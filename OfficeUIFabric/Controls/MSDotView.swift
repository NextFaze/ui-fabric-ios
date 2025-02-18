//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

open class MSDotView: UIView {
    @objc open var color: UIColor? = MSColors.black {
        didSet {
            if oldValue != color {
                setNeedsDisplay()
            }
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func draw(_ rect: CGRect) {

        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        (color ?? UIColor.clear).set()
        context.addEllipse(in: bounds)
        context.fillPath()
    }
}
