//
//  HsMapViewController.m
//  Hundsun_InternetSellTicket
//
//  Created by 王金东 on 15/6/19.
//  Copyright (c) 2015年 王金东. All rights reserved.
//

#import "HsMapViewController.h"
#import "UIImage+Rotate.h"


@interface RouteAnnotation : BMKPointAnnotation{
    int _type; ///<0:起点 1：终点 2：公交 3：地铁 4:驾乘 5:途经点
    int _degree;
}
@property (nonatomic) int type;
@property (nonatomic) int degree;
@end

@implementation RouteAnnotation

@synthesize type = _type;
@synthesize degree = _degree;
@end

#pragma mark

@interface HsMapViewController ()<BMKMapViewDelegate,BMKRouteSearchDelegate,BMKPoiSearchDelegate,BMKGeoCodeSearchDelegate,BMKLocationServiceDelegate>{
    //想要定位的位置
    BMKPointAnnotation *_pointAnnotation;
    CGPoint _location;
    //路径检索
    BMKRouteSearch *_routesearch;
    //周边检索
    BMKPoiSearch *_poisearch;
    //位置检索
    BMKGeoCodeSearch *_geocodesearch;
    //当前中心点
    CLLocationCoordinate2D _centerLocation;
    //两点距离
    CGFloat _meterBetwwenTwoPoint;
    //定位服务
    BMKLocationService *_locService;
    
}

//用户位置
@property (nonatomic,strong) BMKUserLocation *userLocation;

@end

@implementation HsMapViewController

#pragma mark ---------------------life cycle----------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    if(CGPointEqualToPoint(_location, CGPointZero)){
        CLLocationCoordinate2D coor;
        //经纬度 默认杭州
        coor.latitude = 120.20000;
        coor.longitude = 30.26667;
        [self setCenterLocation:coor];
    }
    //设置当前点
    self.point = _point;
    
    //设置地图缩放级别
    if(self.zoomLevel > 0 )
         _mapView.zoomLevel = self.zoomLevel;
    else
        self.zoomLevel = 11;
    
    //设置是否缩放
    [self setScale:_scale];

    //路径检索
    _routesearch = [[BMKRouteSearch alloc]init];
    //周边检索
    _poisearch = [[BMKPoiSearch alloc]init];
    //地址位置检索
    _geocodesearch = [[BMKGeoCodeSearch alloc]init];
    
    //右侧菜单事件
    if (self.endAddress) {
        [self pointByKeyword:self.endAddress];
    }

}

- (void)startLocation {
    _mapView.showsUserLocation = self.showsUserLocation;
    if (_locService == nil) {
        _locService = [[BMKLocationService alloc]init];
        // Do any additional setup after loading the view from its nib.
    }
    _locService.delegate = self;
    [_locService startUserLocationService];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
     _routesearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _poisearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
     _geocodesearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    if (self.showsUserLocation) {
         [self startLocation];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated ];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _routesearch.delegate = nil; // 不用时，置nil
    _poisearch.delegate = nil; // 不用时，置nil
    _geocodesearch.delegate = nil; // 不用时，置nil
    
    [_locService stopUserLocationService];
    _locService.delegate = nil;
}
- (void)setZoomLevel:(CGFloat)zoomLevel {
    _zoomLevel = zoomLevel;
    _mapView.zoomLevel = self.zoomLevel;
}
- (void)dealloc {
    if (_mapView) {
        self.mapView = nil;
    }
    NSLog(@"mapViewController 释放了");
}

#pragma mark ----------------------delegate-----------------------------------

