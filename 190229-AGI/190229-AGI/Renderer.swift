//
//  Renderer.swift
//  190229-AGI
//
//  Created by Riku Takano on 2019/02/20.
//  Copyright © 2019 Riku Takano. All rights reserved.
//


import Cocoa
import MetalKit


class Renderer: NSObject {
    var commandQueue: MTLCommandQueue!
    var renderPipelineState: MTLRenderPipelineState!
    
    // Computer
    var computer_program: Computer!
    
    // Data of vertices
    var vertexBuffer: MTLBuffer!
    var vertices: [Vertex]!
    // Data to draw vertices and edges
    var vIndexBuffer: MTLBuffer!
    var eIndexBuffer: MTLBuffer!
    var vIndices: [UInt16]!
    var eIndices: [UInt16]!
    // Data to initialize the above data
    let pi: Float32 = 3.14 * 2
    let N = 20
    
    init(device: MTLDevice) {
        super.init()
        initGraph()
        createCommandQueue(device: device)
        createPipelineState(device: device)
        createBuffers(device: device)
        createComputer(device: device)
    }
    
    func initGraph() {
        vertices = [
            Vertex(position: float3(0, 0, 0), color: float4(0, 1, 0, 1)),
        ]
        vIndices = [UInt16(0)]
        eIndices = []
        
        var angle: Float32 = 0
        let delta: Float32 = pi / Float32(N)
        for i in 0..<N {
            angle += delta
            vertices.append(Vertex(position: float3(sin(angle) * 0.7, cos(angle) * 0.7, 0), color: float4(0, 1, 0, 1)))
            eIndices.append(0)
            eIndices.append(UInt16(i+1))
            vIndices.append(UInt16(i+1))
        }
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
        vIndexBuffer = device.makeBuffer(bytes: vIndices,
                                         length: MemoryLayout<UInt16>.stride * vIndices.count,
                                         options: [])
        eIndexBuffer = device.makeBuffer(bytes: eIndices,
                                         length: MemoryLayout<UInt16>.stride * eIndices.count,
                                         options: [])
    }
    
    func createComputer(device: MTLDevice) {
        computer_program = Computer(device: device)
    }
    
    var frameSize: [Float] = [ 0.0, 0.0 ]
    
    func setFrameSize(size: CGSize) {
        frameSize = [ Float(size.width), Float(size.height) ]
    }
    
//    func mouse_down(x: Float, y: Float) {
//        now_picking = true
//        picker_program.setClickedPosition(x: x, y: frameSize[1] - y)
//    }
//
//    func mouse_dragged(x: Float, y: Float) {
//        if (selected_vertex > -1) {
//            let posx = x / (frameSize[0] / 2) - 1
//            let posy = y / (frameSize[1] / 2) - 1
//            computer_program.compute(vertexBuffer: vertexBuffer, numVertices: vertices.count, pickBuffer: picker_program.pickBuffer, x: posx, y: posy)
//        }
//    }
//
//    func mouse_up(x: Float, y: Float) {
//        print("mouse up")
//    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        setFrameSize(size: view.frame.size)
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
            let renderPassDescriptor = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
            else {return}
        
        commandEncoder.setRenderPipelineState(renderPipelineState)
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        //commandEncoder.setDepthStencilState(depthStencilState)
        commandEncoder.drawIndexedPrimitives(type: .point,
                                             indexCount: vIndices.count,
                                             indexType: .uint16,
                                             indexBuffer: vIndexBuffer,
                                             indexBufferOffset: 0)
        commandEncoder.drawIndexedPrimitives(type: .line,
                                             indexCount: eIndices.count,
                                             indexType: .uint16,
                                             indexBuffer: eIndexBuffer,
                                             indexBufferOffset: 0)
        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
