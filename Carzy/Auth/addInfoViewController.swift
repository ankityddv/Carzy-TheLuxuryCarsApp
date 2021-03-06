//
//  addInfoViewController.swift
//  Carzy
//
//  Created by ANKIT YADAV on 23/12/19.
//  Copyright © 2019 ANKIT YADAV. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import SVProgressHUD

class addInfoViewController: UIViewController {
    
    var ref:DatabaseReference?
    var selectedImage: UIImage?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var mobileField: UITextField!
    @IBOutlet weak var continueBttn: UIButton!
    @IBAction func continueBttn(_ sender: Any) {
        updateAllInfo()
        self.performSegue(withIdentifier: "signUp", sender: self)
        //go to nav bar
        //let vc = storyboard?.instantiateViewController(withIdentifier: "tabBar") as! UITabBarController
        //self.appDelegate.window?.rootViewController = vc
    }
    
    
    @objc func openImagePicker(_ sender:Any) {
        // Open Image Picker
        let pickerController = UIImagePickerController()
        pickerController.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
        present(pickerController, animated: true, completion: nil)
    }
    func updateAllInfo() {
        updateData()
        updateProfileImage()
    }
    
    func updateProfileImage(){
        
        let storageRef = Storage.storage().reference().child("user/profile_images")
        let profileImg = self.selectedImage
        
        guard let imageData = profileImg?.jpegData(compressionQuality: 0.2) else { return }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let ImageRef = storageRef.child("\(uid).png")
        let uploadTask = ImageRef.putData(imageData, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                return
            }
            let size = metadata.size
            ImageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    return
                }
            }
        }
    }
    func updateData() {
        self.ref = Database.database().reference()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if self.mobileField.text != "" && self.nameField.text != ""
        {
            self.ref?.child("USER").child(uid).setValue(["Name" : self.nameField.text ,"Phone" : self.mobileField.text])
        }
        else
        {
            print("error")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        continueBttn.layer.cornerRadius = 10
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(imageTap)
        imageView.layer.cornerRadius = 75
            //imageView.bounds.height / 2
        imageView.clipsToBounds = true
        
        //Hide Keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardwilchange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardwilchange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardwilchange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    // MARK: - hide/show keyboard

        deinit {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        }
        
        func hideKeyboard(){
            view.resignFirstResponder()
        }
        
        @objc func keyboardwilchange(notification: Notification){
            view.frame.origin.y = -200
            imageView.frame = CGRect(x: 157, y: 243, width: 100, height: 100)
            imageView.layer.cornerRadius = 50
        }
        
        //UITextFieldDeligate Methods
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            hideKeyboard()
            return true
        }
        
        //Hide when touch outside keyboard
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
            view.frame.origin.y = 0
            imageView.layer.cornerRadius = 75
            imageView.frame = CGRect(x: 131, y: 173, width: 150, height: 150)
        }

    }

    extension addInfoViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
                selectedImage = image
                imageView.image = image
            }
            dismiss(animated: true, completion: nil)
        }
    }

