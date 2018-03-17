// RKClient+Errors.m
//
// Copyright (c) 2014 Sam Symons (http://samsymons.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "RKClient+Errors.h"

@implementation RKClient (Errors)

const NSInteger RKClientErrorAuthenticationFailed = 1;

const NSInteger RKClientErrorInvalidCaptcha = 201;
const NSInteger RKClientErrorInvalidCSSClassName = 202;
const NSInteger RKClientErrorInvalidCredentials = 203;
const NSInteger RKClientErrorRateLimited = 204;
const NSInteger RKClientErrorTooManyFlairClassNames = 205;
const NSInteger RKClientErrorArchived = 206;
const NSInteger RKClientErrorInvalidSubreddit = 207;
const NSInteger RKClientErrorLinkAlreadySubmitted = 208;

const NSInteger RKClientErrorInvalidMultiredditName = 401;
const NSInteger RKClientErrorPermissionDenied = 402;
const NSInteger RKClientErrorConflict = 403;
const NSInteger RKClientErrorNotFound = 404;

const NSInteger RKClientErrorInternalServerError = 501;
const NSInteger RKClientErrorBadGateway = 502;
const NSInteger RKClientErrorServiceUnavailable = 503;
const NSInteger RKClientErrorTimedOut = 504;

+ (NSError *)errorFromResponse:(NSHTTPURLResponse *)response responseString:(NSString *)responseString
{
    NSParameterAssert(response);
    NSParameterAssert(responseString);
    
    return [[self class] errorFromStatusCode:response.statusCode responseString:responseString];
}

+ (NSError *)errorFromStatusCode:(NSInteger)statusCode responseString:(NSString *)responseString
{
    switch (statusCode)
    {
        case 200:
            if ([RKClient string:responseString containsSubstring:@"WRONG_PASSWORD"]) return [RKClient invalidCredentialsError];
            if ([RKClient string:responseString containsSubstring:@"BAD_CAPTCHA"]) return [RKClient invalidCaptchaError];
            if ([RKClient string:responseString containsSubstring:@"RATELIMIT"]) return [RKClient rateLimitedError];
            if ([RKClient string:responseString containsSubstring:@"BAD_CSS_NAME"]) return [RKClient invalidCSSClassNameError];
            if ([RKClient string:responseString containsSubstring:@"TOO_OLD"]) return [RKClient archivedError];
            if ([RKClient string:responseString containsSubstring:@"TOO_MUCH_FLAIR_CSS"]) return [RKClient tooManyFlairClassNamesError];
            if ([RKClient string:responseString containsSubstring:@"SUBREDDIT_NOEXIST"]) return [RKClient invalidSubredditError];
            if ([RKClient string:responseString containsSubstring:@"ALREADY_SUB"]) return [RKClient linkAlreadySubmittedError];
            
            break;
        case 400:
            if ([RKClient string:responseString containsSubstring:@"BAD_MULTI_NAME"]) return [RKClient invalidMultiredditNameError];
            
            break;
        case 403:
            if ([RKClient string:responseString containsSubstring:@"USER_REQUIRED"]) return [RKClient authenticationRequiredError];
            
            return [RKClient permissionDeniedError];
            break;
        case 404:
            return [RKClient notFoundError];
            break;
        case 409:
            return [RKClient conflictError];
            break;
        case 500:
            return [RKClient internalServerError];
            break;
        case 502:
            return [RKClient badGatewayError];
            break;
        case 503:
            return [RKClient serviceUnavailableError];
            break;
        case 504:
            return [RKClient timedOutError];
            break;
        default:
            break;
    }
    
    return nil;
}

