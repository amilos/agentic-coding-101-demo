// Appium + NovaWindows UI test for the NorthBank StatementViewer (Win64 VCL).
//
// Prerequisites (Windows only):
//   1. Appium 3 running with appium-novawindows-driver installed.
//   2. StatementViewer.exe built from ui/StatementViewer.dpr.
//
// The NovaWindows driver supports XPath locators over UI Automation attributes:
// https://github.com/AutomateThePlanet/appium-novawindows-driver#element-location

const { remote } = require('webdriverio');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const APP_PATH = process.env.STATEMENT_VIEWER_PATH
  || path.resolve(__dirname, '..', '..', 'ui', 'StatementViewer.exe');

const automationId = {
  accountIdInput: '1001',
  loadButton: '1002',
  statementList: '1003',
};

const capabilities = {
  platformName: 'Windows',
  'appium:automationName': 'NovaWindows',
  'appium:app': APP_PATH,
  'appium:appWorkingDir': path.dirname(APP_PATH),
  'appium:shouldCloseApp': true,
};

describe('NorthBank StatementViewer', function () {
  let client;

  before(async function () {
    if (!fs.existsSync(APP_PATH)) {
      throw new Error(
        `StatementViewer executable was not found at "${APP_PATH}". `
        + 'Build ui/StatementViewer.dpr or set STATEMENT_VIEWER_PATH.'
      );
    }

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
    const accountId = await client.$(`~${automationId.accountIdInput}`);
    await accountId.clearValue();
    await accountId.setValue('1001');

    const loadButton = await client.$(`~${automationId.loadButton}`);
    await loadButton.click();

    const statementItems = `//*[@AutomationId="${automationId.statementList}"]/ListItem`;
    await client.waitUntil(async () => (await client.$$(statementItems)).length > 0, {
      timeout: 5000,
      interval: 100,
      timeoutMsg: 'Statement list was not populated after loading account 1001.',
    });

    const items = await client.$$(statementItems);
    assert.ok(items.length > 0, 'Statement list should be populated');

    const accountStatement = await client.$(
      `//*[@AutomationId="${automationId.statementList}"]`
      + '/ListItem[@Name="Statement for account 1001"]'
    );
    assert.ok(await accountStatement.isExisting(), 'Statement should reference account 1001');
  });
});
