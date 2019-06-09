#exec(compile(open("C:/Users/s167917/Documents/#School/Jaar 3/4 Project USE Robots Everywhere/model/blend_to_json.py").read(), "C:/Users/s167917/Documents/#School/Jaar 3/4 Project USE Robots Everywhere/model/blend_to_json.py", 'exec'))
import json
import bpy

# get object
obj = bpy.context.active_object

#define empty dictionary/arrays
data = {}
vertices = []
indices = []
materials = []
normals = []
#loop over vertices and scale them
for vertex in obj.data.vertices.values():
    vertices.append((vertex.co.x*10,vertex.co.y*10,vertex.co.z*10))
    
#loop over triangles and get indices+1 (for Matlab indexing) and material indices
for triangle in obj.data.polygons:
    indices.append((triangle.vertices[0]+1,triangle.vertices[1]+1,triangle.vertices[2]+1))
    materials.append(triangle.material_index+1)
    
#data into dictionary
data["vertices"]  = vertices
data["indices"]   = indices
data["materials"] = materials

#dictionary to file
json.dump(data,open('iss_1.json','w'))