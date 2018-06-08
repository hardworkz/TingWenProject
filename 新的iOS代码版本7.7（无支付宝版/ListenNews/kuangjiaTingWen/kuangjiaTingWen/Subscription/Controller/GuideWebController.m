//
//  GuideWebController.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2018/4/28.
//  Copyright © 2018年 zhimi. All rights reserved.
//

#import "GuideWebController.h"

@interface GuideWebController ()<WKNavigationDelegate,WKUIDelegate,UIScrollViewDelegate>
{
    UIView *topView;
}
@property (strong, nonatomic) WKWebView *webView;
@end

@implementation GuideWebController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(back)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [_webView addGestureRecognizer:rightSwipe];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://tingwen.me/index.php/help/help"]]];
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
    leftBtn.frame = CGRectMake(10, 30, 50, 40);
//    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 10)];
//    [leftBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    leftBtn.titleLabel.font = CUSTOM_FONT_TYPE(15.0);
    [leftBtn setTitle:@"返回" forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:leftBtn];
    
    UILabel *topLab = [[UILabel alloc]initWithFrame:CGRectMake(50, 30, IPHONE_W - 100, 30)];
    topLab.textColor = [UIColor blackColor];
    topLab.font = [UIFont boldSystemFontOfSize:17.0f];
    topLab.text = @"如何添加";
    topLab.backgroundColor = [UIColor clearColor];
    topLab.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:topLab];
    UIView *seperatorLine = [[UIView alloc]initWithFrame:CGRectMake(0, 63.5, SCREEN_WIDTH, 0.5)];
    [seperatorLine setBackgroundColor:[UIColor lightGrayColor]];
    [topView addSubview:seperatorLine];
    
    //适配iPhoneX导航栏
    if (IS_IPHONEX) {
        topView.frame = CGRectMake(0, 0, IPHONE_W, 88);
        leftBtn.frame = CGRectMake(10, 30 + 24, 35, 35);
        topLab.frame = CGRectMake(50, 30 + 24, IPHONE_W - 100, 30);
        seperatorLine.frame = CGRectMake(0, 63.5 + 24, SCREEN_WIDTH, 0.5);
    }else{
        topView.frame = CGRectMake(0, 0, IPHONE_W, 64);
        leftBtn.frame = CGRectMake(10, 30, 35, 35);
        topLab.frame = CGRectMake(50, 30, IPHONE_W - 100, 30);
        seperatorLine.frame = CGRectMake(0, 63.5, SCREEN_WIDTH, 0.5);
    }
}
- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
