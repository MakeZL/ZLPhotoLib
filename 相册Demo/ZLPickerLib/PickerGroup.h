//
//  PickerGroup.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickerGroup : NSObject

/**
 *  组名
 */
@property (nonatomic , copy) NSString *groupName;

/**
 *  组的真实名
 */
@property (nonatomic , copy) NSString *realGroupName;

/**
 *  缩略图
 */
@property (nonatomic , strong) UIImage *thumbImage;

/**
 *  类型 : Saved Photos...
 */
@property (nonatomic , copy) NSString *type;

/**
 *  所有的图片
 */
@property (nonatomic , strong) NSArray *assets;
/**
 *  所有的图片的缩略图
 */
@property (nonatomic , strong) NSArray *thumbsAssets;

@end
