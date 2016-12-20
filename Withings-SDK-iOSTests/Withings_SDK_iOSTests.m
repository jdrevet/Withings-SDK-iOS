//
//  Withings_SDK_iOSTests.m
//  Withings-SDK-iOSTests
//
//  Created by Johan Drevet on 13/02/2016.
//  Copyright © 2016 jdrevet. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WithingsAPI.h"

#define MACRO_NAME(f) #f
#define MACRO_VALUE(f)  MACRO_NAME(f)

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

- (void)testGetEnvVar {
    NSString *testEnvVar = [NSString stringWithCString:MACRO_VALUE(TEST) encoding:NSUTF8StringEncoding];
    XCTAssertNotNil(testEnvVar);
    XCTAssert([testEnvVar isEqualToString:@"TEST_TEST"], @"%@", testEnvVar);
    //[[WithingsAPI sharedInstance] setUpWithConsumerKey:CONSUMER_KEY consumerSecret:CONSUMER_SECRET];
}

@end
