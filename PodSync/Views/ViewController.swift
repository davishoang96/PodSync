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
    
    let library = Utilities.myItuneLibrary
    var playlists = struct_playlist.playlistInfo(name: Utilities.getPlaylist())
    var messages = [ConsoleMessage.message]()

    
    //MARK: - IBOutlet
    @IBOutlet weak var ProgressBar: NSProgressIndicator!
    @IBOutlet weak var SyncBtn: NSButton!
    @IBOutlet weak var consoleView: NSTableView!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var PathControl: NSPathControl!
    @IBOutlet weak var label_totalSize: NSTextField!
    @IBOutlet weak var label_spaceAvailable: NSTextField!
    @IBOutlet weak var Level_diskSpace: NSLevelIndicator!
    
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
                    
                    if let location = result
                    {
                        self.PathControl.url = location.absoluteURL
                        
                        UserDefaults.standard.setLocationURL(value: location)
                        
                        self.GetVolumeInfo(location)
                    }
                }
            }
            else
            {
                print("nothing chosen")
            }
        })
    }
    
    
    
    @IBAction func onClickSync(_ sender: NSButton) {

        messages.removeAll()
        consoleView.reloadData()
        
        if Synchronize.getstop() == true
        {
            SyncBtn.title = "Sync"
            Synchronize.stop(flag: false)
            print("ISNOTRUNNING")
        }
        else
        {
            let command = alertBox.dialogOKCancel(question: "Sync", text: "Sync now?", button: 1)
            if command == true && !selected_playlist.isEmpty
            {
                print("ISRUNNING")
                SyncBtn.title = "Cancel"
                ProgressBar.doubleValue = 0
                Synchronize.stop(flag: true)
                print(Synchronize.getstop())

                let queue = DispatchQueue(label: "work-queue")

                queue.async {

                    let songs = Utilities.getSong(name: self.selected_playlist)

                    SyncedPlaylist.createXML(self.selected_playlist)

                    if let item = DirectoryUtilities.Get_FolderItemURL(UserDefaults.standard.getLocationURL())
                    {
                        Synchronize.removeOldFiles(songs: songs, files: item)
                    }

                    DirectoryUtilities.removeEmptyFolder(UserDefaults.standard.getLocationURL())
                    
                    
                    Synchronize.Sync(songs: songs, destinationFolder: UserDefaults.standard.getLocationURL())


                    DispatchQueue.main.async {
                        if Synchronize.getCompleted() == true
                        {
                            alertBox.messageBox(question: "Alert", text: "Sync completed")
                        }
                    }

                    
                    
                }
            }
            else if command == true && selected_playlist.isEmpty
            {
                alertBox.messageBox(question: "Alert", text: "Can't Sync!!! No playlists were selected")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 2. UI Setup
        self.tableView.sizeLastColumnToFit()
        
        
        // TEST
        let showLibrary = UserDefaults.standard.getShowLibrary()
        if showLibrary == true
        {
            Utilities.ShowMainLibrary(true)
        }
        else
        {
            Utilities.ShowMainLibrary(false)
        }
        
        
    }
    
    func Observer()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: NSApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProcessInfo), name: NSNotification.Name("NotificationPercent"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RemainedPercent), name: NSNotification.Name("NotificationRemained"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SyncLocation), name: NSNotification.Name("NotificationLocation"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(StopSync), name: NSNotification.Name("StopSync"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UpdateWindowLevel), name: NSNotification.Name("UpdateWindowLevel"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ReloadLibrary), name: NSNotification.Name("ReloadLibrary"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UpdateMessage), name: NSNotification.Name("UpdateMessage"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NotifyDirectoryGone), name: NSNotification.Name("NotifyDirectoryGone"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UpdateVolumeInfo), name: NSNotification.Name("UpdateVolumeInfo"), object: nil)
    }
    
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = self.messages.count-1
            self.consoleView.scrollRowToVisible(indexPath)
        }
    }
    
    @objc func UpdateMessage(notification: Notification)
    {
        messages.append(ConsoleMessage.updateMessage(des: Synchronize.getMessage()))
        DispatchQueue.main.async {
            self.consoleView.reloadData()
            self.scrollToBottom()
        }
    }
    
    @objc func UpdateVolumeInfo(notification: Notification)
    {
        DispatchQueue.main.async {
            self.GetVolumeInfo(UserDefaults.standard.getLocationURL())
        }
    }
    
    func setWindowLevel()
    {
        if UserDefaults.standard.getAlwaysOnTop() == true
        {
            self.view.window?.level = .floating
        }
        else
        {
            self.view.window?.level = .normal
        }
        self.viewDidLoad()
    }
    
    func GetVolumeInfo(_ url: URL)
    {
        // Get total disk space
        self.label_totalSize.stringValue = "Disk capacity: " + Volumes.GetSize(url)
        
        // Calculate disk space avaiable
        self.label_spaceAvailable.stringValue =  "Disk available: " + Volumes.GetFreeSize(url)
        
        self.Level_diskSpace.integerValue = Volumes.diskPercent(url)
        
        print(Volumes.diskPercent(url))
    }
    
    //MARK: - Update view window level at first launch
    override func viewDidAppear()
    {
        // 1. Set floating or normal for window level
        setWindowLevel()
        
        // 2. Notify if previous destination folder is not existed
        let lastDirectory = UserDefaults.standard.getLocationURL()
        if !FileManager.default.fileExists(atPath: lastDirectory.path)
        {
            let removeURL = UserDefaults.standard
            removeURL.removeObject(forKey: "destinationURL")
            alertBox.messageBox(question: "Alert", text: "Cannot found the previous sync folder. Please choose other folder to sync.")
        }
        else
        {
            PathControl.url = lastDirectory
            GetVolumeInfo(lastDirectory)
        }
    }
    
    //MARK: - Intial NotificationCenters
    override func viewDidLayout() {
        Observer()
    }
    
    
    //MARK: - Reload itunes library after the application has been focus
    @objc func applicationDidBecomeActive(_ notification: Notification) {
        Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(self.ReloadLibrary), userInfo: nil, repeats: false)
    }
    
    //MARK: - Reload library
    @objc func ReloadLibrary()
    {
        // 1. Get playlist
        playlists = struct_playlist.playlistInfo(name: Utilities.getPlaylist())
        
        // 2. Reload the table
        tableView.reloadData()
    }

    
    @objc func UpdateWindowLevel(notification: Notification)
    {
        setWindowLevel()
    }
    
    @objc func StopSync(notification: Notification)
    {
        DispatchQueue.main.async {
            self.ProgressBar.doubleValue = 0
            self.SyncBtn.state = .off
            self.SyncBtn.title = "Sync"
        }
    }
    
    @objc func NotifyDirectoryGone(notification: Notification)
    {
        DispatchQueue.main.async {
            alertBox.messageBox(question: "Error!!!", text: "Destination folder not found.")
        }
    }
    
    @objc func RemainedPercent(notification: Notification)
    {
        let percent = SyncPercent.remainedPercent()
        
        DispatchQueue.main.async {
            self.ProgressBar.doubleValue = percent
        }
        
    }
    
    @objc func SyncLocation(notification: Notification)
    {
        let ChosenLocation = UserDefaults.standard.getLocationURL()
        
        location = ChosenLocation
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
        if tableView.tag == 1
        {
            return playlists.count
        }
        if tableView.tag == 2
        {
            return messages.count
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView.tag == 1
        {
            if (tableColumn?.identifier)!.rawValue == "CheckColumn"
            {
                if let cell: CustomTableViewCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CheckColumn"), owner: self) as? CustomTableViewCell
                {
                    //cell.Checkbox.title = thisPlaylist.playlist[row]
                    cell.Checkbox.state = .off
                    cell.Checkbox.title = playlists[row].name
                    
                    for p in selected_playlist
                    {
                        if cell.Checkbox.title == p
                        {
                            cell.Checkbox.state = .on
                        }
                    }
                    
                    cell.sel_checkBox = { sender in
                        if cell.Checkbox.state.rawValue == 1
                        {
                            self.selected_playlist.append(self.playlists[row].name)
                        }
                        else
                        {
                            self.selected_playlist = self.selected_playlist.filter({ $0 != self.playlists[row].name })
                        }
                    }
                    return cell
                }
            }
            else if (tableColumn?.identifier)!.rawValue == "totalColumn"
            {
                if let cell: CustomTableViewCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "totalColumn"), owner: self) as? CustomTableViewCell
                {
                    cell.label_totalSong.stringValue = String(playlists[row].totalSongs)
                    return cell
                }
            }
            else if (tableColumn?.identifier)!.rawValue == "sizeColumn"
            {
                if let cell: CustomTableViewCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "sizeColumn"), owner: self) as? CustomTableViewCell
                {
                    if playlists[row].size != nil
                    {
                        if let size = playlists[row].size
                        {
                            cell.label_size.stringValue = size
                            return cell
                        }
                    }
                }
            }
            
            return nil
        }
        else if tableView.tag == 2
        {
        
            if (tableColumn?.identifier)!.rawValue == "timeColumn"
            {
                if let cell: CustomTableViewCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "timeColumn"), owner: self) as? CustomTableViewCell
                {
                    cell.label_time.stringValue = messages[row].time
                    return cell
                }
            }
            else if (tableColumn?.identifier)!.rawValue == "desColumn"
            {
                if let cell: CustomTableViewCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "desColumn"), owner: self) as? CustomTableViewCell
                {
                    cell.label_description.stringValue = messages[row].description
                    return cell
                }
            }
        }
        else
        {
            return nil
        }
        return nil
    }
    

}

