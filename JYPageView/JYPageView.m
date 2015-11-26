//
//  JYPageView.m
//  JYPageView
//
//  Created by joyann on 15/9/26.
//  Copyright (c) 2015年 Joyann. All rights reserved.
//

#import "JYPageView.h"

static const CGFloat kPageControlWidth  = 100;
static const CGFloat kPageControlHeight = 37;

@interface JYPageView () <UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIPageControl *pageControl;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL timerFlag; // 用来记录手势的标志,每次点击图片的时候应该修改的是这个值, 而不应该是用户的auto选择.

@end

@implementation JYPageView

- (void)dealloc
{
    // 在viewControlelr销毁的时候注销timer
    [self removeTimer];
}

+ (instancetype)pageView
{
    JYPageView *pageView = [[JYPageView alloc] init];
    
    return pageView;
}

+ (instancetype)pageViewWithPhotoNames:(NSArray *)photoNames automaticPlay:(BOOL)automatic
{
    JYPageView *pageView = [[JYPageView alloc] init];
    
    pageView.photoNames = photoNames;
    pageView.automaticPlay = automatic;
    
    return pageView;
}

+ (instancetype)pageIntroViewWithPhotoNames:(NSArray *)photoNames
{
    JYPageView *introView = [self pageViewWithPhotoNames:photoNames automaticPlay:NO];
    introView.frame = [UIScreen mainScreen].bounds;
    return introView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self addSubviews];
        
        [self initSetUp];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initSetUp];
}

- (void)initSetUp
{
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    
    self.pageControl.hidesForSinglePage = YES;
    
    self.duration = 1.5;
    self.automaticPlay = NO;
}

- (void)addSubviews
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    [self addSubview:pageControl];
    self.pageControl = pageControl;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 重新设置scrollView的位置和大小
    self.scrollView.frame = self.bounds;
    
    // 重新设置pageControl的位置和大小
    CGFloat width = kPageControlWidth;
    CGFloat height = kPageControlHeight;
    CGFloat x = self.bounds.size.width / 2 - width / 2;
    CGFloat y = self.bounds.size.height - height;
    self.pageControl.frame = CGRectMake(x, y, width, height);
    
    // 重新设置各个控件的frame，然后再加上图片。默认layoutSubviews方法在setPhotoNames:方法后执行，所以会导致不正确的显示。这里是先执行layoutSubviews中的方法，再执行setPhotoNames:方法。
    [self setPhotoNames:self.photoNames];
}

#pragma mark - getter methods
- (NSInteger)numberOfPages
{
    return self.pageControl.numberOfPages;
}

- (NSInteger)currentPageIndex
{
    return self.pageControl.currentPage;
}

#pragma mark - setter methods

- (void)setPageControlTintColor:(UIColor *)pageControlTintColor
{
    self.pageControl.pageIndicatorTintColor = pageControlTintColor;
}

- (void)setCurrentPageControlTintColor:(UIColor *)currentPageControlTintColor
{
    self.pageControl.currentPageIndicatorTintColor = currentPageControlTintColor;
}

- (void)setHidePageControlForSingleImage:(BOOL)hidePageControlForSingleImage
{
    self.pageControl.hidesForSinglePage = hidePageControlForSingleImage;
}

- (void)setPhotoNames:(NSArray *)photoNames
{
    _photoNames = photoNames;
    
    // 移除之前ImageView
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // 将图片加入到scrollView中
    for (int i = 0; i < photoNames.count; i++) {
        UIImage *image = [UIImage imageNamed:photoNames[i]];
        CGRect imageRect = CGRectMake(i * self.scrollView.bounds.size.width, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageRect];
//        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.image = image;
        
        [self.scrollView addSubview:imageView];
    }
    
    // 因为contentSize会随着photoNames改变而改变，所以不能再初始化方法或是awakeFromNib中设置
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * self.photoNames.count, 0);
    
    self.pageControl.numberOfPages = self.photoNames.count;
    self.pageControl.currentPage = 0;
}

- (void)setAutomaticPlay:(BOOL)automaticPlay
{
    _automaticPlay = automaticPlay;
    
    self.timerFlag = YES;
}

- (void)setTimerFlag:(BOOL)timerFlag
{
    _timerFlag = timerFlag;
    
    if (_timerFlag) {
        [self addTimerWithDuration:self.duration];
    } else {
        [self removeTimer];
        self.timer = nil;
    }
}

- (void)setDuration:(CGFloat)duration
{
    _duration = duration;
    if (self.automaticPlay) {
        [self addTimerWithDuration:duration];
    }
}

// KVC 修改当前pageControl的图片
- (void)setCurrentPageImage:(UIImage *)currentPageImage
{
    [self.pageControl setValue:currentPageImage forKeyPath:@"_currentPageImage"];
}

// KVC 修改pageControl的图片
- (void)setPageConrolImage:(UIImage *)pageConrolImage
{
    [self.pageControl setValue:pageConrolImage forKeyPath:@"_pageImage"];
}

#pragma mark - UIScrollViewDelegate

// 根据scrollView移动的距离计算是第几个page
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self setPageControlAccordingToScrollView:scrollView];
}

// 当用户手指拖动图片的时候，移除timer，关闭自动播放
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.timerFlag = NO;
}

/**
 *  scrollView停下来有三种情况：
 *  1. 没有经过减速就停止 -> scrollViewDidEndDragging:willDecelerate:
 *  2. 经过减速停止      -> scrollViewDidEndDecelerating:
 *  3. 通过setContentOffset:animated:改变offset然后停止 -> scrollViewDidEndScrollingAnimation:
 */

// 当用户手指离开图片，增加timer，开启自动播放
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{

    if (self.automaticPlay) {
        self.timerFlag = YES;
    }
    
//    if (!decelerate) {
//        self.pageViewDidScrollWithIndex(self.pageControl.currentPage);
//    }
}

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    self.pageViewDidScrollWithIndex(self.pageControl.currentPage);
//}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.pageViewDidScrollWithIndex(self.pageControl.currentPage);
}


#pragma mark - helper methods

- (void)addTimerWithDuration: (CGFloat)duration
{
    // 首先移除之前的timer
    [self removeTimer];
    // 增加timer自动播放图片
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow: duration];
    self.timer = [[NSTimer alloc] initWithFireDate:fireDate interval: duration target:self selector:@selector(playImages) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)removeTimer
{
    [self.timer invalidate];
}

- (void)playImages
{
    // 获取当前的page
    NSInteger currentPage = self.pageControl.currentPage;
    currentPage ++;
    // 当超出图片个数的时候，设置为0重新开始
    if (currentPage >= self.photoNames.count) {
        currentPage = 0;
    }
    
    CGPoint offset = CGPointMake(currentPage * self.scrollView.bounds.size.width, 0);
    [self.scrollView setContentOffset:offset animated:YES];
}

- (void)setPageControlAccordingToScrollView: (UIScrollView *)scrollView
{
    NSUInteger currentPage = 0;
    if (self.immediatelyRefreshPageControl) {
        currentPage = (NSInteger)(scrollView.contentOffset.x / self.scrollView.bounds.size.width + 0.5);
    } else {
        currentPage = scrollView.contentOffset.x / self.scrollView.bounds.size.width;        
    }
    self.pageControl.currentPage = currentPage;
}

@end
