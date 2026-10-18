// maXbox5 / maXbox6 Script: 2x2 Confusion Matrix for Person A (9-Person Social Recognition)
// Computes and graphically renders a Confusion Matrix natively in Object Pascal
// for Tutorial 20the confusion matrix
// Script v2: Interactive 2x2 Confusion Matrix Simulator
// Allows real-time editing of TP, FN, FP, and TN values via GUI input controls
//TODO: metrics nominator/denominator do variable

program Person_A_Confusion_Matrix2Interactiv;

type
  TMatrix2x2 = array[0..1] of array[0..1] of Integer;
  TTStringArray = array[0..1] of string;

var
  Form1: TForm;
  ImgCanvas: TImage;
  MemoLog: TMemo;
  BtnCalc: TButton;
  EdtTP, EdtFN, EdtFP, EdtTN: TEdit;
  LblTP, LblFN, LblFP, LblTN: TLabel;
  ClassNames: TTStringArray;

procedure CalculateAndDrawMatrix(Sender: TObject);
var
  CM: TMatrix2x2;
  r, c, TotalSamples, Correct: Integer;
  Acc, Prec, rRec, F1, Spec: Double;
  W, H, CellW, CellH, OffX, OffY, rVal, MaxVal: Integer;
  ColorVal: Byte;
