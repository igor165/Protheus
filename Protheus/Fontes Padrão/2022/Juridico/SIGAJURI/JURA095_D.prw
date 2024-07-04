#INCLUDE "JURA095_D.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE 'FWBROWSE.CH'
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA095_D
Functions utilizadas no dicionario de dados de processos

@author Wellington Coelho
@since 26/11/14
@version 1.0
/*/
//-------------------------------------------------------------------

Function JURA095_D()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef Functions utilizadas no dicionario de dados de processos

@author Wellington Coelho
@since 26/11/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Functions utilizadas no dicionario de dados de processos

@author Wellington Coelho
@since 26/11/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Functions utilizadas no dicionario de dados de processos

@author Wellington Coelho
@since 26/11/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J095VLDNUQ
Validação dos campo de Grupo, Cliente para unidade
Verifica se o Cliente, Loja, pertence ao grupo selecionado

@Return lRet	.T./.F. As informações são válidas ou não
@sample
@author Rodrigo Guerato
@since 31/07/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function J095VLDNUQ()
Local oM     := FWModelActive()
Local lRet   := .T.
Local cGrupo := ''

if !Empty(oM:GetValue('NSZMASTER','NSZ_CGRCLI'))

  cGrupo := JurGetDados('SA1', 1, xFilial('SA1') + oM:GetValue('NUQDETAIL','NUQ_CCLIEN') + oM:GetValue('NUQDETAIL','NUQ_LCLIEN'), 'A1_GRPVEN')
  if cGrupo <> oM:GetValue('NSZMASTER','NSZ_CGRCLI')
	  JurMsgErro(STR0001)
	  lRet := .F.
	  Return lRet
  Endif

Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR95CGCUN
Verifica se o envolvido é pessoa física ou jurídica para inclusão de máscara
no campo de CNPJ/CPF
Uso no cadastro de Envolvidos

@Return cRet	 		Máscara para o campo de CNPJ/CPF

@author Juliana Iwayama Velho
@since 13/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR95CGCUN()
Local cRet := ''

cRet:= JURM1(FWFldGet('NYJ_TIPOP'))

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J95CdPrOr
Funcao para gerar o número do inicializ. padrão do campo NSZ_CPRORI.

@author Rafael Rezende Costa
@since 03/01/2014
@version 1.0s
/*/
//-------------------------------------------------------------------
Function J95CdPrOr()
Local cNumPro := ''
Local oModel	:= FwModelActive()
Local nOpc

	If oModel <> NIL
		nOpc := oModel:GetOperation() // : 3 – Inclusão / 4 – Alteração / 5 - Exclusão

		If nOpc == 4
			cNumPro := NSZ->NSZ_COD
		ElseIf nOpc == 3
			If (IsInCallStack('lIncdtTOK') .AND. IsInCallStack('JA095INC'))	// Inclusão de Incidente
				cNumPro := cAssJur
			Else
				cNumPro := ''
			EndIf
		Else
			cNumPro := ''
		EndIf
	Else
		cNumPro := ''
	EndIf

Return cNumPro

