//
//  Pie.m
//  Pie
//
//  Created by Haibo Tang on 12-8-14.
//  Copyright (c) 2012年 Haibo Tang. All rights reserved.
//

#import "Pie.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

#define kAcceleration 20

@interface PieDataModel : NSObject{
    NSString *_title;
    UIColor *_color;
    CGFloat _startRadian;
    CGFloat _endRadian;
    CGFloat _persent;
}
@property (nonatomic, retain)NSString *title;
@property (nonatomic, retain)UIColor *color;
@property (nonatomic, assign)CGFloat startRadian;
@property (nonatomic, assign)CGFloat endRadian;
@property (nonatomic, assign)CGFloat persent;
@end

@implementation PieDataModel
@synthesize title = _title;
@synthesize color = _color;
@synthesize startRadian = _startRadian;
@synthesize endRadian = _endRadian;
@synthesize persent = _persent;

- (void)dealloc{
    [_title release];
    [_color release];
    
    [super dealloc];
}

@end


@interface Pie(){
    UIPanGestureRecognizer *_panGR;
    CGPoint _prePoint;
    CGPoint _curPoint;
    
    NSMutableArray *_datas;
    CGFloat _rotaionRadian;
    CGPoint _90Pt;
    
    UILabel *_titleLabel;
    CGFloat _deltaRadian;
    NSTimeInterval _lastTime;
    NSTimeInterval _deltaTime;
}
@property (nonatomic, retain)UIPanGestureRecognizer *panGR;
@property (nonatomic, retain)NSMutableArray *datas;
@property (nonatomic, retain)UILabel *titleLabel;

- (CGFloat)radianForPoint1:(CGPoint)point1 point2:(CGPoint)point2;
@end

@implementation Pie

- (id)initWithCenter:(CGPoint)center radius:(CGFloat)radius{
    self = [self initWithFrame:CGRectMake(0, 0, radius*2, radius*2)];
    self.center = center;
    if (nil!=self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self titleLabel];
        [self panGR];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] setFill];
    CGContextFillEllipseInRect(context, self.bounds);
    
    NSInteger num = [self.dataSource numOfPie];
    if (self.datas.count!=num &&
        ([self.dataSource respondsToSelector:@selector(colorForIndex:)] ||
         [self.dataSource respondsToSelector:@selector(persentForIndex:)] ||
         [self.dataSource respondsToSelector:@selector(titleForIndex:)])) {
            CGFloat curRadian = 0;
            for (int i=0; i<num; i++) {
                PieDataModel *model = [[PieDataModel alloc] init];
                model.color = [self.dataSource colorForIndex:i];
                model.title = [self.dataSource titleForIndex:i];
                model.startRadian = curRadian;
                model.endRadian = curRadian+(2*M_PI)*[self.dataSource persentForIndex:i];
                [self.datas addObject:model];
                [model release];
                
                curRadian = model.endRadian;
            }
    }
    
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    for (PieDataModel *model in self.datas) {
        CGContextMoveToPoint(context, center.x, center.y);
        [model.color setFill];
        CGContextAddArc(context, center.x, center.y,
                        CGRectGetWidth(self.bounds)/2,
                        model.startRadian,
                        model.endRadian,
                        0);
        CGContextClosePath(context);
        CGContextFillPath(context);
    }
    
    if (ABS(_90Pt.x)<0.00001 && ABS(_90Pt.y)<0.0001) {
        CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        _90Pt = CGPointMake(cosf(-M_PI_2)*160+center.x, -sinf(-M_PI_2)*160+center.y);
        _90Pt = [self.superview convertPoint:_90Pt fromView:self];
    }
    //debug
    CGPoint startPt = CGPointZero;
    [[UIColor blackColor] setFill];
    for (PieDataModel *model in self.datas) {
        startPt = CGPointMake(cosf((model.startRadian+model.endRadian)/2)*160+center.x,
                              -sinf(-(model.startRadian+model.endRadian)/2)*160+center.y);
        CGContextFillEllipseInRect(context, CGRectMake(startPt.x-4, startPt.y-4, 8, 8));
    }
}


