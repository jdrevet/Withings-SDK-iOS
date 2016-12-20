//
//  Withings_SDK_iOSTests.m
//  Withings-SDK-iOSTests
//
//  Created by Johan Drevet on 13/02/2016.
//  Copyright © 2016 jdrevet. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WithingsAPI.h"

@interface Withings_SDK_iOSTests : XCTestCase

@end

@implementation Withings_SDK_iOSTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    NSString *envVar = [[NSProcessInfo processInfo] environment][@"TEST"];
    XCTAssert(envVar != nil);
    XCTAssert([envVar isEqualToString:@"TEST_TEST"], @"%@", [[NSProcessInfo processInfo] environment]);
    //[[WithingsAPI sharedInstance] setUpWithConsumerKey:CONSUMER_KEY consumerSecret:CONSUMER_SECRET];
}

@end
