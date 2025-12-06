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
//  ClientLogger.mm
//  EasyVNC
//
//  Created by Giuseppe Rocco on 03/12/25.
//

#import <Foundation/Foundation.h>

#import "ClientLogger.h"
#import "Callbacks.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"

#import "rfb/rfbclient.h"
#import "rfb/rfb.h"

#pragma clang diagnostic pop

@implementation ClientLogger

#pragma mark - Class stub

+ (instancetype)shared {
    static ClientLogger *logger;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        logger = [[self alloc] _init];
        // Overriding default libVNCClient logging
        // facilities with our own void function (Callbacks.h)
        rfbClientLog = client_log_callback;
        rfbClientErr = client_log_callback;
    });
    
    return logger;
}

#pragma mark - Instance methods

- (void)writeLogData:(NSData *)data {
    if (!data.length) return;

    dispatch_async(self.writeQueue, ^{
        @autoreleasepool {
            NSFileHandle *fileHandle = self.pipe.fileHandleForWriting;
            
            @try {
                [fileHandle writeData:data];
                // Also logs to stdout, we don't wanna lose that
                NSLog(@"%@", [[NSString alloc] initWithData:data
                                               encoding:NSUTF8StringEncoding]);
            } @catch (NSException *exception) {
                NSLog(@"[ClientLogger] writeData exception: %@", exception);
            }
        }
    });
}

#pragma mark - Initialization

// The "public" init shouldn't be used. See "shared" instead.
- (instancetype)init NS_UNAVAILABLE { return nil; }

// This is gonna be used to create the singleton instance
- (instancetype)_init {
    self = [super init];
    if (self) {
        _pipe = [NSPipe pipe];
        _writeQueue = dispatch_queue_create("com.EasyVNC.LoggerQueue",
                                            DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

@end
