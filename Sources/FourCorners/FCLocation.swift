import Foundation
import CoreLocation
import Security
import KitBridge

// MARK: - Cardinal Directions

/// The characters of the cardinal directions: letters, arrows and kanji
public enum FCCardinal {
    public static let north: Character = "N"
    public static let south: Character = "S"
    public static let east: Character = "E"
    public static let west: Character = "W"

    public static let northArrow: Character = "\u{2191}"
    public static let southArrow: Character = "\u{2193}"
    public static let eastArrow: Character = "\u{2192}"
    public static let westArrow: Character = "\u{2190}"
    public static let northWestArrow: Character = "\u{2196}"
    public static let northEastArrow: Character = "\u{2197}"
    public static let southEastArrow: Character = "\u{2198}"
    public static let southWestArrow: Character = "\u{2199}"

    public static let northKanji: Character = "\u{5317}"
    public static let southKanji: Character = "\u{5357}"
    public static let eastKanji: Character = "\u{6771}"
    public static let westKanji: Character = "\u{897F}"
}

// MARK: - Compass Directions

/// Compass directions in degrees, clockwise from north
public enum FCDirection {
    /// no direction
    public static let disoriented: CLLocationDirection = -1
    public static let north: CLLocationDirection = 0
    public static let northEast: CLLocationDirection = 45
    public static let east: CLLocationDirection = 90
    public static let southEast: CLLocationDirection = 135
    public static let south: CLLocationDirection = 180
    public static let southWest: CLLocationDirection = 225
    public static let west: CLLocationDirection = 270
    public static let northWest: CLLocationDirection = 315

    // the boundaries between the eight directions
    public static let northByNorthEast: CLLocationDirection = 22.5
    public static let eastByNorthEast: CLLocationDirection = 67.5
    public static let eastBySouthEast: CLLocationDirection = 112.5
    public static let southBySouthEast: CLLocationDirection = 157.5
    public static let southBySouthWest: CLLocationDirection = 202.5
    public static let westBySouthWest: CLLocationDirection = 247.5
    public static let westByNorthWest: CLLocationDirection = 292.5
    public static let northByNorthWest: CLLocationDirection = 337.5

    /// @returns a random direction, or `disoriented` if there's no randomness to be had
    public static func random() -> CLLocationDirection {
        var bits: UInt16 = 0 // two bytes of entropy is sufficient, thousands of directions
        guard SecRandomCopyBytes(kSecRandomDefault, MemoryLayout<UInt16>.size, &bits) == errSecSuccess else { return disoriented }
        return 360 * Double(bits) / Double(UInt16.max)
    }
}

// MARK: - Distances

/// Useful distances in meters
public enum FCDistance {
    public static let meter: CLLocationDistance = 1
    public static let kilometer: CLLocationDistance = 1000

    /// The radius of the Earth per WGS 84
    public static let earthRadius: CLLocationDistance = 6_378_137.0
    /// The semi-minor axis of the Earth per WGS 84
    public static let earthSemiMinorAxis: CLLocationDistance = 6_356_752.314245
    /// The 1/F flattening of the Earth per WGS 84
    public static let earthFlattening: Double = 298.257223563

    /// The altitude of geostationary orbits, https://en.wikipedia.org/wiki/Geostationary_orbit
    public static let geostationaryAltitude: CLLocationDistance = 35_786_000
    /// The mean distance between the Earth and the Sun, https://en.wikipedia.org/wiki/Astronomical_unit
    public static let astronomicalUnit: CLLocationDistance = 149_597_870_700
    /// The distance light travels in a second, https://en.wikipedia.org/wiki/Light-second
    public static let lightSecond: CLLocationDistance = 299_792_458
    /// The distance light travels in a Julian year, https://en.wikipedia.org/wiki/Light-year
    public static let lightYear: CLLocationDistance = 9_460_730_472_580_800
}

// MARK: - Circular Error

