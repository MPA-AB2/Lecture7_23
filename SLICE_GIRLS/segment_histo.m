function [] = segment_histo(pathToImages, pathOfResults)

% Find files in dir
images = dir([pathToImages, 'im*.png']);
masks = dir([pathToImages, 'mask*.png']);
numFiles = length(images);

for i = 1:numFiles
    % Read files and prealocate output mask
    image = imread([pathToImages, images(i).name]);
    mask = imread([pathToImages, masks(i).name]);
    maskSeg = uint8(zeros(size(mask)));
    
    maskTumor = zeros(size(mask));
    maskNecro = zeros(size(mask));
    maskStroma = zeros(size(mask));
    
%     % Colorcode map
%     mR = mask == 1 | mask == 4;
%     mG = mask == 2 | mask == 4;
%     mB = mask == 3 | mask == 4;
%     maskRGB = double(cat(3,mR,mG,mB));
%     
%     % Show input
%     figure(1), sgtitle(['Image: ', num2str(i)])
%     subplot 131, imshow(image)
%     subplot 132, imshow(maskRGB)
    
    % Segmentation
%     numColors = 5;
%     L = imsegkmeans(image,numColors);
%     B = labeloverlay(image,L);
%     
%     labImage = rgb2lab(image);
    
    %% Segment fat
    grayImage = im2double(rgb2gray(image));
    grayImageG = imgaussfilt(grayImage,2);
    
    maskFat = imbinarize(grayImageG, 0.9);
    maskFat = bwareaopen(maskFat, 3000);
    maskFat = imfill(maskFat,'holes');
    
%     windowSize = 11;
%     kernel = ones(windowSize) / windowSize ^ 2;
%     blurryImage = conv2(single(fat), kernel, 'same');
%     fat = blurryImage > 0.5;

    %% Detect necrosis
    minRadius = 6;
    maxRadius = 11;
    [centersDark, radiiDark] = imfindcircles(image,[minRadius, maxRadius],'ObjectPolarity','dark');

    % show circles
%     subplot 131
%     viscircles(centersDark, radiiDark,'Color','b');

    %% Segment cells
    % Determine number of colors
%     numColors = 2;
%     
%     if size(centersDark,1) > 15
%         numColors = numColors + 1;
%     elseif sum(sum(maskFat)) > 1
%         numColors = numColors + 1;
%     end
% %     L = imsegkmeans(image,numColors);
% %     B = labeloverlay(image,L);
%     
%     labImage = rgb2lab(image);
% 
%     ab = labImage(:,:,2:3);
%     ab = im2single(ab);
%     pixel_labels = imsegkmeans(ab,numColors,'NumAttempts',3);
%     B = labeloverlay(image,pixel_labels);

    %
%     subplot 133, imshow(B)

    %% Feature maps
%     edgeImage = edge(grayImage,'Sobel');
    gradImage = imgradient(grayImage,'Sobel');
%     filtImage = medfilt2(gradImage,[25 25],'symmetric');
    filtImage = imgaussfilt(gradImage, 4);
    thres = graythresh(filtImage);
%     thres = graythresh(gradImage)
    
%     figure(2);
%     subplot 121, imshow(edgeImage)
%     subplot 122, imshow(gradImage)
    
    %% Segmentation
    [rows, cols] = size(mask);
    range = 35;
    
    for row = 3:5:rows-2
        for col = 3:5:cols-2
         
            % Fat
            if maskFat(row,col)
                continue
            end

            % Necrosis
            rowU = max([1, row-range]);
            rowD = min([row+range, rows]);
            colU = max([1, col-range]);
            colD = min([col+range, cols]);
            
            centNum = size(centersDark,1);
            centVec = zeros(1,centNum);
            for cent = 1:centNum
                if (centersDark(cent,2) > rowU) && (centersDark(cent,2) < rowD) && (centersDark(cent,1) > colU) && (centersDark(cent,1) < colD)
                    centVec(cent) = 1;
                end
            end
            if sum(centVec)>1
                maskNecro(row-2:row+2,col-2:col+2) = 1;
                continue
            end
            
            % Tumor and stroma
%             meanGrad = mean(gradImage(rowU:rowD,colU:colD),'all');
            
            if mean(filtImage(row-2:row+2,col-2:col+2),'all') > thres % 0.27
                maskTumor(row-2:row+2,col-2:col+2) = 1;
            else
                maskStroma(row-2:row+2,col-2:col+2) = 1;
            end

        end
    end
    
    %% Adjust and combine results
    % Open necrosis region
    if sum(maskNecro,'all') > 7500
        maskNecro = imdilate(maskNecro, strel('disk', 75));
    else
        maskNecro(:,:) = 0;
    end
    
    % Filter tumor
%     maskTumor = imclose(maskTumor, strel('disk', 11));
    maskTumor = bwareaopen(maskTumor, 3000);
    maskTumor = imfill(maskTumor, 'holes');
    maskTumor = imclose(maskTumor, strel('disk', 17));
    maskTumor = bwareaopen(~maskTumor, 2500);
    maskTumor = ~maskTumor;
    
%     maskTumor = imopen(maskTumor, strel('disk', 11));
%     maskTumor = bwareaopen(maskTumor, 2000);
%     maskTumor = imfill(maskTumor, 'holes');
    
    maskSeg(:,:) = 2;
    maskSeg(logical(maskTumor)) = 1;
    maskSeg(logical(maskFat)) = 4;
    maskSeg(logical(maskNecro)) = 3;
    maskSeg = reshape(maskSeg, rows,cols);
    
    % Filter results
%     maskSeg = medfilt2(maskSeg,[7 7]);
    
    %% Show segmentation
%     mR = maskSeg == 1 | maskSeg == 4;
%     mG = maskSeg == 2 | maskSeg == 4;
%     mB = maskSeg == 3 | maskSeg == 4;
%     maskRGB = double(cat(3,mR,mG,mB));
%     
%     % Show input
%     figure(1)
%     subplot 133, imshow(maskRGB)  
    
    %% Save results
    imwrite(maskSeg,[pathOfResults, masks(i).name])
    
%     pause;
end


end