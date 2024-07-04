#ifdef SPANISH
	#define STR0001 "Es necesario informar los siguientes datos en el encabezado:"
	#define STR0002 "Es necesario informar en el encabezado el campo ###"
	#define STR0003 "El campo ###("
	#define STR0004 "), no contiene un tipo de operación válido para el tipo de documento."
	#define STR0005 "Atención"
	#define STR0006 "OK"
	#define STR0007 "La nota Serie y Nro"
	#define STR0008 " no puede Anularse/Eliminarse pues fue procesado por la Transmisión electrónica. Utilice Nota de crédito para anular el documento."
	#define STR0009 " no puede borrarse, pues fue procesada por la Transmisión electrónica. Utilice la opción Anular"
	#define STR0010 "TSS: Transmisión electrónica."
#else
	#ifdef ENGLISH
		#define STR0001 "Enter the following information in the header:"
		#define STR0002 "Fill in the header the field ###"
		#define STR0003 "Field ###("
		#define STR0004 ") does not contain a valid transaction type for the document type."
		#define STR0005 "Attention"
		#define STR0006 "OK"
		#define STR0007 "Invoice Series and Number"
		#define STR0008 "cannot be Canceled/Deleted because it was processed by Electronic Transmission. User Credit Note to cancel document."
		#define STR0009 "cannot be deleted because it was processed by Electronic Transmission. Use option Cancel"
		#define STR0010 "TSS: Electronic Transmission."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Es necesario informar los siguientes datos en el encabezado:", "É necessário informar os seguintes dados no cabeçalho:" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Es necesario informar en el encabezado el campo ###", "É necessário informar no cabeçalho o campo ###" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "El campo ###(", "O campo ###(" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "), no contiene un tipo de operación válido para el tipo de documento.", "), não contém um tipo de operação válido para o tipo de documento." )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Atención", "Atenção" )
		#define STR0006 "OK"
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "La nota Serie y Nro", "A nota Série e Nro" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", " no puede Anularse/Eliminarse pues fue procesado por la Transmisión electrónica. Utilice Nota de crédito para anular el documento.", "não pode ser Cancelada/Removida, pois foi processada pela Transmissão Eletrônica. Utilize Nota de Crédito para cancelar o documento." )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", " no puede borrarse, pues fue procesada por la Transmisión electrónica. Utilice la opción Anular", "não pode ser excluída, pois foi processada pela Transmissão Eletrônica. Utilize a opção Cancelar" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "TSS: Transmisión electrónica.", "TSS: Transmissão Eletrônica." )
	#endif
#endif
