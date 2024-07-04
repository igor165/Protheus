#ifdef SPANISH
	#define STR0001 "Visualizar"
	#define STR0002 "Incluir"
	#define STR0003 "Modificar"
	#define STR0004 "Excluir"
	#define STR0005 "Imprimir"
	#define STR0006 "Copiar"
	#define STR0007 "Factura de Venta "
	#define STR0008 "Datos Factura de Venta"
	#define STR0009 "Registro de Pagos"
	#define STR0010 "Aviso"
	#define STR0011 "La sumatoria de los Pagos difiere del total de la Factura"
	#define STR0012 "La siguiente pantalla permite capturar los Pagos realizados a una Factura con "
	#define STR0013 "Condición de Pago de Contado. Si omite este paso, el documento digital (XML)  "
	#define STR0014 "contendrá errores y  no será autorizado."
	#define STR0015 "Desc. Form. Proc. Pago"
	#define STR0016 "Desc. Banco"
	#define STR0017 "Desc. Tipo Tarjeta"
	#define STR0018 "Total Factura"
	#define STR0019 "Desc. Tipo Pago"
	#define STR0020 "Atención"
	#define STR0021 "Debe registrar al menos un Pago que cubra el Total de la Factura. "
	#define STR0022 "Registra uno o varios Pagos hasta cubrir el monto total de la factura."
	#define STR0023 "OK"
	#define STR0024 "Pagos"
#else
	#ifdef ENGLISH
		#define STR0001 "View"
		#define STR0002 "Add"
		#define STR0003 "Edit"
		#define STR0004 "Delete"
		#define STR0005 "Print"
		#define STR0006 "Copy"
		#define STR0007 "Sales invoice"
		#define STR0008 "Sales invoice data"
		#define STR0009 "Payment Record"
		#define STR0010 "Notification"
		#define STR0011 "The sum of Payments is different than the Invoice total"
		#define STR0012 "The following screen enables you to capture the Payments made for an Invoice with"
		#define STR0013 "Payment Term in cash. This step is hidden, the digital document (XML)"
		#define STR0014 "Displays errors and will not be authorized."
		#define STR0015 "Disc. Form. Proc. Payment"
		#define STR0016 "Disc.Bk"
		#define STR0017 "Card Type Description"
		#define STR0018 "Invoice total"
		#define STR0019 "Payment Type Description"
		#define STR0020 "Attention"
		#define STR0021 "Register at least one Payment reaching the Invoice Total."
		#define STR0022 "Register one or more several Payments to the total value of the invoice."
		#define STR0023 "OK"
		#define STR0024 "Payments"
	#else
		#define STR0001 "Visualizar"
		#define STR0002 "Incluir"
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Modificar", "Alterar" )
		#define STR0004 "Excluir"
		#define STR0005 "Imprimir"
		#define STR0006 "Copiar"
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Factura de Venta ", "Nota Fiscal de Venda" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Datos Factura de Venta", "Dados Nota Fiscal de Venda" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Registro de Pagos", "Registro de Pagamentos" )
		#define STR0010 "Aviso"
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "La sumatoria de los Pagos difiere del total de la Factura", "A somatória dos Pagamentos é diferente do total da Nota Fiscal" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "La siguiente pantalla permite capturar los Pagos realizados a una Factura con ", "A seguinte tela permite capturar os Pagamentos efetuados para uma Nota Fiscal com" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Condición de Pago de Contado. Si omite este paso, el documento digital (XML)  ", "Condição de Pagamento à Vista. Este passo é omitido, o documento digital (XML)" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "contendrá errores y  no será autorizado.", "apresentará erros e não será autorizado." )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Desc. Form. Proc. Pago", "Desc. Form. Proc. Pagamento" )
		#define STR0016 "Desc. Banco"
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Desc. Tipo Tarjeta", "Desc. Tipo Cartão" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Total Factura", "Total Nota Fiscal" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Desc. Tipo Pago", "Desc. Tipo Pagamento" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Atención", "Atenção" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Debe registrar al menos un Pago que cubra el Total de la Factura. ", "Deve ser cadastrado ao menos um Pagamento que atinja o Total da Nota Fiscal." )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "Registra uno o varios Pagos hasta cubrir el monto total de la factura.", "Cadastra um ou vários Pagamentos até o valor total da nota fiscal." )
		#define STR0023 "OK"
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Pagos", "Pagamentos" )
	#endif
#endif
