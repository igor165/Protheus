#INCLUDE "TCBROWSE.CH"
#INCLUDE "PROTHEUS.CH"   
#INCLUDE "CRDA240.CH"   
#INCLUDE "CRDDEF.CH"  

Static lMVLJPDVPA := FindFunction("LjxBGetPaf") .AND. LjxBGetPaf()[2] //Indica se é pdv  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³CRD240Resgate ³ Autor ³ Vendas Clientes   ³ Data ³01/12/05   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Faz o resgate dos pontos e entrega do cartao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fidelizacao do cliente                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³      ³                                             ³±±
±±³          ³        ³      ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Crd240Resgate( cCartao,  cCliente	, cLoja		, cMsgResg	,;
						nPontVen, aLibera	, nTotVen	, oWs 		)

Local aCriterio		:= {}			// Criterio para resgate dos pontos
Local aDados		:= {}			// Array com os dados selecionados
Local lRet			:= .T.			// Retorno da funcao
Local cCodCam		:= ""			// Codigo da Campanha
Local cNomeCli		:= ""			// Nome do cliente
Local cDtIniCam 	:= ""			// Data inicial da campanha
Local cDtFinCam   	:= ""			// Data final da campanha
Local nPontos		:= 0 			// Quantidade de pontos
Local lAcponto		:= SuperGetMV("MV_CRDACPT", ,.F.)  // Indica se utiliza acumulo de pontos entre campanhas       
Local lRetPE		:= .T.			// Retorno do ponto de entrada
Local lCrd 			:= .T.			// Informa que eh do CRD      
Local nX			:= 0			// Auxiliar de looping    
Local lMostra		:= .F.			// Verifica se mostra a pergunta de resgate de titulos
Local lExecFinan	:= .T.			// Verifica se executa o Crd240Finan
Local LjSupAtraso	:= ""			// LjSupAtraso
Local lRetCrit		:= .T.

DEFAULT cCliente	:= ""			// Codigo do cliente
DEFAULT cLoja   	:= ""			// Loja do cliente
DEFAULT cMsgResg 	:= ""			// Mensagem de resgate
DEFAULT nPontVen	:= 0 			// Pontos da venda ativa
DEFAULT aLibera		:= {}         	// Retorna quem liberou os premios 
DEFAULT oWs         := Nil          // Web Service utilizado

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o cartao e do dependente. Se for nao pode resgatar os pontos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ((nModulo == 23) .OR. lMVLJPDVPA) .AND. SuperGetMV("MV_FRTCRD",,.F.)
	oWs:CrdVerCart(cCartao, cCliente, cLoja) //"Executando consulta na retaguarda"
	lRet := oWs:LCRDVERCARTRESULT
Else
	lRet := Crd240Cartao (cCartao, cCliente, cLoja)
EndIf

lRet := .T.	
If lRet                                                                
	DbSelectArea("SA1")
	DbSetOrder( 1 )
	
	If DbSeek( xFilial( "SA1" ) + cCliente + cLoja )
		cNomeCli     := SA1->A1_NOME
	                                 
	    nPontos := nPontVen
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se existe alguma campanha ativa e tambem os criterios para resgate dos pontos. Se existir ³
		//³Armazena as Regras para resgate dos pontos. Vem ordenado do maior para o menor                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ((nModulo == 23) .OR. lMVLJPDVPA) .AND. SuperGetMV("MV_FRTCRD",,.F.)

			oWs:CrdCriteri(cCliente) //"Executando consulta na retaguarda"
			If Len(oWs:OWSCRDCRITERIRESULT:OWSCRDESTRCRI) > 0

				cCodCam 	:=	oWs:OWSCRDCRITERIRESULT:OWSCRDESTRCRI[1]:CCCODCAM
				cDtFinCam 	:=	oWs:OWSCRDCRITERIRESULT:OWSCRDESTRCRI[1]:DCDTFINCAM
				cDtIniCam   :=	oWs:OWSCRDCRITERIRESULT:OWSCRDESTRCRI[1]:DCDTINICAM
				lRetCrit 	:=	oWs:OWSCRDCRITERIRESULT:OWSCRDESTRCRI[1]:LLRET
				For nX := 1 to Len(oWs:OWSCRDCRITERIRESULT:OWSCRDESTRCRI[1]:OWSACRITERIO:OWSESTACRI)
					
					aAdd( aCriterio,{	oWs:OWSCRDCRITERIRESULT:OWSCRDESTRCRI[1]:OWSACRITERIO:OWSESTACRI[nX]:NPontos ,;  		
										oWs:OWSCRDCRITERIRESULT:OWSCRDESTRCRI[1]:OWSACRITERIO:OWSESTACRI[nX]:CValor	,;		
										oWs:OWSCRDCRITERIRESULT:OWSCRDESTRCRI[1]:OWSACRITERIO:OWSESTACRI[nX]:CProduto ,;		
										oWs:OWSCRDCRITERIRESULT:OWSCRDESTRCRI[1]:OWSACRITERIO:OWSESTACRI[nX]:CPERDES ,;		
										oWs:OWSCRDCRITERIRESULT:OWSCRDESTRCRI[1]:OWSACRITERIO:OWSESTACRI[nX]:CTipo ,;									
										oWs:OWSCRDCRITERIRESULT:OWSCRDESTRCRI[1]:OWSACRITERIO:OWSESTACRI[nX]:CSequem ,;      
										oWs:OWSCRDCRITERIRESULT:OWSCRDESTRCRI[1]:OWSACRITERIO:OWSESTACRI[nX]:CPreco ,;      								
										oWs:OWSCRDCRITERIRESULT:OWSCRDESTRCRI[1]:OWSACRITERIO:OWSESTACRI[nX]:CCodCam} )
	            
	            Next nX
	    	
	    	Else
		    	lRetCrit := .F.
			EndIf
		Else

			lRetCrit := Crd240Criterio( @cCodCam, @aCriterio, @cDtIniCam, @cDtFinCam )
			
		Endif
		
		If lRetCrit 
			
			If ((nModulo == 23) .OR. lMVLJPDVPA) .AND. SuperGetMV("MV_FRTCRD",,.F.)

				oWs:CrdPontCli(cCliente, cLoja, cCodCam, lAcponto) //"Executando consulta na retaguarda"
				nPontos := oWs:NCRDPONTCLIRESULT

			Else

				nPontos := CrdPontCli(cCliente, cLoja, cCodCam, lAcponto)

			EndIf
						
			
			
			If nPontos > 0

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ponto de entrada para validar se a tela de retirada de premios deve ser exibida ou nao³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock("CRD2403")
					lRetPE	:=	ExecBlock( "CRD2403", .F., .F., { nPontos }  )
				Endif
				
				For nX := 1 to Len( aCriterio )
					If nPontos > aCriterio[ nX, 1 ]
						lMostra := .T.
					EndIf
				Next nX		
						               	
				
				If lRetPE .AND. lMostra
					If LjAtraso( cCliente, cLoja, lCrd )
						lExecFinan := .F.
						If MsgYesNo( STR0030 )	// "Cliente possui títulos vencidos. Deseja resgatar vales compra?"
							lRetPE := LjProfile( 19		,@LjSupAtraso 	, NIL , NIL ,;
												 NIL	, .T.			, NIL )   //Senha para liberar Vale Compra
						Else
							lRetPE := .F.
						EndIf  
					Else
						lRetPE := .T.	   
					EndIf	        
				EndIf
				If lRetPE
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Chama a função para montar a listbox com as opcoes de resgate ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aDados :=	Crda240A(	nPontos		,;	// 01 Pontos que o cliente possui
											cCliente	,;	// 02 Codigo do cliente	
											cLoja		,;	// 03 Loja	
											cNomeCli	,;	// 04 Nome do cliente
											cDtIniCam	,;	// 05 Data Inicial da Campanha
											cDtFinCam	,;	// 06 Data Final da Campanha
											aCriterio	,;	// 07 Array com os criterios de resgate dos pontos
											cCodCam		,;	// 08 Codigo da campanha
											nTotVen		,; // 09 Pontuacao da venda 
											oWs )	 	       
											
					If  Len(aDados) > 0 .AND.;
						!Crd240Finan( 	cCliente	,;	// 01 Codigo do cliente
										cLoja		,;	// 02 Loja
										cDtIniCam	,;	// 03 Data inicial da campanha
										cDtFinCam	,;	// 04 Data final da campanha
										aDados		,;	// 05 Premios a resgatar  
										@aLibera	,;  // 06 Premios liberados
										lExecFinan	,;  // 07 Se executa a Crd240Finan
										LjSupAtraso ,;
										oWs )	// 08 Supervisor que executou
						aDados := {}
					Endif
				Endif
			Endif
		
		Endif
	Endif                          
Endif	
Return(aDados)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Crd240Criterio³ Autor ³ Vendas Clientes   ³ Data ³02/12/05   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna os criterios de resgate de ponto na orde decrescente ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fidelizacao do cliente                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                             

Function Crd240Criterio( cCodCam, aCriterio, cDtIniCam, cDtFinCam, cTipRet)

