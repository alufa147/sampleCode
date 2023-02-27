//
//  File.swift
//  KaishanoKaizen
//
//  Created by 北条ようた on 2022/01/20.
//

import Foundation

struct File {
    let path: String
    
    static let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    
    static let documentDirectory = File(path: documentDirectoryPath)
    
}

extension File {
    
    var exists: Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
    var url: URL {
        return URL(fileURLWithPath: path)
    }
    
    var data: Data? {
        return try? Data(contentsOf: url)
    }
    
    var name: String {
        return (path as NSString).lastPathComponent
    }
    
    var nameWithoutExtension: String {
        return (name as NSString).deletingPathExtension
    }
    
    var files: [File] {
        return filesMap { self + $0 }
    }
    
    var filePaths: [String] {
        return filesMap { (self + $0).path }
    }
    
    var fileNames: [String] {
        return filesMap { $0 }
    }
    
   
    
    private func filesMap<T>(_ transform: (String) throws -> (T)) rethrows -> [T] {
        guard let fileNames = try? FileManager.default.contentsOfDirectory(atPath: path) else {
            return []
        }
        return try fileNames.map { try transform($0) }
    }
    
    func append(pathComponent: String) -> File {
        return File(path: (path as NSString).appendingPathComponent(pathComponent))
    }
    
    static func + (lhs: File,rhs: String) -> File {
        return lhs.append(pathComponent: rhs)
    }
    
    func makeDirectory() throws {
        if !exists {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    
    
    
}
