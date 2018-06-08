//
//  HomePageViewController.m
//  kuangjiaTingWen
//
//  Created by Zhimi on 17/3/20.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import "HomePageViewController.h"
#import "HMSegmentedControl.h"
#import "NSDate+TimeFormat.h"
#import "ProjiectDownLoadManager.h"
#import "WHC_Download.h"
#import "AppDelegate.h"
#import "guanggaoVC.h"
#import "NewReportViewController.h"
#import "ClassViewController.h"

@interface HomePageViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (strong,nonatomic) UIScrollView *scrollView;
@property (strong,nonatomic) HMSegmentedControl *segmentedControl;
@property (strong, nonatomic) UITableView *subScriptionTableView;
@property (strong,nonatomic) UITableView *columnTableView;
@property (strong,nonatomic) UITableView *newsTableView;
@property (strong,nonatomic) UITableView *classroomTableView;
@property (strong,nonatomic) NSMutableArray *subscriptionInfoArr;
@property (strong,nonatomic) NSMutableArray *columnInfoArr;
@property (strong,nonatomic) NSMutableArray *newsInfoArr;
@property (strong,nonatomic) NSMutableArray *classroomInfoArr;
//@property (assign, nonatomic) NSInteger columnIndex;
//@property (assign, nonatomic) NSInteger columnPageSize;
//@property (assign, nonatomic) NSInteger newsIndex;
//@property (assign, nonatomic) NSInteger newsPageSize;
@property (assign, nonatomic) NSInteger classIndex;
@property (assign, nonatomic) NSInteger classPageSize;
@property (strong, nonatomic) NSMutableArray *slideADResult;
@property (strong, nonatomic) NSMutableArray *ztADResult;
@property (strong, nonatomic) NSMutableDictionary *pushNewsInfo;
@property (strong, nonatomic) UIView *lineView;
@property (assign, nonatomic) NSInteger playListIndex;
@property (strong, nonatomic) UIView *refreshTipView;
@property (strong, nonatomic) UILabel *tipLabel;
@property (strong, nonatomic) NSString *maxID;
@property (strong, nonatomic) NSString *minID;
@property (strong, nonatomic) NSString *maxColumnID;
@property (strong, nonatomic) NSString *minColumnID;
@property (strong, nonatomic) NSString *maxSubID;
@property (strong, nonatomic) NSString *minSubID;
@property (strong, nonatomic) NSString *page;
@property (strong, nonatomic) NSString *adNum;
@property (strong, nonatomic) NSString *subPage;
@end

@implementation HomePageViewController
/**
 系统公告方法
 */
//- (void)getSystemNotice
//{
//    RTLog(@"getSystemNotice");
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:@"公告" message:@"请前往App Store升级最新版本" preferredStyle:UIAlertControllerStyleAlert];
//        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            
//        }]];
//        [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"前往App Store" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/id1160650661?mt=8"]];
//            
//        }]];
//        [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
//    });
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.playListIndex = 2;
    //这里是启动app时广告
    RegisterNotify(@"getStartAD", @selector(getStartAD))
//    [self getStartAD];
    [self setUpView];
    [self setUpData];
    
    //系统消息提醒
//    [self getSystemNotice];
    
    //设置盲人模式下拉刷新按钮
    UIButton *VoiceOverBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, IS_IPHONEX? 128:104, SCREEN_WIDTH, 30)];
    [VoiceOverBtn setTitle:@"刷新列表" forState:UIControlStateNormal];
    [VoiceOverBtn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    VoiceOverBtn.backgroundColor = [UIColor clearColor];
    [VoiceOverBtn addTarget:self action:@selector(voiceOver_Clicked)];
    [self.view insertSubview:VoiceOverBtn aboveSubview:self.scrollView];
    
    DefineWeakSelf
    [NewPlayVC shareInstance].reloadNewsTableView = ^{
        [weakSelf.newsTableView reloadData];
    };
    //获取复制链接
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (pasteboard.URL && [pasteboard.URL.description hasPrefix:@"http"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PasteboardGetUrlNotifiction object:nil userInfo:@{@"url":pasteboard.URL.description}];
        [CommonCode writeToUserD:pasteboard.URL.description andKey:@"copyUrl"];
    }else if (pasteboard.string && [pasteboard.string containsString:@"http"]) {
        //适配今日头条
        NSRange endRange = [pasteboard.string rangeOfString:@"http"];
        NSRange titleRange = NSMakeRange(0, endRange.location);
        NSRange httpRange = NSMakeRange(endRange.location, pasteboard.string.length - endRange.location);
        NSString *titleResult = [pasteboard.string substringWithRange:titleRange];
        NSString *httpResult = [pasteboard.string substringWithRange:httpRange];
        [[NSNotificationCenter defaultCenter] postNotificationName:PasteboardGetUrlNotifiction object:nil userInfo:@{@"url":httpResult,@"title":titleResult}];
        [CommonCode writeToUserD:httpResult andKey:@"copyUrl"];
        [CommonCode writeToUserD:titleResult andKey:@"copyTitle"];
    }
}
- (void)voiceOver_Clicked
{
    [self.subScriptionTableView.mj_header beginRefreshing];
    [self.columnTableView.mj_header beginRefreshing];
    [self.newsTableView.mj_header beginRefreshing];
    [self.classroomTableView.mj_header beginRefreshing];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar setTranslucent:YES];
    
    [self.subScriptionTableView reloadData];
    [self.newsTableView reloadData];
    [self.columnTableView reloadData];
}
//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//
//    NSArray *familyNames = [UIFont familyNames];
//    for( NSString *familyName in familyNames )
//    {
//        NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
//        for( NSString *fontName in fontNames )
//        {
//            printf( "\tFont: %s \n", [fontName UTF8String] );
//        }
//    }
//}
- (void)setUpData
{
//    self.columnIndex = 1;
//    self.columnPageSize = 15;
//    self.newsPageSize = 15;
    self.page = @"1";
    self.adNum = @"1";
    self.classIndex = 1;
    self.classPageSize = 15;
    _subscriptionInfoArr = [NSMutableArray new];
    _columnInfoArr = [NSMutableArray new];
    _newsInfoArr = [NSMutableArray new];
    _classroomInfoArr = [NSMutableArray new];
    _slideADResult = [NSMutableArray new];
    _ztADResult = [NSMutableArray new];
    _pushNewsInfo = [NSMutableDictionary new];
    if (IS_LOGIN) {
        [self loadSubScriptionDataWithLoadType:LoadTypeNotData andId:nil];
    }
    [self loadColumnDataWithLoadType:LoadTypeNotData andId:nil];
    [self loadNewsDataWithLoadType:LoadTypeNotData andId:nil];
    [self loadClassData];
    //获取频道列表 - 下载时有用到
    [NetWorkTool getPaoGuoFenLeiLieBiaoWithWhateverSomething:@"q" sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
            NSMutableArray *commonListArr = [NSMutableArray arrayWithArray:responseObject[@"results"]];
            [CommonCode writeToUserD:commonListArr andKey:@"commonListArr"];
        }
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
    }];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadClassList) name:ReloadClassList object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadClassIsBuyList:) name:ReloadNewsIsBuyList object:nil];
    RegisterNotify(ReloadHomeSelectPageData, @selector(reloadSelectedList))
    RegisterNotify(@"loginSccess", @selector(reloadClassList))
    RegisterNotify(@"tuichuLoginSeccess", @selector(reloadClassList))
}

