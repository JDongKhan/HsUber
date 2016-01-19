//
//  HsMapManager.m
//  Hundsun_InternetSellTicket
//
//  Created by 王金东 on 15/6/19.
//  Copyright (c) 2015年 王金东. All rights reserved.
//

#import "HsMapManager.h"
#import <BaiduMapAPI/BMKMapView.h>


@interface HsMapManager ()<BMKGeneralDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate>

@property (nonatomic,strong) BMKMapManager *mapManager;
@property (nonatomic,strong) BMKGeoCodeSearch *geocodesearch;
@property (nonatomic,strong) BMKLocationService *locService;
@property (nonatomic,weak) id<HsMapLocationManagerDelegate> delegate;

@end

@implementation HsMapManager
+ (instancetype)sharedInstance{
    static dispatch_once_t once;
    static HsMapManager * __singleton__;
    dispatch_once( &once, ^{
        __singleton__ = [[self alloc] init];
        __singleton__.mapManager = [[BMKMapManager alloc]init];
        BOOL ret = [__singleton__.mapManager start:@"6tfyZM3T2V5PFy8eNFDdGH1F" generalDelegate:__singleton__];
        if (!ret) {
            NSLog(@"manager start failed!");
        }
        
    });
    return __singleton__;
}

- (void)start:(id<HsMapLocationManagerDelegate>)delegate{
    //设置定位精确度，默认：kCLLocationAccuracyBest
    [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    //指定最小距离更新(米)，默认：kCLDistanceFilterNone
    [BMKLocationService setLocationDistanceFilter:100.f];
    [self stop];
    if (self.locService == nil) {
        self.locService = [[BMKLocationService alloc]init];
        // Do any additional setup after loading the view from its nib.
    }
    self.locService.delegate = self;
    self.delegate = delegate;
    [_locService startUserLocationService];
}
- (void)stop {
    self.locService.delegate = nil;
    [self.locService stopUserLocationService];
    self.locService = nil;
}
- (void)applicationWillResignActive:(UIApplication *)application {
     [BMKMapView willBackGround];//当应用即将后台时调用，停止一切调用opengl相关的操作
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [BMKMapView didForeGround];//当应用恢复前台状态时调用，回复地图的渲染和opengl相关的操作
}



- (void)onGetNetworkState:(int)iError {
    if (0 == iError) {
        NSLog(@"联网成功");
    }
    else{
        NSLog(@"onGetNetworkState %d",iError);
    }
    
}

- (void)onGetPermissionState:(int)iError {
    if (0 == iError) {
        NSLog(@"授权成功");
    }
    else {
        NSLog(@"onGetPermissionState %d",iError);
    }
}


#pragma mark ------------------定位delagete---------------------
/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)willStartLocatingUser {
    //NSLog(@"start locate");
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation {
    // NSLog(@"heading is %@",userLocation.heading);
//    [self stop];
//    if (self.delegate && [self.delegate respondsToSelector:@selector(locationManager:didFinishedLocation:)]) {
//        [self.delegate locationManager:self didFinishedLocation:userLocation];
//    }
//    if(self.delegate && [self.delegate respondsToSelector:@selector(locationManager:locationInfo:)]){
//        [self reverseGeocode:userLocation.location.coordinate];
//    }
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    [self stop];
    if (self.delegate && [self.delegate respondsToSelector:@selector(locationManager:didFinishedLocation:)]) {
        [self.delegate locationManager:self didFinishedLocation:userLocation];
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(locationManager:locationInfo:)]){
        [self reverseGeocode:userLocation.location.coordinate];
    }
}

/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)didStopLocatingUser {
    // NSLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error {
    NSLog(@"location error");
    if (self.delegate && [self.delegate respondsToSelector:@selector(locationManager:didFailWithError:)]) {
        [self.delegate locationManager:self didFailWithError:nil];
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(locationManager:locationInfo:)]){
        [self.delegate locationManager:self locationInfo:nil];
    }
}

//获取位置
-(void)reverseGeocode:(CLLocationCoordinate2D)location {
    self.geocodesearch = [[BMKGeoCodeSearch alloc]init];
    self.geocodesearch.delegate = self;
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = location;
    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
}
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    if (error == BMK_SEARCH_NO_ERROR) {
        NSMutableDictionary *locationInfo = [NSMutableDictionary dictionary];
        [locationInfo setValue:result.addressDetail.city forKey:@"city"];
        [locationInfo setValue:result.addressDetail.streetNumber forKey:@"streetNumber"];
        [locationInfo setValue:result.addressDetail.streetName forKey:@"streetName"];
        [locationInfo setValue:result.addressDetail.district forKey:@"district"];
        [locationInfo setValue:result.addressDetail.city forKey:@"city"];
        [locationInfo setValue:result.addressDetail.province forKey:@"province"];
        [self.delegate locationManager:self locationInfo:locationInfo];
    }else{
        [self.delegate locationManager:self locationInfo:nil];
    }
}


@end
