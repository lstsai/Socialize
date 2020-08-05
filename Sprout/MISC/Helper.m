//
//  Helper.m
//  Sprout
//
//  Created by laurentsai on 7/21/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "Helper.h"
#import <UIKit/UIKit.h>
#import "Reachability.h"

@implementation Helper
+ (instancetype)shared
{
    static Helper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Helper alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}
/**
 Converts an UIImage to a PFFileObject in order to be stored in Parse
 @param[in] image The image to be convered into a file
 @param[in] imageName The image name for the file
 @return the image data as a PFFileObject
*/
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image withName:(NSString*)imageName {
    if(image)
    {
        NSData *imageData = UIImagePNGRepresentation(image);
        imageName=[imageName stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString* fileName=[imageName stringByAppendingString:@".png"];
        if(imageData)
            return [PFFileObject fileObjectWithName:fileName data:imageData];
    }
    
    return nil;//if image data or image is nil
}
/**
 Get the UserAccessible Object for the specified User.
 
 More info: The UserAccessible class is an object that each user has a pointer to. Since
 parse does not let users modify other users' data, this pointer allows friends to
 add to or delete from the the liked orgs/events list, and the friends list, without
 actually modifying the user object.
 
 @param[in] user The user whose UserAccessible object to retrieve
 @return The UserAccessible object for the user.
*/
+ (PFObject *) getUserAccess:(PFUser*) user{

    PFQuery *accessQ= [PFQuery queryWithClassName:@"UserAccessible"];
    if(![Helper connectedToInternet])
        [accessQ fromLocalDatastore];
    [accessQ whereKey:@"username" equalTo:user.username];
    [[accessQ getFirstObject] pinInBackgroundWithName:@"UserAccessible"];
    return [accessQ getFirstObject];
}
/**
 Get the Friends array for current user,
 @param[in] completion the block to be called when finished fetching the objects.
 returns an array of PFUsers which are the user's friends if retrieved, or return an error
*/
+ (void) getFriends:(void(^)(NSArray *friends, NSError *error))completion{
    
    PFObject *friendAccess=[Helper getUserAccess:PFUser.currentUser];
    NSArray *friendList=friendAccess[@"friends"];
    PFQuery *friendQuery = [PFQuery queryWithClassName:@"_User"];
    if(! [Helper connectedToInternet])
        [friendQuery fromLocalDatastore];
    [friendQuery whereKey:@"objectId" containedIn:friendList];
    [friendQuery includeKey:@"friendAccessible"];
    [friendQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(error)
            completion(nil, error);
        else{
            for(PFUser* friend in objects)
            {
                [friend[@"friendAccessible"] pinInBackground];
            }
            [PFObject unpinAllObjectsWithName:@"Friends"];
            [PFObject pinAllInBackground:objects withName:@"Friends"];
            completion(objects, nil);
        }
    }];
    
}
/**
 Called when the user has liked an organization from any view controller.
 Adds the liked organization to the user's 'likedOrgs' in parse. Then calls
 the addObjectToFriendsList: method in the background to update thier
 friends's list. Also creates a post to signal the user has liked this org
 @param[in] likedOrg the organization that was liked
 @param[in] viewC the view controller that called this method

 */
