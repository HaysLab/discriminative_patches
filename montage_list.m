function montage_image = montage_list(scene_match_files, montage_title, montage_width, background_color, montage_dimensions)
%instead of montaging a dir, it will accept a cell array of image paths and
%a cell array of text annotations to put underneath each image.  No
%duplicate checking or stuff like that.


if(~exist('background_color', 'var'))
    background_color = [1 1 1];
end


num_images      = length(scene_match_files);
montage_tiles_x = montage_width;
montage_tiles_y = ceil(num_images / montage_width);

whitespace = 10; %half of the number of pixels of white space to put between everything

tile_width  = 200;
tile_height = 200;

if(~exist('montage_dimensions', 'var'))
    montage_dimensions = [montage_tiles_y * (tile_height+2*whitespace), ...
                          montage_tiles_x * (tile_width +2*whitespace), 3];
    montage_dimensions(1) = montage_dimensions(1) + 20; %extra padding for labels
end

montage_width  = (tile_height+2*whitespace); %this is width of each image in the montage;
montage_height = (tile_width +2*whitespace);
scene_match_imgs = cell(num_images, 1);


for i = 1:num_images
    current_filename = scene_match_files{i};
    if(ischar(current_filename))
        fprintf('current_filename: %s\n', current_filename)      
        current_image = single(imread(current_filename))/255;
    else
        current_image = current_filename;
        if(max(current_image(:)) > 1)
            current_image = current_image ./ 255;
        end
    end

    if(size(current_image,3) < 3)
        current_image = cat(3, current_image, current_image, current_image);
    end

    current_image = preserve_aspect_resize(current_image, [montage_height-2*whitespace montage_width-2*whitespace], 'bilinear');

    padded_image = ones([montage_height montage_width 3]);
    padded_image(:,:,1) = padded_image(:,:,1) * background_color(1);
    padded_image(:,:,2) = padded_image(:,:,2) * background_color(2);
    padded_image(:,:,3) = padded_image(:,:,3) * background_color(3);

    if(size(current_image,3) == 3)
        padded_image(whitespace+1:end-whitespace, whitespace+1:end-whitespace, :) = current_image;
    else
        padded_image(whitespace+1:end-whitespace, whitespace+1:end-whitespace, 1) = current_image;
        padded_image(whitespace+1:end-whitespace, whitespace+1:end-whitespace, 2) = current_image;
        padded_image(whitespace+1:end-whitespace, whitespace+1:end-whitespace, 3) = current_image;
    end

%     figure(1)
%     imshow(padded_image)
%     pause(.01)
    scene_match_imgs{i} = padded_image;
end

montage_image = ones(montage_dimensions);

for i = 1:num_images
    start_x = round(mod((i-1), montage_tiles_x) * montage_width + 1);
    start_y = round((floor((i-1)/montage_tiles_x)) * montage_height + 1);
    end_x = round(start_x + montage_width - 1);
    end_y = round(start_y + montage_height - 1);
%     start_x
%     start_y
%     end_x
%     end_y
%     size(scene_match_imgs{i})
    montage_image( start_y:end_y, start_x:end_x, : ) = scene_match_imgs{i};

end

end