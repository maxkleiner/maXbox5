// maXbox5 / maXbox6 Script v9: Japanese Katakana & Kanji Multi-Reading Vocabulary Trainer
// Includes 46 Basic Katakana +  Voiced Dakuten/Handakuten + 30 N5 Kanji Signs (101 Total Signs)
// Supports multiple valid Kunyomi/Onyomi readings (e.g. 'sui, mizu' or 'nichi, hi, bi')
// Uses direct WideChar Unicode Hex Literals (#$XXXX) for 100% locale independence for Tutorial 205
// {$APPTYPE FORM} 🦋 ⛩️ Katakana Example ⛩️ ア 🦋 🖼️ 📥 ⚙️ 🖥️ 🌐 🧠 🎯 🎨  for Tutor 205

program Katakana_Kanji_Language_Trainer_Studio9;

const
  TOTAL_ITEMS = 101;

var
  Form1: TForm;
  LblTitle, LblKatakana, LblGroup, LblHex, LblResult, LblScore, LblPrompt: TLabel;
  EdtAnswer: TEdit;
  BtnCheck, BtnNext, BtnHint, BtnReset: TButton;
  MemoLog: TMemo;

  Symbols: array[0..100] of WideString;
  HexCodes: array[0..100] of string;
  Romaji: array[0..100] of string;
  Groups: array[0..100] of string;
  Hints: array[0..100] of string;

  CurrentIdx, TotalAttempts, CorrectCount: Integer;
  IsChecked: Boolean;

function MatchAnswer(const UserInput, AcceptedList: string): Boolean;
var
  List, Token: string;
  p: Integer;
begin
  Result := False;
  List:= LowerCase(boldTrim(AcceptedList)) + ',';
  while Pos(',', List) > 0 do begin
    p:= Pos(',', List);
    Token:= boldTrim(Copy(List, 1, p - 1));
    Delete(List, 1, p);
    if (Length(Token) > 0) and (UserInput = Token) then begin
      Result:= True;
      Exit;
    end;
  end;
end;