Local cStatus		:= "1"									// Status da Campanha
Local lRet			:= .T.									// Variavel de controle
Local lRetSald		:= .T.									// Variavel de controle
Local nPreco		:= 0									// Preco do produto
Local cTabPad	    := AllTrim(SuperGetMv("MV_TABPAD"))		// Tabela de preco padrao
Local cCampo	    := ""                 		          	// Campo da tabela de preco padrao 
Local cTipo			:= "C"									// Armazena o tipo do campo MAU_PONTOS
Local aArea			:= {}									// Backup da area antes de procurar o type do MAU_PONTOS
Local aRet 			:= {}

Default	 cCodCam	:= "" 									// Codigo da campanha 
Default cDtIniCam	:= ""									// Data de inicio da campanha	 
Default cDtFinCam	:= ""									// Data do final da campanha
Default aCriterio	:= {}    								// Criterio para validacao da campanha  
Default cTipRet		:= ""                                   // Define o tipo do retorno

aArea := GetArea()
DbSelectArea("SX3") 
DbSetOrder( 2 )
If DbSeek( "MAU_PONTOS" )
	cTipo := X3_TIPO
EndIf
RestArea( aArea )
          
MA0->( DbSetOrder(3) )
If MA0->( DbSeek( xFilial("MA0") + cStatus ) )

	While MA0->( !Eof() ) .AND. dDataBase >= MA0->MA0_DTINI .AND. dDataBase <= MA0->MA0_DTFIN

		cCodCam 	:= MA0->MA0_CODCAM 
		cDtIniCam	:= MA0->MA0_DTINI
		cDtFinCam	:= MA0->MA0_DTFIN
	
		MAU->( DbSetOrder( 1 ) )
		If MAU->( DbSeek( xFilial( "MAU" ) + cCodCam ) )
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Adiciona no Array, os criterios existentes no MAU³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			While MAU->( !Eof() ) 						.AND.;
			      MAU->MAU_FILIAL == xFilial( "MAU" ) 	.AND.;
			      MAU->MAU_CODCAM == cCodCam
	
				If !Empty( MAU->MAU_PROD )
					lRetSald := CRD240Sald( MAU->MAU_PROD, 1 )
				Endif

				If lRetSald
					If !Empty( MAU->MAU_PROD )
						If SuperGetMv("MV_LJCNVDA",,.F.)
							LjxeValPre (@nPreco, Alltrim( MAU->MAU_PROD ))
						Else
							SB0->( DbSetOrder( 1 ) )
							If SB0->( DbSeek( xFilial( "SB0" ) +  Alltrim( MAU->MAU_PROD ) ) )
								cCampo := "B0_PRV"+cTabPad
								nPreco	:= SB0->(&cCampo)					
							Endif
						EndIf

					Endif
															
					aAdd( aCriterio, {	If( cTipo == "C", Val(MAU->MAU_PONTOS), MAU->MAU_PONTOS ), ;
										Transform( MAU->MAU_VALOR, "@E 999,999,999.99" ) ,;
										MAU->MAU_PROD,;
										Transform( MAU->MAU_PERDES, "@E 999.99" ) ,;
										MAU->MAU_TIPO,;
										MAU->MAU_SEQUEN,;
										Transform( nPreco, "@E 999,999,999.99" ),;
										MAU->MAU_CODCAM } )										
											
				Endif
				MAU->( DbSkip() )               
			End
	
			aSort( aCriterio,,, {|a,b| a[1] > b[1] })
		Else                                          
			lRet := .F.
		Endif                          
		MA0->( DbSkip() )
	End
Else
	lRet := .F.
Endif



If cTipRet == "ws"
	
	aAdd( aRet, {cCodCam, aCriterio, cDtIniCam, cDtFinCam, cTipRet } )										
	Return	aRet

EndIF
Return lRet    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Crd240Finan   ³ Autor ³ Vendas Clientes   ³ Data ³02/12/05   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se o cliente comprou algum produto no periodo da    ³±±
±±³          |campanha, e se nao tem nenhuma parcela em aberto no financei-³±±
±±³          |ro. Caso contrario somente libera atraves de senha.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fidelizacao do cliente                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³      ³                                             ³±±
±±³          ³        ³      ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                             

Function Crd240Finan( 	cCliente, cLoja		, cDtIniCam		, cDtFinCam		,;
						aVale	, aLibera	, lExecFinan	, LjSupAtraso, oWs	)

Local lRet			:= .T.   
Local lUniComp		:= .T.
Local lTemComp  	:= .F.
Local lAcponto		:= SuperGetMV("MV_CRDACPT", ,.F.)  //Indica se utiliza acumulo de pontos entre campanhas
Local cSupervisor	:= Space(15)                                                                        
Local nX			:= 0                           
Local cCodMot		:= ""       
Local cTipMen 		:= ""

Default aLibera		:= {}                                                              
Default lExecFinan	:= .T.
DEfault LjSupAtraso	:= ""
DEFAULT oWs         := Nil          // Web Service utilizado
                                 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Considera-se como titulos vencidos:      ³
//³- Saldo > 0  E Data Venc Real < Data Base³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Mesmo para titulos ja baixados(dinheiro) ³
//³deve considerar se eh a primeira compra  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lExecFinan
	// Verifica se 
	cTipMen := ""
	
	If ((nModulo == 23) .OR. lMVLJPDVPA) .AND. SuperGetMV("MV_FRTCRD",,.F.)

		oWs:CrdAtFin(cDtIniCam, cDtFinCam, cCliente, cLoja, lRet) //"Executando consulta na retaguarda"
		cTipMen 	:=	oWs:OWSCRDATFINRESULT:OWSLSTFIN[1]:CCTIPMEN
		lUniComp 	:=	oWs:OWSCRDATFINRESULT:OWSLSTFIN[1]:llUniComp
		lTemComp   	:=	oWs:OWSCRDATFINRESULT:OWSLSTFIN[1]:llTemComp
		lRet 		:=	oWs:OWSCRDATFINRESULT:OWSLSTFIN[1]:llRet   

	Else
		lRet := Crd240aAtFin(@cTipMen, @lUniComp, @lTemComp, cDtIniCam, cDtFinCam, cCliente, cLoja, lRet)

	EndIf
	
	If cTipMen == "1" 
		Aviso( STR0032, STR0008 + " " + STR0018, {STR0019} ) 	//#"Atenção" #"Resgate de Pontos" #"Existem parcelas vencidas. A liberação depende da permissão de caixa: Libera Vale Compra." #"OK"
	EndIf

	If lRet
		If lUniComp     
			// "Atencao" "Resgate de Pontos" ### "O cliente possui uma unica compra. A liberação depende da permissão de caixa: Libera Vale Compra." ### "OK"
			Aviso(  STR0032, STR0008 + " " + STR0020, {STR0019} )
			lRet := .F.
		ElseIf lAcponto
			lRet := lTemComp
		ElseIf !lTemComp
		    lRet := .F.
		Endif
	Endif   

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso lRet = .F., solicita senha de liberação para resgate de Vale Compra³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lRet
		If !LJProfile( 19,@cSupervisor )   //Senha para liberar Vale Compra
			// "Atencao" "Resgate de Pontos" ### "Caixa sem permissao para liberar Resgate de Vale Compra." ### "OK"
			Aviso( STR0032, STR0008 + " " + STR0021, {STR0019} )
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Apresenta a tela de motivo de liberacao para que o   ³
			//³infome o motivo da liberacao.                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCodMot  := Crd240MawCons()
			
			For nX:=1 To Len( aVale )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava na tabela MAZ quem liberou o resgate.³
				//³Status = 1 -> Liberacao no resgate         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
				aAdd( aLibera, { cSupervisor											,;	//01 Supervisor que liberou		
								 IIF(Empty(aVale[nX][3]), aVale[nX][4], aVale[nX][3])	,;	//02 Codigo do produto ou vale compra
								 cCodMot												,;	//03 Codigo do motivo de liveracao
								 STR(RESGATE,1) } )   										//04 Status = 1 (resgate)
			Next
	
			lRet := .T.
		Endif
	Endif

Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apresenta a tela de motivo de liberacao para que o   ³
	//³infome o motivo da liberacao.                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCodMot  := Crd240MawCons()
	
	For nX:=1 To Len( aVale )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava na tabela MAZ quem liberou o resgate.³
		//³Status = 1 -> Liberacao no resgate         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
		aAdd( aLibera, { LjSupAtraso											,;	//01 Supervisor que liberou		
						 IIF(Empty(aVale[nX][3]), aVale[nX][4], aVale[nX][3])	,;	//02 Codigo do produto ou vale compra
						 cCodMot												,;	//03 Codigo do motivo de liveracao
						 STR(RESGATE,1) } )   										//04 Status = 1 (resgate)
	Next

	lRet := .T.

EndIf

Return lRet                         


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Crd240FinRes  ³ Autor ³ Vendas Clientes   ³ Data ³03/12/05   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Faz a baixa dos pontos do saldo do cliente e troca o status  ³±±
±±³          |dos cartoes para recebido.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fidelizacao do cliente                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                             
Function Crd240FinRes(	cCliente, cLojaCli	, aVales, nUsado,;
						cDoc	, cSerie	)

Local nX 		:= 0								// Variavel auxiliar do For
Local aCam		:= {}								//Campanhas ativas            
Local lAcponto	:= SuperGetMV("MV_CRDACPT", ,.F.)  //Indica se utiliza acumulo de pontos entre campanhas       
Local lContinua := .F.								//Valida se continua o processamento
Local cStatus	:= ""								//Status da Regra de pontos
DEFAULT cDoc	:= ""                    			//Nro da Nota Fiscal
DEFAULT cSerie	:= ""								//Nro da Serie   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza Status do Vale Compra e tambem grava no MAY os premios resgatados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CRD240BxPr( cCliente, cLojaCli, aVales, cDoc,;
	 	    cSerie)			

