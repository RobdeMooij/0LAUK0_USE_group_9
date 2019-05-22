classdef triangle_ < handle
    properties
        point_1
        point_2
        point_3
        edge_1
        edge_2
        material
        normal
    end
    methods(Access = public, Static)
        function obj = triangle_(point_1,point_2,point_3,normal,material)
            obj.point_1  = point_1;
            obj.point_2  = point_2;
            obj.point_3  = point_3;
            obj.edge_1   = obj.point_2-obj.point_1;
            obj.edge_2   = obj.point_3-obj.point_1;
            obj.material = material;
            obj.normal   = normal;
        end
    end    
end

