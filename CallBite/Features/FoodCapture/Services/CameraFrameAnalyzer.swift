//
//  CameraFrameAnalyzer.swift
//  CallBite
//
//  Created by Codex on 12/09/26.
//

@preconcurrency import AVFoundation
import ImageIO
@preconcurrency import Vision

final class CameraFrameAnalyzer: CameraFrameAnalyzing, @unchecked Sendable {
    func analyze(pixelBuffer: CVPixelBuffer) -> CameraFrameAnalysis {
        let brightness = averageBrightness(of: pixelBuffer)
        let subjectBounds = salientSubjectBounds(in: pixelBuffer)

        return CameraFrameAnalysis(
            brightness: brightness,
            subjectBounds: subjectBounds,
            portraitFrameWidth: Double(CVPixelBufferGetHeight(pixelBuffer)),
            portraitFrameHeight: Double(CVPixelBufferGetWidth(pixelBuffer))
        )
    }

    private func averageBrightness(of pixelBuffer: CVPixelBuffer) -> Double {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        let planeIndex = CVPixelBufferGetPlaneCount(pixelBuffer) > 0 ? 0 : nil
        let width: Int
        let height: Int
        let bytesPerRow: Int
        let baseAddress: UnsafeMutableRawPointer?

        if let planeIndex {
            width = CVPixelBufferGetWidthOfPlane(pixelBuffer, planeIndex)
            height = CVPixelBufferGetHeightOfPlane(pixelBuffer, planeIndex)
            bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, planeIndex)
            baseAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, planeIndex)
        } else {
            width = CVPixelBufferGetWidth(pixelBuffer)
            height = CVPixelBufferGetHeight(pixelBuffer)
            bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
            baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        }

        guard let baseAddress, width > 0, height > 0 else { return 0 }

        let sampleStride = 16
        var luminanceTotal = 0
        var sampleCount = 0

        for rowIndex in stride(from: 0, to: height, by: sampleStride) {
            let row = baseAddress
                .advanced(by: rowIndex * bytesPerRow)
                .assumingMemoryBound(to: UInt8.self)

            for columnIndex in stride(from: 0, to: width, by: sampleStride) {
                luminanceTotal += Int(row[columnIndex])
                sampleCount += 1
            }
        }

        guard sampleCount > 0 else { return 0 }
        return Double(luminanceTotal) / Double(sampleCount * 255)
    }

    private func salientSubjectBounds(in pixelBuffer: CVPixelBuffer) -> CameraSubjectBounds? {
        let request = VNGenerateObjectnessBasedSaliencyImageRequest()
        let requestHandler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: .right,
            options: [:]
        )

        do {
            try requestHandler.perform([request])
        } catch {
            return nil
        }

        guard let observations = request.results?.first?.salientObjects,
              let largestObservation = observations.max(by: {
                  $0.boundingBox.width * $0.boundingBox.height
                      < $1.boundingBox.width * $1.boundingBox.height
              }) else {
            return nil
        }

        let visionBounds = largestObservation.boundingBox
        return CameraSubjectBounds(
            x: visionBounds.minX,
            y: 1 - visionBounds.maxY,
            width: visionBounds.width,
            height: visionBounds.height
        )
    }
}
