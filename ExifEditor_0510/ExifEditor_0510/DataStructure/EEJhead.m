//
//  EEJhead.m
//  JustExifViewer
//
//  Created by Hurderella on 2015. 7. 19..
//  Copyright (c) 2015년 Hurderella. All rights reserved.
//

#import "EEJhead.h"
#include "jhead.h"


@implementation EEJhead

+ (int) testDummy:(char*) inputData{
    NSLog(@"testDummy");
    return 0;
}

+ (NSString*) runParsing:(NSString*) filePath{

    NSString* appName = @"jhead";
    NSString* FilePath = filePath;
    
    NSLog(@"runParsing Path : %@", filePath);
    
    char* args[] = {(char*)[appName cStringUsingEncoding:NSUTF8StringEncoding],
        "-v",
        (char*)[FilePath cStringUsingEncoding:NSUTF8StringEncoding]
    };
    
    __block NSMutableArray* ExifInfos = [[NSMutableArray alloc] init];

    entry_main(3, ^int(char* inputData) {
        NSString* dataString =
            [NSString stringWithCString:inputData encoding:NSUTF8StringEncoding];
        
        if (dataString == nil) {
            return 0;
        }
        
        [ExifInfos addObject:dataString];
        return 0;
    }, args);

    __block NSString* exifInfos = @"";
    
    [ExifInfos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString* info = obj;
        exifInfos = [exifInfos stringByAppendingString:info];
    }];
    
    
    return exifInfos;
}


@end
