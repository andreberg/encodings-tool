//
//  main.m
//  encodings
//
//  Created by André Berg on 2010-09-21.
//  Copyright Berg Media 2010. All rights reserved.
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

#import <Foundation/Foundation.h>
#import "NSString+AvailableEncodingsExtension.h"

#include <getopt.h>
#include <stdlib.h>

#define PROG_NAME       "encodings"
#define PROG_SHORT_DESC "string output converted to arbitrary encodings"
#define PROG_BUILD_DATE "2010-10-10"
#define PROG_VERSION    PROG_NAME" v0.1 ("PROG_BUILD_DATE")"

//#define DEBUG_LEVEL (int)(getenv("NSDebugLevel"))

const int ERR_IN_ENCODINGS_LIST_GENERATION_FAILED = -1;
const int ERR_OUT_ENCODINGS_LIST_GENERATION_FAILED = -2;

const int ERR_INPUTSTR_MISSING  = 1;
const int ERR_INVALID_IN_ENCODINGS_LIST = 2;
const int ERR_INVALID_IN_ENCODINGS_PARAM = 3;
const int ERR_INVALID_IN_ENCODINGS_RANGE = 4;
const int ERR_INVALID_OUT_ENCODINGS_LIST = 5;
const int ERR_INVALID_OUT_ENCODINGS_PARAM = 6;
const int ERR_INVALID_OUT_ENCODINGS_RANGE = 7;


void logLine(NSString * msg) {
    fprintf(stdout, " \n");
    fprintf(stdout, "%s\n", [msg UTF8String]);
    fprintf(stdout, " \n");
}

void log1(NSString * msg) {
    fprintf(stdout, "%s\n", [msg UTF8String]);
    fprintf(stdout, " \n");
}

void printUsage(void) {
    const char usage[] = "\n"
    ""
    "   "PROG_NAME" -- "PROG_SHORT_DESC"\n"
    "\n"
    "   Created by André Berg on "PROG_BUILD_DATE".\n"
    "   Copyright 2010 Berg Media. All rights reserved.\n"
    "\n"
    "   USAGE: "PROG_NAME" [-V] [-h] [-v] [-q] [-l] [-i <SPEC>] [-o <SPEC>] string\n"
    "\n"
    "       "PROG_NAME" is intended as a tool for debugging string\n"
    "       encoding conversion problems or just to satisfy personal\n"
    "       curiosity of \"what would this look like in xy encoding\".\n"
    "\n"
    "       The input string is first converted to NSData instances\n"
    "       using all encodings specified by -i <SPEC>.\n"
    "       Each NSData instance is then converted to all encodings\n"
    "       specified by -o <SPEC>.\n"
    "\n"
    "       <SPEC>      Following formats are valid as specifier:\n"
    "\n"
    "                   n       a single number, e.g. 30 for Mac OS Roman Encoding\n"
    "                   n-n     a range of encodings, e.g. 1-4\n"
    "                   n,n,... a comma separated list of encodings, e.g. 1,2,5\n"
    "\n"
    "       Note: a number may also be entered in 0xnnn... hex format\n"
    "       Note 2: numbers that do not correlate to an encoding will\n"
    "               be skipped silently.\n"
    "\n"
    "\n"
    "       For valid numbers look at NSStringEncoding and CFStringEncodingExt.h.\n"
    "\n"
    "       If -i or -o is not specified a list will be populated by all\n"
    "       encodings returned from [NSString availableStringEncodings].\n"
    "\n"
    "       Warning: if both -i and -o are not specified the output can be\n"
    "       huge, as each in encoding is converted to each out encoding!\n"
    "\n"
    "\n"
    "   OPTIONS:\n"
    "       -V, --version        Display version and exit\n"
    "\n"
    "       -h, --help           Display this help and exit\n"
    "\n"
    "       -v, -verbose         Output every conversion from data to string\n"
    "                            even if the result is nil\n"
    "\n"
	"       -q, -quiet           Output only the converted string\n"
	"\n"
    "       -l, -list            List all available encodings and exit\n"
    "\n"
    "   ERROR CODES:\n"
    "\n"
    "      -1   populating the in encodings list failed\n"
    "      -2   populating the out encodings list failed\n"
    "       1   input string missing\n"
    "       2   invalid in encodings list\n"
    "       3   invalid in encoding number\n"
    "       4   invalid in encodings range\n"
    "       5   invalid out encodings list\n"
    "       6   invalid out encoding number\n"
    "       7   invalid out encodings range\n"
    "\n"
    "   DISCLAIMER:\n"
    "       This program comes with ABSOLUTELY NO WARRANTY\n"
    "       either express or implied. Use solely at your own risk!\n"
    "\n"
    "   LICENSE:\n"
    "       Licensed under the MIT license. \n"
    "       http://www.opensource.org/licenses/mit-license.html\n"
    "\n"
    "   SEE ALSO:\n"
    "       man iconv(1)";
    
    printf("%s\n", usage);
}

