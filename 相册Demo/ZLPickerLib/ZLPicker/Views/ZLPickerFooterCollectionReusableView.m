//
//  FooterCollectionReusableView.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-13.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ZLPickerFooterCollectionReusableView.h"

@interface ZLPickerFooterCollectionReusableView ()
@property (weak, nonatomic) IBOutlet UILabel *footerLabel;

@end

@implementation ZLPickerFooterCollectionReusableView

- (void)setCount:(NSInteger)count{
    _count = count;
    
    if (count > 0) {
        self.footerLabel.text = [NSString stringWithFormat:@"有 %ld 张图片", count];
    }
}

@end