// 根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation {
    //普通annotation
    if (annotation == _pointAnnotation) {//定位
        NSString *AnnotationViewID = @"renameMark";
        BMKPinAnnotationView *annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
        if (annotationView == nil) {
            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
            // 设置颜色
            annotationView.pinColor = BMKPinAnnotationColorPurple;
            // 从天上掉下效果
            annotationView.animatesDrop = YES;
            // 设置可拖拽
            annotationView.draggable = YES;
        }
        return annotationView;
    }else if ([annotation isKindOfClass:[RouteAnnotation class]]) {//路径规划
        return [self getRouteAnnotationView:mapView viewForAnnotation:(RouteAnnotation*)annotation];
    }else{//周边检索
        // 生成重用标示identifier
        NSString *AnnotationViewID = @"zhoubianMark";
        // 检查是否有重用的缓存
        BMKAnnotationView* annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
        
        // 缓存没有命中，自己构造一个，一般首次添加annotation代码会运行到此处
        if (annotationView == nil) {
            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
            ((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorRed;
            // 设置重天上掉下的效果(annotation)
            ((BMKPinAnnotationView*)annotationView).animatesDrop = YES;
        }
        
        // 设置位置
        annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
        annotationView.annotation = annotation;
        // 单击弹出泡泡，弹出泡泡前提annotation必须实现title属性
        annotationView.canShowCallout = YES;
        // 设置是否可以拖拽
        annotationView.draggable = NO;
        
        return annotationView;
    }
    return nil;
}
/**
 *点中底图空白处会回调此接口
 *@param mapview 地图View
 *@param coordinate 空白处坐标点的经纬度
 */
- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate {
    if (self.onClickedMapBlank) {
        self.onClickedMapBlank();
    }
}

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (self.mapCenterBlock) {
        self.mapCenterBlock(CGPointMake(mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude));
    }
    [self pointByKeywordWithLocation:mapView.centerCoordinate];
}
#pragma mark ------------------定位delagete---------------------
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation {
    [self didUpdateBMKUserLocation:userLocation];
}
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    [_mapView updateLocationData:userLocation];
    if (CGPointEqualToPoint(_location, CGPointZero)) {
        [self setCenterLocation:userLocation.location.coordinate];
    }
    _userLocation = userLocation;
}

#pragma mark BMKRouteSearchDelegate 检索delegate

#define MYBUNDLE_NAME @ "mapapi.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]
#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]

- (NSString*)getMyBundlePath1:(NSString *)filename{
    
    NSBundle  *libBundle = MYBUNDLE ;
    if ( libBundle && filename ){
        NSString * s=[[libBundle resourcePath ] stringByAppendingPathComponent : filename];
        return s;
    }
    return nil ;
}
- (BMKAnnotationView*)getRouteAnnotationView:(BMKMapView *)mapview viewForAnnotation:(RouteAnnotation*)routeAnnotation{
    BMKAnnotationView* view = nil;
    switch (routeAnnotation.type) {
        case 0:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"start_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"start_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_start.png"]];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 1:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"end_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"end_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_end.png"]];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 2:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"bus_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"bus_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_bus.png"]];
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 3:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"rail_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"rail_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_rail.png"]];
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 4:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"route_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"route_node"];
                view.canShowCallout = TRUE;
            } else {
                [view setNeedsDisplay];
            }
            
            UIImage* image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_direction.png"]];
            view.image = [image imageRotatedByDegrees:routeAnnotation.degree];
            view.annotation = routeAnnotation;
            
        }
            break;
        case 5:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"waypoint_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"waypoint_node"];
                view.canShowCallout = TRUE;
            } else {
                [view setNeedsDisplay];
            }
            
            UIImage* image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_waypoint.png"]];
            view.image = [image imageRotatedByDegrees:routeAnnotation.degree];
            view.annotation = routeAnnotation;
        }
            break;
        default:
            break;
    }
    
    return view;
}

- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:1];
        polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        polylineView.lineWidth = 3.0;
        return polylineView;
    }
    return nil;
}