//-------------------------------------------------------------------
/*/{Protheus.doc} JA95VA2NSZ
Função utilizada para validar o correspondente preenchido no campo
NSZ_CCORRE ou NUQ_CCORRE

@Return lRet	 	Retorna se o corresp está dentro da restrição ou não.

@author André Spirigoni Pinto

@since 27/08/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA95VA2NSZ(cCodSa2)
Local lRet     := .F.
Local nI
Local aArea    := GetArea()
Local aRestr   := {}
Local cGrpRest := JurGrpRest()

If 'CORRESPONDENTES' $ cGrpRest
	aRestr:= JA162RstUs()

	If Len(aRestr) > 0
		For nI := 1 to LEN(aRestr)
			If (aRestr[nI][2] == cCodSa2)
				lRet := .T.
				Exit
			Endif
		Next
	Else
		lRet := .T.
	EndIf
Else
	//se não for do grupo correspondentes, retorna .T.
	lRet := .T.
EndIf

If !lRet
	// "Correspondente Inválido para este Assunto Jurídico"
	// "Verifique as restrições de área de atuação, comarca e área jurídica que foram configuradas para o cadastro do correspondente selecionado."
	JurMsgErro(STR0010,,STR0011)
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA95NQ1
Filtra consulta padrão de natureza conforme o processo é principal ou desdobramento
Uso no cadastro de Instância.

@Return lRet	 	.T./.F. As informações são válidas ou não
@sample

@author Juliana Iwayama Velho
@since 28/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA95NQ1()
Local cRet := "@#@#"

	If !IsPesquisa()
		If EMPTY(FwFldGet('NSZ_CPRORI'))
			cRet := "@#NQ1->NQ1_ORIGEM == '1'@#"
		Else
			cRet := "@#NQ1->NQ1_ORIGEM == '2'@#"
		EndIf
	EndIf

return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095NSWOK
Valida se o campo de subclasse está vinculado ao classe
@Return lRet	 	.T./.F. As informações são válidas ou não
@sample
@author Juliana Iwayama Velho
@since 23/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095NSWOK()
Local lRet     := .F.
Local aArea    := GetArea()
Local aAreaNSW := NSW->( GetArea() )
Local oModel   := FWModelActive()
Local cClasse  := oModel:GetValue("NSZMASTER","NSZ_CCLASS")
Local cSubClas := oModel:GetValue("NSZMASTER","NSZ_CSUBCL")

If !Empty(cSubClas)

	NSW->( dbSetOrder( 1 ) )
	NSW->( dbSeek( xFilial( 'NSW' ) + cSubClas ) )

	While !NSW->( EOF() ) .AND. xFilial( 'NSW' ) + cSubClas == NSW->NSW_FILIAL + NSW->NSW_COD
		If cClasse == NSW->NSW_CCLASS
			lRet := .T.
		Endif
		NSW->( dbSkip() )
	End

	If !lRet
		JurMsgErro(STR0002+RetTitle("NSZ_CSUBCL"))
		lRet := .F.
	EndIf

EndIf

RestArea( aAreaNSW )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095DTENT()
Valida Data de Entrada(NSZ_DTENTR)

@Return lRet
@author Tiago Martins
@since 27/12/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095DTENT()
Local lRet:= .T.

	If lRet:= FwFldGet('NSZ_DTENTR') > DATE()
	     JurMsgErro(STR0003) //"Data não pode ser futura"
	EndIf

Return !lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095DTDIS
Função que valida a data de distribuição do prcesso para que não
seja futura.
@return lRet
@author Clóvis Eduardo Teixeira
@since 06/08/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095DTDIS()
Local lRet   := .T.
Local oModel := FWModelActive()
Local cDtIni := oModel:GetValue("NUQDETAIL","NUQ_DTDIST")
Local cDtTdy := Date()

if cDtIni > cDtTdy .And. !Empty(cDtIni)
  lRet := .F.
  JurMsgErro(STR0004)  //"A data de distribuição do processo não pode ser superior a data de hoje"
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095VSA2
Validação o correspondente conforme a disponibilidade do módulo
Jurídico
Uso no cadastro de Instância.

@Return lRet	 	.T./.F. As informações são válidas ou não

@param  cCorresp	Código do correspondente
@param  cLoja		Loja do correspondente

@author Juliana Iwayama Velho
@since 06/05/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095VSA2(cCorresp, cLoja)
Local lRet       := .T.
Local oModel     := FWModelActive()
Local oModelNUQ  := oModel:GetModel('NUQDETAIL')
Default cCorresp := oModelNUQ:GetValue('NUQ_CCORRE')
Default cLoja    := oModelNUQ:GetValue('NUQ_LCORRE')

If JurGetDados('SA2', 1 , xFilial('SA2') + cCorresp + cLoja , 'A2_MJURIDI') <> '1' .Or.;
   JurGetDados('SA2', 1 , xFilial('SA2') + cCorresp + cLoja , 'A2_MSBLQL') <> '2'
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095Cas(oModel)
Função que valida o numero do caso de acordo com o parametro MV_JCASO1
Uso no cadastro de Processos.
@param  cCliente Código do Cliente
@param  cLoja    Código da Loja
@param  cCaso    Código do Caso
@return lRet
@author Clóvis Eduardo Teixeira
@since 24/02/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095Cas(cCliente, cLoja, cNumCaso)
Local lRet      := .T.

if SuperGetMV("MV_JCASO1",, "1") == "1"
  lRet := ExistCpo('NVE',cCliente + cLoja + cNumCaso,1)
  If lRet
  	If JurGetDados('NVE',1,xFilial('NVE')+cCliente+ cLoja + cNumCaso ,'NVE_SITUAC') == '2' .And. !IsInCallStack("JURA101")
  		lRet := .F.
  		lRet := .F.
  	EndIf
  EndIf
Else
	If !Empty(cNumCaso)
		lRet := ExistCpo('NVE',cNumCaso,3)
    EndIf
  if !IsInCallStack("JURA101")
	  lRet := JAEXECPLAN("NSZMASTER", 'NSZ_CGRCLI', 'NSZ_CCLIEN', 'NSZ_LCLIEN', 'NSZ_NUMCAS', 'NSZ_NUMCAS')
  Endif

  If lRet
  	If JurGetDados('NVE',3,xFilial('NVE')+cNumCaso ,'NVE_SITUAC') == '2' .And. !IsInCallStack("JURA101")
  		lRet := .F.
  	EndIf
  EndIf
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095NSW
Filtra consulta padrão de subclasse por classe
@Return cRet	 	Comando para filtro
@#JA055NSW()
@author Juliana Iwayama Velho
@since 23/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095NSW()
Local lRet := .F.
	If IsPesquisa()
		lRet := (NSW->NSW_CCLASS == M->NSZ_CCLASS)
	ElseIf !Empty(FwFldGet('NSZ_CCLASS'))
		lRet := (NSW->NSW_CCLASS == FwFldGet('NSZ_CCLASS'))
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095GRCLI
Filtra a consulta de grupo de clientes conforme grupo ou restrição
Uso no cadastro de Processo.

@Return lRet	.T./.F. As informações são válidas ou não
@sample
@author Jorge Luis Branco Martins Junior
@since 15/10/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095GRCLI()
Local aArea   	:= GetArea()
Local aAreaSA1	:= SA1->(GetArea())
Local aAreaACY	:= ACY->(GetArea())
Local lRet    	:= .F.
Local aSearch 	:= {{'ACY_GRPVEN',1},{'ACY_DESCRI',3}}
Local aCampos 	:= {'ACY_GRPVEN','ACY_DESCRI'}
Local aFiltro 	:= {}
Local aRestr  	:= {}
Local cRetFim 	:= ""
Local cRet    	:= ""
Local nPos    	:= 0
Local nI      	:= 0
Local cSQL		:= ""
Local aTemp 	:= {}
Local cTmp      := ""
Local aFields	:= {}
Local aOrder  	:= {}
Local aFldsFilt := {}
Local cCond		:= ""
Local lCond		:= .T.
Local nFlxCorres:= SuperGetMV("MV_JFLXCOR", , 1)	//Fluxo de correspondente por Follow-up ou Assunto Jurídico? (1=Follow-up ; 2=Assunto Jurídico)"
Local cGrpRest  := JurGrpRest()
Local nResult   := 0
Local oTabTmp   := Nil
Local aStruAdic := {}
Local cCodUser  := __CUSERID
Local cAreaTmp  := ""
	
	If IsPesquisa()
	
		aRestr:= JA162RstUs()
	
		If !Empty(aRestr)
			If ('CLIENTES' $ cGrpRest)
				DbSelectArea("NWO")
				NWO->(DbSetOrder(2))
				NWO->(DbGoTop())
				
				For nI := 1 to LEN(aRestr)
					If NWO->(DbSeek(xFilial("NWO")+aRestr[nI][2]+aRestr[nI][3]))
						DbSelectArea("SA1")
						SA1->(DbSetOrder(1))
						If SA1->(DbSeek(xFilial("SA1")+NWO->NWO_CCLIEN+NWO->NWO_CLOJA ))
							If !Empty(AllTrim(SA1->A1_GRPVEN)) .And. lCond
					    	cCond += " NWO.NWO_CCONF = '" + aRestr[1][1] + "' AND "
					    	lCond := .F.
							EndIf
						EndIf
					EndIf
				Next
			EndIf
			
			If Empty(Alltrim(cCond))
				cCond += " NWO.NWO_CCONF = '0' AND "
			EndIf
	
			cSQL := "	SELECT ACY.ACY_GRPVEN, ACY.ACY_DESCRI, ACY.R_E_C_N_O_ RECNOLAN "
			cSQL += 	" FROM " + RetSqlName("ACY") + " ACY "
	
			//Restricao grupo de correspondentes
			If 'CORRESPONDENTES' $ cGrpRest .And. Type("INCLUI") <> "U" .And. !INCLUI  //Verifica funcao inclui no model //Se nao for inclusao efetuar restricao
	
				cSQL += " INNER JOIN " + RetSqlName("SA1") + " SA1 ON (SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND "
				cSQL += 	" SA1.A1_GRPVEN = ACY.ACY_GRPVEN AND "
				cSQL +=   " SA1.D_E_L_E_T_ = ' ') "
	
				cSQL += " INNER JOIN " + RetSqlName("NSZ") + " NSZ ON (NSZ.NSZ_FILIAL = '"+xFilial("NSZ")+"' AND "
				cSQL += 	" NSZ.NSZ_CCLIEN = SA1.A1_COD AND "
				cSQL +=   " NSZ.NSZ_LCLIEN = SA1.A1_LOJA AND "
				cSQL +=   " NSZ.NSZ_CGRCLI = SA1.A1_GRPVEN AND "
				cSQL += 	" NSZ.NSZ_TIPOAS IN (" + JurSetTAS(.F.) + ") AND"
				cSQL +=   " NSZ.D_E_L_E_T_ = ' ') "
	
				//Fluxo de correspondente por Assunto Jurídico
	   			If nFlxCorres == 2
	
					cSQL += " LEFT JOIN " + RetSqlName("NUQ") + " NUQ ON (NUQ.NUQ_FILIAL = '"+xFilial("NUQ")+"' AND "
					cSQL += 	" NUQ.NUQ_CAJURI = NSZ.NSZ_COD AND "
					cSQL +=   "	NUQ.NUQ_INSATU = '1' AND "
					cSQL +=   "	NUQ.D_E_L_E_T_ = ' ') "
	
					cSQL += "INNER JOIN " + RetSqlName("NVK") + " NVK ON (NVK.NVK_FILIAL = '"+xFilial("NVK")+"' AND "
					cSQL +=                                             "(NVK.NVK_CUSER = '" + cCodUser + "' OR "
					cSQL +=                                             " NVK.NVK_CGRUP IN (SELECT NZY_CGRUP "
					cSQL +=                                                               " FROM " + RetSqlName("NZY") + " NZY "
					cSQL +=                                                               " WHERE NZY.NZY_CUSER = '" + cCodUser + "' AND "
					cSQL +=                                                                    " NZY.D_E_L_E_T_ = ' ' AND 
					cSQL +=                                                                    " NZY.NZY_FILIAL = '" + xFilial("NZY") + "')"
					cSQL +=                                             " ) AND"
					cSQL +=                                             " NVK.NVK_CCORR = NUQ.NUQ_CCORRE AND "
					cSQL +=                                             " NVK.NVK_CLOJA = NUQ.NUQ_LCORRE AND "
					cSQL +=                                             " NVK.NVK_COD   = '" + aRestr[1][1] + "' AND "
					cSQL +=                                             " NVK.D_E_L_E_T_ = ' ') "
	
					cSQL += " UNION "
	
					cSQL += "	SELECT ACY.ACY_GRPVEN, ACY.ACY_DESCRI, ACY.R_E_C_N_O_ RECNOLAN "
					cSQL += 	" FROM " + RetSqlName("ACY") + " ACY "
	
					cSQL += " INNER JOIN " + RetSqlName("SA1") + " SA1 ON (SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND "
					cSQL += 	" SA1.A1_GRPVEN = ACY.ACY_GRPVEN AND "
					cSQL +=   " SA1.D_E_L_E_T_ = ' ') "
	
					cSQL += " INNER JOIN " + RetSqlName("NSZ") + " NSZ ON (NSZ.NSZ_FILIAL = '"+xFilial("NSZ")+"' AND "
					cSQL += 	" NSZ.NSZ_CCLIEN = SA1.A1_COD AND "
					cSQL +=   " NSZ.NSZ_LCLIEN = SA1.A1_LOJA AND "
					cSQL +=   " NSZ.NSZ_CGRCLI = SA1.A1_GRPVEN AND "
					cSQL += 	" NSZ.NSZ_TIPOAS IN (" + JurSetTAS(.F.) + ") AND "
					cSQL +=   " NSZ.D_E_L_E_T_ = ' ') "
					
					cSQL += " INNER JOIN " + RetSqlName("NVK") + " NVK ON (NVK.NVK_FILIAL = '"+xFilial("NVK")+"' AND "
					cSQL +=                                              "(NVK.NVK_CUSER = '" + cCodUser + "' OR "
					cSQL +=                                              " NVK.NVK_CGRUP IN (SELECT NZY_CGRUP "
					cSQL +=                                                                " FROM " + RetSqlName("NZY") + " NZY "
					cSQL +=                                                                " WHERE NZY.NZY_CUSER = '" + cCodUser + "' AND "
					cSQL +=                                                                     " NZY.D_E_L_E_T_ = ' ' AND 
					cSQL +=                                                                     " NZY.NZY_FILIAL = '" + xFilial("NZY") + "')"
					cSQL +=                                              " ) AND"
					cSQL +=                                              " NVK.NVK_CCORR = NSZ.NSZ_CCORRE AND "
					cSQL +=                                              " NVK.NVK_CLOJA = NSZ.NSZ_LCORRE AND "
					cSQL +=                                              " NVK.NVK_COD   = '" + aRestr[1][1] + "' AND "
					cSQL +=                                              " NVK.D_E_L_E_T_ = ' ') "

				//Fluxo de correspondente por Follow-up
				Else
					cSQL += " LEFT JOIN " + RetSqlName("NTA") + " NTA ON (NTA.NTA_FILIAL = '"+xFilial("NTA")+"' AND "
					cSQL +=                                             " NTA.NTA_CAJURI = NSZ.NSZ_COD AND "
					cSQL +=                                             " NTA.D_E_L_E_T_ = ' ') "
	
					cSQL += " INNER JOIN " + RetSqlName("NVK") + " NVK ON ( NVK.NVK_FILIAL = '"+xFilial("NVK")+"' AND "
					cSQL +=                                              "(NVK.NVK_CUSER = '" + cCodUser + "' OR "
					cSQL +=                                              " NVK.NVK_CGRUP IN (SELECT NZY_CGRUP "
					cSQL +=                                                                " FROM " + RetSqlName("NZY") + " NZY "
					cSQL +=                                                                " WHERE NZY.NZY_CUSER = '" + cCodUser + "' AND "
					cSQL +=                                                                     " NZY.D_E_L_E_T_ = ' ' AND 
					cSQL +=                                                                     " NZY.NZY_FILIAL = '" + xFilial("NZY") + "')"
					cSQL +=                                              " ) AND"
					cSQL +=                                              " NVK.NVK_CCORR  = NTA.NTA_CCORRE AND "
					cSQL +=                                              " NVK.NVK_CLOJA  = NTA.NTA_LCORRE AND "
					cSQL +=                                              " NVK.NVK_COD    = '" + aRestr[1][1] + "' AND "
					cSQL +=                                              " NVK.D_E_L_E_T_ = ' ') "
				EndIf
	
			//Restricao grupo de clientes
			ElseIf 'CLIENTES' $ cGrpRest
	
				cSQL += " INNER JOIN " + RetSqlName("SA1") + " SA1 ON (SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND "
				cSQL += 	" SA1.A1_GRPVEN = ACY.ACY_GRPVEN AND "
				cSQL +=   " SA1.D_E_L_E_T_ = ' ') "
	
				cSQL += " INNER JOIN " + RetSqlName("NWO") + " NWO ON (NWO.NWO_FILIAL = '"+xFilial("NWO")+"' AND "
				cSQL +=   cCond
				cSQL +=   " NWO.NWO_CCLIEN = SA1.A1_COD AND "
				cSQL +=   " NWO.NWO_CLOJA = SA1.A1_LOJA AND "
				cSQL +=   " NWO.D_E_L_E_T_ = ' ') "
	
				cSQL += "	WHERE ACY.ACY_FILIAL = '"+xFilial("ACY")+"'"
				cSQL +=   " AND ACY.D_E_L_E_T_ = ' ' "
	
				cSQL += " UNION "
	
				cSQL += "	SELECT ACY.ACY_GRPVEN, ACY.ACY_DESCRI, ACY.R_E_C_N_O_ RECNOLAN "
				cSQL += 	" FROM " + RetSqlName("ACY") + " ACY "
	
				cSQL += "	INNER JOIN " + RetSqlName("NY2") + " NY2 ON (NY2.NY2_FILIAL = '"+xFilial("NY2")+"' AND "
				cSQL += " NY2.NY2_CCONF = '" + aRestr[1][1] + "' AND "
				cSQL += " NY2.NY2_CGRUP = ACY.ACY_GRPVEN AND "
				cSQL += " NY2.D_E_L_E_T_ = ' ') "
	
				cSQL += "	WHERE ACY.ACY_FILIAL = '"+xFilial("ACY")+"'"
				cSQL +=   " AND ACY.D_E_L_E_T_ = ' ' "
			EndIf
	
			cSQL += "	GROUP BY ACY.ACY_GRPVEN, ACY.ACY_DESCRI, ACY.R_E_C_N_O_  "
	
			cSQL := ChangeQuery(cSQL, .F.)
	
			nPos   := Len(AllTrim(cRet))
			cRetFim:= SUBSTRING(cRet,1,nPos-4)
	
			RestArea( aArea )
			RestArea(aAreaSA1)
			RestArea(aAreaACY)

			nResult := JurF3SXB("ACY", aCampos,, .F., .F.,,cSQL)
			lRet    := nResult > 0
	
			If lRet
				DbSelectArea("ACY")
				ACY->(dbgoTo(nResult))
			EndIf
		Else
			RestArea( aArea )
			RestArea(aAreaSA1)
			RestArea(aAreaACY)
			
			nResult := JurF3SXB("ACY", aCampos,cRetFim, .F., .F.)
			lRet    := nResult > 0
			
			If lRet
				DbSelectArea("ACY")
				ACY->(dbgoTo(nResult))
			EndIf
		EndIf
	Else
		RestArea( aArea )
		RestArea(aAreaSA1)
		RestArea(aAreaACY)
		
		nResult := JurF3SXB("ACY", aCampos,cRetFim, .F., .F.)
		lRet    := nResult > 0
		
		If lRet
			DbSelectArea("ACY")
			ACY->(dbgoTo(nResult))
		EndIf
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA95SA2NSZ
Filtro da consulta padrão de correspondentes, respeitando a restrição

@Return aRet	 	Lista de cliente e loja

@author André Spirigoni Pinto

@since 21/08/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA95SA2NSZ()
Local cRet     := "@#@#"
Local nPos     := 0
Local nI
Local aArea    := GetArea()
Local aRestr   := {}
Local cGrpRest := JurGrpRest()

If !IsInCallStack('JURA163') .And. 'CORRESPONDENTES' $ cGrpRest
	aRestr:= JA162RstUs()
	cRet := "@#("

	For nI := 1 to LEN(aRestr)
		cRet += "( SA2->A2_COD == '"+aRestr[nI][2]+"' .AND. SA2->A2_LOJA == '"+aRestr[nI][3]+"') .OR."
	Next

	nPos   := Len(AllTrim(cRet))
	cRetFim:= SUBSTRING(cRet,1,nPos-4)
	cRet   := cRetFim+") .AND. SA2->A2_MJURIDI=='1'.AND.SA2->A2_MSBLQL=='2'@#"
Else
	cRet := "@#SA2->A2_MJURIDI=='1'.AND.SA2->A2_MSBLQL=='2'@#"
EndIf

RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA95NVENSZ
Filtra a consulta padrão de casos conforme a restrição de clientes ou
situação

@Return cRet	 	Filtro da consulta

@author Juliana Iwayama Velho
@since 04/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA95NVENSZ()
Local cRet     := "@#("
Local cRetFim  := "@#@#"
Local nPos     := 0
Local nPosCli  := 0
Local nPosLoj  := 0
Local aRestr   := {}
Local cMVJcaso1:= SuperGetMV("MV_JCASO1",, "1")
Local nI
Local aArea    := GetArea()
Local cGrpRest := JurGrpRest()

If IsPesquisa()
	aRestr:= JA162RstUs()
	If !Empty(aRestr) .And. 'CLIENTES' $ cGrpRest
		If !(Empty(M->NSZ_CCLIEN) .And. Empty(M->NSZ_LCLIEN))
			If ( nPosCli := aScan( aRestr, { | x |  x[2] == M->NSZ_CCLIEN } ) ) > 0 .And.;
   			   ( nPosLoj := aScan( aRestr,{ | x |  x[3] == M->NSZ_LCLIEN } ) ) > 0
					cRet += "( NVE->NVE_CCLIEN == '"+M->NSZ_CCLIEN+"' .AND. NVE->NVE_LCLIEN == '"+M->NSZ_LCLIEN+"') .OR."
			EndIf
		ElseIf Empty(M->NSZ_CCLIEN) .Or. Empty(M->NSZ_LCLIEN)
			For nI := 1 to LEN(aRestr)
				cRet += "( NVE->NVE_CCLIEN == '"+aRestr[nI][2]+"' .AND. NVE->NVE_LCLIEN == '"+aRestr[nI][3]+"') .OR."
			Next
		EndIf
		nPos   := Len(AllTrim(cRet))
		cRetFim:= SUBSTRING(cRet,1,nPos-4)+")@#"
	Else
		If !(Empty(M->NSZ_CCLIEN) .And. Empty(M->NSZ_LCLIEN)) .And. cMVJcaso1 == '1'
			cRetFim := "@#NVE->NVE_CCLIEN == '"+M->NSZ_CCLIEN+"' .AND. NVE->NVE_LCLIEN == '"+M->NSZ_LCLIEN+"'@#"
		EndIF
	EndIf
Else
	If !(Empty(M->NSZ_CCLIEN) .And. Empty(M->NSZ_LCLIEN)) .And. cMVJcaso1 == '1'
	  if !IsInCallStack("JURA101")
			cRetFim := "@#NVE->NVE_CCLIEN == '"+M->NSZ_CCLIEN+"' .AND. NVE->NVE_SITUAC == '1' .AND. NVE->NVE_LCLIEN == '"+M->NSZ_LCLIEN+"'@#"
		Else
			cRetFim := "@#NVE->NVE_CCLIEN == '"+M->NSZ_CCLIEN+"' .AND. NVE->NVE_LCLIEN == '"+M->NSZ_LCLIEN+"'@#"
		Endif
	Elseif !IsInCallStack("JURA101")
		cRetFim := "@#NVE->NVE_SITUAC == '1'@#"
	EndIf
EndIf

RestArea(aArea)

return cRetFim

//-------------------------------------------------------------------
/*/{Protheus.doc} JA95SA2NUQ
Filtra a consulta padrão de correspondentes conforme a restrição, se
é do tipo jurídico e se está ativo

