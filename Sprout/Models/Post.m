
//
//  Post.m
//  Sprout
//
//  Created by laurentsai on 7/21/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "Post.h"

@implementation Post
@dynamic postID;
@dynamic author;
@dynamic postDescription;
@dynamic event;
@dynamic image;
@dynamic createdAt;
@dynamic org;

+ (nonnull NSString *)parseClassName {
    return @"Post";
}
+ (void) createPost:(UIImage * _Nullable )image withDescription:(NSString *)description withEvent:(Event* _Nullable)event withOrg:(Organization* _Nullable)org withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    Post *newPost= [Post new];
    newPost.author=PFUser.currentUser;
    newPost.image=[Helper getPFFileFromImage:image withName:@"postImage"];
    newPost.postDescription=description;
    newPost.event=event;
    if(org)
    {
        
        newPost.org=[Organization dictionaryWithOrg:org];
    }
    [newPost saveInBackgroundWithBlock:completion];
}

@end
