
    // 创建控制器
    PickerViewController *pickerVc = [[PickerViewController alloc] init];
    pickerVc.delegate = self;
    [self presentViewController:pickerVc animated:YES completion:nil];


    // 代理回调方法
    - (void)pickerViewControllerDonePictures:(NSArray *)images{
        self.images = images;
        [self.tableView reloadData];
    }
