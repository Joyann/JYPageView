//
//  JYPageView.h
//  JYPageView
//
//  Created by joyann on 15/9/26.
//  Copyright (c) 2015年 Joyann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JYPageView : UIView
/**
 *  JYPageView的初始化方法，需要再设置photoNames属性。
 *
 *  @return 返回一个JYPageView的对象
 */
+ (instancetype)pageView;

/**
 *  JYPageView的初始化方法，直接将photoNames传入。
 *
 *  @param photoNames 图片名称的数组
 *  @param automatic 是否自动播放
 *
 *  @return 返回一个JYPageView的对象
 */
+ (instancetype)pageViewWithPhotoNames:(NSArray *)photoNames automaticPlay:(BOOL)automatic;

/**
 *  图片名称的数组.
 */
@property (nonatomic, strong) NSArray *photoNames;

/**
 *  用来判断是否需要自动播放.
 *  默认为NO，不进行自动播放.
 */
@property (nonatomic, assign) BOOL automaiticPlay;
/**
 *  用来判断当用户手指拖动超过图片的二分之一的时候，pageControl是否更新.
 *  默认为NO，当用户松开手的时候才更新pageControl.
 *  当设置为YES的时候则是只要超过图片二分之一就更新pageControl即使没有松开手.
 */
@property (nonatomic, assign) BOOL immediatelyRefreshPageControl;

/**
 *  设置图片播放间隔时间.
 *  默认为1.5秒.
 */
@property (nonatomic, assign) NSUInteger duration;

@end
