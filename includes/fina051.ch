#ifdef SPANISH
	#define STR0001 "Proveedor"
	#define STR0002 "Modalidad de la detraccion"
	#define STR0003 "De Emison "
	#define STR0004 "A Emison "
	#define STR0005 "Numero de la constancia"
	#define STR0006 "Fecha de deposito"
	#define STR0007 "Atencion"
	#define STR0008 "Este asistente le ayudara en el rellenado de datos relativos a la constancia de detraccion."
	#define STR0009 "Constancias de detraccion"
	#define STR0010 "Debe seleccionar el proveedor y un filtro con la fecha de emision de facturas para posteriormente seleccionar para cuales de estas se esta informando la constancia."
	#define STR0011 "Datos para filtro"
	#define STR0012 "En este paso debe informar los datos para filtrar las facturas."
	#define STR0013 "Filtro"
	#define STR0014 "Datos de la constancia"
	#define STR0015 "En este paso debe informar los datos de la constancia de deposito"
	#define STR0016 "constancia"
	#define STR0017 "Seleccione titulos de detraccion de la constancia"
	#define STR0018 "Solamente estan disponibles los titulos de detraccion dados de baja anteriormente a la fecha del deposito y que aun no tuvieron constacia informada."
	#define STR0019 "Finalizado"
	#define STR0020 "Operacion finalizada con exito."
	#define STR0021 "Este asistente le ayuara a limpiar los datos relativos a la constancia de detraccion."
	#define STR0022 "Constancia de detraccion"
	#define STR0023 "Debe seleccionar el proveedor y la fecha de deposito de la detraccion para posteriormente seleccionar la detraccion que debe anularse."
	#define STR0024 "Datos de la constancia"
	#define STR0025 "Seleccione la detraccion"
	#define STR0026 "Seleccione las detracciones que desea anular."
	#define STR0027 "Total seleccionado:"
	#define STR0028 "Emision"
	#define STR0029 "Prefijo"
	#define STR0030 "Numero"
	#define STR0031 "Tipo"
	#define STR0032 "Valor"
	#define STR0033 "Titulos"
	#define STR0034 "Inconsistencia"
	#define STR0035 "La constancia "
	#define STR0036 " no puede anularse, pues la detraccion de la factura "
	#define STR0037 " se emitio con fecha anterior al ultimo cierre fiscal ("
	#define STR0038 "Formato no valido"
	#define STR0039 "Se utilizan 2 d�gitos del 01 al 12 para el mes y el a�o consta de 4 d�gitos ejemplo: '012020' para Enero del 2020."
	#define STR0040 "Mes/A�o presentacion"
	#define STR0041 " e informar Mes y A�o (MMAAAA) en que se presentara la detraccion en el Libro de Compras,"
