#INCLUDE "TMKR046.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMKR046  � Autor � Cleber Martinez       � Data � 24/07/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Posicao Geral da Fila de Telecobranca         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMKR046(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATMK                                                    ���
�������������������������������������������������������������������������Ĵ��
��� ANALISTA     � DATA   � BOPS �MOTIVO DA ALTERACAO                     ���
�������������������������������������������������������������������������Ĵ��
���              �        �      �                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function TMKR046()
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Local wnrel   	:= "TMKR046"  	 	// Nome do Arquivo utilizado no Spool
Local Titulo 	:= STR0001 			//"Posicao Geral da Fila de TeleCobranca"
Local cDesc1 	:= STR0002 			//"Este relat�rio ira exibir de forma sintetica os n�meros atualizados dos t�tulos que est�o em cobranca"
Local cDesc2 	:= ""
Local cDesc3 	:= STR0003 			//"N�o haver� op��o de extrair o relat�rio ref. a datas retroativas"
Local nomeprog	:= "TMKR046.PRW"	 // nome do programa
Local cAlias 	:= "SK1"			 // Alias utilizado na Filtragem
Local lDic    	:= .F. 				 // Habilita/Desabilita Dicionario
Local lComp   	:= .F. 				 // Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro 	:= .F. 				 // Habilita/Desabilita o Filtro
Local dMaiorAtraso 					 // Armazena a data do titulo com maior atraso fora da fila de cobran�a

Private Tamanho := "M" 				 // P/M/G
Private Limite  := 132 				 // 80/132/220
Private aReturn := { STR0004,;		 							//[1] Reservado para Formulario	//"Zebrado"
					 1,;										//[2] Reservado para N� de Vias
					 STR0005,;		 							//[3] Destinatario //"Administra��o"
					 2,;										//[4] Formato => 1-Comprimido 2-Normal	
					 2,;	    								//[5] Midia   => 1-Disco 2-Impressora
					 1,;										//[6] Porta ou Arquivo 1-LPT1... 4-COM1...
					 "",;										//[7] Expressao do Filtro
					 1 } 										//[8] Ordem a ser selecionada
					 											//[9]..[10]..[n] Campos a Processar (se houver)

Private m_pag   := 1  				 // Contador de Paginas
Private nLastKey:= 0  				 // Controla o cancelamento da SetPrint e SetDefault
Private aOrdem  := {}  				 // Ordem do Relatorio

wnrel:=SetPrint(cAlias,wnrel,,@titulo,cDesc1,cDesc2,cDesc3,lDic,aOrdem,lComp,Tamanho,lFiltro)

If (nLastKey == 27)
	DbSelectArea(cAlias)
	DbSetOrder(1)
	DbClearFilter()
	Return
Endif

SetDefault(aReturn,cAlias)

If (nLastKey == 27)
	DbSelectArea(cAlias)
	DbSetOrder(1)
	DbClearFilter()
	Return
Endif

RptStatus({|lEnd| TKR046Imp(@lEnd,wnRel,cAlias,nomeprog,Titulo)},Titulo)

