#ifdef SPANISH
	#define STR0001 'Es una compensación de documentos.'
	#define STR0002 'Existen documentos seleccionados que fueron pagados en una sola exhibición (PUE)'
	#define STR0003 'Existen documentos seleccionados que requieren generación de complemento de pago (con condición de pago en parcialidades - PPD).'
	#define STR0004 'Solución: Realizar procesos por separado en diferentes recibos.'
	#define STR0005 'Se está intenando dar de baja documentos con forma de pago en una sola exhibición (PUE) y Parcialidades (PPD).'
	#define STR0006 'No se solicitará el timbrado del recibo, por las siguientes características:'
	#define STR0007 'Observaciones'
	#define STR0008 'No se permitirá el grabado del recibo, por las siguientes características:'
	#define STR0009 'Atención'
#else
	#ifdef ENGLISH
		#define STR0001 "Is a document compensation."
		#define STR0002 "Some selected documents were paid in one display (PUE)"
		#define STR0003 "Some selected documents need a payment complement (with payment term Installments - PPD)."
		#define STR0004 "Solution: perform processes separately in different receipts."
		#define STR0005 "You are attempting to download documents with payment method in one display (PUE) and Installments (PPD)."
		#define STR0006 "Receipt stamp will not be requested because of the following characteristics:"
		#define STR0007 "Notes"
		#define STR0008 "Receipt taxing will not be allowed because of the following characteristics:"
		#define STR0009 "Attention"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", 'Es una compensación de documentos.', "É uma compensação de documentos." )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", 'Existen documentos seleccionados que fueron pagados en una sola exhibición (PUE)', "Existem documentos selecionados que foram pagos em uma só exibição (PUE)" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", 'Existen documentos seleccionados que requieren generación de complemento de pago (con condición de pago en parcialidades - PPD).', "Existem documentos selecionados que precisam de um complemento de pagamento (com condição de pagamento parcelado - PPD)." )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", 'Solución: Realizar procesos por separado en diferentes recibos.', "Solução: realizar processos por separado em diferentes recibos." )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", 'Se está intenando dar de baja documentos con forma de pago en una sola exhibición (PUE) y Parcialidades (PPD).', "Se está tentando baixar documentos com forma de pagamento em uma sola exibição (PUE) e Parcelas (PPD)." )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", 'No se solicitará el timbrado del recibo, por las siguientes características:', "Não será solicitado o timbrado do recibo, pelas seguintes caraterísticas:" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", 'Observaciones', "Observações" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", 'No se permitirá el grabado del recibo, por las siguientes características:', "Não será permitida a tributação do recibo, pelas seguintes caraterísticas:" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", 'Atención', "Atenção" )
	#endif
#endif
