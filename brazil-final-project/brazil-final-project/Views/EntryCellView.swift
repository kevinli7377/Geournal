//
//  EntryCellView.swift
//  brazil-final-project
//
//  Created by Aryana Mohammadi on 11/9/23.
//

import Foundation
import SwiftUI

struct EntryCellView: View {
    var timestamp: Double
    
    var img: Image?
    
    var body: some View {
        let datetime: Array<String> = convertTimestamp(serverTimestamp: timestamp)
        let date = datetime[0]
        
        ZStack {
            HStack {
                Text(date)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if img == nil {
                    Image(systemName: "globe.americas.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 45, height: 45)
                        .clipped()
                        .cornerRadius(15)
                }
                
                else {
                    img!
                        .resizable()
                        .scaledToFill()
                        .frame(width: 45, height: 45)
                        .clipped()
                        .cornerRadius(15)
                }
            }
        }
        .padding()
        .foregroundStyle(.black)
    }
}

#Preview {
    EntryCellView(timestamp: 1496101820775, img: Image(systemName: "globe.americas.fill"))
}


// Returns array of first entry date, second entry time
func convertTimestamp(serverTimestamp: Double) -> Array<String> {
    var dateTime: Array<String> = []

    let x = serverTimestamp / 1000
    let date = NSDate(timeIntervalSince1970: x)

    // format date as January 1, 2000
    let formatDate = DateFormatter()
    formatDate.dateStyle = .long
    formatDate.timeStyle = .none
    dateTime.append(formatDate.string(from: date as Date))

    // format time as 3:30 PM
    let formatTime = DateFormatter()
    formatTime.dateStyle = .none
    formatTime.timeStyle = .short
    dateTime.append(formatTime.string(from: date as Date))

    return dateTime
}
