unit StatsmodelsTutorial_163_164_MachineLearning_plotdataset;
//note writes a file named: confusion_matrix145png
// https://maxbox6.wordpress.com/2025/11/25/machinelearning-steps/
{https://rosettacode.org/wiki/Spinning_rod_animation/Text#Delphi  ,   adapt to maXbox5
https://medium.com/@maxkleiner1/statsmodels-for-python-and-delphi-8fcc890f78c2
 This program may be used or modified for any non-commercial purpose 👉
 so long as this original notice remains in place.
 All other rights are reserved    - test script for embeeding  ラーメン - not finished!🧰
  Library: SysUtils,StdCtrls  throbber(c("🌑", "🌒", "🌓", "🌔", "🌕", "🌖", "🌗", "🌘"))}
 
 var CA: array [0..3] of char; // = ('|','/','-','\');
 
procedure SpinningRod(Memo: TMemo);
var I: integer;
    LastKey: char;
//const CA: array [0..3] of char = ('|','/','-','\');
 begin
 LastKey:=#0;
   for I:=0 to 100 do begin
      Memo.SetFocus;
      Memo.Lines.Clear;
      Memo.Lines.Add('  '+CA[I mod 4]+' - Press Any Key To Stop');
      writeln(itoa(getlastinput));
      lastkey:= inttochar(getlastinput);
      //writeln(lastkey);
      Sleep(250);
      //lastkey:= inttochar(getlastinput);
      //if (LastKey<>#0) or Application.Terminated then break;
      if (iskeypressed) or Application.Terminated then break;
      Application.ProcessMessages;
    end;
 end; 
 
 procedure initchars;
 var phase: string;
 begin
   CA[0]:='|'; CA[1]:='/';
   CA[2]:= '-'; CA[3]:='\';
   phase:='🌑" "🌒""🌓"';   //Type mismatch
   //println(phase);
   //phase:= ^I;
   //AssignFileWrite('mystring 🌑"', exepath+'examples\myfilewrite.txt');
    // AssignFileWrite(memo1.text, exepath+'examples\myfilewrite.txt');
 
   //SaveStringUC(exepath+'examples\myfilewriteuc.txt','mystring '+'🌑',true); 
   //SaveStringUC(exepath+'examples\myfilewriteuc1.txt',memo1.text, false); 
 end;  
 
 procedure PY_Solution;
begin
 with TPythonEngine.Create(Nil) do begin
    autofinalize:= false;
    loadDLL;
    try
      ExecString('import sys,re,io');
      ExecString('from time import sleep');
      //ExecString(PYFUNC);
      //# Unicode: 9601, 9602, 9603, 9604, 9605, 9606, 9607, 9608
      execstr('output = io.StringIO(); sys.stdout = output'); 
      //ExecString('while True:                    '+lf+
      ExecString('for i in range(5):                    '+lf+
                 '  for rod in r"\|/-":          '+lf+
                 '      print(rod, end="\r")     '+lf+
                 '      output.getvalue().strip()'+lf+
                // '      print('+memo2.lines[1]+')'+lf+
                 '      sleep(0.25)      ');
      Application.ProcessMessages;      // wont work     
      //addclient(TEngineClient.create(nil));
      println(StringReplace(evalstr('(output.getvalue().strip())'),
                                                   LF,CRLF,[rfReplaceAll]));  
      //writeln('PythonOK '+botostr(PythonOK)+ ' clcount:'+itoa(clientcount));
    except
      raiseError;
    finally
      unloadDll;
      Free;
    end;  
  end;  
end;  


{def writedat(filename, x, y, xprecision=3, yprecision=5):
    with open(filename,'w') as f:
        for a, b in zip(x, y):
            print("%.*g\t%.*g" % (xprecision, a, yprecision, b), file=f)}

const PYWRITE =
'def writedat(filename, x, y, xprecision=3, yprecision=5):               '+lf+
'   with open(filename,"w") as f:                                       '+lf+
'      for a, b in zip(x, y):                               '+lf+
'          print("%.*g\t%.*g" % (xprecision, a, yprecision, b), file=f)';
//'            print >> f, "%.*g\t%.*g" % (xprecision, a, yprecision, b)   ';


