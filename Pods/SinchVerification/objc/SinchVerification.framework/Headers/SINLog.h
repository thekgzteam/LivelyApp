/*
 * Copyright (c) 2015 Sinch AB. All rights reserved.
 *
 * See LICENSE file for license terms and information.
 */

#ifndef SIN_LOG_H
#define SIN_LOG_H

#import "SINLogSeverity.h"

typedef void (^SINLogCallback)(SINLogSeverity severity, NSString* area, NSString* message, NSDate* timestamp);

#endif  // SIN_LOG_H
