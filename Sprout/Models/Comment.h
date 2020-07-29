//
//  Comment.h
//  Sprout
//
//  Created by laurentsai on 7/29/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//
/*
 Object to represent a comment for the group page
 */
#import <Parse/Parse.h>
#import "Post.h"
NS_ASSUME_NONNULL_BEGIN

@interface Comment : PFObject<PFSubclassing>
    @property (nonatomic, strong) NSString *commentID;
    @property (nonatomic, strong) PFUser *author;
    @property (nonatomic, strong) NSString *commentText;
    @property (nonatomic, strong) NSDate *createdAt;
    @property (nonatomic, strong) Post *post;


+ (void) postComment:( NSString * _Nullable )comment forPost:(Post*) post withCompletion: (PFBooleanResultBlock  _Nullable)completion;
@end

NS_ASSUME_NONNULL_END
