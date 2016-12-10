//
//  NetworkingConstants.swift
//  TZea
//
//  Created by Adam Jawer on 12/10/16.
//  Copyright © 2016 Adam Jawer. All rights reserved.
//

import Foundation

struct HTTPStatusCodes {
    // Informational
    static let informationalUnknown = 1
    static let informationalContinue = 100
    static let informationalSwitchingProtocols = 101
    static let informationalProcessing = 102
    
    // Success
    static let successUnknown = 2
    static let successOK = 200
    static let successCreated = 201
    static let successAccepted = 202
    static let successNonAuthoritativeInformation = 203
    static let successNoContent = 204
    static let successResetContent = 205
    static let successPartialContent = 206
    static let successMultiStatus = 207
    static let successAlreadyReported = 208
    static let successIMUsed = 209
    
    // Redirection
    static let redirectionUnknown = 3
    static let redirectionMultipleChoices = 300
    static let redirectionMovedPermanently = 301
    static let redirectionFound = 302
    static let redirectionSeeOther = 303
    static let redirectionNotModified = 304
    static let redirectionUseProxy = 305
    static let redirectionSwitchProxy = 306
    static let redirectionTemporaryRedirect = 307
    static let redirectionPermanentRedirect = 308
    
    // Client error
    static let clientErrorUnknown = 4
    static let clientErrorBadRequest = 400
    static let clientErrorUnauthorised = 401
    static let clientErrorPaymentRequired = 402
    static let clientErrorForbidden = 403
    static let clientErrorNotFound = 404
    static let clientErrorMethodNotAllowed = 405
    static let clientErrorNotAcceptable = 406
    static let clientErrorProxyAuthenticationRequired = 407
    static let clientErrorRequestTimeout = 408
    static let clientErrorConflict = 409
    static let clientErrorGone = 410
    static let clientErrorLengthRequired = 411
    static let clientErrorPreconditionFailed = 412
    static let clientErrorRequestEntityTooLarge = 413
    static let clientErrorRequestURITooLong = 414
    static let clientErrorUnsupportedMediaType = 415
    static let clientErrorRequestedRangeNotSatisfiable = 416
    static let clientErrorExpectationFailed = 417
    static let clientErrorIamATeapot = 418
    static let clientErrorAuthenticationTimeout = 419
    static let clientErrorMethodFailureSpringFramework = 420
    static let clientErrorEnhanceYourCalmTwitter = 4200
    static let clientErrorUnprocessableEntity = 422
    static let clientErrorLocked = 423
    static let clientErrorFailedDependency = 424
    static let clientErrorMethodFailureWebDaw = 4240
    static let clientErrorUnorderedCollection = 425
    static let clientErrorUpgradeRequired = 426
    static let clientErrorPreconditionRequired = 428
    static let clientErrorTooManyRequests = 429
    static let clientErrorRequestHeaderFieldsTooLarge = 431
    static let clientErrorNoResponseNginx = 444
    static let clientErrorRetryWithMicrosoft = 449
    static let clientErrorBlockedByWindowsParentalControls = 450
    static let clientErrorRedirectMicrosoft = 451
    static let clientErrorUnavailableForLegalReasons = 4510
    static let clientErrorRequestHeaderTooLargeNginx = 494
    static let clientErrorCertErrorNginx = 495
    static let clientErrorNoCertNginx = 496
    static let clientErrorHTTPToHTTPSNginx = 497
    static let clientErrorClientClosedRequestNginx = 499
    
    
    // Server error
    static let serverErrorUnknown = 5
    static let serverErrorInternalServerError = 500
    static let serverErrorNotImplemented = 501
    static let serverErrorBadGateway = 502
    static let serverErrorServiceUnavailable = 503
    static let serverErrorGatewayTimeout = 504
    static let serverErrorHTTPVersionNotSupported = 505
    static let serverErrorVariantAlsoNegotiates = 506
    static let serverErrorInsufficientStorage = 507
    static let serverErrorLoopDetected = 508
    static let serverErrorBandwidthLimitExceeded = 509
    static let serverErrorNotExtended = 510
    static let serverErrorNetworkAuthenticationRequired = 511
    static let serverErrorConnectionTimedOut = 522
    static let serverErrorNetworkReadTimeoutErrorUnknown = 598
    static let serverErrorNetworkConnectTimeoutErrorUnknown = 599
}

enum HTTPError: Error  {
    case httpResponseError(Int)
}
