//
//  MapViewController.h
//  Sprout
//
//  Created by laurentsai on 7/28/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@import GoogleMaps;
NS_ASSUME_NONNULL_BEGIN

@interface MapViewController : UIViewController
@property (nonatomic) CLLocationCoordinate2D coords;
@property (nonatomic) NSString* name;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
-(void) setUpMap;
@end

NS_ASSUME_NONNULL_END
