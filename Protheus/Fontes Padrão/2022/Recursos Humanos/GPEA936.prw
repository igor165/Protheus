#include 'GPEA936.CH'
#include 'PROTHEUS.CH'
#include 'TOTVS.ch'
#Include 'FWMVCDef.ch'
#include "fileio.ch"
#include "TBICONN.CH"
#INCLUDE "TBICODE.CH"

#DEFINE TAB Chr(09)

Static lParcial		:= .F.
Static cVersEnvio	:= ""

/*/{Protheus.doc} GPEA936
//TODO Descrição auto-gerada.
@author Samuel de Vincenzo
@since 05/04/2019
@version P12
@example
(examples)
@see (links_or_references)
/*/
function GPEA936()
Local aArea := GetArea()
Local oBrowse
Local cMsgDesatu := ""
Local lRJ7	:= .F.
Local lCTabela	  := !ChkFile("RJ7") .And. !ChkFile("RJ8")
Local aErro	:= {}
Local lContinua := .F.
Local aTitle	:= {}
Local nE	:= 0
Local nR 	:= 0
Local aResumo := {}
Local aIncons := {}

If lCTabela
 	cMsgDesatu := CRLF + OemToAnsi(STR0051) + CRLF //"Tabela RJ7 e RJ8 não encontrada. Execute o UPDDISTR - atualizador de dicionário e base de dados."
 EndIf

 	If !Empty(cMsgDesatu)
		//ATENCAO"###"Tabela RJ9 não encontrada na base de dados. Execute o UPDDISTR."
		//ATENCAO"###

		Help( " ", 1, OemToAnsi(STR0013),, cMsgDesatu, 1, 0 )
		Return
	EndIf

	//VERIFICO SE É A PRIMEIRA VEZ NA ROTINA
	DbSelectArea("RJ7")
		RJ7->(DbGoTop())
		If RJ7->(EOF())
			lRJ7 := .T.
		Endif

//Faço a validação para se certificar que as tabelas estão realmente dentro do compartilhamento correto
	vertab(@aErro,@lContinua)

If !lContinua

	For nE := 1 to Len(aErro)
		aResumo := FWTxt2Array( aErro[nE], 131)
		For nR := 1 to Len(aResumo)
			aAdd(aIncons, aResumo[nR])
		Next nR
	Next nE

	aErro := {}

	For nE := 1 To Len(aIncons)
		Aadd( aErro, aIncons[nE] )
	Next nE

	fMakeLog({aErro}, aTitle, Nil, Nil, "Filial", OemToAnsi(STR0053), "M", "P",, .F.) //"Log de Ocorrências - Carga de filial - Evento S-1020."
	Return()
Endif

// Se a tabela está vazia, executa  o programa para popular a tabela
If lRJ7

	fGp936Novo()

Else

	SetFunName("GPEA936")

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("RJ7")
	oBrowse:SetDescription(STR0001) //"Configuração das Filiais X Tabelas"

	oBrowse:DisableDetails()
	oBrowse:Activate()

EndIf


RestArea(aArea)

return Nil
/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Samuel de Vincenzo                                              |
 | Data:  05/04/2019                                                   |
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/
Static Function MenuDef()
    Local aRot := {}

    //Adicionando opções
    ADD OPTION aRot TITLE STR0002 ACTION 'VIEWDEF.GPEA936' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1 'Visualizar'
    ADD OPTION aRot TITLE STR0003 ACTION 'VIEWDEF.GPEA936' OPERATION MODEL_OPERATION_INSERT   ACCESS 0 //OPERATION 3 'Incluir'
    ADD OPTION aRot TITLE STR0004 ACTION 'VIEWDEF.GPEA936' OPERATION MODEL_OPERATION_UPDATE   ACCESS 0 //OPERATION 4 'Alterar'
    ADD OPTION aRot TITLE STR0005 ACTION 'VIEWDEF.GPEA936' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5 'Excluir'
Return aRot

/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Samuel de Vincenzo                                           |
 | Data:  05/04/2019                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 *---------------------------------------------------------------------*/
Static Function ModelDef()
    Local oModel   	:= Nil
    Local bCpCab    := {|cCampo| AllTrim(cCampo)+"|" $ "RJ7_FILIAL|RJ7_TABELA|RJ7_DESCRI|"}
    Local bCpGrd    := {|cCampo| AllTrim(cCampo)+"|" $ "RJ7_TABELA|RJ7_FILPAR|"}
    Local bPosValid := { |oModel| Gp936CPosVal( oModel )}
    Local oStruCab 	:= FWFormStruct(1, "RJ7",bCpCab)
    Local oStruGrd 	:= FWFormStruct(1, "RJ7",bCpGrd)
    Local bVldPos  	:= {}
    Local bVldCom  	:= {}
    Local aRJ7Rel  	:= {}

	//Criando o FormModel, adicionando o Cabeçalho e Grid
    oModel := MPFormModel():New("GPEA936M", /*bPreValid*/, bPosValid, )

    oModel:AddFields("FORMCAB",/*cOwner*/,oStruCab)
    oModel:AddGrid('RJ7DETAIL','FORMCAB',oStruGrd)

    oStruGrd:SetProperty('RJ7_TABELA', MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))

    aAdd(aRJ7Rel, {'RJ7_FILIAL','Iif(!inclui, RJ7->RJ7_FILIAL, FWxFilial("RJ7"))'})
    aAdd(aRJ7Rel, {'RJ7_TABELA','Iif(!inclui, RJ7->RJ7_TABELA, M->RJ7_TABELA)'})

    //Criando o relacionamentoM
    oModel:SetRelation('RJ7DETAIL', aRJ7Rel , RJ7->(IndexKey(1)))

    //Setando o campo único da grid para não ter repetição
    oModel:GetModel('RJ7DETAIL'):SetUniqueLine({"RJ7_FILPAR"})

    //Setando outras informações do Modelo de Dados
    oModel:SetDescription("Dados do Cadastro ") //STR0006
    oModel:SetPrimaryKey({})
    oModel:GetModel("FORMCAB"):SetDescription(STR0007) //"Formulário do Cadastro"



Return oModel

/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Samuel Vincenzo                                                |
 | Data:  14/01/2017                                                   |
 | Desc:  Criação da visão MVC                                         |
 *---------------------------------------------------------------------*/
Static Function ViewDef()
    Local oModel     := FWLoadModel("GPEA936")
    Local oView      := Nil
    Local bCpCab    := {|cCampo| AllTrim(cCampo)+"|" $ "RJ7_FILIAL|RJ7_TABELA|RJ7_DESCRI|"}
    Local bCpGrd    := {|cCampo| AllTrim(cCampo)+"|" $ "RJ7_TABELA|RJ7_FILPAR|"}
    Local oStruCab := FWFormStruct(2, "RJ7",bCpCab)
    Local oStruGrd := FWFormStruct(2, "RJ7",bCpGrd)


    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_CAB", oStruCab, "FORMCAB")
    oView:AddGrid('VIEW_RJ7',oStruGrd,'RJ7DETAIL')

    oStruCab:SetNoFolder()
    oStruGrd:SetNoFolder()

    //Setando o dimensionamento de tamanho
    oView:CreateHorizontalBox('CABEC',30)
    oView:CreateHorizontalBox('GRID',70)

    //Amarrando a view com as box
    oView:SetOwnerView('VIEW_CAB','CABEC')
    oView:SetOwnerView('VIEW_RJ7','GRID')

    //Habilitando título
    oView:EnableTitleView('VIEW_CAB',STR0008) //'Configuração - Tabelas'
    oView:EnableTitleView('VIEW_RJ7',STR0009) //'Configuração - Filiais'

    //Tratativa padrão para fechar a tela
    oView:SetCloseOnOk({||.T.})

    //Remove os campos de Filial e Tabela da Grid
    oStruCab:RemoveField('RJ7_FILIAL')

    oStruGrd:RemoveField('RJ7_TABELA')

Return oView

/*/{Protheus.doc} GPEA936SM0
//TODO Descrição auto-gerada.
@author Samuel de Vincenzo
@since 24/06/2019
@version 1.0
@return return, return_description

@example
(examples)
@see (links_or_references)
/*/
function GPEA936SM0()
Local aCpos := {}
   Local oDlg
   Local oLbx

   SM0->(dbGotop())
   While !SM0->(EOF())
      If !SM0->(Deleted()) .And. aScan(aCpos,{|x| x[1] == AllTrim(SM0->M0_CODIGO)}) == 0
            aAdd(aCpos, {AllTrim(SM0->M0_CODIGO),AllTrim(SM0->M0_NOME)})
      EndIf
      SM0->(dbSkip())
   End

   DEFINE MSDIALOG oDlg TITLE STR0010 FROM 0,0 TO 240,500 PIXEL//"Grupo de Empresas" //

   @ 10,10 LISTBOX oLbx FIELDS HEADER STR0011,STR0012  SIZE 230,95 OF oDlg PIXEL//"Empresa","Desc Empresa"

   oLbx:SetArray( aCpos )
   oLbx:bLine      := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2]}}
   oLbx:bLDblClick := {|| oDlg:End(), cEmpRet := oLbx:aArray[oLbx:nAt,1] }

   DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlg:End(), cEmpRet := oLbx:aArray[oLbx:nAt,1])  ENABLE OF oDlg
   ACTIVATE MSDIALOG oDlg CENTER
Return .T.

function a936RetEmp()
return cEmpRet

/*/{Protheus.doc} VerTab
//TODO Descrição auto-gerada.
@author Samuel de Vincenzo
@since 05/04/2019
@version P12
@example
(examples)
@see (links_or_references)
/*/
static function VerTab(aErro, lContinua)
Local cTabSRV 	 := FWModeAccess('SRV',3)+FWModeAccess('SRV',2)+FWModeAccess('SRV',1)
Local cTabSPA 	 := FWModeAccess('SPA',3)+FWModeAccess('SPA',2)+FWModeAccess('SPA',1)
Local cTabSRJ 	 := FWModeAccess('SRJ',3)+FWModeAccess('SRJ',2)+FWModeAccess('SRJ',1)
Local cTabSR6 	 := FWModeAccess('SR6',3)+FWModeAccess('SR6',2)+FWModeAccess('SR6',1)
Local cTabSPJ    := FWModeAccess('SPJ',3)+FWModeAccess('SPJ',2)+FWModeAccess('SPJ',1)
Local cTabCTT    := FWModeAccess('CTT',3)+FWModeAccess('CTT',2)+FWModeAccess('CTT',1)
Local aEmpresas  := FWLoadSM0( .T. , .F. )
Local oLog		 := {}
Local aLog		 := {}
Local aEmp	     := {}
Local aJobAux	 := {}
Local nY		 := 0
Local nX		 := 0
Local nEmp		 := ""
Local cJobFile 		:= ''
Local cJobAux  		:= ''
Local cStartPath 	:= GetSrvProfString("Startpath","")
Local lRet := .T.
Local cTabe 		:= ""
Local cBkpFil		:= ""
Local  lNewLot 		:= FindFunction("fVldObraRJ") .And. (fVldObraRJ(@lParcial, .F.) .And. !lParcial)

Default aErro 	    := {}
Default lContinua   := .F.

If FindFunction("fVersEsoc")
	fVersEsoc( "S2200", .F.,,, @cVersEnvio,,)
EndIf

If cTabSRV $ "CCC|ECE|EEC|ECC"
	aAdd(aErro, STR0015 + cTabSRV + STR0027 + " https://tdn.totvs.com/x/IpC1HQ" + CRLF) //"A tabela SRV está com o compartilhamento:  "##" Para o correto funcionamento deverá ser diferente de (CCC / ECE / EEC / ECC ), altere o modo de compartilhamento atraves do Configurador. Saiba mais em: "
EndIf
If cTabSPA $ "CCC|ECE|EEC|ECC" .And. cVersEnvio < "9.0.00"
	aAdd(aErro, STR0016 + cTabSPA + STR0027 + " https://tdn.totvs.com/x/IpC1HQ" + CRLF ) //"A tabela SPA está com o compartilhamento:  "##" Para o correto funcionamento deverá ser diferente de (CCC / ECE / EEC / ECC ), altere o modo de compartilhamento atraves do Configurador. Saiba mais em: "
Endif
If cTabSRJ $ "CCC|ECE|EEC|ECC" .And. cVersEnvio < "9.0.00"
	aAdd(aErro, STR0017 + cTabSRJ + STR0027 + " https://tdn.totvs.com/x/IpC1HQ" + CRLF) //"A tabela SRJ está com o compartilhamento:  "##" Para o correto funcionamento deverá ser diferente de (CCC / ECE / EEC / ECC ), altere o modo de compartilhamento atraves do Configurador. Saiba mais em: "
Endif
If cTabSR6 $ "CCC|ECE|EEC|ECC" .And. cVersEnvio < "9.0.00"
	aAdd(aErro, STR0018 + cTabSR6 + STR0027 + " https://tdn.totvs.com/x/IpC1HQ" + CRLF) //"A tabela SR6 está com o compartilhamento:  "##" Para o correto funcionamento deverá ser diferente de (CCC / ECE / EEC / ECC ), altere o modo de compartilhamento atraves do Configurador. Saiba mais em: "
Endif
If cTabSPJ $ "CCC|ECE|EEC|ECC" .And. cVersEnvio < "9.0.00"
	aAdd(aErro, STR0019 + cTabSPJ + STR0027 + " https://tdn.totvs.com/x/IpC1HQ" + CRLF) //"A tabela SPJ está com o compartilhamento:  "##" Para o correto funcionamento deverá ser diferente de (CCC / ECE / EEC / ECC ), altere o modo de compartilhamento atraves do Configurador. Saiba mais em: "
EndiF
If cTabCTT $ "CCC|ECE|EEC|ECC" .And. !lNewLot
	aAdd(aErro, STR0020 + cTabCTT + STR0027 + " https://tdn.totvs.com/x/IpC1HQ") //"A tabela CTT está com o compartilhamento:  "##" Para o correto funcionamento deverá ser diferente de (CCC / ECE / EEC / ECC ), altere o modo de compartilhamento atraves do Configurador. Saiba mais em: "
Endif

If Len(aErro) < 1
	lContinua := .T.
EndIf

return ()

/*/{Protheus.doc} vldemp
//TODO Descrição auto-gerada.
@author samue
@since 07/05/2019
@version undefined
@return return, return_description
@param cEmp, characters, descricao
@param cFil, characters, descricao
@param cTabSRV, characters, descricao
@param cTabSPA, characters, descricao
@param cTabSRJ, characters, descricao
@param cTabSR6, characters, descricao
@param cJobFile, characters, descricao
@param cThread, characters, descricao
@param cPath, characters, descricao
@param cTab, characters, descricao
@example
(examples)
@see (links_or_references)
/*/
function vldemp(cEmp,cFil,xUser,lThread,aFilRJ7,cTabe)
Local cSRV,cSPA,cSRJ,cSR6,cSPJ,cTabCTT
Local cMsgLog := STR0013 + cEmp + STR0014 + cFil //"Empresa... " / " Filial... " e
Local lRet	  := .T.
Local cFRJ7 := ""
Local nY	  := 0
Local aLogError := {}
Local aLogAuto	:= {}
Local bErro		:= Nil
Local aLogAux	:= {}
Local nRegAux	:= 0
Local nX 		:= 1
Local nRotFim	:= 0
Local nContAux	:= 0

Private aErroAux		:= {}
Private aLogLj			:= {}
Private nContaLj		:= 0
Private nContErro		:= 0
Private lErroAux		:= .T.
Private lAutoErrNoFile 	:= .T.

Private aRotina := {}

bErro := ErrorBlock( { |oErr| ErroForm( oErr , @lErroAux, @aLogError ) } ) //Define um bloco de erro para eventual ocorrencia de error.log ser gravado no array aLogError.


