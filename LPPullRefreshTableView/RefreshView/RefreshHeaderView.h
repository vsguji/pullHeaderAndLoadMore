//
//  RefreshHeaderView.h
//  LPPullRefreshTableView
//
//  Created by lipeng on 2018/4/14.
//  Copyright © 2018年 lipeng. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RefreshMacros.h"
// 拉下刷新状态
typedef enum : NSUInteger {
    LPullRefreshPulling = 0,
    LPullRefreshNormal,
    LPullRefreshLoading,
} LPullRefreshState;

@class RefreshHeaderView;
@protocol LPullRefreshHeaderDelegate<NSObject>
- (void)pullRefreshTableHeaderViewDidTriggerRefresh:(RefreshHeaderView *)headerView;
- (BOOL)pullRefreshTableHeaderDataSourceIsLoading:(RefreshHeaderView *)headerView;
@optional
- (NSDate *)pullRefreshTableViewHeaderDataSourceLastUpdated:(RefreshHeaderView *)headerView;
@end

// 下拉刷新
@interface RefreshHeaderView : UIView
{
    LPHeaderRefreshState _state;
    UILabel *_lastUpdatedLabel;
    UILabel *_statusLabel;
    CALayer *_arrowImage;
    UIActivityIndicatorView *_activityView;
}

@property (nonatomic,weak) id <LPullRefreshHeaderDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame arrowImageName:(NSString *)arrow textColor:(UIColor *)textColor;

- (void)refreshLashUpdatedDate;
- (void)pullRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)pullRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)pullRefreshScrollViewDataSouceDidFinished:(UIScrollView *)scrollView;
- (void)pullRefreshScrollViewDataSourceStartManualLoading:(UIScrollView *)scrollView;

@end
