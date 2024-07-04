#include 'totvs.ch'
#include 'FWMVCDEF.CH'
#include 'FINA310.CH'

// #########################################################################################
// Projeto: 11.7
// Modulo : Financeiro
// Fonte  : FINA310.prw
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 18/09/12 | Marcos Berto	    | Gerenciamento de Arquivo Pagamento Elet.
// ---------+-------------------+-----------------------------------------------------------

Function FINA310()

Local oBrowse

PRIVATE cCadastro := STR0001 //Gerenc. de Arquivo de Pagamento Eletron.

If cPaisLoc $ "ARG|RUS"
	dbSelectArea("FJB")
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("FJB")
	oBrowse:SetDescription(STR0001) //Gerenc. de Arquivo de Pagamento Eletron.
	oBrowse:AddLegend("FJB_STATUS = '1'","GREEN"	,STR0002) //Ativo
	oBrowse:AddLegend("FJB_STATUS = '2'","RED"	,STR0003) //Inativo
	oBrowse:AddLegend("FJB_STATUS = '3'","BLUE"	,STR0004) //Arquivo Gerado
	oBrowse:AddLegend("FJB_STATUS = '4'","BLACK"	,STR0005) //Retorno do Banco
	oBrowse:AddLegend("FJB_STATUS = '5'","PINK"	,STR0006) //Inativo por Erro
	oBrowse:AddLegend("FJB_STATUS = '6'","ORANGE"	,STR0007) //Baixado
	oBrowse:Activate()
Else
	Alert(STR0035+" "+STR0036) // Tabelas inexistentes. Favor atualizar o dicionário de dados
EndIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados do controle de lotes financeiros

@author    Marcos Berto
@version   11.7
@since     18/09/2012

@return oModel	Modelo de Dados

/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

local aRelacFJD := {}

Local oModel

Local oStrutFJB	:= FwFormStruct(1,"FJB")
Local oStrutFJD	:= FwFormStruct(1,"FJD")

oModel := MPFormModel():New("FINA310")

oStrutFJB:AddField(STR0008 	,STR0008 	,"FJB_DESC"	,"C",20,0,,,,,{|| F242SitCab(FJB->FJB_STATUS)},,,.T.) //Status
oStrutFJd:AddField(""		,""			,"FJC_LEGEND"	,"C",15,0,,,,,{|| F310RetLeg(FJD->FJD_STATUS)},,,.T.)

oModel:AddFields("FJBMASTER",,oStrutFJB)

oModel:AddGrid("FJDDETAIL","FJBMASTER",oStrutFJD)

aAdd(aRelacFJD,{"FJD_FILIAL"	,"xFilial('FJD')"	})
aAdd(aRelacFJD,{"FJD_BANCO"		,"FJB_BANCO"		})
aAdd(aRelacFJD,{"FJD_AGENCI"	,"FJB_AGENCI"		})
aAdd(aRelacFJD,{"FJD_CONTA"		,"FJB_CONTA"		})
aAdd(aRelacFJD,{"FJD_NUMLOT"	,"FJB_NUMLOT"		})

oModel:SetRelation("FJDDETAIL",aRelacFJD,FJD->(IndexKey(1)))

oModel:SetPrimaryKey({"FJB_FILIAL","FJB_BANCO","FJB_AGENCI","FJB_CONTA","FJB_NUMLOT"})

oModel:SetDescription(STR0001)

oModel:GetModel("FJBMASTER"):SetDescription(STR0010)
oModel:GetModel("FJDDETAIL"):SetDescription(STR0011)

Return oModel


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função que define a interface do gerenciamento de arquivos do banco. 

@author    Marcos Berto
@version   11.7
@since     18/09/2012

@return oView	interface

/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oView

Local oModel := FWLoadModel("FINA310")

Local oStrutFJB :=FWFormStruct(2,"FJB")
Local oStrutFJD :=FWFormStruct(2,"FJD")

oStrutFJB:RemoveField("FJB_FILIAL")
oStrutFJB:RemoveField("FJB_STATUS")
oStrutFJB:AddField( "FJB_DESC","ZZ",RetTitle("FJB_STATUS"),RetTitle("FJB_STATUS"),,"C",,,,.F.,,,,,,,,.F.)

oStrutFJD:RemoveField("FJD_FILIAL")
oStrutFJD:RemoveField("FJD_BANCO")
oStrutFJD:RemoveField("FJD_AGENCI")
oStrutFJD:RemoveField("FJD_CONTA")
oStrutFJD:RemoveField("FJD_NUMLOT")
oStrutFJD:RemoveField("FJD_STATUS")
oStrutFJD:AddField( "FJC_LEGEND","","","",,"C","@BMP",,,.F.,,,,,,,,.F.)

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEW_FJB",oStrutFJB,"FJBMASTER")
oView:AddGrid("VIEW_FJD",oStrutFJD,"FJDDETAIL")

oView:AddUserButton(STR0043,"",{|oView| F310LegRet()}) //Lengenda

oView:CreateHorizontalBox("TOPO",20)
oView:CreateHorizontalBox("DETALHE",80)

oView:SetOwnerView("VIEW_FJB","TOPO")
oView:SetOwnerView("VIEW_FJD","DETALHE")

oView:EnableTitleView("VIEW_FJB")
oView:EnableTitleView("VIEW_FJD")

Return oView

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Menu Funcional

Parametros do array a Rotina:                       
	- Nome a aparecer no cabecalho                         
	- Nome da Rotina associada                            
	- Reservado                                          
	- Tipo de Transacaoo a ser efetuada:                  
		1 - Pesquisa e Posiciona em um Banco de Dados     
		2 - Simplesmente Mostra os Campos                   
		3 - Inclui registros no Bancos de Dados             
		4 - Altera o registro corrente                         
		5 - Remove o registro corrente do Banco de Dados       
	- Nivel de acesso                                       
	- Habilita Menu Funcional  

@author    Marcos Berto
@version   11.7
@since     18/09/2012
/*/
//------------------------------------------------------------------------------------------

Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title STR0012 /*Pesquisar*/ 		Action "VIEWDEF.FINA310" 	OPERATION 1 ACCESS 0 
ADD OPTION aRotina Title STR0013 /*Visualizar*/		Action "VIEWDEF.FINA310" 	OPERATION 2 ACCESS 0
ADD OPTION aRotina Title STR0014 /*Det. Lote*/ 		Action "VIEWDEF.FINA242" 	OPERATION 2 ACCESS 0
ADD OPTION aRotina Title STR0015 /*Gerar Arq.*/  	Action "F310ImpArq" 			OPERATION 2 ACCESS 0
ADD OPTION aRotina Title STR0016 /*Retorno Arq.*/ 	Action "F310RetArq" 			OPERATION 2 ACCESS 0
ADD OPTION aRotina Title STR0017 /*Efet. Lote*/		Action "F310EftLot"			OPERATION 2 ACCESS 0

Return aRotina

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F310ImpArq
Função para execução da fórmula de geração dos arquivos magnéticos por software de 3os.

@author    Marcos Berto
@version   11.7
@since     18/09/2012

/*/
//------------------------------------------------------------------------------------------
Function F310ImpArq()

Local aLotes		:= {}
Local aParam 		:= {}

Local cBanco 		
Local cAgencia 	
Local cConta		

Local dDataDe
Local dDataAte

Local lOK	

Local nX			:= 0

lOK := Pergunte("FIN310A",.T.)

If lOK
	cBanco 	:= MV_PAR01 		
	cAgencia	:= MV_PAR02 	 	
	cConta		:= MV_PAR03 		
	dDataDe	:= MV_PAR04 	
	dDataAte	:= MV_PAR05 		
	
	//Posiciona no banco configurado para execução da rotina que gera o arquivo
	dbSelectArea("SA6")
	SA6->(dbSetOrder(1))
	If cPaisLoc $ "ARG|RUS"
		If SA6->(dbSeek(xFilial("SA6")+cBanco+cAgencia+cConta))
			If !Empty(SA6->A6_FORMARQ)
				If ExistBlock(SA6->A6_FORMARQ)  
					aParam := {cBanco,cAgencia,cConta,dDataDe,dDataAte}
					aLotes := ExecBlock(SA6->A6_FORMARQ,.F.,.F.,aParam)
				Else
					Alert(STR0018) //Fórmula para geração do arquivo inexistente.
				EndIf
			Else
				Alert(STR0019+" "+STR0020) //Não foi informada uma fórmula para a geração do arquivo. Verifique o cad. do banco
			EndIf
		EndIf
	EndIf
	
	//Os lotes processados serão retornados e terão os status atualizados.
	If Len(aLotes) > 0
		dbSelectArea("FJB")
		FJB->(dbSetOrder(1))
		For nX := 1 to Len(aLotes)
			If FJB->(dbSeek(xFilial("FJB")+cBanco+cAgencia+cConta+aLotes[nX][1]))
				If FJB->FJB_STATUS $ "1|3" //Ativo (Emissao) ou Arquivo Gerado (Reemissao)
					RecLock("FJB",.F.)
					FJB->FJB_STATUS 	:= "3" //Arquivo Gerado
					FJB->FJB_ARQID 	:= aLotes[nX][2]
					FJB->(MsUnlock())
				EndIf
			EndIf
		Next nX
	EndIf
EndIf

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F310RetArq
Função para execução da fórmula de leitura do arquivo de retorno processado por 
software de 3os. 

@author    Marcos Berto
@version   11.7
@since     18/09/2012

/*/
//------------------------------------------------------------------------------------------
Function F310RetArq()

Local aLotes		:= {}
Local aParam 		:= {}

Local cBanco 		
Local cAgencia 	
Local cConta		
Local cArquivo

Local lOK			:= .F.
Local lRetVld		:= .F.

Local nX			:= 0

lOK := Pergunte("FIN310B",.T.)

If lOK
	cBanco 	:= MV_PAR01 		
	cAgencia	:= MV_PAR02 	 	
	cConta		:= MV_PAR03 	
	cArquivo	:= MV_PAR04 		
	
	//Posiciona no banco configurado para execução da rotina que gera o arquivo
	dbSelectArea("SA6")
	SA6->(dbSetOrder(1))
	If cPaisLoc $ "ARG|RUS"
		If SA6->(dbSeek(xFilial("SA6")+cBanco+cAgencia+cConta))
			If !Empty(SA6->A6_FORMRET)
				If ExistBlock(SA6->A6_FORMRET)  
					aParam := {cBanco,cAgencia,cConta,cArquivo}
					aLotes := ExecBlock(SA6->A6_FORMRET,.F.,.F.,aParam)
				Else
					Alert(STR0021) //Fórmula para processamento do arquivo inexistente.
				EndIf
			Else
				Alert(STR0022+" "+STR0021) //Não foi informada uma fórmula para a processamento do arquivo. Verifique o cadastro do banco
			EndIf
		EndIf
	EndIf
	
	//Os lotes processados serão retornados e terão os status atualizados.
	If Len(aLotes) > 0
		dbSelectArea("FJB")
		FJB->(dbSetOrder(1))
		For nX := 1 to Len(aLotes)
			If FJB->(dbSeek(xFilial("FJB")+cBanco+cAgencia+cConta+aLotes[nX]))
				If FJB->FJB_STATUS == "3" //Arquivo Gerado
					//Valida se os pagamentos do lote foram retornados sem erro
					lRetVld := F310VldRet(cBanco,cAgencia,cConta,aLotes[nX])
					
					If lRetVld
						RecLock("FJB",.F.)
						FJB->FJB_STATUS := "4" //Retornado do Banco
						FJB->(MsUnlock())
					Else
						/*	Inativa o lote posicionado por erro do banco
							IMPORTANTE: 	Função para desabilitar o lote --> Man. Lote (FINA242)
											O lote deve estar posicionado - FJB
						*/
						F242DesLot()
					EndIf
				EndIf
			EndIf
		Next nX
	EndIf
EndIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F310RetLeg
Função que retorno da legenda de um detalhe de retorno de arquivo

@author    Marcos Berto
@version   11.7
@since     19/09/2012

@param cStatus	Cod. do Status
@return cDesc	 	Descrição do Status