procedure InitJapaneseDataset;
begin
  Symbols[0]:=#$30A2; HexCodes[0]:='30A2'; Romaji[0]:='a'; Groups[0]:='Vowels (A-row)'; Hints[0]:='Vocab: America ('#$30A2#$30E1#$30EA#$30AB' / amerika)';
  Symbols[1]:=#$30A4; HexCodes[1]:='30A4'; Romaji[1]:='i'; Groups[1]:='Vowels (A-row)'; Hints[1]:='Vocab: India ('#$30A4#$30F3#$30C9' / indo)';
  Symbols[2]:=#$30A6; HexCodes[2]:='30A6'; Romaji[2]:='u'; Groups[2]:='Vowels (A-row)'; Hints[2]:='Vocab: Vector ('#$30D9#$30AF#$30C8#$30EB' / beku-toru)';
  Symbols[3]:=#$30A8; HexCodes[3]:='30A8'; Romaji[3]:='e'; Groups[3]:='Vowels (A-row)'; Hints[3]:='Vocab: Energy ('#$30A8#$30CD#$30EB#$30AE' / enerugi)';
  Symbols[4]:=#$30AA; HexCodes[4]:='30AA'; Romaji[4]:='o'; Groups[4]:='Vowels (A-row)'; Hints[4]:='Vocab: Orange ('#$30AA#$30EC#$30F3#$30B8' / orenji)';
  Symbols[5]:=#$30AB; HexCodes[5]:='30AB'; Romaji[5]:='ka'; Groups[5]:='K-Group (Ka-row)'; Hints[5]:='Vocab: Camera ('#$30AB#$30E1#$30E9' / kamera)';
  Symbols[6]:=#$30AD; HexCodes[6]:='30AD'; Romaji[6]:='ki'; Groups[6]:='K-Group (Ka-row)'; Hints[6]:='Vocab: King ('#$30AD#$30F3#$30B0' / kingu)';
  Symbols[7]:=#$30AF; HexCodes[7]:='30AF'; Romaji[7]:='ku'; Groups[7]:='K-Group (Ka-row)'; Hints[7]:='Vocab: Class ('#$30AF#$30E9#$30B9' / kurasu)';
  Symbols[8]:=#$30B1; HexCodes[8]:='30B1'; Romaji[8]:='ke'; Groups[8]:='K-Group (Ka-row)'; Hints[8]:='Vocab: Cake ('#$30B1#$30FC#$30AD' / keeki)';
  Symbols[9]:=#$30B3; HexCodes[9]:='30B3'; Romaji[9]:='ko'; Groups[9]:='K-Group (Ka-row)'; Hints[9]:='Vocab: Coffee ('#$30B3#$30FC#$30D2#$30FC' / koohii)';
  Symbols[10]:=#$30B5; HexCodes[10]:='30B5'; Romaji[10]:='sa'; Groups[10]:='S-Group (Sa-row)'; Hints[10]:='Vocab: Salad ('#$30B5#$30E9#$30C0' / sarada)';
  Symbols[11]:=#$30B7; HexCodes[11]:='30B7'; Romaji[11]:='shi, si'; Groups[11]:='S-Group (Sa-row)'; Hints[11]:='Vocab: Shirt ('#$30B7#$30E3#$30C4' / shatsu)';
  Symbols[12]:=#$30B9; HexCodes[12]:='30B9'; Romaji[12]:='su'; Groups[12]:='S-Group (Sa-row)'; Hints[12]:='Vocab: Sports ('#$30B9#$30DD#$30FC#$30C4' / supootsu)';
  Symbols[13]:=#$30BB; HexCodes[13]:='30BB'; Romaji[13]:='se'; Groups[13]:='S-Group (Sa-row)'; Hints[13]:='Vocab: Center ('#$30BB#$30F3#$30BF#$30FC' / sentaa)';
  Symbols[14]:=#$30BD; HexCodes[14]:='30BD'; Romaji[14]:='so'; Groups[14]:='S-Group (Sa-row)'; Hints[14]:='Vocab: Sofa ('#$30BD#$30D5#$30A1#$30FC' / sofaa)';
  Symbols[15]:=#$30BF; HexCodes[15]:='30BF'; Romaji[15]:='ta'; Groups[15]:='T-Group (Ta-row)'; Hints[15]:='Vocab: Taxi ('#$30BF#$30AF#$30B7#$30FC' / takushii)';
  Symbols[16]:=#$30C1; HexCodes[16]:='30C1'; Romaji[16]:='chi, ti'; Groups[16]:='T-Group (Ta-row)'; Hints[16]:='Vocab: Team ('#$30C1#$30FC#$30E0' / chiimu)';
  Symbols[17]:=#$30C4; HexCodes[17]:='30C4'; Romaji[17]:='tsu, tu'; Groups[17]:='T-Group (Ta-row)'; Hints[17]:='Vocab: Tour ('#$30C4#$30A2#$30FC' / tsuaa)';
  Symbols[18]:=#$30C6; HexCodes[18]:='30C6'; Romaji[18]:='te'; Groups[18]:='T-Group (Ta-row)'; Hints[18]:='Vocab: Tennis ('#$30C6#$30CB#$30B9' / tenisu)';
  Symbols[19]:=#$30C8; HexCodes[19]:='30C8'; Romaji[19]:='to'; Groups[19]:='T-Group (Ta-row)'; Hints[19]:='Vocab: Tomato ('#$30C8#$30DE#$30C8' / tomato)';
  Symbols[20]:=#$30CA; HexCodes[20]:='30CA'; Romaji[20]:='na'; Groups[20]:='N-Group (Na-row)'; Hints[20]:='Vocab: Knife ('#$30CA#$30A4#$30D5' / naifu)';
  Symbols[21]:=#$30CB; HexCodes[21]:='30CB'; Romaji[21]:='ni'; Groups[21]:='N-Group (Na-row)'; Hints[21]:='Vocab: News ('#$30CB#$30E5#$30FC#$30B9' / nyuusu)';
  Symbols[22]:=#$30CC; HexCodes[22]:='30CC'; Romaji[22]:='nu'; Groups[22]:='N-Group (Na-row)'; Hints[22]:='Vocab: Noodle ('#$30CC#$30FC#$30C9#$30EB' / nuudoru)';
  Symbols[23]:=#$30CD; HexCodes[23]:='30CD'; Romaji[23]:='ne'; Groups[23]:='N-Group (Na-row)'; Hints[23]:='Vocab: Necktie ('#$30CD#$30AF#$30BF#$30A4' / nekutai)';
  Symbols[24]:=#$30CE; HexCodes[24]:='30CE'; Romaji[24]:='no'; Groups[24]:='N-Group (Na-row)'; Hints[24]:='Vocab: Note ('#$30CE#$30FC#$30C8' / nooto)';
  Symbols[25]:=#$30CF; HexCodes[25]:='30CF'; Romaji[25]:='ha'; Groups[25]:='H-Group (Ha-row)'; Hints[25]:='Vocab: Ham ('#$30CF#$30E0' / hamu)';
  Symbols[26]:=#$30D2; HexCodes[26]:='30D2'; Romaji[26]:='hi'; Groups[26]:='H-Group (Ha-row)'; Hints[26]:='Vocab: Hero ('#$30D2#$30ED#$30FC' / hiroo)';
  Symbols[27]:=#$30D5; HexCodes[27]:='30D5'; Romaji[27]:='fu, hu'; Groups[27]:='H-Group (Ha-row)'; Hints[27]:='Vocab: Fork ('#$30D5#$30A9#$30FC#$30AF' / fooku)';
  Symbols[28]:=#$30D8; HexCodes[28]:='30D8'; Romaji[28]:='he'; Groups[28]:='H-Group (Ha-row)'; Hints[28]:='Vocab: Helicopter ('#$30D8#$30EA#$30B3#$30D7#$30BF#$30FC' / herikoputaa)';
  Symbols[29]:=#$30DB; HexCodes[29]:='30DB'; Romaji[29]:='ho'; Groups[29]:='H-Group (Ha-row)'; Hints[29]:='Vocab: Hotel ('#$30DB#$30C6#$30EB' / hoteru)';
  Symbols[30]:=#$30DE; HexCodes[30]:='30DE'; Romaji[30]:='ma'; Groups[30]:='M-Group (Ma-row)'; Hints[30]:='Vocab: Mask ('#$30DE#$30B9#$30AF' / masuku)';
  Symbols[31]:=#$30DF; HexCodes[31]:='30DF'; Romaji[31]:='mi'; Groups[31]:='M-Group (Ma-row)'; Hints[31]:='Vocab: Milk ('#$30DF#$30EB#$30AF' / miruku)';
  Symbols[32]:=#$30E0; HexCodes[32]:='30E0'; Romaji[32]:='mu'; Groups[32]:='M-Group (Ma-row)'; Hints[32]:='Vocab: Music ('#$30DF#$30E5#$30FC#$30B8#$30C3#$30AF' / myuujikku)';
  Symbols[33]:=#$30E1; HexCodes[33]:='30E1'; Romaji[33]:='me'; Groups[33]:='M-Group (Ma-row)'; Hints[33]:='Vocab: Menu ('#$30E1#$30CB#$30E5#$30FC' / menyuu)';
  Symbols[34]:=#$30E2; HexCodes[34]:='30E2'; Romaji[34]:='mo'; Groups[34]:='M-Group (Ma-row)'; Hints[34]:='Vocab: Monitor ('#$30E2#$30CB#$30BF#$30FC' / monitaa)';
  Symbols[35]:=#$30E4; HexCodes[35]:='30E4'; Romaji[35]:='ya'; Groups[35]:='Y-Group (Ya-row)'; Hints[35]:='Vocab: Yahoo ('#$30E4#$30D5#$30FC' / yafuu)';
  Symbols[36]:=#$30E6; HexCodes[36]:='30E6'; Romaji[36]:='yu'; Groups[36]:='Y-Group (Ya-row)'; Hints[36]:='Vocab: User ('#$30E6#$30FC#$30B6#$30FC' / yuuzaa)';
  Symbols[37]:=#$30E8; HexCodes[37]:='30E8'; Romaji[37]:='yo'; Groups[37]:='Y-Group (Ya-row)'; Hints[37]:='Vocab: Yogurt ('#$30E8#$30FC#$30B0#$30EB#$30C8' / yooguruto)';
  Symbols[38]:=#$30E9; HexCodes[38]:='30E9'; Romaji[38]:='ra'; Groups[38]:='R-Group (Ra-row)'; Hints[38]:='Vocab: Radio ('#$30E9#$30B8#$30AA' / rajio)';
  Symbols[39]:=#$30EA; HexCodes[39]:='30EA'; Romaji[39]:='ri'; Groups[39]:='R-Group (Ra-row)'; Hints[39]:='Vocab: Ribbon ('#$30EA#$30DC#$30F3' / ribon)';
  Symbols[40]:=#$30EB; HexCodes[40]:='30EB'; Romaji[40]:='ru'; Groups[40]:='R-Group (Ra-row)'; Hints[40]:='Vocab: Rule ('#$30EB#$30FC#$30EB' / ruuru)';
  Symbols[41]:=#$30EC; HexCodes[41]:='30EC'; Romaji[41]:='re'; Groups[41]:='R-Group (Ra-row)'; Hints[41]:='Vocab: Lemon ('#$30EC#$30E2#$30F3' / remon)';
  Symbols[42]:=#$30ED; HexCodes[42]:='30ED'; Romaji[42]:='ro'; Groups[42]:='R-Group (Ra-row)'; Hints[42]:='Vocab: Robot ('#$30ED#$30DC#$30C3#$30C8' / robotto)';
  Symbols[43]:=#$30EF; HexCodes[43]:='30EF'; Romaji[43]:='wa'; Groups[43]:='W-Group (Wa-row)'; Hints[43]:='Vocab: Wine ('#$30EF#$30A4#$30F3' / wain)';
  Symbols[44]:=#$30F2; HexCodes[44]:='30F2'; Romaji[44]:='wo, o'; Groups[44]:='W-Group (Wa-row)'; Hints[44]:='Vocab: Particle Wo ('#$30F2' / wo)';
  Symbols[45]:=#$30F3; HexCodes[45]:='30F3'; Romaji[45]:='n'; Groups[45]:='N-Singular'; Hints[45]:='Vocab: Pan / Bread ('#$30D1#$30F3' / pan)';
  Symbols[46]:=#$30AC; HexCodes[46]:='30AC'; Romaji[46]:='ga'; Groups[46]:='G-Group (Dakuten)'; Hints[46]:='Vocab: Garlic ('#$30AC#$30FC#$30EA#$30C3#$30AF' / gaarikku)';
  Symbols[47]:=#$30AE; HexCodes[47]:='30AE'; Romaji[47]:='gi'; Groups[47]:='G-Group (Dakuten)'; Hints[47]:='Vocab: Guitar ('#$30AE#$30BF#$30FC' / gitaa)';
  Symbols[48]:=#$30B0; HexCodes[48]:='30B0'; Romaji[48]:='gu'; Groups[48]:='G-Group (Dakuten)'; Hints[48]:='Vocab: Glass ('#$30B0#$30E9#$30B9' / gurasu)';
  Symbols[49]:=#$30B2; HexCodes[49]:='30B2'; Romaji[49]:='ge'; Groups[49]:='G-Group (Dakuten)'; Hints[49]:='Vocab: Game ('#$30B2#$30FC#$30E0' / geemu)';
  Symbols[50]:=#$30B4; HexCodes[50]:='30B4'; Romaji[50]:='go'; Groups[50]:='G-Group (Dakuten)'; Hints[50]:='Vocab: Golf ('#$30B4#$30EB#$30D5' / gorufu)';
  Symbols[51]:=#$30B6; HexCodes[51]:='30B6'; Romaji[51]:='za'; Groups[51]:='Z-Group (Dakuten)'; Hints[51]:='Vocab: Bazaar ('#$30D0#$30B6#$30FC' / bazaa)';
  Symbols[52]:=#$30B8; HexCodes[52]:='30B8'; Romaji[52]:='ji, zi'; Groups[52]:='Z-Group (Dakuten)'; Hints[52]:='Vocab: Juice ('#$30B8#$30E5#$30FC#$30B9' / juusu)';
  Symbols[53]:=#$30BA; HexCodes[53]:='30BA'; Romaji[53]:='zu'; Groups[53]:='Z-Group (Dakuten)'; Hints[53]:='Vocab: Jeans ('#$30B8#$30FC#$30F3#$30BA' / jiinzu)';
  Symbols[54]:=#$30BC; HexCodes[54]:='30BC'; Romaji[54]:='ze'; Groups[54]:='Z-Group (Dakuten)'; Hints[54]:='Vocab: Jelly ('#$30BC#$30EA#$30FC' / zerii)';
  Symbols[55]:=#$30BE; HexCodes[55]:='30BE'; Romaji[55]:='zo'; Groups[55]:='Z-Group (Dakuten)'; Hints[55]:='Vocab: Zombie ('#$30BE#$30F3#$30D3' / zonbi)';
  Symbols[56]:=#$30C0; HexCodes[56]:='30C0'; Romaji[56]:='da'; Groups[56]:='D-Group (Dakuten)'; Hints[56]:='Vocab: Dance ('#$30C0#$30F3#$30B9' / dansu)';
  Symbols[57]:=#$30C2; HexCodes[57]:='30C2'; Romaji[57]:='ji, zi'; Groups[57]:='D-Group (Dakuten)'; Hints[57]:='Vocab: Voiced Ji ('#$30C2' / ji)';
  Symbols[58]:=#$30C5; HexCodes[58]:='30C5'; Romaji[58]:='zu'; Groups[58]:='D-Group (Dakuten)'; Hints[58]:='Vocab: Voiced Zu ('#$30C5' / zu)';
  Symbols[59]:=#$30C7; HexCodes[59]:='30C7'; Romaji[59]:='de'; Groups[59]:='D-Group (Dakuten)'; Hints[59]:='Vocab: Desk ('#$30C7#$30B9#$30AF' / desuku)';
  Symbols[60]:=#$30C9; HexCodes[60]:='30C9'; Romaji[60]:='do'; Groups[60]:='D-Group (Dakuten)'; Hints[60]:='Vocab: Door ('#$30C9#$30A2' / doa)';
  Symbols[61]:=#$30D0; HexCodes[61]:='30D0'; Romaji[61]:='ba'; Groups[61]:='B-Group (Dakuten)'; Hints[61]:='Vocab: Banana ('#$30D0#$30CA#$30CA' / banana)';
  Symbols[62]:=#$30D3; HexCodes[62]:='30D3'; Romaji[62]:='bi'; Groups[62]:='B-Group (Dakuten)'; Hints[62]:='Vocab: Building ('#$30D3#$30EB' / biru)';
  Symbols[63]:=#$30D6; HexCodes[63]:='30D6'; Romaji[63]:='bu'; Groups[63]:='B-Group (Dakuten)'; Hints[63]:='Vocab: Bus ('#$30D0#$30B9' / basu)';
  Symbols[64]:=#$30D9; HexCodes[64]:='30D9'; Romaji[64]:='be'; Groups[64]:='B-Group (Dakuten)'; Hints[64]:='Vocab: Bed ('#$30D9#$30C3#$30C9' / beddo)';
  Symbols[65]:=#$30DC; HexCodes[65]:='30DC'; Romaji[65]:='bo'; Groups[65]:='B-Group (Dakuten)'; Hints[65]:='Vocab: Ball ('#$30DC#$30FC#$30EB' / booru)';
  Symbols[66]:=#$30D1; HexCodes[66]:='30D1'; Romaji[66]:='pa'; Groups[66]:='P-Group (Handakuten)'; Hints[66]:='Vocab: Pan / Bread ('#$30D1#$30F3' / pan)';
  Symbols[67]:=#$30D4; HexCodes[67]:='30D4'; Romaji[67]:='pi'; Groups[67]:='P-Group (Handakuten)'; Hints[67]:='Vocab: Piano ('#$30D4#$30A2#$30CE' / piano)';
  Symbols[68]:=#$30D7; HexCodes[68]:='30D7'; Romaji[68]:='pu'; Groups[68]:='P-Group (Handakuten)'; Hints[68]:='Vocab: Pool ('#$30D7#$30FC#$30EB' / puuru)';
  Symbols[69]:=#$30DA; HexCodes[69]:='30DA'; Romaji[69]:='pe'; Groups[69]:='P-Group (Handakuten)'; Hints[69]:='Vocab: Pen ('#$30DA#$30F3' / pen)';
  Symbols[70]:=#$30DD; HexCodes[70]:='30DD'; Romaji[70]:='po'; Groups[70]:='P-Group (Handakuten)'; Hints[70]:='Vocab: Post / Mail ('#$30DD#$30B9#$30C8' / posuto)';
  Symbols[71]:=#$65E5; HexCodes[71]:='65E5'; Romaji[71]:='nichi, hi, bi'; Groups[71]:='Kanji (Nature / Days)'; Hints[71]:='Vocab: Sun / Japan ('#$65E5#$672C' / Nihon) | Day ('#$65E5' / hi)';
  Symbols[72]:=#$6708; HexCodes[72]:='6708'; Romaji[72]:='getsu, gatsu, tsuki'; Groups[72]:='Kanji (Nature / Days)'; Hints[72]:='Vocab: Moon/Monday ('#$6708#$66DC#$65E5' / Getsuyoubi) |Moon('#$6708'/tsuki)';
  Symbols[73]:=#$706B; HexCodes[73]:='706B'; Romaji[73]:='ka, hi'; Groups[73]:='Kanji (Elements / Days)'; Hints[73]:='Vocab: Fire / Tuesday ('#$706B#$66DC#$65E5' / Kayoubi) | Fire ('#$706B' / hi)';
  Symbols[74]:=#$6C34; HexCodes[74]:='6C34'; Romaji[74]:='sui, mizu'; Groups[74]:='Kanji (Elements / Days)'; Hints[74]:='Vocab: Water / Wednesday ('#$6C34#$66DC#$65E5' / Suiyoubi) | Water ('#$6C34' / mizu)';
  Symbols[75]:=#$6728; HexCodes[75]:='6728'; Romaji[75]:='moku, boku, ki'; Groups[75]:='Kanji (Elements / Days)'; Hints[75]:='Vocab: Tree / Thursday ('#$6728#$66DC#$65E5' / Mokuyoubi) | Tree ('#$6728' / ki)';
  Symbols[76]:=#$91D1; HexCodes[76]:='91D1'; Romaji[76]:='kin, kane'; Groups[76]:='Kanji (Elements / Days)'; Hints[76]:='Vocab: Gold / Friday ('#$91D1#$66DC#$65E5' / Kinyoubi) | Money ('#$91D1' / kane)';
  Symbols[77]:=#$571F; HexCodes[77]:='571F'; Romaji[77]:='do, to, tsuchi'; Groups[77]:='Kanji (Elements / Days)'; Hints[77]:='Vocab: Soil / Saturday ('#$571F#$66DC#$65E5' / Doyoubi) | Earth ('#$571F'/tsuchi)';
  Symbols[78]:=#$5C71; HexCodes[78]:='5C71'; Romaji[78]:='yama, san, zan'; Groups[78]:='Kanji (Nature)'; Hints[78]:='Vocab: Mountain ('#$5C71' / yama) | Mt. Fuji ('#$5BCC#$58EB#$5C71' / Fujisan)';
  Symbols[79]:=#$5DDD; HexCodes[79]:='5DDD'; Romaji[79]:='kawa, gawa, sen'; Groups[79]:='Kanji (Nature)'; Hints[79]:='Vocab: River ('#$5DDD' / kawa) | Stream ('#$5C0F#$5DDD' / Ogawa)';
  Symbols[80]:=#$7530; HexCodes[80]:='7530'; Romaji[80]:='ta, da, den'; Groups[80]:='Kanji (Nature)'; Hints[80]:='Vocab: Rice Field ('#$7530' / ta) | Paddy ('#$6C34#$7530' / Suiden)';
  Symbols[81]:=#$4EBA; HexCodes[81]:='4EBA'; Romaji[81]:='hito, jin, nin'; Groups[81]:='Kanji (People)'; Hints[81]:='Vocab: Person ('#$4EBA' / hito) | Japanese ('#$65E5#$672C#$4EBA' / Nihonjin)';
  Symbols[82]:=#$53E3; HexCodes[82]:='53E3'; Romaji[82]:='kuchi, guchi, kou'; Groups[82]:='Kanji (Body Parts)'; Hints[82]:='Vocab: Mouth ('#$53E3' / kuchi) | Entrance ('#$5165#$53E3' / Iriguchi)';
  Symbols[83]:=#$76EE; HexCodes[83]:='76EE'; Romaji[83]:='me, moku'; Groups[83]:='Kanji (Body Parts)'; Hints[83]:='Vocab: Eye ('#$76EE' / me) | Purpose ('#$76EE#$7684' / Mokuteki)';
  Symbols[84]:=#$624B; HexCodes[84]:='624B'; Romaji[84]:='te, shu'; Groups[84]:='Kanji (Body Parts)'; Hints[84]:='Vocab: Hand ('#$624B' / te) | Skillful ('#$4E0A#$624B' / Jouzu)';
  Symbols[85]:=#$8DB3; HexCodes[85]:='8DB3'; Romaji[85]:='ashi, soku'; Groups[85]:='Kanji (Body Parts)'; Hints[85]:='Vocab: Foot / Leg ('#$8DB3' / ashi) | Excursion ('#$9060#$8DB3' / Ensoku)';
  Symbols[86]:=#$529B; HexCodes[86]:='529B'; Romaji[86]:='chikara, ryoku, riki'; Groups[86]:='Kanji (Body / Mind)'; Hints[86]:='Vocab: Power ('#$529B' / chikara) | Cooperation ('#$5354#$529B' / Kyouryoku)';
  Symbols[87]:=#$5973; HexCodes[87]:='5973'; Romaji[87]:='onna, jo'; Groups[87]:='Kanji (People)'; Hints[87]:='Vocab: Woman ('#$5973' / onna) | Female ('#$5973#$6027' / Josei)';
  Symbols[88]:=#$7537; HexCodes[88]:='7537'; Romaji[88]:='otoko, dan, nan'; Groups[88]:='Kanji (People)'; Hints[88]:='Vocab: Man ('#$7537' / otoko) | Male ('#$7537#$6027' / Dansei)';
  Symbols[89]:=#$5B50; HexCodes[89]:='5B50'; Romaji[89]:='ko, shi'; Groups[89]:='Kanji (People)'; Hints[89]:='Vocab: Child ('#$5B50' / ko) | Children ('#$5B50#$4F9B' / Kodomo)';
  Symbols[90]:=#$5927; HexCodes[90]:='5927'; Romaji[90]:='dai, tai, oo'; Groups[90]:='Kanji (Size / Direction)'; Hints[90]:='Vocab: Big ('#$5927#$304D#$3044' / ookii) | University ('#$5927#$5B66' / Daigaku)';
  Symbols[91]:=#$5C0F; HexCodes[91]:='5C0F'; Romaji[91]:='shou,chiisai,chi';Groups[91]:='Kanji(Size/Direction)';Hints[91]:='Vocab:Small('#$5C0F#$3055#$3044'/chiisai)|Elementary('#$5C0F#$5B66#$751F'/Shougakusei)';
  Symbols[92]:=#$4E2D; HexCodes[92]:='4E2D'; Romaji[92]:='chuu, naka'; Groups[92]:='Kanji (Size / Direction)'; Hints[92]:='Vocab: Inside ('#$4E2D' / naka) | China ('#$4E2D#$56FD' / Chuugoku)';
  Symbols[93]:=#$4E0A; HexCodes[93]:='4E0A'; Romaji[93]:='ue, jou, kami'; Groups[93]:='Kanji (Size / Direction)'; Hints[93]:='Vocab: Above ('#$4E0A' / ue) | Skillful ('#$4E0A#$624B' / Jouzu)';
  Symbols[94]:=#$4E0B; HexCodes[94]:='4E0B'; Romaji[94]:='shita, ka, ge'; Groups[94]:='Kanji (Size / Direction)'; Hints[94]:='Vocab: Below ('#$4E0B' / shita) | Subway ('#$5730#$4E0B#$9244' / Chikatetsu)';
  Symbols[95]:=#$5E74; HexCodes[95]:='5E74'; Romaji[95]:='nen, toshi'; Groups[95]:='Kanji (Time)'; Hints[95]:='Vocab: Year ('#$5E74' / toshi) | This Year ('#$4ECA#$5E74' / Kotoshi)';
  Symbols[96]:=#$5148; HexCodes[96]:='5148'; Romaji[96]:='sen, saki'; Groups[96]:='Kanji (Time / People)'; Hints[96]:='Vocab: Ahead ('#$5148' / saki) | Teacher ('#$5148#$751F' / Sensei)';
  Symbols[97]:=#$751F; HexCodes[97]:='751F'; Romaji[97]:='sei, shou, nama, iki'; Groups[97]:='Kanji (Life / Education)'; Hints[97]:='Vocab: Life / Raw ('#$751F' / nama) | Student ('#$5B66#$751F' / Gakusei)';
  Symbols[98]:=#$5B66; HexCodes[98]:='5B66'; Romaji[98]:='gaku, manabu'; Groups[98]:='Kanji (Education)'; Hints[98]:='Vocab: Study ('#$5B66#$3076' / manabu) | School ('#$5B66#$6821' / Gakkou)';
  Symbols[99]:=#$6821; HexCodes[99]:='6821'; Romaji[99]:='kou'; Groups[99]:='Kanji (Education)'; Hints[99]:='Vocab: School ('#$5B66#$6821' / Gakkou) | High School ('#$9AD8#$6821' / Koukou)';
  Symbols[100]:=#$672C; HexCodes[100]:='672C'; Romaji[100]:='hon, moto'; Groups[100]:='Kanji (Education / Origin)'; Hints[100]:='Vocab: Book / Origin ('#$672C' / hon) | Japanese ('#$65E5#$672C#$8A9E'/Nihongo)';
