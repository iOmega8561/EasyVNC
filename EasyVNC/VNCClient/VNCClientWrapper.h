//
//  VNCClientWrapper.h
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

#ifndef VNCClientWrapper_h
#define VNCClientWrapper_h

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"

#import "rfb/rfbclient.h"

#pragma clang diagnostic pop

@protocol VNCClientDelegate <NSObject>

- (void)didUpdateFramebuffer:(const uint8_t *)data width:(int)width height:(int)height stride:(int)stride;

@end

@interface VNCClientWrapper : NSObject

@property (nonatomic, weak) id<VNCClientDelegate> delegate;
@property (nonatomic, strong) dispatch_queue_t clientQueue;
@property (atomic, assign) BOOL runEventLoop;
@property (nonatomic, assign) rfbClient *client;

- (void)connectToHost:(NSString *)host port:(int)port completion:(void (^)(BOOL success))completion;

- (void)sendPointerEventWithX:(int)x y:(int)y buttonMask:(int)mask;

- (void)sendKeyEvent:(int)key down:(BOOL)down;

- (void)disconnect;

@end

#endif /* VNCClientWrapper_h */
