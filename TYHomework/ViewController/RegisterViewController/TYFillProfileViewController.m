//
//  RSFillProfileViewController.m
//  FITogether
//
//  Created by taoYe on 15/3/17.
//  Copyright (c) 2015年 closure. All rights reserved.
//

#import "TYFillProfileViewController.h"
#import <CTAssetsPickerController.h>
#import "TYFillPersonalMessageViewControllr.h"
#import "VPImageCropperViewController.h"
#import "RSSettingSelectView.h"
#import "TYRoundImageView.h"
#import <CoreLocation/CoreLocation.h>
#import "RSOptions.h"
#import "TYAccountAccess.h"
#import "UIImage+TY.h"
#import "TYViewControllerLoader.h"
#import "TYImageHelper.h"

typedef NS_ENUM(NSInteger, RSSettingType) {
    RSSettingTypeLocation = 0,
    RSSettingTypeAge = 1,
    RSSettingTypeHeight
};

@interface TYFillProfileViewController () <UITextFieldDelegate, CTAssetsPickerControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, TYFillPersonalMessageViewControllrDelegate, VPImageCropperDelegate, UIPickerViewDataSource, UIPickerViewDelegate, RSSettingSelectViewDelegate>

@property (nonatomic, weak) IBOutlet UITextField *locationTextField;
@property (nonatomic, weak) IBOutlet UITextField *heightTextField;
@property (nonatomic, weak) IBOutlet UITextField *birthdayTextField;
@property (nonatomic, weak) UITextField *targetTextField;
@property (nonatomic, strong) RSSettingSelectView *selectedView;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *nextBarButton;
@property (nonatomic, weak) IBOutlet TYRoundImageView *avatarImageView;

@property (nonatomic, weak) IBOutlet UIButton *maleButton;
@property (nonatomic, weak) IBOutlet UIButton *femaleButton;
@property (nonatomic, assign) BOOL isMale;

@property (nonatomic, weak) IBOutlet UILabel *personalMessageLabel;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) CLLocation *lastLocation;

@property (nonatomic, strong) ALAssetsLibrary *library;

@property (nonatomic, strong) NSMutableArray *heightDataSource;
@property (nonatomic, strong) NSMutableArray *ageDataSource;
@property (nonatomic, strong) NSMutableArray *locationDataSource;
@property (nonatomic, strong) NSMutableArray *cities;
@property (nonatomic, strong) UITextField *activeTextField;
@property (nonatomic, strong) NSString *activeString;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *province;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger cityIndex;
@property (nonatomic, assign) BOOL pickerDoneLastTime;
@property (nonatomic, assign) RSSettingType settingType;


@property (nonatomic, strong) NSArray *pickerViewDataSources;


@end

@implementation TYFillProfileViewController

- (RSSettingSelectView *)_createSelectedView {
    RSSettingSelectView *selectView = [RSSettingSelectView settingSelectViewWithPickViewDataSource:self pickViewDelegate:self delegate:self];
    selectView.frame = CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height);
    [self setupDataSource];
     [[UIApplication sharedApplication].keyWindow addSubview:selectView];
    [selectView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenPickerView)]];
    return selectView;
}

- (BOOL)isMale {
    return _maleButton.selected;
}

+ (NSString *)numberOnly {
    return @"0123456789";
}

+ (NSInteger)numberLimitLength {
    return 3;
}

- (void)setupDataSource {
    [_ageDataSource removeAllObjects];
    [_heightDataSource removeAllObjects];
    for (NSInteger i = 18; i < 80; i++) {
        [_ageDataSource addObject:[NSString stringWithFormat:@"%ld", (long)i]];
    }
    for (NSInteger i = 120; i < 240; i++) {
        [_heightDataSource addObject:[NSString stringWithFormat:@"%ld", (long)i]];
    }
    
    NSDictionary *cityDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cities" ofType:@"json"]] options:NSJSONReadingAllowFragments error:nil];
    _locationDataSource = cityDict[@"cities"];
    _pickerViewDataSources = @[_locationDataSource, _ageDataSource, _heightDataSource];
    _cities = [_locationDataSource firstObject][@"city"];
    _city = [_cities firstObject];
    _province = [_locationDataSource firstObject][@"province"];
}

