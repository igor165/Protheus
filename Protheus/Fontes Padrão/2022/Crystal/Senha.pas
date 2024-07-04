unit Senha;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, Lib, ExtCtrls, i18n;

type
  TfSenha = class(TForm)
    LbTitulo: TLabel;
    LbTituloUsu: TLabel;
    LbTituloSenha: TLabel;
    EdUsu: TEdit;
    EdSenha: TEdit;
    BtOK: TBitBtn;
    BtCancel: TBitBtn;
    Shape1: TShape;
    procedure BtCancelClick(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fSenha: TfSenha;
  sLogin : String;
  nIdioma : Integer;

implementation

{$R *.DFM}

procedure TfSenha.BtCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfSenha.BtOKClick(Sender: TObject);
begin
  sLogin := EdUsu.Text + cBARRA + EdSenha.Text;
  Close;
end;

procedure TfSenha.FormCreate(Sender: TObject);
begin
  fSenha.Caption := SetTexto(11, nIdioma);
  LbTitulo.Caption := SetTexto(12, nIdioma);
  LbTituloUsu.Caption := SetTexto(13, nIdioma);
  LbTituloSenha.Caption := SetTexto(14, nIdioma);
  BtOk.Caption := SetTexto(9, nIdioma);
  BtCancel.Caption := SetTexto(10, nIdioma);
end;

end.
