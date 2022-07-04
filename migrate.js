require("dotenv").config();

const { SlonikMigrator } = require("@slonik/migrator");
const { createPool } = require("slonik");

const slonik = createPool(process.env.DB_CONNECT);

const migrator = new SlonikMigrator({
  migrationsPath: __dirname + "/migrations",
  migrationTableName: "migration",
  slonik,
});

migrator.runAsCLI();
