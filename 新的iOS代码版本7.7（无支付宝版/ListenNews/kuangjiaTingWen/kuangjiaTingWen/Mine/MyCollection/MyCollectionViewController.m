//
//  MyCollectionViewController.m
//  kuangjiaTingWen
//
//  Created by Zhimi on 17/3/9.
//  Copyright © 2017年 贺楠. All rights reserved.
//

#import "MyCollectionViewController.h"
#import "NSDate+TimeFormat.h"
#import "ProjiectDownLoadManager.h"
#import "WHC_Download.h"

@interface MyCollectionViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *helpTableView;
@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@property (nonatomic, strong) UILabel *label;

@property (assign, nonatomic) NSInteger page;
@end

@implementation MyCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.page = 1;
    DefineWeakSelf
    self.helpTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.page = 1;
        [weakSelf setUpData];
    }];
    self.helpTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf getMoreData];
    }];
    [self setUpData];
    [self setUpView];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)setUpData
{
    [NetWorkTool get_collectionWithaccessToken:AvatarAccessToken andPage:@"1" andLimit:@"10" sccess:^(NSDictionary *responseObject) {
        [self.helpTableView.mj_header endRefreshing];
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]]) {
            NSMutableArray *dataArray = [responseObject[@"results"] mutableCopy];
            if (dataArray.count == 10) {
                self.page++;
            }
            //替换id为当前新闻ID
            for (int i = 0; i<self.dataSourceArr.count; i++) {
                NSDictionary *dict = self.dataSourceArr[i];
                [dict setValue:dict[@"post_id"] forKey:@"id"];
            }
            self.dataSourceArr = dataArray;
            [self.helpTableView reloadData];
            
            if (dataArray.count != 0) {
                self.helpTableView.mj_footer.hidden = NO;
            }
            if (dataArray.count < 10) {
                [self.helpTableView.mj_footer endRefreshingWithNoMoreData];
            }else{
                [self.helpTableView.mj_footer resetNoMoreData];
            }
        }
        else{
            if (self.dataSourceArr.count == 0) {
                self.helpTableView.mj_footer.hidden = YES;
                [[BJNoDataView shareNoDataView] showCenterWithSuperView:self.helpTableView icon:nil iconClicked:^{
                    //图片点击回调
                    [self setUpData];//刷新数据
                }];
            }else{
                //有数据
                [[BJNoDataView shareNoDataView] clear];
            }
        }

    } failure:^(NSError *error) {
        [self.helpTableView.mj_header endRefreshing];
        RTLog(@"error:%@",error);
    }];
}
- (void)getMoreData
{
    [NetWorkTool get_collectionWithaccessToken:AvatarAccessToken andPage:[NSString stringWithFormat:@"%ld",self.page] andLimit:@"10" sccess:^(NSDictionary *responseObject) {
        [self.helpTableView.mj_footer endRefreshing];
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]]) {
            NSMutableArray *dataArray = [responseObject[@"results"] mutableCopy];
            if (dataArray.count == 10) {
                self.page++;
            }
            //替换id为当前新闻ID
            for (int i = 0; i<self.dataSourceArr.count; i++) {
                NSDictionary *dict = self.dataSourceArr[i];
                [dict setValue:dict[@"post_id"] forKey:@"id"];
            }
            [self.dataSourceArr addObjectsFromArray:dataArray];
            [self.helpTableView reloadData];
            
            if (dataArray.count != 0) {
                self.helpTableView.mj_footer.hidden = NO;
            }
            if (dataArray.count < 10) {
                [self.helpTableView.mj_footer endRefreshingWithNoMoreData];
            }
        }else
        {
            [self.helpTableView.mj_footer endRefreshingWithNoMoreData];
        }
        
    } failure:^(NSError *error) {
        [self.helpTableView.mj_footer endRefreshing];
        RTLog(@"error:%@",error);
    }];
}
- (void)setUpView{
    
    [self setTitle:@"我的收藏"];
//    [self enableAutoBack];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = NO;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, 64)];
    [topView setUserInteractionEnabled:YES];
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(10, 25, 35, 35);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 10)];
    [leftBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    leftBtn.accessibilityLabel = @"返回";
    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:leftBtn];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [topView addGestureRecognizer:tap];
    
    UILabel *topLab = [[UILabel alloc]initWithFrame:CGRectMake(50, 30, IPHONE_W - 100, 30)];
    topLab.textColor = [UIColor blackColor];
    topLab.font = [UIFont boldSystemFontOfSize:17.0f];
    topLab.text = @"我的收藏";
    topLab.backgroundColor = [UIColor clearColor];
    topLab.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:topLab];
    
    UIView *seperatorLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63.5, SCREEN_WIDTH, 0.5)];
    [seperatorLine setBackgroundColor:[UIColor lightGrayColor]];
    [topView addSubview:seperatorLine];
    
    //适配iPhoneX导航栏
    if (IS_IPHONEX) {
        topView.frame = CGRectMake(0, 0, IPHONE_W, 88);
        leftBtn.frame = CGRectMake(10, 25 + 24, 35, 35);
        topLab.frame = CGRectMake(50, 30 + 24, IPHONE_W - 100, 30);
        seperatorLine.frame = CGRectMake(0, 63.5 + 24, SCREEN_WIDTH, 0.5);
    }else{
        topView.frame = CGRectMake(0, 0, IPHONE_W, 64);
        leftBtn.frame = CGRectMake(10, 25, 35, 35);
        topLab.frame = CGRectMake(50, 30, IPHONE_W - 100, 30);
        seperatorLine.frame = CGRectMake(0, 63.5, SCREEN_WIDTH, 0.5);
    }
    
    [self.view addSubview:self.helpTableView];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.helpTableView addGestureRecognizer:rightSwipe];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deletePostNewsWithIndexPath:(NSIndexPath *)indexPath{
    
    [NetWorkTool del_collectionWithaccessToken:AvatarAccessToken post_id:self.dataSourceArr[indexPath.row][@"post_id"] sccess:^(NSDictionary *responseObject) {
        [self.dataSourceArr removeObjectAtIndex:indexPath.row];
        // 之后更新view
        [self.helpTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } failure:^(NSError *error) {
        //
    }];
}

- (void)SVPDismiss {
    [SVProgressHUD dismiss];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //设置频道类型
    [ZRT_PlayerManager manager].channelType = ChannelTypeMineCollection;
    //设置播放器播放内容类型
    [ZRT_PlayerManager manager].playType = ZRTPlayTypeNews;
    DefineWeakSelf;
    //播放内容切换后刷新对应的播放列表
    [ZRT_PlayerManager manager].playReloadList = ^(NSInteger currentSongIndex) {
        [weakSelf.helpTableView reloadData];
    };
    //设置播放界面打赏view的状态
    [NewPlayVC shareInstance].rewardType = RewardViewTypeNone;
    //判断是否是点击当前正在播放的新闻，如果是则直接跳转
    if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:self.dataSourceArr[indexPath.row][@"post_id"]]){
        
        //设置播放器播放数组
        [ZRT_PlayerManager manager].songList = self.dataSourceArr;
//        [[NewPlayVC shareInstance] reloadInterface];
        [self.navigationController.navigationBar setHidden:YES];
        [self.navigationController pushViewController:[NewPlayVC shareInstance] animated:YES];
    }
    else{
        
        //设置播放器播放数组
        [ZRT_PlayerManager manager].songList = self.dataSourceArr;
        //设置新闻ID
        [NewPlayVC shareInstance].post_id = self.dataSourceArr[indexPath.row][@"post_id"];
        //保存当前播放新闻Index
        ExcurrentNumber = (int)indexPath.row;
        //调用播放对应Index方法
        [[NewPlayVC shareInstance] playFromIndex:ExcurrentNumber];
        //跳转播放界面
        [self.navigationController.navigationBar setHidden:YES];
        [self.navigationController pushViewController:[NewPlayVC shareInstance] animated:YES];
        [tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self deletePostNewsWithIndexPath:indexPath];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  [self.dataSourceArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return IS_IPHONEX?120.0:120.0 / 667 * SCREEN_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NewsCell *cell = [NewsCell cellWithTableView:tableView];
    cell.dataDict = self.dataSourceArr[indexPath.row];
    return cell;
}

- (UITableView *)helpTableView{
    if (_helpTableView == nil) {
        _helpTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,IS_IPHONEX?IPHONEX_TOP_H:64, SCREEN_WIDTH,IS_IPHONEX?SCREEN_HEIGHT - IPHONEX_TOP_H: SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
        [_helpTableView setDelegate:self];
        [_helpTableView setDataSource:self];
        [_helpTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    return _helpTableView;
}

- (NSMutableArray *)dataSourceArr{
    if (!_dataSourceArr) {
        _dataSourceArr = [NSMutableArray array];
    }
    return _dataSourceArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
