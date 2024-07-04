#ifdef SPANISH
	#define STR0001 "Este programa emitirá la lista de los bienes que "
	#define STR0002 "fueron totalmente depreciados."
	#define STR0003 "Bienes depreciados"
	#define STR0004 "Saldos depreciados por bienes"
	#define STR0005 "Código  Descripciación"
	#define STR0006 "Código         Descripción"
	#define STR0007 "Código     Ítem Descripción"
	#define STR0008 "                                  Correc. Acumulada     Depr Acumulada  Corr Depr Acumul     Val Ampliac. "
	#define STR0009 "ANULADO POR EL OPERADOR"
	#define STR0010 "T O T A L E S"
	#define STR0011 "Total"
	#define STR0012 "Cuenta:"
	#define STR0013 "C.Costo: "
	#define STR0014 "Ítem: "
	#define STR0015 "Cl.Valor: "
	#define STR0016 "Código base del bien"
	#define STR0017 "Cuenta"
	#define STR0018 "Centro de costo"
	#define STR0019 "Ítem contable"
	#define STR0020 "Clase de valor"
	#define STR0021 "Código"
	#define STR0022 "Empresa"
	#define STR0023 "Unidad de negocio"
	#define STR0024 "Sucursal"
	#define STR0025 "Sucursales seleccionadas para el informe"
	#define STR0026 "Por favor, espere..."
#else
	#ifdef ENGLISH
		#define STR0001 "This program lists the assets already             "
		#define STR0002 "were completely depreciated"
		#define STR0003 "Depreciated Assets"
		#define STR0004 "Depreciated Balances per Asset"
		#define STR0005 "Code    Descript."
		#define STR0006 "Code           Descript "
		#define STR0007 "Code       Item Descript."
		#define STR0008 "                                  Accumulate Adjustm    Accum. Depr.    Accum.Depr.Adjus.    Extension"
		#define STR0009 "CANCELLED BY THE OPERATOR  "
		#define STR0010 "T O T A L S"
		#define STR0011 "Total"
		#define STR0012 "Account: "
		#define STR0013 "Cost.C.: "
		#define STR0014 "Item: "
		#define STR0015 "Vlue Clss "
		#define STR0016 "Good Base Code    "
		#define STR0017 "Acct."
		#define STR0018 "Cost Center    "
		#define STR0019 "Acctg. Item "
		#define STR0020 "Value Class    "
		#define STR0021 "Code"
		#define STR0022 "Company"
		#define STR0023 "Business Unit"
		#define STR0024 "Branch"
		#define STR0025 "Selected Branches for the report"
		#define STR0026 "Please Wait..."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Este programa irá emitir a relação dos bens que já", "Este programa irá emitir a relação dos Bens que já" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Foram totalmente depreciados", "foram totalmente depreciados" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Artigos Depreciados", "Bens Depreciados" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Saldos Depreciados Por Bens", "Saldos Depreciados por Bens" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Código  Descrição", "Codigo  Descricao" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Código         Descrição", "Codigo         Descricao" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Código     Elemento Descrição", "Codigo     Item Descricao" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "                                  Correcção Acumulada    Depr Acumulada  Corr Depr Acumul     Vlr Ampliação", "                                  Correcao Acumulada    Depr Acumulada  Corr Depr Acumul     Vlr Ampliacao" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Cancelado Pelo Operador", "CANCELADO PELO OPERADOR" )
		#define STR0010 "T O T A I S"
		#define STR0011 "Total"
		#define STR0012 "Conta: "
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "C. Custo:", "C.Custo: " )
		#define STR0014 "Item: "
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Cl.valor: ", "Cl.Valor: " )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Código Base Do Bem", "Codigo Base do Bem" )
		#define STR0017 "Conta"
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Centro De Custo", "Centro de Custo" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Item Contab.", "Item Contabil" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Classe De Valor", "Classe de Valor" )
		#define STR0021 "Código"
		#define STR0022 "Empresa"
		#define STR0023 "Unidade de negócio"
		#define STR0024 "Filial"
		#define STR0025 "Filiais selecionadas para o relatorio"
		#define STR0026 "Favor Aguardar..."
	#endif
#endif