end;

procedure UpdateScoreDisplay;
var
  Pct: Double;
begin
  if TotalAttempts > 0 then
    Pct:= (CorrectCount * 100.0) / TotalAttempts
  else
    Pct:= 0.0;
  LblScore.Caption:= Format('Score: %d / %d  (Accuracy: %.1f%%)', [CorrectCount, TotalAttempts, Pct]);
end;

procedure LoadNewCharacter(Sender: TObject);
begin
  CurrentIdx:= Random(TOTAL_ITEMS);
  LblKatakana.Caption:= Symbols[CurrentIdx];
  LblGroup.Caption:= 'Group: ' + Groups[CurrentIdx];
  LblHex.Caption:= 'Unicode Hex: U+' + HexCodes[CurrentIdx];
  LblResult.Caption:= 'Type any valid Romaji reading (e.g. Kunyomi / Onyomi) & click Check.';
  LblResult.Font.Color:= clBlack;
  EdtAnswer.Text:= '';
  EdtAnswer.SetFocus;
  IsChecked:= False;
end;

procedure CheckAnswer(Sender: TObject);
var UserAns, TargetAnsList: string;
begin
  if IsChecked then begin
    LoadNewCharacter(Sender);
    Exit;
  end;

  UserAns:= LowerCase(boldTrim(EdtAnswer.Text));
  TargetAnsList:= LowerCase(Romaji[CurrentIdx]);
  Inc(TotalAttempts);
  IsChecked:= True;

 if MatchAnswer(UserAns, TargetAnsList) then begin
  //if UserAns = TargetAnslist then begin
    Inc(CorrectCount);
    LblResult.Caption:='CORRECT!  '+Symbols[CurrentIdx]+' (U+'+HexCodes[CurrentIdx]+') = '+UserAns+' [Valid Readings: '+TargetAnsList + ']';
    LblResult.Font.Color:= clGreen;
    MemoLog.Lines.Add(unicodeFormat('[%d]  %s (U+%s) -> %s (Correct | Accepted: %s)',[TotalAttempts,Symbols[CurrentIdx],HexCodes[CurrentIdx],UserAns,TargetAnsList]));
   end else begin
    LblResult.Caption:=unicodeFormat('INCORRECT!  %s (U+%s) accepted readings: "%s" (You typed: "%s")',[Symbols[CurrentIdx],HexCodes[CurrentIdx],TargetAnsList,UserAns]);
    LblResult.Font.Color:= clRed;
    MemoLog.Lines.Add(unicodeFormat('[%d]  %s (U+%s) -> %s (Expected one of: %s)',[TotalAttempts, Symbols[CurrentIdx],HexCodes[CurrentIdx],UserAns,TargetAnsList]));
   end;

  UpdateScoreDisplay;
