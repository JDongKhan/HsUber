//
//  HsMapManager.h
//  Hundsun_InternetSellTicket
//
//  Created by 王金东 on 15/6/19.
//  Copyright (c) 2015年 王金东. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI/BMapKit.h>


@protocol HsMapLocationManagerDelegate;

@interface HsMapManager : NSObject

+ (instancetype)sharedInstance;

- (void)start:(id<HsMapLocationManagerDelegate>)delegate;
- (void)stop;

- (void)applicationWillResignActive:(UIApplication *)application;

- (void)applicationDidBecomeActive:(UIApplication *)application;

@end



@protocol HsMapLocationManagerDelegate <NSObject>

@optional

- (void)locationManager:(HsMapManager *)locationManager didFinishedLocation:(BMKUserLocation *)userLocation;//成功

- (void)locationManager:(HsMapManager *)locationManager locationInfo:(NSDictionary *)locationInfo;//位置信息

- (void)locationManager:(HsMapManager *)locationManager didFailWithError:(NSError *)error;//失败

@end