unit Gauge;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, jpeg, ExtCtrls;

type
  TfGauge = class(TForm)
    ProgressBar1: TProgressBar;
    TemaProtheus: TImage;
    lblReport: TLabel;
  private
    { Private declarations }     
  public
    { Public declarations }
  end;

var
  fGauge: TfGauge;

implementation

{$R *.DFM}

end.
