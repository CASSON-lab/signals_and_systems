function laplace_poles(varargin)
%% Alex Casson
% 
% Versions
% 04.11.16 - v1 - initial script
%
% Aim
% GUI to show impulse responses due to different pole locations in the
% Laplace domain
%
% Description
% Move the poles locations to see how these affect the system impulse
% response. Displays:
%  - The location of the poles in the s domain. (Plotting Re(s) as an x
%  coordinate and Im(s) as a y coordinate). 
%  - The transfer function this corresponds to in the Laplace domain, H(s).
%  For simplicity this assumes no zeros are presenet.
%  - The inverse Laplace transform of H(s). That is, h(t) the impulse
%  response. 
%  - A plot of the impulse response h(t). 
% Use this to see how the imaginary part of the poles gives the oscillation
% frequency. The real part of the poles gives the amount of damping
% present. When the real part is >= 0 the system becomes unstable. 
% -------------------------------------------------------------------------

%% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @laplace_poles_OpeningFcn, ...
                   'gui_OutputFcn',  @laplace_poles_OutputFcn, ...
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


%% GUI code
function laplace_poles_OpeningFcn(hObject, eventdata, handles, varargin)


% Choose default command line output for laplace_poles
fsize = 14; % font size
handles.output = hObject;
handles.ord    = '2nd order'; % set default value
handles.real   = 0; % set default value
handles.imag   = 0; % set default value
handles.tf_disp = axes('units','pixels','position',[0 0 0 0],'visible','off');
handles.time_disp = axes('units','pixels','position',[0 0 0 0],'visible','off');
handles.ax_poles   = handles.axes2;
handles.ax_impulse = handles.axes1;
guidata(hObject,handles);

% Format window
set(hObject,'Name','University of Manchester Electrical and Electronic Engineering Laplace pole simulator by Alex Casson');
set(hObject,'Toolbar','figure');

% Make note of GUI size
top = 500;

% Set axis labels
xlabel(handles.axes2,'Real part','FontSize',fsize);
ylabel(handles.axes2,'Imaginary part','FontSize',fsize);
xlabel(handles.axes1,'Time / s','FontSize',fsize);
ylabel(handles.axes1,'Amplitude / arbitrary','FontSize',fsize);
        
% Set real part
real_step  = [0.005 0.05]; % 0.1 minor step, 1 major change
real_range = [-10, 10]; % [lower upper]
position   = [20 top-75 150 50];
real_txt   = uicontrol('Style','text','Position',position,'String','Real part','HorizontalAlignment','right','FontSize',fsize);
position   = [position(1)+position(3)+5 position(2)+25 250 25];
real_slide = uicontrol('Style','slider','Min',real_range(1),'Max',real_range(2),'Value',handles.real,'SliderStep',real_step,'Position',position,'Callback',@real_Callback);
position   = [position(1)+position(3)+5 position(2) 50 25];
real_out   = uicontrol('Style','text','Position',position,'String',handles.real,'HorizontalAlignment','left','FontSize',fsize);
    function real_Callback(source,eventdata)
        real = get(source,'Value');
        set(real_out,'String',num2str(real,2));
        h = guidata(gcbo);
        h.real = real;
        guidata(gcbo,h)
        update_plots;
    end


% Set imaginary part
imag_step  = [0.005 0.05]; % 0.1 minor step, 1 major change
imag_range = [-10, 10]; % [lower upper]
position   = [20 top-100 150 25];
imag_txt   = uicontrol('Style','text','Position',position,'String','Imaginary part','HorizontalAlignment','right','FontSize',fsize);
position   = [position(1)+position(3)+5 position(2) 250 25];
imag_slide = uicontrol('Style','slider','Min',imag_range(1),'Max',imag_range(2),'Value',handles.imag,'SliderStep',imag_step,'Position',position,'Callback',@imag_Callback);
position   = [position(1)+position(3)+5 position(2) 50 25];
imag_out   = uicontrol('Style','text','Position',position,'String',[num2str(handles.imag) 'j'],'HorizontalAlignment','left','FontSize',fsize);
    function imag_Callback(source,eventdata)
        imagg = get(source,'Value');
        set(imag_out,'String',[num2str(imagg) 'j']);
        h = guidata(gcbo);
        h.imag = imagg;
        guidata(gcbo,h)
        update_plots;
    end

    