/*/
//------------------------------------------------------------------------------------------
Function F310RetLeg(cStatus)

Local cDesc := ""

DEFAULT cStatus := ""

Do Case
	Case cStatus == "1" //Retorno do Banco
		cDesc := "BR_VERDE"	
	Case cStatus == "2" //Atualização sistema
		cDesc := "BR_AZUL"	
	Case cStatus == "3" //Erro informado pelo banco
		cDesc := "BR_VERMELHO"	
	Case cStatus == "4" //Erro atualização sistema
		cDesc := "BR_AMARELO"	
EndCase

Return cDesc

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F310EftLot
Função para efetivação de um lote

@author    Marcos Berto
@version   11.7
@since     19/09/2012

@param cBcoLot	Banco do Lote
@param cAgeLot	Agencia do Lote
@param cCtaLot	Conta do Lote
@param cNumLot	Numero do Lote
@param lPergCtb	Exibe a pergunta para contabilização?

/*/
//------------------------------------------------------------------------------------------
Function F310EftLot(cBcoLot,cAgeLot,cCtaLot,cNumLot,lPergCtb)

Local aAreaSA2	:= {}
Local aAreaSE2	:= {}
Local aAreaSEK	:= {}

Local aAux			:= {}
Local aSEF			:= {}
Local aSEK			:= {}
Local aSE2			:= {}
Local aSE5			:= {}
Local aOPs			:= {}
Local aDadosOP	:= {}
Local aValores	:= {}
Local aValExc		:= {}

Local cBenef		:= ""
Local cNumero		:= ""
Local cTpMov		:= ""
Local cOrdPago	:= ""
Local cMsgErro	:= ""

Local dDtVcto		:= dDataBase

Local lProcOK		:= .T.
Local lOk			:= .T.

Local nX			:= 0
Local nPosOP		:= 0
Local nPosPgto	:= 0
Local nPosRec		:= 0
Local nTamRec		:= 0
Local nTxMoeda	:= 0
Local nTaxaMCusto	:= 0
Local nValor		:= 0
Local nValAtTit	:= 0
Local nMoedCusto	:= 0
Local nRecnoFJD	:= 0
Local nRecnoSEK	:= 0

//Contabilização
Local aDiario 	:= {}
Local aOPsProc	:= {}
Local cKeyImp		:= ""
Local cArquivo	:= ""
Local cCodDiario	:= ""
Local cLoteCom	:= ""
Local lLanctOk	:= .F.
Local lGeraLanc	:= .F.
Local lDigita		:= .F. 
Local lAglutina	:= .F.
Local lLancPad70	:= .F.
Local nHdlPrv		:= 0
Local nTotalLanc	:= 0
Local nRECSEKDia	:= 0

Private aFlagCTB		:= {}
Private aFormasPgto 	:= {}
Private lUsaFlag		:= SuperGetMV("MV_CTBFLAG",.T.,.F.)

DEFAULT cBcoLot 	:= ""
DEFAULT cAgeLot 	:= ""
DEFAULT cCtaLot 	:= ""
DEFAULT cNumLot 	:= ""
DEFAULT lPergCtb	:= .T.

lOk := Pergunte("FIN310C",lPergCtb)

lGeraLanc	:= (mv_par01 = 1)
lDigita	:= (mv_par02 = 1)
lAglutina	:= (mv_par03 = 1)

//Caso não seja passado nenhum dos parâmetros, atribui o lote posicionado
If FunName() == "FINA310"
	cBcoLot := FJB->FJB_BANCO
	cAgeLot := FJB->FJB_AGENCI
	cCtaLot := FJB->FJB_CONTA
	cNumLot := FJB->FJB_NUMLOT
EndIf

