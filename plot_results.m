clear; close all
data = load('data_complete_fixed.mat');
data = data.data.complete_data;

n_cases = length(unique(data(:,1)));
n_conds = size(data,1)/n_cases;
diams_all = reshape(data(:,2),[n_conds,n_cases]);
azi_all = reshape(data(:,3),[n_conds,n_cases]);
ele_all = reshape(data(:,4),[n_conds,n_cases]);
hits_all = reshape(data(:,5),[n_conds,n_cases]);
vels_all = reshape(data(:,6),[n_conds,n_cases]);
dists_all = reshape(data(:,7),[n_conds,n_cases]);
offsety_all = reshape(data(:,8),[n_conds,n_cases]);
offsetz_all = reshape(data(:,9),[n_conds,n_cases]);

diams = diams_all(hits_all(:,1)>1,:);
azi = azi_all(hits_all(:,1)>1,:);
ele = ele_all(hits_all(:,1)>1,:);
hits = hits_all(hits_all(:,1)>1,:);
vels = vels_all(hits_all(:,1)>1,:);
dists = dists_all(hits_all(:,1)>1,:);
offsety = offsety_all(hits_all(:,1)>1,:);
offsetz = offsetz_all(hits_all(:,1)>1,:);

colors = {[0.5843 0.8157 0.9882],[0 0 1],[0 1 0],[1 1 0],[1 0.5 0]};
colors_vel = {[0 0 1],[255 153 153]/255,[255 102 102]/255,[255 0 0]/255};
legend_cell = {'No lasers','1','1 tilted','2','3'};
labels = {'Diameter (m)','Azimuth (rad)','Elevation (rad)',...
                'Hits (-)','Impact velocity (m/s)','Least distance (m)',...
                'Horizontal offset (m)','Vertical offset (m)'};


%bar_plot_summary(hits,5,dists,colors)
%bar_plot_vels(hits,vels,4,dists,colors_vel)
%input_to_hits(diams,labels{1},hits,vels,legend_cell)
angle_plots(azi_all,ele_all,offsety_all,offsetz_all,hits_all,vels_all,diams_all,legend_cell)

function bar_plot_summary(hits,hit_classes,dists,colors)
bar_data = zeros(size(hits,2),hit_classes);
figure
for cas = 1:5
    bar_data(cas,1) = ((sum(hits(:,cas)==1 & dists(:,cas)>1000))/size(hits(:,cas),1))*100;
    bar_data(cas,2) = ((sum(hits(:,cas)==1 & dists(:,cas)<=1000))/size(hits(:,cas),1))*100;
    for hit_class = 2:hit_classes-1
        bar_data(cas,hit_class+1) = (sum(hits(:,cas)==hit_class)/size(hits(:,cas),1))*100;
    end
end

bar_plot = bar(bar_data,'FaceColor','flat');
xlabel('Laser categories')
ylabel('%Hits')
xticklabels({'No laser','1 laser','1 laser, tilted','2 lasers','3 lasers'})
legend('Far miss','Near miss','Low','Medium','High','Location','Best')
set(gcf,'Color', 'w');

size(bar_data)
for k = 1:size(bar_data,2)
    bar_plot(k).CData = colors{k};
end  
end

function bar_plot_vels(hits,vels,hit_classes,dists,colors)
bar_data = zeros(size(hits,2),hit_classes);
figure
for cas = 1:5
    bar_data(cas,1) = ((sum(hits(:,cas)==1))/size(hits(:,cas),1))*100;
    bar_data(cas,2) = ((sum(hits(:,cas)>1&vels(:,cas)<5000))/size(hits(:,cas),1))*100;
    bar_data(cas,3) = ((sum(hits(:,cas)>1&vels(:,cas)>=5000&vels(:,cas)<10000))/size(hits(:,cas),1))*100;
    bar_data(cas,4) = ((sum(hits(:,cas)>1&vels(:,cas)>=10000))/size(hits(:,cas),1))*100;
%     for hit_class = 2:hit_classes-1
%         bar_data(cas,hit_class+1) = (sum(hits(:,cas)==hit_class)/size(hits(:,cas),1))*100;
%     end
end

bar_plot = bar(bar_data,'FaceColor','flat');
xlabel('Laser categories')
ylabel('%Hits')
xticklabels({'No laser','1 laser','1 laser, tilted','2 lasers','3 lasers'})
legend('Miss','<5 km/s','5-10 km/s','>10 km/s','Location','Best')
set(gcf,'Color', 'w');

size(bar_data)
for k = 1:size(bar_data,2)
    bar_plot(k).CData = colors{k};
