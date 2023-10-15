function [X,f] = myPsd(x,fs)
X = fft(x)./size(x,1);
X = X(1:round(length(X)./2),:);
X(2:end,:) = 2.*X(2:end,:);

f = (0:length(X)-1) ./ (size(x,1)/fs);

