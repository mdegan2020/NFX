function result = inspectNITF(filename)
    %inspectNITF - Independently parse the candidate's NITF bytes and pixels
    % This test oracle uses JBP offsets and scalar reads, not NFX layout helpers.
    data = readBytes(filename);
    assert(isequal(char(data(1:9)), 'NITF02.10'), 'oracle:Magic', 'Bad magic.');
    number = @(first,count) str2double(char(data(first:first+count-1)));
    result.clevel = number(10,2);
    result.fl = number(343,12);
    result.hl = number(355,6);
    result.numi = number(361,3);
    result.lish = number(364,6);
    result.li = number(370,10);
    assert(result.numi == 1 && result.hl == 404, 'oracle:Header', 'Unexpected file layout.');
    assert(result.fl == numel(data), 'oracle:Length', 'FL disagrees with actual bytes.');
    assert(result.fl == result.hl+result.lish+result.li, 'oracle:Length', 'Segment lengths disagree.');
    assert(isequal(char(data(380:404)), repmat('0',1,25)), 'oracle:Header', 'Unexpected segments or extensions.');
    h = data(result.hl+1:result.hl+result.lish);
    result.fileHeader = data(1:404);
    result.imageHeader = h;
    n = @(first,count) str2double(char(h(first:first+count-1)));
    assert(isequal(char(h(1:2)), 'IM'), 'oracle:Image', 'Bad image marker.');
    result.nrows = n(334,8);
    result.ncols = n(342,8);
    result.irep = strtrim(char(h(353:360)));
    result.icat = strtrim(char(h(361:368)));
    result.abpp = n(369,2);
    assert(isequal(char(h(350:352)), 'INT'), 'oracle:Image', 'Unexpected PVTYPE.');
    assert(isequal(char(h(372:375)), ' 0NC'), 'oracle:Image', 'Unexpected optional fields or compression.');
    bands = n(376,1);
    cursor = 377;
    if bands == 0
        bands = n(cursor,5);
        assert(bands > 9, 'oracle:Bands', 'XBANDS must exceed nine.');
        cursor = cursor + 5;
    end
    result.bands = bands;
    result.bandRecords = reshape(h(cursor:cursor+13*bands-1),13,bands).';
    cursor = cursor+13*bands;
    assert(isequal(char(h(cursor:cursor+1)), '0B'), 'oracle:Image', 'Unexpected IMODE.');
    result.nbpr = n(cursor+2,4);
    result.nbpc = n(cursor+6,4);
    result.nppbh = n(cursor+10,4);
    result.nppbv = n(cursor+14,4);
    result.nbpp = n(cursor+18,2);
    assert(isequal(char(h(cursor+20:cursor+35)), '0010000000000000'), 'oracle:Image', 'Invalid display placement.');
    assert(isequal(char(h(cursor+36:cursor+44)), '1.0 00000'), 'oracle:Image', 'Invalid magnification or UDID.');
    extensionLength = n(cursor+45,5);
    cursor = cursor+50;
    result.rpc = zeros(1,0,'uint8');
    if extensionLength > 0
        assert(extensionLength == 1055, 'oracle:TRE', 'Unexpected extension area length.');
        assert(isequal(char(h(cursor:cursor+13)), '000RPC00B01041'), 'oracle:TRE', 'Invalid TRE framing.');
        result.rpc = h(cursor+14:cursor+1054);
        cursor = cursor+extensionLength;
    end
    assert(cursor == numel(h)+1, 'oracle:Image', 'Subheader length disagrees.');
    bytesPerPixel = result.nbpp/8;
    assert(ismember(bytesPerPixel,[1 2]), 'oracle:Pixels', 'Unsupported sample width.');
    if bytesPerPixel == 1
        result.pixels = zeros(result.nrows,result.ncols,bands,'uint8');
    else
        result.pixels = zeros(result.nrows,result.ncols,bands,'uint16');
    end
    offset = result.hl+result.lish+1;
    for blockRow = 0:result.nbpc-1
        for blockCol = 0:result.nbpr-1
            for band = 1:bands
                for row = 1:result.nppbv
                    for col = 1:result.nppbh
                        sample = double(data(offset));
                        if bytesPerPixel == 2
                            sample = 256*sample + double(data(offset+1));
                        end
                        offset = offset+bytesPerPixel;
                        r = blockRow*result.nppbv+row;
                        c = blockCol*result.nppbh+col;
                        if r <= result.nrows && c <= result.ncols
                            result.pixels(r,c,band) = sample;
                        else
                            assert(sample == 0, 'oracle:Padding', 'Nonzero edge padding.');
                        end
                    end
                end
            end
        end
    end
    assert(offset == numel(data)+1, 'oracle:Pixels', 'Unexpected trailing or missing data.');
end