DbSelectArea("MAS")
DbSetOrder(3)           
If DbSeek( xFilial("MAS")+cStatus )   //Busca Regra de pontos ativa

	While MAS->( !Eof() ) 						.AND.;
		  MAS->MAS_FILIAL == xFilial("MAS") 	.AND.;
		  MAS->MAS_STATUS == "1"
						
   		AADD ( aCam, { MAS_CODCAM } ) 
  		DbSkip()
  	End
Endif
            
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza o saldo de pontos                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
BEGIN TRANSACTION
	
	DbSelectArea("MAX")
	DbSetOrder(1)
	
	If DbSeek( xFilial("MAX")+cCliente+cLojaCli ) 
	    			
		While MAX->( !Eof() ) 						.AND.;
			  MAX->MAX_FILIAL == xFilial("MAX")		.AND.;
			  MAX->MAX_CODCLI == cCliente		   	.AND.;
			  MAX->MAX_LOJA   == cLojaCli  
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica o parametro MV_CRDACPT, caso for .F. atualiza o saldo³
			//³somente da campanha ativa, senao, faz pra todas.              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lAcponto                     
				lContinua := .F.
				For nX:=1 To Len( aCam )					
					If MAX->MAX_CODCAM = aCam[nX][1]
						lContinua := .T.
						exit			
					Endif 
				Next nX
			Else
				lContinua := .T.
			Endif    
			                
			If lContinua  
			
				If MAX->MAX_SALDO > 0
					If MAX->MAX_SALDO > nUsado
						Reclock("MAX")
						Replace MAX->MAX_SALDO With  MAX->MAX_SALDO - nUsado
						MsUnlock()
						Exit
					Else
						nUsado := nUsado - MAX->MAX_SALDO
						
						Reclock("MAX")
						Replace	MAX->MAX_SALDO With 0
						MsUnlock()
						
						If nUsado = 0
							Exit
						Endif			
					Endif			
				Endif			
			Endif						
			MAX->( DbSkip() )
		End
	Endif           
		
END TRANSACTION

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Crd240RegPontos³ Autor ³ Vendas Clientes   ³ Data ³03/12/05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula pontos conforme criterios da tabela MAT              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Param     ³ cCliente : Codigo do cliente                                ³±±
±±³          ³ cLoja    : Loja do clinte                                   ³±±
±±³          ³ aProduto : Array com os produtos para analise dos pontos    ³±±
±±³          ³ nTotVen  : Total da Venda                                   ³±±
±±³          ³ cNum     : Numero do orcamento                              ³±±
±±³          ³ cSerie   : Serie                                            ³±±
±±³          ³ cOrigem  : Identifica se e do Loja ou do Televendas         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³cNum      : Numero do orcamento                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                             
                        
Function Crd240RegPontos( cCliente, cLoja, aProduto, nTotVen, cNum, cSerie, cOrigem, cPgVc )

Local aAreaSA1		:= SA1->(GetArea())	// Area do Arquivo de Cliente
Local cStatus   	:= "1"					// Status da regra de pontos
Local cGrupoCli	  	:= ""					// Grupo de clientes que incide a regra de pontos
Local nX			:= 0 					// Variavel de looping
Local nY			:= 0       				// Variavel de looping
Local nPontos		:= 0					// Pontos calculados no momento da venda
Local aMatGrupo		:= {}					// Agrupada por produto
Local lAchou		:= .F.					// Variavel de controle                                               
Local lRet	  		:= .F.					// Variavel de controle                                      


Default cOrigem		:= ""					// Caso tenha residuo de pontos mantem a origem                                                               
Default nTotVen		:= 0					// Total da venda
Default cPgVc		:= ""					// =1 indica se tem pagamento com vale compra
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o cliente tem cartao cadastrado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("MA6")
DbSetOrder(2) 	
If DbSeek( xFilial("MA6")+cCliente+cLoja )                                
	lRet := .T.                               
Endif

If lRet
	cGrupoCli := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"SA1->A1_GRPVEN")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Agrupa os dados por codigo do produto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX:=1 to Len( aProduto )
		lAchou := .F.
		
		For nY:=1 to Len( aMatGrupo )  
			If !Empty (aMatGrupo[nY][1] )
				If aMatGrupo[nY][1] == aProduto[nX][1]
					aMatGrupo[nY][3] += aProduto[nX][3]
					lAchou := .T.
				Endif
			Endif
		Next
		
		If !lAchou
			aADD( aMatGrupo, { aProduto[nX][1], aProduto[nX][2], aProduto[nX][3] } )
		Endif 
	Next
	
	DbSelectArea("MAS")
	DbSetOrder(3)
	
	If DbSeek( xFilial("MAS")+cStatus )          
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica todas as regras de pontuacao ativas para calcular os pontos   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ            
		While MAS->( !EOF() ) 				.AND.;
			  MAS_FILIAL == xFilial("MAS")	.AND.;
			  MAS_STATUS == cStatus
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Utiliza o array aProduto para cada critério de pontuacao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			aProduto := aClone( aMatGrupo ) 
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se a database esta dentro do periodo da campanha. Se nao tiver³
			//³o sistema na faz o calculo mesmo que a campanha esteja ativa           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If MAS->MAS_DTINI <= dDatabase .AND. MAS->MAS_DTFIN >= dDatabase
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Criterio  por cliente + loja  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(MAS->MAS_CODCLI) .AND. !Empty(MAS->MAS_LOJA)
				    
					If cCliente <> MAS->MAS_CODCLI .OR. cLoja <>	MAS->MAS_LOJA
						lRet := .F.
					Endif                       
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Criterio  por loja             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		     	ElseIf !Empty(MAS->MAS_LOJA)
					   If cLoja <>	MAS->MAS_LOJA
							lRet := .F.
						Endif                   
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Criterio  por Grupo de Vendas  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
				ElseIf !Empty(MAS->MAS_GRPVEN)
					If cGrupoCli <> MAS->MAS_GRPVEN
						lRet := .F.
					Endif
				Endif
		
				If lRet
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Regra de pontuacao da campanha³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("MAT")
					DbSetOrder(1)               
					If DbSeek( xFilial("MAT")+MAS->MAS_CODCAM )
		
		            	Do While MAT->( !EOF() ) 				.AND.;
		            	 		 MAT_FILIAL == xFilial("MAT")	.AND.;
		            	 		 MAT_CODCAM == MAS->MAS_CODCAM
		                    
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Calculo do pontos                                                                     ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							nPontos += Crd240CalcPontos( 	@aProduto		,;	// 01 Array com os produtos
															MAT->MAT_PROD	,;	// 02 Codigo do produto da regra
															MAT->MAT_GRUPO	,;	// 03 Grupo do produto da regra
															MAT->MAT_VALOR	,;	// 04 Valor total da regra
															MAS->MAS_PONTOS	,;	// 05 Numero de pontos da regra
															cPgVc			,;	// 06 Indica se e pagamento com vale compra
															nTotVen )			// 07 Total da venda		
		                    
		            		MAT->( DbSkip() )						  
		            		 
						End
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se tiver pontos grava um novo registro com os pontos³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If nPontos > 0
							DbSelectArea("MAX")
							DbSetOrder(1)
							Reclock("MAX",.T.)
							Replace	MAX->MAX_FILIAL		With xFilial("MAX")
							Replace	MAX->MAX_CODCAM		With MAS->MAS_CODCAM
							Replace	MAX->MAX_CODCLI		With cCliente	
							Replace	MAX->MAX_LOJA		With cLoja
							Replace	MAX->MAX_NUM		With cNum
							SerieNfId("MAX",1,"MAX_SERIE",dDataBase,LjEspecieNF(), cSerie) 
							Replace	MAX->MAX_DTMOV     	With dDatabase               
							Replace	MAX->MAX_PONTOS	    With nPontos
							Replace	MAX->MAX_SALDO	    With nPontos
							Replace	MAX->MAX_ORIG		With cOrigem
							MsUnlock()   
								      								  
						Endif						
					Endif
				Endif
			Endif   
			
			MAS->( DbSkip() )

		End
	Endif      
	
Endif

RestArea( aAreaSA1 )

Return lRet
                    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³CRD240ExcPon  ³ Autor ³ Vendas Clientes   ³ Data ³03/12/05   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Exclui o registro referente aos pontos da venda              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fidelizacao do cliente                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³      ³                                             ³±±
±±³          ³        ³      ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Crd240ExcPon( cNum, cSerie, cOrigem )

Local 	lRet 	:= .T.
Default	cOrigem	:= Space(TamSX3("MAX_ORIG")[1])
                     
cSerie := cSerie+Space(TamSX3("MAX_SERIE")[1]-Len(cSerie))


DbSelectArea("MAX")
DbSetOrder(3)

