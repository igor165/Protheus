#ifdef SPANISH
	#define STR0001 "Atención"
	#define STR0002 "1- Proveedor"
	#define STR0003 "2-Cliente"
	#define STR0004 "3- Ambos"
	#define STR0005 "ARBA – REGIMEN DE RECAUDACIÓN – NÓMINA 42/12"
	#define STR0006 "Inf. Preliminar"
	#define STR0007 "Archivo"
	#define STR0008 "Importación de archivo TXT"
	#define STR0009 "Percepción"
	#define STR0010 "Retención"
	#define STR0011 "Importación de archivo TXT"
	#define STR0012 "Esta opción tiene como objetivo actualizar los registros"
	#define STR0013 "CGF identificando la alícuota de retención de IIBB de la ARBA RN 42/12"
	#define STR0014 "Tabla equivalencia"
	#define STR0015 "DD/MM/AAAA"
	#define STR0016 "Importar"
	#define STR0017 "Resumen"
	#define STR0018 "Salir"
	#define STR0019 "Leyendo archivo, espere..."
	#define STR0020 "Actualización de alícuotas"
	#define STR0021 "No se pudo borrar la tabla"
	#define STR0022 "PERIODO"
	#define STR0023 "El archivo"
	#define STR0024 " no puede abrirse."
	#define STR0025 " ¡Archivo importado!"
	#define STR0026 "Este tipo de importación solamente es compatible con la base de datos MSSQL."
	#define STR0027 "Seleccionar archivo"
	#define STR0028 "Este archivo no existe o el servidor SQL no consigue abrirlo, utilice un archivo que se encuentre en la máquina de su servidor SQL o una dirección de red a la que pueda accederse por el servidor SQL."
	#define STR0029 "Ocurrió un error al procesar el archivo seleccionado. Verifique si el contenido está correcto e intente nuevamente."
	#define STR0030 "Ocurrió un error al procesar el archivo seleccionado, verifique si el archivo existe en el servidor SQL, así como su contenido, e intente nuevamente."
	#define STR0031 "Seleccione un archivo e intente nuevamente."
	#define STR0032 "Fecha Inicio Vigencia:"
	#define STR0033 "Fecha Fin    Vigencia:"
	#define STR0034 "Tabla de equivalencia vacía"
	#define STR0035 "La tabla de equivalencia no existe"
#else
	#ifdef ENGLISH
		#define STR0001 "Attention"
		#define STR0002 "1- Supplier"
		#define STR0003 "2-Customer"
		#define STR0004 "3- Both"
		#define STR0005 "ARBA - COLLECTION REGIMEN - PAYROLL 42/12"
		#define STR0006 "Preliminary Rel."
		#define STR0007 "Record"
		#define STR0008 "TXT record import"
		#define STR0009 "Collection"
		#define STR0010 "Withholding"
		#define STR0011 "TXT record import"
		#define STR0012 "This option aims to update CGF records"
		#define STR0013 "identifying the IIBB withholding rate from ARBA RN 42/12"
		#define STR0014 "Equivalence table"
		#define STR0015 "DD/MM/YYYY"
		#define STR0016 "Import"
		#define STR0017 "Summary"
		#define STR0018 "Exit"
		#define STR0019 "Reading record. Wait..."
		#define STR0020 "Rate Update"
		#define STR0021 "Could not delete table"
		#define STR0022 "PERIOD"
		#define STR0023 "The record"
		#define STR0024 "cannot be opened."
		#define STR0025 "Record imported!"
		#define STR0026 "This import type is only compatible with the MSSQL database."
		#define STR0027 "Select record"
		#define STR0028 "This record does not exist or the SQL Server cannot open it. Use a record that stays in your SQL Server computer or a network address that allows access through the SQL Server."
		#define STR0029 "Error processing a selected record. Check its content and try again."
		#define STR0030 "An error occurred when processing the record selected. Check whether the record exists in the SQL Server, as well as its contents, then try again."
		#define STR0031 "Select a record and try again."
		#define STR0032 "Validity Start Date:"
		#define STR0033 "Validity end date:"
		#define STR0034 "Equivalence table empty"
		#define STR0035 "Equivalence Table does not exist"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Atención", "Atenção" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "1- Proveedor", "1- Fornecedor" )
		#define STR0003 "2-Cliente"
		#define STR0004 "3- Ambos"
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "ARBA – REGIMEN DE RECAUDACIÓN – NÓMINA 42/12", "ARBA - REGIME DE RECOLHIMENTO - FOLHA DE PAGAMENTO 42/12" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Inf. Preliminar", "Rel. Preliminar" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Archivo", "Cadastro" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Importación de archivo TXT", "Importação de cadastro TXT" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Percepción", "Percepção" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Retención", "Retenção" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Importación de archivo TXT", "Importação de cadastro TXT" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Esta opción tiene como objetivo actualizar los registros", "Esta opção tem como objetivo atualizar os registros" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "CGF identificando la alícuota de retención de IIBB de la ARBA RN 42/12", "CGF identificando a alíquota de retenção de IIBB da ARBA RN 42/12" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Tabla equivalencia", "Tabela equivalência" )
		#define STR0015 "DD/MM/AAAA"
		#define STR0016 "Importar"
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Resumen", "Resumo" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Salir", "Sair" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Leyendo archivo, espere...", "Lendo cadastro, aguarde..." )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Actualización de alícuotas", "Atualização de alíquotas" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "No se pudo borrar la tabla", "Não foi possível excluir a tabela" )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "PERIODO", "PERÍODO" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "El archivo", "O cadastro" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", " no puede abrirse.", "não pode ser aberto." )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", " ¡Archivo importado!", "¡Cadastro importado!" )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Este tipo de importación solamente es compatible con la base de datos MSSQL.", "Este tipo de importação só é compatível com a base de dados MSSQL." )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Seleccionar archivo", "Selecionar cadastro" )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "Este archivo no existe o el servidor SQL no consigue abrirlo, utilice un archivo que se encuentre en la máquina de su servidor SQL o una dirección de red a la que pueda accederse por el servidor SQL.", "Este cadastro não existe ou o servidor SQL não consegue abrir, utilize um cadastro que fique na máquina do seu servidor SQL ou um endereço de rede com o qual possa acessar pelo servidor SQL." )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "Ocurrió un error al procesar el archivo seleccionado. Verifique si el contenido está correcto e intente nuevamente.", "Ocorreu um erro ao processar um cadastro selecionado. Confira se o conteúdo está correto e tente novamente." )
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "Ocurrió un error al procesar el archivo seleccionado, verifique si el archivo existe en el servidor SQL, así como su contenido, e intente nuevamente.", "Ocorreu um erro ao processar o cadastro selecionado, confira se o cadastro existe no servidor SQL, bem como seu conteúdo, e tente novamente." )
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "Seleccione un archivo e intente nuevamente.", "Selecione um cadastro e tente novamente." )
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "Fecha Inicio Vigencia:", "Data de Início de Vigência:" )
		#define STR0033 If( cPaisLoc $ "ANG|PTG", "Fecha Fin    Vigencia:", "Data Final Vigência:" )
		#define STR0034 If( cPaisLoc $ "ANG|PTG", "Tabla de equivalencia vacía", "Tabela de equivalência vazia" )
		#define STR0035 If( cPaisLoc $ "ANG|PTG", "La tabla de equivalencia no existe", "A tabela de equivalência não existe" )
	#endif
#endif
