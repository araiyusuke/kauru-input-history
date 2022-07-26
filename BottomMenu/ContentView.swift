//
//  ContentView.swift
//  BottomMenu
//
//  Created by 名前なし on 2022/07/25.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel: ViewModel = ViewModel()
    @ObservedObject var keyboard: KeyboardObserver = KeyboardObserver()
    let keyboardMenuHeight: CGFloat = 50

    var body: some View {

        GeometryReader { geometry in

            ZStack(alignment: .bottom) {

                VStack(spacing: 0) {

                    titleTextFeild
                        .frame(maxWidth: .infinity, maxHeight: 30)

                    TextEditorPlaceFolder(placeFolder: "メモ", value: $viewModel.memo)
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity
                        )

                    Spacer(minLength: keyboard.isShowing ? 300 : 0)

                }

                closeButton
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: keyboardMenuHeight + 300, alignment: .topTrailing)
                    .padding(.trailing, 10)
                    .background(Color.gray)
                    .opacity(keyboard.isShowing ? 1 : 0)
                    .onTapGesture {
                        UIApplication.shared.closeKeyboard()
                    }

            }
            // 本来であればキーボードの高さが下部から突き出るのを無視する
            //            .ignoresSafeArea(.keyboard, edges:  keyboard.isShowing ? [] : [.bottom])
            .ignoresSafeArea(.keyboard,  edges: keyboard.isShowing  ?  [.bottom] : [] )

            //            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
        }
        .onAppear{
            self.keyboard.addObserver()
        }.onDisappear {
            self.keyboard.removeObserver()
        }
    }

    var closeButton: some View {
        VStack(spacing: 0) {
            Text("✖️")
                .foregroundColor(.white)
                .frame(height: keyboardMenuHeight)
        }
    }

    var titleTextFeild: some View {
        GeometryReader { geometry in
            TextField("タイトル", text: $viewModel.title)
                .font(.title)
                .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }

    struct TextEditorPlaceFolder: View {

        enum Field {
            case textField
            case textEditor
        }

        @StateObject var keyboard: KeyboardObserver = KeyboardObserver()
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
                            .font(.body)
                    }
                    TextEditor(text: $value)
                        .font(.body)
                        .focused($onFocus, equals: .textEditor)
                        .padding(-5)
                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                        .onAppear() {
                            onFocus = .textEditor
                        }
                    //                    }
                }
                .onAppear{
                    self.keyboard.addObserver()
                }.onDisappear {
                    self.keyboard.removeObserver()
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
                .onTapGesture {
                    self.isTouch = true
                    onFocus = .textEditor
                }
                .onAppear() {
                    UITextView.appearance().backgroundColor = .clear
                }
                .onDisappear() {
                    UITextView.appearance().backgroundColor = nil
                }
            }
        }
    }

    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }

    class KeyboardObserver: ObservableObject {
        @Published var isShowing = false
        @Published var height: CGFloat = 0

        func addObserver() {
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        }

        func removeObserver() {
            NotificationCenter.default.removeObserver(self,name: UIResponder.keyboardWillShowNotification,object: nil)
            NotificationCenter.default.removeObserver(self,name: UIResponder.keyboardWillHideNotification,object: nil)
        }

        @objc func keyboardWillShow(_ notification: Notification) {
            isShowing = true
            guard let userInfo = notification.userInfo as? [String: Any] else {
                return
            }
            guard let keyboardInfo = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
                return
            }
            let keyboardSize = keyboardInfo.cgRectValue.size
            height = keyboardSize.height
        }

        @objc func keyboardWillHide(_ notification: Notification) {
            isShowing = false
            height = 0
        }
    }
}
extension UIApplication {
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