If DbSeek( xFilial("MAX")+cNum+cSerie )
    lRet := .F.
	While MAX->( !Eof() ) 						.AND.;
		  MAX->MAX_FILIAL == xFilial("MAX")		.AND.;
		  MAX->MAX_NUM    == cNum		  		.AND.;
		  MAX->MAX_SERIE  == cSerie
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³A variagem origem identifica se o titulo e do loja ou do Televendas³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cOrigem == MAX->MAX_ORIG
			MAX->(RecLock("MAX",.F.))
			MAX->MAX_SALDO := 0
			MAX->(MsUnLock())			          
			lRet := .T.
		Endif                
		MAX->( DbSkip() )
	End
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Crd240CalcPontos³ Autor ³ Vendas Clientes   ³ Data ³04/12/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula total de pontos conforme regra da tab. MAT           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fidelizacao do cliente                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³      ³                                             ³±±
±±³          ³        ³      ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Crd240CalcPontos( 	aProduto, 	cProd,	cGrupo,	nValor,;
							nMasPontos, cProp,	cPgVC, 	nTotVen )

LocaL	nPontos		:= 0                              	//Total de pontos
Local	nX			:= 0                              	//Contador
Local 	nFator		:= 0								//Fator utilizado para calcular nro de pontos
Local  	nDivisao	:= 0								// Resultado do valor da compra / valor da regra
Local 	nUsado		:= 0								//Valor usado para calculo dos pontos
Local 	nTotPontos	:= 0                               	//Valor total
Local 	lValor		:= .F.                            	//Indica se o criterio e por valor
Local 	lReincide	:= SuperGetMV("MV_CRDREIN", ,.F.)  //Indica se acumula pontos na reincidencia da regra
Default cProd		:= Empty()                        	//Codigo do produto
Default cGrupo		:= Empty()                        	//Codigo do grupo
Default nValor		:= 0 								//Valor da Regra de Pontos
Default cProp		:= 0                                //Considera centavos no calculo
Default cPgVc		:= ""								//1=pago com vale compra    
Default nTotVen		:= 0                              	//Total da Venda

For nX := 1 To Len( aProduto )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criterio por produto                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
	If aProduto[nX][1] == cProd .AND. cPgVc !="1"
		                 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se na regra tem Valor  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 	
	 	If nValor == 0               
	 		nPontos += nMasPontos * aProduto[nX][4]                             

	 	ElseIf aProduto[nX][3] > nValor
	 	
		     
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se calcula pontos quando o valor do produto for                     ³
			//³maior que o valor da regra.                                                  ³
			//³Exemplo: Regra:                                                              ³
			//³Prod = 000001   Valor=100   Pontos= 1                                        ³
			//³                                                                             ³
			//³Venda:                                                                       ³
			//³Prod = 000001   Valor=1000   Pontos= 1 ou se reincide = .t. calcula 10 pontos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
   			If lReincide	
           		nDivisao			:= aProduto[nX][3] / nValor	
           		nFator  			:= Int(nDivisao) 
           		nPontos				+= nMasPontos * nFator
	            	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Armazena o valor que foi utilizado para calculo dos pontos. e abate este valor.³
				//³EX: Venda =190... Regra= 100 == Pontos = 1... Abate =100 do saldo              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   			nUsado := aProduto[nX][3] - ( (nDivisao - nFator) * 100)
	            	
	   		Else
		       	nPontos += nMasPontos * aProduto[nX][4]                             
			Endif		  
		
		Endif	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se na regra tem Grupo  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf !Empty(aProduto[nX][2]) .AND. (aProduto[nX][2] == cGrupo) .AND. ( cPgVc !="1" )             
	 	If nValor == 0               
	 		nPontos += nMasPontos * aProduto[nX][4]                             
	 	
    	ElseIf lReincide
			nTotPontos	:= nTotPontos + aProduto[nX][3]
			If nTotPontos >= nValor			   
	           	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Armazena o valor que foi utilizado para calculo dos pontos. e abate este valor.³
				//³EX: Venda =190... Regra= 100 == Pontos = 1... Abate =100 do saldo              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
           		nPontos	:= nMasPontos * nFator
				nUsado	:= nTotPontos - ( (nDivisao - nFator) * 100) 
			EndIf
		Else
			nPontos	+= (nMasPontos * aProduto[nX][4])
		Endif                         
      	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se a compra e maior que o total³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	ElseIf nValor > 0      
 		lValor 		:= .T.
 		
 		If cPgVc == "1"
			nTotPontos 	:= nTotVen
			exit
 		Else
   			nTotPontos 	:= nTotPontos + aProduto[nX][3]   	
   		Endif
   		
   	Endif    
Next nX
     
If lValor .AND. (nTotPontos >= nValor)
	     	nDivisao			:= nTotPontos / nValor
        nFator  			:= IIf( cProp=="0",Int(nDivisao),  nDivisao )
        nPontos				+= nMasPontos * nFator
		            	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Armazena o valor que foi utilizado para calculo dos pontos. e abate este valor.³
			//³EX: Venda =190... Regra= 100 == Pontos = 1... Abate =100 do saldo              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nUsado := nTotPontos - ( (nDivisao - nFator) * 100) 
		Endif                         

Return nPontos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Crd240AtuValMat ³ Autor ³ Vendas Clientes   ³ Data ³04/12/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Baixa os valores utilizados no calculo dos pontos            ³±±
±±³Descri‡„o ³nOpc: 1) Produto, 2) Grupo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fidelizacao do cliente                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³      ³                                             ³±±
±±³          ³        ³      ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Crd240AtuValMat( aProduto, nOpc, nUsado, cProd, cGrupo )

Local   nX		:= 0                                                
Default cProd	:= "" 
Default cGrupo	:= "" 

If nOpc == 1

	For nX:=1 To Len( aProduto )                        	
		If aProduto[nX][1] == cProd 
			aProduto[nX][3] :=	aProduto[nX][3] - nUsado
			Exit
		Endif
	Next
	
ElseIf nOpc == 2
	For nX:=1 To Len( aProduto )                        	
		If aProduto[nX][2] == cGrupo 
			If aProduto[nX][3] <= nUsado
				aProduto[nX][3] :=	0              
				If aProduto[nX][3] == nUsado
					Exit
				Else
					nUsado := nUsado -	aProduto[nX][3]
				Endif
			Else
				aProduto[nX][3] :=	aProduto[nX][3] - nUsado
				Exit
			Endif		
		Endif
	Next
Else
	For nX:=1 To Len( aProduto )                        	
			If aProduto[nX][3] <= nUsado
				aProduto[nX][3] :=	0              
				If aProduto[nX][3] == nUsado
					Exit
				Else
					nUsado := nUsado -	aProduto[nX][3]
				Endif
			Else
				aProduto[nX][3] :=	aProduto[nX][3] - nUsado
				Exit
			Endif		
	Next	
Endif                                


Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Crd240TvendXTvale ³ Autor ³ Vendas Clientes   ³ Data ³06/12/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se o pagamento com vale e maior que o total da compra ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fidelizacao do cliente                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³      ³                                               ³±±
±±³          ³        ³      ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Crd240TvendXTvale(aVale, nTotVen, nTotVale  )

Local 	lRet		:= .T.
Local 	nX			:= 0
Local 	cSupervisor	:= Space(15)                                   
Local 	cCodMot		:= ""                                     
Local 	nMvCrdVdif	:= SuperGetMV("MV_CRDVDIF", ,.F.)  //Indica se utiliza acumulo de pontos entre campanhas       


If	nTotVale > nTotVen  
					
	If  (nTotVale - nTotVen) > nMvCrdVdif                                                           
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³""Atencao" Vale Compra" + "Total de Vale Compra nao pode ultrapassar" + "xxx" + " do total da venda" ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   	Aviso( STR0032, STR0002 + " " + STR0022 + " " + str(nMvCrdVdif) + STR0023, { STR0019 } ) 
	
		If !LJProfile( 19,@cSupervisor )   //Senha para liberar Vale Compra
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³" "Atencao" Resgate de Pontos" ### "Caixa sem permissao para liberar Resgate de Vale Compra." ### "OK"³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Aviso( STR0032, STR0008 + " " + STR0021, {STR0019} )
			lRet := .F.
		Else                                                     
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Apresenta a tela de motivo de liberacao para que o infome o motivo da liberacao.  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCodMot  := Crd240MawCons()
			
			For nX:=1 To Len( aVale )	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava na tabela MAZ quem liberou o resgate. Status = 2 -> Liberacao no pagamento com vale compra ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !aVale[nX][Len(aVale[nx])]
					Crd240GrvMaz(	cSupervisor		,;		// 01 Supervisor
					 				aVale[nX][1]	,;		// 02 Nro Vale
					 				cCodMot			,;	  	// 03 Motivo de liberacao
					 				STR(PAGAMENTO,1) ) 		// 04 Status
				Endif
			Next
			lRet := .T.
		Endif
	
	Endif
Endif
                                             
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Crd240ValidUsoVale³ Autor ³ Vendas Clientes  ³ Data ³06/12/05³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida vale compra no uso para pagamento                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fidelizacao do cliente                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³      ³                                             ³±±
±±³          ³        ³      ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Crd240ValidUsoVale( cCodVale, cStatus, nValor, dValidade  )

Local lRet  := .F.   
Local cStat := ""      

Default dValidade := dDatabase
                                                    
lRet := Crd240MavPesq( cCodVale, @cStat, @nValor, @dValidade  )

