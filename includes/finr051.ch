#ifdef SPANISH
	#define STR0001 "Detracciones"
	#define STR0002 "Tít. de Detracción"
	#define STR0003 "Emisión"
	#define STR0004 "Baja"
	#define STR0005 "Fch. Depósito"
	#define STR0006 "Nº Comprobante"
	#define STR0007 "Fch Depósito"
	#define STR0008 "Total proveedor"
#else
	#ifdef ENGLISH
		#define STR0001 "Depreciation"
		#define STR0002 "Depreciation Bills"
		#define STR0003 "Issue"
		#define STR0004 "Write-off"
		#define STR0005 "Deposit Date"
		#define STR0006 "Slip Number"
		#define STR0007 "Deposit Date"
		#define STR0008 "Supplier Total"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Detracciones", "Detrações" )
		#define STR0002 "Títulos de detração"
		#define STR0003 "Emissão"
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Liquidação", "Baixa" )
		#define STR0005 "Data depósito"
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Nr.Comprovante", "Nro Comprovante" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Dt.Depósito", "Dt Depósito" )
		#define STR0008 "Total fornecedor"
	#endif
#endif
