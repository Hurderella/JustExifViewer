//
//  EExifReader.m
//  ExifEditor_0510
//
//  Created by HeoChan Soon on 2014. 6. 1..
//  Copyright (c) 2014년 Hurderella. All rights reserved.
//

#import "EExifReader.h"
#import "EExifFileHandler.h"

@implementation EExifReader

- (id) init{
    
    self = [super init];
    
    EXIF_ENDIAN = EXIF_BIG_ENDIAN;

    return self;
}

- (id) initWithUrl:(NSString*) urlPath{

    self = [super init];
    
    if(self){
        self->openfilePath = urlPath;
    }
    
    return self;
}

-(BOOL)readImageData:(ImageData*) imageData{
    
    EExifFileHandler* exifFileHandler = [[EExifFileHandler alloc]
                                         initWithFilePath:self->openfilePath];
    
    [exifFileHandler storeCurPosWithTag:@"FILE_START"];
    
    
    u_short jpegStartTag = [exifFileHandler front_pop16];
    
    if (jpegStartTag != 0xFFD8) {
        
        NSDictionary* debugDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                    self->openfilePath,
                                                                    @"FileName", nil];
        
        NSException* except = [NSException exceptionWithName:@"JpegTagError"
                                                      reason:@"Jpeg StartTag is not 0xFFD8"
                                                    userInfo:debugDic];
        [except raise];

//        [NSException raise:@"JpegTagError" format:@"JpegStartTag is not 0xFFD8!"];
    }
    
    
    u_short exifTag, tagLength = 0;
    
    BOOL loopFlag = true;
    
    while (loopFlag) {
        [exifFileHandler setEndian:EXIF_BIG_ENDIAN];
        exifTag = [exifFileHandler front_pop16];
        
        [exifFileHandler storeCurPosWithTag:@"TAG_SEARCH"];
        
        tagLength = [exifFileHandler front_pop16];
        
        switch (exifTag) {
            case 0xFFE1:
                [self readExif_FFE1Tag:exifFileHandler
                              StartPos:[exifFileHandler getCurPos]
                             ImageData:imageData];
//                               ExifIFD:infoData.ExifIfdDictionary
//                               SubIFD:infoData.SubIfdDictionary
//                              ThumbIFD:infoData.ThumbIfdDictionary];
                break;
            case 0xFFDB:
                NSLog(@"FFDB!!!!");
                imageData.DqtStartPos = [exifFileHandler getCurPos] - 4;
                loopFlag = false;
                break;
            default:
        
                if (!(0xFF00 <= exifTag && exifTag <= 0xFFFF)){
                    NSLog(@"Tag Not Found : %x", exifTag);
                    loopFlag = false;
                }
                break;
        }
        [exifFileHandler moveTo:tagLength from:@"TAG_SEARCH"];
    }

    //[imageData makeDetailExifInfoData:openfilePath];
    return true;
    
}

