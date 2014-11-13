//
//  PickerDatas.m
//  相册Demo
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "PickerDatas.h"
#import "PickerGroup.h"
#import <AssetsLibrary/AssetsLibrary.h>

typedef ALAssetsLibraryAccessFailureBlock failureBlock;

@interface PickerDatas ()

/**
 *  是否是URLs，默认传图片
 */
@property (nonatomic , assign , getter=isResourceURLs) BOOL resourceURLs;
@property (nonatomic , strong) NSMutableArray *groups;

@property (nonatomic , strong) PickerGroup *currentGroupModel;

@property (nonatomic , copy) failureBlock failureBlock;

@end

@implementation PickerDatas

#pragma mark -getter
- (NSMutableArray *)groups{
    if (!_groups) {
        _groups = [NSMutableArray array];
    }
    return _groups;
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

//
///**
// *  获取数据
// */
//- (void) getDatas : (callBackBlock) callBack{
//    NSMutableArray *dataArray = [NSMutableArray array];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result, NSUInteger index, BOOL *stop){
//            if (result!=NULL) {
//                if (self.isResourceURLs) {
//                    // URL
//                    NSString *urlStr=[NSString stringWithFormat:@"%@",result.defaultRepresentation.url];
//                    [dataArray addObject:urlStr];
//                }else{
//                    // 图片
//                    if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
//                        UIImage *image = [UIImage imageWithCGImage:result.defaultRepresentation.fullScreenImage];
//                        [dataArray addObject:image];
////                        self.currentGroupModel.groups = dataArray;
//                    }
//                }
//                
//                
//            }else{
//                // 完毕调用回调方法
//                callBack(dataArray);
//            }
//            
//        };
//        
//        
//        ALAssetsLibraryGroupsEnumerationResultsBlock
//        libraryGroupsEnumeration = ^(ALAssetsGroup* group, BOOL* stop){
//            
//            if (group == nil)
//            {
//                
//            }
//            
//            if (group!=nil) {
//                NSString *g=[NSString stringWithFormat:@"%@",group];//获取相簿的组
//                NSLog(@"gg:%@",g);//gg:ALAssetsGroup - Name:Camera Roll, Type:Saved Photos, Assets count:71
//                
//                NSString *g1=[g substringFromIndex:16 ] ;
//                NSArray *arr=[[NSArray alloc] init];
//                arr=[g1 componentsSeparatedByString:@","];
//                NSString *g2=[[arr objectAtIndex:0] substringFromIndex:5];
//                if ([g2 isEqualToString:@"Camera Roll"]) {
//                    g2=@"相机胶卷";
//                }
//                NSLog(@"%@",g2);
////                NSString *groupName=g2;//组的name
//                
////                PickerGroup *groupModel = [[PickerGroup alloc] init];
////                groupModel.groupName = groupName;
////                self.currentGroupModel = groupModel;
//                
//                [group enumerateAssetsUsingBlock:groupEnumerAtion];
//            }
//            
//        };
//        
//        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
//        [library enumerateGroupsWithTypes:ALAssetsGroupAll
//                               usingBlock:libraryGroupsEnumeration
//                             failureBlock:failureblock];
//    });
//}


/**
 * 获取所有组对应的图片
 */
- (void) getAllGroupWithPhotos : (callBackBlock ) callBack{
    NSMutableArray *dataArray = [NSMutableArray array];
    __block NSInteger assetsCount = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result, NSUInteger index, BOOL *stop){
            if (result!=NULL) {
                    // 图片
                    if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                        UIImage *image = [UIImage imageWithCGImage:result.thumbnail];
                        if (!self.currentGroupModel.thumbImage) {
                            self.currentGroupModel.thumbImage = image;
                        }
                    }
                    assetsCount = index;
            }else{
                // 如果不存在图片就弄占位图片
                if (!self.currentGroupModel.thumbImage) {
                    self.currentGroupModel.thumbImage = [UIImage imageNamed:@"wallpaper_placeholder"];
                }
                self.currentGroupModel.assetsCount = assetsCount;
                // 完毕调用回调方法
                [self.groups addObject:self.currentGroupModel];
            }
            
        };
        
        
        ALAssetsLibraryGroupsEnumerationResultsBlock
        libraryGroupsEnumeration = ^(ALAssetsGroup* group, BOOL* stop){
            
            if (group == nil)
            {
                callBack(dataArray);
            }
            
            if (group!=nil) {
                NSString *g=[NSString stringWithFormat:@"%@",group];//获取相簿的组
                NSLog(@"gg:%@",g);//gg:ALAssetsGroup - Name:Camera Roll, Type:Saved Photos, Assets count:71
                
                NSString *g1=[g substringFromIndex:16 ] ;
                NSArray *arr=[[NSArray alloc] init];
                arr=[g1 componentsSeparatedByString:@","];
                NSString *g2=[[arr objectAtIndex:0] substringFromIndex:5];
                if ([g2 isEqualToString:@"Camera Roll"]) {
                    g2 = @"相机胶卷";
                }else if ([g2 isEqualToString:@"My Photo Stream"]){
                    g2 = @"我的相机流";
                }
                
                NSString *groupName=g2;//组的name
                
                PickerGroup *groupModel = [[PickerGroup alloc] init];
                groupModel.groupName = groupName;
                groupModel.realGroupName = g;
                groupModel.type = [self getGroupReplaceTypeName:g];
                self.currentGroupModel = groupModel;
                
                
                [dataArray addObject:groupModel];
                
                [group enumerateAssetsUsingBlock:groupEnumerAtion];
                
            }
        };
        
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        [library enumerateGroupsWithTypes:ALAssetsGroupAll
                               usingBlock:libraryGroupsEnumeration
                             failureBlock:_failureBlock];
    });
    
}