@Return cRet	 	Filtro da consulta

@author Juliana Iwayama Velho
@since 04/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA95SA2NUQ(cCod, cLoja)
Local cRet       := "@#"
Local nPos       := 0
Local nI         := 1
Local aArea      := GetArea()
Local aRestr     := {}
Local cGrpRest   := JurGrpRest()
Local cFilCorAre := "" //Filtro da Comarca e Area que o corresponde atua

Default cCod     := ""
Default cLoja    := ""

If !IsInCallStack('JURA163') .And. 'CORRESPONDENTES' $ cGrpRest

	aRestr:= JA162RstUs()

	If Len(aRestr) > 0
	 	cRet += "("

		For nI := 1 to LEN(aRestr)
			cRet += "( SA2->A2_COD == '"+aRestr[nI][2]+"' .AND. SA2->A2_LOJA == '"+aRestr[nI][3]+"') .OR."
		Next

		nPos   := Len(AllTrim(cRet))
		cRetFim:= SUBSTRING(cRet,1,nPos-4)
		cRet   := cRetFim+") .AND. "
	EndIf

EndIf

cRet += "SA2->A2_MJURIDI == '1' .AND. SA2->A2_MSBLQL == '2'"

//Filtra os correspondente pela comarca ou area
If !Empty( cFilCorAre := FilComArea(cCod, cLoja) )
	cRet += " .AND. " + cFilCorAre
