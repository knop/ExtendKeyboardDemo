//
//  CTExtendKeyboard.m
//  ExtendKeyboardDemo
//
//  Created by Xiaohui Chen on 13-8-22.
//  Copyright (c) 2013年 Team4.US. All rights reserved.
//

#import "ExtendKeyboard.h"

@interface TextFieldObject : NSObject

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic) CGPoint point; //相对于最外层UIView的坐标

@end

@implementation TextFieldObject

@end

@interface ExtendKeyboard ()
{
    NSMutableArray *_textFields;
    NSUInteger _currentTextFieldIndex;
    __weak UIView *_parentView;
    UIView *_extendKeyboardView;
    CGRect _originFrame;
    CGFloat _heightOfKeyboard;
    CGSize _originContentSize;
    UISegmentedControl *_segmentedControl;
}
@end

@implementation ExtendKeyboard

- (id)initWithParentView:(UIView *)parentView
{
    self = [super init];
    if (self) {
        _currentTextFieldIndex = -1;
        _parentView = parentView;
        _extendKeyboardView = [self extendboardView];
        [self reloadAllTextFieldsFromParentView];
        [self addKeyBoardNotification];
    }
    return self;
}

- (void)dealloc
{
    [self removeKeyBoardNotification];
}

- (UIView *)extendboardView
{
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    CGFloat width = 320.0f;
    CGFloat height = 44.0f;
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(x, y, width, height)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    NSString *previousText = @"Previous";
    NSString *nextText = @"Next";
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[previousText,nextText]];
    [_segmentedControl addTarget:self
                          action:@selector(onClickPreviousOrNext:)
                forControlEvents:UIControlEventValueChanged];
    [_segmentedControl setMomentary:YES];
    [_segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:_segmentedControl];
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:self
                                                                action:@selector(onClickDone:)];
    UIBarButtonItem *emptyItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:nil
                                                                               action:nil];
    toolbar.items = @[leftItem, emptyItem, doneItem];
    return toolbar;
}

+ (ExtendKeyboard *)addExtendKeyboardViewToParentView:(UIView *)parentView
{
    return [[ExtendKeyboard alloc] initWithParentView:parentView];
}

- (void)addKeyBoardNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardFrameChange:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}

- (void)removeKeyBoardNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
}

- (void)reloadAllTextFieldsFromParentView
{
    if (_textFields == nil) {
        _textFields = [[NSMutableArray alloc] init];
    }
    
    [_textFields removeAllObjects];

    [self loadAllTextFieldsFromParentView:_parentView
                                    point:_parentView.frame.origin];
    
    if ([_parentView isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)_parentView;
        _originContentSize = scrollView.contentSize;
    } else {
        _originFrame = _parentView.frame;
    }
    
    [self keyboardFrameChange:nil];
}

- (void)loadAllTextFieldsFromParentView:(UIView *)view
                                  point:(CGPoint)point
{
    for (UIView *subview in [view subviews]) {
        if (subview.hidden) {
            continue;
        }
        if ([subview isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)subview;
            if (!textField.hidden) {
                [textField addTarget:self
                              action:@selector(onEditingDidBegin:)
                    forControlEvents:UIControlEventEditingDidBegin];
                textField.inputAccessoryView = _extendKeyboardView;
                TextFieldObject *object = [[TextFieldObject alloc] init];
                object.textField = textField;
                object.point = CGPointMake(point.x + textField.frame.origin.x,
                                           point.y + textField.frame.origin.y);
                [_textFields addObject:object];
            }
        } else {
            CGPoint newPoint = CGPointMake(point.x + subview.frame.origin.x,
                                           point.y + subview.frame.origin.y);
            [self loadAllTextFieldsFromParentView:subview
                                            point:newPoint];
        }
    }
    
    [self sortTextField];
}

- (void)sortTextField
{
    NSComparator compareFunc = ^NSComparisonResult(TextFieldObject *object, TextFieldObject *anotherObject) {
        if (object.point.y < anotherObject.point.y) {
            return NSOrderedAscending;
        } else if (object.point.y > anotherObject.point.y) {
            return NSOrderedDescending;
        } else {
            if (object.point.x < anotherObject.point.x) {
                return NSOrderedAscending;
            } else if (object.point.x > anotherObject.point.x) {
                return NSOrderedDescending;
            } else {
                return NSOrderedSame;
            }
        }

        return NSOrderedSame;
    };
    
    [_textFields sortUsingComparator:compareFunc];
}

