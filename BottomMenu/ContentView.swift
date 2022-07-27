//
//  ContentView.swift
//  BottomMenu
//
//  Created by 名前なし on 2022/07/25.
//

import SwiftUI

struct ContentView: View {

    enum FocusTextFields {
        case input
    }

    @StateObject private var viewModel: ViewModel = ViewModel()
    @ObservedObject var keyboard: KeyboardObserver = KeyboardObserver()
    @FocusState var onFocus: FocusTextFields?
    @State var inputText: String = ""
    let keyboardMenuHeight: CGFloat = 140
    let safeAreaHeight: CGFloat = 34
    let keyboardHeight: CGFloat = 336

    var isShowBottomSheets: Bool {
        return keyboard.isShowing
    }

    var body: some View {

        GeometryReader { geometry in

            ZStack(alignment: .bottom) {

                formList

                VStack(spacing: 0) {

                    inpuTextBttomSheet
                        .frame(
                            maxHeight: keyboardHeight + keyboardMenuHeight,                                           alignment: .topTrailing)
                        .background(RoundedCorners(color: Color.rgb(241, 241,243), tl: 20, tr: 20, bl: 0, br: 0))
                        .onTapGesture {
                            onFocus = .input
                        }
                }
                .opacity(isShowBottomSheets || inputText.isEmpty == false  ? 1 : 0)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .background(Color.gray.opacity(keyboard.isShowing ? 0.3 : 0))
            }
            .ignoresSafeArea(.keyboard,  edges: keyboard.isShowing  ?  [.bottom] : [] )
            .ignoresSafeArea(edges: [.bottom])  // 下端と右端を拡張
            .frame(maxHeight: .infinity)
            .background(Color.white)
        }
        .onAppear{
            self.keyboard.addObserver()
        }.onDisappear {
            self.keyboard.removeObserver()
        }
    }

    var formList: some View {
        VStack(spacing: 10) {
            List {
                ForEach(1..<25, id: \.self) { index in
                    Text("入力テスト")
                        .frame(maxWidth: .infinity, maxHeight: 30)
                        .onTapGesture {
                            self.onFocus = .input
                        }
                }
            }
            // リストのフォーマットをリセット
            .listStyle(.plain)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    var inpuTextBttomSheet: some View {

        VStack {

            Text("路線名・駅名")
                .font(.headline)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
                .onTapGesture {
                    UIApplication.shared.closeKeyboard()
                }
            TextField("駅名を入力して下さい", text: $inputText)
                .foregroundColor(Color.black)
                .focused($onFocus, equals: .input)
                .padding(.leading, 5)
                .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.blue, lineWidth: 1)
                )

            if (inputText.count == 5 || keyboard.isShowing == false) {
                VStack(spacing: 10) {
                    VStack {
                        ForEach(1..<10, id: \.self) { index in
                            Text("+")
                                .frame(maxWidth: .infinity, maxHeight: 30)
                                .onTapGesture {
                                    self.onFocus = .input
                                }
                        }
                    }
                    .frame(height: 100, alignment: .top)
                    // リストのフォーマットをリセット
                    .listStyle(.plain)

                }

            }
        }
        .padding()
//        .frame(maxWidth: .infinity, maxHeight: keyboardMenuHeight)
    }

    var titleTextFeild: some View {
        GeometryReader { geometry in
            TextField("タイトル", text: $viewModel.title)
                .foregroundColor(.black)
                .font(.title)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background(Color.gray)
        }
    }

    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}

extension Color {
    static func rgb(_ red: Double, _ green: Double, _ blue: Double, _ alpha: CGFloat = 1.0) -> Color {
        return Color(red: red / 255, green: green / 255, blue: blue / 255, opacity: alpha)
    }
}

extension UIApplication {
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
        print(height)
        print(UIScreen.main.bounds.size.height)
        height = keyboardSize.height
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        isShowing = false
        height = 0
    }
}