procedure PY_Solution_Write;
begin
 with TPythonEngine.Create(Nil) do begin
    autofinalize:= false;
    loadDLL;
    try
      ExecString('import sys,re,io, itertools, math');
      ExecString('from time import sleep');
      ExecString(PYWRITE);
      //# Unicode: 9601, 9602, 9603, 9604, 9605, 9606, 9607, 9608
      execstr('output = io.StringIO(); sys.stdout = output'); 
      //ExecString('while True:                    '+lf+
        execstr('x = [1, 2, 3, 1e11] '+lf+
                'y = map(math.sqrt, x) '+lf+
                '(y)      ');
       //  [1.0, 1.4142135623730951, 1.7320508075688772, 316227.76601683791]
         execstr('writedat(r".\examples\sqrt_1450.txt", x, y) ');
       //check test  
      ExecString('for line in open(r".\examples\sqrt_1450.txt"):'+lf+
                 '   print(line)                                ');
      //addclient(TEngineClient.create(nil));
      println(StringReplace(evalstr('(output.getvalue().strip())'),
                                                   LF,CRLF,[rfReplaceAll]));  
      //writeln('PythonOK '+botostr(PythonOK)+ ' clcount:'+itoa(clientcount));
    except
      raiseError;
    finally
      unloadDll;
      Free;
    end;  
  end;  
end;  

procedure PY_Solution_Statistics;
begin
 with TPythonEngine.Create(Nil) do begin
    autofinalize:= false;
    loadDLL;
    try
      ExecString('import sys,re,io, itertools, math');
      ExecString('import numpy as np');
      //ExecString(PYWRITE);
      //# Unicode: 9601, 9602, 9603, 9604, 9605, 9606, 9607, 9608
      execstr('output = io.StringIO(); sys.stdout = output'); 
      //ExecString('while True:                    '+lf+
      execstr('# Sample data '+lf+
              'x = np.array([1, 2, 3, 4, 5]) # Independent variable  '+lf+
              'y = np.array([2.2, 2.8, 4.5, 3.7, 5.5]) # Dependent variable');
      //# Adding a column of ones for the intercept term 
      execstr('X = np.vstack((np.ones(len(x)), x)).T');
       //check test  
      ExecString('beta = np.linalg.inv(X.T @ X) @ X.T @ y'+lf+
                 'print(f"Intercept (b): {beta[0]:.2f}, Slope (a): {beta[1]:.2f}")');
      //addclient(TEngineClient.create(nil));
      println(StringReplace(evalstr('(output.getvalue().strip())'),
                                                   LF,CRLF,[rfReplaceAll]));  
      //writeln('PythonOK '+botostr(PythonOK)+ ' clcount:'+itoa(clientcount));
    except
      raiseError;
    finally
      unloadDll;
      Free;
    end;  
  end;  
end;  

