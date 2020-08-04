//
//  AppDelegate.h
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <CoreData/CoreData.h>
#import "ProfileViewController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) ProfileViewController* currProfileVC;
@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;
@end

