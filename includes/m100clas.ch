#ifdef SPANISH
	#define STR0001 "Preparando remitos..."
	#define STR0002 "Preparando guías de despacho..."
	#define STR0003 "Preparando remisiones..."
	#define STR0004 "Preparando notas de entrega..."
	#define STR0005 "Remitos de compras"
	#define STR0006 "Seleccionando remitos..."
	#define STR0007 "Guías de despacho"
	#define STR0008 "Seleccionando guías de despacho..."
	#define STR0009 "Envío"
	#define STR0010 "Seleccionando remisión..."
	#define STR0011 "Notas de entrega"
	#define STR0012 "Seleccionando notas de entrega..."
	#define STR0013 "Cargando la factura"
	#define STR0014 "¿RUT               ?"
	#define STR0015 "¿De proveedor      ?"
	#define STR0016 "¿Sucursal          ?"
	#define STR0017 "¿Fecha de emisión  ?"
	#define STR0018 "¿A                 ?"
	#define STR0019 "Clasificar         "
	#define STR0020 "Total"
	#define STR0021 "Total-Dev."
	#define STR0022 "Preparando conduce..."
	#define STR0023 "Conduce"
	#define STR0024 "Seleccionando conduce..."
	#define STR0025 "Seleccionando "
	#define STR0026 "Preparando "
	#define STR0027 " de Compras"
#else
	#ifdef ENGLISH
		#define STR0001 "Preparing Remitos..."
		#define STR0002 "Preparing Guias de despacho..."
		#define STR0003 "Preparing Remisiones..."
		#define STR0004 "Preparing Facturas de Entrega..."
		#define STR0005 "Remitos of Purchase"
		#define STR0006 "Selecting Remitos..."
		#define STR0007 "Dispatch Forms"
		#define STR0008 "Selecting Guias de Despacho..."
		#define STR0009 "Remittance"
		#define STR0010 "Selecting remision..."
		#define STR0011 "Remittance Forms"
		#define STR0012 "Selecting Facturas de Entrega..."
		#define STR0013 "Invoice Loading"
		#define STR0014 "¨RUT               "
		#define STR0015 "¨From Supplier     ?"
		#define STR0016 "¨Branch            ?"
		#define STR0017 "¨Issue Date        ?"
		#define STR0018 "¨To                ?"
		#define STR0019 "Classify           "
		#define STR0020 "Total"
		#define STR0021 "Total-Ret."
		#define STR0022 "Preparing Conduce..."
		#define STR0023 "Conduce"
		#define STR0024 "Selecting Conduce..."
		#define STR0025 "Selecting "
		#define STR0026 "Preparing "
		#define STR0027 " of Purchase"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Preparar Guia De Remessas...", "Preparando Guias de Remessa..." )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "A preparar as guias de despacho...", "Preparando Guias de Remessa..." )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "A Preparar Remessas...", "Preparando Guias de Remessa..." )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "A Preparar As Facturas De Entrega...", "Preparando Guias de Remessa..." )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Guia De Remessas De Compras", "Guias de Remessa de Compras" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "A Seleccionar Guia De Remessas...", "Selecionando Guias de Remessa..." )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Guias De Despacho", "Guias de Remessa" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "A Seleccionar Guias De Despacho...", "Selecionando Guias de Remessa..." )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Remissão", "Guias de Remessa" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "A seleccionar remessas...", "Selecionando Guias de Remessa..." )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Facturas De Entrega", "Guias de Remessa" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "A Seleccionar Facturas De Entrega...", "Seleccionando Guias de Remessa..." )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "A Carrregar A Factura", "Carrregando a Nota Fiscal" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "¨NIB               ?", "¨CNPJ/CPF          ?" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "¨do fornecedor     ?", "¨Do Fornecedor     ?" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "¨loja              ?", "¨Loja              ?" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "¨data de emissão      ?", "¨Data Emissão      ?" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "¨até               ?", "¨Até               ?" )
		#define STR0019 "Classificar         "
		#define STR0020 "Total"
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Total-devolvido", "Total-Ret." )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "A Preparar A Viatura...", "Preparando Guia de Remessa..." )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Conduce", "Guia de Remessa" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "A Seleccionar A Viatura...", "Selecionando Guia de Remessa.." )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "A seleccionar ", "Selecionando " )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "A preparar ", "Preparando " )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", " De Compras", " de Compras" )
	#endif
#endif
