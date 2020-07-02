//
//  CubeView.swift
//  LiquidMetal
//
//  Created by David Garcia on 6/26/20.
//  Copyright © 2020 Wodinga. All rights reserved.
//

import Foundation
import Metal
import MetalKit


struct VertexIn {
    var position : vector_float4 //<x,y>
    var color : vector_float4 //<R,G,B,A>
}

class CubeView: MTKView{
    let vertices = [
        VertexIn(position: [0,0, 0, 1], color: [0,1,0,1]),
        VertexIn(position: [0,1, 0, 1], color: [0,0,1,1]),
        VertexIn(position: [1,1, 0, 1], color: [1,1,1,1]),
    ]
    let viewMatrix: [vector_float4] = [
        [1,0,0,0],
        [0,1,0,0],
        [0,0,1,0],
        [0,0,0,1],
    ]
    var vertexBuffer : MTLBuffer!
    var library : MTLLibrary?
    var vertexFunc: MTLFunction?
    var fragmentFunc: MTLFunction?
    var viewportSize = vector_uint2(300,300)
    var  pipelineDescriptor = MTLRenderPipelineDescriptor()
    required init(coder: NSCoder) {
        super.init(coder:coder)
        
        /// Step 1: Create *device*
        device = MTLCreateSystemDefaultDevice()
        library = device?.makeDefaultLibrary()
        vertexFunc = library!.makeFunction(name: "vertex_func")
        fragmentFunc = library!.makeFunction(name: "fragment_func")
        vertexBuffer = device?.makeBuffer(length: MemoryLayout<VertexIn>.size * 4, options: [])
        
        // Set render pipeline descriptor to build render pipeline state
        pipelineDescriptor.label = "draw_vertices"
        pipelineDescriptor.vertexFunction = vertexFunc
        pipelineDescriptor.fragmentFunction = fragmentFunc
        pipelineDescriptor.colorAttachments[0].pixelFormat = colorPixelFormat
    }
    
    /// Step 2: override draw func in MTKView
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        /// Step 2a: Create render pass descriptor to configure renderer
        if let rpd = currentRenderPassDescriptor, let drawable = currentDrawable{
            let renderState = try! device!.makeRenderPipelineState(descriptor: pipelineDescriptor)
            /// Step 2b: add color attachments like
            rpd.colorAttachments[0].clearColor = MTLClearColorMake(0.5, 0.5, 0.5, 1.0)

            
            /// Step 2c: command buffer to hold GPU commands
            let command_buffer = device!.makeCommandQueue()?.makeCommandBuffer()
            let command_encoder = command_buffer!.makeRenderCommandEncoder(descriptor: rpd)
            command_encoder?.setRenderPipelineState(renderState)
            command_encoder?.label = "rendering_encoder"
            // Pass in the parameter data.
            command_encoder?.setVertexBytes(vertices, length: MemoryLayout<VertexIn>.size * vertices.count, index: 0)
            command_encoder?.setVertexBytes(viewMatrix, length: MemoryLayout<vector_float4>.size * viewMatrix.count, index: 1)
//            command_encoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
//            command_encoder?.setVertexBuffer(viewportSize, offset: 0, index: 1)
//            command_encoder?.setViewport(MTLViewport(originX: 0, originY: 0, width: Double(viewportSize.x), height: Double(viewportSize.y), znear: 0, zfar: 1))

            // Draw the triangle.
            command_encoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
            command_encoder?.endEncoding()
            
            // Schedule a present once the framebuffer is complete using the current drawable.
            command_buffer!.present(drawable)
            
            // Finalize rendering here & push the command buffer to the GPU.
            command_buffer!.commit()
        }
    }
    
}
