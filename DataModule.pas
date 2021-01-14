unit DataModule;

interface

uses
  System.SysUtils, System.Classes, Vcl.ImgList, Vcl.Controls, System.Generics.Collections,
  Vcl.Graphics, System.Masks;

type
  Tg_DataModule = class(TDataModule)
    ListViewIcons: TImageList;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TExeData = class
    exename: string;
    Icon: TIcon;
    l_IconIndex : integer;
    exeStringsWCounters: TDictionary<string, cardinal>;
    procedure Init(fileName: string; path: string);
    function AddCounter(textStr: string; value: cardinal): Integer;
    function GetCounter(textStr: string): cardinal; overload;
    function GetCounter(): cardinal; overload;
    function LoadFromFile(processDB: TStringList; basePath: string):boolean;
    function SaveToFile(basePath: string): boolean;
  end;

type
  wildcardMask = class
    exename: string;
    wildcardsstring: TList<string>;
    wildcards: TList<TMask>;
    { *m = new TMask("String to check");
      bool isMatch = m->Matches("string to*");
      delete m; }

    function IsExeMatches(exeToTest: string): boolean;
    function IsWildcardMatchesTo(checkedtext: string): boolean;

    procedure LoadData(fileName: string; wildcardsData: TStringList);
  end;

function IsMatchesWildcards(exename: string; textData: string): Integer;

var
  g_AddFilterForm_CategoryColorData : TDictionary<string, TColor>;
  g_AddFilterForm_CategoryColor_Default : TColor = clWindow;
  g_AddFilterForm_CategorySummaryName : string = 'Summary';

var
  g_DataModule: Tg_DataModule;

var
  g_Wildcards: TList<TList<wildcardMask>>;
  g_defaultGroupIndex : integer = 0;

type TTodayFilter = class
    value : cardinal;
    name : string;
    fullName : string;
    monthlyChartAlwaysVisibleMarks : boolean;
  end;

var
  g_Dictionary: TDictionary<string, TExeData>;
  g_SummaryFiltersIndex : integer;
  g_TodayFilters : TDictionary<integer, TTodayFilter>;

var
  g_exePath: string;
  g_dbPath: string;
  g_todayPath: string;

function GetCategoryColor(item: string): TColor;
function ConvertDateToDayPath(date : TDateTime):string;
function ConvertDateToDayPathInDBLocation(date : TDateTime):string;
function ConvertDateStringToPathInDBLocation( dateString : string ):string;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses  Winapi.PsAPI, ShellAPI, Winapi.Windows, System.IOUtils;

function ConvertDateToDayPath(date : TDateTime):string;
begin
   result := FormatDateTime('yyyy-mm-dd', date);;
end;

function ConvertDateToDayPathInDBLocation(date : TDateTime):string;
begin
  result := g_dbPath + '\' + FormatDateTime('yyyy-mm-dd', date);
end;

function ConvertDateStringToPathInDBLocation( dateString : string ):string;
begin
  result := g_dbPath + '\' + dateString;
end;


function GetCategoryColor(item: string): TColor;
begin
  if (g_AddFilterForm_CategoryColorData.ContainsKey(item)) then
  begin
    result := g_AddFilterForm_CategoryColorData[item];
  end
  else
  begin
    result := g_AddFilterForm_CategoryColor_Default;
  end;
end;


function wildcardMask.IsExeMatches(exeToTest: string): boolean;
begin
  result := Comparetext(self.exename, exeToTest) = 0;
end;

function wildcardMask.IsWildcardMatchesTo(checkedtext: string): boolean;
var
  I: Integer;
begin
  for I := 0 to (wildcards.Count - 1) do
  begin
    if (wildcards[I].Matches(checkedtext)) then
    begin
      exit(true);
    end;
  end;
  exit(false);
end;

procedure wildcardMask.LoadData(fileName: string; wildcardsData: TStringList);
var
  I: Integer;
begin
  wildcardsstring := TList<string>.Create();
  wildcards := TList<TMask>.Create();

  self.exename := fileName + '.exe';
  if (wildcardsData.Count = 0) then
  begin
    wildcardsstring.Add('');
    wildcards.Add(TMask.Create('*'));
  end
  else
  begin
    for I := 0 to wildcardsData.Count - 1 do
    begin
      wildcardsstring.Add(wildcardsData[I]);
      wildcards.Add(TMask.Create('*' + wildcardsData[I] + '*'));
    end;
  end;
end;


function ExtractIconFromFile(fileName: string): TIcon;
var
  // IconIndex : integer;
  IconHandle, IconSmallHandle: HIcon;
  // Icon : integer;
  // s: String;
  // FileInfo: TSHFileInfo;
  // Flags: Integer;

  { Bitmap : TBitmap; }
  Icon: TIcon;
  IconIndex : integer;

  // NumIcons : integer;
  // pTheLargeIcons : phIconArray;

