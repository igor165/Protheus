#include "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'GPEA940A.CH'

/*/{Protheus.doc} GPEA940
	@type  Function
	@author Gisele Nuncherino
	@since 26/02/2020
	@description Rotina para cadastrar as versões de modelo do consentimento
/*/
FUNCTION GPEA940()

Local oBrwRI2
Local cMsgDesatu	:= ""

Private cConteudo	:= ""

If !(ChkFile("RI2") .And. ChkFile("RI3"))
	cMsgDesatu := CRLF + OemToAnsi(STR0001) + CRLF //"Tabelas não definidas: RI2/RI3 - Versionamento e Aceites de Consentimento"
	Help( " ", 1, OemToAnsi(STR0008),, cMsgDesatu, 1, 0 )
	Return
EndIf

RI2->(DBSetOrder(2))

oBrwRI2 := FWmBrowse():New()
oBrwRI2:SetAlias( 'RI2' )
oBrwRI2:SetDescription( STR0002 ) //"Versionamento de Consentimentos"

oBrwRI2:AddLegend('!Empty(RI2_DTFIM) .And. fDHtoNS(RI2_DTFIM, RI2_HRFIM) <= fDHtoNS(ddatabase, Val(StrTran(Substr(time(),1,5),":",".")) )', "RED", OemToAnsi(STR0015) ) //"Fora do prazo"
oBrwRI2:AddLegend('fDHtoNS(RI2_DTINI, RI2_HRINI) <= fDHtoNS(ddatabase, Val(StrTran(Substr(time(),1,5),":",".")) ) .And. ( Empty(RI2_DTFIM) .Or. fDHtoNS(RI2_DTFIM, RI2_HRFIM) >= fDHtoNS(ddatabase, Val(StrTran(Substr(time(),1,5),":",".")) ) )', "GREEN", OemToAnsi(STR0014) ) //"Versão vigente"
oBrwRI2:AddLegend('fDHtoNS(RI2_DTINI, RI2_HRINI) > fDHtoNS(ddatabase, Val(StrTran(Substr(time(),1,5),":",".")) )', "BLUE", OemToAnsi(STR0016) ) //"Modelo Futuro"

oBrwRI2:ForceQuitButton()

oBrwRI2:DisableDetails()

oBrwRI2:Activate()

Return


/*/{Protheus.doc} MenuDef
	@type  Static Function
	@author Gisele Nuncherino
	@since 26/02/2020
	@description Rotina que define as opções de menu da rotina
/*/
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina Title STR0003  Action 'PesqBrw'			OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina Title STR0004  Action 'VIEWDEF.GPEA940'	OPERATION 2 ACCESS 0 //"Aceites"
	ADD OPTION aRotina Title STR0005  Action 'VIEWDEF.GPEA940'	OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina Title STR0006  Action 'VIEWDEF.GPEA940'	OPERATION 4 ACCESS 0 //"Atualizar"
	ADD OPTION aRotina Title STR0007  Action 'VIEWDEF.GPEA940'	OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina


/*/{Protheus.doc} ModelDef
	@type  Static Function
	@author Gisele Nuncherino
	@since 26/02/2020
	@description Rotina que define o modelo a ser utilizado
/*/
Static Function ModelDef()
	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruRI2 := FWFormStruct( 1, 'RI2', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruRI3 := FWFormStruct( 1, "RI3")
	Local oModel
	// Blocos de codigo do modelo
	Local bPosValid 	:= { |oModel| GP940POSVAL( oModel ) }
	Local bCommit 	    := { |oModel| GP934AGRV( oModel )   }
	Local bCancel 	    := { |oModel| GP934ACanc( oModel )  }

	oStruRI2:SetProperty( 'RI2_CODIGO' , MODEL_FIELD_WHEN , {||.F.})
	oStruRI2:SetProperty( 'RI2_FILIAL' , MODEL_FIELD_WHEN , {||.F.})

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('GPEA940', /*bPreValid*/, bPosValid, bCommit, bCancel )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'GPEA940_MRI2', /*cOwner*/, oStruRI2, /*bLOkVld*/, /*bTOkVld*/, /*bCarga*/ )

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:SetDescription( STR0017 )   //"Aceites por modelo de consentimento"

	// Adiciona grid com os aceites por modelo
	oModel:AddGrid( "GPEA940_RI3", "GPEA940_MRI2", oStruRI3 )

	oModel:GetModel("GPEA940_RI3"):SetOptional(.T.)
	oModel:SetOnlyQuery("GPEA940_RI3", .T. )
	oModel:SetPrimaryKey( {"RI2_CODIGO"} )

	oModel:SetRelation( "GPEA940_RI3", { {"RI3_FILIAL", "xFilial('RI2')"}, {"RI3_CODVER", "RI2_CODIGO"} }, RI3->(IndexKey()) )

	//--Valida se o model deve ser ativado
	oModel:SetVldActivate( { |oModel| fVldModel(oModel,oModel:GetOperation()) } )

