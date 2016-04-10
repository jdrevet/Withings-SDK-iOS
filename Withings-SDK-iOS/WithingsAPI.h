//
// WithingsAPI.h
// Withings-SDK-iOS
//
// Copyright (c) 2016 jdrevet
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
//

#import <Foundation/Foundation.h>

@class UIViewController;
@class WithingsMeasureAPIClient;
@class WithingsError;


/**
 * The base SDK object, which manages and persists the users authorizations and holds a client to call the API.
 * It must be set up with your application keys before any other call.
 */
@interface WithingsAPI : NSObject

/**
 * Gets the unique instance of WithingsAPI.
 *
 * @return The unique instance of WithingsAPI
 */
+ (instancetype)sharedInstance;

/**
 * Sets up the SDK with your application keys. It must be done before any other call.
 * To get your keys, register to [Withings](https://account.withings.com/connectionuser/account_login?r=http%3A%2F%2Foauth.withings.com%2Fpartner%2Fadd).
 *
 * @param consumerKey Your consumer key
 * @param consumerSecret Your consumer secret
 */
- (void)setUpWithConsumerKey:(NSString*)consumerKey consumerSecret:(NSString*)consumerSecret;

/**
 * Handles the OAuth callback received when the user authorizes your application to access to his resources.
 * This method should be called in application:openURL: of your AppDelegate.
 *
 * @param url The callback url
 */
- (void)handleOpenURL:(NSURL*)url;

/**
 * Requests authorization to access to current user resources. The user will be sent to a web page provided by Withings to authorize your application to access to his resources.
 *
 * @param callbackScheme Your application scheme. It is used to handle the process once the user gives authorization.
 * @param presenterViewController The view controller which will present the authorization view.
 * @param success A block object to be executed when the user has granted access
 * 
 * - *userId* The id of the user who has given his authorization. Your application should persist this id to be able to request Withings API without requesting again the user authorization
 * @param failure A block object to be executed when an error occured during the authorization process
 *
 * - *error* The encountered error
 */
- (void)requestAccessAuthorizationWithCallbackScheme:(NSString*)callbackScheme presenterViewController:(UIViewController*)presenterViewController success:(void (^)(NSString *userId))success failure:(void (^)(WithingsError *error))failure;

/**
 * Indicates if the user has already given his authorization to access his resources.
 *
 * @param userId The Withings user id returned during authorization process
 * @return YES if the user has already given his authorization to access his resources
 */
- (BOOL)hasAccessAuthorizationForUser:(NSString*)userId;

/**
 * The convenient API client managed by the singleton.
 */
@property (readonly, nonatomic) WithingsMeasureAPIClient *measureAPIClient;

@end
