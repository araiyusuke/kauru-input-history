//
//  BottomMenuViewModel.swift
//  BottomMenu
//
//  Created by 名前なし on 2022/07/25.
//

import Foundation

class ViewModel : ObservableObject {
    @Published var title: String =  ""
    @Published var memo: String =  ""
}
