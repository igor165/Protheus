#ifdef SPANISH
	#define STR0001 "Cierre de Orden de Servicio"
	#define STR0002 "Buscar"
	#define STR0003 "Cerrar"
	#define STR0004 "Leyenda"
	#define STR0005 "Abierta"
	#define STR0006 "Liberada"
	#define STR0007 "Cerrada"
	#define STR0008 "Anulado"
	#define STR0009 "Tecnico no encontrado"
	#define STR0010 "Tecnico sin autorizacion en el archivo de equipo tecnico (VAI_FECOFI)."
	#define STR0011 "Muestra Parametros Facturacion"
	#define STR0012 "Informe si muestra los "
	#define STR0013 "Parametros de Facturacion en el"
	#define STR0014 "momento de generacion de Factura."
	#define STR0015 "No"
	#define STR0016 "Si"
	#define STR0017 "Busqueda Avanzada"
	#define STR0018 "Cond. Pago (Gar.)"
	#define STR0019 "Condicion de pago para calculo de las"
	#define STR0020 "cuotas para cierre garantia de"
	#define STR0021 "parte."
	#define STR0022 "Orden lista de piezas"
	#define STR0023 "Grupo + C�digo"
	#define STR0024 "C�digo"
	#define STR0025 "Define el orden de la lista de piezas."
#else
	#ifdef ENGLISH
		#define STR0001 "Service Order Closing"
		#define STR0002 "Search"
		#define STR0003 "Close"
		#define STR0004 "Subtitle"
		#define STR0005 "Open"
		#define STR0006 "Released"
		#define STR0007 "Closed"
		#define STR0008 "Canceled"
		#define STR0009 "Technician not found"
		#define STR0010 "Technician with no permission in the register of technician team (VAI_FECOFI)."
		#define STR0011 "Display Invoicing Parameters"
		#define STR0012 "Indicate if it shows "
		#define STR0013 "Invoicing Parameters in"
		#define STR0014 "the moment of Invoice generation."
		#define STR0015 "No"
		#define STR0016 "Yes"
		#define STR0017 "Advanced Search"
		#define STR0018 "Condition Payment (Warranty)"
		#define STR0019 "Payment terms to calculate"
		#define STR0020 "installments for closing warranty of the"
		#define STR0021 "part."
		#define STR0022 "Spare Parts List Order"
		#define STR0023 "Group + Code"
		#define STR0024 "Code"
		#define STR0025 "Define order of spare parts list."
	#else
		#define STR0001 "Fechamento de Ordem de Servi�o"
		#define STR0002 "Pesquisar"
		#define STR0003 "Fechar"
		#define STR0004 "Legenda"
		#define STR0005 "Aberta"
		#define STR0006 "Liberada"
		#define STR0007 "Fechada"
		#define STR0008 "Cancelada"
		#define STR0009 "T�cnico n�o encontrado"
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "T�cnico sem permiss�o no registo de equipa t�cnica (VAI_FECOFI).", "T�cnico sem permiss�o no cadastro de equipe t�cnica (VAI_FECOFI)." )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Mostra Par�metros Factura��o", "Mostra Parametros Faturamento" )
		#define STR0012 "Informe se mostra os "
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "par�metros da Factura��o no", "Parametros do Faturamento no" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "momento da gera��o da Factura.", "momento da gera��o da NF." )
		#define STR0015 "N�o"
		#define STR0016 "Sim"
		#define STR0017 "Pesq.Avan�ada"
		#define STR0018 "Cond. Pagto (Gar.)"
		#define STR0019 "Condi��o de pagamento para c�lculo das"
		#define STR0020 "parcelas para fechamento garantia de"
		#define STR0021 "pe�a."
		#define STR0022 "Ordem Lista de Pe�as"
		#define STR0023 "Grupo + C�digo"
		#define STR0024 "C�digo"
		#define STR0025 "Define a ordena��o da listagem de pe�as."
	#endif
#endif