Else //se não houverem correspondentes com atuação compatível ou sem restrição, não devem ser exibidos nenhum
	If !(IsPesquisa()) .and. !FwIsInCallStack('JURA189') .and. !FwIsInCallStack('JURA191')
		cRet += " .AND. 1 == 2"
	EndIf
EndIf

cRet += "@#"

RestArea(aArea)
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JU095CAS
Filtra a consulta padrão de caso conforme o cliente
Uso na pesquisa de processo da tela de vinculo.
@Return lRet	.T./.F. As informações são válidas ou não
@author Clóvis Eduardo Teixeira
@since 13/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JU095CAS()
Local cRet := "@#@#"

	If !(Empty(cGetClien) .And. Empty(cGetLoja))
		cRet := "@#NVE->NVE_CCLIEN == '"+cGetClien+"' .AND. NVE->NVE_LCLIEN == '"+cGetLoja+"'@#"
	EndIF

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095CLI
Filtra a consulta de cliente conforme grupo ou restrição
Uso no cadastro de Processo.

@Param aCampos	    	- Campos disponiveis para a pesquisa. Default := {}
@Param lVisualiza		- Apresenta botão de Visualiza (T/F). Default := .F.
@Param lInclui	    	- Apresenta botão de Inclusão (T/F) . Default := .F.
@Param cFiltro    		- Filtro a ser executado na tabela. O formato tem que ser em ADVPL.
//                   	  Ex: "A1_EST == 'SP' .AND. A1_FILIAL == 'D MG    ' "
@Param cFonte      	- Nome do Fonte. Default := ""
@Param lExibeDados	- Indica se os dados serão exibidos logo que é aberta a tela. Default := .T.

@Return lRet	.T./.F. As informações são válidas ou não
@sample
@author Clóvis Eduardo Teixeira
@since 09/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095CLI(aCampos,lVisualiza,lInclui,cFiltro,cFonte,lExibeDados)
Local aArea     := GetArea()
Local lRet      := .F.
Local aRestr    := {}
Local cSQL		:= ""
Local nResult   := 0
Local aCmpExibir:= {}
Local nI        := 0

Local lIntegra  := SuperGetMV( "MV_JFTJURI",, "2" ) == "1" // Indica se ha Integracao entre SIGAJURI e SIGAPFS (1=Sim;2=Nao)
Local lLojaAuto := SuperGetMv( "MV_JLOJAUT",, "2" ) == "1" // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)


Default aCampos    := {}
Default lVisualiza := .F.
Default lInclui    := .F.
Default cFiltro    := ""
Default cFonte     := ""
Default lExibeDados:= .T.


	If IsPesquisa() .OR. IsInCallStack("JURA162") .OR. IsInCallStack("JURA219")

		aRestr:= JA162RstUs()
		If Len(aCampos) > 0
			aCmpExibir := aCampos

			// Inclui o A1_COD e o A1_NOME caso não tenha essas colunas
			// Por eles serem o retorno da tela
			If aScan(aCampos, 'A1_COD') = 0
				aAdd(aCampos, 'A1_COD')
			EndIf

			If aScan(aCampos, 'A1_NOME') = 0
				aAdd(aCampos, 'A1_NOME')
			EndIf

			// Garante que não aparecerá a loja se a integração entre SIGAJURI e SIGAPFS e loja automática estiverem ativos
			If lLojaAuto .AND. lIntegra
				cFiltro := " A1_LOJA == '"+JurGetLjAt()+"' "
			Else
				If aScan(aCampos, 'A1_LOJA') = 0
					aAdd(aCampos, 'A1_LOJA')
				EndIf
			EndIf
		Else
			aCampos := {'A1_COD','A1_NOME'}
			If lLojaAuto .AND. lIntegra
				cFiltro := " A1_LOJA == '"+JurGetLjAt()+"' "
			Else
				aAdd(aCampos, 'A1_LOJA')
			EndIf

			aCmpExibir := aClone(aCampos)
		EndIf

		If !Empty(aRestr) //Verifica funcao inclui no model //Se nao for inclusao efetuar restricao

			If !IsPesquisa()
				cSQL := J095CliSql(aRestr, aCampos, cFiltro)   //Monta SQL com restrição LPS
				cSQL := ChangeQuery(cSQL, .F.)
			EndIf

			nResult := JurF3SXB("SA1", aCmpExibir,cFiltro, lVisualiza, lInclui,cFonte,cSQL,lExibeDados)
			lRet    := nResult > 0

		Else
			//-- Monta a query para filtrar clientes que geram caso automático (NUH_CASAUT = '1')
			iF Len(aCampos) > 0 .And. Empty(cSQL)
				cSQL := "SELECT "
				
				For nI := 1 To Len(aCampos)
					cSQL += aCampos[nI] + ", "
				Next
				cSQL += " SA1.R_E_C_N_O_ RECNOSA1 "
				cSQL +=      " FROM " + RetSqlName('SA1') + " SA1"
				cSQL += " INNER JOIN " + RetSqlName('NUH') + " NUH ON NUH.NUH_COD = SA1.A1_COD"
				cSQL +=      " AND NUH.NUH_LOJA = SA1.A1_LOJA"
				cSQL += " WHERE SA1.D_E_L_E_T_ =  ' ' "
				cSQL +=      " AND NUH.D_E_L_E_T_ =  ' ' "
			EndIf

			nResult := JurF3SXB("SA1", aCmpExibir,cFiltro, lVisualiza, lInclui,cFonte,cSQL,lExibeDados)
			lRet    := nResult > 0
		EndIf

	Else
		oModel := FWModelActive()
		if !Empty(oModel:GetValue('NSZMASTER','NSZ_CGRCLI'))
			cFiltro := "A1_GRPVEN == '"+oModel:GetValue('NSZMASTER','NSZ_CGRCLI')+"'"
		endif

		If lLojaAuto .AND. lIntegra
			// Garante que não aparecerá a loja se a integração entre SIGAJURI e SIGAPFS e loja automática estiverem ativos
			aCampos := {'A1_COD','A1_NOME'}

			IIf( !Empty(cFiltro), cFiltro += " .AND. ", )

			cFiltro += "A1_LOJA == '"+JurGetLjAt()+"' "
		EndIf

		nResult := JurF3SXB("SA1", aCampos,cFiltro, lVisualiza, lInclui,cFonte,cSQL,lExibeDados)
		lRet    := nResult > 0
	EndIf

	If lRet
		DbSelectArea("SA1")
		SA1->(dbgoTo(nResult))
	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J095CliSql
Monta SQL para o retorno de clientes quando utiliza-se restrições de Clientes e Correspondentes
no momento da verificação das restrições do usuário e pesquisa na JA162RstUs.

