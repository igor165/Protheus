#ifdef SPANISH
	#define STR0001 "Asientos Contab II"
	#define STR0002 "Buscar"
	#define STR0003 "Visualizar"
	#define STR0004 "Incluir"
	#define STR0005 "Modificar"
	#define STR0006 "Excluir"
	#define STR0007 "Leyenda"
	#define STR0008 "Portada de Lote - Asientos Contables"
	#define STR0009 "Documento"
	#define STR0010 "Fecha"
	#define STR0011 "Lote"
	#define STR0012 "Sublote"
	#define STR0013 "Libro Diario"
	#define STR0014 "Nro Diario"
	#define STR0015 "Historial de documento"
	#define STR0016 "Config. Adicionales"
	#define STR0017 "Moneda"
	#define STR0018 "Criterio Conv."
	#define STR0019 "Fch. Tasa Conv."
	#define STR0020 "Tipo de Saldo"
	#define STR0021 "Totales Informados"
	#define STR0022 "Del Documento"
	#define STR0023 "Del Lote"
	#define STR0024 "Movimientos contables"
	#define STR0025 "Totales del lote y documento (otras monedas)"
	#define STR0026 "Totales"
	#define STR0027 "Inconsistencia Anterior"
	#define STR0028 "Anterior"
	#define STR0029 "Proxima Inconsistencia"
	#define STR0030 "Proxima"
	#define STR0031 "Detalles del asiento posicionado"
	#define STR0032 "Detalles"
	#define STR0033 "Replicar el contenido del campo posicionado"
	#define STR0034 "Replicar"
	#define STR0035 "Registros"
	#define STR0036 "Localizar"
	#define STR0037 "Monedas"
	#define STR0038 "Entes"
	#define STR0039 "Actividades Complementarias"
	#define STR0040 "Totales Digitados"
	#define STR0041 "Criterio invalido para la moneda"
	#define STR0042 "ID"
	#define STR0043 "Valor"
	#define STR0044 "Tasa"
	#define STR0045 "Fecha de la tasa"
	#define STR0046 "Crit. Conver."
	#define STR0047 "Ente"
	#define STR0048 "A Debito"
	#define STR0049 "A Credito"
	#define STR0050 "Total"
	#define STR0051 "Campo"
	#define STR0052 "invalido no hay criterio"
	#define STR0053 "por tanto este campo no se debe rellenar."
	#define STR0054 "El criterio de conversion informado no contiene el digito"
	#define STR0055 "Actividades"
	#define STR0056 "Otras Actividades"
	#define STR0057 "Lct.Extemp"
