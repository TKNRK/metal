//
//  MonteCarlo.swift
//  MonteCarlo
//
//  Created by Riku Takano on 2018/12/01.
//  Copyright © 2018 Riku Takano. All rights reserved.
//

import MetalKit

class MonteCarlo: NSObject {
    let samples = 100000
    var inputData: [float2]!
    var outputData: [Bool]!
    
    var commandQueue: MTLCommandQueue!
    var computePipelineState: MTLComputePipelineState!
    var inputBuffer: MTLBuffer!
    var outputBuffer: MTLBuffer!
    
    init(device: MTLDevice) {
        super.init()
        
        inputData = prepareInputDataSet(size: samples)
        outputData = [Bool](repeating: false, count: inputData.count)
        
        createCommandQueue(device: device)
        createComputePipeline(device: device)
        createBuffers(device: device)
        
//        // Calculate PI
//        calculate(device: device)
//        let pi = readOutputBuffer(device: device)
//        print(pi)
    }
    
    func createCommandQueue(device: MTLDevice) {
        commandQueue = device.makeCommandQueue()
    }
    
    func createComputePipeline(device: MTLDevice) {
        guard let library = device.makeDefaultLibrary() else {return}
        // let monte_carlo = library.makeFunction(name: "monte_carlo")!
        // let draw_red = library.makeFunction(name: "draw_red")!
        let mandelbrot = library.makeFunction(name: "mandelbrot")!
        do {
            computePipelineState = try device.makeComputePipelineState(function: mandelbrot)
        }  catch {
            print(error.localizedDescription)
        }
    }
    
    func createBuffers(device: MTLDevice) {
        inputBuffer = device.makeBuffer(bytes: inputData,
                                        length: MemoryLayout<float2>.stride * inputData.count,
                                        options: [])
        outputBuffer = device.makeBuffer(bytes: outputData,
                                         length: MemoryLayout<Bool>.stride * outputData.count,
                                         options: [])
    }
    
//    func calculate(device: MTLDevice) {
//        guard let computeCommandBuffer = commandQueue.makeCommandBuffer(),
//            let computeCommandEncoder = computeCommandBuffer.makeComputeCommandEncoder()
//            else {return}
//
//        computeCommandEncoder.setComputePipelineState(computePipelineState)
//        computeCommandEncoder.setBuffer(inputBuffer, offset: 0, index: 1)
//        computeCommandEncoder.setBuffer(outputBuffer, offset: 0, index: 2)
//
//        // Number of thread groups
//        let width = 64
//        let threadsPerGroup = MTLSize(width: width, height: 1, depth: 1)
//        let numThreadgroups = MTLSize(width: (inputData.count + width - 1) / width, height: 1, depth: 1)
//        computeCommandEncoder.dispatchThreadgroups(numThreadgroups, threadsPerThreadgroup: threadsPerGroup)
//
//        computeCommandEncoder.endEncoding()
//        computeCommandBuffer.commit()
//        computeCommandBuffer.waitUntilCompleted()
//    }
    
    func readOutputBuffer(device: MTLDevice) -> Double {
        let data = Data(bytesNoCopy: outputBuffer.contents(), count: outputData.count, deallocator: .none)
        var resultData = [Bool](repeating: false, count: outputData.count)
        resultData = data.withUnsafeBytes {
            Array(UnsafeBufferPointer<Bool>(start: $0, count: data.count/MemoryLayout<Bool>.size))
        }
        
        let count = resultData.reduce(0) {$1 ? $0 + 1 : $0}
        return 4.0 * Double(count) / Double(resultData.count)
    }
    
    private func prepareInputDataSet(size: Int) -> [float2] {
        var inVector: [float2] = [float2]()
        for _ in 0..<size {
            let x = Float(arc4random_uniform(UInt32.max)) / Float(UInt32.max)
            let y = Float(arc4random_uniform(UInt32.max)) / Float(UInt32.max)
            inVector.append(float2(x,y))
        }
        return inVector
    }
}

extension MonteCarlo: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        view.framebufferOnly = false
        if let drawable = view.currentDrawable,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let commandEncoder = commandBuffer.makeComputeCommandEncoder()
        {
            commandEncoder.setComputePipelineState(computePipelineState)
            commandEncoder.setTexture(drawable.texture, index: 0)
            let threadGroupCount = MTLSizeMake(8, 8, 1)
            let threadGroups = MTLSizeMake(drawable.texture.width / threadGroupCount.width, drawable.texture.height / threadGroupCount.height, 1)
            commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
            commandEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}

