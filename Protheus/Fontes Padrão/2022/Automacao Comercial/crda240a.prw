#INCLUDE "TCBROWSE.CH"
#INCLUDE "PROTHEUS.CH"   
#INCLUDE "CRDA240a.CH"  

#DEFINE PONTOS		1					// Numero de pontos do criterio
#DEFINE VALOR		2					// Valor do vale compras
#DEFINE CODPROD		3					// Codigo do produto
#DEFINE PERDES		4					// Percentual de Desconto - Self Liquidate
#DEFINE TIPO		5					// Tipo (1-Vale compras; 2-Brinde; 3-Self Liquidate)
#DEFINE SEQUEN		6					// Sequencia - Self Liquidate
#DEFINE PRECO		7					// Preco de tabela
#DEFINE CAMPANHA	8					// Campanha
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)

Static aRet	:= {}		// Retorna os vales que serao resgatados
Static oDlg				// Tela de Resgate 
Static oLbx		   		// Objeto ListBox
Static oPontos			// Objeto da pontuacao

                         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CRDA240A  �Autor  � Vendas Clientes    � Data �  04/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Carrega tela com o resgate dos pontos                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CRDA240                                                    ���
�������������������������������������������������������������������������͹��
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function Crda240A(	nPontos,	cCliente, 	cLoja, 		cNomeCli,;
					cDtIniCam,	cDtFinCam,	aCriterio,	cCodCam,;
					nTotVen, oWs )

Local cBitmap 	:= "PROJETOAP"								// Imagem utilizada na caixa de dialogo
Local cTipo		:= ""										// Tipo da retirada (Vale compras, Brinde e Self Liquidate)
Local cTipoN	:= ""										// Tipo da retirada (Vale compras, Brinde e Self Liquidate)
Local cPai		:= ""										// Identifica quem eh pai no self liquidate
Local aColsTRB	:= {}    
Local lMark		:= .F.										// Marca de selacao da listbox
Local nPontosAux:= 0										// Quantidade de pontos Auxiliar
Local nAuxFor	:= 0										// Variavel auxiliar do For Next
Local nPrecoAtu	:= 0										// Preco com desconto do self liquidate

//����������������������������������������������������������������������������������������
//�Posicao do aVetor																	 �
//�[1] - .T. Quando selecionado                                                          �
//�      .F. N�o selecionado                                                             �
//�[2] - Quantidade de pontos, referente ao pr�mio;                                      �
//�[3] - Descri��o do tipo de pr�mio;                                                    �
//�[4] - Valor do vale compras;                                                          �
//�[5] - C�digo do produto;                                                              �
//�[6] - Percentual de desconto do produto;                                              �
//�[7] - C�digo do Vale Compras;                                                         �
//�[8] - Valida a sequencia (no caso de self liquidate);                                 �
//�[9] - C�digo da sequ�ncia do self liquidate (no caso de haver mais que um selecionado;�
//�[10] - Valor do produto pela tabela de pre�o;                                         �
//�[11] - Valor do produto com o desconto debitado;                                      �
//�[12] - C�digo da campanha que est� sendo utilizada;                                   �
//�[13] - Quantidade de vale compras que estao sendo resgatados                          �
//����������������������������������������������������������������������������������������
Local aVetor	:= {}										// Array com os dados dos produtos retirados
Local aDados	:= {}										// Array com os dados que serao retornados

Local oBold													// Objeto para deixar a fonte em negrito
Local oBold1												// Objeto para deixar a fonte em negrito
Local oOk		:= LoadBitmap( GetResources(), "LBOK" )		// Imagem do check box clicado
Local oNo		:= LoadBitmap( GetResources(), "LBNO" )		// Imagem do check box sem estar selecionado
Local aHeaderTRB		:= {}
Local aTamMAU_PONTOS	:= TamSx3("MAU_PONTOS") 	
Local aTamMAU_TIPO		:= TamSx3("MAU_TIPO")   
Local aTamMAU_VALOR		:= TamSx3("MAU_VALOR")  
Local aTamMAU_PROD		:= TamSx3("MAU_PROD")     
Local aTamMAU_PERDES	:= TamSx3("MAU_PERDES")  
Local nX				:= 0 
Local aCampos	:= { "TRB_QTD" }	 
Local lNew		:= AliasIndic( "MB1" )				

Private nPontosAtu		// Quantidade de pontos - sendo atualizada de acordo com a listbox
Private oVlComp
Private nPtsOri

Default nPontos		:= 0									// Pontos acumulados pelo cliente
Default cCliente	:= ""									// Codigo do Cliente que tem direito ao resgate
Default cLoja		:= ""									// Loja do Cliente que tem direito ao resgate
Default cNomeCli	:= ""									// Nome do cliente que tem direito ao resgate
Default cDtIniCam	:= ""									// Data Inicial da campanha
Default cDtFinCam	:= ""									// Data Final da campanha
Default cCodCam		:= ""									// Codigo da campanha
Default aCriterio	:= {}									// Array com os criterios de resgate
DEFAULT oWs         := Nil 						            // Web Service utilizado no FrontLoja

nPontosAtu := nPontos
nPontosAux := nPontos
nPtsOri	   := nPontos

//�����������������������������������������������������������������������������������������Ŀ
//�Ponto de Entrada para regra de Descontos, caso nao retorne nenhum premio para retirada   �
//�������������������������������������������������������������������������������������������
If ExistBlock("CRD2401")
	aDados	:=	ExecBlock( "CRD2401", .F., .F., { nTotVen } )
	For nAuxFor := 1 to Len( aDados )
		If ValType( aDados[nAuxFor][1] ) <> "N"
			aDados[nAuxFor][1] := 0
		ElseIf ValType( aDados[nAuxFor][2] ) <> "C"
			aDados[nAuxFor][2] := ""
		ElseIf ValType( aDados[nAuxFor][3] ) <> "C"
			aDados[nAuxFor][3] := ""
		ElseIf ValType( aDados[nAuxFor][4] ) <> "C"
			aDados[nAuxFor][4] := ""
		ElseIf ValType( aDados[nAuxFor][5] ) <> "N"
			aDados[nAuxFor][5] := 0
		ElseIf ValType( aDados[nAuxFor][6] ) <> "N"
			aDados[nAuxFor][6] := 0
		ElseIf ValType( aDados[nAuxFor][7] ) <> "N"
			aDados[nAuxFor][7] := 0
		Endif
	Next nAuxFor
Endif

