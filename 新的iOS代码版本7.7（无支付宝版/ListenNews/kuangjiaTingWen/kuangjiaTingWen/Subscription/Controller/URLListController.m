//
//  URLListController.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2018/4/12.
//  Copyright © 2018年 zhimi. All rights reserved.
//

#import "URLListController.h"
#import "URLWebViewController.h"
#import <WebKit/WebKit.h>

@interface URLListController ()<UITableViewDataSource,UITableViewDelegate,WKNavigationDelegate,WKUIDelegate>
{
    UIView *topView;
    UILabel *tipLable;
    UILabel *urlLable;
}
@property(strong,nonatomic)UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *urlArray;
@property (strong, nonatomic) NSMutableArray *readUrlArray;

@property (copy, nonatomic) NSString *addUrl;
@property (copy, nonatomic) NSString *addTitle;
@property (strong, nonatomic) UIView *addView;
@property (strong, nonatomic) UIView *noDataView;
/**
 隐藏式加载网页数据
 */
@property (strong, nonatomic) WKWebView *webView;
@property (assign, nonatomic) NSInteger imageUrlIndex;
@end

@implementation URLListController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if ([[CommonCode readFromUserD:@"openWebVC"] boolValue] == YES) {
        
        [CommonCode writeToUserD:@(NO) andKey:@"openWebVC"];
    }else{
        [self setUrlListData];
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([CommonCode readFromUserD:@"copyUrl"]) {
        [self getURLString:[CommonCode readFromUserD:@"copyUrl"]];
        [CommonCode writeToUserD:nil andKey:@"copyUrl"];
        [CommonCode writeToUserD:nil andKey:@"copyTitle"];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化使用的朗读器为讯飞
//    if ([CommonCode readFromUserD:use_ifly_reader] == nil) {
        [CommonCode writeToUserD:@(YES) andKey:use_ifly_reader];
//    }
    
    [self setNavBar];
    
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, - SCREEN_HEIGHT, SCREEN_WIDTH, 100)];
    _webView.backgroundColor = [UIColor whiteColor];
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    _webView.scrollView.delegate = self;
    [self.view addSubview:_webView];
    
    [self.view insertSubview:self.tableView atIndex:0];
    
    [self setUrlListData];
    