- (NSString *) getGroupReplaceTypeName:(NSString *) g{
    NSRange typeRange = [g rangeOfString:@"Type:"];
    NSString *type = [g stringByReplacingCharactersInRange:NSMakeRange(0, typeRange.location+typeRange.length) withString:@""];
    NSRange strRange = [type rangeOfString:@","];
    type = [type stringByReplacingCharactersInRange: NSMakeRange(strRange.location, type.length - strRange.location) withString:@""];
    return type;
}

/**
 *  传入一个组获取组里面的图片
 */
- (void) getGroupPhotosWithGroup : (PickerGroup *) pickerGroup finished : (callBackBlock ) callBack{
    __block PickerGroup *backGroup = [[PickerGroup alloc] init];
    // 缩略图
    NSMutableArray *thumbImgs = [NSMutableArray array];
    // 原图
    NSMutableArray *assets = [NSMutableArray array];
    dispatch_async(dispatch_get_main_queue(), ^{
        ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result, NSUInteger index, BOOL *stop){
            if (result!=NULL) {
                
                [assets addObject:result];
            }else{
                // 完毕调用回调方法
                backGroup.thumbsAssets = thumbImgs;
                backGroup.assets = assets;
                callBack(backGroup);
            }
            
        };
        
        
        ALAssetsLibraryGroupsEnumerationResultsBlock
        libraryGroupsEnumeration = ^(ALAssetsGroup* group, BOOL* stop){
            
            if (group!=nil) {
                
                NSString *g=[NSString stringWithFormat:@"%@",group];//获取相簿的组
                
                // 如果匹配到了就退出
                if ([g isEqualToString:pickerGroup.realGroupName]) {
                    
                    [group enumerateAssetsUsingBlock:groupEnumerAtion];
                    
                    *stop = YES;
                }
            }
        };
        
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        [library enumerateGroupsWithTypes:ALAssetsGroupAll
                               usingBlock:libraryGroupsEnumeration
                             failureBlock:_failureBlock];
    });
    


}

@end
