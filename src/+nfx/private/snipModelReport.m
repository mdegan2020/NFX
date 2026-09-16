function report = snipModelReport(records,header,fileHeader,des) %#codegen
    %snipModelReport - Require a complete supplied mensuration metadata set
    report = newReport('SNIP sensor model'); tags = {records.tag};
    rsmReport = newReport('SNIP RSM path');
    id = find(strcmp(tags,'RSMIDA')); exposure = find(strcmp(tags,'CSEXRB'));
    rsm = isscalar(id); glas = isscalar(exposure);
    if rsm
        adjusted = any(strcmp(tags,'RSMAPB')); direct = any(strcmp(tags,'RSMDCB')); indirect = any(strcmp(tags,'RSMECB'));
        report = snipIssue(report,(adjusted && ~direct) || (~adjusted && (~indirect || direct)), ...
            'SNIPRSMCovariance','RSMAPB/RSMECB/RSMDCB', ...
            'Use RSMECB for a nonadjusted model, or RSMAPB and RSMDCB for an adjusted model.','Table 7-2');
        data = records(id).payload;
        report = snipIssue(report,~isequal(data(1:80),textField(header.iid2,80)), ...
            'SNIPRSMIdentity','RSMIDA.iid','The RSM image identifier must match IID2.','16.12');
        sensor = strtrim(char(data(161:200))); type = strtrim(char(data(201:240)));
        validType = numel(type) > 4 && endsWith(type,'_RSM');
        parts = strsplit(char(fileHeader.ftitle),'_');
        if numel(parts) >= 5 && numel(parts{1}) == 14 && knownDate(parts{1},14)
            validType = validType && strcmp(type,[parts{4} '_RSM']);
        end
        report = snipIssue(report,isempty(sensor) || ~validType,'SNIPRSMSource','RSMIDA.sid/stid', ...
            'Supply the sensor identity and product-type identifier ending in _RSM.','16.12.1.1');
    end
    if rsm, rsmReport = report; end
    report = newReport('SNIP GLAS path');
    if glas
        plane = glasImageInfo(records(exposure).payload); types = {'CSATTB','CSEPHB','CSSFAB','CSCSDB'};
        found = zeros(1,4); linked = zeros(1,0);
        for k = 1:numel(des)
            info = glasDESInfo(des(k));
            if ~info.verified || ~any(strcmpi(cellstr(plane.des),info.uuid)), continue; end
            match = find(strcmp(des(k).header.desid,types));
            if isempty(match), continue; end
            found(match) = found(match)+1;
            linked(end+1) = k;
            report = snipIssue(report,info.eci,'SNIPEarthFixed','GLAS.coordinate_system', ...
                'SNIP requires Earth-centered fixed coordinates.','7.2.1');
            if match == 4
                % The only current CSCSDB reserved area ends in positive
                % two-digit correlation IDs; absent area ends in nine zeros.
                hasReserved = ~isequal(des(k).data(end-8:end),uint8('000000000'));
                report = snipIssue(report,hasReserved,'SNIPCovarianceReserved','CSCSDB.spdcf_id_adj', ...
                    'The optional adjustment-correlation area awaits resolution of conflicting Appendix M packing rules.','7.2.1; Appendix M M.9');
            end
        end
        report = snipIssue(report,any(found == 0) || plane.sensor == ' ', ...
            'SNIPGLASCompanions','CSEXRB.assoc_des_uuid', ...
            'Associate populated attitude, ephemeris, alignment and covariance DESs with the sensor model.','7.2.1');
        if all(found > 0) && plane.sensor ~= ' '
            report = mergeReport(report,snipGLASTimeReport(records(exposure).payload,header,des,linked),'');
        end
        aircraft = find(strcmp(tags,'ACFTB '));
        if isscalar(aircraft)
            data = records(exposure).payload; at = 40+36*size(plane.des,1);
            report = snipIssue(report,~isequal(records(aircraft).payload(47:52),data(at+12:at+17)), ...
                'SNIPSensorIdentity','ACFTB/CSEXRB.sensor_id','The six-character sensor identifiers must agree.','6.4.2');
        end
    end
    % One complete mensuration path is sufficient. Additional generic model
    % metadata has already passed structural validation before this check.
    if (rsm && rsmReport.valid) || (glas && report.valid)
        report = newReport('SNIP sensor model');
        return
    end
    report = mergeReport(rsmReport,report,'');
    if ~rsm && ~glas && any(strcmp(tags,'SENSRB'))
        report = snipIssue(report,true,'SNIPSENSRBProfileUnavailable','SENSRB', ...
            'The separately distributed NGA SENSRB mensuration profile is required for this sole-model path.','7.2.3');
    else
        report = snipIssue(report,~rsm && ~glas,'SNIPGeopositioning','sensor model', ...
            'Supply a complete RSM or ECF GLAS/GFM set; RPC00B alone is insufficient.','7.2');
    end
end
