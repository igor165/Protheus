#include "totvs.ch"
#include "fwmvcdef.ch"
#include "SPEDCONFTSS.ch"

#define ENTER CHR(13) + CHR(10)
#define CRYPTKEY 'A6F985FTSS' 
#define LINHA	 '------------------------------'

Static _lAdmin	  := nil
static _lCpoMod

/*/{Protheus.doc} SPEDCFGTSS
					
	Função para configuração Geral do TSS

	@author Valter Silva
	@since  07/07/2020
/*/
function SPEDCFGTSS()
	local aAdvSize	 := {}
	local aInfoSize	 := {}
	local aObjCoords := {}
	local aObjSize	 := {}
	local oDlgMark   := Nil
	local oTela	     := nil
	local cIdUp		 := nil
	local cIdDown	 := nil
	local oPanelUp	 := nil
	local oPanelDown := nil
	local oModelo	 := nil
	local oView		 := nil
	local lProc		 := .T.

	private oMark      := nil  
	private cMrcCfgTSS := ""
	private aRetSM0    := {}
	private cCrtFile   := ""
	private cUrlcPL    := ""
	
	if(!accessPD())
		return
	endif

	if _lAdmin == nil
		_lAdmin := PswAdmin( /*cUser*/, /*cPsw*/,RetCodUsr()) == 0
	endIf	
	
	if TableInDic( "FX7", .F. ) 

		if _lCpoMod == nil
			_lCpoMod := FX7->(ColumnPos("FX7_MODELO")) > 0 .and. OpcIntCred() == 1
		endif

		if _lCpoMod
			if !alltrim(FWX2Unico("FX7")) == "FX7_FILIAL+FX7_CREDEN+FX7_MODELO"
				Help( ,, 'SPEDCFGTSS',, STR0041 + CHR(13) + CHR(10) + STR0042 + CHR(13) + CHR(10) + STR0043, 1, 0 ) // "Não será possível acessar a rotina." # "Verifique com administrador do sistema a chave única da tabela FX7." # "Por favor, atualizar o dicionario de dados (UPDDISTR)."
				lProc := .F.
			endif
		endif

		if lProc
			aRetSM0 := AdmSM0()
			lProc := SpedCgInit("A")
		endif

		if lProc
			aAdvSize := MsAdvSize(.T.)
			aInfoSize := { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 15 }
			aAdd( aObjCoords , { 100 , 100 , .T. , .T. } )
			aObjSize := MsObjSize( aInfoSize , aObjCoords ,.T.)

			Define MsDialog oDlgMark FROM aAdvSize[7], 0 To aAdvSize[6], aAdvSize[5] Title ''  OF oMainWnd PIXEL
				oDlgMark:lEscClose := .T.

				oTela := FWFormContainer():New( oDlgMark )
				cIdUp := oTela:CreateHorizontalBox( 70)
				cIdDown := oTela:CreateHorizontalBox( 30)
				
				oTela:Activate( oDlgMark, .T. )
				oPanelUp := oTela:GeTPanel( cIdUp )
				oPanelDown := oTela:GeTPanel( cIdDown )

				oMark := FWMarkBrowse():New()
				oMark:SetAlias( "FX7" )
				oMark:SetDescription( STR0001 ) // "Configuração Gerais TSS"
				oMark:DisableReport()
			
				oMark:SetFieldMark( "FX7_OK" )

				oMark:AddStatusColumns( { || SpedCfgSta( ) }, { || CfgTSSLegen() } )
				oMark:AddStatusColumns( { || SpedCfgStC( ) }, { || CfgLegCert() } )

				oMark:SetOwner(oPanelUp)
				oMark:SetAllMark( {|| VldMarkAll() } )
				oMark:SetCustomMarkRec( {|| MarkReg(nil) } )
				oMark:SetFontBrowse( TFont():New( , , 20, , .F.) )
				oMark:SetLineHeight(25)

				oMark:Activate()
				cMrcCfgTSS := oMark:Mark() 

				oModelo := FWLoadModel("CONFTSSA")
				oModelo:SetOperation(  MODEL_OPERATION_INSERT )
				oModelo:Activate()

				oView := FWLoadView("CONFTSSA")
				oView:SetModel(oModelo)

				oView:SetOwner(oPanelDown)
				oView:SetOperation( MODEL_OPERATION_INSERT )

				oView:Activate()
				
			ACTIVATE MSDIALOG oDlgMark CENTERED
		endif
	
	else
		Help( ,, 'SPEDCFGTSS',, STR0002, 1, 0 ) // "A tabela FX7 não existe. Por favor, atualizar o dicionario de dados."
	endif

return

static function SpedCfgSta()
	local cStatus := 'BR_VERMELHO'

	if alltrim(FX7->FX7_STATUS) == "1"
		cStatus := 'BR_AZUL'
	endif
return cStatus

static function CfgTSSLegen()
	local oLegenda  :=  FWLegend():New()

	oLegenda:Add( '', 'BR_VERMELHO'	, STR0003 )	// "Filial sem configuração"
	oLegenda:Add( '', 'BR_AZUL'		, STR0004 )	// "Credenciais informada"

	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()
return nil

static function SpedCfgStC()
	local cStatus := 'BR_VERMELHO'

	if alltrim(FX7->FX7_STCERT) == "2"
		cStatus := 'BR_VERDE'
	elseif alltrim(FX7->FX7_STCERT) == "3"
		cStatus := 'BR_AMARELO'
	endif

return cStatus

static function CfgLegCert()
	local oLegenda  :=  FWLegend():New()

	oLegenda:Add( '', 'BR_VERMELHO'	, STR0025 )//"Certificado não configurado"
	oLegenda:Add( '', 'BR_VERDE'	, STR0026)// "Certificado configurado com sucesso."
	oLegenda:Add( '', 'BR_AMARELO'	, STR0027)//"Erro ao configurar o Certificado Digital"

	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()

