//
//  HsCenterView.m
//  HsUber
//
//  Created by 王金东 on 16/1/19.
//  Copyright © 2016年 王金东. All rights reserved.
//

#import "HsCenterView.h"
#import "HsMapLabel.h"

@interface HsCenterView (){
    CGRect _oldContentFrame;
    CGRect _oldLabelFrame;
    CGRect _oldUsedButtonFrame;
}
@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong) HsMapLabel *timeLabel;
@property (nonatomic,strong) UIButton *usedButton;
@property (nonatomic,strong) UIView *locationView;

@end

@implementation HsCenterView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    _oldContentFrame = CGRectMake(0, 0, self.frame.size.width, 60);
    _oldLabelFrame = CGRectMake(15, 5, _oldContentFrame.size.height-10, _oldContentFrame.size.height-10);
    _oldUsedButtonFrame = CGRectMake(CGRectGetMaxX(_oldLabelFrame), 0, _oldContentFrame.size.width-CGRectGetMaxX(_oldLabelFrame), _oldContentFrame.size.height);
    
    
    self.contentView = [[UIView alloc] init];
    [self addSubview:self.contentView];
    

    self.timeLabel = [[HsMapLabel alloc] init];
    [self.contentView addSubview:self.timeLabel];

    self.usedButton = [[UIButton alloc] init];
    [self.contentView addSubview:self.usedButton];
    
    self.locationView = [[UIView alloc] init];

    [self addSubview:self.locationView];
    
    [self setStyle];
}
- (void)setStyle {
    [self reset:@(NO)];
    self.contentView.layer.masksToBounds = YES;
    self.contentView.backgroundColor = [UIColor blackColor];
    self.contentView.layer.cornerRadius = self.contentView.frame.size.height/2;
    
    self.timeLabel.font = [UIFont systemFontOfSize:14.0f];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.numberOfLines = 2;
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.text = @"1\n分钟";
    
    [self.usedButton addTarget:self action:@selector(yuding) forControlEvents:UIControlEventTouchUpInside];
    
    self.locationView.backgroundColor = [UIColor blackColor];
    self.locationView.frame = CGRectMake((self.frame.size.width-2)/2, CGRectGetMaxY(self.contentView.frame), 2, self.frame.size.height-CGRectGetMaxY(self.contentView.frame));
}

- (void)yuding {
 
}

- (void)startLoading {
    [self.timeLabel startLoading];
    self.timeLabel.hidden = NO;
    self.usedButton.hidden = YES;
    [UIView animateWithDuration:0.3f animations:^{
        self.contentView.frame = CGRectMake(0, 0, self.contentView.frame.size.height, self.contentView.frame.size.height);
        self.contentView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        self.timeLabel.frame = self.contentView.bounds;;
    }];
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(suiji) object:nil];
    [self performSelector:@selector(suiji) withObject:nil afterDelay:3.0f];
}
- (void)suiji {
    int i = arc4random()%100;
    if (i % 2 == 0) {
        [self showFail:@"附近暂无可用车辆"];
    }else {
        [self reset:@(YES)];
    }
}
- (void)showFail:(NSString *)title {
    self.usedButton.hidden = NO;
    self.timeLabel.hidden = YES;
    NSDictionary *attribute = @{NSFontAttributeName: self.usedButton.titleLabel.font};
    
    CGSize retSize = [title boundingRectWithSize:CGSizeMake(200, 20)
                                             options:
                      NSStringDrawingTruncatesLastVisibleLine |
                      NSStringDrawingUsesLineFragmentOrigin |
                      NSStringDrawingUsesFontLeading
                                          attributes:attribute
                                             context:nil].size;
    void(^block)(void) = ^{
        self.contentView.frame = CGRectMake(0, 0, retSize.width+20, _oldContentFrame.size.height);
        self.contentView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        self.usedButton.frame = self.contentView.bounds;
        [self.usedButton setTitle:title forState:UIControlStateNormal];
        self.usedButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    };
    [UIView animateWithDuration:0.3f animations:^{
        block();
    }];
}

- (void)reset:(NSNumber *)animal {
    self.usedButton.hidden = NO;
    self.timeLabel.hidden = NO;
    void(^block)(void) = ^{
        self.contentView.frame = _oldContentFrame;
        self.contentView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        self.timeLabel.frame = _oldLabelFrame;
        self.usedButton.frame = _oldUsedButtonFrame;
        self.usedButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.usedButton setTitle:@"点击用车" forState:UIControlStateNormal];
        [self.timeLabel endLoading];
    };
    if (animal.boolValue) {
        [UIView animateWithDuration:0.3f animations:^{
            block();
        }];
    }else{
        block();
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
