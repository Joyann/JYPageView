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

    NSArray *photoNames = @[@"1", @"2", @"3", @"4", @"5"];
    JYPageView *pageView = [JYPageView pageViewWithPhotoNames:photoNames automaticPlay:YES];
    pageView.immediatelyRefreshPageControl = YES;
    pageView.frame = CGRectMake(50, 100, 300, 150);
    pageView.duration = 3.0;
    
    [self.view addSubview:pageView];
}

@end
