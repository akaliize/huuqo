import SwiftUI

enum Layout {
    enum Cards {
        static let standardWidth: CGFloat = 160
        static let smallWidth: CGFloat = 140
        static let largeWidth: CGFloat = (UIScreen.main.bounds.width - Padding.standard * 3) / 2
        
        static func adaptiveWidth(for size: CGSize, minimumWidth: CGFloat = standardWidth) -> CGFloat {
            let spacing: CGFloat = 16
            let horizontalPadding: CGFloat = 32
            let availableWidth = size.width - horizontalPadding
            let numberOfCards = max(1, floor(availableWidth / (minimumWidth + spacing)))
            return (availableWidth - (spacing * (numberOfCards - 1))) / numberOfCards
        }
    }
    
    enum Spacing {
        static let standard: CGFloat = 16
        static let small: CGFloat = 8
        static let large: CGFloat = 24
    }
    
    enum Padding {
        static let standard: CGFloat = 16
        static let small: CGFloat = 8
        static let large: CGFloat = 24
    }
} 