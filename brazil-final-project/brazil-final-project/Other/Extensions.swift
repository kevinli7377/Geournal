//
//  Extensions.swift
//  brazil-final-project
//
//  Created by Ari Wilford on 11/13/23.
//

import Foundation
import SwiftUI
import NavigationTransition

extension AnyNavigationTransition {
    /// A transition that reverses the slide effect along the specified axis.
    ///
    /// This transition:
    /// - Pushes views left-to-right and pops views right-to-left when `axis` is `horizontal`.
    /// - Pushes views top-to-bottom and pops views bottom-to-top when `axis` is `vertical`.
    public static func reverseSlide(axis: Axis) -> Self {
        .init(ReverseSlide(axis: axis))
        .animation(.easeInOut(duration: 1.0))
    }
}

extension AnyNavigationTransition {
    /// Equivalent to `reverseSlide(axis: .horizontal)`.
    @inlinable
    public static var reverseSlide: Self {
        .reverseSlide(axis: .horizontal)
        .animation(.easeInOut(duration: 1.0))
    }
}

/// A transition that reverses the slide effect along the specified axis.
///
/// This transition:
/// - Pushes views left-to-right and pops views right-to-left when `axis` is `horizontal`.
/// - Pushes views top-to-bottom and pops views bottom-to-top when `axis` is `vertical`.
public struct ReverseSlide: NavigationTransition {
    private let axis: Axis

    public init(axis: Axis) {
        self.axis = axis
    }

    /// Equivalent to `ReverseSlide(axis: .horizontal)`.
    @inlinable
    public init() {
        self.init(axis: .horizontal)
        
    }

    public var body: some NavigationTransition {
        switch axis {
        case .horizontal:
            MirrorPop {
                Move(edge: .trailing)
                    
                    
            }
            MirrorPush {
                Move(edge: .trailing)
            }
            
        case .vertical:
            MirrorPop {
                Move(edge: .top)
            }
        }
    }
    
}

extension AnyNavigationTransition {
    /// A transition that reverses the slide effect along the specified axis.
    ///
    /// This transition:
    /// - Pushes views left-to-right and pops views right-to-left when `axis` is `horizontal`.
    /// - Pushes views top-to-bottom and pops views bottom-to-top when `axis` is `vertical`.
    public static func newSlide(axis: Axis) -> Self {
        .init(NewSlide(axis: axis))
        .animation(.easeInOut(duration: 1.0))
    }
}

extension AnyNavigationTransition {
    /// Equivalent to `reverseSlide(axis: .horizontal)`.
    @inlinable
    public static var newSlide: Self {
        .newSlide(axis: .horizontal)
        .animation(.easeInOut(duration: 1.0))
    }
}

/// A transition that reverses the slide effect along the specified axis.
///
/// This transition:
/// - Pushes views left-to-right and pops views right-to-left when `axis` is `horizontal`.
/// - Pushes views top-to-bottom and pops views bottom-to-top when `axis` is `vertical`.
public struct NewSlide: NavigationTransition {
    private let axis: Axis

    public init(axis: Axis) {
        self.axis = axis
    }

    /// Equivalent to `ReverseSlide(axis: .horizontal)`.
    @inlinable
    public init() {
        self.init(axis: .horizontal)
        
    }

    public var body: some NavigationTransition {
        switch axis {
        case .horizontal:
            MirrorPush {
                Move(edge: .trailing)
                    
            }
            MirrorPop {
                Move(edge: .leading)
            }
            
        case .vertical:
            MirrorPop {
                Move(edge: .top)
            }
        }
    }
}



