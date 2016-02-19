//
//  EEAppDelegate.h
//  ExifEditor_0510
//
//  Created by HeoChan Soon on 2014. 5. 10..
//  Copyright (c) 2014년 Hurderella. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EExifInfoArray.h"
#import "EExifLogicController.h"

@interface EEAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet EExifLogicController* exifLogicController;
//@property (assign) IBOutlet EExifInfoArray* exifInfoArray;

@end
