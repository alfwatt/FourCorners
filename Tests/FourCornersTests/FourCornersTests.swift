import XCTest
import CoreLocation
import FourCorners

final class FourCornersTests: XCTestCase {

    // MARK: - Geohash

    func testGeohashEncode() {
        // https://en.wikipedia.org/wiki/Geohash
        XCTAssertEqual(Geohash.encode(CLLocationCoordinate2D(latitude: 57.64911, longitude: 10.40744)), "u4pruydqqv") // as precise as the coordinate, Wikipedia has one more character
        XCTAssertNil(Geohash.encode(CLLocationCoordinate2D(latitude: 91, longitude: 0)))
    }

    func testGeohashDecode() throws {
        let coordinate = try XCTUnwrap(Geohash.decode("u4pruydqqvj"))
        XCTAssertEqual(coordinate.latitude, 57.64911, accuracy: 0.00001)
        XCTAssertEqual(coordinate.longitude, 10.40744, accuracy: 0.00001)
        XCTAssertNil(Geohash.decode("not a hash!"))
        XCTAssertNil(Geohash.decode(""))
    }

    func testLocationFromGeohash() throws {
        let location = try XCTUnwrap(FCLocation(geohash: "u4pruydqqvj"))
        XCTAssertEqual(location.coordinate.latitude, 57.64911, accuracy: 0.00001)
        XCTAssertEqual(location.geohash, "u4pruydqqv")
    }

    // MARK: - Bearings and Distances

    func testBearing() {
        let origin = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        XCTAssertEqual(origin.bearing(to: CLLocationCoordinate2D(latitude: 1, longitude: 0)), FCDirection.north, accuracy: 0.001)
        XCTAssertEqual(origin.bearing(to: CLLocationCoordinate2D(latitude: 0, longitude: 1)), FCDirection.east, accuracy: 0.001)
        XCTAssertEqual(origin.bearing(to: CLLocationCoordinate2D(latitude: -1, longitude: 0)), FCDirection.south, accuracy: 0.001)
        XCTAssertEqual(origin.bearing(to: CLLocationCoordinate2D(latitude: 0, longitude: -1)), FCDirection.west, accuracy: 0.001)
    }

    func testCoordinateAtDistanceAndBearing() {
        let start = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let destination = start.coordinate(atDistance: 1000, bearing: FCDirection.northEast)
        let distance = CLLocation(latitude: start.latitude, longitude: start.longitude)
            .distance(from: CLLocation(latitude: destination.latitude, longitude: destination.longitude))
        XCTAssertEqual(distance, 1000, accuracy: 5)
        XCTAssertEqual(start.bearing(to: destination), FCDirection.northEast, accuracy: 0.1)
    }

    func testRandomDirection() {
        for _ in 0..<100 {
            XCTAssertTrue((0...360).contains(FCDirection.random()))
        }
    }

    func testCircularError() {
        XCTAssertEqual(FCCircularError.cep50.convert(10, to: .cep50), 10, accuracy: 1e-9)
        XCTAssertEqual(FCCircularError.drms.convert(10, to: .twoDRMS), 20, accuracy: 0.01)
        XCTAssertGreaterThan(FCCircularError.cep50.convert(10, to: .r95), 10)
    }

    func testSpecialLocations() {
        let here = FCLocation(latitude: 1, longitude: 2)
        XCTAssertEqual(FCLocation.nowhere.distance(from: here), .infinity)
        XCTAssertEqual(FCLocation.anywhere.distance(from: here), 0)
        XCTAssertTrue(FCLocation.restricted.distance(from: here).isNaN)
        XCTAssertEqual(FCLocation.nowhere.direction(to: here), FCDirection.disoriented)
    }

    // MARK: - Strings

