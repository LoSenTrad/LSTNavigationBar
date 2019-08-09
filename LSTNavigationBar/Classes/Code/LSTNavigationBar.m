//
//  LSTNavigationBar.m
//
//  Created by LoSenTrad on 2018/3/19.
//  Copyright © 2018年 LoSenTrad. All rights reserved.
//

#import "LSTNavigationBar.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "UIView+LSTView.h"

#import <objc/runtime.h>

const CGFloat LSTNavigationBarDefaultHeight = 44.f;
const CGFloat LSTNavigationBarLargeTitleMinHeight = 49.f;
const CGFloat LSTNavigationBarPortraitHeight = 44.f;
const CGFloat LSTNavigationBarLandscapeHeight = 32.f;
const CGFloat LSTNavigationBarShadowViewHeight = 0.5;
const CGFloat LSTNavigationBarIPhoneXFixedSpaceWidth = 56.f;

#define LSTNavigationBarIsIPhoneX lst_IsIphoneX_ALL()


#define LSTNavigationBarStatusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define LSTNavigationBarScreenWidth [UIScreen mainScreen].bounds.size.width

#define LSTNavigationBarDefaultFrame CGRectMake(0, LSTNavigationBarStatusBarHeight, LSTNavigationBarScreenWidth, LSTNavigationBarDefaultHeight)

#pragma mark - LSTNavigationItem
@interface LSTNavigationItem ()

@property (nonatomic, strong) LSTNavigationBarContentView *contentView;

@end

@implementation LSTNavigationItem



#pragma mark - ***** setter 设置器 *****

- (void)setTitleViewStyle:(LSTNavigationBarTitleViewStyle)titleViewStyle {
    _titleViewStyle = titleViewStyle;
    self.contentView.titleViewStyle = titleViewStyle;
}

- (void)setTitle:(NSString *)title {
    _title = [title copy];
    self.contentView.title = title;
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    self.contentView.titleLabel.textColor = titleColor;
}

- (void)setTitleView:(UIView *)titleView {
    _titleView = titleView;
    self.contentView.titleView = titleView;
}

- (void)setTitleTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)titleTextAttributes {
    _titleTextAttributes = [titleTextAttributes copy];
    self.contentView.titleTextAttributes = titleTextAttributes;
}

- (void)setLeftBarButton:(UIButton *)leftBarButton {
    _leftBarButton = leftBarButton;
    self.contentView.leftBarButton = leftBarButton;
}

- (void)setLeftBarItems:(NSArray<UIView *> *)leftBarItems {
    _leftBarItems = [leftBarItems copy];
    self.contentView.leftBarItems = leftBarItems;
}

- (void)setRightBarButton:(UIButton *)rightBarButton {
    _rightBarButton = rightBarButton;
    self.contentView.rightBarButton = rightBarButton;
}

- (void)setRightBarItems:(NSArray<UIView *> *)rightBarItems {
    _rightBarItems = [rightBarItems copy];
    self.contentView.rightBarItems = rightBarItems;
}

- (void)setAlpha:(CGFloat)alpha {
    _alpha = alpha;
    self.contentView.alpha = alpha;
}

#pragma mark - ***** 懒加载 *****
- (LSTNavigationBarContentView *)contentView {
    if (!_contentView) {
        _contentView = [[LSTNavigationBarContentView alloc] init];
    }
    return _contentView;
}

@end

#pragma mark - LSTNavigationBar
@interface LSTNavigationBar ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) LSTNavigationItem *navigationItem;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *shadowImageView;
@property (nonatomic, strong) UIVisualEffectView *visualEffectView;
@property (nonatomic, strong) UIView *largeTitleView;
@property (nonatomic, strong) UILabel *largeTitleLabel;

@property (nonatomic, assign) BOOL willHidden;
@property (nonatomic, copy) NSString *identifier;

@end

@implementation LSTNavigationBar


#pragma mark - ***** UIView生命周期 *****

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super initWithFrame:LSTNavigationBarDefaultFrame];
    if (self) {
        _identifier = identifier;
        [self lst_addObserver];
        [self lst_addSubviews];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_identifier) {
        [self removeObserver:self forKeyPath:@"navigationItem.title"];
    }
}

#pragma mark - ***** UI布局 *****

