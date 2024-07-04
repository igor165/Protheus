#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "TMSAI88.CH"

#DEFINE NTAMARQ  120
#DEFINE DEFALIAS {"DN2","DN3","DNB"}
#DEFINE NOMEARQ  "LayColEnt.Lay"

/*{Protheus.doc} TMSAI88
Exporta/Importa os layouts de integração com coleta/entrega
@type Function
@author Valdemar Roberto Mognon
@since 27/07/2022
@version P12
@example TMSAI88()
(examples)
@see (links_or_references)
*/
Function TMSAI88(nAcao)
Local aVetLay   := {}
Local cDir      := Space(NTAMARQ)
Local cCodFon   := Space(TamSX3("DN6_CODIGO")[1])

Private cAcao := ""

Default nAcao := 0	//-- 1=Exportação # 2=Importação

	If nAcao == 1	//-- Exportação
		cAcao := STR0002
	Else	//-- Importação
		cAcao := STR0003
	EndIf

	If TMSAI88Wiz(nAcao,@cDir,@cCodFon)
		If nAcao == 1	//-- Exportação
			FwMsgRun(,{|| aVetLay := TMSAI88Sel(cCodFon)},STR0007,STR0009)	//-- Processando # Selecionando registros
			FwMsgRun(,{|| TMSAI88Grv(AllTrim(cDir),Aclone(aVetLay))},STR0007,STR0008)	//-- Processando # Gravando arquivo
		Else	//-- Importação
			FwMsgRun(,{|| TMSAI88Exc(cCodFon)},STR0007,STR0011)	//-- Processando # Excluindo registros
			FwMsgRun(,{|| TMSAI88Imp(AllTrim(cDir),cCodFon)},STR0007,STR0012)	//-- Processando # Importando layouts
		EndIf
	EndIf

Return

/*{Protheus.doc} TMSAI88Sel
Seleciona registros para a exportação dos layouts de integração com coleta/entrega
@type Function
@author Valdemar Roberto Mognon
@since 27/07/2022
@version P12
@example TMSAI88Sel()
(examples)
@see (links_or_references)
*/
Function TMSAI88Sel(cCodFon)
Local aLayout   := {}
Local aAliasLay := DEFALIAS
Local aStruc    := {}
Local aRegistro := {}
Local nAlias    := 0
Local aAreas    := {}

	AEval(aAliasLay,{|xAlias| AAdd(aAreas, (xAlias)->(GetArea()) ) })
	AAdd(aAreas, GetArea() )

	For nAlias := 1 To Len(aAliasLay)
		AAdd(aLayout,{aAliasLay[nAlias],{},{}})
		aStruc := (aAliasLay[nAlias])->(DbStruct())
		AEval(aStruc,{|x| AAdd(aLayout[nAlias][2], X[1] ) })
		(aAliasLay[nAlias])->(DbSetOrder(1))
		(aAliasLay[nAlias])->(MsSeek(xFilial(aAliasLay[nAlias])+cCodFon))
		Do While !(aAliasLay[nAlias])->(Eof()) .And. (aAliasLay[nAlias])->(FieldGet(FieldPos(aAliasLay[nAlias]+"_FILIAL"))+FieldGet(FieldPos(aAliasLay[nAlias]+"_CODFON"))) == xFilial(aAliasLay[nAlias])+cCodFon
			aRegistro := {}
			(aAliasLay[nAlias])->(AEval(aLayout[nAlias][2], {|xCampo| AAdd(aRegistro, FieldGet(FieldPos(xCampo)) ) } ))
			AAdd(aLayout[nAlias][3], AClone(aRegistro) )
			(aAliasLay[nAlias])->(DbSkip())
		EndDo
	Next

	AEval(aAreas, {|x,y| RestArea(x), FwFreeArray(x)} )
	FwFreeArray(aAreas)
	FwFreeArray(aAliasLay)
	FwFreeArray(aStruc)
	FwFreeArray(aRegistro)
	
Return aClone(aLayout)

/*{Protheus.doc} TMSAI88Grv
Grava vetor com os layouts
@type Function
@author Valdemar Roberto Mognon
@since 28/07/2022
@version P12
@example TMSAI88Grv()
(examples)
@see (links_or_references)
*/
Function TMSAI88Grv(cDirArq,aVetGrv)

	Default cDirArq := ""
	Default aVetGrv := {}

	If !Empty(aVetGrv)
		__VSave(aVetGrv,cDirArq + NOMEARQ)
	EndIf

