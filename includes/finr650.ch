#ifdef SPANISH
	#define STR0001 "El objetivo de este progr. es imprimir el archivo"
	#define STR0002 "Retorno de la Comunicacion Bancaria, segun layout "
	#define STR0003 "configurado previamente."
	#define STR0004 "Impres. del retorno de la comunic. bancaria"
	#define STR0005 "A Rayas"
	#define STR0006 "Administrac."
	#define STR0007 "Por Numero"
	#define STR0008 "Por Modalid."
	#define STR0009 "Por Vencmnto."
	#define STR0010 "Por Banco"
	#define STR0011 "Proveedor"
	#define STR0012 "Por Emision"
	#define STR0013 "Por Cod Provee."
	#define STR0014 "Nº Titulo           Cli/Pro   Ocurrencia               Fc.Ocur. Val Original  Val Cobrado    Desp. Cobr.  Val Descuento  Val Deducc.    Val Inter.   Val IOF  Otr Cred. Fc.Cred.   Nº Titulo Bco   Consistencia"
	#define STR0015 "OCURRENCIA NO ENVIADA"
	#define STR0016 "OCURRENCIA NO ENCONTRADA"
	#define STR0017 "NUMERO TITULO NO ENVIADO"
	#define STR0018 "TITULO NO ENCONTRADO"
	#define STR0019 "FECHA DE BAJA NO ENVIADA"
	#define STR0020 "ESPECIE NO ENVIADA"
	#define STR0021 "ESPECIE NO ENCONTRADA"
	#define STR0022 "TITULO OK"
	#define STR0023 "TOTALES DEL INFORME"
	#define STR0024 "Nº Titulo           Cli/Pro   Ocurrencia               Fc.Ocur. Val Original      Val Pagado Desp. Cobr.  Val Descuento  Val Deducc.    Val Inter        Nº Titulo Bco       Consistencia"
	#define STR0025 "VALOR RECIBIDO A MAS"
	#define STR0026 "FCH MENOR QUE FCH FINANCIERA"
	#define STR0027 "SUBTOTALES POR OCURRENCIA"
	#define STR0028 "DADO DE BAJA ANTERIO. - TOTAL"
	#define STR0029 "DADO DE BAJA ANTERIOR.- PARCIAL"
	#define STR0030 "TITULO OK"
	#define STR0031 "Nº Titulo"
	#define STR0032 "Cli/Pro"
	#define STR0033 "Ocurrencia"
	#define STR0034 "Fch Ocur"
	#define STR0035 "Vlr Original"
	#define STR0036 "Vlr Cobrado"
	#define STR0037 "Vlr Pago"
	#define STR0038 "Gast. Cobr."
	#define STR0039 "Vlr Descto."
	#define STR0040 "Vlr Descto."
	#define STR0041 "Vlr Inter"
	#define STR0042 "Vlr IOF"
	#define STR0043 "Nº Titulo Bco"
	#define STR0044 "Otr Creditos"
	#define STR0045 "Fch Cred"
	#define STR0046 "Consistencia"
	#define STR0047 "Titulos p. cobrar"
	#define STR0048 "Subtot."
	#define STR0049 "No fue posible copiar el archivo de entrada para el servidor. El archivo se procesará a partir de la máquina local, para un mejor desempeno, copie el archivo directamente en el servidor."
	#define STR0050 "VAL COB SUPERIOR"
	#define STR0051 "VAL COB INFERIOR"
	#define STR0052 "VAL PAGADO SUPERIOR"
	#define STR0053 "VAL PAGADO INFERIOR"
	#define STR0054 "ANULADO POR EL OPERADOR"
	#define STR0055 "TITULO RECHAZADO"
	#define STR0056 "Archivo no se encontró"
	#define STR0057 "El archivo"
	#define STR0058 "Informado en el camino"
	#define STR0059 "no se encontró. Por favor, verifique."
	#define STR0060 "El uso de la pregunta ‘¿Configuración CNAB?' = Modelo PIX solamente se permite para la cartera Cobrar."
	#define STR0061 "Para utilizar la cartera Pagar, utilice la opción Modelo 1 o Modelo 2."
	#define STR0062 "La pregunta ‘¿Configuración CNAB?' fue definida como 'Modelo 1' y el archivo de configuración es 'Modelo 2'."
	#define STR0063 "Para utilizar este layout, ajuste la pregunta ‘¿Configuración CNAB?' a 'Modelo 2'."
	#define STR0064 "La pregunta ‘¿Configuración CNAB?' fue definida como 'Modelo 2' y el archivo de configuración es 'Modelo 1' o 'Modelo PIX'."
	#define STR0065 "Para utilizar este layout, ajuste la pregunta ‘¿Configuración CNAB?' de acuerdo con el tipo de layout 'Modelo 1' o 'Modelo PIX'."
	#define STR0066 "Para generar el informe con layout de cobranza PIX, parametrice la pregunta ‘¿Configuración CNAB?' con el contenido 'Modelo PIX'."
	#define STR0067 "La subcuenta definida en los parámetros tiene el Número de bytes (EE_NRBYTES) diferente de 750."
	#define STR0068 "Para la utilización del informe con layout PIX es necesario configurar en el archivo de Parámetros bancos (FINA130) el campo Número bytes (EE_NRBYTES) = 750"