- (void)lst_addSubviews {
    [self lst_addBackgroundView];//添加背景view
    [self lst_addBackgroundImageView];//添加背景图片imageView
    [self lst_addShadowImageView];//添加底部阴影线
    [self lst_addVisualEffectView];//添加高斯模糊层
    [self lst_addLargeTitleView];//添加大标题view
}

- (void)lst_layoutIfNeeded {
    [self lst_layoutSubviews];
}

- (void)lst_layoutSubviews {
    BOOL isLandscape = [self lst_isLandscape];
    CGFloat largeTitleViewHeight = (self.prefersLargeTitles && !isLandscape) ? [self lst_largeTitleViewHeight] : 0.f;
    
    CGFloat statusBarHeight = isLandscape ? 0.f : (LSTNavigationBarIsIPhoneX ? 44.f : 20.f);
    CGFloat contentHeight = isLandscape ? LSTNavigationBarLandscapeHeight : LSTNavigationBarPortraitHeight;
    if (!isLandscape) contentHeight += self.contentOffset;
    
    CGRect barFrame = CGRectMake(0, statusBarHeight + self.verticalOffset, LSTNavigationBarScreenWidth, contentHeight + largeTitleViewHeight);
    if (self.willHidden) barFrame.origin.y = -barFrame.size.height;
    self.frame = barFrame;
    
    self.backgroundView.frame = [self barBackgroundFrame];
    self.backgroundImageView.frame = self.backgroundView.bounds;
    self.shadowImageView.frame = [self barShadowViewFrame];
    self.visualEffectView.frame = self.backgroundView.bounds;
    
    CGRect contentFrame = CGRectMake(0, 0, LSTNavigationBarScreenWidth, contentHeight);
    if ([self lst_needsFixedSpace]) {
        contentFrame.origin.x = LSTNavigationBarIPhoneXFixedSpaceWidth;
        contentFrame.size.width = LSTNavigationBarScreenWidth - LSTNavigationBarIPhoneXFixedSpaceWidth * 2;
    }
    self.navigationItem.contentView.frame = contentFrame;
    
    self.largeTitleView.frame = CGRectMake(0, CGRectGetMaxY(contentFrame), CGRectGetWidth(self.frame), largeTitleViewHeight);
    [self lst_showLargeTitle:(!isLandscape && self.prefersLargeTitles)];
}


#pragma mark - ***** setter设置器 *****
// over write
- (void)setFrame:(CGRect)frame {
    frame.origin.x = 0.f;
    frame.size.width = LSTNavigationBarScreenWidth;
    [super setFrame:frame];
}

- (void)setAlpha:(CGFloat)alpha {
    _backgroundView.alpha = alpha;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _visualEffectView.backgroundColor = backgroundColor;
    _visualEffectView.effect = backgroundColor ? nil : [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
}

- (void)setHidden:(BOOL)hidden {
    [self setHidden:hidden animated:NO];
}


- (void)setHidden:(BOOL)hidden animated:(BOOL)animated {
    self.willHidden = hidden;
    if (hidden) {
        if (animated) {
            [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
                [self lst_layoutIfNeeded];
            } completion:^(BOOL finished) {
                if (finished) {
                    if (self.frame.origin.y < 0) {
                        [super setHidden:hidden];
                    }
                }
            }];
        }
        else {
            [self lst_layoutIfNeeded];
            [super setHidden:hidden];
        }
    }
    else {
        [super setHidden:hidden];
        if (animated) {
            [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
                [self lst_layoutIfNeeded];
            }];
        }
        else {
            [self lst_layoutIfNeeded];
        }
    }
}

- (void)setNavigationItem:(LSTNavigationItem *)navigationItem {
    _navigationItem = navigationItem;
    
    [_navigationItem.contentView removeFromSuperview];
    [self addSubview:_navigationItem.contentView];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    _backgroundImageView.image = backgroundImage;
    
    _visualEffectView.hidden = backgroundImage != nil;
}

- (void)setShadowImage:(UIImage *)shadowImage {
    _shadowImage = shadowImage;
    _shadowImageView.image = shadowImage;
}

- (void)setPrefersLargeTitles:(BOOL)prefersLargeTitles {
    _prefersLargeTitles = prefersLargeTitles;
    
    if ([self lst_isLandscape]) return;
    [self lst_layoutIfNeeded];
}