+ (void)didLikeOrg:(Organization*)likedOrg sender:(UIViewController* _Nullable)viewC{
    NSMutableArray *likedOrgs= [PFUser.currentUser[@"likedOrgs"] mutableCopy];
    [likedOrgs addObject:likedOrg.ein];
    [Helper performSelectorInBackground:@selector(addObjectToFriendsList:) withObject:@[likedOrg.ein, @"friendOrgs"]];//add to list in background
    PFUser.currentUser[@"likedOrgs"]=likedOrgs;
    [PFUser.currentUser pinInBackground];
    [PFUser.currentUser saveEventually];
    [[Helper shared].currProfVC performSelectorInBackground:@selector(getLikedOrgInfo) withObject:nil];
    [Post createPostWithDescription:@"Liked an Organization" withEvent:nil withOrg:likedOrg groupPost:NO withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if(error)
            [Helper displayAlert:@"Error Posting" withMessage:error.localizedDescription on:viewC];
    }];
}
/**
Called when the user has unlied an organization from any view controller.
Removes the unliked organization to the user's 'likedOrgs' in parse. Then calls
the deleteObjectToFriendsList: method in the background to update thier
friends's list.
@param[in] unlikedOrg the organization that was liked

*/
+ (void)didUnlikeOrg:(Organization*)unlikedOrg{
    NSMutableArray *likedOrgs= [PFUser.currentUser[@"likedOrgs"] mutableCopy];

    [likedOrgs removeObject:unlikedOrg.ein];
    [Helper performSelectorInBackground:@selector(deleteObjectFromFriendsList:) withObject:@[unlikedOrg.ein, @"friendOrgs"]];//add to list in background
    PFUser.currentUser[@"likedOrgs"]=likedOrgs;
    [PFUser.currentUser pinInBackground];
    [PFUser.currentUser saveEventually];
    [[Helper shared].currProfVC performSelectorInBackground:@selector(getLikedOrgInfo) withObject:nil];
}
/**
Called when the user has liked an event from any view controller.
Adds the liked event to the user's 'likedEvents' in parse. Then calls
the addObjectToFriendsList: method in the background to update thier
friends's list. Also creates a post to signal the user has liked this event
@param[in] likedEvent the event that was liked
@param[in] viewC the view controller that called this method

*/
+(void) didLikeEvent:(Event*)likedEvent senderVC:(UIViewController* _Nullable)viewC{
    NSMutableArray *likedEvents= [PFUser.currentUser[@"likedEvents"] mutableCopy];
    
    [likedEvents addObject:likedEvent.objectId];
    [Helper performSelectorInBackground:@selector(addObjectToFriendsList:) withObject:@[likedEvent.objectId, @"friendEvents"]];

    PFUser.currentUser[@"likedEvents"]=likedEvents;
    [PFUser.currentUser pinInBackground];
    [PFUser.currentUser saveEventually];
    [[Helper shared].currProfVC performSelectorInBackground:@selector(getLikedEventInfo) withObject:nil];
    [Post createPostWithDescription:@"Liked an Event" withEvent:likedEvent withOrg:nil groupPost:NO withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
           if(error)
           [Helper displayAlert:@"Error Posting" withMessage:error.localizedDescription on:viewC];
       }];
}
/**
Called when the user has unlied an event from any view controller.
Removes the unliked event to the user's 'likedEvent' in parse. Then calls
the deleteObjectToFriendsList: method in the background to update thier
friends's list.
@param[in] unlikedEvent the organization that was liked

*/
+ (void)didUnlikeEvent:(Event*)unlikedEvent{
    NSMutableArray *likedEvents= [PFUser.currentUser[@"likedEvents"] mutableCopy];

    [likedEvents removeObject:unlikedEvent.objectId];
    [self performSelectorInBackground:@selector(deleteObjectFromFriendsList:) withObject:@[unlikedEvent.objectId, @"friendEvents"]];
    
    PFUser.currentUser[@"likedEvents"]=likedEvents;
    [PFUser.currentUser pinInBackground];
    [PFUser.currentUser saveEventually];
    [[Helper shared].currProfVC performSelectorInBackground:@selector(getLikedEventInfo) withObject:nil];
}
/**
This method adds the liked org/event to every friend's list. The objKey is the identifier
for a specific liked object, and the listName is the dictionary the liked object should be
added to. In order for parse to 'save' an object, it needs to detect a change in that object,
which is why there are  many variables. These are reassigned to the object at the very end
so that Parse will actually save this change.
@param[in] keys the Array of parameters. Since to perfrom methods in background there can only be at most one param.
 the first object in keys is the name object to be added to the list
 the second object in keys is the name of the attribute in parse to be changed

*/
+ (void) addObjectToFriendsList:(NSArray*)keys{
    
    NSString *objKey=keys.firstObject;
    NSString *listName=keys.lastObject;
    [Helper getFriends:^(NSArray * _Nonnull friends, NSError * _Nonnull error) {
           for(PFObject* friend in friends)//get the array of friends for current user
           {
               //if the friend alreay has other friends that like this org
               PFObject * friendAccess=friend[@"friendAccessible"];
               if(friendAccess[listName][objKey])
               {
                   //get the dictionary of objects
                   NSMutableDictionary *friendObj=[friendAccess[listName] mutableCopy];
                   
                   //get the array of friends that have liked this for this obj and add self
                   NSMutableArray* list= [friendObj[objKey] mutableCopy];
                   [list addObject:PFUser.currentUser.username];
                   
                   //set the array to the key
                   friendObj[objKey]=list;
                   //assign dictionary to attribute so parse detects change
                   friendAccess[listName]= friendObj;
               }
               else
               {
                   //create that array for the obj and add self as the person who liked it
                   NSMutableDictionary *friendObj=[friendAccess[listName] mutableCopy];
                   friendObj[objKey]=@[PFUser.currentUser.username];
                   friendAccess[listName]= friendObj;
               }
               //save each friend
               [friendAccess saveEventually];
           }
       }];
}
/**
This method deletes the liked org/event to every friend's list. The objKey is the identifier
for a specific liked object, and the listName is the dictionary the liked object should be
added to. In order for parse to 'save' an object, it needs to detect a change in that object,
which is why there are  many variables. These are reassigned to the object at the very end
so that Parse will actually save this change.
@param[in] keys the Array of parameters. Since to perfrom methods in background there can only be at most one param.
 the first object in keys is the name object to be removed from the list
 the second object in keys is the name of the attribute in parse to be changed

*/
+ (void) deleteObjectFromFriendsList:(NSArray*)keys{
    NSString *objKey=keys.firstObject;
    NSString *listName=keys.lastObject;
    [Helper getFriends:^(NSArray * _Nonnull friends, NSError * _Nonnull error) {
        for(PFObject* friend in friends)//get the array of friends for current user
        {
            //if the friend alreay has other friends that like this org
            PFObject * friendAccess=friend[@"friendAccessible"];
            if(friendAccess[listName][objKey])
            {
                //get the dictionary of orgs
                NSMutableDictionary *friendObj=[friendAccess[listName] mutableCopy];
                
                //get the arry for this org and add
                NSMutableArray* list= [friendObj[objKey] mutableCopy];
                [list removeObject:PFUser.currentUser.username];
                   
                //set the list to the key
                friendObj[objKey]=list;
                //assign dictionary to attribute so parse detects change
                friendAccess[listName]= friendObj;
            }
               //save each friend
            [friendAccess saveEventually];
        }
    }];
}