If lOk .Or. !lPergCtb
	aFormasPgto := Fin025Tipo()
	
	dbSelectArea("FJB")
	FJB->(dbSetOrder(1))
	
	If FJB->(dbSeek(xFilial("FJB")+cBcoLot+cAgeLot+cCtaLot+cNumLot))
	
		//Valida se existem erros no retorno do lote, caso houver
		If FJB->FJB_BCORET == "1" 
			lProcOK := F310VldEft(cBcoLot,cAgeLot,cCtaLot,cNumLot,@aOPs)
		EndIf	
	
		If (FJB->FJB_STATUS == "4" .And. FJB->FJB_BCORET == "1") .Or. (FJB->FJB_STATUS == "1" .And. FJB->FJB_BCORET == "2")
			
			Begin Transaction
			
				If lProcOK
					dbSelectArea("FJC")
					FJC->(dbSetOrder(1))
				
					If FJC->(dbSeek(xFilial("FJC")+cBcoLot+cAgeLot+cCtaLot+cNumLot))
											
						While !FJC->(Eof()) .And. FJC->FJC_FILIAL == xFilial("FJC") .And.;
						 		FJB->FJB_BANCO == FJC->FJC_BANCO .And.;
						 		FJB->FJB_AGENCI == FJC->FJC_AGENCI .And.;
						 		FJB->FJB_CONTA == FJC->FJC_CONTA .And.;
						 		FJB->FJB_NUMLOT == FJC->FJC_NUMLOT  	
							
							
							cOrdPago := FJC->FJC_NUMFIN 
							
							dbSelectArea("SEK")
							SEK->(dbSetOrder(1))
							SEK->(dbGoTop())
							
							If SEK->(dbSeek(xFilial("SEK")+cOrdPago))
								
								While !SEK->(Eof()) .And. SEK->EK_FILIAL == xFilial("SEK") .And. SEK->EK_ORDPAGO == cOrdPago
									
									//TITULOS BAIXADOS PELA OP
									If SEK->EK_TIPODOC == "TB" 
									
										dbSelectArea("SE2")
										aAreaSE2 := SE2->(GetArea()) 
										SE2->(dbSetOrder(1))
										SE2->(dbGoTop())
										
										If SE2->(dbSeek(xFilial("SE2")+SEK->EK_PREFIXO+SEK->EK_NUM+SEK->EK_PARCELA+SEK->EK_TIPO+SEK->EK_FORNECE+SEK->EK_LOJA))
										
											nValAtTit := SEK->EK_VALOR + SEK->EK_DESCONT - Iif(cPaisLoc == "RUS", 0, SEK->EK_MULTA) - SEK->EK_JUROS
											
											//Atualiza dados dos títulos a pagar
											RecLock("SE2",.F.)
											SE2->E2_MOVIMEN 	:= dDataBase
											SE2->E2_SALDO 	-= nValAtTit
											SE2->E2_VALLIQ   	+= nValAtTit
											SE2->E2_ORDPAGO 	:= SEK->EK_ORDPAGO
											SE2->E2_DESCONT 	:= SEK->EK_DESCONT
											If cPaisLoc == "ARG"
												SE2->E2_MULTA	:= SEK->EK_MULTA 
											EndIf
											SE2->E2_JUROS		:= SEK->EK_JUROS
											SE2->E2_BAIXA		:= dDataBase
											SE2->(MsUnlock())
											
											//Atualiza dados do fornecedor
											nMoedCusto 	:= Val(GetMv("MV_MCUSTO"))
											
											If SEK->EK_MOEDA <> "1"
												If (SEK->(FieldPos("EK_TXMOE"+SEK->EK_MOEDA)) > 0 )
													nTxMoeda := SEK->&("EK_TXMOE"+PadL(SEK->EK_MOEDA,2,"0"))
												EndIf
											Else
												nTxMoeda := 1
											Endif	
											
											If GetMv("MV_MCUSTO") <> "1"
												If (SEK->(FieldPos("EK_TXMOE"+SEK->EK_MOEDA)) > 0 )
													nTaxaMCusto := SEK->&("EK_TXMOE"+PadL(GetMv("MV_MCUSTO"),2,"0"))
												EndIf
											Else
												nTaxaMCusto := 1
											Endif	
											
											dbSelectArea("SA2")
											aAreaSA2 := SA2->(GetArea()) 
											SA2->(dbSetOrder(1))
											If SA2->(dbSeek(xFilial("SA2")+SEK->EK_FORNECE+SEK->EK_LOJA))
												cBenef := SA2->A2_NOME
												Reclock("SA2",.F.)
												SA2->A2_SALDUP	:= SA2->A2_SALDUP  - Round(xMoeda(nValAtTit,Val(SEK->EK_MOEDA),1,,5,nTxMoeda),MsDecimais(Val(SEK->EK_MOEDA)))
												SA2->A2_SALDUPM	:= SA2->A2_SALDUPM - Round(xMoeda(nValAtTit,Val(SEK->EK_MOEDA),nMoedCusto,,5,nTxMoeda,nTaxaMCusto),MsDecimais(nMoedCusto))
												MsUnlock()
											Endif
											SA2->(RestArea(aAreaSA2))
																			
											//Gera movimentos de Juros, Multa, Desconto etc.
																			
											//JUROS
											If SEK->EK_JUROS > 0
												aAux := {}
												aAdd(aAux,SEK->EK_PREFIXO)
												aAdd(aAux,SEK->EK_NUM)				
												aAdd(aAux,SEK->EK_PARCELA)
												aAdd(aAux,SEK->EK_TIPO)
												aAdd(aAux,SEK->EK_NATUREZ)				
												aAdd(aAux,SEK->EK_FORNECE)  	
												aAdd(aAux,SEK->EK_LOJA)     			
												aAdd(aAux,cBenef) 					
												aAdd(aAux,SEK->EK_JUROS) 
												aAdd(aAux,SEK->EK_MOEDA)			  				    				
												aAdd(aAux,nTxMoeda)     	  				 				
												aAdd(aAux,dDataBase)    								   								
												aAdd(aAux,"NOR")
												aAdd(aAux,"JR")
												aAdd(aAux,STR0024) //Juros     				     				
												aAdd(aAux,SEK->EK_BANCO)	   				
												aAdd(aAux,SEK->EK_AGENCIA)  				
												aAdd(aAux,SEK->EK_CONTA)
												aAdd(aAux,SEK->EK_ORDPAGO)  
												aAdd(aAux,"")
												aAdd(aAux,SEK->(Recno())) //Reestruturação SE5

												aAdd(aSE5,aAux)
											EndIf  
											
											
											//DESCONTO
											If SEK->EK_DESCONT > 0
												aAux := {}
												aAdd(aAux,SEK->EK_PREFIXO)
												aAdd(aAux,SEK->EK_NUM)				
												aAdd(aAux,SEK->EK_PARCELA)
												aAdd(aAux,SEK->EK_TIPO)
												aAdd(aAux,SEK->EK_NATUREZ)				
												aAdd(aAux,SEK->EK_FORNECE)  	
												aAdd(aAux,SEK->EK_LOJA)     			
												aAdd(aAux,cBenef) 					
												aAdd(aAux,SEK->EK_DESCONT) 
												aAdd(aAux,SEK->EK_MOEDA)			  				    				
												aAdd(aAux,nTxMoeda)     	  				 				
												aAdd(aAux,dDataBase)    								   								
												aAdd(aAux,"NOR")
												aAdd(aAux,"DC")
												aAdd(aAux,STR0025) //Desconto     				     				
												aAdd(aAux,SEK->EK_BANCO)	   				
												aAdd(aAux,SEK->EK_AGENCIA)  				
												aAdd(aAux,SEK->EK_CONTA)
												aAdd(aAux,SEK->EK_ORDPAGO)  
												aAdd(aAux,"")
												aAdd(aAux,SEK->(Recno())) //Reestruturação SE5

												aAdd(aSE5,aAux) 
											EndIf
											
											
											//MULTA
											If cPaisLoc == "ARG"
												If SEK->EK_MULTA > 0
													aAux := {}
													aAdd(aAux,SEK->EK_PREFIXO)
													aAdd(aAux,SEK->EK_NUM)				
													aAdd(aAux,SEK->EK_PARCELA)
													aAdd(aAux,SEK->EK_TIPO)
													aAdd(aAux,SEK->EK_NATUREZ)				
													aAdd(aAux,SEK->EK_FORNECE)  	
													aAdd(aAux,SEK->EK_LOJA)     			
													aAdd(aAux,cBenef) 					
													aAdd(aAux,SEK->EK_MULTA)
													aAdd(aAux,SEK->EK_MOEDA)			  				    				
													aAdd(aAux,nTxMoeda)     	  				 				
													aAdd(aAux,dDataBase)    								   								
													aAdd(aAux,"NOR")
													aAdd(aAux,"MT")
													aAdd(aAux,STR0026) //Multa      				     				
													aAdd(aAux,SEK->EK_BANCO)	   				
													aAdd(aAux,SEK->EK_AGENCIA)  				
													aAdd(aAux,SEK->EK_CONTA)
													aAdd(aAux,SEK->EK_ORDPAGO) 
													aAdd(aAux,"") 
													aAdd(aAux,SEK->(Recno())) //Reestruturação SE5

													aAdd(aSE5,aAux) 
												EndIf
											EndIf
										
											//BAIXA DO TITULO
											aAux := {}
											aAdd(aAux,SEK->EK_PREFIXO)
											aAdd(aAux,SEK->EK_NUM)				
											aAdd(aAux,SEK->EK_PARCELA)
											aAdd(aAux,SEK->EK_TIPO)
											aAdd(aAux,SEK->EK_NATUREZ)				
											aAdd(aAux,SEK->EK_FORNECE)  	
											aAdd(aAux,SEK->EK_LOJA)     			
											aAdd(aAux,cBenef) 					
											aAdd(aAux,SEK->EK_VALOR)
											aAdd(aAux,SEK->EK_MOEDA)			  				    				
											aAdd(aAux,nTxMoeda)     	  				 				
											aAdd(aAux,dDataBase)    								   								
											aAdd(aAux,"NOR")
											aAdd(aAux,"BA")
											aAdd(aAux,STR0027)  //Bx. Tit. por OP    				     				
											aAdd(aAux,SEK->EK_BANCO)	   				
											aAdd(aAux,SEK->EK_AGENCIA)  				
											aAdd(aAux,SEK->EK_CONTA)
											aAdd(aAux,SEK->EK_ORDPAGO) 
											aAdd(aAux,"") 
											aAdd(aAux,SEK->(Recno())) //Reestruturação SE5
										
											aAdd(aSE5,aAux) 
										EndIf
										
										//Atualiza abatimentos
										SE2->(dbSetOrder(6))   
										SE2->(dbGoTop())
										If SE2->(dbSeek(xFilial("SE2")+SEK->EK_FORNECE+SEK->EK_LOJA+SEK->EK_PREFIXO+SEK->EK_NUM+SEK->EK_PARCELA))
											While 	SE2->E2_FILIAL == xFilial("SE2") .And.;
													SE2->E2_FORNECE == SEK->EK_FORNECE .And.;
													SE2->E2_LOJA == SEK->EK_LOJA .And.;
													SE2->E2_PREFIXO == SEK->EK_PREFIXO .And.;
													SE2->E2_NUM == SEK->EK_NUM .And.;
													SE2->E2_PARCELA == SEK->EK_PARCELA
													
												If SE2->E2_TIPO $ MVABATIM
													RecLock("SE2",.F.)
													SE2->E2_SALDO    := 0
													SE2->E2_BAIXA    := dDataBase
													SE2->E2_MOVIMEN  := dDataBase
													SE2->E2_ORDPAGO  := SEK->EK_ORDPAGO
													SE2->(MsUnlock())
												EndIf
												
												SE2->(dbSkip())
												
											EndDo
										EndIf
										
										SE2->(RestArea(aAreaSE2))
										
										//Atualiza o flag de efetivação do movimento da OP
										If cPaisLoc $ "ARG|RUS"
											RecLock("SEK",.F.)
											SEK->EK_EFTVAL := "1"
											SEK->(MsUnlock())
										EndIf
									
									//GERA O TITULO DE ADIANTAMENTO
									ElseIf	SEK->EK_TIPODOC == "PA"
									
										If SEK->EK_MOEDA <> "1"
											If (SEK->(FieldPos("EK_TXMOE"+SEK->EK_MOEDA)) > 0 )
												nTxMoeda := SEK->&("EK_TXMOE"+PadL(SEK->EK_MOEDA,2,"0"))
											EndIf
										Else
											nTxMoeda := 1
										Endif
									
										aAux := {}
										aAdd(aAux,SEK->EK_PREFIXO)		//Prefixo
										aAdd(aAux,SEK->EK_NUM)			//Numero
										aAdd(aAux,SEK->EK_PARCELA)		//Parcela
										aAdd(aAux,SEK->EK_TIPO)			//Tipo
										aAdd(aAux,SEK->EK_FORNECE)		//Fornecedor
										aAdd(aAux,SEK->EK_LOJA)			//Loja
										aAdd(aAux,SEK->EK_NATUREZ)		//Natureza
										aAdd(aAux,SEK->EK_VALOR)			//Valor
										aAdd(aAux,SEK->EK_MOEDA)			//Moeda
										aAdd(aAux,nTxMoeda)				//Taxa Moeda
										aAdd(aAux,SEK->EK_VENCTO)		//Vencimento
										aAdd(aAux,"")						//Dt. Baixa
										aAdd(aAux,nValor)					//Saldo
										aAdd(aAux,SEK->EK_BANCO)			//Banco
										aAdd(aAux,SEK->EK_AGENCIA)		//Agencia
										aAdd(aAux,SEK->EK_CONTA)			//Conta
										aAdd(aAux,SEK->EK_ORDPAGO)		//Ordem de Pago	
						
										aAdd(aSE2,aAux)	
									
									//DOCUMENTOS PROPRIOS GERADOS PELA OP
									ElseIf SEK->EK_TIPODOC == "CP"
										
										//Modo de pago usado - geração dos movimentos conforme configurado
										nPosPgto := Ascan(aFormasPgto,{|x| AllTrim(x[1]) == AllTrim(SEK->EK_MODPAGO)})
										
										If nPosPgto > 0
											cTpMov := 	aFormasPgto[nPosPgto][4] 
										EndIf
																	
										/*---------------------------------------------------------------------
								 			Verifica se possui mais de um retorno do banco referente a 
								 			atualização de registros de um mesmo tipo, para seleção de:
								 			- Numero do documento
								 			- Data de vencimento
									 	  ---------------------------------------------------------------------*/
									 										
									 	nRecnoSEK := SEK->(Recno())
								 		aAreaSEK  := SEK->(GetArea())
									 	
									 	aValores := F310GetVlr(SEK->EK_BANCO,SEK->EK_AGENCIA,SEK->EK_CONTA,SEK->EK_NUMLOT,SEK->EK_ORDPAGO,SEK->EK_TIPO,SEK->EK_VALOR,aValExc)
									 	
									 	If Len(aValores) > 0	
										 	
								 			If Len(aValores) == 1
												nRecnoFJD := aValores[1]	
								 			Else
								 				/*
								 				Caso haja mais de um pagamento com o mesmo tipo e valor,
								 				será exibida uma tela para escolha do movimento correspondente
								 				*/
								 				
								 				aAdd(aDadosOP,SEK->EK_ORDPAGO)
								 				aAdd(aDadosOP,SEK->EK_MODPAGO)
								 				aAdd(aDadosOP,SEK->EK_TIPO)
								 				aAdd(aDadosOP,SEK->EK_NUM)
								 				aAdd(aDadosOP,SEK->EK_TALAO)
								 				
								 				nRecnoFJD := F310SelRet(aValores,aDadosOP)
								 				
								 				//Adiciona o recno no array de controle dos itens já associados
								 				If nRecnoFJD > 0
								 					aAdd(aValExc,nRecnoFJD)
								 				EndIf
								 				
								 			EndIf
								 			
								 			If nRecnoFJD > 0
								 			
									 			dbSelectArea("FJD")
										 		FJD->(dbSetOrder(1))				 		
									 			FJD->(dbGoTo(nRecnoFJD))
									 			cNumero 	:= FJD->FJD_NUMBCO
												dDtVcto 	:= FJD->FJD_DTVCTO
												nValor		:= FJD->FJD_VALOR
												
												//Salva o registro e os valores para atualização posterior
												aAdd(aSEK,{SEK->(Recno()),cNumero,dDtVcto})
												
											Else
												cNumero 	:= SEK->EK_NUM
												dDtVcto 	:= SEK->EK_VENCTO
												nValor		:= SEK->EK_VALOR	
											EndIf
								 			
									 	Else
									 		cNumero 	:= SEK->EK_NUM
											dDtVcto 	:= SEK->EK_VENCTO
											nValor		:= SEK->EK_VALOR	
									 	EndIf
										
										/*--------------------------------------------------------------
								 			Gera as movimentações, dependendo de cada documento
									 	  --------------------------------------------------------------*/
									 	
									 	dbSelectArea("SEK")
									 	SEK->(RestArea(aAreaSEK))
									 	SEK->(dbGoTo(nRecnoSEK))
									 	  
										Do Case
										 //Cheques diferido ou comum
										 Case AllTrim(SEK->EK_TIPO) $ MVCHEQUE
										 	
											If SEK->EK_MOEDA <> "1"
												If (SEK->(FieldPos("EK_TXMOE"+SEK->EK_MOEDA)) > 0 )
													nTxMoeda := SEK->&("EK_TXMOE"+PadL(SEK->EK_MOEDA,2,"0"))
												EndIf
											Else
												nTxMoeda := 1
											Endif
											
										 	aAux := {}
										 	aAdd(aAux,SEK->EK_PREFIXO)
										 	aAdd(aAux,SEK->EK_NUM)
										 	aAdd(aAux,SEK->EK_PARCELA)
										 	aAdd(aAux,SEK->EK_TIPO)
										 	aAdd(aAux,SEK->EK_FORNECE)
										 	aAdd(aAux,SEK->EK_LOJA)
										 	aAdd(aAux,SEK->EK_NATUREZ)
										 	aAdd(aAux,nValor)
										 	aAdd(aAux,SEK->EK_MOEDA)
										 	aAdd(aAux,Iif(nTxMoeda = 0,1,nTxMoeda))
										 	aAdd(aAux,dDtVcto)
										 	aAdd(aAux,nValor)
										 	aAdd(aAux,SEK->EK_BANCO)
										 	aAdd(aAux,SEK->EK_AGENCIA)
										 	aAdd(aAux,SEK->EK_CONTA)
										 	aAdd(aAux,SEK->EK_ORDPAGO)
										 	aAdd(aAux,cNumero)	
										 	aAdd(aAux,SEK->EK_TALAO)
										 	aAdd(aAux,cTpMov)
										 	aAdd(aAux,"")
										 	aAdd(aAux,SEK->(Recno())) //Reestruturação SE5

										 	aAdd(aSEF,aAux)

										 //Transferencias bancárias
										 Case AllTrim(SEK->EK_TIPO) == "TF" .And. cTpMov == "2"
										 	
										 	aAux := {}
											aAdd(aAux,SEK->EK_PREFIXO)				//Prefixo
											aAdd(aAux,cNumero)						//Numero
											aAdd(aAux,SEK->EK_PARCELA)				//Parcela
											aAdd(aAux,SEK->EK_TIPO)					//Tipo
											aAdd(aAux,SEK->EK_NATUREZ)				//Natureza
											aAdd(aAux,SEK->EK_FORNECE)				//Fornecedor
											aAdd(aAux,SEK->EK_LOJA)					//Loja
											dbSelectArea("SA2")
											aAreaSA2 := SA2->(GetArea())
											SA2->(dbSelectArea("SA2"))
											If SA2->(dbSeek(xFilial("SA2")+SEK->EK_FORNECE+SEK->EK_LOJA))
												aAdd(aAux,SA2->A2_NOME)				//Beneficiario	
											Else
												aAdd(aAux,"")							//Beneficiario	
											EndIf	
											aAdd(aAux,nValor)							//Valor
											aAdd(aAux,SEK->EK_MOEDA)					//Moeda
											aAdd(aAux,nTxMoeda)						//Taxa Moeda
											aAdd(aAux,dDtVcto)						//Vencimento
											aAdd(aAux,"NOR")							//Motivo de Baixa
											aAdd(aAux,"VL")							//Tipo Doc.
											aAdd(aAux,STR0028+": "+SEK->EK_ORDPAGO)	//Histórico
											aAdd(aAux,SEK->EK_BANCO)					//Banco
											aAdd(aAux,SEK->EK_AGENCIA)				//Agencia
											aAdd(aAux,SEK->EK_CONTA)					//Conta
											aAdd(aAux,SEK->EK_ORDPAGO)				//Ordem de Pago
											aAdd(aAux,"")								//Talonario
											aAdd(aAux,SEK->(Recno())) //Reestruturação SE5
											
											aAdd(aSE5,aAux)
										 	
										Case AllTrim(SEK->EK_TIPO) == "TF" .And. cTpMov == "1"
										
											aAux := {}
											aAdd(aAux,SEK->EK_PREFIXO)		//Prefixo
											aAdd(aAux,cNumero)				//Numero
											aAdd(aAux,SEK->EK_PARCELA)		//Parcela
											aAdd(aAux,SEK->EK_TIPO)			//Tipo
											aAdd(aAux,SEK->EK_FORNECE)		//Fornecedor
											aAdd(aAux,SEK->EK_LOJA)			//Loja
											aAdd(aAux,SEK->EK_NATUREZ)		//Natureza
											aAdd(aAux,nValor)					//Valor
											aAdd(aAux,SEK->EK_MOEDA)			//Moeda
											aAdd(aAux,nTxMoeda)				//Taxa Moeda
											aAdd(aAux,dDtVcto)				//Vencimento
											If dDataBase == dDtVcto
												aAdd(aAux,dDataBase)			//Dt. Baixa
												aAdd(aAux,0)					//Saldo
											Else
												aAdd(aAux,"")					//Dt. Baixa
												aAdd(aAux,nValor)				//Saldo
											EndIf	
											aAdd(aAux,SEK->EK_BANCO)			//Banco
											aAdd(aAux,SEK->EK_AGENCIA)		//Agencia
											aAdd(aAux,SEK->EK_CONTA)			//Conta
											aAdd(aAux,SEK->EK_ORDPAGO)		//Ordem de Pago	
							
											aAdd(aSE2,aAux)	
											
											//Caso o vencimento seja igual à data da baixa, gera mov. bancário
											If dDataBase == dDtVcto
												aAux := {}
												aAdd(aAux,SEK->EK_PREFIXO)				//Prefixo
												aAdd(aAux,cNumero)						//Numero
												aAdd(aAux,SEK->EK_PARCELA)				//Parcela
												aAdd(aAux,SEK->EK_TIPO)					//Tipo
												aAdd(aAux,SEK->EK_NATUREZ)				//Natureza
												aAdd(aAux,SEK->EK_FORNECE)				//Fornecedor
												aAdd(aAux,SEK->EK_LOJA)					//Loja
												dbSelectArea("SA2")
												aAreaSA2 := SA2->(GetArea())
												SA2->(dbSelectArea("SA2"))
												If SA2->(dbSeek(xFilial("SA2")+SEK->EK_FORNECE+SEK->EK_LOJA))
													aAdd(aAux,SA2->A2_NOME)				//Beneficiario	
												Else
													aAdd(aAux,"")							//Beneficiario	
												EndIf	
												aAdd(aAux,nValor)							//Valor
												aAdd(aAux,SEK->EK_MOEDA)					//Moeda
												aAdd(aAux,nTxMoeda)						//Taxa Moeda
												aAdd(aAux,dDtVcto)						//Vencimento
												aAdd(aAux,"NOR")							//Motivo de Baixa
												aAdd(aAux,"VL")							//Tipo Doc.
												aAdd(aAux,STR0028+": "+SEK->EK_ORDPAGO)	//Histórico
												aAdd(aAux,SEK->EK_BANCO)					//Banco
												aAdd(aAux,SEK->EK_AGENCIA)				//Agencia
												aAdd(aAux,SEK->EK_CONTA)					//Conta
												aAdd(aAux,SEK->EK_ORDPAGO)				//Ordem de Pago
												aAdd(aAux,"")								//Talonario
												aAdd(aAux,SEK->(Recno())) //Reestruturação SE5

												aAdd(aSE5,aAux)	
											EndIf
												
										End Case
																													
									EndIf 
									
									SEK->(dbSkip())
									
								EndDo
									
							EndIf
					
							//Controle de Ordens de Pago para contabilização
							aAdd(aOPsProc,cOrdPago)
							
							aValExc := {}
							FJC->(dbSkip())
				
						EndDo
						
						//Atualiza os cheques e gera os movimentos
						If Len(aSEF) > 0
