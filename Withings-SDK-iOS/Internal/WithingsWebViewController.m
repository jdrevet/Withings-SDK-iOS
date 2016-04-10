//
// WithingsWebViewController.m
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

#import "WithingsWebViewController.h"

@interface WithingsWebViewController () <UIWebViewDelegate>
@property (nonatomic, strong) UIViewController *presenterViewController;
@property (nonatomic, strong) NSURL *url;
@end

@implementation WithingsWebViewController

- (instancetype)initWithPresenterViewController:(UIViewController *)presenterViewController
{
    self = [super init];
    if (self) {
        self.presenterViewController = presenterViewController;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame = self.parentViewController.view.bounds;
    self.view.frame = frame;
    UIWebView *webView = [[UIWebView alloc] initWithFrame:frame];
    [self.view addSubview:webView];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [webView loadRequest:[NSURLRequest requestWithURL:_url]];
}

#pragma mark - OAuthSwiftURLHandlerType protocol implementation

- (void)handle:(NSURL*)url
{
    if(![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handle:url];
        });
        return;
    }
    
    self.url = url;
    [_presenterViewController presentViewController:self animated:YES completion:nil];
}

- (void)dismissWebViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
