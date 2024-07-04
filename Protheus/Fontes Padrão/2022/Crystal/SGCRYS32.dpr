program SGCRYS32;

uses
  Forms,
  Main in 'Main.pas' {fMain},
  Lib in 'Lib.pas',
  Crysini in 'Crysini.pas' {fCrysini},
  Senha in 'Senha.pas' {fSenha},
  Gauge in 'Gauge.pas' {fGauge},
  Viewer in 'Viewer.pas' {fViewer},
  i18n in 'i18n.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'sgcrys32';
  Application.CreateForm(TfMain, fMain);
  Application.Run;
end.
