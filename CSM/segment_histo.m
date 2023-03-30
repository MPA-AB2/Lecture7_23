function segment_histo(path_to_images, path_of_results)

folder = path_to_images;
images = dir([folder,'/im','*','.png']);
load("net1.mat");
imagesLoaded = cell(size(images));

for k  = 1:length(images)
    imagesLoaded{k} = imread([images(k).folder,'\',images(k).name]);
    
    img = imresize(imagesLoaded{k},[128 128]);
    testSeg = predict(net,img);
    testSeg = imresize(testSeg,[size(imagesLoaded{k},1),size(imagesLoaded{k},2)]);
    maska_out=uint8(zeros(size(imagesLoaded{k},1),size(imagesLoaded{k},2)));

    for i = 1:size(maska_out,1)
        for j=1:size(maska_out,2)
        a=testSeg(i,j,1);
        b=testSeg(i,j,2);
        c=testSeg(i,j,3);
        d=testSeg(i,j,4);
        e=testSeg(i,j,5);
    
        vektor=[a b/7 c d e];
        [~,poz]=max(vektor);
         if poz==1
            maska_out(i,j)=0;
        elseif poz==2
            maska_out(i,j)=1;
        elseif poz==3
            maska_out(i,j)=2;
        elseif poz==4
            maska_out(i,j)=3;
        elseif poz==5
            maska_out(i,j)=4;
         end    
        end
    end
    imwrite(maska_out,append(path_of_results,'\mask',images(k).name(3:4),'.png'))
end

end