//
//  URLWebViewController.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2018/4/12.
//  Copyright © 2018年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface URLWebViewController : UIViewController
@property (copy, nonatomic) NSString *urlString;
@property (strong, nonatomic) NSString *imageUrl;
@property (strong, nonatomic) NSMutableArray *listArray;
@property (assign, nonatomic) NSInteger index;
@property (assign, nonatomic) BOOL isDownCoverImage;
@property (assign, nonatomic) BOOL isFromTouTiao;

@property (copy, nonatomic) void (^getUrlData)(NSString *title,NSString *imageUrl ,NSString *url);
@property (copy, nonatomic) void (^setReadUrlState)(NSString *url);
@end
