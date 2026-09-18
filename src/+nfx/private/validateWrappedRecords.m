function [ok, status] = validateWrappedRecords(records) %#codegen
    %validateWrappedRecords - Validate all leaves using a homogeneous queue
    %   Nested wrappers remain encoded; no recursive object graph is built.
    ok = true;
    status = decodeStatus();
    queue = records;
    identity = 0;
    if ~isempty(queue)
        identity = max([queue.id]);
    end
    while ~isempty(queue)
        selected = queue([queue.id] == queue(1).id);
        queue([queue.id] == queue(1).id) = [];
        tag = selected(1).tag;
        if any(strcmp(tag, {'FSYNWA', 'FASYWA', 'CONTXA'}))
            [children, reader] = readWrapperChildren( ...
                tag, selected(1).payload);
            if ~reader.ok
                ok = false;
                status = decodeStatus(reader.code, ...
                    reader.message, reader.position);
                return
            end
            for k = 1:numel(children)
                children(k).id = children(k).id + identity;
            end
            identity = max([children.id]);
            queue = [queue children]; %#ok<AGROW>
            continue
        end
        switch tag
            case 'ACFTB '
                [~, ok, status] = nfx.ACFTB.deserialize(selected(1).payload);
            case 'AIMIDB'
                [~, ok, status] = nfx.AIMIDB.deserialize(selected(1).payload);
            case 'BANDSB'
                [~, ok, status] = nfx.BANDSB.deserialize(selected(1).payload);
            case 'CAMSDA'
                [~, ok, status] = nfx.CAMSDA.deserialize(selected(1).payload);
            case 'CSCRNA'
                [~, ok, status] = nfx.CSCRNA.deserialize(selected(1).payload);
            case 'CSDIDA'
                [~, ok, status] = nfx.CSDIDA.deserialize(selected(1).payload);
            case 'CSEXRB'
                [~, ok, status] = nfx.CSEXRB.deserialize(selected(1).payload);
            case 'CSRLSB'
                [~, ok, status] = nfx.CSRLSB.deserialize(selected(1).payload);
            case 'CSWRPB'
                [~, ok, status] = nfx.CSWRPB.deserialize(selected(1).payload);
            case 'FCRNSA'
                [~, ok, status] = nfx.FCRNSA.deserialize(selected(1).payload);
            case 'FREESA'
                [~, ok, status] = nfx.FREESA.deserialize(selected(1).payload);
            case 'HISTOA'
                [~, ok, status] = nfx.HISTOA.deserialize(selected(1).payload);
            case 'ICHIPB'
                [~, ok, status] = nfx.ICHIPB.deserialize(selected(1).payload);
            case 'ILLUMB'
                [~, ok, status] = nfx.ILLUMB.deserialize(selected(1).payload);
            case 'J2KLRA'
                [~, ok, status] = nfx.J2KLRA.deserialize(selected(1).payload);
            case 'MATESA'
                [~, ok, status] = nfx.MATESA.deserialize(selected(1).payload);
            case 'MICIDA'
                [~, ok, status] = nfx.MICIDA.deserialize(selected(1).payload);
            case 'MIMCSA'
                [~, ok, status] = nfx.MIMCSA.deserialize(selected(1).payload);
            case 'MTIMFA'
                [~, ok, status] = nfx.MTIMFA.deserialize(selected(1).payload);
            case 'MTIMSA'
                [~, ok, status] = nfx.MTIMSA.deserialize(selected(1).payload);
            case 'RPC00B'
                [~, ok, status] = nfx.RPC00B.deserialize(selected(1).payload);
            case 'RSMAPB'
                [~, ok, status] = nfx.RSMAPB.deserialize(selected(1).payload);
            case 'RSMDCB'
                [~, ok, status] = nfx.RSMDCB.deserialize(selected(1).payload);
            case 'RSMECB'
                [~, ok, status] = nfx.RSMECB.deserialize(selected(1).payload);
            case 'RSMGGA'
                [~, ok, status] = nfx.RSMGGA.deserialize(selected(1).payload);
            case 'RSMGIA'
                [~, ok, status] = nfx.RSMGIA.deserialize(selected(1).payload);
            case 'RSMIDA'
                [~, ok, status] = nfx.RSMIDA.deserialize(selected(1).payload);
            case 'RSMPCA'
                [~, ok, status] = nfx.RSMPCA.deserialize(selected(1).payload);
            case 'RSMPIA'
                [~, ok, status] = nfx.RSMPIA.deserialize(selected(1).payload);
            case 'SENSRB'
                [~, ok, status] = nfx.SENSRB.deserializeRecords(selected);
            case 'TMINTA'
                [~, ok, status] = nfx.TMINTA.deserialize(selected(1).payload);
            otherwise
                % Framing was checked by the reader. Keep unknown bytes.
                ok = true;
        end
        if ~ok
            return
        end
    end
end
