#ifdef SPANISH
	#define STR0001 "El objetivo de este informe es facilitar el retiro de materiales "
	#define STR0002 "después de generar una factura o de la creación de una OP, si consumen"
	#define STR0003 "materiales que utilizan el control de ubicación"
	#define STR0004 "A rayas"
	#define STR0005 "Administración"
	#define STR0006 "Pick-List Ubicación"
	#define STR0007 "PRODUCTO                                     DESCRIPCIÓN                                UM LOTE       SUBLOTE UBICACIÓN     NÚMERO DE SERIE      CANTIDAD       FC VALIDEZ    POTENCIA"
	#define STR0008 " (Factura de venta)    "
	#define STR0009 " (Orden de producción)"
	#define STR0010 "Seleccionando registros ..."
	#define STR0011 "ANULADO POR EL OPERADOR"
	#define STR0012 "VALOR DE LA FACTURA:  "
	#define STR0013 "OBSERVACIÓN: "
	#define STR0014 "CLIENT/PROV.: "
	#define STR0015 "MUNICIPIO....: "
	#define STR0016 "FACTURA......: "
	#define STR0017 "PEDIDO.......: "
	#define STR0018 "TRANSPORTE...: "
	#define STR0019 "VOLUMEN......: "
	#define STR0020 "CLASE......: "
	#define STR0021 "PESO NETO....: "
	#define STR0022 "PESO BRUTO.: "
	#define STR0023 "ORDEN DE PRODUCCIÓN: "
	#define STR0024 "PRODUCTO............: "
	#define STR0025 "FECHA PREV. INICIO: "
	#define STR0026 "FECHA PREV.ENTREGA: "
	#define STR0027 "CANTIDAD.........: "
	#define STR0028 "OBSERVACIÓN......: "
	#define STR0029 "REMITO"
	#define STR0030 "GUÍA DE DESPACHO"
	#define STR0031 "REMISIÓN"
	#define STR0032 "CONDUCE"
	#define STR0033 "Encabezados de documentos de salida"
	#define STR0034 "Órdenes de Prod."
	#define STR0035 " Ítems de documentos de salida"
	#define STR0036 "Reservas"
	#define STR0037 "Movim. por ubicación"
#else
	#ifdef ENGLISH
		#define STR0001 "The purpose of this report is to facilitate the materials outflow"
		#define STR0002 "after a invoicing or a Production Order creation, in case of consumption"
		#define STR0003 "of materials that use Addressing control"
		#define STR0004 "Z.Form"
		#define STR0005 "Management"
		#define STR0006 "Pick-List Addressing"
		#define STR0007 "PRODUCT                                      DESCRIPTION                                ONE LOT       SUB-LOT  LOCATION      SERIES NUMBER        QUANTITY       VALIDITY DT   POWER"
		#define STR0008 " (Outflow Invoice)      "
		#define STR0009 " (Production Order)"
		#define STR0010 "Selecting Records..."
		#define STR0011 "CANCELLED BY THE OPERATOR"
		#define STR0012 "INVOICE AMOUNT: "
		#define STR0013 "NOTE: "
		#define STR0014 "CUSTOM/VENDOR: "
		#define STR0015 "CITY.........: "
		#define STR0016 "INVOICE......: "
		#define STR0017 "ORDER........: "
		#define STR0018 "TRANSPORT....: "
		#define STR0019 "VOLUME.......: "
		#define STR0020 "TYPE.........: "
		#define STR0021 "NET WEIGHT...: "
		#define STR0022 "GROSS WEIGHT.: "
		#define STR0023 "PRODUCT. ORDER...: "
		#define STR0024 "PRODUCT..........: "
		#define STR0025 "EXPEC.START DATE.: "
		#define STR0026 "EXPEC.DELIV.DATE.: "
		#define STR0027 "QUANTITY.........: "
		#define STR0028 "NOTE.............: "
		#define STR0029 "REMITTANCE"
		#define STR0030 "DISPATCH FORM"
		#define STR0031 "REMISION"
		#define STR0032 "CONDUCE"
		#define STR0033 "Outflow document header          "
		#define STR0034 "Production orders "
		#define STR0035 " Outbound Document Items"
		#define STR0036 "Allocat."
		#define STR0037 "Movements by address   "
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Este relatório tem o objectivo de facilitar a retirada de materiais", "Este relatório tem o objetivo de facilitar a retirada de materiais" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Após a facturação de uma factura ou a criação de uma op caso consumam", "após o Faturamento de uma NF ou a Criação de uma OP caso consumam" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Materiais Que Utilizem O Controle De Endereçamento", "materiais que utilizam o controle de Endereçamento" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Código de barras", "Zebrado" )
		#define STR0005 "Administração"
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Pick-list Endereçamento", "Pick-List Endereçamento" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "ARTIGO                                      DESCRIÇÃO                                  UM LOTE       SUB-LOTE LOCALIZAÇÃO   NÚMERO DE SÉRIE      QUANTIDADE     DT VALIDADE   POTÊNCIA", "PRODUTO                                      DESCRIÇÃO                                  UM LOTE       SUBLOTE LOCALIZAÇÃO   NÚMERO DE SÉRIE      QUANTIDADE     DT VALIDADE   POTÊNCIA" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", " (factura De Venda)", " (Nota Fiscal de Venda)" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", " (ordem De Produção)", " (Ordem de Produção)" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "A selecionar registos ...", "Selecionando Registros ..." )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Cancelado Pelo Operador", "CANCELADO PELO OPERADOR" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Valor da factura: ", "VALOR DA NOTA FISCAL: " )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Observação: ", "OBSERVAÇÃO: " )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Cliente/forn.: ", "CLIENTE/FORN.: " )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "CONCELHO....: ", "MUNICÍPIO....: " )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Factura..: ", "NOTA FISCAL..: " )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Pedido.......: ", "PEDIDO.......: " )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Transporte...: ", "TRANSPORTE...: " )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Volume.......: ", "VOLUME.......: " )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Espécie....: ", "ESPÉCIE....: " )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Peso líq.....: ", "PESO LÍQ.....: " )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "Peso bruto.: ", "PESO BRUTO.: " )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Ordem de produção: ", "ORDEM DE PRODUÇÃO: " )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "ARTIGO..........: ", "PRODUTO..........: " )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "Data prev. início: ", "DATA PREV. INÍCIO: " )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Data prev. entreg: ", "DATA PREV. ENTREG: " )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Quantidade.......: ", "QUANTIDADE.......: " )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "Observação.......: ", "OBSERVAÇÃO.......: " )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "Guia de remessa", "GUIA DE REMESSA" )
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "Guia De Despacho", "GUIA DE REMESSA" )
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "Remissão", "GUIA DE REMESSA" )
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "Conduce", "GUIA DE REMESSA" )
		#define STR0033 If( cPaisLoc $ "ANG|PTG", "Cabeçalhos de Facturas de saída", "Cabeçalhos de documentos de saída" )
		#define STR0034 If( cPaisLoc $ "ANG|PTG", "Ordens de produção", "Ordens de Produção" )
		#define STR0035 " Itens de documentos de saída"
		#define STR0036 If( cPaisLoc $ "ANG|PTG", "Alocações", "Empenhos" )
		#define STR0037 "Movimentos por Endereço"
	#endif
#endif
