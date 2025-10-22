unit U_ProbabilityDist_5_EKON29;

{Copyright  © 2003, Gary Darby,  www.DelphiForFun.org
 This program may be used or modified for any non-commercial purpose
 so long as this original notice remains in place.
 All other rights are reserved   - adapt for maXbox by Max  #locs:2023
 
  //TODO: transfer the TUpDown to a TSpinEdit!
  
 }          

 {Investgate a few kinds of probability distributions by generating random samples
  from a population and comparing the results to the theoretical distribution.
  #sign:User: DESKTOP-BTLKHKF: 29/09/2025 10:51:25 
  Included are: Uniform, Posiion, Normal, and Exponential distributions}

{There is also a page to illustrate the Central Limit Theorem by drawing samples
 from a uniform distribution and summing subsets to produce a normally distributed population}

{Uses Tchart component}

interface

{uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  TeEngine, TeeFunci, Series, ExtCtrls, TeeProcs, Chart, StdCtrls, ComCtrls
  ,ShellAPI;  }

type
  TProbType=(Uniform, aNormal, aPoisson, Exponential,None);
  TForm1 = TForm;
  var
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    aMemo1: TMemo;
    Label1: TLabel;
    NbDieEdt: TEdit;
    Label2: TLabel;
    SidesEdt: TEdit;
    Label3: TLabel;
    TrialsEdt: TEdit;
    GenCBtn: TButton;
    NbrDieUD: TUpDown;
    SidesUD: TUpDown;
    //C:\maXbox\..\source\REST\uPSI_Spin.pas
    TrialsUD: TSpinEdit;
    aMemo2: TMemo;
    Label4: TLabel;
    Edit1: TEdit;
    UpDown1: TUpDown;
    Label5: TLabel;
    Edit2: TEdit;
    UpDown2: TUpDown;
    Label6: TLabel;
    Edit3: TEdit;
    UpDown3: TUpDown;
    GenUBtn: TButton;
    PlotType: TRadioGroup;
    Label7: TLabel;
    Edit4: TEdit;
    Label8: TLabel;
    Edit5: TEdit;
    GenNBtn: TButton;
    Label9: TLabel;
    Edit6: TEdit;
    UpDown4: TSpinEdit; //TUpDown;
    NormPlotType: TRadioGroup;
    Memo3: TMemo;
    Label10: TLabel;
    Edit7: TEdit;
    UpDown5: TSpinEdit; //TUpDown;
    Memo4: TMemo;
    Label11: TLabel;
    Edit8: TEdit;
    GenPBtn: TButton;
    Label13: TLabel;
    Edit10: TEdit;
    UpDown8: TUpDown;
    PlotTypeP: TRadioGroup;
    Memo5: TMemo;
    Label12: TLabel;
    Edit9: TEdit;
    Label14: TLabel;
    Edit11: TEdit;
    UpDown6: TUpDown;
    Label15: TLabel;
    Edit12: TEdit;
    UpDown7: TUpDown;
    ExpPlotType: TRadioGroup;
    GenEBtn: TButton;
    Memo6: TMemo;
    StaticText1: TStaticText;
       procedure GenCBtnClick(Sender: TObject);
       procedure GenUBtnClick(Sender: TObject);
       procedure GenNBtnClick(Sender: TObject);
       procedure DrawChartU(sender:TObject);
       procedure DrawChartN(sender:TObject);
       procedure DrawChartP(sender:TObject);
       procedure DrawChartE(sender:TObject);
       procedure FormCreate(Sender: TObject);
       procedure GenPBtnClick(Sender: TObject);
       procedure GenEBtnClick(Sender: TObject);
       procedure StaticText1Click(Sender: TObject);
  //public
    var
      filename:string;

    {variables used by generate and drawchart routines for each dist type}
    mean,sigma,minx,maxx:double;
    value:array of double;
    interval:double;
    freqcount:array of integer;
    nbrsamps:integer;
    nbrbuckets:integer;
    probtype: TProbtype;
  //end;
  
  type TChartForm = TForm;
   var
    Chart1: TChart;
    Series1: TBarSeries;
    //TeeFunction1: TAddTeeFunction;
    BitBtn1: TBitBtn;
    Series2: TFastLineSeries;

var
  Form1: TForm1;
  ChartForm: TChartForm;
  model_chars: array of char;


implementation

//{$R *.DFM}

//uses math, u_ProbChart;

const path_to_model = 'path/to/model/directory';

procedure setmodelchars;
begin
  model_chars:= ['!', '"', '#', '$', '%', '&', '''', '(', ')', '*', '+', ',', '-', '.',
               '/', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ':', ';', '<',
               '=', '>', '?', '@', '_', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i',
               'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w',
               'x', 'y', 'z'];
end;
//(*

function letmodelchars2: array of char;
begin
  result:= ['!', '"', '#', '$', '%', '&', '''', '(', ')', '*', '+', ',', '-', '.',
             '/', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ':', ';', '<',
             '=', '>', '?', '@', '_', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i',
             'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w',
             'x', 'y', 'z'];
end;
//*)
function letmodelchars3: string;
//var model_chars: Tchararray;
begin
  result:= '!"#$%&''()*+,-./';
end;

{****************** DrawChartU *************}
procedure DrawChartU(sender:TObject);
{Draw Uniform dist charts}
var i:integer;
    sum:integer;
  begin
    If probtype<>uniform then begin
      Showmessage('Generate a set of data first');
      exit;
    end;
    with chartform do begin
      series1.clear;
      series2.clear;
      chart1.bottomaxis.title.caption:='Value';
      chart1.leftaxis.increment:=0;
      case plottype.itemindex of
      0:   {freq}
        begin
          for i:= 0 to nbrbuckets-1 do
          begin
            series1.addxy(minx+i,freqcount[i],'',clRed);
            series2.addxy(minx+i, nbrsamps /nbrbuckets,'',clblue);
          end;
          chart1.leftaxis.title.caption:='Frequency of Values';
        end;
      1: {cumulative freq}
        begin
          sum:=0;
          for i:= 0 to nbrbuckets-1 do begin
            inc2(sum,freqcount[i]);
            series1.addxy(minx+i,sum,'',clred);
            series2.addxy(minx+i,(i+1)*nbrsamps/nbrbuckets,'',clblue);
          end;
          chart1.leftaxis.title.caption:='Cumulative Frequency of Values';
        end;

      2: {probability}
        begin
          for i:= 0 to nbrbuckets-1 do
          begin
            series1.addxy(minx+i,freqcount[i]/nbrsamps,'',clred);
            series2.addxy(minx+i, 1/nbrbuckets,'',clblue);
          end;
          chart1.leftaxis.title.caption:='Probability Density of Values';
       end;

      3: {cumulative probability}
        begin
          sum:=0;
          series2.addxy(minx-1, 0,'',clred);
          for i:= 0 to nbrbuckets-1 do begin
            inc2(sum,freqcount[i]);
            series1.addxy(minx+i,sum/nbrsamps,'',clred);
            series2.addxy(minx+i, (i+1)/nbrbuckets,'',clblue);
          end;
          chart1.leftaxis.title.caption:='Cumulative Probability of Values';
          chart1.leftaxis.increment:=0.1;
        end;
      end; {case}
      chart1.title.text[0]:='Uniform Distribution';
      //chart1.title.text.add('Uniform Distribution');
      
      show;
    end;
  end;


{**************** GenUbtnClick ************}
procedure GenUBtnClick(Sender: TObject);
{Generate Uniform distribution data}
var i:integer;
begin
  minx:=Updown1.position;
  maxx:=Updown3.position+1;
  nbrbuckets:=trunc(maxx-minx);
  nbrsamps:= updown2.position;
  setlength(freqcount,nbrbuckets);
  for i:=0 to nbrbuckets-1 do freqcount[i]:=0;
  for i:= 1 to nbrsamps do inc(freqcount[random(nbrbuckets)]);
  probtype:=uniform;
  //chart1.title.text.add('Uniform Distribution');
      
  DrawchartU(self);
