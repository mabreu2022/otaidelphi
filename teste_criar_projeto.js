// ============================================================
// TESTE: Cole este comando no Console do DevTools do EdgeBrowser
// (clique com botao direito na area do browser > Inspect > Console)
//
// Ele simula o que a IA vai enviar para criar um projeto completo.
// ============================================================

// --- TESTE 1: Criar projeto com 1 form + 1 unit de dados ---
window.chrome.webview.postMessage(JSON.stringify({
  "action": "create_project",
  "project_name": "TesteConectIA",
  "project_path": "C:\\Projetos\\TesteConectIA",
  "units": [
    {
      "unit_name": "MainForm",
      "is_form": true,
      "pas_content": "unit MainForm;\n\ninterface\n\nuses\n  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,\n  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,\n  Vcl.StdCtrls;\n\ntype\n  TForm1 = class(TForm)\n    btnOk: TButton;\n    lblTitulo: TLabel;\n    procedure btnOkClick(Sender: TObject);\n  private\n  public\n  end;\n\nvar\n  Form1: TForm1;\n\nimplementation\n\n{$R *.dfm}\n\nprocedure TForm1.btnOkClick(Sender: TObject);\nbegin\n  ShowMessage('Ola, Conect IA!');\nend;\n\nend.",
      "dfm_content": "object Form1: TForm1\n  Left = 0\n  Top = 0\n  Caption = 'Teste Conect IA'\n  ClientHeight = 300\n  ClientWidth = 400\n  Color = clBtnFace\n  Font.Charset = DEFAULT_CHARSET\n  Font.Color = clWindowText\n  Font.Height = -12\n  Font.Name = 'Segoe UI'\n  Font.Style = []\n  TextHeight = 15\n  object lblTitulo: TLabel\n    Left = 24\n    Top = 24\n    Width = 180\n    Height = 20\n    Caption = 'Gerado pelo Conect IA Architect'\n  end\n  object btnOk: TButton\n    Left = 150\n    Top = 230\n    Width = 100\n    Height = 32\n    Caption = 'OK'\n    TabOrder = 0\n    OnClick = btnOkClick\n  end\nend"
    },
    {
      "unit_name": "UDadosCliente",
      "is_form": false,
      "pas_content": "unit UDadosCliente;\n\ninterface\n\nuses\n  System.SysUtils, System.Classes;\n\ntype\n  TCliente = class\n  private\n    FNome  : string;\n    FEmail : string;\n  public\n    property Nome  : string read FNome  write FNome;\n    property Email : string read FEmail write FEmail;\n    constructor Create(const ANome, AEmail: string);\n  end;\n\nimplementation\n\nconstructor TCliente.Create(const ANome, AEmail: string);\nbegin\n  FNome  := ANome;\n  FEmail := AEmail;\nend;\n\nend.",
      "dfm_content": ""
    }
  ]
}));


// --- TESTE 2: Apenas injetar codigo no editor ativo (modo legado via JSON) ---
// window.chrome.webview.postMessage(JSON.stringify({
//   "action": "inject_code",
//   "code": "ShowMessage('Ola do Conect IA!');"
// }));