#pragma mark - action
- (void)onPanGR:(UIPanGestureRecognizer *)panGR{
    if (UIGestureRecognizerStateBegan == panGR.state) {
        _prePoint = [panGR locationInView:self.superview];
        _curPoint = [panGR locationInView:self.superview];
        
        _lastTime = [[NSDate date] timeIntervalSince1970];
    }else if (UIGestureRecognizerStateChanged == panGR.state) {
        NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
        _deltaTime = curTime - _lastTime;
        
        _curPoint = [panGR locationInView:self.superview];
        _deltaRadian = [self radianForPoint1:_prePoint point2:_curPoint];
        _rotaionRadian += _deltaRadian;
        [self setTransform:CGAffineTransformMakeRotation(_rotaionRadian)];
        NSLog(@"pre:%@ cur:%@ angle:%f", NSStringFromCGPoint(_prePoint), NSStringFromCGPoint(_curPoint), _deltaRadian*180/3.1415926);
        
        _prePoint = _curPoint;
        _lastTime = curTime;
    }else if (UIGestureRecognizerStateEnded == panGR.state){
        CGFloat v = _deltaRadian/_deltaTime;
        CGFloat interval = ABS(v/kAcceleration);
        CGFloat deltaRadian = v*interval/2;
        NSLog(@"v:%f interval:%f deltaRadian:%f", v, interval, deltaRadian);
//        CGFloat deltaRadian = -4*M_PI;
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.delegate = self;
        [animation setDuration:2];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        NSMutableArray *values =[NSMutableArray array];
        [values addObject:[NSNumber numberWithFloat:_rotaionRadian]];
        
        if (deltaRadian>0) {
            CGFloat tmp = _rotaionRadian;
            while (deltaRadian>0) {
                if (deltaRadian>=M_PI_4) {
                    tmp += M_PI_4;
                    [values addObject:[NSNumber numberWithFloat:tmp]];
                }else{
                    tmp += deltaRadian;
                    [values addObject:[NSNumber numberWithFloat:tmp]];
                }
                deltaRadian -= M_PI_4;
            }
        }else{
            CGFloat tmpRadian = _rotaionRadian;
            while (deltaRadian<0) {
                if (deltaRadian<=-M_PI_4) {
                    tmpRadian -= M_PI_4;
                    [values addObject:[NSNumber numberWithFloat:tmpRadian]];
                }else{
                    tmpRadian += deltaRadian;
                    [values addObject:[NSNumber numberWithFloat:tmpRadian]];
                }
                deltaRadian += M_PI_4;
            }
        }
        
        [animation setValues:values];
        animation.removedOnCompletion = YES;
        [self.layer addAnimation:animation forKey:@"rotate"];
        _rotaionRadian += v*interval/2;
    }
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self setTransform:CGAffineTransformMakeRotation(_rotaionRadian)];
    
    NSInteger count = (M_PI_2-_rotaionRadian)/(2*M_PI);
    CGFloat radian = M_PI_2-_rotaionRadian - count*2*M_PI;
    if (radian<0) {
        radian += 2*M_PI;
    }
    NSLog(@"三角指向%f", 90-radian*180/M_PI);

    CGPoint startPt = CGPointZero;
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    for (PieDataModel *model in self.datas) {
        if (model.startRadian<=radian &&
            model.endRadian>radian) {
            startPt = CGPointMake(cosf((model.startRadian+model.endRadian)/2)*160+center.x,
                                  -sinf(-(model.startRadian+model.endRadian)/2)*160+center.y);
            startPt = [self.superview convertPoint:startPt fromView:self];
            CGFloat rotainRadian = [self radianForPoint1:startPt point2:_90Pt];
            _rotaionRadian += rotainRadian;

            [UIView animateWithDuration:0.2
                             animations:^{
                                 [self setTransform:CGAffineTransformMakeRotation(_rotaionRadian)];
                             }];

            self.titleLabel.text = model.title;
            break;
        }
    }
}

#pragma mark - private
- (CGFloat)radianForPoint1:(CGPoint)point1 point2:(CGPoint)point2{
    CGPoint v1 = CGPointMake(point1.x-self.center.x, point1.y-self.center.y);
    CGPoint v2 = CGPointMake(point2.x-self.center.x, point2.y-self.center.y);
    
    if ((point1.x==0 || point1.y==0) &&
        (point2.x==0 || point2.y==0)) {
        return 0;
    }
    
    CGFloat cos = (v1.x*v2.x+v1.y*v2.y)/(sqrt(powf(v1.x, 2)+powf(v1.y, 2)) * sqrt(powf(v2.x, 2)+powf(v2.y, 2)));
    
    CGFloat radian = acosf(cos);
    CGFloat cross = v1.x*v2.y-v2.x*v1.y;
    if (cross<0) {
        radian = -radian;
    }
    return radian;
}

#pragma mark - getter/setter
@synthesize panGR = _panGR;
@synthesize dataSource = _dataSource;
@synthesize datas = _datas;
@synthesize titleLabel = _titleLabel;

- (void)dealloc{
    [_datas release];
    [_panGR release];
    [_titleLabel release];
    [super dealloc];
}

- (UIPanGestureRecognizer *)panGR{
    if (nil==_panGR) {
        _panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGR:)];
        [self addGestureRecognizer:_panGR];
    }
    return _panGR;
}

- (NSMutableArray *)datas{
    if (nil==_datas) {
        _datas = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _datas;
}

- (UILabel *)titleLabel{
    if (nil==_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        [self addSubview:_titleLabel];
        _titleLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
    return _titleLabel;
}
@end
