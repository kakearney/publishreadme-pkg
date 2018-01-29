function publishjekyllpost(mfile, jekylldir, varargin)
%PUBLISHREADME Publish a README.m file to HTML and GitHub-flavored markdown
%
% publishreadme(folder, xmlflag)
%
% This function is designed to publish a README.m documentation and
% examples script to both HTML and GitHub-flavored markdown, making it
% easier to use a single file for GitHub and MatlabCentral File Exchange
% documentation.
%
% The markdown stylesheet can also be used independently by publish.m to
% convert any file written with Matlab markup to markdown. 
%
% Input variables:
%
%   folder:     folder name.  The folder should contain a file names
%               README.m. A README.md and README.html file will be added to
%               this folder. If necessary, a readmeExtras folder that holds
%               any supporting images will also be added.
%
%   jekylldir:
%
%   draft:      

% Copyright 2016 Kelly Kearney

validateattributes(mfile, {'char'}, {}, 'publishreadme', 'file');
validateattributes(jekylldir, {'char'}, {}, 'publishreadme', 'jekylldir');

p = inputParser;
p.addParameter('draft', false, @(x) validateattributes(x, {'logical'}, {'scalar'}));
p.addParameter('title', '', @(x) validateattributes(x, {'char'}, {}));
p.addParameter('outname', '', @(x) validateattributes(x, {'char'}, {}));
p.parse(varargin{:});

Opt = p.Results;

% Folders

if Opt.draft
    postdir = fullfile(jekylldir, '_drafts');
else
    postdir = fullfile(jekylldir, '_posts');
end

imagedir = fullfile(jekylldir, 'assets', 'supporting_code');
if ~exist(imagedir, 'dir')
    mkdir(imagedir);
end

% File title

if isempty(Opt.title)
    [~,fname,~] = fileparts(mfile);
    Opt.title = sprintf('%s-%s.md', datestr(today, 'yyyy-mm-dd'), fname);
end
if length(Opt.title) < 3 || ~strcmp(Opt.title(end-2:end), '.md')
    Opt.title = [Opt.title '.md'];
end
if isempty(Opt.outname)
    Opt.outname = fname;
end

% Make a copy to get around any shadowing (less likely with a generic file
% than with READMEs specifically, but still a good safeguard)    

if ~exist(mfile, 'file')
    error('File %s not found', mfile);
end
tmpfile = [tempname('.') '.m'];
[~,tmpbase,~] = fileparts(tmpfile);
copyfile(mfile, tmpfile);

% Options for html and markdown publishing
           
fol = tempname;
mkdir(fol);

mdOpt = struct('format', 'html', ...
               'stylesheet', 'mxdom2jekyll.xsl', ...
               'showCode', true, ...
               'outputDir', fol, ...
               'createThumbnail', false, ...
               'maxWidth', 800);
           
% Publish
           
mdfile   = publish(tmpfile, mdOpt);

% Correct HTML in markdown (R2016b+ uses html in command window printouts)

mdtxt = fileread(mdfile);
mdtxt = strrep(mdtxt, '&times;', 'x');
mdtxt = strrep(mdtxt, '&gt;', '>');
fid = fopen(mdfile, 'wt');
fprintf(fid, '%s', mdtxt);
fclose(fid);

newmd = fullfile(postdir, Opt.title);
movefile(mdfile, newmd);

% Move main files up, and replace references to supporting materials

Files = dir(fol);
fname = setdiff({Files.name}, {'.', '..'});
fnamenew = strrep(fname, tmpbase, Opt.outname);
if ~isempty(fname)

    fid = fopen(newmd, 'r');
    textmd = textscan(fid, '%s', 'delimiter', '\n');
    textmd = textmd{1};
    fclose(fid);
        
    textmd   = strrep(textmd,   tmpbase, fullfile('/assets/supporting_code/', Opt.outname));
    for ii = 1:length(fname)   
        movefile(fullfile(fol, fname{ii}), fullfile(imagedir, fnamenew{ii}));
    end
    fid = fopen(newmd, 'wt');
    fprintf(fid, '%s\n', textmd{:});
    fclose(fid);
end
