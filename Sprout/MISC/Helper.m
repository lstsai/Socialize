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
    [Helper performSelectorInBackground:@selector(addOrgToFriendsList:) withObject:likedOrg];//add to list in background
    PFUser.currentUser[@"likedOrgs"]=likedOrgs;
    [PFUser.currentUser saveInBackground];
    [Post createPost:nil withDescription:@"Liked an Organization" withEvent:nil withOrg:likedOrg withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if(error)
            [AppDelegate displayAlert:@"Error Posting" withMessage:error.localizedDescription on:viewC];
    }];
}
+ (void)didUnlikeOrg:(Organization*)unlikedOrg{
    NSMutableArray *likedOrgs= [PFUser.currentUser[@"likedOrgs"] mutableCopy];

    [likedOrgs removeObject:unlikedOrg.ein];
    [Helper performSelectorInBackground:@selector(deleteOrgFromFriendsList:) withObject:unlikedOrg];//add to list in background
    PFUser.currentUser[@"likedOrgs"]=likedOrgs;
    [PFUser.currentUser saveInBackground];
}

+(void) addOrgToFriendsList:(Organization*)likedOrg{
    
    [Helper getFriends:^(NSArray * _Nonnull friends, NSError * _Nonnull error) {
        for(PFObject* friend in friends)//get the array of friends for current user
        {
            //if the friend alreay has other friends that like this org
            PFObject * faAcess=friend[@"friendAccessible"];
            if(faAcess[@"friendOrgs"][likedOrg.ein])
            {
                //get the dictionary of orgs
                NSMutableDictionary *friendOrgs=[faAcess[@"friendOrgs"] mutableCopy];
                
                //get the arry for this org and add
                NSMutableArray* list= [friendOrgs[likedOrg.ein] mutableCopy];
                [list addObject:PFUser.currentUser.username];
                
                //set the list to the key
                friendOrgs[likedOrg.ein]=list;
                //assign dictionary to attribute so parse detects change
                faAcess[@"friendOrgs"]= friendOrgs;
            }
            else
            {
                //create that array for the ein and add self as the person who liked it
                NSMutableDictionary *friendOrgs=[faAcess[@"friendOrgs"] mutableCopy];
                friendOrgs[likedOrg.ein]=@[PFUser.currentUser.username];
                faAcess[@"friendOrgs"]= friendOrgs;
            }
            //save each friend
            [faAcess saveInBackground];
        }
    }];
}
+(void) deleteOrgFromFriendsList:(Organization*)unlikedOrg{
    
    [Helper getFriends:^(NSArray * _Nonnull friends, NSError * _Nonnull error) {
        for(PFObject* friend in friends)//get the array of friends for current user
        {
            PFObject * faAcess=friend[@"friendAccessible"];
            if(faAcess[@"friendOrgs"][unlikedOrg.ein])
            {
                //add own username to that list of friends
                NSMutableDictionary *friendOrgs=[faAcess[@"friendOrgs"] mutableCopy];
                
                NSMutableArray* list= [friendOrgs[unlikedOrg.ein] mutableCopy];
                [list removeObject:PFUser.currentUser.username];
                
                friendOrgs[unlikedOrg.ein]=list;
                faAcess[@"friendOrgs"]= friendOrgs;
            }
            //save each friend
            [faAcess saveInBackground];
        }
    }];
}

+(void) didLikeEvent:(Event*)likedEvent senderVC:(UIViewController* _Nullable)viewC{
    NSMutableArray *likedEvents= [PFUser.currentUser[@"likedEvents"] mutableCopy];
    
    [likedEvents addObject:likedEvent.objectId];
    [Helper performSelectorInBackground:@selector(addEventToFriendsList:) withObject:likedEvent];
    
    PFUser.currentUser[@"likedEvents"]=likedEvents;
    [PFUser.currentUser saveInBackground];
    [Post createPost:nil withDescription:@"Liked an Event" withEvent:likedEvent withOrg:nil withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if(error)
            [AppDelegate displayAlert:@"Error Posting" withMessage:error.localizedDescription on:viewC];
    }];
}
+ (void)didUnlikeEvent:(Event*)unlikedEvent{
    NSMutableArray *likedEvents= [PFUser.currentUser[@"likedEvents"] mutableCopy];

    [likedEvents removeObject:unlikedEvent.objectId];
    [self performSelectorInBackground:@selector(deleteEventFromFriendsList:) withObject:unlikedEvent];
    
    PFUser.currentUser[@"likedEvents"]=likedEvents;
    [PFUser.currentUser saveInBackground];
}
+ (void) addEventToFriendsList:(Event*)likedEvent{
    [Helper getFriends:^(NSArray * _Nonnull friends, NSError * _Nonnull error) {
        for(PFObject* friend in friends)//get the array of friends for current user
        {
            //if the friend alreay has other friends that like this org
            PFObject * faAcess=friend[@"friendAccessible"];
           if(faAcess[@"friendEvents"][likedEvent.objectId])
            {   //get dictionary that contains liked evnts by friends
                NSMutableDictionary *friendEvents=[faAcess[@"friendEvents"] mutableCopy];
                
                //add own username to that list of friends that liked event
                NSMutableArray* list= [friendEvents[likedEvent.objectId] mutableCopy];
                [list addObject:PFUser.currentUser.username];
                
                //assign array back to key, then assign dictionary to the attribute so parse will save
                friendEvents[likedEvent.objectId]=list;
                faAcess[@"friendEvents"]= friendEvents;
            }
            else
            {
                //create that array for the ein and add self as the person who liked it
                NSMutableDictionary *friendEvents=[faAcess[@"friendEvents"] mutableCopy];
                friendEvents[likedEvent.objectId]=@[PFUser.currentUser.username];
                faAcess[@"friendEvents"]= friendEvents;
            }
            //save each friend
            [faAcess saveInBackground];
        }
    }];
}

+ (void) deleteEventFromFriendsList:(Event*)unlikedEvent{
    [Helper getFriends:^(NSArray * _Nonnull friends, NSError * _Nonnull error) {
        for(PFObject* friend in friends)//get the array of friends for current user
        {
            PFObject * faAcess=friend[@"friendAccessible"];
            if(faAcess[@"friendEvents"][unlikedEvent.objectId])
            {
                //add own username to that list of friends
                NSMutableDictionary *friendEvents=[faAcess[@"friendEvents"] mutableCopy];
                
                NSMutableArray* list= [friendEvents[unlikedEvent.objectId] mutableCopy];
                [list removeObject:PFUser.currentUser.username];
                    
                friendEvents[unlikedEvent.objectId]=list;
                faAcess[@"friendEvents"]= friendEvents;
            }
            //save each friend
            [faAcess saveInBackground];
        }
    }];
}




@end
