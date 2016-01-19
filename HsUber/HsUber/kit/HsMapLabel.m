//
//  HsMapLabel.m
//  HsUber
//
//  Created by 王金东 on 16/1/19.
//  Copyright © 2016年 王金东. All rights reserved.
//

#import "HsMapLabel.h"

@interface HsMapLabel ()
@property (nonatomic,strong) CAShapeLayer *shapeLayer;

@end
@implementation HsMapLabel


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //创建出CAShapeLayer
    if (self.shapeLayer == nil) {
        self.shapeLayer = [CAShapeLayer layer];
        self.shapeLayer.frame = self.bounds;//设置shapeLayer的尺寸和位置
        self.shapeLayer.fillColor = [UIColor clearColor].CGColor;//填充颜色为ClearColor
       
        //设置线条的宽度和颜色
        self.shapeLayer.lineWidth = 1.0f;
        self.shapeLayer.strokeColor = [UIColor redColor].CGColor;
        //设置stroke起始点
        self.shapeLayer.strokeStart = 0;
        self.shapeLayer.strokeEnd = 0.95;
        
        //创建出圆形贝塞尔曲线
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
        
        //让贝塞尔曲线与CAShapeLayer产生联系
        self.shapeLayer.path = circlePath.CGPath;
        //添加并显示
        [self.layer addSublayer:self.shapeLayer];
    }
    CGPoint center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
     self.shapeLayer.position = center;
}


- (void)startLoading {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.toValue = @(3.14156*2.0);
    animation.duration = 1.0f;
    animation.cumulative = YES;
    animation.repeatCount = MAXFLOAT;
    [self.shapeLayer addAnimation:animation forKey:@"rotationAnimation"];
}

- (void)endLoading {
    [self.shapeLayer removeAllAnimations];
}
@end
