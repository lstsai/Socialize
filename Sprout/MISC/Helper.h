//
//  Helper.h
//  Sprout
//
//  Created by laurentsai on 7/21/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Helper : PFObject
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image withName:(NSString*)imageName;
+ (void) getFriends:(void(^)(NSArray *friends, NSError *error))completion;
@end

NS_ASSUME_NONNULL_END