- (void)setLargeTitleTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)largeTitleTextAttributes {
    _largeTitleTextAttributes = [largeTitleTextAttributes copy];
    
    if (!self.prefersLargeTitles) {
        return;
    }
    if (self.navigationItem.title) {
        _largeTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:self.navigationItem.title attributes:largeTitleTextAttributes];
        
        [self lst_layoutIfNeeded];
    }
}

- (void)setContentOffset:(CGFloat)contentOffset {
    _contentOffset = contentOffset > -14.f ? contentOffset : -14.f;
    
    if ([self lst_isLandscape]) return;
    [self lst_layoutIfNeeded];
}

- (void)setVerticalOffset:(CGFloat)verticalOffset {
    _verticalOffset = verticalOffset < 0.f ? verticalOffset : 0.f;
    
    [self lst_layoutIfNeeded];
}


#pragma mark - ***** Other 其他 *****

- (void)lst_addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameDidChange:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    [self addObserver:self forKeyPath:@"navigationItem.title" options:NSKeyValueObservingOptionNew context:nil];
}



- (CGRect)barBackgroundFrame {
    return CGRectMake(0, -self.frame.origin.y, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) + self.frame.origin.y);
}

- (CGRect)barShadowViewFrame {
    return CGRectMake(0, CGRectGetHeight(_backgroundView.frame), CGRectGetWidth(_backgroundView.frame), LSTNavigationBarShadowViewHeight);
}


- (BOOL)lst_isLandscape {
    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
    return UIInterfaceOrientationIsLandscape(orientation);
}

- (BOOL)lst_needsFixedSpace {
    return [self lst_isLandscape] && LSTNavigationBarIsIPhoneX;
}

- (CGFloat)lst_largeTitleViewHeight {
    UIFont *font = (UIFont *)self.largeTitleTextAttributes[NSFontAttributeName];
    CGFloat largeTitleViewHeight = font.pointSize * 1.2 > LSTNavigationBarLargeTitleMinHeight ? font.pointSize * 1.2 : LSTNavigationBarLargeTitleMinHeight;
    return largeTitleViewHeight;
}

- (void)lst_showLargeTitle:(BOOL)show {
    if (show) {
        _largeTitleView.hidden = NO;
        _largeTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:self.navigationItem.title ?: @"" attributes:self.largeTitleTextAttributes];
        
        _largeTitleLabel.frame = CGRectMake(16.f, 0.f, LSTNavigationBarScreenWidth - 32.f, CGRectGetHeight(_largeTitleView.frame));
        _navigationItem.contentView.titleLabel.alpha = 0.f;
        _largeTitleLabel.alpha = 1.f;
    }
    else {
        _largeTitleView.hidden = YES;
        _navigationItem.contentView.titleLabel.alpha = 1.f;
        _largeTitleLabel.alpha = 0.f;
    }
}

#pragma mark - ***** 通知 *****

- (void)statusBarFrameDidChange:(NSNotification *)sender {
    [self lst_layoutIfNeeded];
}

//kvo
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"navigationItem.title"]) {
        _largeTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:self.navigationItem.title ?: @"" attributes:self.largeTitleTextAttributes];
    }
}

#pragma mark - ***** 懒加载 *****

- (void)lst_addBackgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:[self barBackgroundFrame]];
        [self addSubview:_backgroundView];
    }
}

- (void)lst_addBackgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:_backgroundView.bounds];
        [_backgroundView addSubview:_backgroundImageView];
    }
}

- (void)lst_addShadowImageView {
    if (!_shadowImageView) {
        _shadowImageView = [[UIImageView alloc] initWithFrame:[self barShadowViewFrame]];
        [_backgroundView addSubview:_shadowImageView];
    }
}

- (void)lst_addVisualEffectView {
    if (!_visualEffectView) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        _visualEffectView.frame = _backgroundView.bounds;
        [_backgroundView addSubview:_visualEffectView];
    }
}

- (void)lst_addLargeTitleView {
    if (!_largeTitleView) {
        _largeTitleView = [[UIView alloc] init];
        _largeTitleView.hidden = YES;
        [self addSubview:_largeTitleView];
        
        [self lst_addLargeTitleLable];
    }
}

- (void)lst_addLargeTitleLable {
    if (!_largeTitleLabel) {
        _largeTitleLabel = [[UILabel alloc] init];
        _largeTitleLabel.alpha = 0.f;
        _largeTitleLabel.textColor = [UIColor darkTextColor];
        _largeTitleLabel.font = [UIFont boldSystemFontOfSize:32.f];
        [_largeTitleView addSubview:_largeTitleLabel];
    }
}




