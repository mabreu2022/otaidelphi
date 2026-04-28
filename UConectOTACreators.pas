unit UConectOTACreators;

{
  ============================================================
  Conect IA Architect - OTA Creators
  ============================================================
  Classes que ensinam o Delphi a criar arquivos e projetos
  via Open Tools API (OTA), a partir do conteudo gerado pela IA.

  Hierarquia:
    TConectOTAFile          -> IOTAFile
    TConectPasCreator       -> IOTACreator + IOTAModuleCreator
    TConectProjectCreator   -> IOTACreator + IOTAProjectCreator + IOTAProjectCreator50
  ============================================================
}

interface

uses
  System.SysUtils,
  System.Classes,
  ToolsAPI;

// ============================================================
// TConectOTAFile
// Embrulha uma string como se fosse um arquivo para a OTA
// ============================================================
type
  TConectOTAFile = class(TInterfacedObject, IOTAFile)
  private
    FContent: string;
  public
    constructor Create(const AContent: string);
    { IOTAFile }
    function GetSource: string;
    function GetAge: TDateTime;
  end;

// ============================================================
// TConectPasCreator
// Instrui a OTA a criar um .pas (e opcionalmente um .dfm)
// ============================================================
type
  TConectPasCreator = class(TInterfacedObject, IOTACreator, IOTAModuleCreator)
  private
    FOwner       : IOTAProject;
    FUnitName    : string;
    FIsForm      : Boolean;
    FPasContent  : string;
    FDfmContent  : string;
    FDestPath    : string;
  public
    constructor Create(
      const AOwner      : IOTAProject;
      const AUnitName   : string;
      const AIsForm     : Boolean;
      const APasContent : string;
      const ADfmContent : string;
      const ADestPath   : string
    );

    { IOTACreator }
    function GetCreatorType: string;
    function GetExisting: Boolean;
    function GetFileSystem: string;
    function GetOwner: IOTAModule;
    function GetUnnamed: Boolean;

    { IOTAModuleCreator }
    function GetAncestorName: string;
    function GetImplFileName: string;
    function GetIntfFileName: string;
    function GetFormName: string;
    function GetMainForm: Boolean;
    function GetShowForm: Boolean;
    function GetShowSource: Boolean;
    function NewFormFile(const FormIdent, AncestorIdent: string): IOTAFile;
    function NewImplSource(const ModuleIdent, FormIdent, AncestorIdent: string): IOTAFile;
    function NewIntfSource(const ModuleIdent, FormIdent, AncestorIdent: string): IOTAFile;
  end;

// ============================================================
// TConectProjectCreator
// Instrui a OTA a criar um projeto .dpr + .dproj
// ============================================================
type
  TConectProjectCreator = class(TInterfacedObject, IOTACreator, IOTAProjectCreator, IOTAProjectCreator50)
  private
    FProjectName : string;
    FDestPath    : string;
  public
    constructor Create(const AProjectName, ADestPath: string);

    { IOTACreator }
    function GetCreatorType: string;
    function GetExisting: Boolean;
    function GetFileSystem: string;
    function GetOwner: IOTAModule;
    function GetUnnamed: Boolean;

    { IOTAProjectCreator }
    function GetFileName: string;
    function GetOptionFileName: string;
    function GetShowSource: Boolean;
    procedure NewDefaultModule;
    function NewOptionSource(const ProjectName: string): IOTAFile;
    procedure NewProjectResource(const Project: IOTAProject);
    function NewProjectSource(const ProjectName: string): IOTAFile;

    { IOTAProjectCreator50 }
    procedure NewDefaultProjectModule(const Project: IOTAProject);
  end;


implementation

// ============================================================
// TConectOTAFile
// ============================================================

constructor TConectOTAFile.Create(const AContent: string);
begin
  inherited Create;
  FContent := AContent;
end;

function TConectOTAFile.GetSource: string;
begin
  Result := FContent;
end;

function TConectOTAFile.GetAge: TDateTime;
begin
  // -1 significa "arquivo novo, sem data de modificacao anterior"
  Result := -1;
end;


// ============================================================
// TConectPasCreator
// ============================================================

constructor TConectPasCreator.Create(
  const AOwner      : IOTAProject;
  const AUnitName   : string;
  const AIsForm     : Boolean;
  const APasContent : string;
  const ADfmContent : string;
  const ADestPath   : string
);
begin
  inherited Create;
  FOwner      := AOwner;
  FUnitName   := AUnitName;
  FIsForm     := AIsForm;
  FPasContent := APasContent;
  FDfmContent := ADfmContent;
  FDestPath   := IncludeTrailingPathDelimiter(ADestPath);
end;

{ IOTACreator }

function TConectPasCreator.GetCreatorType: string;
begin
  // sForm = cria .pas + .dfm | sUnit = cria apenas .pas
  if FIsForm then
    Result := sForm
  else
    Result := sUnit;
end;

function TConectPasCreator.GetExisting: Boolean;
begin
  Result := False; // Sempre cria arquivo novo
end;

function TConectPasCreator.GetFileSystem: string;
begin
  Result := ''; // Sistema de arquivos padrao do Delphi
