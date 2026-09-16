classdef FileSystemTest < NfxTest
    properties (TestParameter)
        unsafeName = {'*.ntf','file?.ntf','https://example.invalid/a.ntf'}
    end
    methods (Test)
        function overwriteRequiresOptIn(t)
            file = fixtureFile();
            destination = fullfile(t.folder,'existing.ntf');
            sentinel = uint8('preserve this destination');
            putBytes(destination,sentinel);
            t.verifyError(@() file.write(destination),'nfx:Exists');
            t.verifyEqual(readBytes(destination),sentinel);
            file.write(destination,Overwrite=true);
            t.verifyEqual(nitfread(destination),file.images(1).data);
        end
        function validationFailurePreservesDestination(t)
            file = fixtureFile();
            file.header.ostaid = '';
            destination = fullfile(t.folder,'existing.ntf');
            sentinel = uint8('keep');
            putBytes(destination,sentinel);
            t.verifyError(@() file.write(destination,Overwrite=true),'nfx:Invalid');
            t.verifyEqual(readBytes(destination),sentinel);
            t.verifyEmpty(dir(fullfile(t.folder,'*.nfx-part')));
        end
        function genericProductCannotPassOrWriteAsSnip(t)
            file = fixtureFile();
            report = file.validate(SNIP_COMPLIANT=true);
            destination = fullfile(t.folder,'existing.ntf');
            sentinel = uint8('keep');
            putBytes(destination,sentinel);
            t.verifyFalse(report.valid);
            t.verifyTrue(any(strcmp({report.issues.id},'SNIPSpectralImage')));
            t.verifyError(@() file.write(destination,Overwrite=true,SNIP_COMPLIANT=true),'nfx:Invalid');
            t.verifyEqual(readBytes(destination),sentinel);
            t.verifyTrue(file.validate().valid);
        end
        function directoryAndMissingParent(t)
            file = fixtureFile();
            t.verifyError(@() file.write(t.folder),'nfx:Destination');
            t.verifyError(@() file.write(fullfile(t.folder,'missing','output.ntf')),'nfx:Destination');
        end
        function unsafeDestinations(t, unsafeName)
            file = fixtureFile();
            t.verifyError(@() file.write(unsafeName),'nfx:Destination');
        end
        function emptyDestination(t)
            file = fixtureFile();
            t.verifyError(@() file.write(''),'MATLAB:validators:mustBeNonempty');
        end
        function shortWritePreservesDestinationAndCleansUp(t)
            file = fixtureFile();
            destination = fullfile(t.folder,'existing.ntf');
            sentinel = uint8('short-write sentinel');
            putBytes(destination,sentinel);
            handles = fileHandles();
            injectIOFailure(t,'fwrite',sprintf('function count=fwrite(varargin)\ncount=0;\nend\n'));
            t.verifyError(@() file.write(destination,Overwrite=true),'nfx:WriteFailed');
            t.verifyEqual(readBytes(destination),sentinel);
            t.verifyEmpty(dir(fullfile(t.folder,'*.nfx-part')));
            t.verifyEqual(fileHandles(),handles);
        end
        function publicationFailurePreservesDestination(t)
            file = fixtureFile();
            destination = fullfile(t.folder,'existing.ntf');
            sentinel = uint8('publish sentinel');
            putBytes(destination,sentinel);
            injectIOFailure(t,'movefile',sprintf('function [ok,message]=movefile(varargin)\nok=false; message=''Injected rename failure'';\nend\n'));
            t.verifyError(@() file.write(destination,Overwrite=true),'nfx:PublishFailed');
            t.verifyEqual(readBytes(destination),sentinel);
            t.verifyEmpty(dir(fullfile(t.folder,'*.nfx-part')));
        end
        function closeFailurePreservesDestination(t)
            file = fixtureFile();
            destination = fullfile(t.folder,'existing.ntf');
            sentinel = uint8('close sentinel');
            putBytes(destination,sentinel);
            handles = fileHandles();
            injectIOFailure(t,'fclose',sprintf('function status=fclose(fid)\nbuiltin(''fclose'',fid); status=-1;\nend\n'));
            t.verifyError(@() file.write(destination,Overwrite=true),'nfx:WriteFailed');
            t.verifyEqual(readBytes(destination),sentinel);
            t.verifyEmpty(dir(fullfile(t.folder,'*.nfx-part')));
            t.verifyEqual(fileHandles(),handles);
        end
        function incorrectPositionPreservesDestination(t)
            file = fixtureFile();
            destination = fullfile(t.folder,'existing.ntf');
            sentinel = uint8('position sentinel');
            putBytes(destination,sentinel);
            injectIOFailure(t,'ftell',sprintf('function position=ftell(varargin)\nposition=-1;\nend\n'));
            t.verifyError(@() file.write(destination,Overwrite=true),'nfx:WriteFailed');
            t.verifyEqual(readBytes(destination),sentinel);
            t.verifyEmpty(dir(fullfile(t.folder,'*.nfx-part')));
        end
        function temporaryOpenFailureLeavesDestinationAlone(t)
            file = fixtureFile();
            destination = fullfile(t.folder,'existing.ntf');
            sentinel = uint8('open sentinel');
            putBytes(destination,sentinel);
            injectIOFailure(t,'fopen',sprintf(['function varargout=fopen(varargin)\n' ...
                'if nargin>1 && strcmp(varargin{2},''wb''), varargout={-1,''Injected failure''};\n' ...
                'else, [varargout{1:nargout}]=builtin(''fopen'',varargin{:}); end\nend\n']));
            t.verifyError(@() file.write(destination,Overwrite=true),'nfx:OpenFailed');
            t.verifyEqual(readBytes(destination),sentinel);
            t.verifyEmpty(dir(fullfile(t.folder,'*.nfx-part')));
        end
        function noOutputAfterFailedValidation(t)
            file = nfx.File();
            destination = fullfile(t.folder,'new.ntf');
            t.verifyError(@() file.write(destination),'nfx:Invalid');
            t.verifyFalse(isfile(destination));
        end
        function readOnlyDestinationIsPreserved(t)
            file = fixtureFile();
            destination = fullfile(t.folder,'readonly.ntf');
            sentinel = uint8('read-only sentinel');
            putBytes(destination,sentinel);
            fileattrib(destination,'-w');
            t.addTeardown(@() fileattrib(destination,'+w'));
            t.verifyError(@() file.write(destination,Overwrite=true),'nfx:PublishFailed');
            t.verifyEqual(readBytes(destination),sentinel);
            t.verifyEmpty(dir(fullfile(t.folder,'*.nfx-part')));
        end
        function newlyAppearedFileIsNotOverwritten(t)
            file = fixtureFile();
            destination = fullfile(t.folder,'concurrent.ntf');
            injectDestinationAtClose(t,destination,false);
            t.verifyError(@() file.write(destination),'nfx:Exists');
            t.verifyEqual(readBytes(destination),uint8('concurrent'));
            t.verifyEmpty(dir(fullfile(t.folder,'*.nfx-part')));
        end
        function newlyAppearedDirectoryIsNotModified(t)
            file = fixtureFile();
            destination = fullfile(t.folder,'concurrent-directory');
            injectDestinationAtClose(t,destination,true);
            t.verifyError(@() file.write(destination),'nfx:Destination');
            t.verifyTrue(isfolder(destination));
            t.verifyEqual(numel(dir(destination)),2);
            t.verifyEmpty(dir(fullfile(t.folder,'*.nfx-part')));
        end
    end
end