/**
 Displays an UIAlertController on the specified view controller
@param[in] title the title of the alert to be displayed
 @param[in] message the message of the alert ot be displayed
 @param[in] senderVC the view controller to display the alert on
*/

+(void)displayAlert:(NSString*)title withMessage:(NSString*)message on:(UIViewController  * _Nullable)senderVC{
    if(senderVC)
    {
        UIAlertController* alert= [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //nothing
        }];
        [alert addAction:okAction];
        [senderVC presentViewController:alert animated:YES completion:nil];
    }
}
/**
 Displays an UIAlertController Action sheet on the specified view controller to ask image source
 @param[in] senderVC the view controller to display the alert on
*/
+ (void)displayImageActionSheetOn:(UIViewController * _Nullable)senderVC withSource:(UIImagePickerControllerSourceType*) sourceType{
    UIAlertController* imageAlert = [UIAlertController alertControllerWithTitle:@"Choose an Image Source"
                                   message:nil
                                   preferredStyle:UIAlertControllerStyleActionSheet];
     
    UIAlertAction* camera = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault
    handler:^(UIAlertAction * action) {
    }];
    UIAlertAction* library = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault
    handler:^(UIAlertAction * action) {
    }];

    [imageAlert addAction:camera];
    [imageAlert addAction:library];
    [senderVC presentViewController:imageAlert animated:YES completion:nil];
}


