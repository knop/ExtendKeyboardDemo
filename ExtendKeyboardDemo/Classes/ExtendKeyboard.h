//
//  CTExtendKeyboard.h
//  ExtendKeyboardDemo
//
//  Created by Xiaohui Chen on 13-8-22.
//  Copyright (c) 2013年 Team4.US. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExtendKeyboard: NSObject

+ (ExtendKeyboard *)addExtendKeyboardViewToParentView:(UIView *)parentView;

- (void)reloadAllTextFieldsFromParentView;

@end
