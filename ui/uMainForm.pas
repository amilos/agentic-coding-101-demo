unit uMainForm;

{ NorthBank statement viewer (Win32 VCL).

  Minimal stubbed screen used for the Appium/WinAppDriver UI-automation demo.
  Controls carry stable Names so an automation id can target them:
    edtAccountId  - account number entry
    btnLoad       - loads the statement
    lstStatement  - the resulting statement lines }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfrmMain = class(TForm)
    edtAccountId: TEdit;
    btnLoad: TButton;
    lstStatement: TListBox;
    lblAccountId: TLabel;
    procedure btnLoadClick(Sender: TObject);
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.btnLoadClick(Sender: TObject);
var
  AccountId: string;
begin
  AccountId := Trim(edtAccountId.Text);
  lstStatement.Clear;

  if AccountId = '' then
  begin
    lstStatement.Items.Add('Please enter an account id.');
    Exit;
  end;

  // Stubbed statement data. A real build would query the ledger.
  lstStatement.Items.Add(Format('Statement for account %s', [AccountId]));
  lstStatement.Items.Add('2026-06-01  Opening balance      500.00');
  lstStatement.Items.Add('2026-06-03  Transfer to 1002     -75.00');
  lstStatement.Items.Add('2026-06-28  Monthly interest       2.10');
  lstStatement.Items.Add('2026-06-30  Closing balance      427.10');
end;

end.
