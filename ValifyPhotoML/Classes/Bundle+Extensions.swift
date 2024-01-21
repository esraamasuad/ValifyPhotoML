//
//  Bundle+Extensions.swift
//  ValifyPhotoML
//
//  Created by Esraa on 20/01/2024.
//

import Foundation

extension Bundle {
    static var local: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: BundleToken.self)
        #endif
    }
}

private class BundleToken {}
