//
//  HsTopView.m
//  HsUber
//
//  Created by 王金东 on 16/1/19.
//  Copyright © 2016年 王金东. All rights reserved.
//

#import "HsTopView.h"

@interface HsTopView ()<UITextFieldDelegate>
@end

@implementation HsTopView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.startLocationView = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/2+1)];
    self.startLocationView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.startLocationView.layer.borderWidth = 1.0f;
    self.startLocationView.returnKeyType = UIReturnKeyDone;
    self.startLocationView.delegate = self;
    self.startLocationView.placeholder = @"出发地";
    self.startLocationView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.startLocationView];
    
    self.endLocationView = [[UITextField alloc] initWithFrame:CGRectMake(0, self.frame.size.height/2, self.frame.size.width, self.frame.size.height/2)];
    self.endLocationView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.endLocationView.delegate = self;
    self.endLocationView.placeholder = @"目的地";
    self.endLocationView.returnKeyType = UIReturnKeyDone;
    self.endLocationView.layer.borderWidth = 1.0f;
    self.endLocationView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.endLocationView];
    
    _topTextField = self.startLocationView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldEndEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];
}
- (void)textFieldDidEditing:(NSNotification *)notification {
    self.editing = YES;
    if (self.editingBlock) {
        self.editingBlock(YES);
    }
    _topTextField = notification.object;
    [UIView animateWithDuration:0.2f animations:^{
        self.startLocationView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/2+1);
        self.endLocationView.frame = CGRectMake(0, self.frame.size.height/2, self.frame.size.width, self.frame.size.height/2);
    } completion:^(BOOL finished) {
        //view之间的切换
        UIView *view = notification.object;
        [self bringSubviewToFront:view];
        [UIView animateWithDuration:0.2f animations:^{
            self.startLocationView.frame = CGRectMake(0, 10, self.frame.size.width, self.frame.size.height/2+1);
            self.endLocationView.frame = CGRectMake(0, self.frame.size.height/2-20, self.frame.size.width, self.frame.size.height/2);
        }];
    }];

}
- (void)textFieldEndEditing:(NSNotification *)notification {

}

- (void)resetView {
    self.editing = NO;
    _topTextField = self.startLocationView;
    if (self.editingBlock) {
        self.editingBlock(NO);
    }
    [UIView animateWithDuration:0.3f animations:^{
        self.startLocationView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/2+1);
        self.endLocationView.frame = CGRectMake(0, self.frame.size.height/2, self.frame.size.width, self.frame.size.height/2);
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)aTextfield {
    [aTextfield resignFirstResponder];//关闭键盘
    [self resetView];
    return YES;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
