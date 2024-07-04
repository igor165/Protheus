#ifdef SPANISH
	#define STR0001 "Atención"
	#define STR0002 "1- Proveedor"
	#define STR0003 "2- Cliente"
	#define STR0004 "3- Ambos"
	#define STR0005 "Padron Jujuy"
	#define STR0006 "Parametros"
	#define STR0007 "Fecha inicial de vigencia"
	#define STR0008 "&Importacion de archivo TXT."
	#define STR0009 "Esta rutina tiene como objetivo importar el Padron RG 1510: "
	#define STR0010 "Régimen General de Percepciones y Retenciones  "
	#define STR0011 "El Padron RG 1510: Padron de contribuyentes no esta disponible"
	#define STR0012 "&Importar"
	#define STR0013 "&Salir"
	#define STR0014 "Leyendo archivo. Espere..."
	#define STR0015 "El archivo"
	#define STR0016 "no es posible abrir"
	#define STR0017 "Seleccionar archivo"
	#define STR0018 "Procesando registros..."
	#define STR0019 "Procesando clientes..."
	#define STR0020 "Procesando Proveedores..."
	#define STR0021 "Actualizando datos..."
	#define STR0022 "Registros actualizados"
	#define STR0023 "No hubo modificaciones en los registros."
	#define STR0024 "El periodo del Padron no coincide con lo informado en los parametros o no informo un periodo valido (Formato AAAAMM)"
	#define STR0025 "Formato de archivo no valido."
	#define STR0026 "Periodo de vigencia"
	#define STR0027 "Tipo de Contribuyente"
#else
	#ifdef ENGLISH
		#define STR0001 "Attention"
		#define STR0002 "1-Supplier"
		#define STR0003 "2-Customer"
		#define STR0004 "3- Both"
		#define STR0005 "Jujuy Standard"
		#define STR0006 "Parameters"
		#define STR0007 "Validity start date"
		#define STR0008 "&TXT register import."
		#define STR0009 "This routine aims at importing the RG 1510 Standard:"
		#define STR0010 "General System of Perception and Withholding"
		#define STR0011 "DR 1510 Standard: Taxpayers standard not available"
		#define STR0012 "&Import"
		#define STR0013 "&Exit"
		#define STR0014 "Reading register. Wait..."
		#define STR0015 "The register"
		#define STR0016 "cannot open"
		#define STR0017 "Select Register"
		#define STR0018 "Processing records..."
		#define STR0019 "Processing customers..."
		#define STR0020 "Processing suppliers..."
		#define STR0021 "Updating data..."
		#define STR0022 "Records updated"
		#define STR0023 "No changes in records."
		#define STR0024 "Default period does not match information entered in parameters or a valid period was not entered (Format YYYYMM)"
		#define STR0025 "Registration format not valid."
		#define STR0026 "Effective Term:"
		#define STR0027 "Taxpayer type"
	#else
		#define STR0001 "Atenção"
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "1- Proveedor", "1- Fornecedor" )
		#define STR0003 "2- Cliente"
		#define STR0004 "3- Ambos"
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Padron Jujuy", "Padrão Jujuy" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Parametros", "Parâmetros" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Fecha inicial de vigencia", "Data Inicial de Vigência" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "&Importacion de archivo TXT.", "&Importação de Cadastro TXT." )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Esta rutina tiene como objetivo importar el Padron RG 1510: ", "Essa rotina tem como objetivo importar o Padrão RG 1510:" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Régimen General de Percepciones y Retenciones  ", "Regime Geral de Percepções e Retenções" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "El Padron RG 1510: Padron de contribuyentes no esta disponible", "O Padrão RG 1510: Padrão de contribuintes não está disponível" )
		#define STR0012 "&Importar"
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "&Salir", "&Sair" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Leyendo archivo. Espere...", "Lendo cadastro. Aguarde..." )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "El archivo", "O cadastro" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "no es posible abrir", "não é possível abrir" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Seleccionar archivo", "Selecionar cadastro" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Procesando registros...", "Processando registros..." )
		#define STR0019 "Procesando clientes..."
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Procesando Proveedores...", "Processando fornecedores..." )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Actualizando datos...", "Atualizando dados..." )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "Registros actualizados", "Registros atualizados" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "No hubo modificaciones en los registros.", "Não aconteceram alterações nos registros." )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "El periodo del Padron no coincide con lo informado en los parametros o no informo un periodo valido (Formato AAAAMM)", "O período do Padrão não coincide com o informado nos parâmetros ou não foi informado um período válido (Formato AAAAMM)" )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "Formato de archivo no valido.", "Formato de cadastro inválido." )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Periodo de vigencia", "Período de Vigência" )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Tipo de Contribuyente", "Tipo de Contribuinte" )
	#endif
#endif
