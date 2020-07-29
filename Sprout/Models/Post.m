
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
@dynamic groupPost;
/**
Returns the class name for the Event object in parse
@return the class name
*/
+ (nonnull NSString *)parseClassName {
    return @"Post";
}
/**
Creates a a Post object to be saved in to Parse
@param[in] image the image associated with the Post
@param[in] description decription/caption of the post
@param[in] event associated event (if applicable)
@param[in] org associated organization (if applicable)
@param[in] completion the block to be called when the event is finised being saved
*/
+ (void) createPost:(UIImage * _Nullable )image withDescription:(NSString *)description withEvent:(Event* _Nullable)event withOrg:(NSObject* _Nullable)org groupPost:(BOOL)groupPost withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    Post *newPost= [Post new];
    newPost.author=PFUser.currentUser;
    newPost.image=[Helper getPFFileFromImage:image withName:@"postImage"];
    newPost.postDescription=description;
    newPost.event=event;
    newPost.groupPost=groupPost;
    if(org)
    {
        newPost.org=[Organization dictionaryWithOrg:org];
    }
    [newPost saveInBackgroundWithBlock:completion];
}

@end
