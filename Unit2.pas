unit Unit2;

interfaceuses System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
 FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait,
   Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.DApt.Intf, FireDAC.DApt,
    FireDAC.Comp.UI;

    type TClient = class private FID: Integer;
     FName: string;
      FEmail: string;
       procedure SetName(const Value: string);
        procedure SetEmail(const Value: string);
         public constructor Create;
          destructor Destroy; override;
           property ID: Integer read FID write FID;
            property Name: string read FName write SetName;
             property Email: string read FEmail write SetEmail;
              end;

               TClientDAO = class(TFDQuery)
                private procedure OpenConnection;
                 procedure CloseConnection;
                  public constructor Create;
                   destructor Destroy; override;
                    function Insert(const Client: TClient): Boolean;
                     function Update(const Client: TClient): Boolean;
                      function Delete(const ID: Integer): Boolean;
                       function Select(const ID: Integer): TClient;
                        function GetAllClients: TFDMemTable;
                         end;

                         implementation{ TClient }

                         constructor TClient.Create;
                         begin inherited Create;
                         end;

                         destructor TClient.Destroy;
                         begin inherited Destroy;
                         end;

                         procedure TClient.SetName(const Value: string);
                         begin FName := Value;
                         end;

                         procedure TClient.SetEmail(const Value: string);
                         begin FEmail := Value;
                         end;

                         { TClientDAO }

                         constructor TClientDAO.Create;
                         begin inherited Create(nil);
                          ConnectionDefName := 'YourConnectionName'; // Set your connection definition nameend;

                          destructor TClientDAO.Destroy;
                          begin CloseConnection;
                           inherited Destroy;
                           end;

                           procedure TClientDAO.OpenConnection;
                           begin if not Connected then Connect;
                           end;

                           procedure TClientDAO.CloseConnection;
                           begin if Connected then Disconnect;
                           end;

                           function TClientDAO.Insert(const Client: TClient): Boolean;
                           begin OpenConnection;
                            try SQL.Clear;
                             SQL.Add('INSERT INTO Clients (ID, Name, Email)');
                              SQL.Add('VALUES (:ID, :Name, :Email)');
                               Params.ParamByName('ID').AsInteger := Client.ID;
                                Params.ParamByName('Name').AsString := Client.Name;
                                 Params.ParamByName('Email').AsString := Client.Email;
                                  ExecSQL;
                                   Result := True;
                                    except on E: Exception do Result := False;
                                     end;
                                      CloseConnection;
                                      end;

                                      function TClientDAO.Update(const Client: TClient): Boolean;
                                      begin OpenConnection;
                                       try SQL.Clear;

                                              SQL.Add('UPDATE Clients SET Name = :Name, Email = :Email WHERE ID = :ID');
                                         Params.ParamByName('ID').AsInteger := Client.ID;
                                          Params.ParamByName('Name').AsString := Client.Name;
                                           Params.ParamByName('Email').AsString := Client.Email;
                                            ExecSQL;
                                             Result := True;
                                              except on E: Exception do Result := False;
                                               end;
                                                CloseConnection;
                                                end;

                                                function TClientDAO.Delete(const ID: Integer): Boolean;
                                                begin OpenConnection;
                                                 try SQL.Clear;
                                                  SQL.Add('DELETE FROM Clients WHERE ID = :ID');
                                                   Params.ParamByName('ID').AsInteger := ID;
                                                    ExecSQL;
                                                     Result := True;
                                                      except on E: Exception do Result := False;
                                                       end;
                                                        CloseConnection;
                                                        end;

                                                        function TClientDAO.Select(const ID: Integer): TClient;
                                                        var Client: TClient;
                                                        begin OpenConnection;
                                                         try SQL.Clear;
                                                          SQL.Add('SELECT * FROM Clients WHERE ID = :ID');
                                                           Params.ParamByName('ID').AsInteger := ID;
                                                            Open;
                                                             if not EOF then begin Client := TClient.Create;
                                                              Client.ID := FieldByName('ID').AsInteger;
                                                               Client.Name := FieldByName('Name').AsString;
                                                                Client.Email := FieldByName('Email').AsString;
                                                                 Result := Client;
                                                                  end else Result := nil;
                                                                   finally Close;
                                                                    end;
                                                                     CloseConnection;
                                                                     end;

                                                                     function TClientDAO.GetAllClients: TFDMemTable;
                                                                     begin