begin
  // Class Names
  ClassNames[0]:= 'Known';
  ClassNames[1]:= 'Don''t Know';

  // Populate 2x2 Confusion Matrix Counts based on Person A's 9-Person Scenario:
  // TP (Known -> Known) = 3
  // FN (Known -> Don't Know) = 2
  // FP (Don't Know -> Known) = 1
  // TN (Don't Know -> Don't Know) = 3
  CM[0][0]:= 3; // TP
  CM[0][1]:= 2; // FN
  CM[1][0]:= 1; // FP
  CM[1][1]:= 3; // TN

  TotalSamples:= CM[0][0] + CM[0][1] + CM[1][0] + CM[1][1]; // 9
  Correct:= CM[0][0] + CM[1][1]; // 6
  Acc:= (Correct * 100.0) / TotalSamples; // 66.67%

  // Metrics for "Known" (Positive class)
  if (CM[0][0] + CM[1][0]) > 0 then Prec:= (CM[0][0] * 100.0) / (CM[0][0] + CM[1][0]) else Prec:= 0.0; // 3/4 = 75.0%
  if (CM[0][0] + CM[0][1]) > 0 then rRec:= (CM[0][0] * 100.0) / (CM[0][0] + CM[0][1]) else rRec:= 0.0;   // 3/5 = 60.0%
  if (CM[1][1] + CM[1][0]) > 0 then Spec:= (CM[1][1] * 100.0) / (CM[1][1] + CM[1][0]) else Spec:= 0.0; // 3/4 = 75.0%
  if (Prec + rRec) > 0 then F1:= (2.0 * Prec * rRec) / (Prec + rRec) else F1:= 0.0;                 // 66.67%

  // Memo Log Output
  MemoLog.Clear;
  MemoLog.Lines.Add('=== PERSON CONFUSION MATRIX ===');
  MemoLog.Lines.Add('Total People Evaluated : '+ IntToStr(TotalSamples));
  MemoLog.Lines.Add('Overall Accuracy : '+ FormatFloat('0.00%', Acc));
  MemoLog.Lines.Add('');
  MemoLog.Lines.Add('ACTUAL \ PREDICTED | Known | Don''t Know | Total');
  MemoLog.Lines.Add('----------------------------');
  MemoLog.Lines.Add(Format('%-16s | %2d | %2d | %2d',[ClassNames[0],CM[0][0],CM[0][1],CM[0][0]+CM[0][1]]));
  MemoLog.Lines.Add(Format('%-16s | %2d | %2d | %2d',[ClassNames[1],CM[1][0],CM[1][1],CM[1][0]+CM[1][1]]));
  MemoLog.Lines.Add('----------------------------');
  MemoLog.Lines.Add(Format('%-16s | %2d | %2d | %2d',['Total Predicted',CM[0][0]+CM[1][0],CM[0][1]+CM[1][1],TotalSamples]));
  MemoLog.Lines.Add('');
  MemoLog.Lines.Add('--- KEY EVALUATION METRICS ---');
  MemoLog.Lines.Add('Precision (Known)   : ' + FormatFloat('0.00%', Prec) + ' (3/4)');
  MemoLog.Lines.Add('Recall / Sensitivity: ' + FormatFloat('0.00%', rRec) + ' (3/5)');
  MemoLog.Lines.Add('Specificity         : ' + FormatFloat('0.00%', Spec) + ' (3/4)');
  MemoLog.Lines.Add('F1-Score            : ' + FormatFloat('0.00%', F1));

  // Render Canvas
  W:= ImgCanvas.Width;
  H:= ImgCanvas.Height;
  ImgCanvas.Canvas.Brush.Color:= $DCF8FF //$3F85CD; //$ADDEFF; clWhite;
  ImgCanvas.Canvas.FillRect(Rect(0, 0, W, H));

  MaxVal:= 3;
  OffX:= 120; OffY:= 110; CellW:= 100; CellH:= 100;

  // Title and Axis Labels
  ImgCanvas.Canvas.Font.Name:= 'Arial';
  ImgCanvas.Canvas.Font.Size:= 14;
  ImgCanvas.Canvas.Font.Style2:= fsBold2;
  ImgCanvas.Canvas.Font.Color:= clBlack;
  ImgCanvas.Canvas.TextOut(OffX - 2, 35, 'Predicted Status');
  ImgCanvas.Canvas.TextOut(10, OffY + 80, 'Actual');

  // Column Headers
  ImgCanvas.Canvas.Font.Size:= 9;
  ImgCanvas.Canvas.TextOut(OffX - 1, OffY - 30, ClassNames[0]);
  ImgCanvas.Canvas.TextOut(OffX + CellW - 1, OffY - 30, ClassNames[1]);
  ImgCanvas.Canvas.TextOut(OffX , OffY + 220, 'Sample Size: 9');
  
  // Cells
  for r:= 0 to 1 do begin
    ImgCanvas.Canvas.TextOut(10, OffY + r * CellH + 40, ClassNames[r]);

    for c:= 0 to 1 do begin
      rVal:= CM[r][ c];
      // Color intensity based on count
      ColorVal:= 255 - Round((rVal / MaxVal) * 160);
      
      // Diagonal cells (TP, TN) green/teal, Off-diagonal (FN, FP) orange/amber
      if r = c then
        ImgCanvas.Canvas.Brush.Color:= RGB(ColorVal, 255, ColorVal)
      else
        ImgCanvas.Canvas.Brush.Color:= RGB(255, 230, ColorVal);

      ImgCanvas.Canvas.Pen.Color:= clNavy;
      ImgCanvas.Canvas.Pen.Width:= 2;
      ImgCanvas.Canvas.Rectangle(OffX+ c * CellW, OffY+ r * CellH, 
                                 OffX+ (c+ 1) * CellW, OffY+ (r+ 1) * CellH);
      // Value & Label text inside cell
      ImgCanvas.Canvas.Font.Size:= 16;
      ImgCanvas.Canvas.Font.Style2:= fsBold2;
      ImgCanvas.Canvas.Font.Color:= clBlack;
      ImgCanvas.Canvas.Brush.Style:= bsClear;
      ImgCanvas.Canvas.TextOut(OffX + c * CellW + 42, OffY + r * CellH + 28, IntToStr(rVal));
      ImgCanvas.Canvas.Font.Size:= 8;
      ImgCanvas.Canvas.Font.Style2:= fsNormal;
      if (r=0) and (c=0) then ImgCanvas.Canvas.TextOut(OffX + c * CellW + 15, OffY + r * CellH + 65, '(True Pos)')
      else if (r=0) and (c=1) then ImgCanvas.Canvas.TextOut(OffX+ c * CellW+ 10, OffY+ r * CellH+ 65, '(False Neg)')
      else if (r=1) and (c=0) then ImgCanvas.Canvas.TextOut(OffX+ c * CellW+ 10, OffY+ r * CellH+ 65, '(False Pos)')
      else if (r=1) and (c=1) then ImgCanvas.Canvas.TextOut(OffX+ c * CellW+ 15, OffY+ r * CellH+ 65, '(True Neg)');

      ImgCanvas.Canvas.Brush.Style:= bsSolid;
      ImgCanvas.Canvas.Font.Size:= 9;
      ImgCanvas.Canvas.Font.Style2:= fsBold2;
    end;
  end;
end;

