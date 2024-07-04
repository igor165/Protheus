#ifdef SPANISH
	#define STR0001 "Ningun Cliente/Procedimiento seleccionado"
	#define STR0002 "Cliente nuevo ya transmitido, no se pueden incluir pedidos a este."
	#define STR0003 "Aviso"
	#define STR0004 "Atencion"
	#define STR0005 "Volver"
	#define STR0006 "Pedido"
	#define STR0007 "Incluir"
	#define STR0008 "Modificar"
	#define STR0009 "Borrar"
	#define STR0010 "Imprimir"
	#define STR0011 "Pedido N�"
	#define STR0012 "Emision"
	#define STR0013 "Cond. Pago"
	#define STR0014 "Ult.Pedido"
	#define STR0015 "Ultimos Pedidos"
	#define STR0016 "Items"
	#define STR0017 "Copiar Ped."
	#define STR0018 "Estatus"
	#define STR0019 "Ocurrencia"
	#define STR0020 "Ocurrencia N� "
	#define STR0021 "Grabar"
	#define STR0022 "Contactos"
	#define STR0023 "Detalle"
	#define STR0024 "Cod. "
	#define STR0025 "Contacto "
	#define STR0026 "Cargo "
	#define STR0027 "Inventario"
	#define STR0028 "Producto:"
	#define STR0029 "Cant.: "
	#define STR0030 "Producto"
	#define STR0031 "Ctd."
	#define STR0032 "Consumo"
	#define STR0033 "Mes/Ano Pasado"
	#define STR0034 "Mes Pasado"
	#define STR0035 "Mes Actual"
#else
	#ifdef ENGLISH
		#define STR0001 "No Customer/Itinerary selected"
		#define STR0002 "New customer already transmitted, unable to insert orders for it."
		#define STR0003 "Warning"
		#define STR0004 "Servicing"
		#define STR0005 "Back"
		#define STR0006 "Order"
		#define STR0007 "Insert "
		#define STR0008 "Edit   "
		#define STR0009 "Delete "
		#define STR0010 "Print"
		#define STR0011 "Order No."
		#define STR0012 "Issue"
		#define STR0013 "Paym Terms"
		#define STR0014 "Last Order"
		#define STR0015 "Last Orders"
		#define STR0016 "Items"
		#define STR0017 "Copy Order"
		#define STR0018 "Status"
		#define STR0019 "Occurrence"
		#define STR0020 "Occurrence No. "
		#define STR0021 "Save"
		#define STR0022 "Contacts"
		#define STR0023 "Detail"
		#define STR0024 "Code "
		#define STR0025 "Contact "
		#define STR0026 "Position "
		#define STR0027 "Inventory"
		#define STR0028 "Product:"
		#define STR0029 "Qtty.: "
		#define STR0030 "Product"
		#define STR0031 "Qtty"
		#define STR0032 "Indem."
		#define STR0033 "Last Month/Year"
		#define STR0034 "Last Month"
		#define STR0035 "Current Month"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Nenhum cliente/roteiro seleccionado", "Nenhum Cliente/Roteiro selecionado" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Cliente novo j� transmitido, n�o � poss�vel incluir pedidos para ele.", "Cliente novo j� transmitido, n�o � poss�vel incluir pedidos a ele." )
		#define STR0003 "Aviso"
		#define STR0004 "Atendimento"
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Recuperar", "Retornar" )
		#define STR0006 "Pedido"
		#define STR0007 "Incluir"
		#define STR0008 "Alterar"
		#define STR0009 "Excluir"
		#define STR0010 "Imprimir"
		#define STR0011 "Pedido N�"
		#define STR0012 "Emiss�o"
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Cond.pagto.", "Cond.Pagto." )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "�lt.pedido", "Ult.Pedido" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "�ltimos Pedidos", "�ltimos Pedidos" )
		#define STR0016 "Itens"
		#define STR0017 "Copiar Ped."
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Estado", "Status" )
		#define STR0019 "Ocorr�ncia"
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Ocorr�ncia n� ", "Ocorr�ncia N� " )
		#define STR0021 "Gravar"
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "Contactos", "Contatos" )
		#define STR0023 "Detalhe"
		#define STR0024 "C�d. "
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "Contacto ", "Contato " )
		#define STR0026 "Cargo "
		#define STR0027 "Invent�rio"
		#define STR0028 "Produto:"
		#define STR0029 "Quant.: "
		#define STR0030 "Produto"
		#define STR0031 "Qtd"
		#define STR0032 "Consumo"
		#define STR0033 If( cPaisLoc $ "ANG|PTG", "M�s/ano Passado", "M�s/Ano Passado" )
		#define STR0034 "M�s Passado"
		#define STR0035 If( cPaisLoc $ "ANG|PTG", "M�s Actual", "M�s Atual" )
	#endif
#endif
