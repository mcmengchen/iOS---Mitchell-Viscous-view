//
//  drawView.m
//  qq粘性图标
//
//  Created by MENGCHEN on 15/8/28.
//  Copyright (c) 2015年 Mcking. All rights reserved.
//

#import "drawView.h"

@interface drawView()

/**
 *
 */
@property(nonatomic,assign)CGPoint mainCenter;
/**
 *
 */
@property(nonatomic,weak)UIView * smallView;
/**
 *
 */
@property(nonatomic,weak)CAShapeLayer * shapLayer;
/**
 *
 */
@property(nonatomic,assign)BOOL isEnd;
@end
@implementation drawView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib{
    [self setUp];
    [self createSmallView];
    
}

-(CAShapeLayer *)shapLayer{
    if (!_shapLayer) {
        CAShapeLayer*layer = [CAShapeLayer layer];
        layer.fillColor = [UIColor redColor].CGColor;
        [self.superview.layer insertSublayer:layer atIndex:0];
        _shapLayer = layer;
    }
    return _shapLayer;
}

- (void)setUp{
    self.layer.cornerRadius = self.frame.size.width/2.0;
    UIPanGestureRecognizer*pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    
    
    
}

- (void)createSmallView{
    UIView *vi            = [[UIView alloc]initWithFrame:self.frame];
    vi.frame              = self.frame;
    _mainCenter           = self.center;
    vi.center             = self.center;
    vi.backgroundColor    = self.backgroundColor;
    vi.layer.cornerRadius = self.frame.size.width/2.0;
    [self.superview insertSubview:vi belowSubview:self];
    _smallView            = vi;
}
#pragma mark ------------------ 拖拽手势 ------------------
- (void)pan:(UIPanGestureRecognizer*)pan{
    //1、使大圆偏移
    CGPoint point = [pan translationInView:self];
    CGPoint center = self.center;
    center.x += point.x;
    center.y += point.y;
    self.center = center;
    [pan setTranslation:CGPointZero inView:self];
    
    //计算圆心距
    CGFloat distance =[self calculateDistanceToCenter:self];
    //防止由于distance为0 计算sin cos的值出bug
    NSLog(@"%f",distance);
    if (distance>0&&distance<=85) {

        CGFloat smallR = self.bounds.size.width*0.5-distance/10;
        _smallView.bounds = CGRectMake(0, 0, smallR*2, smallR*2);
        _smallView.layer.cornerRadius = smallR;
        //2、修改小圆半径
        UIBezierPath *path = [self calculatePathWithSmallView:_smallView WithBigView:self];
        self.shapLayer.path = path.CGPath;
    }else if (distance>85){
        
//        _smallView.center = self.center;
        [_smallView removeFromSuperview];
        [_shapLayer removeFromSuperlayer];
        
        
        NSMutableArray *arr = [NSMutableArray array];
        for (int i = 1 ; i<=8; i++) {
            NSString*str = [NSString stringWithFormat:@"%d",i];
            UIImage*img = [UIImage imageNamed:str];
            [arr addObject:img];
        }
        
        
        UIImageView*imageV= [[UIImageView alloc]initWithFrame:self.bounds];
        imageV.animationDuration = 1;
        imageV.animationImages = arr;
        imageV.animationRepeatCount = 1;
        [imageV startAnimating];
        [self addSubview:imageV];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removeFromSuperview];

        });
        
        
    }

}



#pragma mark ------------------ 计算圆心距 ------------------
- (CGFloat)calculateDistanceToCenter:(UIView*)view{
    CGFloat distanceX = self.center.x - _smallView.center.x;
    CGFloat distanceY = self.center.y - _smallView.center.y;
    CGFloat distance = sqrt(distanceX*distanceX+distanceY*distanceY);
    return distance;
}
#pragma mark ------------------ 计算贝塞尔曲线 ------------------
- (UIBezierPath*)calculatePathWithSmallView:(UIView*)smallView WithBigView:(UIView*)bigView{
    CGFloat distanceX = self.center.x - _smallView.center.x;
    CGFloat distanceY = self.center.y - _smallView.center.y;
    //圆心距
    CGFloat distance =  [self calculateDistanceToCenter:smallView];
    //θ角的sin值与cos值
    CGFloat sinθ = distanceX/distance;
    CGFloat cosθ = distanceY/distance;
    CGFloat y1 = _smallView.center.y;
    CGFloat x1 = _smallView.center.x;
    CGFloat r1 = _smallView.layer.cornerRadius;
    
    CGFloat y2 = self.center.y;
    CGFloat x2 = self.center.x;
    CGFloat r2 = self.layer.cornerRadius;
    
    //计算4个点
    CGPoint APoint = CGPointMake(x1-r1*cosθ, y1+r1*sinθ);
    CGPoint BPoint = CGPointMake(x1+r1*cosθ, y1 - r1*sinθ);
    CGPoint CPoint = CGPointMake(x2+r2*cosθ, y2-r2*sinθ);
    CGPoint DPoint = CGPointMake(x2-r2*cosθ,  y2 + r2*sinθ);
    //计算曲线的两个控制点
    CGPoint pointO = CGPointMake(APoint.x + distance * 0.5 * sinθ, APoint.y + distance * 0.5 * cosθ);
    CGPoint pointP = CGPointMake(BPoint.x + distance * 0.5 * sinθ, BPoint.y + distance * 0.5 * cosθ);
    //绘制贝塞尔曲线
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:APoint];
    [path addLineToPoint:BPoint];
    [path addQuadCurveToPoint:CPoint controlPoint:pointP];
    [path addLineToPoint:DPoint];
    [path addQuadCurveToPoint:APoint controlPoint:pointO];
    
    return path;
}
@end
