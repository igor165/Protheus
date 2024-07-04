#ifdef SPANISH
	#define STR0001 "Atención"
	#define STR0002 "1- Proveedor"
	#define STR0003 "2- Cliente"
	#define STR0004 "3- Ambos"
	#define STR0005 "RN 36/2019 - Régimen de Retenciones y Percepciones – Cordoba"
	#define STR0006 "Inf. Preliminar"
	#define STR0007 "Archivo"
	#define STR0008 "Impuesto: "
	#define STR0009 "Percepción"
	#define STR0010 "Retención"
	#define STR0011 "Importación de archivo TXT"
	#define STR0012 "Esta opción tiene como objetivo actualizar el archivo "
	#define STR0013 "Proveedor / Cliente vs. Impuesto, de acuerdo con el archivo TXT "
	#define STR0014 "Puesto a disposición por el gobierno "
	#define STR0015 "Informe el período:"
	#define STR0016 "Importar"
	#define STR0017 "Resumen"
	#define STR0018 "Salir"
	#define STR0019 "Leyendo archivo, espere..."
	#define STR0020 "Actualización de alícuotas"
	#define STR0021 "Período informado no corresponde al período del archivo ("
	#define STR0022 "Período"
	#define STR0023 "El archivo"
	#define STR0024 " no puede abrirse."
	#define STR0025 "¡Archivo importado!"
	#define STR0026 "Este tipo de importación solamente es compatible con la base de datos MSSQL."
	#define STR0027 "Seleccionar archivo"
	#define STR0028 "Este archivo no existe o el servidor SQL no consigue abrirlo, utilice un archivo que se encuentre en la máquina de su servidor SQL o una dirección de red a la que pueda accederse por el servidor SQL."
	#define STR0029 "Ocurrió un error al procesar el archivo seleccionado. Verifique si el contenido está correcto e intente nuevamente."
	#define STR0030 "Ocurrió un error al procesar el archivo seleccionado, verifique si el archivo existe en el servidor SQL, así como su contenido, e intente nuevamente."
	#define STR0031 "Seleccione un archivo e intente nuevamente."
	#define STR0032 "¡Archivo no importado!"
#else
	#ifdef ENGLISH
		#define STR0001 "Attention"
		#define STR0002 "1-Supplier"
		#define STR0003 "2-Customer"
		#define STR0004 "3- Both"
		#define STR0005 "RN 36/2019 - Withholdings and Perceptions System - Cordova"
		#define STR0006 "Inf. Preliminary"
		#define STR0007 "Register"
		#define STR0008 "Tax:"
		#define STR0009 "Perception"
		#define STR0010 "Withholding"
		#define STR0011 "TXT file import"
		#define STR0012 "This option aims at updating the register"
		#define STR0013 "Tax in accordance with CSV register"
		#define STR0014 "Made available by Government,"
		#define STR0015 "Enter the period:"
		#define STR0016 "Import"
		#define STR0017 "Summary"
		#define STR0018 "Exit"
		#define STR0019 "Reading register. Wait..."
		#define STR0020 "Rate update"
		#define STR0021 "Period entered does not match the period of the register ("
		#define STR0022 "Period"
		#define STR0023 "The register"
		#define STR0024 "cannot be opened."
		#define STR0025 "Register imported"
		#define STR0026 "This type of import is compatible only with the MSSQL database"
		#define STR0027 "Select Register"
		#define STR0028 "This register does not exist or it cannot be opened by your SQL server. Use a register that is in the machine of your SQL server or a network address that can be accessed by the SQL server."
		#define STR0029 "An error occurred while processing a register. Check whether the content is correct and try again."
		#define STR0030 "Error processing the selected register. Check whether the register is in the SQL server, as well as its content, and try again."
		#define STR0031 "Select a register and try again."
		#define STR0032 "Register not imported!"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Atención", "Atenção" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "1- Proveedor", "1- Fornecedor" )
		#define STR0003 "2- Cliente"
		#define STR0004 "3- Ambos"
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "RN 36/2019 - Régimen de Retenciones y Percepciones – Cordoba", "RN 36/2019 - Regime de Retenções e Percepções - Córdova" )
		#define STR0006 "Inf. Preliminar"
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Archivo", "Cadastro" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Impuesto: ", "Imposto:" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Percepción", "Perceção" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Retención", "Retenção" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Importación de archivo TXT", "Importação de arquivo TXT" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Esta opción tiene como objetivo actualizar el archivo ", "Esta opção tem como objetivo atualizar o cadastro" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Proveedor / Cliente vs. Impuesto, de acuerdo con el archivo TXT ", "Imposto conforme o cadastro CSV" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Puesto a disposición por el gobierno ", "Disponibilizado pelo governo" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Informe el período:", "Informe o período:" )
		#define STR0016 "Importar"
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Resumen", "Resumo" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Salir", "Sair" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Leyendo archivo, espere...", "Lendo cadastro, aguarde..." )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Actualización de alícuotas", "Atualização de alíquotas" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Período informado no corresponde al período del archivo (", "Período informado não corresponde ao período do cadastro (" )
		#define STR0022 "Período"
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "El archivo", "O cadastro" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", " no puede abrirse.", "não pode ser aberto." )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "¡Archivo importado!", "Cadastro importado!" )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Este tipo de importación solamente es compatible con la base de datos MSSQL.", "Este tipo de importação só é compatível com a base de dados MSSQL." )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Seleccionar archivo", "Selecionar cadastro" )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "Este archivo no existe o el servidor SQL no consigue abrirlo, utilice un archivo que se encuentre en la máquina de su servidor SQL o una dirección de red a la que pueda accederse por el servidor SQL.", "Este cadastro não existe ou o servidor SQL não consegue abrir, utilize um cadastro que fique na máquina do seu servidor SQL ou um endereço de rede com o qual possa acessar pelo servidor SQL." )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "Ocurrió un error al procesar el archivo seleccionado. Verifique si el contenido está correcto e intente nuevamente.", "Ocorreu um erro ao processar um cadastro selecionado. Confira se o conteúdo está correto e tente novamente." )
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "Ocurrió un error al procesar el archivo seleccionado, verifique si el archivo existe en el servidor SQL, así como su contenido, e intente nuevamente.", "Ocorreu um erro ao processar o cadastro selecionado, confira se o cadastro existe no servidor SQL, bem como seu conteúdo, e tente novamente." )
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "Seleccione un archivo e intente nuevamente.", "Selecione um cadastro e tente novamente." )
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "¡Archivo no importado!", "Cadastro não importado!" )
	#endif
#endif
