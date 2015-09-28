//
//  JYPageView.m
//  JYPageView
//
//  Created by joyann on 15/9/26.
//  Copyright (c) 2015年 Joyann. All rights reserved.
//

#import "JYPageView.h"

@interface JYPageView () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation JYPageView

- (void)dealloc
{
    // 在viewControlelr销毁的时候注销timer
    [self removeTimer];
}

+ (instancetype)pageView
{
    JYPageView *pageView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] firstObject];
    
    pageView.automaiticPlay = NO;
    pageView.duration = 1.5; // 注意automaticiPlay和duration设置顺序，不可以反过来
    
    return pageView;
}

+ (instancetype)pageViewWithPhotoNames:(NSArray *)photoNames automaticPlay:(BOOL)automatic
{
    JYPageView *pageView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] firstObject];
    
    pageView.photoNames = photoNames;
    pageView.automaiticPlay = automatic;
    pageView.duration = 1.5; // 注意automaticiPlay和duration设置顺序，不可以反过来
    
    return pageView;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 重新设置scrollView的位置和大小
    self.scrollView.frame = self.bounds;
    
    // 重新设置pageControl的位置
    CGFloat width = self.pageControl.frame.size.width;
    CGFloat height = self.pageControl.frame.size.height;
    CGFloat x = self.bounds.size.width / 2 - width / 2;
    CGFloat y = self.bounds.size.height - height;
    self.pageControl.frame = CGRectMake(x, y, width, height);
    
    // 重新设置各个控件的frame，然后再加上图片。默认layoutSubviews方法在setPhotoNames:方法后执行，所以会导致不正确的显示。这里是先执行layoutSubviews中的方法，再执行setPhotoNames:方法。
    [self setPhotoNames:self.photoNames];
}

#pragma mark - setter methods

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

- (void)setAutomaiticPlay:(BOOL)automaiticPlay
{
    if (_automaiticPlay != automaiticPlay) {
        _automaiticPlay = automaiticPlay;
        if (_automaiticPlay) {
            [self addTimerWithDuration:self.duration];
        } else {
            [self removeTimer];
        }
    }
}

- (void)setDuration:(CGFloat)duration
{
    if (self.automaiticPlay) {
        [self addTimerWithDuration:duration];
    }
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
    self.automaiticPlay = NO;
}

// 当用户手指离开图片，增加timer，开启自动播放
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // 首先要判断是否是自动播放.如果不判断，那么会出现当设置不自动播放的时候，用户拖拽图片，松开手后会继续自动播放的bug.
    if (self.automaiticPlay) {
        self.automaiticPlay = YES;
    }
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
