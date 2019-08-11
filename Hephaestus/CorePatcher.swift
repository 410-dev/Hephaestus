//
//  CorePatcher.swift
//  Hephaestus
//
//  Created by Hoyoun Song on 26/05/2019.
//  Copyright © 2019 Hoyoun Song. All rights reserved.
//

import Foundation
class CorePatcher {
    let System: SystemLevelCompatibilityLayer = SystemLevelCompatibilityLayer()
    public func lslib() {
        System.sh("rm", "-r", "/Library/Application Support/LanSchool")
    }
    
    func kadlib() {
        if System.checkFile(pathway: "/Users/kisadmin"){
            System.sh("rm", "-r", "/Users/kisadmin")
        }
    }
    
    func hidlib() {
        if System.checkFile(pathway: "/Users/hiddenadmin"){
            System.sh("rm", "-r", "/Users/hiddenadmin")
        }
    }
    
    public func dsclpatch() {
        transferToRootFSUser()
        System.sh("dscl", ".", "create", "/Users/kisadmin", "IsHidden", "1")
        System.sh("dscl", ".", "-delete", "/Users/hiddenadmin")
        print("Removed hiddenadmin.")
        System.sh("dscl", ".", "-delete", "/Users/kisadmin")
        print("Removed kisadmin.")
        kadlib()
        hidlib()
        print("Deleted Directories.")
    }
    
    func transferToRootFSUser() {
        System.sh("mv", "/private/var/hiddenadmin", "/Users/hiddenadmin")
        print("Transfered /private/var/hiddenadmin to /Users/hiddenadmin.")
        System.sh("mv", "/private/var/kisadmin", "/Users/kisadmin")
        print("Transfered /private/var/kisadmin to /Users/kisadmin.")
    }
}
