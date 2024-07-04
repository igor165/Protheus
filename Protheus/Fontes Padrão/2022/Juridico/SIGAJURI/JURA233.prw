#INCLUDE "JURA233.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

Static cMasNumPro

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA233
Contem As Informacoes e-Social.

@author Reginaldo N Soares
@since 06/04/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA233(/*cCajuri, oModel095*/)
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "O08" )
oBrowse:SetLocate()
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transa��o a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Altera��o sem inclus�o de registros
7 - C�pia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Reginaldo N Soares
@since 06/04/17
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA233", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA233", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA233", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA233", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA233", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Contem As Informacoes e-Social.

@author Reginaldo N Soares
@since 06/04/17
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA233" )
Local oStruct := FWFormStruct( 2, "O08" )

	JurSetAgrp( 'O08',, oStruct )

	oView := FWFormView():New()
	oView:SetModel( oModel )

	oStruct := JBreakLine(oStruct, "O08_NUMPRO")
	oStruct := JBreakLine(oStruct, "O08_FIMINS")
	oStruct := JBreakLine(oStruct, "O08_INDMAT")
	oStruct := JBreakLine(oStruct, "O08_IDVARA")
	oStruct := JBreakLine(oStruct, "O08_CODSUS")

	oView:AddField( "JURA233_VIEW", oStruct, "O08MASTER"  )
	oView:CreateHorizontalBox( "FORMFIELD", 100 )
	oView:SetOwnerView( "JURA233_VIEW", "FORMFIELD" )
	oView:SetDescription( STR0007 ) // "Contem As Informacoes e-Social."
	oView:EnableControlBar( .T. )

	oStruct:RemoveField( "O08_CAJURI" )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Contem As Informacoes e-Social.

@author Reginaldo N Soares
@since 06/04/17
@version 1.0

