//
//  SectionData.swift
//  TestScroll
//
//  Created by MaxMobile Software on 12/6/24.
//

import Foundation

protocol SectionData: Identifiable {
    associatedtype Item
    var details: [Item] { get }
}
