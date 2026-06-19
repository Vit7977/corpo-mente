import z from "zod";

export const createUserDTO = z.object({
  nome: z
    .string()
    .trim()
    .min(3, { message: "O nome de usuário deve conter ao menos 3 caracteres!" })
    .max(30, {
      message: "O máximo de caracteres para nome de usuário é de 30!",
    }),
  email: z.email({ message: "O email deve ser válido!" }),
  senha: z
    .string()
    .min(6, { message: "A senha deve conter no mínimo 6 caracteres!" })
    .regex(/^(?=.*[A-Z])(?=.*\d).+$/, {
      message:
        "A senha deve conter pelo menos uma letra maiúscula e um número!",
    }),
  funcao: z.enum(["user", "admin_parceiro", "admin"], {
    message: "Função inválida!",
  }),
  telefone: z.string().regex(/^\d{10,11}$/, {
    message: "Telefone deve conter 10 ou 11 dígitos!",
  }),
});
