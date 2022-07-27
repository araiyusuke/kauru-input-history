//
//  TextEditorPlaceFolder.swift
//  BottomMenu
//
//  Created by 名前なし on 2022/07/26.
//

import Foundation
import SwiftUI

struct TextEditorPlaceFolder: View {

    enum Field {
        case textField
        case textEditor
    }

    let placeFolder: String
    @FocusState var onFocus: Field?
    @Binding var value: String
    @State var isTouch: Bool = false

    init(placeFolder: String, value:  Binding<String>) {
        self.placeFolder = placeFolder
        self._value = value
    }

    var body: some View {

        GeometryReader { geometry in

            ZStack(alignment: .topLeading) {
                
                if value.isEmpty {
                    TextField(placeFolder, text: Binding.constant(""))
                        .foregroundColor(.white)
                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                }

                TextEditor(text: $value)
                    .font(.body)
                    .focused($onFocus, equals: .textEditor)
                    .padding(-5)
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                    .onAppear() {
                        onFocus = .textEditor
                    }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
            .onTapGesture {
                self.isTouch = true
                onFocus = .textEditor
            }
            .onAppear() {
                // darkmodeで背景が黒くなる
                UITextView.appearance().backgroundColor = .clear
            }
            .onDisappear() {
                UITextView.appearance().backgroundColor = nil
            }
        }
    }
}
