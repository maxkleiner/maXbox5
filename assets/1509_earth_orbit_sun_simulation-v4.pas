// maXbox5 / maXbox6 Script v4: Solar System Simulation with Main Asteroid Belt
// Features Venus, Earth (+Moon), Mars, and 120 Procedural Belt Asteroids with Motion Trails & Axial Rotation.

program Solar_System_Asteroid_Belt_Simulation_v4;

const
  MAX_TRAIL = 50;
  NUM_ASTEROIDS = 120;
  CANVAS_W = 820;
  CANVAS_H = 620;
  SUN_R = 26;

  // Orbital Semi-major (A) & Semi-minor (B) axes in pixels
  VENUS_A = 110; VENUS_B = 85;   VENUS_R = 10;
  EARTH_A = 175; EARTH_B = 135;  EARTH_R = 12;  MOON_ORBIT_R = 22; MOON_R = 4;
  MARS_A  = 245; MARS_B  = 190;  MARS_R  = 9;
  BELT_MIN_A = 290; BELT_MAX_A = 360;
  BELT_MIN_B = 220; BELT_MAX_B = 275;

var
  Form1: TForm;
  ImgCanvas: TImage;
  Timer1: TTimer;
  BtnStartPause, BtnReset, BtnClearTrails, BtnSave: TButton;
  TrkSpeed: TTrackBar;
  LblSpeed, LblSpeedVal, LblTitle: TLabel;

  // Orbital angles in radians
  VenusAngleRad, EarthAngleRad, MoonAngleRad, MarsAngleRad: Double;

  // Axial Rotation angles (Day/Night spin)
  VenusSpinRad, EarthSpinRad, MarsSpinRad: Double;

  // Motion Trails (Ring Buffers)
  VenusTrailX, VenusTrailY: array[0..MAX_TRAIL] of Integer;
  EarthTrailX, EarthTrailY: array[0..MAX_TRAIL] of Integer;
  MoonTrailX,  MoonTrailY:  array[0..MAX_TRAIL] of Integer;
  MarsTrailX,  MarsTrailY:  array[0..MAX_TRAIL] of Integer;
  TrailCount: Integer;

  // Asteroid Belt Arrays
  AstA: array[0..NUM_ASTEROIDS] of Double;
  AstB: array[0..NUM_ASTEROIDS] of Double;
  AstAngle: array[0..NUM_ASTEROIDS] of Double;
  AstSpeed: array[0..NUM_ASTEROIDS] of Double;
  AstSize: array[0..NUM_ASTEROIDS] of Integer;

  IsRunning: Boolean;
  DayCounter: Integer;

procedure InitAsteroidBelt;
var i: Integer;
begin
  Randomize;
  for i := 0 to NUM_ASTEROIDS - 1 do begin
    AstA[i] := BELT_MIN_A + Random(BELT_MAX_A - BELT_MIN_A);
    AstB[i] := BELT_MIN_B + Random(BELT_MAX_B - BELT_MIN_B);
    AstAngle[i] := (Random(3600) / 10.0) * (Pi / 180.0);
    AstSpeed[i] := 0.008 + (Random(10) / 1000.0); // Keplerian speed ~0.3x Earth
    AstSize[i] := 2 + Random(3);
  end;
end;

procedure ClearAllTrails;
var i: Integer;
begin
  for i := 0 to MAX_TRAIL do begin
    VenusTrailX[i] := 0; VenusTrailY[i] := 0;
    EarthTrailX[i] := 0; EarthTrailY[i] := 0;
    MoonTrailX[i]  := 0; MoonTrailY[i]  := 0;
    MarsTrailX[i]  := 0; MarsTrailY[i]  := 0;
  end;
  TrailCount := 0;
end;

