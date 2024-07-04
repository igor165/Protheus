#INCLUDE "ATFA155.ch"
#INCLUDE "PROTHEUS.CH"


Static _lAtualizou := .F.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFA155   บAutor  ณJair Ribeiro        บ Data ณ  07/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ampliacao do bem com ou sem aumento de vida util           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAATF                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ATFA155()
Local lCpoSup	:= .T.
Local lIndice9	:= .T.
Local cIndice9	:= "SN49"
Local aASX3		:= SX3->(GetArea())
Local aASIX		:= SIX->(GetArea())

Private cCadastro 	:= STR0001 //"Ampliacao"
Private aRotina		:= MenuDef()

SetKey(  VK_F12, { || pergunte("AFA012",.T.) } )

SX3->(DbSetOrder(2))
lCpoSup	:= (SX3->(DbSeek('N1_BASESUP')) .and. SX3->(DbSeek('N1_ITEMSUP')))

SIX->(DbSetOrder(1))
lIndice9:= SIX->(DbSeek(cIndice9))

If lIndice9
	lIndice9 := (ALLTRIM(SIX->CHAVE) == "N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+N4_SEQREAV+N4_SEQ+DTOS(N4_DATA)+N4_OCORR")
EndIf

If !lCpoSup .or. !lIndice9
	Help(" ",1,"ATFNOKER",,STR0002,1,0) //"Modulo SIGAATF desatualizado, por favor atualizar com o ultimo update"
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se o modulo do ativo esta atualizadoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ATFXKERNEL()
	mBrowse(6,1,22,75,"SN1",,"N1_BAIXA",22,,, AtfLegenda("SN1"))
EndIf
SX3->(RestArea(aASX3))
SIX->(RestArea(aASIX))
SET KEY VK_F12 TO
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA155Ampl	บAutor  ณJair Ribeiro        บ Data ณ  07/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de configuracao da ampliacao                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cAlias: Alias selecionado no browse                        บฑฑ
ฑฑบ          ณ nRecno: Recno posicionado                                  บฑฑ
ฑฑบ          ณ nOpc: Opcao selecionada no browse                          บฑฑ
ฑฑบ          ณ 		3 - Ampliacao | 4 - Estorno                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAATF                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA155Ampl(cAlias,nRecno,nOpc)
Local aDimensao	:= FWGetDialogSize(oMainWnd)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVariaveis de objeto 								   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local oDlg		:= Nil
Local oPanelM	:= Nil
Local oGroupI	:= Nil
Local oGroupJ	:= Nil
Local oGroupL	:= Nil
Local oPanelI	:= Nil
Local oPanelI2	:= Nil
Local oPanelJ	:= Nil
Local oPanelL	:= Nil
Local oSayJ1	:= Nil
Local oSayJ2	:= Nil
Local oSayJ3	:= Nil
Local oSayJ4	:= Nil
Local oSayJ5	:= Nil
Local oSayJ6	:= Nil
Local oComboJ1	:= Nil
Local oComboJ2	:= Nil
Local oComboJ3	:= Nil
Local oGetJ1	:= Nil
Local oGetJ2	:= Nil
Local oGetJ3	:= Nil
Local oGetDdL	:= Nil
Local oGetDdI	:= Nil

Local aComboJ1	:= {"1="+STR0004,"2="+STR0005,"3="+STR0036}//"Mesmo Bem (Tipo 11)"###"Novo Bem (Incorporacao)" //"Novo Item"###"Nova Incorporacao" ###"Mesmo Item (Tipo 01)"
Local aComboJ2	:= {"1="+STR0006,"2="+STR0007} 				//"Vinculada"###"Propria"
Local aComboJ3	:= {"1="+STR0008,"2="+STR0009,"3="+STR0010}//"Vida Util"###"Valor"###"Ambos"
Local cMetodo	:= "3"
Local cTipoVida	:= ""
Local cAcao		:= ""
Local cIndice	:= ""
Local cIdMov	:= ""
Local cVAtual	:= ""
Local cQtdMov	:= ""
Local nVidaUtil	:= 0
Local nTxDepr	:= 0
Local nRecnoDel	:= 0
Local nTxAnDepr	:= 0
Local nI		:= 0
Local nVidaAtual:= 0
Local lMultMoed := .T.
Local nMoedas	:= If(lMultMoed,AtfMoedas(),5)
Local nQtdMov	:= AF155MOVIM(xFilial("SN3"),SN1->N1_CBASE,SN1->N1_ITEM,"01","06","3")

Local aHeaderI	:= {}
Local aColsI	:= {}
Local aColsJ	:= {}
Local aCamposGD	:= {}
Local aCpoEnc	:= {"N3_CBASE","N3_ITEM","N3_TIPO","N3_TIPDEPR","N3_TPSALDO","N3_HISTOR"}
Local aCpoGet	:= {}

Local bFieldok		:= {|| AF155SetVl(oGetDdL)}
Local bUpdate	:= {|| IiF(Eval(bTudoOk),(Eval(bGrava),oDlg:End()),.F.)}
Local bTudoOk	:= {|lRet| lRet := If(nOpc == 3 , AF155TDOK(oGetDdL,lCalcMes,nVidaAtual,cMetodo,cTipoVida,cAcao,nVidaUtil),.T.)}
Local bGrava	:= {|| AF155GRV	(oGetDdL,nOpc,nTxAnDepr,lCalcMes,cMetodo,cTipoVida,cAcao,nVidaUtil,nRecnoDel)}
Local bEndWin	:= {|| oDlg:End()}
Local bValidM	:= {|| If (cMetodo == "3" .and. cAcao != "1",(Help(" ",1,"AFA155METODO",,STR0039,1,0),.F.),.T.)} //"Metodo Valido apenas para Acao = VidaUtil"

Local dDataBloq := GetNewPar("MV_ATFBLQM",CTOD(""))
Local dUltDepr 	:= SuperGetMv("MV_ULTDEPR")
Local lCalcMes	:= (ALLTRIM(SuperGetMv("MV_CALCDEP",,"1")) == "0")	//Verifica a formula de calculo de depreciacao
Local cTipoMA	:= IiF(lCalcMes,STR0011,STR0012) 				//"(Meses)"###"(Anos)"
Local cIndBem	:= xFilial("SN3")+SN1->(N1_CBASE+N1_ITEM)+"01"
Local lContinua	:= .T.
Local oModel	:= ModelDef()  //carregando modelo para quando for validar x3_valid pelo campo N3_CCUSTO ao passar para o ATFA012

Private bRetGet		:= {|nVal| AF155RetGet(oGetDdL,nVal)}

//Ativando Model ATFA012
oModel:Activate(.T.) 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Validacoes para verificar se pode aplicar uma ampliacao/estorno no bem 		ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Posiciona no Cadastro de Bens 					   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SN3->(DbSetOrder(1))
If !SN3->(DbSeek(xFilial("SN3")+SN1->N1_CBASE+SN1->N1_ITEM+"01"))
	Help(" ",1,"AF150NaoLo")
	lContinua := .F.
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Estorno						  					   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lContinua .and. nOpc == 4
	SN3->(DbSetOrder(1))
	If !SN3->(DbSeek(xFilial("SN3")+SN1->N1_CBASE+SN1->N1_ITEM+"110"))
		Help(" ",1,"ATFNOAMPL",,STR0013,1,0) 						//"Bem posicionado nao possui ampliacoes que possam ser estornadas"
		lContinua := .F.
	Else
		cIndice	:= SN3->(N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA)
		While SN3->(!EOF()) .and. SN3->(N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA) == cIndice
	 		nRecnoDel:= SN3->(Recno())
	 		SN3->(DbSkip())
		EndDo
		SN3->(DbGoTo(nRecnoDel))

		If SN3->N3_CRIDEPR == "03"		//Exercicio completo
			lContinua := .F.
			Help( " ", 1, "AF155AMMOV",,STR0014,1,0) //"Nใo ้ possํvel estornar a amplia็ใo, pois a mesma possui calendแrio de exercํcio completo!"
		EndIf

		If lContinua
			nTxDepr:= SN3->N3_TXDEPR1
			SN4->(DbSetOrder(9))			//N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+N4_SEQREAV+N4_SEQ+DTOS(N4_DATA)+N4_OCORR
			If SN4->(DbSeek(xFilial("SN4")+SN3->(N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQREAV+N3_SEQ)+DTOS(SN3->N3_AQUISIC)))
				cIdMov := SN4->N4_IDMOV

				While SN4->(!EOF()) .and. (SN4->(N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+N4_SEQREAV) == xFilial("SN4")+SN3->(N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQREAV)) .and. (SN4->N4_DATA >= SN3->N3_AQUISIC)
					If Alltrim(SN4->N4_IDMOV) > Alltrim(cIdMov)
						lContinua := .F.
						Help( " ", 1, "AF155AMMOV",,STR0015,1,0) //"Nใo ้ possํvel estornar a amplia็ใo, pois a mesma possui movimenta็oes"
						Exit
					EndIf
					SN4->(DbSkip())
				EndDo
			EndIf
		EndIf
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se bem nao esta bloqueado                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lContinua .and. Val(SN3->N3_BAIXA) > 0
	Help(" ",1,"AF155BAIXA",,STR0016,1,0) //"Este bem foi baixado, nao pode sofrer ampliacao."
	lContinua := .F.
Endif

If lContinua .and. !Empty(SN1->N1_DTBLOQ)
	Help(" ",1,"AF155BLOQ",,STR0017,1,0) //"Este bem esta bloqueado, nao pode sofrer ampliacao."
	lContinua := .F.
EndIf

If lContinua
	If SN1->N1_STATUS == "2"
		Help(" ",1,"AF155BLOQ",,STR0017,1,0) //"Este bem esta bloqueado, nao pode sofrer ampliacao."
   		lContinua := .F.
	EndIf
EndIf

If lContinua .And. ATFXVerPrj(SN1->N1_CBASE,SN1->N1_ITEM, .T. )
	lContinua := .F.
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se a data  v lida                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lContinua .and. !Empty(dDataBase) .and. (dDataBase < dDataBloq)
	Help(" ",1,"AF155BLQM",,STR0018 + DTOC(dDataBloq) ,1,0) //"A data de aquisi็ใo do bem ้ menor que a data de bloqueio de movimenta็ใo : "
	lContinua := .F.
End If

//Validacao para o bloqueio do processo
If lContinua .And. !CtbValiDt(,dDataBase ,,,,{"ATF001"},)
	lContinua := .F.
EndIf

