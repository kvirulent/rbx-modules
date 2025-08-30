// xirulent 2025
// Geometry primitive objects, geometry algorithms, EditableMesh debugging functions, etc.

import { Workspace } from "@rbxts/services";

export const set_marker = (mesh: EditableMesh, pos: Vector3, vertex: number) => {
    let tag = mesh.IdDebugString(vertex);

    let marker = new Instance("Part");
    marker.Position = pos;
    marker.Size = new Vector3(0.05, 0.05, 0.05)
    marker.Color = new Color3(0.15,0.83,1)
    marker.Material = Enum.Material.Neon;
    marker.Anchored = true;

    let marker_tag_billboard = new Instance("BillboardGui", marker);
    marker_tag_billboard.Size = UDim2.fromScale(1,1);
    marker_tag_billboard.AlwaysOnTop = true;

    let marker_tag_text = new Instance("TextLabel", marker_tag_billboard);
    marker_tag_text.BackgroundTransparency = 1;
    marker_tag_text.Position = UDim2.fromScale(0,0);
    marker_tag_text.Size = UDim2.fromScale(1,1);
    marker_tag_text.Text = tag;
    marker_tag_text.TextColor3 = new Color3(1,1,1);

    marker.Parent = Workspace;
}

/** Greatest common divisor of two numerics */
const gcd = (a: number, b: number): number => {
    const precision = 6;
    const mul = math.pow(10, precision);

    let scaled_a = math.round(a * mul);
    let scaled_b = math.round(a * mul);

    while (scaled_b !== 0) {
        let t = scaled_b;
        scaled_b = scaled_a % scaled_b;
        scaled_a = t;
    }

    return scaled_a / mul;
}

/** Least common divisor of two numerics */
const lcd = (a: number, b: number): number => {
    if (a === 0 || b === 0) return 0;
    return math.abs(a*b)/ gcd(a,b);
}

/** Least common divisor among an array of numerics */
const lcdarr = (arr: number[]): number => {
    if (!arr || arr.size() === 0) return 0;

    let r = arr[0];
    for (let i = 1; i < arr.size(); i++) {
        r = lcd(r, arr[i]);
    }

    return r;
}

/** Least common divisible components of an array of vectors */
export const lcdvec3arr = (arr: Vector3[]): Vector3 => {
    const x = arr.map(element => element.X);
    const y = arr.map(element => element.Y);
    const z = arr.map(element => element.Z);

    let r = new Vector3(
        lcdarr(x),
        lcdarr(y),
        lcdarr(z)
    );

    return r;
}

/** Apply offset vector to every vector in arr */
export const offset_vector_array = (arr: Vector3[], offset: Vector3): Vector3[] => {
    let r: Vector3[] = [];
    arr.forEach((element: Vector3) => {
        r.push(element.add(offset));
    })

    return r;
}

/** TODO: Modify this function to always create geometry which winds counter-clockwise, regardless of the input values */
export const quad = (v1: number, v2: number, v3: number, v4: number): number[] => {
    let r: number[] = []
    r.push(v1,v2,v3);
    r.push(v1,v3,v4);

    return r;
}

/** TODO: See geometry.quad() */
export const get_quad_buffer = (): [Vector3[], number[]] => {
    let vertex_buffer: Vector3[] = [
        new Vector3(0,0,0),
        new Vector3(1,0,0),
        new Vector3(0,1,0),
        new Vector3(1,1,0),
    ]

    let index_buffer: number[] = [
        ...quad(1,2,3,4)
    ];

    return [vertex_buffer, index_buffer];
}

/** Returns geometry data for a cube object */
export const get_cube_buffer = (): [Vector3[], number[]] => {
    let vertex_buffer: Vector3[] = [
        new Vector3(0,0,0), //1
        new Vector3(2,0,0), //2
        new Vector3(0,2,0), //3
        new Vector3(2,2,0), //4
        new Vector3(0,0,2), //5
        new Vector3(2,0,2), //6
        new Vector3(0,2,2), //7
        new Vector3(2,2,2), //8
    ];

    // This should be a loop, but the quad() function doesn't wind faces properly
    let index_buffer: number[] = [
        3,2,1,
        3,4,2,
        3,1,5,
        3,5,7,
        7,8,4,
        7,4,3,
        4,6,2,
        4,8,6,
        6,5,1,
        2,6,1,
        7,5,6,
        6,8,7,
    ];

    return [vertex_buffer, index_buffer];
}