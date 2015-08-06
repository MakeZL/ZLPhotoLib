// to do..
PickerViewController *pickerVc = [[PickerViewController alloc] init];
pickerVc.delegate = self;
[self presentViewController:pickerVc animated:YES completion:nil];

// Delegate
- (void)pickerViewControllerDonePictures:(NSArray *)images{
    self.images = images;
    [self.tableView reloadData];
}