If lContinua .and. dDataBase <= dUltDepr .or. (dDataBase > (LastDAy(dUltDepr+1)))
	If GetMv("MV_TIPDEPR") <> "2"
		Help(" ",1,"AF155DEPREC",,STR0019+DTOC(dUltDepr),1,0) //"A Database do sistema deve ter o m๊s igual ao m๊s do parโmetro MV_ULTDEPR = "
		lContinua := .F.
	ElseIf dDataBase < (FirstDay(dUltDepr))
		Help(" ",1,"AF155DEPREC",,STR0019+DTOC(dUltDepr),1,0) //"A Database do sistema deve ter o m๊s igual ao m๊s do parโmetro MV_ULTDEPR = "
		lContinua := .F.
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Posiciona no resgistro e preenche acols										ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lContinua
	aAdd(aCpoGet,"N3_TIPO")
	aAdd(aCpoGet,"N3_TIPREAV")
	aAdd(aCpoGet,"N3_HISTOR")
	aAdd(aCpoGet,"N3_AQUISIC")
	aAdd(aCpoGet,"N3_TPSALDO")

	aAdd(aCpoGet,"N3_CCONTAB")
	aAdd(aCpoGet,"N3_CUSTBEM")
	aAdd(aCpoGet,"N3_CDEPREC")
	aAdd(aCpoGet,"N3_CCUSTO")
	aAdd(aCpoGet,"N3_CCDEPR")
	aAdd(aCpoGet,"N3_CDESP")
	aAdd(aCpoGet,"N3_CCORREC")
	aAdd(aCpoGet,"N3_CCCORR")
	aAdd(aCpoGet,"N3_CCDESP")
	aAdd(aCpoGet,"N3_CCCDEP")
	aAdd(aCpoGet,"N3_CCCDES")
	aAdd(aCpoGet,"N3_DINDEPR")

	For nI := 1 To nMoedas
		aAdd(aCpoGet,"N3_VORIG"+Alltrim(Str(nI)))
		If nI > 9
			aAdd(aCpoGet,"N3_TXDEP"+Alltrim(Str(nI)))
			aAdd(aCpoGet,"N3_VRDAC"+Alltrim(Str(nI)))
		Else
	   		aAdd(aCpoGet,"N3_TXDEPR"+Alltrim(Str(nI)))
	   	  	aAdd(aCpoGet,"N3_VRDACM"+Alltrim(Str(nI)))
		EndIf
	Next nI

	aAdd(aCpoGet,"N3_TPDEPR")
	aAdd(aCpoGet,"N3_PERDEPR")

	aAdd(aCpoGet,"N3_CRIDEPR")
	aAdd(aCpoGet,"N3_CALDEPR")
	aAdd(aCpoGet,"N3_VMXDEPR")
	aAdd(aCpoGet,"N3_VLSALV1")
	aAdd(aCpoGet,"N3_PRODANO")
	aAdd(aCpoGet,"N3_PRODMES")
	aAdd(aCpoGet,"N3_PRODACM")


	aAdd(aCpoGet,"N3_SUBCCON")
	aAdd(aCpoGet,"N3_SUBCCOR")
	aAdd(aCpoGet,"N3_SUBCDEP")
	aAdd(aCpoGet,"N3_SUBCDES")
	aAdd(aCpoGet,"N3_SUBCCDE")
	aAdd(aCpoGet,"N3_CLVLCON")
	aAdd(aCpoGet,"N3_CLVLCOR")
	aAdd(aCpoGet,"N3_CLVLDEP")
	aAdd(aCpoGet,"N3_CLVLDES")
	aAdd(aCpoGet,"N3_CLVLCDE")


	For nI := 1 To Len(aCpoGet)
		AF155InHdr(aHeaderI,aCpoGet[nI])
	Next nI

	SN3->(DbSetOrder(1))
	SN3->(DbSeek(xFilial("SN3")+SN1->(N1_CBASE+N1_ITEM)+"01"))

	nTxAnDepr := SN3->N3_TXDEPR1
	nVidaAtual:= SN3->N3_PERDEPR
	RegToMemory("SN3",.F.)

	aAdd(aColsI,Array(Len(aHeaderI)+1))
	aColsI[Len(aColsI),Len(aHeaderI)+1] := .F.

	For nI := 1 To Len(aHeaderI)
		If "N3_TPDEPR" $ aHeaderI[nI][2]
	   		aColsI[Len(aColsI)][nI] := GetAdvFVal("SN3","N3_TPDEPR",cIndBem,1,"")
		ElseIf "N3_CRIDEPR" $ aHeaderI[nI][2]
			aColsI[Len(aColsI)][nI] := GetAdvFVal("SN3","N3_CRIDEPR",cIndBem,1,"")
		ElseIf "N3_CALDEPR" $ aHeaderI[nI][2]
			aColsI[Len(aColsI)][nI] := GetAdvFVal("SN3","N3_CALDEPR",cIndBem,1,"")
		Else
			aColsI[Len(aColsI)][nI] := M->&(aHeaderI[nI][2])
		EndIf
	Next nI

	AF155AltHd(aHeaderI,"N3_TIPO"		,06,"")
	AF155AltHd(aHeaderI,"N3_TPSALDO"	,06,"VldTpSald(M->N3_TPSALDO)")
	AF155AltHd(aHeaderI,"N3_TPSALDO"	,13,"")

	AF155AltHd(aHeaderI,"N3_TPDEPR" 	,13,".F.")
	AF155AltHd(aHeaderI,"N3_TPDEPR" 	,06,"")
	AF155AltHd(aHeaderI,"N3_PERDEPR" 	,06,"Positivo() .And. AF155G2()")

	AF155AltHd(aHeaderI,"N3_VMXDEPR"	,06,"Positivo() .And. AF155G2() .And. AF010VlMax()")
	AF155AltHd(aHeaderI,"N3_VLSALV1" 	,06,"Positivo() .And. AF155G2()")
	AF155AltHd(aHeaderI,"N3_PRODANO" 	,06,"Positivo() .And. AF155G2()")
	AF155AltHd(aHeaderI,"N3_PRODMES" 	,06,"Positivo() .And. AF155G2()")

	AF155AltHd(aHeaderI,"N3_CRIDEPR"	,13,".F.")
	AF155AltHd(aHeaderI,"N3_CALDEPR"	,13,".F.")
	AF155AltHd(aHeaderI,"N3_CRIDEPR" 	,06,"")
	AF155AltHd(aHeaderI,"N3_CRIDEPR" 	,06,"")

	AF155AltHd(aHeaderI,"N3_CCONTAB",12,"AF155AGRP('N3_CCONTAB')")
	AF155AltHd(aHeaderI,"N3_CUSTBEM",12,"AF155AGRP('N3_CUSTBEM')")
	AF155AltHd(aHeaderI,"N3_CDEPREC",12,"AF155AGRP('N3_CDEPREC')")
	AF155AltHd(aHeaderI,"N3_CCUSTO",12,"AF155AGRP( 'N3_CCUSTO')")
	AF155AltHd(aHeaderI,"N3_CCDEPR",12,"AF155AGRP( 'N3_CCDEPR')")
	AF155AltHd(aHeaderI,"N3_CDESP"	,12,"AF155AGRP('N3_CDESP')")
	AF155AltHd(aHeaderI,"N3_CCORREC",12,"AF155AGRP('N3_CCORREC')")
	AF155AltHd(aHeaderI,"N3_CCCORR",12,"AF155AGRP( 'N3_CCCORR')")
	AF155AltHd(aHeaderI,"N3_CCDESP",12,"AF155AGRP( 'N3_CCDESP')")
	AF155AltHd(aHeaderI,"N3_CCCDEP",12,"AF155AGRP( 'N3_CCCDEP')")
	AF155AltHd(aHeaderI,"N3_CCCDES",12,"AF155AGRP( 'N3_CCCDES')")
	AF155AltHd(aHeaderI,"N3_SUBCCON",12,"AF155AGRP('N3_SUBCCON')")
	AF155AltHd(aHeaderI,"N3_SUBCCOR",12,"AF155AGRP('N3_SUBCCOR')")
	AF155AltHd(aHeaderI,"N3_SUBCDEP",12,"AF155AGRP('N3_SUBCDEP')")
	AF155AltHd(aHeaderI,"N3_SUBCDES",12,"AF155AGRP('N3_SUBCDES')")
	AF155AltHd(aHeaderI,"N3_SUBCCDE",12,"AF155AGRP('N3_SUBCCDE')")
	AF155AltHd(aHeaderI,"N3_CLVLCON",12,"AF155AGRP('N3_CLVLCON')")
	AF155AltHd(aHeaderI,"N3_CLVLCOR",12,"AF155AGRP('N3_CLVLCOR')")
	AF155AltHd(aHeaderI,"N3_CLVLDEP",12,"AF155AGRP('N3_CLVLDEP')")
	AF155AltHd(aHeaderI,"N3_CLVLDES",12,"AF155AGRP('N3_CLVLDES')")
	AF155AltHd(aHeaderI,"N3_CLVLCDE",12,"AF155AGRP('N3_CLVLCDE')")
	
	AF155AltHd(aHeaderI,"N3_CALDEPR",12,"AF155AGRP('N3_CALDEPR')")
	
	AF155AltHd(aHeaderI,"N3_VMXDEPR",13,"A155VLZERO('N3_VMXDEPR')")

	AF155AltHd(aHeaderI,"N3_PRODACM",06,"AF155AVlGr()")
	AF155AltHd(aHeaderI,"N3_PRODMES",06,"AF155AVlGr()")
	AF155AltHd(aHeaderI,"N3_PRODANO",06,"AF155AVlGr()")
	AF155AltHd(aHeaderI,"N3_VLSALV1",06,"AF155AVlGr()")
	AF155AltHd(aHeaderI,"N3_VMXDEPR",06,"AF155AVlGr()")
	AF155AltHd(aHeaderI,"N3_PRODACM",06,"AF155AVlGr()")
	AF155AltHd(aHeaderI,"N3_CALDEPR",06,"ExistCpo('SN0','06'+M->N3_CALDEPR)")


	For nI := 1 To nMoedas
		AF155AltHd(aHeaderI,"N3_VORIG"+Alltrim(Str(nI))	,06,"POSITIVO()")
		If nI > 9
			AF155AltHd(aHeaderI,"N3_TXDEP"+Alltrim(Str(nI))	,06,"POSITIVO()")
			AF155AltHd(aHeaderI,"N3_TXDEP"+Alltrim(Str(nI))	,13,"AF155TXDP()")
			
			AF155AltHd(aHeaderI,"N3_VRDAC"+Alltrim(Str(nI))	,06,"POSITIVO()")
		Else
			AF155AltHd(aHeaderI,"N3_TXDEPR"+Alltrim(Str(nI)),06,"POSITIVO()")
			AF155AltHd(aHeaderI,"N3_TXDEPR"+Alltrim(Str(nI)),13,"AF155TXDP()")
			
			AF155AltHd(aHeaderI,"N3_VRDACM"+Alltrim(Str(nI))	,06,"POSITIVO()")
		EndIf
	Next nI
	lContinua := AF155ACOLS(aHeaderI,aColsJ,aCamposGD,nOpc,nRecnoDel)
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ 					Tela de configuracao de ampliacao						ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lContinua
	oDlg:= MSDialog():New(aDimensao[1],aDimensao[2],aDimensao[3],aDimensao[4],cCadastro,,,,,,,,,.T.)

		oPanelM	:= TPanel():New(0,0,'',oDlg,,.T.,.T.,,,30,30,.T.,.T.)
		oPanelM:Align:= CONTROL_ALIGN_ALLCLIENT

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ						Dados do Bem: Original					   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	 	oGroupI:= tGroup():New(aDimensao[1]			,5,FA155SIZE(48,oDlg),(aDimensao[4]/2)-5		,STR0020  		,oPanelM,,,.T.)	  //'Dados do Bem: Original'
		oPanelI	:= TPanel():New(FA155SIZE(6,oDlg)		,20,"",oPanelM,,.F.,,,,aDimensao[4]/2-40,FA155SIZE(20,oDlg),.F.,.F.)

	   //	oMsGet := MsmGet():New("SNG",,nOpc	,,,,		,/*{0,0,200,600}*/,		,,,,,oPanelT,,.F.)
	   	oMsGet := Msmget():New("SN3",,1	,,,,aCpoEnc,/*{0,0,200,200}*/,{}	,,,,,oPanelI)
		oMsGet:oBox:Align:= CONTROL_ALIGN_ALLCLIENT

	   	oPanelI2:= TPanel():New(FA155SIZE(28,oDlg)		,20,"",oPanelM,,.F.,,,,aDimensao[4]/2-40,FA155SIZE(15,oDlg),.F.,.F.)

		oGetDdI:=  MsNewGetDados():New(0,0,150,200,0,"AllwaysTrue","AllwaysTrue",,,,,"AllwaysTrue",,"AllwaysTrue",oPanelI2,aHeaderI,aColsI)
		oGetDdI:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ						Dados da operacao						   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		oGroupJ	:= tGroup():New(FA155SIZE(48,oDlg)	,5,FA155SIZE(68,oDlg),(aDimensao[4]/2)-5		,STR0021	   		,oPanelM,,,.T.) //'Dados da Operacao'
	 	oPanelJ	:= TPanel():New(FA155SIZE(51,oDlg)		,20,"",oPanelM,,.F.,,,,aDimensao[4]/2-40,FA155SIZE(14,oDlg),.F.,.F.)

		oSayJ3	:= TSay():New(03,05			,{|| STR0024 },oPanelJ,,,,,,.T.) //"Acao"
	 	oComboJ3:= tComboBox():New(02,55	,{|u| if(PCount()>0,cAcao:=u,cAcao)	},aComboJ3,90,20,oPanelJ,,{|| If(cAcao == "1",(cMetodo := "3", oGetDdL:Disable(),AF155TPATF(oGetDdL,cMetodo,aColsI,.T.)),(cMetodo := "1",oGetDdL:Enable(),AF155TPATF(oGetDdL,cMetodo,,.T.)))},,,,.T.,,,,{|| (nOpc == 3)},,,,,'cAcao')

	 	oSayJ1	:= TSay():New(15,05			,{|| STR0022 },oPanelJ,,,,,,.T.) //"Metodo"
	  	oComboJ1:= tComboBox():New(14,55	,{|u| if(PCount()>0,cMetodo:=u,cMetodo)},aComboJ1,90,20,oPanelJ,,{|| AF155TPATF(oGetDdL,cMetodo)},bValidM,,,.T.,,,,{|| (nOpc == 3 .and. cAcao $ "2|3")},,,,,'cMetodo')

		oSayJ2 	:= TSay():New(03,165		,{|| STR0023 },oPanelJ,,,,,,.T.) //"Tipo de Vida Util"
	 	oComboJ2:= tComboBox():New(02,210	,{|u| if(PCount()>0,cTipoVida:=u,cTipoVida)},aComboJ2,90,20,oPanelJ,,{|| nTxDepr := 0},,,,.T.,,,,{|| (nOpc == 3 .and. cAcao $ "2|3")},,,,,'cTipoVida')

		oSayJ4	:= TSay():New(15,165		,{|| STR0025+cTipoMA },oPanelJ,,,,,,.T.) //"Vida Util "
		oGetJ1	:= TGet():New(14,210		,{|u| if(PCount()>0,nVidaUtil:=u,nVidaUtil)	},oPanelJ,90,10,PesqPict("SN3","N3_PERDEPR"),,,,,,,.T.,,,,,,,(nOpc == 4),,,'nVidaUtil')

	   	If nVidaAtual <= 0
	   		If nTxAnDepr > 0
	   			nVidaAtual	:= (100/nTxAnDepr)
				nVidaAtual := Round(IiF(lCalcMes,(nVidaAtual * 12),nVidaAtual),0)
			EndIf
		EndIf
		cVAtual	:= ALLTRIM(STR(nVidaAtual))+" "+cTipoMA
		oSayJ5	:= TSay():New(03,320		,{|| STR0026},oPanelJ,,,,,,.T.) //"Vida Util Atual"
		oGetJ2	:= TGet():New(02,365		,{|u| if(PCount()>0,cVAtual:=u,cVAtual)},oPanelJ,90,10,,,,,,,,.T.,,,{|| .F.},,,,,,,'cVAtual')

		cQtdMov	:= ALLTRIM(STR(nQtdMov))+" "+cTipoMA
		oSayJ6	:= TSay():New(15,320		,{|| STR0027},oPanelJ,,,,,,.T.) //"Transcorrida"
		oGetJ3	:= TGet():New(14,365		,{|u| if(PCount()>0,cQtdMov:=u,cQtdMov)},oPanelJ,90,10,,,,,,,,.T.,,,{|| .F.},,,,,,,'nQtdMov')

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ						Dados do Bem: Incorporacao 				   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	  	oGroupL:= tGroup():New(FA155SIZE(68,oDlg)	,5,FA155SIZE(90,oDlg),(aDimensao[4]/2)-5		,STR0028	,oPanelM,,,.T.) //'Dados do Bem: Incorporacao'
		oPanelL	:= TPanel():New(FA155SIZE(73,oDlg)		,20,"",oPanelM,,.F.,,,,aDimensao[4]/2-40,FA155SIZE(15,oDlg),.F.,.F.)

		oGetDdL:=  MsNewGetDados():New(0,0,150,200,(If(nOpc == 3,GD_INSERT+GD_UPDATE+GD_DELETE,0)),"AllwaysTrue","AllwaysTrue",,aCamposGD,,1,"AllwaysTrue",,"AllwaysTrue",oPanelL,aHeaderI,aColsJ)
		oGetDdL:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oGetDdL:bFieldok	:= bFieldOk
		oGetDdL:Disable()
	oDlg:Activate(,,,.T.,,,EnchoiceBar(oDlg,bUpdate,bEndWin))
