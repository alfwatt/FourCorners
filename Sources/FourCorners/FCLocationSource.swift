import Foundation
import CoreLocation
#if canImport(AppKit)
import AppKit
#endif
import KitBridge

/// The base class of sources of locations: the current location of the device, and the locations of objects it tracks
@objc(FCLocationSource)
open class FCLocationSource: NSObject, @unchecked Sendable {
    /// should the source keep a track of the locations it provides?
    open var shouldTrackLocation = false

    /// the source of the device's location from Core Location
    public class var core: FCCoreLocationSource {
        FCCoreLocationSource.shared
    }

    /// all the location sources
    public class var locationSources: [FCLocationSource] {
        [core]
    }

    // MARK: Source Information

    open var sourceName: String { "" }
    open var sourceType: String { "" }
    open var horizontalAccuracy: CLLocationDistance { -1 }
    open var verticalAccuracy: CLLocationDistance { -1 }

    /// does the source know the current location of the device?
    open var knowsCurrentLocation: Bool { false }

    /// the current location of the device
    open var currentLocation: FCLocation? { FCLocation.anywhere }

    /// the locations the source has tracked
    open var trackedLocations: [FCLocation] { [] }

    /// does the source post updates of the current location or tracked objects?
    open var providesLocationUpdates: Bool { false }

    open func startUpdatingLocation() {}
    open func stopUpdatingLocation() {}
}

// MARK: -

/// The device's location from Core Location
@objc(FCCoreLocationSource)
open class FCCoreLocationSource: FCLocationSource, CLLocationManagerDelegate, @unchecked Sendable {
    /// the shared Core Location source
    public static let shared = FCCoreLocationSource()

    public let manager = CLLocationManager()
    /// you are here, or thereabouts
    public private(set) var current: FCLocation?
    /// the locations from this source, oldest first
    public private(set) var track: [FCLocation] = []

    public override init() {
        super.init()
        manager.delegate = self
    }

    open override var sourceName: String { "Core Location" }
    open override var sourceType: String { "Wi-Fi" }
    /// Core Location is about this accurate with Wi-Fi
    open override var horizontalAccuracy: CLLocationDistance { 10 }

    open override var knowsCurrentLocation: Bool {
        let status = manager.authorizationStatus
#if os(visionOS)
        let isAuthorized = status == .authorizedWhenInUse // visionOS has no always authorized
#elseif os(macOS)
        let isAuthorized = status == .authorizedAlways || status == .authorized
#else
        let isAuthorized = status == .authorizedAlways || status == .authorizedWhenInUse
#endif
        guard isAuthorized, let current, CLLocationCoordinate2DIsValid(current.coordinate) else { return false }
        let coordinate = current.coordinate
        return coordinate.latitude != 0 && coordinate.longitude != 0 && coordinate.latitude != -180 && coordinate.longitude != -180
    }

    open override var currentLocation: FCLocation? { current }
    open override var trackedLocations: [FCLocation] { track }
    open override var providesLocationUpdates: Bool { true }

    open override func startUpdatingLocation() {
        if manager.authorizationStatus == .notDetermined { // prompt, updates start when it's granted
            manager.requestWhenInUseAuthorization()
        }
#if os(tvOS)
        manager.requestLocation() // tvOS gives one location at a time
#else
        manager.startUpdatingLocation()
#endif
    }

    open override func stopUpdatingLocation() {
#if !os(tvOS)
        manager.stopUpdatingLocation()
#endif
    }

    /// make the
    /// @param location provided the current location, and post an update
    open func updateCurrentLocation(_ location: FCLocation) {
        current = location
        track.append(location)
        if location.type != FCLocation.specialType {
            location.name = ProcessInfo.processInfo.hostName
            location.icon = ILImage(systemName: "mappin")
        }
        location.notifyLocationUpdate(from: self)
    }

    // MARK: CLLocationManagerDelegate

    open func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            updateCurrentLocation(FCLocation(location: location))
        }
    }

    open func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        switch (error as? CLError)?.code {
        case .denied where manager.authorizationStatus == .notDetermined:
            return // reported while the authorization prompt is waiting for an answer
        case .denied:
            updateCurrentLocation(.restricted) // we've moved to a restricted location
        case .locationUnknown:
            updateCurrentLocation(.anywhere) // we could be anywhere!
        default:
#if canImport(AppKit)
            NSLog("locationManager: %@ didFailWithError: %@", manager, error as NSError)
            DispatchQueue.main.async {
                NSApp.presentError(error)
            }
#endif
        }
    }
}