Return oModel

/*/{Protheus.doc} ViewDef
	@type  Static Function
	@author Gisele Nuncherino
	@since 26/02/2020
	@description Rotina que define a view a ser utilizada
/*/
Static Function ViewDef()
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel	:= FWLoadModel( 'GPEA940' )
	Local oView		:= FWFormView():New()
	// Cria a estrutura a ser usada na View
	Local oStruRI2	:= FWFormStruct( 2, 'RI2' )
	Local oStruRI3	:= FWFormStruct( 2, 'RI3' )

	oStruRI2:SetProperty('RI2_ARQUIV' , MVC_VIEW_CANCHANGE , .F. )
	oStruRI2:RemoveField( 'RI2_MODELO')
	oStruRI3:RemoveField("RI3_CODVER")

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	//Adiciona Grid na interface
	oView:AddField( 'GPEA940_VRI2', oStruRI2, 'GPEA940_MRI2' )
	oView:AddGrid("GPEA940_RI3", oStruRI3)
	oView:CreateHorizontalBox("TOP", 35)
	oView:CreateHorizontalBox("BOTTOM", 65)

	oView:SetOwnerView("GPEA940_VRI2", "TOP")
	oView:SetOwnerView("GPEA940_RI3", "BOTTOM")

	oView:SetViewProperty("GPEA940_RI3", "ONLYVIEW")

	oView:AddUserButton( OEMTOANSI( STR0013 ), 'NOTE', {|oView| UploadPDF(oModel) },/*cToolTip*/,/*nShortCut*/, {MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE} )

Return oView


