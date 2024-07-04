#ifdef SPANISH
	#define STR0001 "Salir"
	#define STR0002 "Confirmar"
	#define STR0003 "bUscar"
	#define STR0004 "Visualizar"
	#define STR0005 "Liberar/Rechazar"
	#define STR0006 "Revertir"
	#define STR0007 "Cant Original        "
	#define STR0008 "Aprobado            "
	#define STR0009 "Rechazado           "
	#define STR0010 "Transferido"
	#define STR0011 "Reversión Transferencia"
	#define STR0012 "Reversión  Liberación"
	#define STR0013 "Reversión  Rechazo   "
	#define STR0014 "[TIPO:"
	#define STR0015 "/SEC:"
	#define STR0016 "Número:"
	#define STR0017 "Almacén"
	#define STR0018 "Cód.Producto:"
	#define STR0019 "Unid.Medida:"
	#define STR0020 "Lote:"
	#define STR0021 "Cant. Original:"
	#define STR0022 "Cant. Liberada:"
	#define STR0023 "Cant. Rechazada:"
	#define STR0024 "Saldo:"
	#define STR0025 "Gastos agregados    "
	#define STR0026 "Reversión gastos    "
	#define STR0027 "Sublote:"
	#define STR0028 "Proveedor:"
	#define STR0029 "Tienda:"
	#define STR0030 "Bajas del C.Calidad"
	#define STR0031 "Potencia"
	#define STR0032 "Modificar potencia de lote"
	#define STR0033 "Leyenda"
	#define STR0034 "Saldo que debe analizarse"
	#define STR0035 "Saldo liberado/rechazado"
	#define STR0036 "Atención"
	#define STR0037 "El Código del servicio está vacío o incorrecto, complete el servicio adecuadamente"
	#define STR0038 "El Código de la estrutura está vacío o incorrecto, complételo adecuadamente"
	#define STR0039 " Almacén: "
	#define STR0040 "Al mover este ítem, se solicitará el producto para una OP finalizada. ¿Confirma movimiento ?"
	#define STR0041 "Sí"
	#define STR0042 "No"
	#define STR0043 "Administración de proyectos - <F10> "
	#define STR0044 "Proyectos"
	#define STR0045 'Solamente pueden utilizarse Servicios de WMS del tipo "Entrada".'
	#define STR0046 "Fecha de validez"
	#define STR0047 "Cant.Transferida:"
	#define STR0048 "Cliente/Prov:"
	#define STR0049 "Cant. Total:"
	#define STR0050 "La modificación de la fecha de validez solo se permite si se utiliza el Tipo de movimiento 5."
