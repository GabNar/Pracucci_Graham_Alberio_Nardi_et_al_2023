function [normG,normR] = normalizeToIso(greenCh, redCh, lambda, iso)
%UNTITLED This function computes the spline interpolation of the red channel
%at the isosbestic point specifed by iso. Then normalizes redCh and greenCh
%to this value

% 1) Find the value of the Red spectra at the isosbestic wavelength
Riso = spline (lambda,redCh,iso);

% 2) Normalize the red spectra so that it is = 1 at the isosbestic
% wavelength

normR = redCh./Riso;
ck = spline (lambda',normR,iso);

% 3) Normalize the the green spectra with the same factor
normG = greenCh ./ Riso;



end