Return

/*{Protheus.doc} TMSAI88Exc
Exclui registros do mesmo código de fonte
@type Function
@author Valdemar Roberto Mognon
@since 29/07/2022
@version P12
@example TMSAI88Exc()
(examples)
@see (links_or_references)
*/
Function TMSAI88Exc(cCodFon)
Local aArea  := GetArea()
Local aAlias := DEFALIAS
Local nAlias := 0

Default cCodFon := ""

	For nAlias := 1 To Len(aAlias)
		(aAlias[nAlias])->(DbSetOrder(1))
		Do While (aAlias[nAlias])->(DbSeek(xFilial(aAlias[nAlias])+cCodFon))
			RecLock(aAlias[nAlias],.F.)
			(aAlias[nAlias])->(DbDelete())
			MsUnlock()
		EndDo
	Next

	RestArea(aArea)
	FwFreeArray(aArea)
	FwFreeArray(aAlias)

Return

/*{Protheus.doc} TMSAI88Imp
Executa a importação dos layouts de integração com coleta/entrega
@type Function
@author Valdemar Roberto Mognon
@since 27/07/2022
@version P12
@example TMSAI88Imp()
(examples)
@see (links_or_references)
*/
Function TMSAI88Imp(cDirArq,cCodFon)

Local aArea   := GetArea()
Local aVetImp := {}
Local nAlias  := 0
Local nReg    := 0
Local nCampo  := 0

	If !Empty(cDirArq) .And. !Empty(cCodFon)
		aVetImp := __VRestore(cDirArq + NOMEARQ)
		For nAlias := 1 To Len(aVetImp)
			For nReg := 1 To Len(aVetImp[nAlias][3])
				RecLock(aVetImp[nAlias][1],.T.)
				For nCampo := 1 To Len(aVetImp[nAlias][2])
					If "_FILIAL" $ aVetImp[nAlias][2][nCampo]
						(aVetImp[nAlias][1])->( FieldPut( FieldPos( aVetImp[nAlias][1]+"_FILIAL" ), xFilial(aVetImp[nAlias][1]) ) )
					ElseIf "_CODFON" $ aVetImp[nAlias][2][nCampo]
						(aVetImp[nAlias][1])->( FieldPut( FieldPos( aVetImp[nAlias][1]+"_CODFON" ), cCodFon ) )
					Else
						(aVetImp[nAlias][1])->( FieldPut( FieldPos( aVetImp[nAlias][2][nCampo] ), aVetImp[nAlias][3][nReg][nCampo] ) )
					EndIf
				Next
				MsUnLock()
			Next
		Next
	EndIf

	RestArea(aArea)
	FwFreeArray(aArea)
	FwFreeArray(aVetImp)

Return

/*{Protheus.doc} TMSAI88A
Acionamento do fonte de exportação dos layouts de integração com coleta/entrega
@type Function
@author Valdemar Roberto Mognon
@since 27/07/2022
@version P12
@example TMSAI88A()
(examples)
@see (links_or_references)
*/
Function TMSAI88A()

TMSAI88(1)

Return

/*{Protheus.doc} TMSAI88B
Acionamento do fonte de importação dos layouts de integração com coleta/entrega
@type Function
@author Valdemar Roberto Mognon
@since 27/07/2022
@version P12
@example TMSAI88B()
(examples)
@see (links_or_references)
*/
Function TMSAI88B()

TMSAI88(2)

Return

/*{Protheus.doc} TMSAI88Vld
Valida a existência do arquivo na pasta e layouts com o código fonte
@type Function
@author Valdemar Roberto Mognon
@since 28/07/2022
@version P12
@example TMSAI88Vld()
(examples)
@see (links_or_references)
*/
Function TMSAI88Vld(nAcao,cDirArq,cCodFon,lYesNo)
Local lRet    := .T.
Local aAreas  := {DN2->(GetArea()),GetArea()}
Local cPasta  := ""

