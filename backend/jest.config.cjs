/** @type {import('jest').Config} */
// The MongoDB driver loads Node built-ins with a dynamic import. Jest's VM
// only allows that when the test script is started with --experimental-vm-modules.
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/tests'],
  setupFiles: ['<rootDir>/tests/setup-env.cjs'],
  clearMocks: true,
  testTimeout: 120000,
};
