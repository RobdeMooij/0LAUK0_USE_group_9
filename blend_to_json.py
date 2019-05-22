#exec(compile(open("C:/Users/s167917/Documents/#School/Jaar 3/4 Project USE Robots Everywhere/model/blend_to_json.py").read(), "C:/Users/s167917/Documents/#School/Jaar 3/4 Project USE Robots Everywhere/model/blend_to_json.py", 'exec'))
import json
import bpy
data = {}
obj = bpy.context.active_object
vertices = []
triangles = []
materials = []
normals = []
for vertex in obj.data.vertices.values():
    vertices.append((vertex.co.x,vertex.co.y,vertex.co.z))
for triangle in obj.data.polygons:
    triangles.append((triangle.vertices[0]+1,triangle.vertices[1]+1,triangle.vertices[2]+1))
    normals.append(triangle.normal[:])
    materials.append(triangle.material_index+1)
data["vertices"] = vertices
data["triangles"] = triangles
data["materials"] = materials
data["normals"] = normals
json.dump(data,open('iss.json','w'))