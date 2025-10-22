// ###################################################################
// #### This file is part of the mathematics library project, and is
// #### offered under the licence agreement described on
// #### http://www.mrsoft.org/
// ####
// #### Copyright:(c) 2015, Michael R. . All rights reserved.
// ####
// #### Unless required by applicable law or agreed to in writing, software
// #### distributed under the License is distributed on an "AS IS" BASIS,
// #### WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// #### See the License for the specific language governing permissions and
// #### limitations under the License.
// ###################################################################

unit RandomEng_Mersenne_mX52;

// ############################################
// #### Utility functions for math utils library
// ############################################

interface

//uses Types, MatrixConst, SysUtils, Classes;

type
  TRootFuncWithDerrive = procedure( x : double; var y, dy : double);
  TRootFunc = function( x : double ): double;
  TRandomDouble = function : double; // of object;

function TRandomGeneratorRandMersenneDbl: double;
function gcm2(a, b : NativeInt): NativeInt; // greatest common divisior

//{$WRITEABLECONST ON}
const cDoubleEpsilon = 2.2204460492503131e-016;  // smallest such that 1.0+DBL_EPSILON != 1.0
var cMinDblDivEps: double; //  = 0;     // filled in initialization


implementation

//uses Math;

// ##########################################
// #### utility function implementation
// ##########################################

function Arr( const elements : Array of integer ) : TIntegerDynArray;
var i: Integer;
begin
     SetLength(Result, Length(elements));

     for i := 0 to Length(elements) - 1 do
         Result[i] := elements[i];
end;

procedure DoubleSwap(var a, b: Double); //{$IFNDEF FPC} {$IF CompilerVersion >= 17.0} inline; {$IFEND} {$ENDIF}
var temp : double;
begin
     temp:= a;
     a:= b;
     b:= temp;
end;

type pdouble = double;

procedure DblPtrSwap( var a, b : PDouble);
var temp : PDouble;
begin
     temp:= a;
     a:= b;
     b:= temp;
end;

//(*

const cInsertionTurnOver = 7;
procedure QuickSort2( var A, B : TDoubleDynArray );
var iStack : Array[0..50] of integer;
    i, ir, j, k, l : integer;
    jstack,n : integer;
    am, bm : Double;
//const cInsertionTurnOver = 7;
begin
     n := Length(A);
     l := 0;
     ir := n - 1;
     jstack := 0;

     while true do begin
          if ir - l < cInsertionTurnOver then begin
               for j := l + 1 to ir do begin
                    am := a[j];
                    bm := b[j];
                    i := j - 1;
                    while i >= l do begin
                         if a[i] <= am then
                            break;

                         a[i + 1] := a[i];
                         b[i + 1] := b[i];
                         dec(i);
                    end;
                    a[i + 1] := am;
                    b[i + 1] := bm;
               end;

               if jstack = 0 then
                  exit;

               ir := istack[jstack];
               l := istack[jstack - 1];
               dec2(jstack, 2);
          end
          else begin
               k := (l + ir) div 2;
               DoubleSwap(a[k], a[l + 1]);
               DoubleSwap(b[k], b[l + 1]);

               if a[l] > a[ir] then begin
                    DoubleSwap(a[l], a[ir]);
                    DoubleSwap(b[l], b[ir]);
               end;
               if a[l + 1] > a[ir] then begin
                    DoubleSwap(a[l + 1], a[ir]);
                    DoubleSwap(b[l + 1], b[ir]);
               end;
               if a[l] > a[l + 1] then begin
                    DoubleSwap(a[l], a[l + 1]);
                    DoubleSwap(b[l], b[l + 1]);
               end;

               i := l + 1;
               j := ir;
               am := a[l + 1];
               bm := b[l + 1];
               while True do begin
                    repeat
                          inc(i);
                    until a[i] >= am;
                    repeat
                          dec(j);
                    until a[j] <= am;
                    if (j < i) then
                       break;

                    DoubleSwap(a[i], a[j]);
                    DoubleSwap(b[i], b[j]);
               end;

               a[l + 1] := a[j];
               a[j] := am;
               b[l + 1] := b[j];
               b[j] := bm;
               inc2(jstack, 2);

               // push pointers to larger subarray on stack
               if jStack >= Length(iStack) then
                  xraise (Exception.Create('Stack too small to sort'));

               if (ir - i + 1 >= j - 1) then begin
                    istack[jstack] := ir;
                    istack[jstack - 1] := i;
                    ir := j - 1;
               end else begin
                    istack[jstack] := j - 1;
                    istack[jstack - 1] := l;
                    l := i;
               end;
          end;
     end;
