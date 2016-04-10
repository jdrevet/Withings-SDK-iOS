//
// WithingsBodyMeasuresGroup.h
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

@class WithingsBodyMeasure;

/**
 * Reprensents a group of body measures catched in the same time.
 */
@interface WithingsBodyMeasuresGroup : NSObject

/**
 * Measures sources.
 */
typedef NS_ENUM(NSInteger, WithingsBodyMeasureSource) {
    /** The measuregroup has been captured by a device and is known to belong to this user (and is not ambiguous) */
    WithingsBodyMeasureSourceDevice = 0,
    /** The measuregroup has been captured by a device but may belong to other users as well as this one (it is ambiguous) */
    WithingsBodyMeasureSourceDeviceAmbiguous = 1,
    /** The measuregroup has been entered manually for this particular user */
    WithingsBodyMeasureSourceManual = 2,
    /** The measuregroup has been entered manually during user creation (and may not be accurate) */
    WithingsBodyMeasureSourceManualCreation = 4
};

/**
 * Measures categories.
 */
typedef NS_ENUM(NSInteger, WithingsBodyMeasureCategory) {
    /** Unknown */
    WithingsBodyMeasureCategoryUnknown = 0,
    /** Real measurements */
    WithingsBodyMeasureCategoryReal = 1,
    /** User objectives */
    WithingsBodyMeasureCategoryUserObjectives = 2
};

/**
 * The id of the measure group.
 */
@property (readonly, nonatomic) NSNumber *groupId;
/**
 * The way the measures has been taken.
 */
@property (readonly, nonatomic) WithingsBodyMeasureSource source;
/**
 * The datetime the measures has been taken.
 */
@property (readonly, nonatomic) NSDate *date;
/**
 * The category for the measures in the group.
 */
@property (readonly, nonatomic) WithingsBodyMeasureCategory category;
/**
 * The optionnal comments.
 */
@property (readonly, nonatomic) NSString *comment;
/**
 * The array of measures in the group.
 */
@property (readonly, nonatomic) NSArray<WithingsBodyMeasure*> *measures;

@end
