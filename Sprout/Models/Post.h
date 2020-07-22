//
//  Post.h
//  Sprout
//
//  Created by laurentsai on 7/21/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <Parse/Parse.h>
#import "Helper.h"
#import "Event.h"
#import "Organization.h"
NS_ASSUME_NONNULL_BEGIN

@interface Post : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) PFUser *author;
@property (nonatomic, strong) NSString *postDescription;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) NSObject* org;
@property (nonatomic, strong) PFFileObject *image;


+ (void) createPost:(UIImage * _Nullable )image withDescription:(NSString *)description withEvent:(Event* _Nullable)event withOrg:(NSObject* _Nullable)org withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
