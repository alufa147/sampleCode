//
//  ContentView.swift
//  KaishanoKaizen
//
//  Created by 北条ようた on 2022/01/18.
//

import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}

struct ContentView: View {
   
    
    @State var kisyuList: [Kisyu] = []

    @State var kisyu = "機種名を押して選択"
    @State var rotNum = ""
    @State var ROTNUM = ""
    let dataManager = TimeDataManager(KISYUNAME: "")
    
    @State var page = 0
    var body: some View {
        NavigationView{
            VStack{
            if page == 0 {
            VStack{
                
                NavigationLink(destination: DataView(), label: {
                    Text("データ")
                })
                Text("機種選択: \(kisyu)")
                HStack{
                TextField("台数", text: $rotNum, onEditingChanged: { _ in
                    ROTNUM = rotNum
                }, onCommit: {
                    ROTNUM = rotNum
                }).keyboardType(.numberPad).frame(width: 50, height: 30, alignment: .center)
                    Button(action: {
                        UIApplication.shared.endEditing()
                    }, label: {
                        Text("OK")
                    })
                }
                
                ForEach(kisyuList) { value in
                    Button(action: {
                        kisyu = value.name
                        
                    }, label: {
                        Text("\(value.name)")
                    }).padding()
                }
                
                
                NavigationLink( destination: PikkingView(filename: "\(kisyu)",rotnum: Int(ROTNUM) ?? 0, data: makeData() ),
                label: {
                    /*@START_MENU_TOKEN@*/Text("Navigate")/*@END_MENU_TOKEN@*/
                })
            }
                if page == 1 {
                    
                    
                }
            }
            
            }.navigationBarHidden(true).onAppear(perform: {
                kisyuList = []
                setKisyu()
            })
        }
    }
 
    
    func makeData() -> String {
        return "\(kisyu),\(ROTNUM),\(dataManager.nowTime())"
    }
    
    func setKisyu(){
        let csvManager = CsvManager.init(f: "")
        var num = 0
        for data in csvManager.kisyuList {
             kisyuList += [Kisyu(id: num, name: data)]
             num += 1
        }
    }
    
    
}



struct Kisyu: Identifiable {
    var id: Int
    var name: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
           
        }
            
    }
}
