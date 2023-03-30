imageDir = "V:\MPA-AB2\Lecture7_23\trainData\Image";
labelDir = "V:\MPA-AB2\Lecture7_23\trainData\Mask";

imds = imageDatastore(imageDir);
classNames = ["background","tumour","stroma","necrosis","fat"];
labelIDs   = [0 1 2 3 4];
pxds = pixelLabelDatastore(labelDir,classNames,labelIDs);

lgraph = unetLayers([192 192],5,"EncoderDepth",4);

ds = combine(imds,pxds);

options = trainingOptions('adam', ...
    'InitialLearnRate',1e-3, ...
    'MaxEpochs',20, ...
    'VerboseFrequency',10);

net = trainNetwork(ds,lgraph,options);