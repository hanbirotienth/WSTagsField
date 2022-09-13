//
//  WSTagView.swift
//  Whitesmith
//
//  Created by Ricardo Pereira on 12/05/16.
//  Copyright © 2016 Whitesmith. All rights reserved.
//

import UIKit

open class WSTagView: UIView, UITextInputTraits {

    fileprivate let textLabel = UILabel()
    fileprivate let avatarLabel = UILabel()

    open var displayText: String = "" {
        didSet {
            updateLabelText()
            setNeedsDisplay()
        }
    }

    open var displayDelimiter: String = "" {
        didSet {
            updateLabelText()
            setNeedsDisplay()
        }
    }

    open var font: UIFont? {
        didSet {
            textLabel.font = font
            setNeedsDisplay()
        }
    }

    open var cornerRadius: CGFloat = 3.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            setNeedsDisplay()
        }
    }

    open var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
            setNeedsDisplay()
        }
    }

    open var borderColor: UIColor? {
        didSet {
            if let borderColor = borderColor {
                self.layer.borderColor = borderColor.cgColor
                self.layer.borderWidth = 0.5
                setNeedsDisplay()
            }
        }
    }

    open override var tintColor: UIColor! {
        didSet { updateContent(animated: false) }
    }

    /// Background color to be used for selected state.
    open var selectedColor: UIColor? {
        didSet { updateContent(animated: false) }
    }

    open var textColor: UIColor? {
        didSet { updateContent(animated: false) }
    }

    open var selectedTextColor: UIColor? {
        didSet { updateContent(animated: false) }
    }

    internal var onDidRequestDelete: ((_ tagView: WSTagView, _ replacementText: String?) -> Void)?
    internal var onDidRequestSelection: ((_ tagView: WSTagView) -> Void)?
    internal var onDidInputText: ((_ tagView: WSTagView, _ text: String) -> Void)?

    open var selected: Bool = false {
        didSet {
            if selected && !isFirstResponder {
                _ = becomeFirstResponder()
            }
            else if !selected && isFirstResponder {
                _ = resignFirstResponder()
            }
            updateContent(animated: true)
        }
    }

    // MARK: - UITextInputTraits

    public var autocapitalizationType: UITextAutocapitalizationType = .none
    public var autocorrectionType: UITextAutocorrectionType  = .no
    public var spellCheckingType: UITextSpellCheckingType  = .no
    public var keyboardType: UIKeyboardType = .default
    public var keyboardAppearance: UIKeyboardAppearance = .default
    public var returnKeyType: UIReturnKeyType = .next
    public var enablesReturnKeyAutomatically: Bool = false
    public var isSecureTextEntry: Bool = false

    // MARK: - Initializers

    public init(tag: WSTag) {
        super.init(frame: CGRect.zero)
        self.backgroundColor = .clear
        self.borderColor = tintColor
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true

        textColor = .white
        selectedColor = .gray
        selectedTextColor = .black
        
        self.avatarLabel.frame = CGRect(x: 1, y: 1, width: 30, height: 30)
        self.avatarLabel.font = font
        self.avatarLabel.textAlignment = .center
        self.avatarLabel.backgroundColor = .red
        self.avatarLabel.textColor = .white
        self.avatarLabel.layer.masksToBounds = true
        self.addSubview(self.avatarLabel)
        textLabel.frame = CGRect(x: self.avatarLabel.bounds.width + 5, y: layoutMargins.top, width: 0, height: 0)
        
        textLabel.font = font
        textLabel.textColor = .white
        textLabel.backgroundColor = .clear
        addSubview(textLabel)

        self.displayText = tag.text
        updateLabelText()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer))
        addGestureRecognizer(tapRecognizer)
        setNeedsLayout()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        assert(false, "Not implemented")
    }

    // MARK: - Styling

    fileprivate func updateColors() {
        self.backgroundColor = selected ? tintColor : .clear
        self.borderColor = selected ? .clear : tintColor
        textLabel.textColor = textColor
    }

    internal func updateContent(animated: Bool) {
        guard animated else {
            updateColors()
            return
        }

        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                self?.updateColors()
                if self?.selected ?? false {
                    self?.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                }
            },
            completion: { [weak self] _ in
                if self?.selected ?? false {
                    UIView.animate(withDuration: 0.1) { [weak self] in
                        self?.transform = CGAffineTransform.identity
                    }
                }
            }
        )
    }

    // MARK: - Size Measurements

    open override var intrinsicContentSize: CGSize {
        let labelIntrinsicSize = textLabel.intrinsicContentSize
        return CGSize(width: textLabel.frame.origin.x + labelIntrinsicSize.width + layoutMargins.left + layoutMargins.right,
                      height: labelIntrinsicSize.height + layoutMargins.top + layoutMargins.bottom)
    }

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        let layoutMarginsHorizontal = layoutMargins.left + layoutMargins.right
        let layoutMarginsVertical = layoutMargins.top + layoutMargins.bottom
        let fittingSize = CGSize(width: size.width - layoutMarginsHorizontal,
                                 height: size.height - layoutMarginsVertical)
        let labelSize = textLabel.sizeThatFits(fittingSize)
        return CGSize(width: textLabel.frame.origin.x + labelSize.width + layoutMarginsHorizontal,
                      height: labelSize.height + layoutMarginsVertical)
    }

    open func sizeToFit(_ size: CGSize) -> CGSize {
        if intrinsicContentSize.width > size.width {
            return CGSize(width: size.width,
                          height: intrinsicContentSize.height)
        }
        return intrinsicContentSize
    }

    // MARK: - Attributed Text
    fileprivate func updateLabelText() {
        // Unselected shows "[displayText]," and selected is "[displayText]"
        textLabel.text = displayText + displayDelimiter
        // Expand Label
        self.avatarLabel.backgroundColor = displayText.colorFromCharacter()
        self.avatarLabel.text = (displayText.first?.description ?? "?").uppercased()
        let intrinsicSize = self.intrinsicContentSize
        frame = CGRect(x: 0, y: 0, width: intrinsicSize.width, height: intrinsicSize.height)
    }

    // MARK: - Laying out
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.avatarLabel.frame = CGRect(x: 1, y: 1, width: self.intrinsicContentSize.height - 2, height: self.intrinsicContentSize.height - 2)
        self.avatarLabel.layer.cornerRadius = self.avatarLabel.frame.width / 2
        textLabel.frame = CGRect(x: self.avatarLabel.bounds.width + 5, y: layoutMargins.top, width: bounds.inset(by: layoutMargins).width, height: bounds.inset(by: layoutMargins).height)
        if frame.width == 0 || frame.height == 0 {
            frame.size = CGSize(width: textLabel.frame.origin.y + textLabel.frame.width, height:  self.intrinsicContentSize.height)
        }
        self.layer.cornerRadius = frame.height / 2
        
        self.borderColor = selected ? selectedTextColor : tintColor
    }

    // MARK: - First Responder (needed to capture keyboard)
    open override var canBecomeFirstResponder: Bool {
        return true
    }

    open override func becomeFirstResponder() -> Bool {
        let didBecomeFirstResponder = super.becomeFirstResponder()
        selected = true
        return didBecomeFirstResponder
    }

    open override func resignFirstResponder() -> Bool {
        let didResignFirstResponder = super.resignFirstResponder()
        selected = false
        return didResignFirstResponder
    }

    // MARK: - Gesture Recognizers
    @objc func handleTapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        if selected {
            return
        }
        onDidRequestSelection?(self)
    }

}

