//
//  InfiniteScrollActivityView.h
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//
/*
 Activity view indicator to represent loading when reach the end of a table/collection view
*/
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface InfiniteScrollActivityView : UIActivityIndicatorView
@property (class, nonatomic, readonly) CGFloat defaultHeight;
-(void) startAnimating;
-(void) stopAnimating;
@end

NS_ASSUME_NONNULL_END
