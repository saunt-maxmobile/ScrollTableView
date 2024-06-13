//
//  ContentView.swift
//  TestScroll
//
//  Created by MaxMobile Software on 10/6/24.
//

import SwiftUI

struct ContentView: View {
    //    @State private var items = Array(1...20).map { Item(id: $0) }
    
    @State private var items: [Item] = [
        Item(title: "Section 1", details: ["Detail 1.1", "Detail 1.2", "Detail 1.3", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4"]),
        Item(title: "Section 2", details: ["Detail 1.1", "Detail 1.2", "Detail 1.3", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4"]),
        Item(title: "Section 3", details: ["Detail 1.1", "Detail 1.2", "Detail 1.3", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4"]),
        Item(title: "Section 4", details: ["Detail 1.1", "Detail 1.2", "Detail 1.3", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4"]),
        Item(title: "Section 5", details: ["Detail 1.1", "Detail 1.2", "Detail 1.3", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4"]),
        Item(title: "Section 6", details: ["Detail 1.1", "Detail 1.2", "Detail 1.3", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4"]),
        Item(title: "Section 7", details: ["Detail 1.1", "Detail 1.2", "Detail 1.3", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4"]),
        Item(title: "Section 8", details: ["Detail 1.1", "Detail 1.2", "Detail 1.3", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4"]),
        Item(title: "Section 9", details: ["Detail 1.1", "Detail 1.2", "Detail 1.3", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4"]),
        Item(title: "Section 10", details: ["Detail 1.1", "Detail 1.2", "Detail 1.3", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4"]),
        Item(title: "Section 11", details: ["Detail 1.1", "Detail 1.2", "Detail 1.3", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4"]),
        Item(title: "Section 12", details: ["Detail 1.1", "Detail 1.2", "Detail 1.3", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4"]),
        Item(title: "Section 13", details: ["Detail 1.1", "Detail 1.2", "Detail 1.3", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4"]),
        Item(title: "Section 14", details: ["Detail 1.1", "Detail 1.2", "Detail 1.3", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 1.1", "Detail 1.2", "Detail 1.3", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4"]),
        Item(title: "Section 15", details: ["Detail 1.1", "Detail 1.2", "Detail 1.3", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4", "Detail 3.1", "Detail 3.2", "Detail 3.3", "Detail 3.4"]),
    ]
    
    @State private var selectedIndex: Int = 0
    @State private var selectSection: Bool = false
    @State private var sectionOnScreen: Set<Int> = []
    
    var body: some View {
        //        CustomScrollView(collections: $items, collectionHeight: 80, contentSize: .fixed(.init(width: 100, height: 80)), collectionViewContent: { item,_  in
        //            CollectionItemView(item: item)
        //        }, tableViewContent: { item in
        //            TableItemView(item: item)
        //        })
        
        //        CustomCollectionView(collections: $items, contentSize: .fixed(.init(width: 200, height: 50))) { item in
        //            TableItemView(item: item)
        //        }
        
        VStack {
            ScrollViewReader(content: { scrollProxy in
                HorizontalCollectionView(sections: items, selectSection: $selectSection, selectedIndex: $selectedIndex, scrollProxy: scrollProxy)
                    .frame(height: 50)
                
                CustomSectionCollectionView(
                    sections: $items,
                    selectedIndex: $selectedIndex,
                    selectSection: $selectSection,
                    contentSize: .fixed(CGSize(width: 100, height: 100)),
                    itemSpacing: .init(mainAxisSpacing: 10, crossAxisSpacing: 10),
                    sectionSpacing: 20,
                    onShowSection: { section in
                        if let index = items.firstIndex(where: { $0.title == section.title }) {
                            sectionOnScreen.insert(index)
                            selectedIndex = sectionOnScreen.first ?? 0
                            withAnimation {
                                scrollProxy.scrollTo(section.title, anchor: .center)
                            }
                        }
                    }, onHideSection: { section in
                        if let index = items.firstIndex(where: { $0.title == section.title }) {
                            sectionOnScreen.remove(index)
                            selectedIndex = sectionOnScreen.first ?? index - 1
                        }
                    }, contentForItem: { detail in
                        Text(detail)
                            .padding()
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(8)
                    },
                    contentForHeader: { section in
                        SectionHeaderView(title: section.title)
                    }
                )
            })
            
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

struct HorizontalCollectionView: View {
    let sections: [Item]
    @Binding var selectSection: Bool
    @Binding var selectedIndex: Int
    var scrollProxy: ScrollViewProxy
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(0..<sections.count, id: \.self) { index in
                    Text(sections[index].title)
                        .padding()
                        .background(index == selectedIndex ? Color.gray : Color.clear)
                        .cornerRadius(8)
                        .id(sections[index].title)
                        .onTapGesture {
//                            selectSection = true
//                            selectedIndex = index
//                            withAnimation {
//                                scrollProxy.scrollTo(sections[index].title, anchor: .center)
//                            }
                            selectSection = true
                            withAnimation {
                                
                                selectedIndex = index
                                
                                scrollProxy.scrollTo(sections[index].title, anchor: .center)
                            }
                        }
                }
            }
        }
    }
}

struct SectionHeaderView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .padding()
            .background(Color.blue.opacity(0.7))
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}
