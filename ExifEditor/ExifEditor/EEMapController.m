//
//  EEMapController.m
//  JustExifViewer
//
//  Created by Hurderella on 2016. 2. 10..
//  Copyright © 2016년 Hurderella. All rights reserved.
//

#import "EEMapController.h"
#import "ImageData.h"

@implementation EEMapController

- (void) initNode:(EExifInfoArray*) arr{

    annotationData = arr;    
    
}

- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary<NSString *,id> *)change
                        context:(void *)context{
    NSLog(@"map cont OBSERVE!!!!!!!");
    if ([object isEqual:annotationData]) {
        NSLog(@"catch!! observer!!!");
        NSArray* arr = [annotationData arrangedObjects];
        __block NSMutableArray* validAnnotations = [[NSMutableArray alloc] init];
        
        [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj,
                                          NSUInteger idx,
                                          BOOL * _Nonnull stop) {

            ImageData* imgData = (ImageData*)obj;
            if (CLLocationCoordinate2DIsValid(imgData.coordinate)){
                [validAnnotations addObject:imgData];
            }
        }];
        
        [mkMapView removeAnnotations:validAnnotations];
        [mkMapView addAnnotations:validAnnotations];

        ImageData* lastObj = ((ImageData*)[validAnnotations lastObject]);
        
        MKCoordinateRegion region;
        region.center = lastObj.coordinate;
        region.span.latitudeDelta = 1.0f;
        region.span.longitudeDelta = 1.0f;
        [mkMapView setRegion:region];
        
    }
    

}

@end




