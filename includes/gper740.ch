#ifdef SPANISH
	#define STR0001 "Grupo de conceptos"
	#define STR0002 "Impresión del informe de grupo de conceptos"
	#define STR0003 "de acuerdo con los parámetros solicitados por el"
	#define STR0004 "Usuario"
	#define STR0005 "Grupo"
	#define STR0006 "Cód. del grupo"
	#define STR0007 "Desc. del grupo"
	#define STR0008 "Conceptos"
	#define STR0009 "Cód. del concepto"
	#define STR0010 "Descr. del concepto"
	#define STR0011 "Valor"
	#define STR0012 "Concepto sin grupo"
	#define STR0013 "A RAYAS"
	#define STR0014 "ADMINISTRACIÓN"
	#define STR0015 If( cPaisLoc == "PTG", "No existen datos para procesarse", "No existen datos para procesar" )
	#define STR0016 "Verifique los parámetros"
	#define STR0017 "ANULADO POR EL OPERADOR"
	#define STR0018 "<<continua>>"
	#define STR0019 "Total"
	#define STR0020 "Total general"
#else
	#ifdef ENGLISH
		#define STR0001 "Fund Group"
		#define STR0002 "Issue of Fund Group Report"
		#define STR0003 "in accordance with parameters requested by"
		#define STR0004 "User"
		#define STR0005 "Group"
		#define STR0006 "Group Code"
		#define STR0007 "Group Description"
		#define STR0008 "Funds"
		#define STR0009 "Fund Code"
		#define STR0010 "Payroll Item Description"
		#define STR0011 "Value"
		#define STR0012 "Payroll Item without Group"
		#define STR0013 "Z-FORM"
		#define STR0014 "MANAGEMENT"
		#define STR0015 "There are no data to be processed"
		#define STR0016 "Check parameters"
		#define STR0017 "CANCELED BY OPERATOR"
		#define STR0018 "<<to be continued>>"
		#define STR0019 "Total"
		#define STR0020 "Grand Total"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|EQU|HAI", "Grupo de verbas", If( cPaisLoc == "PTG", "Grupo De Verbas", "Grupo de Verbas" ) )
		#define STR0002 "Impressão do Relatório de Grupo de Verbas"
		#define STR0003 "de acordo com os parâmetros solicitados pelo"
		#define STR0004 If( cPaisLoc $ "ANG|EQU|HAI", "Utilizador", If( cPaisLoc == "PTG", "Usuario", "Usuário" ) )
		#define STR0005 "Grupo"
		#define STR0006 If( cPaisLoc $ "ANG|EQU|HAI", "Cód.do Grupo", If( cPaisLoc == "PTG", "Cod.do Grupo", "Cód. do Grupo" ) )
		#define STR0007 If( cPaisLoc $ "ANG|EQU|HAI|PTG", "Descr.do Grupo", "Descr. do Grupo" )
		#define STR0008 "Verbas"
		#define STR0009 If( cPaisLoc $ "ANG|EQU|HAI", "Cód.da Verba", If( cPaisLoc == "PTG", "Cod.da Verba", "Cód. da Verba" ) )
		#define STR0010 If( cPaisLoc $ "ANG|EQU|HAI|PTG", "Descr.da Verba", "Descr. da Verba" )
		#define STR0011 "Valor"
		#define STR0012 If( cPaisLoc $ "ANG|EQU|HAI", "Verba sem grupo", If( cPaisLoc == "PTG", "Verba Sem Grupo", "Verba sem Grupo" ) )
		#define STR0013 If( cPaisLoc $ "ANG|EQU|HAI", "CÓDIGO DE BARRAS", If( cPaisLoc == "PTG", "Código de barras", "ZEBRADO" ) )
		#define STR0014 "ADMINISTRAÇÃO"
		#define STR0015 "Não há dados para serem processados"
		#define STR0016 "Verifique os parâmetros"
		#define STR0017 "CANCELADO PELO OPERADOR"
		#define STR0018 "<<continua>>"
		#define STR0019 "Total"
		#define STR0020 "Total Geral"
	#endif
#endif
