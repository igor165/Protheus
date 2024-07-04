#INCLUDE "tbiconn.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLM460CUS
Ponto Entrada gera producao automatica gasolina C
Adaptação da função M460CUST do template DCL
@author jose.eulaiio
@param aCusto
@return M460CUST
@since 08/02/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function DCLM460CUS(aCusto)

Local aArea		:= GetArea()
Local aAreaSD3 	:= SD3->(GetArea())
Local aAreaDH5 	:= DH5->(GetArea())
Local aAreaDH3 	:= DH3->(GetArea())
Local TMD      	:= ""
Local cLaudo		:= Space(TamSX3("DH3_LAUDO")[1])
Local cNumOp		:= ""  
Local lDCEPROAUT	:= .T. 
Local lRet			:= .T.
Local cRET20G		:= 'N'

Default aCusto	:= {}

Private lMsErroAuto :=.F.

//Grava complemento da Nota de Saída DCL
Dclm460DH3()
	
	// Para produtos com estoque zero antecipar entrada do estoque.
	IF SB1->(DbSeek(xFilial('SB1')+SD2->D2_COD))
		DbSelectArea("DH5")
		DH5->(DbSetOrder(1))
		If DH5->(DbSeek(xFilial("DH5") + SB1->B1_COD))
			If DH5->DH5_PREQUI == "S"
				//SG1->(DBORDERNICKNAME("DCLSG1_01"))//G1_FILIAL+G1_COD+DTOS(G1_FIM)+G1_TRT
				SG1->(DbSetOrder(5))//G1_FILIAL+G1_COD+DTOS(G1_FIM)+G1_TRT
				SG1->(DbSeek(xFilial() + SD2->D2_COD + DTOS(SD2->D2_EMISSAO),.T.))
				dFim := SG1->G1_FIM
				WHILE SD2->D2_COD == SG1->G1_COD .AND. ! SG1->(EOF()) .AND. dFim == SG1->G1_FIM
					IF ALLTRIM(SG1->G1_COMP) $ SUPERGETMV('MV_ESTZERO',.F.,'  ') .AND. SF4->F4_ESTOQUE == 'S'
						A2460GrEst(SG1->G1_COMP,(SD2->D2_QUANT * SG1->G1_QUANT) )
					ENDIF
					SG1->(DBSKIP())
				ENDDO
			ELSE
				IF ALLTRIM(SD2->D2_COD) $ SUPERGETMV('MV_ESTZERO',.F.,'  ') .AND. SF4->F4_ESTOQUE == 'S'
					A2460GrEst(SD2->D2_COD,SD2->D2_QUANT)
				ENDIF
			ENDIF
		EndIf
	ENDIF
	
	//Por padrao o o RET20G = Nao, caso esteja no parametro e o pedido seja sim. Somente neste caso o RET20G é sim.
IF !EMPTY(SD2->D2_CF) .AND. ALLTRIM(SD2->D2_CF) $ SuperGetMV('MV_DCLCFOR',.F.,"") .And. SC5->C5_RET20G == 'S'
		cRET20G := 'S'  	  
	Endif
	
	DH3->(DbSetOrder(1)) //DH3_FILIAL+DH3_DOCD2+DH3_SERIE+DH3_CLIENT+DH3_LOJA+DH3_ITEM
