//
//  MenuView.m
//  AnimationMenuView
//
//  Created by 许向亮 on 2019/5/5.
//  Copyright © 2019 meituan. All rights reserved.
//

#import "MenuView.h"

@interface MenuView()

@property (nonatomic, strong) UIView *firstLine;
@property (nonatomic, strong) UIView *secondLine;
@property (nonatomic, strong) UIView *thirdLine;

@end

/**
 设计师给的描述：
    2秒一个周期，最顶上的线旋转角度和位移大于第二根线，但延迟100ms，以造成掀起感
 
 动画原型设计工具导出的数据：
 Utils.interval 2,->
    Line1.animate
        y: -5, rotation: -12
        options:
            time: .3
            delay: .1
    Line2.animate
        y: 4, rotation: -6
        options:
            time: .3
 
 Utils.delay .5,->
    Line1.animate
        y: 0, rotation: 0
        options:
            curve: "spring(120,10,0)" // 这三个值对应着：力度 stiffness 、摩擦系数 damping、速率 initialVelocity
            time: .3
            delay: .1
    Line2.animate
        y: 7, rotation: 0
        options:
            curve: "spring(120,10,0)"
            time: .3
 
 */
@implementation MenuView

- (instancetype)init {
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, 44, 44);
        [self setupUI];
        [self addObserver];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupUI {
    self.firstLine = [[UIView alloc] initWithFrame:CGRectMake(0, 14, 24, 1.5)];
    self.secondLine = [[UIView alloc] initWithFrame:CGRectMake(0, 21, 24, 1.5)];
    self.thirdLine = [[UIView alloc] initWithFrame:CGRectMake(0, 28, 24, 1.5)];
    
    self.firstLine.layer.allowsEdgeAntialiasing = YES;
    self.secondLine.layer.allowsEdgeAntialiasing = YES;
    self.thirdLine.layer.allowsEdgeAntialiasing = YES;
    self.firstLine.backgroundColor = [UIColor grayColor];
    self.secondLine.backgroundColor = [UIColor grayColor];
    self.thirdLine.backgroundColor = [UIColor grayColor];
    
    [self addSubview:self.firstLine];
    [self addSubview:self.secondLine];
    [self addSubview:self.thirdLine];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchAction)];
    [self addGestureRecognizer:tap];
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startAnimatingIfNeed)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)touchAction {
    if (self.didTouchCallback) {
        self.didTouchCallback();
    }
}

- (void)startAnimatingIfNeed {
    if (self.isAnimating) {
        [self stopAnimating];
        [self startAnimating];
    }
}

- (void)startAnimating {
    if (!self.isAnimating) {
        [self addAnimations];
    }
}

/**
 stiffness: 刚度系数(劲度系数/弹性系数)，刚度系数越大，形变产生的力就越大，运动越快
 
 damping: 阻尼系数，阻止弹簧伸缩的系数，阻尼系数越大，停止越快
 
 initialVelocity: 初始速率，动画视图的初始速度大小
 
 settlingDuration: 结算时间，返回弹簧动画到停止时的估算时间，根据当前的动画参数估算，通常弹簧动画的时间使用结算时间比较准确
 
 注意：根据动画的实际效果：
 代码实现的动画总时长缩短 0.2 秒（从 2 秒变 1.8 秒）；
 每条线的动画开始时间 beginTime 提前 0.3 秒；
 stiffness、damping 没有改变
 */
