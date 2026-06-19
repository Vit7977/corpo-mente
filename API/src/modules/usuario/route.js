import { Router } from "express";
import UsuarioController from "./controller.js";
import { createUserDTO } from "./dto.js";
import { validate } from "../../core/middlewares/validate.js";

const router = Router();

router.get("/", UsuarioController.getAll);
// router.get("/:id");
// router.get("/auth/validate");

router.post("/", validate(createUserDTO), UsuarioController.create);
// router.post("/login");
// router.put("/:id");
// router.delete("/:id");

export default router;
