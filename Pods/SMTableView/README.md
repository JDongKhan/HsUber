# SMTableView
对tableview的拓展，通过数据源控制、显示，不用实现一行委托类，当然你可以根据自己的喜好用委托类来实现也行！任何复杂的界面都可以实现


 >IOS项目用的最多的控件中tableview恐怕是有着举足轻重位置，可是你如果还在自己实现tableview的delegate和datasource恐怕就low了，尤其是datasource逻辑大同小异，而本项目就是针对一个数组来分析实现掉datasource，甚至完全靠一个数组源都能全部处理掉tableview的渲染和时间处理。


# -------惯例先上图，图丑但是它不是重点------

![](https://github.com/wangjindong/SMTableView/blob/master/tableview.gif)

对tableview的拓展，通过数据源控制、显示，不用实现一行委托类，当然你可以根据自己的喜好用委托类来实现也行！
tableview用的最多，对tableview的玩法是对tableview的数据结构操作即可！
设计理念：程序由算法和数据结构组成，那么算法只负责逻辑，所有可能来源均有数据结构提供！

该方法支持在数据里面增加tableview的选择事件，默认的cell样式、accessoryView,block等等！


如果你有好的建议请联系我:419591321@qq.com,其实自己仔细琢磨更有意思！

例子:

 ## 第一种
----------------------------------- 
```c
self.tableView.itemsArray = @[
        @"第一条",
        @"第二条",
        @"第3条",
        @"第4条",
        @"第5条",
        @"第6条",
        @"第7条",
        @"第8条",
        @"第9条",
        @"第10条",
        @"第11条"
        ].mutableCopy;
```
## 第二种 可支持自定义model
-----------------------------------
```c
self.secondTableView.keyForTitleView = @"title";
self.secondTableView.itemsArray = @[
                                @{
                                    @"title" : @"第一"
                                },
                                @{
                                    @"title" : @"第二"
                                },
                                @{
                                    @"title" : @"第仨"
                                }
                        ].mutableCopy;
```

## 第三种 支持数组 可支持自定义model
-----------------------------------
```c
self.thirdTableView.keyOfHeadTitle = @"title";
//可以不配置 有默认值
self.thirdTableView.keyForTitleView = @"title";
self.thirdTableView.keyForDetailView = @"detail";
self.thirdTableView.keyOfItemArray = @"items";

self.thirdTableView.sectionable = YES;
self.thirdTableView.tableViewCellClass = [HsBaseTableViewCellStyleValue1 class];
self.thirdTableView.itemsArray = @[
@{
    @"title" : @"人",
    @"items" : @[
    @{
        @"title" : @"美女",
        @"detail" : @"很漂亮"
    },
    @{
        @"title" : @"帅哥",
        @"detail" : @"大长腿"
    }
    ]
},
@{
    @"title" : @"第二",
    @"items" : @[
    @{
        @"title" : @"美女",
        @"detail" : @"很漂亮"
    },
    @{
        @"title" : @"帅哥",
        @"detail" : @"大长腿"
    }
    ]
},
@{
    @"title" : @"第仨",
    @"items" : @[
    @{
        @"title" : @"美女",
        @"detail" : @"很漂亮"
    },
    @{
        @"title" : @"帅哥",
        @"detail" : @"大长腿"
    }
    ]
}
].mutableCopy;
```

        
## 第四种 支持数组 自定义model group样式 cell自定义(model只要key对应上即可，跟字典一样的)
-----------------------------------
```c
__weak UIViewController *weakSelf = self;
self.forthTableView.keyOfHeadTitle = @"title";
self.forthTableView.autoLayout = YES;
self.forthTableView.sectionable = YES;
self.forthTableView.dataSource = self;
self.forthTableView.tableViewCellArray = @[
[UINib nibWithNibName:@"TableViewDemoCell" bundle:nil],
[HsBaseTableViewCellStyleValue1 class]
];
self.forthTableView.itemsArray = @[
@{
    @"title" : @"人",
    @"items" : @[
        [User user:@"张三1" sex:@"男"],
        [User user:@"张三2" sex:@"男"]
    ]
},
@{
    @"title" : @"第二",
    @"items" : @[
    @{
    @"title" : @"美女",
    @"detail" : @"很漂亮",
    HsCellKeySelectedBlock : ^(NSIndexPath *indexPath){
        [weakSelf.navigationController pushViewController:[[HsRefreshTableViewController alloc] init] animated:YES];
        NSLog(@"选中第%ld行",indexPath.row);
    },
    HsBaseTableViewKeyTypeForRow : @(1)//等同于下面的typeForRowAtIndexPath委托方法
},
@{
    @"title" : @"美女",
    @"detail" : @"很漂亮",
    HsBaseTableViewKeyTypeForRow : @(1)//等同于下面的typeForRowAtIndexPath委托方法
}
]
},
@{
    @"title" : @"第仨",
    @"items" : @[
    [User user:@"张三5" sex:@"女"],
    [User user:@"张三6" sex:@"男"]
    ]
}
].mutableCopy;
```
## 第五种 自定义的modal 
-----------------------------------

 >这种就比较复杂 ，如果你的数据源比较复杂，只需要将数组指定给itemArray，然后帮你分析将每行的数据对象传给cell，你只需要重写cell的render方法即可拿到数据进行渲染，在cell重写tableView:(UITableView *)tableView cellInfo:(id)dataInfo即可继续计算行高
 

# CocoaPods

1、在 Podfile 中添加 `pod 'SMTableView'`。

2、执行 `pod install` 或 `pod update`。

3、导入 \<SMTableView/UITableiView+simplify.h\>。
