//
//  URLDataModel.h
//  kuangjiaTingWen
//
//  Created by 泡果 on 2018/4/23.
//  Copyright © 2018年 zhimi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLDataModel : NSObject
@property(nonatomic,copy)NSString *ID; /**<ID*/
@property(nonatomic,copy)NSString *user_id; /**<用户ID*/
@property(nonatomic,copy)NSString *article_url; /**<网址*/
@property(nonatomic,copy)NSString *img_url; /**<封面图*/
@property(nonatomic,copy)NSString *title; /**<标题*/
@property(nonatomic,copy)NSString *domain; /**<域名*/
@property(nonatomic,copy)NSString *source; /**<来源*/
@property(nonatomic,copy)NSString *createtime; /**<保存时间*/
@property(nonatomic,assign)BOOL isUpload; /**<是否上传*/
@property(nonatomic,assign)BOOL isFromTouTiao; /**<是否来自今日头条*/
@end
