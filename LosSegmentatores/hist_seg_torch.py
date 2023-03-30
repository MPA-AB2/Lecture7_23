

import torch
# import torchvision
# import matplotlib.pyplot as plt
# import numpy as np
import torchio as tio
from loaders import HIST_Dataset
from unet import UNet
from loss_fcns import DiceLoss
import torchmetrics

# device for pytorch
device = "cuda" if torch.cuda.is_available() else "cpu"
print(f"Using {device} device")

# get dataset

tr_ds = HIST_Dataset(
    imgPath='/storage/brno3-cerit/home/xnantl01/AB2_L7/public/imagesTr',
    lblPath='/storage/brno3-cerit/home/xnantl01/AB2_L7/public/labelsTr',
    transform = tio.Compose([
            tio.RandomAffine(scales = (0.8, 1.2),degrees = (-30, 30),isotropic = True,p = 0.2),
            tio.RandomNoise(mean = 0,std = 0.01,p = 0.15,exclude = ['a_segmentation']),
            tio.RandomGamma(log_gamma = (0.8, 1.2),p = 0.15,exclude = ['a_segmentation']),
            tio.RandomFlip(axes = (0,1,2),flip_probability = 0.5)])
    )
    
tr_ds_dl = torch.utils.data.DataLoader(tr_ds,batch_size=1,shuffle=False)

val_ds = HIST_Dataset(
    imgPath='/storage/brno3-cerit/home/xnantl01/AB2_L7/public/imagesTs',
    lblPath='/storage/brno3-cerit/home/xnantl01/AB2_L7/public/labelsTs'
    )
val_ds_dl = torch.utils.data.DataLoader(val_ds,batch_size=1,shuffle=False)

# U-Net
net = UNet(1,5)
net.to(device)

# training and evaluation
# loss_f = CrossEntropyDiceLoss()
loss_f = DiceLoss()
net.eval()
initLR = 6e-5
opt = torch.optim.Adam(net.parameters(),lr= initLR,weight_decay = 3e-4)
# scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(opt,mode='min')
tr_losses = []
val_losses = []
tr_dices = []
val_dices = []
best_net = []
best_loss = 0
end_epoch = 1001
for epoch in range(1,end_epoch):
    opt.param_groups[0]['lr'] = initLR * (1 - epoch / end_epoch)**0.9
    tr_loss = 0.0
    val_loss = 0.0
    tr_dice = 0.0
    val_dice = 0.0
    acc = 0
    net.train()
    for img,lbl in tr_ds_dl:
        img,lbl = img.to(device),lbl.to(device)
        pred = net(img)
        # pred = torch.softmax(pred)
        loss = loss_f(pred,lbl)
        opt.zero_grad()
        loss.backward()
        opt.step()
        tr_loss+=loss.item()
        tr_dice += torchmetrics.functional.dice(pred,lbl)

    print('All training batches used')
    net.eval()
    with torch.no_grad():
         for img,lbl in val_ds_dl:
             img,lbl = img.to(device),lbl.to(device)
             pred=net(img)
             #pred = torch.sigmoid(pred)
             loss=loss_f(pred,lbl)
             val_loss+=loss.item()
             val_dice += torchmetrics.functional.dice(pred,lbl)

    print('All validation data used')
    tr_loss=tr_loss/len(tr_ds_dl)
    val_loss=val_loss/len(val_ds_dl)
    tr_dice = tr_dice/len(tr_ds_dl)
    val_dice = val_dice/len(val_ds_dl)

    tr_losses.append(tr_loss)
    val_losses.append(val_loss)
    tr_dices.append(tr_dice)
    val_dices.append(val_dice)

    # scheduler.step(ts_loss)

    # if ts_loss<best_loss:
    #   best_net = net
    #   best_loss = ts_loss

    print('Epoch: {}; Train Loss: {:.4f}; Val Loss: {:.4f}; Train Dice coeff: {:.4f}; Val Dice coeff: {:.4f};'.format(epoch,tr_loss,val_loss,tr_dice,val_dice))
    
x = torch.randn(1, 1, 200, 200, requires_grad=True,device=device)
torch_out = net(x)
torch.onnx.export(net,               # model being run
                  x,                         # model input (or a tuple for multiple inputs)
                  "/storage/brno3-cerit/home/xnantl01/AB2_L7/histSegUNet.onnx",   # where to save the model (can be a file or file-like object)
                  export_params=True,        # store the trained parameter weights inside the model file
                  opset_version=10,          # the ONNX version to export the model to
                  do_constant_folding=True,  # whether to execute constant folding for optimization
                  input_names = ['input'],   # the model's input names
                  output_names = ['output']) # the model's output names


#torch.save(net,'/storage/brno3-cerit/home/xnantl01/AB2_L7/histSegUNet.pb')

# plot results
# plt.plot(tr_losses)
# plt.plot(ts_losses)
# plt.legend(['tr_loss','val_loss'])
# plt.title('Loss - COVID dataset')
# plt.show()
# plt.plot(dice_losses)
# plt.legend(['dice_losses'])
# plt.title('Accuracy - COVID dataset')
# plt.show()

# eval 1 image
# trim = torchvision.transforms.Resize((256,256))
# tr = torchvision.transforms.Compose([torchvision.transforms.Grayscale(),torchvision.transforms.Resize((256,256))])

# image = torchvision.io.read_image('./data/COVID-513.png')
# image = image.float()/255
# image = torch.unsqueeze(image,dim = 0)
# label = tr(torchvision.io.read_image('./data/COVID-513_mask.png'))
# label = label.float()/255
# label[np.where(label<0.9)] = 0
# label[np.where(label>=0.9)] = 1

# net.eval()
# prediction = torch.sigmoid(net(image)) > 0.5

# fig, ax = plt.subplots(1, 2)
# ax[0].imshow(prediction[0,0,:,:],cmap = 'gray')
# ax[0].set_title('Prediction')
# ax[1].imshow(label[0,:,:],cmap = 'gray')
# ax[1].set_title('GT mask')
# fig.show()