end;

function eps(const val : double) : double;
 begin
     Result:= val*cDoubleEpsilon;
 end;

function MinDblDiv : double;
var small : double;
 begin
     Result:= MinDouble;
     small:= 1/MaxDouble;

     if small > Result then
         Result:= small*(1 + eps(1));
 end;

function lcm2(a, b : NativeInt) : NativeInt;  // least common multiple
 begin
     Result:= (absint(a) div gcm2(a, b)) * absint(b);
 end;

// from https://en.wikipedia.org/wiki/Euclidean_algorithm
function gcm2(a, b : NativeInt) : NativeInt; // greatest common divisior
var t : NativeInt;
 begin
     while b <> 0 do begin
          t:= b;
          b:= a mod b;
          a:= t;
     end;
     Result := a;
 end;

function Next2Pwr(num : NativeInt; maxSize : NativeInt) : NativeInt;
 begin
     Result:= 1;
     while (Result < maxSize) and (Result < num) do
           Result:= Result shl 1;
 end;

// computes the eukledian distance without the destructive underflow or overflow
function pythag(const A, B : double) : double; //{$IFNDEF FPC} {$IF CompilerVersion >= 17.0} inline; {$IFEND} {$ENDIF}
var absA, absB : double;
 begin
     absA:= abs(A);
     absB:= abs(B);

     if absA = 0 then
         Result:= absB
     else if absB = 0 then
         Result:= absA
     else if absA > absB
     then
         Result:= absa*sqrt(1 + sqr(absb/absa))
     else
         Result:= absb*sqrt(1 + sqr(absa/absb));
 end;

function sign(const a: double; const b: double): double; //{$IFNDEF FPC} {$IF CompilerVersion >= 17.0} inline; {$IFEND} {$ENDIF}
 begin
     if b >= 0 then
         Result:= abs(a)
     else
         Result:= -abs(a);
 end;

function GetLocalFMTSet : TFormatSettings;
begin
  (*   {$IF DEFINED(FPC)}
     Result := DefaultFormatSettings;
     {$ELSE}
        {$IF (CompilerVersion <= 21)}
        GetLocaleFormatSettings(0, Result);
        {$ELSE}
        Result := TFormatSettings.Create;
        {$IFEND}
     {$IFEND}  *)
end;

// writes the matrix such that matlab can read it nicely
procedure WriteMtlMtx(const fileName : string; const mtx : TDoubleDynArray; width : integer; prec : integer {= 8});
var s : UTF8String;
    x, y : integer;
    ft : TFormatSettings;
 begin
     ft := GetLocalFMTSet;
     ft.DecimalSeparator := '.';

     with TFileStream.Create(fileName, fmCreate or fmOpenWrite) do 
      try
         for y := 0 to (Length(mtx) div width) - 1 do begin
            s := '';
            for x := 0 to width - 1 do
               //s := s + UTF8String(Format('%.*f,', [prec, mtx[x + y*width]], ft));   fix

            s[length(s)] := #13;
            s := s + #10;
            WriteBuffer(s[1], Length(s));
         end;
      finally
        Free;
      end;
 end;

const cMaxIter = 100;
      cEuler = 0.5521566;
      cFPMin = 1.0e-30;
      cEPS = 6.0e-8;

function ei( x : double ) : double;
var k : integer;
    fact, prev, sum, term : double;