Return(.T.)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TKR045Imp � Autor � Cleber Martinez       � Data � 24/07/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TKR045Imp		                                          ���
�������������������������������������������������������������������������Ĵ��
��� ANALISTA     � DATA   � BOPS �MOTIVO DA ALTERACAO                     ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function TKR046Imp(	lEnd,	wnrel,	cAlias,		nomeprog,;
							Titulo	)

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao Do Cabecalho e Rodape    �
//����������������������������������������������������������������
Local nLi		:= 0			// Linha a ser impressa
Local nMax		:= 58			// Maximo de linhas suportada pelo relatorio
Local cbCont	:= 0			// Numero de Registros Processados
Local cbText	:= SPACE(10)	// Mensagem do Rodape
Local cCabec1	:= "" 			// Label dos itens
Local cCabec2	:= "" 			// Label dos itens
Local nIni		:= 0			// Inicio do periodo de cobranca
Local nFim		:= 0			// Final do periodo de cobranca
Local nX		:= 0			// Usada em lacos For...Next
Local dIni		:= MsDate()		// Data Inicial da Regra de Selecao
Local dFim		:= MsDate()		// Data Final da Regra de Selecao
Local cSK1		:= ""			// Alias da tabela SK1
Local aRegras	:= {}			// Array com as regras de selecao
Local aResult	:= {}			// Array com os resultados obtidos na consulta
Local nTitulos	:= 0			// Total de titulos encontrados
Local nTotCli	:= 0			// Total de clientes a cobrar
Local nTotValor	:= 0			// Valor total dos titulos
Local cTipo		:= UPPER(GetNewPar("MV_TMKCOBR","")) 	// Contem os tipos de titulos que devem ser utilizados para cobranca
Local cSep		:= ""     		// Separador dos tipos de titulo utilizado na select 
Local aTotais	:= {}			// Array com os dados totalizados a partir das queries					
Local aNaoAcionados	:= {}		// Array com os titulos nao acionados por Regra de Selecao
Local cOperadores := ""			// Armazena os operadores que nao devem ser considerados por estarem na mesma faixa de selecao e nao sao receptivo

#IFDEF TOP
	Local cQuery	:= ""		// Query a executar
#ENDIF

DbSelectArea("SK0")
DbSetOrder(2)
DbSeek(xFilial("SK0"))
While !Eof() .AND. xFilial("SK0") == SK0->K0_FILIAL
	nIni := nFim + 1
	If SK0->K0_PRAZO == "999999"		// Trabalha com lista de contato
    	nFim := nFim + 100000
    Else
    	nFim := nFim + Val(SK0->K0_PRAZO)
	EndIf
    
    aAdd(aRegras,{	SK0->K0_DESC,;
    				nIni,;
    				nFim,;
    				SK0->K0_ORDEM})
    
    DbSelectArea("SK0")
    DbSkip()
End

//����������������������������������������������������������������������������������������������������Ŀ
//�Atribui os separadores dos tipos de titulos a serem utilizados e os tipos de  titulos de abatimento �
//������������������������������������������������������������������������������������������������������
If !Empty(cTipo)
	cSep:=	If("/" $ cTipo,"/",",") 
Endif

