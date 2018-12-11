//
//  Renderer.swift
//  1-drawTriangle
//
//  Created by Riku Takano on 2018/12/08.
//  Copyright © 2018 Riku Takano. All rights reserved.
//

import Cocoa
import MetalKit

// 頂点が持つ構造
struct Vertex {
    var position: float3
    var color: float4
}

class Renderer: NSObject {
    var commandQueue: MTLCommandQueue!
    var renderPipelineState: MTLRenderPipelineState!
    var picker_program: Picker!
    var now_picking: Bool = false

    var vertexBuffer: MTLBuffer!
    var vertices: [Vertex] = [
        Vertex(position: float3(0,0.5,0), color: float4(0,1,0,1)),
        Vertex(position: float3(-0.5,-0.5,0), color: float4(0,1,0,1)),
        Vertex(position: float3(0.5,-0.5,0), color: float4(0,1,0,1))
    ]

    init(device: MTLDevice) {
        super.init()
        createCommandQueue(device: device)
        createPipelineState(device: device)
        createBuffers(device: device)
        createPicker(device: device)
    }
    
    func createCommandQueue(device: MTLDevice) {
        commandQueue = device.makeCommandQueue()
    }
    
    func createPipelineState(device: MTLDevice) {
        let library = device.makeDefaultLibrary()
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        let vertexFunction = library?.makeFunction(name: "basic_vertex_function")
        let fragmentFunction = library?.makeFunction(name: "basic_fragment_function")
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction
        
        do {
            renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func createBuffers(device: MTLDevice) {
        vertexBuffer = device.makeBuffer(bytes: vertices,
                                         length: MemoryLayout<Vertex>.stride * vertices.count,
                                         options: [])
    }
    
    func createPicker(device: MTLDevice) {
        picker_program = Picker(device: device)
    }
    
    var frameSize: [Float] = [ 0.0, 0.0 ]
    
    func setFrameSize(size: CGSize) {
        frameSize = [ Float(size.width), Float(size.height) ]
        picker_program.setClickedPosition(x: 0, y: 0)
    }
    
    func pick_start(x: Float, y: Float) {
        now_picking = true
        picker_program.setClickedPosition(x: x, y: frameSize[1] - y)
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        setFrameSize(size: view.frame.size)
    }
    
    func pick_before(commandEncoder: MTLRenderCommandEncoder) {
        picker_program.pick(commandEncoder: commandEncoder, vertexBuffer: vertexBuffer, numVertices: vertices.count)
    }
    
    func pick_after() {
        now_picking = false
        picker_program.loadPicker()
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
            let renderPassDescriptor = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
            else {return}

        if (now_picking) {pick_before(commandEncoder: commandEncoder)}
        
        commandEncoder.setRenderPipelineState(renderPipelineState)
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: vertices.count)
        
        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
        if (now_picking) {pick_after()}
    }
}