return nil

/*/{Protheus.doc} MenuDef
	Menudef do fonte

	@author Valter Silva
	@since  07/07/2020
/*/
Static function MenuDef()
	local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0006 ACTION 'SpedProCFG()'	    OPERATION 4 ACCESS 0 // 'Salvar' 
	ADD OPTION aRotina TITLE STR0009 ACTION 'SpedExcCFG()'		OPERATION 5 ACCESS 0 // 'Excluir'
	ADD OPTION aRotina TITLE STR0007 ACTION 'SpedCgInit("M")'	OPERATION 4 ACCESS 0 // 'Atualizar informações'
	
return aRotina

/*/{Protheus.doc} SpedProCFG
	Realiza o processamento da configuração do TSS

	@author Valter Silva
	@since  07/07/2020
/*/
function SpedProCFG()
	local oSay		 := nil
	local aArea		 := GetArea()
	local aAreaFX7	 := FX7->(GetArea())
	local oModel	 := FWModelActive()
	local oModFX7	 := oModel:GetModel('FORMFX7')
	local lMarca	 := .F.
	local nProc		 := 0	
	local oView      := nil
	local lCreden    := .F.
	local lEmptyURL  := .F.
	local lProc		 := .F.
	local lCert      := .F.
	local lUsaIdHex  := GetNewPar("MV_A3IDHEX",.F.)
	local cMsgUrl	 := ""
	local cRes       := ""
	local nTipo  	 := 0
	local cCert      := Space(250)
	local cKeyCert   := Space(250)
	local cPassWord  := Space(50)
	local cSlot      := Space(4)
	local cLabel     := Space(250)
	local cModulo    := Space(250)
	local cIdHex	 := Space(250)
 
	if _lAdmin

		nTipo     := val(allTrim(oModFX7:GetValue("FX7_TIPO"))) 
		cCert     := allTrim(oModFX7:GetValue("FX7_CERT"))
		cKeyCert  := allTrim(oModFX7:GetValue("FX7_PRIKEY"))
		cPassWord := allTrim(oModFX7:GetValue("FX7_SENHA"))
		cSlot     := allTrim(oModFX7:GetValue("FX7_SLOT"))
		cLabel    := allTrim(oModFX7:GetValue("FX7_LABEL"))
		cModulo   := allTrim(oModFX7:GetValue("FX7_HSM"))
		if lUsaIdHex
			cIdHex    := allTrim(oModFX7:GetValue("FX7_IDHEX"))
		endif

		lCreden	:= (!empty(oModFX7:GetValue("FX7_CREDEN")) .and. !empty(oModFX7:GetValue("FX7_CREKEY")))
		cUrl 	:= alltrim(oModFX7:GetValue("FX7_URL"))
		lEmptyURL := empty( cUrl )
		lCert	:= !empty(cPassWord) .and. ((!Empty(cCert) .and. ( ( !Empty(cKeyCert) .And. nTipo == 1 ) .or. nTipo == 2 ) ) ) .or. ( ( !Empty(cSlot) .And. nTipo == 3) .or. !Empty(cLabel) .or. !Empty(cIdHex) )

		lProc := lCreden
		if !lCreden .and. !lCert
			if  (!empty(oModFX7:GetValue("FX7_CREDEN")) .or. !empty(oModFX7:GetValue("FX7_CREKEY")))
				MsgStop(STR0037) //É necessário preencher os dois campos: Client Id e cli.Secret
			else
				MsgStop(STR0031 + " " + STR0039 ) // É necessário preencher os campos: # "(Credenciais ou Certificado de acordo com o Tipo)"
			endif
		endif

		If lCert 
			lProc := .F.
			if ( nTipo <> 3 .And. !File(cCert)) .or. ( nTipo == 1 .And. !File(cKeyCert))
				MsgStop(STR0029) //"Arquivo do certificado não encontrado"
			elseif lEmptyURL .and. ( ( _lCpoMod <> nil .and. _lCpoMod) .or. empty(cUrl := alltrim(SuperGetMv("MV_SPEDURL",.F.,"",FWCodEmp()))) )
				MsgStop(STR0044 + if( ( _lCpoMod <> nil .and. _lCpoMod) , "" ,STR0045 ) + ".") // "É necessário preencher o campo 'URL' da pasta 'URL TSS' para realizar a configuração do certificado" # " ou o paramêtro 'MV_SPEDURL'"
			else
				lProc := .T.
			endif
		endif

		if lProc
			FWMsgRun(, {|oSay| ProcFX7(oSay,  oModFX7, lCreden, lCert, @lMarca, @nProc, @cRes, @cMsgUrl, lEmptyURL, cUrl, nTipo, cCert, cKeyCert, cPassWord, cSlot, cLabel, cModulo, cIdHex ) }, STR0010, STR0046) // "Processando informações das empresas/filiais..."

			if !lMarca
				ApMsgInfo(STR0020) // "Não foram marcados registros para processamento."
	
			else
				ApMsgInfo(STR0012 + " " + alltrim( Str( nProc ) ) + " " + STR0013 + " "+cMsgUrl) 

				if nProc > 0
					oView := FWViewActive()
					oModFX7:SetValue("FX7_CREDEN" ,"") 
					oModFX7:SetValue("FX7_CREKEY" ,"")
					oModFX7:SetValue("FX7_URL"    ,"")
					if empty(cRes)
						oModFX7:SetValue("FX7_CERT"   ,"")
						oModFX7:SetValue("FX7_PRIKEY" ,"")
						oModFX7:SetValue("FX7_SENHA"  ,"")
						oModFX7:SetValue("FX7_SLOT"   ,"")
						oModFX7:SetValue("FX7_LABEL"  ,"")
						oModFX7:SetValue("FX7_HSM"    ,"")
					endif
					oView:Refresh()
				endif
	
				if !empty(cRes)
					ViewMsg(cRes)
				endif
				
			endif

		endif

		RestArea( aArea )
		RestArea( aAreaFX7 )

	else
		Help( "", 1, "SEMPERM" )
	endIf

