//
//  Item.swift
//  TestScroll
//
//  Created by MaxMobile Software on 12/6/24.
//

import Foundation
import SwiftUI

struct Item: SectionData, Equatable {
    let id = UUID()
    let title: String
    let details: [String]
}

struct DetailView: View {
    let detail: String
    
    var body: some View {
        Text(detail)
            .padding()
            .background(Color.gray.opacity(0.3))
            .cornerRadius(8)
    }
}
