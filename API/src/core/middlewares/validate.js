export const validate =
  (schema, property = "body") =>
  (req, res, next) => {
    try {
      const parsed = schema.safeParse(req[property]);

      if (!parsed.success) {
        return res.status(400).json({
          message: "Erro de validação!",
          error: {
            path: parsed.error.issues[0].path[0],
            message: parsed.error.issues[0].message,
          },
        });
      }

      req[property] = parsed.data;
      next();
    } catch (error) {
      return res.status(400).json({
        message: "Erro de validação!",
        error: error.issues.map((err) => ({
          path: err.path[0],
          message: err.message,
        }))[0],
      });
    }
  };