//							aAdd(aSE5,aSEFb[1])
							MsgRun(STR0048,STR0009,{|| F310GerChq(aSEF)})
						EndIf
						
						//Gera registro de movimentação bancária
						If Len(aSE5) > 0
							MsgRun(STR0048,STR0009,{|| F310GerMov(aSE5)})
						EndIf
						
						//Gera títulos a pagar
						If Len(aSE2) > 0
							MsgRun(STR0048,STR0009,{||F310GeraCP(aSE2)})
						EndIf
						
						//Atualiza a Ordem de Pago
						If Len(aSEK) > 0
							MsgRun(STR0048,STR0009,{||F310AtuOP(aSEK)})
						EndIf
						
						//Efetua a contabilização dos registros
						If lGeraLanc
						
							lLancPad70 := VerPadrao("570")
						
							If lLancPad70
								
								dbSelectArea("SX5")
								dbSeek(xFilial()+"09FIN")
								cLoteCom := IiF(Found(),Trim(X5_DESCRI),"FIN")
								
								nHdlPrv := HeadProva(cLoteCom,"PAGO011",SubStr(cUsuario,7,6),@cArquivo)
								
								If nHdlPrv <= 0
									Help(" ",1,"A100NOPROV")
								EndIf
							
							EndIf
		
							If nHdlPrv > 0 .and. lLancPad70
				
								//+--------------------------------------------------+
								//¦ Gera Lancamento Contab. para Orden de Pago.      ¦
								//+--------------------------------------------------+
								dbSelectArea("SEK")
								SEK->(dbSetOrder(1))
								aAreaSEK := SEK->(GetArea())
								For nX := 1 to Len(aOPsProc)
									SEK->(dbSeek(xFilial("SEK")+aOPsProc[nX]))
									nRECSEKDia := SEK->(Recno())
									dbSelectArea("SA2")
									SA2->(dbsetOrder(1))
									SA2->(dbSeek(xFilial("SA2")+SEK->EK_FORNECE+SEK->EK_LOJA))
									dbSelectArea("SEK")
									While !SEK->(EOF()).And.SEK->EK_ORDPAGO == aOPsProc[nX]
										
										SA6->(DbsetOrder(1))
										SA6->(DbSeek(xFilial("SA6")+SEK->EK_BANCO+SEK->EK_AGENCIA+SEK->EK_CONTA,.F.))
										
										Do Case
											Case ( Alltrim(SEK->EK_TIPO) == Alltrim(GetSESnew("NCP")) )
												cAlias := "SF2"
											Case ( Alltrim(SEK->EK_TIPO) == Alltrim(GetSESnew("NDI")) )
												cAlias := "SF2"
											Otherwise
												cAlias := "SF1"
										EndCase
										
										cKeyImp := xFilial(cAlias)+SEK->EK_NUM	+SEK->EK_PREFIXO+SEK->EK_FORNECE+SEK->EK_LOJA
										
										If ( cAlias == "SF1" )
											cKeyImp += SE1->E1_TIPO
										Endif
										
										If lUsaFlag // Armazena em aFlagCTB para atualizar no modulo Contabil
											aAdd( aFlagCTB, { "EK_LA","S","SEK",SEK->(RecNo()),0,0,0} )
										EndIf
										
										Posicione(cAlias,1,cKeyImp,"F"+SubStr(cAlias,3,1)+"_VALIMP1")
										
										nTotalLanc := nTotalLanc + DetProva( 	nHdlPrv,;
																					"570",;
																					"FINA310" /*cPrograma*/,;
																					cLoteCom,;
																					/*@nLinha*/,;
																					/*lExecuta*/,;
																					/*cCriterio*/,;
																					/*lRateio*/,;
																					/*cChaveBusca*/,;
																					/*aCT5*/,;
																					/*lPosiciona*/,;
																					@aFlagCTB,;
																					/*aTabRecOri*/,;
																					/*aDadosProva*/,;
																					/*Simulacao*/,;
																					"CTK",;
																					"CT2",;
																					"CV3")
										
										SEK->(DbSkip())
									EndDo
								Next nX
								SEK->(RestArea(aAreaSEK))
							
								//+-----------------------------------------------------+
								//¦ Envia para Lancamento Contabil, se gerado arquivo   ¦
								//+-----------------------------------------------------+
								RodaProva(nHdlPrv,nTotalLanc)
								
								//+-----------------------------------------------------+
								//¦ Envia para Lancamento Contabil, se gerado arquivo   ¦
								//+-----------------------------------------------------+
								If UsaSeqCor()
									cCodDiario := CTBAVerDia()
										
									aDiario := {}
									aDiario := {{"SEK",nRECSEKDia,cCodDiario,"EK_NODIA","EK_DIACTB"}}
								EndIf
								
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Envia para Lancamento Contabil                      ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								lLanctOk := cA100Incl( 	cArquivo,;
															nHdlPrv,;
															3 /*nOpcx*/,;
															cLoteCom,;
															lDigita,;
															lAglutina,;
															/*cOnLine*/,;
															/*dData*/,;
															/*dReproc*/,;
															@aFlagCTB,;
															/*aDadosProva*/,;
															aDiario,;
															/*aTpSaldo*/,;
															/*Simulacao*/,;
															"CTK",;
															"CT2",;
															"CTF")
								
								SET KEY VK_F4 to
								SET KEY VK_F5 to
								SET KEY VK_F6 to
								SET KEY VK_F7 to
								
								If lLanctOk .And. !lUsaFlag
									dbSelectArea("SEK")
									SEK->(dbSetOrder(1))
									For nX := 1 to Len(aOPsProc)
										SEK->(dbSeek(xFilial("SEK")+aOPsProc[nX]))
										While !SEK->(Eof()) .And. xFilial("SEK") == SEK->EK_FILIAL .And. aOPsProc[nX] == SEK->EK_ORDPAGO
											RecLock("SEK",.F.)
											Replace SEK->EK_LA With "S"
											SEK->(MsUnLock())
											SEK->(dbSkip())
										Enddo
									Next nX
								EndIf
							EndIf
						
						EndIf
							
						//Atualiza os registros do retorno do banco
						dbSelectArea("FJD")
					 	FJD->(dbSetOrder(1))
						If FJD->(dbSeek(xFilial("FJD")+cBcoLot+cAgeLot+cCtaLot+cNumLot))							 	
					 		While !FJD->(Eof()) .And. FJD->FJD_FILIAL == xFilial("FJD") .And.;
					 		 		FJD->FJD_BANCO == cBcoLot .And.;
					 		 		FJD->FJD_AGENCI == cAgeLot .And.;
					 		 		FJD->FJD_CONTA == cCtaLot .And.;
					 				FJD->FJD_NUMLOT == cNumLot
					 		
					 			Reclock("FJD",.F.)
					 			FJD->FJD_STATUS := "2" //Atualização do sistema
					 			FJD->(MsUnlock())
					 			FJD->(dbSkip())
					 		
					 		EndDo
					 	EndIf 	
								 						 				
						//Atualiza o status do loje
						dbSelectArea("FJB")
						Reclock("FJB",.F.)
						FJB->FJB_STATUS := "6"
						FJB->(MsUnlock())
						
					EndIf
					
				Else
				
					//Atualiza os registros de retorno
					dbSelectArea("FJD")
					FJD->(dbSetOrder(1))
					FJD->(dbGoTop())
					If FJD->(dbSeek(xFilial("FJD")+cBcoLot+cAgeLot+cCtaLot+cNumLot))							 	
						While !FJD->(Eof()) .And. FJD->FJD_FILIAL == xFilial("FJD") .And.;
							 	FJD->FJD_BANCO == cBcoLot .And.;
							 	FJD->FJD_AGENCI == cAgeLot .And.;
							 	FJD->FJD_CONTA == cCtaLot .And.;
				 				FJD->FJD_NUMLOT == cNumLot
				 		
				 			nPosOP := aScan(aOPs,{|x| AllTrim(x) == AllTrim(FJD->FJD_NUMFIN)})
				 		
				 			cMsgErro := Iif(nPosOP > 0,STR0029,STR0030) //Pagamento não encontrados/Erro no Lote X OP
				 		
				 			Reclock("FJD",.F.)
				 			FJD->FJD_STATUS := "4" //Erro na atualização do sistema
				 			FJD->FJD_ERRO := cMsgErro
				 			FJD->(MsUnlock())
				 			FJD->(dbSkip())
				 		
				 		EndDo
			 		EndIf 	
				
					/*	Inativa o lote posicionado por erro do banco
						IMPORTANTE: 	Função para desabilitar o lote --> Man. Lote (FINA242)
										O lote deve estar posicionado - FJB
					*/
					F242DesLot()
				EndIf
			End Transaction
		EndIf
	EndIf
