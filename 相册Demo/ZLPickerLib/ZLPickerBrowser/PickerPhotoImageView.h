//
//  PickerImageView.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-15.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PickerPhoto;

@interface PickerPhotoImageView : UIImageView

@property (nonatomic , strong) PickerPhoto *photo;

- (void) setupFrame;

@end
