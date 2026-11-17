// maXbox5 / maXbox6 Script v31: Solar System Inner Planets Simulation
// Features Persistent Orbital Trails & Planetary Axial Rotation (Day/Night Spin on Axes)
// Simulates Venus, Earth (with Moon), and Mars orbiting the Sun using TTimer & TImage canvas.
// adding the Main Asteroid Belt ring between Mars and outer space.

program Solar_System_Inner_Planets_Simulation_v31;

const
  CANVAS_W = 740;  //820
  CANVAS_H = 560;  //620
  NUM_ASTEROIDS = 120;
  SUN_R = 26;
  MAX_TRAIL = 50;

  // Orbital semi-major & semi-minor axes (pixels)
  VENUS_A = 110; VENUS_B = 85;   VENUS_R = 10;
  EARTH_A = 175; EARTH_B = 135;  EARTH_R = 12;  MOON_ORBIT_R = 22; MOON_R = 4;
  MARS_A  = 245; MARS_B  = 190;  MARS_R  = 9;
  BELT_MIN_A = 290; BELT_MAX_A = 360;
  BELT_MIN_B = 220; BELT_MAX_B = 275;


var
  Form1: TForm;
  ImgCanvas: TImage;
  Timer1: TTimer;
  BtnStartPause, BtnReset, BtnSave, BtnClearTrails: TButton;
  TrkSpeed: TTrackBar;
  LblSpeed, LblSpeedVal, LblTitle: TLabel;

  // Orbital angles in radians
  VenusAngleRad, EarthAngleRad, MoonAngleRad, MarsAngleRad: Double;

  // Axial Rotation (Spin) angles in radians
  VenusSpinRad, EarthSpinRad, MarsSpinRad: Double;

  // Ring Buffer for Persistent Orbital Trails (Historical X, Y) !
  VenusTrailX, VenusTrailY: array[0..50] of Integer;
  EarthTrailX, EarthTrailY: array[0..50] of Integer;
  MoonTrailX, MoonTrailY: array[0..50] of Integer;
  MarsTrailX, MarsTrailY: array[0..50] of Integer;
  TrailCount: Integer;
  
  // Asteroid Belt Arrays
  AstA: array[0..NUM_ASTEROIDS] of Double;
  AstB: array[0..NUM_ASTEROIDS] of Double;
  AstAngle: array[0..NUM_ASTEROIDS] of Double;
  AstSpeed: array[0..NUM_ASTEROIDS] of Double;
  AstSize: array[0..NUM_ASTEROIDS] of Integer;

  IsRunning: Boolean;
  DayCounter: Integer;


//@helper  
function BytesPerPixel(Bitmap: TBitmap): Integer;
begin
  case Bitmap.PixelFormat of
    pf1bit:  Result:= 1 div 8;
    pf4bit:  Result:= 4 div 8;
    pf8bit:  Result:= 1;
    pf15bit,
    pf16bit: Result:= 2;
    pf24bit: Result:= 3;
    pf32bit: Result:= 4;
  else
    Result:= 0;
  end;
end;  

procedure InitAsteroidBelt;
var i: Integer;
begin
  Randomize;
  for i:= 0 to NUM_ASTEROIDS - 1 do begin
    AstA[i]:= BELT_MIN_A + Random(BELT_MAX_A - BELT_MIN_A);
    AstB[i]:= BELT_MIN_B + Random(BELT_MAX_B - BELT_MIN_B);
    AstAngle[i]:= (Random(3600) / 10.0) * (Pi / 180.0);
    AstSpeed[i]:= 0.008 + (Random(10) / 1000.0); // Keplerian speed ~0.3x Earth
    AstSize[i]:= 2 + Random(3);
  end;
end;

procedure UpdateTrailBuffer(Vx, Vy, Ex, Ey, Mx, My, MarX, MarY: Integer);
var
  i: Integer;
