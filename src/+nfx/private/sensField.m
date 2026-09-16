function [value,valid] = sensField(number,word,index,geodeticType,angularUnit,dynamic) %#codegen
    %sensField - Encode one indexed SENSRB field from explicit typed storage
    info = sensFieldInfo(index,geodeticType,angularUnit);
    value = repmat(uint8('-'),1,info.width);
    valid = info.valid;
    if ~valid, return; end
    textFieldType = info.format == 'A' || info.format == 'D';
    if textFieldType
        valid = isempty(number) && ischar(word) && (isrow(word) || isempty(word)) && ...
            numel(word) <= info.width && all(word >= ' ' & word <= '~');
        if ~valid, return; end
        word = deblank(word);
        if isempty(strtrim(word)) || all(word == '-')
            valid = info.unknown && ~dynamic;
            return
        end
        switch index
            case {'02i','07e'}, valid = any(strcmp(word,{'Y','N'}));
            case '03a', valid = any(strcmp(word,{'mm','px'}));
            case '04a'
                valid = any(strcmp(word,{'Single Frame','Multi-Frame','Single MIDSI','Multi-MIDSI','Pushbroom','Whiskbroom'}));
            case '04b', valid = numel(word) == 3 && all(word >= '0' & word <= '9');
            case '03l', valid = numel(word) == 8 && partialDate14([word '------']);
        end
        if valid, value = textField(word,info.width); end
        return
    end
    valid = isempty(word) && (isempty(number) || (isa(number,'double') && isscalar(number) && isreal(number) && ~issparse(number)));
    if ~valid, return; end
    if isempty(number) || isnan(number)
        valid = info.unknown && ~dynamic;
        return
    end
    valid = isfinite(number) && number >= info.lower && number <= info.upper && ...
        (~info.positive || number > 0);
    if strcmp(index,'04k'), valid = valid && any(number == [0 2 4 5 6 8]); end
    if ~valid, return; end
    [value,valid] = sensNumber(number,info.width,info.format);
    if valid
        rounded = str2double(char(value));
        if info.format == 'N' && (rounded < info.lower || rounded > info.upper)
            % At an inclusive irrational boundary (for example pi radians),
            % choose the adjacent representable decimal inside the interval.
            point = find(value == uint8('.'),1);
            places = 0;
            if ~isempty(point), places = numel(value)-point; end
            direction = double(rounded < info.lower)-double(rounded > info.upper);
            [value,valid] = sensNumber(rounded+direction*10^(-places),info.width,info.format);
            rounded = str2double(char(value));
        end
        valid = valid && rounded >= info.lower && rounded <= info.upper && (~info.positive || rounded > 0);
    end
end
