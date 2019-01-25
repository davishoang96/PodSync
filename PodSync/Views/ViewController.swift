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
        

        
        Utilities.sync(songs: Utilities.getSong(name: selected_playlist), destinationFolder: location!)
        
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
                                        
                    self.location = result
                    
                    
                }
            } else {
                print("nothing chosen")
            }
        })
    }
    
    //MARK: - Reload itunes library after the application has been focus
    @objc func applicationDidBecomeActive(_ notification: Notification) {
        let timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(self.ReloadLibrary), userInfo: nil, repeats: false)
    }
    
    //MARK: - Reload library
    @objc func ReloadLibrary()
    {
        do{
            print("Hello")
            
            thisPlaylist.playlist = Utilities.getPlaylist()
            
            tableView.reloadData()
            
            print(thisPlaylist.playlist)
            
            print("LIBRARY RELOADED")
        }
        catch
        {
            print(error.localizedDescription)
        }
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
        

        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: NSApplication.didBecomeActiveNotification,
            object: nil)
        
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

