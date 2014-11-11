//
//  PickerCollectionViewCell.m
//  相机
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "PickerCollectionViewCell.h"

@interface PickerCollectionViewCell ()

@property (nonatomic , weak) UIImageView *cellImgView;

@end

@implementation PickerCollectionViewCell

static UIImageView *_cellImageView;

//- (UIImageView *)cellImgView{
//    if (!_cellImgView) {
//        PickerImageView *cellImgView = [[PickerImageView alloc] initWithFrame:self.bounds];
//        cellImgView.contentMode = UIViewContentModeScaleAspectFill;
//        cellImgView.clipsToBounds = YES;
//        [self.contentView addSubview:cellImgView];
//        self.cellImgView = cellImgView;
//    }
//    return _cellImgView;
//}


+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    PickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    if ([[cell.contentView.subviews lastObject] isKindOfClass:[UIImageView class]]) {
        [[cell.contentView.subviews lastObject] removeFromSuperview];
    }
    
    return cell;
}

//- (void)setCellImage:(UIImage *)cellImage{
//    _cellImage = cellImage;
//    self.cellImgView.image = cellImage;
//}

@end
