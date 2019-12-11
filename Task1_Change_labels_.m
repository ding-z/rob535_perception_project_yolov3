clear all; close all; fclose all; clc;
classes = {0,1,1,1,1,1,1,1,1,3,3,2,2,2,3,0,0,0,2,2,2,2,0};

%%
location = '../data-2019/test/';
datainformation = importdata('Detect_information.txt');
filepaths = datainformation.textdata;
labels = datainformation.data;

training_size_x = 512;
training_size_y = 512;

changed_label = fopen('Changed_label_v1.txt','w');
for idx = 1:size(labels,1)
    foldername = filepaths{idx}(20:end-15);
    imagename = filepaths{idx}(end-13:end);
    snapshot = [location, foldername, '/', imagename];
%     disp(snapshot)
    img = imread(snapshot);

    xyz = read_bin(strrep(snapshot, '_image.jpg', '_cloud.bin'));
    xyz = reshape(xyz, [], 3)';

    proj = read_bin(strrep(snapshot, '_image.jpg', '_proj.bin'));
    proj = reshape(proj, [4, 3])';

    uv = proj * [xyz; ones(1, size(xyz, 2))];
    uv = uv ./ uv(3, :);

    %%
    dist = vecnorm(xyz);
    
    cur_label = labels(idx,1);
    x_c = labels(idx,2); y_c =labels(idx,3);   %center in training image sizes
    
    x_scaled = x_c/training_size_x * size(img,2);
    y_scaled = y_c/training_size_y * size(img,1);
    
    nearest_id = knnsearch(uv(1:2,:)',[x_scaled y_scaled]);
    dist(nearest_id);
    if dist(nearest_id) > 50
        cur_label = 0;
        disp('Found larger than 50')
    end
    fprintf(changed_label,"%s %d %.5f\n",snapshot(19:end-10),cur_label,labels(idx,end));
    
end

fclose(changed_label);
% figure(1)
% clf()
% imshow(img)
% hold all
% scatter(x_scaled,y_scaled,30,'g','LineWidth',10)
% scatter(uv(1,nearest_id ),uv(2,nearest_id),30,'r','LineWidth',10)

%%
function data = read_bin(file_name)
id = fopen(file_name, 'r');
data = fread(id, inf, 'single');
fclose(id);
end