void printVersion(void) {
    printf("%s\n", PROG_VERSION);
}

BOOL addEncodingToStringEncodings(NSString * intstr, NSMutableArray * stringEncodings) {
    @try {
        NSAutoreleasePool * tpool = [[NSAutoreleasePool alloc] init];
        NSInteger encvalue = [intstr integerValue];
        NSString * name = [NSString localizedNameOfStringEncoding:encvalue];
        if (encvalue && name && ![name isEqualToString:@""]) {
            NSMutableArray * row = [NSMutableArray arrayWithCapacity:2];
            [row addObject:name];
            [row addObject:[NSNumber numberWithUnsignedInteger:[intstr integerValue]]];
            [stringEncodings addObject:row];
            [tpool drain];
        }
        return YES;
    }
    @catch (NSException * e) {
        fprintf(stderr, "%s Caught %s: %s", __PRETTY_FUNCTION__, [[e name] UTF8String], [[e  reason] UTF8String]);
    }
    return NO;
}

NSInteger fillWithAvailableStringEncodings(NSMutableArray * table) {
    @try {
        const NSStringEncoding * encoding = [NSString availableStringEncodings];
        
        while (*encoding) {
            NSAutoreleasePool * tmpPool = [[NSAutoreleasePool alloc] init];
            NSMutableArray * row = [NSMutableArray arrayWithCapacity:2];
            
            [row addObject:[NSString localizedNameOfStringEncoding:*encoding]];
            [row addObject:[NSNumber numberWithUnsignedInteger:*encoding]];
            encoding++;
            
            [table addObject:row];
            [tmpPool drain];
        }
        return [table count];
    }
    @catch (NSException * e) {
        fprintf(stderr, "%s Caught %s: %s", __PRETTY_FUNCTION__, [[e name] UTF8String], [[e  reason] UTF8String]);
    }
    return -1;
}

NSString * convertHexStringToIntegerString(NSString * string) {
    if ([string rangeOfString:@"0x"].location != NSNotFound) {
        const char * estr = [string UTF8String];
        long long llval;
        @try {
            if (isdigit((unsigned)estr[0]) ) {
                llval = strtoll(estr, NULL, 0);
            }
            string = [NSString stringWithFormat:@"%qi", llval];
        }
        @catch (NSException * e) {
            fprintf(stderr, "%s Caught %s: %s", __PRETTY_FUNCTION__, [[e name] UTF8String], [[e  reason] UTF8String]);
        }
    }
    return string;
}