procedure CalculateAndDrawMatrixInteractiv(Sender: TObject);
var
  CM: TMatrix2x2;
  r, c, TotalSamples, Correct: Integer;
  Acc, Prec, rRec, F1, Spec: Double;
  W, H, CellW, CellH, OffX, OffY: Integer;
  pVal, MaxVal: Integer;
  ColorVal: Byte;
begin
  // Class Names
  ClassNames[0] := 'Positive(Known)';
  ClassNames[1] := 'Negative(Uknown)';

  // Read interactive inputs from GUI edits
  CM[0][0] := StrToIntDef(EdtTP.Text, 3); // True Positive
  CM[0][1] := StrToIntDef(EdtFN.Text, 2); // False Negative
  CM[1][0] := StrToIntDef(EdtFP.Text, 1); // False Positive
  CM[1][1] := StrToIntDef(EdtTN.Text, 3); // True Negative

  TotalSamples:= CM[0][0] + CM[0][1] + CM[1][0] + CM[1][1]; // 9
  Correct := CM[0][0] + CM[1][1]; // 6;
  Acc:= (Correct * 100.0) / TotalSamples; // 66.67%

(*  if TotalSamples > 0 then
    Acc := (Correct * 100.0) / TotalSamples
  else
    Acc := 0.0;
  // Precision = TP / (TP + FP)
  if (CM + CM) > 0 then
    Prec := (CM * 100.0) / (CM + CM)
  else
    Prec := 0.0;
  // Recall / Sensitivity = TP / (TP + FN)
  if (CM + CM) > 0 then
    Rec := (CM * 100.0) / (CM + CM)
  else
    Rec := 0.0;
  // Specificity = TN / (TN + FP)
  if (CM + CM) > 0 then
    Spec := (CM * 100.0) / (CM + CM)
  else
    Spec := 0.0;
  // F1-Score
  if (Prec + Rec) > 0 then
    F1 := (2.0 * Prec * Rec) / (Prec + Rec)
  else
    F1 := 0.0;     *)
    
     // Metrics for "Known" (Positive class)
  if (CM[0][0] + CM[1][0]) > 0 then Prec:= (CM[0][0] * 100.0) / (CM[0][0] + CM[1][0]) else Prec:= 0.0; // 3/4 = 75.0%
  if (CM[0][0] + CM[0][1]) > 0 then rRec:= (CM[0][0] * 100.0) / (CM[0][0] + CM[0][1]) else rRec:= 0.0;   // 3/5 = 60.0%
  if (CM[1][1] + CM[1][0]) > 0 then Spec:= (CM[1][1] * 100.0) / (CM[1][1] + CM[1][0]) else Spec:= 0.0; // 3/4 = 75.0%
  if (Prec + rRec) > 0 then F1:= (2.0 * Prec * rRec) / (Prec + rRec) else F1:= 0.0;                 // 66.67%

  // Memo Log Output
  MemoLog.Clear;
  MemoLog.Lines.Add('== PERSON CONFUSION MATRIX ==');
  MemoLog.Lines.Add('Total People Evaluated : '+ IntToStr(TotalSamples));
  MemoLog.Lines.Add('Overall Accuracy : '+ FormatFloat('0.00%', Acc));
  MemoLog.Lines.Add('');
  MemoLog.Lines.Add('ACTUAL \ PREDICTED | Known | Don''t Know | Total');
  MemoLog.Lines.Add('----------------------------');
  MemoLog.Lines.Add(Format('%-16s | %2d | %2d | %2d',[ClassNames[0],CM[0][0],CM[0][1],CM[0][0]+CM[0][1]]));
  MemoLog.Lines.Add(Format('%-16s | %2d | %2d | %2d',[ClassNames[1],CM[1][0],CM[1][1],CM[1][0]+CM[1][1]]));
  MemoLog.Lines.Add('----------------------------');
  MemoLog.Lines.Add(Format('%-16s | %2d | %2d | %2d',['Total Predicted',CM[0][0]+CM[1][0],CM[0][1]+CM[1][1],TotalSamples]));
  MemoLog.Lines.Add('');
  MemoLog.Lines.Add('--- KEY EVALUATION METRICS ---');
  MemoLog.Lines.Add('Precision (Known)   : ' + FormatFloat('0.00%', Prec) + ' (3/4)');
  MemoLog.Lines.Add('Recall / Sensitivity: ' + FormatFloat('0.00%', rRec) + ' (3/5)');
  MemoLog.Lines.Add('Specificity         : ' + FormatFloat('0.00%', Spec) + ' (3/4)');
  MemoLog.Lines.Add('F1-Score            : ' + FormatFloat('0.00%', F1));

  // Render Canvas
  W := ImgCanvas.Width;
  H := ImgCanvas.Height;
  ImgCanvas.Canvas.Brush.Color:= $DCF8FF;
  ImgCanvas.Canvas.FillRect(Rect(0, 0, W, H));

  MaxVal := CM[0][0] + CM[0][1] + CM[1][0] + CM[1][1];;
  //if CM > MaxVal then MaxVal := CM;
  //if CM > MaxVal then MaxVal := CM;
  //if CM > MaxVal then MaxVal := CM;
  if MaxVal = 0 then MaxVal := 1;

  OffX := 120; OffY := 110; CellW := 110; CellH := 110;

  // Title and Axis Labels
  ImgCanvas.Canvas.Font.Name := 'Arial';
  ImgCanvas.Canvas.Font.Size := 14;
  ImgCanvas.Canvas.Font.Style2 := fsBold2;
  ImgCanvas.Canvas.Font.Color := clBlack;
  ImgCanvas.Canvas.TextOut(OffX -2, 35, 'Predicted Class');
  ImgCanvas.Canvas.TextOut(10, OffY + 80, 'Actual');

  // Column Headers
  ImgCanvas.Canvas.Font.Size := 9;
  ImgCanvas.Canvas.TextOut(OffX -1, OffY - 30, 'Positive');
  ImgCanvas.Canvas.TextOut(OffX + CellW -1, OffY - 30, 'Negative');
  ImgCanvas.Canvas.TextOut(OffX , OffY + 230, 'Sample Size: '+itoa(maxval));
 
  // Draw 2x2 Heatmap Cells
  for r := 0 to 1 do begin
    if r = 0 then
      ImgCanvas.Canvas.TextOut(10, OffY + r * CellH + 45, 'Positive')
    else
      ImgCanvas.Canvas.TextOut(10, OffY + r * CellH + 45, 'Negative');

    for c := 0 to 1 do begin
      pVal := CM[r][c];
      ColorVal := 255 - Round((pVal / MaxVal) * 160);
      if r = c then
        ImgCanvas.Canvas.Brush.Color := RGB(ColorVal, 255, ColorVal)
      else
        ImgCanvas.Canvas.Brush.Color := RGB(255, 220, ColorVal);

      ImgCanvas.Canvas.Pen.Color := clNavy;
      ImgCanvas.Canvas.Pen.Width := 2;
      ImgCanvas.Canvas.Rectangle(OffX + c * CellW, OffY + r * CellH,
                                 OffX + (c + 1) * CellW, OffY + (r + 1) * CellH);
      ImgCanvas.Canvas.Font.Size := 18;
      ImgCanvas.Canvas.Font.Style2 := fsBold2;
      ImgCanvas.Canvas.Font.Color := clBlack;
      ImgCanvas.Canvas.Brush.Style := bsClear;
      ImgCanvas.Canvas.TextOut(OffX + c * CellW + 45, OffY + r * CellH + 30, IntToStr(pVal));

      ImgCanvas.Canvas.Font.Size := 8;
      ImgCanvas.Canvas.Font.Style2 := fsNormal;
      if (r=0) and (c=0) then ImgCanvas.Canvas.TextOut(OffX + c * CellW + 5, OffY + r * CellH + 75, '(True Pos-TP)')
      else if (r=0) and (c=1) then ImgCanvas.Canvas.TextOut(OffX + c * CellW + 13, OffY + r * CellH + 75, '(False Neg)')
      else if (r=1) and (c=0) then ImgCanvas.Canvas.TextOut(OffX + c * CellW + 13, OffY + r * CellH + 75, '(False Pos)')
      else if (r=1) and (c=1) then ImgCanvas.Canvas.TextOut(OffX + c * CellW + 5, OffY + r * CellH + 75, '(True Neg-TN)');

      ImgCanvas.Canvas.Brush.Style := bsSolid;
      ImgCanvas.Canvas.Font.Size := 9;
      ImgCanvas.Canvas.Font.Style2 := fsBold2;
    end;
  end;
