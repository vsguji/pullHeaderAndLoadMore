//
//  RefreshMacros.h
//  LPPullRefreshTableView
//
//  Created by lipeng on 2018/4/14.
//  Copyright © 2018年 lipeng. All rights reserved.
//

#ifndef RefreshMacros_h
#define RefreshMacros_h

// 下拉刷新
typedef enum : NSUInteger {
    LPHeaderDropPulling = 0,
    LPHeaderDropRefreshLoading,
    LPHeaderNormal,
} LPHeaderRefreshState;

// 上拉加载
typedef enum : NSUInteger {
    LPFooterMoreUpPulling = 0,
    LPFooterMoreUpLoding,
    LPFooterMoreNormal,
} LPFooterRefreshState;

#endif /* RefreshMacros_h */
