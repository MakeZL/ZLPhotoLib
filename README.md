
This is a photo album multiple-choice / photo browser example
--------------

* Demo Show
![](http://cc.cocimg.com/bbs/attachment/Fid_19/19_421709_3dcc945469f2d0e.gif)

相册多选
--------
    // 创建图片多选控制器
    PickerViewController *pickerVc = [[PickerViewController alloc] init];
    // 默认显示相册里面的内容SavePhotos
    PickerVc.status = PickerViewShowStatusSavePhotos;
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

ZLPickerBrowserViewController 图片游览器
----------
    ZLPickerBrowserViewController *pickerBrowser = [[ZLPickerBrowserViewController alloc] init];
    // 传入点击图片View的话，会有微信朋友圈照片的风格
    pickerBrowser.toView = cell.imageView;
    // 数据源/delegate
    pickerBrowser.delegate = self;
    pickerBrowser.dataSource = self;
    // 是否可以删除照片
    pickerBrowser.editing = YES;
    // 当前选中的值
    pickerBrowser.currentPage = indexPath.row;
    // 展示控制器
    [pickerBrowser show];

ZLCameraViewController 自定义相机连拍
-----------
    ZLCameraViewController *cameraVc = [[ZLCameraViewController alloc] init];
    [cameraVc startCameraOrPhotoFileWithViewController:self complate:^(id object) {
        // to do.. 回调内容
    }];
    self.cameraVc = cameraVc;
