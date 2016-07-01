//
// WithingsMeasureAPIClient.h
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
//
// June 2016 addition of WithingsSleepMeasure sleep measures retrieval and mapping
//
// copyright (c) 2016 robertturrall
//
//
#import <Foundation/Foundation.h>

#import "WithingsBodyMeasuresGroup.h"
#import "WithingsBodyMeasure.h"

@class WithingsActivity;
@class WithingsSleepMeasure;
@class MeasuresDateRange;
@class WithingsError;

/**
 * Client to request the Withings API related to measures.
 * You can manage one or more instance of clients or simply use the instance of client held by the WithingsAPI singleton.
 * Note that the user must give you an autorization to access his data. To request the autorization, use the method requestAccessAuthorizationWithCallbackScheme of the WithingsAPI singleton.
 */
@interface WithingsMeasureAPIClient : NSObject

/**
 * Inits a client with your application keys
 * To get your keys, register to [Withings](https://account.withings.com/connectionuser/account_login?r=http%3A%2F%2Foauth.withings.com%2Fpartner%2Fadd).
 *
 * @param consumerKey Your consumer key
 * @param consumerSecret Your consumer secret
 * @return The client initialized with the provided keys
 */
- (instancetype)initWithConsumerKey:(NSString*)consumerKey consumerSecret:(NSString*)consumerSecret;

/**
 * A block object to be executed when a client request has failed.
 *
 * @param error The encountered error
 */
typedef void(^WithingsClientFailure)(WithingsError *error);


#pragma mark - Activity measures

/**
 * Gets the activity measures for the given date.
 * Note that the service is limited to 60 calls per minute.
 * 
 * @param userId The Withings user id returned during authorization process
 * @param activityDate The date of the activity measures
 * @param success A block object to be executed when the activity measures for the date has been sucessfully fetched. If no activity has been found for this date, the block will give nil
 * @param failure A block object to be executed when the request has failed
 */
- (void)getActivityMeasuresForUser:(NSString*)userId atDate:(NSDate*)activityDate success:(void(^)(WithingsActivity *activityMeasures))success failure:(WithingsClientFailure)failure;
/**
 * Gets the measures for the activities recorded in the given date range.
 * Note that the service is limited to 60 calls per minute.
 *
 * @param userId The Withings user id returned during authorization process
 * @param dateRange The date range in which the measures sould be returned
 * @param success A block object to be executed when the activities measures in the range has been sucessfully fetched. If no activity has been found in this range, the block will give an empty array
 * @param failure A block object to be executed when the request has failed
 */
- (void)getActivitiesMeasuresForUser:(NSString*)userId inDateRange:(MeasuresDateRange*)dateRange success:(void(^)(NSArray<WithingsActivity*> *activitiesMeasures))success failure:(WithingsClientFailure)failure;
/**
 * Gets all the activities measures of the user.
 * Note that the service is limited to 60 calls per minute.
 *
 * @param userId The Withings user id returned during authorization process
 * @param success A block object to be executed when the activity measures has been sucessfully fetched. If no activity has been found, the block will give an empty array
 * @param failure A block object to be executed when the request has failed
 */
- (void)getActivitiesMeasuresForUser:(NSString*)userId success:(void(^)(NSArray<WithingsActivity*> *activitiesMeasures))success failure:(WithingsClientFailure)failure;

#pragma mark - Sleep measures
/**
 * Gets the measures for the activities recorded in the given date range.
 * Note that only 7 days' worth of measures can be retrieved from the API at a time. To retrieve more, send further requests.
 *
 * @param userId The Withings user id returned during authorization process
 * @param dateRange The date range in which the measures sould be returned
 * @param success A block object to be executed when the activities measures in the range has been sucessfully fetched. If no activity has been found in this range, the block will give an empty array
 * @param failure A block object to be executed when the request has failed
 */
- (void)getSleepMeasuresForUser:(NSString*)userId inDateRange:(MeasuresDateRange*)dateRange success:(void(^)(NSArray <WithingsSleepMeasure*> *sleepMeasures))success failure:(WithingsClientFailure)failure;

#pragma mark - Body measures