/// Circular error probabilities, https://en.wikipedia.org/wiki/Circular_error_probable
public enum FCCircularError: Double, CaseIterable, Sendable {
    /// circular error probable, 50%
    case cep50 = 0.5
    /// distance root mean square
    case drms = 0.63213
    /// twice the distance root mean square
    case twoDRMS = 0.98169
    /// 95%
    case r95 = 0.95
    /// 99.7%
    case r997 = 0.997

    /// the radius, relative to the root mean square, https://en.wikipedia.org/wiki/Circular_error_probable#Conversion
    private var rmsRadius: Double {
        switch self {
        case .cep50: 1.1774
        case .drms: 1.4142
        case .twoDRMS: 2.8284
        case .r95: 2.4477
        case .r997: 3.4086
        }
    }

    /// @returns the
    /// @param distance of an error at this probability converted to the probability of the
    /// @param other error provided
    public func convert(_ distance: CLLocationDistance, to other: FCCircularError) -> CLLocationDistance {
        distance * other.rmsRadius / rmsRadius
    }
}

// MARK: - Coordinates

public extension CLLocationCoordinate2D {
    /// @returns the great circle bearing to the
    /// @param destination provided
    func bearing(to destination: CLLocationCoordinate2D) -> CLLocationDirection {
        let lat1 = latitude * .pi / 180, lat2 = destination.latitude * .pi / 180
        let deltaLon = (destination.longitude - longitude) * .pi / 180
        let y = sin(deltaLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon)
        let bearing = atan2(y, x) * 180 / .pi
        return bearing < 0 ? bearing + 360 : bearing
    }

    /// @returns the coordinate at the
    /// @param distance provided along the
    /// @param bearing provided from this one
    func coordinate(atDistance distance: CLLocationDistance, bearing: CLLocationDirection) -> CLLocationCoordinate2D {
        let lat1 = latitude * .pi / 180, lon1 = longitude * .pi / 180
        let direction = bearing * .pi / 180
        let angle = distance / FCDistance.earthRadius
        let lat2 = asin(sin(lat1) * cos(angle) + cos(lat1) * sin(angle) * cos(direction))
        var lon2 = lon1 + atan2(sin(direction) * sin(angle) * cos(lat1), cos(angle) - sin(lat1) * sin(lat2))
        lon2 = fmod(lon2 + 3 * .pi, 2 * .pi) - .pi
        return CLLocationCoordinate2D(latitude: lat2 * 180 / .pi, longitude: lon2 * 180 / .pi)
    }
}

// MARK: - Notifications

public extension Notification.Name {
    /// the location of this device updated, the object is the location
    static let FCLocationUpdate = Notification.Name("LocationUpdate")
    /// the location was forgotten
    static let FCLocationForgotten = Notification.Name("LocationForgotten")
    /// the location of a tracked object updated
    static let FCLocationTracked = Notification.Name("LocationTracked")
    /// the location was geocoded into placemarks
    static let FCLocationGeocoded = Notification.Name("FCLocationGeocodedNotification")
}

// MARK: - CLLocation

public extension CLLocation {
    var latitudeHemisphere: Character { coordinate.latitude < 0 ? FCCardinal.south : FCCardinal.north }
    var latitudeDegrees: CLLocationDegrees { abs(coordinate.latitude).rounded(.down) }
    var latitudeMinutes: CLLocationDegrees { (abs(coordinate.latitude) * 60).truncatingRemainder(dividingBy: 60) }
    var latitudeSeconds: CLLocationDegrees { (abs(coordinate.latitude) * 3600).truncatingRemainder(dividingBy: 60) }

    var longitudeHemisphere: Character { coordinate.longitude < 0 ? FCCardinal.west : FCCardinal.east }
    var longitudeDegrees: CLLocationDegrees { abs(coordinate.longitude).rounded(.down) }
    var longitudeMinutes: CLLocationDegrees { (abs(coordinate.longitude) * 60).truncatingRemainder(dividingBy: 60) }
    var longitudeSeconds: CLLocationDegrees { (abs(coordinate.longitude) * 3600).truncatingRemainder(dividingBy: 60) }

