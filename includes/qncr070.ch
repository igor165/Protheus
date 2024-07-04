#ifdef SPANISH
	#define STR0001 "DIAGRAMA DE CAUSA Y EFECTO"
	#define STR0002 "EFECTO"
	#define STR0003 "Ficha de ocurrencia/No conformidad:"
	#define STR0004 "Plan de acción:"
	#define STR0005 "MEDICIÓN"
	#define STR0006 "MATERIALES"
	#define STR0007 "MANO DE OBRA"
	#define STR0008 "MEDIO AMBIENTE"
	#define STR0009 "MÉTODO"
	#define STR0010 "MÁQUINA"
	#define STR0011 "No existen datos generados para este informe. Verifique los parámetros del informe"
	#define STR0012 "Sin Datos"
	#define STR0013 "(*) Causa raíz"
#else
	#ifdef ENGLISH
		#define STR0001 "CAUSE AND EFFECT CHART    "
		#define STR0002 "EFFECT"
		#define STR0003 "Occurrence/Non-conformance Form:"
		#define STR0004 "Action plan:"
		#define STR0005 "MEASUREMENT"
		#define STR0006 "MATERIALS"
		#define STR0007 "WORKFORCE"
		#define STR0008 "ENVIRONMENT"
		#define STR0009 "METHOD"
		#define STR0010 "MACHINE"
		#define STR0011 "There is no data generated for this Report. Check the parameters of the report"
		#define STR0012 "No data  "
		#define STR0013 "(*) Root Cause"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Diagrama De Causa E Efeito", "DIAGRAMA DE CAUSA E EFEITO" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Efeito", "EFEITO" )
		#define STR0003 "Ficha Ocorrência/Não-Conformidade:"
		#define STR0004 "Plano de Ação:"
		#define STR0005 "MEDIÇÃO"
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Materiais", "MATERIAIS" )
		#define STR0007 "MÃO-DE-OBRA"
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Meio Ambiente", "MEIO AMBIENTE" )
		#define STR0009 "MÉTODO"
		#define STR0010 "MÁQUINA"
		#define STR0011 "Não existem dados gerados para este Relatório. Verifique os parâmetros do relatório"
		#define STR0012 "Sem Dados"
		#define STR0013 "(*) Causa Raíz"
	#endif
#endif