/**
 Adds a friend(user)  to the friend's array of a certain user. And calls the addFriendLikes: method to
 make sure the new friend's liked object are reflected in the user's UserAccessible object
 @param[in] from the user that is adding a friend
 @param[in] to the friend user to be added
*/
+ (void) addFriend:(PFUser*) from toFriend:(PFUser*) to{

    PFObject *friendsAccess= [Helper getUserAccess:from];
    NSMutableArray *friendsArray=friendsAccess[@"friends"];
    [friendsArray addObject:to.objectId];
    friendsAccess[@"friends"]=friendsArray;
    [friendsAccess saveEventually];
    
    [self performSelectorInBackground:@selector(addFriendLikes:) withObject:@[from, to]];
}
/**
 Removes a friend(user)  from the friend's array of a certain user. And calls the deleteFriendLikes: method to
 make sure the new friend's liked object are removed from the user's UserAccessible object
 @param[in] from the user that is removing a friend
 @param[in] to the friend user to be removed
*/
+ (void) removeFriend:(PFUser*) from toFriend:(PFUser*) to{
    
    PFObject *friendsAccess= [Helper getUserAccess:from];
    NSMutableArray *friendsArray=friendsAccess[@"friends"];
    [friendsArray removeObject:to.objectId];
    friendsAccess[@"friends"]=friendsArray;
    [friendsAccess saveEventually];
    [self performSelectorInBackground:@selector(deleteFriendLikes:) withObject:@[from, to]];

}
/**
 Adds a user's likes to the friend's UserAccessible object.
 @param[in] users  the users that are involved.
    the first user is the user whose UserAccessible Object is being modified, adding the second
    user's liked object to thier 'friendOrgs" or 'friendEvents' list.
*/
+ (void)addFriendLikes:(NSArray*)users{
    
    PFUser *fromUser= [users firstObject];
    PFUser *toUser=[users lastObject];
    PFQuery *selfAccessQ= [PFQuery queryWithClassName:@"UserAccessible"];
    [selfAccessQ whereKey:@"username" equalTo:fromUser.username];
    [selfAccessQ getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        PFObject* selfAccess=object;
        PFObject *friendLikes=selfAccess[@"friendOrgs"];
        //for each of the organizations that the friend has liked, add to the 'from' user's list
        for(NSString* ein in toUser[@"likedOrgs"])
        {
            if(friendLikes[ein])
            {
                NSMutableArray *list= [friendLikes[ein] mutableCopy];
                [list addObject:toUser.username];
                friendLikes[ein]=list;
            }
            else
            {
                friendLikes[ein]=@[toUser.username];
            }
        }
        selfAccess[@"friendOrgs"]=friendLikes;
        [selfAccess saveEventually];


        friendLikes=selfAccess[@"friendEvents"];
        //for each of the events that the friend has liked, add to the 'from' user's list
        for(NSString *eventId in toUser[@"likedEvents"])
        {
            if(friendLikes[eventId])
            {
                NSMutableArray *list= [friendLikes[eventId] mutableCopy];
                [list addObject:toUser.username];
                friendLikes[eventId]=list;
            }
            else
            {
                friendLikes[eventId]=@[toUser.username];
            }
        }
        selfAccess[@"friendEvents"]=friendLikes;
        [selfAccess saveEventually];
    
    }];
}
/**
 Delets a user's likes from the friend's UserAccessible object.
 @param[in] users  the users that are involved.
    the first user is the user whose UserAccessible Object is being modified, deleting the second
    user's liked object from thier 'friendOrgs" or 'friendEvents' list.
*/
+ (void)deleteFriendLikes:(NSArray*)users{

    PFUser *fromUser= [users firstObject];
    PFUser *toUser=[users lastObject];
    PFQuery *selfAccessQ= [PFQuery queryWithClassName:@"UserAccessible"];
    [selfAccessQ whereKey:@"username" equalTo:fromUser.username];
    [selfAccessQ getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        PFObject* selfAccess=object;
        PFObject *friendLikes=selfAccess[@"friendOrgs"];
        //for each of the organizations that the friend has liked, remove the friend's username from the list
        for(NSString* ein in toUser[@"likedOrgs"])
        {
            if(friendLikes[ein])
            {
                NSMutableArray *list= [friendLikes[ein] mutableCopy];
                [list removeObject:toUser.username];
                friendLikes[ein]=list;
            }
            else
            {
                friendLikes[ein]=@[toUser.username];
            }
        }
        selfAccess[@"friendOrgs"]=friendLikes;
        [selfAccess saveEventually];

        friendLikes=selfAccess[@"friendEvents"];
        //for each of the events that the friend has liked, remove the friend's username from the list
        for(NSString *eventId in toUser[@"likedEvents"])
        {
            if(friendLikes[eventId])
            {
                NSMutableArray *list= [friendLikes[eventId] mutableCopy];
                [list removeObject:toUser.username];
                friendLikes[eventId]=list;
            }
            else
            {
                friendLikes[eventId]=@[toUser.username];
            }
        }
        selfAccess[@"friendEvents"]=friendLikes;
        [selfAccess saveEventually];
    
    }];
}
/**
 Delets a friend request
 @param[in] current the user that declined the request
 @param[in] requester  the user that requested
 
 removes the 'inRequest' for the decliner and the 'outRequest' for the requester
*/
+ (void) removeRequest:(PFUser *)current forUser:(PFUser *)requester{
    PFObject *currentUserAccess= [Helper getUserAccess:current];
    PFObject *requesterUserAccess= [Helper getUserAccess:requester];
    //access the request list of the requester and the current
    NSMutableArray *inRequests= currentUserAccess[@"inRequests"];
    NSMutableArray *outRequests= requesterUserAccess[@"outRequests"];
    
    //remove the request from both
    [inRequests removeObject:requester.objectId];
    [outRequests removeObject:current.objectId];
    
    //assign the attributes to new list
    currentUserAccess[@"inRequests"]=inRequests;
    requesterUserAccess[@"outRequests"]=outRequests;
    
    //save
    [currentUserAccess saveEventually];
    [requesterUserAccess saveEventually];

}
/**
 Adds a friend request
 @param[in] current the user that sent a request
 @param[in] requested  the user that is requested
 
 Adds the 'inRequest' for the requested and the 'outRequest' for the current
*/
+ (void) addRequest:(PFUser *)current forUser:(PFUser *)requested{
    
    PFObject *currentUserAccess= [Helper getUserAccess:current];
    PFObject *requestedUserAccess= [Helper getUserAccess:requested];
    //access the request list of the requester and the current
    NSMutableArray *outRequests= currentUserAccess[@"outRequests"];
    NSMutableArray *inRequests= requestedUserAccess[@"inRequests"];
    
    //add the request to both
    [outRequests addObject:requested.objectId];
    [inRequests addObject:current.objectId];
    
    //assign the attributes to new list
    currentUserAccess[@"outRequests"]=outRequests;
    requestedUserAccess[@"inRequests"]=inRequests;
    
    //save
    [currentUserAccess saveEventually];
    [requestedUserAccess saveEventually];
}
/**
Updates the ordered message thread list in UserAccess for the 2 users messaging
 @param[in] toUser  the user that the messages are  with
 Adds the 'inRequest' for the requested and the 'outRequest' for the current
*/
+ (void) updateMessageOrder:(PFUser *)toUser{
    PFObject *currentUserAccess= [Helper getUserAccess:PFUser.currentUser];
    PFObject *toUserAccess= [Helper getUserAccess:toUser];
    //access the messageThread list of the users
    NSMutableArray *currMessageT= currentUserAccess[@"messageThreads"];
    NSMutableArray *otherMessageT= toUserAccess[@"messageThreads"];
    
    //remove the users from the current order
    [currMessageT removeObject:toUser.objectId];
    [otherMessageT removeObject:PFUser.currentUser.objectId];
    //add the object id of both users to the beginning of the list
    [currMessageT insertObject:toUser.objectId atIndex:0];
    [otherMessageT insertObject:PFUser.currentUser.objectId atIndex:0];
    
    //assign the attributes to new list
    currentUserAccess[@"messageThreads"]=currMessageT;
    toUserAccess[@"messageThreads"]=otherMessageT;
    //save
    [currentUserAccess saveEventually];
    [toUserAccess saveEventually];
}
/**
Add the unread message  list in UserAccess to indicate the message to this user is unread
 @param[in] reciever the user that the message is to
*/
+ (void) addUnreadMessage:(PFUser*) reciever{
    PFObject *rUserAccess= [Helper getUserAccess:reciever];
    NSMutableArray *rUserUnread= rUserAccess[@"unreadMessages"];
    [rUserUnread addObject:PFUser.currentUser.objectId];
    rUserAccess[@"unreadMessages"]=rUserUnread;
    [rUserAccess saveEventually];
}
/**
Remove the unread message list in UserAccess to indicate the message from this user has been read
 @param[in] sender  the user that sent the message
*/
+ (void) removeUnreadMessage:(PFUser*) sender{
    PFObject *selfAccess= [Helper getUserAccess:PFUser.currentUser];
    NSMutableArray *selfUnread= selfAccess[@"unreadMessages"];
    [selfUnread removeObject:sender.objectId];
    selfAccess[@"unreadMessages"]=selfUnread;
    [selfAccess saveEventually];
}
/**
 Checks if the app is connected to the internet
 @return YES: the app is conencted to internet
        NO, the app is not connected to internet
 */
