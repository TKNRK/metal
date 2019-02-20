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
    var pickData: [Pick]!
    var pickBuffer: MTLBuffer!
    
    init(device: MTLDevice) {
        super.init()
        pickData = [Pick(mouse_x: 0, mouse_y: 0, pick_id: UInt16(100))]
        commandQueue = device.makeCommandQueue()
        createPipelineState(device: device)
        createBuffer(device: device)
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
    
    func createBuffer(device: MTLDevice) {
        pickBuffer = device.makeBuffer(bytes: pickData,
                                       length: MemoryLayout<Pick>.stride,
                                       options: [])
        pickBuffer.label = "PickBuffer"
    }
    
    func setClickedPosition(x: Float, y:Float) {
        let initPicker = [Pick(mouse_x: x, mouse_y: y, pick_id: UInt16(50))]
        pickBuffer.contents().copyMemory(from: initPicker, byteCount: MemoryLayout<Pick>.stride)
    }
    
    func pick(view: MTKView, vertexBuffer: MTLBuffer, numVertices: Int) {
        guard let drawable = view.currentDrawable,
            let renderPassDescriptor = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
            else {return}

        commandEncoder.setRenderPipelineState(renderPipelineState)
        
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder.setFragmentBuffer(vertexBuffer, offset: 0, index: 1)
        commandEncoder.setFragmentBuffer(pickBuffer, offset: 0, index: 2)
        commandEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: numVertices)
        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func loadPicker() -> (Int16) {
        let result = pickBuffer.contents().load(as: Pick.self)
        print(result)
        print(String(format: "selectedID: %d", result.pick_id))
        return Int16(result.pick_id)
    }
}
