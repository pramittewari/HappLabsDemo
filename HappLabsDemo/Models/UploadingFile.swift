//
//  UploadingFile.swift
//  HappLabsDemo
//
//  Created by Pramit on 30/03/20.
//  Copyright © 2020 Pramit Tewari. All rights reserved.
//

import Foundation
import UIKit

let maxChunkSize: UInt64 = 5242880

class UploadingFile {
    
    var filePath: String?
    var fileName: String?
    var partNumber: UInt64 = 0
    var totalSize: UInt64?
    var fileNameHex: String?
    var uploadId: String?
    var fileExtension: String?
    var fileHandle: FileHandle?
    var eTags: [[String: Any]] = []
    
    var hasUploadedAllChunks: Bool {
        
        let totalFileSize = CGFloat(totalSize ?? 0)
        let chunkSizeLimit = CGFloat(maxChunkSize)
        let currentPartNumber = CGFloat(partNumber)
        
        return currentPartNumber > (totalFileSize/chunkSizeLimit).rounded(.up)
    }
    
    init(withFileURL fileURL: String) {
        
        filePath = fileURL
        
        guard let url = URL(string: fileURL) else {
            fileName = "Unnamed file"
            return
        }
        
        fileName = url.lastPathComponent
        fileExtension = url.pathExtension
        totalSize = url.fileSize
        print("Initiaised file size \(totalSize ?? 0)")
        // fileHandle = FileHandle(forReadingAtPath: fileURL)
        do {
            fileHandle = try FileHandle(forReadingFrom: url)
        } catch {
            print(error.localizedDescription)
        }
        
        partNumber = 1
    }
    
    func updateAfterUpload(fileNameHex: String?, uploadId: String?) {
        
        self.fileNameHex = fileNameHex
        self.uploadId = uploadId
    }
    
    func collectETag(withValue value: String?) {
        
        let currentETag: [String: Any] = [
            "PartNumber": partNumber,
            "ETag": value ?? ""
        ]
        eTags.append(currentETag)
        partNumber += 1
    }
    
    func getNextDataChunk() -> Data? {
        
        var offset: UInt64 = (partNumber - 1) * maxChunkSize
        offset = offset < 0 ? 0 : offset
        
        if #available(iOS 13.0, *) {
            do {
                try fileHandle?.seek(toOffset: offset)
            } catch {
                // Handle error
                return nil
            }
            
        } else {
            // Fallback on earlier versions
            fileHandle?.seek(toFileOffset: offset)
        }
        
        var length: UInt64 = 0
        if (totalSize ?? 0) > offset + maxChunkSize {
            length = maxChunkSize
        } else {
            length = (totalSize ?? 0) - offset
        }
        
        length = length < 0 ? 0 : length
        return fileHandle?.readData(ofLength: Int(length))
    }
    
    func clearData() {
        
        filePath = nil
        fileName = nil
        partNumber = 0
        fileNameHex = nil
        fileHandle = nil
        eTags.removeAll()
    }
}
