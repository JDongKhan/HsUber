//
//  HsBottomView.m
//  HsUber
//
//  Created by 王金东 on 16/1/19.
//  Copyright © 2016年 王金东. All rights reserved.
//

#import "HsBottomView.h"

#define padding 40

@interface HsBottomView ()


@end

@implementation HsBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    UILabel *lable1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 130, 20)];
    lable1.font = [UIFont systemFontOfSize:14.0f];
    lable1.textAlignment = NSTextAlignmentCenter;
    lable1.text = @"人民优步+";
    [self addSubview:lable1];
    
    UILabel *lable2 = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-150, 10, 130, 20)];
    lable2.font = [UIFont systemFontOfSize:14.0f];
    lable2.textAlignment = NSTextAlignmentCenter;
    lable2.text = @"高级轿车";
    [self addSubview:lable2];
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(padding, self.frame.size.height-80, self.frame.size.width-padding*2, 80)];
    slider.continuous = NO;
    slider.minimumTrackTintColor = [UIColor grayColor];
    slider.maximumTrackTintColor = [UIColor grayColor];
    //slider.minimumValueImage = [UIImage imageNamed:@"icon_faild"];
    [slider setThumbImage:[UIImage imageNamed:@"icon_start"] forState:UIControlStateNormal];
    [slider addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:slider];
    
}
- (void)valueChange:(UISlider *)sender {
    if (sender.value < sender.maximumValue/2) {
        [sender setValue:0 animated:YES];
    }else{
        [sender setValue:sender.maximumValue animated:YES];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
