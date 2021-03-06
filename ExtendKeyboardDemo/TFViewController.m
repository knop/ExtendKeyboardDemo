//
//  TFViewController.m
//  ExtendKeyboardDemo
//
//  Created by Xiaohui Chen on 13-8-22.
//  Copyright (c) 2013年 Team4.US. All rights reserved.
//

#import "TFViewController.h"
#import "ExtendKeyboard.h"

@interface TFViewController ()
{
    ExtendKeyboard *_extendKeyboard;
}
@end

@implementation TFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    if (_extendKeyboard == nil) {
        _extendKeyboard = [ExtendKeyboard addExtendKeyboardViewToParentView:self.view];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
