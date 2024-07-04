#INCLUDE "ctbatree.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "FWMVCDEF.CH"

#Define CAMPOTREE &(cTAlias + "->" + cTAlias + cCampoTree)

// 17/08/2009 -- Filial com mais de 2 caracteres
// 12.1.07 - sistemico

   /*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ CtbaTree ณ Autor ณ Marcos S. Lobo        ณ Data ณ 21/10/2003 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Cadastros dos Planos Contabeis no formato TREE 			    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ ctbatree(<alias cadastro>)                                	ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGACTB 		                                                ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ctbatree( cTAlias )

Local aSize			:= {}
Local aObjects		:= {}
Local cCpoDesc		:= cTAlias + "->" + cTAlias + "_DESC01"
Local bTxtTree		:= {|| AllTrim( CAMPOTREE ) + " - " + &(cCpoDesc) }
Local nTamMasc		:= 0
Local lStopWin  	:= .F.

Local nOpcA    		:= 3
Local cCpoFil  		:= PrefixoCpo( cTAlias ) + "_FILIAL"
Local cMemo   		:= ""
LOcal nX       		:= 0
Local lVirtual		:=.F. // Qdo .F. carrega inicializador padrao nos campos virtuais
Local cArqInd		:= ""
Local nIndex		:= 0
Local cCargoAtu		:= ""
Local lValida       := .F.


If Empty( cTAlias )
	If ! empty( Alias() )
		cTAlias := Alias()
	Else
	 	msgAlert( STR0018 ) // Erro na constru็ใo da arvore
	 	Return
	Endif
Endif

Private cCadastro	:= ""

Private oDlgTree	:= nil
Private oTree		:= nil
Private oMnuTree	:= nil
Private oBarTree	:= nil
Private oLPanel		:= nil
Private oEnc3Vis	:= nil
Private aHeader		:= {}
Private aTree		:= {}

Private Altera 		:=.F.
Private aTELA[0][0]
Private Inclui 		:=.F.
Private aGETS[0]

Private cCampoTree	:= ""
Private nTamCpoTree	:= ""
Private cMascara	:= ""
Private cCpoSup		:= ""
Private cChave		:= ""
Private cUserId		:= RetCodUsr()
Private cRotina		:= ""

SX2->(dbSetOrder(1))
If SX2->(dbSeek(cTAlias))
	cCadastro := AllTrim(X2Nome())
EndIf

DO CASE
	CASE cTAlias == "CT1"
		cCampoTree	:= "_CONTA"
		nTamCpoTree	:= TAMSX3("CT1_CONTA")[1]
		cMascara	:= GetMV("MV_MASCARA")
		cCpoSup		:= "_CTASUP"
		cChave		:= "CT1_FILIAL+CT1_CTASUP+CT1_CONTA"
		cRotina     := "CTBA020"

	CASE cTAlias == "CTT"
		cCampoTree	:= "_CUSTO"
		nTamCpoTree	:= TAMSX3("CTT_CUSTO")[1]
		cMascara	:= GetMV("MV_MASCCUS")
		cCpoSup		:= "_CCSUP"
		cChave		:= "CTT_FILIAL+CTT_CCSUP+CTT_CUSTO"
		cRotina     := "CTBA030"

	CASE cTAlias == "CTD"
		cCampoTree	:= "_ITEM"
		nTamCpoTree	:= TAMSX3("CTD_ITEM")[1]
		cMascara	:= ""
		cCpoSup		:= "_ITSUP"
		cChave		:= "CTD_FILIAL+CTD_ITSUP+CTD_ITEM"
		cRotina     := "CTBA040"

	CASE cTAlias == "CTH"
		cCampoTree	:= "_CLVL"
		nTamCpoTree	:= TAMSX3("CTH_CLVL")[1]
		cMascara	:= ""
		cCpoSup		:= "_CLSUP"
		cChave		:= "CTH_FILIAL+CTH_CLSUP+CTH_CLVL"
		cRotina     := "CTBA060"

	OTHERWISE
		cCampoTree	:= ""
		nTamCpoTree	:= ""
		cMascara	:= ""
		cCpoSup		:= ""
		cChave		:= ""
		cRotina     := ""
ENDCASE

If ! Empty( cCampoTree )

	dbSelectArea(cTAlias)
	dbSetOrder(1)

	//Cria indice temporario
	cArqInd	:= CriaTrab( Nil , .F.)

	IndRegua( cTAlias , cArqInd , cChave ,,,STR0016)  //"Selecionando Registros..."

	nIndex	:= RetIndex( cTAlias )

	dbSelectArea(cTAlias)


	dbSetOrder( nIndex + 1 )

	nTamMasc	 	:= nTamCpoTree+Len(cMascara)-1

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Faz o calculo de dimensoes do objetos    			 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aSize		:= MsAdvSize(,.F.,430)
	aObjects	:= {{ 100, 157 , .T., .T. }}
	aInfo		:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
	aPosObj		:= MsObjSize( aInfo, aObjects )
	oTdTree	 	:= {}

	While !lStopWin
		lStopWin := .T.
		DEFINE 	MSDIALOG oDlgTree TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5]	OF oMainWnd PIXEL

		oTree	:= DbTree():New(15, 5, (aPosObj[1,3]-15), 170,oDlgTree,,,.T.)
		oTree:lShowHint:= .T.
		oTree:Align := CONTROL_ALIGN_LEFT

		Aadd( oTdTree , oTree)

		MENU oMnuTree POPUP
		MENUITEM STR0001	 	    Action Ctba3Pes(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,@lStopWin,nIndex,cRotina)
		MENUITEM STR0002 		    Action cCargoAtu := Ctba3Inc(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,@lStopWin,nIndex,cRotina)
		MENUITEM STR0003 	        Action cCargoAtu := Ctba3Alt(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,@lStopWin,nIndex,cRotina)
		MENUITEM STR0004 	        Action cCargoAtu := Ctba3Exc(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,@lStopWin,nIndex,cRotina)
		MENUITEM STR0005			Action FreeObj(oTree), oTree := nil, oDlgTree:End(), CtbaTree(cTAlias)
		MENUITEM STR0006 	        Action oDlgTree:End()
		ENDMENU

		oTree:bRClicked := {|o,x,y| (ctba3mnu(o, oMnuTree), oMnuTree:Activate(x,y,o)) } // Posi็ใo x,y em rela็ใo ao Tree

		DbSelectArea(cTAlias)
		dbSetOrder(1)

		If MsSeek(xFilial(cTAlias),.T.)
			lValida := .T. //Verifica se ainda nใo existe registro na filial
		EndIf

		If !lValida .Or. (cTAlias)->(FieldGet(FieldPos(cCpoFil))) == xFilial(cTAlias)
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Monta a entrada de dados do arquivo						     ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			RegToMemory(cTAlias, .F., .F. )

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Inicializa variaveis para campos Memos Virtuais						 ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If Type("aMemos")=="A"
				For nX := 1 To Len(aMemos)
					cMemo := aMemos[nX][2]
					If ExistIni(cMemo)
						&cMemo := InitPad(SX3->X3_RELACAO)
					Else
						&cMemo := ""
					EndIf
				Next nX
			EndIf

			/*If cFunc != NIL
				lVirtual:=.T.
				&cFunc.()
			EndIf*/

			//If ValType(aPosEnch) == "U"
			//	aPosEnch := {,,(oDlgTree:nClientHeight - 4)/2,}  // ocupa todo o  espa็o da janela
			//Endif

			If ValType( oEnc3Vis ) == "O"
				Zero()
			Endif

			//If nColMens != NIL
			//	oEnc3Vis := Msmget():New(cTAlias,(cTAlias)->(Recno()),2,,,,,{15,172,(aPosObj[1,3]-15),(aPosObj[1][4]-5)},,3,1,nColMens,cMensagem,oDlgTree,,,lVirtual)
			//Else
				oEnc3Vis := Msmget():New(cTAlias,(cTAlias)->(Recno()),1,,,,,{15,172,(aPosObj[1,3]-15),(aPosObj[1][4]-5)},,3, ,		   ,		 ,oDlgTree,,,lVirtual)
				oEnc3Vis:oBox:Align := CONTROL_ALIGN_ALLCLIENT
			//EndIf
		Else
			Help(" ",1,"A000FI")
			nOpcA := 3
		EndIf

		oTree:bChange:= {|| Ctba3Show(oDlgTree,cTAlias,Ret3Recno(oTree))}

		CTTreeRfsh(cTAlias,nIndex,@oTree,cMascara, nTamCpoTree, nTamMasc,nIndex,bTxtTree,cCpoSup)

		ACTIVATE MSDIALOG oDlgTree ON INIT ctba3Bar(cTAlias,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,@lStopWin,nIndex,cRotina)			/// MONTA DIALOG (INICIALIZA ENCHOICEBAR E ENCHOICE DO TREE POSICIONADO)
	EndDo

	SET KEY VK_F6 TO //K_ALT_P - PESQUISAR
	SET KEY VK_F7 TO //K_ALT_I - INCLUIR
	SET KEY VK_F8 TO //K_ALT_A - ALTERAR
	SET KEY VK_F9 TO //K_ALT_E - EXCLUIR
	SET KEY VK_F5 TO //K_ALT_R - RECALCULAR TREE
	//SET KEY 287 TO 		//K_ALT_S - SAIR

	//Apaga indice temporario
	Ferase( cArqInd + OrdBagExt() )

	dbSelectArea( cTAlias )
	dbSetOrder(1)
