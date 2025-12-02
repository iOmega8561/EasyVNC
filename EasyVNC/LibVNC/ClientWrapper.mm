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
        
        // Set up callbacks, along with host and port
        client->MallocFrameBuffer = resize_callback;
        client->GotFrameBufferUpdate = framebuffer_update_callback;
        client->canHandleNewFBSize = TRUE;
        client->serverHost = strdup([host UTF8String]);
        client->serverPort = port;
        
        // Attempt to initialize the client.
        if (!rfbInitClient(client, NULL, NULL)) { return; }
        
        // Set the clientData to self so callbacks can call delegate methods.
        rfbClientSetClientData(client, &kVNCClientTag, (__bridge void *)self);
        self.client = client;
        self.runEventLoop = YES;
        
        // Start the event loop.
        [self startEventLoopTimer];
        
        // Update connection state for UI
        if (self.delegate) {
            [self.delegate handleConnectionStatusChange:(YES)];
        }
    });
}

- (void)cleanupDisconnect {
    if (self.eventTimer) {
        dispatch_source_cancel(self.eventTimer);
        self.eventTimer = nil;
    }

    if (self.client) {
        // Making sure the client isn't referenced
        // anymore by this wrapper. Could be a mess otherwise.
        rfbClient *client = self.client;
        self.client = NULL;
        
        // Only then, we clean it up
        rfbClientCleanup(client);
    }

    self.runEventLoop = NO;

    if (self.delegate) {
        // Let's make sure the UI gets updated
        [self.delegate handleConnectionStatusChange:NO];
    }
}

- (void)startEventLoopTimer {
    self.eventTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                             0,
                                             0,
                                             self.clientQueue);
    // 1 millisecond is a good compromise.
    // Can be made adjustable in the future.
    dispatch_source_set_timer(self.eventTimer,
                              DISPATCH_TIME_NOW,
                              NSEC_PER_MSEC,
                              NSEC_PER_MSEC);
    // Instead of a blocking while loop, we let good old GCD
    // do the heavy lifting. This handler is not blocking.
    dispatch_source_set_event_handler(self.eventTimer, ^{
        if (self.runEventLoop &&
            self.client &&
            self.client->sock != -1
        ) {
            if (WaitForMessage(self.client, 0) > 0 &&
                !HandleRFBServerMessage(self.client)
            ) {
                self.runEventLoop = NO;
            }
        } else { [self cleanupDisconnect]; }
    });
    // Everything's ready, let's start the timer
    dispatch_resume(self.eventTimer);
}

#pragma mark - Input Events

- (void)sendPointerEventWithX:(int)x y:(int)y buttonMask:(int)mask {
    dispatch_async(self.clientQueue, ^{
        if (self.client)
            SendPointerEvent(self.client, x, y, mask);
    });
}

- (void)sendKeyEvent:(int)key down:(BOOL)down {
    dispatch_async(self.clientQueue, ^{
        if (self.client)
            SendKeyEvent(self.client, key, down);
    });
}

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _client = NULL;
        // libVNCClient recommends to always access the client on
        // the same thread. we're gonna use a serial queue for safety.
        _clientQueue = dispatch_queue_create("com.EasyVNC.ClientQueue",
                                             DISPATCH_QUEUE_SERIAL);
        _runEventLoop = NO;
    }
    return self;
}

@end