procedure PY_Machinelearning_steps;
 begin
   with TPythonEngine.Create(Nil) do begin
     //pythonhome:= 'C:\Users\User\AppData\Local\Programs\Python\Python314\';
      try
       loadDLL;
       autofinalize:= false;
       ExecStr('import pandas as pd, io, sys'+lf+
               'import matplotlib.pyplot as plt');
       execStr('from sklearn.model_selection import train_test_split'+lf+
               'from sklearn.ensemble import RandomForestClassifier'+lf+
               'from sklearn import datasets'+lf+
               'from sklearn.metrics import accuracy_score'+lf+
               'from sklearn.metrics import confusion_matrix');
       execstr('output = io.StringIO(); sys.stdout = output');         
       execstr('iris = datasets.load_iris()'+lf+
               'df = pd.DataFrame(iris.data, columns=iris.feature_names)');
       execstr('X_train,X_test, y_train,y_test = train_test_split(df[iris.feature_names],'+
                  'iris.target,test_size=0.5, stratify=iris.target, random_state=123456)');
       execstr('rf = RandomForestClassifier(n_estimators=100, oob_score=True,'+
                                           'random_state=123456)'+lf+
               'rf.fit(X_train, y_train)');   
             
       writeln('Classify accuracy= '+Evalstr('accuracy_score(y_test, rf.predict(X_test))'));
       //('# Precision Recall scores
       execstr('from sklearn import metrics');
       execstr('print("Precision, Recall, Confusion matrix, in testing\n")');
       execstr('print(metrics.classification_report(y_test, rf.predict(X_test), digits=3))');
       println(StringReplace(evalstr('(output.getvalue().strip())'),
                                                   LF,CRLF,[rfReplaceAll]));    
            
      //https://www.blopig.com/blog/2017/07/using-random-forests-in-python-with-scikit-learn/
       execstr('import seaborn as sns');
       execstr('cm = pd.DataFrame(confusion_matrix(y_test, rf.predict(X_test)),'+
                     'columns=iris.target_names, index=iris.target_names)');
       execstr('sns.heatmap(cm, annot=True)'+lf+
               'plt.title("maXbox5 Seaborn ConfusionMatrix Plot")'+lf+
               'plt.savefig("confusion_matrix1452.png")'+lf+
               'plt.show()');
       //execStr('plt.savefig("confusion_matrix1452.png")');
       //openFile(exepath+'confusion_matrix1452.png');  
       
       execStr('iris = pd.DataFrame(                        '+lf+
               'data= np.c_[iris["data"],iris["target"]],   '+lf+
               'columns= iris["feature_names"]+["target"]   '+lf+
               ')                                           ');
       execStr('species = []                       '+lf+
             'for i in range(len(iris["target"])): '+lf+
             '   if iris["target"][i] == 0:        '+lf+
             '       species.append("setosa")      '+lf+
             '   elif iris["target"][i] == 1:      '+lf+
             '       species.append("versicolor")  '+lf+
             '   else:                             '+lf+
             '       species.append("virginica")   '+lf+
             'iris["species"] = species            ');
             
      execstr('print(iris.groupby("species").size())'+lf+
          'setosa = iris[iris.species =="setosa"]   '+lf+
          'versicolor = iris[iris.species =="versicolor"]'+lf+
          'virginica = iris[iris.species =="virginica"]  '+lf+
         'fig, ax = plt.subplots()                       '+lf+
        // 'fig.set_size_inches(13, 7) # adjusting the length and width of plot '+lf+
         '# lables and scatter points                                          '+lf+
         'ax.scatter(setosa["petal length (cm)"],setosa["petal width (cm)"], label="Setosa",facecolor="blue")  '+lf+
         'ax.scatter(versicolor["petal length (cm)"],versicolor["petal width (cm)"],label="Versicolor",facecolor="green")'+lf+
         'ax.scatter(virginica["petal length (cm)"],virginica["petal width (cm)"],label="Virginica",facecolor="red")'+lf+
         'ax.set_xlabel("petal length (cm)")  '+lf+
         'ax.set_ylabel("petal width (cm)")   '+lf+
         'ax.grid()                           '+lf+
         'ax.set_title("Iris petals maXbox5") '+lf+
         'ax.legend()                         '+lf+
         'plt.show()                          ');     //*)
       except
         raiseError;        
       finally      
         Free;
       end; 
   end;
 end;

type VA = array of double;


//function TToString(v: TArray<Double>): TArray<string>;
function TToString(v: VA): TStringArray;
var
  fmt: TFormatSettings;
begin
  //fmt := TFormatSettings.Create('en-US');
  SetLength(Result, length(v));
  for it:= 0 to High(v) do //begin
    //formatfloat(' %.5f ',v[it]);                         [
    //Result[it] := v[it].tostring(ffGeneral, 5, 3, fmt);
     //Result[it]:= format(' %-3.5f ',[v[it]]);
     //label1.caption:=FloatToStrF(zahl,ffFixed,10,3);
      Result[it]:= FloatToStrF(v[it],ffgeneral,5,3);
     //Result[it]:= formatfloat(' %-3.5f ',v[it]);
     //writeln(Result[it]+flots(v[it])); end;
end;

function Merge(a, b: TStringArray): TStringArray;
begin
  SetLength(Result, length(a));
  for it:= 0 to High(a) do
    Result[it]:= a[it] +#9+ b[it]+#10;
end;

function StrArrayJoin(const StringArray: TStringArray; const Separator: string): string;
var
  i : Integer;
begin
  Result:= '';
  for i:= low(StringArray) to high(StringArray) do
    Result:= Result + StringArray[i] + Separator;
  Delete(Result, Length(Result), 1);
end;

var x, y: vA; //TArray<Double>;

