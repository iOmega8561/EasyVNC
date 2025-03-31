//
//  VNCClientWrapper.mm
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"

#import "VNCClientWrapper.h"
#import "rfb/rfbclient.h"
#import "rfb/rfbproto.h"

#pragma clang diagnostic pop

@implementation VNCClientWrapper {
    rfbClient* _client;
}

static rfbBool resize_callback(rfbClient* cl) {
    
    // If there's already a framebuffer, free it (or reallocate).
    if (cl->frameBuffer) {
        free(cl->frameBuffer);
        cl->frameBuffer = NULL;
    }
    
    // Allocate a new buffer
    // (width * height * bytesPerPixel).
    int bpp = cl->format.bitsPerPixel / 8;
    cl->frameBuffer = (uint8_t *)malloc(cl->width * cl->height * bpp);

    return TRUE; // Let the library know allocation succeeded.
}

static void framebuffer_update_callback(rfbClient* cl, int x, int y, int w, int h) {
    VNCClientWrapper* self = (__bridge VNCClientWrapper*)cl->clientData;
            
    if (self.delegate && cl->frameBuffer) {
        
        // If your delegate needs to update UI, dispatch to main queue:
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didUpdateFramebuffer:(const uint8_t *)cl->frameBuffer
                                           width:cl->width
                                          height:cl->height
                                          stride:cl->width * (cl->format.bitsPerPixel / 8)];
        });
    }
}

- (BOOL)connectToHost:(NSString *)host port:(int)port {
    if (_client) return NO;

    _client = rfbGetClient(8, 3, 4);
    
    _client->canHandleNewFBSize = TRUE;
    _client->MallocFrameBuffer = resize_callback;
    _client->GotFrameBufferUpdate = framebuffer_update_callback;
    _client->clientData = (rfbClientData*)(__bridge void*) self;

    const char *host_c = [host UTF8String];
    _client->serverHost = strdup(host_c);
    _client->serverPort = port;

    NSLog(@"Connecting to %s:%d", _client->serverHost, _client->serverPort);
    
    if (!rfbInitClient(_client, nullptr, nullptr)) {
        if (_client) {
            if (_client->frameBuffer) {
                free(_client->frameBuffer);
            }
            free(_client->serverHost);
            free(_client);
        }
        _client = nullptr;
        return NO;
    }
    
    // Start the event loop to process incoming updates in the background.
    [self startEventLoop];
    
    return YES;
}

- (void)startEventLoop {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        while (self->_client && self->_client->sock != -1) {
            
            NSLog(@"Current socket: %d", self->_client->sock);
            int waitResult = WaitForMessage(self->_client, 100000);
            
            NSLog(@"WaitForMessage returned: %d", waitResult);
            if (waitResult > 0) {
            
                BOOL handled = HandleRFBServerMessage(self->_client);
                NSLog(@"HandleRFBServerMessage returned: %d", handled);
                
                if (!handled) {
                    NSLog(@"Message handling failed, breaking loop.");
                    break;
                }
            }
        }
        
        NSLog(@"Exiting event loop");
        [self disconnect];
    });
}

- (void)sendPointerEventWithX:(int)x y:(int)y buttonMask:(int)mask {
    if (_client) SendPointerEvent(_client, x, y, mask);
}

- (void)sendKeyEvent:(int)key down:(BOOL)down {
    if (_client) SendKeyEvent(_client, key, down);
}

- (void)disconnect {
    if (_client) {
        _client->frameBuffer = NULL;
        _client->clientData = NULL;
        _client->GotFrameBufferUpdate = NULL;

        rfbClientCleanup(_client);
        _client = nullptr;
    }
}

@end