- (BOOL) readExif_FFE1Tag:(EExifFileHandler*) fileHandler
                 StartPos:(uint) pos
                ImageData:(ImageData*) imageData{

    EExifFileHandler* exifFileHandler = fileHandler;
    
    [exifFileHandler moveTo:pos from:@"FILE_START"];
    
    u_int tagIdentifier = [exifFileHandler front_pop32];
    u_short nullChar = [exifFileHandler front_pop16];
    
    if (tagIdentifier != 0x45786966 || nullChar != 0x0000) {
        
        NSLog(@"Invalid E1 Identifier");
        return false;
    }
    
    [exifFileHandler storeCurPosWithTag:@"STUB_OF_FFE1"];
    imageData.ExifPivotPos = [exifFileHandler getCurPos];
    
    u_int e1_tagEndian = [exifFileHandler front_pop32];
    [exifFileHandler setEndian:e1_tagEndian];
    
    
    u_int exifIfdStartOffset = [exifFileHandler front_pop32];
    [exifFileHandler moveTo:exifIfdStartOffset from:@"STUB_OF_FFE1"];
    
    // Exif IFD 0
    u_int nextOffset_0th = 0;
    [self readExif_IFD:exifFileHandler
              StartPos:[exifFileHandler getCurPos]
            DataEndian:e1_tagEndian
            IfdInfoDic:imageData.ExifIfdDictionary
             IfdOffset:&nextOffset_0th];
    
    // Exif Sub IFD
    IfdInfo* ifd = imageData.ExifIfdDictionary[@"8769"];
    u_int* ifd_data = (u_int*)[ifd.Data bytes];
    u_int nextOffset_sub = 0;
    if (ifd_data){
//        for(int i = 0 ; i < 4 ; i++){
//            NSLog(@"8769[%d] : %X", i, ifd_data[i]);
//        }
//        NSLog(@"*ifd_data : %X", (u_int)(*ifd_data));
        u_int offset = NSSwapBigIntToHost((u_int)*ifd_data);//[exifFileHandler MixToUINT:ifd_data];
//        NSLog(@">>>offset : %X", offset);
        [exifFileHandler moveTo:offset from:@"STUB_OF_FFE1"];
        
        [self readExif_IFD:exifFileHandler
                  StartPos:[exifFileHandler getCurPos]
                DataEndian:e1_tagEndian
                IfdInfoDic:imageData.SubIfdDictionary
                 IfdOffset:&nextOffset_sub];
    }
    
    NSLog(@"===========");
    
    //Thumbnail
    u_int nextIfdOffset = nextOffset_0th;//exifIfd[@"nextIfdOffset"];
    if (0 != nextIfdOffset) {
        
        [exifFileHandler moveTo: nextIfdOffset from:@"STUB_OF_FFE1"];

        u_int nextOffset_thumb = 0;
        [self readExif_IFD:exifFileHandler
                  StartPos:[exifFileHandler getCurPos]
                DataEndian:e1_tagEndian
                IfdInfoDic:imageData.ThumbIfdDictionary
                 IfdOffset:&nextOffset_thumb];
        NSLog(@"Thumb Dic : %@", imageData.ThumbIfdDictionary);
    }

    return true;
}

- (BOOL) readExif_IFD:(EExifFileHandler*) fileHandler
             StartPos:(uint) pos
           DataEndian:(u_int) endian
           IfdInfoDic:(NSMutableDictionary*) ifdInfoDic
            IfdOffset:(uint*) ifdOffset{
    
    if (ifdInfoDic == nil) {
        [NSException raise:@"NilOfIFD" format:@"IFD Array is Nil"];
        return false;
    }
    
    EExifFileHandler* exifFileHandler = fileHandler;
    
    [exifFileHandler moveTo:pos from:@"FILE_START"];
    
    [exifFileHandler setEndian:endian];
    
    u_int ifdCount = [exifFileHandler front_pop16];
    
    
    [exifFileHandler storeCurPosWithTag:@"START_OF_IFD"];
    
    for (int i = 0 ; i < ifdCount; i++) {
        [exifFileHandler moveTo: i*12 from:@"START_OF_IFD"];
        
        IfdInfo* ifdInfo = [IfdInfo alloc];
        ifdInfo.Tag = [exifFileHandler front_pop16];
        ifdInfo.Type = [exifFileHandler front_pop16];
        ifdInfo.ComponentCount = [exifFileHandler front_pop32];
        ifdInfo.EndianInfo = endian;

        u_int dataLength = bytePerComponent[ifdInfo.Type] * ifdInfo.ComponentCount;
        if (dataLength > 4){
            u_int ifdInfoOffset = [exifFileHandler front_access32];
            [exifFileHandler moveTo:ifdInfoOffset from:@"STUB_OF_FFE1"];
            
            u_char* readDataPtr = [exifFileHandler curDataPtr];
            ifdInfo.Data = [NSData dataWithBytes:readDataPtr length:dataLength];

        }else{
            uint ifd_value = [exifFileHandler front_access32];
            uint data = NSSwapHostIntToBig(ifd_value);
            ifdInfo.Data = [NSData dataWithBytes:&data length:4];
        }

        [ifdInfoDic setObject:ifdInfo forKey:[NSString stringWithFormat:@"%04X", ifdInfo.Tag]];
        
    }
    [exifFileHandler moveTo: 12*ifdCount from:@"START_OF_IFD"];
    
    *ifdOffset = [exifFileHandler front_pop32];
    
    return true;
}

@end





