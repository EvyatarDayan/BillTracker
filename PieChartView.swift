//
//  PieChartView.swift
//  BillTracker
//
//  Created for visualizing category spending with beautiful animations.
//

import SwiftUI

struct PieSliceData: Identifiable, Equatable {
    let id = UUID()
    let value: Double
    let color: Color
    
    static func == (lhs: PieSliceData, rhs: PieSliceData) -> Bool {
        lhs.id == rhs.id
    }
}

struct PieChartView: View {
    let slices: [PieSliceData]
    let lineWidth: CGFloat
    let showsCenterHole: Bool
    
    @State private var animationProgress: CGFloat = 0
    @State private var selectedSlice: PieSliceData?
    @State private var isAnimating = false
    
    init(slices: [PieSliceData], lineWidth: CGFloat = 0, showsCenterHole: Bool = false) {
        self.slices = slices
        self.lineWidth = lineWidth
        self.showsCenterHole = showsCenterHole
    }
    
    var total: Double {
        max(slices.reduce(0) { $0 + $1.value }, 0.000001)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let radius = size / 2
            ZStack {
                // Animated pie slices
                pieLayers(radius: radius)
                
                // Center hole
                if showsCenterHole && lineWidth > 0 {
                    Circle()
                        .fill(Color(.systemBackground))
                        .frame(width: size - lineWidth * 2, height: size - lineWidth * 2)
                        .scaleEffect(animationProgress)
                        .opacity(animationProgress)
                }
                
                // Selection indicator
                if let selectedSlice = selectedSlice,
                   let selectedIndex = slices.firstIndex(where: { $0.id == selectedSlice.id }) {
                    let angles = sliceAngles()
                    let startAngle = angles[selectedIndex].start
                    let endAngle = angles[selectedIndex].end
                    
                    Circle()
                        .stroke(selectedSlice.color, lineWidth: 3)
                        .frame(width: size + 8, height: size + 8)
                        .scaleEffect(1.05)
                        .opacity(0.8)
                        .animation(.easeInOut(duration: 0.2), value: selectedSlice)
                }
            }
            .frame(width: size, height: size)
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            startAnimation()
        }
        .onChange(of: slices.count) { _ in
            startAnimation()
        }
    }
    
    @ViewBuilder
    private func pieLayers(radius: CGFloat) -> some View {
        let angles = sliceAngles()
        ZStack {
            ForEach(Array(zip(slices.indices, slices)), id: \.0) { index, slice in
                let startAngle = angles[index].start
                let endAngle = angles[index].end
                let delay = Double(index) * 0.1
                
                PieSliceShape(startAngle: startAngle, endAngle: endAngle)
                    .fill(slice.color)
                    .scaleEffect(selectedSlice?.id == slice.id ? 1.02 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: selectedSlice)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if selectedSlice?.id == slice.id {
                                selectedSlice = nil
                            } else {
                                selectedSlice = slice
                            }
                        }
                    }
                    .opacity(animationProgress)
                    .animation(.easeOut(duration: 0.6).delay(delay), value: animationProgress)
            }
        }
    }
    
    private func sliceAngles() -> [(start: Angle, end: Angle)] {
        var angles: [(start: Angle, end: Angle)] = []
        var start: Double = -90 // Start at top
        for slice in slices {
            let degrees = (slice.value / total) * 360
            let end = start + degrees
            angles.append((start: Angle(degrees: start), end: Angle(degrees: end)))
            start = end
        }
        return angles
    }
    
    private func startAnimation() {
        animationProgress = 0
        isAnimating = true
        
        withAnimation(.easeOut(duration: 0.8)) {
            animationProgress = 1.0
        }
        
        // Reset selection after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            selectedSlice = nil
            isAnimating = false
        }
    }
}

struct PieSliceShape: Shape {
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()
        
        path.move(to: center)
        path.addArc(center: center,
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false)
        path.closeSubpath()
        return path
    }
}

// MARK: - Enhanced Pie Chart with Staggered Animation
struct EnhancedPieChartView: View {
    let slices: [PieSliceData]
    let lineWidth: CGFloat
    let showsCenterHole: Bool
    
    @State private var animationProgress: CGFloat = 0
    @State private var sliceProgresses: [CGFloat]
    @State private var selectedSlice: PieSliceData?
    
    init(slices: [PieSliceData], lineWidth: CGFloat = 0, showsCenterHole: Bool = false) {
        self.slices = slices
        self.lineWidth = lineWidth
        self.showsCenterHole = showsCenterHole
        self._sliceProgresses = State(initialValue: Array(repeating: 0, count: slices.count))
    }
    