return

/*/{Protheus.doc} ProcFX7
	Salva a tabela FX7 e realiza o envio da configuração do certificado

/*/
static function ProcFX7(oSay, oModFX7, lCreden, lCert, lMarca, nProc, cRes, cMsgUrl, lEmptyURL, cUrl, nTipo, cCert, cKeyCert, cPassWord, cSlot, cLabel, cModulo, cIdHex)
	local aAreaSM0	 := {}
	local aAreaFX7	 := {}
	local lSay		 := valtype(oSay) == "O"
	local cMarca	 := if( type("oMark") == "O" , oMark:Mark() , "" )
	local lAtualiza	 := .F.
	local cCertRes	 := ""
	local cKey       := ""
	local cCreden	 := ""
	local cStatus	 := ""
	local cIdEnt	 := nil
	local cBkpFilAnt := cFilAnt
	local nDados	 := 0
	local aDadosFX7	 := {}
	local aConfCert	 := {}
	local nPos		 := 0

	dbSelectArea("FX7")
	aAreaFX7 := FX7->(getArea())

	dbSelectArea( "SM0" )
	aAreaSM0 := SM0->(getArea())

	SM0->(DbSetOrder( 1 ))
	lMarca   := .F.
	nProc    := 0
	cRes     := ""
	if lCreden .and. !empty( cKey := Alltrim(oModFX7:GetValue("FX7_CREKEY")) )
		cKey := rc4crypt( cKey ,CRYPTKEY, .T.) 
		cCreden := oModFX7:GetValue("FX7_CREDEN")
	endif
	aDadosFX7 := {}

	FX7->(dbGoTop())

	while FX7->(!eof())

		if !empty(cMarca) .and. oMark:IsMark(cMarca) 

			lMarca := .T.
			if lCreden .or. lCert
				//Configura os parametros
				if _lCpoMod <> nil .and. _lCpoMod .and. alltrim(FX7->FX7_MODELO) == '0' .and. !lEmptyURL .and. lCert
					PutMVpar("MV_SPEDURL",cUrl)
					cMsgUrl := ENTER + STR0038 //"O parametrô (MV_SPEDURL) foi configurado com sucesso!"
				endif
				aAdd( aDadosFX7, FX7->(recno()) )
			endif
		endif

		FX7->( dbSkip() )
	endDo

	for nDados := 1 to len(aDadosFX7)

		FX7->(dbgoto( aDadosFX7[nDados] ))
		lAtualiza := .F.
		cCertRes := ""

		if lSay
			oSay:SetText(STR0015 + " - " + alltrim(FX7->FX7_FILIAL) + "...") // "Processando "
		endif

		if SM0->(dbSeek( cEmpAnt + FX7->FX7_FILIAL ))
			cFilAnt := SM0->M0_CODFIL

			if RecLock("FX7",.F.)			
				if lCreden
					lAtualiza := .T.
					FX7->FX7_CREDEN := cCreden
					FX7->FX7_CREKEY := cKey
					FX7->FX7_STATUS	:= "1"
				endif

				if lCert
					nPos := aScan( aConfCert, { |X| X[1] == FX7->FX7_FILIAL } )
					if nPos == 0 
						
						cIdEnt := nil
						if lSay
							oSay:SetText(STR0047 + ": " + alltrim(FX7->FX7_FILIAL) + "...") // "Realizando a configuração do certificado para filial"
						endif

						// cStatus
						//"2"  - Certificado configurado com sucesso 
						//"3"  - Certificado com problema na configuração 
						if ConfCert(@cIdEnt,cUrl,,nTipo,cCert,cKeyCert,cPassWord,cSlot,cLabel,cModulo,cIdHex,@cCertRes)

							cStatus := IIF(SpedValidCert(cIdEnt, cUrl),'2','3')
							If cStatus == "2"
								lAtualiza:=.T.
							elseIf cStatus == "3"
								cRes:=  cRes + LINHA + cFilAnt + LINHA + ENTER + cCertRes + ENTER
							endif
						else

							cStatus	:= "3"  
							cRes := cRes + LINHA + cFilAnt + LINHA + ENTER + cCertRes + ENTER
						endif

						aAdd( aConfCert, { FX7->FX7_FILIAL, cStatus } )
					else
						cStatus := aConfCert[nPos][2]
					endif
					FX7->FX7_STCERT := cStatus
				endif
				FX7->(MsUnLock())

			endif

			if lAtualiza
				nProc++
			endif
	
		endif
	next

	cFilAnt := cBkpFilAnt

	restArea(aAreaSM0)
	restArea(aAreaFX7)

return

/*/{Protheus.doc} FX7DesKey
	Retornar a chave descriptografada

	@author Valter Silva
	@since  07/07/2020
/*/
function FX7DesKey(cChave)
	local cRet := ""
	if isInCallStack("useTSSAuth") .and. !empty(cChave) .and. !isInCallStack("StaticCall")
		cRet := rc4crypt( alltrim(cChave) , CRYPTKEY, .F., .T.)
	endif
return cRet