For nY := 1 to Len(aFilRJ7)

	If !lErroAux //Se ocorreu error.log, para processamento.
		Exit
	EndIf

	cFRJ7 := cFil
	cFilAnt := aFilRJ7 [nY]

	// Seta job para nao consumir licensas
	RpcSetType(3)
	RpcSetEnv( cEmp, cFilAnt,,,'GPE')
	SetsDefault()

	//cTabe - Tabelas que serão COnfiguradas
	//cTabe[1] - SRV
	//cTabe[2] - SPA
	//cTabe[3] - SRJ
	//cTabe[4] - SR6
	//cTabe[5] - SPJ
	//cTabe[6] - CTT

	IF cTabe[1] //SRV
		// Verifico qual o compartilhamento apos a troca da empresa
		cSRV := FWModeAccess('SRV',3)  +FWModeAccess('SRV',2) + FWModeAccess('SRV',1)
		If cSRV $ "CCC|ECE|EEC|ECC"
			nContErro ++
			aAdd(aErroAux, STR0015 ," https://tdn.totvs.com/x/kKSCEw") //" A tabela SRV está com o compartilhamento incorreto, saiba mais em: "
		Else

			dbSelectArea("RJ7")
			dbSetOrder(1)

				If !MsSeek(xFilial("RJ7")+"1"+aFilRJ7 [nY])

					Reclock( "RJ7", .T. )
					RJ7->RJ7_FILIAL  := xFilial("RJ7")
					RJ7->RJ7_TABELA  := "1"
					RJ7->RJ7_FILPAR  := aFilRJ7 [nY]
				    RJ7->( MsUnlock() )
				Endif
			RJ7->(DbCloseArea())


		EndIf

	EndIf
	If cTabe[2] //SPA
		// Verifico qual o compartilhamento apos a troca da empresa
		cSPA := FWModeAccess('SPA',3) + FWModeAccess('SPA',2) + FWModeAccess('SPA',1)
		If cSPA $ "CCC|ECE|EEC|ECC"
			cMsgLog += "|" +  STR0016  //" A tabela SRJ está com o compartilhamento incorreto, saiba mais em: "
			cMsgLog += "|" + " https://tdn.totvs.com/x/kKSCEw"
			lRet := .F.
		Else



			dbSelectArea("RJ7")
			dbSetOrder(1)

				If !MsSeek(xFilial("RJ7")+"2"+aFilRJ7 [nY])

					Reclock( "RJ7", .T. )
					RJ7->RJ7_FILIAL  := xFilial("RJ7")
					RJ7->RJ7_TABELA  := "2"
					RJ7->RJ7_FILPAR  := aFilRJ7 [nY]
				    RJ7->( MsUnlock() )
				Endif
			RJ7->(DbCloseArea())



		EndIf
	EndIf
	If cTabe[3] //SRJ
		// Verifico qual o compartilhamento apos a troca da empresa
		cSRJ := FWModeAccess('SRJ',3) + FWModeAccess('SRJ',2) + FWModeAccess('SRJ',1)
		If cSRJ $ "CCC|ECE|EEC|ECC"
			cMsgLog += "|" + STR0017 //" A tabela SRJ está com o compartilhamento incorreto, saiba mais em: "
			cMsgLog += "|" + " https://tdn.totvs.com/x/kKSCEw"
			lRet := .F.
		Else



			dbSelectArea("RJ7")
			dbSetOrder(1)

				If !MsSeek(xFilial("RJ7")+"3"+aFilRJ7 [nY])

					Reclock( "RJ7", .T. )
					RJ7->RJ7_FILIAL  := xFilial("RJ7")
					RJ7->RJ7_TABELA  := "3"
					RJ7->RJ7_FILPAR  := aFilRJ7 [nY]
				    RJ7->( MsUnlock() )
				Endif
			RJ7->(DbCloseArea())



		EndIf
	EndIf
	If cTabe[4] //SR6
		// Verifico qual o compartilhamento apos a troca da empresa
		cSR6 := FWModeAccess('SR6',3) + FWModeAccess('SR6',2) + FWModeAccess('SR6',1)
		If cSR6 $ "CCC|ECE|EEC|ECC"
			cMsgLog += "|" + STR0018 //" A tabela SR6 está com o compartilhamento incorreto, saiba mais em:  "
			cMsgLog += "|" + " https://tdn.totvs.com/x/kKSCEw"
			lRet := .F.
		Else



			dbSelectArea("RJ7")
			dbSetOrder(1)

				If !MsSeek(xFilial("RJ7")+"4"+aFilRJ7 [nY])

					Reclock( "RJ7", .T. )
					RJ7->RJ7_FILIAL  := xFilial("RJ7")
					RJ7->RJ7_TABELA  := "4"
					RJ7->RJ7_FILPAR  := aFilRJ7 [nY]
				    RJ7->( MsUnlock() )
				Endif
			RJ7->(DbCloseArea())


		EndIf
	EndIf
	If cTabe[5] //SPJ
		// Verifico qual o compartilhamento apos a troca da empresa
		cSR6 := FWModeAccess('SPJ',3) + FWModeAccess('SPJ',2) + FWModeAccess('SPJ',1)
		If cSR6 $ "CCC|ECE|EEC|ECC"
			cMsgLog += "|" + STR0019 //" A tabela SPJ está com o compartilhamento incorreto, saiba mais em:  "
			cMsgLog += "|" + " https://tdn.totvs.com/x/kKSCEw"
			lRet := .F.
		Else



			dbSelectArea("RJ7")
			dbSetOrder(1)

				If !MsSeek(xFilial("RJ7")+"5"+aFilRJ7 [nY])

					Reclock( "RJ7", .T. )
					RJ7->RJ7_FILIAL  := xFilial("RJ7")
					RJ7->RJ7_TABELA  := "5"
					RJ7->RJ7_FILPAR  := aFilRJ7 [nY]
				    RJ7->( MsUnlock() )
				Endif
			RJ7->(DbCloseArea())



		EndIf
	Endif
	If cTabe[6] //CTT
		// Verifico qual o compartilhamento apos a troca da empresa
		cSR6 := FWModeAccess('CTT',3) + FWModeAccess('CTT',2) + FWModeAccess('CTT',1)
		If  cSR6 $ "CCC|ECE|EEC|ECC"
			cMsgLog += "|" + STR0020 //" A tabela SR6 está com o compartilhamento incorreto, saiba mais em:  "
			cMsgLog += "|" + " https://tdn.totvs.com/x/kKSCEw"
			lRet := .F.
		Else



			dbSelectArea("RJ7")
			dbSetOrder(1)

				If !MsSeek(xFilial("RJ7")+"6"+aFilRJ7 [nY])

					Reclock( "RJ7", .T. )
					RJ7->RJ7_FILIAL  := xFilial("RJ7")
					RJ7->RJ7_TABELA  := "6"
					RJ7->RJ7_FILPAR  := aFilRJ7 [nY]
				    RJ7->( MsUnlock() )
				Endif
			RJ7->(DbCloseArea())



		EndIf
	EndIf

	VarBeginT("GPEA936","nRegsOk")
	VarGetXD("GPEA936","nRegsOk",@nRegAux)
	nRegAux++
	VarSetXD("GPEA936","nRegsOk",nRegAux)
	VarEndT("GPEA936","nRegsOk")

Next nY

If !Empty(aLogLj)
		VarBeginT("GPEA936","aLogLJ")
			VarGetAD("GPEA936","aLogLJ",@aLogAux)
			For nX := 1 to Len(aLogLJ)
				aAdd(aLogAux, aLogLJ[nX])
			Next nX
			VarSetAD("GPEA936","aLogLJ",aLogAux)
		VarEndT("GPEA936","aLogLJ")
	EndIf

	If nContaLj > 0
		VarSetX("GPEA936","nContaLJ",1)
	EndIf

	If nContErro > 0
		VarBeginT("GPEA936","nContErro")
			VarGetXD("GPEA936","nContErro",@nContAux)
			nContAux += nContErro
			VarSetXD("GPEA936","nContErro",nContAux)
		VarEndT("GPEA936","nContErro")
	EndIf

	If !lErroAux
		VarSetX("GPEA936","cRotErro","S")
		VarSetA("GPEA936","aLogErro",aLogError)
	EndIf

	If Len(aErroAux) > 0
		VarBeginT("GPEA936","aLogAuto")
			VarGetAD("GPEA936","aLogAuto",@aLogAuto)
			aAdd(aLogAuto,aErroAux)
			VarSetAD("GPEA936","aLogAuto",aLogAuto)
		VarEndT("GPEA936","aLogAuto")
	EndIf

	//Soma 1 no controle de threads finalizadas
	VarBeginT("GPEA936","nRotFim")
		VarGetXD("GPEA936","nRotFim",@nRotFim)
		nRotFim++
		VarSetXD("GPEA936","nRotFim",nRotFim)
	VarEndT("GPEA936","nRotFim")

	ErrorBlock( bErro )

	//RpcClearEnv()
	cFilAnt := cFRJ7

Return ()

/*/{Protheus.doc} fGP936Novo
//TODO Descrição auto-gerada.
@author Samuel de Vincenzo
@since 05/04/2019
@version P12
@example
(examples)
@see (links_or_references)
/*/
Static Function fGp936Novo()
	Local aArea 		:= GetArea()
	Local oProcesso	 	:= Nil
	Local oDlgEven		:= Nil
	Local cAliasTRB		:= GetNextAlias()
	Local cProcesso		:= ""
	Local aProcesso		:= {OemToAnsi(STR0021), OemToAnsi(STR0022), OemToAnsi(STR0023), OemToAnsi(STR0024), OemToAnsi(STR0025), OemToAnsi() } //##"SRV" ##"SPA" ##"SRJ" ##"SR6" ##"SPJ" ##"CTT" //STR0021 a STR0027
	Local aSizeTel		:= MsAdvSize(.F.)
	Local dDataRef		:= SToD("  /  /    ")
	Local aObjects		:= {}
	Local aInfo			:= {}
	Local aPosObj		:= {}
	Local aArrayFil		:= {}
	Local aCheck		:= { .F., .F., .F., .F., .F., .F.}
	Local bFecha		:= {||oDlgEven:End()}
	Local bOK			:= {||IIF( fGP936TdOk( aCheck, aArrayFil, cAliasTRB ), ( oDlgEven:End(), nOpcX := 1 ), Nil )}
	Local oFWLayer		:= FWLayer():New()
	Local aBotoes		:= {}
	Local oButton		:= NIL
	Local cTabSRV 	 	:= FWModeAccess('SRV',3)+FWModeAccess('SRV',2)+FWModeAccess('SRV',1)
	Local cTabSPA 	 	:= FWModeAccess('SPA',3)+FWModeAccess('SPA',2)+FWModeAccess('SPA',1)
	Local cTabSRJ 	 	:= FWModeAccess('SRJ',3)+FWModeAccess('SRJ',2)+FWModeAccess('SRJ',1)
	Local cTabSR6 	 	:= FWModeAccess('SR6',3)+FWModeAccess('SR6',2)+FWModeAccess('SR6',1)
	Local cTabSPJ 	 	:= FWModeAccess('SPJ',3)+FWModeAccess('SPJ',2)+FWModeAccess('SPJ',1)
	Local cTabCTT 	 	:= FWModeAccess('CTT',3)+FWModeAccess('CTT',2)+FWModeAccess('CTT',1)
	Local  lNewLot 		:= FindFunction("fVldObraRJ") .And. (fVldObraRJ(@lParcial, .F.) .And. !lParcial)

	Private oTmpTbl
	Private cEmpDe := ""
	Private cFilde := ""

	Pergunte("GPEA936", .F.)
	cEmpDe		:= MV_PAR01
	cFilDe		:= MV_PAR02


	If cTabSRV $ "CCC|ECE|EEC|ECC"
		Help( ,, 'HELP',, STR0015 + cTabSRV + STR0027 + " https://tdn.totvs.com/x/IpC1HQ", 1, 0 ) //"A tabela SRV está com o compartilhamento:  "##" Para o correto funcionamento deverá ser diferente de (CCC / ECE / EEC / ECC ), altere o modo de compartilhamento atraves do Configurador. Saiba mais em: "
		Return()
	EndIf
	If cTabSPA $ "CCC|ECE|EEC|ECC" .And. cVersEnvio < "9.0.00"
		Help( ,, 'HELP',, STR0016 + cTabSPA + STR0027 + " https://tdn.totvs.com/x/IpC1HQ", 1, 0 ) //"A tabela SPA está com o compartilhamento:  "##" Para o correto funcionamento deverá ser diferente de (CCC / ECE / EEC / ECC ), altere o modo de compartilhamento atraves do Configurador. Saiba mais em: "
		Return()
	EndIf
	If cTabSRJ $ "CCC|ECE|EEC|ECC" .And. cVersEnvio < "9.0.00"
		Help( ,, 'HELP',, STR0017 + cTabSRJ + STR0027 + " https://tdn.totvs.com/x/IpC1HQ", 1, 0 ) //"A tabela SRJ está com o compartilhamento:  "##" Para o correto funcionamento deverá ser diferente de (CCC / ECE / EEC / ECC ), altere o modo de compartilhamento atraves do Configurador. Saiba mais em: "
		Return()
	EndIf
	If cTabSR6 $ "CCC|ECE|EEC|ECC" .And. cVersEnvio < "9.0.00"
		Help( ,, 'HELP',, STR0018 + cTabSR6 + STR0027 + " https://tdn.totvs.com/x/IpC1HQ", 1, 0 ) //"A tabela SR6 está com o compartilhamento:  "##" Para o correto funcionamento deverá ser diferente de (CCC / ECE / EEC / ECC ), altere o modo de compartilhamento atraves do Configurador. Saiba mais em: "
		Return()
	EndIf
	If cTabSPJ $ "CCC|ECE|EEC|ECC" .And. cVersEnvio < "9.0.00"
		Help( ,, 'HELP',, STR0019 + cTabSPJ + STR0027 + " https://tdn.totvs.com/x/IpC1HQ", 1, 0 ) //"A tabela SPJ está com o compartilhamento:  "##" Para o correto funcionamento deverá ser diferente de (CCC / ECE / EEC / ECC ), altere o modo de compartilhamento atraves do Configurador. Saiba mais em: "
		Return()
	EndIf
	If cTabCTT $ "CCC|ECE|EEC|ECC" .And. !lNewLot
		Help( ,, 'HELP',, STR0020 + cTabCTT + STR0027 + " https://tdn.totvs.com/x/IpC1HQ", 1, 0 ) //"A tabela CTT está com o compartilhamento:  "##" Para o correto funcionamento deverá ser diferente de (CCC / ECE / EEC / ECC ), altere o modo de compartilhamento atraves do Configurador. Saiba mais em: "
		Return()
	EndIf

	//Faz o calculo automatico de dimensoes dos objetos visuais
	AAdd(aObjects, {100, 075, .T., .T.})
	AAdd(aObjects, {100, 125, .T., .T.})
	aInfo   := {aSizeTel[1], aSizeTel[2], aSizeTel[3], aSizeTel[4], 3, 3}
	aPosObj := MsObjSize(aInfo, aObjects, .T.)

	//Dialog eventos periodicos
		DEFINE MSDIALOG oDlgEven FROM aSizeTel[7], 0 TO aSizeTel[6], aSizeTel[5] TITLE STR0033 OF oMainWnd PIXEL //##"Configuração de cópia de tabelas" //STR0034

		//Compatibilizando a posição para a V12 - Barra Superior
		aPosObj[1, 1] += 35

		//Checkbox folha de pagamento
		fGP936ChBx(oDlgEven, aPosObj, aCheck)

		//Criacao do markbrowse
		fGP936MkB(oDlgEven, aPosObj, cAliasTRB)

		ACTIVATE MSDIALOG oDlgEven CENTERED ON INIT EnchoiceBar(oDlgEven, bOK ,bFecha, , aBotoes)

		Processa({|lEnd| fGp936Pro(aArrayFil, aCheck)}, OemToAnsi(STR0034)) //##"Configuração Cópia Tabelas" ////STR0035


