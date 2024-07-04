#ifdef SPANISH
	#define STR0001 "Emisión del Libro de Tickets"
	#define STR0002 "Se solicitarán el mes y año de movimiento para la emisión "
	#define STR0003 "del libro de tickets de IVA Ventas"
	#define STR0004 "Especial"
	#define STR0005 "Administración"
	#define STR0006 "Filtrando registros..."
	#define STR0007 "** ANULADO POR EL OPERADOR **"
	#define STR0008 "** A N U L A D A **"
	#define STR0009 "ENERO    "
	#define STR0010 "FEBRERO  "
	#define STR0011 "MARZO    "
	#define STR0012 "ABRIL    "
	#define STR0013 "MAYO     "
	#define STR0014 "JUNIO    "
	#define STR0015 "JULIO    "
	#define STR0016 "AGOSTO   "
	#define STR0017 "SETIEMBRE"
	#define STR0018 "OCTUBRE  "
	#define STR0019 "NOVIEMBRE"
	#define STR0020 "DICIEMBRE"
	#define STR0021 "                    V E N T A S   C O N   T I C K E T S                "
	#define STR0022 "Empresa: "
	#define STR0023 "Página N.: "
	#define STR0024 "RIF: "
	#define STR0025 "Mes "
	#define STR0026 "Año"
	#define STR0027 "Resumen :"
	#define STR0028 "Transporte :"
	#define STR0029 "Facturas        :"
	#define STR0030 "Tickets         :"
	#define STR0031 "Ventas exentas IVA :"
	#define STR0032 "¿Fomulario esta en posición? "
	#define STR0033 "¿Intentar nuevamente? "
	#define STR0034 "    Fecha     Serie    Rango de Tickets                                                                                                                                                                                          "
	#define STR0035 "                       Del n.       Al n.                    Total Ventas          Base Impuesto          Valor Impuesto                                                                             "
	#define STR0036 "V E N T A S   C O N   F A C T U R A S"
	#define STR0037 "   Fecha    Serie   Factura       Docto.   Razón Social                       RIF                TOTAL Ventas         Base Impuesto         Alíc. Imp.(%)      Valor Impuesto                        "
	#define STR0038 "                                Valor Neto      IVA           Total         "
	#define STR0039 "T O T A L E S : "
	#define STR0040 "No hay datos para los parámetros digitados"
