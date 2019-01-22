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

    @IBOutlet weak var TableView: NSTableView!
    @IBAction func onClickSync(_ sender: NSButton) {
        
        
        Utilities.sync(songs: Utilities.getSong(name: selected_playlist))
        
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
                    Utilities.getFolderItems(folderLocation: result!)
                }
            } else {
                print("nothing chosen")
            }
        })
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        return Utilities.getPlaylist().count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if (tableColumn?.identifier)!.rawValue == "CheckColumn"
        {
            if let cell: CustomTableViewCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CheckColumn"), owner: self) as? CustomTableViewCell
            {
                cell.Checkbox.title = Utilities.getPlaylist()[row]
                
                cell.sel_checkBox = { sender in
                    if cell.Checkbox.state.rawValue == 1
                    {
                        self.selected_playlist.append(Utilities.getPlaylist()[row])
                    }
                    else
                    {
                        self.selected_playlist = self.selected_playlist.filter({ $0 != Utilities.getPlaylist()[row] })
                    }
                }
                
                
                return cell
            }
        }
        return nil
    }
}

