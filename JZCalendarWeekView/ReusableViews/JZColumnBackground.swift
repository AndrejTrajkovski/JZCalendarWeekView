import UIKit

open class JZColumnBackground: UICollectionReusableView {

	public override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = UIColor.red

	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
