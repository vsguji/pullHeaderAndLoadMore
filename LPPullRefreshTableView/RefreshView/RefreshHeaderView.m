//
//  RefreshHeaderView.m
//  LPPullRefreshTableView
//
//  Created by lipeng on 2018/4/14.
//  Copyright © 2018年 lipeng. All rights reserved.
//

#import "RefreshHeaderView.h"

#define  TextColor [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define  Duration 0.18f

@interface RefreshHeaderView()
- (void)setState:(LPHeaderRefreshState)state;
@end

@implementation RefreshHeaderView

- (instancetype)initWithFrame:(CGRect)frame arrowImageName:(NSString *)arrow textColor:(UIColor *)textColor {
    if (self == [super initWithFrame:frame]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.f, self.frame.size.width, 20.f)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.font = [UIFont systemFontOfSize:12.0];
        label.textColor = textColor;
        label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
        label.shadowOffset = CGSizeMake(0.0, 1.0f);
        label.textAlignment  = NSTextAlignmentCenter;
        [self addSubview:label];
        _lastUpdatedLabel = label;
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.f, self.frame.size.width, 20.f)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.font = [UIFont boldSystemFontOfSize:13.0f];
        label.textColor = textColor;
        label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
        label.shadowOffset = CGSizeMake(0.0f, 1.0f);
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        _statusLabel = label;
        
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(25.0f, frame.size.height - 65.0f, 30.0f, 55.0f);
        layer.contentsGravity = kCAGravityResizeAspect;
        layer.contents = (id)[UIImage imageNamed:arrow].CGImage;
#if __IPHONE_OS_VERSION_MAX_ALLOWED
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            layer.contentsScale = [[UIScreen mainScreen] scale];
        }
#endif
        [[self layer] addSublayer:layer];
        _arrowImage = layer;
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        view.frame = CGRectMake(25.0f, frame.size.height - 38.0f, 20.f, 20.f);
        [self addSubview:view];
        _activityView = view;
        [self setState:LPHeaderNormal];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame arrowImageName:@"blueArrow.png" textColor:TextColor];
}

#pragma mark - 

- (void)refreshLashUpdatedDate {
    if ([self.delegate respondsToSelector:@selector(pullRefreshTableViewHeaderDataSourceLastUpdated:)]) {
        NSDate *date = [self.delegate pullRefreshTableViewHeaderDataSourceLastUpdated:self];
        [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        _lastUpdatedLabel.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"Last Updated", @"Last Updated"),[dateFormatter stringFromDate:date]];
        [[NSUserDefaults standardUserDefaults] setObject:_lastUpdatedLabel.text forKey:@"LPullRefreshView_lastUpdate"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
        _lastUpdatedLabel.text = nil;
    }
}

- (void)setState:(LPHeaderRefreshState)state {
    switch (state) {
        case LPHeaderDropPulling:
            _statusLabel.text = NSLocalizedString(@"to refresh...", @"refreshPullState");
            [CATransaction begin];
            [CATransaction setAnimationDuration:Duration];
            _arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.f, 0.0f, 0.0f, 1.0f);
            [CATransaction commit];
            break;
         case LPHeaderNormal:
            if (_state == LPullRefreshPulling) {
                [CATransaction begin];
                [CATransaction setAnimationDuration:Duration];
                _arrowImage.transform = CATransform3DIdentity;
                [CATransaction commit];
            }
            _statusLabel.text = NSLocalizedString(@"pull down...", @"refreshPullNormal");
            [_activityView stopAnimating];
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            _arrowImage.hidden = NO;
            _arrowImage.transform = CATransform3DIdentity;
            [CATransaction commit];
            [self refreshLashUpdatedDate];
            break;
         case LPHeaderDropRefreshLoading:
            _statusLabel.text = NSLocalizedString(@"pull loading...", @"refreshLoading");
            [_activityView startAnimating];
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            _arrowImage.hidden = YES;
            [CATransaction commit];
            break;
        default:
            break;
    }
    _state = state;
}

#pragma mark - scrollview method

- (void)pullRefreshScrollViewDidScroll:(UIScrollView *)scrollView {
    if (_state == LPHeaderDropRefreshLoading) {
        CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
        offset = MIN(offset, 60);
        scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
    }
    else if (scrollView.isDragging){
        BOOL _loading = NO;
        if ([self.delegate  respondsToSelector:@selector(pullRefreshTableHeaderDataSourceIsLoading:)]) {
            _loading = [self.delegate pullRefreshTableHeaderDataSourceIsLoading:self];
        }
        if (_state == LPHeaderDropPulling && scrollView.contentOffset.y > -65.0f
            && scrollView.contentOffset.y < 0.0f && !_loading) {
            [self setState:LPHeaderNormal];
        }
        else if (_state == LPHeaderNormal && scrollView.contentOffset.y < - 65
                 && !_loading) {
            [self setState:LPHeaderDropPulling];
        }
        
        if (scrollView.contentInset.top != 0) {
            scrollView.contentInset = UIEdgeInsetsZero;
        }
    }
}

- (void)pullRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
    BOOL _loading = NO;
    if ([self.delegate respondsToSelector:@selector(pullRefreshTableHeaderDataSourceIsLoading:)]) {
        _loading = [self.delegate pullRefreshTableHeaderDataSourceIsLoading:self];
    }
    if (scrollView.contentOffset.y <= -65 && !_loading) {
        if ([self.delegate respondsToSelector:@selector(pullRefreshTableHeaderViewDidTriggerRefresh:)]) {
            [self.delegate pullRefreshTableHeaderViewDidTriggerRefresh:self];
        }
        [self setState:LPHeaderDropRefreshLoading];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        scrollView.contentInset = UIEdgeInsetsMake(60.f, 0.f, 0.f, 0.f);
        [UIView commitAnimations];
    }
    
}

- (void)pullRefreshScrollViewDataSouceDidFinished:(UIScrollView *)scrollView {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [scrollView setContentInset:UIEdgeInsetsZero];
    [UIView commitAnimations];
    [self setState:LPHeaderNormal];
    // lp 修复首次下拉,位置重置
    if (scrollView.contentInset.top != 0) {
        scrollView.contentInset = UIEdgeInsetsZero;
    }
}

#pragma mark - refreshView update

- (void)pullRefreshScrollViewDataSourceStartManualLoading:(UIScrollView *)scrollView {
    [UIView animateWithDuration:0.3 animations:^{
        scrollView.contentInset = UIEdgeInsetsMake(60.f, 0.f, 0.f, 0.f);
        scrollView.contentOffset = CGPointMake(0, -60.f);
    }];
    
    if ([self.delegate respondsToSelector:@selector(pullRefreshTableHeaderViewDidTriggerRefresh:)]) {
        [self.delegate pullRefreshTableHeaderViewDidTriggerRefresh:self];
    }
}
@end