RestArea(aArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fGp936ChBx³ Autor ³ Samuel Vincenzo      ³ Data ³ 05/04/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Realiza a criacao dos objetos TCheckBox                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oDlgEven - Tela onde serao criados os objetos              ³±±
±±³          ³ aPosObj  - Dimensoes da tela                               ³±±
±±³          ³ aCheck   - Array para controle de selecao dos eventos      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGp936ChBx(oDlgEven, aPosObj, aCheck)
Local oGroup, oCheck1, oCheck2, oCheck3, oCheck4, oCheck5, oCheck6, oCheckAll
Local lChkAll	:= .F.

//Grupo Tabelas
oGroup := TGROUP():New(aPosObj[1, 1], aPosObj[1, 2] + 5, aPosObj[1, 3] +17, aPosObj[1, 4], OemToAnsi("SELECIONE AS TABELAS QUE SERAO CONFIGURADAS PARA COPIA"), oDlgEven, CLR_BLUE,, .T.) //#"Eventos"

//CheckBoxes
//Lado esquerdo da tela
oCheck1 := TCheckBox():New(aPosObj[1, 1] + 17, aPosObj[1, 2] + 10, OemtoAnsi(STR0021)+" "+OemtoAnsi(STR0035), {|| aCheck[1]}, oGroup, 250, 10,, {|| aCheck[1] := !aCheck[1]},,,,,, .T.,,,) 	//##"SRV"##"Cadastro de Verbas" //STR0036
//oBLink1 := TButton():New( aPosObj[1, 1] + 45, aPosObj[1, 2] + 100, OemToAnsi("?"),oDlgEven,{|| ShellExecute("open","http://tdn.totvs.com/x/Agc4Fw","","",1) }, 7,7,,,.F.,.T.,.F.,,.F.,,,.F. )
oCheck2 := TCheckBox():New(aPosObj[1, 1] + 27, aPosObj[1, 2] + 10, OemtoAnsi(STR0022)+" "+OemtoAnsi(STR0036), {|| aCheck[2]}, oGroup, 250, 10,, {|| aCheck[2] := !aCheck[2]},,,,,, .T.,,,) 	//##"SPA"##"REGRAS DE APONTAMENTO" //STR0037

oCheck3 := TCheckBox():New(aPosObj[1, 1] + 37, aPosObj[1, 2] + 10, OemtoAnsi(STR0023)+" "+OemtoAnsi(STR0037), {|| aCheck[3]}, oGroup, 250, 10,, {|| aCheck[3] := !aCheck[3]},,,,,, .T.,,,) 	//##"SRJ"##"FUNÇÕES" //STR0038

oCheck4 := TCheckBox():New(aPosObj[1, 1] + 47, aPosObj[1, 2] + 10, OemtoAnsi(STR0024)+" "+OemtoAnsi(STR0038), {|| aCheck[4]}, oGroup, 250, 10,, {|| aCheck[4] := !aCheck[4]},,,,,, .T.,,,) 	//##"SR6"##"Turnos de Trabalho            " //STR0039

oCheck5 := TCheckBox():New(aPosObj[1, 1] + 57, aPosObj[1, 2] + 10, OemtoAnsi(STR0025)+" "+OemtoAnsi(STR0039), {|| aCheck[5]}, oGroup, 250, 10,, {|| aCheck[5] := !aCheck[5]},,,,,, .T.,,,) 	//##"SR6"##"Horario Padrao            " //STR0040

oCheck6 := TCheckBox():New(aPosObj[1, 1] + 67, aPosObj[1, 2] + 10, OemtoAnsi(STR0026)+" "+OemtoAnsi(STR0040), {|| aCheck[6]}, oGroup, 250, 10,, {|| aCheck[6] := !aCheck[6]},,,,,, .T.,,,) 	//##"CTT"##"CENTRO DE CUSTO            " //STR0041



//Todos os eventos
oCheckAll := TCheckBox():New(aPosObj[1, 3] + 6, aPosObj[1, 2] + 10, OemtoAnsi(STR0041), {|| lChkAll}, oGroup, 150, 10,, {|| fGP936ChA(@lChkAll, aCheck, oCheck1, oCheck2, oCheck3, oCheck4, oCheck5, oCheck6)},,,,,,,, .T.,,,) 	//##"Todas as tabelas"

Return ()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fGp936ChAll ³ Autor ³ Samuel Vincenzo      ³ Data ³ 05/04/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marca/Desmarca todas as tabelas para cópia			        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lChkAll - Controla se marca ou desmarca                      ³±±
±±³          ³ aCheck  - Array com as tabelas                               ³±±
±±³          ³ oCheck1 - Objeto da tabela 1 - SRV                           ³±±
±±³          ³ oCheck2 - Objeto da tabela 2 - SPA                           ³±±
±±³          ³ oCheck3 - Objeto do evento 3 - SRJ                           ³±±
±±³          ³ oCheck4 - Objeto do evento 4 - SR6                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fGp936ChA(lChkAll, aCheck, oCheck1, oCheck2, oCheck3, oCheck4,oCheck5,oCheck6)

//Atualiza check evento atual
lChkAll := !lChkAll

//Atualiza checks de todos os eventos
aCheck[1] := lChkAll
aCheck[2] := lChkAll
aCheck[3] := lChkAll
aCheck[4] := lChkAll
aCheck[5] := lChkAll
aCheck[6] := lChkAll


//Atualiza objetos
oCheck1:Refresh()
oCheck2:Refresh()
oCheck3:Refresh()
oCheck4:Refresh()
oCheck5:Refresh()
oCheck6:Refresh()

Return ()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fGp936MkB³ Autor ³ Samuel Vincenzo       ³ Data ³ 05/04/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Realiza a criacao do MarkBrowse com informacoes das filiais³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oDlgEven  - Tela onde serao criados os objetos             ³±±
±±³          ³ aPosObj   - Dimensoes da tela                              ³±±
±±³          ³ cAliasTRB - Alias do arquivo temporario                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGp936MkB(oDlgEven, aPosObj, cAliasTRB)
Local oMarkFil		:= Nil
Local oChkAll		:= Nil
Local cArq 			:= ""
Local aArea		 	:= GetArea()
Local oView 		:= FWViewActive()
Local aStru   		:= {}
Local aCpoBro 		:= {}
Local aSM0    		:= FWLoadSM0(.T.,,.F.)
Local lInverte  	:= .F.
Local lContinua		:= .T.
Local lChkAll 		:= .F.
Local cMark   		:= GetMark()
local nY			:= 0
Local nEmp

Private cCadastro 	:= OemToAnsi(STR0042) //##"SELECIONE AS EMPRESAS QUE SERAO CONFIGURADAS PARA COPIA"
Private aRotina	:= {}

If FunName() == "GPEA936"
	//Estrutura da tabela temporaria
	Aadd(aStru, {"OK"		, "C", 2						, 0})
    Aadd(aStru, {"EMPRESA"	, "C", 2						, 0})
    Aadd(aStru, {"FILIAL"   ,  "C", 12                       , 0})
    Aadd(aStru, {"NOME"  	, "C", 100						, 0})
    Aadd(aStru, {"CNPJ"  	, "C", 15					  	, 0})

    oTmpTbl := FWTemporaryTable():New(cAliasTRB)
    oTmpTbl:SetFields(aStru)
    oTmpTbl:AddIndex( "01", {"EMPRESA"} )
    oTmpTbl:Create()
EndIf

//Faço o laço para pegar as empresas Matriz
For nY := 1 to Len(aSM0)
	//Alimentando a tabela
	If aSM0[nY,1] == cEmpAnt .And. Reclock(cAliasTrb, .T.)
		(cAliasTRB)->EMPRESA := aSM0[nY,1]
		(cAliasTRB)->FILIAL  := aSM0[nY,2]
		(cAliasTRB)->NOME    := aSM0[nY,6] + " / " + aSM0[nY,17]
		(cAliasTRB)->CNPJ    := aSM0[nY,18]
		(cAliasTRB)->(MsUnlock())
	EndIf
Next nY
If FunName() == "GPEA936"
	//Definindo a visualização das informacoes
    aCpoBro	:= {{"OK"		,, " "   				, "@!"},;
    			{"EMPRESA"	,, "Empresa"			, "@!"},;
    			{"FILIAL"	,, "Filial"				, "@!"},;
    			{"NOME"		,, "Nome"				, "@!"},;
    			{"CNPJ"		,, "Cnpj"				, "@R 99.999.999/9999-99"}}

    //Posicionando no inicio da tabela temporaria
    (cAliasTRB)->(dbGoTop())

    //Filiais
    TSay():New(aPosObj[2, 1] + 15, aPosObj[2, 2] + 5, {|| OemToAnsi(STR0043)}, oDlgEven,,, .F., .F., .F., .T., CLR_BLUE,, 200, 10, .F., .F., .F., .F., .F.) //#"SELECIONE AS EMPRESAS QUE SERAO CONFIGURADAS PARA COPIA"

    //Criacao do markbrowse
    oMarkFil := MsSelect():New(cAliasTRB, "OK", "", aCpoBro, @lInverte, @cMark, {aPosObj[2, 1] + 25, aPosObj[2, 2] + 8, aPosObj[2, 3] - 20, aPosObj[2, 4]},,,,,{})
    oMarkFil:bMark := {|| fGP936AlS(cAliasTRB, cMark, oMarkFil, 1, .F.)}

    oCheckAll := TCheckBox():New(aPosObj[2, 3] - 20, aPosObj[2, 2] + 10, OemtoAnsi(STR0044), {|| lChkAll}, oDlgEven, 250, 10,,{|| (lChkAll := !lChkAll, fGP936AlS(cAliasTRB, cMark, oMarkFil, 2, lChkAll))},,,,,, .T.,,,) 	//##"Todas as filiais"
EndIf

RestArea(aArea)

Return ()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fGp93AlS³ Autor ³ Samuel Vincenzo     	³ Data ³ 05/04/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tratamento para mudanca de selecao do MsSelect das filiais ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAliasTRB - Alias Utilizado para montar o MsSelect         ³±±
±±³          ³ cMark     - Variavel de controle de selecao                ³±±
±±³          ³ oMarkFil  - Objeto do markbrowse                           ³±±
±±³          ³ nOpc  	 - Marcar 1 ou todas filiais no markbrowse        ³±±
±±³          ³ lChkAll   - Opcao marcar/desmarcar para todas as filiais   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGp936AlS(cAliasTRB, cMark, oMarkFil, nOpc, lChkAll)
Local aArea := GetArea()


If nOpc == 1
	RecLock(cAliasTRB, .F.)

	If Marked("OK")
		(cAliasTRB)->OK := cMark
	Else
		(cAliasTRB)->OK := ""
	EndIf

	(cAliasTRB)->(MsUnlock())
Else

	(cAliasTRB)->(dbGoTop())

	While (cAliasTRB)->(!EOF())
		RecLock(cAliasTRB, .F.)
			(cAliasTRB)->OK := IIF(lChkAll, cMark, "")
		(cAliasTRB)->(MsUnlock())

		(cAliasTRB)->(dbSkip())
	EndDo

	//Reposiciona no inicio do arquivo
	(cAliasTRB)->(dbGoTop())
EndIf

//Atualiza o MsSelect
oMarkFil:oBrowse:Refresh()

RestArea(aArea)

Return ()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fGp936TdOk ³ Autor ³ Samuel Vincenzo	      ³ Data ³ 05/04/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pos-validacao do modelo relativo as tabelas para cópia       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCompete  - Competencia para geracao dos eventos             ³±±
±±³          ³ cPerIni   - Periodo inicial                                  ³±±
±±³          ³ cPerFim   - Periodo final                                    ³±±
±±³          ³ aCheck    - Array para controle de selecao dos eventos       ³±±
±±³          ³ aArrayFil - Array para armazenar as filiais selecionadas     ³±±
±±³          ³ cAliasTRB - Alias do arquivo temporario                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet = .T. ou .F.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fGp936TdOk(aCheck, aArrayFil, cAliasTRB, cProcesso)
Local aArea			:= GetArea()
Local nI			:= 0
Local lRet 			:= .T.
Local aCheckAux 	:= aClone(aCheck) //Salva itens selecionados

//Limpa array
aArrayFil := {}

Do Case
	Case aScan(aCheck, {|x| x}) == 0 //Valida tabela
		MsgStop(OemToAnsi(STR0045)) //##"Necessário selecionar uma tabela"
		lRet := .F.
	OtherWise
		If lRet
			//Adiciona filiais selecionadas
			(cAliasTRB)->(dbGoTop())

			While (cAliasTRB)->(!EOF())
				If !Empty((cAliasTRB)->OK)
					aAdd( aArrayFil, Padr( ( cAliasTRB )->FILIAL,12 ) )
				EndIf

				(cAliasTRB)->(dbSkip())
			EndDo

			//Valida filiais
			If Len(aArrayFil) == 0
				(cAliasTRB)->(dbGoTop())
				MsgStop(OemToAnsi(STR0046)) //##"Necessário selecionar uma filial"
				lRet := .F.
			EndIf
		EndIf
EndCase

//Restaura itens selecionados
aCheck := aClone(aCheckAux)

Return ( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fGp936Pro ³ Autor ³ Samuel Vincenzo       ³ Data ³05/04/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Executa a validação do grupo de empresas                    ³±±
±±³          ³e grava na tabela de referencia                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGP936Pro()                                           	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA936()   					                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGp936Pro(aArrayFil, aCheck)
Local aArea 		    := GetArea()
Local nI				:= 0
Local aTitle		    := {STR0047}//"Processando..."
Local cJobFile          := ""
Local aJobAux			:= {}
Local cJobAux			:= ""
Local cStartPath 		:= GetSrvProfString("Startpath","")
Local cTabela			:= "RJ7"
Local oLog				:= {}
Local cFil				:= ""
Local aThreads			:= {}
Local uThreads			:= Nil
Local aLogError         := {}
Local aArray			:= {}
Local nLoops			:= 0

Local aLogErro		:= {}
Local aLogAuto		:= {}
Local nRegsOk		:= 1
Local nRegsAux		:= 0
Local nRotFim		:= 0
Local lThreads 		:= .F.
Local lRotErro		:= .F.
Local cRotErro		:= "N"

Private aLogProc	:= {}

Private aLogLj		:= {}
Private cLogLj		:= ""
Private cTab		:= ""
Private nContaLj	:= 0
Private nQtdRJ7		:= 0
Private nContErro 	:= 0

Default lImprime    := .F.

	uThread := fRJ7Thread(aArrayFil)

	If ValType(uThread) == "A"
		aThreads := aClone(uThread)
		lThreads := .T.
		nLoops	 := Len(aThreads)
	Else
		aArray := uThread
	EndIf

	ProcRegua(nQtdRJ7)

	//Dispara jobs
			VarSetUID("GPEA936",.T.)
			VarSetXD("GPEA936","cRotErro","N")
			VarSetXD("GPEA936","nRotFim",0)
			VarSetXD("GPEA936","nRegsOk",0)
			VarSetXD("GPEA936","nContaLJ",0)
			VarSetXD("GPEA936","nContErro",0)
			VarSetAD("GPEA936","aLogLJ",{})
			VarSetAD("GPEA936","aLogErro",{})
			VarSetAD("GPEA936","aLogAuto",{})


	//Faço a validação se as tabelas nas empresas selecionadas estão seguindo o mesmo compartilhamento da empresa escolhida como padrao
	For nI := 1 to Len(aThreads)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    //³ Dispara thread    ³
	    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    startjob("vldemp",getenvserver(),.F.,cEmpAnt,cFilAnt,__cUserId,lThreads,aThreads[nI],aCheck)
	    //                                                     SRV
	    //vldemp(cEmpAnt,cFilAnt,__cUserId,lThreads,aThreads[nI],aCheck)

	Next nI

		While .T.
			VarGetXD("GPEA936","cRotErro",@cRotErro)
			lRotErro := ( cRotErro == "S" )
			VarGetXD("GPEA936","nRotFim",@nRotFim)
			VarGetX("GPEA936","nRegsOk",@nRegsAux)

			For nRegsOk := nRegsOk to nRegsAux
				//Incrementa contador de acordo com o número de registros processados
				IncProc() //Processando...
			Next nRegsOk
			If lRotErro
				Exit
			EndIf
			If nRotFim == nLoops
				Exit
			EndIf
		EndDo

		VarGetX("GPEA936","nContaLJ",@nContaLJ)
		VarGetA("GPEA936","aLogLJ",@aLogLJ)
		VarGetA("GPEA936","aLogErro",@aLogErro)
		VarGetA("GPEA936","aLogAuto",@aLogAuto)
		VarGetX("GPEA936","nContErro",@nContErro)

		//Elimina as globais criadas
		VarClean("GPEA936")


		  /*
		   If Len( oLog ) > 0
		   	fMakeLog({oLog}, , Nil, Nil, "Filial", "Configuração Cópia Tabelas", "M", "P",, .F.)
		   EndIf
		 */
Return ()


Static Function fRJ7Thread(aArray)
Local aThreads	:= {}
Local aAux		:= {}
Local uThread	:= Nil
Local nEmpDiv 	:= SuperGetMv("MV_RHGPRJ7", NIL, 1)	//Quantidade de threads que devem ser utilizadas
Local nCount	:= 0
Local nTamAux	:= 0
Local nCntReg 	:= 0
Local nNumReg	:= 0
Local nX		:= 0

nTamAux := nQtdRJ7 := nNumReg := Len(aArray)

If nNumReg >= 20
	nEmpDiv := 0
EndIf

If nEmpDiv > 20
	nTamAux	:= Int(nNumReg / 20)

	//Minimo de 20 filiais por thread
	nEmpDiv := Min(nEmpDiv,nTamAux)
	nTamAux := nNumReg

	If nEmpDiv > 1
		nCntReg	:= (nNumReg % nEmpDiv)
		nTamAux	:= (nNumReg+(nEmpDiv-nCntReg)) / nEmpDiv
	EndIf

	for nX := 1 to Len(aArray)

		If nCount > nTamAux
			aAdd(aThreads,aAux)
			aAux := {}
			nCount := 0
		EndIf

		aAdd( aAux , aArray[nX] )
		nCount++

	Next nX

	If !Empty(aAux)
		aAdd(aThreads,aAux)
		aAux := {}

		If Len(aThreads) > 1
			uThread := aThreads
		Else
			uThread := aArray
		EndIf

	EndIf
Else
	for nX := 1 to Len(aArray)
		If nCount > nTamAux
			aAdd(aThreads,aAux)
			aAux := {}
			nCount := 0
		EndIf

		aAdd( aAux , aArray[nX] )
		nCount++

	Next nX
	If !Empty(aAux)
		aAdd(aThreads,aAux)
		aAux := {}

		If Len(aThreads) >= 1
			uThread := aThreads
		Else
			uThread := aArray
		EndIf

	EndIf
EndIf


Return uThread



/*/{Protheus.doc} GPEA936BRO
//TODO Função para trazer a descrição da tabela no browser e alteração.
@author Samuel de Vincenzo
@since 07/05/2019
@version 1.0
@param cCampo
@return cRet, retorna o nome da tabela
/*/
Function GPEA936BRO(cCampo)

Local cRet	:= ""

If cCampo == "1"
	cRet := InfoSX2("SRV","X2_NOME")
EndIf
If cCampo == "2"
	cRet := InfoSX2("SPA","X2_NOME")
EndIf
If cCampo == "3"
	cRet := InfoSX2("SR6","X2_NOME")
EndIf
If cCampo == "4"
	cRet := InfoSX2("SRJ","X2_NOME")
EndIf
If cCampo == "5"
	cRet := InfoSX2("SPJ","X2_NOME")
EndIf
If cCampo == "6"
	cRet := InfoSX2("CTT","X2_NOME")
EndIf


Return (cRet)

/*/{Protheus.doc} GPA936ThA
//TODO Descrição auto-gerada.
@author SAMUEL DE VINCENZO
@since 08/05/2019
@version undefined
@param aParams, array, descricao
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GPA936ThA(aParams)
Local lRet			:= .T.
Local cStartPath 	:= GetSrvProfString("Startpath","")
Local cJobFile
Local cQryTmp
Local cQryTmp2
Local cAliasRJ8 	:= "RJ8"
Local nSize 		:= FWSizeFilial()
Local aLog			:= {}
Local nCount		:= 0
Local cQuery		:= ""


	PREPARE ENVIRONMENT EMPRESA (aParams[1]) FILIAL (aParams[2]) TABLES 'SRV,SPA,SR6,SRJ,SPJ,CTT,RJ7,RJ8'  MODULO "GPE"


	Aadd(aLog, DtoC( Date() ) + " " + Time() + " - Iniciando o schedule de cópia")

	cQuery := "SELECT RJ8_FILIAL,RJ8_TABELA,RJ8_FILPAR,RJ8_CONTEU,RJ8_DATA,RJ8_HORA,RJ8_OPERAC,RJ8_STATUS,RJ8_USUARI,RJ8_ESOCIA,RJ8_MSGLOG "
	cQuery += "FROM "+RetSqlName("RJ8")+" RJ8 "
	cQuery += "WHERE RJ8.RJ8_FILPAR = '" + Space(FwGetTamFilial) + "' AND "
	cQuery += "RJ8.RJ8_STATUS = '0' AND "
	cQuery += "RJ8.D_E_L_E_T_ = '' "
	cQuery += "ORDER BY RJ8_DATA,RJ8_HORA ASC "
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"XTEMP",.T.,.T.)

		dbSelectArea("XTEMP")
	    dbGoTop()

	Count To nCount


	If nCount == 0
		Aadd(aLog, DtoC( Date() ) + " " + Time() + STR0048) //" - Sem dados para gerar a cópia"
	Else
		XTEMP->( dbGoTop() )
		Aadd(aLog, DtoC( Date() ) + " " + Time() + STR0049) //" - Verificando tabela de filiais para cópia "

		While !XTEMP->( EOF() )

			BeginSQL Alias "XTEMP2"
					Select
					RJ7_FILIAL,
					RJ7_TABELA,
					RJ7_FILPAR
					From
					%Table:RJ7% RJ7
					WHERE
					RJ7_TABELA = %Exp:XTEMP->RJ8_TABELA% AND
					RJ7.%NotDel%
				EndSQL


			While !XTEMP2->( EOF() )
				Sleep( 1000 )

					If XTEMP2->RJ7_TABELA == "1"

			    		If xFilial( "SRV",XTEMP2->RJ7_FILPAR ) <> Substr(XTEMP->RJ8_CONTEU,1,nSize)

				    		dbSelectArea("RJ8")
				    		dbSetOrder(2)
				    		If !MsSeek(xFilial("RJ8")+xFilial("SRV",XTEMP2->RJ7_FILPAR)+XTEMP->RJ8_TABELA+XTEMP->RJ8_CONTEU+XTEMP->RJ8_OPERAC)
				    			BEGIN TRANSACTION

						    		//Alimentando a tabela
								 Reclock( cAliasRJ8, .T. )
								( cAliasRJ8 )->RJ8_FILIAL  := xFilial("RJ8")
								( cAliasRJ8 )->RJ8_FILPAR  := xFilial("SRV",XTEMP2->RJ7_FILPAR)
								( cAliasRJ8 )->RJ8_TABELA  := XTEMP->RJ8_TABELA
								( cAliasRJ8 )->RJ8_CONTEU  := XTEMP->RJ8_CONTEU
								( cAliasRJ8 )->RJ8_DATA    := Date()
								( cAliasRJ8 )->RJ8_HORA    := TIME()
								( cAliasRJ8 )->RJ8_OPERAC  := XTEMP->RJ8_OPERAC
								( cAliasRJ8 )->RJ8_USUARI  := ""
								( cAliasRJ8 )->RJ8_STATUS  := "0"
								( cAliasRJ8 )->RJ8_ESOCIA  := "1"
								If XTEMP->RJ8_OPERAC == "1"
									( cAliasRJ8 )->RJ8_MSGLOG  := DtoC(Date())+ " - "+ Time() + "- INCLUSAO DE VERBA " + SUBSTR(XTEMP->RJ8_CONTEU,nSize,4) + "- FILIAL:" + XTEMP2->RJ7_FILPAR
								ElseIf XTEMP->RJ8_OPERAC == "2"
								    ( cAliasRJ8 )->RJ8_MSGLOG  := DtoC(Date())+ " - "+ Time() + "- ALTERACAO DE VERBA " + SUBSTR(XTEMP->RJ8_CONTEU,nSize,4) + "- FILIAL:" + XTEMP2->RJ7_FILPAR
								ElseIf XTEMP->RJ8_OPERAC == "3"
								    ( cAliasRJ8 )->RJ8_MSGLOG  := DtoC(Date())+ " - "+ Time() + "- EXCLUSAO DE VERBA COD: " + SUBSTR(XTEMP->RJ8_CONTEU,nSize,4) + "- FILIAL:" + XTEMP2->RJ7_FILPAR
								EndIf
								( cAliasRJ8 )->( MsUnlock() )

							END TRANSACTION

				    		Aadd(aLog, DtoC( Date() ) + " " + Time() + " - Efetuando gravação RJ8 - Filial" + XTEMP2->RJ7_FILPAR + " TABELA: " + XTEMP->RJ8_TABELA + " - Cadastro de Verbas"  )
				    		//GP936grava(XTEMP->RJ8_FILIAL,XTEMP->RJ8_TABELA,XTEMP->RJ8_CONTEU,XTEMP->RJ8_OPERAC)

				    	  Endif
				    	Else
				    		XTEMP2->(DbSkip())
				    		Loop
				    	EndIf
			    	EndIf

			    	If XTEMP2->RJ7_TABELA == "2"

			    		If xFilial( "SPA",XTEMP2->RJ7_FILPAR ) <> Substr(XTEMP->RJ8_CONTEU,1,nSize)

				    		dbSelectArea("RJ8")
				    		dbSetOrder(2)
				    		If !MsSeek(xFilial("RJ8")+xFilial("SPA",XTEMP2->RJ7_FILPAR)+XTEMP->RJ8_TABELA+XTEMP->RJ8_CONTEU+XTEMP->RJ8_OPERAC)
					    		BEGIN TRANSACTION
						    			//Alimentando a tabela
									 Reclock( cAliasRJ8, .T. )
									( cAliasRJ8 )->RJ8_FILIAL  := xFilial("RJ8")
									( cAliasRJ8 )->RJ8_FILPAR  := xFilial("SPA",XTEMP2->RJ7_FILPAR)
									( cAliasRJ8 )->RJ8_TABELA  := XTEMP->RJ8_TABELA
									( cAliasRJ8 )->RJ8_CONTEU  := XTEMP->RJ8_CONTEU
									( cAliasRJ8 )->RJ8_DATA    := Date()
									( cAliasRJ8 )->RJ8_HORA    := TIME()
									( cAliasRJ8 )->RJ8_OPERAC  := XTEMP->RJ8_OPERAC
									( cAliasRJ8 )->RJ8_USUARI  := ""
									( cAliasRJ8 )->RJ8_STATUS  := "0"
									( cAliasRJ8 )->RJ8_ESOCIA  := "1"
									If XTEMP->RJ8_OPERAC == "1"
										( cAliasRJ8 )->RJ8_MSGLOG  := DtoC(Date())+ " - "+ Time() + "- INCLUSAO DE REGRA DE APONTAMENTO " + SUBSTR(XTEMP->RJ8_CONTEU,nSize,4) + "- FILIAL:" + XTEMP2->RJ7_FILPAR
									ElseIf XTEMP->RJ8_OPERAC == "2"
									    ( cAliasRJ8 )->RJ8_MSGLOG  := DtoC(Date())+ " - "+ Time() + "- ALTERACAO DE REGRA DE APONTAMENTO " + SUBSTR(XTEMP->RJ8_CONTEU,nSize,4) + "- FILIAL:" + XTEMP2->RJ7_FILPAR
									ElseIf XTEMP->RJ8_OPERAC == "3"
									    ( cAliasRJ8 )->RJ8_MSGLOG  := DtoC(Date())+ " - "+ Time() + "- EXCLUSAO DE REGRA DE APONTAMENTO " + SUBSTR(XTEMP->RJ8_CONTEU,nSize,4) + "- FILIAL:" + XTEMP2->RJ7_FILPAR
									EndIf
									( cAliasRJ8 )->( MsUnlock() )
								END TRANSACTION

								Aadd(aLog, DtoC( Date() ) + " " + Time() + " - Efetuando gravação RJ8 - Filial" + XTEMP2->RJ7_FILPAR + " TABELA: " + XTEMP->RJ8_TABELA + " - Regra Apontamento"  )
								//GP936grava(XTEMP->RJ8_FILIAL,XTEMP->RJ8_TABELA,XTEMP->RJ8_CONTEU,XTEMP->RJ8_OPERAC)
							EndIf
						Else
							XTEMP2->(DbSkip())
				    		Loop
						EndIf
					Endif
			    	If XTEMP2->RJ7_TABELA == "3"

			    		If xFilial( "SR6",XTEMP2->RJ7_FILPAR ) <> Substr(XTEMP->RJ8_CONTEU,1,nSize)

				    		dbSelectArea("RJ8")
				    		dbSetOrder(2)
				    		If !MsSeek(xFilial("RJ8")+xFilial("SR6",XTEMP2->RJ7_FILPAR)+XTEMP->RJ8_TABELA+XTEMP->RJ8_CONTEU+XTEMP->RJ8_OPERAC)
					    		BEGIN TRANSACTION
						    			//Alimentando a tabela
									 Reclock( cAliasRJ8, .T. )
									( cAliasRJ8 )->RJ8_FILIAL  := xFilial("RJ8")
									( cAliasRJ8 )->RJ8_FILPAR  := xFilial("SR6",XTEMP2->RJ7_FILPAR)
									( cAliasRJ8 )->RJ8_TABELA  := XTEMP->RJ8_TABELA
									( cAliasRJ8 )->RJ8_CONTEU  := XTEMP->RJ8_CONTEU
									( cAliasRJ8 )->RJ8_DATA    := Date()
									( cAliasRJ8 )->RJ8_HORA    := TIME()
									( cAliasRJ8 )->RJ8_OPERAC  := XTEMP->RJ8_OPERAC
									( cAliasRJ8 )->RJ8_USUARI  := ""
									( cAliasRJ8 )->RJ8_STATUS  := "0"
									( cAliasRJ8 )->RJ8_ESOCIA  := "1"
									If XTEMP->RJ8_OPERAC == "1"
										( cAliasRJ8 )->RJ8_MSGLOG  := DtoC(Date())+ " - "+ Time() + "- INCLUSAO DE TURNO DE TRABALHO " + SUBSTR(XTEMP->RJ8_CONTEU,nSize,4) + "- FILIAL:" + XTEMP2->RJ7_FILPAR
									ElseIf XTEMP->RJ8_OPERAC == "2"
									    ( cAliasRJ8 )->RJ8_MSGLOG  := DtoC(Date())+ " - "+ Time() + "- ALTERACAO DE TURNO DE TRABALHO " + SUBSTR(XTEMP->RJ8_CONTEU,nSize,4) + "- FILIAL:" + XTEMP2->RJ7_FILPAR
									ElseIf XTEMP->RJ8_OPERAC == "3"
									    ( cAliasRJ8 )->RJ8_MSGLOG  := DtoC(Date())+ " - "+ Time() + "- EXCLUSAO DE TURNO DE TRABALHO " + SUBSTR(XTEMP->RJ8_CONTEU,nSize,4) + "- FILIAL:" + XTEMP2->RJ7_FILPAR
									EndIf
									( cAliasRJ8 )->( MsUnlock() )

								END TRANSACTION

								Aadd(aLog, DtoC( Date() ) + " " + Time() + " - Efetuando gravação RJ8 - Filial " + XTEMP2->RJ7_FILPAR + " TABELA: " + XTEMP->RJ8_TABELA + " - Turno de Trabalho"  )
								//GP936grava(XTEMP->RJ8_FILIAL,XTEMP->RJ8_TABELA,XTEMP->RJ8_CONTEU,XTEMP->RJ8_OPERAC)
							Endif
						Else
							XTEMP2->(DbSkip())
				    		Loop
						EndIf
			    	EndIf

			    	If XTEMP2->RJ7_TABELA == "4"

			    		If xFilial( "SRJ",XTEMP2->RJ7_FILPAR ) <> Substr(XTEMP->RJ8_CONTEU,1,nSize)

				    		dbSelectArea("RJ8")
				    		dbSetOrder(2)
				    		If !MsSeek(xFilial("RJ8")+xFilial("SRJ",XTEMP2->RJ7_FILPAR)+XTEMP->RJ8_TABELA+XTEMP->RJ8_CONTEU+XTEMP->RJ8_OPERAC)
					    		BEGIN TRANSACTION
						    			//Alimentando a tabela
									 Reclock( cAliasRJ8, .T. )
									( cAliasRJ8 )->RJ8_FILIAL  := xFilial("RJ8")
									( cAliasRJ8 )->RJ8_FILPAR  := xFilial("SRJ",XTEMP2->RJ7_FILPAR)
									( cAliasRJ8 )->RJ8_TABELA  := XTEMP->RJ8_TABELA
									( cAliasRJ8 )->RJ8_CONTEU  := XTEMP->RJ8_CONTEU
									( cAliasRJ8 )->RJ8_DATA    := Date()
									( cAliasRJ8 )->RJ8_HORA    := TIME()
									( cAliasRJ8 )->RJ8_OPERAC  := XTEMP->RJ8_OPERAC
									( cAliasRJ8 )->RJ8_USUARI  := ""
									( cAliasRJ8 )->RJ8_STATUS  := "0"
									( cAliasRJ8 )->RJ8_ESOCIA  := "1"
									If XTEMP->RJ8_OPERAC == "1"
										( cAliasRJ8 )->RJ8_MSGLOG  := DtoC(Date())+ " - "+ Time() + "- INCLUSAO DE FUNCOES " + SUBSTR(XTEMP->RJ8_CONTEU,nSize,4) + "- FILIAL:" + XTEMP2->RJ7_FILPAR
									ElseIf XTEMP->RJ8_OPERAC == "2"
									    ( cAliasRJ8 )->RJ8_MSGLOG  := DtoC(Date())+ " - "+ Time() + "- ALTERACAO DE FUNCOES " + SUBSTR(XTEMP->RJ8_CONTEU,nSize,4) + "- FILIAL:" + XTEMP2->RJ7_FILPAR
									ElseIf XTEMP->RJ8_OPERAC == "3"
									    ( cAliasRJ8 )->RJ8_MSGLOG  := DtoC(Date())+ " - "+ Time() + "- EXCLUSAO DE FUNCOES " + SUBSTR(XTEMP->RJ8_CONTEU,nSize,4) + "- FILIAL:" + XTEMP2->RJ7_FILPAR
									EndIf
									( cAliasRJ8 )->( MsUnlock() )

								END TRANSACTION
								Aadd(aLog, DtoC( Date() ) + " " + Time() + " - Efetuando gravação RJ8 - Filial " + XTEMP2->RJ7_FILPAR + " TABELA: " + XTEMP->RJ8_TABELA + " - Funções"  )
								//GP936grava(XTEMP->RJ8_FILIAL,XTEMP->RJ8_TABELA,XTEMP->RJ8_CONTEU,XTEMP->RJ8_OPERAC)
							EndIf
						Else
							XTEMP2->(DbSkip())
				    		Loop
						EndIf
			    	Endif
			    	If XTEMP2->RJ7_TABELA == "5"

			    		If xFilial( "SPJ",XTEMP2->RJ7_FILPAR ) <> Substr(XTEMP->RJ8_CONTEU,1,nSize)

				    		dbSelectArea("RJ8")
				    		dbSetOrder(2)
				    		If !MsSeek(xFilial("RJ8")+xFilial("SPJ",XTEMP2->RJ7_FILPAR)+XTEMP->RJ8_TABELA+XTEMP->RJ8_CONTEU+XTEMP->RJ8_OPERAC+XTEMP->RJ8_STATUS)
					    		BEGIN TRANSACTION

						    			//Alimentando a tabela
									 Reclock( cAliasRJ8, .T. )
									( cAliasRJ8 )->RJ8_FILIAL  := xFilial("RJ8")
									( cAliasRJ8 )->RJ8_FILPAR  := xFilial("SPJ",XTEMP2->RJ7_FILPAR)
									( cAliasRJ8 )->RJ8_TABELA  := XTEMP->RJ8_TABELA
									( cAliasRJ8 )->RJ8_CONTEU  := XTEMP->RJ8_CONTEU
									( cAliasRJ8 )->RJ8_DATA    := Date()
									( cAliasRJ8 )->RJ8_HORA    := TIME()
									( cAliasRJ8 )->RJ8_OPERAC  := XTEMP->RJ8_OPERAC
									( cAliasRJ8 )->RJ8_USUARI  := ""
									( cAliasRJ8 )->RJ8_STATUS  := "0"
									( cAliasRJ8 )->RJ8_ESOCIA  := "1"
									If XTEMP->RJ8_OPERAC == "1"
										( cAliasRJ8 )->RJ8_MSGLOG  := DtoC(Date())+ " - "+ Time() + "- INCLUSAO DE HORARIO PADRAO " + SUBSTR(XTEMP->RJ8_CONTEU,nSize,4) + "- FILIAL: " + xFilial("SPJ",XTEMP2->RJ7_FILPAR)
									ElseIf XTEMP->RJ8_OPERAC == "2"
									    ( cAliasRJ8 )->RJ8_MSGLOG  := DtoC(Date())+ " - "+ Time() + "- ALTERACAO DE HORARIO PADRAO " + SUBSTR(XTEMP->RJ8_CONTEU,nSize,4) + "- FILIAL: " + xFilial("SPJ",XTEMP2->RJ7_FILPAR)
									ElseIf XTEMP->RJ8_OPERAC == "3"
									    ( cAliasRJ8 )->RJ8_MSGLOG  := DtoC(Date())+ " - "+ Time() + "- EXCLUSAO DE HORARIO PADRAO " + SUBSTR(XTEMP->RJ8_CONTEU,nSize,4) + "- FILIAL: " + xFilial("SPJ",XTEMP2->RJ7_FILPAR)
									EndIf
									( cAliasRJ8 )->( MsUnlock() )

								END TRANSACTION
								Aadd(aLog, DtoC( Date() ) + " " + Time() + " - Efetuando gravação Tabela RJ8 - Filial " + XTEMP2->RJ7_FILPAR + " TABELA: " + XTEMP->RJ8_TABELA + " - Horario Padrao"  )
								//GP936grava(XTEMP->RJ8_FILIAL,XTEMP->RJ8_TABELA,XTEMP->RJ8_CONTEU,XTEMP->RJ8_OPERAC, xFilial("SPJ",XTEMP2->RJ7_FILPAR))
							EndIf
						Else
							XTEMP2->(DbSkip())
				    		Loop
						EndIf
			    	EndIf
			    	If XTEMP2->RJ7_TABELA == "6"

			    		If xFilial( "CTT",XTEMP2->RJ7_FILPAR ) <> Substr( XTEMP->RJ8_CONTEU,1,nSize )

				    		dbSelectArea("RJ8")
				    		dbSetOrder(2)
				    		If !MsSeek(xFilial("RJ8")+xFilial("CTT",XTEMP2->RJ7_FILPAR)+XTEMP->RJ8_TABELA+XTEMP->RJ8_CONTEU+XTEMP->RJ8_OPERAC)
					    		BEGIN TRANSACTION

					    			//Alimentando a tabela
								 Reclock( cAliasRJ8, .T. )
								( cAliasRJ8 )->RJ8_FILIAL  := xFilial("RJ8")
								( cAliasRJ8 )->RJ8_FILPAR  := xFilial("CTT",XTEMP2->RJ7_FILPAR)
								( cAliasRJ8 )->RJ8_TABELA  := XTEMP->RJ8_TABELA
								( cAliasRJ8 )->RJ8_CONTEU  := XTEMP->RJ8_CONTEU
								( cAliasRJ8 )->RJ8_DATA    := Date()
								( cAliasRJ8 )->RJ8_HORA    := TIME()
								( cAliasRJ8 )->RJ8_OPERAC  := XTEMP->RJ8_OPERAC
								( cAliasRJ8 )->RJ8_USUARI  := ""
								( cAliasRJ8 )->RJ8_STATUS  := "0"
								( cAliasRJ8 )->RJ8_ESOCIA  := "1"
								If XTEMP->RJ8_OPERAC == "1"
									( cAliasRJ8 )->RJ8_MSGLOG  := DtoC(Date())+ " - "+ Time() + "- INCLUSAO DE CENTRO DE CUSTO " + SUBSTR(XTEMP->RJ8_CONTEU,nSize,4) + "- FILIAL: " + XTEMP2->RJ7_FILPAR
								ElseIf XTEMP->RJ8_OPERAC == "2"
								    ( cAliasRJ8 )->RJ8_MSGLOG  := DtoC(Date())+ " - "+ Time() + "- ALTERACAO DE CENTRO DE CUSTO " + SUBSTR(XTEMP->RJ8_CONTEU,nSize,4) + "- FILIAL:" + XTEMP2->RJ7_FILPAR
								ElseIf XTEMP->RJ8_OPERAC == "3"
								    ( cAliasRJ8 )->RJ8_MSGLOG  := DtoC(Date())+ " - "+ Time() + "- EXCLUSAO DE CENTRO DE CUSTO " + SUBSTR(XTEMP->RJ8_CONTEU,nSize,4) + "- FILIAL:" + XTEMP2->RJ7_FILPAR
								EndIf
								( cAliasRJ8 )->( MsUnlock() )

								END TRANSACTION
								Aadd(aLog, DtoC( Date() ) + " " + Time() + " - Efetuando gravação RJ8 - Filial " + XTEMP2->RJ7_FILPAR + " TABELA: " + XTEMP->RJ8_TABELA + " - Centro de Custo"  )
								//GP936grava(XTEMP->RJ8_FILIAL,XTEMP->RJ8_TABELA,XTEMP->RJ8_CONTEU,XTEMP->RJ8_OPERAC)
							EndIf
						Else
							XTEMP2->(DbSkip())
				    		Loop
						Endif
			    	Endif
			  XTEMP2->(DbSkip())
		    EndDo
		     XTEMP2->( dbCloseArea() )

		     GP936grava(XTEMP->RJ8_FILIAL,XTEMP->RJ8_TABELA,XTEMP->RJ8_CONTEU,XTEMP->RJ8_OPERAC)
		     Aadd(aLog, DtoC( Date() ) + " " + Time() +  STR0050) //" - Gravação executada com sucesso!"
			 XTEMP->(dbSkip())
		EndDo
	EndIf
	XTEMP->( dbCloseArea() )
	//Após a criação das filiais na tabela RJ8 fazemos as inclusões nas tabelas correspondentes
	GPEA936GRV(@aLog)

	If Len(aLog) > 0

		GP936ARQ(aLog)

	EndIf
	RESET ENVIRONMENT
Return

Static Function GP936grava(cFili,cTabela,cConteudo,cOperacao)
Local cAliasRJ8:= "RJ8"
local cMsg		:= ""
Local cTam		:= FWSizeFilial()

			 dbSelectArea("RJ8")
		     dbSetOrder(3)
		     IF MsSeek(cFili+cTabela+cConteudo+cOperacao)

			 cMsg	:= (cAliasRJ8)->RJ8_MSGLOG

			   Reclock( cAliasRJ8, .F. )
				( cAliasRJ8 )->RJ8_STATUS  := "1"
				( cAliasRJ8 )->RJ8_MSGLOG  := cMsg + CHR(13)+CHR(10)+ DToC(Date()) + " " + TIME() + "- Geração efetuada nas filiais configuradas"
				( cAliasRJ8 )->( MsUnlock() )

			  RJ8->(dbCloseArea())

			 Endif

Return

/*/{Protheus.doc} GP936ARQ
//TODO Descrição auto-gerada.
@author Samuel de Vincenzo
@since 10/05/2019
@version P12
@return return, return_description
@param aLogProc, array, descricao
@example
(examples)
@see (links_or_references)
/*/
Static Function GP936ARQ(aLogProc)
Local cArq		:= '\sched_copia'+DtoS(Date()) + ".txt"
Local cDir		:= "\schedule_copia"
Local cQuebra	:= CRLF + "+===========================================================================================================================================+" + CRLF
Local lOk		:= .T.
Local cTexto	:= ""
Local cFileNom	:= cDir+cArq
Local lExistDir	:= ExistDir(cDir)
Local nX		:= 0

Default aLogProc	:= {}

	If !lExistDir
		MakeDir(cDir)
	Endif

	If File(cFileNom)
		nHandle := fopen(cFileNom , FO_READWRITE )
		FSeek(nHandle, 0, FS_END)

		For nX := 1 to Len(aLogproc)

			If nX == 1
				cTexto := aLogProc[nX] + CRLF
		    Else
		    	cTexto += aLogProc[nX] + CRLF
		    Endif

		Next nX

		cTexto += cQuebra

		FWrite(nHandle,cTexto)
        FClose(nHandle)

	Else
		nHandle	:= Fcreate(cFileNom)
		//Montando a mensagem
        cTexto := cQuebra
        cTexto += "Função   - "+ FunName()       + CRLF
        cTexto += "Usuário  - "+ cUserName       + CRLF
        cTexto += "Data     - "+ dToC(Date()) 	 + CRLF
        cTexto += "Hora     - "+ Time()          + CRLF
        cTexto += cQuebra

        For nX := 1 to Len(aLogproc)

        	cTexto += aLogProc[nX] + CRLF

		Next nX

		cTexto += cQuebra

        FWrite(nHandle,cTexto)
        FClose(nHandle)

	Endif

Return

/*/{Protheus.doc} GPEA936GRV
//TODO Descrição auto-gerada.
@author Samuel de Vincenzo
@since 13/05/2019
@version undefined
@param aLog, array, descricao
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GPEA936GRV(aLog)
Local nFilSize	 := FWSizeFilial()
Local aSRV		 := {}
Local aDadosIMP	 := {}
Local aDadosComp := {}
Local aDadosAlt  := {}
Local aDadosSX3  := {}
Local aHorasDia	 := {}
Local aHorario	 := {}
Local aCab       := {}
Local aItem      := {}
Local aRetLog	 := ""
Local nX		 := 0
Local nY		 := 0
Local nZ		:= 0
Local i			:= 0
Local j			:= 0
Local k			:= 0
Local nPos		:= 0
Local nP		:= 0
Local cfil	    := ""
Local cQuery	:= ""
Local cQuery1	:= ""
Local cLauto	:= {}
Local nErro		:= ""
Local aError	:= {}
Local oModel    := Nil
Local nCount	:= 0
Local nCount1	:= 0
Local nSeq		:= 0
Local nDiasSemana := 0
Local lContinua   := .T.
Local lRet		:= .T.
Local nResult   := 0
Local nPesq		:= 0
Local nItem		:= 0

Private aRotina := {}

Private lMsErroAuto	   := .F.
Private lMsHelpAuto	   := .F.
Private lAutoErrNoFile := .T.

Default aLog	:= {}


	 Aadd(aLog, DtoC( Date() ) + " " + Time() + " - Iniciando as Inclusões!" )

	cQuery := "SELECT RJ8_FILIAL,RJ8_TABELA,RJ8_FILPAR,RJ8_CONTEU,RJ8_DATA,RJ8_HORA,RJ8_OPERAC,RJ8_STATUS,RJ8_USUARI,RJ8_ESOCIA,RJ8_MSGLOG "
	cQuery += "FROM "+RetSqlName("RJ8")+" RJ8 "
	cQuery += "WHERE RJ8.RJ8_FILPAR <> '" + Space(FwGetTamFilial) + "' AND "
	cQuery += "RJ8.RJ8_STATUS = '0' AND "
	cQuery += "RJ8.D_E_L_E_T_ = '' "
	cQuery += "ORDER BY RJ8_TABELA,RJ8_DATA,RJ8_HORA ASC "
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"XRJ8",.T.,.T.)

	Count to nCount

	If nCount > 0

		dbSelectArea("XRJ8")
	    dbGoTop()
			while !XRJ8->( EOF() )
				lMsErroAuto	   := .F.
				//----------------------------------------------------------------------------
				// Tabela SRV - Cadastro de Verbas
				//----------------------------------------------------------------------------
				IF XRJ8->RJ8_TABELA == "1"

					If XRJ8->RJ8_OPERAC =="1" //INCLUSAO

						dbSelectArea("SRV")
						dbSetOrder(1)
						If dbSeek(XRJ8->RJ8_CONTEU)
							aDadosIMP := GP936Rec("SRV")
						EndIf

						cFil := cfilant
						cfilant := fGetFil(XRJ8->RJ8_FILPAR)

						oModel := FWLoadModel("GPEA040")
						oModel:SetOperation(MODEL_OPERATION_INSERT)
						oModel:Activate()

 						For nX := 1 to Len(aDadosIMP)
							nResult := Ascan(aDadosIMP[nX],"RV_FILIAL")
							If nResult > 0
							 Loop
							Else
								oModel:LoadValue("SRVMASTER",aDadosIMP[nX,1],aDadosIMP[nX][2])
							Endif
						Next nX

						If oModel:VldData()
							oModel:CommitData()

						//Chamo o programa para atualização da tabela RJ8
							GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS)
							aAdd(aLog,"Inclusao da verba na filial: " + XRJ8->RJ8_FILPAR + " Cód: " +SubStr(XRJ8->RJ8_CONTEU,nFilSize+1,3) )
						Else
							aError := oModel:GetErrorMessage()
							aAdd(aLog,"Erro na Inclusão de Verba na Filial: "+ XRJ8->RJ8_FILPAR +" Cód: "+substr(XRJ8->RJ8_CONTEU,nFilSize+1,3)+" Motivo: "+aError[4]+" - "+aError[5]+" - "+ aError[6])
							//+aDadosIMP[nX,1]+
							//Chamo o programa para inclusao do retorno de erro da Rotina Automatica na RJ8
							GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,aError[4]+" - "+aError[5]+" - "+ aError[6])
						EndIf

						oModel:DeActivate()

						cfilant := cFil

					ElseIf XRJ8->RJ8_OPERAC =="2" //ALTERACAO

						dbSelectArea("SRV")
						dbSetOrder(1)
						If dbSeek(XRJ8->RJ8_CONTEU)
							aDadosIMP := GP936Rec("SRV")
						EndIf
						SRV->( DbCloseArea())
						cFil := cfilant
						cfilant := fGetFil(XRJ8->RJ8_FILPAR)

						DbSelectArea("SRV")
						SRV->( DbGoTop() )
						SRV->( DbSetOrder(1) )
						SRV->( DbSeek(xFilial("SRV") + aDadosImp[1,2] ) )

						aDadosComp := GP936REC("SRV")

						oModel := FWLoadModel("GPEA040")
						oModel:SetOperation(MODEL_OPERATION_UPDATE)
						oModel:Activate()

						For nX := 1 to Len(aDadosIMP)

						 	nPos := aScan(aDadosComp[nX],aDadosIMP[nX,1])

						 	If nPos > 0
						 		if aDadosIMP[nX][2] <> aDadosComp[nX][2]
						 			oModel:LoadValue("SRVMASTER",aDadosIMP[nX,1],aDadosIMP[nX][2])
						 		Else
						 			Loop
						 		Endif
						 	Endif
						Next nX

						If oModel:VldData()
							oModel:CommitData()
							//Chamo o programa para atualização da tabela RJ8
							GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS)
							aAdd(aLog,"Alteracao de verba cod na filial: " + XRJ8->RJ8_FILPAR+ " Cód: " +SubStr(XRJ8->RJ8_CONTEU,nFilSize+1,3) )
						Else
							aError := oModel:GetErrorMessage()
							aAdd(aLog,"Erro na Alteração de Verba na Filial: "+ XRJ8->RJ8_FILPAR +" Cód: "+substr(XRJ8->RJ8_CONTEU,nFilSize+1,3)+" Motivo: "+aError[4]+" - "+aError[5]+" - "+ aError[6])

							//Chamo o programa para inclusao do retorno de erro da Rotina Automatica na RJ8
							GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,aError[4]+" - "+aError[5]+" - "+ aError[6])
						EndIf
						oModel:DeActivate()

						cfilant := cFil
					ElseIf XRJ8->RJ8_OPERAC =="3" //EXCLUSAO

						cFil := cfilant
						cfilant := fGetFil(XRJ8->RJ8_FILPAR)

						dbSelectArea("SRV")
						dbSetOrder(1)
						If dbSeek( xFilial("SRV",XRJ8->RJ8_FILPAR) + Substr(XRJ8->RJ8_CONTEU,nFilSize+1,3) )

							oModel := FWLoadModel("GPEA040")
							oModel:SetOperation(MODEL_OPERATION_DELETE)
							oModel:Activate()

							If oModel:VldData()
								oModel:CommitData()
								//Chamo o programa para atualização da tabela RJ8
								GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS)
								aAdd(aLog,"Exclusao da verba cod: "+aDadosIMP[1][2]+" na filial: " + XRJ8->RJ8_FILPAR+ " Cód: " +SubStr(XRJ8->RJ8_CONTEU,nFilSize+1,3) )
							Else
								aError := oModel:GetErrorMessage()
								aAdd(aLog,"Erro na Exclusao de Verba na Filial: "+ XRJ8->RJ8_FILPAR +" Cód: "+substr(XRJ8->RJ8_CONTEU,nFilSize+1,3)+" Motivo: "+aError[4]+" - "+aError[5]+" - "+ aError[6])
								//+aDadosIMP[nX,1]+
								//Chamo o programa para inclusao do retorno de erro da Rotina Automatica na RJ8
								GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,aError[4]+" - "+aError[5]+" - "+ aError[6])
							EndIf

							oModel:DeActivate()
						Else
							GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,"Registro não Encontrado!")
							aAdd(aLog,"Erro na Exclusao da Verba na Filial: "+ XRJ8->RJ8_FILPAR +"Motivo: Registro nao Localizado - Conteudo: " + XRJ8->RJ8_CONTEU)
						EndIf
						cfilant := cFil
						aDadosComp := {}
					EndIf

				EndIf

				//----------------------------------------------------------------------------
				// Tabela SPA - Regras de Apontamento
				//----------------------------------------------------------------------------
				If XRJ8->RJ8_TABELA == "2"

					If XRJ8->RJ8_OPERAC =="1" //inclusao

						dbSelectArea("SPA")
						dbSetOrder(1)
						If dbSeek(XRJ8->RJ8_CONTEU)
							aDadosIMP := GP936Rec("SPA")
						EndIf
						SPA->(DbCloseArea())

						cFil := cfilant
						cfilant := XRJ8->RJ8_FILPAR

						MsExecAuto( { |x,y|PONA060( x,y ) }, aDadosIMP , 3 )

						If !lMsErroAuto
							GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,nErro)
							aAdd(aLog,"Inclusao de Regra de Apontamento cod: "+aDadosIMP[1][2]+" na filial: " + XRJ8->RJ8_FILPAR)
						Else
							nErro :=""
							cLauto := getAutoGRLog()
							for i := 1 to len(cLauto)
							nErro += cLauto[i]
							next i
							GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,nErro)
							ConOut( "Erro na inclusao Regra de Apontamento" )
						EndIf

						cfilant := cFil

					ElseIf XRJ8->RJ8_OPERAC =="2" //alteracao

						dbSelectArea("SPA")
						dbSetOrder(1)
						If dbSeek(XRJ8->RJ8_CONTEU)
							aDadosIMP := GP936Rec("SPA")
						EndIf
						SPA->(DbCloseArea())

						cFil := cfilant
						cfilant := XRJ8->RJ8_FILPAR
						/*
						DbSelectArea("SPA")
						SPA->( DbSetOrder(1) )
						SPA->( DbGoTop() )
						SPA->( DbSeek(xFilial("SPA") + aDadosImp[1,2] ) )

						aDadosComp := GP936REC("SPA")

						For nX := 1 to Len(aDadosIMP)

							nPos := aScan(aDadosComp[nX],aDadosIMP[nX,1])

							if nPos > 0
								if aDadosIMP[nX][2] <> aDadosComp[nX][2]
									aAdd(aDadosAlt,{aDadosIMP[nX][1] , aDadosIMP[nX][2],Nil})
								Else
									Loop
								Endif
							EndIf

						Next nX
						aDadosImp := {}
						aDadosImp := aClone(aDadosAlt)
						*/
						MsExecAuto( { |x,y|PONA060( x,y ) }, aDadosIMP , 4 )

						If !lMsErroAuto
							GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,nErro)
							aAdd(aLog,"Alteraçao da Regra de Apontamento cod: "+aDadosIMP[1][2]+" na filial: " + XRJ8->RJ8_FILPAR)
						Else
							nErro :=""
							cLauto := getAutoGRLog()
							for i := 1 to len(cLauto)
							nErro += cLauto[i]
							next i
							GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,nErro)
							ConOut( "Erro na Alteração Regra de Apontamento" )
						EndIf

						cfilant := cFil
						aDadosComp := {}
						aDadosAlt  := {}

					ElseIf XRJ8->RJ8_OPERAC =="3" //exclusao

						cFil := cfilant
						cfilant := XRJ8->RJ8_FILPAR

						DbSelectArea("SPA")
						SPA->(dbSetOrder(1))
						SPA->(dbGoTop())
						If dbSeek( xFilial("SPA",XRJ8->RJ8_FILPAR) + Substr(XRJ8->RJ8_CONTEU,nFilSize+1,3) )

							aDadosIMP := GP936Rec("SPA")

							MsExecAuto( { |x,y|PONA060( x,y ) }, aDadosIMP , 5 )

							If !lMsErroAuto
								GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,Nil)
								aAdd(aLog,"Exclusao de Regra de Apontamento cod:  " + Substr(XRJ8->RJ8_CONTEU,nFilSize+1,3) +"  na filial: " + XRJ8->RJ8_FILPAR)
							Else
								nErro :=""
								cLauto := getAutoGRLog()
								for i := 1 to len(cLauto)
								nErro += cLauto[i]
								next i
								GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,nErro)
								ConOut( "Erro na exclusão Regra de Apontamento" )
							EndIf
						Else
						   GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,"Registro não Encontrado!")
						   aAdd(aLog,"Erro na Exclusao da Regra de Apontamento na Filial: "+ XRJ8->RJ8_FILPAR +"Motivo: Registro nao Localizado - Conteudo: " + XRJ8->RJ8_CONTEU)

						EndIf
						cfilant := cFil
						SPA->(dbCloseArea())
					EndIf
				EndIf

				//----------------------------------------------------------------------------
				// Tabela SR6 - Turnos de Trabalho
				//----------------------------------------------------------------------------
				If XRJ8->RJ8_TABELA == "3"

					If XRJ8->RJ8_OPERAC =="1" //Inclusao

						dbSelectArea("SR6")
						dbSetOrder(1)
						If dbSeek(XRJ8->RJ8_CONTEU)
							aDadosIMP := GP936Rec("SR6")
						EndIf
						SR6->(DbCloseArea())

						cFil := cfilant
						cfilant := XRJ8->RJ8_FILPAR

						MsExecAuto( { |x,y|GPEA080( x,y ) }, aDadosIMP , 3 )

						If !lMsErroAuto
							GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,nErro)
							aAdd(aLog,"Inclusao de Turno de Trabalho cod: "+aDadosIMP[1][2]+" na filial: " + XRJ8->RJ8_FILPAR)
						Else
							nErro :=""
							cLauto := getAutoGRLog()
							for i := 1 to len(cLauto)
							nErro += cLauto[i]+CHR(13)+CHR(10)
							next i
							GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,nErro)
							aAdd(aLog,"Erro na Inclusão do Turno de Trabalho cod: "+substr(XRJ8->RJ8_CONTEU,nFilSize+1,3)+" na filial: " + XRJ8->RJ8_FILPAR)
							aAdd(aLog,"Motivo: " + nErro)
							ConOut( "Erro na inclusao Turno de Trabalho" )
						EndIf

						cfilant := cFil

					ElseIf XRJ8->RJ8_OPERAC =="2" //Alteracao

						dbSelectArea("SR6")
						dbSetOrder(1)
						If dbSeek(XRJ8->RJ8_CONTEU)
							aDadosIMP := GP936Rec("SR6")
						EndIf


						cFil := cfilant
						cfilant := XRJ8->RJ8_FILPAR

						MsExecAuto( { |x,y|GPEA080( x,y ) }, aDadosIMP , 4 )

						If !lMsErroAuto
							GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,nErro)
							aAdd(aLog,"Alteraçao de Turno de Trabalho cod: "+aDadosIMP[1][2]+" na filial: " + XRJ8->RJ8_FILPAR)
						Else
							nErro :=""
							cLauto := getAutoGRLog()
							for i := 1 to len(cLauto)
							nErro += cLauto[i]+CHR(13)+CHR(10)
							next i
							GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,nErro)
							aAdd(aLog,"Erro na Alteração do Turno de Trabalho cod: "+substr(XRJ8->RJ8_CONTEU,nFilSize+1,3)+" na filial: " + XRJ8->RJ8_FILPAR)
							aAdd(aLog,"Motivo: " + nErro)
							ConOut( "Erro na Alteracao Turno de Trabalho" )
						EndIf
						SR6->(dbCloseArea())

						cfilant := cFil


					ElseIf XRJ8->RJ8_OPERAC =="3" //Exclusao

						cFil := cfilant
						cfilant := XRJ8->RJ8_FILPAR

						dbSelectArea("SR6")
						SR6->(dbSetOrder(1))
						SR6->(dbGoTop())
						If dbSeek( xFilial("SR6",XRJ8->RJ8_FILPAR) + Substr(XRJ8->RJ8_CONTEU,nFilSize+1,3) )

							aDadosIMP := GP936Rec("SR6")

							MsExecAuto( { |x,y|GPEA080( x,y ) }, aDadosIMP , 5 )

							If !lMsErroAuto
								GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,"")
								aAdd(aLog,"Exclusao de Turno de Trabalho cod: "+aDadosIMP[1][2]+" na filial: " + XRJ8->RJ8_FILPAR)
							Else
								nErro :=""
								cLauto := getAutoGRLog()
								for i := 1 to len(cLauto)
								nErro += cLauto[i]+CHR(13)+CHR(10)
								next i
								GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,nErro)
								aAdd(aLog,"Motivo: " + nErro)
								aAdd(aLog,"Erro na Exclusao Turno de Trabalho" )
							EndIf
						Else
							GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,"Registro não Encontrado!")
						   aAdd(aLog,"Erro na Exclusao do Turno de Trabalho na Filial: "+ XRJ8->RJ8_FILPAR +"Motivo: Registro nao Localizado - Conteudo: " + XRJ8->RJ8_CONTEU)

						Endif
						SR6->(dbCloseArea())
						cfilant := cFil

					EndIf
				EndIf

				//----------------------------------------------------------------------------
				// Tabela SRJ - Cadastro de Funcoes
				//----------------------------------------------------------------------------
				If XRJ8->RJ8_TABELA == "4"

					If XRJ8->RJ8_OPERAC =="1" //INCLUSAO

						dbSelectArea("SRJ")
						dbSetOrder(1)
						If dbSeek(XRJ8->RJ8_CONTEU)
							aDadosIMP := GP936Rec("SRJ")
						EndIf
						SRJ->(dbCloseArea())

						cFil := cfilant
						cfilant := fGetFil(XRJ8->RJ8_FILPAR)

						oModel := FWLoadModel("GPEA030")
						oModel:SetOperation(MODEL_OPERATION_INSERT)
						oModel:Activate()

						For nX := 1 to Len(aDadosIMP)

							oModel:LoadValue("GPEA030_SRJ",aDadosIMP[nX,1],aDadosIMP[nX][2])

						Next nX

						If oModel:VldData()

							oModel:CommitData()

						//Chamo o programa para atualização da tabela RJ8
						GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,"")
						aAdd(aLog,"Inclusao de Turno de Trabalho na filial: " + XRJ8->RJ8_FILPAR)
						Else
							aError := oModel:GetErrorMessage()
							aAdd(aLog,"Erro na inclusão de Função na Filial: "+ XRJ8->RJ8_FILPAR +" Cód: "+substr(XRJ8->RJ8_CONTEU,nFilSize+1,3)+" Motivo: "+aError[4]+" - "+aError[5]+" - "+ aError[6])
							GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,aError[4]+" - "+aError[5]+" - "+ aError[6])
						EndIf

						oModel:DeActivate()

						cfilant := cFil

					ElseIf XRJ8->RJ8_OPERAC =="2" //ALTERACAO

						dbSelectArea("SRJ")
						dbSetOrder(1)
						If dbSeek(XRJ8->RJ8_CONTEU)
							aDadosIMP := GP936Rec("SRJ")
						EndIf
						SRJ->(dbCloseArea())

						cFil := cfilant
						cfilant := fGetFil(XRJ8->RJ8_FILPAR)

						dbSelectArea("SRJ")
						SRJ->(dbSetOrder(1))
						SRJ->(dbGoTop())
						SRJ->( DbSeek(xFilial("SRJ") + aDadosImp[1,2] ) )

						aDadosComp := GP936REC("SRJ")

						oModel := FWLoadModel("GPEA030")
						oModel:SetOperation(MODEL_OPERATION_UPDATE)
						oModel:Activate()

						For nX := 1 to Len(aDadosIMP)

							nPos := aScan(aDadosComp[nX],aDadosIMP[nX,1])

						 	If nPos > 0
						 		if aDadosIMP[nX][2] <> aDadosComp[nX][2]
						 			oModel:LoadValue("GPEA030_SRJ",aDadosIMP[nX,1],aDadosIMP[nX][2])
						 		Else
						 			Loop
						 		Endif
						 	Endif

						Next nX

						If oModel:VldData()
							oModel:CommitData()

						//Chamo o programa para atualização da tabela RJ8
						GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,"")
						aAdd(aLog,"Alteracao de Turno de Trabalho cod: "+aDadosIMP[1][2]+" na filial: " + XRJ8->RJ8_FILPAR)
						Else
							aError := oModel:GetErrorMessage()
							aAdd(aLog,"Erro na alteração de Função na Filial: "+ XRJ8->RJ8_FILPAR +" Cód: "+substr(XRJ8->RJ8_CONTEU,nFilSize+1,3)+" Motivo: "+aError[4]+" - "+aError[5]+" - "+ aError[6])
							GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,aError[4]+" - "+aError[5]+" - "+ aError[6])
						EndIf

						oModel:DeActivate()

						aDadosComp := {}
						cfilant := cFil

						SRJ->(dbCloseArea())

					ElseIf XRJ8->RJ8_OPERAC =="3" //EXCLUSAO

						cFil := cfilant
						cfilant := fGetFil(XRJ8->RJ8_FILPAR)

						dbSelectArea("SRJ")
						dbSetOrder(1)
						If dbSeek(xFilial("SRJ")+SubStr(XRJ8->RJ8_CONTEU,nFilSize+1,5))

							oModel := FWLoadModel("GPEA030")
							oModel:SetOperation(MODEL_OPERATION_DELETE)
							oModel:Activate()

							If oModel:VldData()
								oModel:CommitData()
								//Chamo o programa para atualização da tabela RJ8
								GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,"")
								aAdd(aLog,"Exclusao de Funcoes cod: " + SubStr(XRJ8->RJ8_CONTEU,nFilSize+1,3) +"  na filial: " + XRJ8->RJ8_FILPAR)
							Else
								aError := oModel:GetErrorMessage()
								aAdd(aLog,"Erro na Exclusao de Funcao  na Filial: "+ XRJ8->RJ8_FILPAR +"Motivo: "+aError[4]+" - "+aError[5]+" - "+ aError[6])
								//+aDadosIMP[nX,1]+
								//Chamo o programa para inclusao do retorno de erro da Rotina Automatica na RJ8
								GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,aError[4]+" - "+aError[5]+" - "+ aError[6])
							EndIf

							oModel:DeActivate()
						Else
							GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,"Registro não Encontrado!")
							aAdd(aLog,"Erro na Exclusao de Funcao na Filial: "+ XRJ8->RJ8_FILPAR +"Motivo: Registro nao Localizado - Conteudo: " + XRJ8->RJ8_CONTEU)
						EndIf
						cfilant := cFil
						SRJ->(dbCloseArea())
					EndIf
				EndIf
				//----------------------------------------------------------------------------
				// Tabela SPJ - Horário Padrão
				//----------------------------------------------------------------------------
				If XRJ8->RJ8_TABELA == "5"

					If XRJ8->RJ8_OPERAC =="1" //inclusao

						aDadosIMP := {}
						aHorasDia := {}
						dbSelectArea("SPJ")
						dbSetOrder(1)
						If dbSeek( Alltrim( XRJ8->RJ8_CONTEU ) )

							dbSelectArea("SX3")
							dbSetOrder(1)
							dbSeek("SPJ")
							While ( !Eof() .And. (SX3->X3_ARQUIVO == "SPJ") )
								If SX3->X3_CONTEXT != "V"
									Aadd(aDadosIMP,{ SX3->X3_CAMPO })
								EndIf
								dbSelectArea("SX3")
								dbSkip()
							EndDo
							aHorasDia := {}
							fCarHPad("SPJ",Alltrim( XRJ8->RJ8_CONTEU ),@aHorasDia)

							cFil := cfilant
							cfilant := XRJ8->RJ8_FILPAR

							If Len(aHorasDia) > 0 .and. Len(aDadosIMP) > 0

								For j := 1 to Len(aHorasDia)

									RecLock( "SPJ", .T. )

										For k := 1 to Len(aDadosIMP)
											nPesq := Ascan(aDadosIMP[k], "PJ_FILIAL")
											If nPesq > 0
												SPJ->PJ_FILIAL := cfilAnt
											Else
												&(aDadosIMP[k][1]) := aHorasDia[j][k]
											EndIf
										Next k

									SPJ->(MsUnlock())
								Next j
							EndIf

							cfilant := cFil

							//Chamo o programa para atualização da tabela RJ8
							GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,"")
							aAdd(aLog,"Inclusao de Horário Padrão na filial: " + XRJ8->RJ8_FILPAR)
						Else
							GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,"Registro não Encontrado!")
							aAdd(aLog,"Erro na Inclusão de Horário Padrão na Filial: "+ XRJ8->RJ8_FILPAR +"Motivo: Registro nao Localizado - Conteudo: " + XRJ8->RJ8_CONTEU)
						EndIf

						SPJ->( dbCloseArea() )


					ElseIf XRJ8->RJ8_OPERAC =="2" //alteracao

						aDadosIMP := {}

						dbSelectArea("SPJ")
						dbSetOrder(1)
						If dbSeek(Alltrim(XRJ8->RJ8_CONTEU))

							dbSelectArea("SX3")
							dbSetOrder(1)
							dbSeek("SPJ")
							While ( !Eof() .And. (SX3->X3_ARQUIVO == "SPJ") )
								If SX3->X3_CONTEXT != "V"
									Aadd(aDadosIMP,{ SX3->X3_CAMPO })
								EndIf
								dbSelectArea("SX3")
								dbSkip()
							EndDo
							aHorasDia := {}
							fCarHPad("SPJ",Alltrim( XRJ8->RJ8_CONTEU ),@aHorasDia)
						Else
							GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,"Registro não Encontrado!")
							aAdd(aLog,"Erro na Alteração de Horário Padrão na Filial: "+ XRJ8->RJ8_FILPAR +"Motivo: Registro nao Localizado - Conteudo: " + XRJ8->RJ8_CONTEU)
						EndIf

						SPJ->( dbCloseArea() )

						cFil := cfilant
						cfilant := XRJ8->RJ8_FILPAR


							If Len(aHorasDia) > 0 .and. Len(aDadosIMP) > 0

								For j := 1 to Len(aHorasDia)

									DbSelectArea("SPJ")
									SPJ->(DbSetOrder(1))
									SPJ->(DbGoTop())

									If dbSeek(xFilial("SPJ") + aHorasDia[j][2] + aHorasDia[j][3] + aHorasDia[j][4] )

										RecLock( "SPJ", .F. )
										For k := 1 to Len(aDadosIMP)
											If AllTrim(aDadosIMP[k][1]) == "PJ_FILIAL"
												&(aDadosIMP[k][1]) := cfilant
											Else
												&(aDadosIMP[k][1]) := aHorasDia[j][k]
											Endif
										Next k
										SPJ->(MsUnlock())

									Endif
									SPJ->(DbCloseArea())

								Next j
							EndIf

							cfilant := cFil
							SPJ->( dbCloseArea() )
							//Chamo o programa para atualização da tabela RJ8
							GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,"")
							aAdd(aLog,"Alteração de Horário Padrão na filial: " + XRJ8->RJ8_FILPAR)

					ElseIf XRJ8->RJ8_OPERAC =="3" //exclusao

						cFil := cfilant
						cfilant := XRJ8->RJ8_FILPAR

						//-------------------------------------------------------
				  		//  Remove todas as sequências criadas para aquele turno
				  			cValInt := SPJ->( xFilial("SPJ") + SubStr( XRJ8->RJ8_CONTEU,nFilSize+1,3 )  )

							SPJ->(DbSeek(cValInt))
							SR6->( DbSeek(xFilial("SR6")+SPJ->PJ_TURNO))



							While SPJ->( DbSeek(cValInt))
								AAdd( aCab, { "R6_FILIAL", SR6->R6_FILIAL, NIL } )
								AAdd( aCab, { "R6_TURNO" , SR6->R6_TURNO , NIL } )

								AAdd( aCab, { "PJ_FILIAL", SPJ->PJ_FILIAL, NIL } )
								AAdd( aCab, { "PJ_TURNO" , SPJ->PJ_TURNO , NIL } )
								AAdd( aCab, { "PJ_SEMANA", SPJ->PJ_SEMANA, NIL } )

								While SPJ->( PJ_FILIAL + PJ_TURNO ) == cValInt
									aAdd( aItem, {} )
									nItem++

									AAdd( aItem[nItem],{ "PJ_FILIAL", SPJ->PJ_FILIAL, NIL } )
									AAdd( aItem[nItem],{ "PJ_TURNO" , SPJ->PJ_TURNO , NIL } )
									AAdd( aItem[nItem],{ "PJ_SEMANA", SPJ->PJ_SEMANA, NIL } )
									AAdd( aItem[nItem],{ "PJ_DIA"   , SPJ->PJ_DIA   , NIL } )
									AAdd( aItem[nItem],{ "PJ_TPDIA" , SPJ->PJ_TPDIA , NIL } )

									SPJ->( DbSkip() )
								End

								MsExecAuto( { |x, y, z| PONA080(x, y, z)}, aCab, aItem, 5 )

								If !lMsErroAuto
									GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,"")
									aAdd(aLog,"Exclusao de Turno de Trabalho cod: "+SPJ->PJ_TURNO+" na filial: " + XRJ8->RJ8_FILPAR)
									aCab := {} // Faço a limpeza do array
								Else
									DisarmTransaction()
									nErro :=""
									cLauto := getAutoGRLog()
									for i := 1 to len(cLauto)
										nErro += cLauto[i]+CHR(13)+CHR(10)
									next i
									GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,nErro)
									aAdd(aLog,"Motivo: " + nErro)
									aAdd(aLog,"Erro na Exclusao Turno de Trabalho" )
									aCab := {} // Faço a limpeza do array
								EndIf

						   End
					EndIf
				EndIf
				//----------------------------------------------------------------------------
				// Tabela CTT - Centro de Custo
				//----------------------------------------------------------------------------
				If XRJ8->RJ8_TABELA == "6"

					If XRJ8->RJ8_OPERAC =="1" //inclusao

						dbSelectArea("CTT")
						CTT->( dbSetOrder(1) )
						CTT->( dbGoTop() )

						If dbSeek(XRJ8->RJ8_CONTEU)

							aDadosIMP := GP936Rec("CTT")

							cFil := cfilant
							cfilant := fGetFil(XRJ8->RJ8_FILPAR)

							MSExecAuto({|x, y| CTBA030(x, y)},aDadosIMP, 3)

							If !lMsErroAuto
								GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,"")
								aAdd(aLog,"Inclusao Centro de Custo cod na filial: " + XRJ8->RJ8_FILPAR)
							Else
								nErro :=""
								cLauto := getAutoGRLog()
								for i := 1 to len(cLauto)
									nErro += cLauto[i]+CHR(13)+CHR(10)
								next i
								GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,nErro)
								aAdd(aLog,"Erro na Inclusão Centro de Custo" )
								aAdd(aLog,"Motivo: " + nErro)
							EndIf
							CTT->( dbCloseArea() )
						    cfilant := cFil
						Else
							GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,"Registro não Encontrado!")
							aAdd(aLog,"Erro na Inclusão do Centro de Custo na Filial: "+ XRJ8->RJ8_FILPAR +"Motivo: Registro nao Localizado - Conteudo: " + XRJ8->RJ8_CONTEU)
							CTT->( dbCloseArea() )
						EndIf
					ElseIf XRJ8->RJ8_OPERAC =="2" //Alteração

						dbSelectArea("CTT")
						CTT->( dbSetOrder(1) )
						CTT->( dbGoTop() )

						If dbSeek(XRJ8->RJ8_CONTEU)

							aDadosIMP := GP936Rec("CTT")

							cFil := cfilant
							cfilant := fGetFil(XRJ8->RJ8_FILPAR)

							MSExecAuto({|x, y| CTBA030(x, y)},aDadosIMP, 4)

							If !lMsErroAuto
								GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,"")
								aAdd(aLog,"Alteração de Centro de Custo cod na filial: " + XRJ8->RJ8_FILPAR)
							Else
								nErro :=""
								cLauto := getAutoGRLog()
								for i := 1 to len(cLauto)
									nErro += cLauto[i]+CHR(13)+CHR(10)
								next i
								GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,nErro)
								aAdd(aLog,"Erro na Inclusão Centro de Custo" )
								aAdd(aLog,"Motivo: " + nErro)
							EndIf
							CTT->( dbCloseArea() )
						    cfilant := cFil
						Else
							GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,"Registro não Encontrado!")
							aAdd(aLog,"Erro na Inclusão do Centro de Custo na Filial: "+ XRJ8->RJ8_FILPAR +"Motivo: Registro nao Localizado - Conteudo: " + XRJ8->RJ8_CONTEU)
							CTT->( dbCloseArea() )
					    EndIf
					ElseIf XRJ8->RJ8_OPERAC =="3" //Exclusão

						cFil := cfilant
						cfilant := fGetFil(XRJ8->RJ8_FILPAR)

						dbSelectArea("CTT")
						CTT->( dbSetOrder(1) )
						CTT->( dbGoTop() )

						If dbSeek(xFilial("CTT",XRJ8->RJ8_FILPAR)+SubStr(XRJ8->RJ8_CONTEU,nFilSize+1,9))

							aDadosIMP := GP936Rec("CTT")

							MSExecAuto({|x, y| CTBA030(x, y)},aDadosIMP, 5)

							If !lMsErroAuto
								GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,"")
								aAdd(aLog,"Exclusão de Centro de Custo cod na filial: " + XRJ8->RJ8_FILPAR)
							Else
								nErro :=""
								cLauto := getAutoGRLog()
								for i := 1 to len(cLauto)
									nErro += cLauto[i]+CHR(13)+CHR(10)
								next i
								GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,nErro)
								aAdd(aLog,"Erro na Inclusão Centro de Custo" )
								aAdd(aLog,"Motivo: " + nErro)
							EndIf
							CTT->( dbCloseArea() )
						    cfilant := cFil
						Else
							GP936At( XRJ8->RJ8_FILIAL, XRJ8->RJ8_FILPAR, XRJ8->RJ8_TABELA, XRJ8->RJ8_CONTEU, XRJ8->RJ8_OPERAC,XRJ8->RJ8_STATUS,"Registro não Encontrado!")
							aAdd(aLog,"Erro na Inclusão do Centro de Custo na Filial: "+ XRJ8->RJ8_FILPAR +"Motivo: Registro nao Localizado - Conteudo: " + XRJ8->RJ8_CONTEU)
							CTT->( dbCloseArea() )
					    EndIf
					EndIf
				  EndIf
			XRJ8->( dbSkip() )
			EndDo
			XRJ8->(dbCloseArea())
	Else
		Aadd(aLog, DtoC( Date() ) + " " + Time() + " - Sem dados para Incluir!" )

		XRJ8->(dbCloseArea())
	EndIf

