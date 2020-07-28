//
//  MapViewController.m
//  Sprout
//
//  Created by laurentsai on 7/28/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "MapViewController.h"
#import "Constants.h"
@interface MapViewController ()

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpMap];
}
/**
Instantiates the map view to show the given location with a marker
*/
-(void) setUpMap{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.coords.latitude longitude:self.coords.longitude zoom:MAP_ZOOM];
    self.mapView.camera=camera;
    GMSMarker* marker= [GMSMarker markerWithPosition:self.coords];
    marker.title=self.name;
    marker.map=self.mapView;
}
/**
 Triggered when the user taps the cancel button. Dismisses the map view controller
 @param[in] sender the button that was tapped
 */
- (IBAction)didTapCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
