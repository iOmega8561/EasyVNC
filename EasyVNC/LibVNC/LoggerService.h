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
//  LoggerService.h
//  EasyVNC
//
//  Created by Giuseppe Rocco on 03/12/25.
//

#ifndef LoggerService_h
#define LoggerService_h

#import <Foundation/Foundation.h>

@interface LoggerService : NSObject

// Singleton
// From what i understand, libVNCClient only does global logging.
// It doesn't support piping each client instance individually.
+ (instancetype)shared;

// Any vnc log will be redirected to this NSPipe.
@property (nonatomic, strong, readonly) NSPipe *pipe;
// And we also make sure to execute on a serial queue
@property (nonatomic, strong)           dispatch_queue_t writeQueue;

// This will be used by the appropriate callback
- (void)writeLogData:(NSData *)data;

@end

#endif /* LoggerService_h */