//������������������������������������Ŀ
//� Posicao atual por regra de selecao �
//��������������������������������������
For nX := 1 To Len(aRegras)

	nTitulos	:= 0
	nTotValor	:= 0
	nTotCli		:= 0

	DbSelectArea(cAlias)
	DbSetOrder(2)	//K1_FILIAL+DTOS(K1_VENCREA)+K1_CLIENTE+K1_LOJA
	#IFDEF TOP
		cSK1 := GetNextAlias()		// Alias temporario do SK1
	
		//�����������������������������������������Ŀ
		//�  -----60---------30--------Hoje----		�
		//�	     dIni       dFim      dDataBase		�
		//�������������������������������������������
		dIni	:= dDataBase - aRegras[nX][3]		
		dFim	:= dDataBase - aRegras[nX][2]		
	
		//����������������������������������Ŀ
		//� Query de totalizacao de clientes �
		//������������������������������������
		cQuery	:=	" SELECT COUNT(*) AS CLIENTES, SUM(TIT) AS TITULOS, SUM(SALDO) AS SALDO FROM (" 
		cQuery	+=  " SELECT SK1.K1_CLIENTE, COUNT(SK1.K1_CLIENTE) AS TIT "
		cQuery	+=  " , SUM(SK1.K1_SALDO) AS SALDO "
		cQuery  +=	" FROM " + RetSqlName("SK1") + " SK1"
		cQuery  +=	" WHERE SK1.K1_FILIAL = '" + xFilial("SK1") + "' AND "
		cQuery	+=  " SK1.K1_OPERAD <> 'XXXXXX' AND"
		cQuery  +=	" SK1.D_E_L_E_T_ = '' "
		cQuery  +=	" GROUP BY SK1.K1_CLIENTE "		
		cQuery  +=	" HAVING MIN(SK1.K1_VENCREA) BETWEEN '" + DtoS(dIni) + "' AND '" + DtoS(dFim) + "' "				
		cQuery  +=	" ) CONTADOR"
		
		cQuery	:= ChangeQuery( cQuery )
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cSK1, .F., .T.)
		nTitulos 	:= (cSK1)->TITULOS
     	nTotCli		:= (cSK1)->CLIENTES
     	nTotValor	:= (cSK1)->SALDO
        (cSK1)->(DbCloseArea())
      
		//���������������������������������������������������������������Ŀ
		//� Adiciona os resultados no array para depois usar na impressao �
		//�����������������������������������������������������������������
     	aAdd(aResult, { aRegras[nX][1]	,;		//Nome da Regra
     					nTitulos		,;		//Total de Titulos
     					nTotCli			,;		//Total de Clientes
				     	nTotValor		} )		//Valor Total
		
		nTitulos	:= 0
		nTotValor	:= 0
		nTotCli		:= 0

		//�����������������������������������������������������������������Ŀ
		//� Seleciona os operadores que trabalham na mesma faixa de selecao |
		//�������������������������������������������������������������������        
		cOperadores := ""
		DbSelectArea("SU7")
		DbSetOrder(1)
		If DbSeek(xFilial("SU7"))
	
			While !Eof() .AND. SU7->U7_FILIAL == xFilial("SU7")
	
				DbSelectArea("SU0")
				DbSetOrder(1)
	
				If DbSeek(xFilial("SU0") + SU7->U7_POSTO)
					DbSelectArea("SK0")
					DbSetOrder(1)
	
					If DbSeek(xFilial("SK0") + SU0->U0_REGSEL) .AND. SU0->U0_BOUND <> '1'
						//��������������������������������������������������Ŀ
						//�Esses operadores estao no grupo do operador atual �
						//����������������������������������������������������
						If SK0->K0_ORDEM == aRegras[nX][4]
							cOperadores+= SU7->U7_COD + ","
						Endif	
					Endif	
	
				Endif
	
				DbSelectArea("SU7")
				DbSkip()
			End	
		Endif
		
		If !Empty(cOperadores)
			cOperadores := Left(cOperadores,Len(cOperadores)-1) //Tira a ultima virgula da string
	    Endif
	
	

		cQuery	:=	" SELECT COUNT(*) AS CLIENTES, SUM(TIT) AS TITULOS, SUM(SALDO) AS SALDO FROM (" 
		cQuery	+=  " SELECT SK1.K1_CLIENTE, COUNT(SK1.K1_CLIENTE) AS TIT "
		cQuery	+=  " , SUM(SK1.K1_SALDO) AS SALDO "	
		cQuery  +=	" FROM " + RetSqlName("SK1") + " SK1"
		cQuery  +=	" WHERE SK1.K1_FILIAL = '" + xFilial("SK1") + "' AND "
		cQuery	+=  " SK1.K1_OPERAD <> 'XXXXXX' AND"
		cQuery  +=	" SK1.D_E_L_E_T_ = '' "
		cQuery  +=	" GROUP BY SK1.K1_CLIENTE "		
		cQuery  +=	" HAVING MIN(SK1.K1_VENCREA) BETWEEN '" + DtoS(dIni) + "' AND '" + DtoS(dFim) + "' AND"				
		cQuery  +=	" MAX(SK1.K1_OPERAD) NOT IN" + FormatIn(cOperadores,",") + ""				
		cQuery  +=	" ) CONTADOR"		
		cQuery	:= ChangeQuery( cQuery )
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cSK1, .F., .T.)

		nTitulos 	:= (cSK1)->TITULOS
     	nTotCli		:= (cSK1)->CLIENTES
     	nTotValor	:= (cSK1)->SALDO
        (cSK1)->(DbCloseArea())		
    
		//���������������������������������������������������������������Ŀ
		//� Adiciona os resultados no array para depois usar na impressao �
		//�����������������������������������������������������������������
     	aAdd(aNaoAcionados, {	aRegras[nX][1]	,;		//Nome da Regra
     							nTitulos		,;		//Total de Titulos
     							nTotCli			,;		//Total de Clientes
				     			nTotValor		} )		//Valor Total
				     	        	
	#ENDIF 
