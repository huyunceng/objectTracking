function show_precision(positions, ground_truth, title)
%SHOW_PRECISION
%   Calculates precision for a series of distance thresholds (percentage of
%   frames where the distance to the ground truth is within the threshold).
%   The results are shown in a new figure.
%
%   Accepts positions and ground truth as Nx2 matrices (for N frames), and
%   a title string.
%

%   Jo?o F. Henriques, 2012
%   http://www.isr.uc.pt/~henriques/

	
	max_threshold = 50;  %used for graphs in the paper
	
	
	if size(positions,1) ~= size(ground_truth,1) %~= �ǲ����ں�
		disp('Could not plot precisions, because the number of ground')
		disp('truth frames does not match the number of tracked frames.')
		return
	end
	%%
    target_sz = [ground_truth(:,4), ground_truth(:,3)];
	pos = [ground_truth(:,2), ground_truth(:,1)] + floor(target_sz/2);%��һ֡λ�õ�����ֵ
	%% calculate distances to ground truth over all frames
	distances = sqrt((positions(:,1) - pos(:,1)).^2 + ...
				 	 (positions(:,2) - pos(:,2)).^2);
	distances(isnan(distances)) = []; %�����ľ���Ϊ[]

	%compute precisions
	precisions = zeros(max_threshold, 1);
	for p = 1:max_threshold
		precisions(p) = nnz(distances < p) / numel(distances);%nnz(x):���ؾ���X�еķ���Ԫ�ص���Ŀ;nnz(X)/prod(size(X)):ϡ�������ܶ���
	end
	
	%plot the precisions
	figure( 'Name',['Precisions - ' title])
	plot(precisions, 'k-', 'LineWidth',2)
    grid on
	xlabel('Threshold'), ylabel('Precision')

end
