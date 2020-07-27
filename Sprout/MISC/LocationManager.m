//
//  LocationManager.m
//  Sprout
//
//  Created by laurentsai on 7/14/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "LocationManager.h"

@implementation LocationManager

@synthesize currentLocation;
@synthesize geoCoder;
@synthesize currentPlacemark;

//initialize a shared manager for all the view controllers to access.
static LocationManager *sharedManager;

+ (LocationManager *)sharedInstance {
  
  static dispatch_once_t pred;
  
  dispatch_once(&pred, ^{
    sharedManager = [[LocationManager alloc] init];
  });

  return sharedManager;
}

- (id)init {
  
  self = [super init];
  
  if (self) {
    
    currentLocation = [[CLLocation alloc] init];
    geoCoder=[[CLGeocoder alloc] init];
    locationManager = [[CLLocationManager alloc] init];

    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLLocationAccuracyHundredMeters;
    [locationManager requestWhenInUseAuthorization];
    [self start];
  }
  
  return self;
}

#pragma mark - Public Methods
/**
 Start monitoring the user's location
 */
- (void)start {

  [locationManager startUpdatingLocation];

}
/**
Stop monitoring the user's location
*/
- (void)stop {

  [locationManager stopUpdatingLocation];
}

#pragma mark - Delegate Methods
/**
 Tells the delegate that new location data is available, Uses a geocoder to update the placemark variable (to get the human readable location data)
@param[in] manager The location manager object that generated the update event.
@param[in] locations An array of CLLocation objects containing the location data. The most recent location update is at the end of the array.
*/
-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    self.currentLocation=[locations lastObject];

    [self.geoCoder reverseGeocodeLocation:self.currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if(placemarks)
        {
            self.currentPlacemark=[placemarks firstObject];
            //NSLog(@"Current loc %@", self.currentPlacemark.subThoroughfare);
        }
        else
            NSLog(@"Error geting location %@", error.localizedDescription);
    }];
}
@end