/*/{Protheus.doc} TSSAtuFX7
	Realiza o atualização dos dados da empresa na tabela FX7

	@author Valter Silva
	@since  07/07/2020
/*/
static function TSSAtuFX7(oSay, aModelos)
    local aArea      := {}
    local aAreaSM0   := {}
	local aAreaFX7	 := {}
    local nTotal	 := 0
	local nFiliais	 := 0
    local lSay		 := .F.
    local cGroup     := FWGrpCompany()
	local lInclui	 := .F.
	local nContador	 := 0
	local nPosGrp	 := 0
	local nIni		 := 0
	local nFim 		 := 0
	local nMod		 := 1
	local cModelo	 := ""

	default oSay	 := nil
	default aModelos := {""}

	aArea := GetArea()
	aAreaSM0 := SM0->( GetArea() )

    aSort(aRetSM0, , , {|x,y| x[1]+x[2] < y[1]+y[2]})
    nPosGrp := aScan(aRetSM0, {|x| alltrim(x[1]) == alltrim(FWGrpCompany()) } )

	nTotal := len(aRetSM0)
    lSay := valtype(oSay) == "O"

    dbSelectArea("FX7")
	aAreaFX7 := FX7->( GetArea())

	if( ( _lCpoMod <> nil .and. _lCpoMod ) , FX7->(dbSetOrder(2)) /* FX7_FILIAL + FX7_MODELO */ , FX7->(dbSetOrder(1)) /*FX7_FILIAL + FX7_CREDEN*/ )

	nIni := 1
	nFim := (if((nTotal - nPosGrp) == 0,nFim := 1,(nTotal - nPosGrp))) * len(aModelos)

	for nMod := 1 to len(aModelos)

		if _lCpoMod <> nil .and. _lCpoMod
			cModelo := PadR(aModelos[nMod], len(FX7->FX7_MODELO)) 
		endif

		for nFiliais := nPosGrp to nTotal

			if !(alltrim(aRetSM0[nFiliais][1]) == alltrim(cGroup))
				exit
			endif

			if !SM0->(dbSeek( cGroup + PadR(aRetSM0[nFiliais][2], len(SM0->M0_CODFIL))))
				loop
			endif

			if lSay
				oSay:SetText(STR0015 + " " + alltrim(str(nIni)) + " " + STR0016 + " " + alltrim(str(nFim)) + "...") // "Processando " # " de "
			endif

			lInclui := if((_lCpoMod <> nil .and. _lCpoMod ), !FX7->(dbSeek(PadR(SM0->M0_CODFIL, len(FX7->FX7_FILIAL)) + cModelo)), !FX7->(dbSeek(PadR(SM0->M0_CODFIL, len(FX7->FX7_FILIAL)))) )
			nIni += 1
			if lInclui
				if RecLock("FX7", lInclui)
					nContador ++
					FX7->FX7_FILIAL := SM0->M0_CODFIL
					if _lCpoMod <> nil .and. _lCpoMod
						FX7->FX7_MODELO := aModelos[nMod]
					endif
					FX7->(MsUnLock())
				endif
			endif

		next nFiliais

	next nMod

	ApMsgInfo( STR0012 + " " + alltrim( Str( nContador ) ) + " " + STR0013 ) // 'Foram atualizados ' # ' registros.'

    restArea(aArea)
    restArea(aAreaSM0)
	restArea(aAreaFX7)

return 

/*/
{Protheus.doc} SpedCgInit
	Verifica se a tabela esta vazia para dar a primeira carga automatica. 

	@author Valter Silva
	@since  07/07/2020
/*/
function SpedCgInit(cCarga)
	local lRet		:= .T.
	local oSay		:= nil
	local aModelos	:= {""}

	default cCarga := 'A'

	if _lAdmin .or. cCarga == "A"
		dbSelectArea("FX7")
		If (FX7->(BOF()) .and. FX7->(EOF())) .or. cCarga == "M"  //"M-manual"
			if (lRet := ViewModFX7(@aModelos, cCarga))
				FWMsgRun(, {|oSay| TSSAtuFX7(oSay, aModelos) }, STR0010, STR0011) // "Aguarde # "Carregando informações das empresas/filiais..."
			endif
			FX7->( dbGoTop() )
		endif
	else
		Help( "", 1, "SEMPERM" )
	endIf

return lRet

/*/
{Protheus.doc} AdmSM0
	Carrega os dados da empresa

	@author Valter Silva
	@since  07/07/2020
/*/
Static function AdmSM0()
	local aArea		 := SM0->( GetArea() )
	local aRetSM0	 := {}

	if ExistFunc("FWLoadSM0")
		aRetSM0	:= FWLoadSM0(.T. , .T.)
	else
		DbSelectArea( "SM0" )
		SM0->( DbGoTop() )
		while SM0->( !Eof() )
			aAdd( aRetSM0, {;
				SM0->M0_GRPEMP  ,;
				SM0->M0_CODFIL  ,;
				SM0->M0_EMPRESA ,;
				SM0->M0_UNIDNEG ,;
				SM0->M0_FILIAL  ,;
				SM0->M0_NOME    ,;
				"" 				,;
				SM0->M0_SIZEFIL ,;
				SM0->M0_LEIAUTE ,;
				SM0->M0_EMPOK   ,;
				SM0->M0_USEROK  ,;
				SM0->(Recno())  ,;
				SM0->M0_LEIAEMP ,;
				SM0->M0_LEIAUN  ,;
				SM0->M0_LEIAFIL ,;
				SM0->M0_STATUS  ,;
				SM0->M0_NOMECOM ,;
				SM0->M0_CGC     ,;
				SM0->M0_DESCEMP ,;
				SM0->M0_DESCUN  ,;
				SM0->M0_DESCGRP ,;
				SM0->M0_IDMID   ,;
				SM0->M0_PICTURE ;
			})
			SM0->( DbSkip() )
		end
	endif
	RestArea( aArea )
	
return aRetSM0

/*/
{Protheus.doc} VldMarkAll
	Valida os campos obrigatórios da empresa para marcação de todas as empresas/filiais

	@author Valter Silva
	@since  07/07/2020
/*/
Static Function VldMarkAll()
	local oSay		 := nil
	
	FWMsgRun(, {|oSay| MarkAll(oSay ) }, STR0010, STR0018 ) // "Aguarde # "Validando todos os registros..."

return

