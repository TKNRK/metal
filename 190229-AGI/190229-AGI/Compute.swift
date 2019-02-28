//
//  Compute.swift
//  190229-AGI
//
//  Created by Riku Takano on 2019/02/20.
//  Copyright © 2019 Riku Takano. All rights reserved.
//


import MetalKit

class Computer: NSObject {
    var commandQueue: MTLCommandQueue!
    var computePipelineState: MTLComputePipelineState!
    
    var timer: Float = 0
    
    init(device: MTLDevice) {
        super.init()
        createCommandQueue(device: device)
        createComputePipeline(device: device)
    }
    
    private func createCommandQueue(device: MTLDevice) {
        commandQueue = device.makeCommandQueue()
    }
    
    private func createComputePipeline(device: MTLDevice) {
        guard let library = device.makeDefaultLibrary() else {return}
        let cs_function = library.makeFunction(name: "compute")!
        do {
            computePipelineState = try device.makeComputePipelineState(function: cs_function)
        }  catch {
            print(error.localizedDescription)
        }
    }
    
    private func update() {
        timer += 0.1
    }
    

    func compute(N: Int, h_dim: Int, vertexBuffer: MTLBuffer, LhdBuffer: MTLBuffer, projBuffer: MTLBuffer) {
        
        guard let computeCommandBuffer = commandQueue.makeCommandBuffer(),
            let computeCommandEncoder = computeCommandBuffer.makeComputeCommandEncoder()
            else {return}
        
        computeCommandBuffer.label = "computeCommandBuffer"
        
        computeCommandEncoder.setComputePipelineState(computePipelineState)
        let width = 8
        let threadsPerGroup = MTLSize(width: width, height: 1, depth: 1)
        let numThreadgroups = MTLSize(width: (N + width - 1) / width, height: 1, depth: 1)
        
        update()
        // computeCommandEncoder.setBytes(&timer, length: MemoryLayout<Float>.stride, index: 0)
        computeCommandEncoder.setBuffer(vertexBuffer, offset: 0, index: 0)
        computeCommandEncoder.setBuffer(LhdBuffer, offset: 0, index: 1)
        computeCommandEncoder.setBuffer(projBuffer, offset: 0, index: 2)
        var N = N
        var h_dim = h_dim
        computeCommandEncoder.setBytes(&N, length: MemoryLayout<Int>.stride, index: 3)
        computeCommandEncoder.setBytes(&h_dim, length: MemoryLayout<Int>.stride, index: 4)

        computeCommandEncoder.dispatchThreadgroups(numThreadgroups, threadsPerThreadgroup: threadsPerGroup)
        
        computeCommandEncoder.endEncoding()
        computeCommandBuffer.commit()
        computeCommandBuffer.waitUntilCompleted()
    }
}

