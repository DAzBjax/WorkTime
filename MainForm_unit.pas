unit MainForm_unit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Types,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Grids, Vcl.ValEdit,
  System.IOUtils, System.Masks,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.Samples.Spin, Vcl.ComCtrls, Vcl.ImgList,
  VCLTee.TeEngine, VCLTee.Series, VCLTee.TeeProcs, VCLTee.Chart;

type
  TMainForm = class(TForm)
    OneSecTimer: TTimer;
    Edit_ActiveProcessName: TEdit;
    Edit_ActiveProcessFormName: TEdit;
    SaveButton: TButton;
    UserActivityTimer: TTimer;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    SpinEdit_UserAwayLimitInM: TSpinEdit;
    Edit_Away: TLabeledEdit;
    ListView1: TListView;
    Timer_AutoSave: TTimer;
    Chart_4WeeksData: TChart;
    Chart_Today: TChart;
    Series2: TBarSeries;
    Series3: TBarSeries;
    Series1: TBarSeries;
    Series4: TLineSeries;
    Series5: TLineSeries;
    Series6: TLineSeries;
    Series7: TLineSeries;
    Button2: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Button_RestartThisApplication: TButton;
    CheckBox_EnableAlwaysMarks: TCheckBox;
    Edit_ActiveProcessCounter: TEdit;
    Edit_SelectedProcessName: TEdit;
    Button_AddExternalData: TButton;
    FileOpenDialog1: TFileOpenDialog;
    procedure OneSecTimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure UserActivityTimerTimer(Sender: TObject);
    procedure SpinEdit_UserAwayLimitInMChange(Sender: TObject);
    procedure ListView1ColumnClick(Sender: TObject; Column: TListColumn);
    procedure ListView1Compare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
    procedure ListView1DblClick(Sender: TObject);
    procedure Timer_AutoSaveTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure UpdateTodayValuesInChart(index: Integer; value: cardinal);
    procedure UpdateTodaySummaryValuesInChart(SummaryFiltersIndex: Integer);
    procedure UpdateTodaySummaryValuesInMonthsChart(SummaryFiltersIndex: Integer);
    procedure Button2Click(Sender: TObject);
    procedure Chart_4WeeksDataMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Button_RestartThisApplicationClick(Sender: TObject);
    procedure TabSheet1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Button_AddExternalDataClick(Sender: TObject);

  private
    procedure AddBarChart_IntoTodayChart(categoryName: string; wildcardsBaseDir: string; I: Integer);
    procedure SimulateActiveProcess(textStr: string; path: string; counter: cardinal; exename: string);

    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses System.Generics.Collections, Winapi.PsAPI, ShellAPI, System.TimeSpan, Vcl.Clipbrd, DataModule, addfilterform_unit,
  DateUtils, SyncObjs, System.Generics.Defaults;

function MS2S(value: cardinal): string;
begin
  result := Format('%.2d:%.2d:%.2d', [Integer((value div (1000 * 60 * 60)) mod 24),
    Integer((value div (1000 * 60)) mod 60), Integer((value div (1000)) mod 60)]);
end;

var
  g_ListViewRoots: TDictionary<string, TListItem>;

var
  g_textChars_hash: PWideChar;

  // загружаем один деь целиком из указанного пути, на выходе выдаем
procedure LoadDictionaryDayDataInto(l_DayPath: string; l_TodayFilters: TDictionary<Integer, TTodayFilter>);
var
  processDB: TStringList;
  processesDBs: TStringDynArray;
  I: Integer;
  exeData: TExeData;

  filter: TTodayFilter;
  exeList: TList<TExeData>;
  exeLines: string;

  groupIndex: Integer;
