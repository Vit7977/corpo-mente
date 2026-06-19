-- ============================================================
--  Corpo & Mente — banco de dados
--  Criado com: MySQL 8+
-- ============================================================

DROP DATABASE IF EXISTS corpoemente;
CREATE DATABASE corpoemente
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE corpoemente;

-- ------------------------------------------------------------
--  1. usuario
-- ------------------------------------------------------------
CREATE TABLE usuario (
    id                  INT UNSIGNED     PRIMARY KEY AUTO_INCREMENT,
    nome                VARCHAR(100)     NOT NULL,
    email               VARCHAR(254)     NOT NULL UNIQUE,
    senha               VARCHAR(255)     NOT NULL,
    funcao              ENUM('user', 'admin_parceiro', 'admin')
                                         NOT NULL DEFAULT 'user',
    telefone            VARCHAR(20)      NULL,
    ativo               BOOLEAN          NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                         ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_usuario_funcao (funcao)
);

-- ------------------------------------------------------------
--  2. parceiro
-- ------------------------------------------------------------
CREATE TABLE parceiro (
    id              INT UNSIGNED     PRIMARY KEY AUTO_INCREMENT,
    usuario_id      INT UNSIGNED     NOT NULL,
    tipo            ENUM('academia', 'terapeuta', 'clinica')
                                     NOT NULL DEFAULT 'academia',
    nome_empresa    VARCHAR(100)     NOT NULL,
    descricao       TEXT             NULL,           -- sem limite arbitrário de 255
    cep             CHAR(8)          NOT NULL,        -- sempre 8 dígitos
    endereco        VARCHAR(255)     NOT NULL,        -- preenchido via BrasilAPI
    cidade          VARCHAR(100)     NOT NULL,        -- preenchido via BrasilAPI
    estado          CHAR(2)          NOT NULL,        -- preenchido via BrasilAPI
    ativo           BOOLEAN          NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                     ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY fk_parceiro_usuario (usuario_id)
        REFERENCES usuario (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ------------------------------------------------------------
--  3. licenca
-- ------------------------------------------------------------
CREATE TABLE licenca (
    id              INT UNSIGNED     PRIMARY KEY AUTO_INCREMENT,
    parceiro_id     INT UNSIGNED     NOT NULL,
    status          ENUM('ativo', 'suspenso', 'cancelado')
                                     NOT NULL DEFAULT 'ativo',
    iniciado_em     DATE             NOT NULL DEFAULT (CURRENT_DATE),
    acaba_em        DATE             NULL,
    taxa_mensal     DECIMAL(8, 2)    NOT NULL,
    created_at      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                     ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY fk_licenca_parceiro (parceiro_id)
        REFERENCES parceiro (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    INDEX idx_licenca_status (status)
);

-- ------------------------------------------------------------
--  4. plano
-- ------------------------------------------------------------
CREATE TABLE plano (
    id              INT UNSIGNED     PRIMARY KEY AUTO_INCREMENT,
    parceiro_id     INT UNSIGNED     NOT NULL,
    nome            VARCHAR(100)     NOT NULL,
    descricao       TEXT             NOT NULL,
    tipo            ENUM('academia', 'terapia', 'especializado')
                                     NOT NULL DEFAULT 'academia',
    preco           DECIMAL(8, 2)    NOT NULL,       -- suporta até 999.999,99
    validade_dias   INT UNSIGNED     NOT NULL DEFAULT 30,
    ativo           BOOLEAN          NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                     ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY fk_plano_parceiro (parceiro_id)
        REFERENCES parceiro (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    INDEX idx_plano_tipo (tipo),
    INDEX idx_plano_ativo (ativo)
);

-- ------------------------------------------------------------
--  5. combo
--     Liga um plano de academia a um plano de terapia.
--     Os dois parceiros podem ser diferentes (um de cada).
-- ------------------------------------------------------------
CREATE TABLE combo (
    id                  INT UNSIGNED     PRIMARY KEY AUTO_INCREMENT,
    plano_academia_id   INT UNSIGNED     NOT NULL,
    plano_terapia_id    INT UNSIGNED     NOT NULL,
    preco               DECIMAL(8, 2)    NOT NULL,
    desconto_pct        DECIMAL(5, 2)    NOT NULL,   -- percentual: ex. 15.00 = 15%
    ativo               BOOLEAN          NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                         ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY fk_combo_academia (plano_academia_id)
        REFERENCES plano (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    FOREIGN KEY fk_combo_terapia (plano_terapia_id)
        REFERENCES plano (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ------------------------------------------------------------
--  6. assinatura
--     plano_id XOR combo_id — exatamente um deve ser preenchido.
--     A constraint CHECK garante isso no banco.
-- ------------------------------------------------------------
CREATE TABLE assinatura (
    id              INT UNSIGNED     PRIMARY KEY AUTO_INCREMENT,
    usuario_id      INT UNSIGNED     NOT NULL,
    plano_id        INT UNSIGNED     NULL,
    combo_id        INT UNSIGNED     NULL,
    status          ENUM('ativo', 'pausado', 'cancelado', 'expirado')
                                     NOT NULL DEFAULT 'ativo',
    iniciado_em     TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    acaba_em        DATE             NULL,
    quantia_paga    DECIMAL(8, 2)    NOT NULL,
    created_at      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                     ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY fk_assinatura_usuario (usuario_id)
        REFERENCES usuario (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    FOREIGN KEY fk_assinatura_plano (plano_id)
        REFERENCES plano (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    FOREIGN KEY fk_assinatura_combo (combo_id)
        REFERENCES combo (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    INDEX idx_assinatura_status (status),
    INDEX idx_assinatura_usuario (usuario_id)
);

-- ------------------------------------------------------------
--  7. pagamento
-- ------------------------------------------------------------
CREATE TABLE pagamento (
    id              INT UNSIGNED     PRIMARY KEY AUTO_INCREMENT,
    assinatura_id   INT UNSIGNED     NOT NULL,
    preco           DECIMAL(8, 2)    NOT NULL,
    status          ENUM('pendente', 'pago', 'falha', 'reembolsado')
                                     NOT NULL DEFAULT 'pendente',
    metodo          ENUM('credito', 'pix', 'boleto')
                                     NOT NULL DEFAULT 'pix',
    gateway_tx_id   VARCHAR(100)     NULL UNIQUE,    -- ID da transação no gateway
    pago_em         TIMESTAMP        NULL,
    created_at      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY fk_pagamento_assinatura (assinatura_id)
        REFERENCES assinatura (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    INDEX idx_pagamento_status (status)
);

-- ------------------------------------------------------------
--  8. agendamento
-- ------------------------------------------------------------
CREATE TABLE agendamento (
    id              INT UNSIGNED     PRIMARY KEY AUTO_INCREMENT,
    usuario_id      INT UNSIGNED     NOT NULL,
    parceiro_id     INT UNSIGNED     NOT NULL,
    assinatura_id   INT UNSIGNED     NOT NULL,
    agendado_em     DATETIME         NOT NULL,
    duracao_min     INT UNSIGNED     NOT NULL DEFAULT 60,
    status          ENUM('agendado', 'confirmado', 'realizado', 'cancelado')
                                     NOT NULL DEFAULT 'agendado',
    observacoes     TEXT             NULL,
    created_at      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                     ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY fk_agendamento_usuario (usuario_id)
        REFERENCES usuario (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    FOREIGN KEY fk_agendamento_parceiro (parceiro_id)
        REFERENCES parceiro (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    FOREIGN KEY fk_agendamento_assinatura (assinatura_id)
        REFERENCES assinatura (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    INDEX idx_agendamento_data (agendado_em),
    INDEX idx_agendamento_status (status)
);

-- ------------------------------------------------------------
--  9. avaliacao
--     Vinculada à assinatura para garantir que só quem
--     contratou pode avaliar.
-- ------------------------------------------------------------
CREATE TABLE avaliacao (
    id              INT UNSIGNED     PRIMARY KEY AUTO_INCREMENT,
    usuario_id      INT UNSIGNED     NOT NULL,
    parceiro_id     INT UNSIGNED     NOT NULL,
    assinatura_id   INT UNSIGNED     NOT NULL,
    nota            TINYINT UNSIGNED NOT NULL,
    comentario      TEXT             NULL,
    created_at      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_nota CHECK (nota BETWEEN 1 AND 5),
    UNIQUE KEY uq_avaliacao (usuario_id, assinatura_id),
    FOREIGN KEY fk_avaliacao_usuario (usuario_id)
        REFERENCES usuario (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY fk_avaliacao_parceiro (parceiro_id)
        REFERENCES parceiro (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY fk_avaliacao_assinatura (assinatura_id)
        REFERENCES assinatura (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ------------------------------------------------------------
--  10. notificacao
-- ------------------------------------------------------------
CREATE TABLE notificacao (
    id          INT UNSIGNED     PRIMARY KEY AUTO_INCREMENT,
    usuario_id  INT UNSIGNED     NOT NULL,
    titulo      VARCHAR(100)     NOT NULL,
    corpo       TEXT             NOT NULL,
    tipo        ENUM('lembrete', 'pagamento', 'promocao', 'sistema')
                                 NOT NULL DEFAULT 'sistema',
    lido        BOOLEAN          NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY fk_notificacao_usuario (usuario_id)
        REFERENCES usuario (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    INDEX idx_notificacao_lido (usuario_id, lido)
);