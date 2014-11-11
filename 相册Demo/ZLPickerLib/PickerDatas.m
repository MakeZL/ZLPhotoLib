//
//  PickerDatas.m
//  相册Demo
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "PickerDatas.h"
//#import "PickerGroup.h"
#import <AssetsLibrary/AssetsLibrary.h>


@interface PickerDatas ()

/**
 *  是否是URLs，默认传图片
 */
@property (nonatomic , assign , getter=isResourceURLs) BOOL resourceURLs;
@property (nonatomic , strong) NSMutableArray *groups;

//@property (nonatomic , strong) PickerGroup *currentGroupModel;


@end

@implementation PickerDatas

- (NSMutableArray *)groups{
    if (!_groups) {
        _groups = [NSMutableArray array];
    }
    return _groups;
}

+ (instancetype) defaultPicker{
    return [[self alloc] init];
}


/**
 * 获取所有的图片的URL
 */
- (void) getAllPhotosURLs : (callBackBlock ) callBack{
    self.resourceURLs = YES;
    [self getDatas:callBack];
}

/**
 * 获取所有的图片的URL
 */
- (void) getAllPhotos : (callBackBlock) callBack{
    self.resourceURLs = NO;
    [self getDatas:callBack];
}

/**
 *  获取数据
 */
- (void) getDatas : (callBackBlock) callBack{
    NSMutableArray *dataArray = [NSMutableArray array];
    dispatch_async(dispatch_get_main_queue(), ^{
        ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror){
            NSLog(@"相册访问失败 =%@", [myerror localizedDescription]);
            if ([myerror.localizedDescription rangeOfString:@"Global denied access"].location!=NSNotFound) {
                NSLog(@"无法访问相册.请在'设置->定位服务'设置为打开状态.");
            }else{
                NSLog(@"相册访问失败.");
            }
        };
        
        ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result, NSUInteger index, BOOL *stop){
            if (result!=NULL) {
                if (self.isResourceURLs) {
                    // URL
                    NSString *urlStr=[NSString stringWithFormat:@"%@",result.defaultRepresentation.url];
                    [dataArray addObject:urlStr];
                }else{
                    // 图片
                    if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                        UIImage *image = [UIImage imageWithCGImage:result.defaultRepresentation.fullScreenImage];
                        [dataArray addObject:image];
//                        self.currentGroupModel.groups = dataArray;
                    }
                }
                
                
            }else{
                // 完毕调用回调方法
                [self.groups addObject:dataArray];
                callBack(dataArray);
            }
            
        };
        
        
        ALAssetsLibraryGroupsEnumerationResultsBlock
        libraryGroupsEnumeration = ^(ALAssetsGroup* group, BOOL* stop){
            
            if (group == nil)
            {
                
            }
            
            if (group!=nil) {
                NSString *g=[NSString stringWithFormat:@"%@",group];//获取相簿的组
                NSLog(@"gg:%@",g);//gg:ALAssetsGroup - Name:Camera Roll, Type:Saved Photos, Assets count:71
                
                NSString *g1=[g substringFromIndex:16 ] ;
                NSArray *arr=[[NSArray alloc] init];
                arr=[g1 componentsSeparatedByString:@","];
                NSString *g2=[[arr objectAtIndex:0] substringFromIndex:5];
                if ([g2 isEqualToString:@"Camera Roll"]) {
                    g2=@"相机胶卷";
                }else{
                    g2=@"ZLPhotos";
                }
                NSString *groupName=g2;//组的name
                
//                PickerGroup *groupModel = [[PickerGroup alloc] init];
//                groupModel.groupName = groupName;
//                self.currentGroupModel = groupModel;
                
                [group enumerateAssetsUsingBlock:groupEnumerAtion];
            }
            
        };
        
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        [library enumerateGroupsWithTypes:ALAssetsGroupAll
                               usingBlock:libraryGroupsEnumeration
                             failureBlock:failureblock];
    });
}


/**
 * 获取所有组对应的图片
 */
- (void) getAllGroupWithPhotos : (callBackBlock ) callBack{
    NSMutableArray *dataArray = [NSMutableArray array];
    dispatch_async(dispatch_get_main_queue(), ^{
        ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror){
            NSLog(@"相册访问失败 =%@", [myerror localizedDescription]);
            if ([myerror.localizedDescription rangeOfString:@"Global denied access"].location!=NSNotFound) {
                NSLog(@"无法访问相册.请在'设置->定位服务'设置为打开状态.");
            }else{
                NSLog(@"相册访问失败.");
            }
        };
        
        ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result, NSUInteger index, BOOL *stop){
            if (result!=NULL) {
//                if (self.isResourceURLs) {
//                    // URL
//                    NSString *urlStr=[NSString stringWithFormat:@"%@",result.defaultRepresentation.url];
//                    [dataArray addObject:urlStr];
//                }else{
                    // 图片
                    if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                        UIImage *image = [UIImage imageWithCGImage:result.defaultRepresentation.fullScreenImage];
                        [dataArray addObject:image];
//                        self.currentGroupModel.groups = dataArray;
                    }
//                }
                
                
            }else{
                // 完毕调用回调方法
//                [self.groups addObject:self.currentGroupModel];
//                callBack(dataArray);
            }
            
        };
        
        
        ALAssetsLibraryGroupsEnumerationResultsBlock
        libraryGroupsEnumeration = ^(ALAssetsGroup* group, BOOL* stop){
            
            if (group == nil)
            {
                callBack(self.groups);
            }
            
            if (group!=nil) {
                NSString *g=[NSString stringWithFormat:@"%@",group];//获取相簿的组
                NSLog(@"gg:%@",g);//gg:ALAssetsGroup - Name:Camera Roll, Type:Saved Photos, Assets count:71
                
                NSString *g1=[g substringFromIndex:16 ] ;
                NSArray *arr=[[NSArray alloc] init];
                arr=[g1 componentsSeparatedByString:@","];
                NSString *g2=[[arr objectAtIndex:0] substringFromIndex:5];
                if ([g2 isEqualToString:@"Camera Roll"]) {
                    g2=@"相机胶卷";
                }else{
                    g2=@"ZLPhotos";
                }
                NSString *groupName=g2;//组的name
                
//                PickerGroup *groupModel = [[PickerGroup alloc] init];
//                groupModel.groupName = groupName;
//                self.currentGroupModel = groupModel;
                
                [group enumerateAssetsUsingBlock:groupEnumerAtion];
                
            }
        };
        
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        [library enumerateGroupsWithTypes:ALAssetsGroupAll
                               usingBlock:libraryGroupsEnumeration
                             failureBlock:failureblock];
    });
    
}

@end