/*/{Protheus.doc} GP940POSVAL
	@type  Static Function
	@author Gisele Nuncherino
	@since 26/02/2020
	@description Rotina para validar as informações antes de serem gravadas na base de
	Dados
/*/
Static Function GP940POSVAL( oModel )
	Local lRetorno 		:= .T.
	Local nOperation 	:= 0
	Local oStruRI2 		:= oModel:GetModel("GPEA940_MRI2")
	Local cCodigo		:= ''
	Local cFilRI2		:= ''
	Local cDiretorio	:= SuperGetMV("MV_DIRCONS",.F.,"")
	Local cNewDir		:= GetMv("MV_DIRTERM", .T., '')

	Local cAux1	:= ''
	Local cAux2	:= ''
	Local cAux3 := ''

	Local aArea 	:= GetArea()

	// Seta qual e a operacao corrente
	nOperation := oModel:GetOperation()

	If nOperation == 5
		RI3->(DbSetOrder(2)) //RI3_FILIAL+RI3_CODVER
		If RI3->(DbSeek(RI2->RI2_FILIAL + RI2->RI2_CODIGO))
			lRetorno := .F.
			Help( " ", 1, OemToAnsi(STR0008),, OemToAnsi(STR0019), 1, 0 )
			//"Exclusão do registro não permitida. Existem aceites vinculados a este modelo de termo de consentimento."
		EndIf
	Else

		if empty(cNewDir) .and. empty(cDiretorio)
			lRetorno := .F.
			Help( " ", 1, OemToAnsi(STR0008),,OemToAnsi(STR0035), 1, 0 )
			Return( lRetorno )
		endif

		lRetorno := ValidData(0, oStruRI2:GETVALUE("RI2_DTINI") , oStruRI2:GETVALUE("RI2_HRINI")) .And.;
					ValidData(1, oStruRI2:GETVALUE("RI2_DTINI") , oStruRI2:GETVALUE("RI2_HRINI"), oStruRI2:GETVALUE("RI2_DTFIM") , oStruRI2:GETVALUE("RI2_HRFIM")) .And.;
					ValidData(2, oStruRI2:GETVALUE("RI2_DTFIM") , oStruRI2:GETVALUE("RI2_HRFIM"), oStruRI2:GETVALUE("RI2_DTMAX") , oStruRI2:GETVALUE("RI2_HRMAX"))

		IF lRetorno
			cCodigo := oStruRI2:GETVALUE("RI2_CODIGO")
			cFilRI2 := oStruRI2:GETVALUE("RI2_FILIAL")

			//PROCESSO DE VALIDAR O PERIODO
			RI2->(DBSETORDER(2)) //RI2_FILIAL+RI2_DTINI+RI2_HRINI+RI2_DTFIM+RI2_HRFIM
			RI2->(DBSEEK(cFilRI2))

			WHILE RI2->(!EOF()) .AND. RI2->RI2_FILIAL == cFilRI2

				IF RI2->RI2_CODIGO <> cCodigo
					IF !EMPTY(oStruRI2:GETVALUE("RI2_DTINI"))
						CAUX1 := fDHtoNS( oStruRI2:GETVALUE("RI2_DTINI") , oStruRI2:GETVALUE("RI2_HRINI") )
						CAUX2 := fDHtoNS( RI2->(RI2->RI2_DTINI) , RI2->(RI2->RI2_HRINI) )
						IF !EMPTY(RI2->RI2_DTFIM)
							CAUX3 := fDHtoNS( RI2->(RI2->RI2_DTFIM) , RI2->(RI2->RI2_HRFIM) )
							IF CAUX2 <= CAUX1 .and. CAUX1 <= CAUX3
								lRetorno := .F.
								Help( " ", 1, OemToAnsi(STR0008),, OemToAnsi(STR0027), 2 , 0 , , , , , , { OemToAnsi(STR0031) } )
								EXIT
							ENDIF
						ENDIF
					ENDIF
					IF !EMPTY(oStruRI2:GETVALUE("RI2_DTFIM"))
						CAUX1 := fDHtoNS( oStruRI2:GETVALUE("RI2_DTFIM") , oStruRI2:GETVALUE("RI2_HRFIM") )
						CAUX2 := fDHtoNS( RI2->(RI2->RI2_DTINI) , RI2->(RI2->RI2_HRINI) )
						IF !EMPTY(RI2->RI2_DTFIM)
							CAUX3 := fDHtoNS( RI2->(RI2->RI2_DTFIM) , RI2->(RI2->RI2_HRFIM) )
							IF CAUX2 <= CAUX1 .AND. CAUX1 <=  CAUX3
								lRetorno := .F.
								Help( " ", 1, OemToAnsi(STR0008),, OemToAnsi(STR0027), 2 , 0 , , , , , , { OemToAnsi(STR0031) } )
								EXIT
							ENDIF
						ENDIF
					ENDIF
				ENDIF
				RI2->(DBSKIP())
			ENDDO
		ENDIF
	Endif

	RestArea(aArea)

Return( lRetorno )


/*/{Protheus.doc} fVldModel
	@type  Static Function
	@author Gisele Nuncherino
	@since 26/02/2020
	@description Rotina para ativar o modelo definido
/*/
Static Function fVldModel( oModel, nOperation )

Local lRetorno 		:= .T.
Local aArea      	:= GetArea()
Local nOperation 	:= 0
Local nFim			:= ''
Local nAux			:= fDHtoNS( dDatabase , Val(StrTran(Substr(time(),1,5),":",".")) )

nOperation := oModel:GetOperation()

if nOperation == 4 // alteracao
	IF !EMPTY(RI2->RI2_DTFIM)
		nFim := fDHtoNS( RI2->(RI2->RI2_DTFIM) , RI2->(RI2->RI2_HRFIM) )
		if (nFim >= nAux)
			RI3->(DBSETORDER(2)) //RI3_FILIAL+RI3_CODVER
			IF !RI3->(DBSEEK(RI2->RI2_FILIAL + RI2->RI2_CODIGO))
				lRetorno := .T.
			ELSE
				lRetorno := .F.
				Help( " ", 1, OemToAnsi(STR0008),, OEMTOANSI( STR0020 ), 1, 0 )
			ENDIF
		else
			lRetorno := .F.
			Help( " ", 1, OemToAnsi(STR0008),, OEMTOANSI( STR0018 ), 1, 0 )
		ENDIF
	ELSE
		RI3->(DBSETORDER(2)) //RI3_FILIAL+RI3_CODVER
		IF !RI3->(DBSEEK(RI2->RI2_FILIAL + RI2->RI2_CODIGO))
			lRetorno := .T.
		ELSE
			lRetorno := .F.
			Help( " ", 1, OemToAnsi(STR0008),, OEMTOANSI( STR0020 ), 1, 0 )
		ENDIF
	ENDIF
