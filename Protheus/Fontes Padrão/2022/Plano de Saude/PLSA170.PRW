#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#include "PLSA170.CH"
#include 'Ap5Mail.ch'
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PLSA170 � Autor � Tulio Cesar          � Data � 01.03.2001 潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Cadastro de Regioes                                        潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � Advanced Protheus 5.08                                     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Nenhum                                                     潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL           潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅rogramador � Data   � BOPS �  Motivo da Altera噭o                     潮�
北媚哪哪哪哪哪呐哪哪哪哪拍哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function PLSA170
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Define o cabecalho da tela de atualizacoes                               �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := STR0001//"Cadastro de Regi鮡s"

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Endereca a funcao de BROWSE                                              �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
BIB->(DbSetOrder(1))
BIB->(DbGoTop())
BIB->(mBrowse(06,01,22,75,"BIB"))

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Fim da Rotina Principal                                                  �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Return

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    � PL170MOV � Autor � Tulio Cesar           � Data � 31.03.01 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Movimentacao do Cadastro de Doencas                        潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function PL170MOV(cAlias,nReg,nOpc)

Local I__f := 0
LOCAL nOpca	 := 0
LOCAL aTitles := {STR0014,STR0015}//"Municipio"###"CEP"
LOCAL aPages  := {"",""}
LOCAL lRet	  := .T.
LOCAL cQryBar
LOCAL aPosObj   := {}
LOCAL aObjects  := {}
LOCAL aSize     := {}
LOCAL aInfo     := {}
LOCAL bOK       := {|| nOpca := 1,Iif(nOpc == K_Alterar,PLSVLDALT(),Iif(nOpc == K_Incluir,If(PLSVLDTOK(),oDlg:End(),nOpca:=2),oDlg:End())),If(nOpca==1,oDlg:End(),.F.) }
LOCAL bCancel	:= {||oDlg:End()}
LOCAL cVldLine

PRIVATE oDlg
PRIVATE oFolder
PRIVATE oEnchoice
PRIVATE oGetMUN
PRIVATE oGetCEP
PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
PRIVATE aHeader
PRIVATE aCols
PRIVATE aHeader1
PRIVATE aCols1
PRIVATE aHeader2
PRIVATE aCols2
PRIVATE aVetTrab1 := {}
PRIVATE aVetTrab2 := {}
PRIVATE aChave1 := {}
PRIVATE aChave2 := {}
PRIVATE cTipo := ""

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Monta aCols e aHeader...                                                 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Store Header "BIC" TO aHeader1 For .T.
Store Header "BY7" TO aHeader2 For .T.

If nOpc == K_Incluir
	Copy "BIB" TO Memory Blank

	Store COLS Blank "BIC" TO aCols1 FROM aHeader1
	Store COLS Blank "BY7" TO aCols2 FROM aHeader2
Else
	Copy "BIB" TO MEMORY

	BIC->(DbSetOrder(1))
	If BIC->(MsSeek(xFilial("BIC")+BIB->(BIB_CODINT+BIB_CODREG)))
		Store COLS "BIC" TO aCols1 FROM aHeader1 VETTRAB aVetTrab1 While BIC->(BIC_CODINT+BIC_CODREG) == BIB->(BIB_CODINT+BIB_CODREG)
	Else
		Store COLS Blank "BIC" TO aCols1 FROM aHeader1
	EndIf

	BY7->(DbSetOrder(1))
	If BY7->(MsSeek(xFilial("BY7")+BIB->(BIB_CODINT+BIB_CODREG)))
		Store COLS "BY7" TO aCols2 FROM aHeader2 VETTRAB aVetTrab2 While BY7->(BY7_CODINT+BY7_CODREG) == BIB->(BIB_CODINT+BIB_CODREG)
	Else
		Store COLS Blank "BY7" TO aCols2 FROM aHeader2
	EndIf
EndIf

aSize := MsAdvSize()
AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 200, 200, .T., .T.,.T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj 	:= MsObjSize( aInfo, aObjects,.T.)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Define Dialogo...                                                        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd Pixel

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Monta Enchoice...                                                        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Zero();oEnchoice := MsMGet():New(cAlias,nReg,nOpc,,,,,aPosObj[1],,,,,,oDlg,,,.F.)

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Monta Folder...                                                          �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitles,aPages,oDlg,,,, .T., .F.,aPosObj[2,3],aPosObj[2,4])

If Val(GetVersao(.F.)) >= 12 // Caso a versao seja maior ou igual a 12
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Monta GetDados Municipio...                                              �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁

	aDifSize:= {,,,,35,3,,}

	cVldLine := If(nOpc == K_Incluir .OR. nOpc == K_Alterar,"PLSVLDBIC()", NIL)
	oGetMUN := TPLSBrw():New(0,0,aPosObj[2,3]-1,aPosObj[2,4]-12,nil  ,oFolder:aDialogs[1],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aHeader1   ,aCols1 ,.F.      ,"BIC" ,nOpc,STR0014,nil,nil,nil,aVetTrab1,cVldLine,,,,,,,,,,,,aDifSize) //"Municipio"

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Monta GetDados CEP...                                             		 �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	cVldLine := If(nOpc == K_Incluir .OR. nOpc == K_Alterar,"PLSVLDBY7()", NIL)
	oGetCEP := TPLSBrw():New(0,0,aPosObj[2,3]-1,aPosObj[2,4]-11,nil  ,oFolder:aDialogs[2],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aHeader2   ,aCols2 ,.F.      ,"BY7" ,nOpc,STR0015,nil,nil,nil,aVetTrab2,cVldLine,,,,,,,,,,,,aDifSize) //"CEP"

