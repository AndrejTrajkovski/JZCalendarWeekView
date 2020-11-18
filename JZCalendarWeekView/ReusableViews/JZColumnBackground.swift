import UIKit
import Util
import SwiftUI

open class JZColumnBackground: UICollectionReusableView {

	public override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = UIColor.init(Color.init(hex: "D8D8D8", alpha: 0.3))

	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
