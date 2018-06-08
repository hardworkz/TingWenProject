//
//  UrlListCellFrameModel.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2018/4/23.
//  Copyright © 2018年 zhimi. All rights reserved.
//

#import "UrlListCellFrameModel.h"

@implementation UrlListCellFrameModel
MJCodingImplementation
- (void)setModel:(URLDataModel *)model
{
    _model = model;
    
//    CGFloat imageW = SCREEN_WIDTH == 320?100:130;
    _imageF = CGRectMake(SCREEN_WIDTH - 120.0 / 375 * IPHONE_W, 15, 105.0 / 375 * IPHONE_W, 84.72 / 375 *IPHONE_W);
    if (IS_IPAD) {
        _imageF = CGRectMake(SCREEN_WIDTH - 125.0 / 375 * IPHONE_W, 19, 105.0 / 375 * IPHONE_W, 70.0 / 375 *IPHONE_W);
    }else if (IS_IPHONEX){
        _imageF = CGRectMake(SCREEN_WIDTH - 125.0, 19, 105.0, 84.72);
    }
    
    CGSize titleSize = [model.title boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - _imageF.size.width - 40, SCREEN_WIDTH == 320?50:75) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:CUSTOM_FONT_TYPE(17.0)} context:nil].size;
    _titleF = CGRectMake(15, 10, titleSize.width == 0?SCREEN_WIDTH - _imageF.size.width - 10 - 15:titleSize.width, titleSize.height == 0?40:titleSize.height);
    
    NSDate *date = [NSDate dateFromString:model.createtime];
    CGSize timeSize = [[NSString stringWithFormat:@"%@      ",[date showTimeByTypeA]] boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:CUSTOM_FONT_TYPE(12.0)} context:nil].size;
    
//    if (SCREEN_WIDTH == 320) {
//        _createTimeF = CGRectMake(_titleF.origin.x, CGRectGetMaxY(_titleF) + 5, timeSize.width, timeSize.height);
//    }else{
        _createTimeF = CGRectMake(_titleF.origin.x, CGRectGetMaxY(_imageF) - timeSize.height , timeSize.width, timeSize.height);
//    }
    
    CGSize sourceSize = [[NSString stringWithFormat:@"来自:%@",model.source] boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:CUSTOM_FONT_TYPE(12.0)} context:nil].size;
    _sourceF = CGRectMake(_imageF.origin.x - sourceSize.width - 10, _createTimeF.origin.y, sourceSize.width, sourceSize.height);
    
    _cellHeight = CGRectGetMaxY(_imageF) + 15;
    _deviderF = CGRectMake(0, _cellHeight - 0.5, SCREEN_WIDTH, 0.5);
}
@end