begin
  if TrailCount < MAX_TRAIL then
    Inc(TrailCount);

  for i:= TrailCount - 1 downto 1 do begin
    VenusTrailX[i]:= VenusTrailX[i - 1];
    VenusTrailY[i]:= VenusTrailY[i - 1];
    EarthTrailX[i]:= EarthTrailX[i - 1];
    EarthTrailY[i]:= EarthTrailY[i - 1];
    MoonTrailX[i] := MoonTrailX[i - 1];
    MoonTrailY[i] := MoonTrailY[i - 1];
    MarsTrailX[i] := MarsTrailX[i - 1];
    MarsTrailY[i] := MarsTrailY[i - 1];
  end;

  VenusTrailX[0]:= Vx;   VenusTrailY[0]:= Vy;
  EarthTrailX[0]:= Ex;   EarthTrailY[0]:= Ey;
  MoonTrailX[0] := Mx;   MoonTrailY[0] := My;
  MarsTrailX[0] := MarX; MarsTrailY[0] := MarY;
end;

procedure RedrawSimulation;
var
  CX, CY, i: Integer;
  Vx, Vy, Ex, Ey, Mx, My, MarX, MarY: Integer;
   AstX, AstY: Integer;
  SpotX, SpotY: Integer;
begin
  CX:= CANVAS_W div 2;
  CY:= (CANVAS_H div 2) - 15;

  // 1. Deep Space Background
  ImgCanvas.Canvas.Brush.Color:= RGB(10, 15, 30);
  ImgCanvas.Canvas.FillRect(Rect(0, 0, CANVAS_W, CANVAS_H));

  // 2. Distant Background Stars
  //imgcanvas.canvas.brush.Bitmap.PixelFormat := pf24bit;
  ImgCanvas.Canvas.pen.width:= 3;
  ImgCanvas.Canvas.Pixels[45, 160]:= clWhite;
  ImgCanvas.Canvas.Pixels[180,120]:= clWhite;
  ImgCanvas.Canvas.Pixels[650,190]:= clwhite;
  ImgCanvas.Canvas.Pixels[680,420]:= clWhite;
  ImgCanvas.Canvas.Pixels[80, 480]:= clWhite;
  ImgCanvas.Canvas.Pixels[310,510]:= clred;
  ImgCanvas.Canvas.Pixels[520,130]:= clWhite;
  ImgCanvas.Canvas.Pixels[510,310]:= clred;
  ImgCanvas.Canvas.Pixels[30, 520]:= clWhite;

  // Calculate Current Positions
  Vx:= CX + Round(VENUS_A * Cos(VenusAngleRad));
  Vy:= CY + Round(VENUS_B * Sin(VenusAngleRad));

  Ex:= CX + Round(EARTH_A * Cos(EarthAngleRad));
  Ey:= CY + Round(EARTH_B * Sin(EarthAngleRad));
  Mx:= Ex + Round(MOON_ORBIT_R * Cos(MoonAngleRad));
  My:= Ey + Round(MOON_ORBIT_R * Sin(MoonAngleRad));

  MarX:= CX + Round(MARS_A * Cos(MarsAngleRad));
  MarY:= CY + Round(MARS_B * Sin(MarsAngleRad));

  // 3. Draw Orbit Paths (Dotted Ellipses)
  ImgCanvas.Canvas.Brush.Style:= bsClear;
  
  ImgCanvas.Canvas.Pen.Color:= RGB(180, 150, 90);
  ImgCanvas.Canvas.Pen.Style:= psDot;
  ImgCanvas.Canvas.Ellipse(CX- VENUS_A, CY- VENUS_B, CX+ VENUS_A, CY+ VENUS_B);

  ImgCanvas.Canvas.Pen.Color:= RGB(60, 100, 160);
  ImgCanvas.Canvas.Ellipse(CX- EARTH_A, CY- EARTH_B, CX+ EARTH_A, CY+ EARTH_B);

  ImgCanvas.Canvas.Pen.Color:= RGB(180, 80, 70);
  ImgCanvas.Canvas.Ellipse(CX - MARS_A, CY - MARS_B, CX + MARS_A, CY + MARS_B);
  ImgCanvas.Canvas.Pen.Style:= psSolid;

  // 4. DRAW PERSISTENT ORBITAL TRAILS
  if TrailCount > 1 then begin
    for i:= 1 to TrailCount - 1 do begin
      // Venus Trail
      ImgCanvas.Canvas.Pen.Color:= RGB(Max(40,210- i * 4),Max(30,160- i * 3),Max(10,80- i * 2));
      ImgCanvas.Canvas.MoveTo(VenusTrailX[i - 1], VenusTrailY[i - 1]);
      ImgCanvas.Canvas.LineTo(VenusTrailX[i], VenusTrailY[i]);

      // Earth Trail
      ImgCanvas.Canvas.Pen.Color:= RGB(Max(10,30 - i),Max(30,120- i * 2),Max(50,220- i * 4));
      ImgCanvas.Canvas.MoveTo(EarthTrailX[i - 1], EarthTrailY[i - 1]);
      ImgCanvas.Canvas.LineTo(EarthTrailX[i], EarthTrailY[i]);

      // Moon Trail
      ImgCanvas.Canvas.Pen.Color:= RGB(Max(30,180-i * 3),Max(30,190-i * 3),Max(40,200-i * 3));
      ImgCanvas.Canvas.MoveTo(MoonTrailX[i - 1], MoonTrailY[i - 1]);
      ImgCanvas.Canvas.LineTo(MoonTrailX[i], MoonTrailY[i]);

      // Mars Trail
      ImgCanvas.Canvas.Pen.Color:= RGB(Max(40,210 - i * 4),Max(20,70 - i * 2), Max(10,50 - i));
      ImgCanvas.Canvas.MoveTo(MarsTrailX[i - 1], MarsTrailY[i - 1]);
      ImgCanvas.Canvas.LineTo(MarsTrailX[i], MarsTrailY[i]);
    end;
  end;

  // 5. Moon Orbit Path around Earth
  ImgCanvas.Canvas.Pen.Color:= RGB(90, 120, 160);
  ImgCanvas.Canvas.Ellipse(Ex - MOON_ORBIT_R, Ey - MOON_ORBIT_R,Ex + MOON_ORBIT_R,Ey + MOON_ORBIT_R);
  
  // 51. Render Main Asteroid Belt Particles
  ImgCanvas.Canvas.Brush.Color:= RGB(150, 155, 170);
  ImgCanvas.Canvas.Pen.Color:= RGB(180, 185, 200);
  for i:= 0 to NUM_ASTEROIDS - 1 do begin
    AstX:= CX + Round(AstA[i] * Cos(AstAngle[i]));
    AstY:= CY + Round(AstB[i] * Sin(AstAngle[i]));
    ImgCanvas.Canvas.Ellipse(AstX - 1, AstY - 1, AstX + AstSize[i], AstY + AstSize[i]);
  end;

  // 6. Sun with Glowing Outer Corona
  ImgCanvas.Canvas.Brush.Color:= RGB(255, 180, 30);
  ImgCanvas.Canvas.Pen.Color:= RGB(255, 150, 0);
  ImgCanvas.Canvas.Ellipse(CX - (SUN_R + 8), CY - (SUN_R + 8),CX + (SUN_R + 8),CY + (SUN_R + 8));
  ImgCanvas.Canvas.Brush.Color:= RGB(255, 235, 100);
  ImgCanvas.Canvas.Pen.Color:= RGB(255, 255, 200);
  ImgCanvas.Canvas.Ellipse(CX - SUN_R, CY - SUN_R, CX + SUN_R, CY + SUN_R);

  ImgCanvas.Canvas.Font.Color:= RGB(100, 40, 0);
  ImgCanvas.Canvas.Font.Style2:= fsBold2;
  //ImgCanvas.Canvas.Brush.Style:= bsClear;
  ImgCanvas.Canvas.TextOut(CX - 18, CY - 12, 'SUN');

  // 7. Venus (Golden Body + Atmosphere Spin Spot)
  ImgCanvas.Canvas.Brush.Color:= RGB(230, 180, 90);
  ImgCanvas.Canvas.Pen.Color:= RGB(255, 220, 140);
  ImgCanvas.Canvas.Ellipse(Vx - VENUS_R, Vy - VENUS_R, Vx + VENUS_R, Vy + VENUS_R);

  // Rotating Venus Atmosphere Cloud Feature
  SpotX:= Vx + Round(6 * Cos(VenusSpinRad));
  SpotY:= Vy + Round(6 * Sin(VenusSpinRad));
  ImgCanvas.Canvas.Brush.Color:= RGB(255, 240, 190);
  ImgCanvas.Canvas.Ellipse(SpotX - 2, SpotY - 2, SpotX + 2, SpotY + 2);
  ImgCanvas.Canvas.Font.Color:= RGB(240, 210, 130);
  ImgCanvas.Canvas.Brush.Style:= bsClear;
  ImgCanvas.Canvas.TextOut(Vx - 16, Vy + VENUS_R + 2, 'Venus');

  // 8. Earth (Blue Body + Axial Tilt + Rotating Continent Marker)
  ImgCanvas.Canvas.Brush.Color:= RGB(30, 120, 220);
  ImgCanvas.Canvas.Pen.Color:= RGB(100, 200, 255);
  ImgCanvas.Canvas.Ellipse(Ex - EARTH_R, Ey - EARTH_R, Ex + EARTH_R, Ey + EARTH_R);

  // 23.5 Degree Axial Tilt Line
  ImgCanvas.Canvas.Pen.Color:= RGB(180, 230, 255);
  ImgCanvas.Canvas.MoveTo(Ex - 4, Ey - 14);
  ImgCanvas.Canvas.LineTo(Ex + 4, Ey + 14);

  // Rotating Green Continent Feature Marker on Earth's surface
  SpotX:= Ex + Round(7 * Cos(EarthSpinRad));
  SpotY:= Ey + Round(7 * Sin(EarthSpinRad));
  ImgCanvas.Canvas.Brush.Color:= RGB(50, 200, 80);
  ImgCanvas.Canvas.Pen.Color:= RGB(100, 255, 120);
  ImgCanvas.Canvas.Ellipse(SpotX - 3, SpotY - 3, SpotX + 3, SpotY + 3);
  ImgCanvas.Canvas.Font.Color:= RGB(140, 210, 255);
  ImgCanvas.Canvas.Brush.Style:= bsClear;
  ImgCanvas.Canvas.TextOut(Ex - 14, Ey + EARTH_R + 2, 'Earth');

  // Moon
  ImgCanvas.Canvas.Brush.Color:= RGB(210, 215, 225);
  ImgCanvas.Canvas.Pen.Color:= RGB(240, 240, 250);
  ImgCanvas.Canvas.Ellipse(Mx - MOON_R, My - MOON_R, Mx + MOON_R, My + MOON_R);

  // 9. Mars (Red Body + Polar Ice Cap + Rotating Surface Marker)
  ImgCanvas.Canvas.Brush.Color:= RGB(220, 70, 50);
  ImgCanvas.Canvas.Pen.Color:= RGB(255, 120, 100);
  ImgCanvas.Canvas.Ellipse(MarX-MARS_R, MarY-MARS_R, MarX+MARS_R, MarY+MARS_R);

  // Mars North Polar Ice Cap
  ImgCanvas.Canvas.Brush.Color:= clWhite;
  ImgCanvas.Canvas.Ellipse(MarX- 3, MarY- MARS_R, MarX+ 3, MarY- MARS_R + 4);

  // Rotating Surface Spot (Syrtis Major)
  SpotX:= MarX + Round(5 * Cos(MarsSpinRad));
  SpotY:= MarY + Round(5 * Sin(MarsSpinRad));
  ImgCanvas.Canvas.Brush.Color:= RGB(140, 30, 20);
  ImgCanvas.Canvas.Ellipse(SpotX - 2, SpotY - 2, SpotX + 2, SpotY + 2);

  ImgCanvas.Canvas.Font.Color:= RGB(255, 140, 120);
  ImgCanvas.Canvas.Brush.Style:= bsClear;
  ImgCanvas.Canvas.TextOut(MarX - 14, MarY + MARS_R + 2, 'Mars');

  // 10. Real-time Telemetry Readout
  ImgCanvas.Canvas.Brush.Style:= bsClear;
  //ImgCanvas.Canvas.Font.Style2:= fsBold2;
  ImgCanvas.Canvas.Font.Style2:= fsnormal;
  ImgCanvas.Canvas.Font.Color:= RGB(240, 245, 255);
  ImgCanvas.Canvas.Font.Size:= 9;
  ImgCanvas.Canvas.TextOut(15,2,Format('Simulated Time: Day %d | Trails Active (%d pts)',
                           [DayCounter, TrailCount]));

  //ImgCanvas.Canvas.Font.Style2:= [];
  ImgCanvas.Canvas.Font.Size:= 8;
  ImgCanvas.Canvas.Font.Color:= RGB(240, 210, 130);
  ImgCanvas.Canvas.TextOut(15,26,Format('Venus (0.62 AU): (X: %d, Y: %d) | Retrograde Spin: %.1f deg', 
                           [Vx, Vy, VenusSpinRad * 180.0 / Pi]));

  ImgCanvas.Canvas.Font.Color:= RGB(140, 210, 255);
  ImgCanvas.Canvas.TextOut(15,44,Format('Earth (1.00 AU): (X: %d, Y: %d) | Axial Spin: %.1f deg (23.5 deg tilt)', 
                           [Ex, Ey, EarthSpinRad * 180.0 / Pi]));

  ImgCanvas.Canvas.Font.Color:= RGB(255, 140, 120);
  ImgCanvas.Canvas.TextOut(15, 64, Format('Mars  (1.52 AU): (X: %d, Y: %d) | Sol Spin: %.1f deg (Ice Cap)', 
                           [MarX, MarY, MarsSpinRad * 180.0 / Pi]));