begin   //@main
   maxform1.setconsole;
   memo2.font.size:= 10;
   memo2.font.name:= 'Courier';
   initchars();
   //SpinningRod(memo2); //memo2.setfocus;
   //PY_Solution();
   x := [1, 2, 3, 1e11];
   y := [1, 1.4142135623730951, 1.7320508075688772, 316227.76601683791];
   //Merge(TToString(x), TToString(y));
   //StrArrayJoin(Merge(TToString(x), TToString(y)), ' ') ;
  //TFile.WriteAllLines('FloatArrayColumns.txt', Merge(ToString(x), ToString(y)));
   //sr:= StringArrayToString(Merge(TToString(x), TToString(y)), ' ') ;
   AssignFileWrite(StrArrayJoin(Merge(TToString(x), TToString(y)),''), 
                                 exepath+'examples\FloatArrayColumns.txt');
   //openFile(exepath+'examples\FloatArrayColumns.txt')  
   //PY_Solution_Write();    
   
   PY_Solution_Statistics();   
   PY_Machinelearning_steps();                     
 end.
end.

ref: https://colab.research.google.com/github/maxkleiner/maXbox5/blob/main/machinelearningsteps.ipynb
     https://maxbox6.wordpress.com/2025/11/25/machinelearning-steps/
     https://maxbox6.wordpress.com/2025/11/21/statsmodels-for-python-and-delphi/
     https://medium.com/@maxkleiner1/statsmodels-for-python-and-delphi-8fcc890f78c2
     https://rosettacode.org/wiki/Spinning_rod_animation/Text#Delphi
     https://rosettacode.org/wiki/Spinning_rod_animation/Text#Python
     https://www.quarkml.com/2022/05/iris-dataset-classification-with-python.html
     throbber(c("⬍", "⬈", "➞", "⬊", "⬍", "⬋", "⬅", "⬉"))
     Chart = チャート Chāto
     
     I had an accident in a dream. Last week, during the night, I got up to use the restroom and 
     tripped over a comforter that had fallen on the floor. To make a long story short, 
     I fell flat on my face.
       X-rays and CT scans revealed that I had fractured my face.
       
       Palantir „Maven“ ist im Kern eine militärische KI- und Datenplattform, die Sensordaten (z.B. 
       Satelliten, Drohnen, Funk, Logistiksysteme) zusammenführt, automatisch auswertet und für Lagebild, 
       Zielerkennung und Einsatzführung nutzbar macht.​

Einordnung und Zweck
Palantir Maven Smart System (oft kurz „Maven“) ist ein Produkt, das aus dem US‑Verteidigungsprojekt „Project Maven“ 
hervorgegangen ist und heute von US‑Streitkräften, NATO und anderen genutzt wird. Es dient dazu, sehr große, 
heterogene Datenmengen für Aufklärung, Planung und Command‑&‑Control in Echtzeit nutzbar zu machen, insbesondere 
im Bereich Zielerkennung und Gefechtsfeld‑Transparenz.​

Datenquellen und Fusion
Maven aggregiert Daten aus vielen C2‑Systemen, Sensoren, Drohnen, Satelliten, 
Geolokationsquellen und offenen Daten in einem gemeinsamen Datenraum. Diese Daten werden 
vereinheitlicht, georeferenziert und in ein durchsuchbares Modell überführt, sodass 
Nutzer nicht in Rohdaten, sondern in Objekten wie Einheiten, Orten, Ereignissen oder Zielen denken können.​

KI‑Funktionen
Aus dem ursprünglichen „Project Maven“ stammt die Fähigkeit, Bild- und Sensordaten 
automatisch zu analysieren, etwa um Objekte in Überwachungs‑Videos oder Satellitenbildern 
zu erkennen und zu klassifizieren. Darauf aufbauend bietet Maven heute Funktionen 
wie automatische Zielvorschläge, Priorisierung von Bedrohungen, Mustererkennung 
und Unterstützung bei der Einsatzplanung.​

Einsatz im Gefechtsfeld
Das System liefert Kommandeuren ein gemeinsames Lagebild, indem es Bewegungen eigener 
und gegnerischer Kräfte auf Karten visualisiert und mit weiteren Informationsschichten
 (Logistik, Wetter, Aufklärungsergebnisse) kombiniert. Durch diese Integration sollen Entscheidungen
  schneller getroffen werden, etwa bei Feuerleitung, Truppenverlegung oder maritimer Überwachung.​

Technische Rolle innerhalb Palantir
Maven nutzt Palantirs bestehende Plattform‑Bausteine: Datenfusion und Analyse wie in Gotham, 
sowie die Auslieferung/Updates über die Deploy‑Plattform Apollo. Es ist also keine völlig 
eigenständige Codebasis, sondern eine domänenspezifische Konfiguration von Palantirs 
Kern‑Technologie für militärische KI‑Anwendungen.​

