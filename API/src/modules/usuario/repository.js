import pool from "../../core/database/pool.js";

const UsuarioRepository = {
  async create(user) {
    return await pool.execute(
      `INSERT INTO usuario(nome, email, senha, funcao, telefone) VALUES (?, ?, ?, ?, ?);`,
      [user.nome, user.email, user.senha, user.funcao, user.telefone],
    );
  },

  async getAll() {
    const [users] = await pool.execute(`SELECT * FROM usuario;`);
    return users;
  },
};

export default UsuarioRepository;
