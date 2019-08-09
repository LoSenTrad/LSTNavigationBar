//
//  LSTNavigationBarContentView.m
//
//  Created by LoSenTrad on 2018/3/20.
//  Copyright © 2018年 LoSenTrad. All rights reserved.
//

#import "LSTNavigationBarContentView.h"

#define LSTBarContentViewDefaultFrame CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 44.0)

@interface LSTNavigationBarContentView()

@property (nonatomic, assign) CGFloat titleViewHeight;
@property (nonatomic, assign) CGFloat leftMargin;
@property (nonatomic, assign) CGFloat rightMargin;

@end

@implementation LSTNavigationBarContentView
-(BOOL)shouldAutorotate
{
    return [self.inputViewController shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return [self.inputViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.inputViewController preferredInterfaceOrientationForPresentation];
}

- (instancetype)init
{
    self = [super initWithFrame:LSTBarContentViewDefaultFrame];
    if (self) {
        
        _titleViewStyle = LSTNavigationBarTitleViewStyleDefault;
        
        [self lst_addSubviews];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self updateLeftBarButtonFrame];
    [self updateLeftBarItemsFrame];
    [self updateRightBarButtonFrame];
    [self updateRightBarItemsFrame];
    [self updateTitleFrame];
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if (![self.subviews containsObject:self.titleView]) {
        return;
    }
    
    CGFloat height = self.titleViewHeight > CGRectGetHeight(self.frame) ? CGRectGetHeight(self.frame) : self.titleViewHeight;
    CGFloat left = self.leftMargin;
    CGFloat right = self.rightMargin;
    if (self.titleViewStyle == LSTNavigationBarTitleViewStyleDefault) {
        CGFloat margin = MAX(self.leftMargin, self.rightMargin);
        left = right = margin;
    }
    [self removeConstraints:self.constraints];
    self.titleView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:left]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-right]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height]];
}

#pragma mark - private
- (void)lst_addSubviews
{
    [self lst_addTitleLabel];
}

- (void)lst_addTitleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.hidden = YES;
        _titleLabel.font = [UIFont boldSystemFontOfSize:17];
        _titleLabel.textColor = [UIColor darkTextColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
    }
}

- (void)updateTitleLabelFrame
{
    CGFloat margin = MAX(self.leftMargin, self.rightMargin) * 2;
    _titleLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame) - margin, CGRectGetHeight(self.frame));
    _titleLabel.center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2);
}

- (void)updateTitleFrame
{
    if (_titleView) {
        [self updateConstraintsIfNeeded];
    }
    else {
        [self updateTitleLabelFrame];
    }
}

- (void)removeAllLeftBarItems
{
    if ([self.subviews containsObject:_leftBarButton]) {
        [_leftBarButton removeFromSuperview];
    }
    if (_leftBarButton) {
        _leftBarButton = nil;
    }
    [_leftBarItems enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
}

- (void)removeAllRightBarItems
{
    if ([self.subviews containsObject:_rightBarButton]) {
        [_rightBarButton removeFromSuperview];
    }
    if (_rightBarButton) {
        _rightBarButton = nil;
    }
    [_rightBarItems enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
}

- (void)updateLeftBarButtonFrame
{
    CGRect frame = _leftBarButton.frame;
    frame.origin.x = 0.f;
    frame.size.height = frame.size.height > CGRectGetHeight(self.frame) ? CGRectGetHeight(self.frame) : frame.size.height;
    frame.origin.y = (CGRectGetHeight(self.frame) - frame.size.height) / 2;
    _leftBarButton.frame = frame;
}

- (void)updateLeftBarItemsFrame
{
    if (_leftBarItems.count > 0) {
        __block CGFloat lastItemWidth = 0.f;
        [_leftBarItems enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGRect frame = obj.frame;
            frame.origin.x = lastItemWidth;
            frame.size.height = frame.size.height > CGRectGetHeight(self.frame) ? CGRectGetHeight(self.frame) : frame.size.height;
            frame.origin.y = (CGRectGetHeight(self.frame) - frame.size.height) / 2;
            lastItemWidth += frame.size.width;
            obj.frame = frame;
        }];
    }
}

- (void)updateRightBarButtonFrame
{
    CGRect frame = _rightBarButton.frame;
    frame.origin.x = CGRectGetWidth(self.bounds) - frame.size.width;
    frame.size.height = frame.size.height > CGRectGetHeight(self.frame) ? CGRectGetHeight(self.frame) : frame.size.height;
    frame.origin.y = (CGRectGetHeight(self.frame) - frame.size.height) / 2;
    _rightBarButton.frame = frame;
}

- (void)updateRightBarItemsFrame
{
    if (_rightBarItems.count > 0) {
        __block CGFloat lastItemWidth = 0.f;
        [_rightBarItems enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGRect frame = obj.frame;
            frame.origin.x = CGRectGetWidth(self.frame) - frame.size.width - lastItemWidth;
            frame.size.height = frame.size.height > CGRectGetHeight(self.frame) ? CGRectGetHeight(self.frame) : frame.size.height;
            frame.origin.y = (CGRectGetHeight(self.frame) - frame.size.height) / 2;
            lastItemWidth = lastItemWidth + frame.size.width;
            obj.frame = frame;
        }];
    }
}

