//
// MainViewController.m
// Withings-SDK-iOS
//
// Copyright (c) 2016 jdrevet
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
//
// June 2016 addition of WithingsSleepMeasure sleep measures retrieval and mapping
//
// copyright (c) 2016 robertturrall
//
//

#import "MainViewController.h"
#import "WithingsAPI.h"
#import "WithingsError.h"
#import "UIColor+Withings.h"


@interface MenuItem : NSObject
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *segueId;
+ (MenuItem*)menuItemWithTitle:(NSString*)title segueId:(NSString*)segueId;
@end


@interface MainViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loginActivityIndicatorView;
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;
@property (strong, nonatomic) NSArray<MenuItem*> *menuItems;
@end


@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Customize navigation bar UI
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    //Display the right controls for the current authorization state
    BOOL shouldRequestAccessAuthorization = [self shouldRequestAccessAuthorization];
    _loginButton.enabled = shouldRequestAccessAuthorization;
    [_menuTableView setUserInteractionEnabled:!shouldRequestAccessAuthorization];
    
    //Configure the API menu
    _menuItems = @[[MenuItem menuItemWithTitle:@"Activity measures" segueId:@"ShowActivityMeasuresSegue"],
                   [MenuItem menuItemWithTitle:@"Sleep measures" segueId:@"ShowSleepMeasuresSegue"],
                   [MenuItem menuItemWithTitle:@"Body measures" segueId:@"ShowBodyMeasuresSegue"]];
}

- (IBAction)login:(UIButton *)sender
{
    [_loginActivityIndicatorView startAnimating];
    _loginButton.userInteractionEnabled = NO;
    [[WithingsAPI sharedInstance] requestAccessAuthorizationWithCallbackScheme:@"withingsDemo" presenterViewController:self success:^(NSString *userId) {
        [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"WithingsUser"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        _loginButton.enabled = NO;
        [_loginActivityIndicatorView stopAnimating];
        [_menuTableView setUserInteractionEnabled:YES];
        [_menuTableView reloadData];
    } failure:^(WithingsError *error) {
        NSLog(@"%@", error);
        [_loginActivityIndicatorView stopAnimating];
        _loginButton.userInteractionEnabled = YES;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }];
}

- (BOOL)shouldRequestAccessAuthorization
{
    BOOL shouldRequestAccessAuthorization = YES;
    NSString *currentUser = [[NSUserDefaults standardUserDefaults] stringForKey:@"WithingsUser"];
    if(currentUser) {
        shouldRequestAccessAuthorization = ![[WithingsAPI sharedInstance] hasAccessAuthorizationForUser:currentUser];
    }
    return shouldRequestAccessAuthorization;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WithingsAPICell" forIndexPath:indexPath];
    cell.textLabel.textColor = [self shouldRequestAccessAuthorization] ? [UIColor grayColor] : [UIColor withingsBlueColor];
    if(indexPath.row < _menuItems.count) {
        cell.textLabel.text = _menuItems[indexPath.row].title;
    }
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < _menuItems.count) {
        [self performSegueWithIdentifier:_menuItems[indexPath.row].segueId sender:self];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end


@implementation MenuItem
+ (MenuItem*)menuItemWithTitle:(NSString*)title segueId:(NSString*)segueId
{
    MenuItem *menuItem = [[MenuItem alloc] init];
    menuItem.title = title;
    menuItem.segueId = segueId;
    return menuItem;
}
@end


