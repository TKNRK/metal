//
//  MetalView.swift
//  2-ComputeShader
//
//  Created by Riku Takano on 2018/12/07.
//  Copyright © 2018 Riku Takano. All rights reserved.
//

import MetalKit

class MetalView: MTKView {
    var monte_carlo: MonteCarlo!
    var mandelbrot: Mandelbrot!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("Device loading error")
        }
        device = defaultDevice
        colorPixelFormat = .bgra8Unorm
        clearColor = MTLClearColor(red: 0.1, green: 0.57, blue: 0.25, alpha: 1)
        createMonteCarlo(device: defaultDevice)
        // createMandelbrot(device: defaultDevice)
    }
    
    func createMonteCarlo(device: MTLDevice){
        monte_carlo = MonteCarlo(device: device)
        let samples = 100000
        monte_carlo.calculate(device: device, samples: samples)
        let pi = monte_carlo.readOutputBuffer(device: device)
        print(pi)
    }

    func createMandelbrot(device: MTLDevice){
        mandelbrot = Mandelbrot(device: device)
        delegate = mandelbrot
    }
    

    
}