end;

//http://www.teechart.net/docs/teechart/vclfmx/tutorials/UserGuide/Tutorials/tutorial6.htm

procedure TForm1FormCreate(Sender: TObject);
var i: Integer;
  tmpLineSeries: TLineSeries;
begin
  Chart1.View3D:=false;
  for i:=0 to 5 do
  tmpLineSeries:=TLineSeries.Create(self);
    Chart1.AddSeries(tmpLineSeries).FillSampleValues(10);
end;

procedure TForm1Chart1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var series, valueIndex: Integer;
    P0, P1: TPoint;
begin
 // Chart1.Draw();
   chart1.canvas
  for series:=0 to Chart1.SeriesCount-1 do
    with Chart1[series] do
    for valueIndex:=FirstValueIndex to LastValueIndex-1 do
    begin
      P0.X:=CalcXPos(valueIndex);
      P0.Y:=CalcYPos(valueIndex);
      P1.X:=CalcXPos(valueIndex+1);
      P1.Y:=CalcYPos(valueIndex+1);
      if PointInLineTolerance(Point(X, Y), P0.X, P0.Y, P1.X, P1.Y, 5) then
      begin
        //TCanvas3D(Chart1).cANvas.TextOut(X+5,Y-10,'Series ' 
             //+ IntToStr(series));
        exit;
      end;
    end;
   With Chart1,form1.Canvas,chart1.ChartRect do begin
   //prepare Pen and Brush
      Pen.Color := clBlue;
      Pen.Width := 1;
      Pen.Style := psDot;
      Brush.Color := clWhite;
      Brush.Style := bsSolid;
   end;
   {Cube(Left,
        Left+((Right-Left) div 2),
        Top,
        Top+((Bottom-Top) div 2),
        0,
        Width3D,
        True);  }         
end; 

procedure TForm1Button123Click(Sender: TObject);
var rectLeft,rectTop,rectRight,rectBottom:Integer;
begin
 With Chart1, form1.Canvas, chart1.ChartRect do
  begin
    rectLeft:= Left;
    rectTop:= Top;
    rectRight:= Left + (Right - Left) div 2;
    rectBottom:= Top + (Bottom - Top) div 2;

    //prepare Pen and Brush
    Pen.Color := clBlue;
    Pen.Width := 1;
    Pen.Style := psDot;
    Brush.Color := clWhite;
    Brush.Style := bsSolid;

    //Draw the Rectangle
    Rectangle(rectLeft,rectTop,rectRight,rectBottom);
    //Modify Font
    Font.Color := clRed;
    //add the Text start at the midpoint of the Rectangle
    TextOut(rectLeft + (rectRight - rectLeft) div 2, 
            rectTop + (rectBottom-rectTop) div 2,
            'Hello');
 end;
end;

//http://teechart.net/docs/teechart/vclfmx/tutorials/UserGuide/Tutorials/tutorial13.htm
//end;

const  //extended
  C0 = 2.515517;
  C1 = 0.802853;
  C2 = 0.010328;
  D1 = 1.432788;
  D2 = 0.189269;
  D3 = 0.001308;


