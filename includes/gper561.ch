#ifdef SPANISH
	#define STR0001 "Archivo Texto|*.TXT"
	#define STR0002 "Grabar Búsqueda..."
	#define STR0003 "         DGII              | SECRETARÍA DE ESTADO DE FINANZAS                                                                                                  # PAGINA   "
	#define STR0004 "         IR-13             | DIRECCIÓN GENERAL DE IMPUESTOS INTERNOS                                                                                           AÑO FISCAL "
	#define STR0005 "Aprobado por el Contralor  | DECLARACIÓN JURADA ANUAL DEL AGENTE DE RETENCIÓN"
	#define STR0006 " General de la República   | DE ASALARIADOS"
	#define STR0007 "DATOS GENERALES DEL AGENTE DE RETENCIÓN"
	#define STR0008 "  APELLIDOS Y NOMBRES    |     CÉDULA O      |TOTAL DE SUELDOS |     OTRAS       | TOTAL PAGADO     |  OTROS PAGOS    |   IMPUESTO     |   IMPUESTO      |   SALDO A FAV.  |   DIFERENCIA   "
	#define STR0009 "                         |    PASAPORTE      |PAGADOS EN EL AÑO| REMUNERACIONES  |   EN EL AÑO      | SUJ. A RETENCIÓN|   LIQUIDADO    |  RET. Y PAGADO  |  DEL EMPLEADO   |     POR PAGAR    "
	#define STR0010 "           A             |        B          |        C        |       D         |        E         |         F       |        G       |       H         |        I        |        J       "
	#define STR0011 "Número asalariados"
	#define STR0012 "Sujetos a Retención"
	#define STR0013 "YO"
	#define STR0014 "EN MI CALIDAD DE AGENTE DE RETENCIÓN, POR LA PRESENTE DECLARO BAJO JURAMENTO QUE LOS DATOS"
	#define STR0015 "CONSIGNADOS EN LA PRESENTE DECLARACIóN SON CORRECTOS Y COMPLETOS Y QUE NO HE OMITIDO DATO"
	#define STR0016 "ALGUNO QUE LA MISMA DEBA DE CONTENER, CONSECUENTEMENTE TODO SU CONTENIDO ES LA FIEL"
	#define STR0017 "EXPRESIóN DE LA VERDAD."
	#define STR0018 "FIRMA DEL DECLARANTE"
	#define STR0019 "CEDULA-SERIE"
	#define STR0020 "IMPUESTO POR PAGAR"
	#define STR0021 "REGARGOS ART. 252 (   )%"
	#define STR0022 "INTERÉS INDEMNIZATORIO ART. 27(  )%"
	#define STR0023 "TOTAL POR PAGAR RD$"
	#define STR0024 "                         |                   |                 |                 |                  |   SUELDOS Y     |                |                 |                 |                "
	#define STR0025 "RESUMEN PARA EL PAGO"
