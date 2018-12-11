//
//  Renderer.swift
//  1-drawTriangle
//
//  Created by Riku Takano on 2018/12/07.
//  Copyright © 2018 Riku Takano. All rights reserved.
//

import MetalKit

// 頂点が持つ構造
struct Vertex {
    var position: float3
    var color: float4
}

class Renderer: NSObject {
    var commandQueue: MTLCommandQueue!
    var renderPipelineState: MTLRenderPipelineState!
    
    // 頂点情報を保持するためのバッファーを宣言
    var vertexBuffer: MTLBuffer!
    // 三角形の頂点座標
    var vertices: [Vertex] = [
        Vertex(position: float3(0,1,0), color: float4(1,0,0,1)),
        Vertex(position: float3(-1,-1,0), color: float4(0,1,0,1)),
        Vertex(position: float3(1,-1,0), color: float4(0,0,1,1))
    ]
    
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
        // デバイスにあるライブラリを使って色々と宣言していく
        let library = device.makeDefaultLibrary()
        // render pipeline を設定するために，Descriptor を宣言
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        // pixel の形式を，MetalView で設定したやつに揃える
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        // vertex,fragment shader で使用する関数を宣言，セットする
        let vertexFunction = library?.makeFunction(name: "basic_vertex_function")
        let fragmentFunction = library?.makeFunction(name: "basic_fragment_function")
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction

        // render pipeline の状態を更新する
        do {
            renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func createBuffers(device: MTLDevice) {
        // バッファーの中にデータを突っ込む
        vertexBuffer = device.makeBuffer(bytes: vertices,
                                         length: MemoryLayout<Vertex>.stride * vertices.count,
                                         options: [])
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    // 課題１：三角形の描画を元に，三角形の骨組みを描画する
    // 課題２：三角形の描画を元に，四角形を描画する
    func draw(in view: MTKView) {
        // drawable と descriptor を参照して，commandBuffer と commandEncoder を作る
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
            else {return}

        commandEncoder.setRenderPipelineState(renderPipelineState)
        
        // vertexBuffer を 0 番目の index にセットする
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        // .triangle のプリミティブをバッファの 0 番目から，vertices.count 個描画する
        commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
        
        // 描画命令のコミット
        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
