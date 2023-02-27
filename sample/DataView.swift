//
//  DataView.swift
//  KaishanoKaizen
//
//  Created by 北条ようた on 2022/01/24.
//

import SwiftUI

struct DataView: View {
    
    @State var data: [TimeData] = []
    @State var kisyuList: [Kisyu] = []
    @State var kisyu = "機種名を押して選択"
    var body: some View {
        VStack{
        HStack{
            
            
            VStack{
                Text("機種選択: \(kisyu)")
        ForEach(kisyuList) { value in
            Button(action: {
                kisyu = value.name

            }, label: {
                Text("\(value.name)")
            }).padding()
        }
            }
            Button(action: {
                loadData()
            }, label: {Text("データを見る")})
        }
        List(data){ data in
            DataRow(data: data)
        }
        }.onAppear(perform: {
            setKisyu()
        })
    }
    
    func setKisyu(){
        kisyuList = []
        let csvManager = CsvManager.init(f: "")
        var num = 0
        for data in csvManager.kisyuList {
             kisyuList += [Kisyu(id: num, name: data)]
             num += 1
        }
        
    }
    
    func loadData(){
        self.data = []
        let data = TimeDataManager.init(KISYUNAME: kisyu)
        var num = 0
        for da in data.DATA {
            let line = da.components(separatedBy: ",")
            self.data += [TimeData(id: num, rotNum: line[1], startTime: line[2], pikkingTime: line[3])]
            num += 1
        }
    }
    
//    func timeSelecter(startTime: String, endTime: String) -> Int {
//        let startDay = strEdit(str: startTime, start: 5, end: 6)
//        let endDay = strEdit(str: endTime, start: 5, end: 6)
//        let startHour = strEdit(str: startTime, start: 11, end: 12)
//        let endHour = strEdit(str: endTime, start: 11, end: 12)
//        let startMinute = strEdit(str: startTime, start: 14, end: 15)
//        let endMinute = strEdit(str: endTime, start: 14, end: 15)
//        if startDay == endDay && startHour < 10 && endHour <= 12 && end
//                            //日だったら
//        //日を跨いだら
//
//    }
    
    
    func strEdit(str: String, start: Int, end: Int) -> Int {
        return Int(str[str.index(str.startIndex, offsetBy: start)..<str.index(str.startIndex, offsetBy: end)]) ?? 0
    }
}

struct DataRow: View {
    var data: TimeData
    var body: some View{
        HStack{
            Text("\(data.rotNum)")
            Text(data.startTime)
            Text(data.pikkingTime)
        }
    }
}

struct TimeData: Identifiable {
    var id: Int
    var rotNum: String
    var startTime: String
    var pikkingTime: String
}

struct DataView_Previews: PreviewProvider {
    static var previews: some View {
        DataView()
    }
}
