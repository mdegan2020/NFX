function values = nativeCases(name, folder)
    %nativeCases - Make small asymmetric files with an independent byte oracle
    % These tiny host fixtures deliberately concatenate varying case sizes.
    %#ok<*AGROW>
    type = 'uint8'; if endsWith(name, '16'), type = 'uint16'; end
    item = struct('name', '', 'args', {{}}, 'expected', struct());
    values = repmat(item, 1, 0);
    header = nfx.FileHeader(ostaid='CODERTEST', fdt='20260917120100', ...
        fsclas='U', ftitle='Synthetic portable Coder inputs');
    for variant = 0:3
        file = nfx.File(header=header); samples = zeros(1, 0, type);
        expectedStorage = zeros(1, 0, 'uint8'); images = 1 + (variant == 3);
        if variant == 0
            images = 0;
            file = file + nfx.TextSegment('No images', header=nfx.TextHeader( ...
                textid='NOTE', txtdt='20260917120000', tsclas='U'));
        end
        for imageIndex = 1:images
            bands = 1 + (variant == 3); frames = 1 + (variant >= 2);
            data = reshape(cast(1:2 * 3 * bands * frames, type), 3, 2, bands, frames);
            data = permute(data, [2 1 3 4]);
            if strcmp(type, 'uint16'), data = data + uint16(1000); end
            representation = 'MONO'; category = 'VIS';
            if bands > 1, representation = 'MULTI'; category = 'MS'; end
            if frames > 1, category = [category '.M']; end
            h = nfx.ImageHeader(iid1='CODER', idatim='20260917120000', ...
                isclas='U', irep=representation, icat=category, nppbh=2, nppbv=2);
            image = nfx.ImageSegment(data, header=h);
            if frames > 1
                timing = nfx.MTIMSA(image_seg_index=imageIndex, layer_id='SYNTHETIC', ...
                    camera_set_index=1, camera_id='10000000-0000-4000-8000-000000000001', ...
                    time_interval_index=1, temp_block_index=imageIndex, nominal_frame_rate=25, ...
                    base_timestamp='20260917120000.000000001', dt_multiplier=uint64(1000000), ...
                    number_frames=frames, dt=uint64(40));
                image = image + timing;
            end
            file = file + image; samples = [samples reshape(data, 1, [])];
            expectedStorage = [expectedStorage scalarByteOracle(data)];
        end
        filename = fullfile(folder, sprintf('%s_%d.ntf', name, variant));
        file.write(filename, Overwrite=true);
        fid = fopen(filename, 'rb'); cleanup = onCleanup(@() fclose(fid));
        raw = reshape(fread(fid, Inf, '*uint8'), 1, []); clear cleanup
        % This fixture parser uses fixed NITF table positions, independently
        % of indexNITF and the production pixel block encoder.
        length = str2double(char(raw(355:360))); headers = raw([1:9 12:342]);
        storage = zeros(1, 0, 'uint8'); at = length + 1; table = 364;
        for k = 1:images
            subheader = str2double(char(raw(table:table + 5)));
            count = str2double(char(raw(table + 6:table + 15))); table = table + 16;
            headers = [headers raw(at:at + subheader - 1)]; at = at + subheader;
            storage = [storage raw(at:at + count - 1)]; at = at + count;
        end
        assert(isequal(storage, expectedStorage), 'nfxkit:ByteOracle', ...
            'Source writer bytes disagree with the independent pixel oracle.');
        expected = struct('ok', true, 'code', 'OK', 'samples', samples);
        if startsWith(name, 'native')
            expected.headers = headers; expected.storage = expectedStorage;
            expected.clevel = str2double(char(raw(10:11)));
        else
            expected.header = raw(1:length);
        end
        values(end + 1) = struct('name', sprintf('layout%d', variant), ...
            'args', {{raw}}, 'expected', expected);
    end
    values(end + 1) = struct('name', 'truncated', 'args', {{raw(1:end - 1)}}, ...
        'expected', struct('ok', false, 'code', 'MalformedFile'));
end

function bytes = scalarByteOracle(data)
    bytes = zeros(1, 0, 'uint8');
    for left = [1 3]
        for frame = 1:size(data, 4)
            for band = 1:size(data, 3)
                for row = 1:2
                    for col = left:left + 1
                        value = zeros(1, 'like', data);
                        if col <= 3, value = data(row, col, band, frame); end
                        if isa(data, 'uint16')
                            % TYPECAST/SWAPBYTES is independent of the encoder's
                            % bit-shift implementation.
                            [~, ~, endian] = computer;
                            if endian == 'L', value = swapbytes(value); end
                            bytes = [bytes typecast(value, 'uint8')];
                        else
                            bytes(end + 1) = value;
                        end
                    end
                end
            end
        end
    end
end
