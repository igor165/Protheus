#ifdef SPANISH
	#define STR0001 "Padrón SISA"
	#define STR0002 "Sistema de Información Simplificado Agrícola SISA"
	#define STR0003 "Esta rutina efectúa la importación del Padrón SISA (archivo txt) y "
	#define STR0004 "actualizando las tablas FX6 y SA2 para su posterior consulta."
	#define STR0005 " * Será requerido acceso exclusivo a la tabla del Padrón (FX6)."
	#define STR0006 "Fecha de generación del padrón actual:  "
	#define STR0007 "Fecha de importación del padrón actual:  "
	#define STR0008 "Usuario: "
	#define STR0009 "Archivo procesado con éxito."
	#define STR0010 "Se encontraron algunos errores durante el proceso."
	#define STR0011 "Verifique el log para mas detalles."
	#define STR0012 "*** Padrón SISA ***"
	#define STR0013 "Aguarde por favor..."
	#define STR0014 "Preparando tablas..."
	#define STR0015 "Archivo: "
	#define STR0016 "ERRO"
	#define STR0017 "Errores encontrados (Ver detalle)."
	#define STR0018 "FIM"
	#define STR0019 "Archivo '"
	#define STR0020 "' procesado con éxito."
	#define STR0021 "Padrón SISA"
	#define STR0022 "Atención! - Padrón SISA"
	#define STR0023 "No se pudo obtener acceso exclusivo a la tabla del Padrón (FX6)."
	#define STR0024 "Cierre las sesiones que puedan tener dicha tabla en uso e intente nuevamente."
	#define STR0025 "Padrón SISA - Selección de archivo..."
	#define STR0026 "Informe ruta y nombre del archivo a procesar"
	#define STR0027 "Seleccionar archivo..."
	#define STR0028 "Informe la ruta y el nombre de archivo a procesar."
	#define STR0029 "Atención!"
	#define STR0030 "No se encontró el archivo especificado. Por favor intente nuevamente."
	#define STR0031 "Atención!"
	#define STR0032 "Estructura de archivo incorrecta."
	#define STR0033 "Fecha de generación no encontrada en la línea: "
	#define STR0034 "Estructura de registro incorrecta."
	#define STR0035 "La cantidad de campos de la línea: "
	#define STR0036 " es menor a: "
	#define STR0037 "La Fecha de generación del Padrón a importar ["
	#define STR0038 "] es anterior o igual a la Fecha de generación del último Padrón importado ["
	#define STR0039 "]. "
	#define STR0040 "¿Desea continuar?"
	#define STR0041 "Procesando archivo '"
	#define STR0042 "': registro "
	#define STR0043 " de "
	#define STR0044 "Estructura de registro incorrecta."
	#define STR0045 "La cantidad de campos de la línea: "
	#define STR0046 " es menor a: "
	#define STR0047 "Fecha de generación del archivo: "
	#define STR0048 "Padrón SISA. Datos de última ejecución."
	#define STR0049 "Modelo de datos del Padrón SISA"
	#define STR0050 "Visualizar"
	#define STR0051 "Importar"
	#define STR0052 "Historial"
	#define STR0053 "Iniciar"
	#define STR0054 "Cerrar"
	#define STR0055 "INICIO"
	#define STR0056 "AxVisual"