- (void)setUpView{
    [self CustomNavigationBar];
    [self.scrollView addSubview:self.subScriptionTableView];
    [self.scrollView addSubview:self.columnTableView];
    [self.scrollView addSubview:self.newsTableView];
    [self.scrollView addSubview:self.classroomTableView];
    self.newsTableView.mj_footer.hidden = YES;
    [self.view addSubview:self.segmentedControl];
    [self.view addSubview:self.scrollView];
//    [self.view bringSubviewToFront:self.segmentedControl];
    DefineWeakSelf;
    [self.segmentedControl setIndexChangeBlock:^(NSInteger index) {
        if (!IS_LOGIN && index == 0) {
            [weakSelf loginFirst];
            weakSelf.subScriptionTableView.mj_footer = nil;
        }
//        if (weakSelf.columnInfoArr.count == 0) {
//            [weakSelf loadColumnDataWithLoadType:LoadTypeNotData andId:nil];
//        }
//        if (weakSelf.classroomInfoArr.count == 0) {
//            [weakSelf loadClassData];
//        }
//        if (weakSelf.subscriptionInfoArr.count == 0 && IS_LOGIN) {
//            [weakSelf loadSubScriptionDataWithLoadType:LoadTypeNotData andId:nil];
//        }
        [weakSelf.scrollView scrollRectToVisible:CGRectMake(SCREEN_WIDTH * index, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 104 - 49) animated:YES];
    }];
    //TODO:修改适配订阅功能
    [self.segmentedControl setSelectedSegmentIndex:2 animated:YES];
    
    self.subScriptionTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (IS_LOGIN) {
            if (weakSelf.subscriptionInfoArr.count!=0) {
                [weakSelf loadSubScriptionDataWithLoadType:LoadTypeNewData andId:weakSelf.maxSubID];
            }else{
                [weakSelf loadSubScriptionDataWithLoadType:LoadTypeNotData andId:nil];
            }
        }
    }];
    self.subScriptionTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (weakSelf.subscriptionInfoArr.count!=0) {
            [weakSelf loadSubScriptionDataWithLoadType:LoadTypeMoreData andId:weakSelf.minSubID];
        }
    }];
    self.columnTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (weakSelf.columnInfoArr.count!=0) {
            [weakSelf loadColumnDataWithLoadType:LoadTypeNewData andId:weakSelf.maxColumnID];
        }else{
            [weakSelf loadColumnDataWithLoadType:LoadTypeNotData andId:nil];
        }
    }];
    self.columnTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (weakSelf.columnInfoArr.count!=0) {
            [weakSelf loadColumnDataWithLoadType:LoadTypeMoreData andId:weakSelf.minColumnID];
        }
    }];
    self.newsTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (weakSelf.newsInfoArr.count!=0) {
            [weakSelf loadNewsDataWithLoadType:LoadTypeNewData andId:weakSelf.maxID];
        }else{
            [weakSelf loadNewsDataWithLoadType:LoadTypeNotData andId:nil];
        }
    }];
    self.newsTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        if (weakSelf.newsInfoArr.count!=0) {
            [weakSelf loadNewsDataWithLoadType:LoadTypeMoreData andId:weakSelf.minID];
        }
    }];
    self.classroomTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.classIndex = 1;
        [weakSelf loadClassData];
    }];
    self.classroomTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        weakSelf.classIndex ++;
        [weakSelf loadClassData];
    }];
}
- (void)loginFirst
{
    UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您还没登录，无法订阅，请先登录" preferredStyle:UIAlertControllerStyleAlert];
    [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [qingshuruyonghuming addAction:[UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        LoginVC *loginFriVC = [LoginVC new];
        LoginNavC *loginNavC = [[LoginNavC alloc]initWithRootViewController:loginFriVC];
        [loginNavC.navigationBar setBackgroundColor:[UIColor whiteColor]];
        loginNavC.navigationBar.tintColor = [UIColor blackColor];
        [self presentViewController:loginNavC animated:YES completion:nil];
    }]];
    
    [self presentViewController:qingshuruyonghuming animated:YES completion:nil];
}
#pragma mark - setter
- (UIView *)refreshTipView
{
    if (!_refreshTipView) {
        _refreshTipView = [[UIView alloc] initWithFrame:CGRectMake(0, IS_IPHONEX? 128:104, SCREEN_WIDTH, 0)];
        _refreshTipView.backgroundColor = gMainColorRGB;
        
        _tipLabel = [[UILabel alloc] initWithFrame:_refreshTipView.bounds];
        _tipLabel.textColor = [UIColor whiteColor];
        _tipLabel.font = CUSTOM_FONT_TYPE(15.0);
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        [_refreshTipView addSubview:_tipLabel];
    }
    return _refreshTipView;
}
- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,IS_IPHONEX? 128:104, SCREEN_WIDTH, SCREEN_HEIGHT - 104 - 49)];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 4, SCREEN_HEIGHT - 104 - 49);
        _scrollView.delegate = self;
        //TODO:修改适配订阅功能
        [_scrollView scrollRectToVisible:CGRectMake(SCREEN_WIDTH * 2, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 104 - 49) animated:NO];
    }
    return _scrollView;
}

- (HMSegmentedControl *)segmentedControl{
    if (!_segmentedControl) {
        _segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles: @[@"订阅", @"专栏", @"快讯",@"课堂"]];
        _segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        _segmentedControl.frame = CGRectMake(0,IS_IPHONEX?88:64, SCREEN_WIDTH, 40);
        _segmentedControl.backgroundColor = [UIColor whiteColor];
        _segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 30, 0, 30);
        _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
        _segmentedControl.selectionIndicatorLocation =   HMSegmentedControlSelectionIndicatorLocationDown;
        _segmentedControl.selectedSegmentIndex = 2;
        _segmentedControl.verticalDividerEnabled = YES;
        _segmentedControl.verticalDividerColor = [UIColor whiteColor];
        _segmentedControl.selectionIndicatorColor = gTextColorSub;
        _segmentedControl.selectionIndicatorBoxColor = [UIColor whiteColor];
        _segmentedControl.selectionIndicatorHeight = 5.0;
        _segmentedControl.shouldAnimateUserSelection = YES;
        _segmentedControl.verticalDividerWidth = 1.0f;
        [_segmentedControl setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
            if (selected) {
                NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName :gTextDownload,NSFontAttributeName : [UIFont boldSystemFontOfSize:16]}];
                return attString;
            }
            else{
                NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName :gTextColorSub,NSFontAttributeName : [UIFont boldSystemFontOfSize:16]}];
                return attString;
            }
        }];
        [_segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
        
        UIView *downLine = [[UIView alloc]initWithFrame:CGRectMake(15.0 / 375 * IPHONE_W, _segmentedControl.frame.size.height - 1, SCREEN_WIDTH - 30.0 / 375 * IPHONE_W, 0.8)];
        [downLine setBackgroundColor:[UIColor colorWithHue:0.00 saturation:0.00 brightness:0.85 alpha:1.00]];
        [_segmentedControl addSubview:downLine];
    }
    return _segmentedControl;
}
- (UITableView *)subScriptionTableView{
    if (!_subScriptionTableView){
        _subScriptionTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.scrollView.frame.size.height) style:UITableViewStylePlain];
        [_subScriptionTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _subScriptionTableView.delegate = self;
        _subScriptionTableView.dataSource = self;
        _subScriptionTableView.tableFooterView = [UIView new];
    }
    return _subScriptionTableView;
}

