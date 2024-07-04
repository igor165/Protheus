#INCLUDE "loca075.ch"
#INCLUDE "PROTHEUS.CH"
#Include "topconn.ch"
#Include "ap5mail.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOCA075   บAutor  ณFrank Z Fuga        บ Data ณ  30/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Integracao / processos antigo INTPROG.PRW                  บฑฑ
ฑฑบ          ณ produtizado em 25/11/21                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Function LOCA075   
Private cCadastro := STR0001 		// "Integra็ใo / Processos "
Private aRotina   := fMontaRot()	// Monta o aRotina
Private cDelFunc  := ".T." 			// Validacao para a exclusao. Pode-se utilizar ExecBlock

	dbSelectArea("FQ5") 
	dbSetOrder(1)
	MBROWSE( 6, 1,22,75,"FQ5")

Return

//-----------------------------------------------------------------------------
Static Function fMontaRot()  //Monta o aRotina
Local aRotina:={}

	AAdd(aRotina,{STR0002         	,"AxPesqui"  	,0,1}) //"Pesquisar"
	AAdd(aRotina,{STR0003        	,"LOCA075001" 	,0,6}) //"Visualizar"
	AAdd(aRotina,{STR0004       	,"LOCA075002" 	,0,4}) //"Programacao"
	AAdd(aRotina,{STR0005 			,"LOCA075003" 	,0,4}) //Inclui matricula de funcionario    //"Incluir Funcionario"
	//AAdd(aRotina,{"Gerar certifado"     ,"U_GERACERT",0,4}) //Gera certificado de treinamento. Incluํdo por Cau๊ Poltronieri em 02/02/2016.
	//AAdd(aRotina,{STR0006,"LOCA075006" ,0,4}) //Controle de Treinados //"Controle de Treinados"

Return(aRotina)

//-----------------------------------------------------------------------------
Function  LOCA075001 //VisuInt() 
	fManu(2)
Return

//-----------------------------------------------------------------------------
Static Function fManu(pOpc)

Local cTitJan:=STR0007 //"Integracao de Processos"
Local aAreaZLG:=GetArea()
Local nPos

Private nOpc:=pOpc
Private oArial12N1		:=TFont():New("Arial",12,16,,.T.,,,,.T.,.F.)
Private oArial12N2		:=TFont():New("Arial",12,16,,.T.,,,,.T.,.F.)
Private oDlgFro, oDlgEqu, oDlgMO, oFolderFro,oObra, oProj, oAs
Private aHeader			:={}
Private aCols			:={}
Private aMarcados		:={}
Private aDeleta			:={}
Private _aButton		:={}
Private aButtons		:={}
Private nFolderInt		:= 0
Private nFolderProc		:= 0
Private oFont1			:= oArial12N1  //Say
Private oFont2			:= oArial12N2  //Get
Private aObjects  		:= {}
Private aInfo     		:= {}
Private aPosGet   		:= {}
Private aPosObj   		:= {}
Private cKeyP			:= ""
Private	cKeyS			:= ""
private cTpAS			:= ""
Private aColsFullInt   	:= {}
Private aColsFullProc   := {}
Private aGRV 			:= {}
Private aOnde 			:= {}
Private aIntOrig 		:= {}

	aSizeAut 	 			:= MsAdvSize()

	FQ5->(DbSelectArea("FQ5"))
	FQ5->(DbSetOrder(1))
	RegToMemory("FQ5",.T.)

	If oMainWnd:nClientWidth > 800
		AAdd( aObjects, {  100, 008, .T., .T. } )  //Enchoice
		AAdd( aObjects, {  100, 092, .T., .T. } )  //MsGetDados
	Else
		AAdd( aObjects, {  100, 030, .T., .T. } )  //Enchoice
		AAdd( aObjects, {  100, 070, .T., .T. } )  //MsGetDados
	EndIf

	aInfo 	:= {aSizeAut[1],aSizeAut[2],aSizeAut[3],aSizeAut[4],3,3}
	aPosObj := MsObjSize( aInfo, aObjects, .T. , .F. )
	aPosGet := MsObjGetPos((aSizeAut[3]-aSizeAut[1]),315,{{004,024,240,270}} )

	nLin1:=aPosObj[2,1]
	nCol1:=aPosObj[2,2]
	nLin2:=aPosObj[2,4]-aPosObj[2,2]  //Largura
	nCol2:=aPosObj[2,3]-aPosObj[2,1]  //Altura

	aPages :={}
	aTitles:={}
	AAdd(aTitles,STR0008	) //"Integracao "
	nFolderInt	:=Len(aTitles)

	AAdd(aTitles,STR0009			) //"Processo"
	nFolderProc	:=Len(aTitles)

	DbSelectArea("FPU")
	//DbSetOrder(2)
	FPU->(dbclearFilter())
	FPU->(DBSETFILter({|| alltrim(FPU->FPU_CODCLI) == alltrim(FQ5->FQ5_CODCLI) .and. alltrim(FPU->FPU_LOJCLI) == alltrim(FQ5->FQ5_LOJA)},"alltrim(FPU->FPU_CODCLI) == alltrim(FQ5->FQ5_CODCLI) .and. alltrim(FPU->FPU_LOJCLI) == alltrim(FQ5->FQ5_LOJA)"))
	FPU->(dbGotop())


	//If !DbSeek(xFilial("ZM0")+FQ5->FQ5_AS+FQ5->FQ5_OBRA+FQ5->FQ5_SOT)
	IF EMPTY(FPU->FPU_CODCLI)
	DbSelectArea("FPU")
	DbSetOrder(2)
		If !DbSeek(xFilial("FPU")+FQ5->FQ5_AS+FQ5->FQ5_OBRA+FQ5->FQ5_SOT)
			MsgAlert(STR0010,STR0011) //"Nใo foi encontrado registro para este Projeto/Obra/AS. Processo de integra็ใo abortado"###"Aten็ใo!"
			//MsgAlert("Nใo foi encontrado registro para este Cliente/Obra. Processo de integra็ใo abortado","Aten็ใo!")
			Return
		Endif
	endif

	DEFINE MSDIALOG oDlg FROM aSizeAut[7],0           TO aSizeAut[6],aSizeAut[5] TITLE OemToAnsi(cTitJan) Of oMainWnd PIXEL

	oFolder:=TFolder():New(nLin1+45 ,nCol1 ,aTitles  ,aPages     ,oDlg   ,         ,          ,          ,.T.       ,.F.        ,nLin2 ,nCol2-50   ,      )

	For nPos:=1 to Len(aTitles)
		oFolder:aDialogs[nPos]:oFont:=oDlg:oFont
	Next

	oFolder:bSetOption:={|nIndo|ZM1MUDA(nIndo,oFolder:nOption,@oDlg,@oFolder)}

	nLin1:=aPosObj[1,1]
	nCol1:=aPosObj[1,2]
	nLin2:=aPosObj[1,3]
	nCol2:=aPosObj[1,4]

	@ nLin1,nCol1 to nLin2+45,nCol2 Of oDlg PIXEL

	cProj:= FQ5->FQ5_SOT
	CoBRA:= FQ5->FQ5_OBRA
	CAS:= FQ5->FQ5_AS

	@ nLin1+15,nCol1+005 Say OemtoAnsi(STR0012) Size 055,8   Of oDlg PIXEL COLOR CLR_BLUE FONT oFont1 //"Projeto :"
	@ nLin1+14,nCol1+055 MsGet oProj  Var cProj  Size 400,8 WHEN .f. Of oDlg PIXEL COLOR CLR_BLUE FONT oFont2
	@ nLin1+30,nCol1+005 Say OemtoAnsi(STR0013) Size 055,8   Of oDlg PIXEL COLOR CLR_BLUE FONT oFont1 //"Obra :"
	@ nLin1+29,nCol1+055 MsGet oObra  Var cObra  Size 400,8 WHEN .f. Of oDlg PIXEL COLOR CLR_BLUE FONT oFont2
	@ nLin1+45,nCol1+005 Say OemtoAnsi(STR0014) Size 055,8   Of oDlg PIXEL COLOR CLR_BLUE FONT oFont1 //"AS :"
	@ nLin1+44,nCol1+055 MsGet oAs  Var cAs  Size 400,8 WHEN .f. Of oDlg PIXEL COLOR CLR_BLUE FONT oFont2

	//----- Folder para Integracao
	If nFolderInt > 0
		nLin1:=002
		nCol1:=003
		nLin2:=aPosObj[2,3]-aPosObj[2,1]  //Altura
		nCol2:=aPosObj[2,4]
		fFolderInt(nFolderInt,nLin1,nCol1,nLin2,nCol2)
	endif

	//---- Folder para Processo
	If nFolderProc > 0
		nLin1:=002
		nCol1:=003
		nLin2:=aPosObj[2,3]-aPosObj[2,1]  //Altura
		nCol2:=aPosObj[2,4]
		fFolderProc(nFolderProc,nLin1,nCol1,nLin2,nCol2)
	endif

	Activate MsDialog oDlg CENTERED On Init EnchoiceBar(oDlg,{||fSalvar(oDlg)},{||fSair(oDlg)},,aButtons)

	RestArea(aAreaZLG)

Return

//-----------------------------------------------------------------------------
STATIC FUNCTION fFolderInt(nFolder,nLin,nCol1,nLin2,nCol2)
Local aCamposSim	:= {}
Local nc, nh
Local nStyle := iif(nOpc==2, 0, GD_INSERT + GD_UPDATE + GD_DELETE)

	aCols2:={}
	aHeader2:= {}

	cAlias   :="FPU"

	DBSELECTAREA(cAlias)
	(cAlias)->(dbgotop())

	cFQ5_AS:=PADR(FQ5->FQ5_AS,LEN(FPU_AS))
	cFQ5_OBRA:=PADR(FQ5->FQ5_OBRA,LEN(FPU_OBRA))
	cFQ5_SOT:=PADR(FQ5->FQ5_SOT,LEN(FPU_PROJ))
	cFQ5_CLI:=PADR(FQ5->FQ5_CODCLI,LEN(FPU_CODCLI))
	cFQ5_LOJA:=PADR(FQ5->FQ5_LOJA,LEN(FPU_LOJCLI))

	nIndice	 := 2
	cChave   :=xFILIAL(cAlias)+cFQ5_AS+cFQ5_OBRA+cFQ5_SOT
	cCondicao:=""
	cFiltro:="ALLTRIM(FPU->FPU_CODCLI)== ALLTRIM(cFQ5_CLI) .AND. ALLTRIM(FPU->FPU_LOJCLI)== ALLTRIM(cFQ5_LOJA) .OR. ALLTRIM(FPU->FPU_AS)== ALLTRIM(cFQ5_AS) .AND. ALLTRIM(FPU->FPU_OBRA)== ALLTRIM(cFQ5_OBRA) .AND. ALLTRIM(FPU->FPU_PROJ)== ALLTRIM(cFQ5_SOT)" //"ALLTRIM(ZM0->ZM0_AS)== ALLTRIM(cFQ5_AS) .AND. ALLTRIM(ZM0->ZM0_OBRA)== ALLTRIM(cFQ5_OBRA) .AND. ALLTRIM(ZM0->ZM0_PROJ)== ALLTRIM(cFQ5_SOT)"

	AAdd(aCamposSim,{"FPU_MAT"   	,""})
	AAdd(aCamposSim,{"FPU_NOME"   	,""})
	AAdd(aCamposSim,{"FPU_DTINI"   	,""})
	AAdd(aCamposSim,{"FPU_DTFIN"   	,""})
	AAdd(aCamposSim,{"FPU_QTDDIA"   	,""})
	AAdd(aCamposSim,{"FPU_DTLIM"   	,""})
	AAdd(aCamposSim,{"FPU_VALID"   	,""})
	AAdd(aCamposSim,{"FPU_DTVALI"   	,""})
	AAdd(aCamposSim,{"FPU_CRACHA"   	,""})
	AAdd(aCamposSim,{"FPU_DESIST"   	,""})
	AAdd(aCamposSim,{"FPU_OBS"   	,""})
	AAdd(aCamposSim,{"FPU_CONTRO"   	,""})
	AAdd(aCamposSim,{"FPU_CODCLI"   	,"V"})
	AAdd(aCamposSim,{"FPU_LOJCLI"   	,"V"})

	aHeader:=fHeader(aCamposSim)
	aCols:=fCols(aHeader,cAlias,nIndice,cChave,cCondicao,cFiltro)

	for nC:=1 to len(aCols)
		aadd(aCols2, aCols[nC])
	next

	for nH:=1 to len(aHeader)
		aadd(aHeader2, aHeader[nh])
	next

	oDlgFro:=MsNewGetDados():New(nLin1,nCol1,nLin2,nCol2 ,nStyle,"LINOK" , , , , ,9999,,,.t. ,oFolder:aDialogs[nFolder],aHeader2,aCols2)
	oDlgFro:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT
	oDlgFro:oBrowse:bChange:={||MudaZM0(nFolder)}
	oDlgFro:Refresh()

Return