#else
	#ifdef ENGLISH
		#define STR0001 "1"
		#define STR0002 "Simplified Agricultural Information System SISA"
		#define STR0003 "This routine imports the SISA Standard (txt register) and"
		#define STR0004 "updating tables FX6 and SA2 for later queries."
		#define STR0005 "* Exclusive access to the Standard table (FX6) will be required."
		#define STR0006 "Date of generation of current standard:"
		#define STR0007 "Date of import of current standard:"
		#define STR0008 "User:"
		#define STR0009 "Register processed successfully."
		#define STR0010 "Errors occurred during the process."
		#define STR0011 "Check log for further information."
		#define STR0012 "*** SISA Standard ***"
		#define STR0013 "Wait..."
		#define STR0014 "Preparing tables..."
		#define STR0015 "Register:"
		#define STR0016 "ERROR"
		#define STR0017 "Errors found (see detail)."
		#define STR0018 "END"
		#define STR0019 "Register ‘"
		#define STR0020 "‘ processed successfully"
		#define STR0021 "SISA Standard"
		#define STR0022 "Attention! - SISA Standard"
		#define STR0023 "Unable to obtain exclusive access to the Standard table (FX6)."
		#define STR0024 "End sessions that may have this table in use and try again."
		#define STR0025 "SISA Standard - Selecting register..."
		#define STR0026 "Enter path and name of register to be processed"
		#define STR0027 "Select register..."
		#define STR0028 "Enter path and name of register to be processed"
		#define STR0029 "Attention!"
		#define STR0030 "Specified register not found. Try again."
		#define STR0031 "Attention!"
		#define STR0032 "Incorrect register structure:"
		#define STR0033 "Generation Date not found in line:"
		#define STR0034 "Incorrect register structure"
		#define STR0035 "The number of fields in the line:"
		#define STR0036 "is lower than:"
		#define STR0037 "Date of generation of standard to import ["
		#define STR0038 "] is earlier than or equal to the date of generation of the last imported Standard ["
		#define STR0039 "]."
		#define STR0040 "Continue?"
		#define STR0041 "Processing register ‘"
		#define STR0042 "‘: register"
		#define STR0043 "of"
		#define STR0044 "Incorrect register structure"
		#define STR0045 "The number of fields in the line:"
		#define STR0046 "is lower than:"
		#define STR0047 "Register generation date:"
		#define STR0048 "SISA Standard. Data of last execution."
		#define STR0049 "SISA Standard data model"
		#define STR0050 "View"
		#define STR0051 "Import"
		#define STR0052 "History"
		#define STR0053 "Start"
		#define STR0054 "Close"
		#define STR0055 "START"
		#define STR0056 "AxVisual"
	#else
		#define STR0001 "Padrão SISA"
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Sistema de Información Simplificado Agrícola SISA", "Sistema de Informação Simplificado Agrícola SISA" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Esta rutina efectúa la importación del Padrón SISA (archivo txt) y ", "Esta rotina efetua a importação do Padrão SISA (cadastro txt) e" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "actualizando las tablas FX6 y SA2 para su posterior consulta.", "atualizando as tabelas FX6 e SA2 para sua posterior consulta." )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", " * Será requerido acceso exclusivo a la tabla del Padrón (FX6).", "* Será requerido o acesso exclusivo à tabela do Padrão (FX6)." )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Fecha de generación del padrón actual:  ", "Data da geração do padrão atual:" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Fecha de importación del padrón actual:  ", "Data de importação do padrão atual:" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Usuario: ", "Usuario:" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Archivo procesado con éxito.", "Cadastro processado com sucesso." )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Se encontraron algunos errores durante el proceso.", "Foram encontrados alguns erros durante o processo." )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Verifique el log para mas detalles.", "Verifique o log para mais detalhes." )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "*** Padrón SISA ***", "*** Padrão SISA ***" )
		#define STR0013 "Aguarde por favor..."
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Preparando tablas...", "Preparando tabelas..." )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Archivo: ", "Cadastro:" )
		#define STR0016 "ERRO"
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Errores encontrados (Ver detalle).", "Errors encontrados (Ver detalhe)." )
		#define STR0018 "FIM"
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Archivo '", "Cadastro '" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "' procesado con éxito.", "' processado com sucesso." )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Padrón SISA", "Padrão SISA" )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "Atención! - Padrón SISA", "Atenção! - Padrão SISA" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "No se pudo obtener acceso exclusivo a la tabla del Padrón (FX6).", "Não foi possível obter acesso exclusivo para a tabela do Padrão (FX6)." )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Cierre las sesiones que puedan tener dicha tabla en uso e intente nuevamente.", "Encerre as sessões que possam ter essa tabela em uso e tente novamente." )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "Padrón SISA - Selección de archivo...", "Padrão SISA - Seleção do cadastro..." )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Informe ruta y nombre del archivo a procesar", "Informe caminho e nome do cadastro a processar" )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Seleccionar archivo...", "Selecionar cadastro..." )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "Informe la ruta y el nombre de archivo a procesar.", "Informe o caminho e o nome do cadastro a processar." )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "Atención!", "Atenção!" )
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "No se encontró el archivo especificado. Por favor intente nuevamente.", "Não foi encontrado o cadastro especificado. Por favor tente novamente." )
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "Atención!", "Atenção!" )
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "Estructura de archivo incorrecta.", "Estrutura do cadastro incorreta." )
		#define STR0033 If( cPaisLoc $ "ANG|PTG", "Fecha de generación no encontrada en la línea: ", "Data da Geração não foi encontrada na linha:" )
		#define STR0034 If( cPaisLoc $ "ANG|PTG", "Estructura de registro incorrecta.", "Estrutura de cadastro incorreta." )
		#define STR0035 If( cPaisLoc $ "ANG|PTG", "La cantidad de campos de la línea: ", "A quantidade de campos da linha:" )
		#define STR0036 If( cPaisLoc $ "ANG|PTG", " es menor a: ", "é menor a:" )
		#define STR0037 If( cPaisLoc $ "ANG|PTG", "La Fecha de generación del Padrón a importar [", "A data de geração do Padrão a importar [" )
		#define STR0038 If( cPaisLoc $ "ANG|PTG", "] es anterior o igual a la Fecha de generación del último Padrón importado [", "] é anterior ou igual à Data de geração do último Padrão importado [" )
		#define STR0039 If( cPaisLoc $ "ANG|PTG", "]. ", "]." )
		#define STR0040 If( cPaisLoc $ "ANG|PTG", "¿Desea continuar?", "Deseja prosseguir?" )
		#define STR0041 If( cPaisLoc $ "ANG|PTG", "Procesando archivo '", "Processando cadastro '" )
		#define STR0042 If( cPaisLoc $ "ANG|PTG", "': registro ", "': registro" )
		#define STR0043 If( cPaisLoc $ "ANG|PTG", " de ", "de" )
		#define STR0044 If( cPaisLoc $ "ANG|PTG", "Estructura de registro incorrecta.", "Estrutura de cadastro incorreta." )
		#define STR0045 If( cPaisLoc $ "ANG|PTG", "La cantidad de campos de la línea: ", "A quantidade de campos da linha:" )
		#define STR0046 If( cPaisLoc $ "ANG|PTG", " es menor a: ", "é menor a:" )
		#define STR0047 If( cPaisLoc $ "ANG|PTG", "Fecha de generación del archivo: ", "Data de geração do cadastro:" )
		#define STR0048 If( cPaisLoc $ "ANG|PTG", "Padrón SISA. Datos de última ejecución.", "Padrão SISA. Dados da última execução." )
		#define STR0049 If( cPaisLoc $ "ANG|PTG", "Modelo de datos del Padrón SISA", "Modelo de dados do Padrão SISA" )
		#define STR0050 "Visualizar"
		#define STR0051 "Importar"
		#define STR0052 If( cPaisLoc $ "ANG|PTG", "Historial", "Histórico" )
		#define STR0053 "Iniciar"
		#define STR0054 If( cPaisLoc $ "ANG|PTG", "Cerrar", "Fechar" )
		#define STR0055 If( cPaisLoc $ "ANG|PTG", "INICIO", "INÍCIO" )
		#define STR0056 "AxVisual"
	#endif
#endif
