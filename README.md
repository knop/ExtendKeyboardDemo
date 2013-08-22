ExtendKeyboardDemo
==================
键盘扩展以支持多个UITextField中进行切换.

目前支持parent view为UIView和UIScrollView


使用方式

1.将Classes目录中的两个文件加到工程中
2.使用以下类方法

    + (ExtendKeyboard *)addExtendKeyboardViewToParentView:(UIView *)parentView;
    
3.如果动态添加UITextField,可以重新调用

    - (void)reloadAllTextFieldsFromParentView; 
    
具体详见Demo代码

