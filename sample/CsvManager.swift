//
//  CsvManager.swift
//  KaishanoKaizen
//
//  Created by 北条ようた on 2022/01/24.
//

import Foundation

struct CsvManager {
    
    let dir = File.documentDirectory + "ピッキングリスト"
    var data: [String] {
        return loadData(filename: filename)
    }
    var filename: String
    var kisyuList: [String] {
        return self.loadKisyuList()
    }
    init(f: String) {
        filename = f
        makePikkingFile()
        
    }
    
    func makePikkingFile(){
        try? dir.makeDirectory()
    }
    
    func loadKisyuList() -> [String] {
        var kisyuList: [String] = []
        for kisyuname in dir.fileNames {
            kisyuList.append(kisyuname)
        }
        return kisyuList
    }
    func loadData(filename: String) -> [String]{
        var csvLines: [String] = []
        let dir = File.documentDirectory + "ピッキングリスト" + "\(filename)"
        do {
        let csvFile = try String(contentsOf: dir.url, encoding: .utf8)
            csvLines = csvFile.components(separatedBy: "\n")
            csvLines.removeLast()
        } catch {
            print(error)
        }
        return csvLines
    }
    func savePikkingData() -> [String] {
        var pikkingData: [String] = []
        let user = UserDefaults.standard
        for da in data {
            let ma = da.components(separatedBy: ",")
            pikkingData.append("\(ma[1]),\(user.integer(forKey: "\(ma[1])"))")
        }
        return pikkingData
    }
    
}
