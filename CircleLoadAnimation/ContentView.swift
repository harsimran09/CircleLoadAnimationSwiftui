//
//  ContentView.swift
//  CircleLoadAnimation
//
//  Created by ITRS-1519 on 26/06/22.
//

import SwiftUI

struct ContentView: View {
    @State var fill: CGFloat = 0.0
    @State private var showButton: Bool = false
    @State private var showLoadingCircle: Bool = false
    
    var body: some View {
        
        ZStack{
            if !showButton {
                Color(UIColor(red: 110/255.0, green: 105/255.0, blue: 115/255.0, alpha: 1))
                ZStack{
                    
                    Circle()
                        .stroke(Color.white.opacity(0.3), style: StrokeStyle(lineWidth: 25))
                    if showLoadingCircle{
                        Circle()
                            .trim(from: 0, to: self.fill)
                            .stroke(Color.green, style: StrokeStyle(lineWidth: 25))
                            .rotationEffect(.init(degrees: -90))
                            .onAppear{
                                withAnimation(Animation.easeIn(duration: 1)){
                                    for x in 0...100{
                                        DispatchQueue.main.asyncAfter(deadline: .now()+TimeInterval(x/10)){
                                            self.fill += 0.01
                                            if x == 100 {
                                                showButton.toggle()
                                            }
                                        }
                                    }
                                    print("complete")
                                }
                            }
                    }
                    Text("\(Int(self.fill * 100.0 ))%")
                        .foregroundColor(.white)
                        .font(.system(size: 40))
                }
                .padding(50)
            }
            else{
                VStack{
                    Text("All set to start !!!").foregroundColor(.yellow)
                        .font(.system(size: 30)) .fontWeight(.ultraLight)
                    Button(action: {
                        print("Start Clicked")}) {
                            HStack {
                                Image(systemName: "person")
                                Text("START").fontWeight(.bold)
                            }
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.gray)
                        .cornerRadius(.infinity)
                }
            }
        }
        .onTapGesture {
            showLoadingCircle = true
            
            
        }
        
    }
}
struct AnimatableModifierDouble: AnimatableModifier {
    
    var targetValue: Double
    
    // SwiftUI gradually varies it from old value to the new value
    var animatableData: Double {
        didSet {
            print("eeeee")
            checkIfFinished()
        }
    }
    
    var completion: () -> ()
    
    // Re-created every time the control argument changes
    init(bindedValue: Double, completion: @escaping () -> ()) {
        self.completion = completion
        print("\(bindedValue)")
        // Set animatableData to the new value. But SwiftUI again directly
        // and gradually varies the value while the body
        // is being called to animate. Following line serves the purpose of
        // associating the extenal argument with the animatableData.
        self.animatableData = bindedValue
        targetValue = bindedValue
    }
    
    func checkIfFinished() -> () {
        print("Current value: \(animatableData)")
        if (animatableData == targetValue) {
            //if animatableData.isEqual(to: targetValue) {
            DispatchQueue.main.async {
                self.completion()
            }
        }
    }
    
    // Called after each gradual change in animatableData to allow the
    // modifier to animate
    func body(content: Content) -> some View {
        content.animation(nil, value: targetValue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
struct OffsetXEffectModifier: AnimatableModifier {
    
    var initialOffsetX: CGFloat
    var offsetX: CGFloat
    var onCompletion: (() -> Void)?
    
    init(offsetX: CGFloat, onCompletion: (() -> Void)? = nil) {
        self.initialOffsetX = offsetX
        self.offsetX = offsetX
        self.onCompletion = onCompletion
    }
    
    var animatableData: CGFloat {
        get { offsetX }
        set {
            print("new value \(newValue)")
            offsetX = newValue
            checkIfFinished()
        }
    }
    
    func checkIfFinished() -> () {
        if let onCompletion = onCompletion, offsetX == initialOffsetX {
            DispatchQueue.main.async {
                onCompletion()
            }
        }
    }
    
    func body(content: Content) -> some View {
        content.offset(x: offsetX)
    }
}
