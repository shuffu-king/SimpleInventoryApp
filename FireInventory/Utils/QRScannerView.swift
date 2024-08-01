//
//  QRScannerView.swift
//  FireInventory
//
//  Created by Ayo Shafau on 8/1/24.
//

import SwiftUI
import CodeScanner

struct QRScannerView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var scannedSN: String
    
    var body: some View {
        CodeScannerView(codeTypes: [.qr],
                        simulatedData: "SN001",
                        completion: handleScan
        )
        .edgesIgnoringSafeArea(.all)
    }
    
    private func handleScan(result: Result<ScanResult, ScanError>) {
        switch result {
        case .success(let scanResult):
            scannedSN = scanResult.string
            presentationMode.wrappedValue.dismiss()
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
}

//#Preview {
//    QRScannerView(scannedSN: Binding<String>)
//}