    /// the distance from the core location source's current location, nil if it doesn't know where it is
    var distanceFromHere: CLLocationDistance? {
        let source = FCLocationSource.core
        guard source.knowsCurrentLocation, let here = source.currentLocation else { return nil }
        return distance(from: here)
    }

    /// the direction from the core location source's current location, nil if it doesn't know where it is
    var directionFromHere: CLLocationDirection? {
        let source = FCLocationSource.core
        guard source.knowsCurrentLocation, let here = source.currentLocation else { return nil }
        return here.direction(to: self)
    }

    /// the great circle bearing to the
    /// @param other location provided, `FCDirection.disoriented` for the special locations
    func direction(to other: CLLocation) -> CLLocationDirection {
        let special = [FCLocation.nowhere, FCLocation.anywhere, FCLocation.restricted]
        if special.contains(where: { $0 === self || $0 === other }) || isEqual(other) {
            return FCDirection.disoriented
        }
        return coordinate.bearing(to: other.coordinate)
    }

    // MARK: Coordinate Strings

    /// e.g. `N37° 46.4940' W122° 25.1940'`
    var latLonString: String {
        String(format: "%@%.0f° %.4f' %@%.0f° %.4f'", String(latitudeHemisphere), latitudeDegrees, latitudeMinutes,
               String(longitudeHemisphere), longitudeDegrees, longitudeMinutes)
    }

    /// e.g. `MSL+12.5m`, nil at sea level
    var altitudeString: String? {
        altitude == 0 ? nil : String(format: "MSL%+.1fm", altitude)
    }

    /// e.g. `~10.0m`, nil if the accuracy is unknown
    var precisionString: String? {
        horizontalAccuracy == 0 ? nil : String(format: "~%.1fm", horizontalAccuracy)
    }

    /// the coordinates, altitude and precision
    var coordinateString: String {
        [latLonString, altitudeString, precisionString].compactMap { $0 }.joined(separator: " ")
    }

    /// the coordinates in the NMEA format `FCLocation(nmeaString:)` reads
    var nmeaString: String {
        String(format: "%@%.0f' %.4f\" %@%.0f %.4f\" MSL%+.2f", String(latitudeHemisphere), latitudeDegrees, latitudeMinutes,
               String(longitudeHemisphere), longitudeDegrees, longitudeMinutes, altitude)
    }

    /// the geohash of the coordinates, empty if they aren't valid
    var geohash: String {
        Geohash.encode(coordinate) ?? ""
    }

    // MARK: Notifications

    /// post an update of this location, from the
    /// @param source provided
    func notifyLocationUpdate(from source: FCLocationSource?) {
        var info: [String: Any] = [:]
        info[FCLocation.sourceKey] = source
        NotificationCenter.default.post(name: .FCLocationUpdate, object: self, userInfo: info)
    }

    /// post that the
    /// @param tracked object provided moved to this location, from the
    /// @param replaced location provided
    func notifyLocationTracked(replacing replaced: CLLocation?, object tracked: Any?) {
        var info: [String: Any] = [:]
        info[FCLocation.trackedReplacesKey] = replaced
        info[FCLocation.trackedObjectKey] = tracked
        NotificationCenter.default.post(name: .FCLocationTracked, object: self, userInfo: info)
    }

    /// post that the
    /// @param source provided forgot this location
    func notifyLocationForgotten(by source: FCLocationSource?) {
        var info: [String: Any] = [:]
        info[FCLocation.sourceKey] = source
        NotificationCenter.default.post(name: .FCLocationForgotten, object: self, userInfo: info)
    }
}

// MARK: - FCLocation

/// A CLLocation with a name, URL, type and icon
@objc(FCLocation)
open class FCLocation: CLLocation, @unchecked Sendable {
    // MARK: Types
    public static let coreLocationType = "Core Location"
    public static let nmeaType = "NMEA"
    public static let specialType = "Special"
    public static let sharedType = "Shared"

