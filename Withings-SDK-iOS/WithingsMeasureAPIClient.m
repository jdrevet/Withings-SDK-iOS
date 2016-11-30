//
// WithingsMeasureAPIClient.m
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

#import "WithingsMeasureAPIClient.h"
#import <OAuthSwift/OAuthSwift-Swift.h>
#import <DCKeyValueObjectMapping/DCKeyValueObjectMapping.h>
#import <SAMKeychain/SAMKeychain.h>
#import "WithingsActivity+Mapping.h"
#import "WithingsSleepMeasure+Mapping.h"
#import "WithingsBodyMeasuresGroup+Mapping.h"
#import "WithingsError.h"

static NSString * const WITHINGS_API_BASE_URL = @"https://wbsapi.withings.net";
static NSString * const KEY_CHAIN_SERVICE_ID = @"withings.keychain.users";
static NSDateFormatter *ymdDateFormatter()
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    return dateFormatter;
}

@interface WithingsMeasureAPIClient ()
@property (strong, nonatomic) OAuthSwiftClient *oauthClient;
@end

@interface MeasuresDateRange ()
- (NSDictionary<NSString*, id>*)parameters;
- (NSDictionary<NSString*, id>*)parametersAt12Noon;
- (NSDictionary<NSString*, id>*)parametersWithYMDFormat;
@end


@implementation WithingsMeasureAPIClient

- (instancetype)initWithConsumerKey:(NSString*)consumerKey consumerSecret:(NSString*)consumerSecret
{
    NSAssert(consumerKey && consumerSecret, @"Consumer key and consumer secret cannot be null");
    self = [super init];
    if (self) {
        OAuthSwiftCredential *credential = [[OAuthSwiftCredential alloc] initWithConsumerKey:consumerKey consumerSecret:consumerSecret];
        _oauthClient = [[OAuthSwiftClient alloc] initWithCredential:credential];
        _oauthClient.paramsLocation = ParamsLocationRequestURIQuery;
    }
    return self;
}


#pragma mark - Activity measures

- (void)getActivityMeasuresForUser:(NSString*)userId atDate:(NSDate*)activityDate success:(void(^)(WithingsActivity *activityMeasures))success failure:(WithingsClientFailure)failure
{
    NSDate *checkedActivityDate = activityDate ? activityDate : [NSDate date];
    [self sendRequestWithPath:@"v2/measure" action:@"getactivity" parameters:@{@"date" : [ymdDateFormatter() stringFromDate:checkedActivityDate]} user:userId success:^(NSDictionary *body) {
        //Try to parse the result
        WithingsActivity *activity = nil;
        if(body.count > 0) {
            activity = [WithingsActivity activityFromJson:body];
        }
        success(activity);
     } failure:^(WithingsError *error) {
         failure(error);
     }];
}

- (void)getActivitiesMeasuresForUser:(NSString*)userId success:(void(^)(NSArray<WithingsActivity*> *activitiesMeasures))success failure:(WithingsClientFailure)failure
{
    [self getActivitiesMeasuresForUser:userId inDateRange:nil success:success failure:failure];
}

- (void)getActivitiesMeasuresForUser:(NSString*)userId inDateRange:(MeasuresDateRange*)dateRange success:(void(^)(NSArray<WithingsActivity*> *activitiesMeasures))success failure:(WithingsClientFailure)failure
{
    NSDictionary<NSString*,id> *parameters = dateRange ? [dateRange parametersWithYMDFormat] : [[[MeasuresDateRange alloc] init] parametersWithYMDFormat];
    [self sendRequestWithPath:@"v2/measure" action:@"getactivity" parameters:parameters user:userId success:^(NSDictionary *body){
        NSArray *activitiesArrayJson = body[@"activities"];
        NSArray<WithingsActivity*> *activities = [WithingsActivity activitiesFromJson:activitiesArrayJson];
        success(activities);
    } failure:^(WithingsError *error) {
        failure(error);
    }];
}

#pragma mark - Sleep measures 
#warning TODO: retreive overall body node with "model" - requires creation of a top level WithingsSleepMeasuresGroup class or similar

//https://wbsapi.withings.net/v2/sleep?action=get&userid=29&startdate=1387234800&enddate=1387258800