- (void)onGetTransitRouteResult:(BMKRouteSearch*)searcher result:(BMKTransitRouteResult*)result errorCode:(BMKSearchErrorCode)error {
    //清理地图图标
    [self clearMap];
    if(error == BMK_SEARCH_RESULT_NOT_FOUND){
        [self showTipsMessage:@"没有找到检索结果"];
    }else if(error == BMK_SEARCH_NOT_SUPPORT_BUS_2CITY){
        [self showTipsMessage:@"不支持跨城市公交"];
    }else if (error == BMK_SEARCH_NO_ERROR) {
        BMKTransitRouteLine* plan = (BMKTransitRouteLine*)[result.routes objectAtIndex:0];
        // 计算路线方案中的路段数目
        NSUInteger size = [plan.steps count];
        int planPointCounts = 0;
        for (int i = 0; i < size; i++) {
            BMKTransitStep* transitStep = [plan.steps objectAtIndex:i];
            if(i==0){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = @"起点";
                item.type = 0;
                [_mapView addAnnotation:item]; // 添加起点标注
                
            }else if(i==size-1){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.terminal.location;
                item.title = @"终点";
                item.type = 1;
                [_mapView addAnnotation:item]; // 添加起点标注
            }
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.instruction;
            item.type = 3;
            [_mapView addAnnotation:item];
            
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKTransitStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
            
        }
        // 通过points构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_mapView addOverlay:polyLine]; // 添加路线overlay
        delete []temppoints;
        [self mapViewFitPolyLine:polyLine];
    }
}
- (void)onGetDrivingRouteResult:(BMKRouteSearch*)searcher result:(BMKDrivingRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    //清理地图图标
    [self clearMap];
    
    if(error == BMK_SEARCH_RESULT_NOT_FOUND){
        [self showTipsMessage:@"没有找到检索结果"];
    }else  if (error == BMK_SEARCH_NO_ERROR) {
        BMKDrivingRouteLine* plan = (BMKDrivingRouteLine*)[result.routes objectAtIndex:0];
        // 计算路线方案中的路段数目
        NSInteger size = [plan.steps count];
        int planPointCounts = 0;
        for (int i = 0; i < size; i++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:i];
            if(i==0){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = @"起点";
                item.type = 0;
                [_mapView addAnnotation:item]; // 添加起点标注
                
            }else if(i==size-1){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.terminal.location;
                item.title = @"终点";
                item.type = 1;
                [_mapView addAnnotation:item]; // 添加起点标注
            }
            //添加annotation节点
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.entraceInstruction;
            item.degree = transitStep.direction * 30;
            item.type = 4;
            [_mapView addAnnotation:item];
            
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        // 添加途经点
        if (plan.wayPoints) {
            for (BMKPlanNode* tempNode in plan.wayPoints) {
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = tempNode.pt;
                item.type = 5;
                item.title = tempNode.name;
                [_mapView addAnnotation:item];
            }
        }
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
            
        }
        // 通过points构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_mapView addOverlay:polyLine]; // 添加路线overlay
        delete []temppoints;
        [self mapViewFitPolyLine:polyLine];
    }
}


//根据polyline设置地图范围
- (void)mapViewFitPolyLine:(BMKPolyline *) polyLine {
    CGFloat ltX, ltY, rbX, rbY;
    if (polyLine.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyLine.points[0];
    ltX = pt.x, ltY = pt.y;
    rbX = pt.x, rbY = pt.y;
    for (int i = 1; i < polyLine.pointCount; i++) {
        BMKMapPoint pt = polyLine.points[i];
        if (pt.x < ltX) {
            ltX = pt.x;
        }
        if (pt.x > rbX) {
            rbX = pt.x;
        }
        if (pt.y > ltY) {
            ltY = pt.y;
        }
        if (pt.y < rbY) {
            rbY = pt.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(ltX , ltY);
    rect.size = BMKMapSizeMake(rbX - ltX, rbY - ltY);
    [_mapView setVisibleMapRect:rect];
    _mapView.zoomLevel = _mapView.zoomLevel - 0.3;
}

#pragma mark BMKPoiSearchDelegate
#pragma mark -
#pragma mark implement BMKMapViewDelegate

/**
 *根据anntation生成对应的View
 *@param mapView 地图View
 *@param annotation 指定的标注
 *@return 生成的标注View
 */
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view{
    [mapView bringSubviewToFront:view];
    [mapView setNeedsDisplay];
    
    
}
- (void)mapView:(BMKMapView *)mapView didAddAnnotationViews:(NSArray *)views{
   // NSLog(@"didAddAnnotationViews");
    
    
}

#pragma mark -
#pragma mark implement BMKSearchDelegate
- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult*)result errorCode:(BMKSearchErrorCode)error
{
    //清理地图图标
    [self clearMap];
    
    if (error == BMK_SEARCH_NO_ERROR) {
        NSMutableArray *annotations = [NSMutableArray array];
        for (int i = 0; i < result.poiInfoList.count; i++) {
            BMKPoiInfo* poi = [result.poiInfoList objectAtIndex:i];
            BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
            item.coordinate = poi.pt;
            item.title = poi.name;
            [annotations addObject:item];
        }
        [_mapView addAnnotations:annotations];
        [_mapView showAnnotations:annotations animated:YES];
    } else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
       // NSLog(@"起始点有歧义");
    } else {
        // 各种情况的判断。。。
    }
}

#pragma mark BMKGeoCodeSearchDelegate
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    if (error == 0) {
        _pointAnnotation = [[BMKPointAnnotation alloc]init];
        _pointAnnotation.coordinate = result.location;
        _pointAnnotation.title = result.address;
        [_mapView addAnnotation:_pointAnnotation];
        _mapView.centerCoordinate = result.location;
        //移到中心点
        [self setCenterLocation:result.location];
    }
}
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    NSMutableDictionary *locationInfo = nil;
    if (error == BMK_SEARCH_NO_ERROR) {
        locationInfo = [NSMutableDictionary dictionary];
        [locationInfo setValue:result.addressDetail.city forKey:@"city"];
        [locationInfo setValue:result.addressDetail.streetNumber forKey:@"streetNumber"];
        [locationInfo setValue:result.addressDetail.streetName forKey:@"streetName"];
        [locationInfo setValue:result.addressDetail.district forKey:@"district"];
        [locationInfo setValue:result.addressDetail.city forKey:@"city"];
        [locationInfo setValue:result.addressDetail.province forKey:@"province"];
        [locationInfo setValue:result.address forKey:@"address"];
    }
    if (self.reverseGeoCodeResultBlock) {
        self.reverseGeoCodeResultBlock(locationInfo);
    }
}



