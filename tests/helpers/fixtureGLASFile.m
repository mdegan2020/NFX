function [file,image,exploitation,attitude,ephemeris,alignment,covariance] = fixtureGLASFile(type)
    %fixtureGLASFile - Assemble synthetic supplied metadata, without accuracy claims
    if nargin == 0, type = 'S'; end
    [base,image] = fixtureFile(reshape(uint16(1:2048),32,64)); image = image.removeTRE(1);
    exploitation = fixtureCSEXRB(type); attitude = fixtureCSATTB(); ephemeris = fixtureCSEPHB();
    alignment = fixtureCSSFAB(type); covariance = fixtureCSCSDB();
    file = nfx.File(header=base.header)+(image+exploitation)+attitude+ephemeris+alignment+covariance;
end
