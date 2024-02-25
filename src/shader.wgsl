struct VertexInput {
    @location(0) position: vec3<f32>,
    @location(1) tex_coords: vec2<f32>,
}

struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0) tex_coords: vec2<f32>,
}

struct Point{
    @location(2) position: vec2<f32>,
}

struct Points{
    @location(3) points: array<Point>,
}

@vertex
fn vs_main(
    model: VertexInput,
) -> VertexOutput {
    var out: VertexOutput;
    out.tex_coords = model.tex_coords;
    out.clip_position = vec4<f32>(model.position, 1.0);
    return out;
}

// create rand xor shift function
// fn xorshift64star(seed: u32) -> u32 {
//     var x = seed;
//     x ^= x >> 12;
//     x ^= x << 25;
//     x ^= x >> 27;
//     return x;
// }


// Fragment shader
// group(0): texture_bind_group_layout
//  binding(0): bindGroupLayoutEntry binding 0
@group(0) @binding(0) 
var t_diffuse: texture_2d<f32>;
@group(0) @binding(1)
var s_diffuse: sampler;

@group(1) @binding(0)
var<storage> points: Points;
// https://sotrh.github.io/learn-wgpu/beginner/tutorial5-textures/#the-results
@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    let tex_coords: vec2<f32> = in.tex_coords;
    // var sample = textureSample(t_diffuse, s_diffuse, tex_coords);
    var sample = vec4<f32>(0.0, 0.0, 0.0, 1.0);
    var min_dist = 1.5;
    var id = 0u;
    
    for (var i = 0u; i < arrayLength(&points.points); i = i + 1u){
        let point = points.points[i];
        let dist = distance(tex_coords, point.position);
        if (dist < min_dist){
            min_dist = dist;
            id = i;
        }
    }
    let precent = f32(id) / 100.0;
    var hue = mix(0.0, 48.0, precent*2.0);
    if (precent > 0.5){
        hue = mix(188.0, 220.0, (precent - 0.5)*2.0);
    }
    // let saturation = mix(0.2,1.0,precent);
    let saturation = 1.0;
    let value = 0.9;
    sample = hsv2rgb(vec3<f32>(f32(hue), f32(saturation), f32(value)));
    // sample = color(id);

    return sample;
}

// fn color(i: u32) -> vec4<f32>{
//   let l = i;
//   let r = f32((l >>  0u) & 255u)/255.0;
//   let g = f32((l >>  8u) & 255u)/255.0;
//   let b = f32((l >> 16u) & 255u)/255.0;
//   return vec4<f32>(r,g,b, 1.0);
// }


fn hsv2rgb(hsv: vec3<f32>) -> vec4<f32> {
    let c = hsv.y * hsv.z;
    let x = c * (1.0 - abs((hsv.x / 60.0) % 2.0 - 1.0));    
    let m = hsv.z - c;
    var rgb: vec4<f32>;

    if (0.0 <= hsv.x && hsv.x < 60.0) {
        rgb = vec4<f32>(c, x, 0.0, 1.0);
    } else if (60.0 <= hsv.x && hsv.x < 120.0) {
        rgb = vec4<f32>(x, c, 0.0, 1.0);
    } else if (120.0 <= hsv.x && hsv.x < 180.0) {
        rgb = vec4<f32>(0.0, c, x, 1.0);
    } else if (180.0 <= hsv.x && hsv.x < 240.0) {
        rgb = vec4<f32>(0.0, x, c, 1.0);
    } else if (240.0 <= hsv.x && hsv.x < 300.0) {
        rgb = vec4<f32>(x, 0.0, c, 1.0);
    } else {
        rgb = vec4<f32>(c, 0.0, x, 1.0);
    }

    return rgb + m;
}