EndIf
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF155ACOLSบAutor  ณJair Ribeiro        บ Data ณ  07/21/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Preenche aColsJ de acordo com a opcao selecionada no browseบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aHeaderI: aHeader do objeto MsNewGetDados                  บฑฑ
ฑฑบ          ณ aColsJ: aCols a ser preenchido                             บฑฑ
ฑฑบ          ณ aCamposGD: Campos que poderao ser editados no aCols	      บฑฑ
ฑฑบ          ณ nOpc: Opcao selecionada no browse                          บฑฑ
ฑฑบ          ณ nRecnoDel: Recno para estorno						      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAATF                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF155ACOLS(aHeaderI,aColsJ,aCamposGD,nOpc,nRecnoDel)
Local nI	:= 0
Local lRet	:= .T.
Local aArea	:= SN3->(GetArea())

If nOpc == 3
	aAdd(aColsJ,Array(Len(aHeaderI)+1))
	aColsJ[Len(aColsJ),Len(aHeaderI)+1] := .F.

	For nI := 1 To Len(aHeaderI)
		If "N3_TIPO" $ aHeaderI[nI][2]
			aColsJ[Len(aColsJ)][nI] := "01"
		Else
			aColsJ[Len(aColsJ)][nI] := M->&(aHeaderI[nI][2])
			aAdd(aCamposGD,ALLTRIM(aHeaderI[nI][2]))
		EndIf
	Next nI
Else
	SN3->(DbGoTo(nRecnoDel))
	aAdd(aColsJ,Array(Len(aHeaderI)+1))
	aColsJ[Len(aColsJ),Len(aHeaderI)+1] := .F.

	For nI := 1 To Len(aHeaderI)
		aColsJ[Len(aColsJ)][nI] := SN3->&(aHeaderI[nI][2])
	Next nI
EndIf
SN3->(RestArea(aArea))
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF155TDOK บAutor  ณJair Ribeiro        บ Data ณ  07/21/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida configuracao digitada	                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oGetDados: MsNewGetDados que contem dados da Incorporacao  บฑฑ
ฑฑบ          ณ lCalcMes: Define calculo mensal (.T.) ou anual (.F.)       บฑฑ
ฑฑบ          ณ nVidaAtual: Vida util atual do bem                         บฑฑ
ฑฑบ          ณ cMetodo: Define novo item("1") ou incorporacao("2")        บฑฑ
ฑฑบ          ณ cTipoVida: Define tipo de vida util	                      บฑฑ
ฑฑบ          ณ cAcao: Define dados a serem validados valor e/ou vida util บฑฑ
ฑฑบ          ณ nVidaUtil: Valor da nova vida util                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAATF                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF155TDOK(oGetDados,lCalcMes,nVidaAtual,cMetodo,cTipoVida,cAcao,nVidaUtil)
Local lVldVida	:= (cAcao $ "1|3")
Local lVldValor	:= (cAcao $ "2|3")
Local lVidaProp	:= (cTipoVida $ "2")
Local aColsX	:= aClone(oGetDados:aCols)
Local aHeaderX	:= aClone(oGetDados:aHeader)
Local nPosTxDep	:= GdFieldPos('N3_TXDEPR1',aHeaderX)
Local nPosVOrig	:= GdFieldPos('N3_VORIG1',aHeaderX)
Local nPosTipo	:= GdFieldPos('N3_TIPO',aHeaderX)
Local nPosTpSald:= GdFieldPos('N3_TPSALDO',aHeaderX)

Local lRet 		:= .T.

If lVldVida
	If lCalcMes
		If ((nVidaUtil - nVidaAtual) < 12)
			lRet := .F.
			Help(" ",1,"AF150NOVUT",,STR0029 + ALLTRIM(STR(nVidaAtual)),1,0) //"Para amplia็ใo da vida ๚til deve ser informado ao menos 12 meses a mais que a vida ๚til atual que ้ de : "
		EndIf
	ElseIf ((nVidaUtil - nVidaAtual) < 1) .and. lRet
		lRet := .F.
		Help(" ",1,"AF150NOVUT",,STR0030 + ALLTRIM(STR(nVidaAtual)),1,0) //"Para amplia็ใo da vida ๚til deve ser informado ao menos 1 ano a mais que a vida ๚til atual que ้ de : "
	EndIf
EndIf

If lVldValor .and. lRet

	If lVidaProp
		lRet:= oGetDados:ChkObrigat(1)
		If lRet
			If !(lRet := aColsX[1,nPosTxDep] > 0)
				Help(" ",1,"AF150NOVUT",,STR0031+aHeaderX[nPosTxDep,1],1,0) //"Para esta configura็ใo a Taxa de Deprecia็ใo deve ser informada em Incorporacao: campo "
			EndIf
		EndIf
	EndIf

	If nPosVOrig > 0 .and. lRet
		If !(lRet := aColsX[1,nPosVOrig] > 0)
			Help(" ",1,"AF150VLR",,STR0032+aHeaderX[nPosVOrig,1],1,0) //"Para a็ใo selecionada ้ necessแrio informar o valor em Incorporacao: campo "
		EndIf
	EndIf
EndIf

If lRet
	lRet:= ATFSALDEPR(aColsX[1,nPosTipo],aColsX[1,nPosTpSald])
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF155GRV  บAutor  ณJair Ribeiro        บ Data ณ  07/21/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Prepara rotina para gravacao dos dados                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oGetDados: MsNewGetDados que contem dados da Incorporacao  บฑฑ
ฑฑบ          ณ nOpc: Opcao selecionada no browse                          บฑฑ
ฑฑบ          ณ nTxAnDepr: Taxa anual de depreciacao na moeda de calculo   บฑฑ
ฑฑบ          ณ lCalcMes: Indica se sistema esta configurado para calculo  บฑฑ
ฑฑบ          ณ de depreciacao mensal                                      บฑฑ
ฑฑบ          ณ cTipoVida: Define tipo de vida util                        บฑฑ
ฑฑบ          ณ cAcao: Define dados a serem validados valor e/ou vida util บฑฑ
ฑฑบ          ณ nVidaUtil: Valor da nova vida util                         บฑฑ
ฑฑบ          ณ nRecnoDel: Recno para estorno						      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAATF                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF155GRV(oGetDados,nOpc,nTxAnDepr,lCalcMes,cMetodo,cTipoVida,cAcao,nVidaUtil,nRecnoDel)
Local nAux			:= 0
Local nQtdMov		:= 0
Local nTxDprBem		:= 0
Local lNoExComp		:= .T.
Local cCpoTxDep		:= 'N3_TXDEPR1'
Local cMoedaAtf		:= AllTrim(SuperGetMv("MV_ATFMOED",,"1"))
Local nPosTxDep 	:= Ascan(oGetDados:aHeader, {|x| Alltrim(x[2])  == IiF(Val(cMoedaAtf)>9,"N3_TXDEP","N3_TXDEPR")+cMoedaAtf})