Return(aLog)

/*/{Protheus.doc} GP936Rec
//TODO Descrição auto-gerada.
@author Samuel de Vincenzo
@since 05/06/2019
@version P12
@param cAlias, characters, descricao
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
static function GP936Rec(cAlias,ccont)
Local nI, nT 	:= len(DbSTruct())
Local fsize	 	:= FWSizeFilial()
Local aDados 	:= {}
Local aDSPJ	 	:= {}
Local aCpos	 	:= {}
Local cField 	:= 0
Local cCod	 	:= 0
Local cQueryPJ 	:= ""
Local nInd		:= 1


	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(cAlias)
	While (!EOF() .And. SX3->X3_ARQUIVO == cAlias )
		If X3Uso(X3_USADO) .And. SX3->X3_CONTEXT != "V"
			aADD(aCpos, SX3->X3_CAMPO)
		EndIf
	DbSkip()
	EndDo

	If cAlias =="SPJ"

		return (aCpos)

	Else

		For nI := 1 to Len(aCpos)

			If cAlias $ "CTT" .and. aCpos[nI] $ "CTT_SIGLA"
				Loop
			Else
				cField := (cAlias)->(FIELDPOS(aCpos[nI]))
				aadd(aDados,{ALLTRIM(aCpos[nI]),(cAlias)->(fieldget(cField)),NIL})
			EndIf
		Next nI

	EndIf



Return (aDados)

/*/{Protheus.doc} GP936At
//TODO Descrição auto-gerada.
@author Samuel de Vincenzo
@since 05/06/2019
@version undefined
@param cF, characters, Filial
@param cFP, characters, Filial Para
@param cT, characters, Qual a Tabela sendo processada( 1-SRV,2-SPA,3SR6,4-SRJ,5-SPJ,6-CTT )
@param cC, characters, Conteudo processado
@param cO, characters, Qual a operação processada ( 1-Inclusao,2-Alteracao,3-Exclusao )
@param cSt, characters, Status do registro
@param cCo, characters, Retorno do erro da rotina automatica para preenchimento na RJ8
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
static function GP936At(cF ,cFP, cT, cC, cO,cSt,cCo)
Local cAliasRJ8	:="RJ8"
local cMsg		:= ""

	dbSelectArea(cAliasRJ8)
	dbSetOrder(2)
	If (cAliasRJ8)->( MsSeek(cF+cFP+cT+cC+cO+cSt) )

		cMsg	:= (cAliasRJ8)->RJ8_MSGLOG

		If !Empty(cCo)

		  	Reclock( cAliasRJ8, .F. )
		  	( cAliasRJ8 )->RJ8_STATUS  := "2"
			If cO == "1"
				( cAliasRJ8 )->RJ8_MSGLOG  := cMsg + CHR(13)+CHR(10)+ DtoC(Date()) + " - " + TIME() + "- Erro na inclusao na Filial " + cFP + " - Motivo: " + cCo
			ElseIf cO == "2"
				( cAliasRJ8 )->RJ8_MSGLOG  := cMsg + CHR(13)+CHR(10)+ DtoC(Date()) + " - " + TIME() + "- Erro de Alteracao na Filial " + cFP + " - Motivo: " + cCo
			ElseIf cO == "3"
				( cAliasRJ8 )->RJ8_MSGLOG  := cMsg + CHR(13)+CHR(10)+ DtoC(Date()) + " - " + TIME() + "- Erro de Exclusão na Filial " + cFP + " - Motivo: " + cCo
			EndIf
			( cAliasRJ8 )->( MsUnlock() )

			(cAliasRJ8)->( dbCloseArea() )
		Else
			Reclock( cAliasRJ8, .F. )
			( cAliasRJ8 )->RJ8_STATUS  := "1"
			If cO == "1"
				( cAliasRJ8 )->RJ8_MSGLOG  := cMsg + CHR(13)+CHR(10)+ DtoC(Date()) + " - " + TIME() + "- Inclusão Efetuada com sucesso!"
			ElseIf cO == "2"
				( cAliasRJ8 )->RJ8_MSGLOG  := cMsg + CHR(13)+CHR(10)+ DtoC(Date()) + " - " + TIME() + "- Alteração Efetuada com sucesso!"
			ElseIf cO == "3"
				( cAliasRJ8 )->RJ8_MSGLOG  := cMsg + CHR(13)+CHR(10)+ DtoC(Date()) + " - " + TIME() + "- Exclusão Efetuada com sucesso!"
			EndIf
			( cAliasRJ8 )->( MsUnlock() )

			(cAliasRJ8)->( dbCloseArea() )
		Endif
	Endif