begin
  // check input directory
  if (not TDirectory.Exists(l_DayPath)) then
    exit();

  // clear filter
  for filter in l_TodayFilters.Values do
  begin
    filter.value := 0;
  end;

  // load all txt only files with processes stored data
  processesDBs := TDirectory.GetFiles(l_DayPath, '*.txt');

  // generate new list
  processDB := TStringList.Create;
  exeList := TList<TExeData>.Create;

  // for each loaded txt file
  for I := 0 to High(processesDBs) do
  begin
    processDB.LoadFromFile(processesDBs[I]); // load it txt into lines list
    exeData := TExeData.Create; // create new exe info instance
    // exeData.Init(processesDBs[0], processesDBs[1]);
    if (exeData.LoadFromFile(processDB, '')) then // generate ico and load all data into
    begin // return true if list must be resaved
      processDB.SaveToFile(processesDBs[I]);
    end;
    exeList.Add(exeData); // add into array
  end;
  processDB.Free; // clear list

  for exeData in exeList do // foreach exe info
  begin
    for exeLines in exeData.exeStringsWCounters.Keys do // list all exe entries with all for names
    begin
      // listTextValue := exeData.exename + ' - ' + exeLines; // full line

      // listViewItem := ListViewEditor.Items.Add(); // add list view item
      // exeData.l_IconIndex := ListViewIcons.AddIcon(exeData.Icon); // store icon ondex from icons list
      // listViewItem.ImageIndex := exeData.l_IconIndex; // set list view item icon

      // listViewItem.SubItems.Add(listTextValue); // add exename text
      // listViewItem.SubItems.Add(MS2S(exeData.exeStringsWCounters[exeLines])); // add form text

      groupIndex := DataModule.IsMatchesWildcards(exeData.exename, exeLines); // categorize by filters
      if (groupIndex >= 0) then
      begin
        // listViewItem.GroupID := groupIndex;
      end
      else
      begin
        groupIndex := g_defaultGroupIndex;
      end;
      // add counter to today times
      l_TodayFilters[groupIndex].value := l_TodayFilters[groupIndex].value + exeData.exeStringsWCounters[exeLines];

      // store list view item for future using
      // g_ListViewRoots.Add(listTextValue, listViewItem);
    end;
  end;
  exeList.Free;
end;

procedure LoadDictionaryDataToday();
var
  processDB: TStringList;
  processesDBs: TStringDynArray;
  I: Integer;
  exeData: TExeData;
begin
  // check input directory
  if (not TDirectory.Exists(g_todayPath)) then
    exit();

  // load all txt only files with processes stored data
  processesDBs := TDirectory.GetFiles(g_todayPath, '*.txt');

  // generate new list
  processDB := TStringList.Create;

  // for each loaded txt file
  for I := 0 to High(processesDBs) do
  begin
    processDB.LoadFromFile(processesDBs[I]); // load it txt into lines list
    exeData := TExeData.Create; // create new exe info instance
    // exeData.Init(processesDBs[0], processesDBs[1]);
    if (exeData.LoadFromFile(processDB, g_todayPath)) then // generate ico and load all data into
    begin // return true if list must be resaved
      processDB.SaveToFile(processesDBs[I]);
    end;
    g_Dictionary.Add(exeData.exename, exeData); // add into global storage
  end;
  processDB.Free; // clear list

end;

{
  procedure UpdateValueListEditor(ValueListEditor: TValueListEditor);
  var
  exeData: TExeData;
  listTextValue: string;
  exeLines: string;
  begin
  ValueListEditor.Strings.Clear;

  for exeData in dictionary.Values do
  begin
  for exeLines in exeData.exeStringsWCounters.Keys do
  begin
  listTextValue := exeData.exename + ' - ' + exeLines; // exeData.exeStringsWCounters[exe];
  ValueListEditor.InsertRow(listTextValue, MS2S(exeData.exeStringsWCounters[exeLines]), true);
  end;
  end;
  end; }

procedure UpdateListViewEditor(ListViewEditor: TListView; ListViewIcons: TImageList);
var
  exeData: TExeData;
  listTextValue: string;
  exeLines: string;
  listViewItem: TListItem;

  groupIndex: Integer;

  todayFilterIndex: Integer;
begin
  ListViewEditor.Clear;
  ListViewIcons.Clear;

  for exeData in g_Dictionary.Values do // foreach exe info
  begin
    for exeLines in exeData.exeStringsWCounters.Keys do // list all exe entries with all for names
    begin
      listTextValue := exeData.exename + ' - ' + exeLines; // full line

      listViewItem := ListViewEditor.Items.Add(); // add list view item
      exeData.l_IconIndex := ListViewIcons.AddIcon(exeData.Icon); // store icon ondex from icons list
      listViewItem.ImageIndex := exeData.l_IconIndex; // set list view item icon

      listViewItem.SubItems.Add(listTextValue); // add exename text
      listViewItem.SubItems.Add(MS2S(exeData.exeStringsWCounters[exeLines])); // add form text

      groupIndex := DataModule.IsMatchesWildcards(exeData.exename, exeLines); // categorize by filters
      if (groupIndex >= 0) then
      begin
        listViewItem.GroupID := groupIndex;
      end
      else
      begin
        listViewItem.GroupID := g_defaultGroupIndex;
      end;
      // add counter to today times
      g_TodayFilters[listViewItem.GroupID].value := g_TodayFilters[listViewItem.GroupID].value +
        exeData.exeStringsWCounters[exeLines];

      // store list view item for future using
      g_ListViewRoots.Add(listTextValue, listViewItem);
    end;
  end;

  // update today chart fully
  for todayFilterIndex in g_TodayFilters.Keys do
  begin
    MainForm.UpdateTodayValuesInChart(todayFilterIndex, g_TodayFilters[todayFilterIndex].value);
  end;

end;

