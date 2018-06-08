//
//  ShufflingTableViewCell.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2018/5/2.
//  Copyright © 2018年 zhimi. All rights reserved.
//

#import "ShufflingTableViewCell.h"

@implementation ShufflingTableViewCell
+(ShufflingTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    ShufflingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self)];
    if (cell == nil) {
        cell = [[ShufflingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(self)];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    }
    return self;
}
- (void)setSlideADResult:(NSMutableArray *)slideADResult
{
    _slideADResult = slideADResult;
    
    [self setupTBCView];
}
- (void)setupTBCView{
    if (self.slideADResult.count != 0) {
        TBCircleScrollView *tbScView = [[TBCircleScrollView alloc] initWithFrame:CGRectMake(15.0 / 375 * IPHONE_W, 0, IPHONE_W - 30.0 / 375 * IPHONE_W, IS_IPHONEX?162.0:162.0 / 667 * SCREEN_HEIGHT) andArr:self.slideADResult];
        tbScView.scrollView.scrollsToTop = NO;
        tbScView.biaozhiStr = @"头条";
        NSMutableArray *imgArr = [[NSMutableArray alloc]init];
        for (int i = 0; i <self.slideADResult.count; i++ ){
            [imgArr addObject:NEWSSEMTPHOTOURL(self.slideADResult[i][@"picture"])];
        }
        tbScView.ztADCount = [imgArr count];
        tbScView.imageArray = [NSArray arrayWithArray:imgArr];
        [self.contentView addSubview:tbScView];
    }
}
@end
