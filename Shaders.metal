//
//  Shaders.metal
//  LiquidMetal
//
//  Created by David Garcia on 7/1/20.
//  Copyright © 2020 Wodinga. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

struct Vertex {
    float4 position [[position]];
    float4 color;
};

constant uint AAPLVertexInputIndexViewportSize = 1;
vertex Vertex vertex_func(constant Vertex *vertices [[buffer(0)]],
                          constant float4x4 &matrix [[buffer(1)]],
                          uint vid [[vertex_id]]) {
    Vertex in = vertices[vid];
    Vertex out;
    
    out.position = float4(in.position) * matrix;
    out.color = in.color;
    return out;
}

fragment float4 fragment_func(Vertex vert [[stage_in]]) {
    return vert.color;
}
