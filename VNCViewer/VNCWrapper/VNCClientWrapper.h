//
//  VNCClientWrapper.h
//  VNCViewer
//
//  Created by Giuseppe Rocco on 31/03/25.
//

#ifndef VNCClientWrapper_h
#define VNCClientWrapper_h

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@protocol VNCClientDelegate <NSObject>

- (void)didUpdateFramebuffer:(const uint8_t *)data width:(int)width height:(int)height stride:(int)stride;

@end

@interface VNCClientWrapper : NSObject

@property (nonatomic, weak) id<VNCClientDelegate> delegate;

- (BOOL)connectToHost:(NSString *)host port:(int)port;

- (void)sendPointerEventWithX:(int)x y:(int)y buttonMask:(int)mask;

- (void)sendKeyEvent:(int)key down:(BOOL)down;

- (void)disconnect;

@end

#endif /* VNCClientWrapper_h */
