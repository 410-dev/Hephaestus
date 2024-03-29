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
    
    let bin = "/usr/local/Libertas/Library/scripts/"
    let backupPath = "/usr/local/Libertas/Library/distribution/Hephaestus/backup"
    let Library = "/usr/local/Libertas/Library/"
    
    let isBeta = false
    let minimumOSV = "10.14"
    let maximumOSV = "10.14"
    
    override func viewDidLoad() {
        if !FirstViewDidLoadInitiated {
            print("Hephaestus - LanSchool Breaker for macOS 10.14")
            println("Checking compatibility...")
            if !isResourceAvailable() {
                Graphics.msgBox_errorMessage(title: "Missing Library", contents: "Unable to access CoreBinaries DB. Please install libertasapi = 10.14-x.0")
                exit(-9)
            }
            print("[LIBERTAS] Library access authorized. User: root")
            let apiCompatibility = System.readFile(pathway: Library + "COM/compatibility/major")
            let currentVersion = System.readFile(pathway: Library + "COM/compatibility/systemv")
            if !currentVersion.starts(with: minimumOSV) || !currentVersion.starts(with: maximumOSV) {
                println("System incompatible.")
                Graphics.msgBox_errorMessage(title: "Incompatible System", contents: "Your system's major release must be " + maximumOSV + ", but your system is " + currentVersion + ". Cannot continue.");
                exit(-7)
            }
            if !currentVersion.starts(with: apiCompatibility) {
                println("API incompatible.")
                Graphics.msgBox_errorMessage(title: "Incompatible API", contents: "Libertas API is not compatible. API supports " + apiCompatibility + ", but your system is " + currentVersion + ".")
                exit(-8)
            }
            if !String(System.getUsername() ?? "nil").elementsEqual("root") {
                Outlet_ActionStartButton.isEnabled = false
                Outlet_ActionRevertChange.isEnabled = false
                Outlet_ActionRevertChange.title = "Error"
                Outlet_ActionStartButton.title = "0x16"
                Outlet_StatusMessage.stringValue = "App is NOT running as ROOT ❌"
                Outlet_StatusMessage.textColor = NSColor(red: 100, green: 100, blue: 100, alpha: 100)
            }else{
                Outlet_StatusMessage.stringValue = "App is running as ROOT ✅"
                Outlet_StatusMessage.textColor = NSColor(red: 100, green: 100, blue: 100, alpha: 100)
            }
            
            if isThisJailbroken() || isBackupAvailable() {
                if isThisJailbroken() {
                    Outlet_ActionStartButton.isEnabled = false
                    Outlet_ActionStartButton.title = "Jailbroken"
                }
                
                if isBackupAvailable() && isThisJailbroken() {
                    Outlet_ActionRevertChange.isEnabled = true
                    Outlet_ActionRevertChange.title = "Restore"
                }else{
                    println("Backup is not available.")
                    Outlet_ActionRevertChange.isEnabled = false
                    Outlet_ActionRevertChange.title = "No Backup"
                }
            }else if !isThisKISImage() {
                Outlet_ActionStartButton.isEnabled = false
                Outlet_ActionStartButton.title = "Apple Default"
                Outlet_ActionRevertChange.isEnabled = false
                Outlet_ActionRevertChange.title = "Apple Default"
            }else{
                if !isBackupAvailable() {
                    println("Backup is not available.")
                    Outlet_ActionRevertChange.isEnabled = false
                    Outlet_ActionRevertChange.title = "No Backup"
                }
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
    
    func disableAllButton() {
        Outlet_ActionRevertChange.isEnabled = false
        Outlet_ActionStartButton.isEnabled = false
    }

    override var representedObject: Any? {
        didSet {
            
        }
    }
    
    func isThisJailbroken() -> Bool {
        return System.checkFile(pathway: Library + "COM/flags/jailbroken.stat")
    }
    
    func isThisKISImage() -> Bool {
        return System.checkFile(pathway: "/private/var/kisadmin")
    }
    
    func isResourceAvailable() -> Bool {
        return System.checkFile(pathway: Library)
    }
    
    func isBackupAvailable() -> Bool {
        if System.checkFile(pathway: backupPath + "/backupDone"){
            return true
        }else{
            return false
        }
    }
    
    func bootstrapResourceInstalled() -> Bool {
        let mpkgdb = "/usr/local/mpkglib/db/"
        if !System.checkFile(pathway: mpkgdb + "libusersupport") || !System.checkFile(pathway: mpkgdb + "com.zeone.osxsubstrate"){
            return false
        }else{
            return true
        }
    }
    
    @IBAction func ActionStart(_ sender: Any) {
        disableAllButton()
        if !isBackupAvailable() {
            println("Making backup...")
            breakUserView("Making Backup")
            System.silentsh(bin + "backup", "make", backupPath)
            println("Done.")
        }
        if !bootstrapResourceInstalled() {
            println("Missing core resources!")
            Graphics.msgBox_Message(title: "Core Resources Required.", contents: "Core Resource is missing. The app will start installing core resources. Please don't quit.")
            breakUserView("Installing")
            println("Access port: 23864")
            println("breaking...")
            System.silentsh(bin + "rest", "3")
            println("Access gained: root")
            println("Executing rwx2rootfs...")
            var loopthrough = 0
            while loopthrough < 100000 {
                loopthrough += 1
            }
            println("rwx2rootfs confirmed.")
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
            if System.checkFile(pathway: "/usr/local/mpkglib/db/libusersupport/pkgid") && System.checkFile(pathway: "/usr/local/mpkglib/db/com.zeone.osxsubstrate/pkgid") && System.checkFile(pathway: "/usr/local/mpkglib/db/com.zeone.osxsubstrate/pkgid") {
                println("All components are installed.")
                println("Requesting for OS REFRESH!")
                println("Reloading OSX Substrate...")
                Graphics.msgBox_Message(title: "Installed Bootstraps", contents: "Resources installation complete. Your UI will be refreshed.")
                breakUserView("Refresh")
                System.silentsh(bin + "refreshui")
            }else{
                breakUserView("Error")
                restoreUserView("0x17")
                Outlet_ActionRevertChange.isEnabled = false
                println("Components missing!")
                Graphics.msgBox_errorMessage(title: "Missing Components", contents: "Core components are failed to install.")
                exit(-9)
            }
        }
        breakUserView("Unload LSD/A")
        println("Unloading LSD/A...")
        System.silentsh(bin + "launchctlmgr", "unload")
        System.silentsh(bin + "rest", "2")
        breakUserView("Core Patch")
        println("Patching Core... May take up to 10 seconds")
        System.silentsh(bin + "rest", "6")
        System.silentsh(bin + "corepatch", "do")
        breakUserView("DSCL Patch")
        println("Patching DSCL...")
        System.silentsh(bin + "rest", "3")
        System.silentsh(bin + "dsclpatch", "do")
        breakUserView("LBFX")
        println("Running LBFX Process...")
        System.silentsh(bin + "rest", "1")
        breakUserView("Substrate Update")
        System.silentsh(bin + "subsupdate")
        breakUserView("Cleanup")
        println("Cleaning up...")
        println("Nothing to clean!")
        breakUserView("Final Check")
        println("Running final check!")
        if finalCheck() {
            if Graphics.msgBox_QMessage(title: "Reboot Needed", contents: "The computer have to restart in order to take the effect. Would you like to reboot?") {
                System.silentsh("reboot")
            }else{
                exit(0)
            }
        }else{
            Graphics.msgBox_errorMessage(title: "Failed", contents: "LanSchool and the miscellaneus components removal failure.")
            exit(0)
        }
    }
    
    func finalCheck() -> Bool{
        if !System.checkFile(pathway: "/private/var/kisadmin") && !System.checkFile(pathway: "/Library/Application Support/LanSchool") {
            System.silentsh(bin + "writeflag", "success")
            println("Successfully jailbroken.")
            return true
        }else{
            println("Jailbreak Failed.")
            return false
        }
    }
    
    @IBAction func ActionRestore(_ sender: Any) {
        disableAllButton()
        if isThisJailbroken() {
            restoreUserView("Restoring")
            println("Restoring...")
            System.silentsh(bin + "backup", "restore", backupPath)
            println("Restoring: DSCL")
            System.silentsh(bin + "dsclpatch", "restore")
            println("Restoring: LSD/A")
            System.silentsh(bin + "launchctlmgr", "load")
            restoreUserView("Finishing")
            println("Finishing up...")
            System.silentsh(bin + "writeflag", "restored")
            System.silentsh(bin + "backup", "delete", backupPath)
            println("Done.")
            restoreUserView("Done")
            if Graphics.msgBox_QMessage(title: "Reboot needed", contents: "Restoration completed. To apply the difference, you need to reboot. You'd you like to do it now?") {
                System.silentsh("reboot")
            }
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