- (UITableView *)columnTableView{
    if (!_columnTableView){
        _columnTableView = [[UITableView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, self.scrollView.frame.size.height) style:UITableViewStylePlain];
        [_columnTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _columnTableView.delegate = self;
        _columnTableView.dataSource = self;
        _columnTableView.tableFooterView = [UIView new];
    }
    return _columnTableView;
}

- (UITableView *)newsTableView{
    if (!_newsTableView){
        _newsTableView = [[UITableView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH * 2, 0, SCREEN_WIDTH, self.scrollView.frame.size.height) style:UITableViewStylePlain];
        [_newsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _newsTableView.delegate = self;
        _newsTableView.dataSource = self;
        _newsTableView.tableFooterView = [UIView new];
    }
    return _newsTableView;
}

- (UITableView *)classroomTableView{
    if (!_classroomTableView){
        _classroomTableView = [[UITableView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH * 3, 0, SCREEN_WIDTH, self.scrollView.frame.size.height) style:UITableViewStylePlain];
        [_classroomTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _classroomTableView.delegate = self;
        _classroomTableView.dataSource = self;
        _classroomTableView.tableFooterView = [UIView new];
    }
    return _classroomTableView;
}

#pragma mark - Utiliteis
- (void)loadNewsDataWithLoadType:(LoadType)type andId:(NSString *)Id
{
    if (type == LoadTypeNewData || type == LoadTypeNotData) {
        [self getAD];
        self.newsTableView.mj_footer.hidden = YES;
    }
    DefineWeakSelf;
    NSString *IDType;
    switch (type) {
        case LoadTypeNewData:
            IDType = @"1";
            break;
        case LoadTypeMoreData:
            IDType = @"2";
            break;
        case LoadTypeNotData:
            IDType = nil;
            break;
        default:
            IDType = nil;
            break;
    }
    [NetWorkTool getInformationNewListWithaccessToken:AvatarAccessToken andId:Id == nil?nil:Id andType:IDType andLimit:nil andPage:self.page sccess:^(NSDictionary *responseObject) {
        RTLog(@"%@",responseObject);
        if ([responseObject[status] intValue] == 1){
            if (type == LoadTypeNotData) {
                weakSelf.page = @"2";
                [weakSelf.newsInfoArr addObjectsFromArray:responseObject[results]];
                weakSelf.newsInfoArr = [[NSMutableArray alloc] initWithArray:weakSelf.newsInfoArr];
            }else if (type == LoadTypeNewData) {
                if ([responseObject[results] isKindOfClass:[NSArray class]]) {
                    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:responseObject[results]];
                    [weakSelf refreshTopTipWithTitle:[NSString stringWithFormat:@"听闻更新了%ld条新闻",(unsigned long)tempArray.count]];
                    if ([ZRT_PlayerManager manager].channelType == ChannelTypeHomeChannelTwo) {
                        //增加播放器index
                        [ZRT_PlayerManager manager].currentSongIndex = [ZRT_PlayerManager manager].currentSongIndex + tempArray.count;
                    }
                    //添加数据到数组中
                    [tempArray addObjectsFromArray:weakSelf.newsInfoArr];
                    weakSelf.newsInfoArr = tempArray;
                }else{
                    [weakSelf refreshTopTipWithTitle:@"已更新新闻"];
                }
            }else if (type == LoadTypeMoreData) {
                weakSelf.page = [NSString stringWithFormat:@"%d",[self.page intValue] + 1];
                [weakSelf.newsInfoArr addObjectsFromArray:responseObject[results]];
                weakSelf.newsInfoArr = [[NSMutableArray alloc] initWithArray:weakSelf.newsInfoArr];
            }
            //添加数据到播放器
            if ([ZRT_PlayerManager manager].channelType == ChannelTypeHomeChannelOne) {
                NSMutableArray *dictArray = [NSMutableArray array];
                for (NSDictionary *dict in weakSelf.newsInfoArr) {
                    if (![dict isKindOfClass:[MyClassroomListFrameModel class]]) {
                        if ([dict[@"is_news"] intValue] == 1) {
                            [dictArray addObject:dict];
                        }
                    }
                }
                [ZRT_PlayerManager manager].songList = dictArray;
            }
            //替换推荐课程数据为模型数据
            NSMutableArray *newArray = [weakSelf.newsInfoArr mutableCopy];
            for (int i = 0;i<newArray.count;i++) {
                NSDictionary *dict = newArray[i];
                if (![dict isKindOfClass:[MyClassroomListFrameModel class]]) {
                    if ([dict[@"is_news"] intValue] == 0) {
                        [newArray replaceObjectAtIndex:i withObject:[weakSelf frameModelWithDict:dict]];
                    }else{
                        weakSelf.minID = dict[@"id"];
                    }
                }
            }
            for (int i = 0;i<newArray.count;i++) {
                NSDictionary *dict = newArray[i];
                if (![dict isKindOfClass:[MyClassroomListFrameModel class]]) {
                    if ([dict[@"is_news"] intValue] == 1) {
                        weakSelf.maxID = dict[@"id"];
                        break;
                    }
                }
            }
            weakSelf.newsInfoArr = newArray;
            
            
            weakSelf.newsTableView.mj_footer.hidden = NO;
            [weakSelf.newsTableView reloadData];
            [weakSelf endNewsRefreshing];
        }
        else{
            [weakSelf endNewsRefreshing];
        }
    } failure:^(NSError *error) {
        [weakSelf endNewsRefreshing];
        [weakSelf loadNewsDataWithLoadType:type andId:Id];
    }];
}

/**
 将推荐课程字典数据转换成frame模型数据
 */
- (MyClassroomListFrameModel *)frameModelWithDict:(NSDictionary *)dict
{
    MyClassroomListFrameModel *frameModel = [[MyClassroomListFrameModel alloc] init];
    MyClassroomListModel *model = [MyClassroomListModel mj_objectWithKeyValues:dict];
    frameModel.model = model;
    return frameModel;
}
/**
 下拉刷新提示条
 */
- (void)refreshTopTipWithTitle:(NSString *)title
{
    [self.view insertSubview:self.refreshTipView aboveSubview:self.scrollView];
    self.tipLabel.text = title;
    [UIView animateWithDuration:0.5 animations:^{
        self.refreshTipView.height = 30;
        self.tipLabel.height = 30;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                self.refreshTipView.height = 0;
                self.tipLabel.height = 0;
            } completion:^(BOOL finished) {
                [self.refreshTipView removeFromSuperview];
            }];
        });
    }];
}
- (void)loadSubScriptionDataWithLoadType:(LoadType)type andId:(NSString *)Id
{
    DefineWeakSelf;
    NSString *IDType;
    switch (type) {
        case LoadTypeNewData:
            IDType = @"1";
            break;
        case LoadTypeMoreData:
            IDType = @"2";
            break;
        case LoadTypeNotData:
            IDType = nil;
            break;
        default:
            IDType = nil;
            break;
    }
    [NetWorkTool getPaoGuoSelfWoDeJieMuNewWithaccessToken:AvatarAccessToken andId:Id == nil?nil:Id andType:IDType andLimit:nil sccess:^(NSDictionary *responseObject) {
        RTLog(@"%@",responseObject);
        if ([responseObject[status] intValue] == 1){
            if (type == LoadTypeNotData) {
                if ([responseObject[results] isKindOfClass:[NSArray class]]) {
                    weakSelf.subPage = @"2";
                    [weakSelf.subscriptionInfoArr addObjectsFromArray:responseObject[results]];
                    weakSelf.subscriptionInfoArr = [[NSMutableArray alloc] initWithArray:weakSelf.subscriptionInfoArr];
                    if (weakSelf.subscriptionInfoArr.count != 0) {
                        weakSelf.subScriptionTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                            if (weakSelf.subscriptionInfoArr.count!=0) {
                                [weakSelf loadSubScriptionDataWithLoadType:LoadTypeMoreData andId:weakSelf.minSubID];
                            }
                        }];
                    }
                }
            }else if (type == LoadTypeNewData) {
                if ([responseObject[results] isKindOfClass:[NSArray class]]) {
                    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:responseObject[results]];
                    [weakSelf refreshTopTipWithTitle:[NSString stringWithFormat:@"听闻更新了%ld条订阅",(unsigned long)tempArray.count]];
                    if ([ZRT_PlayerManager manager].channelType == ChannelTypeSubscriptionChannel) {
                        //增加播放器index
                        [ZRT_PlayerManager manager].currentSongIndex = [ZRT_PlayerManager manager].currentSongIndex + tempArray.count;
                    }
                    //添加数据到数组中
                    [tempArray addObjectsFromArray:weakSelf.subscriptionInfoArr];
                    weakSelf.subscriptionInfoArr = tempArray;
                }else{
                    [weakSelf refreshTopTipWithTitle:@"暂无更新专栏"];
                }
            }else if (type == LoadTypeMoreData) {
                if ([responseObject[results] isKindOfClass:[NSArray class]]) {
                    weakSelf.subPage = [NSString stringWithFormat:@"%d",[self.subPage intValue] + 1];
                    [weakSelf.subscriptionInfoArr addObjectsFromArray:responseObject[results]];
                    weakSelf.subscriptionInfoArr = [[NSMutableArray alloc] initWithArray:weakSelf.subscriptionInfoArr];
                    weakSelf.subScriptionTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                        if (weakSelf.subscriptionInfoArr.count!=0) {
                            [weakSelf loadSubScriptionDataWithLoadType:LoadTypeMoreData andId:weakSelf.minSubID];
                        }
                    }];
                }else{
                    [weakSelf refreshTopTipWithTitle:@"暂无更多内容"];
                    [weakSelf.subScriptionTableView.mj_footer endRefreshingWithNoMoreData];
                }
            }
            if ([ZRT_PlayerManager manager].channelType == ChannelTypeSubscriptionChannel) {
                [ZRT_PlayerManager manager].songList = weakSelf.subscriptionInfoArr;
            }
            //替换推荐课程数据为模型数据
            NSMutableArray *newArray = [weakSelf.subscriptionInfoArr mutableCopy];
            weakSelf.minSubID = [newArray lastObject][@"id"];
            weakSelf.maxSubID = [newArray firstObject][@"id"];
            weakSelf.subscriptionInfoArr = newArray;
            weakSelf.subScriptionTableView.mj_footer.hidden = NO;
            [weakSelf.subScriptionTableView reloadData];
            [weakSelf endSubscriptionRefreshing];
        }
        else{
            [weakSelf endSubscriptionRefreshing];
        }
    } failure:^(NSError *error) {
        [weakSelf endSubscriptionRefreshing];
        [weakSelf loadSubScriptionDataWithLoadType:type andId:Id];
    }];
}
- (void)loadColumnDataWithLoadType:(LoadType)type andId:(NSString *)Id
{
    DefineWeakSelf;
    NSString *IDType;
    switch (type) {
        case LoadTypeNewData:
            IDType = @"1";
            break;
        case LoadTypeMoreData:
            IDType = @"2";
            break;
        case LoadTypeNotData:
            IDType = nil;
            break;
        default:
            IDType = nil;
            break;
    }
    [NetWorkTool getColumnListWithaccessToken:AvatarAccessToken andId:Id == nil?nil:Id andType:IDType andPage:self.adNum andLimit:nil sccess:^(NSDictionary *responseObject) {
        if ([responseObject[status] intValue] == 1){
            if (type == LoadTypeNotData) {
                weakSelf.adNum = @"2";
                [weakSelf.columnInfoArr addObjectsFromArray:responseObject[results]];
                weakSelf.columnInfoArr = [[NSMutableArray alloc] initWithArray:weakSelf.columnInfoArr];
            }else if (type == LoadTypeNewData) {
                if ([responseObject[results] isKindOfClass:[NSArray class]]) {
                    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:responseObject[results]];
                    [weakSelf refreshTopTipWithTitle:[NSString stringWithFormat:@"听闻更新了%ld条专栏",(unsigned long)tempArray.count]];
                    if ([ZRT_PlayerManager manager].channelType == ChannelTypeHomeChannelTwo) {
                        //增加播放器index
                        [ZRT_PlayerManager manager].currentSongIndex = [ZRT_PlayerManager manager].currentSongIndex + tempArray.count;
                    }
                    //添加数据到数组中
                    [tempArray addObjectsFromArray:weakSelf.columnInfoArr];
                    weakSelf.columnInfoArr = tempArray;
                }else{
                    [weakSelf refreshTopTipWithTitle:@"已更新专栏"];
                }
            }else if (type == LoadTypeMoreData) {
                weakSelf.adNum = [NSString stringWithFormat:@"%d",[self.adNum intValue] + 1];
                [weakSelf.columnInfoArr addObjectsFromArray:responseObject[results]];
                weakSelf.columnInfoArr = [[NSMutableArray alloc] initWithArray:weakSelf.columnInfoArr];
            }
            if ([ZRT_PlayerManager manager].channelType == ChannelTypeHomeChannelTwo) {
                NSMutableArray *dictArray = [NSMutableArray array];
                for (NSDictionary *dict in weakSelf.columnInfoArr) {
                    if (![dict isKindOfClass:[MyClassroomListFrameModel class]]) {
                        if ([dict[@"is_news"] intValue] == 1) {
                            [dictArray addObject:dict];
                        }
                    }
                }
                [ZRT_PlayerManager manager].songList = dictArray;
            }
            //替换推荐课程数据为模型数据
            NSMutableArray *newArray = [weakSelf.columnInfoArr mutableCopy];
            for (int i = 0;i<newArray.count;i++) {
                NSDictionary *dict = newArray[i];
                if (![dict isKindOfClass:[MyClassroomListFrameModel class]]) {
                    if ([dict[@"is_news"] intValue] == 0) {
                        [newArray replaceObjectAtIndex:i withObject:[weakSelf frameModelWithDict:dict]];
                    }else{
                        weakSelf.minColumnID = dict[@"id"];
                    }
                }
            }
            for (int i = 0;i<newArray.count;i++) {
                NSDictionary *dict = newArray[i];
                if (![dict isKindOfClass:[MyClassroomListFrameModel class]]) {
                    if ([dict[@"is_news"] intValue] == 1) {
                        weakSelf.maxColumnID = dict[@"id"];
                        break;
                    }
                }
            }
            weakSelf.columnInfoArr = newArray;
            weakSelf.columnTableView.mj_footer.hidden = NO;
            [weakSelf.columnTableView reloadData];
            [weakSelf endColumnRefreshing];
        }
        else{
            [weakSelf endColumnRefreshing];
        }
    } failure:^(NSError *error) {
        [weakSelf endColumnRefreshing];
        [weakSelf loadColumnDataWithLoadType:type andId:Id];
    }];
}

