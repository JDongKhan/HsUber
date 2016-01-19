//
//  ViewController.m
//  HsUber
//
//  Created by 王金东 on 16/1/19.
//  Copyright © 2016年 王金东. All rights reserved.
//

#import "ViewController.h"
#import "HsMapManager.h"
#import "HsMapViewController.h"
#import "HsTopView.h"
#import "HsBottomView.h"
#import "HsCenterView.h"
#import "HsHistoryView.h"

@interface ViewController ()

@property (nonatomic,strong) UIView *mapView;
@property (nonatomic,strong) HsTopView *topView;
@property (nonatomic,strong) HsBottomView *bottomView;
@property (nonatomic,strong) HsCenterView *centerView;
@property (nonatomic,strong) HsHistoryView *historyView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.modalPresentationCapturesStatusBarAppearance = NO;
    
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.topView];
    [self.view addSubview:self.bottomView];
    [self.mapView addSubview:self.centerView];
    [self.view addSubview:self.historyView];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.centerView.center = CGPointMake(self.mapView.frame.size.width/2,(self.mapView.frame.size.height-self.centerView.frame.size.height)/2);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideNavigation {
    CGRect frame = self.navigationController.navigationBar.frame;
    CGRect topFrame = self.topView.frame;
    CGRect historyFrame = self.historyView.frame;
    if (self.topView.isEditing) {
        frame.origin.y = -64;
        topFrame.origin.y = -20;
        historyFrame.origin.y = CGRectGetMaxY(topFrame)+20;
        
    }else{
        frame.origin.y = 20;
        topFrame.origin.y = 20;
        historyFrame.origin.y = self.view.frame.size.height;
    }
    [UIView animateWithDuration:0.3f animations:^{
        self.navigationController.navigationBar.frame = frame;
        self.topView.frame = topFrame;
        self.historyView.frame = historyFrame;
    } completion:^(BOOL finished) {
       
    }];
}

#pragma mark --------------------------------------
- (void)addMapViewController:(UIViewController *)viewController superView:(UIView *)superView currentCity:(NSString *)city{
    [[HsMapManager sharedInstance] start:nil];
    //添加地图
    HsMapViewController *mapViewController = [[HsMapViewController alloc]init];
    
    //设置位置
    mapViewController.city = city;
    mapViewController.point = HsMapLocationPointMake(30.19, 120.17, nil, nil);
    //设置缩放等级
    mapViewController.zoomLevel = 15;
    
    //加入地图工具
    mapViewController.showTools = YES;
    //显示用户位置
    mapViewController.showsUserLocation = YES;
    
    mapViewController.scale = NO;
    UIView *mapView = mapViewController.view;
    mapView.frame = superView.bounds;
    mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [superView insertSubview:mapView atIndex:0];
    //生命周期
    [viewController addChildViewController:mapViewController];
    
    mapViewController.onClickedMapBlank = ^{
        [self.view endEditing:YES];
        [self.topView resetView];
    };
    mapViewController.mapCenterBlock = ^(CGPoint point){
        [self.centerView startLoading];
    };
    mapViewController.reverseGeoCodeResultBlock = ^(NSDictionary *addressInfo){
        self.topView.topTextField.text = addressInfo[@"address"];
    };
    
}

- (HsTopView *)topView {
    if (_topView == nil) {
        __weak ViewController *vc = self;
        _topView = [[HsTopView alloc] initWithFrame:CGRectMake(20, 20, self.view.frame.size.width-40, 100)];
        _topView.backgroundColor = [UIColor clearColor];
        _topView.editingBlock = ^(BOOL edit){
             [vc hideNavigation];
        };
    }
    return _topView;
}
- (HsBottomView *)bottomView {
    if (_bottomView == nil) {
        _bottomView = [[HsBottomView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-100, self.view.frame.size.width, 100)];
        _bottomView.backgroundColor = [UIColor whiteColor];
        _bottomView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    }
    return _bottomView;
}

- (HsCenterView *)centerView {
    if (_centerView == nil) {
        CGFloat height = 80;
        _centerView = [[HsCenterView alloc] initWithFrame:CGRectMake(0, 0, 250, height)];
    }
    return _centerView;
}
- (UIView *)mapView {
    if (_mapView == nil) {
        _mapView = [[UIView alloc] initWithFrame:CGRectMake(0, -64, self.view.frame.size.width, self.view.frame.size.height+64)];
        [self addMapViewController:self superView:_mapView currentCity:@"杭州"];
    }
    return _mapView;
}
- (HsHistoryView *)historyView {
    if (_historyView == nil) {
        _historyView = [[HsHistoryView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
        _historyView.backgroundColor = [UIColor clearColor];
    }
    return _historyView;
}

@end
