//
//  RefreshProtocol.h
//  LPPullRefreshTableView
//
//  Created by lipeng on 2018/4/14.
//  Copyright © 2018年 lipeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@protocol RefreshProtocol <NSObject>
- (instancetype)initWithFrame:(CGRect)frame arrowImageName:(NSString *)arrow textColor:(UIColor *)textColor;
@end