//���������������������������������������������������Ŀ
//�Chama funcao de criterio de resgate - MAU - CRDA240�
//�����������������������������������������������������
For nAuxFor	:= 1 to Len( aCriterio )
	If	  aCriterio[nAuxFor][PONTOS] <= nPontos	 .AND. ( ( aCriterio[nAuxFor][TIPO] == "2" ) .OR.;
		( aCriterio[nAuxFor][TIPO] == "3"		 .AND. aCriterio[nAuxFor][SEQUEN] == "1" ) )
	
		If aCriterio[nAuxFor][TIPO] == "2"
			cTipo	:= "Brinde"
		ElseIf aCriterio[nAuxFor][TIPO] == "3"
			cTipo		:= "Self Liquidate"
			cPai		:= "1"
			nPrecoAtu	:= Round( Cr240aVal( aCriterio[nAuxFor][PRECO] ) - ( ( Cr240aVal( aCriterio[nAuxFor][PRECO] ) * Cr240aVal( aCriterio[nAuxFor][PERDES] ) ) / 100 ) ,2)
		Endif

		If nPrecoAtu < 0.01 .AND. Cr240aVal( aCriterio[nAuxFor][PRECO] ) > 0 
			nPrecoAtu := 0.01
			aCriterio[nAuxFor][PERDES] := Round( 100 - ( 1 / Cr240aVal( aCriterio[nAuxFor][PRECO] ) ) ,2 )
			aCriterio[nAuxFor][PERDES] := Transform( aCriterio[nAuxFor][PERDES], "@E 999.99" )
		Endif
		
		aAdd( aVetor, { lMark, 											aCriterio[nAuxFor][PONTOS],;
						cTipo, 											aCriterio[nAuxFor][VALOR],;
						aCriterio[nAuxFor][CODPROD],					aCriterio[nAuxFor][PERDES],;
						"", 											"",;
						cPai,											aCriterio[nAuxFor][PRECO],;
						Transform( nPrecoAtu,"@E 999,999,999.99" ),		aCriterio[nAuxFor][CAMPANHA] })

		nPrecoAtu	:= 0
	Endif
Next nAuxFor

nPrecoAtu	:= 0
//�����������������������������������������������������������Ŀ
//�Mostra na tela os vales compras que o cliente pode resgatar�
//�������������������������������������������������������������
For nAuxFor :=1 To Len( aCriterio )
	//���������������������������������������������������������������������������Ŀ
	//�O criterio adotado sera sempre se os pontos for acima da faixa (MAU_PONTOS)�
	//�����������������������������������������������������������������������������
	If nPontosAux >= aCriterio[nAuxFor][PONTOS] .AND. aCriterio[nAuxFor][TIPO] == "1"
		cTipo	:= "Vale Compras"
		aAdd( aVetor, {	lMark,											aCriterio[nAuxFor][PONTOS],;
						cTipo, 											aCriterio[nAuxFor][VALOR],;
						aCriterio[nAuxFor][CODPROD],					aCriterio[nAuxFor][PERDES],;
						"", 											"",;
						"",												aCriterio[nAuxFor][PRECO],;
						Transform( nPrecoAtu, "@E 999,999,999.99" ),	aCriterio[nAuxFor][CAMPANHA] })

		If !lNew
			nPontosAux	:= nPontosAux - aCriterio[nAuxFor][PONTOS]
		EndIf	
	EndIf
Next nAuxFor

//�����������������������������������������������������������Ŀ
//�Se nao houver criterio para a pontuacao, nao apresenta tela�
//�������������������������������������������������������������
If Len( aVetor ) == 0
	Return( aDados )
Endif      

//�������������������������������������������������������Ŀ
//�Se houver as melhorias no vale compra faz escolhendo a �
//�quantidade que pode ser resgatada.                     �
//���������������������������������������������������������

If lNew
	aAdd(aHeaderTRB,{STR0020 	,"TRB_QTD"		,"99" ,3					,0 					,"Cr240LinOk(@nPontosAtu, @oVlComp, @nPtsOri )",USADO, "N", Nil, " ", Nil, "0", ".T."} ) // "QUANTIDADE"
	aAdd(aHeaderTRB,{STR0021   	,"TRB_PONTOS"	,"@!" ,aTamMAU_PONTOS[1]	,aTamMAU_PONTOS[2]	,"NaoVazio()"	,USADO, "C", Nil, " ", Nil, Nil, ".T."} ) // "PONTOS"
	aAdd(aHeaderTRB,{STR0022 	,"TRB_TIPO" 	,"@!" ,aTamMAU_TIPO[1]		,aTamMAU_TIPO[2]	,"NaoVazio()"	,USADO, "C", Nil, " ", Nil, Nil, ".T."} ) // "TIPO"
	aAdd(aHeaderTRB,{STR0006	,"TRB_VALOR" 	,"@!" ,aTamMAU_VALOR[1]		,aTamMAU_VALOR[2]	,"NaoVazio()"	,USADO, "N", Nil, " ", Nil, "0", ".T."} ) // "VALOR"
	aAdd(aHeaderTRB,{STR0023   	,"TRB_PROD"		,"@!" ,aTamMAU_PROD[1]		,aTamMAU_PROD[2] 	,"NaoVazio()"	,USADO, "C", Nil, " ", Nil, Nil, ".T."} ) // "PRODUTO"
	aAdd(aHeaderTRB,{STR0024	,"TRB_PERDES"	,"@!" ,aTamMAU_PERDES[1]	,aTamMAU_PERDES[2]	,"NaoVazio()"	,USADO, "C", Nil, " ", Nil, Nil, ".T."} ) // "PERCENTUAL DE DESCONTO"
	aAdd(aHeaderTRB,{STR0025   	,"TRB_VLRTAB"	,"@!" ,aTamMAU_VALOR[1]		,aTamMAU_VALOR[2] 	," "			,USADO, "N", Nil, " ", Nil, Nil, ".T."} ) // "VALOR DE TABELA"
	aAdd(aHeaderTRB,{STR0026   	,"TRB_VLRDESC" 	,"@!" ,aTamMAU_VALOR[1]		,aTamMAU_VALOR[1]	," " 			,USADO, "N", Nil, " ", Nil, Nil, ".T."} ) // "VALOR COM DESCONTO"
	

	For nX := 1 To Len( aVetor )
		aAdd( aColsTRB, { 00			, aVetor[nX,2]	, aVetor[nX,3]	, aVetor[nX,4]	, aVetor[nX,5]	, aVetor[nX,6]	, aVetor[nX,7], aVetor[nX,8], ;
			 			  aVetor[nX,9]	, aVetor[nX,10]	, aVetor[nX,11]	, aVetor[nX,12]	, 00				,.F. } )    
	Next nX	
	
EndIf

