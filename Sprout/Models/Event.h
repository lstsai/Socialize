//
//  Event.h
//  Sprout
//
//  Created by laurentsai on 7/14/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <Parse/Parse.h>
NS_ASSUME_NONNULL_BEGIN

@interface Event : PFObject <PFSubclassing>
    @property (nonatomic, strong) NSString *postID;
    @property (nonatomic, strong) NSString *userID;
    @property (nonatomic, strong) PFUser *author;
    @property (nonatomic, strong) NSString *name;
    @property (nonatomic, strong) NSString *details;
    @property (nonatomic, strong) NSString *location;
    @property (nonatomic, strong) PFFileObject *image;
    @property (nonatomic, strong) NSDate *createdAt;
    @property (nonatomic, strong) NSDate *time;

+ (void) postEvent:(UIImage * _Nullable )image withName:(NSString *)name withTime:(NSDate*)time withLocation:(NSString*)location withDetails:(NSString*)details withCompletion: (PFBooleanResultBlock  _Nullable)completion;
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image withName:(NSString*)eventName;

    @end

NS_ASSUME_NONNULL_END
