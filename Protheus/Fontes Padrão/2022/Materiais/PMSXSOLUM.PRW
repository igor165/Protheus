#include "Protheus.ch"
#include "pmsxsolum.ch" 
#DEFINE VM_INSERT 08192  // Inclusao  de Registro
#DEFINE VM_UPDATE 16384  // Alteracao de Registro
#DEFINE VM_DELETE 32768  // Exclusao  de Registro

Static lVersao := (VAL(GetVersao(.F.)) == 11 .And. GetRpoRelease() > "R6" .Or. VAL(GetVersao(.F.)) > 11)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMSSOLUM  บAutor  ณReynaldo Miyashita  บ Data ณ  06/16/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para acionar as triggers das tabelas                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMSSOLUM( cAlias )
Local nColigada := 0
Local lMsgUnica	:= IsIntegTop()

nColigada := GetNewPar("MV_RMCOLIG",0) // coligada igual a empresa
If !lMsgUnica // nao deve carregar caso seja integracao via m.u.
// o conteudo sendo maior que zero, se refere a Coligada(empresa) no RM CORPORE que estแ associado a esta empresa/filial
	If nColigada > 0
		If     cAlias == "SB1"
			FldSettrigger( SB1->B1_FILIAL , VM_INSERT, { |cCpo,nOper| PMS_SB1(cCpo,nOper) } )
			FldSettrigger( SB1->B1_FILIAL , VM_UPDATE, { |cCpo,nOper| PMS_SB1(cCpo,nOper) } )
			// O Produto nใo serแ excluido somente Bloqueado.
		ElseIf cAlias == "SAH"
			FldSettrigger( SAH->AH_FILIAL , VM_INSERT, { |cCpo,nOper| PMS_SAH(nOper) } )
			FldSettrigger( SAH->AH_FILIAL , VM_UPDATE, { |cCpo,nOper| PMS_SAH(nOper) } )
		ElseIf cAlias == "SA1"
			FldSettrigger( SA1->A1_FILIAL , VM_INSERT, { |cCpo,nOper| PMS_SA1(nOper) } )
			FldSettrigger( SA1->A1_FILIAL , VM_UPDATE, { |cCpo,nOper| PMS_SA1(nOper) } )
			FldSettrigger( SA1->A1_FILIAL , VM_DELETE, { |cCpo,nOper| PMS_SA1(nOper) } )
		ElseIf cAlias == "SA2"
			FldSettrigger( SA2->A2_FILIAL , VM_INSERT, { |cCpo,nOper| PMS_SA2(nOper) } )
			FldSettrigger( SA2->A2_FILIAL , VM_UPDATE, { |cCpo,nOper| PMS_SA2(nOper) } )
			FldSettrigger( SA2->A2_FILIAL , VM_DELETE, { |cCpo,nOper| PMS_SA2(nOper) } )
		ElseIf cAlias == "SM2"
			FldSettrigger( SM2->M2_DATA   , VM_INSERT, { |cCpo,nOper| PMS_SM2(nOper) } )
			FldSettrigger( SM2->M2_DATA   , VM_UPDATE, { |cCpo,nOper| PMS_SM2(nOper) } )
			FldSettrigger( SM2->M2_DATA   , VM_DELETE, { |cCpo,nOper| PMS_SM2(nOper) } )
		ElseIf cAlias == "SBZ"
			FldSettrigger( SBZ->BZ_FILIAL , VM_INSERT, { |cCpo,nOper| PMS_SBZ(nOper) } )
			FldSettrigger( SBZ->BZ_FILIAL , VM_UPDATE, { |cCpo,nOper| PMS_SBZ(nOper) } )
			FldSettrigger( SBZ->BZ_FILIAL , VM_DELETE, { |cCpo,nOper| PMS_SBZ(nOper) } )
		ElseIf cAlias == "AFR"
			FldSettrigger( AFR->AFR_FILIAL, VM_INSERT, { |cCpo,nOper| PMS_AFR(nOper) } )
			FldSettrigger( AFR->AFR_FILIAL, VM_UPDATE, { |cCpo,nOper| PMS_AFR(nOper) } )
			FldSettrigger( AFR->AFR_FILIAL, VM_DELETE, { |cCpo,nOper| PMS_AFR(nOper) } )
		ElseIf cAlias == "SE4"
			FldSettrigger( SE4->E4_FILIAL , VM_INSERT, { |cCpo,nOper| PMS_SE4(nOper) } )
			FldSettrigger( SE4->E4_FILIAL , VM_UPDATE, { |cCpo,nOper| PMS_SE4(nOper) } )
		ElseIf cAlias == "CTT"
			FldSettrigger( CTT->CTT_FILIAL, VM_INSERT, { |cCpo,nOper| PMS_CTT(nOper) } )
			FldSettrigger( CTT->CTT_FILIAL, VM_UPDATE, { |cCpo,nOper| PMS_CTT(nOper) } )
		ElseIf cAlias == "SB2"
			FldSettrigger( SB2->B2_FILIAL, VM_INSERT, { |cCpo,nOper| PMS_SB2(nOper) } )
			FldSettrigger( SB2->B2_FILIAL, VM_UPDATE, { |cCpo,nOper| PMS_SB2(nOper) } )
		EndIf
	EndIf
Endif
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMSINTSOLUบAutor  ณReynaldo Miyashita  บ Data ณ  14/05/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida se o parametro de integracao com o TOP               บฑฑ
ฑฑบ          ณesta ativo e os campos necessarios devidamente criados e    บฑฑ
ฑฑบ          ณconfigurados.                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PMSINTSOLUM()
Local nCount    := 0
Local nColigada := 0
Local nSolumConn := 0
Local cTexto    := ""
Local cFile     :=""
Local cMask     := "Documentos de texto (*.txt)|*.txt|"
Local aFieldID  := {}
Local aAreaSX3  := {}
Local aAreaTMP  := {}
Local aErros    := {}
Local oDlg
Local oMemo
Local lRet := .T.
Local lLimbo := .T.
Local cAlias := ""
Local lPmsInt :=IsIntegTop(,.T.)//verifica se estแ integrado com PMS
Local lMsgUnica	:= IsIntegTop()
nColigada := GetNewPar("MV_RMCOLIG",0) // coligada igual a empresa

// o conteudo sendo maior que zero, se refere a Coligada(empresa) no TOP que estแ associado a esta empresa/filial
If	lPmsInt

	If !IntePMS() // Se a integra็ใo estiver desativada, a integra็ใo com os outros modulos do protheus nใo funciona.
		aAdd(aErros ,STR0001) //"O parametro MV_INTPMS nใo estแ configurado como 'S'. Verifique em parametros do sistema."
	EndIf

	//
	// retorna os campos que devem existir na base de dados
	//
	//nao deve retornar campos quando msngunica na 11.8
	If lMsgUnica
		aFieldID:={}
	Else
		aFieldID := aClone(PMSFldSlm())
	Endif

	aAreaSX3 := SX3->(GetArea())
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	// Busca a existencia do campo atrav้s do alias informado
	For nCount := 1 to Len(aFieldID)
		// verifica se o registro existe no dicionario
		If SX3->(dbSeek(aFieldID[nCount,02]))
			If Empty(SX3->X3_ARQUIVO)
				aAdd(aErros ,STR0002 + " " + aFieldID[nCount,01]+ " " + STR0003)//"A Tabela " " nใo foi encontrada no dicionario de dados."
			Else
				If SX3->X3_ARQUIVO <> aFieldID[nCount,01]
					aAdd(aErros ,STR0004 + " " + aFieldID[nCount,02] + " " + STR0005 + " " +SX3->X3_ARQUIVO + " " + STR0006)//"O campo " " estแ incorretamente na tabela " " conforme dicionario de dados."
				Else
					// verifica se o campo faz parte da tabela
					dbSelectArea(SX3->X3_ARQUIVO)
					aAreaTMP := (SX3->X3_ARQUIVO)->(GetArea())
					If (SX3->X3_ARQUIVO)->(FieldPos(aFieldID[nCount,02])) <=0
						aAdd(aErros ,STR0004 + " " +aFieldID[nCount,02]+ " " + STR0007 + " " + cAlias+ " " + STR0006)//"O campo " " nใo foi encontrada na tabela " " conforme dicionario de dados."
					EndIf
					RestArea(aAreaTMP)
				EndIf
			EndIf
		Else
			aAdd(aErros ,STR0004 + " " +aFieldID[nCount,02]+ " " + STR0003)//"O campo " " nใo foi encontrado no dicionario de dados."
		EndIf

	Next nCount

	//
	// verifica se o campo AF9_TAREFA ้ igual ou superior a 50 caracteres, pois o solum aceita at้ 60 caracteres na versใo 10.70
	// Deve informar ao usuario que deve ser alterado o tamanho do campo atrav้s do grupo de campo 014
	If TamSX3("AF9_TAREFA")[1] <50
		aAdd(aErros ,STR0008)//"O tamanho do campo EDT/Tarefa estแ configurado incorretamente. Deve ser alterar o grupo de campo 014 para tamnho de 50."
	EndIf

	// Pega a conexao do ByYouDBAccess corrente do TOP
	If !(lMsgUnica)
		nSolumConn := CnnSolum(.F.)

		If (nSolumConn>0)
			TCUnLink(nSolumConn)
		Else
			aAdd(aErros ,STR0009)//"Erro na configura็ใo ou conexใo do ByYouDBAccess para a base de dados do TOP."
		EndIf
	Endif
	If Len(aErros) > 0
		lRet := .F.
		If IsBlind()
			ConOut(STR0010) //"*** Integra็ใo Erp Microsiga Protheus x TOP ***"
			ConOut(STR0011 + " " +dtoc(date()) + " " + time())//"Ocorrencia gerada: "
			For nCount := 1 to len(aErros)
				PMSRMSOLUMLOG(aErros[nCount])
			Next nCount
			ConOut(STR0010)//"*** Integra็ใo Erp Microsiga Protheus x TOP ***"
		Else
			cTexto := STR0011 + " " +dtoc(date()) + " " + time()+CHR(10)+CHR(13)//"Ocorrencia gerada: "
			For nCount := 1 to len(aErros)
				cTexto += aErros[nCount]+CHR(10)+CHR(13)
			Next nCount

			DEFINE MSDIALOG oDlg TITLE STR0010 From 3,0 to 340,417 PIXEL //"*** Integra็ใo Erp Microsiga Protheus x TOP ***"
			@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL READONLY
			oMemo:bRClicked := {||AllwaysTrue()}
			oMemo:oFont := oDlg:oFont

			DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL
			DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL

			ACTIVATE MSDIALOG oDlg CENTER

			Final(STR0012)//"Inconsistencias na integra็ใo Microsiga Protheus x TOP"
		EndIf
	Else
		conOut("["+dtoc(date())+" "+time()+"]"+" " + STR0010+ " " +"<"+LogUserName()+", "+ComputerName()+">")//Integracao ERP Microsiga Protheus x TOP.
	EndIf

EndIf

// se as configura็๕es foram efetuadas corretamente, deve verificar se os parametros foram
//configurados caso contrario deve somente advertir para corrigir.
If lRet .and. lPmsInt
	//
	//  NAO EH PRA TRATAR O RETORNO DA FUNCAO SLMVldMV()
	///
	lLimbo := SLMVldMV()
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ SLMVldMV บAutor  ณReynaldo Miyashita  บ Data ณ  06/16/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se os parametros de sistema foram                   บฑฑ
ฑฑบ          ณ criados e configurados                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SLMVldMV()
Local lRet := .T.
Local cConteud := ""
Local cMensagem := ""
Local aAreaTmp := {}

// verifica se o parametro MV_SLMCOND foi cadastrado e parametrizado
If (cConteud:=Alltrim(GetNewPar("MV_SLMCOND" ,"")))<>""
	//
	// Condicao de Pagamento
	//
	dbSelectArea("SE4")
	aAreaTmp := GetArea()
	dbSetOrder(1)
	If !dbSeek(xFilial("SE4")+cConteud)
		cMensagem := STR0013 //"Aten็ใo!!! A condi็ใo de pagamento configurado no parametro de sistema MV_SLMCOND nใo existe. Verifique."
		PMSRMSOLUMLOG(cMensagem)

		If !IsBlind()
			Aviso(STR0010,  cMensagem, {"OK"}, 2) //"Integra็ใo do TOP com ERP Protheus"
		EndIf
		lRet := .F.
	EndIf
	RestArea(aAreaTmp)

Else
	cMensagem := STR0013 //"O parametro de sistema MV_SLMCOND nใo foi configurado corretamente. Verifique."
	PMSRMSOLUMLOG(cMensagem)

	If !IsBlind()
		Aviso(STR0010,  cMensagem, {"OK"}, 2) //"Integra็ใo do TOP com ERP Protheus"
	EndIf
	lRet := .F.
EndIf

If !(cPaisLoc $"BRA")// verifica se o parametro MV_RMCCUST foi cadastrado e parametrizado
	If (cConteud:=AllTrim(GetNewPar("MV_RMCCUST" ,"")))<>""
		//
		// Centro de custo padrใo utilizado na integra็ใo com o localizado
		//
		dbSelectArea("CTT")
		aAreaTmp := GetArea()
		dbSetOrder(1)
		If !dbSeek(xFilial("CTT")+cConteud)
			cMensagem := STR0077 //"Aten็ใo!!! O Centro de Custo configurado no parametro de sistema MV_RMCCUST nใo existe. Verifique."
			PMSRMSOLUMLOG(cMensagem)

			If !IsBlind()
				Aviso(STR0066, cMensagem, {"OK"}, 2)//"Integra็ใo do TOP com ERP Protheus"
			EndIf
			lRet := .F.
		EndIf
		RestArea(aAreaTmp)

	Else
		cMensagem := STR0078 //"O parametro de sistema MV_RMCCUST nใo foi configurado corretamente. Verifique."
		PMSRMSOLUMLOG(cMensagem)

		If !IsBlind()
			Aviso(STR0066,  cMensagem, {"OK"}, 2)//"Integra็ใo do TOP com ERP Protheus"
		EndIf
		lRet := .F.
	EndIf
Endif






// verifica se o parametro MV_SLMTS foi cadastrado e parametrizado
If (cConteud:=AllTrim(GetNewPar("MV_SLMTS" ,"")))<>""
	//
	// Tipo de Entrada e Saida
	//
	dbSelectArea("SF4")
	aAreaTmp := GetArea()
	dbSetOrder(1)
	If !dbSeek(xFilial("SF4")+cConteud)
		cMensagem := STR0014 //"Aten็ใo!!! A Tipo de Saida configurado no parametro de sistema MV_SLMTS nใo existe. Verifique."
		PMSRMSOLUMLOG(cMensagem)

		If !IsBlind()
			Aviso(STR0010, cMensagem, {"OK"}, 2) //"Integra็ใo do TOP com ERP Protheus"
		EndIf
		lRet := .F.
	EndIf
	RestArea(aAreaTmp)

Else
	cMensagem := STR0014 //"O parametro de sistema MV_SLMTS nใo foi configurado corretamente. Verifique."
	PMSRMSOLUMLOG(cMensagem)

	If !IsBlind()
		Aviso(STR0010,  cMensagem, {"OK"}, 2) //"Integra็ใo do TOP com ERP Protheus"
	EndIf
	lRet := .F.
EndIf

// verifica se o parametro MV_PMSNATP foi cadastrado e parametrizado
If (cConteud:=AllTrim(GetNewPar("MV_SLMNATP" ,"")))<>""
	//
	// Natureza
	//
	dbSelectArea("SED")
	aAreaTmp := GetArea()
	dbSetOrder(1)
	If !dbSeek(xFilial("SED")+cConteud)
		cMensagem := STR0015 //"Aten็ใo!!! A Natureza Padrใo para titulos a pagar configurado no parametro de sistema MV_SLMNATP nใo existe. Verifique."
		PMSRMSOLUMLOG(cMensagem)

		If !IsBlind()
			Aviso(STR0010, cMensagem, {"OK"}, 2) //"Integra็ใo do TOP com ERP Protheus"
		EndIf
		lRet := .F.
	EndIf
	RestArea(aAreaTmp)

Else
	cMensagem := STR0015 //"O parametro de sistema MV_SLMNATP nใo foi configurado corretamente. Verifique."
	PMSRMSOLUMLOG(cMensagem)

	If !IsBlind()
		Aviso(STR0010,  cMensagem, {"OK"}, 2) //"Integra็ใo do TOP com ERP Protheus"
	EndIf
	lRet := .F.
EndIf

// verifica se o parametro MV_PMSNATR foi cadastrado e parametrizado
If (cConteud:=AllTrim(GetNewPar("MV_SLMNATR" ,"")))<>""
	//
	// Natureza
	//
	dbSelectArea("SED")
	aAreaTmp := GetArea()
	dbSetOrder(1)
	If !dbSeek(xFilial("SED")+cConteud)
		cMensagem := STR0016 //"Aten็ใo!!! A Natureza Padrใo para titulos a receber configurado no parametro de sistema MV_SLMNATR nใo existe. Verifique."
		PMSRMSOLUMLOG(cMensagem)

		If !IsBlind()
			Aviso(STR0010, cMensagem, {"OK"}, 2) //"Integra็ใo do TOP com ERP Protheus"
		EndIf
		lRet := .F.
	EndIf
	RestArea(aAreaTmp)

Else
	cMensagem := STR0017 //"O parametro de sistema MV_SLMNATR nใo foi configurado corretamente. Verifique."
	PMSRMSOLUMLOG(cMensagem)

	If !IsBlind()
		Aviso(STR0010,  cMensagem, {"OK"}, 2) //"Integra็ใo do TOP com ERP Protheus"
	EndIf
	lRet := .F.
EndIf

// verifica se o parametro MV_SLMPROP (cod. produto padrao TOP) foi cadastrado e parametrizado
If Empty( GetMV("MV_SLMPROP", .F., " ") )
	cMensagem := STR0018 //"O parametro de sistema MV_SLMPROP nใo foi configurado corretamente. Verifique."
	PMSRMSOLUMLOG(cMensagem)

	If !IsBlind()
		Aviso(STR0010,  cMensagem, {"OK"}, 2) //"Integra็ใo do TOP com ERP Protheus"
	EndIf
	lRet := .F.
EndIf

// verifica se o parametro MV_SLMCOMP foi cadastrado e parametrizado
If Empty( GetMV("MV_SLMCOMP", .F., " ") )
	cMensagem := STR0019 //"O parametro de sistema MV_SLMCOMP nใo foi configurado corretamente. Verifique."
	PMSRMSOLUMLOG(cMensagem)

	If !IsBlind()
		Aviso(STR0010,  cMensagem, {"OK"}, 2) //"Integra็ใo do TOP com ERP Protheus"
	EndIf
	lRet := .F.
EndIf

// verifica se o parametro MV_SLMNTPV foi cadastrado e parametrizado
// O conteudo podera ser uma funcao, ponto de entrada ou nome de campo
If Empty( GetMV("MV_SLMNTPV", .F., " ") )
	cMensagem := STR0020 //"O parametro de sistema MV_SLMNTPV nใo foi configurado corretamente. Verifique."
	PMSRMSOLUMLOG(cMensagem)

	If !IsBlind()
		Aviso(STR0010,  cMensagem, {"OK"}, 2) //"Integra็ใo do TOP com ERP Protheus"
	EndIf
	lRet := .F.
EndIf

//
// Tipo de Materiais - Tabela gererica SX5 - 02
//
dbSelectArea("SX5")
aAreaTmp := GetArea()
dbSetOrder(1)
If !dbSeek(xFilial("SX5")+ "02" +  PadR( "MO", len(SX5->X5_CHAVE), " ") )
	cMensagem := STR0021 //"Aten็ใo!!! O tipo de Materiais 'MO' (mao de obra) nao esta cadastrado na tabela SX5. Verifique."
	PMSRMSOLUMLOG(cMensagem)

	If !IsBlind()
		Aviso(STR0010, cMensagem, {"OK"}, 2) //"Integra็ใo do TOP com ERP Protheus"
	EndIf
	lRet := .F.
EndIf
RestArea(aAreaTmp)


// RETORNA SEMPRE TRUE
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMS_SB1   บAutor  ณReynaldo Miyashita  บ Data ณ  02/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza na tabela TPRD de produtos do TOP                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMS_SB1(cCpo,nOper)
Local cQuery     := ""
Local nColigada  := GetNewPar("MV_RMCOLIG",0) // coligada igual a empresa
Local aAreaSAH   := {}
Local aTamSX3    := {}
Local aColig     := {}
Local aAreaSB2 	 := {}
Local nCnt       := 0
Local nERPConn   := 0
Local nSolumConn := -1
Local nCustMed	 := 0
Local nCustD     := 0
Local nUPrcCom   := 0
Local lPMRMCOLIG := ExistBlock("PMRMCOLIG")
Local aArea		 := GetArea()
Local lMsgUnica	:= IsIntegTop()

If !(lMsgUnica)
	// define a coligada a qual o produto vai ser replicado na base RM
	aAdd(aColig ,nColigada)

	// Pega a conexao do ByYouDBAccess corrente do Protheus
	nERPConn := AdvConnection()

	// Pega a conexao do ByYouDBAccess corrente do TOP
	nSolumConn := CnnSolum()

	// se houver conexao do ByYouDBAccess com o TOP
	If (nSolumConn>0)
		tcSetConn(nERPConn) //alterado por Jandir Deodato 28/11/11
		dbSelectArea("SAH")
		aAreaSAH := GetArea()
		dbSetOrder(1)
		// efetua a conexao ByYouDBAccess com o banco de dados TOP
		tcSetConn(nSolumConn)
		TcInternal( 8, STR0022 ) //"Sincronizacao Microsiga Protheus x TOP"

		// insere a unidade de medida

		If dbSeek(xFilial("SAH")+SB1->B1_UM)

			If UPPER(tcgetdb()) == "ORACLE"
				cQuery := "BEGIN "
				If TCSPExist("SP_UNIDMED_TOPPROT")
					cQuery += "SP_UNIDMED_TOPPROT ("
				Else
					cQuery += "sp_Unidade_Solum_Protheus ("
				Endif

				cQuery += "  '" + SAH->AH_UNIMED +"' "
				cQuery += ", '" + FmtStrPrc(SAH->AH_DESCPO) + "' "
				cQuery += ", 0 ); END;" // -- 0.ATIVO / 1.INATIVO

			Else
				cQuery := ""
				If TCSPExist("SP_UNIDMED_TOPPROT")
					cQuery += "SP_UNIDMED_TOPPROT "
				Else
					cQuery += "sp_Unidade_Solum_Protheus "
				Endif
				cQuery += " @CodUnd  = '"   + AllTrim(SAH->AH_UNIMED) + "' "
				cQuery += ",@Descricao = '" + FmtStrPrc(SAH->AH_DESCPO) + "' "
				cQuery += ",@TipoMovimento = 0 " // -- 0.ATIVO / 1.INATIVO

			Endif
			// Executa a Query no Banco
			PMSExecSOLUM(cQuery)

		Else
			PMSRMSOLUMLOG(STR0023)//"Erro na integra็ใo: Nใo encontrado unidade de medida do produto"
		EndIf

		// Se a conexao ByYouDBAccess for maior que zero, deve desconectar
		If nSolumConn >0
			TCUnLink(nSolumConn)
		EndIf
		// volta pra conexao ByYouDBAccess Padrao
		tcSetConn(nERPConn)

	Endif


	RestArea(aAreaSAH)

	// Procura valor do custo m้dio deste produto
	dbSelectArea("SB2")
	aAreaSB2 := GetArea()
	dbSetOrder(1)
	If dbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)
		nCustMed := SB2->B2_CM1
	Endif
	RestArea(aAreaSB2)

	// Procura valor do custo standard e ultimo preco de compra
	nCustD := SB1->(xMoeda(RetFldProd(B1_COD,"B1_CUSTD"),Val(RetFldProd(B1_COD,"B1_MCUSTD")),1,RetFldProd(B1_COD,"B1_UCALSTD")))
	nUPrcCom := RetFldProd(SB1->B1_COD,"B1_UPRC")

	// Pega a conexao do ByYouDBAccess corrente do Protheus
	nERPConn := AdvConnection()

	// Carrega as coligadas
	If lPMRMCOLIG
		aColig:= ExecBlock("PMRMCOLIG",.F.,.F.,{"SB1",aColig})
		// Retorna a conexao do ByYouDBAccess corrente do Protheus
		tcSetConn(nERPConn)
	EndIf

	// Pega a conexao do ByYouDBAccess corrente do TOP
	nSolumConn := CnnSolum()

	// se houver conexao do ByYouDBAccess com o TOP
	If (nSolumConn>0)

		// efetua a conexao ByYouDBAccess com o banco de dados TOP
		tcSetConn(nSolumConn)
		TcInternal( 8, STR0022 )//"Sincronizacao Microsiga Protheus x TOP"

		For nCnt := 1 to len(aColig)

			If UPPER(tcgetdb()) == "ORACLE"
				cQuery := "BEGIN "
				If TCSPExist("SP_PRODUTO_TOPPROT")
					cQuery += "SP_PRODUTO_TOPPROT ("
					If ValType(aColig[1]) == "N"
						cQuery +=  AllTrim(Str(aColig[nCnt])) + " "
						cQuery += ", '" + PADR(cFilAnt,LEN(SM0->M0_CODFIL)) + "' "  // a empresa se relaciona com a coligada e as filial sใo iguais
					Elseif ValType(aColig[1]) == "A"
						cQuery +=  AllTrim(Str(aColig[nCnt,1])) + " "
						If Empty(aColig[nCnt,2])
							cQuery += ", '" + PADR(cFilAnt,LEN(SM0->M0_CODFIL)) + "' "  // a empresa se relaciona com a coligada e as filial sใo iguais
						Else
							cQuery += ", '" + PADR(aColig[nCnt,2],LEN(SM0->M0_CODFIL)) + "' "  // a empresa se relaciona com a coligada e as filial sใo iguais
						Endif
					Endif
					cQuery += ", '" + Alltrim(SB1->B1_COD)  + "' "
					cQuery += ", '" + FmtStrPrc(SB1->B1_DESC) + "' "
					cQuery += ", '" + Alltrim(SB1->B1_UM)   + "' "
					cQuery += ", " + iIf((nOper==VM_DELETE .OR. Alltrim(SB1->B1_MSBLQL)=="1") ,"1" ,"0") + " " // -- 0.ATIVO / 1.INATIVO

					aTamSX3 := TamSX3("B1_CUSTD")
					cQuery += ", " + Str(nUPrcCom,aTamSX3[1],aTamSX3[2]) + " "

					aTamSX3 := TamSX3("B1_PRV1")
					cQuery += ", " + Str(SB1->B1_PRV1,aTamSX3[1],aTamSX3[2]) + " "

					cQuery += ", '" + iif(Trim(SB1->B1_TIPO)="MO", "S", "P") + "' "

					aTamSX3 := TamSX3("B2_CM1")
					cQuery += ", " + Str(nCustMed,aTamSX3[1],aTamSX3[2]) + " "

					cQuery += ", '" + SB1->B1_SEGUM		+ "' "
					cQuery += ", " + str(SB1->B1_CONV)+ " "
					cQuery += ", '" + SB1->B1_TIPCONV	+ "' "

					aTamSX3 := TamSX3("B1_CUSTD")
					cQuery += ", " + Str(nCustD,aTamSX3[1],aTamSX3[2]) + " "
					cQuery += "); END ;"

				Else
					cQuery += "sp_produto_Solum_Protheus ("
					If ValType(aColig[1]) == "N"
						cQuery +=  AllTrim(Str(aColig[nCnt])) + " "
						cQuery += ", '" + PADR(cFilAnt,LEN(SM0->M0_CODFIL)) + "' "  // a empresa se relaciona com a coligada e as filial sใo iguais
					Elseif ValType(aColig[1]) == "A"
						cQuery +=  AllTrim(Str(aColig[nCnt,1])) + " "
						If Empty(aColig[nCnt,2])
							cQuery += ", '" + PADR(cFilAnt,LEN(SM0->M0_CODFIL)) + "' "  // a empresa se relaciona com a coligada e as filial sใo iguais
						Else
							cQuery += ", '" + PADR(aColig[nCnt,2],LEN(SM0->M0_CODFIL)) + "' "  // a empresa se relaciona com a coligada e as filial sใo iguais
						Endif
					Endif
					cQuery += ", '" + Alltrim(SB1->B1_COD)  + "' "
					cQuery += ", '" + FmtStrPrc(SB1->B1_DESC) + "' "
					cQuery += ", '" + Alltrim(SB1->B1_UM)   + "' "
					cQuery += ", '" + iIf((nOper==VM_DELETE .OR. Alltrim(SB1->B1_MSBLQL)=="1") ,"1" ,"0") + "' " // -- 0.ATIVO / 1.INATIVO

					aTamSX3 := TamSX3("B1_CUSTD")
					cQuery += ", '" + Str(nUPrcCom,aTamSX3[1],aTamSX3[2]) + "' "

					aTamSX3 := TamSX3("B1_PRV1")
					cQuery += ",  " + AllTrim(Str(SB1->B1_PRV1,aTamSX3[1],aTamSX3[2])) + " "

					cQuery += ", '" + iif(Trim(SB1->B1_TIPO)="MO", "S", "P") + "' "

					aTamSX3 := TamSX3("B2_CM1")
					cQuery += ",  " + AllTrim(Str(nCustMed,aTamSX3[1],aTamSX3[2])) + " "

					cQuery += ", '" + SB1->B1_SEGUM		+ "' "
					cQuery += ",  " + Alltrim(str(SB1->B1_CONV))	+ " "
					cQuery += ", '" + SB1->B1_TIPCONV	+ "' "

					aTamSX3 := TamSX3("B1_CUSTD")
					cQuery += ",  " + AllTrim(Str(nCustD,aTamSX3[1],aTamSX3[2])) + " "
					cQuery += "); END ;"
				Endif
			Else
				cQuery := ""
				If TCSPExist("SP_PRODUTO_TOPPROT")
					cQuery += "SP_PRODUTO_TOPPROT "
				Else
					cQuery += "sp_produto_Solum_Protheus "
				Endif
				If ValType(aColig[1]) == "N"
					cQuery += "@CodColigada = " + AllTrim(Str(aColig[nCnt])) + " "
					cQuery += ",@Codfilial = '" + PADR(cFilAnt,LEN(SM0->M0_CODFIL)) + "' " // a empresa se relaciona com a coligada e as filial sใo iguais
				Elseif ValType(aColig[1]) == "A"
					cQuery += "@CodColigada = " + AllTrim(Str(aColig[nCnt,1])) + " "
					If Empty(aColig[nCnt,2])
						cQuery += ",@Codfilial = '" + PADR(cFilAnt,LEN(SM0->M0_CODFIL)) + "' " // a empresa se relaciona com a coligada e as filial sใo iguais
					Else
						cQuery += ",@Codfilial = '" + PADR(aColig[nCnt,2],LEN(SM0->M0_CODFIL)) + "' " 
					Endif
				Endif
				cQuery += ",@CodigoPrd = '" + Alltrim(SB1->B1_COD) + "' "
				cQuery += ",@Nome = '"      + FmtStrPrc(SB1->B1_DESC) + "' "
				cQuery += ",@Unidade = '"   + AllTrim(SB1->B1_UM)    + "' "
				cQuery += ",@Inativo = "    + iIf((nOper==VM_DELETE .OR. Alltrim(SB1->B1_MSBLQL)=="1") ,"1" ,"0")  // -- 0.ATIVO / 1.INATIVO

				aTamSX3 := TamSX3("B1_CUSTD")
				cQuery += ",@PPrecoCusto = '" + AllTrim(Str(nUPrcCom,aTamSX3[1],aTamSX3[2])) + "' "

				aTamSX3 := TamSX3("B1_PRV1")
				cQuery += ",@PPrecoVenda = " + AllTrim(Str(SB1->B1_PRV1,aTamSX3[1],aTamSX3[2])) + " "

				cQuery += ",@Tipo = '" + iif(Trim(SB1->B1_TIPO)="MO", "S", "P") + "' "

				aTamSX3 := TamSX3("B2_CM1")
				cQuery += ",@PCustoMedio = " + AllTrim(Str(nCustMed,aTamSX3[1],aTamSX3[2])) + " "

				cQuery += ",@UnidadeBase = '"    +AllTrim(SB1->B1_SEGUM)     + "' "
				cQuery += ",@PFatorConversao = " +Alltrim(str(SB1->B1_CONV)) + " "
				cQuery += ",@TipoConversao =  '" +Alltrim(SB1->B1_TIPCONV)   + "' "

				aTamSX3 := TamSX3("B1_CUSTD")
				cQuery += ",@PCustoStandart = "  +AllTrim(Str(nCustD,aTamSX3[1],aTamSX3[2])) + " "

			EndIf

			PMSExecSOLUM(cQuery)

		Next nCnt

		// Se a conexao ByYouDBAccess for maior que zero, deve desconectar
		If nSolumConn >0
			TCUnLink(nSolumConn)
		EndIf
		// volta pra conexao ByYouDBAccess Padrao
		tcSetConn(nERPConn)
	Endif
Endif
RestArea(aArea)
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMS_SB2   บAutor  ณ Andre Anjos		 บ Data ณ  02/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณAtualiza na tabela de custos do produto do TOP              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMS_SB2(nOper)
Local cQuery 	 := ""
Local nERPConn 	 := 0
Local nSolumConn := -1
Local nX		 := 1
Local nCustoUnit		:= 0
Local nCustoTot		:= 0
Local aTamSB2	 := TamSX3("B2_CM1")
Local aColig	 := {GetNewPar("MV_RMCOLIG",0)}
Local lMsgUnica	:= IsIntegTop()
Local cCusFil		:= SuperGetMV("MV_CUSFIL",.F.,"A")
Local aAreaSB2	 := SB2->(Getarea()) 

If !lMsgUnica
	nCustoUnit := PmsxVatu1(SB2->B2_COD)
	nCustoTot := PmsxVatu1(SB2->B2_COD,.F.)
	nERPConn := AdvConnection() 	//-- Pega a conexao do ByYouDBAccess corrente do Protheus

	//-- Carrega as coligadas por PE
	If ExistBlock("PMRMCOLIG")
		aColig := ExecBlock("PMRMCOLIG",.F.,.F.,{"SB2",aColig})
		TCSetConn(nERPConn) //-- Retorna a conexao do ByYouDBAccess corrente do Protheus
	EndIf

	nSolumConn := CnnSolum()		//-- Pega a conexao do ByYouDBAccess corrente do TOP

	//-- Se houver conexao do ByYouDBAccess com o TOP
	If nSolumConn > 0
		// efetua a conexao ByYouDBAccess com o banco de dados TOP
		TCSetConn(nSolumConn)
		TCInternal(8,STR0022) //"Sincronizacao Microsiga Protheus x TOP"

		If TCSPExist("SP_CUSTO_FILIAL")
			For nX := 1 To Len(aColig)
				If Upper(TCGetDB()) == "ORACLE"
					cQuery := "BEGIN SP_CUSTO_FILIAL("
					If ValType(aColig[1]) == "N"
						cQuery += "'" +AllTrim(Str(aColig[nX])) +"',"
						cQuery += "'" +PadR(cFilAnt,Len(SM0->M0_CODFIL)) +"',"
					Elseif ValType(aColig[1]) == "A"
						cQuery += "'" +AllTrim(Str(aColig[nX,1])) +"',"
						If Empty(aColig[nX,2])
							cQuery += "'" +PadR(cFilAnt,Len(SM0->M0_CODFIL)) +"',"
						Else
							cQuery += "'" +PadR(aColig[nX,2],Len(SM0->M0_CODFIL)) +"',"
						Endif
					Endif
					cQuery += "'" +AllTrim(SB2->B2_COD) +"',"
					If cCusFil == "A" //-- Enviara zero pois a integracao nao admite esta modalidade
						cQuery += "0,"
						cQuery += "0); END;"
					Else
						cQuery += AllTrim(Str(nCustoTot,aTamSB2[1],aTamSB2[2])) +", "
						cQuery += AllTrim(Str(nCustoUnit,aTamSB2[1],aTamSB2[2])) +"); END;"
					EndIf
				Else
					cQuery := "SP_CUSTO_FILIAL "
					If ValType(aColig[1]) == "N"
						cQuery += "@CodColigada = '" +AllTrim(Str(aColig[nX])) +"', "
						cQuery += "@CodFilial  = '" +PadR(cFilAnt,Len(SM0->M0_CODFIL)) +"', "
					Elseif ValType(aColig[1]) == "A"
						cQuery += "@CodColigada = '" +AllTrim(Str(aColig[nX,1])) +"', "
						If Empty(aColig[nX,2])
							cQuery += "@CodFilial  = '" +PadR(cFilAnt,Len(SM0->M0_CODFIL)) +"', "
						Else
							cQuery += "@CodFilial  = '" +PadR(aColig[nX,2],Len(SM0->M0_CODFIL)) +"', "
						Endif
					Endif
					cQuery += "@CodigoPrd = '" +AllTrim(SB2->B2_COD) +"', "
					If cCusFil == "A" //-- Enviara zero pois a integracao nao admite esta modalidade
						cQuery += "@CustoMedio = 0, "
						cQuery += "@CustoUnitario = 0 "
					Else
						cQuery += "@CustoMedio = " +AllTrim(Str(nCustoTot,aTamSB2[1],aTamSB2[2])) +", "
						cQuery += "@CustoUnitario = " +AllTrim(Str(nCustoUnit,aTamSB2[1],aTamSB2[2]))
					EndIf
				Endif
			Next nX
		EndIf

		PMSExecSOLUM(cQuery)

		//-- Se a conexao ByYouDBAccess for maior que zero, deve desconectar
		If nSolumConn > 0
			TCUnLink(nSolumConn)
		EndIf

		TCSetConn(nERPConn) //-- Volta pra conexao ByYouDBAccess padrao
	EndIf
EndIf

