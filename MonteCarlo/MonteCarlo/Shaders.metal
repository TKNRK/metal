//
//  Shaders.metal
//  MonteCarlo
//
//  Created by Riku Takano on 2018/12/01.
//  Copyright © 2018 Riku Takano. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position;
    float4 color;
};


struct VertexOut {
    float4 position [[ position ]];
    float4 color;
};

vertex VertexOut basic_vertex_function(const device VertexIn *vertices [[ buffer(0) ]],
                                       uint vertexID [[ vertex_id  ]]) {
    VertexOut vOut;
    vOut.position = float4(vertices[vertexID].position,1);
    vOut.color = vertices[vertexID].color;
    return vOut;
}

fragment float4 basic_fragment_function(VertexOut vIn [[ stage_in ]]) {
    return vIn.color;
}

kernel void monte_carlo(texture2d<float, access::write> output [[texture(0)]],
                        const device float2 *inPoints [[ buffer(1) ]],
                        device bool *outBools [[ buffer(2) ]],
                        uint id [[ thread_position_in_grid ]]) {
    const float2 location = inPoints[id];
    const float x = location.x;
    const float y = location.y;
    outBools[id] = (sqrt((x * x) + (y * y)) < 1.0) ? true : false;
}

kernel void draw_red(texture2d<float, access::write> output [[texture(0)]],
                    uint2 gid [[thread_position_in_grid]]) {
    output.write(float4(1, 0, 0, 1), gid);
}

float4 hsv2rgb(float h, float s, float v) {
    float3 rgb = float3(v, v, v);
    h *= 6;
    int i = (int)h;
    float f = h - i;
    switch (i) {
        case 0:
            rgb.g *= 1 - s * (1 - f);
            rgb.b *= 1 - s;
            break;
        case 1:
            rgb.r *= 1 - s * f;
            rgb.b *= 1 - s;
            break;
        case 2:
            rgb.r *= 1 - s;
            rgb.b *= 1 - s * (1 - f);
            break;
        case 3:
            rgb.r *= 1 - s;
            rgb.g *= 1 - s * f;
            break;
        case 4:
            rgb.r *= 1 - s * (1 - f);
            rgb.g *= 1 - s;
            break;
        case 5:
            rgb.g *= 1 - s;
            rgb.b *= 1 - s * f;
    }
    return float4(rgb, 1);
}

kernel void mandelbrot(texture2d<float, access::write> output [[texture(0)]],
                       uint2 gid [[thread_position_in_grid]]){
    const int NCOLOR = 256;

    float width = output.get_width();
    float height = output.get_height();
    float2 c = float2(gid) / float2(width, height);

    float2 z = float2(0, 0);
    int n = 0;
    while (n < (NCOLOR * 2 - 1) && length(z) <= 2) {
        float2 z1 = float2(z.x * z.x - z.y * z.y + c.x, 2 * z.x * z.y + c.y);
        z = z1;
        n++;
    }
    float v = 1 - (float)n / NCOLOR;
    float4 out_color = hsv2rgb(fmod(v + 0.6 + (n % 5 * 0.03), 1.0), 1, v);
    output.write(out_color, gid);
}

