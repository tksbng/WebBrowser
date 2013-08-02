//
//  ViewController.m
//  WebBrowser
//
//  Created by Takeshi Bingo on 2013/08/02.
//  Copyright (c) 2013年 Takeshi Bingo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController {
    IBOutlet UIWebView *webView;
    IBOutlet UITextField *urlField;
    
    NSString *pageTitle;
    NSString *url;
    
    NSString *databaseName;
    NSString *databasePath;
    bool loadSuccessful;
}

-(void)createAndCheckDatabase {
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    success = [fileManager fileExistsAtPath:databasePath];
    
    if (success) {
        return;
    }
    NSString *databasePathFromApp = [[[NSBundle mainBundle]resourcePath] stringByAppendingPathComponent:databaseName];
    [fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
}
-(void)makeRequest {
    NSURLRequest *urlReq = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSLog(@"%@",[NSURL URLWithString:url]);
    [webView loadRequest:urlReq];
    loadSuccessful = false;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