If cStat <> cStatus                                                                                          
	nValor := 0
	If Val(cStat) == ATIVO
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³"Atencao" "Vale Compra" + "xx", " não pode ser utilizado nesta operção, pois ainda não foi resgatado. " , "OK"³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aviso( STR0032, STR0002 + " " + alltrim(cCodVale) + " " + STR0024, { STR0019 } )
    ElseIf Val(cStat) ==  RECEBIDO
    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³"Atencao" "Vale Compra" + "xx", " não pode ser utilizado nesta operção, pois ja foi recebido. " , "OK"        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	Aviso( STR0032, STR0002 + " " + alltrim(cCodVale) + " " +STR0025, {STR0019} )
    ElseIf Val(cStat) == UTILIZADO
    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³"Atencao" "Vale Compra" + "xx", " não pode ser utilizado nesta operção, pois ja foi utilizado. " , "OK"       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	Aviso(  STR0032, STR0002 + " " + alltrim(cCodVale) + " " + STR0026, {STR0019} )
    ElseIf Val(cStat) == INATIVO
    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³"Atencao" "Vale Compra" + "xx", " não pode ser utilizado nesta operção, pois esta inativo. " , "OK"           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
    	Aviso( STR0032, STR0002 + " " + alltrim(cCodVale) + " " + STR0027, {STR0019} )
	Endif
Endif

If !Empty( dValidade ) .AND. dValidade <= dDatabase                                                           
    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³"Atencao" "Vale Compra" + "xx", " não pode ser utilizado nesta operção, pois esta vencido. " , "OK"           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
    	Aviso( STR0032, STR0002 + " " + alltrim(cCodVale) +  STR0031, {STR0019} )  
    	lRet := .F.     
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Crd240MavPesq   ³ Autor ³ Vendas Clientes   ³ Data ³06/12/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se existe o vale compra na tabela                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fidelizacao do cliente                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³      ³                                             ³±±
±±³          ³        ³      ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Crd240MavPesq( cCodVale, cStatus, nValor, dValidade  )

Local 	lRet		:= .F.    

DEFAULT	cStatus		:= ""
DEFAULT dValidade   := dDataBase

DbSelectArea("MAV")
MAV->( DbSetOrder(1) )
	
If MAV->( DbSeek( xFilial("MAV") + cCodVale) )
	cStatus := MAV->MAV_STATUS
	nValor	:= MAV->MAV_VALOR	
	If MAV->( FieldPos("MAV_DTVALI") ) > 0
		dValidade := MAV->MAV_DTVALI
	EndIf
	lRet := .T.
Else
	Aviso( STR0032, STR0008 + " " + STR0010 + ".", {STR0019} ) //"Atencao" "Resgate de pontos" + "Vale Compra nao existe. Informe um numero valido." ### "OK"
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Crd240MavPesq   ³ Autor ³  Vendas Clientes  ³ Data ³06/12/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza dados do ValeCompra.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fidelizacao do cliente                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³      ³                                             ³±±
±±³          ³        ³      ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Crd240UpdMAV( aVales, cStatus, nValor, lVoltaSt )

Local 	lRet		:= .T.
Local 	nX			:= 0   
Local  	aValeAtu	:= {} 
Local   nZ			:= 0
DEFAULT	cStatus		:= ""
DEFAULT	nValor		:= 0
Default lVoltaSt	:= .F.  


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Altera o status dos cartoes para RESGATADO (Status==2)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("MAV")
DbSetOrder(1)
                                    
For nX:=1 To Len( aVales )             

	If !aVales[nX][Len(aVales[nx])]
		If DbSeek( xFilial("MAV")+ aVales[nX][1] ) 
		
			RecLock("MAV",.F.) 
			//Guarda no array o status anterior para voltar, caso não localize um dos vales
			aAdd(aValeAtu,{ aVales[nx][1] , 	MAV->MAV_STATUS} )  

			Replace	MAV->MAV_STATUS With cStatus
			MsUnlock()
		Else
			//Retorna .F. e faz um rollback dos status alterados
			If lVoltaSt   
				nX--
				lRet := .F. 
				For nZ := 1 to nX
					If DbSeek( xFilial("MAV")+ aValeAtu[nX][1] ) 							
						RecLock("MAV",.F.) 
						Replace	MAV->MAV_STATUS With aValeAtu[nX][2]
						MsUnlock() 
					EndIf					
				Next
			EndIf
		Endif 
	Endif
Next     


Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Crd240GrvMaz    ³ Autor ³ Vendas Clientes   ³ Data ³06/12/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava usuario que liberou o Vale                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fidelizacao do cliente                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³      ³                                             ³±±
±±³          ³        ³      ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Crd240GrvMaz( cSupervisor, cVale, cMotivo, cStatus )

Local 	lRet	:= .T.   
Local 	cLoja	:= "" 		//Identificacao da loja no CRD (SLJ)
Local 	cCodEst	:= ""		//Codigo da estacao
DEFAULT cVale 	:= ""		//Numero do Vale Compra                                      
DEFAULT cMotivo	:= ""      	//Motivo de Liberacao


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca a identificacao da loja na tabela SLJ que e´utilizado no CRD.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cLoja := Posicione("SLJ",3,xFilial("SLJ")+cEmpAnt+cFilAnt,"SLJ->LJ_CODIGO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Altera o status dos cartoes para RESGATADO (Status==2)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("MAV")
DbSetOrder(1)               


RecLock("MAZ",.T.)               

Replace	MAZ->MAZ_USER 		With cSupervisor					//Superior que liberou o Vale
Replace	MAZ->MAZ_LOJA		With cLoja							//Busca do cadastro SL6 utilizado no CRD
Replace	MAZ->MAZ_CODPRD 	With cVale           				// Codigo do Vale
Replace	MAZ->MAZ_PDV		With AllTrim(LJGetStation("PDV")) 	//Nro do PDV
Replace	MAZ->MAZ_CODEST		With cCodEst						//Codigo da estacao
Replace	MAZ->MAZ_Data		With dDatabase       				//Data liberacao
Replace	MAZ->MAZ_Hora		With Time()							//Hora Liberacao
Replace	MAZ->MAZ_CODMOT		With cMotivo						//Motivo da liberacao do vale
Replace	MAZ->MAZ_STATUS		With cStatus						//Identifica se e resgate ou pagamento. 
	
MsUnlock()


Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Crd240ConMot    ³ Autor ³ Vendas Clientes   ³ Data ³07/12/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna o motivo da liberacao do vale                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fidelizacao do cliente                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³      ³                                             ³±±
±±³          ³        ³      ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Crd240MawCons( cTipo )

Local oDlgMot                                     	//Objeto da tela
Local cCodMot	:= Space(TamSX3("MAW_CODIGO")[1])	//Codigo do motivo de liberacao
Local cDescr	:= Space(TamSX3("MAW_DESCR")[1])	//Descricao do motivo de liberacao
Local lValid    := .F.	   							//Valida se o codigo do motivo e valido		

DEFAULT cTipo	:= ""	// identifica se a operacao e resgate ou pagamento utilizando vale compra

DEFINE MSDIALOG oDlgMot FROM 10,20 TO 140,300 TITLE STR0028 PIXEL    //"Motivo de liberação"

	@ 05,10 SAY "Codigo" SIZE 30,8 PIXEL OF oDlgMot  // "Codigo" 
	@ 05,43 MSGET oCodMot VAR cCodMot SIZE 40,9 PIXEL F3 "MAW" OF oDlgMot PICTURE PesqPict("MAW", "MAW_CODIGOD");
	valid Crd240MawPesq( cCodMot, @cDescr )

	@ 20,10 SAY "Descricao" SIZE 33,8 PIXEL OF oDlgMot  // "Descricao" 
	@ 20,43 MSGET oCodMot VAR cDescr SIZE 80,9 PIXEL WHEN .F.
		
		
	DEFINE SBUTTON FROM 40,070 TYPE 1 ACTION ( lValid := Crd240MawPesq( cCodMot ) , , ,If(lValid,oDlgMot:End(),)) ENABLE OF oDlgMot
	DEFINE SBUTTON FROM 40,105 TYPE 2 ACTION ( If(Crd240MawPesq( cCodMot ), oDlgMot:End(),Nil) ) ENABLE OF oDlgMot

ACTIVATE MSDIALOG oDlgMot CENTER

Return cCodMot
                    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Crd240MawPesq   ³ Autor ³ Vendas Clientes   ³ Data ³07/12/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna o motivo da liberacao do vale                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fidelizacao do cliente                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³      ³                                             ³±±
±±³          ³        ³      ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Crd240MawPesq( cCodMot, cDescr )

Local lRet 		:= .T.                       
Default cDescr	:= ""

DbSelectArea("MAW")
DbSetOrder(1)

If DbSeek( xFilial("MAW")+cCodMot )                                
	cDescr:=MAW->MAW_DESCR   
Else                                                     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³"Atencao " "Motivo de liberação","Codigo nao existe.",{"OK"}³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aviso( STR0032, STR0028 + " " + STR0029, {STR0019})
	lRet := .F.
Endif

Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Crd240_001       ³ Autor ³ Vendas Clientes   ³ Data ³03/12/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula pontos conforme criterios da tabela MAT               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Param     ³ cCliente  : Codigo do cliente                                ³±±
±±³          ³ cLoja     : Loja do clinte                                   ³±±
±±³          ³ aProduto  : Array com os produtos para analise dos pontos    ³±±
±±³          ³ nTotVen   : Total da Venda                                   ³±±
±±³          ³ cCodCam   : Codigo da Campanha                               ³±±
±±³          ³ cProp	 : Calcula pontos proporcional por item.            ³±±
±±³          ³ cPgVc	 : 1) Indica que o pagamento foi feito com vale     ³±±
±±³          ³ 			     compra e deve ser calculado os pontos sobre    ³±±
±±³          ³ 			     a diferenca                                    ³±±
±±³          ³ nMasPontos: Numero de pontos da venda original               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³cNum      : Numero do orcamento                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³      ³                                              ³±±
±±³          ³        ³      ³                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                             

