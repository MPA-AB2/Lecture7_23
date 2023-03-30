function [im_vys] = oriz(image,imageSize)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
vel = size(image);
if (vel(1:2) ~= imageSize(1:2))
    if (length(vel)==2)
        im_vys = imresize(image,imageSize(1:2));
    else
    imager = im2gray(image(:,:,1));
    imageg = im2gray(image(:,:,2));
    imageb = im2gray(image(:,:,3));
    
    im_b = imresize(imageb, imageSize(1:2));
    im_r = imresize(imager, imageSize(1:2));
    im_g = imresize(imageg, imageSize(1:2));
    
    im_vys = cat(3, im_r,im_g,im_b);
    end
else
    im_vys = image;
end

end
