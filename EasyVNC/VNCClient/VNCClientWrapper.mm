//
//  VNCClientWrapper.mm
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>
#import <unistd.h>
#import "VNCClientWrapper.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"

#import "rfb/rfbclient.h"

#pragma clang diagnostic pop

@implementation VNCClientWrapper

#pragma mark - Callback Functions

// Callback used when the server requests a new frame buffer allocation.
static rfbBool resize_callback(rfbClient *cl) {
    // Free any existing framebuffer.
    if (cl->frameBuffer) {
        free(cl->frameBuffer);
        cl->frameBuffer = NULL;
    }
    // Allocate a new framebuffer.
    int bpp = cl->format.bitsPerPixel / 8;
    cl->frameBuffer = (uint8_t *)malloc(cl->width * cl->height * bpp);
    return TRUE;
}

// Callback triggered when there is a framebuffer update.
static void framebuffer_update_callback(rfbClient *cl, int x, int y, int w, int h) {
    VNCClientWrapper *self = (__bridge VNCClientWrapper *)(cl->clientData);
    if (self.delegate && cl->frameBuffer) {
        // Dispatch any UI update to the main thread.
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didUpdateFramebuffer:(const uint8_t *)cl->frameBuffer
                                            width:cl->width
                                           height:cl->height
                                           stride:(cl->width * (cl->format.bitsPerPixel / 8))];
        });
    }
}

#pragma mark - Connection Methods

- (void)connectToHost:(NSString *)host port:(int)port completion:(void (^)(BOOL success))completion {
    dispatch_async(self.clientQueue, ^{
        if (self.client) {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO);
                });
            }
            return;
        }
        
        // Create a new rfbClient instance.
        rfbClient *client = rfbGetClient(8, 3, 4);
        if (!client) {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO);
                });
            }
            return;
        }
        
        // Set up callbacks.
        client->MallocFrameBuffer = resize_callback;
        client->GotFrameBufferUpdate = framebuffer_update_callback;
        client->canHandleNewFBSize = TRUE;
        
        // Set server host and port.
        client->serverHost = strdup([host UTF8String]);
        client->serverPort = port;
        
        // Attempt to initialize the client.
        if (!rfbInitClient(client, NULL, NULL)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
            return;
        }
        
        // Set the clientData to self so callbacks can call delegate methods.
        client->clientData = (rfbClientData *)(__bridge void *)(self);
        self.client = client;
        self.runEventLoop = YES;
        
        // Start the event loop.
        [self startEventLoop];
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES);
            });
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