Restarea(aAreaSB2)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMS_SAH   บAutor  ณReynaldo Miyashita  บ Data ณ  02/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza na tabela TUND de unidades de medida do            บฑฑ
ฑฑบ          ณTOP                                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMS_SAH(nOper)
Local cQuery := ""
Local nERPConn := 0
Local nSolumConn := -1
Local lMsgUnica	:= IsIntegTop()


If !(lMsgUnica)
	// Pega a conexao do ByYouDBAccess corrente do Protheus
	nERPConn := AdvConnection()

	// Pega a conexao do ByYouDBAccess corrente do TOP
	nSolumConn := CnnSolum()

	// se houver conexao do ByYouDBAccess com o TOP
	If (nSolumConn>0)

		// efetua a conexao ByYouDBAccess com o banco de dados TOP
		tcSetConn(nSolumConn)
		TcInternal( 8, STR0022 ) //"Sincronizacao Microsiga Protheus x TOP"


		If UPPER(tcgetdb()) == "ORACLE"
			cQuery := "BEGIN "
			If TCSPExist("SP_UNIDMED_TOPPROT")
				cQuery += "SP_UNIDMED_TOPPROT ("
			Else
				cQuery += "sp_Unidade_Solum_Protheus ("
			Endif
			cQuery += "  '" + SAH->AH_UNIMED +"' "
			cQuery += ", '" + FmtStrPrc(SAH->AH_DESCPO) +"' "
			cQuery += ",  " + IIf(nOper==VM_DELETE ,"1 " ,"0 ") + "); END; "  // -- 0.ATIVO / 1.INATIVO
		ELSE
			cQuery := ""
			If TCSPExist("SP_UNIDMED_TOPPROT")
				cQuery += "SP_UNIDMED_TOPPROT "
			Else
				cQuery += "sp_Unidade_Solum_Protheus "
			Endif
			cQuery += " @CodUnd  = '" + AllTrim(SAH->AH_UNIMED)+"' "
			cQuery += ",@Descricao = '" + FmtStrPrc(SAH->AH_DESCPO) + "' "
			cQuery += ",@TipoMovimento = " + iIf(nOper==VM_DELETE ,"1 " ,"0 ")  // -- 0.ATIVO / 1.INATIVO

		Endif

		PMSExecSOLUM(cQuery)

		// Se a conexao ByYouDBAccess for maior que zero, deve desconectar
		If nSolumConn >0
			TCUnLink(nSolumConn)
		EndIf
		// volta pra conexao ByYouDBAccess Padrao
		tcSetConn(nERPConn)

	Endif
Endif
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMS_SA1   บAutor  ณReynaldo Miyashita  บ Data ณ  02/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza os clientes na tabela TCFO de clientes/fornecedoresบฑฑ
ฑฑบ          ณdo TOP                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMS_SA1(nOper)
Local cQuery := ""
Local nColigada := GetNewPar("MV_RMCOLIG",0) // coligada igual a empresa
Local nCnt       := 0
Local nERPConn   := 0
Local nSolumConn := -1
Local aColig     := {}
Local lPMRMCOLIG := ExistBlock("PMRMCOLIG")
Local cTipo      := ""
Local aAreaSYA
Local aArea      := GetArea()
Local cNameProc  := "ProtheusSolum"
Local nExec      := 0
Local lContinua  := .T.
Local lMsgUnica	:= IsIntegTop()