- (void)showPickerViewWithSettingType:(RSSettingType)settingType {
    switch (settingType) {
        case RSSettingTypeHeight:
            _activeTextField = _heightTextField;
            break;
        case RSSettingTypeAge:
            _activeTextField = _birthdayTextField;
            break;
        case RSSettingTypeLocation:
            _activeTextField = _locationTextField;
            break;
        default:
            break;
    }
    [_selectedView.pickView reloadAllComponents];
    if (settingType != RSSettingTypeLocation) {
        [_selectedView.pickView selectRow:_activeTextField.tag inComponent:0 animated:NO];
    } else {
        if (!_pickerDoneLastTime) {
            _cities = _locationDataSource[_index][@"city"];
            [_selectedView.pickView selectRow:_index inComponent:0 animated:NO];
        } else {
           NSArray *strs = [_locationTextField.text componentsSeparatedByString:@"  "];
            _province = [strs firstObject];
            _city = [strs lastObject];
            for (NSInteger i = 0; i < _locationDataSource.count; i++) {
              NSDictionary *location =  _locationDataSource[i];
                if ([_province isEqualToString:location[@"province"]]) {
                    [_selectedView.pickView selectRow:i inComponent:0 animated:NO];
                    _cities = location[@"city"];
                    
                    for (NSInteger idx = 0; idx < _cities.count; idx++) {
                        if ([_city isEqualToString:_cities[idx]]) {
                            [_selectedView.pickView selectRow:idx inComponent:1 animated:NO];
                            break;
                        }
                    }
                    break;
                }
            }
        }
    }
    [UIView animateWithDuration:0.5 animations:^{
        _selectedView.transform = CGAffineTransformMakeTranslation(0, -_selectedView.bounds.size.height);
    }];
}

- (void)hiddenPickerView {
    [UIView animateWithDuration:0.5 animations:^{
        _selectedView.transform = CGAffineTransformIdentity;
    }];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSArray *data = _pickerViewDataSources[_settingType];
    if (_settingType != RSSettingTypeLocation) {
        _activeString = data[row];
        if (_settingType == RSSettingTypeAge) {
            _birthdayTextField.tag = row;
        } else if (_settingType == RSSettingTypeHeight) {
            _heightTextField.tag = row;
        }
        return;
    }
    if (component == 0) {
        NSDictionary *dict = data[row];
        _province = dict[@"province"];
        _index = row;
        _cities = _locationDataSource[row][@"city"];
        if (_cities.count <= _cityIndex) {
            _city = [_cities lastObject];
        } else {
            _city = _cities[_cityIndex];
        }
        [pickerView reloadComponent:1];
    } else if (component == 1) {
        _city = _cities[row];
        _cityIndex = row;
    }
}

- (void)didClickDone {
    if (_activeString != nil && _settingType != RSSettingTypeLocation) {
        [self pickerView:_selectedView.pickView didSelectRow:_activeTextField.tag inComponent:0];
    }
    switch (_settingType) {
        case RSSettingTypeHeight:
            [self reloadTableViewWithHeight:[_activeString integerValue] age:-1 locatoin:nil];
            break;
        case RSSettingTypeAge:
            [self reloadTableViewWithHeight:-1 age:[_activeString integerValue] locatoin:nil];
            break;
        case RSSettingTypeLocation:
            _pickerDoneLastTime = YES;
            [self reloadTableViewWithHeight:-1 age:-1 locatoin:[NSString stringWithFormat:@"%@  %@",_province, _city]];
            break;
        default:
            break;
    }
    [self hiddenPickerView];
}