Next nX


#IFDEF TOP

	

	//�����������������������������������������Ŀ
	//� Titulos a receber no TeleCobranca       �
	//� Totaliza os resultados ja obtidos antes �
	//�������������������������������������������
	nTitulos := 0
    nTotCli	 := 0
	nTotValor:= 0 
    For nX := 1 To Len(aResult)
		nTitulos 	+= aResult[nX][2]		//Total de Titulos
     	nTotCli		+= aResult[nX][3]		//Total de Clientes
	    nTotValor 	+= aResult[nX][4]		//Valor Total
	Next nX
	
	//aTotais[2]
	aAdd(aTotais, {	STR0007,;	//"T�tulos a receber no Telecobran�a"
					nTitulos,;
					nTotCli,;
					nTotValor	} )
    
	nTitulos := 0
    nTotCli	 := 0
	nTotValor:= 0 
	
	//�����������������������������������������Ŀ
	//� Titulos nao acionados                   �
	//� Totaliza os resultados ja obtidos 		�
	//�������������������������������������������
    For nX := 1 To Len(aNaoAcionados)
		nTitulos 	+= aNaoAcionados[nX][2]		//Total de Titulos
     	nTotCli		+= aNaoAcionados[nX][3]		//Total de Clientes
	    nTotValor 	+= aNaoAcionados[nX][4]		//Valor Total
	Next nX
	//aTotais[3]
	aAdd(aTotais, {	STR0008,; 	//"T�tulos n�o acionados"
					nTitulos,;
					nTotCli,;
					nTotValor	} )		
	    

#ENDIF	
		
//���������������������������������������Ŀ
//� Impressao dos resultados obtidos	  �
//� Posicao atual por Regra Selecao 	  �
//�����������������������������������������
For nX := 1 To Len(aResult)

	If lEnd
		@Prow()+1,000 PSay STR0010 //"CANCELADO PELO OPERADOR"
		Exit
	Endif
	
	//���������������������������������������������������������Ŀ
	//� Imprime o cabecalho da secao (somente no primeiro item) �
	//�����������������������������������������������������������
	If nX == 1
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)	
		@ nLi,050 PSay STR0011 //"Posi��o atual por Regra de Sele��o"
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)	
		@ nLi,040 PSay STR0012 //"(Informa t�tulos da Telecobran�a n�o pagos, que n�o foram alocados p/ nenhum operador e agrupados por Regra de Sele��o)"
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)	
		@ nLi,000 PSay __PrtFatLine()
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)	
		@ nLi,002 PSay STR0013 //"Nome da Regra"
		@ nLi,060 PSay STR0014 //"Total de T�tulos"
		@ nLi,090 PSay STR0015 //"Total de Clientes"
		@ nLi,120 PSay STR0016 //"Valor (R$)"
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)		
		@ nLi,000 PSay __PrtThinLine()
	EndIf
	
	TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)		
	@ nLi,002 PSay aResult[nX][1] 
	@ nLi,060 PSay PadL(TransForm(aResult[nX][2], '@E 999999999'),16)		// Total de Titulos
	@ nLi,090 PSay PadL(TransForm(aResult[nX][3], '@E 999999999'),17)		// Total de Clientes
	@ nLi,116 PSay PadL(TransForm(aResult[nX][4], '@E 999,999,999.99'),14)	// Valor 
	
