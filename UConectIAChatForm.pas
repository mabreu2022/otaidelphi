unit UConectIAChatForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ToolsAPI, DockForm,
  Winapi.WebView2, Winapi.ActiveX, Vcl.Edge, System.JSON,
  UConectOTACreators;

type
  TfrmConectIAChat = class(TDockableForm)
    EdgeBrowser: TEdgeBrowser;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure EdgeBrowserWebMessageReceived(Sender: TCustomEdgeBrowser; Args: TWebMessageReceivedEventArgs);
  private
    procedure InjetarCodigo(const ACodigo: string);
    procedure CriarProjetoCompleto(const AJSON: TJSONObject);
    procedure CriarNovaUnit(const AJSON: TJSONObject; AOwner: IOTAProject);
    function ObterProjetoAtivo: IOTAProject;
    procedure MostrarErro(const AMensagem: string);
    procedure MostrarSucesso(const AMensagem: string);
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  frmConectIAChat: TfrmConectIAChat = nil;

implementation

{$R *.dfm}

constructor TfrmConectIAChat.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Name    := 'frmConectIA_V1';
  Caption := 'Conect IA Architect';
  DeskSection        := '';
  AutoSave           := False;
  SaveStateNecessary := False;
end;

procedure TfrmConectIAChat.FormShow(Sender: TObject);
begin
  EdgeBrowser.Navigate('file:///c:/Projetos Antigravity/OTA IA DELPHI/index.html');
end;

procedure TfrmConectIAChat.EdgeBrowserWebMessageReceived(
  Sender: TCustomEdgeBrowser; Args: TWebMessageReceivedEventArgs);
var
  MensagemPWide: PWideChar;
  ConteudoStr  : string;
  JSONValue    : TJSONValue;
  JSONObj      : TJSONObject;
  Action       : string;
