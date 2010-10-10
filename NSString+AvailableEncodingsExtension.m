//
//  NSString+AvailableEncodingsExtension.m
//  encodings
//
//  Created by Andre Berg on 09.10.10.
//  Copyright 2010 Berg Media. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "NSString+AvailableEncodingsExtension.h"


@implementation NSString (AvailableEncodingsExtension)

+ (NSArray *) allAvailableEncodings {
    
    NSMutableArray * array = [[NSMutableArray array] retain];
    const NSStringEncoding * encoding = [NSString availableStringEncodings];

    while (*encoding) {
        NSAutoreleasePool * tmpPool = [[NSAutoreleasePool alloc] init];
        NSMutableArray * row = [NSMutableArray arrayWithCapacity:2];

        [row addObject:[NSString localizedNameOfStringEncoding:*encoding]];
        [row addObject:[NSNumber numberWithUnsignedInteger:*encoding]];
        encoding++;

        [array addObject:row];
        [tmpPool drain];
    }

    return [array autorelease];
}

- (NSUInteger) numberFromLocalizedStringEncodingName:(NSString *)aName {
    
    NSArray * encodings = [[NSString allAvailableEncodings] retain];
    NSUInteger searchedNumber = 0;

    for (NSArray * encPair in encodings) {
        if ([[encPair objectAtIndex:0] isEqualTo:aName]) {
            searchedNumber = [[encPair objectAtIndex:1] intValue];
        }
    }

    [encodings release];
    return searchedNumber;
}

@end
