//
//  Helper.m
//  Sprout
//
//  Created by laurentsai on 7/21/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "Helper.h"

@implementation Helper
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image withName:(NSString*)imageName {
    if(image)//no image
    {
        NSData *imageData = UIImagePNGRepresentation(image);
        imageName=[imageName stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString* fileName=[imageName stringByAppendingString:@".png"];
        if(imageData)
            return [PFFileObject fileObjectWithName:fileName data:imageData];
    }
    
    return nil;//if image data or image is nil
}
+ (void) getFriends:(void(^)(NSArray *friends, NSError *error))completion{
    PFQuery *selfAccessQ= [PFQuery queryWithClassName:@"UserAccessible"];
    [selfAccessQ whereKey:@"username" equalTo:PFUser.currentUser.username];
    PFObject *friendAccess=[selfAccessQ getFirstObject];
    NSArray *friendList=friendAccess[@"friends"];
    PFQuery *friendQuery = [PFQuery queryWithClassName:@"_User"];
    [friendQuery whereKey:@"objectId" containedIn:friendList];
    [friendQuery includeKey:@"friendAccessible"];
    [friendQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(error)
            completion(nil, error);
        else
            completion(objects, nil);
    }];
    
}
@end
