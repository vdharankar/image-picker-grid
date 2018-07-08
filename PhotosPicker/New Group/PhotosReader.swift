//
//  PhotosReader.swift
//  PhotosPicker
//
//  Created by vishal dharnkar on 09/03/18.
//  Copyright © 2018 PhotosPicker. All rights reserved.
//

import UIKit
import Photos

class PhotosReader: NSObject {
    fileprivate var images = [PHAsset]()
    
    func loadImages() {
        let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
        assets.enumerateObjects({ (object, count, stop) in
            // self.cameraAssets.add(object)
            self.images.append(object)
        })
        
        //In order to get latest image first, we just reverse the array
        self.images.reverse()
        
    }
    func getCount() -> Int { return images.count }
    
    func getImage(index:Int,cellTag:Int,completionCallBack:@escaping (UIImage) -> Void) -> Int{
        let manager = PHImageManager.default()
        
        if cellTag != 0 {
            manager.cancelImageRequest(PHImageRequestID(cellTag))
        }
        
        let asset = images[index]
        let tag = Int(manager.requestImage(for: asset,
                                            targetSize: CGSize(width: 120.0, height: 120.0),
                                            contentMode: .aspectFill,
                                            options: nil) { (result, _) in
                                                completionCallBack(result!)
        })
        return tag
        
    }
    func getImage(index:Int,completionCallBack:@escaping (UIImage) -> Void) -> Int{
        let manager = PHImageManager.default()
    
        let asset = images[index]
        let tag = Int(manager.requestImage(for: asset,
                                           targetSize: CGSize(width: 120.0, height: 120.0),
                                           contentMode: .aspectFill,
                                           options: nil) { (result, _) in
                                            completionCallBack(result!)
        })
        return tag
        
    }
    func requestGalleryAccess(grantedCallback:@escaping ()->(),rejectedCallback:@escaping ()->()) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        if (status == PHAuthorizationStatus.authorized) {
            // Access has been granted.
            grantedCallback()
        }
            
        else if (status == PHAuthorizationStatus.denied) {
            // Access has been denied.
            rejectedCallback()
        }
            
        else if (status == PHAuthorizationStatus.notDetermined) {
            
            // Access has not been determined.
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                
                if (newStatus == PHAuthorizationStatus.authorized) {
                    grantedCallback()
                }
                    
                else {
                    rejectedCallback()
                }
            })
        }
            
        else if (status == PHAuthorizationStatus.restricted) {
            // Restricted access - normally won't happen.
        }
    }
}
