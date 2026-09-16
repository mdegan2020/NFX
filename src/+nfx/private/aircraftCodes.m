function [identifierValid,modeValid,sourceValid,spot,typeValid] = aircraftCodes(identifier,mode,source,radar,optical) %#codegen
    %aircraftCodes - Check the pinned Appendix E Table E-6a sensor registry
    identifier = strtrim(char(identifier));
    indexed = numel(identifier) == 6 && any(strcmp(identifier(1:3),{'GEO','GIR'})) && ...
        all(identifier(4:6) >= '0' & identifier(4:6) <= '9');
    identifierValid = indexed || any(strcmp(identifier, ...
        {'AG3607','AIP','ALIRT','ANAPY8','APG-73','ASARS1','ASARS2','BUCKEY', ...
        'CA236','CA260','CA261','CA265','CA270','CA279H','CA279M','CA295','CH1E0', ...
        'D500','DB110','DLTV','DPY-1','DSS301','DSS322','DSS439','DS-SAR','EO Nos','EO Spo','EO Zoo', ...
        'FOP','FSBS2','GEOMOS','GHR','GIRMOS','GR-M80','HALOE','HSAR','HYCAS','HYDICE', ...
        'IR Amb','IR M50','IR M60','IRLS','JAUDIT','JSE8CA','LAEO','LIDAR','LiMIT','MAEO', ...
        'MBSAR','MPRTIP','MX20EN','MX20EW','MX20IR','OBC','PKSAR','RADEOS','RTNESS','SHARP', ...
        'SIR-C','SPMWIR','SPSWIR','SPVIS','SPVNIR','SYERS','SYERS2','TARSAR','TMAEO','TSAR'}));
    radarIds = {'AIP','ANAPY8','APG-73','ASARS1','ASARS2','DPY-1','DS-SAR', ...
        'FOP','GHR','HSAR','JSE8CA','LiMIT','MBSAR','MPRTIP','PKSAR','SHARP','SIR-C','TARSAR','TSAR'};
    lidarIds = {'ALIRT','BUCKEY','HALOE','JAUDIT','LIDAR'};
    if strcmp(identifier,'RTNESS')
        typeValid = (radar && any(mode == [1 3 14 27 29:32])) || ...
            (optical && any(mode == [4:9 11 12 21 22]));
    elseif any(strcmp(identifier,radarIds))
        typeValid = radar;
    elseif any(strcmp(identifier,lidarIds))
        typeValid = ~radar && ~optical;
    else
        typeValid = optical;
    end
    modes = zeros(1,0);
    spots = zeros(1,0);
    switch identifier
        case 'AIP', modes = 13:20; spots = [18 20];
        case {'ANAPY8','DPY-1'}, modes = 1:6; spots = 1:3;
        case 'ASARS2', modes = [1 2 4 7:13]; spots = [2 4 7 8 11];
        case 'APG-73', modes = [1 2]; spots = 2;
        case {'CA279H','CA279M'}, modes = [7 8 17 18 24:28];
        case 'DB110', modes = [7:12 17 18 99];
        case {'DSS301','DSS322','DSS439'}, modes = [7 17];
        case 'GR-M80', modes = 1:4;
        case 'JSE8CA', modes = [1:12 19]; spots = 1:9;
        case 'MBSAR', modes = 1:4; spots = [2 4];
        case 'MPRTIP', modes = [51:54 57:60 62:65 67:69 71]; spots = [51:54 57:60 62:65];
        case 'PKSAR', modes = [11 12 20 22 30 32]; spots = [20 22 32];
        case 'RTNESS', modes = [1 3:9 11 12 14 21 22 27 29:32]; spots = [1 14 27 32];
        case {'SHARP','TARSAR'}, modes = [11 12 21 22 31 32 41 42 51 52]; spots = [11 12 21 22];
        case 'SYERS2', modes = [10 20 30 40 50 70 80:83 90:93 100:103 120 999];
        otherwise
            if indexed
                modes = [1 101];
            elseif optical
                modes = [4:6 14:16 24:26 34:36];
            end
    end
    % The published table leaves other SAR and LiDAR modes TBD. Do not
    % silently accept an unverified registration in those gaps.
    modeValid = any(mode == modes);
    spot = radar && any(mode == spots);
    sourceValid = isnan(source) || source == 0;
    switch identifier
        case 'ASARS2', sourceValid = sourceValid || any(source == [1 2 3 5 6]);
        case {'CA279H','CA279M'}, sourceValid = sourceValid || source == 2;
        case 'DB110', sourceValid = sourceValid || any(source == [1 2 3]);
        case 'JSE8CA', sourceValid = sourceValid || source == 1;
    end
end
