#ifdef SPANISH
	#define STR0001 "Atención"
	#define STR0002 "OK"
	#define STR0003 "OK"
	#define STR0004 "Cancelación de TFD"
	#define STR0005 "Faltan parámetros por definir para este proceso"
	#define STR0006 "No existe el cliente de servicio web:"
	#define STR0007 ", no es posible continuar con el timbrado."
	#define STR0008 "Ocurrió un error al ejecutar la cancelación..."
	#define STR0009 ", no se canceló el timbre fiscal..."
	#define STR0010 "No se encontró el CFDi "
	#define STR0011 "Ocurrió un error al intentar convertir el archivo .cer a base64..."
	#define STR0012 "Ocurrió un error al intentar convertir el archivo .key a base64..."
	#define STR0013 "Ocurrió un error al ejecutar la cancelación: "
	#define STR0014 "No fue posible abrir el archivo .out"
	#define STR0015 "Estructura xml no válida del CFDi "
	#define STR0016 "Cancelación de TFD. "
	#define STR0017 "Tabla de encabezado/Documento no válidos."
	#define STR0018 "No es posible crear archivo temporal en la ruta "
#else
	#ifdef ENGLISH
		#define STR0001 "Attention"
		#define STR0002 "OK"
		#define STR0003 "OK"
		#define STR0004 "TFD cancellation"
		#define STR0005 "There are no parameters enough to define this process"
		#define STR0006 "No web service client:"
		#define STR0007 ", unable to continue stamping."
		#define STR0008 "An error occurred while canceling..."
		#define STR0009 ", fiscal stamp not canceled..."
		#define STR0010 "CFDi not found."
		#define STR0011 "An error occurred when converting file .cer to base64..."
		#define STR0012 "An error occurred when converting file .key to base64..."
		#define STR0013 "An error occurred while canceling:"
		#define STR0014 "Unable to open .out file"
		#define STR0015 "XML structure of CFDi invalid"
		#define STR0016 "TFD Cancellation."
		#define STR0017 "Invalid header/document table."
		#define STR0018 "Unable to create a temporary file in the path"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Atención", "Atenção" )
		#define STR0002 "OK"
		#define STR0003 "OK"
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Cancelación de TFD", "Cancelamento de TFD" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Faltan parámetros por definir para este proceso", "Faltam parâmetros a definir para este processo" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "No existe el cliente de servicio web:", "Não existe o cliente de serviço web:" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", ", no es posible continuar con el timbrado.", ", não é possível prosseguir com a selagem." )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Ocurrió un error al ejecutar la cancelación...", "Ocorreu um erro ao executar o cancelamento..." )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", ", no se canceló el timbre fiscal...", ", não foi cancelado o selo fiscal..." )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "No se encontró el CFDi ", "Não foi encontrado o CFDi." )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Ocurrió un error al intentar convertir el archivo .cer a base64...", "Ocorreu um erro ao tentar converter o arquivo .cer para base64..." )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Ocurrió un error al intentar convertir el archivo .key a base64...", "Ocorreu um erro ao tentar converter o arquivo .key a base64..." )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Ocurrió un error al ejecutar la cancelación: ", "Ocorreu um erro ao executar o cancelamento:" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "No fue posible abrir el archivo .out", "Não foi possível abrir o arquivo .out" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Estructura xml no válida del CFDi ", "Estrutura xml do CFDi inválida" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Cancelación de TFD. ", "Cancelamento de TFD." )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Tabla de encabezado/Documento no válidos.", "Tabela de cabeçalho/Documento inválidos." )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "No es posible crear archivo temporal en la ruta ", "Não é possível criar um arquivo temporário no caminho" )
	#endif
#endif
