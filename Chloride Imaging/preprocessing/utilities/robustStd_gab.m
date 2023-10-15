function sd_r = robustStd_gab(mat)
%ROBUSTSTD Compute a robust estimate of the std of the baseline activity
% in calcium imaging traces
%   --Input
%       mat: matrix of neuronal activity, in the form of pixels*time


% compute and subtract the mode
% md = max(mode_robust_gab(mat),0);
md = mode_robust_gab(mat');
ff1 = mat-md';

% only consider values under the mode to determine the noise standard deviation
ff1 = -ff1 .* (ff1 < 0);

% compute 25 percentile
ff1 = sort(ff1, 2);
ff1(ff1 == 0) = nan;
% iqr_h is half the interquartile range, (i.e. the 25th percentile when the
% mean is = 0
iqr_h = median(ff1,2,'omitnan'); %Gab
% approximate standard deviation as iqr/1.349
sd_r = 2 * iqr_h / 1.349;
end