{************* InvNorm **********}
function InvNormX (const P: Extended): Extended;
  {inverse normal function}
 {from http://www.adug.org.au/MathsCorner/MathsCornerNDist2.htm}
 {looks like a curve fit solution}
var
  T: Extended;
begin
  T := Sqrt (Ln (1.0 / Sqr (P)));
  Result := T - (C0 + C1 * T + C2 * Sqr (T)) /
    (1.0 + D1 * T + D2 * Sqr (T) + D3 * Sqr (T) * T);
end;


function getnormp(i:integer;var InvPiEtc:double):double;
  var x:double;
  begin
     x:=(minx+interval/2+i*interval-mean)/sigma; {normalize x}
     result:=invpietc*exp(-0.5*x*x)/sigma;  {density value at x}
  end;

{******************* DrawChartN *************}
procedure DrawChartN(sender:TObject);
{Draw Normal dist charts}
var
  InvPiEtc:double;
  p,probsum:double;
  i, sum:integer;

  (*{function getnormp(i:integer):double;
  var x:double;
  begin
     x:=(minx+interval/2+i*interval-mean)/sigma; {normalize x}
     result:=invpietc*exp(-0.5*x*x)/sigma;  {density value at x}
  end; *)

begin
   if probtype <> anormal then begin
     showmessage('Generate a set of data first!');
     exit;
   end;//}
   with chartform do begin
      chart1.bottomaxis.title.caption:='Value';
      chart1.leftaxis.increment:=0;
      series1.clear;
      series2.clear;
      invPiEtc:=1.0/sqrt(2*Pi);
      case normplottype.itemindex of
      0:   {freq}
        begin
          for i:= 0 to nbrbuckets-1 do begin
            series1.addxy(minx+interval/2+i*interval,freqcount[i],'',clred);
             {actual}
            p:=getnormP(i,InvPiEtc);  {density value at x}
            series2.addxy(minx+interval/2+i*interval, 
                   interval*nbrsamps*p,'',clblue); 
                   {expected # samps in interval}
          end;
          chart1.leftaxis.title.caption:='Frequency of Values';
        end;

      1: {cumulative freq}
        begin
          sum:=0;
          probsum:=0;
          for i:= 0 to nbrbuckets-1 do begin
            inc2(sum,freqcount[i]);
            series1.addxy(minx+interval/2+i*interval,sum,'',clred);
            p:=getNormP(i,InvPiEtc); {density value at x}
            probsum:=probsum+p;  {Sum the probabilities}
            series2.addxy(minx+interval/2+i*interval, 
                probsum*interval*nbrsamps,'',clblue); {<= this interval} //}
          end;
          chart1.leftaxis.title.caption:='Cumulative Frequency of Values';
        end;

      2: {probability density}
        begin
          for i:= 0 to nbrbuckets-1 do begin
            series1.addxy(minx+interval/2+i*interval,freqcount[i]
                                          /nbrsamps,'',clred);
            p:=getnormP(i,InvPiEtc); {density value at x}
            series2.addxy(minx+interval/2+i*interval, 
               interval*p,'',clblue); {expected # samps in interval}
          end;
          chart1.leftaxis.title.caption:='Probability Density';
       end;

      3: {cumulative probability}
        begin
          sum:=0;
          probsum:=0;
          for i:= 0 to nbrbuckets-1 do begin
            inc2(sum,freqcount[i]);
            series1.addxy(minx+interval/2+i*interval,sum/nbrsamps,'',clred);
            p:=getnormP(i,InvPiEtc); {density value at x}
            probsum:=probsum+p;
            series2.addxy(minx+interval/2+i*interval, 
                interval*probsum,'',clblue); {expected # samps in interval}
          end;
          chart1.leftaxis.title.caption:='Cumulative Probability Distribution';
          chart1.leftaxis.increment:=0.1;
        end;
      end; {case}

      chart1.title.text[0]:='Normal Distribution' ;
      //chart1.title.text.add('Normal Distribution') ;
      show;
    end;
  end;

{***************** GenBtnClick **********}
procedure GenNBtnClick(Sender: TObject);
{Generate Normal distribution data}
var
  p,x:double;
  i, n, errcode :integer;
  amean, asigma: extended;
begin
         //writeln('g'+floattostr(mean))
         //writeln('f'+floattostr(sigma))
    Series2.LinePen.Width:= 3;
    amean:= mean;
    asigma:= sigma;
    tpval(ansistring(edit4.text),(amean),errcode);
    if errcode<>0 then
         MessageDlg('Error in Mean', mtWarning, [mbOk], 0)
    else begin
      tpval(ansistring(edit5.text),asigma,errcode);
      if errcode<>0 then
         MessageDlg('Error in Srd. Dev. ', mtWarning, [mbOk], 0);
    end;
    mean:= amean;
    sigma:= asigma;
    if errcode=0 then begin
      {generate a bunch of random values drawn from a population
       with specified mean and std deviation}
      writeln('debug: gen norm samples') 
      nbrsamps:=updown4.value; //position +700;
      setlength(value,nbrsamps);
      minx:=1e9;  maxx:=-1e9;
      for i:= 0 to nbrsamps-1 do begin
      //writeln('debug '+itoa(nbrsamps))
        p:=invnormX(randomF);
        //p:= randomF;
        //writeln(floattostr(p))
        x:=mean-p*sigma;
         //writeln(floattostr(mean))
         //writeln(floattostr(sigma))
        value[i]:=x;
        //writeln(floattostr(x))
        if x<minx then minx:=x
        else if x>maxx then maxx:=x;
      end;

      {put the samples into buckets}
      nbrbuckets:=updown5.value //position;
      setlength(freqcount,nbrbuckets);
      for i:=0 to nbrbuckets-1 do freqcount[i]:=0;
      interval:=(maxx-minx)/(nbrbuckets-1);
      for i:= 0 to nbrsamps-1 do begin
        n:=trunc((value[i]-minx)/interval);
        inc(freqcount[n]);
      end;
      probtype:=anormal;
      DrawChartN(sender);
  end;
end;

{************* FormCreate ************}
procedure FormCreate(Sender: TObject);
begin
  randomize;
  probtype:=none;
  pagecontrol1.activepage:=TabSheet1;
end;

procedure DlgClose(Sender: TObject; var action: TcloseAction);
begin
  //dlgSearch.CloseDialog;
  chartform.Free;
  chartform:= NIL;
  action:= caFree;
  writeln('free and nil chartform')
end;


  function getp(i:integer; afact: double):double;
    {get poisson density for this bucket}
    begin
      result:=exp(-mean)*intpower(mean,i)/afact;
    end;


{******************** DrawChartP **************}
procedure DrawChartP(sender:TObject);
{Draw Poisson charts}

var i, sum, totsum:integer;
    p, afact, sump:double;

    (*function getp(i:integer):double;
    {get poisson density for this bucket}
    begin
      result:=exp(-mean)*intpower(mean,i)/fact;
    end; *)

  begin
    If probtype<>apoisson then
     //If probtype in [apoisson] then
    begin
      Showmessage('Generate a set of data first');
      exit;
    end; // }
    with chartform do begin
      series1.clear;
      series2.clear;
      chart1.leftaxis.increment:=0;
     chart1.bottomaxis.title.caption:='Nbr Observations per Unit Measure (N)';
      case plottypeP.itemindex of
      0:   {freq}
        begin
        afact:=1;
          for i:= 0 to nbrbuckets-1 do
          begin
            series1.addxy(minx+i,freqcount[i],'',clred);
            If i>0 then afact:=afact*i;
            p:=getp(i, afact);  {get theoretical}
            series2.addxy(minx+i, p*nbrsamps,'',clblue);
            {  debugging
            If i<high(freqcount) then listbox1.items.add(inttostr(i+1)+': '
                      + inttostr(freqcount[i+1])
                      +', '+ inttostr(trunc(p*nbrsamps)));
            }
          end;
         chart1.leftaxis.title.caption:='Nbr of Intervals with N Observarions';
        end;
      1: {cumulative freq}
        begin
          sum:=0; sump:=0;
          afact:=1;
          for i:= 0 to nbrbuckets-1 do
          begin
            inc2(sum,freqcount[i]);
            series1.addxy(minx+i,sum,'',clred);
            If i>0 then afact:=afact*i;
            p:=getp(i,afact); {get theoretical for this bucket}
            sump:=sump+p;
            series2.addxy(minx+i, sump*nbrsamps,'',clred);
          end;
          chart1.leftaxis.title.caption:=
              'Cumulative Nbr of Intervals with N Observations';
        end;

      2: {probability}
        begin
          totsum:=0;
          for i:= 0 to nbrbuckets-1 do inc2(totsum,freqcount[i]);
          afact:=1;  {initialize factorial}
          for i:= 0 to nbrbuckets-1 do
          begin
            series1.addxy(minx+i,freqcount[i]/totsum,'',clred);
            If i>0 then afact:=afact*i;
            p:=getp(i, afact); {get theoretical for this bucket}
            series2.addxy(minx+i, p,'',clblue);
          end;
          chart1.leftaxis.title.caption:=
              'Probability of N Observations per unit Measure';
       end;

      3: {cumulative probability}
        begin
          sum:=0;
          sump:=0;
          totsum:=0;
          for i:= 0 to nbrbuckets-1 do inc2(totsum,freqcount[i]);
          for i:= 0 to nbrbuckets-1 do
          begin
            inc2(sum,freqcount[i]);
            series1.addxy(minx+i,sum/totsum,'',clred);

            If i>0 then afact:=afact*i else afact:=1;
            p:=getp(i,afact); {get theoretical prob for this bucket}
            sump:=sump+p;
            series2.addxy(minx+i, sump,'',clblue);
          end;
          chart1.leftaxis.title.caption:=
              'Cumulative Probability of N Observations';
          chart1.leftaxis.increment:=0.1;
        end;
      end; {case}
      chart1.title.text[0]:='Poisson Distribution';
      show;
    end;
  end;
  
  
  procedure SaveStattofile(asender: TObject);
  begin
    SaveCanvas2(chartform.canvas, Exepath+'statdist3.png');
    opendoc(Exepath+'statdist3.png')
  end;  

  procedure setvalue(asender: TObject);
  begin
    series1.marks.visible := Not series1.marks.visible; 
    //opendoc(Exepath+'statdist3.png')
  end;  

{**************** GenpBtnClick *************}
procedure GenPBtnClick(Sender: TObject);
{Generate Poisson data}
var
  i:integer;
  count:integer;
  x, sumx: double;
  errcode:integer;
  amean: extended;
begin
  amean:= mean;
  tpval(edit8.text,amean,errcode);
  if errcode<>0 then Showmessage('Generate a set of data first')
  else
  Begin
    minx:=0;
    maxx:=5*mean;
    nbrbuckets:=trunc(maxx-minx);
    nbrsamps:=updown8.position;
    setlength(freqcount,nbrbuckets);
    for i:=0 to nbrbuckets-1 do freqcount[i]:=0;
    for i:= 1 to nbrsamps do
    {use exponential distribution to generate "next arrival" times and
     count number per unit of time to generate counts}
    begin
      sumx:=-ln(randomF)/mean;
      count:=0;
      while sumx<1 do begin
        x:=-ln(random(0))/mean;  {exponential time until next arrival}
        sumx:=sumx+x; {add 'em up until we exceed 1 time unit}
        inc(count);  {increment the  arrival count}
      end;
      if count>high(freqcount) then setlength(freqcount,count+1);
      inc(freqcount[count]);
    end;
    {delete any unused buckets at high end of scale}
    i:=high(freqcount);
    while freqcount[i]=0 do dec(i);
    maxx:=i+1;
    nbrbuckets:=trunc(maxx-minx);
    setlength(freqcount,nbrbuckets);

    probtype:=apoisson;
    DrawchartP(self);
  end;

end;

  function getp2(i:integer {mean: double}):double;
  begin
    result:=exp(-(interval*(i) +interval/2)/mean)/mean; 
      {density value for "i"th bucket}
  end;


{****************** DrawChartE ************}
procedure DrawChartE(sender:TObject);
{Draw Exponential distribution chart}
var p,probsum:double;
  i, sum:integer;
begin
   if probtype<>exponential then
   begin
     showmessage('Generate a set of data first');
     exit;
   end;
   with chartform do begin
      chart1.leftaxis.increment:=0;
      chart1.bottomaxis.title.caption:='Time until next arrival';
      series1.clear;
      series2.clear;
      case expPlotType.itemindex of
      0:   {freq}
        begin
          for i:= 0 to nbrbuckets-1 do  begin
            series1.addxy(interval/2+i*interval,freqcount[i],'',clred); {actual}
            p:=getp2(i);  {get theoretical prob for this bucket}
            series2.addxy(interval/2+i*interval, 
                interval*nbrsamps*p,'',clblue); {expected # samps in interval}
          end;
          chart1.leftaxis.title.caption:='Frequency of Values';
        end;

      1: {cumulative freq}
        begin
          sum:=0;
          for i:= 0 to nbrbuckets-1 do
          begin
            inc2(sum,freqcount[i]);
            series1.addxy(interval/2+i*interval,sum,'',clred);
            probsum:=1-exp(-((i+1)*interval)/mean); 
            {get cum. distribution directly}
            series2.addxy(interval/2+i*interval, 
                     probsum*nbrsamps,'',clblue); {nbr <= this interval}
          end;
          chart1.leftaxis.title.caption:='Cumulative Frequency of Values';
        end;

      2: {probability density}
        begin
          for i:= 0 to nbrbuckets-1 do  begin
            series1.addxy(interval/2+i*interval,freqcount[i]/nbrsamps,'',clred);
            p:=getp2(i); {get theoretical prob for this bucket}
            series2.addxy(interval/2+i*interval, 
                   interval*p,'',clblue); {expected # samps in interval}
          end;
          chart1.leftaxis.title.caption:='Probability Density';
       end;

      3: {cumulative probability}
        begin
          sum:=0;
          for i:= 0 to nbrbuckets-1 do begin
            inc2(sum,freqcount[i]);
            series1.addxy(interval/2+i*interval,sum/nbrsamps,'',clred);
            probsum:=1-exp(-((i+1)*interval)/mean);  
            {get distribution func directly}
            series2.addxy(interval/2+i*interval, 
                    probsum,'',clblue); {plot expected cumulative prob. }
          end;
          chart1.leftaxis.title.caption:='Cumulative Probability Distribution';
          chart1.leftaxis.increment:=0.1;
        end;
      end; {case}
      chart1.title.text[0]:='Expinential Distribution' ;
      show;
    end;
  end;

{*************** GenEBtnClick ********************}
 procedure GenEBtnClick(Sender: TObject);
 {Generate Exponential data }
var
  x:double;
  i, n, errcode :integer;
  amean: extended;
 begin
    amean:= mean;
    tpval(edit9.text,amean,errcode);
    if errcode<>0 then
         MessageDlg('Error in Mean', mtWarning, [mbOk], 0)
    else begin
      {generate a bunch of random values drawn from a population
       with specified mean and std deviation}
      nbrsamps:=updown6.position;
      setlength(value,nbrsamps);
      minx:=0;  maxx:=-1e9;
      for i:= 0 to nbrsamps-1 do
      begin
        x:=-ln(random(0))*mean;
        value[i]:=x;
        if x>maxx then maxx:=x;
      end;

      {put the samples into buckets}
      nbrbuckets:=updown7.position;
      setlength(freqcount,nbrbuckets+1);
      for i:=0 to nbrbuckets-1 do freqcount[i]:=0;
      interval:=maxx/(nbrbuckets-1);
      for i:= 0 to nbrsamps-1 do
      begin
        n:=trunc((value[i])/interval);
        inc(freqcount[n]);
      end;
      probtype:=exponential;
      DrawChartE(sender);
  end;
end;

{****************** ShowitBtnClick ******************}
procedure GenCBtnClick(Sender: TObject);
{Central limit theorem demo}
{build and display a density plot of the data}
var
  sums:array of integer;
  sum:double{integer};
  i,j, sampsize:integer;
begin
  nbrbuckets:=sidesud.position+10;
  nbrsamps:=trialsud.value+50;
  sampsize:=nbrdieud.position;
  setlength(sums, nbrbuckets);
  for i:=low(sums) to high(sums) do  sums[i]:=0;
  for i:= 1 to trialsUD.value+50 do begin
    sum:=0;
    for j:= 1 to sampsize do sum:=sum+randomF;
    j:=trunc(nbrbuckets*sum/sampsize);
    inc(sums[j]);
  end;

  {chartform.}series1.clear;
  {chartform.}series2.clear;
  for i:=0 to high(sums) do 
     series1.addxy(sampsize*i/nbrbuckets, sums[i],'',clred);
  with chartform, chart1 do begin
    leftaxis.title.caption:='Frequency of Subset Sums';
    bottomaxis.title.caption:='Subset sums';
    title.text[0]:='Central Limit Theorem Demo' ;
    chartform.show;
  end;  
end;


procedure StaticText1Click(Sender: TObject);
begin
  //ShellExecute(Handle, 'open', 'http://www.delphiforfun.org/',
  //nil, nil, SW_SHOWNORMAL);
end;


procedure loadChartForm;
var aspinde: TSpinEdit;
begin
Form1:= TForm1.create(self)
   chartform:= TChartform.create(self)
   chartform.setBounds(100,100,800,480)
   
    Series1:= TBarSeries.create(self);
    series1.Title:='Sample Data';
    Series2:= TFastLineSeries.create(self);
    Series2.LinePen.Width:= 4;
    series2.Title:='Theoretical';
    series1.marks.visible:= true;
    series1.Marks.ArrowLength:= 20;
    //series2.ParentChart := Chart1 ; 

    Chart1:= TChart.create(self);
    chart1.parent:= chartform;
    with chart1 do begin
      BackWall.Color:=clWhite;
      //ZoomRect( Rect );
      //Chart1.BottomAxis.Increment := 57; //DateTimeStep[ dtOneHour ] ;
      setBounds(10,10,770,425)
      //Chart1.ExchangeSeries( 0, 1 );
      LeftAxis.Title.Caption:= 'of Occurrences';
      //ChangeSeriesTypeGallery(Self, MySeries );
      //BackWall.Style
      // init title
      title.text.add('Uniform Distribution');

      Legend.LegendStyle:= lsSeries;
      AddSeries(Series1);
      //Series1.FillSampleValues(10); 
      AddSeries(Series2);
      //Series2.FillSampleValues(10); 
      //getSeries(0).fillSampleValues(10); 
      //Chart1.getSeries(1).fillSampleValues(10); 
      
    end; 
    
    BitBtn1:= TBitBtn.create(chartform);
    with bitbtn1 do begin
      parent:= chartform;
      caption:= 'Save...';
      glyph.loadfromresourcename(hinstance, 'TEEARROWUP'); //'TJVREGAUTO')
      setbounds(660,380,100,35)
      //onclose:= chartform.hide;
      onclick:= @savestattofile;
    end;  
    with  TBitBtn.create(chartform) do begin;
      parent:= chartform;
      caption:= 'Values';
      glyph.loadfromresourcename(hinstance, 'TEEARROWDOWN'); //'TJVREGAUTO')
      setbounds(660,335,100,35)
      //onclose:= chartform.hide;
      onclick:= @setvalue;
    end;  
  //http://www.delphigroups.info/2/b4/392586.html  
  Chart1.View3D:=false;  
    
with form1 do begin
  Left := 99
  Top := 104
  Width := 862
  Height := 701
  Anchors := [akLeft, akBottom]
  Caption := 'mX4 Probability Distribution Charts and Functions'
  Color := clBtnFace
  Font.Charset := DEFAULT_CHARSET
  Font.Color := clWindowText
  Font.Height := -14
  Font.Name := 'MS Sans Serif'
  Font.Style := []
  OldCreateOrder := False
  Position := poScreenCenter
  OnCreate := @FormCreate
  onclose:= @dlgclose;
  PixelsPerInch := 120
  //form1.TextHeight('16')
  show;
  end;
  PageControl1:= TPageControl.create(form1)
  with pagecontrol1 do begin
    parent:= form1;
    Left := 0
    Top := 0
    Width := 844
    Height := 636
    ActivePage := TabSheet2
    Align := alClient
    visible:= true;
    TabHeight := 30;
    TabOrder := 0
    TabSheet1:= TTabSheet.create(form1)
    //end;
      with tabsheet1 do begin
      parent:= pagecontrol1;
      Caption := 'Introduction'
      pagecontrol:= pagecontrol1
        //visible:= true;
        //77show
      end;
    
    //text:= '';
    end;  
      Memo6:= TMemo.create(form1)
      with memo6 do begin
      parent:= tabsheet1;
        Left := 20;   Top := 10
        Width := 730; Height := 572
        Color := 14548991
        Font.Charset := DEFAULT_CHARSET
        Font.Color := clWindowText
        Font.Height := -17
        Font.Name := 'MS Sans Serif'
        Font.Style := []
        Lines.add('          Welcome to Random Kingdom! '+
            CRLF+CRLF+
        'Here'#39's a program which looks at some common distributions of ran' +
            'dom variables. You will need a '
          +'statistics course or at least a good text book to understand eve' +
            'rything here, but the the basic '
          +'concepts are not that difficult. First some terminology: '
          +CRLF
          +'Imagine that you place 500 dots randomly on a piece of paper tha' +
            't has been marked off into 100'
          +'squares (10 x 10). If you make a chart with "Number of dots per' +
            ' square" (N) as the X axis and'
          +'"Number of squares" (F) as the Y axis, you will have created a f' +
            'requency distribution chart.'
          +''+CRLF+ CRLF+
          +'If you further divide each value of F by 100, the total number o' +
            'f squares, the results become'
          +'probabilities and the resulting chart is an approximation of the' +
            ' probability density chart for the'
          +'random variable N.  For each value of N the probability density ' +
            'function will tell us the probability'
          +'of that value if we perform a large  number of  experiements.'
          +''+CRLF+CRLF+CRLF+CRLF
          +'If we sum the probability values from left to right, the chart (' +
            'or function) will tell us the probability of the '
          +'number of dots in any square being  less than or equal to N. T' +
            'he is called the cumulative distribution function. The random variable N is'
            +' a "discrete random variable" since it can only '
          +'assume discrete values and, for this example, the distribution i' +
            's "Poisson" with a mean value of 5.'
          +''+CRLF+CRLF
          +'The distributions in this program have mathematical functions wh' +
            'ich describe them but you will have '
          +'to search your statisitcs book (or the program source code) for ' +
            'the specifics. In next pages, we'#39'll generate s.random samples as if they w' +
            'ere selected from a population '
          +'with the specified characterisitcs. The plots will compare the d' +
            'istributions of the sample data (bar'
          +'chart data), with the theroretical distribution for that variabl' +
            'e (the line chart).'  +'' +''
         + ''  +' '  +' '  +' ' +' ')
        ParentFont := False
        TabOrder := 0
      end;
    //end
    TabSheet2:= TTabSheet.create(form1)
    with tabsheet2 do begin
      parent:= pagecontrol1
       pagecontrol:= pagecontrol1
      Caption := 'Uniform Distribution'
      ImageIndex := 1
      end;
      Label4:= TLabel.create(form1)
      with label4 do begin
      parent:= tabsheet2
        Left := 20
        Top := 453
        Width := 53
        Height := 16
        Caption := 'Minimum'
      end;
      Label5:= TLabel.create(form1)
      with label5 do begin
      parent:= tabsheet2
        Left := 197
        Top := 453
        Width := 117
        Height := 16
        Caption := 'Number of samples'
      end;
      Label6:= TLabel.create(form1)
      with label6 do begin
      parent:= tabsheet2 
      //object Label6: TLabel
        Left := 20
        Top := 492
        Width := 57
        Height := 16
        Caption := 'Maximum'
      end;
      aMemo2:= TMemo.create(form1)
      with amemo2 do begin
      parent:= tabsheet2 ;
        Left := 20
        Top := 20
        Width := 464
        Height := 336
        Color := 14548991
        Font.Charset := DEFAULT_CHARSET
        Font.Color := clWindowText
        Font.Height := -17
        Font.Name := 'MS Sans Serif'
        Font.Style := []
        Lines.add (CRLF+
          'All values from a uniform distribution are equally likely.'
          +''
          +'Uniform distributions can occur in in discrete or '
          +'continuous form,   Discrete as when we select '
          +'integers randomly, or draw uniquely colored balls '
          +'from  a bag, replacing each ball before drawing again.'
          +''
          +'Or continuous as when computer languages generate '
          +'uniformly distributed  real numbers between 0 and 1 as one '
          +'of their standard functions.  The 20 or 30 digts of '
          +'accuracy give a fair approximation of a continuous '
          +'uniformly distributed random variable.'
          +''
          +'In this example we will stick to uniformly distributed '
          +'integers within a range.  ')
        ParentFont := False
        TabOrder := 0
      end;
       Edit1:= TEdit.create(form1)
       with edit1 do begin
       parent:= tabsheet2 ;
        Left := 89
        Top := 453
        Width := 50
        Height := 24
        TabOrder := 1
        Text := '1'
      end;
      UpDown1:= TUpDown.create(form1)
      with updown1 do begin
       parent:= tabsheet2 ;
        Left := 139
        Top := 453
        Width := 19
        Height := 24
        Associate:=Edit1;
        //Min := 1
        Position := 1
        TabOrder := 2
      end;
      //object Edit2: TEdit
      Edit2:= TEdit.create(form1)
       with edit2 do begin
       parent:= tabsheet2 ;
        Left := 325
        Top := 453
        Width := 50
        Height := 24
        TabOrder := 3
        Text := '1,000'
      end;
      //object UpDown2: TUpDown
      UpDown2:= TUpDown.create(form1)
      with updown2 do begin
       parent:= tabsheet2 ;
        Left := 375
        Top := 453
        Width := 19
        Height := 24
        //Associate ( Edit2)
        //Min (1)
        //updown2.Maxval := 10000
        Position := 1000
        TabOrder := 4
      end;
      //object Edit3: TEdit
      Edit3:= TEdit.create(form1)
       with edit3 do begin
       parent:= tabsheet2 ;
        Left := 89
        Top := 492
        Width := 50
        Height := 24
        TabOrder := 5
        Text := '10'
      end ;
      //object UpDown3: TUpDown
      UpDown3:= TUpDown.create(form1)
      with updown3 do begin
       parent:= tabsheet2 ;
        Left := 139
        Top := 492
        Width := 19
        Height := 24
        //updown3.Associate ( Edit3)
        //Min := 2
        Position := 10
        TabOrder := 6
      end;
      GenUBtn:= TButton.create(form1)
      with genubtn do begin
      parent:= tabsheet2;
        Left := 20
        Top := 537
        Width := 92
        Height := 30
        Caption := 'Run a set'
        TabOrder := 7
        OnClick := @GenUBtnClick
      end;
      PlotType:= TRadioGroup.create(form1)
      with plottype do begin
      parent:= tabsheet2
        Left := 482;   Top := 453
        Width := 228;  Height := 129
        Caption := 'Plot type'
        ItemIndex := 0
        Items.add('Frequency')
        Items.add('Cumulative Frequency')
        Items.add('Probability')
        Items.add('Cumulative Probability')
        ItemIndex := 1;
         { 'Cumulative Frequency'
          'Probability'
          'Cumulative Probability')  }
        TabOrder := 8
        OnClick := @DrawChartU
      end;
    //end //*)
    
    
  (*  object TabSheet4: TTabSheet
      Caption := 'Poisson'
      ImageIndex := 3
      object Label11: TLabel
        Left := 20
        Top := 453
        Width := 100
        Height := 16
        Caption := 'Avg  Arrival Rate'
      end
      object Label13: TLabel
        Left := 20
        Top := 492
        Width := 109
        Height := 16
        Caption := 'Number of arrivals'
      end
      object Memo4: TMemo
        Left := 20
        Top := 20
        Width := 444
        Height := 296
        Color := 14548991
        Font.Charset := DEFAULT_CHARSET
        Font.Color := clWindowText
        Font.Height := -17
        Font.Name := 'MS Sans Serif'
        Font.Style := []
        Lines.Strings := (
          'Many discrete natural processes have time or space '
          'related events measured as ocurrences per unit measure'
          'that occur in a distribution approximated by the Poisson '
          'Distribution,   The Frequency or Probability Distribution '
          'curves resemble the normal "bell" curve for if the mean '
          'observed rate is high, but definitely scewed to the left for '
          'smaller mean values. '
          ''
          'The data are not generated by outcomes of experiments, '
          'but by randomly occurring events.  Further we are interested '
          'in the occurrence of events rather than the non-occurrence.  '
          'The number of vehicles per hour arriving at the toll booth '
          'or the number of errors per printed page are  examples.'
          ''
          '')
        ParentFont := False
        TabOrder := 0
      end
      object Edit8: TEdit
        Left := 148
        Top := 453
        Width := 50
        Height := 24
        TabOrder := 1
        Text := '2.5'
      end
      object GenPBtn: TButton
        Left := 20
        Top := 546
        Width := 92
        Height := 31
        Caption := 'Run a set'
        TabOrder := 2
        OnClick := GenPBtnClick
      end
      object Edit10: TEdit
        Left := 148
        Top := 492
        Width := 50
        Height := 24
        TabOrder := 3
        Text := '1,000'
      end
      object UpDown8: TUpDown
        Left := 198
        Top := 492
        Width := 19
        Height := 24
        Associate := Edit10
        Min := 1
        Max := 10000
        Position := 1000
        TabOrder := 4
      end
      object PlotTypeP: TRadioGroup
        Left := 482
        Top := 453
        Width := 228
        Height := 129
        Caption := 'Plot type'
        ItemIndex := 0
        Items.Strings := (
          'Frequency'
          'Cumulative Frequency'
          'Probability'
          'Cumulative Probability')
        TabOrder := 5
        OnClick := DrawChartP
      end
    end  *)
    //object TabSheet3: TTabSheet
    TabSheet3:= TTabSheet.create(form1)
    with tabsheet3 do begin
      parent:= pagecontrol1
       pagecontrol:= pagecontrol1
      Caption := 'Normal Dist.'
      ImageIndex := 2
     end; 
     Label7:= TLabel.create(self)
     with label7 do begin
       parent:= tabsheet3
        Left := 20
        Top := 453
        Width := 34
        Height := 16
        Caption := 'Mean'
      end;
      Label8:= TLabel.create(self)
     with label8 do begin
       parent:= tabsheet3
        Left := 20
        Top := 492
        Width := 80
        Height := 16
        Caption := 'Std Deviation'
      end;
      Label9:= TLabel.create(self)
     with label9 do begin
       parent:= tabsheet3
      //object Label9: TLabel
        Left := 197
        Top := 453
        Width := 117
        Height := 16
        Caption := 'Number of samples'
      end;
      Label10:= TLabel.create(self)
     with label10 do begin
       parent:= tabsheet3
      //object Label10: TLabel
        Left := 197
        Top := 502
        Width := 119
        Height := 41
        AutoSize := False
        Caption := 'Number of buckets in plot (bins)'
        WordWrap := True
      end;
      Edit4:= TEdit.create(form1)
      with edit4 do begin
       parent:= tabsheet3;
        Left := 108
        Top := 453
        Width := 51
        Height := 24
        TabOrder := 0
        Text := '68'
      end;  
      //object Edit5: TEdit
      Edit5:= TEdit.create(form1)
      with edit5 do begin
       parent:= tabsheet3;
        Left := 108
        Top := 492
        Width := 51
        Height := 24
        TabOrder := 1
        Text := '2.5'
      end;
      GenNBtn:= TButton.create(form1)
      with gennbtn do begin
      parent:= tabsheet3
        Left := 20
        Top := 546
        Width := 92
        Height := 31
        Caption := 'Run a Set'
        TabOrder := 2
        OnClick := @GenNBtnClick
      end ;
     { Edit6:= TEdit.create(form1);
      with edit6 do begin
        parent:= tabsheet3;
        Left := 325
        Top := 453
        Width := 50
        Height := 24
        TabOrder := 3
        Text := '1,000'
      end;  //}
      UpDown4:= TSpinedit.create(form1)
      with updown4 do begin
      parent:= tabsheet3;
        Left := 325
        Top := 453
        Width := 70
        Height := 25
        font.size:= 13;
        font.color:= clred;
        color:= clsilver;
        //updown4.Associate( Edit6 )
        onclick
        Minvalue := 1
        Maxvalue := 10000
        Value := 2000
        increment:= 200;
        TabOrder := 4
      end;
      NormPlotType:= TRadioGroup.create(form1)
      with normplottype do begin
       parent:= tabsheet3
        Left := 482
        Top := 453
        Width := 228
        Height := 129
        Caption := 'Plot type'
        ItemIndex := 0
        Items.add('Frequency')
        Items.add('Cumulative Frequency')
        Items.add('Probability')
        Items.add('Cumulative Probability')
        TabOrder := 5
        ItemIndex := 0
        OnClick := @DrawchartN
      end;
       Memo3:= TMemo.create(self)
       with memo3 do begin
       parent:= tabsheet3;
        Left := 20
        Top := 20
        Width := 464
        Height := 316
        Color := 14548991
        Font.Charset := DEFAULT_CHARSET
        Font.Color := clWindowText
        Font.Height := -17
        Font.Name := 'MS Sans Serif'
        Font.Style := []
        Lines.add(CRLF+
          'The "Normal" or Gaussian Distribution is  the most commonly '
          +'used probability model  in economic and business modelling.  '
          +'It'#39's density function is the famous (or infamous) Bell shaped '
          +'curve which peaks at the mean of the distribution.  The width '
          +'of the curve is determined by a measure of variablilty  called '
          +'the Standard Deviation, often denoted and therefore named '
          +'with the Greek letter "sigma". '+CRLF+CRLF+' (Standard deviation is the '
          +'square root of the sum of the squares oft the deviations of the '
          +'population samples from the mean, which proably won'#39't '
          +'register unti, you compute a few by hand!)    '
          +''
          +'In a normally distributed population, about 68% of the members '
          +'fall within one sigma of the mean, 95%  fall within two sigma, '
          +'and well over 99% within three sigma. ,  ')
        ParentFont := False
        TabOrder := 6
      end;
      {Edit7:= TEdit.create(form1);
      with edit7 do begin
        parent:= tabsheet3;
        Left := 325
        Top := 502
        Width := 50
        Height := 24
        TabOrder := 7
        Text := '60'
      end ;  }
     { UpDown5:= TUpDown.create(form1)
      with updown5 do begin
      parent:= tabsheet3;
        Left := 375
        Top := 502
        Width := 19
        Height := 24
        //Associate := Edit7
        //Min := 1
        //Max := 1000
        Position := 50
        TabOrder := 8
      end;    }
      
      UpDown5:= TSpinedit.create(form1)
      with updown5 do begin
      parent:= tabsheet3;
        Left := 325
        Top := 502
        Width := 70
        Height := 25
        font.size:= 13;
        font.color:= clred;
        color:= clsilver;
        //Associate := Edit6
        Minvalue := 1
        Maxvalue := 1000
        Value := 50
        increment:= 50;
        TabOrder := 4
      end;
    //end
    (*object TabSheet5: TTabSheet
      Caption := 'Exponential'
      ImageIndex := 4
      object Label12: TLabel
        Left := 20
        Top := 453
        Width := 34
        Height := 16
        Caption := 'Mean'
      end
      object Label14: TLabel
        Left := 197
        Top := 453
        Width := 117
        Height := 16
        Caption := 'Number of samples'
      end
      object Label15: TLabel
        Left := 197
        Top := 502
        Width := 119
        Height := 41
        AutoSize := False
        Caption := 'Number of buckets in plot'
        WordWrap := True
      end
      object Memo5: TMemo
        Left := 20
        Top := 20
        Width := 483
        Height := 286
        Color := 14548991
        Font.Charset := DEFAULT_CHARSET
        Font.Color := clWindowText
        Font.Height := -17
        Font.Name := 'MS Sans Serif'
        Font.Style := []
        Lines.Strings := (
          
            'The Exxponential Distribution is a continuous distribuution rela' +
            'ted '
            'to the discrete Poisson distribution in the following manner.  I' +
            'f a '
            'discrete random variable has a Poisson Distribution, then he tim' +
            'e '
          '(or distance) between events is distributed Exponentially.'
          ''
          'The means are related by and inverse relationsship.  For '
          'example, if there are an average of 60 customers per hour at a '
          
            'facility, the mean time betweren arrivals is one minute (1/60 of' +
            ' an '
          'hour)'
          ''
          'Discrete simluation computer programs frequently use the '
            'exponential disttribution function to generate arrival patterns.' +
            '  ')
        ParentFont := False
        TabOrder := 0
      end
      object Edit9: TEdit
        Left := 108
        Top := 453
        Width := 51
        Height := 24
        TabOrder := 1
        Text := '1.25'
      end
      object Edit11: TEdit
        Left := 325
        Top := 453
        Width := 50
        Height := 24
        TabOrder := 2
        Text := '1,000'
      end
      object UpDown6: TUpDown
        Left := 375
        Top := 453
        Width := 19
        Height := 24
        Associate := Edit11
        Min := 1
        Max := 10000
        Position := 1000
        TabOrder := 3
      end
      object Edit12: TEdit
        Left := 325
        Top := 502
        Width := 50
        Height := 24
        TabOrder := 4
        Text := '50'
      end
      object UpDown7: TUpDown
        Left := 375
        Top := 502
        Width := 19
        Height := 24
        Associate := Edit12
        Min := 1
        Max := 1000
        Position := 50
        TabOrder := 5
      end
      object ExpPlotType: TRadioGroup
        Left := 482
        Top := 453
        Width := 228
        Height := 129
        Caption := 'Plot type'
        ItemIndex := 0
        Items.Strings := (
          'Frequency'
          'Cumulative Frequency'
          'Probability'
          'Cumulative Probability')
        TabOrder := 6
        OnClick := DrawchartE
      end
      object GenEBtn: TButton
        Left := 20
        Top := 546
        Width := 92
        Height := 31
        Caption := 'Run a set'
        TabOrder := 7
        OnClick := GenEBtnClick
      end
    end *)
    //object TabSheet6: TTabSheet
    TabSheet6:= TTabSheet.create(form1)
    with tabsheet6 do begin
      parent:= pagecontrol1;
      //Caption := 'Introduction'
      pagecontrol:= pagecontrol1
      
      Caption := 'Central Limit Theorem'
      ImageIndex := 5
      //object Label1: TLabel
       Label1:= TLabel.create(self)
      end; 
      with label1 do begin
       parent:= tabsheet6
        Left := 20
        Top := 453
        Width := 74
        Height := 16
        Caption := 'Sample size'
      end ;
       Label2:= TLabel.create(self)
     with label2 do begin
       parent:= tabsheet6
      //object Label2: TLabel
        Left := 20
        Top := 492
        Width := 73
        Height := 16
        Caption := 'Nbr Buckets'
      end;
        Label3:= TLabel.create(self)
     with label3 do begin
       parent:= tabsheet6
        Left := 246
        Top := 453
        Width := 93
        Height := 16
        Caption := 'Number of trials'
      end ;
      aMemo1:= TMemo.create(form1)
      with amemo1 do begin
      parent:= tabsheet6
        Left := 10
        Top := 10
        Width := 631
        Height := 415
        Color := 14548991
        Font.Charset := DEFAULT_CHARSET
        Font.Color := clWindowText
        Font.Height := -17
        Font.Name := 'MS Sans Serif'
        Font.Style := []
        Lines.add (CRLF+
          'The Central Limit theorem is one of the more amazing theorems in' +
            +' mathematics.'
          +''
         + 'The distribution of a random variable describes the way that the' +
           + ' possible values'
         +'of the variable are spread.   The Normal or Gaussian is one that' +
           + ' occurs'
        + 'often in nature and appears as the familiar bell shaped curve - ' +
           + 'the values fall'
        + 'equally above and below the mean and most of the values lie near' +
           + ' the mean.'
          +''
        + 'Other distributions inlclude uniform - each value equally likely' +
           + ',  Poisson - values'
          +'skewed toward the lower end, exponential, etc.'
         + ''+CRLF+CRLF+CRLF+
        +  'The Central Limit Theorem says that if you take equal sized samp' +
          +  'les from any random '
       +  'distribution,sums (or means) of these samples will be normally d' +
          +  'istributed!'
          +''+CRLF+CRLF+
     + 'We'#39'll illustrate that here sum summing groups of uniformly distr' +
      +      'ibuted random real '
       +   'numbers between 0 and 1. '
        +  ' '+   'The default values, samples summed in groups of 10 from a total ' +
         +   'population of 10,000 '
      +   'and charted in 50 intervals will illustate a reasonable approxim' +
         +   'ation of the normal '
         + 'distribution.'
         + ''+   'As sample size decreased down towards 1, larger and larger sampl' +
         +   'e sizes are '
      +   'required to produce a smooth normal distribution curve.  At samp' +
         +   'le size 1 of course, '
      +   'the distribution reverts to unifor, no matter how large the popu' +
         +   'lation size.' + '')
        ParentFont := False
        TabOrder := 0
      end;
      //object NbDieEdt: TEdit
      NbDieEdt:= TEdit.create(form1);
      with NbDieEdt do begin
        parent:= tabsheet6;
        Left := 128
        Top := 453
        Width := 50
        Height := 24
        TabOrder := 1
        Text := '10'
      end;
      //object SidesEdt: TEdit
      SidesEdt:= TEdit.create(form1);
      with SidesEdt do begin
        parent:= tabsheet6;
        Left := 128
        Top := 492
        Width := 50
        Height := 24
        TabOrder := 2
        Text := '50'
      end;
      //object TrialsEdt: TEdit
      {TrialsEdt:= TEdit.create(form1);
      with TrialsEdt do begin
        parent:= tabsheet6;
        Left := 364
        Top := 453
        Width := 51
        Height := 24
        TabOrder := 3
        Text := '10000'
      end; }
      GenCBtn:= TButton.create(form1)
      with gencbtn do begin
        parent:= tabsheet6;
        Left := 20
        Top := 537
        Width := 92
        Height := 30
        Caption := 'Run a set'
        TabOrder := 4
        OnClick := @GenCBtnClick
      end ;
      NbrDieUD:= TUpDown.create(form1)
      with NbrDieUD do begin
        parent:= tabsheet6
        Left := 178
        Top := 453
        Width := 19
        Height := 24
        //ApplyDark
        //SmoothStretch
        //TeeShadowSmooth
        //TSpinEdit(NbrDieUD).associate:= 1;
        //SetAssociate
        Associate := NbDieEdt
        max:= 20;
        Min := 1
        Position := 10
        TabOrder := 5
      end;
      //object SidesUD: TUpDown
       SidesUD:= TUpDown.create(form1)
      with SidesUD do begin
        parent:= tabsheet6
        Left := 178
        Top := 492
        Width := 19
        Height := 24
        Associate := SidesEdt
        Min := 10
        Position := 50
        TabOrder := 6
      end;
      TrialsUD:= TSpinEdit.create(form1)
      with TrialsUD do begin
        parent:= tabsheet6
        Left := 415
        Top := 453
        Width := 80
        Height := 24
        //editorenabled:= true;
        increment:= 1;
        //caption:= 'true';
        //Associate := TrialsEdt
        Minvalue := 1
        Maxvalue := 30000
        value := 9000
        TabOrder := 7
      end;
    //end;
  //end *)
  StaticText1:= TStaticText.create(form1)
  with statictext1 do begin
    parent:= form1;
    Left := 0 ;    Top := 636
    Width := 844
    Height := 20
    Cursor := crHandPoint
    Align := alBottom
    Alignment := taCenter
    //BorderStyle := sbsSingle
    Caption := 'Copyright  '#169' 2003, Gary Darby, Max, www.DelphiForFun.org'
    Font.Charset := DEFAULT_CHARSET
    Font.Color := clBlue
    Font.Height := -15
    Font.Name := 'MS Sans Serif'
    //Font.Style := [fsUnderline]
    ParentFont := False
    TabOrder := 1
    OnClick := @StaticText1Click
  end;  //*)
  {object OpenDialog1: TOpenDialog
    FileName := 'reactiondetail.rsd'
    Filter := 'Reaction detail (*.rsd)|*.rsd|All files (*.*)|*.*'
    Left := 568
    Top := 8
  end   }
end ;



procedure TMyMemoPaintImages;
var MCanvas: TControlCanvas;
  DrawBounds: TRect;
  //i, j: Integer;
  OriginalRegion: HRGN;
  ControlDC: HDC;
begin
   MCanvas := TControlCanvas.Create;
   DrawBounds := memo6.ClientRect;
   try
     MCanvas.Control := memo6; //Self;
     ControlDC := GetDC ( memo6.Handle );
     MCanvas.Draw(0, 1, Application.Icon);
   finally
     MCanvas.Free;
   end;
end;


//procedure TMyMemoWMPaint(var Message: TWMPaint);
procedure TMyMemoWMPaint;
var MCanvas: TControlCanvas;
  DrawBounds: TRect;
  //afrm: TForm;
begin
//  inherited;
  MCanvas := TControlCanvas.Create;
  DrawBounds := memo6.ClientRect;
   try
     MCanvas.Control := memo6 //Self;
      with MCanvas do begin
        Brush.Color := clBtnFace;
        FrameRect( DrawBounds );
        InflateRect( DrawBounds, - 1, -302);
        FrameRect( DrawBounds );
        FillRect ( DrawBounds );
        MoveTo ( 33, 0 );
        Brush.Color := clRed;
        LineTo ( 33, memo6.ClientHeight );
        MoveTo ( 0, 33 );
        LineTo ( memo6.ClientHeight,33 );
        TMyMemoPaintImages;
      end;
   finally
     MCanvas.Free;
   end;
end;

(*procedure TMyMemoWMEraseBkGnd(var Message: TWMMessage); //TWMEraseBkGnd);
begin
  {assuming we get a good DC in Message - you should check this of course}
  BitBlt(Message.dc, 0, 0, Width, Height, FImage.Canvas.Handle, 0, 0, SRCCOPY);
  Message.Result := - 1;
end; *)

procedure TMyMemoWMPaint2;
var
  bm: TBitmap;
  dc: HDC;
  hDummy: HWND;
  i: integer;
  //tm: TEXTMETRIC;
  Y: integer;
  act: TControl;
begin
  bm := TBitmap.Create;
  //http://www.delphidabbler.com/tips/209
  //TRANSPARENT:= 003;
  try
    bm.Width := form1.Width;
    bm.Height := form1.Height;
    act.Perform(WM_ERASEBKGND, bm.Canvas.Handle, 0); {always in this simple example}
    bm.Canvas.Font.Assign(form1.Font);
    //    GetTextMetrics(bm.Canvas.Handle, tm);
    //SetBkMode(bm.Canvas.Handle, TRANSPARENT);
    Y := 0;
    for i := 0 to memo6.Lines.Count - 1 do begin
      bm.Canvas.TextOut(0, Y, memo6.Lines[i]);
      //Inc(Y, tm.tmHeight);
    end;
    dc := GetDC(hDummy);
    BitBlt(dc,0,0, memo6.Width, memo6.Height, bm.Canvas.Handle, 0, 0, SRCCOPY);
    ReleaseDC(hDummy, dc);
  finally
    bm.Free;
  end;
  //Message.Result := 0;
end;

  //http://www.delphigroups.info/2/7e/24419.html
 type
  TPalet{*word*249} = record
              peRed: Byte;
              peGreen: Byte;
              peBlue: Byte;
              peFlags: Byte;
           end;  
  
  TLogPalette = record
             palVersion: Word;
             palNumEntries: Word;
             palPalEntry: array[0..0] of TPalet{*word*249};//try;
          end; 
          
  LogPal = record
   lpal : TLogPalette;
    hp: HPalette; 
  //dummy:Array[0..255] of TPaletteEntry;
    dummy: integer;
  end; 

//http://docs.embarcadero.com/products/rad_studio/delphiAndcpp2009/HelpUpdate2/EN/html/delphivclwin32/Controls_TWinControl_GetDeviceContext.html
        
procedure TMyControlSaveAsBmp(fileName: TFileName; self: TForm);
var
  Source: TComponent;
  SysPal : LogPal;
  tempCanvas: TCanvas;
  sourceRect, destRect: TRect;
  image2save: TImage;
  notUsed: HWND;
begin
   tempCanvas := TCanvas.Create;
     try
       //tempCanvas.Handle := GetDeviceContext(notUsed);
       tempCanvas.Handle := GetDC(notUsed);
       image2save:=TImage.create(Nil);
       try
         with image2save do begin
           Height := Self.Height;
           Width :=  Self.Width;
           destRect := Rect(0,0,Width,Height);
           sourceRect := destRect;
           Canvas.CopyRect(destRect,tempCanvas,sourceRect);
           SysPal.lPal.palVersion:=$300;
           SysPal.lPal.palNumEntries:=256;
           //GetSystemPaletteEntries(
             //tempCanvas.Handle,0,256,SysPal.lpal.palPalEntry);
           //Picture.Bitmap.Palette:= CreatePalette(Syspal.lpal);
         end;
         image2save.Picture.SaveToFile(fileName);
       finally
        image2save.Free;
       end;
     finally
       tempCanvas.Free;
     end;
end;

procedure TForm1Button1ClickSaveControl(Sender: TForm);
begin
  //MyControl1.SaveAsBmp('foo.bmp');
  //MyControl1:= TMyControl.Create(Form1);
  //MyControl1.Parent:= Form1;
  //MyControl1.visible := true;
   //sender.parent:= Form1;
   TMyControlSaveAsBmp(exepath+'savecontroltest.bmp',sender)
end;

 var wastext1: boolean;

Begin //@main

  loadChartForm;
  FormCreate(Self);
  maXcalcF('e^(8*ln(2))')
  
  //writeln('model chars' +model_chars[7])
  setmodelchars;
  writeln('model chars: ' +model_chars[6])
  model_chars:= letmodelchars2; 
  model_chars[5]:= model_chars[5];
  writeln('model chars: ' +letmodelchars3[7])
  //model_chars[3]:= letmodelchars2[4];
  
  TMyMemoWMPaint;
  TForm1Button1ClickSaveControl(self);
  
  {wastext1:= false;
  srlist:= TStringlist.create;
  writeln(itoa(LoadDFMFile2Strings('C:\maXbox\mX46210\DataScience\ProbabilityDistSource\U_ProbChart.dfm',srlist,wastext1)));
  writeln(srlist.text)
  srlist.free;  }

End.

 {ref of dfm
 ÿ   To close the form and free it in an OnClose event, set Action to caFree. 
  caFree:  	
    The form is closed and all allocated memory for the form is freed.  }

{The major areas in numerical analysis are represented in this Toolbox, with each
chapter focusing on a particular problem. Each routine begins with a general
description of the implemented algorithm or numerical method. (References to
numerical analysis texts are provided for each numerical procedure.) User-supplied
types, functions, and input and output parameters are defined, and the syntax of
the procedure call is provided. If appropriate, a "Comments" section is also provided.
Finally, every algorithm in the Toolbox is accompanied by a general-purpose
program that handles all the necessary I/O, while allowing you to try each algorithm
without building any code. Handily, these sample programs will often reduce
the coding your own application may require.
C:\maXbox\softwareschule\IBZ_2016\IBZ_IT_Security_2017\pki2018\pki2017\pki2017\o
penssl-1.0.2l-i386-win32>nslookup www.softwareschule.ch
Server:  sdsrv.itlab.local
Address:  172.16.1.3

Non-authoritative answer:
Name:    xwinasp01.xm-rz.net
Address:  91.236.78.59
Aliases:  www.softwareschule.ch

https://thelearninggeek.wordpress.com/tag/google-hack/

}
