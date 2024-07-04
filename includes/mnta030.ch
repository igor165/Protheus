#ifdef SPANISH
	#define STR0001 "Lubricantes"
	#define STR0002 "Conocimiento"
	#define STR0003 "Buscar"
	#define STR0004 "Visualizar"
	#define STR0005 "Incluir"
	#define STR0006 "Modificar"
	#define STR0007 "Borrar"
	#define STR0008 "Imprimir"
	#define STR0009 "Copiar"
	#define STR0010 "Servicio"
	#define STR0011 "&Servicio"
	#define STR0012 "Solicitud de compras"
	#define STR0013 "&Solicitante"
	#define STR0014 "¿Cuanto al borrado?"
	#define STR0015 "Seleccionando registros.."
#else
	#ifdef ENGLISH
		#define STR0001 "Lubricants"
		#define STR0002 "Bill of lading"
		#define STR0003 "Search"
		#define STR0004 "View"
		#define STR0005 "Add"
		#define STR0006 "Edit"
		#define STR0007 "Delete"
		#define STR0008 "Print"
		#define STR0009 "Copy"
		#define STR0010 "Service"
		#define STR0011 "&Service"
		#define STR0012 "Purchase Order"
		#define STR0013 "&Requestor"
		#define STR0014 "About the Deletion?"
		#define STR0015 "Selecting records ...  "
	#else
		#define STR0001 "Lubrificantes"
		#define STR0002 "Conhecimento"
		#define STR0003 "Pesquisar"
		#define STR0004 "Visualizar"
		#define STR0005 "Incluir"
		#define STR0006 "Alterar"
		#define STR0007 "Excluir"
		#define STR0008 "Imprimir"
		#define STR0009 "Copiar"
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Serviço", "Servico" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "&serviço", "&Servico" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Solicitação De Compras", "Solicitaçäo de Compras" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "&solicitante", "&Solicitante" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Quanto à Exclusão?", "Quanto a Exclusao?" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "A Seleccionar Registos...", "Selecionando Registros..." )
	#endif
#endif