begin
  // GetMem(pTheLargeIcons, 1 * sizeof(hIcon));
  // FillChar(pTheLargeIcons^, 1 * sizeof(hIcon), #0);
  if (TFile.Exists(fileName + '.ico')) then
  begin
        IconHandle := ExtractIcon(0, PWideChar(fileName + '.ico'), 0);
  end
  else
  begin
    IconHandle := ExtractIcon(0, PWideChar(fileName), 0);
  end;
  // ExtractIconEx(PWideChar(fileName), 0, IconHandle, IconSmallHandle, 1);

  { Flags := SHGFI_ICON or SHGFI_SYSICONINDEX or SHGFI_LARGEICON;
    SHGetFileInfo(PChar(s),
    0,
    FileInfo,
    SizeOf(FileInfo),
    Flags); }

  Icon := TIcon.Create;
  Icon.Handle := IconHandle;
  // Icon.SetSize(256,256);

  // Icon.LoadFromFile();
  // Icon.Handle := pTheLargeIcons[0];
  // FreeMem(pTheLargeIcons, 1 * sizeof(hIcon));
  // Icon.Handle :=  FileInfo.hIcon;

  { Bitmap := TBitmap.Create;
    try
    Bitmap.Width := Icon.Width;
    Bitmap.Height := Icon.Height;
    Bitmap.Canvas.Draw(0, 0, Icon);
    form3.SpeedButton1.Glyph.Assign(Bitmap);
    finally
    Bitmap.Free;
    end; }

  result := Icon;
end;

procedure TExeData.Init(fileName: string; path: string);
begin
  exename := fileName;
  exeStringsWCounters := TDictionary<string, cardinal>.Create();
  if (path<>'') then
  begin
    Icon := ExtractIconFromFile(path);
  end;
end;

function TExeData.LoadFromFile(processDB: TStringList; basePath: string):boolean;
var
  I: Integer;
  index: Integer;
  limitIndex: Integer;
  wrongItems : TList<integer>;
  indexOf : integer;
begin
  result := false;
  Init(processDB[0], basePath + '\' + processDB[0] + '.ico');

  index := 1;
  limitIndex := ((processDB.Count - 1) div 2) - 1;
  wrongItems := TList<integer>.Create();
  for I := 0 to limitIndex do
  begin
    if (not exeStringsWCounters.ContainsKey(processDB[index])) then
    begin
       exeStringsWCounters.Add(processDB[index], strtoint(processDB[index + 1]));
    end
    else
    begin
       wrongItems.Add(index);
       wrongItems.Add(index+1);
       exeStringsWCounters[processDB[index]] := exeStringsWCounters[processDB[index]] + strtoint(processDB[index + 1]);
       indexOf := processDB.IndexOf(processDB[index]) + 1;
       processDB[indexOf] := inttostr(strtoint(processDB[indexOf]) + strtoint(processDB[index + 1]));
    end;
    index := index + 2;
  end;

  result := wrongItems.Count > 0;

  for I := wrongItems.Count-1 downto 0 do
  begin
     processDB.Delete(wrongItems[i]);
  end;

  wrongItems.Free;
end;

function TExeData.SaveToFile(basePath: string): boolean;
var
  I: Integer;
  processDB: TStringList;
  Key: string;

  icoName: string;
begin
  processDB := TStringList.Create;
  processDB.Add(exename);

  icoName := basePath + '\' + exename + '.ico';
  if (not TFile.Exists(icoName)) then
  begin
    try
      Icon.SaveToFile(icoName);
    except
    end;
  end;

  for Key in exeStringsWCounters.Keys do
  begin
    processDB.Add(Key);
    processDB.Add(inttostr(exeStringsWCounters[Key]))
  end;

  processDB.SaveToFile(basePath + '\' + exename + '.txt');
  processDB.Free;

end;

function TExeData.GetCounter(textStr: string): cardinal;
begin
  if (exeStringsWCounters.ContainsKey(textStr)) then
  begin // увеличиваем значение
    result := exeStringsWCounters[textStr];
  end
  else
  begin
    result := 0;
  end;
end;

function TExeData.GetCounter(): cardinal;
var value : cardinal;
begin
  result := 0;
  for value in exeStringsWCounters.Values do
  begin // увеличиваем значение
    result := result + value;
  end;

end;

// находим нужный каунтер и добавляем в него
function TExeData.AddCounter(textStr: string; value: cardinal): Integer;
begin
  // если такой каунтер у нас есть
  if (exeStringsWCounters.ContainsKey(textStr)) then
  begin // увеличиваем значение
    result := exeStringsWCounters[textStr] + value;
    exeStringsWCounters[textStr] := result;
  end
  else
  begin
    // добавляем значение
    exeStringsWCounters.Add(textStr, value);
    result := value;
  end;
end;

procedure InitLocal_G();
begin
   g_AddFilterForm_CategoryColorData := TDictionary<string, TColor>.Create();
end;

procedure ClearLocal_G();
begin
   if ( g_AddFilterForm_CategoryColorData <> nil) then
   begin
     g_AddFilterForm_CategoryColorData.Free;
     g_AddFilterForm_CategoryColorData := nil;
   end;
end;


procedure Tg_DataModule.DataModuleCreate(Sender: TObject);
begin
       InitLocal_G();
end;

procedure Tg_DataModule.DataModuleDestroy(Sender: TObject);
begin
      ClearLocal_G();
end;

 //return index of matched wildcard in wildcards array from 0
function IsMatchesWildcards(exename: string; textData: string): Integer;
var
  I: Integer;
  wildcardIndex : integer;
begin
  for I := 0 to (g_Wildcards.Count - 1) do
  begin
    for wildcardIndex := 0 to (g_Wildcards[I].Count - 1) do
    begin
      if (g_Wildcards[I][wildcardIndex].IsExeMatches(exename)) then
      begin
        if (g_Wildcards[I][wildcardIndex].IsWildcardMatchesTo(textData)) then
        begin
          exit(I);
        end;
      end;
    end;
  end;
  exit(-1);
end;


end.
