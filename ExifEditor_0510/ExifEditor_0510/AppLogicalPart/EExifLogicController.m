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
- (void)initInnerObserver{
    
    NSLog(@"initInnerObserver");
    windowControllers = [[NSMutableArray alloc] init];
    
    [exifInfoArray addObserver:self forKeyPath:@"selection"
                       options:NSKeyValueObservingOptionNew
                       context:nil];
    [addableClipView addObserver:self forKeyPath:@"AddFileList"
                         options:NSKeyValueObservingOptionNew
                         context:nil];

    orderedKeysOf0IFD = [NSArray arrayWithObjects:
                                  @"010F",
                                  @"0110",
                                  @"010E",
                                  @"011A",
                                  @"011B", nil];
    
    orderedObjectOf0IFD = [NSArray arrayWithObjects:
                                    @"MAKE : %@\n",
                                    @"MODEL : %@\n",
                                    @"DESCRIPTION : %@\n",
                                    @"X Resolution : %@\n",
                                    @"Y Resolution : %@\n", nil];

    orderedKeysOfSubIFD = [NSArray arrayWithObjects:
                                    @"829A", @"829D", @"8827",
                                    @"9205", @"9208", @"9209", @"920A",
                                    @"A001", @"A002", @"A003", nil];
    
    orderedObjectOfSubIfd = [NSArray arrayWithObjects:
                                      @"Exposure Time : %@\n",
                                      @"F Number : %@\n",
                                      @"ISO Speed : %@\n",
                                      @"MaxApertureValue : %@\n",
                                      @"LightSource : %@\n",
                                      @"Flash : %@\n",
                                      @"Focal Length : %@\n",
                                      @"Color Space : %@\n",
                                      @"Exif Image Width : %@\n",
                                      @"Exif Image Height : %@\n", nil];
    
    defaultIcon = [NSImage imageNamed:@"DefaultIcon"];
    
    [imageMidThumbView setImage:defaultIcon];
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
    EExifReader* exifReader = [[EExifReader alloc] initWithUrl:urlPath];
    
    NSPredicate* predicate = [NSPredicate
                              predicateWithFormat:@"FullPath like %@", urlPath];
    NSArray* arr = [[exifInfos arrangedObjects] filteredArrayUsingPredicate:predicate];
    
    if ([arr count] != 0) {
        NSLog(@"Exist !! %@", urlPath);
        return;
    }
    
    @try{
        ImageData* readData = [[ImageData alloc] init];
        if([exifReader readImageData:readData]){
            
            [readData makeDetailExifInfoData:urlPath
                               Ifd_0_Fmt_Key:orderedKeysOf0IFD
                            Ifd_0_Fmt_String:orderedObjectOf0IFD
                             Ifd_sub_Fmt_Key:orderedKeysOfSubIFD
                          Ifd_sub_Fmt_String:orderedObjectOfSubIfd];
            
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

- (void) doubleClickTest:(id)imageData{
    ImageData* imgData = (ImageData*) imageData;

    [[NSWorkspace sharedWorkspace] openFile:imgData.FullPath withApplication:@"Preview.app"];    
}


- (void) makeCSVFileWithImageData:(NSArray*) imageDatas
                    SaveDirectory:(NSString*) saveDirectory
                     SaveFileName:(NSString*) saveFileName{
    
    if ( !imageDatas.count) {
        return;
    }
    
    NSString* fileSavePath = [saveDirectory stringByAppendingFormat:@"%@.csv", saveFileName];
    
    int fileCount = 0;
    while([[NSFileManager defaultManager] fileExistsAtPath:fileSavePath isDirectory:NO]){
        fileCount++;

        NSString* duplicatePath =
                            [saveFileName stringByAppendingFormat:@"_%d.csv", fileCount];

        fileSavePath = [saveDirectory stringByAppendingString:duplicatePath];
    }

    if ( ![[NSFileManager defaultManager] createFileAtPath:fileSavePath
                                                  contents:nil
                                                attributes:nil]){
        NSLog(@"File Create Fail");
        return;
    }
    
    
    
    NSFileHandle* wHandle = [NSFileHandle fileHandleForWritingAtPath:fileSavePath];
    NSLog(@"handle : %@", wHandle);
    [imageDatas enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        ImageData* imgData = obj;

        NSString* imgDataStr = [imgData.ImageInfoString string];
        NSArray* imgDataLine = [imgDataStr componentsSeparatedByString:@"\n"];
        
        if (idx == 0) {
            __block NSString* subjectRow = @"Name";
            
            [imgDataLine enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
                if ([(NSString*)obj isEqualTo:@""]) return;
                
                NSString* subject = [(NSString*)obj componentsSeparatedByString:@":"][0];
                subjectRow = [subjectRow stringByAppendingString:
                              [NSString stringWithFormat:@",%@", subject]];
                
            }];
            
            subjectRow = [subjectRow stringByAppendingString:@"\n"];
            [wHandle writeData:[subjectRow dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        __block NSString* contentDataLine = [NSString stringWithFormat:@"%@", imgData.FileName];
        
        [imgDataLine enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            if ([(NSString*)obj isEqualTo:@""]) return;
            
            NSString* content = [(NSString*)obj componentsSeparatedByString:@":"][1];
            contentDataLine = [contentDataLine stringByAppendingString:
                                [NSString stringWithFormat:@",%@", content]];
        }];
        
        contentDataLine = [contentDataLine stringByAppendingString:@"\n"];
        [wHandle writeData:[contentDataLine dataUsingEncoding:NSUTF8StringEncoding]];

    }];
    
}

- (IBAction)exportToCsv:(id)sender{

    NSLog(@"Export To CSV\n");
    
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:NO];
    [panel setMessage:@"Select Save Directory"];
    [panel beginWithCompletionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            
            NSLog(@"select dic : %@", [[panel URL] path]);
            
            NSString* savePath = @"/EXIF";
            
            [self makeCSVFileWithImageData:exifInfoArray.selectedObjects
                             SaveDirectory:[[panel URL] path]
                                  SaveFileName:savePath];

            [[NSWorkspace sharedWorkspace] openFile:[[panel URL] path]
                                    withApplication:@"Finder.app"];
        }
    }];
    
}

