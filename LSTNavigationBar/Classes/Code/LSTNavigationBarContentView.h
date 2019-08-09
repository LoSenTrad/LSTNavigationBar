//
//  LSTNavigationBarContentView.h
//
//  Created by LoSenTrad on 2018/3/19.
//  Copyright © 2018年 LoSenTrad. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LSTNavigationBarTitleViewStyle) {
    LSTNavigationBarTitleViewStyleDefault,  // 水平居中
    LSTNavigationBarTitleViewStyleAutomatic // 自动适应
};

@interface LSTNavigationBarContentView : UIView

@property (nonatomic, assign) LSTNavigationBarTitleViewStyle titleViewStyle;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView *titleView;

@property (nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *titleTextAttributes;

@property (nonatomic, strong) UIButton *leftBarButton;

@property (nonatomic, copy) NSArray<UIView *> *leftBarItems;

@property (nonatomic, strong) UIButton *rightBarButton;

@property (nonatomic, copy) NSArray<UIView *> *rightBarItems;

@end