#else
	#ifdef ENGLISH
		#define STR0001 "Quit"
		#define STR0002 "Confirm"
		#define STR0003 "Search"
		#define STR0004 "View  "
		#define STR0005 "Release/Reject"
		#define STR0006 "Reverse"
		#define STR0007 "Original Qty        "
		#define STR0008 "Released            "
		#define STR0009 "Rejected            "
		#define STR0010 "Transferred"
		#define STR0011 "Transfer Reversal"
		#define STR0012 "Released Reversal   "
		#define STR0013 "Rejected Reversal   "
		#define STR0014 "[TYPE:"
		#define STR0015 "/SEQ:"
		#define STR0016 "Number:"
		#define STR0017 "Warehouse"
		#define STR0018 "Product Cod."
		#define STR0019 "Unit of Measur.:"
		#define STR0020 "Lot:"
		#define STR0021 "Original Qty.:"
		#define STR0022 "Released Qty.:"
		#define STR0023 "Rejected Qty.:"
		#define STR0024 "Bal.:"
		#define STR0025 "Extra Expenses "
		#define STR0026 "Expenses Reversal   "
		#define STR0027 "Sublot:"
		#define STR0028 "Vendor:"
		#define STR0029 "Unit:"
		#define STR0030 "Q.C. Postings"
		#define STR0031 "Potency"
		#define STR0032 "Edit the Lot Potency"
		#define STR0033 "Caption"
		#define STR0034 "Balance to be Analysed"
		#define STR0035 "Released/Rejected Balance"
		#define STR0036 "Attention"
		#define STR0037 "The Service Code is empty or incorrect, fill in the service correctly"
		#define STR0038 "The Structure Code is empty or incorrect, fill it in correctly"
		#define STR0039 "Warehouse: "
		#define STR0040 "When moving this item, the product will be requested for a finished OP. Confirm moving."
		#define STR0041 "Yes"
		#define STR0042 "No"
		#define STR0043 "Projects Management - <F10> "
		#define STR0044 "Projects"
		#define STR0045 'Only WMS type "Inflow" services can be used.'
		#define STR0046 "Due Date"
		#define STR0047 "Transfer Qty.:"
		#define STR0048 "Customer/Suppl:"
		#define STR0049 "Total Amt:"
		#define STR0050 "The change of the validity date is only allowed when the Type of Transaction used is 5."
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Abandonar", "Abandona" )
		#define STR0002 "Confirma"
		#define STR0003 "Pesquisar"
		#define STR0004 "Visualizar"
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Liberar/rejeitar", "Liberar/Rejeitar" )
		#define STR0006 "Estornar"
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Qtd. original ", "Qtd Original        " )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Livre", "Liberado            " )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Rejeitado", "Rejeitado           " )
		#define STR0010 "Transferido"
		#define STR0011 "Estorno Transferencia"
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Rectificação liberação ", "Estorno Liberacao   " )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Rectificação rejeição ", "Estorno Rejeicao    " )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "[Tipo:", "[TIPO:" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "/seq:", "/SEQ:" )
		#define STR0016 "Número:"
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Armazém", "Armazem" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Cod.artigo:", "Cod.Produto:" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Unid.medida:", "Unid.Medida:" )
		#define STR0020 "Lote:"
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Qtd. original ", "Qtd.Original:" )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "Qtd. livre", "Qtd.Liberada:" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Qtd. rejeitada ", "Qtd.Rejeitada:" )
		#define STR0024 "Saldo:"
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "Despesas agregadas", "Despesas Agregadas  " )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Estorno despesas", "Estorno Despesas    " )
		#define STR0027 "Sublote:"
		#define STR0028 "Fornecedor:"
		#define STR0029 "Loja:"
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "Liq. do CQ", "Baixas do CQ" )
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "Potência", "Potencia" )
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "Alterar A Potência Do Lote", "Alterar Potencia de Lote" )
		#define STR0033 "Legenda"
		#define STR0034 If( cPaisLoc $ "ANG|PTG", "O Saldo Está A Ser Analisado", "Saldo a ser Analisado" )
		#define STR0035 If( cPaisLoc $ "ANG|PTG", "Saldo Autorizado/rejeitado", "Saldo Liberado/Rejeitado" )
		#define STR0036 If( cPaisLoc $ "ANG|PTG", "Atenção", "Atencao" )
		#define STR0037 If( cPaisLoc $ "ANG|PTG", "O código do serviço está vazio ou incorrecto, preencha o serviço adequadamente", "O Codigo do servico esta vazio ou incorreto, preencha o servico adequadamente" )
		#define STR0038 If( cPaisLoc $ "ANG|PTG", "O código da estrutura está vazio ou incorrecto, preencha-o adequadamente", "O Codigo da Estrutura esta vazio ou incorreto, preencha-o adequadamente" )
		#define STR0039 If( cPaisLoc $ "ANG|PTG", " armazém: ", " Armazem: " )
		#define STR0040 If( cPaisLoc $ "ANG|PTG", "Ao movimentar este elemento, o artigo será requisitado para uma op encerrada. confirma movimento ?", "Ao movimentar este item, o produto sera requisitado para uma OP encerrada. Confirma movimento ?" )
		#define STR0041 "Sim"
		#define STR0042 If( cPaisLoc $ "ANG|PTG", "Não", "Nao" )
		#define STR0043 If( cPaisLoc $ "ANG|PTG", "Gestão de projectos - <f10> ", "Gerenciamento de Projetos - <F10> " )
		#define STR0044 If( cPaisLoc $ "ANG|PTG", "Projectos", "Projetos" )
		#define STR0045 If( cPaisLoc $ "ANG|PTG", 'sOmente serviços de wms do tipo "entrada" podem ser utilizados.', 'Somente Servicos de WMS do tipo "Entrada" podem ser utilizados.' )
		#define STR0046 "Data de Validade"
		#define STR0047 "Qtd.Transferida:"
		#define STR0048 "Cliente / Forn:"
		#define STR0049 "Qdt. Total:"
		#define STR0050 "A alteração da data de validade é permitida apenas quando utilizado Tipo de Movimento 5."
	#endif
#endif
