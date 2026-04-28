unit DecrudClientes;

interface

type
  TCliente = record
      Nome: string;
          Telefone: string;
              Email: string;
                end;

                  TDecrudClientes = class
                    private
                        FListaClientes: array of TCliente;
                            procedure AdicionarCliente(const ANome, ATelefone, AEmail: string);
                                function GetCliente(Index: Integer): TCliente;
                                  public
                                      constructor Create;
                                          destructor Destroy; override;
                                              procedure Inserir(const ANome, ATelefone, AEmail: string);
                                                  procedure Excluir(Index: Integer);
                                                      procedure Alterar(Index: Integer; const ANome, ATelefone, AEmail: string);
                                                          property Cliente[Index: Integer]: TCliente read GetCliente; default;
                                                            end;

                                                            implementation

                                                            { TDecrudClientes }

                                                            constructor TDecrudClientes.Create;
                                                            begin
                                                              inherited Create;
                                                                SetLength(FListaClientes, 0);
                                                                end;

                                                                destructor TDecrudClientes.Destroy;
                                                                begin
                                                                  SetLength(FListaClientes, 0);
                                                                    inherited Destroy;
                                                                    end;

                                                                    procedure TDecrudClientes.Inserir(const ANome, ATelefone, AEmail: string);
                                                                    var
                                                                      NovoCliente: TCliente;
                                                                      begin
                                                                        New(NovoCliente);
                                                                          try
                                                                              NovoCliente.Nome := ANome;
                                                                                  NovoCliente.Telefone := ATelefone;
                                                                                      NovoCliente.Email := AEmail;
                                                                                          SetLength(FListaClientes, Length(FListaClientes) + 1);
                                                                                              FListaClientes[High(FListaClientes)] := NovoCliente;
                                                                                                except
                                                                                                    FreeMem(NovoCliente);
                                                                                                        raise;
                                                                                                          end;
                                                                                                          end;

                                                                                                          procedure TDecrudClientes.Excluir(Index: Integer);
                                                                                                          begin
                                                                                                            if (Index >= 0) and (Index < Length(FListaClientes)) then
                                                                                                              begin
                                                                                                                  FListaClientes[Index] := FListaClientes[High(FListaClientes)];
                                                                                                                      SetLength(FListaClientes, High(FListaClientes));
                                                                                                                        end;
                                                                                                                        end;

                                                                                                                        procedure TDecrudClientes.Alterar(Index: Integer; const ANome, ATelefone, AEmail: string);
                                                                                                                        begin
                                                                                                                          if (Index >= 0) and (Index < Length(FListaClientes)) then
                                                                                                                            begin
                                                                                                                                FListaClientes[Index].Nome := ANome;
                                                                                                                                    FListaClientes[Index].Telefone := ATelefone;
                                                                                                                                        FListaClientes[Index].Email := AEmail;
                                                                                                                                          end;
                                                                                                                                          end;

                                                                                                                                          procedure TDecrudClientes.AdicionarCliente(const ANome, ATelefone, AEmail: string);
                                                                                                                                          begin
                                                                                                                                            Inserir(ANome, ATelefone, AEmail);
                                                                                                                                            end;

                                                                                                                                            function TDecrudClientes.GetCliente(Index: Integer): TCliente;
                                                                                                                                            begin
                                                                                                                                              if (Index >= 0) and (Index < Length(FListaClientes)) then
                                                                                                                                                  Result := FListaClientes[Index]
                                                                                                                                                    else
                                                                                                                                                        Result := Default(TCliente);
                                                                                                                                                        end;

                                                                                                                                                        end.unit Unit3;

interface

implementation

end.