#pragma mark ----------------------action-------------------------------------
//当前点
- (void)setPoint:(HsMapLocationPoint)point {
    _point = point;
    if(_mapView != nil){
        [self location:CGPointMake(point.latitude, point.longitude) title:point.title subtitle:point.subtitle];
    }
}
//定位
- (void)location:(CGPoint)location title:(const char *)title subtitle:(const char *)subtitle {
    if (CGPointEqualToPoint(location, CGPointZero) ) {
        return;
    }
    _location = location;
    [_mapView removeAnnotation:_pointAnnotation];
    _pointAnnotation = [[BMKPointAnnotation alloc]init];
    CLLocationCoordinate2D coor;
    coor.latitude = location.x;
    coor.longitude = location.y;
    _pointAnnotation.coordinate = coor;
    if (title) {
        _pointAnnotation.title = [NSString stringWithUTF8String:title];
    
    }
    if (subtitle) {
        _pointAnnotation.subtitle = [NSString stringWithUTF8String:subtitle];
    }
    
    [_mapView addAnnotation:_pointAnnotation];
    //移到中心点
    [self setCenterLocation:coor];
    
}

- (void)setCenterLocation:(CLLocationCoordinate2D )center{
    _centerLocation = center;
    [_mapView setCenterCoordinate:center animated:YES];
}
- (void)clearMap{
    NSArray *array = [NSArray arrayWithArray:_mapView.annotations];
    for (BMKPointAnnotation *annotation in array) {
        if (annotation != _pointAnnotation) {
            [_mapView removeAnnotation:annotation];
        }
    }
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
}
#pragma mark 显示公交
- (void)showBusLines {
    if (![HsMapViewController locationServicesEnabled]) {
        [self openGpsSetting];
        return;
    }
    //我的位置
    BMKPlanNode *start = [[BMKPlanNode alloc]init];
    start.pt = _userLocation.location.coordinate;
    
    //终点
    BMKPlanNode *end = [[BMKPlanNode alloc]init];
    end.name = self.endAddress;
    end.cityName = self.city;
    CLLocationCoordinate2D endCoor ;
    endCoor.latitude = _location.x;
    endCoor.longitude = _location.y;
    end.pt = endCoor;
    
    BMKTransitRoutePlanOption *transitRouteSearchOption = [[BMKTransitRoutePlanOption alloc]init];
    transitRouteSearchOption.city = self.city;
    transitRouteSearchOption.from = start;
    transitRouteSearchOption.to = end;
    BOOL flag = [_routesearch transitSearch:transitRouteSearchOption];
    if(flag){
       // ProgressShowTipMessage(@"公交检索成功");
    }else{
        [self showTipsMessage:@"公交站检索失败"];
    }
}
#pragma mark 显示自驾
- (void)showDriveLines {
    if (![HsMapViewController locationServicesEnabled]) {
       [self openGpsSetting];
        return;
    }
    
    //我的位置
    BMKPlanNode *start = [[BMKPlanNode alloc]init];
    start.pt = _userLocation.location.coordinate;
    start.cityName = self.city;
    //终点
    BMKPlanNode *end = [[BMKPlanNode alloc]init];
    end.name = self.endAddress;
    end.cityName = self.city;
    CLLocationCoordinate2D endCoor ;
    endCoor.latitude = _location.x;
    endCoor.longitude = _location.y;
    end.pt = endCoor;
    
    BMKDrivingRoutePlanOption *drivingRouteSearchOption = [[BMKDrivingRoutePlanOption alloc]init];
    drivingRouteSearchOption.from = start;
    drivingRouteSearchOption.to = end;
    BOOL flag = [_routesearch drivingSearch:drivingRouteSearchOption];
    if(flag){
        //ProgressShowTipMessage(@"自驾检索成功");
    }else{
         [self showTipsMessage:@"自驾检索失败"];
    }
}
#pragma mark 显示周边
- (void)showZhouBian:(NSString *)type {
    BMKNearbySearchOption *nearSearchOption = [[BMKNearbySearchOption alloc]init];
    nearSearchOption.pageIndex = 0;
    nearSearchOption.pageCapacity = 20;
    //检索我的周边
    nearSearchOption.location = self.mapView.centerCoordinate;
    nearSearchOption.keyword = type;
    BOOL flag = [_poisearch poiSearchNearBy:nearSearchOption];
    if(flag){
        //ProgressShowTipMessage(@"周边检索成功");
    }else{
       [self showTipsMessage:@"周边检索失败"];
    }
}

