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

                    titleInput
                        .frame(maxWidth: .infinity, maxHeight: 30)

                    MultiRowEditor(placeFolder: "メモ", value: $viewModel.memo)

                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity
                        )
                        .background(Color.gray.opacity(0.3))

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

    var titleInput: some View {
        GeometryReader { geometry in
            TextField("タイトル", text: $viewModel.title)
                .font(.title)
                .frame(width: geometry.size.width, height: geometry.size.height)
        }

    }

    struct MultiRowEditor: View {

        enum Field {
            case textField
            case textEditor
        }

        let placeFolder: String
        @FocusState var focusState: Field?
        @Binding var value: String

        init(placeFolder: String, value:  Binding<String>) {
            self.placeFolder = placeFolder
            self._value = value
        }

        var body: some View {

            GeometryReader { geometry in

                ZStack(alignment: .topLeading) {

                    if value.isEmpty {
                        Text(value)
                            .font(.body)
                        //                            .focused($focusState, equals: .textField)
                            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                            .background(Color.white)
                            .onTapGesture {
                                value = "1"
                            }

                    } else {
                        TextEditor(text: $value)
                            .font(.body)
                            .focused($focusState, equals: .textEditor)
                            .padding(-5)
                            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                            .onAppear() {
                                focusState = .textEditor
                            }
                    }

                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
                .ignoresSafeArea(.keyboard)
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