#else
	#ifdef ENGLISH
		#define STR0001 "Issue of Ticket Records"
		#define STR0002 "The month and year of transaction will be requested to issue "
		#define STR0003 "the ticket records of VAT Sales"
		#define STR0004 "Special"
		#define STR0005 "Management"
		#define STR0006 "Filtering records..."
		#define STR0007 "** CANCELLED BY THE OPERATOR **"
		#define STR0008 "** C A N C E L L E D **"
		#define STR0009 "JANUARY  "
		#define STR0010 "FEBRUARY "
		#define STR0011 "MARCH    "
		#define STR0012 "APRIL    "
		#define STR0013 "MAY      "
		#define STR0014 "JUNE     "
		#define STR0015 "JULY     "
		#define STR0016 "AUGUST   "
		#define STR0017 "SEPTEMBER"
		#define STR0018 "OCTOBER  "
		#define STR0019 "NOVEMBER"
		#define STR0020 "DECEMBER"
		#define STR0021 "                          T I C K E T  S A L E S                       "
		#define STR0022 "Company: "
		#define STR0023 "Page No.: "
		#define STR0024 "RIF: "
		#define STR0025 "Month "
		#define STR0026 "Year"
		#define STR0027 "Summary :"
		#define STR0028 "Transportation:"
		#define STR0029 "Invoices        :"
		#define STR0030 "Tickets         :"
		#define STR0031 "Exempt Sales   VAT :"
		#define STR0032 "Is the form selected?  "
		#define STR0033 "Try Again?        "
		#define STR0034 "    Date      Serial   Ticket Range                                                                                                                                                                                              "
		#define STR0035 "                       From No.     To No.                   Total Sales           Tax Basis              Tax Amount                                                                                 "
		#define STR0036 "INVOICED SALES                       "
		#define STR0037 "   Date     Serial  Invoice       Doc.     Company Name                       RIF                TOTAL Sales          Tax Basis             Tax Rate(%)        Tax Amount                            "
		#define STR0038 "                                NET AMOUNT      VAT           Total         "
		#define STR0039 "T O T A L S   : "
		#define STR0040 "No data exist for the entered parameters"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Emision Del Libro De Tickets", "Emissão do Livro de Tickets" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Seran solicitadas el mês y ano de movimiento para la emision ", "Serão solicitados o mês e ano do movimento para a emissão " )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Del Libro De Tickets De Iva Ventas", "do livro de tickets de IVA Vendas" )
		#define STR0004 "Especial"
		#define STR0005 "Administração"
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Filtrando registos...", "Filtrando registros..." )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "** cancelado pelo operador **", "** CANCELADO PELO OPERADOR **" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "** a n u l a d a **", "** C A N C E L A D A **" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Enero    ", "JANEIRO  " )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Febrero  ", "FEVEREIRO" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Marzo    ", "MARÇO    " )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Abril    ", "ABRIL    " )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Mayo     ", "MAIO     " )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Junio    ", "JUNHO    " )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Julio    ", "JULHO    " )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Agosto   ", "AGOSTO   " )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Setiembre", "SETEMBRO " )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Octubre  ", "OUTUBRO  " )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Noviembre", "NOVEMBRO" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Diciembre", "DEZEMBRO" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "                    v e n t a s   c o n   t i c k e t s                ", "                    V E N D A S   C O M   T I C K E T S                " )
		#define STR0022 "Empresa: "
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Pagina n.: ", "Página Nº: " )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Rif: ", "RIF: " )
		#define STR0025 "Mês "
		#define STR0026 "Ano"
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Resumen :", "Resumo :" )
		#define STR0028 "Transporte :"
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "Facturas        :", "Notas Fiscais   :" )
		#define STR0030 "Tickets         :"
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "Ventas exentas iva :", "Vendas Isentas IVA :" )
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "¿fomulario esta en posicion? ", "Fomulário está marcado? " )
		#define STR0033 If( cPaisLoc $ "ANG|PTG", "¿intenta nuevamente? ", "Tentar Novamente? " )
		#define STR0034 If( cPaisLoc $ "ANG|PTG", "    fecha     serie    rango de tickets                                                                                                                                                                                          ", "    Data      Série    Faixa de Tickets                                                                                                                                                                                          " )
		#define STR0035 If( cPaisLoc $ "ANG|PTG", "                       del n.       al n.                    total ventas          base impuesto          valor impuesto                                                                             ", "                       Do Nº        Até Nº                   Total Vendas          Base Imposto           Valor Imposto                                                                              " )
		#define STR0036 If( cPaisLoc $ "ANG|PTG", "V E N T A S   C O N   F A C T U R A S", "V E N D A S   C O M   NFs            " )
		#define STR0037 If( cPaisLoc $ "ANG|PTG", "   fecha    serie   factura        razon social                    rif                total ventas         base impuesto         valor impuesto                                                      ", "   Data     Série   NFs           Docto.   Razão Social                       RIF                TOTAL Vendas         Base Imposto          Alíq. Imp.(%)      Valor Imposto                         " )
		#define STR0038 If( cPaisLoc $ "ANG|PTG", "                                valor neto      iva           total         ", "                                Valor Líquido   IVA           Total         " )
		#define STR0039 If( cPaisLoc $ "ANG|PTG", "Totais", "T O T A I S   : " )
		#define STR0040 If( cPaisLoc $ "ANG|PTG", "No hay datos para los parâmetro s ingresados", "Não existem dados para os parâmetros incluídos" )
	#endif
#endif
