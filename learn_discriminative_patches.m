%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Learns the discriminative patches in a dataset, uses method from
% 'Unsupervised Discovery of Mid-Level Patches'
%
% feat_file - name of file containing features and names for all patches,
%           should contain vars 'feat' and 'fidx'
% kmeans_file - name of file containing the kmeans cluster info for all the
%           patches, should contain vars 'centers' and 'cluster_idx_all'
% cluster_number - 
% save_path - location to save assorted files generated in this pipeline
% discovery_set_ratio - amount of the files in the patch_path that should
%                       be part of the discovery set
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%  TODO: make a grid script that calls this function and computes the patches with a list of starting clusters...
% feat_file = 'feat2kmean_ori_8.mat'
% kmeans_file = 'kmeans_result_ori_8.mat'
% save_path = 'debug_results_ori_8/';
% discovery_set_ratio = 0.5;
% min_cluster_size = 3;
function learn_discriminative_patches(feat_file, kmeans_file, cluster_number, save_path, discovery_set_ratio, min_cluster_size)
patch_globals;

load(feat_file);
load(kmeans_file); 
if(~exist(save_path,'dir'))
    mkdir(save_path);
end

%for the range of cluster numbers in cluster_number    
for curC = cluster_number
    cur_cluster_idx = find(I == curC);
    if(length(cur_cluster_idx) < min_cluster_size)
        fprintf('Cluster %d had too few members.\n',curC);
        return;
    end
    
    
    not_cur_cluster_idx = find(I ~= curC);
    ridx = randperm(length(not_cur_cluster_idx));
    ridx = not_cur_cluster_idx(ridx);
    feat_rand = feat(:,ridx);
    fidx_rand = fidx(ridx);
    discovery_set_size = floor(length(fidx_rand)*discovery_set_ratio);
    natural_set_size = length(fidx_rand)-discovery_set_size;

    set.feat = [feat_rand(:,1:floor(discovery_set_size/2)) feat(:,cur_cluster_idx)];
    set.fidx = [fidx_rand(1:floor(discovery_set_size/2)) fidx(1,cur_cluster_idx)];
    discovery{1} = set;
    set.feat = feat_rand(:,floor(discovery_set_size/2)+1:discovery_set_size);
    set.fidx = fidx_rand(floor(discovery_set_size/2)+1:discovery_set_size);
    discovery{2} = set;
    set.feat = feat_rand(:,discovery_set_size+1:discovery_set_size+floor(natural_set_size/2));
    set.fidx = fidx_rand(discovery_set_size+1:discovery_set_size+floor(natural_set_size/2));
    naturalworld{1} = set;
    set.feat = feat_rand(:,discovery_set_size+floor(natural_set_size/2)+1:end);
    set.fidx = fidx_rand(discovery_set_size+floor(natural_set_size/2)+1:end);
    naturalworld{2} = set;

    I_rand = I(ridx);

    cluster_features{1} = discovery{1}.feat;
    cluster_features{2} = discovery{2}.feat;
    cluster_feat_idx{1} = discovery{1}.fidx;
    cluster_feat_idx{2} = discovery{2}.fidx;
    cluster_idx{1} = [I_rand(1:floor(discovery_set_size/2)) I(cur_cluster_idx)];
    cluster_idx{2} = I_rand(floor(discovery_set_size/2)+1:discovery_set_size);

    fprintf('Trying to learn discriminitive patch from cluster %d...\n', curC);
    init_patches.feat = feat(:,cur_cluster_idx);
    init_patches.fidx = fidx(1,cur_cluster_idx);
    prev_patches = [];
    discovery_set = discovery{1};
  
    val_set = discovery{2};
    natural_set = naturalworld{1};
    natural_val_set = naturalworld{2};
    max_iterations = 15;
    iteration = 1;
    % find what discriminitive patch can be learned from this initial cluster
    [discrim_patches, model, cur_iteration] = discover_patch(init_patches, prev_patches,...
                                                discovery_set, val_set,...
                                                natural_set, natural_val_set,...
                                                min_cluster_size, iteration, max_iterations);

    % if a discrim. patch is learned, save the svm model and final cluster 
    if(~isempty(discrim_patches))
        fprintf('Learned a new model from cluster %d !!!!\n', curC);
        discrim_patch_fname = fullfile(save_path, sprintf('discrim_patch_%d.mat',curC));
        save(discrim_patch_fname,'discrim_patches','model','cur_iteration');

        for i = 1 : length(discrim_patches.fidx)

            fidxi = discrim_patches.fidx{i};

            s = regexp(fidxi, '_', 'split');
            px = str2num(s{1});
            py = str2num(s{2});
            tx = floor(px / 256 / 16);
            ty = floor(py / 256 / 16);
            ori = s{3};
            source{i} = sprintf('%s/%03d_%03d/%05d_%05d_%s.jpg', 'patch', tx, ty, px, py, ori);
%                 figure
%                 imshow(source);

        end
        montage_image = montage_list(source, sprintf('Model learned from cluster %d ', curC), floor(length(discrim_patches.fidx)/2));
        imwrite(montage_image, fullfile(save_path, sprintf('discrim_patch_%d_montage.png',curC)), 'PNG');
    end


end


end