//
//  SettingsViewController.swift
//  PodSync
//
//  Created by edi on 15/2/19.
//  Copyright © 2019 Viet. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {

    var alwaysOnTop = UserDefaults.standard.getAlwaysOnTop()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Setup
        preferredContentSize = view.frame.size
        PathControl.url = UserDefaults.standard.getLocationURL().absoluteURL
        
        if alwaysOnTop == true
        {
            CheckAlwaysOnTop.state = .on
        }
        else
        {
            CheckAlwaysOnTop.state = .off
        }
        
       
        
        
    }

    
    @IBOutlet weak var PathControl: NSPathControl!
    @IBAction func onClickPathControl(_ sender: NSPathControl) {
        let dialog = NSOpenPanel()
        
        dialog.title                   = "Choose a destination to sync";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.beginSheetModal(for: self.view.window!, completionHandler: { num in
            
            if num == NSApplication.ModalResponse.OK {
                
                let result = dialog.url
                
                if (result != nil) {
                    
                    self.PathControl.url = result?.absoluteURL
                    
                    UserDefaults.standard.setLocationURL(value: result!)
                    
                    myDataRadio.DataRadio("NotificationLocation")
                    
                }
            } else {
                print("nothing chosen")
            }
        })
    }
    

    @IBOutlet weak var myTextField: NSTextField!
    @IBAction func onTypeTextField(_ sender: NSTextField)
    {
        
    }
    
    @IBOutlet weak var CheckAlwaysOnTop: NSButton!
    @IBAction func onCheckAlwaysOnTop(_ sender: NSButton) {
        if CheckAlwaysOnTop.state == .on
        {
            UserDefaults.standard.setAlwaysOnTop(value: true)
            myDataRadio.DataRadio("UpdateWindowLevel")
            print("CheckAlwaysOnTop:",true)
        }
        else
        {
            UserDefaults.standard.setAlwaysOnTop(value: false)
            myDataRadio.DataRadio("UpdateWindowLevel")
            print("CheckAlwaysOnTop:",false)
        }
    }
    

}
