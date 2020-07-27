//
//  WebViewController.h
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//
/*
 View controller is presented when the user taps a link that needs an web view
 */
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface WebViewController : UIViewController
@property (strong, nonatomic) NSURL *link;
@property (weak, nonatomic) IBOutlet WKWebView *webView;
@end

NS_ASSUME_NONNULL_END
