//
//  PikkingView.swift
//  KaishanoKaizen
//
//  Created by 北条ようた on 2022/01/18.
//

import SwiftUI
import AVFoundation


struct DaisyaKinds: Identifiable {
    var id: Int
    var name: String
    var color: Color
}

struct PikkingView: View {
    let wid = UIScreen.main.bounds.width
    @State var dataManager = TimeDataManager(KISYUNAME: "")
    @State var production : [Production] = []
    @State var daisyaKinds: [DaisyaKinds] = []
    @State var kensaku: [Kensaku] = []
    @State var daisya: [String] = []
    @State var filename: String
    @State var rotnum: Int
    @State static var daisyaKindNum = 0
    @State var num = 0
    @State var csv = CsvManager(f: "")
    @State var kensakuButton = "部品検索"
    @State var dataButton = "データ"
    
    @State var page = 0
    @State var buhinNum = ""
    @State var BUHINNUM = ""
    
    @State var end = false
    @State var data: String
    
    let reader = QRCodeReader()
    
    
    var body: some View {
        VStack{
            HStack{
            Button(action: {
                switch(page){
                case 0:
                    page = 1
                    kensakuButton = "リストに戻る"
                    break
                case 1:
                    page = 0
                    kensakuButton = "部品検索"
                    break
                case 2:
                    page = 1
                    kensakuButton = "リストに戻る"
                    break
                default:
                    page = 0
                    break
                }
             }, label: { Text("\(kensakuButton)")})
                
                Button(action: {
                    end.toggle()
                }, label: {
                    Text("終了")
                }).padding()
                .alert(isPresented: $end, content: {
                    Alert(title: Text("ピッキングを終了しますか？"), primaryButton: .cancel(), secondaryButton: .default(Text("OK"), action: {
                        dataManager = TimeDataManager(KISYUNAME: filename)
                        dataManager.writeDATA(data: "\(data),\(dataManager.nowTime())")
                        UserDefaults.standard.setValue(csv.savePikkingData(), forKey: "\(data)")
                        removePikking()
                        exit(0)
                        
                    }))
                })

                
                
            }
        if page == 0 {
        VStack{
            HStack{
                ForEach(daisyaKinds){ dai in
                    Button(action: {
                        loadcsv(id: dai.id)
                        loadDaisyaKinds(id: dai.id)
                        }, label: {
                        Text("\(dai.name)")
                        }).frame(width: wid/CGFloat(daisyaKinds.count+2), height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).background(dai.color)
                    }
                }
            HStack{
                Text("台車").frame(width: wid*0.03, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).font(.caption2)
                Text("部品番号").frame(width: wid*0.17, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).font(.caption2)
                Text("部品名").frame(width: wid*0.25, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).font(.caption2)
                Text("数/１台").frame(width: wid*0.03, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).font(.caption2)
                Text("業者").frame(width: wid*0.2, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).font(.caption2)
                Text("要求数量").frame(width: wid*0.03, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).font(.caption2)
                Text("備考").frame(width: wid*0.05, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).font(.caption2)
                Text("アドレス").frame(width: wid*0.15, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).font(.caption2)
            }
            
            List(production){ production in
                buhinRow(production: production)
            }
            
            }.onAppear(perform: {
            csv = CsvManager.init(f: filename)
            getdaisyaCount()
            daisya = narabekae()
            loadcsv(id: 0)
            loadDaisyaKinds(id: 0)
            
                reader.delegate = Delegate(read: reader)
        })
        }
        if page == 1 {
            VStack{
                TextField("部品番号先頭から５文字", text: $buhinNum, onEditingChanged: {_ in
                    BUHINNUM = buhinNum
                }, onCommit: {
                    BUHINNUM = buhinNum
                }).keyboardType(.numberPad).frame(width: 250, height: 30, alignment: .center)
                Button(action: {
                    UIApplication.shared.endEditing()
                    print(BUHINNUM)
                    buhinNumKensaku()
                }, label: {
                    Text("検索")
                })
                List(kensaku){ kensaku in
                    KensakuView(kensaku: kensaku)
                }
            }
        }
            if page == 2 {
                VStack{
                    
                    
                }
            }
        }.navigationBarHidden(true)
    }
    

    
    
    
    
    func removePikking(){
        let user = UserDefaults.standard
        var pikkingData: [String] = []
        for data in csv.data {
            let material = data.components(separatedBy: ",")
            pikkingData.append("\(material[1]),\(loadPikkingData(filename: "\(material[1])"))")
            user.removeObject(forKey: "\(material[1])")
        }
    }
    
    
    
    func buhinNumKensaku(){
        var num = 0
        kensaku = []
        for data in csv.data {
            let material = data.components(separatedBy: ",")
            if material[1] != "" {
            if material[1].prefix(BUHINNUM.count) == BUHINNUM {
                print("合ってる\(material[1].prefix(BUHINNUM.count))")
                kensaku += [Kensaku(id: num, daisyaNum: material[0], buhinNum: material[1], buhinName: material[2], gyosya: material[4])]
                num += 1
            }
            }
        }
        
    }
    func loadPikkingData(filename: String) -> Int {
        return UserDefaults.standard.integer(forKey: "\(filename)")
    }
    
