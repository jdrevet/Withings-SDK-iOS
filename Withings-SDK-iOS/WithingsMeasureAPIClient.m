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

#import "WithingsMeasureAPIClient.h"
#import <OAuthSwift/OAuthSwift-Swift.h>
#import <DCKeyValueObjectMapping/DCKeyValueObjectMapping.h>
#import <SSKeychain/SSKeychain.h>
#import "WithingsActivity+Mapping.h"
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
- (NSDictionary<NSString*, id>*)parametersWithYMDFormat;
@end


@implementation WithingsMeasureAPIClient

- (instancetype)initWithConsumerKey:(NSString*)consumerKey consumerSecret:(NSString*)consumerSecret
{
    NSAssert(consumerKey && consumerSecret, @"Consumer key and consumer secret cannot be null");
    self = [super init];
    if (self) {
        _oauthClient = [[OAuthSwiftClient alloc] initWithConsumerKey:consumerKey consumerSecret:consumerSecret];
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
    NSData *credentialData = [SSKeychain passwordDataForService:KEY_CHAIN_SERVICE_ID account:userId];
    OAuthSwiftCredential *credential = (OAuthSwiftCredential*)[NSKeyedUnarchiver unarchiveObjectWithData:credentialData];
    if(!credential || !credential.oauth_token || ! credential.oauth_token_secret) {
        failure([WithingsError errorWithCode:WithingsErrorNoUserAuthorization message:[NSString stringWithFormat:@"Authorization cannot be found for user %@", userId]]);
        return;
    }
    
    //Update the client credentials with the user's credentials
    _oauthClient.credential.oauth_token = credential.oauth_token;
    _oauthClient.credential.oauth_token_secret = credential.oauth_token_secret;
    
    //Add action and userid parameters to the request parameters
    NSMutableDictionary<NSString*, id> *requestParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    requestParameters[@"action"] = action;
    requestParameters[@"userid"] = userId;
    
    //Send the request
    NSURL *url = [[NSURL URLWithString:WITHINGS_API_BASE_URL] URLByAppendingPathComponent:path];
    [_oauthClient get:url.absoluteString parameters:requestParameters headers:nil success:^(NSData *data, NSHTTPURLResponse *response) {
        NSError *error = nil;
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if(!error && jsonResponse) {
            NSInteger status = [jsonResponse[@"status"] integerValue];
            if(status == 0) {
                success(jsonResponse[@"body"]);
            }
            else {
                failure([WithingsError serverErrorWithCode:(WithingsServerErrorCode)status message:jsonResponse[@"error"]]);
            }
        }
        else {
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

- (NSDictionary<NSString*, id>*)parametersWithYMDFormat
{
    NSDate *startDate = _startDate ? _startDate : [NSDate dateWithTimeIntervalSince1970:0];
    NSDate *endDate = _endDate ? _endDate : [NSDate date];
    return @{@"startdateymd" : [ymdDateFormatter() stringFromDate:startDate],
             @"enddateymd" : [ymdDateFormatter() stringFromDate:endDate]};
}

@end
