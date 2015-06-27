//
//  EEAddableClipView.h
//  JustExifViewer
//
//  Created by Hurderella on 2015. 4. 8..
//  Copyright (c) 2015년 Hurderella. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EEAddableClipView : NSClipView{

    NSMutableArray* AddFileList;
}

- (id) initWithCoder:(NSCoder *)coder;

@property (readwrite, strong) NSMutableArray* AddFileList;
@end