//    DefineWeakSelf
//    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//        [weakSelf setUrlListData];
//    }];
    
    RegisterNotify(PasteboardGetUrlNotifiction, @selector(getUrl:))
    RegisterNotify(GetTheCoverImageNotification, @selector(getCover:))
}
- (void)setUrlListData{
    //判断是否登录
    if (IS_LOGIN) {
        //是否需要同步本地和服务器数据
        if (![[CommonCode readFromUserD:@"syncUrlList"] boolValue]) {//不需要同步
            //获取本地数据
            [self.noDataView removeFromSuperview];
            self.urlArray = [URLDataModel mj_objectArrayWithKeyValuesArray:[CommonCode readFromUserD:@"urlList"]];
            if (self.urlArray.count == 0) {
                [self setUpNoDataGuideView];
                [NetWorkTool getReadWithAccessToken:AvatarAccessToken sccess:^(NSDictionary *responseObject) {
                    if ([responseObject[status] intValue] == 1) {
                        if (![responseObject[results] isKindOfClass:[NSArray class]]) {
                            [self setUpNoDataGuideView];
                        }else{
                            [self.noDataView removeFromSuperview];
                            //服务器数据
                            NSArray *array = responseObject[results];
                            NSArray *serverModelArray = [URLDataModel mj_objectArrayWithKeyValuesArray:array];
                            //保存数据到本地
                            [CommonCode writeToUserD:[URLDataModel mj_keyValuesArrayWithObjectArray:serverModelArray] andKey:@"urlList"];
                            //转换成frameModel设置到数据源数组
                            NSMutableArray *tempArray = [NSMutableArray array];
                            for (URLDataModel *model in serverModelArray) {
                                UrlListCellFrameModel *frameModel = [[UrlListCellFrameModel alloc] init];
                                frameModel.model = model;
                                [tempArray addObject:frameModel];
                            }
                            self.urlArray = tempArray;
                            [self.tableView reloadData];
                        }
                    }else{
                        [self setUpNoDataGuideView];
                    }
                } failure:^(NSError *error) {
                    [self setUpNoDataGuideView];
                }];
            }else{
                NSMutableArray *tempArray = [NSMutableArray array];
                for (URLDataModel *model in _urlArray) {
                    UrlListCellFrameModel *frameModel = [[UrlListCellFrameModel alloc] init];
                    frameModel.model = model;
                    [tempArray addObject:frameModel];
                }
                _urlArray = tempArray;
                [self.tableView reloadData];
            }
        }else{//需要同步
            [NetWorkTool getReadWithAccessToken:AvatarAccessToken sccess:^(NSDictionary *responseObject) {
                if ([responseObject[status] intValue] == 1) {
                    if (![responseObject[results] isKindOfClass:[NSArray class]]) {
//                        [self setUpNoDataGuideView];
                    }else{
                        [self.noDataView removeFromSuperview];
                        //服务器数据
                        NSArray *array = responseObject[results];
                        NSArray *serverModelArray = [URLDataModel mj_objectArrayWithKeyValuesArray:array];
                        //本地数据
                        NSArray *locationModelArray = [URLDataModel mj_objectArrayWithKeyValuesArray:[CommonCode readFromUserD:@"urlList"]];
                        NSMutableArray *tempLocationModelArray = [NSMutableArray arrayWithArray:locationModelArray];
                        //去除重复数据
                        NSInteger indexCount = locationModelArray.count;
                        NSInteger count = serverModelArray.count;
                        for (int i= 0;i<indexCount;i++) {
                            URLDataModel *locationModel = locationModelArray[i];
                            for (int j = 0;j<count;j++) {
                                URLDataModel *serverModel = serverModelArray[j];
                                if ([locationModel.article_url isEqualToString:serverModel.article_url]) {
                                    [tempLocationModelArray removeObject:locationModel];
                                }
                            }
                        }
                        //拼接数据
                        NSMutableArray *totalArray = [NSMutableArray arrayWithArray:tempLocationModelArray];
                        [totalArray addObjectsFromArray:serverModelArray];
                        //保存数据到本地
                        [CommonCode writeToUserD:[URLDataModel mj_keyValuesArrayWithObjectArray:totalArray] andKey:@"urlList"];
                        //转换成frameModel设置到数据源数组
                        NSMutableArray *tempArray = [NSMutableArray array];
                        for (URLDataModel *model in totalArray) {
                            UrlListCellFrameModel *frameModel = [[UrlListCellFrameModel alloc] init];
                            frameModel.model = model;
                            [tempArray addObject:frameModel];
                            if (model.ID == nil && IS_LOGIN) {//遍历数组，对本地数据进行复传
                                [self uploadUrlDataWithModel:frameModel.model];
                            }
                        }
                        self.urlArray = tempArray;
                        [self.tableView reloadData];
                        //保存值，防止重复同步操作
                        [CommonCode writeToUserD:@(NO) andKey:@"syncUrlList"];
                        
                        [XWAlerLoginView alertWithTitle:@"~同步成功~"];
                    }
                }else{
                    [self setUpNoDataGuideView];
                }
            } failure:^(NSError *error) {
                [self setUpNoDataGuideView];
            }];
        }
    }else{
        //未登录获取本地数据
        [self.noDataView removeFromSuperview];
        self.urlArray = [URLDataModel mj_objectArrayWithKeyValuesArray:[CommonCode readFromUserD:@"urlList"]];
        if (self.urlArray.count == 0) {
            [self setUpNoDataGuideView];
            return;
        }
        NSMutableArray *tempArray = [NSMutableArray array];
        for (URLDataModel *model in _urlArray) {
            UrlListCellFrameModel *frameModel = [[UrlListCellFrameModel alloc] init];
            frameModel.model = model;
            [tempArray addObject:frameModel];
        }
        _urlArray = tempArray;
        [self.tableView reloadData];
    }
}
- (void)setNavBar
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = NO;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_W, 64)];
    [topView setUserInteractionEnabled:YES];
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    
    UILabel *topLab = [[UILabel alloc]initWithFrame:CGRectMake(50, 30, IPHONE_W - 100, 30)];
    topLab.textColor = [UIColor blackColor];
    topLab.font = [UIFont boldSystemFontOfSize:17.0f];
    topLab.text = @"帮你读";
    topLab.backgroundColor = [UIColor clearColor];
    topLab.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:topLab];
    
    UIView *seperatorLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63.5, SCREEN_WIDTH, 0.5)];
    [seperatorLine setBackgroundColor:[UIColor lightGrayColor]];
    [topView addSubview:seperatorLine];
    
    //适配iPhoneX导航栏
    if (IS_IPHONEX) {
        topView.frame = CGRectMake(0, 0, IPHONE_W, 88);
        topLab.frame = CGRectMake(50, 30 + 24, IPHONE_W - 100, 30);
        seperatorLine.frame = CGRectMake(0, 63.5 + 24, SCREEN_WIDTH, 0.5);
    }else{
        topView.frame = CGRectMake(0, 0, IPHONE_W, 64);
        topLab.frame = CGRectMake(50, 30, IPHONE_W - 100, 30);
        seperatorLine.frame = CGRectMake(0, 63.5, SCREEN_WIDTH, 0.5);
    }
}
- (void)setUpNoDataGuideView
{
    if (self.noDataView) {
        [self.noDataView removeFromSuperview];
    }
    _noDataView = [[UIView alloc] initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _noDataView.backgroundColor = ColorWithRGBA(234, 234, 234, 1);
    [self.tableView addSubview:_noDataView];
    
    //可能出现空值报错（NSConcreteMutableAttributedString addAttribute:value:range:: nil value）
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"您的列表是空的\n\n将文章链接保存到“帮你读”\n就可以用听的哦~"]];
    if (str.length > 10) {
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,7)];
        [str addAttribute:NSFontAttributeName value:CUSTOM_FONT_TYPE(19.0) range:NSMakeRange(0,7)];
    }
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, SCREEN_WIDTH - 20, 100)];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.textColor = ColorWithRGBA(100, 100, 100, 1);
    tipLabel.numberOfLines = 0;
    tipLabel.font = CUSTOM_FONT_TYPE(17.0);
    tipLabel.attributedText = str; 
    [_noDataView addSubview:tipLabel];
    
    UIButton *guideBtn = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 140) *0.5, CGRectGetMaxY(tipLabel.frame) + 50, 140, 40)];
    guideBtn.titleLabel.font = CUSTOM_FONT_TYPE(20.0);
    [guideBtn setTitle:@"了解如何保存" forState:UIControlStateNormal];
    [guideBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    guideBtn.backgroundColor = ColorWithRGBA(254, 193, 63, 1);
    [guideBtn addTarget:self action:@selector(guideBtnClicked)];
    [_noDataView addSubview:guideBtn];
    
    //讯飞技术提供提示
    UILabel *iflyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(guideBtn.frame) + 30, SCREEN_WIDTH - 20, 20)];
    iflyLabel.textAlignment = NSTextAlignmentCenter;
    iflyLabel.textColor = [UIColor lightGrayColor];
    iflyLabel.numberOfLines = 0;
    iflyLabel.font = CUSTOM_FONT_TYPE(12.0);
    iflyLabel.text = @"语音技术由科大讯飞提供";
    [_noDataView addSubview:iflyLabel];
}
/**
 点击引导操作跳转引导页
 */