//-----------------------------------------------------------------------------
STATIC FUNCTION fFolderProc(nFolder,nLin1,nCol1,nLin2,nCol2)
Local aCamposSim := {}
Local nStyle := iif(nOpc==2, 0, GD_INSERT + GD_UPDATE + GD_DELETE)
Local cChave,cCondicao,nIndice,cFiltro,cMat //, cDesist
Local nc, nh

	aCols2:={}
	aHeader2:= {}

	cAlias   :="FPV"

	cFQ5_AS:=PADR(FQ5->FQ5_AS,LEN(FPV->FPV_AS))
	cFQ5_OBRA:=PADR(FQ5->FQ5_OBRA,LEN(FPV->FPV_OBRA))
	cFQ5_SOT:=PADR(FQ5->FQ5_SOT,LEN(FPV->FPV_PROJ))
	cMAT:= FPU->FPU_MAT
	cNome := FPU->FPU_NOME

	If !Empty(cMAT)
		cChave   :=xFILIAL(cAlias)+cFQ5_AS+cFQ5_OBRA+cFQ5_SOT+cMat
	Else
		cChave   :=xFILIAL(cAlias)+cFQ5_AS+cFQ5_OBRA+cFQ5_SOT
	End
	nIndice  :=3  //filial+aS+Obra+Projeto+Funcionario
	cFiltro  :=""

	AAdd(aCamposSim,{"FPV_MAT"   	,""})
	AAdd(aCamposSim,{"FPV_CODPRO"   	,""})
	AAdd(aCamposSim,{"FPV_DESCRI"   	,""})
	AAdd(aCamposSim,{"FPV_OBS   "   	,""})
	AAdd(aCamposSim,{"FPV_DTPREV"   	,""})
	AAdd(aCamposSim,{"FPV_DTREAL"   	,""})
	AAdd(aCamposSim,{"FPV_CONTRO"   	,""})
	AAdd(aCamposSim,{"FPV_DATVLD"   	,""})

	aHeader:=fHeader(aCamposSim)
	aCols:=fCols(aHeader,cAlias,nIndice,cChave,cCondicao,cFiltro)
	aColsFullProc := aClone(aCols)

	for nC:=1 to len(aCols)
		aadd(aCols2, aCols[nC])
	next

	for nH:=1 to len(aHeader)
		aadd(aHeader2, aHeader[nh])
	next

	oDlgMO:=MsNewGetDados():New(nLin1,nCol1,nLin2  ,nCol2 ,nStyle,,,,,,0110,"LOCA075004()",,.T.,oFolder:aDialogs[nFolder],aHeader2,aCols2)
	oDlgMO:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT
	oDlgMO:oBrowse:bChange:={||MudaZM1(nFolder)}

Return

//-----------------------------------------------------------------------------
// 			Validacao de Campo
//-----------------------------------------------------------------------------

Function LOCA075005 //ZM0FieldOk()
	LRET := .T.
Return lRet

//-----------------------------------------------------------------------------
// 			Botao Salvar
//-----------------------------------------------------------------------------

