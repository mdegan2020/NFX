function mustBeRSMNumber(value) %#codegen
    %mustBeRSMNumber - Accept an ordinary double metadata scalar or unset NaN
    mustBeMetadata(value,-9.99999999999999e99,9.99999999999999e99,false);
end
