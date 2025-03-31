//
//  ClientWrapper.h
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

#ifndef ClientWrapper_h
#define ClientWrapper_h

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "ClientWrapper.h"
#import "ClientDelegate.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"

#import "rfb/rfbclient.h"

#pragma clang diagnostic pop

@interface ClientWrapper : NSObject

@property (nonatomic, weak)   id<ClientDelegate> delegate;
@property (nonatomic, strong) dispatch_queue_t clientQueue;
@property (atomic, assign)    BOOL runEventLoop;
@property (nonatomic, assign) rfbClient *client;

- (void)connectToHost:(NSString *)host
                 port:(int)port
           completion:(void (^)(BOOL success))completion;

- (void)sendPointerEventWithX:(int)x
                            y:(int)y
                   buttonMask:(int)mask;

- (void)sendKeyEvent:(int)key
                down:(BOOL)down;

- (void)disconnect;

@end

#endif /* ClientWrapper_h */
