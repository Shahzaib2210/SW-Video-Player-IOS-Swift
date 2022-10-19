//
//  ViewController.swift
//  SW Player
//
//  Created by Shahzaib Mumtaz on 09/09/2022.
//

import UIKit
import AVKit
import AVFoundation
import Photos

class ViewController: UIViewController {
    
    //************************************************//
    // MARK:- Creating Outlets.
    //************************************************//
    
    @IBOutlet weak var musicPlayerLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var menu_View: UIView!
    @IBOutlet weak var show_Menu: UIButton!
    @IBOutlet weak var grid_View_Switch: UISwitch!
    @IBOutlet weak var dark_Theme_Switch: UISwitch!
    @IBOutlet weak var gridViewLabel: UILabel!
    @IBOutlet weak var darkThemeLabel: UILabel!
    @IBOutlet weak var noVideoFoundLabel: UILabel!
    
    //************************************************//
    // MARK: Creating properties.
    //************************************************//
    
    var playerController = AVPlayerViewController()
    var player:AVPlayer?
    
    var imagesAndVideos: PHFetchResult<PHAsset>!
    var fetchOptions = PHFetchOptions()
    
    let helper = Helper()
    
    var is_Menu_View: Bool = true
    var is_Grid_View: Bool = true
    
    var isGridFlowLayoutUsed: Bool = false {
        didSet {
            updateButtonAppearance()
        }
    }
    
    var gridFlowLayout = GridFlowLayout()
    var listFlowLayout = ListFlowLayout()
    
    //************************************************//
    // MARK:- View life Cycle
    //************************************************//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noVideoFoundLabel.isHidden = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = gridFlowLayout
        isGridFlowLayoutUsed = false
        
        show_Menu.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        menu_View.isHidden = true
        grid_View_Switch.isOn = false
        dark_Theme_Switch.isOn = false
        
        FetchSongFromGallery()
        CheckDefaultTheme()
        CheckView()
    }
    
    //************************************************//
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        menu_View.layer.cornerRadius = 10
        menu_View.layer.borderWidth = 1
        menu_View.layer.borderColor = UIColor.lightGray.cgColor
        menu_View.layer.shadowColor = UIColor.lightGray.cgColor
        
        menu_View.translatesAutoresizingMaskIntoConstraints = false
        collectionView.addSubview(menu_View)
        
        NSLayoutConstraint.activate([
            menu_View.topAnchor.constraint(equalTo: collectionView.topAnchor),
            menu_View.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            menu_View.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            menu_View.widthAnchor.constraint(equalTo: collectionView.widthAnchor)
        ])
    }
    
    //************************************************//
    // MARK:- Custom methods, actions and selectors.
    //************************************************//
    
    @IBAction func btn_Show_Menu(_ sender: UIButton) {
        
        if !is_Menu_View {
            is_Menu_View = true
            menu_View.isHidden = true
            sender.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        }
        else {
            is_Menu_View = false
            menu_View.isHidden = false
            sender.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        }
    }
    
    //************************************************//
    
    @IBAction func Grid_View_Switch_Action(_ sender: UISwitch) {
        
        if grid_View_Switch.isOn {
            isGridFlowLayoutUsed = true
            UserDefaults.standard.set("Grid", forKey: "View")
        }
        else {
            isGridFlowLayoutUsed = false
            UserDefaults.standard.set("List", forKey: "View")
        }
    }
    
    //************************************************//
    
    fileprivate func updateButtonAppearance() {
        let layout = isGridFlowLayoutUsed ? gridFlowLayout : listFlowLayout
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.setCollectionViewLayout(layout, animated: true)
        }
    }
    
    //************************************************//
    
    @IBAction func Dark_Theme_Switch_Action(_ sender: UISwitch) {
        
        if dark_Theme_Switch.isOn {
            UserDefaults.standard.set("Dark", forKey: "color")
            overrideUserInterfaceStyle = .dark
            show_Menu.tintColor = UIColor.white
        }
        else {
            UserDefaults.standard.set("Light", forKey: "color")
            overrideUserInterfaceStyle = .light
            show_Menu.tintColor = UIColor.black
        }
    }
    
    //************************************************//
    
    private func FetchSongFromGallery() {
        
        PHPhotoLibrary.requestAuthorization (
            { [weak self] status in
                
                if status == .authorized
                {
                    print("Permision Granted")
                    
                    DispatchQueue.main.async {
                        
                        self?.fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false) ]
                        self?.fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
                        self?.imagesAndVideos = PHAsset.fetchAssets(with: self?.fetchOptions)
                        self?.collectionView.reloadData()
                    }
                }
                else
                {
                    DispatchQueue.main.async {
                        self?.helper.showAlert(message: "Please Go to Setting -> SW Player -> Photos -> Click on Read and Write.", title: "Alert!", viewController: self!)
                    }
                }
            })
        
        self.fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false) ]
        self.fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        self.imagesAndVideos = PHAsset.fetchAssets(with: self.fetchOptions)
        self.collectionView.reloadData()
    }
    
    //************************************************//
}

