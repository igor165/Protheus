#include "protheus.ch"
#include "totvs.ch"
#include "WizardTF.ch"

/*/{Protheus.doc} WizardTF
Wizard para ativação da integração com a TechFin

@author     Victor Furukawa
@version    1.0
@type       Function
@since      28/01/2021
/*/

Main Function WizardTF1()

	MsApp():New( "SIGAFIN" )
	oApp:cInternet  := Nil
	__cInterNet := NIL
	oApp:bMainInit  := { || ( oApp:lFlat := .F. , TechFinWiz() , Final( "Encerramento Normal" , "" ) ) } //"Encerramento Normal"
	oApp:CreateEnv()
	OpenSM0()

	PtSetTheme( "TEMAP10" )
	SetFunName( "WIZARDTF1" )
	oApp:lMessageBar := .T.

	oApp:Activate()

Return Nil


/*/{Protheus.doc} TechFinWiz
Montagem do Step do FWCarolWizard para ativação da integração com a TechFin

@author     Victor Furukawa
@version    1.0
@type       Function
@since      28/01/2021
/*/

Static Function TechFinWiz()

	Local oWizard       As Object
	Local cDescription  As Character
	Local cReqMsg       As Character
	Local cReqDes       As Character
	Local cReqCont      As Character
	local cReqLib       As Character
	Local bConstruction As CodeBlock
	Local bProcess      As CodeBlock
	Local bNextAction   As CodeBlock
	Local bReqVld       As CodeBlock
	local bReqlib       As CodeBlock
	Private cStep       As Character

	nStep := 1

	oWizard := FWCarolWizard():New()

	cDescription   := STR0001
	bConstruction  := { | oPanel | cStep := StepProd(oPanel)}
	bProcess       := { | cGrpEmp, cMsg | iIf(cStep == "TOTVS Antecipa", FinTFWizPg(), iIf(cStep == "TOTVS Mais Prazo", ProcAnt( cGrpEmp, cStep), .T.))}
	bNextAction    := { || VldStep()}
	cReqDes        := STR0002
	cReqCont       := GetRpoRelease()
	bReqVld        := { || GetRpoRelease() >= "12.1.025"}
	cReqMsg        := STR0003
	cReqLib        := FwtechfinVersion()
	bReqlib        := { || FwtechfinVersion() >= "2.4.0" }

	oWizard:SetWelcomeMessage( STR0004 )
	oWizard:AddRequirement( cReqDes, cReqCont, bReqVld, cReqMsg )
	oWizard:AddRequirement( STR0033, cReqLib, bReqlib, STR0034 )
	oWizard:AddStep( cDescription, bConstruction, bNextAction)
	oWizard:AddProcess( bProcess )
	oWizard:UsePlatformAccess(.T.)
    IF cReqLib >= "2.4.0"
		oWizard:SetExclusiveCompany(.F.)
	EndIf
	oWizard:Activate()
Return Nil

/*/{Protheus.doc} StepProd
Montagem tela para escolha do Produto a Ser configurado

@author     Victor Furukawa
@version    1.0
@type       Function
@since      28/01/2021
@return     Character, Retorna o codigo do Produto
/*/

Static Function StepProd(oPanel) as Character

	Local oBmp as Object
	Local cRet as Character

	cRet := StepWiz()

	@ 005,135 BITMAP oBMP RESOURCE "Techfin.bmp" OF oPanel PIXEL NOBORDER
	oBmp:lAutoSize := .T.

	@ 072, 010 SAY STR0005 + cRet SIZE 200,20 OF oPanel PIXEL
	@ 098, 010 SAY STR0006 SIZE 200,20 OF oPanel PIXEL

Return cRet


/*/{Protheus.doc} ProcAnt() 
Rotina de Processamento da gravalçao dos parâmetros

@author     Victor Furukawa
@version    1.0
@type       Function
@since      28/01/2021
@param      cGrpEmp, character, código do grupo da Empresa
@param      cStep, character, produto a ser configurado
@return     Logical, Sucesso ou insucesso da operação
/*/