procedure AddTrailPoint(Vx, Vy, Ex, Ey, Mx, My, MarX, MarY: Integer);
var i: Integer;
begin
  if TrailCount < MAX_TRAIL then begin
    VenusTrailX[TrailCount] := Vx; VenusTrailY[TrailCount] := Vy;
    EarthTrailX[TrailCount] := Ex; EarthTrailY[TrailCount] := Ey;
    MoonTrailX[TrailCount]  := Mx; MoonTrailY[TrailCount]  := My;
    MarsTrailX[TrailCount]  := MarX; MarsTrailY[TrailCount] := MarY;
    Inc(TrailCount);
  end else begin
    for i := 0 to MAX_TRAIL - 1 do begin
      VenusTrailX[i] := VenusTrailX[i + 1]; VenusTrailY[i] := VenusTrailY[i + 1];
      EarthTrailX[i] := EarthTrailX[i + 1]; EarthTrailY[i] := EarthTrailY[i + 1];
      MoonTrailX[i]  := MoonTrailX[i + 1];  MoonTrailY[i]  := MoonTrailY[i + 1];
      MarsTrailX[i]  := MarsTrailX[i + 1];  MarsTrailY[i]  := MarsTrailY[i + 1];
    end;
    VenusTrailX[MAX_TRAIL] := Vx; VenusTrailY[MAX_TRAIL] := Vy;
    EarthTrailX[MAX_TRAIL] := Ex; EarthTrailY[MAX_TRAIL] := Ey;
    MoonTrailX[MAX_TRAIL]  := Mx; MoonTrailY[MAX_TRAIL]  := My;
    MarsTrailX[MAX_TRAIL]  := MarX; MarsTrailY[MAX_TRAIL] := MarY;
  end;
end;

procedure RedrawSimulation;
var
  CX, CY, i: Integer;
  Vx, Vy, Ex, Ey, Mx, My, MarX, MarY: Integer;
  AstX, AstY: Integer;
  Px, Py: Integer;