end  
end


function input_to_hits(input,input_label,hits,velocities,legend_cell)
figure
for cas = 2:5
    input_list = unique(input);
    
    hit_array = zeros(length(input_list),1);
    for i = 1:size(input_list,1)
        diam_ids = input(:,cas)==input_list(i);
        %hit_array(i) = (sum(hits(diam_ids,cas)>1)/sum(hits(diam_ids,1)>1))*100;
        hit_array(i) = mean(velocities(diam_ids&hits(:,cas)>1,cas))
    end

    plot(input_list,hit_array,'-o','Linewidth',2)
    hold on
end
legend(legend_cell{2:5},'Location','Best')
set(gcf,'Color', 'w');
xlabel(input_label)
ylabel('%Hits')
%ylim([0 100])
xlim([min(input(:)) max(input(:))])

hold off
end

function angle_plots(azimuths,elevations,offsety,offsetz,impacts,velocities,diameters,legend_cell)
colors = {[0 0 0],[0 1 0],[1 1 0],[1 0.7 0]};
figure('color','w','units','normalized','outerposition',[0 0 1 1])
factor = 3/max(velocities(:));
for current_case = 1:size(azimuths,2)
%     diameter_list   = data(:,1,current_case);
    %azimuth_list    = data(:,2,current_case);
%     elevations_list = data(:,3,current_case);
    %impact_list     = data(:,4,current_case);
    %velocity_list   = data(:,5,current_case);
    azimuth_lists = azimuths(:,current_case);
    azimuth_list = unique(azimuth_lists);
    ele_list = elevations(:,current_case);
    ele_range = unique(ele_list);
    ele = ele_range(1);
    offsety_list = offsety(:,current_case);
    offy_list = unique(offsety_list);
    offsetz_list = offsetz(:,current_case);
    offz_list = unique(offsetz_list);
    offy = offy_list(3);
    offz = offz_list(3);
    
    impact_list = impacts(:,current_case);
    velocity_list = velocities(:,current_case);
    diam_list = diameters(:,current_case);
    udiams = unique(diam_list);
    dia = udiams(3);

    if current_case == 1
        subplot(4,2,[1,2,3,4])
    else
        subplot(4,2,current_case+3)
    end
    title(legend_cell{current_case})
    axis equal
%     factor = 3/max(velocity_list);
    nr_steps = size(azimuth_list,1);
    for i = 1:nr_steps
        %any(azimuth_lists==azimuth_list(i)&diam_list==dia&ele_list==ele&offsety_list==offsety&offsetz_list==offz)
        mean_vel = velocity_list(azimuth_lists==azimuth_list(i)&diam_list==dia&ele_list==ele&offsety_list==offy&offsetz_list==offz)
%         x = [sin(azimuth_list(i)/2)/2 sin(azimuth_list(i)/2)*((velocity_list(i) ~= 0)/2+velocity_list(i)*factor)];
%         y = [cos(azimuth_list(i)/2)/2 cos(azimuth_list(i)/2)*((velocity_list(i) ~= 0)/2+velocity_list(i)*factor)];
        x = [sin(azimuth_list(i)/2)/2 sin(azimuth_list(i)/2)*((mean_vel ~= 0)/2+mean_vel*factor)];
        y = [cos(azimuth_list(i)/2)/2 cos(azimuth_list(i)/2)*((mean_vel ~= 0)/2+mean_vel*factor)];
        line(x,y,'Color',colors{impact_list(azimuth_lists==azimuth_list(i)&diam_list==dia&ele_list==ele&offsety_list==offy&offsetz_list==offz)})
    end
    draw_circle(0.5,60)
    draw_circle(3.5,60)
end
end


function draw_circle(radius,nr_steps)
    angles = 0:pi/nr_steps:pi;
    x = cos(angles)*radius;
    y = sin(angles)*radius;
    line(x,y,'Color',[0 0 0])    
end


% for cas = 1:4
%     figure
%     n = size(cases(:,:,cas),1);
%     C = zeros(n,3);
%     S = zeros(n,1);
%     vel_norm = vel(:,:,cas)/norm(vel(:,:,cas));
%     size(C)
%     size(vel_norm)
%     for hit_id = 1:length(hit(:,:,cas))
%         color = colors{hit(hit_id,:,cas)};
%         C(hit_id,:) = color;%*vel_norm(hit_id); 
%         S(hit_id) = 1;%vel_norm(hit_id);
%     end
%     scatter(azi(:,:,cas),ele(:,:,cas),S,C)
%     %hold on
% end
% %hold off




