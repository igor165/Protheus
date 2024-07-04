#INCLUDE "JURA095_P.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA095_P
Processamento de processos. 

@author Wellington Coelho
@since 25//11/14
@version 1.0
/*/
//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095AtuGed
Função para atualização da base de processos no Worksite
@Parameter cCajuri - Código do assunto jurídico
@Return nil
@author Clóvis Eduardo Teixeira
@since 31/12/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095AtuGed(cCajuri, lEncerra)
	Local aArea        := GetArea()
	Local cAliasQry    := GetNextAlias()
	Local cOldPath     := ''
	Local cNewPath     := ''
	Local cNewServer   := ''
	Local cNewDataBase := ''
	Local cOldServer   := ''
	Local cOldDataBase := ''
	Local nTam         := 0
	Local nPosIni      := 1

	if lEncerra
		cNewServer   := SuperGetMV('MV_JGEDSEN',,'')
		cNewDataBase := SuperGetMV('MV_JGEDDEN',,'')
	Else
		cNewServer   := SuperGetMV('MV_JGEDSER',,'')
		cNewDataBase := SuperGetMV('MV_JGEDDAN',,'')
	End

	BeginSql Alias cAliasQry

		SELECT NUM.NUM_DOC, NUM.NUM_COD
		FROM %Table:NUM% NUM
		WHERE NUM_CENTID     = %Exp:cCajuri%
		AND NUM.NUM_FILIAL = %xFilial:NUM%
		AND NUM.%notDel%
		UNION
		SELECT NUM.NUM_DOC, NUM.NUM_COD
		FROM %Table:NT4% NT4,
		%Table:NUM% NUM
		WHERE NT4.NT4_CAJURI = %Exp:cCajuri%
		AND NUM.NUM_CENTID = NT4.NT4_COD
		AND NT4.NT4_FILIAL = %xFilial:NT4%
		AND NUM.NUM_FILIAL = %xFilial:NUM%
		AND NT4.%notDel%
		AND NUM.%notDel%

	EndSql

	dbSelectArea(cAliasQry)
	(cAliasQry)->(DbgoTop())

	While !(cAliasQry)->(EOF())
		cOldPath     := AllTrim((cAliasQry)->NUM_DOC)
		nPosIni      := 1
		nTam         := Len(cOldPath)
		cOldServer   := ''
		cOldDataBase := ''

		While nPosIni <= nTam

			If (SUBSTR(cOldPath,nPosIni,8)) = 'session:'
				nPosIni := nPosIni + 8
				While (nPosIni <= nTam) .And. ((SUBSTR(cOldPath,nPosIni,1)) <> ':')
					cOldServer += SubStr(cOldPath,nPosIni,1)
					nPosIni++
				End
				cNewPath :=  StrTran(cOldPath, cOldServer, cNewServer)
			Endif

			If (SUBSTR(cOldPath,nPosIni,9)) = 'database:'
				nPosIni := nPosIni + 9
				While (nPosIni <= nTam) .And. ((SUBSTR(cOldPath,nPosIni,1)) <> ':')
					cOldDataBase += SubStr(cOldPath,nPosIni,1)
					nPosIni++
				End
				cNewPath :=  StrTran(cNewPath, cOldDataBase, cNewDataBase)
			Endif

			nPosIni++

		End

		NUM->(DBSetOrder(1))
		If NUM->(dbSeek(xFilial('NUM') + (cAliasQry)->NUM_COD))
			RecLock('NUM', .F.)
			NUM->NUM_DOC := cNewPath
			MsUnlock()
		Endif

		(cAliasQry)->(dbSkip())

	End

	(cAliasQry)->(dbCloseArea())
	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR095Rea(cCliente, cLoja, cNumCaso)
Função para reabertura automático do caso
de caso
Uso Geral.
@param  cCliente Código do Cliente
@param  cLoja    Código da Loja
@param  cNumCaso Código do Caso
@author Clóvis Teixeira
@since 09/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR095Rea(cCliente, cLoja, cNumCaso)
	Local aArea     := GetArea()
	Local cAliasQry := GetNextAlias()
	Local lRet      := .T.

	BeginSQL Alias cAliasQry

		SELECT NVE_SITUAC
		FROM %Table:NVE% NVE
		WHERE NVE.NVE_CCLIEN = %Exp:cCliente%
		AND NVE.NVE_LCLIEN = %Exp:cLoja%
		AND NVE.NVE_NUMCAS = %Exp:cNumCaso%
		AND NVE.NVE_FILIAL = %xFilial:NVE%
		AND NVE.%NotDel%

	EndSQL

	dbSelectArea(cAliasQry)

	if (cAliasQry)->NVE_SITUAC == '2'

		If NVE->(dbSeek(xFilial('NVE') +cCliente +cLoja +cNumCaso))
			Begin TransAction
				if RecLock('NVE', .F.)
					NVE->NVE_SITUAC := '1'
					NVE->NVE_DTREAB := Date()
					NVE->NVE_CPART4 := J095RetSig()
					NVE->NVE_DETREA := STR0001
					MsUnlock()
	   		//Grava na fila de sincronização a alteração
					J170GRAVA("NVE", xFilial("NVE") + NVE->NVE_CCLIEN + NVE->NVE_LCLIEN + NVE->NVE_NUMCAS, "4")
				Endif
			End TransAction
		Endif
	Endif

	(cAliasQry)->(dbCloseArea())

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095EncAut(oModel)
Encerra o caso automáticamente ao encerrar o processo.
Uso no cadastro de Processos.
@param  oModel Modelo de dados do cadastro de processo
@return lRet
@author Clóvis Eduardo Teixeira
@since 24/02/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095EncAut(oModel)
Local aArea      := GetArea()
Local cCliente   := oModel:GetValue('NSZMASTER','NSZ_CCLIEN')
Local cLoja      := oModel:GetValue('NSZMASTER','NSZ_LCLIEN')
Local cNumCas    := oModel:GetValue('NSZMASTER','NSZ_NUMCAS')
Local cDtEnc     := oModel:GetValue('NSZMASTER','NSZ_DTENCE')
Local cMotivoEnc := oModel:GetValue('NSZMASTER','NSZ_CMOENC')
Local cDetalhe   := JurGetDados( "NQI", 1, xFilial("NQI") + cMotivoEnc, "NQI_DESC" ) // NQI_FILIAL + NQI_COD
Local lRet       := .T.
Local lEnc       := .T.
Local cAliasQry  := GetNextAlias()

	BeginSql Alias cAliasQry

		SELECT NSZ_SITUAC
		FROM %Table:NSZ% NSZ
		WHERE NSZ_CCLIEN = %Exp:cCliente%
		AND NSZ_LCLIEN  = %Exp:cLoja%
		AND NSZ_NUMCAS = %Exp:cNumCas%
		AND NSZ_FILIAL = %xFilial:NSZ%
		AND NSZ.%NotDel%

	EndSql

	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())

	While !(cAliasQry)->( EOF())
		if (cAliasQry)->NSZ_SITUAC == '1'
			lEnc := .F.
			Exit
		Endif
		(cAliasQry)->( dbSkip())
	End

	If NVE->(dbSeek(xFilial('NVE') +cCliente +cLoja +cNumCas)) .And. lEnc
		Begin TransAction
			if RecLock('NVE', .F.)
				NVE->NVE_SITUAC := '2'
				NVE->NVE_DTENCE := cDtEnc
				NVE->NVE_CPART3 := J095RetSig()
				NVE->NVE_DETENC := cDetalhe
				MsUnlock()
   				//Grava na fila de sincronização a alteração
				J170GRAVA("NVE", xFilial("NVE") + NVE->NVE_CCLIEN + NVE->NVE_LCLIEN + NVE->NVE_NUMCAS, "4")
			Else
				lRet := .F.
				JurMsgErro(STR0002)
			Endif
		End TransAction
	Else
		lRet := .F.
		JurMsgErro(STR0003)
	Endif

	(cAliasQry)->( dbCloseArea())

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095NCaso()
Função responsável pela geração automática de Caso
Uso no cadastro de Processos.
@return lRet
@author Clóvis Eduardo Teixeira
@since 07/01/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095NCaso(nOpcNVE)

	Local aArea      := GetArea()
	Local oModel     := Nil
	Local oModelNSZ  := Nil
	Local oAux       := Nil
	Local oStruct    := Nil
	Local oModelNT0  := Nil
	Local oModelNUT  := Nil
	Local aAux       := {}
	Local aCampos    := {}
	Local nI         := 0
	Local nPos       := 0
	Local lRet       := .T.
	Local lNT0       := .T.
	Local cNumCas    := ''
	Local cCliente   := ''
	Local cLoja      := ''
	Local cPart      := ''
	Local cSigla     := ''
	Local cCajuri    := ''
	Local cCdEscCli  := ''
	Local cErro      := ''
	Local cErrOr     := ''
	Local cIdioma    := ''
	Local cContrato  := ''
	Local lIntPFS    := SuperGetMV('MV_JFTJURI',, '1') == '1'  //integração com SIGAPFS.
	Local cLojaAuto  := SuperGetMv( "MV_JLOJAUT" , .F. , "2" ,  ) // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

	Default nOpcNVE  := 3

	oModelNSZ	:= FWModelActive()
	cCliente	:= oModelNSZ:GetValue("NSZMASTER","NSZ_CCLIEN")
	cLoja     	:= oModelNSZ:GetValue("NSZMASTER","NSZ_LCLIEN")
	
	If (cLojaAuto == "1" .AND. cLoja <> JurGetLjAt())
		lRet   := .F.
		cErrOr := "JA095NCaso()"
		cErro  := I18N(STR0042, {RetTitle("NSZ_LCLIEN"),JurGetLjAt()})//"Para geração de casos automáticos com o parâmetro MV_JLOJAUT ativo,
		                                                              //é necessário que o campo '#1' do Cliente seja igual a '#2'!"
	EndIf
	
	If lRet
		cCajuri   	:= oModelNSZ:GetValue("NSZMASTER","NSZ_COD")
		cPart       := oModelNSZ:GetValue("NSZMASTER","NSZ_CPART1")
		cSigla		:= JurGetDados("RD0",1,xFilial("RD0")+cPart,"RD0_SIGLA")
		cCdEscCli	:= JurGetDados("NUH",1,xFilial("NUH")+cCliente+cLoja,"NUH_CESCR")
		cIdioma     := JurGetDados("NUH",1,xFilial("NUH")+cCliente+cLoja,"NUH_CIDIO")
		cAreaJuri  	:= oModelNSZ:GetValue("NSZMASTER","NSZ_CAREAJ")
		cContrato   := IIf(oModelNSZ:GetModel('NSZMASTER'):HasField('NSZ_CCTFAT'),oModelNSZ:GetValue("NSZMASTER","NSZ_CCTFAT"),"")
	EndIf

	If lRet .And. Empty(cCliente) .And. Empty(cLoja)
		lRet   := .F.
		cErrOr := ProcName()
		cErro  := STR0004	//Preencha os campos de Cliente/Loja
	EndIf

	If lRet .And. lIntPFS .And. Alltrim(cIdioma) == ""
		lRet   := .F.
		cErrOr := "JURA070"
		cErro  := STR0005	//Necessário preencher o campo 'Cód idio rel' no cadastro do Cliente para geração de casos automáticos!
	EndIf

	If lRet .AND. !IsInCallStack('JA095INC')
	
		//Posiciona no caso na alteração
		If nOpcNVE == 4
			cNumCas := oModelNSZ:GetValue("NSZMASTER", "NSZ_NUMCAS")
			
			DbSelectArea("NVE")
			NVE->( DbSetOrder(1) )	//NVE_FILIAL+NVE_CCLIEN+NVE_LCLIEN+NVE_NUMCAS+NVE_SITUAC
			// Se houver caso, atualiza, senão cria.
			nOpcNVE := Iif(NVE->( DbSeek(xFilial("NVE") + cCliente + cLoja + cNumCas) ), 4, 3)
		EndIf
		
		If lRet
	
			oModel := FWLoadModel("JURA070")
			oModel:SetOperation(nOpcNVE)
			oModel:Activate()
	
			oAux    := oModel:GetModel("NVEMASTER")
			oStruct := oAux:GetStruct()
			aAux	:= oStruct:GetFields()
			
			//Carrega campos que serão incluidos\alterados

			// Trava execução da JA070Numer por conta do Max() + 1
			while !(LockByName("JA070Numer",.T. ,.T. ))
				sleep(250)
			End

			If nOpcNVE == 4
				aAdd( aCampos, {"NVE_TITULO", AllTrim( JA095TCaso(oModelNSZ) )} )
			Else

				cNumCas :=  JA070Numer(cCliente, cLoja)

				aAdd( aCampos, { "NVE_CCLIEN", cCliente } )
				aAdd( aCampos, { "NVE_LCLIEN", cLoja } )
				aAdd( aCampos, { "NVE_NUMCAS", cNumCas })
				aAdd( aCampos, { "NVE_TITULO", AllTrim( JA095TCaso(oModelNSZ) )} )
				aAdd( aCampos, { "NVE_CIDIO" , cIdioma } )
				aAdd( aCampos, { "NVE_ENCHON", '2'     } )
				aAdd( aCampos, { "NVE_ENCDES", '2'     } )
				aAdd( aCampos, { "NVE_ENCTAB", '2'     } )
				aAdd( aCampos, { "NVE_EXITO" , '2'     } )
				aAdd( aCampos, { "NVE_VIRTUA", '2'     } )
				aAdd( aCampos, { "NVE_LANTS",  '1'     } )
				aAdd( aCampos, { "NVE_LANDSP", '1'     } )
				aAdd( aCampos, { "NVE_LANTAB", '1'     } )
		
				//só preenche o revisor se a integração com o sigapfs estiver ativa.
				if (lIntPFS)
					aAdd( aCampos, { "NVE_SIGLA1", cSigla  } )
				EndIf	
				
				aAdd( aCampos, { "NVE_SIGLA2", cSigla  } )
				aAdd( aCampos, { "NVE_COBRAV", '1'      } )
				aAdd( aCampos, { "NVE_DSPDIS", '2'      } )
				aAdd( aCampos, { "NVE_CESCRI", cCdEscCli} )
				aAdd( aCampos, { "NVE_CAREAJ", cAreaJuri} )
			EndIf
			
			For nI := 1 To Len( aCampos )
				If ( nPos := aScan( aAux, {|x| AllTrim(x[3]) == AllTrim(aCampos[nI][1] ) } ) ) > 0
					If !(lAux := oModel:SetValue("NVEMASTER", aCampos[nI][1], aCampos[nI][2] ) )
						lRet := .F.
						Exit
					EndIf
				Endif
			  
			Next nI
	
			If lRet
				If oModel:VldData() .And. oModel:CommitData()
					oModelNSZ:LoadValue("NSZMASTER", "NSZ_NUMCAS", cNumCas)
				Else
					lRet   := .F.
					cErrOr := oModel:GetErrorMessage()[4]
					cErro  := STR0034 + CRLF + JurModErro(oModel) //"Inclusão de caso automático."
				EndIf
			Else
				cErrOr:= oModel:GetErrorMessage()[4]
				cErro := STR0034 + CRLF + JurModErro(oModel) // "Inclusão de caso automático."
			EndIf

			//LIBERA NUMERO DE CASO
			UnLockByName("JA070Numer",.T. ,.T. )
					
			oModel:DeActivate()
			oModel:Destroy()
			oModelNSZ:Activate()
	
			// Inclusão do caso no contrato indicado no campo NSZ_CCTFAT
			If lRet .And. !Empty(cContrato) .And. lIntPFS
				dbSelectArea("NT0")
				NT0->( dbSetOrder(1) )
				lNT0 := NT0->( dbSeek( xFilial( 'NT0' ) + cContrato ) )
				oModelNT0  := FWLoadModel("JURA096")
	
				If lNT0 // Se encontrou o contrato indicado
					oModelNT0:SetOperation(4)
					oModelNT0:Activate()
	
					//Inclusão do caso no contrato
					oModelNUT := oModelNT0:GetModel("NUTDETAIL")
					
					If !oModelNUT:IsEmpty()
						oModelNUT:AddLine()
					EndIf
					
					If !( oModelNUT:LoadValue('NUT_CCONTR', cContrato ) .And. ;
						  oModelNUT:LoadValue('NUT_CCLIEN', cCliente  ) .And. ;
					      oModelNUT:LoadValue('NUT_CLOJA' , cLoja     ) .And. ;
						  oModelNUT:LoadValue('NUT_CCASO' , cNumCas   ) )
						lRet := .F.
					EndIf
	
					If lRet // Validação do modelo de contrato e commit dos dados
						If ( lRet := oModelNT0:VldData())
							oModelNT0:CommitData()
						Else
							cErrOr := oModelNT0:GetErrorMessage()[4]
							cErro  := STR0043 + CRLF + JurModErro(oModelNT0) // "Inclusão do caso no contrato"
						EndIf
					Else
						cErrOr := oModelNT0:GetErrorMessage()[4]
						cErro  := STR0043 + CRLF + JurModErro(oModelNT0) // "Inclusão do caso no contrato"
					EndIf
					
					// Desativa e destroi o modelo de contratos do faturamento
					oModelNT0:DeActivate()
					oModelNT0:Destroy()
					
					// Ativa o modelo da NSZ
					oModelNSZ:Activate()
				EndIf
			EndIf
		
		EndIf

	Endif
	
	RestArea(aArea)

Return {lRet, cErrOr, cErro, cNumCas}

//----------------------------------------------------------------------
/*/{Protheus.doc} JA095UpdInc(cCajur)
Função que encerra o processo e preenche as informações de encerramento
de acordo com os dados preenchidos no oModel
Uso Geral.
@author Clóvis Eduardo Teixeira
@since 27/10/09
@version 1.0
/*/
//----------------------------------------------------------------------
Function JA095UpdInc(cCajur)
	Local oModel    := FWModelActive()
	
	Local cMoeda    := oModel:GetValue('NSZMASTER','NSZ_CMOFIN')
	Local cVlFinal  := oModel:GetValue('NSZMASTER','NSZ_VLFINA')
	Local cMotivo   := oModel:GetValue('NSZMASTER','NSZ_CMOENC')
	Local cDetalhe  := oModel:GetValue('NSZMASTER','NSZ_DETENC')
	Local cUserEnc  := oModel:GetValue('NSZMASTER','NSZ_USUENC')
	Local aArea     := GetArea()
	Local aAreaNSZ  := NSZ->(GetArea() )
	Local aAreaNT9  := NT9->(GetArea() )
	Local aAreaNUQ  := NUQ->(GetArea() )
	Local lRet      := .T.

	Local cErrOr     := ""
	Local cErro      := ""
	Local cNSZSituac := ""
	Local oNewNSZ    := FWLoadModel( "JURA095" )

	NSZ->(dbSeek(xFilial('NSZ') + cCajur ))

	oNewNSZ:SetOperation( 4 )
	oNewNSZ:Activate()

	If oNewNSZ:GetValue('NSZMASTER','NSZ_SITUAC') <> '2'

		oNewNSZ:SetValue("NSZMASTER", "NSZ_SITUAC" , '2')
		oNewNSZ:SetValue("NSZMASTER", "NSZ_CMOENC" , cMotivo)
		oNewNSZ:SetValue("NSZMASTER", "NSZ_DETENC" , cDetalhe)
		oNewNSZ:SetValue("NSZMASTER", "NSZ_CMOFIN" , cMoeda)
		oNewNSZ:SetValue("NSZMASTER", "NSZ_VLFINA" , cVlFinal)
		oNewNSZ:SetValue("NSZMASTER", "NSZ_USUENC" , cUserEnc)
	
		If ( lRet := oNewNSZ:VldData() )
			oNewNSZ:CommitData()
		Else
			cErrOr := oNewNSZ:GetErrorMessage()[6]
	
			cErro := STR0037 + cCajur + CRLF + CRLF + cErrOr + CRLF + CRLF + STR0038 // "Não foi possível encerrar o processo " / "Deseja encerrá-lo de forma manual?"
	
			// Verifica se o protheus está aberto. E aí sim exibe a mensagem.
			If !IsBlind() 
				If ApMsgYesNo(cErro)
					nExec := FWExecView(STR0039,'JURA095',4,,{||.T.},{||cNSZSituac := oNewNSZ:GetValue("NSZMASTER","NSZ_SITUAC"), .T.},10) //"Processo"

					lRet := nExec == 0 .And. cNSZSituac == "2" // Caso o processo tenha sido encerrado manualmente (Alteração tenha sido confirmada)

				EndIf
			
			EndIf
			
		EndIf
	
	EndIf

	oNewNSZ:DeActivate()
	oNewNSZ:Destroy()
	
	FWModelActive(oModel,.T.)

	RestArea( aAreaNT9 )
	RestArea( aAreaNUQ )
	RestArea( aAreaNSZ )
	RestArea( aArea )

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} JA095Ini(cCajur)
Função inicial para encerramento de desdobramentos automático
Uso Geral.
@param cCajur - Código do Assunto Jurídico
@author Clóvis Eduardo Teixeira
@since 05/11/09
@version 1.0
/*/
//----------------------------------------------------------------------
Function JA095Ini(cCajur)
	Local lRet := .T.

	cCajurPai := JurCodPai(cCajur)
	lRet := JA095EncInc(cCajurPai)	// Verifica os incidentes (recursão)
	
	If cCajurPai <> cCajur
		If !JA095UpdInc(cCajurPai)	// Encerra o processo/incidente
			lRet := .F.
		EndIf
	EndIf
	
	If !lRet
		JurMsgErro(STR0040,,STR0041,.F.) //"Um ou mais processos não foram encerrados!" / "Encerre o(s) processo(s) manualmente."
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VincProc(cCajur,cCajurPai,cTela)
Função utilizada para vincular um incidente ao processo origem
Uso Geral.
@param cCajur - Código do incidente
@param cCajurPi - Código do processo origem
@author Clóvis Eduardo Teixeira
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VincProc(cFilDes, cCajur, cFilOri, cCajurPai, cTela, lMensagem)
	Local cMsg      := ''
	Local lRet      := .T.
	Local oModelNUV := Nil
	Local nRet      := 0
	Local cGravaNUV := SuperGetMV('MV_JUSTVIN',, '5')
	Local oModelAct := FWModelActive()

	Default lMensagem := .T.

	If cTela == '1'
		cMsg := STR0007
	ElseIf cTela == '2'
		cMsg := STR0008
	Else
		cMsg := STR0009
	EndIf

	//Limpa erro anterior do modelo
	If oModelAct <> Nil
		oModelAct:GetErrorMessage(.T.)
	EndIf

	if !Empty(cCajur)

		If lMensagem
			lRet := ApMsgYesNo(cMsg)
		Else
			lRet := .T.
		EndIF
	
		If lRet
  
			if (cGravaNUV $ "1/2/3" .And. cGravaNUV == cTela) .Or. (cGravaNUV == '4') // Validação parâmetro com o preenchimento de 1, 2, 3 ou 4.

				oModelNUV := FWLoadModel("JURA166")
				oModelNUV:SetOperation( 3 )
				oModelNUV:Activate()
		
				oModelNUV:SetValue("NUVMASTER","NUV_FILIAL",cFIlDes )
				oModelNUV:SetValue("NUVMASTER","NUV_CAJURI",cCajur)
				//0 Se o usuário finalizar a operação com o botão confirmar;
				//1 Se o usuário finalizar a operação com o botão cancelar;
				nRet:=FWExecView(STR0033,"JURA166", 3,,{|| .T.}, ,,,,,,oModelNUV ) //"Informe uma justificativa para o relacionamento"
		
			Endif
	
			//Incidentes do Processo
			If cTela == '1' .And. NSZ->(dbSeek(cFilDes + cCajur)) .AND. nRet == 0
				If  lIncdtTOK(cCajurPai, cCajur)
					RecLock('NSZ', .F.)
					NSZ->NSZ_FPRORI := cFilOri
					NSZ->NSZ_CPRORI := cCajurPai
			
					// Ponto de Entrada para maninuplação dos dados de Incidentes.
					If Existblock( 'JA95VINNSZ' )
						Execblock('JA95VINNSZ', .F., .F.,{cFilDes, cCajur, cFilOri, cCajurPai, cTela})
					EndIf

					NSZ->( dbCommit() )
					NSZ->( MsUnlock() )
					ApMsgInfo(STR0010)
				Endif

			//Vinculo entre Processos
			ElseIf cTela == '2' .AND. nRet == 0
				RecLock('NVO', .T.)
				NVO->NVO_FILIAL	 := xFilial('NVO')
				NVO->NVO_FILORI := cFilOri
				NVO->NVO_CAJUR1 := cCajurPai
				NVO->NVO_FILDES := cFIlDes
				NVO->NVO_CAJUR2 := cCajur

				NVO->( dbCommit() )
				NVO->( MsUnlock() )

				RecLock('NVO', .T.)
				NVO->NVO_FILIAL	:= xFilial('NVO')
				NVO->NVO_FILDES := cFilOri
				NVO->NVO_CAJUR2 := cCajurPai
				NVO->NVO_FILORI := cFilDes
				NVO->NVO_CAJUR1 := cCajur

				NVO->( dbCommit() )
				NVO->( MsUnlock() )

				ApMsgInfo(STR0010) // "Processo vinculado com sucesso!"

			//Relacionamento entre Processos				
			ElseIf cTela == '3' .AND. nRet == 0
				RecLock('NXX', .T.)
				NXX->NXX_FILIAL	 := xFilial('NXX')
				NXX->NXX_FILORI := cFilOri
				NXX->NXX_CAJURO := cCajurPai
				NXX->NXX_FILDES := cFilDes
				NXX->NXX_CAJURD := cCajur
				NXX->( dbCommit() )
				NXX->( MsUnlock() )

				RecLock('NXX', .T.)
				NXX->NXX_FILIAL	 := xFilial('NXX')
				NXX->NXX_FILDES := cFilOri
				NXX->NXX_CAJURD := cCajurPai
				NXX->NXX_FILORI := cFilDes
				NXX->NXX_CAJURO := cCajur
				NXX->( dbCommit() )
				NXX->( MsUnlock() )

				ApMsgInfo(STR0011)//'Processo Relacionado com Sucesso'
			Endif
		Else
			JurMsgErro(STR0012) //"O código do assunto júridico não foi localizado. Operação cancelada."
		Endif
	End

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095DEL(cFilDes, cCajur, cFilOri, cCajurPai, cTela)
Função para desvincular um incidente de seu processo origem
@Return lRet	.T./.F. As informações são válidas ou não
@author Clóvis Eduardo Teixeira
@since 20/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095DEL(cFilDes, cCajur, cFilOri, cCajurPai, cTela)
	Local cMsgConf := ''
	Local cMsgErro := ''
	local lErro	:= .F.

	If cTela == '1'
		cMsgConf := STR0013
		cMsgErro := STR0014
	ElseIf cTela == '2'
		cMsgConf := STR0015
		cMsgErro := STR0016
	Else
		cMsgConf := STR0017
		cMsgErro := STR0018
	EndIf

	If !Empty(cCajur) .And. ApMsgYesNo(cMsgConf)
		
		If Existblock( 'J95DELPE' )
			lErro := Execblock('J95DELPE', .F., .F.,{cFilDes, cCajur, cFilOri, cCajurPai, cTela})
		EndIf	

		Do Case
		Case cTela == '1'
			//Exclusão de Incidente
			If NSZ->(dbSeek(cFilDes + cCajur))
				RecLock('NSZ', .F.)
				NSZ->NSZ_CPRORI := ''
				MsUnlock()

				If __lSX8
					ConFirmSX8()
					ApMsgInfo(STR0019)
				EndIf
			Else
				JurMsgErro(STR0006)
			Endif

		Case cTela == '2'
			//Exclusão de Vinculo
			// Pai
			If NVO->(dbSeek(xFilial('NVO') +cFilDes +cCajur +cFilOri +cCajurPai))
				RecLock('NVO', .F.)
				dbDelete()
				MsUnlock()
			Else
				lErro := .T.
			EndIf

			// Filho
			If NVO->(dbSeek(xFilial('NVO') +cFilOri +cCajurPai +cFilDes +cCajur))
				RecLock('NVO', .F.)
				dbDelete()
				MsUnlock()
			Else
				lErro := .T.
			EndIf

			If lErro
				JurMsgErro(STR0006)// 'Erro ao desvincular o processo'
			Else
				If __lSX8
					ConFirmSX8()
					ApMsgInfo(STR0020)
				EndIf
			EndIf

		Case cTela == '3'
			// Relacinados
			// Pai
			If NXX->(dbSeek(xFilial('NXX') +cFilOri +cCajurPai +cFilDes +cCajur))
				RecLock('NXX', .F.)
				dbDelete()
				MsUnlock()
			Else
				lErro := .T.
			EndIf

			// Filho
			If NXX->(dbSeek(xFilial('NXX') +cFilDes +cCajur +cFilOri + cCajurPai))
				RecLock('NXX', .F.)
				dbDelete()
				MsUnlock()
			Else
				lErro := .T.
			EndIf

			If lErro
				JurMsgErro(STR0021)//'Erro ao desvincular os processos'
			Else
				If __lSX8
					ConFirmSX8()
					ApMsgInfo(STR0020)
				EndIf
			EndIf

		End Case

	ElseIf Empty(cCajur)
		JurMsgErro( cMsgErro )
	EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095ALT(cFilOri, cCajur, cTela)