Else
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Monta GetDados Municipio...                                              �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁

	cVldLine := If(nOpc == K_Incluir .OR. nOpc == K_Alterar,"PLSVLDBIC()", NIL)
	oGetMUN := TPLSBrw():New(0,0,aPosObj[2,3]-1,aPosObj[2,4]-12,nil  ,oFolder:aDialogs[1],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aHeader1   ,aCols1 ,.F.      ,"BIC" ,nOpc,STR0014,nil,nil,nil,aVetTrab1,cVldLine) //"Municipio"

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Monta GetDados CEP...                                             		 �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	cVldLine := If(nOpc == K_Incluir .OR. nOpc == K_Alterar,"PLSVLDBY7()", NIL)
	oGetCEP := TPLSBrw():New(0,0,aPosObj[2,3]-1,aPosObj[2,4]-11,nil  ,oFolder:aDialogs[2],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aHeader2   ,aCols2 ,.F.      ,"BY7" ,nOpc,STR0015,nil,nil,nil,aVetTrab2,cVldLine) //"CEP"
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Ativa o Dialogo...                                                       �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
ACTIVATE MSDIALOG oDlg ON INIT Eval({ || EnchoiceBar(oDlg,bOK,bCancel,.F.,{}) })

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Rotina de gravacao dos dados...                                          �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If nOpca == 1
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� No caso de exclusao verifico se houve movimentacao...                    �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If nOpc == K_Excluir
		cQryBar  := " SELECT COUNT(*) BY9_PS FROM " + RetSqlName("BY9") + " BY9 "
		cQryBar  += " WHERE BY9.BY9_CODREG = '" + M->BIB_CODREG +"'"
		cQryBar  += "   AND BY9.BY9_FILIAL = '" + xFilial("BY9") + "' "
		cQryBar  += "   AND BY9.D_E_L_E_T_ <> '*' "
		PLSQuery(cQryBar,"BY9QRY")

		cQryBar  := " SELECT COUNT(*) BY8_PS FROM " + RetSqlName("BY8") + " BY8 "
		cQryBar  += " WHERE BY8.BY8_CODREG = '" + M->BIB_CODREG +"'"
		cQryBar  += "   AND BY8.BY8_FILIAL = '" + xFilial("BY8") + "' "
		cQryBar  += "   AND BY8.D_E_L_E_T_ <> '*' "

		PLSQuery(cQryBar,"BY8QRY")
		If  BY9QRY->BY9_PS >= 1
			lRet := .F.
			MsgStop(STR0007)	//Registro n鉶 pode ser exclu韉o, pois o mesmo se encontra em Produto Sa鷇e.
		Else
			If BY8QRY->BY8_PS >= 1
				lRet := .F.
				MsgStop(STR0008)	//Registro n鉶 pode ser exclu韉o, pois o mesmo se encontra em Operador X Instit.
			EndIf
		EndIf
		BY9QRY->(DbCloseArea())
		BY8QRY->(DbCloseArea())
		//No nomento nao irei tratar pois tera de ser criada uma chave por este campo na tabela de movimentacao.
	Endif

	If lRet == .T.
		If nOpc <> K_Visualizar

			If nOpc <> K_Incluir //Se nao for inclusao, carrega em memoria valor ja gravado
				M->BIB_TIPO := BIB->BIB_TIPO
			EndIf

			PLUPTENC("BIB",nOpc)

			If M->BIB_TIPO $ "13"
				aChave1 := { {"BIC_CODREG",M->BIB_CODREG} , {"BIC_CODINT",M->BIB_CODINT} }
				oGetMUN:Grava(aChave1)
			EndIf

			If M->BIB_TIPO $ "23"
				aChave2 := { {"BY7_CODREG",M->BIB_CODREG} , {"BY7_CODINT",M->BIB_CODINT} }
				oGetCEP:Grava(aChave2)
			EndIf
		EndIf
	EndIf
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Fim da Rotina...                                                         �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    砅LSVLDBIC � Autor � Regiane R. Barreira   � Data � 30.10.06 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao 砎erifica se o municipio ja foi informado no acols ou 		  潮�
北�			 硈e e usado em outra regiao  								  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   砅LSVLDBIC()		                                          潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
FUNCTION PLSVLDBIC()

Local lRet	 	:= .T. 	//Conteudo de retorno
Local cIntPad	:= PlsIntPad()
Local aArea     := GetArea()
Local nX        := 0
Local nMun		:= 0

If M->BIB_TIPO $ "13"
	If Empty(M->BIC_CODMUN )
		MsgInfo(STR0016)	//"Municipio deve ser informado."
		lRet := .F.
	Else
		For nX := 1 to Len(aCols)
			If nX <> N
				If M->BIC_CODMUN == aCols[nX,PLRETPOS("BIC_CODMUN",aHeader,.T.)] .AND. !aCols[nX,Len(aCols[nX])]
					MsgInfo(STR0017)	//"Este municipio j� foi informado anteriormente."
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next nX

		If lRet
			BIC->(DbSetOrder(2))	//BIC_FILIAL+BIC_CODINT+BIC_CODMUN
			If BIC->(MsSeek(xFilial("BIC")+cIntPad+M->BIC_CODMUN))
				While BIC->(BIC_FILIAL+BIC_CODINT+BIC_CODMUN) == xFilial("BIC")+cIntPad+M->BIC_CODMUN
					nMun := nMun + 1
					If BIC->BIC_CODREG <> M->BIC_CODREG .OR. nMun > 1
						MsgInfo(STR0009) //"Este municipio n鉶 pode ser informado pois j� � usado em outra regi鉶."
						lRet := .F.
					EndIf
					BIC->(DbSkip())	
				EndDo
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return(lRet)

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    砅LSVLDBY7 � Autor � Regiane R. Barreira   � Data � 30.10.06 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao 砎erifica as faixas de CEP							  		  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   砅LSVLDBY7()		                                          潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
FUNCTION PLSVLDBY7()

