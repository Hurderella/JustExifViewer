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
@synthesize FullPath;
//@synthesize CameraModel;
//@synthesize CameraBrand;
@synthesize FileDate;
@synthesize ImageBitmap;
@synthesize DqtStartPos;
@synthesize ExifPivotPos;
@synthesize ExifIfdDictionary;
@synthesize SubIfdDictionary;
@synthesize ThumbIfdDictionary;

- (id) init{

    self = [super init];
    
    if (self) {
        ImageInfoString = nil;
        FileName = @"no name";
        FullPath = @"no path";
//        Date = @"1970-01-01 00:00:00 +0000";//YYYY-MM-DD HH:MM:SS ±HHMM

//        CameraModel = @"";
//        CameraBrand = @"no brand";
        FileDate = nil;
        ImageBitmap = nil;
        DqtStartPos = 0;
        ExifPivotPos = 0;
        
        ExifIfdDictionary = [[NSMutableDictionary alloc] init];
        SubIfdDictionary = [[NSMutableDictionary alloc] init];
        ThumbIfdDictionary = [[NSMutableDictionary alloc] init];
        /*
        [self addObserver:self
               forKeyPath:@"CameraModel"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
        [self addObserver:self
               forKeyPath:@"FileDate"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
        */
    }
    
    return self;

}

- (void) syncImgDataToIfdData{
    NSLog(@"syncImgDataToIfdData");
    
    // Camera Model     //0110
    // Camera Brand     //010F
    // File Date        //0132
    
//    IfdInfo* modelIfd = ExifIfdDictionary[@"0110"];
//    int unitSize = bytePerComponent[modelIfd.Type];
//    NSData* modelData = [self.CameraModel dataUsingEncoding:NSASCIIStringEncoding];
//    ExifIfdDictionary[@"0110"] = [[IfdInfo alloc] initWithTag:modelIfd.Tag
//                                                         Type:modelIfd.Type
//                                              ComponenetCount:(u_int)[modelData length] / unitSize
//                                                         Data:modelData];
//    
//    IfdInfo* brandIfd = ExifIfdDictionary[@"010F"];
//    unitSize = bytePerComponent[brandIfd.Type];
//    NSData* brandData = [self.CameraBrand dataUsingEncoding:NSASCIIStringEncoding];
//    ExifIfdDictionary[@"010F"] = [[IfdInfo alloc] initWithTag:brandIfd.Tag
//                                                         Type:brandIfd.Type
//                                              ComponenetCount:(u_int)[brandData length] / unitSize
//                                                         Data:brandData];
//    
//    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//
//    IfdInfo* dateIfd = ExifIfdDictionary[@"0132"];
//    unitSize = bytePerComponent[dateIfd.Type];
//    NSString* fileDateStr = [formatter stringFromDate:self.FileDate];
//    NSData* fileDateData = [fileDateStr dataUsingEncoding:NSASCIIStringEncoding];
//    ExifIfdDictionary[@"0132"] = [[IfdInfo alloc] initWithTag:dateIfd.Tag
//                                                         Type:dateIfd.Type
//                                              ComponenetCount:(u_int)[fileDateData length] / unitSize
//                                                         Data:fileDateData];
    
}

/*
- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context{

    NSLog(@"Change!: %@", keyPath);
    
    if ([keyPath isEqualToString:@"CameraModel"]) {

        NSString* tagString = @"0110";
        IfdInfo* ifd = ExifIfdDictionary[tagString];
        
        if (ifd == nil) return;

//        NSData* data = [ifd Data];
//        NSString* model = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//        
//        NSLog(@"origin model : %@", model);

        NSString* modi_model  = [change valueForKey:@"new"];
        NSLog(@"modified Model : %@", modi_model);
        
        NSData* modi_model_data = [modi_model dataUsingEncoding:NSASCIIStringEncoding];
        
        IfdInfo* modi_ifd = [[IfdInfo alloc] init];
        modi_ifd.Tag = ifd.Tag;
        modi_ifd.Type = ifd.Type;
        modi_ifd.ComponentCount = (unsigned int)[modi_model_data length];
        modi_ifd.Data = modi_model_data;
        
        ExifIfdDictionary[tagString] = modi_ifd;
        
    }else if([keyPath isEqualToString:@"FileDate"]){
        
        NSString* tagString = @"0132";
        IfdInfo* ifd = ExifIfdDictionary[tagString];
        
        if (ifd == nil) return;
        
        NSDate* dateInfo = [change valueForKey:@"new"];
        NSLog(@"date Info : %@", dateInfo);
//        ifd.fi
    }
    
//    NSLog(@"Tag :0x%X", [ifd Tag]);

//    date:infoData.ExifIfdDictionary[@"0132"]
//     brand:infoData.ExifIfdDictionary[@"010F"]
//     model:infoData.ExifIfdDictionary[@"0110"]
//     
//     @property u_short Tag;
//     @property u_short Type;
//     @property u_int ComponentCount;
//     @property NSData* Data;



}*/

