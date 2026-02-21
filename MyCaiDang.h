
//  Created by 野望 on 2022/8/16.
//  Copyright © 2022 野望. All rights reserved.
//Mem


//#define  远程地址  @"https://0ss.top/json/caidan.json"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyCaiDang : UIView
+(void)关闭追踪;//Nctabmenu 关闭追踪
extern BOOL 射线开关,血量开关,名字开关,追踪开关;
extern BOOL 过直播开关;
+ (void)onConsoleButtonTapped;
+ (void)启动;
@end

NS_ASSUME_NONNULL_END
