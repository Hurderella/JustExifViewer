//
//  EEMapController.m
//  JustExifViewer
//
//  Created by Hurderella on 2016. 2. 10..
//  Copyright © 2016년 Hurderella. All rights reserved.
//

#import "EEMapController.h"

@implementation EEMapController

- (void) initCenter:(EExifInfoArray*) arr{

    NSLog(@"!!!init Center Cur : %f, %f", mkMapView.centerCoordinate.latitude,
          mkMapView.centerCoordinate.longitude);
    
//    CLLocationCoordinate2D settingVal = {37.265310f, 127.040785f};
//    mkMapView.centerCoordinate = settingVal;

//    MKCoordinateRegion region;
//    region.center.latitude = 37.265310f;
//    region.center.longitude = 127.040785f;
//    region.span.latitudeDelta = 0.1f;
//    region.span.longitudeDelta = 0.1f;
//    
//    [mkMapView setRegion:region];

    [mkMapView addAnnotations:[arr arrangedObjects]];

}
@end
