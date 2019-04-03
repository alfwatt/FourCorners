<a id="fourcorners"></a>
# FourCorners  

Objective-C Location & Navigation Utilites

<a id="contents"></a>
## Contents

- <a href="#goals">Goals</a>
- <a href="#support">Support</a>
- <a href="#classes">Classes</a>
- <a href="#functions">Functions</a>
- <a href="#protocols">Protocols</a>
- <a href="#categories">Categories</a>
- <a href="#todo">To Do Items</a>
- <a href="#license">MIT License</a>

<a id="goals"></a>
## Goals

FourCorners provides utilites to make working with CoreLocation easier along with Categories and Functions which make
displaying location information easier and more consistent.

<a id="support"></a>
## Support FourCorners Development!

Are you using FourCorners in your apps? Would you like to help support the project and get a sponsor credit?

Visit our [Patreon Page](https://www.patreon.com/istumblerlabs) and patronize us in exchange for great rewards!

<a id="classes"></a>
## Classes

- <a id="FCAnnotation" href="./Sources/FCAnnotation.h">`FCAnnotation`</a>
- <a id="FCFormatters" href="./Sources/FCFormatters.h">`FCFormatters`</a>
- <a id="FCLocation" href="./Sources/FCLocation.h">`FCLocation`</a>
- <a id="FCLocationSource" href="./Sources/FCLocationSource.h">`FCLocationSource`</a>
    - <a id="FCCoreLocationSource" href="./Sources/FCCoreLocationSource.h">`FCCoreLocationSource`</a>

<a id="functions"></a>
## Functions

<a id="FCLocation-Functions" href="./Sources/FCLocation.h">`FCLocation`</a> provides a few public Functions:

`extern CLLocationDirection FCRandomDirection(void);`

`extern CLLocationDirection FCBearingFrom(CLLocationCoordinate2D origin, CLLocationCoordinate2D destination);`

`extern CLLocationCoordinate2D FCCoordincateAtDistanceAndBearingFrom(CLLocationCoordinate2D start, CLLocationDistance distance, CLLocationDirection bearing);`

<a id="categories"></a>
## Categories

<a id="FCLocation-Category" href="./Sources/FCLocation.h">`FCLocation`</a> defines a number of extentions to FCLocation.

<a id="todo"></a>
## To Do Items

- Implement local GPS via Serial
- Implement GPS sharing on iOS
- Implement remote GPS via Network

<a id="license"></a>
## License

    The MIT License (MIT)

    Copyright (c) 2017-2019 Alf Watt <alf@istumbler.net>

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
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