// save all dictionary
procedure SaveDictionaryDataToday();
var
  exeData: TExeData;

begin
  if (not TDirectory.Exists(g_todayPath)) then
    exit();

  for exeData in g_Dictionary.Values do
  begin
    exeData.SaveToFile(g_todayPath);
  end;

end;

procedure LoadSettings(settings: TStringList);
begin
  if (settings.Count > 0) then
  begin
    MainForm.SpinEdit_UserAwayLimitInM.Text := settings[0];
    try
      MainForm.CheckBox_EnableAlwaysMarks.Checked := (settings[1] = '10');
    except
    end;
  end;
end;

procedure SaveSettings();
var
  settings: TStringList;
begin
  settings := TStringList.Create;
  settings.Add(MainForm.SpinEdit_UserAwayLimitInM.Text);
  if (MainForm.CheckBox_EnableAlwaysMarks.Checked) then
    settings.Add('10')
  else
    settings.Add('01');
  settings.SaveToFile(g_exePath + '\settings.txt');
  settings.Free;
end;

var
  g_ChangedDataItems: TList<TExeData>;

procedure TMainForm.Button_AddExternalDataClick(Sender: TObject);
var
  DBDirectories: TStringDynArray;

  dateLocation: string;

  processDB: TStringList;
  processesDBs: TStringDynArray;
  I, limI: Integer;
  exeData: TExeData;

  todayDateStr, DBEntryDateStr: string;
  isTodayFilter: boolean;

  index, limitIndex: Integer;

  LocalDBLocation, exeDBFileName, LocalDBEXEFileName: string;
begin
  // open folder dialog
  if (not FileOpenDialog1.Execute()) then
    exit();

  // folder name is ....
  if (ExtractFileName(FileOpenDialog1.FileName) <> 'DB') then
    exit();

  // load ex data
  DBDirectories := TDirectory.GetDirectories(FileOpenDialog1.FileName);

  // today date filter
  todayDateStr := ConvertDateToDayPath(now());

  for dateLocation in DBDirectories do // for all dates in db
  begin

    if (not TDirectory.Exists(dateLocation)) then
    begin
      continue;
    end;

    DBEntryDateStr := ExtractFileName(dateLocation);
    LocalDBLocation := ConvertDateStringToPathInDBLocation(DBEntryDateStr);

    isTodayFilter := CompareText(todayDateStr, DBEntryDateStr) = 0;

    // not today and not have this date in local db
    if ((not isTodayFilter) and (not TDirectory.Exists(LocalDBLocation))) then
    begin
      // copy full directory into local db
      // delete this location
      TDirectory.Copy(dateLocation, LocalDBLocation);
      TDirectory.Delete(dateLocation, true);
      // breaks other operations
      continue;
    end;

    // load all txt only files with processes stored data
    processesDBs := TDirectory.GetFiles(dateLocation, '*.txt');

    // generate new list
    processDB := TStringList.Create;

    // for each loaded txt file
    for I := 0 to High(processesDBs) do
    begin
      exeDBFileName := ExtractFileName(processesDBs[I]);

      // not today and not existed in target date
      LocalDBEXEFileName := LocalDBLocation + '\' + exeDBFileName;
      if ((not isTodayFilter) and (not TFile.Exists(LocalDBEXEFileName))) then
      begin
        // copy this file and icon file in target folder
        // delete this files
        TFile.Move(processesDBs[I], LocalDBEXEFileName);
        TFile.Move(processesDBs[I].Remove(processesDBs[I].Length - 4) + '.ico',
          LocalDBEXEFileName.Remove(LocalDBEXEFileName.Length - 4) + '.ico');

        //continue;
      end
      else
      begin

        processDB.LoadFromFile(processesDBs[I]); // load it txt into lines list

        // if it today -> add into today data
        if (isTodayFilter) then
        begin
          index := 1;
          limitIndex := ((processDB.Count - 1) div 2) - 1;
          for limI := 0 to limitIndex do
          begin
            // simulate each process
            SimulateActiveProcess(processDB[index], // form header
              processesDBs[I].Remove((processesDBs[I].Length - 4)), // remove .txt for exe location
              strtoint(processDB[index + 1]), // counter
              processDB[0]); // exe name
            index := index + 2;
          end;

        end
        else
        begin
          processDB.Delete(0);
          TFile.AppendAllText(LocalDBEXEFileName, processDB.Text);
          // TFile.Delete(processesDBs[i]);
        end;
      end;
    end;
    processDB.Free; // clear list

    TDirectory.Delete(dateLocation, true); //delete data folder

  end;

  // if it last days / add or copy last days data into local storage
  // delete ex data
end;

