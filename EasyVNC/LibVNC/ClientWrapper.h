//
//  Copyright (C) 2025  Giuseppe Rocco
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
//  ----------------------------------------------------------------------
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
#import "Connection.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"

#import "rfb/rfbclient.h"

#pragma clang diagnostic pop

@interface ClientWrapper : NSObject

@property (nonatomic, weak)   id<ClientDelegate> delegate;
@property (nonatomic, strong)   dispatch_queue_t clientQueue;
@property (nonatomic, strong)  dispatch_source_t eventTimer;
@property (atomic, assign)                  BOOL runEventLoop;
@property (nonatomic, assign)          rfbClient *client;
@property (nonatomic, strong)         Connection *connection;

- (void)initiateConnectionWith:(Connection *)connection;

- (void)cleanupDisconnect;

- (void)startEventLoopTimer;

- (void)sendPointerEventWithX:(int)x
                            y:(int)y
                   buttonMask:(int)mask;

- (void)sendKeyEvent:(int)key
                down:(BOOL)down;

@end

#endif /* ClientWrapper_h */