- (void)loadClassData{
    NSString *accessToken;
    if (ExdangqianUser.length == 0 || ExdangqianUser == nil){
        accessToken = nil;
    }
    else{
        accessToken = [DSE encryptUseDES:ExdangqianUser];
    }
    DefineWeakSelf;
    //[DSE encryptUseDES:@"tw1499171698533660"]
    [NetWorkTool getClassroomListWithaccessToken:AvatarAccessToken andPage:[NSString stringWithFormat:@"%ld",(long)self.classIndex] andLimit:[NSString stringWithFormat:@"%ld",(long)self.classPageSize] sccess:^(NSDictionary *responseObject) {
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
            if (weakSelf.classIndex == 1) {
                [weakSelf.classroomInfoArr removeAllObjects];
            }
            NSMutableArray *classArray = [self frameWithDataArray:[MyClassroomListModel mj_objectArrayWithKeyValuesArray:responseObject[@"results"]]];
            [weakSelf.classroomInfoArr addObjectsFromArray:classArray];
            weakSelf.classroomInfoArr = [[NSMutableArray alloc]initWithArray:weakSelf.classroomInfoArr];
            [weakSelf.classroomTableView reloadData];
            if (classArray.count < self.classPageSize) {
                [weakSelf.classroomTableView.mj_footer endRefreshingWithNoMoreData];
                [weakSelf.classroomTableView.mj_header endRefreshing];
            }else{
                [weakSelf endClassroomRefreshing];
            }
        }
        else{
            [weakSelf endClassroomRefreshing];
        }
    } failure:^(NSError *error) {
        [weakSelf endClassroomRefreshing];
    }];
    
}
/**
 返回frameArray
 
 @param modeArray 数据模型数组
 @return frame数据模型数组
 */
