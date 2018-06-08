//
//  UrlListCellFrameModel.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2018/4/23.
//  Copyright © 2018年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UrlListCellFrameModel : NSObject<NSCoding>
@property (strong, nonatomic) URLDataModel *model;

@property (assign, nonatomic) CGRect titleF;
@property (assign, nonatomic) CGRect imageF;
@property (assign, nonatomic) CGRect urlF;
@property (assign, nonatomic) CGRect createTimeF;
@property (assign, nonatomic) CGRect sourceF;
@property (assign, nonatomic) CGRect deviderF;
@property (assign, nonatomic) CGFloat cellHeight;
@end