STATIC FUNCTION FSALVAR(ODLG)
Local lPrimeira := .F.   
Local cNumContro	:= ""
Local nlc
Local nfx
Local nfz
Local nK
Local nG
Local nH
Local nI
Local nJ
Local nX
Local nhz

	cProj  := FQ5->FQ5_SOT
	CoBRA  := FQ5->FQ5_OBRA
	nAs    := FQ5->FQ5_AS//
	CMAT   := oDlgFro:aCols[oDlgFro:nAt][Ascan(oDlgFro:aHeader,{|x|AllTrim(x[2])=="FPU_MAT" }	)]
	CNOME  := Posicione("SRA",1,xFilial("FPU")+CMAT,"RA_NOME")
	aGravaZM0 := {}
	cChaveDel := ""
	nDel := 0
	Private nlc	 := 0

	If oFolder:nOption = 1
		For nlc := 1 to len(oDlgFro:aCols)
			//	cMat := oDlgFro:aCols[nh][1]
			ZM1MUDA(2,oFolder:nOption,@oDlg,@oFolder,nlc)
		Next nlc
	Else
		MsgStop(STR0015,STR0016) //"O processo s๓ pode ser finalizado quando estiver posicionado na aba de integra็ao"###"Aten็ao !"
		Return
	Endif

	For nfz := 01 to len(OdLGFRO:ACOLS)
		If OdLGFRO:ACOLS[nfz][11] = "99"                                                              
			For nfx := 01 to len(OdLGFRO:ACOLS)
				cNumContro := strzero(nfx,2)
				nPosgrv:=ascan(OdLGFRO:ACOLS,{|x|AllTrim(x[1])==ODLGFRO:ACOLS[oDlgFro:nAt][1] .and. x[11] == cNumContro })
				If nPosgrv = 0
					If lPrimeira = .F.
						lPrimeira := .T.
						cContro := cNumContro
					Endif
				Endif
			Next nfx
			OdLGFRO:ACOLS[oDlgFro:nat][11] := cContro  
			oDlgFro:Refresh()	
		Endif 
	Next nfz

	If nlc = 0
		lAchou:=Localiza(aGrv,Alltrim(CMAT)+Alltrim(oDlgFro:aCols[oDlgFro:nAt][11]))[1]
		
		If lAchou = .T.
			x :=Localiza(aGrv,Alltrim(CMAT)+Alltrim(oDlgFro:aCols[oDlgFro:nAt][11]))[2]
			
			if len(aGrv)<> 0
				aGrv[x][1][2] := oDlgMO:aCols
			endif
		Endif
	Endif         

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณValidacoes solicitadas na ETG15ณ
	//ณClaudio Miranda                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	FOR nK:= 1 TO LEN(ODLGFRO:ACOLS)
		nPosint := ascan(aIntOrig,{|x|AllTrim(x[1])==ODLGFRO:ACOLS[nK][1]})
		IF nPosint = 0
		Else
			If aIntOrig[nPosint][9] = "1"
				If Valtype(ODLGFRO:ACOLS[nK][Len(ODLGFRO:ACOLS[nK])-1]) = "N" .and. valtype(aIntOrig[nPosint][Len(aIntOrig[nPosint])-1]) = "N"
					If ODLGFRO:ACOLS[nK][Len(ODLGFRO:ACOLS[nK])-1] = aIntOrig[nPosint][Len(aIntOrig[nPosint])-1]
						If ODLGFRO:ACOLS[nK][9] != "1"
							MsgStop(STR0017+ ODLGFRO:ACOLS[nK][1] +STR0018+ Alltrim(str(nPosint)) +STR0019,STR0020) //"A matricula "###", referente a linha "###" da integra็ใo, ja estava definida como desistencia, portanto nใo poderแ ser alterada. Por favor altere o status da desistencia para prosseguir"###"Mensagem 201"
							Return
						Endif
					Endif
				Endif
			Endif
			If !Empty(oDlgfro:aCols[nK][4])  
				If oDlgfro:aCols[nK][3] > oDlgfro:aCols[nK][4]
					MsgStop(STR0021+ ODLGFRO:ACOLS[nK][1] +STR0022+Alltrim(str(nK)),STR0023)  //"A data de inicio nใo pode ser maior que a data final da integra็ao. Por favor corrija a matricula "###", linha "###"Mensagem 204"
					Return
				Endif
			Endif
		ENDIF
	Next nk

	FOR nX:=1 TO LEN(ODLGFRO:ACOLS)
		CMAT:= ODLGFRO:ACOLS[nX][1]
		nDifer := 1
		
		If ODLGFRO:ACOLS[nX][Len(ODLGFRO:ACOLS[nX])] = .F.    //ODLGFRO:ACOLS[nX][12] = .F.      //Verifica se o registro da integracao esta deletado
			If ODLGFRO:ACOLS[nX][9] != "1"  //Verifica se e desistencia
				//*** NAO HOUVE DESISTENCIA
				If !empty(ODLGFRO:ACOLS[nX][3])
					If !empty(ODLGFRO:ACOLS[nX][4])
						If ODLGFRO:ACOLS[nX][3] <= ODLGFRO:ACOLS[nX][4]
							lAchou:=Localiza(aGrv,Alltrim(CMAT)+Alltrim(ODLGFRO:ACOLS[nX][11]))[1]  //Procura registros de processos no array aGRV
							If lAchou = .T.  //Consiste ao encontrar o registro no aGRV
								x :=Localiza(aGrv,Alltrim(CMAT)+Alltrim(ODLGFRO:ACOLS[nX][11]))[2] //Traz a posi็ao do registro
								nDel := 0
								For nG := 1 to len(aGrv[x][1][2])  //Le o array aGRV e traz os processos de acordo com a matricula
									If aGrv[x][1][2][nG][Len(aGrv[x][1][2][nG])] = .F. //Verifica se o registro nao esta deletado
	//									If aGrv[x][1][2][nG][7] = ODLGFRO:ACOLS[nX][11]
											If !Empty(aGrv[x][1][2][nG][2])
												If !Empty(aGrv[x][1][2][nG][5]) .and. !Empty(aGrv[x][1][2][nG][6])
													If aGrv[x][1][2][nG][6] >= ODLGFRO:ACOLS[nX][3] .and. aGrv[x][1][2][nG][6] <= ODLGFRO:ACOLS[nX][4] //Verifica se a data prevista do processo e maior que a data inicio da integracao
														cDesist := ODLGFRO:ACOLS[nX][9]
														nPosgrv:=ascan(aGravaZM0,	{|x|AllTrim(x[1])==alltrim(CMAT) .and. x[8] == ODLGFRO:ACOLS[nX][11]})
	//													nPosgrv:=ascan(aGravaZM0,{|x|AllTrim(x[1])==alltrim(CMAT)})
														If nPosgrv = 0
															aadd(aGravaZM0,{CMAT,COBRA,CPROJ,nAs, nX, cDesist, .F.,ODLGFRO:ACOLS[nX][11]})
														Endif
													Else
														//If aGrv[x][1][2][nG][Len(aGrv[x][1][2][nG])] = .F.
															//If !Empty(aGrv[x][1][2][nG][2])
																//MsgStop("A data realizada esta fora do periodo de integra็ใo. Matricula: " + aGrv[x][1][2][nG][1] + ", Processo: " + aGrv[x][1][2][nG][2],"Mensagem 1")
																//Return
															//Endif
														//Endif
													Endif
												Else
													If !Empty(aGrv[x][1][2][nG][5]) .and. Empty(aGrv[x][1][2][nG][6])
														If !Empty(aGrv[x][1][2][nG][2])
															MsgStop("A data realizada nao foi preenchida. Matricula: " + aGrv[x][1][2][nG][1] + ", Processo: " + aGrv[x][1][2][nG][2],"Mensagem 2")
															Return
														Endif
													Elseif Empty(aGrv[x][1][2][nG][5]) .and. Empty(aGrv[x][1][2][nG][6])
														If !Empty(aGrv[x][1][2][nG][2])
															MsgStop("A data realizada nao foi preenchida. Matricula: " + aGrv[x][1][2][nG][1] + ", Processo: " + aGrv[x][1][2][nG][2],"Mensagem 3")
															Return
														Endif
													Else
														If aGrv[x][1][2][nG][6] >= ODLGFRO:ACOLS[nX][3] .and. aGrv[x][1][2][nG][6] <= ODLGFRO:ACOLS[nX][4] //Verifica se a data prevista do processo e maior que a data inicio da integracao
															cDesist := ODLGFRO:ACOLS[nX][9]
															nPosgrv:=ascan(aGravaZM0,	{|x|AllTrim(x[1])==alltrim(CMAT) .and. x[8] == ODLGFRO:ACOLS[nX][11]})
	//														nPosgrv:=ascan(aGravaZM0,{|x|AllTrim(x[1])==alltrim(CMAT)})
															If nPosgrv = 0
																aadd(aGravaZM0,{CMAT,COBRA,CPROJ,nAs, nX, cDesist, .F.,ODLGFRO:ACOLS[nX][11]})
	//														Else
	//															If aGravaZM0[nPosgrv][8] != ODLGFRO:ACOLS[nX][11]
	//																aadd(aGravaZM0,{CMAT,COBRA,CPROJ,nAs, nX, cDesist,.F.,ODLGFRO:ACOLS[nX][11]})
	//															Endif
															Endif
														Else
															If !Empty(aGrv[x][1][2][nG][2])
																MsgStop("A data realizada esta fora do periodo de integra็ใo. Matricula: " + aGrv[x][1][2][nG][1] + ", Processo: " + aGrv[x][1][2][nG][2],"Mensagem 4")
																Return
															Endif
														Endif
													Endif
												Endif
											Else
												MsgStop("Ao menos um processo deve estar preenchido para o encerramento da integra็ao. Matricula: " + ODLGFRO:ACOLS[nX][1]+" Linha "+ alltrim(str(nX)),"Mensagem 13")
												Return
											Endif
	//									Endif
									Else
										dbselectarea("FPV")
										FPV->(DBSETORDER(4))
										If DBSEEK(xFilial("FPV")+Substr(cAs+space(30),1,30)+Substr(cObra+space(3),1,3)+Substr(cProj+space(15),1,15)+Substr(cMat+space(8),1,8)+Substr(ODLGFRO:ACOLS[nX][11]+space(2),1,2))
											RecLock("FPV",.F.)
											dbDelete()
											MsUnlock("FPV")
										Endif
										nDel := nDel + 1
									Endif
								Next
								If nDel = len(aGrv[x][1][2])
									MsgStop("Ao menos um processo deve estar preenchido para o encerramento da integra็ao. Matricula: " + ODLGFRO:ACOLS[nX][1]+" Linha "+Alltrim(str(nX)),"Mensagem 14")
									Return
								Endif
							Else
								If ODLGFRO:ACOLS[nX][3] <= ODLGFRO:ACOLS[nX][4]
									MsgStop("Ao menos um processo deve ser preenchido para a matricula: " + ODLGFRO:ACOLS[nX][1]+" Linha "+Alltrim(str(nX)),"Mensagem 10")
									Return
								Else
									MsgStop("A data inicio da integra็ใo nao pode ser maior que a data final.  Matricula: " + ODLGFRO:ACOLS[nX][1]+" Linha "+Alltrim(str(nX)),"Mensagem 11")
									Return
								Endif
							Endif
						Else
							MsgStop("A data inicio da integra็ใo nao pode ser maior que a data final.  Matricula: " + ODLGFRO:ACOLS[nX][1]+" Linha "+Alltrim(str(nX)),"Mensagem 12")
							Return
						Endif
					Else
						// Se nao ha data Final
						lAchou:=Localiza(aGrv,Alltrim(CMAT)+Alltrim(ODLGFRO:ACOLS[nX][11]))[1]  //Procura registros de processos no array aGRV
						If lAchou = .T.  //Consiste ao encontrar o registro no aGRV
							x :=Localiza(aGrv,Alltrim(CMAT)+Alltrim(ODLGFRO:ACOLS[nX][11]))[2] //Traz a posi็ao do registro
							For nH := 1 to len(aGrv[x][1][2])  //Le o array aGRV e traz os processos de acordo com a matricula
								If aGrv[x][1][2][nH][Len(aGrv[x][1][2][nH])] = .F. //Verifica se o registro nao esta deletado
	//								If aGrv[x][1][2][nH][7] = ODLGFRO:ACOLS[nX][11]
										If !Empty(aGrv[x][1][2][nH][6])
											If aGrv[x][1][2][nH][6] >= ODLGFRO:ACOLS[nX][3]
												cDesist := ODLGFRO:ACOLS[nX][9]
												nPosgrv:=ascan(aGravaZM0,	{|x|AllTrim(x[1])==alltrim(CMAT) .and. x[8] == ODLGFRO:ACOLS[nX][11]})
												If nPosgrv = 0
													aadd(aGravaZM0,{CMAT,COBRA,CPROJ,nAs, nX, cDesist, .F.,ODLGFRO:ACOLS[nX][11]})
												Endif
											Else
												If !Empty(aGrv[x][1][2][nH][2])
													MsgStop("A data realizada esta fora do periodo de integra็ใo. Matricula: " + aGrv[x][1][2][nH][1] + ", Processo: " + aGrv[x][1][2][nH][2],"Mensagem 5")
													Return
												Endif
											Endif
										Else
											cDesist := ODLGFRO:ACOLS[nX][9]
											nPosgrv:=ascan(aGravaZM0,	{|x|AllTrim(x[1])==alltrim(CMAT) .and. x[8] == ODLGFRO:ACOLS[nX][11]})
											If nPosgrv = 0
												aadd(aGravaZM0,{CMAT,COBRA,CPROJ,nAs, nX, cDesist, .F.,ODLGFRO:ACOLS[nX][11]})
											Endif
										Endif
	//								Endif
								Else
									dbselectarea("FPV")
									FPV->(DBSETORDER(4))
									If DBSEEK(xFilial("FPV")+Substr(cAs+space(30),1,30)+Substr(cObra+space(3),1,3)+Substr(cProj+space(15),1,15)+Substr(cMat+space(8),1,8)+Substr(ODLGFRO:ACOLS[nX][11]+space(2),1,2))
										RecLock("FPV",.F.)
										dbDelete()
										MsUnlock("FPV")
									Endif
									
									cDesist := ODLGFRO:ACOLS[nX][9]
									nPosgrv:=ascan(aGravaZM0,	{|x|AllTrim(x[1])==alltrim(CMAT) .and. x[8] == ODLGFRO:ACOLS[nX][11]})
	//								nPosgrv:=ascan(aGravaZM0,{|x|AllTrim(x[1])==alltrim(CMAT)})
									If nPosgrv = 0
										aadd(aGravaZM0,{CMAT,COBRA,CPROJ,nAs, nX, cDesist,.F.,ODLGFRO:ACOLS[nX][11]})
									Endif
								Endif
							Next
						Endif
					Endif
				Else
					//*** Data inicial em branco (Integra็ใo)
					If !empty(ODLGFRO:ACOLS[nX][4])
						MsgStop("A data de inicio da integra็ใo nao foi preenchida. Matricula: " + ODLGFRO:ACOLS[nX][1]+" Linha "+Alltrim(str(nX)),"Mensagem 6")
						Return
					Else
						lAchou:=Localiza(aGrv,Alltrim(CMAT)+Alltrim(ODLGFRO:ACOLS[nX][11]))[1]  //Procura registros de processos no array aGRV
						If lAchou = .T.  //Consiste ao encontrar o registro no aGRV
							x :=Localiza(aGrv,Alltrim(CMAT)+Alltrim(ODLGFRO:ACOLS[nX][11]))[2] //Traz a posi็ao do registro
							For nI := 1 to len(aGrv[x][1][2])  //Le o array aGRV e traz os processos de acordo com a matricula
								If aGrv[x][1][2][nI][Len(aGrv[x][1][2][nI])] = .F. //Verifica se o registro nao esta deletado
	//								If aGrv[x][1][2][nI][7] = ODLGFRO:ACOLS[nX][11]
										If !Empty(aGrv[x][1][2][nI][5]) .and. !Empty(aGrv[x][1][2][nI][6])
											If !Empty(aGrv[x][1][2][nI][2])
												MsgStop("A data de inicio e fim da integra็ใo nao foram preenchidas. Matricula: " + aGrv[x][1][2][nI][1] + ", Processo: " + aGrv[x][1][2][nI][2],"Mensagem 7")
												Return
											Endif
										Elseif Empty(aGrv[x][1][2][nI][5]) .and. !Empty(aGrv[x][1][2][nI][6])
											If !Empty(aGrv[x][1][2][nI][2])
												MsgStop("A data de inicio e fim da integra็ใo nao foram preenchidas. Matricula: " + aGrv[x][1][2][nI][1] + ", Processo: " + aGrv[x][1][2][nI][2],"Mensagem 8")
												Return
											Endif
										Else
											cDesist := ODLGFRO:ACOLS[nX][9]
											nPosgrv:=ascan(aGravaZM0,	{|x|AllTrim(x[1])==alltrim(CMAT) .and. x[8] == ODLGFRO:ACOLS[nX][11]})
	//										nPosgrv:=ascan(aGravaZM0,{|x|AllTrim(x[1])==alltrim(CMAT)})
											If nPosgrv = 0
												aadd(aGravaZM0,{CMAT,COBRA,CPROJ,nAs, nX, cDesist, .F.,ODLGFRO:ACOLS[nX][11]})
											Endif
										Endif    
	//								Endif
								Else
									dbselectarea("FPV")
									FPV->(DBSETORDER(4))
									If DBSEEK(xFilial("FPV")+Substr(cAs+space(30),1,30)+Substr(cObra+space(3),1,3)+Substr(cProj+space(15),1,15)+Substr(cMat+space(8),1,8)+Substr(ODLGFRO:ACOLS[nX][11]+space(2),1,2))
										RecLock("FPV",.F.)
										dbDelete()
										MsUnlock("FPV")
									Endif
									
									cDesist := ODLGFRO:ACOLS[nX][9]
									nPosgrv:=ascan(aGravaZM0,	{|x|AllTrim(x[1])==alltrim(CMAT) .and. x[8] == ODLGFRO:ACOLS[nX][11]})
	//								nPosgrv:=ascan(aGravaZM0,{|x|AllTrim(x[1])==alltrim(CMAT)})
									If nPosgrv = 0
										aadd(aGravaZM0,{CMAT,COBRA,CPROJ,nAs, nX, cDesist,.F.,ODLGFRO:ACOLS[nX][11]})
									Endif
								Endif
							Next
						Endif
					Endif
				Endif
			Else
				//*** HOUVE DESISTENCIA
				If !empty(ODLGFRO:ACOLS[nX][3])
					If !empty(ODLGFRO:ACOLS[nX][4])
						If ODLGFRO:ACOLS[nX][3] <= ODLGFRO:ACOLS[nX][4]
							lAchou:=Localiza(aGrv,Alltrim(CMAT)+Alltrim(ODLGFRO:ACOLS[nX][11]))[1]  //Procura registros de processos no array aGRV
							If lAchou = .T.  //Consiste ao encontrar o registro no aGRV
								x :=Localiza(aGrv,Alltrim(CMAT)+Alltrim(ODLGFRO:ACOLS[nX][11]))[2] //Traz a posi็ao do registro
								For nJ := 1 to len(aGrv[x][1][2])  //Le o array aGRV e traz os processos de acordo com a matricula
									If aGrv[x][1][2][nJ][Len(aGrv[x][1][2][nJ])] = .F. //Verifica se o registro nao esta deletado
	//									If aGrv[x][1][2][nJ][7] = ODLGFRO:ACOLS[nX][11]
											If !Empty(aGrv[x][1][2][nJ][5]) .and. !Empty(aGrv[x][1][2][nJ][6])
												If aGrv[x][1][2][nJ][6] >= ODLGFRO:ACOLS[nX][3] .and. aGrv[x][1][2][nJ][6] <= ODLGFRO:ACOLS[nX][4] //Verifica se a data prevista do processo e maior que a data inicio da integracao
													cDesist := ODLGFRO:ACOLS[nX][9]
													nPosgrv:=ascan(aGravaZM0,	{|x|AllTrim(x[1])==alltrim(CMAT) .and. x[8] == ODLGFRO:ACOLS[nX][11]})
	//												nPosgrv:=ascan(aGravaZM0,{|x|AllTrim(x[1])==alltrim(CMAT)})
													If nPosgrv = 0
														aadd(aGravaZM0,{CMAT,COBRA,CPROJ,nAs, nX, cDesist, .F.,ODLGFRO:ACOLS[nX][11]})
	//												Else
	//													If aGravaZM0[nPosgrv][8] != ODLGFRO:ACOLS[nX][11]
	//														aadd(aGravaZM0,{CMAT,COBRA,CPROJ,nAs, nX, cDesist,.F.,ODLGFRO:ACOLS[nX][11]})
	//													Endif
													Endif
												Else
													If !Empty(aGrv[x][1][2][nJ][2])
														MsgStop("A data realizada esta fora do periodo de integra็ใo. Matricula: " + aGrv[x][1][2][nJ][1] + ", Processo: " + aGrv[x][1][2][nJ][2],"Mensagem A")
														Return
													Endif
												Endif
											Else
												If !Empty(aGrv[x][1][2][nJ][5]) .and. Empty(aGrv[x][1][2][nJ][6])
													If !Empty(aGrv[x][1][2][nJ][2])
														cDesist := ODLGFRO:ACOLS[nX][9]
														nPosgrv:=ascan(aGravaZM0,	{|x|AllTrim(x[1])==alltrim(CMAT) .and. x[8] == ODLGFRO:ACOLS[nX][11]})
	//													nPosgrv:=ascan(aGravaZM0,{|x|AllTrim(x[1])==alltrim(CMAT)})
														If nPosgrv = 0
															aadd(aGravaZM0,{CMAT,COBRA,CPROJ,nAs, nX, cDesist, .F.,ODLGFRO:ACOLS[nX][11]})
	//													Else
	//														If aGravaZM0[nPosgrv][8] != ODLGFRO:ACOLS[nX][11]
	//															aadd(aGravaZM0,{CMAT,COBRA,CPROJ,nAs, nX, cDesist,.F.,ODLGFRO:ACOLS[nX][11]})
	//														Endif
														Endif
													Endif
												Elseif Empty(aGrv[x][1][2][nJ][5]) .and. Empty(aGrv[x][1][2][nJ][6])
													//										If !Empty(aGrv[x][1][2][nJ][2])
													cDesist := ODLGFRO:ACOLS[nX][9]
													nPosgrv:=ascan(aGravaZM0,	{|x|AllTrim(x[1])==alltrim(CMAT) .and. x[8] == ODLGFRO:ACOLS[nX][11]})
	//												nPosgrv:=ascan(aGravaZM0,{|x|AllTrim(x[1])==alltrim(CMAT)})
													If nPosgrv = 0
														aadd(aGravaZM0,{CMAT,COBRA,CPROJ,nAs, nX, cDesist, .F.,ODLGFRO:ACOLS[nX][11]})
	//												Else
	//													If aGravaZM0[nPosgrv][8] != ODLGFRO:ACOLS[nX][11]
	//														aadd(aGravaZM0,{CMAT,COBRA,CPROJ,nAs, nX, cDesist,.F.,ODLGFRO:ACOLS[nX][11]})
	//													Endif
													Endif
													//										Endif
												Else
													If aGrv[x][1][2][nJ][6] >= ODLGFRO:ACOLS[nX][3] .and. aGrv[x][1][2][nJ][6] <= ODLGFRO:ACOLS[nX][4] //Verifica se a data prevista do processo e maior que a data inicio da integracao
														cDesist := ODLGFRO:ACOLS[nX][9]
														nPosgrv:=ascan(aGravaZM0,	{|x|AllTrim(x[1])==alltrim(CMAT) .and. x[8] == ODLGFRO:ACOLS[nX][11]})
	//													nPosgrv:=ascan(aGravaZM0,{|x|AllTrim(x[1])==alltrim(CMAT)})
														If nPosgrv = 0
															aadd(aGravaZM0,{CMAT,COBRA,CPROJ,nAs, nX, cDesist, .F.,ODLGFRO:ACOLS[nX][11]})
	//													Else
	//														If aGravaZM0[nPosgrv][8] != ODLGFRO:ACOLS[nX][11]
	//															aadd(aGravaZM0,{CMAT,COBRA,CPROJ,nAs, nX, cDesist,.F.,ODLGFRO:ACOLS[nX][11]})
	//														Endif
														Endif
													Else
														If !Empty(aGrv[x][1][2][nJ][2])
															MsgStop("A data realizada esta fora do periodo de integra็ใo. Matricula: " + aGrv[x][1][2][nJ][1] + ", Processo: " + aGrv[x][1][2][nJ][2],"Mensagem B")
															Return
														Endif
													Endif
												Endif
											Endif           
	//									Endif
									Else
										dbselectarea("FPV")
										FPV->(DBSETORDER(4))
										If DBSEEK(xFilial("FPV")+Substr(cAs+space(30),1,30)+Substr(cObra+space(3),1,3)+Substr(cProj+space(15),1,15)+Substr(cMat+space(8),1,8)+Substr(ODLGFRO:ACOLS[nX][11]+space(2),1,2))
											RecLock("FPV",.F.)
											dbDelete()
											MsUnlock("FPV")
										Endif
									
										cDesist := ODLGFRO:ACOLS[nX][9]
										nPosgrv:=ascan(aGravaZM0,	{|x|AllTrim(x[1])==alltrim(CMAT) .and. x[8] == ODLGFRO:ACOLS[nX][11]})
	//									nPosgrv:=ascan(aGravaZM0,	{|x|AllTrim(x[1])==alltrim(CMAT) .and. x[8] == ODLGFRO:ACOLS[nX][11]})
	//									nPosgrv:=ascan(aGravaZM0,{|x|AllTrim(x[1])==alltrim(CMAT)})
										If nPosgrv = 0
											aadd(aGravaZM0,{CMAT,COBRA,CPROJ,nAs, nX, cDesist,.F.,ODLGFRO:ACOLS[nX][11]})
	//									Else
	//										If aGravaZM0[nPosgrv][8] != ODLGFRO:ACOLS[nX][11]
	//											aadd(aGravaZM0,{CMAT,COBRA,CPROJ,nAs, nX, cDesist,.F.,ODLGFRO:ACOLS[nX][11]})
	//										Endif
										Endif
									Endif
								Next
							Else
								If ODLGFRO:ACOLS[nX][3] <= ODLGFRO:ACOLS[nX][4]
									cDesist := ODLGFRO:ACOLS[nX][9]
									nPosgrv:=ascan(aGravaZM0,	{|x|AllTrim(x[1])==alltrim(CMAT) .and. x[8] == ODLGFRO:ACOLS[nX][11]})
	//								nPosgrv:=ascan(aGravaZM0,	{|x|AllTrim(x[1])==alltrim(CMAT).and. x[2] == 'N'})
									If nPosgrv = 0
										aadd(aGravaZM0,{CMAT,COBRA,CPROJ,nAs, nX, cDesist,.F.,ODLGFRO:ACOLS[nX][11]})
	//								Else
	//									If aGravaZM0[nPosgrv][8] != ODLGFRO:ACOLS[nX][11]
	//										aadd(aGravaZM0,{CMAT,COBRA,CPROJ,nAs, nX, cDesist,.F.,ODLGFRO:ACOLS[nX][11]})
	//									Endif
									Endif
								Else
									MsgStop("A data inicio da integra็ใo nao pode ser maior que a data final.  Matricula: " + ODLGFRO:ACOLS[nX][1]+" Linha "+Alltrim(str(nX)),"Mensagem E")
									Return
								Endif
							Endif
						Else
							MsgStop("A data inicio da integra็ใo nao pode ser maior que a data final.  Matricula: " + ODLGFRO:ACOLS[nX][1]+" Linha "+Alltrim(str(nX)),"Mensagem F")
							Return
						Endif
					Else
						// Se nao ha data Final
						MsgStop("A data final da integra็ใo deve ser preenchida. Matricula: " + ODLGFRO:ACOLS[nX][1]+" Linha "+Alltrim(str(nX)),"Mensagem C")
						Return
					Endif
				Else
					//*** Data inicial em branco (Integra็ใo)
					MsgStop("A data inicial da integra็ใo deve ser preenchida. Matricula: " + ODLGFRO:ACOLS[nX][1]+" Linha "+Alltrim(str(nX)),"Mensagem D")
					Return
				Endif
			Endif
		Else
			// ###  Registro da integracao deletado
			GRAVZM0(CMAT,COBRA,CPROJ,nAs, nX, ODLGFRO:ACOLS[nX][9],.T.,ODLGFRO:ACOLS[nX][11])
			DbSelectArea("FPU")
			DbSetOrder(2)
			If DbSeek(xFilial("FPU")+nAs+COBRA+CPROJ+CMAT+ODLGFRO:ACOLS[nX][11])
				FPU->(RecLock("FPU",.F.))
				FPU->(dbDelete())
				FPU->(MsUnlock())
			Endif
		Endif
		
	NEXT

	If Len(aGravaZM0) > 0
		For nhz := 1 to Len(aGravaZM0)
			GRAVZM0(aGravaZM0[nhz][1],aGravaZM0[nhz][2],aGravaZM0[nhz][3],aGravaZM0[nhz][4],aGravaZM0[nhz][5],aGravaZM0[nhz][6],.F.,aGravaZM0[nhz][8])
			ODLG:END()
		Next
	Else
		ODLG:END()
	Endif

