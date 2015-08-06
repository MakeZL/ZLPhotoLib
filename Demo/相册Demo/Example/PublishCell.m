//
//  PublishCell.m
//  Where_Beauty
//
//  Created by Transuner on 15-5-21.
//  Copyright (c) 2015年 广州酷炫信息科技有限公司. All rights reserved.
//

#import "PublishCell.h"
#import "ZLPhotoAssets.h"

@implementation PublishCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier IndexPath:(NSIndexPath *) indexPath
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _indexPath = indexPath;
    }
    return self;
}

- (NSArray *)assets
{
    if (!_assets) {
        _assets = [[NSMutableArray alloc]init];
    }
    return _assets;
}
- (NSMutableArray *)imgs
{
    if (!_imgs) {
        _imgs = [[NSMutableArray alloc]init];
    }
    return _imgs;
}
- (void) setData:(NSArray *)data
{
    [self.imgs removeAllObjects];
    self.assets = data;
    
    NSUInteger column = 3;
    
    //加一是为了有个添加照片的图片
    NSUInteger assetCount = data.count + 1;
    
    //判断如果图片大于等于６张的话就消失默认添加图片
    if (assetCount >=6 ) {
        assetCount = 6;
    }
    
    for (long i = 0; i < assetCount; i ++)
    {
        long row = i / column;
        long col = i % column;
        
        _image = [[UIImageView alloc]init];
        [_image setFrame:CGRectMake(55 + (15 * col), 10 + row * 15,15, 15)];
        [_image setContentMode:UIViewContentModeScaleAspectFill];
        [_image setUserInteractionEnabled:YES];
        
        if (i == data.count)
        {
            
            [_image addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(photoSelecte:)]];
        }
        else
        {
            //如果是本地ZLPhotoAssets就从本地获取,否侧从网络获取,　目前全是本地　后期可能会用到
            if ([[data objectAtIndex:i] isKindOfClass:[ZLPhotoAssets class]])
            {
                [_image setImage:[data[i] thumbImage]];
            }else if([[data objectAtIndex:i] isKindOfClass:[UIImage class]]){
                [_image setImage:data[i]];
            } else if ([[data objectAtIndex:i] isKindOfClass:[NSString class]]){
                //这里就用SDWebImage添加网络图片就可以！目前没有网络的这里不写!
            }
            [_image setTag:i];
            [_image addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBrowser:)]];
        }
        [self.contentView addSubview:_image];
        [self.imgs addObject:_image];
    }
    
    
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    if (self.indexPath.section == 0) {
        
        if (self.indexPath.row == 3) {
            
//            self.textLabel.top = -20;
        }
    }
    
    if (self.indexPath.section == 1) {
        
//        self.textLabel.top = -10;
    }
}

- (void)photoSelecte:(UITapGestureRecognizer *)tap
{
    [self.delegate photoSelectedImage];
}

- (void) tapBrowser:(UITapGestureRecognizer *)tap
{

    
    [self.delegate tapBrowser:[tap view].tag IndexPath:self.indexPath imagws:self.imgs];
    
}

@end
