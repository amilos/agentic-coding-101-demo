object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'NorthBank Statement Viewer'
  ClientHeight = 320
  ClientWidth = 480
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object lblAccountId: TLabel
    Left = 16
    Top = 19
    Width = 62
    Height = 15
    Caption = 'Account id:'
  end
  object edtAccountId: TEdit
    Left = 88
    Top = 16
    Width = 200
    Height = 23
    TabOrder = 0
  end
  object btnLoad: TButton
    Left = 304
    Top = 15
    Width = 75
    Height = 25
    Caption = 'Load'
    TabOrder = 1
    OnClick = btnLoadClick
  end
  object lstStatement: TListBox
    Left = 16
    Top = 56
    Width = 448
    Height = 248
    ItemHeight = 15
    TabOrder = 2
  end
end