If !(lMsgUnica)
	IF !IntTopTin(nColigada)//nao pode estar com a integra็ใo tin mu e top procedure ligada
		dbSelectArea("SYA")
		aAreaSYA:= SYA->(GetArea())//Alteracao realizada pela RM.

		If cPaisLoc $ "ARG|ANG|PTG|COL|HAI|PER|BRA"
			Do Case
				Case cPaisLoc == "ARG"
					cTipo := IIF(SA1->A1_PESSOA == " ","F",SA1->A1_PESSOA)  //ALTERADO WPG 31/03/11 FNC:000000079002011 Plano: 000000083582011 - 00
				Case cPaisLoc == "ANG"
					cTipo := iIf(SA1->A1_TIPO=="1","F","J")
				Case cPaisLoc == "PTG"
					cTipo := iIf(SA1->A1_TIPO $ "1|3","F","J")
				Case cPaisLoc == "COL"
					cTipo := iIf(SA1->A1_TIPO $ "1|3","F","J")
				Case cPaisLoc == "HAI"
					cTipo := iIf(SA1->A1_TIPO == "1","F","J")
				Case cPaisLoc == "PER"
					cTipo := iIf(SA1->A1_TIPO == "2","F","J")
				Case cPaisLoc == "BRA"
					cTipo := IIF(SA1->A1_PESSOA == " ","F",SA1->A1_PESSOA)  //ALTERADO WPG 31/03/11 FNC:000000079002011 Plano: 000000083582011 - 00
			EndCase
		Endif

		// define a coligada a qual o produto vai ser replicado na base RM
		aAdd(aColig ,nColigada)

		// Pega a conexao do ByYouDBAccess corrente do Protheus
		nERPConn := AdvConnection()

		// Carrega as coligadas
		If lPMRMCOLIG
			aColig:= ExecBlock("PMRMCOLIG",.F.,.F.,{"SA1",aColig})
			tcSetConn(nERPConn)
		EndIf

		// Pega a conexao do ByYouDBAccess corrente do TOP
		nSolumConn := CnnSolum()

		// se houver conexao do ByYouDBAccess com o TOP
		If (nSolumConn>0)

			// efetua a conexao ByYouDBAccess com o banco de dados TOP
			tcSetConn(nSolumConn)
			TcInternal( 8, STR0022 ) //"Sincronizacao Microsiga Protheus x TOP"


			For nCnt := 1 to len(aColig)

				if UPPER(tcgetdb()) == "ORACLE"

					cQuery := "BEGIN "
					If(TCSPExist("SP_CLIFOR_TOPPROT01"))
						// procedure que contempla envio de codigo pais e codigo municipio
						cQuery += "SP_CLIFOR_TOPPROT01 ("
					ElseIf (TCSPExist("SP_CLIFOR_TOPPROT"))
						cQuery += "SP_CLIFOR_TOPPROT ("
					Else
						cQuery += "sp_ClienteFornecedor ("
					Endif
					If ValType(aColig[1]) == "N"
						cQuery +=         AllTrim(Str(aColig[nCnt])) + " "
					Elseif ValType(aColig[1]) == "A"
						cQuery +=         AllTrim(Str(aColig[nCnt,1])) + " "
					Endif
					cQuery += ", '" + SA1->A1_COD   + "' " //VARCHAR(25),
					cQuery += ", '" + FmtStrPrc(SA1->A1_NOME)  + "' " // VARCHAR(60),
					cQuery += ", 1 " // --> 1.CLIENTE, 2.FORNECEDOR, 3.AMBOS
					cQuery += ",  " + iIf(nOper==VM_DELETE ,"0 " ,"1 ")  // --> 1.ATIVO / 0.INATIVO
					cQuery += ", '" + cTIPO + "' "
					cQuery += ", '" + SA1->A1_LOJA + "' " // VARCHAR(2)
					cQuery += ", '" + SA1->A1_CGC  + "' " //VARCHAR(20)

					If !Empty(SA1->A1_DTNASC)
						cQuery += "	, TO_DATE( '" + strzero(day(SA1->A1_DTNASC),2)+ "/"+ strzero(month(SA1->A1_DTNASC),2)+ "/"+strzero(year(SA1->A1_DTNASC),4)+ "', 'DD/MM/YYYY') "
					Else
						cQuery += ", null " //VARCHAR(20)
					Endif

					cQuery += ", ' ' " //ESTADO CIVIL
					cQuery += ", '" + SA1->A1_RG + "' " //VARCHAR(20)
					cQuery += ", Null " //smallint
					cQuery += ", '" +SA1->A1_CEP + "' " //DCEP
					cQuery += ", null " //Tipo de rua (Rua, Av. Rod. etc)
					cQuery += ", '" +FmtStrPrc(SA1->A1_END) + "' " //VARCHAR(100)
					cQuery += ", ' ' " //Nro do endereco
					cQuery += ", Null " //Tipo de bairro
					cQuery += ", '" +FmtStrPrc(SA1->A1_BAIRRO) + "' " //DBAIRRO

					If(TCSPExist("SP_CLIFOR_TOPPROT01"))
						If(!Empty(SA1->A1_PAIS))
							cQuery += ", '"+ SA1->A1_PAIS +"' " // codPais VARCHAR(2)
							// realiza busca da descricao na tabela de pais
							cQuery += ", '";
								+ AllTrim(Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_DESCR"));
								+"' " // DESCRICAOPAIS 	VARCHAR(60)
						Else
							cQuery += ", NULL "
							cQuery += ", NULL "
						EndIf
					EndIf

					cQuery += ", '" +SA1->A1_EST + "' " //VARCHAR(2)
					cQuery += ", '" +SA1->A1_COD_MUN+ "' " //VARCHAR CODIGO MUNICIPIO

					If(TCSPExist("SP_CLIFOR_TOPPROT01"))
						If(!Empty(SA1->A1_MUN))
							cQuery += ", '"+ LEFT(AllTrim(SA1->A1_MUN),32) +"' " // NOMEMUNICIPIO	VARCHAR(32)


						Else
							cQuery += ", NULL "
						EndIf
					EndIf

					cQuery += ", '" +LEFT(SA1->A1_TEL,15) + "' " //VARCHAR(15)
					cQuery += ", '" +SA1->A1_EMAIL + "' " //VARCHAR(60)
					cQuery += ",  " + iIf(SA1->A1_MSBLQL=="1" ,"1","0") + " " //VARCHAR(1)
					cQuery += "); END; "

					PMSExecSOLUM(cQuery)
				Else
					cQuery := ""
					cQuery := "CREATE PROCEDURE " + cNameProc
					cQuery += " (@SAIDA Integer OutPut)"
					cQuery += " As"
					cQuery += " Begin"
					cQuery += " Declare @DataFormatada DATETIME"
					cQuery += " Select @SAIDA = 0"
					If Empty(SA1->A1_DTNASC)
					   cQuery += " Select @DataFormatada = Convert(DateTime, '1900-01-01 00:00:00', 120)"
					Else
					   cQuery += " Select @DataFormatada = Convert(DateTime, " + "'" + strzero(year(SA1->A1_DTNASC), 4) + "-" + strzero(month(SA1->A1_DTNASC), 2) + "-" + strzero(day(SA1->A1_DTNASC), 2) + " 00:00:00', 120)"
					EndIf
					cQuery += " EXEC "
					If(TCSPExist("SP_CLIFOR_TOPPROT01"))
						cQuery += "SP_CLIFOR_TOPPROT01 "
					ElseIf (TCSPExist("SP_CLIFOR_TOPPROT"))
						cQuery += "SP_CLIFOR_TOPPROT "
					Else
						cQuery += "sp_ClienteFornecedor_Solum_Protheus "
					Endif
					If ValType(aColig[1]) == "N"
						cQuery += " @CodColigada = "      +AllTrim(Str(aColig[nCnt])) + " "
					Elseif ValType(aColig[1]) == "A"
						cQuery += " @CodColigada = "      +AllTrim(Str(aColig[nCnt,1])) + " "
					Endif
					cQuery += ",@CodigoCfo = '"       +AllTrim(SA1->A1_COD)+"' " //VARCHAR(25),
					cQuery += ",@CodLoja = '"         +AllTrim(SA1->A1_LOJA) +"' " // VARCHAR(2)
					cQuery += ",@Nome = '"            +FmtStrPrc(SA1->A1_NOME)+"' " // VARCHAR(60),
					cQuery += ",@CliFor = 1 " // --> 1.CLIENTE, 2.FORNECEDOR, 3.AMBOS
					cQuery += ",@Ativo = "            +iIf(nOper==VM_DELETE ,"0 " ,"1 ")  // --> 1.ATIVO / 0.INATIVO
					cQuery += ",@PessoaFisJur = '" + cTipo + "' "
					cQuery += ",@Bloqueado ="         +iIf(SA1->A1_MSBLQL=="1" ,"1","0") + " " //VARCHAR(1)
					If !Empty(SA1->A1_CGC)
						cQuery += ",@CGCCFO ='"       +AllTrim(SA1->A1_CGC) + "' " //VARCHAR(20)
					Endif
					If !Empty(SA1->A1_DTNASC)
						cQuery += ", @DTNASCIMENTO = @DataFormatada" //DATETIME
					Endif
					If !Empty(SA1->A1_RG)
						cQuery += ",@CIDENTIDADE ='"  +AllTrim(SA1->A1_RG) + "' " //VARCHAR(20)
					Endif
					If !Empty(SA1->A1_CEP)
						cQuery += ",@CEP ='"           +AllTrim(SA1->A1_CEP) + "' " //DCEP
					Endif
					If !Empty(SA1->A1_END)
						cQuery += ",@RUA ='"           +FmtStrPrc(SA1->A1_END) + "' " //VARCHAR(100)
					Endif
					If !Empty(SA1->A1_BAIRRO)
						cQuery += ",@BAIRRO ='"        +FmtStrPrc(SA1->A1_BAIRRO) + "' " //DBAIRRO
					Endif

					If(TCSPExist("SP_CLIFOR_TOPPROT01"))
						If(!Empty(SA1->A1_PAIS))
							cQuery += ", @CODPAIS	 ='"+ AllTrim(SA1->A1_PAIS) +"' " // codPais VARCHAR(2)
							// realiza busca da descricao na tabela de pais
							cQuery += ", @DESCRICAOPAIS ='";
								+ AllTrim(Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_DESCR"));
								+"' " // DESCRICAOPAIS 	VARCHAR(60)
						Else
							cQuery += ", @CODPAIS	 = NULL "
							cQuery += ", @DESCRICAOPAIS = NULL "
						EndIf
					EndIf

					If !Empty(SA1->A1_EST)
						cQuery += ",@CODETD ='"        +AllTrim(SA1->A1_EST) + "' " //VARCHAR(2)
					Endif
					If !Empty(SA1->A1_COD_MUN)
						cQuery += ",@CODMUNICIPIO = '"+ AllTrim(SA1->A1_COD_MUN) +"' " // CODMUNICIPIO VARCHAR(20)
					Else
						cQuery += ",@CODMUNICIPIO = NULL "
					Endif

					If(TCSPExist("SP_CLIFOR_TOPPROT01"))
						If(!Empty(SA1->A1_MUN))
							cQuery += ", @NOMEMUNICIPIO = '"+ LEFT(AllTrim(SA1->A1_MUN),32) +"' " // NOMEMUNICIPIO	VARCHAR(32)
						Else
							cQuery += ", @NOMEMUNICIPIO = NULL "
						EndIf
					EndIf

					If !Empty(SA1->A1_TEL)
						cQuery += ",@TELEFONE ='"      +AllTrim(SA1->A1_TEL) + "' " //VARCHAR(15)
					Endif
					If !Empty(SA1->A1_EMAIL)
						cQuery += ",@EMAIL ='"         +AllTrim(SA1->A1_EMAIL) + "' " //VARCHAR(60)
					Endif
					If !Empty(SA1->A1_PAIS)
						cQuery += ",@NACIONALIDADE = null " //smallint
					Endif
					cQuery += " End"

					// Executa a Stored Procedure
					Pms_LOG(cQuery, cNameProc, nExec, lContinua)//Gera Log
				EndIf

			Next nCnt

			// Se a conexao ByYouDBAccess for maior que zero, deve desconectar
			If nSolumConn >0
				TCUnLink(nSolumConn)
			EndIf
			// volta pra conexao ByYouDBAccess Padrao
			tcSetConn(nERPConn)

		Endif
		RestArea(aAreaSYA)
	Endif
Endif
RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMS_SA2   บAutor  ณReynaldo Miyashita  บ Data ณ  02/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza os fornecedores na tabela TCFO de clientes/        บฑฑ
ฑฑบ          ณfornecedores do TOP                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMS_SA2(nOper)
Local cQuery := ""
Local cTipo := ""
Local nColigada := GetNewPar("MV_RMCOLIG",0) // coligada igual a empresa
Local nCnt       := 0
Local nERPConn   := 0
Local nSolumConn := -1
Local aColig     := {}
Local lPMRMCOLIG := ExistBlock("PMRMCOLIG")
Local aAreaSYA
Local aArea:=GetArea()
Local lMsgUnica	:= IsIntegTop()


If !(lMsgUnica)
	If !IntTopTin(nColigada)
		dbSelectArea("SYA")
		aAreaSYA:= SYA->(GetArea())//Alteracao realizada pela RM.

		If cPaisLoc $ "ANG|PTG"
			cTipo := iIf(SA2->A2_TIPO $ "1|3","F","J")
		ElseIf cPaisLoc == "BRA"
			cTipo := iIf(SA2->A2_TIPO == "F","F","J")
		ElseIf cPaisLoc == "ARG"
			cTipo := iIf(SA2->A2_TIPORUR == "","F",SA2->A2_TIPORUR)
		EndIF

		// define a coligada a qual o produto vai ser replicado na base RM
		aAdd(aColig ,nColigada)

		// Pega a conexao do ByYouDBAccess corrente do Protheus
		nERPConn := AdvConnection()

		// Carrega as coligadas
		If lPMRMCOLIG
			aColig:= ExecBlock("PMRMCOLIG",.F.,.F.,{"SA2",aColig})
			tcSetConn(nERPConn)
		EndIf

		// Pega a conexao do ByYouDBAccess corrente do TOP
		nSolumConn := CnnSolum()

		// se houver conexao do ByYouDBAccess com o TOP
		If (nSolumConn>0)

			// efetua a conexao ByYouDBAccess com o banco de dados TOP
			tcSetConn(nSolumConn)
			TcInternal( 8, STR0022 ) //"Sincronizacao Microsiga Protheus x TOP"

			For nCnt := 1 to len(aColig)

				if UPPER(tcgetdb()) == "ORACLE"

					cQuery := "BEGIN "

					if(TCSPExist("SP_CLIFOR_TOPPROT01"))
						cQuery += "SP_CLIFOR_TOPPROT01 ("
					ElseIf (TCSPExist("SP_CLIFOR_TOPPROT"))
						cQuery += "SP_CLIFOR_TOPPROT ("
					Else
						cQuery += "sp_ClienteFornecedor ("
					Endif
					If ValType(aColig[1]) == "N"
						cQuery +=           AllTrim(Str(aColig[nCnt])) + " "
					Elseif ValType(aColig[1]) == "A"
						cQuery +=           AllTrim(Str(aColig[nCnt,1])) + " "
					Endif
					cQuery += ", '"    +SA2->A2_COD  + "' " //VARCHAR(25),
					cQuery += ", '"    +FmtStrPrc(SA2->A2_NOME)  + "' " // VARCHAR(60),
					cQuery += ", 2 " // --> 1.CLIENTE, 2.FORNECEDOR, 3.AMBOS
					cQuery += ",  "    +iIf(nOper==VM_DELETE ,"0 " ,"1 ")  // --> 1.ATIVO / 0.INATIVO
					cQuery += ", '"    +cTipo + "' " //VARCHAR(1) @PessoaFisJur =
					cQuery += ", '"    +SA2->A2_LOJA  + "' " //VARCHAR(2)
					cQuery += ", '"    +SA2->A2_CGC + "' " //VARCHAR(20)
					cQuery += ", null" //VARCHAR(20) - data nascimento
					cQuery += ", ' ' " //VARCHAR(20) - estado civil
					cQuery += ", ' ' " //ESTADO CIVIL - cidentidade
					cQuery += ", null "   //smallint - NACIONALIDADE
					cQuery += ", '" +SA2->A2_CEP + "' " //DCEP
					cQuery += ", null" //Tipo de rua (Rua, Av. Rod. etc)
					cQuery += ", '" +FmtStrPrc(SA2->A2_END) + "' " //VARCHAR(100)
					cQuery += ", '" +AllTrim(SA2->A2_NR_END) + "' " //VARCHAR(8)
					cQuery += ", null " //Tipo de bairro
					cQuery += ", '" +FmtStrPrc(SA2->A2_BAIRRO) + "' " //DBAIRRO

					If(TCSPExist("SP_CLIFOR_TOPPROT01"))
						If(!Empty(SA2->A2_PAIS))
							cQuery += ", '"+ SA2->A2_PAIS +"' " // codPais VARCHAR(2)

							// realiza busca da descricao na tabela de pais
							cQuery += ", '";
								+ AllTrim(Posicione("SYA",1,xFilial("SYA")+SA2->A2_PAIS,"YA_DESCR"));
								+"' " // DESCRICAOPAIS 	VARCHAR(60)
						Else
							cQuery += ", NULL "
							cQuery += ", NULL "
						EndIf
					EndIf

					cQuery += ", '" +SA2->A2_EST + "' " //VARCHAR(2)
					cQuery += ", '" +SA2->A2_COD_MUN+ "' " //VARCHAR CODIGO MUNICIPIO

					If(TCSPExist("SP_CLIFOR_TOPPROT01"))
						If(!Empty(SA2->A2_MUN))
							cQuery += ", '"+ LEFT(AllTrim(SA2->A2_MUN),32) +"' " // NOMEMUNICIPIO	VARCHAR(32)
						Else
							cQuery += ", NULL "
						EndIf
					EndIf

					cQuery += ", '" +LEFT(SA2->A2_TEL,15) + "' " //VARCHAR(15)
					cQuery += ", '" +SA2->A2_EMAIL + "' " //VARCHAR(60)
					cQuery += ",  " + iIf(SA2->A2_MSBLQL=="1" ,"1","0") + " " //VARCHAR(1)
					cQuery += "); END; "
				Else
					cQuery := ""
					if(TCSPExist("SP_CLIFOR_TOPPROT01"))
						cQuery += "SP_CLIFOR_TOPPROT01 "
					ElseIf (TCSPExist("SP_CLIFOR_TOPPROT"))
						cQuery += "SP_CLIFOR_TOPPROT "
					Else
						cQuery += "sp_ClienteFornecedor_Solum_Protheus "
					Endif
					If ValType(aColig[1]) == "N"
						cQuery += " @CodColigada = " + AllTrim(Str(aColig[nCnt])) + " "
					Elseif ValType(aColig[1]) == "A"
						cQuery += " @CodColigada = " + AllTrim(Str(aColig[nCnt,1])) + " "
					Endif
					cQuery += ",@CodigoCfo = '"+AllTrim(SA2->A2_COD)+"' " //VARCHAR(25),
					cQuery += ",@Nome = '"+FmtStrPrc(SA2->A2_NOME)+"' " // VARCHAR(60),
					cQuery += ",@CliFor = 2 " // --> 1.CLIENTE, 2.FORNECEDOR, 3.AMBOS
					cQuery += ",@Ativo = " + iIf(nOper==VM_DELETE ,"0 " ,"1 ")  // --> 1.ATIVO / 0.INATIVO
					cQuery += ",@PessoaFisJur ='" + cTipo + "' " //VARCHAR(1)
					cQuery += ",@Bloqueado =" + iIf(SA2->A2_MSBLQL=="1" ,"1","0") + " " //VARCHAR(1)
					cQuery += ",@CodLoja ='" +AllTrim(SA2->A2_LOJA) + "' " //VARCHAR(2)

					If !Empty(SA2->A2_CGC)
						cQuery += ",@CGCCFO ='" +AllTrim(SA2->A2_CGC) + "' " //VARCHAR(20)
					Endif
					If cPaisLoc == "ARG"
						cQuery += ",@CIDENTIDADE = '' " //VARCHAR(20)
					ElseIf cPaisLoc == "BRA"
						If !Empty(SA2->A2_PFISICA)
							cQuery += ",@CIDENTIDADE ='" +AllTrim(SA2->A2_PFISICA) + "' " //VARCHAR(20)
						Endif
					EndIF
					If !Empty(SA2->A2_CEP)
						cQuery += ",@CEP ='" +AllTrim(SA2->A2_CEP) + "' " //DCEP
					Endif
					If !Empty(SA2->A2_END)
						cQuery += ",@RUA ='" +FmtStrPrc(SA2->A2_END) + "' " //VARCHAR(100)
					Endif
					If !Empty(SA2->A2_BAIRRO)
						cQuery += ",@BAIRRO ='" +FmtStrPrc(SA2->A2_BAIRRO) + "' " //DBAIRRO
					Endif

					If(TCSPExist("SP_CLIFOR_TOPPROT01"))
						If(!Empty(SA2->A2_PAIS))
							cQuery += ", @CODPAIS	 ='"+ AllTrim(SA2->A2_PAIS) +"' " // codPais VARCHAR(2)

							// realiza busca da descricao na tabela de pais
							cQuery += ", @DESCRICAOPAIS ='";
								+ AllTrim(Posicione("SYA",1,xFilial("SYA")+SA2->A2_PAIS,"YA_DESCR"));
								+"' " // DESCRICAOPAIS 	VARCHAR(60)
						Else
							cQuery += ", @CODPAIS	 = NULL "
							cQuery += ", @DESCRICAOPAIS = NULL "
						EndIf
					EndIf

					If !Empty(SA2->A2_EST)
						cQuery += ",@CODETD ='" +AllTrim(SA2->A2_EST) + "' " //VARCHAR(2)
					Endif
					If !Empty(SA2->A2_COD_MUN)
						cQuery += ",@CODMUNICIPIO = '"+ AllTrim(SA2->A2_COD_MUN) +"' " // CODMUNICIPIO VARCHAR(20)
					Else
						cQuery += ",@CODMUNICIPIO = NULL "
					Endif

					If(TCSPExist("SP_CLIFOR_TOPPROT01"))
						If(!Empty(SA2->A2_MUN))
							cQuery += ", @NOMEMUNICIPIO = '"+ LEFT(AllTrim(SA2->A2_MUN),32) +"' " // NOMEMUNICIPIO	VARCHAR(32)
						Else
							cQuery += ", @NOMEMUNICIPIO = NULL "
						EndIf
					EndIf

					If !Empty(SA2->A2_TEL)
						cQuery += ",@TELEFONE ='" +AllTrim(SA2->A2_TEL) + "' " //VARCHAR(15)
					Endif
					If !Empty(SA2->A2_EMAIL)
						cQuery += ",@EMAIL ='" +AllTrim(SA2->A2_EMAIL) + "' " //VARCHAR(60)
					Endif
					If !Empty(SA2->A2_PAIS)
						cQuery += ",@NACIONALIDADE = null " //smallint
					Endif
					If !Empty(SA2->A2_NR_END)
						cQuery += ",@NUMERO ='" +AllTrim(SA2->A2_NR_END) + "' " //VARCHAR(8)
					Endif
				Endif

				PMSExecSOLUM(cQuery)

			Next nCnt

			// Se a conexao ByYouDBAccess for maior que zero, deve desconectar
			If nSolumConn >0
				TCUnLink(nSolumConn)
			EndIf
			// volta pra conexao ByYouDBAccess Padrao
			tcSetConn(nERPConn)

		Endif
		RestArea(aAreaSYA)
	Endif
Endif
RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMS_SM2   บAutor  ณReynaldo Miyashita  บ Data ณ  02/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza as moedas e cotacoes na tabela GMOEDA e GCOTACAO   บฑฑ
ฑฑบ          ณde moeda e cotacao do TOP                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMS_SM2(nOper)
Local cQuery := ""
Local cMoeda := ""
Local aArTmpSX6 := {}
Local aArea := {}
Local aAreaSX6 := {}
Local aTamSX3 := {}
Local lMoeda:=.F.
Local nERPConn   := 0
Local nSolumConn := -1
Local cNameProc := ""
Local lContinua  := .T.
Local nExec := 0
Local lMsgUnica	:= IsIntegTop()
Local cSimb1		:= GetMv("MV_SIMB1")
Local cSimbX		:= ""
Local cMoedaX		:= ""

If !(lMsgUnica)
	aArea := GetArea()
	aAreaSX6 := SX6->(GetArea())

	lMoeda:=GetMv("MV_MOEDA1"+cMoeda,.T.)

	// Pega a conexao do ByYouDBAccess corrente do Protheus
	nERPConn := AdvConnection()

	// Pega a conexao do ByYouDBAccess corrente do TOP
	nSolumConn := CnnSolum()

	// se houver conexao do ByYouDBAccess com o TOP
	If (nSolumConn>0)

		// efetua a conexao ByYouDBAccess com o banco de dados TOP
		tcSetConn(nSolumConn)
		TcInternal( 8, STR0022 ) //"Sincronizacao Microsiga Protheus x TOP"

		cNameProc := "ProtheusSolum"

		While SX6->(!Eof()) .And. Left( SX6->X6_VAR, 8 ) == "MV_MOEDA"
			aArTmpSX6 := SX6->(GetArea())
			cMoeda := AllTrim(substr(SX6->X6_VAR,9,2))
			cSimbX	:= GetMv("MV_SIMB"+cMoeda)
			cMoedaX:= GetMv("MV_MOEDA"+cMoeda)
			If Val(cMoeda)>0 .AND. SM2->(FieldPos("M2_MOEDA" + cMoeda)) > 0

				aTamSX3 := TamSX3("M2_MOEDA" + cMoeda)

				If UPPER(tcgetdb()) == "ORACLE"
					cQuery := "BEGIN " //"EXEC "
					If TCSPExist("SP_MOEDA_TOPPROT")
						cQuery += "SP_MOEDA_TOPPROT ("
					Else
						cQuery += "sp_Moeda_Solum_Protheus ("
					Endif

					cQuery += "  '" + cSimbX + "' " // VARCHAR(10),
					cQuery += ", '" + cMoedaX + "' " // VARCHAR(40),
					cQuery += ",  " + AllTrim(Str(aTamSX3[2])) + " " // SMALLINT,
					cQuery += ", 'M' " // VARCHAR(10),
					cQuery += ", 0 " // -- 0.INCLUI/ALTERA / 1.EXCLUI
					cQuery += "); END; "

				Else
					cQuery := ""
					If TCSPExist("SP_MOEDA_TOPPROT")
						cQuery += "SP_MOEDA_TOPPROT "
					Else
						cQuery += "sp_Moeda_Solum_Protheus "
					Endif

					cQuery += " @Simbolo = '"      + Alltrim( cSimbX ) + "' " // VARCHAR(10),
					cQuery += ",@Descricao = '"    + Alltrim( cMoedaX ) + "' " // VARCHAR(40),
					cQuery += ",@CasasDecimais = " + AllTrim(Str(aTamSX3[2])) + " " // SMALLINT,
					cQuery += ",@Tipo = 'M' " // VARCHAR(10),
					cQuery += ",@TipoMovimento = 0 " // -- 0.INCLUI/ALTERA / 1.EXCLUI

				EndIf

				// Executa a Stored Procedure
				PMSExecSOLUM(cQuery)

				If UPPER(tcgetdb()) == "ORACLE"
					cQuery := "BEGIN "
					If TCSPExist("SP_COTACAO_TOPPROT")
						cQuery += "SP_COTACAO_TOPPROT ("
					Else
						cQuery += "sp_Cotacao_Solum_Protheus ("
					Endif
					cQuery += "  '" + GetMv("MV_SIMB"+cMoeda) + "' " // VARCHAR(10),
					// Nใo utilizar TO_DATE aqui porque na stored procedure jแ utiliza.
					cQuery += "	,TO_DATE( '" + strzero(day(SM2->M2_DATA),2)+ "/"+ strzero(month(SM2->M2_DATA),2)+ "/"+strzero(year(SM2->M2_DATA),4)+ "', 'DD/MM/YYYY') "
					cQuery += ",  " + AllTrim(Str(SM2->&("M2_MOEDA"+cMoeda),aTamSX3[1],aTamSX3[2])) + " "// NUMERIC(19,4),
					cQuery += ", '" + cSimb1 + "' " //  VARCHAR(10),
					cQuery += ",  " + iIf(nOper==VM_DELETE ,"1 " ,"0 ")  // -- 0.INCLUI/ALTERA / 1.EXCLUI
					cQuery += "); END; "

					// Executa a Stored Procedure
					PMSExecSOLUM(cQuery)
				Else
					cQuery := ""
					cQuery := "CREATE PROCEDURE " +cNameProc + "("
					cQuery += " @SAIDA Integer OutPut "
					cQuery += ") "
					cQuery += " As "
					cQuery += "Begin Declare @DataFormatada DATETIME "
					cQuery += "  Select @SAIDA = 0 Select @DataFormatada = Convert(DateTime,"+ "'" +strzero(year(SM2->M2_DATA),4) + "-" + strzero(month(SM2->M2_DATA),2) + "-"+ strzero(day(SM2->M2_DATA),2)+ " 00:00:00',120) "
					cQuery += "  EXEC "

					If TCSPExist("SP_COTACAO_TOPPROT")
						cQuery += "SP_COTACAO_TOPPROT "
					Else
						cQuery += "sp_Cotacao_Solum_Protheus "
					Endif

					cQuery += " @Simbolo = '"           + Alltrim( cSimbX ) + "' " // VARCHAR(10),
					cQuery += ",@Data = @DataFormatada " // DATETIME,
					cQuery += ",@Fator = "              + AllTrim(Str(SM2->&("M2_MOEDA"+cMoeda),aTamSX3[1],aTamSX3[2])) + " "// NUMERIC(19,4),
					cQuery += ",@SimboloReferencia = '" + Alltrim( cSimb1 ) + "' " //  VARCHAR(10),
					cQuery += ",@TipoMovimento = "      + iIf(nOper==VM_DELETE ,"1 " ,"0 ")  // -- 0.INCLUI/ALTERA / 1.EXCLUI
					cQuery += " End "

					// Executa a Stored Procedure
					Pms_LOG(cQuery,cNameProc,nExec,lContinua)	//Gera Log
				EndIf

			Else
				If Val(cMoeda)>0

					If UPPER(tcgetdb()) == "ORACLE"
						cQuery := "BEGIN "
						If TCSPExist("SP_MOEDA_TOPPROT")
							cQuery += "SP_MOEDA_TOPPROT ("
						Else
							cQuery += "sp_Moeda_Solum_Protheus ("
						Endif

						cQuery += "  '"  + cSimbX + "' " // VARCHAR(10),
						cQuery += ", '"  + cMoedaX + "' " // VARCHAR(40),
						cQuery += ", "   + AllTrim(Str(aTamSX3[2])) + " " // SMALLINT,
						cQuery += ", 'M' " // VARCHAR(10),
						cQuery += ", 1 " // -- 0.INCLUI/ALTERA / 1.EXCLUI
						cQuery += "); END; "
					Else
						cQuery := ""
						If TCSPExist("SP_MOEDA_TOPPROT")
							cQuery += "SP_MOEDA_TOPPROT "
						Else
							cQuery += "sp_Moeda_Solum_Protheus "
						Endif
						cQuery += " @Simbolo = '"      + AllTrim(cSimbX) + "' " // VARCHAR(10),
						cQuery += ",@Descricao = '"    + AllTrim(cMoedaX) + "' " // VARCHAR(40),
						cQuery += ",@CasasDecimais = " + AllTrim(Str(aTamSX3[2])) + " " // SMALLINT,
						cQuery += ",@Tipo = 'M' " // VARCHAR(10),
						cQuery += ",@TipoMovimento = 1 " // -- 0.INCLUI/ALTERA / 1.EXCLUI
					Endif

					// Executa a Stored Procedure
					PMSExecSOLUM(cQuery)

				EndIF
			Endif
			SX6->(RestArea(aArTmpSX6))
			SX6->(DbSkip())
		EndDo
	Endif

	// Se a conexao ByYouDBAccess for maior que zero, deve desconectar
	If nSolumConn >0
		TCUnLink(nSolumConn)
	EndIf
	// volta pra conexao ByYouDBAccess Padrao
	tcSetConn(nERPConn)

	RestArea(aAreaSX6)
	RestArea(aArea)
Endif
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMS_SM0AllบAutor  ณReynaldo Miyashita  บ Data ณ  08/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que irแ mostrar uma atualizarแ a tabela GFILIAL do TOP com todas  บฑฑ
ฑฑบ          ณ as filiais existentes na Empresa logada / Coligada         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMS_SM0All(nOper)
Local nColigada	:= GetNewPar("MV_RMCOLIG",0) // coligada igual a empresa
Local lMsgUnica	:= IsIntegTop()

DEFAULT nOper := VM_UPDATE
If !(lMsgUnica)
	If nColigada > 0
		If IsBlind()
			AuxSM0All(nOper ,nColigada)
		Else
			MsgRun( STR0024; //"Sincronizando as Filiais com TOTVS Obras e Projetos"
			,STR0025; //"Aguarde..."
			,{||AuxSM0All(nOper ,nColigada)} )
		EndIf
	EndIf
Endif
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAuxSM0All บAutor  ณReynaldo Miyashita  บ Data ณ  08/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que atualizarแ a tabela GFILIAL do TOP   com todas  บฑฑ
ฑฑบ          ณ as filiais existentes na Empresa logada / Coligada         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AuxSM0All(nOper ,nColigada)

Local aAreaSM0 	:= {}
local empGest 	:= FWCompany()
local negGest		:= FWUnitBusiness()
local filGest		:= FWFilial()
local TamEmp		:= LEN(empGest)
local TamNeg		:= LEN(negGest)
local TamFil		:= LEN(filGest)
Local lGestao   	:= ( FWSizeFilial() > 2) 
local lContinua 	:= .T. 
Local lMsgUnica	:= IsIntegTop()

local nNivelCol := GetNewPar("MV_RMCOLNV",0) // nivel de que serแ passado para o RM
DEFAULT nColigada := GetNewPar("MV_RMCOLIG",0) // coligada igual a empresa

If !(lMsgUnica )
	If nColigada > 0
		dbSelectArea("SM0")
		aAreaSM0 	:= SM0->(GetArea())
		dbSetOrder(1)// M0_CODIGO + M0_FILIAL
		
		//incluindo valida็ใo para gestใo corporativa
		if lGestao
			dbSeek(cEmpAnt + FWCodFil())
			While SM0->(!Eof()) .and. lContinua .And. cEmpAnt == SM0->M0_CODIGO
				// integra o sigamat.emp do protheus com a tabela GFILIAL do RM
				
				If nNivelCol == 0
					If cEmpAnt == SM0->M0_CODIGO
						lContinua := .T.
					else
						lContinua := .F.
					EndIf
					
				ElseIf nNivelCol == 1
					If SubStr(SM0->M0_CODFIL,1,TamEmp) == empGest
						lContinua := .T.
					else
						lContinua := .F.
					EndIf
				ElseIf nNivelCol == 2
					If SubStr(SM0->M0_CODFIL,TamEmp+1,TamNeg) == negGest
						lContinua := .T.
					else
						lContinua := .F.
					EndIf
				ElseIf nNivelCol == 3
					If SubStr(SM0->M0_CODFIL,TamEmp+TamNeg+1,TamFil) == filGest
						lContinua := .T.
					else
						lContinua := .F.
					EndIf
				EndIf
				
				If lContinua
					PMS_SM0(nOper)
		
					SM0->(DbSkip())
				EndIf
			EndDo
		else
			dbSeek(cEmpAnt)
			While SM0->(!Eof()) .and. cEmpAnt == SM0->M0_CODIGO
				// integra o sigamat.emp do protheus com a tabela GFILIAL do RM
				PMS_SM0(nOper)
	
				SM0->(DbSkip())
			EndDo
		EndIf
		restArea(aAreaSM0)
	EndIf
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PMS_SM0  บAutor  ณClovis Magenta      บ Data ณ  14/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que atualizarแ a tabela GFILIAL do TOP   com a      บฑฑ
ฑฑบ          ณ filial que estiver posicionada no registro corrente da     บฑฑ
ฑฑบ          ณ tabela SM0.                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMS_SM0(nOper)

Local aSPResult  := {} // vetor que vai guardar o retorno da procedure
Local nERPConn   := -1 // c๓digo da conexao Protheus
Local nSolumConn := -1 // c๓digo da conexao TOP
Local cDadosEnv  := "" // armazena os valores que foram enviados a procedure para a funcao PMSRMSOLUMLOG
Local cDadosRec  := "" // armazena os valores recebidos da procedure para a funcao PMSRMSOLUMLOG
Local cMsgError  := "" // Mensagem de erro do banco de dados na execucao da procedure
Local cRetCod    := "" // Codigo de retorno da procedure
Local cRetMsg    := "" // Mensagem de retorno da procedure

Local nColigada  := GetNewPar("MV_RMCOLIG",0) // c๓digo da coligada do RM que vai ser integrado
Local cSp        := ""
Local lNomEmp	   := SuperGetMV("MV_RMEMPNO",,.F.) // C๓digo para saber como enviar informa็๕es do nome da empresa ao RM.
Local lMsgUnica	:= IsIntegTop()

If !(lMsgUnica)
// Foi informado a qual coligada integrar.
	If nColigada >0

	// Pega a conexao do ByYouDBAccess corrente do Protheus
	nERPConn := AdvConnection()

	// Pega a conexao do ByYouDBAccess corrente do TOP
	nSolumConn := CnnSolum()

	// se houver conexao do ByYouDBAccess com o TOP
	If (nSolumConn>0)

			// efetua a conexao ByYouDBAccess com o banco de dados TOP
			tcSetConn(nSolumConn)
			TcInternal( 8, STR0022 ) //"Sincronizacao Microsiga Protheus x TOP"

			//		executa a procedure diretamente do banco de dados TOP
			//
			If TCSPExist("SP_FILIAL_TOPPROT")
				cSp:="SP_FILIAL_TOPPROT"
			ElseIf TCSPExist("sp_Filial_Protheus_Solum")
				cSp:="sp_Filial_Protheus_Solum"
			Endif
			
			If !Empty(cSp)
				If !lNomEmp
					aSPResult := TCSPExec( cSp ,nColigada ,SM0->M0_CODIGO ,SM0->M0_CODFIL ,SM0->M0_FILIAL ,FmtStrPrc(SM0->M0_NOMECOM) ,SM0->M0_CGC ,iIf(nOper==VM_DELETE ,1 ,0) )
				Else
					aSPResult := TCSPExec( cSp ,nColigada ,SM0->M0_CODIGO ,SM0->M0_CODFIL ,FmtStrPrc(SM0->M0_NOMECOM),SM0->M0_FILIAL  ,SM0->M0_CGC ,iIf(nOper==VM_DELETE ,1 ,0) )
				Endif
	
				If ValType( aSPResult ) == "N"
					conout( aSPResult )
				Elseif  ValType( aSPResult ) == "A"
					conout( len(aSPResult), aSPResult[1], aSPResult[2]  )
				Elseif  ValType( aSPResult ) == "U"
					conout( STR0026 + " " +cSp, ValType(aSPResult), time() )//"Retorno nulo da stored procedure "
				Else
					conout( STR0027 + " "  +cSp, ValType(aSPResult), time() )//"Retorno nao esperado da stored procedure "
				Endif
	
				cDadosEnv := ""
				cDadosEnv += STR0028 + " " //"Procedure chamada por TCSPEXEC: "
				cDadosEnv += cSp
				cDadosEnv += " par1: "  + str(nColigada)
				cDadosEnv += " par2: '" + SM0->M0_CODIGO + "' "
				cDadosEnv += " par3: '" + SM0->M0_CODFIL + "' "
				cDadosEnv += " par4: '" + SM0->M0_FILIAL + "' "
				cDadosEnv += " par5: '" + FmtStrPrc(SM0->M0_NOMECOM) + "' "
				cDadosEnv += " par6: '" + SM0->M0_CGC + "' "
				cDadosEnv += " par7: '" + str(iIf(nOper==VM_DELETE ,1 ,0))
	
				// Se o vetor estiver em vazio, houve erro do banco de dados na chamada da procedure
				If Empty(aSPResult)
					//
					// Retorna a mensagem de erro que o banco de dados detectou
					//
					cMsgError := tcSqlError()
	
					PMSRMSOLUMLOG(cMsgError,cDadosEnv,FunName())
					//
					// chamada da procedure concluida com sucesso, contem o retorno da procedure
					//
				Else
					cRetCod  := aSPResult[1] // c๓digo do retorno da procedure
					cRetMsg  := aSPResult[2] // mensagem de retorno da procedure
	
					cDadosRec := ""
					cDadosRec += STR0029 + " " + "-" + " " //"Valores de retorno
					cDadosRec += "Par1 : '"+ cRetCod + "' "
					cDadosRec += "Par2 : '"+ cRetMsg + "' "
	
					PMSRMSOLUMLOG(cDadosRec,cDadosEnv,FunName(),0)
	
				EndIf
			Endif

			// Se a conexao ByYouDBAccess for maior que zero, deve desconectar
			If nSolumConn >0
				TCUnLink(nSolumConn)
			EndIf

		EndIf

		// volta pra conexao Top Padrao
		tcSetConn(nERPConn)

	EndIf

Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMS_AFR   บAutor  ณClovis  Magenta     บ Data ณ  16/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza na tabela MSAPROP com cadastro de Titulos a pagar  บฑฑ
ฑฑบ          ณTOP                                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PMS_AFR(nOper)
Local cQuery := ""
Local nColigada := GetNewPar("MV_RMCOLIG",0) // coligada igual a empresa
Local aAreaSE2 := SE2->(GetArea())
Local cNameProc  := "" // nome da procedure no banco de dados
Local nERPConn   := -1
Local nSolumConn := -1
Local lContinua  := .T.
Local cMoeda     := ""
Local cOperacao  := ""
Local lIDAFR	 := AFR->(FieldPos("AFR_ID"))>0
Local nExec := 0
Local cProdSolum := GetMV("MV_SLMPROP", .F., " ")
Local aArea:=GetArea()
Local lMsgUnica	:= IsIntegTop()

If Type("lPrimeiro") <> "L"
	lPrimeiro := .T.
Endif 
If !(lMsgUnica)

	Do case
		// --> 0-INCLUIR, 1-ALTERAR, 2-APAGAR
		Case nOper==VM_INSERT
	  		cOperacao := "0"
	  	Case nOper==VM_UPDATE
			cOperacao := "1"
		Otherwise
			cOperacao := "2"
	EndCase

	dbSelectArea("SE2")
	dbSetOrder(1) // E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
	If Dbseek(xFilial("SE2")+AFR->(AFR_PREFIX+AFR_NUM+AFR_PARCEL+AFR_TIPO)) .and. (nColigada > 0);
				 .And. !(AFR->AFR_TIPO $ MVPAGANT .And. cPaisLoc <> "BRA" )//Projeto P11.6_CTR - Top Argentina e Mexico.
			 																		//PAs somente serao apropriados pela Ordem de pago.
		cMoeda := Alltrim(STR(SE2->E2_MOEDA))

		// Pega a conexao do ByYouDBAccess corrente do Protheus
		nERPConn := AdvConnection()

		// Pega a conexao do ByYouDBAccess corrente do TOP
		nSolumConn := CnnSolum()

		If (nSolumConn>0)

			// efetua a conexao ByYouDBAccess com o banco de dados TOP
			tcSetConn(nSolumConn)
			TcInternal( 8, STR0022)//"Sincronizacao Microsiga Protheus x TOP"

			// Define o nome da procedure pra ser criada do banco de dados
			cNameProc := "ProtheusSolum"

			If !Empty(cNameProc)
				If cOperacao <> "0"
	  				IF lPrimeiro

		  				If UPPER(tcgetdb()) == "ORACLE"
							cQuery += "BEGIN "
							If TCSPExist("SP_EXCDESP_TOPPROT2")
								cQuery += "SP_EXCDESP_TOPPROT2 ("
							ElseIf TCSPExist("SP_EXCDESP_TOPPROT")
								cQuery += "SP_EXCDESP_TOPPROT ("
							Else
								cQuery += "sp_Exclusao_Despesa ("
							Endif
							cQuery += "  "    +STR(nColigada)
							cQuery += " ,'"   +AFR->AFR_ID +  "' "
							If TCSPExist("SP_EXCDESP_TOPPROT2")
								cQuery += " , NULL "
								cQuery += " ,'"   + PADR(cFilAnt,LEN(SM0->M0_CODFIL)) +  "' "
							EndIf
		 					cQuery += "); END; "

							// Executa a Stored Procedure
							PMSExecSOLUM(cQuery)
				 		Else
							cQuery := "CREATE PROCEDURE "    +cNameProc +"("
							cQuery += " @SAIDA Integer OutPut "
							cQuery += ") "
							cQuery += " As "
							cQuery += "Begin "
							cQuery += "  Select @SAIDA = 0"
							cQuery += "  EXEC "
							If TCSPExist("SP_EXCDESP_TOPPROT2")
								cQuery += "SP_EXCDESP_TOPPROT2 "
							ElseIf TCSPExist("SP_EXCDESP_TOPPROT")
								cQuery += "SP_EXCDESP_TOPPROT "
							Else
								cQuery += "sp_Exclusao_Despesa "
							Endif
							cQuery += "  @CodColigada = "    + STR(nColigada)
							cQuery += " ,@IdProtheus	 = " +"'"+Alltrim(AFR->AFR_ID)+"' "
							If TCSPExist("SP_EXCDESP_TOPPROT2")
								cQuery += " , @IDSA = NULL "
								cQuery += " , @CODIGOFILIAL = '"   + PADR(cFilAnt,LEN(SM0->M0_CODFIL)) +  "' "
							EndIf
							cQuery += " End "

	 		 			Pms_LOG(cQuery,cNameProc,nExec,lContinua)	//Gera Log
			 		Endif
				lPrimeiro:= .F.
	  			Endif
	  		endif
	  			If cOperacao <> "2"
	   				If UPPER(tcgetdb()) == "ORACLE"
						cQuery += "BEGIN "
						If TCSPExist("SP_INCDESP_TOPPROT")
							cQuery += "SP_INCDESP_TOPPROT ("
						Else
							cQuery += "sp_Apropria_Titulo_Pagar ("
						Endif
		  				cQuery += "  "   + STR(nColigada)
		  				cQuery += " , '" + Alltrim(AFR->AFR_PROJET) +"' "
		  				cQuery += " , '" + Alltrim(AFR->AFR_TAREFA) +"' "
		  				cQuery += " , '" + cProdSolum  + "' "
		  				cQuery += " ,  " + cOperacao +" "
		   			If cOperacao $ "0;1;2" .and. lIDAFR
	   					cQuery += " , '"+AFR->AFR_ID+"' "
	   				Else
	   					cQuery += " , ' ' "
	   				Endif
		   			cQuery += " , 1"
	   				cQuery += " , " + STR(AFR->AFR_VALOR1) //pre?oUnitario
	   				cQuery += " , ' ' "
	         		cQuery += "	, TO_DATE( '" + strzero(day(AFR->AFR_DATA),2)+ "/"+ strzero(month(AFR->AFR_DATA),2)+ "/"+strzero(year(AFR->AFR_DATA),4)+ "', 'DD/MM/YYYY') "
	   				cQuery += " , '" +GetMv("MV_SIMB"+cMoeda)+"' "
		   			cQuery += " , '" + PADR(cFilAnt,LEN(SM0->M0_CODFIL)) + "' "
	 				cQuery += "); END; "

					// Executa a Stored Procedure
					PMSExecSOLUM(cQuery)
	   			Else
						cQuery := "CREATE PROCEDURE "    +cNameProc +"("
						cQuery += " @SAIDA Integer OutPut "
						cQuery += ") "
						cQuery += " As "
						cQuery += "Begin Declare @Data DATETIME "
						cQuery += "  Select @SAIDA = 0 Select @Data = Convert(DateTime,"+ "'" +strzero(year(AFR->AFR_DATA),4)+"-"+ strzero(month(AFR->AFR_DATA),2)+"-"+ strzero(day(AFR->AFR_DATA),2)+ " 00:00:00',120) "
						cQuery += "  EXEC "
					 	If TCSPExist("SP_INCDESP_TOPPROT")
							cQuery += "SP_INCDESP_TOPPROT "
						Else
							cQuery += "sp_Apropria_Titulo_Pagar "
						Endif
	   				cQuery += "  @CodColigada = "    + STR(nColigada)
		   			cQuery += " ,@CodProjeto = "    + "'"+AllTrim(AFR->AFR_PROJET)+ "' "
	   				cQuery += " ,@CodTarefa = "     + "'"+AllTrim(AFR->AFR_TAREFA)+"' "
	   				cQuery += " ,@CodProduto	= "  + "'"+cProdSolum  +"' "
	   				cQuery += " ,@TipoMovimento	= "+ cOperacao +" "

	   				If cOperacao $ "0;1;2" .and. lIDAFR
	   					cQuery += " ,@IdProtheus	= " +"'"+Alltrim(AFR->AFR_ID)+"' "
	   				Else
	   					cQuery += " ,@IdProtheus	= '0' "
		   			Endif
		   			cQuery += " ,@Quantidade	= 1"
	  			 		cQuery += " ,@PrecoUnitario	= "  +STR(AFR->AFR_VALOR1)
	  			  		cQuery += " ,@Observacao	= ' ' "
	  			  		cQuery += " ,@DataAprop	= "     +"@Data"
	  			  		cQuery += " ,@Moeda	= "         +"'"+GetMv("MV_SIMB"+cMoeda)+"' "
	   				cQuery += " ,@CODFILIAL_PROTHEUS = " + "'"+PADR(cFilAnt,LEN(SM0->M0_CODFIL)) + "' "
	  			 		cQuery += " ,@SAIDA=0"
	  			 		cQuery += " End "

				 	   Pms_LOG(cQuery,cNameProc,nExec,lContinua)	//Gera Log

		   		Endif

				Endif
			EndIf
		EndIf

		If nSolumConn >0
			TCUnLink(nSolumConn)
		EndIf

	// volta pra conexao ByYouDBAccess Padrao
		tcSetConn(nERPConn)
	EndIf
Endif
RestArea(aAreaSE2)
RestArea(aArea)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMS_LOG   บAutor  ณWilson de Godoi     บ Data ณ  09/05/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera Log se algo errado acontecer com a Stored Procedure    บฑฑ
ฑฑบ          ณTOP                                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMS_LOG(cQuery, cNameProc, nExec, lContinua)
Local cMensagem:= ""
Local nReturn:= 0
Local aResult    := {}
Local lMsgUnica	:= IsIntegTop()

If !(lMsgUnica)
	If Empty(cQuery)
		PMSRMSOLUMLOG(STR0030 + " " +cNameProc+"' ","",FunName(),-1) //'Erro na criacao da procedure '
	Else
		// se a procedure jแ existe, deve ser excluida
		If TCSPExist( cNameProc )
	  		nExec := TcSqlExec('DROP PROCEDURE '+cNameProc)
			If nExec < 0
				PMSRMSOLUMLOG(STR0031 + " " +cNameProc,'DROP PROCEDURE '+cNameProc,FunName(),nExec)//'Erro na exclusao da procedure '
				lContinua := .f.
			EndIf
			PMSRMSOLUMLOG("",'DROP PROCEDURE '+cNameProc,FunName(),nExec)
		EndIf

		If lContinua
			nExec := TcSqlExec(cQuery)
			If nExec == 0
				PMSRMSOLUMLOG("",cQuery,FunName(),nExec)

				aResult := TCSPExec( cNameProc )

				If Empty(aResult)
					PMSRMSOLUMLOG(STR0032 + " " +cNameProc,STR0033,FunName(),-1)//'Erro na chamada do processo '"Execucao da procedure"
				Else
					nReturn := aResult[1]
					// falha nos parametros informados
					If nReturn < 0
						Do Case
							Case nReturn = -1
								cMensagem := STR0034 //"C๓digo de Retorno -1 : Nใo existe o projeto no m๓dulo TOP. Verifique."
							Case nReturn = -2
								cMensagem := STR0035 //"C๓digo de Retorno -2 : Nใo existe a tarefa do projeto no m๓dulo TOP. Verifique."
							Case nReturn = -3
								cMensagem := STR0036 //"C๓digo de Retorno -3 : Nใo existe o produto no m๓dulo TOP. Verifique."
							Case nReturn = -4
								cMensagem := STR0037 //"C๓digo de Retorno -4 : Nใo existe o produto associado a um insumo do projeto no m๓dulo TOP. Verifique."
							Otherwise
								cMensagem := STR0038 + " " +Alltrim(Str(nReturn))+ " " + STR0039 //"C๓digo de Retorno "": Falha na integra็ใo da apropriacao do produto no projeto."
						EndCase

						Aviso(STR0010, cMensagem,{"OK"},3) //'Integra็ใo TOP x ERP Protheus'
					Else
						cMensagem := STR0040 //"Retorno Maior que 0 ou igual a zero"
					EndIf

					PMSRMSOLUMLOG(cMensagem,STR0041,FunName(),nReturn) //"Retorno da Procedure"
				EndIf
				
				If TCSPExist( cNameProc )
					nExec := TcSqlExec('DROP PROCEDURE '+cNameProc)
					If nExec < 0
						PMSRMSOLUMLOG(STR0031 + " " +cNameProc,'DROP PROCEDURE '+cNameProc,FunName(),nExec)//'Erro na exclusao da procedure '
					EndIf
				Endif
			Else
				PMSRMSOLUMLOG(STR0030 + " " +cNameProc,cQuery,FunName(),nExec)//'Erro na criacao da procedure '
			EndIf
		EndIf
	Endif
Endif
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMS_CTT   บAutor  ณClovis Magenta      บ Data ณ  22/03/10	  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza na tabela tcpg de cadastro de Centro de custo 	  บฑฑ
ฑฑบ          ณTOP                                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMS_CTT(nOper)

Local aAreaCTT := CTT->(GetArea())
Local cQuery := ""
Local cBlqLan := "1"
Local nColigada := GetNewPar("MV_RMCOLIG",0) // coligada igual a empresa
Local nERPConn   := 0
Local nSolumConn := -1
Local lMsgUnica	:= IsIntegTop()

If !(lMsgUnica)
	IF !IntTopTin(nColigada)
		Do case
			// --> 0-INCLUIR, 1-ALTERAR, 2-APAGAR
			Case nOper==VM_INSERT
				cOperacao := "0"
			Case nOper==VM_UPDATE
				cOperacao := "0"
			Otherwise
				cOperacao := "1"
		EndCase

		If CTT->CTT_BLOQ == "1" // Centro de custo Bloqueado
			cBlqLan := "0"
		Endif
		// Pega a conexao do ByYouDBAccess corrente do Protheus
		nERPConn := AdvConnection()

		// Pega a conexao do ByYouDBAccess corrente do TOP
		nSolumConn := CnnSolum()

		// se houver conexao do ByYouDBAccess com o TOP
		If (nSolumConn>0)

			// efetua a conexao ByYouDBAccess com o banco de dados TOP
			tcSetConn(nSolumConn)
			TcInternal( 8, STR0022  ) //"Sincronizacao Microsiga Protheus x TOP"

			If nColigada > 0 .AND. cOperacao == "0"
				if UPPER(tcgetdb()) == "ORACLE"
					cQuery := "BEGIN "
					If TCSPExist("SP_CCUSTO_TOPPROT")
						cQuery += "SP_CCUSTO_TOPPROT ("
					Else
						cQuery += "sp_Cadastro_CentroDeCusto ("
					Endif

					cQuery +=         AllTrim(Str(nColigada))  + " "
					cQuery += ", '" + AllTrim(CTT->CTT_CUSTO)  + "' " //varchar(5)
					cQuery += ", '" + FmtStrPrc(CTT->CTT_DESC01) + "' " //P_Nome VARCHAR(100)
					cQuery += ", null " //DCODCOLIGADANULL  -coligada da conta gerencial
					cQuery += ", null " // DCODCONTA
					cQuery += ", null " //DCODCOLIGADANULL - codigo coligada da conta gerencial default
					cQuery += ", null " //DCODCONTA - conta gerencial
					cQuery += ", '"+Alltrim(CTT->CTT_RES)+"' " //varchar
					cQuery += ", null " //varchar
					If CTT->(FieldPos("CTT_BLOQ"))>0
		                cQuery += ", "+iIf(CTT->CTT_BLOQ=="1" ,"0","1")+"" //BIT  Ativo=1 no RM=.T.  Ativo=0 no RM=.F. Ativo>0 no RM=.T.
					Else
		                cQuery += ", 1 " //BIT    Ativo=1 no RM=.T.
					Endif

					cQuery += ", "+cBlqLan + " " //BIT
					cQuery += ", null " //varchar
					cQuery += ", 0 " //BIT
					cQuery += ", 0 " //int
					cQuery += ", 0 " //P_TipoMovimento  INT --> 0. INCLUIR/ALTERAR, 1. APAGAR
					cQuery += "); END; "

				Else
					cQuery := "" //"EXEC "
					If TCSPExist("SP_CCUSTO_TOPPROT")
						cQuery += "SP_CCUSTO_TOPPROT "
					Else
						cQuery += "sp_Cadastro_CentroDeCusto "
					Endif

					cQuery += " @CodColigada = " + AllTrim(Str(nColigada)) + " "
					cQuery += ",@CODCCUSTO = '"+AllTrim(CTT->CTT_CUSTO)+"' " //varchar(5)
					cQuery += ",@NOME = '"+FmtStrPrc(CTT->CTT_DESC01)+"' " //@Nome VARCHAR(100)
					cQuery += ",@CODCOLCONTAGER = null" //DCODCOLIGADANULL  -coligada da conta gerencial
					cQuery += ",@CODCONTAGER = null" // DCODCONTA
					cQuery += ",@CODCOLCONTA = null" //DCODCOLIGADANULL - codigo coligada da conta gerencial default
					cQuery += ",@CODCONTA = null" //DCODCONTA - conta gerencial
					cQuery += ",@CODREDUZIDO = '"+Alltrim(CTT->CTT_RES)+"'" //varchar
					cQuery += ",@CAMPOLIVRE = null" //varchar
					If CTT->(FieldPos("CTT_BLOQ"))>0
		                cQuery += ",@ATIVO = "+iIf(CTT->CTT_BLOQ=="1" ,"0","1")+"" //BIT  Ativo=1 no RM=.T.  Ativo=0 no RM=.F. Ativo>0 no RM=.T.
					Else
		                cQuery += ",@ATIVO = 1 " //BIT    Ativo=1 no RM=.T.
					Endif

					cQuery += ",@PERMITELANC = "+cBlqLan+"" //BIT
					cQuery += ",@CODCLASSIFICA = null " //varchar
					cQuery += ",@ENVIASPED = 0 " //BIT
					cQuery += ",@ID = 0" //int
					cQuery += ",@TipoMovimento = 0" //@TipoMovimento  INT --> 0. INCLUIR/ALTERAR, 1. APAGAR

				EndIf

				// Executa a Stored Procedure
				PMSExecSOLUM(cQuery)

			Endif

			// Se a conexao ByYouDBAccess for maior que zero, deve desconectar
			If nSolumConn >0
				TCUnLink(nSolumConn)
			EndIf
			// volta pra conexao ByYouDBAccess Padrao
			tcSetConn(nERPConn)

		Endif
	Endif
Endif
RestArea(aAreaCTT)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMSExecSOLบAutor  ณReynaldo Miyashita  บ Data ณ  02/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Executa uma query no banco de dados do TOP                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMSExecSOLUM(cQuery)

Local nExec		:= 0
Local cMsgError	:= ""
Local cMsgCode	:= ""
Local cSp			:= ""

Local nColigada	:= GetNewPar("MV_RMCOLIG",0)
Local lMsgUnica	:= IsIntegTop()

DEFAULT cQuery	:= ""
If !(lMsgUnica)
	If nColigada >0 .AND. !Empty(cQuery)
		
		If UPPER(tcgetdb()) == "ORACLE"
			cSP := AllTrim(StrTran(Separa(cQuery,"(")[1],"BEGIN ",""))
		Else
			cSP := AllTrim(Separa(cQuery,"@")[1])
		Endif
		
		If TCSPExist(cSP)
		
			// executa a Query no banco de dados TOP
			nExec:= tcSqlExec(cQuery)
	
			If ValType(nExec) == "N" .AND. nExec < 0
	
				cMsgError := "Execution SQL failed - Error Code: "+allTrim(Str(nExec))
				cMsgCode  := TcSQLError()
				If !Empty(cMsgCode)
					cMsgError += " :" + cMsgCode
				Else
					cMsgError += " :Error Message undefined"
				EndIf
	
			ElseIf ValType(nExec) == "C" .AND. nExec = "0"  // Alterado para '0' = Falha e '1' = Sucesso
	
				cMsgError := "Execution SQL failed - Error Code: "+allTrim(Str(nExec))
				cMsgCode  := TcSQLError()
				If !Empty(cMsgCode)
					cMsgError += " :" + cMsgCode
				Else
					cMsgError += " :Error Message undefined"
				EndIf
	
			ElseIf ValType(nExec) == "A" .AND. Len(nExec) >= 2 .AND. nExec[1] == 0
	
				cMsgError := "Execution SQL failed: "
				cMsgCode  :=  nExec[2]
				If !Empty(cMsgCode)
					cMsgError += " :" + cMsgCode
				Else
					cMsgError += " :Error Message undefined"
				EndIf
	
			ElseIf ValType(nExec) == "U"
	
				conOut( STR0042 + " "  + subs(cQuery, at("sp_",cQuery),10), ValType(nExec), time()) //"Falha na PMSExecSolum. Sem retorno na chamada da Stored Procedure "
	
			ElseIf ValType(nExec) <> "N"
	
				conOut( STR0027 + " "  + subs(cQuery, at("sp_",cQuery),10) , ValType(nExec), time() ) // "Retorno nao esperado da stored produre "
			Endif
	
			PMSRMSOLUMLOG(cMsgError,cQuery,FunName(),nExec)
		Endif

	EndIf
Endif
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMSUPDSOLUบAutor  ณReynaldo Miyashita  บ Data ณ  02/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza as tabelas AF8,AFC,AF9 do Protheus conforme        บฑฑ
ฑฑบ          ณVIEW do TOP                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMSUPDSOLUM(nERPConn,nSolumConn)
Local cQuery := ""

Local cCodProjet:= "d_i_f_e_r_e_n_t_e"
Local c_PROJET	:= ""
Local c_TAREFA	:= ""
Local c_REVISA	:= ""
Local nColigada	:= GetNewPar("MV_RMCOLIG",0)
Local aIDSync	:= {}
Local aIDSyncAll:= {}
Local nCnt		:= 0
Local c_IDSinc  := ""
Local nAlfa		:= 0
Local nOmega	:= 0
Local aFaixas	:= {}
Local c_EDT1    := ""
Local nAte      := 0
Local lNaoAchou := .F.
Local lMsgUnica	:= IsIntegTop()
Local lRet			:= .T.
Local aRet			:= {.F.,"",{}}
Local c_CNO		:= ""
Local c_IDOBRA	:= ""
Local c_CGC		:= ""
Local aExcSON		:= {}
Local cCodCNO		:= ""
Local avwSync		:= {}

If !(lMsgUnica)

	//1- IDENTIFICADOR =0/PROJETO sem o codigo de tarefa (NULL)
	//2- IDENTIFICADOR =0/OBRA  e com o codigo de tarefa
	//3- IDENTIFICADOR =1/ETAPA  (obs: a qtde eh igual a zero na EDT)
	//4- IDENTIFICADOR =2/TAREFA

	// Pega a conexao do ByYouDBAccess corrente do TOP
	nSolumConn := CnnSolum()

	While vwSync->(!Eof())
		//
		// verificar as tratativas
		//
		//////////////////////////////////////////////////////

		c_PROJET := left(vwSync->CODPRJ,Len(AF8->AF8_PROJET))
		c_TAREFA := left(vwSync->CODTRF,Len(AF9->AF9_TAREFA))
		c_EDT1   := left(vwSync->CODPRJ,Len(AF9->AF9_TAREFA))
		c_REVISA := "0001"
		c_IDSinc := vwSync->IDSincronismo
		
		avwSync:= vwSync->(Dbstruct()) //Carrega estrutura de campos da view
		If AF8->(ColumnPos("AF8_CNO")) > 0 .AND. Ascan(avwSync,{|x| x[1]=="CNOPRJ"}) > 0 // Verifica se tanto Protheus como TOP estใo com campos atualizados
			c_CNO	  := vwSync->CNOPRJ
			c_IDOBRA := cValToChar(vwSync->INDPRESTSRV)
			c_CGC	  := left(vwSync->CGCCFO,Len(SON->ON_CGC))
		EndIf

		aAdd( aIDSyncAll ,{c_PROJET, c_TAREFA, c_IDSinc, ""} )

		if vwSync->STATUS == "E"
			// Exclui o registro da tabela do PMS
			// se for uma EDT (Etapa =1 ou Obra,Projeto=0)
			lNaoAchou := .F.
			If vwSync->IDENTIFICADOR == 0 .or. vwSync->IDENTIFICADOR == 1
				dbSelectArea("AFC")
				If AFC->(dbSeek(xFilial("AFC")+c_PROJET+c_REVISA+c_TAREFA))
					RecLock("AFC",.F.,.T.)
					dbDelete()
					MsUnlock()
					lNaoAchou := .T.
				EndIf

				// Exclusao do PROJETO e da EDT principal- Chave: FILIAL + PROJETO + REVISAO + PROJETO
				If vwSync->IDENTIFICADOR == 0 .And. Empty(c_TAREFA)
					dbSelectArea("AFC")
					If AFC->(dbSeek(xFilial("AFC")+c_PROJET+c_REVISA+left(vwSync->CODPRJ,Len(AF9->AF9_TAREFA)) ))
						RecLock("AFC",.F.,.T.)
						dbDelete()
						MsUnlock()
					EndIf

					dbSelectArea("AF8")
					dbSetOrder(1)
					If AF8->(dbSeek(xFilial("AF8")+c_PROJET))
						RecLock("AF8",.F.,.T.)
						dbDelete()
						MsUnlock()
						lNaoAchou := .T.
						If !Empty(c_CNO)
							tcSetConn(nERPConn)
							SON->(DBSetOrder(3))
	  	 					If SON->(DBSeek(xFilial("SON")+c_CNO))
	  	 						cCodCNO := SON->ON_CODIGO
	  	 						aExcSON := ExcSON(cCodCNO)
	  	 					EndIf
							tcSetConn(nSolumConn)
							If !aExcSON[1] //Apenas informa a causa do registro SON nใo ser excluido mas nใo aborta o processo.
								MostraErro()
							EndIf
						EndIf
					Endif
				EndIf
			EndIf

			If vwSync->IDENTIFICADOR == 2
				dbSelectArea("AF9")
				If AF9->(dbSeek(xFilial("AF9")+c_PROJET+c_REVISA+c_TAREFA))
					RecLock("AF9",.F.,.T.)
					dbDelete()
					MsUnlock()
					lNaoAchou := .T.
				EndIf
			EndIf

			If lNaoAchou
				aAdd( aIDSync ,c_IDSinc )
				aIDSyncAll[ len(aIDSyncAll) ] [4] := 'Exclusao - Cod. inexist/PROTHEUS'
			Else
				aAdd( aIDSync ,c_IDSinc )
			Endif

		Else
			//
			// Inclui ou altera registros da tabela do PMS
			//

			If Select("MTRF")>0
				MTRF->(dbCloseArea())
			EndIf

			// Cabecalho do projeto e a EDT PRINCIPAL
			// 1 cod_tarefa = NULL .And. identificador == 0
			//
			IF	Empty(c_TAREFA)

				IF vwSync->STATUS =='I' .And. vwSync->IDENTIFICADOR == 0
					
					If !Empty(c_CNO)
						aRet := PMSI200WN( 3, c_PROJET, c_CNO, left(vwSync->DESCRICAO,Len(SON->ON_DESC)), c_IDOBRA, c_CGC )
					
						If !aRet[1]
	                 		lRet := .F.
	                 		MostraErro()
	               	EndIf
               	EndIf
						
					If lRet
						lNew1 := !(AF8->(dbSeek(xFilial("AF8")+c_PROJET)))
						RecLock("AF8",lNew1)
						AF8->AF8_FILIAL := xFilial("AF8")
						AF8->AF8_PROJET := c_PROJET
						AF8->AF8_REVISA := c_REVISA
						AF8->AF8_DESCRI := vwSync->DESCRICAO
						AF8->AF8_TPPRJ  := "0001"
						AF8->AF8_FASE   := "03"  // em execucao - conforme tabela AEA
						AF8->AF8_CTRUSR := "2"
						If AF8->(ColumnPos("AF8_CNO")) >0
							AF8->AF8_CNO := aRet[2]
						EndIf
	
						AF8->(MsUnLock())
	
						lNew2 := !(AFC->(dbSeek(xFilial("AFC")+c_PROJET+c_REVISA+c_PROJET)))
						RecLock("AFC",lNew2)
						AFC->AFC_FILIAL := xFilial("AFC")
						AFC->AFC_PROJET := c_PROJET
						AFC->AFC_REVISA := c_REVISA
						AFC->AFC_EDT    := c_EDT1
						AFC->AFC_DESCRI := vwSync->DESCRICAO
						AFC->AFC_NIVEL  := "001"
						AFC->AFC_UM     := vwSync->UNIDADEDEMEDIDA
						AFC->AFC_QUANT  := vwSync->QUANTIDADEPREVISTA
						AFC->AFC_CUSTO  := vwSync->CUSTOTOTAL
						AFC->AFC_TOTAL  := vwSync->PRECOVENDATOTAL
						AFC->(MsUnLock())
	
						aAdd( aIDSync ,c_IDSinc )
	
						If vwSync->CodFilial>'0'
							tcSetConn(nSolumConn)
							//
							// Procedure desenvolvida pela RM para que informe que houve a movimentacao(importacao)
							// no projeto para que seja bloqueado a alteracao no codigo da filial destino(Filial Protheus)
							//
	
							If UPPER(tcgetdb()) == "ORACLE"
								cQuery := "BEGIN "
								If TCSPExist("SP_SETAMOV_TOPPROT")
									cQuery += "SP_SETAMOV_TOPPROT ("
								Else
									cQuery += "sp_SetaMovimentacao ("
								Endif
	
								cQuery +=        AllTrim(Str(nColigada)) + " "
								cQuery += ", " + Str(vwSync->IDPRJ) + " "
								cQuery += ",1 ); END; "
							Else
								cQuery := ""
								If TCSPExist("SP_SETAMOV_TOPPROT")
									cQuery += "SP_SETAMOV_TOPPROT "
								Else
									cQuery += "sp_SetaMovimentacao_Solum_Protheus "
								Endif
	
								cQuery += "@CodColigada = " + AllTrim(Str(nColigada)) + " "
								cQuery += ",@IdPrj = " + AllTrim(Str(vwSync->IDPRJ)) + " "
								cQuery += ",@Movimento = 1 "
							Endif
	
							PMSExecSOLUM(cQuery)
							
							tcSetConn(nERPConn)
						EndIf
					EndIf
				Elseif vwSync->STATUS =='A' .And. vwSync->IDENTIFICADOR == 0
					lNew1     := (AF8->(dbSeek(xFilial("AF8")+c_PROJET)))
					lExistePRJ:= lNew1
					
					If !Empty(c_CNO)
						aRet := PMSI200WN( 4, c_PROJET, c_CNO, left(vwSync->DESCRICAO,Len(SON->ON_DESC)), c_IDOBRA, c_CGC )
						If !aRet[1]
	                 		lRet := .F.
	                 		MostraErro()
	               	EndIf
               	EndIf
					
					If lRet
						IF lExistePRJ
							lNew1 := !(AF8->(dbSeek(xFilial("AF8")+c_PROJET)))
							RecLock("AF8",lNew1)
							AF8->AF8_DESCRI := vwSync->DESCRICAO
							If AF8->(ColumnPos("AF8_CNO")) >0
								cCNOAntigo := AF8->AF8_CNO
								AF8->AF8_CNO := aRet[2]
							EndIf
							AF8->(MsUnLock())
							aAdd( aIDSync ,c_IDSinc)
							If AF8->(ColumnPos("AF8_CNO")) >0 .AND. cCNOAntigo <> aRet[2]
								tcSetConn(nERPConn)
								aExcSON := ExcSON(cCNOAntigo)
								tcSetConn(nSolumConn)
								If !aExcSON[1] //Apenas informa a causa do registro SON nใo ser excluido mas nใo aborta o processo.
									MostraErro()
								EndIf
							EndIf
							lNew := !(AFC->(dbSeek(xFilial("AFC")+c_PROJET+c_REVISA+c_EDT1)))
							RecLock("AFC",lNew)
							AFC->AFC_DESCRI := vwSync->DESCRICAO
							AFC->(MsUnLock())
							aAdd( aIDSync ,c_IDSinc )
						Else
							If !lExistePRJ
								// Erro de dados
								aAdd( aIDSync ,c_IDSinc )
								aIDSyncAll[ len(aIDSyncAll) ][4] := 'Error CODTRF NULL'
								MsgAlert(STR0073 + " "  + AllTrim(c_Projet) + " " + STR0074 + CRLF + STR0075)//"O Projeto" "Nใo existe no Protheus." "Verifique a integridade dos dados"
							EndIf
						Endif
					EndIf
				Else
					// Erro de dados
					aAdd( aIDSync ,c_IDSinc )
					aIDSyncAll[ len(aIDSyncAll) ][4] := 'Error CODTRF NULL'
				Endif
			ELSE  //Tem Tarefa
				lNew1     := (AF8->(dbSeek(xFilial("AF8")+c_PROJET)))
				lExistePRJ:= lNew1
				IF 	vwSync->STATUS =='A' .And. vwSync->IDENTIFICADOR == 0
					IF lExistePRJ
	                    lNew   := AFC->(dbSeek(xFilial("AFC")+c_PROJET+c_REVISA+c_TAREFA))
	                    IF lNew
	                        RecLock("AFC",!(lNew))
	                        AFC->AFC_DESCRI := vwSync->DESCRICAO
	                        AFC->(MsUnLock())
	                        aAdd( aIDSync ,c_IDSinc )
	                   Else
	                        // Erro de dados
	                        aAdd( aIDSync ,c_IDSinc )
	                        aIDSyncAll[ len(aIDSyncAll) ][4] := 'Error CODTRF NULL'

	                   Endif


					Else
						// Erro de dados
						aAdd( aIDSync ,c_IDSinc )
						aIDSyncAll[ len(aIDSyncAll) ][4] := 'Error CODTRF NULL'
					Endif
				Endif
				tcSetConn(nSolumConn)
				TcInternal( 8, STR0022 ) //"Sincronizacao Microsiga Protheus x TOP"
				//
				// View criada pela RM para visualizar as informa็oes que compoem a estrutura dos projetos
				// referentes a coligada e projeto identificados para atualizacao
				//
				cQuery := "SELECT * FROM vTarefas_Solum_Protheus "
				cQuery += "WHERE CodColigada = " + AllTrim(Str(nColigada))
				cQuery += " AND IdPrj = "        + AllTrim(Str(vwSync->IDPRJ))
				cQuery += " AND COD_TAREFA = '"  + AllTrim(c_TAREFA) + "' "

				PMSRMSOLUMLOG("-- Trace da VIEW vTarefas_Solum_Protheus --",cQuery,FunName(),0)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"MTRF")

				If Select("MTRF")>0

					tcSetConn(nERPConn)
					lNaoAchou := Eof()

					While MTrf->(!Eof())
						nNivel := 1
						cCodTask := c_Tarefa
						nPos := 1
						While nPos >0
							If (nPos := AT(".", cCodTask)) >0
								cCodTask := SUBSTR(cCodTask ,nPos+2)
								nNivel += 1
							EndIf
						EndDo

						//Regra de NORMALIZACAO DE CHAVE
						//PROJETO
						//OBRA  - nao tem como saber se existe a obra. O PMS permite incluir a tarefa sem Obra
						//ETAPA - opcional
						//TAREFA

						lNew1     := (AF8->(dbSeek(xFilial("AF8")+c_PROJET)))
						lExistePRJ:= lNew1

						//
						// EDTs do projeto (obra ou etapa)
						//
						//2 - Obra -  identificador = 0 .And. cod_tarefa <> null
						//3 - Etapa - identificador = 1
						///
						If MTrf->IDENTIFICADOR < 2 .And. lExistePRJ  .And. !empty(MTrf->COD_TAREFA)  // MTrf->IDENTIFICADOR == 0 OR 1
							lNew := !(AFC->(dbSeek(xFilial("AFC")+c_PROJET+c_REVISA+c_TAREFA)))
							RecLock("AFC",lNew)
							AFC->AFC_FILIAL := xFilial("AFC")
							AFC->AFC_PROJET := c_PROJET
							AFC->AFC_EDT    := c_TAREFA
							AFC->AFC_REVISA := c_REVISA
							AFC->AFC_DESCRI := iIf(Empty(MTrf->DESC_TAREFA),MTrf->NOME_TAREFA,MTrf->DESC_TAREFA)
							AFC->AFC_NIVEL  := StrZero(nNivel+1,3)
							If AllTrim(c_TAREFA) == AllTrim(MTrf->COD_TAREFA_PAI)
								AFC->AFC_EDTPAI := c_PROJET
							Else
								AFC->AFC_EDTPAI := MTrf->COD_TAREFA_PAI
							EndIf
							AFC->AFC_FATURA := "1"
							AFC->AFC_UM     := vwSync->UNIDADEDEMEDIDA
							AFC->AFC_QUANT  := vwSync->QUANTIDADEPREVISTA
							AFC->AFC_CUSTO  := vwSync->CUSTOTOTAL
							AFC->AFC_TOTAL  := vwSync->PRECOVENDATOTAL
							AFC->(MsUnLock())
							aAdd( aIDSync ,c_IDSinc )
						EndIf

						//
						// tarefas do projeto - identificador = 2
						//
						If MTrf->IDENTIFICADOR == 2  .And. lExistePRJ
							lNew := !(AF9->(dbSeek(xFilial("AF9")+c_PROJET+c_REVISA+c_TAREFA)))
							RecLock("AF9",lNew)
							AF9->AF9_FILIAL := xFilial("AF9")
							AF9->AF9_PROJET := c_PROJET
							AF9->AF9_REVISA := c_REVISA
							AF9->AF9_TAREFA := c_TAREFA
							AF9->AF9_DESCRI := iIf(Empty(MTrf->DESC_TAREFA),MTrf->NOME_TAREFA,MTrf->DESC_TAREFA)
							AF9->AF9_NIVEL  := StrZero(nNivel+1,3)
							If Alltrim(c_TAREFA) == AllTrim(MTrf->COD_TAREFA_PAI)
								AF9->AF9_EDTPAI := c_PROJET
							Else
								AF9->AF9_EDTPAI := MTrf->COD_TAREFA_PAI
							EndIf
							AF9->AF9_FATURA := "1"
							AF9->AF9_UM     := vwSync->UNIDADEDEMEDIDA
							AF9->AF9_QUANT  := vwSync->QUANTIDADEPREVISTA
							AF9->AF9_CUSTO  := vwSync->CUSTOTOTAL
							AF9->AF9_TOTAL  := vwSync->PRECOVENDATOTAL
							AF9->(MsUnLock())
							aAdd( aIDSync ,c_IDSinc )
						EndIf

						If !lExistePRJ
							// Dado existente na tabela vTarefas_Solum_Protheus e inexistente no PROTHEUS
							aAdd( aIDSync ,c_IDSinc )
							aIDSyncAll[ len(aIDSyncAll) ] [4] := 'Prj inexistente no PROTHEUS'
							MsgAlert ( STR0073+ " "  + alltrim(c_Projet) + " " +STR0076+ " "  + alltrim(c_Tarefa) + " " + STR0074+ CRLF + STR0075)// "O Projeto" " da tarefa " "Nใo existe no Protheus." "Verifique a integridade dos dados"
						Endif

						MTrf->(dbSkip())
						cCodProjet := MTrf->COD_PROJETO
					EndDo

					If lNaoAchou
						// Dado inexistente na tabela vTarefas_Solum_Protheus
						aAdd( aIDSync ,c_IDSinc )
						aIDSyncAll[ len(aIDSyncAll) ] [4] := 'SEM/IDPrj vTarefas'
					Endif

					MTRF->(dbCloseArea())
				Else
					// Erro na execucao do select
					aAdd( aIDSync ,c_IDSinc )
					aIDSyncAll[ len(aIDSyncAll) ] [4] := 'Error Select MTRF'
				Endif
			Endif
		Endif

		vwSync->(dbSkip())
	EndDo

	vwSync->(dbCloseArea())
	tcSetConn(nSolumConn)

	//
	// Procedure criada pela RM para exclusao dos "registros de log" da estrutura dos projetos do TOP
	// que foram processados no Protheus

	// For nCnt := 1 to Len(aIDSync)
	//                                                   Alfa,Omega  Alfa,Omega  Alfa,Omega
	// EXCLUSAO POR FAIXAS - define as faixas existentes { {1,10},    (12,12},    (15,20}, ... }
	// DIMINUIR O NRO DE SELECT, Tratando por faixas
	///

	aFaixas := {}
	nCnt	:= 1
	nAte	:= len(aIDSync)

	While nCnt <= nAte
		nAlfa	:= val( Str(aIdSync[nCnt] ) )
		nOmega	:= val( Str(aIdSync[nCnt] ) )

		While nCnt <= nAte .And. val( Str(aIdSync[nCnt] ) ) = nOmega
			nCnt	+= 1
			nOmega	+= 1
		Enddo
		aAdd(aFaixas, {nAlfa, nOmega-1} )
	Enddo

	For nCnt := 1 to Len(aFaixas)

		If UPPER(tcgetdb()) == "ORACLE"
			cQuery := "BEGIN "
			If TCSPExist("SP_EXCSINCR_TOPPROT")
				cQuery += "SP_EXCSINCR_TOPPROT ("
			Else
				cQuery += "sp_ExcluiSincronismo_2 ("
			Endif
			cQuery +=         AllTrim(Str(aFaixas[nCnt][1] )) + " "
			cQuery +=  ", " + AllTrim(Str(aFaixas[nCnt][2] )) + " "
			cQuery += "); END; "
		Else
			cQuery := ""
			If TCSPExist("SP_EXCSINCR_TOPPROT")
				cQuery += "SP_EXCSINCR_TOPPROT "
			Else
				cQuery += "sp_ExcluiSincronismo_Solum_Protheus_2 "
			Endif
			cQuery += "  @vIdSincronismo_Inicial = "+ AllTrim(Str(aFaixas[nCnt][1] )) + " "
			cQuery += ", @vIdSincronismo_Fim = "    + AllTrim(Str(aFaixas[nCnt][2] )) + " "
		Endif

		PMSExecSOLUM(cQuery)
		
	Next nCnt

	ConOut( STR0043, time() ) //"finalizado"

	// Se a conexao ByYouDBAccess for maior que zero, deve desconectar
	If nSolumConn >=0
		TCUnLink(nSolumConn)
	EndIf

	tcSetConn(nERPConn)
Endif
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCnnSolum  บAutor  ณReynaldo Miyashita  บ Data ณ  02/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria e abre a conexao com a base de dados do TOP de         บฑฑ
ฑฑบ          ณacordo com os parametros configurados no arquivo de         บฑฑ
ฑฑบ          ณconfigura็๕es do servidor do protheus. Jแ que esta conexao  บฑฑ
ฑฑบ          ณ้ executada atrav้s do TopConnect.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CnnSolum(lAbort,lFuncMsgUni)
Local __nConecta := 0
Local cDatabase := ""
Local cAlias := ""
Local cServer := ""
Local cConType := ""
Local cHasMapper := ""
Local cProtect := ""
Local cMensagem := ""
Local nPort := 0
Local lMsgUnica	:= IsIntegTop()

Default lFuncMsgUni := .F.

DEFAULT lAbort := .T. 
If !lMsgUnica .Or. lFuncMsgUni
	cDataBase  := GetPvProfString("TopConnect","DataBase","ERROR",GetADV97())
	cAlias     := GetPvProfString("TopConnect","AliasRM","ERROR",GetADV97())
	cServer    := GetPvProfString("TopConnect","Server","ERROR",GetADV97())
	cConType   := Upper(GetPvProfString("TopConnect","Contype","TCPIP",GetADV97()))
	cHasMapper := Upper(GetPvProfString("TopConnect","Mapper","ON",GetADV97()))
	cProtect   := GetPvProfString("TopConnect","ProtheusOnly","0",GetADV97())
	nPort      := Val(GetPvProfString("TopConnect","Port","0",GetADV97()))

	cDataBase  := GetSrvProfString("TopDataBase",cDataBase)
	cAlias     := GetSrvProfString("TopAliasRM",cAlias)
	cServer    := GetSrvProfString("TopServer",cServer)
	cConType   := Upper(GetSrvProfString("TopContype",cConType))
	cHasMapper := Upper(GetSrvProfString("TopMapper",cHasMapper))
	cProtect   := GetSrvProfString("TopProtheusOnly",cProtect)
	nPort      := Val(GetSrvProfString("TopPort",StrZero(nPort,4,0)))

	cProtect := iIf(cProtect == "1" ,"@@__@@" ,"")    //Assinatura para o TOP

	// Se a conexao ByYouDBAccess for maior que zero, deve desconectar
	If __nConecta > 0
		TCUnLink(__nConecta)
	EndIf

	__nConecta := -1
	__nConecta := TCLink(cProtect+"@!!@"+cDataBase+"/"+cAlias,cServer,nPort)
	TcInternal( 12, 'ON' )

	If (__nConecta < 0)
		Do Case
			Case ( __nConecta == -34 )
				cMensagem := "No license" //TOPConnect - Excedeu licen็as.

			Case ( __nConecta == -99 )
				cMensagem := "Incompatible version" //"A versao do TOPConnect e incompativel com o servidor Protheus, atualize o TOPConnect"

			OtherWise
				cMensagem := "Connection failed - DataBase:"+cDataBase+" Alias:"+cAlias+" Server:"+cServer+" Port:"+AllTrim(Str(nPort,10)) // 'TOPConnect - Falha de conexao' ## Erro

		EndCase
		If !Empty(cMensagem)
			If lAbort
				Ms_Quit()
			EndIf
		EndIf
	EndIf
Endif
Return __nConecta

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMSExistCPบAutor  ณReynaldo Miyashita  บ Data ณ  02/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSubstitui a rotina ExistCPO() quando chamadas para as       บฑฑ
ฑฑบ          ณtabelas AF8,AFC,AF9.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMSExistCPO(cAlias,cCampo,nIndex)
Local lExist := .F.
PMSVIEWSOLUM()
lExist := ExistCPO(cAlias ,cCampo ,nIndex)

Return lExist

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณSlMCalcNecณ Autor ณ Reynaldo Miyashita    ณ Data ณ   -  -     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณMonta um array contendo a necessidade dos produtos            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณSIGAPMS                                                       ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SlmCalcNec(cProjeto ,cRevisa ,cTarefaDe ,cTarefaAte ,aProdutos ,aRateados ,aSolum )
Local aArea		 := GetArea()
Local aAreaAFC	 := AFC->(GetArea())
Local aAreaAF8	 := AF8->(GetArea())
Local aAreaAFJ	 := AFJ->(GetArea())

Local nColigada  := GetNewPar("MV_RMCOLIG",0)
Local nERPConn   := -1
Local nSolumConn := -1
Local cQuery     := ""

Local cTarefa  := ""
Local dDataPrf := stod("")
Local cProduto := ""
Local nQuant   := 0
Local l1070 := .T.
Local lMsgUnica	:= IsIntegTop()

If PMSCorpore()>="10.70"
	l1070 := .T.
EndIf

SB1->(dbSetOrder(1))
AF8->(dbSetOrder(1))
AF8->(MsSeek(xFilial("AF8")+cProjeto))
If !(lMsgUnica)
	If nColigada > 0

		// Pega a conexao do ByYouDBAccess corrente do Protheus
		nERPConn := AdvConnection()

		//
		// abrir as tabelas protheus
		//
		dbSelectArea("AF8")
		aAreaAF8 := GetArea()
		dbSelectArea("AFC")
		aAreaAFC := GetArea()
		dbSelectArea("AF9")
		aAreaAF9 := GetArea()
		dbSelectArea("SB1")
		dbSelectArea("SB2")
		dbSelectArea("SG1")

		// Pega a conexao do ByYouDBAccess corrente do TOP
		nSolumConn := CnnSolum()

		If (nSolumConn>0)
			tcSetConn(nSolumConn)
			TcInternal( 8, STR0022) //"Sincronizacao Microsiga Protheus x TOP"

			If Select("vwMov")>0
				vwMov->(dbCloseArea())
			EndIf
			cQuery := "SELECT IsNull(IDPROTHEUS ,0) as IDPROTHEUS ,COD_TAREFA ,CODFILIAL ,IDMOV, NUMEROMOV, CODIGOPRD ,QUANTIDADE "
			cQuery += "FROM vMovimento_Solum_Protheus "
			cQuery += "INNER JOIN vTarefas_Solum_Protheus ON "
			cQuery += "vMovimento_Solum_Protheus.IDPRJ = vTarefas_Solum_Protheus.IDPRJ "
			cQuery += "AND vMovimento_Solum_Protheus.IDTRF = vTarefas_Solum_Protheus.IDTRF "
			cQuery += "AND vMovimento_Solum_Protheus.CODCOLIGADA = vTarefas_Solum_Protheus.CODCOLIGADA "
			cQuery += "WHERE vMovimento_Solum_Protheus.CODCOLIGADA=" + AllTrim(Str(nColigada)) + " "
			cQuery += "AND CODFILIAL = '"+ PADR(cFilAnt,LEN(SM0->M0_CODFIL))+"' "
			cQuery += "AND COD_PROJETO = '"+ cProjeto +"' "
			cQuery += "AND COD_TAREFA BETWEEN '"+ cTarefaDe +"' AND '"+ cTarefaAte +"' "
			cQuery += "AND IDPROTHEUS IS NULL "
			PMSRMSOLUMLOG("-- Trace da VIEW vMovimentos_Solum_Protheus --",cQuery,FunName(),0)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"vwMov")
			If Select("vwMov")>0

				tcSetConn(nERPConn)

				// varre os movimentos para gerar os empenhos.
				// E caso precise as solicitacoes de compra e ordens de producaox
				While vwMov->(!Eof())
					//posiciona no produto
					If SB1->(MsSeek(xFilial("SB1")+vwMov->CODIGOPRD))
						// se o produto nao faz parte do filtro de grupo, produto e data de apropriacao
						If SB1->B1_GRUPO  < M->AFK_GRPDE .Or. SB1->B1_GRUPO  > M->AFK_GRPATE
							dbSelectArea("vwMov")
							dbSkip()
							Loop
						EndIf

						// nao eh um produto do tipo beneficiamento ou de mao de obra
						If SB1->B1_TIPO != "BN" .and. SB1->B1_TIPO != "MO"

							cTarefa  := vwMov->Cod_Tarefa  // codigo da tarefa do projeto
							dDataPrf := dDatabase          // DATA DA solicitacao
							cProduto := SB1->B1_COD        // codigo do Produto
							nQuant   := vwMov->QUANTIDADE  // Quantidade solicitada no movimento do TOP para atender a tarefa

							aAdd(aProdutos ,{cProduto, dDataPrf, nQuant, 0, "", "" ,""})
							aAdd(aRateados ,{Len(aProdutos) ,{{cProjeto ,pmsAF8Ver(cProjeto) ,cTarefa ,nQuant ,0 ,0 ,"" ,""}}})
							aAdd(aSolum    ,{Len(aProdutos) ,vwMov->IDMov})

						EndIf

					EndIf

					dbSelectArea("vwMov")
					dbSkip()
				EndDo
				vwMov->(dbCloseArea())
			EndIf // vwMov - Tabela de movimentos
			// Se a conexao ByYouDBAccess for maior que zero, deve desconectar
			If nSolumConn >=0
				TCUnLink(nSolumConn)
			EndIf
			tcSetConn(nERPConn)
		EndIf
	EndIf