//���������������������������������������������������������������Ŀ
//�Cria listbox, para escolha dos produtos que podem ser retirados�
//�����������������������������������������������������������������
DEFINE FONT oBold    NAME "Arial" SIZE 0, -12 BOLD
DEFINE FONT oBold1   NAME "Arial" SIZE 0, -14 BOLD
DEFINE MSDIALOG oDlg FROM  C(0),C(0) TO C(250),C(680) TITLE STR0001 PIXEL STYLE DS_MODALFRAME 				// Resgate de Pontos

	@ C(0), C(0) BITMAP oBmp RESNAME cBitMap oF oDlg SIZE C(38),C(382) NOBORDER WHEN .F. PIXEL


	@ C(005), C(05) SAY STR0015		OF oDlg PIXEL FONT oBold1							// "Escolha abaixo os produtos que o cliente tem direito de retirar"
	
	@ C(015), C(05) SAY STR0003		OF oDlg PIXEL										// "Codigo : "
	@ C(015), C(025) SAY cCliente	OF oDlg PIXEL
		                                                                                        
	@ C(015), C(050) SAY STR0004	OF oDlg PIXEL									// "Loja : "
	@ C(015), C(065) SAY cLoja		OF oDlg PIXEL

	@ C(015), C(85) SAY " - "		OF oDlg PIXEL
	@ C(015), C(90) SAY cNomeCli	OF oDlg PIXEL

	If lNew
	   	oVlComp := MsNewGetDados():New(	C(030)		, C(008), C(100)	, C(300)	,;
	  									GD_UPDATE	, Nil,;
	  									Nil		, Nil		, aCampos	, Nil		,;
	  									999	   	, Nil		, Nil		, Nil		,;
	  									oDlg  	, aHeaderTRB, aColsTRB )                             	
	Else	
 		@ C(030), C(008) LISTBOX oLbx VAR cVar FIELDS HEADER ;
   				" ", STR0021, STR0022, STR0006, STR0023, STR0024, STR0025, STR0026 ;
   				SIZE C(330),C(075) OF oDlg PIXEL ON dblClick(aVetor[oLbx:nAt,1] := !aVetor[oLbx:nAt,1], nPontosAtu := CRD240aPon( nPontos, aVetor, oLbx, aCriterio, oLbx:nAt, aVetor[oLbx:nAt,12] ), oLbx:Refresh(), oDlg:Refresh(), oPontos:Refresh() )
			oLbx:SetArray( aVetor )

			//��������������������������������������������������������������������Ŀ
			//�Define os campos que irao aparecer na listbox, de acordo com o vetor�
			//����������������������������������������������������������������������
			oLbx:bLine := {|| {Iif(aVetor[oLbx:nAt,1],oOk,oNo),;
   									aVetor[oLbx:nAt,2],;
									aVetor[oLbx:nAt,3],;
									aVetor[oLbx:nAt,4],;
									aVetor[oLbx:nAt,5],;
									aVetor[oLbx:nAt,6],;
									aVetor[oLbx:nAt,10],;
									aVetor[oLbx:nAt,11]}}   
	EndIf								

	@ C(110), C(005) SAY STR0005 OF oDlg PIXEL										// "Pontos : "

	@ C(110), C(030) MSGET oPontos VAR Alltrim(STR( nPontosAtu ) ) OF oDlg PIXEL FONT oBold WHEN .F.
    
	DEFINE SBUTTON FROM C(108),C(300) TYPE 1 ACTION (  If( lNew,(If ( Crd240Pont( nPtsOri, oVlComp:aCols ), oDlg:End(), Nil) ), oDlg:End() ) ) ENABLE OF oDlg
	oDlg:LESCCLOSE := .F.
	ACTIVATE MSDIALOG oDlg CENTERED     
	

	If lNew     
		aVetor := aClone( aRet )   
	EndIf		

	For nAuxFor := 1 to Len( aVetor )
		If aVetor[nAuxFor][1]
	        If aVetor[nAuxFor][3] == "Vale Compras"
				cTipoN	:= "1"
			ElseIf aVetor[nAuxFor][3] == "Brinde"
				cTipoN	:= "2"
			ElseIf aVetor[nAuxFor][3] == "Self Liquidate"
				cTipoN	:= "3"
			Endif

			//���������������������������������������������������Ŀ
			//�Posicao do aDados                                  �
			//�1- Numero de pontos de cada um dos itens (numerico)�
			//�2- Tipo 	1 - Vale compras                          �
			//�			2 - Brinde                                �
			//�			3 - SL                                    �
			//�3- Produto                                         �
			//�4- Numero do vale compras                          �
			//�5- Valor do produto com desconto do self liquidate �
			//�6- % Desconto (numerico)                           �
			//�7- Valor do vale compras (numerico)                �
			//�����������������������������������������������������
			Aadd( aDados,{	aVetor[nAuxFor][2],					cTipoN,;
							aVetor[nAuxFor][5],					aVetor[nAuxFor][7],;
							Cr240aVal( aVetor[nAuxFor][11]),	Cr240aVal( aVetor[nAuxFor][6] ),;
							Cr240aVal( aVetor[nAuxFor][4] ) })
	EndIf						
Next nAuxFor
	
Return( aDados )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CRD240aPon�Autor  � Vendas Clientes    � Data �  07/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao de atualizacao dos pontos, de acordo com a listbox   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CRDA240A                                                   ���
�������������������������������������������������������������������������͹��
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CRD240aPon( 	nPontos,	aVetor, oLbx, aCriterio,;
						nLinha,		cCodCam )
Local nAuxFor	:= 0										// Variavel auxiliar do For Next
Local nPontosAux:= 0										// Controle de pontos auxiliar
Local nPrecoAtu	:= 0										// Preco atual
Local cPai		:= ""										// Valida se tem pai, no caso de self liquidate
Local aVetorAux	:= {}										// Vetor auxiliar
Local aSelf		:= {}										// Array com os itens do Self Liquidate
Local aAreaMAU	:= MAU->( GetArea() )						// Area do Arquivo de itens de resgate

Local lMark		:= .F.										// Marca de selacao da listbox
Local lValid	:= .F.										// Valida o vale compras
Local lRet		:= .T.										// Retorno do ponto de entrada, se o item pode ou nao ser marcado
Local nCont		:= 2										// Contador

Local oOk		:= LoadBitmap( GetResources(), "LBOK" )		// Objeto oOK para marcar graficamente quando selecionado
Local oNo		:= LoadBitmap( GetResources(), "LBNO" )		// Objeto oNo para marcar graficamente quando nao estiver selecionado
Local cTipo		:= "C"										// Armazena o tipo do campo MAU_PONTOS
Local aArea		:= {}										// Backup da area antes de procurar o type do MAU_PONTOS

aArea := GetArea()
DbSelectArea("Sx3") 
DbSetOrder( 2 )
If DbSeek( "MAU_PONTOS" )
	cTipo := X3_TIPO
EndIf
RestArea( aArea )    


nPontosAtu	:= nPontos

//�����������������������������������������������������������������������Ŀ
//�Ponto de entrada para possiveis validacoes ao MARCAR o item selecionado�
//�������������������������������������������������������������������������
If ExistBlock("CRD2402") .AND. aVetor[nLinha][1]
	lRet	:=	ExecBlock( "CRD2402", .F., .F., { aVetor[nLinha], aVetor }  )
Endif

If !lRet
	//�������������������������������������������������������������������������������������Ŀ
	//�Mantem o item desmarcado caso nao tenha sido validado e retorna sem descontar pontos �
	//���������������������������������������������������������������������������������������
	aVetor[nLinha][1] := .F.
	Return ( nPontosAtu )
Endif
//���������������������������Ŀ
//�Verifica se e Vale Compras �
//�����������������������������
If aVetor[nLinha][3] == "Vale Compras" .AND. aVetor[nLinha][1]
	lValid	:= Cr240aVale( aVetor, nLinha )
	If !lValid
		aVetor[nLinha][1] := .F.
	Endif
Endif

