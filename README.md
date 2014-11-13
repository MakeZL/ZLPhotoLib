
    // 创建控制器
    PickerViewController *pickerVc = [[PickerViewController alloc] init];
    // 默认显示相册里面的内容SavePhotos
    PickerVc.status = PickerViewShowStatusSavePhotos;
    // 选择图片的最大数
    pickerVc.maxCount = 4; 
    [self presentViewController:pickerVc animated:YES completion:nil];
    
    // block回调或者代理
    // 用block来代替代理
    pickerVc.delegate = self;    
    
    /*
    __weak typeof(self) weakSelf = self;
    pickerVc.callBack = ^(NSArray *arr){
        weakSelf.images = arr;
        [weakSelf.tableView reloadData];
    };
    */

    // 代理回调方法
    - (void)pickerViewControllerDonePictures:(NSArray *)images{
        self.images = images;
        [self.tableView reloadData];
    }
