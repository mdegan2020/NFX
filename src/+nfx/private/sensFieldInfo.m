function info = sensFieldInfo(index,geodeticType,angularUnit) %#codegen
    %sensFieldInfo - Define the indexed SENSRB fields eligible for dynamic data
    info = struct('valid',true,'width',0,'format','N','lower',-Inf, ...
        'upper',Inf,'unknown',false,'positive',false);
    halfTurn = 180;
    if strcmp(angularUnit,'RAD'), halfTurn = pi;
    elseif strcmp(angularUnit,'SMC'), halfTurn = 1;
    end
    switch index
        case '02a', info.width = 20; info.format = 'A';
        case {'02b','02c'}
            info.width = 8; info.format = 'I'; info.lower = 1; info.upper = 99999999;
        case {'02d','02e','02f'}
            info.width = 8; info.lower = 0; info.unknown = true; info.positive = true;
        case {'02g','02h'}
            info.width = 8; info.lower = 0; info.upper = 1.5*halfTurn; info.unknown = true;
        case '02i', info.width = 1; info.format = 'A';
        case '03a', info.width = 2; info.format = 'A';
        case {'03b','03c','03g'}, info.width = 9; info.unknown = true;
        case {'03d','03e','03f','03h','03i','03j','03k'}
            info.width = 12; info.format = 'E'; info.unknown = true;
        case '03l', info.width = 8; info.format = 'D'; info.unknown = true;
        case '04a'
            info.width = 15; info.format = 'A';
        case '04b', info.width = 3; info.format = 'A';
        case {'04c','04d','04e','04f','04i','04j'}
            info.width = 8; info.format = 'I'; info.lower = 1; info.upper = 99999999;
        case {'04g','04h'}, info.width = 10;
        case '04k'
            info.width = 1; info.format = 'I'; info.lower = 0; info.upper = 8;
        case {'04l','04m','04n','04o','04p','04q','04r','04s'}
            info.width = 12; info.format = 'E';
        case '05a', info.width = 12; info.unknown = true;
        case {'05b','05c'}, info.width = 8; info.unknown = true;
        case '06a'
            info.width = 11;
            if strcmp(geodeticType,'G'), info.format = 'L'; info.lower = -90; info.upper = 90; end
        case '06b'
            info.width = 12;
            if strcmp(geodeticType,'G'), info.format = 'O'; info.lower = -180; info.upper = 180; end
        case '06c', info.width = 11;
        case {'06d','06e','06f'}, info.width = 8;
        case '07a', info.width = 1; info.format = 'I'; info.lower = 1; info.upper = 3;
        case {'07b','07d','07h'}
            info.width = 10; info.lower = -halfTurn; info.upper = halfTurn;
            info.unknown = strcmp(index,'07h');
        case {'07c','07g'}
            info.width = 9; info.lower = -halfTurn/2; info.upper = halfTurn/2;
            info.unknown = strcmp(index,'07g');
        case '07e', info.width = 1; info.format = 'A';
        case '07f'
            info.width = 9; info.lower = 0; info.upper = 2*halfTurn; info.unknown = true;
        case {'08a','08b','08c','08d','08e','08f','08g','08h','08i','09a','09b','09c','09d'}
            info.width = 10; info.lower = -1; info.upper = 1;
        case {'10a','10b','10c'}, info.width = 9;
        otherwise, info.valid = false;
    end
end
