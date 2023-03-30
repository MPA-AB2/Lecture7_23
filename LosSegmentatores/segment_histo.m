function segment_histo(path_to_images, path_of_results)
filesInfo = dir([path_to_images '\im*.png']);    
files = {filesInfo.name};
net = importONNXNetwork("histSegUNet.onnx");

for i = 1:length(files)
    im = im2gray(im2double(imread(fullfile(path_to_images,files{i}))));
    
    [nr, nc] = size(im);
    w = 200;
    if nr < 600
        xnr = 3;
    elseif nr > 600 && nr < 800
        xnr = 4;
    elseif nr > 800 && nr < 1000
        xnr = 5;
    end
    if nc < 600
        xnc = 3;
    elseif nc > 600 && nc < 800
        xnc = 4;
    elseif nc > 800 && nc < 1000
        xnc = 5;
    end
    x = [];
    y = [];
    x(1) = 1;
    y(1) = 1;
    x(xnr) = nr-w;
    y(xnc) = nc-w;
    difnr = nr-2*w;
    difnc = nc-2*w;
    halfr = floor(difnr/(xnr-2));
    halfc = floor(difnc/(xnc-2));
    for j = 1:xnr-2
        x(j+1) = (halfr*(j)+w+5)-w;
    end
    for j = 1:xnc-2
        y(j+1) = (halfc*(j)+w+5)-w;
    end

    finalMask = uint8(zeros(nr,nc));
    for j = 1:length(x)
        for k = 1:length(y)
            seg = predict(net,im(x(j):x(j)+199,y(k):y(k)+199));
            seg = dlarray(seg,"SSC");
            seg = softmax(seg);
            seg = extractdata(seg);
            [~,seg] = max(seg,[],3);
            finalMask(x(j):x(j)+199,y(k):y(k)+199) = uint8(seg - 1);

        end
    end

    imwrite(finalMask,[path_of_results '\mask' files{i}((end-5):end)]);
end
end

