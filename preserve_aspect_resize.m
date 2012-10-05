function output_image = preserve_aspect_resize(input_image, dimensions, method, bg_color)
%resizes an image but preserves its aspect ratio with white padding, if
%necessary.

if(~exist('method', 'var'))
    method = 'bilinear';
end

if(~exist('bg_color', 'var'))
    bg_color = [1 1 1];
end

if(size(dimensions,1) < 3)
    dimensions(3) = size(input_image,3);
end

output_image = ones(dimensions);
output_image(:,:,1) = output_image(:,:,1) * bg_color(1);
output_image(:,:,2) = output_image(:,:,2) * bg_color(2);
output_image(:,:,3) = output_image(:,:,3) * bg_color(3);
        
current_aspect_ratio = size(input_image, 2) / size(input_image,1);
target_aspect_ratio  = dimensions(2) / dimensions(1);

if( current_aspect_ratio > target_aspect_ratio) %this means width is the limiter
    resize_ratio = dimensions(2) / size(input_image, 2);
    %input_image = fast_resize(input_image, [round(size(input_image,1)*resize_ratio) dimensions(2)], method);
    input_image = imresize(input_image, [round(size(input_image,1)*resize_ratio) dimensions(2)], method);
    
    vert_gap = dimensions(1) - size(input_image,1);
%     size(output_image(floor(vert_gap/2) + 1:end-ceil(vert_gap/2),:,:))
%     size(input_image)
    output_image(floor(vert_gap/2) + 1:end-ceil(vert_gap/2),:,:) = input_image;
    
else %this means height is the limiter (or they're equal)
    resize_ratio = dimensions(1) / size(input_image, 1);
    %input_image = fast_resize(input_image, [dimensions(1) round(size(input_image,2)*resize_ratio)], method);
    input_image = imresize(input_image, [dimensions(1) round(size(input_image,2)*resize_ratio)], method);
    
    hor_gap = dimensions(2) - size(input_image,2);
%     size(input_image)
%     size(output_image(:,floor(hor_gap/2) + 1:end-ceil(hor_gap/2),:))
    output_image(:,floor(hor_gap/2) + 1:end-ceil(hor_gap/2),:) = input_image;
end

