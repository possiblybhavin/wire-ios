// 
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
// 


import Foundation
import Cartography

public struct AudioEffectCellBorders : OptionSetType {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let None   = AudioEffectCellBorders(rawValue: 0)
    public static let Right  = AudioEffectCellBorders(rawValue: 1 << 0)
    public static let Bottom = AudioEffectCellBorders(rawValue: 1 << 1)
}

@objc public final class AudioEffectCell: UICollectionViewCell {
    private let iconView = IconButton()
    private let borderRightView = UIView()
    private let borderBottomView = UIView()
    
    public var borders: AudioEffectCellBorders = [.None] {
        didSet {
            self.updateBorders()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        self.contentView.backgroundColor = UIColor.clearColor()
        self.clipsToBounds = false
        
        self.iconView.userInteractionEnabled = false
        [self.iconView, self.borderRightView, self.borderBottomView].forEach(self.contentView.addSubview)

        [self.borderRightView, self.borderBottomView].forEach { v in
            v.backgroundColor = UIColor(white: 1, alpha: 0.16)
        }
        
        constrain(self.contentView, self.iconView) { contentView, iconView in
            iconView.edges == contentView.edges
        }
        
        constrain(self.contentView, self.borderRightView, self.borderBottomView) { contentView, borderRightView, borderBottomView in

            borderRightView.bottom == contentView.bottom
            borderRightView.top == contentView.top
            borderRightView.right == contentView.right + 0.5
            borderRightView.width == 0.5
            
            borderBottomView.left == contentView.left
            borderBottomView.bottom == contentView.bottom + 0.5
            borderBottomView.right == contentView.right
            borderBottomView.height == 0.5
        }
        
        self.updateForSelectedState()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public static let reuseIdentifier: String = "AudioEffectCell"
    
    public override var reuseIdentifier: String? {
        get {
            return self.dynamicType.reuseIdentifier
        }
    }
    
    override public var selected: Bool {
        didSet {
            self.updateForSelectedState()
        }
    }
    
    private func updateBorders() {
        self.borderRightView.hidden = !self.borders.contains(.Right)
        self.borderBottomView.hidden = !self.borders.contains(.Bottom)
    }
    
    private func updateForSelectedState() {
        self.iconView.setIconColor(self.selected ? UIColor.accentColor() : UIColor.whiteColor(), forState: .Normal)
    }
    
    public var effect: AVSAudioEffectType = .None {
        didSet {
            self.iconView.setIcon(effect.icon, withSize: .Small, forState: .Normal)
            self.accessibilityLabel = effect.description
        }
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.effect = .None
        self.borders = .None
        self.updateForSelectedState()
    }
}