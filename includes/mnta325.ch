#ifdef SPANISH
	#define STR0001 "Tipo de Estatus"
	#define STR0002 "Tipo de estatus ya cadastrado para el Estatus"
	#define STR0003 "Informe un tipo de estatus válido."
	#define STR0004 "NO CONFORMIDAD"
	#define STR0005 "Color del estatus ya registrado para el Estatus"
	#define STR0006 "Informe un color válido."
	#define STR0007 "Buscar"
	#define STR0008 "Visualizar"
	#define STR0009 "Incluir"
	#define STR0010 "Modificar"
	#define STR0011 "Borrar"
	#define STR0012 "Valor de campo inválido."
	#define STR0013 "Campo en blanco."
	#define STR0014 "Informe un valor para el campo de estatus."
#else
	#ifdef ENGLISH
		#define STR0001 "Status Type"
		#define STR0002 "Status type already registered for the Status"
		#define STR0003 "Enter a valid status type."
		#define STR0004 "NON-CONFORMANCE"
		#define STR0005 "Status color already registered for the Status"
		#define STR0006 "Enter a valid color."
		#define STR0007 "Search"
		#define STR0008 "View"
		#define STR0009 "Add"
		#define STR0010 "Edit"
		#define STR0011 "Delete"
		#define STR0012 "Value of field invalid."
		#define STR0013 "Field blank."
		#define STR0014 "Enter a value for status field."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Tipo De Estado   ", "Tipo de Status" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Tipo De Estado Já Registado Para O Estado", "Tipo de status já cadastrado para o Status" )
		#define STR0003 "Informe um tipo de status válido."
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Não conformidade", "NÃO CONFORMIDADE" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Cor Do Estado Já Registada Para O Estado", "Cor do status já cadastrado para o Status" )
		#define STR0006 "Informe uma cor válida."
		#define STR0007 "Pesquisar"
		#define STR0008 "Visualizar"
		#define STR0009 "Incluir"
		#define STR0010 "Alterar"
		#define STR0011 "Excluir"
		#define STR0012 "Valor de campo inválido."
		#define STR0013 "Campo em branco."
		#define STR0014 "Informe um valor para o campo de status."
	#endif
#endif