Local lAmpliacao	:= (cAcao $ "2|3")
Local lVidaUTil		:= (cAcao $ "1|3")
Local lIncorp		:= ((cMetodo == "2") .and. lAmpliacao)
Local lQtdMov		:= ((cTipoVida == "1") .or. lVidaUTil)

If lQtdMov
	nQtdMov	:= AF155MOVIM(xFilial("SN3"),SN1->N1_CBASE,SN1->N1_ITEM,"01","06","3")
EndIf

lNoExComp := (GetAdvFVal("SN3","N3_CRIDEPR",xFilial("SN3")+SN1->(N1_CBASE+N1_ITEM)+"01",1,"") != "03")

If nOpc == 3
	If lVidaUTil	
		nTxDprBem := AF155AMPVU(oGetDados,nTxAnDepr,nQtdMov,nVidaUtil)			//Aumento de vida util
	EndIf


	If(cTipoVida == "1") .and. lAmpliacao	//Vida Util Vinculada
		If (nAux := GdFieldPos('N3_TXDEPR1',oGetDados:aHeader)) > 0
			If lNoExComp
				oGetDados:aCols[1,nAux]	:= Iif(lVidaUTil, nTxDprBem , Iif(oGetDados:aCols[1,nAux]>0 ,oGetDados:aCols[1,nAux] , nTxAnDepr )) //O TIPO 11 SERA CRIADO COM A MESMA TAXA GERADA PARA O TIPO 1 || AF155VVINC(Iif(lVidaUTil,nTxDprBem,nTxAnDepr),nQtdMov)
			Else
				oGetDados:aCols[1,nAux]	:= Iif(lVidaUTil,nTxDprBem,nTxAnDepr)
				If nPosTxDep > 0
					oGetDados:aCols[1,nPosTxDep]	:= oGetDados:aCols[1,nAux]
				EndIf
			EndIf
		EndIf
	EndIf

	If (lIncorp .and. lVidaUTil)					   			//Incorporacao + aumento de vida util
		AF155G010(oGetDados,nOpc,.F.,.F.,,nTxDprBem,nVidaUtil)

		If(cTipoVida == "1") .and. lAmpliacao
			If (nAux := GdFieldPos('N3_TXDEPR1',oGetDados:aHeader)) > 0
				nTxAnDepr := GetAdvFVal("SN3",cCpoTxDep,xFilial("SN3")+SN1->(N1_CBASE+N1_ITEM)+"01",1,"")

				If lNoExComp
					oGetDados:aCols[1,nAux]	:= AF155VVINC(Iif(lVidaUTil,nTxDprBem,nTxAnDepr),nQtdMov)
					If nPosTxDep > 0
						oGetDados:aCols[1,nPosTxDep]	:= oGetDados:aCols[1,nAux]
					EndIf
				Else
			   		oGetDados:aCols[1,nAux]	:= Iif(lVidaUTil,nTxDprBem,nTxAnDepr)
			 		If nPosTxDep > 0
						oGetDados:aCols[1,nPosTxDep]	:= oGetDados:aCols[1,nAux]
					EndIf
				EndIf
			EndIf
		EndIf

		AF155G010(oGetDados,nOpc,lIncorp,.F.)
	Else
		If lAmpliacao //aumento de vida Util tabela Sn3 ja ้ atualizada na fun็ใo  AF155AMPVU
			AF155G010(oGetDados,nOpc,lIncorp,lAmpliacao,,nTxDprBem,nVidaUtil)
		EndIf
	EndIf
Else													//Estorno
	AF155G010(oGetDados,nOpc,.F.,.F.,nRecnoDel)
EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF155G010 บAutor  ณMicrosiga           บ Data ณ  07/24/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua alteracao/inclusao na ficha de ativo por intermedio บฑฑ
ฑฑบ          ณ da funcao Af010Grava                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oGetDados: MsNewGetDados que contem dados da Incorporacao  บฑฑ
ฑฑบ          ณ nOpc: Opcao selecionada no browse                          บฑฑ
ฑฑบ          ณ lNewAtf: Indica se sera criado um novo bem (Incorporacao)  บฑฑ
ฑฑบ          ณ lNewItem: Indica se adicionado a ficha uma ampliacao 11	  บฑฑ
ฑฑบ          ณ nRecnoDel: Recno para estorno						      บฑฑ
ฑฑบ          ณ nTxDprBem: Nova taxa de depreciacao do bem - Aumento de    บฑฑ
ฑฑบ          ณ vida util do bem											  บฑฑ
ฑฑบ          ณ nVidaUtil: Valor da nova vida util                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAATF                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF155G010(oGetDados,nOpc,lNewAtf,lNewItem,nRecnoDel,nTxDprBem,nVidaUtil)
Local nUsado	:= 0
Local nI		:= 0
Local nRecno	:= 0
Local nAux		:= 0

Local cItem		:= ""
Local cCpoTxDep	:= 'N3_TXDEP'
Local cCpoPerDp	:= 'N3_PERDEPR'
Local cBaseSup	:= SN1->N1_CBASE
Local cItemSup	:= SN1->N1_ITEM
Local cChave	:= xFilial("SN3")+SN1->N1_CBASE

Local aAreaSN1	:= SN1->(GetArea())
Local aAreaSN3	:= SN3->(GetArea())
Local aColsX	:= aClone(oGetDados:aCols)
Local aHeaderX	:= aClone(oGetDados:aHeader)

Local nPosTipo	:= GdFieldPos("N3_TIPO",aHeaderX)
Local nPosHist	:= GdFieldPos("N3_HISTOR",aHeaderX)
Local nPosConta	:= GdFieldPos("N3_CCONTAB",aHeaderX)
Local nPosCC	:= GdFieldPos("N3_CCUSTO",aHeaderX)
Local nPosItem	:= GdFieldPos("N3_SUBCCON",aHeaderX)
Local nPosClVl	:= GdFieldPos("N3_CLVLCON",aHeaderX)
Local nPosAux	:= 0

Local lCalcMes	:= (ALLTRIM(SuperGetMv("MV_CALCDEP",,"1")) == "0")	//Verifica a formula de calculo de depreciacao
Local nVal		:= 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa as Variaveis Privates utilizadas pela funcao af010Grava      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local 	lMostra	    := .F. // Mostra Lancamento
Local 	aCab			:= {}
Local 	aItens			:= {}	
Local 	aAux			:= {} 
Local aParam 			:= {}

Private aCols			:= {}
Private aHeader			:= {}
Private uCampos			:= ""
Private n				:= 1
Private nHdlPrv		:= 0  
Private lContabiliza	:= .T.
Private lHeader		:= .T.
Private lTrailler		:= .T.
Private lAuto			:= .T.
Private lCprova		:= .F.
Private lCopia			:= .F.
Private lPadrao 		:= .F. 
Private Inclui			:= lNewAtf
Private Altera			:= !lNewAtf
Private cLoteAtf 		:= LoteCont("ATF")
Private nTotal			:= 0
Private cArquivo		:= ""
Private lMsErroAuto	:= .F.
Default nTxDprBem		:= 0
Default nVidaUtil		:= 0


Pergunte("AFA012",.F.)
lMostra:=(MV_PAR01 == 1)
nRecno := SN1->(Recno())
cItem:=SN1->N1_ITEM

If lNewAtf
	While SN1->(MsSeek(xFilial("SN1")+SN1->N1_CBASE+cItem)) .OR. !(MayIUseCode(xFilial("SN1")+SN1->N1_CBASE+cItem))
		FreeusedCode(.T.)
		cItem:=AFA155ITEM(xFilial("SN1"),SN1->N1_CBASE,cItem)
	EndDo
	SN1->(DbGoTo(nRecno))
EndIf

cChave += cItem
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa as Variaveis do SN1                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd(aCab,{"N1_CBASE", SN1->N1_CBASE})

