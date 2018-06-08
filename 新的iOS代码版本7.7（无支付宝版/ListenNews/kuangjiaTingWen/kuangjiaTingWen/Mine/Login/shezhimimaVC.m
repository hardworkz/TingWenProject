//
//  shezhimimaVC.m
//  reHeardTheNews
//
//  Created by 贺楠 on 16/5/23.
//  Copyright © 2016年 paoguo. All rights reserved.
//

#import "shezhimimaVC.h"

@interface shezhimimaVC ()
{
    UITextField *shezhimimaF;
    UITextField *querenmimaF;
    UITextField *user_niceNameF;
}
@end

@implementation shezhimimaVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置密码";
    [self enableAutoBack];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                                    NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *NextStep = [UIButton buttonWithType:UIButtonTypeCustom];
    NextStep.frame = CGRectMake(50, 230.0 / 667 * IPHONE_H, IPHONE_W - 100, 44.0 / 667 * IPHONE_H);
    NextStep.layer.cornerRadius = (44.0 / 667 * IPHONE_H)* 0.5;
    NextStep.backgroundColor = gMainColor;
    [NextStep setTitle:@"注册" forState:UIControlStateNormal];
    [NextStep setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [NextStep addTarget:self action:@selector(NextStep:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:NextStep];
    
    UILabel *shezhimimaL = [[UILabel alloc] initWithFrame:CGRectMake(27.5 / 375 * IPHONE_W, 95.0 / 667 * IPHONE_H, 80, 30.0 / 667 * IPHONE_H)];
    shezhimimaL.text = @"密码:";
    [self.view addSubview:shezhimimaL];
    
    shezhimimaF = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(shezhimimaL.frame)+10, 95.0 / 667 * IPHONE_H, SCREEN_WIDTH - CGRectGetMaxX(shezhimimaL.frame)- 30, 30.0 / 667 * IPHONE_H)];
    shezhimimaF.placeholder = @"请输入密码";
    shezhimimaF.font = [UIFont systemFontOfSize:14.0f];
    shezhimimaF.keyboardType = UIKeyboardTypeNumberPad;
    shezhimimaF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:shezhimimaF];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(shezhimimaL.x, 124.0 / 667 * IPHONE_H, shezhimimaL.width + shezhimimaF.width + 10, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:line];

    UILabel *querenmimaL = [[UILabel alloc] initWithFrame:CGRectMake(27.5 / 375 * IPHONE_W, 140.0 / 667 * IPHONE_H, 80, 30.0 / 667 * IPHONE_H)];
    querenmimaL.text = @"确认密码:";
    [self.view addSubview:querenmimaL];
    
    querenmimaF = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(querenmimaL.frame) + 10, 140.0 / 667 * IPHONE_H, SCREEN_WIDTH - CGRectGetMaxX(shezhimimaL.frame)- 30, 30.0 / 667 * IPHONE_H)];
    querenmimaF.placeholder = @"请再次输入密码";
    querenmimaF.font = [UIFont systemFontOfSize:14.0f];
    querenmimaF.keyboardType = UIKeyboardTypeNumberPad;
    querenmimaF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:querenmimaF];
    
    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(querenmimaL.x, 174.0 / 667 * IPHONE_H, querenmimaL.width + querenmimaF.width + 10, 0.5)];
    line1.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:line1];
    
    UILabel *user_niceNameL = [[UILabel alloc] initWithFrame:CGRectMake(27.5 / 375 * IPHONE_W, 185.0 / 667 * IPHONE_H, 80, 30.0 / 667 * IPHONE_H)];
    user_niceNameL.text = @"昵称:";
    [self.view addSubview:user_niceNameL];
    
    user_niceNameF = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(user_niceNameL.frame) + 10, 185.0 / 667 * IPHONE_H, SCREEN_WIDTH - CGRectGetMaxX(shezhimimaL.frame)- 30, 30.0 / 667 * IPHONE_H)];
    user_niceNameF.placeholder = @"请设置昵称";
    user_niceNameF.font = [UIFont systemFontOfSize:14.0f];
    user_niceNameF.keyboardType = UIKeyboardTypeDefault;
    user_niceNameF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:user_niceNameF];
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(user_niceNameL.x, 214.0 / 667 * IPHONE_H, user_niceNameL.width + user_niceNameF.width + 10, 0.5)];
    line2.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:line2];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
}

