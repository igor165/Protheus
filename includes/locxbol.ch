#ifdef SPANISH
	#define STR0001 "Es necesario informar en el encabezado el campo ###"
	#define STR0002 "El campo ### "
	#define STR0003 "no contiene información válida para el tipo de documento."
	#define STR0004 "Atención"
	#define STR0005 "Ok"
	#define STR0006 "Información faltante en registro del Cliente."
	#define STR0007 "Información faltante en registro del Control de Folios."
	#define STR0008 "Información faltante en registro del Producto."
	#define STR0009 " no contiene información."
	#define STR0010 "La ausencia de ésta información impedirá la transmisión del documento."
	#define STR0011 "El documento "
	#define STR0012 " no puede ser borrado/anulado pues ya fue transmitido. Utilice funcionalidad de Anulación de Factura Electrónica de la rutina Transmisión Electrónica (MATA486)."
	#define STR0013 " se encuentra en proceso de validación de anulación. Utilice funcionalidad de Monitor de la rutina Transmisión Electrónica."
#else
	#ifdef ENGLISH
		#define STR0001 "Fill in the header the field ###"
		#define STR0002 "Field ###"
		#define STR0003 "does not contain valid information for the type of document."
		#define STR0004 "Attention"
		#define STR0005 "Ok"
		#define STR0006 "Missing information in Customer register."
		#define STR0007 "Missing information in Folio Control register."
		#define STR0008 "Missing information in Product register."
		#define STR0009 "has no information."
		#define STR0010 "The absence of this information will prevent the transmission of the document."
		#define STR0011 "The document"
		#define STR0012 "cannot be deleted/canceled because it has already been transmitted. Use the Electronic Invoice Cancellation functionality of the Electronic Transmission routine (MATA486)."
		#define STR0013 "is in the process of canceling validation. Use the Monitor functionality of the Electronic Transmission routine."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Es necesario informar en el encabezado el campo ###", "É necessário informar no cabeçalho o campo ###" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "El campo ### ", "O campo ###" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "no contiene información válida para el tipo de documento.", "não contém informação válida para o tipo de documento." )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Atención", "Atenção" )
		#define STR0005 "Ok"
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Información faltante en registro del Cliente.", "Informação faltante em cadastro do Cliente." )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Información faltante en registro del Control de Folios.", "Informação faltante no cadastro de Controle de Fólios." )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Información faltante en registro del Producto.", "Informação faltante no cadastro do Produto." )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", " no contiene información.", "não contém informação." )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "La ausencia de ésta información impedirá la transmisión del documento.", "A ausência dessa informação impedirá a transmissão do documento." )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "El documento ", "O documento" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", " no puede ser borrado/anulado pues ya fue transmitido. Utilice funcionalidad de Anulación de Factura Electrónica de la rutina Transmisión Electrónica (MATA486).", "não pode ser apagado/cancelado porque já foi transmitido. Utilize a funcionalidade de Cancelamento de Nota Fiscal Eletrônica da rotina Transmissão Eletrônica (MATA486)." )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", " se encuentra en proceso de validación de anulación. Utilice funcionalidad de Monitor de la rutina Transmisión Electrónica.", "está em processo de validação de cancelamento. Utilize a funcionalidade de Monitor da rotina de Transmissão Eletrônica." )
	#endif
#endif
