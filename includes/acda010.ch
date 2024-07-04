#ifdef SPANISH
	#define STR0001 "Archivo de operadores"
	#define STR0002 "¡Atencion! "
	#define STR0003 "Este registro esta siendo utilizado por el sistema"
	#define STR0004 "y no puede ser borrado por el sistema"
	#define STR0005 "Operador posee registros de monitoreo de producción en la tabla CBH."
	#define STR0006 "Operador posee apuntes de producción en la tabla SH6."
	#define STR0007 "Exclusión no permitida"
	#define STR0008 " ¡Excluya, primero, estos registros antes de excluir el operador!"
	#define STR0009 "OK"
	#define STR0010 "Operador tiene registro de inventario en la tabla CBB"
#else
	#ifdef ENGLISH
		#define STR0001 "Operators File"
		#define STR0002 "Attention! "
		#define STR0003 "This record is being used by system"
		#define STR0004 "and cannot be deleted by system"
		#define STR0005 "Operator has Production Monitoring registers on CBH table."
		#define STR0006 "Operator has production annotations on SH6 table."
		#define STR0007 "Deletion not allowed"
		#define STR0008 " Firstly, delete these records before deleting the operator!"
		#define STR0009 "OK"
		#define STR0010 "Operator has Inventory record in CBB table"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Registo de operadores", "Cadastro de operadores" )
		#define STR0002 "Atenção! "
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Este registo está a ser utilizado pelo sistema", "Este registro está sendo utilizado pelo sistema" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "e não pode ser excluído pelo sistema", "e não pode ser excluido pelo sistema" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Operator has Production Monitoring registers on CBH table.", "Operador possui registros de Monitoramento de Produção na tabela CBH." )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Operator has production annotations on SH6 table.", "Operador possui apontamentos de produção na tabela SH6." )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Deletion not allowed", "Exclusão não permitida" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Firstly, delete these records before deleting the operator!", " Exclua primeiramente esses registros antes de excluir o operador!" )
		#define STR0009 "OK"
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Operator has Inventory record in CBB table", "Operador possui registro de Inventario na tabela CBB" )
	#endif
#endif
