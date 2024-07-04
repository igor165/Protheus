#ifdef SPANISH
	#define STR0001 "Documentos Exigidos vs Proveedores"
	#define STR0002 "Este programa listara los Documentos Exigidos vs. Proveedores"
	#define STR0003 "A Rayas"
	#define STR0004 "Administrac."
	#define STR0005 "No existen documentos para este proveedor conforme definicion de Parametros"
	#define STR0006 "Datos protegidos - Acceso restringido: este usuario no tiene permiso de acceso a los datos de esta rutina. Para más información, entre en contacto con el Administrador del sistema."
#else
	#ifdef ENGLISH
		#define STR0001 "Necessary Documents X Suppliers"
		#define STR0002 "This program will list the Necessary Documents X Suppliers."
		#define STR0003 "Z-Form"
		#define STR0004 "Management"
		#define STR0005 "No documents for this supplier according to the parameters definition."
		#define STR0006 "Protected Data - Restrict Access: This user does not have permission to access the data of this routine. For further details, contact the system administrator."
	#else
		#define STR0001 "Documentos Exigidos X Fornecedores"
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Este Programa Irá Listar Os Documentos Exigidos X Fornecedores", "Este programa ira listar os Documentos Exigidos X Fornecedores" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Código de barras", "Zebrado" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Administração", "Administracao" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Não Existem Documentos Para Este Fornecedor Conforme Definição Dos Parâmetros", "Nao existem documentos para este fornecedor conforme definicao dos Parametros" )
		#define STR0006 "Dados Protegidos - Acesso Restrito: Este usuário não possui permissão de acesso aos dados dessa rotina. Para mais informações contate o Administrador do sistema !!"
	#endif
#endif
