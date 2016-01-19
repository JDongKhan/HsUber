//
//  HsTopView.h
//  HsUber
//
//  Created by 王金东 on 16/1/19.
//  Copyright © 2016年 王金东. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HsTopView : UIView

@property (nonatomic,weak,readonly) UITextField *topTextField;

@property (nonatomic,strong) UITextField *startLocationView;

@property (nonatomic,strong) UITextField *endLocationView;
@property (nonatomic,assign,getter=isEditing) BOOL editing;

//地图中心点
@property (copy, nonatomic) void(^editingBlock)(BOOL edit);

- (void)resetView ;

@end