/*/
{Protheus.doc} MarkAll
	Marca/Desmarca todos os registros

	@author Valter Silva
	@since  07/07/2020
/*/
Static Function MarkAll(oSay)
	local lSay		:= .F.
	local lProc		:= .T.
	local cModelo	:= ""
	local lMarcaReg := .F.
	local lMarca	:= nil // deixa como nil para que não alterar o fluxo quando o campo FX7_MODELO não existir

	default oSay	 := nil
    
	lSay := valtype(oSay) == "O"

	lProc := SelModAut(@cModelo, @lMarcaReg)

	if lProc
		FX7->( dbGoTop() )
		while !FX7->( EOF() )

			if lSay
				oSay:SetText(STR0021 + FX7->FX7_FILIAL) // "Validando empresa/filial "
			endif

			if !empty(cModelo)
				if FX7->FX7_MODELO $ cModelo
					lMarca := lMarcaReg
				else
					lMarca := .F.
				endif
			endif

			MarkReg(lMarca)

			FX7->( dbSkip() )
		endDo

		FX7->( dbGoTop() )
		oMark:Refresh(.T.)
		oMark:GoTop()

	endif

return

/*/
{Protheus.doc} MarkReg
	Marca ou desmarca o registro da tabela FX7

/*/
static function MarkReg(lMarca)
	local cMarca := ""

	if ( lMarca == nil .and. (empty(FX7->FX7_OK) .or. !alltrim(FX7->FX7_OK) == alltrim(cMrcCfgTSS)) ) .or. lMarca
		cMarca := cMrcCfgTSS
	endif

	if RecLock("FX7", .F.)
		FX7->FX7_OK := cMarca
		FX7->(msUnLock())
	endif

return

/*/
{Protheus.doc} SpedExcCFG
	Exclusão do Registro

	@author Valter Silva
	@since  07/07/2020
/*/
function SpedExcCFG()
	local nCt        := 0
	local cMarca	 := ""
	local lPergunta  := .F.
	local lMark      := .F.

	if _lAdmin
		cMarca := if( type("oMark") == "O" , oMark:Mark() , "" )
		FX7->( dbGoTop() )

		while !FX7->( EOF() )
			if !empty(cMarca) .and. oMark:IsMark(cMarca)
				lMark := .T.

				if lPergunta .or. MsgYesNo(STR0023,STR0040,"YESNO") // "Deseja confirmar a exclusão das empresas/filiais marcadas?"
					lPergunta := .T.
				else
					exit
				endif
				if lPergunta
					if RecLock("FX7",.F.)
						FX7->(dbDelete())
						FX7->(msUnLock())
						nCt++
					endif
				endif
			endif
			FX7->( dbSkip() )
		endDo

		If !lMark
			ApMsgInfo(STR0020) // Não foram marcados registros para processamento.
		elseIf nCt > 0
			ApMsgInfo( STR0024 + alltrim( Str( nCt ) ) + " " + STR0013 ) // 'Foram excluidos # ' registros.'
		endif
	else
		Help( "", 1, "SEMPERM" )
	endIf

return

/*/
{Protheus.doc} SPEDCpoSM0
	Função para buscar campo na SIGAMAT.EMP
	@author Valter Silva
	@since  25/02/2021
/*/      
function SPEDCpoSM0(cCodFil,nIndCampo)
	local nPos      := 0 
	local cCampo    := ""

	default cCodFil	  := ""
	default nIndCampo := 1

	if (nPos := aScan(aRetSM0, {|x| alltrim(x[2]) == alltrim(cCodFil) .and. alltrim(x[1]) == alltrim(FWGrpCompany()) })) > 0
		cCampo := aRetSM0[nPos][nIndcampo]
		if nIndcampo == 18
			if len(alltrim(cCampo)) == 11
				cCampo := Transform(cCampo,"@R 999.999.999-99") 
			else
				cCampo := Transform(cCampo,"@R 99.999.999/9999-99")
			endif
		endif
	endif

Return cCampo

/*/
{Protheus.doc} ViewMsg
	Função para apresentação de mensagem de validação.

	@author Valter Silva
	@since  11/06/2020
/*/
Static function ViewMsg(cMsg)
	local oDlgView	 := nil
	local oPanel	 := nil
	local oSayView	 := nil
	local oGetView	 := nil
	local oFont		 := nil
	local oButton	 := nil
	local cLabel	 := STR0036 //"Verifique as inconsistências abaixo"

	default cMsg	 := ""
    
	if !empty(cMsg)

		oFont := TFont():New("Courier New",09,15)

		define MsDialog oDlgView Title STR0032 From 9,0 To 37,84    // "Houve problemas para configurar algumas filiais:"

			oPanel := TPanel():New(0, 0, "", oDlgView,, .F., .F.,,, 90, 165)
			oPanel:Align := CONTROL_ALIGN_ALLCLIENT

			oSayView := TSay():New(05,015, {|| cLabel },oDlgView,,,,,,.T.,,,190,330)
 			oGetView := TMultiget():New(15,10,{|| cMsg },oDlgView,315,169,oFont,,,,,.T.)
			oGetView:lWordWrap := .T.
			oGetView:lReadOnly := .T.
			oGetView:EnableVScroll(.T.)
			oGetView:EnableHScroll(.T.)

			oButton := TButton():New( 190, 285, STR0033 , oDlgView, { || oDlgView:end() }, 40,15,,,,.T.) // "Fechar" 
	
		activate MsDialog oDlgView centered

	endif

return

/*/
{Protheus.doc} FX3GetCrt
	Função para selecione o arquivo Arquivos .PEM e pfx.

	@author Valter Silva
	@since  17/06/2020
/*/
function FX3GetCrt()
	local oModel	:= FWModelActive()
	local oModFX7	:= oModel:GetModel('FORMFX7')
	local nTipo		:= val(oModFX7:GetValue("FX7_TIPO"))

	cCrtFile := cGetFile( if(nTipo == 1,STR0034+".PEM |*.PEM",STR0034+"(.PFX)|*.PFX|"+STR0034+"(.P12)|*.P12"),+STR0035,0,"",.T.,GETF_LOCALHARD)

