unit AddFilterForm_unit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.CategoryButtons, Vcl.ComCtrls, System.Generics.Collections, DataModule,
  Vcl.Buttons;

type
  TAddFilterForm = class(TForm)
    LabeledEdit_InputString: TLabeledEdit;
    LabeledEdit_MaskedFilter: TLabeledEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ComboBoxEx_ExeName: TComboBoxEx;
    Label4: TLabel;
    Button_SaveFilter: TButton;
    ComboBox_CategoryList: TComboBox;
    procedure ComboBox_CategoryListDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure FormShow(Sender: TObject);
    procedure LabeledEdit_MaskedFilterChange(Sender: TObject);
    procedure Button_SaveFilterClick(Sender: TObject);
    procedure ComboBox_CategoryListChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadString(data: string);
    procedure LoadProcessesList(dictionary: TDictionary<string, TExeData>);
  end;

var
  AddFilterForm: TAddFilterForm;

implementation

uses
  System.IOUtils;

{$R *.dfm}

procedure ComboColor(C: TWinControl; I: Integer; R: TRect; FColor: TColor);
begin
  with (C as TComboBox) do
  begin
    Canvas.Brush.color := GetCategoryColor(Items[I]);
    Canvas.FillRect(R);
    Canvas.Font.color := FColor;
    Canvas.TextOut(R.Left, R.Top, Items[I]);
  end;
end;

procedure TAddFilterForm.Button_SaveFilterClick(Sender: TObject);
var filterEXEWithCategoryFullName : string;
    categoryFullName : string;
    filterString : string;
    filter : TTodayFilter;
    exeFilterData:TStringList;
  I: Integer;
  matchedIndex : integer;
begin
    if (ComboBox_CategoryList.ItemIndex >= 0) then
    begin
       //находим полное им€ категории
       for filter in g_TodayFilters.Values do
       begin
          if (filter.name = ComboBox_CategoryList.Text) then
          begin
             categoryFullName := filter.fullName;
          end;
       end;

       //ищем там файл с данными
       filterEXEWithCategoryFullName := categoryFullName + '\' + string(ComboBoxEx_ExeName.Text).Replace('.exe', '.txt', [rfIgnoreCase]);
       exeFilterData :=TStringList.Create();
       if (TFile.Exists(filterEXEWithCategoryFullName)) then
       begin
          exeFilterData.LoadFromFile(filterEXEWithCategoryFullName);
       end
       else
       begin
          // do nothing
       end;

       //добавл€ем в этот файл или создаем новый файл
       //добавл€ем в фильтры данные
       matchedIndex := -1;
       filterString := LabeledEdit_MaskedFilter.Text;
       for I := 0 to exeFilterData.Count-1 do
       begin
          if (CompareText(exeFilterData[i], filterString)=0) then   //нашли такой фильтр внутри
          begin
             matchedIndex := I;
             break;
          end;
       end;

       //add if not existed inside
       if (matchedIndex = -1) then
       begin
          exeFilterData.Add(filterString);
       end;

       //save data inside file
       exeFilterData.SaveToFile(filterEXEWithCategoryFullName);

       //переносим данные о процессе из одной категории в другую
       //обновл€ем все данные сегодн€шних категорий
    end;

    self.Close;
end;

procedure TAddFilterForm.ComboBox_CategoryListChange(Sender: TObject);
begin
   Button_SaveFilter.Enabled := (ComboBox_CategoryList.Text <> '') and (ComboBoxEx_ExeName.Text <> ''); //фильтр может быть пустой строкой, поэтому мы его просто пропускаем
end;

procedure TAddFilterForm.ComboBox_CategoryListDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
  State: TOwnerDrawState);
begin
  ComboColor(Control, Index, Rect, clWindow);
end;

procedure TAddFilterForm.FormShow(Sender: TObject);
var
  categoryName: string;
begin
  ComboBox_CategoryList.Clear;
  for categoryName in g_AddFilterForm_CategoryColorData.Keys do
  begin
    if (categoryName <> g_AddFilterForm_CategorySummaryName) then
    begin
      ComboBox_CategoryList.Items.Add(categoryName);
    end;
  end;
end;

procedure TAddFilterForm.LabeledEdit_MaskedFilterChange(Sender: TObject);
var
  groupIndex: Integer;
begin
  //in filters already
  groupIndex := DataModule.IsMatchesWildcards(ComboBoxEx_ExeName.Text, LabeledEdit_MaskedFilter.Text);

  // categorize by filters
  if (groupIndex >= 0) then
  begin
    Button_SaveFilter.Enabled := false;
    ComboBox_CategoryList.ItemIndex := ComboBox_CategoryList.Items.IndexOf(g_TodayFilters[groupIndex].name);
  end
  else
  begin
     Button_SaveFilter.Enabled := true;
  end;

end;

procedure TAddFilterForm.LoadProcessesList(dictionary: TDictionary<string, TExeData>);
var
  key: string;
  cbExItem: TComboExItem;
begin

  ComboBoxEx_ExeName.Clear;
  for key in dictionary.Keys do
  begin

    cbExItem := ComboBoxEx_ExeName.ItemsEx.Add();
    cbExItem.Caption := key;
    cbExItem.ImageIndex := dictionary[key].l_IconIndex;
  end;
end;

procedure TAddFilterForm.LoadString(data: string);
var
  exeName: string;
  exeFilter: string;
  splittedData: TArray<String>;
begin
  splittedData := data.Split(['-'], 1);

  exeFilter := trim(data.Substring(Length(splittedData[0]) + 1));
  exeName := trim(splittedData[0]);

  LabeledEdit_InputString.Text := data;
  LabeledEdit_MaskedFilter.Text := exeFilter;

  ComboBoxEx_ExeName.Text := exeName;
  ComboBoxEx_ExeName.ItemIndex := ComboBoxEx_ExeName.Items.IndexOf(exeName);

end;

end.
