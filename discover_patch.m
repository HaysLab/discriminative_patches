%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This learns the discriminative patch svm in the method from "Unsupervised
% Discovery of Discriminative Patches" Singh et al. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% the inputs should all be structs with .feat and .fidx

function [discrim_patches, model, cur_iteration] = discover_patch(init_patches, prev_patches,...
                                                    discovery_set, val_set,...
                                                    natural_set, natural_val_set,...
                                                    cluster_size, iteration, max_iterations)
try                                                
% patch_globals;
cur_iteration = iteration;
%if the max_iterations have been reached, return empty set
if(iteration >= max_iterations)
    discrim_patches = [];
    model = [];
    return;
end

%if the iteration > 1 and the init_patches are < cluster_size, return empty set
if(iteration > 1 && length(init_patches.fidx) < cluster_size)
    discrim_patches = [];
    model = [];
    return;
end

% train lin svm c = 0.1 on init_patches, natural_set
global X 

X = vertcat(single(init_patches.feat)', single(natural_set.feat)');
Y = vertcat(ones(length(init_patches.fidx),1),-1.*ones(length(natural_set.fidx),1));
% X = single(X);
Y = single(Y);
lambda = 1;%0.1; % TODO: try larger lambda....
opt.cg = 1;
opt.iter_max_Newton = 5000;

% TODO: this should have 12 rounds of hard negative mining??
[w,   b0 ]=primal_svm(1,Y,lambda,opt); 

positives.feat = init_patches.feat; 
round = 0;
false_neg_idx = 1;
while(round < 13 && ~isempty(false_neg_idx))
    %find false negatives
    train_confs = X*w+b0;
    false_neg_idx = find(Y >= 0.0 & train_confs < 0);
    
    %else retrain using just hard negatives and natural set
    if(round > 0)
        fprintf('Training on hard negatives - iteration %d \n',round);
        positives.feat = positives.feat(:,false_neg_idx);
        X = vertcat(single(positives.feat)', single(natural_set.feat)');
        Y = vertcat(ones(size(positives.feat,2),1),-1.*ones(length(natural_set.fidx),1));
        Y = single(Y);
        [w,   b0 ]=primal_svm(1,Y,lambda,opt);     
    end
    round = round+1;
end

clear X
% run svm on val_set, top cluster_size confs > -1 = return_patches
val_set.feat = single(val_set.feat);
confs = val_set.feat'*w+b0;

[sort_confs, conf_idx] = sort(confs,'descend');

top_patch_idx = conf_idx(1:cluster_size);
top_patch_idx = top_patch_idx(sort_confs(1:cluster_size) > -1);

return_patches.feat = val_set.feat(:,top_patch_idx);
return_patches.fidx = val_set.fidx(top_patch_idx);
 
%%%%%% visualization
% for temp = 1:length(init_patches.fidx)
%     figure;
%     imshow(['patch/' init_patches.fidx{temp}(15:end) '.jpg']);
% end
% 
% for temp = 1:length(return_patches.fidx)
%     figure;
%     imshow(['patch/' return_patches.fidx{temp}(15:end) '.jpg']);
% end
%%%%%%

% if return_patches == prev_patches, return init_patches + svm_model
try
    return_patch_same = isequal(return_patches.feat, prev_patches.feat);
catch
    return_patch_same = 0;
end
if(return_patch_same)
    discrim_patches = init_patches;
    model.w = w;
    model.b0 = b0;
    return;
    
% else call discover_patch with the init_patches = return_patches,
% prev_patches = init_patches, and all the training sets reversed
else
    [discrim_patches, model, cur_iteration] = discover_patch(return_patches, init_patches,...
                            val_set, discovery_set,...
                            natural_val_set, natural_set,...
                            cluster_size, iteration+1, max_iterations);    
end
catch e
    disp(e.message);
%     keyboard
end
end