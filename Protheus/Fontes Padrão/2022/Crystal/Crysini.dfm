object fCrysini: TfCrysini
  Left = 239
  Top = 232
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  ClientHeight = 320
  ClientWidth = 563
  Color = clBtnHighlight
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Shape1: TShape
    Left = 0
    Top = 0
    Width = 563
    Height = 320
    Align = alClient
    Brush.Color = cl3DLight
    Brush.Style = bsBDiagonal
    Pen.Style = psClear
  end
  object Bevel3: TBevel
    Left = 8
    Top = 200
    Width = 185
    Height = 113
    Shape = bsFrame
  end
  object Bevel1: TBevel
    Left = 8
    Top = 8
    Width = 441
    Height = 185
    Shape = bsFrame
  end
  object Bevel2: TBevel
    Left = 200
    Top = 200
    Width = 249
    Height = 113
    Shape = bsFrame
  end
  object LbTituloSX: TLabel
    Left = 24
    Top = 64
    Width = 33
    Height = 13
    Caption = '           '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object LbTituloRoot: TLabel
    Left = 24
    Top = 18
    Width = 30
    Height = 13
    Caption = '          '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object lblExportRoot: TLabel
    Left = 24
    Top = 140
    Width = 6
    Height = 13
    Caption = '  '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object Label1: TLabel
    Left = 218
    Top = 219
    Width = 28
    Height = 13
    Caption = 'Driver'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object lblServidor: TLabel
    Left = 216
    Top = 247
    Width = 3
    Height = 13
    Caption = '.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object lblPorta: TLabel
    Left = 216
    Top = 276
    Width = 3
    Height = 13
    Caption = '.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object lblConfiguracao: TLabel
    Left = 208
    Top = 194
    Width = 3
    Height = 13
    Caption = '.'
  end
  object lblOpcao: TLabel
    Left = 15
    Top = 194
    Width = 3
    Height = 13
    Caption = '.'
  end
  object lblDiretorio: TLabel
    Left = 15
    Top = 2
    Width = 3
    Height = 13
    Caption = '.'
  end
  object BtOK: TBitBtn
    Left = 469
    Top = 128
    Width = 75
    Height = 25
    TabOrder = 0
    OnClick = BtOKClick
  end
  object BtCancel: TBitBtn
    Left = 469
    Top = 168
    Width = 75
    Height = 25
    TabOrder = 1
    OnClick = BtCancelClick
  end
  object EditSX: TEdit
    Left = 24
    Top = 80
    Width = 369
    Height = 21
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
  end
  object EditRoot: TEdit
    Left = 24
    Top = 34
    Width = 369
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
  end
  object PathSX: TBitBtn
    Left = 400
    Top = 78
    Width = 25
    Height = 25
    Caption = '...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    OnClick = PathSXClick
  end
  object PathRoot: TBitBtn
    Left = 400
    Top = 33
    Width = 25
    Height = 25
    Caption = '...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
    OnClick = PathRootClick
  end
  object EditExport: TEdit
    Left = 24
    Top = 157
    Width = 369
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 6
  end
  object PathExport: TButton
    Left = 400
    Top = 156
    Width = 25
    Height = 25
    Caption = '...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 7
    OnClick = PathExportClick
  end
  object chkLog: TCheckBox
    Left = 24
    Top = 221
    Width = 145
    Height = 17
    Caption = '.'
    Checked = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    State = cbChecked
    TabOrder = 8
  end
  object chkDll: TCheckBox
    Left = 24
    Top = 282
    Width = 145
    Height = 17
    Caption = '.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 9
  end
  object EditDriver: TEdit
    Left = 264
    Top = 219
    Width = 129
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 10
    Text = 'TCP'
  end
  object EditServer: TEdit
    Left = 264
    Top = 246
    Width = 129
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 11
  end
  object EditPort: TEdit
    Left = 264
    Top = 275
    Width = 129
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 12
  end
  object chkPrint: TCheckBox
    Left = 24
    Top = 251
    Width = 145
    Height = 17
    TabOrder = 13
  end
  object chkAuto: TCheckBox
    Left = 24
    Top = 112
    Width = 145
    Height = 17
    TabOrder = 14
  end
end
