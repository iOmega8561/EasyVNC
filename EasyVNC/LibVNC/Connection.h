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
//  Connection.h
//  EasyVNC
//
//  Created by Giuseppe Rocco on 04/12/25.
//

#ifndef Connection_h
#define Connection_h

#import <Foundation/Foundation.h>

@interface Connection : NSObject
    
@property (nonatomic, copy, readonly)   NSString *host;
@property (nonatomic, assign, readonly) NSInteger port;
@property (nonatomic, copy, readonly)   NSString *username;
@property (nonatomic, copy, readonly)   NSString *password;

- (instancetype)initWithHost:(NSString *)host
                        port:(NSInteger)port
                    username:(NSString *)username
                    password:(NSString *)password NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

#endif /* Connection_h */
