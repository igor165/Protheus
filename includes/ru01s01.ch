#ifdef SPANISH
	#define STR0001 "Colocando en operaciуn - Historial"
	#define STR0002 "Rastreador de contabilidad"
	#define STR0003 "Sucursal"
	#define STR0004 "Tipo de bien"
	#define STR0005 "Fecha de registro"
	#define STR0006 "Hora"
	#define STR0007 "Usuario"
	#define STR0008 "Tp. Oper."
	#define STR0009 "Colocando en operaciуn"
	#define STR0010 "Reversiуn"
	#define STR0011 "No se encontrу el registro de saldos y cantidades"
	#define STR0012 "Операции "
	#define STR0013 "Исходныйный документ"
	#define STR0014 "Исходного документа не существует"
	#define STR0015 "Бухгалтерские проводки"
	#define STR0016 "Бухгалтерских проводок не существует"
	#define STR0017 "Печать"
#else
	#ifdef ENGLISH
		#define STR0001 "Putting into Operation - History"
		#define STR0002 "Accounting Tracker"
		#define STR0003 "Branch"
		#define STR0004 "Asset Type"
		#define STR0005 "Entry Date"
		#define STR0006 "Time"
		#define STR0007 "User"
		#define STR0008 "Tp. Oper."
		#define STR0009 "Putting Into Operation"
		#define STR0010 "Storno"
		#define STR0011 "Balances and Amounts record not found"
		#define STR0012 "Operation "
		#define STR0013 "Исходныйный документ"
		#define STR0014 "Original document does not exist"
		#define STR0015 "Accounting Entries"
		#define STR0016 "Accounting Entries do not exist"
		#define STR0017 "Print"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Putting into Operation - History", "Colocando em operaзгo - Histуrico" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Accounting Tracker", "Rastreador de contabilidade" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Branch", "Filial" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Asset Type", "Tipo de Bem" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Entry Date", "Data de lanзamento" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Time", "Hora" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "User", "Usuбrio" )
		#define STR0008 "Tp. Oper."
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Putting Into Operation", "Colocando em Operaзгo" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Storno", "Estorno" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Balances and Amounts record not found", "Registro de saldos e quantidades nгo foi encontrado" )
		#define STR0012 "Операции "
		#define STR0013 "Исходныйный документ"
		#define STR0014 "Исходного документа не существует"
		#define STR0015 "Бухгалтерские проводки"
		#define STR0016 "Бухгалтерских проводок не существует"
		#define STR0017 "Печать"
	#endif
#endif