- (NSMutableArray *)frameWithDataArray:(NSMutableArray *)modeArray
{
    NSMutableArray *array = [NSMutableArray array];
    for (MyClassroomListModel *model in modeArray) {
        MyClassroomListFrameModel *frameModel = [[MyClassroomListFrameModel alloc] init];
        frameModel.model = model;
        [array addObject:frameModel];
    }
    return array;
}
- (void)CustomNavigationBar{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 54) / 2, 35, 54, 25)];
    view.backgroundColor = [UIColor whiteColor];
    view.userInteractionEnabled = YES;
    UIImageView *logo = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 54, 25)];
    [logo setImage:[UIImage imageNamed:@"home_logo"]];
    [view addSubview:logo];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.titleView = view;
    self.navigationController.navigationBarHidden=NO;
    //设置一张透明图片遮盖导航栏底下的黑色线条
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"shadow"]
                                                 forBarPosition:UIBarPositionAny
                                                     barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    [self.lineView setFrame:CGRectMake(segmentedControl.selectedSegmentIndex * (SCREEN_WIDTH )/3 + 30, self.segmentedControl.frame.size.height - 5, (SCREEN_WIDTH)/6, 5)];
}
- (void)endSubscriptionRefreshing{
    [self.subScriptionTableView.mj_header endRefreshing];
    [self.subScriptionTableView.mj_footer endRefreshing];
}
- (void)endColumnRefreshing{
    [self.columnTableView.mj_header endRefreshing];
    [self.columnTableView.mj_footer endRefreshing];
}

- (void)endNewsRefreshing{
    [self.newsTableView.mj_header endRefreshing];
    [self.newsTableView.mj_footer endRefreshing];
}

- (void)endClassroomRefreshing{
    [self.classroomTableView.mj_header endRefreshing];
    [self.classroomTableView.mj_footer endRefreshing];
}

- (void)SVPDismiss {
    [SVProgressHUD dismiss];
}

- (void)getStartAD{
    //获取开屏广告数据，判断屏幕尺寸
    NSDictionary *responseObject = [CommonCode readFromUserD:@"StartAD_Data"];
    if ([responseObject[@"results"] isKindOfClass:[NSArray class]] && responseObject != nil){
        if (TARGETED_DEVICE_IS_IPHONE_480 && [[responseObject[@"results"] firstObject][@"status"] isEqualToString:@"1"]){
            [self openLaunchAD];
        }
        else if (TARGETED_DEVICE_IS_IPHONE_568 &&  [responseObject[@"results"][1] [@"status"] isEqualToString:@"1"]){
            [self openLaunchAD];
        }
        else if (TARGETED_DEVICE_IS_IPHONE_667 &&  [responseObject[@"results"][2] [@"status"] isEqualToString:@"1"]){
            [self openLaunchAD];
        }
        else if (TARGETED_DEVICE_IS_IPHONE_736 &&  [responseObject[@"results"][3] [@"status"] isEqualToString:@"1"]){
            [self openLaunchAD];
        }
        else if (TARGETED_DEVICE_IS_IPAD &&  [responseObject[@"results"][3] [@"status"] isEqualToString:@"1"]){
            [self openLaunchAD];
        }else if (TARGETED_DEVICE_IS_IPHONE_812 &&  [responseObject[@"results"][10][@"status"] isEqualToString:@"1"]){
            [self openLaunchAD];
        }
    }
}

- (void)openLaunchAD{
    guanggaoVC *guangao = [guanggaoVC new];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController pushViewController:guangao animated:NO];
}

- (void)newsItemAction:(UIButton *)sender{
    NSString *term_id;
    NSString *newsType;
    if (sender.tag  == 500) {
        term_id = @"6";
        newsType = @"财经";
    }
    else if (sender.tag == 501){
        term_id = @"4";
        newsType = @"文娱";
    }
    else if (sender.tag == 502){
        term_id = @"8";
        newsType = @"国际";
    }
    else if (sender.tag == 503){
        term_id = @"7";
        newsType = @"科技";
    }
    else if (sender.tag == 504){
        term_id = @"14";
        newsType = @"时政";
    }
    NewReportViewController *newreportVC = [[NewReportViewController alloc]init];
    newreportVC.term_id = term_id;
    newreportVC.NewsTpye = newsType;
    newreportVC.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:newreportVC animated:YES];
}

#pragma mark - NSNotificationAction
- (void)gaibianyanse:(NSNotification *)notification{
    //TODO:订阅添加
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self.subScriptionTableView reloadData];
    }
    else if (self.segmentedControl.selectedSegmentIndex == 1) {
        [self.columnTableView reloadData];
    }
    else if (self.segmentedControl.selectedSegmentIndex == 2){
        [self.newsTableView reloadData];
    }
}

