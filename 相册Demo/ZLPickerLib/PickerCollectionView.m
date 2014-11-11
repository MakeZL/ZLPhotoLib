//
//  PickerCollectionView.m
//  相机
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "PickerCollectionView.h"
#import "PickerCollectionViewCell.h"
#import "PickerImageView.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface PickerCollectionView () <UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic , strong) NSMutableDictionary *dict;
@property (nonatomic , strong) ALAssetsLibrary *assetsLibrary;

@end

@implementation PickerCollectionView

- (ALAssetsLibrary *)assetsLibrary{
    if (!_assetsLibrary) {
        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

- (NSMutableDictionary *)dict{
    if (!_dict) {
        _dict = [NSMutableDictionary dictionary];
    }
    return _dict;
}

- (void)setDataArray:(NSArray *)dataArray{
    _dataArray = dataArray;

    [self reloadData];
}

#pragma mark -getter
- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.dataSource = self;
        self.delegate = self;
        _selectPictureArray = [NSMutableArray array];
    }
    return self;
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    PickerCollectionViewCell *cell = [PickerCollectionViewCell cellWithCollectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    PickerImageView *cellImgView = [[PickerImageView alloc] initWithFrame:cell.bounds];
    cellImgView.contentMode = UIViewContentModeScaleAspectFill;
    cellImgView.clipsToBounds = YES;
    [cell.contentView addSubview:cellImgView];
    
    id resource = self.dataArray[indexPath.item];
    if ([resource isKindOfClass:[UIImage class]]) {
        cellImgView.image = resource;
    }else if([resource isKindOfClass:[NSString class]]){
        if ([self.dict objectForKey:@(indexPath.row)]) {
            cellImgView.image = self.dict[@(indexPath.row)];
        }else{
            // 如果不存在Asset就去请求加载
            [self getAssetURLWithImage:resource atIndexPath:indexPath];
        }
    }
    
    return cell;
}

#pragma mark 根据URL来获取图片
- (void) getAssetURLWithImage:(NSString *) assetUrl atIndexPath:(NSIndexPath *)indexPath{
    [self.assetsLibrary assetForURL:[NSURL URLWithString:assetUrl] resultBlock:^(ALAsset *asset)
    {
        //在这里使用asset来获取图片
        ALAssetRepresentation *assetRep = [asset defaultRepresentation];
        CGImageRef imgRef = [assetRep fullResolutionImage];
        UIImage *img = [UIImage imageWithCGImage:imgRef
                                           scale:assetRep.scale
                                     orientation:(UIImageOrientation)assetRep.orientation];
        self.dict[@(indexPath.row)] = img;
        [self reloadData];
    } failureBlock:nil];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    PickerCollectionViewCell *cell = (PickerCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
    PickerImageView *pickerImageView = [cell.contentView.subviews lastObject];
    // 如果没有就添加到数组里面，存在就移除
    if (pickerImageView.isMaskViewFlag) {
        [self.selectPictureArray removeObject:pickerImageView.image];
    }else{
        [self.selectPictureArray addObject:pickerImageView.image];
    }
    pickerImageView.maskViewFlag = ([pickerImageView isKindOfClass:[PickerImageView class]]) && !pickerImageView.isMaskViewFlag;
}

@end