begin
     if x <= 0 then
        xraise (Exception.Create('Bad argument in ei'));
     if x < cFPMin then begin
          Result := ln(x) + cEuler;
          exit;
     end;
     if x <= -ln(cEPS) then
     begin
          sum := 0;
          fact := 1;
          for k := 1 to cMaxIter do begin
               fact := fact*x/k;
               term := fact/k;
               sum := sum + term;
               if term < cEPS*term then begin
                    Result := sum + ln(x) + cEuler;
                    exit;    
               end;
          end;
       raise Exception.Create('Series failed in ei');
     end
     else begin
          sum := 0;
          term := 0;
          for k := 1 to cMaxIter do begin
               prev := term;
               term := term*k/x;
               if term < cEPS then
                  break;
               if term < prev 
               then
                   sum := sum + term
               else begin
                    sum := sum - prev;
                    break;
               end;
          end;
          Result:= exp(x)*(1.0 + sum)/x;
     end;
end;

function expInt( n : integer; x : double ) : double;
{const cMaxIter = 100;
      cEuler = 0.5772156649;
      cFPMin = 1.0e-30;
      cEPS = 1.0e-7;    }
var i, ii, nm1 : integer;
    a, b, c, d, del, fact, h , psi : double;
 begin
     nm1 := n - 1;
     if (n < 0) or (x < 0) or ( (x = 0) and ( n in [0, 1] ) ) then
        xRaise (Exception.Create('Bad Argument for expint'));
     if n = 0 
     then
         Result := exp(-x)/x
     else begin
          if x = 0 
          then
              Result := 1/nm1
          else begin
               if x > 1 then begin
                    b := x + n;
                    c := 1/cFPMin
                    d := 1/b;
                    h := d;
                    for i := 1 to cMaxIter do begin
                         a := -i*(nm1 + i);
                         b := b + 2;
                         d := 1/(a*d + b);
                         c := b + a/c;
                         del := c*d;
                         h := h*del;
                         if abs(del - 1) < cEPS then begin
                              Result := h*exp(-x);
                              exit;
                         end;
                    end;

                  raise Exception.Create('Continued fraction failed in expint');
               end else begin
                    if nm1 <> 0 
                    then
                        Result := 1/nm1
                    else
                        Result := -ln(x) - cEuler;
                    fact := 1;

                    for i := 1 to cMaxIter do begin
                         fact := -fact*x/i;
                         if i <> nm1 
                         then
                             del := -fact/(i - nm1)
                         else begin
                              psi := -cEuler;
                              for ii := 1 to nm1 do
                                  psi := psi + 1/ii;

                              del := fact*(-ln(x) + psi);
                         end;
                         Result := Result + del;
                         if abs(del) < abs(Result)*cEPS then
                            exit;
                    end;
                 raise Exception.Create('Series failed in expint');                    
               end;
          end;
     end;
 end;


// ###########################################
// #### Prime number stuff
// ###########################################

// miller rubin test for 32 bit (aka the integer range we can build with simple instructions)
function MillerRubinTest32( n : UInt32; a : UInt32 ) : boolean;
var m : UInt32;
    d : UInt32;
    e : UInt32;
    p,q : UInt64;
begin
     // only valid for odd inputs
     if n and 1 = 0 then  begin
        result:= false;
        exit; end;

     Result := True;
     m := n - 1;
     d := m shr 1;
     e := 1;

     while (d and 1) = 0 do begin
          d := d shr 1;
          inc(e);
     end;
     p := a;
     q := a;
     d := d shr 1;
     while d <> 0 do begin
          q := q*q;
          q := q mod n;
          if d and 1 <> 0 then
             p := (p*q) mod n;
          d := d shr 1;
     end;
     if (p = 1) or (p = m) then
        exit;
     dec(e);

     while e <> 0 do begin
          p := (p*p) mod n;
          if p = m then
             exit;
          if p <= 1 then
             break;
          dec(e);
     end;
     Result:= False;
end;

// ###########################################
// #### function root finding
// ###########################################

const MAXITER = 100;

