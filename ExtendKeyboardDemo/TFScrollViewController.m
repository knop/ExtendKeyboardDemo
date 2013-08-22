//
//  TFScrollViewController.m
//  ExtendKeyboardDemo
//
//  Created by Xiaohui Chen on 13-8-22.
//  Copyright (c) 2013年 Team4.US. All rights reserved.
//

#import "TFScrollViewController.h"
#import "ExtendKeyboard.h"

@interface TFScrollViewController ()
{
    ExtendKeyboard *_extendKeyboard;
}
@end

@implementation TFScrollViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    if (_extendKeyboard == nil) {
        UIScrollView *scrollView = (UIScrollView *)self.view;
        _extendKeyboard = [ExtendKeyboard addExtendKeyboardViewToParentView:scrollView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
