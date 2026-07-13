program StatementViewer;

uses
  Vcl.Forms,
  uMainForm in 'uMainForm.pas' {frmMain};

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