end;

procedure OnTimerStep(Sender: TObject);
var
  SpeedFactor: Double;
  Vx, Vy, Ex, Ey, Mx, My, MarX, MarY, CX, CY, i: Integer;
begin
  SpeedFactor:= TrkSpeed.Position / 10.0;

  // Relative Orbital Speeds according to Kepler's 3rd Law
  VenusAngleRad:= VenusAngleRad + (0.0486 * SpeedFactor);
  EarthAngleRad:= EarthAngleRad + (0.0300 * SpeedFactor);
  MarsAngleRad := MarsAngleRad  + (0.0159 * SpeedFactor);

  if VenusAngleRad >= (2.0 * Pi) then VenusAngleRad:= VenusAngleRad- (2.0 * Pi);
  if EarthAngleRad >= (2.0 * Pi) then EarthAngleRad:= EarthAngleRad- (2.0 * Pi);
  if MarsAngleRad  >= (2.0 * Pi) then MarsAngleRad := MarsAngleRad - (2.0 * Pi);

  MoonAngleRad:= MoonAngleRad + (0.3500 * SpeedFactor);
  if MoonAngleRad >= (2.0 * Pi) then MoonAngleRad:= MoonAngleRad - (2.0 * Pi);

  // Update Planetary Axial Spin Rates
  EarthSpinRad:= EarthSpinRad + (0.1800 * SpeedFactor); // Daily rotation on axis
  VenusSpinRad:= VenusSpinRad - (0.0400 * SpeedFactor); // Slow retrograde rotation
  MarsSpinRad := MarsSpinRad  + (0.1700 * SpeedFactor); // ~24.6 hour rotation

  if EarthSpinRad >= (2.0 * Pi) then EarthSpinRad:= EarthSpinRad - (2.0 * Pi);
  if VenusSpinRad <= -(2.0 * Pi) then VenusSpinRad:= VenusSpinRad +(2.0 * Pi);
  if MarsSpinRad  >= (2.0 * Pi) then MarsSpinRad := MarsSpinRad  - (2.0 * Pi);

  Inc(DayCounter);

  // Update Orbital Position Trail Ring Buffers
  CX:= CANVAS_W div 2;
  CY:= (CANVAS_H div 2) - 15;

  Vx:= CX + Round(VENUS_A * Cos(VenusAngleRad));
  Vy:= CY + Round(VENUS_B * Sin(VenusAngleRad));
  Ex:= CX + Round(EARTH_A * Cos(EarthAngleRad));
  Ey:= CY + Round(EARTH_B * Sin(EarthAngleRad));
  Mx:= Ex + Round(MOON_ORBIT_R * Cos(MoonAngleRad));
  My:= Ey + Round(MOON_ORBIT_R * Sin(MoonAngleRad));
  MarX:= CX + Round(MARS_A * Cos(MarsAngleRad));
  MarY:= CY + Round(MARS_B * Sin(MarsAngleRad));
  
  // Asteroids Orbital Advance
  for i:= 0 to NUM_ASTEROIDS - 1 do begin
    AstAngle[i]:= AstAngle[i] + (AstSpeed[i] * SpeedFactor);
    if AstAngle[i] >= (2.0 * Pi) then AstAngle[i]:= AstAngle[i] - (2.0 * Pi);
  end;

  UpdateTrailBuffer(Vx, Vy, Ex, Ey, Mx, My, MarX, MarY);
  RedrawSimulation;