EndIf
	
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F310VldAtu
Função para validação da atualização dos movimentos com o retorno do banco, quando houver

@author    Marcos Berto
@version   11.7
@since     19/09/2012

/*/
//------------------------------------------------------------------------------------------
Function F310VldAtu(cBcoLot,cAgeLot,cCtaLot,cNumLot)

DEFAULT cBcoLot 	:= ""
DEFAULT cAgeLot 	:= ""
DEFAULT cCtaLot 	:= ""
DEFAULT cNumLot 	:= ""

dbSelectArea("FJD")
FJD->(dbSetOrder(1))

If FJD->(dbSeek(xFilial("FJD")+cBcoLot+cAgeLot+cCtaLot+cNumLot))
						 
EndIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F310AtuOP
Atualiza o registro da Ordem de Pago: numeração e vencimento

@author    Marcos Berto
@version   11.7
@since     24/09/2012

@param	aOPs	Dados dos cheques
					[x][1]  = Recno
					[x][2]  = Numero do movimento
					[x][3]  = Data de Vencimento
/*/
//------------------------------------------------------------------------------------------
Function F310AtuOP(aOPs)

Local nX 		:= 0

DEFAULT aOPs 	:= {}

If Len(aOPs) > 0
	dbSelectArea("SEK")
	For nX := 1 to Len(aOPS)
		SEK->(dbGoTo(aOPs[nX][1]))
		RecLock("SEK",.F.)
		SEK->EK_NUM 		:= aOPs[nX][2]
		SEK->EK_VENCTO	:= aOPs[nX][3]
		SEK->(MsUnlock())
	Next nX
EndIf
	
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F310GerChq
Gerencia os registros de cheques:
 - Atualiza numeração;
 - Gera histórico;
 - Gera título;
 - Gera movimentação.

@author    Marcos Berto
@version   11.7
@since     24/09/2012

@param	aCheques	Dados dos cheques
					[x][1]  = Prefixo
					[x][2]  = Numero do Cheque
					[x][3]  = Parcela
					[x][4]  = Tipo
					[x][5]  = Fornecedor
					[x][6]  = Loja
					[x][7]  = Natureza
					[x][8]  = Valor
					[x][9]  = Moeda
					[x][10] = Taxa Moeda
					[x][11] = Vencimento
					[x][12] = Saldo
					[x][13] = Banco
					[x][14] = Agencia
					[x][15] = Conta
					[x][16] = Ordem de Pago
					[x][17] = Num. Banco
					[x][18] = Talonário
					[x][19] = Tipo Movimento (Modo de Pago) --> 1 = Tit. Pagar/2 = Mov. Bancário
/*/
//------------------------------------------------------------------------------------------
Function F310GerChq(aCheques)

Local aAux			:= {}
Local aSE5			:= {}
Local aSE2			:= {}

Local cSeqFRF 	:= ""
Local cBenef		:= ""

Local nX			:= 0

If Len(aCheques) > 0

	dbSelectArea("SEF")
	SEF->(dbSetOrder(1))
	
	For nX := 1 to Len(aCheques)
		
		//Verifica se o registro do cheque será atualizado
		If aCheques[nX][2] <> aCheques[nX][17]
			
			//PREFIXO + BANCO + AGENCIA + CONTA + NUM.CHEQUE
			If SEF->(dbSeek(xFilial("SEF")+aCheques[nX][13]+aCheques[nX][14]+aCheques[nX][15]+aCheques[nX][2]))	
				
				cBenef := SEF->EF_BENEF
				
				RecLock("SEF",.F.)
				SEF->EF_NUM 		:= aCheques[nX][17]
				SEF->EF_VENCTO 	:= aCheques[nX][11]
				SEF->(MsUnlock())
				
				//Atualiza o número dos cheques de todos os registros de histórico
				dbSelectArea("FRF")
				FRF->(dbSetOrder(1))
				If FRF->(dbSeek(xFilial("FRF")+SEF->EF_BANCO+SEF->EF_AGENCIA+SEF->EF_CONTA+SEF->EF_PREFIXO+aCheques[nX][2]))
					While !FRF->(Eof()) .And. FRF->FRF_BANCO == SEF->EF_BANCO .And. FRF->FRF_AGENCI == SEF->EF_AGENCIA .And. FRF->FRF_CONTA == SEF->EF_CONTA .And. FRF->FRF_PREFIX == SEF->EF_PREFIXO .And. FRF->FRF_NUM == aCheques[nX][2]
						RecLock("FRF",.F.)
						FRF->FRF_NUM := aCheques[nX][17]
						FRF->(MsUnlock())
						FRF->(dbSkip())
					EndDo
				EndIf
				
				//Gera um novo registro de histórico do cheque
				cSeqFRF := GetSx8Num("FRF","FRF_SEQ")
				RecLock("FRF",.T.)
				FRF->FRF_FILIAL		:= xFilial("FRF")
				FRF->FRF_BANCO		:= SEF->EF_BANCO
				FRF->FRF_AGENCIA		:= SEF->EF_AGENCIA
				FRF->FRF_CONTA		:= SEF->EF_CONTA
				FRF->FRF_NUM			:= SEF->EF_NUM 
				FRF->FRF_PREFIX		:= SEF->EF_PREFIXO
				FRF->FRF_CART			:= "P"
				FRF->FRF_DATPAG		:= dDataBase
				FRF->FRF_MOTIVO		:= "72"
				FRF->FRF_DESCRI		:= STR0031+" "+aCheques[nX][2]+STR0032+SEF->EF_NUM // Retorno do banco alterou o num.... para 
				FRF->FRF_SEQ			:= cSeqFRF
				FRF->FRF_FORNEC		:= SEF->EF_FORNECE
				FRF->FRF_LOJA			:= SEF->EF_LOJA
				FRF->FRF_NUMDOC		:= SEF->EF_ORDPAGO
				FRF->(MsUnLock())
				ConfirmSX8()
									
			EndIf
		EndIf

		//Gera movimento
		Do Case 
		
			Case aCheques[nX][19] == "1" //Gera tít. a pagar
			
				aAux := {}
				aAdd(aAux,aCheques[nX][1])	//Prefixo
				aAdd(aAux,aCheques[nX][17])	//Numero
				aAdd(aAux,aCheques[nX][3])	//Parcela
				aAdd(aAux,aCheques[nX][4])	//Tipo
				aAdd(aAux,aCheques[nX][5])	//Fornecedor
				aAdd(aAux,aCheques[nX][6])	//Loja
				aAdd(aAux,aCheques[nX][7])	//Natureza
				aAdd(aAux,aCheques[nX][8])	//Valor
				aAdd(aAux,aCheques[nX][9])	//Moeda
				aAdd(aAux,aCheques[nX][10])	//Taxa Moeda
				aAdd(aAux,aCheques[nX][11])	//Vencimento
				aAdd(aAux,"")					//Dt. Baixa
				aAdd(aAux,aCheques[nX][12])	//Saldo					
				aAdd(aAux,aCheques[nX][13])	//Banco
				aAdd(aAux,aCheques[nX][14])	//Agencia
				aAdd(aAux,aCheques[nX][15])	//Conta
				aAdd(aAux,aCheques[nX][16])	//Ordem de Pago	
				
				aAdd(aSE2,aAux)		
				
			Case aCheques[nX][19] == "2" //Gera mov. bancário

				aAux := {}
				aAdd(aAux,aCheques[nX][1])	//Prefixo
				aAdd(aAux,aCheques[nX][17])	//Numero
				aAdd(aAux,aCheques[nX][3])	//Parcela
				aAdd(aAux,aCheques[nX][4])	//Tipo
				aAdd(aAux,aCheques[nX][7])	//Natureza
				aAdd(aAux,aCheques[nX][5])	//Fornecedor
				aAdd(aAux,aCheques[nX][6])	//Loja
				aAdd(aAux,cBenef)				//Beneficiario
				aAdd(aAux,aCheques[nX][8])	//Valor
				aAdd(aAux,aCheques[nX][9])	//Moeda
				aAdd(aAux,aCheques[nX][10])	//Taxa Moeda
				aAdd(aAux,SEK->EK_VENCTO)	//Vencimento
				aAdd(aAux,"DEB")				//Motivo de Baixa
				aAdd(aAux,"VL")				//Tipo Doc.
				aAdd(aAux,STR0033)			//Histórico - debito CC
				aAdd(aAux,aCheques[nX][13])	//Banco
				aAdd(aAux,aCheques[nX][14])	//Agencia
				aAdd(aAux,aCheques[nX][15])	//Conta
				aAdd(aAux,aCheques[nX][16])	//Ordem de Pago
				aAdd(aAux,aCheques[nX][18])	//Talao
				aAdd(aAux,aCheques[nX][21])

				aAdd(aSE5,aAux)
		EndCase
	Next nX

	//Gera os títulos a pagar
	F310GeraCP(aSE2)

	//Gera os movimentos bancários
	F310GerMov(aSE5)

EndIf	

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F310GerMov
Gera movimentação bancária para
	- juros;
	- multa;
	- desconto;
	- cheques.

@author    Marcos Berto
@version   11.7
@since     24/09/2012

@param	aSE5	Dados do movimento					
				[x][1]  = Prefixo
				[x][2]  = Numero 					
				[x][3]  = Parcela 
				[x][4]  = Tipo
				[x][5]  = Natureza 				
				[x][6]  = Fornecedor   	
				[x][7]  = Loja     			
				[x][8]  = Beneficiario					
				[x][9]  = Valor  
				[x][10] = Moeda  			  				    				
				[x][11] = Taxa Moeda     	  				 				
				[x][12] = Data     								   								
				[x][13] = Motivo de Baixa	
				[x][14] = Tipo Doc.
				[x][15] = Historico      				     				
				[x][16] = Banco 	   				
				[x][17] = Agencia  				
				[x][18] = Conta
				[x][19] = Ordem de Pago  
				[x][20] = Talao   							
/*/
//------------------------------------------------------------------------------------------
Function F310GerMov(aSE5)

Local aAreaSX6 	:= {}
Local cSeqBx		:= ""
Local cNumLiq		:= ""
Local nX 			:= 0
Local nSeq			:= 0

//Reestruturação SE5 - Início
Local oModelMov := Nil
Local oSubFKA := Nil
Local oSubFK2 := Nil
Local oSubFK5 := Nil
Local oSubFK6 := Nil
Local cLog := ""
Local cChaveTit := ""
Local cChaveFK7 := ""
Local cCamposE5 := ""
Local cOrdPago := ""
Local lGravaMov := .F.
//Reestruturação SE5 - Fim

Default aSE5 := {}

If Len(aSE5) > 0

	aSort(aSE5,,,{|x,y| x[21] < y[21]}) //Reestruturação SE5

	dbSelectArea("SE5")
	SE5->(dbSetOrder(7))

BEGIN TRANSACTION

	For nX := 1 to Len(aSE5) + 1