Endif
RestArea(aAreaAFC)
RestArea(aAreaAF8)
RestArea(aAreaAFJ)
RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSLMPMSCOSTบAutor  ณReynaldo Miyashita  บ Data ณ  02/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza no TOP a tabela de apropriacao                     บฑฑ
ฑฑบ          ณ MISMAPROP. E grava o id de apropria็ใo gerado para a       บฑฑ
ฑฑบ          ณMISAPROP na tabela do SIGAPMS que houve a integra็ใo.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SLMPMSCOST(nOperacao, cAlias ,dAprop, cProjeto, cTarefa, cProduto, nQtd, nCustUnit, cObs)
Local nExec    := 0
Local nPosID   := 0
Local nCount   := 0
Local cIDAprop := ""
Local aFieldID := {}
Local aArea    := GetArea()
Local lMsgUnica	:= IsIntegTop()

If !(lMsgUnica)

	// nome dos campos que se referem a ID de apropriacao do TOP
	aFieldID := {"AJC_ID",; // Apontamento direto
	"AFS_ID",; // Documentos de saida(NF de saida) (SD2)
	"AFN_ID",; // Documento de entrada (NF de entrada) (SD1)
	"AFI_ID",; // Movimentos internos (SD3)
	"AFU_ID" ; // Apontamento de recursos
	}

	//				 "AFM_ID",; // Apontamentos de ordem de producao (SD3)
	//				 "AFR_ID",; // Despesas financeiras (titulos a pagar)
	//				 "AJE_ID" ; // Movimentacao bancaria

	// Busca a existencia do campo atrav้s do alias informado
	For nCount := 1 to Len(aFieldID)
		// se encontrar o campo, encerra a procura
		If (nPosID := (cAlias)->(FieldPos(aFieldID[nCount])))>0
			Exit
		EndIf
	Next nCount

	// caso encontrado, existe integracao com PMS
	If nPosID >0

		cIDAprop := (cAlias)->(FieldGet(nPosID))
		If nOperacao > 1
			dAprop := iIf(dAprop == NIL ,dDatabase ,dAprop)
			cProjeto := iIf(cProjeto == NIL ,(cAlias)->&(cAlias+"_PROJET"),cProjeto)
			cTarefa  := iIf(cTarefa == NIL ,(cAlias)->&(cAlias+"_TAREFA"),cTarefa)
			cProduto := iIf(cProduto == NIL ,(cAlias)->&(cAlias+"_COD"),cProduto)
			nQtd := iIf(nQtd == NIL ,0,nQtd)
			nCustUnit := iIf(nCustUnit == NIL ,0,nCustUnit)
			cObs := iIf(cObs == NIL ,"",cObs)
		EndIf
			nExec := 0

		If nExec == 0
		// nใo gerou a aproriacao, o usuario deve escolher em uma lista de insumos do projeto
		Else
			Do Case
				Case nExec = -1
					CONOUT(STR0044) //"Erro na Apropria็ใo: Nใo encontrou o ID do projeto"
				Case nExec = -2
					CONOUT(STR0045) //"Erro na Apropria็ใo: Nใo encontrou o ID da tarefa"
				Case nExec = -3
					CONOUT(STR0046) //"Erro na Apropria็ใo: Nใo encontrou o ID do produto"
				Case nExec = -4
					CONOUT(STR0047) //"Erro na Apropria็ใo: Nใo encontrou o ID do insumo"
				Case nExec = -5
					CONOUT(STR0048) //"Erro na Apropria็ใo: Nใo encontrou o ID de apropria็ใo de altera็ใo"
				Case nExec = -6
					CONOUT(STR0049) //"Erro na Apropria็ใo: Nใo encontrou o ID de apropria็ใo de exclusใo "
				Otherwise
					CONOUT(STR0050 + str(nExec)) //"Erro na Apropria็ใo: Nใo definido -> "
			EndCase
			// retornos:
			// -1. Nใo encontrou o ID do projeto
			// -2. Nใo enconrou o ID da tarefa
			// -3. Nใo encontrou o ID do produto
			// -4. Nใo encontrou o ID do insumo
			// -5. Nใo encontrou o ID de apropriacao de alteracao
			// -6. Nใo encontrou o ID de apropriacao de exclusao

		EndIf
	EndIf
Endif
restArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSlmValid  บAutor  ณReynaldo Miyashita  บ Data ณ  02/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para validar se existe insumo associado ao produto,  บฑฑ
ฑฑบ          ณprojeto e coligada informados como parametro pelo Protheus  บฑฑ
ฑฑบ          ณna tabela de insumos MISM do TOP.                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SlmValid(cProjeto ,cProduto)
Local aArea      := GetArea()
Local nColigada  := GetNewPar("MV_RMCOLIG",0) // coligada igual a empresa
Local nERPConn   := -1
Local nSolumConn := -1
Local lRet       := .T.
Local lMsgUnica	:= IsIntegTop()

If !(lMsgUnica)
	If nColigada >0

		lRet := .F.

		// Pega a conexao do ByYouDBAccess corrente do Protheus
		nERPConn := AdvConnection()

		// Pega a conexao do ByYouDBAccess corrente do TOP
		nSolumConn := CnnSolum()

		If (nSolumConn>0)
			// Seto a conexao para o banco de dados da TOP
			tcSetConn(nSolumConn)
			TcInternal( 8, STR0022 ) //"Sincronizacao Microsiga Protheus x TOP"

			// busca se existe o produto relacionado a um insumo do projeto no TOP
			If !Empty(cProjeto) .AND. !Empty(cProduto)
				If Select("vwSync")>0
					vwSync->(dbCloseArea())
				EndIf
				//
				// Query que seleciona o ID do insumo do projeto que estiver associado com os produtos que foram informados
				//
				cQuery := "SELECT IDISM "
				cQuery += "FROM MISMPRD "
				cQuery += "INNER JOIN MPRJ ON MPRJ.CODCOLIGADA = "+str(nColigada)+ " AND CODPRJ = '"+cProjeto+"' AND MPRJ.IDPRJ = MISMPRD.IDPRJ "
				cQuery += "INNER JOIN TPRD ON TPRD.CODCOLIGADA = "+str(nColigada)+ " AND TPRD.CODIGOPRD = '"+cProduto+"' AND TPRD.IDPRD = MISMPRD.IDPRD "

				//PMSRMSOLUMLOG("-- Trace da TABELA mIsmPrd --",cQuery,FunName(),0)  // Wilson em 09/06/2011
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"vwSync")
				If Select("vwSync")>0
					If vwSync->(!Bof() .AND. !Eof())
						lRet := .T.
					Else
						//
						// Nใo existe produto relacionado ao insumo do projeto
						//
						PMSRMSOLUMLOG(STR0051) //"Nใo existe insumo associado a este produto no projeto. Verifique."
					EndIf

					vwSync->(dbCloseArea())
				Else
					PMSRMSOLUMLOG("-- Trace da TABELA mIsmPrd --",cQuery,FunName(),0)
				EndIf
			EndIf

			// Se a conexao ByYouDBAccess for maior que zero, deve desconectar
			If nSolumConn >=0
				TCUnLink(nSolumConn)
			EndIf
		EndIf

		// Retorna a conexao do ByYouDBAccess corrente do Protheus
		tcSetConn(nERPConn)

	EndIf
Endif
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMSLOAD   บAutor  ณ                    บ Data ณ    /  /     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Executa a sincronizacao das tabelas entre Protheus e       บฑฑ
ฑฑบ          ณTOP.     E ativa os gatilhos das tabelas de cadastro do     บฑฑ
ฑฑบ          ณProtheus.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMSLOAD()
Local aDados	:= {}
Local nInc		:= 0

If PMSINTSOLUM()
	PMSVIEWSOLUM()
Endif

// Cadastro de Eventos de Projetos
If AliasInDic( "AN5" )
	aAdd( aDados, { "000000000000001", "APONTAMENTO COM HORA EXCEDENTE"	, "PMSA320" } )
	aAdd( aDados, { "000000000000002", "APONTAMENTO COM HORA EXCEDENTE"	, "PMSA321" } )
	aAdd( aDados, { "000000000000003", "REJEICAO DE PLANO DE ACAO"		, "QNC50BXPEND" } )
	aAdd( aDados, { "000000000000004", "APONTAMENTO DE HORAS EXCEDIDAS"	, "PMS320GRAVA" } )
	aAdd( aDados, { "000000000000005", "REJEICAO DE TAREFA"				, "PMSMONIT" } )
	aAdd( aDados, { "000000000000006", "APROVACAO DE REJEICAO DE TAREF"	, "PMSMONIT" } )
	aAdd( aDados, { "000000000000007", "REJEICAO DE REJEICAO DE TAREFA"	, "PMSMONIT" } )
	//                                  123456789012345678901234567890

	// Realiza a grava็ใo das tabelas
	DbSelectArea( "AN5" )
	AN5->( DbSetOrder( 1 ) )
	For nInc := 1 To Len( aDados )
		If AN5->( !DbSeek( xFilial( "AN5" ) + aDados[nInc][1] ) )
			RecLock( "AN5", .T. )
			AN5->AN5_FILIAL	:= xFilial( "AN5" )
			AN5->AN5_EVENT	:= aDados[nInc][1]
			AN5->AN5_DESCRI	:= aDados[nInc][2]
			AN5->AN5_ROTINA	:= aDados[nInc][3]
			MsUnlock()
		EndIf
	Next
EndIf

If AliasInDic("AN3")
	dbSelectArea("AN3")
	PmsChkAN3()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PMSINITFUN บAutor  ณ TOTVS S/A        บ Data ณ  21/01/2014 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExecuta as funcoes de inicializacao do modulo de PMS        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPMS                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMSINITFUN()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ MA215CHECK - Funcao utilizada para verificar se no momento da abertura  |
//ณ              do modulo existem tabelas exclusivas abertas pela rotina   |
//|              MATA215 ou por outro processo.                             |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If FindFunction("MA215CHECK")
	MA215CHECK()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOMLOAD   บAutor  ณ                    บ Data ณ    /  /     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Executa a sincronizacao das tabelas entre Protheus e       บฑฑ
ฑฑบ          ณTOP.     E ativa os gatilhos das tabelas de cadastro do     บฑฑ
ฑฑบ          ณProtheus.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function COMLOAD()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ MA215CHECK - Funcao utilizada para verificar se no momento da abertura  |
//ณ              do modulo existem tabelas exclusivas abertas pela rotina   |
//|              MATA215 ou por outro processo.                             |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If FindFunction("MA215CHECK")
	MA215CHECK()
EndIf

If PMSINTSOLUM()
	PMSVIEWSOLUM()
Endif

