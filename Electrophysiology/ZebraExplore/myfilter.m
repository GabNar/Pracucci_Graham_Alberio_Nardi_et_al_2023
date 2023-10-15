function filtered=myfilter(x,bp,sf,varargin)

% MYFILTER apply butterworth filter with given characteristic frequencies
% INPUTS: -x: vector, 2D matrix. Data to be parsed into trials. If x is a
%               matrix, each column is a channel.
%         -bp: 2-element vector. Bandpass upper and lower bounds (Hz)
%         -sf: scalar. Sampling frequency (Hz)
%         -order: (optional): filter order. Default is 3.


% arguments parsing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p = inputParser;
addRequired(p,'x',@(x)(isnumeric(x)&&length(size(x))==2))
addRequired(p,'bp',@(x)(isnumeric(x)&&length(x)==2))
addRequired(p,'sf',@(x)(isnumeric(x)&&isscalar(x)))
addOptional(p,'order',3,@(x)(isnumeric(x)&&isscalar(x)))
parse(p,x,bp,sf,varargin{:})
fnames=fields(p.Results);
for i=1:numel(fnames)
    eval(sprintf('%s=p.Results.%s;',fnames{i},fnames{i}))
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if bp(1) == 0 % lower bound = 0 means low-pass
    [z,p,k] = butter(order,2*bp(2)/sf,'low');  %low pass filter
elseif bp(2) == Inf % upper bound = inf means high-pass
    [z,p,k] = butter(order,2*bp(1)/sf, 'high');% high pass and single units
else % band-pass
    [z,p,k] = butter(order,2*bp/sf);
end
[sos,g]=zp2sos(z,p,k);
filtered=filtfilt(sos,g,x);
end

