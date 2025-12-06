//
//  Copyright (C) 2025  Giuseppe Rocco
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
//  ----------------------------------------------------------------------
//
//  Callbacks.mm
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

#import <Foundation/Foundation.h>

#import "ClientDelegate.h"
#import "ClientService.h"
#import "LoggerService.h"
#import "Callbacks.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"

#import "rfb/rfbclient.h"

#pragma clang diagnostic pop

// This variable is never assigned. We are going
// to use its address as a rfbClient content TAG.
int kVNCClientTag;

// MARK: - Remote Framebuffer Resize Callback
// Triggered on a new frame buffer allocation request.

rfbBool resize_callback(rfbClient *cl) {
    
    // Free any existing framebuffer.
    if (cl->frameBuffer) {
        
        free(cl->frameBuffer);
        cl->frameBuffer = NULL;
    }
    
    // Allocate a new framebuffer.
    int bpp = cl->format.bitsPerPixel / 8;
    int size = cl->width * cl->height * bpp;
    cl->frameBuffer = (uint8_t *)malloc(size);
    
    if (!cl->frameBuffer) { return FALSE; }

    // Making sure we don't catch dirty memory.
    memset(cl->frameBuffer, 0, size);
    
    return TRUE;
}

// MARK: - Remote Framebuffer Update Callback
// Triggered on a framebuffer update.

void framebuffer_update_callback(rfbClient *cl, int x, int y, int w, int h) {
    
    ClientService *service = (__bridge ClientService *) rfbClientGetClientData(cl, &kVNCClientTag);
    
    // Basic NULL checks.
    // There's no point in moving forward if these fail.
    if (!service || !service.delegate || !cl->frameBuffer) {
        return;
    }
    // Safe enough to call the wrapper delegate's method.
    [service.delegate didUpdateFramebuffer:(const uint8_t *)cl->frameBuffer
                                     width:cl->width
                                    height:cl->height
                                    stride:(cl->width * (cl->format.bitsPerPixel / 8))];
}

// MARK: - libVNCClient Logging Facility
// Replaces libVNCClient's default logging utility.

void client_log_callback(const char *format, ...) {
    va_list args;
    va_start(args, format);

    char buffer[2048];
    // vsnprintf can return len > sizeof(buffer).
    int len = vsnprintf(buffer, sizeof(buffer), format, args);
    va_end(args);

    if (len <= 0) return;

    // Forcing termination character if data size
    // happens to exceed buffer size.
    if (len >= (int)sizeof(buffer)) {
        len = (int)sizeof(buffer) - 1;
        buffer[len] = '\0';
    }
    
    // Converting to NSData enhances flexibility in this environment.
    NSData *data = [NSData dataWithBytes:buffer length:len];
    [[LoggerService shared] writeLogData:data];
}

// MARK: - libVNCClient GetPassword Facility
// Replaces libVNCClient's default method for password-only authentication.

char* client_password_callback(rfbClient *cl) {
    
    ClientService *service = (__bridge ClientService *)rfbClientGetClientData(cl, &kVNCClientTag);
    
    // Basic NULL checks
    if (!service || !service.connection)
        return NULL;
    
    return strdup([[service.connection password] UTF8String]);
}

// MARK: - libVNCClient GetCredential Facility
// Replaces libVNCClient's default method for credential authentication.

rfbCredential* client_credential_callback(rfbClient* cl, int credentialType) {
        
    // There's no point in moving forward if this fails.
    // This method only supports plain VeNCrypt/MSLogon authentication.
    if (credentialType != rfbCredentialTypeUser) {
        rfbClientErr("Authentication does not require USERNAME\n");
        return NULL;
    }
    
    // This needs to be checked for NULL first, segfault can occurr.
    rfbCredential *credential = (rfbCredential *)malloc(sizeof(rfbCredential));
    if (!credential) { return NULL; }
    
    // This we're gonna check later ...
    credential->userCredential.username = (char *)malloc(RFB_BUF_SIZE);
    credential->userCredential.password = (char *)malloc(RFB_BUF_SIZE);
    // This too, look below for NULL checks ...
    ClientService *service = (__bridge ClientService *)rfbClientGetClientData(cl, &kVNCClientTag);
    
    // Now we can group these NULL checks, instead of having
    // a bazillion of if-statements in this callback function.
    if (!credential->userCredential.username ||
        !credential->userCredential.password ||
        !service ||
        !service.connection
    ) {
        free(credential->userCredential.username);
        free(credential->userCredential.password);
        free(credential);
        return NULL;
    }

    // Dupe the strings and send back to the client. Source is NSString, empty is fine.
    credential->userCredential.username = strdup([[service.connection username] UTF8String]);
    credential->userCredential.password = strdup([[service.connection password] UTF8String]);
    return credential;
}
 
