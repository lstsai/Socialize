
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
@dynamic relatedObject;
@dynamic image;
@dynamic createdAt;


+ (nonnull NSString *)parseClassName {
    return @"Post";
}
+ (void) createPost:(UIImage * _Nullable )image withDescription:(NSString *)description withRelatedObject:(PFObject*)relatedObject withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    Post *newPost= [Post new];
    newPost.author=PFUser.currentUser;
    newPost.image=[Helper getPFFileFromImage:image withName:@"postImage"];
    newPost.postDescription=description;
    newPost.relatedObject=relatedObject;
    [newPost saveInBackgroundWithBlock:completion];
}

@end
