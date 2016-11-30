//
// WithingsAPI.m
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

#import "WithingsAPI.h"
#import <OAuthSwift/OAuthSwift-Swift.h>
#import <SafariServices/SafariServices.h>
#import <SAMKeychain/SAMKeychain.h>
#import "WithingsMeasureAPIClient.h"
#import "WithingsError.h"
#import "WithingsWebViewController.h"


static NSString * const OAUTH_CALLBACK_PATH = @"oauth-callback";
static NSString * const OAUTH_REQUEST_TOKEN_URL = @"https://oauth.withings.com/account/request_token";
static NSString * const OAUTH_AUTHORIZE_URL = @"https://oauth.withings.com/account/authorize";
static NSString * const OAUTH_ACCESS_TOKEN_URL = @"https://oauth.withings.com/account/access_token";
static NSString * const KEY_CHAIN_SERVICE_ID = @"withings.keychain.users";


@interface WithingsAPI () <SFSafariViewControllerDelegate>
@property (strong, nonatomic) NSString *consumerKey;
@property (strong, nonatomic) NSString *consumerSecret;
@property (strong, nonatomic, readwrite) WithingsMeasureAPIClient *measureAPIClient;
@property (copy, nonatomic) void (^ failureBlock) (WithingsError *error);
@property (strong, nonatomic) WithingsWebViewController *withingsWebViewController;
@end


@implementation WithingsAPI

+ (instancetype)sharedInstance;
{
    static WithingsAPI *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //Nothing to init
    }
    return self;
}

- (void)setUpWithConsumerKey:(NSString*)consumerKey consumerSecret:(NSString*)consumerSecret
{
    NSAssert(consumerKey && consumerSecret, @"Consumer key and consumer secret cannot be null");
    _consumerKey = consumerKey;
    _consumerSecret = consumerSecret;
}

- (void)handleOpenURL:(NSURL*)url
{
    if ([url.host isEqualToString:OAUTH_CALLBACK_PATH]) {
        [OAuthSwift handleWithUrl:url];
        [_withingsWebViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)requestAccessAuthorizationWithCallbackScheme:(NSString*)callbackScheme presenterViewController:(UIViewController*)presenterViewController success:(void (^)(NSString *userId))success failure:(void (^)(WithingsError *error))failure
{
    NSAssert(_consumerKey && _consumerSecret, @"Consumer key and consumer secret should be set before the SDK could work");
    
    //Configure the OAuth client
    OAuth1Swift *oauth = [[OAuth1Swift alloc] initWithConsumerKey:_consumerKey consumerSecret:_consumerSecret requestTokenUrl:OAUTH_REQUEST_TOKEN_URL authorizeUrl:OAUTH_AUTHORIZE_URL accessTokenUrl:OAUTH_ACCESS_TOKEN_URL];
    oauth.client.paramsLocation = ParamsLocationRequestURIQuery;
    
    //Set the authorize url handler
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){9, 0, 0}]) {
        //Since iOS 9, we can use the SFSafariViewController
        SafariURLHandler *safariURLHandler = [[SafariURLHandler alloc] initWithViewController:presenterViewController oauthSwift:oauth];
        safariURLHandler.delegate = self;
        self.failureBlock = failure;
        oauth.authorizeURLHandler = safariURLHandler;
    }
    else {
        _withingsWebViewController = [[WithingsWebViewController alloc] initWithPresenterViewController:presenterViewController];
        oauth.authorizeURLHandler = _withingsWebViewController;
    }
    
    //Construct the callback url
    NSURLComponents *callbackUrlComponents = [[NSURLComponents alloc] init];
    callbackUrlComponents.scheme = callbackScheme;
    callbackUrlComponents.host = OAUTH_CALLBACK_PATH;
    
    //Launch the OAuth authorization process
    [oauth objc_authorizeWithCallbackURL:callbackUrlComponents.URL.absoluteString success:^(OAuthSwiftCredential *credential, OAuthSwiftResponse *response, NSDictionary<NSString *,id> *parameters) {
            //Retrieve the user id
            NSString *userId = parameters[@"userid"];
            if(userId) {
                //Store the credentials in the keychain
                [SAMKeychain setPasswordData:[NSKeyedArchiver archivedDataWithRootObject:credential] forService:KEY_CHAIN_SERVICE_ID account:userId];
                success(userId);
            }
            else {
                failure([WithingsError errorWithCode:WithingsErrorOAuth message:@"User id not returned by the server"]);
            }
    } failure:^(NSError *error) {
        failure([WithingsError errorWithCode:WithingsErrorOAuth userInfo:error.userInfo]);
    }];
}

- (BOOL)hasAccessAuthorizationForUser:(NSString*)userId
{
    return ([SAMKeychain passwordDataForService:KEY_CHAIN_SERVICE_ID account:userId] != nil);
}

- (WithingsMeasureAPIClient*)measureAPIClient
{
    NSAssert(_consumerKey && _consumerSecret, @"Consumer key and consumer secret should be set before the SDK could work");
    if(!_measureAPIClient) {
        _measureAPIClient = [[WithingsMeasureAPIClient alloc] initWithConsumerKey:_consumerKey consumerSecret:_consumerSecret];
    }
    return _measureAPIClient;
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller
{
    self.failureBlock([WithingsError errorWithCode:WithingsErrorOAuth message:@"Authorization process cancelled by user"]);
    self.failureBlock = nil;
}


@end
