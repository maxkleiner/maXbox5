{$A8,B-,C-,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q+,R+,S-,T-,U-,V+,W-,X+,Y-,Z1}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00100000}
{$IMAGEBASE $00400000}
{$DYNAMICBASE ON}
{$APPTYPE GUI}
program maXbox5_29beta190;

//{$R '..\..\..\..\IFA2022\maxbox4\OpenWeather.res'}

//{$R *.res}

{$R *.dres}
//{$R sounds.res}

uses
  Forms,
  ShellAPI,
  fMain in 'fMain.pas' {maxform1},
  uPSCompiler in 'pascalscript-master\Source\uPSCompiler.pas',
  infobox1 in 'infobox1.pas' {AboutBox},
  ConfirmReplDlg in 'ConfirmReplDlg.pas' {ConfirmReplDialog},
  FindReplDlg in 'FindReplDlg.pas' {FindReplDialog},
  ide_debugoutput in 'ide_debugoutput.pas' {debugoutput},
  uPSR_dateutils in 'uPSR_dateutils.pas',
  uPSC_dateutils in 'uPSC_dateutils.pas',
  uPSI_StrUtils in 'uPSI_StrUtils.pas',
  uPSC_graphics in 'uPSC_graphics.pas',
  uPSR_graphics in 'uPSR_graphics.pas',
  uPSC_DB in 'uPSC_DB.pas',
  uPSI_IniFiles in 'uPSI_IniFiles.pas',
  uPSR_DB in 'uPSR_DB.pas',
  uPSUtils in 'pascalscript-master\Source\uPSUtils.pas' {/{/{/memorymax3 in 'memorymax3.pas' {winmemory},
  uPSRuntime in 'pascalscript-master\Source\uPSRuntime.pas' {/PassWord in 'PassWord.pas' {PasswordDlg};

//IdMultipartFormData in 'C:\Program Files (x86)\Embarcadero\Studio\22.0\source\Indy10\Protocols\IdMultipartFormData.pas';

{/PassWord in 'PassWord.pas' {PasswordDlg}

//PassWord in 'PassWord.pas' {PasswordDlg};

//uPSUtils in 'uPSUtils.pas';
  //AESPassWordDlg in 'AESPassWordDlg.pas' {PasswordDlg2 Cryptobox};

{$R *.RES}

begin

  if ParamCount=10 then begin
  //for i := 1 to ParamCount do
    //ShellExecute(0, nil, PChar(ParamStr(0)), PChar('"'+ParamStr(i)+'"'),
    ShellExecute(0,NIL,PChar(ParamStr(0)), PChar('"'+ParamStr(1)+'"'), NIL, 1); //SW_SHOWDEFAULT
    Exit;
  end;
  (*if (ParamStr(1) <> '') then begin
     {act_Filename:= ParamStr(1);
     memo1.Lines.LoadFromFile(act_Filename);
     memo2.Lines.Add(Act_Filename + CLIFILELOAD);
     CB1SCList.Items.Add((Act_Filename));   //3.9 wb  bugfix 3.9.3.6
     CB1SCList.ItemIndex:= CB1SCList.Items.Count-1;
     Compile1Click(self);}
    ShellExecute(0,NIL,PChar(ParamStr(0)), PChar('"'+ParamStr(1)+'"'), NIL, 1); //SW_SHOWDEFAULT
      Exit;
     if (ParamStr(2) = 'm') then begin
       //Compile1Click(self);!
       Application.Minimize;
     end;
  end; *)


  Application.Initialize;
  Application.Title := 'Pascal_maXbox5_D12';
  Application.CreateForm(Tmaxform1, maxform1);
  // Application.CreateForm(TPasswordDlg, PasswordDlg);
  if maxform1.STATMemoryReport = true then
    ReportMemoryLeaksOnShutdown:= true;
  //Application.CreateForm(TUCMainDlg, UCMainDlg);
  //Application.CreateForm(Tdebugoutput, debugoutput);
  Application.CreateForm(TConfirmReplDialog, ConfirmReplDialog);
  Application.CreateForm(TFindReplDialog, FindReplDialog);
  Application.Run;
  //Application.ShowMainForm;
end.