If DH3->(DbSeek(xFilial("DH3") + SD2->(D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_ITEM))) 
		RecLock("DH3",.F.)
	If GetMv('MV_LAUDONF')
		cLaudo := LaudoSIMP()
		DH3->DH3_LAUDO	:= cLaudo
	EndIf
		DH3->DH3_RET20G := cRET20G
		MsUnLock()
	EndIf

	//Gravar o Codigo do Tes Inteligente utilizado  
	If SC6->(FieldPos('C6_X_REGRA')) > 0
		DbSelectArea("DH3")
		RecLock("DH3",.F.)
		DH3->DH3_REGRA	:= SC6->C6_X_REGRA
		mSUnlock()
	EndIf


	IF AllTrim(GetMV("MV_REQAUTO")) == "S" .AND. SF4->F4_ESTOQUE == 'S'
		DH5->(DbSetOrder(1)) //DH5_FILIAL+DH5_COD+DH5_CODSIM
		If DH5->(DbSeek(xFilial("DH5") + SB1->B1_COD))
			If DH5->DH5_PREQUI == "S"
				SB1->(DBSEEK(XFILIAL("SB1")+SD2->D2_COD))
				SF5->(DbSetOrder(2)) //F5_FILIAL+F5_MOVTANQ+F5_TIPO
				IF SF5->(DbSeek(xFilial("SF5")+"GC"+"P"))
					TMD := SF5->F5_CODIGO
				ENDIF
				SF5->(dbSetOrder(1))
				IF EMPTY(TMD)
					Aviso("Atencao!","Nao existe Tipo de movimento (GC) no SF5 para producao de gasolina !! Producao automatica nao realizada",{"Ok"},2)
				ELSE         
					If ExistBlock("DCEPROAUT")
						lDCEPROAUT := ExecBlock("DCEPROAUT",.F.,.F.)
						If Valtype(lDCEPROAUT) == "L"
							lRet := lDCEPROAUT
						Endif
					EndIf                  
					If lRet
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Calcula o numero da OP  								     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cNumOp:= GetNumSC2()
						RecLock("SD2",.F.)
						SD2->D2_OP     := cNumOp
						MsUnlock()
			
				        _nModulo := nModulo 
				        nModulo  := 4 
						lMsErroAuto:=.F.
						aVetor:={{"C2_ITEM",SD2->D2_ITEM,NIL},;
						{"C2_NUM",cNumOp,NIL},;
						{"C2_PRODUTO",SD2->D2_COD,NIL},;
						{"C2_QUANT",SD2->D2_QUANT,NIL},;
						{"C2_LOCAL",SD2->D2_LOCAL,NIL},;
						{"AUTEXPLODE","S",NIL},;
						{"C2_DATPRI",SD2->D2_EMISSAO,NIL},;
						{"C2_DATPRF",SD2->D2_EMISSAO,NIL}}
			
						MSExecAuto({|x,y| mata650(x,y)},aVetor,3) //Inclusao da ordem de Producao + Empenho
						If lMsErroAuto
							MOSTRAERRO()
							lRet := .F.
						Endif
			
						If lRet
							lMsErroAuto:=.F.
							aVetor:={	{"D3_TM"		,TMD								,NIL},;
										{"D3_UM"		,SD2->D2_UM						,NIL},;
										{"D3_OP"		,cNumOp + SD2->D2_ITEM + "001"	,NIL},;
										{"D3_COD"		,SD2->D2_COD						,NIL},;
										{"D3_QUANT"	,SD2->D2_QUANT					,NIL},;
										{"D3_LOCAL"	,SD2->D2_LOCAL					,NIL},;
										{"D3_EMISSAO"	,SD2->D2_EMISSAO					,NIL},;
										{"D3_NFORP"	,SD2->D2_DOC						,NIL},;
										{"D3_TPMOVAJ"	,"GC"								,NIL}}
				
							MSExecAuto({|x,y| mata250(x,y)},aVetor,3) //Inclusao da Producao
							If lMsErroAuto
								MOSTRAERRO()
								lRet := .F.
							Else
								aCusto := RetPrdCus(cNumOp+SD2->D2_ITEM+"001")
							Endif
						EndIf
				
						nModulo := _nModulo 
					EndIf
				ENDIF
			EndIf
		EndIf
EndIf

RestArea(aAreaSD3)
RestArea(aAreaDH5)
RestArea(aAreaDH3)
RestArea(aArea)

Return aCusto

//-----------------------------------------------------------
/*/{Protheus.doc} RetPrdCus
Retorna o custo da produção realizada
@author robson.ribeiro
@since 13/04/2016
@version 1.0
@param cChave, character, (Chave para pesquisa da produção)
@return ${return}, ${Custo da Produção}
/*/
//-----------------------------------------------------------
Static Function RetPrdCus(cChave)

Local aAreaSD3		:= SD3->(GetArea())
Local aCusto		:= {0,0,0,0,0}

SD3->(dbSetOrder(1))

If SD3->(MsSeek(xFilial("SD3")+cChave,.T.))
	While Alltrim(SD3->D3_OP) == cChave
		If SD3->D3_CF == "PR0"
			aCusto := {}
			Aadd(aCusto , SD3->D3_CUSTO1 / SD3->D3_QUANT)
			Aadd(aCusto , SD3->D3_CUSTO2 / SD3->D3_QUANT)
			Aadd(aCusto , SD3->D3_CUSTO3 / SD3->D3_QUANT)
			Aadd(aCusto , SD3->D3_CUSTO4 / SD3->D3_QUANT)
			Aadd(aCusto , SD3->D3_CUSTO5 / SD3->D3_QUANT)
		EndIf
		SD3->(dbSkip())
	EndDo
EndIf

RestArea(aAreaSD3)

Return aCusto

//-----------------------------------------------------------
/*/{Protheus.doc} SelecLaudo
Tela para seleção de Laudo de Qualidade
@author Itamar Oliveira
@since 01/09/2005
@version 1.0
@return {nOpc, cLaudo}
/*/
//-----------------------------------------------------------
Static Function SelecLaudo()

Local oDlg
Local oBtnOK
Local oSay
Local oBOLD
Local oFont
Local oLaudo
Local cLaudo	:= Space(TamSX3("DH3_LAUDO")[1])
Local cMens	:= ""
Local nOpc		:= 0

cMens := "É obrigatório informar o Laudo de Qualidade para posterior geração "
cMens += "do arquivo SIMP para a ANP. Caso não preencha o Laudo neste "
cMens += "momento, será necessário informá-lo através da rotina 'Qualidade NF Saida'. " 

DEFINE MSDIALOG oDlg TITLE "Laudo de Qualidade" From 00,00 To 125,350 PIXEL

