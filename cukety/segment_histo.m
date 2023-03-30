function  segment_histo(path_to_images, path_of_results)

% pth_to_images = '/home/zanetka/Documents/schola/AB2/data/Lecture7_data/public';
list_pth= dir(path_to_images);

%% Make array of images names

allFileNames = {list_pth(:).name};
list_im = [];
for i = 1:size(list_pth, 1)
    if contains(allFileNames{i}, 'im')
        list_im = [list_im; allFileNames{i}];
    end
end

%% Segmentation start

%   means1 = [];
%     means2 = [];
%     means3 = [];
%     means4 = [];
%     means0 = [];
mms = [162.5962  189.7305  190.5025 225.9364];
% mms = [91.6396 121.1967 147.5809 176.5377]
for i = 1:size(list_im,1)
    img = imread([path_to_images, '/',list_im(i,:)]);

    mask_ref = imread([path_to_images, '/', 'mask', list_im(i,3:4), '.png']);
%     figure(1)
%     subplot 221
%     imshow(img)
%     subplot 223
%     imshow(mask_ref.*50)
%     disp('done')

%% means
%     if ~isempty(img(mask_ref == 1))
%         means1 = [means1, mean(img(mask_ref == 1))];
%     end
%     if ~isempty(img(mask_ref == 2))
%         means2 = [means2, mean(img(mask_ref == 2))];
%     end
%     if ~isempty(img(mask_ref == 3))
%         means3 = [means3, mean(img(mask_ref == 3))];
%     end
%     if ~isempty(img(mask_ref == 4))
%         means4 = [means4, mean(img(mask_ref == 4))];
%     end
%     if ~isempty(img(mask_ref == 0))
%         means0 = [means0, mean(img(mask_ref == 0))];
%     end
% 
%     mm0 = mean(means0);
%     mm4 = mean(means4);
%     mm3 = mean(means3);
%     mm2 = mean(means2);
%     mm1 = mean(means1);
%     
    
    %% k means
  %% k means
    he = img;
    numColors = 4;
    L = imsegkmeans(he,numColors);
    B = labeloverlay(he,L);
%     figure(1);    subplot 222;    imshow(B);    title("Labeled Image RGB")

    
    lab_he = rgb2lab(he);

    ab = lab_he(:,:,2:3);
    ab = im2single(ab);
    pixel_labels = imsegkmeans(ab,numColors,NumAttempts=3);
    ab = medfilt2(pixel_labels,[40,40]);

    mask1 = pixel_labels == 2;
    mask2 = pixel_labels == 3;
    mask3 = pixel_labels == 4;
%     mask4 = pixel_labels == 5;
    mask0 = pixel_labels == 1;

    a1 = mean(img(mask1==1));
    a2 = mean(img(mask2==1));
    a3 = mean(img(mask3==1));
%     a4 = mean(img(mask4==1));
    a0 = mean(img(mask0==1));

    da1 = mms - a1;
    da2 = mms - a2;
    da3 = mms - a3;
%     da4 = mms - a4;
    da0 = mms - a0;

    [~, la1] = min(abs(da1));
    [~, la2] = min(abs(da2));
    [~, la3] = min(abs(da3));
%     [~, la4] = min(abs(da4));
    [~, la0] = min(abs(da0));
    
    % mask
    mask_seg = zeros(size(img,1),size(img,2),1);
    mask_seg(mask1) = la1;
    mask_seg(mask2) = la2;
    mask_seg(mask3) = la3;
%     mask_seg(mask4) = la4;
    mask_seg(mask0) = la0;
%        mask_seg(mask1) = la1;


    %% save mask
    if ~isdir(path_of_results)
        mkdir(path_of_results)
    end

%     mask_seg = mmedfilt2(mask_seg, [85 85]);
%     figure(1)
%     subplot 224
%     imshow(mask_seg.*50)
    mask_seg = uint8(mask_seg);
    imwrite(mask_seg,[path_of_results, '/mask', list_im(i,3:end)]);


end


end

