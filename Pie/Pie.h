//
//  Pie.h
//  Pie
//
//  Created by Haibo Tang on 12-8-14.
//  Copyright (c) 2012年 Haibo Tang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PieDataSource <NSObject>

- (NSInteger)numOfPie;
- (CGFloat)persentForIndex:(NSInteger)index;
- (UIColor *)colorForIndex:(NSInteger)index;
- (NSString *)titleForIndex:(NSInteger)index;
@end

@interface Pie : UIView{
    id<PieDataSource> _dataSource;
}
@property (nonatomic, assign)id<PieDataSource> dataSource;

- (id)initWithCenter:(CGPoint)center radius:(CGFloat)radius;
@end
