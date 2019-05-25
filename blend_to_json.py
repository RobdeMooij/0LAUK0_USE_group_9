#exec(compile(open("C:/Users/s167917/Documents/#School/Jaar 3/4 Project USE Robots Everywhere/model/blend_to_json.py").read(), "C:/Users/s167917/Documents/#School/Jaar 3/4 Project USE Robots Everywhere/model/blend_to_json.py", 'exec'))
import json
import bpy

# get object
obj = bpy.context.active_object

#define empty dictionary/arrays
data = {}
vertices = []
triangles = []
materials = []
normals = []

#loop over vertices and scale them
for vertex in obj.data.vertices.values():
    vertices.append((vertex.co.x*10,vertex.co.y*10,vertex.co.z*10))
    
#loop over triangles and get indices+1 (for Matlab indexing), normals and material indices
for triangle in obj.data.polygons:
    triangles.append((triangle.vertices[0]+1,triangle.vertices[1]+1,triangle.vertices[2]+1))
    normals.append(triangle.normal[:])
    materials.append(triangle.material_index+1)
    
#data into dictionary
data["vertices"] = vertices
data["triangles"] = triangles
data["materials"] = materials
data["normals"] = normals

#dictionary to file
json.dump(data,open('test.json','w'))