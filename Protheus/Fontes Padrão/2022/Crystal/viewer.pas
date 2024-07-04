unit Viewer;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OleCtrls, CrystalActiveXReportViewerLib11_5_TLB, CRAXDRT_TLB, Lib, Gauge,
  ComCtrls;

type
  TfViewer = class(TForm)
    CRViewer91: TCrystalActiveXReportViewer;
    procedure FormShow(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fViewer: TfViewer;
  RepView : IReport;
  sArquivo : String;

implementation

{$R *.DFM}

procedure TfViewer.FormShow(Sender: TObject);
var
  i : Integer;   
begin
  gravalog('SGCRYS32 com visualizador do ' + cVERSION + ' ' + cBUILD, sArquivo);
  For i:=0 to Screen.FormCount-1 do
    if Screen.Forms[i] is TfGauge then
      Begin
        TfGauge(Screen.Forms[i]).Close;
      end;
end;

end.
