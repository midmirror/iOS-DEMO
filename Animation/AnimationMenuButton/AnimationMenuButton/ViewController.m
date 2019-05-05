//
//  ViewController.m
//  AnimationMenuButton
//
//  Created by 许向亮 on 2019/5/5.
//  Copyright © 2019 meituan. All rights reserved.
//

#import "ViewController.h"
#import "MenuView.h"

@interface ViewController ()

@property (nonatomic, strong) MenuView *menuView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.menuView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.menuView startAnimating];
}

- (MenuView *)menuView {
    if (!_menuView) {
        _menuView = [MenuView new];
//        @weakify(self);
        _menuView.didTouchCallback = ^{
//            @strongify(self);
        };
    }
    return _menuView;
}

@end