#else
	#ifdef ENGLISH
		#define STR0001 "This program has the purpose of printing Reply to "
		#define STR0002 "Bank Communication file, according to previously "
		#define STR0003 "setup lay-out.      "
		#define STR0004 "Printing of Reply to Bank Communication file"
		#define STR0005 "Z.Form "
		#define STR0006 "Management   "
		#define STR0007 "By Number"
		#define STR0008 "By Class   "
		#define STR0009 "By Maturity  "
		#define STR0010 "By Bank "
		#define STR0011 "Supplier  "
		#define STR0012 "By Issue  "
		#define STR0013 "By Suppl.Code "
		#define STR0014 "Bill No.           Cust/Sup.  Occurrence                 Occur.Dt. Original Val. Received Val.  Exp. Coll.  Discount Val.   Abatem.Val.     Interest Val.     IOF Val.  Oth.Cred. Cred.Dt.   Bank Bill No.  Consistence"
		#define STR0015 "OCCURRENCE NOT SENT"
		#define STR0016 "OCCURRENCE NOT FOUND"
		#define STR0017 "BILL NUMBER NOT SENT"
		#define STR0018 "BILL NOT FOUND"
		#define STR0019 "POST NOT SENT"
		#define STR0020 "SPECIES NOT SENT"
		#define STR0021 "SPECIES NOT FOUND"
		#define STR0022 "BILL OK"
		#define STR0023 "REPORT TOTALS "
		#define STR0024 "Bill No.           Cust/Sup.  Occurrence                 Occur.Dt. Original Val.   Paid Val.  Exp. Coll.  Discount Val.   Abatem.Val.     Interest Val.    Bank Bill No.      Consistence"
		#define STR0025 "VALUE RECEIVED FOR MORE"
		#define STR0026 "POSTING DATE LOWER THAN FINANCIAL"
		#define STR0027 "SUBTOTAL PER OCCURRENCE  "
		#define STR0028 "PREVIOUSLY POSTED  -  TOTAL  "
		#define STR0029 "PREVIOUSLY POSTED  -  PARTIAL  "
		#define STR0030 "BILL OK  "
		#define STR0031 "Bill nbr."
		#define STR0032 "Cus/Sup"
		#define STR0033 "Occurrence"
		#define STR0034 "Event Dt"
		#define STR0035 "OriginalAmnt"
		#define STR0036 "Amnt.Cllctd."
		#define STR0037 "Amn.Paid"
		#define STR0038 "Exp.Charged"
		#define STR0039 "Disc. amount"
		#define STR0040 "Deduct.Amn."
		#define STR0041 "Inter.Amn"
		#define STR0042 "IOF amn"
		#define STR0043 "Bank bill nbr."
		#define STR0044 "Other Cred. "
		#define STR0045 "Cred.Dt."
		#define STR0046 "Consistence "
		#define STR0047 "Bills receivable "
		#define STR0048 "Sub-totals"
		#define STR0049 "Unable to copy inflow file to server. The file will be processed from the local computer. For better performance, copy the file direct to the server. "
		#define STR0050 "AMT COLL HIGHER"
		#define STR0051 "AMT COLL LOWER"
		#define STR0052 "AMT PAID HIGHER"
		#define STR0053 "AMT PAID LOWER"
		#define STR0054 "CANCELLED BY THE OPERATOR"
		#define STR0055 "BILL REJECTED"
		#define STR0056 "File not found"
		#define STR0057 "File"
		#define STR0058 "Entered in the path"
		#define STR0059 "was not found. Check."
		#define STR0060 "The usage of the question ‘CNAB configuration?’ = PIX Model is only allowed for portfolio Receivable."
		#define STR0061 "To use the portfolio Payable, use Model 1 or Model 2."
		#define STR0062 "The question ‘CNAB Configuration?’ was defined as ‘Model 1’ and the configuration is ‘Model 2’."
		#define STR0063 "To use this layout, adjust the question ‘CNAB Configuration ?’ to ‘Model 2’."
		#define STR0064 "The question ‘CNAB 2 Configuration ?’ was defined as ‘Model 2’ and the configuration file is ‘Model 1’ or ‘PIX Model’."
		#define STR0065 "To use this layout, adjust the question ‘CNAB Configuration ?’ according to the type of layout ‘Model 1’ or ‘PIX Model ‘."
		#define STR0066 " To generate the report with a PIX collection, parameterized the question ‘CNAB Configuration ?’ with the ‘PIX Model’ content."
		#define STR0067 "The sub account defined in the parameters has the Number of Bytes (EE_NRBYTES) different than 750."
		#define STR0068 "To use the report with PIX layout, configure the field Number Bytes (EE_NRBYTES) = 750 in the Parameters Bank registration (FINA130)"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Este programa tem como objectivo imprimir o ficheiro", "Este programa tem como objetivo imprimir o arquivo" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", 'REtorno da Comunicação Bancária, conforme layout,', "Retorno da Comunicaçäo Bancária, conforme layout, " )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Previamente configurado.", "previamente configurado." )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Impressão Do Retorno Da Comunicação Bancária", "Impressao do Retorno da Comunicacao Bancaria" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Código de barras", "Zebrado" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Administração", "Administracao" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Por Número", "Por Numero" )
		#define STR0008 "Por Natureza"
		#define STR0009 "Por Vencimento"
		#define STR0010 "Por Banco"
		#define STR0011 "Fornecedor"
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Por Emissão", "Por Emissao" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Por Cód.fornec.", "Por Cod.Fornec." )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Nr.Título           Cli/For   Ocorrência               Dt.Ocor. Vlr Original  Vlr Recebido   Desp. Cobr.  Vlr Desconto   Vlr Abatim.    Vlr Juros    Vlr IOF  Out Créd. Dt.Créd.   Nr. Título Bco  Consistência", "No.Titulo           Cli/For   Ocorrencia               Dt.Ocor. Vlr Original  Vlr Recebido   Desp. Cobr.  Vlr Desconto   Vlr Abatim.    Vlr Juros    Vlr IOF  Out Cred. Dt.Cred.   Nro Titulo Bco  Consistencia" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Ocorrência Não Enviada", "OCORRENCIA NAO ENVIADA" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Ocorrencia Não Encontrada", "OCORRENCIA NAO ENCONTRADA" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Número Título Não Enviado", "NUMERO TITULO NAO ENVIADO" )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Título Não Encontrado", "TITULO NAO ENCONTRADO" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Data De Liquidação Não Enviada", "DATA DE BAIXA NAO ENVIADA" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Espécie Não Enviada", "ESPECIE NAO ENVIADA" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Espécie Não Encontrada", "ESPECIE NAO ENCONTRADA" )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "Título Ok", "TITULO OK" )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Totais Do Relatório", "TOTAIS DO RELATORIO" )
		#define STR0024 If( cPaisLoc $ "ANG|PTG", "Nr.Título           Cli/For   Ocorrência               Dt.Ocor. Vlr Original      Vlr Pago   Desp. Cobr.  Vlr Desconto   Vlr Abatim.    Vlr Juros        Nr. Título Bco      Consistência", "No.Titulo           Cli/For   Ocorrencia               Dt.Ocor. Vlr Original      Vlr Pago   Desp. Cobr.  Vlr Desconto   Vlr Abatim.    Vlr Juros        Nro Titulo Bco      Consistencia" )
		#define STR0025 If( cPaisLoc $ "ANG|PTG", "Valor Recebido A Maior", "VALOR RECEBIDO A MAIOR" )
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Data Liquidação Inferior à Data Dep. Financeiro", "DATA BAIXA MENOR QUE DATA FINANCEIRO" )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Sub-totais Por Ocorrência", "SUB-TOTAIS POR OCORRENCIA" )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", "Liquidado Anteriormente - Total", "BAIXADO ANTERIORMENTE - TOTAL" )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "Liquidado Anteriormente - Parcial", "BAIXADO ANTERIORMENTE - PARCIAL" )
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "Título Ok", "TITULO OK" )
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "No.título", "No.Titulo" )
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "Cli/for", "Cli/For" )
		#define STR0033 If( cPaisLoc $ "ANG|PTG", "Ocorrência", "Ocorrencia" )
		#define STR0034 If( cPaisLoc $ "ANG|PTG", "Dt.ocor.", "Dt.Ocor." )
		#define STR0035 If( cPaisLoc $ "ANG|PTG", "Valor Original", "Vlr Original" )
		#define STR0036 "Vlr Recebido"
		#define STR0037 If( cPaisLoc $ "ANG|PTG", "Valor Pago", "Vlr Pago" )
		#define STR0038 "Desp. Cobr."
		#define STR0039 If( cPaisLoc $ "ANG|PTG", "Vlr. Desconto", "Vlr Desconto" )
		#define STR0040 "Vlr Abatim."
		#define STR0041 "Vlr Juros"
		#define STR0042 If( cPaisLoc $ "ANG|PTG", "Vlr Iof", "Vlr IOF" )
		#define STR0043 If( cPaisLoc $ "ANG|PTG", "Nr Título Bco", "Nro Titulo Bco" )
		#define STR0044 If( cPaisLoc $ "ANG|PTG", "Out Créditos", "Out Creditos" )
		#define STR0045 If( cPaisLoc $ "ANG|PTG", "Dt.créd.", "Dt.Cred." )
		#define STR0046 If( cPaisLoc $ "ANG|PTG", "Consistência", "Consistencia" )
		#define STR0047 If( cPaisLoc $ "ANG|PTG", "Títulos a receber", "Titulos a receber" )
		#define STR0048 "Subtotais"
		#define STR0049 If( cPaisLoc $ "ANG|PTG", "Não foi possível copiar o ficheiro de entrada para o servidor. o ficheiro será processado a partir do equipamento local, para um melhor desempenho, copie o ficheiro directamente para o servidor.", "Não foi possível copiar o arquivo de entrada para o servidor. O arquivo será processado a partir da máquina local, para um melhor desempenho, copie o arquivo diretamente no servidor." )
		#define STR0050 If( cPaisLoc $ "ANG|PTG", "Vlr Rec Maior", "VLR REC MAIOR" )
		#define STR0051 If( cPaisLoc $ "ANG|PTG", "Vlr Rec Menor", "VLR REC MENOR" )
		#define STR0052 If( cPaisLoc $ "ANG|PTG", "Vlr Pago Maior", "VLR PAGO MAIOR" )
		#define STR0053 If( cPaisLoc $ "ANG|PTG", "Vlr Pago Menor", "VLR PAGO MENOR" )
		#define STR0054 If( cPaisLoc $ "ANG|PTG", "Cancelado Pelo Operador", "CANCELADO PELO OPERADOR" )
		#define STR0055 If( cPaisLoc $ "ANG|PTG", "TÍTULO REJEITADO", "TITULO REJEITADO" )
		#define STR0056 "Arquivo não Encontrado"
		#define STR0057 "O arquivo "
		#define STR0058 "Informado no caminho "
		#define STR0059 "não foi localizado. Favor verificar."
		#define STR0060 "O uso da pergunta 'Configuração CNAB ?' = Modelo PIX é permitida apenas para a carteira Receber."
		#define STR0061 "Para o uso da carteira Pagar, utilize a opçao Modelo 1 ou Modelo 2."
		#define STR0062 "A pergunta 'Configuração CNAB ?' foi definida como 'Modelo 1' e o arquivo de configuração é 'Modelo 2'."
		#define STR0063 "Para o uso deste layout, ajuste a pergunta 'Configuração CNAB ?' para 'Modelo 2'."
		#define STR0064 "A pergunta 'Configuração CNAB ?' foi definida como 'Modelo 2' e o arquivo de configuração é 'Modelo 1' ou 'Modelo PIX'."
		#define STR0065 "Para o uso deste layout, ajuste a pergunta 'Configuração CNAB ?' de acordo com o tipo de layout 'Modelo 1' ou 'Modelo PIX'."
		#define STR0066 "Para gerar o relatório com layout de cobrança PIX, parametrize a pergunta 'Configuração CNAB ?' com o conteúdo 'Modelo PIX'."
		#define STR0067 "A sub-conta definida nos parâmetros possui o Número de Bytes (EE_NRBYTES) diferente de 750."
		#define STR0068 "Para a utilização do relatório com layout PIX é necessario configurar no cadastro de Parâmetros Bancos (FINA130) o campo Número Bytes (EE_NRBYTES) = 750"
	#endif
#endif
