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

+ (NSString*) runParsing:(NSString*) filePath
                 dateStr:(NSMutableString*) dateStr{

    NSString* appName = @"jhead";
    NSString* FilePath = filePath;
    
    NSLog(@"runParsing Path : %@", filePath);
    
    char* args[] = {(char*)[appName cStringUsingEncoding:NSUTF8StringEncoding],
        "-v",
        (char*)[FilePath cStringUsingEncoding:NSUTF8StringEncoding]
    };
    
    __block NSMutableArray* parsingData = [[NSMutableArray alloc] init];

    entry_main(3, ^int(char* inputData) {
        NSString* dataString =
            [NSString stringWithCString:inputData encoding:NSUTF8StringEncoding];
        
        if (dataString == nil) {
            return 0;
        }

        [parsingData addObject:dataString];
        return 0;
    }, args);

    __block NSString* reportOfImage = @"";
    
    [parsingData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString* info = obj;
        reportOfImage = [reportOfImage stringByAppendingString:info];
    }];
    
    __block NSString* elementDate;
    NSArray* infoLines = [reportOfImage componentsSeparatedByString:@"\n"];
    
    [infoLines enumerateObjectsUsingBlock:
     ^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

         NSArray* elements = [(NSString*)obj componentsSeparatedByString:@"="];

         if ([elements count] >= 2) {
             NSString* dataKeyword = [(NSString*) elements[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
             
             if ([dataKeyword compare:@"DateTime" options:NSLiteralSearch range:(NSRange){0, 8}] == 0) {
                 elementDate = (NSString*) elements[1];
             }
         }
         
         elements = [(NSString*)obj componentsSeparatedByString:@":"];
         
         if([elements count] >= 2){
         
             NSString* latitudeKeyword = [(NSString*) elements[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

             NSLog(@"%@", latitudeKeyword);
         }
        
    }];
    
    
    [dateStr insertString:elementDate atIndex:0];
    
    return reportOfImage;
}


@end
