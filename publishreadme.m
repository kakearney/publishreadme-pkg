function publishreadme(folder)
%PUBLISHREADME Publish a README.m file to HTML and GitHub-flavored markdown
%
% publishreadme(folder)
%
% This function is designed to publish a README.m documentation and
% examples script to both HTML and GitHub-flavored markdown, making it
% easier to use a single file for GitHub and MatlabCentral File Exchange
% documentation.
%
% The markdown stylesheet can also be used independently by publish.m to
% convert any file writtten with Matlab markup to markdown. 
%
% Input variables:
%
%   folder: folder name.  The folder should contain a file names README.m.
%           A README.md and README.html file will be added to this folder.
%           If necessary, a readmeExtras folder that holds any supporting
%           images will also be added.

% Copyright 2016 Kelly Kearney


% READMEs already on the path (pretty common in external toolboxes) will
% shadow these, which prevents the target file from being published.  Make
% a copy to get around that.   

mfile = fullfile(folder, 'README.m');
tmpfile = [tempname('.') '.m'];
[~,tmpbase,~] = fileparts(tmpfile);
copyfile(mfile, tmpfile);

readmefolder = fullfile(folder, 'readmeExtras');

% Remve old published versions

if exist(readmefolder, 'dir')
    rmdir(readmefolder, 's');
end

% Options for html and markdown publishing

htmlOpt = struct('format', 'html', ...
               'showCode', true, ...
               'outputDir', tempdir, ...
               'createThumbnail', false, ...
               'maxWidth', 800);
           
mdOpt = struct('format', 'html', ...
               'stylesheet', 'mxdom2githubmd.xsl', ...
               'showCode', true, ...
               'outputDir', readmefolder, ...
               'createThumbnail', false, ...
               'maxWidth', 800);
           
% xmlOpt = struct('format', 'xml', ...
%                'showCode', true, ...
%                'outputDir', readmefolder, ...
%                'createThumbnail', false, ...
%                'maxWidth', 800);

% Publish, and rename READMEs back to original names
           
htmlfile = publish(tmpfile, htmlOpt);
mdfile   = publish(tmpfile, mdOpt);
% xmlfile  = publish(tmpfile, xmlOpt);

movefile(mdfile,   fullfile(readmefolder, 'README.md'));
movefile(htmlfile, fullfile(readmefolder, 'README.html'));
% movefile(xmlfile,  fullfile(readmefolder, 'README.xml'));

delete(tmpfile);

% Move main files up, and replace references to supporting materials

Files = dir(readmefolder);
fname = setdiff({Files.name}, {'.', '..', 'README.md', 'README.html'});
fnamenew = strrep(fname, tmpbase, 'README');
if isempty(fname)
    movefile(fullfile(readmefolder, 'README.md'), folder);
    movefile(fullfile(readmefolder, 'README.html'), folder);
    rmdir(readmefolder, 's');
else
    fid = fopen(fullfile(readmefolder, 'README.md'), 'r');
    textmd = textscan(fid, '%s', 'delimiter', '\n');
    textmd = textmd{1};
    fclose(fid);
    
    fid = fopen(fullfile(readmefolder, 'README.html'), 'r');
    texthtml = textscan(fid, '%s', 'delimiter', '\n');
    texthtml = texthtml{1};
    fclose(fid);
    
    textmd   = strrep(textmd,   tmpbase, fullfile('.', 'readmeExtras', 'README'));
    texthtml = strrep(texthtml, tmpbase, fullfile('.', 'readmeExtras', 'README'));
    for ii = 1:length(fname)   
        movefile(fullfile(readmefolder, fname{ii}), fullfile(readmefolder, fnamenew{ii}));
    end
    fid = fopen(fullfile(folder, 'README.md'), 'wt');
    fprintf(fid, '%s\n', textmd{:});
    fclose(fid);
    fid = fopen(fullfile(folder, 'README.html'), 'wt');
    fprintf(fid, '%s\n', texthtml{:});
    fclose(fid);
    
    delete(fullfile(readmefolder, 'README.md'));
    delete(fullfile(readmefolder, 'README.html'));
   
end
