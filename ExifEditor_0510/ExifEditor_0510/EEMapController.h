//
//  EEMapController.h
//  JustExifViewer
//
//  Created by Hurderella on 2016. 2. 10..
//  Copyright © 2016년 Hurderella. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "EExifInfoArray.h"

@interface EEMapController : NSObject <MKMapViewDelegate>{

    IBOutlet MKMapView* mkMapView;
}

- (void) initCenter:(EExifInfoArray*) arr;

@end
