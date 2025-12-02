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
