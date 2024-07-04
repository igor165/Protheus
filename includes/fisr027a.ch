#ifdef SPANISH
	#define STR0001 "DECLARACION INFORMATIVA RETENCION DE IVA - VENEZUELA"
	#define STR0002 "RIF"
	#define STR0003 "Periodo"
	#define STR0004 "Fecha"
	#define STR0005 "Tipo"
	#define STR0006 "Número"
	#define STR0007 "Monto Total"
	#define STR0008 "Base"
	#define STR0009 "Monto"
	#define STR0010 "Documento"
	#define STR0011 "Monto Excento"
	#define STR0012 "Alicuota"
	#define STR0013 "de"
	#define STR0014 "Agente"
	#define STR0015 "Imp."
	#define STR0016 "Doc"
	#define STR0017 "Op."
	#define STR0018 "Proveedor"
	#define STR0019 "Control"
	#define STR0020 "Imponible"
	#define STR0021 "IVA"
	#define STR0022 "Retenido"
	#define STR0023 "Afectado"
	#define STR0024 "Comprobante"
	#define STR0025 "Expediente"
	#define STR0026 "Codigo"
	#define STR0027 "Porcentaje"
	#define STR0028 "Factura"
	#define STR0029 "Concepto"
	#define STR0030 "Operacion"
	#define STR0031 "Ha ocurrido un error al generar el archivo, intente nuevamente."
	#define STR0032 "Generación de Archivo Magnético"
	#define STR0033 "¡Archivo texto generado con éxito!"
	#define STR0034 "DECLARACION INFORMATIVA RETENCION DE ISLR  - VENEZUELA"
#else
	#ifdef ENGLISH
		#define STR0001 "IVA WITHHOLDING INFORMATION STATEMENT - VENEZUELA"
		#define STR0002 "RIF"
		#define STR0003 "Period"
		#define STR0004 "Date"
		#define STR0005 "Type"
		#define STR0006 "Number"
		#define STR0007 "Total Value"
		#define STR0008 "Base"
		#define STR0009 "Value"
		#define STR0010 "Document"
		#define STR0011 "Exempt Value"
		#define STR0012 "Rate"
		#define STR0013 "from"
		#define STR0014 "Agent"
		#define STR0015 "Imp."
		#define STR0016 "Doc"
		#define STR0017 "Op."
		#define STR0018 "Supplier"
		#define STR0019 "Control"
		#define STR0020 "Taxable"
		#define STR0021 "VAT"
		#define STR0022 "Withheld"
		#define STR0023 "Affected"
		#define STR0024 "Receipt"
		#define STR0025 "Form"
		#define STR0026 "Code"
		#define STR0027 "Percentage"
		#define STR0028 "Invoice"
		#define STR0029 "Budget"
		#define STR0030 "Operation"
		#define STR0031 "Error generating file. Try again."
		#define STR0032 "Magnetic File Generation"
		#define STR0033 "Text file successfully generated"
		#define STR0034 "ISLR WITHHOLDING INFORMATION STATEMENT - VENEZUELA"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "DECLARACION INFORMATIVA RETENCION DE IVA - VENEZUELA", "DECLARAÇÃO INFORMATIVA RETENÇÃO DE IVA - VENEZUELA" )
		#define STR0002 "RIF"
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Periodo", "Período" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Fecha", "Data" )
		#define STR0005 "Tipo"
		#define STR0006 "Número"
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Monto Total", "Valor Total" )
		#define STR0008 "Base"
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Monto", "Valor" )
		#define STR0010 "Documento"
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Monto Excento", "Valor Isento" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Alicuota", "Alíquota" )
		#define STR0013 "de"
		#define STR0014 "Agente"
		#define STR0015 "Imp."
		#define STR0016 "Doc"
		#define STR0017 "Op."
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Proveedor", "Fornecedor" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Control", "Controle" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Imponible", "Tributável" )
		#define STR0021 "IVA"
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "Retenido", "Retido" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Afectado", "Afetado" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Comprobante", "Comprovante" )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "Expediente", "Formulário" )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Codigo", "Código" )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Porcentaje", "Porcentagem" )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "Factura", "Nota Fiscal" )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "Concepto", "Verba" )
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "Operacion", "Operação" )
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "Ha ocurrido un error al generar el archivo, intente nuevamente.", "Aconteceu um erro durante a geração do arquivo. Tente novamente." )
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "Generación de Archivo Magnético", "Geração de Arquivo Magnético" )
		#define STR0033 If( cPaisLoc $ "ANG|PTG", "¡Archivo texto generado con éxito!", "Arquivo texto gerado com sucesso!" )
		#define STR0034 If( cPaisLoc $ "ANG|PTG", "DECLARACION INFORMATIVA RETENCION DE ISLR  - VENEZUELA", "DECLARAÇÃO INFORMATIVA RETENÇÃO DE ISLR - VENEZUELA" )
	#endif
#endif
