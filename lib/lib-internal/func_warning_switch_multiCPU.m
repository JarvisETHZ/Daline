function func_warning_switch_multiCPU(switch_indicator)
% Set warning off if requested
if switch_indicator 
    % Normal warning off
    warning off
    % warning off for parallel workers
    parfevalOnAll(@warning,0,'off','all');
end