/**
 * A block object to be executed when body measures have been successfully fetched.
 *
 * @param updateTime The server time at which the answer was generated
 * @param timezone The user timezone
 * @param more When using limit, or when the answer is too big, provides the number of measure groups left to be returned to provide the full data set
 * @param measuresGroups An array with the fetched measures groups. If no activity has been found, the array is empty
 */
typedef void(^WithingsClientBodyMeasuresSuccess)(NSDate *updateTime, NSString *timezone, NSInteger more, NSArray<WithingsBodyMeasuresGroup*> *measuresGroups);

/**
 * Gets all the body measures of the user.
 *
 * @param userId The Withings user id returned during authorization process
 * @param success A block object to be executed when body measures have been successfully fetched
 * @param failure A block object to be executed when the request has failed
 */
- (void)getBodyMeasuresForUser:(NSString*)userId success:(WithingsClientBodyMeasuresSuccess)success failure:(WithingsClientFailure)failure;
/**
 * Gets the body measures of the user with the given pagination.
 *
 * @param userId The Withings user id returned during authorization process
 * @param limit The maximum number of measure groups to return. Results are always sorted from the most recent one first to the oldest one (ie limit=1 returns the latest measure group)
 * @param offset Skip the "offset" most recent measure groups. Can be combined with "limit" parameter to retrieve ranges of a large data set
 * @param success A block object to be executed when body measures have been successfully fetched
 * @param failure A block object to be executed when the request has failed
 */
- (void)getBodyMeasuresForUser:(NSString*)userId limit:(NSInteger)limit offset:(NSInteger)offset success:(WithingsClientBodyMeasuresSuccess)success failure:(WithingsClientFailure)failure;
/**
 * Gets the body measures of the user with the given filters and pagination.
 *
 * @param userId The Withings user id returned during authorization process
 * @param measureType The measure type filter. To avoid category filtering, use WithingsBodyMeasureTypeUnknown
 * @param measureCategory The measures category filter. To avoid category filtering, use WithingsBodyMeasureCategoryUnknown
 * @param limit The maximum number of measure groups to return. Results are always sorted from the most recent one first to the oldest one (ie limit=1 returns the latest measure group)
 * @param offset Skip the "offset" most recent measure groups. Can be combined with "limit" parameter to retrieve ranges of a large data set
 * @param success A block object to be executed when body measures have been successfully fetched
 * @param failure A block object to be executed when the request has failed
 */
- (void)getBodyMeasuresForUser:(NSString*)userId measureType:(WithingsBodyMeasureType)measureType measureCategory:(WithingsBodyMeasureCategory)measureCategory limit:(NSInteger)limit offset:(NSInteger)offset success:(WithingsClientBodyMeasuresSuccess)success failure:(WithingsClientFailure)failure;

/**
 * Gets the body measures of the user recorded since the given update date.
 *
 * @param userId The Withings user id returned during authorization process
 * @param lastUpdate The date from which the measures should be returned
 * @param success A block object to be executed when body measures have been successfully fetched
 * @param failure A block object to be executed when the request has failed
 */
- (void)getBodyMeasuresForUser:(NSString*)userId sinceLastUpdate:(NSDate*)lastUpdate success:(WithingsClientBodyMeasuresSuccess)success failure:(WithingsClientFailure)failure;
/**
 * Gets the body measures of the user recorded since the given update date with the given pagination.
 *
 * @param userId The Withings user id returned during authorization process
 * @param lastUpdate The date from which the measures should be returned
 * @param limit The maximum number of measure groups to return. Results are always sorted from the most recent one first to the oldest one (ie limit=1 returns the latest measure group)
 * @param offset Skip the "offset" most recent measure groups. Can be combined with "limit" parameter to retrieve ranges of a large data set
 * @param success A block object to be executed when body measures have been successfully fetched
 * @param failure A block object to be executed when the request has failed
 */