//Reestruturação SE5 - Início
		If nX > Len(aSE5)
			lGravaMov := .T.
		Else
			If aSE5[nX][19] <> cOrdPago .And. !Empty(cOrdPago)
				lGravaMov := .T.
			Else
				lGravaMov := .F.
			EndIf
		EndIf

		If lGravaMov
			oModelMov:SetValue("MASTER","E5_CAMPOS",cCamposE5)
			If oModelMov:VldData()
				oModelMov:CommitData()
				oModelMov:DeActivate()
			Else
				cLog := cValToChar(oModelMov:GetErrorMessage()[4]) + ' - '
				cLog += cValToChar(oModelMov:GetErrorMessage()[5]) + ' - '
				cLog += cValToChar(oModelMov:GetErrorMessage()[6])
				Help(,,"M030F310GERMov",,cLog, 1, 0 )
				DisarmTransaction()
			Endif
		EndIf

		If nX > Len(aSE5)
			nX++
			Loop
		ElseIf lGravaMov .Or. Empty(cOrdPago)
				oModelMov := Nil
				oSubFKA := Nil
				oSubFK2 := Nil
				oSubFK5 := Nil
				oSubFK6 := Nil
				cCamposE5 := ""
				oModelMov := FWLoadModel("FINM020")
				oModelMov:SetOperation(MODEL_OPERATION_INSERT)
				oModelMov:Activate()
				oModelMov:SetValue("MASTER","NOVOPROC",.T.)
				oModelMov:SetValue("MASTER","E5_GRV",.T.)
				oSubFKA := oModelMov:GetModel("FKADETAIL")
				oSubFK2 := oModelMov:GetModel("FK2DETAIL")
				oSubFK5 := oModelMov:GetModel("FK5DETAIL")
				oSubFK6 := oModelMov:GetModel("FK6DETAIL")
		EndIf

		cChaveTit := xFilial("SE2") + "|" +  aSE5[nX][1] + "|" + aSE5[nX][2] + "|" + aSE5[nX][3] + "|" + ;
			aSE5[nX][4] + "|" + aSE5[nX][6] + "|" + aSE5[nX][7]

		If !Empty(cCamposE5)
			cCamposE5 += "|"
		EndIf

		cCamposE5 += "{"		
		cCamposE5 += "{'E5_DTDIGIT',STOD('" + DTOS(dDataBase) + "')}"
		cCamposE5 += ",{'E5_PREFIXO'	,'" + aSE5[nX][1] + "'}"
		cCamposE5 += ",{'E5_NUMERO','" + aSE5[nX][2] + "'}"
		cCamposE5 += ",{'E5_PARCELA'	,'" + aSE5[nX][3] + "'}"
		cCamposE5 += ",{'E5_TIPO','" + aSE5[nX][4] + "'}"
		cCamposE5 += ",{'E5_CLIFOR','" + aSE5[nX][6] + "'}"
		cCamposE5 += ",{'E5_LOJA','" + aSE5[nX][7] + "'}"
		cCamposE5 += ",{'E5_BENEF','" + aSE5[nX][8] + "'}"
		cCamposE5 += ",{'E5_DOCUMEN','" + aSE5[nX][19] + "'}"
		cCamposE5 += ",{'E5_NUMLIQ','" + cNumLiq + "'}"
		cCamposE5 += ",{'E5_TALAO','" + aSE5[nX][20] + "'}"
		cCamposE5 += "}"
//Reestruturação SE5 - Fim

		//Procura a próxima sequência de baixa
		While .T.
			nSeq++
			If !SE5->(dbSeek(xFilial("SE5")+aSE5[nX][1]+aSE5[nX][2]+aSE5[nX][3]+aSE5[nX][4]+aSE5[nX][6]+aSE5[nX][7]+StrZero(nSeq,TamSX3("E5_SEQ")[1])))
				Exit
			EndIf
			SE5->(dbSkip())
		Enddo

		cSeqBx := StrZero(nSeq,TamSX3("E5_SEQ")[1])
		cNumLiq := Soma1(GetMv("MV_NUMLIQ"),6)

//Reestruturação SE5 - Início
		If aSE5[nX][14] $ "BA|VL"

			If !oSubFKA:IsEmpty()
				oSubFKA:AddLine()
				oSubFKA:GoLine(oSubFKA:Length())
			EndIf
			oSubFKA:SetValue("FKA_IDORIG",FWUUIDV4())
			oSubFKA:SetValue("FKA_TABORI","FK2")

			If !oSubFK2:IsEmpty()
				oSubFK2:AddLine()
				oSubFK2:GoLine(oSubFK2:Length())
			EndIf

			If aSE5[nX][14] == "BA"
				cChaveFK7	:= FINGRVFK7("SE2",cChaveTit)
			EndIf

			oSubFK2:SetValue("FK2_IDDOC",cChaveFK7)
			oSubFK2:SetValue("FK2_ORIGEM",FunName())
			oSubFK2:SetValue("FK2_DATA",dDataBase)
			oSubFK2:SetValue("FK2_VALOR",aSE5[nX][9])
			oSubFK2:SetValue("FK2_VLMOE2",Round(xMoeda(aSE5[nX][9],Val(aSE5[nX][10]),1,,5,aSE5[nX][11]),5))
			oSubFK2:SetValue("FK2_MOEDA",PadL(aSE5[nX][10],TamSX3("E5_MOEDA")[1],"0"))
			oSubFK2:SetValue("FK2_NATURE",aSE5[nX][5])
			oSubFK2:SetValue("FK2_RECPAG","P")
			oSubFK2:SetValue("FK2_TPDOC",aSE5[nX][14])
			oSubFK2:SetValue("FK2_HISTOR",aSE5[nX][15])
			oSubFK2:SetValue("FK2_MOTBX",aSE5[nX][13])
			oSubFK2:SetValue("FK2_SEQ",cSeqBx)
			oSubFK2:SetValue("FK2_ORDREC",Substr(aSE5[nX][19],7,6))
			oSubFK2:SetValue("FK2_DOC",aSE5[nX][19])
			oSubFK2:SetValue("FK2_VENCTO",aSE5[nX][12])
			oSubFK2:SetValue("FK2_TXMOED",aSE5[nX][11])
			If !lUsaFlag
				oSubFK2:SetValue("FK2_LA","S")
			EndIf

			If aSE5[nX][14] == "VL"

				If !oSubFKA:IsEmpty()
					oSubFKA:AddLine()
					oSubFKA:GoLine(oSubFKA:Length())
				EndIf
				oSubFKA:SetValue("FKA_IDORIG",FWUUIDV4())
				oSubFKA:SetValue("FKA_TABORI","FK5")

				If !oSubFK5:IsEmpty()
					oSubFK5:AddLine()
					oSubFK5:GoLine(oSubFK5:Length())
				EndIf
				oSubFK5:SetValue("FK5_ORIGEM",FunName())
				oSubFK5:SetValue("FK5_DATA",dDataBase)
				oSubFK5:SetValue("FK5_VALOR",aSE5[nX][9])
				oSubFK5:SetValue("FK5_VLMOE2",Round(xMoeda(aSE5[nX][9],Val(aSE5[nX][10]),1,,5,aSE5[nX][11]),5))		
				oSubFK5:SetValue("FK5_RECPAG","P")
				oSubFK5:SetValue("FK5_BANCO",aSE5[nX][16])
				oSubFK5:SetValue("FK5_AGENCI",aSE5[nX][17])
				oSubFK5:SetValue("FK5_CONTA",aSE5[nX][18])
				oSubFK5:SetValue("FK5_DTDISP",aSE5[nX][12])
				oSubFK5:SetValue("FK5_HISTOR",aSE5[nX][15])
				oSubFK5:SetValue("FK5_MOEDA",PadL(aSE5[nX][10],TamSX3("E5_MOEDA")[1],"0"))
				oSubFK5:SetValue("FK5_NATURE",aSE5[nX][5])
				oSubFK5:SetValue("FK5_TPDOC",aSE5[nX][14])
				oSubFK5:SetValue("FK5_SEQ",cSeqBx)
				oSubFK5:SetValue("FK5_DOC",aSE5[nX][19])
				oSubFK5:SetValue("FK5_TXMOED",aSE5[nX][11])
				If aSE5[nX][4] $ MVCHEQUE
					oSubFK5:SetValue("FK5_NUMCH",aSE5[nX][2])
				EndIf
				If !lUsaFlag
					oSubFK5:SetValue("FK5_LA","S")
				EndIf
//				AtuSalBco(aSE5[nX][16],aSE5[nX][17],aSE5[nX][18],dDataBase,aSE5[nX][9],"-")
				If (cPaisLoc == "RUS")
					AtuSalBco(aSE5[nX][16],aSE5[nX][17],aSE5[nX][18],dDataBase,aSE5[nX][9],"-")
				Endif
			EndIf
		EndIf

		If aSE5[nX][14]$ "MT|JR|DC"

			If !oSubFK6:IsEmpty()
				oSubFK6:AddLine()
				oSubFK6:GoLine(oSubFK6:Length())
			EndIf
			oSubFK6:SetValue("FK6_IDDOC",cChaveFK7)
			oSubFK6:SetValue("FK6_ORIGEM",FunName())
			oSubFK6:SetValue("FK6_DATA",dDataBase)
			oSubFK6:SetValue("FK6_VALOR",aSE5[nX][9])
			oSubFK6:SetValue("FK6_VLMOE2",Round(xMoeda(aSE5[nX][9],Val(aSE5[nX][10]),1,,5,aSE5[nX][11]),5))
			oSubFK6:SetValue("FK6_MOEDA",PadL(aSE5[nX][10],TamSX3("E5_MOEDA")[1],"0"))
			oSubFK6:SetValue("FK6_NATURE",aSE5[nX][5])
			oSubFK6:SetValue("FK6_RECPAG","P")
			oSubFK6:SetValue("FK6_TPDOC",aSE5[nX][14])
			oSubFK6:SetValue("FK6_HISTOR",aSE5[nX][15])
			oSubFK6:SetValue("FK6_MOTBX",aSE5[nX][13])
			oSubFK6:SetValue("FK6_SEQ",cSeqBx)
			oSubFK6:SetValue("FK6_ORDREC",Substr(aSE5[nX][19],7,6))
			oSubFK6:SetValue("FK6_DOC",RTrim(aSE5[nX][19]))
			oSubFK6:SetValue("FK6_VENCTO",aSE5[nX][12])
			oSubFK6:SetValue("FK6_TXMOED",aSE5[nX][11])
			If !lUsaFlag
				oSubFK6:SetValue("FK6_LA","S")
			EndIf
		EndIf
//Reestruturação SE5 - Fim

//		If lUsaFlag //Armazena em aFlagCTB para atualizar no modulo Contabil
//			aAdd(aFlagCTB,{"E2_LA","S","SE2",SE2->(RecNo()),0,0,0})
//		EndIf

		//Atualiza saldo bancário
//		FKCommit()
//		AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DATA,SE5->E5_VALOR,"-")	

		//Atualiza a numeração de liquidação
		aAreaSX6:=GetArea()
		dbSelectArea("SX6")
		dbSetOrder(1)
		If dbSeek(xFilial("SX6")+"MV_NUMLIQ")
			RecLock("SX6",.F.)
			Replace X6_CONTEUD With cNumLiq
			Replace X6_CONTSPA With cNumLiq
			Replace X6_CONTENG With cNumLiq
			MsUnlock()
		EndIf
		RestArea(aAreaSX6)

	nSeq := 0 //Reestruturação SE5

	Next nX

END TRANSACTION

EndIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F310GeraCP
Gera registro no Contas a Pargar para:
	- cheques;
	- juros;
	- multas;
	- descontos

@author    Marcos Berto
@version   11.7
@since     24/09/2012

@param	aSE2	Dados do titulo
				[x][1]  = Prefixo
				[x][2]  = Numero
				[x][3]  = Parcela
				[x][4]  = Tipo
				[x][5]  = Fornecedor
				[x][6]  = Loja
				[x][7]  = Natureza
				[x][8]  = Valor
				[x][9]  = Moeda
				[x][10] = Taxa Moeda
				[x][11] = Vencimento
				[x][12] = Dt. Baixa
				[x][13] = Saldo
				[x][14] = Banco
				[x][15] = Agencia
				[x][16] = Conta
				[x][17] = Ordem de Pago
