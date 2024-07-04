#ifdef SPANISH
	#define STR0001 "Emisión de resultado de la corrección monetaria del activo"
	#define STR0002 "Activo fijo por cuenta"
	#define STR0003 "Resultado de la corrección monetaria"
	#define STR0004 "Cuentas supeditadas                           Saldo en Ufir Valores en reales      Saldo de la corrección acumulada    Valor de "
	#define STR0005 "la corrección      Descripción            en Mayor auxiliar       corregidos          Deudor            Acreedor      Ampliación"
	#define STR0006 "ANULADO POR EL OPERADOR"
	#define STR0007 "BALANCE FINALIZADO EL "
	#define STR0008 "VALOR DE "
	#define STR0009 "E J E R C I C I O"
	#define STR0010 "Cuenta supeditadas                          Saldo en"
	#define STR0011 "Valores en "
	#define STR0012 "    Saldo de Correc. Acumulada          Valor de la"
	#define STR0013 "Cuentas supeditadas"
	#define STR0014 "la corrección"
	#define STR0015 "Descripción"
	#define STR0016 "Saldo en"
	#define STR0017 "en el Mayor auxiliar"
	#define STR0018 "Valores en"
	#define STR0019 "corregidos"
	#define STR0020 "Saldo de la corrección"
	#define STR0021 "Acumulada Deudor "
	#define STR0022 "Acumulada Acreedor"
	#define STR0023 "Valor de la"
	#define STR0024 "Ampliación"
	#define STR0025 "Registros"
	#define STR0026 "Por favor, espere..."
#else
	#ifdef ENGLISH
		#define STR0001 "Issue of the Result of the Fixed Asset Monetary Adjustment "
		#define STR0002 "per Account "
		#define STR0003 "Result of Monetary Adjustment "
		#define STR0004 "Accounts subject                              Balance  UFIR Amounts in Reais       Balance of Accum. Adjustm           Value of"
		#define STR0005 "the adjustment     Description            in Auxiliary Led.         adjusted           Debtor           Credit        Extension"
		#define STR0006 "CANCELLED BY THE OPERATOR  "
		#define STR0007 "BALANCE SHEET CLOSED IN"
		#define STR0008 "VALUE OF  "
		#define STR0009 "FISCAL YEAR      "
		#define STR0010 "Account under                               Balc.in  "
		#define STR0011 "Values in  "
		#define STR0012 "    Accum.Indexation Balance            Value of"
		#define STR0013 "Accts. subject "
		#define STR0014 "to correc."
		#define STR0015 "Descript."
		#define STR0016 "Balance in"
		#define STR0017 "in aux. ledger   "
		#define STR0018 "Values in"
		#define STR0019 "indexed   "
		#define STR0020 "Indexation blnce."
		#define STR0021 "Debit accumul.  "
		#define STR0022 "Credit accumul. "
		#define STR0023 "Amnt. of"
		#define STR0024 "Ampliat. "
		#define STR0025 "Records  "
		#define STR0026 "Please wait..."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Emissão De Resultado Da Correcção Monetária Do Activo", "Emissäo de Resultado da Correcao Monetaria do Ativo" )
		#define STR0002 "Fixo Por Conta."
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Resultado Da Correcção Monetária", "Resultado da Correcao Monetaria" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Contas sujeitas                               saldo em ufir valores em reais       saldo da correcção acumulada         valor da", "Contas sujeitas                               Saldo em Ufir Valores em Reais       Saldo da Correcao Acumulada         Valor da" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "A Correcção         Descrição              Na Razão Auxiliar       Corrigidos          Devedor           Credor        Ampliacão", "a correcao         Descricao              no Razao Auxiliar       corrigidos          Devedor           Credor        Ampliacao" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Cancelado Pelo Operador", "CANCELADO PELO OPERADOR" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Balanço encerrado em ", "BALANCO ENCERRADO EM " )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Valor da  ", "VALOR DA  " )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "E X E R C í C I O", "E X E R C I C I O" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Contas sujeitas                              saldo em ", "Conta sujeitas                              Saldo em " )
		#define STR0011 "Valores em "
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "    saldo da correcção acumulada         valor da", "    Saldo da Correcao Acumulada         Valor da" )
		#define STR0013 "Contas sujeitas"
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "A correcção", "a correcao" )
		#define STR0015 "Descrição"
		#define STR0016 "Saldo em"
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Na Razão Auxiliar", "no Razão Auxiliar" )
		#define STR0018 "Valores em"
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Corrigidos", "corrigidos" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Saldo Da Correcção", "Saldo da Correção" )
		#define STR0021 "Acumulada Devedor"
		#define STR0022 "Acumulada Credor"
		#define STR0023 "Valor da"
		#define STR0024 "Ampliação"
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "Registos", "Registros" )
		#define STR0026 "Favor Aguardar..."
	#endif
#endif
