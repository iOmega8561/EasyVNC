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
//  Connection.m
//  EasyVNC
//
//  Created by Giuseppe Rocco on 04/12/25.
//

#import <Foundation/Foundation.h>

#import "Connection.h"

@implementation Connection

- (instancetype)initWithHost:(NSString *)host
                        port:(NSInteger)port
                    username:(NSString *)username
                    password:(NSString *)password
{
    self = [super init];
    if (!self) return nil;

    _host = [host copy] ?: @"";
    _port = port;
    _username = [username copy] ?: @"";
    _password = [password copy] ?: @"";

    return self;
}

@end