//�����������������������������Ŀ
//�Verifica se eh Self Liquidate�
//�������������������������������
If Cr240aVal( aVetor[nLinha][6] )  > 0 .AND. aVetor[nLinha][1] .AND. "Self"$aVetor[nLinha][3]
	MAU->( DbSetOrder( 2 ) )

	If MAU->( DbSeek( xFilial( "MAU" ) + cCodCam + STR( aVetor[nLinha][2], 5 ) + Alltrim( STR( nCont ) ) ) )
		While	MAU->( !Eof() )	 .AND. MAU->MAU_CODCAM == cCodCam .AND. If( cTipo == "C", MAU->MAU_PONTOS == STR( aVetor[nLinha][2], 5 ), MAU->MAU_PONTOS == aVetor[nLinha][2] )

			If Alltrim( STR( nCont ) ) == MAU->MAU_SEQUEN

				//���������������������������������������������������������������������������������������������Ŀ
				//�Chama a tela para escolher os produtos de self liquidate de acordo com a sequencia existente �
				//�����������������������������������������������������������������������������������������������
				aSelf	:= CRD240aSelf( aVetor[nLinha], nCont, nPontosAtu, cCodCam )
			Endif

			If Len( aSelf ) > 0
				aAdd( aVetorAux, {	.T., 												0,;
									"Self Liquidate", 									Transform( 0, "@E 999,999,999.99" ) ,;
									aSelf[1][5],										aSelf[1][6],;
									"",													Alltrim( STR( nCont ) ),;
									aVetor[nLinha][9],									aSelf[1][10],;
									aSelf[1][11],										aSelf[1][12] })

				nCont	:= nCont + 1
				MAU->( DbSetOrder( 2 ) )
				MAU->( DbSeek( xFilial( "MAU" ) + cCodCam + STR( aVetor[nLinha][2], 5 ) + Alltrim( STR( nCont ) ) ) )

				//�����������������������������������Ŀ
				//�Produtos marcados no self liquidate�
				//�������������������������������������
				aSelf := {}
			Else
				Exit
			Endif
		End
	Endif

//�������������������������������������������Ŀ
//�Se for Self Liquidate mas estiver desmacado�
//���������������������������������������������
ElseIf Cr240aVal( aVetor[nLinha][6] ) > 0 .AND. !aVetor[nLinha][1] .AND. "Self"$aVetor[nLinha][3]

	//���������������������������������������������������������������������������Ŀ
	//�Se este self liquidate for o pai, devera tirar a selecao de todos os filhos�
	//�����������������������������������������������������������������������������
	If aVetor[nLinha][9] == "1" .AND. Empty( aVetor[nLinha][8] )
		For nAuxFor := 1 to Len( aVetor )
			If	Cr240aVal( aVetor[nAuxFor][6] ) > 0 .AND. aVetor[nAuxFor][1] .AND.;
				aVetor[nAuxFor][9] == aVetor[nLinha][9]

				//����������������������Ŀ
				//�Se for filho, desmarca�
				//������������������������
				aVetor[nAuxFor][1] := .F.
			Endif
		Next nAuxFor

	//���������������������������������������������������������������������������Ŀ
	//�Filho for desmarcado, deve desmarcar os proximos da sequencia do mesmo pai �
	//�����������������������������������������������������������������������������
	Else
		nSeq := aVetor[nLinha][8]

		For nAuxFor := 1 to Len( aVetor )
			If	Cr240aVal( aVetor[nAuxFor][6] ) > 0 .AND. aVetor[nAuxFor][1] .AND.;
				aVetor[nAuxFor][9] == aVetor[nLinha][9] .AND. aVetor[nAuxFor][8] > aVetor[nLinha][8]

				//����������������������Ŀ
				//�Se for filho, desmarca�
				//������������������������
				aVetor[nAuxFor][1] := .F.
			Endif
		Next nAuxFor		
	Endif
Endif
//������������Ŀ
//�Volta a area�
//��������������
RestArea( aAreaMAU )

//�������������Ŀ
//�Varre o array�
//���������������
For nAuxFor := 1 to Len( aVetor )
	//����������������������������������������������������������������Ŀ
	//�Se estiver selecionado mantem no vetor e debita dos pontos Atual�
	//������������������������������������������������������������������
	If aVetor[nAuxFor][1]
		nPontosAtu	:= nPontosAtu - aVetor[nAuxFor][2]
		aAdd( aVetorAux, aVetor[nAuxFor] )
		If !Empty( aVetor[nAuxFor][9] )
			If cPai	< aVetor[nAuxFor][9]
				cPai := aVetor[nAuxFor][9]
			Endif
		Endif
	Endif
Next nAuxFor

//�������������������������������������������������������������������������������Ŀ
//�Verifica se deve carregar outros crit�rios de acordo com a pontuacao disponivel�
//���������������������������������������������������������������������������������
For nAuxFor := 1 to Len( aCriterio )
	If aCriterio[nAuxFor][PONTOS] <= nPontosAtu .AND. ( ( aCriterio[nAuxFor][TIPO] == "2" ) .OR.;
		( aCriterio[nAuxFor][TIPO] == "3" .AND. aCriterio[nAuxFor][SEQUEN] == "1" ) )
		
		nPrecoAtu	:= 0  
		If aCriterio[nAuxFor][TIPO] == "2"
			cTipo	:= "Brinde"
			cPai	:= ""
		ElseIf aCriterio[nAuxFor][TIPO] == "3"
			cTipo	:= "Self Liquidate"
			cPai	:= Soma1( cPai )
			nPrecoAtu	:= Round( Cr240aVal( aCriterio[nAuxFor][PRECO] ) - ( Cr240aVal( aCriterio[nAuxFor][PRECO] ) * Cr240aVal( aCriterio[nAuxFor][PERDES] ) ) / 100 ,2)
		Endif

		If nPrecoAtu < 0.01 .AND. Cr240aVal( aCriterio[nAuxFor][PRECO] ) > 0 
			nPrecoAtu := 0.01
			aCriterio[nAuxFor][PERDES] := Round( 100 - ( 1 / Cr240aVal( aCriterio[nAuxFor][PRECO] ) ) ,2 )
			aCriterio[nAuxFor][PERDES] := Transform( aCriterio[nAuxFor][PERDES], "@E 999.99")
		Endif
		
		aAdd(aVetorAux, {	lMark, 											aCriterio[nAuxFor][PONTOS],;
							cTipo, 											aCriterio[nAuxFor][VALOR],;
							aCriterio[nAuxFor][CODPROD],					aCriterio[nAuxFor][PERDES],;
							"", 											"",;
							cPai,											aCriterio[nAuxFor][PRECO],;
							Transform( nPrecoAtu,"@E 999,999,999.99" ),		aCriterio[nAuxFor][CAMPANHA] })

		nPrecoAtu	:= 0
	Endif
Next nAuxFor

nPontosAux	:= nPontosAtu
nPrecoAtu	:= 0
//�����������������������������������������������������������Ŀ
//�Mostra na tela os vales compras que o cliente pode resgatar�
//�������������������������������������������������������������
For nAuxFor :=1 To Len( aCriterio )
	//���������������������������������������������������������������������������Ŀ
	//�O criterio adotado sera sempre se os pontos for acima da faixa (MAU_PONTOS)�
	//�����������������������������������������������������������������������������
	If nPontosAux >= aCriterio[nAuxFor][PONTOS] .AND. aCriterio[nAuxFor][TIPO] == "1"
		cTipo	:= "Vale Compras"

		aAdd( aVetorAux, {	lMark,											aCriterio[nAuxFor][PONTOS],;
							cTipo, 											aCriterio[nAuxFor][VALOR],;
							aCriterio[nAuxFor][CODPROD],					aCriterio[nAuxFor][PERDES],;
							"", 											"",;
							"",												aCriterio[nAuxFor][PRECO],;
							Transform( nPrecoAtu,"@E 999,999,999.99" ),		aCriterio[nAuxFor][CAMPANHA] })

		nPontosAux	:= nPontosAux - aCriterio[nAuxFor][PONTOS]
	EndIf
Next nAuxFor

