//
//  Helper.m
//  Sprout
//
//  Created by laurentsai on 7/21/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "Helper.h"

@implementation Helper
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image withName:(NSString*)imageName {
    if(image)//no image
    {
        NSData *imageData = UIImagePNGRepresentation(image);
        imageName=[imageName stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString* fileName=[imageName stringByAppendingString:@".png"];
        if(imageData)
            return [PFFileObject fileObjectWithName:fileName data:imageData];
    }
    
    return nil;//if image data or image is nil
}
+ (PFObject *) getUserAccess:(PFUser*) user{
    /*
     The UserAccessible class is an object that each user has a pointer to. Since
     parse does not let users modify other users' data, this pointer allows friends to
     add to or delete from the the liked orgs/events list, and the friends list, without
     actually modifying the user object.
     */
    PFQuery *accessQ= [PFQuery queryWithClassName:@"UserAccessible"];
    [accessQ whereKey:@"username" equalTo:user.username];
    return [accessQ getFirstObject];
}
+ (void) getFriends:(void(^)(NSArray *friends, NSError *error))completion{
    
    PFObject *friendAccess=[Helper getUserAccess:PFUser.currentUser];
    NSArray *friendList=friendAccess[@"friends"];
    PFQuery *friendQuery = [PFQuery queryWithClassName:@"_User"];
    [friendQuery whereKey:@"objectId" containedIn:friendList];
    [friendQuery includeKey:@"friendAccessible"];
    [friendQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(error)
            completion(nil, error);
        else
            completion(objects, nil);
    }];
    
}

+ (void)didLikeOrg:(Organization*)likedOrg sender:(UIViewController* _Nullable)viewC{
    NSMutableArray *likedOrgs= [PFUser.currentUser[@"likedOrgs"] mutableCopy];
    [likedOrgs addObject:likedOrg.ein];
    [Helper performSelectorInBackground:@selector(addObjectToFriendsList:) withObject:@[likedOrg.ein, @"friendOrgs"]];//add to list in background
    PFUser.currentUser[@"likedOrgs"]=likedOrgs;
    [PFUser.currentUser saveInBackground];
    [Post createPost:nil withDescription:@"Liked an Organization" withEvent:nil withOrg:likedOrg withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if(error)
            [Helper displayAlert:@"Error Posting" withMessage:error.localizedDescription on:viewC];
    }];
}
+ (void)didUnlikeOrg:(Organization*)unlikedOrg{
    NSMutableArray *likedOrgs= [PFUser.currentUser[@"likedOrgs"] mutableCopy];

    [likedOrgs removeObject:unlikedOrg.ein];
    [Helper performSelectorInBackground:@selector(deleteObjectFromFriendsList:) withObject:@[unlikedOrg.ein, @"friendOrgs"]];//add to list in background
    PFUser.currentUser[@"likedOrgs"]=likedOrgs;
    [PFUser.currentUser saveInBackground];
}
+(void) didLikeEvent:(Event*)likedEvent senderVC:(UIViewController* _Nullable)viewC{
    NSMutableArray *likedEvents= [PFUser.currentUser[@"likedEvents"] mutableCopy];
    
    [likedEvents addObject:likedEvent.objectId];
    [Helper performSelectorInBackground:@selector(addObjectToFriendsList:) withObject:@[likedEvent.objectId, @"friendEvents"]];

    PFUser.currentUser[@"likedEvents"]=likedEvents;
    [PFUser.currentUser saveInBackground];
    [Post createPost:nil withDescription:@"Liked an Event" withEvent:likedEvent withOrg:nil withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if(error)
            [Helper displayAlert:@"Error Posting" withMessage:error.localizedDescription on:viewC];
    }];
}
+ (void)didUnlikeEvent:(Event*)unlikedEvent{
    NSMutableArray *likedEvents= [PFUser.currentUser[@"likedEvents"] mutableCopy];

    [likedEvents removeObject:unlikedEvent.objectId];
    [self performSelectorInBackground:@selector(deleteObjectFromFriendsList:) withObject:@[unlikedEvent.objectId, @"friendEvents"]];
    
    PFUser.currentUser[@"likedEvents"]=likedEvents;
    [PFUser.currentUser saveInBackground];
}

+ (void) addObjectToFriendsList:(NSArray*)keys{
    /*
     This method adds the liked org/event to every friend's list. The objKey is the identifier
     for a specific liked object, and the listName is the dictionary the liked object should be
     added to. In order for parse to 'save' an object, it needs to detect a change in that object,
     which is why I have created many variables, that are reassigned to the object at the very end
     so that Parse will actually save this change.
     */
    
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
               [friendAccess saveInBackground];
           }
       }];
}
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
            [friendAccess saveInBackground];
        }
    }];
}



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




@end
