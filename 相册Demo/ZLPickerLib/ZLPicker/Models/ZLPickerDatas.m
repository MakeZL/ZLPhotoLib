//
//  PickerDatas.m
//  相册Demo
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ZLPickerDatas.h"
#import "ZLPickerGroup.h"
#import <AssetsLibrary/AssetsLibrary.h>

typedef ALAssetsLibraryAccessFailureBlock failureBlock;

@interface ZLPickerDatas ()

/**
 *  是否是URLs，默认传图片
 */
@property (nonatomic , assign , getter=isResourceURLs) BOOL resourceURLs;
@property (nonatomic , strong) NSMutableArray *groups;

@property (nonatomic , strong) ZLPickerGroup *currentGroupModel;
@property (nonatomic , strong) ZLPickerGroup *backGroup;

@property (nonatomic , copy) failureBlock failureBlock;
@property (nonatomic , strong) ALAssetsLibrary *library;

@end

@implementation ZLPickerDatas

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred,^
                  {
                      library = [[ALAssetsLibrary alloc] init];
                  });
    return library;
}

- (ALAssetsLibrary *)library
{
    if (nil == _library)
    {
        _library = [self.class defaultAssetsLibrary];
    }
    
    return _library;
}

#pragma mark -getter
- (ZLPickerGroup *)backGroup{
    if (!_backGroup) {
        _backGroup = [[ZLPickerGroup alloc] init];
    }
    return _backGroup;
}

- (failureBlock)failureBlock{
    if (!_failureBlock) {
        _failureBlock = ^(NSError *myerror){
            NSLog(@"相册访问失败 =%@", [myerror localizedDescription]);
            if ([myerror.localizedDescription rangeOfString:@"Global denied access"].location!=NSNotFound) {
                NSLog(@"无法访问相册.请在'设置->定位服务'设置为打开状态.");
            }else{
                NSLog(@"相册访问失败.");
            }
        };
    }
    return _failureBlock;
}

+ (instancetype) defaultPicker{
    return [[self alloc] init];
}

#pragma mark -获取所有组
- (void) getAllGroupWithPhotos : (callBackBlock ) callBack{
    
    NSMutableArray *groups = [NSMutableArray array];
    ALAssetsLibraryGroupsEnumerationResultsBlock resultBlock = ^(ALAssetsGroup *group, BOOL *stop){
        if (group) {
            // 包装一个模型来赋值
            ZLPickerGroup *pickerGroup = [[ZLPickerGroup alloc] init];
            pickerGroup.group = group;
            pickerGroup.groupName = [group valueForProperty:@"ALAssetsGroupPropertyName"];
            pickerGroup.thumbImage = [UIImage imageWithCGImage:[group posterImage]];
            pickerGroup.assetsCount = [group numberOfAssets];
            [groups addObject:pickerGroup];
        }else{
            callBack(groups);
        }
    };
    
    NSInteger type = ALAssetsGroupLibrary | ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos | ALAssetsGroupPhotoStream;
    
    [self.library enumerateGroupsWithTypes:type usingBlock:resultBlock failureBlock:nil];
}

#pragma mark -传入一个组获取组里面的Asset
- (void) getGroupPhotosWithGroup : (ZLPickerGroup *) pickerGroup finished : (callBackBlock ) callBack{
    
    NSMutableArray *assets = [NSMutableArray array];
    ALAssetsGroupEnumerationResultsBlock result = ^(ALAsset *asset , NSUInteger index , BOOL *stop){
        if (asset) {
            [assets addObject:asset];
        }else{
            callBack(assets);
        }
    };
    [pickerGroup.group enumerateAssetsUsingBlock:result];
    
}

#pragma mark -传入一个AssetsURL来获取UIImage
- (void) getAssetsPhotoWithURLs:(NSURL *) url callBack:(callBackBlock ) callBack{
    [self.library assetForURL:url resultBlock:^(ALAsset *asset) {
        dispatch_async(dispatch_get_main_queue(), ^{
            callBack([UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]]);
        });
    } failureBlock:nil];
}

#pragma mark - 通过传入一个图片对象（ALAsset、URL）获取一张缩略图
- (UIImage *) getImageWithImageObj:(id)imageObj{
    __block UIImage *image = nil;
    if ([imageObj isKindOfClass:[UIImage class]]) {
        image = imageObj;
    }else if ([imageObj isKindOfClass:[ALAsset class]]){
        ALAsset *asset = (ALAsset *)imageObj;
        image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
    }else if ([imageObj isKindOfClass:[NSURL class]]){
        
        image = imageObj;
    }
    return image;
}

@end
