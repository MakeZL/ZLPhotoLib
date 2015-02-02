
This is a photo album multiple-choice / photo browser example
--------------

### Demo Show
#### UICollectionView
![image](https://github.com/MakeZL/ZLAssetsPickerDemo/blob/master/screenshot1.gif)

#### UITableView
![image](https://github.com/MakeZL/ZLAssetsPickerDemo/blob/master/screenshot2.gif)

#### Custom ZLCamera
![image](https://github.com/MakeZL/ZLAssetsPickerDemo/blob/master/screenshot4.png)

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

### ZLPhotoPickerBrowser - DataSource
    /**
     *  有多少组
     */
    - (NSInteger) numberOfSectionInPhotosInPickerBrowser:(ZLPhotoPickerBrowserViewController *) pickerBrowser;
    /**
     *  每个组多少个图片
     */
    - (NSInteger) photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser numberOfItemsInSection:(NSUInteger)section;
    /**
     *  每个对应的IndexPath展示什么内容
     */
    - (ZLPhotoPickerBrowserPhoto *)photoBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoAtIndexPath:(NSIndexPath *)indexPath;

ZLCameraViewController 自定义相机连拍
-----------
    ZLCameraViewController *cameraVc = [[ZLCameraViewController alloc] init];
    [cameraVc startCameraOrPhotoFileWithViewController:self complate:^(id object) {
        // to do.. 回调内容
    }];
    self.cameraVc = cameraVc;
