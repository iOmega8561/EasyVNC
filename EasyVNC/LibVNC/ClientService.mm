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
//  ClientService.mm
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>
#import <unistd.h>

#import "ClientService.h"
#import "Callbacks.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"

#import "rfb/rfbclient.h"
#import "rfb/rfb.h"

#pragma clang diagnostic pop

@implementation ClientService {
    
//  MARK: - Instance Variables (private)
//  rfbClient is managed on a serial queue
     dispatch_queue_t clientQueue;
//  The event loop is a non-blocking GCD timer
    dispatch_source_t eventTimer;
                 BOOL runEventLoop;
            rfbClient *client;
}

// MARK: - Connection Facilities

- (void)initiateConnectionWith:(Connection *)connection {
    dispatch_async(self->clientQueue, ^{
        
        if (self->client || self.connection) return;
        
        // Create a new rfbClient instance.
        rfbClient *client = rfbGetClient(8, 3, 4);
        if (!client) { return; }
        
        // Acquire strong reference to Connection object
        self.connection = connection;
        
        // Set up callbacks, along with host and port
        client->MallocFrameBuffer = resize_callback;
        client->GotFrameBufferUpdate = framebuffer_update_callback;
        client->GetCredential = client_credential_callback;
        client->GetPassword = client_password_callback;
        client->canHandleNewFBSize = TRUE;
        client->serverHost = strdup([[connection host] UTF8String]);
        client->serverPort = (int32_t)[connection port];
        
        // Set the clientData to self so callbacks can call delegate methods.
        rfbClientSetClientData(client, &kVNCClientTag, (__bridge void *)self);
        
        // Attempt to initialize the client.
        if (!rfbInitClient(client, NULL, NULL)) { return; }
        
        self->client = client;
        self->runEventLoop = YES;
        
        // Start the event loop.
        [self startEventLoopTimer];
        
        // Update connection state for UI
        if (self.delegate) {
            [self.delegate handleConnectionStatusChange:(YES)];
        }
    });
}

- (void)cleanupDisconnect {
    if (self->eventTimer) {
        dispatch_source_cancel(self->eventTimer);
        self->eventTimer = nil;
    }

    if (self->client) {
        // Making sure the client isn't referenced
        // anymore by this wrapper. Could be a mess otherwise.
        rfbClient *client = self->client;
        self->client = NULL;
        
        // Only then, we clean it up
        rfbClientCleanup(client);
    }

    self->runEventLoop = NO;

    if (self.delegate) {
        // Let's make sure the UI gets updated
        [self.delegate handleConnectionStatusChange:NO];
    }
}

// MARK: - EventLoop Management

- (void)startEventLoopTimer {
    self->eventTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                             0,
                                             0,
                                              self->clientQueue);
    // 1 millisecond is a good compromise.
    // Can be made adjustable in the future.
    dispatch_source_set_timer(self->eventTimer,
                              DISPATCH_TIME_NOW,
                              NSEC_PER_MSEC,
                              NSEC_PER_MSEC);
    // Instead of a blocking while loop, we let good old GCD
    // do the heavy lifting. This handler is not blocking.
    dispatch_source_set_event_handler(self->eventTimer, ^{
        if (self->runEventLoop &&
            self->client &&
            self->client->sock != -1
        ) {
            if (WaitForMessage(self->client, 0) > 0 &&
                !HandleRFBServerMessage(self->client)
            ) {
                self->runEventLoop = NO;
            }
        } else { [self cleanupDisconnect]; }
    });
    // Everything's ready, let's start the timer
    dispatch_resume(self->eventTimer);
}

// MARK: - Input Events Forwarding

- (void)sendPointerEventWithX:(int)x y:(int)y buttonMask:(int)mask {
    dispatch_async(self->clientQueue, ^{
        if (self->client)
            SendPointerEvent(self->client, x, y, mask);
    });
}

- (void)sendKeyEvent:(int)key down:(BOOL)down {
    dispatch_async(self->clientQueue, ^{
        if (self->client)
            SendKeyEvent(self->client, key, down);
    });
}

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _connection = NULL;
        client = NULL;
        // libVNCClient recommends to always access the client on
        // the same thread. we're gonna use a serial queue for safety.
        clientQueue = dispatch_queue_create("com.EasyVNC.ClientQueue",
                                             DISPATCH_QUEUE_SERIAL);
        runEventLoop = NO;
    }
    return self;
}

@end
