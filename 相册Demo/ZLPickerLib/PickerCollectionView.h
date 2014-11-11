//
//  PickerCollectionView.h
//  相机
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickerCollectionView : UICollectionView
/**
 *  保存所有的数据
 */
@property (nonatomic , strong) NSArray *dataArray;

// 保存选中的图片
@property (nonatomic , strong , readonly) NSMutableArray *selectPictureArray;

@end