DEFINE FONT oBOLD Name "ARIAL" SIZE 0, -10 BOLD
DEFINE FONT oFont Name "ARIAL" SIZE 0, -12 BOLD
@003,003 To 060,173 Of oDlg PIXEL

@007,005 Say cMens Size 168,050 Of oDlg PIXEL FONT oBOLD COLOR CLR_HBLUE

@041,005 Say oSay PROMPT "Laudo: " Of oDlg PIXEL FONT oFont COLOR CLR_HBLUE
@040,030 MSGet oLaudo VAR cLaudo F3('LHW') Valid VldLaudo(cLaudo) Of oDlg PIXEL 
	
@039,135 BUTTON oBtnOK PROMPT "Continuar" SIZE 30,15 ACTION (nOpc:=1, oDlg:End()) OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTER
	
Return {nOpc, cLaudo}

//-----------------------------------------------------------
/*/{Protheus.doc} LaudoSimp
Tela para seleção de Laudo de Qualidade
@author Itamar Oliveira
@since 01/09/2005
@version 1.0
@return aOpc[2]
/*/
//-----------------------------------------------------------
Static Function LaudoSIMP()
Local aOpc		:= {}
Local lLoop	:= .T.
Local lResp	:= .F.

Do While lLoop
	aOpc = SelecLaudo()
	If aOpc[1] == 1 .And. AllTrim(aOpc[2]) == ""
		lResp := MsgYesNo('O número do Laudo de Qualidade não foi informado. Continua assim mesmo?')
		If lResp
	        lLoop := .F.   
		EndIf    
	Else
		lLoop := .F.   
	EndIf
EndDo
	
Return AllTrim(aOpc[2])

//-----------------------------------------------------------
/*/{Protheus.doc} VldLaudo
Tela para seleção de Laudo de Qualidade
@author Itamar Oliveira
@since 01/09/2005
@version 1.0
@return lRet
/*/
//-----------------------------------------------------------
Static Function VldLaudo(cLaudo)
Local lRet			:= .T.
Local aAreaDHE	:= DHE->(GetArea())

Default cLaudo := ""

If AllTrim(cLaudo) != ""
	DbSelectArea('DHE')
	DbSetOrder(1)
	If !(DbSeek(xFilial("DHE") + cLaudo))
		MsgInfo('Número do laudo incorreto!')
		lRet := .F.
	EndIf
EndIf
	
RestArea(aAreaDHE)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} A2460GrEst
Gera movimento provisório quando o parâmetro MV_ESTZERO está ativo e TES que atualiza estoque
@return   Nil

@author   José Eulálio
@since    23.04.2014
@version  P11
/*/
//-------------------------------------------------------------------
Static Function A2460GrEst(cProdZer,nQuant)

Local cTm			:= SuperGetMv('MV_TMPRV',,'')
Local aAreaSB1	:= SB1->(GetArea())
Local aVetor		:= {}

	//CRIA MOVIMENTO INTERNO COM VALOR DO PEDIDO
	aADD(aVetor,{"D3_FILIAL"		,xFilial("SD3")	,NIL})
	aADD(aVetor,{"D3_TM" 		,cTm  				,NIL})
	aADD(aVetor,{"D3_UM"	  		,SD2->D2_UM		,NIL})
	aADD(aVetor,{"D3_COD"		,cProdZer			,NIL})
	aADD(aVetor,{"D3_DOC"		,SD2->D2_DOC		,NIL})
	aADD(aVetor,{"D3_QUANT"		,nQuant			,NIL})
	aADD(aVetor,{"D3_LOCAL"  	,SD2->D2_LOCAL	,NIL})
	aADD(aVetor,{"D3_EMISSAO"	,SD2->D2_EMISSAO	,NIL})
	aADD(aVetor,{"D3_TPMOVAJ"	,"PR"				,NIL})
	aADD(aVetor,{"D3_CHAVEF2"	,SF2->(F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE)+SD2->D2_ITEM,NIL})

	
	lMsErroAuto := .F.
	MSExecAuto({|x,y| mata240(x,y)},aVetor,3) //Inclusao de Internos
	
	If lMsErroAuto
		MostraErro()
	EndIf

SB1->(RestArea(aAreaSB1))

Return !lMsErroAuto

//-------------------------------------------------------------------
/*/{Protheus.doc} Dclm460DH3
Grava Itens Documento de Saida DCL
@return   Nil

@author   José Eulálio
@since    13/04/2017
@version  P12
/*/
//-------------------------------------------------------------------
Static Function Dclm460DH3()

RecLock("DH3",.T.)
	DH3->DH3_FILIAL	:= SD2->D2_FILIAL
	DH3->DH3_DOCD2	:= SD2->D2_DOC
	DH3->DH3_SERIE	:= SD2->D2_SERIE
	DH3->DH3_CLIENT	:= SD2->D2_CLIENTE
	DH3->DH3_LOJA		:= SD2->D2_LOJA
	DH3->DH3_ITEM		:= SD2->D2_ITEM
MsUnlock()

Return