begin
  if Args.ArgsInterface.TryGetWebMessageAsString(MensagemPWide) <> S_OK then
    Exit;

  ConteudoStr := string(MensagemPWide);
  CoTaskMemFree(MensagemPWide);

  if Trim(ConteudoStr) = '' then
    Exit;

  JSONValue := TJSONObject.ParseJSONValue(ConteudoStr);
  try
    if (JSONValue <> nil) and (JSONValue is TJSONObject) then
    begin
      JSONObj := JSONValue as TJSONObject;
      Action  := JSONObj.GetValue<string>('action', 'inject_code');

      if Action = 'create_project' then
        CriarProjetoCompleto(JSONObj)
      else if Action = 'inject_code' then
        InjetarCodigo(JSONObj.GetValue<string>('code', ''))
      else
        MostrarErro('Acao desconhecida: ' + Action);
    end
    else
    begin
      // Modo legado: texto puro
      if (Length(ConteudoStr) >= 2) and
         (ConteudoStr[1] = '"') and
         (ConteudoStr[Length(ConteudoStr)] = '"') then
        ConteudoStr := Copy(ConteudoStr, 2, Length(ConteudoStr) - 2);

      ConteudoStr := StringReplace(ConteudoStr, '\n',   #10,        [rfReplaceAll]);
      ConteudoStr := StringReplace(ConteudoStr, '\r',   '',         [rfReplaceAll]);
      ConteudoStr := StringReplace(ConteudoStr, '\"',   '"',        [rfReplaceAll]);
      ConteudoStr := StringReplace(ConteudoStr, #13#10, #10,        [rfReplaceAll]);
      ConteudoStr := StringReplace(ConteudoStr, #10,    sLineBreak, [rfReplaceAll]);

      if Trim(ConteudoStr) <> '' then
        InjetarCodigo(ConteudoStr);
    end;
  finally
    JSONValue.Free;
  end;
end;

procedure TfrmConectIAChat.CriarProjetoCompleto(const AJSON: TJSONObject);
var
  ProjectName   : string;
  ProjectPath   : string;
  UnitsArray    : TJSONArray;
  ModuleServices: IOTAModuleServices;
  ProjModule    : IOTAModule;
  ProjCreator   : TConectProjectCreator;
  OTAProject    : IOTAProject;
  I             : Integer;
  Msg           : string;
begin
  ProjectName := AJSON.GetValue<string>('project_name', '');
  ProjectPath := AJSON.GetValue<string>('project_path', '');

  if ProjectName = '' then
  begin
    MostrarErro('JSON invalido: campo "project_name" nao encontrado.');
    Exit;
  end;

  if ProjectPath = '' then
  begin
    MostrarErro('JSON invalido: campo "project_path" nao encontrado.');
    Exit;
  end;

  if not DirectoryExists(ProjectPath) then
  begin
    if not ForceDirectories(ProjectPath) then
    begin
      MostrarErro('Nao foi possivel criar o diretorio: ' + ProjectPath);
      Exit;
    end;
  end;

  Msg := Format(
    'Conect IA Architect vai criar o projeto:' + sLineBreak +
    '' + sLineBreak +
    '  Nome: %s' + sLineBreak +
    '  Pasta: %s' + sLineBreak +
    '' + sLineBreak +
    'Deseja continuar?',
    [ProjectName, ProjectPath]
  );

  if MessageDlg(Msg, mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  if not Supports(BorlandIDEServices, IOTAModuleServices, ModuleServices) then
  begin
    MostrarErro('IOTAModuleServices nao disponivel.');
    Exit;
  end;

  ProjCreator := TConectProjectCreator.Create(ProjectName, ProjectPath);
  try
    ProjModule := ModuleServices.CreateModule(ProjCreator);
  except
    on E: Exception do
    begin
      MostrarErro('Erro ao criar projeto: ' + E.Message);
      Exit;
    end;
  end;

  if not Assigned(ProjModule) then
  begin
    MostrarErro('A OTA nao retornou um modulo de projeto valido.');
    Exit;
  end;

  if not Supports(ProjModule, IOTAProject, OTAProject) then
  begin
    MostrarErro('Nao foi possivel obter IOTAProject do modulo criado.');
    Exit;
  end;

  UnitsArray := AJSON.GetValue<TJSONArray>('units');
  if Assigned(UnitsArray) then
  begin
    for I := 0 to UnitsArray.Count - 1 do
    begin
      try
        CriarNovaUnit(UnitsArray.Items[I] as TJSONObject, OTAProject);
      except
        on E: Exception do
          ShowMessage(Format('Aviso: erro ao criar unit %d: %s', [I + 1, E.Message]));
      end;
    end;
  end;

  MostrarSucesso(Format(
    'Projeto "%s" criado com sucesso em:' + sLineBreak + '%s',
    [ProjectName, ProjectPath]
  ));
end;

procedure TfrmConectIAChat.CriarNovaUnit(const AJSON: TJSONObject; AOwner: IOTAProject);
var
  UnitName   : string;
  IsForm     : Boolean;
  PasContent : string;
  DfmContent : string;
  DestPath   : string;
  Creator    : TConectPasCreator;
  ModSvc     : IOTAModuleServices;
begin
  UnitName   := AJSON.GetValue<string>('unit_name',   '');
  IsForm     := AJSON.GetValue<Boolean>('is_form',    False);
  PasContent := AJSON.GetValue<string>('pas_content', '');
  DfmContent := AJSON.GetValue<string>('dfm_content', '');

  if UnitName = '' then
    raise Exception.Create('unit_name nao pode ser vazio.');

  if PasContent = '' then
    raise Exception.Create('pas_content vazio para "' + UnitName + '".');

  if Assigned(AOwner) then
    DestPath := ExtractFilePath(AOwner.FileName)
  else
    DestPath := '';

  if not Supports(BorlandIDEServices, IOTAModuleServices, ModSvc) then
    raise Exception.Create('IOTAModuleServices nao disponivel.');

  Creator := TConectPasCreator.Create(
    AOwner, UnitName, IsForm, PasContent, DfmContent, DestPath);

  ModSvc.CreateModule(Creator);
end;

procedure TfrmConectIAChat.InjetarCodigo(const ACodigo: string);
var
  EditorServices: IOTAEditorServices;
  EditView      : IOTAEditView;
  EditPosition  : IOTAEditPosition;
  Linhas        : TStringList;
  I             : Integer;
begin
  if not Supports(BorlandIDEServices, IOTAEditorServices, EditorServices) then
    Exit;

  EditView := EditorServices.TopView;
  if not Assigned(EditView) or not Assigned(EditView.Buffer) then
    Exit;

  EditPosition := EditView.Buffer.EditPosition;

  Linhas := TStringList.Create;
  try
    Linhas.Text := ACodigo;
    for I := 0 to Linhas.Count - 1 do
    begin
      EditPosition.InsertText(Linhas[I]);
      if I < (Linhas.Count - 1) then
        EditPosition.InsertCharacter(#13);
    end;
    EditView.Paint;
  finally
    Linhas.Free;
  end;
end;

function TfrmConectIAChat.ObterProjetoAtivo: IOTAProject;
var
  ModSvc  : IOTAModuleServices;
  ProjGrp : IOTAProjectGroup;
begin
  Result := nil;
  if not Supports(BorlandIDEServices, IOTAModuleServices, ModSvc) then
    Exit;
  ProjGrp := ModSvc.MainProjectGroup;
  if Assigned(ProjGrp) then
    Result := ProjGrp.ActiveProject;
end;

procedure TfrmConectIAChat.MostrarErro(const AMensagem: string);
begin
  MessageDlg('Conect IA Architect - Erro:' + sLineBreak + AMensagem,
    mtError, [mbOK], 0);
end;

procedure TfrmConectIAChat.MostrarSucesso(const AMensagem: string);
begin
  MessageDlg('Conect IA Architect - Sucesso:' + sLineBreak + AMensagem,
    mtInformation, [mbOK], 0);
end;

procedure TfrmConectIAChat.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TfrmConectIAChat.FormDestroy(Sender: TObject);
begin
  frmConectIAChat := nil;
end;

end.
