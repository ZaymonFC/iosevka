import Foundation

func interpolate(value: Double, from: ClosedRange<Double>, to: ClosedRange<Double>) -> Double {
  let clampedValue = min(max(value, from.lowerBound), from.upperBound)
  return (clampedValue - from.lowerBound) / (from.upperBound - from.lowerBound) * (to.upperBound - to.lowerBound) + to.lowerBound
}
