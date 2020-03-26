//
//  ListUploadsViewController.swift
//  HappLabsDemo
//
//  Created by Pramit on 24/03/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//

import UIKit

class ListUploadsViewController: BaseViewController<ListUploadsInteractor> {
    
    ///
    private lazy var galleryService = GalleryService(navigationController: self.navigationController)
    
    @IBAction func chooseVideoTapped(_ sender: UIButton) {
        
        showAlertToChooseMedia()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    ///
    func showAlertToChooseMedia() {
        
        galleryService.delegate = self
        galleryService.openGalleryCameraActionSheet()
        
    }
    
}

extension ListUploadsViewController: GalleryServiceDelegate {
    
    func getVideoResultFromGallery(video: MediaDetail) {
        
        print("VIDEO URL")
        print(video.videoUrl)
        
        guard let url = video.videoUrl else { return }
        interactor?.beginUpload(fromFileURL: url.absoluteString, fileSize: video.data?.count ?? 0, fileName: video.name ?? "\(Date())")
    }
    
    func cameraAuthorizationFailed(withMessage message: String, navigateToSettings: Bool) {
        
        showSettingsAlert(message: message)
    }
    
    func cameraResult(image: UIImage) {
    }
}
