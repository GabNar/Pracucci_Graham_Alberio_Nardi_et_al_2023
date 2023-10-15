% The residual fluorescence of the Cl bound sensor is posed = 0
% The R_Cl ratio is corrected according to the value of the Rhod6G
% calibration at the time of bleed through
% the rationale being that, in the bleedthough removal we
% scaled the experiment to the R6G ratio measured
% at the time of the bleedtrough measure.

function [Cl,rCl,Kd] = compute_Cl(pH,wavel,g,r,r_template,r_template_full,pka,kd0,isoWl,normalized_bool,R0_corr)

% wavel, r: spectra from calibrations. g = pHspectra
% R0_corr = corrected coeffient
Kd = kd0 .* (1 + 10 .^ (pH - pka ));
% kdplus = kd0 .* (10.^(pH-pka) +1);
% compute Chloride concentration
% September 19, 2019
% Isosbestic point and R0 are computed for each calibration set.
% G/R at the iso point for the actual data is computed by interpolating at the iso point
% the best fit green spectra and the red template
% Compute the G and red fluorescence at the iso point that is not exactly
% at 910 nm. Compute a spline interpolation of the Red Template and of the computed spectra.
Giso = spline(wavel,g,isoWl);

% Computation of the ratio G/R at the isosbestic point (CalIsoPoint)
if normalized_bool
    rCl = Giso;
else
    
    %                 r = r./spline(app.lambdaIn,app.cal.redTmp,isoWl); % 2023 06 11 gab:
    %                               red template has to undergo the same normalization as
    %                             % the measured R spectrum (i.e. normalization
    %                             % at isosbestic point done by the function
    %                             % "normalize to Iso"). This works only if
    %                             "normalized on individual kate spectra" is
    %                             on.
    proj=r/r_template; % Here, instead, we project
    % the red template to our measured R spectrum.
    r_corr=r_template_full'.*proj;
    Riso = spline(wavel',r_corr,isoWl);
    rCl = Giso./Riso;
end

Cl = Kd .* (R0_corr./rCl - 1);
end