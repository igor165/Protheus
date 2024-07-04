#ifdef SPANISH
	#define STR0001 "Tabla de IR"
	#define STR0002 "Buscar"
	#define STR0003 "Visualizar"
	#define STR0004 "Incluir"
	#define STR0005 "Modificar"
	#define STR0006 "Borrar"
	#define STR0007 "Imprimir"
	#define STR0008 "Rangos"
	#define STR0009 "Fecha Inicial de la Validez debe ser inferior que la Fecha final de la Validez."
	#define STR0010 "Base Calculo inicial debe ser inferior a la Base de Calculo final."
	#define STR0011 "Ya existe registro con la Fecha Inicial de la Validez informada"
	#define STR0012 "La Base Calculo inicial debe ser inferior a la Base de calculo Final."
	#define STR0013 "La Base Calculo Inicial debe ser superior a cero"
	#define STR0014 "La Base Calculo Final Inicial debe ser superior a cero"
	#define STR0015 "La Base Calculo Inicial debe ser superior a cero "
	#define STR0016 "La Base Calculo Final debe ser inferior a cero "
#else
	#ifdef ENGLISH
		#define STR0001 "IR Table"
		#define STR0002 "Search"
		#define STR0003 "View"
		#define STR0004 "Add"
		#define STR0005 "Change"
		#define STR0006 "Delete"
		#define STR0007 "Print"
		#define STR0008 "Ranges"
		#define STR0009 "Start due date must be before end due date."
		#define STR0010 "Initial calculation base must be lower than final calculation base."
		#define STR0011 "There is already a record with the initial due date entered."
		#define STR0012 "Initial calculation base must be lower than final calculation base."
		#define STR0013 "Initial calculation base must be higher than zero."
		#define STR0014 "Final calculation base must be higher than zero."
		#define STR0015 "Initial calculation base must be higher than "
		#define STR0016 "Final calculation base must be lower than "
	#else
		#define STR0001 "Tabela de IR"
		#define STR0002 "Pesquisar"
		#define STR0003 "Visualizar"
		#define STR0004 "Incluir"
		#define STR0005 "Alterar"
		#define STR0006 "Excluir"
		#define STR0007 "Imprimir"
		#define STR0008 "Faixas"
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Data inicial da validade deve ser menor que a data final da validade.", "Data Inicial da Validade deve ser menor que a Data final da Validade." )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Base c�lculo inicial deve ser menor que a base de c�lculo final.", "Base C�lculo inicial deve ser menor que a Base de C�lculo final." )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "J� existe registo com a data inicial da validade informada", "J� existe registro com a Data Inicial da Validade informada" )
		#define STR0012 "A Base C�lculo Inicial deve ser menor que Base c�lculo Final."
		#define STR0013 "A Base C�lculo Inicial deve ser maior que zero"
		#define STR0014 "A Base C�lculo Final deve ser maior que zero."
		#define STR0015 "A Base C�lculo Inicial deve ser maior que "
		#define STR0016 "A Base C�lculo Final deve ser menor que "
	#endif
#endif