//Ajusta quantidade jแ entregue do PC com base nas notas de devolu็ใo.
COMAJQJEPC()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Realiza Bloqueio automatico de Inventario com base no parametro MV_BLQINVA ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
MATA271(.T.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ COMINITFUN บAutor  ณ TOTVS S/A        บ Data ณ  21/01/2014 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExecuta as funcoes de inicializacao do modulo de compras    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACOM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function COMINITFUN()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ MA215CHECK - Funcao utilizada para verificar se no momento da abertura  |
//ณ              do modulo existem tabelas exclusivas abertas pela rotina   |
//|              MATA215 ou por outro processo.                             |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If FindFunction("MA215CHECK")
	MA215CHECK()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATINITFUN บAutor  ณ                   บ Data ณ    /  /     บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Executa a sincronizacao das tabelas entre Protheus e       บฑฑ
ฑฑบ          ณTOP.     E ativa os gatilhos das tabelas de cadastro do     บฑฑ
ฑฑบ          ณProtheus.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FATINITFUN()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ MA215CHECK - Funcao utilizada para verificar se no momento da abertura  |
//ณ              do modulo existem tabelas exclusivas abertas pela rotina   |
//|              MATA215 ou por outro processo.                             |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If FindFunction("MA215CHECK")
	MA215CHECK()
EndIf

If PMSINTSOLUM()
	PMSVIEWSOLUM()
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณU_SIGAADV บAutor  ณ                    บ Data ณ    /  /     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Executa a sincronizacao das tabelas entre Protheus e       บฑฑ
ฑฑบ          ณTOP.     E ativa os gatilhos das tabelas de cadastro do     บฑฑ
ฑฑบ          ณProtheus.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ADVINITFUN()

If PMSINTSOLUM()
	PMSVIEWSOLUM()
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PMSRetID บAutor  ณ Reynaldo Miyashita บ Data ณ  14/05/2009 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna um array com os alias e campos que se referem a ID บฑฑ
ฑฑบ          ณ de apropriacao do TOP                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PMSFldSlm()
//
Return( {;
 {"AJC","AJC_ID","C","10"}; 				// Apontamento direto
,{"AFS","AFS_ID","C","10"}; 				// Documentos de saida(NF de saida) (SD2)
,{"AFN","AFN_ID","C","10"}; 				// Documento de entrada (NF de entrada) (SD1)
,{"AFI","AFI_ID","C","10"}; 				// Movimentos internos (SD3)
,{"AFU","AFU_ID","C","10"}; 				// Apontamento de recursos
,{"AFG","AFG_IDPROT","C","10"};	   	// Solicitacao de Compra
,{"AJ7","AJ7_IDPROT","C","10"};			// Pedido de Compra
,{"SC6","C6_PMSID","C","10"}; 			// Pedido de venda
,{"AFM","AFM_IDPROT","C","10"};			// Ordem Produ็ใo
,{"AFR","AFR_ID","C","10"};     			// Despesa financeira
,{"AFH","AFH_ID","C","10"};            // Solicita็ใo de Armazem
})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ SLMPreen บAutor  ณ Reynaldo Miyashita บ Data ณ  09/10/2009 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atraves do ID do TOP preenche o ID do Protheus nas         บฑฑ
ฑฑบ          ณ tabelas do TOP atrav้s de procedure do TOP                 บฑฑ
ฑฑบ          ณ cTipo 1 - Solicita็ใo de Compras            				  บฑฑ
ฑฑบ          ณ cTipo 2 - Pedido de Compra								  บฑฑ
ฑฑบ          ณ cTipo 3 - Pedido de Venda 								  บฑฑ
ฑฑบ          ณ cTipo 4 - Ordem de Produ็ใo						          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SLMPreencheID(nIDSolum ,cTipo)
Local nColigada   := GetNewPar("MV_RMCOLIG",0) // coligada igual a empresa
Local cQuery      := ""
Local aAreaTMP    := {}
Local lOk         := .F.
Local nERPConn   := 0
Local nSolumConn := -1
Local lMsgUnica	:= IsIntegTop()

DEFAULT nIDSolum := 0

If !(lMsgUnica)
	If nColigada > 0 .AND. nIDSolum >0

		If cTipo == "1"
			// projeto x solicitacao de compra
			dbSelectArea("AFG")
			aAreaTMP:= AFG->(GetArea())
			If AFG->(FieldPos("AFG_IDPROT")) > 0
				RecLock("AFG",.F.)
				AFG->AFG_IDPROT := STRZERO(nIDSolum,tamsx3("AFG_IDPROT")[1])
				MsUnLock()
				lOk := .T.
			EndIf
			restArea(aAreaTMP)
		ElseIf cTipo == "2"
			// projeto x Pedido de compra
			dbSelectArea("AJ7")
			aAreaTMP:= AJ7->(GetArea())
			If AJ7->(FieldPos("AJ7_IDPROT")) > 0
				RecLock("AJ7",.F.)
				AJ7->AJ7_IDPROT := STRZERO(nIDSolum,tamsx3("AJ7_IDPROT")[1])
				MsUnLock()
			EndIf
			RestArea(aAreaTMP)

		Elseif cTipo == "3"
			// projeto x Pedido de VENDA
			dbSelectArea("SC6")
			aAreaTMP:= SC6->(GetArea())
			If SC6->(FieldPos("C6_PMSID")) > 0
				RecLock("SC6",.F.)
				SC6->C6_PMSID := STRZERO(nIDSolum,tamSx3("C6_PMSID")[1])
				MsUnLock()
			EndIf
			RestArea(aAreaTMP)

		Else
			// projeto x Ordens de Produ็ใo
			dbSelectArea("AFM")
			aAreaTMP:= AFM->(GetArea())
			If AFM->(FieldPos("AFM_IDPROT")) > 0
				RecLock("AFM",.F.)
				AFM->AFM_IDPROT := STRZERO(nIDSolum,tamSx3("AFM_IDPROT")[1])
				MsUnLock()
			EndIf
			RestArea(aAreaTMP)

		EndIf

		If lOk
			// EXECUTA A PROCEDURE QUE VAI ATUALIZAR O MOVIMENTO DO TOP COM id PROTHEUS.
			// Pega a conexao do ByYouDBAccess corrente do Protheus
			nERPConn := AdvConnection()

			// Pega a conexao do ByYouDBAccess corrente do TOP
			nSolumConn := CnnSolum()

			// se houver conexao do ByYouDBAccess com o TOP
			If (nSolumConn>0)

				// efetua a conexao ByYouDBAccess com o banco de dados TOP
				tcSetConn(nSolumConn)

				If UPPER(tcgetdb()) == "ORACLE"
					cQuery := "BEGIN "
					If TCSPExist("SP_IDPROTHEUS_TOPPROT")
						cQuery += "SP_IDPROTHEUS_TOPPROT ("
					Else
						cQuery += "sp_PreencheIdProtheus ("
					Endif
	 				cQuery +=  Alltrim(Str(nColigada)) + " " // INT,
					cQuery += ", " + Str(nIDSolum) + " " // INT,
					cQuery += ", " + Str(nIDSolum) + " " // INT
					cQuery += "); END; "
				Else
					cQuery := ""
					If TCSPExist("SP_IDPROTHEUS_TOPPROT")
						cQuery += "SP_IDPROTHEUS_TOPPROT "
					Else
						cQuery += "sp_PreencheIdProtheus_Solum_Protheus "
					Endif
					cQuery += " @CodColigada = " + Alltrim(Str(nColigada)) + " " // INT,
					cQuery += ",@IdMovimento = " + Alltrim(Str(nIDSolum)) + " " // INT,
					cQuery += ",@IdProtheus = "  + Alltrim(Str(nIDSolum)) + " " // INT
				Endif

				// Executa a Stored Procedure
				PMSExecSOLUM(cQuery)

				// Se a conexao ByYouDBAccess for maior que zero, deve desconectar
				If nSolumConn >0
					TCUnLink(nSolumConn)
				EndIf

				// volta pra conexao ByYouDBAccess Padrao
				tcSetConn(nERPConn)
			Endif
		EndIf

	EndIf
Endif
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ SlmAtuMov บAutor  ณ Reynaldo Miyashita บ Data ณ  09/10/2009 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Se o Item do pedido de compra foi gerado de um solicitacao บฑฑ
ฑฑบ          ณ de compra, a qual este foi gerado pelo planejamento de     บฑฑ
ฑฑบ          ณ necessidades de materiais do projeto.                      บฑฑ
ฑฑบ          ณ Caso tenha sido gerado pelo planejamento deve executar     บฑฑ
ฑฑบ          ณ a procedure do TOP  e efetuar a baixa nas tabelas do TOP   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SlmAtuMov(cProjeto ,cTarefa ,cPedido ,cItem ,nQtde ,nCustoTotal ,cTipo, nEvento)
Local nColigada := GetNewPar("MV_RMCOLIG",0) // coligada igual a empresa
Local aArea     := GetArea()
Local aAreaSC7  := {}
Local aAreaSC6  := {}
Local aAreaSC1  := {}
Local aAreaSCP  := {}
local aAreaAFH  := {}
Local aAreaAJ7  := {}
Local aAreaAFG  :={}
Local aTamSX3   := {}
Local aTamSX3a  := {}
Local aTamSX3b  := {}
Local lOk       := .F.
Local l1070		 := .T.
Local cPRJFilial:= ""
Local nUnitario := 0
Local cDadosEnv := ""
Local cDadosRec := ""
Local nSolumConn:= 0
Local aSPResult := ""
Local lIDAJ7    := AJ7->(FieldPos("AJ7_VIAINT"))>0
Local lIDAFH    := AFH->(FieldPos("AFH_VIAINT"))>0
Local lAFH_VIAINT		 := .F.
Local cMoeda    := Alltrim( GetMv("MV_SIMB1"))
Local lAFG 	   :=AFG->(FieldPos("AFG_VIAINT"))>0
Local lMsgUnica	:= IsIntegTop()
Local cSP       := ""
Default cTipo   := ""
Default nEvento := 0


If (lMsgUnica) .or. !(nColigada > 0)
	Return .T.
EndIf

If PMSCorpore()>="10.70"
	l1070 := .T.
EndIf

cPrjFilial := PADR(cFilAnt,LEN(SM0->M0_CODFIL))

If Type("l103Class") <> "L"
	l103Class := .F.
Endif

If !Empty(cTipo) .and. cTipo =="PV"
	nUnitario := nCustoTotal/nQtde
	aTamSX3  := TamSX3("C6_PRCVEN")
	aTamSX3a := TamSX3("C6_VALOR")
	aTamSX3b := TamSX3("C6_QTDVEN")
	cUnitario:= Str(nUnitario,aTamSX3[1],aTamSX3[2])

	//Posiciono o Sc6 para verificar se existe Nota fiscal de saida
	dbSelectArea("SC6")
	aAreaSC6:= SC6->(GetArea())
	dbSetOrder(1)//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	If dbSeek(xFilial("SC6") + cPedido + cItem)
		If !Empty(SC6->C6_PROJPMS) .AND. !Empty(SC6->C6_TASKPMS)

			// Pega a conexao do ByYouDBAccess corrente do Protheus
			nERPConn := AdvConnection()
			// Pega a conexao do ByYouDBAccess corrente do TOP
			nSolumConn := CnnSolum()

			If (nSolumConn>0)

				// executa a stored procedure informando que foi 100% atendido
				// efetua a conexao ByYouDBAccess com o banco de dados TOP
				tcSetConn(nSolumConn)
				TcInternal( 8, STR0022 ) //"Sincronizacao Microsiga Protheus x TOP"

				// executa a procedure diretamente do banco de dados TOP

				If UPPER(tcgetdb()) == "ORACLE"
					If TCSPExist("SP_STATUSMOV_TOPPROT3")
						cSP:="SP_STATUSMOV_TOPPROT3"
					ElseIf TCSPExist("SP_STATUSMOV_TOPPROT")
						cSP:="SP_STATUSMOV_TOPPROT"
					Else
						cSP:="sp_StatusMovimento"
					Endif
				Else
					If TCSPExist("SP_STATUSMOV_TOPPROT3")
						cSP:="SP_STATUSMOV_TOPPROT3"
					ElseIf TCSPExist("SP_STATUSMOV_TOPPROT")
						cSP:="SP_STATUSMOV_TOPPROT"
					Else
						cSP:="sp_StatusMovimento_Solum_Protheus"
					Endif
				Endif

				aSPResult := TCSPExec( cSP, str(nColigada), SC6->C6_PMSID, Alltrim(SC6->C6_PRODUTO), cPrjFilial, val(cUnitario), nCustoTotal, nQtde, cItem, cTarefa, '', '', '' )
				If ValType( aSPResult ) == "N"
					conout( aSPResult )
				Elseif  ValType( aSPResult ) == "A"
					conout( len(aSPResult), aSPResult[1], aSPResult[2]  )
				Elseif  ValType( aSPResult ) == "U"
					conout( STR0026 + " " +cSP+"(3)", ValType(aSPResult), time() ) //"Retorno nulo da stored produre "
				Else
					conout( STR0027 + " " +cSP+"(3)", ValType(aSPResult), time() ) //"Retorno nao esperado da stored "
				Endif

				cDadosEnv := ""
				cDadosEnv += STR0028 //"Procedure chamada por TCSPEXEC: "
				cDadosEnv += cSP+"(3) "
				cDadosEnv += " par1: "  + Str(nColigada)+ " "
				cDadosEnv += " par2: '" + SC6->C6_PMSID + "' "
				cDadosEnv += " par3: '" + SC6->C6_PRODUTO + "' "
				cDadosEnv += " par4: '" + cPrjFilial + "' "
				cDadosEnv += " par5:  " + cUnitario  + " "
				cDadosEnv += " par6:  " + Str(nCustoTotal ,aTamSX3a[1] ,aTamSX3a[2]) + " "
				cDadosEnv += " par7:  " + Str(nQtde       ,aTamSX3b[1] ,aTamSX3b[2]) + " "
				cDadosEnv += " par8: '" + cItem + "' "
				cDadosEnv += " par9: '" + cTarefa + "' "

				// Se o vetor estiver em vazio, houve erro do banco de dados na chamada da procedure
				If Empty(aSPResult)
					//
					// Retorna a mensagem de erro que o banco de dados detectou
					//
					cMsgError := tcSqlError()

					PMSRMSOLUMLOG(cMsgError,cDadosEnv,FunName())
					//
					// chamada da procedure concluida com sucesso, contem o retorno da procedure
					//
				Else
					cRetCod  := aSPResult[1] // c๓digo do retorno da procedure
					cRetMsg  := aSPResult[2] // mensagem de retorno da procedure

					cDadosRec := ""
					cDadosRec += STR0029 + " " + "-" + " "  //"Valores de retorno
					cDadosRec += "Par1 : '"+ cRetCod + "' "
					cDadosRec += "Par2 : '"+ cRetMsg + "' "

					PMSRMSOLUMLOG(cDadosRec,cDadosEnv,FunName(),0)
					lOk := .T.

				EndIf
				tcSetConn(nERPConn)
			Endif
		EndIf
	Endif
	RestArea(aAreaSC6)
ElseIf cTipo == "SA"
	nUnitario := nCustoTotal/nQtde
	aTamSX3  := TamSX3("B2_CM1")
	aTamSX3a := TamSX3("B2_QATU")
	aTamSX3b := TamSX3("CP_QUANT")
	cUnitario:= Str(nUnitario,aTamSX3[1],aTamSX3[2])

	//Posiciono o Sc6 para verificar se existe Nota fiscal de saida
	dbSelectArea("SCP")
	aAreaSCP:= SCP->(GetArea())
	dbSelectArea("AFH")
	aAreaAFH:= AFH->(GetArea())
	SCP->(dbSetOrder(1)) //CP_FILIAL+CP_NUM+CP_ITEM+CP_EMISSAO
	AFH->(dbSetOrder(2)) //AFH_FILIAL+AFH_NUMSA+AFH_ITEMSA+AFH_PROJET+AFH_REVISA+AFH_TAREFA
	AFH->(dbSeek(xFilial("AFH") + cPedido + cItem + SD3->D3_PROJPMS + StrZero(1,TamSx3("AFH_REVISA")[1]) + SD3->D3_TASKPMS))
	If lIDAFH
		lAFH_VIAINT:=	IIf(AFH->AFH_VIAINT == 'S' .And. AFH->(!EOF()),.T.,.F.)
	EndIf

	If SCP->(dbSeek(xFilial("SCP") + cPedido + cItem)) .And. lAFH_VIAINT
		// Pega a conexao do ByYouDBAccess corrente do Protheus
		nERPConn := AdvConnection()
		// Pega a conexao do ByYouDBAccess corrente do TOP
		nSolumConn := CnnSolum()

		If (nSolumConn>0)

			// executa a stored procedure informando que foi 100% atendido
			// efetua a conexao ByYouDBAccess com o banco de dados TOP
			tcSetConn(nSolumConn)
			TcInternal( 8, STR0022 ) //"Sincronizacao Microsiga Protheus x TOP"
			// executa a procedure diretamente do banco de dados TOP   WWW
			If UPPER(tcgetdb()) == "ORACLE"
				If TCSPExist("SP_STATUSMOV_TOPPROT3")
					cSP:="SP_STATUSMOV_TOPPROT3"
					aSPResult := TCSPExec( "SP_STATUSMOV_TOPPROT3", AllTrim(str(nColigada)), "B" + SCP->CP_NUM, AllTrim(SCP->CP_PRODUTO), cPrjFilial, Val(cUnitario), nCustoTotal, nQtde, SCP->CP_ITEM, cTarefa, "SA;" + SCP->CP_NUM, cMoeda, AFI->AFI_NUMSEQ )
				ElseIf TCSPExist("SP_STATUSMOV_TOPPROT112040")
					cSP:="SP_STATUSMOV_TOPPROT112040"
					aSPResult := TCSPExec( "SP_STATUSMOV_TOPPROT112040" ,Alltrim(str(nColigada)) ,"B"+SCP->CP_NUM ,Alltrim(SCP->CP_PRODUTO) ,cPrjFilial ,val(cUnitario) ,nCustoTotal ,nQtde, SCP->CP_ITEM, "SA;"+SCP->CP_NUM , cMoeda,AFI->AFI_NUMSEQ )
				Else
					cSP:="sp_StatusMovimento"
					aSPResult := TCSPExec( "sp_StatusMovimento" ,Alltrim(str(nColigada)) ,"B"+SCP->CP_NUM ,Alltrim(SCP->CP_PRODUTO) ,cPrjFilial ,val(cUnitario) ,nCustoTotal ,nQtde, SCP->CP_ITEM,"SA;"+SCP->CP_NUM , cMoeda,AFI->AFI_NUMSEQ )
				Endif
			Else
				If TCSPExist("SP_STATUSMOV_TOPPROT3")
					aSPResult := TCSPExec( "SP_STATUSMOV_TOPPROT3", Alltrim(str(nColigada)), "B" + SCP->CP_NUM, Alltrim(SCP->CP_PRODUTO), cPrjFilial, Val(cUnitario), nCustoTotal, nQtde, SCP->CP_ITEM, cTarefa, "SA;" + SCP->CP_NUM, cMoeda, AFI->AFI_NUMSEQ )
				ElseIf TCSPExist("SP_STATUSMOV_TOPPROT112040")
					aSPResult := TCSPExec( "SP_STATUSMOV_TOPPROT112040" ,Alltrim(str(nColigada)),"B"+SCP->CP_NUM ,Alltrim(SCP->CP_PRODUTO) ,cPrjFilial ,val(cUnitario) ,nCustoTotal ,nQtde, SCP->CP_ITEM, "SA;"+SCP->CP_NUM , cMoeda,AFI->AFI_NUMSEQ )
				Else
					cSP:="sp_StatusMovimento_Solum_Protheus"
					aSPResult := TCSPExec( "sp_StatusMovimento_Solum_Protheus" ,str(nColigada) ,"B"+SCP->CP_NUM ,Alltrim(SCP->CP_PRODUTO) ,cPrjFilial ,val(cUnitario) ,nCustoTotal ,nQtde, SCP->CP_ITEM, "SA;"+SCP->CP_NUM , cMoeda,AFI->AFI_NUMSEQ )
				Endif
			Endif
			If ValType( aSPResult ) == "N"
				conout( aSPResult )
			Elseif  ValType( aSPResult ) == "A"
				conout( len(aSPResult), aSPResult[1], aSPResult[2]  )
			Elseif  ValType( aSPResult ) == "U"
				conout( STR0026 + " " +cSP+"(2)", ValType(aSPResult), time() ) //"Retorno nulo da stored produre "
			Else
				conout( STR0027 + " " +cSP+"(2)", ValType(aSPResult), time() )//"Retorno nao esperado da stored produre "
			Endif


			cDadosEnv := ""
			cDadosEnv += STR0028+ " " //"Procedure chamada por TCSPEXEC: "
			cDadosEnv += cSP+"(2) "
			cDadosEnv += " par1: "   + Str(nColigada)+ " "
			cDadosEnv += " par2: 'B" + SCP->CP_NUM + "' "
			cDadosEnv += " par3: '"  + AllTrim(SCP->CP_PRODUTO) + "' "
			cDadosEnv += " par4: '"  + cPrjFilial + "' "
			cDadosEnv += " par5:  "  + cUnitario  + " "
			cDadosEnv += " par6:  "  + Str(nCustoTotal ,aTamSX3a[1] ,aTamSX3a[2]) + " "
			cDadosEnv += " par7:  "  + Str(nQtde       ,aTamSX3b[1] ,aTamSX3b[2]) + " "
			cDadosEnv += " par8: '"  + SCP->CP_ITEM + "'"
			cDadosEnv += " par9: '"  + cTarefa + "'"
			cDadosEnv += " par10: '"  + "SA;"+SCP->CP_NUM + "' "
			cDadosEnv += " par11: '"  + cMoeda + "'"
			cDadosEnv += " par12: '"  + AFI->AFI_NUMSEQ + "'"
			// Se o vetor estiver em vazio, houve erro do banco de dados na chamada da procedure
			If Empty(aSPResult)
				//
				// Retorna a mensagem de erro que o banco de dados detectou
				//
				cMsgError := tcSqlError()

				PMSRMSOLUMLOG(cMsgError,cDadosEnv,FunName())
				//
				// chamada da procedure concluida com sucesso, contem o retorno da procedure
				//
			Else
				cRetCod  := aSPResult[1] // c๓digo do retorno da procedure
				cRetMsg  := aSPResult[2] // mensagem de retorno da procedure

				cDadosRec := ""
				cDadosRec += STR0029 + " " + "-" + " " //"Valores de retorno
				cDadosRec += "Par1 : '"+ cRetCod + "' "
				cDadosRec += "Par2 : '"+ cRetMsg + "' "

				PMSRMSOLUMLOG(cDadosRec,cDadosEnv,FunName(),0)
				lOk := .T.
			EndIf
			tcSetConn(nERPConn)
		EndIf
	Else
	 	IF lIDAFH
			If SCP->(dbSeek(xFilial("SCP") + cPedido + cItem)) .And. AFH->(dbSeek(xFilial("AFH") + cPedido + cItem + SD3->D3_PROJPMS + StrZero(1,TamSx3("AFH_REVISA")[1]) + SD3->D3_TASKPMS )) .And. !lAFH_VIAINT
				PMS_AFH(cProjeto ,cTarefa ,cPedido ,cItem ,nQtde ,nCustoTotal ,cTipo, nEvento)
			Endif
		Else
			if SCP->(dbSeek(xFilial("SCP") + cPedido + cItem)) .And. AFH->(dbSeek(xFilial("AFH") + cPedido + cItem + SD3->D3_PROJPMS + StrZero(1,TamSx3("AFH_REVISA")[1]) + SD3->D3_TASKPMS))
				PMS_AFH(cProjeto ,cTarefa ,cPedido ,cItem ,nQtde ,nCustoTotal ,cTipo, nEvento)
			EndIf
		Endif
	Endif
	RestArea(aAreaAFH)
	RestArea(aAreaSCP)

Else  // ctipo='PC'
	// VERIFICAR SE VEIO DO TOP OU NAO ATRAVES DE UMA S.A.
	
	// valida se o valor do item serแ passado com ou sem descontos
	If getnewpar("MV_ITVALIQ",.T.) 
		nUnitario := nCustoTotal/nQtde
	else
		nUnitario := SD1->D1_VUNIT
	EndIf
	
	aTamSX3  := TamSX3("D1_VUNIT")
	aTamSX3a := TamSX3("D1_TOTAL")
	aTamSX3b := TamSX3("D1_QUANT")
	cUnitario:= Str(nUnitario,aTamSX3[1],aTamSX3[2])
	//Posiciono o SC7 para verificar se existe pedido de compra
	dbSelectArea("SC7")
	aAreaSC7:= SC7->(GetArea())
	dbSetOrder(1)//C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
	If dbSeek(xFilial("SC7") + cPedido + cItem)
		// Pedido de compra associado ao projeto
		If Empty(SC7->C7_NUMSC)
			// Busca na amarracao do Pedido de compra com a tarefa do projeto
			dbSelectArea("AJ7")
			aAreaAJ7:= AJ7->(GetArea())
			dbSetOrder(2) //AJ7_FILIAL+AJ7_NUMPC+AJ7_ITEMPC+AJ7_PROJET+AJ7_REVISA+AJ7_TAREFA
			If lIDAJ7
				//PC foi originado pelo TOP (SP_STATUSMOV_TOPPROT3)
				If DbSeek(xFilial("AJ7") + SC7->C7_NUM + SC7->C7_ITEM + AFN->AFN_PROJET + AFN->AFN_REVISA + AFN->AFN_TAREFA) .AND. AJ7->AJ7_VIAINT == 'S'
					// Pega a conexao do ByYouDBAccess corrente do Protheus
					nERPConn := AdvConnection()
					// Pega a conexao do ByYouDBAccess corrente do TOP
					nSolumConn := CnnSolum()

					If (nSolumConn>0)

						// executa a stored procedure informando que foi 100% atendido
						// efetua a conexao ByYouDBAccess com o banco de dados TOP
						tcSetConn(nSolumConn)
						TcInternal( 8, "Sincronizacao Microsiga Protheus x TOP" )

						// executa a procedure diretamente do banco de dados TOP
						If UPPER(tcgetdb()) == "ORACLE"
							If TCSPExist("SP_STATUSMOV_TOPPROT3")
								cSP:="SP_STATUSMOV_TOPPROT3"
								aSPResult := TCSPExec( cSP, str(nColigada), "E" + SF1->F1_MSIDENT, Alltrim(SC7->C7_PRODUTO), cPrjFilial, Val(cUnitario), nCustoTotal, nQtde, cItem, cTarefa, "PC;" + SC7->C7_NUM, cMoeda, '' )
							ElseIf TCSPExist("SP_STATUSMOV_TOPPROT")
								cSP:="SP_STATUSMOV_TOPPROT"
								aSPResult := TCSPExec( cSP, str(nColigada), "E" + SF1->F1_MSIDENT, Alltrim(SC7->C7_PRODUTO), cPrjFilial, Val(cUnitario), nCustoTotal, nQtde, cItem, "PC;" + SC7->C7_NUM, cMoeda )
							Else
								cSP:="sp_StatusMovimento"
								aSPResult := TCSPExec( cSP, str(nColigada), "E" + SF1->F1_MSIDENT, Alltrim(SC7->C7_PRODUTO), cPrjFilial, Val(cUnitario), nCustoTotal, nQtde, cItem, "PC;" + SC7->C7_NUM, cMoeda )
							Endif
						Else
							If TCSPExist("SP_STATUSMOV_TOPPROT3")
								cSP:="SP_STATUSMOV_TOPPROT3"
								aSPResult := TCSPExec( cSP, str(nColigada), "E" + SF1->F1_MSIDENT, Alltrim(SC7->C7_PRODUTO), cPrjFilial, Val(cUnitario), nCustoTotal, nQtde, cItem, cTarefa, "PC;" + SC7->C7_NUM, cMoeda, '' )
							ElseIf TCSPExist("SP_STATUSMOV_TOPPROT")
								cSP:="SP_STATUSMOV_TOPPROT"
								aSPResult := TCSPExec( cSP, str(nColigada), "E" + SF1->F1_MSIDENT, Alltrim(SC7->C7_PRODUTO), cPrjFilial, Val(cUnitario), nCustoTotal, nQtde, cItem, "PC;" + SC7->C7_NUM, cMoeda )
							Else
								cSP:="sp_StatusMovimento_Solum_Protheus"
								aSPResult := TCSPExec( cSP, str(nColigada), "E" + SF1->F1_MSIDENT, Alltrim(SC7->C7_PRODUTO), cPrjFilial, Val(cUnitario), nCustoTotal, nQtde, cItem, "PC;" + SC7->C7_NUM, cMoeda )
							Endif
						Endif
						If ValType( aSPResult ) == "N"
						Elseif  ValType( aSPResult ) == "A"
						Elseif  ValType( aSPResult ) == "U"
							conout( "Retorno nulo da stored produre "+cSP+"(1)", ValType(aSPResult), time() )
						Else
							conout( "Retorno nao esperado da stored produre "+cSP+"(1)", ValType(aSPResult), time() )
						Endif
						cDadosEnv := ""
						cDadosEnv += "Procedure chamada por TCSPEXEC: "
						cDadosEnv += cSP+"(1) "
						cDadosEnv += " par1: "  + Str(nColigada)+ " "
						cDadosEnv += " par2: '" +"E"+SF1->F1_MSIDENT + "' "
						cDadosEnv += " par3: '" + AllTrim(SC7->C7_PRODUTO) + "' "
						cDadosEnv += " par4: '" + cPrjFilial + "' "
						cDadosEnv += " par5:  " + cUnitario  + " "
						cDadosEnv += " par6:  " + Str(nCustoTotal ,aTamSX3a[1] ,aTamSX3a[2]) + " "
						cDadosEnv += " par7:  " + Str(nQtde       ,aTamSX3b[1] ,aTamSX3b[2]) + " "
						cDadosEnv += " par8: '" + cItem + "'"
						cDadosEnv += " par9: '" + cTarefa + "'"
						cDadosEnv += " par10: '" +"PC;"+SC7->C7_NUM + "' "
						cDadosEnv += " par11: '" +cMoeda+ "' "
						// Se o vetor estiver em vazio, houve erro do banco de dados na chamada da procedure
						If Empty(aSPResult)
							//
							// Retorna a mensagem de erro que o banco de dados detectou
							//
							cMsgError := tcSqlError()

							PMSRMSOLUMLOG(cMsgError,cDadosEnv,FunName())
							//
							// chamada da procedure concluida com sucesso, contem o retorno da procedure
							//
						Else
							cRetCod  := aSPResult[1] // c๓digo do retorno da procedure
							cRetMsg  := aSPResult[2] // mensagem de retorno da procedure

							cDadosRec := ""
							cDadosRec += "Valores de retorno - "
							cDadosRec += "Par1 : '"+ cRetCod + "' "
							cDadosRec += "Par2 : '"+ cRetMsg + "' "

							PMSRMSOLUMLOG(cDadosRec,cDadosEnv,FunName(),0)
							lOk := .T.

						EndIf
						tcSetConn(nERPConn)
					Endif
				Else
					//PC nใo foi originado pelo TOP (ProtheusSolum_NFE)
					If SF1->(FieldPos("F1_MSIDENT")) > 0
						cMSIdent := SF1->F1_MSIDENT
					Else
						cMSIdent := ""
					Endif
						
					If nQtde > 0 //Inclusใo
						NotaAvulsa(1,cMSIdent)
					Else
						NotaAvulsa(3,cMSIdent)
					Endif
				EndIf
			//Nใo tem o campo AJ7_VIAINT (Nใo ้ originado pelo TOP)
			Else
				If SF1->(FieldPos("F1_MSIDENT")) > 0
					cMSIdent := SF1->F1_MSIDENT
				Else
					cMSIdent := ""
				Endif
					
				If nQtde > 0 //Inclusใo
					NotaAvulsa(1,cMSIdent)
				Else
					NotaAvulsa(3,cMSIdent)
				Endif
			Endif
			RestArea(aAreaAJ7)

		Else // cTipo='SC'
			//Se veio de solicitacao de compra
			If SC7->C7_TIPO == 1 // "Controle de Pedido de Compra ou Autorizacao de Entrega" 1 - Pedido de compra
				dbSelectArea("SC1")
				aAreaSC1:= SC1->(GetArea())
				dbSetOrder(1)
				If dbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC)//Verifico se existe na solicitacao de compra
					If lAFG
						dbSelectArea("AFG")
						aAreaAFG:=AFG->(GetArea())
						AFG->(dbSetOrder(2))//AFG_FILIAL+AFG_NUMSC+AFG_ITEMSC+AFG_PROJET+AFG_REVISA+AFG_TAREFA
						
						//SC originada pelo TOP
						If AFG->(dbSeek(xFilial("AFG")+SC7->C7_NUMSC+SC7->C7_ITEMSC + AFN->AFN_PROJET + AFN->AFN_REVISA + AFN->AFN_TAREFA)) .And. AFG->AFG_VIAINT == "S"
							
							// Pega a conexao do ByYouDBAccess corrente do Protheus
							nERPConn := AdvConnection()
							
							// Pega a conexao do ByYouDBAccess corrente do TOP
							nSolumConn := CnnSolum()
							If (nSolumConn>0)
								// executa a stored procedure informando que foi 100% atendido
								// efetua a conexao ByYouDBAccess com o banco de dados TOP
								tcSetConn(nSolumConn)
								TcInternal( 8, "Sincronizacao Microsiga Protheus x TOP" )

											// executa a procedure diretamente do banco de dados TOP
								If UPPER(tcgetdb()) == "ORACLE"
									If TCSPExist("SP_STATUSMOV_TOPPROT3")
										cSP:="SP_STATUSMOV_TOPPROT3"
										aSPResult := TCSPExec( cSP, str(nColigada), "E" + SF1->F1_MSIDENT, Alltrim(SC1->C1_PRODUTO), cPrjFilial, val(cUnitario), nCustoTotal, nQtde, SC1->C1_ITEM/*cItem*/, cTarefa, "SC;" + SC1->C1_NUM, cMoeda, '' )
									ElseIf TCSPExist("SP_STATUSMOV_TOPPROT")
										cSP:="SP_STATUSMOV_TOPPROT"
										aSPResult := TCSPExec( cSP, str(nColigada), "E" + SF1->F1_MSIDENT, Alltrim(SC1->C1_PRODUTO), cPrjFilial, val(cUnitario), nCustoTotal, nQtde, cItem, "SC;" + SC1->C1_NUM, cMoeda )
									Else
										cSP:="sp_StatusMovimento"
										aSPResult := TCSPExec( cSP, str(nColigada), "E" + SF1->F1_MSIDENT, Alltrim(SC1->C1_PRODUTO), cPrjFilial, val(cUnitario), nCustoTotal, nQtde, cItem, "SC;" + SC1->C1_NUM, cMoeda )
									Endif
								Else
									If TCSPExist("SP_STATUSMOV_TOPPROT3")
										cSP:="SP_STATUSMOV_TOPPROT3"
										aSPResult := TCSPExec( cSP, str(nColigada), "E" + SF1->F1_MSIDENT, Alltrim(SC1->C1_PRODUTO), cPrjFilial, val(cUnitario), nCustoTotal, nQtde, SC1->C1_ITEM/*cItem*/, cTarefa, "SC;" + SC1->C1_NUM, cMoeda, '' )
									ElseIf TCSPExist("SP_STATUSMOV_TOPPROT")
										cSP:="SP_STATUSMOV_TOPPROT"
										aSPResult := TCSPExec( cSP, str(nColigada), "E" + SF1->F1_MSIDENT, Alltrim(SC1->C1_PRODUTO), cPrjFilial, val(cUnitario), nCustoTotal, nQtde, cItem, "SC;" + SC1->C1_NUM, cMoeda )
									Else
										cSP:="sp_StatusMovimento_Solum_Protheus"
										aSPResult := TCSPExec( cSP, str(nColigada), "E" + SF1->F1_MSIDENT, Alltrim(SC1->C1_PRODUTO), cPrjFilial, val(cUnitario), nCustoTotal, nQtde, cItem, "SC;" + SC1->C1_NUM, cMoeda )
									Endif
								Endif
								
								If ValType( aSPResult ) == "N"
								Elseif  ValType( aSPResult ) == "A"
								Elseif  ValType( aSPResult ) == "U"
									conout( "Retorno nulo da stored produre "+cSP+"(1)", ValType(aSPResult), time() )
								Else
									conout( "Retorno nao esperado da stored produre "+cSP+"(1)", ValType(aSPResult), time() )
								Endif
								
								cDadosEnv := ""
								cDadosEnv += "Procedure chamada por TCSPEXEC: "
								cDadosEnv += cSP+"(1) "
								cDadosEnv += " par1: "  + Str(nColigada)+ " "
								cDadosEnv += " par2: '" + "E"+SF1->F1_MSIDENT + "' "
								cDadosEnv += " par3: '" + AllTrim(SC1->C1_PRODUTO) + "' "
								cDadosEnv += " par4: '" + cPrjFilial + "' "
								cDadosEnv += " par5:  " + cUnitario  + " "
								cDadosEnv += " par6:  " + Str(nCustoTotal ,aTamSX3a[1] ,aTamSX3a[2]) + " "
								cDadosEnv += " par7:  " + Str(nQtde       ,aTamSX3b[1] ,aTamSX3b[2]) + " "
								cDadosEnv += " par8: '" + cItem + "'"
								cDadosEnv += " par9: '" + cTarefa + "'"
								cDadosEnv += " par10: '" + "SC;"+SC1->C1_NUM + "'"
								cDadosEnv += " par11: '" + cMoeda + "'"

								// Se o vetor estiver em vazio, houve erro do banco de dados na chamada da procedure
								If Empty(aSPResult)
									// Retorna a mensagem de erro que o banco de dados detectou
									cMsgError := tcSqlError()
									PMSRMSOLUMLOG(cMsgError,cDadosEnv,FunName())
								
								// chamada da procedure concluida com sucesso, contem o retorno da procedure
								Else
									cRetCod  := aSPResult[1] // c๓digo do retorno da procedure
									cRetMsg  := aSPResult[2] // mensagem de retorno da procedure

									cDadosRec := ""
									cDadosRec += "Valores de retorno - "
									cDadosRec += "Par1 : '"+ cRetCod + "' "
									cDadosRec += "Par2 : '"+ cRetMsg + "' "
									PMSRMSOLUMLOG(cDadosRec,cDadosEnv,FunName(),0)
									lOk := .T.
							    EndIf
							EndIf
							tcSetConn(nERPConn)
						Else
							//SC nใo foi originada no TOP
							If SF1->(FieldPos("F1_MSIDENT")) > 0
								cMSIdent := SF1->F1_MSIDENT
							Else
								cMSIdent := ""
							Endif
								
							If nQtde > 0 //Inclusใo
								NotaAvulsa(1,cMSIdent)
							Else
								NotaAvulsa(3,cMSIdent)
							Endif
						EndIf
						RestArea(aAreaAFG)
					//Campo AFG_VIANT nใo tem, por isso SC nใo foi originada no TOP
					Else
						If SF1->(FieldPos("F1_MSIDENT")) > 0
							cMSIdent := SF1->F1_MSIDENT
						Else
							cMSIdent := ""
						Endif
							
						If nQtde > 0 //Inclusใo
							NotaAvulsa(1,cMSIdent)
						Else
							NotaAvulsa(3,cMSIdent)
						Endif
					Endif
				EndIf
				RestArea(aAreaSC1)
			EndIf
		EndIf
	Else
		If Empty(cPedido) .And. Empty(cItem)
			If SF1->(FieldPos("F1_MSIDENT")) > 0
				cMSIdent := SF1->F1_MSIDENT
			Else
				cMSIdent := ""
			Endif
				
			If nQtde > 0 //Inclusใo
				NotaAvulsa(1,cMSIdent)
			Else
				NotaAvulsa(3,cMSIdent)
			Endif
		Endif
	EndIf
	RestArea(aAreaSC7)
EndIf
// Se a conexao ByYouDBAccess for maior que zero, deve desconectar
If nSolumConn >0
	TCUnLink(nSolumConn)
	tcSetConn(nERPConn)
EndIf

RestArea(aArea)

Return lOK

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSlmAtu2MovบAutor  ณ Reynaldo Miyashita บ Data ณ  09/10/2009 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Se o Item do pedido de compra foi gerado de um solicitacao บฑฑ
ฑฑบ          ณ de compra, a qual este foi gerado pelo planejamento de     บฑฑ
ฑฑบ          ณ necessidades de materiais do projeto.                      บฑฑ
ฑฑบ          ณ Caso tenha sido gerado pelo planejamento deve executar     บฑฑ
ฑฑบ          ณ a procedure do TOP e efetuar a baixa nas tabelas do SOLUM  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SlmAtu2Mov(cProjeto ,cTarefa ,cPedido ,cItem ,nQtde ,nCustoTotal ,cTipo)
Local nColigada := GetNewPar("MV_RMCOLIG",0) // coligada igual a empresa
Local aArea     := GetArea()
Local aAreaSC7  := {}
Local aAreaSC6  := {}
Local aAreaSC1  := {}
Local aAreaSCP  := {}
Local aAreaAJ7  := {}
Local aTamSX3   := {}
Local lOk       := .F.
Local l1070     := .T.
Local cPRJFilial := ""
Local nERPConn   := 0
Local nSolumConn := -1
Local lMsgUnica	:= IsIntegTop()

If (lMsgUnica) .or. !(nColigada > 0)
	Return .T.
EndIf

If PMSCorpore()>="10.70"
	l1070 := .T.
EndIf

//
// Se cTipo estiver prenchido e for PV deve procurar o pedido de venda
//
If !Empty(cTipo) .and. cTipo =="PV"
	//Posiciono o Sc6 para verificar se existe Nota fiscal de saida
	dbSelectArea("SC6")
	aAreaSC6:= SC6->(GetArea())
	dbSetOrder(1)//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	If dbSeek(xFilial("SC6") + cPedido + cItem)
		If !Empty(SC6->C6_PROJPMS) .AND. !Empty(SC6->C6_TASKPMS)
			//				If Empty(cPRJFilial := Alltrim(Str(Posicione("AF8",1,xFilial("AF8")+cProjeto,"AF8_FILSOL"))))
			cPrjFilial := PADR(cFilAnt,LEN(SM0->M0_CODFIL))
			//				EndIf
			// Pega a conexao do ByYouDBAccess corrente do Protheus
			nERPConn := AdvConnection()

			// Pega a conexao do ByYouDBAccess corrente do TOP
			nSolumConn := CnnSolum()

			// se houver conexao do ByYouDBAccess com o TOP
			If (nSolumConn>0)

				// efetua a conexao ByYouDBAccess com o banco de dados TOP
				// Retorna a conexao do ByYouDBAccess corrente do Protheus
				tcSetConn(nSolumConn)

				if UPPER(tcgetdb()) == "ORACLE"
					cQuery := "BEGIN "

					If TCSPExist("SP_STATUSMOV_TOPPROT")
						cQuery += "SP_STATUSMOV_TOPPROT ("
					Else
						cQuery += "sp_StatusMovimento ("
					Endif
					cQuery += "   " + Alltrim(Str(nColigada))  + " " // INT,
					cQuery += ",  " + Alltrim(SC6->C6_PMSID)   + " " // INT
					cQuery += ", '" + Alltrim(SC6->C6_PRODUTO) + "' " // VARCHAR(30)
					cQuery += ", '" + cPrjFilial + "' " // VARCHAR(100)
					aTamSX3 := TamSX3("C6_PRCVEN")
					cQuery += ", " + Alltrim(Str(nCustoTotal/nQtde ,aTamSX3[1] ,aTamSX3[2])) + " "// DECIMAL,

					aTamSX3 := TamSX3("C6_VALOR")
					cQuery += ", " + Alltrim(Str(nCustoTotal ,aTamSX3[1] ,aTamSX3[2])) + " "  // DECIMAL

					aTamSX3 := TamSX3("C6_QTDVEN")
					cQuery += ", " + alltrim(Str(nQtde ,aTamSX3[1] ,aTamSX3[2]))+ " "
					cQuery += "); END; "

				Else
					// executa a stored procedure informando que foi 100% atendido
					cQuery := ""
					If TCSPExist("SP_STATUSMOV_TOPPROT")
						cQuery += "SP_STATUSMOV_TOPPROT"
					Else
						cQuery += "sp_StatusMovimento_Solum_Protheus "
					Endif
					cQuery += " @CodColigada = " + Alltrim(Str(nColigada)) + " " // INT,
					cQuery += ",@IdProtheus = " + Alltrim(SC6->C6_PMSID) + " " // INT
					cQuery += ",@CodigoPrd = '" + Alltrim(SC6->C6_PRODUTO) + "' " // VARCHAR(30)
					cQuery += ",@CodigoFilial = '" + cPrjFilial + "' " //VARCHAR(100)
					aTamSX3 := TamSX3("C6_PRCVEN")
					cQuery += ",@Unitario = " + Alltrim(Str(nCustoTotal/nQtde ,aTamSX3[1] ,aTamSX3[2])) + " "// DECIMAL,

					aTamSX3 := TamSX3("C6_VALOR")
					cQuery += ",@Total = " + Alltrim(Str(nCustoTotal ,aTamSX3[1] ,aTamSX3[2])) + " "  // DECIMAL

					aTamSX3 := TamSX3("C6_QTDVEN")
					cQuery += ",@Quantidade = " + alltrim(Str(nQtde ,aTamSX3[1] ,aTamSX3[2]))+ " "

				EndIf

				// Executa a Stored Procedure
				PMSExecSOLUM(cQuery)

				// Se a conexao ByYouDBAccess for maior que zero, deve desconectar
				If nSolumConn >0
					TCUnLink(nSolumConn)
				EndIf
				// volta pra conexao ByYouDBAccess Padrao
				tcSetConn(nERPConn)

				lOk := .T.
			Endif

		EndIf

	Else
		lOk := .F.
	EndIf
	RestArea(aAreaSC6)