LOCAL nPosCEPIni  := 0
LOCAL nPosCEPFin  := 0
LOCAL nVlCEPIni   := 0
LOCAL nVlCEPFin   := 0
LOCAL aCposTrb   := {}
LOCAL nFor       := 0
LOCAL nUltInd
LOCAL nPos
LOCAL nForCpo
LOCAL cMacro := "{ || .T. }"
LOCAL cIfDin
LOCAL nForAux
LOCAL lFlag
LOCAL nLinha   := n
LOCAL lPtoEntr := ExistBlock("PLS170CP")

If M->BIB_TIPO $ "23"
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Monta valor digitado na linha atual da faixa inicial e final...          �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If ( ! lPtoEntr )
		nPosCEPIni := PLRETPOS("BY7_CEPDE",oGetCEP:aHeader)
		nPosCEPFin := PLRETPOS("BY7_CEPATE",oGetCEP:aHeader)

		nVlCEPIni := &("M->"+oGetCEP:aHeader[nPosCEPIni,2])
		nVlCEPFin := &("M->"+oGetCEP:aHeader[nPosCEPFin,2])

		If Empty(nVlCEPIni) .OR. Empty(nVlCEPFin)
			MsgInfo(STR0011)	//"CEP Inicial e CEP Final devem ser informados."
			Return(.F.)
		ElseIf nVlCEPIni > nVlCEPFin
			MsgInfo(STR0010) //"O CEP Inicial deve ser menor ou igual ao CEP Final."
			Return(.F.)
		Endif
	Else
		If !ExecBlock("PLS170CP", .f., .f., {oGetCEP})
			Return(.F.)
		Endif
	Endif
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Liga flags e contadores...                                               �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	lFlag   := .T.
	nUltInd := 0
	nQtdInd := 0

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Navega por toda a matriz...                                              �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	For nFor := 1 To Len(oGetCEP:aCols)
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//� Zera contador do if Dinamico para esta linha do for...                   �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		cIfDin     := "{ || "
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//� Se a linha for diferente...                                              �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		If nFor <> nLinha .And. ! oGetCEP:aCols[nFor,Len(oGetCEP:aHeader)+1]
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
			//� Monta "If" dinamico...                                                   �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
			For nForCpo := 1 To Len(aCposTrb)
				nPos   := PLRETPOS(aCposTrb[nForCpo,1],oGetCEP:aHeader)
				cIfDin += " ( M->"+aCposTrb[nForCpo,1]+" = '"+oGetCEP:aCols[nFor,nPos]+"' ) .And. "
			Next

			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
			//� Acumula dados para a mesma chave...                                      �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
			If Eval(&cMacro)
				nUltInd := nFor
				nQtdInd ++
			Endif

			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
			//� Analisa chave em duplicidade...                                          �
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
			If nPosCEPIni >0 .and. nFor > 0 .And. Eval(&cMacro) .And. (	( nVlCEPIni >= oGetCEP:aCols[nFor,nPosCEPIni] .And. nVlCEPIni <= oGetCEP:aCols[nFor,nPosCEPFin] ) .Or.;
				( nVlCEPIni <= oGetCEP:aCols[nFor,nPosCEPIni] .And. nVlCEPFin >= oGetCEP:aCols[nFor,nPosCEPIni] ) )
				lFlag := .F.
				MsgInfo(STR0018)	//"Esta faixa de CEP j� foi informada anteriormente."
				Exit
			Endif
		Endif
	Next

	If ! lFlag
		Return(.F.)
	Endif

EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Retorno da funcao...                                                     �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Return(.T.)

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    砅LSVLDALT � Autor � Regiane R. Barreira   � Data � 10.03.07 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao 砃a alteracao se os dados das duas pastas (Municipio e CEP)  潮�
北�			 砯orem informados muda o tipo para AMBOS, caso contrario, 	  潮�
北�			 砿antem o tipo informado na inclusao (Municipio ou CEP)	  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   砅LSVLDALT()		                                          潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
FUNCTION PLSVLDALT()

If (Len(oGetMUN:aCols) == 1 .AND. (Empty(oGetMUN:aCols[1,1]) .OR. oGetMUN:aCols[1,Len(oGetMUN:aCols[1])])) .OR.;
	(Len(oGetCEP:aCols) == 1 .AND. (Empty(oGetCEP:aCols[1,1]) .OR. oGetCEP:aCols[1,Len(oGetCEP:aCols[1])]))
	M->BIB_TIPO := cTipo
EndIf

Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    砅LSVLDTOK � Autor � Regiane R. Barreira   � Data � 10.03.07 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao 砎erifica se os dados da pasta (Municipio ou CEP), conforme  潮�
北�			 硂 tipo, foram informados								 	  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   砅LSVLDTOK()		                                          潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
FUNCTION PLSVLDTOK()
Local lRet := .T. 	//Conteudo de retorno
LOCAL lPtoEntr := ExistBlock("PLS170CP")

If M->BIB_TIPO $ "13" .AND. Len(oGetMUN:aCols) == 1 .AND. (Empty(oGetMUN:aCols[1,1]) .OR. oGetMUN:aCols[1,Len(oGetMUN:aCols[1])])
	MsgInfo(STR0012)	//"Os dados da pasta MUNICIPIO devem ser informados."
	lRet := .F.