procedure TMainForm.Button_RestartThisApplicationClick(Sender: TObject);
begin
  // SaveSettings;
  // ShellAPI
  ShellExecute(Handle, nil, PChar(Application.exename), nil, nil, SW_SHOWNOACTIVATE);
  MainForm.Close;
  // Application.Terminate; // or, if this is the main form, simply Close;
end;

var
  l_monthDataLoaded: boolean = false;

procedure TMainForm.Button2Click(Sender: TObject);
var
  startDate: TDateTime;
  category: TTodayFilter;
  lineSeries: TLineSeries;
  color: TColor;
  I: Integer;
  dateLocation: string;

  l_TodayFilters: TDictionary<Integer, TTodayFilter>;
  l_tmpFilter: TTodayFilter;

  FilterKeyIndex: Integer;
  filterKeyCounter: Integer;
  markIndex: Integer;

  isHaveSummary: boolean;

  sMarks: TMarksItem;
begin

  Chart_4WeeksData.SeriesList.Clear;
  l_TodayFilters := TDictionary<Integer, TTodayFilter>.Create(); // clone of global filters for loading data from HDD

  for FilterKeyIndex in g_TodayFilters.Keys do
  begin
    category := g_TodayFilters[FilterKeyIndex];

    color := GetCategoryColor(category.name);

    // rocedure TMainForm.AddBarChart_IntoTodayChart(categoryName : string; wildcardsBaseDir: string; I: Integer);

    lineSeries := TLineSeries.Create(Chart_4WeeksData);

    if (category.monthlyChartAlwaysVisibleMarks) then
    begin
      lineSeries.Tag := 10;
    end
    else
    begin
      lineSeries.Tag := 0;
    end;

    lineSeries.ParentChart := Chart_4WeeksData;
    lineSeries.LegendTitle := category.name;
    lineSeries.LinePen.Width := 1;
    lineSeries.Marks.Visible := true; // := TSeriesMarks.

    // color := ReadColorFromFile(wildcardsBaseDir, barSeries.Color);
    lineSeries.color := color;

    lineSeries.Clear;
    // lineSeries.AddXY(startDate, 0, '');

    l_tmpFilter := TTodayFilter.Create();
    l_tmpFilter.name := category.name;
    l_tmpFilter.value := 0;
    l_tmpFilter.monthlyChartAlwaysVisibleMarks := category.monthlyChartAlwaysVisibleMarks;
    l_TodayFilters.Add(FilterKeyIndex, l_tmpFilter);

  end;

  isHaveSummary := false;
  for I := 30 downto 0 do
  begin

    startDate := IncDay(now(), -I);
    dateLocation := ConvertDateToDayPathInDBLocation(startDate);

    if (TDirectory.Exists(dateLocation)) then
    begin
      LoadDictionaryDayDataInto(dateLocation, l_TodayFilters);
    end
    else
    begin
      for l_tmpFilter in l_TodayFilters.Values do
      begin
        l_tmpFilter.value := 0;
      end;
    end;

    // calculate summary value
    for FilterKeyIndex in l_TodayFilters.Keys do
    begin
      if (FilterKeyIndex <> g_SummaryFiltersIndex) then
      begin
        l_TodayFilters[g_SummaryFiltersIndex].value := l_TodayFilters[g_SummaryFiltersIndex].value +
          l_TodayFilters[FilterKeyIndex].value;
      end;
    end;

    isHaveSummary := isHaveSummary or (l_TodayFilters[g_SummaryFiltersIndex].value > 0);
    if ((I = 0) and (isHaveSummary)) then
    begin
      l_monthDataLoaded := true;
    end;

    // update chart
    filterKeyCounter := 0;
    if (isHaveSummary) then
    begin
      for FilterKeyIndex in l_TodayFilters.Keys do
      begin
        markIndex := Chart_4WeeksData.Series[filterKeyCounter].AddXY(-I, l_TodayFilters[FilterKeyIndex].value,
          FormatDateTime('DD/MM/YYYY', startDate));

        sMarks := Chart_4WeeksData.Series[filterKeyCounter].Marks[markIndex];

        sMarks.Text.Text := MS2S(l_TodayFilters[FilterKeyIndex].value);
        sMarks.Visible := l_TodayFilters[FilterKeyIndex].monthlyChartAlwaysVisibleMarks;
        sMarks.color := Chart_4WeeksData.Series[filterKeyCounter].color;

        inc(filterKeyCounter);
      end;
    end;
  end;

  l_TodayFilters.Free();
end;

procedure TMainForm.UpdateTodaySummaryValuesInMonthsChart(SummaryFiltersIndex: Integer);
var
  summaryValue, value: cardinal;
  index: Integer;

  Count: Integer;

  FilterKeyIndex: Integer;
