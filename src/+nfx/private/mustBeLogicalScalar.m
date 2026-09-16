function mustBeLogicalScalar(value) %#codegen
    %mustBeLogicalScalar - Require a logical scalar without numeric coercion
    if ~islogical(value) || ~isscalar(value)
        error('nfx:LogicalScalar','Expected a logical scalar.');
    end
end