function findRootNewtonRaphson( func: TRootFuncWithDerrive; out root: double; x1,x2:double; xAcc: double {= 1e-8} ): boolean;
var j : integer;
    df, dx, dxold, f, fh, fl : double;
    temp, xh, xl, rts : double;
 begin
     func(x1, fl, df);
     func(x2, fh, df);
     root := nan;
     Result := False;
     if ((fh < 0) and (fl < 0) ) or ( (fh > 0) and (fl > 0) ) then
        exit;

     if fh = 0 then begin
          root := x2;
          Result := True;
          exit;
     end;
     if fl = 0 then begin
          root := x1;
          Result := True;
          exit;
     end;

     if fl < 0 then begin
          xl := x1;
          xh := x2;
     end else begin
          xl := x2;
          xh := x1;
     end;

     rts := 0.5*(x1 + x2);
     dxold := abs(x2 - x1);
     dx := dxold;
     func( rts, f, df );
     j := 0;
     while j < MAXITER do begin
          // check progress:
          // use bisect if out of range or not fast enough
          if (((rts - xh)*df-f)*((rts-xl)*df-f) > 0) or
             (abs(2*f) > abs(dxold*df))
          then begin
               // bisect
               dxold := dx;
               dx := 0.5*(xh - xl);
               rts := xl + dx;
               if xl = rts then
                  break;
          end else begin
               // Newton
               dxold := dx;
               dx := f/df;
               temp := rts;
               rts := rts - dx;
               if temp = rts then
                  break;
          end;

          if abs(dx) < xacc then
             break;
          func(rts, f, df);
          if f < 0 then
              xl := rts
          else
              xh := rts;
          inc(j);
     end;
     Result := j < MAXITER;
     if Result then
        root := rts;
 end;


function findRootBrent( func : TRootFunc; out root : double; x1, x2 : double; xAcc : double {= 1e-8} ) : boolean;
var iter : integer;
    a, b, c, d, e, min1, min2 : double;
    fa, fb, fc, p, q, r, s, tol1, xm : double;
//const MAXITER = 100;
 begin
     a := x1;
     b := x2;
     c := x2;
     fa := func(a);
     fb := func(b);
     d := (c - b)*0.5;
     e := d;

     Result := False;
     root := NAN;
     if ((fa > 0) and (fb > 0)) or ((fa < 0) and (fb < 0)) then
        exit;

     fc := fb;
     iter := 0;
     while iter < MAXITER do begin
          if ((fb > 0) and (fc > 0)) or ((fb < 0) and (fc < 0)) then begin
               c := a;
               fc := fa;
               d := b - a;
               e := d;
          end;

          if abs(fc) < abs(fb) then begin
               a := b;
               b := c;
               c := a;
               fa := fb;
               fb := fc;
               fc := fa;
          end;
          tol1 := 2*eps(1)*abs(b) + 0.5*xacc;
          xm := 0.5*(c - b);

          // ###########################################
          // #### Stop criterion
          if (abs(xm) <= tol1) or (fb = 0) then
             break;
          if (abs(e) >= tol1) and (abs(fa) > abs(fb)) then begin
               s := fb/fa;
               if a = c then begin
                    p := 2*xm*s;
                    q := -s;
               end
               else begin
                    q := fa/fc;
                    r := fb/fc;
                    p := s*(2*xm*q*(q -r) - (b - a)*(r - 1));
                    q := (q - 1)*(r - 1)*(s - 1);
               end;

               if (p > 0) then
                  q := -q;
               p := abs(p);
               min1 := 3*xm*q - abs(tol1*q);
               min2 := abs(e*q);

               if 2*p < Minf( min1, min2 ) then begin
                    e := d;
                    d := p/q;
               end  else begin
                    d := xm;
                    e := d;
               end;
          end else begin
               d := xm;
               e := d;
          end;

          a := b;
          fa := fb;
          if abs(d) > tol1 then
              b := b + d
          else
              b := b + sign( tol1, xm );

          // ###########################################
          // #### next function call
          fb := func(b);
          inc(iter);
     end;
     Result := iter < MAXITER;
     if Result then
        root := b;
 end;


function findRoot1(func: TRootFuncWithDerrive; out root: double; x1, x2: double; xAcc : double {= 1e-8} ): boolean;
begin
     Result:= findRootNewtonRaphson( func, root, x1, x2, xAcc);
end;