return !empty(cCrtFile)

function FX3RetCrt()
return cCrtFile

/*
{Protheus.doc} SpedAjURL
	Função para validar a URL informada
	@author Valter Silva
	@since  17/06/2020
/*/
function SpedAjURL()
	local lRet		:= .T.
	local oModel	:= FWModelActive()
	local oModFX7	:= oModel:GetModel('FORMFX7')
	local cUrlcPL	:= oModFX7:GetValue("FX7_URL")

	iF !empty(cUrlcPL) .and. !("http" == lower(substr(alltrim(cUrlcPL),1,4)))
		Help( ,, 'SPEDCFGTSS',, STR0048 + CHR(13) + CHR(10) + STR0049, 1, 0 ) // "Informe corretamente a URL" # "Por exemplo: http://localhost:8080"
		lRet := .F.
	endif

return lRet

/*/{Protheus.doc} SpedStCert
Função que atualiza status do certificado.
@author Valter Silva
@since  25/06/2021
/*/
Function SpedStCert(lRetorno, nTipo, cModelo, cUrl, cIdEnt)
	local aAreaFX7	 := {}
	local cStatus    := ""
	local lSeek 	 := .F.

	default lRetorno := .T.
	default nTipo	 := 2
	default cModelo	 := "0"

 	dbSelectArea("FX7")
	aAreaFX7 := FX7->( GetArea())

	if _lCpoMod == nil
		_lCpoMod := FX7->(ColumnPos("FX7_MODELO")) > 0 .and. OpcIntCred() == 1
	endif

	if( _lCpoMod , FX7->(dbSetOrder(2)) /* FX7_FILIAL + FX7_MODELO */ , FX7->(dbSetOrder(1)) /*FX7_FILIAL + FX7_CREDEN*/ )
	lSeek := if( _lCpoMod , FX7->(dbSeek(PadR(SM0->M0_CODFIL, len(FX7->FX7_FILIAL)) + PadR(cModelo, len(FX7->FX7_MODELO)) )), FX7->(dbSeek(PadR(SM0->M0_CODFIL, len(FX7->FX7_FILIAL)))) )

	if lSeek 

		if !lRetorno
			cStatus := '3'
		else		
			cStatus := IIF(SpedValidCert(cIdEnt, cUrl),'2','3')
		endif
 
		if RecLock("FX7", .F.)
			FX7->FX7_STCERT  := cStatus
			FX7->(MsUnLock())
		endif
	endif
	RestArea( aAreaFX7 )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewModFX7
Interface para escolher o modelo de credencial para ser utilizado

