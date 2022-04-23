//
//  CashierScreenViewController.swift
//  MeTechApp
//
//  Created by MacOS on 20.04.2022.
//

import UIKit

enum AmountOptions {
    case first
    case second
    case third
    case fourth
    
    var title: String {
        switch self {
        case .first:
            return "50"
        case .second:
            return "100"
        case .third:
            return "200"
        case .fourth:
            return "Diğer"
        }
    }
}

class CashierScreenViewController: UIViewController {
    
    // MARK: -- UI Items
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var formStackView: UIStackView!
    @IBOutlet weak var formStackViewVerticalConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    // MARK: -- Variables
    let amountOptions: [AmountOptions] = [.first, .second, .third, .fourth]
    var currentOption: AmountOptions! {
        didSet {
            self.collectionView.reloadData()
        }
    }

    var coreBManager: CoreBManager!
    let progressHUD = ProgressHUD(text: "Bağlanıyor...")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.priceTextField.isHidden = true
        self.priceTextField.addDoneButton()
        self.collectionViewSetup()
        self.coreBManager  = CoreBManager.shared
        // Create and add the view to the screen.
          
        progressHUD.show()
        self.view.addSubview(progressHUD)
         self.view.isUserInteractionEnabled = false
        self.didConnect()
        self.didUpdateValue()
    }
    
    func didConnect() {
        self.coreBManager.didConnect = { (isConnect: Bool) -> Void in
            if isConnect == true {
                self.progressHUD.hide()
                 self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    
    func didUpdateValue() {
        self.coreBManager.didUpdateValue = { (text: String) -> Void in
            let textComponents = text.components(separatedBy: "/")
            let dataType: DataType = textComponents[1] == DataType.amount.key ? DataType.amount : DataType.text
            if dataType == .text {
                self.formStackView.isHidden = true
                self.resultLabel.isHidden = false
                if textComponents.first == PaymentType.cancel.title {
                    self.resultLabel.text = "Müşteri siparişi iptal etmiştir"
                } else {
                    self.resultLabel.text = "Müşteri ödeme yapmıştır. Ödeme Bilgisi: \(textComponents.first)"
                }
            }
        }
    }
    
    func collectionViewSetup() {
        self.collectionView.register(UINib(nibName: "CashierScreenCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "CashierScreenCollectionViewCell")
        self.collectionView.isScrollEnabled = false
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (self.collectionView.bounds.width - 10) / 2, height: (self.collectionView.bounds.height - 10) / 2)
        self.collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    @objc func keyboardWillShow(sender: Notification) {
        self.formStackViewVerticalConstraint = self.formStackViewVerticalConstraint.setMultiplier(multiplier: 0.6)
        self.view.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide(sender: Notification) {
        self.formStackViewVerticalConstraint = self.formStackViewVerticalConstraint.setMultiplier(multiplier: 1.0)
        self.view.layoutIfNeeded()
    }
    
    
    // MARK: -- Actions
    
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.back()
    }
    
    @IBAction func sendButtonAction(_ sender: UIButton) {
        if self.coreBManager.connectedPeripheral != nil && self.coreBManager.characteristic != nil {
            var messageString: String!
            if self.currentOption == .fourth {
                if self.priceTextField.text?.isEmpty == false {
                    messageString = self.priceTextField.text
                } else {
                    return
                }
            } else {
                messageString = self.currentOption.title
            }
            if messageString.isEmpty == false {
                self.coreBManager.send(text: "\(messageString!)/\(DataType.amount.key)")
            }
        }
    }
    
    @IBAction func crashReportAction(_ sender: UIButton) {
        fatalError()
    }
    
    
    
    func selected(option: AmountOptions) {
        self.currentOption = option
        if self.currentOption == .fourth {
            self.priceTextField.isHidden = false
        } else {
            self.priceTextField.isHidden = true
        }
    }
}

// MARK: -- UICollectionView DataSource

extension CashierScreenViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.amountOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CashierScreenCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CashierScreenCollectionViewCell", for: indexPath) as! CashierScreenCollectionViewCell
        let option: AmountOptions = self.amountOptions[indexPath.row]
        cell.backgroundColor = option == currentOption ? .green : .yellow
        cell.titleLabel?.text = option.title
        return cell
    }
}

// MARK: -- UICollectionView FlowLayout Delegate

extension CashierScreenViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}

// MARK: -- UICollectionView Delegate

extension CashierScreenViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let option: AmountOptions = self.amountOptions[indexPath.row]
        self.selected(option: option)
    }
}