return

/*/{Protheus.doc} G936GeraCTT
//TODO Descrição auto-gerada.
@author Samuel de Vincenzo
@since 24/06/2019
@version 1.0
@return return, Retorna True
@param cttalias, characters, Alias da Tabela
@param cttchave, characters, Chave: Filial + Codigo
@param cttopc, characters, Tipo de ação na rotina: 3- inclusao, 4- alteracao e 5 - exclusao
@see (links_or_references)
/*/
Function G936GeraCTT(cttalias,cttchave,cttopc)
Local aAreaRJ8	  := {}
Local lRet		  := .T.
Local cStatRJ7    := .F.
Local nHoraInicio := 0

nHoraInicio = Seconds()
	//*************************************************************************************
	//SE NÃO FOR ROTINA AUTOMATICA, ENVIO PARA A RJ8 PARA INCLUSÃO EM OUTRAS FILIAIS
	//*************************************************************************************
	cChave:= xFilial("RJ7")+"6"+cFilAnt
	cStatRJ7 := fVldRJ7(1,cChave)


	 If cStatRJ7
		 Begin Transaction

		//Alimentando a tabela
			 Reclock( "RJ8", .T. )
			 RJ8->RJ8_FILIAL  := xFilial( "RJ8" )
			 RJ8->RJ8_FILPAR  := ""
		     RJ8->RJ8_TABELA  := "6"
			 RJ8->RJ8_CONTEU  := cttchave
			 RJ8->RJ8_DATA    := Date()
			 RJ8->RJ8_HORA    := SecsToTime(nHoraInicio)
			 RJ8->RJ8_OPERAC  := iif(cttopc==3,"1",iif(cttopc==4,"2","3"))
			 RJ8->RJ8_USUARI  := UsrRetName(RetCodUsr())
			 RJ8->RJ8_STATUS  := "0"
			 RJ8->RJ8_ESOCIA  := "1"
			 RJ8->RJ8_MSGLOG  := iif(cttopc==3,OemToAnsi(STR0054),iif(cttopc==4,OemToAnsi(STR0055),OemToAnsi(STR0056)))// ### "INCLUSAO DE CENTRO DE CUSTO" ### "ALTERAÇÃO DE CENTRO DE CUSTO" ### "EXCLUSÃO DE CENTRO DE CUSTO"
			 RJ8->( MsUnlock() )
			 RJ8->(DbCommit())
		End Transaction
	Endif