ElseIf M->BIB_TIPO $ "23" .AND. Len(oGetCEP:aCols) == 1 .AND. (Empty(oGetCEP:aCols[1,1]) .OR. oGetCEP:aCols[1,Len(oGetCEP:aCols[1])])
	If ( ! lPtoEntr ) .Or. ( ExecBlock("PLS170CP",.F.,.F.) )
		MsgInfo(STR0013)	//"Os dados da pasta CEP devem ser informados."
		lRet := .F.
	Endif
ElseIf !ExistChav("BIB",M->BIB_CODINT+M->BIB_CODREG,1)
	Help("",1,"JAGRAVADO")
	lRet := .F.
EndIf

Return(lRet)

Function PLSA170Cd(cCodInt)
LOCAL nRet    := 0
LOCAL nOrdBIB := 0
Local aArea   := GetArea()

nOrdBIB := BIB->(IndexOrd())

BIB->(DbSetOrder(1))

BIB->(MsSeek(xFilial("BIB")+cCodInt+Replicate("9",Len(BIB->BIB_CODREG)),.T.))
BIB->(DbSkip(-1))

If BIB->(BIB_FILIAL+BIB_CODINT) <> xFilial("BIB")+cCodInt
	nRet := StrZero(1,3)
Else
	nRet := Soma1(BIB->BIB_CODREG)
Endif

BIB->(DbSetOrder(nOrdBIB))

RestArea(aArea)

Return(nRet)

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  矼enuDef   � Autor � Darcio R. Sporl       � Data �27/12/2006潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Utilizacao de menu Funcional                               潮�
北�          �                                                            潮�
北�          �                                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   矨rray com opcoes da rotina.                                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros砅arametros do array a Rotina:                               潮�
北�          �1. Nome a aparecer no cabecalho                             潮�
北�          �2. Nome da Rotina associada                                 潮�
北�          �3. Reservado                                                潮�
北�          �4. Tipo de Transa噭o a ser efetuada:                        潮�
北�          �		1 - Pesquisa e Posiciona em um Banco de Dados         潮�
北�          �    2 - Simplesmente Mostra os Campos                       潮�
北�          �    3 - Inclui registros no Bancos de Dados                 潮�
北�          �    4 - Altera o registro corrente                          潮�
北�          �    5 - Remove o registro corrente do Banco de Dados        潮�
北�          �5. Nivel de acesso                                          潮�
北�          �6. Habilita Menu Funcional                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�   DATA   � Programador   矼anutencao efetuada                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�          �               �                                            潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function MenuDef()

Private aRotina := {	;
	{STRPL01, 'AxPesqui'    , 0, K_Pesquisar , 0, .F.},;	//'Pesquisar'
	{STRPL02, 'PL170MOV'    , 0, K_Visualizar, 0, },;	//'Visualizar'
	{STRPL03, 'PL170MOV'    , 0, K_Incluir   , 0, },;	//'Incluir'
	{STRPL04, 'PL170MOV'    , 0, K_Alterar   , 0, },;	//'Alterar'
	{STRPL05, 'PL170MOV'    , 0, K_Excluir   , 0, },;	//'Excluir'
	{STR0020, 'PL170DIMREDE', 0, K_Alterar   , 0, },;	//'Dimensionamento da Rede'
	{STR0039, 'PLEXPLIST({"", ""}, .F.)', 0, K_Alterar, 0, }}	//'Rela玢o de Anivers醨ios de Hoje'

Return(aRotina)

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    砅LSDESCLA     � Autor � TOTVS		     � Data � 08/01/2015 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao 砇etorna a descri玢o do tipo da classe  				       潮�
北�			   �								         						    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   砅LSDESCLA()	 	                                          潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
FUNCTION PLSDESCLA()
Local cRet := ""

dbSelectArea("B9I")
dbSetOrder(1)	// filial + codigo
If B9I->(MSSEEK(xFilial("B9I")+BIB->BIB_CODINT+BIB->BIB_CODCLA))
	dbSelectArea("B9A")
	dbSetOrder(1)
	If B9A->(MSSEEK(xFilial("B9A")+B9I->B9I_CODINT+B9I->B9I_TPCLA))
		cRet:= B9A->B9A_TPCLAS
	Endif
Endif

Return cRet

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    砅LSCALCQTDMED � Autor � TOTVS		     � Data � 08/01/2015 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao 矯alcula a massa de usuarios da regi鉶,por esse motivo �    潮�
北�			   硁ecessario o uso do count.	         						    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   砅L170CALCUSU()	                                           潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
FUNCTION PL170CALCUSU()
Local cQryBar 	:= ""
Local cQuery		:= ""
Local cAliasTrb   := ""
Local nRet    	:= 0
Local aArea     := GetArea()//Importante o GetArea e o RestArea para n鉶 ocasionar erro que o campo BIC_TPLCA n鉶 existe.

//Calcular o Massa de usuarios cadastrados para a cidade
cQryBar  := " SELECT COUNT(*) total FROM " + RetSqlName("BA1")
cQryBar  += "   WHERE BA1_FILIAL = '" + xFilial("BA1") + "' "
cQryBar  += "   AND BA1_CODMUN = '"+M->BIC_CODMUN+"'"
cQryBar  += "   AND D_E_L_E_T_ <> '*' "

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Pega uma sequencia de alias para o temporario.               �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁

cAliasTrb := GetNextAlias()

cQuery := ChangeQuery(cQryBar)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTrb, .F., .T.)

DbSelectArea( cAliasTrb )

If (cAliasTrb)->total >= 1
	nRet := (cAliasTrb)->total
Endif

(cAliasTrb)->( dbCloseArea() )

RestArea(aArea)