- (void)getSleepMeasuresForUser:(NSString*)userId inDateRange:(MeasuresDateRange*)dateRange success:(void(^)(NSArray <WithingsSleepMeasure *> *sleepMeasures))success failure:(WithingsClientFailure)failure {
    
    NSDictionary<NSString*,id> *parameters = dateRange ? [dateRange parametersAt12Noon] : [[[MeasuresDateRange alloc] init] parametersAt12Noon];
    
    NSLog(@" - %s - date range - %@", __PRETTY_FUNCTION__, parameters );
    
    [self sendRequestWithPath:@"v2/sleep" action:@"get" parameters:parameters user:userId success:^(NSDictionary *body) {
        
        NSArray *sleepArrayJson = body[@"series"];
        NSArray<WithingsSleepMeasure*> *sleepArray = [WithingsSleepMeasure sleepMeasuresFromJson:sleepArrayJson];
        success(sleepArray);
    } failure:^(WithingsError *error) {
        failure(error);
    }];
}

#pragma mark - Body measures

- (void)getBodyMeasuresForUser:(NSString*)userId success:(WithingsClientBodyMeasuresSuccess)success failure:(WithingsClientFailure)failure
{
    [self getBodyMeasuresForUser:userId limit:-1 offset:-1 success:success failure:failure];
}

- (void)getBodyMeasuresForUser:(NSString*)userId limit:(NSInteger)limit offset:(NSInteger)offset success:(WithingsClientBodyMeasuresSuccess)success failure:(WithingsClientFailure)failure
{
    [self getBodyMeasuresForUser:userId measureType:WithingsBodyMeasureTypeUnknown measureCategory:WithingsBodyMeasureCategoryUnknown limit:limit offset:offset success:success failure:failure];
}
- (void)getBodyMeasuresForUser:(NSString*)userId measureType:(WithingsBodyMeasureType)measureType measureCategory:(WithingsBodyMeasureCategory)measureCategory limit:(NSInteger)limit offset:(NSInteger)offset success:(WithingsClientBodyMeasuresSuccess)success failure:(WithingsClientFailure)failure
{
    NSDictionary<NSString*,id> *parameters = [self bodyMeasuresParametersWithmeasureType:measureType measureCategory:measureCategory limit:limit offset:offset otherParameters:nil];
    [self getBodyMeasuresForUser:userId parameters:parameters success:success failure:failure];
}

- (void)getBodyMeasuresForUser:(NSString*)userId sinceLastUpdate:(NSDate*)lastUpdate success:(WithingsClientBodyMeasuresSuccess)success failure:(WithingsClientFailure)failure
{
    [self getBodyMeasuresForUser:userId sinceLastUpdate:lastUpdate limit:-1 offset:-1 success:success failure:failure];
}
- (void)getBodyMeasuresForUser:(NSString*)userId sinceLastUpdate:(NSDate*)lastUpdate limit:(NSInteger)limit offset:(NSInteger)offset success:(WithingsClientBodyMeasuresSuccess)success failure:(WithingsClientFailure)failure
{
    [self getBodyMeasuresForUser:userId sinceLastUpdate:lastUpdate measureType:WithingsBodyMeasureTypeUnknown measureCategory:WithingsBodyMeasureCategoryUnknown limit:limit offset:offset success:success failure:failure];
}
- (void)getBodyMeasuresForUser:(NSString*)userId sinceLastUpdate:(NSDate*)lastUpdate measureType:(WithingsBodyMeasureType)measureType measureCategory:(WithingsBodyMeasureCategory)measureCategory limit:(NSInteger)limit offset:(NSInteger)offset success:(WithingsClientBodyMeasuresSuccess)success failure:(WithingsClientFailure)failure
{
    NSDictionary<NSString*,id> *lastUpdateParameters = lastUpdate ? (@{@"lastupdate" : @([lastUpdate timeIntervalSince1970])}) : nil;
    NSDictionary<NSString*,id> *parameters = [self bodyMeasuresParametersWithmeasureType:measureType measureCategory:measureCategory limit:limit offset:offset otherParameters:lastUpdateParameters];
    [self getBodyMeasuresForUser:userId parameters:parameters success:success failure:failure];
}