- (void)didClickCancle {
    [self hiddenPickerView];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (_settingType != RSSettingTypeLocation) {
        return 1;
    }
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSMutableArray *data = _pickerViewDataSources[_settingType];
    if (!component) {
        return [data count];
    }
    return [_cities count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSMutableArray *data = _pickerViewDataSources[_settingType];
    if (_settingType != RSSettingTypeLocation) {
        return data[row];
    }
    if (!component) {
        NSDictionary *dict = data[row];
        return dict[@"province"];
    } else if (component == 1) {
        return _cities[row];
    }
    return @"";
}

- (void)reloadTableViewWithHeight:(NSInteger)height age:(NSInteger)age locatoin:(NSString *)location {
    if (height != -1) {
        [_heightTextField setText:[NSString stringWithFormat:@"%ld", (long)height]];
    }
    if (age != -1) {
        [_birthdayTextField setText:[NSString stringWithFormat:@"%ld", (long)age]];
    }
    if (location.length) {
        [_locationTextField setText:location];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([indexPath section] == 0 && ([indexPath row] == 0 ||
                                     [indexPath row] == 1 ||
                                     [indexPath row] == 2)) {
        _settingType = [indexPath row];
        [self showPickerViewWithSettingType:_settingType];
    }
}

- (void)presentImagePickerSheet {
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    [picker setDelegate:self];
    [picker setAssetsLibrary:_library];
    [picker setAssetsFilter:[ALAssetsFilter allPhotos]];
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    if ([assets count]) {
        ALAsset *asset = [assets firstObject];
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        [self setSelectedImage:[UIImage imageWithCGImage:[representation fullResolutionImage] scale:[representation scale] orientation:UIImageOrientationUp]];
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        VPImageCropperViewController *vc = [[VPImageCropperViewController alloc] initWithImage:[self selectedImage] cropFrame:CGRectMake(0, 100, [[self view] bounds].size.width, [[self view] bounds].size.width) limitScaleRatio:10];
        [vc setDelegate:self];
        [self presentViewController:vc animated:YES completion:nil];
    }];
}

- (IBAction)selectSex:(UIButton *)sender {
    [sender setSelected:YES];
    if (sender == [self maleButton]) {
        [[self femaleButton] setSelected:NO];
        [[self femaleButton] setEnabled:YES];
    } else {
        [[self maleButton] setSelected:NO];
        [[self maleButton] setEnabled:YES];
    }
}

- (void)presentSystemPickerController {
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    [controller setDelegate:self];
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [controller setSourceType:sourceType];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    [[self avatarImageView] setImage:editedImage];
    [[self avatarImageView] setNoRound:NO];
    [self setSelectedImage:nil];
    [cropperViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [self setSelectedImage:nil];
    [cropperViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if ([image isKindOfClass:[UIImage class]]) {
        [_avatarImageView setImage:image];
    } else if (image = info[UIImagePickerControllerOriginalImage], [image isKindOfClass:[UIImage class]]) {
        [_avatarImageView setImage:image];
    }
    [_avatarImageView setNoRound:NO];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _ageDataSource = [NSMutableArray array];
    _heightDataSource = [NSMutableArray array];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"register_background"]];
    [imageView setContentMode:UIViewContentModeScaleToFill];
    [[self tableView] setBackgroundView:imageView];
    [[self avatarImageView] setNoRound:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[self selectedView] removeFromSuperview];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![self selectedView]) {
        _selectedView = [self _createSelectedView];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    _targetTextField = textField;
    if (textField == _heightTextField) {
        NSInteger newLength = [[textField text] length] + [string length] - range.length;
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:[TYFillProfileViewController numberOnly]] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        BOOL result = ([string isEqualToString:filtered] && newLength <= [TYFillProfileViewController numberLimitLength]);
        run(^{
            if (newLength >= [TYFillProfileViewController numberLimitLength] && ([string isEqualToString:filtered])) {
                [textField resignFirstResponder];
            }
        });
        return result;
    }
    return YES;
}

- (IBAction)nextButtonPressed:(UIBarButtonItem *)sender {
    [RSProgressHUD showWithStatus:@"更新中..." maskType:RSProgressHUDMaskTypeGradient];
    NSInteger height = -1;
    if ([[_heightTextField text] length]) {
        height = [[_heightTextField text] integerValue];
    }
    NSInteger age = 18;
    if ([[_birthdayTextField text] length]) {
        age = [[_birthdayTextField text] integerValue];
    }
    if (age < 18) {
        age = 18;
    }
    
    [TYAccountAccess updateInfo:nil gender:[self isMale] ? 0 : 1 age:age location:_lastLocation locationDescription:[[self locationTextField] text] introduction:[[self personalMessageLabel] text] height:height weight:-1 avatar:[TYImageHelper setPhotoImage:self.avatarImageView.image] action:^(TYAccount *account, NSError *error) {
        if (error) {
            run(^{
                [RSProgressHUD showErrorWithStatus:@"更新失败"];
            });
            return;
        }
        run(^{
            [RSProgressHUD showSuccessWithStatus:@"完成"];
            [TYViewControllerLoader loadMainEntry];
        });
        return;
    }];
}

- (IBAction)selectedIconImage:(UITapGestureRecognizer *)sender {
    [self presentImagePickerSheet];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"segueForFillPersonalMessage"]) {
        TYFillPersonalMessageViewControllr *target = (TYFillPersonalMessageViewControllr *)[segue destinationViewController];
        if ([target isKindOfClass:[TYFillPersonalMessageViewControllr class]]) {
            [target setDelegate:self];
        }
    }
}

- (IBAction)makeKeyboardDismissAction:(id)sender {
    [_targetTextField resignFirstResponder];
    _targetTextField = nil;
}

- (void)updatePersonalMessage:(NSString *)message {
    [[self personalMessageLabel] setText:message];
}
@end
