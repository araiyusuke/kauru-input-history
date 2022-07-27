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

    let keyboardMenuHeight: CGFloat = 140
    let safeAreaHeight: CGFloat = 34
    let keyboardHeight: CGFloat = 336

    var body: some View {

        GeometryReader { geometry in

            ZStack(alignment: .bottom) {

                formList

                inpuTextBttomSheet
                    .frame(
                        maxWidth: .infinity, maxHeight: 300,
                                       alignment: .topTrailing)
                    .background(RoundedCorners(color: Color.rgb(241, 241,243), tl: 20, tr: 20, bl: 0, br: 0))


            }
            .ignoresSafeArea(.keyboard,  edges: keyboard.isShowing  ?  [.bottom] : [] )
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
                    titleTextFeild
                        .frame(maxWidth: .infinity, maxHeight: 30)
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

            TextField("駅名を入力して下さい", text: Binding.constant(""))
                .foregroundColor(Color.black)
                .padding(.leading, 5)
                .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.blue, lineWidth: 1)
                )
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: keyboardMenuHeight)
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




struct RoundedCorners: View {
    var color: Color = .blue
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0

    var body: some View {
        GeometryReader { geometry in
            Path { path in

                let w = geometry.size.width
                let h = geometry.size.height

                // Make sure we do not exceed the size of the rectangle
                let tr = min(min(self.tr, h/2), w/2)
                let tl = min(min(self.tl, h/2), w/2)
                let bl = min(min(self.bl, h/2), w/2)
                let br = min(min(self.br, h/2), w/2)

                path.move(to: CGPoint(x: w / 2.0, y: 0))
                path.addLine(to: CGPoint(x: w - tr, y: 0))
                path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
                path.addLine(to: CGPoint(x: w, y: h - br))
                path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
                path.addLine(to: CGPoint(x: bl, y: h))
                path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
                path.addLine(to: CGPoint(x: 0, y: tl))
                path.addArc(center: CGPoint(x: tl, y: tl), radius: tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
            }
            .fill(self.color)
        }
    }
}