Return lRet


Function fCarHPad(cAlias,cconte,aHorasDia)
Local aArea		:= GetArea()
Local aCposSPJ	:= {}
Local nX		:= 0
Local nInd		:= 1

Default aHorasDia := {}

	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(cAlias)
	While ( !Eof() .And. (SX3->X3_ARQUIVO == cAlias) )
		If SX3->X3_CONTEXT != "V"
			Aadd(aCposSPJ,{ SX3->X3_CAMPO })
		EndIf
		dbSelectArea("SX3")
		dbSkip()
	EndDo

	If	Len(aCposSPJ) > 0

		dbselectArea(cAlias)
		dbSetOrder(1)
		dbSeek(cconte)

		While ! EOF() .and. cconte = SPJ->PJ_FILIAL+SPJ->PJ_TURNO+SPJ->PJ_SEMANA
			aAdd(aHorasDia,{})

			For nX := 1 to Len(aCposSPJ)

				aAdd(aHorasDia[nInd],&(aCposSPJ[nX][1]))

			Next nX

			nInd++

		dbSkip()

		EndDo
	EndIf

Return (aHorasDia)

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ErroForm 		³Autor³Leandro Drumond     ³ Data ³15/08/2015³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Verifica os Erros na Execucao da Formula                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL                                                  	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³Generico                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Static Function ErroForm(	oErr			,;	//01 -> Objeto oErr
							lNotErro		,;	//02 -> Se Ocorreu Erro ( Retorno Por Referencia )
							aLog			;
						)

