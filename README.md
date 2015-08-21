
This is a photo album multiple-choice / photo browser example
--------------

#### 继承图片多选/图片浏览器/相机连拍的一套图片库
#### 新特性:浏览器支持屏幕旋转、优化了数据源。


### About Detached in PhotoLib (抽离PhotoLib)
`MLCamera 自定义相机连拍`[MLCamera](https://github.com/MakeZL/MLCamera)

`MLSelectPhoto 相册多选库` [MLSelectPhoto](https://github.com/MakeZL/MLSelectPhoto)

`MLPhotoBrowser 图片浏览器` [MLPhotoBrowser](https://github.com/MakeZL/MLPhotoBrowser)

Browser Continued in ...

### Demo Show
![image](https://github.com/MakeZL/ZLAssetsPickerDemo/blob/master/Demo_4.gif)
![image](https://github.com/MakeZL/ZLAssetsPickerDemo/blob/master/Demo_1.gif)
![image](https://github.com/MakeZL/ZLAssetsPickerDemo/blob/master/Demo_2.gif)

#### Recoder SelectedAssets/Limit SelectedAssets (记录/限制功能)
![image](https://github.com/MakeZL/ZLAssetsPickerDemo/blob/master/Demo_3.gif)

#### Custom ZLCamera (自定义相机连拍)
<img src="https://github.com/MakeZL/MLCamera/blob/master/screenshot.png" height="500" />

#### Not Power没权限
<img src="https://github.com/MakeZL/ZLAssetsPickerDemo/blob/master/DemoLock.png" height="500" />

相册多选
--------
    // 创建图片多选控制器
    ZLPhotoPickerViewController *pickerVc = [[ZLPhotoPickerViewController alloc] init];
    // 默认显示相册里面的内容SavePhotos
    pickerVc.status = PickerViewShowStatusSavePhotos;
    // 选择图片的最小数，默认是9张图片最大也是9张
    pickerVc.minCount = 4; 
    [pickerVc show];
    
    // block回调或者代理
    // 用block来代替代理
    pickerVc.delegate = self;    
    /**
     *
     传值可以用代理，或者用block来接收，以下是block的传值
     __weak typeof(self) weakSelf = self;
     pickerVc.callBack = ^(NSArray *assets){
        weakSelf.assets = assets;
        [weakSelf.tableView reloadData];
     };
     */    

    // 代理回调方法
    - (void)pickerViewControllerDoneAsstes:(NSArray *)assets{
      self.assets = assets;
      [self.tableView reloadData];
    }

ZLPhotoPickerBrowserViewController 图片游览器
----------
    ZLPhotoPickerBrowserViewController *pickerBrowser = [[ZLPhotoPickerBrowserViewController alloc] init];
    // 传入点击图片View的话，会有微信朋友圈照片的风格
    pickerBrowser.toView = cell.imageView;
    // 数据源/delegate
    pickerBrowser.delegate = self;
    pickerBrowser.dataSource = self;
    // 是否可以删除照片
    pickerBrowser.editing = YES;
    // 当前显示的分页数
    pickerBrowser.currentIndexPath = indexPath;
    // 展示控制器
    [pickerBrowser show];


ZLCameraViewController 自定义相机连拍
-----------
    ZLCameraViewController *cameraVc = [[ZLCameraViewController alloc] init];
    [cameraVc startCameraOrPhotoFileWithViewController:self complate:^(id object) {
        // to do.. 回调内容
    }];
    self.cameraVc = cameraVc;

# Contact
@weibo : [我的微博](http://weibo.com/makezl/)

# License

MLSelectPhoto is published under MIT License

    Copyright (c) 2015 MakeZL (@MakeZL)
    
    Permission is hereby granted, free of charge, to any person obtaining a copy of
    this software and associated documentation files (the "Software"), to deal in
    the Software without restriction, including without limitation the rights to use,
    copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
    Software, and to permit persons to whom the Software is furnished to do so,
    subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
    COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.