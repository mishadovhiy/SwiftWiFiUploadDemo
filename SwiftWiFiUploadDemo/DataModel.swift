//
//  DataModel.swift
//  SwiftWiFiUploadDemo
//
//  Created by Misha Dovhiy on 19.07.2024.
//

import Foundation

struct MessageContent {
    let title:String
    var description:String? = nil
}

struct ButtonContent {
    let title:String
    var pressed:(()->())? = nil
}
