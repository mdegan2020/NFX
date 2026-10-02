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
            % BEGIN published TRE decoding
            case 'ACCHZB'
                [~, ok, status] = nfx.ACCHZB.deserialize( ...
                    selected(1).payload);
            case 'ACCPOB'
                [~, ok, status] = nfx.ACCPOB.deserialize( ...
                    selected(1).payload);
            case 'ACCVTB'
                [~, ok, status] = nfx.ACCVTB.deserialize( ...
                    selected(1).payload);
            case 'ASTORA'
                [~, ok, status] = nfx.ASTORA.deserialize( ...
                    selected(1).payload);
            case 'ATTPTA'
                [~, ok, status] = nfx.ATTPTA.deserialize( ...
                    selected(1).payload);
            case 'BCHIPA'
                [~, ok, status] = nfx.BCHIPA.deserialize( ...
                    selected(1).payload);
            case 'BNDPLB'
                [~, ok, status] = nfx.BNDPLB.deserialize( ...
                    selected(1).payload);
            case 'CCINFA'
                [~, ok, status] = nfx.CCINFA.deserialize( ...
                    selected(1).payload);
            case 'COMNTA'
                [~, ok, status] = nfx.COMNTA.deserialize( ...
                    selected(1).payload);
            case 'CSEPHA'
                [~, ok, status] = nfx.CSEPHA.deserialize( ...
                    selected(1).payload);
            case 'CSEXRA'
                [~, ok, status] = nfx.CSEXRA.deserialize( ...
                    selected(1).payload);
            case 'CSPROA'
                [~, ok, status] = nfx.CSPROA.deserialize( ...
                    selected(1).payload);
            case 'CSSFAA'
                [~, ok, status] = nfx.CSSFAA.deserialize( ...
                    selected(1).payload);
            case 'EXOPTA'
                [~, ok, status] = nfx.EXOPTA.deserialize( ...
                    selected(1).payload);
            case 'EXPLTB'
                [~, ok, status] = nfx.EXPLTB.deserialize( ...
                    selected(1).payload);
            case 'FACCBB'
                [~, ok, status] = nfx.FACCBB.deserialize( ...
                    selected(1).payload);
            case 'GEOLOB'
                [~, ok, status] = nfx.GEOLOB.deserialize( ...
                    selected(1).payload);
            case 'GRDPSB'
                [~, ok, status] = nfx.GRDPSB.deserialize( ...
                    selected(1).payload);
            case 'IOMAPA'
                [~, ok, status] = nfx.IOMAPA.deserialize( ...
                    selected(1).payload);
            case 'ISACPA'
                [~, ok, status] = nfx.ISACPA.deserialize( ...
                    selected(1).payload);
            case 'ISASIA'
                [~, ok, status] = nfx.ISASIA.deserialize( ...
                    selected(1).payload);
            case 'ISATPA'
                [~, ok, status] = nfx.ISATPA.deserialize( ...
                    selected(1).payload);
            case 'J2KLRB'
                [~, ok, status] = nfx.J2KLRB.deserialize( ...
                    selected(1).payload);
            case 'MAPLOB'
                [~, ok, status] = nfx.MAPLOB.deserialize( ...
                    selected(1).payload);
            case 'MENSRB'
                [~, ok, status] = nfx.MENSRB.deserialize( ...
                    selected(1).payload);
            case 'MITOCA'
                [~, ok, status] = nfx.MITOCA.deserialize( ...
                    selected(1).payload);
            case 'MTIRPB'
                [~, ok, status] = nfx.MTIRPB.deserialize( ...
                    selected(1).payload);
            case 'NBLOCA'
                [~, ok, status] = nfx.NBLOCA.deserialize( ...
                    selected(1).payload);
            case 'PATCHB'
                [~, ok, status] = nfx.PATCHB.deserialize( ...
                    selected(1).payload);
            case 'PIAEQA'
                [~, ok, status] = nfx.PIAEQA.deserialize( ...
                    selected(1).payload);
            case 'PIAEVA'
                [~, ok, status] = nfx.PIAEVA.deserialize( ...
                    selected(1).payload);
            case 'PIAIMC'
                [~, ok, status] = nfx.PIAIMC.deserialize( ...
                    selected(1).payload);
            case 'PIAPEB'
                [~, ok, status] = nfx.PIAPEB.deserialize( ...
                    selected(1).payload);
            case 'PIAPRD'
                [~, ok, status] = nfx.PIAPRD.deserialize( ...
                    selected(1).payload);
            case 'PIATGB'
                [~, ok, status] = nfx.PIATGB.deserialize( ...
                    selected(1).payload);
            case 'PIXMTA'
                [~, ok, status] = nfx.PIXMTA.deserialize( ...
                    selected(1).payload);
            case 'PRJPSB'
                [~, ok, status] = nfx.PRJPSB.deserialize( ...
                    selected(1).payload);
            case 'REGPTB'
                [~, ok, status] = nfx.REGPTB.deserialize( ...
                    selected(1).payload);
            case 'REGPTC'
                [~, ok, status] = nfx.REGPTC.deserialize( ...
                    selected(1).payload);
            case 'RELCCA'
                [~, ok, status] = nfx.RELCCA.deserialize( ...
                    selected(1).payload);
            case 'RSMAPA'
                [~, ok, status] = nfx.RSMAPA.deserialize( ...
                    selected(1).payload);
            case 'RSMDCA'
                [~, ok, status] = nfx.RSMDCA.deserialize( ...
                    selected(1).payload);
            case 'RSMECA'
                [~, ok, status] = nfx.RSMECA.deserialize( ...
                    selected(1).payload);
            case 'S2EVPA'
                [~, ok, status] = nfx.S2EVPA.deserialize( ...
                    selected(1).payload);
            case 'SECTGA'
                [~, ok, status] = nfx.SECTGA.deserialize( ...
                    selected(1).payload);
            case 'SNSPSB'
                [~, ok, status] = nfx.SNSPSB.deserialize( ...
                    selected(1).payload);
            case 'SOURCB'
                [~, ok, status] = nfx.SOURCB.deserialize( ...
                    selected(1).payload);
            case 'STDIDC'
                [~, ok, status] = nfx.STDIDC.deserialize( ...
                    selected(1).payload);
            case 'STREOB'
                [~, ok, status] = nfx.STREOB.deserialize( ...
                    selected(1).payload);
            case 'SYSIDA'
                [~, ok, status] = nfx.SYSIDA.deserialize( ...
                    selected(1).payload);
            case 'USE00A'
                [~, ok, status] = nfx.USE00A.deserialize( ...
                    selected(1).payload);
            % END published TRE decoding
            case 'GEOPSB'
                [~, ok, status] = nfx.GEOPSB.deserialize(selected(1).payload);
            case 'BNDPLC'
                [~, ok, status] = nfx.BNDPLC.deserialize(selected(1).payload);
            case 'XMLDCA'
                [~, ok, status] = nfx.XMLDCA.deserialize(selected(1).payload);
            case 'SECURA'
                [~, ok, status] = nfx.SECURA.deserialize(selected(1).payload);
            case 'PIXQLA'
                [~, ok, status] = nfx.PIXQLA.deserialize(selected(1).payload);
            case 'CSCCGA'
                [~, ok, status] = nfx.CSCCGA.deserialize(selected(1).payload);
            case 'MSTGTA'
                [~, ok, status] = nfx.MSTGTA.deserialize(selected(1).payload);
            case 'BLOCKA'
                [~, ok, status] = nfx.BLOCKA.deserialize(selected(1).payload);
            case 'ENGRDA'
                [~, ok, status] = nfx.ENGRDA.deserialize(selected(1).payload);
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
