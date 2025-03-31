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

// Callback used when the server requests a new frame buffer allocation.
rfbBool resize_callback(rfbClient *cl) {
    
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
void framebuffer_update_callback(rfbClient *cl, int x, int y, int w, int h) {
    
    ClientWrapper *self = (__bridge ClientWrapper *)(cl->clientData);
    
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
