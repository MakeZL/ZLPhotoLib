//
//  PickerCollectionView.m
//  相机
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#define MAX_COUNT 9 // 选择图片最大数默认是9

#import "PickerCollectionView.h"
#import "PickerCollectionViewCell.h"
#import "PickerImageView.h"
#import "PickerFooterCollectionReusableView.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface PickerCollectionView () <UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic , strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic , strong) NSMutableArray *images;

@property (nonatomic , strong) NSMutableArray *fullscrenImages;

/**
 *  选中的索引值，为了防止重用
 */
@property (nonatomic , strong) NSMutableArray *selectsIndexPath;
@property (nonatomic , strong) PickerFooterCollectionReusableView *footerView;


@end

@implementation PickerCollectionView

#pragma mark -getter
- (ALAssetsLibrary *)assetsLibrary{
    if (!_assetsLibrary) {
        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

- (NSMutableArray *)images{
    if (!_images) {
        _images = [NSMutableArray array];
    }
    return _images;
}

- (NSMutableArray *)fullscrenImages{
    if (!_fullscrenImages) {
        _fullscrenImages = [NSMutableArray array];
    }
    return _fullscrenImages;
}

- (NSMutableArray *)selectsIndexPath{
    if (!_selectsIndexPath) {
        _selectsIndexPath = [NSMutableArray array];
    }
    return _selectsIndexPath;
}

#pragma mark -setter
- (void)setDataArray:(NSArray *)dataArray{
    _dataArray = dataArray;

    for (int i = 0; i < dataArray.count; i++) {
        id resource = dataArray[i];
        if ([resource isKindOfClass:[UIImage class]]) {
            [self.images addObject:resource];
        }else if([resource isKindOfClass:[NSString class]]){
                // 如果不存在Asset就去请求加载
            [self getAssetURLWithImage:resource];
        }
        else if ([resource isKindOfClass:[ALAsset class]]){
            [self getAssetWithImage:resource];
        }
    }
    
    [self reloadData];
    
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.dataSource = self;
        self.delegate = self;
        _selectPictureArray = [NSMutableArray array];
        
        [self registerNib:[UINib nibWithNibName:@"PickerFooterCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
        
    }
    return self;
}



- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.images.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    PickerCollectionViewCell *cell = [PickerCollectionViewCell cellWithCollectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    PickerImageView *cellImgView = [[PickerImageView alloc] initWithFrame:cell.bounds];
    cellImgView.contentMode = UIViewContentModeScaleAspectFill;
    cellImgView.clipsToBounds = YES;
    [cell.contentView addSubview:cellImgView];
    
    cellImgView.maskViewFlag = ([self.selectsIndexPath containsObject:@(indexPath.row)]);
    
    cellImgView.image = self.images[indexPath.item];
    
    return cell;
}

#pragma mark 根据URL来获取图片
- (void) getAssetURLWithImage:(NSString *) assetUrl{
    [self.assetsLibrary assetForURL:[NSURL URLWithString:assetUrl] resultBlock:^(ALAsset *asset)
     {
         //在这里使用asset来获取图片
         [self getAssetWithImage:asset];
     } failureBlock:nil];
}

#pragma mark 根据ALAsset来获取
- (void) getAssetWithImage:(ALAsset *) asset{
    //在这里使用asset来获取图片
    ALAssetRepresentation *assetRep = [asset defaultRepresentation];
    CGImageRef imgRef = [asset thumbnail];
    UIImage *img = [UIImage imageWithCGImage:imgRef
                                       scale:assetRep.scale
                                 orientation:UIImageOrientationUp];
    [self.images addObject:img];
    
    @autoreleasepool {
        [self.fullscrenImages addObject:[UIImage imageWithCGImage:[assetRep fullScreenImage] scale:assetRep.scale
                                                      orientation:UIImageOrientationUp]];
    }
                                         
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    PickerCollectionViewCell *cell = (PickerCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
    
    PickerImageView *pickerImageView = [cell.contentView.subviews lastObject];
    // 如果没有就添加到数组里面，存在就移除
    if (pickerImageView.isMaskViewFlag) {
        [self.selectsIndexPath removeObject:@(indexPath.row)];
        [self.selectPictureArray removeObject:pickerImageView.image];
    }else{
        // 1 先判断是否超过选择图片的最大
        NSInteger maxCount = self.maxCount ? self.maxCount : MAX_COUNT;
        
        if (self.selectPictureArray.count >= maxCount) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:[NSString stringWithFormat:@"最多只能选择%ld张图片",maxCount] delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
            [alertView show];
            return ;
        }
        
        [self.selectsIndexPath addObject:@(indexPath.row)];
        [self.selectPictureArray addObject:pickerImageView.image];
    }
    pickerImageView.maskViewFlag = ([pickerImageView isKindOfClass:[PickerImageView class]]) && !pickerImageView.isMaskViewFlag;
    
    // 告诉代理现在被点击了!
    if ([self.collectionViewDelegate respondsToSelector:@selector(pickerCollectionView:didSelctedPicturesCount:)]) {
        [self.collectionViewDelegate pickerCollectionView:self didSelctedPicturesCount:self.selectPictureArray.count];
    }
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView = nil;
    if (kind == UICollectionElementKindSectionFooter) {
        PickerFooterCollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        footerView.count = self.dataArray.count;
        reusableView = footerView;
        self.footerView = footerView;
    }else{
        
    }
    return reusableView;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
