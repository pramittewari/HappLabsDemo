//
//  ListUploadsViewController.swift
//  HappLabsDemo
//
//  Created by Pramit on 24/03/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//

import UIKit

class ListUploadsViewController: BaseViewController<ListUploadsInteractor> {
    
    // MARK: - Outlets
    @IBOutlet weak var uploadedFilesTable: UITableView!
    @IBOutlet weak var noContentLabel: UILabel!
    @IBOutlet weak var uploadProgressView: UIProgressView!
    @IBOutlet weak var uploadProgressViewHeight: NSLayoutConstraint! // Defaults to 60
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var uploadButton: UIButton!
    
    // MARK: - Variables
    private lazy var galleryService = GalleryService(navigationController: self.navigationController)
    
    // MARK: - Actions
    @IBAction func chooseVideoTapped(_ sender: UIButton) {
        
        guard !(interactor?.isUserLoggedOut ?? true) else {
            interactor?.presentSignInScreen()
            return
        }
        showAlertToChooseMedia()
    }
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        
        interactor?.logOutUser()
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        interactor?.fetchUploadedFiles()
        setButtonStates()
    }
    
    // MARK: - UI Methods
    func showAlertToChooseMedia() {
        
        galleryService.delegate = self
        galleryService.openGalleryCameraActionSheet()
        
    }
    
    func setupTable(withFiles files: [UploadedFile]) {
        
        uploadedFilesTable.reloadData()
        setNoContentLabel()
    }
    
    func setupUI() {
        
        setupProgressView(visibility: false)
    }
    
    func setNoContentLabel() {
        
        DispatchQueue.main.async { [weak self] in
            self?.noContentLabel.isHidden = !((self?.interactor?.uploadedFiles.count ?? 0) == 0)
        }
    }
    
    func updateProgressBar(withTotal total: UInt64, uploaded: UInt64) {
        
        let uploadedBytes = CGFloat(uploaded)
        let totalBytes = CGFloat(total)
        
        let value = Float(uploadedBytes/totalBytes) == 0.0 ? 0.03 : Float(uploadedBytes/totalBytes)
        DispatchQueue.main.async { [weak self] in
            self?.uploadProgressView.setProgress(value, animated: true)
        }
    }
    
    func setupProgressView(visibility: Bool) {
        
        uploadProgressViewHeight.constant = visibility ? 60 : 0
        DispatchQueue.main.async { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    func setButtonStates() {
        
        guard let isUserLoggedOut = interactor?.isUserLoggedOut,
            let isUploadInProgress = interactor?.isUploadInProgress else {
            setUploadButtonVisibility(false)
            setLogoutButtonVisibility(false)
            return
        }
        
            setUploadButtonVisibility(!isUploadInProgress)
            setLogoutButtonVisibility(!isUploadInProgress)
    }
    
    private func setUploadButtonVisibility(_ isVisible: Bool) {
        
        DispatchQueue.main.async { [weak self] in
            self?.uploadButton.isUserInteractionEnabled = isVisible
            self?.uploadButton.alpha = isVisible ? 1 : 0.5
        }
    }
    
    private func setLogoutButtonVisibility(_ isVisible: Bool) {
        
        DispatchQueue.main.async { [weak self] in
            self?.logoutButton.isEnabled = isVisible
        }
    }
}

// MARK: - Gallery Delegates
extension ListUploadsViewController: GalleryServiceDelegate {
    
    func getVideoResultFromGallery(video: MediaDetail) {
        
        guard let url = video.videoUrl else { return }
        interactor?.beginUpload(fromFileURL: url.absoluteString)
    }
    
    func cameraAuthorizationFailed(withMessage message: String, navigateToSettings: Bool) {
        
        showSettingsAlert(message: message)
    }
    
    func cameraResult(image: UIImage) { }
}

// MARK: - Table delegates and datasources
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
        showOkAlert(message: "\(file.name ?? "Unnamed file")\n\nSIZE: \(file.size ?? "0") bytes")
    }
}

// MARK: - Upload Delegate
extension ListUploadsViewController: UploadUpdatesDelegate {
    
    func uploadBegan(forTotalSize totalSize: UInt64) {
        
        UIApplication.shared.isIdleTimerDisabled = true
        setButtonStates()
        updateProgressBar(withTotal: totalSize, uploaded: 0)
        setupProgressView(visibility: true)
    }
    
    func uploadProgressChanged(withUploadedBytes uploadedBytes: UInt64, totalSize: UInt64) {
        
        setButtonStates()
        updateProgressBar(withTotal: totalSize, uploaded: uploadedBytes)
    }
    
    func uploadEnded(withSuccess success: Bool, message: String?) {
        
        UIApplication.shared.isIdleTimerDisabled = false
        setButtonStates()
        setupProgressView(visibility: false)
        updateProgressBar(withTotal: 1, uploaded: 0)
        if success {
            
            showAlert(message: "Upload successful!", buttonTitles: ["Okay"], customAlertViewTapButtonBlock: { [weak self] _ in
            
                self?.interactor?.fetchUploadedFiles()
            
                }, isHighPriority: true)
            
        } else {
            showOkAlert(message: message ?? "Upload ended!")
        }
    }
}
