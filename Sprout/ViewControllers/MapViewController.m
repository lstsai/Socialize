//
//  MapViewController.m
//  Sprout
//
//  Created by laurentsai on 7/28/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "MapViewController.h"
#import "Constants.h"
#import "Event.h"
#import "Organization.h"
#import <Parse/Parse.h>
#import "APIManager.h"
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
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:CAMERA_LAT longitude:CAMERA_LNG zoom:MAP_ZOOM/5];
    [self.mapView setMinZoom:MAP_ZOOM/5 maxZoom:MAP_ZOOM];
    self.mapView.camera=camera;
    NSMutableArray* markers=[NSMutableArray new];

    if([[self.objects firstObject] isKindOfClass:[Event class]])
    {
        for(Event* event in self.objects)
        {
            GMSMarker* marker= [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(event.location.latitude, event.location.longitude)];
            marker.title=event.name;
            marker.map=self.mapView;
            [markers addObject:marker];
        }
        [self updateCameraPositionWithMarkers:markers];
    }
    else
    {
        for(Organization* org in self.objects)
        {
            [[APIManager shared] getCoordsFromAddress:[org.location streetAddress] completion:^(CLLocationCoordinate2D coords, NSError * _Nullable error) {
                GMSMarker* marker= [GMSMarker markerWithPosition:coords];
                marker.title=org.name;
                marker.map=self.mapView;
                [markers addObject:marker];
                if([org isEqual:[self.objects lastObject]])
                    [self updateCameraPositionWithMarkers:markers];
            }];
        }
    }

}
-(void) updateCameraPositionWithMarkers:(NSArray*) markers{
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] init];
    for (GMSMarker *marker in markers)
        bounds = [bounds includingCoordinate:marker.position];
    [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds]];
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
