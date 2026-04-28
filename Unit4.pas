unit Unit4;

interface

uses
  Classes, SysUtils, DB, ADODB;

  type
    TCliente = class(TObject)
    private
       FID: Integer;
       FNome: string;
       FEmail: string;
       procedure SetID(const Value: Integer);
       procedure SetNome(const Value: string);
       procedure SetEmail(const Value: string);
    public
       property ID: Integer read FID write SetID;
       property Nome: string read FNome write SetNome;
       property Email: string read FEmail write SetEmail;
    end;

   TClienteDAO = class(TObject)
   private
      FADOConnection: TADOConnection;
   public
      constructor Create(const ConnectionString: string);
      destructor Destroy; override;
      procedure Insert(Cliente: TCliente);
      procedure Update(Cliente: TCliente);
      procedure Delete(ID: Integer);
      function GetByID(ID: Integer): TCliente;
      function GetAll: TStringList;
   end;

 implementation

 { TCliente }

 procedure TCliente.SetID(const Value: Integer);
 begin
   FID := Value;
 end;

 procedure TCliente.SetNome(const Value: string);
 begin
   FNome := Value;
 end;

 procedure TCliente.SetEmail(const Value: string);
 begin
   FEmail := Value;
 end;

 { TClienteDAO }
 constructor TClienteDAO.Create(const ConnectionString: string);
 begin
   inherited Create;
   FADOConnection := TADOConnection.Create(nil);
   FADOConnection.ConnectionString := ConnectionString;
   FADOConnection.LoginPrompt := False;
 end;

 destructor TClienteDAO.Destroy;
 begin
   FreeAndNil(FADOConnection);
   inherited Destroy;
 end;

 procedure TClienteDAO.Insert(Cliente: TCliente);
 var
   ADOQuery: TADOQuery;
 begin
   ADOQuery := TADOQuery.Create(nil);
   try
     ADOQuery.Connection := FADOConnection;
     ADOQuery.SQL.Add('INSERT INTO Clientes (Nome, Email) VALUES (:Nome, :Email)');
     ADOQuery.Parameters.ParamByName('Nome').Value := Cliente.Nome;
     ADOQuery.Parameters.ParamByName('Email').Value := Cliente.Email;
     ADOQuery.ExecSQL;
   finally
     FreeAndNil(ADOQuery);
   end;
 end;

 procedure TClienteDAO.Update(Cliente: TCliente);
 var
   ADOQuery: TADOQuery;
 begin
   ADOQuery := TADOQuery.Create(nil);
   try
     ADOQuery.Connection := FADOConnection;
     ADOQuery.SQL.Add('UPDATE Clientes SET Nome = :Nome, Email = :Email WHERE ID = :ID');
     ADOQuery.Parameters.ParamByName('Nome').Value := Cliente.Nome;
     ADOQuery.Parameters.ParamByName('Email').Value := Cliente.Email;
     ADOQuery.Parameters.ParamByName('ID').Value := Cliente.ID;
     ADOQuery.ExecSQL;
   finally
     FreeAndNil(ADOQuery);
   end;
 end;

 procedure TClienteDAO.Delete(ID: Integer);
 var
   ADOQuery: TADOQuery;
 begin
   ADOQuery := TADOQuery.Create(nil);
   try
     ADOQuery.Connection := FADOConnection;
     ADOQuery.SQL.Add('DELETE FROM Clientes WHERE ID = :ID');
     ADOQuery.Parameters.ParamByName('ID').Value := ID;
     ADOQuery.ExecSQL;
   finally
     FreeAndNil(ADOQuery);
   end;
 end;

 function TClienteDAO.GetByID(ID: Integer): TCliente;
 var
   ADOQuery: TADOQuery;
 begin
   Result := TCliente.Create;
   ADOQuery := TADOQuery.Create(nil);
   try
     ADOQuery.Connection := FADOConnection;
     ADOQuery.SQL.Add('SELECT ID, Nome, Email FROM Clientes WHERE ID = :ID');
     ADOQuery.Parameters.ParamByName('ID').Value := ID;
     ADOQuery.Open;
     if not ADOQuery.Eof then
     begin
       Result.ID := ADOQuery.FieldByName('ID').AsInteger;
       Result.Nome := ADOQuery.FieldByName('Nome').AsString;
       Result.Email := ADOQuery.FieldByName('Email').AsString;
     end;
   finally
     FreeAndNil(ADOQuery);
   end;
 end;

function TClienteDAO.GetAll: TStringList;
var
  ADOQuery: TADOQuery;
begin
  Result := TStringList.Create;
  ADOQuery := TADOQuery.Create(nil);
  try
    ADOQuery.Connection := FADOConnection;
    ADOQuery.SQL.Add('SELECT ID, Nome, Email FROM Clientes');
    ADOQuery.Open;
    while not ADOQuery.Eof do
    begin
      Result.Add(Format('%d;%s;%s', [ADOQuery.FieldByName('ID').AsInteger,
      ADOQuery.FieldByName('Nome').AsString,
      ADOQuery.FieldByName('Email').AsString]));
      ADOQuery.Next;
    end;
  finally
    FreeAndNil(ADOQuery);
  end;

end;

end.
