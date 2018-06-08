//
//  zhuceVC.m
//  reHeardTheNews
//
//  Created by Pop Web on 16/3/21.
//  Copyright © 2016年 paoguo. All rights reserved.
//

#import "zhuceVC.h"
#import "UserXieYIViewController.h"
#import "yanzhengmaVC.h"
@interface zhuceVC ()
{
    BOOL isAgree;
    UITextField *phoneF;
}
@end

@implementation zhuceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isAgree = NO;
    [self enableAutoBack];
    self.title = @"用户注册";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                                    NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(IPHONE_W / 2 - 160.0 / 375 * IPHONE_W, 124.0 / 667 * IPHONE_H, 320.0 / 375 * IPHONE_W, 1)];
    line.backgroundColor = gMainColor;
    [self.view addSubview:line];
    
    UIButton *NextStep = [UIButton buttonWithType:UIButtonTypeCustom];
    NextStep.frame = CGRectMake(0, 185.0 / 667 * IPHONE_H, IPHONE_W, 44.0 / 667 * IPHONE_H);
    NextStep.backgroundColor = gMainColor;
    [NextStep setTitle:@"下一步" forState:UIControlStateNormal];
    [NextStep addTarget:self action:@selector(NextStep:) forControlEvents:UIControlEventTouchUpInside];
    [NextStep setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:NextStep];
    
    phoneF = [[UITextField alloc]initWithFrame:CGRectMake(27.5 / 375 * IPHONE_W, 95.0 / 667 * IPHONE_H, 320.0 / 375 * IPHONE_W, 30.0 / 667 * IPHONE_H)];
    phoneF.placeholder = @"手机号码";
    phoneF.font = [UIFont systemFontOfSize:14.0f];
    phoneF.textAlignment = NSTextAlignmentCenter;
    phoneF.keyboardType = UIKeyboardTypeNumberPad;
    phoneF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:phoneF];
    
    UIButton *agreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    agreeBtn.frame = CGRectMake(117.0 / 375 * IPHONE_W, 147.0 / 667 * IPHONE_H, 15.0 / 375 * IPHONE_W, 15.0 / 667 * IPHONE_H);
    [agreeBtn setBackgroundImage:[UIImage imageNamed:@"agreement_agree_btn"] forState:UIControlStateNormal];
    [agreeBtn addTarget:self action:@selector(agreeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:agreeBtn];
    agreeBtn.contentMode = UIViewContentModeScaleToFill;

    UILabel *agreeLab = [[UILabel alloc]initWithFrame:CGRectMake(131.0 / 375 * IPHONE_W, 144.0 / 667 * IPHONE_H, 42.0 / 375 * IPHONE_W, 21.0 / 667 * IPHONE_H)];
    agreeLab.text = @"同意";
    agreeLab.textColor = [UIColor blackColor];
    agreeLab.font = [UIFont systemFontOfSize:13.0f];
    agreeLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:agreeLab];

    UIButton *xieyiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    xieyiBtn.frame = CGRectMake(165.0 / 375 * IPHONE_W, 147.0 / 667 * IPHONE_H, 108.0, 16.0 / 667 * IPHONE_H);
    [xieyiBtn setTitle:@"《听闻用户协议》" forState:UIControlStateNormal];
    [xieyiBtn addTarget:self action:@selector(xieyiBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [xieyiBtn setTitleColor:gMainColor forState:UIControlStateNormal];
    xieyiBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [self.view addSubview:xieyiBtn];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.hidesBottomBarWhenPushed = YES;
}

- (void)agreeAction:(UIButton *)sender
{
    if (isAgree == NO)
    {
        [sender setBackgroundImage:[UIImage imageNamed:@"agreement_agree_btn_selected"] forState:UIControlStateNormal
         ];
        isAgree = YES;
    }else
    {
        [sender setBackgroundImage:[UIImage imageNamed:@"agreement_agree_btn"] forState:UIControlStateNormal
         ];
        isAgree = NO;
    }
}

- (void)NextStep:(UIButton *)sender{
    if (isAgree == NO){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请勾选同意用户协议" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else{
        if (phoneF.text.length == 11){
            RTLog(@"%@",phoneF.text);
            [NetWorkTool postPaoGuoZhuCeYanZhengMaWithphoneFNumber:[DSE encryptUseDES:phoneF.text] anduseType:@"1" sccess:^(NSDictionary *responseObject) {
                if ([responseObject[@"status"] integerValue] == 1) {
                    ExyanzhengmaStr = [NSString stringWithFormat:@"%@",responseObject[@"results"]];
                    ExZhuCeAccessToken = phoneF.text;
                    [self.navigationController pushViewController:[yanzhengmaVC new] animated:YES];
                }
                else{
                     [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",responseObject[@"msg"]]];
                    [self performSelector:@selector(SVPDismiss) withObject:nil afterDelay:1.0];
                }
            } failure:^(NSError *error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"您输入的手机号码格式不正确!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            }];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入正确的手机号码" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}

- (void)xieyiBtnAction:(UIButton *)sender{
    [self.navigationController pushViewController:[NewRegisterController new] animated:YES];
}

- (void)SVPDismiss {
    [SVProgressHUD dismiss];
}

@end
