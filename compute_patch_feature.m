function compute_patch_feature(base_path, dir_name)
%base_path = '/data/hays_lab/finder/Discriminative_Patch_Discovery/AerialPatch'
%dir_name = '015_004'
	% setup input and output dir
	input_dir = sprintf('%s/patch/%s', base_path, dir_name);
	flist = dir(input_dir );
	flist = flist(3:end);
	output_dir = sprintf('%s/patch_feature/%s', base_path, dir_name);
	if ~isempty(flist)
		mkdir(output_dir );
	end
	% setup conf
	conf.interval = 16;
	size(flist)
	for i = 1 : length(flist)
		fname =  flist(i).name;
		if ~exist(sprintf('%s/%s.mat', output_dir, fname(1:end-4)), 'file')
			input_image = im2double(imread(sprintf('%s/%s', input_dir, fname) ) );
			[feat boxes] = hog2x2(conf, input_image);
			save(sprintf('%s/%s.mat', output_dir, fname(1:end-4)), 'feat' );
		end
	end
	
end