/*/
//------------------------------------------------------------------------------------------
Function F310GeraCP(aSE2)

Local aAreaSA2	:= {}
Local nX			:= 0

DEFAULT aSE2 		:= {}


If Len(aSE2) > 0

dbSelectArea("SE2")
SE2->(dbSetOrder(1))
	For nX := 1 to Len(aSE2) 
	
		If !SE2->(dbSeek(xFilial("SE2")+aSE2[nX][1]+aSE2[nX][2]+aSE2[nX][3]+aSE2[nX][4]+aSE2[nX][5]+aSE2[nX][6]))	
		
			RecLock("SE2",.T.)
			SE2->E2_FILIAL		:= xFilial("SE2")
			SE2->E2_PREFIXO		:= aSE2[nX][1]
			SE2->E2_NUM			:= aSE2[nX][2]
			SE2->E2_PARCELA		:= aSE2[nX][3]
			SE2->E2_TIPO			:= aSE2[nX][4]
			SE2->E2_FORNECE		:= aSE2[nX][5]
			SE2->E2_LOJA			:= aSE2[nX][6]
			dbSelectArea("SA2")
			aAreaSA2 := SA2->(GetArea())
			SA2->(dbSelectArea("SA2"))
			If SA2->(dbSeek(xFilial("SA2")+aSE2[nX][5]+aSE2[nX][6]))
				SE2->E2_NOMFOR 	:= SA2->A2_NOME		
			EndIf	
			RestArea(aAreaSA2)		
			SE2->E2_NATUREZ		:= aSE2[nX][7]
			SE2->E2_VALOR			:= aSE2[nX][8]
			SE2->E2_MOEDA			:= Val(aSE2[nX][9])
			SE2->E2_TXMOEDA		:= aSE2[nX][10]
			SE2->E2_SALDO			:= aSE2[nX][13]
			SE2->E2_VLCRUZ		:= Round(xMoeda(aSE2[nX][8],1,Val(aSE2[nX][9]),,5,aSE2[nX][10]),5)
			SE2->E2_EMIS1			:= dDataBase
			SE2->E2_EMISSAO		:= dDataBase
			SE2->E2_VENCTO		:= aSE2[nX][11]
			SE2->E2_VENCORI		:= aSE2[nX][11]
			SE2->E2_VENCREA		:= DataValida(aSE2[nX][11],.T.)
			If !Empty(aSE2[nX][12]) .And. aSE2[nX][13] = 0
				SE2->E2_VALLIQ 	:= aSE2[nX][8]
				SE2->E2_BAIXA		:= aSE2[nX][12]
				SE2->E2_MOVIMEN	:= aSE2[nX][12]
				SE2->E2_BCOPAG	:= aSE2[nX][14]
			EndIf 
			SE2->E2_ORDPAGO		:= aSE2[nX][17]
			SE2->E2_PORTADO		:= aSE2[nX][14]
			SE2->E2_BCOCHQ		:= aSE2[nX][14]
			SE2->E2_AGECHQ		:= aSE2[nX][15]
			SE2->E2_CTACHQ		:= aSE2[nX][16]
			SE2->E2_SITUACA		:= "0"
			SE2->E2_ORIGEM		:= FunName()
			If !lUsaFlag
				SE2->E2_LA       	 	:= "S"
			EndIf
					
			SE2->(MsUnlock())
		
			If lUsaFlag // Armazena em aFlagCTB para atualizar no modulo Contabil
				aAdd( aFlagCTB, { "E2_LA","S","SE2",SE2->(RecNo()),0,0,0} )
			EndIf
		
		EndIf
		
	Next nX

EndIf

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F310VldRet
Função para validação de erros no retorno do banco

@author    Marcos Berto
@version   11.7
@since     19/09/2012

@param cBanco		Banco
@param cAgencia	Agencia
@param cConta		Conta
@param cLote		Cod. do Lote
@return lRet	 	Validação do retorno do banco

/*/
//------------------------------------------------------------------------------------------

Function F310VldRet(cBanco,cAgencia,cConta,cLote)

Local lRet 		:= .T.

DEFAULT cBanco 	:= ""
DEFAULT cAgencia	:= "" 
DEFAULT cConta 	:= ""
DEFAULT cLote		:= ""

FJD->(dbSetOrder(1))
If FJD->(dbSeek(xFilial("FJD")+cBanco+cAgencia+cConta+cLote))
	While 	!FJD->(Eof()) .And. FJD->FJD_FILIAL == xFilial("FJD") .And.;
			 FJD->FJD_BANCO == cBanco .And. FJD->FJD_AGENCI == cAgencia .And.;
			 FJD->FJD_CONTA == cConta .And. FJD->FJD_NUMLOT == cLote 
			 
		If FJD->FJD_STATUS == "3" //Erro retornado do Banco
			lRet := .F.
			Exit	
		EndIf
		FJD->(dbSkip())	
	EndDo
EndIf

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F310VldEft
Função para validação Retorno Banco X Ordens de Pago X Lote

@author    Marcos Berto
@version   11.7
@since     19/09/2012

@param cBanco		Banco
@param cAgencia	Agencia
@param cConta		Conta
@param cLote		Cod. do Lote
@param aOPs		Ordens de Pago com erro

@return lRet	 	Validação OP X Ret. Banco

/*/
//------------------------------------------------------------------------------------------
Function F310VldEft(cBanco,cAgencia,cConta,cLote,aOPs)

Local aTipo		:= {}
Local aDados		:= {}
Local aAreaFJD 	:= {}
Local aAreaFJC	:= {}
Local aRetBco		:= {}
Local aCfgOP		:= {} 
Local aItensLot	:= {} 
Local nX			:= 0
Local nY 			:= 0
Local nZ 			:= 0
Local nPosTipo 	:= 0
Local nPosOP 		:= 0
Local nPosVal 	:= 0
Local lRet 		:= .T.

DEFAULT cBanco 	:= ""
DEFAULT cAgencia	:= "" 
DEFAULT cConta 	:= ""
DEFAULT cLote		:= ""
DEFAULT aOPs		:= {}


/*
 ----------------------------------------------------
| RETORNO BANCO											|
| Montagem do array com os dados do retorno do  		|
| banco para comparação.									|
 ----------------------------------------------------
*/
dbSelectArea("FJD")
aAreaFJD := FJD->(GetArea())
FJD->(dbSetOrder(1))
If FJD->(dbSeek(xFilial("FJD")+cBanco+cAgencia+cConta+cLote))
	While 	!FJD->(Eof()) .And. FJD->FJD_FILIAL == xFilial("FJD") .And.;
			 FJD->FJD_BANCO == cBanco .And. FJD->FJD_AGENCI == cAgencia .And.;
			 FJD->FJD_CONTA == cConta .And. FJD->FJD_NUMLOT == cLote  
		
		//Não efetua a efetivação caso não houver retorno do banco
		If FJD->FJD_STATUS <> "1" //Retorno do Banco
			lRet := .F.
			Exit
		Else
			
			//Verifica os pagamentos existentes no retorno
			nPosOP := aScan(aRetBco,{|x| AllTrim(x[1]) == AllTrim(FJD->FJD_NUMFIN)})
			
			/*
			[x][1] = Ordem de Pago
			[x][2]
			[x][2][y][1] = Tipo (CH, TH etc)
			[x][2][y][2] = Quantidade
			[x][2][y][3] 
			[x][2][y][3][z][1] = Valor
			[x][2][y][3][z][2] = Moeda
			[x][2][y][3][z][3] = Marcado (T/F) --> usado na comparação com a OP
			*/
			
			If nPosOP > 0
				nPosTipo := aScan(aRetBco[nPosOP][2],{|x| AllTrim(x[1]) == AllTrim(FJD->FJD_TIPO)})
				
				If nPosTipo > 0
					aRetBco[nPosOP][2][nPosTipo][2]++
					aAdd(aRetBco[nPosOP][2][nPosTipo][3],{FJD->FJD_VALOR,FJD->FJD_MOEDA,.F.})
				Else
					aDados := {}
					aAdd(aDados,{FJD->FJD_VALOR,FJD->FJD_MOEDA,.F.})
					aAdd(aRetBco[nPosOP][2],{FJD->FJD_TIPO,1,aDados})	
				EndIf	
			Else
				aTipo 	:= {}
				aDados := {}
				aAdd(aDados,{FJD->FJD_VALOR,FJD->FJD_MOEDA,.F.})
				aAdd(aTipo,{FJD->FJD_TIPO,1,aDados})
				
				aAdd(aRetBco,{FJD->FJD_NUMFIN,aTipo})			
			EndIf
			
		EndIf
		FJD->(dbSkip())
	EndDo
Else
	lRet := .F.	
EndIf

/*
 ----------------------------------------------------
| RETORNO BANCO X LOTE									|
| Valida se todos as OPs do lote foram retornados	|
 ----------------------------------------------------
*/
If lRet
	dbSelectArea("FJC")
	aAreaFJC := FJC->(GetArea())
	FJC->(dbSetOrder(1))
	If FJC->(dbSeek(xFilial("FJC")+cBanco+cAgencia+cConta+cLote))
		While 	!FJC->(Eof()) .And. FJC->FJC_FILIAL == xFilial("FJC") .And.;
				 FJC->FJC_BANCO == cBanco .And. FJC->FJC_AGENCI == cAgencia .And.;
				 FJC->FJC_CONTA == cConta .And. FJC->FJC_NUMLOT == cLote
		
			nPosOP := aScan(aRetBco,{|x| AllTrim(x[1]) == AllTrim(FJC->FJC_NUMFIN)})
			
			If nPosOP == 0
				lRet := .F.
				Exit	
			EndIf
			
			FJC->(dbSkip())
			
		EndDo			
	EndIf
EndIf

/*
 --------------------------------------------------------------
| RETORNO BANCO X ORDEM DE PAGO										|
| Verifica os pagamentos configurados em cada Ordem de Pago 	|
 --------------------------------------------------------------
*/
If lRet
	dbSelectArea("SEK")
	SEK->(dbSetOrder(1))
	For nX := 1 to Len(aRetBco)
		If SEK->(dbSeek(xFilial("SEK")+aRetBco[nX][1]+"CP"))
		
			While 	SEK->EK_FILIAL == xFilial("SEK") .And.;
					SEK->EK_ORDPAGO == aRetBco[nX][1] .And.;
					SEK->EK_TIPODOC == "CP"
			
				nPosOP := aScan(aCfgOP,{|x| AllTrim(x[1]) == AllTrim(SEK->EK_ORDPAGO)})
				
				/*
				[x][1] = Ordem de Pago
				[x][2]
				[x][2][y][1] = Tipo (CH, TH etc)
				[x][2][y][2] = Quantidade
				*/
				
				If nPosOP > 0
					nPosTipo := aScan(aCfgOP[nPosOP][2],{|x| AllTrim(x[1]) == AllTrim(SEK->EK_TIPO)})
					
					If nPosTipo > 0
						aCfgOP[nPosOP][2][nPosTipo][2]++
						aAdd(aCfgOP[nPosOP][2][nPosTipo][3],{SEK->EK_VALOR,SEK->EK_MOEDA})
					Else
						aDados := {}
						aAdd(aDados,{SEK->EK_VALOR,SEK->EK_MOEDA})
						aAdd(aCfgOP[nPosOP][2],{SEK->EK_TIPO,1,aDados})	
					EndIf	
				Else
					aTipo 	:= {}
					aDados := {}
					aAdd(aDados,{SEK->EK_VALOR,SEK->EK_MOEDA})
					aAdd(aTipo,{SEK->EK_TIPO,1,aDados})
					aAdd(aCfgOP,{SEK->EK_ORDPAGO,aTipo})			
				EndIf
				
				SEK->(dbSkip())
			
			EndDo
		EndIf	
	Next nX
	
	//Ordem de Pago X Retono do Banco
	For nX := 1 to Len(aRetBco)
		nPosOP := aScan(aCfgOP,{|x| AllTrim(x[1]) == AllTrim(aRetBco[nX][1])})
		
		If nPosOP > 0
		
			If Len(aRetBco[nX][2]) == Len(aCfgOP[nPosOP][2])
				For nY := 1 to Len(aRetBco[nX][2])
					nPosTipo := aScan(aCfgOP[nPosOP][2],{|x| AllTrim(x[1]) == AllTrim(aRetBco[nX][2][nY][1])})
				
					If nPosTipo > 0
						If aCfgOP[nPosOP][2][nPosTipo][2] <> aRetBco[nX][2][nY][2]
							aAdd(aOPs,aRetBco[nX][1])
							lRet := .F.
							Exit
						Else //Compara valores dos pagamentos
							For nZ := 1 to Len(aCfgOP[nPosOP][2][nPosTipo][3])
								nPosVal := aScan(aRetBco[nX][2][nY][3],{|x| 	x[1] == aCfgOP[nPosOP][2][nPosTipo][3][nZ][1] .And.;
									 												x[2] == aCfgOP[nPosOP][2][nPosTipo][3][nZ][2] .And. !x[3]})
								
								If nPosVal > 0
									aRetBco[nPosOP][2][nPosTipo][3][nPosVal][3] := .T.
								Else //Não localizou um valor correspondente na Ordem de Pago
									lRet := .F.
									Exit	
								EndIf
							Next nZ
						EndIf
					Else //Não localizou o tipo retornado na Ordem de Pago
						lRet := .F.
						Exit	
					EndIf	
				Next nY
			Else //Não possui os mesmos tipos (Configurado X Retornado)
				lRet := .F.
				Exit	
			EndIf	
		Else //Não localizou a Ordem de Pago
			lRet := .F.
			Exit
		EndIf
		
	Next nX
	