#else
	#ifdef ENGLISH
		#define STR0001 "Accounting Entries II"
		#define STR0002 "Search"
		#define STR0003 "View"
		#define STR0004 "Add"
		#define STR0005 "Edit"
		#define STR0006 "Delete"
		#define STR0007 "Caption"
		#define STR0008 "Lot Cover - Accounting Entries"
		#define STR0009 "Document"
		#define STR0010 "Date"
		#define STR0011 "Lot"
		#define STR0012 "Sub-lot"
		#define STR0013 "Journal"
		#define STR0014 "Journal Number"
		#define STR0015 "History of Document"
		#define STR0016 "Config. Additional"
		#define STR0017 "Currency"
		#define STR0018 "Conversion Criterion"
		#define STR0019 "Dt. Conversion Rate"
		#define STR0020 "Balance Type"
		#define STR0021 "Entered Totals"
		#define STR0022 "Of Document"
		#define STR0023 "Of Lot"
		#define STR0024 "Accounting transactions"
		#define STR0025 "Total of Lot and Document (other currencies)"
		#define STR0026 "Totals"
		#define STR0027 "Previous Inconsistency"
		#define STR0028 "Previous"
		#define STR0029 "Next Inconsistency"
		#define STR0030 "Next"
		#define STR0031 "Details of positioned entry"
		#define STR0032 "Details"
		#define STR0033 "Replicate the content of positioned field"
		#define STR0034 "Replicate"
		#define STR0035 "Records"
		#define STR0036 "Find"
		#define STR0037 "Currencies"
		#define STR0038 "Entities"
		#define STR0039 "Supplementary Activities"
		#define STR0040 "Totals Entered"
		#define STR0041 "Criterion not valid for currency"
		#define STR0042 "ID"
		#define STR0043 "Value"
		#define STR0044 "Rate"
		#define STR0045 "Date of Rate"
		#define STR0046 "Conversion Criterion"
		#define STR0047 "Entity"
		#define STR0048 "To Debit"
		#define STR0049 "To Credit"
		#define STR0050 "Total"
		#define STR0051 "Field"
		#define STR0052 "not valid there is no criterion"
		#define STR0053 "therefore this field must not be completed."
		#define STR0054 "The entered conversion criterion does not have the digit"
		#define STR0055 "Activities"
		#define STR0056 "Other Activities"
		#define STR0057 "Extemporaneous Entry"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Lan�. Contab. II", "Lanctos Contab II" )
		#define STR0002 "Pesquisar"
		#define STR0003 "Visualizar"
		#define STR0004 "Incluir"
		#define STR0005 "Alterar"
		#define STR0006 "Excluir"
		#define STR0007 "Legenda"
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Capa de Lote - Lan�amentos Contabil�sticos", "Capa de Lote - Lancamentos Contabeis" )
		#define STR0009 "Documento"
		#define STR0010 "Data"
		#define STR0011 "Lote"
		#define STR0012 "Sublote"
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Livro Di�rio", "Livro Diario" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "No. Di�rio", "Nro Diario" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Hist�rico do documento", "Historico do documento" )
		#define STR0016 "Config. Adicionais"
		#define STR0017 "Moeda"
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Crit�rio Conv.", "Criterio Conv." )
		#define STR0019 "Dt. Taxa Conv."
		#define STR0020 "Tipo de Saldo"
		#define STR0021 "Totais Informados"
		#define STR0022 "Do Documento"
		#define STR0023 "Do Lote"
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Movimentos contabil�sticos", "Movimentos contabeis" )
		#define STR0025 "Totais do lote e documento (outras moedas)"
		#define STR0026 "Totais"
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Inconsist�ncia anterior", "Inconsistencia Anterior" )
		#define STR0028 "Anterior"
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "Pr�xima inconsist�ncia", "Proxima Inconsistencia" )
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "Pr�xima", "Proxima" )
		#define STR0031 "Detalhes do lan�amento posicionado"
		#define STR0032 "Detalhes"
		#define STR0033 If( cPaisLoc $ "ANG|PTG", "Replicar o conte�do do campo posicionado", "Replicar o conteudo do campo posicionado" )
		#define STR0034 "Replicar"
		#define STR0035 If( cPaisLoc $ "ANG|PTG", "Registos", "Registros" )
		#define STR0036 "Localizar"
		#define STR0037 "Moedas"
		#define STR0038 "Entidades"
		#define STR0039 If( cPaisLoc $ "ANG|PTG", "Actividades complementares", "Atividades Complementares" )
		#define STR0040 If( cPaisLoc $ "ANG|PTG", "Totais digitados", "Totais Digitados" )
		#define STR0041 If( cPaisLoc $ "ANG|PTG", "Crit�rio inv�lido para a moeda", "Criterio inv�lido para a moeda" )
		#define STR0042 "ID"
		#define STR0043 "Valor"
		#define STR0044 "Taxa"
		#define STR0045 "Data da taxa"
		#define STR0046 "Crit. Conver."
		#define STR0047 "Entidade"
		#define STR0048 If( cPaisLoc $ "ANG|PTG", "A D�bito", "A Debito" )
		#define STR0049 If( cPaisLoc $ "ANG|PTG", "A Cr�dito", "A Credito" )
		#define STR0050 "Total"
		#define STR0051 "Campo"
		#define STR0052 If( cPaisLoc $ "ANG|PTG", "inv�lido n�o h� crit�rio", "invalido n�o h� crit�rio" )
		#define STR0053 If( cPaisLoc $ "ANG|PTG", "portanto, este campo n�o deve ser preenchido.", "portanto este campo n�o deve ser preenchido." )
		#define STR0054 If( cPaisLoc $ "ANG|PTG", "O crit�rio de convers�o informado n�o cont�m o d�gito", "O crit�rio de convers�o informado n�o cont�m o digito" )
		#define STR0055 If( cPaisLoc $ "ANG|PTG", "Actividades", "Atividades" )
		#define STR0056 If( cPaisLoc $ "ANG|PTG", "Outras actividades", "Outras Atividades" )
		#define STR0057 "Lct.Extemp"
	#endif
#endif
