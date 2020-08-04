//
//  Helper.h
//  Sprout
//
//  Created by laurentsai on 7/21/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

/*
 File for all the helper methods of the program
 */

#import <Parse/Parse.h>
#import "Post.h"
#import "Organization.h"
#import "Event.h"
#import "ProfileViewController.h"
#import "ClaimedOrganization.h"
NS_ASSUME_NONNULL_BEGIN

@interface Helper : NSObject
@property (strong, nonatomic) ProfileViewController* currProfVC;
+ (instancetype)shared;
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image withName:(NSString*)imageName;
+ (void) getFriends:(void(^)(NSArray *friends, NSError *error))completion;
+ (PFObject *) getUserAccess:(PFUser*) user;

+ (void)didLikeOrg:(Organization*)likedOrg sender:(UIViewController* _Nullable)viewC;
+ (void)didUnlikeOrg:(Organization*)unlikedOrg;

+ (void) didLikeEvent:(Event*)likedEvent senderVC:(UIViewController* _Nullable)viewC;
+ (void)didUnlikeEvent:(Event*)unlikedEvent;

+ (void) addObjectToFriendsList:(NSArray*)keys;
+ (void) deleteObjectFromFriendsList:(NSArray*)keys;

+ (void)displayAlert:(NSString*)title withMessage:(NSString*)message on:(UIViewController * _Nullable)senderVC;

+ (void)deleteFriendLikes:(NSArray*)users;
+ (void)addFriendLikes:(NSArray*)users;
+ (void)addFriend:(PFUser*) from toFriend:(PFUser*) to;
+ (void)removeFriend:(PFUser*) from toFriend:(PFUser*) to;
+ (void)removeRequest:(PFUser*) current forUser:(PFUser*) requester;
+ (void) addRequest:(PFUser *) current forUser:(PFUser *)requested;

+ (void) updateMessageOrder:(PFUser *)toUser;
+ (void) addUnreadMessage:(PFUser*) reciever;
+ (void) removeUnreadMessage:(PFUser*) sender;

+ (BOOL)connectedToInternet;
+ (void) getClaimedOrgFromEin:(NSString*) ein withCompletion:(void(^)(PFObject *claimedOrg))completion;
+ (void) addUserToSeenClaimedOrgList:(ClaimedOrganization*)claimedOrg;
+ (void) getClaimedOrgSeenUsers:(ClaimedOrganization*)claimedOrg withCompletion:(void(^)(NSArray *users, NSError *error))completion;
@end

NS_ASSUME_NONNULL_END
