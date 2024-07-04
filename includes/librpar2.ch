#ifdef SPANISH
	#define STR0001 "Este programa imprimirá los Libros de IVA Compras y Ventas"
	#define STR0002 "basado en la ley 125/91.  Se puede  emitir todo el movimiento "
	#define STR0003 "de los libros en la moneda local del país.           "
	#define STR0004 "Libros de Compras o Ventas - Ley 125/91"
	#define STR0005 ""
	#define STR0006 "Administración"
	#define STR0007 "LIBROS DE COMPRA Y VENTAS - Ley 125/91"
	#define STR0008 "LIBRO DE COMPRAS Ley 125/91"
	#define STR0009 "LIBRO DE VENTAS Ley 125/91"
	#define STR0010 "NÚMERO         FECHA      RAZÓN SOCIAL/APELLIDOS     R.U.C                GRABADAS       IMPUESTOS         EXENTAS             TOTAL"
	#define STR0011 "NÚMERO        Tipo    FECHA   RAZÓN SOCIAL/APELLIDOS     R.U.C            GRABADAS       IMPUESTOS         EXENTAS             TOTAL"
	#define STR0012 "Seleccionando registros..."
	#define STR0013 "TOTAL"
	#define STR0014 "RESUMEN COMPRAS - Ley 125/91"
	#define STR0015 "RESUMEN VENTAS - Ley 125/91"
	#define STR0016 "Tipo AFECTACIÓN  Tipo DE COMPROBANTE                     GRABADAS           IMPUESTOS             EXENTAS"
	#define STR0017 "DIRECTO"
	#define STR0018 "INDIRECTO"
	#define STR0019 "FACTURA PROVEEDOR"
	#define STR0020 "FACTURA CLIENTE"
	#define STR0021 "NOTA DE CRÉDITO"
	#define STR0022 "TOTAL GENERAL"
#else
	#ifdef ENGLISH
		#define STR0001 "This program prints the VAT Purchases and Sales Records"
		#define STR0002 "based on Law 125/91. You can issue the entire transaction"
		#define STR0003 "records in the country's local currency.             "
		#define STR0004 "Purchases and Sales Records - Law 125/91"
		#define STR0005 " "
		#define STR0006 "Management"
		#define STR0007 "PURCHASE AND SALES RECORDS - Law 125/91"
		#define STR0008 "PURCHASES RECORD Law 125/91"
		#define STR0009 "SALES RECORD Law 125/91"
		#define STR0010 "NUMBER         DATE       COMPANY NAME/SURNAMES      C.P.F                TAXED          TAXES             EXEMPT              TOTAL"
		#define STR0011 "NUMBER        TYPE    DATE    COMPANY NAME/SURNAMES      C.P.F            TAXED            TAXES            EXEMPT             TOTAL"
		#define STR0012 "Selecting Records..."
		#define STR0013 "GRAND TOTAL"
		#define STR0014 "PURCHASES SUMMARY - Law 125/91"
		#define STR0015 "SALES SUMMARY - Law 125/91"
		#define STR0016 "TAXATION TYPE    RECEIPT TYPE                           TAXED              TAXES                  EXEMPT"
		#define STR0017 "DIRECT"
		#define STR0018 "INDIRECT"
		#define STR0019 "SUPPLIER INVOICE"
		#define STR0020 "CUSTOMER INVOICE"
		#define STR0021 "CREDIT NOTE"
		#define STR0022 "GRAND TOTAL"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Este programa imprimira los libros de iva compras y ventas con", "Este programa irá imprimir os Livros de IVA Compras e Vendas com" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Base en la ley 125/91.  se puede  emitir todo el movimiento de", "base na Lei 125/91.  É possível emitir todo o movimento" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Los libros en la moneda local del pais.                       ", "livros na moeda local do país.                       " )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Libros de compras o ventas - ley 125/91", "Livros de Compras ou Vendas - Lei 125/91" )
		#define STR0005 ""
		#define STR0006 "Administração"
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Libros de compra y ventas - ley 125/91", "LIVROS DE COMPRA E VENDAS - Lei 125/91" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Libro de compras ley 125/91", "LIVRO DE COMPRAS Lei 125/91" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Libro de ventas ley 125/91", "LIVRO DE VENDAS Lei 125/91" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Seleccionando Registos...", "NÚMERO         DATA       RAZÃO SOCIAL/SOBRENOMES    R.U.C                TRIBUTADAS     IMPOSTOS          ISENTAS             TOTAL" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Número        Tipo    Fecha   Razon Social/apellidos     R.u.c            Gravadas       Impuestos         Exentas             Total", "NÚMERO        TIPO    DATA    RAZÃO SOCIAL/SOBRENOMES    R.U.C            TRIBUTADAS     IMPOSTOS          ISENTAS             TOTAL" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Seleccionando Registos...", "Selecionando Registros..." )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Total Geral", "TOTAL GERAL" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Resumen compras - ley 125/91", "RESUMO  COMPRAS - Lei 125/91" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Resumen ventas - ley 125/91", "RESUMO  VENDAS - Lei 125/91" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Tipo Afectacion  Tipo De Comprobante                     Gravadas           Impuestos             Exentas", "TIPO TRIBUTAÇÃO  TIPO DE COMPROVANTE                     TRIBUTADAS         IMPOSTOS              ISENTAS" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Directo", "DIRETO" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Indirecto", "INDIRETO" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Factura Proveedor", "NF FORNECEDOR" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Factura Cliente", "NF CLIENTE" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Nota De Crédito", "NOTA DE CRÉDITO" )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "Suma Total", "TOTAL GERAL" )
	#endif
#endif
