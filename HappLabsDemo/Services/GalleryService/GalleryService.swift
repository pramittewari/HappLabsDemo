//
//  NetworkService.swift
//  HappLabsDemo
//
//  Created by Pramit on 23/03/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//

import UIKit
import Photos
import AVKit
import CoreServices

/// Gallery Extension
enum AttachmentType: String {
    case camera, video, photoLibrary
}

///
protocol GalleryServiceDelegate: class {
    
    ///
    func cameraAuthorizationFailed(withMessage message: String, navigateToSettings: Bool)
    
    ///
    func cameraResult(image: UIImage)
    
    ///
    func getVideoResultFromGallery(video: MediaDetail)
}
///
class GalleryService: NSObject {
    
    // MARK: - Variable
    
    ///
    private weak var navigationController: UINavigationController?
    ///
    weak var delegate: GalleryServiceDelegate?
    ///
    private lazy var myPickerController = UIImagePickerController()
    ///
    //var maxVideoDurationAllowed: Int = 240
    
    // MARK: - Life cycle method
    
    ///
    override init() {
    }
    
    ///
    convenience init(navigationController: UINavigationController?) {
        self.init()
        
        self.navigationController = navigationController
    }
    
    // MARK: - Camera methods
    
    ///
    func openGalleryCameraActionSheet(withFrontCamera isFrontCam: Bool = false) {
        let alert = UIAlertController(title: "", message: "Please select any option", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self](_) in
            self?.openCamera(withFrontCamera: isFrontCam)
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { [weak self](_) in
            self?.openGallery(forVideosOnly: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
        }))
        
        navigationController?.present(alert, animated: true, completion: {
        })
    }
    
    ///
    func openCamera(withFrontCamera isFrontCam: Bool = false) {

        openCameraAfterAuthorization(withFrontCamera: isFrontCam)
    }
    
    ///
    private func openCameraAfterAuthorization(withFrontCamera isFrontCam: Bool = false) {
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                DispatchQueue.main.async { [weak self] in
                    self?.myPickerController.delegate = self
                    self?.myPickerController.sourceType = .camera
                    if let mediaType = (NSArray(objects: kUTTypeMovie) as? [String]) {
                        self?.myPickerController.mediaTypes = mediaType
                    }
                    self?.myPickerController.cameraDevice =  isFrontCam ? .front : .rear
                    self?.myPickerController.cameraCaptureMode = .video
                    // myPickerController.allowsEditing = true
                    //   DispatchQueue.main.async { [weak self] in
                    self?.navigationController?.present(self?.myPickerController ?? UIImagePickerController(), animated: true, completion: nil)
                }
                // }
            }
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] (granted: Bool) in
                if granted {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {

                        DispatchQueue.main.async {
                            
                            self?.myPickerController.delegate = self
                            self?.myPickerController.sourceType = .camera
                            if let mediaType = (NSArray(objects: kUTTypeMovie) as? [String]) {
                                self?.myPickerController.mediaTypes = mediaType
                            }
                            self?.myPickerController.cameraCaptureMode = .video
                            self?.myPickerController.cameraDevice = isFrontCam ? .front : .rear
                            //  myPickerController.allowsEditing = true
                            self?.navigationController?.present(self?.myPickerController ?? UIImagePickerController(), animated: true, completion: nil)
                        }
                    }
                } else {
                    //access denied
                    self?.delegate?.cameraAuthorizationFailed(withMessage: "'HappLabsDemo' needs authorisation to you camera.", navigateToSettings: true)
                }
            })
        }
    }
    
    /// Opens camera in video mpde
    func openLiveVideoCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            if let mediaType = (NSArray(objects: kUTTypeMovie) as? [String]) {
                imagePicker.mediaTypes = mediaType
            }

            imagePicker.cameraCaptureMode = .video
            imagePicker.videoQuality = .typeHigh
            //imagePicker.videoMaximumDuration = TimeInterval(maxVideoDurationAllowed)
            imagePicker.allowsEditing = false
            //  imagePicker.showsCameraControls = true
            imagePicker.modalPresentationStyle = .fullScreen
            if #available(iOS 13.0, *) {
                imagePicker.overrideUserInterfaceStyle = .light
            }
            navigationController?.present(imagePicker, animated: true, completion: nil)
        }
    }
    ///
    private func openGallery(forVideosOnly: Bool = false) {
        myPickerController.delegate = self
        myPickerController.sourceType = .savedPhotosAlbum

        if forVideosOnly, let mediaType = (NSArray(objects: kUTTypeMovie) as? [String]) {
            myPickerController.mediaTypes = mediaType
        }
        navigationController?.present(myPickerController, animated: true, completion: nil)
    }
        
}

// MARK: - Gallery Delegate Methods