int main (int argc, char * const argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    NSMutableArray * inStringEncodings = [NSMutableArray array];
    NSMutableArray * outStringEncodings = [NSMutableArray array];
        
    int c, verbose = 0, quiet = 0;
    BOOL in_encodings_initialized = NO;
    BOOL out_encodings_initialized = NO;
    
    while (1) {
        
        static struct option long_options[] = {
            {"help",          no_argument,       0, 'h'},
            {"version",       no_argument,       0, 'V'},
            {"verbose",       no_argument,       0, 'v'},
			{"quiet",         no_argument,       0, 'q'},
            {"list",          no_argument,       0, 'l'},
            {"inencodings",   required_argument, 0, 'i'},
			{"outencodings",  required_argument, 0, 'o'},
            {0, 0, 0, 0}
        };
        
        /* getopt_long stores the option index here. */
        int option_index = 0;
        
        c = getopt_long(argc, argv, "hVvqli:o:", long_options, &option_index);
        
        /* Detect the end of the options. */
        if (c == -1)
            break;
        
        switch (c) {
            case 'V':
                printVersion();
                exit(EXIT_SUCCESS);
                break;
            case 'h':
                printUsage();
                exit(EXIT_SUCCESS);
                break;
			case 'v':
				verbose = 1;
				break;
			case 'q':
				quiet = 1;
				break;
            case 'l':;
                int count = 0;
                NSArray * allEncodings = [NSString allAvailableEncodings];
                for (NSArray * entry in allEncodings) {
                    NSString * name = [entry objectAtIndex:0];
                    NSStringEncoding e = (NSStringEncoding) [[entry objectAtIndex:1] integerValue];
                    fprintf(stdout, "%10lu: %s\n", (unsigned long)e, [name UTF8String]);
                    count++;
                }
                fprintf(stdout, "\n%10s: %i\n", "total", count);
                exit(EXIT_SUCCESS);
                break;
            case 'i':;
                // printf("option -e with value '%s'\n", optarg);
                NSString * encodingsString = [NSString stringWithUTF8String:optarg];
                
                if ([encodingsString rangeOfString:@","].location != NSNotFound) {
                    NSArray * comps = [encodingsString componentsSeparatedByString:@","];
                    
                    for (NSString * comp in comps) {
                        if (!addEncodingToStringEncodings(convertHexStringToIntegerString(comp), inStringEncodings)) {
                            fprintf(stderr, "Error: processing the encodings list failed. (proper format: n,n,n...)\n");
                            exit(ERR_INVALID_IN_ENCODINGS_LIST);
                        }
                    }
                } else if ([encodingsString rangeOfString:@"-"].location != NSNotFound) {
                    NSArray * comps = [encodingsString componentsSeparatedByString:@"-"];
                    comps = [NSArray arrayWithObjects:[comps objectAtIndex:0], [comps objectAtIndex:1], nil];
                    
                    NSString * first = [comps objectAtIndex:0];
                    NSString * second = [comps objectAtIndex:1];
                    NSUInteger min = [convertHexStringToIntegerString(first) integerValue];
                    NSUInteger max = [convertHexStringToIntegerString(second) integerValue];
                    
                    if (!min) {
                        fprintf(stderr, "Error: start value of encodings range invalid. (format: n-n)\n");
                        exit(ERR_INVALID_IN_ENCODINGS_RANGE);
                    }
                    if (!max) {
                        fprintf(stderr, "Error: upper limit of encodings range invalid. (format: n-n)\n");
                        exit(ERR_INVALID_IN_ENCODINGS_RANGE);
                    }
                    
                    if (min>max) {
                        fprintf(stderr, "Error: start value of encodings range greater than limit value.\n");
                        exit(ERR_INVALID_IN_ENCODINGS_RANGE);
                    }
                    
                    NSUInteger i;
                    for (i = min; i<=max; i++) {
                        NSString * comp = [NSString stringWithFormat:@"%lu", i];
                        if (!addEncodingToStringEncodings(convertHexStringToIntegerString(comp), inStringEncodings)) {
                            fprintf(stderr, "Error: processing the encodings range failed. (proper format: n-n)\n");
                            exit(ERR_INVALID_IN_ENCODINGS_RANGE);
                        }
                    }
                } else {
                    if (!addEncodingToStringEncodings(convertHexStringToIntegerString(encodingsString), inStringEncodings)) {
                        fprintf(stderr, "Error: processing the encodings parameter failed.\n");
                        exit(ERR_INVALID_IN_ENCODINGS_PARAM);
                    }
                }
                
                in_encodings_initialized = YES;
                break;
                
            case 'o':
                ;
                //printf("option -o with value '%s'\n", optarg);
                NSString * outEncodingsString = [NSString stringWithUTF8String:optarg];
                
                if ([outEncodingsString rangeOfString:@","].location != NSNotFound) {
                    NSArray * comps = [outEncodingsString componentsSeparatedByString:@","];
                    
                    for (NSString * comp in comps) {
                        if (!addEncodingToStringEncodings(convertHexStringToIntegerString(comp), outStringEncodings)) {
                            fprintf(stderr, "Error: processing the out encodings list failed. (proper format: n,n,n...)\n");
                            exit(ERR_INVALID_OUT_ENCODINGS_LIST);
                        }
                    }
                } else if ([outEncodingsString rangeOfString:@"-"].location != NSNotFound) {
                    NSArray * comps = [outEncodingsString componentsSeparatedByString:@"-"];
                    comps = [NSArray arrayWithObjects:[comps objectAtIndex:0], [comps objectAtIndex:1], nil];
                    
                    NSString * first = [comps objectAtIndex:0];
                    NSString * second = [comps objectAtIndex:1];
                    NSUInteger min = [convertHexStringToIntegerString(first) integerValue];
                    NSUInteger max = [convertHexStringToIntegerString(second) integerValue];
                    
                    if (!min) {
                        fprintf(stderr, "Error: start value of out encodings range invalid. (format: n-n)\n");
                        exit(ERR_INVALID_OUT_ENCODINGS_RANGE);
                    }
                    if (!max) {
                        fprintf(stderr, "Error: upper limit of out encodings range invalid. (format: n-n)\n");
                        exit(ERR_INVALID_OUT_ENCODINGS_RANGE);
                    }
                    
                    if (min>max) {
                        fprintf(stderr, "Error: start value of out encodings range greater than limit value.\n");
                        exit(ERR_INVALID_OUT_ENCODINGS_RANGE);
                    }
                    
                    NSUInteger i;
                    for (i = min; i<=max; i++) {
                        NSString * comp = [NSString stringWithFormat:@"%lu", i];
                        if (!addEncodingToStringEncodings(convertHexStringToIntegerString(comp), outStringEncodings)) {
                            fprintf(stderr, "Error: processing the out encodings range failed. (proper format: n-n)\n");
                            exit(ERR_INVALID_OUT_ENCODINGS_RANGE);
                        }
                    }
                } else {
                    if (!addEncodingToStringEncodings(convertHexStringToIntegerString(outEncodingsString), outStringEncodings)) {
                        fprintf(stderr, "Error: processing the out encodings parameter failed.\n");
                        exit(ERR_INVALID_OUT_ENCODINGS_PARAM);
                    }
                }
                
                out_encodings_initialized = YES;
                break;
            case '?':
                printUsage();
                exit(EXIT_FAILURE);
                break;
            default:
                abort();
        }
    }
    
    // put together input string from remaining command line arguments (not options)
    NSString * string = @"";
    if (optind < argc) {
        while (optind < argc) {
            string = [string stringByAppendingFormat:@"%@ ", [NSString stringWithUTF8String:argv[optind++]]];
        }           
    } else {
        printUsage();
        exit(ERR_INPUTSTR_MISSING);
    }
    
    if (!in_encodings_initialized) {
        if (fillWithAvailableStringEncodings(inStringEncodings) <= 0) {
            fprintf(stderr, "Error: populating the encodings table failed.\n");
            exit(ERR_IN_ENCODINGS_LIST_GENERATION_FAILED); 
        }
    }
    if (!out_encodings_initialized) {
        if (fillWithAvailableStringEncodings(outStringEncodings) <= 0) {
            fprintf(stderr, "Error: populating the out encodings table failed.\n");
            exit(ERR_OUT_ENCODINGS_LIST_GENERATION_FAILED); 
        }
    }
    if (!in_encodings_initialized && !out_encodings_initialized && verbose) {
        fprintf(stdout, "Warning: -i and -o parameter missing. Output will cover strings in every encoding, all converted to every encoding!\n");
    }
    
    for (NSArray * entry in inStringEncodings) {
        
        if (quiet == 0) logLine(@"---------- Convert input to data -----------------");
        
        NSString * name = [[entry objectAtIndex:0] retain];
        NSStringEncoding enc = [[entry objectAtIndex:1] unsignedIntegerValue];
        NSData * strAsData = [string dataUsingEncoding:enc];
        
		if (quiet == 0) {
			if (strAsData) {
				 fprintf(stdout, "input string as data using encoding %s = %s\n", [name UTF8String], [[strAsData description] UTF8String]);
				//if (DEBUG_LEVEL > 0) NSLog(@"input string as data using encoding %@ = %@", name, strAsData);
			} else {
				 fprintf(stdout, "input string can't be converted to data using encoding %s\n", [name UTF8String]);
				//if (DEBUG_LEVEL > 0) NSLog(@"input string can't be converted to data using encoding %@", name);
				[name release]; name = nil;
				continue;
			}
		}
        
		if (quiet == 0) logLine(@"---------- Convert data to output -----------------");
        
        for (NSArray * outEntry in outStringEncodings) {
            NSString * outName = [[outEntry objectAtIndex:0] retain];
            enc = [[outEntry objectAtIndex:1] unsignedIntegerValue];
            NSString * dataAsString = [[NSString alloc] initWithData:strAsData encoding:enc];
			if (quiet == 0) {
				if (dataAsString || verbose) {
					 fprintf(stdout, "data as string using encoding %s = %s\n", [outName UTF8String], [dataAsString UTF8String]);
					//if (DEBUG_LEVEL > 0) NSLog(@"data as string using encoding %@ = %@", outName, dataAsString);
				}
			} else {
				if (dataAsString) {
					printf("%s", [dataAsString UTF8String]);
				}
			}
			[dataAsString release]; dataAsString = nil;
			[outName release]; outName = nil;
        }
		[name release]; name = nil;
    }
    
    [pool drain];
    return EXIT_SUCCESS;
}
