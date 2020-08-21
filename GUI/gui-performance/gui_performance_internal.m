function varargout = gui_performance_internal(varargin)
% GUI_PERFORMANCE_INTERNAL MATLAB code for gui_performance_internal.fig
%      GUI_PERFORMANCE_INTERNAL, by itself, creates a new GUI_PERFORMANCE_INTERNAL or raises the existing
%      singleton*.
%
%      H = GUI_PERFORMANCE_INTERNAL returns the handle to a new GUI_PERFORMANCE_INTERNAL or the handle to
%      the existing singleton*.
%
%      GUI_PERFORMANCE_INTERNAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_PERFORMANCE_INTERNAL.M with the given input arguments.
%
%      GUI_PERFORMANCE_INTERNAL('Property','Value',...) creates a new GUI_PERFORMANCE_INTERNAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_performance_internal_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_performance_internal_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_performance_internal

% Last Modified by GUIDE v2.5 10-Sep-2019 02:41:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_performance_internal_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_performance_internal_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gui_performance_internal is made visible.
function gui_performance_internal_OpeningFcn(hObject, eventdata, handles, varargin)
    if length(varargin) == 0
        error('No data');
    else
        set(handles.refresh_plots,'UserData',varargin{1});
    end
    
    % Extra options to auto-select everything
    set(handles.mplot_selection,'Visible','off')
    
    % Compute the indexes
    h = waitbar(0,'Computing internal indexes...','Name','Loading');
    dat = get(handles.refresh_plots,'UserData');
    CL_RESULTS = dat{1};
    DATA = dat{2};
    PARAMS = dat{3};
    EXTRAS = dat{4}; %MST and LOF
    ORIGINAL_DATA = dat{5};
    PERF_INTER = performance_internal_simple(DATA,CL_RESULTS);
    delete(h);
    set(handles.gui_performance_internal,'UserData',PERF_INTER);

    [n,p] = size(DATA);
    Ks = PARAMS.k;
    Ss = PARAMS.s;
    
    % Table: active_k
    str = num2cell(Ks');
    act = num2cell(logical(zeros(length(Ks),1)));
    act{1} = true;
    str_tmp = repmat({''},length(Ks),1); %TODO: different brightness for each k
    t = [str,str_tmp,act];
    set(handles.active_k,'Data',t);   
    
    % Table: active_index
    str = fieldnames(PERF_INTER);
    nfields = size(str,1);
    act = num2cell(logical(zeros(nfields,1)));
    str_c = cell(nfields,1);
    colors = color_fullhue(nfields);
    for i = 1:nfields
        color = dec2hex(round(colors(i,:).*255));
        color = ['#',color(1,:),color(2,:),color(3,:)];
        str_tmp = num2str(colors(i,:)); %str2num should be used to get the color
        str_c{i} = strcat(['<html><body bgcolor="' color '" font color="' color '" text="' str_tmp '" width="80px">'], color);
    end
    act{1} = true;
    t = [str,str_c,act];
    set(handles.active_index,'Data',t);   
    
    % Table: active_w
    feats_t = PARAMS.UI{1};
    nf = size(feats_t,1);
    str = cell(nf,1);
    str_c = cell(nf,1);
    for i = 1:nf
        if feats_t{i,3}
            str{i} = strcat('w_',num2str(i));
            tmp = cellfun(@(x) str2double(x), strsplit(feats_t{i,2},' '));
            color = dec2hex(round(tmp.*255));
            color = ['#',color(1,:),color(2,:),color(3,:)];
            str_tmp = num2str(tmp); %str2num should be used to get the color
            str_c{i} = strcat(['<html><body bgcolor="' color '" font color="' color '" text="' str_tmp '" width="80px">'], color);
        end
    end
    str = str(~cellfun('isempty',str));
    str_c = str_c(~cellfun('isempty',str_c));
    act = num2cell(logical(zeros(p,1)));
    t = [str,str_c,act];
    set(handles.active_w,'Data',t);  
    
    % Update the GUI
    gui_performance_internal_update(handles);
    default_gui_options(handles) %dafault gui options
    % Choose default command line output for gui_performance_internal
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);
    % UIWAIT makes gui_performance_internal wait for user response (see UIRESUME)
    % uiwait(handles.gui_performance_internal);


