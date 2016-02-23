//
//  EEAppDelegate.m
//  ExifEditor_0510
//
//  Created by HeoChan Soon on 2014. 5. 10..
//  Copyright (c) 2014년 Hurderella. All rights reserved.
//

#import "EEAppDelegate.h"

@implementation EEAppDelegate

@synthesize exifLogicController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [exifLogicController preoperate];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return YES;
}

@end