end;

procedure closeForm(Sender: TObject; var Action: TCloseAction);
  begin
    //imagelist2.Free;   
    //FormML.Free;
    action:= caFree;
    Form1:= NIL;
    //Screen.Cursor:= crDefault
    writeln('ML confusion matrix form and canvas closed..');
  end;

procedure ShowGUI;
begin
  Application.Initialize;
  Form1:= TForm.Create(Application);
  Form1.Caption:= 'maXbox Interactive Person A 9-Person Social Recognition Matrix Studio';
  Form1.SetBounds(100, 100, 920, 540);
  Form1.Icon.LoadFromResourceName(HInstance,'XUNIT');//'ZHISTOGRAM');
  Form1.onClose:= @closeForm;
  Form1.Position:= poScreenCenter;
  
  // Input Controls Panel
  LblTP := TLabel.Create(Form1);
  LblTP.Parent := Form1;
  LblTP.SetBounds(20, 18, 120, 20);
  LblTP.Caption := 'True + (TP):';

  EdtTP := TEdit.Create(Form1);
  EdtTP.Parent := Form1;
  EdtTP.SetBounds(130, 15, 60, 24);
  EdtTP.Text := '3';

  LblFN := TLabel.Create(Form1);
  LblFN.Parent := Form1;
  LblFN.SetBounds(230, 18, 120, 20);
  LblFN.Caption := 'False - (FN):';

  EdtFN := TEdit.Create(Form1);
  EdtFN.Parent := Form1;
  EdtFN.SetBounds(340, 15, 60, 24);
  EdtFN.Text := '2';

  LblFP := TLabel.Create(Form1);
  LblFP.Parent := Form1;
  LblFP.SetBounds(20, 52, 120, 20);
  LblFP.Caption := 'False + (FP):';

  EdtFP := TEdit.Create(Form1);
  EdtFP.Parent := Form1;
  EdtFP.SetBounds(130, 49, 60, 24);
  EdtFP.Text := '1';

  LblTN := TLabel.Create(Form1);
  LblTN.Parent := Form1;
  LblTN.SetBounds(230, 52, 120, 20);
  LblTN.Caption := 'True - (TN):';

  EdtTN := TEdit.Create(Form1);
  EdtTN.Parent := Form1;
  EdtTN.SetBounds(340, 49, 60, 24);
  EdtTN.Text := '3';

  BtnCalc:= TButton.Create(Form1);
  BtnCalc.Parent:= Form1;
  BtnCalc.SetBounds(20, 90, 400, 32);
  BtnCalc.Caption:= 'Compute & Render 9-Person Matrix';
  //BtnCalc.OnClick:= @CalculateAndDrawMatrix;
  BtnCalc.OnClick:= @CalculateAndDrawMatrixInteractiv;

  MemoLog:= TMemo.Create(Form1);
  MemoLog.Parent:= Form1;
  MemoLog.SetBounds(20, 128, 400, 340);
  MemoLog.Font.Name:= 'Courier New';
  memolog.color:= $FAFAFF; //$B3DEF5; //$F5F5F5; //clMoneyGreen; //clgray;
  MemoLog.Font.Size:= 8;
  MemoLog.ScrollBars:= ssVertical;

  ImgCanvas:= TImage.Create(Form1);
  ImgCanvas.Parent:= Form1;
  ImgCanvas.SetBounds(440, 15, 440, 453);

  //CalculateAndDrawMatrix(Form1);
  CalculateAndDrawMatrixInteractiv(Form1);
  Form1.Show;
end;

begin   //@main
  setDebugOff;
  maxform1.setconsole; //setConsole
  memo2.font.name:= 'Courier';
  memo2.font.size:= 10;
  ShowGUI();
 // openWeb('https://maxbox6.wordpress.com/wp-content/uploads/2026/05/1503_decoding_the_confusion_matrix_infographic.jpg?w=1440');
end.

ref: https://sourceforge.net/projects/maxbox5/files/EKON30/202_EKON30_The_Embedded_ML_Python_Pipeline_maXbox_Studio_Iristest.pdf/download
     https://sourceforge.net/projects/maxbox5/files/EKON30/201_The_Embedded_ML_Python_Pipeline_maXbox_Studio_signed.pdf/download
     https://raw.githack.com/maxkleiner/maXbox5/main/assets/bayesmatrix.htm
     https://maxbox6.wordpress.com/2025/11/25/machinelearning-steps/
     https://medium.com/@maxkleiner1/from-bayes-theorem-to-confusion-matrix-ee134457cd47