Else
	//Posiciono o SC7 para verificar se existe pedido de compra
	dbSelectArea("SC7")
	aAreaSC7:= SC7->(GetArea())
	dbSetOrder(1)//C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
	If dbSeek(xFilial("SC7") + cPedido + cItem)
		// Pedido de compra associado ao projeto
		If Empty(SC7->C7_NUMSC)
			// Busca na amarracao do Pedido de compra com a tarefa do projeto
			dbSelectArea("AJ7")
			aAreaAJ7:= AJ7->(GetArea())
			dbSetOrder(2) //AJ7_FILIAL+AJ7_NUMPC+AJ7_ITEMPC+AJ7_PROJET+AJ7_REVISA+AJ7_TAREFA
			If DbSeek(xFilial("AJ7") + SC7->C7_NUM + SC7->C7_ITEM)

				//					If Empty(cPRJFilial := Alltrim(Str(Posicione("AF8",1,xFilial("AF8")+cProjeto,"AF8_FILSOL"))))
				cPrjFilial := PADR(cFilAnt,LEN(SM0->M0_CODFIL))
				//					EndIf

				// Pega a conexao do ByYouDBAccess corrente do Protheus
				nERPConn := AdvConnection()

				// Pega a conexao do ByYouDBAccess corrente do TOP
				nSolumConn := CnnSolum()

				// se houver conexao do ByYouDBAccess com o TOP
				If (nSolumConn>0)

					// efetua a conexao ByYouDBAccess com o banco de dados TOP
					// Retorna a conexao do ByYouDBAccess corrente do Protheus
					tcSetConn(nSolumConn)

					if UPPER(tcgetdb()) == "ORACLE"
						// executa a stored procedure informando que foi 100% atendido
						cQuery := "BEGIN "
						If TCSPExist("SP_STATUSMOV_TOPPROT")
							cQuery += "SP_STATUSMOV_TOPPROT ("
						Else
							cQuery += "sp_StatusMovimento ("
						Endif
						cQuery += "   "     + Alltrim(Str(nColigada))  + " " // INT,
						cQuery += ",  "     + Alltrim(AJ7->AJ7_IDPROT) + " " // INT
						cQuery += ", '"     + Alltrim(AJ7->AJ7_COD)    + "' " // VARCHAR(30)
						cQuery += ", '"     + cPrjFilial + "' " //VARCHAR(100)
						aTamSX3 := TamSX3("C7_PRECO")
						cQuery += ", "      + Alltrim(Str(nCustoTotal/nQtde ,aTamSX3[1] ,aTamSX3[2])) + " "// DECIMAL,

						aTamSX3 := TamSX3("C7_TOTAL")
						cQuery += ", "      + Alltrim(Str(nCustoTotal ,aTamSX3[1] ,aTamSX3[2])) + " "   // DECIMAL

						aTamSX3 := TamSX3("C7_QUANT")
						cQuery += ", "      + Alltrim(Str(nQtde ,aTamSX3[1] ,aTamSX3[2])) + " "
						cQuery += "); END; "

					Else
						// executa a stored procedure informando que foi 100% atendido
						cQuery := ""
						If TCSPExist("SP_STATUSMOV_TOPPROT")
							cQuery += "SP_STATUSMOV_TOPPROT "
						Else
							cQuery += "sp_StatusMovimento_Solum_Protheus "
						Endif
						cQuery += " @CodColigada = "  + Alltrim(Str(nColigada)) + " " // INT,
						cQuery += ",@IdProtheus = "   + Alltrim(AJ7->AJ7_IDPROT) + " " // INT
						cQuery += ",@CodigoPrd = '"   + Alltrim(AJ7->AJ7_COD) + "' " // VARCHAR(30)
						cQuery += ",@CodigoFilial = '" + cPrjFilial + "' " //VARCHAR(100)
						aTamSX3 := TamSX3("C7_PRECO")
						cQuery += ",@Unitario = "     + Alltrim(Str(nCustoTotal/nQtde ,aTamSX3[1] ,aTamSX3[2])) + " "// DECIMAL,

						aTamSX3 := TamSX3("C7_TOTAL")
						cQuery += ",@Total = "        + Alltrim(Str(nCustoTotal ,aTamSX3[1] ,aTamSX3[2])) + " "   // DECIMAL

						aTamSX3 := TamSX3("C7_QUANT")
						cQuery += ",@Quantidade = "   + alltrim(Str(nQtde ,aTamSX3[1] ,aTamSX3[2])) + " "
					EndIf

					// Executa a Stored Procedure
					PMSExecSOLUM(cQuery)

					// Se a conexao ByYouDBAccess for maior que zero, deve desconectar
					If nSolumConn >0
						TCUnLink(nSolumConn)
					EndIf

					// volta pra conexao ByYouDBAccess Padrao
					tcSetConn(nERPConn)

					lOk := .T.
				Endif

			Else
				lOk := .F.
			EndIf

			RestArea(aAreaAJ7)

		Else //Se veio de solicitacao de compra
			If SC7->C7_TIPO == 1 // "Controle de Pedido de Compra ou Autorizacao de Entrega" 1 - Pedido de compra
				dbSelectArea("SC1")
				aAreaSC1:= SC1->(GetArea())
				dbSetOrder(1)
				If dbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC)//Verifico se existe na solicitacao de compra
					// Busca na amarracao da solicitacao de compra com a tarefa do projeto

					dbSelectArea("SCP")
					aAreaSCP:= SCP->(GetArea())

					If (nRec:= GetNumSA(SC7->C7_NUMSC, SC7->C7_ITEMSC)) > 0

						dbSelectArea("SCP")
						aAreaSCP:= SCP->(GetArea())
						dbgoto( nRec )
						dbSelectArea("SC1")
						cPrjFilial := PADR(cFilAnt,LEN(SM0->M0_CODFIL))
						// Pega a conexao do ByYouDBAccess corrente do Protheus
						nERPConn := AdvConnection()

						// Pega a conexao do ByYouDBAccess corrente do TOP
						nSolumConn := CnnSolum()

						// se houver conexao do ByYouDBAccess com o TOP
						If (nSolumConn>0)

							// efetua a conexao ByYouDBAccess com o banco de dados TOP
							// Retorna a conexao do ByYouDBAccess corrente do Protheus
							tcSetConn(nSolumConn)

							If UPPER(tcgetdb()) == "ORACLE"

								// executa a stored procedure informando que foi 100% atendido
								cQuery := "BEGIN "
								If TCSPExist("SP_STATUSMOV_TOPPROT")
									cQuery += "SP_STATUSMOV_TOPPROT ("
								Else
									cQuery += "sp_StatusMovimento ("
								Endif
								cQuery += "   " + Alltrim(Str(nColigada))  + " " // INT,
								cQuery += ",  " + Alltrim(SCP->CP_NUM)     + " " // INT - NRO SA
								cQuery += ", '" + Alltrim(SCP->CP_PRODUTO) + "' " // VARCHAR(30)
								cQuery += ", '" + cPrjFilial + "' " //VARCHAR(100)
								aTamSX3 := TamSX3("C7_PRECO")
								cQuery += ", " + Alltrim(Str(nCustoTotal/nQtde ,aTamSX3[1] ,aTamSX3[2])) + " "// DECIMAL,

								aTamSX3 := TamSX3("C7_TOTAL")
								cQuery += ", " + Alltrim(Str(nCustoTotal ,aTamSX3[1] ,aTamSX3[2]))+ " "   // DECIMAL

								aTamSX3 := TamSX3("C7_QUANT")
								cQuery += ", " + alltrim(Str(nQtde ,aTamSX3[1] ,aTamSX3[2])) + " "
								cQuery += "); END; "
							Else
								// executa a stored procedure informando que foi 100% atendido
								cQuery := ""
								If TCSPExist("SP_STATUSMOV_TOPPROT")
									cQuery += "SP_STATUSMOV_TOPPROT "
								Else
									cQuery += "sp_StatusMovimento_Solum_Protheus "
								Endif
								cQuery += " @CodColigada = " + Alltrim(Str(nColigada))  + " " // INT,
								cQuery += ",@IdProtheus = "  + Alltrim(SCP->CP_NUM)     + " " // INT - NRO SA
								cQuery += ",@CodigoPrd = '"  + Alltrim(SCP->CP_PRODUTO) + "' " // VARCHAR(30)
								cQuery += ",@CodigoFilial = '" + cPrjFilial + "' " //VARCHAR(100)
								aTamSX3 := TamSX3("C7_PRECO")
								cQuery += ",@Unitario = " + Alltrim(Str(nCustoTotal/nQtde ,aTamSX3[1] ,aTamSX3[2])) + " "// DECIMAL,

								aTamSX3 := TamSX3("C7_TOTAL")
								cQuery += ",@Total = " + Alltrim(Str(nCustoTotal ,aTamSX3[1] ,aTamSX3[2]))+ " "   // DECIMAL

								aTamSX3 := TamSX3("C7_QUANT")
								cQuery += ",@Quantidade = " + alltrim(Str(nQtde ,aTamSX3[1] ,aTamSX3[2])) + " "
							EndIf
							// Executa a Stored Procedure
							PMSExecSOLUM(cQuery)

							// Se a conexao ByYouDBAccess for maior que zero, deve desconectar
							If nSolumConn >0
								TCUnLink(nSolumConn)
							EndIf

							// volta pra conexao ByYouDBAccess Padrao
							tcSetConn(nERPConn)

							lOk := .T.
						EndIf
					Endif
					RestArea(aAreaSCP)
				EndIf
				RestArea(aAreaSC1)
			EndIf
		EndIf
	Else
		lOk := .F.
	EndIf
	RestArea(aAreaSC7)

EndIf

RestArea(aArea)
Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMSCorpore บAutor  ณ Reynaldo Miyashita บ Data ณ  09/10/2009 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Informa qual ้ a versใo do TOP que estแ integrada           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PMSCorpore()
Local aArea      := GetArea()
Local nColigada  := GetNewPar("MV_RMCOLIG",0) // coligada igual a empresa
Local nERPConn   := -1
Local nSolumConn := -1
Local cQuery := ""
Local cCorpVersion := ""
Local lMsgUnica	:= IsIntegTop()

If !(lMsgUnica)
	If nColigada >0

		lRet := .F.

		// Pega a conexao do ByYouDBAccess corrente do Protheus
		nERPConn := AdvConnection()

		// Pega a conexao do ByYouDBAccess corrente do TOP
		nSolumConn := CnnSolum()

		If (nSolumConn>0)
			// Seto a conexao para o banco de dados da
			tcSetConn(nSolumConn)
			TcInternal( 8, STR0022 ) //"Sincronizacao Microsiga Protheus x TOP"

			//
			// Query que seleciona o ID do insumo do projeto que estiver associado com o produto que foram informados
			//
			cQuery := "SELECT VERSAOMINIMA "
			cQuery += "FROM GSISTEMA "
			cQuery += "WHERE NOMESISTEMA = 'RM SOLUM' "
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"vwVersion")
			If Select("vwVersion")>0
				cCorpVersion := vwVersion->VERSAOMINIMA
			EndIf
			vwVersion->(dbCloseArea())

			// Se a conexao ByYouDBAccess for maior que zero, deve desconectar
			If nSolumConn >=0
				TCUnLink(nSolumConn)
			EndIf
		EndIf

		// Retorna a conexao do ByYouDBAccess corrente do Protheus
		tcSetConn(nERPConn)

	EndIf
Endif
RestArea(aArea)

Return( cCorpVersion )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ESTLOAD  บAutor  ณ Pedro Pereira Lima บ Data ณ  26/11/2009 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Executa a sincronizacao das tabelas entre Protheus e       บฑฑ
ฑฑบ          ณTOP.     E ativa os gatilhos das tabelas de cadastro do     บฑฑ
ฑฑบ          ณProtheus quando start do modulo estoque/custos.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMSXSOLUM                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ESTINITFUN()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ MA215CHECK - Funcao utilizada para verificar se no momento da abertura  |
//ณ              do modulo existem tabelas exclusivas abertas pela rotina   |
//|              MATA215 ou por outro processo.                             |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If FindFunction("MA215CHECK")
	MA215CHECK()
EndIf

If PMSINTSOLUM()
	PMSVIEWSOLUM()
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CTBLOAD  บAutor  ณ Clovis Magenta     บ Data ณ  22/03/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Executa a sincronizacao das tabelas entre Protheus e       บฑฑ
ฑฑบ          ณTOP.     E ativa os gatilhos das tabelas de cadastro do     บฑฑ
ฑฑบ          ณProtheus quando start do modulo Contabilidade Gerencial.    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PMSXSOLUM                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTBINITFUN()
If PMSINTSOLUM()
	PMSVIEWSOLUM()
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PMS_SBZ  บAutor  ณ Pedro Pereira Lima บ Data ณ  27/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza na tabela TPRD de produtos do TOP                 บฑฑ
ฑฑบ          ณ conforme alteracoes na tabela SBZ.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMS_SBZ(cCpo,nOper)
Local cQuery	:= ""
Local nColigada	:= GetNewPar("MV_RMCOLIG",0) // coligada igual a empresa
Local aAreaSB1	:= {}
Local aAreaSB2	:= {}
Local aTamSX3	:= {}
Local nCustMed	:= 0
Local nERPConn   := 0
Local 	nSolumConn := -1
Local lMsgUnica	:= IsIntegTop()