- (void)guideBtnClicked
{
    GuideWebController *guide = [[GuideWebController alloc] init];
    [self presentViewController:guide animated:YES completion:nil];
}

/**
 获取网页封面图
 */
- (void)getCover:(NSNotification *)note
{
    for (UrlListCellFrameModel *frameModel in self.urlArray) {
        if ([frameModel.model.article_url isEqualToString:note.userInfo[@"url"]]) {
            frameModel.model.img_url = [NSString stringWithFormat:@"%@",note.userInfo[@"imageUrl"]];
            frameModel.model = frameModel.model;
            //上传url数据
            if (IS_LOGIN) {
                [self uploadUrlDataWithModel:frameModel.model];
            }
//            break;
        }else if (!frameModel.model.isUpload && IS_LOGIN) {//遍历数组，对本地数据进行复传
            [self uploadUrlDataWithModel:frameModel.model];
        }
    }
    
    [self.tableView reloadData];
    //保存数据
    NSMutableArray *tempArray = [NSMutableArray array];
    for (UrlListCellFrameModel *frameModel in self.urlArray) {
        [tempArray addObject:frameModel.model];
    }
    [CommonCode writeToUserD:[URLDataModel mj_keyValuesArrayWithObjectArray:tempArray] andKey:@"urlList"];
}
- (void)getURLString:(NSString *)URL
{
    BOOL isExist = NO;
    for (UrlListCellFrameModel *frameModel in self.urlArray) {
        if ([frameModel.model.article_url isEqualToString:URL]) {
            isExist = YES;
            break;
        }
    }
    if (!isExist) {
        self.addUrl = URL;
        if ([CommonCode readFromUserD:@"copyTitle"]) {
            self.addTitle = [CommonCode readFromUserD:@"copyTitle"];
        }
        [self addAnimation];
    }
}
- (void)getUrl:(NSNotification *)note
{
    BOOL isExist = NO;
    NSString *urlString = note.userInfo[@"url"];
    for (UrlListCellFrameModel *frameModel in self.urlArray) {
        if ([frameModel.model.article_url isEqualToString:urlString]) {
            isExist = YES;
            break;
        }
    }
    if (!isExist) {
        self.addUrl = urlString;
        if (note.userInfo[@"title"]) {
            self.addTitle = note.userInfo[@"title"];
        }
        [self addAnimation];
    }
}
- (NSMutableArray *)urlArray
{
    if (!_urlArray)
    {
        _urlArray = [NSMutableArray array];
    }
    return _urlArray;
}
- (NSMutableArray *)readUrlArray
{
    if (!_readUrlArray)
    {
        if ([[CommonCode readFromUserD:readedUrlArray] isKindOfClass:[NSArray class]])
        {
            _readUrlArray = [NSMutableArray arrayWithArray:[CommonCode readFromUserD:readedUrlArray]];;
        }else
        {
            _readUrlArray = [NSMutableArray array];
        }
    }
    return _readUrlArray;
}
#pragma mark --- 懒加载
- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, IS_IPHONEX?IPHONEX_TOP_H:64, IPHONE_W, IS_IPHONEX?IPHONE_H - IPHONEX_BOTTOM_H - IPHONEX_TOP_H :IPHONE_H - 49 - 64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = ColorWithRGBA(234, 234, 234, 1);
    }
    return _tableView;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.urlArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UrlListCell *cell = [UrlListCell cellWithTableView:tableView];
    UrlListCellFrameModel *frameModel = self.urlArray[indexPath.row];
    cell.readUrlArray = self.readUrlArray;
    cell.frameModel = frameModel;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[VoiceReader voiceReaderManager] stopReader];
    URLWebViewController *webVC = [[URLWebViewController alloc] init];
    webVC.view.backgroundColor = [UIColor whiteColor];
    webVC.index = indexPath.row;
    DefineWeakSelf
    webVC.getUrlData = ^(NSString *title, NSString *imageUrl,NSString *url) {
        for (UrlListCellFrameModel *frameModel in weakSelf.urlArray) {
            if ([frameModel.model.article_url isEqualToString:url]) {
                frameModel.model.title = frameModel.model.title?frameModel.model.title:title;
                if ([imageUrl containsString:@"http"]) {
                    frameModel.model.img_url = imageUrl;
                }
                
                frameModel.model.domain = frameModel.model.domain;
                frameModel.model = frameModel.model;
                break;
            }
            if ([imageUrl containsString:@"http"]) {
                [weakSelf uploadUrlDataWithModel:frameModel.model];
            }
        }
        //保存数据
        NSMutableArray *tempArray = [NSMutableArray array];
        for (UrlListCellFrameModel *frameModel in weakSelf.urlArray) {
            [tempArray addObject:frameModel.model];
        }
        [CommonCode writeToUserD:[URLDataModel mj_keyValuesArrayWithObjectArray:tempArray] andKey:@"urlList"];
        [weakSelf.tableView reloadData];
    };
    webVC.setReadUrlState = ^(NSString *url) {
        //保存已经读过网页文章数据
        [weakSelf.readUrlArray addObject:url];
        NSSet *set = [NSSet setWithArray:weakSelf.readUrlArray];
        weakSelf.readUrlArray = [NSMutableArray arrayWithArray:[set allObjects]];
        [CommonCode writeToUserD:weakSelf.readUrlArray andKey:readedUrlArray];
        [weakSelf.tableView reloadData];
    };
    //传递朗读数组
    NSMutableArray *tempArray = [NSMutableArray array];
    for (UrlListCellFrameModel *frameModel in self.urlArray) {
        [tempArray addObject:frameModel.model];
    }
    webVC.listArray = tempArray;
    
    UrlListCellFrameModel *frameModel = self.urlArray[indexPath.row];
    webVC.urlString = frameModel.model.article_url;
    if (![frameModel.model.img_url isEqualToString:@""] && frameModel.model.img_url != nil) {
        webVC.isDownCoverImage = YES;
    }
    webVC.imageUrl = [frameModel.model.img_url isEqualToString:@""]?nil:frameModel.model.img_url;
    webVC.isFromTouTiao = frameModel.model.isFromTouTiao;
    [self.navigationController pushViewController:webVC animated:YES];
    
    //保存已经读过网页文章数据
    [self.readUrlArray addObject:frameModel.model.article_url];
    NSSet *set = [NSSet setWithArray:self.readUrlArray];
    self.readUrlArray = [NSMutableArray arrayWithArray:[set allObjects]];
    [CommonCode writeToUserD:self.readUrlArray andKey:readedUrlArray];
    [tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UrlListCellFrameModel *frameModel = self.urlArray[indexPath.row];
    return frameModel.cellHeight;
}
#pragma mark - 删除
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        //获取列表数据frameModel
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.urlArray];
        //删除服务器数据
        UrlListCellFrameModel *frameModels = tempArray[indexPath.row];
        if (frameModels.model.ID && IS_LOGIN) {
            [self deleteUrlDataWithModel:frameModels.model];
        }
        //删除对应选项
        if (tempArray.count == 1) {
            [[VoiceReader voiceReaderManager] stopReader];
        }
