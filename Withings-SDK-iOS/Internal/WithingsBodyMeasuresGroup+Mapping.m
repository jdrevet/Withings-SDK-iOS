//
// WithingsBodyMeasuresGroup+Mapping.m
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

#import "WithingsBodyMeasuresGroup+Mapping.h"
#import <DCKeyValueObjectMapping/DCKeyValueObjectMapping.h>
#import <DCKeyValueObjectMapping/DCParserConfiguration.h>
#import <DCKeyValueObjectMapping/DCObjectMapping.h>
#import <DCKeyValueObjectMapping/DCArrayMapping.h>
#import "WithingsBodyMeasure.h"

@implementation WithingsBodyMeasuresGroup (Mapping)

+ (NSArray<WithingsBodyMeasuresGroup*>*)measuresGroupsFromJson:(NSArray*)measuresGroupsArrayJson
{
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    DCObjectMapping *groupIdMapper = [DCObjectMapping mapKeyPath:@"grpid" toAttribute:@"groupId" onClass:[WithingsBodyMeasuresGroup class]];
    [config addObjectMapping:groupIdMapper];
    DCObjectMapping *sourceMapper = [DCObjectMapping mapKeyPath:@"attrib" toAttribute:@"source" onClass:[WithingsBodyMeasuresGroup class]];
    [config addObjectMapping:sourceMapper];

    DCArrayMapping *measuresArrayMapper = [DCArrayMapping mapperForClassElements:[WithingsBodyMeasure class] forAttribute:@"measures" onClass:[WithingsBodyMeasuresGroup class]];
    [config addArrayMapper:measuresArrayMapper];
    
    DCKeyValueObjectMapping *mapper = [DCKeyValueObjectMapping mapperForClass:[WithingsBodyMeasuresGroup class] andConfiguration:config];
    return [mapper parseArray:measuresGroupsArrayJson];
}


@end
