//
//  ViewController.swift
//  PodSync
//
//  Created by edi on 17/1/19.
//  Copyright © 2019 Viet. All rights reserved.
//

import Cocoa
import iTunesLibrary



class ViewController: NSViewController {

    var selected_playlist = [String]()
    var location: URL?
    
    let library = try! ITLibrary.init(apiVersion: "1.1")
    
    var thisPlaylist = TablePlaylist.init(playlist: Utilities.getPlaylist())

    @IBOutlet weak var tableView: NSTableView!
    @IBAction func onClickSync(_ sender: NSButton) {
        
        
        
        if Synchronize.getstop() == true
        {
            let command = alertBox.dialogOKCancel(question: "Sync", text: "Stop now?")
            if command == true
            {
                Synchronize.stop(flag: false)
                
            }
        }
        else
        {
            let command = alertBox.dialogOKCancel(question: "Sync", text: "Sync now?")
            if command == true
            {
                Synchronize.stop(flag: true)
                print(Synchronize.getstop())
                
                        let queue = DispatchQueue(label: "work-queue")
                
                        queue.async {
                
                            if let FolderLocation = self.location
                            {
                                Synchronize.Sync(songs: Utilities.getSong(name: self.selected_playlist), destinationFolder: FolderLocation)
                                
                                DispatchQueue.main.async {
                                    if Synchronize.getCompleted() == true
                                    {
                                        alertBox.dialogOKCancel(question: "Alert", text: "Sync completed")
                                    }
                                    
                                }
                            }
                
                    }
                
            }
        }
        
    }
    
    
    @IBOutlet weak var ProgressBar: NSProgressIndicator!
    @IBOutlet weak var SyncBtn: NSButton!
    
    
    
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
                                        
                    self.location = result
                    
                    
                }
            } else {
                print("nothing chosen")
            }
        })
    }
    
    //MARK: - Reload itunes library after the application has been focus
    @objc func applicationDidBecomeActive(_ notification: Notification) {
        Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(self.ReloadLibrary), userInfo: nil, repeats: false)
    }
    
    //MARK: - Reload library
    @objc func ReloadLibrary()
    {
        // 1. Get playlist
        thisPlaylist.playlist = Utilities.getPlaylist()
        
        // 2. Reload the table
        tableView.reloadData()
        
        print(thisPlaylist.playlist)
        
        print("LIBRARY RELOADED")
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Load saved sync folder location
        let lastDirectory = UserDefaults.standard.getLocationURL()
        
        if FileManager.default.fileExists(atPath: lastDirectory.path)
        {
            self.PathControl.url = lastDirectory
            
            location = lastDirectory
            
            print(lastDirectory.path)
        }
        else
        {
            // REMOVE destinationURL key if needed
            let removeURL = UserDefaults.standard
            removeURL.removeObject(forKey: "destinationURL")
        }
        

        // Reload library after users' modification from iTunes
        // Library will reload after users focus on PodSync's window
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: NSApplication.didBecomeActiveNotification,
            object: nil)
        
        // Sync percents notification center
        NotificationCenter.default.addObserver(self, selector: #selector(ProcessInfo), name: NSNotification.Name("NotificationPercent"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProcessInfo), name: NSNotification.Name("ProcessInfoRemained"), object: nil)
        
    }
    
    @objc func ProcessInfoRemained(notification: Notification)
    {
        let percent = SyncPercent.remainedPercent()
        
        DispatchQueue.main.async {
            self.ProgressBar.doubleValue = percent
        }
        
    }
    
    @objc func ProcessInfo(notification: Notification)
    {
        let percent = SyncPercent.calpercent()
        
        DispatchQueue.main.async {
            self.ProgressBar.increment(by: percent)
        }
        
    }
    

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
}


// MARK - TABLEVIEW
extension ViewController: NSTableViewDelegate, NSTableViewDataSource{
    
    // MARK - GET ALL NUMBER OF PLAYLIST
    func numberOfRows(in tableView: NSTableView) -> Int {
        return thisPlaylist.playlist.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if (tableColumn?.identifier)!.rawValue == "CheckColumn"
        {
            if let cell: CustomTableViewCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CheckColumn"), owner: self) as? CustomTableViewCell
            {
                cell.Checkbox.title = thisPlaylist.playlist[row]
                
                cell.sel_checkBox = { sender in
                    if cell.Checkbox.state.rawValue == 1
                    {
                        self.selected_playlist.append(self.thisPlaylist.playlist[row])
                    }
                    else
                    {
                        self.selected_playlist = self.selected_playlist.filter({ $0 != self.thisPlaylist.playlist[row] })
                    }
                }
                
                
                return cell
            }
        }
        return nil
    }
}