function findRoot( func : TRootFunc; out root : double; x1, x2 : double; xAcc : double {= 1e-8} ) : boolean;
begin
     Result:= findRootBrent( func, root, x1, x2, xAcc);
end;

function GaussWin( N : integer; A : double ) : TDoubleDynArray;
begin
     assert(N > 0, 'Bad vector len');
     SetLength(Result, N);
    // GaussWin( @Result[0], N, A );
end;
           {
procedure GaussWin( dest : PDouble; N : integer; A : double );
var i : integer;
    m : double;
    mInc : double;
begin
     m := -(N-1)/N;
     mInc := -2*m/N;

     for i := 0 to N - 1 do begin
          dest^ := exp( -0.5*sqr(a*m));
          m := m + mInc;
          inc(dest);
     end;
end;    }

//https://github.com/mikerabat/mrmath/blob/master/RandomEng.pas

{$DEFINE MSWINDOWS}

// Mersenne twister functions - Implementation of mt19937ar.c -> Mersenne  Twister with improved initilaization
 const cN = 624;
       cM = 397;
       cMatrix_A = $9908b0df;  // constant vector a
       cUpperMask = $80000000; // most significant w-r bits
       cLowerMask = $7fffffff; // least significant r bits

var fMt : Array of longword; //int64; //LongWord;  // array of the state vector
    fmag01 : Array[0..1] of longword; //LongWord;
    fMTi : longint; //int64; //LongInt;
    // used to convert to sec
    mtxFreq : Int64;
    
    
function MtxGetTime_: Int64;
{$IFDEF LINUX}
var loc_Start : TTimeSpec;
{$ENDIF}
begin
   {$IFDEF MACOS}
   Result := sw.GetTimeStamp;
   {$ENDIF}

   {$IFDEF LINUX}
   clock_gettime(CLOCK_MONOTONIC, @loc_Start);
   Result := loc_Start.tv_sec*1000000000 + loc_Start.tv_nsec;
   {$ENDIF}

   {$IFDEF MSWINDOWS}
    Result:= 0;
    QueryPerformanceCounter(Result);
    writ('debug qpc:'+itoa(result))
   
   {$ENDIF}

   {$IFDEF FPC}{$IFDEF DARWIN}
   Result := Int64( mach_absolute_time*QWORD(timeInfo.numer) div QWORD(timeInfo.denom) );
   {$ENDIF}{$ENDIF}
end;

var fRandDbl : TRandomDouble;

procedure setRandomMethodMersenne;
begin
   // raMersenneTwister: begin
   SetLength(fMt, cN);
   fMTi:= cN + 1;
  fRandDbl := {$IFDEF FPC}@{$ENDIF}@TRandomGeneratorRandMersenneDbl;
   // fRandInt := {$IFDEF FPC}@{$ENDIF}RandMersenneInt;
   // fRandLW := {$IFDEF FPC}@{$ENDIF}RandMersenneLW;
 end;

procedure TRandomGeneratorInitMersenne(Seed: longint);
var mti : longword; //int64;
 begin
    if seed = 0 then
        Seed:= {LongInt}(MtxGetTime_);
      Seed:= {LongInt}(MtxGetTime_);    //each time a new rand one
        writ('debug_seed:'+itoa(seed)); //+'  '+itoa(y))
     fMt[0]:= LongWord(Seed); // and $ffffffff; // for > 32 bit machines

     for mti:= 1 to cN - 1 do begin
          fMT[mti]:= (1812433253 * (fMt[mti - 1] xor (fMt[mti - 1] shr 30)) + mti);
          // fMT[mti] := fMT[mti] and and $ffffffff; // for > 32bit machines
     end;

     fMTi:= cN;
     fmag01[0]:= 0;
     fMag01[1]:= cMatrix_A;
 end;    