//刷新课堂列表
- (void)reloadClassList
{
    self.classIndex = 1;
    [self loadClassData];
    [self getAD];
}
- (void)reloadClassIsBuyList:(NSNotification *)note
{
    NSString *class_id = note.userInfo[@"class_id"];
    
    if (self.newsInfoArr.count != 0) {
        for (int i = 0;i<self.newsInfoArr.count;i++) {
            NSDictionary *dict = self.newsInfoArr[i];
            if ([dict isKindOfClass:[MyClassroomListFrameModel class]]) {
                MyClassroomListFrameModel *frameModel = self.newsInfoArr[i];
                if ([frameModel.model.ad_id isEqualToString:class_id]) {
                    frameModel.model.is_free = @"1";
                    break;
                }
            }
        }
    }
    if (self.columnInfoArr.count != 0) {
        for (int i = 0;i<self.columnInfoArr.count;i++) {
            NSDictionary *dict = self.columnInfoArr[i];
            if ([dict isKindOfClass:[MyClassroomListFrameModel class]]) {
                MyClassroomListFrameModel *frameModel = self.columnInfoArr[i];
                if ([frameModel.model.ad_id isEqualToString:class_id]) {
                    frameModel.model.is_free = @"1";
                    break;
                }
            }
        }
    }
}
/**
 重复点击刷新首页对应列表
 */
- (void)reloadSelectedList
{
    //TODO:修改适配订阅功能
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self.subScriptionTableView.mj_header beginRefreshing];
    }else if (self.segmentedControl.selectedSegmentIndex == 1) {
        [self.columnTableView.mj_header beginRefreshing];
    }else if (self.segmentedControl.selectedSegmentIndex == 2){
        [self.newsTableView.mj_header beginRefreshing];
    }else{
        [self.classroomTableView.mj_header beginRefreshing];
    }
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSInteger page = self.scrollView.contentOffset.x / pageWidth;
    [self.segmentedControl setSelectedSegmentIndex:page animated:YES];
    
    if (!IS_LOGIN && page == 0) {
        [self loginFirst];
        self.subScriptionTableView.mj_footer = nil;
    }
//    if (self.columnInfoArr.count == 0 && page == 1) {
//        [self loadColumnDataWithLoadType:LoadTypeNotData andId:nil];
//    }
//    if (self.classroomInfoArr.count == 0 && page == 3) {
//        [self loadClassData];
//    }
//    if (self.subscriptionInfoArr.count == 0 && IS_LOGIN && page == 0) {
//        [self loadSubScriptionDataWithLoadType:LoadTypeNotData andId:nil];
//    }
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger numberOfRows = 0;
    if (tableView == self.subScriptionTableView) {
        numberOfRows = [self.subscriptionInfoArr count];
    }
    else if (tableView == self.columnTableView) {
        numberOfRows = [self.columnInfoArr count];
    }
    else if (tableView == self.newsTableView){
        numberOfRows = [self.newsInfoArr count];
    }
    else if (tableView == self.classroomTableView){
        numberOfRows = [self.classroomInfoArr count];
    }
    return numberOfRows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.subScriptionTableView){
        //新闻
        NewsCell *cell = [NewsCell cellWithTableView:tableView];
        if ([self.subscriptionInfoArr count]) {
            cell.dataDict = self.subscriptionInfoArr[indexPath.row];
        }
        return cell;
    }
    else if (tableView == self.columnTableView){
        if ([self.columnInfoArr[indexPath.row] isKindOfClass:[MyClassroomListFrameModel class]]) {
            MyClassroomTableViewCell *cell = [MyClassroomTableViewCell cellWithTableView:tableView];
            cell.hiddenPrice = YES;
            cell.isRecommended = YES;
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            MyClassroomListFrameModel *frameModel = self.columnInfoArr[indexPath.row];
            cell.frameModel = frameModel;
            return cell;
        }else{
            //新闻
            NewsCell *cell = [NewsCell cellWithTableView:tableView];
            if ([self.newsInfoArr count]) {
                cell.dataDict = self.columnInfoArr[indexPath.row];
            }
            return cell;
        }
    }
    else if (tableView == self.newsTableView){
//        static NSString *NewsCellIdentify = @"NewsCellIdentify";
//        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NewsCellIdentify];
//        if (!cell){
//            cell = [tableView dequeueReusableCellWithIdentifier:NewsCellIdentify];
//        }
//        CGFloat offsetY = 0;
//        if (indexPath.row == 0) {
//            offsetY = 30;
//            //新闻频道
//            CGFloat newsItem_width = (SCREEN_WIDTH - 10.0 / 375 * IPHONE_W)/5;
//            NSArray *newsItemTitle = @[@"财经",@"文娱",@"国际",@"科技",@"时政"];
//            for (int i = 0 ; i < 5; i ++) {
//                UIButton *newsItem = [UIButton buttonWithType:UIButtonTypeCustom];
//                [newsItem setFrame:CGRectMake(newsItem_width * i + 5.0 / 375 * IPHONE_W + 5.0, 5, newsItem_width - 5,IS_IPAD?40:25)];
//                [newsItem.layer setMasksToBounds:YES];
//                [newsItem.layer setCornerRadius:IS_IPAD?20:12.5];
//                [newsItem.layer setBorderWidth:0.5];
//                [newsItem.layer setBorderColor:TITLE_COLOR_HEX.CGColor];
//                [newsItem setTitle:newsItemTitle[i] forState:UIControlStateNormal];
//                [newsItem setTitleColor:TITLE_COLOR_HEX forState:UIControlStateNormal];
//                [newsItem.titleLabel setFont:CUSTOM_FONT_TYPE(14.0)];
//                [newsItem setTag:(500+ i)];
//                [newsItem addTarget:self action:@selector(newsItemAction:) forControlEvents:UIControlEventTouchUpInside];
//                [cell.contentView addSubview:newsItem];
//            }
//            return cell;
//        }
//        else{
        if ([self.newsInfoArr[indexPath.row] isKindOfClass:[MyClassroomListFrameModel class]]) {
            MyClassroomTableViewCell *cell = [MyClassroomTableViewCell cellWithTableView:tableView];
            cell.hiddenPrice = YES;
            cell.isRecommended = YES;
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            MyClassroomListFrameModel *frameModel = self.newsInfoArr[indexPath.row];
            cell.frameModel = frameModel;
            return cell;
        }else{
            //新闻
            NewsCell *cell = [NewsCell cellWithTableView:tableView];
            if ([self.newsInfoArr count]) {
                cell.dataDict = self.newsInfoArr[indexPath.row];
            }
            return cell;
        }
    }
    else{
        MyClassroomTableViewCell *cell = [MyClassroomTableViewCell cellWithTableView:tableView];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.hiddenDevider = YES;
        MyClassroomListFrameModel *frameModel = self.classroomInfoArr[indexPath.row];
        cell.frameModel = frameModel;
        return cell;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat heightForRow = 44.0;
    if (tableView == self.subScriptionTableView) {
        heightForRow = IS_IPHONEX?120.0:120.0 / 667 * IPHONE_H;
    }
    else if (tableView == self.columnTableView) {
        if ([self.columnInfoArr[indexPath.row] isKindOfClass:[MyClassroomListFrameModel class]]) {
            MyClassroomListFrameModel *frameModel = self.columnInfoArr[indexPath.row];
            heightForRow = frameModel.cellHeight;
        }else{
            heightForRow = IS_IPHONEX?120.0:120.0 / 667 * IPHONE_H;
        }
    }
    else if (tableView == self.newsTableView){
//        if (indexPath.row == 0) {
//            heightForRow = 30.0;
//        }
//        else{
        if ([self.newsInfoArr[indexPath.row] isKindOfClass:[MyClassroomListFrameModel class]]) {
            MyClassroomListFrameModel *frameModel = self.newsInfoArr[indexPath.row];
            heightForRow = frameModel.cellHeight;
        }else{
            heightForRow = IS_IPHONEX?120.0:120.0 / 667 * IPHONE_H;
        }
//        }
    }
    else if (tableView == self.classroomTableView){
        MyClassroomListFrameModel *frameModel = self.classroomInfoArr[indexPath.row];
        heightForRow = frameModel.cellHeight;
    }
    return heightForRow;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //判断是课堂列表还是新闻列表
    if (tableView == self.classroomTableView) {
        [self pushClassWithIndex:indexPath.row dataArray:self.classroomInfoArr];
    }else{
        //判断是新闻还是专栏
        if (tableView == self.newsTableView) {
            //判断是插入课程还是新闻
//            NSInteger index = indexPath.row - 1;
            if ([self.newsInfoArr[(int)indexPath.row] isKindOfClass:[MyClassroomListFrameModel class]]) {
                [self pushClassWithIndex:(int)indexPath.row dataArray:self.newsInfoArr];
            }else{
                [self pushNewsWithIndex:(int)indexPath.row tableView:tableView];
            }
        }else if (tableView == self.columnTableView) {
            //判断是插入课程还是新闻
            if ([self.columnInfoArr[(int)indexPath.row] isKindOfClass:[MyClassroomListFrameModel class]]) {
                [self pushClassWithIndex:(int)indexPath.row dataArray:self.columnInfoArr];
            }else{
                [self pushNewsWithIndex:(int)indexPath.row tableView:tableView];
            }
        }else if (tableView == self.subScriptionTableView) {
            [self pushNewsWithIndex:(int)indexPath.row tableView:tableView];
        }
    }
}