Local aErrorStack
Local cMsgHelp	:= ""

DEFAULT lNotErro	:= .T.

If !( lNotErro := !( oErr:GenCode > 0 ) )
	cMsgHelp += "Error Description: "
	cMsgHelp += oErr:Description
	aAdd( aLog, cMsgHelp )
	aErrorStack	:= Str2Arr( oErr:ErrorStack , Chr( 10 ) )
	aEval( aErrorStack , { |X| aAdd(aLog, X) } )
	aEval( aErrorStack , { |cStackError| RotAddErr( cStackError ) } )
EndIf

Break

Return( NIL )

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³RotAddErr	  ³Autor ³Leandro Drumond      ³ Data ³15/08/2015³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Adiciona String de Erro aa __aRotErr						 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL     													 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                         					 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³Generico 													 ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Static Function RotAddErr( cErr )

Local aErr

Local nErr		:= Len( cErr )

DEFAULT __aRotErr := {}

IF ( nErr > 220 )
	aErr := {}
	While ( nErr > 220 )
		aAdd( aErr , SubStr( cErr , 1 , 220 ) )
		cErr := SubStr( cErr , 221 )
		IF ( ( nErr := Len( cErr ) ) < 220 )
			aAdd( aErr , cErr )
			Exit
		EndIF
	End While
	aEval( aErr , { |cErr| RotAddErr( cErr ) } )