- (void)getBodyMeasuresForUser:(NSString*)userId inDateRange:(MeasuresDateRange*)dateRange success:(WithingsClientBodyMeasuresSuccess)success failure:(WithingsClientFailure)failure
{
    [self getBodyMeasuresForUser:userId inDateRange:dateRange limit:-1 offset:-1 success:success failure:failure];
}
- (void)getBodyMeasuresForUser:(NSString*)userId inDateRange:(MeasuresDateRange*)dateRange limit:(NSInteger)limit offset:(NSInteger)offset success:(WithingsClientBodyMeasuresSuccess)success failure:(WithingsClientFailure)failure
{
    [self getBodyMeasuresForUser:userId inDateRange:dateRange measureType:WithingsBodyMeasureTypeUnknown measureCategory:WithingsBodyMeasureCategoryUnknown limit:limit offset:offset success:success failure:failure];
}
- (void)getBodyMeasuresForUser:(NSString*)userId inDateRange:(MeasuresDateRange*)dateRange measureType:(WithingsBodyMeasureType)measureType measureCategory:(WithingsBodyMeasureCategory)measureCategory limit:(NSInteger)limit offset:(NSInteger)offset success:(WithingsClientBodyMeasuresSuccess)success failure:(WithingsClientFailure)failure
{
    NSDictionary<NSString*,id> *dateRangeParameters = dateRange ? [dateRange parameters] : [[[MeasuresDateRange alloc] init] parameters];
    NSDictionary<NSString*,id> *parameters = [self bodyMeasuresParametersWithmeasureType:measureType measureCategory:measureCategory limit:limit offset:offset otherParameters:dateRangeParameters];
    [self getBodyMeasuresForUser:userId parameters:parameters success:success failure:failure];
}

- (void)getBodyMeasuresForUser:(NSString*)userId parameters:(NSDictionary<NSString*,id>*)parameters success:(WithingsClientBodyMeasuresSuccess)success failure:(WithingsClientFailure)failure
{
    [self sendRequestWithPath:@"measure" action:@"getmeas" parameters:parameters user:userId success:^(NSDictionary *body) {
        NSArray *measuresGroupsArrayJson = body[@"measuregrps"];
        NSArray<WithingsBodyMeasuresGroup*> *measuresGroups = [WithingsBodyMeasuresGroup measuresGroupsFromJson:measuresGroupsArrayJson];
        NSDate *updateTime = [NSDate dateWithTimeIntervalSince1970:[body[@"updatetime"] longValue]];
        success(updateTime, body[@"timezone"], [body[@"more"] integerValue], measuresGroups);
    } failure:^(WithingsError *error) {
        failure(error);
    }];
}


#pragma mark - Utils

- (void)sendRequestWithPath:(NSString*)path action:(NSString *)action parameters:(NSDictionary<NSString*,id>*)parameters user:(NSString*)userId success:(void(^)(NSDictionary *body))success failure:(WithingsClientFailure)failure
{
    //Retrieve the user's credentials
    NSData *credentialData = [SAMKeychain passwordDataForService:KEY_CHAIN_SERVICE_ID account:userId];
    OAuthSwiftCredential *credential = (OAuthSwiftCredential*)[NSKeyedUnarchiver unarchiveObjectWithData:credentialData];
    if(!credential || !credential.oauthToken || ! credential.oauthTokenSecret) {
        failure([WithingsError errorWithCode:WithingsErrorNoUserAuthorization message:[NSString stringWithFormat:@"Authorization cannot be found for user %@", userId]]);
        return;
    }
    
    //Update the client credentials with the user's credentials
    _oauthClient.credential.oauthToken = credential.oauthToken;
    _oauthClient.credential.oauthTokenSecret = credential.oauthTokenSecret;
    
    //Add action and userid parameters to the request parameters
    NSMutableDictionary<NSString*, id> *requestParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    requestParameters[@"action"] = action;
    requestParameters[@"userid"] = userId;
    
    //Send the request
    NSURL *url = [[NSURL URLWithString:WITHINGS_API_BASE_URL] URLByAppendingPathComponent:path];
    [_oauthClient get:url.absoluteString parameters:requestParameters headers:nil success:^(OAuthSwiftResponse * response) {
        //Check HTTP status code
        if(response.response.statusCode != 200) {
            failure([WithingsError errorWithCode:WithingsErrorResponseParsing message:[NSString stringWithFormat:@"HTTP error received from the server: %li", (long)response.response.statusCode]]);
            return;
        }
        
        //Try to parse the response body
        NSError *error = nil;
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:response.data options:kNilOptions error:&error];
        if(!error && jsonResponse) {
            NSInteger status = [jsonResponse[@"status"] integerValue];
            if(status == 0) {
                //Success
                success(jsonResponse[@"body"]);
            }
            else {
                //Error message from server
                failure([WithingsError serverErrorWithCode:(WithingsServerErrorCode)status message:jsonResponse[@"error"]]);
            }
        }
        else {
            //Error while parsing the response body
            failure([WithingsError errorWithCode:WithingsErrorResponseParsing message:@"The response received from the server is not a valid JSON"]);
        }
    } failure:^(NSError *error) {
        failure([WithingsError errorWithCode:WithingsErrorHTTP userInfo:error.userInfo]);
    }];
}

