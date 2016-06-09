//
//  WithingsSleepMeasure+Mapping.m
//  Withings-SDK-iOS
//
//  Created by Robert Turrall on 09/06/16.
//  Copyright © 2016 robertturrall. All rights reserved.
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

#import "WithingsSleepMeasure+Mapping.h"
#import <DCKeyValueObjectMapping/DCKeyValueObjectMapping.h>
#import <DCKeyValueObjectMapping/DCParserConfiguration.h>
#import <DCKeyValueObjectMapping/DCObjectMapping.h>

@implementation WithingsSleepMeasure (Mapping)


+ (WithingsSleepMeasure*)sleepMeasureFromJson:(NSDictionary*)sleepJson
{
    WithingsSleepMeasure *sleep = [[WithingsSleepMeasure sleepMapper] parseDictionary:sleepJson];
    return sleep;
}

+ (NSArray<WithingsSleepMeasure*> *)sleepMeasuresFromJson:(NSArray*)sleepArrayJson
{
    NSArray<WithingsSleepMeasure*> *sleepMeasures = [[WithingsSleepMeasure sleepMapper] parseArray:sleepArrayJson];
    return sleepMeasures;
}

+ (DCKeyValueObjectMapping*)sleepMapper
{
    DCParserConfiguration *config = [DCParserConfiguration configuration];
//    config.datePattern = @"yyyy-MM-dd HH.mm.ss";
    
    DCKeyValueObjectMapping *mapper = [DCKeyValueObjectMapping mapperForClass:[WithingsSleepMeasure class] andConfiguration:config];
    return mapper;
}



@end
