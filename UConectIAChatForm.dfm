object frmConectIAChat: TfrmConectIAChat
  Left = 0
  Top = 0
  Caption = 'Conect IA Architect'
  ClientHeight = 450
  ClientWidth = 350
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnClose = FormClose
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 15
  object EdgeBrowser: TEdgeBrowser
    Left = 0
    Top = 0
    Width = 350
    Height = 450
    Align = alClient
    TabOrder = 0
    AllowSingleSignOnUsingOSPrimaryAccount = False
    TargetCompatibleBrowserVersion = '137.0.3296.44'
    UserDataFolder = '%LOCALAPPDATA%\bds.exe.WebView2'
    OnWebMessageReceived = EdgeBrowserWebMessageReceived
  end
end
