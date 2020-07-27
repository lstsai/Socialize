//
//  Event.m
//  Sprout
//
//  Created by laurentsai on 7/14/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "Event.h"
#import "Post.h"
#import "Helper.h"

@implementation Event

@dynamic postID;
@dynamic userID;
@dynamic author;
@dynamic name;
@dynamic details;
@dynamic location;
@dynamic streetAddress;
@dynamic image;
@dynamic createdAt;
@dynamic startTime;
@dynamic endTime;
@dynamic numFriendsLike;
/**
Returns the class name for the Event object in parse
@return the class name
*/
+ (nonnull NSString *)parseClassName {
    return @"Event";
}
/**
Creates a an event object to be saved in to Parse
@param[in] image the image associated with the event
@param[in] name name of event
@param[in] stime start time of event
@param[in] etime end time of event
@param[in] location location of the event (geopoint)
@param[in] streetAddress The string version of the location
@param[in] details details about the event
@param[in] completion the block to be called when the event is finised being saved
*/
+ (void) postEvent:(UIImage * _Nullable )image withName:(NSString *)name withSTime:(NSDate*)stime withETime:(NSDate*)etime withLocation:(PFGeoPoint*)location withStreetAdress:(NSString*)streetAddress withDetails:(NSString*)details withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    Event *newEvent= [Event new];
    newEvent.name=name;
    newEvent.image= [Helper getPFFileFromImage:image withName:name];
    newEvent.details=details;
    newEvent.author=[PFUser currentUser];
    newEvent.location=location;
    newEvent.startTime=stime;
    newEvent.endTime=etime;
    newEvent.streetAddress=streetAddress;
    [newEvent saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded)
            [Post createPost:nil withDescription:@"Created an event" withEvent:newEvent withOrg:nil withCompletion:completion];
    }];
}

@end
