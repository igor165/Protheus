#ifdef SPANISH
	#define STR0001 "No se identificó la configuración mínima para la generación del MAPAS. Configure el parámetro MV_PRODPF con el campo de la SB5 responsable por la identificación de Productos químicos controlados."
	#define STR0002 "Ocurrió un error en el intento de la generación del archivo magnético. Verifique los parámetros pertinentes e intente nuevamente. Código del error:"
	#define STR0003 "Configuración del encabezado de mapas (Sección EM) incorrecta. La configuración debe tener 8 caracteres '0' o '1'. Ej.: 10101100"
#else
	#ifdef ENGLISH
		#define STR0001 "The minimum configuration for MAPS generation was not identified. Set the MV_PRODPF parameter with the SB5 field responsible for identifying Controlled Chemicals."
		#define STR0002 "There was an error trying to create the magnetic file. Check the relevant parameters and try again. Error code:"
		#define STR0003 "Map Header setting (EM Section) is incorrect. The setting must have 8 characters ‘0’ or ‘1’. Ex: 10101100"
	#else
		#define STR0001 "Não foi identificada a configuração mínima para a geração do MAPAS. Configure o parâmetro MV_PRODPF com o campo da SB5 responsável pela identificação de Produtos Químicos Controlados."
		#define STR0002 "Ocorreu um erro na tentativa da geração do arquivo magnético. Verifique os parâmetros pertinentes e tente novamente. Código do erro: "
		#define STR0003 "Configuração do Cabeçalho Mapas (Seção EM) incorreta. A configuração deve possuir 8 caracteres '0' ou '1'. Ex: 10101100"
	#endif
#endif
