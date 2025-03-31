//
//  ClientDelegate.h
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

#ifndef ClientDelegate_h
#define ClientDelegate_h

#import <Foundation/Foundation.h>

@protocol ClientDelegate <NSObject>

- (void)didUpdateFramebuffer:(const uint8_t *)data
                       width:(int)width
                      height:(int)height
                      stride:(int)stride;

@end

#endif /* ClientDelegate_h */
