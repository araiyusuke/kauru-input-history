//
//  BottomMenuViewModel.swift
//  BottomMenu
//
//  Created by ććăȘă on 2022/07/25.
//

import Foundation

class ViewModel : ObservableObject {
    @Published var title: String =  ""
    @Published var memo: String =  ""
    @Published var inputText: String = ""
    @Published var suggestions: [(String, String)] = []

}
