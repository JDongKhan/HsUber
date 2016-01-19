//
//  HsHistoryView.m
//  HsUber
//
//  Created by 王金东 on 16/1/19.
//  Copyright © 2016年 王金东. All rights reserved.
//

#import "HsHistoryView.h"
#import <tableViewSimplify/UITableView+simplify.h>

@interface HsHistoryView ()<HsBaseTableViewDataSource,HsBaseTableViewDelegate>

@property (nonatomic,strong) UITableView *tableView;

@end
@implementation HsHistoryView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.tableView = [[UITableView alloc] initWithFrame:self.bounds];
    self.tableView.baseDataSource = self;
    self.tableView.baseDelegate = self;
    self.tableView.enableSimplify = YES;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.tableView];
    self.tableView.itemsArray = @[@"历史1",@"历史1"].mutableCopy;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
