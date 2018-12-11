//
//  Renderer.swift
//  1-drawTriangle
//
//  Created by Riku Takano on 2018/12/08.
//  Copyright © 2018 Riku Takano. All rights reserved.
//

import Cocoa
import MetalKit

class Picker: NSObject {
    var commandQueue: MTLCommandQueue!
    var renderPipelineState: MTLRenderPipelineState!
    
    // 選択された頂点を保持するためのバッファー
    var selectionBuffer: MTLBuffer!
    var hitResult: [UInt] = [4]
    var clicked: float2!
    
    init(device: MTLDevice) {
        super.init()
        createCommandQueue(device: device)
        createPipelineState(device: device)
        createBuffers(device: device)
    }
    
    func createCommandQueue(device: MTLDevice) {
        commandQueue = device.makeCommandQueue()
    }
    
    func createPipelineState(device: MTLDevice) {
        let library = device.makeDefaultLibrary()
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        let vertexFunction = library?.makeFunction(name: "picker_vs")
        let fragmentFunction = library?.makeFunction(name: "picker_fs")
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction
        
        do {
            renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func createBuffers(device: MTLDevice) {
        selectionBuffer = device.makeBuffer(bytes: hitResult, length: MemoryLayout<UInt>.stride, options: [])
    }
    
    func setClickedPosition(x: Float, y:Float) {
        clicked = float2(x: x, y: y)
        print(clicked)
    }
    
    func pick(commandEncoder: MTLRenderCommandEncoder, vertexBuffer: MTLBuffer, numVertices: Int) {
        commandEncoder.setRenderPipelineState(renderPipelineState)
        
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder.setFragmentBuffer(vertexBuffer, offset: 0, index: 1)
        commandEncoder.setFragmentBytes(&clicked, length: MemoryLayout<float2>.stride, index: 2)
        commandEncoder.setFragmentBuffer(selectionBuffer, offset: 0, index: 3)
        commandEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: numVertices)
    }
    
    func loadPicker() {
        let result = selectionBuffer.contents().load(as: UInt.self)
        print(String(format: "selectedID: %d", result))
    }
}