Next nX

//���������������������������������������Ŀ
//� Impressao dos resultados obtidos	  �
//� Qtde. de titulos nao acionados  	  �
//�����������������������������������������
For nX := 1 To Len(aNaoAcionados)

	If lEnd
		@Prow()+1,000 PSay STR0010	//"CANCELADO PELO OPERADOR"
		Exit
	Endif
	
	//���������������������������������������������������������Ŀ
	//� Imprime o cabecalho da secao (somente no primeiro item) �
	//�����������������������������������������������������������
	If nX == 1
		TkIncLine(@nLi,3,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)	
		@ nLi,040 PSay STR0017 //"Quantidade de t�tulos n�o acionados por Regra de Sele��o"
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)			
		@ nLi,020 PSay STR0018 //"(T�tulos da Telecobr. n�o pagos, n�o alocados p/ nenhum operador, mas que o cliente possua t�tulos na pend�ncia de um operador)"
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)	
		@ nLi,000 PSay __PrtFatLine()
		
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
		@ nLi,002 PSay STR0013	//"Nome da Regra"
		@ nLi,060 PSay STR0014	//"Total de T�tulos"
		@ nLi,090 PSay STR0015	//"Total de Clientes"
		@ nLi,120 PSay STR0016	//"Valor (R$)"
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)		
		@ nLi,000 PSay __PrtThinLine()
	EndIf
	
	TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)		
	@ nLi,002 PSay aNaoAcionados[nX][1] 
	@ nLi,060 PSay PadL(TransForm(aNaoAcionados[nX][2], '@E 999999999'),16)		// Total de Titulos
	@ nLi,090 PSay PadL(TransForm(aNaoAcionados[nX][3], '@E 999999999'),17)		// Total de Clientes
	@ nLi,116 PSay PadL(TransForm(aNaoAcionados[nX][4], '@E 999,999,999.99'),14)	// Valor 
	
Next nX

//����������������������������������������������������������Ŀ
//� Impressao dos totalizadores de:                          �
//� - Titulos a receber no Protheus (validos p/ Telecobranca)�
//� - Titulos a receber no Telecobranca                      �
//� - Titulos nao acionados                                  �
//� - Qtde. titulos que nao estao na fila de cobranca        �
//������������������������������������������������������������
For nX := 1 To Len(aTotais)

	If lEnd
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)	
		@nLi,000 PSay STR0010	//"CANCELADO PELO OPERADOR"
		Exit
	EndIf

	//���������������������������������������������������������Ŀ
	//� Imprime o cabecalho da secao (somente no primeiro item) �
	//�����������������������������������������������������������
	If nX == 1
		TkIncLine(@nLi,4,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)	
		@ nLi,002 PSay STR0019	//"Indicadores"
		@ nLi,060 PSay STR0014	//"Total de T�tulos"
		@ nLi,090 PSay STR0015	//"Total de Clientes"
		@ nLi,120 PSay STR0016	//"Valor (R$)"
		TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)	
		@ nLi,000 PSay __PrtThinLine()
	EndIf

	TkIncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)	
	@ nLi,002 PSay aTotais[nX][1] 
	@ nLi,060 PSay PadL(TransForm(aTotais[nX][2], '@E 999999999'),16)		// Total de Titulos
	@ nLi,090 PSay PadL(TransForm(aTotais[nX][3], '@E 999999999'),17)		// Total de Clientes
	@ nLi,116 PSay PadL(TransForm(aTotais[nX][4], '@E 999,999,999.99'),14)	// Valor 
	
Next nX
	                                                   

//�����������������������������Ŀ
//�Imprime o rodape do relatorio�
//�������������������������������
Roda(cbCont,cbText,Tamanho)

Set Device To Screen
If ( aReturn[5] = 1 )
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
EndIf
MS_FLUSH()
	    	
Return .T.