Function Crd240_001( cCliente,	cLoja,	aProduto,	nTotVen,;
					 cCodCam,	cProp,	cPgVc,		nMasPontos )

Local 	aAreaSA1    := SA1->(GetArea())   	// Area do Arquivo de Cliente
Local	nX			:= 0 					// Contador utilizado na busca de produto
Local	nY			:= 0               		// Contador utilizado na busca do grupo de produto
LocaL	nPontos		:= 0					// Somatoria do numero de pontos obtido
Local   aMatGrupo	:= {}					//Agrupada por produto
Local  	lAchou		:= .F.                                               
Local   lRet	  	:= .F.

Default	cCodCam		:= "" 					// Codigo da campanha
Default cProp		:= "0"					// Calcula pontos proporcional por item. Usado na devolucao.  Se for == 1 ativa o calculo proporcional
Default cPgVc		:= ""					// =1 indica que o pagamento foi feito com vale compra e deve ser calculado os pontos sobre a diferenca
Default nTotVen		:= 0                  	// Total da Venda/Devolucao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o cliente tem cartao cadastrado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("MA6")
DbSetOrder(2) 	
If DbSeek( xFilial("MA6")+cCliente+cLoja )                                
	lRet := .T.                               
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Agrupa os dados por codigo do produto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len( aProduto )
	lAchou := .F.
	
	If Len(aProduto[nX]) < 4
		AAdd(aProduto[nX] , 1)
	EndIf
	
	For nY := 1 to Len( aMatGrupo )  
		If !Empty (aMatGrupo[nY][1] )     
			If aMatGrupo[nY][1] == aProduto[nX][1]
				aMatGrupo[nY][3] += aProduto[nX][3]
				aMatGrupo[nY][4] += aProduto[nX][4]
				lAchou := .T.
			Endif
		Endif
	Next nY
	
	If !lAchou
		aADD( aMatGrupo, { aProduto[nX][1], aProduto[nX][2], aProduto[nX][3] , aProduto[nX][4]} )
	Endif 
Next nX
	
		
aProduto := aClone( aMatGrupo )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Regra de pontuacao da campanha³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("MAT")
DbSetOrder(1)               
If DbSeek( xFilial("MAT")+ cCodCam )

	While MAT->( !EOF() ) 				.AND.;
		  MAT_FILIAL == xFilial("MAT")	.AND.; 
		  MAT_CODCAM == cCodCam
 		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calculo do pontos                                                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPontos += Crd240CalcPontos( 	@aProduto		,;	// 01 Array com os produtos da venda para calculo
										MAT->MAT_PROD	,; 	// 02 Codigo do produto da regra de pontuacao
										MAT->MAT_GRUPO	,;	// 03 Grupo do produto da regra de pontuacao
										MAT->MAT_VALOR	,;	// 04 Valor total da regra Ex: a cada 1 real = 1 ponto
										nMasPontos		,;	// 05 Pontos que a regra oferece a cada criterio atendigo
										cProp			,;	// 07 Calcula proporcional de pontos
										cPgVC			,;	// 08 Indica se existe pagamento com vale compra
										nTotVen )		  	// 09 Total da venda
		                    
		MAT->( DbSkip() )						  	 
	End				
	
Endif

RestArea( aAreaSA1 )

Return nPontos

