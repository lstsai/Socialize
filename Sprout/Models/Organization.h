//
//  Organization.h
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

/*
 Object to represent an Organization
 */

#import <Foundation/Foundation.h>
#import "Location.h"
NS_ASSUME_NONNULL_BEGIN

@interface Organization : NSObject
@property (nonatomic, strong) NSString *ein; // employer identification number
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *cause;
@property (nonatomic, strong) NSString *missionStatement;
@property (nonatomic, strong) NSString *tagLine;
@property (nonatomic, strong) NSURL *website;
@property (nonatomic,strong) NSDictionary *locationDictionary;//Dictionary contianing location information for the org
@property (nonatomic,strong) NSURL * _Nullable imageURL;
@property (nonatomic) NSInteger numFriendsLike;
@property (strong, nonatomic) Location *location;//location object of the org

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
+ (NSMutableArray *)orgsWithArray:(NSArray *)dictionaries;
+ (NSDictionary *) dictionaryWithOrg:(Organization *)org;
+ (Organization *) orgWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
