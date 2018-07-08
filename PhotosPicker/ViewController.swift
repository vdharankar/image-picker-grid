//
//  ViewController.swift
//  PhotosPicker
//
//  Created by vishal dharnkar on 04/03/18.
//  Copyright © 2018 PhotosPicker. All rights reserved.
//

import UIKit

class ViewController: UIViewController , PhotoPickerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
      
        let photoPicker = PhotoPickerController.createPhotoPickerController()
        photoPicker.padding = 3
        photoPicker.itemsPerRow = 4
        photoPicker.delegate = self
        
        //self.navigationController?.pushViewController(photoPicker, animated: true)
        self.present(photoPicker, animated: true, completion: nil)
    }
    func getSelectedImages(images: Array<UIImage>) {
        print("Count : \(images.count)")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

