function [obj, reader] = readGLASCorrelation(reader) %#codegen
    %readGLASCorrelation - Decode bounded supplied sensor error metadata
    obj = nfx.GLASCorrelation();
    [value, reader] = reader.number(1, 0, 2, true);
    if reader.ok, obj.spdcf_fam = value; end
    [value, reader] = reader.number(5, 0, 1, false);
    if reader.ok, obj.spdcf_weight = value; end
    if reader.ok && obj.spdcf_fam == 0
        [value, reader] = reader.number(8, 1e-06, 1, false);
        if reader.ok, obj.fp_a = value; end
        [value, reader] = reader.number(8, 0, 1, false);
        if reader.ok, obj.fp_alpha = value; end
        [value, reader] = reader.number(9, 0, 10, false);
        if reader.ok, obj.fp_beta = value; end
        [value, reader] = reader.number(21, 1e-06, 9.99999999999999e99, false);
        if reader.ok, obj.fp_t = value; end
    elseif reader.ok && obj.spdcf_fam == 1
        [count, reader] = reader.count(2, 29, 10);
        correlations = zeros(1, count); tau = zeros(1, count);
        for k = 1:count
            [correlations(k), reader] = reader.number(8, 0, 1);
            [tau(k), reader] = reader.number(21, 0, 9.99999999999999e99);
        end
        if reader.ok, obj.pl_max_cor = correlations; obj.pl_tau_max_cor = tau; end
    elseif reader.ok
        [value, reader] = reader.number(8, 1e-06, 1, false);
        if reader.ok, obj.dc_a = value; end
        [value, reader] = reader.number(21, 1e-06, 9.99999999999999e99, false);
        if reader.ok, obj.dc_t = value; end
        [value, reader] = reader.number(21, 1e-06, 9.99999999999999e99, false);
        if reader.ok, obj.dc_p = value; end
    end
end
