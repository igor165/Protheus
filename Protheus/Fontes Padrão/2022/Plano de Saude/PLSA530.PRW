#include "PLSMGER.CH"
#include "PROTHEUS.CH"
STATIC oBrwBXA := nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA530 ³ Autor ³ Eduardo Motta          ³ Data ³ 03.09.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Entrevista Qualificada                                     ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA530()
PRIVATE aRotina   := MenuDef()
PRIVATE cCadastro := Fundesc() //"Entrevista Qualificada"

oBrwBXA := FWmBrowse():New()
oBrwBXA:SetAlias( 'BXA' )
oBrwBXA:SetDescription( cCadastro )

oBrwBXA:Activate()

//mBrowse(06,01,22,75,'BXA')
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal...                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA530Mov ³ Autor ³ Eduardo Motta      ³ Data ³ 03.09.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Manutencao da entrevista qualificada                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PLSA530Mov(cAlias,nReg,nOpc)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA530                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA530Mov(cAlias,nReg,nOpc,lBA3,nRegBA3,aRegsBA1)
Local nCnt
Local aCabBXC := {}
Local aDadBXC := {}
Local aTrbBXC := {}
Local aChave
Local nOpcEnc
Local oDlg
Local aHeadPer := {}
Local aColsPer := {}
Local aVetPer  := {}
Local cSvTipReg
Local nOpcao
Local cCpoPer := "BXB_TIPREG/BXB_CODQUE/BXB_PROQUE/BXB_CODPER/BXB_CODRES/BXB_DESRES/BXB_DESCOM"
Local cTxtBut := "Responder"
Local oBut
Local bEdit := {||(ResQuest(M->BXA_CODQUE,M->BXA_PROQUE,aHeadPer,aColsPer,aVetPer,nOpc,lAuditoria))}
Local nOpcOri := nOpc
Local aCopCols
Local lRet := NIL
Local cMatVid
Local bOk		:= {|| if( P530TudoOk(nOpcEnc),Eval( {|| nOpcao:=1,oDlg:End()} ) ,.F.)}
Local bCancel   := {||nOpcao:=0,oDlg:End()}
Local aArea		:= GetArea()
Local aAreaBA1	:= BA1->(GetArea())
Local aVetTrab	:= {}

Private aCabBXD := {}
Private aDadBXD := {}
Private aTrbBXD := {}
Private oGetBCX
Private n := 1
Private cTipReg := Space(02)
Private INCLUI := (nOpc==3)
Private lAuditoria := (nOpc==6)
Private oEncBXA
Private aObjResp := {}
PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
DEFAULT aRegsBA1 := {}

nOpcEnc := nOpc

BAM->(dbSetOrder(1))

If 	Empty(GetNewPar("MV_PLSQUEU","0001")) .Or.;
	(!BAM->(dbSeek(xFilial("BAM")+"1"+GetNewPar("MV_PLSQUEU","0001"))) .And.;
	!BAM->(dbSeek(xFilial("BAM")+"2"+GetNewPar("MV_PLSQUEU","0001"))))

	Aviso("Atenção","Conteúdo do parâmetro MV_PLSQUEU está inválido: '"+GetNewPar("MV_PLSQUEU","0001")+"'",{"Ok"},3,"Informe um questionário válido no parâmetro")
	Return .F.

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ So sera possivel continuar se a base estiver atualizada...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If BXA->( FieldPos("BXA_USUARI") )  == 0
	MsgStop("Campo BXA_USUARI nao existe na base, nao sera possivel utilizar a entrevista qualificada! Atualize a versao do sistema.")

Elseif BXC->( FieldPos("BXC_USUARI") )  == 0
	MsgStop("Campo BXC_USUARI nao existe na base, nao sera possivel utilizar a entrevista qualificada! Atualize a versao do sistema.")

Endif

lBA3 := If(ValType(lBA3)#"L",.F.,lBA3)
If lBA3
   BA3->(DbGoto(nRegBA3))
EndIf

If lAuditoria
   nOpc := 2
   nOpcEnc := 4
   cCpoPer+="/BXB_COMMED"
   cTxtBut := "Auditar"
Elseif FunName() $ "PLSA094B/PLSA094D/PLSA094A/PLSA094C/PLSA001/PLSA092"
	cTxtBut:= "Visualizar"
EndIf

RegToMemory("BXA",nOpc==K_Incluir)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a GetDados do Folder Usuarios                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BXC" TO aCabBXC For (.T.)

BXC->(DbSetOrder(1))
If nOpc == K_Incluir .or. !BXC->(MsSeek(xFilial("BXC")+BXA->BXA_NUMERO))
	Store COLS Blank "BXC" TO aDadBXC FROM aCabBXC
Else
	If BXC->(MsSeek(xFilial("BXC")+BXA->BXA_NUMERO))
		Store COLS "BXC" TO aDadBXC FROM aCabBXC VETTRAB aVetTrab While BXC->(BXC_FILIAL+BXC_NUMERO) == xFilial("BXC")+BXA->BXA_NUMERO
	EndIf	
Endif

If lBA3

	aCopCols := aClone(aDadBXC[1])

	// Zera matriz se for modo inclusão.
	If nOpc == K_Incluir .or. ! BXC->(DbSeek(xFilial("BXC")+BXA->BXA_NUMERO))
		aDadBXC  := {}
		aTrbBXC  := {}
	Endif

	BA1->(DbSetOrder(2))
	BA1->(DbSeek(xFilial("BA1")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC))
	
	//quando se excluía alguém da família, e tentava se inserir alguém na mesma família, o sistema não carregava nome e número para a entrevista qualificada
	If Empty(M->BXA_NUMERO)
		M->BXA_NUMERO := GETSX8NUM('BXA','BXA_NUMERO')
	EndIf

		M->BXA_USUARI := BA1->(BA1_CODINT+BA1->BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1->BA1_DIGITO)
		M->BXA_NOMUSR := Posicione("BA1",2,xFilial("BA1")+M->BXA_USUARI,"BA1_NOMUSR")

		M->BXA_DATA   := dDataBase
		M->BXA_CODQUE := GetNewPar("MV_PLSQUEU","0001")  // CODIGO DO QUESTIONARIO PARA DECLARACAO DE SAUDE
		M->BXA_PROQUE := "2"
		M->BXA_DESQUE := Posicione("BAM",1,xFilial("BAM")+M->BXA_PROQUE+M->BXA_CODQUE,"BAM_DESCRI")
		nPos := 0

		While BA1->(!Eof()) .and. xFilial("BA1")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC == BA1->BA1_FILIAL+BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC

			If Len(aDadBXC) > 0
				nPos := Ascan(aDadBXC, {|x| x[3] == (BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+BA1->BA1_TIPREG+BA1->BA1_DIGITO)})
			Else
				nPos := 0
			Endif

			If nPos == 0
				aadd(aDadBXC,aClone(aCopCols))
				aadd(aTrbBXC,0)

				GDFieldPut("BXC_TIPREG",StrZero(Len(aDadBXC),2),Len(aDadBXC),aCabBXC,aDadBXC)
				GDFieldPut("BXC_USUARI",BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),Len(aDadBXC),aCabBXC,aDadBXC)
				GDFieldPut("BXC_NOMUSR",BA1->BA1_NOMUSR,Len(aDadBXC),aCabBXC,aDadBXC)
				If BXC->(FieldPos("BXC_MATVID")) > 0
	  			   GDFieldPut("BXC_MATVID",BA1->BA1_MATVID,Len(aDadBXC),aCabBXC,aDadBXC)
				EndIf
			Endif

			BA1->(DbSkip())
		EndDo
	
		RestArea(aAreaBA1)

		If Len(aDadBXC) == 0
			aadd(aDadBXC,aClone(aCopCols))
			aadd(aTrbBXC,0)
		EndIf
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a GetDados do Folder Usuarios                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BXD" TO aCabBXD For (.T.)

