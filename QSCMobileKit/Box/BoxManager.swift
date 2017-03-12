//
//  BoxManager.swift
//  QSCMobileV3
//
//  Created by Zzh on 2017/2/20.
//  Copyright © 2017年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData
import ZipArchive

public class BoxManager: NSObject {
    
    /**
     Override just to make init() private.
     */
    private override init() {
        super.init()
    }
    
    public static let sharedInstance = BoxManager()
    
    private let managedObjectContext: NSManagedObjectContext = {
        let modelURL = Bundle(identifier: QSCMobileKitIdentifier)!.url(forResource: "Box", withExtension: "momd")!
        let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroupIdentifier)!.appendingPathComponent("Box.sqlite")
        
        let mom = NSManagedObjectModel(contentsOf: modelURL)!
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        try! psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moc.persistentStoreCoordinator = psc
        return moc
    }()
    
    // MARK: - Retrieval
    
    public var allFiles: [File] {
        let request: NSFetchRequest<File> = NSFetchRequest(entityName: "File")
        let files = try! managedObjectContext.fetch(request)
        return files
    }
    
    // MARK: - Creation
    
    public func newFile() -> File {
        let file = NSEntityDescription.insertNewObject(forEntityName: "File", into: managedObjectContext) as! File
        file.name = "-"
        file.directory = createRandomDirectory()
        file.code = "-"
        file.password = "-"
        file.secid = "-"
        file.state = "-"
        file.operationDate = Date()
        file.dueDate = Date().addingTimeInterval(Date.tenDaysInSeconds)
        file.progress = 0
        return file
    }
    
    private func createRandomDirectory() -> String {
        let boxFilesURL = getBoxFilesURL()
        while true {
            let directory = (arc4random() % 1000000 ) + 1000000
            let directoryURL = boxFilesURL.appendingPathComponent("\(directory)")
            if FileManager.default.fileExists(atPath: directoryURL.path) == false {
                try! FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
                return String(directory)
            }
        }
    }
    
    public func createRandomFileName(prefix: String, suffix: String) -> String {
        let shortDateWithoutDots = Date.dateToShortStringWithoutDots(date: Date())
        var count = 1
        while true {
            let fileName = String(format: "%@-%@-%02d.%@", prefix, shortDateWithoutDots, count, suffix)
            if getFileByFileName(fileName) == nil {
                return fileName
            }
            count += 1
        }
    }
    
    // MARK: - Deletion
    
    public func removeFile(file: File) {
        let boxFilesURL = getBoxFilesURL()
        let directoryURL = boxFilesURL.appendingPathComponent(file.directory)
        do {
            try FileManager.default.removeItem(at: directoryURL)
        } catch { }
        managedObjectContext.delete(file)
        try! managedObjectContext.save()
    }
    
    // MARK: - Get Info
    
    public func getBoxFilesURL() -> URL {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroupIdentifier)!.appendingPathComponent("BoxFiles")
    }
    
    public func getFileDirectoryURL(file: File) -> URL {
        return getBoxFilesURL().appendingPathComponent(file.directory)
    }
    
    public func getFileURL(file: File) -> URL {
        return getFileDirectoryURL(file: file).appendingPathComponent(file.name)
    }
    
    public func getUnzipURL(file: File) -> URL {
        return getFileDirectoryURL(file: file).appendingPathComponent("UnZip")
    }
    
    public func getFileByFileURL(_ fileURL: URL) -> File? {
        for file in allFiles {
            if getFileURL(file: file) == fileURL {
                return file
            }
        }
        return nil
    }
    
    public func getFileByFileName(_ fileName: String) -> File? {
        for file in allFiles {
            if file.name == fileName {
                return file
            }
        }
        return nil
    }
    
    // MARK: - Deal with Zip
    
    public func createZip(file: File, withFilesAtPaths: [String]) {
        let fileURL = BoxManager.sharedInstance.getFileURL(file: file)
        SSZipArchive.createZipFile(atPath: fileURL.path, withFilesAtPaths: withFilesAtPaths)
    }
    
    public func unzip(file: File) {
        let fileURL = BoxManager.sharedInstance.getFileURL(file: file)
        let unzipURL = BoxManager.sharedInstance.getUnzipURL(file: file)
        SSZipArchive.unzipFile(atPath: fileURL.path, toDestination: unzipURL.path)
        while true {
            var noSubZip = true
            for fileName in FileManager.default.enumerator(atPath: unzipURL.path)! {
                if "\(fileName)".hasSuffix(".zip") == true {
                    noSubZip = false
                    let subZipURL = unzipURL.appendingPathComponent("\(fileName)")
                    SSZipArchive.unzipFile(atPath: subZipURL.path, toDestination: subZipURL.path.components(separatedBy: ".")[0])
                    do {
                        try FileManager.default.removeItem(at: subZipURL)
                    } catch let error as NSError {
                        print("Error: \(error.domain)")
                    }
                }
            }
            if noSubZip {
                break
            }
        }
    }
    
    public func getUnzipFiles() {
        
    }
    
    // MARK: - Save
    
    public func saveFiles() {
        try! managedObjectContext.save()
    }
    
}
