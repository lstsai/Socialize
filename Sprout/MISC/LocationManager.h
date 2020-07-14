//
//  LocationManager.h
//  Sprout
//
//  Created by laurentsai on 7/14/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Constants.h"
@interface LocationManager : NSObject <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    CLGeocoder *geoCoder;
    CLPlacemark *currentPlacemark;
}

@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) CLGeocoder *geoCoder;
@property (nonatomic, retain) CLPlacemark *currentPlacemark;

+ (LocationManager *)sharedInstance;
- (void)start;
- (void)stop;
- (void)getLocalPlaces:(NSString*)searchTerm completion:(void(^)(NSArray *mapItems, NSError *error))completion;

@end