Wenn du magst, kann die Funktionsweise auch stärker „technisch“ (Architektur, 
mögliche Pipelines, verwendbare ML‑Modelle) oder aus ethisch‑politischer Sicht beleuchtet werden.

Welche ML-Modelle sind im Einsatz?

Palantirs Maven Smart System nutzt verschiedene Machine-Learning-Modelle, die 
sich vor allem auf Computer Vision und Sensorfusion konzentrieren. Typische eingesetzte 
ML-Techniken sind:

Bild- und Videoanalyse mit Deep-Learning-Modellen für Objekt- und Zielerkennung in 
Überwachungs- und Satellitendaten

Mustererkennung und Klassifikation, um relevante Ziele oder Bedrohungen automatisch zu identifizieren

Sensorfusion-Algorithmen, die Daten aus mehreren Quellen (Drohnen, Satelliten, Radar, etc.) 
in ein gemeinsames Lagebild integrieren

Workflow-orientierte KI, die Entscheider bei Priorisierung und automatisierten Schritten 
im Zielerfassungsprozess unterstützt

Speziell erwähnt wird der Einsatz von Computer-Vision-Algorithmen, die z.B. in Echtzeit 
Objekte auf Bildern erkennen und klassifizieren, um militärische Zielerfassung zu  
beschleunigen und zu präzisieren.​

Palantir selbst bietet auch natürliche Sprachverarbeitungs-Modelle und Embedding-Modelle 
auf seiner Plattform, die in unterschiedlichen Anwendungskontexten eingesetzt werden können, 
wie z.B. zur Analyse von Textdaten oder für KI-gestützte Workflows, allerdings ist unklar, 
ob diese konkret im Maven System zum Einsatz kommen.​

Zusammengefasst ist Maven eine spezialisierte KI-Plattform mit Fokus auf:

Deep Learning für visuelle Daten (satellitengestützte Bilderkennung)

Multi-Sensor-Datenfusion

Entscheidungsunterstützung durch KI-gestützte Priorisierung und Workflow-Integration

Diese Modelle sind eng in ein operatives System eingebettet, 
das Live-Datenströme aus dem Gefechtsfeld verarbeiten und in Echtzeit nutzen kann.​

Ähnlich

Welche Computer‑Vision‑Modelle nutzt Maven für Zielerkennung

Welche Klassifikations‑ und Segmentierungsarchitekturen werden verwendet

Welche Spracherkennungs‑ oder NLP‑Modelle sind integriert

Wie werden Modelle trainiert und mit welchen Datensätzen

Welche Laufzeitframeworks und Hardwarebeschleuniger nutzt Maven
Sie haben Ihre drei Pro-Suchen für heute ausgeschöpft. Upgrade für unbegrenzten Zugriff
Antworten werden jetzt die grundlegende Suche verwenden, bis Ihr Limit sich morgen zurücksetzt.






     
     
import pandas as pd
import numpy as np
import statsmodels.api as sm
import matplotlib.pyplot as plt
import seaborn as sns

# Sample dataset creation
data = {
    'Size': np.random.randint(500, 4000, 200),  # Size in square feet
    'Bedrooms': np.random.randint(1, 6, 200),   # Number of bedrooms
    'Age': np.random.randint(0, 30, 200),       # Age of the house
}
data['Price'] = 15000 + data['Size'] * 200 + data['Bedrooms'] * 7500 - data['Age'] 
* 300 + np.random.normal(0, 10000, 200)

df = pd.DataFrame(data)

# Define independent variables (X) and dependent variable (y)
X = df[['Size', 'Bedrooms', 'Age']]
y = df['Price']

# Add a constant term to the independent variables
X = sm.add_constant(X)
model = sm.OLS(y, X).fit() # Fit the OLS regression model
print(model.summary())