Return nRet

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    砅L170DimRede � Autor � TOTVS		     � Data � 14/01/2015 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao 矯alcula o dimensionamento da rede         					 潮�
北�			   矨lterado dia 17/06/2015		         						    潮�
北�			   矨lterado dia 19/06/2015 para atualiza玢o de RPO			    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   砅L170DimRede()	                                           潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
FUNCTION PL170DimRede()
Local nMedicos    := 0
Local nFrequencia := 0
Local nPorcUti    := 0
Local nI          := 0
Local nCalculo    := 0
Local cAno        := ""
Local lCheckB9S   := .T.
Local lOk 			:= .F.
Local cQuery		:= ""
Local cAliasTrb   := ""
Local cOperadora  := ""
Local cRDA        := ""

//Boas praticas de programa玢o
BIC->(DBSetOrder(1))//BIC_FILIAL+BIC_CODINT+BIC_CODREG+BIC_CODMUN
B9D->(DBSetOrder(1))//B9D_FILIAL+B9D_CODINT+B9D_CODDCM
B9J->(DBSetOrder(1))//B9J_FILIAL+B9J_CODCLA+B9J_SEQ
B9D->(DBSetOrder(1))//B9D_FILIAL+B9D_CODINT+B9D_CODDCM
B9E->(DBSetOrder(2))//B9E_FILIAL+B9E_CODDCM+B9E_ESPECI
B9S->(dbSetOrder(1))

If BIC->(MSSEEK(xFilial("BIC")+BIB->BIB_CODINT+BIB->BIB_CODREG+BIB->BIB_ESPMUN))

	cOperadora:=  alltrim(BIB->BIB_CODINT)
	cRDA      :=  alltrim(BIB->BIB_CODREG)

	While !BIC->(EOF()) .And. xFilial("BIC")+BIC->BIC_CODINT+BIC->BIC_CODREG == xFilial("BIB")+BIB->BIB_CODINT+BIB->BIB_CODREG
		//Para cada item do cadastro da Regi鉶(BIC) deve-se associar a(s) especialidades da rotina de Classifica玢o da Regi鉶(B9I/B9J)
		//Itens da Classifica玢o da Regi鉶 = TODAS AS ESPECIALIDADES
		If B9J->(MSSEEK(xFilial("B9J")+BIB->BIB_CODCLA))
			While !B9J->(EOF()) .And. xFilial("B9J")+B9J->B9J_CODCLA == xFilial("BIB")+BIB->BIB_CODCLA

				//Distribuicao das Contas Medicas, para localizar a quantidade de medicos necessarios por beneficiario
				If B9D->(MSSEEK(xFilial("B9D")+BIB->BIB_CODINT+BIB->BIB_CODCM))

					nMedicos := B9D->B9D_QTDMES
					cAno	  := alltrim(str(B9D->B9D_ANOREF))//O campo foi definido como numerico

					//Itens da Distribui玢o de Contas Medicas, para localizar a frequencia
					If B9E->(MSSEEK(xFilial("B9E")+BIB->BIB_CODCM+B9J->B9J_ESPECI))
						If B9E->B9E_TIPOAT == "1"//1=Basica;2=Especialidade
							nFrequencia := B9D->B9D_ATENCA
						Else
							nFrequencia := B9D->B9D_MESESP
						Endif

						nPorcUti := B9E->B9E_UTILIZ

					Endif
				Endif

				//Checagem se j� n鉶 existe um estudo gravado na B9S
				If lCheckB9S
					If B9S->(MSSEEK(xFilial("B9S")+BIB->BIB_CODINT+BIB->BIB_CODREG+cAno))

						If MsgYesNo( STR0021+ alltrim(cAno) + STR0022)	//"J� existe um estudo gravado para o ano de "##" deseja exclu�-lo?"
							lOk := .T.
							//Exclus鉶 da B9S
							While !B9S->(EOF()) .And. xFilial("B9S")+B9S->B9S_ANO == xFilial("B9S")+cAno
								RecLock("B9S",.F.)// s� pode existir um estudo valido para o Ano
								B9S->(Dbdelete())
								B9S->(MSUnlock())
								B9S->(DBSkip())
							EndDo

							lCheckB9S := .F. // para n鉶 realizar a pergunta novamente

						Else
							MsgAlert(STR0023)//"Processo cancelado!"
							lOk := .F.
							Return
						Endif
					Else
						lOk := .T.
						lCheckB9S := .F.
					Endif
				Endif

				If lOk

					//Inclus鉶 do registro na rotina de Dimensionamento de Rede(B9S)
					RecLock("B9S",.T.)

					B9S->B9S_FILIAL := xFilial("B9S")  //Filial
					B9S->B9S_CODINT := BIB->BIB_CODINT //Operadora
					B9S->B9S_CODREG := BIB->BIB_CODREG //Regi鉶

					B9S->B9S_CODMUN := BIC->BIC_CODMUN //Municipio
					B9S->B9S_ESPECI := B9J->B9J_ESPECI //Especialidade

					//***F髍mula = (Massa de usuarios * Coeficiente de atencao / "media" de qtde de medicos ) * Frequencia ) * Porcentagem de utilizacao
					nCalculo := ((((BIC->BIC_MASSUS * BIC->BIC_COEFNA) / nMedicos ) * nFrequencia )* nPorcUti)/100
					B9S->B9S_MEDNEC := INT(nCalculo,0)//retornar o valor inteiro
					B9S->B9S_ANO    := cAno

					cQuery := " SELECT  COUNT ( DISTINCT  BC1.BC1_CODPRF )  TOTAL " //BAX_FILIAL, BAX_CODESP, BB8_CODMUN
					cQuery += " FROM " + RetSqlName('BAX') + " BAX , " + RetSqlName('BB8') + " BB8 , " + RetSqlName('BC1') + " BC1 "
					cQuery += " WHERE "
					cQuery += " BAX.BAX_CODINT = BB8.BB8_CODINT "
					cQuery += " AND BAX.BAX_CODLOC = BB8.BB8_CODLOC "
					cQuery += " AND BAX.BAX_CODIGO = BB8.BB8_CODIGO "
					cQuery += " AND BAX.BAX_CODESP = '"+ B9J->B9J_ESPECI +"' "
					cQuery += " AND BB8.BB8_CODMUN = '"+ BIC->BIC_CODMUN +"' "
					cQuery += " AND BAX_DATBLO = '' "
					cQuery += " AND BC1.BC1_CODINT = BAX.BAX_CODINT "
					cQuery += " AND BC1.BC1_CODLOC = BAX.BAX_CODLOC "
					cQuery += " AND BC1.BC1_CODESP = BAX.BAX_CODESP "
					cQuery += " AND BAX.D_E_L_E_T_ = ' ' "
					cQuery += " AND BB8.D_E_L_E_T_ = ' ' "
					cQuery += " AND BC1.D_E_L_E_T_ = ' ' "

					//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
					//� Pega uma sequencia de alias para o temporario.               �
					//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
					cAliasTrb := GetNextAlias()

					cQuery := ChangeQuery(cQuery)
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTrb, .F., .T.)

					DbSelectArea( cAliasTrb )

					If (cAliasTrb)->Total <> 0
						B9S->B9S_MEDATU := alltrim(str((cAliasTrb)->Total))
					Else
						B9S->B9S_MEDATU := "0"
					Endif

					(cAliasTrb)->( dbCloseArea() )

					B9S->(MSUnlock())
				Endif

				B9J->(DBSkip())

			Enddo
		Endif
		BIC->(DBSkip())
	Enddo

	//Chamada da tela para verificar o resultado da funcao
	PLSA743(cOperadora,cRDA,cAno)

