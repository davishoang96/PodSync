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
    
    var thisPlaylist = TablePlaylist.init(playlist: Utilities.getPlaylist())

    @IBOutlet weak var tableView: NSTableView!
    @IBAction func onClickSync(_ sender: NSButton) {

        
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

                    

                    if let item = DirectoryUtilities.Get_FolderItemURL(UserDefaults.standard.getLocationURL())
                    {
                        Synchronize.removeOldFiles(songs: songs, files: item)
                    }

                    DirectoryUtilities.removeEmptyFolder(UserDefaults.standard.getLocationURL())
                    Synchronize.Sync(songs: songs, destinationFolder: UserDefaults.standard.getLocationURL())


                    DispatchQueue.main.async {
                        if Synchronize.getCompleted() == true
                        {
                            alertBox.dialogOKCancel(question: "Alert", text: "Sync completed", button: 0)
                        }
                    }
                    
                    
                    
                }
            }
            else if command == true && selected_playlist.isEmpty
            {
                alertBox.dialogOKCancel(question: "Alert", text: "Can't Sync!!! No playlists were selected", button: 0)
            }
        }
    }
    
    
    @IBOutlet weak var ProgressBar: NSProgressIndicator!
    @IBOutlet weak var SyncBtn: NSButton!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lastDirectory = UserDefaults.standard.getLocationURL()
        if !FileManager.default.fileExists(atPath: lastDirectory.path)
        {
            
            let removeURL = UserDefaults.standard
            removeURL.removeObject(forKey: "destinationURL")
            alertBox.dialogOKCancel(question: "Alert", text: "Cannot found the previous sync folder. Please choose other folder to sync.", button: 0)
        }
        
        // 2. UI Setup
        self.tableView.sizeLastColumnToFit()
        
        
        // TEST

        
    }
    
    func Observer()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: NSApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProcessInfo), name: NSNotification.Name("NotificationPercent"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RemainedPercent), name: NSNotification.Name("NotificationRemained"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SyncLocation), name: NSNotification.Name("NotificationLocation"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(StopSync), name: NSNotification.Name("StopSync"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UpdateWindowLevel), name: NSNotification.Name("UpdateWindowLevel"), object: nil)
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
    
    //MARK: - Update view window level at first launch
    override func viewDidAppear()
    {
        setWindowLevel()
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
        thisPlaylist.playlist = Utilities.getPlaylist()
        
        // 2. Reload the table
        tableView.reloadData()
        
        //print(thisPlaylist.playlist)
        
        //print("LIBRARY RELOADED")
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
        //print(percent)
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