Default nAcao   := 0
Default cDirArq := ""
Default cCodFon := ""
Default lYesNo  := .T.

	cDirArq := AllTrim(cDirArq)
	cDirArq := cDirArq + Iif(Right(cDirArq,1)=="\","","\")
	cPasta  := Left(cDirArq,Len(cDirArq)-1)
	cDirArq := PadR(cDirArq,NTAMARQ)

	If nAcao == 1 .Or. nAcao == 2
		If !File(cPasta) //-- Verifica se a pasta existe
			Help("",1,"TMSAI8803")	//-- Pasta inexistente # Selecione uma pasta que exista
			lRet := .F.
		ElseIf nAcao == 1	//-- Verifica se o arquivo já existe
			If File(cPasta + "\" + NOMEARQ)
				If lYesNo .And. !MsgNoYes(STR0004 + NOMEARQ + STR0005 + STR0006)	//-- Arquivo # NOMEARQ # já existe na pasta e será substituido. # Deseja continuar?
					lRet := .F.
				EndIf
			EndIf
		ElseIf nAcao == 2	//-- Verifica se o arquivo não existe
			If !File(cPasta + "\" + NOMEARQ)
				Help("",1,"TMSAI8802")	//-- Arquivo LayColEnt.Lay não localizado nesta pasta. # Selecione a pasta que contenha o arquivo LayColEnt.Lay.
				lRet := .F.
			EndIf
		EndIf
	ElseIf nAcao == 3	//-- Verifica se existem registros com o código fonte selecionado
		DN2->(DbSetOrder(1))
		If DN2->(DbSeek(xFilial("DN2") + cCodFon))
			If !MsgNoYes(STR0010 + cCodFon + ". " + STR0006)	//-- Existem layouts com o código fonte # cCodFon. # Deseja continuar?
				lRet := .F.
			EndIf
		EndIf
	EndIf

	AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} TMSAI88
Função Wizard de Entrada
@author Carlos Alberto Gomes Junior
@since 02/08/2022
*/
Function TMSAI88Wiz(nAcao,cDir,cCodFon)

Local oWizard, oPanel
Local cText   := ""
Local lRet    := .F.

	cText += STR0013 + cAcao
	cText += STR0014 + CRLF
	cText += STR0015 + CRLF + CRLF + CRLF
	cText += STR0016

	//Inicialização objeto Wizard
	DEFINE WIZARD oWizard TITLE cAcao + STR0017 ;
		HEADER STR0018 ;
		MESSAGE "TMSAI80" TEXT cText ;
		NEXT {|| .T. } FINISH {|| .T. } PANEL

	//Segundo painel do Wizard (após o primeiro avançar)
	CREATE PANEL oWizard HEADER STR0018 ;
		MESSAGE "TMSAI80" ;
		BACK {|| .T. } NEXT {|| .T. } FINISH {|| ( lRet := TMSAI88Vld(nAcao,@cDir) .And. ExistCpo("DN6",cCodFon) .And. Iif(nAcao == 1,.T.,TMSAI88Vld(3,,cCodFon)) ) } PANEL

	//Criação dos dados dentro do painel
	oPanel := oWizard:GetPanel(2)
	TSay():New( 21,02, {|| STR0019},oPanel,,,,,,.T.)
	oGet1 := TGet():New( 31, 02, bSETGET(cDir),oPanel,180,10,, {|| TMSAI88Vld(nAcao,@cDir,,.F.) },,,, .T.,, .T.,, .T., {|| .T. }, .F., .F.,, .F., .F., "", cDir ,,,,.T.)
	TBtnBmp2():New( 62, 370, 25, 25, "BMPVISUAL", , , , {|| cDir := cGetFile("Layout|*.Lay|" + STR0020 + "|*.*|",STR0021,0,STR0022,.F., GETF_LOCALHARD+GETF_ONLYSERVER+GETF_RETDIRECTORY)} , oPanel, STR0023, {|| .T. }, )
	oGet2 := TSay():New( 51, 02, {|| STR0024},oPanel,,,,,,.T.)
	TGet():New( 61 ,02, bSETGET(cCodFon),oPanel,40,10,, {|| ExistCpo("DN6",cCodFon) },,,, .T.,, .T.,, .T., {|| .T. }, .F., .F.,, .F., .F., "DN6", cCodFon ,,,,.T.)

	ACTIVATE WIZARD oWizard CENTER

Return lRet

