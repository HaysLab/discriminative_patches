% TODO: maybe make a parallelizable version of this for packing large
% files?

function [f, idx] = packfiles(flist, ORI)
	f = [];
	idx = [];
    
	len = length(flist);
    
    fprintf('Packing %d files...\n',len);
	% code here is subjected to change if we decide not to use rot inv feature
	if ORI == 0
		len = len / 8;
	end
	
	% load feature
    % TODO: change f to load feature of any size
	f = uint8(zeros(496, len));
	cnt = 1;
	for i = 1 : length(flist)
		fname = flist{i};
		if ORI == 0 & ~strcmp(fname(end-6:end-4), '000')
			continue;
		end
		hog = load(fname);
		f(:, cnt) = hog.feat.descrs(:);
		idx{cnt} = fname(1:end-4);
		cnt = cnt + 1;
    end
%     keyboard
end