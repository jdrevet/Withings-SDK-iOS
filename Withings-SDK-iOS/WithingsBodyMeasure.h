//
// WithingsBodyMeasure.h
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
 * Reprensents a body measure with a value in S.I units (kilogram, meters, etc.) and a type.
 */
@interface WithingsBodyMeasure : NSObject

/**
 * Measure types.
 */
typedef NS_ENUM(NSInteger, WithingsBodyMeasureType) {
    /** Unknown */
    WithingsBodyMeasureTypeUnknown = 0,
    /** Weight (kg) */
    WithingsBodyMeasureTypeWeight = 1,
    /** Height (meter) */
    WithingsBodyMeasureTypeHeigth = 4,
    /** Fat Free Mass (kg) */
    WithingsBodyMeasureTypeFatFreeMass = 5,
    /** Fat Ratio (%) */
    WithingsBodyMeasureTypeFatRatio = 6,
    /** Fat Mass Weight (kg) */
    WithingsBodyMeasureTypeFatMassWeight = 8,
    /** Diastolic Blood Pressure (mmHg) */
    WithingsBodyMeasureTypeDiastolicBloodPressure = 9,
    /** Systolic Blood Pressure (mmHg) */
    WithingsBodyMeasureTypeSystolicBloodPressure = 10,
    /** Heart Pulse (bpm) */
    WithingsBodyMeasureTypeHeartPulse = 11,
    /** SPO2 (%) */
    WithingsBodyMeasureTypeSPO2 = 54
};

/**
 * The value for the measure in S.I units (kilogram, meters, etc.).
 */
@property (readonly, nonatomic) float value;

/**
 * The measure type.
 */
@property (readonly, nonatomic) WithingsBodyMeasureType type;

@end