extension WSTagView: UIKeyInput {

    public var hasText: Bool {
        return true
    }

    public func insertText(_ text: String) {
        onDidInputText?(self, text)
    }

    public func deleteBackward() {
        onDidRequestDelete?(self, nil)
    }

}



let kArrayColor:[String: String] = [
 "A": "#1ABC9C",
 "B": "#16A085",
 "C": "#F1C40F",
 "D": "#F39C12",
 "E": "#2ECC71",
 "F": "#27AE60",
 "G": "#27AE60",
 "H": "#D35400",
 "I": "#3498DB",
 "J": "#2980B9",
 "K": "#E74C3C",
 "L": "#C0392B",
 "M": "#9B59B6",
 "N": "#8E44AD",
 "O": "#BDC3C7",
 "P": "#34495E",
 "Q": "#2C3E50",
 "R": "#95A5A6",
 "S": "#7F8C8D",
 "T": "#EC87BF",
 "U": "#D870AD",
 "V": "#F69785",
 "W": "#9BA37E",
 "X": "#B49255",
 "Y": "#B49255",
 "Z": "#A94136",
]

extension String {
    func colorFromCharacter() -> UIColor {
        if let first = self.first, let hex = kArrayColor["\(first)".uppercased()]  {
            return UIColor(hexString: hex)
        }
        return UIColor(hexString: "#7F8C8D")
    }
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
    
}