Static Function ProcAnt( cGrpEmp as Character, cStep as Character) as Logical

	Local lRet   as Logical

	Local oDlg   as Object
	Local oCbx   as Object
	Local oGrp   as Object

	Local nI as Numeric

	Local aMotBx     as Array
	Local aDescMotbx as Array

	Private cPref    as Character
	Private cTipo    as Character
	Private cNat     as Character
	Private cForn    as Character
	Private cLoja    as Character
	Private cMotBx   as Character
	Private cCodVa   as Character
	Private cDescVa  as Character

	cPref     := space(TamSX3("E2_PREFIXO")[1])
	cTipo     := space(TamSX3("E2_TIPO"   )[1])
	cNat      := space(TamSX3("ED_CODIGO" )[1])
	cForn     := space(TamSX3("A2_COD"    )[1])
	cLoja     := space(TamSX3("A2_LOJA"   )[1])

	cCodVa    := space(TamSX3("FKC_CODIGO")[1])
	cDescVa   := space(TamSX3("FKC_DESC")[1])

	aMotBx     := ReadMotBx()
	aDescMotbx := {}
	nI         := 1
	lRet       := .T.

	SUPERGETMV() // Para Limpar o cache do Supergetmv

	If ValidParam()

		DEFINE MSDIALOG oDlg TITLE STR0007 STYLE DS_MODALFRAME FROM 180,180 TO 550,700 PIXEL
		oDlg:lEscClose := .F.

		@ 000,005 GROUP oGrp TO 140,255 LABEL STR0008 PIXEL

		@ 012, 010 SAY STR0009 SIZE 200,20 OF oDlg PIXEL
		@ 010, 050 MSGET cPref SIZE 45, 09 OF oDlg PIXEL WHEN .T. PICTURE "@!" VALID !VAZIO()

		@ 027, 010 SAY STR0010 SIZE 200,20 OF oDlg PIXEL
		@ 027, 050 MSGET cTipo SIZE 45, 09 OF oDlg  PIXEL F3 "05" WHEN .T. PICTURE "@!" VALID !VAZIO()

		@ 044, 010 SAY STR0011 SIZE 200,20 OF oDlg PIXEL
		@ 044, 050 MSGET cNat SIZE 45, 09 OF oDlg PIXEL F3 "SED" WHEN .T. VALID ExistCpo("SED",cNat) .AND. !VAZIO() PICTURE "@!"

		@ 061, 010 SAY STR0012 SIZE 200,20 OF oDlg PIXEL
		@ 061, 050 MSGET cForn SIZE 45, 09  OF oDlg PIXEL F3 "SA2" WHEN .T. VALID ExistCpo("SA2",cForn) .AND. !VAZIO() PICTURE "@!"

		@ 078, 010 SAY STR0013 SIZE 200,20 OF oDlg PIXEL
		@ 078, 050 MSGET cloja SIZE 45, 09 OF oDlg PIXEL WHEN !Empty(cForn) VALID ExistCpo("SA2",cForn+cLoja) .AND. !VAZIO() PICTURE "@!"

		@ 095, 010 SAY STR0014 SIZE 200,20 OF oDlg PIXEL

		//Retorna o Array aDescMotBx contendo apenas a descricao do motivo das Baixas

		For nI := 1 to len( aMotBx )
			If substr(aMotBx[nI],34,01) == "P"
				AADD(aDescMotbx,substr(aMotBx[nI],01,3))
			EndIf
		Next nI

		@ 095, 050 MSCOMBOBOX oCbx VAR cMotBx ITEMS aDescMotbx SIZE 65,47 OF oDlg PIXEL

		@ 116, 010 SAY STR0015 + cDescVa SIZE 200,20 OF oDlg PIXEL

		@ 124, 010 BUTTON STR0016 SIZE 030, 013 PIXEL OF oDlg ACTION ( cCodVa := SelVa())

		@ 160,110 BUTTON STR0017 SIZE 030, 025 PIXEL OF oDlg ACTION (GravaPar(),oDlg:End())

		ACTIVATE DIALOG oDlg CENTERED

	Endif

	lRet := ValidParam()

Return lRet

/*/{Protheus.doc} Gravapar
Rotina de Validação e gravação dos parâmetros

@author     Victor Furukawa
@version    1.0
@type       Function
@since      28/01/2021
@return     Logical, Sucesso ou insucesso da operação
/*/

