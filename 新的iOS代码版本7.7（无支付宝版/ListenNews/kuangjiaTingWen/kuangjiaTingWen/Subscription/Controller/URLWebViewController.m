//
//  URLWebViewController.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2018/4/12.
//  Copyright © 2018年 zhimi. All rights reserved.
//

#import "URLWebViewController.h"
#import "VoiceReader.h"
#import "ShareView.h"
#import "ShareAlertView.h"
#import "UIImage+compress.h"

@interface URLWebViewController ()<WKNavigationDelegate,WKUIDelegate,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>
{
    UIView *topView;
    UIView *dibuView;
    //底部收藏按钮
    UIButton *bofangRateBtn;
    //播放上一首
    UIButton *bofangLeftBtn;
    //腾讯分享对象
    TencentOAuth *tencentOAuth;
}
//系统自带语音朗读
@property (strong, nonatomic) VoiceReader *reader;
//讯飞朗读
@property (strong, nonatomic) IflyVoiceReader *ifly_reader;

@property (strong, nonatomic) WKWebView *webView;
//播放下一首
@property (strong, nonatomic) UIButton *bofangRightBtn;
//播放开始/暂停
@property (strong, nonatomic) UIButton *bofangCenterBtn;
/**分享*/
@property (strong, nonatomic) UIButton *rightBtn;
/**
 倍数更改tableView
 */
@property(strong,nonatomic) UITableView *playSpeedTableView;
/**
 发音人更改tableView
 */
@property(strong,nonatomic) UITableView *voicerTableView;
/**
 发音选项更改tableView
 */
@property(strong,nonatomic) UITableView *changeTableView;
/**
 倍数弹窗容器
 */
@property (strong, nonatomic) CustomAlertView *alertView;
/**
 倍数数组
 */
@property (strong, nonatomic) NSMutableArray *speedArray;
@property (strong, nonatomic) NSMutableArray *urlArray;

@property (assign, nonatomic) CGFloat lastContenOffsetY;
@property (strong, nonatomic) NSString *Title;
@property (strong, nonatomic) NSString *content;
@property (assign, nonatomic) NSInteger imageUrlIndex;
@end

