//
//  Shaders.metal
//  MetalSwift
//
//  Created by Riku Takano on 2018/11/14.
//  Copyright © 2018 Riku Takano. All rights reserved.
//
//  参考：http://glslsandbox.com/e#50487.2

#include <metal_stdlib>
using namespace metal;

typedef struct Vertex {
    float2 position;
    //float2 complex;
} VS_In;

typedef struct VS_Out {
    float4 position [[ position ]];
    float2 complex;
} FS_In;

typedef float4 FS_Out;

vertex VS_Out vs(const device VS_In *vertices [[ buffer(0) ]],
                 constant float2x2 &C [[ buffer(1) ]],
                 uint id [[ vertex_id ]]) {
    VS_Out out;
    out.position = float4(vertices[id].position, 0, 1);
    switch (id) {
        case 0: out.complex.xy = C[0]; break;
        case 1: out.complex.xy = float2(C[1].x, C[0].y); break;
        case 2: out.complex.xy = float2(C[0].x, C[1].y); break;
        case 3: out.complex.xy = C[1]; break;
    }
    return out;
}


float field2(float3 p, float s, float time) {
    float strength = 7. + .03 * log(1.e-6 + fract(sin(time) * 4373.11));
    float accum = s/4.;
    float prev = 0.;
    float tw = 0.;
    for (int i = 0; i < 18; ++i) {
        float mag = dot(p, p);
        p = abs(p) / mag + float3(-cos(p.y-p.x-time*0.04), (cos(p.x+p.y-time*0.4)*0.5)-0.3925, (sin(time*0.1)*0.5)-1.0);
        float w = exp(-float(i) / 9.);
        accum += w * exp(-strength * pow(abs(mag - prev), 2.2));
        tw += w;
        prev = mag;
    }
    float r = max(0., 5. * accum / tw - .7);
    return r;
}

fragment FS_Out fs(FS_In pixel [[ stage_in ]],
                   constant float &time [[ buffer(2) ]]) {
    float2 p = pixel.complex;
    float2 resolution = float2((2 + p[0]) / 3, (2 + p[1]) / 3);
    float f = field2(float3(resolution, 1.0), 0.001, time);
    float3 color = float3(f * f * f * (0.5 + sin(time - resolution[0] * resolution[1]) * 0.5) * 0.4, f*f*0.5, f*f*f*0.19);
    return float4(color, 1);
}
