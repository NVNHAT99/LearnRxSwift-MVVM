//
//  CommonSearchView.swift
//  IOS-Challenge
//
//  Created by Nhat on 12/15/24.
//

import UIKit

class CommonSearchView: UIView {
    
    private let iconSearchView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search..."
        textField.borderStyle = .none
        textField.font = .systemFont(ofSize: 14)
        textField.textColor = .systemGray
        return textField
    }()
    
    var handleTextDidChange: ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(iconSearchView)
        addSubview(searchTextField)
        setupConstraints()
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.systemGray.cgColor
        
        self.searchTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
    }
    
    private func setupConstraints() {
        iconSearchView.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        
        let iconSearchConstraints: [NSLayoutConstraint] = [
            iconSearchView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            iconSearchView.heightAnchor.constraint(equalToConstant: 20),
            iconSearchView.widthAnchor.constraint(equalTo: iconSearchView.heightAnchor, multiplier: 1.0),
            iconSearchView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        
        let textFieldConstraints: [NSLayoutConstraint] = [
            searchTextField.leadingAnchor.constraint(equalTo: iconSearchView.trailingAnchor, constant: 4),
            searchTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            searchTextField.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            searchTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            searchTextField.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(iconSearchConstraints)
        NSLayoutConstraint.activate(textFieldConstraints)
    }
    
    @objc
    private func textFieldDidChange() {
        let finalText = searchTextField.text ?? ""
        handleTextDidChange?(finalText)
    }
}

extension CommonSearchView {
    func setTextfieldDelegate(_ delegate: UITextFieldDelegate) {
        self.searchTextField.delegate = delegate
    }
    
    func updateTextSearch(_ text: String) {
        self.searchTextField.text = text
    }
    
    func applySwipeTyping() {
        self.searchTextField.keyboardType = .default
        self.searchTextField.autocorrectionType = .yes
        self.searchTextField.spellCheckingType = .yes
    }
}