@implementation URLWebViewController
- (NSMutableArray *)urlArray
{
    if (!_urlArray) {
        _urlArray = [NSMutableArray array];
    }
    return _urlArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _imageUrlIndex = 0;
    if (USE_IFLY) {
        if ([CommonCode readFromUserD:@"ifly_read_rate"] == nil) {
            [CommonCode writeToUserD:@(75) andKey:@"ifly_read_rate"];
        }
        
        if ([CommonCode readFromUserD:@"ifly_read_voicer"] == nil) {
            [CommonCode writeToUserD:@"xiaoyan" andKey:@"ifly_read_voicer"];
        }
        //倍数数据
        self.speedArray = [NSMutableArray arrayWithArray:@[@"35",@"60",@"75",@"85",@"100"]];
    }else{
        if ([CommonCode readFromUserD:@"read_rate"] == nil) {
            [CommonCode writeToUserD:@(0.625) andKey:@"read_rate"];
        }
        //倍数数据
        self.speedArray = [NSMutableArray arrayWithArray:@[@"0.25",@"0.5",@"0.625",@"0.75",@"1.0"]];
    }
    
    [self setNavBar];
    
    _webView = [[WKWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _webView.backgroundColor = [UIColor whiteColor];
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    _webView.scrollView.delegate = self;
    _webView.frame = CGRectMake(0, CGRectGetMaxY(topView.frame), SCREEN_WIDTH, SCREEN_HEIGHT - CGRectGetMaxY(topView.frame));
    _webView.scrollView.bounces = NO;
    _webView.contentScaleFactor = 0;
    [self.view addSubview:_webView];
    
//    UIButton *changeReadVoice = [[UIButton alloc] init];
//    changeReadVoice.backgroundColor = [UIColor whiteColor];
//    changeReadVoice.layer.cornerRadius = 15;
//    [changeReadVoice setImage:[UIImage imageNamed:@"changeVoice"] forState:UIControlStateNormal];
//    changeReadVoice.frame = CGRectMake(SCREEN_WIDTH - 40, SCREEN_HEIGHT - 80.0 / 667 * IPHONE_H - 40, 30, 30);
//    [changeReadVoice addTarget:self action:@selector(changeVoice)];
//    [self.view insertSubview:changeReadVoice aboveSubview:_webView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *strurl = self.urlString;
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:strurl]]];
    });
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [_webView addGestureRecognizer:rightSwipe];
    
    //设置朗读控制器view
    [self setPlayContorlView];
    [self readPlayerControlSet];
    
    
    if (USE_IFLY) {
        _ifly_reader = [IflyVoiceReader iflyVoiceReaderManager];
        DefineWeakSelf
        _ifly_reader.readFinish = ^{
            [weakSelf bofangRightAction:weakSelf.bofangRightBtn];
        };
        _ifly_reader.readState = ^(IflyVoiceReaderState state) {
            switch (state) {
                case IflyVoiceReaderStateIsRead:
                    weakSelf.bofangCenterBtn.selected = YES;
                    break;
                case IflyVoiceReaderStatePause:
                    weakSelf.bofangCenterBtn.selected = NO;
                    break;
                case IflyVoiceReaderStateStop:
                    weakSelf.bofangCenterBtn.selected = NO;
                    break;
                default:
                    weakSelf.bofangCenterBtn.selected = NO;
                    break;
            }
        };
    }else{
        _reader = [VoiceReader voiceReaderManager];
        DefineWeakSelf
        _reader.readFinish = ^{
            [weakSelf bofangRightAction:weakSelf.bofangRightBtn];
        };
        _reader.readState = ^(VoiceReaderState state) {
            switch (state) {
                case VoiceReaderStateIsRead:
                    weakSelf.bofangCenterBtn.selected = YES;
                    break;
                case VoiceReaderStatePause:
                    weakSelf.bofangCenterBtn.selected = NO;
                    break;
                case VoiceReaderStateStop:
                    weakSelf.bofangCenterBtn.selected = NO;
                    break;
                default:
                    weakSelf.bofangCenterBtn.selected = NO;
                    break;
            }
        };
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
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(10, 25, 35, 35);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 10)];
    [leftBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    leftBtn.accessibilityLabel = @"返回";
    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:leftBtn];
    
    _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBtn.frame = CGRectMake(SCREEN_WIDTH - 55, 25, 35, 35);
    [_rightBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 0)];
    [_rightBtn setImage:[UIImage imageNamed:@"title_ic_share"] forState:UIControlStateNormal];
    _rightBtn.accessibilityLabel = @"分享";
    [_rightBtn addTarget:self action:@selector(shareNewsBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:_rightBtn];
    
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
        leftBtn.frame = CGRectMake(10, 25 + 24, 35, 35);
        _rightBtn.frame = CGRectMake(SCREEN_WIDTH - 55, 25 + 24, 35, 35);
        topLab.frame = CGRectMake(50, 30 + 24, IPHONE_W - 100, 30);
        seperatorLine.frame = CGRectMake(0, 63.5 + 24, SCREEN_WIDTH, 0.5);
    }else{
        topView.frame = CGRectMake(0, 0, IPHONE_W, 64);
        leftBtn.frame = CGRectMake(10, 25, 35, 35);
        _rightBtn.frame = CGRectMake(SCREEN_WIDTH - 55, 25, 35, 35);
        topLab.frame = CGRectMake(50, 30, IPHONE_W - 100, 30);
        seperatorLine.frame = CGRectMake(0, 63.5, SCREEN_WIDTH, 0.5);
    }
}
- (void)setPlayContorlView{
    //底部view主容器控件
    dibuView = [[UIView alloc]initWithFrame:CGRectMake(0, IPHONE_H - 80.0 / 667 * IPHONE_H, IPHONE_W, 80.0 / 667 * IPHONE_H)];
    dibuView.y = IS_IPHONEX?IPHONE_H - 80.0 / 667 * IPHONE_H:IPHONE_H - 70.0 / 667 * IPHONE_H;
    dibuView.height = IS_IPHONEX?80.0 / 667 * IPHONE_H:70.0 / 667 * IPHONE_H;
    dibuView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:dibuView];
    
    UIView *devider = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
    devider.backgroundColor = [UIColor lightGrayColor];
    [dibuView addSubview:devider];
    
    //底部收藏按钮
    bofangRateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //    bofangfenxiangBtn.backgroundColor = [UIColor redColor];
    bofangRateBtn.frame = CGRectMake(IPHONE_W - 55.0 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H,IS_IPHONEX?35.0: 35.0 / 667 * IPHONE_H,IS_IPHONEX?35.0: 35.0 / 667 * IPHONE_H);
    [bofangRateBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [bofangRateBtn setImage:[UIImage imageNamed:@"change_voice3"] forState:UIControlStateNormal];
    [bofangRateBtn setImage:[UIImage imageNamed:@"change_voice3"] forState:UIControlStateSelected];
    [bofangRateBtn setTag:99];
    bofangRateBtn.accessibilityLabel = @"倍速";
    [bofangRateBtn addTarget:self action:@selector(playSettingChange) forControlEvents:UIControlEventTouchUpInside];
    bofangRateBtn.contentMode = UIViewContentModeScaleToFill;
    [dibuView addSubview:bofangRateBtn];
    
    //底部定时按钮
    UIButton *bofangdingshiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bofangdingshiBtn.frame = CGRectMake(20.0 / 375 * IPHONE_W, bofangRateBtn.y, IS_IPHONEX?32.0: 32.0 / 667 * IPHONE_H,IS_IPHONEX?32.0: 32.0 / 667 * IPHONE_H);
    [bofangdingshiBtn setImage:[UIImage imageNamed:@"home_news_ic_time-1"] forState:UIControlStateNormal];
    [bofangdingshiBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    bofangdingshiBtn.accessibilityLabel = @"定时";
    [bofangdingshiBtn addTarget:self action:@selector(bofangdingshiBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    bofangdingshiBtn.contentMode = UIViewContentModeScaleToFill;
    [dibuView addSubview:bofangdingshiBtn];
}
- (void)readPlayerControlSet
{
    //底部播放左按钮
    bofangLeftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bofangLeftBtn.frame = CGRectMake(104.5 / 375 * IPHONE_W, 20.0 / 667 * IPHONE_H, 32.0 / 667 * IPHONE_H, 32.0 / 667 * IPHONE_H);
    [bofangLeftBtn setImage:[UIImage imageNamed:@"home_news_ic_before"] forState:UIControlStateNormal];
    [bofangLeftBtn setImage:[UIImage imageNamed:@"home_news_ic_before"] forState:UIControlStateDisabled];
    bofangLeftBtn.accessibilityLabel = @"上一条新闻";
    [bofangLeftBtn addTarget:self action:@selector(bofangLeftAction:) forControlEvents:UIControlEventTouchUpInside];
    bofangLeftBtn.contentMode = UIViewContentModeScaleToFill;
    [dibuView addSubview:bofangLeftBtn];
    
    //底部播放右按钮
    _bofangRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _bofangRightBtn.frame = CGRectMake(IPHONE_W - 104.5 / 375 * SCREEN_WIDTH -  bofangLeftBtn.frame.size.width, bofangLeftBtn.frame.origin.y, bofangLeftBtn.frame.size.width,bofangLeftBtn.frame.size.height);
    [_bofangRightBtn setImage:[UIImage imageNamed:@"home_news_ic_next"] forState:UIControlStateNormal];
    [_bofangRightBtn setImage:[UIImage imageNamed:@"home_news_ic_next"] forState:UIControlStateDisabled];
    _bofangRightBtn.accessibilityLabel = @"下一则新闻";
    [_bofangRightBtn addTarget:self action:@selector(bofangRightAction:) forControlEvents:UIControlEventTouchUpInside];
    _bofangRightBtn.contentMode = UIViewContentModeScaleToFill;
    [dibuView addSubview:_bofangRightBtn];
    
    //底部播放暂停按钮
    _bofangCenterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _bofangCenterBtn.frame = CGRectMake((IPHONE_W  - bofangLeftBtn.frame.size.width)/ 2, bofangLeftBtn.frame.origin.y, bofangLeftBtn.frame.size.width ,bofangLeftBtn.frame.size.height);
    [_bofangCenterBtn setImage:[UIImage imageNamed:@"home_news_ic_play"] forState:UIControlStateNormal];
    [_bofangCenterBtn setImage:[UIImage imageNamed:@"home_news_ic_pause"] forState:UIControlStateSelected];
    _bofangCenterBtn.accessibilityLabel = @"播放";
    [_bofangCenterBtn addTarget:self action:@selector(playPauseClicked:) forControlEvents:UIControlEventTouchUpInside];
    _bofangCenterBtn.contentMode = UIViewContentModeScaleToFill;
    _bofangCenterBtn.selected = YES;
    [dibuView addSubview:_bofangCenterBtn];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [CommonCode writeToUserD:@(YES) andKey:@"openWebVC"];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    //获取所有的html
    NSString *getAllPTag =
    @"function getAllPTag(){\
    var p =  document.getElementsByTagName('p');\
    for(var i=0; i<p.length; i++){\
    p[i].style.display = 'block';\
    }\
    var div =  document.getElementsByTagName('div');\
    for(var i=0; i<div.length; i++){\
    div[i].style.display = 'block';\
    }\
    };";
    NSString *allText = @"document.documentElement.innerText";
    NSString *title = @"document.title";
    DefineWeakSelf
    [webView evaluateJavaScript:getAllPTag completionHandler:nil];
    [webView evaluateJavaScript:@"getAllPTag()" completionHandler:nil];
    [webView evaluateJavaScript:allText completionHandler:^(id _Nullable text, NSError * _Nullable error) {
        weakSelf.content = text;
        if (USE_IFLY) {
            if (weakSelf.isFromTouTiao) {//去除今日头条打开部分重复内容
                [weakSelf.ifly_reader starReaderWithReaderString:[[text stringByReplacingOccurrencesOfString:@"\n打开\n" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""]];
            }else{
                NSString *trimmedString = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                [weakSelf.ifly_reader starReaderWithReaderString:[trimmedString stringByReplacingOccurrencesOfString:@" " withString:@""]];
            }
            weakSelf.ifly_reader.readString = text;
        }else{
            if (weakSelf.isFromTouTiao) {//去除今日头条打开部分重复内容
                [weakSelf.reader starReaderWithReaderString:[text stringByReplacingOccurrencesOfString:@"\n打开\n" withString:@""]];
            }else{
                [weakSelf.reader starReaderWithReaderString:text];
            }
            weakSelf.reader.readString = text;
        }
        //        RTLog(@"%@",text);
    }];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *timeOut =
        @"setTimeout(function(){\
        scrollTo(0,0);\
        },300);";
        [_webView evaluateJavaScript:timeOut completionHandler:nil];
//    });
    
    //这里是js，主要目的实现对url的获取
    NSURL *webUrl = [NSURL URLWithString:self.urlString];
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
    if ([webUrl.host isEqualToString:@"mp.weixin.qq.com"]) {
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
    [NetWorkTool getUrlTitleWithURL:_urlString sccess:^(NSDictionary *responseObject) {
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
    bofangLeftBtn.enabled = YES;
    _bofangRightBtn.enabled = YES;
}

/**
 获取网页图片方法
 */
- (void)getUrlImageWithTitle:(NSString *)text
{
    DefineWeakSelf
    [_webView evaluateJavaScript:@"getImages()" completionHandler:^(id _Nullable urlResurlt, NSError * _Nullable error) {
        //urlResurlt 就是获取到得所有图片的url的拼接；urlArray就是所有Url的数组
        weakSelf.urlArray = [NSMutableArray arrayWithArray:[urlResurlt componentsSeparatedByString:@"+"]];
        if (weakSelf.urlArray.count >= 2) {//去除空字符串
            NSMutableArray *tempArray = [NSMutableArray array];
            for (int i = 0;i<weakSelf.urlArray.count;i++) {
                NSString *string = weakSelf.urlArray[i];
                if (![string isEqualToString:@""]) {
                    [tempArray addObject:string];
                }
            }
            weakSelf.urlArray = tempArray;
        }
        if (!weakSelf.isDownCoverImage) {
            if (weakSelf.getUrlData) {
                weakSelf.getUrlData([[[text stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""], weakSelf.urlArray.firstObject,weakSelf.urlString);
            }
            [weakSelf getTheCoverImageWithUrlArray:weakSelf.urlArray];
        }
        weakSelf.Title = text;
        weakSelf.imageUrl = weakSelf.urlArray.firstObject;
    }];
}
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    bofangLeftBtn.enabled = YES;
    _bofangRightBtn.enabled = YES;
}
- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
    if (USE_IFLY) {
        [[IflyVoiceReader iflyVoiceReaderManager] stopReader];
    }else{
        [[VoiceReader voiceReaderManager] stopReader];
    }
}
/**
 点击定时跳转定时设置控制器
 */
- (void)bofangdingshiBtnAction:(UIButton *)sender
{
    [self.navigationController.navigationBar setHidden:YES];
    [self.navigationController pushViewController:[TimerViewController defaultTimerViewController] animated:YES];
}
/**
 上一条
 */
- (void)bofangLeftAction:(UIButton *)button
{
    _index = _index - 1;
    if (_index<0) {
        _index = 0;
        [[XWAlerLoginView alertWithTitle:@"已经是第一条了"] show];
    }else{
        if (USE_IFLY) {
            //倍数数据
            self.speedArray = [NSMutableArray arrayWithArray:@[@"35",@"60",@"75",@"85",@"100"]];
        }else{
            //倍数数据
            self.speedArray = [NSMutableArray arrayWithArray:@[@"0.25",@"0.5",@"0.625",@"0.75",@"1.0"]];
        }
        button.enabled = NO;
        URLDataModel *model = self.listArray[_index];
        self.urlString = model.article_url;
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:model.article_url]]];
        
        if (self.setReadUrlState) {
            self.setReadUrlState(self.urlString);
        }
    }
}
/**
 下一条
 */
- (void)bofangRightAction:(UIButton *)button
{
    _index = _index + 1;
    if (_index>=self.listArray.count) {
        _index = self.listArray.count - 1;
        [[XWAlerLoginView alertWithTitle:@"已经是最后一条了"] show];
    }else{
        if (USE_IFLY) {
            //倍数数据
            self.speedArray = [NSMutableArray arrayWithArray:@[@"35",@"60",@"75",@"85",@"100"]];
        }else{
            //倍数数据
            self.speedArray = [NSMutableArray arrayWithArray:@[@"0.25",@"0.5",@"0.625",@"0.75",@"1.0"]];
        }
        button.enabled = NO;
        URLDataModel *model = self.listArray[_index];
        self.urlString = model.article_url;
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:model.article_url]]];
        
        if (self.setReadUrlState) {
            self.setReadUrlState(self.urlString);
        }
    }
}
- (void)playPauseClicked:(UIButton *)button
{
    if (USE_IFLY) {
        if ([IflyVoiceReader iflyVoiceReaderManager].isReading) {
            [[IflyVoiceReader iflyVoiceReaderManager] pauseReader];
            button.selected = NO;
        }else{
            [[IflyVoiceReader iflyVoiceReaderManager] continueReader];
            button.selected = YES;
        }
    }else{
        if ([VoiceReader voiceReaderManager].isReading) {
            
            if ([VoiceReader voiceReaderManager].isPause) {
                [[VoiceReader voiceReaderManager] continueReader];
                button.selected = YES;
            }else{
                [[VoiceReader voiceReaderManager] pauseReader];
                button.selected = NO;
            }
        }else{
            
            [[VoiceReader voiceReaderManager] starReaderWithReaderString:self.content];
            button.selected = NO;
        }
    }
}
//讯飞切换发音人和语速的选项列表
- (void)playSettingChange
{
    if (USE_IFLY) {
        self.speedArray = [NSMutableArray arrayWithArray:@[@"0",@"10000"]];
        
        [self.changeTableView reloadData];
        _alertView = [[CustomAlertView alloc] initWithCustomView:[self setupChangeWithCount:2]];
        _alertView.alertHeight = 49 * (2 + 1);
        _alertView.alertDuration = 0.25;
        _alertView.coverAlpha = 0.6;
        [_alertView show];
    }else{
        [self changeRate];
    }
    
}
//改变朗读声音
- (void)changeVoice
{
    /*
     *  |  小琪     |   vixq           | 普通话
     *  |  小宇     |   xiaoyu         | 普通话
     *  |  小研     |   vixy           | 普通话
     *  |  小燕     |   xiaoyan        | 普通话
     *  |  小峰     |   vixf           | 普通话
     *  |  老孙     |   vils           | 普通话
     *  |  小梅     |   vixl           | 粤语
     *  |  小莉     |   vixq           | 台湾普通话
     *  |  小蓉     |   vixr           | 四川话
     *  |  小芸     |   vixyun         | 东北话
     *  |  小坤     |   vixk           | 河南话
     *  |  小强     |   vixqa          | 湖南话
     *  |  小莹     |   vixyin         | 陕西话
     */
    [CommonCode writeToUserD:@(YES) andKey:@"changeVoice"];
    self.speedArray = [NSMutableArray arrayWithArray:@[@"vixq",@"xiaoyu",@"vixy",@"xiaoyan",@"vixf",@"vils",@"vixm",@"vixl",@"vixr",@"vixyun",@"vixk",@"vixqa",@"vixyin"]];
    
    [self.voicerTableView reloadData];
    _alertView = [[CustomAlertView alloc] initWithCustomView:[self setupVoicerAlertView]];
    _alertView.alertHeight = 49 * (6 + 1);
    _alertView.alertDuration = 0.25;
    _alertView.coverAlpha = 0.6;
    [_alertView show];
}
- (void)changeRate
{
    if (USE_IFLY) {
        //倍数数据
        self.speedArray = [NSMutableArray arrayWithArray:@[@"35",@"60",@"75",@"85",@"100"]];
    }else{
        //倍数数据
        self.speedArray = [NSMutableArray arrayWithArray:@[@"0.25",@"0.5",@"0.625",@"0.75",@"1.0"]];
    }
    [self.playSpeedTableView reloadData];
    _alertView = [[CustomAlertView alloc] initWithCustomView:[self setupPlaySpeedAlertViewWithCount:self.speedArray.count]];
    _alertView.alertHeight = 49 * (self.speedArray.count + 1);
    _alertView.alertDuration = 0.25;
    _alertView.coverAlpha = 0.6;
    [_alertView show];
}
/**
 倍数和发音人设置选项弹窗
 */
- (UIView *)setupChangeWithCount:(NSInteger)count
{
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = HEXCOLOR(0xe3e3e3);
    bgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 49 * (count + 1));
    
    [bgView addSubview:self.changeTableView];
    
    return bgView;
}
/**
 倍数设置弹窗
 */
