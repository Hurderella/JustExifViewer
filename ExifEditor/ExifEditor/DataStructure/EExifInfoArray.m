//
//  EExifInfoController.m
//  ExifEditor_0510
//
//  Created by HeoChan Soon on 2014. 5. 11..
//  Copyright (c) 2014년 Hurderella. All rights reserved.
//

#import "EExifInfoArray.h"
#import "ImageData.h"

@implementation EExifInfoArray

- (void) addObject:(id)object{

    ImageData* imageData = (ImageData*) object;
        
    [super addObject:imageData];
}

@end