+ (NSError *)errorFromResponseObject:(id)responseObject
{
    NSParameterAssert(responseObject);
    
    if ([responseObject isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *response = responseObject;
        NSNumber *statusCodeError = response[@"error"];
        NSArray *errors = [response valueForKeyPath:@"json.errors"];
        
        if ([errors isKindOfClass:[NSArray class]] && [errors count] > 0)
        {
            id firstObject = [errors firstObject];
            
            if ([firstObject isKindOfClass:[NSArray class]] && [firstObject count] > 1)
            {
                NSString *firstString = [firstObject firstObject];
                NSString *secondString = [firstObject objectAtIndex:1];
                
                if ([firstString isKindOfClass:[NSString class]] && [secondString isKindOfClass:[NSString class]])
                {
                    return [[self class] errorFromStatusCode:200 responseString:firstString];
                }
            }
        }
        else if (statusCodeError)
        {
            return [[self class] errorFromStatusCode:[statusCodeError integerValue] responseString:@""];
        }
    }
    
    return nil;
}

+ (NSError *)authenticationRequiredError
{
    NSDictionary *userInfo = [RKClient userInfoWithDescription:NSLocalizedStringFromTable(@"Authentication required", @"RedditKit", nil) failureReason:NSLocalizedStringFromTable(@"This method requires you to be signed in.", @"RedditKit", nil)];
    return [NSError errorWithDomain:RKClientErrorDomain code:RKClientErrorAuthenticationFailed userInfo:userInfo];
}

+ (NSError *)invalidCaptchaError
{
    NSDictionary *userInfo = [RKClient userInfoWithDescription:NSLocalizedStringFromTable(@"Invalid CAPTCHA", @"RedditKit", nil) failureReason:NSLocalizedStringFromTable(@"The CAPTCHA value or identifier you provided was invalid.", @"RedditKit", nil)];
    return [NSError errorWithDomain:RKClientErrorDomain code:RKClientErrorInvalidCaptcha userInfo:userInfo];
}

+ (NSError *)invalidCSSClassNameError
{
    NSDictionary *userInfo = [RKClient userInfoWithDescription:NSLocalizedStringFromTable(@"Invalid CSS class name", @"RedditKit", nil) failureReason:NSLocalizedStringFromTable(@"A CSS name you provided contained invalid characters.", @"RedditKit", nil)];
    return [NSError errorWithDomain:RKClientErrorDomain code:RKClientErrorInvalidCSSClassName userInfo:userInfo];
}

+ (NSError *)invalidCredentialsError
{
    NSDictionary *userInfo = [RKClient userInfoWithDescription:NSLocalizedStringFromTable(@"Invalid credentials", @"RedditKit", nil) failureReason:NSLocalizedStringFromTable(@"Your username or password were incorrect.", @"RedditKit", nil)];
    return [NSError errorWithDomain:RKClientErrorDomain code:RKClientErrorInvalidCredentials userInfo:userInfo];
}

+ (NSError *)linkAlreadySubmittedError
{
    NSDictionary *userInfo = [RKClient userInfoWithDescription:NSLocalizedStringFromTable(@"Link already submitted", @"RedditKit", nil) failureReason:NSLocalizedStringFromTable(@"This link has already been submitted to this subreddit.", @"RedditKit", nil)];
    return [NSError errorWithDomain:RKClientErrorDomain code:RKClientErrorLinkAlreadySubmitted userInfo:userInfo];
}

+ (NSError *)rateLimitedError
{
    NSDictionary *userInfo = [RKClient userInfoWithDescription:NSLocalizedStringFromTable(@"Rate limited", @"RedditKit", nil) failureReason:NSLocalizedStringFromTable(@"You have exceeded reddit's rate limit.", @"RedditKit", nil)];
    return [NSError errorWithDomain:RKClientErrorDomain code:RKClientErrorRateLimited userInfo:userInfo];
}

+ (NSError *)tooManyFlairClassNamesError
{
    NSDictionary *userInfo = [RKClient userInfoWithDescription:NSLocalizedStringFromTable(@"Too many flair class names", @"RedditKit", nil) failureReason:NSLocalizedStringFromTable(@"You have passed in too many flair class names", @"RedditKit", nil)];
    return [NSError errorWithDomain:RKClientErrorDomain code:RKClientErrorTooManyFlairClassNames userInfo:userInfo];
}

+ (NSError *)invalidSubredditError
{
    NSDictionary *userInfo = [RKClient userInfoWithDescription:NSLocalizedStringFromTable(@"That subreddit does not exist", @"RedditKit", nil) failureReason:NSLocalizedStringFromTable(@"You have entered an invalid subreddit name", @"RedditKit", nil)];
    return [NSError errorWithDomain:RKClientErrorDomain code:RKClientErrorInvalidSubreddit userInfo:userInfo];
}

+ (NSError *)archivedError
{
    NSDictionary *userInfo = [RKClient userInfoWithDescription:NSLocalizedStringFromTable(@"This object has been archived", @"RedditKit", nil) failureReason:NSLocalizedStringFromTable(@"The object you tried to interact with has been archived.", @"RedditKit", nil)];
    return [NSError errorWithDomain:RKClientErrorDomain code:RKClientErrorArchived userInfo:userInfo];
}

+ (NSError *)invalidMultiredditNameError
{
    NSDictionary *userInfo = [RKClient userInfoWithDescription:NSLocalizedStringFromTable(@"Invalid multireddit name", @"RedditKit", nil) failureReason:NSLocalizedStringFromTable(@"The name provided for the multireddit was invalid.", @"RedditKit", nil)];
    return [NSError errorWithDomain:RKClientErrorDomain code:RKClientErrorInvalidMultiredditName userInfo:userInfo];
}

+ (NSError *)permissionDeniedError
{
    NSDictionary *userInfo = [RKClient userInfoWithDescription:NSLocalizedStringFromTable(@"Permission denied", @"RedditKit", nil) failureReason:NSLocalizedStringFromTable(@"You don't have permission to access this resource.", @"RedditKit", nil)];
    return [NSError errorWithDomain:RKClientErrorDomain code:RKClientErrorPermissionDenied userInfo:userInfo];
}

+ (NSError *)conflictError
{
    NSDictionary *userInfo = [RKClient userInfoWithDescription:NSLocalizedStringFromTable(@"Conflict", @"RedditKit", nil) failureReason:NSLocalizedStringFromTable(@"Your attempt to create a resource caused a conflict.", @"RedditKit", nil)];
    return [NSError errorWithDomain:RKClientErrorDomain code:RKClientErrorConflict userInfo:userInfo];
}

+ (NSError *)notFoundError
{
    NSDictionary *userInfo = [RKClient userInfoWithDescription:NSLocalizedStringFromTable(@"Not found", @"RedditKit", nil) failureReason:NSLocalizedStringFromTable(@"This content could not be found.", @"RedditKit", nil)];
    return [NSError errorWithDomain:RKClientErrorDomain code:RKClientErrorNotFound userInfo:userInfo];
}

+ (NSError *)internalServerError
{
    NSDictionary *userInfo = [RKClient userInfoWithDescription:NSLocalizedStringFromTable(@"Internal server error", @"RedditKit", nil) failureReason:NSLocalizedStringFromTable(@"The reddit servers suffered an internal server error.", @"RedditKit", nil)];
    return [NSError errorWithDomain:RKClientErrorDomain code:RKClientErrorInternalServerError userInfo:userInfo];
}

+ (NSError *)badGatewayError
{
    NSDictionary *userInfo = [RKClient userInfoWithDescription:NSLocalizedStringFromTable(@"Bad gateway", @"RedditKit", nil) failureReason:NSLocalizedStringFromTable(@"Bad gateway.", @"RedditKit", nil)];
    return [NSError errorWithDomain:RKClientErrorDomain code:RKClientErrorBadGateway userInfo:userInfo];
}

+ (NSError *)serviceUnavailableError
{
    NSDictionary *userInfo = [RKClient userInfoWithDescription:NSLocalizedStringFromTable(@"Service unavailable", @"RedditKit", nil) failureReason:NSLocalizedStringFromTable(@"The reddit servers are unavailable.", @"RedditKit", nil)];
    return [NSError errorWithDomain:RKClientErrorDomain code:RKClientErrorServiceUnavailable userInfo:userInfo];
}

+ (NSError *)timedOutError
{
    NSDictionary *userInfo = [RKClient userInfoWithDescription:NSLocalizedStringFromTable(@"Timed out", @"RedditKit", nil) failureReason:NSLocalizedStringFromTable(@"The reddit servers timed out.", @"RedditKit", nil)];
    return [NSError errorWithDomain:RKClientErrorDomain code:RKClientErrorTimedOut userInfo:userInfo];
}

#pragma mark - Private

+ (BOOL)string:(NSString *)string containsSubstring:(NSString *)substring
{
    NSRange range = [string rangeOfString:substring];
    return (range.location != NSNotFound);
}

+ (NSDictionary *)userInfoWithDescription:(NSString *)description failureReason:(NSString *)failureReason
{
    return @{ NSLocalizedDescriptionKey:description, NSLocalizedFailureReasonErrorKey:failureReason };
}

@end