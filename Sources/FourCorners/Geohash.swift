import Foundation
import CoreLocation

/// Geohashes, after the public domain implementation by WEI Zhicheng, https://en.wikipedia.org/wiki/Geohash
public enum Geohash {
    private static let base32 = Array("0123456789bcdefghjkmnpqrstuvwxyz")
    private static let masks = [16, 8, 4, 2, 1]
    private static let precisionLimit = 0.00000000001 // XXX not validated

    /// @returns the geohash of the
    /// @param coordinate provided, as long as it needs to be for the coordinate's precision, at most
    /// @param maxLength characters, or nil if the coordinate isn't valid
    public static func encode(_ coordinate: CLLocationCoordinate2D, maxLength: Int = 63) -> String? {
        let (latitude, longitude) = (coordinate.latitude, coordinate.longitude)
        guard (-90...90).contains(latitude), (-180...180).contains(longitude) else { return nil }
        var lat = (-90.0, 90.0), lon = (-180.0, 180.0)
        let precision = max(precisionLimit, min(fractionalPrecision(latitude), fractionalPrecision(longitude)))
        var hash = ""
        var even = false
        for _ in 0..<maxLength {
            // stop when the hash is as precise as the coordinate
            if (lat.1 - lat.0) / 2 < precision && (lon.1 - lon.0) / 2 < precision {
                break
            }
            var index = 0
            for mask in masks {
                even.toggle()
                if even {
                    let mid = (lon.0 + lon.1) / 2
                    if longitude > mid { index |= mask; lon.0 = mid } else { lon.1 = mid }
                }
                else {
                    let mid = (lat.0 + lat.1) / 2
                    if latitude > mid { index |= mask; lat.0 = mid } else { lat.1 = mid }
                }
            }
            hash.append(base32[index])
        }
        return hash
    }

    /// @returns the coordinate at the center of the
    /// @param hash provided, rounded to its precision, or nil if it isn't a geohash
    public static func decode(_ hash: String) -> CLLocationCoordinate2D? {
        guard !hash.isEmpty else { return nil }
        var lat = (-90.0, 90.0), lon = (-180.0, 180.0)
        var even = false
        for character in hash.lowercased() {
            guard let index = base32.firstIndex(of: character) else { return nil }
            for mask in masks {
                even.toggle()
                let right = index & mask != 0
                if even {
                    let mid = (lon.0 + lon.1) / 2
                    if right { lon.0 = mid } else { lon.1 = mid }
                }
                else {
                    let mid = (lat.0 + lat.1) / 2
                    if right { lat.0 = mid } else { lat.1 = mid }
                }
            }
        }
        func rounded(_ range: (Double, Double)) -> Double {
            let error = (range.1 - range.0) / 2
            let digits = max(1, Int((-log10(error)).rounded())) - 1
            let scale = pow(10, Double(digits))
            return (((range.0 + range.1) / 2) * scale).rounded() / scale
        }
        return CLLocationCoordinate2D(latitude: rounded(lat), longitude: rounded(lon))
    }

    /// the precision of the fractional digits of the
    /// @param value provided, e.g. 0.01 for 1.25
    private static func fractionalPrecision(_ value: Double) -> Double {
        var fraction = value - value.rounded(.towardZero)
        var digits = 0
        while abs(fraction) > Double(Float.ulpOfOne) && abs(abs(fraction) - 1) > Double(Float.ulpOfOne) {
            fraction *= 10
            fraction -= fraction.rounded(.towardZero)
            digits += 1
        }
        return pow(10, -Double(digits))
    }
}
