//
//  ContentView.swift
//  TestScroll
//
//  Created by MaxMobile Software on 10/6/24.
//

import SwiftUI

struct ContentView: View {
    @State private var items = Array(1...20).map { Item(id: $0) }
    
    var body: some View {
        CustomScrollView(collections: $items, collectionHeight: 80, contentSize: .fixed(.init(width: 100, height: 80)), collectionViewContent: { item,_  in
            CollectionItemView(item: item)
        }, tableViewContent: { item in
            TableItemView(item: item)
        })

//        CustomCollectionView(collections: $items, contentSize: .fixed(.init(width: 200, height: 50))) { item in
//            TableItemView(item: item)
//        }
    }
}

#Preview {
    ContentView()
}

struct Item: Identifiable {
    var id: Int
}

struct CollectionItemView: View {
    let item: Item
    
    var body: some View {
        Text("Item \(item.id)")
            .frame(width: 100, height: 100)
            .background(Color.blue)
            .cornerRadius(8)
            .foregroundColor(.white)
            .padding(.horizontal, 4)
            .onAppear {
                print("appear collection item")
            }
    }
}

struct TableItemView: View {
    let item: Item
    
    var body: some View {
        HStack {
            Text("Item \(item.id)")
                .padding()
            Spacer()
        }
        .frame(height: 100)
        .background(.red)
//        .background(Color.gray.opacity(0.1))
//        .cornerRadius(8)
//        .padding(.horizontal)
//        .padding(.vertical, 4)
    }
}
