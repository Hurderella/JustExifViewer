//
//  EExifViewControl.h
//  ExifEditor_0510
//
//  Created by HeoChan Soon on 2014. 5. 11..
//  Copyright (c) 2014년 Hurderella. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EEAddableClipView.h"
#import "EExifInfoArray.h"
#import "ImageData.h"
#import "EEMapWindowController.h"

@interface EExifLogicController : NSObject{

    IBOutlet EExifInfoArray* exifInfoArray;
    IBOutlet NSProgressIndicator* fileReadProg;
    IBOutlet NSTextField* listFileCntState;
    IBOutlet NSTableView* fileTable;

    IBOutlet NSTextView* imageInfoView;
    IBOutlet NSImageCell* imageMidThumbView;
    IBOutlet NSButton* makeBtn;
    
    IBOutlet EEAddableClipView* addableClipView;
    
    NSMutableArray* windowControllers;
    
    NSArray* orderedKeysOf0IFD;
    NSArray* orderedObjectOf0IFD;
    
    NSArray* orderedKeysOfSubIFD;
    NSArray* orderedObjectOfSubIfd;
    
    NSImage* defaultIcon;
    
    EEMapWindowController* mapWindow;
    
    void (^fileAddBlock)(NSString*);
}

- (IBAction)addJPGFile:(id)sender;
- (IBAction)removeJPGinList:(id)sender;
- (void) doubleClickTest:(id)imageData;

- (IBAction)imgDoubleClick:(id)sender;
- (IBAction)mapBtn:(id)sender;

- (void)initInnerObserver;
- (void)displayFileSelectState:(unsigned long)currentSelect total:(unsigned long)total;

@end
