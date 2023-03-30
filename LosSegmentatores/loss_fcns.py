# import numpy
import torch
import torch.nn as nn
import torch.nn.functional as F

class CrossEntropyDiceLoss(nn.Module):
    def __init__(self,weights = [0.5,0.5],classWeights = [1.0,1.0]):
        super(CrossEntropyDiceLoss,self).__init__()
        CrossEntropyDiceLoss.CE = torch.nn.CrossEntropyLoss(weight = torch.Tensor(classWeights).to("cuda"))
        CrossEntropyDiceLoss.Dice = DiceLoss(weights=classWeights)
        CrossEntropyDiceLoss.weights = weights
        # CrossEntropyDiceLoss.eps = eps
    def forward(self,pred,lbl):
        
        CrossEnt = CrossEntropyDiceLoss.CE(pred,lbl)
        Dice = CrossEntropyDiceLoss.Dice(pred,lbl)
        # pred = torch.softmax(pred,dim=1)
        # lbl_extend=lbl.clone()
        # lbl_extend.unsqueeze_(1)
        # one_hot = torch.cuda.FloatTensor(lbl_extend.size(0), 2, lbl_extend.size(2), lbl_extend.size(3),lbl_extend.size(4)).zero_()
        # one_hot.scatter_(1, lbl_extend, 1) 
        # inter = torch.dot(pred.reshape(-1).float(), one_hot.reshape(-1).float())
        # Dice = 1 - ((2*inter+CrossEntropyDiceLoss.eps)/(pred.sum()+one_hot.sum()+CrossEntropyDiceLoss.eps))
        return self.weights[0] * CrossEnt + self.weights[1] *  Dice

class DiceLoss(nn.Module):
    def __init__(self, weights = [1.0,1.0,1.0,1.0,1.0]):
        super(DiceLoss, self).__init__()
        #self.requires_grad = True
        self.weights = weights
    def forward(self, pred, lbl):
        
        #softmax activation layer      
        pred = torch.softmax(pred,dim=1)

        # one hot encoding
        lbl_extend=lbl.clone()
        #lbl_extend.unsqueeze_(1) 
        one_hot = torch.cuda.FloatTensor(lbl_extend.size(0), 5, lbl_extend.size(2), lbl_extend.size(3)).zero_()
        #print(one_hot.shape)
        #print(lbl_extend.shape)
        one_hot.scatter_(1, lbl_extend, 1)
        
        #flatten label and prediction tensors
        TotalDice = 0.0
        for i in range(one_hot.shape[1]):
            predT = pred[:,i].contiguous().view(pred.shape[0],-1)
            one_hotT = one_hot[:,i].contiguous().view(one_hot.shape[0],-1)
            num = 2 * torch.mul(predT,one_hotT).sum(dim = 1) + 1e-9
            den = predT.pow(2).sum(dim=1) + one_hotT.pow(2).sum(dim=1) + 1e-9
                                       
            Dice = self.weights[i] * (1 - num/den)
            TotalDice += Dice.mean()
        
        return TotalDice/one_hot.shape[1]

class DiceBCELoss(nn.Module):
    def __init__(self, weight=None, size_average=True):
        super(DiceBCELoss, self).__init__()

    def forward(self, inputs, targets, smooth=1):
        
        #comment out if your model contains a sigmoid or equivalent activation layer
        # inputs = F.sigmoid(inputs)       
        
        #flatten label and prediction tensors
        inputs = inputs.view(-1)
        targets = targets.view(-1)
        
        intersection = (inputs * targets).sum()                            
        dice_loss = 1 - (2.*intersection + smooth)/(inputs.sum() + targets.sum() + smooth)  
        BCE = F.binary_cross_entropy(inputs, targets, reduction='mean')
        Dice_BCE = BCE + dice_loss
        
        return Dice_BCE



class TverskyLoss(nn.Module):
    def __init__(self, weight=None, size_average=True):
        super(TverskyLoss, self).__init__()

    def forward(self, inputs, targets, smooth=1e-5, alpha=0.5, beta=0.5):
        
        #comment out if your model contains a sigmoid or equivalent activation layer
        inputs = torch.softmax(inputs,dim = 1)

        # one hot encoding
        targets_extend=targets.clone()
        targets_extend.unsqueeze_(1) 
        one_hot = torch.cuda.FloatTensor(targets_extend.size(0), 2, targets_extend.size(2), targets_extend.size(3),targets_extend.size(4)).zero_()
        one_hot.scatter_(1, targets_extend, 1)       
        
        dims = (1, 2, 3, 4)
        intersection = torch.sum(inputs * one_hot, dims)
        fps = torch.sum(inputs * (-one_hot + 1.0), dims)
        fns = torch.sum((-inputs + 1.0) * one_hot, dims)

        numerator = intersection
        denominator = intersection + alpha * fps + beta * fns
        tversky_loss = numerator / (denominator + smooth)

        return torch.mean(-tversky_loss + 1.0)

# pred = torch.randn(4,2,64,75,62)    
# lbl = torch.randint(0,2,(4,64,75,62))
# pred_extend=lbl.clone()
# pred_extend.unsqueeze_(1) 
# pred = torch.FloatTensor(pred_extend.size(0), 2, pred_extend.size(2), pred_extend.size(3),pred_extend.size(4)).zero_()
# pred.scatter_(1, pred_extend, 1)

# loss = DiceLoss()
# DL = loss(pred,lbl)
