//
//  ViewController.swift
//  Simple Face Detector
//
//  Created by Vivan on 27/03/20.
//  Copyright © 2020 The Ace Coder. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    
    struct Filters {
        let filterName:String
        var filterEffectValue: Any?
        var filterEffectValueName: String?
        
        init(filterName:String,filterEffectValue:Any?,filterEffectValueName:String?) {
            self.filterName = filterName
            self.filterEffectValue = filterEffectValue
            self.filterEffectValueName = filterEffectValueName
        }
    }

    @IBOutlet weak var imgView: UIImageView!
    private var originalImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        originalImage = imgView.image
    }
    
    private func applyFilterTo(image:UIImage, filterEffect: Filters) -> UIImage? {
        guard let cgImage = image.cgImage, let openGLContext = EAGLContext(api: .openGLES3) else {
            return nil
        }
        
        let context = CIContext(eaglContext: openGLContext)
        
        let ciImage = CIImage(cgImage: cgImage)
        let filter = CIFilter(name: filterEffect.filterName)
        
        filter?.setValue(ciImage, forKey:kCIInputImageKey)
        
        if let filterEffectValue = filterEffect.filterEffectValue,
            let filterEffectValueName = filterEffect.filterEffectValueName {
            filter?.setValue(filterEffectValue, forKey:filterEffectValueName)
        }
        
        var filteredImage:UIImage?
        
        if let output = filter?.value(forKey:kCIOutputImageKey) as? CIImage,
            let cgiImageResult = context.createCGImage(output, from: output.extent){
            filteredImage = UIImage(cgImage: cgiImageResult)
        }
        
        return filteredImage
        
        
        
    }
    
    //use for image picker from gallary
    @IBAction func btnImport(_ sender: Any) {
    
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Image Source", message: "Choose a source", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            imagePickerController.sourceType = .camera
            
            self.present(imagePickerController,animated: true,completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction) in
            // imagePickerController.sourceType = .photoLibrary
            let vc = UIImagePickerController()
            vc.sourceType = .camera
            vc.allowsEditing = true
            vc.delegate = self
            self.present(vc,animated: true,completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(actionSheet,animated: true,completion: nil)
        }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        imgView.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // below is our filters
    @IBAction func btnApplySepia(_ sender: Any) {
        guard let image = imgView.image else {
            return
        }
        imgView.image = applyFilterTo(image: image, filterEffect: Filters(filterName: "CISepiaTone", filterEffectValue: 0.95, filterEffectValueName: kCIInputIntensityKey))
    }
    
    @IBAction func btnApplyBlur(_ sender: Any) {
        guard let image = imgView.image else {
            return
        }
        imgView.image = applyFilterTo(image: image, filterEffect: Filters(filterName: "CIGaussianBlur", filterEffectValue: 8.0, filterEffectValueName: kCIInputRadiusKey))
        
    }
    
    @IBAction func btnApplyNoir(_ sender: Any) {
        guard let image = imgView.image else {
            return
        }
        imgView.image = applyFilterTo(image: image, filterEffect: Filters(filterName: "CIPhotoEffectNoir", filterEffectValue: nil, filterEffectValueName: nil))
        
    }
    
    @IBAction func btnApplyProcessEffect(_ sender: Any) {
        guard let image = imgView.image else {
            return
        }
        imgView.image = applyFilterTo(image: image, filterEffect: Filters(filterName: "CIPhotoEffectProcess", filterEffectValue: nil, filterEffectValueName: nil))
    }
    
    @IBAction func btnResetFilters(_ sender: Any) {
        imgView.image = originalImage
    }
    
    
    
}
    