begin
  if (not l_monthDataLoaded) then
    exit;

  summaryValue := 0;
  for index in g_TodayFilters.Keys do
  begin
    if (index <> SummaryFiltersIndex) then
    begin
      summaryValue := summaryValue + g_TodayFilters[index].value;
    end;
  end;

  index := 0;
  for FilterKeyIndex in g_TodayFilters.Keys do
  begin
    if (FilterKeyIndex = SummaryFiltersIndex) then
    begin
      value := summaryValue;
    end
    else
    begin
      value := g_TodayFilters[FilterKeyIndex].value;
    end;

    Count := Chart_4WeeksData.Series[index].YValues.Count - 1;
    Chart_4WeeksData.Series[index].YValue[Count] := value;
    Chart_4WeeksData.Series[index].Marks[Count].Text.Text := MS2S(value);

    inc(index);
  end;

  // count := Chart_4WeeksData.Series[SummaryFiltersIndex].YValues.Count-1;
  // Chart_4WeeksData.Series[SummaryFiltersIndex].YValue[count] := value;
  // Chart_4WeeksData.Series[SummaryFiltersIndex].Marks[Count].Text.Text := MS2S(value);
end;


// var g_AlwaysVisibleMarksSeries : integer;

procedure TMainForm.Chart_4WeeksDataMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  // Pt: TPoint;
  seriesI, marksI: Integer;
  P: TChartClickedPart;
  isSelectedSeries: boolean;
begin

  Chart_4WeeksData.CalcClickedPart(Point(X, Y), P);

  if (P.ASeries <> nil) then
  begin
    for seriesI := 0 to Chart_4WeeksData.SeriesList.Count - 1 do
    begin

      isSelectedSeries := (P.ASeries = Chart_4WeeksData.Series[seriesI]);

      if (isSelectedSeries) then
      begin
        Chart_4WeeksData.Series[seriesI].Pen.Width := 3;
      end
      else
      begin
        Chart_4WeeksData.Series[seriesI].Pen.Width := 1;
      end;

      for marksI := 0 to Chart_4WeeksData.SeriesList[seriesI].Marks.Items.Count - 1 do
      begin
        // Chart_4WeeksData.Series[seriesI].Marks[marksI].color := Chart_4WeeksData.Series[seriesI].color;
        Chart_4WeeksData.Series[seriesI].Marks[marksI].Visible := isSelectedSeries or
          (CheckBox_EnableAlwaysMarks.Checked and (Chart_4WeeksData.Series[seriesI].Tag = 10));
      end;

    end;
  end;

end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Timer_AutoSaveTimer(nil);
  SaveSettings;
end;

procedure TMainForm.UpdateTodayValuesInChart(index: Integer; value: cardinal);
begin
  g_TodayFilters[index].value := value;
  Chart_Today.Series[index].YValue[0] := value;

  Chart_Today.Series[index].Labels[0] := g_TodayFilters[index].name + sLineBreak + MS2S(value);
end;

procedure TMainForm.UpdateTodaySummaryValuesInChart(SummaryFiltersIndex: Integer);
var
  value: cardinal;
  index: Integer;
begin
  value := 0;
  for index in g_TodayFilters.Keys do
  begin
    if (index <> SummaryFiltersIndex) then
    begin
      value := value + g_TodayFilters[index].value;
    end;
  end;

  // g_TodayFilters[index] := value;
  Chart_Today.Series[SummaryFiltersIndex].YValue[0] := value;
  Chart_Today.Series[SummaryFiltersIndex].Labels[0] := g_TodayFilters[SummaryFiltersIndex].name + sLineBreak +
    MS2S(value);
end;

function ReadColorFromFile(FileName: string; baseColor: TColor): TColor;
var
  colorFileData: string;
  colorData: TArray<string>;
begin
  if (TFile.Exists(FileName)) then
  begin
    colorFileData := TFile.ReadAllText(FileName);
    colorData := colorFileData.Split(['.']);
    try
      result := RGB(strtoint(colorData[0]), strtoint(colorData[1]), strtoint(colorData[2]));
    except
      result := baseColor;
    end;
  end
  else
  begin
    result := baseColor;
  end;
end;

procedure TMainForm.AddBarChart_IntoTodayChart(categoryName: string; wildcardsBaseDir: string; I: Integer);
var
  barSeries: TBarSeries;
  color: TColor;
begin
  barSeries := TBarSeries.Create(Chart_Today);
  barSeries.ParentChart := Chart_Today;
  barSeries.MultiBar := mbSelfStack;
  color := ReadColorFromFile(wildcardsBaseDir, barSeries.color);
  barSeries.color := color;
  if (categoryName <> '') then
  begin
    g_AddFilterForm_CategoryColorData.Add(categoryName, color);
  end;
  Chart_Today.Series[I].Clear;
  Chart_Today.Series[I].AddXY(0, 0, '');
end;