begin
  CX := CANVAS_W div 2;
  CY := (CANVAS_H div 2) - 15;

  // 1. Deep Space Background
  ImgCanvas.Canvas.Brush.Color := RGB(10, 15, 30);
  ImgCanvas.Canvas.FillRect(Rect(0, 0, CANVAS_W, CANVAS_H));

  // 2. Distant Background Stars
  ImgCanvas.Canvas.Pixels[45, 60]   := clWhite;
  ImgCanvas.Canvas.Pixels[180, 40]  := clWhite;
  ImgCanvas.Canvas.Pixels[750, 90]  := clWhite;
  ImgCanvas.Canvas.Pixels[780, 520] := clWhite;
  ImgCanvas.Canvas.Pixels[80, 560]  := clWhite;
  ImgCanvas.Canvas.Pixels[310, 580] := clWhite;

  // 3. Draw Orbit Path Ellipses
  ImgCanvas.Canvas.Brush.Style := bsClear;
  
  // Venus Orbit Path
  ImgCanvas.Canvas.Pen.Color := RGB(180, 150, 90); ImgCanvas.Canvas.Pen.Style := psDot;
  ImgCanvas.Canvas.Ellipse(CX - VENUS_A, CY - VENUS_B, CX + VENUS_A, CY + VENUS_B);

  // Earth Orbit Path
  ImgCanvas.Canvas.Pen.Color := RGB(60, 100, 160);
  ImgCanvas.Canvas.Ellipse(CX - EARTH_A, CY - EARTH_B, CX + EARTH_A, CY + EARTH_B);

  // Mars Orbit Path
  ImgCanvas.Canvas.Pen.Color := RGB(180, 80, 70);
  ImgCanvas.Canvas.Ellipse(CX - MARS_A, CY - MARS_B, CX + MARS_A, CY + MARS_B);

  // Asteroid Belt Boundary Guides
  ImgCanvas.Canvas.Pen.Color := RGB(80, 85, 100);
  ImgCanvas.Canvas.Ellipse(CX - BELT_MIN_A, CY - BELT_MIN_B, CX + BELT_MIN_A, CY + BELT_MIN_B);
  ImgCanvas.Canvas.Ellipse(CX - BELT_MAX_A, CY - BELT_MAX_B, CX + BELT_MAX_A, CY + BELT_MAX_B);

  ImgCanvas.Canvas.Pen.Style := psSolid;

  // Calculate Positions
  Vx := CX + Round(VENUS_A * Cos(VenusAngleRad));
  Vy := CY + Round(VENUS_B * Sin(VenusAngleRad));

  Ex := CX + Round(EARTH_A * Cos(EarthAngleRad));
  Ey := CY + Round(EARTH_B * Sin(EarthAngleRad));

  Mx := Ex + Round(MOON_ORBIT_R * Cos(MoonAngleRad));
  My := Ey + Round(MOON_ORBIT_R * Sin(MoonAngleRad));

  MarX := CX + Round(MARS_A * Cos(MarsAngleRad));
  MarY := CY + Round(MARS_B * Sin(MarsAngleRad));

  // Add position to Ring Buffer
  if IsRunning then AddTrailPoint(Vx, Vy, Ex, Ey, Mx, My, MarX, MarY);

  // 4. Render Fading Motion Trails
  if TrailCount > 1 then begin
    for i := 0 to TrailCount - 2 do begin
      // Venus Trail (Gold)
      ImgCanvas.Canvas.Pen.Color := RGB(160, 130, 70);
      ImgCanvas.Canvas.MoveTo(VenusTrailX[i], VenusTrailY[i]);
      ImgCanvas.Canvas.LineTo(VenusTrailX[i + 1], VenusTrailY[i + 1]);

      // Earth Trail (Cyan/Blue)
      ImgCanvas.Canvas.Pen.Color := RGB(40, 140, 220);
      ImgCanvas.Canvas.MoveTo(EarthTrailX[i], EarthTrailY[i]);
      ImgCanvas.Canvas.LineTo(EarthTrailX[i + 1], EarthTrailY[i + 1]);

      // Mars Trail (Red)
      ImgCanvas.Canvas.Pen.Color := RGB(200, 70, 50);
      ImgCanvas.Canvas.MoveTo(MarsTrailX[i], MarsTrailY[i]);
      ImgCanvas.Canvas.LineTo(MarsTrailX[i + 1], MarsTrailY[i + 1]);
    end;
  end;

  // 5. Render Main Asteroid Belt Particles
  ImgCanvas.Canvas.Brush.Color := RGB(150, 155, 170);
  ImgCanvas.Canvas.Pen.Color := RGB(180, 185, 200);
  for i := 0 to NUM_ASTEROIDS - 1 do begin
    AstX := CX + Round(AstA[i] * Cos(AstAngle[i]));
    AstY := CY + Round(AstB[i] * Sin(AstAngle[i]));
    ImgCanvas.Canvas.Ellipse(AstX - 1, AstY - 1, AstX + AstSize[i], AstY + AstSize[i]);
  end;

  // 6. Moon Orbit Path around Earth
  ImgCanvas.Canvas.Pen.Color := RGB(90, 120, 160);
  ImgCanvas.Canvas.Ellipse(Ex - MOON_ORBIT_R, Ey - MOON_ORBIT_R, Ex + MOON_ORBIT_R, Ey + MOON_ORBIT_R);

  // 7. Sun with Glowing Corona
  ImgCanvas.Canvas.Brush.Color := RGB(255, 180, 30); ImgCanvas.Canvas.Pen.Color := RGB(255, 150, 0);
  ImgCanvas.Canvas.Ellipse(CX - (SUN_R + 8), CY - (SUN_R + 8), CX + (SUN_R + 8), CY + (SUN_R + 8));

  ImgCanvas.Canvas.Brush.Color := RGB(255, 235, 100); ImgCanvas.Canvas.Pen.Color := RGB(255, 255, 200);
  ImgCanvas.Canvas.Ellipse(CX - SUN_R, CY - SUN_R, CX + SUN_R, CY + SUN_R);

  ImgCanvas.Canvas.Font.Color := RGB(100, 40, 0); ImgCanvas.Canvas.Font.Style2 := fsBold2;
  ImgCanvas.Canvas.TextOut(CX - 12, CY - 6, 'SUN');

  // 8. Venus with Atmosphere Feature Spin
  ImgCanvas.Canvas.Brush.Color := RGB(230, 180, 90); ImgCanvas.Canvas.Pen.Color := RGB(255, 220, 140);
  ImgCanvas.Canvas.Ellipse(Vx - VENUS_R, Vy - VENUS_R, Vx + VENUS_R, Vy + VENUS_R);
  
  Px := Vx + Round(5 * Cos(VenusSpinRad)); Py := Vy + Round(5 * Sin(VenusSpinRad));
  ImgCanvas.Canvas.Brush.Color := RGB(255, 230, 160);
  ImgCanvas.Canvas.Ellipse(Px - 2, Py - 2, Px + 2, Py + 2);
  ImgCanvas.Canvas.Font.Color := RGB(240, 210, 130); ImgCanvas.Canvas.Font.Style2 := [];
  ImgCanvas.Canvas.TextOut(Vx - 16, Vy + VENUS_R + 2, 'Venus');

  // 9. Earth with 23.5 deg Axial Tilt Line & Rotating Continents
  ImgCanvas.Canvas.Brush.Color := RGB(30, 120, 220); ImgCanvas.Canvas.Pen.Color := RGB(100, 200, 255);
  ImgCanvas.Canvas.Ellipse(Ex - EARTH_R, Ey - EARTH_R, Ex + EARTH_R, Ey + EARTH_R);

  // Rotating Continent Marker
  Px := Ex + Round(6 * Cos(EarthSpinRad)); Py := Ey + Round(6 * Sin(EarthSpinRad));
  ImgCanvas.Canvas.Brush.Color := RGB(40, 180, 80);
  ImgCanvas.Canvas.Ellipse(Px - 3, Py - 3, Px + 3, Py + 3);

  // Axial Tilt Indicator Line (23.5 degrees)
  ImgCanvas.Canvas.Pen.Color := RGB(200, 230, 255);
  ImgCanvas.Canvas.MoveTo(Ex - 5, Ey - 15); ImgCanvas.Canvas.LineTo(Ex + 5, Ey + 15);

  ImgCanvas.Canvas.Font.Color := RGB(140, 210, 255);
  ImgCanvas.Canvas.TextOut(Ex - 14, Ey + EARTH_R + 2, 'Earth');

  // Moon
  ImgCanvas.Canvas.Brush.Color := RGB(210, 215, 225); ImgCanvas.Canvas.Pen.Color := RGB(240, 240, 250);
  ImgCanvas.Canvas.Ellipse(Mx - MOON_R, My - MOON_R, Mx + MOON_R, My + MOON_R);

  // 10. Mars with North Polar Ice Cap & Rotating Dark Surface Feature
  ImgCanvas.Canvas.Brush.Color := RGB(220, 70, 50); ImgCanvas.Canvas.Pen.Color := RGB(255, 120, 100);
  ImgCanvas.Canvas.Ellipse(MarX - MARS_R, MarY - MARS_R, MarX + MARS_R, MarY + MARS_R);

  // Ice Cap
  ImgCanvas.Canvas.Brush.Color := clWhite;
  ImgCanvas.Canvas.Ellipse(MarX - 3, MarY - MARS_R, MarX + 3, MarY - MARS_R + 4);

  // Rotating Feature
  Px := MarX + Round(4 * Cos(MarsSpinRad)); Py := MarY + Round(4 * Sin(MarsSpinRad));
  ImgCanvas.Canvas.Brush.Color := RGB(140, 40, 30);
  ImgCanvas.Canvas.Ellipse(Px - 2, Py - 2, Px + 2, Py + 2);

  ImgCanvas.Canvas.Font.Color := RGB(255, 140, 120);
  ImgCanvas.Canvas.TextOut(MarX - 14, MarY + MARS_R + 2, 'Mars');

  // 11. Real-Time Telemetry Overlay
  ImgCanvas.Canvas.Brush.Style := bsClear; ImgCanvas.Canvas.Font.Style2 := fsBold2;
  ImgCanvas.Canvas.Font.Color := RGB(240, 245, 255);
  ImgCanvas.Canvas.TextOut(15, 12, Format('Simulated Time: Day %d | Active Trail Points: %d', [DayCounter, TrailCount]));

  ImgCanvas.Canvas.Font.Style2 := [];
  ImgCanvas.Canvas.Font.Color := RGB(240, 210, 130);
  ImgCanvas.Canvas.TextOut(15, 30, Format('Venus (0.62 AU): (X: %d, Y: %d) | Spin: %.0f Deg', [Vx, Vy, VenusSpinRad * 180.0 / Pi]));

  ImgCanvas.Canvas.Font.Color := RGB(140, 210, 255);
  ImgCanvas.Canvas.TextOut(15, 48, Format('Earth (1.00 AU): (X: %d, Y: %d) | Spin: %.0f Deg (Tilt 23.5 Deg)', [Ex, Ey, EarthSpinRad * 180.0 / Pi]));

  ImgCanvas.Canvas.Font.Color := RGB(255, 140, 120);
  ImgCanvas.Canvas.TextOut(15, 66, Format('Mars  (1.52 AU): (X: %d, Y: %d) | Spin: %.0f Deg', [MarX, MarY, MarsSpinRad * 180.0 / Pi]));

  ImgCanvas.Canvas.Font.Color := RGB(180, 185, 200);
  ImgCanvas.Canvas.TextOut(15, 84, Format('Asteroid Belt (2.1-3.3 AU): 120 Procedural Ring Particles', []));
