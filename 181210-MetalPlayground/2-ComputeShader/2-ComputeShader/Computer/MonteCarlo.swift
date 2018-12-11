//
//  MonteCarlo.swift
//  2-ComputeShader
//
//  Created by Riku Takano on 2018/12/07.
//  Copyright © 2018 Riku Takano. All rights reserved.
//

import MetalKit

class MonteCarlo: Computer {
    // 計算結果を書き込む output のバッファを用意
    var outputData: [Bool]!
    var outputBuffer: MTLBuffer!
    
    init(device: MTLDevice) {
        super.init(device: device, func_name: "monte_carlo")
    }
    
    private func createBuffers(device: MTLDevice) {
        outputBuffer = device.makeBuffer(bytes: outputData,
                                         length: MemoryLayout<Bool>.stride * outputData.count,
                                         options: [])
    }

    // GPU 上で Monte Carlo 法を用いた円周率の計算を実行し，結果を output バッファに書き込む
    func calculate(device: MTLDevice, samples: Int) {
        outputData = [Bool](repeating: false, count: samples)
        createBuffers(device: device)

        guard let computeCommandBuffer = commandQueue.makeCommandBuffer(),
              let computeCommandEncoder = computeCommandBuffer.makeComputeCommandEncoder()
            else {return}
    
        computeCommandEncoder.setComputePipelineState(computePipelineState)
        // Number of thread groups
        let width = 8
        let height = 8
        let threadsPerGroup = MTLSize(width: width, height: height, depth: 1)
        let numThreadgroups = MTLSize(width: (samples + width - 1) / width, height: (samples + height - 1) / height, depth: 1)

        var w = uint(((samples + width - 1) / width) * width)
        computeCommandEncoder.setBytes(&w, length: MemoryLayout<uint>.stride, index: 0)
        computeCommandEncoder.setBuffer(outputBuffer, offset: 0, index: 1)

        computeCommandEncoder.dispatchThreadgroups(numThreadgroups, threadsPerThreadgroup: threadsPerGroup)
    
        computeCommandEncoder.endEncoding()
        computeCommandBuffer.commit()
        computeCommandBuffer.waitUntilCompleted()
    }
    
    // Output のバッファを参照し，円周率の計算を行う
    func readOutputBuffer(device: MTLDevice) -> Double {
        let data = Data(bytesNoCopy: outputBuffer.contents(), count: outputData.count, deallocator: .none)
        var resultData = [Bool](repeating: false, count: outputData.count)
        resultData = data.withUnsafeBytes {
            Array(UnsafeBufferPointer<Bool>(start: $0, count: data.count/MemoryLayout<Bool>.size))
        }
        
        let count = resultData.reduce(0) {$1 ? $0 + 1 : $0}
        return 4.0 * Double(count) / Double(resultData.count)
    }

}