/*                                                            
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Crd240_002       ³ Autor ³ Vendas Clientes   ³ Data ³03/12/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula pontos conforme criterios da tabela MAT               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Param     ³ cTipo	 : 1)Venda 2)Devolucao 3)Exclusao                   ³±±
±±³          ³ cCliente  : Codigo do cliente                                ³±±
±±³          ³ cLoja     : Loja do clinte                                   ³±±
±±³          ³ aProduto  : Array com os produtos para analise dos pontos    ³±±
±±³          ³ nTotVen   : Total da Venda                                   ³±±
±±³          ³ cNum   	 : Numero do orcamento                              ³±±
±±³          ³ cSerie    : Serie                                            ³±±
±±³          ³ cNumOrig  : Numero da venda original                         ³±±
±±³          ³ cSerieOrig: Serie da venda original                          ³±±
±±³          ³ cOrigem   : Identifica se e do Loja ou do Televendas         ³±± 
±±³          ³ lGravaMAX : Indica se grava MAX ou somente calcula pontos    ³±±
±±³          ³ nTotPontos: Total de pontos							        ³±±
±±³          ³ cPgVc     : Pagamento com Vale-Compra calcular sobre a dif.  ³±±
±±³          ³ lExcluiDev: Exclui os pontos gerados pela Troca / Devolucao  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³cNum      : Numero do orcamento                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                             

Function Crd240_002(cTipo, 		cCliente, 	cLoja, 		aProduto, 	;
					nTotVen, 	cNum, 		cSerie,		cNumOrig, 	;
					cSerieOrig,	cOrigem,	lGravaMAX,	nTotPontos, ;
					cPgVc,		lExcluiDev, aPremio  )

Local	lRet		:= .T.  							//Retorno da funcao
Local	nTotPon		:= 0 								//Total de pontos da devolucao/Troca/Exclusao
Local 	nTotPonOrig	:= 0                               	//Pontos da Venda original                                  
Local	cCodCam		:= ""								//Codigo da campanha
Local  	cStatus		:= "1"								//Status do criterio de pontuacao
Local 	cGrupoCli	:= ""								//Grupo de Cliente
Local 	lContinua	:= .T.								// Permite que seja utilizado somente uma regra de pontuacao
Local	aRecnos		:= {}								// Array com os registro que serao excluidos
Local	nI			:= 0								// Contador
Local	lNew		:= AliasInDic( "MB1" )				// Verifica se ha as melhorias no vale compra			
Local	cOper		:= ""								// Operacao do vale compra
Local 	nTotPtResg  := 0								// Valor Total dos Pontos Resgatados
Local 	nPtResg     := 0								// Total Pontos Resgatados	
Local 	nRecMax		:= 0								// Recebimento Maximo
Local 	lAtuMax		:= .F.								// Atualizacao
Local 	aArea		:= {}

DEFAULT cNumOrig	:= "" 
DEFAULT cSerieOrig	:= ""
DEFAULT cOrigem		:= ""   
DEFAULT lGravaMAX   := .T.
DEFAULT nTotPontos  := 0
DEFAULT cPgVc		:= ""								// =1 indica que foi pago com vale compra
DEFAULT lExcluiDev	:= .F.								// Exclui os pontos gerados pela Troca / Devolucao
DEFAULT aPremio		:= {}

If lNew .AND. cTipo == "2"   
	dbSelectArea("MB1")
	dbSetOrder(2) // MB1_FILIAL+MB1_SERIE+MB1_NF+MB1_CODIGO
	dbSeek(xFilial("MB1") + cSerieOrig + cNumOrig)
			
	While !EOF() .AND. MB1->MB1_FILIAL + MB1->MB1_SERIE + MB1->MB1_NF == xFilial("MB1") + cSerieOrig + cNumOrig
		If MB1->MB1_OPER == 3 .OR. MB1->MB1_OPER == 2	// Utilizado ou Resgatado
			If MB1->MB1_OPER == 2   	
				cOper := "4"
			ElseIf MB1->MB1_OPER == 3 	  
				cOper := "2"
			EndIf						 		
		EndIf
		dbSkip()
	End	
EndIf			


If lExcluiDev
	DbSelectArea("MAX")
	DbSetOrder(3)	//Filial + Numero + Serie
	
	If dbSeek(xFilial("MAX") + cNum + cSerie)
		While !(MAX->(Eof())) .AND. (MAX->MAX_NUM + MAX->MAX_SERIE == cNum + cSerie)
			If (MAX->MAX_CODCLI + MAX->MAX_LOJA == cCliente + cLoja)
				Aadd( aRecnos, { MAX->(Recno()) })
			EndIf
			MAX->(DbSkip())
        End
		For nI := 1 to Len(aRecnos)
			MAX->(DbGoTo(aRecnos[nI][1]))
			// Exclui os pontos gerados pela Troca / Devolucao
			Reclock("MAX",.F.)
			DbDelete()
			MsUnlock()
		Next nI
	EndIf
Else
	cGrupoCli := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"SA1->A1_GRPVEN")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se e DEVOLUCAO OU EXCLUSAO E TENHA NOTA ORIGINAL  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( Val(cTipo) == DEVOLUCAO .OR. Val(cTipo) == EXCLUSAO ) .AND. !Empty( cNumOrig )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca o numero de pontos da venda original ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("MAX")
		DbSetOrder(3) 	
		
		If DbSeek( xFilial("MAX")+cNumOrig+cSerieOrig )                                
			
			While !MAX->(Eof()) 				.AND.;
				  MAX->MAX_NUM   == cNumOrig 	.AND.; 
				  MAX->MAX_SERIE == cSerieOrig 			    
  							

				nPontosOrig	:= MAX->MAX_PONTOS
				nSaldoOrig	:= MAX->MAX_SALDO
				cCodCam 	:= MAX->MAX_CODCAM 		

				If MAX->( FieldPos( "MAX_PTRESG" ) ) > 0
					nPtResg 	:= MAX->MAX_PTRESG
				EndIf
	
				If nPtResg > 0 .AND. nSaldoOrig > 0
					nRecMax := Recno()
				EndIf
				
				DbSelectArea("MAS")
				DbSetOrder(1)                   
				If DbSeek( xFilial("MAS")+cCodCam )		
	                 
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Chama a funcao para calcular os pontos da devoucao/troca/exclusao           ³
					//³O penultimo parametro e igual a 1 para permitir calcular pontos proporcional|
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nTotPon := Crd240_001( 	cCliente		,;		//01 Codigo do cliente
											cLoja			,;		//02 Loja do clinte
											aProduto		,;		//03 Array com os produtos para analise dos pontos     
											nTotVen			,;		//04 Total da Venda  
											cCodCam			,;		//05 Codigo da Campanha 
											"0"				,;		//06 Calcula pontos proporcional por item. 
											Nil				,; 		//07 Indica que o pagamento foi feito com vale compra
											MAS->MAS_PONTOS )		//08 Nro de pontos a ser somado por criterio atendido
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Na devolucao ou Exclusao da nota,  calcula-se os pontos da devolucao   ³
					//³e gera um registro negativo no MAX  para abater do saldo. No caso      ³
					//³de o cliente ter resgatado o vale compra, seu saldo ficara negativo.   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nTotPon > 0
						If cTipo == "3"
							DbSelectArea("MB1")
							DbSetOrder(2) // MB1_FILIAL+MB1_SERIE+MB1_NF+MB1_CODIGO
							If DbSeek(xFilial("MB1") + cSerieOrig + cNumOrig)
								If MB1->MB1_OPER == 2
									cOper := "4"
								EndIf		
						 	EndIf
						EndIf
					    
						aArea	:=	MAX->(GetArea())    
					
						Reclock("MAX",.T.)
						Replace  MAX->MAX_FILIAL    With xFilial("MAX")
						Replace	 MAX->MAX_CODCAM	With cCodCam
						Replace	 MAX->MAX_CODCLI	With cCliente	
						Replace	 MAX->MAX_LOJA		With cLoja
						Replace	 MAX->MAX_NUM		With cNum
						SerieNfId("MAX",1,"MAX_SERIE",dDataBase,LjEspecieNF(), cSerie) 
						Replace	 MAX->MAX_DTMOV		With dDatabase               
						Replace	 MAX->MAX_PONTOS	With nTotPonOrig   
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se for devolucao volta os pontos originais.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

						If cOper == "4"

							If nSaldoOrig == 0 .AND. nPtResg > 0
								Replace MAX->MAX_SALDO		With nPtResg - nPontosOrig
							Else

								If nPtResg > 0
									Replace MAX->MAX_SALDO		With ( nSaldoOrig + nPtResg ) - nPontosOrig
								Else
									Replace MAX->MAX_SALDO		With nSaldoOrig							
								EndIf

								If	nSaldoOrig > 0 .AND. nPtResg > 0
									lAtuMax := .T.
								EndIf

							EndIf

						Else	   
							Replace MAX->MAX_SALDO		With (nTotPon+nPtResg) * (- (1))
						EndIf	

						Replace	 MAX->MAX_ORIG		With cOrigem
						MsUnlock()     											
						//RestArea(aArea)
					Endif
				Endif
			MAX->(DBSkip(2))
			End
		Endif

		If lAtuMax
		    DbGoTo(nRecMax)
		    Reclock("MAX",.F.)
			Replace MAX->MAX_SALDO With 0
		    MsUnLock()
		EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava os pontos de Venda e Devolucao sem nota de entrada ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Else
		
		DbSelectArea("MAS")
		DbSetOrder(3)
		
		If DbSeek( xFilial("MAS") + cStatus ) 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica todas as regras de pontuacao ativas para calcular os pontos   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ            
			While MAS->( !EOF() ) 				.AND.;
				  MAS_FILIAL == xFilial("MAS")	.AND.; 
				  MAS_STATUS == cStatus			.AND.;
				  lContinua
	
				lRet := .T.		

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se a database esta dentro do periodo da campanha. Se nao tiver³
				//³o sistema na faz o calculo mesmo que a campanha esteja ativa           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If MAS->MAS_DTINI <= dDatabase .AND. MAS->MAS_DTFIN >= dDatabase
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Criterio  por cliente + loja  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty(MAS->MAS_CODCLI) .AND. !Empty(MAS->MAS_LOJA)
					    
						If cCliente <> MAS->MAS_CODCLI .OR. cLoja <>	MAS->MAS_LOJA
							lRet := .F.
						Endif                          
						
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Criterio  por loja             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			     	ElseIf !Empty(MAS->MAS_LOJA)
						   If cLoja <>	MAS->MAS_LOJA
								lRet := .F.
							Endif                   
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Criterio  por Grupo de Vendas  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
					ElseIf !Empty(MAS->MAS_GRPVEN)
						If cGrupoCli <> MAS->MAS_GRPVEN
							lRet := .F.
						Endif
					Endif				
	
					If lRet 

						nTotPontos := Crd240_001( 	cCliente		,;		//01 Codigo do cliente
													cLoja			,;		//02 Loja do clinte
													aProduto		,;		//03 Array com os produtos para analise dos pontos
													nTotVen			,;		//04 Total da Venda
													MAS->MAS_CODCAM	,;		//05 Codigo da Campanha
													Nil				,;		//06 Calcula pontos proporcional por item.
													cPgVc			,;		//07 Indica que o pagamento foi feito com vale compra
													MAS->MAS_PONTOS	)		//08 Nro de pontos a ser somado por criterio atendido

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Grava os pontos referente a venda ou devolucao sem nota de entrada ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lGravaMAX .AND. nTotPontos > 0
							DbSelectArea("MAX")
							DbSetOrder(1)
							Reclock("MAX",.T.)
							Replace MAX->MAX_FILIAL   	With xFilial("MAX")
							Replace MAX->MAX_CODCAM 	With MAS->MAS_CODCAM
							Replace MAX->MAX_CODCLI		With cCliente	
							Replace MAX->MAX_LOJA		With cLoja
							Replace MAX->MAX_NUM		With cNum
							SerieNfId("MAX",1,"MAX_SERIE",dDataBase,LjEspecieNF(), cSerie)
							Replace MAX->MAX_DTMOV     	With dDatabase               
							Replace MAX->MAX_PONTOS	    With nTotPontos
	
							If MAX->( FieldPos( "MAX_PTRESG" ) ) > 0 .AND. Len( aPremio ) > 0
								For nI := 1 to Len( aPremio )
									nTotPtResg += aPremio[nI][1]							
			  					Next nI
			  					
			  					Replace	MAX->MAX_PTRESG With nTotPtResg
			  					
			  					nTotPtResg := 0
	   						EndIf
	
							If Val(cTipo) == DEVOLUCAO
								Replace MAX->MAX_SALDO	With nTotPontos * (- (1))
							Else	
								Replace MAX->MAX_SALDO	With nTotPontos 					
							Endif
							Replace MAX->MAX_ORIG		With cOrigem
							MsUnlock()     					
							
							//Ponto de entrada apos inclusao MAX
							If ExistBlock("CRD240MX")
								ExecBlock("CRD240MX", .F., .F.)
							EndIf															
		
							lContinua := .F.	
						Endif
					EndIF		
				Endif             
				MAS->( DbSkip() )	
			End	
		Endif
	Endif
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Crd240_003       ³ Autor ³  Vendas Clientes  ³ Data ³08/12/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Busca os dados da campanha.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Param     ³ cOpc 	: 1)Campanha Ativa                                  ³±±
±±³          ³            2)procura por codigo da campanha                  ³±±
±±³          ³                                                              ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³cNum      : Numero do orcamento                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³      ³                                              ³±±
±±³          ³        ³      ³                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                             

Function Crd240_003( cOpc, cCodCam, cDtIniCam,	cDtFinCam )

Local	cChave	:= ""
Local	lRet	:= .T.

DEFAULT cOpcao	:= "1"
DEFAULT cCodCam	:= ""

DbSelectArea("MAS")

If cOpcao == "1"  
	DbSetOrder(3)
	cChave	:=xFilial("MAS")+"1"		//Procura campanha ativa STATUS==1
Else
	DbSetOrder(1)
	cChave	:=xFilial("MAS")+cCodCam	//Procura campanha ativa STATUS==1
Endif	
	
	
If DbSeek( xFilial("MAS")+cStatus ) 
	cCodCam 	:= MAS->MAS_CODCAM 
	cDtIniCam	:= MAS->MAS_DTINI
	cDtFinCam	:= MAS->MAS_DTFIN
Else
	lRet	:= .F.
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRD240SaldºAutor  ³ Vendas Clientes    º Data ³  11/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida saldo em estoque dos produtos que o cliente tem di-  º±±
±±º          ³reito nos criterios de resgate                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA240                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CRD240Sald( cProduto, nQuant )
Local cLocal	:= ""
Local lRet		:= .T.
Local lMvCrdEsto:= SuperGetMV("MV_CRDESTO", ,.F.)  // Indica se considera estoque

If lMvCrdEsto
	SB1->( DbSetOrder( 1 ) )
	If SB1->( DbSeek( xFilial( "SB1" ) + cProduto ) )
		cLocal := SB1->B1_LOCPAD
	
		SB2->( DbSetOrder( 1 ) )
		If SB2->( DbSeek( xFilial( "SB2" ) + cProduto + cLocal ) )
			If SaldoSB2() < nQuant
				lRet := .F.
			Endif
		Endif
	Endif
Endif
Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRD240BxPrºAutor  ³ Vendas Clientes    º Data ³  06/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza o status do vale compra quando este for entregue aoº±±
±±º          ³cliente e tambem grava o resgate dos premios no MAY         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1 - Codigo do cliente                                  º±±
±±º          ³ ExpC2 - Loja do cliente                                    º±±
±±º          ³ ExpA3 - Array com os premios resgatados                    º±±
±±º          ³ ExpC4 - Numero do documento                                º±±
±±º          ³ ExpC5 - Serie do documento                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA240                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRD240BxPr( cCliente, 	cLojaCli,	aVales,    cDoc,;
		  			  cSerie)
	
Local nX	:= 0	//Contador
Local lRet	:= .T.	//Retorno da Funcao
Local cLoja	:= ""	//Nro da Loja SL6                     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca a identificacao da loja na tabela SLJ que e´utilizado no CRD.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cLoja := Posicione("SLJ",3,xFilial("SLJ")+cEmpAnt+cFilAnt,"SLJ->LJ_CODIGO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Altera o status dos cartoes para RESGATADO (Status==2)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
	Help MAV_STATUS
	Status do Vale-Compra.
	1 - Ativo     : O Vale-Compra esta disponivel para ser entregue aos clientes.
	2 - Resgatado : O Vale-Compra foi entregue ao cliente.
	3 - Recebido  : O Vale-Compra foi utilizado pelo cliente no pagamento da compra.
	4 - Inativo   : O Vale-Compra está inativo e nao poderá ser utilizado.
	// Valores dos status do Vale Compra (Ref. MAV_STATUS)
	#DEFINE ATIVO			1 
	#DEFINE RECEBIDO		2
	#DEFINE UTILIZADO		3
	#DEFINE INATIVO	   		4 
*/

         
For nX:=1 To Len( aVales )
	DbSelectArea("MAV")
	DbSetOrder(1)

	If !Empty(aVales[nX][4])   // posicao 4= nro do vale compra
		If DbSeek( xFilial("MAV")+aVales[nX][4] ) 
			RecLock("MAV",.F.)
			Replace MAV->MAV_STATUS With STR(RECEBIDO,1) //02- RESGATADO
			MsUnlock()		

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se a MB1 esta no dicionario³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		 	If AliasIndic( "MB1" )
	 			CRDA270Log( aVales[nX], "2", cDoc, AllTrim(LJGetStation("PDV")), cSerie )			 	
		 	EndIf 
			
		Endif
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faz a gravacao do MAY - CLIENTE X RESGATE DE PREMIO                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	RecLock("MAY",.T.)
	If Empty(aVales[nX][3])	
		Replace	MAY->MAY_CODPRD 	With aVales[nX][4]				// Codigo do vale compra
	Else
		Replace	MAY->MAY_CODPRD		With aVales[nX][3]				// Codigo do produto
	Endif
	Replace	MAY->MAY_CODCLI		With cCliente						//Codigo do cliente
	Replace	MAY->MAY_LOJCLI		With cLojaCli						//Loja do cliente
	Replace	MAY->MAY_LOJA		With cLoja							//Nro da Loja SL6	
	Replace	MAY->MAY_DATA		With dDatabase       				//Data liberacao
	Replace	MAY->MAY_HORA		With Time()							//Hora Liberacao
	Replace	MAY->MAY_PDV		With AllTrim(LJGetStation("PDV")) 	//Nro do PDV
	Replace	MAY->MAY_OPERAD		With xNumCaixa()  					//Operador
	Replace MAY->MAY_DOC		With cDoc							//Nro da NF
	SerieNfId("MAY",1,"MAY_SERIE",dDataBase,LjEspecieNF(), cSerie)		//Nro da Serie
    MsUnlock()
