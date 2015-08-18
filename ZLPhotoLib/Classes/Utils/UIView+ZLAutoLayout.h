//
//  UIView+ZLAutoLayout.h
//  ZLAutoLayout
//
//  Created by 张磊 on 14-12-4.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NSLayoutConstraint ZLLayoutConstraint;

typedef NS_ENUM(NSUInteger, ZLAutoLayoutDirection){
    /** The left of the view. */
    ZLAutoLayoutDirectionLeft = NSLayoutAttributeLeft,
    /** The right of the view. */
    ZLAutoLayoutDirectionRight = NSLayoutAttributeRight,
    /** The top of the view. */
    ZLAutoLayoutDirectionTop = NSLayoutAttributeTop,
    /** The bottom of the view. */
    ZLAutoLayoutDirectionBottom = NSLayoutAttributeBottom,
    /** The leading of the view  */
    ZLAutoLayoutDirectionLeading = NSLayoutAttributeLeading,
    /** The trailing of the view */
    ZLAutoLayoutDirectionTrailing = NSLayoutAttributeTrailing
};

typedef NS_ENUM(NSUInteger, ZLAutoLayoutSize){
    /** The width of the view. */
    ZLAutoLayoutSizeWidth = NSLayoutAttributeWidth,
    /** The height of the view. */
    ZLAutoLayoutSizeHeight = NSLayoutAttributeHeight,
};

typedef NS_ENUM(NSUInteger, ZLAutoLayoutAlign){
    /** The Align Horizontal of the view. */
    ZLAutoLayoutAlignHorizontal = NSLayoutAttributeCenterX,
    /** The Align Vertical of the view. */ ZLAutoLayoutAlignVertical = NSLayoutAttributeCenterY,
};

@interface UIView (ZLAutoLayout)

+ (instancetype) instanceAutoLayoutView;
/**
 *  frame transfrom AutoLayout
 */
- (void)setAutoLayout:(BOOL)layout;
- (BOOL)isAutoLayout;

/**
 *  Current view EqualTo superView autoLayout.
 *
 *  @param direction    ZLAutoLayoutDirection
 */
- (ZLLayoutConstraint *)autoPinSuperViewDirection:(ZLAutoLayoutDirection)direction;

/**
 *  Current view EqualTo superView autoLayout + inset.
 *
 *  @param direction    ZLAutoLayoutDirection
 *  @param withInset    Inset
 */
- (ZLLayoutConstraint *)autoPinSuperViewDirection:(ZLAutoLayoutDirection)direction withInset:(CGFloat)inset;

/**
 *  Current view EqualTo ofView autoLayout.
 *
 *  @param direction    ZLAutoLayoutDirection
 *  @param toDircetion  OfView ZLAutoLayoutDirection
 */
- (ZLLayoutConstraint *)autoPinDirection:(ZLAutoLayoutDirection)direction toPinDirection:(ZLAutoLayoutDirection)toDircetion ofView:(UIView *)view;

/**
 *  Current view EqualTo ofView autoLayout + inset.
 *
 *  @param direction    ZLAutoLayoutDirection
 *  @param toDircetion  OfView ZLAutoLayoutDirection
 *  @param withInset    Inset
 */
- (ZLLayoutConstraint *)autoPinDirection:(ZLAutoLayoutDirection)direction toPinDirection:(ZLAutoLayoutDirection)toDircetion ofView:(UIView *)view withInset:(CGFloat)inset;

- (ZLLayoutConstraint *)autoPinDirection:(ZLAutoLayoutDirection)direction toPinDirection:(ZLAutoLayoutDirection)toDircetion ofView:(UIView *)ofView multiplier:(CGFloat)multiplier withInset:(CGFloat)inset;

/**
 *  Set view width && height
 */
- (NSMutableArray *)autoSetViewSize:(CGSize)size;
- (ZLLayoutConstraint *)autoSetViewSizeWidthOrHeight:(ZLAutoLayoutSize)alSize withInset:(CGFloat)inset;

/**
 *  Set view width || height -> ofView
 *
 *  @param alSize ZLAutoLayoutSize
 *  @param ofView ofView
 */
- (ZLLayoutConstraint *)autoSetViewSizeWidthOrHeight:(ZLAutoLayoutSize)alSize ofView:(UIView *)ofView;

/**
 *  Set view -> superView centerX/Y + inset(options)
 *
 *  @param align ZLAutoLayoutAlign
 */
- (ZLLayoutConstraint *)autoSetAlignToSuperView:(ZLAutoLayoutAlign)align;
- (ZLLayoutConstraint *)autoSetAlignToSuperView:(ZLAutoLayoutAlign)align withInset:(CGFloat)inset;

/**
 *  Set view -> ofView centerX/Y + inset(options)
 *
 *  @param align ZLAutoLayoutAlign
 */
- (ZLLayoutConstraint *)autoSetAlign:(ZLAutoLayoutAlign)align ofView:(UIView *)ofView;
- (ZLLayoutConstraint *)autoSetAlign:(ZLAutoLayoutAlign)align ofView:(UIView *)ofView withInset:(CGFloat)inset;

/**
 *  Equal view to superView autoLayout
 */
- (NSArray *)autoEqualToSuperViewAutoLayouts;

/**
 *  remove view to superView All autoLayout
 */
- (void)removeAllAutoLayout;
/**
 *  remove single constraint
 */
- (void)removeAutoLayout:(ZLLayoutConstraint *)constraint;
/*
 *  remove constraints
 */
- (void)removeAutoLayoutConstraints:(NSArray *)constraints;

@end