//            else{
        [tempArray removeObjectAtIndex:indexPath.row];
//        }
//        NSMutableArray *tempModelArray = [URLDataModel mj_objectArrayWithKeyValuesArray:tempArray];
        //判断是否需要显示引导操作
        
        NSMutableArray *tArray = [NSMutableArray array];
        NSMutableArray *modelArray = [NSMutableArray array];
        for (UrlListCellFrameModel *frameModel in tempArray) {
//            UrlListCellFrameModel *frameModel = [[UrlListCellFrameModel alloc] init];
            frameModel.model = frameModel.model;
            [tArray addObject:frameModel];
            [modelArray addObject:frameModel.model];
        }
        //重新保存数据
        [CommonCode writeToUserD:modelArray.count == 0?nil:[URLDataModel mj_keyValuesArrayWithObjectArray:modelArray] andKey:@"urlList"];
        _urlArray = tArray;
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        [tableView endUpdates];
        
        if (tempArray.count == 0) {
            [self setUpNoDataGuideView];
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self removeAnimation];
}
#pragma mark - 复制链接弹窗动画
- (void)alertAddViewWithUrlString:(NSString *)urlString
{
    UIView *addView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT- IPHONEX_BOTTOM_H, SCREEN_WIDTH, 49)];
    addView.backgroundColor = gMainColor;
    [self.view insertSubview:addView belowSubview:self.tabBarController.tabBar];
    
    self.addView = addView;
    
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 15 - 80, 10, 80, 29)];
    [addBtn setTitle:@"添加" forState:UIControlStateNormal];
    [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addUrlString)];
    addBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    addBtn.layer.borderWidth = 1;
    addBtn.layer.cornerRadius = 5;
    [addView addSubview:addBtn];
    
    tipLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH - 20 - addBtn.width - 15, 20.0)];
    tipLable.font = CUSTOM_FONT_TYPE(14.0);
    tipLable.numberOfLines = 1;
    tipLable.textColor = [UIColor whiteColor];
    tipLable.text = @"将复制的 URL 添加到列表?";
    [addView addSubview:tipLable];
    
    urlLable = [[UILabel alloc] initWithFrame:CGRectMake(tipLable.x, CGRectGetMaxY(tipLable.frame) , SCREEN_WIDTH - 20 - addBtn.width - 15, 15.0)];
    urlLable.font = CUSTOM_FONT_TYPE(14.0);
    urlLable.numberOfLines = 1;
    urlLable.textColor = [UIColor whiteColor];
    urlLable.text = urlString;
    [addView addSubview:urlLable];
}
- (void)addAnimation{
    if (self.addView != nil) {
        [self.addView removeFromSuperview];
    }
        [self alertAddViewWithUrlString:self.addUrl];
        
        [UIView animateWithDuration:0.5 animations:^{
            self.addView.y = IS_IPHONEX? SCREEN_HEIGHT - IPHONEX_BOTTOM_H - 49:SCREEN_HEIGHT - 49 - 49;
        } completion:nil];
}
- (void)removeAnimation{
    if (self.addView != nil) {
        [UIView animateWithDuration:0.5 animations:^{
            self.addView.y = IS_IPHONEX? SCREEN_HEIGHT - IPHONEX_BOTTOM_H:SCREEN_HEIGHT - 49;
        } completion:^(BOOL finished) {
            [self.addView removeFromSuperview];
            self.addView = nil;
        }];
    }
}
- (void)addUrlString
{
    //判断是否已经登录，未登录需要用户登录后才能继续添加（限制5条）
    if ([[CommonCode readFromUserD:@"isLogin"] boolValue] != YES && self.urlArray.count >= 5) {
        [self loginFirst];
        return;
    }
    NSDate *nowDate = [NSDate date];
    NSString *dateString = [nowDate stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    URLDataModel *model = [URLDataModel new];
    model.article_url = self.addUrl;
    if ([CommonCode readFromUserD:@"copyTitle"]) {
        model.title = [CommonCode readFromUserD:@"copyTitle"];
        model.isFromTouTiao = YES;
    }
    model.createtime = dateString;
    model.source = model.source;
    UrlListCellFrameModel *frameModel = [[UrlListCellFrameModel alloc] init];
    frameModel.model = model;
    [self.urlArray insertObject:frameModel atIndex:0];
    
    //移除引导操作提示
    if (_noDataView) {
        [_noDataView removeFromSuperview];
    }
    [self.tableView reloadData];
    //保存数据
    NSMutableArray *tempArray = [NSMutableArray array];
    for (UrlListCellFrameModel *frameModel in self.urlArray) {
        [tempArray addObject:frameModel.model];
    }
    [CommonCode writeToUserD:[URLDataModel mj_keyValuesArrayWithObjectArray:tempArray] andKey:@"urlList"];
    [self removeAnimation];
    
    //清空复制板
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [UIPasteboard removePasteboardWithName:pasteboard.name];
    
    //用webview加载需要的list数据
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.addUrl]]];
}
#pragma mark - 登录弹窗
- (void)loginFirst
{
    UIAlertController *qingshuruyonghuming = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请先登录，才可继续添加哦～" preferredStyle:UIAlertControllerStyleAlert];
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
#pragma mark - 隐藏加载webview
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSString *title = @"document.title";
    
    //这里是js，主要目的实现对url的获取
    NSString *jsGetImages;
    NSString *jsGetH1_H6 =
    @"function getH1_H6(){\
    for(var i=1; i<7; i++){\
        var h = 'h' + i;\
        var obj = document.getElementsByTagName(h);\
        for(var j=0;j<obj.length;j++){\
            if(obj[j].childNodes[0].nodeValue){\
                return obj[j].childNodes[0].nodeValue\
            }\
        }\
    }\
    return '';\
    };";
    if ([webView.URL.host isEqualToString:@"mp.weixin.qq.com"]) {
        jsGetImages =
        @"function getImages(){\
        var objs = document.getElementsByTagName(\"img\");\
        var imgScr = '';\
        for(var i=0;i<objs.length;i++){\
        imgScr = imgScr + objs[i].dataset.src + '+';\
        };\
        return imgScr;\
        };";
        title = @"document.getElementById('activity-name').innerHTML";
    }else{
        jsGetImages =
        @"function getImages(){\
        var objs = document.getElementsByTagName(\"img\");\
        var imgScr = '';\
        for(var i=0;i<objs.length;i++){\
        imgScr = imgScr + objs[i].src + '+';\
        };\
        return imgScr;\
        };";
    }
    //注入js方法
    [webView evaluateJavaScript:jsGetImages completionHandler:nil];
    [webView evaluateJavaScript:jsGetH1_H6 completionHandler:nil];
    //获取网页标题和封面图片
    [NetWorkTool getUrlTitleWithURL:self.addUrl sccess:^(NSDictionary *responseObject) {
        if (![responseObject[results] isEqualToString:@""]) {
            [self getUrlImageWithTitle:responseObject[results]];
        }else{
            [webView evaluateJavaScript:@"getH1_H6()" completionHandler:^(NSString * _Nullable text, NSError * _Nullable error) {
                if (text.length != 0 && text.length < 100) {
                    [self getUrlImageWithTitle:text];
                }else{
                    [webView evaluateJavaScript:title completionHandler:^(NSString * _Nullable text, NSError * _Nullable error) {
                        [self getUrlImageWithTitle:text];
                    }];
                }
            }];
        }
    } failure:^(NSError *error) {
        [webView evaluateJavaScript:@"getH1_H6()" completionHandler:^(NSString * _Nullable text, NSError * _Nullable error) {
            if (text.length != 0 && text.length < 100) {
                [self getUrlImageWithTitle:text];
            }else{
                [webView evaluateJavaScript:title completionHandler:^(NSString * _Nullable text, NSError * _Nullable error) {
                    [self getUrlImageWithTitle:text];
                }];
            }
        }];
    }];
        
    //覆盖粘贴板
    UIPasteboard *gr                             = [UIPasteboard generalPasteboard];
    gr.string = @"";
    gr.URL = [NSURL URLWithString:@""];
}