#pragma mark - getter & setter
- (void)setTitleViewStyle:(LSTNavigationBarTitleViewStyle)titleViewStyle
{
    _titleViewStyle = titleViewStyle;
    
    [self updateConstraintsIfNeeded];
}

- (void)setTitle:(NSString *)title
{
    _title = [title copy];
    _titleLabel.hidden = NO;
    _titleLabel.attributedText = [[NSAttributedString alloc] initWithString:title ?: @"" attributes:self.titleTextAttributes];
    
    if (title) {
        if ([self.subviews containsObject:_titleView]) {
            [_titleView removeFromSuperview];
        }
        if (_titleView) {
            _titleView = nil;
        }
        [self updateTitleLabelFrame];
    }
}

- (void)setTitleView:(UIView *)titleView
{
    [_titleView removeFromSuperview];
    _titleView = titleView;
    
    if (titleView) {
        _titleLabel.hidden = YES;
        self.titleViewHeight = titleView.frame.size.height;
        [self addSubview:_titleView];
        [self updateConstraintsIfNeeded];
    }
}

- (void)setTitleTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)titleTextAttributes
{
    _titleTextAttributes = [titleTextAttributes copy];
    
    if (self.title) {
        _titleLabel.attributedText = [[NSAttributedString alloc] initWithString:self.title attributes:titleTextAttributes];
    }
}

- (void)setLeftBarButton:(UIButton *)leftBarButton
{
    [_leftBarButton removeFromSuperview];
    _leftBarButton = leftBarButton;
    
    if (leftBarButton) {
        
        [_leftBarItems enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
        _leftBarItems = @[];
        
        CGRect frame = leftBarButton.frame;
        frame.origin.x = 0.f;
        frame.size.height = frame.size.height > CGRectGetHeight(self.frame) ? CGRectGetHeight(self.frame) : frame.size.height;
        frame.origin.y = (CGRectGetHeight(self.frame) - frame.size.height) / 2;
        _leftBarButton.frame = frame;
        
        [self addSubview:_leftBarButton];
    }
    [self updateTitleFrame];
}

- (void)setLeftBarItems:(NSArray<UIView *> *)leftBarItems
{
    [self removeAllLeftBarItems];
    _leftBarItems = [leftBarItems copy];
    
    if (leftBarItems.count > 0) {
        __block CGFloat lastItemWidth = 0.f;
        [leftBarItems enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGRect frame = obj.frame;
            frame.origin.x = lastItemWidth;
            frame.size.height = frame.size.height > CGRectGetHeight(self.frame) ? CGRectGetHeight(self.frame) : frame.size.height;
            frame.origin.y = (CGRectGetHeight(self.frame) - frame.size.height) / 2;
            lastItemWidth += frame.size.width;
            obj.frame = frame;
            [self addSubview:obj];
        }];
    }
    [self updateTitleFrame];
}

- (void)setRightBarButton:(UIButton *)rightBarButton
{
    [_rightBarButton removeFromSuperview];
    _rightBarButton = rightBarButton;
    
    if (rightBarButton) {
        
        [_rightBarItems enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
        _rightBarItems = @[];
        
        CGRect frame = rightBarButton.frame;
        frame.origin.x = CGRectGetWidth(self.bounds) - frame.size.width;
        frame.size.height = frame.size.height > CGRectGetHeight(self.frame) ? CGRectGetHeight(self.frame) : frame.size.height;
        frame.origin.y = (CGRectGetHeight(self.frame) - frame.size.height) / 2;
        _rightBarButton.frame = frame;
        [self addSubview:_rightBarButton];
    }
    [self updateTitleFrame];
}

- (void)setRightBarItems:(NSArray<UIView *> *)rightBarItems
{
    [self removeAllRightBarItems];
    _rightBarItems = [rightBarItems copy];
    
    if (rightBarItems.count > 0) {
        __block CGFloat lastItemWidth = 0.f;
        [rightBarItems enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGRect frame = obj.frame;
            frame.origin.x = CGRectGetWidth(self.frame) - frame.size.width - lastItemWidth;
            frame.size.height = frame.size.height > CGRectGetHeight(self.frame) ? CGRectGetHeight(self.frame) : frame.size.height;
            frame.origin.y = (CGRectGetHeight(self.frame) - frame.size.height) / 2;
            lastItemWidth += frame.size.width;
            obj.frame = frame;
            [self addSubview:obj];
        }];
    }
    [self updateTitleFrame];
}

- (CGFloat)leftMargin
{
    _leftMargin = 0.f;
    if (_leftBarButton) {
        _leftMargin = CGRectGetWidth(_leftBarButton.frame);
    }
    if (_leftBarItems.count > 0) {
        [_leftBarItems enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            _leftMargin += CGRectGetWidth(obj.frame);
        }];
    }
    return _leftMargin;
}

- (CGFloat)rightMargin
{
    _rightMargin = 0.f;
    if (_rightBarButton) {
        _rightMargin = CGRectGetWidth(_rightBarButton.frame);
    }
    if (_rightBarItems.count > 0) {
        [_rightBarItems enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            _rightMargin += CGRectGetWidth(obj.frame);
        }];
    }
    return _rightMargin;
}

@end