//�������������������������������������������Ŀ
//�Carrega o vetor auxiliar no vetor principal�
//���������������������������������������������
aVetor	:= aClone( aVetorAux )
oLbx:SetArray( aVetor )
oLbx:bLine := {|| {Iif(	aVetor[oLbx:nAt,1],oOk,oNo),;
						aVetor[oLbx:nAt,2],;
						aVetor[oLbx:nAt,3],;
						aVetor[oLbx:nAt,4],;
						aVetor[oLbx:nAt,5],;
						aVetor[oLbx:nAt,6],;
						aVetor[oLbx:nAt,10],;
						aVetor[oLbx:nAt,11]}}
Return ( nPontosAtu )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CRD240aSel�Autor  � Vendas Clientes    � Data �  05/05/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Carrega tela dos produtos com desconto do self liquidate    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CRDA240a                                                   ���
�������������������������������������������������������������������������͹��
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CRD240aSelf( aVetor, nSeq, nPontosAtu, cCodCam )
Local aCritSelf		:= {}								// Array com os criterios do self liquidate
Local aProdSelf		:= {}								// Array com os produtos do self liquidate
Local cBitmap		:= "PROJETOAP"						// Bitmap carregado na tela
Local lMark			:= .F.								// Valida se o item foi selecionado ou nao
Local nAuxFor		:= 0								// Variavel auxiliar do for... next
Local nPreco		:= 0								// Preco do produto
Local nPrecoAtu		:= 0								// Preco atual do produto
Local nDescProd		:= 0								// Desconto do produto
Local cTabPad	    := AllTrim(SuperGetMv("MV_TABPAD"))	// Tabela de preco padrao
Local cCampo	    := ""								// Campo utilizado na tabela de precos
Local oBold1											// Objeto para alterar as configuracoes da fonte
Local oDlgSelf											// Objeto Dialog dos produtos de self
Local oLbx												// Objeto da list box
Local oOk			:= LoadBitmap( GetResources(), "LBOK" )		// Objeto do bitmap quando selecionado
Local oNo			:= LoadBitmap( GetResources(), "LBNO" )		// Objeto do bitmap quando nao estiver selecionado
Local cTipo			:= "C"										// Armazena o tipo do campo MAU_PONTOS
Local aArea			:= {}										// Backup da area antes de procurar o type do MAU_PONTOS

aArea := GetArea()
DbSelectArea("SX3") 
DbSetOrder( 2 )
If DbSeek( "MAU_PONTOS" )
	cTipo := X3_TIPO
EndIf
RestArea( aArea )

MAU->( DbSetOrder( 1 ) )

//������������������������������
//�Procura os itens da campanha�
//������������������������������
If MAU->( DbSeek( xFilial( "MAU" ) + cCodCam ) )
	//�������������������������������������������������Ŀ
	//�Adiciona no Array, os criterios existentes no MAU�
	//���������������������������������������������������
	While MAU->( !Eof() ) .AND. MAU->MAU_FILIAL	== xFilial( "MAU" )	.AND. MAU->MAU_CODCAM == cCodCam

		If 	MAU->MAU_TIPO	== "3" .AND. MAU->MAU_PERDES > 0 .AND. ; 
			If( cTipo == "C", Val( MAU->MAU_PONTOS ) <= nPontosAtu , MAU->MAU_PONTOS <= nPontosAtu ) .AND.;		
			MAU->MAU_SEQUEN	== Alltrim( STR( nSeq ) )

			nPreco		:= 0
			nPrecoAtu	:= 0 
			
			If !Empty( MAU->MAU_PROD )  
				If SuperGetMv("MV_LJCNVDA",,.F.)
					LjxeValPre (@nPreco, Alltrim( MAU->MAU_PROD ))
			    Else
					SB0->( DbSetOrder( 1 ) )
					If SB0->( DbSeek( xFilial( "SB0" ) +  Alltrim( MAU->MAU_PROD ) ) )
					    cCampo := "B0_PRV"+cTabPad
						nPreco := SB0->(&cCampo)					
					Endif
				EndIf
			Endif

			nPrecoAtu	:= Round( nPreco - ( nPreco * MAU->MAU_PERDES ) / 100 ,2)

			If nPrecoAtu < 0.01 .AND. nPreco > 0
				nPrecoAtu	:= 0.01
				nDescProd	:= Round( 100 - ( 1 / nPreco ) ,2 )
			Else
				
			Endif

			aAdd( aCritSelf, {	lMark, 														MAU->MAU_PROD,;
								Transform( MAU->MAU_PERDES, "@E 999.99" ),					Transform(nPreco, "@E 999,999,999.99" ),;
								Transform( nPrecoAtu, "@E 999,999,999.99" ),				MAU->MAU_CODCAM })
		Endif

		MAU->( dbSkip() )
	End

	//����������������������������������������Ŀ
	//�Ordena somente se existir dados no array�
	//������������������������������������������
	If Len( aCritSelf ) > 0
		aSort( aCritSelf,,, {|a,b| a[1] > b[1] })
	Endif
Else                                          
	Return
EndIf                          

If Len( aCritSelf ) == 0
	Return
Endif

DEFINE FONT oBold1   NAME "Arial" SIZE 0, -12 BOLD
DEFINE MSDIALOG oDlgSelf FROM  C(0),C(0) TO C(240),C(550) TITLE STR0002 PIXEL STYLE DS_MODALFRAME //Produtos com desconto

	@ C(0) , C(0) BITMAP oBmp RESNAME cBitMap oF oDlgSelf SIZE C(38),C(382) NOBORDER WHEN .F. PIXEL

	@ C(004),C(008) SAY STR0016		OF oDlgSelf PIXEL FONT oBold1							// 	"Com a pontuacao alcancada, � poss�vel retirar um dos produtos abaixo."
	@ C(012),C(008) SAY STR0017		OF oDlgSelf PIXEL 										// 	"A condicao de pagamento poder� ser alterada"
	@ C(025),C(008) LISTBOX oLbx VAR cVar FIELDS HEADER ;
   				" ", STR0023, STR0024, STR0025, STR0026 ;
   				SIZE C(265),C(075) OF oDlgSelf PIXEL ON dblClick( aCritSelf[oLbx:nAt,1] := !aCritSelf[oLbx:nAt,1], CRD240aMar( aCritSelf, oLbx,oLbx:nAt ), oLbx:Refresh(), oDlgSelf:Refresh() )

			oLbx:SetArray( aCritSelf )

			//��������������������������������������������������������������������Ŀ
			//�Define os campos que irao aparecer na listbox, de acordo com o vetor�
			//����������������������������������������������������������������������
			oLbx:bLine := {|| {Iif(	aCritSelf[oLbx:nAt,1],oOk,oNo),;
   									aCritSelf[oLbx:nAt,2],;
									aCritSelf[oLbx:nAt,3],;
									aCritSelf[oLbx:nAt,4],;
									aCritSelf[oLbx:nAt,5]}}

	DEFINE SBUTTON FROM C(105),C(235) TYPE 1 ACTION oDlgSelf:End() ENABLE OF oDlgSelf
	oDlgSelf:LESCCLOSE := .F.
	ACTIVATE MSDIALOG oDlgSelf CENTERED

	For nAuxFor	:= 1 to Len( aCritSelf )
		If aCritSelf[nAuxFor][1]

			aAdd( aProdSelf, {	lMark,														0,;
		 						"Self Liquidate", 											Transform( 0, "@E 999,999,999.99" ),;
								aCritSelf[nAuxFor][2],										aCritSelf[nAuxFor][3],;
								"", 														"",;
								"",															aCritSelf[nAuxFor][4],;
								aCritSelf[nAuxFor][5],										aCritSelf[nAuxFor][6] })
		Endif
	Next aCritSelf
