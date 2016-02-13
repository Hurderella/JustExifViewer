//
//  EEMapWindowController.m
//  JustExifViewer
//
//  Created by Hurderella on 2016. 2. 10..
//  Copyright © 2016년 Hurderella. All rights reserved.
//

#import "EEMapWindowController.h"

@interface EEMapWindowController ()

@end

@implementation EEMapWindowController

@synthesize mapContorller;
@synthesize annotationData;

- (void)windowDidLoad {

    [super windowDidLoad];
    
    if(mapContorller != nil && annotationData != nil) {

        [mapContorller initNode:annotationData];
        [annotationData addObserver:mapContorller
                         forKeyPath:@"arrangedObjects"
                            options:NSKeyValueObservingOptionInitial
                            context:nil];
    }
    
}


@end
