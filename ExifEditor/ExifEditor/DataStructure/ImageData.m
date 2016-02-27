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

- (NSString*) makingImageInfoStringWithOrderedKey:(NSArray*) keys
                                          InfoDic:(NSDictionary*) infoDic
                                           FmtDic:(NSDictionary*) fmtDic{
    
    __block NSString* ret = @"";
    [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSString* infoStr = @"NULL";
        IfdInfo* ifdInfo = infoDic[obj];
        if (ifdInfo) {
            infoStr = [NSString stringWithFormat:fmtDic[obj], [ifdInfo ContentToString]];
        }else{
            infoStr = [NSString stringWithFormat:fmtDic[obj], infoStr];
        }
        ret = [ret stringByAppendingString:infoStr];
        
    }];
    
    return ret;
}

@end

/////////////////////////////////////////////////////////////////////////////////

@implementation IfdInfo

@synthesize Tag;
@synthesize Type;
@synthesize ComponentCount;
@synthesize Data;
@synthesize EndianInfo;

- (id) initWithTag:(u_short) tag
              Type:(u_short) type
   ComponenetCount:(u_int) componentCount
              Data:(NSData*) data
            Endian:(E_ENDIAN_INFO)endianInfo{
    
    self = [super init];
    
    self.Tag = tag;
    self.Type = type;
    self.ComponentCount = componentCount;
    self.Data = data;
    self.EndianInfo = endianInfo;
    return self;
}

- (NSString*) GenerateNotNullEndUTFString{

    char* dataByte = (char*)[self.Data bytes];
    unsigned long byteLength = [self.Data length];

    if (byteLength == 0) {
        return nil;
    }
    
    if (dataByte[byteLength-1] == '\0') {
        byteLength--;
    }
    
    NSString* nullessString = [[NSString alloc] initWithBytes:dataByte
                                                       length:byteLength
                                                     encoding:NSUTF8StringEncoding];
    
    return nullessString;
}

- (NSString*) ContentToString{
    //
    // Component Count
    // bytePerComponent[self.Type]
    //
    
    unsigned int (^dataPack)(unsigned char*, int) = ^unsigned int (unsigned char* data, int len){
        unsigned int ret = 0;
        for (int k = 0; k < len; k++) {
            ret <<= 8;
            ret |= data[k];
        }
        return ret;
    };
    
    switch (self.Type) {
        case 1:
        case 3:
        case 4:
        case 6:
        case 7:
        case 8:
        case 9:
        {
            NSString* retStr = @"";
            unsigned char* data = (unsigned char*)[self.Data bytes];
            for (int i = 0; i < self.ComponentCount; i += bytePerComponent[self.Type]) {
                unsigned int ret = dataPack(&data[i], bytePerComponent[self.Type]);
//                NSLog(@">> ret : %X", ret);
                retStr = [retStr stringByAppendingString:[NSString stringWithFormat:@"%d ", ret]];
            }
            return retStr;
        }
            break;
        case 5:
        case 10:
        {
            unsigned int (*swapfptr)(unsigned int) =
                self.EndianInfo == EXIF_BIG_ENDIAN?
                    NSSwapBigIntToHost : NSSwapLittleIntToHost;
            
            NSString* retStr = @"";
            unsigned char* data = (unsigned char*)[self.Data bytes];
            for(int i = 0 ; i < self.ComponentCount; i += bytePerComponent[self.Type]){
                int retChi = swapfptr(*((int*)(&data[i])));
                int retPar = swapfptr(*((int*)(&data[i+4])));
                    //NSSwapLittleIntToHost(*((int*)(&data[i])));//dataPack(&data[i], 4);
                    //NSSwapLittleIntToHost(*((int*)(&data[i+4])));//dataPack(&data[i + 4], 4);
                NSString* rationStr = [NSString stringWithFormat:@"%d/%d ", retChi, retPar];
                retStr = [retStr stringByAppendingString:rationStr];
//                NSLog(@">>> ret : %d / %d", retChi, retPar);

            }
            return retStr;
        }
            break;
        case 11:
        case 12:
            break;
        case 2:
        {
            NSString *retStr = [self GenerateNotNullEndUTFString];
            return retStr;
        }
            break;

        default:
            break;
    }
    return nil;
}

@end
