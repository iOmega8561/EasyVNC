//
//  VNCClientWrapper.mm
//  VNCViewer
//
//  Created by Giuseppe Rocco on 31/03/25.
//

#import <Foundation/Foundation.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"

#import "VNCClientWrapper.h"
#import "rfb/rfbclient.h"

#pragma clang diagnostic pop

@implementation VNCClientWrapper {
    rfbClient* _client;
}

static rfbBool resize_callback(rfbClient* cl) {
    return TRUE;
}

static void framebuffer_update_callback(rfbClient* cl, int x, int y, int w, int h) {
    
    VNCClientWrapper* self = (__bridge VNCClientWrapper*)cl->clientData;
    
    if (self.delegate && cl->frameBuffer) {
        
        [self.delegate didUpdateFramebuffer:(const uint8_t *)cl->frameBuffer
                                      width:cl->width
                                     height:cl->height
                                     stride:cl->width * (cl->format.bitsPerPixel / 8)];
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
    
    return YES;
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