Endif

Return Nil

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    砅LEXPLIST        � Autor � TOTVS		 � Data � 21/01/2015 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao 矴era e Exporta lista de contato da RDA      					 潮�
北�			   �								         						    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   砅LEXPLIST()	                                              潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PLEXPLIST(aParam, lJob, cData)

Local cMontaTxt := "" //variavel que ira armazenar a linha que ir� alimentar o arquivo .csv
Local cQuery	 := "" //texto sql para gerar a lsta
Local cDirGrava := "" //diretorio onde ser� armazenado a lista de contatos
Local cDestino := GetNewPar("MV_PLTOLIS", "") //analista que recebera o email
Local cNomeArq := "" //Composicao do nome do arquivo que sera enviado
Local nDays := 0  //Numero de dias que o sistema dever� retroceder para enviar o e-mail
Local aAnexoAux := {} //arquivo em anexo que sera enviado
Local cAliasTrb := ""
Local cDirAnexo := ""
Local nHandle := 0
Local cCodRDA := ""
LOCAL dData := CTOD("")

DEFAULT lJob := .T. //	Se for um JOB assume .T., mas pra executar via menu deve passar .F.
DEFAULT cData := ""

IF lJob
	RPCSetType(3) //n鉶 consome licen鏰.
	PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2] TABLES "BAU","BBG","BIG","BAX","BAQ"
ENDIF

