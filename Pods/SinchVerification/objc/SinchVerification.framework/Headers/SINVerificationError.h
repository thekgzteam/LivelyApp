/*
 * Copyright (c) 2015 Sinch AB. All rights reserved.
 *
 * See LICENSE file for license terms and information.
 */

#import <Foundation/Foundation.h>

extern NSString* __nonnull const SINVerificationErrorDomain;

// Key that may be populated in NSError userInfo. If present, the
// value is a unique reference to the error and be used for tracing a
// request through all Sinch services.
extern NSString* __nonnull const SINServiceErrorReferenceKey;

enum {
  // Invalid input, client-side (e.g. nil input)
  SINVerificationErrorInvalidInput = 1,
  SINVerificationErrorIncorrectCode,
  SINVerificationErrorCalloutFailure,
  SINVerificationErrorTimeout,
  SINVerificationErrorCancelled,
  // Sinch backend service error
  SINVerificationErrorServiceError,
};
