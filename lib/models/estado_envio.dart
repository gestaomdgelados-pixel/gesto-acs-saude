enum EstadoEnvio { enviado, recebido, visto }

EstadoEnvio estadoEnvio(DateTime? recebido, DateTime? visto) => visto != null
    ? EstadoEnvio.visto
    : recebido != null
        ? EstadoEnvio.recebido
        : EstadoEnvio.enviado;
