//
//  ZLNavigationController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-12-20.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ZLNavigationController.h"

@implementation ZLNavigationController

- (BOOL)shouldAutorotate{
    return self.topViewController.shouldAutorotate;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return [self.topViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//{
//    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
//}
//
//- (BOOL)shouldAutorotate
//{
//    return NO;
//}
//
//- (NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationPortrait;//只支持这一个方向(正常的方向)
//}


@end