EndIf

RestArea(aAreaFJD)

Return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F310GetVlr
Função para comparação de valores OP X Retorno do Lote, para compor seleção, em caso de 
valores identicos.

@author    Marcos Berto
@version   11.7
@since     11/10/2012

@param cBcoLot	Banco do Lote	
@param cAgeLot	Agencia do Lote
@param cCtaLot	Conta do Lote
@param cNumLot	Numero do Lote
@param cNumOP		Ordem de Pago	
@param cTpVal		Tipo (CH, TF etc)
@param nValCp		Valor de comparação

@return aValores	Recnos dos valores encontrados

/*/
//------------------------------------------------------------------------------------------
Function F310GetVlr(cBcoLot,cAgeLot,cCtaLot,cNumLot,cNumOP,cTpVal,nValCp,aRecExc)

Local aAreaFJD	:= {}
Local aValores	:= {}

Local nPosRec		:= 0

DEFAULT cBcoLot	:= ""
DEFAULT cAgeLot	:= ""
DEFAULT cCtaLot	:= ""
DEFAULT cNumLot	:= ""
DEFAULT cNumOP	:= ""
DEFAULT cTpVal	:= ""
DEFAULT nValCp	:= 0
DEFAULT aRecExc	:= {}

dbSelectArea("FJD")
aAreaFJD := FJD->(GetArea())
FJD->(dbSetOrder(1))
If FJD->(dbSeek(xFilial("FJD")+cBcoLot+cAgeLot+cCtaLot+cNumLot+cNumOP))							 	
 	While !FJD->(Eof()) .And. FJD->FJD_FILIAL == xFilial("FJD") .And.;
 		 	FJD->FJD_BANCO ==  cBcoLot .And.;
 		 	FJD->FJD_AGENCI == cAgeLot .And.;
 		 	FJD->FJD_CONTA == cCtaLot .And.;
 			FJD->FJD_NUMLOT == cNumLot .And.;
 			FJD->FJD_NUMFIN == cNumOP
 			
		If AllTrim(FJD->FJD_TIPO) == AllTrim(cTpVal) .And. FJD->FJD_VALOR = nValCp
		
			nPosRec := aScan(aRecExc,{|x| x = FJD->(Recno()) })

			//Somente os Recnos não associados
			If nPosRec = 0
	 			aAdd(aValores,FJD->(Recno())) 
	 		EndIf
	 					
 		EndIf 	
 		FJD->(dbSkip())
	EndDo 			
EndIf 
FJD->(RestArea(aAreaFJD))

Return aValores


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F310SelRet
Função para montagem da tela de seleção dos  

@author    Marcos Berto
@version   11.7
@since     11/10/2012

@param aRecnos	Recnos dos valores
@param aRecExc	Recnos dos valores já associados
@param aDadosOP	Dados do Pagamento da Ordem de Pago

@return nRecSel	Recno Selecionado

/*/
//------------------------------------------------------------------------------------------
Function F310SelRet(aRecnos,aDadosOP)

Local aAreaFJD := {}

Local bOk
Local bCancel
Local bInitBr

Local cMsgOP	:= ""

Local nX		:= 0
Local nRecSel	:= 0

Local oOk
Local oNOk
Local oDlgRet
Local oPnlMsg
Local oPnlRet
Local oSayMsg
Local oSayOP
Local oFontOP

Private aRetBco	:= {}
Private oBrwSelRet

DEFAULT aRecnos 	:= {}
DEFAULT aDadosOP 	:= {}

//Monta array com os recnos informados
dbSelectArea("FJD")
aAreaFJD := FJD->(GetArea())
For nX := 1 to Len(aRecnos)
	FJD->(dbGoTo(aRecnos[nX]))
	aAdd(aRetBco,{.F.,FJD->FJD_NUMBCO,FJD->FJD_TIPO,FJD->FJD_VALOR,FJD->FJD_MOEDA,FJD->FJD_DTVCTO,aRecnos[nX]})
Next nX

If Len(aRetBco) > 0 .And. Len(aDadosOP) > 0
		
	//Define os objetos para montagem da seleção no browse
	oOk  := LoadBitmap(GetResources(),"wfchk")
	oNOk := LoadBitmap(GetResources(),"wfunchk")

	oDlgRet := MsDialog():New( 0,0,400,700,STR0034,,,,,,,,,.T.) //Seleção de Mov.
	
	//Painel da Mensagem
	oPnlMsg := TPanel():New(0,0,"",oDlgRet,,,,,,oDlgRet:nWidth,45,,)
	oPnlMsg:Align := CONTROL_ALIGN_TOP
	
	oSayMsg := TSay():New(01,01,{|| STR0037+" "+STR0038	},oPnlMsg) // "Foram encontradas mais de uma ocorrência para o pagamento abaixo. Selecione o retorno para geração do movimento:"
	
	//Monta a mensagem com os dados da OP
	If aDadosOP[3] $ MVCHEQUE
		cMsgOP := STR0039+aDadosOP[1]+" / "+aDadosOP[4]+" - "+aDadosOP[3]+" - "+STR0040+aDadosOP[5]+" ("+STR0041+aDadosOP[2]+")" //OP/Pgto - Talonário - Modo de Pago
	Else
		cMsgOP := STR0039+aDadosOP[1]+" / "+aDadosOP[4]+" - "+aDadosOP[3]+" ("+STR0041+aDadosOP[2]+")" //OP/Pgto - Modo de Pago
	EndIf
	
	oFontOP := TFont():New()
	oFontOP:Bold := .T.
	oSayOP  := TSay():New(02,01,{|| cMsgOP },oPnlMsg,,oFontOP)

	oBrwSelRet := TCBrowse():New(0,0,400,400,,,,oDlgRet,,,,,{|| F310MrkRet() },,,,,,,,/*Alias*/,.T.,,,,.T.,)
	oBrwSelRet:AddColumn(TcColumn():New("",{|| Iif(aRetBco[oBrwSelRet:nAt][1],oOK,oNOK)},,,,,010,.T.,.F.,,,,,))
	oBrwSelRet:AddColumn(TcColumn():New(RetTitle("FJD_NUMBCO")	,{|| aRetBco[oBrwSelRet:nAt][2]}	,PesqPict("FJD","FJD_NUMBCO")	,,,,TamSX3("FJD_NUMBCO")[1]	,.F.,.F.,,,,,))
	oBrwSelRet:AddColumn(TcColumn():New(RetTitle("FJD_TIPO")	,{|| aRetBco[oBrwSelRet:nAt][3]}	,PesqPict("FJD","FJD_TIPO")		,,,,TamSX3("FJD_TIPO")[1]	,.F.,.F.,,,,,))
	oBrwSelRet:AddColumn(TcColumn():New(RetTitle("FJD_VALOR")	,{|| aRetBco[oBrwSelRet:nAt][4]}	,PesqPict("FJD","FJD_VALOR")	,,,,TamSX3("FJD_VALOR")[1]	,.F.,.F.,,,,,))
	oBrwSelRet:AddColumn(TcColumn():New(RetTitle("FJD_MOEDA")	,{|| aRetBco[oBrwSelRet:nAt][5]}	,PesqPict("FJD","FJD_MOEDA")	,,,,TamSX3("FJD_MOEDA")[1]	,.F.,.F.,,,,,))
	oBrwSelRet:AddColumn(TcColumn():New(RetTitle("FJD_DTVCTO")	,{|| aRetBco[oBrwSelRet:nAt][6]}	,PesqPict("FJD","FJD_DTVCTO")	,,,,TamSX3("FJD_DTVCTO")[1]	,.F.,.F.,,,,,))
	oBrwSelRet:SetArray(aRetBco)
	oBrwSelRet:Align := CONTROL_ALIGN_ALLCLIENT

	//Bloco a ser executado na confirmação da seleção de Lotes
	bOk := {|| GetKeys() , SetKey( VK_F3 , Nil ), nRecSel := F310GetMrk(), If(F310VldChk(),oDlgRet:End(),.F.)}
	
	//Bloco a ser executado ao cancelar a seleção de Lotes
	bCancel := {|| GetKeys() , SetKey( VK_F3 , Nil ), nRecSel := F310GetMrk(), If(F310VldChk(),oDlgRet:End(),.F.)}
	
	//Bloco para montagem da Enchoice da tela de seleção de Lotes
	bInitBr := { || EnchoiceBar( oDlgRet , bOk , bCancel , Nil  )}
	oDlgRet:bInit := bInitBr
	
	oDlgRet:Activate(,,,.T.)
	
EndIf

FJD->(RestArea(aAreaFJD))

Return nRecSel

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F310MrkRet
Função que efetua marcação de um retorno para associação

@author    Marcos Berto
@version   11.7
@since     11/10/2012
/*/
//------------------------------------------------------------------------------------------
Function F310MrkRet()

Local nX := 0

If Type("oBrwSelRet") <> "U" .And. Type("aRetBco") <> "U"
	For nX := 1 to Len(aRetBco)
		If oBrwSelRet:nAt = nX
			aRetBco[nX][1] := .T.
		Else
			aRetBco[nX][1] := .F.
		EndIf
	Next nX
	
	oBrwSelRet:Refresh()
	
EndIf

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F310GetMrk
Recupera o registro que foi marcado na tela de seleção

@author   	Marcos Berto
@version  	11.7
@since    	11/10/2012

@return nRecno	Recno do registro marcado

/*/
//------------------------------------------------------------------------------------------
Function F310GetMrk()

Local nX 		:= 0
Local nRecno 	:= 0

If Type("aRetBco") <> "U"
	For nX := 1 to Len(aRetBco)
		If aRetBco[nX][1]
			nRecno := aRetBco[nX][7]
			Exit
		EndIf
	Next nX
EndIf

Return nRecno

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F310VldChk
Valida se houve seleção do movimento para associação

@author   	Marcos Berto
@version  	11.7
@since    	11/10/2012

@return lRet	Validação da Seleção

/*/
//------------------------------------------------------------------------------------------
Function F310VldChk()

Local lRet	:= .F.
Local nX 	:= 0

If Type("aRetBco") <> "U"
	For nX := 1 to Len(aRetBco)
		If aRetBco[nX][1]
			lRet := .T.
			Exit
		EndIf
	Next nX
EndIf

If !lRet
	Alert(STR0042)//"É necessário selecionar um registro para efetuar a associação dos pagamentos."
EndIf

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F310VldChk
Legenda específica do detalhe

@author   	Marcos Berto
@version  	11.7
@since    	11/10/2012


/*/
//------------------------------------------------------------------------------------------

Function F310LegRet()

Local aLegenda := {}

aAdd(aLegenda,{"BR_VERDE" 		, STR0044})  //"Retorno do Banco"
aAdd(aLegenda,{"BR_AZUL" 		, STR0045 }) //"Atualização sistema"
aAdd(aLegenda,{"BR_VERMELHO" 	, STR0046 }) //"Erro informado pelo banco" 
aAdd(aLegenda,{"BR_AMARELO" 	, STR0047 }) //"Erro na atualização do sistema"

BrwLegenda(STR0043, STR0009, aLegenda) //Legenda - Gerec. Arq. Banco

Return