RETURN

//-----------------------------------------------------------------------------
// 			Botao Sair
//-----------------------------------------------------------------------------
STATIC FUNCTION FSAIR(ODLG)
	ODLG:END()
RETURN

//-----------------------------------------------------------------------------
// 			Responsavel pela mudanca de FOLDER
//-----------------------------------------------------------------------------


Static Function ZM1MUDA(nIndo,nEstou,oDlg,oFolder,nlc)
Local lPrimeira := .F.   
Local cNumContro	:= ""
Local nfx

private aColsTemp:={}

cFQ5_AS:=PADR(FQ5->FQ5_AS,LEN(FPV->FPV_AS))
cFQ5_OBRA:=PADR(FQ5->FQ5_OBRA,LEN(FPV->FPV_OBRA))
cFQ5_SOT:=PADR(FQ5->FQ5_SOT,LEN(FPV->FPV_PROJ)) 

If Empty(nlc)
	If OdLGFRO:ACOLS[oDlgFro:nat][11] = "99"                                                              
		For nfx := 01 to len(OdLGFRO:ACOLS)
			cNumContro := strzero(nfx,2)
			nPosgrv:=ascan(OdLGFRO:ACOLS,{|x|AllTrim(x[1])==ODLGFRO:ACOLS[oDlgFro:nAt][1] .and. x[11] == cNumContro })
			If nPosgrv = 0
				If lPrimeira = .F.
					lPrimeira := .T.
					cContro := cNumContro
			    Endif
			Endif
		Next nfx
		OdLGFRO:ACOLS[oDlgFro:nat][11] := cContro  
		oDlgFro:Refresh()	
	Endif

	CmAT := OdLGFRO:ACOLS[oDlgFro:nat][1]
	cNrAs := oDlgFro:aCols[oDlgFro:nAt][Ascan(oDlgFro:aHeader,{|x|AllTrim(x[2])=="FPU_MAT" }	)]
	cAlias   :="FPV"
	cChave   :=xFILIAL(cAlias)+cFQ5_AS+cFQ5_OBRA+cFQ5_SOT+Substr(cMat+space(8),1,8)+OdLGFRO:ACOLS[oDlgFro:nat][11]
	nIndice  :=4  //filial+aS+Obra+Projeto+Funcionario+controle
	cFiltro  :="ALLTRIM(FPV->FPV_MAT)== ALLTRIM(OdLGFRO:ACOLS[oDlgFro:nat][1]) .and. FPV->FPV_CONTRO == OdLGFRO:ACOLS[oDlgFro:nat][11]"//cCondicao
	cNrAs := oDlgFro:aCols[oDlgFro:nAt][Ascan(oDlgFro:aHeader,{|x|AllTrim(x[2])=="FPU_MAT" }	)]
	x:=0
	
	Do Case
		
		Case nIndo==nFolderInt //FOLDER INTEGRACAO
			lAchou:=Localiza(aGrv,Alltrim(cNrAs)+Alltrim(oDlgFro:aCols[oDlgFro:nAt][11]))[1]
			x :=Localiza(aGrv,Alltrim(cNrAs)+Alltrim(oDlgFro:aCols[oDlgFro:nAt][11]))[2]
			aGrv[x][1][2] := oDlgMO:aCols
			//		aOnde := Aclone(oDlgMo:aCols)
			AtuMOaCols()
		Case nIndo==nFolderProc  //FOLDER DE PROCESSO
			
			oDlgMO:aCols:=fCols2(aHeader,cAlias,nIndice,cChave,"",cFiltro,0)
			lAchou:=Localiza(aGrv,Alltrim(cNrAs)+Alltrim(oDlgFro:aCols[oDlgFro:nAt][11]))[1]
			x :=Localiza(aGrv,Alltrim(cNrAs)+Alltrim(oDlgFro:aCols[oDlgFro:nAt][11]))[2]
			
			IF lAchou
				oDlgMO:aCols:= aGrv[x][1][2]
			else
				nPosF1:= oDlgFro:nAt
				oDlgMO:aCols[1][1]:= cNrAs  //ADICIONANADO INDICE   ==============================
				oDlgMO:aCols[1][7]:= oDlgFro:aCols[oDlgFro:nAt][11]
				aadd(aColsTemp,{Alltrim(oDlgFro:aCols[oDlgFro:nAt][1])+Alltrim(oDlgFro:aCols[oDlgFro:nAt][11])})
				aadd(aColsTemp[1],oDlgMO:aCols)
				aadd( aGRV , aClone(aColsTemp) )
				//			aOnde := AClone(oDlgMo:aCols)
			endif
			oDlgMO:Refresh()
	EndCase
	
Else
	If OdLGFRO:ACOLS[nlc][11] = "99"                                                              
		For nfx := 01 to len(OdLGFRO:ACOLS)
			cNumContro := strzero(nfx,2)
			nPosgrv:=ascan(OdLGFRO:ACOLS,{|x|AllTrim(x[1])==ODLGFRO:ACOLS[nlc][1] .and. x[11] == cNumContro })
			If nPosgrv = 0
				If lPrimeira = .F.
					lPrimeira := .T.
					cContro := cNumContro
			    Endif
			Endif
		Next nfx
		OdLGFRO:ACOLS[nlc][11] := cContro 
		OdLGFRO:ACOLS[nlc][12] := FQ5->FQ5_CODCLI 
		OdLGFRO:ACOLS[nlc][13] := FQ5->FQ5_LOJA		
		oDlgFro:Refresh()	
	Endif

	CmAT := OdLGFRO:ACOLS[nlc][1]
	cNrAs := oDlgFro:aCols[nlc][Ascan(oDlgFro:aHeader,{|x|AllTrim(x[2])=="FPU_MAT" }	)]
	
	cAlias   :="FPV"
	cChave   :=xFILIAL(cAlias)+cFQ5_AS+cFQ5_OBRA+cFQ5_SOT+Substr(cMat+space(8),1,8)+oDlgFro:aCols[nlc][11]
	nIndice  :=4  //filial+aS+Obra+Projeto+Funcionario
	cFiltro  :="ALLTRIM(FPV->FPV_MAT)== ALLTRIM(OdLGFRO:ACOLS[nlc][1]) .and. FPV->FPV_CONTRO == OdLGFRO:ACOLS[nlc][11]"//cCondicao
	x:=0
	
	Do Case
		
		Case nIndo==nFolderInt //FOLDER INTEGRACAO
			lAchou:=Localiza(aGrv,Alltrim(cNrAs)+Alltrim(oDlgFro:aCols[nlc][11]))[1]
			x :=Localiza(aGrv,Alltrim(cNrAs)+Alltrim(oDlgFro:aCols[nlc][11]))[2]
			aGrv[x][1][2] := oDlgMO:aCols
			//		aOnde := Aclone(oDlgMo:aCols)
			AtuMOaCols()
		Case nIndo==nFolderProc  //FOLDER DE PROCESSO
			
			oDlgMO:aCols:=fCols2(aHeader,cAlias,nIndice,cChave,"",cFiltro,nlc)
			lAchou:=Localiza(aGrv,Alltrim(cNrAs)+Alltrim(oDlgFro:aCols[nlc][11]))[1]
			x :=Localiza(aGrv,Alltrim(cNrAs)+Alltrim(oDlgFro:aCols[nlc][11]))[2]
			
			IF lAchou
				oDlgMO:aCols:= aGrv[x][1][2]
			else
				nPosF1:= nlc
				oDlgMO:aCols[1][1]:= cNrAs  //ADICIONANADO INDICE   ==============================
				aadd(aColsTemp,{alltrim(oDlgFro:aCols[nlc][1])+Alltrim(oDlgFro:aCols[nlc][11])})
				aadd(aColsTemp[1],oDlgMO:aCols)
				aadd( aGRV , aClone(aColsTemp) )
				//			aOnde := AClone(oDlgMo:aCols)
			endif
			oDlgMO:Refresh()
	EndCase
Endif
Return