ENDIF

RestArea( aArea )

Return( lRetorno )


/*/{Protheus.doc} GP934AGRV
	@type  Static Function
	@author Gisele Nuncherino
	@since 26/02/2020
	@description Rotina gravar os dados do modelo
/*/
Static Function GP934AGRV(oModel)
	Local lRet			:= .T.
	Local aArea			:= GetArea()
	Local nOperation	:= 0
	Local cCodigo		:= ""
	Local oStruRI2		:= oModel:GetModel("GPEA940_MRI2")
	Local cFilRI2		:= ''
	Local cArq			:= ''
	Local cAux			:= ''
	Local cDiretorio	:= SuperGetMV("MV_DIRCONS",.F.,"")
	Local cNewDir		:= GetMv("MV_DIRTERM", .T., '')
	Local nAtual		:= fDHtoNS( ddatabase , Val(StrTran(Substr(time(),1,5),":",".")) )

	Local aIniSessions := GetIniSessions(GetADV97())
	Local cJobs	:= ''
	Local cPesqWeb := ''
	Local nT := 0

	if empty(cNewDir) 
		//cenario na qual o cliente esteja usando o parametro antigo MV_DIRTERM 
		
		//o parametro MV_DIRCONS sera utilizado APENAS para ambiente ERP e PORTAL no MESMO appserver.ini)
		For nT:=1 To Len(aIniSessions)
			cJobs := GetPvProfString( aIniSessions[nt] , "DEFAULTPAGE", '', GetADV97() )
			if alltrim(upper(cJobs)) == alltrim(upper("w_pwsr001.apw")) //portal do candidato
				cPesqWeb:= GetPvProfString( aIniSessions[nt] , "PATH", '', GetADV97() )
				if !empty(cPesqWeb)
					Exit
				Endif
			Endif
		Next
	Endif

	nOperation := oModel:GetOperation()

	Begin Transaction
		If nOperation == 3			// Inclusao
			If __lSX8
				ConfirmSX8()
			EndIf
		EndIf
		FWFormCommit(oModel)
		If nOperation # 5			// Se nao for Exclusao
			RECLOCK('RI2', .F.)
				RI2->RI2_MODELO := cConteudo
			RI2->(MSUNLOCK())

			cArq  := oStruRI2:GETVALUE("RI2_ARQUIV")
			
			if empty(cNewDir) .and. empty(cDiretorio) 
				lRetorno := .F.
				Help( " ", 1, OemToAnsi(STR0008),,OemToAnsi(STR0035), 1, 0 )
				Return( lRetorno )
			ENDIF

			if empty(cNewDir) 
				cPesqWeb := StrTran( cPesqWeb, AllTrim(GetSrvProfString ("RootPath", "")), "" )
				cPesqWeb := StrTran( cPesqWeb, "\", "/" )
				cDiretorio := cPesqWeb + cDiretorio
			else
				cDiretorio := StrTran( cNewDir, "\", "/" )
			endif

			//-- Cria diretorio
			If !ExistDir( cDiretorio )
				If MakeDir(cDiretorio) == 0
					CpyT2S( cArq , cDiretorio ,.F.)
				ENDIF
			ELSE
				CpyT2S( cArq , cDiretorio ,.F.)
			EndIf

			cCodigo := oStruRI2:GETVALUE("RI2_CODIGO")
			cFilRI2 := oStruRI2:GETVALUE("RI2_FILIAL")

			//PROCESSO DE ATUALIZAR O REGISTRO ANTERIOR COM A DATA FIM DE VIGENCIA DO CONSENTIMENTO
			RI2->(DBSETORDER(2)) //RI2_FILIAL+RI2_DTINI+RI2_HRINI+RI2_DTFIM+RI2_HRFIM
			RI2->(DBSEEK(cFilRI2))
			RI2->(DBGoBottom())
			RI2->(DBSKIP(-1))

			IF EMPTY(RI2->(RI2->RI2_DTFIM)) .AND. RI2->RI2_CODIGO <> cCodigo
				CAUX := fDHtoNS( oStruRI2:GETVALUE("RI2_DTINI") , oStruRI2:GETVALUE("RI2_HRINI") )
				RECLOCK("RI2", .F.)
					CAUX := CAUX - fDHtoNS( NIL , 0.01 ) //retira 1 minuto

					RI2->RI2_DTFIM := fNStoDH( CAUX , "D" )
					RI2->RI2_HRFIM := fNStoDH( CAUX , "H" )

					CAUX := CAUX - fDHtoNS( NIL , 0.01 ) //retira mais 1 minuto
					RI2->RI2_DTMAX := fNStoDH( CAUX , "D" )
					RI2->RI2_HRMAX := fNStoDH( CAUX , "H" )
				RI2->(MSUNLOCK())
			ELSEIF EMPTY(RI2->(RI2->RI2_DTMAX)) .AND. RI2->RI2_CODIGO <> cCodigo
				CAUX := fDHtoNS( RI2->(RI2->RI2_DTFIM) , RI2->(RI2->RI2_HRFIM) )
				RECLOCK("RI2", .F.)
					CAUX := CAUX - fDHtoNS( NIL , 0.01 ) //retira mais 1 minuto
					RI2->RI2_DTMAX := fNStoDH( CAUX , "D" )
					RI2->RI2_HRMAX := fNStoDH( CAUX , "H" )
				RI2->(MSUNLOCK())
			ENDIF

			// Atualizar Status SQG caso modelo RI2 incluído seja o vigente
			If nAtual >= fDHtoNS(oStruRI2:GETVALUE("RI2_DTINI"), oStruRI2:GETVALUE("RI2_HRINI")) .And.;
				( Empty(oStruRI2:GETVALUE("RI2_DTFIM")) .Or. nAtual <= fDHtoNS(oStruRI2:GETVALUE("RI2_DTFIM"), oStruRI2:GETVALUE("RI2_HRFIM")) )
				fAtuAceite(oStruRI2:GETVALUE("RI2_CODIGO"), oStruRI2:GETVALUE("RI2_FILIAL"))
			EndIf
		EndIf
	End Transaction

	RestArea( aArea )

Return lRet


/*/{Protheus.doc} UploadPDF
	@type  Static Function
	@author Gisele Nuncherino
	@since 26/02/2020
	@description Rotina para fazer o upload dos dados do arquivo modelo
/*/
Static Function UploadPDF(oModel)

Local cFile 	:= ""
Local cModelo	:= ""
Local _oView	:= FwViewActive()

//cGetFile ( [ cMascara], [ cTitulo], [ nMascpadrao], [ cDirinicial], [ lSalvar], [ nOpcoes], [ lArvore], [ lKeepCase] )
cFile := cGetFile( OEMTOANSI( STR0011 ) , OEMTOANSI( STR0012 ), 1, "C:\", .F. )

If !EMPTY(cFile) .AND. File( cFile )
	oFile := FwFileReader():New( cFile )
	If (oFile:Open())
		cModelo := oFile:FullRead()
		oFile:Close()
	EndIf

	cConteudo := cModelo

	oModel:SetValue("GPEA940_MRI2", "RI2_ARQUIV" , cFile )
	_oView:LMODIFY:=.T.

Endif

Return


/*/{Protheus.doc} GP934ACanc
	@type  Static Function
	@author Gisele Nuncherino
	@since 26/02/2020
	@description Rotina de cancelamento da inclusao/alteracao
/*/
Static Function GP934ACanc(oModel)
Local lRet       	:= .T.
Local aArea      	:= GetArea()
Local nOperation 	:= 0

nOperation := oModel:GetOperation()

If nOperation # 5 .And. nOperation # 2	// Se nao for Exclusao e Visualizacao
	Begin Transaction
		If nOperation == 3			// Inclusao
			RollBackSX8()
		EndIf
	End Transaction
Endif
RestArea( aArea )

Return lRet


/*/{Protheus.doc} ValDtMax
	@type  Function
	@author Gisele Nuncherino
	@since 26/02/2020
	@description Validação da data e hora maxima para aceite do termo de consentimento
/*/
Function ValDtMax()

Local lRet 		:= .T.
Local cData1 	:= ''
Local cData2 	:= ''
Local cData3	:= ''

if EMPTY(M->RI2_DTMAX)
	lRet := .T.
else
	cData1 	:= fDHtoNS( M->RI2_DTINI , M->RI2_HRINI )
	cData2 	:= fDHtoNS( M->RI2_DTFIM , M->RI2_HRFIM )
	cData3	:= fDHtoNS( M->RI2_DTMAX , M->RI2_HRMAX )

	if !empty(M->RI2_DTFIM)
		if  (cData3 < cData2) .and. (cData3 > cData1)
			lRet := .T.
		else
			lRet := .F.
			Help( " ", 1, OemToAnsi(STR0008),, OemToAnsi(STR0030), 2 , 0 , , , , , , { OemToAnsi(STR0033) } )
			//"Verifique a Data/Hora Máxima - Caso preenchidas, devem ser superiores ao início, e inferiores ao término da vigência."
		ENDIF
	else
		lRet := .F.
		Help( " ", 1, OemToAnsi(STR0008),, OemToAnsi(STR0027), 2 , 0 , , , , , , { OemToAnsi(STR0034) } )
		//"Campos de Data/Hora inválidos - Para o preenchimento da Data/Hora Máxima, a Data/Hora de Término deve ser informada."
	ENDIF
ENDIF

return lRet



/*/{Protheus.doc} ValidData
	@type  Function
	@author Gisele Nuncherino
	@since 26/02/2020
	@description Validação das datas e horas (inicio e termino) de vigencia e aceite do termo de consentimento
/*/
Function ValidData(cTipo, dData1, nHora1, dData2, nHora2)

Local lRet  	:= .T.
Local cData1 	:= ""
Local cData2	:= ""

if cTipo == 1 // valida data fim com data inicio
	If ( Empty(dData2) .And. !Empty(nHora2) ) .Or. !VldHora(nHora2)
		lRet := .F.
		Help( " ", 1, OemToAnsi(STR0008),, OemToAnsi(STR0027), 2 , 0 , , , , , , { OemToAnsi(STR0029) } )	//"Verifique a data/hora de término"
	ElseIf !Empty(dData2)
		cData1 	:= fDHtoNS( dData1 , nHora1 )
		cData2	:= fDHtoNS( dData2 , nHora2 )
		If cData2 < cData1
			lRet := .F.
			Help( " ", 1, OemToAnsi(STR0008),, OemToAnsi(STR0027), 2 , 0 , , , , , , { OemToAnsi(STR0032) } )	//"Data/Hora de Término não deve ser inferior ao Início"
		EndIf
	EndIf
elseif cTipo == 2 // valida data maxima com data fim
	If !Empty(dData1)
		If ( Empty(dData2) .And. !Empty(nHora2) ) .Or. !VldHora(nHora2)
			lRet := .F.
			Help( " ", 1, OemToAnsi(STR0008),, OemToAnsi(STR0027), 2 , 0 , , , , , , { OemToAnsi(STR0030) } )	//"Verifique a Data/Hora Máxima"
		else
			cData1 	:= fDHtoNS( dData1 , nHora1 )
			cData2	:= fDHtoNS( dData2 , nHora2 )
			IF cData2 < cData1
				lRet := ValDtMax()
			ELSE
				lRet := .F.
				Help( " ", 1, OemToAnsi(STR0008),, OemToAnsi(STR0030), 2 , 0 , , , , , , { OemToAnsi(STR0033) } )
				//"Verifique a Data/Hora Máxima - Caso preenchidas, devem ser superiores ao início, e inferiores ao término da vigência."
			ENDIF
		EndIf
	ElseIf !Empty(dData2)
		lRet := .F.
		Help( " ", 1, OemToAnsi(STR0008),, OemToAnsi(STR0027), 2 , 0 , , , , , , { OemToAnsi(STR0034) } )
		//"Campos de Data/Hora inválidos - Para o preenchimento da Data/Hora Máxima, a Data/Hora de Término deve ser informada."
	EndIf
ELSEIF CTIPO == 0
	IF VldHora(nHora1) .and. !Empty(dData1)
		lRet := .T.
	else
		lRet := .F.
		Help( " ", 1, OemToAnsi(STR0008),, OemToAnsi(STR0009), 2 , 0 , , , , , , { OemToAnsi(STR0028) } )	//"Verifique a Data/Hora de Início"
	ENDIF
ENDIF

RETURN lRet