Endif

oTree := nil

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณProgram   ณctba3Show    ณ Autor ณ Marcos S. Lobo        ณ Data ณ 21/10/03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Monta BROWSE padrao da consulta com TREE                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ .T.                                                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Demonstra os lancamentos da data escolhida                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ParC1 = Alias atual usado no BROWSE                           ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ctba3Show(oDlgTree,cTAlias,nRec2Go)

DbSelectArea(cTAlias)

If ValType(nRec2Go) == "N" .and. nRec2Go > 0
	MsGoTo(nRec2Go)
Else
	DbGoTop()
	nRec2Go := Recno()
Endif

If ValType(oEnc3Vis) == "O" 														//// SE O OBJETO AINDA NAO EXISTIR (ABERTURA DA TELA)
	RegToMemory(cTAlias, .F., .F. )							//// SO ATUALIZA COM OS DADOS POSICIONADOS
	oEnc3Vis:Refresh()
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณProgram   ณctba3Bar     ณ Autor ณ Marcos S. Lobo        ณ Data ณ 21/10/03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ ToolBar especifica da rotina de CONSULTA com PARAMETROS       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ ctbatreeCT2(oDlgTree)                                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ Nenhum                                                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGACTB                                                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ParO1 = Objeto dialog atual                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ctba3Bar(cTAlias,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,lStopWin,nIndex,cRotina)