    func loadcsv(id: Int) {
        production = []
        for ma in csv.data {
            let material = ma.components(separatedBy: ",")
            if daisya[id] == material[0] {production += [Production(id: num, daisyaNum: material[0], buhinNum: material[1], buhinName: material[2], ichidai: material[3], gyosya: material[4], yokyu: getIntYokyu(dblNum: material[3]), bikou: material[6], adoresu: material[7])]
            } else {
                continue
            } //もし指定された台車番号じゃなかったらリストの表示をしない
            num += 1
        }
    }
    func getIntYokyu(dblNum: String) -> Int{
        let dbl = atof(dblNum) * Double(rotnum)
        
        return Int(ceil(dbl))
    }
    func getdaisyaCount(){
        var daisyaNumber = 0
        daisya = []
        for ma in csv.data {
            let material = ma.components(separatedBy: ",")
        if daisya.count == 0 {
            daisya.append(material[0])
        }
        if daisya[daisyaNumber] != material[0] {
            daisyaNumber += 1
            daisya.append(material[0])
        }
        }
    }

    func narabekae() -> [String] {
        var syurui: [String] = []
        for i in 0..<100 {
            syurui.append("\(i)Z")
            syurui.append("\(i)R")
            syurui.append("\(i)Q3")
            syurui.append("\(i)Q2")
            syurui.append("\(i)Q1")
            syurui.append("\(i)Y")
            syurui.append("\(i)Y\(i+1)Y")
            syurui.append("\(i)F")
            syurui.append("\(i)T")
        }
        var count = 0
        var newdaisyaKinds: [String] = []
        
        for syu in syurui {
            for dai in daisya {
            if syu == dai {
                newdaisyaKinds.append(syu)
                count += 1
            }
            }
        }
        return newdaisyaKinds
        
    }
    
    func subString(str: String, start: Int, length: Int) -> String {
        let zero = str.startIndex
        let s = str.index(zero, offsetBy: start)
        let e = str.index(s, offsetBy: length)
        
        return String(str[s..<e])
    }
    
    func loadDaisyaKinds(id: Int){
        var num = 0
        daisyaKinds = []
        var color = Color.white
        for dai in daisya {
            if num == id {
                color = Color.gray
                print("\(num)== \(PikkingView.daisyaKindNum)")
            }
            daisyaKinds += [DaisyaKinds(id: num, name: dai, color: color)]
                num += 1
            color = Color.white
        }
        }
    
    
    
    
    
    }

struct buhinRow: View {
    var production: Production
    let wid = UIScreen.main.bounds.width
    let heg: CGFloat = 70
    @State var color: Color = Color.white
    @State var checkNumber = false
    @State var check = 0
    @State var text = ""
    @State var isShowingAlert = false
    var body: some View{
        HStack{
            Button(action: {
                isShowingAlert.toggle()
            }, label: {
                HStack{
                    Text(production.daisyaNum).frame(width: wid*0.04, height: heg, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    Text(production.buhinNum).frame(width: wid*0.17, height: heg, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    Text(production.buhinName).frame(width: wid*0.25, height: heg, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    Text(production.ichidai).frame(width: wid*0.04, height: heg, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    Text(production.gyosya).frame(width: wid*0.2, height: heg, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    Text("\(production.yokyu)").frame(width: wid*0.04, height: heg, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    Text(production.bikou).frame(width: wid*0.06, height: heg, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    Text(production.adoresu).frame(width: wid*0.15, height: heg, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                }
            }).background(color).onAppear(perform: {
                let loadcheck = UserDefaults.standard.integer(forKey: "\(production.buhinNum)")
                if loadcheck == 0 {
                    color = Color.white
                } else if loadcheck == 1 {
                    color = Color.gray
                } else {
                    color = Color.yellow
                }
                
                
            })
            
            TextFieldAlertView(
                        text: $text,
                        isShowingAlert: $isShowingAlert,
                        placeholder: "",
                        isSecureTextEntry: true,
                title: "部品番号\n \(production.buhinNum)",
                message: "数量を入力してください\n必要数量: \(production.yokyu)",
                        leftButtonTitle: "キャンセル",
                        rightButtonTitle: "確定",
                        leftButtonAction: nil,
                        rightButtonAction: {
                            let data = UserDefaults.standard
                            if production.yokyu == Int(text) {
                                if check != 1 {
                                    check = 1
                                    color = Color.gray
                                } else {
                                    check = 0
                                    color = Color.white
                                }
                            data.setValue(check, forKey: "\(production.buhinNum)")
                            data.synchronize()
                           
                            } else {
                                check = 2
                                color = Color.yellow
                                data.setValue(check, forKey: "\(production.buhinNum)")
                                data.synchronize()
                            }
                        }
                    )
            .alert(isPresented: $checkNumber, content: {
                
                
                Alert(title: Text("部品番号を確認してください"), message: Text("\(production.buhinNum)"), primaryButton: .cancel(), secondaryButton: .default(Text("番号一致"), action: {
                    
                }))
            })
        }
    }
    
    
    
    
}

struct Kensaku: Identifiable {
    var id: Int
    var daisyaNum: String
    var buhinNum: String
    var buhinName: String
    var gyosya: String
}

struct KensakuView: View {
    var kensaku: Kensaku
    let wid = UIScreen.main.bounds.width
    var body: some View {
        HStack{
            Text(kensaku.daisyaNum).frame(width: wid*0.1, height: 30, alignment: .center)
            Text(kensaku.buhinNum).frame(width: wid*0.25, alignment: .center)
            Text(kensaku.buhinName).frame(width: wid*0.25, height: 30, alignment: .center)
            Text(kensaku.gyosya).frame(width: wid*0.25, height: 30, alignment: .center)
        }
    }
}



struct Production: Identifiable {
    var id: Int
    var daisyaNum: String
    var buhinNum: String
    var buhinName : String
    var ichidai : String
    var gyosya : String
    var yokyu : Int
    var bikou : String
    var adoresu : String
    
}



struct PikkingView_Previews: PreviewProvider {
    static var previews: some View {
        PikkingView( filename: "", rotnum: 0, data: "")
    }
}



    