BXD->(DbSetOrder(1))
If nOpc == K_Incluir .or. ! BXD->(DbSeek(xFilial("BXD")+BXA->BXA_NUMERO))
	Store COLS Blank "BXD" TO aDadBXD FROM aCabBXD
Else
	Store COLS "BXD" TO aDadBXD FROM aCabBXD VETTRAB aTrbBXD While xFilial("BXD")+BXA->BXA_NUMERO == BXD->(BXD_FILIAL+BXD_NUMERO)
Endif


aSize := MsAdvSize()
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .F., .F. } )
AAdd( aObjects, { 100, 150, .T., .F., .F. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

SetEnch("")
DEFINE MSDIALOG oDlg TITLE cCadastro+" - "+StrTran(aRotina[nOpcOri,1],"&","") FROM aSize[7],aSize[1] To aSize[6],aSize[5] OF oMainWnd PIXEL

oEncBXA := BXA->(MsMGet():New("BXA",nReg,nOpcEnc,,,,,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,,,,,oDlg,,,.F.))

//quando se excluía alguém da família, e tentava se inserir alguém na mesma família, o sistema não carregava nome e número para a entrevista qualificada
If lBA3 .And. Empty(M->BXA_NOMUSR) 
	M->BXA_NOMUSR := Posicione("BA1",2,xFilial("BA1")+M->BXA_USUARI,"BA1_NOMUSR")
EndIf
		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ AVALIACAO                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oGetBXC           := TPLSBrw():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,4],aPosObj[2,3],nil  ,oDlg,nil    , If(lAuditoria,bEdit,NIL) ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabBXC,aDadBXC,.F.,"BXC",nOpc,"Beneficiarios da Entrevista",nil,nil,nil,aTrbBXC,,,)
oGetBXC:bLostFocus := {||cTipReg := oGetBXC:aCols[oGetBXC:Linha(),oGetBXC:FieldPos("BXC_TIPREG",aCabBXC)]}
oGetBXC:bChange    := {||cTipReg := oGetBXC:aCols[oGetBXC:Linha(),oGetBXC:FieldPos("BXC_TIPREG",aCabBXC)]}
If nOpc == 3 .or. nOpc == 4
   oGetBXC:oBrowse:bDelOk := {||oGetBXC:Linha()#1}
EndIf
If !lAuditoria
   @ aPosObj[2,3]+8,aPosObj[2,2] BUTTON oBut Prompt cTxtBut  SIZE 50,13 ACTION Eval(bEdit) Pixel OF oDlg
Else
   @ aPosObj[2,3]+8,aPosObj[2,2] BUTTON oBut Prompt "CID"  SIZE 50,13 ACTION PL530CID(aCabBXD,@aDadBXD,aTrbBXD,4) Pixel OF oDlg
EndIf

Store Header "BXB" to aHeadPer For AllTrim(SX3->X3_CAMPO)$ cCpoPer
DbSelectArea("BXB")
DbSetOrder(1)
If nOpc # K_Incluir .and. DbSeek(xFilial("BXB")+M->BXA_NUMERO)
   Store COLS "BXB" TO aColsPer FROM aHeadPer VETTRAB aVetPer While xFilial("BXB")+M->BXA_NUMERO == BXB->(BXB_FILIAL+BXB_NUMERO)
Else
   n := 1
   cSvTipReg := cTipReg
   cTipReg := Space(02)
   Store COLS Blank "BXB" TO aColsPer FROM aHeadPer
   cTipReg := cSvTipReg
EndIf

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk,bCancel,.F.,{}),If(lBA3,Eval(oBut:bAction),.T.))

