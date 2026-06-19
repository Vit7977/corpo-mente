export const dbConfig = {
  host: process.env.DB_HOST ?? "localhost",
  name: process.env.DB_NAME ?? "corpoemente",
  user: process.env.DB_USER ?? "root",
  pass: process.env.DB_PASS ?? "",
};