#else
	#ifdef ENGLISH
		#define STR0001 "Supplier"
		#define STR0002 "Depreciation nature"
		#define STR0003 "Issue from"
		#define STR0004 "Issue to"
		#define STR0005 "Receipt number"
		#define STR0006 "Deposit date"
		#define STR0007 "Attention"
		#define STR0008 "This wizard helps you fill out data concerning detraccion receipt."
		#define STR0009 "Detraccion receipts"
		#define STR0010 "You must choose the supplier and a filter with issue date of invoices, so you can choose invoices to which the informed receipt refers."
		#define STR0011 "Data for filter"
		#define STR0012 "In this step you have to inform data to filter invoices."
		#define STR0013 "Filter"
		#define STR0014 "Receipt data"
		#define STR0015 "In this step you have to inform data of deposit receipt."
		#define STR0016 "receipt"
		#define STR0017 "Select the detraccion bills of the receipt."
		#define STR0018 "Only detraction bills written-off before the deposit date and not yet with an entered receipt are available."
		#define STR0019 "Finished"
		#define STR0020 "Operation finished successfully."
		#define STR0021 "This wizard will help you clear the data regarding the detraccion receipt."
		#define STR0022 "Detraccion receipt"
		#define STR0023 "First, choose the supplier and the detraccion deposit date. Then, select the detraccion you want to cancel."
		#define STR0024 "Receipt data"
		#define STR0025 "Select the detraccion."
		#define STR0026 "Select the detraccion you want to cancel."
		#define STR0027 "Total selected:"
		#define STR0028 "Issue"
		#define STR0029 "Prefix"
		#define STR0030 "Number"
		#define STR0031 "Type"
		#define STR0032 "Value"
		#define STR0033 "Bills"
		#define STR0034 "Inconsistence"
		#define STR0035 "Receipt "
		#define STR0036 " cannot be canceled because the invoice detraccion "
		#define STR0037 " was issued in a date prior to last fiscal closing ("
		#define STR0038 "Format not valid"
		#define STR0039 "Use 2 digits of 01 to 12 for the month and the year must have 4 digits example: '012020' for January 2020."
		#define STR0040 "Presentation Month/Year"
		#define STR0041 "And enter Month and Year (MMAAAA) where the detraction is displayed in the Purchasing Record,"
	#else
		#define STR0001 "Fornecedor"
		#define STR0002 "Natureza da detra��o"
		#define STR0003 "Emiss�o de"
		#define STR0004 "Emiss�o at�"
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "N�mero do comprovante", "Numero do comprovante" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Data do dep�sito", "Data do deposito" )
		#define STR0007 "Aten��o"
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Este assistente o auxiliar� no preenchimento dos dados relativos � comprovante de detracci�n.", "Este assistente o auxiliara no preenchimento dos dados relativos � comprovante de detracci�n." )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Comprovantes de detrac��o", "Comprovantes de detracci�n" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Voc� devera escolher o fornecedor e um filtro com a data de emiss�o das facturas para posteriormente escolher para qual � o comprovante a ser informado.", "Voc� devera escolher o fornecedor e um filtro com a data de emiss�o das notas fiscais para posteriormente escolher para quais delas � o comprovante sendo informado." )
		#define STR0011 "Dados para filtro"
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Neste passo voc� dever� informar os dados para filtrar as facturas.", "Neste passo voce devera informar os dados para filtrar as notas fiscais." )
		#define STR0013 "Filtro"
		#define STR0014 "Dados do comprovante"
		#define STR0015 "Neste passo voc� devera informar os dados do comprovante de dep�sito"
		#define STR0016 "comprovante"
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Seleccione os t�tulos de detracci�n do comprovante", "Selecione t�tulos de detracci�n do comprovante" )
		#define STR0018 "Somente est�o dispon�veis os t�tulos de detracci�n baixados anteriormente � data do dep�sito e que ainda n�o tiveram comprovante informado."
		#define STR0019 "Finalizado"
		#define STR0020 "Opera��o finalizada com sucesso."
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Este assistente o auxiliar� a limpar os dados relativos ao comprovante de detracci�n.", "Este assistente o auxiliara a limpar os dados relativos ao comprovante de detracci�n." )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "Comprovante de detrac��o", "Comprovante de detracci�n" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Voc� dever� escolher o fornecedor e a data de dep�sito da detracci�n para posteriormente escolher qual a detracci�n a ser cancelada.", "Voc� devera escolher o fornecedor e a data de dep�sito da detracci�n para posteriormente escolher qual a detracci�n que deve ser cancelada." )
		#define STR0024 "Dados do comprovante"
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "Seleccione a detracci�n", "Selecione a detracci�n" )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Seleccione as detracciones que deseja cancelar.", "Selecione as detracciones que deseja cancelar." )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Total seleccionado :", "Total selecionado :" )
		#define STR0028 "Emiss�o"
		#define STR0029 "Prefixo"
		#define STR0030 "N�mero"
		#define STR0031 "Tipo"
		#define STR0032 "Valor"
		#define STR0033 "T�tulos"
		#define STR0034 "Inconsist�ncia"
		#define STR0035 "O comprovante "
		#define STR0036 If( cPaisLoc $ "ANG|PTG", " n�o pode ser cancelado, pois a detracci�n da factura ", " nao pode ser cancelado, pois a detracci�n da nota fiscal " )
		#define STR0037 " foi emitida em data anterior ao �ltimo fechamento fiscal ("
		#define STR0038 If( cPaisLoc $ "ANG|PTG", "Formato no valido", "Formato n�o v�lido" )
		#define STR0039 If( cPaisLoc $ "ANG|PTG", "Se utilizan 2 d�gitos del 01 al 12 para el mes y el a�o consta de 4 d�gitos ejemplo: '012020' para Enero del 2020.", "S�o usados 2 d�gitos de 01 at� 12 para o m�s e o ano consta de 4 d�gitos exemplo: '012020' para Janeiro de 2020." )
		#define STR0040 If( cPaisLoc $ "ANG|PTG", "Mes/A�o presentacion", "M�s/Ano apresenta��o" )
		#define STR0041 If( cPaisLoc $ "ANG|PTG", " e informar Mes y A�o (MMAAAA) en que se presentara la detraccion en el Libro de Compras,", "e informar M�s e Ano (MMAAAA) onde ser� apresentada a detra��o no Livro de Compras," )
	#endif
#endif