ElseIF ( aScan( __aRotErr , { |x| x == cErr } ) == 0 )
	aAdd( __aRotErr , cErr )
EndIF

Return( NIL )


/*/{Protheus.doc} fVldRJ7
//TODO Valida se existe a Filial na Tabela RJ7.
@author Samuel de Vincenzo
@since 26/08/2019
@version V1.0
@return return, Retorna True se existir
@param nOrdem, numeric, Numero da Ordem do Indice para pesquisa
@param cChave, characters, Chave de pesquisa: Filial+CodTabela+FilialCopia
@example
(examples)
@see (links_or_references)
/*/
Function fVldRJ7(nOrdem,cChave)
Local aArea 	:= GetArea()
Local cFilEmp   := cFilAnt
Local lOk		:= .F.
Local nLenChave := 0

Default nOrdem  := 2

DbSelectArea("RJ7")
RJ7->( dbSetOrder(nOrdem) )

cIndex 		:= RJ7->( IndexKey(nOrdem) )
nLenChave	:= Len(cChave)

If RJ7->( dbSeek(cChave) )
	lOk := .T.
EndIf

 RestArea(aArea)

Return lOk

Function GetRegRJ8(nOrdem, cChave, cStatRJ8, cOperRJ8)
Local aArea		:= GetArea()
Local cIndex	:= ""
Local nLenChave	:= 0

Default nOrdem	:= 2
Default cChave	:= ""
Default cStatRJ8:= "-1"
Default cOperRJ8:= "1"

dbSelectArea("RJ8")
RJE->( dbSetOrder(nOrdem) )

cIndex 		:= RJE->( IndexKey(nOrdem) )
nLenChave	:= Len(cChave)

If RJ8->( dbSeek(cChave) )
	While RJ8->( !EoF() ) .And. SubStr( &(cIndex), 1, nLenChave ) == cChave
		cStatRJ8 := RJ8->RJ8_STATUS
		cOperRJ8 := RJ8->RJ8_OPERAC
		RJ8->( dbSkip() )
	End
EndIf

RestArea(aArea)

Return

/*/{Protheus.doc} fGetFil
Valida a filial que será utilizada como cFilAnt devido aos modos de compartilhamento das tabelas
@author allyson.mesashi
@since 13/05/2020
@version V1.0
@return cFilSM0, Retorna o código da folial
@param cFilPRJ8, characters, Código da 'Filial Para' gravado na RJ8
/*/
Static Function fGetFil( cFilPRJ8 )

Local aAreaSM0		:= SM0->( GetArea() )
Local cFilSM0		:= ""

Default cFilPRJ8	:= Space(FwGetTamfilial)

SM0->( dbSetOrder(1) )//M0_CODIGO+M0_CODFOL
If SM0->( dbSeek( cEmpAnt + cFilPRJ8 ) )
	cFilSM0	:= cFilPRJ8
ElseIf SM0->( dbSeek( cEmpAnt + AllTrim(cFilPRJ8) ) )
	cFilSM0	:= SubStr( SM0->M0_CODFIL, 1, FwGetTamFilial )
EndIf

RestArea(aAreaSM0)

Return cFilSM0

/*/{Protheus.doc}
Pos-validacao do Cadastro
@type      	Static Function
@author   	Allyson Mesashi
@since		18/05/2020
@version	1.0
@param		oModel, object, Modelo a ser validado
@return		lRetorno
/*/
Static Function Gp936CPosVal( oModel )

Local cChave		:= ""
Local lRetorno      := .T.
Local nCont			:= 0
Local nOperation	:= oModel:GetOperation()
Local oGrid			:= Nil

If nOperation == MODEL_OPERATION_INSERT .And. RJ7->( dbSeek( xFilial("RJ7") + oModel:GetValue('FORMCAB','RJ7_TABELA') ) )
	Help( " ", 1, OemToAnsi(STR0057),, OemToAnsi(STR0058), 2 , 0 )//"Atenção"##"Já existe cadastro para a tabela informada"
	lRetorno := .F.
ElseIf nOperation == MODEL_OPERATION_UPDATE .And. RJ7->RJ7_TABELA <> oModel:GetValue('FORMCAB','RJ7_TABELA') .And. RJ7->( dbSeek( xFilial("RJ7") + oModel:GetValue('FORMCAB','RJ7_TABELA') ) )
	Help( " ", 1, OemToAnsi(STR0057),, OemToAnsi(STR0059), 2 , 0 )//"Atenção"##"Não é permitido alterar a tabela pois já existe um outro cadastro com esse tipo"
	lRetorno := .F.
EndIf

Return lRetorno
