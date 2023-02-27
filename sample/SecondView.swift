//
//  SecondView.swift
//  KaishanoKaizen
//
//  Created by 北条ようた on 2022/07/11.
//

import SwiftUI

struct SecondView: View {
    @ObservedObject var viewModel: ScannerViewModel
    
    var body: some View {
        ZStack{
            //QRCode読み取りView
            QrCodeScannerView().found(r: self.viewModel.onFoundQrCode).interval(delay: self.viewModel.scanInterval)
            
            VStack{
                VStack{
                    Text("Keep scanning for QR-codes").font(.subheadline)
                    Text("QRコード読み取り結果 = [\(self.viewModel.lastQrCode)]").bold().lineLimit(5).padding()
                    Button(action: {
                        self.viewModel.isShowing = false
                    }, label: {
                        Text("Close")
                    })
                }.padding()
                Spacer()
            }.padding()
        }
    }
}


