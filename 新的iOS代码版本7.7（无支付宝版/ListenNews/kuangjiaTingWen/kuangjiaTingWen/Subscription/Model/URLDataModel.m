//
//  URLDataModel.m
//  kuangjiaTingWen
//
//  Created by 泡果 on 2018/4/23.
//  Copyright © 2018年 zhimi. All rights reserved.
//

#import "URLDataModel.h"

@implementation URLDataModel
//- (BOOL)isEqualToPerson:(URLDataModel *)model {
//    if (!model) {
//        return NO;
//    }
//    BOOL haveEqualArticle_url = [self.article_url isEqualToString:model.article_url];
//    
//    return haveEqualArticle_url;
//}
//- (NSUInteger)hash
//{
//    return [_article_url hash];
//}
//- (BOOL)isEqual:(id)object
//{
//    if (self == object) {
//        return YES;
//    }
//    if (![object isKindOfClass:[URLDataModel class]]) {
//        return NO;
//    }
//    return [self isEqualToPerson:object];
//}
#pragma mark -- 重写上面三个方法用来进行模型数组去重
+ (void)load
{
    [URLDataModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"ID":@"id"};
    }];
}
- (NSString *)domain
{
    NSURL *url = [NSURL URLWithString:_article_url];
    return url.host.description;
}
- (NSString *)source
{
    return _source?_source:_domain;
}
- (BOOL)isUpload
{
    return _ID?YES:NO;
}
@end