#else
	#ifdef ENGLISH
		#define STR0001 "Text File|*.TXT"
		#define STR0002 "Save Search..."
		#define STR0003 "         DGII              | FEDERAL REVENUE                                                                                                 # PAGE   "
		#define STR0004 "         IR-13             | GENERAL DIRECTION OF INTERNAL TAXES                                                                                           FISCAL YEAR "
		#define STR0005 "Approved by Attorney   |  ANNUAL SWORN STATEMENT FROM WITHHOLDING AGENT"
		#define STR0006 " General of Republic   | WAGE EARNER"
		#define STR0007 "WITHHOLDING AGENT GENERAL DATA"
		#define STR0008 "  LAST NAMES AND NAMES   |     ID CARD OR    |  WAGES TOTAL  |     OTHERS       |   PAID TOTAL     |   OTHER PAYMENTS    |     TAX     |     TAX     |   BALANCE IN FAV.   |   DIFFERENCE  "
		#define STR0009 "                         |    PASSPORT       |PAID IN YEAR| COMPENSATIONS  |   IN YEAR    | SUBJ. TO WITHH.|   CLEARED    |  WITHH. AND PAID  |  FROM EMPLOYEE   |     PAYABLE    "
		#define STR0010 "           A             |        B          |        C        |       D         |        E         |         F       |        G       |       H         |        I        |        J       "
		#define STR0011 "Wage earner number"
		#define STR0012 "Subject to withholding"
		#define STR0013 "I, "
		#define STR0014 "AS A WITHHOLDING AGENT, DECLARE UNDER OATH, THAT DATA"
		#define STR0015 "REGISTERED IN THE PRESENT STATEMENT ARE CORRECT AND COMPLETE, AND NO DATA"
		#define STR0016 "WAS OMITTED, THEN ALL CONTENT IS THE FAITHFULL"
		#define STR0017 "EXPRESSION OF THE TRUTH."
		#define STR0018 "DECLARANT SIGNATURE"
		#define STR0019 "ID CARD-SERIES"
		#define STR0020 "TAX PAYABLE"
		#define STR0021 "ADDENDA ART. 252 (   )%"
		#define STR0022 "INDEMNIFICATION INTEREST ART. 27(  )%"
		#define STR0023 "TOTAL PAYABLE RD$"
		#define STR0024 "                         |                   |                 |                 |                  |   SALARIES AND    |                |                 |                 |                "
		#define STR0025 "SUMMARY FOR PAYMENT"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Ficheiro Texto|*.txt", "Arquivo Texto|*.TXT" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Gravar Pesquisa...", "Salvar Pesquisa..." )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "         dgii              | Direcção Geral de Contribuições e Impostos                                                                                                  # página   ", "         DGII              | RECEITA FEDERAL                                                                                                  # PÁGINA   " )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Irs-13             | direcção geral de impostos                                                                                         ano fiscal ", "         IR-13             | DIREÇÃO GERAL DE IMPOSTOS INTERNOS                                                                                           ANO FISCAL " )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Aprovado Pelo Controlador  | Declaração Anual Emitida Pela Entidade Patronal", "Aprovado pelo Procurador  | DECLARAÇÃO JURADA ANUAL DO AGENTE DE RETENÇÃO" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Geral Da República   | De Assalariados", " Geral da República   | DE ASSALARIADOS" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Dados Gerais Do Agente De Retenção", "DADOS GERAIS DO AGENTE DE RETENÇÃO" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "  apelidos e nomes    |    carteira profissional      |total de remunerações|     outras       | total pago     |  outros pagamentos    |   imposto     |   imposto      |   saldo a favor  |   diferença   ", "  SOBRENOMES E NOMES    |     RG OU      |TOTAL DE SALÁRIOS|     OUTRAS       | TOTAL PAGO     |  OUTROS PAGAMENTOS    |   IMPOSTO     |   IMPOSTO      |   SALDO A FAV.  |   DIFERENÇA   " )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "                         |    passaporte     |pagamentos por ano| remunerações |   por ano      | suj. a retenção|   liquidado    |  ret. e pago  |  do empregado   |     a pagar    ", "                         |    PASSAPORTE     |PAGOS NO ANO| REMUNERAÇÕES  |   NO ANO      | SUJ. A RETENÇÃO|   LIQUIDADO    |  RET. E PAGO  |  DO FUNCIONÁRIO   |     A PAGAR    " )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "           a             |        b          |        c        |       d         |        e         |         f       |        g       |       h         |        i        |        j       ", "           A             |        B          |        C        |       D         |        E         |         F       |        G       |       H         |        I        |        J       " )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Número de assalariados", "Número assalariados" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Sujeitos A Retenção", "Sujeitos a retenção" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Eu", "EU, " )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Na Qualidade De Agente De Retenção, Pela Presente Declaro Sob Juramento Que Os Dados", "NA MINHA QUALIDADE DE AGENTE DE RETENÇÃO, DECLARO SOB JURAMENTO, QUE OS DADOS" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Consignados Na Presente Declaração São Correctos E Completos E Que Não Omiti Dado", "REGISTRADOS NA PRESENTE DECLARAÇÃO, SÃO CORRETOS E COMPLETOS, E QUE NÃO FOI OMITIDO DADO" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Algum Que A Mesma Deva Conter, Sendo Em Consequência Todo O Seu Conteúdo A Si Fiel", "ALGUM, SENDO EM CONSEQUÊNCIA TODO O SEU CONTEÚDO, A FIEL" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Expressão Da Verdade", "EXPRESSÃO DA VERDADE." )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Firma Do Declarante", "ASSINATURA DO DECLARANTE" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Carteira profissional-série", "RG-SÉRIE" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Imposto A Pagar", "IMPOSTO A PAGAR" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Regargos art. 252 (   )%", "ADICIONAIS ART. 252 (   )%" )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "Juros indemnizatórios art. 27(  )%", "JUROS INDENIZATÓRIOS ART. 27(  )%" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Total A Pagar €", "TOTAL A PAGAR RD$" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "                         |                   |                 |                 |                  |   salários e     |                |                 |                 |                ", "                         |                   |                 |                 |                  |   SALÁRIOS E    |                |                 |                 |                " )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "Resumo Para Pagamento", "RESUMO PARA O PAGAMENTO" )
	#endif
#endif
