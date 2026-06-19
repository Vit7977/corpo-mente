const sendResponse = (res, {
  success = true,
  status = 200,
  message = "Operação realizada com sucesso",
  error = null,
  data = null,
  quant = null
} = {}) => {
  return res.status(status).json({
    success,
    status,
    message,
    error,
    data,
    quant: Array.isArray(data) ? data.length : quant ?? (data ? 1 : 0)
  });
};


export const success = (res, { message = "Operação realizada com sucesso", data = null } = {}) => {
  return sendResponse(res, { success: true, status: 200, message, data });
};


export const created = (res, { message = "Recurso criado com sucesso", data = null } = {}) => {
  return sendResponse(res, { success: true, status: 201, message, data });
};


export const noContent = (res, { message = "Operação concluída" } = {}) => {
  return sendResponse(res, { success: true, status: 202, message, data: null, quant: 0 });
};


export const notFound = (res, { message = "Recurso não encontrado", error=null } = {}) => {
  return sendResponse(res, { success: false, status: 404, message, error, data: null, quant: 0 });
};

export const invalidToken = (res, { message = "Token inválido ou expirado", error=null } = {}) => {
  return sendResponse(res, { success: false, status: 498, message, error, data: null, quant: 0 });
};

export const badRequest = (res, { message = "Requisição inválida - conteúdo do body não fornecido", error=null } = {}) => {
  return sendResponse(res, { success: false, status: 400, message, error, data: null, quant: 0 });
};

export const unauthorized = (res, { message = "Credenciais inválidas", error=null } = {}) => {
  return sendResponse(res, { success: false, status: 401, message, error, data: null, quant: 0 });
};

export const conflict = (res, { message = "Conflito de dados", error=null } = {}) => {
  return sendResponse(res, { success: false, status: 409, message, error, data: null, quant: 0 });
}

export const forbidden = (res, { message = "Acesso negado", error=null } = {}) => {
  return sendResponse(res, { success: false, status: 403, message, error, data: null, quant: 0 });
};

export const error = (res, { status = 500, message = "Erro interno do servidor", data = null, error=null } = {}) => {  
  return sendResponse(res, { success: false, status, message, error, data });
};