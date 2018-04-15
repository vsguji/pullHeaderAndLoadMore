//
//  RefreshFooterView.h
//  LPPullRefreshTableView
//
//  Created by lipeng on 2018/4/14.
//  Copyright © 2018年 lipeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RefreshMacros.h"
#import "RefreshProtocol.h"

@class RefreshFooterView;
@protocol LPRefreshFooterDelegate <NSObject>
- (void)footerDidTriggerRefresh:(RefreshFooterView *)footerView;
- (BOOL)footerDataSourceIsLoading:(RefreshFooterView *)footerView;

@end

// 上提刷新
@interface RefreshFooterView : UIView
{
    LPFooterRefreshState _state;
    UILabel *_statusLabel;
    CALayer *_arrowImage;
    UIActivityIndicatorView *_activityView;
}
@property (nonatomic,weak) id <LPRefreshFooterDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame arrowImageName:(NSString *)arrow textColor:(UIColor *)textColor;

- (void)footerScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)footerScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)footerScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;


@end
