//
//  LoginPageViewController.swift
//  kiolyn
//
//  Created by Chinh Nguyen on 3/10/17.
//  Copyright © 2017 Willbe Technology. All rights reserved.
//

import UIKit
import Material
import SnapKit
import RxSwift
import RxCocoa
import FontAwesomeKit
import MessageUI
import DRPLoadingSpinner

/// Convention
class LoginController: UIViewController {
    // The single instance of LoginController
    static var singleInstance = LoginController()
    
    fileprivate let theme =  Theme.loginTheme
    fileprivate let disposeBag = DisposeBag()
    
    // The background images
    fileprivate let backgroundImageView = UIImageView()
    // The application logo
    fileprivate let logoImageView = UIImageView()
    // Status labels
    fileprivate let statusView = UIStackView()
    // The name of current store
    fileprivate let storeNameLabel = UILabel()
    // The keyboard
    fileprivate let keyboard = LoginKeyboard()
    // The passkey input text field
    fileprivate let passkeyTextField = LoginTextField()
    // For displaying error message from Signin/Remote Sync
    fileprivate let errorLabel = UILabel()
    // For displaying loading indicator
    fileprivate let loading = DRPLoadingSpinner()
    // The website information
    fileprivate let websiteLabel = UILabel()
    // To enable store editing button
    fileprivate let editStoreIDButton = KLFlatButton()
    // The StoreID text field
    fileprivate let storeIDTextField = LoginTextField()
    // The clock icon
    fileprivate let clockIconLabel = UILabel()
    // The clockin button
    fileprivate let clockinButton = KLRaisedButton()
    // The clockout button
    fileprivate let clockoutButton = KLRaisedButton()
    // The progress of remote/local sync
    fileprivate let syncProgressLabel = UILabel()
    
    // The view model to contain application wiring logic
    lazy var viewModel: LoginViewModel = LoginViewModel()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        prepare()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    /// Prepare by settings view and wire functionalities with ViewModel
    fileprivate func prepare() {
        
        // MARK: - Statics

        // Background image view, this view acts as the root view also
        backgroundImageView.image = UIImage(named: "Background")
        backgroundImageView.alpha = 0.75
        backgroundImageView.contentMode = .scaleAspectFit
        backgroundImageView.isUserInteractionEnabled = true
        view.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // KIOLYN logo (Top/Left)
        logoImageView.image = UIImage(named: "Logo")
        logoImageView.contentMode = .scaleAspectFit
        view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalToSuperview().multipliedBy(0.2 * 0.47)
            make.top.equalToSuperview().offset(theme.guideline*2)
            make.leading.equalToSuperview()
        }

        // MARK: - Statuses
        
        statusView.axis = .vertical
        statusView.distribution = .equalSpacing
        statusView.alignment = .fill
        view.addSubview(statusView)
        statusView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-theme.guideline)
            make.leading.equalToSuperview().offset(theme.guideline)
            make.width.greaterThanOrEqualTo(220)
