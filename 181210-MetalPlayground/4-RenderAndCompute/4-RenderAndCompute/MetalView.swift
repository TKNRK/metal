//
//  MetalView.swift
//  2-ComputeShader
//
//  Created by Riku Takano on 2018/12/07.
//  Copyright © 2018 Riku Takano. All rights reserved.
//

import MetalKit

class MetalView: MTKView {
    var renderer: Renderer!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        guard let defaultDevice = MTLCreateSystemDefaultDevice()
            else {fatalError("Device loading error")}
        device = defaultDevice
        colorPixelFormat = .bgra8Unorm
        clearColor = MTLClearColor(red: 0.1, green: 0.57, blue: 0.25, alpha: 1)
        createRenderer(device: defaultDevice)
    }
    
    func createRenderer(device: MTLDevice){
        renderer = Renderer(device: device)
        delegate = renderer
    }

}


