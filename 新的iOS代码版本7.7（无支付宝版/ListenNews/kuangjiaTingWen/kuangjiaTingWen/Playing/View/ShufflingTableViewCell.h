//
//  ShufflingTableViewCell.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2018/5/2.
//  Copyright © 2018年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShufflingTableViewCell : UITableViewCell
/**
 广告轮播数据
 */
@property (strong, nonatomic) NSMutableArray *slideADResult;

+(ShufflingTableViewCell *)cellWithTableView:(UITableView *)tableView;
@end
