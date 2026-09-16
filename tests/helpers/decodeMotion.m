function pixels = decodeMotion(segment,frames)
    %decodeMotion - Independently recover F/T blocks with scalar byte reads
    h = segment.fields; assert(any(h.imode == 'BFT'));
    type = 'uint8'; if h.nbpp == 16, type = 'uint16'; end
    pixels = zeros(h.nrows,h.ncols,h.bands,frames,type); cursor = 1;
    for br = 0:h.nbpc-1
        for bc = 0:h.nbpr-1
            for f = 1:frames
                for b = 1:h.bands
                    for r = 1:h.nppbv
                        for c = 1:h.nppbh
                            value = double(segment.data(cursor)); cursor = cursor+1;
                            if h.nbpp == 16, value = value*256+double(segment.data(cursor)); cursor = cursor+1; end
                            row = br*h.nppbv+r; col = bc*h.nppbh+c;
                            if row <= h.nrows && col <= h.ncols
                                pixels(row,col,b,f) = value;
                            else
                                assert(value == 0,'oracle:Padding','Every frame must have zero block padding.');
                            end
                        end
                    end
                end
            end
        end
    end
    assert(cursor == numel(segment.data)+1,'oracle:MotionLength','Unexpected motion data length.');
end
