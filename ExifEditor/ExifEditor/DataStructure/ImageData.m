//
//  EExifInfoData.m
//  ExifEditor_0510
//
//  Created by HeoChan Soon on 2014. 5. 11..
//  Copyright (c) 2014년 Hurderella. All rights reserved.
//

#import "ImageData.h"
#import "EEJhead.h"


@implementation ImageData

@synthesize ImageInfoString;
@synthesize FileName;
@synthesize FileTimeZone;
@synthesize FullPath;
@synthesize FileDate;
@synthesize ImageBitmap;
@synthesize DqtStartPos;
@synthesize ExifPivotPos;
@synthesize ExifIfdDictionary;
@synthesize SubIfdDictionary;
@synthesize ThumbIfdDictionary;

@synthesize coordinate;
static int k = 0;
- (id) init{
    k++;
    self = [super init];
    
    if (self) {
        ImageInfoString = nil;
        FileName = @"no name";
        FullPath = @"no path";

        FileDate = nil;
        ImageBitmap = nil;
        DqtStartPos = 0;
        ExifPivotPos = 0;
        
        ExifIfdDictionary = [[NSMutableDictionary alloc] init];
        SubIfdDictionary = [[NSMutableDictionary alloc] init];
        ThumbIfdDictionary = [[NSMutableDictionary alloc] init];

        coordinate.latitude = 37.265310f + k;
        coordinate.longitude = 127.040785f + k;
//        
//        if (k % 2 == 0) {
//            coordinate = kCLLocationCoordinate2DInvalid;
//        }


    }
    
    return self;

}

- (void) makeDetailExifInfoData:(NSString*) filePath {
    
    self->FullPath = filePath;
    self->ImageBitmap = [[NSImage alloc] initWithContentsOfFile:filePath];
    
    NSArray* dirs = [filePath componentsSeparatedByString:@"/"];
    self->FileName = [dirs lastObject];
    
    NSString* imageInfoStr = @"";
    NSMutableString* dateString = [[NSMutableString alloc] init];
    imageInfoStr = [EEJhead runParsing:self->FullPath dateStr:dateString];
    
    if (dateString) {

        NSArray* dateEle = [dateString componentsSeparatedByCharactersInSet:
                            [NSCharacterSet characterSetWithCharactersInString:@" \0\""]];
        NSString* dateFormat = @"";

        dateFormat = [dateEle[2] stringByReplacingOccurrencesOfString:@":" withString:@"-"];
        dateFormat = [dateFormat stringByAppendingString:@" "];
        dateFormat = [dateFormat stringByAppendingString:dateEle[3]];

        NSLog(@"dateFormat : %@", dateFormat);
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        self->FileDate = [formatter dateFromString:dateFormat];
        self->FileTimeZone = @"Europe/London";
        
    }else{
        
        NSLog(@"Empty Date");
        self->FileDate = [NSDate dateWithString:@"1970-01-01 00:00:00 +0000"];
        
    }
    
    NSFont* font = [NSFont fontWithName:@"Courier" size:14];
    self.ImageInfoString = [[NSMutableAttributedString alloc]initWithString:imageInfoStr];
    [self.ImageInfoString beginEditing];
    [self.ImageInfoString addAttribute:NSFontAttributeName
                                       value:font
                                       range:NSMakeRange(0, imageInfoStr.length)];
    [self.ImageInfoString endEditing];
    
    return;
}

@end