end;

procedure OnTimerStep(Sender: TObject);
var
  SpeedFactor: Double;
  i: Integer;
begin
  SpeedFactor := TrkSpeed.Position / 10.0;

  // Keplerian Orbital Speeds
  VenusAngleRad := VenusAngleRad + (0.0486 * SpeedFactor);
  EarthAngleRad := EarthAngleRad + (0.0300 * SpeedFactor);
  MarsAngleRad  := MarsAngleRad  + (0.0159 * SpeedFactor);

  if VenusAngleRad >= (2.0 * Pi) then VenusAngleRad := VenusAngleRad - (2.0 * Pi);
  if EarthAngleRad >= (2.0 * Pi) then EarthAngleRad := EarthAngleRad - (2.0 * Pi);
  if MarsAngleRad  >= (2.0 * Pi) then MarsAngleRad  := MarsAngleRad  - (2.0 * Pi);

  // Asteroids Orbital Advance
  for i := 0 to NUM_ASTEROIDS - 1 do begin
    AstAngle[i] := AstAngle[i] + (AstSpeed[i] * SpeedFactor);
    if AstAngle[i] >= (2.0 * Pi) then AstAngle[i] := AstAngle[i] - (2.0 * Pi);
  end;

  MoonAngleRad := MoonAngleRad + (0.3500 * SpeedFactor);
  if MoonAngleRad >= (2.0 * Pi) then MoonAngleRad := MoonAngleRad - (2.0 * Pi);

  // Axial Rotation (Day/Night Spin)
  EarthSpinRad := EarthSpinRad + (0.20 * SpeedFactor);
  MarsSpinRad  := MarsSpinRad  + (0.19 * SpeedFactor);
  VenusSpinRad := VenusSpinRad - (0.05 * SpeedFactor); // Retrograde spin

  if EarthSpinRad >= (2.0 * Pi) then EarthSpinRad := EarthSpinRad - (2.0 * Pi);
  if MarsSpinRad  >= (2.0 * Pi) then MarsSpinRad  := MarsSpinRad  - (2.0 * Pi);
  if VenusSpinRad <= -(2.0 * Pi) then VenusSpinRad := VenusSpinRad + (2.0 * Pi);

  Inc(DayCounter);
  RedrawSimulation;
