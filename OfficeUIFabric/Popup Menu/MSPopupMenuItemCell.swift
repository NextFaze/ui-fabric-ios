//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class MSPopupMenuItemCell: UITableViewCell {
    private struct Constants {
        static let oneLineHeight: CGFloat = 50.0
        static let twoLineHeight: CGFloat = 62.0

        static let horizontalSpacing: CGFloat = 16.0
        static let verticalSpacing: CGFloat = 2.0

        static let imageViewSize: CGFloat = 25.0
        static let selectedImageViewSize: CGFloat = 20.0

        static let titleFontStyle: MSTextStyle = .body
        static let subtitleFontStyle: MSTextStyle = .footnote

        static let defaultAlpha: CGFloat = 1.0
        static let highlightedAlpha: CGFloat = 0.4

        static let animationDuration: TimeInterval = 0.15
    }

    static let identifier: String = "MSPopupMenuItemCell"

    static func preferredWidth(for item: MSPopupMenuItem, preservingSpaceForImage preserveSpaceForImage: Bool) -> CGFloat {
        let titleSize = item.title.preferredSize(for: Constants.titleFontStyle.font)
        let subtitleSize = item.subtitle?.preferredSize(for: Constants.subtitleFontStyle.font) ?? .zero
        let labelAreaWidth = max(titleSize.width, subtitleSize.width)
        let spacing = Constants.horizontalSpacing

        var width = spacing + labelAreaWidth + spacing + Constants.selectedImageViewSize + spacing

        if item.image != nil || preserveSpaceForImage {
            width += Constants.imageViewSize + spacing
        }

        return width
    }

    static func preferredHeight(for item: MSPopupMenuItem) -> CGFloat {
        return item.subtitle == nil ? Constants.oneLineHeight : Constants.twoLineHeight
    }

    var isHeader: Bool = false {
        didSet {
            isUserInteractionEnabled = !isHeader
            updateAccessibilityTraits()
        }
    }
    var preservesSpaceForImage: Bool = false
    var showsSeparator: Bool = true {
        didSet {
            separator.isHidden = !showsSeparator
        }
    }

    private var item: MSPopupMenuItem?

    // Cannot use imageView since it exists in superclass
    private let _imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = MSColors.PopupMenu.Item.image
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.titleFontStyle.font
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.subtitleFontStyle.font
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let selectedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.staticImageNamed("checkmark-blue-20x20")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = MSColors.PopupMenu.Item.checkmark
        imageView.contentMode = .center
        return imageView
    }()

    private let separator = MSSeparator()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        selectionStyle = .none

        addSubview(_imageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(selectedImageView)
        addSubview(separator)

        isAccessibilityElement = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(item: MSPopupMenuItem) {
        self.item = item

        _imageView.image = item.image
        _imageView.highlightedImage = item.selectedImage
        _imageView.isHidden = _imageView.image == nil

        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle

        updateViews()

        var accessibilityString = "\(item.title)"
        if let subtitle = item.subtitle {
            accessibilityString.append(", \(subtitle)")
        }
        accessibilityLabel = accessibilityString
        updateAccessibilityTraits()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let leftOffset = safeAreaInsets.left
        var leftContentOffset = leftOffset + Constants.horizontalSpacing
        let rightOffset = bounds.width - safeAreaInsets.right
        let rightContentOffset = rightOffset - Constants.horizontalSpacing

        if !_imageView.isHidden || preservesSpaceForImage {
            _imageView.frame = CGRect(
                x: leftContentOffset,
                y: UIScreen.main.middleOrigin(bounds.height, containedSizeValue: Constants.imageViewSize),
                width: Constants.imageViewSize,
                height: Constants.imageViewSize
            )

            leftContentOffset += _imageView.width + Constants.horizontalSpacing
        }

        selectedImageView.frame = CGRect(
            x: rightContentOffset - Constants.selectedImageViewSize,
            y: UIScreen.main.middleOrigin(height, containedSizeValue: Constants.selectedImageViewSize),
            width: Constants.selectedImageViewSize,
            height: Constants.selectedImageViewSize
        )

        let separatorLeftOffset = isHeader ? leftOffset : leftContentOffset
        separator.frame = CGRect(x: separatorLeftOffset, y: bounds.height - separator.height, width: rightOffset - separatorLeftOffset, height: separator.height)

        var labelWidth = rightContentOffset - leftContentOffset
        if !selectedImageView.isHidden {
            labelWidth -= Constants.horizontalSpacing + selectedImageView.width
        }
        let titleLabelHeight = titleLabel.font.deviceLineHeight
        let subtitleLabelHeight = subtitleLabel.font.deviceLineHeight
        let isSubtitleVisible = subtitleLabel.text != nil
        var labelAreaHeight = titleLabelHeight
        if isSubtitleVisible {
            labelAreaHeight += Constants.verticalSpacing + subtitleLabelHeight
        }
        var labelTop = UIScreen.main.middleOrigin(bounds.height, containedSizeValue: labelAreaHeight)

        titleLabel.frame = CGRect(x: leftContentOffset, y: labelTop, width: labelWidth, height: titleLabelHeight)
        if isSubtitleVisible {
            labelTop += titleLabel.height + Constants.verticalSpacing
            subtitleLabel.frame = CGRect(x: leftContentOffset, y: labelTop, width: labelWidth, height: subtitleLabelHeight)
        }

        flipSubviewsForRTL()
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let oldValue = isHighlighted
        super.setHighlighted(highlighted, animated: animated)
        if isHighlighted == oldValue {
            return
        }

        // Override default background color change
        backgroundColor = .clear

        if animated {
            UIView.animate(withDuration: Constants.animationDuration) {
                self.updateViews()
            }
        } else {
            updateViews()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        let oldValue = isSelected
        super.setSelected(selected, animated: animated)
        if isSelected == oldValue {
            return
        }

        // Override default background color change
        backgroundColor = .clear

        if animated {
            UIView.animate(withDuration: Constants.animationDuration) {
                self.updateViews()
            }
        } else {
            updateViews()
        }
    }

    private func updateAccessibilityTraits() {
        if item?.isEnabled == false {
            accessibilityTraits.insert(.notEnabled)
        } else {
            accessibilityTraits.remove(.notEnabled)
        }

        if isHeader {
            accessibilityTraits.remove(.button)
            accessibilityTraits.insert(.header)
        } else {
            accessibilityTraits.insert(.button)
            accessibilityTraits.remove(.header)
        }
    }

    private func updateViews() {
        if item?.isEnabled == false {
            titleLabel.textColor = MSColors.PopupMenu.Item.titleDisabled
            subtitleLabel.textColor = MSColors.PopupMenu.Item.subtitleDisabled
        } else {
            // Highlight
            let alpha = isHighlighted ? Constants.highlightedAlpha : Constants.defaultAlpha
            _imageView.alpha = alpha
            titleLabel.alpha = alpha
            subtitleLabel.alpha = alpha

            // Selection
            _imageView.isHighlighted = isSelected
            titleLabel.textColor = isSelected ? MSColors.PopupMenu.Item.titleSelected : MSColors.PopupMenu.Item.title
            subtitleLabel.textColor = isSelected ? MSColors.PopupMenu.Item.subtitleSelected : MSColors.PopupMenu.Item.subtitle
        }
        selectedImageView.isHidden = !isSelected
    }
}
