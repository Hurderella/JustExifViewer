//
//  EExifFileHandler.h
//  ExifEditor_0510
//
//  Created by HeoChan Soon on 2014. 6. 28..
//  Copyright (c) 2014년 Hurderella. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageData.h"

static const int EXIF_SIZE = 64 * 1024;

typedef enum {
    BYTE_8 = 1,
    BYTE_16 = 2,
    BYTE_32 = 4
}ByteUnit;



typedef u_int (^ENDIAN_FUNC)(u_char*, ByteUnit);
ENDIAN_FUNC bigEndianShift;
ENDIAN_FUNC littleEndianShift;

@interface EExifFileHandler : NSObject{
    unsigned int dataPos;
    unsigned int prevDataPos;

    E_ENDIAN_INFO readEndian;
    u_char* dataArr;
    u_int dataSize;
    BOOL dataOwner;
    
    ENDIAN_FUNC curEndianShift;
    
    NSMutableDictionary* storePosDic;

}

- (id) initWithFilePath:(NSString*)path;
- (id) initWithDataPtr:(u_char*) dataPtr dataSize:(u_int)size;
- (id) initWithDataPtr:(u_char *)dataPtr dataSize:(u_int)size needToDataDelete:(BOOL) flag;

- (void) setEndian:(E_ENDIAN_INFO) endian;
- (void) storeCurPosWithTag:(NSString*) key;
- (u_int) getStorePos:(NSString*) key;
- (void) moveTo:(int) moveValue from:(NSString*) pivotKey;
- (u_int) getCurPos;
- (u_int) getCurDistanceFrom:(NSString*) key;
- (u_char*) curDataPtr;
- (u_int) getRemainderDataSize;

- (u_char) front_pop8;
- (u_char) front_access8;
- (u_short) front_pop16;
- (u_short) front_access16;
- (u_int) front_pop32;
- (u_int) front_access32;

- (u_short) MixToUSHORT:(u_char*) dataPtr;
- (u_int) MixToUINT:(u_char*) dataPtr;

@end
