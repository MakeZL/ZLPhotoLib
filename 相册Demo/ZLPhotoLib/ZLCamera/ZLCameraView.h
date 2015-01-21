//
//  BQCameraView.h
//  carame
//
//  Created by ZL on 14-9-24.
//  Copyright (c) 2014年 beiqing. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZLCameraView;

@protocol ZLCameraViewDelegate <NSObject>

@optional
- (void) cameraDidSelected : (ZLCameraView *) camera;

@end

@interface ZLCameraView : UIView

@property (weak, nonatomic) id <ZLCameraViewDelegate> delegate;

@end
