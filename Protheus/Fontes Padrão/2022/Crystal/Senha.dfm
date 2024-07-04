object fSenha: TfSenha
  Left = 343
  Top = 252
  Width = 324
  Height = 162
  Color = clMenu
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object LbTitulo: TLabel
    Left = 34
    Top = 32
    Width = 3
    Height = 13
  end
  object LbTituloUsu: TLabel
    Left = 34
    Top = 8
    Width = 3
    Height = 13
  end
  object LbTituloSenha: TLabel
    Left = 34
    Top = 64
    Width = 3
    Height = 13
  end
  object Shape1: TShape
    Left = 0
    Top = 0
    Width = 316
    Height = 128
    Align = alClient
    Brush.Color = cl3DLight
    Brush.Style = bsBDiagonal
    Pen.Style = psClear
  end
  object EdUsu: TEdit
    Left = 33
    Top = 32
    Width = 152
    Height = 21
    TabOrder = 0
  end
  object EdSenha: TEdit
    Left = 33
    Top = 88
    Width = 152
    Height = 21
    TabOrder = 1
  end
  object BtOK: TBitBtn
    Left = 224
    Top = 40
    Width = 75
    Height = 25
    TabOrder = 2
    OnClick = BtOKClick
  end
  object BtCancel: TBitBtn
    Left = 224
    Top = 72
    Width = 75
    Height = 25
    TabOrder = 3
    OnClick = BtCancelClick
  end
end