@obs O08MASTER - Dados do Contem As Informacoes e-Social.

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "O08" )

	//-----------------------------------------
	//Monta o modelo do formul�rio
	//-----------------------------------------
	oModel:= MPFormModel():New( "JURA233", /*Pre-Validacao*/,{|oX| JA233TOK(oX)} /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
	oModel:AddFields( "O08MASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:SetDescription( STR0008 ) // "Modelo de Dados de Contem As Informacoes e-Social."
	oModel:GetModel( "O08MASTER" ):SetDescription( STR0009 ) // "Dados de Contem As Informacoes e-Social."
	JurSetRules( oModel, 'O08MASTER',, 'O08' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J233PRO(cTipoAS)
Retorna a mascara do campo O08_NUMPRO
Uso no cadastro de instancias do processo campo X3_PICTVAR
@return lValido	- Informa se o valor do campo foi aceito
@since 06/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function J233PRO()
Return cMasNumPro

//-------------------------------------------------------------------
/*/{Protheus.doc} J233LstInd()
Rotina que contem array com a lista de Indicativo da mat�ria do processo ou alvar� judicial.

@author Reginaldo N Soares
@since 06/04/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J233LstInd()
Local aLstInd   := {}
Local cRet      :="C"
Local nCont     := 0
Local cLstInd   := ""

	aAdd(aLstInd,STR0012) //"01=Tribut�ria ou relativa a FGTS"
	aAdd(aLstInd,STR0013) //"02=Autoriza��o de trabalho de menor"
	aAdd(aLstInd,STR0014) //"03=Dispensa, ainda que parcial, de contrata��o de pessoa com defici�ncia (PCD)"
	aAdd(aLstInd,STR0015) //"04=Dispensa, ainda que parcial, de contrata��o de aprendiz"
	aAdd(aLstInd,STR0016) //"05=Seguran�a e sa�de do trabalhador"
	aAdd(aLstInd,STR0017) //"06=Convers�o de Licen�a Sa�de em Acidente de Trabalho"
	aAdd(aLstInd,STR0055) //"07=Exclusivamente FGTS e/ou Contribui��o Social Rescis�ria (Lei Complementar 110/2001)"
	aAdd(aLstInd,STR0056) //"08=Contribui��o sindical"
	aAdd(aLstInd,STR0018) //"99=Outros assuntos"

	For nCont := 1 To Len(aLstInd)
		cLstInd += aLstInd[nCont]+";"
	Next

	cLstInd := Substr(cLstInd,1,Len(cLstInd)-1)

Return Iif(Upper(cRet)=="C",cLstInd,aLstInd)

//-------------------------------------------------------------------
/*/{Protheus.doc} J233IndAut
Lista do CBOX do campo O08_INDAUT

@since 12/06/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function J233LstAut()
Local aLstIndAut:= {}
Local cRet      :="C"
Local nCont     := 0
Local cLstIndAut:= ""

	aAdd(aLstIndAut,STR0057) //"1=Proprio contribuinte"
	aAdd(aLstIndAut,STR0058) //"2=Outra entidade, empresa ou empregado"

	For nCont := 1 To Len(aLstIndAut)
		cLstIndAut += aLstIndAut[nCont]+";"
	Next

	cLstIndAut := Substr(cLstIndAut,1,Len(cLstIndAut)-1)

Return Iif(Upper(cRet)=="C",cLstIndAut,aLstIndAut)

//-------------------------------------------------------------------
/*/{Protheus.doc} J233LstExi
Rotina que contem array com a lista de Indicativo de suspens�o da exigibilidade.

@author Reginaldo N Soares
@since 06/04/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J233LstExi()
Local aLstExi   := {}
Local cRet      :="C"
Local nCont     := 0
Local cLstExi   := ""

	aAdd(aLstExi,STR0019) //"01=Liminar em Mandado de Seguran�a"
	aAdd(aLstExi,STR0020) //"02=Dep�sito Judicial do Montante Integral"
	aAdd(aLstExi,STR0021) //"03=Dep�sito Administrativo do Montante Integral"
	aAdd(aLstExi,STR0022) //"04=Antecipa��o de Tutela"
	aAdd(aLstExi,STR0023) //"05=Liminar em Medida Cautelar"
	aAdd(aLstExi,STR0024) //"08=Senten�a em Mandado de Seguran�a Favor�vel ao Contribuinte"
	aAdd(aLstExi,STR0025) //"09=Senten�a em A��o Ordin�ria Favor�vel ao Contribuinte e Confirmada pelo TRF
	aAdd(aLstExi,STR0026) //"10=Ac�rd�o do TRF Favor�vel ao Contribuinte"
	aAdd(aLstExi,STR0027) //"11=Ac�rd�o do STJ em Recurso Especial Favor�vel ao Contribuinte"
	aAdd(aLstExi,STR0028) //"12=Ac�rd�o do STF em Recurso Extraordin�rio Favor�vel ao Contribuinte"
	aAdd(aLstExi,STR0029) //"13=Senten�a 1� inst�ncia n�o transitada em julgado com efeito suspensivo"
	aAdd(aLstExi,STR0030) //"14=Contesta��o Administrativa FAP"
	aAdd(aLstExi,STR0031) //"90=Decis�o Definitiva a favor do contribuinte"
	aAdd(aLstExi,STR0032) //"92=Sem suspens�o da exigibilidade"

	For nCont := 1 To Len(aLstExi)
		cLstExi += aLstExi[nCont]+";"
	Next

	cLstExi := Substr(cLstExi,1,Len(cLstExi)-1)

Return Iif(Upper(cRet)=="C",cLstExi,aLstExi)

//-------------------------------------------------------------------
/*/{Protheus.doc} J233LstTpo
Fun��o que informa os dados em que o campo Tipo do Processo ir� apresentar

@return aTpProc - Contem os tipo de processo que contempla no E-Social
		cTpProc - Concatena��o do Array aTpProc

@since   10/04/19
@version 1.0
/*/
//-------------------------------------------------------------------
Function J233LstTpo()
Local aTpProc   := {}
Local cRet      := "C"
Local nCont     := 0
Local cTpProc   := ""

	aAdd(aTpProc,STR0051) // 1=Administrativo
	aAdd(aTpProc,STR0052) // 2=Judicial
	aAdd(aTpProc,STR0053) // 3=N�mero de Benef�cio (NB) do INSS
	aAdd(aTpProc,STR0054) // 4=Processo FAP de exerc�cio anterior a 2019

	For nCont := 1 To Len(aTpProc)
		cTpProc += aTpProc[nCont]+";"
	Next

	cTpProc := Substr(cTpProc,1,Len(cTpProc)-1)

Return Iif(Upper(cRet)=="C",cTpProc,aTpProc)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA233TOK
Valida informa��es ao salvar

@param 	oModel  	Model a ser verificado
@Return lRet	 	.T./.F. As informa��es s�o v�lidas ou n�o
@author Reginaldo N Soares
@since 26/04/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA233TOK(oModel)
Local lRet        := .T.
Local nI          := 0
Local aErros      := {}
Local nOpc        := oModel:GetOperation()
Local dDtIniAnt   := SToD("  /  /    ")
Local dDtFimAnt   := SToD("  /  /    ")
Local cDtIni      := DToC(oModel:GetValue('O08MASTER','O08_INIVAL'))
Local cDtFim      := DToC(oModel:GetValue('O08MASTER','O08_FIMINS'))
Local cTpProc     := oModel:GetValue('O08MASTER','O08_TPPROC')
Local cIndAut     := oModel:GetValue('O08MASTER','O08_INDAUT')
Local cDtIniVal   := SubStr(cDtIni,7,4) + SubStr(cDtIni,4,2)
Local cDtFimVal   := SubStr(cDtFim,7,4) + SubStr(cDtFim,4,2)
Local lMiddleware := IIf( Findfunction("fVerMW"), fVerMW(), .F. )
Local lTafOutSist := SuperGetMV('MV_JTAFOUT',, .F.)

	If nOpc  == 3 .Or. nOpc  == 4

		If !Empty(cDtFimVal) .AND. (cDtFimVal < cDtIniVal)
			lRet := .F.
			JurMsgErro(STR0038) //"Data de Encerramento informada � menor que a data de inclus�o
		Endif

		If lRet .AND. cTpProc =='2'
			If Empty(cIndAut)
				lRet := .F.
				JurMsgErro(STR0034) //"Informar o valor do Indicativo da autoria da A��o Judicial
			EndIf
		Endif

		If nOpc == 4
			dDtIniAnt := O08->O08_INIVAL
			dDtFimAnt := O08->O08_FIMINS
		Endif

	Endif

	If lRet
		lRet := ValidRules(oModel)
	EndIf

	If lRet
		// Montagem do XML
		cXml   := JXmlEsocial(oModel,nOpc,dDtIniAnt,dDtFimAnt,lMiddleware)
		
		If lMiddleware
			lRet = VldMiddle(oModel,cXml,nOpc)
		Else
			If lTafOutSist
				aErros := JExpXmlTaf(cXml, oModel)
			Else
				// Envio do XML para o TAF - S-1070
				aErros := TAFPrepInt(cEmpAnt,cFilAnt, cXml ,, "1", "S1070" )
			EndIf

			// Tratamento de Erro
			If Len( aErros ) <= 0
				lRet := .T.
			Else
				For nI := 1 to Len(aErros)
					lRet := .F.
					JurMsgErro(aErros[nI])
				Next nI
			EndIf
		EndIf
	EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JExpXmlTaf(cXml, oModel)
Fun��o respons�vel por exportar o xml para uma pasta local do S.O. do
usu�rio.

@param cXml   - XML respons�vel por integrar com o TAF
@param oModel - Modelo da rotina do e-social do sigajuri

@since 10/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function JExpXmlTaf(cXml, oModel)
Local cNomeArq := ''
Local cPath    := '\spool\'
Local cExt     := '.xml'
Local cExtens  := 'Arquivo XML | *.xml'
Local cNumPro  := oModel:GetValue('O08MASTER','O08_CAJURI')
Local lHtml    := (GetRemoteType() == 5)
Local lLinux   := "Linux" $ GetSrvInfo()[2]
Local aErros   := {}
Local lWSTLegal := JModRst()

Default cXml   := ''
Default oModel := Nil

	//Se for o html, n�o precisa escolher o arquivo
	If !lHtml .And. !lWSTLegal
		cPath := cGetFile(cExtens, STR0083, , "C:\", .F., nOr(GETF_LOCALHARD,GETF_RETDIRECTORY), .T.) // STR0083 - "Selecione uma pasta para exportar o xml"
	EndIf

	If !Empty(cPath)
		
		cNomeArq := cEmpAnt + Alltrim(xFilial('O08')) + '_s-1070_' + cNumPro
		
		// Tratamento para S.O Linux
		If lLinux
			cNomeArq := StrTran(cNomeArq,"\","/")
			cPath    := StrTran(cPath,"\","/")
		Endif

		If File( cPath + cNomeArq + cExt )
			FErase( cPath + cNomeArq + cExt )
		EndIf

		nHandle := FCreate( cPath + cNomeArq + cExt )
		
		If nHandle > 0
			cXml := '<?xml version="1.0" encoding="utf-8"?> ' + cXml

			FWrite(nHandle, cXml)
			Fclose(nHandle)

			//Envia via download
			If lHtml .And.( CpyS2TW(cPath + cNomeArq + cExt, .T.) < 0 )
				aAdd(aErros, I18N(STR0084,{ cNomeArq + cExt })) // STR0084 - "N�o foi poss�vel efetuar o download do arquivo #1"
			EndIf
		Else
			aAdd(aErros, I18N(STR0085,{ cNomeArq + cExt })) // STR0085 - "Erro ao realizar a cria��o do arquivo #1"
		EndIf
	Else
		aAdd(aErros, STR0086) // STR0086 - "Opera��o cancelada!"
	EndIf

Return aErros

//-------------------------------------------------------------------
/*/{Protheus.doc} VldMiddle(oModel,cXml,nOperation)
Fun��o respons�vel por realizar valida��es e grava��o na
tabela RJE para entrar na fila de eventos do middleware.

@param oModel     - Modelo da rotina do e-social do sigajuri
@param cXml       - XML respons�vel por integrar com o Middleware
@param nOperation - opera��o que cadastro est� sem movimentado.

@since 04/11/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function VldMiddle(oModel,cXml,nOperation)
Local nRecRJE     := 0
Local nOpcao      := 0
Local aInfoC      := {}
Local aDados      := {}
Local cMsgErro    := ""
Local cTpInsc     := ""
Local cOpcRJE     := ""
Local cRetKey     := ""
Local cRetfRJE    := ""
Local lS1000      := .T.
Local lAdmPubl    := .F.
Local lNovoRJE    := .T.
Local lRet        := .T.
Local cOperNew    := "I"
Local cRetfNew    := "1"
Local cStatNew    := "1"
Local cNrInsc     := "0"
Local cStatMid    := "-1"
Local cStatus     := "-1"
Local cFilPro     := xFilial("O08")
Local nTamKey     := GetSx3Cache("RJE_KEY","X3_TAMANHO")
Local nTamInsc    := GetSx3Cache("RJE_INSCR","X3_TAMANHO")
Local cNumPro     := oModel:getValue("O08MASTER","O08_CAJURI")

Default nOperation := oModel:getOperation()
	
	// fVld1000 -- Fun��o respons�vel por validar se o evento S-1000 foi trasmitido (cStatus == 4).
	// ---------------------- Status (cStatus) ---------------------------
	// * 1 - N�o enviado - Gravar por cima do registro encontrado
	// * 2 - Enviado - Aguarda Retorno - Enviar mensagem em tela e n�o continuar com o processo
	// * 3 - Retorno com Erro - Gravar por cima do registro encontrado
	// * 4 - Retorno com Sucesso - Efetivar a grava��o
	
	lS1000 := fVld1000( AnoMes(dDataBase), @cStatus )
	
	If lS1000

		If !ChkFile("RJE") 
			lRet := .F.
			cMsgErro := STR0071 + CRLF //"Tabela RJE n�o encontrada. Verifique com o administrador do Sistema."
		EndIf
		
		If !ChkFile("RJ9")
			lRet := .F.
			cMsgErro += STR0073 //"Tabela RJ9 n�o encontrada. Verifique com o administrador do Sistema."
		EndIf
		
		If lRet
			aInfoC   := fXMLInfos() // Fun��o respons�vel por obter informa��es do cadastro de empregador.
			
			If Len(aInfoC) == 0
				lRet := .F.
				cMsgErro := STR0074 //"O cadastrado de empregador desta filial n�o foi encontrado."
			Else
				cTpInsc  := aInfoC[1]
				cNrInsc  := aInfoC[2]
				cRetKey  := aInfoC[3]
				lAdmPubl := aInfoC[4]
				
				If !lAdmPubl .And. cTpInsc == "1"
					cNrInsc := SubStr(cNrInsc, 1, 8)
				EndIf
						  // Index da Tabela RJE
						  // RJE_TPINSC + RJE_INSCR              +   RJE_EVENTO  + RJE_KEY                               + RJE_INI
				cChaveMid := cTpInsc    + PadR(cNrInsc,nTamInsc) +    "S1070"    + PadR(cFilPro + cNumPro, nTamKey, " ") + AnoMes(dDataBase)
				cStatMid  := "-1"
				
				// Fun��o respons�vel por validar a exist�ncia de registro deste processo e per�odo na fila do middleware.
				// Caso temos o registro gravado deste processo, conseguimos obter o status dele e o recno do registro para efetuar altera��o.
				GetInfRJE( 2, cChaveMid, @cStatMid, @cOpcRJE, @cRetfRJE, @nRecRJE )
				
				If nOperation == MODEL_OPERATION_UPDATE
					
					//Retorno pendente impede o cadastro
					If cStatMid == "2"
						lRet     := .F.
						cMsgErro := STR0075 //"Opera��o n�o ser� realizada pois o evento foi transmitido, mas o retorno est� pendente"
					EndIf
					
					//Evento de exclus�o sem transmiss�o impede o cadastro
					If lRet .And. cOpcRJE == "E" .And. cStatMid != "4"
						lRet     := .F.
						cMsgErro := STR0076 //"Opera��o n�o ser� realizada pois h� evento de exclus�o que n�o foi transmitido ou com retorno pendente"
						
					//N�o existe na fila, ser� tratado como inclus�o
					ElseIf cStatMid == "-1"
						nOpcao   := 3
						cOperNew := "I"
						cRetfNew := "1"
						cStatNew := "1"
						lNovoRJE := .T.
						
					//Evento sem transmiss�o, ir� sobrescrever o registro na fila
					ElseIf cStatMid $ "1/3"
						If cOpcRJE == "A"
							nOpcao := 4
						EndIf
				
						cOperNew := cOpcRJE
						cRetfNew := cRetfRJE
						cStatNew := "1"
						lNovoRJE := .F.
				
					//Evento diferente de exclus�o transmitido, ir� gerar uma retifica��o
					ElseIf cOpcRJE != "E" .And. cStatMid == "4"
						nOpcao   := 4
						cOperNew := "A"
						cRetfNew := "2"
						cStatNew := "1"
						lNovoRJE := .T.
				
					//Evento de exclus�o transmitido, ser� tratado como inclus�o
					ElseIf cOpcRJE == "E" .And. cStatMid == "4"
						nOpcao   := 3
						cOperNew := "I"
						cRetfNew := "1"
						cStatNew := "1"
						lNovoRJE := .T.
					EndIf
				
				ElseIf nOperation == MODEL_OPERATION_INSERT
					
					//Retorno pendente impede o cadastro
					If cStatMid == "2"
						lRet     := .F.
						cMsgErro := STR0075 //"Opera��o n�o ser� realizada pois o evento foi transmitido, mas o retorno est� pendente"
					
					//Evento de exclus�o sem transmiss�o impede o cadastro
					ElseIf cOpcRJE == "E" .And. cStatMid != "4"
						lRet     := .F.
						cMsgErro := STR0076 //"Opera��o n�o ser� realizada pois h� evento de exclus�o que n�o foi transmitido ou com retorno pendente"
					
					//Evento sem transmiss�o, ir� sobrescrever o registro na fila
					ElseIf cStatMid $ "1/3"
						nOpcao   := Iif( cOpcRJE == "I", 3, 4 )
						cOperNew := cOpcRJE
						cRetfNew := cRetfRJE
						cStatNew := "1"
						lNovoRJE := .F.
					
					//Evento diferente de exclus�o transmitido, ir� gerar uma retifica��o
					ElseIf cOpcRJE != "E" .And. cStatMid == "4"
						cOperNew := "A"
						cRetfNew := "2"
						cStatNew := "1"
						lNovoRJE := .T.
					
					//Ser� tratado como inclus�o
					Else
						cOperNew := "I"
						cRetfNew := "1"
						cStatNew := "1"
						lNovoRJE := .T.
					EndIf
				EndIf
		
				If lRet
					
					// Fun��o respons�vel por gravar o xml dentro de um diret�rio para que o middleware possa consumir.
					GrvTxtArq(cXml)
					
					aAdd( aDados, { xFilial("RJE", cFilAnt), xFilial("NSZ", cFilAnt), cTpInsc, PadR(cNrInsc,nTamInsc), "S1070", AnoMes(dDataBase),;
									PadR(cFilPro + cNumPro, nTamKey, " "), cRetKey, cRetfNew, "12", cStatNew, Date(), Time(), cOperNew } )
					
					/* ---------- aDados ----------
					*  aDados[1]  := Filial da RJE
					*  aDados[2]  := Filial do processo da NSZ
					*  aDados[3]  := Tipo de Inscri��o (RJ9_TPINSC) que vem do cadastro do empregador.
					*  aDados[4]  := N�mero da Inscri��o (RJ9_NRINSC) que vem do cadastro do empregador.
					*  aDados[5]  := Nome do Evento
					*  aDados[6]  := Per�odo do lan�amento - Ano/M�s
					*  aDados[7]  := Filial do processo + n�mero do processo(NSZ_COD)
					*  aDados[8]  := Chave Key da RJE == "ID" + Tipo de Inscri��o + N�mero da Incri��o + PadR(N�mero da Inscri��o,14,0)
					*                                     + Data Atual + hor�rio + sequ�ncia
					*  aDados[9]  := Status do Retificador
					*  aDados[10] := Vers�o
					*  aDados[11] := Status do Evento
					*  aDados[12] := Data Atual
					*  aDados[13] := Hor�rio Atual
					*  aDados[14] := Opera��o  
					*/
					
					//Se n�o for uma exclus�o de registro n�o transmitido, cria/atualiza registro na fila
					If cStatMid $ "-1/1/3" .OR. !(cOpcRJE == "E" .And. cStatMid == "4")
						If !( fGravaRJE( aDados, cXml, lNovoRJE, nRecRJE ) )
						 	lRet := .F.
							cMsgErro := STR0077 //"Ocorreu um erro na grava��o do registro na tabela RJE"
						EndIf
					
					//Se for uma exclus�o e n�o for de registro de exclus�o transmitido, exclui registro de exclus�o na fila
					ElseIf cStatMid != "-1" .And. !(cOpcRJE == "E" .And. cStatMid == "4")
						If !( fExcluiRJE( nRecRJE ) )
							lRet := .F.
							cMsgErro := STR0082 //"Ocorreu um erro na exclus�o do registro na tabela RJE"
						EndIf
					EndIf
				Endif
			EndIf
		EndIf
	Else
		lRet := .F.
		Do Case 
			Case cStatus == "-1" // nao encontrado na base de dados
				cMsgErro := STR0078 //"Registro do evento S-1000 n�o localizado na base de dados"
			Case cStatus == "1" // nao enviado para o governo
				cMsgErro := STR0079 //"Registro do evento S-1000 n�o transmitido para o governo"
			Case cStatus == "2" // enviado e aguardando retorno do governo
				cMsgErro := STR0080 //"Registro do evento S-1000 aguardando retorno do governo"
			Case cStatus == "3" // enviado e retornado com erro 
				cMsgErro := STR0081 //"Registro do evento S-1000 retornado com erro do governo"
		EndCase
	EndIf
	
	If !lRet
		JurMsgErro(cMsgErro,, STR0068)
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J233IndDep
Rotina para verifica��o do valor informado do Indicativo de Dep�sito do Montante Integral (O08_INDEP) se satisfaz as condi��es estabelecidas. (1=Sim;2=N�o)

@param cInDep - Indicativo de dep�sito judicial
@param cIndSus - Indicativo de Suspens�o
@param cIndAud - Indicativo de a��o judicial

@author Reginaldo N Soares
@since 06/04/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J233IndDep(cInDep,cIndSus,cIndAud)
	Local lRet := .T.
	// -- -- -- Aten��o!! !! !!
	// Mantido por quest�es de Compatibilidade com Clientes que n�o atualizam o dicion�rio
	//---------
	ParamType 0 Var cInDep  As Character optional Default ""
	ParamType 1 Var cIndSus As Character optional Default ""
	ParamType 2 Var cIndAud As Character optional Default ""

	lRet := J233ValIDE(cInDep)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JXmlEsocial
Fun��o que monta o XML para a integra��o com o TAF
	- A parte de ideEvento � feita pelo TAF

@param oModel - Modelo da JURA233
@param nOpc - Opera��o a ser executada
@param dDtIniAnt - Data Inicial Anterior
@param dDtFimAnt - Data de Encerramento Anterior

@return oXml - Retorna o XMl

@author Beatriz Gomes
@since 28/05/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function JXmlEsocial(oModel, nOpc,dDtIniAnt,dDtFimAnt,lMiddleware)

Local cXml      := ""
Local cXmlITag  := ""
Local cXmlFTag  := ""
Local cXmlP     := ""
Local cXmlFim   := ""
Local cXmlIni   := ""
Local cXmlAlt   := ""
Local cAMIniAnt := ""
Local cAMFimAnt := ""
Local cTpInsc   := ""
Local cNrInsc   := ""
Local cId       := ""
Local cVsEnvio  := ""
Local cNumPro   := ""
Local aInfoC    := {}
Local lAdmPubl  := .F.
Local lNT15     := .F.
Local cAMIniAtu := JAnoMes(oModel:GetValue('O08MASTER','O08_INIVAL'))
Local cAMFimAtu := JAnoMes(oModel:GetValue('O08MASTER','O08_FIMINS'))
Local cDtDeci   := DtoS(oModel:GetValue('O08MASTER','O08_DTDECI'))
Local cIndMat   := oModel:GetValue('O08MASTER','O08_INDMAT')
Local cTpProc   := oModel:GetValue('O08MASTER','O08_TPPROC')
Local cIndDep   := oModel:GetValue('O08MASTER','O08_INDEP')
Local cUfVara   := Alltrim(oModel:GetValue('O08MASTER','O08_UFVARA'))
Local cCodMun   := Alltrim(oModel:GetValue('O08MASTER','O08_CODMUN'))
Local cIdVara   := Alltrim(oModel:GetValue('O08MASTER','O08_IDVARA'))

Default nOpc        := 3
Default dDtIniAnt   := SToD("  /  /    ")
Default dDtFimAnt   := SToD("  /  /    ")
Default lMiddleware := .F.

	// Define o Anomes das Datas Anteriores
	cAMIniAnt   := JAnoMes(dDtIniAnt)//data anterior(caso Altera��o)
	cAMFimAnt   := JAnoMes(dDtFimAnt)//data anterior(caso Altera��o)
	
	If lMiddleware
		aInfoC   := fXMLInfos()
		
		If Len(aInfoC) >= 4
			cTpInsc  := aInfoC[1]
			lAdmPubl := aInfoC[4]
			cNrInsc  := aInfoC[2]
			cId      := aInfoC[3]
		EndIf
		
		// Fun��o respons�vel por obter a vers�o do evento S-1070
		fVersEsoc( "S1070", .T., /*aRetGPE*/, /*aRetTAF*/, , , @cVsEnvio, @lNT15 )
		
		cXmlITag := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtTabProcesso/v" + cVsEnvio + "'>"
		cXmlITag += "<evtTabProcessoId='" + cId + "'>"
		fXMLIdEve( @cXmlITag, { Nil, Nil, Nil, Nil, 1, 1, "12" } )
		fXMLIdEmp( @cXmlITag, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )
	Else
		cXmlITag := '<eSocial>'
		cXmlITag += '<evtTabProcesso>'
	EndIf
	
	cXmlITag += '<infoProcesso>'

	If nOpc == 3
		cXmlIni := '<inclusao>'
		cXmlFim := '</inclusao>'
	ElseIf nOpc == 4
		cXmlIni := '<alteracao>'
		cXmlFim := '</alteracao>'
	ElseIf nOpc == 5
		cXmlIni := '<exclusao>'
		cXmlFim := '</exclusao>'
	Endif

	cNumPro := AllTrim( oModel:GetValue('O08MASTER','O08_NUMPRO') )
	cNumPro := StrTran(cNumPro, "-", "")
	cNumPro := StrTran(cNumPro, ".", "")

	// Verifica se houve altera��o nas datas para transmitir a data anterior e a nova
	If nOpc == 4 .And. (cAMIniAtu <> cAMIniAnt .Or. cAMFimAtu <> cAMFimAnt)
		cXmlP := '<ideProcesso>'
		cXmlP +=   '<tpProc>'+ cTpProc +'</tpProc>'
		cXmlP +=   '<nrProc>'+ cNumPro + '</nrProc>'
		cXmlP +=   '<iniValid>'+ cAMIniAnt +'</iniValid>'
		cXmlP +=   '<fimValid>'+ cAMFimAnt +'</fimValid>'
		cXmlP += '</ideProcesso>'

		cXmlAlt := '<novaValidade>'
		cXmlAlt +=   '<iniValid>'+ cAMIniAtu +'</iniValid>'
		cXmlAlt +=   '<fimValid>'+ cAMFimAtu +'</fimValid>'
		cXmlAlt += '</novaValidade>'
	Else
		cXmlP := '<ideProcesso>'
		cXmlP +=   '<tpProc>'+ cTpProc +'</tpProc>'
		cXmlP +=   '<nrProc>'+ cNumPro + '</nrProc>'
		cXmlP +=   '<iniValid>'+ cAMIniAtu +'</iniValid>'
		cXmlP +=   '<fimValid>'+ cAMFimAtu +'</fimValid>'
		cXmlP += '</ideProcesso>'
	EndIf

	If nOpc == 3 .Or. nOpc == 4
		cXmlDP := '<dadosProc>'
		cXmlDP +=   '<indAutoria>'+ oModel:GetValue('O08MASTER','O08_INDAUT') +'</indAutoria>'
		cXmlDP +=   '<indMatProc>'+ IIF(cIndMat != '99',SubStr(cIndMat,2,1),cIndMat)+'</indMatProc>'

		If cTpProc == '2' .Or. (cTpProc <> '2' .AND. !Empty(cUfVara) .AND. !Empty(cCodMun) .AND. !Empty(cIdVara) )
			cXmlDP += '<dadosProcJud>'
			cXmlDP +=   '<ufVara>' + cUfVara + '</ufVara>'
			cXmlDP +=   '<codMunic>'+ cCodMun +'</codMunic>'
			cXmlDP +=   '<idVara>'+ cIdVara +'</idVara>'
			cXmlDP += '</dadosProcJud>'
		EndIf

		If !Empty(cIndDep)
			cIndDep := Iif(cIndDep == '1', 'S', 'N')
		EndIf

		cXmlDP +=   '<infoSusp>'
		cXmlDP +=     '<codSusp>'+ oModel:GetValue('O08MASTER','O08_CODSUS') +'</codSusp>'
		cXmlDP +=     '<indSusp>'+ oModel:GetValue('O08MASTER','O08_INDSUS')+'</indSusp>'
		cXmlDP +=     '<dtDecisao>'+ IIF(!Empty(cDtDeci),cDtDeci,'') +'</dtDecisao>'
		cXmlDP +=     '<indDeposito>'+ cIndDep +'</indDeposito>'
		cXmlDP +=   '</infoSusp>'
		cXmlDP += '</dadosProc>'
	EndIf

	cXmlFTag := '</infoProcesso>'
	cXmlFTag += '</evtTabProcesso>'
	cXmlFTag += '</eSocial>'

	cXml := cXmlITag + cXmlIni + cXmlP + cXmlDP + cXmlAlt + cXmlFim + cXmlFTag

return cXml

//-------------------------------------------------------------------
/*/{Protheus.doc} J233SetMas
Seta a mascara de numero de processo utilizado pela inst�ncia

@param	 cMascara   - Mascara do processo utilizada na inst�ncia
@return  cMasNumPro - Mascara que dever� ser aplicada no campo de numero do processo
@author  Rafael Tenorio
@since   24/10/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J233SetMas(cMascara)

	Default cMascara := ""

	If !Empty(cMascara)
		cMasNumPro := cMascara
	EndIf

Return cMasNumPro


//-------------------------------------------------------------------
/*/{Protheus.doc} J233ValIMP
Valida��o do Indicativo da Mat�ria do Processo

@param cValor  - Valor atual
@param lTudoOk - Verifica se est� sendo usado pelo TudoOk
@param cMsg    - Mensagem de Erro

@since 12/06/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function J233ValInd(cValor, lTudoOk,cMsg)
Local lRet    := .T.
Local oModel  := FWModelActive()
Local cTpProc := ""

Default cValor  := ""
Default lTudoOk := .F.
Default cMsg    := ""

	If oModel <> Nil .And. oModel:GetId() == "JURA233"
		If cValor == ""
			cValor  :=  oModel:GetValue('O08MASTER','O08_INDMAT')
		EndIf
		cTpProc := oModel:GetValue('O08MASTER','O08_TPPROC')
	EndIf

	If !Empty(cValor) .and. Pertence("01|02|03|04|05|06|07|08|99",cValor)
		If lTudoOk
			If !Empty(cTpProc)
				If cTpProc == "3" .AND. !(cValor $ "06")// Se {tpProc} = [3], deve ser preenchido com [6].
					cMsg := I18n(STR0067,;                       //"Se Tipo do Processo igual a '#1', o Indicativo da Mat�ria do Processo deve ser preenchido com '#2'"
					                {StrTran(STR0053,"=","-"),;  //"3=N�mero de Benef�cio (NB) do INSS"
					                 StrTran(STR0017,"=","-")})  //"06=Convers�o de Licen�a Sa�de em Acidente de Trabalho"
					lRet := .F.
				EndIf
			EndIf
		EndIf
	Else
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J233ValTpo
Fun��o respons�vel por validar o Tipo do Processo.

@param cValor  - Valor atual
@param cMsg    - Mensagem de Erro

@return lRet

@since   10/04/19
@version 1.0
/*/
//-------------------------------------------------------------------
Function J233ValTpo(cValor, cMsg)
Local lRet      := .F.
Local oModel  := FWModelActive()

Default cValor := ""
Default cMsg   := ""

	If oModel <> Nil .And. oModel:GetId() == "JURA233"
		If cValor == ""
			cValor  :=  oModel:GetValue('O08MASTER','O08_TPPROC')
		EndIf
	EndIf

	If !Empty(cValor) .And. Pertence("|1|2|3|4|",cValor)
		lRet := .T.
	Else
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J233ValExi(cValor)
Valida��o do Indicativo de suspens�o da exigibilidade:

@param cValor  - Valor atual
@param lTudoOk - Verifica se est� sendo usado pelo TudoOk
@param cMsg    - Mensagem de Erro

@since 13/06/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function J233ValExi(cValor, lTudoOk, cMsg)
Local lRet     := .T.
Local oModel   := FWModelActive()
Local cTpProc  := ""
Local cDescric := STR0070 //"Indicativo de Suspens�o da Exigibilidade"
Local cInfSus  := ""

Default cValor  := ""
Default lTudoOk := .F.
Default cMsg    := ""

	If oModel <> Nil .And. oModel:GetId() == "JURA233"
		If cValor == ""
			cValor  :=  oModel:GetValue('O08MASTER','O08_INDSUS')
		EndIf
		cTpProc := oModel:GetValue('O08MASTER','O08_TPPROC')
		cInfSus := oModel:GetValue('O08MASTER','O08_INFSUS')
	EndIf

	If cInfSus == "1"
		If !Empty(cValor) .And. Pertence("|01|02|03|04|05|08|09|10|11|12|13|14|90|92|",cValor)
			If lTudoOk
				If !Empty(cTpProc)
					If cTpProc == "1" .AND. !(cValor $ "03|14|92") //Se {tpProc} = [1], deve ser preenchido com [03, 14, 92].

						cMsg := I18n(STR0062,;                        //"Se Tipo do Processo igual a '#1', o #2 deve ser preenchido com '#3','#4' ou '#5'"
						                {StrTran(STR0051,"=","-"),;   //"1=Administrativo"
						                 cDescric,;
						                 StrTran(STR0021,"=","-"),;   //"03=Dep�sito Administrativo do Montante Integral"
						                 StrTran(STR0030,"=","-"),;   //"14=Contesta��o Administrativa FAP"
						                 StrTran(STR0032,"=","-")})   //"92=Sem suspens�o da exigibilidade"
						lRet := .F.
					ElseIf cTpProc == "2" .And. !(cValor $ "|01|02|04|05|08|09|10|11|12|13|90|92|") //Se {tpProc} = [2], deve ser preenchido com [01, 02, 04, 05, 08, 09, 10, 11, 12, 13, 90, 92].

						cMsg := I18n(STR0065,;                            //"Se Tipo do Processo igual a '#1', o #2 n�o pode ser preenchido com '#3' ou '#4'"
						                {StrTran(STR0052,"=","-"),;       //"2=Judicial"
						                 cDescric,;
						                 StrTran(STR0021,"=","-"),;       //"03=Dep�sito Administrativo do Montante Integral"
						                 StrTran(STR0030,"=","-")})       //"14=Contesta��o Administrativa FAP"
						lRet := .F.
					ElseIf cTpProc == "4" .And. !(cValor $ "|14|") //Se {tpProc} = [4], deve ser preenchido com [14].

						cMsg := I18n(STR0066,;                            //"Se Tipo do Processo igual a '#1', o #2 deve ser preenchido com '#3'"
						                {StrTran(STR0054,"=","-"),;       //"4=Processo FAP de exerc�cio anterior a 2019"
						                 cDescric,;
						                 StrTran(STR0030,"=","-")})       //"14=Contesta��o Administrativa FAP"
						lRet := .F.
					EndIf
				EndIf
			EndIf
		Else
			lRet := .F.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J233ValIDE(cValor)
Valida��o do campo de Indicativo de Dep�sito do Montante Integral

@param cValor  - Valor atual
@param lTudoOk - Verifica se est� sendo usado pelo TudoOk
@param cMsg    - Mensagem de Erro

@since 13/06/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function J233ValIDE(cValor, lTudoOk, cMsg)
Local lRet     := .T.
Local oModel   := FWModelActive()
Local cTpProc  := ""
Local cInfSus  := "2"
Local cIndSus  := ""
Local cDescric := STR0069 //"Indicativo de Dep�sito do Montante Integral"
Local cIndSusp := STR0070 //"Indicativo de Suspens�o da Exigibilidade"

Default cValor  := ""
Default lTudoOk := .F.
Default cMsg    := ""

	If oModel <> Nil .And. oModel:GetId() == "JURA233"
		If cValor == ""
			cValor  :=  oModel:GetValue('O08MASTER','O08_INDEP')
		EndIf
		cTpProc := oModel:GetValue('O08MASTER','O08_TPPROC')
		cInfSus := oModel:GetValue('O08MASTER','O08_INFSUS')
		cIndSus := oModel:GetValue('O08MASTER','O08_INDSUS')
	EndIf

	// Verifica se a chamada � pelo TudoOk
	If lTudoOk
		If cInfSus == "1"
			If cIndSus == "90" .And. cValor != "2" //Se {indSusp} = [90], preencher obrigatoriamente com [N].
				cMsg := I18n(STR0063,;                       //"Se #1 igual a '#2', o #3 deve ser preenchido com '2 - N�o'"
				                {cIndSusp,;
				                 StrTran(STR0031,"=","-"),;  //"90=Decis�o Definitiva a favor do contribuinte"
				                 cDescric})

				lRet := .F.
			ElseIf cIndSus $ "|02|03|" .And. cValor != "1" //Se {indSusp} = [02, 03] preencher obrigatoriamente com [S].
				cMsg := I18n(STR0064,;                       // "Se #1 igual a '#2' ou '#3', o #4 deve ser preenchido com '1 - Sim'"
				                {cIndSusp,;
				                 StrTran(STR0020,"=","-"),;  //"02=Dep�sito Judicial do Montante Integral"
				                 StrTran(STR0021,"=","-"),;  //"03=Dep�sito Administrativo do Montante Integral"
				                 cDescric})
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JAnoMes
Monta data no formato Ano Mes

@return cRet - Data no formato AAAA-MM

@since   12/06/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JAnoMes(dData)
Local cRet  := ""
Local cData := JSToFormat(dData, "dd/mm/yyyy")

	If cData <> "00/00/0000"
		cRet := SubStr(cData,7,4) + '-'+ SubStr(cData,4,2) // Transforma em AAAA-MM
	EndIf

Return cRet

//------------------- ------------------------------------------------
/*/{Protheus.doc} JBreakLine(oStruct, cCampo)
Quebra as linhas da Estrutura

@return oStruct - Estrutura com a Quebra de linha

@since   13/06/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JBreakLine(oStruct, cCampo)
	If oStruct:HasField(cCampo)
		oStruct:SetProperty(cCampo,MVC_VIEW_INSERTLINE,.T.)
	Endif
Return oStruct

//------------------- ------------------------------------------------
/*/{Protheus.doc} ValidRules(oModel)
M�todo que concentra as valida��es do E-Social

@param oModel - Modelo Atual

@return lRet - Se deu tudo certo ou n�o

@since   14/06/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidRules(oModel)
Local lRet    := .T.
Local cMsg    := ""
Local cIndMat := oModel:GetValue("O08MASTER", "O08_INDMAT" )
Local cIndSus := oModel:GetValue("O08MASTER", "O08_INDSUS" )
Local cIndep  := oModel:GetValue("O08MASTER", "O08_INDEP" )

	// Valida��o da Mat�ria
	lRet := J233ValInd(cIndMat, .T., @cMsg)

	If lRet
		// Valida��o do C�digo de Suspens�o
		lRet := J233ValExi(cIndSus, .T., @cMsg)
	EndIf

	If lRet
		// Valida��o do Dep�sito
		lRet := J233ValIDE(cIndep, .T., @cMsg)
	EndIf

	If !lRet
		JurMsgErro(cMsg, STR0068)
	EndIf
Return lRet