//-----------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtuMOaCols  บAutor  ณM&S Consultoria     บ Data ณ  30/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Serve para guardar as informa็๕es de M.O. quando o           บฑฑ
ฑฑบ          ณ usuแrio mudar de pasta ou for gravar os dados                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOCT049                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AtuMOaCols()
Local nI
	For nI := 1 to len(oDlgMO:aCols)
		nPos    := 0
		nRecord := oDlgMO:aCols[nI, len(oDlgMO:aHeader)+1]
		
		if nRecord == 0
			nPos := aScan(aColsFullProc, {|x| x[len(oDlgMO:aHeader)+1] == nRecord})
			if nPos == 0
				if ! Empty( oDlgMO:aCols[nI][Ascan(oDlgMO:aHeader,{|x|AllTrim(x[2])=="FPV_MAT"})] )
					aadd(aColsFullProc, oDlgMO:aCols[nI])
				endif
			endif
		else
			nPos := aScan(aColsFullProc, {|x| x[len(oDlgMO:aHeader)+1] == nRecord})
		endif
		if nPos > 0
			aColsFullProc[nPos] := aClone(oDlgMO:aCols[nI])
		endif
	next
Return Nil


//-----------------------------------------------------------------------------
Static Function fHeader(aCamposSim)
Local nPos,aTabAux,aHeader:={}
	dbSelectArea("SX3")
	dbSetOrder(2)  //X3_CAMPO
	For nPos:=1 to Len(aCamposSim)
		If (LOCXCONV(1))->(dbSeek(AllTrim(aCamposSim[nPos,1])))
			aTabAux:={}
			AAdd(aTabAux,TRIM(x3Titulo()))
			AAdd(aTabAux,x3_campo        )
			AAdd(aTabAux,x3_picture      )
			AAdd(aTabAux,x3_tamanho      )
			AAdd(aTabAux,x3_decimal      )
			AAdd(aTabAux,x3_valid        )
			AAdd(aTabAux,x3_usado        )
			AAdd(aTabAux,x3_tipo         )
			AAdd(aTabAux,x3_f3           )
			AAdd(aTabAux,x3_context      )
			AAdd(aTabAux,x3_cbox         )
			AAdd(aTabAux,x3_relacao      )
			AAdd(aTabAux,".t."           )
			
			
			If !Empty(aCamposSim[nPos,2])
				AAdd(aTabAux,aCamposSim[nPos,2])
			Else
				AAdd(aTabAux,x3_visual       )
			EndIf
			
			AAdd(aTabAux,X3_VLDUSER      )
			AAdd(aTabAux,X3_PICTVAR      )
			AAdd(aTabAux,X3_OBRIGAT      )
			AAdd(aHeader,aTabAux         )
		EndIf
	Next

	dbSetOrder(1)  //X3_ARQUIVO+X3_ORDEM

Return(AClone(aHeader))

Static Function fCols(aHeader,cAlias,nIndice,cChave,cCondicao,cFiltro)
Local nPos,aCols0,aCols:={}

	(cAlias)->(DbSetOrder(nIndice))
	(cAlias)->(DbSeek(cChave,.t.))

	If cAlias == "FPV"
		//	If Empty(cMat)
		//		cString := "(cAlias)->(!Eof()) .and. cChave == xFilial(' + "ZM1" + ')+ZM1->ZM1_AS+ZM1->ZM1_OBRA+ZM1->ZM1_PROJ"
		//	Else
		//		cString := "(cAlias)->(!Eof()) .and. cChave == xFilial(' + "ZM1" + ')+ZM1->ZM1_AS+ZM1->ZM1_OBRA+ZM1->ZM1_PROJ+ZM1->ZM1_MAT"
		//	End
		
		While (cAlias)->(!Eof()) .and. cChave == xFilial("FPV")+FPV->FPV_AS+FPV->FPV_OBRA+FPV->FPV_PROJ
			if !empty(cfiltro)
				If !(&cFiltro)
					(cAlias)->(DbSkip())
					Loop
				EndIf
			endif
			aCols0:={}
			For nPos:=1 to Len(aHeader)
				If !aHeader[nPos,10]=="V"  //x3_context
					(cAlias)->(AAdd(aCols0,FieldGet(FieldPos(aHeader[nPos,2]))))
				Else
					(cAlias)->(AAdd(aCols0,CriaVar(aHeader[nPos,2])))
				EndIf
			Next
			
			AAdd(aCols0,(cAlias)->(Recno())  )  //n๚mero do registro
			AAdd(aCols0,.F.  )  //Deleted
			AAdd(aCols,aCols0)
			(cAlias)->(DbSkip())
		EndDo
		
	Else
		DbSelectArea("FPU")
		DbSetOrder(2)
		If DbSeek(cChave)
			While (cAlias)->(!Eof()) .and. cChave == xFilial("FPU")+FPU->FPU_AS+FPU->FPU_OBRA+FPU->FPU_PROJ   //Se necessแrio coloca a chave para ZM0 Aqui.
				if !empty(cfiltro)
					If !(&cFiltro)
						(cAlias)->(DbSkip())
						Loop
					EndIf
				endif
				aCols0:={}
				For nPos:=1 to Len(aHeader)
					If !aHeader[nPos,10]=="V"  //x3_context
						(cAlias)->(AAdd(aCols0,FieldGet(FieldPos(aHeader[nPos,2]))))
					Else
						(cAlias)->(AAdd(aCols0,CriaVar(aHeader[nPos,2])))
					EndIf
				Next
				
				AAdd(aCols0,(cAlias)->(Recno())  )  //n๚mero do registro
				AAdd(aCols0,.F.  )  //Deleted
				AAdd(aCols,aCols0)
				AAdd(aIntOrig,aCols0)
				(cAlias)->(DbSkip())
			EndDo
		Endif
	End

	If Empty(aCols)
		aCols0:={}
		For nPos:=1 to Len(aHeader)
			(cAlias)->(AAdd(aCols0,CriaVar(aHeader[nPos,2])))
		Next
		
		AAdd(aCols0,0	 )  //n๚mero do registro
		AAdd(aCols0,.F.  )  //Deleted
		AAdd(aCols,aCols0)
	EndIf

Return(AClone(aCols))

Static Function fGravaTudo(cAlias,aHeader,aCols)  //Grava todos os campos do aCols
Local nPos,cCampo
	For nPos:=1 to Len(aHeader)
		cCampo:=aHeader[nPos,2]
		(cAlias)->(&cCampo):=aCols[nPos]
	Next
Return(.t.)
//-----------------------------------------------------------------------------

Static Function fSalvar000()
	AtuMOaCols()
Return

//----------------------------------------------------------------
Static Function MudaZM0(pGet)  //Muda o Browse
Local lRet		:=.T.
Local cNrAs		:=""
Local cProjeto	:=""
Local cObra		:=""
Local cMat		:=""
Local DDATE		:= CTOD("")

	Do Case
		Case pGet == 1
			If Empty(oDlgfro:aCols[oDlgFro:nAt][2])
				oDlgFro:aCols[oDlgFro:nAt][Ascan(oDlgFro:aHeader,{|x|AllTrim(x[2])=="FPU_DTLIM"}	)]	:= dDATE  //Estava apaganda as datas ao mudar alinha nos processos
				oDlgFro:aCols[oDlgFro:nAt][Ascan(oDlgFro:aHeader,{|x|AllTrim(x[2])=="FPU_DTFIN"} 	)]	:= dDATE  //Estava apaganda as datas ao mudar alinha nos processos
				oDlgFro:aCols[oDlgFro:nAt][Ascan(oDlgFro:aHeader,{|x|AllTrim(x[2])=="FPU_DTINI"} 	)]	:= dDATE  //Estava apaganda as datas ao mudar alinha nos processos
				oDlgFro:aCols[oDlgFro:nAt][Ascan(oDlgFro:aHeader,{|x|AllTrim(x[2])=="FPU_CONTRO"} )]	:= "99"
				oDlgFro:aCols[oDlgFro:nAt][Ascan(oDlgFro:aHeader,{|x|AllTrim(x[2])=="FPU_CODCLI"} )]	:= FQ5->FQ5_CODCLI// Foi colocado para pegar direto da tabela FQ5 pois o cliente e loja sใo os mesmos em todas as linhas
				oDlgFro:aCols[oDlgFro:nAt][Ascan(oDlgFro:aHeader,{|x|AllTrim(x[2])=="FPU_LOJCLI"} )]	:= FQ5->FQ5_LOJA
				
			End
			oDlgFro:oBrowse:Refresh()
		Case pGet == 2
	EndCase

Return lRet

//----------------------------------------------------------------
Static Function MudaZM1(pGet)  //Muda o Browse
Local lRet:=.T.
Local cNrAs:= "FPU->FPU_MAT"
Local cProjeto	:=""
Local cObra		:=""
Local cMat	:=""
	DDATE:= CTOD("")

	if oDlgMO:nAt > 1
		cNrAs 	:= oDlgFro:aCols[oDlgFro:nAt][Ascan(oDlgFro:aHeader,{|x|AllTrim(x[2])=="FPU_MAT" }	)]
		cContro := oDlgFro:aCols[oDlgFro:nAt][Ascan(oDlgFro:aHeader,{|x|AllTrim(x[2])=="FPU_CONTRO" }	)]
		oDlgMO:aCols[oDlgMO:nAt][Ascan(oDlgMO:aHeader,{|x|AllTrim(x[2])=="FPV_MAT" }		)]	:= cNrAs
		oDlgMO:aCols[oDlgMO:nAt][Ascan(oDlgMO:aHeader,{|x|AllTrim(x[2])=="FPV_OBS"}	)]	:= ""
		//	If Empty(oDlgMO:aCols[oDlgMO:nAt][Ascan(oDlgMO:aHeader,{|x|AllTrim(x[2])=="ZM1_DTPREV"}	)])
		If Empty(oDlgMO:aCols[oDlgMO:nAt][2])
			oDlgMO:aCols[oDlgMO:nAt][Ascan(oDlgMO:aHeader,{|x|AllTrim(x[2])=="FPV_DTPREV"}	)]	:= dDATE  //Estava apaganda as datas ao mudar alinha nos processos
			oDlgMO:aCols[oDlgMO:nAt][Ascan(oDlgMO:aHeader,{|x|AllTrim(x[2])=="FPV_DTREAL"}	)]	:= dDATE  //Estava apaganda as datas ao mudar alinha nos processos
			oDlgMO:aCols[oDlgMO:nAt][Ascan(oDlgMO:aHeader,{|x|AllTrim(x[2])=="FPV_CONTRO"}	)]	:= cContro  //Estava apaganda as datas ao mudar alinha nos processos
		End
		//	If Empty(oDlgMO:aCols[oDlgMO:nAt][Ascan(oDlgMO:aHeader,{|x|AllTrim(x[2])=="ZM1_DTREAL"}	)])
	//	If Empty(oDlgMO:aCols[oDlgMO:nAt][2])

	//	End
		
		oDlgMO:aCols[oDlgMO:nAt][len(oDlgMO:aHeader)+1]	:= 0
		If Empty(oDlgMO:aCols[oDlgMO:nAt][2])
			aadd(oDlgMO:aCols[oDlgMO:nAt],.F.)
		Endif
		
		oDlgMO:oBrowse:Refresh()
		//endif
	endif

Return lRet

//===================================
//       Altera็ใo
//===================================
Function LOCA075002 //fAltera()  //AxAltera
	fManu(4)
Return   



//==========================================
//     Localiza dentro do GRV o indice
//=========================================

Static Function Localiza(aArray,cNRAs)
	nPos:=ascan(aArray,{|x|AllTrim(x[1][1])==alltrim(cNRAs)})
	IF nPos > 0
		lAchou:=.T.
	ELSE
		lAchou:=.F.
	ENDIF
Return {lAchou, nPos }

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fCols2   บAutor  ณM&S Consultoria     บ Data ณ  30/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function fCols2(aHeader,cAlias,nIndice,cChave,cCondicao,cFiltro,nlc)
Local nPos,aCols0,aCols:={}
	DbSelectArea(cAlias)
	DbSetOrder(nIndice)
	If DbSeek(cChave)
		
		While (cAlias)->(!Eof()) .and. alltrim(cChave) == alltrim(xFilial("FPV")+FPV->FPV_AS+FPV->FPV_OBRA+FPV->FPV_PROJ+FPV->FPV_MAT+FPV->FPV_CONTRO)
			if !empty(cfiltro)
				If !(&cFiltro)
					(cAlias)->(DbSkip())
					Loop
				EndIf
			endif
			aCols0:={}
			For nPos:=1 to Len(aHeader)
				If !aHeader[nPos,10]=="V"  //x3_context
					(cAlias)->(AAdd(aCols0,FieldGet(FieldPos(aHeader[nPos,2]))))
				Else
					(cAlias)->(AAdd(aCols0,CriaVar(aHeader[nPos,2])))
				EndIf
			Next
			
			AAdd(aCols0,(cAlias)->(Recno())  )  //n๚mero do registro
			AAdd(aCols0,.F.  )  //Deleted
			AAdd(aCols,aCols0)
			(cAlias)->(DbSkip())
		EndDo
	Endif

	If Empty(aCols)
		aCols0:={}
		For nPos:=1 to Len(aHeader)
			(cAlias)->(AAdd(aCols0,CriaVar(aHeader[nPos,2])))
		Next

		aCols0[1] := cMat
		aCols0[7] := oDlgFro:aCols[oDlgFro:nat][11]
		AAdd(aCols0,0	 )  //n๚mero do registro
		AAdd(aCols0,.F.  )  //Deleted
		AAdd(aCols,aCols0)
	EndIf     

	If nlc > 0
		lAchou:=Localiza(aGrv,Alltrim(cNrAs)+Alltrim(oDlgFro:aCols[nlc][11]))[1]
		x :=Localiza(aGrv,Alltrim(cNrAs)+Alltrim(oDlgFro:aCols[nlc][11]))[2]
		
		IF lAchou
			oDlgMO:aCols:= aGrv[x][1][2]
		else
			nPosF1:= nlc
		//	oDlgMO:aCols[1][1]:= cNrAs  //ADICIONANADO INDICE   ==============================
			aadd(aColsTemp,{alltrim(oDlgFro:aCols[nlc][1])+Alltrim(oDlgFro:aCols[nlc][11])})
			aadd(aColsTemp[1],aCols)
			aadd( aGRV , aClone(aColsTemp) )
			//			aOnde := AClone(oDlgMo:aCols)
		endif
	Endif

