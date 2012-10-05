function [f, idx] = packf(folder_name, ORI)
	f = [];
	idx = [];

	flist = dir(folder_name);
	flist = flist(3:end);
	len = length(flist)
	% code here is subjected to change if we decide not to use rot inv feature
	if ORI == 0
		len = len / 8;
	end
	
	% load feature
	f = uint8(zeros(496, len));
	cnt = 1;
	for i = 1 : length(flist)
		fname = flist(i).name
		if ORI == 0 & ~strcmp(fname(end-6:end-4), '000')
			continue;
		end
		hog = load(sprintf('%s/%s', folder_name, fname) );
		f(:, cnt) = hog.feat.descrs(:);
		idx{cnt} = fname(1:end-4);
		cnt = cnt + 1;
	end
end
