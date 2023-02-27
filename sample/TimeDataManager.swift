//
//  TimeDataManager.swift
//  KaishanoKaizen
//
//  Created by 北条ようた on 2022/01/24.
//

import Foundation

struct TimeDataManager {
    
    let userDefault = UserDefaults.standard
    
    var KISYUNAME: String
    var DATA: [String] {
        return loadDATA()
    }
    var ALLKISYU: [String] {
        return loadKISYUDATA()
    }
    
    
    
    func loadKISYUDATA() -> [String]{
        return userDefault.stringArray(forKey: "KISYU") ?? []
    }
    
    func loadDATA() -> [String]{
        return userDefault.stringArray(forKey: "\(KISYUNAME)") ?? []
    }
    
    func writeKISYUDATA(){
        var data = loadKISYUDATA()
        data.append(KISYUNAME)
        userDefault.setValue(data, forKey: "KISYU")
        userDefault.synchronize()
    }
    
    func writeDATA(data: String){
        var loaddata = loadDATA()
        loaddata.append(data)
        userDefault.setValue(loaddata, forKey: "\(KISYUNAME)")
    }
    
    
    
    func nowTime() -> String {
        let dt = Date()
        let dateFormatter = DateFormatter()

        // DateFormatter を使用して書式とロケールを指定する
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "ja_JP")
        print(dateFormatter.string(from: dt))
        return dateFormatter.string(from: dt)
    }
}
