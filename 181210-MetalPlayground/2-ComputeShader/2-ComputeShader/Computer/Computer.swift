//
//  Computer.swift
//  2-ComputeShader
//
//  Created by Riku Takano on 2018/12/07.
//  Copyright © 2018 Riku Takano. All rights reserved.
//


import MetalKit

class Computer: NSObject {
    var commandQueue: MTLCommandQueue!
    var computePipelineState: MTLComputePipelineState!
    
    init(device: MTLDevice, func_name: String) {
        super.init()
        createCommandQueue(device: device)
        createComputePipeline(device: device, func_name: func_name)
    }
    
    // command queue を生成
    func createCommandQueue(device: MTLDevice) {
        commandQueue = device.makeCommandQueue()
    }
    
    // 継承するクラスの計算からシェーダーで使う関数の名前を受け取って compute pipeline を生成
    func createComputePipeline(device: MTLDevice, func_name: String) {
        guard let library = device.makeDefaultLibrary() else {return}
        let cs_function = library.makeFunction(name: func_name)!
        do {
            computePipelineState = try device.makeComputePipelineState(function: cs_function)
        }  catch {
            print(error.localizedDescription)
        }
    }
}
