//
//  SleepMeasuresViewController.m
//  Withings-SDK-iOS
//
//  Created by Robert Turrall on 08/06/16 based on original code from jdrevet ActivityMeasureController
//  Copyright © 2016 jdrevet. All rights reserved.
//  Copyright © 2016 robertturrall. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
#import "SleepMeasuresViewController.h"
#import "Withings_SDK_iOS.h"
#import "WithingsButton.h"
#import "WithingsSleepCell.h"

@interface SleepMeasuresViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *startDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *endDateTextField;
@property (weak, nonatomic) IBOutlet WithingsButton *fetchButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITableView *resultTableView;
@property (strong, nonatomic) IBOutlet UIToolbar *dateToolbar;
@property (strong, nonatomic) IBOutlet UIDatePicker *startDatePicker;
@property (strong, nonatomic) IBOutlet UIDatePicker *endDatePicker;

@property (strong, nonatomic) UITextField *currentTextField;
@property (strong, nonatomic) NSArray <WithingsSleepMeasure *> *sleepMeasures;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@end


@implementation SleepMeasuresViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Configure the date formatter
    _dateFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter.dateStyle = NSDateFormatterShortStyle;
    
    //Configure the date picker
    _startDateTextField.inputView = _startDatePicker;
    _startDateTextField.inputAccessoryView = _dateToolbar;
    _startDatePicker.maximumDate = [NSDate date];
    _endDateTextField.inputView = _endDatePicker;
    _endDateTextField.inputAccessoryView = _dateToolbar;
    _endDatePicker.maximumDate = [NSDate date];
}

#pragma mark - IBActions

- (IBAction)dateValueChanged:(UIDatePicker *)sender
{
    _currentTextField.text = [_dateFormatter stringFromDate:sender.date];
}

- (IBAction)closeDatePicker:(UIBarButtonItem *)sender
{
    [self textFieldShouldReturn:_currentTextField];
}

- (IBAction)fetchActivityMeasures:(UIButton *)sender
{
    //Close the keyboard
    [self textFieldShouldReturn:_currentTextField];
    
    //Show activity indicator
    _fetchButton.userInteractionEnabled = NO;
    [_activityIndicator startAnimating];
    
    //Call activity API
    NSDate *startDate = [_dateFormatter dateFromString:_startDateTextField.text];
    NSDate *endDate = [_dateFormatter dateFromString:_endDateTextField.text];
    
    
    [[WithingsAPI sharedInstance].measureAPIClient getSleepMeasuresForUser:[[NSUserDefaults standardUserDefaults] stringForKey:@"WithingsUser"] inDateRange:[MeasuresDateRange dateRangeBetweenStartDate:startDate andEndDate:endDate] success:^(NSArray <WithingsSleepMeasure *> *sleepMeasures) {
        NSLog(@"%li sleep measures found", (unsigned long)sleepMeasures.count);
        //Hide activity indicator
        _fetchButton.userInteractionEnabled = YES;
        [_activityIndicator stopAnimating];
        //Display the results in the table view
        self.sleepMeasures = sleepMeasures;
        [_resultTableView reloadData];
    } failure:^(WithingsError *error) {
        NSLog(@"%@", error);
        //Hide activity indicator
        _fetchButton.userInteractionEnabled = YES;
        [_activityIndicator stopAnimating];
        //Display the error in alert view
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }];
    
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //Keep a reference to the current text field
    self.currentTextField = textField;
    UIDatePicker *datePicker = (UIDatePicker*)textField.inputView;
    textField.text = [_dateFormatter stringFromDate:datePicker.date];
#warning TODO check that start date < end date
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    //Close the keyboard
    [textField resignFirstResponder];
    return NO;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sleepMeasures.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDateComponents *components;
    
    WithingsSleepCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WithingsSleepCell" forIndexPath:indexPath];
    
    if(indexPath.row < self.sleepMeasures.count) {
        WithingsSleepMeasure *sleep = self.sleepMeasures[indexPath.row];
        cell.dateLabel.text = [_dateFormatter stringFromDate:sleep.startdate];
        
        components = [[NSCalendar currentCalendar] components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:sleep.startdate];
        cell.fromLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)[components hour], (long)[components minute]];
        
        components = [[NSCalendar currentCalendar] components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:sleep.enddate];
        cell.toLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)[components hour], (long)[components minute]];
        
        cell.statusLabel.text = [sleep stateToString];
    }
    return cell;
}


@end