- (UIView *)setupPlaySpeedAlertViewWithCount:(NSInteger)count
{
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = HEXCOLOR(0xe3e3e3);
    bgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 49 * (count + 1));
    
    [bgView addSubview:self.playSpeedTableView];
    
    return bgView;
}
/**
 发音人设置弹窗
 */
- (UIView *)setupVoicerAlertView
{
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = HEXCOLOR(0xe3e3e3);
    bgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 49 * (6 + 1));
    
    [bgView addSubview:self.voicerTableView];
    
    return bgView;
}
- (UITableView *)playSpeedTableView
{
    if (!_playSpeedTableView)
    {
        _playSpeedTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, IPHONE_W, 49 * (self.speedArray.count>6?7:self.speedArray.count + 1)) style:UITableViewStylePlain];
        _playSpeedTableView.delegate = self;
        _playSpeedTableView.dataSource = self;
        _playSpeedTableView.backgroundColor = [UIColor whiteColor];
        
        UIButton *cancelBtn = [[UIButton alloc] init];
        cancelBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, 49);
        cancelBtn.backgroundColor = [UIColor whiteColor];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [cancelBtn addTarget:self action:@selector(cancel_playSpeed_view)];
        _playSpeedTableView.tableFooterView = cancelBtn;
    }
    return _playSpeedTableView;
}
- (UITableView *)changeTableView
{
    if (!_changeTableView)
    {
        _changeTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, IPHONE_W, 49 * (3)) style:UITableViewStylePlain];
        _changeTableView.delegate = self;
        _changeTableView.dataSource = self;
        _changeTableView.backgroundColor = [UIColor whiteColor];
        
        UIButton *cancelBtn = [[UIButton alloc] init];
        cancelBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, 49);
        cancelBtn.backgroundColor = [UIColor whiteColor];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [cancelBtn addTarget:self action:@selector(cancel_playSpeed_view)];
        _changeTableView.tableFooterView = cancelBtn;
    }
    return _changeTableView;
}
- (UITableView *)voicerTableView
{
    if (!_voicerTableView)
    {
        _voicerTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, IPHONE_W, 49 * (6 + 1)) style:UITableViewStylePlain];
        _voicerTableView.delegate = self;
        _voicerTableView.dataSource = self;
        _voicerTableView.backgroundColor = [UIColor whiteColor];
        
        UIButton *cancelBtn = [[UIButton alloc] init];
        cancelBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, 49);
        cancelBtn.backgroundColor = [UIColor whiteColor];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [cancelBtn addTarget:self action:@selector(cancel_playSpeed_view)];
        _voicerTableView.tableFooterView = cancelBtn;
    }
    return _voicerTableView;
}
- (void)cancel_playSpeed_view
{
    [_alertView coverClick];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //播放控制器显示隐藏
    if (scrollView.contentOffset.y < 0) {
        [self showPlayControl];
    }else{
        if (_lastContenOffsetY < scrollView.contentOffset.y) {//上滑
            [self hidePlayControl];
        }else if (_lastContenOffsetY > scrollView.contentOffset.y){//下滑
            [self showPlayControl];
        }
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _lastContenOffsetY = scrollView.contentOffset.y;
}
#pragma mark - 播放器动画--定时器
- (void)showPlayControl
{
    CGFloat viewY = IS_IPHONEX?IPHONE_H - 80.0 / 667 * IPHONE_H:IPHONE_H - 70.0 / 667 * IPHONE_H;
    if (viewY != dibuView.y) {
        [UIView animateWithDuration:0.5 animations:^{
            dibuView.y = viewY;
        }];
    }
}
- (void)hidePlayControl
{
    CGFloat viewY = IPHONE_H;
    if (viewY != dibuView.y) {
        [UIView animateWithDuration:0.5 animations:^{
            dibuView.y = viewY;
        }];
    }
}
#pragma mark - table datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.speedArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"read_speed_cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"read_speed_cell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = CUSTOM_FONT_TYPE(15.0);
    cell.accessoryType = UITableViewCellAccessoryNone;
    if ([tableView isEqual:self.changeTableView]) {
        if ([self.speedArray[indexPath.row] isEqualToString:@"0"]) {
            cell.textLabel.text = @"朗读声音";
        }else if ([self.speedArray[indexPath.row] isEqualToString:@"10000"]) {
            cell.textLabel.text = @"播放速率";
        }
    }else{
        if ([[CommonCode readFromUserD:@"changeVoice"] boolValue] == YES) {
            /*
             *  |  小琪     |   vixq           | 普通话
             *  |  小宇     |   xiaoyu         | 普通话
             *  |  小研     |   vixy           | 普通话
             *  |  小燕     |   xiaoyan        | 普通话
             *  |  小峰     |   vixf           | 普通话
             *  |  老孙     |   vils           | 普通话
             *  |  小梅     |   vixm           | 粤语
             *  |  小莉     |   vixl           | 台湾普通话
             *  |  小蓉     |   vixr           | 四川话
             *  |  小芸     |   vixyun         | 东北话
             *  |  小坤     |   vixk           | 河南话
             *  |  小强     |   vixqa          | 湖南话
             *  |  小莹     |   vixyin         | 陕西话
             */
            if ([self.speedArray[indexPath.row] isEqualToString:@"vixq"]) {
                cell.textLabel.text = @"小琪-女青,普通话";
            }else if ([self.speedArray[indexPath.row] isEqualToString:@"xiaoyu"]) {
                cell.textLabel.text = @"小宇-男青,普通话";
            }else if ([self.speedArray[indexPath.row] isEqualToString:@"vixy"]) {
                cell.textLabel.text = @"小研-女青,普通话";
            }else if ([self.speedArray[indexPath.row] isEqualToString:@"xiaoyan"]) {
                cell.textLabel.text = @"小燕-女青,普通话";
            }else if ([self.speedArray[indexPath.row] isEqualToString:@"vixf"]) {
                cell.textLabel.text = @"小峰-男青,普通话";
            }else if ([self.speedArray[indexPath.row] isEqualToString:@"vils"]) {
                cell.textLabel.text = @"老孙-男老,普通话";
            }else if ([self.speedArray[indexPath.row] isEqualToString:@"vixm"]) {
                cell.textLabel.text = @"小梅-女青,粤语";
            }else if ([self.speedArray[indexPath.row] isEqualToString:@"vixl"]) {
                cell.textLabel.text = @"小莉-女青,台湾普通话";
            }else if ([self.speedArray[indexPath.row] isEqualToString:@"vixr"]) {
                cell.textLabel.text = @"小蓉-女青,四川话";
            }else if ([self.speedArray[indexPath.row] isEqualToString:@"vixyun"]) {
                cell.textLabel.text = @"小芸-女青,东北话";
            }else if ([self.speedArray[indexPath.row] isEqualToString:@"vixk"]) {
                cell.textLabel.text = @"小坤-男青,河南话";
            }else if ([self.speedArray[indexPath.row] isEqualToString:@"vixqa"]) {
                cell.textLabel.text = @"小强-男青,湖南话";
            }else if ([self.speedArray[indexPath.row] isEqualToString:@"vixyin"]) {
                cell.textLabel.text = @"小莹-女青,陕西话";
            }
            RTLog(@"%ld",indexPath.row);
            if ([[CommonCode readFromUserD:@"ifly_read_voicer"] isEqualToString:self.speedArray[indexPath.row]]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }else{
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }else{
            RTLog(@"%f",[self.speedArray[indexPath.row] floatValue]);
            if (USE_IFLY) {
                if ([self.speedArray[indexPath.row] floatValue] == 35) {
                    cell.textLabel.text = @"0.5倍速";
                }else if ([self.speedArray[indexPath.row] floatValue] == 60) {
                    cell.textLabel.text = @"正常倍速";
                }else if ([self.speedArray[indexPath.row] floatValue] == 75) {
                    cell.textLabel.text = @"1.25倍速";
                }else if ([self.speedArray[indexPath.row] floatValue] == 85) {
                    cell.textLabel.text = @"1.5倍速";
                }else if ([self.speedArray[indexPath.row] floatValue] == 100) {
                    cell.textLabel.text = @"2倍速";
                }
                if ([[CommonCode readFromUserD:@"ifly_read_rate"] floatValue] == [self.speedArray[indexPath.row] floatValue]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }else{
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }else{
                if ([self.speedArray[indexPath.row] floatValue] == 0.25) {
                    cell.textLabel.text = @"0.5倍速";
                }else if ([self.speedArray[indexPath.row] floatValue] == 0.5) {
                    cell.textLabel.text = @"正常倍速";
                }else if ([self.speedArray[indexPath.row] floatValue] == 0.625) {
                    cell.textLabel.text = @"1.25倍速";
                }else if ([self.speedArray[indexPath.row] floatValue] == 0.75) {
                    cell.textLabel.text = @"1.5倍速";
                }else if ([self.speedArray[indexPath.row] floatValue] == 1.0) {
                    cell.textLabel.text = @"2倍速";
                }
                if ([[CommonCode readFromUserD:@"read_rate"] floatValue] == [self.speedArray[indexPath.row] floatValue]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }else{
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
        }
    }
    return cell;
}
#pragma mark - table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.changeTableView]) {
        //弹窗退出
        [_alertView coverClick];
        if ([self.speedArray[indexPath.row] isEqualToString:@"0"]) {
            [self changeVoice];
        }else if ([self.speedArray[indexPath.row] isEqualToString:@"10000"]) {
            [self changeRate];
        }
    }else{
        if ([[CommonCode readFromUserD:@"changeVoice"] boolValue] == YES) {
            if ([[CommonCode readFromUserD:@"tip_read_change_voice_reload"] boolValue]) {
                //倍数弹窗退出
                [_alertView coverClick];
                //把倍数写入播放器和本地
                [IflyVoiceReader iflyVoiceReaderManager].voicer = self.speedArray[indexPath.row];
                [self.ifly_reader starReaderWithReaderString:self.content];
                [CommonCode writeToUserD:@(NO) andKey:@"changeVoice"];
                [tableView reloadData];
            }else{
                [_alertView coverClick];
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"切换播放速率，会使当前播放内容从头播放，请问是否切换？" preferredStyle:UIAlertControllerStyleAlert];
                [alertC addAction:[UIAlertAction actionWithTitle:@"确认切换" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
                    //倍数弹窗退出
                    [_alertView coverClick];
                    //把倍数写入播放器和本地
                    [IflyVoiceReader iflyVoiceReaderManager].voicer = self.speedArray[indexPath.row];
                    [self.ifly_reader starReaderWithReaderString:self.content];
                    [tableView reloadData];
                    [CommonCode writeToUserD:@(YES) andKey:@"tip_read_change_voice_reload"];
                    [CommonCode writeToUserD:@(NO) andKey:@"changeVoice"];
                }]];
                [alertC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [CommonCode writeToUserD:@(NO) andKey:@"changeVoice"];
                }]];
                [self presentViewController:alertC animated:YES completion:nil];
            }
        }else{
            if ([[CommonCode readFromUserD:@"tip_read_reload"] boolValue]) {
                //倍数弹窗退出
                [_alertView coverClick];
                //把倍数写入播放器和本地
                if (USE_IFLY) {
                    [IflyVoiceReader iflyVoiceReaderManager].readRate = [self.speedArray[indexPath.row] floatValue];
                    [self.ifly_reader starReaderWithReaderString:self.content];
                }else{
                    [VoiceReader voiceReaderManager].readRate = [self.speedArray[indexPath.row] floatValue];
                    [self.reader starReaderWithReaderString:self.content];
                }
                [tableView reloadData];
            }else{
                [_alertView coverClick];
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"切换播放速率，会使当前播放内容从头播放，请问是否切换？" preferredStyle:UIAlertControllerStyleAlert];
                [alertC addAction:[UIAlertAction actionWithTitle:@"确认切换" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
                    //倍数弹窗退出
                    [_alertView coverClick];
                    //把倍数写入播放器和本地
                    if (USE_IFLY) {
                        [IflyVoiceReader iflyVoiceReaderManager].readRate = [self.speedArray[indexPath.row] floatValue];
                        [self.ifly_reader starReaderWithReaderString:self.content];
                    }else{
                        [VoiceReader voiceReaderManager].readRate = [self.speedArray[indexPath.row] floatValue];
                        [self.reader starReaderWithReaderString:self.content];
                    }
                    [tableView reloadData];
                    [CommonCode writeToUserD:@(YES) andKey:@"tip_read_reload"];
                }]];
                [alertC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alertC animated:YES completion:nil];
            }
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 49;
}
#pragma mark - 分享
//TODO:分享内容设置
- (void)shareNewsBtnAction
{
    DefineWeakSelf
    ShareAlertView *shareView = [[ShareAlertView alloc]init];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.window addSubview:shareView];
    NSMutableArray *itemArr = [NSMutableArray array];
    NSDictionary *dic0 = @{@"image":@"sinaShareBtn",@"title":@"微博"};
    [itemArr addObject:dic0];
    NSDictionary *dic1 = @{@"image":@"wechat_session",@"title":@"微信好友"};
    [itemArr addObject:dic1];
    NSDictionary *dic2 = @{@"image":@"wechat_timeline",@"title":@"朋友圈"};
    [itemArr addObject:dic2];
    NSDictionary *dic3 = @{@"image":@"iconfont_copy_url",@"title":@"复制链接"};
    [itemArr addObject:dic3];
    [shareView setShareTitle:@"主播分享:"];
    [shareView setSelectItemWithTitleArr:itemArr];
    
    
    shareView.selectedTypeBlock = ^ (NSInteger selectedindex) {
        switch (selectedindex) {
            case 0:
            {
                WBMessageObject *message = [WBMessageObject message];
                //消息的文本内容
                message.text = [NSString stringWithFormat:@"【%@】\n我在“听闻帮你读”分享了这篇文章~\n查看：%@下载：http://tingwen.me\n(^_^)一款可以帮你读文章的APP(^_^)",[self.Title stringByReplacingOccurrencesOfString:@" " withString:@""],self.urlString];
                //设置消息的图片内容
                
                WBSendMessageToWeiboRequest *send = [WBSendMessageToWeiboRequest requestWithMessage:message];
                [WeiboSDK sendRequest:send];
            }
                break;
            case 1:{
                [weakSelf shareToWechatWithscene:WXSceneSession];
            }
                break;
            case 2:{
                [weakSelf shareToWechatWithscene:WXSceneTimeline];
            }
                break;
            default:
            {
                UIPasteboard *gr                             = [UIPasteboard generalPasteboard];
                gr.string = self.urlString;
                XWAlerLoginView *xw = [[XWAlerLoginView alloc]initWithTitle:@"分享链接已复制到您的剪切板~~"];
                [xw show];
            }
                break;
        }
    };
}