% Set number of poles
ord_options = {'1st order','2nd order'};
position = [20 top-20 150 50];
ord_txt   = uicontrol('Style','text','Position',position,'String','System order','HorizontalAlignment','Right','FontSize',fsize);
position = [position(1)+position(3)+5 position(2)+3 125 50];
[~, default] = max(strcmp(handles.ord,ord_options));
ord_popup = uicontrol('Style','popup','String',ord_options,'FontSize',fsize,'Position',position,'Value',default,'Callback',@ord_Callback); 
    function ord_Callback(source,eventdata) 
        val = get(source,'Value');
        ord = ord_options{val};
        h = guidata(gcbo);
        h.ord = ord;
        guidata(gcbo,h)
        if strcmp(h.ord,'1st order')
            set(imag_slide,'Enable','Off');
        elseif strcmp(h.ord,'2nd order')
            set(imag_slide,'Enable','On');
        else
            error('Incorrect system order.')
        end
        update_plots;
    end


% Display transfer function and graphs
    function update_plots
        h = guidata(gcbo);
        real = h.real;
        imag = h.imag;
        ord  = h.ord;
        tf_disp = h.tf_disp; delete(tf_disp);
        time_disp = h.time_disp; delete(time_disp);
        if real>0; sign1 = '-'; sign2 = '+'; else sign1 = '+'; sign2 = '-'; end 
        if strcmp(ord,'1st order')
            if real == 0
                time_txt  = ['$h(t) = e^{' sign2 num2str(abs(real),2) 't} = u(t)$'];
            else
                time_txt  = ['$h(t) = e^{' sign2 num2str(abs(real),2) 't}$'];
            end
            sys_txt   = ['$H(s) = \frac{1}{s' sign1 num2str(abs(real),2) '}$'];
            sys = tf([1],[1 -1*real]); 
        elseif strcmp(ord,'2nd order')
            if real == 0 && imag == 0
            	time_txt = ['$h(t) = t$'];
            elseif imag == 0
                time_txt = ['$h(t) = te^{' sign2 num2str(abs(real),2) 't}$'];
            else
                time_txt = ['$h(t) = \frac{1}{' num2str(abs(imag),2) '}e^{' sign2 num2str(abs(real),2) 't} \sin (' num2str(abs(imag),2) 't)$'];
            end
            sys_txt   = ['$H(s) = \frac{1}{(s - (' num2str(real,2) '+' num2str(abs(imag),2) 'j))(s - (' num2str(real,2) '-' num2str(abs(imag),2) 'j))}$'];
            sys = zpk([],[real+abs(imag)*1i real-abs(imag)*1i],[1]);
        else
            error('Order incorrectly set.');
        end
        position = [500 top-20 150 50];
        h.tf_disp   = axes('units','pixels','position',position,'visible','off');
        text(0,0.5,sys_txt,'interpreter','latex','horiz','left','vert','middle','FontSize',24)
        
        position = [500 top-100 150 50];
        h.time_disp = axes('units','pixels','position',position,'visible','off');
        text(0,0.5,time_txt,'interpreter','latex','horiz','left','vert','middle','FontSize',24)
        
        % Plot impulse response
        if strcmp(ord,'1st order') || real>=0
            y_range = [-2 2]; % [lower upper]
        else
            y_range = [-0.5 0.5]; % [lower upper]
        end
        f_samp = 200;
        t = -1:1/f_samp:10;
        yi = impulse(sys,t);
        y = zeros(length(t),1); y(end-length(yi)+1:end) = yi; % pad y. Times before 0 don't simulate by default.
        plot(h.ax_impulse,t,y,'b','LineWidth',2)
        axis(h.ax_impulse,[min(t) max(t) y_range(1) y_range(2)])
        grid(h.ax_impulse,'On')
        
        % Plot poles
        plot(h.ax_poles,real,abs(imag),'bx','MarkerSize',20,'LineWidth',2);
        hold(h.ax_poles,'on')
        plot(h.ax_poles,real,-abs(imag),'bx','MarkerSize',20,'LineWidth',2);
        line(h.ax_poles,[0 0], [imag_range(1) imag_range(2)],'Color','k','LineWidth',2,'LineStyle',':');
        line(h.ax_poles, [real_range(1) real_range(2)], [0 0],'Color','k','LineWidth',2,'LineStyle',':');
        axis(h.ax_poles,[real_range(1) real_range(2) imag_range(1) imag_range(2)])
        grid(h.ax_poles,'On')
        hold(h.ax_poles,'off')
        
        % Update labels
        xlabel(h.ax_poles,'Real part','FontSize',fsize);
        ylabel(h.ax_poles,'Imaginary part','FontSize',fsize);
        xlabel(h.ax_impulse,'Time / s','FontSize',fsize);
        ylabel(h.ax_impulse,'Amplitude / arbitrary','FontSize',fsize);
    
        % Update GUI handles
        guidata(gcbo,h)
    end
    
end

%% Set up output (not used here)
function varargout = laplace_poles_OutputFcn(hObject, eventdata, handles) 
    % do nothing
end


end