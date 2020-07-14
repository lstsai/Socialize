//
//  CreateViewController.m
//  Sprout
//
//  Created by laurentsai on 7/14/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "CreateViewController.h"
#import "Constants.h"
@interface CreateViewController ()

@end

@implementation CreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupDatePicker];
    
}
-(void) setupDatePicker{
    UIDatePicker *datePicker = [[UIDatePicker alloc]init];
    [datePicker setDate:[NSDate date]];
    [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    [datePicker setMinuteInterval:MINUTE_INTERVAL];
    [datePicker addTarget:self action:@selector(dateTextField:) forControlEvents:UIControlEventValueChanged];

    [self.dateField setInputView:datePicker];


}
-(void) dateTextField:(id)sender{
    UIDatePicker *picker = (UIDatePicker*)self.dateField.inputView;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSDate *eventDate = picker.date;
    [dateFormat setDateFormat:@"MM/dd/yy HH:mm"];
    NSString *dateString = [dateFormat stringFromDate:eventDate];
    self.dateField.text = [NSString stringWithFormat:@"%@",dateString];
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
