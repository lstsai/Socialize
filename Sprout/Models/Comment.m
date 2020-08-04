//
//  Comment.m
//  Sprout
//
//  Created by laurentsai on 7/29/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "Comment.h"

@implementation Comment
@dynamic commentID;
@dynamic author;
@dynamic commentText;
@dynamic createdAt;
@dynamic post;
/**
 Returns the name of the class in parse
 */
+ (nonnull NSString *)parseClassName {
    return @"Comment";
}
/**
Creates and saves a comment in parse.
 @param[in] comment the string for the comment text
 @param[in] post the post associated with the comment
 @param[in] completion the completion block to be executed when the comment is posted
 */
+ (void) postComment:( NSString * _Nullable )comment forPost:(Post*) post withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    //create post with given info
    Comment *newComment= [Comment new];
    newComment.commentText= comment;
    newComment.author=[PFUser currentUser];
    newComment.post= post;
    [newComment saveEventually:completion];
}

@end

