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

#import "ClientWrapper.h"
#import "ClientDelegate.h"
#import "Callbacks.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"

#import "rfb/rfbclient.h"

#pragma clang diagnostic pop

int kVNCClientTag;

// Callback used when the server requests a new frame buffer allocation.
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

    // Making sure we don't catch dirty memory
    memset(cl->frameBuffer, 0, size);
    
    return TRUE;
}

// Callback triggered when there is a framebuffer update.
void framebuffer_update_callback(rfbClient *cl, int x, int y, int w, int h) {
    
    ClientWrapper *wrapper = (__bridge ClientWrapper *) rfbClientGetClientData(cl, &kVNCClientTag);
    
    if (wrapper.delegate && cl->frameBuffer) {
        
        [wrapper.delegate didUpdateFramebuffer:(const uint8_t *)cl->frameBuffer
                                         width:cl->width
                                        height:cl->height
                                        stride:(cl->width * (cl->format.bitsPerPixel / 8))];
    }
}