end;

function TConectPasCreator.GetOwner: IOTAModule;
begin
  Result := FOwner; // Associa ao projeto corrente
end;

function TConectPasCreator.GetUnnamed: Boolean;
begin
  Result := False; // Arquivo ja tem nome definido
end;

{ IOTAModuleCreator }

function TConectPasCreator.GetAncestorName: string;
begin
  if FIsForm then
    Result := 'Form'    // Herda de TForm por padrao
  else
    Result := '';
end;

function TConectPasCreator.GetImplFileName: string;
begin
  // Caminho completo do .pas a ser criado
  Result := FDestPath + FUnitName + '.pas';
end;

function TConectPasCreator.GetIntfFileName: string;
begin
  Result := ''; // Pascal nao usa arquivo de interface separado (seria .hpp no C++)
end;

function TConectPasCreator.GetFormName: string;
begin
  if FIsForm then
    Result := FUnitName  // Nome do form = nome da unit
  else
    Result := '';
end;

function TConectPasCreator.GetMainForm: Boolean;
begin
  Result := False; // Deixamos ao projeto decidir o form principal
end;

function TConectPasCreator.GetShowForm: Boolean;
begin
  Result := FIsForm; // Abre o designer se for um form
end;

function TConectPasCreator.GetShowSource: Boolean;
begin
  Result := True; // Sempre abre o editor de codigo
end;

function TConectPasCreator.NewFormFile(const FormIdent, AncestorIdent: string): IOTAFile;
begin
  if FIsForm and (FDfmContent <> '') then
    Result := TConectOTAFile.Create(FDfmContent)
  else
    Result := nil;
end;

function TConectPasCreator.NewImplSource(const ModuleIdent, FormIdent, AncestorIdent: string): IOTAFile;
begin
  if FPasContent <> '' then
    Result := TConectOTAFile.Create(FPasContent)
  else
    Result := nil;
end;

function TConectPasCreator.NewIntfSource(const ModuleIdent, FormIdent, AncestorIdent: string): IOTAFile;
begin
  Result := nil; // Delphi nao usa arquivo .hpp por padrao
end;


// ============================================================
// TConectProjectCreator
// ============================================================

constructor TConectProjectCreator.Create(const AProjectName, ADestPath: string);
begin
  inherited Create;
  FProjectName := AProjectName;
  FDestPath    := IncludeTrailingPathDelimiter(ADestPath);
end;

{ IOTACreator }

function TConectProjectCreator.GetCreatorType: string;
begin
  Result := sApplication; // Cria projeto do tipo VCL Application
end;

function TConectProjectCreator.GetExisting: Boolean;
begin
  Result := False;
end;

function TConectProjectCreator.GetFileSystem: string;
begin
  Result := '';
end;

function TConectProjectCreator.GetOwner: IOTAModule;
begin
  Result := nil; // Um projeto nao tem "dono" — ele E o dono
end;

function TConectProjectCreator.GetUnnamed: Boolean;
begin
  Result := False;
end;

{ IOTAProjectCreator }

function TConectProjectCreator.GetFileName: string;
begin
  // Caminho completo do .dpr a ser criado
  Result := FDestPath + FProjectName + '.dpr';
end;

function TConectProjectCreator.GetOptionFileName: string;
begin
  Result := ''; // Deixa o Delphi gerar o .dproj automaticamente
end;

function TConectProjectCreator.GetShowSource: Boolean;
begin
  Result := True; // Abre o .dpr no editor
end;

procedure TConectProjectCreator.NewDefaultModule;
begin
  // Nao criamos um modulo padrao aqui —
  // as units serao adicionadas manualmente depois pelo CriarProjetoCompleto
end;

function TConectProjectCreator.NewOptionSource(const ProjectName: string): IOTAFile;
begin
  Result := nil; // Deixa o Delphi gerar as opcoes do .dproj
end;

procedure TConectProjectCreator.NewProjectResource(const Project: IOTAProject);
begin
  // Nao precisamos de recursos customizados por ora
end;

function TConectProjectCreator.NewProjectSource(const ProjectName: string): IOTAFile;
const
  // Template minimo de um .dpr valido para VCL Application
  DPR_TEMPLATE =
    'program %s;'                                   + sLineBreak +
    ''                                              + sLineBreak +
    'uses'                                          + sLineBreak +
    '  Vcl.Forms;'                                  + sLineBreak +
    ''                                              + sLineBreak +
    '{$R *.res}'                                    + sLineBreak +
    ''                                              + sLineBreak +
    'begin'                                         + sLineBreak +
    '  Application.Initialize;'                     + sLineBreak +
    '  Application.MainFormOnTaskbar := True;'      + sLineBreak +
    '  Application.Run;'                            + sLineBreak +
    'end.';
begin
  Result := TConectOTAFile.Create(Format(DPR_TEMPLATE, [ProjectName]));
end;

{ IOTAProjectCreator50 }

procedure TConectProjectCreator.NewDefaultProjectModule(const Project: IOTAProject);
begin
  // Nao criamos modulo padrao aqui por escolha de design
end;

end.