- (void)getBodyMeasuresForUser:(NSString*)userId sinceLastUpdate:(NSDate*)lastUpdate limit:(NSInteger)limit offset:(NSInteger)offset success:(WithingsClientBodyMeasuresSuccess)success failure:(WithingsClientFailure)failure;
/**
 * Gets the body measures of the user recorded since the given update date with the given filters and pagination.
 *
 * @param userId The Withings user id returned during authorization process
 * @param lastUpdate The date from which the measures should be returned
 * @param measureType The measure type filter. To avoid category filtering, use WithingsBodyMeasureTypeUnknown
 * @param measureCategory The measures category filter. To avoid category filtering, use WithingsBodyMeasureCategoryUnknown
 * @param limit The maximum number of measure groups to return. Results are always sorted from the most recent one first to the oldest one (ie limit=1 returns the latest measure group)
 * @param offset Skip the "offset" most recent measure groups. Can be combined with "limit" parameter to retrieve ranges of a large data set
 * @param success A block object to be executed when body measures have been successfully fetched
 * @param failure A block object to be executed when the request has failed
 */
- (void)getBodyMeasuresForUser:(NSString*)userId sinceLastUpdate:(NSDate*)lastUpdate measureType:(WithingsBodyMeasureType)measureType measureCategory:(WithingsBodyMeasureCategory)measureCategory limit:(NSInteger)limit offset:(NSInteger)offset success:(WithingsClientBodyMeasuresSuccess)success failure:(WithingsClientFailure)failure;

/**
 * Gets the body measures of the user recorded in the given date range.
 *
 * @param userId The Withings user id returned during authorization process
 * @param dateRange The date range in which the measures sould be returned
 * @param success A block object to be executed when body measures have been successfully fetched
 * @param failure A block object to be executed when the request has failed
 */
- (void)getBodyMeasuresForUser:(NSString*)userId inDateRange:(MeasuresDateRange*)dateRange success:(WithingsClientBodyMeasuresSuccess)success failure:(WithingsClientFailure)failure;
/**
 * Gets the body measures of the user recorded in the given date range with the given pagination.
 *
 * @param userId The Withings user id returned during authorization process
 * @param dateRange The date range in which the measures sould be returned
 * @param limit The maximum number of measure groups to return. Results are always sorted from the most recent one first to the oldest one (ie limit=1 returns the latest measure group)
 * @param offset Skip the "offset" most recent measure groups. Can be combined with "limit" parameter to retrieve ranges of a large data set
 * @param success A block object to be executed when body measures have been successfully fetched
 * @param failure A block object to be executed when the request has failed
 */
- (void)getBodyMeasuresForUser:(NSString*)userId inDateRange:(MeasuresDateRange*)dateRange limit:(NSInteger)limit offset:(NSInteger)offset success:(WithingsClientBodyMeasuresSuccess)success failure:(WithingsClientFailure)failure;
/**
 * Gets the body measures of the user recorded in the given date range with the given filters and pagination.
 *
 * @param userId The Withings user id returned during authorization process
 * @param dateRange The date range in which the measures sould be returned
 * @param measureType The measure type filter. To avoid category filtering, use WithingsBodyMeasureTypeUnknown
 * @param measureCategory The measures category filter. To avoid category filtering, use WithingsBodyMeasureCategoryUnknown
 * @param limit The maximum number of measure groups to return. Results are always sorted from the most recent one first to the oldest one (ie limit=1 returns the latest measure group)
 * @param offset Skip the "offset" most recent measure groups. Can be combined with "limit" parameter to retrieve ranges of a large data set
 * @param success A block object to be executed when body measures have been successfully fetched
 * @param failure A block object to be executed when the request has failed
 */
- (void)getBodyMeasuresForUser:(NSString*)userId inDateRange:(MeasuresDateRange*)dateRange measureType:(WithingsBodyMeasureType)measureType measureCategory:(WithingsBodyMeasureCategory)measureCategory limit:(NSInteger)limit offset:(NSInteger)offset success:(WithingsClientBodyMeasuresSuccess)success failure:(WithingsClientFailure)failure;

@end


/**
 * Represents a range between two dates to get measures.
 */
@interface MeasuresDateRange : NSObject

/**
 * Start date for the measures (inclusive).
 */
@property (strong, nonatomic) NSDate *startDate;
/**
 * End date for the measures (inclusive).
 */
@property (strong, nonatomic) NSDate *endDate;

/**
 * Creates and returns a date range between the given dates
 *
 * @param startDate The start date for the measures (inclusive)
 * @param endDate The end date for the measures (inclusive)
 * @return The date range initialized with the given dates 
 */
+ (MeasuresDateRange*)dateRangeBetweenStartDate:(NSDate*)startDate andEndDate:(NSDate*)endDate;

@end
