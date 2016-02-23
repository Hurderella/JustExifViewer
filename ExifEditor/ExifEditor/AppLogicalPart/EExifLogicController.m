//
//  EExifViewControl.m
//  ExifEditor_0510
//
//  Created by HeoChan Soon on 2014. 5. 11..
//  Copyright (c) 2014년 Hurderella. All rights reserved.
//

#import "EExifLogicController.h"
#import "EExifReader.h"

@implementation EExifLogicController

- (id)init{

    self = [super init];
    return self;
}
- (void)preoperate{
    
//    NSLog(@"initInnerObserver");
    windowControllers = [[NSMutableArray alloc] init];
    
    [exifInfoArray addObserver:self forKeyPath:@"selection"
                       options:NSKeyValueObservingOptionNew
                       context:nil];
    [addableClipView addObserver:self forKeyPath:@"AddFileList"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    
    defaultIcon = [NSImage imageNamed:@"DefaultIcon"];
    
    [imageMidThumbView setImage:defaultIcon];

    [timeZonePopup removeAllItems];
    [timeZonePopup addItemsWithTitles:[NSTimeZone knownTimeZoneNames]];
//    [timeZonePopup selectItemWithTitle:@"Europe/London"];
}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{

    if ([object isEqual:exifInfoArray]) {

        unsigned int selectionCount = (unsigned int)[[exifInfoArray selectionIndexes] count];
        if ( selectionCount != 0) {
            NSArray* arr = [exifInfoArray arrangedObjects];
            [self displayFileSelectState:[exifInfoArray selectionIndex] + 1
                                   total:[arr count]];
            
        }
        if (selectionCount > 1) {
            NSArray* selectedArr = [exifInfoArray selectedObjects];
            ImageData* imageData = (ImageData*) [selectedArr lastObject];

            [imageInfoView setString:[[imageData ImageInfoString] string]];
            [imageMidThumbView setImage:[imageData ImageBitmap]];
        }else if (selectionCount == 0){
            [imageMidThumbView setImage:defaultIcon];
        }
        
    }else if ([object isEqual:addableClipView]){


        __block NSString* errorLog = @"";

        NSArray* filePathList = addableClipView.AddFileList;
        [filePathList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSLog(@">>%@", obj);
            NSString* filePath = obj;
            BOOL isDirectory = false;
            [[NSFileManager defaultManager] fileExistsAtPath:filePath
                                                 isDirectory:&isDirectory];

            [self addExifInfoToArray:exifInfoArray
                            FilePath:filePath
                            ErrorLog:&errorLog];
            
        }];
        if ( ![errorLog isEqualTo:@""]) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"error files.."];
            [alert setInformativeText:errorLog];
            [alert addButtonWithTitle:@"Ok"];
            [alert runModal];
        }

    }
}


- (void) addExifInfoToArray:(EExifInfoArray*) exifInfos
                  FilePath:(NSString*) filePath
                  ErrorLog:(NSString**) errorLog{

    NSString* urlPath = filePath;
    NSPredicate* predicate = [NSPredicate
                              predicateWithFormat:@"FullPath like %@", urlPath];
    NSArray* arr = [[exifInfos arrangedObjects] filteredArrayUsingPredicate:predicate];
    
    if ([arr count] != 0) {
        NSLog(@"Exist !! %@", urlPath);
        return;
    }
    
    @try{

        ImageData* readData = [[ImageData alloc] init];
        if(readData){
        
            [readData makeDetailExifInfoData:urlPath];
            [exifInfos addObject:readData];
        }
    }@catch(NSException* e){
        
        NSDictionary* debugDic = [e userInfo];
        NSString* errStr = [NSString stringWithFormat:@"%@ : \n%@\n",
                            [e description], debugDic[@"FileName"]] ;
        *errorLog = [*errorLog stringByAppendingString:errStr];
        NSLog(@"%@ : %@", debugDic[@"FileName"], [e description]);
    }
    return ;
}

- (IBAction)addJPGFile:(id)sender{
    
    NSLog(@"addJpgFile");
    
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:YES];
    
    NSArray* allowExt = [NSArray arrayWithObject:@"jpg"];
    [panel setAllowedFileTypes:allowExt];
    
    [panel setMessage:@"Import one or more files or directories."];
        
    [panel beginWithCompletionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            [fileReadProg setHidden:false];
            [fileReadProg startAnimation:fileReadProg];
            
            NSString* errorLog = @"";
            for (NSURL* url in [[panel URLs] objectEnumerator] ) {
                NSLog(@">> %@", [url path]);
                [self addExifInfoToArray:exifInfoArray
                               FilePath:[url path]
                               ErrorLog:&errorLog];
            };
            if ( ![errorLog  isEqual:@""] ) {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:@"error files.."];
                [alert setInformativeText:errorLog];
                [alert addButtonWithTitle:@"Ok"];
                [alert runModal];
            }
            [fileReadProg setHidden:true];
            [fileReadProg stopAnimation:fileReadProg];

        }
    }];
    
}

- (IBAction)imgDoubleClick:(id)sender{
    NSLog(@"MId DoubleClick %@\n", sender);
    NSArray* selectedArr = [exifInfoArray selectedObjects];
    ImageData* imageData = (ImageData*) [selectedArr lastObject];
    
    if (imageData != nil) {
        [self doubleClickTest:imageData];
    }
    
}

- (IBAction)mapBtn:(id)sender{

    NSLog(@"!!!!!!!!!!!!mapBtn click!");

    if (mapWindow == nil) {
        
        mapWindow = [[EEMapWindowController alloc] initWithWindowNibName:@"EEMapWindowController"];
        mapWindow.annotationData = exifInfoArray;
    }
    
    [mapWindow showWindow:mapWindow];
}

- (void) doubleClickTest:(id)imageData{
    ImageData* imgData = (ImageData*) imageData;

    [[NSWorkspace sharedWorkspace] openFile:imgData.FullPath withApplication:@"Preview.app"];    
}

-(void) displayFileSelectState:(unsigned long)currentSelect total:(unsigned long)total{

    NSString* state = [NSString stringWithFormat:@"%lu / %lu", currentSelect, total];

    [listFileCntState setStringValue:state];
}

- (IBAction)removeJPGinList:(id)sender{
    
    [exifInfoArray removeObjectsAtArrangedObjectIndexes:[exifInfoArray selectionIndexes]];

}

@end







