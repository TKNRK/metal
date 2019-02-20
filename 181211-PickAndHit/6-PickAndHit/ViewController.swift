//
//  ViewController.swift
//  6-PickAndHit
//
//  Created by Riku Takano on 2018/12/11.
//  Copyright © 2018 Riku Takano. All rights reserved.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {
    var controller: ViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        controller = ViewControllerDelegate(view: view as! MTKView)
        controller.viewDidLoad()
        controller.renderer.setFrameSize(size: controller.view.frame.size)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        controller.mouseDown(with: event)
    }
    
    override func mouseDragged(with event: NSEvent) {
        controller.mouseDragged(with: event)
    }
    
    override func mouseUp(with event: NSEvent) {
        controller.mouseUp(with: event)
    }
}

extension ViewControllerDelegate {
    func mouseDown(with theEvent: NSEvent) {
        let p = view.convert(theEvent.locationInWindow, to: nil)
        renderer.mouse_down(x: Float(p.x), y: Float(p.y))
    }
    
    func mouseDragged(with theEvent: NSEvent) {
        let p = view.convert(theEvent.locationInWindow, to: nil)
        renderer.mouse_dragged(x: Float(p.x), y: Float(p.y))
    }
    
    func mouseUp(with theEvent: NSEvent) {
        let p = view.convert(theEvent.locationInWindow, to: nil)
        renderer.mouse_up(x: Float(p.x), y: Float(p.y))
    }
}