@Return cSQL
@sample
@author Leandro.silva
@since 18/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J095CliSql(aRestr, aCampos, cFilter)

	Local cGrpRest    := JurGrpRest()
	Local nFlxCorres  := SuperGetMV("MV_JFLXCOR", , 1)	//Fluxo de correspondente por Follow-up ou Assunto Jurídico? (1=Follow-up ; 2=Assunto Jurídico)"
	Local cSql        := ''
	Local cSelCmp     := ''
	Local nI          := 0
	
	Default aCampos := {'A1_COD', 'A1_LOJA', 'A1_NOME'}
	Default cFilter := ''

	For nI := 1 to Len(aCampos)
		cSelCmp += aCampos[nI] + ","
	Next
	cSelCmp := cSelCmp + " SA1.R_E_C_N_O_ "

	cSql := " SELECT " + cSelCmp	
	cSql += " FROM " + RetSqlName("SA1") + " SA1 "

	//Restricao por grupo de correspondente 
	If 'CORRESPONDENTES' $ cGrpRest .And. Type("INCLUI") <> "U" .And. !INCLUI  //Verifica funcao inclui no model //Se nao for inclusao efetuar restricao
		     
		cSql += " INNER JOIN " + RetSqlName("NSZ") + " NSZ ON (NSZ.NSZ_FILIAL = '"+xFilial("NSZ")+"' AND "
		cSql +=                                              " NSZ.NSZ_CCLIEN = SA1.A1_COD AND "
		cSql +=                                              " NSZ.NSZ_LCLIEN = SA1.A1_LOJA AND "
		cSql +=                                              " NSZ.NSZ_TIPOAS IN (" + JurSetTAS(.F.) + ") AND"
		cSql +=                                              " NSZ.D_E_L_E_T_ = ' ') "
	
			//Fluxo de correspondente por Assunto Jurídico
			If nFlxCorres == 2
	
				cSql += " LEFT JOIN " + RetSqlName("NUQ") + " NUQ ON (NUQ.NUQ_FILIAL = '"+xFilial("NUQ")+"' AND "
				cSql +=                                             " NUQ.NUQ_CAJURI = NSZ.NSZ_COD AND "
				cSql +=                                             " NUQ.NUQ_INSATU = '1' AND "
				cSql +=                                             " NUQ.D_E_L_E_T_ = ' ') "
	
				cSql += " INNER JOIN " + RetSqlName("NVK") + " NVK ON (NVK.NVK_FILIAL = '"+xFilial("NVK")+"' AND "
				cSql +=                                              " NVK.NVK_CCORR  = NUQ.NUQ_CCORRE AND "
				cSql +=                                              " NVK.NVK_CLOJA  = NUQ.NUQ_LCORRE AND "
				cSql +=                                              " NVK.NVK_COD    = '" + aRestr[1][1] + "' AND "
				cSql +=                                              " NVK.D_E_L_E_T_ = ' ')"
				
				cSql += " INNER JOIN " + RetSqlName("NUH") + " NUH ON (NUH.NUH_COD = SA1.A1_COD AND "
				cSql +=                                            " NUH.NUH_LOJA = SA1.A1_LOJA AND "
				cSql +=                                            " NUH.D_E_L_E_T_ = ' ') "
				
				cSql += " WHERE SA1.A1_FILIAL = '"+xFilial("SA1")+"'"
				cSql +=	  " AND SA1.D_E_L_E_T_ = ' ' "
				
				//--Verifica se há filtro e inclui na query
				If !(Empty(cFilter))
					cSql += " AND " + cFilter
				EndIf
	
				cSql += " UNION "
				
				cSql += " SELECT " + cSelCmp
				cSql += " FROM " + RetSqlName("SA1") + " SA1 "
	
				cSql += " INNER JOIN " + RetSqlName("NSZ") + " NSZ ON (NSZ.NSZ_FILIAL = '"+xFilial("NSZ")+"' AND "
				cSql +=                                              " NSZ.NSZ_CCLIEN = SA1.A1_COD AND "
				cSql +=                                              " NSZ.NSZ_LCLIEN = SA1.A1_LOJA AND "
				cSql +=                                              " NSZ.NSZ_TIPOAS IN (" + JurSetTAS(.F.) + ") AND"
				cSql +=                                              " NSZ.D_E_L_E_T_ = ' ') "
	
				cSql += " INNER JOIN " + RetSqlName("NVK") + " NVK ON (NVK.NVK_FILIAL = '"+xFilial("NVK")+"' AND "
				cSql +=                                              " NVK.NVK_CCORR  = NSZ.NSZ_CCORRE AND "
				cSql +=                                              " NVK.NVK_CLOJA  = NSZ.NSZ_LCORRE AND "
				cSql +=                                              " NVK.NVK_COD    = '" + aRestr[1][1] + "' AND "
				cSql +=                                              " NVK.D_E_L_E_T_ = ' ')"
				
				cSql += " WHERE	SA1.A1_FILIAL = '"+xFilial("SA1")+"'"
				cSql +=	  " AND SA1.D_E_L_E_T_ = ' ' "			
	
			//Fluxo de correspondente por Follow-up
			Else
			
				cSql += " LEFT JOIN " + RetSqlName("NTA") + " NTA ON (NTA.NTA_FILIAL = '"+xFilial("NTA")+"' AND "
				cSql +=                                             " NTA.NTA_CAJURI = NSZ.NSZ_COD AND "
				cSql +=                                             " NTA.D_E_L_E_T_ = ' ') "
	
				cSql += " INNER JOIN " + RetSqlName("NVK") + " NVK ON (NVK.NVK_FILIAL 	= '"+xFilial("NVK")+"' AND "
				cSql +=                                              " NVK.NVK_CCORR 	= NTA.NTA_CCORRE AND "
				cSql +=                                              " NVK.NVK_CLOJA 	= NTA.NTA_LCORRE AND "
				cSql +=                                              " NVK.NVK_COD   	= '" + aRestr[1][1] + "' AND "
				cSql +=                                              " NVK.D_E_L_E_T_ 	= ' ')"
				
				cSql += " WHERE SA1.A1_FILIAL = '"+xFilial("SA1")+"'"
				cSql +=	  " AND SA1.D_E_L_E_T_ = ' ' "
				
				//--Verifica se há filtro e inclui na query
				If !(Empty(cFilter))
					cSql += " AND " + cFilter
				EndIf
			EndIf
		
	EndIf
	
	//Restricao por grupo de clientes
	If 'CLIENTES' $ cGrpRest

		cSql += " INNER JOIN " + RetSqlName("NWO") + " NWO ON (NWO.NWO_FILIAL = '"+xFilial("NWO")+"' AND "
		cSql += 											 " NWO.NWO_CCONF = '" + aRestr[1][1] + "' AND "
		cSql +=                                              " NWO.NWO_CCLIEN = SA1.A1_COD AND "
		cSql +=                                              " NWO.NWO_CLOJA = SA1.A1_LOJA AND "
		cSql +=                                              " NWO.D_E_L_E_T_ = ' ') "

		cSql += " INNER JOIN " + RetSqlName("NUH") + " NUH ON (NUH.NUH_COD = SA1.A1_COD AND "
		cSql +=                                            " NUH.NUH_LOJA = SA1.A1_LOJA AND "
		cSql +=                                            " NUH.D_E_L_E_T_ = ' ') "

		cSql += " WHERE	SA1.A1_FILIAL = '"+xFilial("SA1")+"'"
		cSql +=   " AND SA1.D_E_L_E_T_ = ' ' "
		
		//--Verifica se há filtro e inclui na query
		If !(Empty(cFilter))
			cSql += " AND " + cFilter
		EndIf

		cSql += " UNION "
		
		cSql += ' SELECT ' + cSelCmp
		cSql += " FROM " + RetSqlName("SA1") + " SA1 "

		cSql += " INNER JOIN " + RetSqlName("NSZ") + " NSZ ON (NSZ.NSZ_FILIAL = '"+xFilial("NSZ")+"' AND "
		cSql +=                                              " NSZ.NSZ_CCLIEN = SA1.A1_COD AND "
		cSql +=                                              " NSZ.NSZ_LCLIEN = SA1.A1_LOJA AND "
		cSql +=                                              " NSZ.D_E_L_E_T_ = ' ') "
		
		cSql += " LEFT JOIN " + RetSqlName("NUQ") + " NUQ ON (NUQ.NUQ_FILIAL = '"+xFilial("NUQ")+"' AND "
		cSql +=                                             " NUQ.NUQ_CAJURI = NSZ.NSZ_COD AND "
		cSql +=                                             " NUQ.NUQ_INSATU = '1' AND "
		cSql +=                                             " NUQ.D_E_L_E_T_ = ' ') "

		cSql += " INNER JOIN " + RetSqlName("NY2") + " NY2 ON (NY2.NY2_FILIAL = '"+xFilial("NY2")+"' AND "
		cSql +=                                              " NY2.NY2_CCONF  = '" + aRestr[1][1] + "' AND "
		cSql +=                                              " NY2.NY2_CGRUP  = SA1.A1_GRPVEN AND "
		cSql +=                                              " NY2.D_E_L_E_T_ = ' ') "

		cSql += " WHERE SA1.A1_FILIAL = '"+xFilial("SA1")+"'"
		cSql +=   " AND SA1.D_E_L_E_T_ = ' ' "

	EndIf

	If ('CORRESPONDENTES' $ cGrpRest) .AND. !IsPesquisa()
		cSql += " WHERE	SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
		cSql +=      " AND SA1.D_E_L_E_T_ = ' ' "
	Else
		cSql += " GROUP BY "  + cSelCmp	//SA1.A1_FILIAL,SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA1.R_E_C_N_O_ "
	EndIf

