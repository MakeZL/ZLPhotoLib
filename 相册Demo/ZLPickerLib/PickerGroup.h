//
//  PickerGroup.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PickerGroup : NSObject

/**
 *  组名
 */
@property (nonatomic , copy) NSString *groupName;

/**
 *  所有的图片
 */
@property (nonatomic , strong) NSArray *groups;

@end
