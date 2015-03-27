//
//  BQCamera.h
//  BQCommunity
//
//  Created by ZL on 14-9-11.
//  Copyright (c) 2014年 beiqing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLCamera.h"

typedef void(^codeBlock)();
typedef void(^ZLComplate)(id object);

@interface ZLCameraViewController : UIViewController

/**
 *  打开相机
 *
 *  @param viewController 控制器
 *  @param complate       成功后的回调
 */
- (void)startCameraOrPhotoFileWithViewController:(UIViewController*)viewController complate : (ZLComplate ) complate;

@end