/*/
//-------------------------------------------------------------------
static function ViewModFX7(aModelos, cOpcao, lMarcaReg)
	local oViewMod	 := nil
	local oBrwMod	 := nil
	local aComboBox	 := {}
	local nCombo	 := 0
	local bConfirmar := { || nil }
	local bCancelar	 := { || nil }
	local aOpcoes	 := {}
	local aColumns	 := {}
	local lProc		 := .T.
	local lOk		 := .T.
	local nPos		 := 0
	local oPUp		 := nil
	local oTelaMod	 := nil
	local cIdUp		 := ""
	local cIdDown	 := ""
	local oPDown	 := nil
	local oButMarca	 := nil
	local oButDesm	 := nil
	local oButCanc	 := nil

	default aModelos  := {}
	default cOpcao	  := "A"
	default lMarcaReg := .F.

	if _lCpoMod <> nil .and. _lCpoMod .and. OpcIntCred() == 1 // define por modelo 

		if !cOpcao == "A"
			lProc := FX7AtuMod(cOpcao)
		endif

		lOk := .F.
		if lProc
			aComboBox := StrTokArr(alltrim(getSX3Cache("FX7_MODELO", "X3_CBOX")), ";")
			for nCombo := 1 to len(aComboBox)
				aAdd( aOpcoes, {.T., SubStr( aComboBox[nCombo], at( "=", aComboBox[nCombo]) + 1, len(aComboBox[nCombo]) ) } )
			next

			if cOpcao == "A"
				bConfirmar := { || if( MsgYesNo(STR0050) , ( if( lOk := VldMod(aOpcoes) ,oViewMod:end(),nil)), nil) } // "Deseja confirmar?"
				bCancelar := { || if( MsgYesNo(STR0051) , oViewMod:end(), nil)} // "Deseja cancelar?"
			elseif cOpcao == "M"
				bConfirmar := { || if( MsgYesNo(STR0052) , ( if( lOk := VldMod(aOpcoes) ,oViewMod:end(),nil)), nil) } // "Deseja confirmar a atualização?"
				bCancelar := { || if( MsgYesNo(STR0051) , oViewMod:end(), nil)} // "Deseja cancelar?"
			elseif cOpcao == "MARCACAO"
				bConfirmar := { || if( MsgYesNo(STR0050), oViewMod:end(),nil)} // "Deseja confirmar?"
				bCancelar := { || oViewMod:end() }
			endif

			oViewMod := TDialog():New(0,0,440,640, STR0053,,,,,,,,oMainWnd,.T.) // "Modelos de Credenciais"
			oViewMod:lCentered := .T.

			oPUp := oViewMod
			if cOpcao == "MARCACAO"
				oTelaMod := FWFormContainer():New( oViewMod )
				cIdUp := oTelaMod:CreateHorizontalBox( 90 )
				cIdDown := oTelaMod:CreateHorizontalBox( 10 )
				oTelaMod:Activate( oViewMod, .T. )
				oPUp := oTelaMod:GeTPanel( cIdUp )
				oPDown := oTelaMod:GeTPanel( cIdDown )
			endif

			oBrwMod := FwBrowse():New()
			oBrwMod:setDataArray()
			oBrwMod:setArray( aOpcoes )
			oBrwMod:disableConfig()
			oBrwMod:disableReport()
			oBrwMod:disableLocate()
			oBrwMod:setProfileId( "view_mod_fx7" )
			oBrwMod:DisableFilter()
			oBrwMod:setInsert( .F. )
			oBrwMod:setDelete( .F. )
			oBrwMod:setEditCell( .F. )
			oBrwMod:setOwner( oPUp )

			oBrwMod:AddMarkColumns({|| if( aOpcoes[oBrwMod:nAt][1], 'LBOK', 'LBNO') }, { |oBrwMod| MarkMod( oBrwMod ) }, { |oBrwMod| MarkMod( oBrwMod, .T. ) })

			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( { || aOpcoes[oBrwMod:nAt,02] } )
			aColumns[Len(aColumns)]:SetSize( 20 )
			aColumns[Len(aColumns)]:SetDecimal( 0 )
			aColumns[Len(aColumns)]:SetTitle( STR0054 ) // "Modelo de Credencial"
			aColumns[Len(aColumns)]:SetEdit(.T.)
			aColumns[Len(aColumns)]:SetReadVar( 'CPO_02' )

			oBrwMod:SetColumns(aColumns)
			oBrwMod:activate( .T. )

			if cOpcao == "MARCACAO"
				oButMarca := TButton():New( 05, (oPDown:nWidth/2)-50, STR0057 , oPDown, { || if( MsgYesNo(STR0055 ), (lOk := .T. , lMarcaReg := .T. , oViewMod:end()), nil) }, 40,10,,,,.T.) // "Deseja marcar os modelos selecionados?" # "Marcar"
				oButDesm := TButton():New( 05, (oPDown:nWidth/2)-100, STR0058 , oPDown, { || if( MsgYesNo(STR0056), (lOk := .T. , lMarcaReg := .F. , oViewMod:end()), nil) }, 40,10,,,,.T.) // "Deseja desmarcar os modelos selecionados?" #  "Desmarcar"
				oButCanc := TButton():New( 05, (oPDown:nWidth/2)-150, STR0059 , oPDown, { || oViewMod:end() }, 40,10,,,,.T.) // "Cancelar"
			else
				oViewMod:bInit := EnchoiceBar( oViewMod, bConfirmar , bCancelar )
			endif
			oViewMod:Activate()

			FwFreeObj(oViewMod)
			FwFreeObj(oBrwMod)
			if lOk
				aModelos := {}
				for nCombo := 1 to len(aOpcoes)
					if !aOpcoes[nCombo][1]
						loop
					endif
					if ( nPos := aScan( aComboBox, { |X| alltrim(lower(aOpcoes[nCombo][2])) $ alltrim(lower(X)) } ) ) > 0
						aAdd( aModelos, substr(alltrim(aComboBox[nPos]),1,1) )
					endif
				next
			endif
		endif
	endif

return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} OpcIntCred
Opção da interface da rotina por modelo ou padrão
	1 - define por modelo 
	0 - padrão

/*/
//-------------------------------------------------------------------
static function OpcIntCred()
	local nRet := val(SuperGetMv("MV_SPDCFGM",.F.,"0",FWCodEmp()))
return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MarkMod
Função que marca/desmarca as linhas

/*/
//-------------------------------------------------------------------
static function MarkMod(oBrw , lAll )
	local nX	 := 0

	default lAll	:= .F.

	if lAll
		for nX := 1 To LEN(oBrw:oData:aArray)
			oBrw:oData:aArray[nX][1] := !oBrw:oData:aArray[nX][1]
		next
	else
		oBrw:oData:aArray[oBrw:At()][1] := !oBrw:oData:aArray[oBrw:At()][1]
	endif
	oBrw:GoTop()
	oBrw:Refresh()

return

//-------------------------------------------------------------------
/*/{Protheus.doc} VldMod
Valida o grid de modelos de credenciais

/*/
//-------------------------------------------------------------------
static function VldMod(aOpcoes)
	local lRet	 := .F.
	local cMsg	 := ""

	begin sequence

	if aScan( aOpcoes , { |X| X[1] }) == 0
		cMsg := STR0060 // "Marque pelo menos uma opção de modelo de credencial."
		break
	endif

	end sequence

	lRet := empty(cMsg)
	if !lRet
		MsgInfo(cMsg,STR0061) // "Atenção"
	endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SelModAut
Seleciona o modelo para marcação na marcação de todas os registros FX7

/*/
//-------------------------------------------------------------------
static function SelModAut(cModelo, lMarcaReg)
	local lRet		 := .T.
	local aModelos	 := {}
	local nMod		 := 0

	default cModelo		:= ""
	default lMarcaReg	:= .T.

	if (lRet := ViewModFX7(@aModelos, "MARCACAO", @lMarcaReg))
		cModelo := ""
		for nMod := 1 to len(aModelos)
			cModelo += aModelos[nMod] + "||"
		next
		lRet := OpcIntCred() == 0 .or. !empty(cModelo)
	endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FX7AtuMod
Verifica na tabela FX7 se possui registro com FX7_MODELO em branco

