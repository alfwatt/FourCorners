import Foundation
import CoreLocation
import MapKit
import KitBridge

/// A map annotation of an object, with a title, subtitle and icon
@objc(FCAnnotation)
open class FCAnnotation: NSObject, MKAnnotation {
    /// the object annotated
    public weak var representedObject: AnyObject?
    public var icon: ILImage?

    @objc public dynamic var coordinate: CLLocationCoordinate2D
    public let title: String?
    public let subtitle: String?

    public init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        super.init()
    }

    open override var description: String {
        "<FCAnnotation \(title ?? "-"), \(subtitle ?? "-") at \(CLLocationCoordinateFormatter.coordinateString(coordinate))>"
    }
}
