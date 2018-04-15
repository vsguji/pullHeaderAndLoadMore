//
//  RefreshFooterView.m
//  LPPullRefreshTableView
//
//  Created by lipeng on 2018/4/14.
//  Copyright © 2018年 lipeng. All rights reserved.
//

#import "RefreshFooterView.h"

#define  LPFooter  [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define  LPDuration 0.18f

@implementation RefreshFooterView

- (instancetype)initWithFrame:(CGRect)frame arrowImageName:(NSString *)arrow textColor:(UIColor *)textColor {
    if (self == [super initWithFrame:frame]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 65.f - 48.f , self.frame.size.width, 20.f)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.font = [UIFont boldSystemFontOfSize:13.f];
        label.textColor = textColor;
        label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
        label.shadowOffset = CGSizeMake(0.f, 1.0f);
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        _statusLabel = label;
        
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(25.0f, 0.f, 30.f, 55.f);
        layer.contentsGravity = kCAGravityResizeAspect;
        layer.contents = (id)[UIImage imageNamed:arrow].CGImage;
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            layer.contentsScale = [[UIScreen mainScreen] scale];
        }
#endif
        [[self layer] addSublayer:layer];
        _arrowImage = layer;
        
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        view.frame = CGRectMake(25.f, label.frame.origin.y, 20.f, 20.f);
        [self addSubview:view];
        _activityView = view;
        [self setState:LPFooterMoreNormal];
    }
   
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame arrowImageName:@"blueArrowLoadMore.png" textColor:LPFooter];
}

- (void)setState:(LPFooterRefreshState)state {
    switch (state) {
        case LPFooterMoreUpPulling:
            _statusLabel.text = NSLocalizedString(@"release to load more", @"to load more");
            [CATransaction begin];
            [CATransaction setAnimationDuration:LPDuration];
            _arrowImage.transform = CATransform3DMakeRotation((M_PI/180.0) * 180, 0.f, 0.f, 1.f);
            [CATransaction commit];
            break;
        case LPFooterMoreNormal:
            if (_state == LPFooterMoreUpPulling) {
                [CATransaction begin];
                [CATransaction setAnimationDuration:LPDuration];
                _arrowImage.transform = CATransform3DIdentity;
                [CATransaction commit];
            }
            _statusLabel.text = NSLocalizedString(@"up to load more", @"up to load more");
            [_activityView stopAnimating];
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            _arrowImage.hidden = NO;
            _arrowImage.transform = CATransform3DIdentity;
            [CATransaction commit];
            break;
        case LPFooterMoreUpLoding:
            _statusLabel.text = NSLocalizedString(@"loading more", @"loading more");
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

#pragma mark - scrollView method

- (void)footerScrollViewDidScroll:(UIScrollView *)scrollView {
    if (_state == LPFooterMoreUpLoding) {
       // CGFloat offset = MAX(scrollView.contentOffset.y, 0);
       // offset = MIN(offset, 60);
       // scrollView.contentInset = UIEdgeInsetsMake(offset, 0, 0.f, 0);
    }
    else if (scrollView.isDragging){
        BOOL _loading = NO;
        if ([self.delegate respondsToSelector:@selector(footerDataSourceIsLoading:)]) {
            _loading = [self.delegate footerDataSourceIsLoading:self];
        }
        if (_state == LPFooterMoreUpPulling && scrollView.contentOffset.y < (scrollView.contentSize.height - scrollView.bounds.size.height + 65) && scrollView.contentOffset.y > 0 && !_loading) {
            [self setState:LPFooterMoreNormal];
        }
        else if (_state == LPFooterMoreNormal && !_loading){
            if (scrollView.contentSize.height < scrollView.frame.size.height) {
                if (scrollView.contentOffset.y > (65.f)) {
                     [self setState:LPFooterMoreUpPulling];
                }
            }
            else if (scrollView.contentSize.height > scrollView.frame.size.height){
                if (scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height + 65)) {
                     [self setState:LPFooterMoreUpPulling];
                }
            }
        }
    }
}

- (void)footerScrollViewDidEndDragging:(UIScrollView *)scrollView {
    BOOL _loading = NO;
    if ([self.delegate respondsToSelector:@selector(footerDataSourceIsLoading:)]) {
        _loading = [self.delegate footerDataSourceIsLoading:self];
    }
    if (scrollView.contentOffset.y > ( 65) && !_loading) {
        if ([self.delegate respondsToSelector:@selector(footerDidTriggerRefresh:)]) {
            [self.delegate footerDidTriggerRefresh:self];
        }
        [self setState:LPFooterMoreUpLoding];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:0.2];
      //  scrollView.contentInset = UIEdgeInsetsMake(0.f, 0.f, 60.f, 0.f);
        [UIView commitAnimations];
    }
}


- (void)footerScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [scrollView setContentInset:UIEdgeInsetsZero];
    [UIView commitAnimations];
    [self setState:LPFooterMoreNormal];
   
    scrollView.contentInset = UIEdgeInsetsZero;

}


@end
