//
//  SegmentedButton.swift
//  SegmentedButton
//
//  Created by Aleksei Sakharov on 14.12.17.
//  Copyright © 2017 Aleksei Sakharov. All rights reserved.
//

import Foundation

protocol SegmentedViewDelegate: class {
    func segmentedViewDidSelect(_ view: SegmentedView, index: Int)
}

class SegmentedView: UIView {
    
    weak var delegate: SegmentedViewDelegate?
    
    var stackView: UIStackView!
    
    var bgColor = UIColor(250, 250, 250)
    var normalColor = UIColor.clear
    var selectedColor = UIColor.tintBlue
    var titleSelectedColor = UIColor.white
    var titleNormalColor = UIColor.tintBlue
    
    private var isContraintsSetup = false
    
    private var selectionView: UIView?
    
    var titles: [String]? {
        didSet {
            setupButtons()
        }
    }
    
    var selectedIndex: Int? {
        didSet {
            selectIndex(selectedIndex)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    private func setup() {
        
        stackView = UIStackView(frame: self.bounds)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        backgroundColor = bgColor
        layer.cornerRadius = 6
    }
    
    private func setupButtons() {
        stackView.subviews.forEach { view in
            view.removeFromSuperview()
            selectionView?.removeFromSuperview()
            selectionView = nil
        }
        
        guard let titles = titles else { return }
        
        for (index, title) in titles.enumerated() {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: self.frame.size.height))
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightSemibold)
            button.setTitleColor(titleNormalColor, for: .normal)
            button.setTitleColor(titleSelectedColor, for: .selected)
            button.setTitle(title, for: .normal)
            button.tag = index
            button.backgroundColor = normalColor
            button.layer.cornerRadius = 6
            button.addTarget(self, action: #selector(buttonTouch(sender:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        
        selectionView = UIView(frame: CGRect.init(x: 0, y: 0, width: 0, height: self.frame.size.height))
        selectionView?.backgroundColor = selectedColor
        selectionView?.layer.cornerRadius = 6
        self.insertSubview(selectionView!, belowSubview: stackView)
    }
    
    private func selectIndex(_ index: Int?) {
        guard let selectionView = selectionView, let index = index else { return }
        
        var selectionFrame = selectionView.frame
        selectionFrame.origin.x = CGFloat(index) * selectionFrame.size.width

        let duration = 0.25
        
        UIView.animate(withDuration: duration, animations: {
            selectionView.frame = selectionFrame
        })
        
        stackView.subviews.forEach { v in
            let button = v as! UIButton
            UIView.transition(with: button, duration: duration, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                button.isSelected = button.tag == index
            }, completion: { _ in
                
            })
        }

    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        if !isContraintsSetup {
            let views: [String: Any] = ["stackView": stackView]
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[stackView]-0-|", options: [], metrics: nil, views: views))
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[stackView]-0-|", options: [], metrics: nil, views: views))
            isContraintsSetup = true
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let selectionView = selectionView, let titles = titles else {return}
        
        var selectionFrame = selectionView.frame
        selectionFrame.size.width = self.frame.size.width / CGFloat(titles.count)
        if let selectedIndex = selectedIndex {
            selectionFrame.origin.x = CGFloat(selectedIndex) * selectionFrame.size.width
        }
        selectionView.frame = selectionFrame
    }

    
    @objc private func buttonTouch(sender: UIButton) {
        selectedIndex = sender.tag
        delegate?.segmentedViewDidSelect(self, index: sender.tag)
    }
    
}