- (void)addAnimations {
    if (@available(iOS 9.0, *)) {
        // 第一条线
        // 设置锚点
        CGPoint firstAnchor = self.firstLine.layer.anchorPoint;
        self.firstLine.layer.anchorPoint = CGPointMake(0, 1);
        self.firstLine.layer.position = CGPointMake(self.firstLine.layer.position.x + self.firstLine.layer.bounds.size.width * (self.firstLine.layer.anchorPoint.x - firstAnchor.x), self.firstLine.layer.position.y + self.firstLine.layer.bounds.size.height * (self.firstLine.layer.anchorPoint.y - firstAnchor.y));
        
        CASpringAnimation *firstBeginPosition = [CASpringAnimation animationWithKeyPath:@"position.y"];
        firstBeginPosition.toValue = @(self.firstLine.layer.position.y - 5);
        firstBeginPosition.beginTime = 0.1;
        firstBeginPosition.removedOnCompletion = NO;
        firstBeginPosition.fillMode = kCAFillModeForwards;
        
        CASpringAnimation *firstBeginRotation = [CASpringAnimation animationWithKeyPath:@"transform.rotation"];
        firstBeginRotation.toValue = @(-12 / 180.0 * M_PI);
        firstBeginRotation.beginTime = 0.1;
        firstBeginRotation.removedOnCompletion = NO;
        firstBeginRotation.fillMode = kCAFillModeForwards;
        
        CASpringAnimation *firstEndPosition = [CASpringAnimation animationWithKeyPath:@"position.y"];
        firstEndPosition.toValue = @(self.firstLine.layer.position.y);
        firstEndPosition.beginTime = 0.7;
        firstEndPosition.stiffness = 120;
        firstEndPosition.damping = 10;
        
        CASpringAnimation *firstEndRotation = [CASpringAnimation animationWithKeyPath:@"transform.rotation"];
        firstEndRotation.toValue = @(0 / 180.0 * M_PI);
        firstEndRotation.beginTime = 0.7;
        firstEndRotation.stiffness = 120;
        firstEndRotation.damping = 10;
        
        CAAnimationGroup *firstLineGroup = [CAAnimationGroup animation];
        firstLineGroup.animations = @[firstBeginPosition, firstBeginRotation, firstEndPosition, firstEndRotation];
        firstLineGroup.duration = 1.8;
        firstLineGroup.repeatCount = INFINITY;
        [self.firstLine.layer addAnimation:firstLineGroup forKey:nil];
        
        // 第二条线
        // 设置锚点
        CGPoint secondAnchor = self.secondLine.layer.anchorPoint;
        self.secondLine.layer.anchorPoint = CGPointMake(0, 1);
        self.secondLine.layer.position = CGPointMake(self.secondLine.layer.position.x + self.secondLine.layer.bounds.size.width * (self.secondLine.layer.anchorPoint.x - secondAnchor.x), self.secondLine.layer.position.y + self.secondLine.layer.bounds.size.height * (self.secondLine.layer.anchorPoint.y - secondAnchor.y));
        
        CASpringAnimation *secondBeginPosition = [CASpringAnimation animationWithKeyPath:@"position.y"];
        secondBeginPosition.toValue = @(self.secondLine.layer.position.y - 2);
        secondBeginPosition.beginTime = 0.0;
        secondBeginPosition.removedOnCompletion = NO;
        secondBeginPosition.fillMode = kCAFillModeForwards;
        
        CASpringAnimation *secondBeginRotation = [CASpringAnimation animationWithKeyPath:@"transform.rotation"];
        secondBeginRotation.toValue = @(-6 / 180.0 * M_PI);
        secondBeginRotation.beginTime = 0.0;
        secondBeginRotation.removedOnCompletion = NO;
        secondBeginRotation.fillMode = kCAFillModeForwards;
        
        CASpringAnimation *secondEndPosition = [CASpringAnimation animationWithKeyPath:@"position.y"];
        secondEndPosition.toValue = @(self.secondLine.layer.position.y);
        secondEndPosition.beginTime = 0.6;
        secondEndPosition.stiffness = 120;
        secondEndPosition.damping = 10;
        
        CASpringAnimation *secondEndRotation = [CASpringAnimation animationWithKeyPath:@"transform.rotation"];
        secondEndRotation.toValue = @(0 / 180.0 * M_PI);
        secondEndRotation.beginTime = 0.6;
        secondEndRotation.stiffness = 120;
        secondEndRotation.damping = 10;
        
        CAAnimationGroup *secondLineGroup = [CAAnimationGroup animation];
        secondLineGroup.animations = @[secondBeginPosition, secondBeginRotation, secondEndPosition, secondEndRotation];
        secondLineGroup.duration = 1.8;
        secondLineGroup.repeatCount = INFINITY;
        [self.secondLine.layer addAnimation:secondLineGroup forKey:nil];
        self.isAnimating = YES;
    }
}

- (void)stopAnimating {
    [self.firstLine.layer removeAllAnimations];
    [self.secondLine.layer removeAllAnimations];
    self.isAnimating = NO;
}

@end
