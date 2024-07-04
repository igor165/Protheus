#ifdef SPANISH
	#define STR0001 "Espere..."
	#define STR0002 "Producto"
	#define STR0003 "Grupo:"
	#define STR0004 "Producto:"
	#define STR0005 "Detalles"
	#define STR0006 "Codigo:"
	#define STR0007 "Precios"
	#define STR0008 "Unidad:"
	#define STR0009 "Ctd.Embal:"
	#define STR0010 "Entrega:"
	#define STR0011 "ICMS:"
	#define STR0012 "IPI:"
	#define STR0013 "Stock:"
	#define STR0014 "Tabla"
	#define STR0015 "Valor"
	#define STR0016 "Precio1: "
	#define STR0017 "Por Codigo"
	#define STR0018 "Por Descripcion"
	#define STR0019 "Buscar"
	#define STR0020 "Volver"
	#define STR0021 "Ok"
	#define STR0022 "Anular"
	#define STR0023 "Buscar"
	#define STR0024 "�Producto no localizado!"
	#define STR0025 "Busca Producto"
#else
	#ifdef ENGLISH
		#define STR0001 "Wait..."
		#define STR0002 "Product"
		#define STR0003 "Group:"
		#define STR0004 "Product:"
		#define STR0005 "Details"
		#define STR0006 "Code:"
		#define STR0007 "Prices"
		#define STR0008 "Unit:"
		#define STR0009 "Pckg.Qty.:"
		#define STR0010 "Delivery:"
		#define STR0011 "ICMS:"
		#define STR0012 "IPI:"
		#define STR0013 "Inventory:"
		#define STR0014 "Table"
		#define STR0015 "Value"
		#define STR0016 "Price 1: "
		#define STR0017 "By Code"
		#define STR0018 "By Description"
		#define STR0019 "Search"
		#define STR0020 "Back"
		#define STR0021 "Ok"
		#define STR0022 "Cancel"
		#define STR0023 "Search"
		#define STR0024 "Product not found!"
		#define STR0025 "Search product  "
	#else
		#define STR0001 "Aguarde..."
		#define STR0002 "Produto"
		#define STR0003 "Grupo:"
		#define STR0004 "Produto:"
		#define STR0005 "Detalhes"
		#define STR0006 "C�digo:"
		#define STR0007 "Pre�os"
		#define STR0008 "Unidade:"
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Qt.embal:", "Qt.Embal:" )
		#define STR0010 "Entrega:"
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Icms:", "ICMS:" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Iva:", "IPI:" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Stock:", "Estoque:" )
		#define STR0014 "Tabela"
		#define STR0015 "Valor"
		#define STR0016 "Pre�o1: "
		#define STR0017 "Por C�digo"
		#define STR0018 "Por Descri��o"
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Procurar", "Buscar" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Recuperar", "Retornar" )
		#define STR0021 "Ok"
		#define STR0022 "Cancelar"
		#define STR0023 "Pesquisar"
		#define STR0024 "Produto n�o localizado!"
		#define STR0025 "Pesquisa Produto"
	#endif
#endif