end;

procedure ShowHint(Sender: TObject);
begin
  ShowMessage('HINT for '+Symbols[CurrentIdx]+' (U+'+HexCodes[CurrentIdx]+'):'+#13#10+
              'Group: ' + Groups[CurrentIdx] + #13#10 +
              'Accepted Readings: ' + Romaji[CurrentIdx] + #13#10 +
              Hints[CurrentIdx]);
end;

procedure ResetStats(Sender: TObject);
begin
  TotalAttempts:= 0;
  CorrectCount:= 0;
  UpdateScoreDisplay;
  MemoLog.Clear;
  MemoLog.Lines.Add('=== JAPANESE KATAKANA & KANJI TRAINER (v9) SESSION RESET ===');
  LoadNewCharacter(Sender);
end;

procedure closeForm(Sender: TObject; var Action: TCloseAction);
  begin
    //imagelist2.Free;   
    //FormML.Free;
    action:= caFree;
    Form1:= NIL;
    //Screen.Cursor:= crDefault
    writeln('Katakana Kanji form and log closed..');
  end;

procedure ShowLang_GUI;
begin
  Randomize;
  InitJapaneseDataset;
  TotalAttempts:= 0;
  CorrectCount:= 0;
  IsChecked:= False;

  Application.Initialize;
  Form1:= TForm.Create(Application);
  Form1.Icon.LoadFromResourceName(HInstance,'XUNIT');
  Form1.Caption:='maXbox Japanese Katakana+Kanji Multi-Read Trainer Studio(v9)';
  Form1.SetBounds(100, 100, 800, 540);
  Form1.Position:= poScreenCenter;
  form1.formstyle:= fsstayontop;
  Form1.onClose:= @closeForm;

  // Title Label
  LblTitle:= TLabel.Create(Form1); LblTitle.Parent:= Form1;
  LblTitle.SetBounds(20, 5, 740, 24);
  LblTitle.Caption:= 'Japanese Katakana & Kanji M-Read Vocab Trainer (v9-101 Signs)';
  LblTitle.Font.Name:= 'Arial'; LblTitle.Font.Size:= 12; LblTitle.Font.Style2:= fsBold2;
  LblTitle.Font.Color:= clNavy;
  // Symbol Display Label (Large Font)
  LblKatakana:= TLabel.Create(Form1); LblKatakana.Parent:= Form1;
  LblKatakana.SetBounds(20, 50, 200, 110);
  LblKatakana.Alignment:= taCenter;
  LblKatakana.Font.Name:= 'Arial'; LblKatakana.Font.Size:= 64; LblKatakana.Font.Style2:= fsBold2;
  LblKatakana.Font.Color:= $7319F6; //clDarkRed;

  // Group Category Label
  LblGroup:= TLabel.Create(Form1); LblGroup.Parent:= Form1;
  LblGroup.SetBounds(240, 40, 280, 18);
  LblGroup.Font.Name:= 'Arial'; LblGroup.Font.Size:= 10; LblGroup.Font.Style2:= fsBold2;

  // Unicode Hex Code Display Label
  LblHex:= TLabel.Create(Form1); LblHex.Parent:= Form1;
  LblHex.SetBounds(240, 68, 280, 18);
  LblHex.Font.Name:= 'Arial'; LblHex.Font.Size:= 9; //LblHex.Font.Style2:= fsBold2;
  LblHex.Font.Color:= clBlue;
  // Input Prompt Label
  LblPrompt:= TLabel.Create(Form1); LblPrompt.Parent:= Form1;
  LblPrompt.SetBounds(240, 90, 280, 18);
  LblPrompt.Caption:= 'Enter Romaji (Onyomi / Kunyomi):';

  // Answer Input Edit Box
  EdtAnswer:= TEdit.Create(Form1); EdtAnswer.Parent:= Form1;
  EdtAnswer.SetBounds(240, 115, 200, 32);
  EdtAnswer.Font.Name:= 'Arial'; EdtAnswer.Font.Size:= 14;

  // Action Buttons
  BtnCheck:= TButton.Create(Form1); BtnCheck.Parent:= Form1;
  BtnCheck.SetBounds(240, 155, 115, 32);
  BtnCheck.Caption:= 'Check Answer';
  BtnCheck.OnClick:= @CheckAnswer;
  BtnNext:= TButton.Create(Form1); BtnNext.Parent:= Form1;
  BtnNext.SetBounds(365, 155, 115, 32);
  BtnNext.Caption:= 'Next Sign';
  BtnNext.OnClick:= @LoadNewCharacter;

  BtnHint:= TButton.Create(Form1); BtnHint.Parent:= Form1;
  BtnHint.SetBounds(490, 155, 105, 32);
  BtnHint.Caption:= 'Show Hint';
  BtnHint.OnClick:= @ShowHint;
  BtnReset:= TButton.Create(Form1); BtnReset.Parent:= Form1;
  BtnReset.SetBounds(605, 155, 105, 32);
  BtnReset.Caption:= 'Reset Score';
  BtnReset.OnClick:= @ResetStats;

  // Feedback Result Label
  LblResult:= TLabel.Create(Form1); LblResult.Parent:= Form1;
  LblResult.SetBounds(20, 198, 740, 24);
  LblResult.Font.Name:= 'Arial'; LblResult.Font.Size:= 10; LblResult.Font.Style2:= fsBold2;
  // Score Stats Display Label
  LblScore:= TLabel.Create(Form1); LblScore.Parent:= Form1;
  LblScore.SetBounds(20, 226, 740, 22);
  LblScore.Font.Name:= 'Arial'; LblScore.Font.Size:= 10; //LblScore.Font.Style2:= fsBold2;
  LblScore.Font.Color:= $095ACC; //clDarkSlateGray;

  // Session Activity Log Memo
  MemoLog:= TMemo.Create(Form1); MemoLog.Parent:= Form1;
  MemoLog.SetBounds(20, 260, 740, 220);
  MemoLog.Font.Name:= 'Courier New'; MemoLog.Font.Size:= 9;
  memolog.color:= clmoneygreen;
  MemoLog.ScrollBars:= ssVertical;
  MemoLog.Lines.Add('=== JAPANESE KATAKANA & KANJI MULTI-READING TRAINER LOG (v9) ===');
  MemoLog.Lines.Add('Dataset: 46 Katakana + 25 Voiced Dakuten + 30 N5 Kanji (101 Signs Total)');
  MemoLog.Lines.Add('Supports both Onyomi & Kunyomi readings (e.g. "sui" or "mizu" for Water).');
  MemoLog.Lines.Add('');

  UpdateScoreDisplay;
  Form1.Show;
  LoadNewCharacter(Form1);
  //Form1.Show;
