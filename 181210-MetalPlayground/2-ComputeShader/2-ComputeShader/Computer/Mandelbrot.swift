//
//  Mandelbrot.swift
//  2-ComputeShader
//
//  Created by Riku Takano on 2018/12/07.
//  Copyright © 2018 Riku Takano. All rights reserved.
//

import MetalKit

class Mandelbrot: Computer {

    // マンデルブロの入力データはグリッドの id だけを使用するので，buffer は使わない
    init(device: MTLDevice) {
        super.init(device: device, func_name: "mandelbrot")
    }

}

extension Mandelbrot: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        view.framebufferOnly = false
        guard let drawable = view.currentDrawable,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let commandEncoder = commandBuffer.makeComputeCommandEncoder()
            else {return}
        
        commandEncoder.setComputePipelineState(computePipelineState)
        // 描画画面を compute shader に送り込む
        commandEncoder.setTexture(drawable.texture, index: 0)
        // thread group を作成
        let threadGroupCount = MTLSizeMake(8, 8, 1)
        let threadGroups = MTLSizeMake(drawable.texture.width / threadGroupCount.width, drawable.texture.height / threadGroupCount.height, 1)
        // 計算を実行
        commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
        // GPU に命令をコミット
        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
