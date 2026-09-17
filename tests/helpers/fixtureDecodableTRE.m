function value = fixtureDecodableTRE(tag)
    %fixtureDecodableTRE - Supply synthetic values for concrete reader tests
    switch tag
        case 'RPC00B'
            value = fixtureRPC();
        case 'ACFTB'
            value = fixtureAircraft();
        case 'AIMIDB'
            value = nfx.AIMIDB(acquisition_date='20260917120000');
        case {'CSCRNA', 'FCRNSA'}
            value = fixtureCorners(tag);
        case 'ICHIPB'
            value = fixtureChip();
        case 'FREESA'
            value = nfx.FREESA(42);
        case 'MIMCSA'
            value = nfx.MIMCSA(layer_id='LAYER', mi_req_decoder='NC', ...
                mi_req_profile='Not Applicable', mi_req_level='N/A');
        case 'CAMSDA'
            value = nfx.CAMSDA( ...
                camera_sets=struct('cameras', fixtureCamera()));
        case 'MICIDA'
            id = fixtureCamera().camera_id;
            core = nfx.MICIDA.coreIdentifier(32, {id});
            value = nfx.MICIDA(cameras=nfx.MICIDA.camera(id, core));
        case 'MTIMSA'
            value = fixtureTiming();
        case 'MTIMFA'
            value = fixtureTemporalMapping();
        case 'TMINTA'
            value = nfx.TMINTA(struct('time_interval_index', 7, ...
                'start_timestamp', '20260915120000.000000001', ...
                'end_timestamp', '20260915120001.000000001'));
        case 'MATESA'
            mate = struct('source', 'SENSOR', 'mate_type', 'DOCID', ...
                'mate_id', 'parent ');
            value = nfx.MATESA(cur_source='SENSOR', cur_mate_type='DOCID', ...
                cur_file_id='current ', ...
                groups=struct('relationship', 'PARENT', 'mates', mate));
        case 'CSRLSB'
            value = nfx.CSRLSB(rs_dt_1=[1 2; 3 4], ...
                rs_dt_2=[5 6; 7 8], rs_dt_3=[9 10; 11 12], ...
                rs_dt_4=[13 14; 15 16]);
        case 'RSMIDA'
            value = fixtureRSMIdentification();
        case 'RSMPCA'
            value = fixturePolynomial();
        case 'RSMGGA'
            value = fixtureRSMGrid();
        case 'RSMAPB'
            value = nfx.RSMAPB(edition='E', tid='T', ...
                parameters=fixtureRSMParameters(), parval=[1 -2]);
        case 'RSMDCB'
            value = nfx.RSMDCB(iid='A', edition='E', tid='T', ...
                parameters=fixtureRSMParameters(), ...
                blocks=[nfx.RSMDCB.block('A', eye(2)) ...
                        nfx.RSMDCB.block('B', [1 2 3; 4 5 6])]);
        case 'RSMECB'
            correlation = nfx.RSMCorrelation(corseg=[1 0], tauseg=[0 1]);
            value = nfx.RSMECB(edition='E', tid='T', cvdate='20240229', ...
                parameters=fixtureRSMParameters(), ...
                subgroups=nfx.RSMECB.subgroup(eye(2), 0, correlation), ...
                map=eye(2), urr=4, urc=2, ucc=1, ...
                row_correlation=correlation, column_correlation=correlation);
        case 'BANDSB'
            value = fullBandMetadata();
        case 'ILLUMB'
            value = fullIllumination();
        case 'HISTOA'
            value = nfx.HISTOA(systype='TBD', event=fullHistoryEvent());
        case 'CSEXRB'
            value = fixtureCSEXRB('F');
        case 'CSWRPB'
            value = nfx.CSWRPB(sensor_type='S', ...
                warp_data=fixtureWarpingSet());
        case 'SENSRB'
            value = fullSensor();
        case 'CSDIDA'
            value = nfx.CSDIDA(platform_code='WV', vehicle_id=3, ...
                pass=2, operation=17, sensor_id='GA', product_id='P2', ...
                time='20260915120000', process_time='20260915120001', ...
                software_version_number='NFX TEST');
        case {'RSMPIA', 'RSMGIA'}
            if strcmp(tag, 'RSMPIA')
                value = nfx.RSMPIA(edition='E', rnis=1, cnis=1, ...
                    rssiz=5, cssiz=7);
                prefix = '';
            else
                value = nfx.RSMGIA(edition='E', grnis=1, gcnis=1, ...
                    grssiz=5, gcssiz=7);
                prefix = 'g';
            end
            for axis = 'rc'
                for term = {'0', 'x', 'y', 'z', 'xx', 'xy', 'xz', ...
                        'yy', 'yz', 'zz'}
                    value.([prefix axis term{1}]) = 0;
                end
            end
        case 'FSYNWA'
            value = nfx.FSYNWA() + fixtureRPC();
        case 'FASYWA'
            value = nfx.FASYWA( ...
                start_timestamp='20260915120000.000000000', ...
                end_timestamp='20260915120001.000000000') + ...
                fullIllumination();
        case 'CONTXA'
            value = nfx.CONTXA(context_type='FR', index_list='1,3-5, ') + ...
                fixtureRPC();
        case 'J2KLRA'
            value = nfx.J2KLRA();
            value.orig = 0;
            value.nlevels_o = 5;
            value.nbands_o = 3;
            value.layer_id = 0:19;
            value.bitrate = [0.03125 0.0625 0.125 0.25 0.5 0.6 0.7 ...
                0.8 0.9 1 1.1 1.2 1.3 1.5 1.7 2 2.3 2.8 3.5 8];
        otherwise
            error('nfx:TestFixture', 'Unknown fixture tag.');
    end
end