If nOpcao == 1 // gravar

	Begin transaction
	If !lAuditoria
		PLUPTENC("BXA",nOpc)

		aChave := {}
		aadd(aChave,{"BXC_NUMERO",M->BXA_NUMERO})
		If nOPC == K_Alterar
			GravaBXC(aChave,oGetBXC:aCols)
		Else	
			oGetBXC:Grava(aChave,.T.)   // deixar forcando a gravacao assim mesmo, MOTIVO - NA INCLUSAO ELE BUSCA AS VIDAS DO BA1 E SE NAO DEIXAR ASSIM ELE NAO GRAVA CERTO - Eduardo Motta 10/03/2004
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza os usuarios informados no folder...                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BA1->( dbSetorder(02) )
		For nCnt := 1 To Len(oGetBXC:aCols)
			If BA1->( dbSeek(xFilial("BA1")+oGetBXC:FieldGet("BXC_USUARI", nCnt)) )
				BA1->( Reclock("BA1", .F.) )
					BA1->BA1_NUMENT := M->BXA_NUMERO
				BA1->( MsUnlock() )
			Endif
		Next

		aChave := {}
		aadd(aChave,{"BXB_NUMERO",M->BXA_NUMERO})
		PlsConsiste(oGetBXC:aCols,oGetBXC:aHeader,{"BXC_TIPREG"},aColsPer,aHeadPer,{"BXB_TIPREG"})
		PLUPTCOLS("BXB",aColsPer,aHeadPer,aVetPer,nOpc,aChave)

	Else
		PLUPTENC("BXA",4)
		aChave := {}
		aadd(aChave,{"BXB_NUMERO",M->BXA_NUMERO})
		PlsConsiste(oGetBXC:aCols,oGetBXC:aHeader,{"BXC_TIPREG"},aColsPer,aHeadPer,{"BXB_TIPREG"})
		PLUPTCOLS("BXB",aColsPer,aHeadPer,aVetPer,4,aChave)

		aChave := {}
		aadd(aChave,{"BXD_NUMERO",M->BXA_NUMERO})
		PlsConsiste(oGetBXC:aCols,oGetBXC:aHeader,{"BXC_TIPREG"},aDadBXD,aCabBXD,{"BXB_TIPREG"})
		PLUPTCOLS("BXD",aDadBXD,aCabBXD,aTrbBXD,4,aChave)

		BA1->(DbSetOrder(14))
		BF3->(DbSetOrder(1))
		BXC->(DbSetOrder(1))
		BXD->(DbSetOrder(1))
		BXD->(DbSeek(xFilial()+BXA->BXA_NUMERO))

		While ! BXD->(Eof()) .and. xFilial("BXD")+BXA->BXA_NUMERO == BXD->BXD_FILIAL+BXD->BXD_NUMERO
			BXC->(DbSeek(xFilial()+BXA->BXA_NUMERO+BXD->BXD_TIPREG))
			If BA1->(DbSeek(xFilial()+BXA->BXA_NUMERO+BXA->BXA_USUARI))
				If ! BF3->(DbSeek(xFilial()+BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+BA1->BA1_TIPREG+BXD->BXD_CODDOE+BXD->BXD_PAGAGR ))
					RecLock("BF3",.T.)
					BF3->BF3_FILIAL := xFilial("BF3")
					BF3->BF3_CODINT := BA1->BA1_CODINT
					BF3->BF3_CODEMP := BA1->BA1_CODEMP
					BF3->BF3_MATRIC := BA1->BA1_MATRIC
					BF3->BF3_TIPREG := BA1->BA1_TIPREG
					BF3->BF3_CODDOE := BXD->BXD_CODDOE
					BF3->BF3_PAGAGR := BXD->BXD_PAGAGR
					BF3->BF3_VALAGR := BXD->BXD_VALAGR
					BF3->BF3_MESAGR := BXD->BXD_MESAGR
					BF3->BF3_UNAGR  := BXD->BXD_UNAGR
					BF3->(MsUnlock())
				EndIf
			EndIf
			BXD->(DbSkip())
		EndDo
	EndIf
	If lBA3
		lRet := .T.
	Endif
	End transaction

Else
	If lBA3
		lRet := .F.
	EndIf
EndIf

RestArea(aArea)

Return lRet
 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA530Tit ³ Autor ³ Eduardo Motta      ³ Data ³ 03.09.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Quando se digita o titular a linha 1 do aCols e' preenchid³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PLSA530Tot()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA530                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Plsa530Tit()
Local aCols
M->BXA_NOMUSR := Posicione("BA1",2,xFilial("BA1")+M->BXA_USUARI,"BA1_NOMUSR")
oGetBXC:FieldPut("BXC_USUARI",M->BXA_USUARI,1)
oGetBXC:FieldPut("BXC_NOMUSR",M->BXA_NOMUSR,1)
If BXC->(FieldPos("BXC_MATVID")) > 0
   oGetBXC:FieldPut("BXC_MATVID",BA1->BA1_MATVID,1)
EndIf
aCols := aClone(oGetBXC:aCols)
oGetBXC:SetArray(aCols)
oGetBXC:oBrowse:oBrowse:lDisablePaint := .f.
oGetBXC:oBrowse:oBrowse:Refresh()
oGetBXC:oBrowse:oBrowse:lDisablePaint := .t.
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA530CID ³ Autor ³ Eduardo Motta      ³ Data ³ 03.09.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Digitacao do CID                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PLSA530CID()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA530                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PL530CID(aCabBXD,aDadBXD,aTrbBXD,nOpc)
Local oDlg
Local nOpca:=0
Local aHeader := aClone(aCabBXD)
Local aCols   := aClone(aDadBXD)
Local aVetTrab := aClone(aTrbBXD)
Local oGetBXD
Local cCodUsu := oGetBXC:FieldGet("BXC_TIPREG")
Local cNomUsu := oGetBXC:FieldGet("BXC_NOMUSR")

DEFINE MSDIALOG oDlg TITLE "Doencas pre-existentes - "+cCodUsu+" "+cNomUsu FROM ndLinIni,ndColIni TO ndLinFin,ndColFin OF GetWndDefault()

PlsBut(oDlg)

