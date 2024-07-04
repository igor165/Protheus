#ifdef SPANISH
	#define STR0001 "Este programa emitirá la lista de los bienes que "
	#define STR0002 "se depreciaron totalmente por %"
	#define STR0003 "Bienes depreciados por %"
	#define STR0004 "Saldos depreciados por bienes"
	#define STR0005 "Código  Descripción"
	#define STR0006 "Código     Ítem Descripc."
	#define STR0007 "ANULADO POR EL OPERADOR"
	#define STR0008 "TOTALES DE LA TASA:"
	#define STR0009 "TOTALES GENERALES "
	#define STR0010 "                                  Correc. Acumulada     Depr.Acumulada  Corr.Depr.Acumul     Val Ampliación"
	#define STR0011 "Cód. Base del bien"
	#define STR0012 "Cuenta"
	#define STR0013 "Centro de costo"
	#define STR0014 "Ítem contable"
	#define STR0015 "Clase de valor"
	#define STR0016 "Total"
	#define STR0017 "Cuenta: "
	#define STR0018 "C.Costo: "
	#define STR0019 "Ítem: "
	#define STR0020 "Cl.Valor: "
	#define STR0021 "Código"
	#define STR0022 "Ítem"
	#define STR0023 "Tipo"
	#define STR0024 "Código sucursal"
	#define STR0025 "Empresa"
	#define STR0026 "Unidad de negocio"
	#define STR0027 "Sucursal"
	#define STR0028 "Por favor, espere..."
	#define STR0029 "Sucursales seleccionadas para el informe"
#else
	#ifdef ENGLISH
		#define STR0001 "This program will print a list of Assets thar were "
		#define STR0002 "already completely depreciated per percentage"
		#define STR0003 "Depreciated Assets by Percentage"
		#define STR0004 "Depreciated Balances per Asset"
		#define STR0005 "Code    Descript."
		#define STR0006 "Code       Item Descript."
		#define STR0007 "CANCELLED BY THE OPERATOR  "
		#define STR0008 "RATE TOTALS:    "
		#define STR0009 "GRAND T O T A L S"
		#define STR0010 "                                  Accumul.Correction    Accumul.Depr    Accum.Depr.Corr.     Enlargem.Value"
		#define STR0011 "Good Base Code    "
		#define STR0012 "Acct."
		#define STR0013 "Cost Center    "
		#define STR0014 "Acctg. Item "
		#define STR0015 "Value Class    "
		#define STR0016 "Total"
		#define STR0017 "Acct.: "
		#define STR0018 "Cost C.: "
		#define STR0019 "Item: "
		#define STR0020 "Value Cl. "
		#define STR0021 "Code"
		#define STR0022 "Item"
		#define STR0023 "Type"
		#define STR0024 "Branch Code"
		#define STR0025 "Company"
		#define STR0026 "Business Unit"
		#define STR0027 "Branch"
		#define STR0028 "Please wait..."
		#define STR0029 "Branches selected for the report"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Este programa irá emitir a relação dos bens que já", "Este programa irá emitir a relaçäo dos Bens que já" )
		#define STR0002 "foram totalmente depreciados por %"
		#define STR0003 "Bens Depreciados Por %"
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Saldos Depreciados Por Bens", "Saldos Depreciados por Bens" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Código  Descrição", "Codigo  Descricao" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Código     Elemento Descrição", "Codigo     Item Descricao" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Cancelado Pelo Operador", "CANCELADO PELO OPERADOR" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Totais da taxa: ", "TOTAIS DA TAXA: " )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "T O T A I S Gerais", "T O T A I S GERAIS" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "                                  Correcção Acumulada    Depr Acumulada  Corr Depr Acumul     Vlr Ampliação", "                                  Correcao Acumulada    Depr Acumulada  Corr Depr Acumul     Vlr Ampliacao" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Código Base Do Bem", "Codigo Base do Bem" )
		#define STR0012 "Conta"
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Centro De Custo", "Centro de Custo" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Item Contab.", "Item Contabil" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Classe De Valor", "Classe de Valor" )
		#define STR0016 "Total"
		#define STR0017 "Conta: "
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "C. Custo:", "C.Custo: " )
		#define STR0019 "Item: "
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Cl.valor: ", "Cl.Valor: " )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Código", "Codigo" )
		#define STR0022 "Item"
		#define STR0023 "Tipo"
		#define STR0024 "Código filial"
		#define STR0025 "Empresa"
		#define STR0026 "Unidade de negócio"
		#define STR0027 "Filial"
		#define STR0028 "Favor Aguardar..."
		#define STR0029 "Filiais selecionadas para o relatório"
	#endif
#endif
