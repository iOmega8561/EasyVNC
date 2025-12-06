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
//  Callbacks.h
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

#ifndef Callbacks_h
#define Callbacks_h

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"

#import "rfb/rfbclient.h"

#pragma clang diagnostic pop

// rfbClient content TAG.
extern int kVNCClientTag;

// MARK: - Remote Framebuffer Resize Callback
rfbBool resize_callback(struct _rfbClient *cl);

// MARK: - Remote Framebuffer Update Callback
void framebuffer_update_callback(struct _rfbClient *cl,
                                               int x,
                                               int y,
                                               int w,
                                               int h);

// MARK: - libVNCClient Logging Facility
void client_log_callback(const char *format, ...);

// MARK: - libVNCClient GetPassword Facility
char* client_password_callback(rfbClient *cl);

// MARK: - libVNCClient GetCredential Facility
rfbCredential* client_credential_callback(rfbClient* cl,
                                                 int credentialType);

#endif /* Callbacks_h */