SX3->(DbSetOrder(1))
SX3->(MsSeek("SN1"))
While (SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SN1" )
	uCampo := SX3->X3_CAMPO
	M->&(uCampo) := CriaVar(SX3->X3_CAMPO,IiF(SX3->X3_CONTEXT=="V",.F.,.T.))
	If(X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
		If ("N1_ITEM" $ uCampo)
	   		aAdd(aCab,{uCampo, cItem})
		ElseIf ("N1_AQUISIC" $ uCampo)
			aAdd(aCab,{uCampo, dDataBase})
		ElseIf ("N1_INIAVP" $ uCampo)
			aAdd(aCab,{uCampo, dDataBase})
		ElseIf ("N1_ICMSAPR" $ uCampo) .and. lNewAtf
			aAdd(aCab,{uCampo, 0 })
		Else			
			aAdd(aCab,{uCampo, SN1->&(uCampo)})
		EndIf
	EndIf
	
	SX3->(DbSkip())
EndDo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa o aHeader do SN3                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SX3->(DbSetOrder(1))
SX3->(MsSeek("SN3"))
While(SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SN3" )
	If(X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
		aAdd(aHeader ,{ Trim(X3TITULO()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT } )
		nUsado++
	EndIf
	SX3->(DbSkip())
EndDo

If !lNewAtf .and. nOpc == 4
	SN3->(DbSetOrder(1))
	If SN3->(DbSeek(cChave))
		While SN3->(!EOF()) .and. SN3->(N3_FILIAL+N3_CBASE+N3_ITEM) == cChave
			If SN3->(Recno()) == nRecnoDel 
				For nI := 1 To Len(aHeader)
					If (nTxDprBem > 0 .and. nVidaUtil > 0).and. SN3->N3_TIPO $ "01"
						If cCpoTxDep $ AllTrim(aHeader[nI][2])
							aAdd(aAux,{aHeader[nI][2], nTxDprBem})
						ElseIf AllTrim(aHeader[nI][2]) == cCpoPerDp
							aAdd(aAux,{aHeader[nI][2], nVidaUtil})
						Else
							aAdd(aAux,{aHeader[nI][2], SN3->&(AllTrim(aHeader[nI][2]))})
						EndIf
					Else
						aAdd(aAux,{aHeader[nI][2], SN3->&(AllTrim(aHeader[nI][2]))})
					EndIf
				Next nI
				
				aAdd(aAux,{"AUTDELETA", "S"})
				
				aAdd(aItens, aAux)
				aAux := {}
			EndIf
			SN3->(DbSkip())
		EndDo
	EndIf
EndIf

If nOpc == 3 .and. (lNewItem .or. lNewAtf)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPreenchimento das Variaveis referentes ao SN3                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nI := 1 To nUsado
		Do Case
		Case ("N3_CBASE"		$ aHeader[nI][2]) .and. nPosTipo > 0
			aAdd(aAux,{"N3_CBASE", SN1->N1_CBASE	})
		Case ("N3_ITEM"		$ aHeader[nI][2]) .and. nPosTipo > 0
			aAdd(aAux,{"N3_ITEM", cItem	})
		Case ("N3_TIPO"		$ aHeader[nI][2]) .and. nPosTipo > 0
			aAdd(aAux,{"N3_TIPO", aColsX[1,nPosTipo]	})
		Case ("N3_TIPO"		$ aHeader[nI][2]) .and. nPosTipo > 0
			aAdd(aAux,{"N3_TIPO", aColsX[1,nPosTipo]	})
			
		Case ("N3_HISTOR"	$ aHeader[nI][2]) .and. nPosHist > 0
			aAdd(aAux,{"N3_HISTOR",aColsX[1,nPosHist]})
			
		Case ("N3_CCONTAB"	$ aHeader[nI][2]) .and. nPosConta > 0
			aAdd(aAux,{"N3_CCONTAB", aColsX[1,nPosConta]})
			
		Case ("N3_CCUSTO" 	$ aHeader[nI][2]) .and. nPosCC > 0
			aAdd(aAux,{"N3_CCUSTO", aColsX[1,nPosCC]})
			
		Case ("N3_SUBCCON"	$ aHeader[nI][2]) .and. nPosItem > 0
			aAdd(aAux,{"N3_SUBCCON", aColsX[1,nPosItem]})
			
		Case ("N3_CLVLCON" 	$ aHeader[nI][2]) .and. nPosClVl > 0
			aAdd(aAux,{"N3_CLVLCON", aColsX[1,nPosClVl]})
			
		Case ("N3_VORIG"	$ aHeader[nI][2])
			If (nAux := GdFieldPos(aHeader[nI][2],aHeaderX)) > 0
				aAdd(aAux,{aHeader[nI][2], aColsX[1,nAux]})
			Else
				aAdd(aAux,{aHeader[nI][2], CriaVar(aHeader[nI][2],IIF(SX3->X3_CONTEXT=="V",.F.,.T.))})
			EndIf
		Case ("N3_TXDEP"	$ aHeader[nI][2])
			If (nAux := GdFieldPos(aHeader[nI][2],aHeaderX)) > 0
				aAdd(aAux,{aHeader[nI][2], aColsX[1,nAux]})
			Else
				aAdd(aAux,{aHeader[nI][2], CriaVar(aHeader[nI][2],IIF(SX3->X3_CONTEXT=="V",.F.,.T.))})
			EndIf
			
		Case ("N3_PERDEPR"	$ aHeader[nI][2])
			If (nAux := GdFieldPos("N3_TXDEPR1",aHeaderX)) > 0
				nVal:= aColsX[1,nAux]
				If nVal > 0
					nVal	:= (100/nVal)
					nVal 	:= Round(IiF(lCalcMes,(nVal*12),nVal),0)
				EndIf
				aAdd(aAux,{"N3_PERDEPR", nVal })
			Else
				aAdd(aAux,{"N3_PERDEPR", CriaVar(aHeader[nI][2],IIF(SX3->X3_CONTEXT=="V",.F.,.T.))})
			EndIf
			
		Case ("N3_BAIXA" 	$ aHeader[nI][2])
			aAdd(aAux,{"N3_BAIXA", "0"})
		Case ("N3_SEQ" 	$ aHeader[nI][2])
			aAdd(aAux,{"N3_SEQ", Soma1(ATFxUltSeq(SN1->N1_CBASE,cItem))})

		OtherWise
			If (nPosAux := aScan(aHeaderX,{|x| AllTrim(x[2]) == AllTrim(aHeader[nI][2])}))>0
				aAdd(aAux,{aHeader[nI][2], aColsX[1,nPosAux]})
			Else
				aAdd(aAux,{aHeader[nI][2], CriaVar(aHeader[nI][2],IIF(SX3->X3_CONTEXT=="V",.F.,.T.))})
			EndIf
		EndCase
	Next nI
	aAdd(aItens, aAux)
	aAux := {}
EndIf


DbSelectArea("SN1")
aAdd(aParam,{"MV_PAR02",1})
MSExecAuto({|x,y,z,w| ATFA012(x,y,z,w)},aCab,aItens,If(lNewAtf,3,4),aParam)

If lMsErroAuto
	lMsErroAuto := .F.
	DisarmTransaction()
	lRet := .F.
	cFileLog := NomeAutoLog()
	cPath := ""
	If !Empty(cFileLog) .And. !lRet
		MostraErro(cPath,cFileLog)
	Endif
Else	
	If lNewAtf 
		SN1->(DbSetOrder(1))
		If SN1->(DbSeek(cChave))
			If SN1->(RecLock("SN1",.F.))
				SN1->N1_BASESUP := cBaseSup
				SN1->N1_ITEMSUP := cItemSup		
				SN1->(MsUnLock())
			EndIf
		EndIf
	Else
		If nOpc == 3 .And. (!lNewItem .or. !lNewAtf) .And. (nTxDprBem > 0)  .and. !_lAtualizou
			SN3->(DbSetOrder(1))
			If SN3->(DbSeek(cChave))
				If SN3->(RecLock("SN3",.F.))
					SN3->N3_TXDEPR1 := nTxDprBem
					SN3->N3_TXDEPR2 := nTxDprBem
					SN3->N3_TXDEPR3 := nTxDprBem
					SN3->N3_TXDEPR4 := nTxDprBem
					SN3->N3_TXDEPR5 := nTxDprBem
					SN3->N3_PERDEPR := nVidaUtil		
					SN3->(MsUnLock())
				EndIf
			EndIf
		EndIf
	EndIf 
EndIf

aSize(aAux, 0)
aSize(aItens,0)
aSize(aCab,0)
aCab := Nil
aItens := Nil
aAux	:= Nil
FreeusedCode(.T.)
SN1->(RestArea(aAreaSN1))
SN3->(RestArea(aAreaSN3))
Return !lMsErroAuto
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF155TPATFบAutor  ณJair Ribeiro        บ Data ณ  07/21/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Altera campo N3_TIPO da grid referente aos dados do bem    บฑฑ
ฑฑบ          ณ incorporacao de acordo com o campo Metodo                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oGetDados: MsNewGetDados que contem dados da Incorporacao  บฑฑ
ฑฑบ          ณ cMetodo: Define novo item("1") ou incorporacao("2")        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAATF                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF155TPATF(oGetDados,cMetodo,aColsY,lAcao)
Local aColsX	:= aClone(oGetDados:aCols)
Local aHeaderX	:= aClone(oGetDados:aHeader)
Local nPosTipo	:= GdFieldPos("N3_TIPO",aHeaderX)
local nPosAqui:= GdFieldPos("N3_AQUISIC",aHeaderX)// adicionado por Caio Quqiueto dos Santos dia 30/01/12
local nPosDepr:= GdFieldPos("N3_DINDEPR",aHeaderX)// adicionado por Caio Quqiueto dos Santos dia 30/01/12
Local nI		:= 0

Default aColsY	:= {}
Default lAcao 	:= .F.

If nPosTipo > 0
	If cMetodo == "1" 
		aColsX[1,nPosTipo]:= "11"					//Novo Item
		aColsX[1,nPosAqui]:= dDataBase				// adicionado por Caio Quqiueto dos Santos dia 30/01/12
		aColsX[1,nPosDepr]:= RetDinDepr(dDataBase)// adicionado por Caio Quqiueto dos Santos dia 30/01/12
		If lAcao
			For nI := 1 To Len(aHeaderX)
				If (aHeaderX[nI][8] == "N")
					aColsX[Len(aColsX)][nI] := 0
				EndIf
			Next nI		
		EndIf
	Else
		If lAcao .and. !Empty(aColsY)
	   		aColsX := aClone(aColsY)
		EndIf
		
   		aColsX[1,nPosTipo]:= "01"	//Incorporacao
	EndIf
	oGetDados:aCols := aClone(aColsX)
	oGetDados:ForceRefresh()
EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF155MOVIMบAutor  ณJair Ribeiro        บ Data ณ  07/27/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna quantidade de movimentos de depreciacao de um bem   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcFilial: Filial para chave de busca                         บฑฑ
ฑฑบ          ณcBase: Codigo base do bem                                   บฑฑ
ฑฑบ          ณcItem: Item relacionado ao bem                              บฑฑ
ฑฑบ          ณcTipo: Tipo do bem                                          บฑฑ
ฑฑบ          ณcOcorr: Tipo de ocorrencia a ser considerada                บฑฑ
ฑฑบ          ณcTipoCnt: Tipo de conta a ser considerada 	              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function AF155MOVIM(cFilialI,cBase,cItem,cTipo,cOcorr,cTipoCnt)
Local nQtdMov	:= 0    
Local aArea		:= SN4->(GetArea())
     
If SN4->(DbSeek(cFilialI+cBase+cItem+cTipo))   
	While SN4->(!EOF()) .and. SN4->(N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO) == cFilialI+cBase+cItem+cTipo
		If ((SN4->N4_OCORR == PadR(cOcorr,TamSx3('N4_OCORR')[1])) .and. (SN4->N4_TIPOCNT == Padr(cTipoCnt,TamSx3('N4_TIPOCNT')[1])))
	   		nQtdMov++
	 	EndIf
	 	SN4->(DbSkip())
	EndDo
EndIf
SN4->(RestArea(aArea))
Return nQtdMov
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF155VVINCบAutor  ณJair Ribeiro        บ Data ณ  07/27/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a taxa de depreciacao anual para vida util vinculadaบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnTxDprAn: Taxa de depreciacao anual	                      บฑฑ
ฑฑบ          ณnQtdMov: Quantidade de movimentos de depreciacao            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF155VVINC(nTxAnDepr,nQtdMov)
Local nTxVinc	:= 0
Local lCalcMes	:= (ALLTRIM(GetMv("MV_CALCDEP",,"1"))== "0")

If nTxAnDepr> 0
	nTxVinc	:= (100/nTxAnDepr)
EndIf

nTxVinc	:= IiF(lCalcMes,(nTxVinc * 12), nTxVinc)
nTxVinc	:= nTxVinc - nQtdMov
nTxVinc	:= IiF(lCalcMes,(nTxVinc / 12), nTxVinc)

If nTxVinc > 0 
	nTxVinc	:= 100/nTxVinc  
EndIf

Return nTxVinc
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF155AMPVUบAutor  ณJair Ribeiro        บ Data ณ  07/27/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza a taxa de deprecia็ใo para os ativos jแ 		  	  บฑฑ
ฑฑบ			 ณcadastrados e Retorna a taxa de depreciacao anual    	  	  บฑฑ
ฑฑบ          ณpara ampliacao de vida util                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnTxDprAn: Taxa de depreciacao anual	                      บฑฑ
ฑฑบ          ณnQtdMov: Quantidade de movimentos de depreciacao            บฑฑ
ฑฑบ          ณnVidaUT: Vida util revisada					              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF155AMPVU(oGetDados,nTxAnDepr,nQtdMov,nVidaUT)
Local lCalcMes	:= (ALLTRIM(SuperGetMv("MV_CALCDEP",,"1"))== "0")
Local nVlBem	:= 0
Local nVLAcu	:= 0
Local nNvVlBem	:= 0
Local nPrazo	:= nVidaUT-nQtdMov //Quantida de meses restantes A DEPRECIAR
Local nVlMes	:= 0
Local nTxAno	:= 0
Local aArea 	:= GetArea()
Local nTxVida	:= 0
Local nPosvlampl 	:= GdFieldPos('N3_VORIG1',oGetDados:aHeader)
Local cIndice   :=	SN3->(N3_FILIAL+N3_CBASE+N3_ITEM)

Default nTxAnDepr := 0 
Default nQtdMov	  := 0
Default nVidaUT	  := 0


//sn3 posicionado N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
//Atualizo a taxa de deprecia็ใo para os tipos 01 e 11 jแ cadastrados 
While SN3->(!EOF()) .and. SN3->(N3_FILIAL+N3_CBASE+N3_ITEM) == cIndice
	If SN3->N3_TIPO == '01' .or. SN3->N3_TIPO == '11'
		nVlBem := SN3->N3_VORIG1  //Valor do Bem
		nVLAcu := SN3->N3_VRDACM1  //Valor deprecia็ใo acumulada
		nNvVlBem := nVlBem - nVLAcu //novo valor do ativo jแ descontando o q jแ foi depreciado
		nVlMes := nNvVlBem / nPrazo //Valor deprecia็ใo por mes com o novo valor do bem
		nTxAno := (nVlMes/nVlBem)*100 //Taxa am%
		If nTxAno > 0 
			nTxVida := IIf( lCalcMes , nTxAno * 12,nTxAno)  //Taxa aa%
		Else
			nTxVida := nTxAnDepr
		EndIf
		If SN3->(RecLock("SN3",.F.))
			SN3->N3_TXDEPR1 := nTxVida
			SN3->N3_TXDEPR2 := nTxVida
			SN3->N3_TXDEPR3 := nTxVida
			SN3->N3_TXDEPR4 := nTxVida
			SN3->N3_TXDEPR5 := nTxVida
			SN3->N3_PERDEPR := nVidaUT		
			SN3->(MsUnLock())
		EndIf
	EndIf

	SN3->(DbSkip())

EndDo
_lAtualizou := .T.
//Devolvo a taxa de deprecia็ใo para o novo tipo 11 criado
//Tipo 11 nao tem deprecia็ใo acumulada valor mensal ้ igual ao valor da amplia็ใo dividido pelos meses restantes a depreciar
nVlBem := oGetDados:aCols[1][nPosvlampl]  //Valor da amplia็ใo
nVlMes := nVlBem / nPrazo //Valor deprecia็ใo por mes com o novo valor do bem
nTxAno := (nVlMes/nVlBem)*100 //Taxa am%
If nTxAno > 0 
	nTxVida := IIf( lCalcMes , nTxAno * 12,nTxAno)  //Taxa aa%
Else
	nTxVida := nTxAnDepr
EndIf

RestArea(aArea)
Asize(aArea,0)
aArea := nil 

Return nTxVida
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF155SetVlบAutor  ณJair Ribeiro        บ Data ณ  08/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valid para preenchimento dos campos correspondentes a moedaบฑฑ
ฑฑบ          ณ de calculo do ativo bFieldOk                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oGetDados: MsNewGetDados que contem dados da Incorporacao  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAATF                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF155SetVl(oGetDados)
Local cVar		:= ReadVar()
Local aColsX	:= oGetDados:aCols
Local cMoedaAtf	:= AllTrim(GetMv("MV_ATFMOED",,"1"))
Local nPosTxDep := Ascan(oGetDados:aHeader, {|x| Alltrim(x[2])  == IiF(Val(cMoedaAtf)>9,"N3_TXDEP","N3_TXDEPR")+cMoedaAtf})

If "N3_VORIG1" $ cVar
	AF155CONV(oGetDados,aColsX)
ElseIf "N3_TXDEPR1" $ cVar
	aColsX[1,nPosTxDep]	:= &(ReadVar()) 
EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA155SIZE บAutor  ณJair Ribeiro	     บ Data ณ  07/14/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna posicao X para objetos	                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nPerc: Numero percentual para posicionamento               บฑฑ
ฑฑบ          ณ oBj: Objeto pai                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAATF                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FA155SIZE(nPerc,oBj)
Local aDimensao	:= FWGetDialogSize(oBj)
Local nSIze		:= 0
nSize := (aDimensao[3] * nPerc) /200
Return INT(nSize)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF155InHdrบAutor  ณJair Ribeiro        บ Data ณ  05/19/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Preenche aHeader                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aHeaderX: aHeader a ser preenchido                         บฑฑ
ฑฑบ          ณ cCampo: Campo contido no dicionario X3_CAMPO               บฑฑ
ฑฑบ          ณ cTitulo: Novo Titulo                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAATF                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF155InHdr(aHeaderX,cCampo,cTitulo)
Local aArea		:= SX3->(GetArea())
Default cTitulo := ""

SX3->(DbSetOrder(2))
If SX3->(DbSeek(cCampo))
	cTitulo := Iif(Empty(cTitulo),X3Titulo(),cTitulo)
 	aAdd(aHeaderX,{;
		cTitulo,; 	  				// 01 - Titulo
		SX3->X3_CAMPO,;				// 02 - Campo
		SX3->X3_PICTURE,;			// 03 - Picture
		SX3->X3_TAMANHO,;			// 04 - Tamanho
		SX3->X3_DECIMAL,;			// 05 - Decimal
		SX3->X3_VALID,;				// 06 - Valid
		SX3->X3_USADO,;				// 07 - Usado
		SX3->X3_TIPO,;				// 08 - Tipo
		SX3->X3_F3,;				// 09 - F3
		SX3->X3_CONTEXT,;	   		// 10 - Contexto
		X3CBox(),;					// 11 - ComboBox
		SX3->X3_RELACAO,;			// 12 - Relacao
		SX3->X3_WHEN,;         		// 13 - When
		SX3->X3_VISUAL,;			// 14 - Visual
		SX3->X3_VLDUSER,;			// 15 - ValidUser
		SX3->X3_PICTVAR,;			// 16 - PictVar	
		X3Obrigat(SX3->X3_CAMPO)})	// 17 - Obrigat
EndIf
RestArea(aArea) 
Return  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF251AltHdบAutor  ณJair Ribeiro        บ Data ณ  05/19/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Altera aHeader                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aHeaderAlt: aHeader preenchido                             บฑฑ 
ฑฑบ          ณ cCampo: Campo a ser alterado no aHeader                    บฑฑ
ฑฑบ          ณ nAlt: Numerico indica que conteudo do aHeader deve ser	  บฑฑ
ฑฑบ          ณ alterado: 	01 - Titulo									  บฑฑ
ฑฑบ          ณ				02 - Campo									  บฑฑ
ฑฑบ          ณ				03 - Picture								  บฑฑ
ฑฑบ          ณ				04 - Tamanho								  บฑฑ
ฑฑบ          ณ				05 - Decimal								  บฑฑ
ฑฑบ          ณ				06 - Valid									  บฑฑ
ฑฑบ          ณ				07 - Usado									  บฑฑ
ฑฑบ          ณ				08 - Tipo									  บฑฑ
ฑฑบ          ณ				09 - F3									  	  บฑฑ
ฑฑบ          ณ				10 - Contexto								  บฑฑ
ฑฑบ          ณ				11 - ComboBox								  บฑฑ
ฑฑบ          ณ				12 - Relacao								  บฑฑ
ฑฑบ          ณ				13 - When									  บฑฑ
ฑฑบ          ณ				14 - Visual									  บฑฑ
ฑฑบ          ณ				15 - ValidUser								  บฑฑ
ฑฑบ          ณ				16 - PictVar								  บฑฑ
ฑฑบ          ณ				17 - Obrigat								  บฑฑ 
ฑฑบ          ณ xConteudo: Novo valor para conteudo do aHeader 			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAATF                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF155AltHd(aHeaderAlt,cCampo,nAlt,xConteudo)
Local nPos	:= aSCan(aHeaderAlt,{|aX| AllTrim(aX[2]) == AllTrim(cCampo)})
If nPos > 0  .and. (nAlt >= 1 .and. nAlt <= 17) 
	aHeaderAlt[nPos,nAlt]:= xConteudo
EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหออออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAFA155ITEMบAutor	 ณJair Ribeiro       บ Data ณ  05/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna Item (N1_ITEM) disponivel de acordo com codigo     บฑฑ
ฑฑบ          ณ base                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cFil: Filial                                               บฑฑ
ฑฑบ          ณ cBase: Codigo base                                         บฑฑ
ฑฑบ          ณ citem: Codigo do item                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบRetorno	 ณ cNewItem:Codigo de item disponivel                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAATF                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Static Function AFA155ITEM(cFil,cBase,cItem)
Local aArea		:= SN1->(GetArea())
Local cNewItem	:= STRZERO(0,TamSx3("N1_ITEM")[1])

Default cFil 	:= ""
Default cBase	:= ""
Default cItem	:= ""

If !Empty(cFil) .and. !Empty(cBase)
	cQry := " SELECT"+chr(13)+chr(10)
	cQry += " MAX(N1_ITEM) ITEM"+chr(13)+chr(10)
	cQry += " FROM "+RetSQlName("SN1")+ " N1 "+chr(13)+chr(10)
	cQry += " WHERE N1_FILIAL = '"+cFil+"'"+chr(13)+chr(10)
	cQry += " AND N1_CBASE = '"+cBase+"'"+chr(13)+chr(10)
	cQry += " AND N1.D_E_L_E_T_ <> '*' "
	
	cQry := ChangeQuery(cQry)
	
	If Select("SN1ITEM") > 0
		SN1ITEM->(DbCloseArea())
	Endif
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), "SN1ITEM", .T., .F.)
	If Empty(SN1ITEM->ITEM)
		cNewItem := IiF(Empty(cItem),Soma1(cNewItem),cItem)
	Else
		cNewItem := Soma1(SN1ITEM->ITEM)
	EndIf
	SN1ITEM->(DbCloseArea())
EndIf
          
SN1->(RestArea(aArea))
Return cNewItem
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณJair Ribeiro			ณ Data ณ29/11/06  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ		1 - Pesquisa e Posiciona em um Banco de Dados    	  ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetua							  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRotina :=	{{OemToAnsi(STR0033)	,"AxPesqui"		,0,1,0,.F.},; //"Pesquisar"
					{ OemToAnsi(STR0034)	,"VIEWDEF.ATFA012"	,0,2,0,nil},; //"Visualizar"
					{ OemToAnsi(STR0001)	,"FA155Ampl"	,0,4,0,nil},; //"Ampliacao"
					{ OemToAnsi(STR0035)	,"FA155Ampl"	,0,4,0,nil},; //"Estorno"
					{ OemToAnsi(STR0041)	,"CTBC662"  	,0,7,0,nil},; //"Tracker Contแbil"
					{ OemToAnsi(STR0003)	,"AtfLegenda"	,0,6,0,.F.}}	//"Legenda"
Return aRotina
Static Function AF155RetGet(oGetDadosC,nRet)
Local aRetorno	:= {}
If nRet == 1
	aRetorno := aClone(oGetDadosC:aHeader)
Else
	aRetorno := aClone(oGetDadosC:aCols)
EndIf
Return aRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF155G2	บAutor  ณMarcelo Akama       บ Data ณ  04/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida็ใo dos campos dos metodos de depreciacao gerencial   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF155G2(cField)
Local aHeaderX		:= Eval(bRetGet,1)
Local aColsX		:= Eval(bRetGet,2)
Local lRet 			:= .F.
Local nPosTpDepr 	:= Ascan(aHeaderX, {|x| Alltrim(x[2]) == "N3_TPDEPR" } )

DEFAULT cField := ReadVar()

If At("->",cField)>0
	cField := SubStr(cField,At("->",cField)+2,len(cField))
EndIf

If nPosTpDepr>0 .And. !Empty(&(ReadVar()))
	Do Case
		Case aColsX[n][nPosTpDepr]=='2'
			lRet := cField $ "N3_PERDEPR,N3_VLSALV1"
		Case aColsX[n][nPosTpDepr]=='3'
			lRet := cField $ "N3_PERDEPR"
		Case aColsX[n][nPosTpDepr]=='4'
			lRet := cField $ "N3_PRODMES,N3_PRODANO"
		Case aColsX[n][nPosTpDepr]=='5'
			lRet := cField $ "N3_PRODMES,N3_PRODANO"
		Case aColsX[n][nPosTpDepr]=='6'
			lRet := cField $ "N3_PERDEPR"
		Case aColsX[n][nPosTpDepr]=='7'
			lRet := cField $ "N3_VMXDEPR"
		Otherwise // =='1'
			lRet := .F.
	EndCase
	If !lRet
	 	Help( " ", 1, "AF155FDNTUS",,STR0037, 1, 0 )       //"Esse campo nใo ้ utilizado pelo m้todo de deprecia็ใo selecionado, o valor informado nใo serแ considerado."
	EndIf
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF155CONV	บAutor  ณMarcelo Akama       บ Data ณ  04/02/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida็ใo dos campos dos metodos de depreciacao gerencial   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF155CONV(oGetDados,aColsX)
Local nValor	:= &(ReadVar())
Local cCampo	:= ReadVar()
Local aHeaderX	:= aClone(oGetDados:aHeader)
Local nLinha	:= oGetDados:nAt
Local cMoedaAtf := GetMV("MV_ATFMOED")
Local lMultMoed := .T.


// Data de conversao das moedas para reavaliacao sera a data base.
Local dDtConv := If(aColsX[nLinha][Ascan(aHeaderX, {|e| Alltrim(e[2]) = "N3_TIPO"})]= "02",dDataBase,SN1->N1_AQUISIC)
Local nPosVOrigAtf := Ascan(aHeaderX, {|e| Alltrim(e[2]) = "N3_VORIG"+cMoedaAtf})

//********************************
// Controle de multiplas moedas  *
//********************************
Local __nQuantas := If(lMultMoed,AtfMoedas(),5)
Local aPosVOrigX:= If(lMultMoed,AtfMultPos(aHeaderX,"N3_VORIG"),;
					{ 	Ascan(aHeaderX	, {|e| Alltrim(e[2]) == "N3_VORIG1" } ),;
						Ascan(aHeaderX	, {|e| Alltrim(e[2]) == "N3_VORIG2" } ),;
						Ascan(aHeaderX	, {|e| Alltrim(e[2]) == "N3_VORIG3" } ),;
						Ascan(aHeaderX	, {|e| Alltrim(e[2]) == "N3_VORIG4" } ),;
						Ascan(aHeaderX	, {|e| Alltrim(e[2]) == "N3_VORIG5" } ) })
Local nX

// Nao converte as linhas de reavaliacao, pois ela ja foi convertida pela rotina Af010Valor
If Type("dDataAqui") == "U" .and. (!aColsX[nLinha][Ascan(aHeaderX, {|e| Alltrim(e[2]) = "N3_TIPO"})]$ "02|05" .or. !GetNewPar("MV_ZRADEPR",.F.))

	//********************************
	// Controle de multiplas moedas  *
	//********************************
	//Converte apenas com base na moeda 1, pois o valor do ativo na outra moeda nใo necessita ter base na cota็ใo do dia.
	If "N3_VORIG1" $ cCampo
		For nX := 2 to __nQuantas
			If aPosVOrigX[nX] > 0
				aColsX[nLinha][aPosVOrigX[nX]] := nValor / RecMoeda(dDtConv,nX)
				&("M->N3_VORIG"+AllTrim(Str(nX))) := aColsX[nLinha][aPosVOrigX[nX]]
			Endif
			If Type("SN1->N1_MOEDAQU") == "N" .And. Type("SN1->N1_TXMOEDA") == "N"
				If nX == SN1->N1_MOEDAQU
					aColsX[nLinha][aPosVOrigX[nX]] := nValor / If(Empty(SN1->N1_TXMOEDA),RecMoeda(dDtConv,nX),SN1->N1_TXMOEDA)
					&("M->N3_VORIG"+AllTrim(Str(nX))) := aColsX[nLinha][aPosVOrigX[nX]]
				Endif
			Endif
		Next
	EndIf

	If nPosVOrigAtf > 0 .And. ExistBlock("A30EMBRA")
		aColsX[nLinha][nPosVOrigAtf] := Iif(ExistBlock("A30EMBRA"),nValor/ExecBlock("A30EMBRA",.F.,.F.),nValor / RecMoeda(dDtConv,Val(cMoedaAtf)))
		&("M->N3_VORIG"+AllTrim(Str(Val(cMoedaAtf)))) := aColsX[nLinha][nPosVOrigAtf]
	Endif
Endif
Return .T.

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ AF155AGRP ณ Autor ณ TOTVS SA              ณ Data ณ 10.08.10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Preenche entidades contabeis no bem de acordo com grupo [SNG]ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ ATFA010                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF155AGRP(cEntidade)

Local cRetorno := ""
Local lErr	:= .F.
Local lSemIndice
Local nOrdem

If Type("M->N1_GRUPO") <> "U"
	lSemIndice := Upper( SubStr(SN3->(IndexKey()),1,26) ) <> "N3_FILIAL+N3_CBASE+N3_ITEM"
	If lSemIndice
		nOrdem := SN3->( IndexOrd() )
		SN3->( DbSetOrder(1) )
	EndIf
	SN3->(MsSeek(xFilial("SN3")+M->(N1_CBASE+N1_ITEM)))
	
	If ! Empty(M->N1_GRUPO)
		If SNG->NG_GRUPO <> M->N1_GRUPO
			SNG->(DbSeek(xFilial("SNG") + M->N1_GRUPO))
		Endif
		If SNG->(FieldPos("NG_" + Subs(cEntidade, 4))) > 0
			If Empty(&("SN3->N3_" + Subs(cEntidade, 4))) .OR. lCopia
				cRetorno := &("SNG->NG_" + Subs(cEntidade, 4))
			Else
				cRetorno := &("SN3->N3_" + Subs(cEntidade, 4))
			Endif
		Else
			lErr := .T.
		Endif
	else
		If cEntidade <> nil .and. TamSX3(cEntidade)[3] == "N"
			cRetorno := 0
		EndIf
	Endif
	If lSemIndice
		SN3->( DbSetOrder(nOrdem) )
	EndIf
Else
	If SNG->(FieldPos("NG_" + Subs(cEntidade, 4))) <> 0
		cRetorno := &("SN3->" + cEntidade)
	Else
		lErr := .T.
	Endif
Endif

// Alterado, caso nao exista o campo, o gatilho irแ retornar em branco 

Return cRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF155TXDP  บAutor  ณRenan Guedes      บ Data ณ  12/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo utilizada como WHEN dos campos de taxa da deprecia็ใoบฑฑ
ฑฑบ          ณN3_TXDEPR                                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF155TXDP(nLinha)

Local lRet			:= .T.
Local nPosN3TpDp 	:= Ascan(aHeader, {|e| Alltrim(e[2]) == "N3_TPDEPR" } )
Local cTpDepr 		:= ""

Default nLinha 		:= n

cTpDepr := IIf(nPosN3TpDp > 0, aCols[nLinha][nPosN3TpDp], '')

If cTpDepr == "A"
	lRet := .F.
EndIf

Return(lRet) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA155VLZERO Autor  ณ Adilson Soeiro     บ Data ณ  08/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Nใo permite altera็ใo no campo apos a inclusใo dif de vazioบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑณParametrosณExpC1 : Nome do campo existindo no aHeader                  ณฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function A155VLZERO(cNomeField)
// Local aArea		:= GetArea()
Local lRet := .T.
Local nPos := 0
Default cNomeField := " "

if ALTERA .and. !Empty(cNomeField)
	nPos:=Ascan( aHeader, {|e| Trim(e[2]) == cNomeField } )
	if nPos > 0 
   		lRet := Empty(aCols[n,nPos] )
	Endif
Endif
// RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF155AVlGrบAutor  ณAlvaro Camillo Neto  บ Data ณ  09/02/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida็ใo dos campos dos metodos de depreciacao gerencial   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF155AVlGr(cField)
Local lRet 			:= .F.
Local nPosTpDepr 	:= Ascan(aHeader, {|x| Alltrim(x[2]) == "N3_TPDEPR" } )
Local lAtfctap		:= IIF(GetNewPar("MV_ATFCTAP","0")=="0",.F.,.T.)

DEFAULT cField := ReadVar()

If At("->",cField)>0
	cField := SubStr(cField,At("->",cField)+2,len(cField))
EndIf

If nPosTpDepr>0 .And. !Empty(&(ReadVar()))
	Do Case
		Case aCols[n][nPosTpDepr]=='2'
			lRet := cField $ "N3_PERDEPR,N3_VLSALV1"
		Case aCols[n][nPosTpDepr]=='3'
			lRet := cField $ "N3_PERDEPR"
		Case aCols[n][nPosTpDepr]=='4'
			If lAtfctap
				lRet := cField $ "N3_PRODANO"
			Else
				lRet := cField $ "N3_PRODMES,N3_PRODANO"
			EndIf
		Case aCols[n][nPosTpDepr]=='5'
			If lAtfctap
				lRet := cField $ "N3_PRODANO"
			Else
				lRet := cField $ "N3_PRODMES,N3_PRODANO"
			EndIf
		Case aCols[n][nPosTpDepr]=='6'
			lRet := cField $ "N3_PERDEPR"
		Case aCols[n][nPosTpDepr]=='7'
			lRet := cField $ "N3_VMXDEPR"
		Case aCols[n][nPosTpDepr]=='8'
			lRet := cField $ "N3_PRODANO"
		Case aCols[n][nPosTpDepr]=='9'
			lRet := cField $ "N3_PRODANO"
		Otherwise // =='1'
			lRet := .F.
	EndCase
	If !lRet .And. !IsBlind()
		Help( " ", 1, "AF010FDNTUS",, STR0025, 1, 0 ) // "Esse campo nใo ้ utilizado pelo m้todo de deprecia็ใo selecionado, o valor informado nใo serแ considerado."
	EndIf
EndIf

AF155VLAEC()
/*
1-Linea	2-RedSl	3-SAnos	4-UnPrd	5-HrPrd	6-SDigi	7-LVlMx	8-ExLin	9-ExSld
N3_PERDEPR			   X	   X					   X
N3_VLSALV1			   X
N3_PRODMES							   X	   X
N3_PRODANO							   X	   X						X		X
N3_VMXDEPR													   X
*/
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณAF155VLAECณ Rev.  ณFernando Radu Muscalu  ณ Data ณ08.06.2011ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFuncao executa os calculos de depreciacao de acordo com os  ณฑฑ
ฑฑณ			 ณmetodos e o criterio de Exercicio Completo ("03")	para      ณฑฑ
ฑฑณ			 ณacumular os valores e retorna-los aos campos relacionados.  ณฑฑ
ฑฑณ			 ณEx: N3_VRDACM1										      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณAF010VLAEC(nLinha)				 		    			  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณnLinha - Numeric: Posicao da linha do aCols         		  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณTrue									    				  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณX3_VALID dos campos:										  ณฑฑ
ฑฑณ          ณN3_TXDEPR1												  ณฑฑ
ฑฑณ          ณN3_TXDEPR2												  ณฑฑ
ฑฑณ          ณN3_TXDEPR3												  ณฑฑ
ฑฑณ          ณN3_TXDEPR4												  ณฑฑ
ฑฑณ          ณN3_TXDEPR5 												  ณฑฑ
ฑฑณ          ณN3_TPDEPR 												  ณฑฑ
ฑฑณ          ณN3_CALDEPR 												  ณฑฑ
ฑฑณ          ณN3_CRIDEPR		 										  ณฑฑ
ฑฑณ          ณ					 										  ณฑฑ
ฑฑณ          ณNas funcoes do rdmake ATFA010A.PRW						  ณฑฑ
ฑฑณ          ณAF010AVLR(...)	 										  ณฑฑ
ฑฑณ          ณAF010AVlGr(...)	 										  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF155VLAEC(nLinha)

Local cFldAcum := ""
Local cFldAmpl := ""
Local cFldCAcm := ""

Local nQtdMo	:= 0
Local nI		:= 0
Local nMeses		:= 0
Local nPosAcum	:= 0
Local nPosAmpl	:= 0
Local nPosValor	:= 0
Local nPosTaxa	:= 0
Local nPosVar	:= 0
Local nPosCAcm	:= 0
Local nPosVrcda	:= 0
Local nPCriDepr	:= aScan(aHeader,{|x| alltrim(x[2]) == "N3_CRIDEPR"})
Local nPCalDepr	:= aScan(aHeader,{|x| alltrim(x[2]) == "N3_CALDEPR"})
Local nPTpDepr	:= aScan(aHeader,{|x| alltrim(x[2]) == "N3_TPDEPR"})
Local nPVmxDepr	:= aScan(aHeader,{|x| alltrim(x[2]) == "N3_VMXDEPR"})
Local nPPerDepr	:= aScan(aHeader,{|x| alltrim(x[2]) == "N3_PERDEPR"})
Local nPVlSalv1	:= aScan(aHeader,{|x| alltrim(x[2]) == "N3_VLSALV1"})
Local nPProdMes	:= aScan(aHeader,{|x| alltrim(x[2]) == "N3_PRODMES"})
Local nPProdAcm	:= aScan(aHeader,{|x| alltrim(x[2]) == "N3_PRODACM"})
Local nPProdAno	:= aScan(aHeader,{|x| alltrim(x[2]) == "N3_PRODANO"})
Local nPFimDepr	:= aScan(aHeader,{|x| alltrim(x[2]) == "N3_FIMDEPR"})
Local nPDInDepr		:= aScan(aHeader,{|x| alltrim(x[2]) == "N3_DINDEPR"})

Local aPeriodo	:= {}
Local aVlrAcum	:= {}
Local aVlrAmpl	:= {}
Local aVlrOrig	:= {}
Local aVlrCAcm	:= {}
Local aVlrCda	:= {}
Local aTaxaMes	:= {}
Local aTaxaAux	:= {}
Local aColsClon	:= {}
Local aParamN3	:= Array(9)
Local aCotaM	:= AtfMultMoe(,,{|x| 0})
Local aValores	:= {}

Local dDataCalc	:= stod("")

Local lRet		:= .T.
Local lResidual	:= .F.

Default nLinha := n // linha do acols para a MSGEtDados

If !(cPaisLoc $ "ARG|BRA|COS") .AND. (SN3->(FieldPos("N3_CRIDEPR")) == 0 .OR. SN3->(FieldPos("N3_CALDEPR")) == 0)
	Return(lRet)
Endif

If nPCriDepr == 0 .or. nPCalDepr == 0
	Return(lRet)
Endif

dDataCalc := M->N1_AQUISIC//dDataBase

aColsClon := aClone(aCols)

nPosVar := aScan(aHeader,{|x| alltrim(x[2]) == Alltrim(substr(ReadVar(),4)) })

If nPosVar > 0
	aColsClon[nLinha,nPosVar] := &(ReadVar())
Endif


If alltrim(aColsClon[nLinha,nPCriDepr]) == "03"
	
	If ( Alltrim(aColsClon[nLinha,nPTpDepr]) <> "8" .and. !Empty(aColsClon[nLinha,nPCalDepr]) ) .or. Alltrim(aColsClon[nLinha,nPTpDepr]) == "8"
		
		nQtdMo := AtfMoedas()
		
		For nI := 1 to nQtdMo
			
			If nI <= 9
				cFldAcum := "N3_VRDACM" + ALLTRIM(Str(nI))
				cFldAmpl := "N3_AMPLIA" + ALLTRIM(Str(nI))
				cFldCAcm := "N3_VRCACM" + ALLTRIM(Str(nI))
			Else
				cFldAcum := "N3_VRDAC" + ALLTRIM(Str(nI))
				cFldAmpl := "N3_AMPLI" + ALLTRIM(Str(nI))
				cFldCAcm := "N3_VRCAC" + ALLTRIM(Str(nI))
			Endif
			
			nPosAcum 	:= aScan(aHeader, {|x| alltrim(x[2]) == cFldAcum } )
			nPosAmpl	:= aScan(aHeader, {|x| alltrim(x[2]) == cFldAmpl } )
			nPosCAcm	:= aScan(aHeader, {|x| alltrim(x[2]) == cFldCAcm } )
			
			nPosVrcda	:= aScan(aHeader, {|x| alltrim(x[2]) == "N3_VRCDA" + Alltrim(Str(nI)) } )
			nPosValor	:= aScan(aHeader, {|x| alltrim(x[2]) == "N3_VORIG" + Alltrim(Str(nI)) } )
			nPosTaxa	:= aScan(aHeader, {|x| alltrim(x[2]) == "N3_TXDEPR" + Alltrim(Str(nI))})
			
			If nPosAcum > 0
				Iif(aColsClon[nLinha,nPosAcum] == nil,aColsClon[nLinha,nPosAcum] := CriaVar(cFldAcum), nil )
				
				//se houver valor acumulado, nao efetua nenhum calculo
				//If aColsClon[n,nPosAcum] > 0
				//	Return(.t.)
				//Endif
				
				aAdd(aVlrAcum,0)
			Endif
			
			If nPosAmpl > 0
				Iif(aColsClon[nLinha,nPosAmpl] == nil,aColsClon[nLinha,nPosAmpl] := CriaVar(cFldAmpl), nil )
				aAdd(aVlrAmpl,aColsClon[nLinha,nPosAmpl])
			Endif
			
			If nPosValor > 0
				Iif(aColsClon[nLinha,nPosValor] == nil,aColsClon[nLinha,nPosValor] := CriaVar("N3_VORIG" + ALLTRIM(Str(nI))), nil)
				aAdd(aVlrOrig,{aColsClon[nLinha,nPosValor],X3Decimal("N3_VORIG" + ALLTRIM(Str(nI)))})
			Endif
			
			If nPosTaxa > 0
				Iif(aColsClon[nLinha,nPosTaxa] == nil,aColsClon[nLinha,nPosTaxa] := CriaVar("N3_TXDEPR" + ALLTRIM(Str(nI))), nil)
				aAdd(aTaxaMes,aColsClon[nLinha,nPosTaxa])
			Endif
			
			If nPosCAcm > 0
				Iif(aColsClon[nLinha,nPosCAcm] == nil,aColsClon[nLinha,nPosCAcm] := CriaVar(cFldCAcm), nil)
				aAdd(aVlrCAcm, aColsClon[nLinha,nPosCAcm])
			Endif
			
			If nPosVrcda > 0
				Iif(aColsClon[nLinha,nPosVrcda] == nil,aColsClon[nLinha,nPosVrcda] := CriaVar("N3_VRCDA" + Alltrim(Str(nI))), nil)
				aAdd(aVlrCda, aColsClon[nLinha,nPosVrcda])
			Endif
			
		Next nI
		
		aPeriodo := AtfXPerCal(dDataCalc,aColsClon[nLinha,nPCriDepr],aColsClon[nLinha,nPCalDepr])
		
		//aPeriodo := IIf (Valtype(aPeriodo) == "L",{},aPeriodo)
		
		If ValType(aPeriodo) == "A"
			
			If dDataCalc >= aPeriodo[1] .and. dDataCalc <= aPeriodo[2]
				
				nMesAnt := Month(dDataCalc) - 1
				
				If nMesAnt == 0
					nMesAnt	:= 12
					nAno 	:= Year(dDataCalc)-1
				Else
					nAno	:= Year(dDataCalc)
				Endif
				
				dLastDepr	:= LastDay( stod(Alltrim(Str(nAno)) + StrZero(nMesAnt,2) + "01") )
				dDataDepr	:= LastDay(aPeriodo[1])
				
				aParamN3[1]	:= aVlrOrig[1,1]
				aParamN3[3]	:= 	Iif(nPTpDepr  > 0,aColsClon[nLinha,nPTpDepr] ,0)
				aParamN3[4]	:= 	Iif(nPvmxDepr > 0,aColsClon[nLinha,nPVmxDepr],0)
				aParamN3[5]	:= 	Iif(nPPerDepr > 0,aColsClon[nLinha,nPPerDepr],0)
				aParamN3[6]	:=	Iif(nPVlSalv1 > 0,aColsClon[nLinha,nPVlSalv1],0)
				aParamN3[7]	:=	Iif(nPProdMes > 0,aColsClon[nLinha,nPProdMes],0)
				aParamN3[8]	:=	Iif(nPProdAno > 0,aColsClon[nLinha,nPProdAno],0)
				aParamN3[9] :=	Iif(nPFimDepr > 0,aColsClon[nLinha,nPFimDepr],0)
				
				If Alltrim(aParamN3[3]) <> "8"
					
					If Alltrim(aParamN3[3]) == "9"
						If nPProdAcm > 0
							nMeses := DateDiffMonth(dLastDepr,dDataDepr) + 1
							aParamN3[7] := aColsClon[nLinha,nPProdAcm] / nMeses //Af010MedProd(aColsClon[n,nPProdAcm],dLastDepr,dDataDepr)
							//lResidual := .t.
						Endif
					Endif
					
					While dDataDepr <= dLastDepr
						
						aParamN3[2]	:= aVlrAcum[1]
						
						aTaxaAux := aClone(aTaxaMes)
						
						aTaxaMes := AFatorCalc(aTaxaMes,aPeriodo[1],dDataDepr,,,,aParamN3)
						
						aValores := {	aVlrOrig,;
						aVlrAcum,;
						aVlrAmpl,;
						aVlrCAcm,;
						aVlrCda }
						
						Af010CotaDepr(aTaxaMes,aCotaM,aParamN3,aValores,dDataDepr,,lResidual,nLinha)
						
						If !lResidual
							lResidual := ( Alltrim(aParamN3[3]) == "9" )
						Endif
						
						For nI := 1 to len(aCotaM)
							
							aVlrAcum[nI] += aCotaM[nI]
							
						Next nI
						
						aTaxaMes := aClone(aTaxaAux)
						
						dDataDepr := LastDay(LastDay(dDataDepr)+1)
					EndDo
				Else
					If nPProdAcm > 0
						
						ATFCalcVR(aColsClon[nLinha,nPProdAcm], aColsClon[nLinha,nPProdAno], @aTaxaMes)
						
						For nI := 1 to len(aVlrAcum)
							aVlrAcum[nI] := Round(aTaxaMes[nI] * aVlrOrig[nI,1],aVlrOrig[nI,2])
						Next nI
					Endif
				Endif
			Endif
		Else
			lRet := aPeriodo
		Endif
	Endif
	
	If lRet
		If Len(aVlrAcum) > 0
			For nI := 1 to len(aVlrAcum)
				
				If nI <= 9
					cFldAcum := "N3_VRDACM" + Alltrim(Str(nI))
				Else
					cFldAcum := "N3_VRDAC" + Alltrim(Str(nI))
				Endif
				
				If ( nPosAcum := aScan(aHeader, {|x| alltrim(x[2]) == cFldAcum } ) ) > 0
					aCols[nLinha,nPosAcum] := aVlrAcum[nI]
				Endif
			Next nI
		Endif
		
		If nPDInDepr > 0
			aCols[nLinha,nPDInDepr] := FirstDay(dDataCalc)
		Endif
		
	Endif
	
ElseIf alltrim(aColsClon[nLinha,nPCriDepr]) == "04"
	
	If nPDInDepr > 0
		
		aPeriodo := AtfXPerCal(dDataCalc,aColsClon[nLinha,nPCriDepr],aColsClon[nLinha,nPCalDepr])
		
		If ValType(aPeriodo) == "A"
			aCols[nLinha,nPDInDepr] := aPeriodo[1]
		Else
			lRet := aPeriodo
		Endif
	Endif
	
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLoad12ModelบAutor  ณgustavo.campos      บ Data ณ  12/11/2019บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para carregar o modelo de dados ao entrar na e      บฑฑ
ฑฑบ          ณ valida็ใo  AF012ACHCC quando entra no ATFA012,             บฑฑ
บฑฑ 		   via x3_valid		   										   ฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATF012                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ModelDef()
//Esta rotina nใo ้ MVC, mas utiliza o model da atfa012 para passar as informa็๕es necessarias
Local oModel 	:= FWLoadModel('ATFA012')

Return oModel


