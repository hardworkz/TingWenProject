//
//  ECMacroHelper.h
//  MacroDemo
//
//  Created by Eric Wang on 15/6/11.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#ifndef ECMacroHelper_h
#define ECMacroHelper_h

#define DefineWeakSelf __weak __typeof(self) weakSelf = self;


#pragma mark - UIColor

/**
 *  UIColor
 *  usage: UIColorFromHex(0x323232)
 */
#define UIColorFromHexWithAlpha(hexValue,a) [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0xFF00) >> 8))/255.0 blue:((float)(hexValue & 0xFF))/255.0 alpha:a]

#define UIColorFromHex(hexValue)            UIColorFromHexWithAlpha(hexValue,1.0)
#define UIColorFromRGBA(r,g,b,a)            [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define UIColorFromRGB(r,g,b)               UIColorFromRGBA(r,g,b,1.0)

#pragma mark - iOS Version

#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

#define IOS_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)

#define IOS_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)

#define IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define IOS_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#define IOS_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#pragma mark - Screen size

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

#define AdaptiveScale_W (SCREEN_WIDTH/375.0)

#pragma mark - Device type.

#define TARGETED_DEVICE_IS_IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
#define TARGETED_DEVICE_IS_IPHONE UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone
#define TARGETED_DEVICE_IS_IPHONE_480 TARGETED_DEVICE_IS_IPHONE && SCREEN_HEIGHT == 480
#define TARGETED_DEVICE_IS_IPHONE_568 TARGETED_DEVICE_IS_IPHONE && SCREEN_HEIGHT == 568
#define TARGETED_DEVICE_IS_IPHONE_667 TARGETED_DEVICE_IS_IPHONE && SCREEN_HEIGHT == 667
#define TARGETED_DEVICE_IS_IPHONE_736 TARGETED_DEVICE_IS_IPHONE && SCREEN_HEIGHT == 736
#define TARGETED_DEVICE_IS_IPHONE_812 TARGETED_DEVICE_IS_IPHONE && SCREEN_HEIGHT == 812

#endif