Local aButtons := {}
Local oBtn1
Local oBtn2
Local oBtn3
Local oBtn4
Local oBtn5
Local oBtn6

AADD(aButtons, {"S4WB016N"		, {|| HelProg()}, STR0013})
AADD(aButtons, {"PESQUISA"		, {|| Ctba3Pes(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,@lStopWin,nIndex,cRotina)}, STR0001})
AADD(aButtons, {"BMPINCLUIR"	, {|| cCargoAtu := Ctba3Inc(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,@lStopWin,nIndex,cRotina)}, STR0002})
AADD(aButtons, {"NOTE"		   , {|| cCargoAtu := Ctba3Alt(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,@lStopWin,nIndex,cRotina)}, STR0003})
AADD(aButtons, {"EXCLUIR"		, {|| cCargoAtu := Ctba3Exc(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,@lStopWin,nIndex,cRotina)}, STR0004})
AADD(aButtons, {"RECALC"		, {|| FreeObj(oTree), oTree := nil, oDlgTree:End(), CtbaTree(cTAlias)}, STR0015 })

EnchoiceBar(oDlgTree,{|| oDlgTree:End()},{|| oDlgTree:End()},,aButtons,,,,,.F.)


SETKEY(VK_F6,{|| Ctba3Pes(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,@lStopWin,nIndex,cRotina)})				//// "K_ALT_P" (ALT+P) 281
SETKEY(VK_F7,{|| cCargoAtu := Ctba3Inc(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,@lStopWin,nIndex,cRotina)})	//// "K_ALT_I" (ALT+I) 279
SETKEY(VK_F8,{|| cCargoAtu := Ctba3Alt(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,@lStopWin,nIndex,cRotina)})	//// "K_ALT_A" (ALT+A) 286
SETKEY(VK_F9,{|| cCargoAtu := Ctba3Exc(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,@lStopWin,nIndex,cRotina)})	//// "K_ALT_E" (ALT+E) 274
SETKEY(VK_F5,{|| FreeObj(oTree), oTree := nil, oDlgTree:End(), CtbaTree(cTAlias), lStopWin := .F.})										//// "K_ALT_R" (ALT+R) 275

IF lStopWin
	ctba3Show(oDlgTree,cTAlias)			/// EXECUTA A ATUALIZAวรO DA ENCHOICE PELA 1ช VEZ.
Endif

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณctba3mnu     ณ Autor ณ Marcos S. Lobo        ณ Data ณ 21/10/03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Retorna String com a data atual para consulta dos lancamentos ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ ctbatree                                                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ctba3mnu(oTree, oMnuTree)

Local cCargo	:= oTree:GetCargo()

If Left(cCargo, 1) == "1"		// Indica se tratar de conta sintetica
	oMnuTree:aItems[1]:Enable()	// (permite incluir abaixo)
	oMnuTree:aItems[2]:Enable()
	oMnuTree:aItems[3]:Enable()
	oMnuTree:aItems[4]:Enable()
	oMnuTree:aItems[5]:Enable()
	oMnuTree:aItems[6]:Enable()
ElseIf Left(cCargo,1) == "2"
	oMnuTree:aItems[1]:Enable()
	oMnuTree:aItems[2]:Disable()
	oMnuTree:aItems[3]:Enable()
	oMnuTree:aItems[4]:Enable()
	oMnuTree:aItems[5]:Enable()
	oMnuTree:aItems[6]:Enable()
Else
	oMnuTree:aItems[1]:Disable()
	oMnuTree:aItems[2]:Enable()
	oMnuTree:aItems[3]:Disable()
	oMnuTree:aItems[4]:Disable()
	oMnuTree:aItems[5]:Enable()
	oMnuTree:aItems[6]:Disable()
Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRet3Recno บAutor  ณMarcos S. Lobo      บ Data ณ  10/22/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o Recno do ponteiro no Tree.                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ret3Recno(oTree)

Local nRecno := 0

nRecno := val(Substr(oTree:GetCargo(),2,12))

