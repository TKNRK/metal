//
//  Compute.swift
//  6-PickAndHit
//
//  Created by Riku Takano on 2019/02/14.
//  Copyright © 2019 Riku Takano. All rights reserved.
//


import MetalKit

class Computer: NSObject {
    var commandQueue: MTLCommandQueue!
    var computePipelineState: MTLComputePipelineState!
    
    var timer: Float = 0
    var selected_id: UInt16 = 100
    var newpos: [Float] = [0.0, 0.0]
    
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
    
    func compute(vertexBuffer: MTLBuffer, numVertices: Int, pickBuffer: MTLBuffer, x: Float, y: Float) {
        newpos = [x, y]
        
        guard let computeCommandBuffer = commandQueue.makeCommandBuffer(),
            let computeCommandEncoder = computeCommandBuffer.makeComputeCommandEncoder()
            else {return}
        
        computeCommandEncoder.setComputePipelineState(computePipelineState)
        let width = 8
        let threadsPerGroup = MTLSize(width: width, height: 1, depth: 1)
        let numThreadgroups = MTLSize(width: (numVertices + width - 1) / width, height: 1, depth: 1)
        
        update()
        computeCommandEncoder.setBuffer(pickBuffer, offset: 0, index: 0)
        computeCommandEncoder.setBytes(&newpos, length: MemoryLayout<Float>.stride * 2, index: 1)
        // computeCommandEncoder.setBytes(&timer, length: MemoryLayout<Float>.stride, index: 0)
        computeCommandEncoder.setBuffer(vertexBuffer, offset: 0, index: 2)
        
        computeCommandEncoder.dispatchThreadgroups(numThreadgroups, threadsPerThreadgroup: threadsPerGroup)
        
        computeCommandEncoder.endEncoding()
        computeCommandBuffer.commit()
        computeCommandBuffer.waitUntilCompleted()
    }
}