end;

procedure ToggleStartPause(Sender: TObject);
begin
  IsRunning := not IsRunning;
  Timer1.Enabled := IsRunning;
  if IsRunning then BtnStartPause.Caption := 'Pause Simulation'
  else BtnStartPause.Caption := 'Start Simulation';
end;

procedure ResetSimulation(Sender: TObject);
begin
  Timer1.Enabled := False;
  IsRunning := False;
  VenusAngleRad := 0.0; EarthAngleRad := 0.0; MoonAngleRad := 0.0; MarsAngleRad := 0.0;
  VenusSpinRad := 0.0; EarthSpinRad := 0.0; MarsSpinRad := 0.0;
  DayCounter := 1;
  ClearAllTrails;
  BtnStartPause.Caption := 'Start Simulation';
  RedrawSimulation;
end;

procedure OnClearTrailsClick(Sender: TObject);
begin
  ClearAllTrails;
  RedrawSimulation;
end;

procedure SaveFrameImage(Sender: TObject);
begin
  ImgCanvas.Picture.SaveToFile('solar_system_v4_frame.bmp');
  ShowMessage('Saved current simulation snapshot to solar_system_v4_frame.bmp');
end;

procedure OnSpeedChange(Sender: TObject);
begin
  LblSpeedVal.Caption := Format('%.1fx', [TrkSpeed.Position / 10.0]);