Return aProdSelf


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CRD240aMar�Autor  � Vendas Clientes    � Data �  09/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida a marca de somente um item por sequencia no self li- ���
���          �quidate                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � CRDA240a                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CRD240aMar( aCritSelf, oLbx )
Local lRet		:= .F.
Local nAuxFor	:= 0

//�������������Ŀ
//�Varre o array�
//���������������
For nAuxFor := 1 to Len( aCritSelf )
	//����������������������������������������������������������������Ŀ
	//�Se estiver selecionado mantem no vetor e debita dos pontos Atual�
	//������������������������������������������������������������������
	If aCritSelf[nAuxFor][1]
		If !lRet
			lRet	:= .T.
		Else
			Alert(STR0027)
			aCritSelf[nAuxFor][1] := .F.
		Endif
	Endif
Next nAuxFor

Return

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o	 �Crd240Vale    � Autor �� Data �02/12/05   ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Entrega do vale compra ao cliente                            ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Fidelizacao do cliente                                      ���
��������������������������������������������������������������������������Ĵ��
���          �        �      �                                             ���
���          �        �      �                                             ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Static Function Cr240aVale( aVetor, nLinha, oWs )

Local oDlgResg
Local oValor
Local oCodVale
Local nValor	:= Cr240aVal( aVetor[nLinha][4]	 )			// Valor
Local cCodVale	:= Space( Len( MAV->MAV_CODIGO ) )
Local lValid	:= .F.  
Local lNew		:= AliasIndic( "MB1" )    

DEFAULT oWs     := Nil      						    	// Web Service utilizado no FrontLoja

DEFINE MSDIALOG oDlgResg FROM 10,20 TO 150,300 TITLE STR0006 PIXEL STYLE DS_MODALFRAME

	@ 05,10 SAY STR0006 SIZE 30,8 PIXEL OF oDlgResg			// "Valor" 
	
	@ 05,57 MSGET oValor VAR nValor SIZE 50,8 PIXEL OF oDlgResg PICTURE "@E 99,999,999.99" ;
			WHEN .F. 
	
	@ 20,10 SAY STR0007 SIZE 30,8 PIXEL OF oDlgResg			// Nr.Vale-Compra
	@ 20,57 MSGET oCodVale VAR cCodVale SIZE 60,8 PIXEL OF oDlgResg PICTURE "@!" WHEN .T. 
	
	DEFINE SBUTTON FROM 50,070 TYPE 1 ACTION ( lValid := Crd2PsVal( cCodVale, nValor, aVetor,        0,     "1", nLinha), If(lValid, aVetor[nLinha][7] := cCodVale, ), If(lValid,oDlgResg:End(),)) ENABLE OF oDlgResg
	DEFINE SBUTTON FROM 50,105 TYPE 2 ACTION ( If (lNew, If ( MsgYesNo(STR0019 ),oDlgResg:End(), Nil ) , oDlgResg:End() ) ) ENABLE OF oDlgResg
	oDlgResg:LESCCLOSE := .F.
ACTIVATE MSDIALOG oDlgResg CENTER

Return( lValid )

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o	 �Crd240PesqVale� Autor �  Vendas Clientes  � Data �02/12/05   ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica se o Vale compra existe. Se existir faz a consisten ���
���          �cia do valor do Vale Compra.                                 ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Fidelizacao do cliente                                      ���
��������������������������������������������������������������������������Ĵ��
���          �        �      �                                             ���
���          �        �      �                                             ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/                             

Function Crd240PesqVale( cCodVale, nValor, aVetor, nTotPag, cOpc, nLinha, cMensagem, bAviso )

Local 	lRet		:= .T.								// Retorno da funcao
Local 	nX			:= 1                    			// Variavel auxiliar do For
Local   nDif		:= 0								// Diferenca do valor e do vale compras
Local 	cCodMot		:= ""								// Motivo
Local 	nMvCrdVdif	:= SuperGetMV("MV_CRDVDIF", ,.F.)  // Diferenca tolerada no pagamento do vale compras
Local 	nCr240aVa  	:= 0 								// verifica vale compra

DEFAULT	cOpc	 := "1"
DEFAULT nTotPag  := 0
DEFAULT aVetor	 := {}  
DEFAULT cMensagem:= ""
DEFAULT bAviso 	 := .T.

//�����������������������������������Ŀ
//�Verifica se o vale ja foi digitado.�
//�������������������������������������
If cOpc == "1"
	For nX:= 1 to Len( aVetor )
		nCr240aVa := Cr240aVal( aVetor[nX][4] )
		If aVetor[nX][1] .AND. nCr240aVa > 0
			If aVetor[nX][7] == cCodVale
				
				If bAviso
					aViso(STR0001, STR0011 + ".", {"OK"} ) //"Resgate de pontos" + "Vale Compra ja digitado. Digite outrou numero."	
				Else	
					cMensagem := "1"
				EndIf
				
				lRet := .F.
				
				
				
				Exit
			EndIf
		Endif
	Next nX
Else
	lRet := .T.
EndIf          

