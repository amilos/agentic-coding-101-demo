unit uMainForm;

{ NorthBank statement viewer (Win64 VCL).

  Minimal stubbed screen used for the Appium/WinAppDriver UI-automation demo.
  Controls expose stable UI Automation IDs:
   1001 - account number entry
   1002 - loads the statement
   1003 - the resulting statement lines }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfrmMain = class(TForm)
  private
    procedure AssignAutomationId(Control: TWinControl; ControlId: NativeInt);
    procedure CreateControls;
    procedure btnLoadClick(Sender: TObject);
  public
    edtAccountId: TEdit;
    btnLoad: TButton;
    lstStatement: TListBox;
    lblAccountId: TLabel;
    constructor Create(AOwner: TComponent); override;
  end;

var
  frmMain: TfrmMain;

implementation

const
  AccountIdEditAutomationId = 1001;
  LoadButtonAutomationId = 1002;
  StatementListAutomationId = 1003;

constructor TfrmMain.Create(AOwner: TComponent);
begin
  // CreateNew avoids loading the legacy DFM resource.
  inherited CreateNew(AOwner);

  Caption := 'NorthBank Statement Viewer';
  ClientHeight := 320;
  ClientWidth := 480;
  Color := clBtnFace;
  Font.Name := 'Segoe UI';
  Font.Height := -12;

  CreateControls;
end;

procedure TfrmMain.AssignAutomationId(Control: TWinControl; ControlId: NativeInt);
begin
  // UI Automation exposes a Win32 child window's control ID as AutomationId.
  // Source: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowlongptrw
  SetWindowLongPtr(Control.Handle, GWLP_ID, ControlId);
end;

procedure TfrmMain.CreateControls;
begin
  lblAccountId := TLabel.Create(Self);
  lblAccountId.Name := 'lblAccountId';
  lblAccountId.Parent := Self;
  lblAccountId.SetBounds(16, 19, 62, 15);
  lblAccountId.Caption := 'Account id:';

  edtAccountId := TEdit.Create(Self);
  edtAccountId.Name := 'edtAccountId';
  edtAccountId.Parent := Self;
  edtAccountId.SetBounds(88, 16, 200, 23);
  edtAccountId.TabOrder := 0;
  AssignAutomationId(edtAccountId, AccountIdEditAutomationId);
  lblAccountId.FocusControl := edtAccountId;

  btnLoad := TButton.Create(Self);
  btnLoad.Name := 'btnLoad';
  btnLoad.Parent := Self;
  btnLoad.SetBounds(304, 15, 75, 25);
  btnLoad.Caption := 'Load';
  btnLoad.TabOrder := 1;
  btnLoad.OnClick := btnLoadClick;
  AssignAutomationId(btnLoad, LoadButtonAutomationId);

  lstStatement := TListBox.Create(Self);
  lstStatement.Name := 'lstStatement';
  lstStatement.Parent := Self;
  lstStatement.SetBounds(16, 56, 448, 248);
  lstStatement.ItemHeight := 15;
  lstStatement.TabOrder := 2;
  AssignAutomationId(lstStatement, StatementListAutomationId);
end;

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
