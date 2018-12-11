//
//  MetalView.swift
//  5-PickAndHit
//
//  Created by Riku Takano on 2018/12/08.
//  Copyright © 2018 Riku Takano. All rights reserved.
//


import MetalKit

class MetalView: MTKView {
    var renderer: Renderer!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        // Metal が使える GPU じゃなかったらエラーを返す
        guard let defaultDevice = MTLCreateSystemDefaultDevice()
            else {fatalError("Device loading error")}
        
        device = defaultDevice
        // 画面の背景色を RGBA で設定
        colorPixelFormat = .bgra8Unorm
        clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1)
        
        // 描画の設定や命令を作成（Renderer.swift）
        createRenderer(device: defaultDevice)
    }
    
    func createRenderer(device: MTLDevice){
        renderer = Renderer(device: device)
        delegate = renderer
    }
    
}