Função para visualização e alteração do Incidente
@Return lRet	.T./.F. As informações são válidas ou não
@sample JA095ALT(NSZ->NSZ_COD)
@author Clóvis Eduardo Teixeira
@since 20/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095ALT(cFilOri, cCajur, cTela)
	Local cRotina  := 'JURA095'
	Local cMsg       := ''
	Local cMsgErro  := ''
	Local cTipoAS   := JurGetDados("NSZ",1,cFilOri + cCajur, "NSZ_TIPOAS")
	Local aShow  := {{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Confirmar"},{.T.,"Fechar"},{.T.,Nil},{.T.,Nil}}

	If cTela == '1'
		cMsg     := STR0022
		cMsgErro := STR0014
	ElseIf cTela == '2'
		cMsg     := STR0023
		cMsgErro := STR0016
	Else
		cMsg     := STR0024
		cMsgErro := STR0018
	EndIf

	If !Empty(cCajur)
		NSZ->(DBSetOrder(1))

		If NSZ->(dbSeek(cFilOri + cCajur))
			INCLUI     := .F.
			ALTERA     := .T.
			c162TipoAs := cTipoAS
			cTipoAsJ   := c162TipoAs

			MsgRun(STR0025, cMsg,{|| FWExecView( cMsg, cRotina, 4,, { || lOk := .T., lOk },,,aShow) }) //Carregando... Incidentes do Processo/Vinculo do Processo
		Endif

	Else
		JurMsgErro( cMsgErro )
	EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095VIS(cFilOri, cCajur, cTela)
Função para visualização do Incidente
@Return lRet	.T./.F. As informações são válidas ou não
@sample JA095VIS(NSZ->NSZ_COD)
@author Clóvis Eduardo Teixeira
@since 20/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095VIS(cFilOri, cCajur, cTela)
	Local cRotina  := 'JURA095'
	Local cMsg     := ''
	Local cMsgErro := ''
	Local cTipoAS  := JurGetDados("NSZ",1,cFilOri + cCajur, "NSZ_TIPOAS")
	Local aShow  := {{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Confirmar"},{.T.,"Fechar"},{.T.,Nil},{.T.,Nil}}

	If cTela == '1'
		cMsg     := STR0022
		cMsgErro := STR0014
	ElseIf cTela == '2'
		cMsg     := STR0023
		cMsgErro := STR0016
	Else
		cMsg     := STR0024
		cMsgErro := STR0018
	EndIf

	If !Empty(cCajur)
		NSZ->(DBSetOrder(1))
	
		c162TipoAs := cTipoAS
		cTipoAsJ   := c162TipoAs
	
		INCLUI := .F.
		ALTERA := .F.

		If NSZ->(dbSeek(cFilOri + cCajur))
			MsgRun(STR0025, cMsg,{|| FWExecView( cMsg, cRotina, 1,, { || lOk := .T., lOk },,,aShow) }) //Carregando... Incidentes do Processo/Vinculo do Processo
		Endif

	Else
		JurMsgErro( cMsgErro )
	EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095INC(cTpAssJur, cAsJROri, cTelaOr)
Função que exibe a tela de incidentes.
@parame cTpAssJur --> Codigo do tipo de assunto jurídico
@Return lRet NIL
@sample
@author Clóvis Eduardo Teixeira
@since 20/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA095INC(cTpAssJur, cAsJROri, cTelaOr, oM)
	Local nExec	    := 99
	Local cRotina     := 'JURA095'
	Local nOper       := 3
	Local cMsg        := ''
	Local oMNew       := nil
	Local oMNT9       := nil
	Local oMNT9New    := nil
	Local nI          := 0
	Local cCajVinc    := ''
	Local aShow       := {{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Confirmar"},{.T.,"Fechar"},{.T.,Nil},{.T.,Nil}}
	Local bOk         := {|| IIF(nOper == 3,cCajVinc := oMNew:GetValue("NSZMASTER","NSZ_COD"),), .T.}
	Local cNszTipoAs  := oM:GetValue('NSZMASTER','NSZ_TIPOAS')
	Local lEnvAut     := (SuperGetMV('MV_JENVENT',, '2') == '1')
	
	Private cAssJur   := oM:GetValue('NSZMASTER','NSZ_COD')
	Private cFilOri   := oM:GetValue('NSZMASTER','NSZ_FILIAL')

	Private cComarc

	Default cTpAssJur	 := ''
	Default cAsJROri	 := ''
	Default cTelaOr	 := ''

	If cTelaOr == '1'
		cMsg     := STR0022
	ElseIf cTelaOr == '2'
		cMsg     := STR0023
	Else
		cMsg     := STR0024
	EndIf

//<-- Se o campo NUQ_CCOMAR existir em NUQDETAIL e o perfil não forem dos tipos: Consultivo (05). Licitações (10) ou Marcas e Paten (11) não popula a variavel.-->
	If ( oM:GetModel('NUQDETAIL') <> NIL .AND. oM:GetModel('NUQDETAIL'):HasField('NUQ_CCOMAR') ).AND. !(c162TipoAs $ "005/010/011")
		cComarc   := oM:GetValue('NUQDETAIL','NUQ_CCOMAR')
	EndIF

	INCLUI := .T.
	ALTERA := .F.

	cTipoAsJ   := cNszTipoAs
	c162TipoAs := /*cNszTipoAs*/cTpAssJur

	If  c162TipoAs > '050'
		c162TipoAs := JurGetDados('NYB', 1, xFilial('NYB') + c162TipoAs, 'NYB_CORIG')
	EndIf

	oMNew := FWLoadModel( cRotina ) // Cria um model JURA095 para possibilitar a alteração da variavel cCajVinc sem que ela seja Static
	oMNew:SetOperation( nOper )
	oMNew:Activate()
	oMNew:SetValue("NSZMASTER","NSZ_TIPOAS",cNszTipoAs)
	
	oMNew:SetValue("NSZMASTER","NSZ_CPRORI",oM:GetValue('NSZMASTER','NSZ_COD'))
	oMNew:SetValue("NSZMASTER","NSZ_NPRORI",oM:GetValue('NSZMASTER','NSZ_NUMPRO'))
	oMNew:SetValue("NSZMASTER","NSZ_FILIAL",oM:GetValue('NSZMASTER','NSZ_FILIAL'))
	oMNew:SetValue("NSZMASTER","NSZ_CGRCLI",oM:GetValue('NSZMASTER','NSZ_CGRCLI'))
	oMNew:SetValue("NSZMASTER","NSZ_CCLIEN",oM:GetValue('NSZMASTER','NSZ_CCLIEN'))
	oMNew:SetValue("NSZMASTER","NSZ_LCLIEN",oM:GetValue('NSZMASTER','NSZ_LCLIEN'))
	oMNew:LoadValue("NSZMASTER","NSZ_NUMCAS",oM:GetValue('NSZMASTER','NSZ_NUMCAS'))
	oMNew:SetValue("NSZMASTER","NSZ_CESCRI",oM:GetValue('NSZMASTER','NSZ_CESCRI'))
	
	oMNew:SetValue("NSZMASTER","NSZ_CAREAJ",oM:GetValue('NSZMASTER','NSZ_CAREAJ'))
	oMNew:SetValue("NSZMASTER","NSZ_CSUBAR",oM:GetValue('NSZMASTER','NSZ_CSUBAR'))
	oMNew:SetValue("NSZMASTER","NSZ_CPART1",oM:GetValue('NSZMASTER','NSZ_CPART1'))
	oMNew:SetValue("NSZMASTER","NSZ_CPART2",oM:GetValue('NSZMASTER','NSZ_CPART2'))
	oMNew:SetValue("NSZMASTER","NSZ_CPART3",oM:GetValue('NSZMASTER','NSZ_CPART3'))
	
	oMNew:SetValue("NSZMASTER","NSZ_SIGLA1",oM:GetValue('NSZMASTER','NSZ_SIGLA1'))
	oMNew:SetValue("NSZMASTER","NSZ_SIGLA2",oM:GetValue('NSZMASTER','NSZ_SIGLA2'))
	oMNew:SetValue("NSZMASTER","NSZ_SIGLA3",oM:GetValue('NSZMASTER','NSZ_SIGLA3'))
	
	oMNT9 := oM:GetModel('NT9DETAIL')
	
	If oMNT9 <> Nil	// Pula quando o Tipo de Assunto Jurídico não tiver tabela de Envolvidos

		oMNT9New := oMNew:GetModel( 'NT9DETAIL' )
		
		for nI := 1 to oMNT9:Length(.T.)
			If oMNT9New:AddLine() == nI
				If lEnvAut //VALIDA SE ESTA EM USO OS ENVOLVIDOS TABELADOS	
						J105SetDados(oMNT9:GetValue("NT9_ENTIDA", nI),oMNT9:GetValue("NT9_CODENT", nI))
						oMNT9New:SetValue("NT9_FILIAL",oMNT9:GetValue("NT9_FILIAL", nI))
						oMNT9New:LoadValue("NT9_ENTIDA",oMNT9:GetValue("NT9_ENTIDA", nI))
						oMNT9New:SetValue("NT9_CODENT",oMNT9:GetValue("NT9_CODENT", nI))
						oMNT9New:SetValue("NT9_PRINCI",oMNT9:GetValue("NT9_PRINCI", nI))
						oMNT9New:SetValue("NT9_TIPOEN",oMNT9:GetValue("NT9_TIPOEN", nI))
						oMNT9New:SetValue("NT9_CTPENV",oMNT9:GetValue("NT9_CTPENV", nI))					
				Else
						oMNT9New:SetValue("NT9_FILIAL",oMNT9:GetValue("NT9_FILIAL", nI))
						oMNT9New:SetValue("NT9_TIPOCL",oMNT9:GetValue("NT9_TIPOCL", nI))
						If oMNT9:GetValue("NT9_TIPOCL", nI) == '1'
							oMNT9New:SetValue("NT9_CEMPCL",oMNT9:GetValue("NT9_CEMPCL", nI))
							oMNT9New:SetValue("NT9_LOJACL",oMNT9:GetValue("NT9_LOJACL", nI))
						ElseIf oMNT9:GetValue("NT9_TFORNE", nI) == '1'
							oMNT9New:SetValue("NT9_CFORNE",oMNT9:GetValue("NT9_CFORNE", nI))
							oMNT9New:SetValue("NT9_LFORNE",oMNT9:GetValue("NT9_LFORNE", nI))
						Else
							oMNT9New:LoadValue("NT9_NOME",oMNT9:GetValue("NT9_NOME", nI))
						endIf
						oMNT9New:SetValue("NT9_PRINCI",oMNT9:GetValue("NT9_PRINCI", nI))
						oMNT9New:SetValue("NT9_TFORNE",oMNT9:GetValue("NT9_TFORNE", nI))
						oMNT9New:SetValue("NT9_TIPOEN",oMNT9:GetValue("NT9_TIPOEN", nI))
						oMNT9New:SetValue("NT9_CTPENV",oMNT9:GetValue("NT9_CTPENV", nI))
						oMNT9New:SetValue("NT9_TIPOP",oMNT9:GetValue("NT9_TIPOP", nI))					
				EndIf
			EndIf
			lRet := oMNT9New:VldData()
		next nI
	Endif

	MsgRun(STR0025, cMsg,{|| nExec := FWExecView(cMsg,cRotina, nOper,,{|| lRet := .T., lRet},bOk,,aShow,,,,oMNew) }) //"Carregando..." e "Incidentes do Processos"

//<- Se a execução do FWExecView for bem sucedida, chame a função para vincular o novo processo cadastrado ->
	If nExec == 0
		cAsJROri := IIF( EMPTY(cAsJROri), cAssJur, cAsJROri) 	// Codigo anterior a FWExecView
		VincProc(cFilOri, cCajVinc, cFilOri, cAsJROri, cTelaOr, .F. )
	EndIf

//<- Limpa a variavel Static que conterá o código de Cajuri "filho", ou seja do registro cadastrado pelo FWExecView ->
	cCajVinc := ''
	nExec	  := 99

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA095VIN(cFilOri, cCajurPai, cTipoAs, cTela)
Função para vincular como incidente um processo já cadastrado
@param cFilOri   = Filial do processo origem
@param cCajurPai = Código do processo origem
@param cTipoAs   = Tipo de assunto do processo origem
@param cTela     =  1 - Incidentes 
					2 - Vinculados 
					3 - Relacionados
@Return lRet	.T./.F. As informações são válidas ou não
@sample
@author Clóvis Eduardo Teixeira
@since 20/10/09
@version 1.0  
/*/  
//-------------------------------------------------------------------
Function JA095VIN(cFilOri, cCajurPai, cTipoAs, cTela)
Local oGetNumPro  := Nil
Local cGetNumPro  := CriaVar('NSZ_NUMPRO', .F.)
Local oGetCodPro  := Nil
Local cGetCodPro  := CriaVar('NSZ_COD'   , .F.)
Local oGetCaso    := Nil 
Local cGetCaso    := CriaVar('NSZ_NUMCAS', .F.)
Local oGetAJ      := Nil
Local cGetAJ      := CriaVar('NSZ_TIPOAS', .F.)
Local oGetDetail  := Nil
Local cGetDetail  := CriaVar('NSZ_DETALH', .F.)
Local oGetTombo   := NIL
Local cGetTombo   := CriaVar('NSZ_TOMBO' , .F.)
Local oDescPro    := NIL
Local oDescCli    := Nil
Local oDescCaso   := Nil
Local oDescDetail := Nil
Local oDescTombo  := Nil
Local oDescLoja   := Nil
Local oDescAJ     := Nil
Local oPnlPesq    := Nil
Local oPnlList    := Nil
Local oPnlBtn     := Nil
Local oDlg        := Nil
Local oLbx        := Nil
Local cTitle      := STR0028 //"Vincular ao Processo"
Local lHasNUQ     := ("NUQ" $ JA095TabAj(cTipoAs))

Private oGetClien := NIL
Private cGetClien := CriaVar('NSZ_CCLIEN', .F.)
Private oGetLoja  := NIL
Private cGetLoja  := CriaVar('NSZ_LCLIEN', .F.)

	// Define o Título
	If cTela == '2'
		cTitle := STR0027 //"Vincular incidente ao Processo"
	ElseIf cTela == '3'
		cTitle := STR0046 //"Relacionar Processos"
	Endif

	//"Pesquisa de Processos"
	DEFINE MSDIALOG oDlg TITLE cTitle FROM 0, 0 TO 400, 600 OF oDlg PIXEL 
	oPnlPesq       := TPanel():New(0,0,'',oDlg,,,,,,0,50)
	oPnlList       := TPanel():New(0,0,'',oDlg,,,,,,0,00)
	oPnlBtn        := TPanel():New(0,0,'',oDlg,,,,,,0,20)
	oPnlPesq:Align := CONTROL_ALIGN_TOP
	oPnlList:Align := CONTROL_ALIGN_ALLCLIENT
	oPnlBtn:Align  := CONTROL_ALIGN_BOTTOM

	//Assuntos Jurídicos que tem NUQ 
	If lHasNUQ .Or. cTela == '3'
		oDescPro   := TSay():New(003,170,{||J95TitCpo('NSZ_NUMPRO',cTipoAs)},oPnlPesq,,,,,,.T.,,,60,10)
		oGetNumPro := TGet():New(010,170,{|u| if(Pcount()>0, cGetNumPro := u, cGetNumPro)},oPnlPesq,075,0,;
								PesqPict('NSZ','NSZ_NUMPRO'),{|| },,,,,,.T.,,,,,,,,,,'cGetNumPro')
	Endif

	oDescCli  :=  TSay():New(003,010,{||J95TitCpo('NSZ_CCLIEN',cTipoAs)},oPnlPesq,,,,,,.T.,,,60,10)
	oGetClien :=  TGet():New(010,010,{|u| if(Pcount()>0, cGetClien  := u, cGetClien )},oPnlPesq,050,0,;
							PesqPict('NSZ','NSZ_CCLIEN'),{|| },,,,,,.T.,,,,,,,,,'SA1','cGetClien',,,,.T.)

	oDescLoja :=  TSay():New(003,065,{||J95TitCpo('NSZ_LCLIEN',cTipoAs)},oPnlPesq,,,,,,.T.,,,40,10)
	oGetLoja  :=  TGet():New(010,065,{|u| if(Pcount()>0, cGetLoja  := u, cGetLoja )},oPnlPesq,040,0,;
							PesqPict('NSZ','NSZ_LCLIEN'),{|| },,,,,,.T.,,,,,,,,,,'cGetLoja',,,,.T.)

	oDescCaso :=  TSay():New(003,115,{||J95TitCpo('NSZ_NUMCAS',cTipoAs)},oPnlPesq,,,,,,.T.,,,40,10)
	oGetCaso  :=  TGet():New(010,115,{|u| if(Pcount()>0, cGetCaso   := u, cGetCaso  )},oPnlPesq,050,0,;
							PesqPict('NSZ','NSZ_NUMCAS'),{|| },,,,,,.T.,,,,,,,,,'NVEPES','cGetCaso',,,,.T.)

	If cTela == '3' //"Relacionados"

		oDescPro   := TSay():New(023,010,{||J95TitCpo("NSZ_COD",cTipoAs)},oPnlPesq,,,,,,.T.,,,60,10)
		oGetCodPro := TGet():New(030,010,{|u| if(Pcount()>0, cGetCodPro := u, cGetCodPro)},oPnlPesq,075,0,;
								PesqPict('NSZ','NSZ_COD'),{|| },,,,,,.T.,,,,,,,,,'JURNSZ','cGetCodPro',,,,.T.)

		oDescAJ    := TSay():New(023,115,{||J95TitCpo('NSZ_TIPOAS',cTipoAs)},oPnlPesq,,,,,,.T.,,,80,10)
		oGetAJ     := TGet():New(030,115,{|u| if(Pcount()>0, cGetAJ   := u, cGetAJ  )},oPnlPesq,025,0,;
							PesqPict('NSZ','NSZ_TIPOAS'),{|| },,,,,,.T.,,,,,,,,,'NYBALL','cGetAJ',,,,.T.)
	Else
		If cTipoAs != '008' // Societário
			oDescDetail := TSay():New(023,010,{||J95TitCpo('NSZ_DETALH',cTipoAs)},oPnlPesq,,,,,,.T.,,,40,10)
			oGetDetail  := TMultiget():New(030,10,{|u| if(Pcount()>0, cGetDetail := u, cGetDetail) },oPnlPesq,135,12,,,,,,.T.)

			oDescTombo	:= TSay():New(023,150,{||J95TitCpo('NSZ_TOMBO',cTipoAs)},oPnlPesq,,,,,,.T.,,,40,10)
			oGetTombo   := TGet():New(030,150,{|u| if(Pcount()>0, cGetTombo  := u, cGetTombo )},oPnlPesq,100,0,;
										PesqPict('NSZ','NSZ_TOMBO'),{|| },,,,,,.T.,,,,,,,,,,'cGetTombo')
		Endif
	EndIf
	
	oLbx := MsNewGetDados():New(000,000,000,000,0,,,,,,,,,,oPnlList,ListaHead(cTipoAs),{})
	oLbx:oBrowse:blDblClick := {||VincProc(GetListaCod(oLbx,'NSZ_FILIAL'), GetListaCod(oLbx), cFilOri, cCajurPai,cTela), oDlg:End()}
	oLbx:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	If cTela == '3' //"Relacionados"
			oLbx:oBrowse:lReadOnly := .T.
	EndIf
		
	oLbx:ACOLS := {}
	oLbx:Refresh()
	
	@ oPnlPesq:nTop+ 010, oPnlPesq:nLeft+ 263 Button oBtnPesquisar Prompt STR0029; //Botão Pesquisar
		Size 25,12 Of oPnlPesq Pixel ;
		Action AtuLista(oLbx, cTipoAs, cCajurPai, cTela, cGetNumPro, cGetClien, cGetLoja,;
						 cGetCaso, cGetDetail, cGetTombo, cGetCodPro, cGetAJ, cFilOri) 

	@ oPnlPesq:nTop+ 030, oPnlPesq:nLeft+ 263 Button oBtnLimpar Prompt STR0030; //Botão Limpar
		Size 25,12 Of oPnlPesq Pixel ;
		Action {||cGetNumPro   := CriaVar('NSZ_NUMPRO', .F.),;
					cGetClien  := CriaVar('NSZ_CCLIEN', .F.),;
					cGetLoja   := CriaVar('NSZ_LCLIEN', .F.),;
					cGetCaso   := CriaVar('NSZ_NUMCAS', .F.),;
					cGetAJ     := CriaVar('NSZ_TIPOAS', .F.),;
					cGetCodPro := CriaVar('NSZ_COD'	 , .F.),;
					cGetDetail := CriaVar('NSZ_DETALH', .F.),;
					cGetTombo  := CriaVar('NSZ_TOMBO' , .F.) }

	@ oPnlBtn:nTop + 005, oPnlBtn:nLeft + 221 Button oBtnVincular Prompt STR0031; //Botão Vincular
		Size 25,12 Of oPnlBtn  Pixel;
		Action Eval({||VincProc(GetListaCod(oLbx,'NSZ_FILIAL'), GetListaCod(oLbx), cFilOri, cCajurPai,cTela), oDlg:End()})

	@ oPnlBtn:nTop + 005, oPnlBtn:nLeft + 273 Button oBtnSair Prompt STR0032; //Botão Sair
		Size 25,12 Of oPnlBtn  Pixel;
		Action oDlg:End()

	Activate MsDialog oDlg Center

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA95PRVT
Realiza o cálculo da previsão de término do processo
Uso no cadastro de Processo.

@Return dData	 	Data de previsão de término

@author Juliana Iwayama Velho
@since 01/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA95PRVT()
	Local dData     := ctod('')
	Local nCt       := 0
	Local aArea     := GetArea()
	Local oModel    := FWModelActive()
	Local oModelNUQ := oModel:GetModel('NUQDETAIL')

	For nCt := 1 To oModelNUQ:GetQtdLine()

		If oModelNUQ:GetValue('NUQ_INSATU',nCt) == '1'

			If oModelNUQ:GetValue('NUQ_EXECUC',nCt) == '1'

				dData := JurPrxData(oModelNUQ:GetValue('NUQ_DTDECI',nCt),1)

			ElseIf oModelNUQ:GetValue('NUQ_INSTAN',nCt) == '1' .And. !Empty(GetMV('MV_JQMES1A'))

				dData := JurPrxData(oModelNUQ:GetValue('NUQ_DTDECI',nCt), GetMV('MV_JQMES1A'))

			ElseIf oModelNUQ:GetValue('NUQ_INSTAN',nCt) == '2' .And. !Empty(GetMV('MV_JQMES2A'))

				dData := JurPrxData(oModelNUQ:GetValue('NUQ_DTDECI',nCt), GetMV('MV_JQMES2A'))

			ElseIf oModelNUQ:GetValue('NUQ_INSTAN',nCt) == '3' .And. !Empty(GetMV('MV_JQMESTS'))

				dData := JurPrxData(oModelNUQ:GetValue('NUQ_DTDECI',nCt), GetMV('MV_JQMESTS'))

			ElseIf !Empty(FwFldGet('NUQ_DTDIST')) .And. !Empty(GetMV('MV_JQMESDT'))

				dData := JurPrxData(FwFldGet('NUQ_DTDIST'), GetMV('MV_JQMESDT'))

			EndIf

			Exit

		EndIf

	Next

	RestArea( aArea )

Return dData

//-------------------------------------------------------------------
/*/{Protheus.doc} J95COPYMOD
Copia os dados do modelo anterior para o modelo atual.
Uso geral.

@author Antonio Carlos Ferreira
@since 27/02/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J95COPYMOD(oModelANT, oModelATU, cModelo, aModGrids)

	Local nA    := 0    //Contador para o for/next
	Local nX    := 0
	Local nLin  := 0
	Local nPos  := 0

	Local oAux1    := nil
	Local oAux2    := nil
	Local oStruct1 := nil
	Local oStruct2 := nil
	Local aAux1    := {}
	Local aAux2    := {}

	If  (oModelANT == nil) .Or. (oModelATU == nil)
		Return .T.
	EndIf

// Instanciamos apenas referentes às dados
	oAux1 := oModelATU:GetModel( cModelo )
	oAux2 := oModelANT:GetModel( cModelo )

// Obtemos a estrutura de dados
	oStruct1 := oAux1:GetStruct()
	aAux1    := oStruct1:GetFields()

	oStruct2 := oAux2:GetStruct()
	aAux2    := oStruct2:GetFields()

	For nA := 1 To Len(aAux1)
		If  ((nPos := aScan(aAux2,{|x| AllTrim( x[3] )== AllTrim(aAux1[nA][3]) } )) > 0) .And. (oModelATU:GetValue(cModelo,aAux1[nA][3]) != oModelANT:GetValue(cModelo,aAux2[nPos][3]))
			oModelATU:LoadValue( cModelo, aAux1[nA][3], oModelANT:GetValue(cModelo, aAux2[nPos][3]) )
		EndIf
	Next nA

	For nX := 1 to Len(aModGrids)

	// Instanciamos apenas referentes às dados
		oAux1 := oModelATU:GetModel( aModGrids[nX][1] )
		oAux2 := oModelANT:GetModel( aModGrids[nX][1] )
	
	// Obtemos a estrutura de dados
		oStruct1 := oAux1:GetStruct()
		aAux1    := oStruct1:GetFields()
	
		oStruct2 := oAux2:GetStruct()
		aAux2    := oStruct2:GetFields()
	
		For nLin := 1 To oAux2:GetQtdLine()
			If  Empty(oModelANT:GetValue(aModGrids[nX][1], aModGrids[nX][2]))
				Loop
			EndIf
	
			If  (nLin > oAux1:GetQtdLine())
				If  (oAux1:AddLine() < nLin)
					Exit
				EndIf
			EndIf
	     
			oAux1:GoLine(nLin)
			oAux2:GoLine(nLin)
	     
			If  oAux2:IsDeleted()
				oAux1:DeleteLine()
			Else
				For nA := 1 To Len(aAux1)
					If  ((nPos := aScan(aAux2,{|x| AllTrim( x[3] )== AllTrim(aAux1[nA][3]) } )) > 0) .And. (oModelATU:GetValue(aModGrids[nX][1],aAux1[nA][3]) != oModelANT:GetValue(aModGrids[nX][1],aAux2[nPos][3]))
						oModelATU:LoadValue( aModGrids[nX][1], aAux1[nA][3], oModelANT:GetValue(aModGrids[nX][1], aAux2[nPos][3]) )
					EndIf
				Next nA
			EndIf
		Next nLin
    
	Next nX

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuLista()
Função utilizada para preencher a lista.

@param oLbx    - Objeto da lista
@param cTipoAs - Tipo de assunto jurídico
@param cCajur  - Código do processo origem
@param cTela   - Tipo de tela: 1 = Incidentes, 2 = Vinculados e 3 = Relacionados
@param cNumPro - Número do processo
@param cClien  - Código do cliente
@param cLoja   - Loja do cliente
@param cCaso   - Número do caso
@param cDetail - Detalhamento do assunto
@param cTombo  - Número do tombo
@param cCodPro - Código do processo
@param cAJ     - Tipo de assunto jurídico
@param cFilOri - Filial do processo origem

@since 19/10/09
/*/
//-------------------------------------------------------------------
Static Function AtuLista(oLbx, cTipoAs, cCajur, cTela, cNumPro,;
		cClien, cLoja, cCaso, cDetail, cTombo, cCodPro, cAJ, cFilOri)

	oLbx:ACOLS := ListaCol(oLbx:aHEADER, cTipoAs, cCajur, cTela, cNumPro,;
		cClien, cLoja, cCaso, cDetail, cTombo, cCodPro, cAJ, cFilOri)
	If cTela == '3'
		If Empty(oLbx:ACOLS)
			oLbx:oBrowse:lReadOnly := .T.
		Else
			oLbx:oBrowse:lReadOnly := .F.
		EndIf
	EndIf
	oLbx:Refresh()
	oLbx:goTop()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ListaHead(cTipoAs)
Função utilizada para configurar o cabeçalho da lista
Uso Geral.

@param cTipoAs Código do tipo de assunto jurídico. Usado para diferenciar as 
colunas do cabeçalho

@Return		aHead	Array com o cabeçalho
@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ListaHead(cTipoAs)
Local aHead  := {}
Local nUsado := 0
Local aCampos:= {'NSZ_FILIAL','NSZ_COD','NSZ_CCLIEN','NSZ_NUMCAS','NSZ_SITUAC'}

	//Assuntos Jurídicos com NUQ
	If "NUQ" $ JA095TabAj(cTipoAs)
		aAdd(aCampos,'NUQ_NUMPRO')
		aAdd(aCampos,'NSZ_PATIVO')
		aAdd(aCampos,'NSZ_PPASSI')
		aAdd(aCampos,'NSZ_TOMBO')
	Endif

	dbSelectArea('SX3')
	SX3->( dbSetOrder(2) )

	For nUsado := 1 to LEN(aCampos)

		SX3->( dbSeek(aCampos[nUsado]) )
		If (X3USO( SX3->X3_USADO ) .AND. cNivel >= SX3->X3_NIVEL) .Or. (X3_CAMPO == 'NSZ_FILIAL')
			aAdd( aHead, { ;
				J95TitCpo(SX3->X3_CAMPO,cTipoAs), ;  // 01 - Titulo
			SX3->X3_CAMPO      , ;    // 02 - Campo
			SX3->X3_PICTURE    , ;    // 03 - Picture
			SX3->X3_TAMANHO    , ;    // 04 - Tamanho
			SX3->X3_DECIMAL    , ;    // 05 - Decimal
			SX3->X3_VALID      , ;    // 06 - Valid
			SX3->X3_USADO      , ;    // 07 - Usado
			SX3->X3_TIPO       , ;    // 08 - Tipo
			SX3->X3_F3         , ;    // 09 - F3
			SX3->X3_CONTEXT    , ;    // 10 - Contexto
			SX3->X3_CBOX       , ;    // 11 - ComboBox
			SX3->X3_RELACAO    , ;    // 12 - Relacao
			SX3->X3_WHEN       , ;    // 13 - Alterar
			SX3->X3_VISUAL     , ;    // 14 - Visual
			SX3->X3_VLDUSER      } )  // 15 - Valid Usuario
		EndIf
	Next

Return aHead

//-------------------------------------------------------------------
/*/{Protheus.doc} ListaCol(aHead, cTipoAs, cCajur, cTela, cNumPro,;
		cClien, cLoja, cCaso, cDetail, cTombo, cCodPro, cAJ, cFilOri)
Função utilizada para preencher a lista.

@param aHead   - Array com o cabeçalho
@param cTipoAs - Tipo de assunto jurídico
@param cCajur  - Código do processo origem
@param cTela   - Tipo de tela: 1 = Incidentes, 2 = Vinculados e 3 = Relacionados
@param cNumPro - Número do processo
@param cClien  - Código do cliente
@param cLoja   - Loja do cliente
@param cCaso   - Número do caso
@param cDetail - Detalhamento do assunto
@param cTombo  - Número do tombo
@param cCodPro - Código do processo
@param cAJ     - Tipo de assunto jurídico
@param cFilOri - Filial do processo origem
Uso Geral.
@author Clóvis Eduardo Teixeira
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ListaCol(aHead, cTipoAs, cCajur , cTela  , cNumPro, cClien;
						,cLoja, cCaso, cDetail, cTombo, cCodPro, cAJ, cFilOri)


Local aCol        := {}
Local aArea       := GetArea()
Local nCols       := 0
Local cLista      := GetNextAlias()
Local nX          := 0
Local nQtd        := 0
Local cSQL        := ''
Local cSelect     := ""
Local cFrom       := ""
Local cWhere      := ""
Local aSQLRest    := {}
Local cNSZAssun   := JurGetDados("NSZ",1,cFilOri+cCajur, "NSZ_TIPOAS")

Default cTipoAs := ''
Default cCajur  := ''
Default cTela   := ''
Default cNumPro := ''
Default cClien  := ''
Default cLoja   := ''
Default cCaso   := ''
Default cDetail := ''
Default cTombo  := ''
Default cCodPro := ''
Default cAJ     := ''

	cSelect := " SELECT NSZ_FILIAL, NSZ_COD, NSZ_CCLIEN, NSZ_LCLIEN, NSZ_NUMCAS, "
	cSelect +=        " NSZ_SITUAC, NSZ_TIPOAS, NSZ_PATIVO, NSZ_PPASSI, NSZ_TOMBO "
	cFrom   := " FROM " + RetSqlName("NSZ") + " NSZ "
	cWhere  := " WHERE NSZ.D_E_L_E_T_ = ' ' "
	cWhere  +=   " AND NSZ.NSZ_COD <> '" + cCaJur + "' "
	cWhere  +=   " AND NSZ.NSZ_FILIAL " + J095SetFil()

	If Empty(cNumPro + cCodPro + cClien + cLoja + cCaso + cAJ + cDetail + cTombo)
		ApMsgInfo(STR0036) //"É preciso preencher pelo menos um filtro da pesquisa."
	Else

		If cTela != '3' //Não é relacionados

			// Mesma família de Tipo de assunto jurídico 
			cFrom += " INNER JOIN (" + FamiliaASJ(IIF(!Empty(cNSZAssun), cNSZAssun, cTipoAs)) + ") ASSJ "
			cFrom +=    " ON (NSZ_TIPOAS = ASSJ.NYB_COD "
			cFrom +=       " AND NSZ_TIPOAS IN (" + JurTpAsPesq(__CUSERID) + "))"

			//Societário
			If cTipoAs == '008'
			
				cFrom += " LEFT JOIN " + RetSqlName("NYJ") + " NYJ"
				cFrom += 	" ON( NSZ.NSZ_COD = NYJ.NYJ_CAJURI"
				cFrom += 		" AND NYJ.NYJ_FILIAL = '" + xFilial("NYJ") + "'"
				cFrom += 		" AND NYJ.NYJ_UNIDAD = '1'"
				cFrom += 		" AND NYJ.D_E_L_E_T_ = ' ')"

			Endif

			//Incidentes
			If cTela == '1'
				cWhere += " AND NSZ.NSZ_CPRORI = ' ' "
			EndIf
		EndIf

		// Aplica Filtros genéricos
		If !Empty(cNumPro) .Or. cTela == '1'
			cSelect += ", NUQ_NUMPRO "
			cFrom += "INNER JOIN " + RetSqlName("NUQ") + " NUQ "
			cFrom +=    " ON ( NSZ_COD = NUQ_CAJURI "
			cFrom +=         " AND NSZ_FILIAL = NUQ_FILIAL "
			cFrom +=         " AND NUQ.D_E_L_E_T_ = ' ' "
			cFrom +=         " AND NUQ.NUQ_INSATU = '1') "
			If !Empty(cNumPro)
				cWhere += " AND "+ JurFormat("NUQ_NUMPRO",.T.,.T.,'NUQ')+" LIKE '%" + STRTRAN(JurLmpCpo( AllTrim( Lower(cNumPro))),'#','')+ "%'"
			EndIf
		Endif

		If !Empty(cDetail)
			cWhere += " AND "+ JurFormat("NSZ_DETALH",.T.,.T.,'NSZ')+" LIKE '%" + STRTRAN(JurLmpCpo( AllTrim( Lower(cDetail))),'#','')+ "%'"
		Endif

		if !Empty(cClien)
			cWhere += " AND NSZ.NSZ_CCLIEN LIKE "+"'%"+ ALLTRIM(cClien) +"%'"
		Endif

		if !Empty(cLoja)
			cWhere += " AND NSZ.NSZ_LCLIEN = '"+cLoja+"' "
		Endif

		if !Empty(cCaso)
			cWhere += " AND NSZ.NSZ_NUMCAS LIKE "+"'%"+ ALLTRIM(cCaso) +"%'"
		Endif

		if !Empty(cTombo)
			cWhere += " AND "+ JurFormat("NSZ_TOMBO",.T.,.T.,'NSZ')+" LIKE '%" + STRTRAN(JurLmpCpo( AllTrim( Lower(cTombo))),'#','')+ "%'"
		Endif

		If !Empty(cCodPro)
			cWhere += " AND NSZ.NSZ_COD = '"+AllTrim(cCodPro)+"'"
		Endif

		If !Empty(cAJ)
			cWhere += " AND NSZ.NSZ_TIPOAS = '"+AllTrim(cAJ)+"'"
		Endif

		// Aplica filtros por tela
		//Incidentes
		if cTela == '1'
		
			cWhere +=   " AND NSZ_TIPOAS = '" +IIF(!Empty(cNSZAssun), cNSZAssun, cTipoAs)  + "'"

		//Vinculados
		Elseif cTela == '2'

			cWhere +=   " AND NSZ.NSZ_COD NOT IN (SELECT NVO_CAJUR1 "
			cWhere +=                           " FROM "+RetSqlName("NVO") + " NVO"
			cWhere +=                           " WHERE NVO.NVO_FILIAL = '"+xFilial("NVO")+"'"
			cWhere +=                             " AND NVO.D_E_L_E_T_ = ' ' "
			cWhere +=                             " AND NVO.NVO_FILDES = '"+cFilOri+"'"
			cWhere +=                             " AND NVO.NVO_CAJUR2 = '"+cCaJur+"')"

		//Relacionados
		Elseif cTela == '3'
			cWhere +=   " AND NSZ.NSZ_COD NOT IN (SELECT NXX_CAJURO "
			cWhere +=                           " FROM "+RetSqlName("NXX")
			cWhere +=                           " WHERE NXX_FILIAL = '"+xFilial("NXX")+"'"
			cWhere +=                             " AND D_E_L_E_T_ = ' ' "
			cWhere +=                             " AND NXX_FILDES = '"+cFilOri+"'"
			cWhere +=                             " AND NXX_CAJURD = '"+cCaJur+"')"
			cWhere +=   " AND NSZ_TIPOAS IN (" + JurTpAsPesq(__CUSERID) + ")"
			cWhere +=   " AND ( NSZ_TIPOAS NOT IN (" + FamiliaASJ(IIF(!Empty(cNSZAssun), cNSZAssun, cTipoAs)) + ") "
			
			If ExistBlock('J95FVINC')
				cWhere += ExecBlock('J95FVINC',.F.,.F.,{cTela})
			EndIf

			cWhere +=  ")"
		Endif
		
		//Atribui condição verificando a restrição de área e escritório
		cWhere += VerRestricao()

		//Adiciona restrição do usuário/pesquisa
		aSQLRest := JA162RstUs()
		If !Empty(aSQLRest)
			cWhere += " AND ("+JA162SQLRt(aSQLRest)+")"
		EndIf

		If ExistBlock('J95FVINC') .And. cTela <> '3'
			cWhere += ExecBlock('J95FVINC',.F.,.F.,{cTela})
		EndIf

		cSQL := ChangeQuery(cSelect + cFrom + cWhere)
		cSQL := StrTran(cSQL,",' '",",''")
		dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cLista, .T., .F.)

		dbSelectArea(cLista)
		(cLista)->(dbGoTop())

		NSZ->(DBSetOrder(1))

		If Empty((cLista)->(NSZ_COD)) .And. (!Empty(cNumPro) .Or. !Empty(cClien) .Or.;
				!Empty(cCaso) .Or. !Empty(cDetail) .Or. !Empty(cTombo))
				Alert(STR0035) //"Não foi localizado nenhum processo com os critérios da sua pesquisa. Tente novamente!"
		Else
			While (cLista)->(!Eof())
				aAdd(aCol,Array(LEN(aHead)+1))
				nCols++
				nQtd++

				For nX := 1 To LEN(aHead)
					NSZ->(dbSeek((cLista)->NSZ_FILIAL+(cLista)->NSZ_COD))
					If ( aHead[nX][10] != "V")
						aCol[nCols][nX] := (cLista)->(FieldGet(FieldPos(aHead[nX][2])))
					Else
						aCol[nCols][nX] := CriaVar(aHead[nX][2],.T.)
					Endif
				Next nX

				aCol[nCols][LEN(aHead)+1] := .F.
				dbSelectArea(cLista)
				(cLista)->(dbSkip())

			End
		Endif

		(cLista)->( dbCloseArea() )
			

		RestArea( aArea )
	EndIf
Return aCol

//-------------------------------------------------------------------
/*/{Protheus.doc} J095SetFil()
Função utilizada para verificar as filiais que o usuário logado tem acesso
@since 24/03/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function J095SetFil()

Local aFilUsr   := JURFILUSR( __CUSERID, 'NSZ' )

Return IIF( VerSenha(114) .or. VerSenha(115), " IN " +  FORMATIN(aFilUsr[1],aFilUsr[2]), " = '" + xFilial("NSZ") + "' " )


/*/{Protheus.doc} FamiliaASJ()
	Rertorna a familia de assuntos jurídicos
	
	@since 19/04/2022
	@version version
	@param cTpAssunto, Assunto a ser pesquisado
	@return cSql, SQL para pesquisa
	
/*/
Static Function FamiliaASJ(cTpAssunto)
Local cSql := "SELECT * FROM ("

	cSql += "SELECT DISTINCT NYB3.NYB_COD "
	cSql +=  " FROM " + RetSqlName("NYB") + " NYB "
	cSql += " INNER JOIN " + RetSqlName('NYB') + " NYB2 ON ("
	cSql +=             "( NYB2.NYB_COD = NYB.NYB_CORIG "
	cSql +=              " OR NYB2.NYB_COD = NYB.NYB_COD ) "
	cSql +=              " AND NYB2.NYB_FILIAL = '" + xFilial("NYB") + "' "
	cSql +=              " AND NYB2.D_E_L_E_T_ = ' ') "
	cSql += " INNER JOIN " + RetSqlName('NYB') + " NYB3 ON ("
	cSql +=             "( NYB3.NYB_CORIG = NYB2.NYB_COD "
	cSql +=               " OR NYB3.NYB_COD = NYB2.NYB_COD ) "
	cSql +=               " AND NYB3.NYB_FILIAL = '" + xFilial("NYB") + "' "
	cSql +=               " AND NYB3.D_E_L_E_T_ = ' ') "
	cSql += " WHERE NYB.NYB_COD = '" + cTpAssunto + "'
	cSql += ") FAMILIA "
	cSql += " WHERE FAMILIA.NYB_COD IN ( " + JurTpAsPesq(__CUSERID) + " ) "

Return cSql
