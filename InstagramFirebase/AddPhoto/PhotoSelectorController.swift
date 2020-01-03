//
//  PhotoSelectorController.swift
//  InstagramFirebase
//
//  Created by Thai Nguyen on 12/6/19.
//  Copyright © 2019 Thai Nguyen. All rights reserved.
//

import UIKit
import LBTATools
import Photos

class ImageCell: LBTAListCell<UIImage> {
    override var item: UIImage! {
        didSet {
            photoImageView.image = item
        }
    }
    
    let photoImageView: UIImageView = {
       let iv = UIImageView()
        iv.backgroundColor = .brown
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        
        return iv
    }()
    
    override func setupViews() {
        super.setupViews()
        
        backgroundColor = .blue
        
        addSubview(photoImageView)
        
        photoImageView.fillSuperview()
    }
}

class PhotoSelectorHeader: UICollectionReusableView {
    
    let selectedImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .lightGray
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true

        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .red
        
        addSubview(selectedImageView)

        selectedImageView.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class PhotoSelectorController: LBTAListHeaderController<ImageCell, UIImage, PhotoSelectorHeader>, UICollectionViewDelegateFlowLayout {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavButtons()
        
        fetchPhotos()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let view = UIView(frame: collectionView.bounds)
        view.setGradientBackground()
        
        self.view.insertSubview(view, belowSubview: collectionView)
        collectionView.backgroundColor = .clear
    }
    
    
    // Keep a ref to the header to access selected high res Image
    var photoSelectorHeader: PhotoSelectorHeader?
    
    override func setupHeader(_ header: PhotoSelectorHeader) {
        
        // Extract the asset of selected image to retrieve a higher res version
        if let selectedImage = selectedImage {
            if let index = items.firstIndex(of: selectedImage) {
                let selectedAsset = assets[index]
                
                let imageManager = PHImageManager.default()
                
                let targetSize = CGSize(width: 600, height: 600)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, info) in
                    
                    header.selectedImageView.image = image
                    
                }
            }
        }
        
        photoSelectorHeader = header
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedImage = items[indexPath.item]
        
        collectionView.reloadData()
        
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    private var selectedImage: UIImage?
    
    private var assets = [PHAsset]()
    
    fileprivate func assetsFetchOptions() -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 50
        
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor] 
        
        return fetchOptions
    }
    
    fileprivate func fetchPhotos() {
        
        let allPhotos = PHAsset.fetchAssets(with: .image, options: assetsFetchOptions())
        
        DispatchQueue.global(qos: .background).async {
            allPhotos.enumerateObjects { (asset, index, stop) in
                let imageManager = PHImageManager.default()
                
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, info) in
                    if let image = image {
                        self.items.append(image)
                        
                        self.assets.append(asset)
                        
                        // Set initial selected image to 1st one
                        if self.selectedImage == nil {
                            self.selectedImage = image
                        }
                    }
                    
                    if index == allPhotos.count - 1 {
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
        }
        
       
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3 * 1) / 4
        
        return .init(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 1, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        
        return .init(width: view.frame.width, height: width)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    fileprivate func setupNavButtons() {
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
        
        title = "Select a photo"
    }
    
    @objc func handleCancel() {
        dismiss(animated: true)
    }
    
    @objc func handleNext() {
        let sharePhotoController = SharePhotoController()
        sharePhotoController.selectedImage = self.photoSelectorHeader?.selectedImageView.image
        navigationController?.pushViewController(sharePhotoController, animated: true)
    }
}
