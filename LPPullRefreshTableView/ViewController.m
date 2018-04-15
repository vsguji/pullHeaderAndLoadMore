//
//  ViewController.m
//  LPPullRefreshTableView
//
//  Created by lipeng on 2018/4/14.
//  Copyright © 2018年 lipeng. All rights reserved.
//

#import "ViewController.h"
#import "RefreshHeaderView.h"
#import "RefreshFooterView.h"

@interface ViewController ()<LPullRefreshHeaderDelegate,LPRefreshFooterDelegate>
{
    RefreshHeaderView *_pullRefreshTableHeaderView;
    BOOL isRefreshing;
    int dataRows;
    
    RefreshFooterView *_upRefreTableFooterView;
    BOOL isLoadMoreing;
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    isRefreshing = NO;
    dataRows = 5;
    if (_pullRefreshTableHeaderView == nil) {
        _pullRefreshTableHeaderView = [[RefreshHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - (self.tableView.bounds.size.height+ [UIApplication sharedApplication].statusBarFrame.size.height), self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
        [self.tableView addSubview:_pullRefreshTableHeaderView];
        _pullRefreshTableHeaderView.delegate = self;
    }
    [_pullRefreshTableHeaderView refreshLashUpdatedDate];
    
    
    if (_upRefreTableFooterView == nil) {
        _upRefreTableFooterView = [[RefreshFooterView alloc] initWithFrame:CGRectMake(0.0f, self.tableView.frame.size.height, self.tableView.frame.size.width, self.tableView.bounds.size.height)];
        _upRefreTableFooterView.delegate = self;
        [self.tableView addSubview:_upRefreTableFooterView];
    }
    
    [self reloadData];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"identity"];
    
    NSString *tt = NSLocalizedString(@"Last Updated", @"refreshPullState");
    NSLog(@"上次更新时间 : %@",tt);
    
    
    NSString *tt1 = NSLocalizedString(@"to refresh...", @"refreshPullState");
    NSLog(@"释放刷新 : %@",tt1);
    
    NSString *tt2 = NSLocalizedString(@"pull down...", @"refreshPullState");
    NSLog(@"下拉刷新 : %@",tt2);
}

- (void)reloadData {
    [self.tableView reloadData];
    
    // 上拉刷新
    if (self.tableView.contentSize.height < self.tableView.frame.size.height) {
        _upRefreTableFooterView.frame = CGRectMake(0.f, self.tableView.frame.size.height, self.tableView.frame.size.width, self.tableView.frame.size.height);
    }
    else{
        _upRefreTableFooterView.frame = CGRectMake(0.f, self.tableView.contentSize.height, self.tableView.frame.size.width, self.tableView.frame.size.height);
    }
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_pullRefreshTableHeaderView pullRefreshScrollViewDidScroll:scrollView];
    [_upRefreTableFooterView footerScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_pullRefreshTableHeaderView pullRefreshScrollViewDidEndDragging:scrollView];
    [_upRefreTableFooterView footerScrollViewDidEndDragging:scrollView];
}


#pragma mark - LPullRefreshHeaderDelegate

- (void)pullRefreshTableHeaderViewDidTriggerRefresh:(RefreshHeaderView *)headerView {
    isRefreshing = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        sleep(3);
        self->dataRows +=5;
        dispatch_sync(dispatch_get_main_queue(), ^{
            self->isRefreshing = NO;
            [self reloadData];
            [self->_pullRefreshTableHeaderView pullRefreshScrollViewDataSouceDidFinished:self.tableView];
        });
    });
}

#pragma mark - LPRefreshFooterDelegate

- (void)footerDidTriggerRefresh:(RefreshFooterView *)footerView {
    if (self.tableView.contentSize.height < self.tableView.frame.size.height) {
        footerView.frame = CGRectMake(0.f, self.tableView.frame.size.height - 65.f, self.tableView.frame.size.width, 60.f);
    }
    else{
         footerView.frame = CGRectMake(0.f, self.tableView.contentSize.height - 65.f, self.tableView.frame.size.width, 60.f);
    }
   
    isLoadMoreing = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        sleep(3);
        self->dataRows += 2;
        dispatch_sync(dispatch_get_main_queue(), ^{
            self->isLoadMoreing = NO;
            [self reloadData];
            [self->_upRefreTableFooterView footerScrollViewDataSourceDidFinishedLoading:self.tableView];
        });
    });
}


- (NSDate *)pullRefreshTableViewHeaderDataSourceLastUpdated:(RefreshHeaderView *)headerView {
    return [NSDate date];
}

- (BOOL)pullRefreshTableHeaderDataSourceIsLoading:(RefreshHeaderView *)headerView {
    return isRefreshing;
}

- (BOOL)footerDataSourceIsLoading:(RefreshFooterView *)footerView {
    return isLoadMoreing;
}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identity"];
    cell.textLabel.text = [NSString stringWithFormat:@"cell:%ld",indexPath.row];
    return cell;
}


@end