+ (BOOL)connectedToInternet{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}
/**
Fetches the claimed orgainzation with this ein, nil if it doesnt exist
 @param[in] ein the ein of the organizaiton
@param[in] completion the block that will send the claimed org back to the caller
*/
+ (void) getClaimedOrgFromEin:(NSString*) ein withCompletion:(void(^)(PFObject *claimedOrg))completion{
    PFQuery* orgQ=[PFQuery queryWithClassName:@"ClaimedOrganization"];
    [orgQ whereKey:@"ein" equalTo:ein];
    [orgQ findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(error || objects.count==0)
            completion(nil);
        else
            completion([objects firstObject]);
    }];
}
/**
 Adds the current user to the seen users of the claimed organization
 @param[in] claimedOrg the org that this user has seen
 */
+ (void) addUserToSeenClaimedOrgList:(ClaimedOrganization*)claimedOrg{
    NSMutableArray* seenUsers=claimedOrg.seenUsers.mutableCopy;
    //add only once and not the claimed user
    [claimedOrg.claimedBy fetchIfNeeded];
    if(PFUser.currentUser.username!=claimedOrg.claimedBy.username)
    {
        [seenUsers removeObject:PFUser.currentUser.objectId];
        [seenUsers addObject:PFUser.currentUser.objectId];
        claimedOrg.seenUsers=seenUsers;
        [claimedOrg saveEventually];
    }
}

/**
fetches all the users that have seen this organization
 @param[in] claimedOrg the org that this user has seen
 */
+ (void) getClaimedOrgSeenUsers:(ClaimedOrganization*)claimedOrg withCompletion:(void(^)(NSArray *users, NSError *error))completion{
    
    PFQuery *userQ = [PFQuery queryWithClassName:@"_User"];
    if(! [Helper connectedToInternet])
        [userQ fromLocalDatastore];
    [userQ whereKey:@"objectId" containedIn:claimedOrg.seenUsers];
    [userQ includeKey:@"friendAccessible"];
    [userQ findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(error)
            completion(nil, error);
        else{
            for(PFUser* user in objects)
            {
                [user[@"friendAccessible"] pinInBackground];
            }
            [PFObject pinAllInBackground:objects];
            completion(objects, nil);
        }
    }];
}

@end