function TRandomGeneratorRandMersenneDblWord: int64;
 var y : longint;
    kk : integer;
 begin
     if fMTi > cN then
        TRandomGeneratorInitMersenne(5489);
     if fMTi >= cN then begin// generate N word sat one time
          for kk:= 0 to cN - cM - 1 do begin
               y:= (fMt[kk] and cUpperMask) or (fMT[kk + 1] and cLowerMask);
               fMT[kk]:= fMT[kk + cM] xor (y shr 1) xor fmag01[y and $1];
          end;

          for kk:= cN - cM to cN - 2 do begin
               y:= (fMt[kk] and cUpperMask) or (fMT[kk + 1] and cLowerMask);
               fMT[kk]:= fMT[kk+(cM-cN)] xor (y shr 1) xor fMag01[y and $1];
          end;

          y:= (fMT[cN - 1] and cUpperMask) or (fMT[0] and cLowerMask);
          fMt[cN- 1]:= fMT[cM - 1] xor (y shr 1) xor fMag01[y and $1];
          fMTi:= 0;
     end;
     
     y:= fMT[fMTi];
     //y:= absint(y);
     writ('debug_'+itoa(fmti)+'  '+itoa(y))
     inc(fMTi);
     // writ('debug'+itoa(fmti))
     // tempering
     y:= y xor ( y shr 11 );
     y:= y xor ((y  shl 7) and $9d2c5680 );
     y:= y xor ((y shl 15) and $efc60000 );
     y:= y xor ( y shr 18 );
     Result:= y;
 end;


const cMultA  = 67108864.0;
      cMultB  = 1.0/9007199254740992.0;
      
function TRandomGeneratorRandMersenneDbl: double;
// generates a random number on [0,1) with 53-bit resolution
// note: FPC seems to have troubles estimating if the output is single or double...
// -> thus the explicit assignment!

var a, b : Cardinal;
    x, y : double;
 begin
     a:= TRandomGeneratorRandMersenneDblWord;
     writ('debug:'+flots(a))
     x:= a shr 5;
     b:= TRandomGeneratorRandMersenneDblWord;
     writ('debug:'+flots(b))
     y:= b shr 6;
     Result:= (x*cMultA+y)*cMultB;
 end;

var ad1, ad2: double; dynarr: TIntegerDynArray;
    x:integer;

initialization
  cMinDblDivEps:= MinDblDiv/eps(1);
  
  ad1:= PI; ad2:= flcpi2;
  DoubleSwap(ad1, ad2)
  writeln('swaped '+flots(ad2));
  //function Arr( const elements : Array of integer ) : TIntegerDynArray;
  dynarr:= Arr([3,4,5,6,7,8]);
  writ(itoa(dynarr[2]));
  
  //function expInt( n : integer; x : double ) : double;
   writ(flots(expInt(20, Pi )));
   writ(flots(ExpJ(Pi)));
   x:=2;
   Writeln('e^'+itoa( x)+' = '+FormatFloat('0.0000', Exp(x)));
   Writeln('e^'+flots(Pi)+' = '+FormatFloat('0.0000', Exp(Pi)));
   
   //GetHighlightersFilter ///GetHighlighters
  {with TStatTest.create do begin
     free
   end;    }
   
  {$IFDEF MSWINDOWS}
    QueryPerformanceFrequency(mtxFreq);
  {$ENDIF}
  
  writ('TRandomGeneratorRandMersenneDbl:-->')
  setRandomMethodMersenne();
  writ('mRand: '+flots(TRandomGeneratorRandMersenneDbl));

  {$IFDEF LINUX}
   mtxFreq := 1000000000;
  {$ENDIF}
  {$IFDEF FPC}{$IFDEF DARWIN}
   mtxFreq := 1000000000;
  {AM}
   mach_timebase_info(timeInfo);
  {AM}
  {$ENDIF}{$ENDIF}
  {$IFDEF MACOS}
  sw:= TStopWatch.Create() ;
  sw.Start;
  mtxFreq:= SW.Frequency;
  writ(flots(TRandomGeneratorRandMersenneDbl));
  
finalization
    sw.Stop;
  {$ENDIF}
   
 end.
End.

ref: https://github.com/mikerabat/mrmath/blob/master/MathUtilFunc.pas
https://forum.winehq.org/viewtopic.php?t=34932
https://github.com/mikerabat/mrmath/blob/master/RandomEng.pas
http://www.softwareschule.ch/maxbox_functions.txt