/*/
//-------------------------------------------------------------------
static function FX7AtuMod(cOpcao)
	local lRet		 := .F.
	local lOk		 := .F.
	local oViewUpMod := nil
	local nRowSay	 := 0
	local nColSay	 := 0
	local nRowGet	 := 0
	local nColGet	 := 0
	local nSizeJump	 := 0
	local oFont		 := nil
	local cMsg		 := ""
	local oSayText	 := nil
	local oSayMod	 := nil
	local oGetMod	 := nil
 	local aComboBox	 := {}
	local cCombo	 := ''
	local bConfirmar := { || nil }
	local bCancelar	 := { || nil }

	default cOpcao := ""

	// Verifico se possui registro com FX7_MODELO em branco
	if !(lRet := FX7EmpMod())

		lRet := .F.
		oViewUpMod := TDialog():New(0,0,260,640,STR0053,,,,,,,,oMainWnd,.T.) // "Modelos de Credenciais"
		oViewUpMod:lCentered := .T.

		nRowSay := 035
		nColSay := 005
		nRowGet := 035
		nColGet := 050
		nSizeJump := 020
		oFont := TFont():New( "Consolas", 6, 16 )

		cMsg := STR0062 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + ; // "Existem registros que não possuem modelo de credencial definido."
				STR0063 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + ; // "Por favor, selecione uma das opções abaixo para atualizar para o modelo, no qual já está sendo utilizada pelo sistema."
				STR0064 // "Serão atualizadas as filiais que possuem registros com modelo de credencial em branco."
		oSayText := TSay():New( nRowSay, nColSay, { || cMsg }, oViewUpMod,,oFont,,,,.T.,CLR_RED,CLR_WHITE, (oViewUpMod:nWidth/2), (oViewUpMod:nHeight/2) )

		nRowSay	:= nRowSay + (nSizeJump*3)
		nRowGet	:= nRowGet + (nSizeJump*3)
		
		oSayMod := TSay():New( nRowSay, nColSay, { || STR0054 + ": " }, oViewUpMod,,,,,,.T.,CLR_BLUE,CLR_WHITE, 050, 015) // "Modelo de Credencial
		aComboBox := StrTokArr(alltrim(getSX3Cache("FX7_MODELO", "X3_CBOX")), ";")
		aAdd( aComboBox, " " )
		cCombo := aComboBox[len(aComboBox)]
		oGetMod := TComboBox():New(nRowSay,nColGet,{|u|if(PCount()>0,cCombo:=u,cCombo)},aComboBox,100,20,oViewUpMod,,,,,,.T.,,,,,,,,,'cCombo')

		bConfirmar := { || if( lOk := VldSelMod(cCombo,aComboBox),oViewUpMod:end(),nil) }
		bCancelar := { || if( MsgYesNo(STR0051) , oViewUpMod:end(), nil)} // "Deseja cancelar?"
 		oViewUpMod:bInit := EnchoiceBar( oViewUpMod, bConfirmar , bCancelar )
		oViewUpMod:Activate()

		FwFreeObj(oViewUpMod)
 
		if lOk .and. ProcModEmp(cCombo, cOpcao)
			if cOpcao == "M"
				lRet := MsgYesNo(STR0065 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0066) // "Atualização realizada com sucesso." # "Deseja incluir um novo modelo?"
			else
				lRet := .T.
				MsgInfo(STR0065, STR0061) // "Atualização realizada com sucesso." # "Atenção"
			endif
		endif

	endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldSelMod
Valida o modelo selecionado para ser atualizar os registros com 
FX7_MODELO em branco

/*/
//-------------------------------------------------------------------
static function VldSelMod(cCombo, aComboBox)
	local lRet		 := .F.
	local cMsgError	 := ""
	local cDescCbo	 := ""

	default cCombo := ""

	if empty(cCombo)
		cMsgError := STR0067 // "Selecione uma opção."

	else
		cDescCbo := aComboBox[aScan( aComboBox, { |X| cCombo == substr(X,1,1) })]
		lRet := MsgYesNo(STR0068 + ": '" + cDescCbo + "'?" + CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0069) // "Deseja confirmar o modelo # "Serão atualizadas as filiais que possuem registros com modelo de credencial em branco."

	endif

	if !empty(cMsgError)
		MsgInfo(cMsgError,STR0061) // "Atenção"
		lRet := .F.
	endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcModEmp
Verifica na tabela FX7 se possui registro com FX7_MODELO em branco

/*/
//-------------------------------------------------------------------
static function ProcModEmp(cCombo, cOpcao)
	local lRet		 := .T.
	local cQryAlias	 := ""
	local aAreaFX7	 := {}
	local nConut	 := 0

	dbSelectArea("FX7")
	aAreaFX7 := FX7->(getArea())
	cQryAlias := GetNextAlias()

	BeginSql Alias cQryAlias
		SELECT R_E_C_N_O_ RECNO_FX7
		FROM %Table:FX7% FX7
		WHERE FX7.D_E_L_E_T_ = ' ' AND FX7.FX7_MODELO = ' '
	EndSql

	(cQryAlias)->(dbGoTop())
	nConut := 0
	while (cQryAlias)->(!eof())
		FX7->(dbGoTo((cQryAlias)->RECNO_FX7))
		if FX7->(Recno()) == (cQryAlias)->RECNO_FX7
			if reclock("FX7", .F.)
				FX7->FX7_MODELO := cCombo
				FX7->(MsUnlock())
				nConut += 1
			endif
		endif
		(cQryAlias)->(dbSkip())
	end
	(cQryAlias)->(dbCloseArea())

	if cOpcao == "M" .and. nConut > 0 .and. nConut < len(aRetSM0)
		TSSAtuFX7(, {cCombo})
	endif

	restArea(aAreaFX7)

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FX7EmpMod
Verifica na tabela FX7 se possui registro com FX7_MODELO em branco

/*/
//-------------------------------------------------------------------
static function FX7EmpMod()
	local cQryAlias	 := ""
	local lRet		 := .F.

	cQryAlias := GetNextAlias()

	BeginSql Alias cQryAlias
		SELECT COUNT(*) TOTAL
		FROM %Table:FX7% FX7
		WHERE FX7.D_E_L_E_T_ = ' ' AND FX7.FX7_MODELO = ' '
	EndSql

	(cQryAlias)->(dbGoTop())
	lRet := (cQryAlias)->TOTAL == 0
	(cQryAlias)->(dbCloseArea())

return lRet