/**
 跳转课堂判断方法
 */
- (void)pushClassWithIndex:(NSInteger)indexPathRow dataArray:(NSMutableArray *)dataArray
{
    NSDictionary *userInfoDict = [CommonCode readFromUserD:@"dangqianUserInfo"];
    //跳转已购买课堂界面，超级会员可直接跳转课堂已购买界面
    MyClassroomListFrameModel *frameModel = dataArray[indexPathRow];
    if (IS_LOGIN) {
        if ([frameModel.model.is_free isEqualToString:@"1"]||[userInfoDict[results][member_type] intValue] == 2) {
            zhuboXiangQingVCNewController *faxianzhuboVC = [[zhuboXiangQingVCNewController alloc]init];
            faxianzhuboVC.jiemuDescription = frameModel.model.Description;
            faxianzhuboVC.jiemuFan_num = frameModel.model.fan_num;
            faxianzhuboVC.jiemuID = frameModel.model.ID?frameModel.model.ID:frameModel.model.ad_id;
            faxianzhuboVC.jiemuImages = frameModel.model.images;
            faxianzhuboVC.jiemuIs_fan = frameModel.model.is_fan;
            faxianzhuboVC.jiemuMessage_num = frameModel.model.message_num;
            faxianzhuboVC.jiemuName = frameModel.model.name;
            faxianzhuboVC.isfaxian = YES;
            faxianzhuboVC.isClass = YES;
            [self.navigationController pushViewController:faxianzhuboVC animated:YES];
        }
        //跳转未购买课堂界面
        else if ([frameModel.model.is_free isEqualToString:@"0"]){
            ClassViewController *vc = [ClassViewController shareInstance];
            vc.jiemuDescription = frameModel.model.Description;
            vc.jiemuFan_num = frameModel.model.fan_num;
            vc.jiemuID = frameModel.model.ID?frameModel.model.ID:frameModel.model.ad_id;
            vc.jiemuImages = frameModel.model.images;
            vc.jiemuIs_fan = frameModel.model.is_fan;
            vc.jiemuMessage_num = frameModel.model.message_num;
            vc.jiemuName = frameModel.model.name;
            vc.act_id = frameModel.model.ID?frameModel.model.ID:frameModel.model.ad_id;
            vc.listVC = self;
            vc.hidePayBtn = NO;
            [self.navigationController.navigationBar setHidden:YES];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else{//未登录状态
        ClassViewController *vc = [ClassViewController shareInstance];
        vc.jiemuDescription = frameModel.model.Description;
        vc.jiemuFan_num = frameModel.model.fan_num;
        vc.jiemuID = frameModel.model.ID?frameModel.model.ID:frameModel.model.ad_id;
        vc.jiemuImages = frameModel.model.images;
        vc.jiemuIs_fan = frameModel.model.is_fan;
        vc.jiemuMessage_num = frameModel.model.message_num;
        vc.jiemuName = frameModel.model.name;
        vc.act_id = frameModel.model.ID?frameModel.model.ID:frameModel.model.ad_id;
        vc.listVC = self;
        vc.hidePayBtn = NO;
        [self.navigationController.navigationBar setHidden:YES];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

/**
 判断新闻跳转方法
 */
- (void)pushNewsWithIndex:(int)indexPathRow tableView:(UITableView *)tableView
{
    //TODO:修改适配订阅功能
    if (self.segmentedControl.selectedSegmentIndex != 3) {
        self.playListIndex = self.segmentedControl.selectedSegmentIndex;
    }
    
    NSArray *arr;
    int index = 0;
    if (self.playListIndex == 0) {
        index = indexPathRow;
        arr = self.subscriptionInfoArr;
        [ZRT_PlayerManager manager].channelType = ChannelTypeSubscriptionChannel;
    }
    else if (self.playListIndex == 1) {
        index = indexPathRow;
        arr = self.columnInfoArr;
        [ZRT_PlayerManager manager].channelType = ChannelTypeHomeChannelTwo;
    }
    else if (self.playListIndex == 2){
        index = indexPathRow;
        arr = self.newsInfoArr;
        [ZRT_PlayerManager manager].channelType = ChannelTypeHomeChannelOne;
    }
    //设置播放器播放内容类型
    [ZRT_PlayerManager manager].playType = ZRTPlayTypeNews;
    //设置播放器播放完成自动加载更多block
    DefineWeakSelf;
    [ZRT_PlayerManager manager].loadMoreList = ^(NSInteger currentSongIndex) {
        if (weakSelf.playListIndex == 0) {
            [weakSelf loadSubScriptionDataWithLoadType:LoadTypeMoreData andId:weakSelf.maxColumnID];
        }
        else if (weakSelf.playListIndex == 1) {
            [weakSelf loadColumnDataWithLoadType:LoadTypeMoreData andId:weakSelf.maxColumnID];
        }
        else if (weakSelf.playListIndex == 2){
            [weakSelf loadNewsDataWithLoadType:LoadTypeMoreData andId:weakSelf.minID];
        }
    };
    //播放内容切换后刷新对应的播放列表
    [ZRT_PlayerManager manager].playReloadList = ^(NSInteger currentSongIndex) {
        if (weakSelf.playListIndex == 0) {
            [weakSelf.subScriptionTableView reloadData];
        }
        else if (weakSelf.playListIndex == 1) {
            [weakSelf.columnTableView reloadData];
        }
        else if (weakSelf.playListIndex == 2){
            [weakSelf.newsTableView reloadData];
        }
    };
    NSMutableArray *dictArray = [NSMutableArray array];
    //设置播放界面打赏view的状态
    [NewPlayVC shareInstance].rewardType = RewardViewTypeNone;
    //判断是否是点击当前正在播放的新闻，如果是则直接跳转
//    RTLog(@"%@---%@",[CommonCode readFromUserD:@"dangqianbofangxinwenID"],arr[index][@"id"]);
    if ([[CommonCode readFromUserD:@"dangqianbofangxinwenID"] isEqualToString:arr[index][@"id"]]){
        
        [self.navigationController.navigationBar setHidden:YES];
        [self.navigationController pushViewController:[NewPlayVC shareInstance] animated:YES];
    }
    else{
        int j = 0;
        for (int i = 0; i<index+1; i++) {
            NSDictionary *dict = arr[i];
            if ([dict isKindOfClass:[MyClassroomListFrameModel class]]) {
                j++;
            }
        }
        index = index - j;
        RTLog(@"index------------:%d",index);
        for (NSDictionary *dict in arr) {
            if (![dict isKindOfClass:[MyClassroomListFrameModel class]]) {
                [dictArray addObject:dict];
            }
        }
        //设置播放器播放数组
        [ZRT_PlayerManager manager].songList = dictArray;
        //设置新闻ID
        [NewPlayVC shareInstance].post_id = dictArray[index][@"id"];
        //保存当前播放新闻Index
        ExcurrentNumber = (int)index;
        //调用播放对应Index方法
        [[NewPlayVC shareInstance] playFromIndex:ExcurrentNumber];
        //跳转播放界面
        [self.navigationController.navigationBar setHidden:YES];
        [self.navigationController pushViewController:[NewPlayVC shareInstance] animated:YES];
        [tableView reloadData];
    }
}
- (void)getAD{
    //获取轮播图数据
//    [self.ztADResult removeAllObjects];
    [NetWorkTool getNewSlideListWithaccessToken:ExdangqianUser?[DSE encryptUseDES:ExdangqianUser]:@"" sccess:^(NSDictionary *responseObject) {
//        RTLog(@"%@",responseObject);
        if ([responseObject[@"results"] isKindOfClass:[NSArray class]]){
            
            self.slideADResult = responseObject[@"results"];
            [self setupTBCView];
        }
        else{
            self.slideADResult = [NSMutableArray array];
            [self setupTBCView];
        }
        [self.newsTableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}
- (void)setupTBCView{
    if (self.slideADResult.count != 0) {
        CGFloat newsItemH = IS_IPAD?40:25;
        //容器
        UIView *adContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, IS_IPHONEX?162.0 + newsItemH:162.0 / 667 * SCREEN_HEIGHT + newsItemH)];
        adContentView.backgroundColor = [UIColor whiteColor];
        
        //滚动图
        TBCircleScrollView *tbScView = [[TBCircleScrollView alloc] initWithFrame:CGRectMake(15.0 / 375 * IPHONE_W, 0, IPHONE_W - 30.0 / 375 * IPHONE_W, IS_IPHONEX?162.0:162.0 / 667 * SCREEN_HEIGHT) andArr:self.slideADResult];
        tbScView.scrollView.scrollsToTop = NO;
        tbScView.biaozhiStr = @"头条";
        NSMutableArray *imgArr = [[NSMutableArray alloc]init];
        for (int i = 0; i <self.slideADResult.count; i++ ){
            [imgArr addObject:NEWSSEMTPHOTOURL(self.slideADResult[i][@"picture"])];
        }
        tbScView.ztADCount = [imgArr count];
        tbScView.imageArray = [NSArray arrayWithArray:imgArr];
        [adContentView addSubview:tbScView];
        
        //新闻频道
        CGFloat newsItem_width = (SCREEN_WIDTH - 10.0 / 375 * IPHONE_W)/5;
        NSArray *newsItemTitle = @[@"财经",@"文娱",@"国际",@"科技",@"时政"];
        for (int i = 0 ; i < 5; i ++) {
            UIButton *newsItem = [UIButton buttonWithType:UIButtonTypeCustom];
            [newsItem setFrame:CGRectMake(newsItem_width * i + 5.0 / 375 * IPHONE_W + 5.0, IS_IPHONEX?162.0 + 5:162.0 / 667 * SCREEN_HEIGHT + 5, newsItem_width - 5,IS_IPAD?40:25)];
            [newsItem.layer setMasksToBounds:YES];
            [newsItem.layer setCornerRadius:IS_IPAD?20:12.5];
            [newsItem.layer setBorderWidth:0.5];
            [newsItem.layer setBorderColor:TITLE_COLOR_HEX.CGColor];
            [newsItem setTitle:newsItemTitle[i] forState:UIControlStateNormal];
            [newsItem setTitleColor:TITLE_COLOR_HEX forState:UIControlStateNormal];
            [newsItem.titleLabel setFont:CUSTOM_FONT_TYPE(14.0)];
            [newsItem setTag:(500+ i)];
            [newsItem addTarget:self action:@selector(newsItemAction:) forControlEvents:UIControlEventTouchUpInside];
            [adContentView addSubview:newsItem];
        }
        
        [self.newsTableView.tableHeaderView removeFromSuperview];
        self.newsTableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, IS_IPHONEX?162.0 + newsItemH:162.0 / 667 * SCREEN_HEIGHT + newsItemH)];
        [self.newsTableView.tableHeaderView addSubview:adContentView];
        [self.newsTableView reloadData];
    }else{
        CGFloat newsItemH = IS_IPAD?40:25;
        //容器
        UIView *adContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, newsItemH)];
        adContentView.backgroundColor = [UIColor whiteColor];
        //新闻频道
        CGFloat newsItem_width = (SCREEN_WIDTH - 10.0 / 375 * IPHONE_W)/5;
        NSArray *newsItemTitle = @[@"财经",@"文娱",@"国际",@"科技",@"时政"];
        for (int i = 0 ; i < 5; i ++) {
            UIButton *newsItem = [UIButton buttonWithType:UIButtonTypeCustom];
            [newsItem setFrame:CGRectMake(newsItem_width * i + 5.0 / 375 * IPHONE_W + 5.0, IS_IPHONEX?162.0 + 5:162.0 / 667 * SCREEN_HEIGHT + 5, newsItem_width - 5,IS_IPAD?40:25)];
            [newsItem.layer setMasksToBounds:YES];
            [newsItem.layer setCornerRadius:IS_IPAD?20:12.5];
            [newsItem.layer setBorderWidth:0.5];
            [newsItem.layer setBorderColor:TITLE_COLOR_HEX.CGColor];
            [newsItem setTitle:newsItemTitle[i] forState:UIControlStateNormal];
            [newsItem setTitleColor:TITLE_COLOR_HEX forState:UIControlStateNormal];
            [newsItem.titleLabel setFont:CUSTOM_FONT_TYPE(14.0)];
            [newsItem setTag:(500+ i)];
            [newsItem addTarget:self action:@selector(newsItemAction:) forControlEvents:UIControlEventTouchUpInside];
            [adContentView addSubview:newsItem];
        }
        
        [self.newsTableView.tableHeaderView removeFromSuperview];
        self.newsTableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,newsItemH)];
        [self.newsTableView.tableHeaderView addSubview:adContentView];
        [self.newsTableView reloadData];
    }
}
@end
