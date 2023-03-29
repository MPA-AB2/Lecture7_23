function [dice_scores] = evaluate_segmentation(gt_path, segmented_path)
gt_mask_names = dir([gt_path '\mask*.png']);
dice_scores.details = [];
images_names = {};
values = [0,1,2,3,4];
catnames = {'background', 'tumour', 'stroma', 'necrosis', 'fat'};
for num_mask = 1:length(gt_mask_names)
    images_names{num_mask} = gt_mask_names(num_mask).name(end-5:end-4);
    gt = categorical(imread([gt_path '\' gt_mask_names(num_mask).name]), values, catnames);
    segmented = categorical(imread([segmented_path '\' gt_mask_names(num_mask).name]), values, catnames);
    dice_scores.details(1:5,num_mask) = dice(segmented,gt);
end
dice_scores.mean_dice = nanmean(dice_scores.details(:));
dice_scores.std_dice = nanstd(dice_scores.details(:));
dice_scores.mean_dice_categories = table(catnames',nanmean(dice_scores.details')','VariableNames',{'Category','MeanDice'});
dice_scores.mean_dice_images = table(images_names',nanmean(dice_scores.details)','VariableNames',{'ImageNumber','MeanDice'});
end