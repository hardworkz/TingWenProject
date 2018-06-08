//
//  UrlListCell.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2018/4/23.
//  Copyright © 2018年 zhimi. All rights reserved.
//

#import "UrlListCell.h"

@interface UrlListCell ()
{
    UILabel *title;
    UILabel *url;
    UILabel *createTime;
    UILabel *source;
    UIImageView *image;
    UIView *devider;
}
@end
@implementation UrlListCell

+(UrlListCell *)cellWithTableView:(UITableView *)tableView
{
    UrlListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self)];
    if (cell == nil) {
        cell = [[UrlListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(self)];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        title = [[UILabel alloc] init];
        title.font = CUSTOM_FONT_TYPE(17.0);
        title.numberOfLines = 0;
        [self.contentView addSubview:title];
        
        createTime = [[UILabel alloc] init];
        createTime.font = CUSTOM_FONT_TYPE(12.0);
        createTime.numberOfLines = 2;
        createTime.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:createTime];
        
        source = [[UILabel alloc] init];
        source.font = CUSTOM_FONT_TYPE(12.0);
        source.numberOfLines = 0;
        source.textAlignment = NSTextAlignmentRight;
        source.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:source];
        
        image = [[UIImageView alloc] init];
        image.contentMode = UIViewContentModeScaleAspectFill;
        image.clipsToBounds = YES;
        [self.contentView addSubview:image];
        
        devider = [[UIView alloc] init];
        devider.backgroundColor = nMineNameColor;
        [self.contentView addSubview:devider];
    }
    return self;
}
- (void)setFrameModel:(UrlListCellFrameModel *)frameModel
{
    _frameModel = frameModel;
    
    title.frame = frameModel.titleF;
    title.textColor = [self textColorFormUrl:frameModel.model.article_url];
    createTime.frame = frameModel.createTimeF;
    source.frame = frameModel.sourceF;
    image.frame = frameModel.imageF;
    devider.frame = frameModel.deviderF;
    
    if (frameModel.model.title == nil) {
        createTime.hidden = YES;
        source.hidden = YES;
        image.hidden = YES;
        title.text = frameModel.model.article_url;
        
    }else{
        createTime.hidden = NO;
        source.hidden = NO;
        image.hidden = NO;
        title.text = frameModel.model.title;
        
        NSDate *date = [NSDate dateFromString:frameModel.model.createtime];
        createTime.text = [date showTimeByTypeA];
        source.text = [NSString stringWithFormat:@"来自:%@",frameModel.model.source];
        [image sd_setImageWithURL:[NSURL URLWithString:frameModel.model.img_url] placeholderImage:[UIImage imageNamed:@"听闻帮你读"]];
    }
}
- (UIColor *)textColorFormUrl:(NSString *)url
{
    UIColor *returnColor = [UIColor blackColor];
    NSArray *yitingguoArr = [NSArray arrayWithArray:self.readUrlArray];
    for (int i = 0; i < yitingguoArr.count; i ++){
        if ([url isEqualToString:yitingguoArr[i]]){
            returnColor = [[UIColor grayColor] colorWithAlphaComponent:0.7f];
                break;
        }
    }
    return returnColor;
}

@end