- (NSUInteger)findFirstResponderTextField
{
    for (NSUInteger i=0; i<_textFields.count; i++) {
        TextFieldObject *object = [_textFields objectAtIndex:i];
        if ([object.textField isFirstResponder]) {
            return i;
        }
    }

    return 0;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    if ([_parentView isKindOfClass:[UIScrollView class]]) {
        if (CGSizeEqualToSize(_originContentSize, CGSizeZero)) {
            UIScrollView *scrollView = (UIScrollView *)_parentView;
            CGSize fullSize = [UIScreen mainScreen].bounds.size;
            scrollView.contentSize = fullSize;
        }
    }
    [self keyboardFrameChange:notification];
    [self onTextFieldChange];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    if ([_parentView isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)_parentView;
        [scrollView setContentSize:_originContentSize];
    } else {
        _parentView.frame = _originFrame;
    }
    [UIView commitAnimations];
    _currentTextFieldIndex = -1;
}

- (void)keyboardFrameChange:(NSNotification *)notification
{
    if (notification != nil) {
        NSDictionary *userInfo = [notification userInfo];
        NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardRect = [aValue CGRectValue];
        _heightOfKeyboard = keyboardRect.size.height + _extendKeyboardView.frame.size.height;
    }

    if (_heightOfKeyboard > 0) {
        if ([_parentView isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)_parentView;
            CGFloat height = _originContentSize.height + _heightOfKeyboard;
            [scrollView setContentSize:CGSizeMake(_originContentSize.width, height)];
        } else {
            CGFloat height = _originFrame.size.height + _heightOfKeyboard;
            _parentView.frame = CGRectMake(_originFrame.origin.x,
                                           _originFrame.origin.y,
                                           _originFrame.size.width,
                                           height);
        }
    }
}

- (void)onClickPreviousOrNext:(UISegmentedControl *)segmentedControl
{
    
    if (segmentedControl.selectedSegmentIndex == 0) {
        [self changeTextField:NO];
    } else if (segmentedControl.selectedSegmentIndex == 1) {
        [self changeTextField:YES];
    }
    [self updateSegmentedControlEnabledStates];
}

- (void)onClickDone:(id)sender
{
    [_parentView endEditing:YES];
}

- (void)onEditingDidBegin:(id)sender
{
    if (_currentTextFieldIndex != -1) {
        [self onTextFieldChange];
    }
}

- (void)onTextFieldChange
{
    _currentTextFieldIndex = [self findFirstResponderTextField];
    TextFieldObject *object = [_textFields objectAtIndex:_currentTextFieldIndex];
    [self moveTextField:object];
    [self updateSegmentedControlEnabledStates];
}

- (void)changeTextField:(BOOL)isNext
{
    if (isNext) {
        _currentTextFieldIndex++;
    } else {
        _currentTextFieldIndex--;
    }
    [self becomeFirstResponder:isNext];
    [self updateSegmentedControlEnabledStates];
}

- (void)updateSegmentedControlEnabledStates
{
    [_segmentedControl setEnabled:(_currentTextFieldIndex > 0)
                forSegmentAtIndex:0];
    [_segmentedControl setEnabled:(_currentTextFieldIndex < _textFields.count - 1)
                forSegmentAtIndex:1];
}

- (void)becomeFirstResponder:(BOOL)isNext
{
    if (_textFields != nil) {
        TextFieldObject *object = [_textFields objectAtIndex:_currentTextFieldIndex];
        if (object.textField.hidden) {
            [self changeTextField:isNext];
        } else {
            [object.textField becomeFirstResponder];
        }
    }
}

- (void)moveTextField:(TextFieldObject *)object
{
    if (_heightOfKeyboard == 0.0f) {
        return;
    }
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];

    if ([_parentView isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)_parentView;
        CGRect rect = CGRectMake(0.0f,
                                 object.point.y + _heightOfKeyboard,
                                 object.textField.frame.size.width,
                                 object.textField.frame.size.height);
        [scrollView scrollRectToVisible:rect animated:YES];
    } else {
        CGSize fullSize = [UIScreen mainScreen].bounds.size;
        CGFloat y = fullSize.height - (object.textField.frame.size.height + _heightOfKeyboard);
        if (object.point.y > y) {
            _parentView.frame = CGRectMake(_originFrame.origin.x,
                                           _originFrame.origin.y - (object.point.y - y),
                                           _originFrame.size.width,
                                           _parentView.frame.size.height);
        } else {
            _parentView.frame = CGRectMake(_originFrame.origin.x,
                                           _originFrame.origin.y,
                                           _originFrame.size.width,
                                           _parentView.frame.size.height);
        }
    }

    [UIView commitAnimations];
}

@end
