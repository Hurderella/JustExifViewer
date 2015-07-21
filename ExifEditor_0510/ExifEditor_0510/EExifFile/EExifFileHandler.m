//
//  EExifFileHandler.m
//  ExifEditor_0510
//
//  Created by HeoChan Soon on 2014. 6. 28..
//  Copyright (c) 2014년 Hurderella. All rights reserved.
//

#import "EExifFileHandler.h"

ENDIAN_FUNC bigEndianShift = ^u_int(u_char* data, ByteUnit byteUnit){
    
    u_int rtnVal = 0;
    for (int i = 0; i < byteUnit; i++) {
        rtnVal <<= 8;
        rtnVal |= data[i];
    }
    return rtnVal;
};
ENDIAN_FUNC littleEndianShift = ^u_int(u_char* data, ByteUnit byteUnit){
    
    u_int rtnVal = 0;
    for (int i = 0; i < byteUnit; i++) {
        rtnVal |= data[i] << (i * 8);
    }
    return rtnVal;
};

@implementation EExifFileHandler

- (id)initWithFilePath:(NSString *)path{

    self = [super init];

    FILE* fd = fopen([path UTF8String], "rb");
    
    if (fd < 0) {
        [NSException raise:@"FileError" format:@"fail fopen()"];
    }
    
    dataArr = (u_char*)malloc(EXIF_SIZE);
    fread(dataArr, 1, EXIF_SIZE, fd);
    fclose(fd);
    
    return [self initWithDataPtr:dataArr dataSize:EXIF_SIZE needToDataDelete:true];
}

- (id) initWithDataPtr:(u_char *)dataPtr dataSize:(u_int)size{
    return [self initWithDataPtr:dataPtr dataSize:size needToDataDelete:false];
}

- (id) initWithDataPtr:(u_char *)dataPtr dataSize:(u_int)size needToDataDelete:(BOOL) flag{
    
    dataSize = size;
    dataArr = dataPtr;
    dataPos = 0;
    prevDataPos = 0;
    dataOwner = flag;
    
    storePosDic = [[NSMutableDictionary alloc] init];

    [self setEndian:EXIF_BIG_ENDIAN];
    return self;
}

- (void) dealloc{

    NSLog(@"ExifFileHandler Dealloc");
    if (dataOwner) {
        NSLog(@"data free");
        free(dataArr);
    }else{
        NSLog(@"data no free");
    }
//    free(dataArr);
    
}


- (void) setEndian:(E_ENDIAN_INFO)endian{

    if (endian != EXIF_BIG_ENDIAN && endian != EXIF_LITTLE_ENDIAN) {
        [NSException raise:@"EndianErr" format:@"Invalid Endian Enum"];
    }
    readEndian = endian;
    //NSLog(@"endian is = %x", readEndian);
    curEndianShift =
        (readEndian == EXIF_BIG_ENDIAN? bigEndianShift:littleEndianShift);
}

- (void) storeCurPosWithTag:(NSString*) key{
    NSNumber* dataPosNum = [NSNumber numberWithInteger:dataPos];
    [storePosDic setObject:dataPosNum forKey:key];
}

- (u_int) getStorePos:(NSString*) key{
    
    NSNumber* dataPosNum = [storePosDic objectForKey:key];
    if (dataPosNum == nil) {
        [NSException raise:@"Not Exist Key" format:@"Key : %@", key];
    }
    //[NSException raise:@"E1" format:@"Invalid E1 Identifier"];
    return (u_int)[dataPosNum unsignedIntegerValue];
}

- (void) moveTo:(int) moveValue from:(NSString*) pivotKey{
    
    u_int pivotPos = [self getStorePos:pivotKey];
    dataPos = moveValue + pivotPos;
}

- (u_int) getCurPos{
    
    return dataPos;
}

- (u_int) getCurDistanceFrom:(NSString*) key{
    
    return [self getCurPos] - [self getStorePos:key];
}

- (u_char*) curDataPtr{
    return &dataArr[dataPos];
}

- (u_int) getRemainderDataSize{
    return dataSize - dataPos;
}

//- (void) readIfdDic:(NSMutableDictionary*)ifdDic
//      pivotPosition:(NSString*)standName
//         nextOffset:(u_int*)offset{
//
////    NSMutableDictionary* tmpDic = [[NSMutableDictionary alloc] init];
//    
//    if (ifdDic == nil) {
//        [NSException raise:@"NilOfIFD" format:@"IFD Array is Nil"];
//        return;
//    }
//    
//    u_int ifdCount = [self front_pop16];
//    [self storeCurPos:@"START_OF_IFD"];
//    for (int i = 0 ; i < ifdCount; i++) {
//        [self moveTo: i*12 from:@"START_OF_IFD"];
//        
//        IfdInfo* ifdInfo = [IfdInfo alloc];
//        ifdInfo.Tag = [self front_pop16];
//        ifdInfo.Type = [self front_pop16];
//        ifdInfo.ComponentCount = [self front_pop32];
//        
//        u_int dataLength = bytePerComponent[ifdInfo.Type] * ifdInfo.ComponentCount;
//        if (dataLength > 4){
//            [self moveTo:[self front_access32] from:standName];
//        }
//        u_char* readDataPtr = [self curDataPtr];
//        
//        ifdInfo.Data = [NSData dataWithBytes:readDataPtr length:dataLength];
//        
//        [ifdDic setObject:ifdInfo forKey:[NSString stringWithFormat:@"%04X", ifdInfo.Tag]];
//     
//    }
//    [self moveTo: 12*ifdCount from:@"START_OF_IFD"];
//    *offset = [self front_pop32];
//
//}

- (u_char) front_pop8{
    dataPos += 1;
    return dataArr[dataPos - 1];
}

- (u_char) front_access8{
    return dataArr[dataPos];
}

- (u_short) front_pop16{
    
    u_short rtnVal = [self front_access16];
    dataPos += 2;
    return rtnVal;
}

- (u_short) front_access16{

    return curEndianShift(&dataArr[dataPos], BYTE_16);
}
- (u_int) front_pop32{
    
    u_int rtnVal = [self front_access32];
    dataPos += 4;
    return rtnVal;
}

- (u_int) front_access32{

    return curEndianShift(&dataArr[dataPos], BYTE_32);
}

- (u_short) MixToUSHORT:(u_char *)dataPtr{
    return self->curEndianShift(dataPtr, BYTE_16);
}

- (u_int) MixToUINT:(u_char *)dataPtr{
    return self->curEndianShift(dataPtr, BYTE_32);
}
@end