Static Function GravaPar() as Logical

	Local lRet     as Logical
	Local cPeriod  as Character
	Local cAgend   as Character
	Local cMsgErro as Character

	cPeriod  := ""
	cAgend   := ""
	cMsgErro := ""

	lRet := .T.

	If Len(alltrim(cPref)) > TamSX3("E2_PREFIXO")[1]
		Help(Nil, Nil, "NONAT", "", STR0018 + FWCompany() , 1,;
			,,,,,,{STR0019})
	else
		PUTMV("MV_PRETECF" , PADR(alltrim(cPref), TamSX3("E2_PREFIXO")[1]))   //Prefixo
	Endif

	dbSelectArea('SX5')
	dbSetOrder(1)
	If dbSeek(xFilial('SX5')+"05"+ PADR(alltrim(cTipo), TamSX3("E2_TIPO")[1]))
		PUTMV("MV_TPTECF"  , PADR(alltrim(cTipo), TamSX3("E2_TIPO")[1]))   //Tipo
	Else
		Help(Nil, Nil, "TIPTIT", "", STR0020 + FWCompany() , 1,;
			,,,,,,{STR0021})
	EndIf

	Dbselectarea("SED")
	dbSetOrder(1)
	Dbgotop()
	If dbseek(FwxFilial("SED")+ PADR(alltrim(cNat), TamSX3("ED_CODIGO")[1]))
		PUTMV("MV_NTTECF"  , PADR(alltrim(cNat), TamSX3("ED_CODIGO")[1]))   //Natureza
	else
		Help(Nil, Nil, "NONAT", "", STR0022 + FWCompany() , 1,;
			,,,,,,{STR0023})
	Endif

	DbSelectArea("SA2")
	DbSetorder(1)
	DbGotop()
	If dbseek(FwxFilial("SA2")+ PADR(alltrim(cForn), TamSX3("A2_COD")[1])+PADR(alltrim(cLoja), TamSX3("A2_LOJA")[1]))
		PUTMV("MV_FNTECF"  , PADR(alltrim(cForn), TamSX3("A2_COD")[1]))   //Fornecedor
		PUTMV("MV_LFTECF"  , PADR(alltrim(cLoja), TamSX3("A2_LOJA")[1]))   //Loja
	else
		Help(Nil, Nil, "NOFOR", "", STR0024 + FWCompany() , 1,;
			,,,,,,{STR0025})
	Endif

	PUTMV("MV_MBXTECF" , PADR(alltrim(cMotBx), TamSX3("FK1_MOTBX")[1]))   //Motivo de Baixa

	DbSelectArea("FKC")
	DbSetorder(1)
	DbGotop()

	PUTMV("MV_VATECF"  , PADR(alltrim(cCodVa), TamSX3("FKC_CODIGO")[1]))   //Codigo Valores AcessÃƒÂ³rios

	If !(ExisteJob())
		//Executa a cada 10 minutos
		cPeriod := "D(Each(.T.);Day(1);EveryDay(.F.););Execs(0144);Interval(00:10);"
		//(cFunction, cUserID, cParam, cPeriod, cTime, cEnv, cEmpFil, cStatus, dDate, nModule, aParamDef)
		cAgend := FwInsSchedule("FINA137F", "000000",, cPeriod, "00:00", Upper(GetEnvServer()), cEmpAnt + "/" + cFilAnt + ";","0", Date(), 6, {cEmpAnt, cFilAnt, "TESTE"})
		If Empty(cAgend)
			cMsgErro :=  STR0026
			FwLogMsg("INFO",, "SCHEDULER", FunName(), "", "01", cMsgErro, 0, 0, {})
		EndIf
	EndIf

Return .T.

/*/{Protheus.doc} ValidParam
Rotina de Validação dos Parametros TOTVS Mais Prazo

@author     Victor Furukawa
@version    1.0
@type       Function
@since      28/01/2021
@return     Logical, Sucesso ou insucesso da operação
/*/


Static Function ValidParam() As Logical

	Local lExiste   As Logical

	lExiste := .T.

	If !(GetMV("MV_PRETECF", .T.)) .Or. !(GetMV("MV_TPTECF", .T.)) .Or. !(GetMV("MV_NTTECF", .T.)) .Or.;
			!(GetMV("MV_FNTECF", .T.)) .Or. !(GetMV("MV_LFTECF", .T.)) .Or. !(GetMV("MV_MBXTECF", .T.)) .Or. !(GetMV("MV_VATECF", .T.))
		lExiste := .F.
		Help(Nil, Nil, "NOPARAM", "", STR0027 + FWCompany() , 1,; //"Um ou mais parÃƒÂ¢metros Financeiros do TOTVS Antecipa nÃƒÂ£o foram encontrados."
		,,,,,,{STR0028}) // "Execute o UPDDISTR de acordo com a ÃƒÂºltima expediÃƒÂ§ÃƒÂ£o contÃƒÂ­nua para criaÃƒÂ§ÃƒÂ£o dos parÃƒÂ¢metros Financeiros do TOTVS Antecipa."
	EndIf

Return lExiste

/*/{Protheus.doc} Stepwiz()
Rotina de Escolha do Produto

@author     Victor Furukawa
@version    1.0
@type       Function
@since      28/01/2021
@return     Character, Codigo do produto a ser configurado
/*/

Static Function Stepwiz() as Character

	Local oDlg     as Object
	Local oButton  as Object
	Local oRadio   as Object
	Local oGrp     as Object
	Local oBmp     as Object

	Local nRadio   as Numeric

	Local aOptions as Array

	Local cRet     as Character

	nRadio :=1

	aOptions:= {"TOTVS Mais Prazo","TOTVS Antecipa","Painel Financeiro"}

	cRet := ""

	DEFINE MSDIALOG oDlg FROM 0,0 TO 200,280 STYLE DS_MODALFRAME PIXEL TITLE STR0029
	oDlg:lEscClose := .F.

	@ 00,12 BITMAP oBMP RESOURCE "Techfin.bmp" OF oDlg PIXEL NOBORDER
	oBmp:lAutoSize := .T.

	@ 031,012 GROUP oGrp TO 072,129 LABEL ("Escolha") PIXEL
	oRadio:= tRadMenu():New(40,42,aOptions, {|u|if(PCount()>0,nRadio:=u,nRadio)},oDlg,,,,,,,,100,20,,,,.T.)

	@ 85,40 BUTTON oButton PROMPT STR0030 OF oDlg PIXEL ACTION oDlg:End()

	ACTIVATE MSDIALOG oDlg CENTERED

	cRet := aOptions[nRadio]

