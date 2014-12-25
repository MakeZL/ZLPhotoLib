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
        
        if(self.translatesAutoresizingMaskIntoConstraints) break;
        
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
        
        [view.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-viewX-[myView(viewW)]" options:0 metrics:viewMetrics views:views]];
        
        [view.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-viewY-[myView(viewH)]" options:0 metrics:viewMetrics views:views]];
    }
}

- (BOOL) isAutoLayout{
    return _layout;
}

- (void)addSubview:(UIView *)view{
    [self insertSubview:view atIndex:self.subviews.count];
    if (view == self) {
        [self setupLayouts:@[view]];
    }
}

#pragma mark - Current view EqualTo ofView autoLayout.
/**
 *  Current view EqualTo ofView autoLayout.
 *
 *  @param direction    ZLAutoLayoutDirection
 *  @param toDircetion  OfView ZLAutoLayoutDirection
 */
- (void)autoPinDirection:(ZLAutoLayoutDirection)direction toPinDirection:(ZLAutoLayoutDirection)toDircetion ofView:(UIView *)ofView{
    
    [self ZLAutoLayoutConstraint:direction toPinDirection:toDircetion ofView:ofView];
    
}

#pragma mark - Current view EqualTo ofView autoLayout + inset.
/**
 *  Current view EqualTo ofView autoLayout + inset.
 *
 *  @param direction    ZLAutoLayoutDirection
 *  @param toDircetion  OfView ZLAutoLayoutDirection
 *  @param withInset    Inset
 */
- (void)autoPinDirection:(ZLAutoLayoutDirection)direction toPinDirection:(ZLAutoLayoutDirection)toDircetion ofView:(UIView *)ofView withInset:(CGFloat)inset{
    
    [self ZLAutoLayoutConstraint:direction toPinDirection:toDircetion ofView:ofView withInset:inset];
    
}

#pragma mark - Set view width && height
/**
 *  Set view width && height
 */
- (void)autoSetViewSize:(CGSize)size{
    [self autoSetViewSizeWidthOrHeight:ZLAutoLayoutSizeWidth withInset:size.width];
    [self autoSetViewSizeWidthOrHeight:ZLAutoLayoutSizeHeight withInset:size.height];
}
- (void)autoSetViewSizeWidthOrHeight:(ZLAutoLayoutSize)alSize withInset:(CGFloat)inset{
    [self autoPinDirection:(ZLAutoLayoutDirection)alSize toPinDirection:(ZLAutoLayoutDirection)alSize ofView:self.superview withInset:inset];
}

#pragma mark - Equal view to superView autoLayout
/**
 *  Equal view to superView autoLayout
 */
- (void)autoEqualToSuperViewAutoLayouts{
    [self autoPinSuperViewDirection:ZLAutoLayoutDirectionLeft];
    [self autoPinSuperViewDirection:ZLAutoLayoutDirectionRight];
    [self autoPinSuperViewDirection:ZLAutoLayoutDirectionTop];
    [self autoPinSuperViewDirection:ZLAutoLayoutDirectionBottom];
}

#pragma mark - Current view EqualTo superView autoLayout.
/**
 *  Current view EqualTo superView autoLayout.
 *
 *  @param direction    ZLAutoLayoutDirection
 */
- (void)autoPinSuperViewDirection:(ZLAutoLayoutDirection)direction{
    [self autoPinDirection:direction toPinDirection:direction ofView:self.superview];
}

#pragma mark - Current view EqualTo superView autoLayout + inset.
/**
 *  Current view EqualTo superView autoLayout + inset.
 *
 *  @param direction    ZLAutoLayoutDirection
 *  @param withInset    Inset
 */
- (void)autoPinSuperViewDirection:(ZLAutoLayoutDirection)direction withInset:(CGFloat)inset{
    [self autoPinDirection:direction toPinDirection:direction ofView:self.superview withInset:inset];
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
- (void)autoSetViewSizeWidthOrHeight:(ZLAutoLayoutSize)alSize ofView:(UIView *)ofView{
    [self autoPinDirection:(ZLAutoLayoutDirection)alSize toPinDirection:(ZLAutoLayoutDirection)alSize ofView:ofView];
}


#pragma mark - private
- (NSLayoutConstraint *) ZLAutoLayoutConstraint:(ZLAutoLayoutDirection)direction toPinDirection:(ZLAutoLayoutDirection)toDircetion ofView:(UIView *)ofView{
    return
    [self ZLAutoLayoutConstraint:direction toPinDirection:toDircetion ofView:ofView withInset:0];
}

- (NSLayoutConstraint *) ZLAutoLayoutConstraint:(ZLAutoLayoutDirection)direction toPinDirection:(ZLAutoLayoutDirection)toDircetion ofView:(UIView *)ofView withInset:(CGFloat)inset{
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    switch (direction) {
        case ZLAutoLayoutDirectionBottom:
        case ZLAutoLayoutDirectionRight:
            inset = -inset;
            break;
        default:
            break;
    }
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:[self ZLAutoLayoutAttribute:direction] relatedBy:NSLayoutRelationEqual toItem:ofView attribute:[self ZLAutoLayoutAttribute:toDircetion] multiplier:1.0 constant:inset];
    
    if([[self getParsentView:ofView] isEqual:ofView]){
        [ofView addConstraint:constraint];
    }else{
        [self.superview addConstraint:constraint];
    }
    
    
    return constraint;
}

#pragma mark - get Parsent View
- (UIView *)getParsentView:(UIView *)view{
    if ([[view nextResponder] isKindOfClass:[UIViewController class]] || view == nil) {
        return view;
    }
    return [self getParsentView:view.superview];
}

/**
 *  Set view -> superView centerX/Y + inset(options)
 *
 *  @param align ZLAutoLayoutAlign
 */
- (void)autoSetAlignToSuperView:(ZLAutoLayoutAlign)align{
    [self autoPinDirection:(ZLAutoLayoutDirection)align toPinDirection:(ZLAutoLayoutDirection)align ofView:self.superview];
}
- (void)autoSetAlignToSuperView:(ZLAutoLayoutAlign)align withInset:(CGFloat)inset{
    [self autoPinDirection:(ZLAutoLayoutDirection)align toPinDirection:(ZLAutoLayoutDirection)align ofView:self.superview withInset:inset];
}

/**
 *  Set view -> ofView centerX/Y + inset(options)
 *
 *  @param align ZLAutoLayoutAlign
 */
- (void)autoSetAlign:(ZLAutoLayoutAlign)align ofView:(UIView *)ofView{
    [self autoPinDirection:(ZLAutoLayoutDirection)align toPinDirection:(ZLAutoLayoutDirection)align ofView:ofView];
}
- (void)autoSetAlign:(ZLAutoLayoutAlign)align ofView:(UIView *)ofView withInset:(CGFloat)inset{
    [self autoPinDirection:(ZLAutoLayoutDirection)align toPinDirection:(ZLAutoLayoutDirection)align ofView:ofView withInset:inset];
}

@end