Return(AClone(aCols))

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ  LINOK   บAutor  ณM&S Consultoria     บ Data ณ  30/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function LINOK()
Local nPosint := 0  
Local lPrimeira := .F.   
Local cNumContro	:= ""
Local nfx

	If OdLGFRO:ACOLS[oDlgFro:nat][11] = "99"                                                              
		For nfx := 01 to len(OdLGFRO:ACOLS)
			cNumContro := strzero(nfx,2)
			nPosgrv:=ascan(OdLGFRO:ACOLS,{|x|AllTrim(x[1])==ODLGFRO:ACOLS[oDlgFro:nAt][1] .and. x[11] == cNumContro })
			If nPosgrv = 0
				If lPrimeira = .F.
					lPrimeira := .T.
					cContro := cNumContro
				Endif
			Endif
		Next nfx
		OdLGFRO:ACOLS[oDlgFro:nat][11] := cContro  
		oDlgFro:Refresh()	
	Endif
	/*
	If !Empty(oDlgfro:aCols[oDlgFro:nAt][2])
		nPosint := Ascan(aIntOrig,{|x|AllTrim(x[1])== oDlgfro:aCols[oDlgFro:nAt][1] })
		If nPosint = 0
			MsgStop("A matricula "+ oDlgfro:aCols[oDlgFro:nAt][1] +" Linha "+Alltrim(str(oDlgFro:nAt))+" nใo pode ser usada nesse processo de integra็ao","Mensagem 300")
			Return(.F.)
		Else
			If aIntOrig[nPosint][9] = "1"
				If Valtype(ODLGFRO:ACOLS[oDlgFro:nAt][Len(ODLGFRO:ACOLS[oDlgFro:nAt])-1]) = "N" .and. valtype(aIntOrig[nPosint][Len(aIntOrig[nPosint])-1]) = "N"
					If ODLGFRO:ACOLS[oDlgFro:nAt][Len(ODLGFRO:ACOLS[oDlgFro:nAt])-1] = aIntOrig[nPosint][Len(aIntOrig[nPosint])-1]
						If ODLGFRO:ACOLS[oDlgFro:nAt][9] != "1"
							MsgStop("A matricula "+ ODLGFRO:ACOLS[oDlgFro:nAt][1] +", referente a linha "+ str(nPosint) +" da integra็ใo, ja estava definida como desistencia, portanto nใo poderแ ser alterada. Por favor altere o status da desistencia para prosseguir","Mensagem 301")
							Return
						Endif
					Endif
				Endif
			Endif
	*/
			If !Empty(oDlgfro:aCols[oDlgFro:nAt][4])   
				If oDlgfro:aCols[oDlgFro:nAt][3] > oDlgfro:aCols[oDlgFro:nAt][4]
					MsgStop(STR0021+ ODLGFRO:ACOLS[oDlgFro:nAt][1] +STR0024+Alltrim(str(oDlgFro:nAt))+STR0025,STR0026)  //"A data de inicio nใo pode ser maior que a data final da integra็ao. Por favor corrija a matricula "###" Linha "###"."###"Mensagem 304"
					Return
				Endif                              
			Endif
	//	ENDIF
	//Endif

Return(.T.)
 

//-------------------------------------------------------------
Function LOCA075003 //fIncMat()
Local cCod		:= Space(6)

    DEFINE MSDIALOG oDlgUser TITLE STR0027 FROM 000,000 TO 120,300 PIXEL OF oMainWnd //"Funcionแrio"
	
	@ 010,010 SAY STR0028 OF oDlgUser PIXEL 		 //"Informe a matricula do funcionario."
	@ 030,010 MSGET cCod F3 "SRAINT" SIZE 80,010 OF oDlgUser PIXEL
	@ 030,100 BUTTON STR0029 SIZE 35,14 PIXEL OF oDlgUser Action (Processa({|| GravaZM0(cCod) })) //"Confirmar"
			
	ACTIVATE MSDIALOG oDlgUser CENTERED  

Return  
 
Static Function GravaZM0(cCod)
Local cNome 	:= ""
Local aArea		:= GetArea()
Local aAreaSRA	:= SRA->(GetArea()) 
Local aAreaZM0	:= FPU->(GetArea())
   	 
   	DbSelectArea("SRA")
   	DbSetOrder(1)
   	If DbSeek(xFilial("SRA")+cCod)  
   		cNome := SRA->RA_NOME
   	EndIf                    


	DbSelectArea("FPU")
	FPU->(DBSETORDER(1))

	IF !FPU->(DBSEEK(XFILIAL("FPU")+FQ5->FQ5_AS+cCod))

		RecLock("FPU", .T.)
		FPU->FPU_FILIAL := xFilial("FPU") 
		FPU->FPU_AS 	:= FQ5->FQ5_AS
		FPU->FPU_OBRA 	:= FQ5->FQ5_OBRA
		FPU->FPU_PROJ 	:= FQ5->FQ5_SOT
		FPU->FPU_MAT 	:= cCod
		FPU->FPU_NOME 	:= cNome
		FPU->FPU_DTLIM  := FQ5->FQ5_DATINI    	
		FPU->FPU_DESIST := "2"
		FPU->FPU_CONTRO := "01"	
		FPU->FPU_CODCLI := FQ5->FQ5_CODCLI
		FPU->FPU_LOJCLI := FQ5->FQ5_LOJA	
		MsUnlock()

	ELSE

		MsgAlert("AS / MATRอCULA Jม EXISTENTE !!")

	ENDIF 
    
    oDlgUser:End() 
    
	RestArea(aAreaZM0)
	RestArea(aAreaSRA)
	RestArea(aArea)
Return

Function LOCA075004 //INTPROGV()
Local lRet 	:= .T.
Local dDatR 
Local dDatV
	
	If AllTrim(&(LOCXCONV(2))) == 'FPV_DATVLD'
		dDatR := oDlgMo:aCols[oDlgMo:nAt][Ascan(oDlgMo:aHeader,{|x|AllTrim(x[2])=="FPV_DTREAL" }	)]
		
		If DTOS(M->FPV_DATVLD) < DTOS(dDatR)
			MsgAlert(STR0030,STR0031) //"A data de validade deve ser maior ou igual que a data realizada"###"Aten็ใo"
			lRet := .F.
		EndIf	                                 
	ElseIf AllTrim(&(LOCXCONV(2))) == 'FPV_DTREAL'
		dDatV := oDlgMo:aCols[oDlgMo:nAt][Ascan(oDlgMo:aHeader,{|x|AllTrim(x[2])=="FPV_DATVLD" }	)]
		
		If DTOS(dDatV) < DTOS(M->FPV_DTREAL) .And. !Empty(dDatV)
			MsgAlert(STR0030,STR0031) //"A data de validade deve ser maior ou igual que a data realizada"###"Aten็ใo"
			lRet := .F.
		EndIf
	EndIf

Return(lRet)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ConTrei  บAutor  ณ Michel Taipina     บ Data ณ 05/04/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de Controle de Treinados                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function LOCA075006 //ConTrei()
Local   oZX1  
Private aRotina:={}
                     
	//Instaciamento
	oZX1 := FWMBrowse():New()       

	// ZX1 virou FQC

	//Tabela que serแ utilizada
	oZX1:SetAlias( "FQC" )

	//Titulo
	oZX1:SetDescription( STR0006 ) //"Controle de Treinados"

	//Filtro somente registros da AS posicionada
	oZX1:SetFilterDefault( "FQC_AS = FQ5->FQ5_AS " )

	oZX1:DisableDetails() 

	MenuDef2()

	//Ativa
	oZX1:Activate()

Return      

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ManuDef2  บAutor  ณ Michel Taipina     บ Data ณ 05/04/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Manuten็ใo de Controle de Treinados                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function MenuDef2()  

	aAdd( aRotina, { STR0003      , "AxVisual" , 0, 2, 0, NIL } ) //"Visualizar"
	aAdd( aRotina, { STR0032         , "AxInclui" , 0, 3, 0, NIL } ) //"Incluir"
	aAdd( aRotina, { STR0033         , "AxAltera" , 0, 4, 0, NIL } ) //"Alterar"
	aAdd( aRotina, { STR0034         , "AxDeleta" , 0, 5, 0, NIL } ) //"Excluir"
	//aAdd( aRotina, {"Gerar Certificado","U_GERACERT",0 , 4         } ) //Gera Certificado de Treinamento. Comentado por Cau๊ em 02/08/2016.

Return


