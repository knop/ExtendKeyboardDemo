ExtendKeyboardDemo
==================
键盘扩展以支持多个UITextField中进行切换.

目前支持parent view为UIView和UIScrollView


使用方式
    - (void)viewWillAppear:(BOOL)animated
    {
        if (_extendKeyboard == nil) {
            _extendKeyboard = [ExtendKeyboard addExtendKeyboardViewToParentView:self.view];
        }
    }

