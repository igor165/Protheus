#ifdef SPANISH
	#define STR0001 "Emisión del Libro de Facturas y Boletas"
	#define STR0002 "Se solicitarán el mes y año de movimiento para la emisión "
	#define STR0003 "del libro de IVA Ventas"
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
	#define STR0017 "SEPTIEMBRE"
	#define STR0018 "OCTUBRE  "
	#define STR0019 "NOVIEMBRE"
	#define STR0020 "DICIEMBRE"
	#define STR0021 "V E N T A S   C O N   B O L E T A S"
	#define STR0022 "Empresa: "
	#define STR0023 "Página N.: "
	#define STR0024 "RUT: "
	#define STR0025 "Mes "
	#define STR0026 "Año"
	#define STR0027 "Resumen :"
	#define STR0028 "Transporte :"
	#define STR0029 "Facturas           :"
	#define STR0030 "Boletas            :"
	#define STR0031 "Ventas Exentas IVA :"
	#define STR0032 "¿Fomulario esta en posición? "
	#define STR0033 "¿Intentar nuevamente? "
	#define STR0034 "   Fecha         Rango de Boletas                   Ventas Exentas                                   Ventas Afect.  IVA               "
	#define STR0035 "                 Del nº   Al nº               Con Boletas     Sin Boletas                 Con Boletas    Sin Boletas        T O T A L "
	#define STR0036 "V E N T A S   C O N   F A C T U R A S"
	#define STR0037 "       Factura    Fecha       RUT            CLIENTE                                        Ventas                          VENTAS AFECTADAS                "
	#define STR0038 "                                                                                            Exentas            Valor Neto              IVA            Total         "
	#define STR0039 "T O T A L E S : "
	#define STR0040 "Subtotales "
	#define STR0041 "Menos IVA "
	#define STR0042 "Totales   "
#else
	#ifdef ENGLISH
		#define STR0001 "Issuance of the Invoice and Slips Records "
		#define STR0002 "Month and year of the transaction will be requested for issue "
		#define STR0003 "of Sales VAT records"
		#define STR0004 "Special"
		#define STR0005 "Administration"
		#define STR0006 "Filtering records ..."
		#define STR0007 "** CANCELLED BY THE OPERATOR **"
		#define STR0008 "** C A N C E L L E D **"
		#define STR0009 "JANUARY  "
		#define STR0010 "FEBRUARY"
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
		#define STR0021 "SALES WITH BANK SLIPS"
		#define STR0022 "Company: "
		#define STR0023 "Page No.: "
		#define STR0024 "RUT: "
		#define STR0025 "Month "
		#define STR0026 "Year"
		#define STR0027 "Summary :"
		#define STR0028 "Transportation:"
		#define STR0029 "Invoices      :"
		#define STR0030 "Bank Slips         :"
		#define STR0031 "Exempt Sales VAT :"
		#define STR0032 "Is the form selected? "
		#define STR0033 "Try Again? "
		#define STR0034 "   Date          Range of Bank Slips                Exempt Sales                                     Taxable Sales  VAT               "
		#define STR0035 "                 From n   To n.               w/slips         w/o slips                   w/slips        w/o slips          T O T A L "
		#define STR0036 "INVOICED SALES                       "
		#define STR0037 "      Invoice     Date       CNPJ           CUSTOMER                                        Sales                           TAXABLE SALES                   "
		#define STR0038 "                                                                                            Exempt            Net amount               VAT            Total         "
		#define STR0039 "T O T A L S   : "
		#define STR0040 "Subtotal "
		#define STR0041 "Less IVA "
		#define STR0042 "Total     "
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Emissão Do Livro De Notas Fiscais E Boletas", "Emissão do Livro de Notas Fiscais e Boletos" )
		#define STR0002 "Serão solicitados o mês e ano de movimento para a emissão "
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Do Livro De Iva Vendas", "do livro de IVA Vendas" )
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
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Noviembre", "NOVEMBRO " )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Diciembre", "DEZEMBRO " )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "V E N T A S   C O N   B O L E T A S", "V E N D A S   C O M   B O L E T O S" )
		#define STR0022 "Empresa: "
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Pagina n.: ", "Página N.: " )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Rut: ", "CNPJ: " )
		#define STR0025 "Mês "
		#define STR0026 "Ano"
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Resumen :", "Resumo :" )
		#define STR0028 "Transporte :"
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "Facturas           :", "Notas Fiscais      :" )
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "Boletas            :", "Boletos            :" )
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "Ventas exentas iva :", "Vendas Isentas IVA :" )
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "¿fomulario esta en posicion? ", "Fomulário está selecionado? " )
		#define STR0033 If( cPaisLoc $ "ANG|PTG", "¿intenta nuevamente? ", "Tentar Novamente? " )
		#define STR0034 If( cPaisLoc $ "ANG|PTG", "   fecha         rango de boletas                   ventas exentas                                   ventas afectas iva               ", "   Data          Faixa de Boletos                   Vendas Isentas                                   Vendas Tribut. IVA               " )
		#define STR0035 If( cPaisLoc $ "ANG|PTG", "                 del n.   al n.               con boletas     sin boletas                 con boletas    sin boletas        t o t a l ", "                 Do Nº    Até o Nº            Com Boletos     Sem Boletos                 Com Boletos    Sem Boletos        T O T A L " )
		#define STR0036 If( cPaisLoc $ "ANG|PTG", "V E N T A S   C O N   F A C T U R A S", "V E N D A S   C O M   NF             " )
		#define STR0037 If( cPaisLoc $ "ANG|PTG", "       factura    fecha       rut            cliente                                        ventas                          ventas afectas                  ", "       NF         Data        CNPJ           CLIENTE                                        Vendas                          VENDAS TRIBUTÁVEIS              " )
		#define STR0038 If( cPaisLoc $ "ANG|PTG", "                                                                                            exentas            valor neto              iva            total         ", "                                                                                            Isentas            Valor Líquido           IVA            Total         " )
		#define STR0039 If( cPaisLoc $ "ANG|PTG", "Totais", "T O T A I S   : " )
		#define STR0040 "Subtotais "
		#define STR0041 If( cPaisLoc $ "ANG|PTG", "Menos iva ", "Menos IVA " )
		#define STR0042 "Totais    "
	#endif
#endif