    var total: Double {
        max(slices.reduce(0) { $0 + $1.value }, 0.000001)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let radius = size / 2
            ZStack {
                // Animated pie slices with staggered appearance
                ForEach(Array(zip(slices.indices, slices)), id: \.0) { index, slice in
                    let startAngle = sliceStartAngle(for: index)
                    let endAngle = sliceEndAngle(for: index)
                    
                    PieSliceShape(startAngle: startAngle, endAngle: endAngle)
                        .fill(slice.color)
                        .scaleEffect(selectedSlice?.id == slice.id ? 1.05 : 1.0)
                        .shadow(color: slice.color.opacity(0.3), radius: selectedSlice?.id == slice.id ? 8 : 4, x: 0, y: 2)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedSlice)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                if selectedSlice?.id == slice.id {
                                    selectedSlice = nil
                                } else {
                                    selectedSlice = slice
                                }
                            }
                        }
                        .opacity(index < sliceProgresses.count ? sliceProgresses[index] : 0)
                        .animation(.easeOut(duration: 0.8).delay(Double(index) * 0.15), value: index < sliceProgresses.count ? sliceProgresses[index] : 0)
                }
                
                // Center hole with fade-in animation
                if showsCenterHole && lineWidth > 0 {
                    Circle()
                        .fill(Color(.systemBackground))
                        .frame(width: size - lineWidth * 2, height: size - lineWidth * 2)
                        .scaleEffect(animationProgress)
                        .opacity(animationProgress)
                        .animation(.easeOut(duration: 0.6).delay(0.4), value: animationProgress)
                }
                
                // Selection indicator with pulsing effect
                if let selectedSlice = selectedSlice,
                   let selectedIndex = slices.firstIndex(where: { $0.id == selectedSlice.id }) {
                    let startAngle = sliceStartAngle(for: selectedIndex)
                    let endAngle = sliceEndAngle(for: selectedIndex)
                    
                    Circle()
                        .stroke(selectedSlice.color, lineWidth: 4)
                        .frame(width: size + 12, height: size + 12)
                        .scaleEffect(1.08)
                        .opacity(0.6)
                        .animation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true), value: selectedSlice)
                }
            }
            .frame(width: size, height: size)
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            startStaggeredAnimation()
        }
        .onChange(of: slices.count) { _ in
            // Only start animation if we have slices
            if !slices.isEmpty {
                startStaggeredAnimation()
            } else {
                // Reset everything when no slices
                animationProgress = 0
                sliceProgresses = []
                selectedSlice = nil
            }
        }
    }
    
    private func sliceStartAngle(for index: Int) -> Angle {
        var start: Double = -90
        for i in 0..<index {
            let degrees = (slices[i].value / total) * 360
            start += degrees
        }
        return Angle(degrees: start)
    }
    
    private func sliceEndAngle(for index: Int) -> Angle {
        var start: Double = -90
        for i in 0...index {
            let degrees = (slices[i].value / total) * 360
            start += degrees
        }
        return Angle(degrees: start)
    }
    
    private func startStaggeredAnimation() {
        animationProgress = 0
        selectedSlice = nil
        
        // Ensure sliceProgresses array matches the current slices count
        let newSliceProgresses = Array(repeating: CGFloat(0), count: slices.count)
        sliceProgresses = newSliceProgresses
        
        // Animate center hole
        withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
            animationProgress = 1.0
        }
        
        // Animate slices with staggered timing
        for index in slices.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.15) {
                // Check if the array still has the same count before updating
                if index < self.sliceProgresses.count {
                    withAnimation(.easeOut(duration: 0.8)) {
                        self.sliceProgresses[index] = 1.0
                    }
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Basic Pie Chart")
            .font(.headline)
        
        PieChartView(slices: [
            PieSliceData(value: 30, color: .blue),
            PieSliceData(value: 25, color: .green),
            PieSliceData(value: 20, color: .orange),
            PieSliceData(value: 15, color: .red),
            PieSliceData(value: 10, color: .purple)
        ], lineWidth: 40, showsCenterHole: true)
        .frame(height: 200)
        
        Text("Enhanced Pie Chart")
            .font(.headline)
        
        EnhancedPieChartView(slices: [
            PieSliceData(value: 30, color: .blue),
            PieSliceData(value: 25, color: .green),
            PieSliceData(value: 20, color: .orange),
            PieSliceData(value: 15, color: .red),
            PieSliceData(value: 10, color: .purple)
        ], lineWidth: 40, showsCenterHole: true)
        .frame(height: 200)
    }
    .padding()
}