    // MARK: Notification Keys
    /// the source of the location
    public static let sourceKey = "FCLocationSourceKey"
    /// the object the location tracks
    public static let trackedObjectKey = "FCLocationTrackedObjectKey"
    /// the location a tracked location replaces
    public static let trackedReplacesKey = "FCLocationTrackedReplacesKey"
    /// the location's placemarks
    public static let geocodedPlacemarksKey = "FCLocationGeocodedPlacemarksKey"
    /// the geocoding error
    public static let geocodingErrorKey = "FCLocationGeocodingErrorKey"

    public var name: String?
    public var url: URL?
    public var type: String?
    public var icon: ILImage?
    /// the placemarks of the location, after it's geocoded
    public var placemarks: [CLPlacemark]?

    // MARK: Special Locations

    /// a location which is infinitely far from everywhere
    public static let nowhere = FCLocation(coordinate: kCLLocationCoordinate2DInvalid, name: "Nowhere", type: specialType)
    /// a location which is right here, wherever here is
    public static let anywhere = FCLocation(coordinate: kCLLocationCoordinate2DInvalid, name: "Anywhere", type: specialType)
    /// a location we're not allowed to know
    public static let restricted = FCLocation(coordinate: kCLLocationCoordinate2DInvalid, name: "Restricted", type: specialType)

    // MARK: Initializers

    public override init(coordinate: CLLocationCoordinate2D, altitude: CLLocationDistance, horizontalAccuracy hAccuracy: CLLocationAccuracy,
                         verticalAccuracy vAccuracy: CLLocationAccuracy, timestamp: Date) {
        super.init(coordinate: coordinate, altitude: altitude, horizontalAccuracy: hAccuracy, verticalAccuracy: vAccuracy, timestamp: timestamp)
    }

    public override init(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        super.init(latitude: latitude, longitude: longitude)
    }

    public override init(coordinate: CLLocationCoordinate2D, altitude: CLLocationDistance, horizontalAccuracy hAccuracy: CLLocationAccuracy,
                         verticalAccuracy vAccuracy: CLLocationAccuracy, course: CLLocationDirection, speed: CLLocationSpeed, timestamp: Date) {
        super.init(coordinate: coordinate, altitude: altitude, horizontalAccuracy: hAccuracy, verticalAccuracy: vAccuracy,
                   course: course, speed: speed, timestamp: timestamp)
    }

    public override init(coordinate: CLLocationCoordinate2D, altitude: CLLocationDistance, horizontalAccuracy hAccuracy: CLLocationAccuracy,
                         verticalAccuracy vAccuracy: CLLocationAccuracy, course: CLLocationDirection, courseAccuracy: CLLocationDirectionAccuracy,
                         speed: CLLocationSpeed, speedAccuracy: CLLocationSpeedAccuracy, timestamp: Date) {
        super.init(coordinate: coordinate, altitude: altitude, horizontalAccuracy: hAccuracy, verticalAccuracy: vAccuracy,
                   course: course, courseAccuracy: courseAccuracy, speed: speed, speedAccuracy: speedAccuracy, timestamp: timestamp)
    }

    /// a copy of the
    /// @param location provided
    public convenience init(location: CLLocation) {
        self.init(coordinate: location.coordinate, altitude: location.altitude, horizontalAccuracy: location.horizontalAccuracy,
                  verticalAccuracy: location.verticalAccuracy, timestamp: location.timestamp)
        type = (location as? FCLocation)?.type ?? Self.coreLocationType
        if let location = location as? FCLocation {
            name = location.name
            url = location.url
            icon = location.icon
        }
    }

    public convenience init(coordinate: CLLocationCoordinate2D, name: String?, type: String?, url: URL? = nil, icon: ILImage? = nil) {
        self.init(coordinate: coordinate, altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: Date())
        self.name = name
        self.type = type
        self.url = url
        self.icon = icon
    }

