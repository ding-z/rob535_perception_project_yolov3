clear all; close all; clc;
classes = {0,1,1,1,1,1,1,1,1,3,3,2,2,2,3,0,0,0,2,2,2,2,0};

%%
files = dir('../data-2019/trainval/*/*_image.jpg');

for idx = 1:size(files,1)
    find = 0;
    snapshot = [files(idx).folder, '/', files(idx).name];
    disp(snapshot)

    image_name = [files(idx).folder(74:end),'_', files(idx).name];
    image_name = image_name(1:end-4);
    img = imread(snapshot);

    xyz = read_bin(strrep(snapshot, '_image.jpg', '_cloud.bin'));
    xyz = reshape(xyz, [], 3)';

    proj = read_bin(strrep(snapshot, '_image.jpg', '_proj.bin'));
    proj = reshape(proj, [4, 3])';

    try
        bbox = read_bin(strrep(snapshot, '_image.jpg', '_bbox.bin'));
    catch
        disp('[*] no bbox found.')
        bbox = single([]);
    end
    bbox = reshape(bbox, 11, [])';

    uv = proj * [xyz; ones(1, size(xyz, 2))];
    uv = uv ./ uv(3, :);

    %%
    dist = vecnorm(xyz);
    annotation = fopen(['./labels/',image_name,'.txt'],'w');
    for k = 1:size(bbox, 1)
        R = rot(bbox(k, 1:3));
        t = reshape(bbox(k, 4:6), [3, 1]);

        sz = bbox(k, 7:9);
        [vert_3D, edges] = get_bbox(-sz / 2, sz / 2);
        vert_3D = R * vert_3D + t;

        vert_2D = proj * [vert_3D; ones(1, size(vert_3D, 2))];
        vert_2D = vert_2D ./ vert_2D(3, :);

        [BOX,~] = get_2d_box(vert_2D,[size(img,2),size(img,1)]);
        upperleft_x = BOX(1);
        upperleft_y = BOX(2);
        width = BOX(3);
        height = BOX(4);
        c_x = upperleft_x + width/2;
        c_y = upperleft_y + height/2;

        width_scaled = width/size(img,2);
        height_scaled = height/size(img,1);
        x_scaled = c_x/size(img,2);
        y_scaled = c_y/size(img,1);


        t = double(t);  % only needed for `text()`
        c = classes{int64(bbox(k, 10)) + 1};
        ignore_in_eval = logical(bbox(k, 11));

        if ignore_in_eval == 0
            find = 1;
            fprintf(annotation,'%d %.5f %.5f %.5f %.5f\n',c,x_scaled,y_scaled,width_scaled,height_scaled);
        end
    end
    fclose(annotation);
    if find == 0
        delete(['./labels/',image_name,'.txt']);
    else
        resized_img = imresize(img,[512,512]);
        imwrite(resized_img, ['./images/',image_name,'.jpg']);
    end
end

%%
function [v, e] = get_bbox(p1, p2)
v = [p1(1), p1(1), p1(1), p1(1), p2(1), p2(1), p2(1), p2(1)
    p1(2), p1(2), p2(2), p2(2), p1(2), p1(2), p2(2), p2(2)
    p1(3), p2(3), p1(3), p2(3), p1(3), p2(3), p1(3), p2(3)];
e = [3, 4, 1, 1, 4, 4, 1, 2, 3, 4, 5, 5, 8, 8
    8, 7, 2, 3, 2, 3, 5, 6, 7, 8, 6, 7, 6, 7];
end

%%
function R = rot(n)
theta = norm(n, 2);
if theta
    n = n / theta;
    K = [0, -n(3), n(2); n(3), 0, -n(1); -n(2), n(1), 0];
    R = eye(3) + sin(theta) * K + (1 - cos(theta)) * K^2;
else
    R = eye(3);
end
end

%%
function data = read_bin(file_name)
id = fopen(file_name, 'r');
data = fread(id, inf, 'single');
fclose(id);
end

function [box_2d, vert_2D_fix] = get_2d_box(vert_2D, image_size)
%% convert 2D box (8 points) to matlab box (x,y,width,height) while handling 
% out of image.
%Image size is x y (size(img,2), size(img,1))

% Point indices correspondence. Left-Right.
% [8 6]
% [4 2]
% [7 5]
% [3 1]
% Map from 1 2 3 4 5 6 7 8
idx_lr =  [3 4 1 2 7 8 5 6];

% Up-down.
% [6 5]
% [2 1]
% [8 7]
% [4 3]
% Map from 1 2 3 4 5 6 7 8
idx_ud =  [2 1 4 3 6 5 8 7];


vert_2D_fix = vert_2D;

% Handle out of image box.
% Left side out.
idx_out = find(vert_2D_fix(1,:) < 1 );
for i = idx_out
    j = idx_lr(i);
    x0 = vert_2D_fix(1,i);
    x1 = vert_2D_fix(1,j);
    y0 = vert_2D_fix(2,i);
    y1 = vert_2D_fix(2,j);

    % Compute new x, y.
    x2 = 1;
    y2 = (y1 - y0)*(x2 - x0)/(x1 - x0) + y0;
    % Update x, y.
    vert_2D_fix(1,i) = x2;
    vert_2D_fix(2,i) = y2;
end

% Right side out.
idx_out = find(vert_2D_fix(1,:) > image_size(1));
for i = idx_out
    j = idx_lr(i);
    x0 = vert_2D_fix(1,i);
    x1 = vert_2D_fix(1,j);
    y0 = vert_2D_fix(2,i);
    y1 = vert_2D_fix(2,j);

    % Compute new x, y.
    x2 = image_size(1);
    y2 = (y1 - y0)*(x2 - x0)/(x1 - x0) + y0;
    % Update x, y.
    vert_2D_fix(1,i) = x2;
    vert_2D_fix(2,i) = y2;
end

% Up side out.
idx_out = find(vert_2D_fix(2,:) < 1);
for i = idx_out
    j = idx_ud(i);
    x0 = vert_2D_fix(1,i);
    x1 = vert_2D_fix(1,j);
    y0 = vert_2D_fix(2,i);
    y1 = vert_2D_fix(2,j);

    % Compute new x, y.
    y2 = 1;
    x2 = (x1 - x0)*(y2 - y0)/(y1 - y0) + x0;
    % Update x, y.
    vert_2D_fix(1,i) = x2;
    vert_2D_fix(2,i) = y2;
end

% Down side out.
idx_out = find(vert_2D_fix(2,:) > image_size(2));
for i = idx_out
    j = idx_ud(i);
    x0 = vert_2D_fix(1,i);
    x1 = vert_2D_fix(1,j);
    y0 = vert_2D_fix(2,i);
    y1 = vert_2D_fix(2,j);

    % Compute new x, y.
    y2 = image_size(2);
    x2 = (x1 - x0)*(y2 - y0)/(y1 - y0) + x0;
    % Update x, y.
    vert_2D_fix(1,i) = x2;
    vert_2D_fix(2,i) = y2;
end

% Convert 2D box to matlab box format.
box_x = min(vert_2D_fix(1,:));
box_y = min(vert_2D_fix(2,:));
width_x = max(vert_2D_fix(1,:)) - min(vert_2D_fix(1,:));
height_y = max(vert_2D_fix(2,:)) - min(vert_2D_fix(2,:));
box_2d = [ceil(box_x), ceil(box_y), floor(width_x), floor(height_y)];
end

