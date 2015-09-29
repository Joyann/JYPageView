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
 *  JYPageView的初始化方法，直接将photoNames传入.该方法默认不自动播放.
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
@property (nonatomic, assign) BOOL automaticPlay;
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
@property (nonatomic, assign) CGFloat duration;

/**
 *  设置pageControl是否可用.
 *  默认为NO, pageControl不可用.
 *  当设置为YES的时候可以点击pageControl, scrollView会根据pageControl移动的相应的位置.
 */

/**
 *  设置pageControl选中的图片.
 *  @warning 设置这个属性也要设置pageControlImage属性.
 */
@property (nonatomic, strong) UIImage *currentPageImage;

/**
 *  设置pageControl默认的图片.
 *  @warning 设置这个属性也要设置currentPageImage属性.
 */
@property (nonatomic, strong) UIImage *pageConrolImage;

/**
 *  设置pageControl默认颜色.
 */
@property (nonatomic, strong) UIColor *pageControlTintColor;

/**
 *  设置pageControl选中的颜色.
 */
@property (nonatomic, strong) UIColor *currentPageControlTintColor;

/**
 *  当只有一张图片的时候，设置是否隐藏pageControl.
 *  默认为YES，当有一张图片的时候，自动隐藏pageControl.
 */
@property (nonatomic, assign) BOOL hidePageControlForSingleImage;

/**
 *  获得当前有多少个page, 也等于当前图片数.
 */
@property (nonatomic, assign) NSInteger numberOfPages;

/**
 *  获得当前page的index.
 */
@property (nonatomic, assign) NSInteger currentPageIndex;

@property (nonatomic, copy) void (^pageViewDidScrollWithIndex) (NSInteger index);


@end