end;

procedure ToggleStartPause(Sender: TObject);
begin
  IsRunning:= not IsRunning;
  Timer1.Enabled:= IsRunning;
  if IsRunning then BtnStartPause.Caption:= 'Pause Simulation'
  else BtnStartPause.Caption:= 'Start Simulation';
end;

procedure ClearTrails(Sender: TObject);
begin
  TrailCount:= 0;
  RedrawSimulation;
end;

procedure ResetSimulation(Sender: TObject);
begin
  Timer1.Enabled:= False;
  IsRunning:= False;
  VenusAngleRad:= 0.0; EarthAngleRad:= 0.0; MoonAngleRad:= 0.0; MarsAngleRad:= 0.0;
  VenusSpinRad:= 0.0; EarthSpinRad:= 0.0; MarsSpinRad:= 0.0;
  TrailCount:= 0;
  DayCounter:= 1;
  BtnStartPause.Caption:= 'Start Simulation';
  RedrawSimulation;
end;

procedure SaveFrameImage(Sender: TObject);
begin
  ImgCanvas.Picture.SaveToFile('solar_system_v3_frame.bmp');
  ShowMessage('Saved current simulation snapshot to solar_system_v3_frame.bmp');
end;

procedure OnSpeedChange(Sender: TObject);
begin
  LblSpeedVal.Caption:= Format('%.1fx', [TrkSpeed.Position / 10.0]);
