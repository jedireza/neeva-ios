//
//  SlideOverSheet.swift
//
//
//  Created by Stuart Allen on 1/04/21.
//

import SwiftUI
import NeevaSupport

struct SlideOverSheet<Content: View> : View {
    @GestureState private var dragState = DragState.inactive
    @State var position = CardPosition.bottom
    let onDismiss: (AddToSpaceList.IDs?) -> ()

    private func onDragEnded(drag: DragGesture.Value) {
        let verticalDirection = drag.predictedEndLocation.y - drag.location.y
        let cardTopEdgeLocation = self.position.rawValue + drag.translation.height
        let positionAbove: CardPosition
        let positionBelow: CardPosition
        let closestPosition: CardPosition

        if cardTopEdgeLocation <= CardPosition.middle.rawValue {
            positionAbove = .top
            positionBelow = .middle
        } else {
            positionAbove = .middle
            positionBelow = .bottom
        }

        if (cardTopEdgeLocation - positionAbove.rawValue) < (positionBelow.rawValue - cardTopEdgeLocation) {
            closestPosition = positionAbove
        } else {
            closestPosition = positionBelow
        }

        if verticalDirection > 0 {
            self.position = positionBelow
        } else if verticalDirection < 0 {
            self.position = positionAbove
        } else {
            self.position = closestPosition
        }
    }

    var content: () -> Content
    var body: some View {
        let drag = DragGesture()
            .updating($dragState) { drag, state, transaction in
                state = .dragging(translation: drag.translation)
        }
        .onEnded(onDragEnded)
        return Group {
            ZStack {
                //Background
                Spacer()
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                    .background(Color.black.opacity(0.50))
                    .animation(.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0))
                    .gesture(
                        TapGesture()
                            .onEnded { _ in
                                self.onDismiss(nil)
                        }
                )

                //Foreground
                VStack{
                    Spacer()
                    ZStack{
                        Color.white.opacity(1.0)
                            .frame(width: UIScreen.main.bounds.size.width, height:UIScreen.main.bounds.height)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        self.content()
                            .padding(.bottom, 25)
                            .frame(width: UIScreen.main.bounds.size.width, height:UIScreen.main.bounds.height)
                            .clipped()
                    }
                    .offset(y: self.position.offset + self.dragState.translation.height)
                    .animation(.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0))
                    .gesture(drag)
                }
            }.edgesIgnoringSafeArea(.all)
        }
    }
}

enum CardPosition: CGFloat {
    case top = 1
        case middle = 0.5
        case bottom = 0.3

        var offset: CGFloat {
            let screenHeight = UIScreen.main.bounds.height
            return screenHeight - (screenHeight * CGFloat(self.rawValue))
        }

        var coveringPortionOfScreen: CGFloat {
            return self.rawValue
        }
}

enum DragState {
    case inactive
    case dragging(translation: CGSize)

    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }

    var isDragging: Bool {
        switch self {
        case .inactive:
            return false
        case .dragging:
            return true
        }
    }
}
