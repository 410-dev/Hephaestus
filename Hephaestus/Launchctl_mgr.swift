//
//  Launchctl_mgr.swift
//  Hephaestus
//
//  Created by Hoyoun Song on 25/05/2019.
//  Copyright © 2019 Hoyoun Song. All rights reserved.
//

import Foundation
class Launchctl_mgr {
    let System: SystemLevelCompatibilityLayer = SystemLevelCompatibilityLayer()
    func unloadLaunchAgent(){
        System.sh("launchctl", "unload", "-w", "/Library/LaunchAgents/com.lanschool.lsutil.plist")
        System.sh("launchctl", "unload", "-w", "/Library/LaunchAgents/com.lanschool.student.plist")
        System.sh("rm", "/Library/LaunchAgents/com.lanschool.student.plist", "/Library/LaunchAgents/com.lanschool.lsutil.plist")
    }
    
    func unloadLaunchDaemons() {
        System.sh("launchctl", "unload", "-w", "/Library/LaunchDaemons/com.lanschool.lsdaemon.plist")
        System.sh("rm", "/Library/LaunchDaemons/com.lanschool.lsdaemon.plist")
    }
    
    func loadLaunchAgent () {
        System.sh("launchctl", "load", "-w", "/Library/LaunchAgents/com.lanschool.lsutil.plist")
        System.sh("launchctl", "load", "-w", "/Library/LaunchAgents/com.lanschool.student.plist")
    }
    
    func loadLaunchDaemons() {
        System.sh("launchctl", "load", "-w", "/Library/LaunchDaemons/com.lanschool.lsdaemon.plist")
    }
}
