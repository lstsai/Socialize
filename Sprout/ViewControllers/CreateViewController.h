//
//  CreateViewController.h
//  Sprout
//
//  Created by laurentsai on 7/14/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CreateViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *eventNameField;
@property (weak, nonatomic) IBOutlet UITextField *dateField;
-(void) setupDatePicker;
-(void) dateTextField:(id)sender;

@end

NS_ASSUME_NONNULL_END
