%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This method performs kmeans on the patches in the input directory.
% The packed 
%
% features = matrix where every column is the feature vector of a patch
%
% cluster_membership_idx = the cluster index of the patch with
% corresponding feature vector in the features matrix column of the same
% column index
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% patch_patch = '/gpfs/data/hays_lab/finder/Discriminative_Patch_Discovery/AerialPatch/patch_feature/';
% patch_path = './patch_feature/';
% save_path = './';
% in orig. paper min_cluster_size = 3
% NOTE TO Tsung-Yi : If you just point this at the feature mat file that has
% patches at multiple orientations, it will cluster them. I don't have a
% special variable that knows that the patches are at different
% orientations. 
function [features, feat_idx, cluster_idx] = kmeans_patch(save_path, fname, min_cluster_size)
    patch_globals;
    
    disp('load feature and idx')
    load(fname);
    feat = set.feat;
    fidx = set.fidx;


    % kmeans
    kmeans_fname = fullfile(save_path,'kmeans_result.mat');
    if(~exist(save_path,'dir'))
        mkdir(save_path);
    end
    
    len = size(feat, 2);
    disp('kmeans start....')
    tic
    K = round(len/4);
    if(~exist(kmeans_fname, 'file'))

        %[centers, cluster_idx_all] = vl_ikmeans(feat, K);
        [C, I] = vl_ikmeans(feat, K);
        % NOTE to Tsung-yi : this heirarchical kmeans might be faster, but
        % it's not working yet. 
%         nleaves = 2*K; % i don't know if this is right...
%         [tree, asgn] = vl_hikmeans(feat,K,nleaves,'method', 'elkan');
        

        save(kmeans_fname, 'C', 'I');
    else
        load(kmeans_fname);
    end
    toc
    
    % remove all clusters with less than min_cluster_size members    
    num_occ = histc(I, 1:K);
    too_small_clusters = find(num_occ <  min_cluster_size);
    cluster_idx = I(~ismember(I,too_small_clusters));
    features = feat(:,~ismember(I,too_small_clusters));
    feat_idx = fidx(~ismember(I,too_small_clusters));

end