- (void) makeDetailExifInfoData:(NSString*) filePath
                   Ifd_0_Fmt_Key:(NSArray*) keysOf_0_ifd
                Ifd_0_Fmt_String:(NSArray*) fmtStrOf_0_ifd
                 Ifd_sub_Fmt_Key:(NSArray*) keysOf_sub_ifd
              Ifd_sub_Fmt_String:(NSArray*) fmtStrOf_sub_ifd{
    
    self->FullPath = filePath;
    self->ImageBitmap = [[NSImage alloc] initWithContentsOfFile:filePath];
    
    NSArray* dirs = [filePath componentsSeparatedByString:@"/"];
    
    self->FileName = [dirs lastObject];
    
    
    NSString* imageInfoStr = @"";
    
    NSDictionary* dicOf_0_ifd = self->ExifIfdDictionary;
//    NSDictionary* dicOf_sub_ifd = self->SubIfdDictionary;

//    NSDictionary* tagOf0Dic = [NSDictionary dictionaryWithObjects:fmtStrOf_0_ifd
//                                                          forKeys:keysOf_0_ifd];
//
//    NSDictionary* tagOfSubDic = [NSDictionary dictionaryWithObjects:fmtStrOf_sub_ifd
//                                                            forKeys:keysOf_sub_ifd];

//    imageInfoStr = [self makingImageInfoStringWithOrderedKey:keysOf_0_ifd//orderedKeysOf0IFD
//                                                     InfoDic:dicOf_0_ifd
//                                                      FmtDic:tagOf0Dic];
//    
//    imageInfoStr = [imageInfoStr stringByAppendingString:
//                    [self makingImageInfoStringWithOrderedKey:keysOf_sub_ifd//orderedKeysOfSubIFD
//                                                      InfoDic:dicOf_sub_ifd
//                                                       FmtDic:tagOfSubDic]];
    imageInfoStr = [EEJhead runParsing:self->FullPath];
    
    IfdInfo* dateIfd = dicOf_0_ifd[@"0132"];
    if (dateIfd) {
        NSString* dateStr = [dateIfd GenerateNotNullEndUTFString];
        self->FileDate = [self makingNSDateWithIfdString:dateStr];
    }else{
        NSLog(@"Empty Date");
        self->FileDate = [NSDate dateWithString:@"1970-01-01 00:00:00 +0000"];
    }
    
    // 0 IFD
    // 0x010e	ImageDescription
    // 0x011a	XResolution
    // 0x011b	YResolution
    
    // Sub
    // 0x829a	ExposureTime
    // 0x829d	FNumber
    // 0x8827	ISOSpeedRatings
    // 0x9205	MaxApertureValue
    // 0x9208	LightSource
    // 0x9209	Flash
    // 0x920a	FocalLength
    //
    
    NSFont* font = [NSFont fontWithName:@"Courier" size:14];
    self.ImageInfoString = [[NSMutableAttributedString alloc]initWithString:imageInfoStr];
    [self.ImageInfoString beginEditing];
    [self.ImageInfoString addAttribute:NSFontAttributeName
                                       value:font
                                       range:NSMakeRange(0, imageInfoStr.length)];
    [self.ImageInfoString endEditing];
    
    return;
}

- (NSDate*) makingNSDateWithIfdString:(NSString*) dateString{
    
    NSArray* dateEle = [dateString componentsSeparatedByCharactersInSet:
                        [NSCharacterSet characterSetWithCharactersInString:@" \0"]];
    
    NSString* dateInfo = @"";
    dateInfo = [dateEle[0] stringByReplacingOccurrencesOfString:@":" withString:@"-"];
    dateInfo = [dateInfo stringByAppendingString:@" "];
    dateInfo = [dateInfo stringByAppendingString:dateEle[1]];
    
    NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
    NSLog(@"%@", systemTimeZone);
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate* date = [formatter dateFromString:dateInfo];
    return date;
    
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
    
//    NSLog(@"self.Type : %d\n", self.Type);
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

//@implementation EEUtils
//
//+ (NSString*) GenerateNotNullEndUTFString:(char *)c_str
//                                   length:(unsigned long)leng{
//    
//    unsigned long byteLength = leng;
//    char* dataByte = c_str;
//    if (byteLength == 0 || c_str == 0) {
//        return nil;
//    }
//    
//    if (dataByte[byteLength-1] == '\0') {
//        byteLength--;
//    }
//    
//    NSString* nullessString = [[NSString alloc] initWithBytes:dataByte
//                                                       length:byteLength
//                                                     encoding:NSUTF8StringEncoding];
//    
//    
//    return nullessString;
//}
//
////+ (NSString*) RemoveLastNullChar:(char*) c_str length:(unsigned long)leng;
//@end

