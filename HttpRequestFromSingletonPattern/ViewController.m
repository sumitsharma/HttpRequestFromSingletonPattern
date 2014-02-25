//
//  ViewController.m
//  HttpRequestFromSingletonPattern
//
//  Created by Sumit Sharma on 2/25/14.
//  Copyright (c) 2014 Sumit Sharma. All rights reserved.
//

#import "ViewController.h"
#import "HttpUtils.h"

NSString *const stringURL = @"http://phobos.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/toppaidapplications/limit=75/xml";

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [HttpUtils invokeAPIWithURL:[NSURL URLWithString:stringURL] parameters:nil andCompletionHandler:^(NSString *response, NSDictionary *paramObj, NSError *error, BOOL isSuccess) {
        
        if (isSuccess) {
            NSLog(@"success %@ ", response);
            
        }else{
            NSLog(@"failure");
           
        }
    } inView:self.view andLoadmessage:@"Please wait..."];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