R-Squared and Adjusted R-Squared:
R-squared (0.760) indicates that 76% of the variance in house prices is explained by the model. 
This is a strong indicator of model fit.
Adjusted R-squared (0.755) accounts for the number of predictors, providing a more conservative 
estimate of model performance, particularly when comparing models with different numbers of variables.
F-Statistic and Prob (F-Statistic):
F-statistic (124.5) assesses the overall significance of the regression model. A high value 
indicates that at least one predictor variable is significantly related to house prices.
Prob (F-statistic) of 
1.45
×
1
0
20
1.45×10 
20
  shows that the model is statistically significant.
     
     https://linuxschweizag.wordpress.com/wp-content/uploads/2021/05/20170415_125144.jpg?w=2048
     
     Der SVT Leipzig mit der Nummer 137234 gehört dem Förderverein Diesel-Schnelltriebwagen, 
     der sich im Jahr 2000 gründete, um einige Zeitzeugen der Eisenbahngeschichte für die Nachwelt zu erhalten. 
     Laut einem Flyer des Vereins wurde zunächst der SVT Köln (Baujahr 1938) innen und äußerlich komplett 
     aufgearbeitet. Nachdem dies bis zum Jahr 2014 abgeschlossen war, kümmerte man sich um den SVT Leipzig, 
     der in den Jahren 1935/36 gebaut wurde. Er ist der letzte dieselelektrische Triebwagen dieser Art.

(*----------------------------------------------------------------------------*)
procedure SIRegister_TGoBlock(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TObject', 'TGoBlock') do
  with CL.AddClassN(CL.FindClass('TObject'),'TGoBlock') do
  begin
    RegisterProperty('id', 'integer', iptrw);
    RegisterProperty('color', 'TStonecolor', iptrw);
    RegisterProperty('openedges', 'integer', iptrw);
    RegisterProperty('stonelist', 'TStringlist', iptrw);
    RegisterMethod('Constructor Create');
    RegisterMethod('Procedure Free');
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_U_Go3(CL: TPSPascalCompiler);
begin
  CL.AddTypeS('TstoneColor', '( goblack, gowhite, goempty, goinvalid )');
  CL.AddTypeS('TStoneRec', 'record occupiedBy : TstoneColor; blocknbr : integer; end');
 //TGoBoard=array[0..18,0..18] of TStonerec;
 CL.AddTypeS('TGoBoard', 'array[0..18] of array[0..18] of TStonerec;');
  CL.AddTypeS('TGoBoards', 'array[0..1] of TGoBoard;');
  //CL.AddTypeS('Tgoblocks', 'array of TGoBlock;');
  CL.AddTypeS('TGoScore', 'array[0..1] of integer;');
  SIRegister_TGoBlock(CL);
  CL.AddTypeS('Tgoblocks', 'array of TGoBlock;');
  SIRegister_TGoForm1(CL);
end;

Form

  object Savedialog1: TSaveDialog
    DefaultExt = 'txt'
    Filter = 'Text file (*.txt)|*.txt|All files (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 616
    Top = 24
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'txt'
    Filter = 'Text files (*.txt)|*.txt|All files (*.*)|*.*'
    Left = 544
    Top = 24
  end
end

add a new property

procedure TFormRoundedCorners_R(Self: TForm; var T: TRoundedCornerType);
begin T := Self.RoundedCorners;
end;

procedure TFormRoundedCorners_W(Self: TForm;  T: TRoundedCornerType);
begin  Self.RoundedCorners:= T ;
end;

 /// <summary> Type used by form RoundedCorners property and DefaultRoundedCorners class property </summary>
  TRoundedCornerType = (
    /// <summary>Windows default or global app setting</summary>
    rcDefault,
    /// <summary>Rounded corners disabled</summary>
    rcOff,
    /// <summary>Rounded corners active</summary>
    rcOn,
    /// <summary>Rounded corners active, but with small radius</summary>
    rcSmall     );
  
     property RoundedCorners: TRoundedCornerType read FRoundedCorners write SetRoundedCorners default TRoundedCornerType.rcDefault;
 
     CL.AddTypeS('TRoundedCornerType', '( rcDefault, rcOff, rcOn, rcSmall )');
     RegisterProperty('RoundedCorners', 'TRoundedCornerType', iptrw);
     RegisterPropertyHelper(@TFormRoundedCorners_R, @TFormRoundedCorners_W,'RoundedCorners');

  Das japanische Wort Manhōru (マンホール, Manhooru) ist vom englischen Wort manhole (Schacht) abgeleitet. 
  Manchmal findet man im Zusammenhang 
  mit Kanaldeckeln auch den Zusatz no futa, was auf Japanisch „Deckel“ (蓋, futa) bedeutet.




