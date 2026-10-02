function value = fixtureAdditionalTRE(tag)
    %fixtureAdditionalTRE - Synthetic standards-extension metadata
    switch tag
        case 'GEOPSB'
            value = nfx.GEOPSB();
        case 'BNDPLC'
            value = nfx.BNDPLC(struct('lon', [0 0 1], ...
                'lat', [0 1 0], 'height', []));
        case 'XMLDCA'
            value = nfx.XMLDCA(tredata=uint8('<a/>')).updateCRC();
        case 'SECURA'
            value = nfx.SECURA(fdattim='20260915120000', ...
                secstd='ARH.XML', security=uint8('<a/>'));
        case 'PIXQLA'
            value = nfx.PIXQLA(all_images=true, pq_condition='Bad');
        case 'CSCCGA'
            value = nfx.CSCCGA(ccg_source='PAN', reg_sensor='PAN', ...
                origin_line=1, origin_sample=1, as_cell_size=1, ...
                cs_cell_size=1, ccg_max_line=2, ccg_max_sample=2);
        case 'MSTGTA'
            value = nfx.MSTGTA(tgt_num=0);
        case 'BLOCKA'
            value = nfx.BLOCKA(block_instance=1, l_lines=5);
        case 'ENGRDA'
            entry = nfx.ENGRDA.entry('A', uint16([1 256; 65535 2]));
            value = nfx.ENGRDA(resrc='Source', redata=entry);
        otherwise
            error('nfx:TestFixture', 'Unknown additional TRE fixture.');
    end
end
