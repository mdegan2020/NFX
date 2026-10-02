classdef (Sealed) RSMAPA < nfx.TRE
    %RSMAPA - Indexed RSM parameter adjustments
    %   OBJ = RSMAPA(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   RSMAPA functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   RSMAPA properties:
    %       cetag - Constant tag identifier
    %       iid - IID metadata
    %       edition - EDITION metadata
    %       tid - TID metadata
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
    %       parval - PARVAL metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'RSMAPA' % Registered tag identifier
    end
    properties
        iid {mustBeAscii(iid, 80)} = '' % IID metadata
        edition {mustBeAscii(edition, 40)} = '' % EDITION metadata
        tid {mustBeAscii(tid, 40)} = '' % TID metadata
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
        % PARVAL metadata
        parval {mustBeMetadataArray(parval, ...
            -9.99999999999999e+99, 9.99999999999999e+99, 0)} = zeros(1, 0)
    end
    methods
        function obj = RSMAPA(options) %#codegen
            arguments
                options.?nfx.RSMAPA
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
            if isfield(options, 'parval')
                obj.parval = options.parval;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix U, Table 7 (2024-05)';
            report = newReport(reference);
            report = addIssue(report, isempty(strtrim(char(obj.edition))), ...
                'Required', 'edition', 'Supply EDITION.', reference);
            [~, valid] = rsmNumber(obj.xuol, false);
            report = addIssue(report, ~valid, 'Encoding', 'xuol', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = rsmNumber(obj.yuol, false);
            report = addIssue(report, ~valid, 'Encoding', 'yuol', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = rsmNumber(obj.zuol, false);
            report = addIssue(report, ~valid, 'Encoding', 'zuol', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = rsmNumber(obj.xuxl, false);
            report = addIssue(report, ~valid, 'Encoding', 'xuxl', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = rsmNumber(obj.xuyl, false);
            report = addIssue(report, ~valid, 'Encoding', 'xuyl', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = rsmNumber(obj.xuzl, false);
            report = addIssue(report, ~valid, 'Encoding', 'xuzl', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = rsmNumber(obj.yuxl, false);
            report = addIssue(report, ~valid, 'Encoding', 'yuxl', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = rsmNumber(obj.yuyl, false);
            report = addIssue(report, ~valid, 'Encoding', 'yuyl', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = rsmNumber(obj.yuzl, false);
            report = addIssue(report, ~valid, 'Encoding', 'yuzl', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = rsmNumber(obj.zuxl, false);
            report = addIssue(report, ~valid, 'Encoding', 'zuxl', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = rsmNumber(obj.zuyl, false);
            report = addIssue(report, ~valid, 'Encoding', 'zuyl', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = rsmNumber(obj.zuzl, false);
            report = addIssue(report, ~valid, 'Encoding', 'zuzl', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.iro, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'iro', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.irx, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'irx', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.iry, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'iry', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.irz, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'irz', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.irxx, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'irxx', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.irxy, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'irxy', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.irxz, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'irxz', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.iryy, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'iryy', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.iryz, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'iryz', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.irzz, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'irzz', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.ico, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'ico', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.icx, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'icx', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.icy, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'icy', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.icz, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'icz', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.icxx, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'icxx', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.icxy, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'icxy', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.icxz, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'icxz', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.icyy, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'icyy', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.icyz, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'icyz', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.iczz, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'iczz', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.gxo, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'gxo', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.gyo, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'gyo', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.gzo, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'gzo', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.gxr, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'gxr', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.gyr, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'gyr', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.gzr, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'gzr', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.gs, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'gs', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.gxx, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'gxx', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.gxy, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'gxy', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.gxz, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'gxz', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.gyx, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'gyx', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.gyy, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'gyy', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.gyz, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'gyz', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.gzx, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'gzx', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.gzy, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'gzy', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.gzz, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'gzz', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, ...
                ~(isrow(obj.parval) || isempty(obj.parval)) || ...
                numel(obj.parval) < 1 || numel(obj.parval) > 4761, ...
                'Count', 'parval', 'Supply a row within the defined count limits.', reference);
            for k = 1:numel(obj.parval)
                [~, valid] = rsmNumber(obj.parval(k), false);
                report = addIssue(report, ~valid, 'Encoding', 'parval', ...
                    'Supply finite values fitting the encoded precision.', reference);
            end
            indices = [obj.iro obj.irx obj.iry obj.irz obj.irxx obj.irxy obj.irxz obj.iryy obj.iryz obj.irzz obj.ico obj.icx obj.icy obj.icz obj.icxx obj.icxy obj.icxz obj.icyy obj.icyz obj.iczz obj.gxo obj.gyo obj.gzo obj.gxr obj.gyr obj.gzr obj.gs obj.gxx obj.gxy obj.gxz obj.gyx obj.gyy obj.gyz obj.gzx obj.gzy obj.gzz];
            active = indices(isfinite(indices));
            report = addIssue(report, ~isequal(sort(active), 1:numel(active)) || isempty(active), ...
                'Metadata', 'indices', 'Active indices must be a permutation of 1 through NPAR.', reference);
            report = addIssue(report, ~rsmOrthonormal(reshape([obj.xuxl obj.xuyl obj.xuzl obj.yuxl obj.yuyl obj.yuzl obj.zuxl obj.zuyl obj.zuzl], 3, 3), true), ...
                'Metadata', 'local_frame', 'Supply a right-handed orthonormal local coordinate basis.', reference);
            report = addIssue(report, numel(obj.parval) ~= numel(active), ...
                'Metadata', 'parval', 'Supply one value per active parameter.', reference);
            payloadLength = 80 + ...
                40 + ...
                40 + ...
                2 + ...
                21 + ...
                21 + ...
                21 + ...
                21 + ...
                21 + ...
                21 + ...
                21 + ...
                21 + ...
                21 + ...
                21 + ...
                21 + ...
                21 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                2 + ...
                0 + 21 * numel(obj.parval);
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data textField(obj.iid, 80)];
            data = [data textField(obj.edition, 40)];
            data = [data textField(obj.tid, 40)];
            data = [data decimalField(numel(obj.parval), 2, 0, false)];
            data = [data rsmNumber(obj.xuol, false)];
            data = [data rsmNumber(obj.yuol, false)];
            data = [data rsmNumber(obj.zuol, false)];
            data = [data rsmNumber(obj.xuxl, false)];
            data = [data rsmNumber(obj.xuyl, false)];
            data = [data rsmNumber(obj.xuzl, false)];
            data = [data rsmNumber(obj.yuxl, false)];
            data = [data rsmNumber(obj.yuyl, false)];
            data = [data rsmNumber(obj.yuzl, false)];
            data = [data rsmNumber(obj.zuxl, false)];
            data = [data rsmNumber(obj.zuyl, false)];
            data = [data rsmNumber(obj.zuzl, false)];
            data = [data treNumber(obj.iro, 2, 0, false, true, false)];
            data = [data treNumber(obj.irx, 2, 0, false, true, false)];
            data = [data treNumber(obj.iry, 2, 0, false, true, false)];
            data = [data treNumber(obj.irz, 2, 0, false, true, false)];
            data = [data treNumber(obj.irxx, 2, 0, false, true, false)];
            data = [data treNumber(obj.irxy, 2, 0, false, true, false)];
            data = [data treNumber(obj.irxz, 2, 0, false, true, false)];
            data = [data treNumber(obj.iryy, 2, 0, false, true, false)];
            data = [data treNumber(obj.iryz, 2, 0, false, true, false)];
            data = [data treNumber(obj.irzz, 2, 0, false, true, false)];
            data = [data treNumber(obj.ico, 2, 0, false, true, false)];
            data = [data treNumber(obj.icx, 2, 0, false, true, false)];
            data = [data treNumber(obj.icy, 2, 0, false, true, false)];
            data = [data treNumber(obj.icz, 2, 0, false, true, false)];
            data = [data treNumber(obj.icxx, 2, 0, false, true, false)];
            data = [data treNumber(obj.icxy, 2, 0, false, true, false)];
            data = [data treNumber(obj.icxz, 2, 0, false, true, false)];
            data = [data treNumber(obj.icyy, 2, 0, false, true, false)];
            data = [data treNumber(obj.icyz, 2, 0, false, true, false)];
            data = [data treNumber(obj.iczz, 2, 0, false, true, false)];
            data = [data treNumber(obj.gxo, 2, 0, false, true, false)];
            data = [data treNumber(obj.gyo, 2, 0, false, true, false)];
            data = [data treNumber(obj.gzo, 2, 0, false, true, false)];
            data = [data treNumber(obj.gxr, 2, 0, false, true, false)];
            data = [data treNumber(obj.gyr, 2, 0, false, true, false)];
            data = [data treNumber(obj.gzr, 2, 0, false, true, false)];
            data = [data treNumber(obj.gs, 2, 0, false, true, false)];
            data = [data treNumber(obj.gxx, 2, 0, false, true, false)];
            data = [data treNumber(obj.gxy, 2, 0, false, true, false)];
            data = [data treNumber(obj.gxz, 2, 0, false, true, false)];
            data = [data treNumber(obj.gyx, 2, 0, false, true, false)];
            data = [data treNumber(obj.gyy, 2, 0, false, true, false)];
            data = [data treNumber(obj.gyz, 2, 0, false, true, false)];
            data = [data treNumber(obj.gzx, 2, 0, false, true, false)];
            data = [data treNumber(obj.gzy, 2, 0, false, true, false)];
            data = [data treNumber(obj.gzz, 2, 0, false, true, false)];
            for k = 1:numel(obj.parval)
                data = [data rsmNumber(obj.parval(k), false)]; %#ok<AGROW>
            end
        end
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent metadata value
            %   OBJ = deserialize(DATA) reads a uint8 payload row.
            %   [OBJ, OK, STATUS] = deserialize(DATA) also returns success
            %   and a diagnostic. Failure returns a default scalar object.
            arguments
                data
            end
            obj = nfx.RSMAPA();
            reader = nfx.internal.TREReader(data, 99985);
            [value, reader] = reader.text(80, true, false);
            if reader.ok, obj.iid = value; end
            [value, reader] = reader.text(40, true, false);
            if reader.ok, obj.edition = value; end
            [value, reader] = reader.text(40, true, false);
            if reader.ok, obj.tid = value; end
            [parvalCount, reader] = reader.count(2, 21, 36);
            [value, reader] = reader.number(21, -9.99999999999999e+99, 9.99999999999999e+99, ...
                false, false);
            if reader.ok, obj.xuol = value; end
            [value, reader] = reader.number(21, -9.99999999999999e+99, 9.99999999999999e+99, ...
                false, false);
            if reader.ok, obj.yuol = value; end
            [value, reader] = reader.number(21, -9.99999999999999e+99, 9.99999999999999e+99, ...
                false, false);
            if reader.ok, obj.zuol = value; end
            [value, reader] = reader.number(21, -1, 1, ...
                false, false);
            if reader.ok, obj.xuxl = value; end
            [value, reader] = reader.number(21, -1, 1, ...
                false, false);
            if reader.ok, obj.xuyl = value; end
            [value, reader] = reader.number(21, -1, 1, ...
                false, false);
            if reader.ok, obj.xuzl = value; end
            [value, reader] = reader.number(21, -1, 1, ...
                false, false);
            if reader.ok, obj.yuxl = value; end
            [value, reader] = reader.number(21, -1, 1, ...
                false, false);
            if reader.ok, obj.yuyl = value; end
            [value, reader] = reader.number(21, -1, 1, ...
                false, false);
            if reader.ok, obj.yuzl = value; end
            [value, reader] = reader.number(21, -1, 1, ...
                false, false);
            if reader.ok, obj.zuxl = value; end
            [value, reader] = reader.number(21, -1, 1, ...
                false, false);
            if reader.ok, obj.zuyl = value; end
            [value, reader] = reader.number(21, -1, 1, ...
                false, false);
            if reader.ok, obj.zuzl = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.iro = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.irx = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.iry = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.irz = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.irxx = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.irxy = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.irxz = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.iryy = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.iryz = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.irzz = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.ico = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.icx = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.icy = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.icz = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.icxx = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.icxy = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.icxz = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.icyy = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.icyz = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.iczz = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.gxo = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.gyo = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.gzo = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.gxr = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.gyr = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.gzr = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.gs = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.gxx = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.gxy = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.gxz = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.gyx = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.gyy = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.gyz = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.gzx = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.gzy = value; end
            [value, reader] = reader.number(2, 1, 36, ...
                true, true);
            if reader.ok, obj.gzz = value; end
            count = parvalCount;
            [value, reader] = reader.numbers(count, 21, -9.99999999999999e+99, 9.99999999999999e+99, ...
                false, false);
            if reader.ok, obj.parval = value; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.RSMAPA());
        end
    end
end
