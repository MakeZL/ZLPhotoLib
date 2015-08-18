//
//  UIView+ZLAutoLayout.m
//  ZLAutoLayout
//
//  Created by 张磊 on 14-12-4.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "UIView+ZLAutoLayout.h"

static BOOL _layout;
static NSMutableArray *_layouts;

@implementation UIView (ZLAutoLayout)

+ (instancetype) instanceAutoLayoutView{
    UIView *autoLayoutView = [[self alloc] init];
    autoLayoutView.translatesAutoresizingMaskIntoConstraints = NO;
    return autoLayoutView;
    
}
- (void)setAutoLayout:(BOOL)layout{
    _layout = layout;
    
    if (!_layouts) {
        _layouts = [NSMutableArray array];
    }
    self.translatesAutoresizingMaskIntoConstraints = !layout;
    return;
}

#pragma mark - frame transfrom AutoLayout
/**
 *  frame transfrom AutoLayout
 */
- (void)setupLayouts:(NSArray *)layouts{
    
    for (UIView *view in layouts) {
        CGRect frame = view.frame;
        
        if (CGRectIsEmpty(frame)) {
            break;
        }
        
        UIView *myView = view;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(myView);
        NSDictionary *viewMetrics = @{
                                      @"viewX":@(frame.origin.x),
                                      @"viewY":@(frame.origin.y),
                                      @"viewW":@(frame.size.width),
                                      @"viewH":@(frame.size.height),
                                      };
        
        [view.superview addConstraints:[ZLLayoutConstraint constraintsWithVisualFormat:@"H:|-viewX-[myView(viewW)]" options:0 metrics:viewMetrics views:views]];
        
        [view.superview addConstraints:[ZLLayoutConstraint constraintsWithVisualFormat:@"V:|-viewY-[myView(viewH)]" options:0 metrics:viewMetrics views:views]];
    }
}

- (BOOL) isAutoLayout{
    return _layout;
}

#pragma mark - Current view EqualTo ofView autoLayout.
/**
 *  Current view EqualTo ofView autoLayout.
 *
 *  @param direction    ZLAutoLayoutDirection
 *  @param toDircetion  OfView ZLAutoLayoutDirection
 */
- (ZLLayoutConstraint *)autoPinDirection:(ZLAutoLayoutDirection)direction toPinDirection:(ZLAutoLayoutDirection)toDircetion ofView:(UIView *)ofView{
    
    return [self ZLAutoLayoutConstraint:direction toPinDirection:toDircetion ofView:ofView];
    
}

#pragma mark - Current view EqualTo ofView autoLayout + inset.

- (ZLLayoutConstraint *)autoPinDirection:(ZLAutoLayoutDirection)direction toPinDirection:(ZLAutoLayoutDirection)toDircetion ofView:(UIView *)ofView withInset:(CGFloat)inset{
    return [self ZLAutoLayoutConstraint:direction toPinDirection:toDircetion ofView:ofView withInset:inset];
}
/**
 *  Current view EqualTo ofView autoLayout + inset.
 *
 *  @param direction    ZLAutoLayoutDirection
 *  @param direction    multiplier
 *  @param toDircetion  OfView ZLAutoLayoutDirection
 *  @param withInset    Inset
 */
- (ZLLayoutConstraint *)autoPinDirection:(ZLAutoLayoutDirection)direction toPinDirection:(ZLAutoLayoutDirection)toDircetion ofView:(UIView *)ofView multiplier:(CGFloat)multiplier withInset:(CGFloat)inset{
    return [self ZLAutoLayoutConstraint:direction toPinDirection:toDircetion ofView:ofView multiplier:multiplier withInset:inset];
    
}

#pragma mark - Set view width && height
/**
 *  Set view width && height
 */
- (NSArray *)autoSetViewSize:(CGSize)size{
    ZLLayoutConstraint *cons1 = [self autoSetViewSizeWidthOrHeight:ZLAutoLayoutSizeWidth withInset:size.width];
    ZLLayoutConstraint *cons2 = [self autoSetViewSizeWidthOrHeight:ZLAutoLayoutSizeHeight withInset:size.height];
    return @[cons1,cons2];
}
- (ZLLayoutConstraint *)autoSetViewSizeWidthOrHeight:(ZLAutoLayoutSize)alSize withInset:(CGFloat)inset{
    return [self autoPinDirection:(ZLAutoLayoutDirection)alSize toPinDirection:(ZLAutoLayoutDirection)alSize ofView:nil withInset:inset];
}

#pragma mark - Equal view to superView autoLayout
/**
 *  Equal view to superView autoLayout
 */
- (NSArray *)autoEqualToSuperViewAutoLayouts{
    ZLLayoutConstraint *left = [self autoPinSuperViewDirection:ZLAutoLayoutDirectionLeft];
    ZLLayoutConstraint *right = [self autoPinSuperViewDirection:ZLAutoLayoutDirectionRight];
    ZLLayoutConstraint *top = [self autoPinSuperViewDirection:ZLAutoLayoutDirectionTop];
    ZLLayoutConstraint *bottom = [self autoPinSuperViewDirection:ZLAutoLayoutDirectionBottom];
    return @[left,right,top,bottom];
}

#pragma mark - Current view EqualTo superView autoLayout.
/**
 *  Current view EqualTo superView autoLayout.
 *
 *  @param direction    ZLAutoLayoutDirection
 */
- (ZLLayoutConstraint *)autoPinSuperViewDirection:(ZLAutoLayoutDirection)direction{
    return [self autoPinDirection:direction toPinDirection:direction ofView:self.superview];
}

