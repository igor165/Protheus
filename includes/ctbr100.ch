#ifdef SPANISH
	#define STR0001 "Este programa imprimira el balance de "
	#define STR0002 "de acuerdo con los parametros solicitados por el usuario. "
	#define STR0003 "Balance de verificacion "
	#define STR0004 If( cPaisLoc == "ANG", "|  CODIGO                     |      D E S C R I P C I O N                      |    SALDO ANTERIOR              |    CARGO        |      ABONO        |    MOVIMIENTO DEL PERIODO     |         SALDO ACTUAL              |", If( cPaisLoc == "EQU", "|  CODIGO                     |      D E S C R I P C I O N                      |    SALDO ANTERIOR              |    DEBITO        |     CREDITO      |    MOVIMIENTO DEL PERIODO     |         SALDO ACTUAL              |", If( cPaisLoc == "HAI", "|  CODIGO                     |      D E S C R I P C I O N                      |    SALDO ANTERIOR              |    CARGO        |      ABONO        |    MOVIMIENTO DEL PERIODO     |         SALDO ACTUAL              |", If( cPaisLoc == "MEX", "|  CODIGO                     |      D E S C R I P C I O N                      |    SALDO ANTERIOR              |    CARGO        |      ABONO        |    MOVIMIENTO DEL PERIODO     |         SALDO ACTUAL              |", If( cPaisLoc == "PTG", "|  CODIGO                     |      D E S C R I P C I O N                      |    SALDO ANTERIOR              |    CARGO        |      ABONO        |    MOVIMIENTO DEL PERIODO     |         SALDO ACTUAL              |", "|  CODIGO                     |      D E S C R I P C I O N                      |    SALDO ANTERIOR              |    DEBITO       |      CREDITO      |    MOVIMIENTO DEL PERIODO     |         SALDO ACTUAL              |" ) ) ) ) )
	#define STR0005 If( cPaisLoc == "ANG", "|  CODIGO               |   D E S C R I P C I O N        |   SALDO ANTERIOR  |      DEBITO    |      CREDITO   |   SALDO ACTUAL    |", If( cPaisLoc == "EQU", "|  CODIGO               |   D E S C R I P C I O N        |   SALDO ANTERIOR  |      DEBITO    |      CREDITO   |   SALDO ACTUAL    |", If( cPaisLoc == "HAI", "|  CODIGO               |   D E S C R I P C I O N        |   SALDO ANTERIOR  |      DEBITO    |      CREDITO   |   SALDO ACTUAL    |", If( cPaisLoc == "MEX", "|  CODIGO               |   D E S C R I P C I O N        |   SALDO ANTERIOR  |      CARGO     |      ABONO     |   SALDO ACTUAL    |", If( cPaisLoc == "PTG", "|  CODIGO               |   D E S C R I P C I O N        |   SALDO ANTERIOR  |      DEBITO    |      CREDITO   |   SALDO ACTUAL    |", "|  CODIGO               |     D E S C R I P C I O N      |   SALDO ANTERIOR  |      DEBITO    |      CREDITO   |   SALDO ACTUAL    |" ) ) ) ) )
	#define STR0006 "DE BALANCE PARCIAL ANALITICO"
	#define STR0007 "DE BALANCE PARCIAL SINTETICO DE "
	#define STR0008 "DE BALANCE PARCIAL "
	#define STR0009 " DE "
	#define STR0010 " A  "
	#define STR0011 " EN "
	#define STR0012 " (PRESUPUESTADO)"
	#define STR0013 " (DE GESTION)"
	#define STR0014 "Creando archivo temporal..."
	#define STR0015 "A Rayas"
	#define STR0016 "Administracion"
	#define STR0017 "***** ANULADO POR EL OPERADOR *****"
	#define STR0018 "TOTALES DE PERIODO:"
	#define STR0019 "TOTALES GRUPO   ("
	#define STR0020 "TOTALES DE"
	#define STR0021 " Cuenta "
	#define STR0022 "DIV."
	#define STR0023 "Por favor rellenar los parametros Grupos Ingresos/Gastos y Fecha Sld Ant. Ingresos/Gastos o "
	#define STR0024 "dejar el parametro Ignora Sl Ant.Ing/Gas = No "
	#define STR0025 "DESCRIPC."
	#define STR0026 "MOV. PERIODO"
	#define STR0027 "CODIGO"
	#define STR0028 "SALDO ANTERIOR"
	#define STR0029 If( cPaisLoc == "MEX", "CARGO", "DEBITO" )
	#define STR0030 If( cPaisLoc == "MEX", "ABONO", "CREDITO" )
	#define STR0031 "Mov. Periodo"
	#define STR0032 "SALDO ACT. "