end;

begin  //@main
  SetDebugoff;  
  maxform1.setconsole;
  writeln(#$d83d#$de42);    
  writeln(#$D83E#$DD8B#$30A2);  
  ShowLang_GUI;
  Writeln('Hello '#$D83D#$DE42); // Displays: Hello 🙂
  openWeb('https://raw.githack.com/maxkleiner/maXbox5/main/assets/machinelearning573.htm');
end.

ref: https://medium.com/@maxkleiner1/katakana-language-trainer-0ea409f0a2ab

     https://www.loc.gov/marc/specifications/specchareacc/JapaneseHiraganaKatakana.html
     https://teetrains.wordpress.com/faszination-modellbau/
  
     sha384-iYYqBRXns7oLmHo+YyTAX4bzstga2E/iyRyfgbiAHS247NBc4dFoD16Hhozit9dj

To implement multiple acceptable readings in maXbox (Object Pascal), you use a comma-delimited 
string parsing helper that checks the user's input against a list of valid readings.
Here is the 3-step pattern used in katakana_kanji_language_trainer-v9.pas:
1. Store Comma-Separated Target Strings
In your dataset array, store all valid readings (both Onyomi and Kunyomi) separated by commas:
Romaji[74] := 'sui, mizu';     // Accepts both "sui" and "mizu" for 水
Romaji[71] := 'nichi, hi, bi'; // Accepts "nichi", "hi", or "bi" for 日
Romaji[81] := 'hito, jin, nin'; // Accepts "hito", "jin", or "nin" for 人
2. Add the MatchAnswer Helper Function
This function normalizes the target string list, appends a trailing comma for iteration, 
and extracts tokens one by one using Pos, Copy, and Delete:

Key Features of Version 9 Web Application

Multi-Reading Answer Verification: checkAnswer() splits comma-separated target readings 
(item.romaji.split(',')) and validates user input against any matching Onyomi or Kunyomi sound.

Comprehensive Compound Hints: Hints now highlight both standalone meanings 
and compound vocabulary (e.g. 日 $\rightarrow$ Japan (日本 / Nihon) | Day (日 / hi)).

Complete 101 Character Coverage: Covers 46 Basic Katakana, 25 Voiced Dakuten/Handakuten, and 30 N5 Kanji.