// Rotina para grava็ใo da zm0 - fpu
Static FUNCTION GRAVZM0 (cMat,cObra,cProj,cAs,nX,cDesist,ldelZM0,cContro /*array ou variaveis.*/)
Local nJh
	DBSELECTAREA("FPU")
	FPU->(dbgotop())
	FPU->(DBSETORDER(2))// FPU_FILIAL+FPU_AS+FPU_OBRA+FPU_PROJ +FPU_MAT

	cObra	:=	PADR(cObra,LEN(FPU_OBRA))
	cProj	:=	PADR(cProj,LEN(FPU_PROJ))
	cAs		:=	PADR(cAs,LEN(FPU_AS))
	cMat	:= PADR(cMat,LEN(FPU_MAT))
	lAchou  := .F.
	cChaveDel := ""

	IF FPU->(!DBSEEK(xFilial('FPU')+Substr(cAs+space(27),1,27)+Substr(cObra+space(3),1,3)+Substr(cProj+space(22),1,22)+Substr(cMat+space(6),1,6)+Substr(cContro+space(2),1,2)))
		lInclui:=.T.
	ELSE
		lInclui:=.F.
	ENDIF

	If ldelZM0 = .F.
		RECLOCK("FPU",lInclui)
		FPU->FPU_FILIAL		:= XFILIAL("FPU")
		FPU->FPU_AS 		:= ALLTRIM(cAs)
		FPU->FPU_PROJ 		:= ALLTRIM(cProj)
		FPU->FPU_OBRA 		:= ALLTRIM(cObra)
		FPU->FPU_MAT 		:= ALLTRIM(cMat)
		FPU->FPU_NOME 		:= oDlgFro:aCols[nX][2]
		FPU->FPU_DTINI 		:= oDlgFro:aCols[nX][3]
		FPU->FPU_DTFIN 		:= oDlgFro:aCols[nX][4]
		FPU->FPU_QTDDIA		:= oDlgFro:aCols[nX][5]
		FPU->FPU_DTLIM 		:= oDlgFro:aCols[nX][6]
		FPU->FPU_VALID	 	:= oDlgFro:ACols[nX][7]
		FPU->FPU_CRACHA		:= oDlgFro:aCols[nX][8]
		FPU->FPU_DESIST		:= cDesist
		FPU->FPU_OBS		:= oDlgFro:aCols[nX][10]
		FPU->FPU_CONTRO		:= oDlgFro:aCols[nX][11] 
		FPU->FPU_CODCLI		:= oDlgFro:aCols[nX][12]
		FPU->FPU_LOJCLI		:= oDlgFro:aCols[nX][13]
		
		
			
		lAchou := Localiza(aGrv,Alltrim(CMAT)+Alltrim(oDlgFro:aCols[nX][11]))[1]
		
		If lAchou = .T.
			x :=Localiza(aGrv,Alltrim(CMAT)+Alltrim(oDlgFro:aCols[nX][11]))[2]

			dbselectarea("FPV")
			FPV->(DBSETORDER(4))
			If DBSEEK(xFilial('FPV')+Substr(cAs+space(30),1,30)+Substr(cObra+space(3),1,3)+Substr(cProj+space(15),1,15)+Substr(cMat+space(8),1,8)+Substr(cContro+space(2),1,2))
				While xFilial('FPV')+Substr(cAs+space(30),1,30)+Substr(cObra+space(3),1,3)+Substr(cProj+space(15),1,15)+Substr(cMat+space(8),1,8)+Substr(cContro+space(2),1,2) = FPV->FPV_FILIAL+FPV->FPV_AS+FPV->FPV_OBRA+FPV->FPV_PROJ+FPV->FPV_MAT+FPV->FPV_CONTRO
					RecLock("FPV",.F.)
					dbDelete()
					MsUnlock("FPV")
	//				FPV->(DBCLOSEAREA())
					FPV->(Dbskip())
				End
			Endif
			
			For nJh := 1 to len(aGrv[x][1][2])
				If !Empty(aGrv[x][1][2][nJh][2])
	//				If aGrv[x][1][2][nJh][7] = oDlgFro:aCols[nX][11]
						GRAVZM1(cMat,cObra,cProj,cAs,nJh, X,cContro)   
	//				Endif
				Endif
			Next
			
		Endif
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณValidacao das datas para grava็ใo na tabela ZLO ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !Empty(oDlgFro:aCols[nX][3])
			If cDesist != "1"
				If !Empty(oDlgFro:aCols[nX][4])
					If oDlgFro:aCols[nX][4] < oDlgFro:aCols[nX][6]  //Se a Data Fim da integra็ao for menor que a data limite
						nDif := (oDlgFro:aCols[nX][4] +1)  -  oDlgFro:aCols[nX][3]
						nDes := oDlgFro:aCols[nX][6]  -  oDlgFro:aCols[nX][4]
					Elseif oDlgFro:aCols[nX][4] = oDlgFro:aCols[nX][6] //Se a Data Fim da integra็ao for igual a data limite
						nDif := (oDlgFro:aCols[nX][6] +1)  -  oDlgFro:aCols[nX][3]
						nDes := 0
					Else //Se a Data Fim da integra็ao for Maior que a data limite
						nDif :=  (oDlgFro:aCols[nX][4] +1)  -  oDlgFro:aCols[nX][3]
						nDes := 0
					End
				Else
					If oDlgFro:aCols[nX][6] <  oDlgFro:aCols[nX][3]
						nDif := 0
						nDes := 0
					Else
						nDif := (oDlgFro:aCols[nX][6] +1) -  oDlgFro:aCols[nX][3]
						nDes := 0
					Endif
				End
			Else
				nDif := (oDlgFro:aCols[nX][4] +1)  -  oDlgFro:aCols[nX][3]
				nDes := oDlgFro:aCols[nX][6]  -  oDlgFro:aCols[nX][4]
			Endif
			
			IF nDif = 0 .and. nDes = 0
				MsgAlert("O processo de integra็ao esta atrasado para a matricula: " + cmat +" Linha "+Alltrim(str(nX)),"Aten็ao 1")   
				CadZLO(nDif,nDes,cDesist,oDlgFro:aCols[nX][3],oDlgFro:aCols[nX][4],oDlgFro:aCols[nX][6],oDlgFro:aCols[nX][11])
			else
				CadZLO(nDif,nDes,cDesist,oDlgFro:aCols[nX][3],oDlgFro:aCols[nX][4],oDlgFro:aCols[nX][6],oDlgFro:aCols[nX][11])
			endif
		Else
			CadZLO(0,0,cDesist,oDlgFro:aCols[nX][3],oDlgFro:aCols[nX][4],oDlgFro:aCols[nX][6],oDlgFro:aCols[nX][11])
		Endif
		
		MSUNLOCK('FPU')
		FPU->(DBCLOSEAREA())
	Else
		dbselectarea("FPV")
		FPV->(DBSETORDER(4))
		If DBSEEK(xFilial('FPV')+Substr(cAs+space(30),1,30)+Substr(cObra+space(3),1,3)+Substr(cProj+space(15),1,15)+Substr(cMat+space(8),1,8)+Substr(cContro+space(2),1,2))
			While xFilial('FPV')+Substr(cAs+space(30),1,30)+Substr(cObra+space(3),1,3)+Substr(cProj+space(15),1,15)+Substr(cMat+space(8),1,8)+Substr(cContro+space(2),1,2) = FPV->FPV_FILIAL+FPV->FPV_AS+FPV->FPV_OBRA+FPV->FPV_PROJ+FPV->FPV_MAT+FPV->FPV_CONTRO
				RecLock("FPV",.F.)
				dbDelete()
				MsUnlock("FPV")
	//			FPV->(DBCLOSEAREA())
				FPV->(Dbskip())
			End
		Endif
		
		/*
		DbSelectArea("FPQ")
		DbSetOrder(1)
		//	cQuery += " AND ZLO_STATUS = 'INTEGR'"
		//	cQuery += " AND ZLO_DATA NOT BETWEEN '"+DtoS(cdataini)+"' AND '"+DtoS(cdatafim)+"'"
		
		cQuery := " Select * FROM  " + RetSqlName("FPQ") + " FPQ"
		cQuery += " WHERE FPQ_FILIAL = '"+xFilial("FPQ")+"'"
		cQuery += " AND FPQ_AS = '"+cAs+"'"
		cQuery += " AND FPQ_PROJET = '"+cProj+"'"
		cQuery += " AND FPQ_OBRA = '"+cObra+"'"
		cQuery += " AND FPQ_MAT = '"+cMat+"'"  
		cQuery += " AND FPQ_STATUS = 'INTEGR'"   
		cQuery += " AND FPQ_CONTRO = '"+cContro+"'"  
		cQuery += " AND D_E_L_E_T_ = ''"
		cQuery += " ORDER BY FPQ_DATA"
		cQuery := ChangeQuery(cQuery)
		MsAguarde( { || dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"TRBZLO",.T.,.T.)},"Aguarde... Processando Dados...")
		
		DbSelectArea("TRBZLO")
		While !Eof()
			cChaveDel := TRBZLO->FPQ_MAT+TRBZLO->FPQ_DATA
			DbSelectArea("FPQ")
			dbsetorder(1)
			If DbSeek(xFilial("FPQ")+cChaveDel+	cContro)
				If FPQ_AS+FPQ_PROJET+FPQ_OBRA+FPQ_MAT == TRBZLO->FPQ_AS+TRBZLO->FPQ_PROJET+TRBZLO->FPQ_OBRA+TRBZLO->FPQ_MAT
					If FPQ_TIPINC = "A"
						RecLock("FPQ",.F.)
						dbDelete()
						MsUnlock("FPQ")
					Endif
				Endif
			Endif
			TRBZLO->(dbSkip())
		End
		
		TRBZLO->(DbCloseArea())
		*/
	Endif

RETURN

//===============================================
Static FUNCTION GRAVZM1(cMat,cObra,cProj,cAs,nX, X,	cContro)
Local Ldeleta := .F.

	dbselectarea("FPV")
	FPV->(dbgotop())
	FPV->(DBSETORDER(4)) //FPV_FILIAL+FPV_AS+FPV_OBRA+FPV_PROJ+FPV_MAT+Cod

	//For nJh := 1 to Len(oDlgMO:aCols)
	If !Empty(aGrv[x][1][2][nX][2])
		cMat := aGrv[x][1][2][nX][1]   //PADR(cMat,LEN(FPV_MAT)) // MATRICULA                  - bUSCAR DE OdLGmO:AcOLS
		cCod := aGrv[x][1][2][nX][2]   //ALLTRIM(aGrv[X][1][2][NX][2]) //CODIGO DO PROCESSO    - bUSCAR DE OdLGmO:AcOLS
		
		cObra:=PADR(cObra,LEN(FPV_OBRA))
		cProj:= PADR(cProj,LEN(FPV_PROJ))
		cAs:=PADR(cAs,LEN(FPV_AS))
		cCod:=PADR(cCod, Len(FPV_CODPRO))
		
		
		IF FPV->(!DBSEEK(xFilial('FPV')+Substr(cAs+space(30),1,30)+Substr(cObra+space(3),1,3)+Substr(cProj+space(15),1,15)+Substr(cMat+space(8),1,8)+Substr(cContro+space(2),1,2)+Substr(cCod+space(8),1,8)))
			lInclui:=.t.
		ELSE
			lInclui:= .f.
		ENDIF
		
		//	For nB := 1 to len(aGrv[X][1][2][NX])
		//fAZ CONTAGEM DO TAMANHO DE COLUNAS DO ARRAY
		//	Next
		
		//	nB := nB -1
		
		Ldeleta := .F.
		//For nA := 1 to nB
		If aGrv[x][1][2][nX][len(aGrv[x][1][2][nX])]  = .T. //aGrv[X][1][2][NX][nB] = .T.
			Ldeleta := .T.
		Endif
		//Next
		
		If Ldeleta = .F.
			RECLOCK("FPV",lInclui)
			
			FPV->FPV_FILIAL	:= XFILIAL("FPV")
			FPV->FPV_AS 		:= ALLTRIM(cAs)
			FPV->FPV_PROJ 		:= ALLTRIM(cProj)
			FPV->FPV_OBRA		:= ALLTRIM(cObra)
			FPV->FPV_MAT	 	:= ALLTRIM(cMat)
			FPV->FPV_CODPRO 	:= cCod
			FPV->FPV_DESCRI 	:= ALLTRIM(aGrv[x][1][2][nX][3]) //verificar posicao
			FPV->FPV_OBS 		:= aGrv[x][1][2][nX][4]   //verificar posicao
			FPV->FPV_DTPREV 	:= aGrv[x][1][2][nX][5]  //verificar posicao
			FPV->FPV_DTREAL 	:= aGrv[x][1][2][nX][6]  //verificar posicao
			FPV->FPV_CONTRO 	:= cContro  //aGrv[x][1][2][nX][7]
			FPV->FPV_DATVLD 	:= aGrv[x][1][2][nX][8]
			
			
			MSUNLOCK('FPV')
	/*	Else
			dbselectarea("FPV")
			FPV->(DBSETORDER(4))
			If DBSEEK(xFilial('FPV')+Substr(cAs+space(30),1,30)+Substr(cObra+space(3),1,3)+Substr(cProj+space(15),1,15)+Substr(cMat+space(8),1,8)+Substr(cContro+space(2),1,2)+Substr(cCod+space(2),1,2))
				RecLock("FPV",.F.)
				dbDelete()
				MsUnlock("FPV")
			Endif   */
		Endif
	Endif

	FPV->(DBCLOSEAREA())

