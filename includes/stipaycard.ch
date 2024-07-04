#ifdef SPANISH
	#define STR0001 "Fecha"
	#define STR0002 "Valor"
	#define STR0003 "Cuotas"
	#define STR0004 "Efectuar Pago"
	#define STR0005 "Anular"
	#define STR0006 "Sucursal"
	#define STR0007 "Adm.Financiera"
	#define STR0008 "Adm.Finan"
	#define STR0009 "Valor informado superior al saldo por pagar. No se permite vuelto en tarjeta."
	#define STR0010 "Conforme a Item 4a1 del Req. XVI del PAF-ECF 02.01, no se permite cambio en tarjeta superior al R$10,00."
	#define STR0011 "NSU"
	#define STR0012 "Autorizacion"
	#define STR0013 "Seleccione la administradora de la tarjeta: "
	#define STR0014 "Selecci�n de la Administradora de tarjeta de cr�dito/d�bito"
	#define STR0015 "Lista de las administradoras registradas"
	#define STR0016 "Codigo"
	#define STR0017 "Tipo"
	#define STR0018 "Administradora"
	#define STR0019 "Seleccione la administradora"
	#define STR0020 "ID Tarjeta"
	#define STR0021 "Identific. Tarjeta"
	#define STR0022 "Por favor, complete el c�digo NSU y el c�digo de autorizaci�n."
	#define STR0023 "Administradora / Tipo "
	#define STR0024 "No se encontr� la administradora para la forma de pago informada."
	#define STR0025 "Inter�s Adm. Fin."
#else
	#ifdef ENGLISH
		#define STR0001 "Date"
		#define STR0002 "Value"
		#define STR0003 "Installments"
		#define STR0004 "Payment"
		#define STR0005 "Cancel"
		#define STR0006 "Branch"
		#define STR0007 "Financial Company"
		#define STR0008 "Fin. Adm."
		#define STR0009 "Value entered higher than balance payable. Change in card not allowed."
		#define STR0010 "According to Item 4a of PAF-ECF ER 02.01 Requisite XVI, change in card higher than R$10,00 is not allowed."
		#define STR0011 "NSU"
		#define STR0012 "Authorization"
		#define STR0013 "Select credit card administrator: "
		#define STR0014 "Credit/Debit Card Administrator Selection"
		#define STR0015 "List of Registered Credit Card Companies"
		#define STR0016 "Code"
		#define STR0017 "Type"
		#define STR0018 "Provider"
		#define STR0019 "Select card company"
		#define STR0020 "Card ID"
		#define STR0021 "Card Identification"
		#define STR0022 "Complete the NSU code and the authorization code!"
		#define STR0023 "Administrative Company/Type "
		#define STR0024 "Card Company not found for entered Payment Method."
		#define STR0025 "Fin.Adm.Interests"
	#else
		#define STR0001 "Data"
		#define STR0002 "Valor"
		#define STR0003 "Parcelas"
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Efectuar pagamento", "Efetuar Pagamento" )
		#define STR0005 "Cancelar"
		#define STR0006 "Filial"
		#define STR0007 "Adm.Financeira"
		#define STR0008 "Adm.Finan"
		#define STR0009 "Valor informado superior ao saldo a pagar. N�o � permitido troco em cart�o."
		#define STR0010 "Conforme Item 4a1 do Req. XVI do PAF-ECF 02.01, n�o � permitido troco em cartao superior a R$10,00."
		#define STR0011 "NSU"
		#define STR0012 "Autoriza��o"
		#define STR0013 "Selecione a administradora do cart�o: "
		#define STR0014 "Sele��o da Administradora de Cart�o de Cr�dito/D�bito"
		#define STR0015 "Lista das Administradoras Cadastradas"
		#define STR0016 "Codigo"
		#define STR0017 "Tipo"
		#define STR0018 "Administradora"
		#define STR0019 "Selecione a administradora"
		#define STR0020 "ID Cart�o"
		#define STR0021 "Identific. Cart�o"
		#define STR0022 "Por favor, preencha o c�digo NSU e o c�digo de autoriza��o!"
		#define STR0023 "Adminsitradora / Tipo "
		#define STR0024 "N�o foi encontrado Administradora para a Forma de Pagamento informada."
		#define STR0025 "Juros Adm. Fin."
	#endif
#endif
