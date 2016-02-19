//
//  EEAddableClipView.m
//  JustExifViewer
//
//  Created by Hurderella on 2015. 4. 8..
//  Copyright (c) 2015년 Hurderella. All rights reserved.
//

#import "EEAddableClipView.h"

@implementation EEAddableClipView

@synthesize AddFileList;

- (id) initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    NSLog(@"initWithCoder");
    AddFileList = [[NSMutableArray alloc] init];
    [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
    return self;
}


- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        if (sourceDragMask & NSDragOperationCopy) {
            NSArray* items = [pboard propertyListForType:NSFilenamesPboardType];
            //[pboard pasteboardItems];
            
            [AddFileList removeAllObjects];
            [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString* str = obj;
                NSLog(@"i : %@", str);
                [AddFileList addObject:str];
            
            }];
            
            return NSDragOperationCopy;
        }
    }
    return NSDragOperationNone;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender {
    NSLog(@"draggingExited:");
    
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender {
    NSLog(@"prepare DragOper");
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSLog(@"perform Drag");
    return YES;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender {
    NSLog(@"concludeDragOperation:");
    NSLog(@"AddFileList : %@", AddFileList);
    [self willChangeValueForKey:@"AddFileList"];
    [self didChangeValueForKey:@"AddFileList"];
}


@end
