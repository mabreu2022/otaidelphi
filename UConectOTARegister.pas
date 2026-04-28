unit UConectOTARegister;

interface

uses
  ToolsAPI,
  Vcl.Menus,
  Vcl.Dialogs,
  System.SysUtils,
  System.Classes,
  UConectIAChatForm,
  Vcl.Forms;

type
  TConectIAWizard = class(TNotifierObject, IOTAWizard)
  public
    function GetIDString: string;
    function GetName: string;
    function GetState: TWizardState;
    procedure Execute;
    procedure MenuClick(Sender: TObject);
  end;

procedure Register;

implementation

var
  MenuItem: TMenuItem;

procedure Register;
var
  NTAServices: INTAServices;
  ToolsMenu: TMenuItem;
begin
  // 1. Registra o Wizard
  RegisterPackageWizard(TConectIAWizard.Create);

  // 2. Injeta o Menu de forma segura
  if Supports(BorlandIDEServices, INTAServices, NTAServices) then
  begin
    ToolsMenu := NTAServices.MainMenu.Items.Find('Tools');
    if Assigned(ToolsMenu) then
    begin
      if ToolsMenu.Find('Conect IA Chat') = nil then
      begin
        MenuItem := TMenuItem.Create(ToolsMenu);
        MenuItem.Caption := 'Conect IA Chat';
        // Criamos o Wizard apenas para tratar o clique
        MenuItem.OnClick := TConectIAWizard.Create.MenuClick;
        ToolsMenu.Add(MenuItem);
      end;
    end;
  end;
end;

{ TConectIAWizard }

procedure TConectIAWizard.Execute;
begin
 if not Assigned(frmConectIAChat) then
  begin
    // AQUI ESTÁ O SEGREDO: Em vez de "nil", passamos o "Application" da IDE como dono
    frmConectIAChat := TfrmConectIAChat.Create(Application);
  end;

  frmConectIAChat.Show;
end;

procedure TConectIAWizard.MenuClick(Sender: TObject);
begin
  Execute;
end;

function TConectIAWizard.GetIDString: string;
begin
  Result := 'ConectSolutions.IA.Architect.V1';
end;

function TConectIAWizard.GetName: string;
begin
  Result := 'Conect IA Architect';
end;

function TConectIAWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

initialization

finalization
  // Limpa a janela da memória quando o pacote for recompilado/desinstalado
  if Assigned(frmConectIAChat) then
    frmConectIAChat.Free;

  if MenuItem <> nil then
    MenuItem.Free;


end.
