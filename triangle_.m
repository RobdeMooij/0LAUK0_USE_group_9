classdef triangle_ < handle
    properties
        point_1         %position of first point in the triangle
        point_2         %position of second point in the triangle
        point_3         %position of third point in the triangle
        edge_1          %point_2-point_1
        edge_2          %point_3-point_1
        material        %material index
%         normal          %normal vector
    end
    methods(Access = public, Static)
        function obj = triangle_(point_1,point_2,point_3,material) % normal,
            obj.point_1  = point_1;
            obj.point_2  = point_2;
            obj.point_3  = point_3;
            obj.edge_1   = obj.point_2-obj.point_1;
            obj.edge_2   = obj.point_3-obj.point_1;
            obj.material = material;
%             obj.normal   = normal;
        end
    end    
end