end;

procedure BuildGUI;
begin
  VenusAngleRad := 0.0; EarthAngleRad := 0.0; MoonAngleRad := 0.0; MarsAngleRad := 0.0;
  VenusSpinRad := 0.0; EarthSpinRad := 0.0; MarsSpinRad := 0.0;
  DayCounter := 1; IsRunning := False;
  ClearAllTrails;
  InitAsteroidBelt;

  Application.Initialize;
  Form1 := TForm.Create(Application);
  Form1.Caption := 'maXbox Simulation v4: Solar System with Main Asteroid Belt';
  Form1.SetBounds(80, 60, 860, 740);
  Form1.Position := poScreenCenter;
  Form1.Color := RGB(20, 25, 40);

  LblTitle := TLabel.Create(Form1); LblTitle.Parent := Form1;
  LblTitle.SetBounds(20, 10, 820, 24);
  LblTitle.Caption := 'Solar System Dynamics: Inner Planets (Venus, Earth, Mars) & Main Asteroid Belt (v4)';
  LblTitle.Font.Name := 'Arial'; LblTitle.Font.Size := 11; LblTitle.Font.Style2 := fsBold2;
  LblTitle.Font.Color := RGB(230, 240, 255);

  ImgCanvas := TImage.Create(Form1); ImgCanvas.Parent := Form1;
  ImgCanvas.SetBounds(20, 38, CANVAS_W, CANVAS_H);

  Timer1 := TTimer.Create(Form1);
  Timer1.Interval := 40;
  Timer1.OnTimer := @OnTimerStep;

  BtnStartPause := TButton.Create(Form1); BtnStartPause.Parent := Form1;
  BtnStartPause.SetBounds(20, 670, 130, 34);
  BtnStartPause.Caption := 'Start Simulation';
  BtnStartPause.OnClick := @ToggleStartPause;

  BtnReset := TButton.Create(Form1); BtnReset.Parent := Form1;
  BtnReset.SetBounds(160, 670, 110, 34);
  BtnReset.Caption := 'Reset Orbits';
  BtnReset.OnClick := @ResetSimulation;

  BtnClearTrails := TButton.Create(Form1); BtnClearTrails.Parent := Form1;
  BtnClearTrails.SetBounds(280, 670, 110, 34);
  BtnClearTrails.Caption := 'Clear Trails';
  BtnClearTrails.OnClick := @OnClearTrailsClick;

  BtnSave := TButton.Create(Form1); BtnSave.Parent := Form1;
  BtnSave.SetBounds(400, 670, 120, 34);
  BtnSave.Caption := 'Save Snapshot';
  BtnSave.OnClick := @SaveFrameImage;

  LblSpeed := TLabel.Create(Form1); LblSpeed.Parent := Form1;
  LblSpeed.SetBounds(540, 665, 80, 16);
  LblSpeed.Caption := 'Speed:'; LblSpeed.Font.Color := clWhite;

  TrkSpeed := TTrackBar.Create(Form1); TrkSpeed.Parent := Form1;
  TrkSpeed.SetBounds(535, 680, 180, 30);
  TrkSpeed.Min := 1; TrkSpeed.Max := 50; TrkSpeed.Position := 10;
  TrkSpeed.OnChange := @OnSpeedChange;

  LblSpeedVal := TLabel.Create(Form1); LblSpeedVal.Parent := Form1;
  LblSpeedVal.SetBounds(725, 680, 45, 20);
  LblSpeedVal.Caption := '1.0x'; LblSpeedVal.Font.Color := RGB(100, 200, 255);

  RedrawSimulation;
  Form1.ShowModal;
  Form1.Free;
end;

begin
  BuildGUI;
end.
