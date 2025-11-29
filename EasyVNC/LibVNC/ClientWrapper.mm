//
//  ClientWrapper.mm
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>
#import <unistd.h>
#import "ClientWrapper.h"
#import "Callbacks.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"

#import "rfb/rfbclient.h"
#import "rfb/rfb.h"

#pragma clang diagnostic pop

@implementation ClientWrapper

#pragma mark - Connection Methods

- (void)connectToHost:(NSString *)host port:(int)port {
    dispatch_async(self.clientQueue, ^{
        
        if (self.client) { return; }
        
        // Create a new rfbClient instance.
        rfbClient *client = rfbGetClient(8, 3, 4);
        if (!client) { return; }
        
        // Set up callbacks.
        client->MallocFrameBuffer = resize_callback;
        client->GotFrameBufferUpdate = framebuffer_update_callback;
        client->canHandleNewFBSize = TRUE;
        
        // Set server host and port.
        client->serverHost = strdup([host UTF8String]);
        client->serverPort = port;
        
        // Attempt to initialize the client.
        if (!rfbInitClient(client, NULL, NULL)) { return; }
        
        // Set the clientData to self so callbacks can call delegate methods.
        rfbClientSetClientData(client, &kVNCClientTag, (__bridge void *)self);
        self.client = client;
        self.runEventLoop = YES;
        
        // Start the event loop.
        [self startEventLoop];
        
        // Update connection state for UI
        if (self.delegate) {
            [self.delegate handleConnectionStatusChange:(YES)];
        }
    });
}

- (void)startEventLoop {
    dispatch_async(self.clientQueue, ^{
        
        // Keep running while the flag is set and the client is valid.
        while (self.runEventLoop && self.client && self.client->sock != -1) {
            if (WaitForMessage(self.client, 100000) > 0) {
                if (!HandleRFBServerMessage(self.client)) {
                    break;
                }
            }
        }
                
        // When the loop exits, perform cleanup on the same thread.
        if (self.client) {
            rfbClientCleanup(self.client);
            self.client = NULL;
        }
        
        // Update connection state for UI
        if (self.delegate) {
            [self.delegate handleConnectionStatusChange:(NO)];
        }
    });
}

- (void)disconnect {
    dispatch_async(self.clientQueue, ^{
        
        // Signal the event loop to stop.
        self.runEventLoop = NO;
        
        if (self.client && self.client->sock != -1) {
        
            // Closing the socket forces WaitForMessage() to fail.
            close(self.client->sock);
            self.client->sock = -1;
        }
    });
}

#pragma mark - Input Events

- (void)sendPointerEventWithX:(int)x y:(int)y buttonMask:(int)mask {
    if (self.client) SendPointerEvent(self.client, x, y, mask);
}

- (void)sendKeyEvent:(int)key down:(BOOL)down {
    if (self.client) SendKeyEvent(self.client, key, down);
}

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        // Create a serial queue dedicated to all client operations.
        _clientQueue = dispatch_queue_create("com.EasyVNC.ClientQueue", DISPATCH_QUEUE_SERIAL);
        _runEventLoop = NO;
        _client = NULL;
    }
    return self;
}

@end
