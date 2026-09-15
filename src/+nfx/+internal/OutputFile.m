classdef (Hidden, Sealed) OutputFile < handle
    %OutputFile - Own a descriptor until close or exceptional unwinding
    % A small resource owner permits explicit close-status checks without a
    % cleanup callback referencing a cleared or already-closed descriptor.
    properties (SetAccess = private)
        id = -1 % Owned file descriptor
    end
    methods
        function obj = OutputFile(filename) %#codegen
            %OutputFile - Open a binary temporary output
            obj.id = fopen(filename, 'wb');
            if obj.id < 0
                error('nfx:OpenFailed', 'Could not open temporary output.');
            end
        end
        function status = close(obj) %#codegen
            %CLOSE - Close explicitly and report filesystem failure
            status = fclose(obj.id);
            obj.id = -1;
        end
        function delete(obj) %#codegen
            %DELETE - Close an outstanding descriptor during unwinding
            if obj.id >= 0, fclose(obj.id); end
        end
    end
end