% --- Outputs from this function are returned to the command line.
function varargout = gui_performance_internal_OutputFcn(hObject, eventdata, handles) 
    % Get default command line output from handles structure
    varargout{1} = handles.output;


function refresh_plots_Callback(hObject, eventdata, handles)
    gui_performance_internal_update(handles);
  
function mplot_selection_Callback(hObject, eventdata, handles)
    gui_performance_internal_update(handles);
    
function darker_colors_Callback(hObject, eventdata, handles)    
    gui_performance_internal_update(handles);
function mplot_selection_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_intern.
function save_intern_Callback(hObject, eventdata, handles)
    selpath = uigetdir('','Select where to save the results');
    if isequal(selpath,0)
        return
    end
    perfIntern = get(handles.gui_performance_internal,'UserData');
    dat = get(handles.refresh_plots,'UserData');
    s = dat{3}.s;
    k = dat{3}.k;
    tmps = num2cell(s);
    tmpk = [{'k\s'};num2cell(k')];    

    z = [perfIntern.wSilh2];
    wSilh2 = reshape(z,length(k),length(s));
    z = [perfIntern.wSilh];
    wSilh = reshape(z,length(k),length(s));  
    z = [perfIntern.wDBi];
    wDBi = reshape(z,length(k),length(s));  
    z = [perfIntern.wBRi];
    wBRi = reshape(z,length(k),length(s));      
    z = [perfIntern.wCHi];
    wCHi = reshape(z,length(k),length(s));  
    
    z = [perfIntern.Silh2];
    Silh2 = reshape(z,length(k),length(s));
    z = [perfIntern.Silh];
    Silh = reshape(z,length(k),length(s));  
    z = [perfIntern.DBi];
    DBi = reshape(z,length(k),length(s));  
    z = [perfIntern.BRi];
    BRi = reshape(z,length(k),length(s));      
    z = [perfIntern.CHi];
    CHi = reshape(z,length(k),length(s));      
    
    wSilh2c = [tmpk,[tmps;num2cell(wSilh2)]];
    wSilhc = [tmpk,[tmps;num2cell(wSilh)]];
    wDBic = [tmpk,[tmps;num2cell(wDBi)]];
    wBRic = [tmpk,[tmps;num2cell(wBRi)]];    
    wCHic = [tmpk,[tmps;num2cell(wCHi)]];
    
    Silh2c = [tmpk,[tmps;num2cell(Silh2)]];
    Silhc = [tmpk,[tmps;num2cell(Silh)]];
    DBic = [tmpk,[tmps;num2cell(DBi)]];
    BRic = [tmpk,[tmps;num2cell(BRi)]];    
    CHic = [tmpk,[tmps;num2cell(CHi)]];   

    a = [cell(1,length(s)+1);wSilh2c;...
        cell(1,length(s)+1);wSilhc;...
        cell(1,length(s)+1);wDBic;...
        cell(1,length(s)+1);wBRic;...
        cell(1,length(s)+1);wCHic;...
        cell(1,length(s)+1);Silh2c;...
        cell(1,length(s)+1);Silhc;...
        cell(1,length(s)+1);DBic;...
        cell(1,length(s)+1);BRic;...
        cell(1,length(s)+1);CHic];
    b = find(cellfun(@(x) isempty(x),a(:,1))==1);
    a{b(1)} = 'wSilh2';
    a{b(2)} = 'wSilh';
    a{b(3)} = 'wDBi';
    a{b(4)} = 'wBRi';
    a{b(5)} = 'wCHi';
    a{b(6)} = 'Silh2';
    a{b(7)} = 'Silh';
    a{b(8)} = 'DBi';
    a{b(9)} = 'BRi';
    a{b(10)} = 'CHi';

    T = cell2table(a);
    writetable(T,fullfile(selpath,'perfIntern.csv'),'WriteVariableNames',0);
    save(fullfile(selpath,'perfIntern'),'perfIntern');