Return(nRecno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtba3Pes  บAutor  ณMarcos S. Lobo      บ Data ณ  10/29/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a pesquisa no Tree baseado no cadastro.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ctba3Pes(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,lStopWin,nIndex,cRotina)

If !MPUserHasAccess(cRotina, 1, cUserId)
	HELP("",1,"SEMPERM")
	Return
Endif

If Empty(cTAlias)
	cTAlias := Alias()
ElseIf cTAlias <> Alias()
	dbSelectArea(cTAlias)
Endif

If (cTAlias)->(RecCount()) == 0
	HELP(" ",1,"ARQVAZIO")
	Return
Endif

If ValType(oTree) <> "O"
	HELP(" ",1,"ARQVAZIO")
	Return
Else
	cCargo := oTree:GetCargo()
	If Empty(cCargo)
		HELP(" ",1,"ARQVAZIO")
		Return
	Endif
Endif

cCadAnt 		:= cCadastro
cCadastro		+= " - "+STR0001

SET KEY VK_F6 TO //K_ALT_P - PESQUISAR
SET KEY VK_F7 TO //K_ALT_I - INCLUIR
SET KEY VK_F8 TO //K_ALT_A - ALTERAR
SET KEY VK_F9 TO //K_ALT_E - EXCLUIR
SET KEY VK_F5 TO //K_ALT_R - RECALCULAR TREE

nRecPos := Recno()
AxPesqui()

If ValType(oTree) == "O"
	If nRecPos <> (cTAlias)->(Recno())
		oTree:TreeSeek(Padr(Alltrim((cTAlias)->(&(cTAlias+"_CLASSE"))) + StrZero((cTAlias)->(RecNo()),12),80))
		oTree:Refresh()
		ctba3Show(oDlgTree,cTAlias,Ret3Recno(oTree))			/// SO ATUALIZA O ENCHOICE ภ DIREITA (JA ALTERADO)
	Endif
Endif

cCadastro 		:= cCadAnt

SETKEY(VK_F6,{|| Ctba3Pes(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,,nIndex,cRotina)})							//// "K_ALT_P" (ALT+P) 281
SETKEY(VK_F7,{|| cCargoAtu := Ctba3Inc(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,@lStopWin,nIndex,cRotina)})	//// "K_ALT_I" (ALT+I) 279
SETKEY(VK_F8,{|| cCargoAtu := Ctba3Alt(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,@lStopWin,nIndex,cRotina)})	//// "K_ALT_A" (ALT+A) 286
SETKEY(VK_F9,{|| cCargoAtu := Ctba3Exc(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,@lStopWin,nIndex,cRotina)})	//// "K_ALT_E" (ALT+E) 274
SETKEY(VK_F5,{|| FreeObj(oTree), oTree := nil, oDlgTree:End(), CtbaTree(cTAlias) , lStopWin := .F.})									//// "K_ALT_R" (ALT+R) 275

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtba3Inc  บAutor  ณMarcos S. Lobo      บ Data ณ  10/22/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณOperacao de Inclusao no cadastro, atualizando o tree        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ctba3Inc(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,lStopWin,nIndex,cRotina)

Local aSaveArea	:= GetArea()
Local nRecPos		:= 0
Local cTreeCont		:= ""
Local cBmpCls		:= "BMPTABLE"
Local cBmpOpn		:= "BMPTABLE" /// "BMPTRG"
Local nPosOpc		:=	0
PRIVATE INCLUI  	:= .T.
PRIVATE ALTERA	 	:= .F.
PRIVATE lRefresh	:= .F.

DO CASE
	CASE cRotina == 'CTBA020'
		nPosOpc := 2
	
	CASE cRotina == 'CTBA030' .Or. cRotina == 'CTBA040' .OR. cRotina == 'CTBA060'
		nPosOpc := 3

	OTHERWISE
		nPosOpc := 0

ENDCASE

If !MPUserHasAccess(cRotina, nPosOpc, cUserId)
	HELP("",1,"SEMPERM")
	Return
Endif

cCadAnt				:= cCadastro
cCadastro			+= " - "+STR0002		/// "Incluir"

If ValType(oTree) == "O"
	nRecPos		:= Ret3Recno(oTree)
	cTreeCont	:= oTree:GetCargo()
Endif

SET KEY VK_F6 TO //K_ALT_P - PESQUISAR
SET KEY VK_F7 TO //K_ALT_I - INCLUIR
SET KEY VK_F8 TO //K_ALT_A - ALTERAR
SET KEY VK_F9 TO //K_ALT_E - EXCLUIR
SET KEY VK_F5 TO //K_ALT_R - RECALCULAR TREE

DO CASE
	CASE cTAlias == "CT1"
		FWExecView(STR0002,'CTBA020',MODEL_OPERATION_INSERT) //"Incluir"
	CASE cTAlias == "CTT"
		Ctba030inc(cTAlias,nRecPos,3)
	CASE cTAlias == "CTD"
		Ctba040inc(cTAlias,nRecPos,3)
	CASE cTAlias == "CTH"
		Ctba060inc(cTAlias,nRecPos,3)
ENDCASE

cClasse	:= Alltrim((cTAlias)->(&(cTAlias+"_CLASSE")))

If ValType(oTree) <> "O"			///Indica que ainda nใo hแ registros no cadastro tree nao foi criado
	cCadastro	:= cCadAnt
	If (cTAlias)->(RecCount()) > 0
		oDlgTree:End()
		lStopWin := .F.
		Return
	Endif

	If ValType(oTree) == "O"
		nRecPos		:= Ret3Recno(oTree)
		cTreeCont	:= oTree:GetCargo()

		oTree:TreeSeek(Padr("",80))
		oTree:Refresh()
		ctba3Show(oDlgTree,cTAlias,nRecPos)			/// SO ATUALIZA O ENCHOICE ภ DIREITA (JA ALTERADO)
	Endif
Else								///Inclusao ap๓s jแ existirem registros
	If cClasse == "1"
		cBmpCls := "FOLDER12"    /// 12=Azul Fechada / 13=Azul Aberta
		cBmpOpn := "FOLDER13"
	Endif

	If (cTAlias)->(Recno()) <> nRecPos .and. !Eof()	//// SE O RECNO POSICIONADO FOR DIFERENTE DO ANTERIOR
		cCodSup := ALLTRIM((cTAlias)->(&(cTAlias+cCpoSup)))
		If Empty(cCodSup)								/// SE FOR SINTETICA E O CODIGO SUPERIOR ESTIVER VAZIO (DE NIVEL 1)
			oTree:TreeSeek(Padr("",80))
			oTree:addItem(Eval(bTxtTree),Alltrim((cTAlias)->(&(cTAlias+"_CLASSE"))) + StrZero((cTAlias)->(RecNo()),12),cBmpCls,cBmpOpn,,,1)
			//DBADDTREE oTree PROMPT Eval(bTxtTree) RESOURCE cBmpCls,cBmpOpn CARGO Alltrim((cTAlias)->(&(cTAlias+"_CLASSE"))) + StrZero((cTAlias)->(RecNo()),12)	// Adiciono como nivel "
			DBENDTREE oTree
		Else											/// SE TIVER A SUPERIOR PREENCHIDA
			nOrdNew	:= (cTAlias)->(IndexOrd())
			nRecNew := (cTAlias)->(Recno())
			dbSelectArea(cTAlias)						/// VERIFICA SE O REGISTRO CADASTRADO FAZ PARTE DO MESMO GRUPO
			dbSetOrder(1)
			If MsSeek(xFilial(cTAlias)+cCodSup)
				If Recno() <> nRecPos				//// SE O CODIGO SUPERIOR FOR DIFERENTE DO TREE POSICIONADO
					cTreeCont := Alltrim((cTAlias)->(&(cTAlias+"_CLASSE"))) + StrZero((cTAlias)->(RecNo()),12)				//// USA O TREE DO CODIGO SUPERIOR ADICIONADO
				Endif
			Endif
			dbSetOrder(nOrdNew)
			dbGoTo(nRecNew)
			oTree:TreeSeek(Padr(cTreeCont,80))													//// PESQUISA A POSICAO DO SUPERIOR NO TREE
			If (cTAlias)->(&(cTAlias+"_CLASSE")) == "1"			/// SE FOR SINTETICA
				oTree:addItem(Eval(bTxtTree),Alltrim((cTAlias)->(&(cTAlias+"_CLASSE"))) + StrZero((cTAlias)->(RecNo()),12),cBmpCls,cBmpOpn,,,2)
				DBENDTREE oTree
			Else  																		/// SE FOR ANALITICA
				oTree:addItem(Eval(bTxtTree),Alltrim((cTAlias)->(&(cTAlias+"_CLASSE"))) + StrZero((cTAlias)->(RecNo()),12),cBmpCls,cBmpOpn,,,2)
			Endif
			
		Endif
		oTree:Refresh()
		ctba3Show(oDlgTree,cTAlias,Ret3Recno(oTree))			/// SO ATUALIZA O ENCHOICE ภ DIREITA (JA ALTERADO)
	Endif
Endif

cCadastro	:= cCadAnt

SETKEY(VK_F6,{|| Ctba3Pes(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,@lStopWin,nIndex,cRotina)})				//// "K_ALT_P" (ALT+P) 281
SETKEY(VK_F7,{|| cCargoAtu := Ctba3Inc(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,@lStopWin,nIndex,cRotina)})	//// "K_ALT_I" (ALT+I) 279
SETKEY(VK_F8,{|| cCargoAtu := Ctba3Alt(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,@lStopWin,nIndex,cRotina)})	//// "K_ALT_A" (ALT+A) 286
SETKEY(VK_F9,{|| cCargoAtu := Ctba3Exc(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,@lStopWin,nIndex,cRotina)})	////"K_ALT_E" (ALT+E) 274
SETKEY(VK_F5,{|| FreeObj(oTree), oTree := nil, oDlgTree:End(), CtbaTree(cTAlias) , lStopWin := .F.})									//// "K_ALT_R" (ALT+R) 275

RestArea(aSaveARea)

Return(oTree:GetCargo())

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtba3Alt  บAutor  ณMarcos S. Lobo      บ Data ณ  10/22/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณOperacao de Alteracao do Cadastro, atualizando o tree       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ctba3Alt(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,lStopWin,nIndex,cRotina)

Local nRecPos		:= 0
Local cTreeCont		:= ""
Local lCabeca		:= .F.
Local nPosOpc		:= 0

PRIVATE INCLUI := .F.
PRIVATE ALTERA := .T.
PRIVATE lRefresh	:= .F.

DO CASE
	CASE cRotina == 'CTBA020'
		nPosOpc := 3
	
	CASE cRotina == 'CTBA030' .Or. cRotina == 'CTBA040' .OR. cRotina == 'CTBA060'
		nPosOpc := 4

	OTHERWISE
		nPosOpc := 0

ENDCASE


If !MPUserHasAccess(cRotina, nPosOpc, cUserId)
	HELP("",1,"SEMPERM")
	Return
Endif

If cTAlias <> Alias()
	dbSelectArea(cTAlias)
Endif

If (cTAlias)->(RecCount()) == 0 .or. ValType(oTree) <> "O"
	HELP(" ",1,"ARQVAZIO")
	Return
Endif

If ValType( oTree ) == "O"
	nRecPos		:= Ret3Recno(oTree)
	cTreeCont	:= oTree:GetCargo()

	If Empty(cTreeCont)
		HELP(" ",1,"ARQVAZIO")
		Return
	Endif

	If nRecPos <> Recno()
		dbGoTo(nRecPos)
	Endif
Endif

cCadAnt 		:= cCadastro
cCadastro		+= " - "+STR0003		/// "Alterar"

cDescEnt	:= (cTAlias)->(&(cCpoDesc))					//// DESCRICAO ANTES DA ALTERACAO
cCodSupOri	:= (cTAlias)->(&(cTAlias+cCpoSup))				//// CODIGO SUPERIOR ANTES DA ALTERACAO

SET KEY VK_F6 TO //K_ALT_P - PESQUISAR
SET KEY VK_F7 TO //K_ALT_I - INCLUIR
SET KEY VK_F8 TO //K_ALT_A - ALTERAR
SET KEY VK_F9 TO //K_ALT_E - EXCLUIR
SET KEY VK_F5 TO //K_ALT_R - RECALCULAR TREE

DO CASE
	CASE cTAlias == "CT1"
		FWExecView(STR0003,'CTBA020', MODEL_OPERATION_UPDATE) //"Alterar"
	CASE cTAlias == "CTT"
		Ctba030Alt(cTAlias,nRecPos,4)
	CASE cTAlias == "CTD"
		Ctba040Alt(cTAlias,nRecPos,4)
	CASE cTAlias == "CTH"
		AxAltera(cTAlias,nRecPos,4)
ENDCASE

cCodSup := (cTAlias)->(&(cTAlias+cCpoSup))			/// CODIGO SUPERIOR DO REGISTRO ALTERADO

If ValType( oTree ) <> "O"			///Indica que ainda nใo hแ registros no cadastro tree nao foi criado
	If (cTAlias)->(RecCount()) > 0
		oDlgTree:End()
		lStopWin := .F.
		Return
	Endif

	If ValType( oTree ) == "O"
		nRecPos		:= Ret3Recno(oTree)
		cTreeCont	:= oTree:GetCargo()

		oTree:TreeSeek(Padr("",80))
		oTree:Refresh()
		ctba3Show(oDlgTree,cTAlias,nRecPos)			/// SO ATUALIZA O ENCHOICE ภ DIREITA (JA ALTERADO)
	Endif
Else
	If  cCodSupOri <> cCodSup  //// RECRIA O ITEM SOMENTE SE A DESCRICAO/COD SUP. FOR ALTERADO
		
		FreeObj(oTree)
		oTree := nil
		oDlgTree:End()

		CtbaTree(cTAlias)	
		
	ElseIf ( cDescEnt <> (cTAlias)->(&(cCpoDesc)) )
		oTree:ChangePrompt(Eval(bTxtTree), oTree:GetCargo())
	Endif

	If ValType( oTree ) == "O"	
		oTree:Refresh()
		ctba3Show(oDlgTree,cTAlias,Ret3Recno(oTree))			/// SO ATUALIZA O ENCHOICE ภ DIREITA (JA ALTERADO)
	EndIf

Endif

cCadastro 		:= cCadAnt

SETKEY(VK_F6,{|| Ctba3Pes(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,@lStopWin,nIndex,cRotina)})				//// "K_ALT_P" (ALT+P) 281
SETKEY(VK_F7,{|| cCargoAtu := Ctba3Inc(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,@lStopWin,nIndex,cRotina)})	//// "K_ALT_I" (ALT+I) 279
SETKEY(VK_F8,{|| cCargoAtu := Ctba3Alt(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,@lStopWin,nIndex,cRotina)})	//// "K_ALT_A" (ALT+A) 286
SETKEY(VK_F9,{|| cCargoAtu := Ctba3Exc(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,@lStopWin,nIndex,cRotina)})	//// "K_ALT_E" (ALT+E) 274
SETKEY(VK_F5,{|| FreeObj(oTree), oTree := nil, oDlgTree:End(), CtbaTree(cTAlias), lStopWin := .F.})										//// "K_ALT_R" (ALT+R) 275

Return( If(ValType( oTree ) <> "O", "", oTree:GetCargo() ) )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtba3Exc  บAutor  ณMarcos S. Lobo      บ Data ณ  10/22/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณOperacao de Exclusใo do cadastro, atualizando o tree.                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ctba3Exc(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,lStopWin,nIndex,cRotina)

Local nRecPos		:= 0
Local cTreeCont		:= ""
Local nPosOpc		:= 0
PRIVATE INCLUI := .F.
PRIVATE ALTERA := .F.
PRIVATE lRefresh	:= .F.

DO CASE
	CASE cRotina == 'CTBA020'
		nPosOpc := 4
	
	CASE cRotina == 'CTBA030' .Or. cRotina == 'CTBA040' .OR. cRotina == 'CTBA060'
		nPosOpc := 5

	OTHERWISE
		nPosOpc := 0

ENDCASE

If !MPUserHasAccess(cRotina, nPosOpc, cUserId)
	HELP("",1,"SEMPERM")
	Return
Endif

If cTAlias <> Alias()
	dbSelectArea(cTAlias)
Endif

If (cTAlias)->(RecCount()) == 0 .or. ValType(oTree) <> "O"
	HELP(" ",1,"ARQVAZIO")
	Return
Endif

If ValType(oTree) == "O"
	nRecPos		:= Ret3Recno(oTree)
	cTreeCont	:= oTree:GetCargo()

	If Empty(cTreeCont)
		HELP(" ",1,"ARQVAZIO")
		Return
	Endif

	If nRecPos <> Recno()
		dbGoTo(nRecPos)
	Endif
Endif

cCadAnt 		:= cCadastro
cCadastro		+= " - "+STR0004		/// "Excluir"

SET KEY VK_F6 TO //K_ALT_P - PESQUISAR
SET KEY VK_F7 TO //K_ALT_I - INCLUIR
SET KEY VK_F8 TO //K_ALT_A - ALTERAR
SET KEY VK_F9 TO //K_ALT_E - EXCLUIR
SET KEY VK_F5 TO //K_ALT_R - RECALCULAR TREE

DO CASE
	CASE cTAlias == "CT1"
		FWExecView(STR0004,'CTBA020',MODEL_OPERATION_DELETE) //"Excluir"
	CASE cTAlias == "CTT"
		Ctba030Del(cTAlias,nRecPos,5)
	CASE cTAlias == "CTD"
		Ctba040Del(cTAlias,nRecPos,5)
	CASE cTAlias == "CTH"
		Ctba060Del(cTAlias,nRecPos,5)
ENDCASE

If ValType(oTree) <> "O"			///Indica que ainda nใo hแ registros no cadastro tree nao foi criado
	If (cTAlias)->(RecCount()) > 0
		oDlgTree:End()
		lStopWin := .F.
		Return
	Endif
Else
	If (cTAlias)->(Deleted()) .and. oTree:TreeSeek(Padr(cTreeCont,80))
		oTree:DelItem()
		oTree:Refresh()
	Endif
	ctba3Show(oDlgTree,cTAlias,Ret3Recno(oTree))			/// SO ATUALIZA O ENCHOICE ภ DIREITA (JA ALTERADO)
Endif

cCadastro 		:= cCadAnt

SETKEY(VK_F6,{|| Ctba3Pes(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,@lStopWin,nIndex,cRotina)})				//// "K_ALT_P" (ALT+P) 281
SETKEY(VK_F7,{|| cCargoAtu := Ctba3Inc(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,@lStopWin,nIndex,cRotina)})	//// "K_ALT_I" (ALT+I) 279
SETKEY(VK_F8,{|| cCargoAtu := Ctba3Alt(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,@lStopWin,nIndex,cRotina)})	//// "K_ALT_A" (ALT+A) 286
SETKEY(VK_F9,{|| cCargoAtu := Ctba3Exc(cTAlias,cCampoTree,nTamCpoTree,cMascara,nTamMasc,cCpoSup,bTxtTree,cCpoDesc,@lStopWin,nIndex,cRotina)})	//// "K_ALT_E" (ALT+E) 274
SETKEY(VK_F5,{|| FreeObj(oTree), oTree := nil, oDlgTree:End(), CtbaTree(cTAlias) , lStopWin := .F.})									//// "K_ALT_R" (ALT+R) 275

Return(oTree:GetCargo())
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTTReeRfshบAutor  ณSimone Mie Sato     บ Data ณ  05/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRefresh do Tree.                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTTreeRfsh(cTAlias,nIndex,oTree,cMascara, nTamCpoTree, nTamMasc,nIndex,bTxtTree,cCpoSup,cCargoAtu)

Return Processa({||AuxTreeRfsh(cTAlias,nIndex,oTree,cMascara, nTamCpoTree, nTamMasc,nIndex,bTxtTree,cCpoSup,cCargoAtu) },STR0017) //"Carregando Estrutura. Aguarde..."

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณAuxTreeRfshบAutor  ณSimone Mie Sato     บ Data ณ  10/05/05  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณRefresh do Tree.                                            บฑฑ                                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณ DATA   ณ BOPS ณProgramador  ณALTERACAO                                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ06.08.07ณ130132ณDavi Torchio ณSetOrder no Indice 5 Tabelas CT1/CTT/CTD/CTH       ณฑฑ
ฑฑณ06.08.07ณ130132ณDavi Torchio ณorder FILIAL + CONTA OU ENTIDADE SUPERIOR          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑภฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AuxTreeRfsh(cTAlias,nIndex,oTree,cMascara, nTamCpoTree, nTamMasc,nIndex,bTxtTree,cCpoSup,cCargoAtu)

dbSelectArea(cTAlias)
ProcRegua((cTAlias)->(RecCount()))

If (cTAlias)->(RecCount()) > 0
	oEnc3Vis:Hide()
//	oTree:Hide()
	oTree:Reset()
	oTree:BeginUpdate()
		
	nIndex := 5  // INDICE 5 PARA CT1,CTT,CTD e CTH PEGAREM O SEGUINTE INDICE: FILIAL + CONTA OU ENTIDADE SUPERIOR

	dbSelectArea(cTAlias)
	dbSetOrder(nIndex)

	MsSeek(xFilial(),.T.)		// Busco o nivel da conta inicial

	DO CASE
		CASE cTAlias == "CT1"

			bCodigo	:= "CT1->CT1_CONTA"
			bCodSup := "CT1->CT1_CTASUP"
			bClasse := "CT1->CT1_CLASSE"

		CASE cTAlias == 'CTT'

			bCodigo	:= "CTT->CTT_CUSTO"
			bCodSup := "CTT->CTT_CCSUP"
			bClasse := "CTT->CTT_CLASSE"

		Case cTAlias == 'CTD'

			bCodigo	:= "CTD->CTD_ITEM"
			bCodSup := "CTD->CTD_ITSUP"
			bClasse := "CTD->CTD_CLASSE"

		Case cTAlias == 'CTH'

			bCodigo	:= "CTH->CTH_CLVL"
			bCodSup := "CTH->CTH_CLSUP"
			bClasse := "CTH->CTH_CLASSE"


	EndCase

	// cria / recria o tree
	Ctb3Mount( oTree , cTAlias , bTxtTree , bCodigo , bCodSup , bClasse )

	If cCargoAtu <> Nil .or. Empty( cCargoAtu )
		cCargoAtu := &bClasse + StrZero( ( cTAlias )->( RecNo() ) , 12 )
	Endif

	oTree:Refresh()
	oTree:EndUpdate()

	If cCargoAtu <> Nil
		oTree:TreeSeek( cCargoAtu )
	EndIf

	oTree:Show()
	oEnc3Vis:Show()
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBATREE  บAutor  ณRenato F. Campos    บ Data ณ  01/16/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Ctb3mount( oTree , pAlias , bTxtTree , bCodigo , bCodSup , bClasse )
Local cFilAlias
Local aAreaEnt	:= GetArea()

Private aFilaCts := {}

DbSelectArea( pAlias )
DbSetOrder( 1 )

cFilAlias := xFilial( pAlias )

MsSeek( cFilAlias , .T. ) // posiciono o primeiro registro
While ! Eof() .And. cFilAlias == ( pAlias )->(&( pAlias + "_FILIAL" ))

	DbSelectArea( pAlias )
	DbSetOrder( 1 )

	Ctba3VarSEx( oTree , pAlias , bClasse , bCodSup , bTxtTree )

	oTree:PTCollapse()

	IncProc()

	DbSkip()
Enddo

RestArea( aAreaEnt )

RETURN


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtba3VarSExบAutor  ณRenato F. Campos   บ Data ณ  10/21/03   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a montagem do tree                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ctba3VarSEx( oTree , cTAlias , cClasse , cCodSup , bTxtTree )
Local cBmpCls 	:= "BMPTABLE"
Local cBmpOpn 	:= "BMPTABLE"//"BMPTRG"
Local nOrdAtu, nRecAtu
Local lExist 	:= .T.
Local cTreeInc
Local nLevel	:= 2
Local aArea	:= GetArea()
Local nSeek,nX

DEFAULT ctAlias	:= Alias()

If &cClasse == "1"
	cBmpCls := "FOLDER12"    /// 12 = Azul Fechada
	cBmpOpn := "FOLDER13"    /// 13 = Azul Aberta
Endif

If ! Empty( &cCodSup )
	dbSelectArea( cTAlias )

	nOrdAtu := IndexOrd()
	nRecAtu := Recno()

    dbSetOrder(1)
	If MsSeek( xFilial( cTAlias ) + &cCodSup )
		cTreeSup := Alltrim( &cClasse ) + StrZero( ( cTAlias )->( Recno() ) , 12 )

		If !oTree:TreeSeek( cTreeSup )

			If ( nSeek := aScan( aFilaCts , {|x| x[1]==cTreeSup } ) )==0
				aAdd(aFilaCts , { cTreeSup , {nRecAtu} } )
				lExist := .F.
			Else
				aAdd(aFilaCts[ nSeek , 2 ] , nRecAtu )
				lExist := .F.
			EndIf

		EndIf

	Else
		cTreeSup := " "
		nLevel	:= 1
		If oTree:CURRENTNODEID > "0000001"
			oTree:CURRENTNODEID := "0000001"
		EndIf
	Endif

	dbSetOrder( nOrdAtu )
	dbGoTo( nRecAtu )
Else
	nLevel	:= 1
	If oTree:CURRENTNODEID > "0000001"
		oTree:CURRENTNODEID := "0000001"
	EndIf
Endif

If lExist .or. nLevel==1

	// Monta Chave que ira ser incluida
	cTreeInc	:= Alltrim( &cClasse ) + StrZero( ( cTAlias )->( Recno() ) , 12 )

	oTree:addItem( Eval( bTxtTree ) , cTreeInc ,cBmpCls,cBmpOpn,,,nLevel)

	// Verifica se a Chave que foi incluida tem itens na fila ( vetor aFilaCts )
	If ( nSeek := aScan( aFilaCts , {|x| x[1]==cTreeInc } ) )>0

		// Inclui itens que estใo na fila
		For nX := 1 To Len(aFilaCts[nSeek,2])

			// Posiciona Recno que esta na fila

			DbGoTo( aFilaCts[ nSeek , 2 , nX ] )
			Ctba3VarSEx( @oTree , cTAlias , cClasse , cCodSup , bTxtTree )
			RestArea(aArea)

	    Next

	EndIf


EndIf

lTipoTree := .T.
oTree:Refresh()

Return .T.
