classdef MATESATest < NfxTest
    properties (TestParameter)
        invalidText = {char(0),char(127),char(159),char(256),42,missing,["a" "b"]}
        badRelation = {'PRE_PARENT','POST_STEREO','PRE_POST_DARKCOLLECT','UNKNOWN'}
    end
    methods (Test)
        function minimumRecordAndLiteralFieldLengths(t)
            mate = struct('source','','mate_type','FTITLE','mate_id','PARENT');
            groups = struct('relationship','PARENT','mates',mate);
            value = nfx.MATESA(cur_source='SENSOR',cur_mate_type='FTITLE', ...
                cur_file_id='CHILD',groups=groups);
            encoded = value.payload();
            t.verifyEqual(value.cur_file_id_len,5);
            t.verifyEqual(value.num_groups,1);
            t.verifyEqual(value.num_mates,1);
            t.verifyEqual(value.cel,167);
            t.verifyEqual(char(encoded(1:58)), ['SENSOR' repmat(' ',1,36) 'FTITLE' repmat(' ',1,10)]);
            t.verifyEqual(char(encoded(59:71)), '0005CHILD0001');
            t.verifyEqual(char(encoded(72:99)), ['PARENT' repmat(' ',1,18) '0001']);
            t.verifyEqual(char(encoded(142:167)), ['FTITLE' repmat(' ',1,10) '0006PARENT']);
            value.cur_file_id = 'C';
            value.groups(1).mates.mate_id = 'P';
            t.verifyEqual(value.cel,158);
        end
        function ecsBytesAndSnapshotOrder(t)
            mate = struct('source',char([65 233]),'mate_type','DOCID','mate_id','first');
            second = mate; second.mate_id = 'second';
            groups = struct('relationship','REFERENCE','mates',[mate second]);
            value = nfx.MATESA(cur_source=string(char([66 255])),cur_mate_type='DOCID', ...
                cur_file_id='current',groups=groups);
            file = fixtureFile()+value;
            value.groups(1).mates(1).mate_id = 'changed';
            name = fullfile(t.folder,'mates.ntf');
            file.write(name);
            parsed = inspectContainer(name);
            t.verifyEqual(parsed.tres(1).tag,'MATESA');
            t.verifyEqual(parsed.tres(1).payload(1:2),uint8([66 255]));
            t.verifyTrue(contains(char(parsed.tres(1).payload),'0005first'));
            t.verifyTrue(contains(char(parsed.tres(1).payload),'0006second'));
            t.verifyFalse(contains(char(parsed.tres(1).payload),'changed'));
        end
        function invalidECSIsNotSubstituted(t, invalidText)
            t.verifyError(@() nfx.MATESA(cur_source=invalidText), 'nfx:ECSText');
        end
        function modifiersAreRestricted(t, badRelation)
            mate = struct('source','','mate_type','DOCID','mate_id','id');
            value = nfx.MATESA(cur_mate_type='DOCID',cur_file_id='current', ...
                groups=struct('relationship',badRelation,'mates',mate));
            t.verifyFalse(value.validate().valid);
            value.groups.relationship = 'PRE_DARKCOLLECT';
            t.verifyTrue(value.validate().valid);
            value.groups.relationship = 'POST_GEOPOSITION_CALIB';
            t.verifyTrue(value.validate().valid);
        end
        function malformedGroupsAndMissingIdentifiers(t)
            t.verifyError(@() nfx.MATESA(groups=struct()), 'nfx:MateGroups');
            t.verifyError(@() nfx.MATESA(groups=struct('relationship','PARENT','mates',42)), 'nfx:MateGroups');
            t.verifyFalse(nfx.MATESA().validate().valid);
            mate = struct('source','','mate_type','UUID','mate_id','bad');
            value = nfx.MATESA(cur_mate_type='FTITLE',cur_file_id='current', ...
                groups=struct('relationship','PARENT','mates',mate));
            t.verifyFalse(value.validate().valid);
            value.groups.mates.mate_id = '01234567-89ab-cdef-0123-456789abcdef';
            t.verifyTrue(value.validate().valid);
            value.groups.mates.mate_id = '01234567-89ab-cdef-0123-456789abcdeg';
            t.verifyFalse(value.validate().valid);
        end
        function largeMateGroupsRequireFurtherInstances(t)
            mate = struct('source','','mate_type','FILENAME','mate_id',repmat('x',1,9999));
            value = nfx.MATESA(cur_mate_type='FTITLE',cur_file_id='C', ...
                groups=struct('relationship','PARENT','mates',repmat(mate,1,9)));
            t.verifyTrue(value.validate().valid);
            t.verifyEqual(value.cel,90644);
            value.groups.mates(10) = mate;
            t.verifyFalse(value.validate().valid);
            t.verifyError(@() value.payload(), 'nfx:Invalid');
        end
    end
end
