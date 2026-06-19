import UsuarioService from "./service.js";
import * as response from "../../core/utils/responses.js";

const UsuarioController = {
  async create(req, res) {
    try {
      await UsuarioService.create(req.body);
      return response.created(res, {
        message: "Usuario criado com sucesso!",
      });
    } catch (error) {
      return response.error(res, {
        message: "Erro interno no servidor!",
        error: error.message,
      });
    }
  },

  async getAll(req, res) {
    try {
      const data = await UsuarioService.getAll();
      return response.success(res, {
        message: "Usuarios consultados com sucesso!",
        data,
      });
    } catch (error) {
      return response.error(res, {
        message: "Erro interno no servidor!",
        error: error.message,
      });
    }
  },
};

export default UsuarioController;
