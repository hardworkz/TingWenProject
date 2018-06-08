//
//  newsDetailModel.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2017/6/21.
//  Copyright © 2017年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 {
 msg = "\U8bf7\U6c42\U6210\U529f!";
 results =     {
 act =         {
 description = "\U8d22\U7ecf\U65b0\U95fb\U3001\U65f6\U653f\U65b0\U95fb\U4e3b\U64ad";
 "fan_num" = 96855;
 id = 56;
 images = "http://tingwen-1254240285.file.myqcloud.com/2017-02-23/crop_58aeaa5eaa615.jpg";
 "is_fan" = 1;
 "message_num" = 46;
 name = "\U9ad8\U660e";
 };
 "is_collection" = 0;
 "post_news" = 56;
 praisenum = 158;
 "user_zan" = 0;
 };
 status = 1;
 }

 */
@class newsActModel;
@interface newsDetailModel : NSObject
@property (nonatomic, strong) NSString *post_id;/**<新闻ID*/
@property (nonatomic, strong) NSString *post_news;/**<新闻节目ID */
@property (nonatomic, strong) NSString *post_title;/**<新闻标题 */
@property (nonatomic, strong) NSString *post_lai;/**<新闻来源 */
@property (nonatomic, strong) NSString *post_mp;/**<新闻音频url */
@property (nonatomic, strong) NSString *post_time;/**<新闻音频总时间（ps:秒数，要除1000） */
@property (nonatomic, strong) NSString *post_size;/**<音频大小 */
@property (nonatomic, strong) NSString *post_excerpt;/**<新闻内容摘要 */
@property (nonatomic, strong) NSString *post_modified;/**<新闻发布日期 */
@property (nonatomic, strong) NSString *comment_count;/**<新闻评论数 */
@property (nonatomic, strong) NSString *smeta;/**<新闻封面图片 */
@property (nonatomic, strong) NSString *gold;/**<被打赏的金币总额 */
@property (nonatomic, strong) NSString *is_collection;/**<是否收藏 */
@property (nonatomic, strong) NSString *praisenum;/**<新闻总点赞数 */
@property (nonatomic, strong) NSString *user_zan;/**<当前用户对新闻点赞数 */
@property (nonatomic, strong) NSString *reward_num;/**<打赏数 */
@property (nonatomic, strong) NSString *url;/**<原文url */
@property (nonatomic, strong) newsActModel *act;/**<主播数据模型 */
@property (nonatomic, strong) NSArray *reward;/**<打赏数据 */
@end
