//
//  BatchJobTableViewCell.swift
//  Kiolyn
//
//  Created by Chinh Nguyen on 5/22/18.
//  Copyright © 2018 Willbe Technology. All rights reserved.
//

import Foundation
import RxSwift
import DRPLoadingSpinner
import FontAwesomeKit

/// For displaying a close batch job row.
class CloseBatchJobTableViewCell: KLTableViewCell {
    let theme = Theme.light
    var disposeBag: DisposeBag?
    
    let name = UILabel()
    let message = UILabel()
    let loading = DRPLoadingSpinner()
    let check = UILabel()
    let error = UILabel()
    
    var job: CloseBatchJob? {
        didSet {
            disposeBag = DisposeBag()
            guard let job = job else {
                return
            }
            name.text = job.device?.name.uppercased() ?? "NO DEVICE"
            job.status
                .asDriver()
                .drive(onNext: { status in
                    self.loading.isHidden = status.isNotLoading
                    self.check.isHidden = status.isNotOK
                    self.error.isHidden = status.isNotError
                })
                .disposed(by: disposeBag!)
            
            job.status
                .asDriver()
                .map { status in
                    switch status {
                    case let .message(m): return m
                    case let .error(reason): return reason
                    case .ok: return "Closed batch successfully."
                    default: return "Closing batch ..."
                    }
                }
                .drive(message.rx.text)
                .disposed(by: disposeBag!)
        }
    }
    
    override func prepare() {
        super.prepare()
        
        name.textColor = theme.textColor
        name.font = theme.heading2BoldFont
        addSubview(name)
        name.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(theme.guideline)
            make.top.equalToSuperview().offset(theme.guideline/2)
            make.width.equalToSuperview().multipliedBy(0.75)
            make.height.equalToSuperview().multipliedBy(0.45)
        }
        
        message.numberOfLines = 2
        message.adjustsFontSizeToFitWidth = true
        message.minimumScaleFactor = 0.5
        message.textColor = theme.secondaryTextColor
        message.font = theme.normalFont
        addSubview(message)
        message.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(theme.guideline)
            make.bottom.equalToSuperview().offset(-theme.guideline/2)
            make.width.equalToSuperview().multipliedBy(0.75)
            make.height.equalToSuperview().multipliedBy(0.45)
        }
        
        loading.colorSequence = [theme.primary.base]
        loading.lineWidth = 3
        loading.startAnimating()
        addSubview(loading)
        loading.snp.makeConstraints { make in
            make.width.height.equalTo(theme.loadingSmallSize)
            make.trailing.equalToSuperview().offset(-theme.guideline)
            make.centerY.equalToSuperview()
        }
        
        check.textColor = theme.primary.base
        check.fakIcon = FAKFontAwesome.checkIcon(withSize: theme.smallButtonHeight/2)
        addSubview(check)
        check.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-theme.guideline)
            make.centerY.equalToSuperview()
        }
        
        error.textColor = theme.warn.base
        error.fakIcon = FAKFontAwesome.exclamationTriangleIcon(withSize: theme.smallButtonHeight/2)
        addSubview(error)
        error.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-theme.guideline)
            make.centerY.equalToSuperview()
        }
        
        let separator = KLSeparator(theme)
        addSubview(separator)
        separator.snp.makeConstraints { make in
            make.width.equalToSuperview().offset(-theme.guideline*2)
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
}