Next nX                                                      

Return lRet                            
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Crd240CartaoºAutor  ³ Vendas Clientes    º Data ³  06/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza o status do vale compra quando este for entregue ao  º±±
±±º          ³cliente e tambem grava o resgate dos premios no MAY           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1 - Cartao 			                                    º±±
±±º          ³ ExpC2 - Cliente			                                    º±±
±±º          ³ ExpA3 - Local                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA240                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Crd240Cartao (cCartao, cCliente, cLojaCli)

Local lRet := .T.

DEFAULT cCartao 	:= ""
DEFAULT cCliente	:= ""
DEFAULT cLojaCli	:= ""


If  !Empty( cCartao )
	DbSelectArea("MAC")
	DbSetOrder( 2 ) 	
	If DbSeek( xFilial( "MAC" ) + cCliente + cLojaCli )                                
		While MAC->( !Eof() ) 					 .AND.;
			  MAC->MAC_FILIAL == xFilial("MAC") .AND.;
			  MAC->MAC_CODCLI == cCliente		 .AND.;
			  MAC->MAC_LOJA   == cLojaCli
			
			If MAC->MAC_CART == cCartao
				lRet := .F.
				Exit
			Endif
			MAC->( DbSkip() )
		End                       
	Endif
Endif
	
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Crd240Pont  ºAutor  ³ Vendas Clientes    º Data ³  06/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna pontos de clientes									º±±
±±º          ³														        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1 - Cartao 			                                    º±±
±±º          ³ ExpC2 - Cliente			                                    º±±
±±º          ³ ExpA3 - Local                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA240                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CrdPontCli(cCliente, cLoja, cCodCam, lAcponto)

Local nPontos	:= 0
Local cChave	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso utilize somatoria de pontos de campanhas anteriores de conforme parametro MV_CRDACPT³
//³Total de pontos = Somatoria pontos campanha atual + Somatoria pontos campanha anterior   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAcponto
	cChave := xFilial( "MAX" ) + cCliente + cLoja
Else
	cChave := xFilial( "MAX" ) + cCliente + cLoja + cCodCam    		
Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca os pontos acumulados do cliente referente a campanha      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea( "MAX" )
DbSetOrder( 1 )
If DbSeek( cChave ) 
    			
	While MAX->( !Eof() ) 						.AND.;
	      MAX->MAX_FILIAL == xFilial("MAX") 	.AND.;
	      MAX->MAX_CODCLI == cCliente		 	.AND.;
	      MAX->MAX_LOJA   == cLoja
		
		If !lAcponto
			If MAX->MAX_CODCAM <> cCodCam
				Exit
			Endif
		Endif    
		nPontos	:= nPontos + MAX->MAX_SALDO
		MAX->( DbSkip() )
	End  

Endif

Return(nPontos)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Crd240aAtFinºAutor  ³ Vendas Clientes    º Data ³  06/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna se tem uma unica venda e se tem pacelas em atraso     º±±
±±º          ³														        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ 																º±±
±±º          ³ 							                                    º±±
±±º          ³ 				                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA240                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Crd240aAtFin(cTipMen, lUniComp,  lTemComp, cDtIniCam, cDtFinCam, cCliente, cLoja, lRet)

Default cTipMen 	:= "" 		// Tipo de menssagem que vai ser enviada
Default lUniComp	:= .T.		// inica compra
Default lTemComp  	:= .F.		// tem xompra
Default lRet		:= .T. 		// retorno



	DbSelectArea("SE1")
	DbSetOrder( 8 )     // Cliente+Loja+Status+Vencimento Real
	If DbSeek( xFilial("SE1")+cCliente+cLoja ) 
	        lUniComp := .F.
	    	While SE1->( !Eof() ) 					.AND.;
	    		  SE1->E1_FILIAL == xFilial("SE1")	.AND.; 
	    		  SE1->E1_CLIENTE == cCliente 	   	.AND.;
	    		  SE1->E1_LOJA == cLoja
	    	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			   //³Verifica se o cliente fez alguma compra durante o periodo da campanha.³
			   //³Este conceito so e valido se a empresa acumula pontos de outras       ³
			   //³campanhas.                                                            ³
			   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ							   		                          
			   If ValType(cDtIniCam) != "D"
				   cDtIniCam := CTOD(cDtIniCam)
			   EndIf
			   
			   If ValType(cDtFinCam) != "D"
				   cDtFinCam := CTOD(cDtFinCam)
			   EndIf

			   If SE1->E1_EMISSAO >= cDtIniCam .AND. SE1->E1_EMISSAO <= cDtFinCam
			      	lTemComp := .T.
	           Endif
					
			   If SE1->E1_SALDO > 0 .AND. SE1->E1_VENCREA < dDatabase	
	    	   		lRet	:= .F.
	    	   		cTipMen := 	"1"
	    	   Endif
	    	   
	    	   DbSkip()
	    	End
	Else
		Return(lRet)
	EndIf


Return(lRet)
