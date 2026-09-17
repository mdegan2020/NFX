classdef (TestTags = {'OpenJPEG'}) OpenJPEGTest < NfxTest
    properties
        encoder
        sample
    end
    properties (TestParameter)
        profile = {'NPJE','EPJE'}
        pixelCase = struct( ...
            'mono8',struct('shape',[1030 1032 1],'type','uint8','rep','MONO','range',256), ...
            'mono16',struct('shape',[1030 1032 1],'type','uint16','rep','MONO','range',65536), ...
            'rgb8',struct('shape',[1030 1032 3],'type','uint8','rep','RGB','range',256), ...
            'rgb16',struct('shape',[1030 1032 3],'type','uint16','rep','RGB','range',65536), ...
            'msi16',struct('shape',[1030 1032 5],'type','uint16','rep','MULTI','range',4096), ...
            'xbands',struct('shape',[64 65 10],'type','uint8','rep','MULTI','range',256), ...
            'zero',struct('shape',[32 32 1],'type','uint16','rep','MONO','range',1), ...
            'thinEdges',struct('shape',[1025 1025 1],'type','uint8','rep','MONO','range',256))
        corruption = {'soc','sizLength','cod','qcd','tlm','sot','plt','eoc','trailing','profile','order'}
    end
    methods (TestClassSetup)
        function configureEncoder(t)
            t.encoder = getenv('NFX_OPENJPEG');
            t.assertTrue(isfile(t.encoder),'Set NFX_OPENJPEG or use runTests(OpenJPEG=ENCODER).');
            t.sample = nfx.JPEG2000(reshape(uint8(mod(0:2047,256)),32,64),t.encoder,Profile='EPJE');
        end
    end
    methods (Test)
        function losslessNitfAndMarkerOracle(t,profile,pixelCase)
            data = makePixels(pixelCase);
            image = makeImage(data,pixelCase.rep).compress(t.encoder,Profile=profile);
            file = makeFile(image);
            filename = fullfile(t.folder,'compressed.ntf');
            file.write(filename);
            parsed = inspectContainer(filename);
            raw = fullfile(t.folder,'image.j2c');
            putBytes(raw,parsed.images.data);
            oracle = inspectCodestream(raw);
            t.verifyEqual(nitfread(filename),data);
            t.verifyEqual(imread(raw),data);
            t.verifyEqual(image.data,data);
            t.verifyEqual(parsed.images.fields.ic,'C8');
            t.verifyEqual(parsed.images.fields.comrat,image.compression.comrat);
            t.verifyEqual(parsed.images.fields.abpp,8+8*isa(data,'uint16'));
            t.verifyEqual(parsed.images.fields.nbpp,parsed.images.fields.abpp);
            t.verifyEqual(oracle.rsiz,2);
            t.verifyEqual(oracle.grid,[size(data,2) size(data,1) 0 0 1024 1024 0 0]);
            t.verifyEqual(oracle.cod,[0 double(strcmp(profile,'EPJE')) 0 20 0 5 4 4 0 1]);
            t.verifyEqual(oracle.bands,size(data,3));
            t.verifyEqual(parsed.images.allTRE.tag,'J2KLRA');
            t.verifyEqual(parsed.images.allTRE.payload,image.compression.j2klra);
            [layers, ok, status] = image.J2KLRA(ID=0);
            t.assertTrue(ok, status.message);
            t.verifyEqual(layers.payload(), image.compression.j2klra);
            t.verifyEqual(layers.nbands_o, size(data, 3));
            t.verifyEqual(image.treCount('J2KLRA'), 1);
            view = image.tre(ID=0); %#ok<NASGU>
            output = evalc('disp(view)');
            t.verifySubstring(output, 'J2KLRA');
            t.verifySubstring(output, 'bitrate');
            t.verifyEqual(numel(parsed.images.data),image.li);
            t.verifyEqual(numel(parsed.images.header),image.lish);
            t.verifyEqual(image.compression.info.tlm,oracle.tlm);
            tiles = prod(ceil(pixelCase.shape(1:2)/1024));
            parts = 1+5*strcmp(profile,'EPJE');
            t.verifyEqual(oracle.tiles(:,1:2),[repmat((0:tiles-1).',parts,1) repelem((0:parts-1).',tiles,1)]);
            t.verifyEqual(numel(image.compression.j2klra),251);
            verifyLayerMetadata(t,image.compression,size(data,3),numel(data));
        end
        function reducedResolutionsAgreeAcrossProfiles(t)
            data = makePixels(t.pixelCase.msi16);
            npje = nfx.JPEG2000(data,t.encoder);
            epje = nfx.JPEG2000(data,t.encoder,Profile='EPJE');
            a = fullfile(t.folder,'npje.j2c'); b = fullfile(t.folder,'epje.j2c');
            putBytes(a,npje.codestream); putBytes(b,epje.codestream);
            t.verifyEqual(imread(a,ReductionLevel=5),imread(b,ReductionLevel=5));
            t.verifyEqual(imread(a,ReductionLevel=3),imread(b,ReductionLevel=3));
            t.verifySize(imread(b,ReductionLevel=5),[33 33 5]);
        end
        function pixelEditsDiscardEncoding(t)
            image = makeImage(ones(32,32,'uint16'),'MONO').compress(t.encoder);
            captured = makeFile(image);
            image.data(1) = uint16(257);
            t.verifyEmpty(image.compression);
            t.verifyEqual(image.header.ic,'NC');
            t.verifyEqual(image.header.abpp,9);
            t.verifyEmpty(image.tre_records);
            t.verifyEqual(captured.images(1).header.ic,'C8');
            t.verifyEqual(captured.images(1).data(1),uint16(1));
        end
        function uncompressRestoresPrecisionAndTREs(t)
            image = makeImage(ones(32,32,'uint16'),'MONO')+fixtureRPC();
            image.header.abpp = 12;
            original = image;
            image = image.compress(t.encoder).uncompress();
            t.verifyEqual(image,original);
        end
        function metadataEditsPreserveSnapshot(t)
            image = makeImage(ones(32,32,'uint8'),'MONO').compress(t.encoder);
            original = image.compression.codestream;
            image.header.iid1 = 'EDITED';
            image = image+fixtureRPC();
            t.verifyTrue(image.validate().valid);
            t.verifyEqual(image.compression.codestream,original);
            t.verifyEqual(image.tre_ids,1);
            t.verifyEqual([image.tre_records.id],[1 0]);
            image = image.removeTRE(1);
            t.verifyEqual(image.tre_records.tag,'J2KLRA');
        end
        function changedBlockGeometryCannotWrite(t)
            image = makeImage(ones(32,32,'uint8'),'MONO').compress(t.encoder);
            image.header.nppbh = 512;
            t.verifyFalse(image.validate().valid);
            t.verifyError(@() makeFile(image).write(fullfile(t.folder,'bad.ntf')),'nfx:Invalid');
            t.verifyEmpty(dir(fullfile(t.folder,'*.ntf')));
        end
        function mixedImagesAndText(t)
            [base,plain] = fixtureFile();
            packed = makeImage(reshape(uint8(0:255),32,8).','MONO');
            packed.data = repmat(packed.data,4,1);
            packed = packed.compress(t.encoder,Profile='EPJE');
            file = nfx.File(header=base.header)+packed+plain+fixtureText();
            filename = fullfile(t.folder,'mixed.ntf'); file.write(filename);
            parsed = inspectContainer(filename);
            t.verifyEqual(nitfread(filename,1),packed.data);
            t.verifyEqual(nitfread(filename,2),plain.data);
            fields = [parsed.images.fields];
            t.verifyEqual({fields.ic},{'C8','NC'});
            t.verifyNumElements(parsed.texts,1);
        end
        function invalidCodestreamRejected(t,corruption)
            bytes = corrupt(t.sample,corruption);
            t.verifyError(@() nfx.JPEG2000.inspect(bytes,'EPJE'),errorFor(corruption));
        end
        function unsupportedPixelsAndGeometry(t)
            t.verifyError(@() nfx.JPEG2000(single(ones(32)),t.encoder),'nfx:Pixels');
            t.verifyError(@() nfx.JPEG2000(zeros(31,32,'uint8'),t.encoder),'nfx:JPEG2000Scope');
            t.verifyError(@() nfx.JPEG2000(zeros(32,32,1,2,'uint8'),t.encoder),'nfx:JPEG2000Scope');
        end
        function missingEncoder(t)
            t.verifyError(@() nfx.JPEG2000(zeros(32,'uint8'),fullfile(t.folder,'missing.exe')),'nfx:OpenJPEGExecutable');
        end
        function impossibleEPJEBandCountFailsBeforeEncoding(t)
            t.verifyError(@() nfx.JPEG2000(zeros(32,32,3300,'uint8'), ...
                fullfile(t.folder,'not-invoked.exe'),Profile='EPJE'),'nfx:JPEG2000Scope');
        end
        function deterministicEncoding(t)
            other = nfx.JPEG2000(reshape(uint8(mod(0:2047,256)),32,64),t.encoder,Profile='EPJE');
            t.verifyEqual(other.codestream,t.sample.codestream);
        end
        function leftJustifiedInputRejected(t)
            image = makeImage(zeros(32,'uint16'),'MONO'); image.header.pjust = 'L';
            t.verifyError(@() image.compress(t.encoder),'nfx:JPEG2000Scope');
        end
        function motionCategoryRejected(t)
            image = makeImage(zeros(32,'uint8'),'MONO'); image.header.icat = 'VIS.M';
            t.verifyError(@() image.compress(t.encoder),'nfx:JPEG2000Scope');
        end
        function motionEditInvalidatesSnapshot(t)
            image = makeImage(zeros(32,'uint8'),'MONO').compress(t.encoder);
            image.header.icat = 'VIS.M';
            t.verifyFalse(image.validate().valid);
        end
        function executablePathWithSpaces(t)
            destination = fullfile(t.folder,'codec with spaces');
            copyfile(fileparts(t.encoder),destination);
            encoded = nfx.JPEG2000(zeros(32,'uint8'),fullfile(destination,'opj_compress.exe'));
            t.verifyEqual(encoded.info.precision,8);
        end
        function shellExpansionPathRejected(t)
            destination = fullfile(t.folder,'codec%PATH%.exe');
            copyfile(t.encoder,destination);
            t.verifyError(@() nfx.JPEG2000(zeros(32,'uint8'),destination),'nfx:OpenJPEGPath');
        end
        function declaredSNIPStillFailsForCompressedPrototype(t)
            image = makeImage(zeros(32,32,2,'uint16'),'MULTI').compress(t.encoder);
            report = makeFile(image).validate(SNIP_COMPLIANT=true);
            t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id},'SNIPImageEncoding')));
        end
    end