    /// the location at the center of the
    /// @param geohash provided, or nil if it isn't one
    public convenience init?(geohash: String) {
        guard let coordinate = Geohash.decode(geohash) else { return nil }
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    /// the location in an NMEA string with its altitude, e.g. `N37' 46.4940" W122 25.1940" MSL+0.00`, or nil if it can't be read
    public convenience init?(nmeaString string: String) {
        let scanner = Scanner(string: string)
        scanner.charactersToBeSkipped = .whitespaces
        guard let latitudeHemisphere = scanner.scanCharacter(), let latitudeDegrees = scanner.scanDouble(),
              scanner.scanString("'") != nil, let latitudeMinutes = scanner.scanDouble(), scanner.scanString("\"") != nil,
              let longitudeHemisphere = scanner.scanCharacter(), let longitudeDegrees = scanner.scanDouble(),
              let longitudeMinutes = scanner.scanDouble(), scanner.scanString("\"") != nil else {
            return nil
        }
        let altitude = scanner.scanString("MSL") != nil ? (scanner.scanDouble() ?? 0) : 0
        let latitude = (latitudeDegrees + latitudeMinutes / 60) * (latitudeHemisphere == FCCardinal.south ? -1 : 1)
        let longitude = (longitudeDegrees + longitudeMinutes / 60) * (longitudeHemisphere == FCCardinal.west ? -1 : 1)
        self.init(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), altitude: altitude,
                  horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: Date())
        name = string
        type = Self.nmeaType
    }

    // MARK: NSSecureCoding, in the version 100 format of FourCorners 1.x

    open override class var supportsSecureCoding: Bool { true }

    open override func encode(with coder: NSCoder) {
        coder.encode(100, forKey: "ver")
        coder.encode(coordinate.latitude, forKey: "lat")
        coder.encode(coordinate.longitude, forKey: "lon")
        coder.encode(altitude, forKey: "alt")
        coder.encode(horizontalAccuracy, forKey: "hdop")
        coder.encode(verticalAccuracy, forKey: "vdop")
        coder.encode(timestamp, forKey: "time")
        coder.encode(name, forKey: "name")
        coder.encode(url, forKey: "url")
        coder.encode(type, forKey: "type")
#if canImport(AppKit)
        coder.encode(icon?.name(), forKey: "icon")
#endif
    }

    public required init?(coder: NSCoder) {
        let isVersion100 = coder.decodeInt32(forKey: "ver") == 100
        let coordinate = CLLocationCoordinate2D(latitude: isVersion100 ? coder.decodeDouble(forKey: "lat") : 0,
                                                longitude: isVersion100 ? coder.decodeDouble(forKey: "lon") : 0)
        super.init(coordinate: coordinate,
                   altitude: isVersion100 ? coder.decodeDouble(forKey: "alt") : 0,
                   horizontalAccuracy: isVersion100 ? coder.decodeDouble(forKey: "hdop") : 0,
                   verticalAccuracy: isVersion100 ? coder.decodeDouble(forKey: "vdop") : 0,
                   timestamp: (isVersion100 ? coder.decodeObject(of: NSDate.self, forKey: "time") as Date? : nil) ?? Date())
        name = coder.decodeObject(of: NSString.self, forKey: "name") as String?
        url = coder.decodeObject(of: NSURL.self, forKey: "url") as URL?
        type = coder.decodeObject(of: NSString.self, forKey: "type") as String?
        if let iconName = coder.decodeObject(of: NSString.self, forKey: "icon") as String? {
#if canImport(AppKit)
            icon = ILImage(named: iconName)
#elseif os(watchOS)
            icon = ILImage(named: iconName)
#else
            icon = ILImage(named: iconName) ?? ILImage(systemName: iconName)
#endif
        }
    }

    // MARK: NSCopying

    open override func copy(with zone: NSZone? = nil) -> Any {
        FCLocation(location: self)
    }

    // MARK: CLLocation

