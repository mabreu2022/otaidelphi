unit Unit1;

interface

uses
Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.DBGrids, Data.DB,
FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.DatS,
FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TForm1 = class(TForm)
        Button1: TButton;
            Button2: TButton;
                Button3: TButton;
                    Button4: TButton;
                        DataSource1: TDataSource;
                            DBGrid1: TDBGrid;
                                Edit1: TEdit;
                                    Label1: TLabel;
                                        Edit2: TEdit;
                                            Label2: TLabel;
                                                procedure FormCreate(Sender: TObject);
                                                    procedure Button1Click(Sender: TObject);
                                                        procedure Button2Click(Sender: TObject);
                                                            procedure Button3Click(Sender: TObject);
                                                                procedure Button4Click(Sender: TObject);
                                                                  private
                                                                      FDConnection1: TFDConnection;
                                                                          FDQuery1: TFDQuery;
                                                                            public
                                                                              end;

                                                                                var
                                                                                    Form1: TForm1;

                                                                                    implementation

                                                                                    {$R *.dfm}

                                                                                    procedure TForm1.FormCreate(Sender: TObject);
                                                                                    begin
                                                                                      FDConnection1 := TFDConnection.Create(Self);
                                                                                        FDConnection1.Params.Clear;
                                                                                          FDConnection1.Params.Add('DriverID=ODBC');
                                                                                            FDConnection1.Params.Add('Database=' + ExtractFilePath(ParamStr(0)) + 'agenda.mdb');

                                                                                              FDQuery1 := TFDQuery.Create(Self);
                                                                                                FDQuery1.Connection := FDConnection1;
                                                                                                  FDQuery1.SQL.Clear;
                                                                                                    FDQuery1.SQL.Add('SELECT * FROM agenda');
                                                                                                    end;

                                                                                                    procedure TForm1.Button1Click(Sender: TObject);
                                                                                                    begin
                                                                                                      FDQuery1.Insert;
                                                                                                        FDQuery1.FieldByName('nome').AsString := Edit1.Text;
                                                                                                          FDQuery1.FieldByName('telefone').AsString := Edit2.Text;
                                                                                                            FDQuery1.Post;
                                                                                                            end;

                                                                                                            procedure TForm1.Button2Click(Sender: TObject);
                                                                                                            begin
                                                                                                              FDQuery1.Edit;
                                                                                                                FDQuery1.FieldByName('nome').AsString := Edit1.Text;
                                                                                                                  FDQuery1.FieldByName('telefone').AsString := Edit2.Text;
                                                                                                                    FDQuery1.Post;
                                                                                                                    end;

                                                                                                                    procedure TForm1.Button3Click(Sender: TObject);
                                                                                                                    begin
                                                                                                                      FDQuery1.Delete;
                                                                                                                      end;

                                                                                                                      procedure TForm1.Button4Click(Sender: TObject);
                                                                                                                      begin
                                                                                                                        Edit1.Clear;
                                                                                                                          Edit2.Clear;
                                                                                                                          end;

                                                                                                                          end.
  end;
