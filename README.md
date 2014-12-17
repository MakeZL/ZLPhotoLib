
    // 创建图片多选控制器
    PickerViewController *pickerVc = [[PickerViewController alloc] init];
    // 默认显示相册里面的内容SavePhotos
    PickerVc.status = PickerViewShowStatusSavePhotos;
    // 选择图片的最小数，默认是9张图片最大也是9张
    pickerVc.minCount = 4; 
    [self presentViewController:pickerVc animated:YES completion:nil];
    
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

    // 图片游览器
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

    #pragma mark - 自定义动画
    // 你也可以自定义动画
    // 参考BaseAnimationView
    - (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
        UIView *boxView = [[UIView alloc] init];
        boxView.backgroundColor = [UIColor redColor];

        NSDictionary *options = @{
                                  UIViewAnimationInView:self.view,
                                  UIViewAnimationToView:boxView,
                                  };

    
        [ZLAnimationBaseView animationViewWithOptions:options animations:^{
            // TODO .. 执行动画时
        } completion:^(ZLAnimationBaseView *baseView) {
            // TODO .. 动画执行完时
        }];
    }
