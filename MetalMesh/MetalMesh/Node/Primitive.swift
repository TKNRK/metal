//
//  Primitive.swift
//  MetalMesh
//
//  Created by Riku Takano on 2018/11/15.
//  Copyright © 2018 Riku Takano. All rights reserved.
//

import MetalKit

class Primitive: Node {
    // Buffers
    var vertexBuffer: MTLBuffer!
    var indexBuffer: MTLBuffer!
    // BufferData
    var vertices: [Vertex]!
    var indices: [UInt16]!
    // States
    var renderPipelineState: MTLRenderPipelineState!
    var depthStencilState: MTLDepthStencilState!
    // Constraints
    var modelConstraints = ModelConstraints()
    
    init(withDevice device: MTLDevice) {
        super.init()
        buildVertices()
        buildBuffers(device: device)
        buildPipelineState(device: device)
        buildDepthStencil(device: device)
    }
    
    public func buildVertices() {
        
    }
    
    private func buildBuffers(device: MTLDevice) {
        vertexBuffer = device.makeBuffer(bytes: vertices,
                                         length: MemoryLayout<Vertex>.stride * vertices.count,
                                         options: [])
        indexBuffer = device.makeBuffer(bytes: indices,
                                        length: MemoryLayout<UInt16>.stride * indices.count,
                                        options: [])
    }
    
    private func buildPipelineState(device: MTLDevice) {
        let library = device.makeDefaultLibrary()
        // Retrieve the shader functions
        let vertexFunction = library?.makeFunction(name: "basic_vertex_function")
        let fragmentFunction = library?.makeFunction(name: "basic_fragment_function")
        
        // Create the renderPiplineDescriptor
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction
        renderPipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        // Create the VertexDescriptor
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].offset = MemoryLayout<float3>.size
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        
        // Create the PipelineState
        renderPipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        do {
            renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func buildDepthStencil(device: MTLDevice) {
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }
    
    override func render(commandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
        commandEncoder.setRenderPipelineState(renderPipelineState)
        super.render(commandEncoder: commandEncoder, deltaTime: deltaTime)
        commandEncoder.setVertexBuffer(vertexBuffer,
                                       offset: 0,
                                       index: 0)
        commandEncoder.setDepthStencilState(depthStencilState)
        commandEncoder.setVertexBytes(&modelConstraints, length: MemoryLayout<ModelConstraints>.stride, index: 1)
        commandEncoder.drawIndexedPrimitives(type: .triangle,
                                             indexCount: indices.count,
                                             indexType: .uint16,
                                             indexBuffer: indexBuffer,
                                             indexBufferOffset: 0)
    }
}


extension Primitive: Constraintable {
    func scale(axis: float3) {
        modelConstraints.modelMatrix.scale(axis: axis)
    }
    
    func translate(direction: float3) {
        modelConstraints.modelMatrix.translate(direction: direction)
    }
    
    func rotate(angle: Float, axis: float3) {
        modelConstraints.modelMatrix.rotate(angle: angle, axis: axis)
    }
}