If lRet              

	dbSelectArea("MAV")
	dbSetOrder(1)
    
	If cOpc == "1"
		If DbSeek( xFilial( "MAV" ) + cCodVale )

				//������������������������������������������������Ŀ
				//�Verificar se o Vale esta ativou("Staus==1").    �
				//��������������������������������������������������
				If MAV->MAV_STATUS == '1'					// ATIVO    
					If MAV->MAV_VALOR <> nValor           
						If bAviso
							Aviso(STR0001, STR0009 + STR(nValor, 10,2) + ".", {"OK"} )	//"Resgate de pontos" + "Valor incorreto. Digite o Codigo do Vale Compra no Valor de : "
						Else
						cMensagem := "2"
						EndIf
						
						lRet := .F.	
						
					EndIf          
				Else 
					lRet := .F.
					
					If MAV->MAV_STATUS == '2' 				// RESGATADO
						If bAviso
							Aviso(STR0001, STR0012 , {"&OK"} ) // "Resgate de pontos" + "Vale compra ja resgatado. Digite outro numero. "
						Else
							cMensagem := "3"
					 	EndIf
					ElseIf MAV->MAV_STATUS == '3'			// RECEBIDO
						If bAviso
							Aviso(STR0001, STR0013 , {"&OK"} ) // "Resgate de pontos" + "Vale compra ja recebido. Digite outro numero. "
					 	Else
					 		cMensagem := "4"
						EndIf
					Else									// INATIVO
						If bAviso
							Aviso(STR0001, STR0014 , {"&OK"} ) // "Resgate de pontos" + "Vale compra inativo. Digite outro numero. "
						Else
							cMensagem := "5"
						EndIF
					EndIf
				EndIf
		Else
			If bAviso
				Aviso(STR0001, STR0010 + ".", {"OK"} )			// "Resgate de pontos" + "Vale Compra nao existe. Informe um numero valido."	
			Else
				cMensagem := "6"
			EndIf
			lRet := .F.	
		EndIf	 
		
	ElseIf cOpc == "2"      
		nValor := 0    
	
		For nX:=1 To Len ( aVetor )
			cCodVale := aVetor[nX][7]	

			If DbSeek( xFilial( "MAV" ) + cCodVale ) 
				If MAV->MAV_STATUS == '2'					// Resgatado
					nValor += MAV->MAV_VALOR             
				Else   
					lRet := .F.

					If MAV->MAV_STATUS == '1'				// RESGATADO
						If bAviso
							Aviso(STR0028, STR0029 + cCodVale + STR0030 , {"&OK"} ) //"Resgate de pontos" + "Vale compra ja resgatado. Digite outro numero. "
						Else
							cMensagem := "7"
						EndIf
					ElseIf MAV->MAV_STATUS == '3'			// RECEBIDO
						If bAviso
							Aviso(STR0028, STR0029 + cCodVale + STR0031 , {"&OK"} ) //"Resgate de pontos" + "Vale compra ja recebido. Digite outro numero. "
						Else
							cMensagem := "8"
					  	EndIf
					Else									// INATIVO
						If bAviso
							Aviso(STR0028, STR0029 + cCodVale + STR0032 , {"&OK"} ) //"Resgate de pontos" + "Vale compra inativo. Digite outro numero. "
						Else
							cMensagem := "9"
					    EndIF
					EndIf
					
				EndIf
			EndIf
		Next nX
		
		If lRet
			nDif := nTotpag - nValor
			
			If nDif < 0
				If ( nDif * -1 ) > nMvCrdVdif
					If bAviso
						Aviso(STR0028 + STR0033 ) // Recebimento de Vale Compra + " Total de Vale compra ultrapassa o valor da venda."
					Else
						cMensagem := "10"
					EndIF
						If !LJProfile( 19,@cSupervisor )   //Senha para liberar Vale Compra
							If bAviso
								Aviso(STR0008, STR0034, {"OK"} ) // "Caixa sem permissao para liberar Vale Compra."	
							EndIf
						Else
							//�����������������������������������������������������Ŀ
							//�Grava na tabela MAZ quem liberou o resgate.          �
							//�Status = 2 -> Liberacao no pagamento com vale compra �
							//�������������������������������������������������������
							cCodMot  := Crd240MawCons()
							Crd240GrvMaz( cSupervisor, "", cCodMot, "2" )
	
							lRet := .T.
						EndIf
				EndIf	
			EndIf
		Endif
	EndIf
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Cr240aVal �Autor  � Vendas Clientes    � Data �  12/11/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Cr240aVal( cString )
Local nVlrStr	:= 0

If ValType( cString ) == "C"
	cString	:= StrTran( cString,".",";" )
	cString	:= StrTran( cString,",","." )
	cString	:= StrTran( cString,";","," )
	nVlrStr	:= Round( Val( cString ), 2 )
ElseIf ValType( cString ) == "N"
	nVlrStr	:= cString
Endif
Return( nVlrStr )

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o	 �Crd240Pont    � Autor �  Vendas Clientes  � Data �02/12/05   ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Valida se a quantidade escolhida confere com a pontuacao     ���
���          �disponivel.                                                  ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Fidelizacao do cliente                                      ���
��������������������������������������������������������������������������Ĵ��
���          �        �      �                                             ���
���          �        �      �                                             ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/ 
Function Crd240Pont( nPontosAux, aColsTRB, oWs ) 
Local nX		:= 0		// Posicao do aColsTRB
Local nY		:= 0		// Quantidade de vale compras
Local nAuxPont	:= 0		// Pontuacao auxiliar
Local lRet		:= .F.		// Retorno da funcao
Local aAux		:= {}		// Auxiliar na montagem dos vales compra
Local aBackup	:= aClone( aColsTRB )		// Guarda o conteudo do aColsda tela
Local lValid	:= .F.		// Valida se o vale compra eh valido
Local lSai		:= .F.		// Verifica se marcou a opcao de cancelar o resgate (lValid == .F.)

DEFAULT oWs     := Nil 		// Web Service utilizado no FrontLoja

For nX := 1 To Len( aColsTRB )
	aColsTRB[ nX, 13 ] := aColsTRB[ nX, 1 ]
	aColsTRB[ nx, 1  ] := .T.   
	
	For nY := 1 To aColsTRB[ nX, 13 ]
		aAdd( aAux, aClone( aColsTRB[nX] ) )
	Next nY 	
Next nX	


For nX := 1 To Len( aAux )   
	If !lSai
		If (aAux[nX] [3] == "Vale Compras")
			lValid := Cr240aVale( aAux, nX, oWs ) 
	
			If lValid
				nAuxPont +=  aAux[ nX, 2 ] 
			Else                       
				aAux := {}    
				lSai := .T.
				Loop
			EndIf
		Else
			nAuxPont +=  aAux[ nX, 2 ] 	
		EndIf
	EndIf		
Next Nx

If nAuxPont	<= nPontosAux
	lRet := .T.    
	aColsTRB := aClone( aAux )   
	aRet := aClone( aAux ) 
Else
	aColsTRB := {}
	aColsTRB := aClone( aBackup )
	Alert( STR0035 )	// "Total selecionado supera a quantidade de pontos do cliente!"	
EndIf
		
Return ( lRet )		

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o	 �Cr240LinOk    � Autor � Vendas Clientes   � Data �02/12/05   ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Valida se a quantidade escolhida confere com a pontuacao     ���
���          �disponivel.                                                  ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Fidelizacao do cliente                                      ���
��������������������������������������������������������������������������Ĵ��
���          �        �      �                                             ���
���          �        �      �                                             ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/ 
Function Cr240LinOk( nPontosAtu, oVlComp, nPontos )
Local lRet 		:= .F.		// Retorno da funcao
Local nPontUsa	:= 0		
Local nX		:= oVlComp:nAt 
Local nY		:= 0    
Local lEntra 	:= .T.


If ( &(ReadVar()) <> oVlComp:aCols[ oVlComp:nAt, 1 ] ) 
	If( &(ReadVar()) < oVlComp:aCols[ oVlComp:nAt, 1 ] )
		nPontosAtu += oVlComp:aCols[ oVlComp:nAt, 1 ] * oVlComp:aCols[ oVlComp:nAt, 2 ]     
	ElseIf ( &(ReadVar()) > oVlComp:aCols[ oVlComp:nAt, 1 ] ) 	
		nPontosAtu -= oVlComp:aCols[ oVlComp:nAt, 1 ] * oVlComp:aCols[ oVlComp:nAt, 2 ]     
	EndIf
Else
	lEntra := .F.
	lRet := .T.	
EndIf  



//�������������������������������������������������������Ŀ
//�Soma todos os vales, exceto o que esta sendo alterado. �
//�O que esta sendo alterado sera somado um pouco adiante.�
//���������������������������������������������������������
For nY := 1 To Len( oVlComp:aCols )
	If nX <> nY
		nPontUsa += oVlComp:aCols[ nY, 1 ] * oVlComp:aCols[ nY, 2 ]	
	EndIf
Next nY		



//��������������������������������������������������������Ŀ
//�So' volto a pontuacao orignal caso nao tenha nenhum vale�
//�selecionado.                                            �
//����������������������������������������������������������

If nPontUsa == 0
	nPontosAtu := nPontos
EndIf	

