unit Crysini;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, FileCtrl, Lib, ExtCtrls, i18n;

type
   TfCrysini = class(TForm)
    BtOK: TBitBtn;
    BtCancel: TBitBtn;
    Shape1: TShape;
    Bevel1: TBevel;
    LbTituloSX: TLabel;
    LbTituloRoot: TLabel;
    lblExportRoot: TLabel;
    EditSX: TEdit;
    EditRoot: TEdit;
    PathSX: TBitBtn;
    PathRoot: TBitBtn;
    EditExport: TEdit;
    PathExport: TButton;
    chkLog: TCheckBox;
    chkDll: TCheckBox;
    Label1: TLabel;
    lblServidor: TLabel;
    lblPorta: TLabel;
    EditDriver: TEdit;
    EditServer: TEdit;
    EditPort: TEdit;
    Bevel2: TBevel;
    Bevel3: TBevel;
    lblConfiguracao: TLabel;
    lblOpcao: TLabel;
    lblDiretorio: TLabel;
    chkPrint: TCheckBox;
    chkAuto: TCheckBox;
    procedure PathSXClick(Sender: TObject);
    procedure PathRootClick(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PathExportClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fCrysini: TfCrysini;
  sPathEXE : String;
  nIdioma : Integer;

implementation

{$R *.DFM}

procedure TfCrysini.PathSXClick(Sender: TObject);
var
 sPathAux : String;
begin
  if SelectDirectory(sPathAux,[sdAllowCreate, sdPerformCreate, sdPrompt],1000) then
    EditSX.Text := sPathAux;
end;

procedure TfCrysini.PathRootClick(Sender: TObject);
var
  sPathAux : String;
begin
  if SelectDirectory(sPathAux,[sdAllowCreate, sdPerformCreate, sdPrompt],1000) then
    EditRoot.Text := sPathAux;
end;

procedure TfCrysini.PathExportClick(Sender: TObject);
var
  sPathAux : String;
begin
  if SelectDirectory(sPathAux,[sdAllowCreate, sdPerformCreate, sdPrompt],1000) then
    EditExport.Text := sPathAux;

end;

procedure TfCrysini.BtCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfCrysini.BtOKClick(Sender: TObject);
var
  bOK : Boolean;
begin
  bOK := True;
  if (Trim(EditSX.Text) = cVAZIO) or (Not DirectoryExists(EditSX.Text)) then
  begin
    ExibeErro(SetTexto(3, nIdioma));
    EditSX.SetFocus;
    bOK := False;
  end;

  if (Trim(EditRoot.Text) = cVAZIO) or (Not DirectoryExists(EditRoot.Text)) then
  begin
    ExibeErro(SetTexto(3, nIdioma));
    EditRoot.SetFocus;
    bOK := False;
  end;

  if (chkDll.Checked = true) then
  begin
       if (Trim(EditDriver.Text) = cVAZIO) or (Trim(EditServer.Text) = cVAZIO) or (Trim(EditPort.Text) = cVAZIO) then
       begin
          ExibeErro(SetTexto(33, nIdioma));
          EditRoot.SetFocus;
          bOK := False;
       end;
  end;

  //Defini��o do arquivo de configura��o (Crysini.ini)

  If bOK then
  begin  
    //Define a sess�o [PATH]
    SetValINI(sPathEXE+cBARINV+cCRYSINI, cPATH,    cSXS, EditSX.Text);
    SetValINI(sPathEXE+cBARINV+cCRYSINI, cPATH,   cDATA, EditRoot.Text);
    SetValINI(sPathEXE+cBARINV+cCRYSINI, cPATH, cEXPORT, EditExport.Text);
    //Define se dever� ser gerado o arquivo de LOG
    if chkLog.Checked = true then
    begin
        SetValINI(sPathEXE+cBARINV+cCRYSINI, cPATH,    cLOG, cUM);
    end;
    //Define se os SXS ser�o acessados via DLL
    if chkDll.Checked = true then
    begin
        SetValINI(sPathEXE+cBARINV+cCRYSINI, cPATH, cDLL, cUM);
        //Define a sess�o [SXS] do arquivo de configura��o (Crwini.ini)
        SetValINI(sPathEXE+cBARINV+cCRWINI, cSXS, cSX1, cUM);
        SetValINI(sPathEXE+cBARINV+cCRWINI, cSXS, cSX2, cUM);
        SetValINI(sPathEXE+cBARINV+cCRWINI, cSXS, cDRIVERS, EditDriver.Text);
        SetValINI(sPathEXE+cBARINV+cCRWINI, cSXS, cSERVER, EditServer.Text);
        SetValINI(sPathEXE+cBARINV+cCRWINI, cSXS, cPORT, EditPort.Text);
    end;
    //Define se ser� permitida a impress�o dos relat�rios.
    if chkPrint.Checked = true then
    begin
        SetValINI(sPathEXE+cBARINV+cCRYSINI, cPATH, cPRINT, cZERO);
    end;

    //Define se a configura��o do StartPath ser� realizada pelo CrwStartPath.
    if chkAuto.Checked = true then
    begin
        SetValINI(sPathEXE+cBARINV+cCRYSINI, cPATH, cAUTO, cUM);
    end;

    Close;
  end;

end;

procedure TfCrysini.FormCreate(Sender: TObject);
begin
  LbTituloSX.Caption := SetTexto(5, nIdioma); //'Selecione o caminho definido no StartPath:'
  LbTituloRoot.Caption := SetTexto(7, nIdioma); //'Selecione o caminho definido no RootPath:'
  LblExportRoot.Caption := SetTexto(6, nIdioma); //'Selecione o caminho para exporta��o de relat�rios:'
  LblDiretorio.Caption := SetTexto(26, nIdioma); //'Diret�rios'
  LblOpcao.Caption := SetTexto(27, nIdioma); //'Op��es'
  LblConfiguracao.Caption := SetTexto(28, nIdioma); //'Configura��es do Servidor'
  chkLog.Caption := SetTexto(29, nIdioma); //'Gera LOG'
  chkDll.Caption := SetTexto(30, nIdioma); //'Acessa SXx via DLL'
  chkPrint.Caption := SetTexto(34, nIdioma); //'Desabilita Impress�o'
  chkAuto.Caption := SetTexto(35, nIdioma); //'Configura��o Autom�tica'
  LblServidor.Caption := SetTexto(31, nIdioma); //'Servidor'
  LblPorta.Caption := SetTexto(32, nIdioma); //'Porta'

  BtOK.Caption := SetTexto(9, nIdioma);
  BtCancel.Caption := SetTexto(10, nIdioma);
end;
end.
