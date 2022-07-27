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
    let keyboardMenuHeight: CGFloat = 140
    let safeAreaHeight: CGFloat = 34
    let keyboardHeight: CGFloat = 336
    let resetEdgeInsets = EdgeInsets(
        top: 0,
        leading: 0,
        bottom: 0,
        trailing: 0
    )
    var isShowAboveKeyBoard: Bool {
        return keyboard.isShowing
    }

    var body: some View {

        GeometryReader { geometry in

            ZStack(alignment: .bottom) {

                formList

                VStack(spacing: 0) {
                    textFieldAboveKeyboard
                        .frame(
                            // ここの高さを変える
                            maxHeight: keyboardHeight + keyboardMenuHeight + (viewModel.suggestions.count > 0 ? 100 : 0),
                            alignment: .topTrailing)
                        .background(RoundedCorners(color: Color.rgb(241, 241,243), tl: 20, tr: 20, bl: 0, br: 0))
                        .onTapGesture {
                            onFocus = .input
                        }
                }
                // キーボードが表示されている、未入力でない場合はキーボードの上に入力欄を表示する
                .opacity(isShowAboveKeyBoard  ? 1 : 0)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .background(Color.gray.opacity(keyboard.isShowing ? 0.3 : 0))
                .onTapGesture {
                    UIApplication.shared.closeKeyboard()
                }
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
                    Text("テスト")
                        .frame(maxWidth: .infinity, maxHeight: 30)
                        // タップのエリアを広げる
                        .contentShape(Rectangle())
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

    var textFieldAboveKeyboard: some View {

        VStack(spacing: 0) {

            VStack {

                Text("路線名・駅名")
                    .font(.caption)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
                    .onTapGesture {
                        UIApplication.shared.closeKeyboard()
                    }

                TextField(
                    "駅名を入力して下さい", text: $viewModel.inputText
                )
                .onChange(of: viewModel.inputText) { newValue in
                    let res = Self.stations.filter { $0.0.contains(viewModel.inputText) }
                    if res.count > 0 {
                        viewModel.suggestions = res
                    } else {
                        viewModel.suggestions = []
                    }
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(Color.black)
                .focused($onFocus, equals: .input)
                .padding(.leading, 5)
                .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.blue, lineWidth: 1)
                )
            }
            .padding()

            if (viewModel.suggestions.count > 0) {

                VStack(spacing: 0) {

                    VStack(spacing: 0) {

                        List {
                            Section(header: Text("候補")
                                .font(.caption)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
                                .padding(.leading, 10)
                                .background(Color.rgb(56, 67, 85))
                                .listRowInsets(resetEdgeInsets)
                            ) {
                                ForEach(0..<viewModel.suggestions.count, id: \.self) { index in
                                    Text(viewModel.suggestions[index].1)
                                        .font(.callout)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            viewModel.inputText = viewModel.suggestions[index].0
                                            UIApplication.shared.closeKeyboard()
                                        }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .listStyle(GroupedListStyle())
                    }
                    .environment(\.defaultMinListRowHeight, 47)
                }
            }
        }
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
