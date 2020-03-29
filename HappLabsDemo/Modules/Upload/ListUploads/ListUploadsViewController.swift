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
    @IBOutlet weak var uploadedFilesTable: UITableView!
    ///
    @IBOutlet weak var noContentLabel: UILabel!
    ///
    @IBOutlet weak var uploadProgressView: UIProgressView!
    ///
    @IBOutlet weak var uploadProgressViewHeight: NSLayoutConstraint!
    
    ///
    private lazy var galleryService = GalleryService(navigationController: self.navigationController)
    
    @IBAction func chooseVideoTapped(_ sender: UIButton) {
        
        showAlertToChooseMedia()
    }
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        
        interactor?.logOutUser()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        interactor?.fetchUploadedFiles()
    }
    
    ///
    func showAlertToChooseMedia() {
        
        galleryService.delegate = self
        galleryService.openGalleryCameraActionSheet()
        
    }
    
    ///
    func setupView(withFiles files: [UploadedFile]) {
        
        uploadedFilesTable.reloadData()
        setNoContentLabel()
    }
    
    ///
    func setupUI() {
        
        uploadedFilesTable.tableFooterView = UIView()
    }
    
    ///
    func setNoContentLabel() {
        
        noContentLabel.isHidden = !((interactor?.uploadedFiles.count ?? 0) == 0)
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
    
    func cameraResult(image: UIImage) { }
}

extension ListUploadsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interactor?.uploadedFiles.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.uploadedFileCell.identifier) as? UploadedFileCell else {
            return UITableViewCell()
        }
        cell.fileNameLabel.text = interactor?.uploadedFiles[indexPath.row].name ?? "Unnamed file"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let file = interactor?.uploadedFiles[indexPath.row] else { return }
        showOkAlert(message: "\(file.name ?? "Unnamed file")\n\(file.size ?? "0") bytes")
    }
}