#else
	#ifdef ENGLISH
		#define STR0001 "This program will print the Trial Balance "
		#define STR0002 "according to the parameters selecteds by the User. "
		#define STR0003 "Trial Balance "
		#define STR0004 "|  CODE                       |      D E S C R I P T I O N                      |    PREVIOUS BALANCE            |    DEBIT        |      CREDIT       |    PERIOD MOVEMENTS           |         CURRENT BALANCE           |"
		#define STR0005 "|  CODE                 |   D  E  S  C  R  I  P  T  .    |   PREV. BALANCE   |      DEBIT     |      CREDIT    |   CURRENT BAL.    |"
		#define STR0006 "DETAILED TRIAL BALANCE "
		#define STR0007 "SUMM. TRIAL BALANCE "
		#define STR0008 "TRIAL BALANCE "
		#define STR0009 " FROM "
		#define STR0010 " TO "
		#define STR0011 " IN "
		#define STR0012 " (BUDGETED)"
		#define STR0013 " (MANAGERIAL)"
		#define STR0014 "Creating Temporary File..."
		#define STR0015 "Z.Form"
		#define STR0016 "Management"
		#define STR0017 "***** CANCELLED BY THE OPERATOR *****"
		#define STR0018 "PERIOD TOTALS:     "
		#define STR0019 "GROUP TOTALS    ("
		#define STR0020 "TOTALS OF "
		#define STR0021 " Account "
		#define STR0022 "DIV."
		#define STR0023 "Please, fill out the parameters Groups Incomes/Expenses& Date Prv Blnc Incomes/Expenses or "
		#define STR0024 "leave parameter Ignor Sl Adv.Rec/Des = No  "
		#define STR0025 "DESCRIPT."
		#define STR0026 "PERIOD MOV. "
		#define STR0027 "CODE  "
		#define STR0028 "PREVIOUS BLNCE"
		#define STR0029 "DEBIT "
		#define STR0030 "CREDIT "
		#define STR0031 "Transac. Period"
		#define STR0032 "CURRENT BLN"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Este programa vai imprimir o balancete de ", "Este programa ira imprimir o Balancete de " )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "De acordo com os par�metros solicitados pelo utilizador. ", "de acordo com os parametros solicitados pelo Usuario. " )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Balancete de verifica��o ", "Balancete de Verificacao " )
		#define STR0004 If( cPaisLoc $ "ANG|EQU|HAI", "|  C�DIGO                     |      D E S C R I � � O                          |    SALDO ANTERIOR              |    D�BITO       |      CR�DITO      |    MOVIMENTO DO PER�ODO       |         SALDO ATUAL               |", If( cPaisLoc $ "MEX|PTG", "|  c�digo                     |      d e s c r i � � o                          |    saldo anterior              |    d�bito       |      cr�dito      |    movimento do per�odo       |         saldo actual               |", "|  CODIGO                     |      D E S C R I C A O                          |    SALDO ANTERIOR              |    DEBITO       |      CREDITO      |    MOVIMENTO DO PERIODO       |         SALDO ATUAL               |" ) )
		#define STR0005 If( cPaisLoc $ "ANG|EQU|HAI", "|  C�DIGO               |   D  E  S  C  R  I  �  �  O    |   SALDO ANTERIOR  |      D�BITO    |      CR�DITO   |   SALDO ATUAL     |", If( cPaisLoc $ "MEX|PTG", "|  c�digo               |   d  e  s  c  r  i  �  �  o    |   saldo anterior  |      d�bito    |      cr�dito   |   saldo actual     |", "|  CODIGO               |   D  E  S  C  R  I  C  A  O    |   SALDO ANTERIOR  |      DEBITO    |      CREDITO   |   SALDO ATUAL     |" ) )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Balancete analitico de ", "BALANCETE ANALITICO DE " )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Balancete sintetico de ", "BALANCETE SINTETICO DE " )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Balancete de ", "BALANCETE DE " )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", " de ", " DE " )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", " at� ", " ATE " )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", " em ", " EM " )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", " (orcado)", " (ORCADO)" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", " (de gest�o)", " (GERENCIAL)" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "A Criar Ficheiro Tempor�rio...", "Criando Arquivo Temporario..." )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "C�digo de barras", "Zebrado" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Administra��o", "Administracao" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "***** cancelado pelo operador *****", "***** CANCELADO PELO OPERADOR *****" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Totais do per�odo: ", "TOTAIS DO PERIODO: " )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Totais do grupo (", "TOTAIS DO GRUPO (" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Totais do ", "TOTAIS DO " )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", " conta ", " Conta " )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "Div.", "DIV." )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Favor preencher os par�metros grupos receitas/despesas e data sld ant. receitas/despesas ou ", "Favor preencher os parametros Grupos Receitas/Despesas e Data Sld Ant. Receitas/Despesas ou " )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Deixar o par�metro ignora sl ant.rec/des = n�o ", "deixar o parametro Ignora Sl Ant.Rec/Des = Nao " )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "Descri��o", "DESCRICAO" )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Mov. Per�odo", "MOV. PERIODO" )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "C�digo", "CODIGO" )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "Saldo Anterior", "SALDO ANTERIOR" )
		#define STR0029 If( cPaisLoc $ "ANG|EQU|HAI", "D�BITO", If( cPaisLoc == "MEX", "Cart�o D�bito", If( cPaisLoc == "PTG", "D�bito", "DEBITO" ) ) )
		#define STR0030 If( cPaisLoc $ "ANG|EQU|HAI", "CR�DITO", If( cPaisLoc == "MEX", "N�o � possivel gerar uma Nota de Cr�dito com o valor restante", If( cPaisLoc == "PTG", "Cr�dito", "CREDITO" ) ) )
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "Mov. Per�odo", "Mov. Periodo" )
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "Saldo Actual", "SALDO ATUAL" )
	#endif
#endif
