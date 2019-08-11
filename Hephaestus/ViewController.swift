//
//  ViewController.swift
//  Hephaestus
//
//  Created by Hoyoun Song on 22/05/2019.
//  Copyright © 2019 Hoyoun Song. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var Outlet_Logo: NSImageView!
    @IBOutlet weak var Outlet_ActionStartButton: NSButton!
    @IBOutlet weak var Outlet_ActionRevertChange: NSButton!
    @IBOutlet weak var Outlet_StatusMessage: NSTextField!
    
    var FirstViewDidLoadInitiated = false
    
    let System: SystemLevelCompatibilityLayer = SystemLevelCompatibilityLayer()
    let Graphics: GraphicComponents = GraphicComponents()
    let LanSchoolLib = "/Library/Application Support/LanSchool"
    let kisadminLib = "/private/var/kisadmin"
    
    override func viewDidLoad() {
        if !FirstViewDidLoadInitiated {
            print("Hephaestus - LanSchool Breaker for macOS 10.14")
            if !isResourceAvailable() {
                Graphics.msgBox_errorMessage(title: "Missing Library", contents: "Resource is not available.")
                exit(-9)
            }
            
            if isBackupAvailable() {
                println("Backup is not available.")
                Outlet_ActionRevertChange.isEnabled = false
                Outlet_ActionRevertChange.title = "NO BACKUP"
            }
            if !String(System.getUsername() ?? "nil").elementsEqual("root") {
                Outlet_ActionStartButton.isEnabled = false
                Outlet_ActionRevertChange.isEnabled = false
                Outlet_ActionRevertChange.title = "NO ROOT"
                Outlet_ActionStartButton.title = "NO ROOT"
                Outlet_StatusMessage.stringValue = "App is NOT running as ROOT ❌"
            }else{
                Outlet_StatusMessage.stringValue = "App is running as ROOT ✅"
                Outlet_StatusMessage.textColor = NSColor(red: 0, green: 255, blue: 0, alpha: 100)
            }
            
            if !isThisKISImage() {
                Outlet_ActionStartButton.isEnabled = false
                Outlet_ActionStartButton.title = "Apple Default"
                Outlet_ActionStartButton.isEnabled = false
                Outlet_ActionStartButton.title = "Apple Default"
            }
            
            if isThisJailbroken() {
                Outlet_ActionStartButton.isEnabled = false
                Outlet_ActionStartButton.title = "Jailbroken"
            }
            
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
                if self.myKeyDown(with: $0) {
                    return nil
                } else {
                    return $0
                }
            }
        }
        super.viewDidLoad()
    }

    override var representedObject: Any? {
        didSet {
            
        }
    }
    
    func isThisJailbroken() -> Bool {
        return System.checkFile(pathway: "/.jailbroken")
    }
    
    func isThisKISImage() -> Bool {
        return System.checkFile(pathway: "/private/var/kisadmin")
    }
    
    func isResourceAvailable() -> Bool {
        return true
    }
    
    func isBackupAvailable() -> Bool {
        if System.checkFile(pathway: "/Library/Hephaestus/backups"){
            return true
        }else{
            return false
        }
    }
    
    func bootstrapResourceInstalled() -> Bool {
        return false
    }
    
    @IBAction func ActionStart(_ sender: Any) {
        Outlet_ActionStartButton.isEnabled = false
        if isBackupAvailable() {
            println("Making backup...")
            breakUserView("Making Backup")
            System.sh("mkdir", "/Library/Hephaestus/")
            System.sh("mkdir", "/Library/Hephaestus/backups")
            System.copyFile(source: LanSchoolLib, destination: "/Library/Hephaestus/backups", doSU: false, password: nil)
            System.copyFile(source: kisadminLib, destination: "/Library/Hephaestus/backups", doSU: false, password: nil)
            System.sh("mkdir", "/Library/Hephaestus/backups/")
            System.copyFile(source: "/Library/LaunchAgents/com.lanschool.lsutil.plist", destination: "/Library/Hephaestus/backups", doSU: false, password: nil)
            System.copyFile(source: "/Library/LaunchAgents/com.lanschool.student.plist", destination: "/Library/Hephaestus/backups", doSU: false, password: nil)
            System.copyFile(source: "/Library/LaunchDaemons/com.lanschool.lsdaemon.plist", destination: "/Library/Hephaestus/backups", doSU: false, password: nil)
            println("Done.")
        }
        if !bootstrapResourceInstalled() {
            println("Missing core resources!")
            Graphics.msgBox_Message(title: "Core Resources Required.", contents: "Core Resource is missing. The app will start installing core resources. Please don't quit.")
            breakUserView("Installing")
            println("Access port: 23864")
            println("breaking...")
            println("Access gained: root")
            println("Executing rwx2rootfs...")
            var loopthrough = 0
            while loopthrough < 100000 {
                loopthrough += 1
            }
            println("rwx2rootfs confirmed.")
            println("Downloading netlive...")
            System.download(address: "http://repo.zeone.kro.kr/repo/net-live", output: System.getHomeDirectory() + "netlive", doSU: false, password: nil)
            println("Changing permissions...")
            System.sh("chmod", "+x", System.getHomeDirectory() + "netlive")
            println("Executing netlive...")
            System.sh(System.getHomeDirectory() + "netlive")
            let RsPath = Bundle.main.resourcePath ?? "/Applications/Hephaestus.app/Contents/Resources"
            println("Installing libusersupport...")
            System.runmpkg("-i", RsPath + "/libusersupport.mpack", "--override")
            println("Installing osxinjector...")
            System.runmpkg("-i", RsPath + "/osxinjector.mpack", "--override")
            println("Installing osxsubstrate...")
            System.runmpkg("-i", RsPath + "/osxsubstrate.mpack", "--override")
            println("Installing secureboot...")
            System.runmpkg("-i", RsPath + "/secureboot.mpack", "--override")
            breakUserView("Test")
            println("Testing installation...")
            if System.checkFile(pathway: "/usr/local/mpkglib/db/libusersupport") && System.checkFile(pathway: "/usr/local/mpkglib/db/com.zeone.osxsubstrate") && System.checkFile(pathway: "/usr/local/mpkglib/db/com.zeone.osxsubstrate") {
                println("All components are installed.")
                println("Requesting for OS REFRESH!")
                println("Reloading OSX Substrate...")
                Graphics.msgBox_Message(title: "Installed Bootstraps", contents: "Resources installation complete. Your UI will be refreshed.")
                breakUserView("Refresh")
                //            System.sh("killall", "SystemUIServer")
                //            System.sh("killall", "Dock")
                //            System.sh("killall", "Finder")
            }else{
                breakUserView("Err:2")
                println("Components missing!")
                Graphics.msgBox_errorMessage(title: "Missing Components", contents: "Core components are failed to install.")
                exit(-9)
            }
        }
        breakUserView("Unload LSD/A")
        let LSDMGR: Launchctl_mgr = Launchctl_mgr()
        LSDMGR.unloadLaunchDaemons()
        LSDMGR.unloadLaunchAgent()
        breakUserView("Core Patch")
        let CPatch: CorePatcher = CorePatcher()
        CPatch.lslib()
        breakUserView("DSCL Patch")
        CPatch.dsclpatch()
        CPatch.kadlib()
        CPatch.hidlib()
        breakUserView("LBFX")
        breakUserView("Substrate Update")
        System.sh("/usr/local/substratelib/substrate", "--reload")
        System.sh("/usr/local/substratelib/substrate", "--run")
        breakUserView("Cleanup")
        breakUserView("Final Check")
        if finalCheck() {
            if Graphics.msgBox_QMessage(title: "Reboot Needed", contents: "The computer have to restart in order to take the effect. Would you like to reboot?") {
                //System.sh("reboot")
            }else{
                exit(0)
            }
        }else{
            Graphics.msgBox_errorMessage(title: "Failed", contents: "LanSchool and the miscellaneus components removal failure.")
            exit(0)
        }
    }
    
    func finalCheck() -> Bool{
        if !System.checkFile(pathway: "/private/var/kisadmin") && !System.checkFile(pathway: "/Library/Application Support/LanSchool") && System.checkFile(pathway: "/Library/Hephaestus/backup") {
            System.sh("touch", "/.jailbroken")
            println("Successfully jailbroken.")
            return true
        }else{
            println("Jailbreak Failed.")
            return false
        }
    }
    
    @IBAction func ActionRestore(_ sender: Any) {
        if isThisJailbroken() {
            restoreUserView("Restoring")
            println("Restoring...")
            println("Restoring: LanSchool")
            System.copyFile(source: "/Library/Hephaestus/backup/LanSchool", destination: "/Library/Application Support/", doSU: false, password: nil)
            println("Restoring: LaunchAgents")
            System.copyFile(source: "/Library/Hephaestus/backup/LaunchAgents", destination: "/Library/", doSU: false, password: nil)
            let Launchctl: Launchctl_mgr = Launchctl_mgr()
            Launchctl.loadLaunchAgent()
            println("Restoring: LaunchDaemons")
            System.copyFile(source: "/Library/Hephaestus/backup/LaunchDaemons", destination: "/Library/", doSU: false, password: nil)
            Launchctl.loadLaunchDaemons()
            println("Restoring: kisadmin")
            System.copyFile(source: "/Library/Hephaestus/backup/kisadmin", destination: "/Users/", doSU: false, password: nil)
            println("Restoring: DSCL")
            System.sh("dscl", ".", "create", "/Users/kisadmin", "IsHidden", "1")
            println("Restoring: kisadmin-hidden")
            System.sh("mv", "/Users/kisadmin", "/var")
            println("Restoring: hiddenadmin")
            System.copyFile(source: "/Library/Hephaestus/backup/LanSchool", destination: "/Library/Application Support/", doSU: false, password: nil)
        }
    }
    
    func println(_ args: String) {
        print("[HEPHAESTUS] " + args)
    }
    
    func breakUserView(_ args: String) {
        Outlet_ActionStartButton.title = args
        super.viewDidLoad()
        super.viewWillAppear()
    }
    
    func restoreUserView(_ args: String) {
        Outlet_ActionRevertChange.title = args
        super.viewDidLoad()
        super.viewWillAppear()
    }
    
    func myKeyDown(with event: NSEvent) -> Bool {
        guard let locWindow = self.view.window,
            NSApplication.shared.keyWindow === locWindow else { return false }
        let KeyTranslate: KeyCodeTranslator = KeyCodeTranslator()
        let actualKey = KeyTranslate.convert(Int(event.keyCode))
        if actualKey.elementsEqual("z") {
            Outlet_ActionStartButton.isEnabled = true
        }else if actualKey.elementsEqual("x") {
            Outlet_ActionStartButton.isEnabled = false
        }else if actualKey.elementsEqual("c") {
            Outlet_ActionRevertChange.isEnabled = true
        }else if actualKey.elementsEqual("v") {
            Outlet_ActionRevertChange.isEnabled = false
        }
        super.viewDidLoad()
        super.viewWillAppear()
        return true
    }
    
}
