#ifdef SPANISH
	#define STR0001 "Buscar"
	#define STR0002 "Visualizar"
	#define STR0003 "Incluir"
	#define STR0005 "Borrar"
	#define STR0006 "Plan de Accion vs Mandato"
	#define STR0007 "Clientes"
	#define STR0008 "Planes de Accion"
	#define STR0009 "Conocimiento"
	#define STR0010 "Esta rutina fue descontinuada y centralizada en la rutina de 'Mandatos' (MDTA635), seleccione 'Finalizar' para ser reorientado"
	#define STR0011 "Atención"
#else
	#ifdef ENGLISH
		#define STR0001 "Search"
		#define STR0002 "View"
		#define STR0003 "Insert"
		#define STR0005 "Delete"
		#define STR0006 "Action Plan X Mandate"
		#define STR0007 "Customers"
		#define STR0008 "Action Plans"
		#define STR0009 "Knowledge"
		#define STR0010 "This routine was discontinued and centralized in the 'Term of office' (MDTA635), select 'Close' to be redirected"
		#define STR0011 "Attention"
	#else
		#define STR0001 "Pesquisar"
		#define STR0002 "Visualizar"
		#define STR0003 "Incluir"
		#define STR0005 "Excluir"
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Plano De Acção  X Mandato", "Plano de Acao X Mandato" )
		#define STR0007 "Clientes"
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Planos de acção", "Planos de Ação" )
		#define STR0009 "Conhecimento"
		#define STR0010 "Esta rotina foi descontinuada e centralizada na rotina de 'Mandatos' (MDTA635), selecione 'Fechar' para ser redirecionado"
		#define STR0011 "Atenção"
	#endif
#endif
