#ifdef SPANISH
	#define STR0001 "Imprimiendo"
	#define STR0002 "Codigo del tipo de impresion no valido"
	#define STR0003 "Aviso"
	#define STR0004 "Imprime etiqueta de identificacion del producto"
	#define STR0005 "Si"
	#define STR0006 "No"
	#define STR0007 "Seleccionando pedido..."
	#define STR0008 "Local de impresion no valido"
	#define STR0009 "Confirma la impresion de etiquetas"
	#define STR0010 "Aviso"
	#define STR0011 "Nota: "
	#define STR0012 " Prov.: "
	#define STR0013 "Las etiquetas de la Factura:"
	#define STR0014 " con registro de movimiento interno."
	#define STR0015 "Atencion"
	#define STR0016 "¿Desea imprimirlas nuevamente?"
	#define STR0017 "Producto"
	#define STR0018 "Ctd. del item"
	#define STR0019 "Ctd por embalaje"
	#define STR0020 "Resto"
	#define STR0021 "Ctd. volumenes"
	#define STR0022 "Confirma la salida"
	#define STR0023 "Informe la ctd. por"
	#define STR0024 "Caja del producto:"
	#define STR0025 "Cantidad por caja "
	#define STR0026 "Descripcion: "
	#define STR0027 "Cantidad caja"
#else
	#ifdef ENGLISH
		#define STR0001 "Printing"
		#define STR0002 "Invalid printing type code"
		#define STR0003 "Warning"
		#define STR0004 "Print product identification label"
		#define STR0005 "Yes"
		#define STR0006 "No"
		#define STR0007 "Selecting order..."
		#define STR0008 "Invalid Print Local"
		#define STR0009 "Confirm Labels Printing"
		#define STR0010 "Warning"
		#define STR0011 "Note: "
		#define STR0012 " Supp.: "
		#define STR0013 "The Invoice labels:"
		#define STR0014 " with internal movement record."
		#define STR0015 "Attention"
		#define STR0016 "Reprint them?"
		#define STR0017 "Product"
		#define STR0018 "Item Amount"
		#define STR0019 "Amount per package"
		#define STR0020 "Rest"
		#define STR0021 "Volume Amt."
		#define STR0022 "Confirm exit"
		#define STR0023 "Enter Amount by"
		#define STR0024 "Product box:"
		#define STR0025 "Amount by Box "
		#define STR0026 "Description: "
		#define STR0027 "Amount Box"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "A imprimir", "Imprimindo" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Código do tipo de impressão inválido", "Codigo do tipo de impressao invalido" )
		#define STR0003 "Aviso"
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Imprimir etiqueta de identificação do artigo", "Imprime etiqueta de identificacao do produto" )
		#define STR0005 "Sim"
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "No", "Não" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "A seleccionar pedido...", "Selecionando pedido..." )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Local de impressão inválido", "Local de impressao invalido" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Confirm Labels Printing", "Confirma a Impressão de Etiquetas" )
		#define STR0010 "Aviso"
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Factura: ", "Nota: " )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", " forn: ", " Forn: " )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "The Invoice labels:", "As etiquetas da Nota:" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "with internal movement record.", " com registro de movimento interno." )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Attention", "Atenção" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Print them?", "Deseja reimprimi-las?" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Product", "Produto" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Item Amount", "Qtde do Item" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Amount per package", "Qtde por embalagem" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Rest", "Resto" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Volume Amt.", "Qtde Volumes" )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "Confirm exit", "Confirma a Saida" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Enter Amount by", "Informe a Qtde por" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Product box:", "Caixa do produto:" )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "Amount by Box", "Quantidade Por Caixa " )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Description:", "Descrição: " )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Amount Box", "Quantidade Caixa" )
	#endif
#endif
