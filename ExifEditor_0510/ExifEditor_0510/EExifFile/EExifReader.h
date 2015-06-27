//
//  EExifReader.h
//  ExifEditor_0510
//
//  Created by HeoChan Soon on 2014. 6. 1..
//  Copyright (c) 2014년 Hurderella. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EExifFileHandler.h"
#import "ImageData.h"

@interface EExifReader : NSObject{

    E_ENDIAN_INFO EXIF_ENDIAN;
    NSString* openfilePath;

}

- (id) initWithUrl:(NSString*) urlPath;

- (BOOL) readImageData:(ImageData*)imageData;

//- (BOOL) readExif_FFE1Tag:(EExifFileHandler*) fileHandler
//                 startPos:(uint) pos
//              ExifIFD:(NSMutableDictionary*) exifIfd
//              SubIFD:(NSMutableDictionary*) subIfd
//               ThumbIFD:(NSMutableDictionary*) ifdThumb;

@end