end;

procedure Build_GUI;
begin
  VenusAngleRad:= 0.0; EarthAngleRad:= 0.0; MoonAngleRad:= 0.0; MarsAngleRad:= 0.0;
  VenusSpinRad:= 0.0; EarthSpinRad:= 0.0; MarsSpinRad:= 0.0;
  TrailCount:= 0; DayCounter:= 1; IsRunning:= False;
  
  InitAsteroidBelt;

  Application.Initialize;
  Form1:= TForm.Create(Application);
  Form1.Caption:= 'maXbox Simulation v31: Inner Solar System with Trails & Axial Rotation';
  Form1.SetBounds(80, 60, 865, 715);
  Form1.Position:= poScreenCenter;
  Form1.Color:= RGB(20, 25, 40);

  LblTitle:= TLabel.Create(Form1); LblTitle.Parent:= Form1;
  LblTitle.SetBounds(20, 10, 740, 24);
  LblTitle.Caption:= 'Inner Solar System v31: Orbital Motion Trails, Planetary Axial Rotation Dynamics';
  LblTitle.Font.Name:= 'Arial'; LblTitle.Font.Size:= 11; LblTitle.Font.Style2:= fsBold2;
  LblTitle.Font.Color:= RGB(230, 240, 255);

  ImgCanvas:= TImage.Create(Form1); ImgCanvas.Parent:= Form1;
  ImgCanvas.SetBounds(20, 38, CANVAS_W, CANVAS_H);

  Timer1:= TTimer.Create(Form1);
  Timer1.Interval:= 50;
  Timer1.OnTimer:= @OnTimerStep;

  BtnStartPause:= TButton.Create(Form1); BtnStartPause.Parent:= Form1;
  BtnStartPause.SetBounds(20, 610, 140, 34);
  BtnStartPause.Caption:= 'Start Simulation';
  BtnStartPause.OnClick:= @ToggleStartPause;

  BtnReset:= TButton.Create(Form1); BtnReset.Parent:= Form1;
  BtnReset.SetBounds(170, 610, 110, 34);
  BtnReset.Caption:= '&Reset Orbits';
  BtnReset.OnClick:= @ResetSimulation;
  BtnClearTrails:= TButton.Create(Form1); BtnClearTrails.Parent:= Form1;
  BtnClearTrails.SetBounds(290, 610, 110, 34);
  BtnClearTrails.Caption:= '&Clear Trails';
  BtnClearTrails.OnClick:= @ClearTrails;

  BtnSave:= TButton.Create(Form1); BtnSave.Parent:= Form1;
  BtnSave.SetBounds(410, 610, 130, 34);
  BtnSave.Caption:= 'Save Snapshot';
  BtnSave.OnClick:= @SaveFrameImage;

  LblSpeed:= TLabel.Create(Form1); LblSpeed.Parent:= Form1;
  LblSpeed.SetBounds(561, 590, 80, 16);
  LblSpeed.Caption:= 'Simulation Speed:'; LblSpeed.Font.Color:= clWhite;
  TrkSpeed:= TTrackBar.Create(Form1); TrkSpeed.Parent:= Form1;
  TrkSpeed.SetBounds(555, 618, 210, 30);
  TrkSpeed.Min:= 1; TrkSpeed.Max:= 50; TrkSpeed.Position:= 10;
  TrkSpeed.OnChange:= @OnSpeedChange;

  LblSpeedVal:= TLabel.Create(Form1); LblSpeedVal.Parent:= Form1;
  LblSpeedVal.SetBounds(765, 620, 45, 20);
  LblSpeedVal.Caption:= '1.0x'; LblSpeedVal.Font.Color:= RGB(100, 200, 255);

  RedrawSimulation;
  Form1.ShowModal;
  Form1.Free;