RETURN



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCADZLO    บAutor  ณM&S Consultoria     บ Data ณ  30/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function CadZLO (nReg,nDes,cDesist,cdatini,cdatfim,cdatlimite,ccontro)//(nReg,nDes,cDesist,oDlgFro:aCols[nX][3],oDlgFro:aCols[nX][4])
Local n, nY
Private cALIAS   	:= "FPQ"
Private lINCLUI  	:= .F.
Private cData    	:= FPU->FPU_DTINI
Private cMat     	:= FPU->FPU_MAT
Private cDtqini		:= DTQ->DTQ_DATINI
Private cDtqFim		:= DTQ->DTQ_DATFIM
Private cFolMes		:= GETMV("MV_FOLMES")
Private cDataFol  	:= Substr(DTOS(cData),1,6)
Private cProjeto 	:= FPU->FPU_PROJ
Private cAs			:= FPU->FPU_AS
Private cObra		:= FPU->FPU_OBRA
Private cdataini	:= cdatini
Private cdatafim	:= cdatfim
Private cdatalimite	:= cdatlimite
Private cControl	:= ccontro

	FOR N:= 1 TO nREG
		
		If N > 1
			cData := cData + 1
			cDataFol := Substr(DTOS(cData),1,6)
		Endif
		
		IF cDataFol >= cFolmes
			
			cChave := cmat+DTOS(cDATA)
			
			DbSelectArea("FPQ")
			dbsetorder(1)
			If DbSeek(xFilial("FPQ")+cChave+ccontrol)
				lINCLUI:= .F. //Altera
			Else
				If DbSeek(xFilial("FPQ")+cChave)
					lINCLUI:= .F. //Altera
				Else
					lINCLUI:= .T. //Inclui			
				Endif
			Endif
			
			If lINCLUI = .F.
				If FPQ->FPQ_TIPINC = "A"
					RECLOCK("FPQ", .F.)
					FPQ->FPQ_FILIAL		:= xFilial("FPQ")
					FPQ->FPQ_MAT		:= FPU->FPU_MAT
					FPQ->FPQ_DATA		:= cData
					FPQ->FPQ_STATUS  	:= "000005"
					FPQ->FPQ_VT			:= "N"
					FPQ->FPQ_AS			:= FPU->FPU_AS
					FPQ->FPQ_PROJET		:= FPU->FPU_PROJ
					FPQ->FPQ_OBRA		:= FPU->FPU_OBRA
					FPQ->FPQ_DESC		:= ""
					FPQ->FPQ_HORAS		:= 0
					FPQ->FPQ_OBS		:= ""
					FPQ->FPQ_USERGI		:= ""
					FPQ->FPQ_USERGA		:= ""
					FPQ->FPQ_FIND		:= ""
					FPQ->FPQ_FILAUX		:= ""
					FPQ->FPQ_AGENDA		:= "2"
					FPQ->FPQ_SERVIC		:= ""
					FPQ->FPQ_HRINI		:= "0"
					FPQ->FPQ_HRFIN		:= "0"
					FPQ->FPQ_FILMAT		:= "  "
					FPQ->FPQ_TIPINC		:= "A"
					FPQ->FPQ_CONTRO		:= ccontrol
					MSUNLOCK("FPQ")
					dbCommitAll()
				End
			Else
				RECLOCK("FPQ", .T.)
				FPQ->FPQ_FILIAL		:= xFilial("FPQ")
				FPQ->FPQ_MAT		:= FPU->FPU_MAT
				FPQ->FPQ_DATA		:= cData
				FPQ->FPQ_STATUS		:= "000005"
				FPQ->FPQ_VT			:= "N"
				FPQ->FPQ_AS			:= FPU->FPU_AS
				FPQ->FPQ_PROJET		:= FPU->FPU_PROJ
				FPQ->FPQ_OBRA		:= FPU->FPU_OBRA
				FPQ->FPQ_DESC		:= ""
				FPQ->FPQ_HORAS		:= 0
				FPQ->FPQ_OBS		:= ""
				FPQ->FPQ_USERGI		:= ""
				FPQ->FPQ_USERGA		:= ""
				FPQ->FPQ_FIND		:= ""
				FPQ->FPQ_FILAUX		:= ""
				FPQ->FPQ_AGENDA		:= "2"
				FPQ->FPQ_SERVIC		:= ""
				FPQ->FPQ_HRINI		:= "0"
				FPQ->FPQ_HRFIN		:= "0"
				FPQ->FPQ_FILMAT		:= "  "
				FPQ->FPQ_TIPINC		:= "A"
				FPQ->FPQ_CONTRO		:= ccontrol
				MSUNLOCK("FPQ")
				dbCommitAll()
			End
		Endif
	NEXT

	If nDes > 0  //tratamento para os dias de diferenca entre data fim e data limite
		cDataLim   := FPU->FPU_DTLIM + 1
		cChaveObra := cmat+DTOS(cDataLim)
		
		DbSelectArea("FPQ")
		dbsetorder(1)
		If cDesist != "1"   //Verifica se houve desistencia
			If DbSeek(xFilial("FPQ")+cChaveObra+ccontrol)  //Verifica se o registro ja existe uma dia depois da data limite
				If FPQ_AS+FPQ_PROJET+FPQ_OBRA+ALLTRIM(FPQ_STATUS) == FPU->FPU_AS+FPU->FPU_PROJ+FPU->FPU_OBRA+"000004"  //Verifica se o registro pertence a mesma OBRA/PROJETO
					For nY:= 1 TO nDes
						cData := cData + 1
						cChave := cmat+DTOS(cDATA)
						
						IF cDataFol >= cFolmes
							DbSelectArea("FPQ")
							dbsetorder(1)
							If DbSeek(xFilial("FPQ")+cChave+ccontrol)  //Reposiciona no registro
								lINCLUI:= .F. //Altera
							Else
								If DbSeek(xFilial("FPQ")+cChave)
									lINCLUI:= .F. //Altera
								Else
									lINCLUI:= .T. //Inclui			
								Endif
							Endif                    

							If cData >= cDTQINI .and. cData <= cDTQFIM  //So altera oa registros que estiverem dentro do Range
								If lINCLUI = .F.  //Verifica se altera็ao
									If FPQ->FPQ_TIPINC = "A"  //Verifica se e inclusao Manual ou automatica  - Se for Manual Pula
										If FPQ_AS+FPQ_PROJET+FPQ_OBRA == FPU->FPU_AS+FPU->FPU_PROJ+FPU->FPU_OBRA
											RECLOCK("FPQ", .F.)
											FPQ->FPQ_FILIAL  	:= xFilial("FPQ")
											FPQ->FPQ_MAT  	 	:= FPU->FPU_MAT
											FPQ->FPQ_DATA  	 	:= cData
											FPQ->FPQ_STATUS  	:= "000004"
											FPQ->FPQ_VT 	 	:= "N"
											FPQ->FPQ_AS  	 	:= FPU->FPU_AS
											FPQ->FPQ_PROJET  	:= FPU->FPU_PROJ
											FPQ->FPQ_OBRA  	 	:= FPU->FPU_OBRA
											FPQ->FPQ_DESC  	 	:= ""
											FPQ->FPQ_HORAS   	:= 0
											FPQ->FPQ_OBS     	:= ""
											FPQ->FPQ_USERGI  	:= ""
											FPQ->FPQ_USERGA  	:= ""
											FPQ->FPQ_FIND  	 	:= ""
											FPQ->FPQ_FILAUX  	:= ""
											FPQ->FPQ_AGENDA  	:= "2"
											FPQ->FPQ_SERVIC  	:= ""
											FPQ->FPQ_HRINI   	:= "0"
											FPQ->FPQ_HRFIN   	:= "0"
											FPQ->FPQ_FILMAT  	:= "  "
											FPQ->FPQ_TIPINC  	:= "A"
											FPQ->FPQ_CONTRO		:= ccontrol
											MSUNLOCK("FPQ")
											dbCommitAll()
										Endif
									End
								Else
									//Inclusao de registro inexistente
									RECLOCK("FPQ", .T.)
									FPQ->FPQ_FILIAL  := xFilial("FPQ")
									FPQ->FPQ_MAT  	 := FPU->FPU_MAT
									FPQ->FPQ_DATA  	 := cData
									FPQ->FPQ_STATUS  := "000004"
									FPQ->FPQ_VT 	 := "N"
									FPQ->FPQ_AS  	 := FPU->FPU_AS
									FPQ->FPQ_PROJET  := FPU->FPU_PROJ
									FPQ->FPQ_OBRA  	 := FPU->FPU_OBRA
									FPQ->FPQ_DESC  	 := ""
									FPQ->FPQ_HORAS   := 0
									FPQ->FPQ_OBS     := ""
									FPQ->FPQ_USERGI  := ""
									FPQ->FPQ_USERGA  := ""
									FPQ->FPQ_FIND  	 := ""
									FPQ->FPQ_FILAUX  := ""
									FPQ->FPQ_AGENDA  := "2"
									FPQ->FPQ_SERVIC  := ""
									FPQ->FPQ_HRINI   := "0"
									FPQ->FPQ_HRFIN   := "0"
									FPQ->FPQ_FILMAT  := "  "
									FPQ->FPQ_TIPINC  := "A"
									FPQ->FPQ_CONTRO		:= ccontrol
									MSUNLOCK("FPQ")
									dbCommitAll()
								End
							Else
								//Se estiver fora da data do Projeto DTQ, deleta os registros
								DbSelectArea("FPQ")
								dbsetorder(1)
								If DbSeek(xFilial("FPQ")+cChave+ccontrol)  //Reposiciona no registro
									If FPQ_AS+FPQ_PROJET+FPQ_OBRA == FPU->FPU_AS+FPU->FPU_PROJ+FPU->FPU_OBRA
										If FPQ_TIPINC = "A"
											RecLock("FPQ",.F.)
											dbDelete()
											MsUnlock("FPQ")
										Endif
									Endif
								Else
									If DbSeek(xFilial("FPQ")+cChave)
										If FPQ_AS+FPQ_PROJET+FPQ_OBRA == FPU->FPU_AS+FPU->FPU_PROJ+FPU->FPU_OBRA
											If FPQ_TIPINC = "A"
												RecLock("FPQ",.F.)
												dbDelete()
												MsUnlock("FPQ")
											Endif
										Endif
									Endif
								Endif
							Endif
						Endif
					Next
				Else
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณDeleta registros a mais quando nao ha OBRA depois da data limiteณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					Deleta()
				End
			Else
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณDeleta registros a mais quando nao ha mais registros depois da data limiteณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				Deleta()
			Endif
		Else
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณDeleta registros a mais quando houve desistenciaณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Deleta()
		Endif
	Else
		Deleta()
	Endif
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Deleta   บAutor  ณM&S Consultoria     บ Data ณ  30/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Deleta registros de integra็ao que nao estใo dentro do     บฑฑ
ฑฑบ          ณ periodo de integracao                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function Deleta()

Local lGeraZlo := .F.
Local lApagaInt	:= .F.

	DbSelectArea("FPQ")
	DbSetOrder(1)

	If !Empty(cdataini) .and. Empty(cdatafim) .and. Empty(cdatalimite) //Data Inicio preenchida      1
		lGeraZlo := .F.
		lApagaInt	:= .T.
	Elseif Empty(cdataini) .and. !Empty(cdatafim) .and. Empty(cdatalimite) //Data Fim preenchida     2
		lGeraZlo := .F.
		lApagaInt	:= .T.
	Elseif Empty(cdataini) .and. Empty(cdatafim) .and. !Empty(cdatalimite) //Data Limite preenchida     3
		lGeraZlo := .F.
		lApagaInt	:= .T.
	Elseif !Empty(cdataini) .and. !Empty(cdatafim) .and. Empty(cdatalimite) //Data Inicio e Fim preenchidas   4
		lGeraZlo := .T.
		lApagaInt	:= .T.
	Elseif !Empty(cdataini) .and. !Empty(cdatafim) .and. !Empty(cdatalimite) //Todas as Datas preenchidas     5
		lGeraZlo := .T.
		lApagaInt	:= .T.
	Elseif !Empty(cdataini) .and. Empty(cdatafim) .and. !Empty(cdatalimite) //Data Inicio e Limite preenchidas			7
		If cdataini < cdatalimite
			lGeraZlo := .T.
			lApagaInt	:= .T.
		Else
			lGeraZlo := .F.
			lApagaInt	:= .T.
		Endif
	Endif

	If 	lApagaInt = .T.  // Deleta os registros	
		cQuery := " Select * FROM  " + RetSqlName("FPQ") + " FPQ"
		cQuery += " WHERE FPQ_FILIAL = '"+xFilial("FPQ")+"'"
		cQuery += " AND FPQ_AS = '"+cAs+"'"
		cQuery += " AND FPQ_PROJET = '"+cProjeto+"'"
		cQuery += " AND FPQ_OBRA = '"+cObra+"'"
		cQuery += " AND FPQ_STATUS = '000005'"
		cQuery += " AND FPQ_MAT = '"+cMat+"'"
		cQuery += " AND (FPQ_CONTRO = '"+cControl+"'" + " OR FPQ_CONTRO = '')"
		If !Empty(cdatafim) .and. !Empty(cdataini)
			cQuery += " AND FPQ_DATA NOT BETWEEN '"+DtoS(cdataini)+"' AND '"+DtoS(cdatafim)+"'"
		Elseif !Empty(cdatalimite) .and. !Empty(cdataini)
			cQuery += " AND FPQ_DATA NOT BETWEEN '"+DtoS(cdataini)+"' AND '"+DtoS(cdatalimite)+"'"
		Endif
		cQuery += " AND D_E_L_E_T_ = ''"
		cQuery += " ORDER BY FPQ_DATA"
		cQuery := ChangeQuery(cQuery)
		MsAguarde( { || dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"TRBZLO",.T.,.T.)},"Aguarde... Processando Dados...")
		
		DbSelectArea("TRBZLO")
		While !Eof()
			cChaveDel := TRBZLO->FPQ_MAT+TRBZLO->FPQ_DATA
			DbSelectArea("FPQ")
			dbsetorder(1)
			If DbSeek(xFilial("FPQ")+cChaveDel+ccontrol)
				If FPQ_AS+FPQ_PROJET+FPQ_OBRA+ALLTRIM(FPQ_STATUS) == TRBZLO->FPQ_AS+TRBZLO->FPQ_PROJET+TRBZLO->FPQ_OBRA+alltrim(TRBZLO->FPQ_STATUS)
					If FPQ_TIPINC = "A"
						RecLock("FPQ",.F.)
						dbDelete()
						MsUnlock("FPQ")
					Endif
				End
			Endif
			TRBZLO->(dbSkip())
		End
		
		TRBZLO->(DbCloseArea())
	Endif
        
Return



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Deleta   บAutor  ณM&S Consultoria     บ Data ณ  30/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Filtra usuแrio pelo centro de custo cadastrado na  rotina  บฑฑ
ฑฑบ          ณ Usuแrio x Rotina x C/c                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Function UsrVRot()

LOCAL _CUSER	:= RETCODUSR(SUBSTR(CUSUARIO,7,15))  //RETORNA O CำDIGO DO USUมRIO
LOCAL aAreaSRA	:= GetArea()
LOCAL LRET		:= .F.
LOCAL cFilSRA 	:= ""

	IF FQ1->(DBSEEK(XFILIAL("FQ1") + _CUSER + "LOCA075",.T.)) 	// PROCURA O CำDIGO DE USUมRIO NA TABELA DE USUมRIOS ANALIZADORES DE PROMOวีES (SZ5)
		//_CCC := FQ1->FQ1_CC

		IF !SRA->(EOF())

			cFilSRA := "RA_CC = '"+FQ1->FQ1_CC+"' "

			DBSELECTAREA("SRA")
			DBSETORDER(1)
			dbclearFilter()
			dbSetFilter( {|| &cFilSRA }, cFilSRA )

			//SRA->(DBSETFILter({|| alltrim(FQ1->FQ1_CC) == alltrim(SRA->RA_CC) },"alltrim(FQ1->FQ1_CC) == alltrim(SRA->RA_CC)"))
			DBGOTOP()
	
		ENDIF

		/*dbSelectArea("SE2")
		dbSetOrder(1)//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
		dbSetFilter( {|| &cFilSE2 }, cFilSE2 )
		dbGotop()*/
	

		LRET	:= .T. 

	ELSE
		MSGALERT(STR0002 , STR0003)  //"ATENวรO: SOMENTE USUมRIOS PRษ-CADASTRADOS PODEM EFETUAR ESSE LANวAMENTO."###"GPO - LOCT053.PRW"
	ENDIF	
	
	RestArea(aAreaSRA)

Return(LRET)


// Frank Z Fuga - 29/08/22
// Gatilho dos campos FPU_DTINI e FPU_DTFIN
Function LOCA075A
Local nQtd := 0
Local dDtIni := oDlgFro:ACOLS[oDlgFro:NAT][ASCAN(oDlgFro:AHEADER,{|X|ALLTRIM(X[2])=="FPU_DTINI"})]
Local dDtFim := oDlgFro:ACOLS[oDlgFro:NAT][ASCAN(oDlgFro:AHEADER,{|X|ALLTRIM(X[2])=="FPU_DTFIN"})]
	If !empty(dDtIni) .and. !empty(dDtFim)
		nQtd := (dDtFim- dDtIni) + 1
	EndIF
Return nQtd
