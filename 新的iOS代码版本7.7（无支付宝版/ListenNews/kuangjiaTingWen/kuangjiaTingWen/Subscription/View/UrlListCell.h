//
//  UrlListCell.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2018/4/23.
//  Copyright © 2018年 zhimi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UrlListCellFrameModel;
@interface UrlListCell : UITableViewCell
@property (strong, nonatomic) NSMutableArray *readUrlArray;
@property (strong, nonatomic) UrlListCellFrameModel *frameModel;
+(UrlListCell *)cellWithTableView:(UITableView *)tableView;
@end
