//
//  RyxFillProfileViewController.swift
//  FITogether
//
//  Created by closure on 11/27/14.
//  Copyright (c) 2014 closure. All rights reserved.
//

import UIKit
import CoreLocation

private enum SettingType : Int {
    case Height = 2
    case Age = 1
    case Location = 0
}

public class RyxFillProfileViewController : UITableViewController, UITextFieldDelegate, CTAssetsPickerControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, RyxFillPersonalMessageViewControllrDelegate, VPImageCropperDelegate, UIPickerViewDelegate, UIPickerViewDataSource, RyxSettingSelectViewDelegate {
   // @IBOutlet weak var genderSegmentControl: UISegmentedControl!
    @IBOutlet weak var locationTextField: UITextField!
   // @IBOutlet weak var locatingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var nextBarButton: UIBarButtonItem!
    @IBOutlet weak var heightTextField: UITextField!
    
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var avatarImageView: RyxRoundImageView!
    
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    
    @IBOutlet weak var personalMessageLabel: UILabel!
    
    private weak var targetTextField : UITextField? = nil
    
    private var selectedImage : UIImage? = nil
    
    private func __createSelectedView() -> RyxSettingSelectView! {
        var sv = RyxSettingSelectView(pickViewDataSource: self, pickViewDelegate: self, delegate: self)
        sv.frame = CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height)
        self.setupDataSource()
        self.view.window?.addSubview(sv)
        sv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("hiddenPickerView")))
        return sv
    }
    
    private var selectedView : RyxSettingSelectView!
    
    private var library = ALAssetsLibrary()
    
    private var isMale: Bool {
        get {
            return maleButton.selected
        }
    }
    
    private var lastLocation : CLLocation? = nil
    private var locationManager = RyxLocationManager.defaultManager()
    
    private class var numberOnly : String {
        get {
            return  "0123456789"
        }
    }
    
    private class var numberLimitLength : Int {
        get {
            return 3
        }
    }

    
    private var heightDataSource = [String]()
    private var ageDataSource = [String]()
    private var locationDataSource : [NSDictionary]!
    private var pickerViewDataSources : [Array<AnyObject>]!
    
    private var cities : [String]!
    
    private var activeTextField: UITextField? = nil
    private var activeString: String? = nil
    
    private var city = ""
    private var province = ""
    
    private var index = 0
    private var cityIndex = 0
    
    private var pickerDoneLastTime = false
    
    private var settingType: SettingType = .Location
    
    private func setupDataSource() {
        ageDataSource.removeAll(keepCapacity: true)
        heightDataSource.removeAll(keepCapacity: true)
        for i in 18..<80 {
            ageDataSource.append(String(i))
        }
        
        for i in 120..<240 {
            heightDataSource.append("\(i)")
        }
        
        let cityDict = NSJSONSerialization.JSONObjectWithData(NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("cities", ofType: "json")!)!, options: NSJSONReadingOptions.AllowFragments, error: nil) as NSDictionary
        self.locationDataSource = cityDict.objectForKey("cities") as [NSDictionary]
        self.pickerViewDataSources = [self.locationDataSource, self.ageDataSource, self.heightDataSource]
        self.cities = self.locationDataSource.first!.objectForKey("city") as [String]
        self.city = self.cities.first!
        self.province = self.locationDataSource.first!.objectForKey("province") as String
    }
    
    private func showPickerViewWithSettingType(settingType: SettingType) {
        switch settingType {
        case .Height:
            self.activeTextField = self.heightTextField
        case .Age:
            self.activeTextField = self.birthdayTextField
        case .Location:
            self.activeTextField = self.locationTextField
        }
        self.selectedView.pickView.reloadAllComponents()
        if settingType != .Location {
            self.selectedView.pickView.selectRow(self.activeTextField!.tag, inComponent: 0, animated: false)
        } else {
            if !pickerDoneLastTime {
                self.cities = self.locationDataSource[self.index].objectForKey("city") as [String]
                self.selectedView.pickView.selectRow(self.index, inComponent: 0, animated: false)
            } else {
                var strs = self.locationTextField.text.componentsSeparatedByString("  ") as [String]
                (province, city) = (strs.first!, strs.last!)
                for (idx, ds) in enumerate(self.locationDataSource) {
                    if ds.objectForKey("province") as String == province {
                        self.selectedView.pickView.selectRow(idx, inComponent: 0, animated: false)
                        self.cities = ds.objectForKey("city") as [String]
                        self.selectedView.pickView.selectRow(find(self.cities, city)!, inComponent: 1, animated: false)
                        break
                    }
                }
            }
        }
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.selectedView.transform = CGAffineTransformMakeTranslation(0, -self.selectedView.bounds.size.height)
        })
    }
    
    public func hiddenPickerView() {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.selectedView.transform = CGAffineTransformIdentity
        })
    }
    
    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let data = self.pickerViewDataSources[self.settingType.rawValue]
        if self.settingType != .Location {
            self.activeString = data[row] as? String
            if self.settingType == .Age {
                self.birthdayTextField.tag = row
            } else if self.settingType == .Height {
                self.heightTextField.tag = row
            }
            return
        }
        if component == 0 {
            let dict = data[row] as NSDictionary
            self.province = dict.objectForKey("province") as String
            self.index = row
            self.cities = self.locationDataSource[row].objectForKey("city") as [String]
            if self.cities.count <= self.cityIndex {
                self.city = cities.last!
            } else {
                self.city = cities[self.cityIndex]
            }
            pickerView.reloadComponent(1)
        } else if component == 1 {
            city = cities[row]
            cityIndex = row
        }
    }
    
    public func didClickDone() {
        if activeString != nil && settingType != .Location {
            self.pickerView(self.selectedView.pickView, didSelectRow: self.activeTextField!.tag, inComponent: 0)
        }
        
        switch settingType {
        case .Height:
            self.reloadTableView(height: activeString?.toInt())
        case .Age:
            self.reloadTableView(age: activeString?.toInt())
        case .Location:
            pickerDoneLastTime = true
            self.reloadTableView(location: "\(province)  \(city)")
        }
        
        self.hiddenPickerView()
    }
    
    public func didClickCancle() {
        self.hiddenPickerView()
    }
    
    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        if settingType != .Location {
            return 1
        }
        return 2
    }
    
    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let data = self.pickerViewDataSources[self.settingType.rawValue]
        if component == 0 {
            return data.count
        }
        return cities.count
    }
    
    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        let data = self.pickerViewDataSources[self.settingType.rawValue]
        if self.settingType != .Location {
            return data[row] as String
        }
        if component == 0 {
            let dict = data[row] as NSDictionary
            return dict.objectForKey("province") as String
        } else if component == 1 {
            return self.cities[row]
        }
        return ""
    }
    
    private func reloadTableView(height: Int? = -1, age: Int? = -1, location: String? = nil) {
        if height != nil && height! != -1 {
            self.heightTextField.text = String(height!)
        }
        if age != nil && age! != -1 {
            self.birthdayTextField.text = String(age!)
        }
        if location != nil && location! != "" {
            self.locationTextField.text = location!
        }
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if indexPath.section == 0 && (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2) {
            self.settingType = SettingType(rawValue: indexPath.row)!
            self.showPickerViewWithSettingType(self.settingType)
        }
    }

    public func presentImagePickerSheet() {
        let picker = CTAssetsPickerController()
        picker.delegate = self
        picker.assetsLibrary = self.library
        picker.assetsFilter = ALAssetsFilter.allPhotos()
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    public func assetsPickerController(picker: CTAssetsPickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        if assets.count > 0 {
            let asset = assets.first! as ALAsset
            let representation = asset.defaultRepresentation()
            self.selectedImage = UIImage(CGImage: representation.fullScreenImage().takeUnretainedValue(), scale: CGFloat(representation.scale()), orientation: UIImageOrientation.Up)
        }
        picker.dismissViewControllerAnimated(true, completion: { () -> Void in
            let vc = VPImageCropperViewController(image: self.selectedImage, cropFrame: CGRectMake(0, 100, self.view.bounds.size.width, self.view.bounds.size.width), limitScaleRatio: 10)
            vc.delegate = self
            self.presentViewController(vc, animated: true, completion: nil)
        })
    }
    
    @IBAction func selectSex(sender: UIButton) {
            //todo
        sender.selected = true
       // sender.enabled = false
        if (sender == self.maleButton) {
            self.femaleButton.selected = false
            self.femaleButton.enabled = true
        } else {
            self.maleButton.selected = false
            self.maleButton.enabled = true;
        }
//        var selectedImage = UIImage(named: "button_checkmark_selected");
//        var noSelectedImage = UIImage(named: "button_checkmark");
//        sender.setImage(noSelectedImage, forState: .Normal)
//        sender.setImage(selectedImage, forState: .Selected)
        
    }
    
//    // MARK: - RyxImagePickerSheetDelegate
//    public func imagePickerSheet(imagePickerSheet: RyxImagePickerSheet, titleForButtonAtIndex buttonIndex: Int) -> String {
//        var x : [String]!
//        if imagePickerSheet.numberOfSelectedPhotos > 1 {
//            x = ["Choose \(imagePickerSheet.numberOfSelectedPhotos) photos", "Photo Library", "Cancel"]
//        } else if imagePickerSheet.numberOfSelectedPhotos == 1 {
//            x = ["Choose \(imagePickerSheet.numberOfSelectedPhotos) photo", "Photo Library", "Cancel"]
//        } else {
//            x = ["Choose photo", "Photo Library", "Cancel"]
//        }
//        return  x[buttonIndex]
//    }
//    
//    public func imagePickerSheet(imagePickerSheet: RyxImagePickerSheet, willDismissWithButtonIndex buttonIndex: Int) {
//        if buttonIndex != imagePickerSheet.cancelButtonIndex {
//            if buttonIndex == 0 {
//                // choose
//                if imagePickerSheet.numberOfSelectedPhotos > 0 {
//                    imagePickerSheet.getSelectedImagesWithCompletion({ (images) -> Void in
//                        self.avatarImageView.image = images.first
//                        self.avatarImageView.noRound = false
//                        self.jumpToCropperViewController()
//                    })
//                }
//            } else if buttonIndex == 1 {
//                // photo library
//                self.presentSystemPickerController()
//            }
//        }
//    }
    
    func presentSystemPickerController() {
        let controller = UIImagePickerController()
        controller.delegate = self
        var sourceType: UIImagePickerControllerSourceType = .PhotoLibrary
        if (!UIImagePickerController.isSourceTypeAvailable(sourceType)) {
            sourceType = .PhotoLibrary
        }
        controller.sourceType = sourceType
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    // MARK: - VPImageCropperDelegate 
    public func imageCropper(cropperViewController: VPImageCropperViewController!, didFinished editedImage: UIImage!) {
        self.avatarImageView.image = editedImage
        self.avatarImageView.noRound = false
        self.selectedImage = nil
        cropperViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func imageCropperDidCancel(cropperViewController: VPImageCropperViewController!) {
        self.selectedImage = nil
        cropperViewController.dismissViewControllerAnimated(true, completion: nil)
    }
//    // MARK: - UIImagePickerControllerDelegate
//    
    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let image = info[UIImagePickerControllerEditedImage] as UIImage! {
            self.avatarImageView.image = image
        } else if let image = info[UIImagePickerControllerOriginalImage] as UIImage! {
            self.avatarImageView.image = image
        }
        self.avatarImageView.noRound = false
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private lazy var locationAction : RyxLocationManager.locationAction = { (location, error) -> Void in
        if error != nil {
            if error?.code == CLError.Denied.rawValue {
                self.checkLocationServiceAndNotifyUserIfNecessary()
                return
            }
            
            run {
                RSProgressHUD.showErrorWithStatus("加载失败")
            }
            return
        }
        if let l = location as CLLocation! {
            self.lastLocation = l
//            run {
//                let geocoder = CLGeocoder()
//                geocoder.reverseGeocodeLocation(l, completionHandler: { (results, error) -> Void in
//                    if let marker = results?.first as? CLPlacemark {
//                        self.locationTextField.text = "\(marker.subLocality) , \(marker.locality)"
//                    } else {
//                        self.locationTextField.text = ""
//                    }
//                })
//            }
            return
        }
    }
    
    private func checkLocationServiceAndNotifyUserIfNecessary() {
        let option = RyxOptions.option()
        
        if false == RyxLocationManager.locationServicesEnabled() {
            // error notify user! should open location service first !!!
        }
        
        switch CLLocationManager.authorizationStatus() {
        case .Authorized, .AuthorizedWhenInUse:
            return
        case .NotDetermined:
            self.locationManager.requestWhenInUseAuthorization()
        case .Restricted, .Denied:
            let alertController = UIAlertController(
                title: option.locationAccessDisabledError,
                message: option.locationAccessDisabledNotifyContent,
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: option.cancelString, style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: option.openSettingsContent, style: .Default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    private func startLocaiton() {
        self.locationManager.currentLocation(self.locationAction)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        let imageView = UIImageView(image: UIImage(named: "register_background")!)
        imageView.contentMode  = .ScaleToFill
        self.tableView.backgroundView = imageView
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("changeLocation:"), name: RyxLocationNotification.ChangeLocation.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("changeAuthorizationStatus:"), name: RyxLocationNotification.ChangeAuthorizationStatus.rawValue, object: nil)
        self.checkLocationServiceAndNotifyUserIfNecessary()
        self.startLocaiton()
        self.avatarImageView.noRound = true
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.selectedView.removeFromSuperview()
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if self.selectedView == nil {
            self.selectedView = self.__createSelectedView()
        }
        TalkingData.beginTrack(self.dynamicType)
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        TalkingData.endTrack(self.dynamicType)
    }
    
    public func changeLocation(notification: NSNotification?) {
    }
    
    public func changeAuthorizationStatus(notification: NSNotification?) {
        println("\(__FUNCTION__), \(notification)")
    }
    
    // MARK: - UITableViewDelegate
    public override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // MARK: - UITextFieldDelegate
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
    
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        self.targetTextField = textField
        if textField == self.heightTextField {
            let newLength = countElements(textField.text) + countElements(string) - range.length
            let cs = NSCharacterSet(charactersInString: RyxFillProfileViewController.numberOnly).invertedSet
            let filtered = (string.componentsSeparatedByCharactersInSet(cs) as NSArray).componentsJoinedByString("")
            
            let result = (string == filtered && newLength <= RyxFillProfileViewController.numberLimitLength)
            (dispatch_get_main_queue(), 1) ~>> {
                if (newLength >= RyxFillProfileViewController.numberLimitLength) && (string == filtered) {
                    textField.resignFirstResponder()
                }
            }
            return result
        }
        return true
    }
    
    @IBAction func nextButtonPressed(sender: UIBarButtonItem) {
        RSProgressHUD.showWithStatus("更新中...", maskType: RSProgressHUDMaskType.Gradient)
        var height = -1
        if let h = self.heightTextField.text.toInt() {
            height = h
        }
        var age = 18
        if let _age = self.birthdayTextField.text.toInt() {
            age = _age
        }
        if age <= 18 {
            age = 18
        }
        
        RyxAccountAccess.updateInfo(nil, gender: self.isMale ? 0 : 1, age: age, location: self.lastLocation, locationDescription: self.locationTextField.text, introduction: self.personalMessageLabel.text, height: height, weight: -1, avatar: self.avatarImageView.image?.compressPhoto()) { (account, error) -> Void in
            if error == nil {
                run {
                    RSProgressHUD.showSuccessWithStatus("完成")
                    RyxBranchViewControllerLoader.loadMainEntry(viewController: self)
//                    RyxBranchViewControllerLoader.loadMainEntry(true)

                }
                return
            } else {
                run {
                    RSProgressHUD.showErrorWithStatus("更新失败")
                }
                return
            }
        }
    }
    
    
    @IBAction func selectedIconImage(sender: UITapGestureRecognizer) {
        self.presentImagePickerSheet()
    }
 
    
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueForFillPersonalMessage" {
            if let target = segue.destinationViewController as? RyxFillPersonalMessageViewControllr {
                target.delegate = self
            }
        }
    }
    
    @IBAction func makeKeyboardDismissAction(sender: AnyObject) {
        self.targetTextField?.resignFirstResponder()
        self.targetTextField = nil
    }
    
    public func updatePersonalMessage(message: String?) {
        self.personalMessageLabel.text = message
    }
}