    /// the distance to the
    /// @param location provided, infinite from nowhere, zero from anywhere and not a number from restricted locations
    open override func distance(from location: CLLocation) -> CLLocationDistance {
        if self === Self.nowhere || location === Self.nowhere { return .infinity }
        if self === Self.anywhere || location === Self.anywhere { return 0 }
        if self === Self.restricted || location === Self.restricted { return .nan }
        return super.distance(from: location)
    }

    // MARK: NSObject

    /// ordered by latitude, then longitude, then altitude, accuracy is disregarded
    @objc open func compare(_ other: FCLocation) -> ComparisonResult {
        let mine = (coordinate.latitude, coordinate.longitude, altitude)
        let theirs = (other.coordinate.latitude, other.coordinate.longitude, other.altitude)
        if mine == theirs { return .orderedSame }
        return mine > theirs ? .orderedAscending : .orderedDescending
    }

    open override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? CLLocation,
              coordinate.latitude == other.coordinate.latitude, coordinate.longitude == other.coordinate.longitude,
              altitude == other.altitude else {
            return false
        }
        guard let location = other as? FCLocation else {
            return Swift.type(of: other) == CLLocation.self // only plain CLLocations compare by their coordinates
        }
        return name == location.name && url == location.url && type == location.type && icon === location.icon
    }

    open override var hash: Int {
        var hasher = Hasher()
        hasher.combine(coordinate.latitude)
        hasher.combine(coordinate.longitude)
        hasher.combine(altitude)
        return hasher.finalize()
    }

    // MARK: Geocoding

    /// geocode the location into placemarks, and post `FCLocationGeocoded` when it's done
    open func geocode() {
        CLGeocoder().reverseGeocodeLocation(self) { [self] placemarks, error in
            self.placemarks = placemarks
            var info: [String: Any] = [Self.geocodedPlacemarksKey: placemarks ?? []]
            info[Self.geocodingErrorKey] = error
            NotificationCenter.default.post(name: .FCLocationGeocoded, object: self, userInfo: info)
        }
    }

    /// the name of the location's last placemark
    open var placeName: String? {
        placemarks?.last?.name
    }

    /// the street, city and state of the location's last placemark
    open var placeAddress: String? {
        guard let address = placemarks?.last else { return nil }
        return [address.thoroughfare, address.locality, address.administrativeArea].compactMap { $0 }.joined(separator: ", ")
    }
}

// MARK: - Geo URLs

public extension URL {
    /// the media type of geo `data:` URLs
    static let geoURLType = "x-type:geo"

    /// a `data:x-type:geo,latitude,longitude[,altitude[,time]]` URL
    init(geoLatitude latitude: CLLocationDegrees, longitude: CLLocationDegrees, altitude: CLLocationDistance? = nil, time: Date? = nil) {
        var values = ["\(latitude)", "\(longitude)"]
        if let altitude { values.append("\(altitude)") }
        if let time { values.append("\(time.timeIntervalSince1970)") }
        self.init(string: "data:\(Self.geoURLType),\(values.joined(separator: ","))")!
    }

    /// the geo URL of the
    /// @param location provided
    init(geoLocation location: CLLocation) {
        self.init(geoLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, altitude: location.altitude,
                  time: location.timestamp)
    }
}

public extension FCLocation {
    /// the location of a
    /// @param geoURL provided, or nil if it isn't one
    convenience init?(geoURL url: URL) {
        let prefix = "data:\(URL.geoURLType),"
        guard url.absoluteString.hasPrefix(prefix) else { return nil }
        let values = url.absoluteString.dropFirst(prefix.count).split(separator: ",").compactMap { Double($0) }
        guard values.count >= 2 else { return nil }
        let timestamp = values.count > 3 ? Date(timeIntervalSince1970: values[3]) : Date()
        self.init(coordinate: CLLocationCoordinate2D(latitude: values[0], longitude: values[1]), altitude: values.count > 2 ? values[2] : 0,
                  horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: timestamp)
    }
}