procedure TMainForm.SimulateActiveProcess(textStr: string; path: string; counter: cardinal; exename: string);
var
  groupIndex: Integer;
  valPreExit: cardinal;
  listViewItem: TListItem;
  listTextValue: string;
  exeDataItem: TExeData;
begin
  exename := exename.ToLower;
  // counter := 1;
  listTextValue := exename + ' - ' + textStr;
  if (g_Dictionary.ContainsKey(exename)) then
  begin
    exeDataItem := g_Dictionary[exename];
  end
  else
  // если такой ключ уже есть, то иконку извлекать не надо
  // не такого ключа
  begin
    exeDataItem := TExeData.Create;
    // извлекаем иконку и сохраняем куда следует
    exeDataItem.Init(exename, path);
    g_Dictionary.Add(exename, exeDataItem);
  end;

  valPreExit := exeDataItem.GetCounter(textStr);
  // valToExit := counter;
  counter := exeDataItem.AddCounter(textStr, counter);
  // valToExit := counter - valToExit; //difference
  if (not g_ChangedDataItems.Contains(exeDataItem)) then
  begin
    g_ChangedDataItems.Add(exeDataItem);
  end;
  if (g_ListViewRoots.ContainsKey(listTextValue)) then
  begin
    listViewItem := g_ListViewRoots[listTextValue];
    listViewItem.SubItems[1] := MS2S(counter);
  end
  else
  begin
    listViewItem := ListView1.Items.Add;
    // add list view item
    exeDataItem.l_IconIndex := g_DataModule.ListViewIcons.AddIcon(exeDataItem.Icon);
    // store icon ondex from icons list
    listViewItem.ImageIndex := exeDataItem.l_IconIndex;
    // set list view item icon
    // listViewItem.SubItems.Add('');
    listViewItem.SubItems.Add(listTextValue);
    listViewItem.SubItems.Add(MS2S(counter));
    groupIndex := IsMatchesWildcards(exename, textStr);
    if (groupIndex >= 0) then
    begin
      listViewItem.GroupID := groupIndex;
    end
    else
    begin
      listViewItem.GroupID := g_defaultGroupIndex;
    end;
    g_ListViewRoots.Add(listTextValue, listViewItem);
  end;
  if ((ListView1.Selected <> nil) and (Length(ListView1.Selected.SubItems[0]) > 4)) then
  begin
    Edit_SelectedProcessName.Visible := true;
    exename := ListView1.Selected.SubItems[0].Substring(0, ListView1.Selected.SubItems[0].IndexOf('-') - 1);
    Edit_SelectedProcessName.Text := exename;
    Edit_ActiveProcessCounter.Text := MS2S(g_Dictionary[exename].GetCounter);
  end
  else
  begin
    Edit_SelectedProcessName.Visible := false;
    Edit_ActiveProcessCounter.Text := MS2S(g_Dictionary[exename].GetCounter);
  end;
  UpdateTodayValuesInChart(listViewItem.GroupID, g_TodayFilters[listViewItem.GroupID].value - valPreExit + counter);
  UpdateTodaySummaryValuesInChart(g_SummaryFiltersIndex);
  UpdateTodaySummaryValuesInMonthsChart(g_SummaryFiltersIndex);
end;

var
  curDayDate: TDate;

procedure TMainForm.FormCreate(Sender: TObject);
var
  wildcardsFiles: TStringDynArray;
  wildcardsCategories: TStringDynArray;

  I: Integer;
  fI: Integer;
  wildcardData: wildcardMask;
  linesOfWildcard: TStringList;
  settings: TStringList;

  tmpStr: string;

  listGroup: TListGroup;

  filter: TTodayFilter;
