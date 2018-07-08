//
//  PhotoPickerController.swift
//  PhotosPicker
//
//  Created by vishal dharnkar on 04/03/18.
//  Copyright © 2018 PhotosPicker. All rights reserved.
//

import UIKit

private let reuseIdentifier = "PictureCell"

extension UIViewController {
    
    var topbarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
}

protocol PhotoPickerDelegate {
    func getSelectedImages(images:Array<UIImage>)
}
class PhotoPickerController: UICollectionViewController,UICollectionViewDelegateFlowLayout {
    
    var itemsPerRow: CGFloat = 5 //default
    var padding: CGFloat = 15 // default , this can be overided
    fileprivate var sectionInsets : UIEdgeInsets?
    var photoReader : PhotosReader?
    var imageStatus : Array<Bool>?
    var delegate : PhotoPickerDelegate?
    var selectedImages : Array<UIImage>?
    var navbar : UINavigationBar?
    
    static func createPhotoPickerController() -> PhotoPickerController {
        let photoPicker = PhotoPickerController(nibName: "PhotoPickerController", bundle: nil)
        return photoPicker
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNeedsStatusBarAppearanceUpdate()
        
        sectionInsets = UIEdgeInsets(top: padding * 5, left:padding * 2, bottom: padding * 5, right: padding * 2)
       
        // Register cell classes
        self.collectionView!.register(UINib(nibName:"PictureViewCell", bundle: nil), forCellWithReuseIdentifier:reuseIdentifier)
    
        // Do any additional setup after loading the view.
        
        
        // below wrapper is responsible for gallery stuff
        photoReader = PhotosReader()
        
        // check the access if already granted
        photoReader?.requestGalleryAccess(grantedCallback: {
            
            // if access is granted then load images
            self.photoReader?.loadImages()
            
            // this array stores selected images (basically status )
            self.imageStatus = Array(repeating:false,count:(self.photoReader?.getCount())!)
            
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
            
        }, rejectedCallback: {
            // take care of this
        })
        
        // setup selected image array
        selectedImages = Array<UIImage>()
        
        setupView()
       
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
       
        let paddingSpace = (sectionInsets?.left)! * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets!
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets!.left
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets!.left
    }
    
    func setupView() {
        // setup title and buttons
     /*   self.navigationItem.title = "All Photos"
    
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.plain, target: self, action: #selector(actionClose(sender:)))
        
        // color the navigation bar
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]

     //   self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.darkGray
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        */
        
        navbar = UINavigationBar(frame: CGRect(x: 0, y:topbarHeight, width: UIScreen.main.bounds.width, height: 40))
        navbar?.barTintColor = UIColor.darkGray
        navbar?.tintColor = UIColor.white
        //  navbar.delegate = self as! UINavigationBarDelegate
        
        navbar?.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        view.addSubview(navbar!)
        
        collectionView?.frame = CGRect(x: 0, y: topbarHeight + 40, width:(collectionView?.collectionViewLayout.collectionViewContentSize.width)!, height:UIScreen.main.bounds.height - topbarHeight)
        
        if let sb = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView {
            sb.backgroundColor = UIColor.darkGray
        }

        
        // set the count on left item
        if let totalCount = self.photoReader?.getCount() {
            let navItem = UINavigationItem()
            
            navItem.title = "Photos"
            
            navItem.leftBarButtonItem = UIBarButtonItem(title: "0/\(String(describing:totalCount))", style: UIBarButtonItemStyle.plain, target: self, action: nil)
            
            navItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(actionClose(sender:)))
            
            navbar?.items = [navItem]
        }
    }
    
    @objc func actionClose(sender:UIView) {
        
        delegate?.getSelectedImages(images: selectedImages!)
        self.dismiss(animated: true, completion: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
       
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        return (photoReader?.getCount())!
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PictureViewCell
    
        if imageStatus![indexPath.row] == true {
            cell.layer.borderColor = UIColor.cyan.cgColor
        }
        else {
            cell.layer.borderColor = UIColor.clear.cgColor
        }
        
        cell.layer.borderWidth = 3.0
        cell.tag = (photoReader?.getImage(index: indexPath.row,cellTag: cell.tag, completionCallBack: { (image) in
            cell.pictureImageView.image = image
        }))!
        
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Image is selected")
        var status = imageStatus![indexPath.row]
        status = !status
        
        imageStatus![indexPath.row] = status
        let cell = collectionView.cellForItem(at: indexPath) as! PictureViewCell
        
        if status == false {
            let image = cell.pictureImageView.image
            deleteImageFromSelected(image: image!)
        }
        else {
            selectedImages?.append(cell.pictureImageView.image!)
        }
       
        if let totalCount = photoReader?.getCount() {
             if let selectedCount = selectedImages?.count {
            
              //  self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "\(String(describing: selectedCount))/\(String(describing: totalCount))", style: UIBarButtonItemStyle.plain, target: self, action: nil)
                
                let navItem = UINavigationItem()
                
                navItem.title = "All Photos"
                
                navItem.leftBarButtonItem = UIBarButtonItem(title: "\(String(describing: selectedCount))/\(String(describing:totalCount))", style: UIBarButtonItemStyle.plain, target: self, action: nil)
                
                navItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.plain, target: self, action: #selector(actionClose(sender:)))
                
                navbar?.items = [navItem]
            }
        }
        collectionView.reloadData()
        
    }
    func deleteImageFromSelected(image:UIImage) {
        if let index = selectedImages?.index(of: image) {
            selectedImages?.remove(at: index)
        }
    }
    
}



