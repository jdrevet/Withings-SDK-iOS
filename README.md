## Overview

Withings-SDK-iOS provides an Objective-C interface for integrating iOS apps with the [Withings API](http://oauth.withings.com/api). It handles OAuth 1.0 authentication using [OAuthSwift library](https://github.com/OAuthSwift/OAuthSwift).


## Requirements

Withings-SDK-iOS requires iOS 8.0 and above.


In order to use the API, you will need to register as a developer [here](https://oauth.withings.com/partner/add) to get a consumer key and secret. Note that you will also need to have an end-user Withings account to fetch data from. 


Several third-party open source libraries are used within Withings-SDK-iOS:
1. [OAuthSwift](https://github.com/OAuthSwift/OAuthSwift) - OAuth support
2. [DCKeyValueObjectMapping](https://github.com/dchohfi/KeyValueObjectMapping) - JSON mapping
3. [SSKeychain](https://github.com/soffes/SSKeychain) - Keychain wrapper


## Installation

### Installation with CocoaPods

TODO

### Installation with Carthage

TODO


## Usage

### SDK setup

Before any other call, set up the SDK with your application keys
```
NSString *consumerKey = @"<Your consumer key>";
NSString *consumerSecret = @"<Your consumer secret>";
[[WithingsAPI sharedInstance] setUpWithConsumerKey:consumerKey consumerSecret:consumerSecret];
```
To get your keys, register as a developer [here](https://oauth.withings.com/partner/add)

### Callback management

During the OAuth 1.0 authentication process, the user will be redirect to a web page managed by Withings to authorize your application to access to his resources. Your application should be configured to handle the callback called at the end of the process.
- Declare an URL scheme fo your application
- In your AppDelegate, implement `application:openURL:`
```
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
    [[WithingsAPI sharedInstance] handleOpenURL:url];
    return YES;
}
```
Implement also the deprecated method to manage the callbacks on iOS 8.0
```
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation
{
    [[WithingsAPI sharedInstance] handleOpenURL:url];
    return YES;
}
```

### Request user authorization

Request the user authorization
```
[[WithingsAPI sharedInstance] requestAccessAuthorizationWithCallbackScheme:@"<Your application scheme>" presenterViewController:self success:^(NSString *userId) {
	//Persist the user id to be able to request Withings API without requesting again the user authorization
} failure:^(WithingsError *error) {
    //Manage the error
}];
```

### Call APIs

Once you have user authorization, you can call any API provided by the API client.
For example, to get all the activities measures for an user, call:
```
[[WithingsAPI sharedInstance].measureAPIClient getActivitiesMeasuresForUser:@"<The user id>" success:^(NSArray<WithingsActivity *> *activitiesMeasures) {
    //Process the results
} failure:^(WithingsError *error) {
    //Manage the error
}
```


## License

Withings-SDK-iOS is released under the MIT license. See LICENSE for details.
