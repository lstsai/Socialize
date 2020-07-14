//
//  Event.m
//  Sprout
//
//  Created by laurentsai on 7/14/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "Event.h"

@implementation Event

@dynamic postID;
@dynamic userID;
@dynamic author;
@dynamic name;
@dynamic details;
@dynamic location;
@dynamic image;
@dynamic createdAt;
@dynamic time;

+ (nonnull NSString *)parseClassName {
    return @"Event";
}
+ (void) postEvent:(UIImage * _Nullable )image withName:(NSString *)name withTime:(NSDate*)time withLocation:(NSString*)location withDetails:(NSString*)details withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    Event *newEvent= [Event new];
    newEvent.name=name;
    newEvent.image= [self getPFFileFromImage:image withName:name];
    newEvent.details=details;
    newEvent.author=[PFUser currentUser];
    newEvent.location=location;
    newEvent.time=time;
    [newEvent saveInBackgroundWithBlock:completion];
}
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image withName:(NSString*)eventName {
    if(image)//no image
    {
        NSData *imageData = UIImagePNGRepresentation(image);
        NSString* fileName=[eventName stringByAppendingString:@".png"];
        if(imageData)
            return [PFFileObject fileObjectWithName:fileName data:imageData];
    }
    
    return nil;//if image data or image is nil
}
@end