begin

  PageControl1.ActivePageIndex := 0;

  curDayDate := Date();

  g_ChangedDataItems := TList<TExeData>.Create;
  // if (ListViewRoots <> nil) then ListViewRoots.Free;
  g_ListViewRoots := TDictionary<string, TListItem>.Create;

  g_Dictionary := TDictionary<string, TExeData>.Create(TIStringComparer.Ordinal);

  g_TodayFilters := TDictionary<Integer, TTodayFilter>.Create();
  g_textChars_hash := System.SysUtils.StrAlloc(1024);

  g_exePath := ExtractFileDir(ParamStr(0));

  g_dbPath := g_exePath + '\DB';
  ForceDirectories(g_dbPath);

  g_todayPath := ConvertDateToDayPathInDBLocation(now());
  ForceDirectories(g_todayPath);

  // if (wildcards <> nil) then wildcards.Free;

  Chart_Today.SeriesList.Clear;
  Chart_Today.Legend.Visible := false;

  g_Wildcards := TList < TList < wildcardMask >>.Create();
  wildcardsCategories := TDirectory.GetDirectories(g_exePath + '\WCards', '*-*');
  TArray.Sort<string>(wildcardsCategories);
  ListView1.Groups.Clear;

  linesOfWildcard := TStringList.Create;
  g_defaultGroupIndex := -1;
  for I := 0 to High(wildcardsCategories) do // добавляем лист группы под индексам
  begin
    g_Wildcards.Add(TList<wildcardMask>.Create);

    listGroup := ListView1.Groups.Add();

    tmpStr := wildcardsCategories[I];
    tmpStr := tmpStr.Substring(tmpStr.IndexOf('-') + 1);
    listGroup.Header := tmpStr;
    listGroup.State := [lgsNormal, lgsCollapsible];

    filter := TTodayFilter.Create();
    filter.value := 0;
    filter.name := tmpStr;
    filter.fullName := wildcardsCategories[I];
    filter.monthlyChartAlwaysVisibleMarks := TFile.Exists(wildcardsCategories[I] + '\EnableMonthlyMarks');

    g_TodayFilters.Add(I, filter);

    AddBarChart_IntoTodayChart(tmpStr, wildcardsCategories[I] + '\Color', I);

    // для каждого индекса загружаем макси
    wildcardsFiles := TDirectory.GetFiles(wildcardsCategories[I], '*.txt');

    if ((g_defaultGroupIndex = -1) and (TFile.Exists(wildcardsCategories[I] + '\Default'))) then
    begin
      g_defaultGroupIndex := I;
    end;

    for fI := 0 to High(wildcardsFiles) do
    begin
      wildcardData := wildcardMask.Create();
      linesOfWildcard.LoadFromFile(wildcardsFiles[fI]);
      linesOfWildcard.Text := linesOfWildcard.Text.Replace('?', '', [rfReplaceAll]);
      wildcardData.LoadData(ExtractFileName(wildcardsFiles[fI]).Replace('.txt', ''), linesOfWildcard);
      g_Wildcards[I].Add(wildcardData);
    end;

  end;
  g_SummaryFiltersIndex := I;

  filter := TTodayFilter.Create();
  filter.value := 0;
  filter.name := g_AddFilterForm_CategorySummaryName;
  filter.fullName := '';

  g_TodayFilters.Add(I, filter);

  // g_TodayFilters.Add(I,0);
  // g_TodayFiltersNames.Add(I, );
  AddBarChart_IntoTodayChart(g_AddFilterForm_CategorySummaryName, '', I);

  linesOfWildcard.Free;

  if (TFile.Exists(g_exePath + '\settings.txt')) then
  begin
    settings := TStringList.Create;
    settings.LoadFromFile(g_exePath + '\settings.txt');

    LoadSettings(settings);
    settings.Free;
  end;

  { barSeries := TBarSeries.Create(Chart_Today);
    barSeries.ParentChart := Chart_Today;
    barSeries.LegendTitle := 'positive';

    Chart_Today.Series[0].Add(64.0, 'positive'+sLineBreak+'12:45:55');
    Chart_Today.Series[0].YValue[0] := 32.0;
    Chart_Today.Series[0].Labels[0] :=  'positive'+sLineBreak+'12:44:44'; }
  // Chart_Today.Series[0].

  LoadDictionaryDataToday();
  // UpdateValueListEditor(ValueListEditor1);
  UpdateListViewEditor(ListView1, g_DataModule.ListViewIcons);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  g_Dictionary.Free;
  System.SysUtils.StrDispose(g_textChars_hash);
end;

var
  Descending: boolean;
  SortedColumn: Integer = 2;

procedure TMainForm.ListView1ColumnClick(Sender: TObject; Column: TListColumn);
begin
  TListView(Sender).SortType := stNone;
  if Column.index <> SortedColumn then
  begin
    SortedColumn := Column.index;
    Descending := false;
  end
  else
    Descending := not Descending;
  TListView(Sender).SortType := stText;
end;

procedure TMainForm.ListView1Compare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
begin
  begin
    if SortedColumn = 0 then
      Compare := CompareText(Item1.Caption, Item2.Caption)
    else if SortedColumn <> 0 then
      Compare := CompareText(Item1.SubItems[SortedColumn - 1], Item2.SubItems[SortedColumn - 1]);
    if Descending then
      Compare := -Compare;
  end;
end;

procedure TMainForm.ListView1DblClick(Sender: TObject);
var
  clp: TClipboard;
  Data: string;
begin
  clp := TClipboard.Create;
  Data := '';
  try
    Data := ListView1.Selected.SubItems[0];
    clp.AsText := Data
  except
  end;
  clp.Free;

  if (Data <> '') then
  begin
    addfilterform.LoadProcessesList(g_Dictionary);
    addfilterform.LoadString(Data);
    addfilterform.Show;
  end;

