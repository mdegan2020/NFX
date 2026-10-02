function injectDestinationAtClose(testCase, destination, directory)
    %injectDestinationAtClose - Simulate a target appearing during output creation
    destination = strrep(destination,'''','''''');
    if directory
        action = sprintf('mkdir(''%s'');', destination);
    else
        action = sprintf(['out=builtin(''fopen'',''%s'',''wb''); ' ...
            'builtin(''fwrite'',out,uint8(''concurrent''),''uint8''); builtin(''fclose'',out);'],destination);
    end
    body = sprintf(['function status=fclose(fid)\nname=fopen(fid); ' ...
        'status=builtin(''fclose'',fid);\nif endsWith(name,''.nfx-part''), %s end\nend\n'],action);
    injectIOFailure(testCase,'fclose',body);
end
