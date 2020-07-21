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
    @property (nonatomic, strong) PFGeoPoint *location;
    @property (nonatomic, strong) NSString *streetAddress;
    @property (nonatomic, strong) PFFileObject *image;
    @property (nonatomic, strong) NSDate *createdAt;
    @property (nonatomic, strong) NSDate *startTime;
    @property (nonatomic, strong) NSDate *endTime;
    @property (nonatomic) NSInteger numFriendsLike;

+ (void) postEvent:(UIImage * _Nullable )image withName:(NSString *)name withSTime:(NSDate*)stime withETime:(NSDate*)etime withLocation:(PFGeoPoint*)location withStreetAdress:(NSString*)streetAddress withDetails:(NSString*)details withCompletion: (PFBooleanResultBlock  _Nullable)completion;
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image withName:(NSString*)eventName;

    @end

NS_ASSUME_NONNULL_END
