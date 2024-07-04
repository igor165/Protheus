#ifdef SPANISH
	#define STR0001 "Archivo Texto|*.TXT"
	#define STR0002 "Grabar Búsqueda..."
	#define STR0003 "         DGII              | SECRETARÍA DE ESTADO DE FINANZAS                                   "
	#define STR0004 "         IR-4              | DIRECCIÓN GENERAL DE IMPUESTOS INTERNOS                             "
	#define STR0005 "                           | FORMATO PARA EL CÁLCULO DE LAS RETENCIONES MENSUALES DEL ASALARIADO"
	#define STR0006 "Agente de retención"
	#define STR0007 "PerÍodo"
	#define STR0008 "Hoja"
	#define STR0009 "Mes: "
	#define STR0010 "Año: "
	#define STR0011 "De: "
	#define STR0012 "Nº: "
	#define STR0013 "       IDENTIFICACIÓN DEL ASALARIADO         |                                 REMUNERACIONES PERCIBIDAS                        |                   LIQUIDACIÓN DEL IMPUESTO (LEY 11-92)"
	#define STR0014 "                              |              | SUELDOS PAG.   |REMUNERACIONES |OTRAS REM. PAG. |               |SUELDOS Y OTROS |               |                |SALDO A FAVOR DEL|SAL. FAVOR DE LA"
	#define STR0015 "APELLIDOS Y NOMBRES           |   CÉDULA O   | POR EL AGENTE  |PAGADAS  OTROS |POR EL   AGENTE | TOTAL PAGADO  |PAGOS SUJETOS A |  LIQUIDACIÓN  |  SALDO A FAV.  |ASAL COMP FUT RET|DIRECCIÓN GENERAL"
	#define STR0016 "      COMPLETOS               |   PASAPORTE  | DE  RETENCIÓN  | EMPLEADORES   |DE RETENCIÓN    |  EN EL MES    |   RETENCIÓN    |    PERÍODO    | DEL ASALARIADO |(Si H-1 es neg.) |(Si H-1 es pos.)"
	#define STR0017 "           A                  |      B       |        C       |       D       |        E       |        F      |        G       |       H       |       I        |        J        |        K       "
	#define STR0018 "(L)Número asalariados      "
	#define STR0019 "(M)Sujetos a retención     "
	#define STR0020 "TOTALES(RD$)"
	#define STR0021 "Llevar a la casilla con la letra (A) del Form. IR-13"
	#define STR0022 "Llevar a la casilla con la letra (B) del Form IR-13"
	#define STR0023 "El período debe informarse en el formato aaaadd"
