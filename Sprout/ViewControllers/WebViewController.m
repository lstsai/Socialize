//
//  WebViewController.m
//  Sprout
//
//  Created by laurentsai on 7/13/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "WebViewController.h"
#import "MBProgressHUD.h"
@interface WebViewController ()<WKNavigationDelegate>

@end

@implementation WebViewController
/**
 Loads the link that was passed to this controller
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.webView];
    self.webView.navigationDelegate=self;
    // Do any additional setup after loading the view.
    NSURLRequest *request=[NSURLRequest requestWithURL:self.link];
    [self.webView loadRequest:request];
    [self.webView reload];
}
/**
 Triggered when the user taps the cancel button, dismisses the view controller
 @param[in] sender the button that was pressed
 */
- (IBAction)didTapCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