- (NSDictionary<NSString*,id>*)bodyMeasuresParametersWithmeasureType:(WithingsBodyMeasureType)measureType measureCategory:(WithingsBodyMeasureCategory)measureCategory limit:(NSInteger)limit offset:(NSInteger)offset otherParameters:(NSDictionary<NSString*,id>*)otherParameters
{
    NSMutableDictionary<NSString*,id> *parameters = [NSMutableDictionary dictionaryWithDictionary:otherParameters];
    if (measureType != WithingsBodyMeasureTypeUnknown)
        parameters[@"meastype"] = @(measureType);
    if(measureCategory != WithingsBodyMeasureCategoryUnknown)
        parameters[@"category "] = @(measureCategory);
    if(limit > 0)
        parameters[@"limit"] = @(limit);
    if(offset > 0)
        parameters[@"offset"] = @(offset);
    
    return parameters;
}

@end


@implementation MeasuresDateRange

+ (MeasuresDateRange*)dateRangeBetweenStartDate:(NSDate*)startDate andEndDate:(NSDate*)endDate
{
    MeasuresDateRange *dateRange = [[MeasuresDateRange alloc] init];
    dateRange.startDate = startDate;
    dateRange.endDate = endDate;
    return dateRange;
}

- (NSDictionary<NSString*, id>*)parameters
{
    NSDate *startDate = _startDate ? _startDate : [NSDate dateWithTimeIntervalSince1970:0];
    NSDate *endDate = _endDate ? _endDate : [NSDate date];
    return @{@"startdate" : @([startDate timeIntervalSince1970]),
                  @"enddate" : @([endDate timeIntervalSince1970])};
}

- (NSDictionary<NSString*, id>*)parametersAt12Noon {
    
    NSDate *startDate = _startDate ? _startDate : [NSDate dateWithTimeIntervalSince1970:0];
    NSDate *endDate = _endDate ? _endDate : [NSDate date];

    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *start12Noon = [calendar dateBySettingHour:12 minute:0 second:0 ofDate:startDate options:0];
    NSDate *end12Noon = [calendar dateBySettingHour:12 minute:0 second:0 ofDate:endDate options:0];
    
    double difStart = [startDate timeIntervalSince1970] - [start12Noon timeIntervalSince1970];
    double difEnd = [endDate timeIntervalSince1970] - [end12Noon timeIntervalSince1970];
    double startTimeStampWithReference12Noon = [startDate timeIntervalSince1970] - difStart ;
    double endTimeStampWithReference12Noon = [endDate timeIntervalSince1970] - difEnd ;
    
    return @{@"startdate" : @(startTimeStampWithReference12Noon),//@([startDate timeIntervalSince1970]),
             @"enddate" : @(endTimeStampWithReference12Noon)};//[endDate timeIntervalSince1970])};
}

- (NSDictionary<NSString*, id>*)parametersWithYMDFormat
{
    NSDate *startDate = _startDate ? _startDate : [NSDate dateWithTimeIntervalSince1970:0];
    NSDate *endDate = _endDate ? _endDate : [NSDate date];
    return @{@"startdateymd" : [ymdDateFormatter() stringFromDate:startDate],
             @"enddateymd" : [ymdDateFormatter() stringFromDate:endDate]};
}

@end
