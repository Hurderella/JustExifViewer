//
//  EEJhead.h
//  JustExifViewer
//
//  Created by Hurderella on 2015. 7. 19..
//  Copyright (c) 2015년 Hurderella. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EEJhead : NSObject


+ (int) testDummy:(char*) inputData;
+ (NSString*) runParsing:(NSString*) filePath
                 dateStr:(NSMutableString*) dateStr;

@end
