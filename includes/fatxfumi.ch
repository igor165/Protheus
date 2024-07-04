#ifdef SPANISH
	#define STR0001 "El documento seleccionado (###), no ha sido transmitido. Realice la transmisión e intente nuevamente."
	#define STR0002 "El UUID del documento seleccionado (###), no pertenece a un documento emitido con el modelo de validación posterior."
	#define STR0003 "El documento seleccionado (###), no ha sido transmitido y/o validado. Realice la transmisión y validación de recepción del documento e intente nuevamente."
#else
	#ifdef ENGLISH
		#define STR0001 "The selected document (###) was not transmitted. Transmit it and try again."
		#define STR0002 "The UUID of the selected document (###) does not belong to a document issued with the later validation model."
		#define STR0003 "The selected document (###) was not transmitted and/or validated. Transmit and validate the receipt of the document and try again."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "El documento seleccionado (###), no ha sido transmitido. Realice la transmisión e intente nuevamente.", "O documento selecionado (###), não foi transmitido. Realize a transmissão e tente novamente." )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "El UUID del documento seleccionado (###), no pertenece a un documento emitido con el modelo de validación posterior.", "O UUID do documento selecionado (###), não pertence a um documento emitido com o modelo de validação posterior." )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "El documento seleccionado (###), no ha sido transmitido y/o validado. Realice la transmisión y validación de recepción del documento e intente nuevamente.", "O documento selecionado (###), não foi transmitido e/ou validado. Efetue a transmissão e validação de recebimento do documento e tente novamente." )
	#endif
#endif
