//
//  guanggaoVC.m
//  reHeardTheNews
//
//  Created by Pop Web on 16/3/21.
//  Copyright © 2016年 paoguo. All rights reserved.
//

#import "guanggaoVC.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
@interface guanggaoVC ()
{
    UIImageView *imgV;
}
@end

@implementation guanggaoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    imgV = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:imgV];
    
    imgV.userInteractionEnabled = YES;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"跳过" forState:UIControlStateNormal];
    button.layer.cornerRadius = 20;
    button.clipsToBounds = YES;
    button.titleLabel.font = [UIFont systemFontOfSize:13];
    [button addTarget:self action:@selector(tiaoguo) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0,0, 40, 40);
    button.center = CGPointMake(IPHONE_W - 40, 54);
    [button setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.46]];
    [self.view addSubview:button];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [imgV addGestureRecognizer:tap];
    
    [NetWorkTool getIntoAppGuangGaoAccessToken:IS_LOGIN?AvatarAccessToken:nil sccess:^(NSDictionary *responseObject) {
        if (TARGETED_DEVICE_IS_IPHONE_480){
            [self setVCWithUrlStr:[NSString stringWithFormat:@"%@",responseObject[results][0][@"ad_content"]] tapUrlStr:responseObject[results][0][@"ad_name"]];
        }
        else if (TARGETED_DEVICE_IS_IPHONE_568){
            NSLog(@"IPHONE6");
            [self setVCWithUrlStr:[NSString stringWithFormat:@"%@",responseObject[results][1][@"ad_content"]] tapUrlStr:responseObject[results][1][@"ad_name"]];
        }
        else if (TARGETED_DEVICE_IS_IPHONE_667){
            NSLog(@"IPHONE6P");
            [self setVCWithUrlStr:[NSString stringWithFormat:@"%@",responseObject[results][2][@"ad_content"]] tapUrlStr:responseObject[results][2][@"ad_name"]];
        }
        else if (TARGETED_DEVICE_IS_IPHONE_736){
            [self setVCWithUrlStr:[NSString stringWithFormat:@"%@",responseObject[results][3][@"ad_content"]] tapUrlStr:responseObject[results][3][@"ad_name"]];
        }
        else if (IS_IPAD){
            [self setVCWithUrlStr:[NSString stringWithFormat:@"%@",responseObject[results][3][@"ad_content"]] tapUrlStr:responseObject[results][3][@"ad_name"]];
        }else if (TARGETED_DEVICE_IS_IPHONE_812 &&  [responseObject[results][10][@"status"] isEqualToString:@"1"]){
            [self setVCWithUrlStr:[NSString stringWithFormat:@"%@",responseObject[results][3][@"ad_content"]] tapUrlStr:responseObject[results][3][@"ad_name"]];
        }
        
    } failure:^(NSError *error)
     {
         NSLog(@"error = %@",error);
         [self performSelector:@selector(afterAction) withObject:nil];

     }];
}
- (void)setVCWithUrlStr:(NSString *)urlStr tapUrlStr:(NSString *)tapUrlStr
{
    self.urlStr = urlStr;
    self.tapUrlStr = tapUrlStr;
    [imgV sd_setImageWithURL:[NSURL URLWithString:self.urlStr]];
    [self performSelector:@selector(afterAction) withObject:nil afterDelay:3.0f];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    ExisFristOpenApp = YES;
}

- (void)tapAction {
    NSDictionary *adDataDict = [CommonCode readFromUserD:@"StartAD_Data"];
    RTLog(@"%@",adDataDict);
    if ([adDataDict[results] isKindOfClass:[NSArray class]] && adDataDict != nil) {
        //判断是否是课程
        if ([adDataDict[results][0][@"is_act"] isEqualToString:@"1"]) {
            NSDictionary *userInfoDict = [CommonCode readFromUserD:@"dangqianUserInfo"];
            //跳转已购买课堂界面，超级会员可直接跳转课堂已购买界面
            if ([adDataDict[results][0][@"is_free"] isEqualToString:@"1"]||[userInfoDict[results][member_type] intValue] == 2) {
                zhuboXiangQingVCNewController *faxianzhuboVC = [[zhuboXiangQingVCNewController alloc]init];
                faxianzhuboVC.jiemuDescription = adDataDict[results][0][@"description"];
                faxianzhuboVC.jiemuFan_num = adDataDict[results][0][@"fan_num"];
                faxianzhuboVC.jiemuID = adDataDict[results][0][@"id"];
                faxianzhuboVC.jiemuImages = adDataDict[results][0][@"images"];
                faxianzhuboVC.jiemuIs_fan = adDataDict[results][0][@"is_fan"];
                faxianzhuboVC.jiemuMessage_num = adDataDict[results][0][@"message_num"];
                faxianzhuboVC.jiemuName = adDataDict[results][0][@"name"];
                faxianzhuboVC.isfaxian = YES;
                faxianzhuboVC.isClass = YES;
                [self.navigationController pushViewController:faxianzhuboVC animated:YES];
            }
            //跳转未购买课堂界面
            else if ([adDataDict[results][0][@"is_free"] isEqualToString:@"0"]){
                ClassViewController *vc = [ClassViewController shareInstance];
                vc.jiemuDescription = adDataDict[results][0][@"description"];
                vc.jiemuFan_num = adDataDict[results][0][@"fan_num"];
                vc.jiemuID = adDataDict[results][0][@"id"];
                vc.jiemuImages = adDataDict[results][0][@"images"];
                vc.jiemuIs_fan = adDataDict[results][0][@"is_fan"];
                vc.jiemuMessage_num = adDataDict[results][0][@"message_num"];
                vc.jiemuName = adDataDict[results][0][@"name"];
                vc.act_id = adDataDict[results][0][@"id"];
                vc.listVC = self;
                vc.hidePayBtn = NO;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }else{
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:self.tapUrlStr]];
        }
    }else{
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:self.tapUrlStr]];
    }
    //清空开屏广告本地数据
    [CommonCode writeToUserD:nil andKey:@"StartAD_Data"];
}

- (void)afterAction {
    if ([self.navigationController.topViewController isKindOfClass:[guanggaoVC class]]) {
        [self.navigationController popViewControllerAnimated:NO];
    }
    //清空开屏广告本地数据
    [CommonCode writeToUserD:nil andKey:@"StartAD_Data"];
}

- (void)tiaoguo {
    [self.navigationController popViewControllerAnimated:NO];
    NSLog(@"跳过");
    //清空开屏广告本地数据
    [CommonCode writeToUserD:nil andKey:@"StartAD_Data"];
}
@end
