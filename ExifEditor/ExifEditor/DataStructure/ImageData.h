//
//  EExifInfoData.h
//  ExifEditor_0510
//
//  Created by HeoChan Soon on 2014. 5. 11..
//  Copyright (c) 2014년 Hurderella. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef enum{
    EXIF_BIG_ENDIAN = 0x4D4D002A,
    EXIF_LITTLE_ENDIAN = 0x49492A00
}E_ENDIAN_INFO;

@interface ImageData : NSObject <MKAnnotation> {

@public
    
    NSMutableAttributedString* ImageInfoString;
    NSString* FileName;
    NSString* FullPath;
    NSDate* FileDate;
    NSImage* ImageBitmap;
    u_char thumbBin[64*1024];
    BOOL result;
    int DqtStartPos;
    uint ExifPivotPos;
    
    NSMutableDictionary* ExifIfdDictionary;
    NSMutableDictionary* SubIfdDictionary;
    NSMutableDictionary* ThumbIfdDictionary;
    
}

- (void) makeDetailExifInfoData:(NSString*) filePath;

@property (readwrite, strong) NSMutableAttributedString* ImageInfoString;
@property (readwrite, strong) NSString* FileName;
@property (readwrite, strong) NSString* FullPath;
@property (readwrite, strong) NSDate* FileDate;
@property (readwrite, strong) NSString* FileTimeZone;
@property (readwrite, strong) NSImage* ImageBitmap;
@property (readwrite) int DqtStartPos;
@property (readwrite) uint ExifPivotPos;
@property (readwrite, strong) NSMutableDictionary* ExifIfdDictionary;
@property (readwrite, strong) NSMutableDictionary* SubIfdDictionary;
@property (readwrite, strong) NSMutableDictionary* ThumbIfdDictionary;

@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;

@end

/////////////////////////////////////////////////////////////////////////////////

static const u_char bytePerComponent[13] = {0, 1, 1, 2, 4, 8, 1, 1, 2, 4, 8, 4, 8};

@interface IfdInfo:NSObject

- (id) initWithTag:(u_short) tag
              Type:(u_short) type
   ComponenetCount:(u_int) componentCount
              Data:(NSData*) data
            Endian:(E_ENDIAN_INFO) endianInfo;

- (NSString*) GenerateNotNullEndUTFString;

- (NSString*) ContentToString;

@property u_short Tag;
@property u_short Type;
@property u_int ComponentCount;
@property NSData* Data;
@property E_ENDIAN_INFO EndianInfo;

@end

//@interface EEUtils : NSObject
//
//+ (NSString*) GenerateNotNullEndUTFString:(char*) c_str
//                                   length:(unsigned long) leng;
//
//@end