If !(lMsgUnica)
	// Procura valor do custo m้dio deste produto
	dbSelectArea("SB2")
	aAreaSB2 := GetArea()
	dbSetOrder(1)
	If dbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)
		nCustMed := SB2->B2_CM1
	Endif
	RestArea(aAreaSB2)

	// insere a unidade de medida

	dbSelectArea("SB1")
	aAreaSB1 := SB1->(GetArea())
	dbSetOrder(1)
	If dbSeek(xFilial("SB1")+SBZ->BZ_COD)

		// Pega a conexao do ByYouDBAccess corrente do Protheus
		nERPConn := AdvConnection()

		// Pega a conexao do ByYouDBAccess corrente do TOP
		nSolumConn := CnnSolum()

		// se houver conexao do ByYouDBAccess com o TOP
		If (nSolumConn>0)

			// efetua a conexao ByYouDBAccess com o banco de dados TOP
			// Retorna a conexao do ByYouDBAccess corrente do Protheus
			tcSetConn(nSolumConn)

			if UPPER(tcgetdb()) == "ORACLE"
				cQuery := "BEGIN "
				If TCSPExist("SP_PRODUTO_TOPPROT")
					cQuery += "SP_PRODUTO_TOPPROT ("
				Else
					cQuery += "sp_Produto_Solum_Protheus ("
				Endif
				cQuery +=         AllTrim(Str(nColigada)) + " "
				cQuery += ", '" + PADR(cFilAnt,LEN(SM0->M0_CODFIL))    + "' " // a empresa se relaciona com a coligada e as filial sใo iguais
				cQuery += ", '" + Alltrim(SB1->B1_COD)    + "' "
				cQuery += ", '" + FmtStrPrc(SB1->B1_DESC) + "' "
				cQuery += ", '" + Alltrim(SB1->B1_UM)     + "' "
				cQuery += ",  " + iIf(nOper==VM_DELETE ,"1 " ,"0 ")  // -- 0.ATIVO / 1.INATIVO

				aTamSX3 := TamSX3("BZ_CUSTD")
				cQuery += ", '" + AllTrim(Str(SBZ->BZ_UPRC,aTamSX3[1],aTamSX3[2])) + "' "

				aTamSX3 := TamSX3("B1_PRV1")
				cQuery += ", '" + AllTrim(Str(SB1->B1_PRV1,aTamSX3[1],aTamSX3[2])) + "' "

				cQuery += ", '" + iif(Trim(SB1->B1_TIPO)="MO", "S", "P") + "' "

				aTamSX3 := TamSX3("B2_CM1")
				cQuery += ", '" +AllTrim(Str(nCustMed,aTamSX3[1],aTamSX3[2])) + "' "
				cQuery += ", '" +Alltrim(SB1->B1_SEGUM)    + "' "
				cQuery += ", '" +Alltrim(str(SB1->B1_CONV))+ "' "
				cQuery += ", '" +Alltrim(SB1->B1_TIPCONV)  + "' "

				aTamSX3 := TamSX3("BZ_CUSTD")
				cQuery += ", '" +Alltrim(Str(SBZ->BZ_CUSTD,aTamSX3[1],aTamSX3[2])) + "' "
				cQuery += "); END; "
			Else
				cQuery := ""
				If TCSPExist("SP_PRODUTO_TOPPROT")
					cQuery += "SP_PRODUTO_TOPPROT "
				Else
					cQuery += "sp_Produto_Solum_Protheus "
				Endif
				cQuery += "@CodColigada = "      +AllTrim(Str(nColigada)) + " "
				cQuery += ",@Codfilial = '"  	 +PADR(cFilAnt,LEN(SM0->M0_CODFIL)) + "' " // a empresa se relaciona com a coligada e as filial sใo iguais
				cQuery += ",@CodigoPrd = '"      +AllTrim(SB1->B1_COD) + "' "
				cQuery += ",@Nome = '"           +FmtStrPrc(SB1->B1_DESC) + "' "
				cQuery += ",@Unidade = '"        +AllTrim(SB1->B1_UM) + "' "
				cQuery += ",@Inativo = "         +iIf(nOper==VM_DELETE ,"1 " ,"0 ")  // -- 0.ATIVO / 1.INATIVO

				aTamSX3 := TamSX3("BZ_CUSTD")
				cQuery += ",@PPrecoCusto = "      +AllTrim(Str(SBZ->BZ_UPRC,aTamSX3[1],aTamSX3[2])) + " "

				aTamSX3 := TamSX3("B1_PRV1")
				cQuery += ",@PPrecoVenda = "      +AllTrim(Str(SB1->B1_PRV1,aTamSX3[1],aTamSX3[2])) + " "

				cQuery += ",@Tipo = " + "'"      +iif(Trim(SB1->B1_TIPO)="MO", "S", "P") + "' "

				aTamSX3 := TamSX3("B2_CM1")
				cQuery += ",@PCustoMedio = " +AllTrim(Str(nCustMed,aTamSX3[1],aTamSX3[2])) + " "

				cQuery += ",@UnidadeBase = '"    +AllTrim(SB1->B1_SEGUM)+"' "
				cQuery += ",@PFatorConversao = " +Alltrim(str(SB1->B1_CONV))+" "
				cQuery += ",@TipoConversao =  '" +Alltrim(SB1->B1_TIPCONV)+"' "

				aTamSX3 := TamSX3("BZ_CUSTD")
				cQuery += ",@PCustoStandart = '" +AllTrim(Str(SBZ->BZ_CUSTD,aTamSX3[1],aTamSX3[2]))+"' "

			EndIf

			// Executa a Stored Procedure
			PMSExecSOLUM(cQuery)

			// Se a conexao ByYouDBAccess for maior que zero, deve desconectar
			If nSolumConn >0
				TCUnLink(nSolumConn)
			EndIf
			// volta pra conexao ByYouDBAccess Padrao
			tcSetConn(nERPConn)

		Endif
	Else
		PMSRMSOLUMLOG(STR0052) //"Erro na integra็ใo: Produto nใo encontrado no cadastro de produtos"
	EndIf

	RestArea(aAreaSB1)
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMSRMSOLUMLOGบAutor  ณ Pedro Pereira Lima บ Data ณ  27/11/2009 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava log de mensagem de erro no servidor se o parametro      บฑฑ
ฑฑบ          ณ MV_PMSRMLG igual .T.                                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                            บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMSRMSOLUMLOG(cErrorMsg,cQueryCall,cFuncCall,nExec)
Local nHandle	:= -1
Local cFileLog	:= ""
Local cMsgLog	:= GetNewPar("MV_PMSRMLG","0")
Local cPathLog	:= AllTrim(GetNewPar("MV_DIRLOG","C:\DIRLOG\"))
Local aFil		:= IIf( FindFunction( "FWArrFilAtu" ), FWArrFilAtu( cEmpAnt, PADR(cFilAnt,LEN(SM0->M0_CODFIL)) ), { SM0->M0_CODIGO, SM0->M0_CODFIL }  )

Default cErrorMsg := ""
Default cQueryCall := ""
Default cFuncCall := ""
Default nExec = -1

If cMsgLog == "1" .OR. cMsgLog == "2"
	If Right(cPathLog,1)== "\"
		cPathLog := left(cPathLog ,len(cPathLog)-1)
	EndIf

	If !ExistDir(cPathLog)
		makeDir(cPathLog)
	EndIf
Endif

If cMsgLog == "1" .And. nExec < 0 //Mensagens de erro gravadas no LOG

	cFileLog := cPathLog+"\"+ComputerName()+".log"

	If !File(cFileLog)
		//Crio o arquivo de LOG com o nome da maquina onde esta sendo acessado
		nHandle := FCreate(cFileLog)
		//Criacao do cabe็alho do LOG
		FWrite(nHandle, STR0053 + CRLF)  //"LOG DE ERRO: INTEGRAวรO ERP MICROSIGA PROTHEUS X TOP"
		FWrite(nHandle, "---------------" + CRLF)
		FWrite(nHandle, STR0054 + " "  + Dtoc(MsDate()) + CRLF)//"DATA DE CRIAวรO....: "
		FWrite(nHandle, STR0055 + " "  + Time() + CRLF + CRLF) //"HORA DE CRIAวรO....: "
		//Se ja existe mensagem de erro na criacao do arquivo
		If !Empty(cErrorMsg)
			FWrite(nHandle, ">>> " + DtoC(MsDate()) + " - " + Time() + " <<<" + CRLF)
			FWrite(nHandle, STR0056 + " "  + aFil[1] + "/" + aFil[2] + CRLF) //"EMPRESA / FILIAL...: "
			FWrite(nHandle, STR0057 + " "  + Capital(Trim(aFil[6])) + CRLF) //"NOME EMPRESA.......: "
			FWrite(nHandle, STR0058 + " "  + Capital(Trim(aFil[7])) + CRLF)//"NOME FILIAL........: "
			FWrite(nHandle, STR0059 + " "  + SubStr(cUsuario,7,15) + CRLF)//"USUมRIO............: "
			FWrite(nHandle, STR0063+ " " + GetEnvServer() + CRLF)//"AMBIENTE.....................:
			FWrite(nHandle, STR0060 + " "  + "SIGA" + cModulo + CRLF) //"MำDULO.............: "
			FWrite(nHandle, STR0061 + " "  + cErrorMsg + CRLF) //"MENSAGEM...........: "
			FWrite(nHandle, ">>> " + DtoC(MsDate()) + " - " + Time() + " <<<" + CRLF+ CRLF)
		EndIf

	Else
		//Inclsuใo das linhas de mensagem de erro
		nHandle := FOpen(cFileLog, 1)
		FSeek(nHandle, 0, 2)
		FWrite(nHandle, ">>> " + DtoC(MsDate()) + " - " + Time() + " <<<" + CRLF)
		FWrite(nHandle,  STR0056 + " "   + aFil[1] + "/" + aFil[2] + CRLF) //"EMPRESA / FILIAL...: "
		FWrite(nHandle,  STR0057 + " "  + Capital(Trim(aFil[6])) + CRLF)//"NOME EMPRESA.......: "
		FWrite(nHandle,  STR0058 + " "  + Capital(Trim(aFil[7])) + CRLF)//"NOME FILIAL........: "
		FWrite(nHandle,  STR0059 + " "   + SubStr(cUsuario,7,15) + CRLF)//"USUมRIO............: "
		FWrite(nHandle,  STR0063 + " "  + GetEnvServer() + CRLF)//"AMBIENTE....................:
		FWrite(nHandle,  STR0060 + " "  + "SIGA" + cModulo + CRLF)//"MำDULO.............: "
		FWrite(nHandle,  STR0061 + " "   + cErrorMsg + CRLF)//"MENSAGEM...........: "
		FWrite(nHandle, ">>> " + DtoC(MsDate()) + " - " + Time() + " <<<" + CRLF+ CRLF)
	EndIf

	If nHandle > 0
		FClose(nHandle)
	EndIf

ElseIf cMsgLog == "2" //Trace das procedures atraves de arquivo LOG
	cFileLog := cPathLog+"\"+ComputerName()+"_TRACE.log"

	If !File(cFileLog)
		//Crio o arquivo de LOG com o nome da maquina onde esta sendo acessado
		nHandle := FCreate(cFileLog)
		//Criacao do cabe็alho do LOG
		FWrite(nHandle, STR0062 + CRLF) //"LOG DE RASTREAMENTO DE PROCEDURES: INTEGRAวรO ERP MICROSIGA PROTHEUS X TOP"
		FWrite(nHandle, "---------------------------------------------------------------------------------------" + CRLF)
		FWrite(nHandle, STR0054 + " "  + Dtoc(MsDate()) + CRLF) ////"DATA DE CRIAวรO....: "
		FWrite(nHandle, STR0055 + " "   + Time() + CRLF + CRLF)//"HORA DE CRIAวรO....: "
		//Se ja existe mensagem de erro na criacao do arquivo
		If !Empty(cErrorMsg)
			FWrite(nHandle, ">>> " + DtoC(MsDate()) + " - " + Time() + " <<<" + CRLF)
			FWrite(nHandle, STR0056 + " "   + aFil[1] + "/" + aFil[2] + CRLF)////"EMPRESA / FILIAL...: "
			FWrite(nHandle, STR0057 + " "  + Capital(Trim(aFil[6])) + CRLF)///"NOME EMPRESA.......: "
			FWrite(nHandle, STR0058 + " "   + Capital(Trim(aFil[7])) + CRLF)////"NOME FILIAL........: "
			FWrite(nHandle, STR0059 + " "   + SubStr(cUsuario,7,15) + CRLF)//"USUมRIO............: "
			FWrite(nHandle, STR0063 + " "  + GetEnvServer() + CRLF)//"AMBIENTE.................:
			FWrite(nHandle, STR0060 + " "   + "SIGA" + cModulo + CRLF)//"MำDULO.............: "
			FWrite(nHandle, STR0064 + " "  + cFuncCall + CRLF)//"FUNวรO CHAMADORA......................: "
			FWrite(nHandle, "QUERY.................................: " + cQueryCall + CRLF)
			If nExec < 0
				FWrite(nHandle, "===================================================" + CRLF)
				FWrite(nHandle, STR0061 + " " + cErrorMsg + CRLF) //"MENSAGEM..............................: "
				FWrite(nHandle, "===================================================" + CRLF)
			EndIf
			FWrite(nHandle, STR0065 + " "  + AllTrim(STR(nExec)) + CRLF) //"CำDIGO DE EXECUวรO DA QUERY...........: "

			FWrite(nHandle, ">>> " + DtoC(MsDate()) + " - " + Time() + " <<<" + CRLF+ CRLF)
		EndIf

	Else
		//Inclsuใo das linhas de mensagem de erro
		nHandle := FOpen(cFileLog, 1)
		FSeek(nHandle, 0, 2)
		FWrite(nHandle, ">>> " + DtoC(MsDate()) + " - " + Time() + " <<<" + CRLF)
		FWrite(nHandle, STR0056 + " "    + aFil[1] + "/" + aFil[2] + CRLF)//"EMPRESA / FILIAL...: "
		FWrite(nHandle, STR0057 + " "   + Capital(Trim(aFil[6])) + CRLF)//"NOME EMPRESA.......: "
		FWrite(nHandle, STR0058 + " "    + Capital(Trim(aFil[7])) + CRLF)//"NOME FILIAL........: "
		FWrite(nHandle, STR0059 + " "   + SubStr(cUsuario,7,15) + CRLF)//"USUมRIO............: "
		FWrite(nHandle, STR0063 + " "  + GetEnvServer() + CRLF)//"AMBIENTE.................:
		FWrite(nHandle, STR0060 + " "   + "SIGA" + cModulo + CRLF)//"MำDULO.............: "
		FWrite(nHandle, STR0064 + " "  + cFuncCall + CRLF)//"FUNวรO CHAMADORA......................: "

		FWrite(nHandle, "===================================================" + CRLF)
		FWrite(nHandle, "QUERY.................................: " + cQueryCall + CRLF)
		FWrite(nHandle, "===================================================" + CRLF)

		If nExec < 0
			FWrite(nHandle, "===================================================" + CRLF)
			FWrite(nHandle, STR0061 + " "  + cErrorMsg + CRLF) //"MENSAGEM..............................: "
			FWrite(nHandle, "===================================================" + CRLF)
		EndIf
		FWrite(nHandle, STR0065 + " " + AllTrim(STR(nExec)) + CRLF)//"CำDIGO DE EXECUวรO DA QUERY...........: "

		FWrite(nHandle, ">>> " + DtoC(MsDate()) + " - " + Time() + " <<<" + CRLF+ CRLF)
	EndIf

	If nHandle > 0
		FClose(nHandle)
	EndIf
Else
	Conout(cErrorMsg)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณU_SIGAFIN บAutor  ณ                    บ Data ณ    /  /     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Executa a sincronizacao das tabelas entre Protheus e       บฑฑ
ฑฑบ          ณTOP.     E ativa os gatilhos das tabelas de cadastro do     บฑฑ
ฑฑบ          ณProtheus.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FININITFUN()

If PMSINTSOLUM()
	PMSVIEWSOLUM()
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMSBLKINT บAutor  ณ Pedro Pereira Lima บ Data ณ 28/01/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua o bloqueio das rotinas padrใo do PMS quando a       บฑฑ
ฑฑบ          ณ integra็ใo Protheus x TOP estiver ativa. A fun็ใo          บฑฑ
ฑฑบ          ณ verifica o parโmetro MV_RMCOLIG.                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMSBLKINT(lIsAutoExec)
Local lRet := .F.
Local lIntegra:=.F.
Default lIsAutoExec := .F.

lIntegra:=IsIntegTop(,.T.)

If lIntegra
	If !lIsAutoExec
		Aviso(STR0066,  STR0067 + CRLF;
		+STR0068, {"OK"}, 2) //"Integra็ใo SIGAPMS" / "As fun็๕es do PMS nใo podem ser utilizadas quando a integra็ใo" /"do sigapms com outras marcas estiver ativa!"
		lRet := .T.

	ElseIf !IsInCallStack('IntegDef')// deve habilitar as rotinas do pms pela mensagem ๚nica.
		Help(,,'PMSBLKINT1',,STR0067 + " " + STR0068,1,0)
		lRet := .T.
	EndIf


EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMSExecSOLบAutor  ณReynaldo Miyashita  บ Data ณ  02/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Executa uma query no banco de dados do TOP                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMSVldProc(cQuery)

Local nExec := 0
Local nERPConn:= -1
Local nSolumConn := -1
Local cMsgError := ""
Local cMsgCode  := ""
Local cSP		  := ""
Local aReturn   := {}
Local nColigada := GetNewPar("MV_RMCOLIG",0)
Local lMsgUnica	:= IsIntegTop()

DEFAULT cQuery := ""

If !(lMsgUnica)
	If nColigada >0 .AND. !Empty(cQuery)

		// Pega a conexao do ByYouDBAccess corrente do Protheus
		nERPConn := AdvConnection()

		// Pega a conexao do ByYouDBAccess corrente do TOP
		nSolumConn := CnnSolum()

		If (nSolumConn>0)

			// efetua a conexao ByYouDBAccess com o banco de dados TOP
			tcSetConn(nSolumConn)
			TcInternal( 8, STR0022) //"Sincronizacao Microsiga Protheus x TOP"
			
			If UPPER(tcgetdb()) == "ORACLE"
				cSP := AllTrim(StrTran(Separa(cQuery,"(")[1],"BEGIN ",""))
			Else
				cSP := AllTrim(Separa(cQuery,"@")[1])
			Endif
			
			If TCSPExist(cSP)
			
				// executa a Query no banco de dados TOP
				nExec:= tcSqlExec(cQuery)
				If nExec < 0
	
					cMsgError := "Execution SQL failed - Error Code: "+allTrim(Str(nExec))
					cMsgCode  := TcSQLError()
	
					If !Empty(cMsgCode)
						cMsgError += " :" + cMsgCode
					Else
						cMsgError += " :Error Message undefined"
					EndIf
				EndIF
	
				PMSRMSOLUMLOG(cMsgError,cQuery,FunName(),nExec)
			Endif

			// Se a conexao ByYouDBAccess for maior que zero, deve desconectar
			If nSolumConn >0
				TCUnLink(nSolumConn)
			EndIf
		EndIf

		// volta pra conexao ByYouDBAccess Padrao
		tcSetConn(nERPConn)

	EndIf

	Aadd(aReturn, {nExec, cMsgCode})
Endif
Return aReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMSExecSOLบAutor  ณReynaldo Miyashita  บ Data ณ  02/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Executa uma query no banco de dados do TOP                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetNumSA(cNUMSC,cITEMSC)

Local aRetorno	:= {}
Local cNumSA	:= ""
Local cItemSA	:= ""
Local lRet		:= .T.
Local nRec		:= 0
Local cFilSC1	:= xFilial("SC1")

Default cNUMSC	:= ""
Default cITEMSC	:= ""

If !Empty(cNUMSC)
	aRetorno:= COMPosDHN({3,{'1',cFilSC1,cNUMSC,cITEMSC}}) //-- Avalia os documentos de compras que foram gerados pela solicita็ใo armazem.
	If aRetorno[1]
		If (aRetorno[2])->(Eof())
			conout(STR0069 + " "  + cNUMSC + " " + STR0070+ " "  + cITEMSC)//"Numero solicitacao de compras nใo encontrado: "" Item "
			lRet := .F.
		Else
			cNumSA	:= (aRetorno[2])->DHN_DOCORI
			cItemSA	:= (aRetorno[2])->DHN_ITORI
			SCP->(dbSeek(xFilial("SCP")+cNumSA+cItemSA))
			nRec := SCP->(RecNo())
		Endif
		(aRetorno[2])->(DbCloseArea())
	EndIf
EndIf

Return nRec

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMS_SE4   บAutor  ณClovis Magenta	     บ Data ณ  25/03/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณIntegra็ใo do cadastro de condicao de pagamento com o       บฑฑ
ฑฑบ          ณTOP                                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMS_SE4(nOper)
Local cQuery 		:= ""
Local nColigada 	:= GetNewPar("MV_RMCOLIG",0) // coligada igual a empresa
Local nERPConn   	:= 0
Local nSolumConn 	:= -1
Local nCnt			:= 0
Local aColig     	:= {}
Local lPMRMCOLIG 	:= ExistBlock("PMRMCOLIG")
Local lMsgUnica	:= IsIntegTop()

If !(lMsgUnica)
	Do case
		// --> 0-INCLUIR, 1-ALTERAR, 2-APAGAR
		Case nOper==VM_INSERT
			cOperacao := "0"
		Case nOper==VM_UPDATE
			cOperacao := "1"
		Otherwise
			cOperacao := "2"
	EndCase
	
	// define a coligada a qual o produto vai ser replicado na base RM
	aAdd(aColig ,nColigada)

	// Pega a conexao do ByYouDBAccess corrente do Protheus
	nERPConn := AdvConnection()
	
	// Carrega as coligadas
	If lPMRMCOLIG
		aColig:= ExecBlock("PMRMCOLIG",.F.,.F.,{"SE4",aColig})
		tcSetConn(nERPConn)
	EndIf
	

	// Pega a conexao do ByYouDBAccess corrente do TOP
	nSolumConn := CnnSolum()

	// se houver conexao do ByYouDBAccess com o TOP
	If (nSolumConn>0)

		// efetua a conexao ByYouDBAccess com o banco de dados TOP
		// Retorna a conexao do ByYouDBAccess corrente do Protheus
		tcSetConn(nSolumConn)

		For nCnt := 1 to len(aColig)
			If UPPER(tcgetdb()) == "ORACLE"
				cQuery := "BEGIN "
				If TCSPExist("SP_CONDPAG_TOP_PROT")
					cQuery += "SP_CONDPAG_TOP_PROT ("
				Else
					cQuery += "sp_Condicao_Pagamento ("
				Endif
				If ValType(aColig[1]) == "N"
					cQuery +=         AllTrim(STR(aColig[nCnt])) + " "		//INT, --> codigo coligada
				Elseif ValType(aColig[1]) == "A"
					cQuery +=         AllTrim(STR(aColig[nCnt,1])) + " "		//INT, --> codigo coligada
				Endif
				cQuery += ", '" + SE4->E4_CODIGO + "' "	//VARCHAR(5)
				cQuery += ", '" + FmtStrPrc(SE4->E4_DESCRI) + "' "	// VARCHAR(100)
				cQuery += ", "  + cOperacao + " "	//INT --> 0-INCLUIR, 1-ALTERAR, 2-APAGAR (somente via MATA360)
				cQuery += "); END; "
			Else
				cQuery := ""
				If TCSPExist("SP_CONDPAG_TOP_PROT")
					cQuery += "SP_CONDPAG_TOP_PROT "
				Else
					cQuery += "sp_Condicao_Pagamento "
				Endif
				If ValType(aColig[1]) == "N"
					cQuery += " @CodColigada = "    + AllTrim(STR(aColig[nCnt])) + " " //INT, --> codigo coligada
				Elseif ValType(aColig[1]) == "A"
					cQuery += " @CodColigada = "    + AllTrim(STR(aColig[nCnt,1])) + " " //INT, --> codigo coligada
				Endif
				cQuery += ",@CodCPG = '"        + AllTrim(SE4->E4_CODIGO) + "' " //VARCHAR(5)
				cQuery += ",@Nome = '"          + FmtStrPrc(SE4->E4_DESCRI)+"' "  // VARCHAR(100)
				cQuery += ",@TipoMovimento = '" + cOperacao+"' " //INT --> 0-INCLUIR, 1-ALTERAR, 2-APAGAR (somente via MATA360)
	
			EndIf
	
			// Executa a Stored Procedure
			PMSExecSOLUM(cQuery)
		
		Next nCnt
		
		// Se a conexao ByYouDBAccess for maior que zero, deve desconectar
		If nSolumConn >0
			TCUnLink(nSolumConn)
		EndIf
		// volta pra conexao ByYouDBAccess Padrao
		tcSetConn(nERPConn)

	Endif
Endif
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณPMSVIEWSOLUบAutor  ณReynaldo Miyashita  บ Data ณ  02/11/09  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณAntes de atualizar as tabelas AF8,AFC,AF9 do Protheus       บฑฑ
ฑฑบ          ณVIEW do TOP                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMSVIEWSOLUM()
Local cQuery := ""
Local aArea    := GetArea()
Local aAreaAF8 := {}
Local aAreaAFC := {}
Local aAreaAF9 := {}
Local nColigada := GetNewPar("MV_RMCOLIG",0)
Local nERPConn := -1
Local nSolumConn := -1
Local lMsgUnica	:= IsIntegTop()

If !(lMsgUnica)
	If nColigada > 0

		// Pega a conexao do ByYouDBAccess corrente do Protheus
		nERPConn := AdvConnection()

		dbSelectArea("AF8")
		aAreaAF8 := GetArea()
		dbSelectArea("AFC")
		aAreaAFC := GetArea()
		dbSelectArea("AF9")
		aAreaAF9 := GetArea()
		dbSelectArea("SON")

		// Pega a conexao do ByYouDBAccess corrente do TOP
		nSolumConn := CnnSolum()

		If (nSolumConn>0)

			tcSetConn(nSolumConn)
			TcInternal( 8, STR0022 ) //"Sincronizacao Microsiga Protheus x TOP"

			If Select("vwSync")>0
				vwSync->(dbCloseArea())
			EndIf

			//
			// View criada pela RM para visualizar os projetos e suas estruturadas que foram criadas no TOP.
			// Atrav้s do filtro da codigo da coligada e o codigo da filial destino identifico se devo
			// atualizar as tabelas do PMS (AF8,AFC,AF9)
			//
			cQuery := "SELECT * FROM vSincronismo_Solum_Protheus "
			cQuery += "WHERE codcoligada=" + AllTrim(Str(nColigada))
			cQuery += " AND CODFILIAL = '" + PADR(cFilAnt,LEN(SM0->M0_CODFIL)) +"' "
			If UPPER(tcgetdb()) == "ORACLE"
				cQuery += " ORDER BY IDSINCRONISMO,IDPRJ,IDTRF NULLS FIRST,IDENTIFICADOR "
			Else
				cQuery += " ORDER BY IDSINCRONISMO,IDPRJ,IDTRF,IDENTIFICADOR "
			Endif
			PMSRMSOLUMLOG("-- Trace da VIEW vSincronismo_Solum_Protheus --",cQuery,FunName(),0)

			//
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"vwSync")
			If Select("vwSync")>0 .And. vwSync->(!Eof())
				MsgRun(STR0071,STR0066, {|| PMSUPDSOLUM(nERPConn,nSolumConn)}) //"Importando dados de integracao (Estrutura do Projeto)""Integracao PROTHEUS x TOP"
			Endif

		Endif

		// Retorna a conexao do ByYouDBAccesscorrente do Protheus
		tcSetConn(nERPConn)
		If nSolumConn >0
			TCUnLink(nSolumConn)
		EndIf
		RestArea(aAreaAF9)
		RestArea(aAreaAFC)
		RestArea(aAreaAF8)

	EndIf
Endif
RestArea(aArea)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMS_AFN   บAutor  ณWilson Godoi        บ Data ณ  12/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza na tabela de movimento de NFE do TOP               บฑฑ
ฑฑบ          ณnOper --> 1 - Inclusao de Nota Fiscal de Entrada            บฑฑ
ฑฑบ          ณnOper --> 2 - Estorno da Nota fiscal de Entrada(Nใo serแ    บฑฑ
ฑฑบ          ณ              utilizado, apenas convertido para 3           บฑฑ
ฑฑบ          ณnOper --> 3 - Exclusao de Nota Fiscal de Entrada            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PMS_AFN(nOper,cIdentSF1)

Local aArea    := GetArea()
Local aAreaSCP := SCP->(GetArea())
Local aAreaAJ7 := AJ7->(GetArea())
Local aAreaSC7 := SC7->(GetArea())
Local aAreaSC1 := SC1->(GetArea())
Local aAreaSD1 := SD1->(GetArea())
Local aAreaAFG
Local aAreaAFN
Local lMsgUnica	:= IsIntegTop()

If !(lMsgUnica)
	If nOper == 3  // Exclusao de NFE
	   NotaAvulsa(nOper,cIdentSF1)
	Else
		//Posiciono o SC7 para verificar se existe pedido de compra
		dbSelectArea("SC7")
		dbSetOrder(1)//C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
		If dbSeek(xFilial("SC7") + SD1->D1_PEDIDO + SD1->D1_ITEMPC)

			//Verifico se existe na solicitacao de compra
			dbSelectArea("SC1")
			dbSetOrder(1)

			If dbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC)

				If (nRec:= GetNumSA(SC7->C7_NUMSC,SC7->C7_ITEMSC)) > 0
					dbSelectArea("SCP")
					dbgoto( nRec )

					// Neste momento as tabelas SD1, SC7, SC1 e SCP estใo posicionadas de acordo com o link criado no momento da baixa do PC.
					AFH->(DbSetOrder(2))
					IF AFH->(DbSeek(xFilial()+SCP->CP_NUM+SCP->CP_ITEM)) .And. AFH->AFH_VIAINT <> "S"
						NotaAvulsa(nOper,cIdentSF1)  // Avulso
					Else
						//Busca na AFN - Rateio Projeto/NF
						dbSelectArea("AFN")
		  				aAreaAFN:=AFN->(GetArea())
		  				AFN->(dbSetOrder(2))//AFN_FILIAL, AFN_DOC, AFN_SERIE, AFN_FORNEC, AFN_LOJA, AFN_ITEM, AFN_PROJET, AFN_REVISA, AFN_TAREFA
		  				If AFN->(dbSeek(xFilial("AFN")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA))
		  					NotaAvulsa(nOper,cIdentSF1)  // Avulso  //Wilson Incluido em 05/07/2011
		  				Endif
		  				RestArea(aAreaAFN)
					Endif

	  		   Else
	  				 dbSelectArea("AFG")
	  				 aAreaAFG:=AFG->(GetArea())
	  				 AFG->(dbSetOrder(2))//AFG_FILIAL+AFG_NUMSC+AFG_ITEMSC+AFG_PROJET+AFG_REVISA+AFG_TAREFA
	  				 If AFG->(dbSeek(xFilial("AFG")+SC7->C7_NUMSC+SC7->C7_ITEMSC)) .And. AFG->AFG_VIAINT <> "S"
	  				 	NotaAvulsa(nOper,cIdentSF1)  // Avulso  //Wilson Incluido em 05/07/2011
	  				 Else
	  				 	//Busca na AFN - Rateio Projeto/NF
						dbSelectArea("AFN")
		  				aAreaAFN:=AFN->(GetArea())
		  				AFN->(dbSetOrder(2))//AFN_FILIAL, AFN_DOC, AFN_SERIE, AFN_FORNEC, AFN_LOJA, AFN_ITEM, AFN_PROJET, AFN_REVISA, AFN_TAREFA
		  				If AFN->(dbSeek(xFilial("AFN")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA))
		  					NotaAvulsa(nOper,cIdentSF1)  // Avulso  //Wilson Incluido em 05/07/2011
		  				Endif
		  				RestArea(aAreaAFN)
	  				 Endif
	  				 RestArea(aAreaAFG)
			   Endif
			Else
				// Busca na amarracao do Pedido de compra com a tarefa do projeto
				dbSelectArea("AJ7")
				dbSetOrder(2) //AJ7_FILIAL+AJ7_NUMPC+AJ7_ITEMPC+AJ7_PROJET+AJ7_REVISA+AJ7_TAREFA
				If DbSeek(xFilial("AJ7") + SC7->C7_NUM + SC7->C7_ITEM) .And. AFG->AFG_VIAINT <> "S"
				  NotaAvulsa(nOper,cIdentSF1)  // Avulso
				Else
					//Busca na AFN - Rateio Projeto/NF
					dbSelectArea("AFN")
	  				aAreaAFN:=AFN->(GetArea())
	  				AFN->(dbSetOrder(2))//AFN_FILIAL, AFN_DOC, AFN_SERIE, AFN_FORNEC, AFN_LOJA, AFN_ITEM, AFN_PROJET, AFN_REVISA, AFN_TAREFA
	  				If AFN->(dbSeek(xFilial("AFN")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA))
	  					NotaAvulsa(nOper,cIdentSF1)  // Avulso  //Wilson Incluido em 05/07/2011
	  				Endif
	  				RestArea(aAreaAFN)
				Endif
			Endif
		Else
		  NotaAvulsa(nOper,cIdentSF1)  // Avulso
		Endif
	Endif
Endif
RestArea(aAreaSCP)
RestArea(aAreaAJ7)
RestArea(aAreaSC1)
RestArea(aAreaSC7)
RestArea(aAreaSD1)
RestArea(aArea)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNotaAvulsaบAutor  ณWilson Godoi        บ Data ณ  12/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza na tabela de movimento de NFE do TOP               บฑฑ
ฑฑบ          ณnOper --> 1 - Inclusao de Nota Fiscal de Entrada            บฑฑ
ฑฑบ          ณnOper --> 2 - Estorno da Nota fiscal de Entrada(Nใo serแ    บฑฑ
ฑฑบ          ณ              utilizado, apenas convertido para 3           บฑฑ
ฑฑบ          ณnOper --> 3 - Exclusao de Nota Fiscal de Entrada            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function NotaAvulsa(nOper,cIdentSF1)

Local cQuery := " "
Local nColigada := GetNewPar("MV_RMCOLIG",0) // coligada igual a empresa
Local aArea    := GetArea()
Local cNameProc  := "" // nome da procedure no banco de dados
Local nERPConn   := -1
Local nSolumConn := -1
Local cOperacao  := ""
Local lIDAFN    := AFN->(FieldPos("AFN_ID"))>0
Local lIDSF1    := SF1->(FieldPos("F1_MSIDENT"))>0
Local nExec := 0
Local nCustoPrd :=0
Local lAfn:= .T.
Local lContinua  := .T.
Local lVldPrdMO	:= SuperGetMV("MV_ITVLDPR",,.F.) .And. IsIntegTop(,.T.)
Local lApropAll	:= SuperGetMV("MV_ITAPALL",,.F.)
Local cTpProd		:= ""
Local cDocD1		:= ""
Local cSerD1		:= ""
Local cForD1		:= ""
Local cLojD1		:= ""
Local cIteD1		:= ""
Local cPrdD1		:= ""
Local nCusD1		:= 0
Local nQtdD1		:= 0
Local nVunD1		:= 0
Local cPedD1		:= ""
Local cItPD1		:= ""
Local cTpDD1		:= ""
Local cRemD1		:= ""
Local cReSD1		:= ""
Local cReID1		:= ""
Local dDtDD1		:= CtoD("//")
Local lVldExp		:= .F.
Local aPMSNFSA	:= {}
Local lMsgUnica	:= IsIntegTop()

If Type("l103Class") <> "L"
	l103Class := .F.
Endif

If l103Class
	cDocD1	:= aCols[n,GdFieldPos("D1_DOC")]
	cSerD1	:= aCols[n,GdFieldPos("D1_SERIE")]
	cForD1	:= aCols[n,GdFieldPos("D1_FORNECE")]
	cLojD1	:= aCols[n,GdFieldPos("D1_LOJA")]
	cIteD1	:= aCols[n,GdFieldPos("D1_ITEM")]
	cPrdD1	:= aCols[n,GdFieldPos("D1_COD")]
	nCusD1 := Iif(GdFieldPos("D1_CUSTO")==0,0,aCols[n,GdFieldPos("D1_CUSTO")])
	nQtdD1 := aCols[n,GdFieldPos("D1_QUANT")]
	nVunD1	:= aCols[n,GdFieldPos("D1_VUNIT")]
	dDtDD1 := aCols[n,GdFieldPos("D1_DTDIGIT")]
	cPedD1	:= aCols[n,GdFieldPos("D1_PEDIDO")]
	cItPD1	:= aCols[n,GdFieldPos("D1_ITEMPC")]
	cTpDD1 := ""
	cRemD1	:= ""
	cReSD1	:= ""
	cReID1	:= "" 
Else
	cDocD1	:= SD1->D1_DOC
	cSerD1	:= SD1->D1_SERIE
	cForD1	:= SD1->D1_FORNECE
	cLojD1	:= SD1->D1_LOJA
	cIteD1	:= SD1->D1_ITEM
	cPrdD1	:= SD1->D1_COD
	nCusD1 := SD1->D1_CUSTO
	nQtdD1 := SD1->D1_QUANT
	nVunD1	:= SD1->D1_VUNIT
	dDtDD1 := SD1->D1_DTDIGIT
	cPedD1	:= SD1->D1_PEDIDO
	cItPD1	:= SD1->D1_ITEMPC
	
	If cPaisLoc <> "BRA"
		cTpDD1 := SD1->D1_TIPODOC
		cRemD1	:= SD1->D1_REMITO
		cReSD1	:= SD1->D1_SERIREM
		cReID1	:= SD1->D1_ITEMREM
	Else
		cTpDD1 := ""
		cRemD1	:= ""
		cReSD1	:= ""
		cReID1	:= ""
	Endif
Endif

If!(lMsgUnica)
	If AFN->AFN_ESTOQUE == "2" //nao gera apropriacao pelo botao estoque sim/nao
		lAfn := .F.
	EndIf
	
	If lApropAll 
		lAfn := .T.
	Endif
	
	If lAfn
		//Se parametro estiver habilitado e for integra็ใo TOP x Protheus, valida o tipo do produto MO (Produto servi็o),
		//diferente de MO (produto material).
		//Se for produto MO (Sera apropriado), caso contrario nใo sera apropriado.
		If lVldPrdMO
			//Verifica o tipo do produto
			cTpProd := AllTrim(Posicione("SB1",1,xFilial("SB1") + Padr(cPrdD1,TamSx3("D1_COD")[1]),"B1_TIPO"))
			
			If cTpProd == "MO"
				lAfn := .T.
			Else
				lAfn := .F.
			Endif
		Endif
		
		If lApropAll 
			lAfn := .T.
		Endif
		
		//Verifica se item for originado de uma SA, para saber se deve ou nใo apropriar
		//Caso seja ambiente localizado, a verifica็ใo de apropria็ใo ้ feita apenas
		//na factura de entrada
		If lAfn
			If cPaisLoc == "BRA"
				If !Empty(cPedD1) .And. !Empty(cItPD1)	
					aPMSNFSA := PMSNFSA(cPedD1,cItPD1)
					If aPMSNFSA[1]
						lAfn := .F.
					Endif
				Endif
			Else
				//Factura Entrada
				If AllTrim(cTpDD1) == "10"
					//Verifica se tem pedido de compra
					If !Empty(cPedD1) .And. !Empty(cItPD1)
						aPMSNFSA := PMSNFSA(cPedD1,cItPD1)
						//Verifica se o item da factura ้ originado de uma SA
						//Caso seja, nใo apropria porque a apropria็ใo deve ser 
						//feita no momento da baixa
						If aPMSNFSA[1]
							lAfn := .F.
						Endif
					//Verifica se possuir informa็ใo de remito na factura
					//Caso sim, nใo apropria porque ja foi apropria na
					//inclusใo do remito
					Elseif !Empty(cRemD1)
						lAfn := .F.
					Endif
				//Remito (Remission)
				Elseif AllTrim(cTpDD1) == "60"
					If !Empty(cPedD1) .And. !Empty(cItPD1)
						aPMSNFSA := PMSNFSA(cPedD1,cItPD1)
						//Verifica se o item do remito ้ originado de uma SA
						//Caso seja, nใo apropria porque a apropria็ใo deve ser 
						//feita no momento da baixa
						If aPMSNFSA[1]
							lAfn := .F.
						Endif
					Endif
				Endif
			Endif
		Endif
	Endif

	If lAfn
		// Pega a conexao do ByYouDBAccess corrente do Protheus
		nERPConn := AdvConnection()

		// Pega a conexao do ByYouDBAccess corrente do TOP
		nSolumConn := CnnSolum()

		If (nSolumConn>0)

			// efetua a conexao ByYouDBAccess com o banco de dados TOP
			tcSetConn(nSolumConn)
			TcInternal( 8, "Sincronizacao Microsiga Protheus x TOP" )

			// nome da procedure pra ser chamada pelo TCSPExec
			cNameProc := "ProtheusSolum_NFE"

			// nOper igual a 2 (Estorno da Nota fiscal de Entrada), nใo serแ tratado
			nOper :=IIf(nOper==3 .Or. nOper==2, 3, 1)

			// Converte Tipo de Opera็ใo para o TOP
			if nOper == 1
			   cOperacao:= '0' //Inclusใo no TOP
			Elseif nOper == 3
				cOperacao:= '2' // Exclusใo no TOP
			Endif

			If !Empty(cNameProc)
		 		IF nOper == 3  // Exclusao de NFE
		 	 		If UPPER(tcgetdb()) == "ORACLE"
						cQuery += "BEGIN "
						If TCSPExist("SP_EXCDESP_TOPPROT2")
							cQuery += "SP_EXCDESP_TOPPROT2 ("
						ElseIf TCSPExist("SP_EXCDESP_TOPPROT")
							cQuery += " SP_EXCDESP_TOPPROT ("
						Else
							cQuery += " sp_Exclusao_Despesa ("
						Endif
						cQuery += " "    + STR(nColigada)
						If lIDSF1
							cQuery += ", '" +cIdentSF1 +"' "
						Else
							cQuery += ", 0"
						Endif
						If TCSPExist("SP_EXCDESP_TOPPROT2")
							cQuery += " , NULL "
							cQuery += " ,'"   + PADR(cFilAnt,LEN(SM0->M0_CODFIL)) +  "' "
						EndIf
						cQuery += "); END; "

						// Executa a Stored Procedure
						PMSExecSOLUM(cQuery)
					Else
		   				cQuery := "CREATE PROCEDURE "    +cNameProc +"("
		   				cQuery += " @SAIDA Integer OutPut "
		   				cQuery += ") "
		   				cQuery += " As "
		   				cQuery += "Begin "
		   				cQuery += "  Select @SAIDA = 0"
		   				cQuery += "  EXEC "
						If TCSPExist("SP_EXCDESP_TOPPROT2")
							cQuery += "SP_EXCDESP_TOPPROT2 "
						ElseIf TCSPExist("SP_EXCDESP_TOPPROT")
							cQuery += "SP_EXCDESP_TOPPROT "
						Else
							cQuery += "sp_Exclusao_Despesa "
						Endif
						cQuery += "  @CodColigada = "    + STR(nColigada)
						If lIDSF1
							cQuery += " ,@IdProtheus	= " +"'"+Alltrim(cIdentSF1)+"' "
						Else
							cQuery += " ,@IDPROTHEUS 	= '0' "
						Endif
						If TCSPExist("SP_EXCDESP_TOPPROT2")
							cQuery += " , @IDSA = NULL "
							cQuery += " , @CODIGOFILIAL = '"   + PADR(cFilAnt,LEN(SM0->M0_CODFIL)) +  "' "
						EndIf
						cQuery += " End "
						Pms_LOG(cQuery,cNameProc,nExec,lContinua)	//Gera Log									//
					Endif
			  	Else
					If l103Class
						If cDocD1 + cSerD1 + cForD1 + cLojD1 + cPrdD1 + cIteD1 == AFN->(AFN_DOC+AFN_SERIE+AFN_FORNEC+AFN_LOJA+AFN_COD+AFN_ITEM)
							lVldExp := .T.
						Endif 
					Else
						dbSelectArea("SD1")
						dbSetOrder(1) // D1_DOC+D1_SERIE+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
					
						If Dbseek(xFilial("SD1")+AFN->(AFN_DOC+AFN_SERIE+AFN_FORNEC+AFN_LOJA+AFN_COD+AFN_ITEM))
							lVldExp := .T.
						Endif
					Endif
					
					If lVldExp .And. (nColigada > 0)

			 	 		If UPPER(tcgetdb()) == "ORACLE"
							cQuery += "BEGIN "
							If TCSPExist("SP_INCDESP_TOPPROT")
								cQuery += " SP_INCDESP_TOPPROT "
							Else
								cQuery += " SP_APROPRIA_TITULO_PAGAR "
							Endif
							cQuery += "   (" + STR(nColigada)
							cQuery += " , '" +Alltrim(AFN->AFN_PROJET)+ "' "
							cQuery += " , '" +Alltrim(AFN->AFN_TAREFA)+"' "
							cQuery += " , '" +Alltrim(AFN->AFN_COD) +"' "
							cQuery += " , "  + cOperacao +" "

							If lIDAFN
								cQuery += " , '" +AFN->AFN_ID+"' "
							Else
								cQuery += " , ' ' "
							Endif
							
							// valida se o valor do item serแ passado com ou sem descontos
							if getnewpar("MV_ITVALIQ",.T.) 
								nCustoPrd := (nCusD1 / nQtdD1)
							else
								nCustoPrd := nVunD1
							EndIf

							cQuery += " ,  " + AllTrim(Str(AFN->AFN_QUANT))
							cQuery += "	,  " + AllTrim(str(nCustoPrd,TamSX3("B1_CUSTD")[1],TamSX3("B1_CUSTD")[2]))
							cQuery += "	, ' ' "
							cQuery += "	,  TO_DATE('" + strzero(day(dDataBase),2)+ "/"+ strzero(month(dDataBase),2)+ "/"+strzero(year(dDataBase),4)+ "', 'DD/MM/YYYY') "
							cQuery += "	, '" +GetMv("MV_SIMB1")+"' "
							cQuery += "	, '" + PADR(cFilAnt,LEN(SM0->M0_CODFIL)) + "' "

							cQuery += "); END; "

							// Executa a Stored Procedure
							PMSExecSOLUM(cQuery)
						Else
		   				cQuery := "CREATE PROCEDURE "    +cNameProc +"("
		   				cQuery += " @SAIDA Integer OutPut "
		   				cQuery += ") "
		   				cQuery += " As "
		   				cQuery += "Begin Declare @Data Datetime  "
		   				cQuery += "  Select @SAIDA = 0 Select @Data = CONVERT(DATETIME,"+"'"+ strzero(Year(dDtDD1),4)+ "-"+strzero(month(dDtDD1),2)+ "-"+strzero(day(dDtDD1),2)+ " 00:00:00',120) "
		   				cQuery += "  EXEC "
							If TCSPExist("SP_INCDESP_TOPPROT")
								cQuery += " SP_INCDESP_TOPPROT "
							Else
								cQuery += " SP_APROPRIA_TITULO_PAGAR "
							Endif
							cQuery += "  @CodColigada = "   + STR(nColigada)
							cQuery += " ,@CodProjeto = "    + "'"+AllTrim(AFN->AFN_PROJET)+ "' "
							cQuery += " ,@CodTarefa = "     + "'"+AllTrim(AFN->AFN_TAREFA)+"' "
							cQuery += " ,@CodProduto	= "	+ "'"+AllTrim(AFN->AFN_COD) +"' "
							cQuery += " ,@TipoMovimento	= "	+ cOperacao +" "

							If lIDAFN
								cQuery += " ,@IdProtheus	= " +"'"+Alltrim(AFN->AFN_ID)+"' "
							Else
								cQuery += " ,@IdProtheus	= '0' "
							Endif

							// valida se o valor do item serแ passado com ou sem descontos
							if getnewpar("MV_ITVALIQ",.T.) 
								nCustoPrd := (nCusD1 / nQtdD1)
							else
								nCustoPrd := nVunD1
							EndIf

							cQuery += " ,@Quantidade	= " +AllTrim(Str(AFN->AFN_QUANT))
							cQuery += "	,@PrecoUnitario = " + AllTrim(str(nCustoPrd,TamSX3("B1_CUSTD")[1],TamSX3("B1_CUSTD")[2]))
							cQuery += "	,@Observacao = ' ' "
							cQuery += "	,@DataAprop = @Data"
							cQuery += "	,@Moeda = '"		+GetMv("MV_SIMB1")+"' "
							cQuery += "	,@CODFILIAL_PROTHEUS = '" + PADR(cFilAnt,LEN(SM0->M0_CODFIL)) + "' "
							cQuery += " ,@SAIDA = 0"
							cQuery += " End "

							Pms_LOG(cQuery,cNameProc,nExec,lContinua)	//Gera Log									//
		     			Endif
					Endif
				EndIf

			Endif
		EndIf

		// Se a conexao ByYouDBAccess for maior que zero, deve desconectar
		If nSolumConn >0
			TCUnLink(nSolumConn)
		EndIf

		// volta pra conexao ByYouDBAccess Padrao
		tcSetConn(nERPConn)
	EndIf
Endif
RestArea(aArea)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMS_AFH   บAutor  ณWilson Possani      บ Data ณ  15/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza na tabela MSAPROP com a baixa da requisicao        บฑฑ
ฑฑบ          ณTOP                                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMS_AFH(cProjeto ,cTarefa ,cPedido ,cItem ,nQtde ,nCustoTotal ,cTipo, nOper)

Local cQuery := ""
Local nColigada := GetNewPar("MV_RMCOLIG",0) // coligada igual a empresa
Local cNameProc  := "" // nome da procedure no banco de dados
Local nERPConn   := -1
Local nSolumConn := -1
Local lContinua  := .T.
Local cMoeda     := ""
Local cOperacao  :=""
Local lIDAFH	 := AFH->(FieldPos("AFH_ID"))>0
Local nExec := 0
Local lMsgUnica	:= IsIntegTop()

Default cProjeto 	:=""
Default cTarefa 	:=""
Default cPedido 	:=""
Default cItem 		:=""
Default nQtde 		:=""
Default nCustoTotal :=""
Default cTipo		:=""

If !(lMsgUnica)
	Do case
		Case nOper==1
	  		cOperacao := "0"   // 0-INCLUIR
	  	Case nOper==2
			cOperacao := "2"   // 2-APAGAR
	EndCase

	cMoeda := Alltrim(STR(SE2->E2_MOEDA))
	If cMoeda == "0"
		cMoeda := "1"
	Endif

	// Pega a conexao do ByYouDBAccess corrente do Protheus
	nERPConn := AdvConnection()

	// Pega a conexao do ByYouDBAccess corrente do TOP
	nSolumConn := CnnSolum()

	If (nSolumConn>0)

		// efetua a conexao ByYouDBAccess com o banco de dados TOP
		tcSetConn(nSolumConn)
		TcInternal( 8, STR0022 ) //"Sincronizacao Microsiga Protheus x TOP"

		// Define o nome da procedure pra ser criada do banco de dados
		cNameProc := "ProtheusSolum"

		If !Empty(cNameProc)
			IF cOperacao = "2"

				If UPPER(tcgetdb()) == "ORACLE"
		 				cQuery += "BEGIN "
						If TCSPExist("SP_EXCDESP_TOPPROT2")
							cQuery += "SP_EXCDESP_TOPPROT2 ("
						ElseIf TCSPExist("SP_EXCDESP_TOPPROT")
							cQuery += "SP_EXCDESP_TOPPROT ("
						Else
							cQuery += "sp_Exclusao_Despesa ("
						Endif
						cQuery += "  "    +STR(nColigada)
						cQuery += " ,'"   +SD3->D3_NUMSEQ +  "' "
						If TCSPExist("SP_EXCDESP_TOPPROT2")
							cQuery += " , NULL "
							cQuery += " ,'"   + PADR(cFilAnt,LEN(SM0->M0_CODFIL)) +  "' "
						EndIf
		 				cQuery += "); END; "
						// Executa a Stored Procedure
						PMSExecSOLUM(cQuery)
		 		Else
						cQuery := "CREATE PROCEDURE "    +cNameProc +"("
						cQuery += " @SAIDA Integer OutPut "
						cQuery += ") "
						cQuery += " As "
						cQuery += "Begin "
						cQuery += "  Select @SAIDA = 0"
						cQuery += "  EXEC "
						If TCSPExist("SP_EXCDESP_TOPPROT2")
							cQuery += "SP_EXCDESP_TOPPROT2 "
						ElseIf TCSPExist("SP_EXCDESP_TOPPROT")
							cQuery += "SP_EXCDESP_TOPPROT "
						Else
							cQuery += "sp_Exclusao_Despesa "
						Endif
						cQuery += "  @CodColigada = "    + STR(nColigada)
						cQuery += " ,@IdProtheus	= " +"'"+Alltrim(SD3->D3_NUMSEQ)+"' "
						If TCSPExist("SP_EXCDESP_TOPPROT2")
							cQuery += " , @IDSA = NULL "
							cQuery += " , @CODIGOFILIAL = '"   + PADR(cFilAnt,LEN(SM0->M0_CODFIL)) +  "' "
						EndIf
						cQuery += " End "

			 			Pms_LOG(cQuery,cNameProc,nExec,lContinua)	//Gera Log
			 	Endif
	  		Endif
	  		IF cOperacao = "0"

				If UPPER(tcgetdb()) == "ORACLE"
					cQuery += "BEGIN "
					If TCSPExist("SP_INCDESP_TOPPROT")
						cQuery += " SP_INCDESP_TOPPROT ("
					Else
						cQuery += " SP_APROPRIA_TITULO_PAGAR ("
					Endif
					cQuery += STR(nColigada)
					cQuery += " , '" + Alltrim(cProjeto) +"' "
					cQuery += " , '" + Alltrim(cTarefa)      +"' "
					cQuery += " , '" + Alltrim(AFH->AFH_COD) +"' "
					cQuery += " ,  " + cOperacao    +" "

					If cOperacao $ "0;2" .and. lIDAFH
						cQuery += " ,'" +SD3->D3_NUMSEQ +  "' "
					Else
						cQuery += " , ' ' "	 //VARCHAR,
					Endif
					cQuery += " , "+ Alltrim(str(nQtde))	 //DECIMAL = 1,
					cQuery += " , "+ Alltrim(STR(nCustoTotal/nQtde))	 //DECIMAL,
					cQuery += " , ' ' " //VARCHAR(100), OBS
					cQuery += "	,  TO_DATE( '" + strzero(day(dDataBase),2)+ "/"+ strzero(month(dDataBase),2)+ "/"+strzero(year(dDataBase),4)+ "', 'DD/MM/YYYY') "
					cQuery += " ,'" + GetMv("MV_SIMB"+cMoeda) + "' " //VARCHAR(10)
					cQuery += " , '" + PADR(cFilAnt,LEN(SM0->M0_CODFIL)) + "' "
					cQuery += "); END; "

					// Executa a Stored Procedure
					PMSExecSOLUM(cQuery)
				Else
					cQuery := "CREATE PROCEDURE "    +cNameProc +"("
					cQuery += " @SAIDA Integer OutPut "
					cQuery += ") "
					cQuery += " As "
					cQuery += "Begin Declare @Data DateTime "
					cQuery += "  Select @SAIDA = 0 Select @Data = Convert(DateTime,"+"'"+strzero(year(dDataBase),4)+"-"+ strzero(month(dDataBase),2)+"-"+ strzero(day(dDataBase),2)+ " 00:00:00',120)"
					cQuery += "  EXEC "
					If TCSPExist("SP_APROPRIA_TITULO_PAGAR")
						cQuery += " SP_APROPRIA_TITULO_PAGAR "
					Else
						cQuery += " SP_INCDESP_TOPPROT "
					Endif
					cQuery += "  @CodColigada = "    + STR(nColigada)
					cQuery += " ,@CodProjeto = "    + "'"+AllTrim(cProjeto)+ "' "
					cQuery += " ,@CodTarefa = "     + "'"+AllTrim(cTarefa)+"' "
					cQuery += " ,@CodProduto	= '" + AFH->AFH_COD +"' "
					cQuery += " ,@TipoMovimento	= "+ cOperacao +" "

					If cOperacao $ "0;2" .and. lIDAFH
						cQuery += " ,@IdProtheus	= " +"'"+Alltrim(SD3->D3_NUMSEQ)+"' "
					Else
						cQuery += " ,@IdProtheus	= '0' "
					Endif

					cQuery += " ,@Quantidade	= " +Str(nQtde)
					cQuery += " ,@PrecoUnitario	= "  +STR(nCustoTotal/nqtde)
					cQuery += " ,@Observacao	= ' ' "
					cQuery += " ,@DataAprop	= "     +"@Data "
					cQuery += " ,@Moeda	= '" + GetMv("MV_SIMB"+cMoeda) + "' "
					cQuery += " ,@CODFILIAL_PROTHEUS = " + "'"+PADR(cFilAnt,LEN(SM0->M0_CODFIL)) + "' "
					cQuery += " ,@SAIDA=0"
					cQuery += " End "

					Pms_LOG(cQuery,cNameProc,nExec,lContinua)	//Gera Log
				Endif
			Endif
		EndIf
	EndIf

	// Se a conexao ByYouDBAccess for maior que zero, deve desconectar
	If nSolumConn >0
		TCUnLink(nSolumConn)
	EndIf

	// volta pra conexao ByYouDBAccessao
	tcSetConn(nERPConn)
Endif
Return .T.

// Esta Function abaixo foi transferida do Fonte PMSXFUNB.PRW
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
zฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัอออออออออออออออออออออออออออหออออออัอออออออออออออออปฑฑ
ฑฑบPrograma  ณ PMSIntRm    บAutorณCl๓vis Magenta             บ Data ณ 23/03/2010   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯอออออออออออออออออออออออออออสออออออฯอออออออออออออออนฑฑ
ฑฑณDescri…o ณ Consulta padrใo para buscar do banco de composicoes ou do SX5       ณฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSintaxe   ณ cCode:   	                                                       บฑฑ
ฑฑบ			 ณ		PRD - Cadastro de Produtos									   บฑฑ
ฑฑบ			 ณ		CC - Cadastro de Centro de Custo 							   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Exclusao de um produto - MATA010							           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PmsExcProd(cCode)
Local lExclui 	:= .T.
Local nColigada	:= GetNewPar("MV_RMCOLIG",0) // coligada igual a empresa
Local cQuery 		:= ""
Local aRetProc 	:= {}
Local aArea		:= GetArea()
Local cBlqLan		:= "1"
Local lMsgUnica	:= IsIntegTop()
local aColig		:= {}
local nCnt			:= 0
Local lPMRMCOLIG 	:= ExistBlock("PMRMCOLIG")
Default cCode 	:= ""

If !(lMsgUnica)
	If nColigada > 0
		// Pega a conexao do ByYouDBAccess corrente do Protheus
		nERPConn := AdvConnection()

		// Pega a conexao do ByYouDBAccess corrente do TOP
		nSolumConn := CnnSolum()

		// se houver conexao do ByYouDBAccess com o TOP
		If (nSolumConn>0)

			// efetua a conexao ByYouDBAccess com o banco de dados TOP
			// Retorna a conexao do ByYouDBAccess corrente do Protheus
			tcSetConn(nSolumConn)
			TcInternal( 8, STR0079 )//"Sincronizacao Microsiga Protheus x TOP"
			
			Begin Transaction
			
				Do Case
					Case cCode == "PRD"  // Produto - MATA010
						
						// define a coligada a qual o produto vai ser replicado na base RM
						aAdd(aColig ,nColigada)
	
						// Carrega as coligadas
						If lPMRMCOLIG
							aColig:= ExecBlock("PMRMCOLIG",.F.,.F.,{"SB1",aColig})
							tcSetConn(nERPConn)
						EndIf
						
						For nCnt := 1 to Len(aColig)
							If UPPER(tcgetdb()) == "ORACLE"
								cQuery := "BEGIN "
								cQuery += "sp_exclui_produto_Solum ("
								If ValType(aColig[1]) == "N"
									cQuery +=  AllTrim(Str(aColig[nCnt])) + " "
								Elseif ValType(aColig[1]) == "A"
									cQuery +=  AllTrim(Str(aColig[nCnt,1])) + " "
								Endif
								cQuery += ", '" + alltrim(SB1->B1_COD) + "' "
								cQuery += "); END; "
		
							Else
								cQuery := ""
								cQuery += "sp_exclui_produto_Solum "
								If ValType(aColig[1]) == "N"
									cQuery += " @CodColigada = " + AllTrim(Str(aColig[nCnt])) + " "
								Elseif ValType(aColig[1]) == "A"
									cQuery += " @CodColigada = " + AllTrim(Str(aColig[nCnt,1])) + " "
								Endif
								cQuery += ",@CODIGOPRD = '"+AllTrim(SB1->B1_COD)+"' " //@CODIGOPRD VARCHAR(30)
							Endif
							
							aRetProc := PMSVldProc(cQuery)
		
							If aRetProc[1][1] < 0
								lExclui := .F.
								MsgAlert(STR0081,STR0080)//"Nใo foi possํvel excluir registro na Base de Dados do TOP. Verifique as amarra็๕es existentes.""Aten็ใo"
								Conout(STR0082 + " " +CRLF+aRetProc[1][2])//"Erro na exclusใo do produto: "
								DisarmTransaction()
								Exit
							Endif
						Next nCnt
	
					Case cCode == "CC" .and. !IntTopTin(nColigada)  // Centro de Custo - CTBA030--nao chamnar na integra็ใo tin x top procedure
	
						If CTT->CTT_BLOQ == "1" // Centro de custo bloqueado
							cBlqLan := "0"
						Endif
	
						if UPPER(tcgetdb()) == "ORACLE"
							cQuery := "BEGIN "
	
							cQuery += "sp_Cadastro_CentroDeCusto ("
							cQuery +=         AllTrim(Str(nColigada))  + " "
							cQuery += ", '" + AllTrim(CTT->CTT_CUSTO)  + "' " //varchar(5)
							cQuery += ", '" + FmtStrPrc(CTT->CTT_DESC01) + "' " //P_Nome VARCHAR(100)
							cQuery += ", null " //DCODCOLIGADANULL  -coligada da conta gerencial
							cQuery += ", null " // DCODCONTA
							cQuery += ", null " //DCODCOLIGADANULL - codigo coligada da conta gerencial default
							cQuery += ", null " //DCODCONTA - conta gerencial
							cQuery += ", '"+CTT->CTT_RES+"' " //varchar
							cQuery += ", null " //varchar
							If CTT->(FieldPos("CTT_BLOQ"))>0
								cQuery += ", "+iIf(CTT->CTT_BLOQ=="1" ,"0","1")+" " //BIT
							Else
								cQuery += ", 1 " //BIT
							Endif
							cQuery += ", "+cBlqLan + " " //BIT
							cQuery += ", null " //varchar
							cQuery += ", 0 " //BIT
							cQuery += ", 0 " //int
							cQuery += ", 1 " //P_TipoMovimento  INT --> 0. INCLUIR/ALTERAR, 1. APAGAR
							cQuery += "); END; "
	
						Else
							cQuery := ""
							cQuery += "sp_Cadastro_CentroDeCusto "
							cQuery += " @CodColigada = " + AllTrim(Str(nColigada)) + " "
							cQuery += ",@CODCCUSTO = '"+AllTrim(CTT->CTT_CUSTO)+"' " //varchar(5)
							cQuery += ",@NOME = '"+FmtStrPrc(CTT->CTT_DESC01)+"' " //@Nome VARCHAR(100)
							cQuery += ",@CODCOLCONTAGER = null" //DCODCOLIGADANULL  -coligada da conta gerencial
							cQuery += ",@CODCONTAGER = null" // DCODCONTA
							cQuery += ",@CODCOLCONTA = null" //DCODCOLIGADANULL - codigo coligada da conta gerencial default
							cQuery += ",@CODCONTA = null" //DCODCONTA - conta gerencial
							cQuery += ",@CODREDUZIDO = '"+Alltrim(CTT->CTT_RES)+"'" //varchar
							cQuery += ",@CAMPOLIVRE = null" //varchar
							If CTT->(FieldPos("CTT_BLOQ"))>0
								cQuery += ",@ATIVO = "+iIf(CTT->CTT_BLOQ=="1" ,"0","1")+"" //BIT
							Else
								cQuery += ",@ATIVO = 1 " //BIT
							Endif
							cQuery += ",@PERMITELANC = "+cBlqLan+"" //BIT
							cQuery += ",@CODCLASSIFICA = null " //varchar
							cQuery += ",@ENVIASPED = 0 " //BIT
							cQuery += ",@ID = 0" //int
							cQuery += ",@TipoMovimento = "+ "1" //@TipoMovimento  INT --> 0. INCLUIR/ALTERAR, 1. APAGAR
	
						Endif
	
						aRetProc := PMSVldProc(cQuery)
	
						If aRetProc[1][1] < 0
							lExclui := .F.
							MsgAlert(STR0081,STR0080)//"Nใo foi possํvel excluir registro na Base de Dados do TOP. Verifique as amarra็๕es existentes.""Aten็ใo"
							Conout(STR0083 + " " + CRLF+aRetProc[1][2])//"Erro na exclusใo do Centro de Custo: "
							DisarmTransaction()
						Endif
	
					Case cCode == "UM" // Unidade de Medida - QIEA030
	
						If UPPER(tcgetdb()) == "ORACLE"
	
							cQuery := "BEGIN "
							cQuery += "sp_Unidade_Solum_Protheus ("
							cQuery += "  '" + AllTrim(SAH->AH_UNIMED)+"' "
							cQuery += ", '" + FmtStrPrc(SAH->AH_DESCPO) + "' "
							cQuery += ",  " + "1 ); END; "  // -- 0.ATIVO / 1.INATIVO
						ELSE
							cQuery := ""
							cQuery += "sp_Unidade_Solum_Protheus "
							cQuery += " @CodUnd  = '" + AllTrim(SAH->AH_UNIMED)+"' "
							cQuery += ",@Descricao = '" + FmtStrPrc(SAH->AH_DESCPO) + "' "
							cQuery += ",@TipoMovimento = " + "1"  // -- 0.ATIVO / 1.INATIVO
						ENDIF
	
						aRetProc := PMSVldProc(cQuery)
	
						If aRetProc[1][1] < 0
							lExclui := .F.
							MsgAlert(STR0081,STR0080)//"Nใo foi possํvel excluir registro na Base de Dados do TOP. Verifique as amarra็๕es existentes.""Aten็ใo"
							Conout(STR0084 + " " + CRLF+aRetProc[1][2])//"Erro na exclusใo da Unidade de Medida: "
							DisarmTransaction()
						Endif
	
					Case cCode == "CP" // Condi็ใo de pagamento - MATA360
	
						// define a coligada a qual o produto vai ser replicado na base RM
						aAdd(aColig ,nColigada)
	
						// Carrega as coligadas
						If lPMRMCOLIG
							aColig:= ExecBlock("PMRMCOLIG",.F.,.F.,{"SE4",aColig})
							tcSetConn(nERPConn)
						EndIf
	
						For nCnt := 1 to len(aColig)
							If UPPER(tcgetdb()) == "ORACLE"
								cQuery := "BEGIN " //"EXEC "
								cQuery += "sp_Condicao_Pagamento ("
								If ValType(aColig[1]) == "N"
									cQuery +=         AllTrim(STR(aColig[nCnt])) + " "		//INT, --> codigo coligada
								Elseif ValType(aColig[1]) == "A"
									cQuery +=         AllTrim(STR(aColig[nCnt,1])) + " "		//INT, --> codigo coligada
								Endif
								cQuery += ", '" + SE4->E4_CODIGO + "' "	//VARCHAR(5)
								cQuery += ", '" + FmtStrPrc(SE4->E4_DESCRI) + "' "	// VARCHAR(100)
								cQuery += ", 2 "	//INT --> 0-INCLUIR, 1-ALTERAR, 2-APAGAR (somente via MATA360)
								cQuery += "); END; "
		
							Else
								cQuery := "" //"EXEC "
								cQuery += "sp_Condicao_Pagamento "
								If ValType(aColig[1]) == "N"
									cQuery += " @CodColigada = "+ AllTrim(STR(aColig[nCnt])) + " " //INT, --> codigo coligada
								Elseif ValType(aColig[1]) == "A"
									cQuery += " @CodColigada = "+ AllTrim(STR(aColig[nCnt,1])) + " " //INT, --> codigo coligada
								Endif
								cQuery += ",@CodCPG = '" + AllTrim(SE4->E4_CODIGO) + "' " //VARCHAR(5)
								cQuery += ",@Nome = '"+FmtStrPrc(SE4->E4_DESCRI)+"' "  // VARCHAR(100)
								cQuery += ",@TipoMovimento = 2 "  //INT --> 0-INCLUIR, 1-ALTERAR, 2-APAGAR (somente via MATA360)
		
							Endif
		
							aRetProc := PMSVldProc(cQuery)
		
							If aRetProc[1][1] < 0
								lExclui := .F.
								MsgAlert(STR0081,STR0080)//"Nใo foi possํvel excluir registro na Base de Dados do TOP. Verifique as amarra็๕es existentes.""Aten็ใo"
								Conout(STR0085 + " " + CRLF+aRetProc[1][2])//"Erro na exclusใo da Condi็ใo de Pagamento: "
								DisarmTransaction()
							Endif
						Next nCnt
				EndCase
			
			End Transaction
		Endif
	Endif
	// Se a conexao ByYouDBAccess for maior que zero, deve desconectar
	If nColigada > 0 //verifica se a integra็ใo com o top estแ ligada Adicionado por  Jandir Deodato em 11/11/11
		If nSolumConn >0
			TCUnLink(nSolumConn)
		EndIf
		tcSetConn(nERPConn) // volta pra conexao ByYouDBAccess Padrao
	Endif
Endif
RestArea(aArea)
Return lExclui

//-------------------------------------------------------------------
/*/{Protheus.doc} FmtStrPrc
	Funcao para retirar carcteres especiais de textos que serao passados para procedures evitando
	inconsistencias na transacao.

	@param	cTexto Texto que terแ os caracteres especiais tratados
	@author	Luํs Gustavo dias <luis.gustavo@totvs.com.br>
	@version	P11
	@since	04/07/2012
	@return	cResultado
/*/
//-------------------------------------------------------------------
Static Function FmtStrPrc(cTexto)
	Local cResultado := ""

	cResultado := Alltrim(StrTran(cTexto, "'", "''"))
Return cResultado

//-------------------------------------------------------------------
/*{Protheus.doc} IsIntegTop(cMarca,lTodas)
	Fun็ใo que verifica se o PMS esta integrado. Caso seja informado no segundo parametro .T., a fun็ใo verifica se o PMS esta integrado com alguem, independente
	se via parametro MV_PMSITMU ou RMCOLIG. Caso nao seja enviado ou seja enviado .F. , a rotina verifica se o protheus ้ maior que
	11.80 e somente em caso afirmativo, verifica se o Pms esta integrado via mensagem unica.


	@param	cMarca Parametro que serแ utilizado na mensagem unica a principio para verificar se esta integrado
	@param lTodas	Se verifica todos os tipos de integra็ใo ou somente via msg unica
	@author	Jandir Deodato
	@version	P11
	@since	24/01/2013
	@return	lRet
*/
//-------------------------------------------------------------------

Function IsIntegTop(cMarca,lTodas)
Local lRet		:=.F.
Local cMsgUnica	:=GetNewPar("MV_PMSITMU","0")
Local nColigada	:=GetNewPar("MV_RMCOLIG",0)
Default cMarca	:=''
Default lTodas :=.F.


If  lVersao .and. AllTrim(cMsgUnica) =="1"
	lRet:= .T.
ElseIf  lTodas .and. nColigada >0
	lRet:= .T.
Endif

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} IsTOPXTIN(cAliasCode,cCode)
	Fun็ใo de Busca dos de-para na integra็ใo Protheus x top x tin


	@param cAliasCode		Codigo do Alias do de-para
	@param cCode			De para recebido
	@author	Jandir Deodato
	@version	P11
	@since	24/04/2013
	@return	cRetCode - Retorna o InternalId. Para cliente/fornecedor, traz a concatena็ใo de codigo+loja.

*/
//-------------------------------------------------------------------

Function IsTOPXTIN(cAliasCode,cCode)

Local aARea:=GetArea()
Local cCampo:=''
Local cRetCode:=''
Local aRetorno:={}
Local cVersion:='1.000'

Default cCode:=''
Default cAliasCode:=''


If cAliasCode=='SA1'
	cCampo:= 'A1_COD'
	If FindFunction('IntCliInt')//existe a fun็ใo da versใo 2.000 da mensagem
		cVersion:=AllTrim(PmsMsgUVer('CUSTOMERVENDOR','MATA030'))
		aRetorno:=IntCliInt(cCode, 'RM', cVersion)
		If aREtorno[1]
			If cVersion=='1.000'
				cRetCode:=aRetorno[2][1]+aRetorno[2][2]
			Else
				cRetCode:=PAdr(aRetorno[2][3],TamSX3("A1_COD")[1])+PAdr(aRetorno[2][4],TamSX3("A1_LOJA")[1])
			Endif
		Endif
	Else
		cRetCode:=CFGA070INT( 'RM', cAliasCode, cCampo, cCode )
	Endif
ElseIf cAliasCode=='SA2'
	cCampo:= 'A2_COD'
	If FindFunction('IntForInt')//existe a fun็ใo da versใo 2.000 da mensagem
		cVersion:=AllTrim(PmsMsgUVer('CUSTOMERVENDOR','MATA020'))
		aRetorno:=IntForInt(cCode, 'RM', cVersion)
		If aREtorno[1]
			If cVersion=='1.000'
				cRetCode:=aRetorno[2][1]+aRetorno[2][2]
			Else
				cRetCode:=Padr(aRetorno[2][3],TamSx3("A2_COD")[1])+Padr(aRetorno[2][4],TamSx3("A2_LOJA")[1])
			Endif
		Endif
	Else
		cRetCode:=CFGA070INT( 'RM', cAliasCode, cCampo, cCode )
	Endif
ElseIf cAliasCode=='SED'
	If FindFunction('F10GetInt')
		aRetorno:=F10GetInt(cCode, 'RM')
		If aRetorno[1]
			cRetCode:=aRetorno[2][1]+aRetorno[2][2]
		Endif
	Else
		cCampo:='ED_CODIGO'
		cRetCode:=CFGA070INT( 'RM', cAliasCode, cCampo, cCode )
	Endif
ElseIf cAliasCode =='CTT'
	If FindFunction('IntCusInt')
		cVersion:=AllTrim(PmsMsgUVer('COSTCENTER','CTBA030'))
		aRetorno:=IntCusInt( cCode, 'RM', cVersion)
		If aRetorno[1]
			If cVersion=='1.000'
				cRetCode:=aRetorno[2][1]+aRetorno[2][2]
			Else
				cRetCode:=aRetorno[2][2]+aRetorno[2][3]
			Endif
		Endif
	Else
		cCampo:='CTT_CUSTO'
		cRetCode:=CFGA070INT( 'RM', cAliasCode, cCampo, cCode )
	Endif
Endif

RestArea(aARea)
Return cRetCode

//-------------------------------------------------------------------
/*{Protheus.doc} IntTOPTIN(nColigada)
	Fun็ใo que verifica se a integra็ใo tripla protheus x top x tin esta ativa.


	@param	nColigada		Codigo da coligada do TOp

	@author	Jandir Deodato
	@version	P11
	@since	24/04/2013
	@return	lRet - Indica se a integra็ใo estแ ativa


*/
//-------------------------------------------------------------------

Function IntTOPTIN(nColigada)
Local lRet:=.F.
Default nColigada := 0

//chamada da fun็ใo para saber se a integra็ใo Protheus x Tin via Mensagem ฺnica x Totvs Obras e Projetos via Stored Procedure estแ ligada.
If FindFunction ('FWHASEAI') .and. FwHasEai("FINA055") .and. nColigada > 0 .and. FindFunction ("CFGA070INT") .and. !IsIntegTop()//TOP via mu nao pode estar ligado
 lRet:=.T.
Endif

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} PmsMsgUVer(cMensagem,cRotina)
	Fun็ใo que verifica a versใo de uma mensagem ๚nica cadastrada no adapter EAI


	@param	cMensagem		Nome da Mensagem ๚nica a ser pesquisada
	@param cRotina		Rotina que possui a IntegDef da Mensagem Unica

	@author	Jandir Deodato
	@version	P11
	@since	24/04/2013
	@return	cVersion Versใo da mensagem ๚nica cadastrada no Configurador.