    func testNMEARoundTrip() throws {
        let location = FCLocation(coordinate: CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093), altitude: 58,
                                  horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: Date())
        let parsed = try XCTUnwrap(FCLocation(nmeaString: location.nmeaString))
        XCTAssertEqual(parsed.coordinate.latitude, -33.8688, accuracy: 0.0001)
        XCTAssertEqual(parsed.coordinate.longitude, 151.2093, accuracy: 0.0001)
        XCTAssertEqual(parsed.altitude, 58, accuracy: 0.01)
        XCTAssertEqual(parsed.type, FCLocation.nmeaType)
        XCTAssertNil(FCLocation(nmeaString: "not a location"))
    }

    func testCoordinateStrings() {
        let location = FCLocation(coordinate: CLLocationCoordinate2D(latitude: 37.5, longitude: -122.25), altitude: 12.5,
                                  horizontalAccuracy: 10, verticalAccuracy: 0, timestamp: Date())
        XCTAssertEqual(location.latLonString, "N37° 30.0000' W122° 15.0000'")
        XCTAssertEqual(location.altitudeString, "MSL+12.5m")
        XCTAssertEqual(location.precisionString, "~10.0m")
        XCTAssertEqual(location.coordinateString, "N37° 30.0000' W122° 15.0000' MSL+12.5m ~10.0m")
    }

    // MARK: - Archiving

    func testArchiveRoundTrip() throws {
        let location = FCLocation(coordinate: CLLocationCoordinate2D(latitude: 51.5, longitude: -0.12), name: "London", type: FCLocation.sharedType,
                                  url: URL(string: "https://istumbler.net"))
        let archive = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
        let decoded = try XCTUnwrap(NSKeyedUnarchiver.unarchivedObject(ofClass: FCLocation.self, from: archive))
        XCTAssertEqual(decoded, location)
        XCTAssertEqual(decoded.name, "London")
        XCTAssertEqual(decoded.url, URL(string: "https://istumbler.net"))
        XCTAssertEqual(NSStringFromClass(FCLocation.self), "FCLocation", "the class name in archives and soups")
    }

    func testCopy() throws {
        let location = FCLocation(coordinate: CLLocationCoordinate2D(latitude: 1, longitude: 2), name: "Copied", type: FCLocation.sharedType)
        let copy = try XCTUnwrap(location.copy() as? FCLocation)
        XCTAssertEqual(copy, location)
        XCTAssertFalse(copy === location)
    }

    // MARK: - URLs

    func testGeoURLRoundTrip() throws {
        let url = URL(geoLatitude: 10.5, longitude: -20.25, altitude: 100, time: Date(timeIntervalSince1970: 1000))
        let location = try XCTUnwrap(FCLocation(geoURL: url))
        XCTAssertEqual(location.coordinate.latitude, 10.5)
        XCTAssertEqual(location.coordinate.longitude, -20.25)
        XCTAssertEqual(location.altitude, 100)
        XCTAssertEqual(location.timestamp, Date(timeIntervalSince1970: 1000))
        XCTAssertNil(FCLocation(geoURL: URL(string: "https://istumbler.net")!))
    }

    // MARK: - Formatters

    func testDistanceFormatter() {
        let formatter = CLLocationDistanceFormatter()
        XCTAssertEqual(formatter.string(for: NSNumber(value: 0.1)), "100mm")
        XCTAssertEqual(formatter.string(for: NSNumber(value: 12.34)), "12.3m")
        XCTAssertEqual(formatter.string(for: NSNumber(value: 4200)), "4.20km")
        XCTAssertEqual(formatter.attributedString(for: NSNumber(value: 12.34), withDefaultAttributes: [:])?.string, "12.3m")
    }

    func testDirectionFormatters() {
        XCTAssertEqual(CLLocationDirectionFormatter.bearingString(0), "N")
        XCTAssertEqual(CLLocationDirectionFormatter.bearingString(45), "NE")
        XCTAssertEqual(CLLocationDirectionFormatter.bearingString(180), "S")
        XCTAssertEqual(CLLocationDirectionFormatter.bearingString(350), "N")
        XCTAssertEqual(CLLocationDirectionFormatter().string(for: NSNumber(value: 90)), "E ~ 90°")
        XCTAssertEqual(CLLocationDirectionArrowFormatter.bearingString(90), "\u{2192}")
        XCTAssertEqual(CLLocationDirectionKanjiFormatter.bearingString(180), "\u{5357}")
    }

    func testCoordinateFormatter() {
        let location = CLLocation(latitude: 37.5, longitude: -122.25)
        let formatter = CLLocationCoordinateFormatter()
        XCTAssertEqual(formatter.string(for: location), "N37° 30.0000' W122° 15.0000'")
        XCTAssertEqual(formatter.attributedString(for: location, withDefaultAttributes: [:])?.string, "N37°\u{00a0}30.0000' W122°\u{00a0}15.0000'")
        XCTAssertEqual(CLLocationCoordinateFormatter.coordinateString(location.coordinate), "37.5000, -122.2500")
    }
}
