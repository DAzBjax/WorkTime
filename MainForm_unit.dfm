object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MainForm'
  ClientHeight = 586
  ClientWidth = 1101
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 1101
    Height = 586
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'Day'
      DesignSize = (
        1093
        558)
      object SaveButton: TButton
        Left = 992
        Top = 494
        Width = 75
        Height = 25
        Caption = 'SaveButton'
        TabOrder = 0
        Visible = False
        OnClick = SaveButtonClick
      end
      object ValueListEditor1: TValueListEditor
        Left = 8
        Top = 8
        Width = 841
        Height = 473
        KeyOptions = [keyEdit]
        TabOrder = 1
        Visible = False
        ColWidths = (
          582
          253)
      end
      object GroupBox1: TGroupBox
        Left = 960
        Top = 8
        Width = 129
        Height = 121
        Anchors = [akTop, akRight]
        Caption = 'User away settings'
        TabOrder = 2
        object Label1: TLabel
          Left = 14
          Top = 25
          Width = 91
          Height = 13
          Caption = 'User away limit (m)'
        end
        object SpinEdit_UserAwayLimitInM: TSpinEdit
          Left = 16
          Top = 44
          Width = 97
          Height = 22
          MaxValue = 60
          MinValue = 0
          TabOrder = 0
          Value = 5
          OnChange = SpinEdit_UserAwayLimitInMChange
        end
        object Edit_Away: TLabeledEdit
          Left = 16
          Top = 92
          Width = 97
          Height = 21
          EditLabel.Width = 106
          EditLabel.Height = 13
          EditLabel.Caption = 'Current user away (s)'
          Enabled = False
          TabOrder = 1
        end
      end
      object ListView1: TListView
        Left = 8
        Top = 8
        Width = 841
        Height = 473
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            MaxWidth = 35
            MinWidth = 35
            Width = 35
          end
          item
            Caption = 'Data'
            MinWidth = 600
            Width = 600
          end
          item
            Caption = 'Value'
            MaxWidth = 150
            MinWidth = 150
            Width = 150
          end>
        DoubleBuffered = True
        FullDrag = True
        GridLines = True
        GroupView = True
        ReadOnly = True
        RowSelect = True
        ParentDoubleBuffered = False
        SmallImages = g_DataModule.ListViewIcons
        SortType = stText
        TabOrder = 3
        ViewStyle = vsReport
        OnColumnClick = ListView1ColumnClick
        OnCompare = ListView1Compare
        OnDblClick = ListView1DblClick
      end
      object Edit_ActiveProcessName: TEdit
        Left = 8
        Top = 496
        Width = 609
        Height = 21
        Anchors = [akLeft, akRight, akBottom]
        TabOrder = 4
        Text = 'Edit_ActiveProcessName'
      end
      object Edit_ActiveProcessFormName: TEdit
        Left = 8
        Top = 523
        Width = 609
        Height = 21
        Anchors = [akLeft, akRight, akBottom]
        TabOrder = 5
        Text = 'Edit_ActiveProcessFormName'
      end
      object Chart_Today: TChart
        Left = 855
        Top = 159
        Width = 234
        Height = 346
        Legend.Visible = False
        Title.Text.Strings = (
          'TChart')
        Title.Visible = False
        BottomAxis.Visible = False
        LeftAxis.Visible = False
        View3D = False
        Zoom.Allow = False
        TabOrder = 6
        Anchors = [akTop, akRight, akBottom]
        PrintMargins = (
          33
          15
          33
          15)
        ColorPaletteIndex = 13
        object Series2: TBarSeries
          Marks.Arrow.Visible = False
          Marks.Callout.Brush.Color = clBlack
          Marks.Callout.Arrow.Visible = False
          Marks.ShapeStyle = fosRoundRectangle
          Marks.Visible = True
          SeriesColor = 107822
          Emboss.Color = 8947848
          MultiBar = mbSelfStack
          Shadow.Color = 8947848
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Bar'
          YValues.Order = loNone
          Data = {000100000033333333338C7040}
        end
        object Series3: TBarSeries
          Marks.Arrow.Visible = False
          Marks.Callout.Brush.Color = clBlack
          Marks.Callout.Arrow.Visible = False
          Marks.ShapeStyle = fosRoundRectangle
          Marks.Visible = True
          Emboss.Color = 8947848
          MultiBar = mbSelfStack
          Shadow.Color = 8947848
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Bar'
          YValues.Order = loNone
          Data = {00010000000000000000207640}
        end
        object Series1: TBarSeries
          Marks.Arrow.Visible = False
          Marks.Callout.Brush.Color = clBlack
          Marks.Callout.Arrow.Visible = False
          Marks.Emboss.Color = 8487297
          Marks.Shadow.Color = 8487297
          Marks.ShapeStyle = fosRoundRectangle
          Marks.Visible = True
          Emboss.Color = 8882055
          MultiBar = mbSelfStack
          Shadow.Color = 8882055
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Bar'
          YValues.Order = loNone
          Data = {00010000000000000000006240}
        end
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Month'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 682
      object Chart_4WeeksData: TChart
        Left = 0
        Top = 0
        Width = 1093
        Height = 558
        BackImage.Inside = True
        Legend.CustomPosition = True
        Legend.FontSeriesColor = True
        Legend.Left = 0
        Legend.PositionUnits = muPercent
        Legend.ResizeChart = False
        Legend.Shadow.Visible = False
        Legend.Top = 0
        Legend.VertSpacing = 6
        Title.Text.Strings = (
          'TChart')
        Title.Visible = False
        AxisBehind = False
        BottomAxis.LabelsAngle = 90
        DepthAxis.Automatic = False
        DepthAxis.AutomaticMaximum = False
        DepthAxis.AutomaticMinimum = False
        DepthAxis.Maximum = 0.500000000000000000
        DepthAxis.Minimum = -0.500000000000000000
        DepthTopAxis.Automatic = False
        DepthTopAxis.AutomaticMaximum = False
        DepthTopAxis.AutomaticMinimum = False
        DepthTopAxis.Maximum = 0.500000000000000000
        DepthTopAxis.Minimum = -0.500000000000000000
        LeftAxis.LogarithmicBase = 2.718281828459050000
        LeftAxis.Visible = False
        RightAxis.Automatic = False
        RightAxis.AutomaticMaximum = False
        RightAxis.AutomaticMinimum = False
        RightAxis.Visible = False
        TopAxis.Automatic = False
        TopAxis.AutomaticMaximum = False
        TopAxis.AutomaticMinimum = False
        TopAxis.Visible = False
        View3D = False
        Zoom.Allow = False
        Align = alClient
        TabOrder = 0
        OnMouseMove = Chart_4WeeksDataMouseMove
        ExplicitLeft = 8
        ExplicitTop = -15
        ExplicitWidth = 978
        ExplicitHeight = 697
        ColorPaletteIndex = 5
        object Series4: TLineSeries
          Marks.Arrow.Visible = True
          Marks.Callout.Brush.Color = clBlack
          Marks.Callout.Arrow.Visible = True
          Marks.ShapeStyle = fosRoundRectangle
          Marks.Visible = False
          Brush.BackColor = clDefault
          Pointer.InflateMargins = True
          Pointer.Style = psRectangle
          Pointer.Visible = False
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Y'
          YValues.Order = loNone
        end
        object Series5: TLineSeries
          Marks.Arrow.Visible = True
          Marks.Callout.Brush.Color = clBlack
          Marks.Callout.Arrow.Visible = True
          Marks.ShapeStyle = fosRoundRectangle
          Marks.Visible = False
          SeriesColor = clBlue
          Brush.BackColor = clDefault
          Pointer.InflateMargins = True
          Pointer.Style = psRectangle
          Pointer.Visible = False
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Y'
          YValues.Order = loNone
        end
        object Series6: TLineSeries
          Marks.Arrow.Visible = True
          Marks.Callout.Brush.Color = clBlack
          Marks.Callout.Arrow.Visible = True
          Marks.ShapeStyle = fosRoundRectangle
          Marks.Visible = False
          SeriesColor = clBlue
          Brush.BackColor = clDefault
          Pointer.InflateMargins = True
          Pointer.Style = psRectangle
          Pointer.Visible = False
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Y'
          YValues.Order = loNone
        end
        object Series7: TLineSeries
          Marks.Arrow.Visible = True
          Marks.Callout.Brush.Color = clBlack
          Marks.Callout.Arrow.Visible = True
          Marks.ShapeStyle = fosRoundRectangle
          Marks.Visible = True
          SeriesColor = 16744448
          Brush.BackColor = clDefault
          LinePen.Width = 3
          Pointer.Brush.Gradient.EndColor = 16744448
          Pointer.Gradient.EndColor = 16744448
          Pointer.InflateMargins = True
          Pointer.Style = psRectangle
          Pointer.Visible = False
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Y'
          YValues.Order = loNone
        end
      end
      object Button2: TButton
        Left = 72
        Top = 3
        Width = 75
        Height = 25
        Caption = 'LoadMonth'
        TabOrder = 1
        OnClick = Button2Click
      end
    end
  end
  object Button_RestartThisApplication: TButton
    Left = 915
    Top = 549
    Width = 75
    Height = 25
    Caption = 'Button_RestartThisApplication'
    TabOrder = 1
    OnClick = Button_RestartThisApplicationClick
  end
  object OneSecTimer: TTimer
    OnTimer = OneSecTimerTimer
    Left = 864
    Top = 8
  end
  object UserActivityTimer: TTimer
    OnTimer = UserActivityTimerTimer
    Left = 936
    Top = 16
  end
  object Timer_AutoSave: TTimer
    Interval = 10000
    OnTimer = Timer_AutoSaveTimer
    Left = 936
    Top = 64
  end
end
