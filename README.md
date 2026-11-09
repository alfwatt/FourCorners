<a id="fourcorners"></a>
# FourCorners  

Swift Location & Navigation Utilities

<a id="contents"></a>
## Contents

- <a href="#goals">Goals</a>
- <a href="#support">Support</a>
- <a href="#classes">Classes</a>
- <a href="#extensions">Extensions</a>
- <a href="#todo">To Do Items</a>
- <a href="#versions">Versions</a>
- <a href="#license">MIT License</a>

<a id="goals"></a>
## Goals

FourCorners provides utilities to make working with CoreLocation easier along with extensions and formatters which make
displaying location information easier and more consistent.

<a id="support"></a>
## Support FourCorners Development!

Are you using FourCorners in your apps? Would you like to help support the project and get a sponsor credit?

Visit our [Patreon Page](https://www.patreon.com/istumblerlabs) and patronize us in exchange for great rewards!

<a id="classes"></a>
## Classes

- [`FCLocation`](./Sources/FourCorners/FCLocation.swift): a `CLLocation` with a name, URL, type and icon, the special
  locations `nowhere`, `anywhere` and `restricted`, and initializers from NMEA strings, geohashes and geo `data:` URLs
- [`FCLocationSource`](./Sources/FourCorners/FCLocationSource.swift): the base class of location sources,
  `FCLocationSource.core` is the device's location from Core Location
    - `FCCoreLocationSource`
- [`FCAnnotation`](./Sources/FourCorners/FCAnnotation.swift): a map annotation of an object
- [`FCFormatters`](./Sources/FourCorners/FCFormatters.swift): `CLLocationDistanceFormatter`, `CLLocationSpeedFormatter`,
  `CLLocationCoordinateFormatter`, `CLLocationDirectionFormatter`, `CLLocationDirectionArrowFormatter`,
  `CLLocationDirectionKanjiFormatter` and `FCLocationLogFormatter`
- [`Geohash`](./Sources/FourCorners/Geohash.swift): encodes and decodes geohashes

<a id="extensions"></a>
## Extensions

- `CLLocationCoordinate2D.bearing(to:)` and `coordinate(atDistance:bearing:)`
- `CLLocation`: hemispheres, degrees, minutes and seconds, `direction(to:)`, `latLonString`, `altitudeString`,
  `precisionString`, `coordinateString`, `nmeaString`, `geohash`, and the location notifications
- `FCDirection`, `FCDistance`, `FCCardinal` and `FCCircularError` constants, `FCDirection.random()` and
  `FCCircularError.convert(_:to:)`
- `Notification.Name.FCLocationUpdate`, `.FCLocationTracked`, `.FCLocationForgotten` and `.FCLocationGeocoded`
 
<a id="todo"></a>
## To Do Items

- Implement local GPS via Serial
- Implement GPS sharing on iOS
- Implement remote GPS via Network
- Add Haversine and Vincenty distance methods

<a id="versions"></a>
## Versions

- 2.0.0 — Breaking API changes, FourCorners is written in Swift, with KitBridge 3.0
    - Requires macOS 14, iOS 17, tvOS 17, watchOS 10 or visionOS 26
    - The classes keep their Objective-C names, and `FCLocation` its archive format, for existing archives and soups
    - `FCLocationSource.core`, `locationSources`, `knowsCurrentLocation`, `currentLocation` and `trackedLocations`
      are properties
    - Constants are in `FCDirection`, `FCDistance`, `FCCardinal`, `FCCircularError` and `FCLocation`, e.g.
      `FCLocation.specialType` and `FCLocation.sourceKey`
    - `coordinateLatLonString`, `coordinateNEMAString` and `coordinateGeoHash` are `latLonString`, `nmeaString` and
      `geohash`, the boxed `altitudeValue`… properties are gone
    - Fixes: minutes and seconds of coordinates are never negative, bearings convert degrees to radians, NMEA
      strings are read with the right hemispheres, `init(geohash:)` returns the location, `FCCircularError` converts
      distances, `CLLocationCoordinateFormatter` formats plain `CLLocation`s
    - Tests run with `swift test`
- 1.0.4 — 19 August 2024: Swift Package Manager Support
- 103 / 103.3 — initial release

<a id="license"></a>
## License

    The MIT License (MIT)

    Copyright © 2017-2026 Alf Watt <alf@istumbler.net>

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