@end

#pragma mark - UIViewController (LSTNavigationBar)
@implementation UIViewController (LSTNavigationBar)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *sels = @[@"viewDidLoad", @"viewWillAppear:"];
        [sels enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            Method originalMethod = class_getInstanceMethod(self, NSSelectorFromString(obj));
            NSString *swizzledSel = [@"lst__" stringByAppendingString:obj];
            Method swizzledMethod = class_getInstanceMethod(self, NSSelectorFromString(swizzledSel));
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }];
    });
}

- (void)lst__viewDidLoad {
    [self lst__viewDidLoad];
    
    if (self.navigationController) {
        
        if (!self.navigationController.lst_navigationBarEnabled) {
            return;
        }
        
        [self registerNavigationBar];
        
        self.fd_prefersNavigationBarHidden = !self.lst_navigationBarDisabled;
        
        if (self.navigationController.viewControllers.count > 1) {
            [self lst_setupBackBarButton];
        }
    }
}

- (void)lst__viewWillAppear:(BOOL)animated {
    [self lst__viewWillAppear:animated];
    
    if (self.navigationController) {
        
        if (!self.navigationController.lst_navigationBarEnabled) {
            return;
        }
        
        if (self.view.subviews.lastObject != self.lst_navigationBar) {
            [self.view bringSubviewToFront:self.lst_navigationBar];
        }
    }
}

#pragma mark - public
- (void)registerNavigationBar {
    if (self.navigationController.lst_titleTextAttributes) {
        self.lst_navigationItem.titleTextAttributes = self.navigationController.lst_titleTextAttributes;
    }
    if (self.navigationController.lst_barBackgroundImage) {
        self.lst_navigationBar.backgroundImage = self.navigationController.lst_barBackgroundImage;
    }
    if (self.navigationController.lst_barTintColor) {
        self.lst_navigationBar.backgroundColor = self.navigationController.lst_barTintColor;
    }
    if (self.navigationController.lst_barShadowImage) {
        self.lst_navigationBar.shadowImage = self.navigationController.lst_barShadowImage;
    }
    self.lst_navigationBar.hidden = self.navigationController.lst_navigationBarHidden;
    self.fd_prefersNavigationBarHidden = !self.navigationController.lst_navigationBarHidden;
    [self.view addSubview:self.lst_navigationBar];
}

