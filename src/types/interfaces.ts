/**
 * Interfaces de dominio compartidas.
 * Fuente: MODELO_DATOS_v3.md · CONTRATO_API_v4.md
 */

export interface UsuarioAutenticado {
  id: string;
  email: string;
  perfil: string;
  nombre: string;
}

export interface IAContexto {
  caso: {
    radicado: string;
    delito_imputado: string;
    etapa_procesal: string;
    regimen_procesal: string;
  };
  herramienta: string;
  datos: Record<string, unknown>;
}

export interface IARespuesta {
  contenido: string;
  tokens_entrada: number;
  tokens_salida: number;
  modelo_usado: string;
  duracion_ms: number;
}