/**
 分享到微信
 */
- (void)shareToWechatWithscene:(int)scene{
    //注册微信
    [WXApi registerApp:KweChatappID];
    
    if (![WXApi isWXAppInstalled]){
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请先安装微信" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        [al show];
        return;
    }
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = YES;
    req.text = [NSString stringWithFormat:@"【%@】\n我在“听闻帮你读”分享了这篇文章~\n查看：%@下载：http://tingwen.me\n(^_^)一款可以帮你读文章的APP(^_^)",[self.Title stringByReplacingOccurrencesOfString:@" " withString:@""],self.urlString];
    req.scene = scene;
    if ([WXApi sendReq:req]) {
        RTLog(@"微信发送请求成功");
    }
    else{
        RTLog(@"微信发送请求失败");
    }
}
/**
 获取分享图片
 */
- (void)getImageWithURLStr:(NSString *)urlstring OnSucceed:(void(^)(UIImage *image))succeed {
    //获取图片管理
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    //图片URL
    NSURL *url = [NSURL URLWithString:urlstring];
    //获取缓存key
    NSString *cacheKey = [manager cacheKeyForURL:url];
    //判断图片是否缓存
    if ([manager cachedImageExistsForURL:url]) {
        //先从内存中获取图片
        UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:cacheKey];
        //如果图片为空，则从本地获取图片
        if (!image) {
            image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:cacheKey];
        }
        //如果还是不存在图片， 则取图标
        if (!image) {
            image = [UIImage imageNamed:@"Icon-60"];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            succeed(image);
        });
        
    }else{
        [manager downloadImageWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            //下载图片完成后， 存在图片
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    succeed(image);
                });
                
            }else if (error){
                //如果发生错误，则取图标
                UIImage *palaceImage = [UIImage imageNamed:@"Icon-60"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    succeed(palaceImage);
                });
            }
        }];
    }
}

/**
 获取链接的合适封面图片，过滤掉不合适的图片

 @param array 链接数组
 */
- (void)getTheCoverImageWithUrlArray:(NSArray *)array
{
    //判断防止数组越界
    if (_imageUrlIndex >= array.count) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GetTheCoverImageNotification object:nil userInfo:@{@"imageUrl":@"",@"url":self.urlString}];
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
                self.imageUrl = imageURL.description;
                [[NSNotificationCenter defaultCenter] postNotificationName:GetTheCoverImageNotification object:nil userInfo:@{@"imageUrl":imageURL.description,@"url":self.urlString}];
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
@end
