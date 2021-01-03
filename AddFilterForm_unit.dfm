object AddFilterForm: TAddFilterForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = 'AddFilterForm'
  ClientHeight = 204
  ClientWidth = 970
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 327
    Top = 80
    Width = 13
    Height = 25
    Caption = '*'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 943
    Top = 80
    Width = 13
    Height = 25
    Caption = '*'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 176
    Top = 61
    Width = 47
    Height = 13
    Caption = 'Exe name'
  end
  object Label4: TLabel
    Left = 16
    Top = 61
    Width = 45
    Height = 13
    Caption = 'Category'
  end
  object LabeledEdit_InputString: TLabeledEdit
    Left = 16
    Top = 24
    Width = 945
    Height = 21
    EditLabel.Width = 115
    EditLabel.Height = 13
    EditLabel.Caption = 'LabeledEdit_InputString'
    TabOrder = 0
  end
  object LabeledEdit_MaskedFilter: TLabeledEdit
    Left = 346
    Top = 80
    Width = 591
    Height = 21
    EditLabel.Width = 121
    EditLabel.Height = 13
    EditLabel.Caption = 'LabeledEdit_MaskedFilter'
    TabOrder = 1
    OnChange = LabeledEdit_MaskedFilterChange
  end
  object ComboBoxEx_ExeName: TComboBoxEx
    Left = 176
    Top = 80
    Width = 145
    Height = 22
    AutoCompleteOptions = [acoAutoSuggest, acoAutoAppend, acoUseTab, acoUpDownKeyDropsList]
    ItemsEx = <
      item
        ImageIndex = 1
        SelectedImageIndex = 1
      end>
    TabOrder = 2
    Images = g_DataModule.ListViewIcons
  end
  object Button_SaveFilter: TButton
    Left = 824
    Top = 144
    Width = 132
    Height = 49
    Caption = 'Button_SaveFilter'
    TabOrder = 3
    OnClick = Button_SaveFilterClick
  end
  object ComboBox_CategoryList: TComboBox
    Left = 16
    Top = 80
    Width = 145
    Height = 22
    Style = csOwnerDrawFixed
    TabOrder = 4
    OnChange = ComboBox_CategoryListChange
    OnDrawItem = ComboBox_CategoryListDrawItem
    Items.Strings = (
      'a'
      'b'
      'c'
      'd'
      'e'
      'f')
  end
end
