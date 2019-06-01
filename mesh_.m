classdef mesh_ < handle
   properties       
       vertices         %vertices coordinates
       indices          %vertices indices that make up triangle
       triangles        %triangle_ objects
       materials        %triangles material indices
%        normals          %normal vectors
   end
   methods(Access = public, Static)
        function obj = mesh_(file_name)
            %create mesh_ object based on (.json or .txt) file
			json_file = fopen(file_name);
            try %possible bug in jsondecode in Matlab version 2018b and higher
                json_data = jsondecode(fread(json_file,inf,'*char'));
            catch %use JSONlab toolbox (has to be installed)
                json_data = loadjson(file_name);
            end
            fclose(json_file);
            obj.vertices    = json_data.vertices;
            obj.indices     = json_data.triangles;
            obj.materials   = json_data.materials;
%             obj.normals     = json_data.normals;

            %create triangle_ objects
            for i = 1:size(obj.indices,1)
                obj.triangles = [obj.triangles triangle_(obj.vertices(obj.indices(i,1),:),obj.vertices(obj.indices(i,2),:),obj.vertices(obj.indices(i,3),:),obj.materials(i))]; % obj.normals(i,:),
            end
        end
   end
   methods(Access = public)
        function show(this,scale)
            %shows mesh            
            hold on
            for triangle = this.triangles
                triangle.show()
            end
            hold off
            view(-135,30)
            rotate3d on            
            axis([-1 1 -1 1 -1 1]*scale)
            axis vis3d
            xlabel('x [m]')
            ylabel('y [m]')
            zlabel('z [m]')
            grid on
        end
    end
end