#pragma mark - private
- (void)lst_setupBackBarButton {
    UIButton *backBarButton = [UIButton buttonWithType:UIButtonTypeSystem];
    backBarButton.clipsToBounds = YES;
    [backBarButton sizeToFit];
    [backBarButton setTitle:@"‹" forState:UIControlStateNormal];
    backBarButton.titleLabel.font = [UIFont fontWithName:@"Menlo-Regular" size:49.f];
    [backBarButton addTarget:self action:@selector(backBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
    self.lst_navigationItem.leftBarButton = backBarButton;
}

#pragma mark - action
- (void)backBarButtonAction {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - getter & setter
- (LSTNavigationBar *)lst_navigationBar {
    LSTNavigationBar *navigationBar = objc_getAssociatedObject(self, _cmd);
    if (!navigationBar) {
        navigationBar = [[LSTNavigationBar alloc] initWithIdentifier:NSStringFromClass(self.class)];
        objc_setAssociatedObject(self, @selector(lst_navigationBar), navigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    navigationBar.navigationItem = self.lst_navigationItem;
    return navigationBar;
}

- (void)setLst_navigationBar:(LSTNavigationBar *)lst_navigationBar {
    objc_setAssociatedObject(self, @selector(lst_navigationBar), lst_navigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (LSTNavigationItem *)lst_navigationItem {
    LSTNavigationItem *navigationItem = objc_getAssociatedObject(self, _cmd);
    if (!navigationItem) {
        navigationItem = [[LSTNavigationItem alloc] init];
        objc_setAssociatedObject(self, @selector(lst_navigationItem), navigationItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return navigationItem;
}

- (void)setLst_navigationItem:(LSTNavigationItem *)lst_navigationItem {
    objc_setAssociatedObject(self, @selector(lst_navigationItem), lst_navigationItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)lst_navigationBarDisabled {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setLst_navigationBarDisabled:(BOOL)lst_navigationBarDisabled {
    objc_setAssociatedObject(self, @selector(lst_navigationBarDisabled), @(lst_navigationBarDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.fd_prefersNavigationBarHidden = !lst_navigationBarDisabled;
}

@end

#pragma mark - UINavigationController (LSTNavigationBar)
@implementation UINavigationController (LSTNavigationBar)

+ (void)load {

//        Method originalMethod = class_getInstanceMethod(self, @selector(setNavigationBarHidden:animated:));
//        Method swizzledMethod = class_getInstanceMethod(self, @selector(lst__setNavigationBarHidden:animated:));
//        method_exchangeImplementations(originalMethod, swizzledMethod);

    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *sels = @[@"setNavigationBarHidden:", @"setNavigationBarHidden:animated:"];
        [sels enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            Method originalMethod = class_getInstanceMethod(self, NSSelectorFromString(obj));
            NSString *swizzledSel = [@"lst__" stringByAppendingString:obj];
            Method swizzledMethod = class_getInstanceMethod(self, NSSelectorFromString(swizzledSel));
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }];
    });
}

- (void)lst__setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    [self lst__setNavigationBarHidden:hidden animated:animated];
    if (hidden) {
        self.fd_prefersNavigationBarHidden = YES;
    }else {
        self.fd_prefersNavigationBarHidden = NO;
    }
    
    if (!self.lst_navigationBarEnabled) {
        return;
    }
    
    if (!hidden) {
        self.topViewController.lst_navigationBar.hidden = YES;
    }
}

- (void)lst__setNavigationBarHidden:(BOOL)hidden {
    [self lst__setNavigationBarHidden:hidden];
    if (hidden) {
        self.fd_prefersNavigationBarHidden = YES;
    }else {
        self.fd_prefersNavigationBarHidden = NO;
    }
    
    if (!self.lst_navigationBarEnabled) {
        return;
    }
    
    if (!hidden) {
        self.topViewController.lst_navigationBar.hidden = YES;
    }
}

#pragma mark - getter & setter
- (BOOL)lst_navigationBarEnabled {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setLst_navigationBarEnabled:(BOOL)lst_navigationBarEnabled {
    objc_setAssociatedObject(self, @selector(lst_navigationBarEnabled), @(lst_navigationBarEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.lst_navigationBarHidden = !lst_navigationBarEnabled;
}

- (UIColor *)lst_barTintColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setLst_barTintColor:(UIColor *)lst_barTintColor {
    objc_setAssociatedObject(self, @selector(lst_barTintColor), lst_barTintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.topViewController.lst_navigationBar.backgroundColor = lst_barTintColor;
}

- (UIImage *)lst_barBackgroundImage {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setLst_barBackgroundImage:(UIImage *)lst_barBackgroundImage {
    objc_setAssociatedObject(self, @selector(lst_barBackgroundImage), lst_barBackgroundImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.topViewController.lst_navigationBar.backgroundImage = lst_barBackgroundImage;
}

- (UIImage *)lst_barShadowImage {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setLst_barShadowImage:(UIImage *)lst_barShadowImage {
    objc_setAssociatedObject(self, @selector(lst_barShadowImage), lst_barShadowImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.topViewController.lst_navigationBar.shadowImage = lst_barShadowImage;
}

- (BOOL)lst_navigationBarHidden {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setLst_navigationBarHidden:(BOOL)lst_navigationBarHidden {
    objc_setAssociatedObject(self, @selector(lst_navigationBarHidden), @(lst_navigationBarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.topViewController.lst_navigationBar setHidden:lst_navigationBarHidden];
    self.topViewController.fd_prefersNavigationBarHidden = !lst_navigationBarHidden;
}

- (NSDictionary<NSAttributedStringKey,id> *)lst_titleTextAttributes {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setLst_titleTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)lst_titleTextAttributes {
    objc_setAssociatedObject(self, @selector(lst_titleTextAttributes), lst_titleTextAttributes, OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.topViewController.lst_navigationItem.titleTextAttributes = lst_titleTextAttributes;
}

- (LSTNavigationBar *)lst_navigationBar {
    return self.topViewController.lst_navigationBar;
}

- (LSTNavigationItem *)lst_navigationItem {
    return self.topViewController.lst_navigationItem;
}

@end

