//
//  AllEntriesMapView.swift
//  Geournal
//
//  Created by Aryana Mohammadi on 11/30/23.
//

import Foundation
import SwiftUI
import MapKit

struct AllEntriesMapView: View {
    @AppStorage("fontSize") private var fontSize = 0.0
    @StateObject var viewModel: DataViewModel = DataViewModel()
    @State private var isDataLoaded = false
    
   
    
    var body: some View {
        
        
        VStack {
            Text("MAP")
                .font(.system(size: CGFloat(fontSize+24)))
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            
            Text("View all your entries on the map.")
                .font(.system(size: CGFloat(fontSize+18)))
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.bottom], 30)
            
                Spacer()
            
                VStack {
                    
//                    if viewModel.isDataLoaded {
                        BigMapView(viewModel: viewModel)
                            .padding([.bottom], 20)
                        
//                    } else {
//                        ProgressView("Loading...")
//                    }
                }
                
        }
        .onAppear{
            DispatchQueue.main.async{
                self.isDataLoaded = false
                viewModel.fetchDataForCurrentUser(){
                    self.isDataLoaded = true
                }
            }
        }
        .padding(30)
    }
    
}



#Preview {
    AllEntriesMapView()
}
