//
//  PickerProgressView.h
//
//
//  Created by 张磊 on 14-11-14.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "PickerProgressView.h"

#import <QuartzCore/QuartzCore.h>


static const CGFloat kBorderWidth = 2.0f;


#pragma mark -
#pragma mark THProgressLayer

@interface THProgressLayer : CALayer
@property (nonatomic, strong) UIColor* progressTintColor;
@property (nonatomic, strong) UIColor* borderTintColor;
@property (nonatomic) CGFloat progress;
@end

@implementation THProgressLayer

@dynamic progressTintColor;
@dynamic borderTintColor;

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    return [key isEqualToString:@"progress"] ? YES : [super needsDisplayForKey:key];
}

- (void)drawInContext:(CGContextRef)context
{
    CGRect rect = CGRectInset(self.bounds, kBorderWidth, kBorderWidth);
    CGFloat radius = CGRectGetHeight(rect) / 2.0f;
    CGContextSetLineWidth(context, kBorderWidth);
    CGContextSetStrokeColorWithColor(context, self.borderTintColor.CGColor);
    [self drawRectangleInContext:context inRect:rect withRadius:radius];
    CGContextStrokePath(context);
    
    
    CGContextSetFillColorWithColor(context, self.progressTintColor.CGColor);
    CGRect progressRect = CGRectInset(rect, 2 * kBorderWidth, 2 * kBorderWidth);
    CGFloat progressRadius = CGRectGetHeight(progressRect) / 2.0f;
    progressRect.size.width = fmaxf(self.progress * progressRect.size.width, 2.0f * progressRadius);
    [self drawRectangleInContext:context inRect:progressRect withRadius:progressRadius];
    CGContextFillPath(context);
}

- (void)drawRectangleInContext:(CGContextRef)context inRect:(CGRect)rect withRadius:(CGFloat)radius
{
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + radius);
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height - radius);
    CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, radius, M_PI, M_PI / 2, 1);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height);
    CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + radius);
    CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, radius, 0.0f, -M_PI / 2, 1);
    CGContextAddLineToPoint(context, rect.origin.x + radius, rect.origin.y);
    CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + radius, radius, -M_PI / 2, M_PI, 1);
}

@end


#pragma mark -
#pragma mark THProgressView

@implementation PickerProgressView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.backgroundColor = [UIColor clearColor];
}

- (void)didMoveToWindow
{
    self.progressLayer.contentsScale = self.window.screen.scale;
}

+ (Class)layerClass
{
    return [THProgressLayer class];
}

- (THProgressLayer *)progressLayer
{
    return (THProgressLayer *)self.layer;
}


#pragma mark Getters & Setters

- (CGFloat)progress
{
    return self.progressLayer.progress;
}

- (void)setProgress:(CGFloat)progress
{
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    [self.progressLayer removeAnimationForKey:@"progress"];
    CGFloat pinnedProgress = MIN(MAX(progress, 0.0f), 1.0f);
    
    if (animated) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"progress"];
        animation.duration = fabsf(self.progress - pinnedProgress) + 0.1f;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.fromValue = [NSNumber numberWithFloat:self.progress];
        animation.toValue = [NSNumber numberWithFloat:pinnedProgress];
        [self.progressLayer addAnimation:animation forKey:@"progress"];
    }
    else {
        [self.progressLayer setNeedsDisplay];
    }
    
    self.progressLayer.progress = pinnedProgress;
}

- (UIColor *)progressTintColor
{
    return self.progressLayer.progressTintColor;
}

- (void)setProgressTintColor:(UIColor *)progressTintColor
{
    self.progressLayer.progressTintColor = progressTintColor;
   [self.progressLayer setNeedsDisplay];
}

- (UIColor *)borderTintColor
{
    return self.progressLayer.borderTintColor;
}

- (void)setBorderTintColor:(UIColor *)borderTintColor
{
    self.progressLayer.borderTintColor = borderTintColor;
    [self.progressLayer setNeedsDisplay];
}

@end
