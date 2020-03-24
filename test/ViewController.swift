//
//  ViewController.swift
//  test
//
//  Created by HaLam on 10/24/17.
//  Copyright © 2017 HaLam. All rights reserved.
//

import UIKit
import AWSCore
import AWSS3
import AWSCognito

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.APSoutheast2,
                                                                identityPoolId:"PLACE_YOUR_KEY_HERE")
        let configuration = AWSServiceConfiguration(region:.APSoutheast2, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
    }
    
    @IBAction func touchUp(_ sender: UIButton) {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary;
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
//        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
//            imagePicker.delegate = self
//            imagePicker.sourceType = .photoLibrary;
//            imagePicker.allowsEditing = false
//            present(imagePicker, animated: true, completion: nil)
//        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedVideoURL: URL
        if #available(iOS 11.0, *) {
            selectedVideoURL = info[UIImagePickerControllerImageURL] as! URL
        } else {
            selectedVideoURL = info[UIImagePickerControllerMediaURL] as! URL
        }
        uploadToS3(fileURL: selectedVideoURL)
        picker.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func uploadToS3(fileURL: URL) {
        let transferManager = AWSS3TransferManager.default()
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.bucket = "zoodle.file.storage"
        uploadRequest?.key = "lam_test.jpg"
        uploadRequest?.body = fileURL
//        uploadRequest?.acl = .publicRead
        
        transferManager.upload(uploadRequest!)
            .continueWith {
                task -> Any? in
                guard (task.result != nil) else {
                    return nil
                }
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent((uploadRequest?.bucket!)!).appendingPathComponent((uploadRequest?.key!)!)
                if let absoluteString = publicURL?.absoluteString {
                    print("Uploaded to:\(absoluteString)")
                }
                return nil
        }
    }
    
    
    
}

