//
//  Organization.h
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"
NS_ASSUME_NONNULL_BEGIN

@interface Organization : NSObject
@property (nonatomic, strong) NSString *ein; // For favoriting, retweeting & replying
@property (nonatomic, strong) NSString *name; // Text content of tweet
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *cause;
@property (nonatomic, strong) NSString *missionStatement; // Display website
@property (nonatomic, strong) NSString *tagLine; // Display website
@property (nonatomic, strong) NSURL *website;
@property (nonatomic,strong)NSURL *imageURL;
@property (strong, nonatomic) Location *address;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
+ (NSMutableArray *)orgsWithArray:(NSArray *)dictionaries;

@end

NS_ASSUME_NONNULL_END
