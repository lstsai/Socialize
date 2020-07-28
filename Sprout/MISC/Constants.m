//
//  Constants.m
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "Constants.h"
const int RESULTS_SIZE = 20;
const int MINUTE_INTERVAL = 15;
const float SEARCH_DELAY=0.5;
NSString * const EVENT_SEARCH_PLACEHOLDER=@"Search for events";
NSString * const ORG_SEARCH_PLACEHOLDER=@"Search for organizations";
NSString * const PEOPLE_SEARCH_PLACEHOLDER=@"Search for people";
const int ORG_SEGMENT=0;
const int EVENT_SEGMENT=1;
const int PEOPLE_SEGMENT=2;

const CGFloat CELL_CORNER_RADIUS=10.0f;
const CGFloat SHADOW_RADIUS=5.0f;
const CGFloat SHADOW_OFFSET=2.0f;
const CGFloat SHADOW_OPACITY=0.5f;

const int MIN_MARGINS=5;
const int SECTION_INSETS=10;
const CGFloat PEOPLE_PER_LINE=2;

const NSTimeInterval ANIMATION_DURATION=0.75;
const CGFloat CELL_TOP_OFFSET=50.0f;

const int SHOW_ALPHA=1;
const int HIDE_ALPHA=0;

const int NUM_PLACEHOLDER_CELLS=3;

const NSString* ORG_POST_TEXT_PLACEHOLDER =@"Share something about this organization";
const NSString* EVENT_POST_TEXT_PLACEHOLDER=@"Share something about this event";

const CGFloat EMPTY_TITLE_FONT_SIZE=18;
const CGFloat EMPTY_MESSAGE_FONT_SIZE=14;

const CGFloat PULL_REFRESH_HEIGHT=50;
const int SEARCH_RADIUS=20;//miles
const int MIN_RESULT_THRESHOLD=10;

const int MAP_ZOOM=15;



