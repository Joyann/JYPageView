//
//  JYPageViewController.m
//  JYPageView
//
//  Created by joyann on 15/9/26.
//  Copyright (c) 2015年 Joyann. All rights reserved.
//

#import "JYPageViewController.h"
#import "JYPageView.h"

@interface JYPageViewController ()

@end

@implementation JYPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor purpleColor];

    [self createIntroView];
//    [self createPageView];
}

- (void)createIntroView
{
    NSArray *photoNames = @[@"1", @"2", @"3", @"4", @"5"];
    JYPageView *introView = [JYPageView pageIntroViewWithPhotoNames:photoNames];
    [self.view addSubview:introView];
}

- (void)createPageView
{
    NSArray *photoNames = @[@"1", @"2", @"3", @"4", @"5"];
    JYPageView *pageView = [JYPageView pageView];
    pageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 150);
    pageView.immediatelyRefreshPageControl = YES;
    pageView.automaticPlay = YES;
    pageView.photoNames = photoNames;
    pageView.pageViewDidScrollWithIndex = ^(NSInteger index) {
        NSLog(@"%ld", index);
    };
    
    [self.view addSubview:pageView];

}

@end