Return cRet


/*/{Protheus.doc} ExisteJob
Verifica se o JOB existe no grupo de empresa atual.

@type       Function
@author     Victor Furukawa
@since      05/11/2020
@version    P12.1.27
@param      cAgendamen, character, código do agendamento
@return     logical, verdadeiro caso encontre o job para empresa desejada
@obs        rotina possui referência direta as tabelas de framework XX1 e XX2 pois não existe função que atenda a este requisito. A issue DFRM1-16827 foi aberta para este propósito
/*/
Static Function ExisteJob() As Logical

	Local aSchd       As Array

	Local lCriado     As Logical

	Local oDASched    As Object

	Local nX          As Numeric

	lCriado := .F.

	oDASched := FWDASchedule():New() //chama o objeto do schedule
	aSchd:=oDASched:readSchedules() //como voce não sabe quem é, tem que ler todos

	For nX := 1 to Len(aSchd)

		If Alltrim(aSchd[nX]:GetFunction())== 'FINA137F'
			lCriado := .T.
		Endif

	Next

Return lCriado

/*/{Protheus.doc} SelVA
Tela para seleção do Valor Acessório

@type       Function
@author     Victor Furukawa
@since      05/11/2020
@version    P12.1.27
@return     Character, Retorna o codigo do valor acessório
/*/

Static Function SelVa() as Character

	Local cRet

	DEFINE DIALOG oDlg TITLE STR0031 FROM 180,180 TO 660,485 PIXEL

	// Cria browse que receberá as colunas
	DbSelectArea("FKC")
	oBrowse:=MsSelBr():New( 1,1,150,180,,,,oDlg,,,,,,,,,,,,.F.,'FKC',.T.,,.F.,,, )
	// Cria colunas
	oBrowse:AddColumn(TCColumn():New("Codigo",{||FKC->FKC_CODIGO },,,,"LEFT",,.F.,.F.,,,,,))
	oBrowse:AddColumn(TCColumn():New("Descrição"  ,{||FKC->FKC_DESC},,,,"LEFT",,.F.,.F.,,,,,))
	oBrowse:lHasMark := .F.
	oBrowse:lAllMark := .T.

	@ 190,060 BUTTON oButton PROMPT STR0032 SIZE 030, 025 OF oDlg PIXEL ACTION oDlg:End()


	ACTIVATE DIALOG oDlg CENTERED

	cRet    := ALLTRIM(FKC->FKC_CODIGO)
	cDescVa := ALLTRIM(FKC->FKC_DESC)

Return cRet

/*/{Protheus.doc} VldStep
Retorna um aviso para que o usuario esteja ciente para verificar o compartilhamento das tabelas SA2 e SED.

@type       Function
@author     Victor Furukawa
@since      05/11/2020
@version    P12.1.27
@return     Character, Retorna o codigo do valor acessório
/*/

Static Function VldStep()

	Local lRet   As Logical
	Local lCheck AS Logical

	Local oDlg as Object
	Local oChkBox as Object

	lRet := .T.
	lCheck := .F.

   DEFINE MSDIALOG oDlg FROM 0,0 TO 200,380 STYLE DS_MODALFRAME PIXEL TITLE STR0029
	oDlg:lEscClose := .F.

	@ 00,37 BITMAP oBMP RESOURCE "Techfin.bmp" OF oDlg PIXEL NOBORDER
	oBmp:lAutoSize := .T.

	@ 37,29 SAY "Por favor verifique a compartilhamento dos Cadastros" SIZE 200,20 OF oDlg PIXEL
	@ 47,29 SAY "Os parâmetros foram criados de maneira Compartilhada" SIZE 200,20 OF oDlg PIXEL
	@ 57,29 SAY "Principalmente os cadastros de Natureza e Fornecedor" SIZE 200,20 OF oDlg PIXEL

	@ 75,10 CHECKBOX oChkBox VAR lCheck PROMPT "Estou Ciente!" SIZE 60,15 OF oDlg PIXEL

	@ 85,40 BUTTON oButton PROMPT STR0030 OF oDlg PIXEL ACTION Iif(lCheck, oDlg:End(), "")

	ACTIVATE MSDIALOG oDlg CENTERED

Return lRet






