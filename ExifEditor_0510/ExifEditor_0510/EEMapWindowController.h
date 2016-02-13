//
//  EEMapWindowController.h
//  JustExifViewer
//
//  Created by Hurderella on 2016. 2. 10..
//  Copyright © 2016년 Hurderella. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EEMapController.h"

@interface EEMapWindowController : NSWindowController {

}

@property (assign) IBOutlet EEMapController* mapContorller;
@property (assign) EExifInfoArray* annotationData;
@end
