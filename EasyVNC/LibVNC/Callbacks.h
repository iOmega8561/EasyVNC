//
//  Callbacks.h
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

#ifndef Callbacks_h
#define Callbacks_h

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"

#import "rfb/rfbclient.h"

#pragma clang diagnostic pop

extern int kVNCClientTag;

rfbBool resize_callback(struct _rfbClient *cl);

void framebuffer_update_callback(struct _rfbClient *cl,
                                                 int x,
                                                 int y,
                                                 int w,
                                                 int h);

#endif /* Callbacks_h */
