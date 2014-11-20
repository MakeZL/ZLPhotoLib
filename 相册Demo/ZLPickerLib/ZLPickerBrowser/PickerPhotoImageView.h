//
//  PickerImageView.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-15.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

typedef void(^downLoadWebImageCallBlock)();


#import <UIKit/UIKit.h>


@class PickerPhoto;
@interface PickerPhotoImageView : UIImageView

@property (nonatomic , strong) PickerPhoto *photo;
// 下载完回调
@property (nonatomic , copy) downLoadWebImageCallBlock downLoadWebImageCallBlock;


@end
