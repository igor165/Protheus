#ifdef SPANISH
	#define STR0001 "RG 001-12 - Posadas - Percepciones"
	#define STR0002 "Exportacion de TXT"
	#define STR0003 "Esta rutina realiza la exportacion de un TXT con las "
	#define STR0004 "percepciones de impuestos municipales de Posadas."
	#define STR0005 "RG 001-12 – Municipalidad de Posadas"
	#define STR0006 "Exportar"
	#define STR0007 "Salir"
	#define STR0008 "Por favor, complete todos los parametros solicitados"
	#define STR0009 "Seleccionando registros..."
	#define STR0010 "Creando archivo"
	#define STR0011 "Atención"
	#define STR0012 "Procesando registros"
	#define STR0013 "Verifique el formato del numero de habilitacion 000000/00"
	#define STR0014 "Procedimiento finalizado."
	#define STR0015 "No existen registros a exportar."
	#define STR0016 "El rango de fechas debe pertenecer al mismo periodo."
	#define STR0017 "Seleccion de Sucursales"
	#define STR0018 "Marque las Sucursales que se consideran en el procesamiento"
	#define STR0019 "Invierte seleccion"
	#define STR0020 "Sucursal"
	#define STR0021 "Descripcion"
	#define STR0022 "CUIT"
#else
	#ifdef ENGLISH
		#define STR0001 "RG 001-12 - Posadas - Collections"
		#define STR0002 "TXT Export"
		#define STR0003 "This routine exports a TXT with"
		#define STR0004 "Posadas city taxes collections."
		#define STR0005 "RG 001-12 - Posadas Municipality"
		#define STR0006 "Export"
		#define STR0007 "Exit"
		#define STR0008 "Enter all requested parameters"
		#define STR0009 "Selecting records..."
		#define STR0010 "Creating file"
		#define STR0011 "Attention"
		#define STR0012 "Processing records"
		#define STR0013 "Check license number format 000000/00"
		#define STR0014 "Procedure completed."
		#define STR0015 "No records to export."
		#define STR0016 "Data range must belong to the same period."
		#define STR0017 "Selection of Branches"
		#define STR0018 "Select Branches to be considered in processing"
		#define STR0019 "Reverse Selection"
		#define STR0020 "Branch"
		#define STR0021 "Description"
		#define STR0022 "CUIT (Single Code of Tax Identification)"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "RG 001-12 - Posadas - Percepciones", "RG 001-12 - Posadas - Percepções" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Exportacion de TXT", "Exportação de TXT" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Esta rutina realiza la exportacion de un TXT con las ", "Esta rotina realiza a exportação de um TXT com as" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "percepciones de impuestos municipales de Posadas.", "percepções de impostos municipais de Posadas." )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "RG 001-12 – Municipalidad de Posadas", "RG 001-12 - Municipalidade de Posadas" )
		#define STR0006 "Exportar"
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Salir", "Sair" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Por favor, complete todos los parametros solicitados", "Por favor, preencha todos os parâmetros solicitados" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Seleccionando registros...", "Selecionando registros..." )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Creando archivo", "Criando arquivo" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Atención", "Atenção" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Procesando registros", "Processando registros" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Verifique el formato del numero de habilitacion 000000/00", "Confira o formato do número de habilitação 000000/00" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Procedimiento finalizado.", "Procedimento concluído." )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "No existen registros a exportar.", "Não existem registros a exportar." )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "El rango de fechas debe pertenecer al mismo periodo.", "O rango de datas deve pertencer ao mesmo período." )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Seleccion de Sucursales", "Seleção de Filiais" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Marque las Sucursales que se consideran en el procesamiento", "Selecione as Filiais que serão consideradas no processamento" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Invierte seleccion", "Reverter Seleção" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Sucursal", "Filial" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Descripcion", "Descrição" )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "CUIT", "CUIT (Cód. Únic. Identif. Tribut.)" )
	#endif
#endif
