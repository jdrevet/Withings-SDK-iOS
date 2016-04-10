//
// WithingsActivity.h
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

/**
 * Reprensents the activity of the user for a day.
 */
@interface WithingsActivity : NSObject

/**
 * The date at which the measures has been taken.
 */
@property (readonly, nonatomic) NSDate *date;

/**
 * The timezone for the date.
 */
@property (readonly, nonatomic) NSString *timezone;

/**
 * The number of steps for the day.
 */
@property (readonly, nonatomic) NSInteger steps;

/**
 * The distance travelled for the day (in meters).
 */
@property (readonly, nonatomic) float distance;

/**
 * The active calories burned in the day (in kcal).
 */
@property (readonly, nonatomic) float calories;

/**
 * The total calories burned in the day (in kcal).
 */
@property (readonly, nonatomic) float totalCalories;

/**
 * The elevation climbed during the day (in meters).
 */
@property (readonly, nonatomic) float elevation;

/**
 * The duration of soft activities (in seconds).
 */
@property (readonly, nonatomic) NSInteger soft;

/**
 * The duration of moderate activities (in seconds).
 */
@property (readonly, nonatomic) NSInteger moderate;

/**
 * The duration of intense activities (in seconds).
 */
@property (readonly, nonatomic) NSInteger intense;


@end