extension ViewController {
    
    // MARK :- Play Video function.
    
    func playVideo(asset: PHAsset) {
        
        guard asset.mediaType == .video else {
            // Handle if the asset is not a video.
            return
        }
        
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        
        PHCachingImageManager().requestPlayerItem(forVideo: asset, options: options)
        { [weak self] (playerItem, info) in
            
            DispatchQueue.main.async {
                
                let playerViewController = AVPlayerViewController()
                playerViewController.player = AVPlayer(playerItem: playerItem)
                self?.present(playerViewController, animated: true) {
                    playerViewController.player?.play()
                }
            }
        }
    }
    
    //************************************************//
    
    func CheckDefaultTheme() {
        
        if UserDefaults.standard.value(forKey: "color") != nil {
            
            if UserDefaults.standard.value(forKey: "color") as! String == "Light" {
                
                overrideUserInterfaceStyle = .light
                show_Menu.tintColor = UIColor.black
                dark_Theme_Switch.isOn = false
            }
            else if UserDefaults.standard.value(forKey: "color") as! String == "Dark" {
                
                overrideUserInterfaceStyle = .dark
                show_Menu.tintColor = UIColor.white
                dark_Theme_Switch.isOn = true
            }
        }
        else {
            print("No Theme Selected!")
        }
    }
    
    //************************************************//
    
    func CheckView() {
        if UserDefaults.standard.value(forKey: "View") != nil {
            
            if UserDefaults.standard.value(forKey: "View") as! String == "Grid" {
                
                grid_View_Switch.isOn = true
                isGridFlowLayoutUsed = true
            }
            else if UserDefaults.standard.value(forKey: "View") as! String == "List" {
                
                grid_View_Switch.isOn = false
                isGridFlowLayoutUsed = false
            }
        }
        else {
            print("No Theme Selected!")
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    //************************************************//
    // MARK:- CollectionView delegate and datesource
    //************************************************//
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if imagesAndVideos.count > 0 {
            noVideoFoundLabel.isHidden = true
            return imagesAndVideos.count
        } else {
            noVideoFoundLabel.isHidden = false
            return 0
        }
    }
    
    //************************************************//
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SongsList", for: indexPath) as! SongsListCollectionViewCell
        
        let asset = imagesAndVideos!.object(at: indexPath.row)
        
        let width: CGFloat = 408
        let height: CGFloat = 154
        
        let size = CGSize(width:width, height:height)
        
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: PHImageContentMode.aspectFill, options: nil)
        { (image, userInfo) -> Void in
            
            cell.thumbnailImage.image = image
            
            if  cell.totalWatchTime.text != nil {
                
                cell.totalWatchTime.text = String(format: "%02d:%02d",Int((asset.duration / 60)),Int(asset.duration) % 60)
                cell.songName.text = asset.value(forKey: "filename") as? String
            }
            else {
                print("Mo Value")
            }
        }
        return cell
    }
    
    //************************************************//
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let path = imagesAndVideos!.object(at: indexPath.row)
        self.playVideo(asset: path)
    }
    
    //************************************************//
}