Return cSql

//-------------------------------------------------------------------
/*/{Protheus.doc} JA95SU5
Monta a query de advogado a partir de parâmetro para filtro de
correspondente
Uso no cadastro de Instância.

@Param cCorresp    Campo de código de Correspondente
@Return cQuery	 	Query montada

@author Juliana Iwayama Velho
@since 29/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA95SU5(cCorresp , cLjCorr)
Local cQuery   := ""

Default cLjCorr := "##"

If !Empty(cCorresp)
	cQuery += "SELECT U5_CODCONT, U5_CONTAT, SU5.R_E_C_N_O_ SU5RECNO "
	cQuery += " FROM "+RetSqlName("SU5")+" SU5,"+RetSqlName("SA2")+" SA2,"+RetSqlName("AC8")+" AC8"
	cQuery += " WHERE U5_FILIAL = '"+xFilial("SU5")+"'"
	cQuery += " AND A2_FILIAL = '"+xFilial("SA2")+"'"
	cQuery += " AND AC8_FILIAL = '"+xFilial("AC8")+"'"
	cQuery += " AND AC8_CODCON = U5_CODCONT"
	cQuery += " AND AC8_ENTIDA = 'SA2'"
	cQuery += " AND A2_COD||A2_LOJA = AC8_CODENT "
	cQuery += " AND A2_MJURIDI = '1'"
	cQuery += " AND A2_MSBLQL  = '2'"
	cQuery += " AND SU5.D_E_L_E_T_ = ' '"
	cQuery += " AND SA2.D_E_L_E_T_ = ' '"
	cQuery += " AND AC8.D_E_L_E_T_ = ' '"
	cQuery += " AND SA2.A2_COD = '"+cCorresp+"'"

	If !Empty(cLjCorr) .AND. cLjCorr != "##"
		cQuery += " AND SA2.A2_LOJA = '"+cLjCorr+"'"
	EndIf
Else
	cQuery += "SELECT U5_CODCONT, U5_CONTAT, SU5.R_E_C_N_O_ SU5RECNO "
	cQuery += " FROM "+RetSqlName("SU5")+" SU5"
	cQuery += " WHERE U5_FILIAL = '--'"
EndIf

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J95VGCliUn
Função para validar Cliente/Loja de acordo com Grupo de Cliente
na aba de Unidades (SOCIETARIO)

@Return lRet	   .T. ou .F.

@author Rafael Rezende Costa
@since 14/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J95VGCliUn()
Local lRet      := .T.
Local cSQL      := ""
Local aSQL      := {}
Local aRestr    := ''
Local nLoc      := 0
local cGrupo    := ''
Local aCodsUser := {}
Local aCods     := {}
Local cRetFim   := ''
Local nI,nY     := 0
Local cGrpRest  := JurGrpRest()
Local cCliente  := ""
Local cLoja     := ""
Local lSociet   := .F.
Local oModel
Local oModelNYJ

If !IsPesquisa()
	oModel    := FWMODELACTIVE()
	oModelNYJ := oModel:GetModel('NYJDETAIL')
	cCliente  := oModelNYJ:GetValue('NYJ_CCLIEN')
	cLoja     := oModelNYJ:GetValue('NYJ_LCLIEN')
	cGrupoCli := oModel:GetValue('NSZMASTER','NSZ_CGRCLI')
	lSociet   := IIF(oModel:GetID()=='JURA095',JurSocieta(oModel:GetValue("NSZMASTER","NSZ_TIPOAS")),.F.)
EndIf

//<-Validação somente para SOCIETARIO ->
If lSociet .AND. !EMPTY(cLoja)

	If ExistCpo('SA1',cCliente + cLoja,1)

		aRestr   := JA162RstUs()
		cCliente := cCliente
		cLoja	 := cLoja

		cSQL := "	SELECT SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME,  SA1.R_E_C_N_O_ RECNOLAN " + CRLF
		cSQL += " FROM " + RetSqlName("SA1") + " SA1 " + CRLF

		If (!Empty(cGrupoCli)) .AND. !('CLIENTES' $ cGrpRest)
			cSQL += "	WHERE	SA1.A1_FILIAL = '"+xFilial("SA1")+"'"+ CRLF
			cSQL += " AND SA1.D_E_L_E_T_ = ' ' "+ CRLF
			cSQL += " AND SA1.A1_GRPVEN = '"+cGrupoCli+"'"
		Else

			// Restrição
			If 'CLIENTES' $ cGrpRest .AND. !Empty(aRestr)
				cSQL += "	INNER JOIN " + RetSqlName("NWO") + " NWO ON (NWO.NWO_FILIAL = '"+xFilial("NWO")+"' AND "+ CRLF
				cSQL +=                                              " NWO.NWO_CCONF = '" + aRestr[1][1] + "' AND " + CRLF
				cSQL +=                                              " NWO.NWO_CCLIEN = SA1.A1_COD AND "+ CRLF
				cSQL +=                                              " NWO.NWO_CLOJA = SA1.A1_LOJA AND "+ CRLF
				cSQL +=                                              " NWO.D_E_L_E_T_ = ' ') "+ CRLF
				cSQL += "	WHERE	SA1.A1_FILIAL = '"+xFilial("SA1")+"'"+ CRLF
				cSQL +=   " AND SA1.D_E_L_E_T_ = ' ' "+ CRLF
				cSQL += " UNION " + CRLF
				cSQL += "	SELECT SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME,  SA1.R_E_C_N_O_ RECNOLAN " + CRLF
				cSQL += 	" FROM " + RetSqlName("SA1") + " SA1 " + CRLF
				cSQL +=        " INNER JOIN " + RetSqlName("NSZ") + " NSZ ON (NSZ.NSZ_FILIAL = '"+xFilial("NSZ")+"' AND "+ CRLF
				cSQL +=                                                     " NSZ.NSZ_CCLIEN = SA1.A1_COD AND " + CRLF
				cSQL +=                                                     " NSZ.NSZ_LCLIEN = SA1.A1_LOJA AND " + CRLF
				cSQL +=                                                     " NSZ.D_E_L_E_T_ = ' ') " + CRLF

				cSQL +=         " LEFT JOIN " + RetSqlName("NYJ") + " NYJ ON (NYJ.NYJ_FILIAL = '"+xFilial("NYJ")+"' AND "+ CRLF
				cSQL +=                                                     " NYJ.NYJ_CAJURI = NSZ.NSZ_COD AND " + CRLF
				cSQL +=                                                     " NYJ.D_E_L_E_T_ = ' ') " + CRLF

				cSQL +=         " INNER JOIN " + RetSqlName("NY2") + " NY2 ON (NY2.NY2_FILIAL = '"+xFilial("NY2")+"' AND "+ CRLF
				cSQL +=                                              " NY2.NY2_CCONF = '" + aRestr[1][1] + "' AND " + CRLF
				cSQL +=                                              " NY2.NY2_CGRUP = SA1.A1_GRPVEN AND "+ CRLF
				cSQL +=                                              " NY2.D_E_L_E_T_ = ' ') "+ CRLF
			EndIf

			cSQL += " WHERE SA1.A1_FILIAL = '"+xFilial("SA1")+"'"+ CRLF
			cSQL +=   " AND SA1.D_E_L_E_T_ = ' ' "+ CRLF

			IF 'CLIENTES' $ cGrpRest .AND.Empty(aRestr)
				aCodsUser := JurCodRst()

				cRetFim := cSQL
				For nI := 1 TO LEN(aCodsUser)
					aCods:= JurCdCliRst(aCodsUser[nI][1])

					cRetFim += IIF( LEN(aCods) > 0, "AND (", '')

					For nY:= 1 to LEN(aCods)
						cRetFim += "(SA1.A1_COD = '"+aCods[nY][1]+"' AND SA1.A1_LOJA ='"+aCods[nY][2]+"')"
						cRetFim += " OR "
					Next nY
				Next nI

				cRetFim:= LEFT(cRetFim , RAT(' OR ',cRetFim)-1 )
				cRetFim += IIF( LEN(aCods) > 0," )", '')

				cSQL:= cRetFim
			EndIF

			cSQL += "	GROUP BY SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA1.R_E_C_N_O_  " + CRLF
		EndIF

		aSQL := JurSQL(cSQL, {"A1_COD", "A1_LOJA"})

		If aScan( aSQL, {|x| x[1]== cCliente .AND. x[2]== cLoja } ) < 1
			lRet := .F.
			JurMsgErro(STR0005) //"Cliente e Loja inválidos para este perfil de processo"
		EndIf

	Else
		lRet := .F.
		JurMsgErro(STR0005) //"Cliente e Loja inválidos para este perfil de processo"
	EndIf

EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J095CliNYJ

Consulta padrao para cliente da unidade respeitando a restricao

@author Rodrigo Guerato
@since 31/07/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function J095CliNYJ()
	Local aArea   	  := GetArea()
	Local aAreaSA1    := SA1->(GetArea())
	Local lRet    	  := .F.
	Local aSearch 	  := {{'A1_COD',1},{'A1_NOME',2}}
	Local aCampos 	  := {'A1_COD','A1_LOJA','A1_NOME'}
	Local aFiltro 	  := {}
	Local aRestr  	  := {}
	Local cRetFim 	  := ""
	Local cRet    	  := ""
	Local nPos    	  := 0
	Local cSQL		  := ""
	Local aTemp 	  := {}
	Local TABLANC 	  := ""
	Local aFields	  := {}
	Local aOrder	  := {}
	Local aFldsFilt   := {}
	Local cGrpRest    := JurGrpRest()
	Local nResult     := 0
	Local oTabTmp     := Nil
	Local aStruAdic   := {}

	If IsPesquisa() .OR. IsInCallStack("JURA162")

		aRestr := JA162RstUs()

		If !Empty(aRestr)

			cSQL := "	SELECT SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME,  SA1.R_E_C_N_O_ RECNOLAN " + CRLF
			cSQL += 	" FROM " + RetSqlName("SA1") + " SA1 " + CRLF

			If 'CLIENTES' $ cGrpRest

				cSQL += "	INNER JOIN " + RetSqlName("NWO") + " NWO ON (NWO.NWO_FILIAL = '"+xFilial("NWO")+"' AND "+ CRLF
				cSQL +=                                              " NWO.NWO_CCONF = '" + aRestr[1][1] + "' AND " + CRLF
				cSQL +=                                              " NWO.NWO_CCLIEN = SA1.A1_COD AND "+ CRLF
				cSQL +=                                              " NWO.NWO_CLOJA = SA1.A1_LOJA AND "+ CRLF
				cSQL +=                                              " NWO.D_E_L_E_T_ = ' ') "+ CRLF

				cSQL += "	WHERE	SA1.A1_FILIAL = '"+xFilial("SA1")+"'"+ CRLF
				cSQL +=   " AND SA1.D_E_L_E_T_ = ' ' "+ CRLF

				cSQL += " UNION " + CRLF

				cSQL += "	SELECT SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME,  SA1.R_E_C_N_O_ RECNOLAN " + CRLF
				cSQL += 	" FROM " + RetSqlName("SA1") + " SA1 " + CRLF

				cSQL +=        " INNER JOIN " + RetSqlName("NSZ") + " NSZ ON (NSZ.NSZ_FILIAL = '"+xFilial("NSZ")+"' AND "+ CRLF
				cSQL +=                                                     " NSZ.NSZ_CCLIEN = SA1.A1_COD AND " + CRLF
				cSQL +=                                                     " NSZ.NSZ_LCLIEN = SA1.A1_LOJA AND " + CRLF
				cSQL +=                                                     " NSZ.D_E_L_E_T_ = ' ') " + CRLF
				cSQL +=         " LEFT JOIN " + RetSqlName("NYJ") + " NYJ ON (NYJ.NYJ_FILIAL = '"+xFilial("NYJ")+"' AND "+ CRLF
				cSQL +=                                                     " NYJ.NYJ_CAJURI = NSZ.NSZ_COD AND " + CRLF
				cSQL +=                                                     "	NYJ.D_E_L_E_T_ = ' ') " + CRLF

				cSQL += "	INNER JOIN " + RetSqlName("NY2") + " NY2 ON (NY2.NY2_FILIAL = '"+xFilial("NY2")+"' AND "+ CRLF
				cSQL +=                                              " NY2.NY2_CCONF = '" + aRestr[1][1] + "' AND " + CRLF
				cSQL +=                                              " NY2.NY2_CGRUP = SA1.A1_GRPVEN AND "+ CRLF
				cSQL +=                                              " NY2.D_E_L_E_T_ = ' ') "+ CRLF

				cSQL += "	WHERE	SA1.A1_FILIAL = '"+xFilial("SA1")+"'"+ CRLF
				cSQL +=   " AND SA1.D_E_L_E_T_ = ' ' "+ CRLF

			EndIf

			cSQL += "	GROUP BY SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA1.R_E_C_N_O_  " + CRLF

			cSQL := ChangeQuery(cSQL, .F.)

			nPos   := Len(AllTrim(cRet))
			cRetFim:= SUBSTRING(cRet,1,nPos-4)

			Aadd(aStruAdic, { "RECNOLAN", "RECNOLAN", "N", 100, 0, ""})

			aTemp 		:= JurCriaTMP(GetNextAlias(), cSQL, 'SA1', , aStruAdic)
			oTabTmp 	:= aTemp[1]
			aFields		:= aTemp[2]
			aOrder  	:= aTemp[3]
			aFldsFilt 	:= aTemp[4]
			TABLANC     := oTabTmp:GetAlias()

			RestArea( aArea )
			RestArea(aAreaSA1)

			nResult := JurF3SXB("SA1", aCampos,, .F., .F.,,cSQL)
			lRet    := nResult > 0

			If lRet
				DbSelectArea(TABLANC)
				(TABLANC)->(dbgoTo(nResult))
			EndIf

			//Apaga a Tabela temporária
			oTabTmp:Delete()

		Else
			cRetFim := "A1_FILIAL == '"+FwxFilial("SA1",cFilAnt)+"'"
			nResult := JurF3SXB("SA1", aCampos, cRetFim, .F., .F.,,cSQL)
			lRet    := nResult > 0

			If lRet
				DbSelectArea("SA1")
				SA1->(dbgoTo(nResult))
			EndIf

		EndIf

	Else
		oModel := FWModelActive()
		if !Empty(oModel:GetValue('NSZMASTER','NSZ_CGRCLI'))
			cRetFim := "A1_GRPVEN == '"+oModel:GetValue('NSZMASTER','NSZ_CGRCLI')+"'"
		endif

		nResult := JurF3SXB("SA1", aCampos, cRetFim, .F., .F.)
		lRet    := nResult > 0

		If lRet
			DbSelectArea("SA1")
			SA1->(dbgoTo(nResult))
		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FilComArea
Retonar o filtro com os correpondentes pertencentes a comarca atual ou area do processo

@return	cFiltro - Contendo os correspondes do filtro
@author Rafael Tenorio da Costa
@since 24/06/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FilComArea(cCod, cLoja)
Local aArea		:= GetArea()
Local cFiltro	:= ""
Local oModel	:= FWModelActive()
Local cProcesso	:= ""
Local cTipoAssu := ""
Local cAreaJuri	:= ""
Local aAux		:= {}
Local aTabelas	:= {}
Local cComarca	:= ""
Local cQuery	:= " SELECT FILCOMAREA.A2_COD, FILCOMAREA.A2_LOJA FROM( "
Local cTabela	:= ""
Local cJoin		:= ""
Local cWhere	:= ""
Local lContinua	:= .F.
Local cWhrUnion := ""

Default cCod    := "" 
Default cLoja   := ""
	//Carrega informacoes do processo
	If oModel <> Nil .And. oModel:IsActive()
		Do Case
			Case oModel:GetId() == "JURA106" 
				cProcesso := oModel:GetValue("NTAMASTER", "NTA_CAJURI")
				If !Empty(cProcesso)
					aAux := JurGetDados("NSZ", 1, xFilial("NSZ") + cProcesso, {"NSZ_TIPOAS", "NSZ_CAREAJ"} ) //NSZ_FILIAL+NSZ_COD
					If aAux <> Nil .And. Len(aAux) > 1
						cTipoAssu := aAux[1]
						cAreaJuri := aAux[2]
					EndIf
				EndIf

			Case oModel:GetId() == "JURA095"	
				cProcesso := oModel:GetValue("NSZMASTER", "NSZ_COD")
				If !Empty(cProcesso)
					cTipoAssu := oModel:GetValue("NSZMASTER", "NSZ_TIPOAS")
					cAreaJuri := oModel:GetValue("NSZMASTER", "NSZ_CAREAJ")
				EndIf
		End Case
	EndIf

	If !Empty(cProcesso) .And. !Empty(cTipoAssu)
		//Pega as tabelas relacionadas ao assunto juridico
		aTabelas := JA158RtNYC( cTipoAssu )

		//Pega a comarca
		If Ascan( aTabelas, {|x| AllTrim(x) == "NUQ"} ) > 0

			If oModel:GetId() == "JURA095"
				cComarca := oModel:GetValue("NUQDETAIL", "NUQ_CCOMAR")
			Else
				cComarca := JurGetDados("NUQ", 2, xFilial("NUQ") + cProcesso + "1", "NUQ_CCOMAR" )	//NUQ_FILIAL+NUQ_CAJURI+NUQ_INSATU
			EndIf
		EndIf

		//Monta join e where da comarca
		If !Empty(cComarca)
			cJoin		:= " INNER JOIN " +RetSqlName("NU3")+ " NU3 ON A2_COD = NU3_CCREDE AND A2_LOJA = NU3_LOJA "
			cWhere		:= " NU3_CCOMAR = '" +cComarca+ "' AND NU3.D_E_L_E_T_ = ' ' "
			lContinua	:= .T.
		EndIf

		//Monta join e where da area juridica
		If !Empty(cAreaJuri)

			If lContinua
				cWhere += " AND "
			EndIf

			cJoin		+= " INNER JOIN " +RetSqlName("NVI")+ " NVI ON A2_COD = NVI_CCREDE AND A2_LOJA = NVI_CLOJA " 
			cWhere		+= " NVI_CAREA = '" +cAreaJuri+ "' AND NVI.D_E_L_E_T_ = ' ' " 
			lContinua 	:= .T.
		EndIf

		cTabela := GetNextAlias()



		//Executa query para buscar correspondentes da comarca e area definidos acima
		If lContinua
			cQuery += " SELECT DISTINCT A2_COD, A2_LOJA " 
			cQuery += " FROM " +RetSqlName("SA2")+ " SA2 " 
			cQuery += cJoin
			cQuery += " WHERE SA2.D_E_L_E_T_ = ' ' AND " 
			cQuery += cWhere
			cQuery += " UNION "
		EndIf
		//Executa query para buscar correspondentes que não possuem limitação de Atuação
		cQuery += " SELECT DISTINCT A2_COD, A2_LOJA " 
		cQuery += " FROM " +RetSqlName("SA2")+ " SA2 " 
		cQuery += " WHERE SA2.D_E_L_E_T_ = ' ' " 
		cQuery += " AND SA2.A2_MJURIDI  =  '1' " 
		//filtra correspondentes que não possuem nenhuma limitação de Atuação
		cWhrUnion   += " AND NOT EXISTS (" 
		cWhrUnion   += " SELECT 1 FROM " +RetSqlName("NU3")+ " NU3 " 
		cWhrUnion   += " WHERE NU3.D_E_L_E_T_ = ' ' " 
		cWhrUnion   += " AND   NU3.NU3_LOJA   = SA2.A2_LOJA " 
		cWhrUnion   += " AND   NU3.NU3_CCREDE = SA2.A2_COD ) " 
		cWhrUnion   += " AND NOT EXISTS (" 
		cWhrUnion   += " SELECT 1 FROM " +RetSqlName("NVI")+ " NVI " 
		cWhrUnion   += " WHERE NVI.D_E_L_E_T_ = ' ' " 
		cWhrUnion   += " AND   NVI.NVI_CLOJA  = SA2.A2_LOJA " 
		cWhrUnion   += " AND   NVI.NVI_CCREDE = SA2.A2_COD ) " 
		// filtra correspondentes que possuem restição por Comarca, mas não por Area Jurídica
		cWhrUnion   += " OR ( EXISTS (" 
		cWhrUnion   += " SELECT 1 FROM " +RetSqlName("NU3")+ " NU3 " 
		cWhrUnion   += " WHERE NU3.D_E_L_E_T_ = ' ' " 
		cWhrUnion   += " AND   NU3.NU3_LOJA   = SA2.A2_LOJA " 
		cWhrUnion   += " AND   NU3.NU3_CCREDE = SA2.A2_COD  " 
		cWhrUnion   += " AND   NU3.NU3_CCOMAR = '" +cComarca+ "' ) " 
		cWhrUnion   += " AND NOT EXISTS (" 
		cWhrUnion   += " SELECT 1 FROM " +RetSqlName("NVI")+ " NVI " 
		cWhrUnion   += " WHERE NVI.D_E_L_E_T_ = ' ' " 
		cWhrUnion   += " AND   NVI.NVI_CLOJA  = SA2.A2_LOJA " 
		cWhrUnion   += " AND   NVI.NVI_CCREDE = SA2.A2_COD ) )" 
		// filtra correspondentes que possuem restição por Area Jurídica, mas não por Comarca
		cWhrUnion   += " OR ( NOT EXISTS (" 
		cWhrUnion   += " SELECT 1 FROM " +RetSqlName("NU3")+ " NU3 " 
		cWhrUnion   += " WHERE NU3.D_E_L_E_T_ = ' ' " 
		cWhrUnion   += " AND   NU3.NU3_LOJA   = SA2.A2_LOJA " 
		cWhrUnion   += " AND   NU3.NU3_CCREDE = SA2.A2_COD ) " 
		cWhrUnion   += " AND EXISTS (" 
		cWhrUnion   += " SELECT 1 FROM " +RetSqlName("NVI")+ " NVI " 
		cWhrUnion   += " WHERE NVI.D_E_L_E_T_ = ' ' " 
		cWhrUnion   += " AND   NVI.NVI_CLOJA  = SA2.A2_LOJA " 
		cWhrUnion   += " AND   NVI.NVI_CCREDE = SA2.A2_COD " 
		cWhrUnion   += " AND   NVI.NVI_CAREA = '" +cAreaJuri+ "' ) )"
					
		cQuery += cWhrUnion + " ) FILCOMAREA "

		If !Empty(cCod)
			cQuery += " WHERE FILCOMAREA.A2_COD = '" + cCod + "' "
			cQuery +=   " AND FILCOMAREA.A2_LOJA = '" + cLoja + "'"
		EndIf
			
		cQuery := ChangeQuery(cQuery)

		DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cTabela, .F., .T.)

		If (cTabela)->( !Eof() )

			//Carrega filtro com os correspondentes
			cFiltro := "( "

			While !(cTabela)->( Eof() )
				cFiltro += "(SA2->A2_COD == '" +(cTabela)->A2_COD+ "' .AND. SA2->A2_LOJA == '" +(cTabela)->A2_LOJA+ "') .OR. "
				(cTabela)->( DbSkip() )
			EndDo

			//Finaliza filtro
			cFiltro := SubStr(cFiltro, 1, Len(cFiltro) - 5)
			cFiltro += ")"
		EndIf

		(cTabela)->( DbCloseArea() )
	EndIf

	RestArea( aArea )

Return cFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} J095VldNT0

Validação do campo de contrato - NSZ_CCTFAT
Verifica se o contrato indicado existe para o cliente do processo

@author Jorge Luis Branco Martins Junior
@since 27/06/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J095VldNT0()
Local oModel   := FWModelActive()
Local lRet     := .F.
Local cCliente := oModel:GetValue('NSZMASTER','NSZ_CCLIEN')
Local cLoja    := oModel:GetValue('NSZMASTER','NSZ_LCLIEN')
Local cContr   := oModel:GetValue('NSZMASTER','NSZ_CCTFAT')
Local aCliLoja := {}

If !Empty(cCliente) .And. !Empty(cLoja)

	aCliLoja := JurGetDados('NT0', 1, xFilial('NT0') + cContr, {'NT0_CCLIEN','NT0_CLOJA'})
	If aCliLoja[1] == cCliente .And. aCliLoja[2] == cLoja
		lRet := .T.
	Else
		JurMsgErro(STR0007,,STR0008) // Contrato inválido. -- O contrato deve estar vinculado ao cliente e loja indicado.
	EndIf

Else
	JurMsgErro(STR0007,,STR0009) // Contrato inválido. -- Preencha o cliente e loja antes de preencher o contrato.
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J095WhnNT0

When do campo de contrato - NSZ_CCTFAT
Verifica as seguintes condições para habilitar o campo:
- Inclusão;
- Integração com SIGAPFS estiver ativa - MV_JFTJURI = 1;
- Cliente e Loja estiverem preenchidos;
- No cadastro de cliente deve estar indicado que a criação de casos é automática.

@author Jorge Luis Branco Martins Junior
@since 28/06/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J095WhnNT0()
Local oModel   := FWModelActive()
Local lRet     := .F.
Local nOpc     := 0
Local lIntPFS  := SuperGetMV('MV_JFTJURI',, '1') == '1' // Integração com SIGAPFS.
Local cClien   := ""
Local cLoja    := ""

If oModel <> NIL

	cClien := oModel:GetValue("NSZMASTER","NSZ_CCLIEN")
	cLoja  := oModel:GetValue("NSZMASTER","NSZ_LCLIEN")

	nOpc := oModel:GetOperation() // 3 – Inclusão / 4 – Alteração / 5 - Exclusão

	// O campo de código do contrato só ficará habilitado se:
	// - Inclusão;
	// - Integração com SIGAPFS estiver ativa - MV_JFTJURI = 1;
	// - Cliente e Loja estiverem preenchidos;
	// - No cadastro de cliente deve estar indicado que a criação de casos é automática.
	If nOpc == 3 .And. lIntPFS .And. !Empty(cClien) .And. !Empty(cLoja) .And. !JA095CAut()
		lRet := .T.
	EndIf
EndIf

Return lRet