#pragma mark - Current view EqualTo superView autoLayout + inset.
/**
 *  Current view EqualTo superView autoLayout + inset.
 *
 *  @param direction    ZLAutoLayoutDirection
 *  @param withInset    Inset
 */
- (ZLLayoutConstraint *)autoPinSuperViewDirection:(ZLAutoLayoutDirection)direction withInset:(CGFloat)inset{
    return [self autoPinDirection:direction toPinDirection:direction ofView:self.superview withInset:inset];
}

#pragma mark - Get ZLAutoLayoutDirection Real type.
/**
 *  Get ZLAutoLayoutDirection Real type.
 *
 *  @param direction ZLAutoLayoutDirection -> NSLayoutAttribute
 *
 *  @return NSLayoutAttribute
 */
- (NSLayoutAttribute) ZLAutoLayoutAttribute:(ZLAutoLayoutDirection)direction{
    return (NSLayoutAttribute)direction;
}

#pragma mark - Set view width || height -> ofView
/**
 *  Set view width || height -> ofView
 *
 *  @param alSize ZLAutoLayoutSize
 *  @param ofView ofView
 */
- (ZLLayoutConstraint *)autoSetViewSizeWidthOrHeight:(ZLAutoLayoutSize)alSize ofView:(UIView *)ofView{
    return [self autoPinDirection:(ZLAutoLayoutDirection)alSize toPinDirection:(ZLAutoLayoutDirection)alSize ofView:ofView];
}


#pragma mark - private
- (ZLLayoutConstraint *) ZLAutoLayoutConstraint:(ZLAutoLayoutDirection)direction toPinDirection:(ZLAutoLayoutDirection)toDircetion ofView:(UIView *)ofView{
    return
    [self ZLAutoLayoutConstraint:direction toPinDirection:toDircetion ofView:ofView withInset:0];
}

- (ZLLayoutConstraint *) ZLAutoLayoutConstraint:(ZLAutoLayoutDirection)direction toPinDirection:(ZLAutoLayoutDirection)toDircetion ofView:(UIView *)ofView multiplier:(CGFloat)multiplier withInset:(CGFloat)inset{
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    switch (direction) {
        case ZLAutoLayoutDirectionBottom:
        case ZLAutoLayoutDirectionRight:
            inset = -inset;
            break;
        default:
            break;
    }
    
    ZLLayoutConstraint *constraint = [ZLLayoutConstraint constraintWithItem:self attribute:[self ZLAutoLayoutAttribute:direction] relatedBy:NSLayoutRelationEqual toItem:ofView attribute:[self ZLAutoLayoutAttribute:toDircetion] multiplier:multiplier constant:inset];
    
    [self.superview addConstraint:constraint];
    return constraint;
}

#pragma mark - setAutoLayout
- (ZLLayoutConstraint *) ZLAutoLayoutConstraint:(ZLAutoLayoutDirection)direction toPinDirection:(ZLAutoLayoutDirection)toDircetion ofView:(UIView *)ofView withInset:(CGFloat)inset{
    return [self ZLAutoLayoutConstraint:direction toPinDirection:toDircetion ofView:ofView multiplier:1.0 withInset:inset];
}

/**
 *  Set view -> superView centerX/Y + inset(options)
 *
 *  @param align ZLAutoLayoutAlign
 */
- (ZLLayoutConstraint *)autoSetAlignToSuperView:(ZLAutoLayoutAlign)align{
    return [self autoPinDirection:(ZLAutoLayoutDirection)align toPinDirection:(ZLAutoLayoutDirection)align ofView:self.superview];
}
- (ZLLayoutConstraint *)autoSetAlignToSuperView:(ZLAutoLayoutAlign)align withInset:(CGFloat)inset{
    return [self autoPinDirection:(ZLAutoLayoutDirection)align toPinDirection:(ZLAutoLayoutDirection)align ofView:self.superview withInset:inset];
}

/**
 *  Set view -> ofView centerX/Y + inset(options)
 *
 *  @param align ZLAutoLayoutAlign
 */
- (ZLLayoutConstraint *)autoSetAlign:(ZLAutoLayoutAlign)align ofView:(UIView *)ofView{
    return [self autoPinDirection:(ZLAutoLayoutDirection)align toPinDirection:(ZLAutoLayoutDirection)align ofView:ofView];
}
- (ZLLayoutConstraint *)autoSetAlign:(ZLAutoLayoutAlign)align ofView:(UIView *)ofView withInset:(CGFloat)inset{
    return [self autoPinDirection:(ZLAutoLayoutDirection)align toPinDirection:(ZLAutoLayoutDirection)align ofView:ofView withInset:inset];
}

/**
 *  remove view to superView autoLayout
 */
#pragma mark - remove view to superView autoLayout
- (void)removeAllAutoLayout{
    [self removeConstraints:self.constraints];
    for (ZLLayoutConstraint *constraint in self.superview.constraints) {
        if ([constraint.firstItem isEqual:self]) {
            [self.superview removeConstraint:constraint];
        }
    }
}

#pragma mark - remove single constraint
- (void)removeAutoLayout:(ZLLayoutConstraint *)constraint{
    for (ZLLayoutConstraint *constraint in self.superview.constraints) {
        if ([constraint isEqual:constraint]) {
            [self.superview removeConstraint:constraint];
        }
    }
}

#pragma mark - remove constraints 
- (void)removeAutoLayoutConstraints:(NSArray *)constraints{
    for (ZLLayoutConstraint *constraint in constraints) {
        for (ZLLayoutConstraint *superViewConstraint in self.superview.constraints) {
            if ([superViewConstraint isEqual:constraint]) {
                [self.superview removeConstraint:constraint];
            }
        }
    }
}
@end
