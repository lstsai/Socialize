//
//  InfiniteScrollActivityView.m
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "InfiniteScrollActivityView.h"

#import "InfiniteScrollActivityView.h"

@implementation InfiniteScrollActivityView

UIActivityIndicatorView* activityIndicatorView;
static CGFloat _defaultHeight = 60.0;//height of the view 

+ (CGFloat)defaultHeight{
    return _defaultHeight;
}
/**
Initializes an InfiniteScrollActivityView
@param[in] aDecoder the NSCoder that contains the information needed to initialize the indicator
 @return the created indicator
*/
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self setupActivityIndicator];
    }
    return self;
}
/**
Initializes an InfiniteScrollActivityView
@param[in] frame the CGRect frame that the indicator should be in
 @return the created indicator
*/
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self setupActivityIndicator];
    }
    return self;
}
/**
Configures the layout of the indicator to be in the center of the frame
*/
- (void)layoutSubviews{
    [super layoutSubviews];
    activityIndicatorView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
}
/**
Create and set up the indicator
*/
- (void)setupActivityIndicator{
    activityIndicatorView = [[UIActivityIndicatorView alloc] init];
    activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleMedium;
    activityIndicatorView.hidesWhenStopped = true;
    [self addSubview:activityIndicatorView];
}
/**
Stops animating and hides
 */
-(void)stopAnimating{
    [activityIndicatorView stopAnimating];
    self.hidden = true;
}
/**
Start animating and and shows
 */
-(void)startAnimating{
    self.hidden = false;
    [activityIndicatorView startAnimating];
}

@end