*/
//-------------------------------------------------------------------


Function PmsMsgUVer(cMensagem,cRotina)

Local aArea		:= GetArea()
Local aAreaXX4	:= {}
Local cVersion	:= '1.000'

dbSelectArea('XX4')
XX4->(dbSetOrder(1))
	
aAreaXX4 := XX4->(GetArea())

//Ajuste Adapter Produto
If AllTrim(Upper(cRotina)) == "MATA020" .And. FWXX4Seek("MATA020M")
	A020AjInteg()
Endif

If FindFunction("FwAdapterVersion")
	cVersion := FwAdapterVersion(cRotina)
Else	
	cRotina := Padr(cRotina,Len(XX4_ROTINA))
	
	cMensagem := PADR(cMensagem,Len(XX4_MODEL))
		
	IF XX4->(DbSeek(xFilial('XX4')+ cRotina + cMensagem))
		If !Empty(XX4->XX4_SNDVER)
			cVersion := XX4->XX4_SNDVER
		Endif
	Endif
EndIf

RestArea(aAreaXX4)
RestArea(aArea)

Return cVersion

//-------------------------------------------------------------------
/*/{Protheus.doc} AdpLogEAI
  Fun็ใo para gravar arquivo de log das opera็๕es efetuadas nos adapters
   de mensagem ๚nica.

   @param   nTipoLog Tipo de log
                     1 - Inํcio do adapter
                     2 - String
                     3 - Variแvel
                     4 - Opera็ใo
                     5 - Encerramento do adapter
   @param   xLog     String para gravar no log
   @param   xVar     Variแvel para gravar no log
   @param   xVar2    Variแvel utilizada no tipo 1
   @param   xVar3    Variแvel utilizada no tipo 1

   @author  Mateus Gustavo de Freitas e Silva
   @version P11
   @since   21/11/2012
/*/
//-------------------------------------------------------------------
Function AdpLogEAI(nTipoLog, xLog, xVar, xVar2, xVar3)
   Local nNivelLog := GetNewPar("MV_INTLOG", 0)
   Local cDirLog   := GetNewPar("MV_INTPATH", "\logs\EAI\")
   Local cFileLog  := ""
   Local aDirLog   := {}
   Local I         := 1

   If nNivelLog > 0
      If Right(cDirLog, 1)== "\"
         cDirLog := SubStr(cDirLog , 1, Len(cDirLog) - 1)
      EndIf

      aDirLog := strtokarr (cDirLog, "\")

      For I:= 1 To Len(aDirLog)
         If I == 1
            cDirLog := '\' + aDirLog[I]
         Else
            cDirLog += '\' + aDirLog[I]
         EndIf

         If !ExistDir(cDirLog)
            If MakeDir(cDirLog) != 0
               ConOut(STR0086 + cDirLog + ").") //"Nใo foi possํvel criar o diret๓rio de log do adapter EAI ("
            EndIf
         EndIf
      Next I

      cFileLog := cDirLog + "\EAI-" + PadL(AllTrim(Str(Day(Date()))), 2, '0') + '-' + PadL(AllTrim(Str(Month(Date()))), 2, '0') + '-' + Transform(Year(Date()), '9999') + ".log"

      If !File(cFileLog)
         //Crio o arquivo de LOG com o nome da maquina onde esta sendo acessado
         nHandle := FCreate(cFileLog, Nil, Nil, .F.)
      Else
         nHandle := FOpen(cFileLog, 1)
         FSeek(nHandle, 0, 2)
      EndIf

      If nHandle == -1
         Do Case
            Case Ferror() == 2
               ConOut(STR0087 + cFileLog) //"Arquivo nใo encontrado. "
            Case Ferror() == 3
               ConOut(STR0088 + cFileLog) //"Diret๓rio nใo encontrado. "
            Case Ferror() == 4
               ConOut(STR0089 + cFileLog) //"Muitos arquivos foram abertos. Verifique o parโmetro FILES. "
            Case Ferror() == 5
               ConOut(STR0090 + cFileLog) //"Impossํvel acessar o arquivo. "
            Case Ferror() == 6
               ConOut(STR0091 + cFileLog) //"N๚mero de manipula็ใo de arquivo invแlido. "
            Case Ferror() == 8
               ConOut(STR0092 + cFileLog) //"Mem๓ria insuficiente. "
            Case Ferror() == 15
               ConOut(STR0093 + cFileLog) //"Acionador (Drive) de discos invแlido. "
            Case Ferror() == 19
               ConOut(STR0094 + cFileLog) //"Tentativa de gravar sobre um disco protegido contra escrita. "
            Case Ferror() == 21
               ConOut(STR0095 + cFileLog) //"Acionador (Drive) de discos inoperante. "
            Case Ferror() == 23
               ConOut(STR0096 + cFileLog) //"Erro de dados no disco. "
            Case Ferror() == 29
               ConOut(STR0097 + cFileLog) //"Erro de grava็ใo no disco. "
            Case Ferror() == 30
               ConOut(STR0098 + cFileLog) //"Erro de leitura no disco. "
            Case Ferror() == 32
               ConOut(STR0099 + cFileLog) //"Viola็ใo de compartilhamento. "
            Case Ferror() == 33
               ConOut(STR0100 + cFileLog) //"Viola็ใo de bloqueio. "
         EndCase

         FClose(nHandle)
      EndIf

      Do Case
         Case nTipoLog == 1
            If !Empty(xVar3)
               xVar3 := DecodeUtf8(xVar3)
            EndIf

            FWrite(nHandle, "################################ " + STR0101 + xLog + " ################################") //"INICIO "
            FWrite(nHandle, CRLF)
            FWrite(nHandle, PadR(STR0102, 20, ".") + ": " + Dtoc(MsDate())) //"Data"
            FWrite(nHandle, CRLF)
            FWrite(nHandle, PadR(STR0103, 20, ".") + ": " + Time()) //"Hora"
            FWrite(nHandle, CRLF)
            FWrite(nHandle, PadR(STR0104, 20, ".") + ": " + cEmpAnt) //"Empresa"
            FWrite(nHandle, CRLF)
            FWrite(nHandle, PadR(STR0105, 20, ".") + ": " + cFilAnt) //"Filial"
            FWrite(nHandle, CRLF)

            If !Empty(xVar) .And. xVar == '0'
               FWrite(nHandle, PadR(STR0106, 20, ".") + ": " + STR0107) //"Sentido" "Recebimento"
               FWrite(nHandle, CRLF)
            ElseIf !Empty(xVar) .And. xVar == '1'
               FWrite(nHandle, PadR(STR0106, 20, ".") + ": " + STR0108) //"Sentido" "Envio"
               FWrite(nHandle, CRLF)
            EndIf

            If !Empty(xVar2) .And. xVar2 == '10'
               FWrite(nHandle, PadR(STR0109, 20, ".") + ": " + STR0110) //"Tipo" "EAI Mensagem Protheus"
               FWrite(nHandle, CRLF)
            ElseIf !Empty(xVar2) .And. xVar2 == '11'
               FWrite(nHandle, PadR(STR0109, 20, ".") + ": " + STR0111) //"Tipo" "EAI Mensagem Protheus com MVC"
               FWrite(nHandle, CRLF)
            ElseIf !Empty(xVar2) .And. xVar2 == '20'
               FWrite(nHandle, PadR(STR0109, 20, ".") + ": " + STR0112) //"Tipo" "EAI Mensagem Unica Business Message"
               FWrite(nHandle, CRLF)
            ElseIf !Empty(xVar2) .And. xVar2 == '21'
               FWrite(nHandle, PadR(STR0109, 20, ".") + ": " + STR0113) //"Tipo" "EAI Mensagem Unica Response Message"
               FWrite(nHandle, CRLF)
            ElseIf !Empty(xVar2) .And. xVar2 == '22'
               FWrite(nHandle, PadR(STR0109, 20, ".") + ": " + STR0114) //"Tipo" "EAI Mensagem Unica Receipt Message"
               FWrite(nHandle, CRLF)
            ElseIf !Empty(xVar2) .And. xVar2 == '23'
               FWrite(nHandle, PadR(STR0109, 20, ".") + ": " + STR0115) //"Tipo" "EAI Mensagem Unica WhoIs Message"
               FWrite(nHandle, CRLF)
            ElseIf !Empty(xVar2)
               FWrite(nHandle, PadR(STR0109, 20, ".") + ": " + STR0116) //"Tipo" "EAI Mensagem Unica Send"
               FWrite(nHandle, CRLF)
            EndIf

            If !Empty(xVar3)
               FWrite(nHandle, PadR("UUID", 20, ".") + ": " + SubStr(xVar3, At('<UUID>', xVar3) + 6, 36))
               FWrite(nHandle, CRLF)
            EndIf

            If !Empty(xVar3) .And. (xVar2 == '21' .Or. xVar2 == '22')
               cDirLog := SubStr(xVar3, At('<ReceivedMessage>', xVar3))
               FWrite(nHandle, PadR(STR0117, 20, ".") + ": " + SubStr(cDirLog, At('<UUID>', cDirLog) + 6, 36)) //"UUID Original"
               FWrite(nHandle, CRLF)
            EndIf

            If !Empty(xVar3)
               FWrite(nHandle, PadR(STR0118, 20, ".") + ": " + SubStr(xVar3, At('<Transaction>', xVar3) + 13, At('</Transaction>', xVar3) - At('<Transaction>', xVar3) - 13)) //"Transa็ใo"
               FWrite(nHandle, CRLF)
            EndIf

            If !Empty(xVar3) .And. nNivelLog == 2
               FWrite(nHandle, PadR("xml", 20, ".") + ": " + xVar3)
               FWrite(nHandle, CRLF)
            EndIf
         Case nTipoLog == 2 .And. nNivelLog == 2
            FWrite(nHandle, xLog)
            FWrite(nHandle, CRLF)
         Case nTipoLog == 3 .And. nNivelLog == 2
            FWrite(nHandle, VarInfo(xLog, xVar, 0, .F., .F.))
            FWrite(nHandle, CRLF)
         Case nTipoLog == 4 .And. nNivelLog == 2
            If xLog == 3
               FWrite(nHandle, PadR(STR0119, 20, ".") + ": " + STR0120) //"Opera็ใo" "Inclusใo"
               FWrite(nHandle, CRLF)
            ElseIf xLog == 4
               FWrite(nHandle, PadR(STR0119, 20, ".") + ": " + STR0121) //"Opera็ใo" "Altera็ใo"
               FWrite(nHandle, CRLF)
            ElseIf xLog == 5
               FWrite(nHandle, PadR(STR0119, 20, ".") + ": " + STR0122) //"Opera็ใo" "Exclusใo"
               FWrite(nHandle, CRLF)
            Else
               FWrite(nHandle, PadR(STR0119, 20, ".") + ": " + STR0123) //"Opera็ใo" "Desconhecido"
               FWrite(nHandle, CRLF)
            EndIf
         Case nTipoLog == 5
            If !Empty(xVar2)
               If xVar2 == .T.
                  FWrite(nHandle, PadR(STR0124, 20, ".") + ": " + STR0125) //"Status Retorno" "Ok"
                  FWrite(nHandle, CRLF)
               ElseIf xVar3 == .F.
                  FWrite(nHandle, PadR(STR0124, 20, ".") + ": " + STR0126) //"Status Retorno" "Error"
                  FWrite(nHandle, CRLF)
               Else
                  FWrite(nHandle, PadR(STR0124, 20, ".") + ": " + STR0127) //"Status Retorno" "Unknown"
                  FWrite(nHandle, CRLF)
               EndIf
            EndIf

            If !Empty(xVar) .And. nNivelLog == 2
               FWrite(nHandle, PadR(STR0128, 20, ".") + ": " + xVar) //"Retorno"
               FWrite(nHandle, CRLF)
            EndIf

            FWrite(nHandle, '################################ FINAL  ' + xLog + ' ################################')
            FWrite(nHandle, CRLF + CRLF)
      EndCase

      If nHandle > 0
         FClose(nHandle)
      EndIf
   EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} IntChcEmp
Fun็ใo que retorna a filial do registro recebido.
O RM permite estar logado em uma filial no contexto e manipular registros
de outras filiais. Neste caso o EAI utiliza a filial do Messageinformation
(contexto) para logar no Protheus e esta fun็ใo altera a filial corrente
para a filial do registro.
No execauto dos formulแrios MVC nใo informamos o c๓digo da filial. Ele
utiliza a filial logada.

@param   oXML     Objeto xml com o xml da mensagem parseado
@param   cAlias   Alias da tabela do cadastro
@param   cProduto Produto da integra็ใo
@author  Mateus Gustavo de Freitas e Silva
@version P11
@since   18/12/2012

@return aEmpresas Valor booleano indicando se o de/para de empresa
         foi informado corretamente e a filial a ser utilizada no cadastro.
/*/
//-------------------------------------------------------------------
Function IntChcEmp(oXML, cAlias, cProduto)
   Local aFilialP := {}
   Local cEmp     := ""
   Local cFil     := ""
   Local cEmpProt := ""
   Local cFilProt := ""
   Local lLog     := FindFunction("AdpLogEAI")

   If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CompanyId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CompanyId:Text)
      cEmp := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CompanyId:Text
   EndIf

   If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BranchId:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BranchId:Text)
      cFil := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BranchId:Text
   EndIf

   // Se o cadastro ้ compartilhado a nํvel de filial ou a nํvel de empresa no RM
   // As tags CompanyID e BranchId podem vir vazias
   If Empty(cEmp)
      If lLog
         AdpLogEAI(2, STR0129 + Chr(10) + STR0130) //"Empresa compartilhada." "Tag CompanyId do BusinessContent veio vazia."
      EndIf
   EndIf

   If Empty(cFil)
      If lLog
         AdpLogEAI(2, STR0131 + Chr(10) + STR0132) //"Filial compartilhada." "Tag BranchId do BusinessContent veio vazia."
      EndIf
   EndIf

   If Empty(cEmp) .Or. Empty(cFil)
      aAdd(aFilialP, .T.)
      aAdd(aFilialP, cFilProt)

      Return aFilialP
   EndIf

   aFilialP := FWEAIEMPFIL(cEmp, cFil, cProduto)

   If Empty(aFilialP)
      If lLog
         AdpLogEAI(2, STR0133 + cEmp + "/" + cFil + STR0134 + cProduto + ".") //"Empresa/Filial " " recebida no BusinessContent nใo esta cadastrada no de/para para o produto "
      EndIf

      cEmpProt := cEmpAnt
      cFilProt := cFilAnt
   Else
      cEmpProt := aFilialP[1]
      cFilProt := aFilialP[2]
   EndIf

   If cEmpProt != cEmpAnt
      If lLog
         AdpLogEAI(2, STR0104 + " " + cEmpProt + STR0134 + cEmpAnt + STR0135) //"Empresa" " recebida no BusinessContent ้ diferente da empresa " " enviada no MessageInformation."
      EndIf

      cEmpProt := cEmpAnt
      cFilProt := cFilAnt
   EndIf

   aFilialP := {}

   If cFilAnt != cFilProt
      If lLog
         AdpLogEAI(2, STR0136) //"Altera็ใo de filial."
         AdpLogEAI(2, STR0137 + cFilAnt) //"Filial Anterior: "
      EndIf

      cFilAnt := cFilProt

      If lLog
         AdpLogEAI(2, STR0138 + cFilAnt) //"Nova Filial: "
      EndIf
   EndIf

   aAdd(aFilialP, .T.)
   aAdd(aFilialP, cFilProt)
Return aFilialP

//-------------------------------------------------------------------
/*/{Protheus.doc} IntRatPrjCC
Recebe um array com os dados do centro de custo e um array com os
dados do projeto e tarefa e retorna um array com o rateio no formato
do RM Nucleos.

@param   aCntrCst Array com o dados de centro de custo
         [1] - Centro de Custo
         [2] - Conta Contabil
         [3] - Item da Conta Contabil
         [4] - Classe Valor Contabil
         [5] - % Rateio do Item
@param   aPrjtTrf Array com os dados de projeto/tarefa
         [1] - Codigo do Projeto
         [2] - Versao do Projeto
         [3] - Codigo da Tarefa
         [4] - Quantidade do Projeto
@author  Mateus Gustavo de Freitas e Silva
@version P11
@since   08/03/2013

@return aResult Array com os dados do rateio de centro de custo e de
        projeto/tarefa no formato do RM Nucleos.
         [1] - Centro de Custo
         [2] - Conta Contabil
         [3] - Item da Conta Contabil
         [4] - Classe Valor Contabil
         [5] - % Rateio do Item
         [6] - Codigo do Projeto
         [7] - Codigo da Tarefa
         [8] - Qtd Rateio do Item

/*/
//-------------------------------------------------------------------
Function IntRatPrjCC(aCntrCst, aPrjtTrf)
   Local aResult   := {}
   Local nI        := 0
   Local nJ        := 0
   Local nQuantTot := 0
   Local aTemp     := {}
   Local nQuant    := 0
   Local nPercent  := 0
   Local nPercTot  := 0
   Local nDecAFN   := TamSx3("AFN_QUANT")[2]

   //Calcula a Total de Itens do Rateio para calcular o percentual
   If !Empty(aPrjtTrf)
      For nI := 1 To Len(aPrjtTrf)
         nQuantTot += aPrjtTrf[nI][4]
      Next nI
   EndIf

   // Se nใo possuir rateio de projeto/tarefa
   If Empty(aPrjtTrf)
      For nI := 1 To Len(aCntrCst)
         aAdd(aTemp, aCntrCst[nI][1])
         aAdd(aTemp, aCntrCst[nI][2])
         aAdd(aTemp, aCntrCst[nI][3])
         aAdd(aTemp, aCntrCst[nI][4])
         aAdd(aTemp, aCntrCst[nI][5])
         aAdd(aTemp, "")
         aAdd(aTemp, "")
         aAdd(aTemp, "")
         aAdd(aResult, aClone(aTemp))
         aTemp := {}
      Next nI
   // Se nใo possuir rateio de centro de custo
   ElseIf Empty(aCntrCst)
      For nI := 1 To Len(aPrjtTrf)
         nPercent := Round(aPrjtTrf[nI][4] / nQuantTot, 2)
         nPercTot += nPercent

         aAdd(aTemp, "")
         aAdd(aTemp, "")
         aAdd(aTemp, "")
         aAdd(aTemp, "")
         aAdd(aTemp, nPercent * 100)
         aAdd(aTemp, aPrjtTrf[nI][1])
         aAdd(aTemp, aPrjtTrf[nI][3])
         aAdd(aTemp, aPrjtTrf[nI][4])
         aAdd(aResult, aClone(aTemp))
         aTemp := {}
      Next nI
   // Se possuir rateio de centro de custo e rateio de projeto/tarefa
   Else
      //Calcula o rateio com o centro de custo e o projeto vinculados
      For nI := 1 To Len(aPrjtTrf)
         For nJ := 1 To Len(aCntrCst)
            nQuant := Round(aPrjtTrf[nI][4] * aCntrCst[nJ][5] / 100, nDecAFN)
            nPercent := Round(nQuant / nQuantTot * 100, 2)
            nPercTot += nPercent

            aAdd(aTemp, aCntrCst[nJ][1])
            aAdd(aTemp, aCntrCst[nJ][2])
            aAdd(aTemp, aCntrCst[nJ][3])
            aAdd(aTemp, aCntrCst[nJ][4])
            aAdd(aTemp, nPercent)
            aAdd(aTemp, aPrjtTrf[nI][1])
            aAdd(aTemp, aPrjtTrf[nI][3])
            aAdd(aTemp, nQuant)
            aAdd(aResult, aClone(aTemp))
            aTemp := {}

         Next nJ
      Next nI
   EndIf

	//Ajusta o ๚ltimo percentual para fechar 100%
	If Len(aResult) > 0
		If (aResult[Len(aResult)][5] + (100 - nPercTot)) > 100
			nDif := (aResult[Len(aResult)][5] + (100 - nPercTot)) - 100
		Else
			nDif := aResult[Len(aResult)][5] + (100 - nPercTot)
		Endif

		aResult[Len(aResult)][5] := nDif
	EndIf

Return aResult


//-------------------------------------------------------------------
/*/{Protheus.doc} PmsxVatu1
Retorna o valor do B2_VATU1 por Filial
@author Jos้ Eulแlio
@since 05/09/2017
@param cCod,lQatu
@version 1.0
/*/
//------------------------------------------------------------------
Function PmsxVatu1(cCod,lQatu)
Local nVatu1		:= 0
Local cQuery		:= ""
Local cAliasTop	:= GetNextAlias()
Local cCusFil		:= SuperGetMV("MV_CUSFIL",.F.,"A")

Default lQatu		:= .T.

cQuery := " SELECT "
cQuery += " 	COALESCE(( SUM(SB2.B2_VATU1) "

If lQatu
	cQuery += " /  SUM(SB2.B2_QATU)"
EndIf

cQuery += "  ),0) TOTVLR "
cQuery += " FROM " + RetSqlName("SB2") + " SB2 "
cQuery += " WHERE "
If cCusFil == "F"
	cQuery += " 	SB2.B2_FILIAL = '" + xFilial("SB2") + "' AND "
EndIf
cQuery += " 	SB2.B2_COD = '" + cCod + "' AND "
cQuery += "	SB2.B2_QATU > 0 AND "
cQuery += " 	SB2.D_E_L_E_T_ = ' ' "
	
cQuery := ChangeQuery(cQuery)
		
dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasTop)

nVatu1 := (cAliasTop)->TOTVLR

(cAliasTop)->(DbCloseArea())	

Return nVatu1

//-------------------------------------------------------------------
/*/{Protheus.doc} ExcCNO
Verifica se deve excluir o Codigo Nacinal de Obra da SON
@author William Pianheri
@since 07/03/2018
@param cCodCNO
@version 1.0
/*/
//------------------------------------------------------------------

Function ExcSON(cCodCNO)
Local aArea		:= GetArea()
Local cAliasAF8	:= getNextAlias()
Local cAliasSC5	:= getNextAlias()
Local cAliasSF2	:= getNextAlias()
Local lRet			:= .T.
Local aErro		:= {}
Local aMessages	:= {}	
Local cXMLRet		:= ""
Local nCount		:= 0

Private lMsErroAuto	:= .F.

Default cCodCNO	:= ""

 		
//Verifica็ใo de relacionamentos (outras dependencias do CNO) 		
BeginSql Alias cAliasAF8 //Projetos
	Select Count(*) TOTAL
	From %Table:AF8% PROJETO
	Where PROJETO.AF8_CNO = %Exp:cCodCNO% And PROJETO.%notdel%
EndSql
	
BeginSql Alias cAliasSC5 //Pedidos de Venda
	Select Count(*) TOTAL
	From  %Table:SC5% PEDIDO
	Where PEDIDO.C5_CNO = %Exp:cCodCNO% And PEDIDO.%notdel%
EndSql
	
BeginSql Alias cAliasSF2 //Notas de Saํda
	Select Count(*) TOTAL
	From  %Table:SF2% NOTA
	Where NOTA.F2_CNO = %Exp:cCodCNO% And NOTA.%notdel%
EndSql
			                 
 
If (cAliasAF8)->TOTAL = 0 .AND. (cAliasSC5)->TOTAL = 0 .AND. (cAliasSF2)->TOTAL = 0 
	SON->(DBSetOrder(1))
	If SON->(DBSeek(xFilial("SON")+cCodCNO))
		MSExecAuto({|x, y| MATA322(x, y)}, 5, {{"ON_CODIGO"	,cCodCNO,Nil}})

		If lMsErroAuto
			aErro := GetAutoGRLog()
			lRet := .F.
			cXMLRet := '<![CDATA['
			For nCount := 1 To Len(aErro)
				cXMLRet += cValToChar(aErro[nCount]) + CRLF
			Next nCount
			cXMLRet += ']]>'
			aAdd(aMessages, {cXMLRet , 1, Nil})
		EndIf  
	EndIf
EndIf

(cAliasAF8)->(dbCloseArea())
(cAliasSC5)->(dbCloseArea()) 
(cAliasSF2)->(dbCloseArea())  

RestArea(aArea)
Return({lRet,aMessages})