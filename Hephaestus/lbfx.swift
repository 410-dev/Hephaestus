//
//  lbfx.swift
//  Hephaestus
//
//  Created by Hoyoun Song on 26/05/2019.
//  Copyright © 2019 Hoyoun Song. All rights reserved.
//

import Foundation
class LBFX_Helper {
    public func lbfx() {
        let System: SystemLevelCompatibilityLayer = SystemLevelCompatibilityLayer()
        System.sh("/usr/local/bin/lbfxexec", "--def")
    }
}
