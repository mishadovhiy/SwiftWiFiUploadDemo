//
//  FileManagerService.swift
//  SwiftWiFiUploadDemo
//
//  Created by Misha Dovhiy on 19.07.2024.
//

import Foundation

struct FileManagerService {
    func createDirectory(name:String) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let newDirectoryPath = documentsPath.appendingPathComponent("NewDirectory")
        do {
                try FileManager.default.createDirectory(at: newDirectoryPath, withIntermediateDirectories: true, attributes: nil)
                print("Directory created successfully at \(newDirectoryPath)")
            } catch {
                print("Error creating directory: \(error.localizedDescription)")
            }
    }
}
