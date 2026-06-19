import UsuarioRepository from "./repository.js";
import { hashPass, validatePass } from "../../core/utils/passUtils.js";

const UsuarioService = {
  async create(data) {
    const hashedPass = await hashPass(data.senha);

    const user = {
      ...data,
      senha: hashedPass,
    };
    return await UsuarioRepository.create(user);
  },

  async getAll() {
    return await UsuarioRepository.getAll();
  },
};

export default UsuarioService;