bFilter := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BXD_TIPREG",aHeader)] == cCodUsu }
oGetBXD := TPLSBrw():New(0030,001,435,226,nil  ,oDlg,nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BXD",nOpc,"Doencas pre-existentes",nil,nil,nil,aVetTrab,,,bFilter)

ACTIVATE DIALOG oDlg CENTERED ON INIT ( EnchoiceBar(oDlg, {|| nOpca:=1,PlsEndBrw(),oDlg:End()},{|| nOpca:= 0,oDlg:End()} ))
If nOpca==1
   aDadBXD := aClone(oGetBXD:aCols)
EndIf

Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ResQuest   ³ Autor ³ Eduardo Motta       ³ Data ³ 23.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Responde questionario                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ResQuest()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ResQuest(cQuest,cPropri,aHeadPer,aColsPer,aVetPer,nOpc,lComent)
Local oDlg
Local cDesQue := Posicione("BAM",1,xFilial("BAM")+cPropri+cQuest,"BAM_DESCRI")
Local nPosReg := GdFieldPos("BXB_TIPREG",aHeadPer)
Local nPosPro := GdFieldPos("BXB_PROQUE",aHeadPer)
Local nPosQue := GdFieldPos("BXB_CODQUE",aHeadPer)
Local nOpca   := 0
Local oRadio
Local nRadio := 1
Local aPerg := {}
Local aResp := {}
Local aDesResp := {}
Local oScroll
Local bBlock
Local nLin := 15
Local nLinT := 0
Local nI
Local nJ
Local nPos
Local nPosRes
Local cWhen
Local oGetCom
Local lVisual := (nOpc#3 .and. nOpc#4)
Local lPerVisual
Local aAuxCol
Local nTamComRes := CalcFieldSize("C",TamSX3("BXB_DESCOM")[1],0,"@!","")
Local nTamComMed := CalcFieldSize("C",TamSX3("BXB_RESCOM")[1],0,"@!","")
Local nTamResp   := CalcFieldSize("C",TamSX3("BXB_DESRES")[1],0,"@!","")
Local cValid
Local lPlunusu	:= GetNewPar("MV_PLUNUSU",.F.)
Local lContinua	:= .T.
Local lPL530REQ :=  ExistBlock("PL530REQ")
DEFAULT lComent := .F.

DbSelectArea("BAJ")
BAJ->(DbSetOrder(1))
DbSeek(xFilial("BAJ")+cPropri+cQuest)
While xFilial("BAJ") == BAJ->BAJ_FILIAL .and. cPropri == BAJ->BAJ_PROQUE .and. cQuest == BAJ->BAJ_CODQUE
    aResp    := {}
    aDesResp := {}
    BAK->(DbSetOrder(1))
	If BAK->(DbSeek(xFilial("BAK")+cPropri+cQuest+BAJ->BAJ_CODPER))
		While !BAK->(Eof()) .And. BAK->(BAK_FILIAL+BAK_PROQUE+BAK_CODQUE+BAK_CODPER)==xFilial("BAK")+cPropri+cQuest+BAJ->BAJ_CODPER
			aadd(aResp,{BAK->BAK_CODRES,BAK->BAK_DESCRI,BAK->BAK_PEDCOM})
			aadd(aDesResp,BAK->BAK_DESCRI)
			BAK->(DbSkip())
		EndDo
	EndIf
	If BAJ->(FieldPos("BAJ_VALID")) > 0
   	   cValid  := AllTrim(BAJ->BAJ_VALID)
   	Else
   	   cValid  := ""
   	EndIf
	If BAJ->(FieldPos("BAJ_VISUAL")) > 0
   	   lPerVisual := (BAJ->BAJ_VISUAL=="1")
   	Else
   	   lPerVisual := .f.
   	EndIf
    aadd(aPerg,{BAJ->BAJ_CODPER,BAJ->BAJ_DESCRI,aClone(aResp),aClone(aDesResp),"","","",BAJ->BAJ_TIPRES,"",cValid,lPerVisual})
	BAJ->(DbSkip())
EndDo


If !lComent .OR. lPlunusu

	If Len(aObjResp) > 0
		For nI := 1 to Len(oGetBXC:aCols)
			If lPlunusu	.AND. nI <= Len(aObjResp)
				aObjResp[nI,6] := Iif(nI == oGetBXC:Linha(),.T.,.F.)
				lContinua := .F.	
					If (Empty(aObjResp[nI,4]) .or. Empty(aObjResp[nI,2]))
						aObjResp[nI,4] := aClone(aPerg)
						aObjResp[nI,2] := Array(Len(aPerg),7)
					EndIf			
			ElseIf (lPlunusu .OR. !lComent) .AND. Len(aObjResp) < nI 
				aadd(aObjResp,Array(Len(oGetBXC:aCols),7)[nI])
				aObjResp[nI,6] := Iif(nI == oGetBXC:Linha(),.T.,.F.)				
				aObjResp[nI,1] := oGetBXC:FieldGet("BXC_TIPREG",nI)
				aObjResp[nI,2] := Array(Len(aPerg),7)
				aObjResp[nI,3] := oGetBXC:FieldGet("BXC_NOMUSR",nI)
				aObjResp[nI,4] := aClone(aPerg)
				aObjResp[nI,5] := oGetBXC:IsDeleted(nI)				
				aObjResp[nI,6] := Iif(nI == oGetBXC:Linha(),.T.,.F.)
				aObjResp[nI,7] := .F.				
				lContinua := .F.
			EndIf
		Next
	Else
		If lPlunusu
			aObjResp := Array(Len(oGetBXC:aCols),7)
		Else
			aObjResp := Array(Len(oGetBXC:aCols),5)
		Endif
	EndIf
  
	If lContinua
		For nI := 1 to Len(oGetBXC:aCols)		
			aObjResp[nI,1] := oGetBXC:FieldGet("BXC_TIPREG",nI)
			aObjResp[nI,2] := Array(Len(aPerg),7)
			aObjResp[nI,3] := oGetBXC:FieldGet("BXC_NOMUSR",nI)
			aObjResp[nI,4] := aClone(aPerg)
			aObjResp[nI,5] := oGetBXC:IsDeleted(nI)
			If lPlunusu
				aObjResp[nI,6] := Iif(nI == oGetBXC:Linha(),.T.,.F.)
				aObjResp[nI,7] := .F.
			Endif
		Next
	Endif
Else
	aObjResp := Array(1,7)
	aObjResp[1,1] := oGetBXC:FieldGet("BXC_TIPREG")
	aObjResp[1,2] := Array(Len(aPerg),7)
	aObjResp[1,3] := oGetBXC:FieldGet("BXC_NOMUSR")
	aObjResp[1,4] := aClone(aPerg)
	aObjResp[1,5] := .f.
	cDesQue := AllTrim(cDesQue)+" - "+aObjResp[1,1]+" "+aObjResp[1,3]

EndIf


DEFINE MSDIALOG oDlg TITLE AllTrim(cDesQue) FROM 0,0 TO 400,700 PIXEL
@ 15,01 ScrollBox oScroll Vertical Horizontal  Size 180,350 of oDlg BORDER

For nI := 1 to Len(aPerg)
   bBlock := '{||"'+StrZero(nI,3)+". "+AllTrim(aPerg[nI,2])+'"}'
   TSay():New( nLin, 05, &bBlock,oScroll, , /*oFont*/, , ,,.t.)
   nLin+=10
   For nJ := 1 to Len(aObjResp)

      If lPlunusu .And. !aObjResp[nJ][6]
      	Loop
      Endif

      If lPlunusu
	      aObjResp[nJ][7] := .T.
      Endif

      If Len(aPerg[nI,4]) > 0
	  	  nLinT := nLin
         nLin += (Len(aPerg[nI,3])*10)+10
         cWhen := "{|| PLSA530WHE(aPerg,aObjResp,"+Str(nI,3)+","+Str(nJ,3)+"  ) }"
         
         aObjResp[nJ,2,nI,5] := RetCompl(aObjResp,nI,nJ,aHeadPer,aColsPer,cPropri,cQuest)
         bBlock := &('{ | u | If( PCount()==0, aObjResp['+Str(nJ,3)+',2,'+Str(nI,3)+',5], aObjResp['+Str(nJ,3)+',2,'+Str(nI,3)+',5]:= u ) }')
         cValid := "{|| PLSA530Vld(aPerg,aObjResp,"+Str(nI,3)+","+Str(nJ,3)+"  ) }"
         oGetCom := TGet():New( nLin-3, 15, bBlock,;
                                  oScroll, nTamComRes, 08,,&cValid,,,,,,.t.,,, &cWhen)
         nLin+=10
         aObjResp[nJ,2,nI,7] := oGetCom
         oGetCom:lReadOnly := lVisual .or. aObjResp[nJ,5] .or. aPerg[nI,11]
         oGetCom:NWIDTH := 590


         aObjResp[nJ,2,nI,2] := RetResp(aPerg,aObjResp,nI,nJ,aHeadPer,aColsPer,cPropri,cQuest)
         bBlock := &('{ | u | If( PCount()==0, aObjResp['+Str(nJ,3)+',2,'+Str(nI,3)+',2], PLSA530CLK(aObjResp,'+Str(nJ,3)+','+Str(nI,3)+',u,oGetCom))}')
         aObjResp[nJ,2,nI,1] := TRadMenu():New( nLinT,15, aPerg[nI,4],;
                                    bBlock, oScroll, , ,;
                                    nil, , aPerg[nI,2], , ,;
                                    nTamResp,10, , , .t.,;
                                    .t.)
         aObjResp[nJ,2,nI,1]:lReadOnly := (lComent .or. lVisual .or. aObjResp[nJ,5])

         If lPL530REQ //Ponto de entrada para alterar o item padrao selecionado no radio
			nOpcPE := ExecBlock("PL530REQ",.F.,.F.,{cQuest,cPropri,aObjResp[nJ,2,nI,1]:nOption,aPerg[nI,1],aPerg[nI,2]})
			If ValType(nOpcPE) == 'N' .And. nOpcPE <= Len(aPerg[nI,3])
				aObjResp[nJ,2,nI,1]:SetOption(nOpcPE)
			EndIf
		 EndIf

         /*nLin += (Len(aPerg[nI,3])*10)+10
         cWhen := "{|| PLSA530WHE(aPerg,aObjResp,"+Str(nI,3)+","+Str(nJ,3)+"  ) }"*/
      Else
         aObjResp[nJ,2,nI,2] := 0
         cWhen := "{||.t.}"
      EndIf
      If !lComent
      	  If  Len(aPerg[nI,4]) == 0
	         aObjResp[nJ,2,nI,5] := RetCompl(aObjResp,nI,nJ,aHeadPer,aColsPer,cPropri,cQuest)
	         bBlock := &('{ | u | If( PCount()==0, aObjResp['+Str(nJ,3)+',2,'+Str(nI,3)+',5], aObjResp['+Str(nJ,3)+',2,'+Str(nI,3)+',5]:= u ) }')
	         cValid := "{|| PLSA530Vld(aPerg,aObjResp,"+Str(nI,3)+","+Str(nJ,3)+"  ) }"
	         oGetCom := TGet():New( nLin-3, 15, bBlock,;
	                                  oScroll, nTamComRes, 08,,&cValid,,,,,,.t.,,, &cWhen)
	         nLin+=10
	         aObjResp[nJ,2,nI,7] := oGetCom
	         oGetCom:lReadOnly := lVisual .or. aObjResp[nJ,5] .or. aPerg[nI,11]
	         oGetCom:NWIDTH := 590
         EndIf
         If aObjResp[nJ,5]
            oGetCom:bWhen := {||.f.}
         EndIf
      Else
         aObjResp[nJ,2,nI,5] := RetCompl(aObjResp,nI,nJ,aHeadPer,aColsPer,cPropri,cQuest)
         If !Empty(aObjResp[nJ,2,nI,5])
            bBlock := &('{ | u | If( PCount()==0, aObjResp['+Str(nJ,3)+',2,'+Str(nI,3)+',5], aObjResp['+Str(nJ,3)+',2,'+Str(nI,3)+',5]:= u ) }')
            cValid := "{|| .t.}"
            oGetCom := TGet():New( nLin-3, 15, bBlock,;
                                     oScroll, nTamComRes, 08,,&cValid,,,,,,.t.,,,)
            aObjResp[nJ,2,nI,7] := oGetCom
            oGetCom:lReadOnly := !aObjResp[nJ,5]
            oGetCom:NWIDTH := 590
            If aObjResp[nJ,5]
               oGetCom:bWhen := {||.f.}
            EndIf
            nLin+=10
         EndIf
         bBlock := '{||"Comentario profisisonal"}'
         TSay():New( nLin, 15, &bBlock,oScroll, , /*oFont*/, , ,,.t.)
         nLin+=10
         aObjResp[nJ,2,nI,6] := RetComent(aObjResp,nI,nJ,aHeadPer,aColsPer,cPropri,cQuest)
         bBlock := &('{ | u | If( PCount()==0, aObjResp['+Str(nJ,3)+',2,'+Str(nI,3)+',6], aObjResp['+Str(nJ,3)+',2,'+Str(nI,3)+',6]:= u ) }')
         cValid := "{|| .t.}"
         TGet():New( nLin-3, 15, bBlock,;
                                  oScroll, nTamComMed, 08,,&cValid,,,,,,.t.,,,)
         nLin+=10
      EndIf
   Next nJ
Next nI

ACTIVATE DIALOG oDlg CENTERED ON INIT ( EnchoiceBar(oDlg, {|| nOpca:=1,oDlg:End()},{|| nOpca:= 0,oDlg:End()} ))

If nOpca == 1
   If lComent
      aAuxCol := {}
      For nI := 1 TO Len(aColsPer)
         If aColsPer[nI,nPosReg] # cTipReg
            aadd(aAuxCol,aColsPer[nI])
         EndIf
      Next
      aColsPer := aClone(aAuxCol)
   Else
      aColsPer := {}
   EndIf
   For nI := 1 to Len(aObjResp)
      For nJ := 1 to Len(aPerg)
 
         If Len(aObjResp[nI]) > 5 .And. !aObjResp[nI,7]
         	Exit
         Endif

         aadd(aColsPer,Array(Len(aHeadPer)+1))
         nPos    := Len(aColsPer)
         nPosRes := aObjResp[nI,2,nJ,2]
         aColsPer[nPos,Len(aHeadPer)+1] := .F.
         GDFieldPut("BXB_TIPREG",aObjResp[nI,1],nPos,aHeadPer,aColsPer)
         GDFieldPut("BXB_CODQUE",cQuest,nPos,aHeadPer,aColsPer)
         GDFieldPut("BXB_PROQUE",cPropri,nPos,aHeadPer,aColsPer)
         GDFieldPut("BXB_CODPER",aPerg[nJ,1],nPos,aHeadPer,aColsPer)

         iF Valtype(nPosRes)="N"
         	If nPosRes > 0
            	GDFieldPut("BXB_CODRES",aPerg[nJ,3,nPosRes,1],nPos,aHeadPer,aColsPer)
           		GDFieldPut("BXB_DESRES",aPerg[nJ,3,nPosRes,2],nPos,aHeadPer,aColsPer)
         	Else
            	GDFieldPut("BXB_CODRES","",nPos,aHeadPer,aColsPer)
           	 	GDFieldPut("BXB_DESRES","",nPos,aHeadPer,aColsPer)
         	EndIf
         Endif

         GDFieldPut("BXB_DESCOM",aObjResp[nI,2,nJ,5],nPos,aHeadPer,aColsPer)
         If lComent
            GDFieldPut("BXB_COMMED",aObjResp[nI,2,nJ,6],nPos,aHeadPer,aColsPer)
         EndIf
      Next
   Next
EndIf

Return

Function PLSA530CLK(aObjResp,nI,nJ,u,oGetCom)
	aObjResp[nI,2,nJ,2]:= u 
	oGetCom:CtrlRefresh()
	oGetCom:SetFocus()	
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA530WHE ³ Autor ³ TOTVS                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Controle do WHEN dos campos complementares                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PLSA530WHE(aPerg,aObjResp,nI,nJ)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA530                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA530WHE(aPerg,aObjResp,nI,nJ)
Local lCompl

If aObjResp[nJ,2,nI,2] > 0
	lCompl := aPerg[nI,3,aObjResp[nJ,2,nI,2],3] == "1"
Else
	lCompl := .F.
Endif

If !lCompl
   aObjResp[nJ,2,nI,5] := Space(Len(aObjResp[nJ,2,nI,5]))
EndIf

Return lCompl

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA530Vld ³ Autor ³ TOTVS                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao de validacao dos campos                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PLSA530Vld(aPerg,aObjResp,nI,nJ)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA530                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA530Vld(aPerg,aObjResp,nI,nJ)
Local cValid := aPerg[nI,10]
Local nX
Local lRet := .t.
Private aRespostas := {}
Private cResposta  := aObjResp[nJ,2,nI,5]
Private nPerg      := nI
For nX := 1 to Len(aObjResp[nJ,2])
   aadd(aRespostas,{aPerg[nX,1],aObjResp[nJ,2,nX,5]})
Next
If !Empty(cValid)
   lRet := &cValid
EndIf
For nX := 1 to Len(aObjResp[nJ,2])
   aObjResp[nJ,2,nX,5] := PadR(aRespostas[nX,2],100)
   If ValType(aObjResp[nJ,2,nX,7]) == "O"
      aObjResp[nJ,2,nX,7]:Refresh()
   EndIf
Next

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RetResp    ³ Autor ³ TOTVS                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorno das respostas                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RetResp(aPerg,aObjResp,nI,nJ,aHeadPer,aColsPer,           ³±±
±±³			 ³			cPropri,cCodQue)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA530                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetResp(aPerg,aObjResp,nI,nJ,aHeadPer,aColsPer,cPropri,cCodQue)
Local nOpc := 1
Local nPos
Local nPosReg := GDFieldPos("BXB_TIPREG",aHeadPer)
Local nPosPro := GDFieldPos("BXB_PROQUE",aHeadPer)
Local nPosQue := GDFieldPos("BXB_CODQUE",aHeadPer)
Local nPosPer := GDFieldPos("BXB_CODPER",aHeadPer)
Local nPosRes := GDFieldPos("BXB_CODRES",aHeadPer)
Local cTipReg := aObjResp[nJ,1]
Local cCodPer := aObjResp[nJ,4,nI,1]
Local cCodRes
Local nPerRes
Local aPerRes

nPerRes := aScan(aPerg,{|x|x[1]==cCodPer})
aPerRes := aClone(aPerg[nPerRes,3])

nPos := aScan(aColsPer,{|x|x[nPosReg]==cTipReg .and. x[nPosPro]==cPropri .and. x[nPosQue]==cCodQue .and. x[nPosPer]==cCodPer})
If nPos > 0
   cCodRes := aColsPer[nPos,nPosRes]
   nOpc := aScan(aPerRes,{|x|x[1]==cCodRes})
EndIf

Return nOpc

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RetCompl   ³ Autor ³ TOTVS                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorno dos complementos das respostas                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RetCompl(aObjResp,nI,nJ,aHeadPer,aColsPer,cPropri,        ³±±
±±³			 ³			cCodQue)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA530                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetCompl(aObjResp,nI,nJ,aHeadPer,aColsPer,cPropri,cCodQue)
Local cCompl := Space(TamSX3("BXB_DESCOM")[1])
Local nPos
Local nPosReg := GDFieldPos("BXB_TIPREG",aHeadPer)
Local nPosPro := GDFieldPos("BXB_PROQUE",aHeadPer)
Local nPosQue := GDFieldPos("BXB_CODQUE",aHeadPer)
Local nPosPer := GDFieldPos("BXB_CODPER",aHeadPer)
Local nPosCom := GDFieldPos("BXB_DESCOM",aHeadPer)
Local cTipReg := aObjResp[nJ,1]
Local cCodPer := aObjResp[nJ,4,nI,1]
Local cCodRes

nPos := aScan(aColsPer,{|x|x[nPosReg]==cTipReg .and. x[nPosPro]==cPropri .and. x[nPosQue]==cCodQue .and. x[nPosPer]==cCodPer})
If nPos > 0
   cCompl := aColsPer[nPos,nPosCom]
EndIf

Return cCompl

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RetComent  ³ Autor ³ TOTVS                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorno dos comentarios                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RetCompl(aObjResp,nI,nJ,aHeadPer,aColsPer,cPropri,cCodQue)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA530                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetComent(aObjResp,nI,nJ,aHeadPer,aColsPer,cPropri,cCodQue)
Local cCompl := Space(TamSX3("BXB_DESCOM")[1])
Local nPos
Local nPosReg := GDFieldPos("BXB_TIPREG",aHeadPer)
Local nPosPro := GDFieldPos("BXB_PROQUE",aHeadPer)
Local nPosQue := GDFieldPos("BXB_CODQUE",aHeadPer)
Local nPosPer := GDFieldPos("BXB_CODPER",aHeadPer)
Local nPosCom := GDFieldPos("BXB_COMMED",aHeadPer)
Local cTipReg := aObjResp[nJ,1]
Local cCodPer := aObjResp[nJ,4,nI,1]
Local cCodRes

nPos := aScan(aColsPer,{|x|x[nPosReg]==cTipReg .and. x[nPosPro]==cPropri .and. x[nPosQue]==cCodQue .and. x[nPosPer]==cCodPer})
If nPos > 0   .and. nPosCom >0
   cCompl := aColsPer[nPos,nPosCom]
EndIf

Return cCompl


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PlsBut     ³ Autor ³ TOTVS                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA530                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PlsBut(oDlg)
Local oBtnBaca

DEFINE SBUTTON oBtnBaca FROM 100000,100000 TYPE 1 ACTION (oDlg:GoNextCtrl(oDlg:hWnd)) OF oDlg ENABLE PIXEL

oBtnBaca:bGotFocus := {||oDlg:GoNextCtrl(oBtnBaca:hWnd)}  // pula para o proximo controle - EDUARDO MOTTA - 04/07/2001

Return oBtnBaca
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLS530PUSER³ Autor ³ DAHER	           ³ Data ³ 22.12.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa generica ...			                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS530PUSER(lBloqueia,cCodOpe)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

LOCAL oDlgPesUsr
LOCAL oTipoPes
LOCAL oSayUsr
LOCAL nOpca      := 0
LOCAL aBrowUsr   := {}
LOCAL aVetPad    := { {"","","",0,"","","","","",""} }
LOCAL oBrowUsr
LOCAL bRefresh   := { || If(!Empty(cChave),PLSA530PU(AllTrim(cChave),Subs(cTipoPes,1,1),lChkChk,aBrowUsr,aVetPad,oBrowUsr,lBloqueia,cCodOpe),.T.), If( Empty(aBrowUsr[1,2]) .And. !Empty(cChave),.F.,.T. )  }
LOCAL cValid     := "{|| Eval(bRefresh) }"
LOCAL bOK        := { || IF(!Empty(cChave),(nLin := oBrowUsr:nAt, nOpca := 1,oDlgPesUsr:End()),Help("",1,"PL530CN")) }
LOCAL bCanc      := { || nOpca := 3,oDlgPesUsr:End() }
LOCAL nReg
LOCAL oGetChave
LOCAL aTipoPes   := {}
LOCAL nOrdem     := 1
LOCAL cTipoPes   := ""
LOCAL oChkChk
LOCAL lChkChk    := .F.
LOCAL nLin       := 1

// variaveis lgpd
local objCENFUNLGP  := CENFUNLGP():New()
local aCamposCen  	:= {}
local aBls  		:= {}

DEFAULT lBloqueia:= .F.
DEFAULT cCodOpe  := PLSINTPAD()


PRIVATE aOpcoes  := {}
PRIVATE cTitulo	:= 'Pesquisa de Entrevistas'
PRIVATE cChave  := Space(100)

aBrowUsr := aClone(aVetPad)

aTipoPes   := {"1-Nome do Beneficiario","2-Numero da Entrevista"}
aadd(aOpcoes,{"BA1_NOMUSR"})
aadd(aOpcoes,{"BXA_NUMERO"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgPesUsr TITLE cTitulo FROM 002.2,000 TO 025,ndColFin OF GetWndDefault()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta objeto que recebera o a chave de pesquisa  ...                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ3

oGetChave := TGet():New(040,103,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesUsr,210,008 ,"@!S30",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Browse...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oBrowUsr := TcBrowse():New( 060, 008, 378, 100,,,, oDlgPesUsr,,,,,,,,,,,, .F.,, .T.,, .F., )

oBrowUsr:AddColumn(TcColumn():New("Nro. Entr.",nil,;
         nil,nil,nil,nil,035,.F.,.F.,nil,nil,nil,.F.,nil))
         oBrowUsr:ACOLUMNS[1]:BDATA     := { || aBrowUsr[oBrowUsr:nAt,1] }
oBrowUsr:AddColumn(TcColumn():New("Matricula",nil,;
         nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))
         oBrowUsr:ACOLUMNS[2]:BDATA     := { || aBrowUsr[oBrowUsr:nAt,2] }
oBrowUsr:AddColumn(TcColumn():New("Nome",nil,;
         nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))
         oBrowUsr:ACOLUMNS[3]:BDATA     := { || aBrowUsr[oBrowUsr:nAt,3] }

@ 040,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 090,010 OF oDlgPesUsr PIXEL COLOR CLR_HBLUE
@ 040,319 CHECKBOX oChkChk   Var lChkChk PROMPT "Pesquisar Palavra Chave" PIXEL SIZE 080, 010 OF oDlgPesUsr

oBrowUsr:SetArray(aBrowUsr)
oBrowUsr:BLDBLCLICK := bOK

if objCENFUNLGP:isLGPDAt()
	aCamposCen := {"BXA_NUMERO", "BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO","BA1_NOMUSR"}
	aBls := objCENFUNLGP:getTcBrw(aCamposCen)

	oBrowUsr:aObfuscatedCols := aBls
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o Dialogo...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlgPesUsr ON INIT Eval({ || EnChoiceBar(oDlgPesUsr,bOK,bCanc,.F.) })

If nOpca == K_OK
   If !Empty(aBrowUsr[nLin,2])
      BXA->(DbGoto(aBrowUsr[nLin,4]))
   Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno da Funcao...                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(nOpca==K_OK)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA530PU  ³ Autor ³ Daher		       ³ Data ³ 21.12.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa a usuarios na base de dados ...                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSA530PU(cChave,cTipoPes,lChkChk,aBrowUsr,aVetPad,oBrowUsr,lBloqueia,cCodOpe)
LOCAL cSQL      := ""

If '"' $ cChave .Or. ;
   "'" $ cChave
   Aviso( "Caracter Invalido", ;
          "Existem caracteres invalidos em sua pesquisa.",;
          { "Ok" }, 2 )
   Return(.F.)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa resultado...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aBrowUsr := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busco na tabela de vidas os usuarios que possuem as inicais informadas   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := "SELECT BXA_NUMERO, BXA_USUARI, BA1_CODINT, BA1_CODEMP, "
Csql += " BA1_MATRIC, BA1_TIPREG, BA1_DIGITO , BA1_NOMUSR, "+ RetSQLName("BXA")+".R_E_C_N_O_"
cSQL += " FROM " + RetSQLName("BA1") +", " + RetSQLName("BXA")
cSQL += " WHERE BXA_USUARI = BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO"
cSQL += " AND BA1_FILIAL = '"+xFilial("BA1")+"'"
cSQL += " AND BXA_FILIAL = '"+xFilial("BXA")+"' AND "

If lChkChk
     cSQL += aOpcoes[Val(cTipoPes),1]+" LIKE '%"+AllTrim(cChave)+"%' AND "
Else
     cSQL += aOpcoes[Val(cTipoPes),1]+" LIKE '"+AllTrim(cChave)+"%' AND "
Endif

cSQL += RetSQLName("BA1")+".D_E_L_E_T_ = '' AND "
cSQL += RetSQLName("BXA")+".D_E_L_E_T_ = '' "
cSQL += "ORDER BY BA1_FILIAL,"+aOpcoes[Val(cTipoPes),1]


PLSQuery(cSQL,"TrbPes")

TrbPes->(DbGoTop())
While ! TrbPes->(Eof())
      TrbPes->(aadd(aBrowUsr,{BXA_NUMERO,;
      BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO,;
      BA1_NOMUSR,;
      R_E_C_N_O_}))
TrbPes->(DbSkip())
Enddo

TrbPes->(DbCloseArea())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa resultado da pesquisa...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aBrowUsr) == 0
   aBrowUsr := aClone(aVetPad)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza browse...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowUsr:SetArray(aBrowUsr)
oBrowUsr:Refresh()
oBrowUsr:SetFocus()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ P530TudoOk ³ Autor ³ Daher		       ³ Data ³ 21.12.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao do browse					                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function P530TudoOk(nOpc)
Local lRet := .T.

If ! OBrigatorio(oEncBXA:aGets, oEncBXA:aTela)
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para validacao de usuario. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .and. ExistBlock("P530VLDOK")
	lRet := Execblock("P530VLDOK",.F.,.F.,{oEncBXA,nOpc})
EndIf
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GravaBXC ³ Autor ³ Roberto Barbosa      ³ Data ³ 06.11.18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função para a gravação correta da BXC quando o Browse     ³±±	
				se encontra em modo de alteração					     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GravaBXC(cChave,aCols)
Local lInclui := .T.
Local nI	  := 0

For nI := 1 to len(aCols)

	BXC->(dbSetOrder(1))  //BXC_FILIAL+BXC_NUMERO+BXC_TIPREG+BXC_MATVID
	If BXC->(MsSeek(xFilial("BXC")+cChave[1][2]+aCols[nI][1]+aCols[nI][2])) 
		Loop
	Else
		BXC->( Reclock("BXC", lInclui) )
			BXC->BXC_FILIAL := xFilial("BXC")
			BXC->BXC_NUMERO := cChave[1][2]
			BXC->BXC_TIPREG := aCols[nI][1]
			BXC->BXC_MATVID := aCols[nI][2]
			BXC->BXC_USUARI := aCols[nI][3]
		BXC->( MsUnlock() )
	EndIf	

Next

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Darcio R. Sporl       ³ Data ³05/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Private aRotina := {	{ STRPL01        , 'PLS530PUSER', 1 , K_Pesquisar  	, 0, .F.},;
						{ STRPL02   	 , 'PLSA530MOV' , 2 , K_Visualizar 	, 0, Nil},;
						{ STRPL03  	 	 , 'PLSA530MOV' , 3 , K_Incluir   	, 0, Nil},;
						{ STRPL04	  	 , 'PLSA530MOV' , 4 , K_Alterar    	, 0, Nil},;
						{ STRPL05      	 , 'PLSA530MOV' , 5 , K_Excluir    	, 0, Nil},;
						{ "Auditoria"    , 'PLSA530MOV' , 6 , 6  			, 0, Nil}}
Return(aRotina)
