function message = publishedTRECoverage(tag, payload) %#codegen
    %publishedTRECoverage - Identify unchecked relationships or nested content
    message = '';
    switch tag
        case {'RSMAPA', 'RSMDCA', 'RSMECA'}
            message = ['Payload fields are checked; complete model and ' ...
                'cross-image relationships for this RSM layout are unverified.'];
        case 'BCHIPA'
            message = ['Payload fields are checked; whole-series band ' ...
                'coverage and image relationships are unverified.'];
        case 'ATTPTA'
            message = ['Payload fields are checked; referenced-image ' ...
                'identities and point bounds are unverified.'];
        case 'NBLOCA'
            message = ['Payload fields are checked; offsets into the ' ...
                'associated compressed frame stream are unverified.'];
        case 'J2KLRB'
            message = ['Payload fields are checked; consistency with the ' ...
                'associated JPEG 2000 codestream is unverified.'];
        case 'CSEPHA'
            message = ['Payload fields are checked; complete ephemeris-series ' ...
                'and product-specific sample requirements are unverified.'];
        case 'PIXMTA'
            message = ['Payload fields are checked; associated-image ' ...
                'dimensions and band relationships are unverified.'];
        case 'CCINFA'
            [tre, ok] = nfx.CCINFA.deserialize(payload);
            if ok
                for k = 1:numel(tre.codes)
                    if ~isempty(tre.codes(k).detail)
                        message = ['Country-code detail bytes are preserved; ' ...
                            'XML schemas and GZIP content are unverified.'];
                        return
                    end
                end
            end
    end
end
