//
//  WithingsSleepMeasure.h
//  Withings-SDK-iOS
//
//  Created by Robert Turrall on 09/06/16.
//  Copyright © 2016 robertturrall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WithingsSleepMeasure : NSObject

/**
 * Measure types.
 */
typedef NS_ENUM(NSInteger, WithingsSleepState) {
    /** awake */
    WithingsSleepStateAwake = 0,
    /** light sleep */
    WithingsSleepStateLightSleep = 1,
    /** deep sleep */
    WithingsSleepStateDeepSleep = 2,
    /** REM sleep (only if model is 32) */
    WithingsSleepStateREM = 3
};

/**
 * The start datetime at which the measures has been taken.
 */
@property (readonly, nonatomic) NSDate *startdate;

/**
 * The end datetime at which the measures has been taken.
 */
@property (readonly, nonatomic) NSDate *enddate;

/**
 * The sleep state.
 */
@property (readonly, nonatomic) WithingsSleepState state;


/**
 * Output the sleep state as a string value.
 */
- (NSString*)stateToString;

@end