- (IBAction)testBtn:(id)sender{
    
    
//    [makeField insertText:@"HEllo"];
    //s[makeField updateLayer];
//    [makeField becomeFirstResponder];

//    [makeBtn becomeFirstResponder];
    
    
//    NSString* selecModel = [exifInfoArray valueForKeyPath:@"selection.model"];
//    NSLog(@"What : %@", selecModel);
//    
//    NSObjectController* a = [exifInfoArray selection];
//    NSLog(@"proxy : %@", a);
//
//    
//    NSArray* object = [exifInfoArray selectedObjects];
//
//    [object enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        NSLog(@"------------");
//        ImageData* imageData = (ImageData*)obj;
//        NSLog(@"%@", [imageData FileName]);
    
//        EExifInfoData* exifInfoData = (EExifInfoData*) obj;
//        NSLog(@"%@", exifInfoData.fileName);
//        NSLog(@"%@", exifInfoData.brand);
//        NSLog(@"%@", exifInfoData.model);
//        NSLog(@"------------");
//        NSLog(@"->%@", selecModel);

//    }];

    //
//    NSArray* testArr = [exifInfoArray exposedBindings];
//    [testArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        NSLog(@"%@", obj);
//    }];

//    NSArray* te = [exifInfoArray arrangedObjects];

//    [exifInfoArray filterPredicate];
//    NSLog(@"%@", te);
//    [te filteredArrayUsingPredicate:<#(NSPredicate *)#>];
//    [te enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        EExifInfoData* data = (EExifInfoData*)obj;
//        NSLog(@"%@", data.fileName);
//    }];
    
//    NSPredicate *predicate = [NSPredicate
//                              predicateWithFormat:@"(lastName like[cd] %@) AND (birthday > %@)",
//                              lastNameSearchString, birthdaySearchDate];

    

//    NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
//    NSLog(@"%@", systemTimeZone);
////    [systemTimeZone name];
//    NSLog(@"Wow > %@", [systemTimeZone name]);
//    
//    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
//    [formatter setTimeZone:systemTimeZone];
//    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    
//    [NSDate allocWithZone:(struct _NSZone *)];
//    NSLog(@"Seconds > %@", [systemTimeZone ]);
    
//    [systemTimeZone secondsFromGMT]
    
    //    [systemTimeZone localizedKey]
    
//    NSArray *timeZoneNames = [NSTimeZone knownTimeZoneNames];
//    for (NSString* i in timeZoneNames) {
//        NSLog(@"%@", i);
//    }
//    [NSTimeZone tim]
//    int pos = (int)[exifInfoArray valueForKeyPath:@"selection.ffdbStart"];
//    NSLog(@"pos %x", pos);
    
//    ImageData* selecImg = [exifInfoArray valueForKeyPath:@"selection"];

//    ImageData* selecImg = (ImageData*)[exifInfoArray selectedObjects][0];
    
    
//    NSArray* selectedImg = [exifInfoArray selectedObjects];
//    
//    for(ImageData* img in selectedImg){
//    
//        EExifWriter* exifWrite = [[EExifWriter alloc] init];
//        [exifWrite writeImageData:img];
//    }
    
//    NSLog(@"fileName : %@", [selecImg fileName]);
    
}


-(void) displayFileSelectState:(unsigned long)currentSelect total:(unsigned long)total{

    NSString* state = [NSString stringWithFormat:@"%lu / %lu", currentSelect, total];

    [listFileCntState setStringValue:state];
}

- (IBAction)removeJPGinList:(id)sender{
    
    [exifInfoArray removeObjectsAtArrangedObjectIndexes:[exifInfoArray selectionIndexes]];

}

@end







