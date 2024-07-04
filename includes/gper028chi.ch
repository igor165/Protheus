#ifdef SPANISH
	#define STR0001 "¡El archivo de nombre"
	#define STR0002 "no se puede crear! Verifique el archivo."
	#define STR0003 "¡Atención!"
	#define STR0004 "No existen conceptos para los parámetros informados."
	#define STR0005 "No existen períodos válidos para el período informado."
	#define STR0006 "Ocurrió un error en la grabación del archivo. ¿Continua?"
	#define STR0007 "generado con éxito!"
	#define STR0008 "Por favor, espere...."
	#define STR0009 "Generando el archivo .txt"
	#define STR0010 "Procesando empleado: "
	#define STR0011 "Archivo"
	#define STR0012 "No existe información con estos parámetros."
	#define STR0013 "No se configuró el máximo imponible AFC para el período en proceso. Verifique las tablas S002 y S005"
#else
	#ifdef ENGLISH
		#define STR0001 "File named"
		#define STR0002 "cannot be created! Check file."
		#define STR0003 "Attention!"
		#define STR0004 "There are no budgets for parameters entered."
		#define STR0005 "There are no valid periods for the period entered."
		#define STR0006 "There was an error saving the file. Proceed?"
		#define STR0007 "successfully generated!"
		#define STR0008 "Please, wait..."
		#define STR0009 "Generating .txt file"
		#define STR0010 "Processing employee:"
		#define STR0011 "File"
		#define STR0012 "There are no information with these parameters."
		#define STR0013 "The maximum taxable AFC for the period in process was not configured. Check the S002 and S005 tables"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "¡El archivo de nombre", "O arquivo chamado" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "no se puede crear! Verifique el archivo.", "não pode ser criado! Verifique o arquivo." )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "¡Atención!", "Atenção!" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "No existen conceptos para los parámetros informados.", "Não existem verbas para os parâmetros informados." )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "No existen períodos válidos para el período informado.", "Não existem períodos válidos para o período informado." )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Ocurrió un error en la grabación del archivo. ¿Continua?", "Ocorreu um erro na gravação do arquivo. Prosseguir?" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "generado con éxito!", "gerado com sucesso!" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Por favor, espere....", "Por favor, aguarde..." )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Generando el archivo .txt", "Gerando o arquivo .txt" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Procesando empleado: ", "Processando funcionário:" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Archivo", "Arquivo" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "No existe información con estos parámetros.", "Não existem informações com esses parâmetros." )
		#define STR0013 "Não foi configurado o máximo tributável AFC para o período em processo. Verifique as tabelas S002 e S005"
	#endif
#endif