/**
 获取网页图片方法
 */
- (void)getUrlImageWithTitle:(NSString *)text
{
    DefineWeakSelf
    [_webView evaluateJavaScript:@"getImages()" completionHandler:^(id _Nullable urlResurlt, NSError * _Nullable error) {
        //urlResurlt 就是获取到得所有图片的url的拼接；urlArray就是所有Url的数组
        NSMutableArray *URLArray = [NSMutableArray arrayWithArray:[urlResurlt componentsSeparatedByString:@"+"]];
        if (URLArray.count >= 2) {//去除空字符串
            NSMutableArray *tempArray = [NSMutableArray array];
            for (int i = 0;i<URLArray.count;i++) {
                NSString *string = URLArray[i];
                if (![string isEqualToString:@""]) {
                    [tempArray addObject:string];
                }
            }
            URLArray = tempArray;
        }
        //设置数据数组
        for (UrlListCellFrameModel *frameModel in weakSelf.urlArray) {
            if ([frameModel.model.article_url isEqualToString:weakSelf.addUrl]) {
                frameModel.model.title = frameModel.model.title?frameModel.model.title:[[[text stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
                frameModel.model.domain = frameModel.model.domain;
                frameModel.model = frameModel.model;
            }
        }
        [weakSelf.tableView reloadData];
        //保存到本地数据
        NSMutableArray *tempArray = [NSMutableArray array];
        for (UrlListCellFrameModel *frameModel in weakSelf.urlArray) {
            [tempArray addObject:frameModel.model];
        }
        [CommonCode writeToUserD:[URLDataModel mj_keyValuesArrayWithObjectArray:tempArray] andKey:@"urlList"];
        
        //获取网页封面图片
        [weakSelf getTheCoverImageWithUrlArray:URLArray];
    }];
}
/**
 获取链接的合适封面图片，过滤掉不合适的图片
 
 @param array 链接数组
 */
- (void)getTheCoverImageWithUrlArray:(NSArray *)array
{
    //判断防止数组越界
    if (_imageUrlIndex >= array.count) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GetTheCoverImageNotification object:nil userInfo:@{@"imageUrl":@"",@"url":self.addUrl}];
        return;
    }
    //处理图片URL
    NSString *imageUrl = @"";
    //判断是否包含http
    if (![array[_imageUrlIndex] hasPrefix:@"http"]) {
        imageUrl = [NSString stringWithFormat:@"http:%@",array[_imageUrlIndex]];
    }
    //判断是否包含base64
    if ([array[_imageUrlIndex] hasPrefix:@"base64"]) {
        _imageUrlIndex ++;
        [self getTheCoverImageWithUrlArray:array];
        return;
    }
    if ([array[_imageUrlIndex] isEqualToString:@""]) {
        _imageUrlIndex ++;
        [self getTheCoverImageWithUrlArray:array];
        return;
    }
    //获取图片进行判断
    DefineWeakSelf
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:![imageUrl isEqualToString:@""]?imageUrl:array[_imageUrlIndex]] options:SDWebImageRetryFailed|SDWebImageLowPriority progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (image) {
            if (image.size.width >= 200 && image.size.height >= 150 && (image.size.width/image.size.height)>= 4/3) {
                _imageUrlIndex = 0;
                [[NSNotificationCenter defaultCenter] postNotificationName:GetTheCoverImageNotification object:nil userInfo:@{@"imageUrl":imageURL.description,@"url":weakSelf.addUrl}];
            }else{
                weakSelf.imageUrlIndex ++;
                [weakSelf getTheCoverImageWithUrlArray:array];
            }
        }else{
            weakSelf.imageUrlIndex ++;
            [weakSelf getTheCoverImageWithUrlArray:array];
        }
    }];
}
//上传网页数据
- (void)uploadUrlDataWithModel:(URLDataModel *)model
{
    if (!model.article_url) {
        return;
    }
    DefineWeakSelf
    [NetWorkTool readSaveWithAccessToken:AvatarAccessToken ID:model.ID title:model.title article_url:model.article_url img_url:model.img_url createtime:model.createtime sccess:^(NSDictionary *responseObject) {
        RTLog(@"%@",responseObject[msg]);
        if ([responseObject[status] intValue] == 1) {
            model.ID = responseObject[results][@"id"];
            model.user_id = responseObject[results][@"user_id"];
            model.source = responseObject[results][@"source"];
            [weakSelf.tableView reloadData];
        }
    } failure:^(NSError *error) {
        [weakSelf uploadUrlDataWithModel:model];
    }];
}
//删除网页数据
- (void)deleteUrlDataWithModel:(URLDataModel *)model
{
    if (IS_LOGIN) {
        DefineWeakSelf
        [NetWorkTool readDeleteWithAccessToken:AvatarAccessToken Id:model.ID sccess:^(NSDictionary *responseObject) {
            RTLog(@"%@",responseObject[msg]);
            if ([responseObject[status] intValue] == 1) {
            }
        } failure:^(NSError *error) {
            [weakSelf deleteUrlDataWithModel:model];
        }];
    }
}
@end