#else
	#ifdef ENGLISH
		#define STR0001 "Text File|*.TXT"
		#define STR0002 "Save Search..."
		#define STR0003 "         DGII              | FEDERAL REVENUE                                   "
		#define STR0004 "         IR-4              | GENERAL DIRECTION OF INTERNAL TAXES                             "
		#define STR0005 "                           | FORMAT FOR CALCULATION OF MONTHLY WITHHOLDING OF THE WAGE EARNER"
		#define STR0006 "Withholding Agent"
		#define STR0007 "Period"
		#define STR0008 "Payroll"
		#define STR0009 "Month: "
		#define STR0010 "Year: "
		#define STR0011 "From: "
		#define STR0012 "No.: "
		#define STR0013 "       IDENTIFICATION OF WAGE EARNER          |                                 COMPENSATION RECEIVED                           |                   SETTLEMENT OF TAX (LAW 11-92)"
		#define STR0014 "                              |              | SALARIES PAID   |COMPENSATIONS |OTHER COMPENSATION PAID |               |SALARIES AND OTHERS |             |                |BALANCE IN FAVOR OF|SAL. IN FAVOR OF"
		#define STR0015 "SURNAMES AND NAMES            |   ID OR      | BY AGENT    |PAID OTHERS  |BY   AGENT   | TOTAL PAID   |PAID SUBJECT TO |  SETTLEMENT  |  BALANCE IN FAVOR  |WAGE EARNER COMP.FUT.WITHH|GENERAL DIRECTION"
		#define STR0016 "      FULL               |  PASSPORT  | OF WITHHOLDING  | EMPLOYERS   |OF WITHHOLDING    |  IN MONTH    |   WITHHOLDING    |    PERIOD    | FROM THE WAGE EARNER |(If H-1 is neg.) |(If H-1 is pos.)"
		#define STR0017 "           A                  |      B       |        C       |       D       |        E       |        F      |        G       |       H       |       I        |        J        |        K       "
		#define STR0018 "(L)Wage earner number      "
		#define STR0019 "(M)Subject to Withholding     "
		#define STR0020 "TOTAL(RD$)"
		#define STR0021 "Fill out cell with the letter (A) in Form.IR-13 "
		#define STR0022 "Take to cashier with letter (B) of Form Income Tax 13"
		#define STR0023 "Period must be entered under the format YYYYMM"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Ficheiro Texto|*.txt", "Arquivo Texto|*.TXT" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Gravar Pesquisa...", "Salvar Pesquisa..." )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "         DGII              | SECRETARIA DE ESTADO DE FINANÇAS                                   ", "         DGII              | RECEITA FEDERAL                                   " )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "         IR-4              | DIREÇÃO GERAL DE IMPOSTOS INTERNOS                            ", "         IR-4              | DIREÇÃO GERAL DE IMPOSTOS INTERNOS                             " )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "                           | Formato Para O Cálculo Das Retenções Mensais Do Assalariado", "                           | FORMATO PARA O CÁLCULO DAS RETENÇÕES MENSAIS DO ASSALARIADO" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Agente De Retenção", "Agente de Retenção" )
		#define STR0007 "Período"
		#define STR0008 "Folha"
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Mes: ", "Mês: " )
		#define STR0010 "Ano: "
		#define STR0011 "De: "
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "No: ", "Nº: " )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "       identificacion del asalariado         |                                 remuneraciones percibidas                        |                   liquidacion del impuesto (ley 11-92)", "       IDENTIFICAÇÃO DO ASSALARIADO          |                                 REMUNERAÇÕES RECEBIDAS                           |                   LIQUIDAÇÃO DO IMPOSTO (LEI 11-92)" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "                              |              | Salários Pag.   |remunerações |outras Rem. Pag. |               |salários E Otros |               |                |saldo A Favor Do|sal. Favor Da", "                              |              | SALÁRIOS PAG.   |REMUNERAÇÕES |OUTRAS REM. PAG. |               |SALÁRIOS E OUTROS |             |                |SALDO A FAVOR DO|SAL. FAVOR DA" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Apelidos E Nomes           |   Cédula Ou   | Pelo Agente  |pagas  Outros |pelo Agente | Total Pago  |pagamentos Sujeitos A |  Liquidação  |  Saldo A Fav.  |assal. Comp. Fut. Ret|direcção Geral", "SOBRENOMES E NOMES            |   RG OU      | PELO AGENTE    |PAGAS  OUTROS  |PELO   AGENTE   | TOTAL PAGO   |PAGOS SUJEITOS A |  LIQUIDAÇÃO  |  SALDO A FAV.  |ASSAL.COMP.FUT.RET|DIREÇÃO GERAL" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "      completos               |  passaporte  | de  retenção  | empregadores   |de retenção    |  no mês    |   retenção    |    período    | do assalariado |(se h-1 é neg.) |(se h-1 é pos.)", "      COMPLETOS               |  PASSAPORTE  | DE  RETENÇÃO  | EMPREGADORES   |DE RETENÇÃO    |  NO MÊS    |   RETENÇÃO    |    PERÍODO    | DO ASSALARIADO |(Se H-1 for neg.) |(Se H-1 for pos.)" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "           a                  |      b       |        c       |       d       |        e       |        f      |        g       |       h       |       i        |        j        |        k       ", "           A                  |      B       |        C       |       D       |        E       |        F      |        G       |       H       |       I        |        J        |        K       " )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "(l) número assalariados      ", "(L)Número assalariados      " )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "(m)sujeitos a retenção    ", "(M)Sujeitos a Retenção     " )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Totais(rd€)", "TOTAIS(RD$)" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Llevar a la casilla con la letra (a) del form.ir-13 ", "Incluir na célula com a letra (A) no Form.IR-13 " )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "Llevar A La Casilla Con La Letra (b) Del Form.ir-13", "Incluir na célula com a letra (B) no Form.IR-13" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "O período deve ser introduzido em formato aaaadd", "O período deve ser informado no formato aaaadd" )
	#endif
#endif
