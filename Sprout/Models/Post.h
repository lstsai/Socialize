//
//  Post.h
//  Sprout
//
//  Created by laurentsai on 7/21/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Post : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) PFUser *author;
@property (nonatomic, strong) NSString *postDescription;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) PFObject *relatedObject;
@property (nonatomic, strong) PFFileObject *image;


+ (void) createPost:(UIImage * _Nullable )image withDescription:(NSString *)description withRelatedObject:(PFObject*)relatedObject withCompletion: (PFBooleanResultBlock  _Nullable)completion;
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image;

@end

NS_ASSUME_NONNULL_END
