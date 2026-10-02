classdef (Sealed) RSMECA < nfx.TRE
    %RSMECA - Indirect RSM covariance and unmodeled errors
    %   OBJ = RSMECA(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   RSMECA functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   RSMECA properties:
    %       cetag - Constant tag identifier
    %       iid - IID metadata
    %       edition - EDITION metadata
    %       tid - TID metadata
    %       inclic - INCLIC metadata
    %       incluc - INCLUC metadata
    %       cvdate - CVDATE metadata
    %       xuol - XUOL metadata
    %       yuol - YUOL metadata
    %       zuol - ZUOL metadata
    %       xuxl - XUXL metadata
    %       xuyl - XUYL metadata
    %       xuzl - XUZL metadata
    %       yuxl - YUXL metadata
    %       yuyl - YUYL metadata
    %       yuzl - YUZL metadata
    %       zuxl - ZUXL metadata
    %       zuyl - ZUYL metadata
    %       zuzl - ZUZL metadata
    %       iro - IRO metadata
    %       irx - IRX metadata
    %       iry - IRY metadata
    %       irz - IRZ metadata
    %       irxx - IRXX metadata
    %       irxy - IRXY metadata
    %       irxz - IRXZ metadata
    %       iryy - IRYY metadata
    %       iryz - IRYZ metadata
    %       irzz - IRZZ metadata
    %       ico - ICO metadata
    %       icx - ICX metadata
    %       icy - ICY metadata
    %       icz - ICZ metadata
    %       icxx - ICXX metadata
    %       icxy - ICXY metadata
    %       icxz - ICXZ metadata
    %       icyy - ICYY metadata
    %       icyz - ICYZ metadata
    %       iczz - ICZZ metadata
    %       gxo - GXO metadata
    %       gyo - GYO metadata
    %       gzo - GZO metadata
    %       gxr - GXR metadata
    %       gyr - GYR metadata
    %       gzr - GZR metadata
    %       gs - GS metadata
    %       gxx - GXX metadata
    %       gxy - GXY metadata
    %       gxz - GXZ metadata
    %       gyx - GYX metadata
    %       gyy - GYY metadata
    %       gyz - GYZ metadata
    %       gzx - GZX metadata
    %       gzy - GZY metadata
    %       gzz - GZZ metadata
    %       groups - GROUPS metadata
    %       map - MAP metadata
    %       urr - URR metadata
    %       urc - URC metadata
    %       ucc - UCC metadata
    %       row_correlations - ROW_CORRELATIONS metadata
    %       column_correlations - COLUMN_CORRELATIONS metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'RSMECA' % Registered tag identifier
    end
    properties
        iid {mustBeAscii(iid, 80)} = '' % IID metadata
        edition {mustBeAscii(edition, 40)} = '' % EDITION metadata
        tid {mustBeAscii(tid, 40)} = '' % TID metadata
        inclic {mustBeAscii(inclic, 1)} = 'N' % INCLIC metadata
        incluc {mustBeAscii(incluc, 1)} = 'N' % INCLUC metadata
        cvdate {mustBeAscii(cvdate, 8)} = '' % CVDATE metadata
        % XUOL metadata
        xuol {mustBeMetadata(xuol, ...
            -9.99999999999999e+99, 9.99999999999999e+99, 0)} = NaN
        % YUOL metadata
        yuol {mustBeMetadata(yuol, ...
            -9.99999999999999e+99, 9.99999999999999e+99, 0)} = NaN
        % ZUOL metadata
        zuol {mustBeMetadata(zuol, ...
            -9.99999999999999e+99, 9.99999999999999e+99, 0)} = NaN
        % XUXL metadata
        xuxl {mustBeMetadata(xuxl, ...
            -1, 1, 0)} = NaN
        % XUYL metadata
        xuyl {mustBeMetadata(xuyl, ...
            -1, 1, 0)} = NaN
        % XUZL metadata
        xuzl {mustBeMetadata(xuzl, ...
            -1, 1, 0)} = NaN
        % YUXL metadata
        yuxl {mustBeMetadata(yuxl, ...
            -1, 1, 0)} = NaN
        % YUYL metadata
        yuyl {mustBeMetadata(yuyl, ...
            -1, 1, 0)} = NaN
        % YUZL metadata
        yuzl {mustBeMetadata(yuzl, ...
            -1, 1, 0)} = NaN
        % ZUXL metadata
        zuxl {mustBeMetadata(zuxl, ...
            -1, 1, 0)} = NaN
        % ZUYL metadata
        zuyl {mustBeMetadata(zuyl, ...
            -1, 1, 0)} = NaN
        % ZUZL metadata
        zuzl {mustBeMetadata(zuzl, ...
            -1, 1, 0)} = NaN
        % IRO metadata
        iro {mustBeMetadata(iro, ...
            1, 36, 1)} = NaN
        % IRX metadata
        irx {mustBeMetadata(irx, ...
            1, 36, 1)} = NaN
        % IRY metadata
        iry {mustBeMetadata(iry, ...
            1, 36, 1)} = NaN
        % IRZ metadata
        irz {mustBeMetadata(irz, ...
            1, 36, 1)} = NaN
        % IRXX metadata
        irxx {mustBeMetadata(irxx, ...
            1, 36, 1)} = NaN
        % IRXY metadata
        irxy {mustBeMetadata(irxy, ...
            1, 36, 1)} = NaN
        % IRXZ metadata
        irxz {mustBeMetadata(irxz, ...
            1, 36, 1)} = NaN
        % IRYY metadata
        iryy {mustBeMetadata(iryy, ...
            1, 36, 1)} = NaN
        % IRYZ metadata
        iryz {mustBeMetadata(iryz, ...
            1, 36, 1)} = NaN
        % IRZZ metadata
        irzz {mustBeMetadata(irzz, ...
            1, 36, 1)} = NaN
        % ICO metadata
        ico {mustBeMetadata(ico, ...
            1, 36, 1)} = NaN
        % ICX metadata
        icx {mustBeMetadata(icx, ...
            1, 36, 1)} = NaN
        % ICY metadata
        icy {mustBeMetadata(icy, ...
            1, 36, 1)} = NaN
        % ICZ metadata
        icz {mustBeMetadata(icz, ...
            1, 36, 1)} = NaN
        % ICXX metadata
        icxx {mustBeMetadata(icxx, ...
            1, 36, 1)} = NaN
        % ICXY metadata
        icxy {mustBeMetadata(icxy, ...
            1, 36, 1)} = NaN
        % ICXZ metadata
        icxz {mustBeMetadata(icxz, ...
            1, 36, 1)} = NaN
        % ICYY metadata
        icyy {mustBeMetadata(icyy, ...
            1, 36, 1)} = NaN
        % ICYZ metadata
        icyz {mustBeMetadata(icyz, ...
            1, 36, 1)} = NaN
        % ICZZ metadata
        iczz {mustBeMetadata(iczz, ...
            1, 36, 1)} = NaN
        % GXO metadata
        gxo {mustBeMetadata(gxo, ...
            1, 36, 1)} = NaN
        % GYO metadata
        gyo {mustBeMetadata(gyo, ...
            1, 36, 1)} = NaN
        % GZO metadata
        gzo {mustBeMetadata(gzo, ...
            1, 36, 1)} = NaN
        % GXR metadata
        gxr {mustBeMetadata(gxr, ...
            1, 36, 1)} = NaN
        % GYR metadata
        gyr {mustBeMetadata(gyr, ...
            1, 36, 1)} = NaN
        % GZR metadata
        gzr {mustBeMetadata(gzr, ...
            1, 36, 1)} = NaN
        % GS metadata
        gs {mustBeMetadata(gs, ...
            1, 36, 1)} = NaN
        % GXX metadata
        gxx {mustBeMetadata(gxx, ...
            1, 36, 1)} = NaN
        % GXY metadata
        gxy {mustBeMetadata(gxy, ...
            1, 36, 1)} = NaN
        % GXZ metadata
        gxz {mustBeMetadata(gxz, ...
            1, 36, 1)} = NaN
        % GYX metadata
        gyx {mustBeMetadata(gyx, ...
            1, 36, 1)} = NaN
        % GYY metadata
        gyy {mustBeMetadata(gyy, ...
            1, 36, 1)} = NaN
        % GYZ metadata
        gyz {mustBeMetadata(gyz, ...
            1, 36, 1)} = NaN
        % GZX metadata
        gzx {mustBeMetadata(gzx, ...
            1, 36, 1)} = NaN
        % GZY metadata
        gzy {mustBeMetadata(gzy, ...
            1, 36, 1)} = NaN
        % GZZ metadata
        gzz {mustBeMetadata(gzz, ...
            1, 36, 1)} = NaN
        % GROUPS repeated entries
        groups {mustBegroups} = repmat(newgroups(), 1, 0)
        % MAP metadata
        map {mustBeMetadataArray(map, ...
            -9.99999999999999e+99, 9.99999999999999e+99, 0)} = zeros(1, 0)
        % URR metadata
        urr {mustBeMetadata(urr, ...
            0, 9.99999999999999e+99, 0)} = NaN
        % URC metadata
        urc {mustBeMetadata(urc, ...
            -9.99999999999999e+99, 9.99999999999999e+99, 0)} = NaN
        % UCC metadata
        ucc {mustBeMetadata(ucc, ...
            0, 9.99999999999999e+99, 0)} = NaN
        % ROW_CORRELATIONS repeated entries
        row_correlations {mustBerow_correlations} = repmat(newrow_correlations(), 1, 0)
        % COLUMN_CORRELATIONS repeated entries
        column_correlations {mustBecolumn_correlations} = repmat(newcolumn_correlations(), 1, 0)
    end
    methods
        function obj = RSMECA(options) %#codegen
            arguments
                options.?nfx.RSMECA
            end
            if isfield(options, 'iid')
                obj.iid = options.iid;
            end
            if isfield(options, 'edition')
                obj.edition = options.edition;
            end
            if isfield(options, 'tid')
                obj.tid = options.tid;
            end
            if isfield(options, 'inclic')
                obj.inclic = options.inclic;
            end
            if isfield(options, 'incluc')
                obj.incluc = options.incluc;
            end
            if isfield(options, 'cvdate')
                obj.cvdate = options.cvdate;
            end
            if isfield(options, 'xuol')
                obj.xuol = options.xuol;
            end
            if isfield(options, 'yuol')
                obj.yuol = options.yuol;
            end
            if isfield(options, 'zuol')
                obj.zuol = options.zuol;
            end
            if isfield(options, 'xuxl')
                obj.xuxl = options.xuxl;
            end
            if isfield(options, 'xuyl')
                obj.xuyl = options.xuyl;
            end
            if isfield(options, 'xuzl')
                obj.xuzl = options.xuzl;
            end
            if isfield(options, 'yuxl')
                obj.yuxl = options.yuxl;
            end
            if isfield(options, 'yuyl')
                obj.yuyl = options.yuyl;
            end
            if isfield(options, 'yuzl')
                obj.yuzl = options.yuzl;
            end
            if isfield(options, 'zuxl')
                obj.zuxl = options.zuxl;
            end
            if isfield(options, 'zuyl')
                obj.zuyl = options.zuyl;
            end
            if isfield(options, 'zuzl')
                obj.zuzl = options.zuzl;
            end
            if isfield(options, 'iro')
                obj.iro = options.iro;
            end
            if isfield(options, 'irx')
                obj.irx = options.irx;
            end
            if isfield(options, 'iry')
                obj.iry = options.iry;
            end
            if isfield(options, 'irz')
                obj.irz = options.irz;
            end
            if isfield(options, 'irxx')
                obj.irxx = options.irxx;
            end
            if isfield(options, 'irxy')
                obj.irxy = options.irxy;
            end
            if isfield(options, 'irxz')
                obj.irxz = options.irxz;
            end
            if isfield(options, 'iryy')
                obj.iryy = options.iryy;
            end
            if isfield(options, 'iryz')
                obj.iryz = options.iryz;
            end
            if isfield(options, 'irzz')
                obj.irzz = options.irzz;
            end
            if isfield(options, 'ico')
                obj.ico = options.ico;
            end
            if isfield(options, 'icx')
                obj.icx = options.icx;
            end
            if isfield(options, 'icy')
                obj.icy = options.icy;
            end
            if isfield(options, 'icz')
                obj.icz = options.icz;
            end
            if isfield(options, 'icxx')
                obj.icxx = options.icxx;
            end
            if isfield(options, 'icxy')
                obj.icxy = options.icxy;
            end
            if isfield(options, 'icxz')
                obj.icxz = options.icxz;
            end
            if isfield(options, 'icyy')
                obj.icyy = options.icyy;
            end
            if isfield(options, 'icyz')
                obj.icyz = options.icyz;
            end
            if isfield(options, 'iczz')
                obj.iczz = options.iczz;
            end
            if isfield(options, 'gxo')
                obj.gxo = options.gxo;
            end
            if isfield(options, 'gyo')
                obj.gyo = options.gyo;
            end
            if isfield(options, 'gzo')
                obj.gzo = options.gzo;
            end
            if isfield(options, 'gxr')
                obj.gxr = options.gxr;
            end
            if isfield(options, 'gyr')
                obj.gyr = options.gyr;
            end
            if isfield(options, 'gzr')
                obj.gzr = options.gzr;
            end
            if isfield(options, 'gs')
                obj.gs = options.gs;
            end
            if isfield(options, 'gxx')
                obj.gxx = options.gxx;
            end
            if isfield(options, 'gxy')
                obj.gxy = options.gxy;
            end
            if isfield(options, 'gxz')
                obj.gxz = options.gxz;
            end
            if isfield(options, 'gyx')
                obj.gyx = options.gyx;
            end
            if isfield(options, 'gyy')
                obj.gyy = options.gyy;
            end
            if isfield(options, 'gyz')
                obj.gyz = options.gyz;
            end
            if isfield(options, 'gzx')
                obj.gzx = options.gzx;
            end
            if isfield(options, 'gzy')
                obj.gzy = options.gzy;
            end
            if isfield(options, 'gzz')
                obj.gzz = options.gzz;
            end
            if isfield(options, 'groups')
                obj.groups = options.groups;
            end
            if isfield(options, 'map')
                obj.map = options.map;
            end
            if isfield(options, 'urr')
                obj.urr = options.urr;
            end
            if isfield(options, 'urc')
                obj.urc = options.urc;
            end
            if isfield(options, 'ucc')
                obj.ucc = options.ucc;
            end
            if isfield(options, 'row_correlations')
                obj.row_correlations = options.row_correlations;
            end
            if isfield(options, 'column_correlations')
                obj.column_correlations = options.column_correlations;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix U, Table 9 (2024-05)';
            report = newReport(reference);
            report = addIssue(report, isempty(strtrim(char(obj.edition))), ...
                'Required', 'edition', 'Supply EDITION.', reference);
            report = addIssue(report, ...
                ~any(strcmp(obj.inclic, {'Y', 'N'})), ...
                'Enumeration', 'inclic', 'Use a defined INCLIC value.', reference);
            report = addIssue(report, ...
                ~any(strcmp(obj.incluc, {'Y', 'N'})), ...
                'Enumeration', 'incluc', 'Use a defined INCLUC value.', reference);
            if strcmp(obj.inclic, 'Y')
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isempty(obj.cvdate), ...
                'AbsentField', 'cvdate', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = rsmNumber(obj.xuol, false);
                report = addIssue(report, ~valid, 'Encoding', 'xuol', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.xuol), ...
                'AbsentField', 'xuol', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = rsmNumber(obj.yuol, false);
                report = addIssue(report, ~valid, 'Encoding', 'yuol', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.yuol), ...
                'AbsentField', 'yuol', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = rsmNumber(obj.zuol, false);
                report = addIssue(report, ~valid, 'Encoding', 'zuol', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.zuol), ...
                'AbsentField', 'zuol', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = rsmNumber(obj.xuxl, false);
                report = addIssue(report, ~valid, 'Encoding', 'xuxl', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.xuxl), ...
                'AbsentField', 'xuxl', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = rsmNumber(obj.xuyl, false);
                report = addIssue(report, ~valid, 'Encoding', 'xuyl', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.xuyl), ...
                'AbsentField', 'xuyl', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = rsmNumber(obj.xuzl, false);
                report = addIssue(report, ~valid, 'Encoding', 'xuzl', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.xuzl), ...
                'AbsentField', 'xuzl', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = rsmNumber(obj.yuxl, false);
                report = addIssue(report, ~valid, 'Encoding', 'yuxl', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.yuxl), ...
                'AbsentField', 'yuxl', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = rsmNumber(obj.yuyl, false);
                report = addIssue(report, ~valid, 'Encoding', 'yuyl', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.yuyl), ...
                'AbsentField', 'yuyl', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = rsmNumber(obj.yuzl, false);
                report = addIssue(report, ~valid, 'Encoding', 'yuzl', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.yuzl), ...
                'AbsentField', 'yuzl', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = rsmNumber(obj.zuxl, false);
                report = addIssue(report, ~valid, 'Encoding', 'zuxl', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.zuxl), ...
                'AbsentField', 'zuxl', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = rsmNumber(obj.zuyl, false);
                report = addIssue(report, ~valid, 'Encoding', 'zuyl', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.zuyl), ...
                'AbsentField', 'zuyl', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = rsmNumber(obj.zuzl, false);
                report = addIssue(report, ~valid, 'Encoding', 'zuzl', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.zuzl), ...
                'AbsentField', 'zuzl', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.iro, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'iro', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.iro), ...
                'AbsentField', 'iro', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.irx, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'irx', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.irx), ...
                'AbsentField', 'irx', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.iry, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'iry', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.iry), ...
                'AbsentField', 'iry', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.irz, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'irz', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.irz), ...
                'AbsentField', 'irz', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.irxx, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'irxx', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.irxx), ...
                'AbsentField', 'irxx', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.irxy, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'irxy', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.irxy), ...
                'AbsentField', 'irxy', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.irxz, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'irxz', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.irxz), ...
                'AbsentField', 'irxz', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.iryy, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'iryy', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.iryy), ...
                'AbsentField', 'iryy', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.iryz, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'iryz', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.iryz), ...
                'AbsentField', 'iryz', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.irzz, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'irzz', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.irzz), ...
                'AbsentField', 'irzz', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.ico, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'ico', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.ico), ...
                'AbsentField', 'ico', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.icx, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'icx', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.icx), ...
                'AbsentField', 'icx', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.icy, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'icy', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.icy), ...
                'AbsentField', 'icy', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.icz, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'icz', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.icz), ...
                'AbsentField', 'icz', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.icxx, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'icxx', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.icxx), ...
                'AbsentField', 'icxx', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.icxy, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'icxy', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.icxy), ...
                'AbsentField', 'icxy', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.icxz, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'icxz', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.icxz), ...
                'AbsentField', 'icxz', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.icyy, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'icyy', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.icyy), ...
                'AbsentField', 'icyy', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.icyz, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'icyz', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.icyz), ...
                'AbsentField', 'icyz', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.iczz, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'iczz', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.iczz), ...
                'AbsentField', 'iczz', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.gxo, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'gxo', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.gxo), ...
                'AbsentField', 'gxo', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.gyo, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'gyo', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.gyo), ...
                'AbsentField', 'gyo', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.gzo, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'gzo', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.gzo), ...
                'AbsentField', 'gzo', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.gxr, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'gxr', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.gxr), ...
                'AbsentField', 'gxr', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.gyr, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'gyr', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.gyr), ...
                'AbsentField', 'gyr', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.gzr, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'gzr', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.gzr), ...
                'AbsentField', 'gzr', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.gs, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'gs', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.gs), ...
                'AbsentField', 'gs', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.gxx, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'gxx', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.gxx), ...
                'AbsentField', 'gxx', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.gxy, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'gxy', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.gxy), ...
                'AbsentField', 'gxy', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.gxz, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'gxz', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.gxz), ...
                'AbsentField', 'gxz', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.gyx, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'gyx', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.gyx), ...
                'AbsentField', 'gyx', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.gyy, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'gyy', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.gyy), ...
                'AbsentField', 'gyy', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.gyz, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'gyz', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.gyz), ...
                'AbsentField', 'gyz', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.gzx, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'gzx', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.gzx), ...
                'AbsentField', 'gzx', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.gzy, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'gzy', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.gzy), ...
                'AbsentField', 'gzy', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                [~, valid] = treNumber(obj.gzz, 2, 0, false, true, false);
                report = addIssue(report, ~valid, 'Encoding', 'gzz', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isnan(obj.gzz), ...
                'AbsentField', 'gzz', 'Leave the omitted field empty.', reference);
            if strcmp(obj.inclic, 'Y')
                report = addIssue(report, numel(obj.groups) < 1 || ...
                    numel(obj.groups) > 36, ...
                    'Count', 'groups', 'Entry count is outside the defined range.', reference);
                for k = 1:numel(obj.groups)
                    report = validategroups(obj.groups(k), report, reference);
                end
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isempty(obj.groups), ...
                'AbsentField', 'groups', 'Leave the omitted group empty.', reference);
            if strcmp(obj.inclic, 'Y')
                report = addIssue(report, ...
                    ~(isrow(obj.map) || isempty(obj.map)) || ...
                    numel(obj.map) < 1 || numel(obj.map) > 4761, ...
                    'Count', 'map', 'Supply a row within the defined count limits.', reference);
                for k = 1:numel(obj.map)
                    [~, valid] = rsmNumber(obj.map(k), false);
                    report = addIssue(report, ~valid, 'Encoding', 'map', ...
                        'Supply finite values fitting the encoded precision.', reference);
                end
            end
            report = addIssue(report, ~(strcmp(obj.inclic, 'Y')) && ~isempty(obj.map), ...
                'AbsentField', 'map', 'Leave the omitted field empty.', reference);
            if strcmp(obj.incluc, 'Y')
                [~, valid] = rsmNumber(obj.urr, false);
                report = addIssue(report, ~valid, 'Encoding', 'urr', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.incluc, 'Y')) && ~isnan(obj.urr), ...
                'AbsentField', 'urr', 'Leave the omitted field empty.', reference);
            if strcmp(obj.incluc, 'Y')
                [~, valid] = rsmNumber(obj.urc, false);
                report = addIssue(report, ~valid, 'Encoding', 'urc', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.incluc, 'Y')) && ~isnan(obj.urc), ...
                'AbsentField', 'urc', 'Leave the omitted field empty.', reference);
            if strcmp(obj.incluc, 'Y')
                [~, valid] = rsmNumber(obj.ucc, false);
                report = addIssue(report, ~valid, 'Encoding', 'ucc', ...
                    'Supply a value fitting the encoded precision.', reference);
            end
            report = addIssue(report, ~(strcmp(obj.incluc, 'Y')) && ~isnan(obj.ucc), ...
                'AbsentField', 'ucc', 'Leave the omitted field empty.', reference);
            if strcmp(obj.incluc, 'Y')
                report = addIssue(report, numel(obj.row_correlations) < 2 || ...
                    numel(obj.row_correlations) > 9, ...
                    'Count', 'row_correlations', 'Entry count is outside the defined range.', reference);
                for k = 1:numel(obj.row_correlations)
                    report = validaterow_correlations(obj.row_correlations(k), report, reference);
                end
            end
            report = addIssue(report, ~(strcmp(obj.incluc, 'Y')) && ~isempty(obj.row_correlations), ...
                'AbsentField', 'row_correlations', 'Leave the omitted group empty.', reference);
            if strcmp(obj.incluc, 'Y')
                report = addIssue(report, numel(obj.column_correlations) < 2 || ...
                    numel(obj.column_correlations) > 9, ...
                    'Count', 'column_correlations', 'Entry count is outside the defined range.', reference);
                for k = 1:numel(obj.column_correlations)
                    report = validatecolumn_correlations(obj.column_correlations(k), report, reference);
                end
            end
            report = addIssue(report, ~(strcmp(obj.incluc, 'Y')) && ~isempty(obj.column_correlations), ...
                'AbsentField', 'column_correlations', 'Leave the omitted group empty.', reference);
            if strcmp(obj.inclic, 'Y')
            indices = [obj.iro obj.irx obj.iry obj.irz obj.irxx obj.irxy obj.irxz obj.iryy obj.iryz obj.irzz obj.ico obj.icx obj.icy obj.icz obj.icxx obj.icxy obj.icxz obj.icyy obj.icyz obj.iczz obj.gxo obj.gyo obj.gzo obj.gxr obj.gyr obj.gzr obj.gs obj.gxx obj.gxy obj.gxz obj.gyx obj.gyy obj.gyz obj.gzx obj.gzy obj.gzz];
            active = indices(isfinite(indices));
            report = addIssue(report, ~isequal(sort(active), 1:numel(active)) || isempty(active), ...
                'Metadata', 'indices', 'Active indices must be a permutation of 1 through NPAR.', reference);
            report = addIssue(report, ~rsmOrthonormal(reshape([obj.xuxl obj.xuyl obj.xuzl obj.yuxl obj.yuyl obj.yuzl obj.zuxl obj.zuyl obj.zuzl], 3, 3), true), ...
                'Metadata', 'local_frame', 'Supply a right-handed orthonormal local coordinate basis.', reference);
            report = addIssue(report, legacyParameterCount(obj.groups) > 36 || ...
                numel(obj.map) ~= numel(active) * legacyParameterCount(obj.groups), ...
                'Metadata', 'groups/map', 'Supply at most 36 original parameters and a complete row-major mapping matrix.', reference);
            report = addIssue(report, ~isempty(char(obj.cvdate)) && ~knownDate(obj.cvdate, 8), ...
                'Metadata', 'cvdate', 'Supply a valid date or leave it blank.', reference);
            end
            if strcmp(obj.incluc, 'Y')
            report = addIssue(report, ~rsmCovariance([obj.urr obj.urc; obj.urc obj.ucc]), ...
                'Metadata', 'urr/urc/ucc', 'Supply a positive semidefinite unmodeled covariance.', reference);
            report = addIssue(report, ~validLegacyCorrelation([obj.row_correlations.ucorsr], [obj.row_correlations.utausr]) || ...
                ~validLegacyCorrelation([obj.column_correlations.ucorsc], [obj.column_correlations.utausc]), ...
                'Metadata', 'unmodeled_correlations', 'Supply valid row and column correlation functions.', reference);
            end
            report = addIssue(report, strcmp(obj.inclic, 'N') && strcmp(obj.incluc, 'N'), ...
                'Metadata', 'inclic/incluc', 'Include at least one covariance model.', reference);
            payloadLength = 80 + ...
                40 + ...
                40 + ...
                1 + ...
                1 + ...
                double(strcmp(obj.inclic, 'Y')) * 2 + ...
                double(strcmp(obj.inclic, 'Y')) * 2 + ...
                double(strcmp(obj.inclic, 'Y')) * 2 + ...
                double(strcmp(obj.inclic, 'Y')) * (8) + ...
                double(strcmp(obj.inclic, 'Y')) * (21) + ...
                double(strcmp(obj.inclic, 'Y')) * (21) + ...
                double(strcmp(obj.inclic, 'Y')) * (21) + ...
                double(strcmp(obj.inclic, 'Y')) * (21) + ...
                double(strcmp(obj.inclic, 'Y')) * (21) + ...
                double(strcmp(obj.inclic, 'Y')) * (21) + ...
                double(strcmp(obj.inclic, 'Y')) * (21) + ...
                double(strcmp(obj.inclic, 'Y')) * (21) + ...
                double(strcmp(obj.inclic, 'Y')) * (21) + ...
                double(strcmp(obj.inclic, 'Y')) * (21) + ...
                double(strcmp(obj.inclic, 'Y')) * (21) + ...
                double(strcmp(obj.inclic, 'Y')) * (21) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (2) + ...
                double(strcmp(obj.inclic, 'Y')) * (lengthgroups(obj.groups)) + ...
                double(strcmp(obj.inclic, 'Y')) * (0 + 21 * numel(obj.map)) + ...
                double(strcmp(obj.incluc, 'Y')) * (21) + ...
                double(strcmp(obj.incluc, 'Y')) * (21) + ...
                double(strcmp(obj.incluc, 'Y')) * (21) + ...
                double(strcmp(obj.incluc, 'Y')) * (lengthrow_correlations(obj.row_correlations)) + ...
                double(strcmp(obj.incluc, 'Y')) * (lengthcolumn_correlations(obj.column_correlations));
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 43045, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data textField(obj.iid, 80)];
            data = [data textField(obj.edition, 40)];
            data = [data textField(obj.tid, 40)];
            data = [data textField(obj.inclic, 1)];
            data = [data textField(obj.incluc, 1)];
            if strcmp(obj.inclic, 'Y')
                data = [data decimalField(sum(isfinite([obj.iro obj.irx obj.iry obj.irz obj.irxx obj.irxy obj.irxz obj.iryy obj.iryz obj.irzz obj.ico obj.icx obj.icy obj.icz obj.icxx obj.icxy obj.icxz obj.icyy obj.icyz obj.iczz obj.gxo obj.gyo obj.gzo obj.gxr obj.gyr obj.gzr obj.gs obj.gxx obj.gxy obj.gxz obj.gyx obj.gyy obj.gyz obj.gzx obj.gzy obj.gzz])), 2, 0, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data decimalField(legacyParameterCount(obj.groups), 2, 0, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data decimalField(numel(obj.groups), 2, 0, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data textField(obj.cvdate, 8)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data rsmNumber(obj.xuol, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data rsmNumber(obj.yuol, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data rsmNumber(obj.zuol, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data rsmNumber(obj.xuxl, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data rsmNumber(obj.xuyl, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data rsmNumber(obj.xuzl, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data rsmNumber(obj.yuxl, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data rsmNumber(obj.yuyl, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data rsmNumber(obj.yuzl, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data rsmNumber(obj.zuxl, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data rsmNumber(obj.zuyl, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data rsmNumber(obj.zuzl, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.iro, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.irx, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.iry, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.irz, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.irxx, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.irxy, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.irxz, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.iryy, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.iryz, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.irzz, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.ico, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.icx, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.icy, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.icz, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.icxx, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.icxy, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.icxz, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.icyy, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.icyz, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.iczz, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.gxo, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.gyo, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.gzo, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.gxr, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.gyr, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.gzr, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.gs, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.gxx, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.gxy, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.gxz, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.gyx, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.gyy, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.gyz, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.gzx, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.gzy, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                data = [data treNumber(obj.gzz, 2, 0, false, true, false)];
            end
            if strcmp(obj.inclic, 'Y')
                for k = 1:numel(obj.groups)
                    data = [data writegroups(obj.groups(k))]; %#ok<AGROW>
                end
            end
            if strcmp(obj.inclic, 'Y')
                for k = 1:numel(obj.map)
                    data = [data rsmNumber(obj.map(k), false)]; %#ok<AGROW>
                end
            end
            if strcmp(obj.incluc, 'Y')
                data = [data rsmNumber(obj.urr, false)];
            end
            if strcmp(obj.incluc, 'Y')
                data = [data rsmNumber(obj.urc, false)];
            end
            if strcmp(obj.incluc, 'Y')
                data = [data rsmNumber(obj.ucc, false)];
            end
            if strcmp(obj.incluc, 'Y')
                data = [data decimalField(numel(obj.row_correlations), 1, 0, false)];
                for k = 1:numel(obj.row_correlations)
                    data = [data writerow_correlations(obj.row_correlations(k))]; %#ok<AGROW>
                end
            end
            if strcmp(obj.incluc, 'Y')
                data = [data decimalField(numel(obj.column_correlations), 1, 0, false)];
                for k = 1:numel(obj.column_correlations)
                    data = [data writecolumn_correlations(obj.column_correlations(k))]; %#ok<AGROW>
                end
            end
        end
    end
    methods (Static)
        function entry = groupsEntry() %#codegen
            %groupsEntry - Create one editable repeated entry
            %   ENTRY = nfx.RSMECA.groupsEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newgroups();
        end

        function entry = correlationsEntry() %#codegen
            %correlationsEntry - Create one editable repeated entry
            %   ENTRY = nfx.RSMECA.correlationsEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newcorrelations();
        end

        function entry = row_correlationsEntry() %#codegen
            %row_correlationsEntry - Create one editable repeated entry
            %   ENTRY = nfx.RSMECA.row_correlationsEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newrow_correlations();
        end

        function entry = column_correlationsEntry() %#codegen
            %column_correlationsEntry - Create one editable repeated entry
            %   ENTRY = nfx.RSMECA.column_correlationsEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newcolumn_correlations();
        end

        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent metadata value
            %   OBJ = deserialize(DATA) reads a uint8 payload row.
            %   [OBJ, OK, STATUS] = deserialize(DATA) also returns success
            %   and a diagnostic. Failure returns a default scalar object.
            arguments
                data
            end
            obj = nfx.RSMECA();
            reader = nfx.internal.TREReader(data, 43045);
            [value, reader] = reader.text(80, true, false);
            if reader.ok, obj.iid = value; end
            [value, reader] = reader.text(40, true, false);
            if reader.ok, obj.edition = value; end
            [value, reader] = reader.text(40, true, false);
            if reader.ok, obj.tid = value; end
            [value, reader] = reader.text(1, true, false);
            if reader.ok, obj.inclic = value; end
            [value, reader] = reader.text(1, true, false);
            if reader.ok, obj.incluc = value; end
            nparCount = 0;
            if strcmp(obj.inclic, 'Y')
                [nparCount, reader] = reader.number(2, 1, 36, true);
            end
            nparoCount = 0;
            if strcmp(obj.inclic, 'Y')
                [nparoCount, reader] = reader.number(2, 1, 36, true);
            end
            groupsCount = 0;
            if strcmp(obj.inclic, 'Y')
                [groupsCount, reader] = reader.count(2, 3, 36);
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.text(8, true, false);
                if reader.ok, obj.cvdate = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(21, -9.99999999999999e+99, 9.99999999999999e+99, ...
                    false, false);
                if reader.ok, obj.xuol = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(21, -9.99999999999999e+99, 9.99999999999999e+99, ...
                    false, false);
                if reader.ok, obj.yuol = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(21, -9.99999999999999e+99, 9.99999999999999e+99, ...
                    false, false);
                if reader.ok, obj.zuol = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(21, -1, 1, ...
                    false, false);
                if reader.ok, obj.xuxl = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(21, -1, 1, ...
                    false, false);
                if reader.ok, obj.xuyl = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(21, -1, 1, ...
                    false, false);
                if reader.ok, obj.xuzl = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(21, -1, 1, ...
                    false, false);
                if reader.ok, obj.yuxl = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(21, -1, 1, ...
                    false, false);
                if reader.ok, obj.yuyl = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(21, -1, 1, ...
                    false, false);
                if reader.ok, obj.yuzl = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(21, -1, 1, ...
                    false, false);
                if reader.ok, obj.zuxl = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(21, -1, 1, ...
                    false, false);
                if reader.ok, obj.zuyl = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(21, -1, 1, ...
                    false, false);
                if reader.ok, obj.zuzl = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.iro = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.irx = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.iry = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.irz = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.irxx = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.irxy = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.irxz = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.iryy = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.iryz = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.irzz = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.ico = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.icx = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.icy = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.icz = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.icxx = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.icxy = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.icxz = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.icyy = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.icyz = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.iczz = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.gxo = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.gyo = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.gzo = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.gxr = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.gyr = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.gzr = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.gs = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.gxx = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.gxy = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.gxz = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.gyx = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.gyy = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.gyz = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.gzx = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.gzy = value; end
            end
            if strcmp(obj.inclic, 'Y')
                [value, reader] = reader.number(2, 1, 36, ...
                    true, true);
                if reader.ok, obj.gzz = value; end
            end
            if strcmp(obj.inclic, 'Y')
                count = groupsCount;
                entries = repmat(newgroups(), 1, 0);
                for k = 1:count
                    [entry, reader] = readgroups(reader);
                    if ~reader.ok, break; end
                    entries(end + 1) = entry;
                end
                if reader.ok, obj.groups = entries; end
            end
            if strcmp(obj.inclic, 'Y')
                count = nparCount * nparoCount;
                [value, reader] = reader.numbers(count, 21, -9.99999999999999e+99, 9.99999999999999e+99, ...
                    false, false);
                if reader.ok, obj.map = value; end
            end
            if strcmp(obj.incluc, 'Y')
                [value, reader] = reader.number(21, 0, 9.99999999999999e+99, ...
                    false, false);
                if reader.ok, obj.urr = value; end
            end
            if strcmp(obj.incluc, 'Y')
                [value, reader] = reader.number(21, -9.99999999999999e+99, 9.99999999999999e+99, ...
                    false, false);
                if reader.ok, obj.urc = value; end
            end
            if strcmp(obj.incluc, 'Y')
                [value, reader] = reader.number(21, 0, 9.99999999999999e+99, ...
                    false, false);
                if reader.ok, obj.ucc = value; end
            end
            if strcmp(obj.incluc, 'Y')
                [count, reader] = reader.count(1, 42, 9);
                entries = repmat(newrow_correlations(), 1, 0);
                for k = 1:count
                    [entry, reader] = readrow_correlations(reader);
                    if ~reader.ok, break; end
                    entries(end + 1) = entry;
                end
                if reader.ok, obj.row_correlations = entries; end
            end
            if strcmp(obj.incluc, 'Y')
                [count, reader] = reader.count(1, 42, 9);
                entries = repmat(newcolumn_correlations(), 1, 0);
                for k = 1:count
                    [entry, reader] = readcolumn_correlations(reader);
                    if ~reader.ok, break; end
                    entries(end + 1) = entry;
                end
                if reader.ok, obj.column_correlations = entries; end
            end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.RSMECA());
        end
    end
end

function entry = newgroups() %#codegen
    entry = struct( ...
        'errcvg', zeros(1, 0), ...
        'tcdf', NaN, ...
        'correlations', repmat(newcorrelations(), 1, 0));
end

function mustBegroups(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 3 || ...
            ~all(isfield(entries, { ...
                'errcvg', ...
                'tcdf', ...
                'correlations'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeMetadataArray(entry.errcvg, -9.99999999999999e+99, 9.99999999999999e+99, false);
        mustBeMetadata(entry.tcdf, 0, 2, true);
        mustBecorrelations(entry.correlations);
    end
end

function report = validategroups(entry, report, reference) %#codegen
    report = addIssue(report, numel(entry.errcvg) < 1 || ...
        numel(entry.errcvg) > 4761, ...
        'Count', 'errcvg', 'Vector count is outside the defined range.', reference);
    for j = 1:numel(entry.errcvg)
        [~, valid] = rsmNumber(entry.errcvg(j), false);
        report = addIssue(report, ~valid, 'Encoding', 'errcvg', ...
            'Supply values fitting the encoded precision.', reference);
    end
    [~, valid] = treNumber(entry.tcdf, 1, 0, false, false, false);
    report = addIssue(report, ~valid, 'Encoding', 'tcdf', ...
        'Supply a value fitting the encoded precision.', reference);
    report = addIssue(report, numel(entry.correlations) < 2 || ...
        numel(entry.correlations) > 9, ...
        'Count', 'correlations', 'Entry count is outside the defined range.', reference);
    for childK = 1:numel(entry.correlations)
        report = validatecorrelations(entry.correlations(childK), report, reference);
    end
    report = addIssue(report, ~validUpperCovariance(entry.errcvg, ...
        (sqrt(1 + 8 * numel(entry.errcvg)) - 1) / 2), ...
        'Metadata', 'errcvg', 'Supply a positive semidefinite upper triangle for 1 to 36 parameters.', reference);
    report = addIssue(report, ~validLegacyCorrelation([entry.correlations.corseg], [entry.correlations.tauseg]), ...
        'Metadata', 'correlations', 'Supply a valid piecewise-linear correlation function.', reference);
end

function data = writegroups(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data decimalField((sqrt(1 + 8 * numel(entry.errcvg)) - 1) / 2, 2, 0, false)];
    for j = 1:numel(entry.errcvg)
        data = [data rsmNumber(entry.errcvg(j), false)]; %#ok<AGROW>
    end
    data = [data treNumber(entry.tcdf, 1, 0, false, false, false)];
    data = [data decimalField(numel(entry.correlations), 1, 0, false)];
    for childK = 1:numel(entry.correlations)
        data = [data writecorrelations(entry.correlations(childK))]; %#ok<AGROW>
    end
end

function [entry, reader] = readgroups(reader) %#codegen
    entry = newgroups();
    [numopgCount, reader] = reader.number(2, 1, 36, true);
    valueCount = numopgCount * (numopgCount + 1) / 2;
    [value, reader] = reader.numbers(valueCount, 21, -9.99999999999999e+99, 9.99999999999999e+99, false);
    if reader.ok, entry.errcvg = value; end
    [value, reader] = reader.number(1, 0, 2, ...
        true, false);
    if reader.ok, entry.tcdf = value; end
    [childCount, reader] = reader.count(1, 42, 9);
    childEntries = repmat(newcorrelations(), 1, 0);
    for childK = 1:childCount
        [childEntry, reader] = readcorrelations(reader);
        if ~reader.ok, break; end
        childEntries(end + 1) = childEntry;
    end
    if reader.ok, entry.correlations = childEntries; end
end

function count = lengthgroups(entries) %#codegen
    count = 0;
    for k = 1:numel(entries)
        entry = entries(k);
        count = count + 2 + ...
            0 + 21 * numel(entry.errcvg) + ...
            1 + ...
            lengthcorrelations(entry.correlations);
    end
end

function entry = newcorrelations() %#codegen
    entry = struct( ...
        'corseg', NaN, ...
        'tauseg', NaN);
end

function mustBecorrelations(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 2 || ...
            ~all(isfield(entries, { ...
                'corseg', ...
                'tauseg'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeMetadata(entry.corseg, 0, 1, false);
        mustBeMetadata(entry.tauseg, 0, 9.99999999999999e+99, false);
    end
end

function report = validatecorrelations(entry, report, reference) %#codegen
    [~, valid] = rsmNumber(entry.corseg, false);
    report = addIssue(report, ~valid, 'Encoding', 'corseg', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = rsmNumber(entry.tauseg, false);
    report = addIssue(report, ~valid, 'Encoding', 'tauseg', ...
        'Supply a value fitting the encoded precision.', reference);
end

function data = writecorrelations(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data rsmNumber(entry.corseg, false)];
    data = [data rsmNumber(entry.tauseg, false)];
end

function [entry, reader] = readcorrelations(reader) %#codegen
    entry = newcorrelations();
    [value, reader] = reader.number(21, 0, 1, ...
        false, false);
    if reader.ok, entry.corseg = value; end
    [value, reader] = reader.number(21, 0, 9.99999999999999e+99, ...
        false, false);
    if reader.ok, entry.tauseg = value; end
end

function count = lengthcorrelations(entries) %#codegen
    count = 1 + 42 * numel(entries);
end

function entry = newrow_correlations() %#codegen
    entry = struct( ...
        'ucorsr', NaN, ...
        'utausr', NaN);
end

function mustBerow_correlations(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 2 || ...
            ~all(isfield(entries, { ...
                'ucorsr', ...
                'utausr'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeMetadata(entry.ucorsr, 0, 1, false);
        mustBeMetadata(entry.utausr, 0, 9.99999999999999e+99, false);
    end
end

function report = validaterow_correlations(entry, report, reference) %#codegen
    [~, valid] = rsmNumber(entry.ucorsr, false);
    report = addIssue(report, ~valid, 'Encoding', 'ucorsr', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = rsmNumber(entry.utausr, false);
    report = addIssue(report, ~valid, 'Encoding', 'utausr', ...
        'Supply a value fitting the encoded precision.', reference);
end

function data = writerow_correlations(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data rsmNumber(entry.ucorsr, false)];
    data = [data rsmNumber(entry.utausr, false)];
end

function [entry, reader] = readrow_correlations(reader) %#codegen
    entry = newrow_correlations();
    [value, reader] = reader.number(21, 0, 1, ...
        false, false);
    if reader.ok, entry.ucorsr = value; end
    [value, reader] = reader.number(21, 0, 9.99999999999999e+99, ...
        false, false);
    if reader.ok, entry.utausr = value; end
end

function count = lengthrow_correlations(entries) %#codegen
    count = 1 + 42 * numel(entries);
end

function entry = newcolumn_correlations() %#codegen
    entry = struct( ...
        'ucorsc', NaN, ...
        'utausc', NaN);
end

function mustBecolumn_correlations(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 2 || ...
            ~all(isfield(entries, { ...
                'ucorsc', ...
                'utausc'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeMetadata(entry.ucorsc, 0, 1, false);
        mustBeMetadata(entry.utausc, 0, 9.99999999999999e+99, false);
    end
end

function report = validatecolumn_correlations(entry, report, reference) %#codegen
    [~, valid] = rsmNumber(entry.ucorsc, false);
    report = addIssue(report, ~valid, 'Encoding', 'ucorsc', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = rsmNumber(entry.utausc, false);
    report = addIssue(report, ~valid, 'Encoding', 'utausc', ...
        'Supply a value fitting the encoded precision.', reference);
end

function data = writecolumn_correlations(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data rsmNumber(entry.ucorsc, false)];
    data = [data rsmNumber(entry.utausc, false)];
end

function [entry, reader] = readcolumn_correlations(reader) %#codegen
    entry = newcolumn_correlations();
    [value, reader] = reader.number(21, 0, 1, ...
        false, false);
    if reader.ok, entry.ucorsc = value; end
    [value, reader] = reader.number(21, 0, 9.99999999999999e+99, ...
        false, false);
    if reader.ok, entry.utausc = value; end
end

function count = lengthcolumn_correlations(entries) %#codegen
    count = 1 + 42 * numel(entries);
end
