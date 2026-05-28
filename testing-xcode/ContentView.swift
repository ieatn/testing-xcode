//
//  ContentView.swift
//  testing-xcode
//
//  Created by Dennis Zhang on 5/28/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        RootView()
    }
}

#Preview {
    ContentView()
        .environment(TodoStore())
}
