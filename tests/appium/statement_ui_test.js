// Appium + WinAppDriver UI test for the NorthBank StatementViewer (Win32 VCL).
//
// Prerequisites (Windows only):
//   1. WinAppDriver running:  C:\Program Files\Windows Application Driver\WinAppDriver.exe
//   2. StatementViewer.exe built from ui/StatementViewer.dpr.
//
// Update APP_PATH and the automation ids below to match your build. VCL
// controls are exposed by their Name property (edtAccountId, btnLoad,
// lstStatement); WinAppDriver can target them with accessibility id.

const { remote } = require('webdriverio');
const assert = require('assert');

// TODO: point this at your local build of the app.
const APP_PATH = 'C:\\\\NorthBank\\\\StatementViewer.exe';

const capabilities = {
  platformName: 'Windows',
  'appium:automationName': 'Windows',
  'appium:app': APP_PATH,
};

describe('NorthBank StatementViewer', function () {
  let client;

  before(async function () {
    client = await remote({
      hostname: '127.0.0.1',
      port: 4723,
      path: '/',
      capabilities,
    });
  });

  after(async function () {
    if (client) {
      await client.deleteSession();
    }
  });

  it('loads a statement for account 1001', async function () {
    // Automation ids map to the VCL control Names.
    const accountId = await client.$('~edtAccountId');
    await accountId.setValue('1001');

    const loadButton = await client.$('~btnLoad');
    await loadButton.click();

    const statement = await client.$('~lstStatement');
    const text = await statement.getText();

    assert.ok(text.length > 0, 'Statement list should be populated');
    assert.ok(text.includes('1001'), 'Statement should reference account 1001');
  });
});