//            make.height.equalTo(statusLabelHeight * statusLabels.count)
        }

        let copyDeviceIDButton = KLRaisedButton()
        copyDeviceIDButton.titleColor = theme.secondary.base
        copyDeviceIDButton.title = "COPY DEVICE ID"
        statusView.addArrangedSubview(copyDeviceIDButton)
        copyDeviceIDButton.rx.tap
            .subscribe(onNext: { _ in
                UIPasteboard.general.string = self.viewModel.stationID
            })
            .disposed(by: disposeBag)

        let stationIDLabel = UILabel()
        stationIDLabel.text = "Device ID: \(viewModel.stationID)"
        
        let stationNameLabel = UILabel()
        viewModel.station
            .asDriver()
            .map { station in "Station: \(station?.name ?? "Not found")" }
            .drive(stationNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        let stationStatusLabel = UILabel()
        SP.stationManager.status
            .asDriver()
            .map { status in  "Status: \(status.asString)" }
            .drive(stationStatusLabel.rx.text)
            .disposed(by: disposeBag)

        let lastUpdatedLabel = UILabel()
        viewModel.lastUpdated
            .drive(lastUpdatedLabel.rx.text)
            .disposed(by: disposeBag)

        let ipLabel = UILabel()
        ipLabel.text = "IP: \(viewModel.ipAddress)"
        
        let versionLabel = UILabel()
        versionLabel.text = "Version: \(viewModel.version)"

        let statusLabels = [stationIDLabel, stationNameLabel, stationStatusLabel, lastUpdatedLabel, ipLabel, versionLabel]
        let statusLabelHeight = 24
        for l in statusLabels {
            l.font = theme.xsmallBoldFont
            l.textColor = theme.textColor
            l.snp.makeConstraints{ make in
                make.height.equalTo(statusLabelHeight)
            }
            statusView.addArrangedSubview(l)
        }
        
        // MARK: - Center area
        
        // Store name
        storeNameLabel.font = theme.titleBoldFont
        storeNameLabel.textColor = theme.textColor
        storeNameLabel.textAlignment = .center
        view.addSubview(storeNameLabel)
        storeNameLabel.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.6)
            make.height.greaterThanOrEqualTo(theme.titleHeight)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(theme.guideline*4)
        }
        viewModel.store
            .asDriver()
            .map { $0?.storeName }
            .drive(storeNameLabel.rx.text)
            .disposed(by: disposeBag)

        // Keyboard
        view.addSubview(keyboard)
        keyboard.snp.makeConstraints { make in
            make.width.equalTo(keyboard.expectedWidth)
            make.height.equalTo(keyboard.expectedHeight)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        keyboard.textFields = [passkeyTextField, storeIDTextField]
        viewModel.canRemoteSync
            .drive(keyboard.syncButton.rx.isEnabled)
            .disposed(by: disposeBag)
        keyboard.syncButton.rx.tap
            .bind(to: viewModel.remoteSync)
            .disposed(by: disposeBag)
        viewModel.viewStatus
            .asDriver()
            .map { $0.isNotLoading }
            .drive(keyboard.rx.isUserInteractionEnabled)
            .disposed(by: disposeBag)
        viewModel.canSignin
            .drive(keyboard.returnButton!.rx.isEnabled)
            .disposed(by: disposeBag)
        keyboard.returnButton!.rx.tap
            .bind(to: viewModel.signin)
            .disposed(by: disposeBag)
        
        // Passkey
        passkeyTextField.font = theme.xlargeInputFont
        passkeyTextField.set(placeholder: "PASSKEY")
        passkeyTextField.isSecureTextEntry = true
        view.addSubview(passkeyTextField)
        passkeyTextField.snp.makeConstraints { make in
            make.width.equalTo(keyboard.snp.width).multipliedBy(0.6)
            make.height.equalTo(theme.normalInputHeight)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(keyboard.snp.top).offset(-theme.guideline)
        }
        passkeyTextField.rx.text.orEmpty.changed
            .bind(to: viewModel.passkey)
            .disposed(by: disposeBag)
        passkeyTextField.rx.controlEvent(.editingDidEndOnExit)
            .bind(to: viewModel.signin)
            .disposed(by: disposeBag)

        // Error message
        errorLabel.isHidden = true
        errorLabel.numberOfLines = 3
        errorLabel.font = theme.normalBoldFont
        errorLabel.textColor = theme.warn.base
        errorLabel.textAlignment = .center
        view.addSubview(errorLabel)
        errorLabel.snp.makeConstraints { make in
            make.width.equalTo(keyboard.snp.width)
            make.height.greaterThanOrEqualTo(20.0)
            make.top.equalTo(keyboard.snp.bottom).offset(theme.guideline)
            make.centerX.equalToSuperview()
        }
        viewModel.viewStatus
            .asDriver()
            // Must revert this, isError = true ~ isHidden = false
            .map { status in status.isNotError }
            .drive(errorLabel.rx.isHidden)
            .disposed(by: disposeBag)
        viewModel.viewStatus
            .asDriver()
            .map { status in status.errorMessage }
            .drive(errorLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.viewStatus
            .asDriver()
            .filter { status in status.isError }
            .drive(onNext: { _ in _ = self.passkeyTextField.becomeFirstResponder() })
            .disposed(by: disposeBag)

        // Loading indicator
        loading.colorSequence = [theme.secondary.base]
        loading.lineWidth = 3
        loading.startAnimating()
        view.addSubview(loading)
        loading.snp.makeConstraints { make in
            make.top.equalTo(keyboard.snp.bottom).offset(theme.guideline)
            make.centerX.equalToSuperview()
        }
        viewModel.viewStatus
            .asDriver()
            .drive(onNext: { status in
                self.loading.isHidden = status.isNotLoading
                self.keyboard.isUserInteractionEnabled = status.isNotLoading
                self.keyboard.alpha = status.isLoading ? 0.5 : 1.0
            })
            .disposed(by: disposeBag)

        // Website linke
        websiteLabel.text = "kiolyn.com"
        websiteLabel.font = theme.normalBoldFont
        websiteLabel.textColor = theme.textColor
        websiteLabel.textAlignment = .center
        view.addSubview(websiteLabel)
        websiteLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-theme.guideline)
        }

        // Enable storeId button
        editStoreIDButton.setTitleColor(theme.textColor, for: .normal)
        editStoreIDButton.set(icon: FAKFontAwesome.pencilIcon(withSize: 20.0))
        view.addSubview(editStoreIDButton)
        editStoreIDButton.snp.makeConstraints { make in
            make.width.height.equalTo(theme.smallIconButtonWidth)
            make.trailing.equalToSuperview().offset(-theme.guideline)
            make.top.equalToSuperview().offset(theme.guideline)
        }
        editStoreIDButton.rx.tap
            .subscribe(onNext: { _ in
                self.storeIDTextField.isEnabled = true
                _ = self.storeIDTextField.becomeFirstResponder()
            })
            .disposed(by: disposeBag)

        // StoreID
        storeIDTextField.delegate = self
        storeIDTextField.font = theme.largeInputFont
        storeIDTextField.set(placeholder: "Store ID")
        storeIDTextField.textAlignment = .left
        view.addSubview(storeIDTextField)
        storeIDTextField.snp.makeConstraints { make in
            make.width.equalTo(180.0)
            make.height.equalTo(theme.normalInputHeight)
            make.trailing.equalTo(editStoreIDButton.snp.leading).offset(-theme.guideline/2)
            make.centerY.equalTo(editStoreIDButton.snp.centerY)
        }
        viewModel.storeID
            .asDriver()
            .drive(storeIDTextField.rx.text)
            .disposed(by: disposeBag)
        storeIDTextField.rx.text.orEmpty.changed
            .filter { _ in SP.stationManager.status.value.canChangeState }
            .bind(to: viewModel.storeID)
            .disposed(by: disposeBag)
        storeIDTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { _ in
                _ = self.passkeyTextField.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
        
        // Sync progress label
        syncProgressLabel.text = "100%"
        syncProgressLabel.font = theme.normalBoldFont
        syncProgressLabel.textColor = theme.warn.base
        syncProgressLabel.textAlignment = .center
        view.addSubview(syncProgressLabel)
        syncProgressLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-theme.guideline)
            make.bottom.equalToSuperview().offset(-theme.guideline)
        }
        viewModel.viewStatus
            .asDriver()
            .map { $0.progress.asPercentage }
            .drive(syncProgressLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.viewStatus
            .asDriver()
            .map { $0.progress == 0 }
            .drive(syncProgressLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        // vm.onSignedIn ==> change to main view
        SP.authService.currentIdentity
            .asDriver()
            .filter { $0 != nil }
            .drive(onNext: { _ in
                // Clean the passkey field text
                self.passkeyTextField.text = ""
                // ... and inside view model
                self.viewModel.passkey.accept("")
                // Show main screen
                self.change(root: MainController.singleInstance)
            })
            .disposed(by: disposeBag)

        // Clock icon
        clockIconLabel.textColor = theme.textColor
        clockIconLabel.fakIcon = FAKFontAwesome.clockOIcon(withSize: 20.0)
        view.addSubview(clockIconLabel)
        clockIconLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-60)
            make.centerY.equalToSuperview().offset(-80)
        }
        // Clockin
        clockinButton.title = "CLOCKIN"
        clockinButton.titleColor = theme.secondary.base
        view.addSubview(clockinButton)
        clockinButton.snp.makeConstraints { make in
            make.width.equalTo(HeightPreset.xxlarge.rawValue)
            make.height.equalTo(HeightPreset.large.rawValue)
            make.centerX.equalTo(clockIconLabel.snp.centerX)
            make.top.equalTo(clockIconLabel.snp.bottom).offset(theme.guideline*2)
        }
        viewModel.canClockin
            .drive(clockinButton.rx.isEnabled)
            .disposed(by: disposeBag)
        clockinButton.rx.tap
            .bind(to: viewModel.clockin)
            .disposed(by: disposeBag)
        
        // Clockout
        clockoutButton.title = "CLOCKOUT"
        clockoutButton.titleColor = theme.secondary.base
        view.addSubview(clockoutButton)
        clockoutButton.snp.makeConstraints { make in
            make.width.equalTo(HeightPreset.xxlarge.rawValue)
            make.height.equalTo(HeightPreset.large.rawValue)
            make.centerX.equalTo(clockIconLabel.snp.centerX)
            make.top.equalTo(clockinButton.snp.bottom).offset(theme.guideline*2)
        }
        viewModel.canClockout
            .drive(clockoutButton.rx.isEnabled)
            .disposed(by: disposeBag)
        clockoutButton.rx.tap
            .map { _ in nil }
            .bind(to: viewModel.clockout)
            .disposed(by: disposeBag)

        logoImageView.rx.tapGesture(numberOfTapsRequired: 2)
            .when(.recognized)
            .subscribe(onNext: { _ in self.sendLogFile() })
            .disposed(by: disposeBag)
        
        rx.viewDidAppear
            .subscribe(onNext: { _ in
                if self.viewModel.storeID.value.isEmpty {
                    self.storeIDTextField.isEnabled = true
                    _ = self.storeIDTextField.becomeFirstResponder()
                } else {
                    self.storeIDTextField.isEnabled = false
                    _ = self.passkeyTextField.becomeFirstResponder()
                }
            })
            .disposed(by: disposeBag)
        
        SP.stationManager.mainStation
            .asDriver()
            .skip(1) // The first initial value should not be count
            .filter { _ in !Configuration.standalone }
            .map { info in info?.1 }
            .drive(onNext: { mainStoreID in
                guard let mainStoreID = mainStoreID else {
                    self.storeIDTextField.text = ""
                    self.storeIDTextField.isEnabled = true
                    self.editStoreIDButton.isHidden = false
                    _ = self.storeIDTextField.becomeFirstResponder()
                    return
                }
                self.storeIDTextField.text = mainStoreID
                self.storeIDTextField.isEnabled = false
                self.editStoreIDButton.isHidden = true
                _ = self.passkeyTextField.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
    }
    
    private func sendLogFile() {
        guard MFMailComposeViewController.canSendMail() else {
            return derror("Please configure your email account.")
        }
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setToRecipients(["chinh.nguyen@willbe.vn"])
        var subject = "[KIOLYN] Log files"
        if let store = self.viewModel.store.value {
            subject += " for \(store.name)/\(store.id)"
        }
        if let station = self.viewModel.station.value {
            subject += " from \(station.name)/\(station.id)"
        }
        mail.setSubject("[KIOLYN] Log files")
        mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)

        do {
            let logFile = NSTemporaryDirectory().appending("kiolyn.log")
            let logData = try Data(contentsOf: URL(fileURLWithPath: logFile))
            mail.addAttachmentData(logData, mimeType: "text/txt", fileName: "kiolyn.log")
        } catch {
            derror("Could not read log file.")
        }

        self.present(mail, animated: true)
    }
}

extension LoginController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

extension LoginController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // If it is storeID, we only accept number
        if textField == storeIDTextField {
            return Int(string) != nil
        }
        return true
    }
}