///
extension GalleryService: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let pickedVideoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            //Video
            let mediaObj = MediaDetail()
            mediaObj.type = .video
            
            if let thumbnail = getPreviewImageForVideoAtURL(pickedVideoUrl as URL, atInterval: 1) {
                mediaObj.thumbnailImage = thumbnail
            }

            if picker.sourceType == .camera {

                let status = PHPhotoLibrary.authorizationStatus()
                
                switch status {
                case .authorized:
                    // AUTHORISED
                    PHPhotoLibrary.shared().performChanges({
                        let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: pickedVideoUrl as URL)
                        print(request?.placeholderForCreatedAsset?.localIdentifier ?? "nil")
                        self.encodeVideoToMp4(videoUrl: pickedVideoUrl as URL, resultClosure: { [weak self](outputUrl) in
                            print(outputUrl ?? "")
                            mediaObj.videoUrl = outputUrl
                            DispatchQueue.main.async {
                                self?.navigationController?.dismiss(animated: true, completion: { [weak self] in
                                    //mediaObj.videoUrl = outputUrl
                                    guard let outputUrl = outputUrl, let mp4data =  NSData(contentsOf: outputUrl) else { return }
                                    mediaObj.data = mp4data as Data?
                                    self?.delegate?.getVideoResultFromGallery(video: mediaObj)
                                })
                            }
                        })
                        
                    }, completionHandler: { (success, error) in
                        if success {
                            print("Video Saved")
                        } else {
                            print("Error in Video Saving: \(error?.localizedDescription ?? "")")
                        }
                    })
                case .denied:
                    delegate?.cameraAuthorizationFailed(withMessage: "HappLabsDemo needs authorisation to you photo library.", navigateToSettings: true)
                    
                case .notDetermined:
                    // Permission not determined
                    PHPhotoLibrary.requestAuthorization({ [weak self] (status) in
                        if status == PHAuthorizationStatus.authorized {
                            // photo library access given
                            PHPhotoLibrary.shared().performChanges({
                                let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: pickedVideoUrl as URL)
                                print(request?.placeholderForCreatedAsset?.localIdentifier ?? "nil")
                                self?.encodeVideoToMp4(videoUrl: pickedVideoUrl as URL, resultClosure: { [weak self](outputUrl) in
                                    print(outputUrl ?? "")
                                    mediaObj.videoUrl = outputUrl
                                    DispatchQueue.main.async {
                                        self?.navigationController?.dismiss(animated: true, completion: { [weak self] in
                                            //mediaObj.videoUrl = outputUrl
                                            guard let outputUrl = outputUrl, let mp4data =  NSData(contentsOf: outputUrl) else { return }
                                            mediaObj.data = mp4data as Data?
                                            self?.delegate?.getVideoResultFromGallery(video: mediaObj)
                                        })
                                    }
                                })
                                
                            }, completionHandler: { (success, error) in
                                if success {
                                    print("Video Saved")
                                } else {
                                    print("Error in Video Saving: \(error?.localizedDescription ?? "")")
                                }
                            })
                        } else {
                            // Restricted manually
                            self?.delegate?.cameraAuthorizationFailed(withMessage: "HappLabsDemo needs authorisation to you photo library.", navigateToSettings: true)
                        }
                    })
                case .restricted:
                    delegate?.cameraAuthorizationFailed(withMessage: "HappLabsDemo needs authorisation to you photo library.", navigateToSettings: true)

                default: break
                }

            } else {
                guard let url = ((info as NSDictionary)).object(forKey: "UIImagePickerControllerMediaURL") as? NSURL else {
                    navigationController?.dismiss(animated: true, completion: nil)
                    return
                }
                encodeVideoToMp4(videoUrl: url as URL, resultClosure: { [weak self](outputUrl) in
                    print(outputUrl ?? "" )
                    self?.navigationController?.dismiss(animated: true, completion: { [weak self] in
                        mediaObj.videoUrl = outputUrl
                        guard let outputUrl = outputUrl, let mp4data =  NSData(contentsOf: outputUrl) else { return }
                        mediaObj.data = mp4data as Data?
                        self?.delegate?.getVideoResultFromGallery(video: mediaObj)
                    })
                })
            }
            
        } else {
            // To handle image
            if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                delegate?.cameraResult(image: image)
                navigationController?.dismiss(animated: true, completion: nil)
            } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                delegate?.cameraResult(image: image)
                navigationController?.dismiss(animated: true, completion: nil)
            } else {
                navigationController?.dismiss(animated: true, completion: { [weak self] in

                    self?.delegate?.cameraAuthorizationFailed(withMessage: "SOMETHING_WENT_WRONG! Please try again!", navigateToSettings: false)
                })
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Video Helper Methods
    ///
    func
        encodeVideoToMp4(videoUrl: URL, outputUrl: URL? = nil, resultClosure: @escaping (URL?) -> Void ) {
        
        //2019/10
        var finalOutputUrl: URL? = outputUrl == nil ? videoUrl : outputUrl
        
        if outputUrl == nil {
            let lastPathCompo = videoUrl.lastPathComponent
            let writePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(lastPathCompo)
            finalOutputUrl = writePath
        }
        
        //2019/10
        if let path = finalOutputUrl?.path, FileManager.default.fileExists(atPath: path) {
            print("Converted file already exists \(path)")
            resultClosure(finalOutputUrl)
            return
        }
        
        let asset = AVURLAsset(url: videoUrl)
        //2019/10
        if let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetLowQuality), let finalURL = finalOutputUrl {
            //if let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough) {
            
            exportSession.outputURL = finalURL
            exportSession.outputFileType = AVFileType.mp4
            let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
            let range = CMTimeRangeMake(start: start, duration: asset.duration)
            exportSession.timeRange = range
            exportSession.shouldOptimizeForNetworkUse = true
            
            exportSession.exportAsynchronously {
                
                switch exportSession.status {
                case .failed:
                    print("Export failed: \(exportSession.error != nil ? exportSession.error?.localizedDescription ?? "No Error Info" : "No Error Info")")
                    
                    DispatchQueue.main.async {
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }
                case .cancelled:
                    print("Export canceled")
                    DispatchQueue.main.async {
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }
                case .completed:
                    DispatchQueue.main.async {
                        resultClosure(finalURL)
                    }
                default:
                    break
                }
            }
        } else {
            resultClosure(nil)
        }
    }
    
    func getPreviewImageForVideoAtURL(_ videoURL: URL, atInterval: Int) -> UIImage? {
        print("Taking pic at \(atInterval) second")
        let asset = AVAsset(url: videoURL)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(Float64(atInterval), preferredTimescale: 100)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let frameImg = UIImage(cgImage: img)
            return frameImg
        } catch {
        }
        return nil
    }
}
