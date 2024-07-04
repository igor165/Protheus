#ifdef SPANISH
	#define STR0001 "Volante de Pago Electrónico"
	#define STR0002 "Esta rutina obtiene el Volante de Pago Electrónico por empleado, de acuerdo a los parámetros seleccionados."
	#define STR0003 "Las informaciones de los volantes son enviadas al Proveedor Tecnológico, quien valida y transmite a la DIAN."
	#define STR0004 "Opcionalmente, cada volante de pago electrónico puede ser enviado por correo a los empleados correspondientes."
	#define STR0005 "Atención"
	#define STR0006 "Debe indicar los periodos a informar."
	#define STR0007 "No se encontraron periodos para informar."
	#define STR0008 "Los periodos seleccionados no corresponden al mismo año y mes."
	#define STR0009 "Todos los periodos a informar deben tener Status de cerrado."
#else
	#ifdef ENGLISH
		#define STR0001 "Electronic Payment Form"
		#define STR0002 "This routine gets the Electronic Payment Form by employee according to the selected parameters."
		#define STR0003 "The form information is sent to the Technology Supplier, which validates and transmits it to the DIAN."
		#define STR0004 "Each electronic payment form can also be sent by mail to the corresponding employees."
		#define STR0005 "Attention"
		#define STR0006 "Enter the periods."
		#define STR0007 "No periods found."
		#define STR0008 "The selected periods do not correspond to the same year and month."
		#define STR0009 "All periods statuses must be Closed."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Volante de Pago Electrónico", "Formulário Eletrônico de Pagamento" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Esta rutina obtiene el Volante de Pago Electrónico por empleado, de acuerdo a los parámetros seleccionados.", "Esta rotina obtém o Fomulário de Pagamento Eletrônico por funcionário, conforme os parâmetros selecionados." )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Las informaciones de los volantes son enviadas al Proveedor Tecnológico, quien valida y transmite a la DIAN.", "As informações dos formulários são enviadas para o Fornecedor Tecnológico, quem valida e transmite para DIAN." )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Opcionalmente, cada volante de pago electrónico puede ser enviado por correo a los empleados correspondientes.", "Opcionalmente, cada formulário de pagamento eletrônico pode ser enviado pelo correio aos funcionários correspondentes." )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Atención", "Atenção" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Debe indicar los periodos a informar.", "Deve indicar os períodos a informar." )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "No se encontraron periodos para informar.", "Não foram encontrados períodos a informar." )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Los periodos seleccionados no corresponden al mismo año y mes.", "Os períodos selecionados não correspondem ao mesmo ano e mês." )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Todos los periodos a informar deben tener Status de cerrado.", "Todos os períodos a informar devem ter Status de fechado." )
	#endif
#endif
