function segment_histo(cesta,cesta_seg)
tic
info_img=dir([cesta,'\im*.png']);
info_mask=dir([cesta,'\mask*.png']);

thr=cell(1,3);
thr{1}=[1,155];
thr{2}=[155,235];
thr{3}=[235,255];

for ind=1:length(info_img)
    nazev_img=[cesta,'\',info_img(ind).name];
    img=rgb2gray(imread(nazev_img));


    thr{1}=[1,mean2(img)];
    thr{2}=[mean2(img),235];
    img_thr=img;
    okno=40;
    img_thr(img_thr>thr{1}(1) & img_thr<thr{1}(2))=1;
    img_thr(img_thr>thr{3}(1) & img_thr<thr{3}(2))=4;
    img_thr(img_thr>=thr{2}(1) & img_thr<=thr{2}(2))=2;
    i=1;
    while i<=size(img_thr,1)-okno
        j=1;
        while j<=size(img_thr,2)-okno
            loc_std=std2(img(i:i+okno,j:j+okno));
            if loc_std>std2(img)*1.5
               img_thr(i:i+okno,j:j+okno)=3;
            end
            j=j+round(okno/2);
        end
        i=i+round(okno/2);
    end

    img_thr(img_thr>4)=0;
    img_thr=medfilt2(img_thr,[25,25]);

    nazev_new=[cesta_seg,'\',info_mask(ind).name];
    imwrite(img_thr,nazev_new)
end
toc
% [dice_scores] = evaluate_segmentation(cesta, cesta_seg)
end