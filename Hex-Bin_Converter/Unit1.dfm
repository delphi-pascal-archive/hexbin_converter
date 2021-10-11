object Form1: TForm1
  Left = 428
  Top = 270
  AutoSize = True
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsToolWindow
  BorderWidth = 1
  Caption = 'Hex-Bin Converter'
  ClientHeight = 113
  ClientWidth = 209
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 209
    Height = 113
    BorderWidth = 1
    BorderStyle = bsSingle
    TabOrder = 0
    object ButHexBin: TButton
      Left = 16
      Top = 8
      Width = 177
      Height = 25
      Caption = 'Hex => Bin'
      Font.Charset = ARABIC_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = ButHexBinClick
    end
    object ButBinHex: TButton
      Left = 16
      Top = 40
      Width = 177
      Height = 25
      Caption = 'Bin => Hex'
      Font.Charset = ARABIC_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = ButBinHexClick
    end
    object ButExit: TButton
      Left = 16
      Top = 72
      Width = 177
      Height = 25
      Caption = 'Exit'
      TabOrder = 2
      OnClick = ButExitClick
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 13
    Top = 21
  end
end