If &(ReadVar()) > 0 .AND. lEntra
	nPontUsa += &(ReadVar()) * oVlComp:aCols[ nX, 2 ] 	
	If nPontUsa <= nPontos 

		nPontosAtu := nPontos - nPontUsa

		lRet := .T.
	    oPontos:Refresh()
	Else
		If nPontosAtu < 0 
			nPontUsa := 0
			For nY := 1 To Len( oVlComp:aCols )
				nPontUsa += oVlComp:aCols[ nY, 1 ] * oVlComp:aCols[ nY, 2 ]	
			Next nY	
			nPontosAtu := nPontos - nPontUsa 			
		EndIf	       
		
		Alert( STR0036 )	// "O cliente nao possui pontos para retirar vale compra."
	EndIf  
ElseIf &(ReadVar()) == 0
	lRet := .T.	        
EndIf	

oPontos:Refresh()		
Return( lRet )	

/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa   �   C()   � Autores �  Vendas Clientes       � Data �10/05/2005���
����������������������������������������������������������������������������Ĵ��
���Descricao  � Funcao responsavel por manter o Layout independente da       ���
���           � resolucao horizontal do Monitor do Usuario.                  ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function C(nTam)                                                         

Local nHRes	:= oMainWnd:nClientWidth			// Resolucao horizontal do monitor     

If nHRes == 640									// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)  
	nTam *= 0.8                                                                
ElseIf ( nHRes == 798 ) .OR. ( nHRes == 800 )	// Resolucao 800x600                
	nTam *= 1                                                                  
Else											// Resolucao 1024x768 e acima                                           
	nTam *= 1.28                                                               
EndIf                                                                         

Return Int(nTam)          


/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o	 �Crd2PsVal		� Autor �  Vendas Clientes  � Data �02/12/05   ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica se o Vale compra existe. Se existir faz a consisten ���
���          �cia do valor do Vale Compra.                                 ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Fidelizacao do cliente                                      ���
��������������������������������������������������������������������������Ĵ��
���          �        �      �                                             ���
���          �        �      �                                             ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/                             
Function Crd2PsVal( cCodVale, nValor, aVetor, nTotPag, cOpc, nLinha ) 

Local lRet	:= .T.
Local nX								
Local cMensagem := ""

DEFAULT	cOpc	:= "1"
DEFAULT nTotPag := 0
DEFAULT aVetor	:= {}

oSvc := WSFRTBAIXACRD():New()
iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oSvc),Nil) //Monta o Header de Autentica��o do Web Service
oSvc :_URL := "http://"+AllTrim(LJGetStation("WSSRV"))+"/FRTBAIXACRD.apw"
//�������������������������������Ŀ
//� Cria o array dentro do metodo �
//���������������������������������
oSvc:oWSACRDITENS:OWSVERARRAY 						:= FRTBAIXACRD_ARRAYOFWSCRDITENS():New()
oSvc:oWSACRDITENS:OWSVERARRAY:OWSWSCRDITENS 		:= Array( Len(aVetor) )
//���������������������������������������������Ŀ
//�Antes de chamar o metodo, atribui os valores �
//�as propriedades (passagem de parametros)     �
//�����������������������������������������������
For nX := 1 To Len(aVetor)
	
	oSvc:oWSACRDITENS:OWSVERARRAY:OWSWSCRDITENS[nX] := FRTBAIXACRD_WSCRDITENS():New()
	
	oSvc:oWSACRDITENS:OWSVERARRAY:OWSWSCRDITENS[nX]:lA		:=	aVetor[nX][1]
	oSvc:oWSACRDITENS:OWSVERARRAY:OWSWSCRDITENS[nX]:nB		:=	aVetor[nX][2]
	oSvc:oWSACRDITENS:OWSVERARRAY:OWSWSCRDITENS[nX]:cC		:=	aVetor[nX][3]
	oSvc:oWSACRDITENS:OWSVERARRAY:OWSWSCRDITENS[nX]:cD		:=	aVetor[nX][4]
	oSvc:oWSACRDITENS:OWSVERARRAY:OWSWSCRDITENS[nX]:cE		:=	aVetor[nX][5]
	oSvc:oWSACRDITENS:OWSVERARRAY:OWSWSCRDITENS[nX]:cF		:=	aVetor[nX][6]
	oSvc:oWSACRDITENS:OWSVERARRAY:OWSWSCRDITENS[nX]:cG		:=	aVetor[nX][7]
	oSvc:oWSACRDITENS:OWSVERARRAY:OWSWSCRDITENS[nX]:cH		:=	aVetor[nX][8]
	oSvc:oWSACRDITENS:OWSVERARRAY:OWSWSCRDITENS[nX]:cI		:=	aVetor[nX][9]
	oSvc:oWSACRDITENS:OWSVERARRAY:OWSWSCRDITENS[nX]:cJ		:=	aVetor[nX][10]
	oSvc:oWSACRDITENS:OWSVERARRAY:OWSWSCRDITENS[nX]:cL		:=	aVetor[nX][11]
	oSvc:oWSACRDITENS:OWSVERARRAY:OWSWSCRDITENS[nX]:cM		:=	aVetor[nX][11]
Next nX


oSvc:FRTBXcrd(, cCodVale, nValor,  nTotPag, cOpc, nLinha)
	
If oSvc:NFRTBXCRDRESULT > 0 
	lRet := .F.
	cMensagem :=  ALLTRIM(str(oSvc:NFRTBXCRDRESULT))
EndIf

Do Case
	Case cMensagem == "1"
		Aviso(STR0001, STR0011 + ".", {"OK"} ) //"Resgate de pontos" + "Vale Compra ja digitado. Digite outrou numero."	
	Case cMensagem == "2"
		Aviso(STR0001, STR0009 + STR(nValor, 10,2) + ".", {"OK"} )	//"Resgate de pontos" + "Valor incorreto. Digite o Codigo do Vale Compra no Valor de : "
	Case cMensagem == "3"
		Aviso(STR0001, STR0012 , {"&OK"} ) // "Resgate de pontos" + "Vale compra ja resgatado. Digite outro numero. "		
	Case cMensagem == "4"
		Aviso(STR0001, STR0013 , {"&OK"} ) // "Resgate de pontos" + "Vale compra ja recebido. Digite outro numero. "
	Case cMensagem == "5"
		Aviso(STR0001, STR0014 , {"&OK"} ) // "Resgate de pontos" + "Vale compra inativo. Digite outro numero. "
	Case cMensagem == "6"
		Aviso(STR0001, STR0010 + ".", {"OK"} )			// "Resgate de pontos" + "Vale Compra nao existe. Informe um numero valido."	
	Case cMensagem == "7"
		Aviso(STR0028, STR0029 + cCodVale + STR0030 , {"&OK"} ) //"Resgate de pontos" + "Vale compra ja resgatado. Digite outro numero. "
	Case cMensagem == "8"
		Aviso(STR0028, STR0029 + cCodVale + STR0031 , {"&OK"} ) //"Resgate de pontos" + "Vale compra ja recebido. Digite outro numero. "
	Case cMensagem == "9"
		Aviso(STR0028, STR0029 + cCodVale + STR0032 , {"&OK"} ) //"Resgate de pontos" + "Vale compra inativo. Digite outro numero. "
	Case cMensagem == "10"
		Aviso(STR0028 + STR0033 ) // Recebimento de Vale Compra + " Total de Vale compra ultrapassa o valor da venda."
EndCase 

Return(lRet)       
