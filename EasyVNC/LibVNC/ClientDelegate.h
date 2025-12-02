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

- (void)handleConnectionStatusChange:(BOOL)isConnected;

@end

#endif /* ClientDelegate_h */