- (void)NextStep:(UIButton *)sender{
    if ([shezhimimaF.text stringByReplacingOccurrencesOfString:@" " withString:@""].length >= 6){
        if ([shezhimimaF.text isEqualToString:querenmimaF.text]){
            [NetWorkTool postPaoGuoZhuCeWithZhuCeAccessToken:[DSE encryptUseDES:ExZhuCeAccessToken] andpassword:[DSE encryptUseDES:shezhimimaF.text]  anduser_nicename:user_niceNameF.text andvcode:ExyanzhengmaStr sccess:^(NSDictionary *responseObject) {
                if ([responseObject[@"status"] integerValue] == 1){
                    UIAlertController *qingdengru = [UIAlertController alertControllerWithTitle:@"注册成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
                    [qingdengru addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                    }]];
                    [self presentViewController:qingdengru animated:YES completion:^{
                    }];
                    //自动登录账号
                    [NetWorkTool getPaoGuoUserInfoWithUserName:[DSE encryptUseDES:ExZhuCeAccessToken] andPassWord:[DSE encryptUseDES:shezhimimaF.text] sccess:^(NSDictionary *responseObject) {
                        if ([responseObject[status] intValue] == 1) {
                            ExdangqianUser = responseObject[@"results"][@"user_phone"];
                            ExdangqianUserUid = responseObject[@"results"][@"id"];
                            [CommonCode writeToUserD:[NSString stringWithFormat:@"%@",ExdangqianUser] andKey:@"dangqianUser"];
                            [CommonCode writeToUserD:responseObject[@"results"][@"id"] andKey:@"dangqianUserUid"];
                            [self dismissViewControllerAnimated:YES completion:nil];
                            [CommonCode writeToUserD:@(YES) andKey:@"isLogin"];
                            [CommonCode writeToUserD:responseObject andKey:@"dangqianUserInfo"];
                            //拿到图片
                            UIImage *userAvatar = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:USERPHOTOHTTPSTRING(responseObject[@"results"][@"avatar"])]]];
                            NSString *path_sandox = NSHomeDirectory();
                            //设置一个图片的存储路径
                            NSString *avatarPath = [path_sandox stringByAppendingString:@"/Documents/userAvatar.png"];
                            //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
                            [UIImagePNGRepresentation(userAvatar) writeToFile:avatarPath atomically:YES];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSccess" object:responseObject];
                            [CommonCode writeToUserD:@"ShouJi" andKey:@"isWhatLogin"];
                            
                            //判断是否需要同步本地和服务器的帮你读列表数据
                            NSArray *array = [CommonCode readFromUserD:@"urlList"];
                            if (array.count != 0) {
                                [CommonCode writeToUserD:@(YES) andKey:@"syncUrlList"];
                            }else{
                                [CommonCode writeToUserD:@(NO) andKey:@"syncUrlList"];
                            }
                            //获取播放限制状态
                            [APPDELEGATE getVipLimitData];
                            [APPDELEGATE getAppVersion];
                        }else{
                            XWAlerLoginView *alert = [[XWAlerLoginView alloc] initWithTitle:responseObject[msg]];
                            [alert show];
                        }
                    } failure:^(NSError *error) {
                        NSLog(@"error = %@",error);
                    }];
                    
                }
                else if ([responseObject[@"status"] integerValue] == 0){
                    UIAlertController *qingdengru = [UIAlertController alertControllerWithTitle:responseObject[@"msg"] message:nil preferredStyle:UIAlertControllerStyleAlert];
                    [qingdengru addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    }]];
                    
                    [self presentViewController:qingdengru animated:YES completion:^{
                    }];
                }
            } failure:^(NSError *error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注册失败" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            }];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"两次输入密码不一致" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"密码不能少于6位" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