end;

procedure TMainForm.SaveButtonClick(Sender: TObject);
begin
  SaveSettings();
  SaveDictionaryDataToday();
end;

var
  g_cursorSmalMovement_Limit_InSecs: Integer = 60;

var
  g_lastCursorPos: TPoint;
  g_cursorSmalMovement_CurrentValue_InSec: Integer = 0;

procedure TMainForm.SpinEdit_UserAwayLimitInMChange(Sender: TObject);
begin
  try
    g_cursorSmalMovement_Limit_InSecs := 60 * strtoint(SpinEdit_UserAwayLimitInM.Text);
  except
  end;
end;

procedure TMainForm.TabSheet1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ListView1.Selected := nil;
end;

procedure TMainForm.Timer_AutoSaveTimer(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to (g_ChangedDataItems.Count - 1) do
  begin
    g_ChangedDataItems[I].SaveToFile(g_todayPath);
  end;
  g_ChangedDataItems.Clear;
end;

procedure TMainForm.UserActivityTimerTimer(Sender: TObject);
var
  curCursorPos: TPoint;
begin
  GetCursorPos(curCursorPos);

  // не ушли дальше чем на +-10 от предыдущей точки -> считаем что человека нет
  if (g_lastCursorPos.X - 10 <= curCursorPos.X) and (g_lastCursorPos.X + 10 >= curCursorPos.X) and
    (g_lastCursorPos.Y - 10 <= curCursorPos.Y) and (g_lastCursorPos.Y + 10 >= curCursorPos.Y) then
  begin
    g_cursorSmalMovement_CurrentValue_InSec := g_cursorSmalMovement_CurrentValue_InSec + 1;
  end
  else
  begin
    g_cursorSmalMovement_CurrentValue_InSec := 0;
  end;

  // сохраняем новую позицию
  g_lastCursorPos := curCursorPos;

  Edit_Away.Text := inttostr(g_cursorSmalMovement_CurrentValue_InSec);

end;

function GetHWNDProcessPath(foregroudWindow: HWND): String;
var
  pid: DWORD;
  hProcess: THandle;
  path: array [0 .. 4095] of WideChar;
begin
  GetWindowThreadProcessId(foregroudWindow, pid);

  hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, false, pid);
  if hProcess <> 0 then
    try
      if GetModuleFileNameEx(hProcess, 0, @path[0], Length(path) * 2) = 0 then
        RaiseLastOSError;

      result := path;
    finally
      CloseHandle(hProcess);
    end
  else
    RaiseLastOSError;
end;

var
  gettickcount_value: cardinal = 0;

function TickDiff(StartTick: cardinal; EndTick: cardinal): cardinal;
begin
  if EndTick >= StartTick then
    result := EndTick - StartTick
  else
    result := High(NativeUInt) - StartTick + EndTick;
end;

procedure TMainForm.OneSecTimerTimer(Sender: TObject);

var
  foregroudWindow: HWND;
  // I: Integer;

  textLen: Integer;

  textStr: string;
  path: string;

  FileName: string;

  counter: cardinal;
  // Row: Integer;

  gettickcount_cur_value: cardinal;

  curDate: TDate;
begin

  curDate := Date();
  if (curDayDate <> Date) then
  begin
    Button_RestartThisApplicationClick(nil);
    exit;
  end;

  foregroudWindow := GetForegroundWindow();

  if (foregroudWindow = 0) then
    exit;

  gettickcount_cur_value := GetTickCount(); // получаем миллисекунды со старта системы
  if (gettickcount_value = 0) then // если изначально было 0, то первый запуск
  begin
    counter := OneSecTimer.Interval; // берем значение таймера
  end
  else
  begin
    counter := TickDiff(gettickcount_value, gettickcount_cur_value);
    // считаем реальный промежуток времени c учетом возможного врапа
  end;
  gettickcount_value := gettickcount_cur_value; // сохраняем старые данные

  if (counter > 5000) then
    counter := 5000;

  if (g_cursorSmalMovement_CurrentValue_InSec > g_cursorSmalMovement_Limit_InSecs) then
    exit; // после рассчета времени, т.к. иначе след вызов вернет полный промежуток

  try
    path := GetHWNDProcessPath(foregroudWindow);
  except
    exit(); // ignore rights av and vipe counting for 1 sec
  end;

  // edit1.Text := path;
  FileName := ExtractFileName(path);
  Edit_ActiveProcessName.Text := FileName;

  textLen := GetWindowText(foregroudWindow, g_textChars_hash, 1024);
  textStr := string(ansistring(g_textChars_hash)).Replace('?', '', [rfReplaceAll]);
  Edit_ActiveProcessFormName.Text := textStr;

  SimulateActiveProcess(textStr, path, counter, FileName);

end;

end.
