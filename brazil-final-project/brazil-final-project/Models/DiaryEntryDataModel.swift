//
//  DiaryEntryDataModel.swift
//  brazil-final-project
//
//  Created by Ari Wilford on 11/11/23.
//

import Foundation
//import Firebase
import FirebaseFirestore

struct DataModel: Codable, Identifiable {
    var id: String
    var senderID: String
    var content: String
    @ServerTimestamp var timestamp: Timestamp?
    var imageURL: String?
    var location: Location?
    
    struct Location: Codable {
            var latitude: Double
            var longitude: Double
        }
}