//Deve ser informado no parametro MV_PLSDIRA algum diretorio apartir do Protheus_Data por exemplo \ANEXO,
//ou seja n鉶 pode informar C:\PROTHEUS12\protheus_data\ANEXO porque ocasionara erro na execu玢o da FCREATE(cNomeArq)
cDirGrava  := PLSMUDSIS(GetNewPar("MV_PLSDIRA", "\ANEXO\"))
cDirGrava  += IIF(RIGHT(cDirGrava, 1) <> "\", "\", "")
nDays      := GetNewPar("MV_PLAVALD", 0)
dData      := IIF(EMPTY(cData), dDataBase, CTOD(cData))
cDtInicial := DaySub(dData, nDays)

//Anivers醨io da especialidade
cQuery := " SELECT DISTINCT BAU_CODIGO, BAU_TIPPE, BAU_NOME, BAU_NFANTA, BAU_EMAIL, BAU_TEL, BAX_CODESP, BAQ_DESCRI, BBG_EMAIL "
cQuery +=   " FROM " + RetSqlName('BAU') + " BAU , " + RetSqlName('BAX') + " BAX ," + RetSqlName('BAQ') + " BAQ ," + RetSqlName('BBG') + " BBG "
cQuery +=  " WHERE BAU_FILIAL = '" + xFilial("BAU") + "' "
cQuery +=    " AND BAX_FILIAL = '" + xFilial("BAX") + "' "
cQuery +=    " AND BAQ_FILIAL = '" + xFilial("BAQ") + "' "
cQuery +=    " AND BBG_FILIAL = '" + xFilial("BBG") + "' "
cQuery +=    " AND BAX_CODIGO = BAU_CODIGO  "
cQuery +=    " AND BAQ_CODESP = BAX_CODESP  "
cQuery +=    " AND BBG_CODIGO = BAU_CODIGO  "
If TCGetDB() == "ORACLE"
	cQuery +=  " AND SUBSTR(BAQ_ANIVER, 5) = '" + Right(DtoS(cDtInicial), 4) + "'  "
else
	cQuery +=  " AND  RIGHT(BAQ_ANIVER, 4) = '" + Right(DtoS(cDtInicial), 4) + "'  "
EndIf
cQuery +=    " AND BAX.D_E_L_E_T_ = ''  "
cQuery +=    " AND BAU.D_E_L_E_T_ = ''  "
cQuery +=    " AND BAQ.D_E_L_E_T_ = ''  "
cQuery +=    " AND BBG.D_E_L_E_T_ = ''  "
cQuery := ChangeQuery(cQuery)
cAliasTrb := GetNextAlias()
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTrb, .F., .T.)
dbSelectArea(cAliasTrb)
If !((cAliasTrb)->(EoF()))
	cMontaTxt := STR0033 + ";" /*"C骴igo RDA"*/
	cMontaTxt += STR0034 + ";" /*"Nome"      */
	cMontaTxt += STR0029 + ";" /*"E-mail"    */
	cMontaTxt += STR0030 + ";" /*"Telefone"  */
	cMontaTxt += STR0037 + ";" /*"C骴igo Especialidade" */
	cMontaTxt += STR0038 + ";" /*"Descri玢o" */
	cMontaTxt += CRLF
	While !((cAliasTrb)->(EoF()))
		If cCodRDA  <> (cAliasTrb)->BAU_CODIGO
			cMontaTxt += (cAliasTrb)->BAU_CODIGO + ";"
			cMontaTxt += Iif((cAliasTrb)->BAU_TIPPE == "F",(cAliasTrb)->BAU_NOME,(cAliasTrb)->BAU_NFANTA)   + ";"
			cMontaTxt += (cAliasTrb)->BBG_EMAIL  + ";"
			cMontaTxt += (cAliasTrb)->BAU_TEL    + ";"
			cMontaTxt += (cAliasTrb)->BAX_CODESP + ";"
			cMontaTxt += (cAliasTrb)->BAQ_DESCRI + ";"
			cMontaTxt += CRLF
			cCodRDA   := (cAliasTrb)->BAU_CODIGO
		EndIf
		(cAliasTrb)->(DbSkip())
	EndDO
	(cAliasTrb)->(DbCloseArea())
	cNomeArq := "Aniversario_Especialidades_x_RDA_Lista_"+SubStr(DtoS(cDtInicial),7,2)+"_"+SubStr(DtoS(cDtInicial),5,2)+"_"+SubStr(DtoS(cDtInicial),1,4)+".csv"
	cDirAnexo := cDirGrava + cNomeArq
	nHandle := FCREATE(cDirAnexo)
	If nHandle > 0
		FWrite(nHandle,cMontaTxt)
		FClose(nHandle)
		aadd(aAnexoAux,cDirAnexo)
	EndIF
	cMontaTxt := ""
EndIf

//Anivers醨io do Prestador
cQuery := " SELECT DISTINCT BAU_CODIGO, BAU_TIPPE, BAU_NOME, BAU_NFANTA, BAU_EMAIL, BAU_TEL, BAU_NASFUN, BAU_TIPPRE, BAG_DESCRI, BBG_EMAIL "
cQuery +=   " FROM " + RetSqlName('BAU') + " BAU , " + RetSqlName('BAG') + " BAG , " + RetSqlName('BBG') + " BBG "
cQuery +=  " WHERE BAU_FILIAL = '" + xFilial("BAU") + "' "
cQuery +=    " AND BAG_FILIAL = '" + xFilial("BAG") + "' "
cQuery +=    " AND BAG_CODIGO = BAU_TIPPRE "
cQuery +=    " AND BBG_CODIGO = BAU_CODIGO "
If TCGetDB() == "ORACLE"
	cQuery +=  " AND SUBSTR(BAU_NASFUN, 5) = '" + Right(DtoS(cDtInicial), 4) + "'  "
else
	cQuery +=  " AND  RIGHT(BAU_NASFUN, 4) = '" + Right(DtoS(cDtInicial), 4) + "'  "
EndIF
cQuery +=    " AND BAU.D_E_L_E_T_ = '' "
cQuery +=    " AND BAG.D_E_L_E_T_ = '' "
cQuery := ChangeQuery(cQuery)
cAliasTrb := GetNextAlias()
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTrb, .F., .T.)
dbSelectArea(cAliasTrb)
If !((cAliasTrb)->(EoF()))
	cMontaTxt := STR0033 + ";"	/*"C骴igo RDA"*/
	cMontaTxt += STR0034 + ";"	/*"Nome"      */
	cMontaTxt += STR0040 + ";"	/*"Tipo Pessoa"*/
	cMontaTxt += STR0029 + ";"	/*"E-mail"    */
	cMontaTxt += STR0030 + ";"	/*"Telefone"  */
	cMontaTxt += STR0036 + ";"	/*"Classe - c骴igo"*/
	cMontaTxt += STR0035 + ";"	/*"Classe - descri玢o"*/
	cMontaTxt += CRLF
	cCodRDA   := ""
	While !((cAliasTrb)->(EoF()))
		If cCodRDA  <> (cAliasTrb)->BAU_CODIGO
			cMontaTxt += (cAliasTrb)->BAU_CODIGO + ";"
			cMontaTxt += Iif((cAliasTrb)->BAU_TIPPE == "F",(cAliasTrb)->BAU_NOME,(cAliasTrb)->BAU_NFANTA)   + ";"
			cMontaTxt += (cAliasTrb)->BAU_NOME   + ";"
			cMontaTxt += (cAliasTrb)->BBG_EMAIL  + ";"
			cMontaTxt += (cAliasTrb)->BAU_TEL    + ";"
			cMontaTxt += (cAliasTrb)->BAU_TIPPRE + ";"
			cMontaTxt += (cAliasTrb)->BAG_DESCRI + ";"
			cMontaTxt += CRLF
			cCodRDA   := (cAliasTrb)->BAU_CODIGO
		EndIf
		(cAliasTrb)->(DbSkip())
	EndDO
	(cAliasTrb)->(DbCloseArea())
	cNomeArq := "Aniversario_RDA_Lista_"+SubStr(DtoS(cDtInicial),7,2)+"_"+SubStr(DtoS(cDtInicial),5,2)+"_"+SubStr(DtoS(cDtInicial),1,4)+".csv"
	cDirAnexo := cDirGrava + cNomeArq
	nHandle := FCREATE(cDirAnexo)
	If nHandle > 0
		FWrite(nHandle,cMontaTxt)
		FClose(nHandle)
		aadd(aAnexoAux,cDirAnexo)
	EndIF
	cMontaTxt := ""
EndIF

//Realiza o filtro dos credenciados
cQuery := " SELECT BAU_FILIAL, BAU_DTINCL, BAU_CODIGO, BAU_TIPPE, BAU_NOME, BAU_NFANTA, BBG_NOME, BBG_DTNASC, BBG_EMAIL, BBG_TEL, BIG_DESCRI "
cQuery +=   " FROM " + RetSqlName('BAU') + " BAU , " + RetSqlName('BBG') + " BBG ,"+ RetSqlName('BIG') + " BIG "
cQuery +=  " WHERE BAU_FILIAL = '" + xFilial("BAU") + "' "
cQuery +=    " AND BBG_FILIAL = '" + xFilial("BBG") + "' "
cQuery +=    " AND BIG_FILIAL = '" + xFilial("BIG") + "' "

If TCGetDB() == "ORACLE"
	cQuery +=  " AND SUBSTR(BAU_NASFUN, 5) = '" + Right(DtoS(cDtInicial), 4) + "'  "
else
	cQuery +=  " AND  RIGHT(BAU_NASFUN, 4) = '" + Right(DtoS(cDtInicial), 4) + "'  "
EndIF

cQuery +=    " AND BAU_FILIAL = BBG_FILIAL "
cQuery +=    " AND BBG_CODIGO = BAU_CODIGO "
cQuery +=    " AND BBG_FILIAL = BIG_FILIAL "
cQuery +=    " AND BIG_CODORG = BBG_CODORG "
cQuery +=    " AND BAU.D_E_L_E_T_ = ' ' "
cQuery +=    " AND BBG.D_E_L_E_T_ = ' ' "
cQuery +=    " AND BIG.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
cAliasTrb := GetNextAlias()
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTrb, .F., .T.)
dbSelectArea(cAliasTrb)
If !(cAliasTrb)->(Eof())
	cMontaTxt += STR0025 + ";"	//"RDA"
	cMontaTxt += STR0026 + ";"	//"Nome"
	cMontaTxt += STR0027 + ";"	//"Contato"
	cMontaTxt += STR0028 + ";"	//"Dt.Nascimento"
	cMontaTxt += STR0029 + ";"	//"E-mail"
	cMontaTxt += STR0030 + ";"	//"Telefone"
	cMontaTxt += STR0031 + ";"	//"Ocupa玢o"
	cMontaTxt += CRLF
	cCodRDA   := ""
	While !(cAliasTrb)->(Eof())
		If cCodRDA  <> (cAliasTrb)->BAU_CODIGO
			cMontaTxt += (cAliasTrb)->BAU_CODIGO + ";"
			cMontaTxt += Iif((cAliasTrb)->BAU_TIPPE == "F",(cAliasTrb)->BAU_NOME,(cAliasTrb)->BAU_NFANTA)   + ";"
			cMontaTxt += (cAliasTrb)->BBG_NOME + ";"
			cMontaTxt += (cAliasTrb)->BBG_DTNASC + ";"
			cMontaTxt += (cAliasTrb)->BBG_EMAIL + ";"
			cMontaTxt += (cAliasTrb)->BBG_TEL + ";"
			cMontaTxt += (cAliasTrb)->BIG_DESCRI + ";"
			cMontaTxt += CRLF // Salto de linha para .csv (excel)
			cCodRDA   := (cAliasTrb)->BAU_CODIGO
		EndIf
		(cAliasTrb)->(dbSkip())
	EndDO
	(cAliasTrb)->(dbCloseArea())

	// Exportando os dados para planilha
	cNomeArq := "Contatos_"+SubStr(DtoS(cDtInicial),7,2)+"_"+SubStr(DtoS(cDtInicial),5,2)+"_"+SubStr(DtoS(cDtInicial),1,4)+".csv"
	cDirAnexo := cDirGrava + cNomeArq
	nHandle := FCREATE(cDirAnexo)
	If nHandle > 0
		FWrite(nHandle,cMontaTxt)
		FClose(nHandle)
		aadd(aAnexoAux,cDirAnexo)
	EndIf

EndIf
If Len(aAnexoAux) > 0
	cDestino := PlsWFProc("000001", STR0024 , STR0024+SubStr(DtoS(cDtInicial),7,2)+"_"+SubStr(DtoS(cDtInicial),5,2)+"_"+SubStr(DtoS(cDtInicial),1,4), "PLSA170",cDestino, "" ,"" ,"\workflow\WfListaContato.htm" ,,aAnexoAux,.F.) //"Listas: "
	IF !lJob .AND. !EMPTY(cDestino)
		MSGINFO(STR0041)
	ENDIF
Else
	Plslogfil(STR0032,cDirAnexo)//"Arquivo nao encontrado"
EndIf
IF lJob
	RESET ENVIRONMENT
ENDIF

Return



FUNCTION PL170GTDESC()
Local cTexto := ""

B9I->(dbSetOrder(1))
If B9I->( DbSeek(xFilial("B9I") + M->(BIB_CODINT + BIB_CODCLA)) )
	B9A->(dbSetOrder(1))
	If B9A->( DbSeek(xFilial("B9A") + B9I->(B9I_CODINT + B9I_TPCLA)) )
		cTexto:= B9A->B9A_TPCLAS
	Endif
Endif

Return cTexto
