//
//  gifView.h
//  playGif
//
//  Created by 张磊 on 14-11-15.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ZLPickerBrowserPhotoGifView : UIView
{
    CGImageSourceRef gif; // 保存gif动画
    NSDictionary *gifProperties; // 保存gif动画属性
    size_t index; // gif动画播放开始的帧序号
    size_t count; // gif动画的总帧数
    NSTimer *timer; // 播放gif动画所使用的timer
}

/**
 *  播放本地gif图
 */
- (id)initWithFrame:(CGRect)frame filePath:(NSString *)filePath;
/**
 *  播放网络gif图
 */
- (void)playGifWithURLString:(NSString *)urlString;
- (void)stopGif;
@end
