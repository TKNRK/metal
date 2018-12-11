//
//  Shaders.metal
//  2-ComputeShader
//
//  Created by Riku Takano on 2018/12/07.
//  Copyright © 2018 Riku Takano. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float2 position;
};

struct VertexOut {
    float4 position [[ position ]];
    float4 color;
};

vertex VertexOut vs(const device VertexIn *vertices [[ buffer(0) ]],
                                       uint vertexID [[ vertex_id  ]]) {
    VertexOut vOut;
    vOut.position = float4(vertices[vertexID].position, 0, 1);
    return vOut;
}

fragment float4 fs(VertexOut vIn [[ stage_in ]]) {
    
    return vIn.color;
}

const

kernel void compute(constant float &time [[ buffer(0) ]],
                        device float2 *vertices [[ buffer(1) ]],
                        uint gid [[ thread_position_in_grid ]]) {
    float2 p;
    if (gid == 0) {
        p = float2(cos(time), 0.5 + sin(time));
    }
    if (gid == 1) {
        p = float2(0.5 + cos(time), -0.5 + sin(time));
    }
    if (gid == 2) {
        p = float2(-0.5 + cos(time), -0.5 + sin(time));
    }
    vertices[gid] = p;
}