- (void)pointByKeyword:(NSString *)keyword {
    BMKGeoCodeSearchOption *geocodeSearchOption = [[BMKGeoCodeSearchOption alloc]init];
    geocodeSearchOption.city= self.city;
    geocodeSearchOption.address = keyword;
    BOOL flag = [_geocodesearch geoCode:geocodeSearchOption];
    if(flag){
        //ProgressShowTipMessage(@"城市检索成功");
    }else{
        [self showTipsMessage:@"城市检索失败"];
    }

}
- (void)pointByKeywordWithLocation:(CLLocationCoordinate2D)location {
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
- (CGFloat)meterBetweenMapPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    BMKMapPoint startMapPoint = BMKMapPointMake(startPoint.x, startPoint.y);
    BMKMapPoint endMapPoint = BMKMapPointMake(endPoint.x, endPoint.y);
    CLLocationDistance dis = BMKMetersBetweenMapPoints(startMapPoint, endMapPoint);
    return dis/1000;
}


- (void)showTipsMessage:(NSString *)message {
   
}

- (void)openGpsSetting {
//    if (IOS8ORLate) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:
//                              NSLocalizedString( @"定位服务未开启", nil )
//                                                        message: NSLocalizedString( @"去设置开启定位服务?", nil )
//                                                       delegate:self
//                                              cancelButtonTitle: NSLocalizedString( @"不去", nil )
//                                              otherButtonTitles: NSLocalizedString( @"去开启", nil ), nil];
//        
//        [alert show];
//    
//    }else{
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:
//                              NSLocalizedString( @"定位服务未开启", nil )
//                                                        message: NSLocalizedString( @"请到【设置>隐私】开启定位服务", nil )
//                                                       delegate:nil
//                                              cancelButtonTitle: NSLocalizedString( @"知道了", nil )
//                                              otherButtonTitles: nil];
//        
//        [alert show];
//    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view {
    if (_onClickedMapAnnotation != nil) {
        self.onClickedMapAnnotation();
    }
}
#pragma mark ----------------------getter-------------------------------------

#pragma mark --------------------------------工具条-----------------------

+ (BOOL)locationServicesEnabled {
    if ([CLLocationManager locationServicesEnabled] &&
        ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized
         || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)) {
            //定位功能可用，开始定位
            return YES;
        }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        return NO;
    }
    return YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