end;

begin  //@main
  writeln(#$d83d#$de42#$d83d#$de42#$d83d#$de42);    
  processmessagesOFF;   
   maxform1.setconsole;
  SetdebugOFF;
  Build_GUI();
end.

doc: What's New in Version 3Persistent Motion Trails:
Implemented historical ring buffers 
(VenusTrailX, EarthTrailX, MoonTrailX, MarsTrailX) up to 50 past positions.As planets move, 
fading, color-coded trail vectors are rendered behind each planet to visualize orbital paths 
and motion vectors in real time.
Added a dedicated Clear Trails button to reset trail histories 
whenever needed.
Planetary Axial Rotation (Day/Night Spin):Earth ($1.00\text{ AU}$): 
Features a $23.5^\circ$ axial tilt line and a rotating surface continent marker (EarthSpinRad)
 completing daily axial rotations.Venus ($0.62\text{ AU}$): 
 Simulates slow retrograde axial 
 rotation (VenusSpinRad) with a rotating cloud atmosphere feature spot.Mars ($1.52\text{ AU}$): 
 Displays a white North Polar Ice Cap and a rotating dark surface feature (MarsSpinRad) c
 alibrated to a $\approx 24.6$-hour Sol cycle.
 Expanded Telemetry Overlay:
 Displays live axial 
 spin angles (in degrees) alongside active trail point counts, real-time Cartesian 
 coordinates $(X, Y)$, and simulated day counts.
 
add planetary rotation (day/night spin on their axes) or trace 
persistent orbital trail lines behind each planet!

In Delphi, ParentDoubleBuffered and DoubleBuffered are properties used to control how a 
component handles its rendering to reduce flickering during updates.
ProcessmessagesON and OFF does a similiar effect in a maxbox script! 

New in maXbox 5.2.9.198 (September 30, 2025)
New in maXbox 5.1.4.98 (June 30, 2024)
New in maXbox 5.1.4.95 (April 17, 2024)
New in maXbox 5.1.4.90 (March 21, 2024)
New in maXbox 4.7.6.50 (June 15, 2023)
New in maXbox 4.7.6.20 (December 15, 2022)
New in maXbox 4.7.6.10 (November 12, 2021)
New in maXbox 4.7.5.80 (July 22, 2021)
New in maXbox 4.7.4.64 (June 14, 2020)
New in maXbox 4.7.4.62 (June 8, 2020)
