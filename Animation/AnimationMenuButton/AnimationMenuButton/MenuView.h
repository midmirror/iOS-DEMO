//
//  MenuView.h
//  AnimationMenuView
//
//  Created by 许向亮 on 2019/5/5.
//  Copyright © 2019 meituan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** 打开抽屉的菜单按钮 & 动画(iOS 9.0起才有动画) */
@interface MenuView : UIView

@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, copy) void (^didTouchCallback)(void);

- (void)startAnimatingIfNeed;
- (void)startAnimating;
- (void)stopAnimating;

@end

NS_ASSUME_NONNULL_END
