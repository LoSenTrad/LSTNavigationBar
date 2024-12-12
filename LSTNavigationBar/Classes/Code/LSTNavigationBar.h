//
//  LSTNavigationBar.h
//
//  Created by LoSenTrad on 2018/3/19.
//  Copyright © 2018年 LoSenTrad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSTNavigationBarContentView.h"

@interface LSTNavigationItem : NSObject

@property (nonatomic, assign) LSTNavigationBarTitleViewStyle titleViewStyle; // 标题视图风格

@property (nonatomic, copy) NSString *title; // 导航栏标题

@property (nonatomic, strong) UIColor *titleColor; // 导航栏标题颜色

@property (nonatomic, strong) UIView *titleView; // 导航栏标题视图

@property (nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *titleTextAttributes; // 导航栏标题文本属性

@property (nonatomic, strong) UIButton *leftBarButton; // 导航栏左边按钮

@property (nonatomic, copy) NSArray<UIView *> *leftBarItems; // 导航栏左边视图数组

@property (nonatomic, strong) UIButton *rightBarButton; // 导航栏右边按钮

@property (nonatomic, copy) NSArray<UIView *> *rightBarItems; // 导航栏右边视图数组

@property (nonatomic, assign) CGFloat alpha; // 内容视图透明度

@end

@interface LSTNavigationBar : UIView

@property (nonatomic, strong) UIImage *backgroundImage; // 导航栏背景图片

@property (nonatomic, strong) UIImage *shadowImage; // 导航栏底部阴影图片

@property (nonatomic, assign) BOOL prefersLargeTitles; // 开启或关闭导航栏大标题

@property (nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *largeTitleTextAttributes; // 导航栏大标题文本属性

@property (nonatomic, assign) CGFloat contentOffset; // 导航栏内容高度偏移量

@property (nonatomic, assign) CGFloat verticalOffset; // 导航栏垂直位置偏移量

/// 左间距 默认0 大于0生效
@property (nonatomic, assign) CGFloat LeftSpacing;
/// 右间距 默认0 大于0生效
@property (nonatomic, assign) CGFloat rightSpacing;

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated; // 隐藏或显示导航栏，如果animated=YES，将开启动画效果

@end

@interface UIViewController (LSTNavigationBar)

@property (nonatomic, strong, readonly) LSTNavigationBar *lst_navigationBar;

@property (nonatomic, strong, readonly) LSTNavigationItem *lst_navigationItem;

@property (nonatomic, assign) BOOL lst_navigationBarDisabled; // 是否禁用LSTNavigationBar，使用系统导航栏

- (void)registerNavigationBar; // 注册LSTNavigationBar

@end

@interface UINavigationController (LSTNavigationBar)

@property (nonatomic, assign) BOOL lst_navigationBarEnabled; // 是否开启LSTNavigationBar

@property (nonatomic, strong) UIColor *lst_barTintColor; // 导航栏背景颜色

@property (nonatomic, strong) UIImage *lst_barBackgroundImage; // 导航栏背景图片

@property (nonatomic, strong) UIImage *lst_barShadowImage; // 导航栏底部阴影图片

@property (nonatomic, assign) BOOL lst_navigationBarHidden; // 隐藏或显示导航栏

@property (nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *lst_titleTextAttributes; // 导航栏标题文本属性

@end
