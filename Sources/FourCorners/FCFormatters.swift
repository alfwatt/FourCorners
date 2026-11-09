import Foundation
import CoreLocation
#if canImport(AppKit)
import AppKit
#else
import UIKit
#endif
import KitBridge

/// The attributes of the parts of formatted locations
enum FCFormatterAttributes {
    /// units are smaller than their values
    static let unitScale: CGFloat = 0.8

    /// @returns the attributes of units, smaller and gray if they're in the control text color
    static func units(_ attributes: [NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any] {
        var units = cardinal(attributes)
        if let font = attributes[.font] as? ILFont, let smaller = ILFont(name: font.fontName, size: font.pointSize * unitScale) {
            units[.font] = smaller
        }
        return units
    }

    /// @returns the attributes of cardinal directions and symbols, gray if they're in the control text color
    static func cardinal(_ attributes: [NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any] {
        var cardinal = attributes
        if let color = attributes[.foregroundColor] as? ILColor, color.isEqual(ILColor.controlText) {
            cardinal[.foregroundColor] = ILColor.gray
        }
        return cardinal
    }

    /// @returns the attributes in the user's fixed pitch font
    static func monospace(_ attributes: [NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any] {
        var monospace = attributes
        let size = (attributes[.font] as? ILFont)?.pointSize ?? ILFont.applicationFontSize
        monospace[.font] = ILFont.userFixedPitchFont(ofSize: size) ?? ILFont.monospacedSystemFont(ofSize: size, weight: .regular)
        return monospace
    }

    /// a value in a monospaced font followed by its units
    static func value(_ value: String, units: String, attributes: [NSAttributedString.Key: Any]?) -> NSAttributedString {
        let monospace = Self.monospace(attributes ?? [:])
        let formatted = NSMutableAttributedString(string: value, attributes: monospace)
        formatted.append(NSAttributedString(string: units, attributes: Self.units(monospace)))
        return formatted
    }
}

func localized(_ key: String) -> String {
    NSLocalizedString(key, bundle: Bundle(for: FCLocationSource.self), comment: key)
}

// MARK: -

/// Formats distances in meters as mm, m or km
@objc(CLLocationDistanceFormatter)
open class CLLocationDistanceFormatter: Formatter, @unchecked Sendable {
    public static func distanceString(_ distance: CLLocationDistance) -> String {
        if distance == 0 || distance.isNaN { return "" }
        if distance < 0.25 { return String(format: "%.0f", distance * 1000) } // mm without rounding
        if distance < 2500 { return String(format: "%.1f", distance) } // m with one decimal
        return String(format: "%.2f", distance / 1000) // km
    }

    public static func unitsString(_ distance: CLLocationDistance) -> String {
        if distance == 0 || distance.isNaN { return localized("here") }
        if distance < 0.25 { return localized("mm") }
        if distance < 2500 { return localized("m") }
        return localized("km")
    }

    open override func string(for obj: Any?) -> String? {
        guard let distance = (obj as? NSNumber)?.doubleValue else { return nil }
        return Self.distanceString(distance) + Self.unitsString(distance)
    }

    open override func attributedString(for obj: Any, withDefaultAttributes attrs: [NSAttributedString.Key: Any]? = nil) -> NSAttributedString? {
        guard let distance = (obj as? NSNumber)?.doubleValue else { return nil }
        return FCFormatterAttributes.value(Self.distanceString(distance), units: Self.unitsString(distance), attributes: attrs)
    }
}

// MARK: -

/// Formats speeds in meters per second as mm/s, m/s or km/s
@objc(CLLocationSpeedFormatter)
open class CLLocationSpeedFormatter: Formatter, @unchecked Sendable {
    public static func speedString(_ speed: CLLocationSpeed) -> String {
        if speed == -1 { return "" } // still, or no speed from Core Location
        if speed < 0.25 { return String(format: "%.0f", speed * 1000) }
        if speed < 2500 { return String(format: "%.1f", speed) }
        return String(format: "%.2f", speed / 1000)
    }

    public static func unitsString(_ speed: CLLocationSpeed) -> String {
        if speed == -1 { return localized("still") }
        if speed < 0.25 { return localized("mm/s") }
        if speed < 2500 { return localized("m/s") }
        return localized("km/s")
    }

    open override func string(for obj: Any?) -> String? {
        guard let speed = (obj as? NSNumber)?.doubleValue else { return nil }
        return Self.speedString(speed) + Self.unitsString(speed)
    }

    open override func attributedString(for obj: Any, withDefaultAttributes attrs: [NSAttributedString.Key: Any]? = nil) -> NSAttributedString? {
        guard let speed = (obj as? NSNumber)?.doubleValue else { return nil }
        return FCFormatterAttributes.value(Self.speedString(speed), units: Self.unitsString(speed), attributes: attrs)
    }
}

// MARK: -

/// Formats locations as degrees and minutes, e.g. `N37° 46.4940' W122° 25.1940'`, and reads NMEA strings
@objc(CLLocationCoordinateFormatter)
open class CLLocationCoordinateFormatter: Formatter, @unchecked Sendable {
    /// e.g. `37.7749, -122.4194`
    public static func coordinateString(_ coordinate: CLLocationCoordinate2D) -> String {
        String(format: "%2.4f, %2.4f", coordinate.latitude, coordinate.longitude)
    }

    open override func string(for obj: Any?) -> String? {
        (obj as? CLLocation)?.latLonString
    }

    open override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String,
                                      errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        let location = FCLocation(nmeaString: string)
        obj?.pointee = location
        return location != nil
    }

    open override func attributedString(for obj: Any, withDefaultAttributes attrs: [NSAttributedString.Key: Any]? = nil) -> NSAttributedString? {
        guard let location = obj as? CLLocation else { return nil }
        let monospace = FCFormatterAttributes.monospace(attrs ?? [:])
        let cardinal = FCFormatterAttributes.cardinal(monospace)
        let formatted = NSMutableAttributedString()
        func append(_ string: String, _ attributes: [NSAttributedString.Key: Any]) {
            formatted.append(NSAttributedString(string: string, attributes: attributes))
        }
        append(String(location.latitudeHemisphere), cardinal)
        append(String(format: "%.0f", location.latitudeDegrees), monospace)
        append("°\u{00a0}", cardinal)
        append(String(format: "%2.4f", location.latitudeMinutes), monospace)
        append("' ", cardinal)
        append(String(location.longitudeHemisphere), cardinal)
        append(String(format: "%.0f", location.longitudeDegrees), monospace)
        append("°\u{00a0}", cardinal)
        append(String(format: "%2.4f", location.longitudeMinutes), monospace)
        append("'", cardinal)
        return formatted
    }
}

// MARK: -

/// Formats directions in degrees as the eight cardinal directions, e.g. `NE ~ 45°`
@objc(CLLocationDirectionFormatter)
open class CLLocationDirectionFormatter: Formatter, @unchecked Sendable {
    /// the eight directions, clockwise from north, with the directions they start at
    static let directions: [(start: CLLocationDirection, name: String, arrow: Character)] = [
        (FCDirection.northByNorthEast, "NE", FCCardinal.northEastArrow),
        (FCDirection.eastByNorthEast, "E", FCCardinal.eastArrow),
        (FCDirection.eastBySouthEast, "SE", FCCardinal.southEastArrow),
        (FCDirection.southBySouthEast, "S", FCCardinal.southArrow),
        (FCDirection.southBySouthWest, "SW", FCCardinal.southWestArrow),
        (FCDirection.westBySouthWest, "W", FCCardinal.westArrow),
        (FCDirection.westByNorthWest, "NW", FCCardinal.northWestArrow)
    ]

    /// the index of the
    /// @param direction provided in `directions`, nil for north
    static func directionIndex(_ direction: CLLocationDirection) -> Int? {
        let normalized = direction.truncatingRemainder(dividingBy: 360)
        guard normalized >= FCDirection.northByNorthEast, normalized < FCDirection.northByNorthWest else { return nil }
        return directions.lastIndex { normalized >= $0.start }
    }

    /// e.g. "NE", "-" when disoriented
    public static func bearingString(_ direction: CLLocationDirection) -> String {
        guard direction >= 0 else { return "-" }
        return localized(directionIndex(direction).map { directions[$0].name } ?? "N")
    }

    open override func string(for obj: Any?) -> String? {
        guard let bearing = obj as? NSNumber else { return nil }
        guard bearing.intValue != -1 else { return "-" }
        return "\(Self.bearingString(bearing.doubleValue)) ~ \(bearing.intValue)°"
    }

    open override func attributedString(for obj: Any, withDefaultAttributes attrs: [NSAttributedString.Key: Any]? = nil) -> NSAttributedString? {
        guard let bearing = obj as? NSNumber else { return nil }
        let monospace = FCFormatterAttributes.monospace(attrs ?? [:])
        let cardinal = FCFormatterAttributes.cardinal(monospace)
        guard bearing.intValue != -1 else { return NSAttributedString(string: "~", attributes: cardinal) }
        let formatted = NSMutableAttributedString(string: Self.bearingString(bearing.doubleValue) + " ~ ", attributes: cardinal)
        formatted.append(NSAttributedString(string: "\(bearing.intValue)", attributes: monospace))
        formatted.append(NSAttributedString(string: "°", attributes: cardinal))
        return formatted
    }
}

// MARK: -

/// Formats directions in degrees as arrows, e.g. `↗`
@objc(CLLocationDirectionArrowFormatter)
open class CLLocationDirectionArrowFormatter: Formatter, @unchecked Sendable {
    public static func bearingString(_ direction: CLLocationDirection) -> String {
        String(CLLocationDirectionFormatter.directionIndex(direction).map { CLLocationDirectionFormatter.directions[$0].arrow } ?? FCCardinal.northArrow)
    }

    open override func string(for obj: Any?) -> String? {
        guard let bearing = obj as? NSNumber else { return nil }
        return bearing.intValue == -1 ? "-" : Self.bearingString(bearing.doubleValue)
    }

    open override func attributedString(for obj: Any, withDefaultAttributes attrs: [NSAttributedString.Key: Any]? = nil) -> NSAttributedString? {
        guard let bearing = obj as? NSNumber else { return nil }
        let monospace = FCFormatterAttributes.monospace(attrs ?? [:])
        if bearing.intValue == -1 {
            return NSAttributedString(string: "-", attributes: FCFormatterAttributes.units(monospace))
        }
        return NSAttributedString(string: Self.bearingString(bearing.doubleValue), attributes: FCFormatterAttributes.cardinal(monospace))
    }
}

// MARK: -

/// Formats directions in degrees as the four kanji of the cardinal directions
@objc(CLLocationDirectionKanjiFormatter)
open class CLLocationDirectionKanjiFormatter: Formatter, @unchecked Sendable {
    public static func bearingString(_ direction: CLLocationDirection) -> String {
        let normalized = direction.truncatingRemainder(dividingBy: 360)
        switch normalized {
        case FCDirection.northEast..<FCDirection.southEast: return String(FCCardinal.eastKanji)
        case FCDirection.southEast..<FCDirection.southWest: return String(FCCardinal.southKanji)
        case FCDirection.southWest..<FCDirection.northWest: return String(FCCardinal.westKanji)
        default: return String(FCCardinal.northKanji)
        }
    }

    open override func string(for obj: Any?) -> String? {
        guard let bearing = obj as? NSNumber else { return "" }
        return bearing.intValue == -1 ? "-" : Self.bearingString(bearing.doubleValue)
    }

    open override func attributedString(for obj: Any, withDefaultAttributes attrs: [NSAttributedString.Key: Any]? = nil) -> NSAttributedString? {
        guard let bearing = obj as? NSNumber else { return nil }
        let monospace = FCFormatterAttributes.monospace(attrs ?? [:])
        if bearing.intValue == -1 {
            return NSAttributedString(string: "-", attributes: FCFormatterAttributes.units(monospace))
        }
        return NSAttributedString(string: Self.bearingString(bearing.doubleValue), attributes: FCFormatterAttributes.cardinal(monospace))
    }
}

// MARK: -

/// Formats locations as lines of a CSV log
@objc(FCLocationLogFormatter)
open class FCLocationLogFormatter: Formatter, @unchecked Sendable {
    /// the header of the log
    public static let header = "lat,lon,alt,hdop,vdop,speed,course,name,type"

    /// the log line of the
    /// @param location provided
    public static func logString(_ location: CLLocation) -> String {
        let fcLocation = location as? FCLocation
        return String(format: "%f,%f,%f,%f,%f,%f,%f,%@,%@", location.coordinate.latitude, location.coordinate.longitude, location.altitude,
                      location.horizontalAccuracy, location.verticalAccuracy, location.speed, location.course,
                      fcLocation?.name ?? "", fcLocation?.type ?? "")
    }

    open override func string(for obj: Any?) -> String? {
        guard let location = obj as? CLLocation else { return Self.header }
        return Self.logString(location)
    }
}