end

function data = makePixels(spec)
    values = mod((0:prod(spec.shape)-1)*251+17,spec.range);
    data = reshape(cast(values,spec.type),spec.shape);
end

function image = makeImage(data,rep)
    category = 'VIS'; if strcmp(rep,'MULTI'), category = 'MS'; end
    image = nfx.ImageSegment(data,header=nfx.ImageHeader(iid1='J2K', ...
        idatim='20260916000000',isclas='U',irep=rep,icat=category));
end

function file = makeFile(image)
    file = nfx.File(header=nfx.FileHeader(ostaid='NFXTEST',fdt='20260916000000',fsclas='U'))+image;
end

function verifyLayerMetadata(t,encoded,bands,samples)
    bytes = char(encoded.j2klra);
    t.verifyEqual(bytes(1:11),sprintf('%d05%05d020',2*strcmp(encoded.profile,'EPJE'),bands));
    rows = reshape(bytes(12:end),12,[]).';
    t.verifyEqual(str2double(string(rows(:,1:3))),(0:19).');
    expected = [.03125 .0625 .125 .25 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.5 1.7 2 2.3 2.8 3.5];
    t.verifyEqual(str2double(string(rows(1:19,4:12))),expected.',AbsTol=1e-6);
    t.verifyEqual(str2double(rows(20,4:12)),8*numel(encoded.codestream)/samples,AbsTol=5e-7+eps(37));
end

function bytes = corrupt(sample,kind)
    bytes = sample.codestream; info = sample.info; first = info.parts(1).first;
    switch kind
        case 'soc', bytes(2) = 0;
        case 'sizLength', bytes(5:6) = 0;
        case 'cod', at = info.main([info.main.marker] == hex2dec('FF52')).first; bytes(at+5) = 0;
        case 'qcd', at = info.main([info.main.marker] == hex2dec('FF5C')).first; bytes(at+5) = 0;
        case 'tlm', at = info.main([info.main.marker] == hex2dec('FF55')).last; bytes(at) = 0;
        case 'sot', bytes(first+6:first+9) = 0;
        case 'plt', bytes(first+17) = 0;
        case 'eoc', bytes(end) = 0;
        case 'trailing', bytes(end+1) = 0;
        case 'profile', bytes(8) = 0;
        case 'order', bytes(first+10) = 3;
    end
end

function id = errorFor(kind)
    id = 'nfx:JPEG2000Structure';
    if any(strcmp(kind,{'cod','qcd','profile','order'})), id = 'nfx:JPEG2000Profile'; end
end
