#include "pmsa200.ch"
#include "protheus.ch"
#include "pmsicons.ch"
#INCLUDE "FWMVCDEF.CH"
STATIC __lBlind		:= IsBlind()
Static nTamDet	 := 0
Static lTskCust0

Static _oPMSA2001
Static _oPMSA2002

// Melhoria de performance
#command PMS_TRUNCA <val1>, <val2>, <val3>, <val4>, <val5>, <Dec1>, <Dec2>, <Dec3>, <Dec4>, <Dec5>, <QtTsk>, <Trunca>, <Total> TO <var1>, <var2>, <var3>, <var4>, <var5>	;
                                                                                                                                                                             ;
  => if <Total>																																							  		;
   ; 	if <Trunca>$"13"																																						;
   ; 		<var1>+=NoRound(<val1>,<Dec1>)																																		;
   ; 		<var2>+=NoRound(<val2>,<Dec2>)																																		;
   ; 		<var3>+=NoRound(<val3>,<Dec3>)																																		;
   ; 		<var4>+=NoRound(<val4>,<Dec4>)																																		;
   ; 		<var5>+=NoRound(<val5>,<Dec5>)																																		;
   ; 	else																																									;
   ; 		<var1>+=Round(<val1>,<Dec1>)																																		;
   ; 		<var2>+=Round(<val2>,<Dec2>)																																		;
   ; 		<var3>+=Round(<val3>,<Dec3>)																																		;
   ; 		<var4>+=Round(<val4>,<Dec4>)																																		;
   ; 		<var5>+=Round(<val5>,<Dec5>)																																		;
   ; 	endif																																									;
   ; elseif <Trunca>$"1"																																						;
   ; 	<var1>+=NoRound(<val1>*<QtTsk>,<Dec1>)																																	;
   ; 	<var2>+=NoRound(<val2>*<QtTsk>,<Dec2>)																																	;
   ; 	<var3>+=NoRound(<val3>*<QtTsk>,<Dec3>)																																	;
   ; 	<var4>+=NoRound(<val4>*<QtTsk>,<Dec4>)																																	;
   ; 	<var5>+=NoRound(<val5>*<QtTsk>,<Dec5>)																																	;
   ; elseif <Trunca>$"2"					   																																	;
   ; 	<var1>+=Round(<val1>*<QtTsk>,<Dec1>)																																	;
   ; 	<var2>+=Round(<val2>*<QtTsk>,<Dec2>)																																	;
   ; 	<var3>+=Round(<val3>*<QtTsk>,<Dec3>)																																	;
   ; 	<var4>+=Round(<val4>*<QtTsk>,<Dec4>)																																	;
   ; 	<var5>+=Round(<val5>*<QtTsk>,<Dec5>)																																	;
   ; elseif <Trunca>$"3"					 																																	;
   ; 	<var1>+=NoRound(NoRound(<val1>,<Dec1>)*<QtTsk>,<Dec1>)																													;
   ; 	<var2>+=NoRound(NoRound(<val2>,<Dec2>)*<QtTsk>,<Dec2>)																													;
   ; 	<var3>+=NoRound(NoRound(<val3>,<Dec3>)*<QtTsk>,<Dec3>)																													;
   ; 	<var4>+=NoRound(NoRound(<val4>,<Dec4>)*<QtTsk>,<Dec4>)																													;
   ; 	<var5>+=NoRound(NoRound(<val5>,<Dec5>)*<QtTsk>,<Dec5>)																													;
   ; else									  																																	;
   ; 	<var1>+=Round(Round(<val1>,<Dec1>)*<QtTsk>,<Dec1>)																														;
   ; 	<var2>+=Round(Round(<val2>,<Dec2>)*<QtTsk>,<Dec2>)																														;
   ; 	<var3>+=Round(Round(<val3>,<Dec3>)*<QtTsk>,<Dec3>)																														;
   ; 	<var4>+=Round(Round(<val4>,<Dec4>)*<QtTsk>,<Dec4>)																														;
   ; 	<var5>+=Round(Round(<val5>,<Dec5>)*<QtTsk>,<Dec5>)																														;
   ; endif


/*/{Protheus.doc} PMSA200
Programa de manutencao de projetos.

@param nCallOpcx, numÈrico, (DescriÁ„o do par‚metro)
@param cRevisa, character, (DescriÁ„o do par‚metro)
@param lSimula, logico, (DescriÁ„o do par‚metro)
@param xRotAuto, vari·vel, (DescriÁ„o do par‚metro)
@param nOpcAuto, numÈrico, (DescriÁ„o do par‚metro)
@param xAutoCtr, vari·vel, (DescriÁ„o do par‚metro)
@return ${return}, ${return_description}

@author Edson Maricate
@since 09-02-2001
@version 1.0

/*/
Function PMSA200(nCallOpcx,cRevisa,lSimula,xRotAuto,nOpcAuto,xAutoCtr)
Local aIndexAF8 	:= {}
Local aAreaAF8 	:= {}
Local aLegenda
Local bFiltraBrw
Local cDetalhe	:= ""
Local cFiltBrw	:= ""
Local cFilUser	:= ""
Local lExistANE	:= .F.
Local lPM200BFIL	:= ExistBlock("PM200BFIL")
Local lPM200FIL	:= ExistBlock( "PM200FIL" )
Local lVersao		:= .F.
Local nNumDet		:= 0
Local nPosCod		:= 0
Local nx			:= 0
Local oMBrowse

PRIVATE aCores  	:= PmsAF8Color()
PRIVATE aMemos  	:= {{"AF8_CODMEM","AF8_OBS"}}
PRIVATE aRotina 	:= MenuDef()
PRIVATE cCadastro	:= STR0001 //"Gerenciamento de Projetos"
PRIVATE lAuto		:= .F.
PRIVATE lDetail	:= .F.
PRIVATE nDlgPln	:= PMS_VIEW_TREE

Private oTempTbAN9	:= Nil

DEFAULT xAutoCtr := NIL

lVersao	:= PMSVersion()
lExistANE	:= lVersao

If xAutoCtr != NIL
	lDetail := .T.
Endif

If !Empty(xRotAuto)
	If !PMSBLKINT(.T.)

		lAuto:= .T.
		/*************************************************************************
	  	// Foi necessario colocar esta opÁ„o para a exclus„o de um projeto e as
	  	// tabelas relacionadas, porque a Rotina FWMVCRotAuto n„o est· chamando
	  	// a FunÁ„o PMS200Dlg para excluir o Projeto.
	  	/*************************************************************************/
		If nOpcAuto == 5
			nPosCod:=Ascan(xRotAuto,{|x|Alltrim(x[1]) == 'AF8_PROJET'})
	    	DbSelectArea("AF8")
	    	aAreaAF8 := GetArea()
			dbSetOrder(1)
			If nPoscod > 0 .and.!Empty(xRotAuto[nPosCod][2]).and. MsSeek(xFilial("AF8")+xRotAuto[nPosCod][2])
	 			PMS200Dlg("AF8",AF8->(RecNo()),nCallOpcx,,,cRevisa,lSimula,lAuto)
	 		Else
	 			Help("  ",1,"REGNOIS")
	 		Endif
			RestArea(aAreaAF8)

		// verifica se a opÁ„o de menu trocar codigo foi adicionado
		ElseIf aScan(aRotina,{|x|upper(x[2])="PMSALTPRJ"}) == nOpcAuto

			PMSAltPrj("AF8",AF8->(RecNo()),nCallOpcx,,,xRotAuto)

		Else
	  		//Executa Rotina autom·tica se receber conte˙do no array xRotAuto
			If xAutoCtr == NIL .or. !lExistANE
				FWMVCRotAuto(ModelDef(),"AF8",nOpcAuto, {{"AF8MASTER",xRotAuto}})
			Else
				nTamDet := Len(xAutoCtr)
				FWMVCRotAuto(ModelDef(),"AF8",nOpcAuto, {{"AF8MASTER",xRotAuto},{"ANEDETAIL",xAutoCtr}})
			Endif

		Endif
	Endif
Else
	Set Key VK_F12 To FAtiva()

	If AMIIn(44) .And. !PMSBLKINT()

		Pergunte("PMA200",.F.)
		nDlgPln := mv_par01

		If lPM200FIL
			cFiltBrw := ExecBlock("PM200FIL",.F.,.F.)
			If ( ValType(cFiltBrw) == "C" ) .And. !Empty(cFiltBrw)
				bFiltraBrw := {|| FilBrowse("AF8",@aIndexAF8,@cFiltBrw) }
				Eval(bFiltraBrw)
			EndIf
		EndIf

		If nCallOpcx <> Nil
			PMS200Dlg("AF8",AF8->(RecNo()),nCallOpcx,,,cRevisa,lSimula)
		Else
			If lPM200BFIL
				cFilUser := ExecBlock("PM200BFIL",.F.,.F.)
				If ValType(cFilUser) <> "C"
					cFilUser := ""
				EndIf
			EndIf

			dbSelectArea('AF8')
			oBrowse := FWmBrowse():New()
			oBrowse:SetAlias( 'AF8' )
			oBrowse:SetDescription( cCadastro ) // 'Cadastro de Projetos'
			If !Empty(cFilUser)
				oBrowse:SetFilterDefault(cFilUser)
			EndIf
			oBrowse:SetUseFilter(.T.)
			
		   //Monta Legenda ao lado esquerdo da grid da Browse.
			For nX := 1 To Len(aCores)
				oBrowse:AddLegend( aCores[nX][1], aCores[nX][2], aCores[nX][3]  )
			Next nX

			oBrowse:Activate()

			If ( Len(aIndexAF8)>0 )
				//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				//≥ Finaliza o uso da funcao FilBrowse e retorna os indices padroes.       ≥
				//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
				EndFilBrw("AF8",aIndexAF8)
			EndIf
			
		EndIf

	EndIf

	Set Key VK_F12 To
Endif

If( valtype(oTempTbAN9) == "O")
	oTempTbAN9:Delete()
	freeObj(oTempTbAN9)
	oTempTbAN9 := nil
EndIf

Return (Nil)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥PMS200Leg≥ Autor ≥  Fabio Rogerio Pereira ≥ Data ≥ 19-03-2002 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Programa de Exibicao de Legendas                             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ PMSA200, SIGAPMS                                             ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PMS200Leg(cAlias,nReg,nOpcx)
Local aCores	:= Iif(Type("aCores")=="A" , aCores , {} )
Local aLegenda	:= {}
Local i       	:= 0

If aCores == Nil .Or. Len( aCores ) == 0//ForÁa o preenchimento das cores da legenda
	aCores := PmsAF8Color()
EndIf

If ExistBlock("PMA200LEG")
	aLegenda := ExecBlock("PMA200LEG", .T., .T., {aCores})
Else
	For i:= 1 To Len(aCores)
		Aadd(aLegenda,{aCores[i,2],aCores[i,3]})
	Next i

	aLegenda:= aSort(aLegenda,,,{|x,y| x[1] < y[1]})
EndIf

BrwLegenda(cCadastro,STR0079,aLegenda) //"Legenda"

Return(.T.)


/*/{Protheus.doc} PMS200Dlg
Programa de Inclusao,Alteracao,Visualizacao e Exclusao de Projetos.

@param cAlias, character, (DescriÁ„o do par‚metro)
@param nReg, numÈrico, (DescriÁ„o do par‚metro)
@param nOpcx, numÈrico, (DescriÁ„o do par‚metro)
@param cR1, character, (DescriÁ„o do par‚metro)
@param cR2, character, (DescriÁ„o do par‚metro)
@param cVers, character, (DescriÁ„o do par‚metro)
@param lSimula, ${param_type}, (DescriÁ„o do par‚metro)
@param lAuto, ${param_type}, (DescriÁ„o do par‚metro)
@return ${return}, ${return_description}

@author Edson Maricate
@since 09-02-2001
@version 1.0
/*/
Function PMS200Dlg(cAlias,nReg,nOpcx,cR1,cR2,cVers,lSimula,lAuto)
Local aArea		:= GetArea()
Local aButtons	:= {}
Local aConfig		:= {1, PMS_MIN_DATE, PMS_MAX_DATE, Space(TamSX3("AE8_RECURS")[1])}
Local aMenuAt		:= {}
Local aUsButtons	:= {}
Local bContext	:= Nil
Local cExcPrjPms	:= SuperGetMv("MV_PMSTEXC",,"S")
Local cPrograma	:= ""
Local cSearch		:= Space(TamSX3("AFC_DESCRI")[1])
Local cStatus		:= ""
Local cTitulo		:= ""
Local l200Altera	:= .F.
Local l200Exclui	:= .F.
Local l200Inclui	:= .F.
Local l200Visual	:= .F.
Local lCalcTrib	:= .F.
Local lCancela	:= .F.
Local lChgCols	:= .F.
Local lConfirma	:= .F.
Local lContinua	:= .T.
Local lDelPrj		:= .T.
Local lOk
Local lPMA200Inc	:= ExistBlock("PMA200Inc")
Local lRet			:= .T.
Local nOpcA		:= 0
Local nRet			:= 0
Local nz,nx
Local oDlg
Local oMenu
Local oMenu2
Local oModel

Local nScreVal1 := 775 // variaveis para posicionamento do popup menu
Local nScreVal2 := 23  // variaveis para posicionamento do popup menu
Local aScreens := {}   // variaveis para posicionamento do popup menu
PRIVATE aBAtalhos		:= {}
PRIVATE bBlocoAtalho	:= {}
PRIVATE cArqPLN
PRIVATE cArquivo		:= CriaTrab(,.F.)
PRIVATE cCmpPLN
PRIVATE cPLNDescri	:= ''
PRIVATE cPLNSenha		:= ""
PRIVATE cPLNVer		:= ''
PRIVATE cRevisa		:= ""
PRIVATE lEmAtalho		:= .F.
PRIVATE lSenha		:= .F.
PRIVATE nFreeze		:= 0
PRIVATE nIndent		:= PMS_SHEET_INDENT
PRIVATE oMenu3
PRIVATE oTree

DEFAULT cVers			:= AF8->AF8_REVISA
DEFAULT lSimula		:= .F.
DEFAULT lAuto  		:= .F.

//Incluido variaveis para posicionamento do Popup Menu, pois na russia o mesmo dever· ficar posicioando abaixo do menu a direita
If cPaisLoc == 'RUS'
	//Valores para a Russia, posicionado a direita
	//Change popup menu localization, using the screen resolution to position on right
	aScreens := getScreenRes()
	nScreVal1 := aScreens[1]-215
	nScreVal2 := 53
EndIf

If aRotina[nOpcx][4] == 4  //na versao 11 o lock È automatico ao pressionar altera na mbrowse - impede outros usuarios a realizar apt.
	AF8->(MsUnlock())      //razao desta instruÁ„o para liberar o registro referente ao projeto
EndIf

cRevisa := cVers

//***************************
// IntegraÁ„o com o SIGAPCO *
//***************************/
PcoIniLan("000350")

// define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)
Do Case
	Case (aRotina[nOpcx][4] == 2)
		l200Visual := .T.
	Case (aRotina[nOpcx][4] == 3) .Or. (aRotina[nOpcx,4] == 6)
		l200Inclui	:= .T.
	Case (aRotina[nOpcx][4] == 4)
		l200Altera	:= .T.
	Case (aRotina[nOpcx][4] == 5)
		lOk			:= If(lAuto,.T.,.F.)
		l200Exclui	:= .T.
		l200Visual	:= .T.
EndCase
FATPDLogUser("PMS200DLG")
// utiliza a funcao axInclui para incluir o Projeto
If l200Inclui
	If TamSX3("AFC_PROJET")[1] > TamSX3("AFC_EDT")[1]
		Help(" ",1,"A200TAMAFC")
		lContinua := .F.
	EndIf
	
	If lContinua
		If lPMA200Inc
			If ExecBlock("PMA200Inc")
				Return
			EndIf
		EndIf

		cTitulo      := STR0001 // 'Gerenciamento de Projetos'
		cPrograma    := 'PMSA200'
		__nOper      := nOpcx
		nOperation   := nOpcx
		bOk          := {|| nRet := 1,.T. }
		FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,bOk, /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ )
		__nOper      := 0
		cRevisa	:= AF8->AF8_REVISA
		If nRet == 1
			If ExistBlock("PMA200Prj")
				ExecBlock("PMA200Prj", .F., .F.)
			EndIf
		Else
		   lContinua := .F.
		EndIf
	EndIF
EndIf

If lContinua .and. l200Exclui .And. !lSimula

	// verifica os direitos do usuario
	If !PmsChkUser(AF8->AF8_PROJET,,Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT)),"",3,"ESTRUT",cRevisa)
		Aviso(STR0134,STR0135,{STR0136},2) //##"Usuario sem Permiss‰o."##"Usuario sem permiss‰o para executar a exclus‰o da estrutura do projeto. Verifique os direitos do usuario na estrutura deste projeto ou o projeto selecionado."##"OK"
		lContinua := .F.
	EndIf
	// verifica o evento de Exclusao no Fase atual.
	If lContinua .And. !PmsVldFase("AF8",AF8->AF8_PROJET,"12")
		lContinua := .F.
	EndIf

    // Verifica apontamentos nas tarefas do projeto
	If lContinua .And. (cExcPrjPms == "N")
		dbSelectArea("AF9")
		dbSetOrder(1)
		If dbSeek(xFilial("AF9")+AF8->(AF8_PROJET+AF8_REVISA) )
			WHILE !Eof() .and. ( AF8->(AF8_PROJET+AF8_REVISA) == AF9->(AF9_PROJET+AF9_REVISA) )  .and. lContinua
				If GeralApp( AF9->AF9_PROJET, AF9->AF9_REVISA, AF9->AF9_TAREFA )
					Aviso(STR0069,STR0266,{STR0037},2) //"Atencao"###"Existem apontamentos para esta tarefa, portanto nao pode ser excluida!"###"Fechar"
					lContinua := .F.
				else
					AF9->( dbSkip() )
				EndIf
			EndDo
		EndIf
	EndIf

EndIf

If lContinua .AND. l200Altera .And. !lSimula

	// verifica se o projeto nao esta reservado.
	If AF8->AF8_PRJREV=="1" .And. AF8->AF8_STATUS<>"2" .And. GetNewPar("MV_PMSRBLQ","N")=="S"
		Aviso(STR0035,STR0036,{STR0037},2) //"Gerenciamento de Revisoes"###"Este projeto nao se encontra em revisao. Para realizar uma alteracao no projeto, deve-se primeiro Iniciar uma revisao no projeto atraves do Gerenciamento de Revisoes."###"Fechar"
		lContinua := .F.
	EndIf

	// verifica o evento de alteracao no Fase atual.
	If !PmsVldFase("AF8",AF8->AF8_PROJET,"11")
		lContinua := .F.
	EndIf
EndIf

If lContinua
	If l200Exclui
		cCadastro := STR0001 + STR0286 // - EXCLUIR
	Elseif l200Altera
		cCadastro := STR0001 + STR0287 // - ALTERAR
	Elseif l200Visual
		cCadastro := STR0001 + STR0288 // - VISUALIZAR
	Else
		cCadastro := STR0001 + STR0289 // - INCLUIR
	Endif

	PmsAvalCal()

	// se esta funcao(PMS200Dlg) estiver sendo executada via rotina automatica,
	// ent„o È para excluir um projeto. Outras opÁıes do aRotina n„o estao disponiveis nesta funcao
	If lAuto
		If l200Exclui .And. lOk
			// verifica a existencia do ponto de entrada PMA200DEL
			If ExistBlock("PMA200DEL")
				lDelPrj:= ExecBlock("PMA200DEL",.F.,.F.,)

				// verifica se o conteudo do retorno È logico pois o retorno
				// foi implementado apos ser implementado o ponto de entrada
				If (ValType(lDelPrj) == "L") .And. !lDelPrj

					// limpar os atalhos das teclas CONTROL
					ClearAtalho()
					Return
				EndIf
			EndIf
			MaDelAF8(,AF8->(RecNo()))
		EndIf
	Else
		//Verifica se considera calculo de impostos dos produtos ou recursos das tarefas
		lCalcTrib := AF8->AF8_PAR006 == '1'

		//Chamada da funcao que determina a exibicao dos campos totalizadores de Impostos das EDTs/Tarefas
		PMSExibeCpoImp(lCalcTrib)

		If !l200Visual
			If l200Inclui .Or. l200Altera
				MENU oMenu2 POPUP
					MENUITEM STR0082 ACTION ClearAtalho() ,If(PMS200Rev(lSimula),PmsRpr(oTree,IIf(lSimula,cVers,cRevisa),cArquivo),Nil) ,RestoreAtalho() //"Reprogramar datas previstas... "
					MENUITEM STR0190 ACTION ClearAtalho() ,PmsRprSim(oTree,cRevisa,cArquivo) ,RestoreAtalho() //"Simular reprogramacao..."
					MENUITEM STR0083 ACTION ClearAtalho() ,If(PMS200Rev(lSimula),(Pms200AltCus(oTree, lSimula, lCalcTrib),Eval(bRefresh)),Nil) ,RestoreAtalho() //"Reajustar Custo Previsto Produtos... "
					MENUITEM STR0137 ACTION ClearAtalho() ,(PMS200ReCalc(lSimula,lCalcTrib),Eval(bReCalc)) ,RestoreAtalho()//"Recalculo do custo"
					MENUITEM STR0130 ACTION ClearAtalho() ,If(PMS200Rev(lSimula),(PmsDlgRedistRec( AF8->AF8_PROJET ,cRevisa ),Eval(bRefresh)),Nil) ,RestoreAtalho() //"RedistribuiÁ„o de Recursos"
					MENUITEM STR0155 ACTION ClearAtalho() ,Processa({|| Pms200REdt(oTree,cArquivo)}) ,RestoreAtalho() //"Atualizar acumulados de datas e progresso"
					MENUITEM STR0156 ACTION ClearAtalho() ,Processa({|| Pms200AGrp(oTree,cArquivo) }) ,RestoreAtalho()//"Alterar Grupo de Tarefas"
					MENUITEM STR0182 ACTION ClearAtalho() ,If(PMS200Rev(lSimula),(iIf(RecodeProj(@oTree, cArquivo),Eval(bRefresh),.T.)),Nil),RestoreAtalho() //"Recodificar"
					MENUITEM STR0188 ACTION ClearAtalho() ,If( PmsVldFase("AF8", AF8->AF8_PROJET, "28") , ;
					                                      (Processa({|| PMS200Subs(IIf(lSimula,cVers,nil))}), Eval(bRefresh)), Nil),RestoreAtalho() // "Substituir"
					MENUITEM STR0273 ACTION ClearAtalho() ,If( PmsVldFase("AF8", AF8->AF8_PROJET, "28") , ;
					                                      (Processa({|| PMS200SbLt(IIf(lSimula,cVers,nil))}), Eval(bRefresh)), Nil),RestoreAtalho() // "Substituicao em lote de recursos"

					If AF8ComAJT( AF8->AF8_PROJET )
						MENUITEM STR0274 //"Composicoes Auxiliares"
						MENU oMenu21 POPUP
							MENUITEM STR0275 ACTION ClearAtalho() ,If(PMS200Rev(),PA204Dialog( AF8->AF8_PROJET, cRevisa, bReCalc ),Nil) ,RestoreAtalho()  //"Insumos do Projeto"
							MENUITEM STR0276 ACTION ClearAtalho() ,If(PMS200Rev(),PA205Dlg2( AF8->AF8_PROJET, cRevisa, bReCalc ),Nil) ,RestoreAtalho()  //"Composicoes Auxiliares do Projeto"
						ENDMENU
					EndIf

				ENDMENU
				For nZ	:= 1 To Len(oMenu2:aItems)
					AAdd(aMenuAt,{ATA_FERRAMENTAS+"A"+STRZERO(nZ,2),1,oMenu2:aItems[nZ]:cCaption,oMenu2:aItems[nZ]:bAction,oMenu2,Nil})
				Next nZ
			EndIf
			MENU oMenu3 POPUP
				MENUITEM STR0084 ACTION ClearAtalho() ,PmsDlgAF8Gnt(cRevisa,aConfig,@oDlg,@oTree,cArquivo),RestoreAtalho()  //"Grafico de gantt..."
				MENUITEM STR0120 ACTION ClearAtalho() ,PmsDlgAF8Rec(cRevisa,@oTree,cArquivo) ,RestoreAtalho() //"Alocacao dos recursos do projeto..."
				MENUITEM STR0121 ACTION ClearAtalho() ,Pms200View(STR0121,{|| PMSC110(AF8->AF8_PROJET,cRevisa,,,@oTree,cArquivo) }) ,RestoreAtalho() //"Alocacao dos recursos por periodo..."
				MENUITEM STR0140 ACTION ClearAtalho() ,Pms200View(STR0140,{|| PMSC112(AF8->AF8_PROJET,cRevisa,@oTree,cArquivo) }) ,RestoreAtalho()//"Alocacao dos recursos por equipe por periodo..."###"Alocacao dos recursos por equipe por periodo..."
				MENUITEM STR0122 ACTION ClearAtalho() ,PmsDlgAF8Eqp(cRevisa,@oTree,cArquivo)  //"Alocacao de equipes do projeto..."
				MENUITEM STR0123 ACTION ClearAtalho() ,Pms200View(STR0123,{||PMSC115(AF8->AF8_PROJET,cRevisa,@oTree,cArquivo) }) ,RestoreAtalho()//"Alocacao de equipes por periodo..."
				MENUITEM STR0157 ACTION ClearAtalho() ,Processa({|| PmsRedeRel(oTree,cArquivo)}) ,RestoreAtalho() //"Redes de relacionamentos"
				MENUITEM STR0191 ACTION ClearAtalho() ,MsAguarde({|| PmsAponRec(oTree,cArquivo)}) ,RestoreAtalho() //'Apontamento de recursos'
	        	If lCalcTrib
					MENUITEM STR0283 ACTION ClearAtalho() ,PmsDlgAN9Vis(),RestoreAtalho()  //"Tributos do Projeto"
	   			EndIf
			EndMenu
			For nZ	:= 1 To Len(oMenu3:aItems)
				AAdd(aMenuAt,{ATA_PROJ_CONSULTAS+"A"+STRZERO(nZ,2),1,oMenu3:aItems[nZ]:cCaption,oMenu3:aItems[nZ]:bAction,oMenu3,Nil})
			Next nZ
			MENU oMenu POPUP
				MENUITEM STR0010 ACTION ClearAtalho() , iIf(PMS200to201(3,@oTree,"1",cArquivo),Eval(bRefresh),.T.) ,RestoreAtalho() //"Incluir EDT" //PMSTreeEDT(@oTree,cRevisa)
				MENUITEM STR0011 ACTION ClearAtalho() , iIf(PMS200to201(3,@oTree,"2",cArquivo),Eval(bRefresh),.T.) ,RestoreAtalho() //"Incluir Tarefa"
				MENUITEM STR0005 ACTION ClearAtalho() , iIf(PMS200to201(4,@oTree,   ,cArquivo),Eval(bRefresh),.T.) ,RestoreAtalho() //"Alterar"
				MENUITEM STR0003 ACTION ClearAtalho() ,PMS200to201(2,@oTree,,cArquivo) ,RestoreAtalho() //"Visualizar"
				MENUITEM STR0006 ACTION ClearAtalho() , iIf(PMS200to201(5,@oTree,,cArquivo),Eval(bRefresh),.T.) ,RestoreAtalho() //"Excluir"
				MENUITEM STR0248 ACTION ClearAtalho() , IIf(PMS200Import(oTree,cArquivo,1,lCalcTrib), Eval(bRefresh), .T.) ,RestoreAtalho() // "Copiar EDT/Tarefa de Orcamento"
				MENUITEM STR0063 ACTION ClearAtalho() , IIf(PMS200Import(oTree,cArquivo,2,lCalcTrib), Eval(bRefresh), .T.) ,RestoreAtalho()	//"Copiar EDT/Tarefa do Projeto" //"Copiar EDT/Tarefa"
				MENUITEM STR0080 ACTION ClearAtalho() , IIf(PMS200Cmp(AF8->(RecNo()),@oTree,cArquivo,lSimula) ,Eval(bRefresh),.T.) ,RestoreAtalho() //"Importar Composicao"
				MENUITEM STR0113 ACTION ClearAtalho() , (PMS200ChangeEDT(@oTree,cArquivo,lCalcTrib),Eval(bRefresh)) ,RestoreAtalho() //"Trocar EDT Pai"
				MENUITEM STR0129 ACTION ClearAtalho() , IIf(PMS200Cmp2(AF8->(RecNo()),@oTree,cArquivo,lSimula) ,Eval(bRefresh),.T.) ,RestoreAtalho() //"Associar Composicao"

				If nDlgPln == PMS_VIEW_TREE
					MENUITEM STR0132 ACTION ClearAtalho() ,Procurar(oTree, @cSearch, cArquivo) ,RestoreAtalho() //"Procurar..."
					MENUITEM STR0133 ACTION ClearAtalho() ,ProcurarP(oTree, @cSearch, cArquivo) ,RestoreAtalho() //"Procurar proxima"
				EndIf
			ENDMENU
			For nZ	:=	1	To Len(oMenu:aItems)
				AAdd(aMenuAt,{ATA_PROJ_ESTRUTURA+"A"+STRZERO(nZ,2),1,oMenu:aItems[nZ]:cCaption,oMenu:aItems[nZ]:bAction,oMenu,Nil})
			Next nZ

			If (GetVersao(.F.) == "P10" )

				If nDlgPln == PMS_VIEW_SHEET
					aMenu := {;
				         	{TIP_PROJ_INFO,      {||ClearAtalho() ,PmsPrjInf() ,RestoreAtalho()}, BMP_PROJ_INFO, TOOL_PROJ_INFO},;
				         	{TIP_COLUNAS,        {||ClearAtalho() ,Iif(lChgCols := PMC200Cfg("",0,0),oDlg:End(),Nil) ,RestoreAtalho()}, BMP_COLUNAS, TOOL_COLUNAS},;
				         	{TIP_FERRAMENTAS,    {||A200CtrMenu(@oMenu,oTree,l200Visual,cArquivo,oMenu2,nDlgPln,lSimula),oMenu2:Activate(105,45,oDlg) }, BMP_FERRAMENTAS, TOOL_FERRAMENTAS},;
				         	{TIP_FILTRO,         {||ClearAtalho() ,If(PmsCfgDlg(aConfig),Eval(bRefresh),Nil) ,RestoreAtalho()},BMP_FILTRO, TOOL_FILTRO},;
				         	{TIP_PROJ_CONSULTAS, {||oMenu3:Activate(175,45,oDlg) },BMP_PROJ_CONSULTAS,TOOL_PROJ_CONSULTAS},;
				         	{TIP_PROJ_ESTRUTURA, {||A200CtrMenu(@oMenu,oTree,l200Visual,cArquivo,oMenu2,nDlgPln,lSimula),oMenu:Activate(210,45,oDlg) },BMP_PROJ_ESTRUTURA,TOOL_PROJ_ESTRUTURA}}
				Else
					aMenu := {;
				         	{TIP_PROJ_INFO,      {||ClearAtalho() ,PmsPrjInf() ,RestoreAtalho()}, BMP_PROJ_INFO, TOOL_PROJ_INFO},;
				         	{TIP_FERRAMENTAS,    {||A200CtrMenu(@oMenu,oTree,l200Visual,cArquivo,oMenu2,nDlgPln,lSimula),oMenu2:Activate(70,45,oDlg) }, BMP_FERRAMENTAS, TOOL_FERRAMENTAS},;
				         	{TIP_FILTRO,         {||ClearAtalho() ,If(PmsCfgDlg(aConfig),Eval(bRefresh),Nil) ,RestoreAtalho()}, BMP_FILTRO, TOOL_FILTRO},;
				         	{TIP_PROJ_CONSULTAS, {||oMenu3:Activate(140,45,oDlg) }, BMP_PROJ_CONSULTAS, TOOL_PROJ_CONSULTAS},;
				         	{TIP_PROJ_ESTRUTURA, {||A200CtrMenu(@oMenu,oTree,l200Visual,cArquivo,oMenu2,nDlgPln,lSimula),oMenu:Activate(175,45,oDlg) },BMP_PROJ_ESTRUTURA, TOOL_PROJ_ESTRUTURA}}
				EndIf
	    	Else
				//Acoes relacionadas
				If nDlgPln == PMS_VIEW_SHEET
					aMenu := {;
							{TIP_PROJ_INFO,      {||ClearAtalho() ,PmsPrjInf() ,RestoreAtalho()}, BMP_PROJ_INFO, TOOL_PROJ_INFO},;
							{TIP_COLUNAS,        {||ClearAtalho() ,Iif(lChgCols := PMC200Cfg("",0,0),oDlg:End(),Nil) ,RestoreAtalho()}, BMP_COLUNAS, TOOL_COLUNAS},;
							{TIP_FERRAMENTAS,    {||A200CtrMenu(@oMenu,oTree,l200Visual,cArquivo,oMenu2,nDlgPln,lSimula),oMenu2:Activate(nScreVal1,nScreVal2,oDlg) }, BMP_FERRAMENTAS, TOOL_FERRAMENTAS},;
							{TIP_FILTRO,         {||ClearAtalho() ,If(PmsCfgDlg(aConfig),Eval(bRefresh),Nil) ,RestoreAtalho()},BMP_FILTRO, TOOL_FILTRO},;
							{TIP_PROJ_CONSULTAS, {||oMenu3:Activate(nScreVal1,nScreVal2,oDlg) },BMP_PROJ_CONSULTAS,TOOL_PROJ_CONSULTAS},;
							{TIP_PROJ_ESTRUTURA, {||A200CtrMenu(@oMenu,oTree,l200Visual,cArquivo,oMenu2,nDlgPln,lSimula),oMenu:Activate(nScreVal1,nScreVal2,oDlg) },BMP_PROJ_ESTRUTURA,TOOL_PROJ_ESTRUTURA}}

				Else
					aMenu := {;
							{TIP_PROJ_INFO,      {||ClearAtalho() ,PmsPrjInf() ,RestoreAtalho()}, BMP_PROJ_INFO, TOOL_PROJ_INFO},;
							{TIP_FERRAMENTAS,    {||A200CtrMenu(@oMenu,oTree,l200Visual,cArquivo,oMenu2,nDlgPln,lSimula),oMenu2:Activate(nScreVal1,nScreVal2,oDlg) }, BMP_FERRAMENTAS, TOOL_FERRAMENTAS},;
							{TIP_FILTRO,         {||ClearAtalho() ,If(PmsCfgDlg(aConfig),Eval(bRefresh),Nil) ,RestoreAtalho()}, BMP_FILTRO, TOOL_FILTRO},;
							{TIP_PROJ_CONSULTAS, {||oMenu3:Activate(nScreVal1,nScreVal2,oDlg) }, BMP_PROJ_CONSULTAS, TOOL_PROJ_CONSULTAS},;
							{TIP_PROJ_ESTRUTURA, {||A200CtrMenu(@oMenu,oTree,l200Visual,cArquivo,oMenu2,nDlgPln,lSimula),oMenu:Activate(nScreVal1,nScreVal2,oDlg) },BMP_PROJ_ESTRUTURA, TOOL_PROJ_ESTRUTURA}}
				EndIf
	    	Endif
		Else
			MENU oMenu3 POPUP
				MENUITEM STR0084 ACTION ClearAtalho() ,PmsDlgAF8Gnt(cRevisa,aConfig,@oDlg,@oTree,cArquivo) ,RestoreAtalho()  //"Grafico de gantt..."
				MENUITEM STR0120 ACTION ClearAtalho() ,PmsDlgAF8Rec(cRevisa,@oTree,cArquivo) ,RestoreAtalho() //"Alocacao dos recursos do projeto..."
				MENUITEM STR0121 ACTION ClearAtalho() ,Pms200View(STR0121,{|| PMSC110(AF8->AF8_PROJET,cRevisa,,,@oTree,cArquivo) })  ,RestoreAtalho() //"Alocacao dos recursos por periodo..."
				MENUITEM STR0140 ACTION ClearAtalho() ,Pms200View(STR0140,{|| PMSC112(AF8->AF8_PROJET,cRevisa,@oTree,cArquivo) }) ,RestoreAtalho() //"Alocacao dos recursos por equipe por periodo..."###"Alocacao dos recursos por equipe por periodo..."
				MENUITEM STR0122 ACTION ClearAtalho() ,PmsDlgAF8Eqp(cRevisa,@oTree,cArquivo) ,RestoreAtalho() //"Alocacao de equipes do projeto..."
				MENUITEM STR0123 ACTION ClearAtalho() ,Pms200View(STR0123,{||PMSC115(AF8->AF8_PROJET,cRevisa,@oTree,cArquivo) }) ,RestoreAtalho() //"Alocacao de equipes por periodo..."
				MENUITEM STR0162 ACTION ClearAtalho() ,Processa({|| PmsRedeRel(oTree,cArquivo)}) ,RestoreAtalho() //"Redes de relacionamentos"
				MENUITEM STR0191 ACTION ClearAtalho() ,MsAguarde({|| PmsAponRec(oTree,cArquivo)}) ,RestoreAtalho() //'Apontamento de recursos'
				If lCalcTrib
					MENUITEM STR0283 ACTION ClearAtalho() ,PmsDlgAN9Vis(),RestoreAtalho()  //"Tributos do Projeto"
	   			EndIf
			ENDMENU
			For nZ	:=	1 To Len(oMenu3:aItems)
				AAdd(aMenuAt,{ATA_PROJ_CONSULTAS+"V"+STRZERO(nZ,2),1,oMenu3:aItems[nZ]:cCaption,oMenu3:aItems[nZ]:bAction,oMenu3,Nil})
			Next nZ

			MENU oMenu POPUP
				MENUITEM STR0003 ACTION ClearAtalho() ,PMS200to201(2,@oTree,,cArquivo) ,RestoreAtalho() //"Visualizar"

				If nDlgPln == PMS_VIEW_TREE
					MENUITEM STR0132 ACTION ClearAtalho() ,Procurar(oTree, @cSearch, cArquivo) ,RestoreAtalho() //"Procurar..."
					MENUITEM STR0133 ACTION ClearAtalho() ,ProcurarP(oTree, @cSearch, cArquivo) ,RestoreAtalho() //"Procurar proxima"
				EndIf
			ENDMENU
			For nZ	:= 1 To Len(oMenu:aItems)
				AAdd(aMenuAt,{ATA_PROJ_ESTRUTURA+"V"+STRZERO(nZ,2),1,oMenu:aItems[nZ]:cCaption,oMenu:aItems[nZ]:bAction,oMenu,Nil})
			Next nZ

			If (GetVersao(.F.) == "P10" )

				If nDlgPln == PMS_VIEW_SHEET
					aMenu := {;
				         	{TIP_PROJ_INFO,      {||ClearAtalho() ,PmsPrjInf() ,RestoreAtalho()}, BMP_PROJ_INFO, TOOL_PROJ_INFO},;
				         	{TIP_COLUNAS,        {||ClearAtalho() ,Iif(lChgCols := PMC200Cfg("",0,0),oDlg:End(),Nil) ,RestoreAtalho()}, BMP_COLUNAS, TOOL_COLUNAS},;
				         	{TIP_FILTRO,         {||ClearAtalho() ,If(PmsCfgDlg(aConfig),Eval(bRefresh),Nil) ,RestoreAtalho()}, BMP_FILTRO, TOOL_FILTRO},;
				         	{TIP_PROJ_CONSULTAS, {||oMenu3:Activate(140,45,oDlg) }, BMP_PROJ_CONSULTAS, TOOL_PROJ_CONSULTAS},;
				         	{TIP_PROJ_ESTRUTURA, {||A200CtrMenu(@oMenu,oTree,l200Visual,cArquivo,oMenu2,nDlgPln,lSimula),oMenu:Activate(175,45,oDlg) }, BMP_PROJ_ESTRUTURA, TOOL_PROJ_ESTRUTURA}}
				Else
					aMenu := {;
				         	{TIP_PROJ_INFO,      {||ClearAtalho() ,PmsPrjInf() ,RestoreAtalho()}, BMP_PROJ_INFO, TOOL_PROJ_INFO},;
				         	{TIP_FILTRO,         {||ClearAtalho() ,If(PmsCfgDlg(aConfig),Eval(bRefresh),Nil) ,RestoreAtalho()}, BMP_FILTRO, TOOL_FILTRO},;
				         	{TIP_PROJ_CONSULTAS, {||oMenu3:Activate(105,45,oDlg) }, BMP_PROJ_CONSULTAS, TOOL_PROJ_CONSULTAS},;
				         	{TIP_PROJ_ESTRUTURA, {||A200CtrMenu(@oMenu,oTree,l200Visual,cArquivo,oMenu2,nDlgPln,lSimula),oMenu:Activate(140,45,oDlg) }, BMP_PROJ_ESTRUTURA, TOOL_PROJ_ESTRUTURA}} //"&Estrutura"
				EndIf

			Else
				//Acoes relacionadas
				If nDlgPln == PMS_VIEW_SHEET
					aMenu := {;
							{TIP_PROJ_INFO,      {||ClearAtalho() ,PmsPrjInf() ,RestoreAtalho()}, BMP_PROJ_INFO, TOOL_PROJ_INFO},;
							{TIP_COLUNAS,        {||ClearAtalho() ,Iif(lChgCols := PMC200Cfg("",0,0),oDlg:End(),Nil) ,RestoreAtalho()}, BMP_COLUNAS, TOOL_COLUNAS},;
							{TIP_FILTRO,         {||ClearAtalho() ,If(PmsCfgDlg(aConfig),Eval(bRefresh),Nil) ,RestoreAtalho()}, BMP_FILTRO, TOOL_FILTRO},;
							{TIP_PROJ_CONSULTAS, {||oMenu3:Activate(nScreVal1,nScreVal2,oDlg) }, BMP_PROJ_CONSULTAS, TOOL_PROJ_CONSULTAS},;
							{TIP_PROJ_ESTRUTURA, {||A200CtrMenu(@oMenu,oTree,l200Visual,cArquivo,oMenu2,nDlgPln,lSimula),oMenu:Activate(nScreVal1,nScreVal2,oDlg) }, BMP_PROJ_ESTRUTURA, TOOL_PROJ_ESTRUTURA}}
				Else
					aMenu := {;
							{TIP_PROJ_INFO,      {||ClearAtalho() ,PmsPrjInf() ,RestoreAtalho()}, BMP_PROJ_INFO, TOOL_PROJ_INFO},;
							{TIP_FILTRO,         {||ClearAtalho() ,If(PmsCfgDlg(aConfig),Eval(bRefresh),Nil) ,RestoreAtalho()}, BMP_FILTRO, TOOL_FILTRO},;
							{TIP_PROJ_CONSULTAS, {||oMenu3:Activate(nScreVal1,nScreVal2,oDlg) }, BMP_PROJ_CONSULTAS, TOOL_PROJ_CONSULTAS},;
							{TIP_PROJ_ESTRUTURA, {||A200CtrMenu(@oMenu,oTree,l200Visual,cArquivo,oMenu2,nDlgPln,lSimula),oMenu:Activate(nScreVal1,nScreVal2,oDlg) }, BMP_PROJ_ESTRUTURA, TOOL_PROJ_ESTRUTURA}} //"&Estrutura"
				EndIf

			Endif
		EndIf

		If ExistBlock("PMA200MENU")   // ponto de entrada concebido originalmente para
			ExecBlock("PMA200MENU",.F.,.F.,{oTree,cArquivo}) // manipular array aMenu - Alt.Estrutura PMSA410
		EndIf

		If hasTemplate("CCT") .and. ExistTemplate("PMA200MENU")   // ponto de entrada concebido originalmente para
			ExecTemplate("PMA200MENU",.F.,.F.,{oTree,cArquivo}) // manipular array aMenu - Alt.Estrutura PMSA410
		EndIf

		AAdd(aMenu, {STR0163,  {||ClearAtalho() ,SetAtalho(aMenuAt,aMenu,.T.) ,RestoreAtalho()}, "ATALHO", STR0164}) //"Atalhos"##"Atalhos"

		// le os atalhos desde o profile
		CarregaAtalhos(aMenu,aMenuAt,Iif(l200Visual,"V","A")	)

		// configura as teclas de atalho
	 	SetAtalho(aMenuAt,aMenu,.F.)

		If nDlgPln == PMS_VIEW_SHEET
			aCampos := {{"AF9_TAREFA","AFC_EDT",8,,,.F.,"",},{"AF9_DESCRI","AFC_DESCRI",55,,,.F.,"",150}}

			//
			// MV_PMSCPLN
			//
			// 1 - a configuraÁ„o da planilha È utilizada exclusivamente pelo usu·rio que criou
			// 2 - a configuraÁ„o da planilha È utilizada por qualquer usu·rio (default)
			//

			If GetNewPar("MV_PMSCPLN", 2) == 1
				A200Opn(@aCampos, PMS_PROFILE_DIR + PMS_PATH_SEP + "pmsa200." + __cUserID)
			Else
				A200Opn(@aCampos)
			EndIf

			PmsPlanAF8(cCadastro,cRevisa,aCampos,@cArquivo,,,@lOk,aMenu,@oDlg,,,aConfig,,nIndent)
		Else
			If (GetVersao(.F.) == "P10" )
				bContext	:=	{|o,x,y| A200CtrMenu(@oMenu,oTree,l200Visual,cArquivo,oMenu2,nDlgPln,lSimula) , oMenu:Activate(x,y-50,oDlg) }
			Else
				//Acoes relacionadas
				bContext	:=	{|o,x,y| A200CtrMenu(@oMenu,oTree,l200Visual,cArquivo,oMenu2,nDlgPln,lSimula) , oMenu:Activate(nScreVal1,nScreVal2,oDlg) }
			Endif
			PmsDlgAF8(cCadastro,@oMenu,cRevisa,@oTree,,{||A200CtrMenu(@oMenu,oTree,l200Visual,cArquivo,oMenu2,nDlgPln,lSimula)},@lOk,,aMenu,@oDlg,aConfig,@cArquivo,,bContext)
		EndIf

		If ExistBlock("PMA200Sa")
			ExecBlock("PMA200Sa", .F., .F., {nOpcx})
		EndIf

		// grava os atalhos no profile
		GravaAtalhos(aMenuAt,Iif(l200Visual,"V","A")	)
		If lChgCols
			PMS200Dlg(cAlias,nReg,nOpcx,cR1,cR2,cVers,lSimula,.F.)
		Else
			If l200Exclui .And. lOk

				// verifica a existencia do ponto de entrada PMA200DEL
				If ExistBlock("PMA200DEL")
					lDelPrj:= ExecBlock("PMA200DEL",.F.,.F.,)

					// verifica se o conteudo do retorno È logico pois o retorno
					// foi implementado apos ser implementado o ponto de entrada
					If (ValType(lDelPrj) == "L") .And. !lDelPrj

						// limpar os atalhos das teclas CONTROL
						ClearAtalho()
						Return
					EndIf
				EndIf
				MaDelAF8(,AF8->(RecNo()))
			EndIf
		Endif

		If ExistBlock("PMA200AL")
			ExecBlock("PMA200AL", .F., .F., {l200Inclui, l200Visual, l200Altera, l200Exclui})
		EndIf

		// limpar os atalhos das teclas CONTROL
		ClearAtalho()

		// destroi os objetos - Blindagem para garantir a destruicao dos objetos criados
		PMSFreeObj(oMenu)
		PMSFreeObj(oMenu2)
		PMSFreeObj(oMenu3)
		PMSFreeObj(oDlg)
		PMSFreeObj(oTree)

	EndIf

	FreeUsedCode(.T.)

EndIf


//***************************
// IntegraÁ„o com o SIGAPCO *
//***************************
PcoFinLan("000350")

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥PMS200to201≥ Autor ≥ Edson Maricate       ≥ Data ≥ 09-02-2001 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Funcao que monta o a Tarefa no Tree do Projeto.               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥PMSA200                                                       ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PMS200to201(nOpc,oTree,cEDT,cArquivo)
Local aArea    := GetArea()
Local aAreaTMP := {}
Local cProjeto
Local cRevisao
Local cNivAtu
Local cTrfAtu	:= ''
Local nRecAF9
Local nRecAFC
Local aGetCpos
Local cAlias
Local nRecAlias
Local lRefresh  := .T.
Local lContinua := .T.

If ExistBlock("PMA200Tr")
	If !ExecBlock("PMA200Tr", .F., .F., {nOpc, cEdt})
		lRefresh  := .F.
		lContinua := .F.
	EndIf
EndIf

If lContinua
	If oTree!= Nil
		cAlias	:= SubStr(oTree:GetCargo(),1,3)
		nRecAlias	:= Val(SubStr(oTree:GetCargo(),4,12))
	Else
		aAreaTMP := (cArquivo)->(GetArea())
		cAlias := (cArquivo)->ALIAS
		nRecAlias := (cArquivo)->RECNO
	Endif
	
	If nOpc == 3
		If cAlias == "AF9"
			Aviso(STR0090,STR0091,{STR0019},2) //"Opcao invalida."###"A tarefa e o ultimo elemento na estrutura do projeto. Novos niveis e tarefas so poderao ser adicionados a uma EDT." //"Ok"
			Return lRefresh
		Elseif cAlias == "AF8"
			Aviso(STR0090,STR0285,{STR0019},2) //"Opcao invalida."###"O Projeto È o primeiro elemento na estrutura do projeto. Novos niveis e tarefas so poderao ser adicionados a uma EDT." //"Ok"
			Return lRefresh
		EndIf
	EndIf


	dbSelectArea(cAlias)
	dbGoto(nRecAlias)

	If cAlias == "AFC"
		cProjeto := AFC->AFC_PROJET

	ElseIf cAlias == "AF9"
		cProjeto := AF9->AF9_PROJET

	Endif
	Do Case
		Case nOpc == 3
			If cEDT == "1"
				cNivelAFC := If(cAlias=="AFC",AFC->AFC_NIVEL,"000")
				If cNivelAFC <> "000"
					cProjeto	:= AFC->AFC_PROJET
					cRevisao	:= cRevisa
					cNivAtu		:= AFC->AFC_NIVEL
					cTrfAtu		:= AFC->AFC_EDT
				EndIf
				aGetCpos := {	{"AFC_PROJET",AF8->AF8_PROJET,.F.},;
								{"AFC_REVISA",cRevisa,.F.},;
								{"AFC_CALEND",AF8->AF8_CALEND,.T.},;
								{"AFC_EDTPAI",cTrfAtu,.F.}}

				If GetNewPar("MV_PMSTCOD","1")=="2" .Or. GetNewPar("MV_PMSTCOD","1")=="3"
					aAdd(aGetCpos,{"AFC_EDT",PmsNumAFC(AF8->AF8_PROJET,cRevisa,cNivelAFC,cTrfAtu,,.F.),.F.})
				EndIf
				nRecAFC	:= PMSA201(3,aGetCpos,cNivelAFC,@lRefresh)
				If nRecAFC <> Nil .And. cArquivo == Nil
					PMSTreeEDT(@oTree,cVersao)
				EndIf
			Else
				cNivelAFC := If(cAlias=="AFC",AFC->AFC_NIVEL,"000")
				If cNivelAFC <> "000"
					cProjeto	:= AFC->AFC_PROJET
					cRevisao	:= cRevisa
					cNivAtu		:= AFC->AFC_NIVEL
					cTrfAtu		:= AFC->AFC_EDT
				EndIf
				aGetCpos := {	{"AF9_PROJET",AF8->AF8_PROJET,.F.},;
								{"AF9_REVISA",cRevisa,.F.},;
								{"AF9_CALEND",AF8->AF8_CALEND,.T.},;
								{"AF9_CNVPRV",AF8->AF8_CNVPRV,.T.},;
								{"AF9_DTCONV",AF8->AF8_DTCONV,.T.},;
								{"AF9_EDTPAI",cTrfAtu,.F.},;
				                {"AF9_BDI",AF8->AF8_BDIPAD,.T.} }

				If GetNewPar("MV_PMSTCOD","1")=="2" .Or. GetNewPar("MV_PMSTCOD","1")=="3"
					aAdd(aGetCpos,{"AF9_TAREFA",PmsNumAF9(AF8->AF8_PROJET,cRevisa,cNivelAFC,cTrfAtu,,.F.),.F.})
				EndIf

				nRecAF9	:= PMSA203(3,aGetCpos,cNivelAFC,,,,,,,,@lRefresh)
			EndIf
		Case nOpc == 2 .And. cAlias == "AFC"
			PMSA201(2,,"000",@lRefresh)
		Case nOpc == 2 .And. cAlias == "AF9"
			PMSA203(2,,"000",,,,,,,,@lRefresh)
		Case nOpc == 4 .And. cAlias == "AFC"
			If cRevisa <> AFC->AFC_REVISA
				AFC->(dbSetOrder(1))
				AFC->(dbSeek(xFilial()+AFC->AFC_PROJET+cRevisa+AFC->AFC_EDT))
			EndIf
			PMSA201(4,,"000",@lRefresh)
		Case nOpc == 4 .And. cAlias == "AF9"
			If cRevisa <> AF9->AF9_REVISA
				AF9->(dbSetOrder(1))
				AF9->(dbSeek(xFilial()+AF9->AF9_PROJET+cRevisa+AF9->AF9_TAREFA))
			EndIf
			PMSA203(4,,"000",,,,,,,,@lRefresh)
		Case nOpc == 5 .And. cAlias == "AFC"
			If cRevisa <> AFC->AFC_REVISA
				AFC->(dbSetOrder(1))
				AFC->(dbSeek(xFilial()+AFC->AFC_PROJET+cRevisa+AFC->AFC_EDT))
			EndIf
			PMSA201(5,,"000",@lRefresh)
		Case nOpc == 5 .And. cAlias == "AF9"
			If cRevisa <> AF9->AF9_REVISA
				AF9->(dbSetOrder(1))
				AF9->(dbSeek(xFilial()+AF9->AF9_PROJET+cRevisa+AF9->AF9_TAREFA))
			EndIf
			PMSA203(5,,"000",,,,,,,,@lRefresh)
	EndCase

	FreeUsedCode(.T.)

	If oTree == Nil
		RestArea(aAreaTMP)
	EndIf

EndIf

RestArea(aArea)

Return( lRefresh )



/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥Pms200Atu≥ Autor ≥ Edson Maricate         ≥ Data ≥ 09-02-2001 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Atualizacao dos arquivos na Inclusao do Projeto.              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥PMSA200                                                       ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function Pms200Atu(oModel)
Local aArea	:= GetArea()
Local lRet
Local nOperation
Local aButtons := {}
Local aUsButtons := {}
Local aCposAlt	:= {"AF8_TRUNCA","AF8_BDI","AF8_BDIPAD","AF8_ENCARG","AF8_SALBAS"}
Local aOldVal	:= {}
Local lRecalc	:= .F.
Local nx
Local nPos      := 0
Local cAlias
Local lVersao := PMSVersion()
Local lExistANE := lVersao
Local lCalcTrib := .F.

If ValType(oModel) == "O"
	lRet:= FWFormCommit(oModel)
	nOperation := oModel:GetOperation()
Else
	lRet:= .T.
	nOperation := If(Inclui, 3, If(Altera, 4, 2))
EndIf

dbSelectArea("AF8")
dbSetOrder(1)
cAlias:=ALIAS()
MsSeek(xFilial("AF8")+M->AF8_PROJET)
aArea	:= GetArea()
lCalcTrib := AF8->AF8_PAR006 == '1'
If lRet .AND. (nOperation == 3 )
	PmsAvalPrj("AF8",1)
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥Grava os campos Memos Virtuais         ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	If Type("aMemos") == "A" .and. Type("AF8_OBS") != "U"
		For nX := 1 to Len(aMemos)
			cVar := aMemos[nX][2]
			//IncluÌdo parametro com o nome da tabela de memos => para mÛdulo APT
			cAliasMemo := If(len(aMemos[nX]) == 3,aMemos[nX][3],Nil)
			MSMM(,TamSx3(aMemos[nX][2])[1],,&cVar,1,,,cAlias,aMemos[nX][1],cAliasMemo)
		Next nX
	EndIf
ElseIf lRet .AND. (nOperation == 4 )

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥Grava os campos Memos Virtuais         ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	If Type("aMemos") == "A" .and. Type("AF8_OBS") != "U"
		For nX := 1 to Len(aMemos)
			cVar := aMemos[nX][2]
			//IncluÌdo parametro com o nome da tabela de memos => para mÛdulo APT
			cAliasMemo := If(len(aMemos[nX]) == 3,aMemos[nX][3],Nil)
			MSMM(,TamSx3(aMemos[nX][2])[1],,&cVar,1,,,cAlias,aMemos[nX][1],cAliasMemo)
		Next nX
	EndIf


	If AF8ComAJT(AF8->AF8_PROJET)
		lRecalc := .T.
		aArea:=GetArea()
		dbSelectArea("AJY")
		dbSetOrder(1)
		AJY->(dbSeek(xFilial("AJY")+AF8->AF8_PROJET+AF8->AF8_REVISA))
		Do While !AJY->(Eof()) .And. AJY->( AJY_FILIAL+AJY_PROJET+AJY_REVISA ) == xFilial("AJY")+AF8->AF8_PROJET+AF8->AF8_REVISA
			If AJY->AJY_GRORGA=='A' .And. AJY->AJY_TPPARC $ '1;2'
				RecLock( "AJY", .F. )
				AJY->AJY_CUSTD  :=	IIf(AF8->AF8_DEPREC $ "13", AJY->AJY_DEPREC, 0) +;
									IIf(AF8->AF8_JUROS  $ "13", AJY->AJY_VLJURO, 0) +;
									IIf(AF8->AF8_MDO    $ "13", AJY->AJY_MDO   , 0) +;
									IIf(AF8->AF8_MATERI $ "13", AJY->AJY_MATERI, 0) +;
									IIf(AF8->AF8_MANUT  $ "13", AJY->AJY_MANUT , 0)
				AJY->AJY_CUSTIM :=	IIf(AF8->AF8_DEPREC $ "23", AJY->AJY_DEPREC, 0) +;
									IIf(AF8->AF8_JUROS  $ "23", AJY->AJY_VLJURO, 0) +;
									IIf(AF8->AF8_MDO    $ "23", AJY->AJY_MDO   , 0)
				MsUnlock()
			EndIf

			AJY->(dbSkip())
		EndDo
		RestArea(aArea)
	EndIf
	For nX := 1 to Len(aCposAlt)
		If FieldPos(aCposAlt[nX]) > 0 .AND. (nPos := aScan( aOldVal,{|xValor| xValor[1] == aCposAlt[nX]}))>0
			If aOldVal[nPos][2] <> AF8->(FieldGet(FieldPos(aCposAlt[nX])))
				lRecalc := (Aviso(STR0165, STR0166, {STR0150, STR0167}, 2)==1) //"Atencao!"##"Foram alteradas algumas configuraÁıes que podem influenciar diretamente no custo previsto deste projeto. Voce deseja recalcular o custo neste momento ?"##"Sim"##"Mais Tarde"
				Exit
			EndIf
		EndIf
	Next nX

	If (AF8->AF8_RECALC=="1") .Or. lRecalc
		PMS200ReCalc(.F.,lCalcTrib)
	EndIf
Endif
RestArea(aArea)
Return lRet


/*/{Protheus.doc} Pms200rev
Funcao que cria a revisao do Projeto ( Automatico ).

@param lSimula, ${param_type}, (DescriÁ„o do par‚metro)
@param cRevOrig, character, (DescriÁ„o do par‚metro)
@return ${return}, ${return_description}

@author Edson Maricate
@since 09-02-2001
@version 1.0
/*/
Function Pms200rev(lSimula,cRevOrig)
Local bCampo		:= {|n| FieldName(n) }
Local cGetMemo	:= CriaVar("AFE_MEMO")
Local cNextVer	:= ""
Local lGravaOk	:= .F.
Local lRet 		:= .T.
Local nx			:= 0
Local oEnchoice	:= Nil
Local oMemo		:= Nil
Local oPanel		:= Nil
Local oSize		:= Nil

DEFAULT lSimula := .F.

PRIVATE 	cSavScrVT,;
			cSavScrVP,;
			cSavScrHT,;
			cSavScrHP,;
			CurLen,;
			nPosAtu:=0,;
			nPosAnt:=9999,;
			nColAnt:=9999

If !lSimula
	If AF8->AF8_PRJREV=="2" .And. AF8->AF8_STATUS<>"2"
		If Aviso(STR0027,STR0028,{STR0029,STR0030},2) == 1 //"Controle de Revisao"###"Este projeto esta configurado para criar alteracoes automaticas nas alteracoes efetuadas. Confirma alteracao ?"###"Confirmar"###"Cancelar"

			// carrega as variaveis de memoria AFE
			dbSelectArea("AFE")
			RegToMemory("AFE",.T.)
			M->AFE_PROJET	:= AF8->AF8_PROJET
			M->AFE_DATAI	:= MsDate()
			M->AFE_HORAI	:= Time()
			M->AFE_NOME		:= UsrRetName(RetCodUsr())
			M->AFE_DATAF	:= MsDate()
			M->AFE_HORAF	:= Time()
			M->AFE_USERF	:= RetCodUsr()
			M->AFE_REVISA	:= AF8->AF8_REVISA
			M->AFE_DESCRI	:= AF8->AF8_DESCRI
			M->AFE_COMENT	:= ""
			M->AFE_USERI	:= RetCodUsr()

			DEFINE MSDIALOG oDlg TITLE STR0035 FROM 8,0 TO 31,78 OF oMainWnd //"Gerenciamento de Revisoes"

				oSize := FwDefSize():New(.T.,,,oDlg)
				oSize:lLateral := .F.
				oSize:lProp := .T.
		
				oSize:AddObject("TOP",100,40,.T.,.T.)
				oSize:AddObject("ALLCLIENT",100,60,.T.,.T.)
	
				oSize:Process()
	
				oEnChoice := MsMGet():New("AFE" ,AFE->(RecNo()),3,,,,,;
									{oSize:GetDimension("TOP","LININI"),oSize:GetDimension("TOP","COLINI"),oSize:GetDimension("TOP","LINEND"),oSize:GetDimension("TOP","COLEND")};
									,,3,,,,oDlg,,,,,,,,,,,)
				
				oPanel := TPanel():New(oSize:GetDimension("ALLCLIENT","LININI"),oSize:GetDimension("ALLCLIENT","COLINI"),"",oDlg,NIL,.T.,.F.,NIL,NIL,oSize:GetDimension("ALLCLIENT","XSIZE")-5,oSize:GetDimension("ALLCLIENT","YSIZE"),.T.,.F. )

				@ 1,2 Say STR0277 of oPanel Pixel  //"Comentarios resumido"
				@ 10,2 GET oMemo VAR M->AFE_MEMO MEMO SIZE oSize:GetDimension("ALLCLIENT","XSIZE")-10,20 VALID MEMOVALID() PIXEL OF oPanel
				@ 32,2 Say STR0278 of oPanel Pixel  //"Comentarios completo"
				@ 40,2 GET oMemo2 VAR M->AFE_COMENT MEMO SIZE oSize:GetDimension("ALLCLIENT","XSIZE")-10,40 PIXEL OF oPanel

			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lGravaOk:=.T.,oDlg:End()},{|| lRet:=.F.,oDlg:End()}) CENTERED

			If lGravaOk
				cNextVer := Soma1(AF8->AF8_REVISA)

				// verifica se a versao nao existe e pega a proxima
				dbSelectArea("AFE")
				dbSetOrder(1)
				While dbSeek(xFilial()+AF8->AF8_PROJET+cNextVer)
					cNextVer := Soma1(cNextVer)
				End
				Begin Transaction
					RecLock("AFE",.T.)
					For nx := 1 TO FCount()
						FieldPut(nx,M->&(EVAL(bCampo,nx)))
					Next nx
					AFE->AFE_FILIAL := xFilial("AFE")
					AFE->AFE_REVISA	:= cNextVer
					AFE->AFE_MEMO	:= cGetMemo
					AFE->AFE_TIPO   := "1" // Projeto Normal
					MSMM(,TamSx3("AFE_COMENT")[1],,M->AFE_COMENT,1,,,"AFE","AFE_CODMEM")
					MsUnlock()

					MaPmsRevisa(AF8->(RecNo()),1,cRevOrig,cNextVer)
				End Transaction
			EndIf
		Else
			lRet := .F.
		EndIf
		cRevisa := AF8->AF8_REVISA
	EndIf
EndIf

Return lRet

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥PMS200Alt≥ Autor ≥ Edson Maricate         ≥ Data ≥ 09-02-2001 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Funcao de alteracao no cadastro do Projeto.                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥PMSA200,SIGAPMS                                               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PMS200Alt(cAlias,nReg,nOpcx)
Local aButtons := {}
Local aUsButtons := {}
Local aCposAlt	:= {"AF8_TRUNCA","AF8_BDI","AF8_BDIPAD","AF8_ENCARG","AF8_SALBAS"}
Local aOldVal	:= {}
Local lRecalc	:= .F.
Local nx
Local nPos      := 0
Local aArea
Local lRet          := .T.
Local cStatus		:= ""

Local lCalcTrib := AF8->AF8_PAR006 == '1'	//Verifica se havera calculo de impostos para produtos

If PmsChkUser(AF8->AF8_PROJET,,Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT)),"  ",3,"ESTRUT",AF8->AF8_REVISA)

	If ExistBlock("PMS200A1")
		ExecBlock("PMS200A1",.F.,.F.)
	EndIf

	//Inclui Botıes na OpÁ„o Alt.Cadastro no AÁıes Relacionadas.
	If ExistBlock("PM200BU2")
		If ValType(aUsButtons := ExecBlock("PM200BU2", .F., .F.)) == "A"
			aEval(aUsButtons, { |x| aAdd(aButtons, x)})
		EndIf
	EndIf
	For nx := 1 to Len(aCposAlt)
		If FieldPos(aCposAlt[nx]) > 0
			aAdd(aOldVal,{aCposAlt[nx],AF8->(FieldGet(FieldPos(aCposAlt[nx])))})
		EndIf
	Next

	If lRet

		cTitulo      := STR0001 // 'Gerenciamento de Projetos'
		cPrograma    := 'PMSA200'
		nOperation   := MODEL_OPERATION_UPDATE
		__nOper      := nOperation
		bOk          := {|| .T. } //"Deseja Realizar o bloqueio/desbloqueio do projeto ou etapas ? "
		nOpca 		 := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,bOk, /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ )
		__nOper      := 0

		// verifica a existencia do ponto de entrada PMS200A2
		If nOpca == 0 .And. ExistBlock("PMS200A2")
			ExecBlock("PMS200A2",.F.,.F.)
		EndIf

	EndIf
Else
	Aviso(STR0240, STR0241, {STR0242}, 2)
EndIf

Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥PMS200Cli≥ Autor ≥ Edson Maricate         ≥ Data ≥ 09-02-2001 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Valida o codigo do cliente digitado.                          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥PMSA200,SIGAPMS                                               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PMS200Cli()
Local lRet

If Empty(M->AF8_LOJA)
	lRet := Vazio() .Or. ExistCpo("SA1",M->AF8_CLIENT)
Else
	lRet := Vazio() .Or. ExistCpo("SA1",M->AF8_CLIENT+M->AF8_LOJA)
EndIf

Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥PMS200Ok≥ Autor ≥ Edson Maricate          ≥ Data ≥ 09-02-2001 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Validacao TudoOk do cadastro de Projetos .                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥PMSA200,SIGAPMS                                               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PMS200Ok(oModel)
Local lRet	:= .T.

If ValType(oModel) == "O"
	Inclui := IIf(oModel:GetOperation() == 3,.T.,.F.)
	Altera := IIf(oModel:GetOperation() == 4,.T.,.F.)
EndIf

dbSelectArea("AF8")
dbSetOrder(1)
MsSeek(xFilial("AF8")+M->AF8_PROJET)
If !Empty(M->AF8_CLIENT) .And. Empty(M->AF8_LOJA)
	HELP("   ",1,"PMSA20002")
	lRet := .F.
EndIf

If lRet .And. Empty(M->AF8_CLIENT) .And. !Empty(M->AF8_LOJA)
	HELP("   ",1,"PMSA20003")
	lRet := .F.
EndIf

If lRet .And. !MayIUseCode("AF8" + xFilial("AF8") + M->AF8_PROJET)
	lRet := .F.
EndIf

If lRet .And. !Inclui .And. !A200Encerra(M->AF8_FASE,AF8->AF8_FASE,AF8->AF8_PROJET,AF8->AF8_REVISA,@M->AF8_ENCPRJ)
	lRet := .F.
EndIf

If lRet .And. (!Empty(M->AF8_FIMPER) .And. Empty(M->AF8_INIPER)) .Or. (M->AF8_FIMPER < M->AF8_INIPER)
	Help(   ,    , STR0318	, Nil, STR0319 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0320})
	lRet := .F.
EndIf

If lRet .And. ExistBlock("PMA200CO")
	lRet := ExecBlock("PMA200CO", .F., .F., {Inclui, Altera})
EndIf

Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥A200CtrMenu≥ Autor ≥ Edson Maricate       ≥ Data ≥ 09-02-2001 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Funcao que controla as propriedades do Menu PopUp.            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥PMSA200                                                       ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function A200CtrMenu(oMenu,oTree,lVisual,cArquivo,oMenu2,nDlgPln,lSimula)
Local aArea		:= GetArea()
Local cAlias
Local nRecView
Local lP200FER := Existblock("P200FER")

DEFAULT lSimula := .F.

If oTree == Nil
	If (cArquivo)->(Eof())
		(cArquivo)->(DbGoTop())
	EndIf

	cAlias	:= (cArquivo)->ALIAS
	nRecView	:= (cArquivo)->RECNO
Else
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
EndIf

dbSelectArea(cAlias)
dbGoto(nRecView)

If !lVisual
	Do Case
		Case cAlias == "AFC" .And. AFC->AFC_NIVEL=="001"
			If PmsChkUser(AFC->AFC_PROJET,,AFC->AFC_EDT,AFC->AFC_EDTPAI,3,"ESTRUT",AFC->AFC_REVISA)
				oMenu:aItems[1]:Enable()
				oMenu:aItems[2]:Enable()
				oMenu:aItems[3]:Enable()
				oMenu:aItems[6]:Enable()
				oMenu:aItems[7]:Enable()
				oMenu:aItems[8]:Enable()

				If oMenu2<>Nil
					oMenu2:aItems[1]:Enable()
					oMenu2:aItems[7]:Enable()
				EndIf
			ElseIf PmsChkUser(AFC->AFC_PROJET,,AFC->AFC_EDT,AFC->AFC_EDTPAI,2,"ESTRUT",AFC->AFC_REVISA)
				oMenu:aItems[1]:Disable()
				oMenu:aItems[2]:Disable()
				oMenu:aItems[3]:Enable()
				oMenu:aItems[6]:Disable()
				oMenu:aItems[7]:Disable()
				oMenu:aItems[8]:Disable()
				If oMenu2<>Nil
					oMenu2:aItems[1]:Enable()
					oMenu2:aItems[7]:Enable()
				EndIf
			Else
				oMenu:aItems[1]:Disable()
				oMenu:aItems[2]:Disable()
				oMenu:aItems[3]:Disable()
				oMenu:aItems[6]:Disable()
				oMenu:aItems[7]:Disable()
				oMenu:aItems[8]:Disable()
				If oMenu2<>Nil
					oMenu2:aItems[1]:Disable()
					oMenu2:aItems[7]:Disable()
				EndIf
			EndIf

			oMenu:aItems[4]:Enable()
			oMenu:aItems[5]:Disable()
			oMenu:aItems[9]:Disable()
			oMenu:aItems[10]:Disable()

		Case cAlias == "AFC" .And. AFC->AFC_NIVEL!="001"
			If PmsChkUser(AFC->AFC_PROJET,,AFC->AFC_EDT,AFC->AFC_EDTPAI,3,"ESTRUT",AFC->AFC_REVISA)
				oMenu:aItems[1]:Enable()
				oMenu:aItems[2]:Enable()
				oMenu:aItems[3]:Enable()
				oMenu:aItems[5]:Enable()
				oMenu:aItems[6]:Enable()
				oMenu:aItems[7]:Enable()
				oMenu:aItems[8]:Enable()
				oMenu:aItems[9]:Enable()

				If oMenu2<>Nil
					oMenu2:aItems[1]:Enable()
					oMenu2:aItems[7]:Enable()
				EndIf

			ElseIf PmsChkUser(AFC->AFC_PROJET,,AFC->AFC_EDT,AFC->AFC_EDTPAI,2,"ESTRUT",AFC->AFC_REVISA)
				oMenu:aItems[1]:Disable()
				oMenu:aItems[2]:Disable()
				oMenu:aItems[3]:Enable()
				oMenu:aItems[5]:Disable()
				oMenu:aItems[6]:Disable()
				oMenu:aItems[7]:Disable()
				oMenu:aItems[8]:Disable()
				oMenu:aItems[9]:Disable()

				If oMenu2<>Nil
					oMenu2:aItems[1]:Enable()
					oMenu2:aItems[7]:Enable()
				EndIf
			Else
				oMenu:aItems[1]:Disable()
				oMenu:aItems[2]:Disable()
				oMenu:aItems[3]:Disable()
				oMenu:aItems[5]:Disable()
				oMenu:aItems[6]:Disable()
				oMenu:aItems[7]:Disable()
				oMenu:aItems[8]:Disable()
				oMenu:aItems[9]:Disable()

				If oMenu2<>Nil
					oMenu2:aItems[1]:Disable()
					oMenu2:aItems[7]:Disable()
				EndIf
			EndIf

			oMenu:aItems[4]:Enable()

		Case cAlias == "AF9"
			oMenu:aItems[1]:Disable()
			oMenu:aItems[2]:Disable()
			oMenu:aItems[4]:Enable()
			oMenu:aItems[6]:Disable()
			oMenu:aItems[7]:Disable()
			oMenu:aItems[8]:Disable()

			If PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,3,"ESTRUT",AF9->AF9_REVISA)

				If AFFAltMenu(oTree, cArquivo)
					oMenu:aItems[3]:Enable()
				Else
					oMenu:aItems[3]:Disable()
				EndIf

				oMenu:aItems[5]:Enable()
				oMenu:aItems[9]:Enable()
				oMenu:aItems[10]:Enable()

				If oMenu2<>Nil
					oMenu2:aItems[1]:Enable()
					oMenu2:aItems[7]:Enable()
				EndIf
			ElseIf PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,2,"ESTRUT",AF9->AF9_REVISA)
				If AFFAltMenu(oTree, cArquivo)
					oMenu:aItems[3]:Enable()
				Else
					oMenu:aItems[3]:Disable()
				EndIf

				oMenu:aItems[5]:Disable()
				oMenu:aItems[9]:Enable()
				oMenu:aItems[10]:Enable()

				If oMenu2<>Nil
					oMenu2:aItems[1]:Enable()
					oMenu2:aItems[7]:Enable()
				EndIf
			Else
				oMenu:aItems[3]:Disable()
				oMenu:aItems[5]:Disable()
				oMenu:aItems[9]:Disable()
				oMenu:aItems[10]:Disable()

				If oMenu2<>Nil
					oMenu2:aItems[1]:Disable()
					oMenu2:aItems[7]:Disable()
				EndIf
			EndIf

		OtherWise
			oMenu:aItems[1]:Disable()
			oMenu:aItems[2]:Disable()
			oMenu:aItems[3]:Disable()
			oMenu:aItems[4]:Disable()
			oMenu:aItems[5]:Disable()
			oMenu:aItems[6]:Disable()
			oMenu:aItems[7]:Disable()
			oMenu:aItems[8]:Disable()
			oMenu:aItems[9]:Disable()
			oMenu:aItems[10]:Disable()

			If oMenu2<>Nil
				oMenu2:aItems[1]:Disable()
				oMenu2:aItems[7]:Disable()
			EndIf
	EndCase
	If oMenu2<>Nil
		If PmsChkUser(AF8->AF8_PROJET,,Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT)),"  ",2,"ESTRUT",AF8->AF8_REVISA)
			oMenu2:aItems[2]:Enable()
			oMenu2:aItems[3]:Enable()
			oMenu2:aItems[9]:Enable()
			oMenu2:aItems[10]:Enable()
		Else
			oMenu2:aItems[2]:Disable()
			oMenu2:aItems[3]:Disable()
			oMenu2:aItems[9]:Disable()
			oMenu2:aItems[10]:Disable()
		EndIf

		If lSimula
			oMenu2:aItems[8]:Disable()
		Else
			oMenu2:aItems[8]:Enable()
		EndIf

	EndIf
EndIf

IF lP200FER
	ExecBlock ("P200FER",.F.,.F.,oMenu2)
EndIF

RestArea(aArea)
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥PMS200Import≥ Autor ≥ Edson Maricate      ≥ Data ≥ 09-02-2001 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Funcao de chamada na copia de estruturas.                     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ nOrcPrj - 1:copia do orcamento                               ≥±±
±±≥          ≥           2:copia do projeto                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥Generico                                                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PMS200Import(oTree,cArquivo,nOrcPrj,lCalcTrib)
Local lRet      := .F.
Local lContinua := .T.
Local aImport   := {}
Local aArea     := GetArea()
Local aRet      := {}
Local cFilCopy	:=	Nil
Local aUser
Local cFilPrj	:=	Nil
Local cFilBkp	:=	cFilAnt
Local aParam := {,cFilAnt}
Local lCalc		:= .T.
Local aMarkPrj := {}
Local aPM100Cpy:= {}

Default lCalcTrib := .F.

If oTree != Nil
	cAlias:= SubStr(oTree:GetCargo(),1,3)
	nRecno:= Val(SubStr(oTree:GetCargo(),4,12))
Else
	cAlias := (cArquivo)->ALIAS
	nRecNo := (cArquivo)->RECNO
EndIf

If GetNewPar('MV_PMSTPCP','2') == '1'
	If !ParamBox({{ 9 ,STR0250,120 ,Nil,.T. },{ 1 ,STR0251,cFilAnt , 	 ,""  ,"SM0" ,"" ,15 ,.T. }} ,STR0252, aParam	,,,.F.,120,3, ) //"Selecione a filial origem dos dados"##"Filial origem"##"Selecionar filial origem"
		Return .F.
	Endif
	  //"Parametros"
	cFilPrj	:=	aParam[2]

	If ( __cUserId <> '000000' )
		// Para verificar se tem acesso a filial
		PswOrder(1)
	   If (  PswSeek(__cUserId, .T.) )
			aUser := Pswret(5)
			If ( Ascan(aUser[2][6],{|x| x=='@@@@' .Or. x==cEmpAnt+cFilPrj}) == 0 )
				If Aviso(STR0115,STR0253, {STR0254,STR0030}) == 1//'Atencao'##"Usuario sem acesso para esta filial##'Outra'##'Cancelar'
					Return PMS200Import(oTree, cArquivo, nOrcPrj, lCalcTrib)
				Else
					Return .F.
				Endif
			Else
				If cFilPrj == cFilAnt
					cFilPrj:= Nil
				Else
					cFilAnt:=	cFilPrj
				EndIf
			EndIf
		Endif
	Else
		cFilAnt:=	cFilPrj
	EndIf
Endif

If ExistBlock("PM200Cpy")
	aRet := ExecBlock("PM200Cpy", .F., .F.,{nOrcPrj,cAlias,nRecno})
	If ValType(aRet)=="A"
		lContinua := aRet[1]
		lRet      := aRet[2]
	EndIf
EndIf

If lContinua
	// exibe uma tela de selecao dos orcamentos/projetos para importacao
	If nOrcPrj == 1
		aImport := PmsSelTsk(STR0064, "AF1/AF5/AF2","AF5/AF2", STR0065, "AF1", ,,.T.,,@aMarkPrj)
		//"Selecione a EDT/Tarefa"###"Selecao Invalida"
	Else
		aImport := 	PmsSelTsk(STR0064,"AF8/AFC/AF9","AFC/AF9",STR0065,"AF8",AF8->AF8_PROJET,,.T.,,@aMarkPrj)
		//"Selecione a EDT/Tarefa"###"Selecao Invalida"
	EndIf

	If ExistBlock("PM100Cpy")
		
		aPM100Cpy :={	cAlias,;
						nRecno,;
						Iif(Len(aImport) > 0,aImport[1],Nil),;
						Iif(Len(aImport) > 0,aImport[2],Nil),;
						nOrcPrj,;
						aMarkPrj;
					}
		
		If ExecBlock("PM100Cpy", .F., .F.,aPM100Cpy)
			lContinua := .F.
			lRet := .F.
		EndIf
	EndIf

	cFilAnt	:=	cFilBkp
	If lContinua .AND. Len(aImport) > 0
		Processa({|| lRet := PmsPrjCopy(cAlias,nRecno,aImport[1],aImport[2],nOrcPrj,aMarkPrj,cFilPrj)},STR0103)  //"Copiando estrutura..."
	EndIf
EndIf

RestArea(aArea)

PMS200Rev()

If ExistBlock("PMACPYCAL")
	lCalc := ExecBlock("PMACPYCAL", .F., .F.)
EndIf

IF lCalc .and. lRet
	PMS200ReCalc(.F.,lCalcTrib)
ENDIF

Return lRet

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥Pms200User≥ Autor ≥Fabio Rogerio Pereira       ≥ Data ≥ 18/01/2002 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Funcao de configuracao dos usuarios do Projeto.                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥SIGAPMS                                                       	 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function Pms200User(cAlias,nReg,nOpcx)
Local cRevisa := AF8->AF8_REVISA
Local cRevisao:= CriaVar("AF8_REVISA",.F.)
Local aRotAnt
Local cPrgCall := Alltrim(FunName())
Local lPMS200Vis := ExistBlock("PMS200VISU")

If lPMS200Vis
     	ExecBlock("PMS200VISU",.F.,.F.)
EndIf

If cPrgCall == "PMSA410" .And.  aRotina != NIL
		aRotAnt     := aClone(aRotina)
		aRotina 	:= {	{ STR0002, "AxPesqui"  , 0 , 1},;   //"Pesquisar"
							{ STR0003, "PMS200Dlg" , 0 , 2},;   //"Visualizar"
							{ STR0004, "PMS200Dlg" , 0 , 3},;	 //"Incluir"
							{ STR0023, "PMS200Alt" , 0 , 4},;//"Alt.Cadastro"
							{ STR0024, "PMS200Dlg" , 0 , 4},;//"Alt.Estrutura"
							{ STR0062, "PMS200User", 0 , 6},;  //"Usuarios"
							{ STR0006, "PMS200Dlg" , 0 , 5},;//"Excluir"
							{ STR0079, "PMS200Leg" , 0 , 6}}   //"Legenda"
		nOpcx := 6  //para ficar igual a chamada do pmsa200()

EndIf
PmsUser(nOpcx,cRevisa,cRevisao)

If cPrgCall == "PMSA410" .And. aRotAnt != NIL
	aRotina := aClone(aRotAnt)
EndIf

Return(.T.)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥PMS200CMP≥ Autor ≥Fabio Rogerio Pereira   ≥ Data ≥ 15-03-2002 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Funcao que importa o cadastro de composicoes para uma        ≥±±
±±≥          ≥ nova tarefa do Projeto.                                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥PMSA200                                                       ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PMS200CMP(nRecAF8,oTree,cArquivo,lSimula)
Local oDlg
Local oDescri
Local nQuant	:= 0
Local cUM		:= ''
Local cDescri 	:= ''
Local cCompos 	:= SPACE(Len(AE1->AE1_COMPOS))
Local oBold
Local oUM
Local oBmp
Local lOk       := .F.
Local cAlias    := ""
Local nRecAlias := 0
Local nRecAF9   := 0
Local cTarefa   := Space(TamSx3("AF9_TAREFA")[1])
Local cRevisa   := ""
Local oQuant    := Nil
Local aDlgCom
Local aDlgVer

Default lSimula := .F.

If AF8ComAJT(AF8->AF8_PROJET)
	Aviso("AtenÁ„o","FunÁ„o indisponÌvel para composiÁ„o ˙nica",{"Ok"})
	Return lOk
EndIf
If oTree != Nil

	// verifica os dados da EDT/Tarefa posicionada no tree
	cAlias:= SubStr(oTree:GetCargo(),1,3)
	nRecAlias:= Val(SubStr(oTree:GetCargo(),4,12))
Else
	cAlias := (cArquivo)->ALIAS
	nRecAlias := (cArquivo)->RECNO
EndIf


If cAlias == "AFC"
	AE1->(DbSetOrder(1))
	AE1->(Dbseek(xFilial()))
	dbSelectArea(cAlias)
	dbGoto(nRecAlias)

	//Ponto de entrada para manipulacao(criacao) de uma nova Dialog no processo
	//de "Importacao de composicao"
	If Existblock("PMSDlgCom")
		aDlgVer := ExecBlock("PMSDlgCom",.F.,.F.)
		If ValType(aDlgVer)=="A"
			aDlgCom := aClone(aDlgVer)

			lOk := aDlgCom[1]
			If lOk
				cCompos := aDlgCom[2]
				cDescri := aDlgCom[3]
				nQuant	:= aDlgCom[4]
				cTarefa := aDlgCom[5]

			    //Validacao dos dados retornados pelo ponto de entrada, pois serao importantes para
			    //o andamento do processo
				If Empty(cCompos)
					Aviso(STR0115,STR0257,{"Ok"},2)
					lOk := .F.
				Else
					//Verifica se existe a composicao informada
					aAreaTmp := AE1->(GetArea())
					dbSelectArea("AE1")
					DbSetOrder(1)
					If !DbSeek(xFilial()+cCompos)
						Aviso(STR0115,STR0257,{"Ok"},2)
						lOk := .F.
					EndIf

					RestArea(aAreaTmp)
				EndIF
				//Verifica se quantidade informada e maior que 0 (zero)
				If lOk .AND. nQuant<=0
					Aviso(STR0115,STR0258,{"ok"},2)
					lOk := .F.
				EndIF
				//Caso a codificacao das tarefas seja manual, verifica o codigo retornado pelo ponto de entrada
				If lOk .AND. GetMv("MV_PMSTCOD") == "1"
					If Empty(cTarefa)
						Aviso("STR0115",STR0259,{"Ok"},2)
						lOk := .F.
					Else
						If ExistPrjTrf((cAlias)->AFC_PROJET, (cAlias)->AFC_REVISA, cTarefa)
							lOk := .F.
					 	EndIf
					EndIf
				EndIF

			EndIf
		EndIf
	Else

		DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
		DEFINE MSDIALOG oDlg FROM 114,150 TO 450,600 TITLE cCadastro Of oMainWnd PIXEL

			@   0,   0 BITMAP oBmp RESNAME BMP_PROJETOAP oF oDlg SIZE 70,255 NOBORDER WHEN .F. PIXEL
			@  17,  43 TO 18 ,245 LABEL '' OF oDlg PIXEL
			@   6,  50 SAY STR0080 Of oDlg PIXEL SIZE 69, 08 FONT oBold //'Importar Composicao'

			@  30,  55 SAY STR0073 Of oDlg PIXEL SIZE 58, 08 //'Cod. Composicao'
			@  29, 105 MSGET cCompos Picture PesqPict('AE1','AE1_COMPOS') F3 'AE1';
			                         Valid Vazio(cCompos) .Or. RefDlg(@cCompos,@cDescri,@oDescri,@cUM,@oUM) .And.;
			                         (oQuant:SetFocus(), .T.);
									             OF oDlg PIXEL SIZE 92, 08 HASBUTTON

			@  50,  55 SAY STR0074 Of oDlg PIXEL SIZE 43, 08 //'Descricao'
			@  49, 105 GET oDescri VAR cDescri MULTILINE TEXT ;
			           SIZE 106 , 33 PIXEL OF oDlg // READONLY

			@  95,  55 SAY STR0075 Of oDlg PIXEL SIZE 80, 08 //'Unid. de Medida'
			@  94, 105 MSGET oUM VAR cUM Picture PesqPict('AE1','AE1_UM') OF oDlg When .F. PIXEL SIZE 25, 08

			@ 115,  55 SAY STR0076 Of oDlg PIXEL SIZE 45, 08 //'Quantidade'
			@ 114, 105 MSGET oQuant VAR nQuant Picture PesqPict('AF2','AF2_QUANT') Valid Positivo(nQuant) OF oDlg PIXEL SIZE 60, 08 HASBUTTON

			If GetMv("MV_PMSTCOD") == "1"

				// codificacao manual
				@ 135,  55 Say STR0158 Of oDlg Pixel Size 45, 08 //"Cod. da Tarefa"
				@ 134, 105 MSGET cTarefa Picture PesqPict("AF9", "AF9_TAREFA") Valid !ExistPrjTrf((cAlias)->AFC_PROJET, (cAlias)->AFC_REVISA, cTarefa) Of oDlg Pixel Size 60, 08

				@ 155, 131 BUTTON STR0077 SIZE 35 ,11  FONT oDlg:oFont ACTION  (lOk:=.T.,oDlg:End()) OF oDlg PIXEL When !Empty(nQuant) .And. !Empty(cCompos) .And. !Empty(cTarefa)
			Else
				@ 155, 131 BUTTON STR0077 SIZE 35 ,11  FONT oDlg:oFont ACTION  (lOk:=.T.,oDlg:End()) OF oDlg PIXEL When !Empty(nQuant) .And. !Empty(cCompos)
			EndIf

			@ 155, 171 BUTTON STR0078 SIZE 35 ,11  FONT oDlg:oFont ACTION (oDlg:End())  OF oDlg PIXEL  //'Cancela'

			ACTIVATE MSDIALOG oDlg CENTERED
   EndIf

	Begin Transaction
		If lOk
			cDescri := StrTran(cDescri ,chr(13) ,"")
			cDescri := StrTran(cDescri ,chr(10) ," ")

			If GetMv("MV_PMSTCOD") == "2" .Or. GetMv("MV_PMSTCOD") == "3"
				// codificacao automatica
				cTarefa := PmsNumAFC(AFC->AFC_PROJET, AFC->AFC_REVISA, AFC->AFC_NIVEL, AFC->AFC_EDT)
			EndIf

			If lSimula
				cRevisa := AJB->AJB_REVISA
			Else
				cRevisa := AF8->AF8_REVISA
			EndIf

			// verifica a existencia do ponto de entrada PMA200CP
			If ExistBlock("PMA200CP")
				ExecBlock("PMA200CP",.F.,.F.,{ 'AFC',AFC->(RecNo()),AE1->(RecNo()),nQuant })
			EndIf

			If GetMv("MV_PMSCUST") == "2" //1-custo total  2-custo unitario
				nRecAF9 := PMS200ImpCom(nRecAF8,AFC->AFC_NIVEL,cCompos,1, cTarefa,AFC->AFC_EDT,,,,, nQuant,, cRevisa,cDescri)
			Else
				nRecAF9 := PMS200ImpCom(nRecAF8,AFC->AFC_NIVEL,cCompos,	nQuant, cTarefa, AFC->AFC_EDT,,,,, nQuant,, cRevisa,cDescri)
			EndIf
		EndIf
	End Transaction
EndIf

PMS200Rev()

Return lOk
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥PMS200CMP2≥ Autor ≥Fabio Rogerio Pereira  ≥ Data ≥ 15-03-2002 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Funcao que associa o cadastro de composicoes para uma deter- ≥±±
±±≥          ≥ minada tarefa do Projeto.                                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥PMSA200                                                       ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PMS200CMP2(nRecAF8,oTree,cArquivo,lSimula)
Local oDlg
Local oDescri
Local nQuant   := 0
Local cUM      := ''
Local cDescri 	:= ''
Local cCompos 	:= SPACE(Len(AE1->AE1_COMPOS))
Local oBold
Local oUM
Local oBmp
Local lOk       := .F.
Local cAlias    := ""
Local nRecAlias := 0
Local nRecAF9   := 0
Local lMantProd := .F.
Local lPMA200VOK:= ExistBlock("PMA200VOK")
Local lPMA200CP := ExistBlock("PMA200CP")
Local lMantDt	:= .F.

If AF8ComAJT(AF8->AF8_PROJET)
	Aviso(STR0069,STR0303,{"Ok"}) //"FunÁ„o indisponÌvel para composiÁ„o ˙nica"
	Return
EndIf
If oTree != Nil

	// verifica os dados da EDT/Tarefa posicionada no tree
	cAlias:= SubStr(oTree:GetCargo(),1,3)
	nRecAlias:= Val(SubStr(oTree:GetCargo(),4,12))
Else
	cAlias := (cArquivo)->ALIAS
	nRecAlias := (cArquivo)->RECNO
EndIf


If cAlias == "AF9"
	dbSelectArea(cAlias)
	dbGoto(nRecAlias)
	nQuant	:= AF9->AF9_QUANT

	DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
	DEFINE MSDIALOG oDlg FROM 114,150 TO 520,600 TITLE cCadastro Of oMainWnd PIXEL

	@ -09, -12 BITMAP oBmp RESNAME BMP_PROJETOAP oF oDlg SIZE 60,250 NOBORDER WHEN .F. PIXEL
	@  17,  43 TO 18 ,245 LABEL '' OF oDlg PIXEL
	@   6,  50 SAY STR0129 Of oDlg PIXEL SIZE 69, 08 FONT oBold

	@  30,  55 SAY STR0073 Of oDlg PIXEL SIZE 58, 08 //'Cod. Composicao'
	@  29, 105 MSGET cCompos Picture PesqPict('AE1','AE1_COMPOS') F3 'AE1';
	Valid Vazio(cCompos) .Or. RefDlg(@cCompos,@cDescri,@oDescri,@cUM,@oUM);
	OF oDlg PIXEL SIZE 92, 08 HASBUTTON

	@  50,  55 SAY STR0074 Of oDlg PIXEL SIZE 43, 08 //'Descricao'
	@  49, 105 GET oDescri VAR cDescri ;
	SIZE 106 , 33 PIXEL OF oDlg MULTILINE TEXT // READONLY

	@  95,  55 SAY STR0075 Of oDlg PIXEL SIZE 80, 08 //'Unid. de Medida'
	@  94, 105 MSGET oUM VAR cUM Picture PesqPict('AE1','AE1_UM') OF oDlg When .F. PIXEL SIZE 25, 08

	@ 115,  55 SAY STR0076 Of oDlg PIXEL SIZE 45, 08 //'Quantidade'
	@ 114, 105 MSGET oQuant Var nQuant Picture PesqPict('AF2','AF2_QUANT') Valid Positivo(nQuant) OF oDlg PIXEL SIZE 60, 08 HASBUTTON

	TCheckBox():New(133,55,STR0243,{|u|if( pcount()==0,lMantProd,lMantProd := u)},oDlg,200,20,,,,,,,,.T.) //"Manter Produto/Recurso/Despesa da tarefa associada?"
	TCheckBox():New(143,55,STR0302,{|u|if( pcount()==0,lMantDt,lMantDt := u)},oDlg,200,20,,,,,,,,.T.) //"Manter datas da tarefa"

	@ 165, 171 BUTTON STR0077 SIZE 35 ,11  FONT oDlg:oFont ACTION IIF(lOk:=(IIF(lPMA200VOK,ExecBlock("PMA200VOK",.F.,.F.,{cCompos}),.T.)),oDlg:End(), .F.) OF oDlg PIXEL When !Empty(nQuant) .And. !Empty(cCompos) .And. PMS200UsrVld() //'Confirma'
	@ 165, 131 BUTTON STR0078 SIZE 35 ,11  FONT oDlg:oFont ACTION (oDlg:End())  OF oDlg PIXEL //'Cancela'

	ACTIVATE MSDIALOG oDlg CENTERED

	If lOk
		cDescri := StrTran(cDescri ,chr(13) ,"")
		cDescri := StrTran(cDescri ,chr(10) ," ")

		Begin Transaction
			// verifica a existencia do ponto de entrada PMA200CP
			If lPMA200CP
				ExecBlock("PMA200CP",.F.,.F.,{ 'AF9',AF9->(RecNo()),AE1->(RecNo()),nQuant })
			EndIf

			If GetMv("MV_PMSCUST") == "2"  //1-custo total  2-custo unitario
				nRecAF9 := PMS200ImpCom(nRecAF8,,cCompos,1     ,AF9->AF9_TAREFA ,,,,,AF9->(RecNo()), nQuant,,,cDescri,,lMantProd,,lMantDt)
			Else
				nRecAF9 := PMS200ImpCom(nRecAF8,,cCompos,nQuant,AF9->AF9_TAREFA ,,,,,AF9->(RecNo()), nQuant,,,cDescri,,lMantProd,,lMantDt)
			EndIf
		End Transaction
	EndIf
EndIf

PMS200Rev()

Return lOk
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥RefDlg≥ Autor ≥ Edson Maricate            ≥ Data ≥ 09-02-2001 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Executa a validacao e o refresh dos gets da janela            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥PMS101CMP                                                     ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function RefDlg(cCompos,cDescri,oDescri,cUM,oUM)
Local aArea		:= GetArea()
Local aAreaAE1	:= AE1->(GetArea())
Local lRet 		:= .T.

AE1->(dbSetOrder(1))
If AE1->(MsSeek(xFilial("AE1") + cCompos))
	Do Case
		// 1 - orÁamento/projeto
		Case AE1->AE1_USO == "1"
			cDescri := AE1->AE1_DESCRI
			cUM 	:= AE1->AE1_UM
			oDescri:Refresh()
			oUM:Refresh()

		// 2 - orÁamento
		Case AE1->AE1_USO == "2"
			Aviso(STR0244 ,STR0246 , {"OK"}) //"ComposiÁ„o"  //"Esta composiÁ„o pode ser utilizado somente no orÁamento."
			lRet := .F.

		// inativa
		Case AE1->AE1_USO == "3"
			Aviso(STR0244 ,STR0245 , {"OK"})
			lRet := .F.

		Otherwise
			lRet := .F.

	EndCase

Else
	HELP("  ",1,"REGNOIS")
	lRet := .F.
EndIf

RestArea(aAreaAE1)
RestArea(aArea)
Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥PMS200ImpCo≥ Autor ≥Fabio Rogerio Pereira ≥ Data ≥ 15-03-2002              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Funcao que importa/associa a composicao no Projeto.                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥cItemAFA : numero do item produto da tabela AFA                            ≥±±
±±≥          ≥cItemAFB : numero do item da despesa da tabela AFB                         ≥±±
±±≥          ≥lMantProd : mantem os produtos da tarefa associada(utilizado se associacao)≥±±
±±≥          ≥cItemRec : numero do item recurso da tabela AFA                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥PMS200ImpCMP                                                               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PMS200ImpCom(nRecAF8,cNivelAtu,cCompos,nQuant,cTarefa,cEDTPAI,lCriaAF9,cItemAFA,cItemAFB,nRecAF9,nGravaQuant,cProjet,cRevisa,cDescri,lSub,lMantProd,cItemRec,lMantDt)
Local aArea     := GetArea()
Local aAreaAE1  := AE1->(GetArea())
Local aAreaAE2  := AE2->(GetArea())
Local aAreaAE8  := AE8->(GetArea())
Local aAreaAF9  := AF9->(GetArea())
Local aAreaAE3  := AE3->(GetArea())
Local aAreaAE4  := AE4->(GetArea())
Local aAreaSB1  := SB1->(GetArea())
Local aAuxHor   := {}
Local cNivelTrf := cNivelAtu
Local cMsg
Local nRetAF9	:= 0
Local nAuxAF9	:= 0
Local aCustoAF9
Local lAtuCron	:= .T.
Local nx
Local bCampo	:= {|n| FieldName(n) }
Local nAuxMV
Local aCpyAE2	:= {}
Local aCpyAFA	:= {}
Local lOk		:= .T.
Local lContinua	:= .T.
Local lPmValImp	:= ExistBlock("PMVALIMP")
DEFAULT lCriaAF9  := .T.
DEFAULT cItemAFA  := StrZero(0, TamSX3("AFA_ITEM")[1])
DEFAULT cItemAFB  := StrZero(0, TamSX3("AFB_ITEM")[1])
DEFAULT cItemRec  := StrZero(0, TamSX3("AFA_ITEM")[1])
DEFAULT lSub      := .F.
DEFAULT cProjet   := AF8->AF8_PROJET
DEFAULT cRevisa   := AF8->AF8_REVISA
DEFAULT lMantProd := .F.
DEFAULT lMantDt := .F.
If lPmValImp
	lContinua := ExecBlock( "PMVALIMP",.F.,.F.,{cProjet, cTarefa, cCompos})
EndIf

If lContinua

	dbSelectArea("AE1")
	dbSetOrder(1)
	If dbSeek(xFilial("AE1")+cCompos)
		If lCriaAF9
			If nRecAF9 == Nil
				cNivelTrf := StrZero(Val(cNivelTrf) + 1, TamSX3("AF9_NIVEL")[1])
				RecLock("AF9",.T.)
				For nx := 1 TO FCount()
					FieldPut(nx,CriaVar( EVAL(bCampo,nx) ) )
				Next nx
				AF9->AF9_FILIAL := xFilial("AF9")
				AF9->AF9_PROJET := AF8->AF8_PROJET
				AF9->AF9_REVISA := cRevisa //AF8->AF8_REVISA
				AF9->AF9_CALEND := AF8->AF8_CALEND
				AF9->AF9_NIVEL  := cNivelTrf

				If GetMv("MV_PMSTCOD") == "1"
					// codificacao manual
					AF9->AF9_TAREFA := cTarefa
				Else
					AF9->AF9_TAREFA := PmsNumAF9(AF8->AF8_PROJET, cRevisa, cNivelAtu, cEDTPAI)
				EndIf

				AF9->AF9_DESCRI := IIf(cDescri==Nil .Or.Empty(cDescri),AE1->AE1_DESCRI,cDescri)
				AF9->AF9_UM     := AE1->AE1_UM
				AF9->AF9_GRPCOM := AE1->AE1_GRPCOM
				AF9->AF9_QUANT  := nGravaQuant
				AF9->AF9_TPMEDI := "4"
				AF9->AF9_EDTPAI := cEDTPAI

				AF9->AF9_TIPPAR := AE1->AE1_TIPPAR

				If hasTemplate("CCT") .and. ExistTemplate("CCT200_0")
					ExecTemplate("CCT200_0",.F.,.F.,{cCompos,lSub})
				EndIf

				aAuxHor	:= PMSDTaskF(AF8->AF8_START,AF9->AF9_HORAI,AF9->AF9_CALEND,AF9->AF9_HDURAC,AF9->AF9_PROJET,Nil)
				AF9->AF9_START  := aAuxHor[1]
				AF9->AF9_HORAI  := aAuxHor[2]
				AF9->AF9_FINISH := aAuxHor[3]
				AF9->AF9_HORAF  := aAuxHor[4]
				AF9->AF9_COMPOS := cCompos

				MsUnlock()
				nRetAF9	:= AF9->(RecNo())

			Else

				AF9->(dbGoto(nRecAF9))
				RecLock("AF9",.F.)
				AF9->AF9_DESCRI := IIf(cDescri==Nil .Or.Empty(cDescri),AE1->AE1_DESCRI,cDescri)
				AF9->AF9_UM     := AE1->AE1_UM
				AF9->AF9_GRPCOM := AE1->AE1_GRPCOM
				AF9->AF9_QUANT  := nGravaQuant
				AF9->AF9_COMPOS := cCompos

				AF9->AF9_TIPPAR := AE1->AE1_TIPPAR

				If hasTemplate("CCT") .and. ExistTemplate("CCT200_0")
					ExecTemplate("CCT200_0",.F.,.F.,{cCompos,lSub})
				EndIf

				If !lMantDt
					aAuxHor	:= PMSDTaskF(AF8->AF8_START,AF9->AF9_HORAI,AF9->AF9_CALEND,AF9->AF9_HDURAC,AF9->AF9_PROJET,Nil)
					If DTOS(aAuxHor[1])+aAuxHor[2]+DTOS(aAuxHor[3])+aAuxHor[4]==DTOS(AF9->AF9_START)+AF9->AF9_HORAI+DTOS(AF9->AF9_FINISH)+AF9->AF9_HORAF
						lAtuCron	:= .F.
					Else
						lAtuCron	:= .T.
						AF9->AF9_START  := aAuxHor[1]
						AF9->AF9_HORAI  := aAuxHor[2]
						AF9->AF9_FINISH := aAuxHor[3]
						AF9->AF9_HORAF  := aAuxHor[4]
					EndIf
				Endif

				MsUnlock()
				nRetAF9	:= AF9->(RecNo())
				PmsAvalTrf("AF9",1,,lAtuCron)

				AFA->(DbSetOrder(1))
				AFA->(DbSeek(xFilial("AFA")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA))
				While AFA->(!Eof()) .And. xFilial("AFA")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA==;
									AFA->(AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA)
				If !lMantProd
						PmsAvalAFA("AFA",2)
						PmsAvalAFA("AFA",3)
						RecLock("AFA",.F.,.T.)
						AFA->(DbDelete())
						AFA->(MsUnlock())
					Else
						//guarda o ultimo item do produto/recurso da tarefa
						If !Empty(AFA->AFA_RECURS)
							cItemRec := AFA->AFA_ITEM
						Else
							cItemAFA := AFA->AFA_ITEM
						EndIf
					EndIf
					AFA->(DbSkip())
				EndDo

				AFB->(DbSetOrder(1))
				AFB->(DbSeek(xFilial("AFB")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA))
				While AFB->(!Eof()) .And. xFilial("AFB")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA==;
									AFB->(AFB_FILIAL+AFB_PROJET+AFB_REVISA+AFB_TAREFA)
					If lMantProd = .F. // mantem produto/recurso/despesa?
						RecLock("AFB",.F.,.T.)
						AFB->(DbDelete())
						AFB->(MsUnlock())
					Else
						//guarda o ultimo item da despesa da tarefa
						cItemAFB := AFB->AFB_ITEM
					EndIf
					AFB->(DbSkip())
				EndDo
			EndIf
		EndIf

		dbSelectArea("AE2")
		dbSetOrder(1)
		dbSeek(xFilial("AE2")+cCompos)
		While !Eof() .And. xFilial("AE2")+cCompos == AE2->AE2_FILIAL+AE2->AE2_COMPOS .And. lContinua


			Do Case
				//Se recurso e produto vazios, aborta a gravacao
				Case Empty(AE2->AE2_PRODUT) .And. Empty(AE2->AE2_RECURS)
					lOk  := .F.
					cMsg := STR0268  // "Recursos ou produtos n„o cadastrados!"
				//Se o recurso esta preenchido porem nao existe na tabela AE8, aborta a gravacao
				Case !Empty(AE2->AE2_RECURS) .And. Empty(AE2->AE2_PRODUT) .And. Empty(Posicione("AE8",1,xFilial("AE8")+AE2->AE2_RECURS,"AE8_RECURS"))
					lOk := .F.
					cMsg := STR0269 //"Recurso n„o cadastrado! InconsistÍncia na base de dados."
				//Se o produto esta preenchido mas nao existe na tabela SB1, aborta a gravacao
				Case Empty(AE2->AE2_RECURS) .And. !Empty(AE2->AE2_PRODUT) .And. Empty(Posicione("SB1",1,xFilial("SB1")+AE2->AE2_PRODUT,"B1_COD"))
					lOk := .F.
					cMsg := STR0270 //"Produto n„o cadastrado! InconsistÍncia na base de dados."
				//Se o recurso e produto estiverem preenchidos mas algun dos dois n„o existir na base
				Case !Empty(AE2->AE2_PRODUT) .And. !Empty(AE2->AE2_RECURS) .And.;
				     (Empty(Posicione("AE8",1,xFilial("AE8")+AE2->AE2_RECURS,"AE8_RECURS")) .Or. Empty(Posicione("SB1",1,xFilial("SB1")+AE2->AE2_PRODUT,"B1_COD")))
					lOk := .F.
					cMsg := STR0271 //"Produtos ou Recursos n„o cadastrados! InconsistÍncia na base de dados."
			EndCase

			If lOk
				RegToMemory("AFA",.T.)
				RecLock("AFA",.T.)
				For nx := 1 TO FCount()
					FieldPut(nx,M->&(EVAL(bCampo,nx)))
				Next nx
				AFA->AFA_FILIAL := xFilial("AFA")
				AFA->AFA_PROJET := If(lCriaAF9,AF9->AF9_PROJET,cProjet)
				AFA->AFA_REVISA := If(lCriaAF9,AF9->AF9_REVISA,cRevisa)
				AFA->AFA_TAREFA := If(lCriaAF9,AF9->AF9_TAREFA,cTarefa)
				AFA->AFA_PRODUT := AE2->AE2_PRODUT
				AFA->AFA_QUANT  := PmsAFAQuant(AFA->AFA_PROJET,AFA->AFA_REVISA,AFA->AFA_TAREFA,AFA->AFA_PRODUT,nQuant,AE2->AE2_QUANT,AF9->AF9_HDURAC,.T.)

				If hasTemplate("CCT") .and. !ExistTemplate("CCTAFAQUANT") .And. GetMV("MV_PMSCUST")=="2"
					AFA->AFA_QUANT := nQuant * AE2->AE2_QUANT
				EndIf
				SB1->(dbSetOrder(1))
				SB1->(dbSeek(xFilial()+AFA->AFA_PRODUT))
				AFA->AFA_MOEDA  := Val(RetFldProd(SB1->B1_COD,"B1_MCUSTD"))
				AFA->AFA_CUSTD  := RetFldProd(SB1->B1_COD,"B1_CUSTD")

				AFA->AFA_ACUMUL := "3"
				AFA->AFA_DATPRF := AF9->AF9_START
				AFA->AFA_COMPOS := cCompos

				If !Empty(SB1->B1_SEGUM)
					AFA->AFA_QTSEGU := ConvUm(AFA->AFA_PRODUT,AFA->AFA_QUANT,0,2)
				EndIF

				// tratamento para recurso
				If !Empty(AE2->AE2_RECURS)

					If Empty(AE2->AE2_PRODUT)
						AFA->AFA_MOEDA	:= 1
					EndIf

					AFA->AFA_RECURS := AE2->AE2_RECURS

					// se importacao de composicao ou duracao da tarefa igual a zero
					If (nRecAF9 == Nil) .Or. (AF9->AF9_HDURAC == 0)
						// utiliza quantidade de horas
						AFA->AFA_FIX  := "2"
						AFA->AFA_ALOC := 0
					Else
						// MV_PMSICQT
						// 1 - utiliza a porcentagem de alocaÁ„o (default)
						// 2 - utiliza a quantidade de horas
						nAuxMV := GetNewPar("MV_PMSICQT", 1)

						Do Case

							// utiliza % alocaÁ„o
							Case nAuxMV == 1
								AFA->AFA_FIX  := "1"
								AFA->AFA_ALOC := 100

							// utiliza quantidade de horas
							Case nAuxMV == 2
								AFA->AFA_FIX  := "2"
								AFA->AFA_ALOC := 0

							Otherwise
								AFA->AFA_FIX  := "1"
								AFA->AFA_ALOC := 0
						EndCase
					EndIf

					AFA->AFA_CUSTD := 0

					AE8->(dbSetOrder(1))
					If AE8->(dbSeek(xFilial("AE8")+AE2->AE2_RECURS))
						If Empty(AE8->AE8_PRODUT)
							If AE8->AE8_VALOR >0
								AFA->AFA_CUSTD := AE8->AE8_VALOR
							Else
								AFA->AFA_CUSTD := 0
							EndIf
						Else // existe um produto informado junto com o recurso
							If AE8->AE8_VALOR >0
								AFA->AFA_CUSTD := AE8->AE8_VALOR
							Else
								SB1->(dbSetOrder(1))
								SB1->(dbSeek(xFilial()+AE8->AE8_PRODUT))
								AFA->AFA_CUSTD := RetFldProd(SB1->B1_COD,"B1_CUSTD")
							EndIf
						EndIf
					Else
						AFA->AFA_CUSTD := 0
					EndIf

					AFA->AFA_CUSTD := AFA->AFA_CUSTD

					cItemRec      := Soma1(cItemRec)
					AFA->AFA_ITEM := cItemRec
				Else
					cItemAFA      := Soma1(cItemAFA)
					AFA->AFA_ITEM := cItemAFA
				EndIf

				If hasTemplate("CCT") .and. ExistTemplate("CCT200_1")
					ExecTemplate("CCT200_1",.F.,.F.,{cCompos,lSub})
				EndIf

				MsUnlock()

				If ExistBlock("P200Cpy1")
					aCpyAE2	:= AE2->(GetArea())
					aCpyAFA	:= AFA->(GetArea())
					ExecBlock("P200Cpy1",.F.,.F.)
					RestArea(aCpyAE2)
					RestArea(aCpyAFA)
				EndIf

				PmsAvalAFA("AFA",1)

				AE2->( dbSkip() )
			else
				MsgAlert(cMsg,STR0069)
				lContinua := .F.
				AE2->( dbSkip() )
			endIf
		EndDo

		dbSelectArea("AE3")
		dbSetOrder(1)
		dbSeek(xFilial("AE3")+cCompos)
		While !Eof() .And. xFilial("AE3")+cCompos == AE3->AE3_FILIAL+AE3->AE3_COMPOS .And. lContinua
			cItemAFB := Soma1(cItemAFB)
			RegToMemory("AFB",.T.)
			RecLock("AFB",.T.)
			For nx := 1 TO FCount()
				FieldPut(nx,M->&(EVAL(bCampo,nx)))
			Next nx
			AFB->AFB_FILIAL := xFilial("AFB")
			AFB->AFB_PROJET := AF9->AF9_PROJET
			AFB->AFB_REVISA := AF9->AF9_REVISA
			AFB->AFB_ITEM   := cItemAFB
			AFB->AFB_TAREFA := AF9->AF9_TAREFA
			AFB->AFB_DESCRI := AE3->AE3_DESCRI
			AFB->AFB_MOEDA  := AE3->AE3_MOEDA
			AFB->AFB_VALOR  := PmsAFBValor(nQuant,AE3->AE3_VALOR,.T.)
			AFB->AFB_TIPOD  := AE3->AE3_TIPOD
			AFB->AFB_DATPRF := AF9->AF9_START
			AFB->AFB_ACUMUL := "3" //Rateado
			AFB->AFB_COMPOS := cCompos

			If hasTemplate("CCT") .and. ExistTemplate("CCT200_2")
				ExecTemplate("CCT200_2",.F.,.F.,{cCompos,lSub})
			EndIf

			MsUnlock()
	    	dbSelectArea("AE3")
			AE3->( dbSkip() )
		EndDo


		// verifica a existencia do ponto de entrada PMA200IMP
		If ExistBlock("PMA200IMP") .And. lContinua
			ExecBlock("PMA200IMP",.F.,.F.,{cCompos,nQuant})
		EndIf

		// verifica a existencia do ponto de entrada PMA200IMP no Template
		If hasTemplate("CCT") .And. ExistTemplate("PMA200IMP") .And. lContinua
			ExecTemplate("PMA200IMP",.F.,.F.,{cCompos,lSub})
		EndIf


		dbSelectArea("AE4")
		dbSetOrder(1)
		dbSeek(xFilial()+cCompos)
		While !Eof() .And. xFilial()+cCompos == AE4->AE4_FILIAL+AE4->AE4_COMPOS .And. lContinua
			If lCriaAF9
				nAuxAF9 := PMS200ImpCom(nRecAF8,cNivelTrf,AE4->AE4_SUBCOM,AE4->AE4_QUANT*nQuant,AF9->AF9_TAREFA,cEDTPAI,.F.,@cItemAFA,@cItemAFB,,nGravaQuant,,cRevisa,cDescri,.T.,,@cItemRec)
			Else
				nAuxAF9 := PMS200ImpCom(nRecAF8,cNivelTrf,AE4->AE4_SUBCOM,AE4->AE4_QUANT*nQuant,cTarefa,cEDTPAI,.F.,@cItemAFA,@cItemAFB,,nGravaQuant,,cRevisa,cDescri,.T.,,@cItemRec)
			EndIf
			dbSelectArea("AE4")
			dbSkip()
		EndDo

		// grava o custo da tarefa
		If lContinua
			If hasTemplate("CCT") .and. ExistTemplate("PMAAF9CTrf")
				ExecTemplate("PMAAF9CTrf",.F.,.F.,{AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA})
			Else
				aCustoAF9:= PMSAF9CusTrf(,AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA)
				RecLock("AF9",.F.)
				AF9->AF9_CUSTO  := aCustoAF9[1]
				AF9->AF9_CUSTO2 := aCustoAF9[2]
				AF9->AF9_CUSTO3 := aCustoAF9[3]
				AF9->AF9_CUSTO4 := aCustoAF9[4]
				AF9->AF9_CUSTO5 := aCustoAF9[5]
				MsUnLock()
			EndIf
		EndIf
		//
		// Executa a avaliacao dos eventos de uma Tarefa, se n„o for uma subcomposicao
		//
		If !lSub .And. lContinua
			PmsAvalTrf("AF9",1,,lAtuCron)
		EndIf

		If !lContinua
			MsgInfo(STR0272,STR0069)
		EndIf
	EndIf


	RestArea(aAreaSB1)
	RestArea(aAreaAE4)
	RestArea(aAreaAE3)
	RestArea(aAreaAF9)
	RestArea(aAreaAE8)
	RestArea(aAreaAE2)
	RestArea(aAreaAE1)
	RestArea(aArea)

Endif

Return nRetAF9



/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ FAtiva   ≥ Autor ≥ Edson Maricate        ≥ Data ≥ 18.10.95 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Chama a&pergunte                                           ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ PMSA200                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FAtiva()
Pergunte("PMA200",.T.)
nDlgPln := mv_par01
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥A200ChkPln≥ Autor ≥ Edson Maricate        ≥ Data ≥ 18.10.95 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Verifica quais os campos que devem aparecer na planilha.    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥PMSA200                                                     ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function A200ChkPln(aCampos,cMV1,cMV2)

Local cCampos

DEFAULT cMV1 := "MV_PMSPLN1"
DEFAULT cMV2 := "MV_PMSPLN2"

cCampos := Alltrim(GetMv(cMV1))
cCampos += Alltrim(GetMv(cMV2))

While !Empty(AllTrim(cCampos))
	If AT("#",cCampos) > 0
		cAux := Substr(cCampos,1,AT("#",cCampos)-1)
		aAdd(aCampos,{"AF9"+cAux,"AFC"+cAux,,,,.F.,"",})
	    cCampos := Substr(cCampos,AT("#",cCampos)+1,Len(cCampos)-AT("#",cCampos))
	 Else
	 	cCampos := ''
	 EndIf
End

Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥Pms200AltCus≥ Autor ≥Fabio Rogerio Pereira ≥ Data ≥ 26-12-2001≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Funcao que altera os custos do projeto.			            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥SIGAPMS                                                       ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function Pms200AltCus(oTree, lSimula, lCalcTrib)
Local lRet		:= .F.
Local aParam1   := {}
Local aParam2   := {}
Local aTipos    := {STR0042,STR0043,STR0044,STR0045} //"Atualizar do Cadastro"###"Aplicar Percentual"###"Atualizar Custos Por Projeto (Manual)"###"Atualizar Custos Por Tarefa (Manual)"
Local aCalculo  := {STR0046,STR0096} //"Acrescimo"###"Descrescimo"
Local cFiltroB1 := ""
Local cFiltroPAFA:= ""
Local cFiltroRAFA:= ""
Local cFiltroAE8 := ""
Local cFltAFAUsr := ""
Local aRetUsr    := {}
Local nI         := 0

Default lSimula   := .F.
Default lCalcTrib := .F.

// ponto de entrada utilizado para customizar
// o c·lculo de custo
If ExistBlock("PMS200AC")
	Return ExecBlock("PMS200AC", .F., .F.)
EndIf

If hasTemplate("CCT") .and. ExistTemplate("PMS200AC")
	ExecTemplate("PMS200AC",.F.,.F.)
Else

	// verifica se existe ponto de entrada para calculo especifico
	 if ExistBlock("Pms200CPRV")
	 	 aRetUsr := ExecBlock("Pms200CPRV",.F.,.F. )
	 	 if Valtype(aRetUsr) <> "A"
	 	    aRetUsr := {}
	 	 endif
	 endif

	// carrega os titulos das opcoes
	If Len(aRetUsr) > 0
		For nI :=  1 to len(aRetUsr)
			AADD(aTipos,aRetUsr[nI,1])
		Next nI
	EndIf

	// verifica o evento de alteracao no Fase atual
	If !PmsVldFase("AF8",AF8->AF8_PROJET,"11") .Or.;
	   !ParamBox( {	{3,STR0048,1,aTipos,130,"",.F.},;       //"Tipo de Reajuste"
					{1,STR0097,CriaVar("B1_COD",.F.),"@!","","SB1","",80,.F.},;  //"Produto De"
					{1,STR0098,Replicate("Z",TamSX3("B1_COD")[1]),"@!","","SB1","",80,.F.},;  //"Produto Ate"
					{1,STR0099,CriaVar("B1_TIPO",.F.),"@!","","02","",10,.F.},;  //"Tipo Produto"
					{1,STR0100,CriaVar("B1_GRUPO",.F.),"@!","","SBM","",40,.F.},;  //"Grupo De"
					{1,STR0101,Replicate("Z",TamSX3("B1_GRUPO")[1]),"@!","","SBM","",40,.F.},; //"Grupo Ate"
					{1,STR0168, CriaVar("AE8_RECURS",.F.), "@!", "", "AE8", "", 80, .F.},;  //"Recurso De"
					{1,STR0169, Replicate("Z", TamSX3("AE8_RECURS")[1]), "@!", "", "AE8", "", 80, .F.},;  //"Recurso Ate"
					{2,STR0170, STR0171, {STR0171, STR0172, STR0173}, 80, "", .F.},;   //"Grupo Ate"
					{7,STR0189,"AFA","",".T."},;
					{3,STR0227, 1, {STR0228, STR0229}, 100, "", .T.};
						}, STR0012, @aParam1)  //"Filtro itens"###"Parametros"##"Material"##"Trabalho"
		Return(.F.)
	EndIf

	// filtra o arquivo de produtos para pesquisa otimizada
	cFiltroB1 := 	"B1_COD   >= '" + aParam1[2] + "' .And. B1_COD   <= '" + aParam1[3] + "' .And. " +;
								"B1_GRUPO >= '" + aParam1[5] + "' .And. B1_GRUPO <= '" + aParam1[6] + "'"

	If !Empty(aParam1[4])
		cFiltroB1+= " .And. B1_TIPO == '" + aParam1[4] + "'"
	EndIf

	//
	// produto
	//

	// filtra os produtos do projeto para pesquisa otimizada.
	If lSimula
		cFiltroPAFA := "AFA_FILIAL == '" + xFilial("AFA")  + "' .And. " +;
		              "AFA_PROJET == '" + AJB->AJB_PROJET + "' .And. " +;
		              "AFA_REVISA == '" + AJB->AJB_REVISA + "' .And. " +;
	  	            "AFA_PRODUT >= '" + aParam1[2] + "' .And. AFA_PRODUT <= '" + aParam1[3] + "'"
	Else
		cFiltroPAFA := "AFA_FILIAL == '" + xFilial("AFA")  + "' .And. " +;
		              "AFA_PROJET == '" + AF8->AF8_PROJET + "' .And. " +;
		              "AFA_REVISA == '" + AF8->AF8_REVISA + "' .And. " +;
		              "AFA_PRODUT >= '" + aParam1[2] + "' .And. AFA_PRODUT <= '" + aParam1[3] + "'"
	EndIf
	If !Empty(aParam1[10])
      cFltAFAUsr	+= aParam1[10]
	Endif

	//
	// recurso
	//
	cTipo  := If(ValType(aParam1[9]) == "N", "Ambos", aParam1[4])

	// filtra o arquivo de produtos para pesquisa otimizada
	cFiltroAE8 := 	"AE8_RECURS >= '" + aParam1[7] + "' .And. AE8_RECURS <= '" + aParam1[8] + "'" // .And. " +;

	//If !Empty(cTipo)
		Do Case
			Case Upper(AllTrim(cTipo)) == "MATERIAL"
				cFiltroAE8 += " .And. AE8_TIPO == '2'"

			Case Upper(AllTrim(cTipo)) == "TRABALHO"
				cFiltroAE8 += " .And. AE8_TIPO == '1'"
		EndCase
	//EndIf

	// filtra o recurso para pesquisa otimizada
	If lSimula
		cFiltroRAFA := "AFA_FILIAL == '" + xFilial("AFA")  + "' .And. " +;
		               "AFA_PROJET == '" + AJB->AJB_PROJET + "' .And. " +;
		               "AFA_REVISA == '" + AJB->AJB_REVISA + "' .And. " +;
		               "AFA_RECURS >= '" + aParam1[7] + "' .And. AFA_RECURS <= '" + aParam1[8] + "'"
	Else
		cFiltroRAFA := "AFA_FILIAL == '" + xFilial("AFA")  + "' .And. " +;
		               "AFA_PROJET == '" + AF8->AF8_PROJET + "' .And. " +;
		               "AFA_REVISA == '" + AF8->AF8_REVISA + "' .And. " +;
		               "AFA_RECURS >= '" + aParam1[7] + "' .And. AFA_RECURS <= '" + aParam1[8] + "'"
	EndIf

	Do Case
		Case (aParam1[1] == 1)
			Processa({||lRet := Pms200ACCad(cFiltroPAFA, cFiltroB1, cFiltroAE8, cFiltroRAFA,cFltAFAUsr)},  STR0049) //"Atualizando custos. Aguarde..."

		Case (aParam1[1] == 2)

			If ParamBox({ 	{3, STR0231 + " - " + STR0050, 1, aCalculo ,100,"", .T.}, ;  //"Tipo de Calculo"
				{1, STR0051, 0, "9999.99", "Mv_Par02 >= 0", "", "", 100, .F.}, ;
				{3, STR0232 + " - " + STR0050, 1, aCalculo, 100, "", .T.},;  //"Tipo de Calculo"
				{1, STR0051, 0, "9999.99", "Mv_Par04 >= 0", "", "", 100, .F.} ;
				}, STR0174, @aParam2)  //"Percentual Reajuste""Parametros - Reajuste de Produtos"

				Processa({||lRet := Pms200APerc(cFiltroPAFA, cFiltroB1,  aParam2, lSimula, cFltAFAUsr)}, STR0049) //"Atualizando custos. Aguarde..."
				Processa({||lRet := Pms2RCAPerc(cFiltroRAFA, cFiltroAE8, aParam2, lSimula, cFltAFAUsr)}, STR0049) //"Atualizando custos. Aguarde..."
			EndIf

		Case (aParam1[1] == 3) .Or. (aParam1[1] == 4)
			lRet := Pms200AManual(cFiltroPAFA, cFiltroB1, aParam1, cFiltroAE8, cFiltroRAFA,cFltAFAUsr)
			//lRet := PMS2RCAManual(cFiltroRAFA, cFiltroAE8, aParam1)

		Case (aParam1[1] > 4) // opcao customizada pelo cliente

			 if ExistBlock(aRetUsr[(aParam1[1]-4),2]) // na posicao 2 do aRetUsr, ira conter o nome do rdmake
			 	 lRet := ExecBlock(aRetUsr[(aParam1[1]-4),2],.F.,.F., {cFiltroPAFA, cFiltroB1, aParam1, cFiltroAE8, cFiltroRAFA,cFltAFAUsr} )
			 endif

	EndCase

	If lRet
		// atualiza os custos das tarefas e das edts
		PMS200ReCalc(lSimula,lCalcTrib)
	EndIf
EndIf

PMS200Rev()

Return(lRet)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥Pms200ACCad     ≥ Autor ≥Fabio Rogerio Pereira ≥ Data ≥ 26-12-2001 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Funcao que altera os custos do projeto c/cadastro de prod/recurs.  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥SIGAPMS                                                       	 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function Pms200ACCad(cFiltroPAFA, cFiltroB1, cFiltroAE8, cFiltroRAFA,cFltAFAUsr,aProdData)
Local nCusto   := 0
Local cDesc    := ""
Local cAliasQry:= ""
Local aSB1	:=	{}
Local aAE8	:=	{}
Local nPosProd
Default aProdData	:=	{CriaVar('B1_COD'),'zzzzzzzzzzzzz'}

cAliasQry := "AFA"

// filtra o arquivo de produtos para pesquisa otimizada
DbSelectArea("SB1")
DbSetOrder(1)
DbClearFilter()

If !Empty(cFiltroB1)
	DbSetFilter({||&(cFiltroB1)},cFiltroB1)
	dbGoTop()
EndIf

// filtra os produtos do projeto para pesquisa otimizada
DbSelectArea(cAliasQry)
DbSetOrder(1)
MsSeek(xFilial("AFA") + AF8->AF8_PROJET + AF8->AF8_REVISA+aProdData[1],.T.)
While !Eof() .And. AFA->AFA_FILIAL + AFA->AFA_PROJET + AFA->AFA_REVISA+AFA->AFA_PRODUT <= xFilial("AFA") + AF8->AF8_PROJET + AF8->AF8_REVISA  + aProdData[2]

	If !Empty(cFiltroPAFA) .And. !&(cFiltroPAFA)
		dbSelectArea(cAliasQry)
		dbSkip()
		Loop
	EndIf

	If !Empty((cAliasQry)->AFA_RECURS)
		dbSelectArea(cAliasQry)
		dbSkip()
		Loop
	EndIf
	If cFltAFAUsr	<> Nil  .And. !Empty(cFltAFAUsr) .And. !&(cFltAFAUsr)
		dbSelectArea(cAliasQry)
		dbSkip()
		Loop
	Endif
	If AFA->AFA_RECALC != "2"
		nPosProd	:=	Ascan(aSB1,{|x| x[1] ==(cAliasQry)->AFA_PRODUT })
		If nPosProd > 0
			//O produto esta fora do filtro?
			If !aSb1[nPosProd,4]
				dbSelectArea(cAliasQry)
				dbSkip()
				Loop
			Else
				nCusto:= aSb1[nPosProd,2]
				cDesc := aSb1[nPosProd,3]
			Endif
		Else
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+ (cAliasQry)->AFA_PRODUT))
			If !SB1->(&(cFiltroB1))
				dbSelectArea(cAliasQry)
				dbSkip()
				Loop
			EndIf
			cDesc := AllTrim(SB1->B1_DESC)
			nCusto	:=	AEFPrdCust((cAliasQry)->AFA_PROJET ,(cAliasQry)->AFA_REVISA ,'P',(cAliasQry)->AFA_PRODUT ,dDataBase)

			AAdd(aSB1,{(cAliasQry)->AFA_PRODUT,nCusto,cDesc,.T.})
		Endif
		RecLock("AFA",.F.)
		If nCusto >0
			Replace AFA->AFA_CUSTD With nCusto
		Else
			Replace AFA->AFA_CUSTD With 0
		EndIf
		MsUnlock()
	EndIf
	IncProc(STR0052 + cDesc) //"Atualizando "

	dbSelectArea(cAliasQry)
	dbSkip()
End

DbSelectArea("SB1")
DbSetOrder(1)
DbClearFilter()

// filtra o arquivo de produtos para pesquisa otimizada
DbSelectArea("AE8")
DbSetOrder(1)
DbClearFilter()

If !Empty(cFiltroAE8)
	DbSetFilter({||&(cFiltroAE8)}, cFiltroAE8)
	dbGoTop()
EndIf

// filtra os recursos do projeto para pesquisa otimizada
DbSelectArea(cAliasQry)
DbSetOrder(1)
MsSeek(xFilial("AFA") + AF8->AF8_PROJET + AF8->AF8_REVISA)

While !Eof() .And. AFA->AFA_FILIAL + AFA->AFA_PROJET + AFA->AFA_REVISA == xFilial("AFA") + AF8->AF8_PROJET + AF8->AF8_REVISA

	If !&(cFiltroRAFA)
		dbSelectArea(cAliasQry)
		dbSkip()
		Loop
	EndIf

	If Empty((cAliasQry)->AFA_RECURS)
		dbSelectArea(cAliasQry)
		dbSkip()
		Loop
	EndIf
	If cFltAFAUsr	<> Nil  .And. !Empty(cFltAFAUsr) .And. !&(cFltAFAUsr)
		dbSelectArea(cAliasQry)
		dbSkip()
		Loop
	Endif

	If AFA->AFA_RECALC != "2"

		nPosProd	:=	Ascan(aAE8,{|x| x[1] ==(cAliasQry)->AFA_RECURS })

		If	nPosProd>0
			If aAE8[nPosProd,4]
				nCusto:= aAE8[nPosProd,2]
				cDesc := aAE8[nPosProd,3]
			Else
				dbSelectArea(cAliasQry)
				dbSkip()
				Loop
			Endif
		Else
			AE8->(DbSetOrder(1))
			AE8->(DbSeek(xFilial("AE8")+ (cAliasQry)->AFA_RECURS))
			If AE8->(&(cFiltroAE8))
				cDesc := AllTrim(AE8->AE8_DESCRI)

				If Empty((cAliasQry)->AFA_PRODUT)
					nCusto	:=	AEFPrdCust((cAliasQry)->AFA_PROJET ,(cAliasQry)->AFA_REVISA ,'R',(cAliasQry)->AFA_RECURS ,dDataBase)
				Else
					If AE8->AE8_VALOR >0
						nCusto:= AE8->AE8_VALOR
					Else
						SB1->(DbSetOrder(1))
						SB1->(DbSeek(xFilial("SB1")+ (cAliasQry)->AFA_PRODUT))
						If SB1->(&(cFiltroB1))
							nCusto:= RetFldProd(SB1->B1_COD,"B1_CUSTD")
						Else
							dbSelectArea(cAliasQry)
							dbSkip()
							Loop
						EndIf
					EndIf
				EndIf
				AAdd(aAE8,{(cAliasQry)->AFA_RECURS,nCusto,cDesc,.T.})
			Else
				dbSelectArea(cAliasQry)
				dbSkip()
				Loop
			EndIf

		EndIf
		RecLock("AFA",.F.)
		If nCusto >0
			Replace AFA->AFA_CUSTD With nCusto
		Else
			Replace AFA->AFA_CUSTD With 0
		EndIf
		MsUnlock()
	EndIf
	IncProc(STR0052 + cDesc) //"Atualizando "

	dbSelectArea(cAliasQry)
	dbSkip()
End

DbSelectArea("AE8")
DbSetOrder(1)
DbClearFilter()

Return(.T.)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥Pms200APerc     ≥ Autor ≥Fabio Rogerio Pereira ≥ Data ≥ 26-12-2001 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Funcao que altera os custos do projeto aplicando percentual.       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥SIGAPMS                                                       	 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function Pms200APerc(cFiltroAFA, cFiltroB1, aParam, lSimula,cFltAFAUsr)
Local nCusto  := 0
Local cDesc   := ""
Local cAliasQry:= ""
Default lSimula := .F.

cAliasQry := "AFA"

// filtra o arquivo de produtos para pesquisa otimizada
DbSelectArea("SB1")
DbSetOrder(1)
DbClearFilter()

If !Empty(cFiltroB1)
	DbSetFilter({||&(cFiltroB1)},cFiltroB1)
	dbGoTop()
EndIf

// filtra os produtos do projeto para pesquisa otimizada
DbSelectArea("AFA")
DbSetOrder(1)
If lSimula
	MsSeek(xFilial("AFA") + AJB->AJB_PROJET + AJB->AJB_REVISA)
Else
	MsSeek(xFilial("AFA") + AF8->AF8_PROJET + AF8->AF8_REVISA)
EndIf

While !Eof()

	If !&(cFiltroAFA)
		dbSelectArea(cAliasQry)
		dbSkip()
		Loop
	EndIf

	If !Empty((cAliasQry)->AFA_RECURS)
		IncProc(STR0052 + cDesc)  //"Atualizando "
		dbSelectArea(cAliasQry)
		dbSkip()
		Loop
	EndIf
	If cFltAFAUsr	<> Nil .And. !Empty(cFltAFAUsr) .And. !&(cFltAFAUsr)
		dbSelectArea(cAliasQry)
		dbSkip()
		Loop
	Endif

	cDesc := AllTrim(Posicione("SB1",1,xFilial("SB1") + (cAliasQry)->AFA_PRODUT,"B1_DESC"))

	If AFA->AFA_RECALC != "2"
		If aParam[1] == 1
			nCusto:= (cAliasQry)->AFA_CUSTD + (((cAliasQry)->AFA_CUSTD * aParam[2]) / 100)
		Else
			nCusto:= (cAliasQry)->AFA_CUSTD - (((cAliasQry)->AFA_CUSTD * aParam[2]) / 100)
		EndIf

		If (nCusto > 0)
			RecLock("AFA",.F.)
			Replace AFA->AFA_CUSTD With nCusto
			MsUnlock()
		EndIf
	EndIf

	IncProc(STR0052 + cDesc)  //"Atualizando "
	dbSelectArea(cAliasQry)
	dbSkip()
End

DbSelectArea("SB1")
DbSetOrder(1)
DbClearFilter()

Return(.T.)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥Pms200AManual   ≥ Autor ≥Fabio Rogerio Pereira ≥ Data ≥ 26-12-2001 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Funcao que altera os custos do projeto manualmente.                ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥SIGAPMS                                                       	 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function PMS200AManual(cFiltroPAFA, cFiltroB1, aParam, cFiltroAE8, cFiltroRAFA,cFltAfaUsr)
Local lRet     := .F.
Local oProdutos
Local oDlg
Local aProdutos:= {}
Local aObjects := {}
Local aPosObj  := {}
Local aSize    := MsAdvSize(.T.)
Local nPos     := 0
Local cDesc    := ""
Local cTarefa  := ""
Local cPict    := PesqPict("AFA","AFA_CUSTD")
Local cAliasQry:= ""
Local nQuantAF9:= 0
Local nQuantAFA:= 0
Local nDuracTsk:= 0
Local i := 0

cAliasQry := "AFA"

// filtra o arquivo de produtos para pesquisa otimizada
DbSelectArea("SB1")
DbSetOrder(1)
DbClearFilter()

If !Empty(cFiltroB1)
	DbSetFilter({||&(cFiltroB1)}, cFiltroB1)
	dbGoTop()
EndIf

// filtra os produtos do projeto para pesquisa otimizada
DbSelectArea("AFA")
DbSetOrder(1)
MsSeek(xFilial("AFA") + AF8->AF8_PROJET + AF8->AF8_REVISA)

While !Eof()
	If !&(cFiltroPAFA)
		dbSelectArea(cAliasQry)
		dbSkip()
		Loop
	EndIf

	If !Empty((cAliasQry)->AFA_RECURS)
		dbSelectArea(cAliasQry)
		dbSkip()
		Loop
	EndIf

	If cFltAFAUsr	<> Nil .And. !Empty(cFltAFAUsr) .And. !&(cFltAFAUsr)
		dbSelectArea(cAliasQry)
		dbSkip()
		Loop
	Endif

	cDesc    := AllTrim(Posicione("SB1",1,xFilial("SB1") + (cAliasQry)->AFA_PRODUT,"B1_DESC"))

	If SB1->(!Empty(cFiltroB1) .And. !&(cFiltroB1))
		dbSelectArea(cAliasQry)
		dbSkip()
		Loop
	EndIf

	cTarefa  := Posicione("AF9",1,xFilial("AF9") + AF8->AF8_PROJET + AF8->AF8_REVISA + (cAliasQry)->AFA_TAREFA,"AF9_DESCRI")
	nQuantAF9:= Posicione("AF9",1,xFilial("AF9") + AF8->AF8_PROJET + AF8->AF8_REVISA + (cAliasQry)->AFA_TAREFA,"AF9_QUANT")
	nDuracTsk:= Posicione("AF9",1,xFilial("AF9") + AF8->AF8_PROJET + AF8->AF8_REVISA + (cAliasQry)->AFA_TAREFA,"AF9_HDURAC")
	nQuantAFA:= PmsAFAQuant(AF8->AF8_PROJET,AF8->AF8_REVISA,(cAliasQry)->AFA_TAREFA,(cAliasQry)->AFA_PRODUT,nQuantAF9,(cAliasQry)->AFA_QUANT,nDuracTsk,,(cAliasQry)->AFA_RECURS)

	If aParam[1] == 3 //Projeto
		nPos:= aScan(aProdutos,{|x| x[2] == (cAliasQry)->AFA_PRODUT})
		If (nPos > 0)
			aProdutos[nPos][6]+= nQuantAFA
		Else
			Aadd(aProdutos,{"PRD", (cAliasQry)->AFA_PRODUT,cDesc,(cAliasQry)->AFA_TAREFA,"",nQuantAFA,(cAliasQry)->AFA_CUSTD})
		EndIf

	ElseIf aParam[1] == 4	//Tarefa

		nPos:= aScan(aProdutos,{|x| x[2]+x[4] == (cAliasQry)->AFA_PRODUT + (cAliasQry)->AFA_TAREFA})
		If (nPos > 0)
			aProdutos[nPos][6]+= nQuantAFA
		Else
			Aadd(aProdutos,{"PRD", (cAliasQry)->AFA_PRODUT,cDesc,(cAliasQry)->AFA_TAREFA,cTarefa,nQuantAFA,(cAliasQry)->AFA_CUSTD})
		EndIf
	EndIf

	dbSelectArea(cAliasQry)
	dbSkip()
End

//
// recurso
//

// filtra o arquivo de recursos para pesquisa otimizada
DbSelectArea("AE8")
DbSetOrder(1)
DbClearFilter()

If !Empty(cFiltroAE8)
	DbSetFilter({||&(cFiltroAE8)}, cFiltroAE8)
	dbGoTop()
EndIf

// filtra os recursos do projeto para pesquisa otimizada
DbSelectArea("AFA")
DbSetOrder(1)
MsSeek(xFilial("AFA") + AF8->AF8_PROJET + AF8->AF8_REVISA)

While !Eof()
	If !&(cFiltroRAFA)
		dbSelectArea(cAliasQry)
		dbSkip()
		Loop
	EndIf

	If Empty((cAliasQry)->AFA_RECURS)
		dbSelectArea(cAliasQry)
		dbSkip()
		Loop
	EndIf

	If cFltAFAUsr	<> Nil .And. !Empty(cFltAFAUsr) .And. !&(cFltAFAUsr)
		dbSelectArea(cAliasQry)
		dbSkip()
		Loop
	Endif
	cDesc     := AllTrim(Posicione("AE8", 1, xFilial("AE8") + (cAliasQry)->AFA_RECURS, "AE8_DESCRI"))
	cTarefa   := Posicione("AF9", 1, xFilial("AF9") + AF8->AF8_PROJET + AF8->AF8_REVISA + (cAliasQry)->AFA_TAREFA, "AF9_DESCRI")
	nQuantAF9 := Posicione("AF9", 1, xFilial("AF9") + AF8->AF8_PROJET + AF8->AF8_REVISA + (cAliasQry)->AFA_TAREFA, "AF9_QUANT")
	nDuracTsk := Posicione("AF9", 1, xFilial("AF9") + AF8->AF8_PROJET + AF8->AF8_REVISA + (cAliasQry)->AFA_TAREFA, "AF9_HDURAC")
	nQuantAFA := PmsAFAQuant(AF8->AF8_PROJET, AF8->AF8_REVISA, (cAliasQry)->AFA_TAREFA, (cAliasQry)->AFA_RECURS, nQuantAF9, (cAliasQry)->AFA_QUANT, nDuracTsk, , (cAliasQry)->AFA_RECURS)

	If aParam[1] == 3 //Projeto
		nPos := aScan(aProdutos,{|x| x[2] == (cAliasQry)->AFA_RECURS})
		If (nPos > 0)
			aProdutos[nPos][6] += nQuantAFA
		Else
			Aadd(aProdutos, {"REC", (cAliasQry)->AFA_RECURS, cDesc, (cAliasQry)->AFA_TAREFA, "", nQuantAFA, (cAliasQry)->AFA_CUSTD})
		EndIf

	ElseIf aParam[1] == 4	//Tarefa

		nPos:= aScan(aProdutos, {|x| x[2]+x[4] == (cAliasQry)->AFA_RECURS + (cAliasQry)->AFA_TAREFA})
		If (nPos > 0)
			aProdutos[nPos][6] += nQuantAFA
		Else
			Aadd(aProdutos, {"REC", (cAliasQry)->AFA_RECURS, cDesc, (cAliasQry)->AFA_TAREFA, cTarefa, nQuantAFA, (cAliasQry)->AFA_CUSTD})
		EndIf
	EndIf

	dbSelectArea(cAliasQry)
	dbSkip()
End


If (Len(aProdutos) == 0)
	Aadd(aProdutos,{"", "","","","",0,0})
EndIf

aAdd( aObjects, { 100, 100, .T., .T., .T. } )

aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4],3,3 }
aPosObj:= MsObjSize( aInfo, aObjects, .T.,.F. )

// ajuste manual por projeto ou tarefa
If aParam[1] == 3 .Or. aParam[1] == 4

	Do Case
		Case aParam[11] == 1

			// reordenar o array de produtos por produto/recurso
			aSort(aProdutos,,, {|x, y| x[1] + x[2] < y[1] + y[2] })

		Case aParam[11] == 2

			// reordenar o array de produtos por tarefa
			aSort(aProdutos,,, {|x, y| x[4] < y[4] })
	EndCase
EndIf

If aParam[1] == 3
	For i := 1 To Len(aProdutos)
		aProdutos[i][4] := ""
	Next
EndIf


DEFINE MSDIALOG oDlg TITLE  STR0053 FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL //"Atualizacao de Custo"

	@ aPosObj[1,1] , aPosObj[1,2] LISTBOX oProdutos FIELDS	COLSIZES 50,120,50,120,80,80 HEADER  "Tipo", "Codigo",STR0055,STR0021,STR0055,STR0056,STR0057 SIZE aPosObj[1,3] , aPosObj[1,4] DESIGN  OF oDlg PIXEL  //"Produto","Descricao","Tarefa","Descricao","Quantidade","Custo Unitario"
	oProdutos:SetArray(aProdutos)
	oProdutos:bLine     := { || {aProdutos[oProdutos:nAT,1], aProdutos[oProdutos:nAT,2],aProdutos[oProdutos:nAT,3],aProdutos[oProdutos:nAT,4],aProdutos[oProdutos:nAT,5],Transform(aProdutos[oProdutos:nAT,6],cPict),Transform(aProdutos[oProdutos:nAT,7],cPict)}}
	oProdutos:blDblClick:= { || Pms200ChgCusto(@aProdutos,oProdutos,oDlg)}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| lRet:= .T., Processa({||Pms200GrvCusto(cFiltroPAFA,aProdutos,aParam,cFiltroRAFA,cFltAFAUsr)},STR0049),oDlg:End() },{||oDlg:End()}) //"Atualizando custos. Aguarde..."

DbSelectArea("SB1")
DbSetOrder(1)
DbClearFilter()

Return(lRet)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥Pms200ChgCusto  ≥ Autor ≥Fabio Rogerio Pereira ≥ Data ≥ 26-12-2001 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Funcao que altera os custos do projeto manualmente.                ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥SIGAPMS                                                        	 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function Pms200ChgCusto(aArray,oObj)
Local oDlg
Local oGet
Local oGet1
Local nCusto:= 0

DEFINE MSDIALOG oDlg TITLE STR0053 FROM 001,001 TO 150, 250 OF oMainWnd PIXEL //"Atualizacao de Custo"
    @002,002 TO 50,125 LABEL STR0059 OF oDlg PIXEL //"Custos"

	@010,005 SAY STR0060 PIXEL SIZE 50,8 OF oDlg   //"Custo Atual"
	@010,055 MSGET oGet1 VAR aArray[oObj:nAT][7] PICTURE PesqPict("AFA","AFA_CUSTD") PIXEL SIZE 60,8 OF oDlg WHEN .F.
	oGet1:cSX1Hlp := "PMSA2004"
	@025,005 SAY STR0061 PIXEL SIZE 50,8 OF oDlg  //"Custo Novo"
	@025,055 MSGET oGet VAR nCusto PICTURE PesqPict("AFA","AFA_CUSTD") PIXEL SIZE 60,8 OF oDlg
	oGet:cSX1Hlp := "PMSA2005"

	DEFINE SBUTTON FROM 55, 60   TYPE 1 ENABLE OF oDlg ACTION (aArray[oObj:nAT][7]:= nCusto,oDlg:End())
	DEFINE SBUTTON FROM 55, 90   TYPE 2 ENABLE OF oDlg ACTION (oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

Return(.T.)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥Pms200GrvCusto  ≥ Autor ≥Fabio Rogerio Pereira ≥ Data ≥ 26-12-2001 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Funcao que grava os custos do projeto manualmente.                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥SIGAPMS                                                       	 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function PMS200GrvCusto(cFiltroPAFA,aProdutos,aParam,cFiltroRAFA,cFltAFAUsr)
Local nView:= 0

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Grava o custo dos produtos projeto.   ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
For nView:= 1 To Len(aProdutos)
	If (aParam[1] == 3)    //Projeto
		dbSelectArea("AFA")
		dbSetOrder(2)
		If MsSeek(xFilial("AFA") + AF8->AF8_PROJET + AF8->AF8_REVISA,.T.)
			While !Eof()
				If !&(cFiltroPAFA)
					dbSelectArea("AFA")
					dbSkip()
					Loop
				EndIf

				If cFltAFAUsr <> Nil .And. !Empty(cFltAFAUsr) .And. !&(cFltAFAUsr)
					dbSelectArea("AFA")
					dbSkip()
					Loop
				Endif
				If Alltrim(Upper(aProdutos[nView][1])) == "PRD"
					If (AFA->AFA_PRODUT == aProdutos[nView][2])
						RecLock("AFA", .F.)
						Replace AFA->AFA_CUSTD With aProdutos[nView][7]
						MsUnLock()
					EndIf
				Else
					If (AFA->AFA_RECURS == aProdutos[nView][2])
						RecLock("AFA", .F.)
						Replace AFA->AFA_CUSTD With aProdutos[nView][7]
						MsUnLock()
					EndIf
				EndIf

				dbSkip()
			End
		EndIf
	ElseIf (aParam[1] == 4) //Tarefa
		dbSelectArea("AFA")
		dbSetOrder(1)
		If MsSeek(xFilial("AFA") + AF8->AF8_PROJET + AF8->AF8_REVISA + aProdutos[nView][4])
			While !Eof() .And. (xFilial("AFA") + AF8->AF8_PROJET + AF8->AF8_REVISA + aProdutos[nView][4] == AFA->AFA_FILIAL + AFA->AFA_PROJET + AFA->AFA_REVISA + AFA->AFA_TAREFA)

				If cFltAFAUsr	<> Nil .And. !Empty(cFltAFAUsr) .And. !&(cFltAFAUsr)
					dbSelectArea("AFA")
					dbSkip()
					Loop
				Endif

				If Alltrim(Upper(aProdutos[nView][1])) == "PRD"
					If (aProdutos[nView][2] == AFA->AFA_PRODUT)
						RecLock("AFA", .F.)
						Replace AFA->AFA_CUSTD With aProdutos[nView][7]
						MsUnLock()
					EndIf
				Else
					If (aProdutos[nView][2] == AFA->AFA_RECURS)
						RecLock("AFA", .F.)
						Replace AFA->AFA_CUSTD With aProdutos[nView][7]
						MsUnLock()
					EndIf
				EndIf
				dbSkip()
			End
		EndIf
	EndIf

	IncProc(STR0052 + aProdutos[nView][2]) //"Atualizando "
Next

Return(.T.)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥Pms200AEDT      ≥ Autor ≥Fabio Rogerio Pereira ≥ Data ≥ 09-05-2002 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Funcao que atualiza os custos totais das Tarefas/EDT.              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥SIGAPMS                                                       	 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PMS200AEDT(lSimula)

// se o recalculo de custo do orcamento estiver habilitado OU
// se deve fazer o calculo dos custos das tarefas e edts,
// calcula os custos.
If      (AF8->AF8_RECALC=="1")  ;
   .OR. (AF8->AF8_AUTCUS!="2")

	Processa({||Pms200AuxEDT(lSimula)},STR0102)  //"Atualizando Custos da EDT. Aguarde..."

EndIf

Return

Static Function Pms_Converte(nCusto, nMoeda, cCnvPRV, dDtConv, dStart, dFinish, aCusto, aTX2, cTrunca, nQuantTrf, aDecCst, lTotal)

Local nx
Local dAuxConv
Local aVal		:= {0,0,0,0,0}

DEFAULT aCusto	:= {0,0,0,0,0}

Do Case
	Case cCnvPrv == "2" // Data Fixa
		aVal[1] := xMoeda(nCusto,nMoeda,1,dDtConv,aDecCst[1])
		aVal[2] := xMoeda(nCusto,nMoeda,2,dDtConv,aDecCst[2])
		aVal[3] := xMoeda(nCusto,nMoeda,3,dDtConv,aDecCst[3])
		aVal[4] := xMoeda(nCusto,nMoeda,4,dDtConv,aDecCst[4])
		aVal[5] := xMoeda(nCusto,nMoeda,5,dDtConv,aDecCst[5])
		PMS_TRUNCA aVal[1], aVal[2], aVal[3], aVal[4], aVal[5], aDecCst[1], aDecCst[2], aDecCst[3], aDecCst[4], aDecCst[5], nQuantTrf, cTrunca, lTotal TO aCusto[1], aCusto[2], aCusto[3], aCusto[4], aCusto[5]
	Case cCnvPrv == "3" // Taxa Media ( 3 Valores )
		dAuxConv := dStart
		For nx := 1 to 3
			aVal[1] += xMoeda(nCusto,nMoeda,1,dAuxConv,aDecCst[1])
			aVal[2] += xMoeda(nCusto,nMoeda,2,dAuxConv,aDecCst[2])
			aVal[3] += xMoeda(nCusto,nMoeda,3,dAuxConv,aDecCst[3])
			aVal[4] += xMoeda(nCusto,nMoeda,4,dAuxConv,aDecCst[4])
			aVal[5] += xMoeda(nCusto,nMoeda,5,dAuxConv,aDecCst[5])

			dAuxConv += (dFinish-dStart)/3
		Next nx
		PMS_TRUNCA aVal[1]/3, aVal[2]/3, aVal[3]/3, aVal[4]/3, aVal[5]/3, aDecCst[1], aDecCst[2], aDecCst[3], aDecCst[4], aDecCst[5], nQuantTrf, cTrunca, lTotal TO aCusto[1], aCusto[2], aCusto[3], aCusto[4], aCusto[5]
	Case cCnvPrv == "4" // Taxa Media ( 15 Valores )
		dAuxConv := dStart
		For nx := 1 to 15
			aVal[1] += xMoeda(nCusto,nMoeda,1,dAuxConv,aDecCst[1])
			aVal[2] += xMoeda(nCusto,nMoeda,2,dAuxConv,aDecCst[2])
			aVal[3] += xMoeda(nCusto,nMoeda,3,dAuxConv,aDecCst[3])
			aVal[4] += xMoeda(nCusto,nMoeda,4,dAuxConv,aDecCst[4])
			aVal[5] += xMoeda(nCusto,nMoeda,5,dAuxConv,aDecCst[5])

			dAuxConv += (dFinish-dStart)/15
		Next nx
		PMS_TRUNCA aVal[1]/15, aVal[2]/15, aVal[3]/15, aVal[4]/15, aVal[5]/15, aDecCst[1], aDecCst[2], aDecCst[3], aDecCst[4], aDecCst[5], nQuantTrf, cTrunca, lTotal TO aCusto[1], aCusto[2], aCusto[3], aCusto[4], aCusto[5]
	Case cCnvPrv == "5" // Data Inicial
		aVal[1] := xMoeda(nCusto,nMoeda,1,dStart,aDecCst[1])
		aVal[2] := xMoeda(nCusto,nMoeda,2,dStart,aDecCst[2])
		aVal[3] := xMoeda(nCusto,nMoeda,3,dStart,aDecCst[3])
		aVal[4] := xMoeda(nCusto,nMoeda,4,dStart,aDecCst[4])
		aVal[5] := xMoeda(nCusto,nMoeda,5,dStart,aDecCst[5])
		PMS_TRUNCA aVal[1], aVal[2], aVal[3], aVal[4], aVal[5], aDecCst[1], aDecCst[2], aDecCst[3], aDecCst[4], aDecCst[5], nQuantTrf, cTrunca, lTotal TO aCusto[1], aCusto[2], aCusto[3], aCusto[4], aCusto[5]
	Case cCnvPrv == "6" // Data Final
		aVal[1] := xMoeda(nCusto,nMoeda,1,dFinish,aDecCst[1])
		aVal[2] := xMoeda(nCusto,nMoeda,2,dFinish,aDecCst[2])
		aVal[3] := xMoeda(nCusto,nMoeda,3,dFinish,aDecCst[3])
		aVal[4] := xMoeda(nCusto,nMoeda,4,dFinish,aDecCst[4])
		aVal[5] := xMoeda(nCusto,nMoeda,5,dFinish,aDecCst[5])
		PMS_TRUNCA aVal[1], aVal[2], aVal[3], aVal[4], aVal[5], aDecCst[1], aDecCst[2], aDecCst[3], aDecCst[4], aDecCst[5], nQuantTrf, cTrunca, lTotal TO aCusto[1], aCusto[2], aCusto[3], aCusto[4], aCusto[5]
	Case cCnvPrv == "7" // Usuario Informa
		aVal[1] := if(aTX2[1]==0,0,xMoeda(nCusto,nMoeda,1,,aDecCst[1],aTX2[nMoeda],aTX2[1]))
		aVal[2] := if(aTX2[2]==0,0,xMoeda(nCusto,nMoeda,2,,aDecCst[2],aTX2[nMoeda],aTX2[2]))
		aVal[3] := if(aTX2[3]==0,0,xMoeda(nCusto,nMoeda,3,,aDecCst[3],aTX2[nMoeda],aTX2[3]))
		aVal[4] := if(aTX2[4]==0,0,xMoeda(nCusto,nMoeda,4,,aDecCst[4],aTX2[nMoeda],aTX2[4]))
		aVal[5] := if(aTX2[5]==0,0,xMoeda(nCusto,nMoeda,5,,aDecCst[5],aTX2[nMoeda],aTX2[5]))
		PMS_TRUNCA aVal[1], aVal[2], aVal[3], aVal[4], aVal[5], aDecCst[1], aDecCst[2], aDecCst[3], aDecCst[4], aDecCst[5], nQuantTrf, cTrunca, lTotal TO aCusto[1], aCusto[2], aCusto[3], aCusto[4], aCusto[5]
	OtherWise	// Data Base
		aVal[1] := xMoeda(nCusto,nMoeda,1,,aDecCst[1])
		aVal[2] := xMoeda(nCusto,nMoeda,2,,aDecCst[2])
		aVal[3] := xMoeda(nCusto,nMoeda,3,,aDecCst[3])
		aVal[4] := xMoeda(nCusto,nMoeda,4,,aDecCst[4])
		aVal[5] := xMoeda(nCusto,nMoeda,5,,aDecCst[5])
		PMS_TRUNCA aVal[1], aVal[2], aVal[3], aVal[4], aVal[5], aDecCst[1], aDecCst[2], aDecCst[3], aDecCst[4], aDecCst[5], nQuantTrf, cTrunca, lTotal TO aCusto[1], aCusto[2], aCusto[3], aCusto[4], aCusto[5]
EndCase

Return aCusto


Static Function PmsA200Fix(cSQL, cDB)
Local c,s,a,i,pc,cc,t,j,lc

cDB:=AllTrim(Upper(cDB))

if cDB=="INFORMIX"

	cSQL:=StrTran(cSQL,"LTRIM ( ","TRIM ( ")
	cSQL:=StrTran(cSQL,"VALUES (","")
	cSQL:=StrTran(cSQL,";);",";")
	cSQL:=StrTran(cSQL,"numeric","decimal(28,12)")

	s:=''
	a:=cSQL
	i:=AT("ROUND", a)
	do while i>0
		pc:=1
		cc:=0
		s:=s+left(a,i-1)
		t:=""
		j:=i+7
		lc:=-1
		do while j<len(a) .and. pc>0
			j:=j+1
			c:=substr(a,j,1)
			do case
				case c=')'
					pc--
				case c='('
					pc++
				case c=',' .and. pc==1
					cc++
					lc:=j
			endcase
		enddo
		if pc>0
			a:=substr(a,i)
			i:=0
		else
			if cc=2
				a:="TRUNC ( "+substr(a, i+8, lc-i-8)+")"+substr(a,j+1)
			else
				s:=s+"ROUND ( "
				a:=substr(a,i+8)
			endif
			i:=AT("ROUND", a)
		endif
	enddo
	cSQL:=s+a

elseif cDB=="ORACLE"

	cSQL:=StrTran(cSQL,"PMS_DATEDIFF ( 'DAY', vDT1 , vDT2 );","TO_DATE(vDT2,'YYYYMMDD')-TO_DATE(vDT1,'YYYYMMDD');")
	cSQL:=StrTran(cSQL,"PMS_DATEADD ( 'DAY', vJ , vDT1 );","TO_DATE(vDT1,'YYYYMMDD') + vJ;")
	cSQL:=StrTran(cSQL,"TO_NUMBER( (vJ  * vI )  /","CEIL( (vJ  * vI )  /")
	cSQL:=StrTran(cSQL,"= ''","is null")
	cSQL:=StrTran(cSQL,"<> ''","is not null")
	cSQL:=StrTran(cSQL,"numeric","decimal(28,12)")

	s:=''
	a:=cSQL
	i:=AT("ROUND", a)
	do while i>0
		pc:=1
		cc:=0
		s:=s+left(a,i-1)
		t:=""
		j:=i+7
		lc:=-1
		do while j<len(a) .and. pc>0
			j:=j+1
			c:=substr(a,j,1)
			do case
				case c=')'
					pc--
				case c='('
					pc++
				case c=',' .and. pc==1
					cc++
					lc:=j
			endcase
		enddo
		if pc>0
			a:=substr(a,i)
			i:=0
		else
			if cc=2
				a:="TRUNC ( "+substr(a, i+7, lc-i-7)+")"+substr(a,j+1)
			else
				s:=s+"ROUND ( "
				a:=substr(a,i+7)
			endif
			i:=AT("ROUND", a)
		endif
	enddo
	cSQL:=s+a

elseif cDB=="DB2"

	cSQL:=StrTran(cSQL,"set vJ  = DAYS(DATE(vDT1 )) - DAYS(DATE(vDT2 ));","set vJ=DAYS(DATE(SUBSTR(vDT1,1,4)||'-'||SUBSTR(vDT1,5,2)||'-'||SUBSTR(vDT1,7,2))); set vK=DAYS(DATE(SUBSTR(vDT2,1,4)||'-'||SUBSTR(vDT2,5,2)||'-'||SUBSTR(vDT2,7,2))); set vJ=vK-vJ;")
	cSQL:=StrTran(cSQL,"PMS_DATEDIFF ( DAY, vDT1 , vDT2 );","DAY(DATE(vDT2) - DATE(vDT1));")
	cSQL:=StrTran(cSQL,"PMS_DATEADD ( DAY, vJ , vDT1 )","DATE ( SUBSTR( vDT1, 1, 4 )||'-'||SUBSTR( vDT1, 5, 2 )||'-'||SUBSTR( vDT1, 7, 2 ) ) + vJ DAYS")
	cSQL:=StrTran(cSQL,"set vDTAUX  = CHAR(vDT ,'YYYYMMDD');","set vTASK  = CHAR(vDT, ISO); set vDTAUX  = SUBSTR(vTASK,1,4)||SUBSTR(vTASK,6,2)||SUBSTR(vTASK,9,2);")
	cSQL:=StrTran(cSQL,"set vfim_CUR  = 0 ;","set fim_CUR = 0;")
	cSQL:=StrTran(cSQL,"vTX1 DECIMAL( 28 , 12 ) ;","vTX1 DOUBLE;")
	cSQL:=StrTran(cSQL,"vTX2 DECIMAL( 28 , 12 ) ;","vTX2 DOUBLE;")
	cSQL:=StrTran(cSQL,"vTX3 DECIMAL( 28 , 12 ) ;","vTX3 DOUBLE;")
	cSQL:=StrTran(cSQL,"vTX4 DECIMAL( 28 , 12 ) ;","vTX4 DOUBLE;")
	cSQL:=StrTran(cSQL,"vTX5 DECIMAL( 28 , 12 ) ;","vTX5 DOUBLE;")
	cSQL:=StrTran(cSQL,"set vfim_CUR  = 0 ;","set fim_CUR  = 0 ;")

	s:=''
	a:=cSQL
	i:=AT("ROUND", a)
	do while i>0
		pc:=1
		cc:=0
		s:=s+left(a,i-1)
		t:=""
		j:=i+7
		lc:=-1
		do while j<len(a) .and. pc>0
			j:=j+1
			c:=substr(a,j,1)
			do case
				case c=')'
					pc--
				case c='('
					pc++
				case c=',' .and. pc==1
					cc++
					lc:=j
			endcase
		enddo
		if pc>0
			a:=substr(a,i)
			i:=0
		else
			if cc=2
				a:="TRUNC ( "+substr(a, i+8, lc-i-8)+")"+substr(a,j+1)
			else
				s:=s+"ROUND ( "
				a:=substr(a,i+8)
			endif
			i:=AT("ROUND", a)
		endif
	enddo
	cSQL:=s+a

elseif cDB=="SYBASE"

	cSQL:=StrTran(cSQL,"numeric","decimal(28,12)")

elseif cDB=="MSSQL"

	cSQL:=StrTran(cSQL,"numeric","decimal(28,12)")

else

	cSQL:=StrTran(cSQL,"numeric","decimal(28,12)")

endif

Return cSQL


//-------------------------------------------------------------------
/*/{Protheus.doc} Pms200Exec

Atualiza os custos totais das Tarefas/EDT com SQL.

@param cFil,
@param cProjeto,
@param cRevisao,
@param cPmsCust,
@param cDtBase,
@param aDec,
@param nAtuTarefa,
@param nAtuEDT,

@author Marcelo Akama
@since 19-11-2008
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Pms200Exec(cFil, cProjeto, cRevisao, cPmsCust, cDtBase, aDec, nAtuTarefa, nAtuEDT)
Local cSQL   := ''
Local cRet   := 1
Local lRet   := .T.
Local aResult:= {}

Local cAF8			:= RetSQLName("AF8")
Local cAFA			:= RetSQLName("AFA")
Local cAF9			:= RetSQLName("AF9")
Local cAFB			:= RetSQLName("AFB")
Local cSM2			:= RetSQLName("SM2")
Local cAFC			:= RetSQLName("AFC")
Local cDB 			:= Upper(Alltrim(TcGetDB()))
Local lAltProc 	:= (cDB == "INFORMIX" .Or. cDB == "DB2" .Or. cDB == "ORACLE")
Local cNextAlias	:= GetNextAlias()
Local cProc		:= ""
Local cTmp1		:= ""
Local cTmp2		:= ""

DEFAULT lTskCust0 := !__lBlind .AND. MsgYesNo( "Deseja manter Markup de tarefas com custo zero?","Markup")

cProc		:= "PMS200_"+cNextAlias
cTmp1		:= "PMS200_tbl1"+cNextAlias
cTmp2		:= "PMS200_tbl2"+cNextAlias

PMS200Tool(.F.,cDB)

If !TCSPExist( cProc )
	cSQL:=cSQL+"create procedure "+cProc+" (@IN_ATUAF9 int, @IN_ATUAFC int, @OUT_RET int output) as"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"declare @CNVPRV	char(1)			-- Tipo de convers„o de custo"+CRLF
	cSQL:=cSQL+"declare @DTCONV	char(8)			-- Data da convers„o"+CRLF
	cSQL:=cSQL+"declare @TRUNC	char(1)			-- Tipo arredondamento/truncamento"+CRLF
	cSQL:=cSQL+"declare @BDIPAD	decimal(28,12)	-- BDI padr„o do projeto"+CRLF
	cSQL:=cSQL+"declare @NIVEL	varchar(250)	-- Nivel"+CRLF
	cSQL:=cSQL+"declare @X		int"+CRLF
	cSQL:=cSQL+"declare @I		int"+CRLF
	cSQL:=cSQL+"declare @J		int"+CRLF
	cSQL:=cSQL+"declare @K		int"+CRLF
	cSQL:=cSQL+"declare @DTAUX	char(8)			-- Data"+CRLF
	cSQL:=cSQL+"declare @DT1	char(8)			-- Data 1"+CRLF
	cSQL:=cSQL+"declare @DT2	char(8)			-- Data 2"+CRLF
	cSQL:=cSQL+"declare @MOEDA	int				-- Moeda"+CRLF
	cSQL:=cSQL+"declare @TX1	decimal(28,12)	-- TX1"+CRLF
	cSQL:=cSQL+"declare @TX2	decimal(28,12)	-- TX2"+CRLF
	cSQL:=cSQL+"declare @TX3	decimal(28,12)	-- TX3"+CRLF
	cSQL:=cSQL+"declare @TX4	decimal(28,12)	-- TX4"+CRLF
	cSQL:=cSQL+"declare @TX5	decimal(28,12)	-- TX5"+CRLF
	cSQL:=cSQL+"declare @VL1	decimal(28,12)	-- Valor 1"+CRLF
	cSQL:=cSQL+"declare @VL2	decimal(28,12)	-- Valor 2"+CRLF
	cSQL:=cSQL+"declare @VL3	decimal(28,12)	-- Valor 3"+CRLF
	cSQL:=cSQL+"declare @VL4	decimal(28,12)	-- Valor 4"+CRLF
	cSQL:=cSQL+"declare @VL5	decimal(28,12)	-- Valor 5"+CRLF
	cSQL:=cSQL+"declare @BDI	decimal(28,12)	-- BDI"+CRLF
	cSQL:=cSQL+"declare @EDT	varchar(250)	-- EDT"+CRLF
	cSQL:=cSQL+"declare @EDTPAI	varchar(250)	-- EDTPai"+CRLF
	cSQL:=cSQL+"declare @TASK	varchar(250)	-- Tarefa"+CRLF
	cSQL:=cSQL+"declare @DT		datetime"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"declare @fim_CUR	int			-- Indica fim do cursor no DB2"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"select @OUT_RET=0"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"select @CNVPRV=ltrim(AF8_CNVPRV), @DTCONV=ltrim(AF8_DTCONV), @TRUNC=ltrim(AF8_TRUNCA), @BDIPAD=AF8_BDIPAD"+CRLF
	cSQL:=cSQL+"from "+cAF8+""+CRLF
	cSQL:=cSQL+"where AF8_FILIAL='"+cFil+"' and AF8_PROJET='"+cProjeto+"' and D_E_L_E_T_<>'*'"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"if @TRUNC='' select @TRUNC='1'"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"begin transaction"+CRLF
	cSQL:=cSQL+""+CRLF

	// Criacao das tabelas tempor·rias
	if cDB=="INFORMIX"
		cRet := TCSqlExec( '	CREATE TABLE '+cTmp1+' ( TAREFA    char('+ltrim(str(TamSX3("AF9_TAREFA")[1]))+'), VALOR decimal(28,12), QUANT decimal(28,12), VALOR1 decimal(28,12), VALOR2 decimal(28,12), VALOR3 decimal(28,12), VALOR4 decimal(28,12), VALOR5 decimal(28,12), MOEDA decimal(28,12), DTCONV    char(8), CNVPRV    char(1), DTINICIO    char(8), DTFIM    char(8), TX1 decimal(28,12), TX2 decimal(28,12), TX3 decimal(28,12), TX4 decimal(28,12), TX5 decimal(28,12) )' )
		If cRet <> 0
			if !__lBlind
				MsgAlert(STR0316+" "+cTmp1+": "+TCSqlError())   //'SQL Error - Erro ao criar tabela: '
			endif
			conout(STR0316+" "+cTmp1+": "+TCSqlError()) // 'SQL Error - Erro ao criar tabela: '
			lRet := .F.
		EndIf
		cRet := TCSqlExec( '	CREATE TABLE '+cTmp2+' ( TAREFA2    char('+ltrim(str(TamSX3("AF9_TAREFA")[1]))+'), EDTPAI    char('+ltrim(str(TamSX3("AF9_EDTPAI")[1]))+'), BDI decimal(28,12), FLAG integer, UTIBDI    char('+ltrim(str(TamSX3("AF9_UTIBDI")[1]))+') )' )
		If cRet <> 0
			if !__lBlind
				MsgAlert(STR0316+" "+cTmp2+": "+TCSqlError())   //'SQL Error - Erro ao criar tabela: '
			endif
			conout(STR0316+" "+cTmp2+": "+TCSqlError()) // 'SQL Error - Erro ao criar tabela: '
			lRet := .F.
		EndIf
	elseIf cDB=="DB2"
		cRet := TCSqlExec( '	CREATE TABLE '+cTmp1+' ( TAREFA varchar('+ltrim(str(TamSX3("AF9_TAREFA")[1]))+'), VALOR double, QUANT decimal(28,12), VALOR1 decimal(28,12), VALOR2 decimal(28,12), VALOR3 decimal(28,12), VALOR4 decimal(28,12), VALOR5 decimal(28,12), MOEDA decimal(28,12), DTCONV varchar(8), CNVPRV varchar(1), DTINICIO varchar(8), DTFIM varchar(8), TX1 double, TX2 double, TX3 double, TX4 double, TX5 double )' )
		If cRet <> 0
			if !__lBlind
				MsgAlert(STR0316+" "+cTmp1+": "+TCSqlError())   //'SQL Error - Erro ao criar tabela: '
			endif
			conout(STR0316+" "+cTmp1+": "+TCSqlError()) // 'SQL Error - Erro ao criar tabela: '
			lRet := .F.
		EndIf
		cRet := TCSqlExec( '	CREATE TABLE '+cTmp2+' ( TAREFA2 varchar('+ltrim(str(TamSX3("AF9_TAREFA")[1]))+'), EDTPAI varchar('+ltrim(str(TamSX3("AF9_EDTPAI")[1]))+'), BDI decimal(28,12), FLAG integer, UTIBDI varchar('+ltrim(str(TamSX3("AF9_UTIBDI")[1]))+') )' )
		If cRet <> 0
			if !__lBlind
				MsgAlert(STR0316+" "+cTmp2+": "+TCSqlError())   //'SQL Error - Erro ao criar tabela: '
			endif
			conout(STR0316+" "+cTmp2+": "+TCSqlError()) // 'SQL Error - Erro ao criar tabela: '
			lRet := .F.
		EndIf
	else
		cRet := TCSqlExec( '	CREATE TABLE '+cTmp1+' ( TAREFA varchar('+ltrim(str(TamSX3("AF9_TAREFA")[1]))+'), VALOR numeric(28,12), QUANT numeric(28,12), VALOR1 numeric(28,12), VALOR2 numeric(28,12), VALOR3 numeric(28,12), VALOR4 numeric(28,12), VALOR5 numeric(28,12), MOEDA numeric(28,12), DTCONV varchar(8), CNVPRV varchar(1), DTINICIO varchar(8), DTFIM varchar(8), TX1 numeric(28,12), TX2 numeric(28,12), TX3 numeric(28,12), TX4 numeric(28,12), TX5 numeric(28,12) )' )
		If cRet <> 0
			if !__lBlind
				MsgAlert(STR0316+" "+cTmp1+": "+TCSqlError())   //'SQL Error - Erro ao criar tabela: '
			endif
			conout(STR0316+" "+cTmp1+": "+TCSqlError()) // 'SQL Error - Erro ao criar tabela: '
			lRet := .F.
		EndIf
		cRet := TCSqlExec( '	CREATE TABLE '+cTmp2+' ( TAREFA2 varchar('+ltrim(str(TamSX3("AF9_TAREFA")[1]))+'), EDTPAI varchar('+ltrim(str(TamSX3("AF9_EDTPAI")[1]))+'), BDI numeric(28,12), FLAG integer, UTIBDI varchar('+ltrim(str(TamSX3("AF9_UTIBDI")[1]))+') )' )
		If cRet <> 0
			if !__lBlind
				MsgAlert(STR0316+" "+cTmp2+": "+TCSqlError())   //'SQL Error - Erro ao criar tabela: '
			endif
			conout(STR0316+" "+cTmp2+": "+TCSqlError()) // 'SQL Error - Erro ao criar tabela: '
			lRet := .F.
		EndIf
	endif
	
	
	
	cSQL:=cSQL+""+CRLF

	cSQL:=cSQL+"	if @IN_ATUAF9<>0"+CRLF
	cSQL:=cSQL+"		begin"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"			-- Recursos"+CRLF
	cSQL:=cSQL+"			insert into "+cTmp1+" (TAREFA,VALOR,QUANT,VALOR1,VALOR2,VALOR3,VALOR4,VALOR5,MOEDA,DTCONV,CNVPRV,DTINICIO,DTFIM,TX1,TX2,TX3,TX4,TX5)"+CRLF
	cSQL:=cSQL+"			select"+CRLF
	cSQL:=cSQL+"				AFA_TAREFA as TAREFA,"+CRLF
	cSQL:=cSQL+"				AFA_QUANT*AFA_CUSTD as VALOR,"+CRLF
	cSQL:=cSQL+"				AF9_QUANT as QUANT,"+CRLF
	cSQL:=cSQL+"				0 as VALOR1,"+CRLF
	cSQL:=cSQL+"				0 as VALOR2,"+CRLF
	cSQL:=cSQL+"				0 as VALOR3,"+CRLF
	cSQL:=cSQL+"				0 as VALOR4,"+CRLF
	cSQL:=cSQL+"				0 as VALOR5,"+CRLF
	cSQL:=cSQL+"				AFA_MOEDA as MOEDA,"+CRLF
	cSQL:=cSQL+"				AF9_DTCONV as DTCONV,"+CRLF
	cSQL:=cSQL+"				AF9_CNVPRV as CNVPRV,"+CRLF
	cSQL:=cSQL+"				AF9_START as DTINICIO,"+CRLF
	cSQL:=cSQL+"				AF9_FINISH as DTFIM,"+CRLF
	cSQL:=cSQL+"				1.0 as TX1, AF9_TXMO2 as TX2, AF9_TXMO3 as TX3, AF9_TXMO4 as TX4, AF9_TXMO5 as TX5"+CRLF
	cSQL:=cSQL+"			from "+cAFA+" a, "+cAF9+" b"+CRLF
	cSQL:=cSQL+"			where AFA_FILIAL='"+cFil+"' and AFA_PROJET='"+cProjeto+"' and AFA_REVISA='"+cRevisao+"' and a.D_E_L_E_T_<>'*' and b.D_E_L_E_T_<>'*'"+CRLF
	cSQL:=cSQL+"			and AFA_FILIAL=AF9_FILIAL and AFA_PROJET=AF9_PROJET and AFA_REVISA=AF9_REVISA and AFA_TAREFA=AF9_TAREFA"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"			-- Despesas"+CRLF
	cSQL:=cSQL+"			insert into "+cTmp1+" (TAREFA,VALOR,QUANT,VALOR1,VALOR2,VALOR3,VALOR4,VALOR5,MOEDA,DTCONV,CNVPRV,DTINICIO,DTFIM,TX1,TX2,TX3,TX4,TX5)"+CRLF
	cSQL:=cSQL+"			select"+CRLF
	cSQL:=cSQL+"				AFB_TAREFA as TAREFA,"+CRLF
	cSQL:=cSQL+"				AFB_VALOR as VALOR,"+CRLF
	cSQL:=cSQL+"				AF9_QUANT as QUANT,"+CRLF
	cSQL:=cSQL+"				0 as VALOR1,"+CRLF
	cSQL:=cSQL+"				0 as VALOR2,"+CRLF
	cSQL:=cSQL+"				0 as VALOR3,"+CRLF
	cSQL:=cSQL+"				0 as VALOR4,"+CRLF
	cSQL:=cSQL+"				0 as VALOR5,"+CRLF
	cSQL:=cSQL+"				AFB_MOEDA as MOEDA,"+CRLF
	cSQL:=cSQL+"				AF9_DTCONV as DTCONV,"+CRLF
	cSQL:=cSQL+"				AF9_CNVPRV as CNVPRV,"+CRLF
	cSQL:=cSQL+"				AF9_START as DTINICIO,"+CRLF
	cSQL:=cSQL+"				AF9_FINISH as DTFIM,"+CRLF
	cSQL:=cSQL+"				1.0 as TX1, AF9_TXMO2 as TX2, AF9_TXMO3 as TX3, AF9_TXMO4 as TX4, AF9_TXMO5 as TX5"+CRLF
	cSQL:=cSQL+"			from "+cAFB+" a, "+cAF9+" b"+CRLF
	cSQL:=cSQL+"			where AFB_FILIAL='"+cFil+"' and AFB_PROJET='"+cProjeto+"' and AFB_REVISA='"+cRevisao+"' and a.D_E_L_E_T_<>'*' and b.D_E_L_E_T_<>'*'"+CRLF
	cSQL:=cSQL+"			and AFB_FILIAL=AF9_FILIAL and AFB_PROJET=AF9_PROJET and AFB_REVISA=AF9_REVISA and AFB_TAREFA=AF9_TAREFA"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"			-- Atualiza CNVPRV e DTCONV"+CRLF
	cSQL:=cSQL+"			if ltrim(@DTCONV)='' or ltrim(@CNVPRV)=''"+CRLF
	cSQL:=cSQL+"				update "+cTmp1+" set DTCONV='"+cDtBase+"', CNVPRV='1' where ltrim(CNVPRV)=''"+CRLF
	cSQL:=cSQL+"			else"+CRLF
	cSQL:=cSQL+"				update "+cTmp1+" set DTCONV=@DTCONV, CNVPRV=@CNVPRV"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"			-- Atualiza data de convers„o para o critÈrio 1 (Data Base)"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set DTCONV='"+cDtBase+"' where CNVPRV='1'"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"			-- Atualiza data de convers„o para o critÈrio 5 (InÌcio previsto)"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set DTCONV=DTINICIO where CNVPRV='5'"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"			-- Atualiza data de convers„o para o critÈrio 6 (Fim previsto)"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set DTCONV=DTFIM where CNVPRV='6'"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"			-- Atualiza a taxa de convers„o das moedas para critÈrio diferente de 3 (mÈdia de 3 valores), 4 (mÈdia de 15 valores) e 7 (Informado pelo usu·rio)"+CRLF
	cSQL:=cSQL+"			declare cur cursor for select DTCONV from "+cTmp1+" where CNVPRV<>'3' and CNVPRV<>'4' and CNVPRV<>'7' group by DTCONV"+CRLF
	cSQL:=cSQL+"			open cur"+CRLF
	cSQL:=cSQL+"			fetch next from cur into @DTAUX"+CRLF
	cSQL:=cSQL+"			while @@FETCH_STATUS = 0"+CRLF
	cSQL:=cSQL+"				begin"+CRLF
	cSQL:=cSQL+"					select @TX2=0, @TX3=0, @TX4=0, @TX5=0"+CRLF
	cSQL:=cSQL+"					select @TX2=M2_MOEDA2, @TX3=M2_MOEDA3, @TX4=M2_MOEDA4, @TX5=M2_MOEDA5 from "+cSM2+" where D_E_L_E_T_<>'*' and M2_DATA=@DTAUX"+CRLF
	cSQL:=cSQL+"					update "+cTmp1+" set TX2=@TX2 where DTCONV=@DTAUX and CNVPRV<>'3' and CNVPRV<>'4' and CNVPRV<>'7' AND @TX2<>0"+CRLF
	cSQL:=cSQL+"					update "+cTmp1+" set TX3=@TX3 where DTCONV=@DTAUX and CNVPRV<>'3' and CNVPRV<>'4' and CNVPRV<>'7' AND @TX3<>0"+CRLF
	cSQL:=cSQL+"					update "+cTmp1+" set TX4=@TX4 where DTCONV=@DTAUX and CNVPRV<>'3' and CNVPRV<>'4' and CNVPRV<>'7' AND @TX4<>0"+CRLF
	cSQL:=cSQL+"					update "+cTmp1+" set TX5=@TX5 where DTCONV=@DTAUX and CNVPRV<>'3' and CNVPRV<>'4' and CNVPRV<>'7' AND @TX5<>0"+CRLF
	cSQL:=cSQL+"					select @fim_CUR=0"+CRLF
	cSQL:=cSQL+"					fetch next from cur into @DTAUX"+CRLF
	cSQL:=cSQL+"				end"+CRLF
	cSQL:=cSQL+"			close cur"+CRLF
	cSQL:=cSQL+"			deallocate cur"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"			-- Atualiza os valores para os critÈrios diferentes de 3 (mÈdia de 3 valores) e 4 (mÈdia de 15 valores)"+CRLF
	cSQL:=cSQL+"			declare cur66 cursor for select TAREFA from "+cTmp1+" where CNVPRV = '7' group by TAREFA"+CRLF
	cSQL:=cSQL+"			open cur66"+CRLF
	cSQL:=cSQL+"			fetch next from cur66 into @TASK"+CRLF
	cSQL:=cSQL+"			while @@FETCH_STATUS = 0"+CRLF
	cSQL:=cSQL+"				begin"+CRLF
	cSQL:=cSQL+"					select @TX2=0, @TX3=0, @TX4=0, @TX5=0"+CRLF
	cSQL:=cSQL+"					select @TX2=AF9_TXMO2, @TX3=AF9_TXMO3, @TX4=AF9_TXMO4, @TX5=AF9_TXMO5 from "+cAF9+" where D_E_L_E_T_<>'*' and AF9_PROJET='"+cProjeto+"' and AF9_REVISA='"+cRevisao+"' and AF9_TAREFA=@TASK"+CRLF
	cSQL:=cSQL+"						update "+cTmp1+" set TX2=@TX2 where TAREFA=@TASK AND @TX2<>0"+CRLF
	cSQL:=cSQL+"						update "+cTmp1+" set TX3=@TX3 where TAREFA=@TASK AND @TX3<>0"+CRLF
	cSQL:=cSQL+"						update "+cTmp1+" set TX4=@TX4 where TAREFA=@TASK AND @TX4<>0"+CRLF
	cSQL:=cSQL+"						update "+cTmp1+" set TX5=@TX5 where TAREFA=@TASK AND @TX5<>0"+CRLF
	cSQL:=cSQL+"					select @fim_CUR=0"+CRLF
	cSQL:=cSQL+"					fetch next from cur66 into @TASK"+CRLF
	cSQL:=cSQL+"				end"+CRLF
	cSQL:=cSQL+"			close cur66"+CRLF
	cSQL:=cSQL+"			deallocate cur66"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR1=VALOR where MOEDA=1 and CNVPRV in ('1','2','5','6','7')"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR2=VALOR/TX2 where MOEDA=1 and CNVPRV in ('1','2','5','6','7') and TX2 <> 0"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR3=VALOR/TX3 where MOEDA=1 and CNVPRV in ('1','2','5','6','7') and TX3 <> 0"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR4=VALOR/TX4 where MOEDA=1 and CNVPRV in ('1','2','5','6','7') and TX4 <> 0"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR5=VALOR/TX5 where MOEDA=1 and CNVPRV in ('1','2','5','6','7') and TX5 <> 0"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR1=VALOR*TX2 where MOEDA=2 and CNVPRV in ('1','2','5','6','7') and TX2 <> 0"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR2=VALOR where MOEDA=2 and CNVPRV in ('1','2','5','6','7')"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR3=VALOR*TX2/TX3 where MOEDA=2 and CNVPRV in ('1','2','5','6','7') and TX3 <> 0"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR4=VALOR*TX2/TX4 where MOEDA=2 and CNVPRV in ('1','2','5','6','7') and TX4 <> 0"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR5=VALOR*TX2/TX5 where MOEDA=2 and CNVPRV in ('1','2','5','6','7') and TX5 <> 0"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR1=VALOR*TX3 where MOEDA=3 and CNVPRV in ('1','2','5','6','7') and TX3 <> 0"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR2=VALOR*TX3/TX2 where MOEDA=3 and CNVPRV in ('1','2','5','6','7') and TX2 <> 0"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR3=VALOR  where MOEDA=3 and CNVPRV in ('1','2','5','6','7')"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR4=VALOR*TX3/TX4 where MOEDA=3 and CNVPRV in ('1','2','5','6','7') and TX4 <> 0"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR5=VALOR*TX3/TX5 where MOEDA=3 and CNVPRV in ('1','2','5','6','7') and TX5 <> 0"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR1=VALOR*TX4 where MOEDA=4 and CNVPRV in ('1','2','5','6','7') and TX4 <> 0"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR2=VALOR*TX4/TX2 where MOEDA=4 and CNVPRV in ('1','2','5','6','7') and TX2 <> 0"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR3=VALOR*TX4/TX3 where MOEDA=4 and CNVPRV in ('1','2','5','6','7') and TX3 <> 0"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR4=VALOR where MOEDA=4 and CNVPRV in ('1','2','5','6','7')"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR5=VALOR*TX4/TX5 where MOEDA=4 and CNVPRV in ('1','2','5','6','7') and TX5 <> 0"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR1=VALOR*TX5 where MOEDA=5 and CNVPRV in ('1','2','5','6','7') and TX5 <> 0"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR2=VALOR*TX5/TX2 where MOEDA=5 and CNVPRV in ('1','2','5','6','7') and TX2 <> 0"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR3=VALOR*TX5/TX3 where MOEDA=5 and CNVPRV in ('1','2','5','6','7') and TX3 <> 0"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR4=VALOR*TX5/TX4 where MOEDA=5 and CNVPRV in ('1','2','5','6','7') and TX4 <> 0"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR5=VALOR where MOEDA=5 and CNVPRV in ('1','2','5','6','7')"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"			-- Tipo de convers„o 3 (mÈdia de 3 valores)"+CRLF
	cSQL:=cSQL+"			select @I=0"+CRLF
	cSQL:=cSQL+"			while @I<3"+CRLF
	cSQL:=cSQL+"				begin"+CRLF
	cSQL:=cSQL+"					-- Atualiza com o valor na data @I"+CRLF
	cSQL:=cSQL+"					declare cur_avg3 cursor for"+CRLF
	cSQL:=cSQL+"						select MOEDA, DTINICIO, DTFIM"+CRLF
	cSQL:=cSQL+"						from "+cTmp1+" where CNVPRV='3' group by MOEDA, DTINICIO, DTFIM"+CRLF
	cSQL:=cSQL+"					open cur_avg3"+CRLF
	cSQL:=cSQL+"					fetch next from cur_avg3 into @MOEDA, @DT1, @DT2"+CRLF
	cSQL:=cSQL+"					while @@FETCH_STATUS = 0"+CRLF
	cSQL:=cSQL+"						begin"+CRLF
	If !lAltProc
		cSQL:=cSQL+"							select @J=datediff(day, @DT1, @DT2)"+CRLF
	Else
		cSQL:=cSQL+"							select @J=PMS_DATEDIFF(day, @DT1, @DT2)"+CRLF
	EndIf
	cSQL:=cSQL+"							select @J=convert(int,(@J*@I)/3)"+CRLF
	If !lAltProc
		cSQL:=cSQL+"							select @DT=dateadd(day, @J, @DT1)"+CRLF
	Else
		cSQL:=cSQL+"							select @DT=PMS_DATEADD(day, @J, @DT1)"+CRLF
	EndIf
	cSQL:=cSQL+"							select @DTAUX=convert(char(08), @DT, 112)"+CRLF
	cSQL:=cSQL+"							select @TX2=0, @TX3=0, @TX4=0, @TX5=0"+CRLF
	cSQL:=cSQL+"							select @TX2=M2_MOEDA2, @TX3=M2_MOEDA3, @TX4=M2_MOEDA4, @TX5=M2_MOEDA5 from "+cSM2+" where D_E_L_E_T_<>'*' and M2_DATA=@DTAUX"+CRLF
	cSQL:=cSQL+"							if @MOEDA=1"+CRLF
	cSQL:=cSQL+"							BEGIN"+CRLF
	cSQL:=cSQL+"								update "+cTmp1+" set VALOR1=VALOR1+VALOR	where MOEDA=1 and CNVPRV='3' and DTINICIO=@DT1 and DTFIM=@DT2"+CRLF
	cSQL:=cSQL+"								update "+cTmp1+" set VALOR2=VALOR2+(VALOR/@TX2)	where MOEDA=1 and CNVPRV='3' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX2 <> 0"+CRLF
	cSQL:=cSQL+"								update "+cTmp1+" set VALOR3=VALOR3+(VALOR/@TX3)	where MOEDA=1 and CNVPRV='3' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX3 <> 0"+CRLF
	cSQL:=cSQL+"								update "+cTmp1+" set VALOR4=VALOR4+(VALOR/@TX4)	where MOEDA=1 and CNVPRV='3' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX4 <> 0"+CRLF
	cSQL:=cSQL+"								update "+cTmp1+" set VALOR5=VALOR5+(VALOR/@TX5)	where MOEDA=1 and CNVPRV='3' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX5 <> 0"+CRLF
	cSQL:=cSQL+"							END"+CRLF
	cSQL:=cSQL+"							if @MOEDA=2"+CRLF
	cSQL:=cSQL+"							BEGIN"+CRLF
	cSQL:=cSQL+"								update "+cTmp1+" set VALOR1=VALOR1+(VALOR/@TX2) where MOEDA=2 and CNVPRV='3' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX2 <> 0"+CRLF
	cSQL:=cSQL+"						   		update "+cTmp1+" set VALOR2=VALOR2+VALOR where MOEDA=2 and CNVPRV='3' and DTINICIO=@DT1 and DTFIM=@DT2"+CRLF
	cSQL:=cSQL+"						   		update "+cTmp1+" set VALOR3=VALOR3+(VALOR*@TX2/@TX3) where MOEDA=2 and CNVPRV='3' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX3 <> 0"+CRLF
	cSQL:=cSQL+"								update "+cTmp1+" set VALOR4=VALOR4+(VALOR*@TX2/@TX4) where MOEDA=2 and CNVPRV='3' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX4 <> 0"+CRLF
	cSQL:=cSQL+"								update "+cTmp1+" set VALOR5=VALOR5+(VALOR*@TX2/@TX5) where MOEDA=2 and CNVPRV='3' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX5 <> 0"+CRLF
	cSQL:=cSQL+"							END"+CRLF
	cSQL:=cSQL+"							if @MOEDA=3"+CRLF
	cSQL:=cSQL+"							BEGIN"+CRLF
	cSQL:=cSQL+"								update "+cTmp1+" set VALOR1=VALOR1+(VALOR/@TX3) where MOEDA=3 and CNVPRV='3' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX3 <> 0"+CRLF
	cSQL:=cSQL+"						   		update "+cTmp1+" set VALOR2=VALOR2+(VALOR*@TX3/@TX2) where MOEDA=3 and CNVPRV='3' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX2 <> 0"+CRLF
	cSQL:=cSQL+"						   		update "+cTmp1+" set VALOR3=VALOR3+VALOR where MOEDA=3 and CNVPRV='3' and DTINICIO=@DT1 and DTFIM=@DT2"+CRLF
	cSQL:=cSQL+"								update "+cTmp1+" set VALOR4=VALOR4+(VALOR*@TX3/@TX4) where MOEDA=3 and CNVPRV='3' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX4 <> 0"+CRLF
	cSQL:=cSQL+"								update "+cTmp1+" set VALOR5=VALOR5+(VALOR*@TX3/@TX5) where MOEDA=3 and CNVPRV='3' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX5 <> 0"+CRLF
	cSQL:=cSQL+"							END"+CRLF
	cSQL:=cSQL+"							if @MOEDA=4"+CRLF
	cSQL:=cSQL+"							BEGIN"+CRLF
	cSQL:=cSQL+"						   		update "+cTmp1+" set VALOR1=VALOR1+(VALOR/@TX4) where MOEDA=4 and CNVPRV='3' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX4 <> 0"+CRLF
	cSQL:=cSQL+"								update "+cTmp1+" set VALOR2=VALOR2+(VALOR*@TX4/@TX2) where MOEDA=4 and CNVPRV='3' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX2 <> 0"+CRLF
	cSQL:=cSQL+"								update "+cTmp1+" set VALOR3=VALOR3+(VALOR*@TX4/@TX3) where MOEDA=4 and CNVPRV='3' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX3 <> 0"+CRLF
	cSQL:=cSQL+"								update "+cTmp1+" set VALOR4=VALOR4+VALOR where MOEDA=4 and CNVPRV='3' and DTINICIO=@DT1 and DTFIM=@DT2"+CRLF
	cSQL:=cSQL+"								update "+cTmp1+" set VALOR5=VALOR5+(VALOR*@TX4/@TX5) where MOEDA=4 and CNVPRV='3' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX5 <> 0"+CRLF
	cSQL:=cSQL+"							END"+CRLF
	cSQL:=cSQL+"							if @MOEDA=5"+CRLF
	cSQL:=cSQL+"							BEGIN"+CRLF
	cSQL:=cSQL+"						   		update "+cTmp1+" set VALOR1=VALOR1+(VALOR/@TX5) where MOEDA=5 and CNVPRV='3' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX5 <> 0"+CRLF
	cSQL:=cSQL+"						   		update "+cTmp1+" set VALOR2=VALOR2+(VALOR*@TX5/@TX2) where MOEDA=5 and CNVPRV='3' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX2 <> 0"+CRLF
	cSQL:=cSQL+"						   		update "+cTmp1+" set VALOR3=VALOR3+(VALOR*@TX5/@TX3) where MOEDA=5 and CNVPRV='3' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX3 <> 0"+CRLF
	cSQL:=cSQL+"								update "+cTmp1+" set VALOR4=VALOR4+(VALOR*@TX5/@TX4) where MOEDA=5 and CNVPRV='3' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX4 <> 0"+CRLF
	cSQL:=cSQL+"								update "+cTmp1+" set VALOR5=VALOR5+VALOR where MOEDA=5 and CNVPRV='3' and DTINICIO=@DT1 and DTFIM=@DT2"+CRLF
	cSQL:=cSQL+"							END"+CRLF
	cSQL:=cSQL+"							select @fim_CUR=0"+CRLF
	cSQL:=cSQL+"							fetch next from cur_avg3 into @MOEDA, @DT1, @DT2"+CRLF
	cSQL:=cSQL+"						end"+CRLF
	cSQL:=cSQL+"					close cur_avg3"+CRLF
	cSQL:=cSQL+"					deallocate cur_avg3"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"					select @I=@I+1"+CRLF
	cSQL:=cSQL+"				end"+CRLF
	cSQL:=cSQL+"			-- Divide por 3 para tirar a mÈdia"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR1=VALOR1/3, VALOR2=VALOR2/3, VALOR3=VALOR3/3, VALOR4=VALOR4/3, VALOR5=VALOR5/3"+CRLF
	cSQL:=cSQL+"			where CNVPRV='3'"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"			-- Tipo de convers„o 4 (mÈdia de 15 valores)"+CRLF
	cSQL:=cSQL+"			select @I=0"+CRLF
	cSQL:=cSQL+"			while @I<15"+CRLF
	cSQL:=cSQL+"				begin"+CRLF
	cSQL:=cSQL+"					-- Atualiza com o valor na data @I"+CRLF
	cSQL:=cSQL+"					declare cur_avg15 cursor for"+CRLF
	cSQL:=cSQL+"						select MOEDA, DTINICIO, DTFIM"+CRLF
	cSQL:=cSQL+"						from "+cTmp1+" where CNVPRV='4' group by MOEDA, DTINICIO, DTFIM"+CRLF
	cSQL:=cSQL+"					open cur_avg15"+CRLF
	cSQL:=cSQL+"					fetch next from cur_avg15 into @MOEDA, @DT1, @DT2"+CRLF
	cSQL:=cSQL+"					while @@FETCH_STATUS = 0"+CRLF
	cSQL:=cSQL+"						begin"+CRLF
	If !lAltProc
		cSQL:=cSQL+"							select @J=datediff(day, @DT1, @DT2)"+CRLF
	Else
		cSQL:=cSQL+"							select @J=PMS_DATEDIFF(day, @DT1, @DT2)"+CRLF
	EndIf
	cSQL:=cSQL+"							select @J=convert(int,(@J*@I)/15)"+CRLF
	If !lAltProc
		cSQL:=cSQL+"							select @DT=dateadd(day, @J, @DT1)"+CRLF
	Else
		cSQL:=cSQL+"							select @DT=PMS_DATEADD(day, @J, @DT1)"+CRLF
	EndIf
	cSQL:=cSQL+"							select @DTAUX=convert(char(08), @DT, 112)"+CRLF
	cSQL:=cSQL+"							select @TX2=0, @TX3=0, @TX4=0, @TX5=0"+CRLF
	cSQL:=cSQL+"							select @TX2=M2_MOEDA2, @TX3=M2_MOEDA3, @TX4=M2_MOEDA4, @TX5=M2_MOEDA5 from "+cSM2+" where D_E_L_E_T_<>'*' and M2_DATA=@DTAUX"+CRLF
	cSQL:=cSQL+"								if @MOEDA=1"+CRLF
	cSQL:=cSQL+"								BEGIN"+CRLF
	cSQL:=cSQL+"									update "+cTmp1+" set VALOR1=VALOR1+VALOR where MOEDA=1 and CNVPRV='4' and DTINICIO=@DT1 and DTFIM=@DT2"+CRLF
	cSQL:=cSQL+"									update "+cTmp1+" set VALOR2=VALOR2+(VALOR/@TX2) where MOEDA=1 and CNVPRV='4' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX2 <> 0"+CRLF
	cSQL:=cSQL+"									update "+cTmp1+" set VALOR3=VALOR3+(VALOR/@TX3) where MOEDA=1 and CNVPRV='4' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX3 <> 0"+CRLF
	cSQL:=cSQL+"									update "+cTmp1+" set VALOR4=VALOR4+(VALOR/@TX4) where MOEDA=1 and CNVPRV='4' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX4 <> 0"+CRLF
	cSQL:=cSQL+"									update "+cTmp1+" set VALOR5=VALOR5+(VALOR/@TX5) where MOEDA=1 and CNVPRV='4' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX5 <> 0"+CRLF
	cSQL:=cSQL+"								END"+CRLF
	cSQL:=cSQL+"								if @MOEDA=2"+CRLF
	cSQL:=cSQL+"								BEGIN"+CRLF
	cSQL:=cSQL+"									update "+cTmp1+" set VALOR1=VALOR1+(VALOR/@TX2) where MOEDA=2 and CNVPRV='4' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX2 <> 0"+CRLF
	cSQL:=cSQL+"									update "+cTmp1+" set VALOR2=VALOR2+VALOR where MOEDA=2 and CNVPRV='4' and DTINICIO=@DT1 and DTFIM=@DT2"+CRLF
	cSQL:=cSQL+"									update "+cTmp1+" set VALOR3=VALOR3+(VALOR*@TX2/@TX3) where MOEDA=2 and CNVPRV='4' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX3 <> 0"+CRLF
	cSQL:=cSQL+"									update "+cTmp1+" set VALOR4=VALOR4+(VALOR*@TX2/@TX4) where MOEDA=2 and CNVPRV='4' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX4 <> 0"+CRLF
	cSQL:=cSQL+"									update "+cTmp1+" set VALOR5=VALOR5+(VALOR*@TX2/@TX5) where MOEDA=2 and CNVPRV='4' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX5 <> 0"+CRLF
	cSQL:=cSQL+"								END"+CRLF
	cSQL:=cSQL+"								if @MOEDA=3"+CRLF
	cSQL:=cSQL+"								BEGIN"+CRLF
	cSQL:=cSQL+"									update "+cTmp1+" set VALOR1=VALOR1+(VALOR/@TX3) where MOEDA=3 and CNVPRV='4' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX3 <> 0"+CRLF
	cSQL:=cSQL+"									update "+cTmp1+" set VALOR2=VALOR2+(VALOR*@TX3/@TX2) where MOEDA=3 and CNVPRV='4' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX2 <> 0"+CRLF
	cSQL:=cSQL+"									update "+cTmp1+" set VALOR3=VALOR3+VALOR where MOEDA=3 and CNVPRV='4' and DTINICIO=@DT1 and DTFIM=@DT2"+CRLF
	cSQL:=cSQL+"									update "+cTmp1+" set VALOR4=VALOR4+(VALOR*@TX3/@TX4) where MOEDA=3 and CNVPRV='4' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX4 <> 0"+CRLF
	cSQL:=cSQL+"									update "+cTmp1+" set VALOR5=VALOR5+(VALOR*@TX3/@TX5) where MOEDA=3 and CNVPRV='4' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX5 <> 0"+CRLF
	cSQL:=cSQL+"								END"+CRLF
	cSQL:=cSQL+"								if @MOEDA=4"+CRLF
	cSQL:=cSQL+"								BEGIN"+CRLF
	cSQL:=cSQL+"									update "+cTmp1+" set VALOR1=VALOR1+(VALOR/@TX4) where MOEDA=4 and CNVPRV='4' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX4 <> 0"+CRLF
	cSQL:=cSQL+"									update "+cTmp1+" set VALOR2=VALOR2+(VALOR*@TX4/@TX2) where MOEDA=4 and CNVPRV='4' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX2 <> 0"+CRLF
	cSQL:=cSQL+"									update "+cTmp1+" set VALOR3=VALOR3+(VALOR*@TX4/@TX3) where MOEDA=4 and CNVPRV='4' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX3 <> 0"+CRLF
	cSQL:=cSQL+"									update "+cTmp1+" set VALOR4=VALOR4+VALOR where MOEDA=4 and CNVPRV='4' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX4 <> 0"+CRLF
	cSQL:=cSQL+"									update "+cTmp1+" set VALOR5=VALOR5+(VALOR*@TX4/@TX5) where MOEDA=4 and CNVPRV='4' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX5 <> 0"+CRLF
	cSQL:=cSQL+"								END"+CRLF
	cSQL:=cSQL+"								if @MOEDA=5"+CRLF
	cSQL:=cSQL+"								BEGIN"+CRLF
	cSQL:=cSQL+"									update "+cTmp1+" set VALOR1=VALOR1+(VALOR/@TX5) where MOEDA=5 and CNVPRV='4' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX5 <> 0"+CRLF
	cSQL:=cSQL+"									update "+cTmp1+" set VALOR2=VALOR2+(VALOR*@TX5/@TX2) where MOEDA=5 and CNVPRV='4' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX2 <> 0"+CRLF
	cSQL:=cSQL+"									update "+cTmp1+" set VALOR3=VALOR3+(VALOR*@TX5/@TX3) where MOEDA=5 and CNVPRV='4' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX3 <> 0"+CRLF
	cSQL:=cSQL+"									update "+cTmp1+" set VALOR4=VALOR4+(VALOR*@TX5/@TX4) where MOEDA=5 and CNVPRV='4' and DTINICIO=@DT1 and DTFIM=@DT2 AND @TX4 <> 0"+CRLF
	cSQL:=cSQL+"									update "+cTmp1+" set VALOR5=VALOR5+VALOR where MOEDA=5 and CNVPRV='4' and DTINICIO=@DT1 and DTFIM=@DT2"+CRLF
	cSQL:=cSQL+"								END"+CRLF
	cSQL:=cSQL+"							select @fim_CUR=0"+CRLF
	cSQL:=cSQL+"							fetch next from cur_avg15 into @MOEDA, @DT1, @DT2"+CRLF
	cSQL:=cSQL+"						end"+CRLF
	cSQL:=cSQL+"					close cur_avg15"+CRLF
	cSQL:=cSQL+"					deallocate cur_avg15"+CRLF
	cSQL:=cSQL+"					"+CRLF
	cSQL:=cSQL+"					select @I=@I+1"+CRLF
	cSQL:=cSQL+"				end"+CRLF
	cSQL:=cSQL+"			-- Divide por 15 para tirar a mÈdia"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR1=VALOR1/15, VALOR2=VALOR2/15, VALOR3=VALOR3/15, VALOR4=VALOR4/15, VALOR5=VALOR5/15"+CRLF
	cSQL:=cSQL+"			where CNVPRV='4'"+CRLF
	cSQL:=cSQL+"			"+CRLF
	cSQL:=cSQL+"			-- Arredonta/Trunca"+CRLF
	cSQL:=cSQL+"			if '"+cPmsCust+"'='1'	-- Custo total"+CRLF
	cSQL:=cSQL+"				if @TRUNC='1' or @TRUNC='3' -- Trunca"+CRLF
	cSQL:=cSQL+"					update "+cTmp1+" set"+CRLF
	cSQL:=cSQL+"						VALOR1=round(VALOR1,"+ltrim(str(aDec[1]))+",1),"+CRLF
	cSQL:=cSQL+"						VALOR2=round(VALOR2,"+ltrim(str(aDec[2]))+",1),"+CRLF
	cSQL:=cSQL+"						VALOR3=round(VALOR3,"+ltrim(str(aDec[3]))+",1),"+CRLF
	cSQL:=cSQL+"						VALOR4=round(VALOR4,"+ltrim(str(aDec[4]))+",1),"+CRLF
	cSQL:=cSQL+"						VALOR5=round(VALOR5,"+ltrim(str(aDec[5]))+",1)"+CRLF
	cSQL:=cSQL+"				else -- Arredonda"+CRLF
	cSQL:=cSQL+"					update "+cTmp1+" set"+CRLF
	cSQL:=cSQL+"						VALOR1=round(VALOR1,"+ltrim(str(aDec[1]))+"),"+CRLF
	cSQL:=cSQL+"						VALOR2=round(VALOR2,"+ltrim(str(aDec[2]))+"),"+CRLF
	cSQL:=cSQL+"						VALOR3=round(VALOR3,"+ltrim(str(aDec[3]))+"),"+CRLF
	cSQL:=cSQL+"						VALOR4=round(VALOR4,"+ltrim(str(aDec[4]))+"),"+CRLF
	cSQL:=cSQL+"						VALOR5=round(VALOR5,"+ltrim(str(aDec[5]))+")"+CRLF
	cSQL:=cSQL+"			else	-- Custo unit·rio"+CRLF
	cSQL:=cSQL+"				if @TRUNC='1' -- Trunca unit·rio do item"+CRLF
	cSQL:=cSQL+"					update "+cTmp1+" set"+CRLF
	cSQL:=cSQL+"						VALOR1=round(VALOR1*QUANT,"+ltrim(str(aDec[1]))+",1),"+CRLF
	cSQL:=cSQL+"						VALOR2=round(VALOR2*QUANT,"+ltrim(str(aDec[2]))+",1),"+CRLF
	cSQL:=cSQL+"						VALOR3=round(VALOR3*QUANT,"+ltrim(str(aDec[3]))+",1),"+CRLF
	cSQL:=cSQL+"						VALOR4=round(VALOR4*QUANT,"+ltrim(str(aDec[4]))+",1),"+CRLF
	cSQL:=cSQL+"						VALOR5=round(VALOR5*QUANT,"+ltrim(str(aDec[5]))+",1)"+CRLF
	cSQL:=cSQL+"				else if @TRUNC='2'	-- Arredonda unit·rio do item"+CRLF
	cSQL:=cSQL+"					update "+cTmp1+" set"+CRLF
	cSQL:=cSQL+"						VALOR1=round(VALOR1*QUANT,"+ltrim(str(aDec[1]))+"),"+CRLF
	cSQL:=cSQL+"						VALOR2=round(VALOR2*QUANT,"+ltrim(str(aDec[2]))+"),"+CRLF
	cSQL:=cSQL+"						VALOR3=round(VALOR3*QUANT,"+ltrim(str(aDec[3]))+"),"+CRLF
	cSQL:=cSQL+"						VALOR4=round(VALOR4*QUANT,"+ltrim(str(aDec[4]))+"),"+CRLF
	cSQL:=cSQL+"						VALOR5=round(VALOR5*QUANT,"+ltrim(str(aDec[5]))+")"+CRLF
	cSQL:=cSQL+"				else if @TRUNC='3'	-- Trunca unit·rio da tarefa"+CRLF
	cSQL:=cSQL+"					update "+cTmp1+" set"+CRLF
	cSQL:=cSQL+"						VALOR1=round(round(VALOR1,"+ltrim(str(aDec[1]))+",1)*QUANT,"+ltrim(str(aDec[1]))+",1),"+CRLF
	cSQL:=cSQL+"						VALOR2=round(round(VALOR2,"+ltrim(str(aDec[2]))+",1)*QUANT,"+ltrim(str(aDec[2]))+",1),"+CRLF
	cSQL:=cSQL+"						VALOR3=round(round(VALOR3,"+ltrim(str(aDec[3]))+",1)*QUANT,"+ltrim(str(aDec[3]))+",1),"+CRLF
	cSQL:=cSQL+"						VALOR4=round(round(VALOR4,"+ltrim(str(aDec[4]))+",1)*QUANT,"+ltrim(str(aDec[4]))+",1),"+CRLF
	cSQL:=cSQL+"						VALOR5=round(round(VALOR5,"+ltrim(str(aDec[5]))+",1)*QUANT,"+ltrim(str(aDec[5]))+",1)"+CRLF
	cSQL:=cSQL+"				else	-- Arredonda unit·rio da tarefa"+CRLF
	cSQL:=cSQL+"					update "+cTmp1+" set"+CRLF
	cSQL:=cSQL+"						VALOR1=round(round(VALOR1,"+ltrim(str(aDec[1]))+")*QUANT,"+ltrim(str(aDec[1]))+"),"+CRLF
	cSQL:=cSQL+"						VALOR2=round(round(VALOR2,"+ltrim(str(aDec[2]))+")*QUANT,"+ltrim(str(aDec[2]))+"),"+CRLF
	cSQL:=cSQL+"						VALOR3=round(round(VALOR3,"+ltrim(str(aDec[3]))+")*QUANT,"+ltrim(str(aDec[3]))+"),"+CRLF
	cSQL:=cSQL+"						VALOR4=round(round(VALOR4,"+ltrim(str(aDec[4]))+")*QUANT,"+ltrim(str(aDec[4]))+"),"+CRLF
	cSQL:=cSQL+"						VALOR5=round(round(VALOR5,"+ltrim(str(aDec[5]))+")*QUANT,"+ltrim(str(aDec[5]))+")"+CRLF
	cSQL:=cSQL+"			"+CRLF
	cSQL:=cSQL+"			-- Pega valor de BDI"+CRLF
	cSQL:=cSQL+"			insert into "+cTmp2+" (TAREFA2,EDTPAI,BDI,FLAG,UTIBDI)"+CRLF
	cSQL:=cSQL+"			select"+CRLF
	cSQL:=cSQL+"				AF9_TAREFA as TAREFA2,"+CRLF
	cSQL:=cSQL+"				AF9_EDTPAI as EDTPAI,"+CRLF
	cSQL:=cSQL+"				AF9_BDI as BDI,"+CRLF
	cSQL:=cSQL+"				0 as FLAG,"+CRLF
	cSQL:=cSQL+"				AF9_UTIBDI as UTIBDI"+CRLF
	cSQL:=cSQL+"			from "+cAF9+""+CRLF
	cSQL:=cSQL+"			where AF9_FILIAL='"+cFil+"' and AF9_PROJET='"+cProjeto+"' and AF9_REVISA='"+cRevisao+"' and D_E_L_E_T_<>'*'"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"			update "+cTmp2+" set FLAG=1 where BDI<>0 or UTIBDI='2'  -- atualiza flag"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"			-- Se n„o tiver BDI cadastrado, pega das EDT's pais, se ainda n„o tiver, pega BDI padr„o do projeto"+CRLF
	cSQL:=cSQL+"			declare cur_bdi cursor for select EDTPAI from "+cTmp2+" where FLAG=0 group by EDTPAI"+CRLF
	cSQL:=cSQL+"			open cur_bdi"+CRLF
	cSQL:=cSQL+"			fetch next from cur_bdi into @EDT"+CRLF
	cSQL:=cSQL+"			select @X=0"+CRLF
	cSQL:=cSQL+"			while @@FETCH_STATUS = 0"+CRLF
	cSQL:=cSQL+"				begin"+CRLF
	cSQL:=cSQL+"					select @BDI=AFC_BDITAR, @EDTPAI=AFC_EDTPAI from "+cAFC+" where AFC_EDT=@EDT and AFC_FILIAL='"+cFil+"' and AFC_PROJET='"+cProjeto+"' and AFC_REVISA='"+cRevisao+"' and D_E_L_E_T_<>'*'"+CRLF
	cSQL:=cSQL+"					select @I=count(*) from "+cTmp2+" where FLAG=0 and EDTPAI=@EDT and ltrim(EDTPAI)<>''"+CRLF
	cSQL:=cSQL+"					while @I>0 and @X<1000"+CRLF
	cSQL:=cSQL+"						begin"+CRLF
	cSQL:=cSQL+"							update "+cTmp2+" set BDI=@BDI, EDTPAI=@EDTPAI where FLAG=0 and EDTPAI=@EDT"+CRLF
	cSQL:=cSQL+"							update "+cTmp2+" set FLAG=1 where FLAG=0 and BDI<>0"+CRLF
	cSQL:=cSQL+"							update "+cTmp2+" set BDI=@BDIPAD, FLAG=1 where FLAG=0 and ltrim(EDTPAI)=''"+CRLF
	cSQL:=cSQL+"							select @EDT=@EDTPAI"+CRLF
	cSQL:=cSQL+"							select @BDI=AFC_BDITAR, @EDTPAI=AFC_EDTPAI from "+cAFC+" where AFC_EDT=@EDT and AFC_FILIAL='"+cFil+"' and AFC_PROJET='"+cProjeto+"' and AFC_REVISA='"+cRevisao+"' and D_E_L_E_T_<>'*'"+CRLF
	cSQL:=cSQL+"							select @I=count(*) from "+cTmp2+" where FLAG=0 and EDTPAI=@EDT and ltrim(EDTPAI)<>''"+CRLF
	cSQL:=cSQL+"				        	select @X=@X+1"+CRLF
	cSQL:=cSQL+"						end"+CRLF
	cSQL:=cSQL+"					select @fim_CUR=0"+CRLF
	cSQL:=cSQL+"					fetch next from cur_bdi into @EDT"+CRLF
	cSQL:=cSQL+"				end"+CRLF
	cSQL:=cSQL+"			close cur_bdi"+CRLF
	cSQL:=cSQL+"			deallocate cur_bdi"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"			-- Atualiza o custo das tarefas"+CRLF
	cSQL:=cSQL+"			declare cur_tsk cursor for"+CRLF
	cSQL:=cSQL+"				select AF9_TAREFA from "+cAF9+""+CRLF
	cSQL:=cSQL+"				where AF9_FILIAL='"+cFil+"' and AF9_PROJET='"+cProjeto+"' and AF9_REVISA='"+cRevisao+"' and D_E_L_E_T_<>'*'"+CRLF
	cSQL:=cSQL+"				group by AF9_TAREFA"+CRLF
	cSQL:=cSQL+"			open cur_tsk"+CRLF
	cSQL:=cSQL+"			fetch next from cur_tsk into @TASK"+CRLF
	cSQL:=cSQL+"			while @@FETCH_STATUS = 0"+CRLF
	cSQL:=cSQL+"				begin"+CRLF
	cSQL:=cSQL+"					select @TX1=0, @TX2=0, @TX3=0, @TX4=0, @TX5=0, @BDI=0"+CRLF
	cSQL:=cSQL+"					select @TX1=sum(VALOR1), @TX2=sum(VALOR2), @TX3=sum(VALOR3), @TX4=sum(VALOR4), @TX5=sum(VALOR5) from "+cTmp1+" where TAREFA=@TASK group by TAREFA"+CRLF
	cSQL:=cSQL+"					select @BDI=BDI from "+cTmp2+" where TAREFA2=@TASK"+CRLF
	cSQL:=cSQL+"					select @TX1=isnull(@TX1,0), @TX2=isnull(@TX2,0), @TX3=isnull(@TX3,0), @TX4=isnull(@TX4,0), @TX5=isnull(@TX5,0), @BDI=isnull(@BDI,0)"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"					update "+cAF9+" set"+CRLF
	cSQL:=cSQL+"						AF9_CUSTO =@TX1,"+CRLF
	cSQL:=cSQL+"						AF9_CUSTO2=@TX2,"+CRLF
	cSQL:=cSQL+"						AF9_CUSTO3=@TX3,"+CRLF
	cSQL:=cSQL+"						AF9_CUSTO4=@TX4,"+CRLF
	cSQL:=cSQL+"						AF9_CUSTO5=@TX5"
	If !lTskCust0
		cSQL:=cSQL+","+CRLF
		cSQL:=cSQL+"					AF9_VALBDI=round((@TX1*@BDI/100)+0.0000001 ,"+ltrim(str(aDec[1]))+"),"+CRLF
		cSQL:=cSQL+"					AF9_TOTAL =round((@TX1*(1+(@BDI/100)))+0.0000001 ,"+ltrim(str(aDec[1]))+")"+CRLF
	Else
		cSQL:=cSQL+""+CRLF
	Endif
	cSQL:=cSQL+"					where AF9_FILIAL='"+cFil+"' and AF9_PROJET='"+cProjeto+"' and AF9_REVISA='"+cRevisao+"' and AF9_TAREFA=@TASK and D_E_L_E_T_<>'*'"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"					select @fim_CUR=0"+CRLF
	cSQL:=cSQL+"					fetch next from cur_tsk into @TASK"+CRLF
	cSQL:=cSQL+"				end"+CRLF
	cSQL:=cSQL+"			close cur_tsk"+CRLF
	cSQL:=cSQL+"			deallocate cur_tsk"+CRLF
	cSQL:=cSQL+"			"+CRLF
	cSQL:=cSQL+"		end"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"	if @IN_ATUAFC<>0"+CRLF
	cSQL:=cSQL+"		begin"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"			-- zera custo das EDT's"+CRLF
	cSQL:=cSQL+"			update "+cAFC+" set AFC_CUSTO=0, AFC_CUSTO2=0, AFC_CUSTO3=0, AFC_CUSTO4=0, AFC_CUSTO5=0, AFC_VALBDI=0, AFC_TOTAL=0"+CRLF
	cSQL:=cSQL+"			where AFC_FILIAL='"+cFil+"' and AFC_PROJET='"+cProjeto+"' and AFC_REVISA='"+cRevisao+"' and D_E_L_E_T_<>'*'"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"			declare cur_lvl cursor for"+CRLF
	cSQL:=cSQL+"				select AFC_NIVEL from "+cAFC+""+CRLF
	cSQL:=cSQL+"				where AFC_FILIAL='"+cFil+"' and AFC_PROJET='"+cProjeto+"' and AFC_REVISA='"+cRevisao+"' and D_E_L_E_T_<>'*'"+CRLF
	cSQL:=cSQL+"				group by AFC_NIVEL"+CRLF
	cSQL:=cSQL+"				order by AFC_NIVEL DESC"+CRLF
	cSQL:=cSQL+"			open cur_lvl"+CRLF
	cSQL:=cSQL+"			fetch next from cur_lvl into @NIVEL"+CRLF
	cSQL:=cSQL+"			while @@FETCH_STATUS = 0"+CRLF
	cSQL:=cSQL+"				begin"+CRLF
	cSQL:=cSQL+"					declare cur_elv cursor for"+CRLF
	cSQL:=cSQL+"						select AFC_EDT from "+cAFC+""+CRLF
	cSQL:=cSQL+"						where AFC_FILIAL='"+cFil+"' and AFC_PROJET='"+cProjeto+"' and AFC_REVISA='"+cRevisao+"' and AFC_NIVEL=@NIVEL and D_E_L_E_T_<>'*'"+CRLF
	cSQL:=cSQL+"						group by AFC_EDT"+CRLF
	cSQL:=cSQL+"					open cur_elv"+CRLF
	cSQL:=cSQL+"					fetch next from cur_elv into @EDT"+CRLF
	cSQL:=cSQL+"					while @@FETCH_STATUS = 0"+CRLF
	cSQL:=cSQL+"						begin"+CRLF
	cSQL:=cSQL+"							select @TX1=0, @TX2=0, @TX3=0, @TX4=0, @TX5=0, @VL1=0, @VL2=0, @VL3=0, @VL4=0, @VL5=0, @BDI=0, @BDIPAD=0"+CRLF
	cSQL:=cSQL+"							select @TX1=sum(AF9_CUSTO), @TX2=sum(AF9_CUSTO2), @TX3=sum(AF9_CUSTO3), @TX4=sum(AF9_CUSTO4), @TX5=sum(AF9_CUSTO5), @BDI=sum(AF9_VALBDI)"+CRLF
	cSQL:=cSQL+"								from "+cAF9+" where AF9_FILIAL='"+cFil+"' and AF9_PROJET='"+cProjeto+"' and AF9_REVISA='"+cRevisao+"' and AF9_EDTPAI=@EDT and D_E_L_E_T_<>'*'"+CRLF
	cSQL:=cSQL+"							select @VL1=sum(AFC_CUSTO), @VL2=sum(AFC_CUSTO2), @VL3=sum(AFC_CUSTO3), @VL4=sum(AFC_CUSTO4), @VL5=sum(AFC_CUSTO5), @BDIPAD=sum(AFC_VALBDI)"+CRLF
	cSQL:=cSQL+"								from "+cAFC+" where AFC_FILIAL='"+cFil+"' and AFC_PROJET='"+cProjeto+"' and AFC_REVISA='"+cRevisao+"' and AFC_EDTPAI=@EDT and D_E_L_E_T_<>'*'"+CRLF
	cSQL:=cSQL+"							select @TX1=isnull(@TX1,0), @TX2=isnull(@TX2,0), @TX3=isnull(@TX3,0), @TX4=isnull(@TX4,0), @TX5=isnull(@TX5,0), @BDI=isnull(@BDI,0)"+CRLF
	cSQL:=cSQL+"							select @VL1=isnull(@VL1,0), @VL2=isnull(@VL2,0), @VL3=isnull(@VL3,0), @VL4=isnull(@VL4,0), @VL5=isnull(@VL5,0), @BDIPAD=isnull(@BDIPAD,0)"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"							update "+cAFC+" set"+CRLF
	cSQL:=cSQL+"								AFC_CUSTO =@TX1+@VL1,"+CRLF
	cSQL:=cSQL+"								AFC_CUSTO2=@TX2+@VL2,"+CRLF
	cSQL:=cSQL+"								AFC_CUSTO3=@TX3+@VL3,"+CRLF
	cSQL:=cSQL+"								AFC_CUSTO4=@TX4+@VL4,"+CRLF
	cSQL:=cSQL+"								AFC_CUSTO5=@TX5+@VL5,"+CRLF
	cSQL:=cSQL+"								AFC_VALBDI=@BDI+@BDIPAD,"+CRLF
	cSQL:=cSQL+"								AFC_TOTAL =@TX1+@BDI+@VL1+@BDIPAD"+CRLF
	cSQL:=cSQL+"							where AFC_FILIAL='"+cFil+"' and AFC_PROJET='"+cProjeto+"' and AFC_REVISA='"+cRevisao+"' and AFC_EDT=@EDT and D_E_L_E_T_<>'*'"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"							select @fim_CUR=0"+CRLF
	cSQL:=cSQL+"							fetch next from cur_elv into @EDT"+CRLF
	cSQL:=cSQL+"						end"+CRLF
	cSQL:=cSQL+"					close cur_elv"+CRLF
	cSQL:=cSQL+"					deallocate cur_elv"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"					select @fim_CUR=0"+CRLF
	cSQL:=cSQL+"					fetch next from cur_lvl into @NIVEL"+CRLF
	cSQL:=cSQL+"				end"+CRLF
	cSQL:=cSQL+"			close cur_lvl"+CRLF
	cSQL:=cSQL+"			deallocate cur_lvl"+CRLF
	cSQL:=cSQL+"		end"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"commit"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"select @OUT_RET=1"+CRLF

	cSQL:=MsParse(cSQL,Alltrim(TcGetDB()))

	if cSQL==""
		if !__lBlind
 			MsgAlert(STR0260+" "+cProc+": "+MsParseError())  //'Erro criando a Stored Procedure:'
		endif
		conout('Parser Error')
		conout(STR0260+" "+cProc+": "+MsParseError())
		lRet := .F.
	else
		cSQL:=PmsA200Fix(cSQL, Alltrim(TcGetDB()))

		cRet:=TcSqlExec(cSQL)
		if cRet <> 0
			if !__lBlind
	 			MsgAlert(STR0260+" "+cProc+": "+TCSqlError())  //'Erro criando a Stored Procedure:'
			endif
			conout('SQL Error')
			conout(STR0260+" "+cProc+": "+MsParseError())
			lRet := .F.
		endif
	endif

	if cRet=0
		aResult := TCSPExec( cProc, nAtuTarefa, nAtuEDT )
		if empty(aResult)
			if !__lBlind
				MsgAlert(STR0261+" "+cProc+": "+TCSqlError())  //'Erro ao executar a Stored Procedure'	
			endif
			conout('SQL Error')
			conout(STR0261+" "+cProc+": "+TcSQLError())
			lRet := .f.
		elseif aResult[1] != 1
			if !__lBlind
				MsgAlert(STR0262+": "+TCSqlError())   //'Erro atualizando custos
			endif
			conout('SQL Error')
			conout(STR0262+" "+cProc+": "+TcSQLError())
			lRet := .f.
		endif
	endif

	PMS200Tool(.T.,cDB)
	
	If TcSqlExec("	DROP TABLE "+cTmp2 ) <> 0
		if !__lBlind
			MsgAlert(STR0317+ cTmp2+ TCSqlError())   //'SQL Error - Erro ao deletar tabela: '                                                                                                                                                                                                                                                                                 
		endif
		conout(STR0317+ cTmp2+ TCSqlError()) //'SQL Error - Erro ao deletar tabela: ' 
		lRet := .f.
	EndIf
	If TcSqlExec("	DROP TABLE "+cTmp1 ) <> 0
		if !__lBlind
			MsgAlert(STR0317+ cTmp1+ TCSqlError())   //'SQL Error - Erro ao deletar tabela: '                                                                                                                                                                                                                                                                           
		endif
		conout(STR0317+ cTmp1+ TCSqlError()) //'SQL Error - Erro ao deletar tabela: '    
		lRet := .f.
	EndIf

	If TcSqlExec('DROP PROCEDURE '+cProc)<>0
		if !__lBlind
			MsgAlert(STR0263+" "+cProc+": "+TCSqlError())   //'Erro excluindo procedure'
		endif
		conout(STR0263+" "+cProc+": "+TCSqlError())
		lRet := .f.
	endif

endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PMS200AuxEDT
Funcao que atualiza os custos totais das Tarefas/EDT.

@param lSimula,logico, verdadeiro se trata de um projeto de simulaÁ„o

@author Fabio Rogerio Pereira
@since 09-05-2002
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PMS200AuxEDT(lSimula)
Local aAreaAF9	:= {}
Local aCustoAF9 	:= {}
Local aTX2M		:= {0,0,0,0,0}
Local aStruct		:= {}
Local aDecCst		:= {0,0,0,0,0}


Local cProjeto	:= AF8->AF8_PROJET
Local cRevisa		:= AF8->AF8_REVISA
Local cEDTPai		:= AF8->AF8_PROJET
Local cTrunca		:= "1"
Local cPmsCust	:= SuperGetMv("MV_PMSCUST",.F.,"1")
Local cCnvPrv		:= AF8->AF8_CNVPRV
Local cArqTrab	:= ""
Local dDtConv		:= AF8->AF8_DTCONV

Local lDtPrj		:= !empty(AF8->AF8_DTCONV) .and. !empty(AF8->AF8_CNVPRV)
Local lSQL			:= Upper(TcSrvType()) != "AS/400" .and. Upper(TcSrvType()) != "ISERIES" .and. ! ("POSTGRES" $ Upper(TCGetDB()))
Local lPMSXCust	:= ExistBlock("PMSXCust")
Local lTotal		:= .F.

Local n1			:= 0
Local n2			:= 0
Local n3			:= 0
Local n4			:= 0
Local n5			:= 0
Local n6			:= 0
Local nRec			:= 0
Local nRecAF9		:= 0
Local nValBDI		:= 0

DEFAULT lSimula	:= .F.

lTotal := cPmsCust=="1"

aDecCst[1] := TamSX3("AF9_CUSTO")[2]
aDecCst[2] := TamSX3("AF9_CUSTO2")[2]
aDecCst[3] := TamSX3("AF9_CUSTO3")[2]
aDecCst[4] := TamSX3("AF9_CUSTO4")[2]
aDecCst[5] := TamSX3("AF9_CUSTO5")[2]

If lSimula
	cProjeto	:= AJB->AJB_PROJET
	cRevisa	:= AJB->AJB_REVISA
EndIf

If hasTemplate("CCT") .and. ExistTemplate("PMAAF9CTrf") // Se existir template

	dbSelectArea("AF9")
	dbSetOrder(1)
	If MsSeek(xFilial("AF9") + cProjeto + cRevisa)
		PmsNewProc("PROJ",AF8->AF8_PROJET + AF8->AF8_REVISA)

		While !Eof() .And. (xFilial("AF9") + cProjeto  + cRevisa == AF9->AF9_FILIAL + AF9->AF9_PROJET + AF9->AF9_REVISA)

			ExecTemplate("PMAAF9CTrf",.F.,.F.,{AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA})

			// ponto de entrada para que o cliente customizar o calculo do custo da tarefa
			If lBlock
				nRecAF9 := AF9->( Recno() )
				ExecBlock("PMSXCust") // calcula o custo
				AF9->( dbgoto( nRecAF9 ) )
			EndIf

			// atualiza o custo das edts pais
			aAreaAF9:= AF9->(GetArea())
			PmsAvalTrf("AF9",4)
			RestArea(aAreaAF9)

			dbSkip()
			PmsIncProc(.T.,,"PROJ")
		End
	EndIf

else // rec·lculo novo

	cTrunca:=AF8->AF8_TRUNCA

	ASIZE(aCustoAF9,5)

	// Calcula custo das tarefas
	if lSQL // Se for diferente de AS/400, recalcula com SQL

		if lPMSXCust
			// Atualiza tarefas
			Pms200Exec(AF9->(xFilial()), cProjeto, cRevisa, cPmsCust, DTOS(dDataBase), aDecCst, 1, 0)

			AF9->(MsSeek(xFilial()+cProjeto+cRevisa,.T.))
 			do while AF9->AF9_PROJET=cProjeto .and. AF9->AF9_REVISAO=cRevisa .and. !AF9->(Eof())
				// ponto de entrada para que o cliente customizar o calculo do custo da tarefa
				nRecAF9 := AF9->( Recno() )
				ExecBlock("PMSXCust") // calcula o custo
				AF9->( dbgoto( nRecAF9 ) )

				AF9->(DbSkip())
			enddo

			// Atualiza EDT's
			Pms200Exec(AF9->(xFilial()), cProjeto, cRevisa, cPmsCust, DTOS(dDataBase), aDecCst, 0, 1)

		// Se n„o tiver ponto de entrada, calcula tambÈm as EDT's
		else
			Pms200Exec(AF9->(xFilial()), cProjeto, cRevisa, cPmsCust, DTOS(dDataBase), aDecCst, 1, 1)
		endif

		//Executa o calculo referente ao campo AF8_BDI e AF8_VALBDI apos o calculo de custo dos serem itens executado na procedure acima
		dbSelectArea("AFC")
		dbSetOrder(1)
		If dbSeek(xFilial("AFC")+cProjeto+cRevisa+cEDTPai)
			If (AFC->AFC_NIVEL == "001")
				nValBDI += IIf(AF8->AF8_VALBDI <> 0, AF8->AF8_VALBDI, AFC->AFC_CUSTO * AF8->AF8_BDI / 100)
			EndIf
			RecLock("AFC",.F.)
			AFC->AFC_VALBDI	+= nValBDI
			AFC->AFC_TOTAL 	:= AFC->AFC_CUSTO + AFC_VALBDI
			MsUnlock()
		Endif

	else
		nProcRegua:=0

		dbSelectArea("AF9")
		dbSetOrder(1)
		dbSeek(xFilial("AF9")+cProjeto+cRevisa)
		nRec:=AF9->(RecNo())
		While !Eof() .And. xFilial("AF9")+cProjeto+cRevisa == AF9_FILIAL+AF9_PROJET+AF9_REVISA
			nProcRegua++
			dbSkip()
		End
		nProcRegua--

		dbSelectArea("AFC")
		dbSetOrder(1)
		dbSeek(xFilial("AFC")+cProjeto+cRevisa)
		nRec:=AFC->(RecNo())
		While !Eof() .And. xFilial("AFC")+cProjeto+cRevisa == AFC_FILIAL+AFC_PROJET+AFC_REVISA
			nProcRegua++
			dbSkip()
		End
		nProcRegua--

		ProcRegua(nProcRegua)

		AAdd( aStruct, { "TRB_NIVEL", "C", Len( AFC->AFC_NIVEL ), 0 } )
		AAdd( aStruct, { "TRB_EDT"  , "C", Len( AFC->AFC_EDT ), 0 } )
		AAdd( aStruct, { "TRB_RECNO", "N", 10, 0 } )

		If _oPMSA2001 <> Nil
			_oPMSA2001:Delete()
			_oPMSA2001 := Nil
		Endif
				
		_oPMSA2001 := FWTemporaryTable():New( "TRAB" )  
		_oPMSA2001:SetFields(aStruct) 
		_oPMSA2001:AddIndex("1", {"TRB_NIVEL","TRB_EDT"})
		
		//------------------
		//CriaÁ„o da tabela temporaria
		//------------------
		_oPMSA2001:Create()  

		TRAB->(DbSetOrder(1))

		AFC->(dbSetOrder(3))
		AFC->(MsSeek(xFilial()+cProjeto+cRevisa,.T.))
		do while AFC->AFC_FILIAL=xFilial("AFC") .and. AFC->AFC_PROJETO=cProjeto .and. AFC->AFC_REVISAO=cRevisa .and. !AFC->(Eof())
			TRAB->(RecLock("TRAB",.T.))
			TRAB->TRB_NIVEL:= AFC->AFC_NIVEL
			TRAB->TRB_EDT  := AFC->AFC_EDT
			TRAB->TRB_RECNO:= AFC->(Recno())
			TRAB->(MsUnLock())
			AFC->(DbSkip())
		enddo

		AF9->(dbSetOrder(1))
		AFA->(dbSetOrder(1))
		AFB->(dbSetOrder(1))

		AF9->(MsSeek(xFilial("AF9")+cProjeto+cRevisa,.T.))
		AFA->(MsSeek(xFilial("AFA")+AF9->AF9_PROJET+AF9->AF9_REVISAO+AF9->AF9_TAREFA,.T.))
		AFB->(MsSeek(xFilial("AFB")+AF9->AF9_PROJET+AF9->AF9_REVISAO+AF9->AF9_TAREFA,.T.))
		do while AF9->AF9_FILIAL=xFilial("AF9") .and. AF9->AF9_PROJET=cProjeto .and. AF9->AF9_REVISAO=cRevisa .and. !AF9->(Eof())
			if !lDtPrj
				if !empty(AF9->AF9_CNVPRV)
					dDtConv:=AF9->AF9_DTCONV
					cCnvPrv:=AF9->AF9_CNVPRV
				else
					dDtConv:=dDataBase
					cCnvPrv:="1"
				endif
			endif
			aTX2M[1]:=1
			aTX2M[2]:=AF9->AF9_TXMO2
			aTX2M[3]:=AF9->AF9_TXMO3
			aTX2M[4]:=AF9->AF9_TXMO4
			aTX2M[5]:=AF9->AF9_TXMO5

			aCustoAF9[1]:=0; aCustoAF9[2]:=0; aCustoAF9[3]:=0; aCustoAF9[4]:=0; aCustoAF9[5]:=0

            // Pula tarefas que n„o existem
			do while AFA->AFA_PROJET=AF9->AF9_PROJET .and. AFA->AFA_REVISAO=AF9->AF9_REVISAO .and. AFA->AFA_TAREFA<AF9->AF9_TAREFA .and. !AFA->(Eof())
				AFA->(DbSkip())
			enddo
			// Recursos
			do while AFA->AFA_PROJET=AF9->AF9_PROJET .and. AFA->AFA_REVISAO=AF9->AF9_REVISAO .and. AFA->AFA_TAREFA=AF9->AF9_TAREFA .and. !AFA->(Eof())
				Pms_Converte(AFA->AFA_CUSTD*AFA->AFA_QUANT, AFA->AFA_MOEDA, cCnvPRV, dDtConv, AF9->AF9_START, AF9->AF9_FINISH, @aCustoAF9, aTX2M, cTrunca, AF9->AF9_QUANT, aDecCst, lTotal)
				AFA->(DbSkip())
			enddo
            // Pula tarefas que n„o existem
			do while AFB->AFB_PROJET=AF9->AF9_PROJET .and. AFB->AFB_REVISAO=AF9->AF9_REVISAO .and. AFB->AFB_TAREFA<AF9->AF9_TAREFA .and. !AFB->(Eof())
				AFB->(DbSkip())
			enddo
			// Tarefas
			do while AFB->AFB_PROJET=AF9->AF9_PROJET .and. AFB->AFB_REVISAO=AF9->AF9_REVISAO .and. AFB->AFB_TAREFA=AF9->AF9_TAREFA .and. !AFB->(Eof())
				Pms_Converte(AFB->AFB_VALOR, AFB->AFB_MOEDA, cCnvPRV, dDtConv, AF9->AF9_START, AF9->AF9_FINISH, @aCustoAF9, aTX2M, cTrunca, AF9->AF9_QUANT, aDecCst, lTotal)
				AFB->(DbSkip())
			EndDo

			AF9->(RecLock("AF9",.F.))
			AF9->AF9_CUSTO := aCustoAF9[1]
			AF9->AF9_CUSTO2:= aCustoAF9[2]
			AF9->AF9_CUSTO3:= aCustoAF9[3]
			AF9->AF9_CUSTO4:= aCustoAF9[4]
			AF9->AF9_CUSTO5:= aCustoAF9[5]
			AF9->AF9_VALBDI:= aCustoAF9[1]*iif(AF9->AF9_BDI<>0,AF9->AF9_BDI,PmsGetBDIPad('AFC',AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_EDTPAI, AF9->AF9_UTIBDI ))/100
			AF9->AF9_TOTAL := aCustoAF9[1]+AF9->AF9_VALBDI
			AF9->(MsUnLock())

			// ponto de entrada para que o cliente possa customizar o calculo do custo da tarefa
			if lPMSXCust
				nRecAF9 := AF9->( Recno() )
				ExecBlock("PMSXCust") // calcula o custo
				AF9->( dbgoto( nRecAF9 ) )
			endif

			AF9->(DbSkip())

			IncProc()
		enddo

		AFC->(DbSetOrder(2))
		AF9->(DbSetOrder(2))
		TRAB->(DbGoTop())
		do while !TRAB->(Eof())
			n1:=n2:=n3:=n4:=n5:=n6:=0

			if AFC->(MsSeek(xFilial("AFC") + cProjeto + cRevisa + TRAB->TRB_EDT))
				do while !AFC->(Eof()) .And. (xFilial("AFC") + cProjeto + cRevisa + TRAB->TRB_EDT == AFC->AFC_FILIAL + AFC->AFC_PROJET + AFC->AFC_REVISA + AFC->AFC_EDTPAI)
					n1 += AFC->AFC_CUSTO
					n2 += AFC->AFC_CUSTO2
					n3 += AFC->AFC_CUSTO3
					n4 += AFC->AFC_CUSTO4
					n5 += AFC->AFC_CUSTO5
					n6 += AFC->AFC_VALBDI
					AFC->(DbSkip())
				enddo
			endif

			if AF9->(MsSeek(xFilial("AF9") + cProjeto + cRevisa + TRAB->TRB_EDT))
				do while !AF9->(Eof()) .And. (xFilial("AF9") + cProjeto + cRevisa + TRAB->TRB_EDT == AF9->AF9_FILIAL + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_EDTPAI)
					n1 += AF9->AF9_CUSTO
					n2 += AF9->AF9_CUSTO2
					n3 += AF9->AF9_CUSTO3
					n4 += AF9->AF9_CUSTO4
					n5 += AF9->AF9_CUSTO5
					n6 += AF9->AF9_VALBDI
					AF9->(DbSkip())
				enddo
			endif

			AFC->(DbGoto(TRAB->TRB_RECNO))
			RecLock("AFC",.F.)
			AFC->AFC_CUSTO	:= n1
			AFC->AFC_CUSTO2	:= n2
			AFC->AFC_CUSTO3	:= n3
			AFC->AFC_CUSTO4	:= n4
			AFC->AFC_CUSTO5	:= n5
			AFC->AFC_VALBDI	:= n6
			AFC->AFC_TOTAL := n1+n6
			AFC->(MsUnlock())

			TRAB->(DbSkip())

			IncProc()
		enddo

		TRAB->(DbCloseArea())

		If _oPMSA2001 <> Nil
			_oPMSA2001:Delete()
			_oPMSA2001 := Nil
		Endif
		
	endif

endif

Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥PmsCfgDlg≥ Autor ≥ Edson Maricate         ≥ Data ≥ 09-02-2001 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Exibe uma tela com as configuracoes da tela de visualizacao.  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥Generico                                                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PmsCfgDlg(aConfig)
Local lRet		:= .F.

If ParamBox({	{3,STR0106,aConfig[1],{STR0107,STR0108,STR0109},90,,.F.},; //"Filtro para "###"Todas as tarefas"###"Tarefas concluidas"###"Tarefas nao concluidas"
				{1,STR0110,aConfig[2],"","","","",55,.T.},; //"Intervalo de"
				{1,STR0111,aConfig[3],"","","","",55,.T.},;  //"Intervalo ate"
				{1,STR0117, aConfig[4],"","","AE8","", 55, .F.}; //"Recurso"
				},STR0112,aConfig,,,.F.,120,3)   //"Configuracoes"
	lRet := .T.
EndIf

Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥PMS200ChangeEDT  ≥ Autor ≥ Fabio Rogerio Pereira  ≥ Data ≥ 17/10/2002 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Realiza a troca da EDTPai da EDT/Tarefa selecionada.			        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥Generico                                         			            ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PMS200ChangeEDT(oTree,cArquivo,lCalcTrib)
Local aArea   	:= GetArea()
Local aEDT    	:= {}
Local aTabelas
Local cAlias  	:= ""
Local cNivel  	:= ""
Local cEDTPai 	:= ""
Local cEDTAnt 	:= ""
Local cOldEdtPai	:= ""
Local cProjeto 	:= ""
Local cRevisa  	:= ""
Local cEDTOrig 	:= ""
Local cOldCode 	:= ""
Local cMV_PMSTCOD	:= GetMV("MV_PMSTCOD")
Local lRet    	:= .F.
Local nRecno  	:= 0

Default lCalcTrib := .F.

// verifica o alias e recno do item selecionado
If oTree != Nil
	cAlias:= SubStr(oTree:GetCargo(),1,3)
	nRecno:= Val(SubStr(oTree:GetCargo(),4,12))
Else
	cAlias := (cArquivo)->ALIAS
	nRecNo := (cArquivo)->RECNO
EndIf

// somente permite a alteracao da EDT Pai de EDT's e Tarefas
If !(cAlias $ "AF9/AFC")
	Return(.F.)
EndIf

// valida o nivel e a data de inicializacao real da EDT/Tarefa selecionada
// Nao permite a troca da EDT principal e tambem de itens que ja foram
// iniciados
dbSelectArea(cAlias)
dbGoTo(nRecNo)
If &(cAlias + "->"+cAlias+"_NIVEL") == "001"
	Return(.F.)
Else
	If !Empty(&(cAlias + "->"+cAlias+"_DTATUI"))
		MsgAlert(STR0114,STR0115) //"Nao e possivel transferir esta EDT/Tarefa pois ja foi inicializada !"###"Atencao"
		Return(.F.)
	EndIf
EndIf

// exibe uma tela de selecao dos projetos para importacao
aEDT := 	PmsSelTsk(STR0116,"AF8/AFC/AF9","AFC",STR0065,"AF8",AF8->AF8_PROJET,.F.,.F.) //"Selecione a nova EDT" "Selecao Invalida"

If (Len(aEDT) > 0)
	// ponto de entrada
	If ExistBlock("PMSCHGEDT")
		If ! ExecBlock("PMSCHGEDT", .F., .F., {Inclui, Altera})
			RestArea(aArea)
			Return .F.
		EndIf
	EndIf
	lRet:= .T.

	cProjeto := AFC->AFC_PROJET
	cRevisa  := AFC->AFC_REVISA
	cEDTOrig := AFC->AFC_EDT

	AFC->(dbGoTo(aEDT[2]))
	cEDTPai:= AFC->AFC_EDT
	cNivel := AFC->AFC_NIVEL

	// Verifica se a operaÁ„o de troca de EDT
	// n„o causa uma referÍncia circular
   If cAlias <> "AF9"
		If PMSAFCCheckRef(cProjeto, cRevisa, cEDTOrig, cEDTPai)
			Aviso(STR0138,;
			      STR0139,;
			      { "Ok" }, 2)  //"Troca nao efetuada"##"Esta operacao de troca de EDT pai nao pode ser realizada pois causa uma referencia circular."

			RestArea(aArea)
			Return .F.
		EndIf
	Endif
	Do Case
		Case cAlias == "AF9"
			dbSelectArea("AF9")
			dbGoTo(nRecNo)
			RecLock("AF9",.F.)

			cEDTAnt := AF9->AF9_EDTPAI

			If cMV_PMSTCOD == "2" .Or. cMV_PMSTCOD == "3"
				cOldCode := AF9->AF9_TAREFA
				AF9->AF9_TAREFA := PmsNumAF9(AF8->AF8_PROJET,cRevisa,cNivel,cEDTPai)
			EndIf

			cNivel := StrZero(Val(cNivel) + 1, TamSX3("AFC_NIVEL")[1])
			Replace AF9->AF9_EDTPAI With cEDTPai
			Replace AF9->AF9_NIVEL  With cNivel

			MsUnLock()

			If cMV_PMSTCOD == "2" .Or. cMV_PMSTCOD == "3"
				AF9RecRelTables(AF9->AF9_FILIAL, AF9->AF9_PROJET, AF9->AF9_REVISA, cOldCode, AF9->AF9_TAREFA,aTabelas)
			EndIf

			// atualizacao das Datas das EDT na estrutura de uma Tarefa
			PmsAtuEDT(AF9->AF9_PROJET,AF9->AF9_REVISA,cEDTAnt)

			// executa o recalculo dos percentuais executados da EDT
			PmsAtuRlz(AF9->AF9_PROJET,AF9->AF9_REVISA,cEDTAnt)

			// executa o recalculo do custo das tarefas e edt
			PmsAF9CusEDT(AF9->AF9_PROJET,AF9->AF9_REVISA,cEDTAnt)

			// executa o recalculo do impostos da edt
			If lCalcTrib
				PmsAN9ImpEDT(AF9->AF9_PROJET,AF9->AF9_REVISA,cEDTAnt)
			EndIf

		Case cAlias == "AFC"
			dbSelectArea("AFC")
			dbGoTo(nRecNo)
			RecLock("AFC",.F.)

			cEDTAnt:= AFC->AFC_EDT

			// altera o cÛdigo da EDT se o modo de codigo for automatico
			If cMV_PMSTCOD == "2" .Or. cMV_PMSTCOD == "3"
				cOldCode := AFC->AFC_EDT
				AFC->AFC_EDT := PMSNumAFC(AFC->AFC_PROJET,;
				                          AFC->AFC_REVISA,;
				                          PMSGetNivel(AFC->AFC_PROJET, AFC->AFC_REVISA, cEDTPai),;
				                          cEDTPai)
			EndIf

			Replace AFC->AFC_EDTPAI With cEDTPai

			MsUnLock()


			If cMV_PMSTCOD == "2" .Or. cMV_PMSTCOD == "3"
				// recodificar as tarefas se o modo de codigo for automatico
				PMSAFCCod(AFC->AFC_PROJET, AFC->AFC_EDT, cEDTAnt, AFC->AFC_REVISA,aTabelas)
				// atualizar as tabelas com relacionamento, exceto AFC e AF9
				AFCRecRelTables(AFC->AFC_FILIAL, AFC->AFC_PROJET, AFC->AFC_REVISA, cOldCode, AFC->AFC_EDT,aTabelas)
			EndIf

			// recalcular os niveis abaixo dela
			PMSAFCNivel(AFC->AFC_PROJET, cEdtPai, cNivel, AFC->AFC_REVISA)
	EndCase
EndIf

// atualizacao das Datas das EDT na estrutura de uma Tarefa
PmsAtuEDT(AFC->AFC_PROJET,AFC->AFC_REVISA,cEDTPai)

// executa o recalculo dos percentuais executados da EDT
PmsAtuRlz(AFC->AFC_PROJET,AFC->AFC_REVISA,cEDTPai)

// executa o recalculo do custo das tarefas e edt
PmsAF9CusEDT(AFC->AFC_PROJET,AFC->AFC_REVISA,cEdtPai)

// executa o recalculo do impostos da edt
If lCalcTrib
	PmsAN9ImpEDT(AFC->AFC_PROJET,AFC->AFC_REVISA,cEdtPai)
EndIf

PMS200Rev()

RestArea(aArea)

Return(lRet)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ A200Opn ≥ Autor ≥ Edson Maricate         ≥ Data ≥ 11-12-2002 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Abre o arquivo de configuracoes, se nao encontrar cria o arq. ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SIGAPMS                                                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function A200Opn(aCampos,cArquivo,cMV1,cMV2)
Local cCampos
Local aCampos2		:= {}
Local aFile 		:= {}

DEFAULT cArquivo := PMS_PROFILE_DIR + PMS_PATH_SEP + "PMSA200"
DEFAULT cMV1 := "MV_PMSPLN1"
DEFAULT cMV2 := "MV_PMSPLN2"

If !File(cArquivo + PMS_SHEET_EXT)

	cCampos := Alltrim(GetMv(cMV1))
	cCampos += Alltrim(GetMv(cMV2))
	cCmpPln	:= cCampos
	While !Empty(AllTrim(cCampos))
		If AT("#",cCampos) > 0
			cAux := Substr(cCampos,1,AT("#",cCampos)-1)
			aAdd(aCampos,{"AF9"+cAux,"AFC"+cAux,,,,.F.,"",})
			aAdd(aCampos2,{,Substr(cAux,2,Len(cAux)-1)})
		    cCampos := Substr(cCampos,AT("#",cCampos)+1,Len(cCampos)-AT("#",cCampos))
		 Else
		 	cCampos := ''
		 EndIf
	End
	GravaPln(aCampos2, {}, cArquivo, 1)
	cArqPLN	:= AllTrim(cArquivo + PMS_SHEET_EXT)

Else
	If ReadSheetFile(AllTrim(cArquivo + PMS_SHEET_EXT), aFile)

		// {versao, campos, senha, descricao, freeze, nindent}
		cPLNVer    := aFile[1]
		cArqPLN    := AllTrim(cArquivo + PMS_SHEET_EXT)
		cCmpPLN    := aFile[2]
		cPLNSenha  := aFile[3]
		cPLNDescri := aFile[4]
		nFreeze    := aFile[5]
		nIndent    := aFile[6]
		lSenha := !Empty(aFile[3])

		If lSenha
			cCmpPLN    := Embaralha(cCmpPLN, 0)
			cPLNDescri := Embaralha(cPLNDescri, 0)
		EndIf

		C200ChkPln(@aCampos)
	Else
		Aviso(STR0125,STR0126,{"Ok"},2) //"Falha na Abertura."###"Erro na abertura do arquivo. Verifique a existencia do arquivo selecionado."
	EndIf
	If AllTrim(cPLNVer) != "101" .And. AllTrim(cPLNVer) != "102"
		Aviso(STR0127,STR0128,{"Ok"},2 )  //"Falha no Arquivo"###"Estrutura do arquivo incompativel. Verifique o arquivo selecionado."
		cCmpPLN	:= ''
	EndIf
EndIf



Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥PMS200PV≥ Autor ≥ Edson Maricate          ≥ Data ≥ 15-08-2003 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Programa de Visualizacao dos Pedidos de Vendas vinculados ao  ≥±±
±±≥          ≥Projeto.                                                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥SIGAPMS                                                       ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PMS200PV(oTree,cArquivo,lVisual)

Local aArea		:= GetArea()
Local cAlias
Local nRecView
Local aSize		:= MsAdvSize(,.F.,430)
Local aRotina   := {}

If oTree == Nil
	cAlias	:= (cArquivo)->ALIAS
	nRecView	:= (cArquivo)->RECNO
Else
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
EndIf

//A200ValOp(cAlias,nRecView,"GERSC",@lHabVis,@lHabInc,@lHabAlt,@lHabExc)

aRotina:= If(lVisual, {{STR0176, "A220toSC", 0 , 2,,.T.}}, {{ STR0003,"A220toSC", 0 , 2,  ,.T.},; //"Visualizar"
                       {STR0177, "A220toSC", 0 , 3,  ,.T.},;	 //"Incluir"
                       {STR0178, "A220toSC", 0 , 4,  ,.T.},;	 //"Alterar"
                       {STR0179, "A220toSC", 0 , 5, 1,.T.} }) //"Excluir"

If cAlias == "AF9" .And. nRecView<>0
	AF9->(dbGoto(nRecView))
	SC6->(dbSetOrder(3))
	MaWndBrowse(aSize[7],0,aSize[6],aSize[5] ,cCadastro+" - PV -["+AllTrim(AF9->AF9_PROJET)+"/"+AF9->AF9_TAREFA+"]","SC6",,aRotina,,;
	'xFilial("SC6")+AF9->AF9_PROJET+AF9->AF9_TAREFA+SPACE(LEN(AFC->AFC_EDT))',;
	'xFilial("SC6")+AF9->AF9_PROJET+AF9->AF9_TAREFA+SPACE(LEN(AFC->AFC_EDT))',;
	.F.,,,{{"Teste",1}},xFilial("SC6")+AF9->AF9_PROJET+AF9->AF9_TAREFA+SPACE(LEN(AFC->AFC_EDT)))
ElseIf cAlias == "AF8" .And. nRecView<>0
	AF8->(dbGoto(nRecView))
	SC6->(dbSetOrder(3))
	MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+" - PV -["+AllTrim(AF8->AF8_PROJET)+"]","SC6",,aRotina,,;
	'xFilial("SC6")+AF8->AF8_PROJET+AF8->AF8_REVISA',;
	'xFilial("SC6")+AF8->AF8_PROJET+AF8->AF8_REVISA',;
	.F.,,,{{"Teste",1}},xFilial("SC6")+AF8->AF8_PROJET+AF8->AF8_REVISA)
EndIf

RestArea(aArea)
Return

Function Pms200View(cTitle,bBlock)
Local nTop      := oMainWnd:nTop+23
Local nLeft     := oMainWnd:nLeft+5
Local nBottom   := oMainWnd:nTop+100
Local nRight    := oMainWnd:nRight-10
Local oDlg

DEFINE FONT oFont NAME "Arial" SIZE 0, -10
DEFINE MSDIALOG oDlg TITLE cTitle OF oMainWnd PIXEL FROM nTop,nLeft TO nBottom,nRight STYLE nOR(WS_VISIBLE,WS_POPUP)

@00,00 BITMAP oBmp1 RESNAME BMP_FAIXA_SUP_PADRAO SIZE 1200,50 NOBORDER PIXEL

ACTIVATE MSDIALOG oDlg ON INIT (Eval(bBlock),oDlg:End())


Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ ExistPrjTrf ≥ Autor ≥ Adriano Ueda         ≥ Data ≥ 07-06-2004 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Funcao para verificar a existencia de determinada tarefa.      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ cProjeto : codigo do projeto                                   ≥±±
±±≥          ≥ cRevisa  : revisao                                             ≥±±
±±≥          ≥ cTarefa  : codigo da tarefa                                    ≥±±
±±≥          ≥ lMensagem: indica se exibira o help de ja gravado              ≥±±
±±≥          ≥            (default: .T.)                                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function ExistPrjTrf(cProjeto, cRevisa, cTarefa, lMensagem, lLiberaCod)
	Local aAreaAF9 := AF9->(GetArea())
	Default lMensagem  := .T.
	Default lLiberaCod := .F.

	dbSelectArea("AF9")
	AF9->(dbSetOrder(1))

	If AF9->(Msseek(xFilial("AF9") + cProjeto + cRevisa + cTarefa))
		If lMensagem
			Help(" ", 1, "JAGRAVADO")
		EndIf

		lRet := .T.
	Else
		lLiberaCod := .T.
		If !(FreeForUse("AF9", cProjeto + cRevisa + cTarefa))
			MsgAlert(STR0247) //"CÛdigo Reservado!"
			lRet := .T.
		Else
			lRet := .F.
		EndIf
	EndIf

	RestArea(aAreaAF9)
Return lRet

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥Procurar ≥ Autor ≥  Adriano Ueda          ≥ Data ≥ 08-02-2004 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Funcao para pesquisa na arvore do projeto/orcamento, atraves ≥±±
±±≥          ≥ da descricao da tarefa/EDT.                                  ≥±±
±±≥          ≥                                                              ≥±±
±±≥          ≥ Esta funcao apenas apresenta a caixa de dialogo para         ≥±±
±±≥          ≥ pesquisa. A pesquisa e realmente realizada atravÈs da funcao ≥±±
±±≥          ≥ PMSFindText.                                                 ≥±±
±±≥          ≥                                                              ≥±±
±±≥          ≥ O texto e pesquisado a partir da posicao corrente do Tree    ≥±±
±±≥          ≥ ate o final do Tree.                                         ≥±±
±±≥          ≥                                                              ≥±±
±±≥          ≥ Se o texto e encontrado, o Tree e reposicionado para refletir≥±±
±±≥          ≥ a posicao do texto.                                          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ oTree       - objeto Tree a ser pesquisado, deve ser diferen ≥±±
±±≥          ≥               te de Nil.                                     ≥±±
±±≥          ≥ cSearchText - deve ser passada por referencia. esta variavel ≥±±
±±≥          ≥               contera o valor digitado na caixa de dialogo e ≥±±
±±≥          ≥               e podera ser utilizado em pesquisas futuras    ≥±±
±±≥          ≥ cArquivo    - arquivo a ser pesquisado                       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥ Nenhum                                                       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ PMSA100, PMSA200                                             ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Function Procurar(oTree, cSearchText, cArquivo)
	If oTree == Nil
	  If PMSFindDlg(@cSearchText)
			If !PMSFindT(cArquivo, @cSearchText, .T., .F., .F.)
				Aviso(STR0143, STR0144 + AllTrim(cSearchText) + "'", {"Ok"}) //"Procurar"###"Nao foi encontrada nenhuma ocorrencia para '"
			Else
				Alert(STR0145) //"Pesquisa efetuada com sucesso!!!"
			EndIf
		EndIf
	Else
		PMSSeekTree(oTree, @cSearchText)
	EndIf
Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ProcurarP≥ Autor ≥  Adriano Ueda          ≥ Data ≥ 02-08-2004 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Funcao para pesquisa na arvore do projeto/orcamento, atraves ≥±±
±±≥          ≥ da descricao da tarefa/EDT.                                  ≥±±
±±≥          ≥                                                              ≥±±
±±≥          ≥ Esta funcao apenas efetua a pesquisa a partir do proximo     ≥±±
±±≥          ≥ pesquisa. A pesquisa e realmente realizada atravÈs da funcao ≥±±
±±≥          ≥ PMSFindText.                                                 ≥±±
±±≥          ≥                                                              ≥±±
±±≥          ≥ O texto e pesquisado a partir da posicao corrente do Tree    ≥±±
±±≥          ≥ ate o final do Tree.                                         ≥±±
±±≥          ≥                                                              ≥±±
±±≥          ≥ Se o texto e encontrado, o Tree e reposicionado para refletir≥±±
±±≥          ≥ a posicao do texto.                                          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ oTree       - objeto Tree a ser pesquisado, deve ser diferen ≥±±
±±≥          ≥               te de Nil.                                     ≥±±
±±≥          ≥ cSearch     - texto a ser pesquisado                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥ Nenhum                                                       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ PMSA100, PMSA200                                             ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function ProcurarP(oTree, cSearch, cArquivo)
If oTree == Nil
	If Empty(cSearch)
		If PMSFindDlg(@cSearch)
			If !PMSFindT(cArquivo, @cSearch, .T., .T., .T.)
				Aviso(STR0143, STR0144 + AllTrim(cSearch) + "'", {"Ok"}) //"Procurar"###"Nao foi encontrada nenhuma ocorrencia para '"
			Else
				Alert(STR0145) //"Pesquisa efetuada com sucesso!!!"
			EndIf
		EndIf
	Else
		If !PMSFindT(cArquivo, @cSearch, .T., .T., .T.)
			Aviso(STR0143, STR0144 + AllTrim(cSearch) + "'", {"Ok"}) //"Procurar"###"Nao foi encontrada nenhuma ocorrencia para '"
		Else
			Alert(STR0145) //"Pesquisa efetuada com sucesso!!!"
		EndIf
	EndIf
Else
	PMSSeekNext(oTree, @cSearch)
EndIf

Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥PMSFindT   Autor ≥  Adriano Ueda          ≥ Data ≥ 02-08-2004 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Funcao para pesquisa de texto no Tree                        ≥±±
±±≥          ≥                                                              ≥±±
±±≥          ≥ Esta funcao recursiva faz a pesquisa de texto no objeto Tree,≥±±
±±≥          ≥ atraves do arquivo de trabalho utilizado pelo Tree.          ≥±±
±±≥          ≥                                                              ≥±±
±±≥          ≥ EDTs abaixo da EDT atual sao calculadas atraves de uma       ≥±±
±±≥          ≥ chamada recursiva                                            ≥±±
±±≥          ≥                                                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ cAlias      - Tree a ser pesquisada                          ≥±±
±±≥          ≥ cFind       - texto a ser pesquisado                         ≥±±
±±≥          ≥ lIgnoreCase - indica se o texto vai ser pesquisado utilizando≥±±
±±≥          ≥               maiusculas ou minusculas:                      ≥±±
±±≥          ≥               .T. - ignora maiusculas e minusculas           ≥±±
±±≥          ≥               .F. - considera maiusculas e minusculas        ≥±±
±±≥          ≥ lSkipCurrent - indica se o no atual do tree deve ser pulado  ≥±±
±±≥          ≥                (se for .T., a procura comeca no proximo      ≥±±
±±≥          ≥                 registro)                                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥ Nenhum                                                       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ PMSA100, PMSA200                                             ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PMSFindT(cAlias, cFind, lIgnoreCase, lSkipCurrent, lSearchNext)
Local lFound := .F.

dbSelectArea(cAlias)
(cAlias)->(dbSetOrder(0))

If lSkipCurrent
	(cAlias)->(dbSkip())
EndIf

While !(cAlias)->(Eof())
	If (Upper(AllTrim(cFind)) $ Upper((cAlias)->XF9_DESCRI) .And. lIgnoreCase) .Or. (AllTrim(cFind) $ (cAlias)->XF9_DESCRI .And. !lIgnoreCase)
		Alert((cAlias)->XF9_DESCRI)
		lFound := .T.
		Exit
	EndIf

	//Verifico se devo pesquisar a prÛxima linha ou n„o (uso Exit para evitar loop infinito) 
	If lSearchNext
		(cAlias)->(dbSkip())
	Else
		Exit
	EndIf

EndDo

Return lFound

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ PmsRetCopy≥ Autor ≥ Daniel Sobreira      ≥ Data ≥ 11-11-2004 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Funcao para retornar informacoes da tarefa ou EDT.				    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ aImport : Array com Alias e Recno                            ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function PmsRetCopy(aImport)
	Local aRetCopy := {}
	Local cAlias   := (aImport[1])
	Local aAreaAFC := (cAlias)->(GetArea())

	dbSelectArea(aImport[1])
	dbGoto(aImport[2])

	aAdd(aRetCopy,&(cAlias + "->" + cAlias + "_PROJET"))
	aAdd(aRetCopy,&(cAlias + "->" + cAlias + "_REVISA"))
	If cAlias="AFC"
		aAdd(aRetCopy,&(cAlias + "->" + cAlias + "_EDT"))
	ElseIf cAlias="AF9"
		aAdd(aRetCopy,&(cAlias + "->" + cAlias + "_TAREFA"))
	EndIf

	RestArea(aAreaAFC)
Return aRetCopy

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥PMS200ReCalc ≥ Autor ≥ Reynaldo Miyashita ≥ Data ≥ 07.12.2004 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ ForÁa o calculo do custo do projeto.                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SIGAPMS                                                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Function PMS200ReCalc(lSimula,lCalcTrib)

Local cProject := AF8->AF8_PROJET
Local cRev 	   := AF8->AF8_REVISA
Local lPm200Mark := ExistBlock("PM200MARK")

Default lCalcTrib := .F.

If lPm200Mark
	ExecBlock( "PM200MARK",.F.,.F.,{cProject, cRev})
EndIf

Begin Transaction

	// verifica a existencia do ponto de entrada PMS200A2 no Template.- Recalculo do valor dos encargos
	If hasTemplate("CCT") .and. ExistTemplate("PMS200A2")
		ExecTemplate("PMS200A2",.F.,.F.)
	EndIf

	If HasTemplate("CCT") .And. ;
	   GetMv("MV_PMSCUST") == "2" .And. ;
	   GetNewPar("MV_CCTUNIT", "1")	== "2"

		If lSimula
			cProject := AJB->AJB_PROJET
			cRev     := AJB->AJB_REVISA
		else
			cProject := AF8->AF8_PROJET
			cRev     := AF8->AF8_REVISA
		EndIf

		CursorWait()

		MsgRun(STR0255, STR0256, ;
		       {|| T_CctNwPrCost(cProject, cRev) })

		// "Recalculando o projeto..."
		// "Aguarde"
		CursorArrow()
	Else
		// atualiza os custos das tarefas e das edts
		Processa({||Pms200AuxEDT(lSimula)},STR0102)  //"Atualizando Custos da EDT. Aguarde..."
	EndIf

	//atualiza impostos das tarefas e das edts
	If lCalcTrib
		Processa({|| PmsAN9RclcImp(cProject,cRev) }, STR0284)  //"Atualizando Impostos da EDT. Aguarde..."
	EndIf

End Transaction

Return( .T. )
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥PMSAFCChe≥ Autor ≥ Adriano Ueda           ≥ Data ≥ 20/01/2005 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Verifica se È a partir da EDT destino È possÌvel             ≥±±
±±≥          ≥ chegar a EDT de origem, ou seja, ela percorre a              ≥±±
±±≥          ≥ a ·rvore na ordem inversa, atÈ chegar na EDT                 ≥±±
±±≥          ≥ principal ou encontrar a EDT origem.                         ≥±±
±±≥          ≥                                                              ≥±±
±±≥          ≥ Assume que a EDT origem e a EDT destino pertencem ao mesmo   ≥±±
±±≥          ≥ projeto.                                                     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ cProjeto - cÛdigo do projeto no qual ser· checada            ≥±±
±±≥          ≥ a referÍncia.                                                ≥±±
±±≥          ≥                                                              ≥±±
±±≥          ≥ cEDTOrigem - a EDT a ser verificada (como a ·rvore È         ≥±±
±±≥          ≥ percorrida do nÛ folha atÈ o raiz, este È o possÌvel ponto   ≥±±
±±≥          ≥ de tÈrmino).                                                 ≥±±
±±≥          ≥                                                              ≥±±
±±≥          ≥ cEDTDestino - a EDT inicial, onde comeÁar· a ser verificada  ≥±±
±±≥          ≥ a ·rvore. Como a funÁ„o È recursiva, poder· ser igual ao     ≥±±
±±≥          ≥ cÛdigo do projeto.                                           ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥ - Retorna .T. se a EDT origem È igual a EDT destino ou a EDT ≥±±
±±≥          ≥ destino n„o for encontrada na base de dados.                 ≥±±
±±≥          ≥ - Retorna .F. se a EDT destino n„o foi encontrada percorrendo≥±±
±±≥          ≥ a ·rvore na ordem inversa ou, ainda, se a EDT destino for    ≥±±
±±≥          ≥ igual ao cÛdigo do orÁamento.                                ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SIGAPMS                                                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PMSAFCCheckRef(cProjeto, cRevisa, cEDTOrig, cEDTDest)
	Local aAreaAFC := AFC->(GetArea())
	Local cEDTProx := ""

	// a EDT origem e EDT destino n„o podem
	// ser a mesma
	If cEDTOrig  == cEDTDest
		Return .T.
	EndIf

	// se a EDT destino for igual o orÁamento
	// a EDT origem n„o foi encontrada
	If AllTrim(cEDTDest) == AllTrim(cProjeto)
		Return .F.
	EndIf

	AFC->(dbSetOrder(1)) 	// AFC_FILIAL + AFC_PROJET + AFC_REVISA + AF5_EDT
	If AFC->(MsSeek(xFilial("AFC") + cProjeto + cRevisa + cEDTDest))
		cEDTProx := AFC->AFC_EDTPAI

		RestArea(aAreaAFC)
		Return PMSAFCCheckRef(cProjeto, cRevisa, cEDTOrig, cEDTProx)
	EndIf

	RestArea(aAreaAFC)
Return .T.

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥A200Encerra≥ Autor ≥ Adriano Ueda           ≥ Data ≥ 20/01/2005     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Valida a alteracao de fase do projeto                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ cFaseNew   - Fase nova do Projeto                                  ≥±±
±±≥          ≥ cFaseOld   - Fase antiga do Projeto                                ≥±±
±±≥          ≥ cPrj       - codigo do projeto                                     ≥±±
±±≥          ≥ cRevisa    - Revisao do projeto                                    ≥±±
±±≥          ≥ cEncerrado - "1".Projeto encerrado    "2".Projeto nao encerrado    ≥±±
±±≥          ≥              (deve ser passado por referencia)                     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SIGAPMS                                                            ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function A200Encerra(cFaseNew,cFaseOld,cPrj,cRevisa,cEncerrado)
Local lRet
Local cAliasAnt   := Alias()
Local aArea       := GetArea()
Local aAreaAEA    := AEA->(GetArea())

Private lFSEncerra     := .F. 

If ( cFaseNew == cFaseOld )
	lRet := .T.
Else
	dbSelectArea("AEA")
	dbSetOrder(1)
	If dbSeek(xFilial("AEA")+cFaseNew)

		// se projeto esta encerrado
		If cEncerrado=="1"
			Aviso(STR0146,STR0147,{"Ok"},2) //"Projeto Encerrado."###"A alteracao de fase nao e permitido apos encerramento do projeto."
			lRet := .F.
		Else
			If (AEA->AEA_EVEN97 == "1") .And. ;
				Aviso(STR0148, STR0149, {STR0150, STR0151},2)==1 //"Encerramento do Projeto"###"Confirma o encerramento do Projeto ?"###"Sim"###"Nao"
				//se confirmar o encerramento - muda a fase e estorna as
				//solicitacoes/empenhos / ops etc
				lFSEncerra := .T.
				lRet := A200EstornaAmarra(cPrj,cRevisa)
				If lRet
					cEncerrado := "1"
				EndIf
			Else
				//se nao confirmar o encerramento - muda a fase porem continua
				//com as solicitacoes/empenhos sem atualizacao
				lRet := .T.
			EndIf
		EndIf
	Else
		Aviso(STR0152,STR0153,{"Ok"},2) //"Fase invalida."###"Fase invalida. Verifique as fases disponiveis para o projeto."
		lRet := .F.
	EndIf
EndIf

If ExistBlock("PMA200ENC")
	ExecBlock("PMA200ENC", .F., .F., {lRet})
EndIf

RestArea(aAreaAEA)
RestArea(aArea)
dbSelectArea(cAliasAnt)

Return(lRet)




Static Function A200EstornaAmarra(cProjeto, cRevisa)
Local lRet      := .T.
Local cAliasAnt := Alias()
Local aArea     := GetArea()
Local aAreaAFH  := AFH->(GetArea())
Local aAreaAFG  := AFG->(GetArea())
Local aAreaAFM  := AFM->(GetArea())
Local aAreaAFA  := AFA->(GetArea())
Local aAreaAFJ  := AFJ->(GetArea())
Local aAreaAF8  := AF8->(GetArea())
Local aAreaAux

dbSelectArea("AFH")
dbSetOrder(1)
dbSeek(xFilial("AFH")+cProjeto+cRevisa)
While AFH->(!Eof() .And. AFH_FILIAL+AFH_PROJET+AFH_REVISA == ;
					xFilial("AFH")+cProjeto+cRevisa)

	//posicionar em SCP SOL AO ALMOXARIFADO ref ao projeto
	aAreaAux := GetArea()
	dbSelectArea("AFH")
	dbSetOrder(2)

   dbSelectArea("SCP")
   dbSetOrder(1)
   dbSeek(xFilial("SCP")+AFH->(AFH_NUMSA+AFH_ITEMSA))

	While SCP->(!Eof() .And. CP_FILIAL+CP_NUM+CP_ITEM == ;
					xFilial("SCP")+AFH->(AFH_NUMSA+AFH_ITEMSA))
		If AFH->AFH_REVISA==cRevisa
			RecLock("AFH",.F.,.T.)
			dbDelete()
		EndIf
		lRet := .T.
		dbSkip()
	End

	RestArea(aAreaAux)

	dbSelectArea("AFH")
	dbSkip()

End

// verifica a existencia de registros no AFG e efetua a exclusao
dbSelectArea("AFG")
dbSetOrder(1)
MsSeek(xFilial()+cProjeto+cRevisa)
While !Eof() .And. xFilial("AFG")+cProjeto+cRevisa==;
	AFG->AFG_FILIAL+AFG->AFG_PROJET+AFG->AFG_REVISA
	PmsAvalAFG("AFG",2)
	PmsAvalAFG("AFG",3)
	dbSelectArea("AFG")
	lRet := .T.
	dbSkip()
EndDo

//amarracao entre ordens de producao e projeto
dbSelectArea("AFM")
dbSetOrder(1)
MsSeek(xFilial()+cProjeto+cRevisa)
While !Eof() .And. xFilial("AFM")+cProjeto+cRevisa==;
	AFM->AFM_FILIAL+AFM->AFM_PROJET+AFM->AFM_REVISA
	PmsAvalAFM("AFM",2)
	PmsAvalAFM("AFM",3)
	lRet := .T.
	dbSelectArea("AFM")
	dbSkip()
EndDo

//posicionar no projeto
dbSelectArea("AF8")
dbSetOrder(1)
	If dbSeek(xFilial("AF8")+cProjeto)

	//AFA - PRODUTOS / RECURSOS DO PROJETO
	dbSelectArea("AFA")
	dbSetOrder(1)
	dbSeek(xFilial()+AF8->AF8_PROJET+AF8->AF8_REVISA)
	While AFA->(!Eof() .And. AFA_FILIAL+AFA_PROJET+AFA_REVISA==;
								xFilial()+AF8->AF8_PROJET+AF8->AF8_REVISA)
		PmsAvalAFA("AFA",2)
		PmsAvalAFA("AFA",3)
		lRet := .T.
		dbSkip()
	End

	//AFJ - EMPENHOS DO PROJETO
	dbSelectArea("AFJ")
	dbSetOrder(1)
	dbSeek(xFilial()+AF8->AF8_PROJET)
	While AFJ->(!Eof() .And. AFJ_FILIAL+AFJ_PROJET==;
								xFilial()+AF8->AF8_PROJET)
		PmsAvalAFJ("AFJ",2)
		PmsAvalAFJ("AFJ",3)
		lRet := .T.
		dbSkip()
	End
EndIf

RestArea(aAreaAFH)
RestArea(aAreaAFG)
RestArea(aAreaAFM)
RestArea(aAreaAFA)
RestArea(aAreaAFJ)
RestArea(aAreaAF8)
RestArea(aArea)
dbSelectArea(cAliasAnt)

Return(lRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥AF5AtuCod≥ Autor ≥ Adriano Ueda           ≥ Data ≥ 03/06/2005 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥                                                              ≥±±
±±≥          ≥                                                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                              ≥±±
±±≥          ≥                                                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥                                                              ≥±±
±±≥          ≥                                                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SIGAPMS                                                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function AF5AtuCode(cFil, cOrc, cEDT, cNewEDT)
	Local aParam, aCamposUsr
	Local aCampos := {}

	aAdd(aCampos, {"AF5", 2, "AF5_FILIAL+AF5_ORCAME+AF5_EDTPAI", "AF5_EDTPAI", cFil + cOrc + cEDT, cNewEDT}) // AF5_FILIAL+AF5_ORCAME+AF5_EDTPAI+AF5_ORDEM
	aAdd(aCampos, {"AJ1", 2, "AJ1_FILIAL+AJ1_ORCAME+AJ1_PREDEC", "AJ1_PREDEC", cFil + cOrc + cEDT, cNewEDT}) // AJ1_FILIAL+AJ1_ORCAME+AJ1_PREDEC
	aAdd(aCampos, {"AJ2", 1, "AJ2_FILIAL+AJ2_ORCAME+AJ2_EDT",    "AJ2_EDT",    cFil + cOrc + cEDT, cNewEDT}) // AJ2_FILIAL+AJ2_ORCAME+AJ2_EDT+AJ2_ITEM
	aAdd(aCampos, {"AJ3", 1, "AJ3_FILIAL+AJ3_ORCAME+AJ3_EDT",    "AJ3_EDT",    cFil + cOrc + cEDT, cNewEDT}) // AJ3_FILIAL+AJ3_ORCAME+AJ3_EDT+AJ3_ITEM
	aAdd(aCampos, {"AJ3", 2, "AJ3_FILIAL+AJ3_ORCAME+AJ3_PREDEC", "AJ3_PREDEC", cFil + cOrc + cEDT, cNewEDT}) // AJ3_FILIAL+AJ3_ORCAME+AJ3_PREDEC

	//Ponto de Entrada para manipulacao do array aCampos
	//passado aCampos e aParam contendo os parametros recebidos pela funcao
	aParam := { cFil, cOrc, cEDT, cNewEDT }

	If ExistBlock("PM200AF5")
		aCamposUsr := ExecBlock("PM200AF5", .F., .F., {aCampos, aParam})
		AEval( aCamposUsr, { |x| AAdd( aCampos, x ) } )
	EndIf

	PMSAltera({},aCampos)
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥AF2AtuCod≥ Autor ≥ Adriano Ueda           ≥ Data ≥ 03/06/2005 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥                                                              ≥±±
±±≥          ≥                                                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                              ≥±±
±±≥          ≥                                                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥                                                              ≥±±
±±≥          ≥                                                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SIGAPMS                                                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function AF2AtuCode(cFil, cOrc, cTask, cNewTask)
	Local aParam, aCamposUsr
	Local aCampos := {}

	aAdd(aCampos, {"AJ1", 1, "AJ1_FILIAL+AJ1_ORCAME+AJ1_TAREFA", "AJ1_TAREFA", cFil + cOrc + cTask, cNewTask}) // AJ1_FILIAL+AJ1_ORCAME+AJ1_TAREFA+AJ1_ITEM
	aAdd(aCampos, {"AJ2", 2, "AJ2_FILIAL+AJ2_ORCAME+AJ2_PREDEC", "AJ2_PREDEC", cFil + cOrc + cTask, cNewTask}) // AJ2_FILIAL+AJ2_ORCAME+AJ2_PREDEC
	aAdd(aCampos, {"AF3", 1, "AF3_FILIAL+AF3_ORCAME+AF3_TAREFA", "AF3_TAREFA", cFil + cOrc + cTask, cNewTask}) // AF3_FILIAL+AF3_ORCAME+AF3_TAREFA+AF3_ITEM+AF3_TPALOC
	aAdd(aCampos, {"AF4", 1, "AF4_FILIAL+AF4_ORCAME+AF4_TAREFA", "AF4_TAREFA", cFil + cOrc + cTask, cNewTask}) // AF4_FILIAL+AF4_ORCAME+AF4_TAREFA+AF4_ITEM
	aAdd(aCampos, {"AF7", 1, "AF7_FILIAL+AF7_ORCAME+AF7_TAREFA", "AF7_TAREFA", cFil + cOrc + cTask, cNewTask}) // AF7_FILIAL+AF7_ORCAME+AF7_TAREFA+AF7_ITEM
	aAdd(aCampos, {"AF7", 2, "AF7_FILIAL+AF7_ORCAME+AF7_PREDEC", "AF7_PREDEC", cFil + cOrc + cTask, cNewTask}) // AF7_FILIAL+AF7_ORCAME+AF7_PREDEC

	//Ponto de Entrada para manipulacao do array aCampos
	//passado aCampos e aParam contendo os parametros recebidos pela funcao
	aParam := {cFil, cOrc, cTask, cNewTask}

	If ExistBlock("PM200AF2")
		aCamposUsr := ExecBlock("PM200AF2", .F., .F., {aCampos, aParam})
		AEval( aCamposUsr, { |x| AAdd( aCampos, x ) } )
	EndIf

	PMSAltera({},aCampos)
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥AFCAtuCod≥ Autor ≥ Adriano Ueda           ≥ Data ≥ 03/06/2005            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥atualiza a EDT PAI das EDT Filhas e a EDT das outras tabelas relacionadas≥±±
±±≥          ≥                                                                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                                         ≥±±
±±≥          ≥                                                                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥                                                                         ≥±±
±±≥          ≥                                                                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SIGAPMS                                                                 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function AFCAtuCode(cFil, cProject, cRev, cEDT, cNewEDT, aCampoTOP)
Local aParam, aCamposUsr
Local aCampos   := {} //array para o ponto de entrada PM200AF5
Local aCampoDBF := {} //array para atualizacao em DBF
Local nTam      := TamSX3("AFC_REVISA")[1]
Default aCampoTOP := {}

aAdd(aCampos, {"AFC", 2, "AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDTPAI", "AFC_EDTPAI", xFilial("AFC") + cProject + cRev + cEDT, cNewEDT}) // AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDTPAI+AFC_ORDEM
aAdd(aCampos, {"AFP", 2, "AFP_FILIAL+AFP_PROJET+AFP_REVISA+AFP_EDT",    "AFP_EDT",    xFilial("AFP") + cProject + cRev + cEDT, cNewEDT}) // AFP_FILIAL+AFP_PROJET+AFP_REVISA+AFP_EDT+AFP_ITEM
aAdd(aCampos, {"AFQ", 1, "AFQ_FILIAL+AFQ_PROJET+AFQ_REVISA+AFQ_EDT",    "AFQ_EDT",    xFilial("AFQ") + cProject + cRev + cEDT, cNewEDT}) // AFQ_FILIAL+AFQ_PROJET+AFQ_REVISA+AFQ_EDT+DTOS(AFQ_DATA)
aAdd(aCampos, {"AFS", 3, "AFS_FILIAL+AFS_PROJET+AFS_REVISA+AFS_EDT",    "AFS_EDT",    xFilial("AFS") + cProject + cRev + cEDT, cNewEDT}) // AFS_FILIAL+AFS_PROJET+AFS_REVISA+AFS_EDT+AFS_COD+AFS_LOCAL+DTOS(AFS_EMISSA)
aAdd(aCampos, {"AFT", 4, "AFT_FILIAL+AFT_PROJET+AFT_REVISA+AFT_EDT",    "AFT_EDT",    xFilial("AFT") + cProject + cRev + cEDT, cNewEDT}) // AFT_FILIAL+AFT_PROJET+AFT_REVISA+AFT_EDT+AFT_PREFIX+AFT_NUM+AFT_PARCEL+AFT_TIPO+AFT_CLIENT+AFT_LOJA
aAdd(aCampos, {"AFX", 1, "AFX_FILIAL+AFX_PROJET+AFX_REVISA+AFX_EDT",    "AFX_EDT",    xFilial("AFX") + cProject + space(nTam) + cEDT, cNewEDT}) // AFX_FILIAL+AFX_PROJET+AFX_REVISA+AFX_EDT+AFX_USER
aAdd(aCampos, {"AJ5", 1, "AJ5_FILIAL+AJ5_PROJET+AJ5_REVISA+AJ5_EDT",    "AJ5_EDT",    xFilial("AJ5") + cProject + cRev + cEDT, cNewEDT}) // AJ5_FILIAL+AJ5_PROJET+AJ5_REVISA+AJ5_EDT+AJ5_ITEM
aAdd(aCampos, {"AJ6", 1, "AJ6_FILIAL+AJ6_PROJET+AJ6_REVISA+AJ6_EDT",    "AJ6_EDT",    xFilial("AJ6") + cProject + cRev + cEDT, cNewEDT}) // AJ6_FILIAL+AJ6_PROJET+AJ6_REVISA+AJ6_EDT+AJ6_ITEM
aAdd(aCampos, {"AJ6", 2, "AJ6_FILIAL+AJ6_PROJET+AJ6_REVISA+AJ6_PREDEC", "AJ6_PREDEC", xFilial("AJ6") + cProject + cRev + cEDT, cNewEDT}) // AJ6_FILIAL+AJ6_PROJET+AJ6_REVISA+AJ6_PREDEC
aAdd(aCampos, {"AJD", 1, "AJD_FILIAL+AJD_PROJET+AJD_REVISA+AJD_EDT",    "AJD_EDT",    xFilial("AJD") + cProject + cRev + cEDT, cNewEDT}) // AJD_FILIAL+AJD_PROJET+AJD_REVISA+AJD_EDT+AJD_FILDOC+AJD_DOCTO
aAdd(aCampos, {"AJE", 2, "AJE_FILIAL+AJE_PROJET+AJE_REVISA+AJE_EDT",    "AJE_EDT",    xFilial("AJE") + cProject + cRev + cEDT, cNewEDT}) // AJE_FILIAL+AJE_PROJET+AJE_REVISA+AJE_EDT+DTOS(AJE_DATA)
aAdd(aCampos, {"AJ4", 2, "AJ4_FILIAL+AJ4_PROJET+AJ4_REVISA+AJ4_PREDEC", "AJ4_PREDEC", xFilial("AJ4") + cProject + cRev + cEDT, cNewEDT}) // AJ4_FILIAL+AJ4_PROJET+AJ4_REVISA+AJ4_PREDEC

// DbSelectArea para criar as tabelas no banco de dados caso nao existam
DbSelectArea("AFC")
DbSelectArea("AFP")
DbSelectArea("AFQ")
DbSelectArea("AFS")
DbSelectArea("AFT")
DbSelectArea("AFX")
DbSelectArea("AJ5")
DbSelectArea("AJ6")
DbSelectArea("AJ6")
DbSelectArea("AJD")
DbSelectArea("AJE")
DbSelectArea("AJ4")

aAdd(aCampoTOP, {"AFC", "AFC_EDTPAI", "AFC_FILIAL", "AFC_PROJET", "AFC_REVISA", xFilial("AFC"), cProject, cRev+"' AND AFC_EDTPAI = '"+cEDT, , cNewEDT}) // AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDTPAI+AFC_ORDEM
aAdd(aCampoTOP, {"AFP", "AFP_EDT"   , "AFP_FILIAL", "AFP_PROJET", "AFP_REVISA", xFilial("AFP"), cProject, cRev+"' AND AFP_EDT = '"   +cEDT, , cNewEDT}) // AFP_FILIAL+AFP_PROJET+AFP_REVISA+AFP_EDT+AFP_ITEM
aAdd(aCampoTOP, {"AFQ", "AFQ_EDT"   , "AFQ_FILIAL", "AFQ_PROJET", "AFQ_REVISA", xFilial("AFQ"), cProject, cRev+"' AND AFQ_EDT = '"   +cEDT, , cNewEDT}) // AFQ_FILIAL+AFQ_PROJET+AFQ_REVISA+AFQ_EDT+DTOS(AFQ_DATA)
aAdd(aCampoTOP, {"AFS", "AFS_EDT"   , "AFS_FILIAL", "AFS_PROJET", "AFS_REVISA", xFilial("AFS"), cProject, cRev+"' AND AFS_EDT = '"   +cEDT, , cNewEDT}) // AFS_FILIAL+AFS_PROJET+AFS_REVISA+AFS_EDT+AFS_COD+AFS_LOCAL+DTOS(AFS_EMISSA)
aAdd(aCampoTOP, {"AFT", "AFT_EDT"   , "AFT_FILIAL", "AFT_PROJET", "AFT_REVISA", xFilial("AFT"), cProject, cRev+"' AND AFT_EDT = '"   +cEDT, , cNewEDT}) // AFT_FILIAL+AFT_PROJET+AFT_REVISA+AFT_EDT+AFT_PREFIX+AFT_NUM+AFT_PARCEL+AFT_TIPO+AFT_CLIENT+AFT_LOJA
aAdd(aCampoTOP, {"AFX", "AFX_EDT"   , "AFX_FILIAL", "AFX_PROJET", "AFX_REVISA", xFilial("AFX"), cProject, space(nTam)+"' AND AFX_EDT = '"   +cEDT, , cNewEDT}) // AFX_FILIAL+AFX_PROJET+AFX_REVISA+AFX_EDT+AFX_USER
aAdd(aCampoTOP, {"AJ5", "AJ5_EDT"   , "AJ5_FILIAL", "AJ5_PROJET", "AJ5_REVISA", xFilial("AJ5"), cProject, cRev+"' AND AJ5_EDT = '"   +cEDT, , cNewEDT}) // AJ5_FILIAL+AJ5_PROJET+AJ5_REVISA+AJ5_EDT+AJ5_ITEM
aAdd(aCampoTOP, {"AJ6", "AJ6_EDT"   , "AJ6_FILIAL", "AJ6_PROJET", "AJ6_REVISA", xFilial("AJ6"), cProject, cRev+"' AND AJ6_EDT = '"   +cEDT, , cNewEDT}) // AJ6_FILIAL+AJ6_PROJET+AJ6_REVISA+AJ6_EDT+AJ6_ITEM
aAdd(aCampoTOP, {"AJ6", "AJ6_PREDEC", "AJ6_FILIAL", "AJ6_PROJET", "AJ6_REVISA", xFilial("AJ6"), cProject, cRev+"' AND AJ6_PREDEC = '"+cEDT, , cNewEDT}) // AJ6_FILIAL+AJ6_PROJET+AJ6_REVISA+AJ6_PREDEC
aAdd(aCampoTOP, {"AJD", "AJD_EDT"   , "AJD_FILIAL", "AJD_PROJET", "AJD_REVISA", xFilial("AJD"), cProject, cRev+"' AND AJD_EDT = '"   +cEDT, , cNewEDT}) // AJD_FILIAL+AJD_PROJET+AJD_REVISA+AJD_EDT+AJD_FILDOC+AJD_DOCTO
aAdd(aCampoTOP, {"AJE", "AJE_EDT"   , "AJE_FILIAL", "AJE_PROJET", "AJE_REVISA", xFilial("AJE"), cProject, cRev+"' AND AJE_EDT = '"   +cEDT, , cNewEDT}) // AJE_FILIAL+AJE_PROJET+AJE_REVISA+AJE_EDT+DTOS(AJE_DATA)
aAdd(aCampoTOP, {"AJ4", "AJ4_PREDEC", "AJ4_FILIAL", "AJ4_PROJET", "AJ4_REVISA", xFilial("AJ4"), cProject, cRev+"' AND AJ4_PREDEC = '"+cEDT, , cNewEDT}) // AJ4_FILIAL+AJ4_PROJET+AJ4_REVISA+AJ4_PREDEC

//Ponto de Entrada para manipulacao do array aCampoDBF
//passado aCampos e aParam contendo os parametros recebidos pela funcao
aParam := { cFil, cProject, cRev, cEDT, cNewEDT }

If ExistBlock("PM200AFC")
	aCamposUsr := ExecBlock("PM200AFC", .F., .F., {aCampos, aParam})
	AEval( aCamposUsr, { |x| AAdd( aCampoDBF, aClone(x) ) } )
EndIf

PMSAltera({},aCampoDBF)

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥AF9AtuCod≥ Autor ≥ Adriano Ueda           ≥ Data ≥ 03/06/2005 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥                                                              ≥±±
±±≥          ≥                                                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                              ≥±±
±±≥          ≥                                                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥                                                              ≥±±
±±≥          ≥                                                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SIGAPMS                                                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function AF9AtuCode(cFil, cProject, cRev, cTask, cNewTask, aCampoTOP)
Local aParam, aCamposUsr
Local aCampos   := {} //array para o ponto de entrada PM200AF5
Local aCampoDBF := {} //array para atualizacao em DBF
Local nTam      := TamSX3("AF9_REVISA")[1]
Local lCompUnic := AF8ComAJT(AF8->AF8_PROJET)

Default aCampoTOP := {}

// aCampos := {cAlias,
//             nIndexOrder,
//             cPartialIndex,
//             cField,
//             cIndexExpression,
//             cNewValue}
aAdd(aCampos, {"AFA", 1, "AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA", "AFA_TAREFA", xFilial("AFA") + cProject + cRev + cTask, cNewTask}) // AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA+AFA_ITEM+AFA_TPALOC
aAdd(aCampos, {"AFB", 1, "AFB_FILIAL+AFB_PROJET+AFB_REVISA+AFB_TAREFA", "AFB_TAREFA", xFilial("AFB") + cProject + cRev + cTask, cNewTask}) // AFB_FILIAL+AFB_PROJET+AFB_REVISA+AFB_TAREFA+AFB_ITEM
aAdd(aCampos, {"AFD", 1, "AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA", "AFD_TAREFA", xFilial("AFD") + cProject + cRev + cTask, cNewTask}) // AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA+AFD_ITEM
aAdd(aCampos, {"AFD", 2, "AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_PREDEC", "AFD_PREDEC", xFilial("AFD") + cProject + cRev + cTask, cNewTask}) // AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_PREDEC+AFD_ITEM
aAdd(aCampos, {"AFF", 1, "AFF_FILIAL+AFF_PROJET+AFF_REVISA+AFF_TAREFA", "AFF_TAREFA", xFilial("AFF") + cProject + cRev + cTask, cNewTask}) // AFF_FILIAL+AFF_PROJET+AFF_REVISA+AFF_TAREFA+DTOS(AFF_DATA)
aAdd(aCampos, {"AFG", 1, "AFG_FILIAL+AFG_PROJET+AFG_REVISA+AFG_TAREFA", "AFG_TAREFA", xFilial("AFG") + cProject + cRev + cTask, cNewTask}) // AFG_FILIAL+AFG_PROJET+AFG_REVISA+AFG_TAREFA+AFG_NUMSC+AFG_ITEMSC
aAdd(aCampos, {"AFH", 1, "AFH_FILIAL+AFH_PROJET+AFH_REVISA+AFH_TAREFA", "AFH_TAREFA", xFilial("AFH") + cProject + cRev + cTask, cNewTask}) // AFH_FILIAL+AFH_PROJET+AFH_REVISA+AFH_TAREFA+AFH_NUMSA+AFH_ITEMSA
aAdd(aCampos, {"AFI", 1, "AFI_FILIAL+AFI_PROJET+AFI_REVISA+AFI_TAREFA", "AFI_TAREFA", xFilial("AFI") + cProject + cRev + cTask, cNewTask}) // AFI_FILIAL+AFI_PROJET+AFI_REVISA+AFI_TAREFA+AFI_COD+AFI_LOCAL+DTOS(AFI_EMISSA)+AFI_NUMSEQ
aAdd(aCampos, {"AFJ", 1, "AFJ_FILIAL+AFJ_PROJET+AFJ_TAREFA",            "AFJ_TAREFA", xFilial("AFJ") + cProject +        cTask, cNewTask}) // AFJ_FILIAL+AFJ_PROJET+AFJ_TAREFA+AFJ_COD+AFJ_LOCAL
aAdd(aCampos, {"AFL", 1, "AFL_FILIAL+AFL_PROJET+AFL_REVISA+AFL_TAREFA", "AFL_TAREFA", xFilial("AFL") + cProject + cRev + cTask, cNewTask}) // AFL_FILIAL+AFL_PROJET+AFL_REVISA+AFL_TAREFA+AFL_NUMCP+AFL_ITEMCP
aAdd(aCampos, {"AFM", 1, "AFM_FILIAL+AFM_PROJET+AFM_REVISA+AFM_TAREFA", "AFM_TAREFA", xFilial("AFM") + cProject + cRev + cTask, cNewTask}) // AFM_FILIAL+AFM_PROJET+AFM_REVISA+AFM_TAREFA+AFM_NUMOP+AFM_ITEMOP+AFM_SEQOP
aAdd(aCampos, {"AFN", 1, "AFN_FILIAL+AFN_PROJET+AFN_REVISA+AFN_TAREFA", "AFN_TAREFA", xFilial("AFN") + cProject + cRev + cTask, cNewTask}) // AFN_FILIAL+AFN_PROJET+AFN_REVISA+AFN_TAREFA+AFN_DOC+AFN_SERIE+AFN_FORNEC+AFN_LOJA+AFN_ITEM
aAdd(aCampos, {"AFP", 1, "AFP_FILIAL+AFP_PROJET+AFP_REVISA+AFP_TAREFA", "AFP_TAREFA", xFilial("AFP") + cProject + cRev + cTask, cNewTask}) // AFP_FILIAL+AFP_PROJET+AFP_REVISA+AFP_TAREFA+AFP_ITEM
aAdd(aCampos, {"AFR", 1, "AFR_FILIAL+AFR_PROJET+AFR_REVISA+AFR_TAREFA", "AFR_TAREFA", xFilial("AFR") + cProject + cRev + cTask, cNewTask}) // AFR_FILIAL+AFR_PROJET+AFR_REVISA+AFR_TAREFA+AFR_PREFIX+AFR_NUM+AFR_PARCEL+AFR_TIPO+AFR_FORNEC+AFR_LOJA
aAdd(aCampos, {"AFS", 5, "AFS_FILIAL+AFS_PROJET+AFS_REVISA+AFS_TAREFA", "AFS_TAREFA", xFilial("AFS") + cProject + cRev + cTask, cNewTask}) // AFS_FILIAL+AFS_PROJET+AFS_REVISA+AFS_TAREFA+AFS_TRT
aAdd(aCampos, {"AFT", 1, "AFT_FILIAL+AFT_PROJET+AFT_REVISA+AFT_TAREFA", "AFT_TAREFA", xFilial("AFT") + cProject + cRev + cTask, cNewTask}) // AFT_FILIAL+AFT_PROJET+AFT_REVISA+AFT_TAREFA+AFT_PREFIX+AFT_NUM+AFT_PARCEL+AFT_TIPO+AFT_CLIENT+AFT_LOJA
aAdd(aCampos, {"AFU", 1, "AFU_FILIAL+AFU_CTRRVS+AFU_PROJET+AFU_REVISA+AFU_TAREFA", "AFU_TAREFA", xFilial("AFU") + "1" + cProject + cRev + cTask, cNewTask}) // AFU_FILIAL+AFU_CTRRVS+AFU_PROJET+AFU_REVISA+AFU_TAREFA+AFU_RECURS+DTOS(AFU_DATA)
aAdd(aCampos, {"AFV", 1, "AFV_FILIAL+AFV_PROJET+AFV_REVISA+AFV_TAREFA", "AFV_TAREFA", xFilial("AFV") + cProject + SPACE(nTam) + cTask, cNewTask}) // AFV_FILIAL+AFV_PROJET+AFV_REVISA+AFV_TAREFA+AFV_USER
aAdd(aCampos, {"AFZ", 1, "AFZ_FILIAL+AFZ_PROJET+AFZ_REVISA+AFZ_TAREFA", "AFZ_TAREFA", xFilial("AFZ") + cProject + cRev + cTask, cNewTask}) // AFZ_FILIAL+AFZ_PROJET+AFZ_REVISA+AFZ_TAREFA+DTOS(AFZ_DATA)
aAdd(aCampos, {"AJ4", 1, "AJ4_FILIAL+AJ4_PROJET+AJ4_REVISA+AJ4_TAREFA", "AJ4_TAREFA", xFilial("AJ4") + cProject + cRev + cTask, cNewTask}) // AJ4_FILIAL+AJ4_PROJET+AJ4_REVISA+AJ4_TAREFA+AJ4_ITEM
aAdd(aCampos, {"AJ5", 2, "AJ5_FILIAL+AJ5_PROJET+AJ5_REVISA+AJ5_PREDEC", "AJ5_PREDEC", xFilial("AJ5") + cProject + cRev + cTask, cNewTask}) // AJ5_FILIAL+AJ5_PROJET+AJ5_REVISA+AJ5_PREDEC
aAdd(aCampos, {"AJ7", 1, "AJ7_FILIAL+AJ7_PROJET+AJ7_REVISA+AJ7_TAREFA", "AJ7_TAREFA", xFilial("AJ7") + cProject + cRev + cTask, cNewTask}) // AJ7_FILIAL+AJ7_PROJET+AJ7_REVISA+AJ7_TAREFA+AJ7_NUMPC+AJ7_ITEMPC
aAdd(aCampos, {"AJ9", 1, "AJ9_FILIAL+AJ9_PROJET+AJ9_REVISA+AJ9_TAREFA", "AJ9_TAREFA", xFilial("AJ9") + cProject + cRev + cTask, cNewTask}) // AJ9_FILIAL+AJ9_PROJET+AJ9_REVISA+AJ9_TAREFA+DTOS(AJ9_DATA)+AJ9_NUMAE+AJ9_IT
aAdd(aCampos, {"AJC", 1, "AJC_FILIAL+AJC_CTRRVS+AJC_PROJET+AJC_REVISA+AJC_TAREFA", "AJC_TAREFA", xFilial("AJC") + "1" + cProject + cRev + cTask, cNewTask}) // AJC_FILIAL+AJC_CTRRVS+AJC_PROJET+AJC_REVISA+AJC_TAREFA+DTOS(AJC_DATA)
aAdd(aCampos, {"AJD", 2, "AJD_FILIAL+AJD_PROJET+AJD_REVISA+AJD_TAREFA", "AJD_TAREFA", xFilial("AJD") + cProject + cRev + cTask, cNewTask}) // AJD_FILIAL+AJD_PROJET+AJD_REVISA+AJD_TAREFA+AJD_FILDOC+AJD_DOCTO
aAdd(aCampos, {"AJE", 1, "AJE_FILIAL+AJE_PROJET+AJE_REVISA+AJE_TAREFA", "AJE_TAREFA", xFilial("AJE") + cProject + cRev + cTask, cNewTask}) // AJE_FILIAL+AJE_PROJET+AJE_REVISA+AJE_TAREFA+DTOS(AJE_DATA)
aAdd(aCampos, {"AFI", 1, "AFI_FILIAL+AFI_PROJET+AFI_REVISA+AFI_TAREFA", "AFI_TAREFA", xFilial("AFI") + cProject + cRev + cTask, cNewTask}) // AFI_FILIAL+AFI_PROJET+AFI_REVISA+AFI_TAREFA
aAdd(aCampos, {"AJK", 1, "AJK_FILIAL+AJK_PROJET+AJK_REVISA+AJK_TAREFA", "AJK_TAREFA", xFilial("AJK") + cProject + cRev + cTask, cNewTask}) // AJK_FILIAL+AJK_PROJET+AJK_REVISA+AJK_TAREFA
aAdd(aCampos, {"AEF", 1, "AEF_FILIAL+AEF_PROJET+AEF_REVISA+AEF_TAREFA", "AEF_TAREFA", xFilial("AEF") + cProject + cRev + cTask, cNewTask}) // AJK_FILIAL+AJK_PROJET+AJK_REVISA+AJK_TAREFA

If lCompUnic
	aAdd(aCampos, {"AEL", 1, "AEL_FILIAL+AEL_PROJET+AEL_REVISA+AEL_TAREFA", "AEL_TAREFA", xFilial("AEL") + cProject + cRev + cTask, cNewTask}) // AEL_FILIAL+AEL_PROJET+AEL_REVISA+AEL_TAREFA
	aAdd(aCampos, {"AEN", 1, "AEN_FILIAL+AEN_PROJET+AEN_REVISA+AEN_TAREFA", "AEN_TAREFA", xFilial("AEN") + cProject + cRev + cTask, cNewTask}) // AEN_FILIAL+AEN_PROJET+AEN_REVISA+AEN_TAREFA
EndIf

// DbSelectArea para criar as tabelas no banco de dados caso nao existam
DbSelectArea("AFA")
DbSelectArea("AFB")
DbSelectArea("AFD")
DbSelectArea("AFD")
DbSelectArea("AFF")
DbSelectArea("AFG")
DbSelectArea("AFH")
DbSelectArea("AFI")
DbSelectArea("AFJ")
DbSelectArea("AFL")
DbSelectArea("AFM")
DbSelectArea("AFN")
DbSelectArea("AFP")
DbSelectArea("AFR")
DbSelectArea("AFS")
DbSelectArea("AFT")
DbSelectArea("AFU")
DbSelectArea("AFV")
DbSelectArea("AFZ")
DbSelectArea("AJ4")
DbSelectArea("AJ5")
DbSelectArea("AJ7")
DbSelectArea("AJ9")
DbSelectArea("AJC")
DbSelectArea("AJD")
DbSelectArea("AJE")
DbSelectArea("AFI")
DbSelectArea("AJK")
DbSelectArea("AEF")
If lCompUnic
	DbSelectArea("AEL")
	DbSelectArea("AEN")
EndIf

aAdd(aCampoTOP, {"AFA", "AFA_TAREFA", "AFA_FILIAL", "AFA_PROJET", "AFA_REVISA", xFilial("AFA"), cProject, cRev+"' AND AFA_TAREFA = '"+cTask, , cNewTask}) // AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA+AFA_ITEM+AFA_TPALOC
aAdd(aCampoTOP, {"AFB", "AFB_TAREFA", "AFB_FILIAL", "AFB_PROJET", "AFB_REVISA", xFilial("AFB"), cProject, cRev+"' AND AFB_TAREFA = '"+cTask, , cNewTask}) // AFB_FILIAL+AFB_PROJET+AFB_REVISA+AFB_TAREFA+AFB_ITEM
aAdd(aCampoTOP, {"AFD", "AFD_TAREFA", "AFD_FILIAL", "AFD_PROJET", "AFD_REVISA", xFilial("AFD"), cProject, cRev+"' AND AFD_TAREFA = '"+cTask, , cNewTask}) // AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA+AFD_ITEM
aAdd(aCampoTOP, {"AFD", "AFD_PREDEC", "AFD_FILIAL", "AFD_PROJET", "AFD_REVISA", xFilial("AFD"), cProject, cRev+"' AND AFD_PREDEC = '"+cTask, , cNewTask}) // AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_PREDEC+AFD_ITEM
aAdd(aCampoTOP, {"AFF", "AFF_TAREFA", "AFF_FILIAL", "AFF_PROJET", "AFF_REVISA", xFilial("AFF"), cProject, cRev+"' AND AFF_TAREFA = '"+cTask, , cNewTask}) // AFF_FILIAL+AFF_PROJET+AFF_REVISA+AFF_TAREFA+DTOS(AFF_DATA)
aAdd(aCampoTOP, {"AFG", "AFG_TAREFA", "AFG_FILIAL", "AFG_PROJET", "AFG_REVISA", xFilial("AFG"), cProject, cRev+"' AND AFG_TAREFA = '"+cTask, , cNewTask}) // AFG_FILIAL+AFG_PROJET+AFG_REVISA+AFG_TAREFA+AFG_NUMSC+AFG_ITEMSC
aAdd(aCampoTOP, {"AFH", "AFH_TAREFA", "AFH_FILIAL", "AFH_PROJET", "AFH_REVISA", xFilial("AFH"), cProject, cRev+"' AND AFH_TAREFA = '"+cTask, , cNewTask}) // AFH_FILIAL+AFH_PROJET+AFH_REVISA+AFH_TAREFA+AFH_NUMSA+AFH_ITEMSA
aAdd(aCampoTOP, {"AFI", "AFI_TAREFA", "AFI_FILIAL", "AFI_PROJET", "AFI_REVISA", xFilial("AFI"), cProject, cRev+"' AND AFI_TAREFA = '"+cTask, , cNewTask}) // AFI_FILIAL+AFI_PROJET+AFI_REVISA+AFI_TAREFA+AFI_COD+AFI_LOCAL+DTOS(AFI_EMISSA)+AFI_NUMSEQ
aAdd(aCampoTOP, {"AFJ", "AFJ_TAREFA", "AFJ_FILIAL", "AFJ_PROJET", "AFJ_TAREFA", xFilial("AFJ"), cProject, cTask                            , , cNewTask}) // AFJ_FILIAL+AFJ_PROJET+AFJ_TAREFA+AFJ_COD+AFJ_LOCAL
aAdd(aCampoTOP, {"AFL", "AFL_TAREFA", "AFL_FILIAL", "AFL_PROJET", "AFL_REVISA", xFilial("AFL"), cProject, cRev+"' AND AFL_TAREFA = '"+cTask, , cNewTask}) // AFL_FILIAL+AFL_PROJET+AFL_REVISA+AFL_TAREFA+AFL_NUMCP+AFL_ITEMCP
aAdd(aCampoTOP, {"AFM", "AFM_TAREFA", "AFM_FILIAL", "AFM_PROJET", "AFM_REVISA", xFilial("AFM"), cProject, cRev+"' AND AFM_TAREFA = '"+cTask, , cNewTask}) // AFM_FILIAL+AFM_PROJET+AFM_REVISA+AFM_TAREFA+AFM_NUMOP+AFM_ITEMOP+AFM_SEQOP
aAdd(aCampoTOP, {"AFN", "AFN_TAREFA", "AFN_FILIAL", "AFN_PROJET", "AFN_REVISA", xFilial("AFN"), cProject, cRev+"' AND AFN_TAREFA = '"+cTask, , cNewTask}) // AFN_FILIAL+AFN_PROJET+AFN_REVISA+AFN_TAREFA+AFN_DOC+AFN_SERIE+AFN_FORNEC+AFN_LOJA+AFN_ITEM
aAdd(aCampoTOP, {"AFP", "AFP_TAREFA", "AFP_FILIAL", "AFP_PROJET", "AFP_REVISA", xFilial("AFP"), cProject, cRev+"' AND AFP_TAREFA = '"+cTask, , cNewTask}) // AFP_FILIAL+AFP_PROJET+AFP_REVISA+AFP_TAREFA+AFP_ITEM
aAdd(aCampoTOP, {"AFR", "AFR_TAREFA", "AFR_FILIAL", "AFR_PROJET", "AFR_REVISA", xFilial("AFR"), cProject, cRev+"' AND AFR_TAREFA = '"+cTask, , cNewTask}) // AFR_FILIAL+AFR_PROJET+AFR_REVISA+AFR_TAREFA+AFR_PREFIX+AFR_NUM+AFR_PARCEL+AFR_TIPO+AFR_FORNEC+AFR_LOJA
aAdd(aCampoTOP, {"AFS", "AFS_TAREFA", "AFS_FILIAL", "AFS_PROJET", "AFS_REVISA", xFilial("AFS"), cProject, cRev+"' AND AFS_TAREFA = '"+cTask, , cNewTask}) // AFS_FILIAL+AFS_PROJET+AFS_REVISA+AFS_TAREFA+AFS_TRT
aAdd(aCampoTOP, {"AFT", "AFT_TAREFA", "AFT_FILIAL", "AFT_PROJET", "AFT_REVISA", xFilial("AFT"), cProject, cRev+"' AND AFT_TAREFA = '"+cTask, , cNewTask}) // AFT_FILIAL+AFT_PROJET+AFT_REVISA+AFT_TAREFA+AFT_PREFIX+AFT_NUM+AFT_PARCEL+AFT_TIPO+AFT_CLIENT+AFT_LOJA
aAdd(aCampoTOP, {"AFU", "AFU_TAREFA", "AFU_FILIAL", "AFU_CTRRVS", "AFU_PROJET", xFilial("AFU"), "1", cProject+"' AND AFU_REVISA = '"+cRev+"' AND AFU_TAREFA = '"+cTask, , cNewTask}) // AFU_FILIAL+AFU_CTRRVS+AFU_PROJET+AFU_REVISA+AFU_TAREFA+AFU_RECURS+DTOS(AFU_DATA)
aAdd(aCampoTOP, {"AFV", "AFV_TAREFA", "AFV_FILIAL", "AFV_PROJET", "AFV_REVISA", xFilial("AFV"), cProject, SPACE(nTam)+"' AND AFV_TAREFA = '"+cTask, , cNewTask}) // AFV_FILIAL+AFV_PROJET+AFV_REVISA+AFV_TAREFA+AFV_USER
aAdd(aCampoTOP, {"AFZ", "AFZ_TAREFA", "AFZ_FILIAL", "AFZ_PROJET", "AFZ_REVISA", xFilial("AFZ"), cProject, cRev+"' AND AFZ_TAREFA = '"+cTask, , cNewTask}) // AFZ_FILIAL+AFZ_PROJET+AFZ_REVISA+AFZ_TAREFA+DTOS(AFZ_DATA)
aAdd(aCampoTOP, {"AJ4", "AJ4_TAREFA", "AJ4_FILIAL", "AJ4_PROJET", "AJ4_REVISA", xFilial("AJ4"), cProject, cRev+"' AND AJ4_TAREFA = '"+cTask, , cNewTask}) // AJ4_FILIAL+AJ4_PROJET+AJ4_REVISA+AJ4_TAREFA+AJ4_ITEM
aAdd(aCampoTOP, {"AJ5", "AJ5_PREDEC", "AJ5_FILIAL", "AJ5_PROJET", "AJ5_REVISA", xFilial("AJ5"), cProject, cRev+"' AND AJ5_PREDEC = '"+cTask, , cNewTask}) // AJ5_FILIAL+AJ5_PROJET+AJ5_REVISA+AJ5_PREDEC
aAdd(aCampoTOP, {"AJ7", "AJ7_TAREFA", "AJ7_FILIAL", "AJ7_PROJET", "AJ7_REVISA", xFilial("AJ7"), cProject, cRev+"' AND AJ7_TAREFA = '"+cTask, , cNewTask}) // AJ7_FILIAL+AJ7_PROJET+AJ7_REVISA+AJ7_TAREFA+AJ7_NUMPC+AJ7_ITEMPC
aAdd(aCampoTOP, {"AJ9", "AJ9_TAREFA", "AJ9_FILIAL", "AJ9_PROJET", "AJ9_REVISA", xFilial("AJ9"), cProject, cRev+"' AND AJ9_TAREFA = '"+cTask, , cNewTask}) // AJ9_FILIAL+AJ9_PROJET+AJ9_REVISA+AJ9_TAREFA+DTOS(AJ9_DATA)+AJ9_NUMAE+AJ9_IT
aAdd(aCampoTOP, {"AJC", "AJC_TAREFA", "AJC_FILIAL", "AJC_CTRRVS", "AJC_PROJET", xFilial("AJC"), "1", cProject+"' AND AJC_REVISA = '"+cRev+"' AND AJC_TAREFA = '"+cTask, , cNewTask}) // AJC_FILIAL+AJC_CTRRVS+AJC_PROJET+AJC_REVISA+AJC_TAREFA+DTOS(AJC_DATA)
aAdd(aCampoTOP, {"AJD", "AJD_TAREFA", "AJD_FILIAL", "AJD_PROJET", "AJD_REVISA", xFilial("AJD"), cProject, cRev+"' AND AJD_TAREFA = '"+cTask, , cNewTask}) // AJD_FILIAL+AJD_PROJET+AJD_REVISA+AJD_TAREFA+AJD_FILDOC+AJD_DOCTO
aAdd(aCampoTOP, {"AJE", "AJE_TAREFA", "AJE_FILIAL", "AJE_PROJET", "AJE_REVISA", xFilial("AJE"), cProject, cRev+"' AND AJE_TAREFA = '"+cTask, , cNewTask}) // AJE_FILIAL+AJE_PROJET+AJE_REVISA+AJE_TAREFA+DTOS(AJE_DATA)
aAdd(aCampoTOP, {"AFI", "AFI_TAREFA", "AFI_FILIAL", "AFI_PROJET", "AFI_REVISA", xFilial("AFI"), cProject, cRev+"' AND AFI_TAREFA = '"+cTask, , cNewTask}) // AFI_FILIAL+AFI_PROJET+AFI_REVISA+AFI_TAREFA
aAdd(aCampoTOP, {"AJK", "AJK_TAREFA", "AJK_FILIAL", "AJK_PROJET", "AJK_REVISA", xFilial("AJK"), cProject, cRev+"' AND AJK_TAREFA = '"+cTask, , cNewTask}) // AJK_FILIAL+AJK_PROJET+AJK_REVISA+AJK_TAREFA
aAdd(aCampoTOP, {"AEF", "AEF_TAREFA", "AEF_FILIAL", "AEF_PROJET", "AEF_REVISA", xFilial("AEF"), cProject, cRev+"' AND AEF_TAREFA = '"+cTask, , cNewTask}) // AJK_FILIAL+AJK_PROJET+AJK_REVISA+AJK_TAREFA
If lCompUnic
	aAdd(aCampoTOP, {"AEL", "AEL_TAREFA", "AEL_FILIAL", "AEL_PROJET", "AEL_REVISA", xFilial("AEL"), cProject, cRev+"' AND AEL_TAREFA = '"+cTask, , cNewTask}) // AEL_FILIAL+AEL_PROJET+AEL_REVISA+AEL_TAREFA
	aAdd(aCampoTOP, {"AEN", "AEN_TAREFA", "AEN_FILIAL", "AEN_PROJET", "AEN_REVISA", xFilial("AEN"), cProject, cRev+"' AND AEN_TAREFA = '"+cTask, , cNewTask}) // AEN_FILIAL+AEN_PROJET+AEN_REVISA+AEN_TAREFA
EndIf

//Ponto de Entrada para manipulacao do array aCampoDBF
//passado aCampos e aParam contendo os parametros recebidos pela funcao
aParam := { cFil, cProject, cRev, cTask, cNewTask }

If ExistBlock("PM200AF9")
	aCamposUsr := ExecBlock("PM200AF9", .F., .F., {aCampos, aParam})
	AEval( aCamposUsr, { |x| AAdd( aCampoDBF, aClone(x) ) } )
EndIf

PMSAltera({},aCampoDBF)
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥AFCNoIdx ≥ Autor ≥ Adriano Ueda           ≥ Data ≥ 07/06/2005 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥                                                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                              ≥±±
±±≥          ≥                                                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥                                                              ≥±±
±±≥          ≥                                                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SIGAPMS                                                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function AFCNoIdx(cFil, cProject, cRev, cEDT, cNewEDT, aTabelas, aCampoTOP)
Local aCampos    := {}
Local aCamposUsr := {}
Local aCampoDBF  := {} //array para atualizacao em DBF
Default aCampoTOP := {}

If Empty(aTabelas) .Or. AScan(aTabelas,'SD2') > 0
	aAdd(aCampos, {"SD2", "D2_EDTPMS",  "D2_FILIAL + D2_PROJPMS + D2_EDTPMS",  xFilial("SD2") + cProject + cEDT, , cNewEDT})
Endif
If Empty(aTabelas) .Or. AScan(aTabelas,'SC6') > 0
	aAdd(aCampos, {"SC6", "C6_EDTPMS",  "C6_FILIAL + C6_PROJPMS + C6_EDTPMS",  xFilial("SC6") + cProject + cEDT, , cNewEDT})
Endif
If Empty(aTabelas) .Or. AScan(aTabelas,'SC9') > 0
	aAdd(aCampos, {"SC9", "C9_EDTPMS",  "C9_FILIAL + C9_PROJPMS + C9_EDTPMS",  xFilial("SC9") + cProject + cEDT, , cNewEDT})
Endif
If Empty(aTabelas) .Or. AScan(aTabelas,'SCK') > 0
	aAdd(aCampos, {"SCK", "CK_EDTPMS",  "CK_FILIAL + CK_PROJPMS + CK_EDTPMS",  xFilial("SCK") + cProject + cEDT, , cNewEDT})
Endif
If Empty(aTabelas) .Or. AScan(aTabelas,'AJ8') > 0
	aAdd(aCampos, {"AJ8", "AJ8_EDTPMS", "AJ8_FILIAL + AJ8_PROJPM + AJ8_EDTPMS", xFilial("AJ8") + cProject + cEDT, , cNewEDT})
Endif
If Empty(aTabelas) .Or. AScan(aTabelas,'AJA') > 0
	aAdd(aCampos, {"AJA", "AJA_EDT",    "AJA_FILIAL + AJA_PROJET + AJA_EDT",   xFilial("AJA") + cProject + cEDT, , cNewEDT})
Endif

// DbSelectArea para criar as tabelas no banco de dados caso nao existam
If Empty(aTabelas) .Or. AScan(aTabelas,'SD2') > 0
	DbSelectArea("SD2")
	aAdd(aCampoTOP, {"SD2", "D2_EDTPMS",   "D2_FILIAL", "D2_PROJPMS", "D2_EDTPMS", xFilial("SD2"), cProject, cEDT, , cNewEDT})
Endif
If Empty(aTabelas) .Or. AScan(aTabelas,'SC6') > 0
	DbSelectArea("SC6")
	aAdd(aCampoTOP, {"SC6", "C6_EDTPMS",   "C6_FILIAL", "C6_PROJPMS", "C6_EDTPMS", xFilial("SC6"), cProject, cEDT, , cNewEDT})
Endif
If Empty(aTabelas) .Or. AScan(aTabelas,'SC9') > 0
	DbSelectArea("SC9")
	aAdd(aCampoTOP, {"SC9", "C9_EDTPMS",   "C9_FILIAL", "C9_PROJPMS", "C9_EDTPMS", xFilial("SC9"), cProject, cEDT, , cNewEDT})
Endif
If Empty(aTabelas) .Or. AScan(aTabelas,'SCK') > 0
	DbSelectArea("SCK")
	aAdd(aCampoTOP, {"SCK", "CK_EDTPMS",   "CK_FILIAL", "CK_PROJPMS", "CK_EDTPMS", xFilial("SCK"), cProject, cEDT, , cNewEDT})
Endif
If Empty(aTabelas) .Or. AScan(aTabelas,'AJ8') > 0
	DbSelectArea("AJ8")
	aAdd(aCampoTOP, {"AJ8", "AJ8_EDTPMS", "AJ8_FILIAL", "AJ8_PROJPM", "AJ8_EDTPMS", xFilial("AJ8"), cProject, cEDT, , cNewEDT})
Endif
If Empty(aTabelas) .Or. AScan(aTabelas,'AJA') > 0
	DbSelectArea("AJA")
	aAdd(aCampoTOP, {"AJA", "AJA_EDT",    "AJA_FILIAL", "AJA_PROJET", "AJA_EDT",   xFilial("AJA"), cProject, cEDT, , cNewEDT})
Endif

PMSAltera(@aCampoTOP,{})

//Ponto de Entrada para manipulacao do array aCampos
//passado aCampos e aParam contendo os parametros recebidos pela funcao
aParam := { cFil, cProject, cRev, cEDT, cNewEDT }

If ExistBlock("P200AFC2")
	aCamposUsr := ExecBlock("P200AFC2", .F., .F., {aCampos, aParam})
	AEval( aCamposUsr, { |x| AAdd( aCampoDBF, aClone(x) ) } )
EndIf

PMSNoIdx(aCampoDBF)

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥AF9NoIdx ≥ Autor ≥ Adriano Ueda           ≥ Data ≥ 03/06/2005 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥                                                              ≥±±
±±≥          ≥                                                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                              ≥±±
±±≥          ≥                                                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥                                                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SIGAPMS                                                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function AF9NoIdx(cFil, cProject, cRev, cTask, cNewTask,aTabelas, aCampoTOP)
Local aCampos    := {}
Local aCamposUsr := {}
Local aCampoDBF  := {} //array para atualizacao em DBF
Default aCampoTOP := {}

If Empty(aTabelas) .Or. AScan(aTabelas,'SD2') > 0
	aAdd(aCampos, {"SD2", "D2_TASKPMS",  "D2_FILIAL + D2_PROJPMS + D2_TASKPMS", xFilial("SD2") + cProject + cTask, , cNewTask})
Endif
If Empty(aTabelas) .Or. AScan(aTabelas,'SD3') > 0
	aAdd(aCampos, {"SD3", "D3_TASKPMS",  "D3_FILIAL + D3_PROJPMS + D3_TASKPMS", xFilial("SD3") + cProject + cTask, , cNewTask})
Endif
If Empty(aTabelas) .Or. AScan(aTabelas,'SC6') > 0
	aAdd(aCampos, {"SC6", "C6_TASKPMS",  "C6_FILIAL + C6_PROJPMS + C6_TASKPMS", xFilial("SC6") + cProject + cTask, , cNewTask})
Endif
If Empty(aTabelas) .Or. AScan(aTabelas,'SC9') > 0
	aAdd(aCampos, {"SC9", "C9_TASKPMS",  "C9_FILIAL + C9_PROJPMS + C9_TASKPMS", xFilial("SC9") + cProject + cTask, , cNewTask})
Endif
If Empty(aTabelas) .Or. AScan(aTabelas,'SCK') > 0
	aAdd(aCampos, {"SCK", "CK_TASKPMS",  "CK_FILIAL + CK_PROJPMS + CK_TASKPMS", xFilial("SCK") + cProject + cTask, , cNewTask})
Endif
If Empty(aTabelas) .Or. AScan(aTabelas,'AJ8') > 0
	aAdd(aCampos, {"AJ8", "AJ8_TASKPM", "AJ8_FILIAL + AJ8_PROJPM + AJ8_TASKPM", xFilial("AJ8") + cProject + cTask, , cNewTask})
Endif
If Empty(aTabelas) .Or. AScan(aTabelas,'AJA') > 0
	aAdd(aCampos, {"AJA", "AJA_TAREFA", "AJA_FILIAL + AJA_PROJET + AJA_TAREFA", xFilial("AJA") + cProject + cTask, , cNewTask})
Endif
If Empty(aTabelas) .Or. AScan(aTabelas,'AJK') > 0
	aAdd(aCampos, {"AJK", "AJK_TAREFA", "AJK_FILIAL + AJK_PROJET + AJK_TAREFA", xFilial("AJK") + cProject + cTask, , cNewTask})
Endif
// DbSelectArea para criar as tabelas no banco de dados caso nao existam
If Empty(aTabelas) .Or. AScan(aTabelas,'SD2') > 0
	DbSelectArea("SD2")
	aAdd(aCampoTOP, {"SD2", "D2_TASKPMS",  "D2_FILIAL", "D2_PROJPMS", "D2_TASKPMS", xFilial("SD2"), cProject, cTask, , cNewTask})
Endif
If Empty(aTabelas) .Or. AScan(aTabelas,'SD3') > 0
	DbSelectArea("SD3")
	aAdd(aCampoTOP, {"SD3", "D3_TASKPMS",  "D3_FILIAL", "D3_PROJPMS", "D3_TASKPMS", xFilial("SD3"), cProject, cTask, , cNewTask})
Endif
If Empty(aTabelas) .Or. AScan(aTabelas,'SC6') > 0
	DbSelectArea("SC6")
	aAdd(aCampoTOP, {"SC6", "C6_TASKPMS",  "C6_FILIAL", "C6_PROJPMS", "C6_TASKPMS", xFilial("SC6"), cProject, cTask, , cNewTask})
Endif
If Empty(aTabelas) .Or. AScan(aTabelas,'SC9') > 0
	DbSelectArea("SC9")
	aAdd(aCampoTOP, {"SC9", "C9_TASKPMS",  "C9_FILIAL", "C9_PROJPMS", "C9_TASKPMS", xFilial("SC9"), cProject, cTask, , cNewTask})
Endif
If Empty(aTabelas) .Or. AScan(aTabelas,'SCK') > 0
	DbSelectArea("SCK")
	aAdd(aCampoTOP, {"SCK", "CK_TASKPMS",  "CK_FILIAL", "CK_PROJPMS", "CK_TASKPMS", xFilial("SCK"), cProject, cTask, , cNewTask})
Endif
If Empty(aTabelas) .Or. AScan(aTabelas,'AJ8') > 0
	DbSelectArea("AJ8")
	aAdd(aCampoTOP, {"AJ8", "AJ8_TASKPM", "AJ8_FILIAL", "AJ8_PROJPM", "AJ8_TASKPM", xFilial("AJ8"), cProject, cTask, , cNewTask})
Endif
If Empty(aTabelas) .Or. AScan(aTabelas,'AJA') > 0
	DbSelectArea("AJA")
	aAdd(aCampoTOP, {"AJA", "AJA_TAREFA", "AJA_FILIAL", "AJA_PROJET", "AJA_TAREFA", xFilial("AJA"), cProject, cTask, , cNewTask})
Endif
If Empty(aTabelas) .Or. AScan(aTabelas,'AJK') > 0
	DbSelectArea("AJK")
	aAdd(aCampoTOP, {"AJK", "AJK_TAREFA", "AJK_FILIAL", "AJK_PROJET", "AJK_TAREFA", xFilial("AJK"), cProject, cTask, , cNewTask})
Endif
//Ponto de Entrada para manipulacao do array aCampos
//passado aCampos e aParam contendo os parametros recebidos pela funcao
aParam := { cFil, cProject, cRev, cTask, cNewTask }

If ExistBlock("P200AF92")
	aCamposUsr := ExecBlock("P200AF92", .F., .F., {aCampos, aParam})
	AEval( aCamposUsr, { |x| AAdd( aCampoTOP , aClone(x) ) } )
EndIf
PMSAltera(@aCampoTOP,{})

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥PMSNoIdx ≥ Autor ≥ Adriano Ueda           ≥ Data ≥ 03/06/2005 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥                                                              ≥±±
±±≥          ≥                                                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                              ≥±±
±±≥          ≥                                                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥                                                              ≥±±
±±≥          ≥                                                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SIGAPMS                                                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PMSNoIdx(aCampos)
Local cTempFilename := CriaTrab(Nil, .F.)
Local nIndex := 0

Local cAlias := ""
Local cField := ""
Local cIndex := ""
Local cValue := ""
Local cCode  := ""

Local nRecno  := 0
Local nRecAnt := 0

Local i := 0

Local aArea := Nil

// cria os indices
For i := 1 To Len(aCampos)
	cAlias := aCampos[i][1]
	cField := aCampos[i][2]
	cIndex := aCampos[i][3]
	cValue := aCampos[i][4]
	cCode  := aCampos[i][6]

	dbSelectArea(cAlias)
	aArea := (cAlias)->(GetArea())
	IndRegua(cAlias, cTempFilename, cIndex, ,	)
	nIndex := RetIndex(cAlias)
	(cAlias)->(dbSetIndex(cTempFilename + OrdBagExt()))
	(cAlias)->(dbSetOrder(nIndex + 1))

	(cAlias)->(MsSeek(cValue))

	While !(cAlias)->(Eof()) .And. &(cIndex) == cValue

		// salva a recno atual
		nRecAnt := (cAlias)->(Recno())

		// salva o prÛximo recno
		(cAlias)->(dbSkip())
		nRecno := (cAlias)->(Recno())

		// restaura o recno atual
		(cAlias)->(dbGoto(nRecAnt))

		// altera o cÛdigo da tarefa
		Reclock(cAlias, .F.)
		(cAlias)->(FieldPut((cAlias)->(FieldPos(cField)), cCode))
		MsUnlock()

		// vai para o prÛximo registro
		(cAlias)->(dbGoto(nRecno))
	End

	// deleta os indices
	dbSelectArea(cAlias)
	RetIndex(cAlias)
	dbClearFilter()
	FErase(cTempFilename + OrdBagExt())

	(cAlias)->(RestArea(aArea))
Next i
Return


Function PMSNoIdxTop(aCampos)
	Local cSQL := ""
	Local i    := 0

	Local cAlias := ""
	Local cField := ""

	Local cIdx1 := ""
	Local cIdx2 := ""
	Local cIdx3 := ""

	Local cVal1 := ""
	Local cVal2 := ""
	Local cVal3 := ""

	Local cCode  := ""

	For i := 1 To Len(aCampos)

		cAlias := aCampos[i][1]
		cField := aCampos[i][2]

		cIdx1 := aCampos[i][3]
		cIdx2 := aCampos[i][4]
		cIdx3 := aCampos[i][5]

		cVal1 := aCampos[i][6]
		cVal2 := aCampos[i][7]
		cVal3 := aCampos[i][8]

		cCode := aCampos[i][10]

		cSQL := "UPDATE " + RetSqlName(cAlias) + " "
		cSQL += "SET " + cField + " = '" + cCode + "' "
		cSQL += "WHERE "
		cSQL += cIdx1 + " = '" + cVal1 + "' AND "
		cSQL += cIdx2 + " = '" + cVal2 + "' AND "
		cSQL += cIdx3 + " = '" + cVal3 + "' AND "
		cSQL += "D_E_L_E_T_ = ' '"

		TcSqlExec(cSQL)
	Next
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥PMSAltera≥ Autor ≥ Adriano Ueda           ≥ Data ≥ 03/06/2005                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥                                                                                ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥aCampoTop : array com os campos e valores que serao atualizados por update(Top) ≥±±
±±≥          ≥aCampoDBF : array com os campos e valores que serao atualizados por CodeBase    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥                                                                                ≥±±
±±≥          ≥                                                                                ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SIGAPMS                                                                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PMSAltera(aCampoTOP,aCampoDBF)
Local i        := 0
Local cAlias   := ""
Local nIndex   := 1
Local cPar     := ""
Local cField   := ""
Local cIndex   := ""
Local cCode    := ""
Local nRecno   := 0
Local nRecAnt  := 0
Local aArea    := Nil
Local aAreaAtu := GetArea()
Local aAreaSX2 := SX2->(GetArea())
Local aAreaAFC := AFC->(GetArea())
Local aAreaAF9 := AF9->(GetArea())

Default aCampoDBF := {}
Default aCampoTOP := {}

aAreaAFC := AFC->(GetArea())
aAreaAF9 := AF9->(GetArea())

PMSNoIdxTop(aCampoTOP)
aCampoTOP := {}

//apos atualizacao por TcSQLExec, o registro posicionado NAO EH atualizado no Protheus
//a atualizacao eh realizada desposicionando o registro e recuperando a posicao
AFC->(DbGoTop())
AF9->(DbGoTop())
RestArea(aAreaAFC)
RestArea(aAreaAF9)

// array com dados DBF e dados dos pontos de entradas PM200AF5,PM200AF2,PM200AFC,PM200AF9
For i := 1 To Len(aCampoDBF)

	cAlias := aCampoDBF[i][1]
	nIndex := aCampoDBF[i][2]
	cPar   := aCampoDBF[i][3]
	cField := aCampoDBF[i][4]
	cIndex := aCampoDBF[i][5]
	cCode  := aCampoDBF[i][6]

	If SX2->(! dbSeek(cAlias))
		Loop
	EndIf

	dbSelectArea(cAlias)
	aArea := (cAlias)->(GetArea())
	(cAlias)->(dbSetOrder(nIndex))

	(cAlias)->(MsSeek(cIndex))

	While !(cAlias)->(Eof()) .And. &(cPar) == cIndex

		// salva a recno atual
		nRecAnt := (cAlias)->(Recno())

		// salva o prÛximo recno
		(cAlias)->(dbSkip())
		nRecno := (cAlias)->(Recno())

		// restaura o recno atual
		(cAlias)->(dbGoto(nRecAnt))

		// altera o cÛdigo da tarefa
		Reclock(cAlias, .F.)
		(cAlias)->(FieldPut((cAlias)->(FieldPos(cField)), cCode))
		MsUnlock()

		// vai para o prÛximo registro
		(cAlias)->(dbGoto(nRecno))
	EndDo

	(cAlias)->(RestArea(aArea))
Next i

RestArea(aAreaSX2)
RestArea(aAreaAtu)

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥PmsLoadEDT≥ Autor ≥ Marcelo Akama          ≥ Data ≥ 12/01/2009                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Carrega as EDT's pais ou filhas no Array de retorno                             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ cProjeto - Codigo do projeto(caracter)                                          ≥±±
±±≥          ≥ cRevisa - Versao do projeto(caracter)                                           ≥±±
±±≥          ≥ cSeekEDT - Codigo da EDT(caracter)                                              ≥±±
±±≥          ≥ lInferior - Se busca as EDT's filhas (.T.) ou pais (.F.) (Opcional,default=.T.) ≥±±
±±≥          ≥ lSelf - Inclui a EDT em cSeekED (.T.) ou n„o (.F.) (Opcional,default=.F.)       ≥±±
±±≥          ≥ aSelectEDT - Codigo das EDT's filhas/pais da EDT (retorno)                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥ .T.                                                                             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SIGAPMS                                                                         ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ‹ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PmsLoadEDT(cProjeto, cRevisa, cSeekEDT, lInferior, lSelf, aSelectEDT)
Local aAreaAF8 	:= AF8->(GetArea())
Local aAreaAFC 	:= AFC->(GetArea())

If ValType(lInferior) <> 'L'
	lInferior := .T.
EndIf

If ValType(lSelf) <> 'L'
	lSelf := .F.
EndIf

//posicionar no projeto
dbSelectArea("AF8")
dbSetOrder(1)
If dbSeek(xFilial("AF8")+cProjeto)
	dbSelectArea("AFC")
	dbSetOrder(1)
	If dbSeek(xFilial()+cProjeto+cRevisa+cSeekEDT)
		If lSelf .and. ASCAN(aSelectEDT, AFC->AFC_EDT) == 0
			AADD(aSelectEDT, {AFC->AFC_EDT, AFC->AFC_NIVEL})
		EndIf
		If lInferior
			dbSetOrder(2)
			dbSeek(xFilial()+cProjeto+cRevisa+cSeekEDT)
			Do While !AFC->(Eof()) .and. xFilial()+cProjeto+cRevisa+cSeekEDT == ;
					 AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDTPAI
				If ASCAN(aSelectEDT, AFC->AFC_EDT) == 0
					AADD(aSelectEDT, {AFC->AFC_EDT, AFC->AFC_NIVEL})
				EndIf
				PMSLoadEDT(cProjeto, cRevisa, AFC->AFC_EDT, lInferior, .F., @aSelectEDT)
				AFC->(DbSkip())
			EndDo
		Else
			Do while !empty(AFC->AFC_EDTPAI) .and. dbSeek(xFilial()+cProjeto+cRevisa+AFC->AFC_EDTPAI)
				If ASCAN(aSelectEDT, AFC->AFC_EDT) == 0
					AADD(aSelectEDT, {AFC->AFC_EDT, AFC->AFC_NIVEL})
				EndIf
			EndDo
		EndIf
	EndIf
EndIf

RestArea(aAreaAF8)
RestArea(aAreaAFC)

Return .T.


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥PmsEDTPrv ≥ Autor ≥ Marcelo Akama          ≥ Data ≥ 12/01/2009                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Atualiza as datas de inÌcio e fim, hora de inicio e fim, horas uteis e duracao  ≥±±
±±≥          ≥ que  estao  previstas  para  a  EDT  atraves  das  tarefas  e EDT  que  compoe  ≥±±
±±≥          ≥ Consequentemente, seus eventos e predecessores associados                       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ cProjeto - Codigo do projeto(caracter)                                          ≥±±
±±≥          ≥ cRevisa - Versao do projeto(caracter)                                           ≥±±
±±≥          ≥ cEDTPai - Codigo da EDT(caracter)                                               ≥±±
±±≥          ≥ aAtuEDT - Array com os codigos das EDT's selecionadas                           ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥                                                                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SIGAPMS                                                                         ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ‹ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PmsEdtPrv(cProjeto, cRevisa, cEDTPai, aAtuEDT)
Local aAreaAF8 := AF8->(GetArea())
Local aAreaAF9 := AF9->(GetArea())
Local aAreaAFC := AFC->(GetArea())
Local aAreaAFP := AFP->(GetArea())
Local nCount
Local cSeekEDT
Local dStart
Local cHoraI
Local dFinish
Local cHoraF
Local nHrUteis
Local nDurac
Local lMin
Local lMax
Local lAF9_HESF := .F.
Local lAFC_HESF := .F.
Local nHrEsforco := 0

Local lSQL   := Upper(TcSrvType()) != "AS/400" .and. Upper(TcSrvType()) != "ISERIES"
Local cOper  := IIf(Upper(TcGetDb())$'ORACLE.POSTGRES.DB2.INFORMIX','||','+')
Local cProc  := 'PMS200_'+CriaTrab(nil,.F.)
Local cSQL   := ''
Local cRet   := 1
Local lRet   :=.t.
Local aResult:={}

Local cAF9:=RetSQLName("AF9")
Local cAFC:=RetSQLName("AFC")

DEFAULT aAtuEDT := {}

dbSelectArea("AF9")
lAF9_HESF := AF9->(FieldPos("AF9_HESF"))>0
dbSelectArea("AFC")
lAFC_HESF := AFC->(FieldPos("AFC_HESF"))>0

//posicionar no projeto
dbSelectArea("AF8")
dbSetOrder(1)
If dbSeek(xFilial("AF8")+cProjeto)
	dbSelectArea("AFC")
	dbSetOrder(1)
	If dbSeek(xFilial()+cProjeto+cRevisa+cEDTPai)
		If Empty(aAtuEDT)
			// obtem todas edts filhas da edt informada mais a edt informada
			PMSLoadEDT( cProjeto, cRevisa, AFC->AFC_EDT, .T., .T., @aAtuEDT )
			// obtem todas edts pai que se referem a edt informada
			PMSLoadEDT( cProjeto, cRevisa, AFC->AFC_EDT, .F., .F., @aAtuEDT )

			aSort(aAtuEDT,,, {|x, y| y[2] < x[2] })
		End If

		If lSQL
			cSQL:=cSQL+"create procedure "+cProc+" ("+CRLF
			cSQL:=cSQL+"	@IN_PROJETO	varchar(255),"+CRLF
			cSQL:=cSQL+"	@IN_REVISAO	varchar(255),"+CRLF
			cSQL:=cSQL+"	@IN_EDT		varchar(255),"+CRLF
			cSQL:=cSQL+"	@OUT_DTINI	varchar(8)	output,"+CRLF
			cSQL:=cSQL+"	@OUT_HRINI	varchar(5)	output,"+CRLF
			cSQL:=cSQL+"	@OUT_DTFIM	varchar(8)	output,"+CRLF
			cSQL:=cSQL+"	@OUT_HRFIM	varchar(5)	output,"+CRLF
			cSQL:=cSQL+"	@OUT_HUTEIS Float output,"   +CRLF
			cSQL:=cSQL+"	@OUT_HESFORCO Float output,"+CRLF
			cSQL:=cSQL+"	@OUT_RET	int			output"+CRLF
			cSQL:=cSQL+") as"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"declare @fim_CUR	int			-- Indica fim do cursor no DB2"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"select @OUT_RET=0"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"declare @INICIO	 varchar(20)"+CRLF
			cSQL:=cSQL+"declare @FIM     varchar(20)"+CRLF
			cSQL:=cSQL+"declare @INICIO2 varchar(20)"+CRLF
			cSQL:=cSQL+"declare @FIM2	 varchar(20)"+CRLF
			cSQL:=cSQL+"declare @HUTEIS2 Float "+CRLF
			cSQL:=cSQL+"declare @OUT_HESFORCO2 Float "+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"select @OUT_HUTEIS=null, @INICIO=null, @FIM=null, @INICIO2=null, @FIM2=null, @HUTEIS2=null, @OUT_HESFORCO=null "+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"select @OUT_HUTEIS=sum(AFC_HUTEIS), @INICIO=min(AFC_START "+cOper+" AFC_HORAI), @FIM=max(AFC_FINISH "+cOper+" AFC_HORAF)"+CRLF
			If lAFC_HESF
				cSQL:=cSQL+",@OUT_HESFORCO=SUM(AFC_HESF) "+CRLF
			EndIf
			cSQL:=cSQL+" from "+cAFC+CRLF
			cSQL:=cSQL+" where AFC_FILIAL = '"+xFilial()+"'"+CRLF
			cSQL:=cSQL+" and AFC_PROJET = @IN_PROJETO"+CRLF
			cSQL:=cSQL+" and AFC_REVISA = @IN_REVISAO"+CRLF
			cSQL:=cSQL+" and AFC_EDTPAI = @IN_EDT"+CRLF
			cSQL:=cSQL+" and AFC_START <> ' '"+CRLF
			cSQL:=cSQL+" and D_E_L_E_T_ <> '*'"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"select @OUT_HUTEIS=isnull(@OUT_HUTEIS,0), @INICIO=isnull(@INICIO,'        00:00'), @FIM=isnull(@FIM,'        00:00'), @OUT_HESFORCO=isnull(@OUT_HESFORCO,0) "+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"select @HUTEIS2=sum(AF9_HUTEIS), @INICIO2=min(AF9_START "+cOper+" AF9_HORAI), @FIM2=max(AF9_FINISH "+cOper+" AF9_HORAF)"+CRLF
			If lAF9_HESF
				cSQL:=cSQL+",@OUT_HESFORCO2=SUM(AF9_HESF) "+CRLF
			EndIf
			cSQL:=cSQL+" from "+cAF9+CRLF
			cSQL:=cSQL+" where AF9_FILIAL = '"+xFilial()+"'"+CRLF
			cSQL:=cSQL+" and AF9_PROJET = @IN_PROJETO"+CRLF
			cSQL:=cSQL+" and AF9_REVISA = @IN_REVISAO"+CRLF
			cSQL:=cSQL+" and AF9_EDTPAI = @IN_EDT"+CRLF
			cSQL:=cSQL+" and AF9_START <> ' '"+CRLF
			cSQL:=cSQL+" and D_E_L_E_T_ <> '*'"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"select @HUTEIS2=isnull(@HUTEIS2,0), @INICIO2=isnull(@INICIO2,'        00:00'), @FIM2=isnull(@FIM2,'        00:00'), @OUT_HESFORCO2=isnull(@OUT_HESFORCO2,0) "+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"select @OUT_HUTEIS=@OUT_HUTEIS+@HUTEIS2"+CRLF
			cSQL:=cSQL+"if (@INICIO2 = '        00:00') select @INICIO2=@INICIO"+CRLF
    		cSQL:=cSQL+"if (@INICIO = '        00:00' or @INICIO2<@INICIO) select @INICIO=@INICIO2"+CRLF
			cSQL:=cSQL+"if (@FIM2 = '        00:00') select @FIM2=@FIM"+CRLF
    		cSQL:=cSQL+"if (@FIM = '        00:00' or @FIM2>@FIM) select @FIM=@FIM2"+CRLF
			cSQL:=cSQL+"select @OUT_HESFORCO=@OUT_HESFORCO+@OUT_HESFORCO2"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"select @OUT_DTINI=substring(@INICIO,1,8)"+CRLF
			cSQL:=cSQL+"select @OUT_HRINI=substring(@INICIO,9,5)"+CRLF
			cSQL:=cSQL+"select @OUT_DTFIM=substring(@FIM,1,8)"+CRLF
			cSQL:=cSQL+"select @OUT_HRFIM=substring(@FIM,9,5)"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"select @OUT_RET=1"+CRLF

			cSQL:=MsParse(cSQL,Alltrim(TcGetDB()))

			If cSQL=''
				If !__lBlind
 					MsgAlert(STR0260+" "+cProc+": "+MsParseError())  //'Erro criando a Stored Procedure:'
				EndIf
			Else

				cSQL:=PmsA200Fix(cSQL, Alltrim(TcGetDB()))
				If Upper(TcGetDb())$'DB2.INFORMIX.ORACLE'
					cSQL:=StrTran(cSQL,"MIN ( AFC_START  || AFC_HORAI ), AFC_HORAI","MIN ( AFC_START  || AFC_HORAI )")
					cSQL:=StrTran(cSQL,"MAX ( AFC_FINISH  || AFC_HORAF ), AFC_HORAF","MAX ( AFC_FINISH  || AFC_HORAF )")
					cSQL:=StrTran(cSQL,"MIN ( AF9_START  || AF9_HORAI ), AF9_HORAI","MIN ( AF9_START  || AF9_HORAI )")
					cSQL:=StrTran(cSQL,"MAX ( AF9_FINISH  || AF9_HORAF ), AF9_HORAF","MAX ( AF9_FINISH  || AF9_HORAF )")
				EndIf

				cRet:=TcSqlExec(cSQL)
				If cRet <> 0
					If !__lBlind
	 					MsgAlert(STR0260+" "+cProc+": "+TCSqlError())  //'Erro criando a Stored Procedure:'
					EndIf
					lRet := .f.
				EndIf
			EndIf

		EndIf

		If cRet=0
			For nCount := 1 to len(aAtuEDT)
				cSeekEDT := aAtuEDT[nCount][1]
				dStart   := PMS_MAX_DATE
				cHoraI   := PMS_MAX_HOUR
				dFinish  := PMS_MIN_DATE
				cHoraF   := PMS_MIN_HOUR
				lMin     := .F.
				lMax     := .F.

				If lSQL
					aResult := TCSPExec( cProc, cProjeto, cRevisa, cSeekEDT)
					If empty(aResult)
						If !__lBlind
							MsgAlert(STR0261+" "+cProc+": "+TCSqlError())  //'Erro executando a Stored Procedure'
						EndIf
						lRet := .f.
					ElseIf aResult[7] != 1
						If !__lBlind
							MsgAlert(STR0261+": "+TCSqlError())   //'Erro executando a Stored Procedure'
						EndIf
						lRet := .f.
					Else
						dStart   := STOD(aResult[1])
						cHoraI   := aResult[2]
						dFinish  := STOD(aResult[3])
						cHoraF   := aResult[4]
						nHrUteis := aResult[5]
						nHrEsforco := aResult[6]
						lMin     := !Empty(aResult[1])
						lMax     := !Empty(aResult[3])
					EndIf
				Else
					nHrUteis := 0
					nHrEsforco := 0
					dbSelecTArea("AF9")
					dbSetOrder(2)
					dbSeek(xFilial("AF9") + cProjeto + cRevisa + cSeekEDT)
					Do While !AF9->(Eof()) .And. AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_EDTPAI==;
										  xFilial("AF9")+cProjeto+cRevisa+cSeekEDT
						If DTOS(dStart)+cHoraI > DTOS(AF9->AF9_START)+AF9->AF9_HORAI .and. !empty(AF9->AF9_START)
							dStart := AF9->AF9_START
							cHoraI := AF9->AF9_HORAI
							lMin   := .T.
						EndIf
						If DTOS(dFinish)+cHoraF < DTOS(AF9->AF9_FINISH)+AF9->AF9_HORAF .and. !empty(AF9->AF9_FINISH)
							dFinish := AF9->AF9_FINISH
							cHoraF  := AF9->AF9_HORAF
							lMax    := .T.
						EndIf
						nHrUteis := nHrUteis + AF9->AF9_HUTEIS
						If lAF9_HESF
							nHrEsforco := nHrEsforco + AF9->AF9_HESF
						EndIf
						AF9->(DbSkip())
					End Do

					dbSelecTArea("AFC")
					dbSetOrder(2)
					dbSeek(xFilial("AFC") + cProjeto + cRevisa + cSeekEDT)
					Do While !AFC->(Eof()) .And. AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDTPAI==;
										  xFilial("AFC")+cProjeto+cRevisa+cSeekEDT
						If DTOS(dStart)+cHoraI > DTOS(AFC->AFC_START)+AFC->AFC_HORAI .and. !empty(AFC->AFC_START)
							dStart := AFC->AFC_START
							cHoraI := AFC->AFC_HORAI
							lMin   := .T.
						EndIf
						If DTOS(dFinish)+cHoraF < DTOS(AFC->AFC_FINISH)+AFC->AFC_HORAF .and. !empty(AFC->AFC_FINISH)
							dFinish := AFC->AFC_FINISH
							cHoraF  := AFC->AFC_HORAF
							lMax    := .T.
						EndIf
						nHrUteis := nHrUteis + AFC->AFC_HUTEIS
						If lAFC_HESF
							nHrEsforco := nHrEsforco + AFC->AFC_HESF
						EndIf

						AFC->(DbSkip())
					EndDo
				EndIf

				dbSelecTArea("AFC")
				dbSetOrder(1)
				dbSeek(xFilial("AFC") + cProjeto + cRevisa + cSeekEDT)
				If dStart <> AFC->AFC_START .or. cHoraI <> AFC->AFC_HORAI .or. dFinish <> AFC->AFC_FINISH;
											.or. cHoraF <> AFC->AFC_HORAF .or. nHrUteis <> AFC->AFC_HUTEIS
					// exclui os eventos da EDT
					dbSelectArea("AFP")
					dbSetOrder(2)
					MsSeek(xFilial()+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT)
					Do While !AFP->(Eof()) .And. xFilial()+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT==;
										AFP->AFP_FILIAL+AFP->AFP_PROJET+AFP->AFP_REVISA+AFP->AFP_EDT
						PMSAvalAFP("AFP",3,2)
						AFP->(DbSkip())
					EndDo

					dStart  := IIf(lMin, dStart , PMS_EMPTY_DATE)
					cHoraI  := IIf(lMin, cHoraI , '00:00')
					dFinish := IIf(lMax, dFinish, PMS_EMPTY_DATE)
					cHoraF  := IIf(lMax, cHoraF , '00:00')

					If !Empty(dStart) .And. !Empty(dFinish)
						nDurac:=PmsHrsItvl(dStart,cHoraI,dFinish,cHoraF,AFC->AFC_CALEND,cProjeto)
					Else
						nDurac:=0
					EndIf

					dbSelecTArea("AFC")

					Reclock('AFC', .F.)
					AFC->AFC_START  := dStart
					AFC->AFC_HORAI  := cHoraI
					AFC->AFC_FINISH := dFinish
					AFC->AFC_HORAF  := cHoraF
					AFC->AFC_HUTEIS := nHrUteis
					AFC->AFC_HDURAC := nDurac
					If lAFC_HESF
						AFC->AFC_HESF := nHrEsforco
					EndIf

					MsUnlock()

					// inclui os eventos da EDT
					dbSelectArea("AFP")
					dbSetOrder(2)
					MsSeek(xFilial()+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT)
					Do While !AFP->(Eof()) .And. xFilial()+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT==;
										AFP_FILIAL+AFP_PROJET+AFP_REVISA+AFP_EDT
						PMSAvalAFP("AFP",1,2)

						AFP->(DbSkip())
					EndDo

					// atualiza as predecessoras da EDT
					PmsAtuScsE(AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_EDT,.F.)
				EndIf

				If AFC->AFC_NIVEL == '001'
					Reclock('AF8', .F.)
					AF8_START  := AFC->AFC_START
					AF8_FINISH := AFC->AFC_FINISH
					MsUnlock()
				EndIf
			Next nCount

			If lSQL
				If TcSqlExec('DROP PROCEDURE '+cProc)<>0
					If !__lBlind
						MsgAlert(STR0263+" "+cProc+": "+TCSqlError())   //'Erro excluindo procedure'
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaAF8)
RestArea(aAreaAF9)
RestArea(aAreaAFC)


RestArea(aAreaAFP)

Return


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥PmsEDTReal≥ Autor ≥ Marcelo Akama          ≥ Data ≥ 12/01/2009                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Atualiza as datas de inÌcio e fim, hora de inicio e fim, horas uteis e duracao  ≥±±
±±≥          ≥ que   foram  realizadas  na   EDT  atraves  das  tarefas  e   EDT  que  compoe  ≥±±
±±≥          ≥ Consequentemente, seus eventos associados                                       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ cProjeto - Codigo do projeto(caracter)                                          ≥±±
±±≥          ≥ cRevisa - Versao do projeto(caracter)                                           ≥±±
±±≥          ≥ cEDTPai - Codigo da EDT(caracter)                                               ≥±±
±±≥          ≥ aAtuEDT - Array com os codigos das EDT's selecionadas                           ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥                                                                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SIGAPMS                                                                         ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ‹ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PMSEdtReal(cProjeto, cRevisa, cEDTPai, aAtuEDT)
Local aAreaAF8 := AF8->(GetArea())
Local aAreaAF9 := AF9->(GetArea())
Local aAreaAFC := AFC->(GetArea())
Local aAreaAFF := AFF->(GetArea())
Local aAreaAFQ := AFQ->(GetArea())
Local aEDTsPai
Local nCount
Local cSeekEDT
Local dDtAtuI
Local nHrUteis
Local lEDTPrincipal
Local lMileStone
Local nTotMileStone
Local nTotTasks
Local nPercExec
Local nPercMile
Local aTaskFilho
Local aEDTFilho
Local aAFQDatas
Local aAFQUpdate
Local nPosData
Local nCnt2
Local aDatasReal
Local lMin

Local lMax
Local nCol
Local nQtTot
Local nTot
Local nFator
Local nPos

Local cFilAFQ := xFilial("AFQ")
Local cFilAFC := xFilial("AFC")
Local cFilAF9 := xFilial("AF9")
Local cFilAFF := xFilial("AFF")

Local lSQL   := Upper(TcSrvType()) != "AS/400" .and. Upper(TcSrvType()) != "ISERIES"
Local cOper  := ""
Local cProc  := ""
Local cSQL   := ""
Local nRet   := 0
Local lRet   := .F.
Local aResult:= {}

Local cPrecisao:= ""

Local cAF8 :=""
Local cAF9 :=""
Local cAFC :=""
Local cAFF :=""
Local cAFQ :=""
Local cTmp2:=""

Local lExecProc := .F.

DEFAULT aAtuEDT := {}

// se o base de dados for TOP e n„o esta dentro de uma transacao (BEGIN/END TRANSACTION) 
// executa a procedure. Isso È necessario, pois para executar a procedure È necessario criar uma
// tabela no banco antes de executar a procedure e depois excluir. Porem dentro de uma transacao, 
// o banco nao permite excluir a tabela.
//
lExecProc := lSQL .and. !InTransact()

//posicionar no projeto
dbSelectArea("AF8")
dbSetOrder(1)
If dbSeek(xFilial("AF8")+cProjeto)
	dbSelectArea("AFC")
	dbSetOrder(1)
	If dbSeek(cFilAFC+cProjeto+cRevisa+cEDTPai)
		If Empty(aAtuEDT)
			// obtem todas edts filhas da edt informada mais a edt informada
			PMSLoadEDT( cProjeto, cRevisa, AFC->AFC_EDT, .T., .T., @aAtuEDT )
			// obtem todas edts pai que se referem a edt informada
			PMSLoadEDT( cProjeto, cRevisa, AFC->AFC_EDT, .F., .F., @aAtuEDT )

			aSort(aAtuEDT,,, {|x, y| y[2] < x[2] })
		End If

		If lExecProc
			cOper  := IIf(Upper(TcGetDb())$'ORACLE.POSTGRES.DB2.INFORMIX','||','+')
			cProc  :='PMS200_'+CriaTrab(nil,.F.)
			cSQL   := ''
			nRet   := 1
			lRet   :=.t.
			aResult:={}
			
			cPrecisao:=ltrim(str(TamSX3("AFQ_QUANT")[2]))
			
			cAF8 :=RetSQLName("AF8")
			cAF9 :=RetSQLName("AF9")
			cAFC :=RetSQLName("AFC")
			cAFF :=RetSQLName("AFF")
			cAFQ :=RetSQLName("AFQ")
			cTmp2:=CriaTrab(nil,.F.)
		
			If Alltrim(Upper(TcGetDb()))=="INFORMIX"
				TCSqlExec('CREATE TABLE '+cTmp2+' ( ID varchar(255), HORAS decimal(28,12), DATA varchar(8), HORAI varchar(5), HORAF varchar(5), PERC decimal(28,12), PERCMILE decimal(28,12), FATOR decimal(28,12) )' )
			ElseIf Alltrim(Upper(TcGetDb()))=="DB2"
				TCSqlExec('CREATE TABLE '+cTmp2+' ( ID varchar(255), HORAS double, DATA varchar(8), HORAI varchar(5), HORAF varchar(5), PERC double, PERCMILE double, FATOR double )' )
			Else
				TCSqlExec('CREATE TABLE '+cTmp2+' ( ID varchar(255), HORAS numeric(28,12), DATA varchar(8), HORAI varchar(5), HORAF varchar(5), PERC numeric(28,12), PERCMILE numeric(28,12), FATOR numeric(28,12) )' )
			EndIf

			cSQL:=cSQL+"create procedure "+cProc+" ("+CRLF
			cSQL:=cSQL+"	@IN_PROJETO	varchar(255),"+CRLF
			cSQL:=cSQL+"	@IN_REVISAO	varchar(255),"+CRLF
			cSQL:=cSQL+"	@IN_EDT		varchar(255),"+CRLF
			cSQL:=cSQL+"	@OUT_RET	int output"+CRLF
			cSQL:=cSQL+") as"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"declare @HRUTEIS	DECIMAL( 28 , 12 )"+CRLF
			cSQL:=cSQL+"declare @QTTOT		DECIMAL( 28 , 12 )"+CRLF
			cSQL:=cSQL+"declare @AUX		varchar(255)"+CRLF
			cSQL:=cSQL+"declare @DATA		varchar(8)"+CRLF
			cSQL:=cSQL+"declare @NIVEL		varchar(255)"+CRLF
			cSQL:=cSQL+"declare @HRS		DECIMAL( 28 , 12 )"+CRLF
			cSQL:=cSQL+"declare @QT			DECIMAL( 28 , 12 )"+CRLF
			cSQL:=cSQL+"declare @MAINEDT	int"+CRLF
			cSQL:=cSQL+"declare @TOTTASK	int"+CRLF
			cSQL:=cSQL+"declare @TOTMILE	int"+CRLF
			cSQL:=cSQL+"declare @FATOR		DECIMAL( 28 , 12 )"+CRLF
			cSQL:=cSQL+"declare @PERC		DECIMAL( 28 , 12 )"+CRLF
			cSQL:=cSQL+"declare @PERCTASK	DECIMAL( 28 , 12 )"+CRLF
			cSQL:=cSQL+"declare @PERCMILE	DECIMAL( 28 , 12 )"+CRLF
			cSQL:=cSQL+"declare @DTSTART	varchar(8)"+CRLF
			cSQL:=cSQL+"declare @DTFINISH	varchar(8)"+CRLF
			cSQL:=cSQL+"declare @HORAI		varchar(5)"+CRLF
			cSQL:=cSQL+"declare @HORAF		varchar(5)"+CRLF
			cSQL:=cSQL+"declare @AFCSTART	varchar(8)"+CRLF
			cSQL:=cSQL+"declare @AFCFINISH	varchar(8)"+CRLF
			cSQL:=cSQL+"declare @RECNO		int"+CRLF
			cSQL:=cSQL+"declare @MAX		int"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"declare @PMS_MAX_DATE varchar(8)"+CRLF
			cSQL:=cSQL+"declare @PMS_MIN_DATE varchar(8)"+CRLF
			cSQL:=cSQL+"declare @PMS_MIN_HOUR varchar(5)"+CRLF
			cSQL:=cSQL+"declare @PMS_MAX_HOUR varchar(5)"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"declare @fim_CUR	int			-- Indica fim do cursor no DB2"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"declare @iLoop		integer"+CRLF
			cSQL:=cSQL+"declare @ins_error	integer"+CRLF
			cSQL:=cSQL+"declare @ins_ini	integer"+CRLF
			cSQL:=cSQL+"declare @ins_fim	integer"+CRLF
			cSQL:=cSQL+"declare @icoderror	integer"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"select @PMS_MAX_DATE = '20501231'"+CRLF
			cSQL:=cSQL+"select @PMS_MIN_DATE = '19800101'"+CRLF
			cSQL:=cSQL+"select @PMS_MIN_HOUR = '00:00'"+CRLF
			cSQL:=cSQL+"select @PMS_MAX_HOUR = '24:00'"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"select @DTSTART		= null"+CRLF
			cSQL:=cSQL+"select @DTFINISH	= null"+CRLF
			cSQL:=cSQL+"select @HORAI		= null"+CRLF
			cSQL:=cSQL+"select @HORAF		= null"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"select @OUT_RET=0"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"select @HRUTEIS=AFC_HUTEIS, @QTTOT=AFC_QUANT, @NIVEL=AFC_NIVEL, @AFCSTART=AFC_START, @AFCFINISH=AFC_FINISH"+CRLF
			cSQL:=cSQL+"from "+cAFC+CRLF
			cSQL:=cSQL+"where AFC_FILIAL='"+cFilAFC+"'"+CRLF
			cSQL:=cSQL+"and AFC_PROJET=@IN_PROJETO"+CRLF
			cSQL:=cSQL+"and AFC_REVISA=@IN_REVISAO"+CRLF
			cSQL:=cSQL+"and AFC_EDT=@IN_EDT"+CRLF
			cSQL:=cSQL+"and D_E_L_E_T_<>'*'"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"if @NIVEL='001' select @MAINEDT=-1 else select @MAINEDT=0"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"select @TOTTASK=0, @TOTMILE=0"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"declare cur99 cursor for"+CRLF
			cSQL:=cSQL+"select AF9_TAREFA, AF9_HUTEIS, AF9_QUANT"+CRLF
			cSQL:=cSQL+"from "+cAF9+CRLF
			cSQL:=cSQL+"where AF9_FILIAL='"+cFilAF9+"'"+CRLF
			cSQL:=cSQL+"and AF9_PROJET=@IN_PROJETO"+CRLF
			cSQL:=cSQL+"and AF9_REVISA=@IN_REVISAO"+CRLF
			cSQL:=cSQL+"and AF9_EDTPAI=@IN_EDT"+CRLF
			cSQL:=cSQL+"and D_E_L_E_T_<>'*'"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"open cur99"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"select @fim_CUR=0"+CRLF
			cSQL:=cSQL+"fetch next from cur99 into @AUX, @HRS, @QT"+CRLF
			cSQL:=cSQL+"while @@fetch_status = 0"+CRLF
			cSQL:=cSQL+"	begin"+CRLF
			cSQL:=cSQL+"		select @TOTTASK = @TOTTASK+1"+CRLF
			cSQL:=cSQL+"		if @HRS=0 select @TOTMILE = @TOTMILE+1"+CRLF
			cSQL:=cSQL+"		if @HRUTEIS=0 select @FATOR=0 else select @FATOR = @QTTOT * (@HRS / @HRUTEIS)"+CRLF
			cSQL:=cSQL+"		"+CRLF
			cSQL:=cSQL+"		insert into "+cTmp2+" (ID, HORAS, DATA, HORAI, HORAF, PERC, PERCMILE, FATOR)"+CRLF
			cSQL:=cSQL+"		select AFF_TAREFA, -99, AFF_DATA, AFF_HORAI, AFF_HORAF, AFF_QUANT, 0, 0"+CRLF
			cSQL:=cSQL+"		from "+cAFF+CRLF
			cSQL:=cSQL+"		where AFF_FILIAL='"+cFilAFF+"'"+CRLF
			cSQL:=cSQL+"		and AFF_PROJET=@IN_PROJETO"+CRLF
			cSQL:=cSQL+"		and AFF_REVISA=@IN_REVISAO"+CRLF
			cSQL:=cSQL+"		and AFF_TAREFA=@AUX"+CRLF
			cSQL:=cSQL+"		and D_E_L_E_T_<>'*'"+CRLF
			cSQL:=cSQL+"		"+CRLF
			cSQL:=cSQL+"		update "+cTmp2+" set HORAS=@HRS, PERC=PERC/@QT, FATOR=@FATOR where HORAS=-99"+CRLF
			cSQL:=cSQL+"		"+CRLF
			cSQL:=cSQL+"		select @fim_CUR=0"+CRLF
			cSQL:=cSQL+"		fetch next from cur99 into @AUX, @HRS, @QT"+CRLF
			cSQL:=cSQL+"	end"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"close cur99"+CRLF
			cSQL:=cSQL+"deallocate cur99"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"update "+cTmp2+" set HORAI=@PMS_MIN_HOUR where HORAI is null or HORAI='  :  ' or HORAI=''"+CRLF
			cSQL:=cSQL+"update "+cTmp2+" set HORAF=@PMS_MAX_HOUR where HORAF is null or HORAF='  :  ' or HORAF=''"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"declare cur2 cursor for"+CRLF
			cSQL:=cSQL+"select AFC_EDT, AFC_HUTEIS, AFC_QUANT"+CRLF
			cSQL:=cSQL+"from "+cAFC+CRLF
			cSQL:=cSQL+"where AFC_FILIAL='"+cFilAFC+"'"+CRLF
			cSQL:=cSQL+"and AFC_PROJET=@IN_PROJETO"+CRLF
			cSQL:=cSQL+"and AFC_REVISA=@IN_REVISAO"+CRLF
			cSQL:=cSQL+"and AFC_EDTPAI=@IN_EDT"+CRLF
			cSQL:=cSQL+"and D_E_L_E_T_<>'*'"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"open cur2"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"select @fim_CUR=0"+CRLF
			cSQL:=cSQL+"fetch next from cur2 into @AUX, @HRS, @QT"+CRLF
			cSQL:=cSQL+"while @@fetch_status = 0"+CRLF
			cSQL:=cSQL+"	begin"+CRLF
			cSQL:=cSQL+"		select @TOTTASK = @TOTTASK+1"+CRLF
			cSQL:=cSQL+"		if @HRS=0 select @TOTMILE = @TOTMILE+1"+CRLF
			cSQL:=cSQL+"		if @HRUTEIS=0 select @FATOR=0 else select @FATOR = @QTTOT * (@HRS / @HRUTEIS)"+CRLF
			cSQL:=cSQL+"		"+CRLF
			cSQL:=cSQL+"		insert into "+cTmp2+" (ID, HORAS, DATA, HORAI, HORAF, PERC, PERCMILE, FATOR)"+CRLF
			cSQL:=cSQL+"		select AFQ_EDT, -99, AFQ_DATA, '  :  ', '  :  ', AFQ_QUANT, 0, 0"+CRLF
			cSQL:=cSQL+"		from "+cAFQ+CRLF
			cSQL:=cSQL+"		where AFQ_FILIAL='"+cFilAFQ+"'"+CRLF
			cSQL:=cSQL+"		and AFQ_PROJET=@IN_PROJETO"+CRLF
			cSQL:=cSQL+"		and AFQ_REVISA=@IN_REVISAO"+CRLF
			cSQL:=cSQL+"		and AFQ_EDT=@AUX"+CRLF
			cSQL:=cSQL+"		and D_E_L_E_T_<>'*'"+CRLF
			cSQL:=cSQL+"		"+CRLF
			cSQL:=cSQL+"		update "+cTmp2+" set HORAS=@HRS, HORAI=@PMS_MIN_HOUR, HORAF=@PMS_MAX_HOUR, PERC=PERC/@QT, FATOR=@FATOR where HORAS=-99"+CRLF
			cSQL:=cSQL+"		"+CRLF
			cSQL:=cSQL+"		select @fim_CUR=0"+CRLF
			cSQL:=cSQL+"		fetch next from cur2 into @AUX, @HRS, @QT"+CRLF
			cSQL:=cSQL+"	end"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"close cur2"+CRLF
			cSQL:=cSQL+"deallocate cur2"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"select @AUX=null"+CRLF
			cSQL:=cSQL+"select @AUX=MIN(DATA "+cOper+" HORAI)"+CRLF
			cSQL:=cSQL+"from "+cTmp2+CRLF
			cSQL:=cSQL+"where DATA is not null"+CRLF
			cSQL:=cSQL+"and DATA <> ''"+CRLF
			cSQL:=cSQL+"and ((DATA "+cOper+" HORAI)<(@DTSTART "+cOper+" @HORAI) or (@DTSTART is null))"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"if @AUX is not null select @DTSTART=substring(@AUX,1,8), @HORAI=substring(@AUX,9,5)"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"select @AUX=null"+CRLF
			cSQL:=cSQL+"select @AUX=MAX(DATA "+cOper+" HORAF)"+CRLF
			cSQL:=cSQL+"from "+cTmp2+CRLF
			cSQL:=cSQL+"where DATA is not null"+CRLF
			cSQL:=cSQL+"and DATA <> ''"+CRLF
			cSQL:=cSQL+"and PERC>=1"+CRLF
			cSQL:=cSQL+"and ((DATA "+cOper+" HORAF)>(@DTFINISH "+cOper+" @HORAF) or (@DTFINISH is null))"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"if @AUX is not null select @DTFINISH=substring(@AUX,1,8), @HORAF=substring(@AUX,9,5)"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"declare cur3 cursor for select DATA from "+cTmp2+" where ID<>'TOTAL' group by DATA order by DATA"+CRLF
			cSQL:=cSQL+"open cur3"+CRLF
			cSQL:=cSQL+"select @fim_CUR=0"+CRLF
			cSQL:=cSQL+"fetch next from cur3 into @DATA"+CRLF
			cSQL:=cSQL+"while @@fetch_status = 0"+CRLF
			cSQL:=cSQL+"	begin"+CRLF
			cSQL:=cSQL+"		select @PERC=0, @PERCMILE=0, @PERCTASK=0"+CRLF
			cSQL:=cSQL+"		"+CRLF
			cSQL:=cSQL+"		declare cur4 cursor for select ID, max(FATOR), max(HORAS) from "+cTmp2+" where ID<>'TOTAL' group by ID order by ID"+CRLF
			cSQL:=cSQL+"		open cur4"+CRLF
			cSQL:=cSQL+"		select @fim_CUR=0"+CRLF
			cSQL:=cSQL+"		fetch next from cur4 into @AUX, @FATOR, @HRS"+CRLF
			cSQL:=cSQL+"		while @@fetch_status = 0"+CRLF
			cSQL:=cSQL+"			begin"+CRLF
			cSQL:=cSQL+"				select @QT=null"+CRLF
			cSQL:=cSQL+"				select @QT=PERC from "+cTmp2+" where ID=@AUX and DATA=@DATA"+CRLF
			cSQL:=cSQL+"				if @QT is null select @QT=MAX(PERC) from "+cTmp2+" where ID=@AUX and DATA<=@DATA"+CRLF
			cSQL:=cSQL+"				select @QT=isnull(@QT,0), @FATOR=isnull(@FATOR,0), @HRS=isnull(@HRS,0)"+CRLF
			cSQL:=cSQL+"				if @HRS=0"+CRLF
			cSQL:=cSQL+"					select @PERCMILE=@PERCMILE+@QT"+CRLF
			cSQL:=cSQL+"				else"+CRLF
			cSQL:=cSQL+"					begin"+CRLF
			cSQL:=cSQL+"						select @PERCTASK=@PERCTASK+(@QT*@FATOR)"+CRLF
			cSQL:=cSQL+"						select @PERC=@PERC+@QT"+CRLF
			cSQL:=cSQL+"					end"+CRLF
			cSQL:=cSQL+"				select @fim_CUR=0"+CRLF
			cSQL:=cSQL+"				fetch next from cur4 into @AUX, @FATOR, @HRS"+CRLF
			cSQL:=cSQL+"			end"+CRLF
			cSQL:=cSQL+"		close cur4"+CRLF
			cSQL:=cSQL+"		deallocate cur4"+CRLF
			cSQL:=cSQL+"		"+CRLF
			cSQL:=cSQL+"		insert into "+cTmp2+" (ID, DATA, PERC, PERCMILE, FATOR) values ( 'TOTAL', @DATA, @PERC, @PERCMILE, @PERCTASK)"+CRLF
			cSQL:=cSQL+"		"+CRLF
			cSQL:=cSQL+"		select @fim_CUR=0"+CRLF
			cSQL:=cSQL+"		fetch next from cur3 into @DATA"+CRLF
			cSQL:=cSQL+"	end"+CRLF
			cSQL:=cSQL+"close cur3"+CRLF
			cSQL:=cSQL+"deallocate cur3"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"update "+cAFQ+" set R_E_C_D_E_L_=R_E_C_N_O_, D_E_L_E_T_='*'"+CRLF
			cSQL:=cSQL+"where AFQ_FILIAL='"+cFilAFQ+"'"+CRLF
			cSQL:=cSQL+"and AFQ_PROJET=@IN_PROJETO"+CRLF
			cSQL:=cSQL+"and AFQ_REVISA=@IN_REVISAO"+CRLF
			cSQL:=cSQL+"and AFQ_EDT=@IN_EDT"+CRLF
			cSQL:=cSQL+"and D_E_L_E_T_<>'*'"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"select @MAX=0"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"declare cur5 cursor for select DATA, PERC, PERCMILE, FATOR from "+cTmp2+" where ID='TOTAL' order by DATA"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"open cur5"+CRLF
			cSQL:=cSQL+"select @fim_CUR=0"+CRLF
			cSQL:=cSQL+"fetch next from cur5 into @DATA, @PERC, @PERCMILE, @FATOR"+CRLF
			cSQL:=cSQL+"while @@fetch_status = 0"+CRLF
			cSQL:=cSQL+"	begin"+CRLF
			cSQL:=cSQL+"		if @TOTTASK=@TOTMILE"+CRLF
			cSQL:=cSQL+"			begin"+CRLF
			cSQL:=cSQL+"				if @PERCMILE<@TOTTASK select @PERCTASK=0, @MAX=0 else select @PERCTASK=@QTTOT, @MAX=-1"+CRLF
			cSQL:=cSQL+"			end"+CRLF
			cSQL:=cSQL+"		else"+CRLF
			cSQL:=cSQL+"			begin"+CRLF
			cSQL:=cSQL+"				if @PERC>=@TOTTASK-@TOTMILE and @PERC+@PERCMILE < @TOTTASK"+CRLF
			cSQL:=cSQL+"					select @PERCTASK=0.99*@FATOR"+CRLF
			cSQL:=cSQL+"				else"+CRLF
			cSQL:=cSQL+"					select @PERCTASK=@FATOR"+CRLF
			cSQL:=cSQL+"				if @PERC+@PERCMILE >= @TOTTASK select @MAX=-1 else select @MAX=0"+CRLF
			cSQL:=cSQL+"			end"+CRLF
			cSQL:=cSQL+"		"+CRLF
			cSQL:=cSQL+"		select @PERCTASK=round(@PERCTASK,"+cPrecisao+")"+CRLF
			cSQL:=cSQL+"		select @RECNO = 0"+CRLF
			cSQL:=cSQL+"		select @RECNO = MAX(R_E_C_N_O_) from "+cAFQ+""+CRLF
			cSQL:=cSQL+"		select @RECNO = @RECNO + 1"+CRLF
			cSQL:=cSQL+"		if (@RECNO = 0 or @RECNO is null) select @RECNO = 1"+CRLF
			cSQL:=cSQL+"		"+CRLF
			cSQL:=cSQL+"		select @ins_ini = @RECNO"+CRLF // inicio do tratamento do R_E_C_N_O_ ( ser· substituido apos chamar InsertPutSql() )
			cSQL:=cSQL+"		insert into "+cAFQ+" (AFQ_FILIAL, AFQ_PROJET, AFQ_REVISA, AFQ_DATA, AFQ_EDT, AFQ_QUANT, R_E_C_N_O_)"+CRLF
			cSQL:=cSQL+"		values ('"+cFilAFQ+"', @IN_PROJETO, @IN_REVISAO, @DATA, @IN_EDT, @PERCTASK, @RECNO)"+CRLF
			cSQL:=cSQL+"		select @ins_fim = 1"+CRLF // fim do tratamento do R_E_C_N_O_ ( ser· substituido apos chamar InsertPutSql() )
			cSQL:=cSQL+"		"+CRLF
			cSQL:=cSQL+"		select @fim_CUR=0"+CRLF
			cSQL:=cSQL+"		fetch next from cur5 into @DATA, @PERC, @PERCMILE, @FATOR"+CRLF
			cSQL:=cSQL+"	end"+CRLF
			cSQL:=cSQL+"close cur5"+CRLF
			cSQL:=cSQL+"deallocate cur5"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"if @DTSTART is null select @DTSTART='', @HORAI='  :  '"+CRLF
			cSQL:=cSQL+"if @MAX=0 or @DTFINISH is null select @DTFINISH='', @HORAF='  :  '"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"update "+cAFC+" set AFC_DTATUI=@DTSTART, AFC_HRATUI=@HORAI, AFC_DTATUF=@DTFINISH, AFC_HRATUF=@HORAF"+CRLF
			cSQL:=cSQL+"where AFC_FILIAL='"+cFilAFC+"'"+CRLF
			cSQL:=cSQL+"and AFC_PROJET=@IN_PROJETO"+CRLF
			cSQL:=cSQL+"and AFC_REVISA=@IN_REVISAO"+CRLF
			cSQL:=cSQL+"and AFC_EDT=@IN_EDT"+CRLF
			cSQL:=cSQL+"and D_E_L_E_T_<>'*'"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"if @MAINEDT=-1"+CRLF
			cSQL:=cSQL+"	update "+cAF8+" set AF8_START=@AFCSTART, AF8_FINISH=@AFCFINISH"+CRLF
			cSQL:=cSQL+"	where AF8_FILIAL='"+xFilial("AF8")+"'"+CRLF
			cSQL:=cSQL+"	and AF8_PROJET=@IN_PROJETO"+CRLF
			cSQL:=cSQL+"	and AF8_REVISA=@IN_REVISAO"+CRLF
			cSQL:=cSQL+"	and D_E_L_E_T_<>'*'"+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"delete from "+cTmp2+""+CRLF
			cSQL:=cSQL+""+CRLF
			cSQL:=cSQL+"select @OUT_RET=1"+CRLF

			cSQL:=MsParse(cSQL,Alltrim(TcGetDB()))

			If cSQL=''
				If !__lBlind
 					MsgAlert(STR0260+" "+cProc+": "+MsParseError())  //'Erro criando a Stored Procedure:'
				EndIf
			Else

				//Inclusao do tratamento de INSERT na procedure
 				cSQL:=InsertPutSql( TcGetDb(), cSQL )
				If Trim(TcGetDb()) = 'DB2'
					nPos := AT("DECLARE FIM_CUR INTEGER DEFAULT 0;",Upper(cSQL))
					If nPos > 0
						cSQL := Stuff(cSQL,nPos+34,0,CRLF+"Declare v_dup_key CONDITION for sqlstate '23505';")
					EndIf
					nPos := AT("SET FIM_CUR = 1;",Upper(cSQL))
					If nPos > 0
						cSQL := Stuff(cSQL,nPos+16,0,CRLF+"DECLARE CONTINUE HANDLER FOR v_dup_key SET vicoderror = 1;")
					Endif
				EndIf
				cSQL:=StrTran(cSQL,CHR(13),'')

				cSQL:=PmsA200Fix(cSQL, Alltrim(TcGetDB()))
				If Upper(TcGetDb())=='DB2'
					cSQL:=StrTran(cSQL,"declare vHRUTEIS DECIMAL( 28 , 12 ) ;","declare vHRUTEIS DOUBLE;")
					cSQL:=StrTran(cSQL,"declare vQTTOT DECIMAL( 28 , 12 ) ;","declare vQTTOT DOUBLE;")
					cSQL:=StrTran(cSQL,"declare vHRS DECIMAL( 28 , 12 ) ;","declare vHRS DOUBLE;")
					cSQL:=StrTran(cSQL,"declare vQT DECIMAL( 28 , 12 ) ;","declare vQT DOUBLE;")
					cSQL:=StrTran(cSQL,"declare vFATOR DECIMAL( 28 , 12 ) ;","declare vFATOR DOUBLE;")
					cSQL:=StrTran(cSQL,"declare vPERC DECIMAL( 28 , 12 ) ;","declare vPERC DOUBLE;")
					cSQL:=StrTran(cSQL,"declare vPERCTASK DECIMAL( 28 , 12 ) ;","declare vPERCTASK DOUBLE;")
					cSQL:=StrTran(cSQL,"declare vPERCMILE DECIMAL( 28 , 12 ) ;","declare vPERCMILE DOUBLE;")
				EndIf
				If Upper(TcGetDb())=='INFORMIX'
					cSQL:=StrTran(cSQL,"'TOTAL' , vDATA , vPERC , vPERCMILE , vPERCTASK );"," VALUES ('TOTAL' , vDATA , vPERC , vPERCMILE , vPERCTASK );")
					cSQL:=StrTran(cSQL,"'01' , IN_PROJETO , IN_REVISAO , vDATA , IN_EDT , vPERCTASK , vRECNO );", " VALUES ('01' , IN_PROJETO , IN_REVISAO , vDATA , IN_EDT , vPERCTASK , vRECNO );")
				EndIf
				If Upper(TcGetDb())=='ORACLE'
					cSQL:=StrTran(cSQL,"vDTSTART  :is null ;","vDTSTART  := '        ' ;")
					cSQL:=StrTran(cSQL,"vDTFINISH  :is null ;", "vDTFINISH  := '        ' ;")
				EndIf
				If Upper(TcGetDb())$'DB2.INFORMIX.ORACLE'
					cSQL:=StrTran(cSQL,"MIN ( DATA  || HORAI ), HORAI","MIN ( DATA  || HORAI )")
					cSQL:=StrTran(cSQL,"MAX ( DATA  || HORAF ), HORAF","MAX ( DATA  || HORAF )")
				EndIf

				nRet:=TcSqlExec(cSQL)

				If nRet <> 0
					If !__lBlind
	 					MsgAlert(STR0260+" "+cProc+": "+TCSqlError())  //'Erro criando a Stored Procedure:'
					EndIf
					lRet := .f.
				EndIf
			EndIf

		EndIf
		
		If nRet==0

			aEDTSPai := {}
			For nCount := 1 to Len(aAtuEDT)
				cSeekEDT      := aAtuEDT[nCount,1]
				dDtAtuI       := PMS_MAX_DATE
				lMileStone    := .F.
				nTotMileStone := 0
				nTotTasks     := 0
				aTaskFilho    := {}
				aEDTFilho     := {}
				aAFQUpdate    := {}

				If lExecProc
					aResult := TCSPExec( cProc, cProjeto, cRevisa, cSeekEDT)
					If empty(aResult)
						If !__lBlind
							MsgAlert(STR0261+" "+cProc+": "+TCSqlError())  //'Erro executando a Stored Procedure'
						EndIf
						lRet := .f.
					ElseIf aResult[1] != 1
						If !__lBlind
							MsgAlert(STR0261+": "+TCSqlError())   //'Erro executando a Stored Procedure'
						EndIf
						lRet := .f.
					EndIf
				Else
					dbSelectArea("AFC")
					dbSetOrder(1)
					If dbSeek(cFilAFC+cProjeto+cRevisa+cSeekEDT)
						nHrUteis      := AFC->AFC_HUTEIS
						nQtTot        := AFC->AFC_QUANT
						lEDTPrincipal := AFC->AFC_NIVEL == '001'
					Else
						nHrUteis      := 0
						nQtTot        := 0
						lEDTPrincipal := .F.
					EndIf

					dbSelecTArea("AF9")
					dbSetOrder(2)
					dbSeek(cFilAF9 + cProjeto + cRevisa + cSeekEDT)
					Do While !AF9->(Eof()) .And. AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_EDTPAI==;
										  cFilAF9+cProjeto+cRevisa+cSeekEDT
						lMileStone := AF9->AF9_HUTEIS == 0
						If lMileStone
							nTotMileStone := nTotMileStone + 1
						EndIf
						nTotTasks := nTotTasks + 1
						nFator    := nQtTot * (AF9->AF9_HUTEIS / nHrUteis)

						dbSelecTArea("AFF")
						dbSetOrder(1)
						dbSeek(cFilAFF + cProjeto + cRevisa + AF9->AF9_TAREFA)
						Do While !AFF->(Eof()) .And. AFF->AFF_FILIAL+AFF->AFF_PROJET+AFF->AFF_REVISA+AFF->AFF_TAREFA==;
											  cFilAFF+cProjeto+cRevisa+AF9->AF9_TAREFA
							If ASCAN(aTaskFilho, {|x| x[1] == AF9->AF9_TAREFA .and. x[2] == AFF->AFF_DATA}) == 0
								If lMileStone
									nPercExec := 0
									nPercMile := AFF->AFF_QUANT / AF9->AF9_QUANT
								Else
									nPercExec := AFF->AFF_QUANT / AF9->AF9_QUANT
									nPercMile := 0
								EndIf
								AADD(aTaskFilho, {AF9->AF9_TAREFA, AFF->AFF_DATA, IIf(empty(AFF->AFF_HORAI),PMS_MIN_HOUR,AFF->AFF_HORAI), IIf(empty(AFF->AFF_HORAF),PMS_MAX_HOUR,AFF->AFF_HORAF), nPercExec, nPercMile, nFator })
							EndIf
							AFF->(DbSkip())
						End Do
						AF9->(DbSkip())
					End Do

					dbSelecTArea("AFC")
					dbSetOrder(2)
					dbSeek(cFilAFC + cProjeto + cRevisa + cSeekEDT)
					Do While !AFC->(Eof()) .And. AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDTPAI==;
										  cFilAFC+cProjeto+cRevisa+cSeekEDT
						lMileStone := AFC->AFC_HUTEIS == 0
						If lMileStone
							nTotMileStone := nTotMileStone + 1
						EndIf
						nTotTasks := nTotTasks + 1
						nFator    := nQtTot * (AFC->AFC_HUTEIS / nHrUteis)

						dbSelecTArea("AFQ")
						dbSetOrder(1)
						dbSeek(cFilAFQ + cProjeto + cRevisa + AFC->AFC_EDT)
						Do While !AFQ->(Eof()) .And. AFQ->AFQ_FILIAL+AFQ->AFQ_PROJET+AFQ->AFQ_REVISA+AFQ->AFQ_EDT==;
											  cFilAFQ+cProjeto+cRevisa+AFC->AFC_EDT
							If ASCAN(aEDTFilho, {|x| x[1] == AFQ->AFQ_EDT .and. x[2] == AFQ->AFQ_DATA}) == 0
								If lMileStone
									nPercExec := 0
									nPercMile := AFQ->AFQ_QUANT / AFC->AFC_QUANT
								Else
									nPercExec := AFQ->AFQ_QUANT / AFC->AFC_QUANT
									nPercMile := 0
								EndIf
								AADD(aEDTFilho, {AFC->AFC_EDT, AFQ->AFQ_DATA, PMS_MIN_HOUR, PMS_MAX_HOUR, nPercExec, nPercMile, nFator })
							EndIf
							AFQ->(DbSkip())
						End Do
						AFC->(DbSkip())
					End Do

					aAFQDatas := {{PMS_EMPTY_DATE},{PMS_EMPTY_DATE}}
					aDatasReal := {PMS_MAX_DATE, PMS_MAX_HOUR, PMS_MIN_DATE, PMS_MIN_HOUR}
					lMin:=.F.
					lMax:=.F.
					lMileStone:=nTotTasks==nTotMileStone

					For nCnt2 := 1 to Len(aTaskFilho)
						nCol:=ASCAN(aAFQDatas[1], aTaskFilho[nCnt2,1])
						If nCol == 0
							AADD( aAFQDatas[1], aTaskFilho[nCnt2,1])
							AADD( aAFQDatas[2], aTaskFilho[nCnt2,7])
							nCol:=len(aAFQDatas[1])
						EndIf
						nPosData := ASCAN(aAFQDatas, {|x| x[1] == aTaskFilho[nCnt2,2]})
						If nPosData == 0
							AADD( aAFQDatas, { aTaskFilho[nCnt2,2] })
							nPosData:=len(aAFQDatas)
							ASIZE( aAFQDatas[nPosData], len(aAFQDatas[1]))
							aAFQDatas[nPosData,nCol]:={aTaskFilho[nCnt2,5], aTaskFilho[nCnt2,6]}
						Else
							ASIZE( aAFQDatas[nPosData], len(aAFQDatas[1]))
							If aAFQDatas[nPosData,nCol]==NIL
								aAFQDatas[nPosData,nCol]:={aTaskFilho[nCnt2,5], aTaskFilho[nCnt2,6]}
							Else
								aAFQDatas[nPosData,nCol,1]+=aTaskFilho[nCnt2,5]
								aAFQDatas[nPosData,nCol,2]+=aTaskFilho[nCnt2,6]
							EndIf
						EndIf
						If DTOS(aDatasReal[1])+aDatasReal[2] > DTOS(aTaskFilho[nCnt2,2])+aTaskFilho[nCnt2,3] .and. !empty(aTaskFilho[nCnt2,2])
							aDatasReal[1] := aTaskFilho[nCnt2,2]
							aDatasReal[2] := aTaskFilho[nCnt2,3]
							lMin:=.T.
						EndIf
						If DTOS(aDatasReal[3])+aDatasReal[4] < DTOS(aTaskFilho[nCnt2,2])+aTaskFilho[nCnt2,4] .and. !empty(aTaskFilho[nCnt2,2]) .and. aTaskFilho[nCnt2,IIf(lMileStone,6,5)] >= 1
							aDatasReal[3] := aTaskFilho[nCnt2,2]
							aDatasReal[4] := aTaskFilho[nCnt2,4]
							lMax:=.T.
						EndIf
					Next nCnt2

					For nCnt2 := 1 to len(aEDTFilho)
						nCol:=ASCAN(aAFQDatas[1], aEDTFilho[nCnt2,1])
						If nCol = 0
							AADD( aAFQDatas[1], aEDTFilho[nCnt2,1])
							AADD( aAFQDatas[2], aEDTFilho[nCnt2,7])
							nCol:=len(aAFQDatas[1])
						EndIf
						nPosData := ASCAN(aAFQDatas, {|x| x[1] == aEDTFilho[nCnt2,2]})
						If nPosData = 0
							AADD( aAFQDatas, { aEDTFilho[nCnt2,2] })
							nPosData:=len(aAFQDatas)
							ASIZE( aAFQDatas[nPosData], len(aAFQDatas[1]))
							aAFQDatas[nPosData,nCol]:={aEDTFilho[nCnt2,5],aEDTFilho[nCnt2,6]}
						Else
							ASIZE( aAFQDatas[nPosData], len(aAFQDatas[1]))
							If aAFQDatas[nPosData,nCol]==nil
								aAFQDatas[nPosData,nCol]:={aEDTFilho[nCnt2,5],aEDTFilho[nCnt2,6]}
							Else
								aAFQDatas[nPosData,nCol,1]+=aEDTFilho[nCnt2,5]
								aAFQDatas[nPosData,nCol,2]+=aEDTFilho[nCnt2,6]
							EndIf
						EndIf
						If DTOS(aDatasReal[1])+aDatasReal[2] > DTOS(aEDTFilho[nCnt2,2])+aEDTFilho[nCnt2,3] .and. !empty(aEDTFilho[nCnt2,2])
							aDatasReal[1] := aEDTFilho[nCnt2,2]
							aDatasReal[2] := aEDTFilho[nCnt2,3]
							lMin:=.T.
						EndIf
						If DTOS(aDatasReal[3])+aDatasReal[4] < DTOS(aEDTFilho[nCnt2,2])+aEDTFilho[nCnt2,4] .and. !empty(aEDTFilho[nCnt2,2]) .and. aEDTFilho[nCnt2,IIf(lMileStone,6,5)] >= 1
							aDatasReal[3] := aEDTFilho[nCnt2,2]
							aDatasReal[4] := aEDTFilho[nCnt2,4]
							lMax:=.T.
						EndIf
					Next nCnt2

					If len(aAFQDatas)>1
						aSort(aAFQDatas,,, {|x, y| valtype(x[len(x)])=='C' .or. y[1] > x[1]})

						AADD( aAFQDatas[1], 'Total')
						AADD( aAFQDatas[2], 0)
						nTot:=len(aAFQDatas[1])
						For nCnt2 := 3 to len(aAFQDatas)
							ASIZE( aAFQDatas[nCnt2], nTot)
							aAFQDatas[nCnt2,nTot]:={0,0,0}
							For nCol := 2 to nTot-1
								If aAFQDatas[nCnt2,nCol]==NIL
									aAFQDatas[nCnt2,nCol]:=IIf(nCnt2==3, {0,0,0}, aAFQDatas[nCnt2-1,nCol])
								EndIf
								aAFQDatas[nCnt2,nTot,1]+=aAFQDatas[nCnt2,nCol,1]
								aAFQDatas[nCnt2,nTot,2]+=aAFQDatas[nCnt2,nCol,2]
								aAFQDatas[nCnt2,nTot,3]+=aAFQDatas[nCnt2,nCol,1]*aAFQDatas[2,nCol]
							Next nCol
						Next nCnt2
					EndIf

					// Inclui ou atualiza as confirmaÁıes de EDT j· existentes
					dbSelecTArea("AFQ")
					dbSetOrder(1)
					For nCnt2 := 3 to len(aAFQDatas)

						If lMileStone
							lMax:=nPercMile>0
							// percentual por Milestone
							nFator:=IIf(aAFQDatas[nCnt2,nTot,2]<nTotTasks,0,nQtTot) 
						Else
							lMax:=( aAFQDatas[nCnt2,nTot,1] + aAFQDatas[nCnt2,nTot,2] ) >= nTotTasks
							// percentual por Execucao
							nFator:=IIf(aAFQDatas[nCnt2,nTot,1]>=(nTotTasks-nTotMileStone) .and. (aAFQDatas[nCnt2,nTot,1]+aAFQDatas[nCnt2,nTot,2])<nTotTasks, 0.99*aAFQDatas[nCnt2,nTot,3], aAFQDatas[nCnt2,nTot,3] )
						EndIf
						If AFQ->(dbSeek(cFilAFQ + cProjeto + cRevisa + cSeekEDT + DTOS(aAFQDatas[nCnt2,1])))
							Reclock('AFQ', .F.)
							AFQ->AFQ_QUANT := nFator
							MsUnlock()
						Else
							Reclock('AFQ', .T.)
							AFQ->AFQ_FILIAL := cFilAFQ
							AFQ->AFQ_PROJET := cProjeto
							AFQ->AFQ_REVISA := cRevisa
							AFQ->AFQ_EDT    := cSeekEDT
							AFQ->AFQ_DATA   := aAFQDatas[nCnt2,1]
							AFQ->AFQ_QUANT  := nFator
							MsUnlock()
						EndIf
						AADD(aAFQUpdate, AFQ->AFQ_DATA)
					Next nCnt2

					// exclui as confirmaÁıes de EDT n„o modificadas
					If AFQ->(dbSeek(cFilAFQ + cProjeto + cRevisa + cSeekEDT))

						Do While !AFQ->(Eof()) .And. AFQ->AFQ_FILIAL+AFQ->AFQ_PROJET+AFQ->AFQ_REVISA+AFQ->AFQ_EDT==;
											  cFilAFQ+cProjeto+cRevisa+cSeekEDT
							If ASCAN(aAFQUpdate, {|x| x == AFQ->AFQ_DATA} ) <= 0
								RecLock("AFQ",.F.)
								AFQ->(DbDelete())
								MsUnLock()
							EndIf

							AFQ->(DbSkip())

						EndDo

						// Posiciona na EDT
						dbSelectArea("AFC")
						dbSetOrder(1)
						If MSSeek(cFilAFC+cProjeto+cRevisa+cSeekEDT)
							RecLock("AFC",.F.)
							AFC->AFC_DTATUI := IIf(lMin, aDatasReal[1], PMS_EMPTY_DATE)
							AFC->AFC_HRATUI := IIf(lMin, aDatasReal[2], '  :  ')
							AFC->AFC_DTATUF := IIf(lMax, aDatasReal[3], PMS_EMPTY_DATE)
							AFC->AFC_HRATUF := IIf(lMax, aDatasReal[4], '  :  ')
							MsUnLock()

							If lEDTPrincipal
								Reclock('AF8', .F.)
								AF8->AF8_START  := AFC->AFC_START
								AF8->AF8_FINISH := AFC->AFC_FINISH
								MsUnlock()
							EndIf

						EndIf

					EndIf

				EndIf

			Next nCount

		EndIf

		If lExecProc
			MsErase(cTmp2,,"TOPCONN")
			If TcSqlExec('DROP PROCEDURE '+cProc)<>0
				If !__lBlind
					MsgAlert(STR0263+" "+cProc+": "+TCSqlError())   //'Erro excluindo procedure'
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaAF8)
RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aAreaAFF)
RestArea(aAreaAFQ)

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥Pms200REdt≥ Autor ≥                        ≥ Data ≥ 03/06/2005                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥                                                                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥                                                                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SIGAPMS                                                                         ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ‹ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Function Pms200REdt(oTree,cArquivo)
Local nData
Local nCalc
Local aRet:={}
Local cAlias
Local nRecAlias
Local cEDTPai

If ParamBox ( {;
		{2,STR0314, 3,{'1='+STR0307,'2='+STR0308,'3='+STR0309},80,"",.F.},; //"Considera as datas:"##"Previstas"##"Realizadas"##"Ambas"
		{2,STR0310, 2,{'1='+STR0311,'2='+STR0312},80,"",.F.}  },; // "Calcular a partir:" ##"Projeto"##"EDT"
		STR0313, @aRet) // "Atualizar acumulados de datas e progresso"
	nData:= If(ValType(aRet[1])=="N",aRet[1],Val(left(aRet[1],1)))
	nCalc:= If(ValType(aRet[2])=="N",aRet[2],Val(left(aRet[2],1)))

	If oTree!= Nil
	   	cAlias	:= SubStr(oTree:GetCargo(),1,3)
		nRecAlias	:= Val(SubStr(oTree:GetCargo(),4,12))
	Else
		cAlias := (cArquivo)->ALIAS
		nRecAlias := (cArquivo)->RECNO
	EndIf

	dbSelectArea(cAlias)
	dbGoto(nRecAlias)

	If nCalc == 1
		cEDTPai := Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT))
	Else
		If cAlias == 'AF9'
			cEDTPai := AF9->AF9_EDTPAI
		Else
			cEDTPai := AFC->AFC_EDT
		EndIf
	EndIf

	If PA200Rec( nData, AF8->AF8_PROJET, cRevisa, cEDTPai )
		Eval(bRefresh)
		Eval(bReCalc)
	EndIf
EndIf

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥PA200Rec  ≥ Autor ≥                        ≥ Data ≥ 03/06/2005                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Funcao auxiliar para recalculo da EDT                                            ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function PA200Rec( nData, cProjet, cRevisa, cEDTPai )
Local lRet			:= .F.
Local aSelectEDT	:= {}

PmsLoadEDT( cProjet, cRevisa, cEDTPai, .T., .T., @aSelectEDT ) // Carrega as EDT's filhas mais a edt informada
PmsLoadEDT( cProjet, cRevisa, cEDTPai, .F., .F., @aSelectEDT ) // Carrega as EDT's pais

If !Empty(aSelectEDT)
	aSort(aSelectEDT,,, {|x, y| y[2] < x[2] })
	If nData >= 1
		PmsEdtPrv( cProjet, cRevisa, cEDTPai, aSelectEDT)
	EndIf

	If nData >= 2
		PMSEdtReal( cProjet, cRevisa, cEDTPai, aSelectEDT)
	EndIf

	lRet := .T.
EndIf

Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥PA200Sched≥ Autor ≥                        ≥ Data ≥ 03/06/2005                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Funcao para recalculo da EDT via schedule                                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PA200Sched()

ConOut( "Iniciando: Atualizacao de acumulados de datas e progressos" )

Pergunte( "PMA200SCHE", .F. )

DbSelectArea( "AF8" )
AF8->( DbSetOrder( 1 ) )
AF8->( DbSeek( xFilial( "AF8" ) ) )
While AF8->( !Eof() ) .AND. AF8->AF8_FILIAL == xFilial( "AF8" )
	PA200Rec( MV_PAR01, AF8->AF8_PROJET, AF8->AF8_REVISA, AF8->AF8_PROJET )
	AF8->( DbSkip() )
End

ConOut( "Finalizando: Atualizacao de acumulados de datas e progressos" )

Return


Function Pms200AGrp(oTree,cArquivo)
Local aRet := {}
Local aArea	:= GetArea()
Local aAreaAFC	:= AFC->(GetArea())
Local aAreaAF9	:= AF9->(GetArea())

If oTree!= Nil
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecAlias	:= Val(SubStr(oTree:GetCargo(),4,12))
ElseIf cArquivo <> Nil
	cAlias := (cArquivo)->ALIAS
	nRecAlias := (cArquivo)->RECNO
EndIf

If cAlias == "AFC"
	dbSelectArea("AFC")
	dbGoto(nRecAlias)
	dbSelectArea("AF9")
	dbSetOrder(2)
	If PmsChkUser(AFC->AFC_PROJET,,AFC->AFC_EDT,AFC->AFC_EDTPAI,3,"ESTRUT",AFC->AFC_REVISA)
		If ParamBox( {	{1, STR0180,CriaVar("AF9_GRPCOM",.F.),"@!","ExistCpo('AE5',MV_PAR01)","AE5","",40,.T.} }, STR0181,@aRet)  //"Grupo"##"Alterar Grupo de Tarefas"
			Begin Transaction
				dbSeek(xFilial()+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT)
				While !Eof() .And. xFilial()+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT==AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_EDTPAI
					PmsIncProc(.T.)
					RecLock("AF9",.F.)
					AF9->AF9_GRPCOM := aRet[1]
					MsUnlock()
					dbSkip()
				End
			End Transaction
		EndIf
	EndIf
	Eval(bRefresh)
ElseIf cAlias == "AF9"
	dbSelectArea("AF9")
	dbGoto(nRecAlias)
	If PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,3,"ESTRUT",AF9->AF9_REVISA)
		If ParamBox( {	{1,"Grupo",CriaVar("AF9_GRPCOM",.F.),"@!","ExistCpo('AE5',MV_PAR01)","AE5","",40,.T.} },STR0233,@aRet)
			Begin Transaction
				RecLock("AF9",.F.)
				AF9->AF9_GRPCOM := aRet[1]
				MsUnlock()
			End Transaction
		EndIf
	EndIf
	Eval(bRefresh)
EndIf


RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aArea)
Return

Function PmsLoadTrf(cChave,aEDTPai,lTarefa,aAllTasks,cFiltroAF9,lMsAguarde ,aTasks )
Local aArea:= GetArea()
Local aAreaAFA := AFA->(GetArea())
Local aAreaAFC := AFC->(GetArea())
Local aAreaAF9 := AF9->(GetArea())
Local cAliasTmp:= ""
Local lTopConn	:= IfDefTopCTB()
Local cCharConcat := ""
Local cWhere		:= ""

DEFAULT lTarefa 	:= .F.
DEFAULT cFiltroAF9 	:= .F.
DEFAULT lMsAguarde  := .F.
DEFAULT aTasks      := {}

// Define o sÌmbolo de concatenaÁ„o de acordo com o banco de dados
If Upper( TcGetDb() ) $ "ORACLE*POSTGRES*DB2*INFORMIX"
	cCharConcat := "||"
Else
	cCharConcat	:= "+"
EndIf

If lTarefa
	If aScan(aEDTPai,AF9->AF9_EDTPAI) <= 0
		aAdd(aEDTPai,AF9->AF9_EDTPAI)
	EndIf
	AAdd(aAllTasks,AF9->(Recno()))
	aAdd(aTasks ,AF9->AF9_TAREFA)
	If lMsAguarde .And. MOD(Len(aAllTasks),100) == 0
		MsProcTxt(STR0212 +Alltrim(Str(Len(aAllTasks)))+STR0213) //'Carregadas '##" tarefas"
	Endif
Else
	If lTopConn

		DbSelectArea("AF9")
		DbSetOrder(2)
		
		cWhere :="%"
		cWhere += "AF9.AF9_PROJET "+ cCharConcat +" AF9.AF9_REVISA "+ cCharConcat
		cWhere +="%"

		cAliasTmp := GetNextAlias()

		BeginSQL Alias cAliasTmp

		SELECT AF9.R_E_C_N_O_ RecAF9

		FROM %table:AF9% AF9

		WHERE AF9.AF9_FILIAL = %xfilial:AF9%
				AND %exp:cWhere% AF9.AF9_EDTPAI = %exp:cChave%
				AND AF9.%NotDel%
		ORDER BY %Order:AF9%

		EndSql

		While (cAliasTmp)->(!Eof())
			AF9->(DbGoTo((cAliasTmp)->RecAF9))

			If Empty(cFiltroAF9) .Or. &(cFiltroAF9)
				If aScan(aEDTPai,AF9->AF9_EDTPAI) <= 0
					aAdd(aEDTPai,AF9->AF9_EDTPAI)
				EndIf
				aAdd(aAllTasks,AF9->(Recno()))
				aAdd(aTasks,AF9->AF9_TAREFA)
				If lMsAguarde .And. MOD(Len(aAllTasks),100) == 0
					MsProcTxt(STR0212 +Alltrim(Str(Len(aAllTasks)))+STR0213) //'Carregadas '##" tarefas"
				Endif
			Endif

			(cAliasTmp)->(DbSkip())
		EndDo

		(cAliasTmp)->(DbCloseArea())


		DbSelectArea("AFC")
		DbSetOrder(2)
		
		cWhere :="%"
		cWhere += "AFC.AFC_PROJET "+ cCharConcat +" AFC.AFC_REVISA "+ cCharConcat
		cWhere +="%"

		cAliasTmp := GetNextAlias()

		BeginSQL Alias cAliasTmp

		SELECT AFC_PROJET, AFC_REVISA, AFC_EDT

		FROM %table:AFC% AFC

		WHERE AFC.AFC_FILIAL = %xfilial:AFC%
				AND %exp:cWhere% AFC.AFC_EDTPAI = %exp:cChave%
				AND AFC.%NotDel%
		ORDER BY %Order:AFC%

		EndSql

		While (cAliasTmp)->(!Eof())

			PmsLoadTrf((cAliasTmp)->AFC_PROJET+(cAliasTmp)->AFC_REVISA+(cAliasTmp)->AFC_EDT,aEDTPai,,aAllTasks,cFiltroAF9,lMsAguarde ,aTasks)

			(cAliasTmp)->(DbSkip())
		EndDo

		(cAliasTmp)->(DbCloseArea())


	Else

		dbSelecTArea("AF9")
		dbSetOrder(2)
		MsSeek(xFilial("AF9")+cChave)
		While !Eof() .And. AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_EDTPAI==;
						xFilial("AF9")+cChave
			If Empty(cFiltroAF9) .Or. &(cFiltroAF9)
				If aScan(aEDTPai,AF9->AF9_EDTPAI) <= 0
					aAdd(aEDTPai,AF9->AF9_EDTPAI)
				EndIf
				aAdd(aAllTasks,AF9->(Recno()))
				aAdd(aTasks,AF9->AF9_TAREFA)
				If lMsAguarde .And. MOD(Len(aAllTasks),100) == 0
					MsProcTxt(STR0212 +Alltrim(Str(Len(aAllTasks)))+STR0213) //'Carregadas '##" tarefas"
				Endif
			Endif
			dbSelecTArea("AF9")
			dbSkip()
		EndDo
		dbSelectArea("AFC")
		dbSetOrder(2)
		MsSeek(xFilial("AFC")+cChave)
		While !Eof() .And. AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+;
							AFC->AFC_EDTPAI==xFilial("AFC")+cChave
			PmsLoadTrf(AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,aEDTPai,,aAllTasks,cFiltroAF9,lMsAguarde ,aTasks)
			dbSkip()
		EndDo

	Endif
EndIf

RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aAreaAFA)
RestArea(aArea)
Return .T.


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥Pms2RCAPerc     ≥ Autor ≥Adriano Ueda          ≥ Data ≥ 01/12/2005 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Funcao que altera os custos do projeto aplicando percentual.       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥SIGAPMS                                                       	 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function Pms2RCAPerc(cFiltroAFA, cFiltroAE8, aParam, lSimula,cFltAFAUsr)
Local nCusto    := 0
Local cDesc     := ""
Local cAliasQry := ""

Default lSimula := .F.

cAliasQry := "AFA"

// filtra o arquivo de produtos para pesquisa otimizada
DbSelectArea("AE8")
DbSetOrder(1)
DbClearFilter()

If !Empty(cFiltroAE8)
	DbSetFilter({||&(cFiltroAE8)},cFiltroAE8)
	dbGoTop()
EndIf

// filtra os produtos do projeto para pesquisa otimizada
DbSelectArea("AFA")
DbSetOrder(1)
If lSimula
	MsSeek(xFilial("AFA") + AJB->AJB_PROJET + AJB->AJB_REVISA)
Else
	MsSeek(xFilial("AFA") + AF8->AF8_PROJET + AF8->AF8_REVISA)
EndIf

While !Eof()
	If !&(cFiltroAFA)
		dbSelectArea(cAliasQry)
		dbSkip()
		Loop
	EndIf
	If Empty((cAliasQry)->AFA_RECURS)
		dbSelectArea(cAliasQry)
		dbSkip()
		Loop
	EndIf
	If cFltAFAUsr	<> Nil .And. !Empty(cFltAFAUsr) .And. !&(cFltAFAUsr)
		dbSelectArea(cAliasQry)
		dbSkip()
		Loop
	Endif

	cDesc := AllTrim(Posicione("AE8", 1, xFilial("AE8") + (cAliasQry)->AFA_RECURS, "AE8_DESCRI"))

	If AFA->AFA_RECALC != "2"

		If aParam[3] == 1
			nCusto:= (cAliasQry)->AFA_CUSTD + (((cAliasQry)->AFA_CUSTD * aParam[4]) / 100)
		Else
			nCusto:= (cAliasQry)->AFA_CUSTD - (((cAliasQry)->AFA_CUSTD * aParam[4]) / 100)
		EndIf

		If (nCusto > 0)
			RecLock("AFA",.F.)
			Replace AFA->AFA_CUSTD With nCusto
			MsUnlock()
		EndIf
	EndIf

	IncProc(STR0052 + cDesc)  //"Atualizando "
	dbSelectArea(cAliasQry)
	dbSkip()
End

DbSelectArea("AE8")
DbSetOrder(1)
DbClearFilter()

Return .T.

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥RecodeProj      ≥ Autor ≥Adriano Ueda          ≥ Data ≥ 13/01/2006 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Funcao que gera um novo codigo para EDT/TAREFA do projeto.         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥SIGAPMS                                                            ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function RecodeProj(oTree, cArquivo)
Local aCampoTOP	:= {}
Local aTabelas	:= {}
Local cAlias		:= ""
Local cAuxCode	:= ""
Local cEDT			:= ""
Local cEntida		:= ""
Local cGetPict	:= ""
Local cNewCode	:= ""
Local cNivel		:= ""
Local cOldCode	:= ""
Local cProject	:= ""
Local cRev			:= ""
Local lContinua	:= .T.
Local lEdtPai		:= .F.
Local lNewCode	:= GetMV("MV_PMSTCOD") == "3"
Local lOk			:= .F.
Local lReturn		:= .F.
Local nAviso		:= 0
Local nRecno		:= 0
Local nTam_EDT	:= TamSX3("AFC_EDT")[1]
Local oDlg			:= Nil
Local oGet			:= Nil
Local oNewCode	:= ""

Private aTAREFA := {}
Private aEDT    := {}

If oTree != Nil
	cAlias := SubStr(oTree:GetCargo(), 1, 3)
	nRecno := Val(SubStr(oTree:GetCargo(), 4, 12))
Else
	cAlias := (cArquivo)->ALIAS
	nRecNo := (cArquivo)->RECNO
EndIf
If GetNewPar('MV_PMSRECO',1) == 2
	If !CheckNoIdx(@aTabelas)
		Return .F.
	Endif
Endif

Do Case
	Case cAlias == "AFC"
		dbSelectArea("AFC")
		dbGoTo(nRecNo)

		cOldCode := AFC->AFC_EDT
		cNewCode := Space(nTam_EDT)

		cGetPict := ""//X3Picture("AFC_EDT")

		cProject := AFC->AFC_PROJET
		cRev     := AFC->AFC_REVISA

		// Para ser EDT Principal deve estar comos campo AFC_EDTPAI vazio 
		// e o afc_nivel igual a 001
		If Empty(AFC->AFC_EDTPAI) .AND. AFC->AFC_NIVEL == StrZero(1,TamSX3("AFC_NIVEL")[1])
			lEdtPai := .T.
		EndIf

	Case cAlias == "AF9"
		dbSelectArea("AF9")
		dbGoTo(nRecNo)

		cOldCode := AF9->AF9_TAREFA
		cNewCode := Space(TamSX3("AF9_TAREFA")[1])

		cGetPict := ""//X3Picture("AF9_TAREFA")

		cProject := AF9->AF9_PROJET
		cRev     := AF9->AF9_REVISA

	Otherwise
		Aviso(STR0182,STR0315,{"OK"}) // "Recodificar" ## "Para execuÁ„o desta opÁ„o, deve estar posicionado em uma EDT ou tarefa."
		lContinua := .F.

EndCase

If ExistBlock("PM200RP")
	lContinua := ExecBlock("PM200RP", .F., .F., {lContinua})
EndIf

If lContinua

	If GetMV("MV_PMSTCOD") == "1" .AND. !lEdtPai
		Define MsDialog oDlg Title STR0211 From 0, 0 To 125, 300 Of oMainWnd Pixel //"Recodificar Tarefa/EDT"

			// codigo atual
			@ 010, 005 Say STR0210 Of oDlg Pixel //"Codigo atual:"
			@ 009, 045 MSGet cOldCode Of oDlg Size 100, 08 Pixel ReadOnly

			// novo codigo
			@ 022, 005 Say STR0185 Of oDlg Pixel //"Novo codigo:"

			If cAlias == "AF9"
				@ 021, 045 MSGet oNewCode Var cNewCode Valid !ExistPrjTrf(cProject, cRev, cNewCode) Of oDlg;
							Picture cGetPict Size 100, 08 Pixel
			Else
				@ 021, 045 MSGet oNewCode Var cNewCode Valid !ExistPrjEDT(cProject, cRev, cNewCode) Of oDlg;
							Picture cGetPict Size 100, 08 Pixel
			EndIf

			// OK
			@ 038, 065 Button "OK" Size 35 ,11 FONT oDlg:oFont Action (lOk := .T., oDlg:End()) Of oDlg Pixel;
						When !Empty(cNewCode)

			// Cancelar
			@ 038, 110 Button STR0078 Size 35 ,11 FONT oDlg:oFont Action (lOk := .F., oDlg:End()) Of oDlg Pixel //"Cancela"
		Activate MsDialog oDlg On Init oNewCode:SetFocus() Centered
	Else
		lOk := .T.
	EndIf

	// Cursor ampulheta
	CursorWait()

	If lOk

		lReturn  := .T.

		If cAlias == "AF9"

			dbSelectArea("AF9")
			dbGoTo(nRecNo)
			// gera o codigo automatico
			If GetMV("MV_PMSTCOD") == "2"
				cNewCode := PMSNumAF9(AF9->AF9_PROJET,;
											AF9->AF9_REVISA,;
											PMSGetNivel(AF9->AF9_PROJET, AF9->AF9_REVISA, AF9->AF9_EDTPAI),;
											AF9->AF9_EDTPAI,;
											IIf(Substr(AF9->AF9_TAREFA,1,3)=="ERR",,AF9->AF9_TAREFA),;
											.F.)
			EndIf
			If lNewCode
				lOk := PmsRetCode(@cNewCode,cOldCode,cProject,cRev,cAlias,AF9->AF9_NIVEL)
			EndIf

			If lOk

				aAdd(aTAREFA, {AF9->AF9_FILIAL,AF9->AF9_TAREFA, cNewCode, AF9->AF9_PROJET,AF9->AF9_REVISA})

				Begin Transaction

					// atualiza a TAREFA das outras tabelas relacionadas
					AF9RecRelTables(AF9->AF9_FILIAL, AF9->AF9_PROJET, AF9->AF9_REVISA, cOldCode, cNewCode , aTabelas,@aCampoTOP)

					cEntida := PmsGetEnt("AF9", AF9->(Recno()))
					aAdd(aCampoTOP, {"AF9", "AF9_TAREFA", "AF9_FILIAL", "AF9_PROJET", "AF9_REVISA", AF9->AF9_FILIAL, AF9->AF9_PROJET, AF9->AF9_REVISA+"' AND AF9_TAREFA = '"+AF9->AF9_TAREFA, , cNewCode}) // AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_TAREFA+AF9_ORDEM
					PMSAltera(@aCampoTOP,{})

					// Libera os codigo reservados
					FreeUsedCode(.T.)

					PmsAltAC9("AF9", AF9->(Recno()) ,cNewCode , cEntida)
				End Transaction
			EndIf
		Else

			dbSelectArea("AFC")
			dbGoTo(nRecNo)

			Begin Transaction

				cEntida := PmsGetEnt("AFC", AFC->(Recno()))
				// Se for EDT Principal, deve recodificar as edt/tarefas filhas
				If lEdtPai .and. !lNewCode
				
					If AFC->AFC_EDT <> padr(cProject,nTam_EDT)
						cOldCode := AFC->AFC_EDT
						cNewCode := padr(cProject,nTam_EDT)
						
						aAdd(aEDT, {AFC->AFC_FILIAL,cOldCode, cNewCode, AFC->AFC_PROJET,AFC->AFC_REVISA})

						// atualiza a EDT PAI das tarefas-filhas
						AFCAtuTrf(AFC->AFC_FILIAL, AFC->AFC_PROJET, AFC->AFC_REVISA, cOldCode, cNewCode, @aCampoTOP)

						// atualiza a EDT PAI das EDT Filhas e a EDT das outras tabelas relacionadas
						AFCRecRelTables(AFC->AFC_FILIAL, AFC->AFC_PROJET, AFC->AFC_REVISA, cOldCode, cNewCode, aTabelas, @aCampoTOP)
						aAdd(aCampoTOP, {"AFC", "AFC_EDT", "AFC_FILIAL", "AFC_PROJET", "AFC_REVISA", AFC->AFC_FILIAL, AFC->AFC_PROJET, AFC->AFC_REVISA+"' AND AFC_EDT = '"+AFC->AFC_EDT, , cNewCode }) // AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDTPAI+AFC_ORDEM
						PMSAltera(@aCampoTOP,{})

						PmsAltAC9("AFC", AFC->(Recno()) , cNewCode , cEntida )
					
					EndIf
					
					// atualiza a TAREFA/EDT filhas da EDT
					AFCReCode( cGetPict, padr(cProject,nTam_EDT), cProject, cRev, aTabelas, , , @aCampoTOP)

				ElseIf lNewCode //Modo "Semi-automatico"

					lOk := PmsRetCode(@cNewCode,cOldCode,cProject,cRev,cAlias,AFC->AFC_NIVEL)
					If lOk

						If lEdtPai
						
							// Se for EDT Principal, deve recodificar as edt/tarefas filhas
							// atualiza a TAREFA/EDT filhas da EDT
							AFCReCode( cGetPict, cNewCode, cProject, cRev, aTabelas, , , @aCampoTOP,lEdtPai)
						Else
							aAdd(aEDT, {AFC->AFC_FILIAL,cOldCode, cNewCode, AFC->AFC_PROJET,AFC->AFC_REVISA})

							// atualiza a EDT PAI das tarefas-filhas
							AFCAtuTrf(AFC->AFC_FILIAL, AFC->AFC_PROJET, AFC->AFC_REVISA, cOldCode, cNewCode, @aCampoTOP)

							// atualiza a EDT PAI das EDT Filhas e a EDT das outras tabelas relacionadas
							AFCRecRelTables(AFC->AFC_FILIAL, AFC->AFC_PROJET, AFC->AFC_REVISA, cOldCode, cNewCode, aTabelas, @aCampoTOP)
							aAdd(aCampoTOP, {"AFC", "AFC_EDT", "AFC_FILIAL", "AFC_PROJET", "AFC_REVISA", AFC->AFC_FILIAL, AFC->AFC_PROJET, AFC->AFC_REVISA+"' AND AFC_EDT = '"+AFC->AFC_EDT, , cNewCode }) // AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDTPAI+AFC_ORDEM
							PMSAltera(@aCampoTOP,{})

							PmsAltAC9("AFC", AFC->(Recno()) , cNewCode , cEntida )
							// Libera o codigo reservado
							FreeUsedCode(.T.)

							cNewCode := AFC->AFC_EDT

							// atualiza a TAREFA/EDT filhas da EDT
							AFCReCode( cGetPict, cNewCode, cProject, cRev, aTabelas, aEDT, aTAREFA, @aCampoTOP)
						EndIf
					EndIf

				Else
					//"Atencao!"               "Deseja que a EDT ### seja incluÌda na recodificaÁ„o?" Sim/Nao/Cancelar
					nAviso := Aviso( STR0069 , STR0224+" "+AllTrim(AFC->AFC_EDT)+" "+STR0225, { STR0150,STR0151,STR0030 }, 2 )

					If nAviso == 1
						// gera o codigo automatico
						If GetMV("MV_PMSTCOD") == "2"
							cNewCode := PMSNumAFC(AFC->AFC_PROJET,;
											AFC->AFC_REVISA,;
											PMSGetNivel(AFC->AFC_PROJET, AFC->AFC_REVISA, AFC->AFC_EDTPAI),;
											AFC->AFC_EDTPAI,;
											IIf(Substr(AFC->AFC_EDT,1,3)=="ERR",,AFC->AFC_EDT),;
											.F.)
						EndIf

						aAdd(aEDT, {AFC->AFC_FILIAL,cOldCode, cNewCode, AFC->AFC_PROJET,AFC->AFC_REVISA})

						// atualiza a EDT PAI das tarefas-filhas
						AFCAtuTrf(AFC->AFC_FILIAL, AFC->AFC_PROJET, AFC->AFC_REVISA, cOldCode, cNewCode, @aCampoTOP)

						// atualiza a EDT PAI das EDT Filhas e a EDT das outras tabelas relacionadas
						AFCRecRelTables(AFC->AFC_FILIAL, AFC->AFC_PROJET, AFC->AFC_REVISA, cOldCode, cNewCode, aTabelas, @aCampoTOP)

						aAdd(aCampoTOP, {"AFC", "AFC_EDT", "AFC_FILIAL", "AFC_PROJET", "AFC_REVISA", AFC->AFC_FILIAL, AFC->AFC_PROJET, AFC->AFC_REVISA+"' AND AFC_EDT = '"+AFC->AFC_EDT, , cNewCode }) // AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDTPAI+AFC_ORDEM
						PMSAltera(@aCampoTOP,{})

						PmsAltAC9("AFC", AFC->(Recno()) , cNewCode , cEntida )
						// Libera o codigo reservado
						FreeUsedCode(.T.)

					ElseIf nAviso == 3
						Return .F.
					EndIf

					// a variavel cCodigo eh utilizada em chave e portanto precisa dos campos em branco tambem
					cNewCode := AFC->AFC_EDT

					// atualiza a TAREFA/EDT filhas da EDT
					AFCReCode( cGetPict, cNewCode, cProject, cRev, aTabelas, aEDT, aTAREFA, @aCampoTOP)

				EndIf

			End Transaction
		EndIf
	EndIf

	// Cursor seta
	CursorArrow()
	If ExistBlock("PMS200AT")
		ExecBlock("PMS200AT",.F.,.F.,{aEDT,aTAREFA})
	EndIf

EndIf

PMS200Rev()

Return lReturn


/*/{Protheus.doc} AFCReCode
Funcao que gera um novos codigos para EDT/TAREFA filhas referentes ao codigo da EDT informado do projeto.

@param cGetPict, character, (DescriÁ„o do par‚metro)
@param cNewCode, character, codigo novo gerado para a EDT pai
@param cProject, character, codigo do projeto
@param cRev, character,  codigo da revisao do projeto
@param aTabelas, array, (DescriÁ„o do par‚metro)
@param aEDT, array, (DescriÁ„o do par‚metro)
@param aTAREFA, array, (DescriÁ„o do par‚metro)
@param aCampoTOP, array, array de registros que serao atualizados
@param lEdtPai, logico, (DescriÁ„o do par‚metro)
@return ${return}, ${return_description}

@author reynaldo
@since 16/01/2006
@version 1.0
/*/
Function AFCReCode( cGetPict ,cNewCode ,cProject ,cRev ,aTabelas ,aEDT,aTAREFA, aCampoTOP, lEdtPai)
Local nLoop      := 0
Local aFilhos    := {}
Local aParam     := {}
Local aConfig    := {}
Local cCodigo    := ""
Local cEDTPai    := ""
Local cEntida		:= ""
Local cFilialAF9	:= xFilial("AF9")
Local cFilialAFC	:= xFilial("AFC")
Local cMV_PMSTCOD	:= GetMV("MV_PMSTCOD")
Local cPrjEDTPai	:= ""
Local lNewCode		:= GetMV("MV_PMSTCOD") == "3"
Local lFirst		:= .F.

Default aEDT		:= {}
Default aTAREFA		:= {}
Default aCampoTOP	:= {}
Default lEdtPai		:= .F.

If lNewCode .And. lEdtPai

	cPrjEDTPai := PadR(cProject,TamSX3("AFC_EDTPAI")[1])

	// obtem todas EDT filhas
	dbSelectArea("AFC")
	dbSetOrder(2) //AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDTPAI+AFC_ORDEM
	dbSeek(cFilialAFC+cProject+cRev+cPrjEDTPai)
	While AFC->(!Eof()) .AND. ;
	      AFC->(AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDTPAI)==cFilialAFC+cProject+cRev+cPrjEDTPai

		aAdd(aFilhos ,{ "AFC" ;
					   ,iIf(Empty(AFC->AFC_ORDEM), "000", AFC->AFC_ORDEM);
					   ,AFC->AFC_EDT ;
					   ,AFC->(recno()) } )
		dbSkip()
	End

	// obtem todas tarefas filhas
	dbSelectArea("AF9")
	dbSetOrder(2) //AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_EDTPAI+AF9_ORDEM
	dbSeek(cFilialAF9+cProject+cRev+cPrjEDTPai)
	While AF9->(!Eof()) .AND. ;
		AF9->(AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_EDTPAI)==cFilialAF9+cProject+cRev+cPrjEDTPai
		aAdd(aFilhos ,{ "AF9" ;
						,If(Empty(AF9->AF9_ORDEM), "000", AF9->AF9_ORDEM);
						,AF9->AF9_TAREFA ;
						,AF9->(recno()) } )
		dbSkip()
	End
	lFirst := .T.
Else
	// obtem todas EDT filhas
	dbSelectArea("AFC")
	dbSetOrder(2) //AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDTPAI+AFC_ORDEM
	dbSeek(cFilialAFC+cProject+cRev+cNewCode)
	While AFC->(!Eof()) .AND. ;
	      AFC->(AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDTPAI)==cFilialAFC+cProject+cRev+cNewCode

		aAdd(aFilhos ,{ "AFC" ;
					   ,iIf(Empty(AFC->AFC_ORDEM), "000", AFC->AFC_ORDEM);
					   ,AFC->AFC_EDT ;
					   ,AFC->(recno()) } )
		dbSkip()
	End

	// obtem todas tarefas filhas
	dbSelectArea("AF9")
	dbSetOrder(2) //AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_EDTPAI+AF9_ORDEM
	dbSeek(cFilialAF9+cProject+cRev+cNewCode)
	While AF9->(!Eof()) .AND. ;
		AF9->(AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_EDTPAI)==cFilialAF9+cProject+cRev+cNewCode
		aAdd(aFilhos ,{ "AF9" ;
							,If(Empty(AF9->AF9_ORDEM), "000", AF9->AF9_ORDEM);
							,AF9->AF9_TAREFA ;
							,AF9->(recno()) } )
		dbSkip()
	End
EndIf

// ordena por nivel e codigo EDT/Tarefa
aSort(aFilhos,,, {|x, y| x[2]+x[3] < y[2]+y[3] })

cCodigo := cNewCode

For nLoop := 1 To len(aFilhos)

	If aFilhos[nLoop, 1] == "AFC"

		dbSelectArea("AFC")
		dbGoto(aFilhos[nLoop, 4])

		cEDTPai := AFC->AFC_EDTPAI

		// Se for a EDT Principal do projeto
		If padr(AFC->AFC_PROJET,TamSX3("AFC_EDT")[1]) == cCodigo
			cCodigo := ""
			cEdtPai := ""
		EndIf

		// Caso exista uma EDT filha de outra EDT
		If cCodigo == cEdtPai
			cCodigo := ""
		EndIf

		If cMV_PMSTCOD == "1"
			aParam := {;
						{1, STR0183 , cProject, "@!",,"", ".F.", 55 ,.F.},; //"Projeto:"
						{1, STR0184 , AFC->AFC_EDT, "@!",,"", ".F.", 55 ,.F.},; //"Cod. Anterior:"
						{1, STR0185 , Space(TamSX3("AFC_EDT")[1]), "@!" ,'ExistChav("AFC", "' + cProject + cRev + '"+ mv_par03 ) .And.FreeForUse("AFC","'+ cProject + cRev + '" + mv_par03)',"","", 55 ,.T.}; //"Novo Codigo:"
						}
			aConfig := {}

			If ParamBox(aParam, STR0186 , aConfig,,,.F.,90,15,,ProcName(0)+"AFC",.F.) //"Renomear codigo da EDT"
				cCodigo := aConfig[3]
			Else
				Exit
			EndIf

		ElseIf cMV_PMSTCOD == "2" .Or. lNewCode
			If !lFirst
				cCodigo := PMSNumAFC(AFC->AFC_PROJET,;
										AFC->AFC_REVISA,;
										PMSGetNivel(AFC->AFC_PROJET, AFC->AFC_REVISA, AFC->AFC_EDTPAI),;
										cEDTPai,;
										cCodigo,;
										.F.,;
										.T.)
			Else
				lFirst := .F.
			EndIf
		EndIf

		aAdd(aEDT, {AFC->AFC_FILIAL,AFC->AFC_EDT, cCodigo, AFC->AFC_PROJET,AFC->AFC_REVISA})

		// atualiza a EDT PAI das tarefas-filhas
		AFCAtuTrf(AFC->AFC_FILIAL, AFC->AFC_PROJET, AFC->AFC_REVISA, aFilhos[nLoop, 3], cCodigo,@aCampoTOP)

		// atualiza a EDT PAI das EDT Filhas e a EDT das outras tabelas relacionadas
		AFCRecRelTables(AFC->AFC_FILIAL, AFC->AFC_PROJET, AFC->AFC_REVISA, aFilhos[nLoop, 3], cCodigo,aTabelas,@aCampoTOP)

		cEntida := PmsGetEnt("AFC", AFC->(Recno()))
		aAdd(aCampoTOP, {"AFC", "AFC_EDT", "AFC_FILIAL", "AFC_PROJET", "AFC_REVISA", AFC->AFC_FILIAL, AFC->AFC_PROJET, AFC->AFC_REVISA+"' AND AFC_EDT = '"+AFC->AFC_EDT, , cCodigo}) // AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDTPAI+AFC_ORDEM
		PMSAltera(@aCampoTOP,{})
		PmsAltAC9("AFC", AFC->(Recno()) ,cCodigo , cEntida)

		// Libera o codigo reservado
		FreeUsedCode(.T.)

		// atualiza a TAREFA/EDT filhas da EDT
		AFCReCode( cGetPict, AFC->AFC_EDT, cProject, cRev, aTabelas, , , @aCampoTOP )

	ElseIf aFilhos[nLoop, 1] == "AF9"

		dbSelectArea("AF9")
		dbGoto(aFilhos[nLoop, 4])

		cEDTPai := AF9->AF9_EDTPAI

		// Se for a EDT Principal do projeto
		If padr(AF9->AF9_PROJET,TamSX3("AF9_TAREFA")[1]) == cCodigo
			cCodigo := ""
			cEdtPai := ""
		EndIf

		// caso seja a primeira tarefa da EDT
		If nLoop == 1
			cCodigo := ""
		EndIf

		If cMV_PMSTCOD == "1"
			aParam := {;
						{1, STR0183 , cProject, "@!",,"", ".F.", 55 ,.F.},; // "Projeto:"
						{1, STR0184 , AF9->AF9_TAREFA, "@!",,"", ".F.", 55 ,.F.},; // "Cod. Anterior:"
						{1, STR0185 , Space(TamSX3("AF9_TAREFA")[1]), "@!" ,'ExistChav("AF9", "' + cProject + cRev + '"+ mv_par03 ) .And.FreeForUse("AF9","'+ cProject + cRev + '" + mv_par03)',"","", 55 ,.T.}; // "Novo Codigo:"
						}
			aConfig := {}

			If ParamBox(aParam, STR0187 , aConfig,,,.F.,90,15,,ProcName(0)+"AF9",.F.) // "Renomear codigo da Tarefa"
				cCodigo := aConfig[3]
			Else
				Exit
			EndIf

		ElseIf cMV_PMSTCOD == "2" .Or. lNewCode
		   If !lFirst
				cCodigo := PMSNumAF9(AF9->AF9_PROJET,;
										AF9->AF9_REVISA,;
										PMSGetNivel(AF9->AF9_PROJET, AF9->AF9_REVISA, AF9->AF9_EDTPAI),;
										cEDTPai /*Iif(AFC->AFC_NIVEL=="002", "", cEDTPai)*/,;
										cCodigo,;
										.F.)
			Else
				lFirst := .F.
			EndIf
		Endif

		aAdd(aTAREFA, {AF9->AF9_FILIAL,AF9->AF9_TAREFA, cCodigo, AF9->AF9_PROJET,AF9->AF9_REVISA})

		// atualiza a TAREFA das outras tabelas relacionadas
		AF9RecRelTables(AF9->AF9_FILIAL, AF9->AF9_PROJET, AF9->AF9_REVISA, aFilhos[nLoop, 3], cCodigo,aTabelas,@aCampoTOP)

		cEntida := PmsGetEnt("AF9", AF9->(Recno()))
		aAdd(aCampoTOP, {"AF9", "AF9_TAREFA", "AF9_FILIAL", "AF9_PROJET", "AF9_REVISA", AF9->AF9_FILIAL, AF9->AF9_PROJET, AF9->AF9_REVISA+"' AND AF9_TAREFA = '"+AF9->AF9_TAREFA, , cCodigo}) // AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_TAREFA+AF9_ORDEM
		PMSAltera(@aCampoTOP,{})

		PmsAltAC9("AF9", AF9->(Recno()) ,cCodigo , cEntida)
		// Libera o codigo reservado
		FreeUsedCode(.T.)

	EndIf

Next nLoop

Return( .T. )

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ ExistPrjEDT ≥ Autor ≥ Adriano Ueda         ≥ Data ≥ 07-06-2004 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Funcao para verificar a existencia de determinada tarefa.      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ cProjeto : codigo do projeto                                   ≥±±
±±≥          ≥ cRevisa  : revisao                                             ≥±±
±±≥          ≥ cTarefa  : codigo da tarefa                                    ≥±±
±±≥          ≥ lMensagem: indica se exibira o help de ja gravado              ≥±±
±±≥          ≥            (default: .T.)                                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function ExistPrjEDT(cProjeto, cRevisa, cEDT, lMensagem)
	Local aAreaAFC := AFC->(GetArea())
	Default lMensagem := .T.

	dbSelectArea("AFC")
	AFC->(dbSetOrder(1))

	If AFC->(Msseek(xFilial("AFC") + cProjeto + cRevisa + cEDT))
		If lMensagem
			Help(" ", 1, "JAGRAVADO")
		EndIf

		lRet := .T.
	Else
		If !(FreeForUse("AFC", cProjeto + cRevisa + cEDT))
			MsgAlert(STR0247) //"CÛdigo Reservado!"
			lRet := .T.
		Else
			lRet := .F.
		EndIf
	EndIf

	RestArea(aAreaAFC)
Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ AFCAtuTrf ≥ Autor ≥ Adriano Ueda         ≥ Data ≥ 13-01-2004 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Funcao para atualizar a EDT PAI das tarefas-filhas           ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ cFil      : filial                                           ≥±±
±±≥          ≥ cProjeto  : codigo do projeto                                ≥±±
±±≥          ≥ cRevisa   : revisao                                          ≥±±
±±≥          ≥ cEDT      : codigo da EDT                                    ≥±±
±±≥          ≥ cNewEDT   : codigo gerado da nova EDT                        ≥±±
±±≥          ≥ aCampoTop : array com os campos e valores que serao          ≥±±
±±≥          ≥             atualizados por update(Top)                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function AFCAtuTrf(cFil, cProject, cRev, cEDT, cNewEDT, aCampoTOP)
Local aParam, aCamposUsr
Local aCampos   := {} //array para o ponto de entrada PM200AFC
Local aCampoDBF := {} //array para atualizacao em DBF
Default aCampoTop := {}

aAdd(aCampos, {"AF9", 2, "AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_EDTPAI", "AF9_EDTPAI", cFil + cProject + cRev + cEDT, cNewEDT}) // AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_EDTPAI+AF9_ORDEM
aAdd(aCampoTOP, {"AF9", "AF9_EDTPAI", "AF9_FILIAL", "AF9_PROJET", "AF9_REVISA", cFil, cProject, cRev+"' AND AF9_EDTPAI = '"+cEDT, , cNewEDT}) // AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_EDTPAI+AF9_ORDEM

//Ponto de Entrada para manipulacao do array aCampoDBF
//passado aCampos e aParam contendo os parametros recebidos pela funcao
aParam := { cFil, cProject, cRev, cEDT, cNewEDT }

If ExistBlock("PM200_AFC")
	aCamposUsr := ExecBlock("PM200_AFC", .F., .F., {aCampos, aParam})
	AEval( aCamposUsr, { |x| AAdd( aCampoDBF, aClone(x) ) } )
EndIf

PMSAltera({},aCampoDBF)

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ AFFAltMen ≥ Autor ≥ Adriano Ueda         ≥ Data ≥ 31/01/2006 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Funcao para travar a desabilitar o menu                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ cProjeto : codigo do projeto                                 ≥±±
±±≥          ≥ cRevisa  : revisao                                           ≥±±
±±≥          ≥ cTarefa  : codigo da tarefa                                  ≥±±
±±≥          ≥ lMensagem: indica se exibira o help de ja gravado            ≥±±
±±≥          ≥            (default: .T.)                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function AFFAltMenu(oTree, cFile)
	Local lReturn   := .F.
	Local cAlias    := ""
	Local nRecAlias := 0
	Local aAreaAF9  := AF9->(GetArea())

	If SuperGetMV("MV_PMSCONF",.F.,"1")== "1" //nao verifica apontamentos e retorna .t. - DEFAULT
		lReturn   := .T.
	Else

		If oTree != Nil
			cAlias	  := SubStr(oTree:GetCargo(), 1, 3)
			nRecAlias	:= Val(SubStr(oTree:GetCargo(), 4, 12))
		Else
			cAlias    := (cFile)->ALIAS
			nRecAlias := (cFile)->RECNO
		EndIf

		If cAlias == "AF9"

			dbSelectArea("AF9")
			dbGoto(nRecAlias)

			(lReturn := !PMSExistAFF(AF9->AF9_PROJET, AF9->AF9_REVISA,;
			                            AF9->AF9_TAREFA, DToC(PMS_MIN_DATE)))
		EndIf
	EndIf

	RestArea(aAreaAF9)

Return lReturn


/*/{Protheus.doc} PMS200Subs
Funcao que substitui um produto/recurso por outro informado

@param cRevisao, character, (DescriÁ„o do par‚metro)
@return ${return}, ${return_description}

@author reynaldo
@since 10.03.2006
@version 1.0
/*/
Function PMS200Subs(cRevisao)
Local aArea		:= GetArea()
Local aAreaAFA
Local aAreaSB1	:= {}
Local aParam		:= {}
Local aRetCus		:= {}
Local bCampo		:= {|n| FieldName(n) }
Local cItem
Local lAFAMsBlQl	:= AFA->(FieldPos("AFA_MSBLQL")) > 0
Local lMostra 	:= .F.
Local lPms200Sub	:= Existblock("Pms200Sub")
Local lRejeicao	:= AF8->AF8_PAR002=="1" .Or. AF8->AF8_PAR002=="2"
Local lResp
Local lUpdate		:= .F.
Local nX

DEFAULT cRevisao := AF8->AF8_REVISA

	If ! Empty(aParam := PMSSubRec(.F.))

		// Substituir o produto
		If aParam[1]
			dbSelectArea("SB1")
			dbSetOrder(1)
			MSSeek(xFilial("SB1")+aParam[3])
		EndIf

		// Substituir o recurso
		If aParam[4]
			dbSelectArea("AE8")
			dbSetOrder(1)
			MSSeek(xFilial("AE8")+aParam[6])
		EndIf

		ProcRegua( AF9->(LastRec()) )

		//
		// busca tarefa a tarefa
		//
		dbSelectArea("AF9")
		dbSetOrder(1)
		MSSeek(xFilial("AF9")+AF8->AF8_PROJET+cRevisao  )
		While AF9->(!Eof()) .AND. (AF9->(AF9_FILIAL+AF9_PROJET+AF9->AF9_REVISA)==xFilial("AF9")+AF8->AF8_PROJET+cRevisao)

			IncProc()

			//
			// busca os produtos e/ou recursos
			//
			dbSelectArea("AFA")
			dbSetOrder(1)
			MSSeek(xFilial("AFA")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)

			While AFA->(!Eof()) .AND. (AFA->AFA_FILIAL+AFA->AFA_PROJET+AFA->AFA_REVISA+AFA->AFA_TAREFA==xFilial("AFA")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)

				// substitui o produto
				If aParam[1] .and.Empty(AFA->AFA_RECURS)
					If aParam[2] == AFA->AFA_PRODUT
						If Empty(AFA->AFA_PLANEJ) .And. PmsVldFase("AF8", AF9->AF9_PROJET, "28")
							PmsAvalAFA("AFA",2)

							RecLock("AFA",.F.)
								AFA->AFA_PRODUT := SB1->B1_COD
								AFA->AFA_MOEDA	:= Val(RetFldProd(SB1->B1_COD,"B1_MCUSTD"))
								AFA->AFA_CUSTD	:= RetFldProd(SB1->B1_COD,"B1_CUSTD")

							MsUnlock()

							If lPms200Sub
								ExecBlock("Pms200Sub", .F., .F.,{"P"})
							EndIf
							PmsAvalAFA("AFA",1)

							lUpdate := .T.
						Else
							lMostra := .T.
						EndIf
					EndIf
				EndIf

				// substitui o recurso
				If aParam[4] .And. !Empty(AFA->AFA_RECURS)
					If aParam[5] == AFA->AFA_RECURS
						If PmsVldFase("AF8", AF9->AF9_PROJET, "28")

							If lRejeicao
								aAreaAFA := AFA->(GetArea())
								cItem:=strzero(0,AFA->(TamSX3("AFA_ITEM")[1]))
								AFA->(DbSetOrder(1))
								AFA->(DbSeek(xFilial("AFA")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)))
								Do While AFA->(!Eof()) .And. xFilial("AFA")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)==AFA->(AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA)
									cItem := AFA->AFA_ITEM
									AFA->(DbSkip())
								EndDo
								cItem := Soma1(cItem)
								RestArea(aAreaAFA)

								lResp := AFA->AFA_RESP == "1"
								RegToMemory( "AFA", .F.)
								RecLock("AFA",.F.)
								AFA->AFA_RESP := "2"
								If lAFAMsBlQl
									AFA->AFA_MSBLQL := "1"
								EndIf
								MsUnLock()

								dbSelectArea("AFA")
								RecLock("AFA",.T.)
								For nx := 1 TO FCount()
									FieldPut(nx,M->&(EVAL(bCampo,nx)))
								Next nx
								AFA->AFA_FILIAL	:= xFilial("AFA")
								AFA->AFA_RESP	:= IIf(lResp, "1", "2")
								AFA->AFA_ITEM	:= cItem
							Else
								RecLock("AFA",.F.)
								PmsAvalAFA("AFA",2)
							EndIf

							AFA->AFA_RECURS	:= AE8->AE8_RECURS
							AFA->AFA_PRODUT := AE8->AE8_PRODUT
							AFA->AFA_CUSTD  := AE8->AE8_VALOR

							If Empty(AFA->AFA_PRODUT)
								AFA->AFA_MOEDA := 1
							Else
								aAreaSB1 := SB1->(GetArea())
								dbSelectArea("SB1")
								dbSetOrder(1)
								If MSSeek(xFilial("SB1")+AFA->AFA_PRODUT)
									AFA->AFA_MOEDA := Val(RetFldProd(SB1->B1_COD,"B1_MCUSTD"))
									If AFA->AFA_CUSTD == 0
										AFA->AFA_CUSTD := RetFldProd(SB1->B1_COD,"B1_CUSTD")
									EndIf
								Else
									AFA->AFA_MOEDA := 1
									AFA->AFA_CUSTD := 0
								EndIf
								RestArea(aAreaSB1)
							EndIf

							If hasTemplate("CCT") .and. ExistTemplate("CCT200_3")
								ExecTemplate("CCT200_3",.F.,.F.)
							EndIf

							MsUnlock()

							If lPms200Sub
								ExecBlock("Pms200Sub", .F., .F.,{"R"})
							EndIf

							// Realiza alteracao do recurso quando houver integracao
							If SuperGetMV("MV_QTMKPMS",.F.,1) == 3 .Or. SuperGetMV("MV_QTMKPMS",.F.,1) == 4
								DbSelectArea( "QI5" )
								QI5->( DbSetOrder( 4 ) ) //QI5_FILIAL+QI5_CODIGO+QI5_REV+QI5_TPACAO
								If QI5->( DbSeek( xFilial( "QI5" ) + AF9->( AF9_ACAO + AF9_REVACA + AF9_TPACAO ) ) )
									While QI5->( !Eof() ) .And. QI5->( QI5_FILIAL + QI5_CODIGO + QI5_REV + QI5_TPACAO ) == xFilial( "QI5" ) + AF9->( AF9_ACAO + AF9_REVACA + AF9_TPACAO )
										If QI5->( QI5_PROJET + QI5_PRJEDT + QI5_TAREFA ) == AF9->( AF9_PROJET + AF9_EDTPAI + AF9_TAREFA )
											RecLock( "QI5", .F. )
											QI5->QI5_MAT := RDZRetEnt( "AE8", xFilial( "AE8" ) + AFA->AFA_RECURS, "QAA",,,, .F. )
											MsUnLock()
										EndIf
										QI5->(dbSkip())
									End
							    EndIf
							EndIf

							PmsAvalAFA("AFA",1)
							lUpdate := .T.

						EndIf
					EndIf
				EndIf

				dbSelectArea("AFA")
				dbSkip()
			End

			If lUpdate
				//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				//≥Grava o custo da tarefa.≥
				//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
				If hasTemplate("CCT") .and. ExistTemplate("PMAAF9CTrf")
					ExecTemplate("PMAAF9CTrf",.F.,.F.,{AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA})
				Else
					aRetCus	:= PmsAF9CusTrf(0 ,AF9->AF9_PROJET ,AF9->AF9_REVISA ,AF9->AF9_TAREFA)
					RecLock("AF9",.F.)
					Replace AF9->AF9_CUSTO  With aRetCus[1]
					Replace AF9->AF9_CUSTO2 With aRetCus[2]
					Replace AF9->AF9_CUSTO3 With aRetCus[3]
					Replace AF9->AF9_CUSTO4 With aRetCus[4]
					Replace AF9->AF9_CUSTO5 With aRetCus[5]
					AF9->AF9_VALBDI:= aRetCus[1]*IF(AF9->AF9_BDI<>0,AF9->AF9_BDI,PmsGetBDIPad('AFC',AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_EDTPAI,AF9->AF9_UTIBDI))/100
					AF9->AF9_TOTAL := aRetCus[1]+AF9->AF9_VALBDI

					MsUnlock()
			 	EndIf

			 	PmsAvalTrf("AF9",1,,.F.,!(Type("lPMS203Auto") == "L" .And. lPMS203Auto))
				lUpdate := .F.
			EndIf

			dbSelectArea("AF9")
			dbSkip()
		End

		If lMostra == .T.
			MsgAlert(STR0236,STR0069) //"Os produtos que possuÌam planejamento n„o puderam ser substituÌdos."
		EndIf

	EndIf

	RestArea(aArea)

Return( .T. )

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥RecalcAut≥ Autor ≥ Cristiano Denardi      ≥ Data ≥ 23.05.2006 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Verifica se o recalculo de custos ou tempos serah feito de    ≥±±
±±≥          ≥forma automatica                                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥Generico                                                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function RecalcAut( cPrj )

Local lRet    := .F.
Local cChave  := ""

cChave := xFilial("AF8") + cPrj
If ReadValue( "AF8", 1, cChave, "AF8_AUTCUS") == "1"
	lRet := .T.
Endif

Return( lRet )

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥PmsAponRec ∫Autor ≥Bruno Sobieski      ∫ Data ≥  11/08/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Consulta de apontamento de recursos                         ∫±±
±±∫          ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PmsAponRec(oTree,cArquivo)
Local aTarefas	:= {}
Local cAlias	:= ""  
Local nRecAlias := 0  
Local aAllEdt	:= {}
Local aParam1	:= {}
Local nX        := 0
Local aArea     := GetArea()
Local aAreaAF8  := AF8->(GetArea())
Local aAreaAFC  := AFC->(GetArea())
Local aAreaAF9  := AF9->(GetArea())
Local aAreaAE8  := AE8->(GetArea())
Local aAreaAED  := AED->(GetArea())

	If	  ParamBox( {	{3,STR0192,1,{STR0058,STR0194},130,"",.T.},;       //"Agrupar por" ##   ## "Equipes"
							{3,STR0193,1,{STR0195,STR0196,STR0197,STR0198},130,"",.T.},;       //"Ordenar por"##"Recursos/equipe"##"Descricao"##"Horas"##"Custo"
							{1,STR0199, PMS_MIN_DATE, "", "", "", "", 50, .F.},; //"Data apontamento de"
							{1,STR0200, dDataBase, "", "", "", "", 50, .F.},;   //"Data apontamento ate"
							{1,STR0168, CriaVar("AE8_RECURS",.F.), "@!", "", "AE8", "", 80, .F.},;  //"Recurso De"
							{1,STR0169, Replicate("Z", TamSX3("AE8_RECURS")[1]), "@!", "", "AE8", "", 80, .F.},;  //"Recurso Ate"
							{1,STR0201, CriaVar("AED_EQUIP",.F.), "@!", "", "AED", "", 80, .F.},; //"Equipe de "
							{1,STR0202, Replicate("Z", TamSX3("AED_EQUIP")[1]), "@!", "", "AED", "", 80, .F.},; // "Equipe ate "
							{7,STR0203,"AF9","",".T."}	}, STR0012, @aParam1)  //"Filtro tarefas"
		If oTree!= Nil
			cAlias	:= SubStr(oTree:GetCargo(),1,3)
			nRecAlias	:= Val(SubStr(oTree:GetCargo(),4,12))
		Else
			cAlias := (cArquivo)->ALIAS
			nRecAlias := (cArquivo)->RECNO
		EndIf

		MsProcTxt(STR0154) //"Carregando Tarefas..."
		If cAlias == "AF8"
			dbSelectArea("AF8")
			dbGoto(nRecAlias)
			dbSelectArea("AFC")
			dbSetOrder(1)
			dbSeek(xFilial()+AF8->AF8_PROJET+cRevisa+Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT)))
			PmsLoadTrf(AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,aAllEDT,,aTarefas,aParam1[9],.T.)
		ElseIf cAlias == "AFC"
			dbSelectArea("AFC")
			dbGoto(nRecAlias)
			PmsLoadTrf(AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT,aAllEDT,,aTarefas,aParam1[9],.T.)
		ElseIf cAlias == "AF9"
			dbSelectArea("AF9")
			dbGoto(nRecAlias)
			PmsLoadTrf(AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA,aAllEDT,.T.,aTarefas,aParam1[9],.T.)
		Endif

		dbSelectArea("AE8")
		dbSetOrder(1)
		dbSelectArea("AED")
		dbSetOrder(1)
		Processa({|| AuxApontRec(aTarefas,aParam1)},STR0204) //'Lendo apontamentos...'

	Endif

RestArea(aAreaAED)
RestArea(aAreaAE8)
RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aAreaAF8)
RestArea(aArea)
Return

Static Function AuxApontRec(aTarefas,aParam1)
Local nX			:=	1
Local nposRec	:=	1
Local aArrayTrb:=	{}
Local aView	:=	{}
Local aButtons	:=	{}
Local lAsc		:= .T.
Local lJa		:= .F.
Local aArea    := GetArea()
Local aAreaAF9 := AF9->(GetArea())
Local aAreaAED := AED->(GetArea())
Local aAreaAE8 := AE8->(GetArea())
Local aAreaAFU := AFU->(GetArea())
Local cCodigo	 := ""
Local cObfNRecur := IIF(FATPDIsObfuscate("AE8_DESCRI",,.T.),FATPDObfuscate("RESOURCE NAME","AE8_DESCRI",,.T.),"")        

	ProcRegua(Len(aTarefas))
	For nX := 1 To Len(aTarefas)
		AF9->(MsGoTo(aTarefas[nX]))
		IncProc()
		cQry := "SELECT  AFU.AFU_RECURS, AE8.AE8_EQUIP, AE8.AE8_DESCRI, "
		cQry += " SUM(AFU.AFU_CUSTO1) AFU_CUSTO1,SUM(AFU.AFU_CUSTO2) AFU_CUSTO2,SUM(AFU.AFU_CUSTO3) AFU_CUSTO3,SUM(AFU.AFU_CUSTO4) AFU_CUSTO4,SUM(AFU.AFU_CUSTO5) AFU_CUSTO5, SUM(AFU.AFU_HQUANT) AFU_HQUANT"
		cQry += "FROM "+RetSqlName("AFU")+" AFU "
		cQry += "INNER JOIN "+RetSqlName("AE8")+" AE8 ON "
		cQry += "AE8.AE8_RECURS = AFU.AFU_RECURS "

		cQry += "WHERE "
		cQry += "AFU.AFU_FILIAL = '"+xFilial("AFU")+"' AND "
		cQry += "AFU.AFU_PROJET = '"+AF9->AF9_PROJET+"' AND "
		cQry += "AFU.AFU_REVISA = '"+AF9->AF9_REVISA+"' AND "
		cQry += "AFU.AFU_TAREFA = '"+AF9->AF9_TAREFA+"' AND "
		cQry += "AFU.AFU_CTRRVS = '1' AND "
		cQry += "AFU.AFU_DATA   BETWEEN '"+dtos(aParam1[3])+"' AND '"+dtos(aParam1[4])+"' AND "
		cQry += "AFU.AFU_RECURS BETWEEN '"+aParam1[5]+"' AND '"+aParam1[6]+"' AND "
		cQry += "AFU.AFU_TPREAL <> '1' AND "
		cQry += "AFU.AFU_CTRRVS = '1' AND "
		cQry += "AFU.D_E_L_E_T_ = ' ' AND "
		cQry += "AE8.AE8_FILIAL = '"+xFilial("AE8")+"' AND "
		cQry += "AE8.AE8_EQUIP  BETWEEN '"+aParam1[7]+"' AND '"+aParam1[8]+"' AND "
		cQry += "AE8.D_E_L_E_T_ = ' ' "

		cQry	+=	" GROUP BY AFU_RECURS,AE8_EQUIP,AE8_DESCRI  "
		cQry := ChangeQuery(cQry)

		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"QRYREC",.F.,.T.)

		DbSelectArea("QRYREC")
		Do While !QRYREC->(Eof())
			If aParam1[1] == 1
				cCodigo	:=	QRYREC->AFU_RECURS
				cDescri	:=	IIF(Empty(cObfNRecur),QRYREC->AE8_DESCRI,cObfNRecur)  
  			Else
				If Empty(QRYREC->AE8_EQUIP)
					cCodigo	:=	""
					cDescri	:=	STR0205 //"Equipe nao informada"
				Else
					cCodigo	:=	QRYREC->AE8_EQUIP
					If AED->(MsSeek(xFilial('AED')+QRYREC->AE8_EQUIP))
						cDescri	:=	AED->AED_DESCRI
					Else
						cDescri	:=	STR0206 //"Equipe inexistente"
					Endif
				Endif
			Endif
			nPosRec := aScan(aArrayTrb,{|x|x[1]==cCodigo})
			If nPosRec <= 0
				aAdd(aArrayTrb,{cCodigo,cDescri,{0,0,0,0,0},0})
				nPosRec	:= Len(aArrayTrb)
			EndIf
			aArrayTrb[nPosRec][4] 	  += QRYREC->AFU_HQUANT
			aArrayTrb[nPosRec][3][1] += QRYREC->AFU_CUSTO1
			aArrayTrb[nPosRec][3][2] += QRYREC->AFU_CUSTO2
			aArrayTrb[nPosRec][3][3] += QRYREC->AFU_CUSTO3
			aArrayTrb[nPosRec][3][4] += QRYREC->AFU_CUSTO4
			aArrayTrb[nPosRec][3][5] += QRYREC->AFU_CUSTO5
			QRYREC->(DbSkip())
		EndDo
		QRYREC->(DbCloseArea())
	Next nX


	If Len(aArrayTrb) > 0
		aColAux	:=	{}
		aAdd(aColAux, STR0208)//"Codigo"
		aAdd(aColAux, STR0196  )//"Descricao"
		aAdd(aColAux, STR0197 )   //"Horas"
		aAdd(aColAux, STR0198 )   //"Custo"
		aAdd(aColAux, "% "+STR0197 )//"Horas"
		aAdd(aColAux, "% "+STR0198 )//"Custo"
		nTotH	:=	0
		nTotC	:=	0
		For nX:= 1 To Len(aArrayTrb)
			aadd(aView,{aArrayTrb[nX,1],aArrayTrb[nX,2],aArrayTrb[nX,4],aArrayTrb[nX,3,1],"",""})
			nTotC	+=	aArrayTrb[nX,3,1]
			nTotH	+=	aArrayTrb[nX,4]
		Next
		For nX:= 1 To Len(aView)
			aView[nX,5]	:=	TransForm(aView[nX,3]/nTotH * 100,'@E 999,999,999.99') + " %"
			aView[nX,6]	:=	TransForm(aView[nX,4]/nTotC * 100,'@E 999,999,999.99') + " %"
		Next nX
		aSort(aView,,,{|x,y| x[aParam1[2]] < y[aParam1[2]]})
		AAdd(aView,{STR0209,"",nTotH,nTotC,"",""}) //"Totais"

		aSize := MsAdvSize(,.F.,400)
		aObjects := {}

		AAdd( aObjects, { 100, 100 , .T., .T. } )

		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
		aPosObj := MsObjSize( aInfo, aObjects, .T. )

		DEFINE FONT oBold NAME "Arial" SIZE 0, -11 BOLD
		DEFINE FONT oFont NAME "Arial" SIZE 0, -10
		DEFINE MSDIALOG oDlg TITLE STR0191 From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL //"Apontamento de recursos"
		oDlg:lMaximized := .T.

		oPanel := TPanel():New(0,0,'',oDlg, , .T., .T.,, ,10,0,.T.,.T. )
		oPanel:Align := CONTROL_ALIGN_TOP

		oPanel1 := TPanel():New(0,0,'',oDlg, , .T., .T.,, ,40,40,.T.,.T. )
		oPanel1:Align := CONTROL_ALIGN_ALLCLIENT

		oView	:= TWBrowse():New( 2,2,aPosObj[1,4]-6,aPosObj[1,3]-aPosObj[1,1]-16,,aColAux,,oPanel1,,,,,,,oFont,,,,,.F.,,.T.,,.F.,,,)
		oView:Align := CONTROL_ALIGN_ALLCLIENT
		oView:SetArray(aView)
	 	oView:bHeaderClick := {|x,y,z| BrwSetOrder(oView,y,@lAsc,@aView) }
		oView:bLine := { || {aView[oView:nAt,1],aView[oView:nAt,2],TransForm(aView[oView:nAt,3],'@E 999,999,999,999.99'),TransForm(aView[oView:nAt,4],'@E 999,999,999,999.99'),aView[oView:nAt,5],aView[oView:nAt,6]}}
		aButtons := aClone(AddToExcel(aButtons,{ {"ARRAY",STR0191,aColAux,aView} } )) //"Apontamento de recursos"
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()},,aButtons )
	EndIf

RestArea(aAreaAFU)
RestArea(aAreaAE8)
RestArea(aAreaAED)
RestArea(aAreaAF9)
RestArea(aArea)
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥BrwSetOrder∫Autor ≥Bruno Sobieski      ∫ Data ≥  11/08/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function BrwSetOrder(o,y,lAsc,aItems)
Local	aItemTot	:=	aItems[Len(aItems)]
aSize(aItems, Len(aItems)-1)
If lAsc == Nil
	lAsc	:=	.T.
Endif
If y == 3 .Or. y == 4 //Colunas numericas
	Asort(aItems,,,IIf(lAsc,{|a,b| a[y] < b[y]},{|a,b| a[y]> b[y]} ))
Else
	Asort(aItems,,,IIf(lAsc,{|a,b| Upper(a[y]) < Upper(b[y])},{|a,b| Upper(a[y])> Upper(b[y])} ))
Endif
o:nAt	:=	1
lAsc	:=	!lAsc
If lAsc
	lAsc	:=	Nil
Endif
aadd(aItems, aItemTot)
o:Refresh()

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥PmsFasePCO ≥ Autor ≥ Bruno Sobieski       ≥ Data ≥ 09-02-2001 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Verficair se a fase pode ser trocada (integracao PCO)         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ cEncerra - variavel passada por referencia e indica se o     ≥±±
±±≥          ≥            projeto sera encerrado(AF8_ENCPRJ="1")            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥Generico                                                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PmsFasePco(cEncerra)
Local lRet	:=	.T.

cEncerra := AF8->AF8_ENCPRJ

If SuperGetMV("MV_PCOINTE",.F.,"2")=="1"

	DbSelectArea('AFC')
	DbSetOrder(3)
	DbSeek(xFilial('AFC')+AF8->AF8_PROJET+AF8->AF8_REVISA+"001")
	lRet := PcoVldLan('000351','01') //AF8

	If lRet .And. PcoExistLc('000351','02')
		DbSelectArea('AF9')
		DbSetOrder(1)
		DbSeek(xFilial('AF9')+AF8->AF8_PROJET+AF8->AF8_REVISA)
		While lRet .And. !AF9->(Eof()) .And. xFilial('AF9')+AF8->AF8_PROJET+AF8->AF8_REVISA == AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA
			PmsIncProc(.T.)
			lRet := PcoVldLan('000351','02')
			AF9->(DbSkip())
		Enddo
	Endif
	If lRet .And. PcoExistLc('000351','03')
		DbSelectArea('AFA')
		DbSetOrder(1)
		DbSeek(xFilial('AFA')+AFA->AFA_PROJET+AFA->AFA_REVISA)
		While lRet .And. !AFA->(Eof()) .And. xFilial('AFA')+AF8->AF8_PROJET+AF8->AF8_REVISA == AFA->AFA_FILIAL+AFA->AFA_PROJET+AFA->AFA_REVISA
			PmsIncProc(.T.)
			lRet := PcoVldLan('000351','03')
			AFA->(DbSkip())
		Enddo
	Endif
	If lRet .And. PcoExistLc('000351','04')
		DbSelectArea('AFB')
		DbSetOrder(1)
		DbSeek(xFilial('AFB')+AFB->AFB_PROJET+AFB->AFB_REVISA)
		While lRet .And. !AFA->(Eof()) .And. xFilial('AFB')+AF8->AF8_PROJET+AF8->AF8_REVISA == AFB->AFB_FILIAL+AFB->AFB_PROJET+AFB->AFB_REVISA
			PmsIncProc(.T.)
			lRet := PcoVldLan('000351','04')
			AFB->(DbSkip())
		Enddo
	Endif
EndIf

If lRet .And. !A200Encerra(M->AF8_FASE,AF8->AF8_FASE,AF8->AF8_PROJET,AF8->AF8_REVISA,@cEncerra)
	lRet := .F.
EndIf

Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥PMS200Fase ≥ Autor ≥ Bruno Sobieski       ≥ Data ≥ 09-02-2001 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Monta uma tela para troca de fase                             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥Generico                                                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PMS200Fase()
Local oBmp
Local oDlg
Local oList
Local alistbox1 := {}
Local alistbox2 := {}
Local aArea     := GetArea()
Local cFolder
Local nx
Local oCinza    := LoadBitmap( GetResources(), "BR_CINZA" )
Local oVerde    := LoadBitmap( GetResources(), "BR_VERDE" )
Local oVermelho := LoadBitmap( GetResources(), "BR_VERMELHO" )
Local oSayNova
Local cNovaFase := ""
Local lOk       := .F.
Local cEncerrado:= ""
Local lContinua := .T.
Local oSize
Local nLinH		:= 0
Local nColH		:= 0
Local nLinH2	:= 0
Local nColH2	:= 0

Private cFaseAnt    := AF8->AF8_FASE

If ExistBlock("PM200FAS")
	ExecBlock("PM200FAS", .F., .F.)
EndIf

If !PmsChkUser(AF8->AF8_PROJET, , Padr(AF8->AF8_PROJET, Len(AFC->AFC_EDT)), ;
              "  ", 3, "ESTRUT", AF8->AF8_REVISA)
	Aviso(STR0134,STR0072,{STR0136},2)
	lContinua := .F.
EndIf

If lContinua .and. !PmsVldAFW() //AF8 POSICIONADO
	lContinua := .F.
EndIf

If lContinua
	If ( Type("l200auto") == "U" .Or. ! l200auto )
		RegToMemory('AF8',.F.,.F.)

		dbSelectArea("AEA")
		dbSetOrder(1)
		MsSeek(xFilial()+AF8->AF8_FASE)
		cDescri	:=	AEA->AEA_DESCRI
		For nx := 1 to FCount()
			If "_EVEN"$FieldName(nx)
				SX3->(dbSetOrder(2))
				SX3->(MsSeek(AllTrim(AEA->(FieldName(nx)))))
				If SXA->(MsSeek(SX3->X3_ARQUIVO+SX3->X3_FOLDER))
					cFolder := XADESCRIC()
				Else
					cFolder := ""
				EndIf
				aAdd(alistbox1,{If(AEA->(FieldGet(nx))=="1",oVerde,If(AEA->(FieldGet(nx))=="2",oVermelho,oCinza)),oCinza,cFolder,X3DESCRIC()})
			EndIf
		Next

		PcoIniLan('000351')
		AEA->(dbSetOrder(1))
		AEA->(MsSeek(xFilial()+AF8->AF8_FASE))

		DEFINE MSDIALOG oDlg TITLE STR0235+Alltrim(AEA->AEA_DESCRI)+"."  OF oMainWnd PIXEL FROM 0,0 TO 400,500 //"Legenda/Fase"

		oSize := FwDefSize():New(.T.,,,oDlg)
		oSize:lLateral := .F.
		oSize:lProp := .T.
		
		oSize:AddObject("HEADER",100,010,.T.,.T.)
		oSize:AddObject("BOTTOM",100,090,.T.,.T.)

		oSize:Process()

		nLinH := oSize:GetDimension("HEADER","LININI")
		nColH := oSize:GetDimension("HEADER","COLINI")
		
		@ nLinH + 000,nColH + 000 To oSize:GetDimension("HEADER","LINEND"),oSize:GetDimension("HEADER","COLEND") - 002 PIXEL OF oDlg
		@ nLinH + 005,nColH + 004 Say STR0237 Size 055,008 COLOR CLR_BLACK PIXEL OF oDlg
		@ nLinH + 003,nColH + 036 MsGet oGet2 Var M->AF8_FASE Size 028,009  F3 'AEA' Valid Iif(M->AF8_FASE <> AF8->AF8_FASE .And. ExistCpo('AEA',M->AF8_FASE,1),SetNovaFase(@cNovaFase,@aListBox1,@oList),.F.) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg HASBUTTON
		@ nLinH + 005,nColH + 066 Say oSayNova Var cNovaFase Size 200,008 COLOR CLR_HBLUE PIXEL OF oDlg SHADOW	

		nLinH2 := oSize:GetDimension("BOTTOM","LININI")
		nColH2 := oSize:GetDimension("BOTTOM","COLINI")

		@ nLinH2,nColH2 To oSize:GetDimension("BOTTOM","LINEND"),oSize:GetDimension("BOTTOM","COLEND") - 002 LABEL STR0234 PIXEL
		oList := TWBrowse():New(nLinH2 + 8,nColH2 + 2,oSize:GetDimension("BOTTOM","XSIZE") - 6,oSize:GetDimension("BOTTOM","YSIZE") - 10,;
													,{"  ","  ",STR0238,STR0055},{10,10,90,70},oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,, ) //"Processo"###"Descricao"
		oList:SetArray(aListBox1)
		oList:bLine := {|| alistbox1[oList:nAT] }

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk:=.T.,oDlg:End(),Nil},{||lOk:=.F.,oDlg:End()}) CENTERED
		
	Else
		lOK := .T.
	EndIf

	If lOk
		If ExistBlock("PMA200GRV")
			lOk := ExecBlock("PMA200GRV",.F.,.F.)
		EndIf
	EndIf

	If lOk
		Begin Transaction
			lOk := PmsFasePco(@cEncerrado)		
			If lOk 
				M->AF8_ENCPRJ := cEncerrado
				//Estorna fase atual no PCO
				PmsLancPco(2)
				//Grava nova fase
				RecLock('AF8',.F.)
				Replace AF8_FASE   With M->AF8_FASE
				Replace AF8_ENCPRJ With M->AF8_ENCPRJ
				MsUnLock()
				//Lanca nova fase no PCO
				PmsLancPco(1)
			EndIf	
		End Transaction
	Endif

	If lOk
		If ExistBlock("PMA200FA")
			ExecBlock("PMA200FA", .F., .F.,{AF8->AF8_PROJET, AF8->AF8_FASE})
		EndIf
	EndIf

	PcoFinLan('000351')
	PcoFreeBlq('000351')
Endif

Return(.T.)

Return

Static Function SetNovaFase(cNovaFase,aListBox1,oLbx)
Local nY	:=	0
Local nX	:=	0
Local oCinza	:= LoadBitmap( GetResources(), BMP_CINZA )
Local oVerde	:= LoadBitmap( GetResources(), BMP_VERDE )
Local oVermelho	:= LoadBitmap( GetResources(), BMP_VERMELHO )
dbSelectArea("AEA")
dbSetOrder(1)
MsSeek(xFilial()+M->AF8_FASE)
cNovaFase:= AEA->AEA_DESCRI
For nX := 1 to FCount()
	If "_EVEN"$FieldName(nx)
		nY++
		SX3->(dbSetOrder(2))
		SX3->(MsSeek(AllTrim(AEA->(FieldName(nx)))))
		If SXA->(MsSeek(SX3->X3_ARQUIVO+SX3->X3_FOLDER))
			cFolder := XADESCRIC()
		Else
			cFolder := ""
		EndIf
		aListBox1[nY,2] := Iif(AEA->(FieldGet(nx))=="1",oVerde,If(AEA->(FieldGet(nx))=="2",oVermelho,oCinza))
	EndIf
Next
oLbx:Refresh()
Return .T.

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥CheckNoIdx ≥ Autor ≥ Bruno Sobieski       ≥ Data ≥ 09-02-2001 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Verifica quasi tabelas deverao ser recodificadas              ≥±±
±±           ≥Eh para evitar que sejam recodificadas tabelas que nao sao uti≥±±
±±           ≥lizadas e que devem serfiltradas para cada tarefa e/ou EDT por≥±±
±±           ≥nao terem indice.                                             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥Generico                                                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function CheckNoIdx(aTabelas)
Local aParam   := { { 5,STR0214, .T., 250,,.F.},;	//"Orcamento e envio de mercadoria pelo faturamento (SCK,SC6,SC9,SD2)"
						{ 5,  STR0215, .T. , 250,,.F.}	,;//"Consulta gerencial de projetos (AJA)"
						{ 5,  STR0216, .T. , 250,,.F.}	,;//"Transferencias e requisicoes de estoque, apropiacao na Nota fiscal de entrada (SD3)"
						{ 5,  STR0217, .T. , 250,,.F.} } //"Geracao de pedidos de venda em base a confirmaÁoes (AJ8)"
Local aConfig  := Array(Len(aParam))
Local nOpca	:=	2

aFill(aConfig,.T.)

oWizard := APWizard():New(	STR0069,; //"Atencao"
								STR0218, STR0219, ;  //"Este assistente ira lhe ajudar na recodificacao das EDTS e tarefas deste projeto "##"Recodificacao de tarefas "
								STR0220+CRLF+CRLF+;	//"Voce devera escolher que processos estao integrados com o ambiente de Gestao de projetos, para otimizar a performance da codificaÁ„o."
								STR0221,;				//"ATENCAO: Se nao tiver certeza sobre as integracoes utilizadas, NAO DESMARQUE NENHUMA OPERACAO na proxima tela."
								{ || .T. } /*<bNext>*/, ;
								{ || .T. } /*<bFinish>*/,;
								/*<.lPanel.>*/, , , /*<.lNoFirst.>*/)

oWizard:NewPanel(   STR0222,; 	// "Integracao com Ambiente de projetos"
						STR0223, ; 		// 						"Desmarque as opercaoes que NAO possuem integraÁ„o com o ambiente de Gest„o de projetos (em caso de d˙vidas deixe todas marcadas)."
	 					{ || .T. }/*<bBack>*/, ;
	 					{ || .T. }/*<bNext>*/, ;
	 					{ || nOpca := 1, .T. }/*<bFinish>*/, ;
	 					.T./*<.lPanel.>*/, ;
	 					{ || ParamBox(aParam ,, aConfig,,,.F.,120,3, oWizard:oMPanel[oWizard:nPanel])   }/*<bExecute>*/ )

oWizard:Activate(	.T./*<.lCenter.>*/,;
					 	{ || .T. }/*<bValid>*/, ;
						{ || .T. }/*<bInit>*/, ;
						{ || .T. }/*<bWhen>*/ )

If aConfig[1]
	AAdd(aTabelas,'SCK')
	AAdd(aTabelas,'SC6')
	AAdd(aTabelas,'SC9')
	AAdd(aTabelas,'SD2')
Endif
If aConfig[2]
	aAdd(aTabelas,'AJA')
Endif
If aConfig[3]
	AAdd(aTabelas,'SD3')
Endif
If aConfig[4]
	AAdd(aTabelas,'AJ8')
Endif

Return (nOpca == 1)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥PmsLancPco ≥ Autor ≥ Bruno Sobieski       ≥ Data ≥ 12-01-2006 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Faz o lancamento de estorno quando se esta mudando de fase, e ≥±±
±±           ≥gera o lancamento novo par a nova fase.                       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥Integracao PMS x PCO                                          ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PmsLancPco(nTipo)

If SuperGetMV("MV_PCOINTE",.F.,"2")=="1"
	//Inclusao
	If nTipo == 1
		//Lanca a nova fase
		DbSelectArea('AFC')
		DbSetOrder(1)
		DbSeek(xFilial()+AF8->AF8_PROJET+AF8->AF8_REVISA+AF8->AF8_PROJET)
		PcoDetLan('000351','01') //AF8

		If PcoExistLc('000351','02',"1")
			DbSelectArea('AF9')
			DbSetOrder(1)
			DbSeek(xFilial()+AF8->AF8_PROJET+AF8->AF8_REVISA)
			While !AF9->(Eof()) .And. xFilial()+AF8->AF8_PROJET+AF8->AF8_REVISA == AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA
				PmsIncProc(.T.)
				PcoDetLan('000351','02')
				AF9->(DbSkip())
			Enddo
		Endif
		If PcoExistLc('000351','03',"1")
			DbSelectArea('AFA')
			DbSetOrder(1)
			DbSeek(xFilial()+AF8->AF8_PROJET+AF8->AF8_REVISA)
			While !AFA->(Eof()) .And. xFilial('AFA')+AF8->AF8_PROJET+AF8->AF8_REVISA == AFA->AFA_FILIAL+AFA->AFA_PROJET+AFA->AFA_REVISA
				PmsIncProc(.T.)
				PcoDetLan('000351','03')
				AFA->(DbSkip())
			Enddo
		Endif
		If PcoExistLc('000351','04',"1")
			DbSelectArea('AFB')
			DbSetOrder(1)
			DbSeek(xFilial()+AF8->AF8_PROJET+AF8->AF8_REVISA)
			While !AFA->(Eof()) .And. xFilial('AFB')+AF8->AF8_PROJET+AF8->AF8_REVISA == AFB->AFB_FILIAL+AFB->AFB_PROJET+AFB->AFB_REVISA
				PmsIncProc(.T.)
				PcoDetLan('000351','04')
				AFB->(DbSkip())
			Enddo
		Endif
	//Estorno
	ElseIf nTipo == 2
		//Estorna lancamentos da fase atual
		DbSelectArea('AFC')
		DbSetOrder(1)
		DbSeek(xFilial()+AF8->AF8_PROJET+AF8->AF8_REVISA)
		PcoDetLan('000351','01',,.T.) //AF8
		If PcoExistLc('000351','02',"1")
			DbSelectArea('AF9')
			DbSetOrder(1)
			DbSeek(xFilial()+AF8->AF8_PROJET+AF8->AF8_REVISA)
			While !AF9->(Eof()) .And. xFilial()+AF8->AF8_PROJET+AF8->AF8_REVISA == AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA
				PmsIncProc(.T.)
				PcoDetLan('000351','02',,.T.)
				AF9->(DbSkip())
			Enddo
		Endif
		If PcoExistLc('000351','03',"1")
			DbSelectArea('AFA')
			DbSetOrder(1)
			DbSeek(xFilial()+AFA->AFA_PROJET+AFA->AFA_REVISA)
			While !AFA->(Eof()) .And. xFilial('AFA')+AF8->AF8_PROJET+AF8->AF8_REVISA == AFA->AFA_FILIAL+AFA->AFA_PROJET+AFA->AFA_REVISA
				PmsIncProc(.T.)
				PcoDetLan('000351','03',,.T.)
				AFA->(DbSkip())
			Enddo
		Endif
		If PcoExistLc('000351','04',"1")
			DbSelectArea('AFB')
			DbSetOrder(1)
			DbSeek(xFilial()+AFB->AFB_PROJET+AFB->AFB_REVISA)
			While !AFA->(Eof()) .And. xFilial('AFB')+AF8->AF8_PROJET+AF8->AF8_REVISA == AFB->AFB_FILIAL+AFB->AFB_PROJET+AFB->AFB_REVISA
				PmsIncProc(.T.)
				PcoDetLan('000351','04',,.T.)
				AFB->(DbSkip())
			Enddo
		Endif
	Endif
Endif

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥MenuDef   ≥ Autor ≥ Ana Paula N. Silva     ≥ Data ≥30/11/06 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Utilizacao de menu Funcional                               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥Array com opcoes da rotina.                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥Parametros do array a Rotina:                               ≥±±
±±≥          ≥1. Nome a aparecer no cabecalho                             ≥±±
±±≥          ≥2. Nome da Rotina associada                                 ≥±±
±±≥          ≥3. Reservado                                                ≥±±
±±≥          ≥4. Tipo de TransaáÑo a ser efetuada:                        ≥±±
±±≥          ≥		1 - Pesquisa e Posiciona em um Banco de Dados     ≥±±
±±≥          ≥    2 - Simplesmente Mostra os Campos                       ≥±±
±±≥          ≥    3 - Inclui registros no Bancos de Dados                 ≥±±
±±≥          ≥    4 - Altera o registro corrente                          ≥±±
±±≥          ≥    5 - Remove o registro corrente do Banco de Dados        ≥±±
±±≥          ≥5. Nivel de acesso                                          ≥±±
±±≥          ≥6. Habilita Menu Funcional                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥   DATA   ≥ Programador   ≥Manutencao efetuada                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥          ≥               ≥                                            ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function MenuDef()
Local aUsRotina	:= {}
Local aRotina 	:= {}

ADD OPTION aRotina TITLE STR0002  	ACTION "AxPesqui"   OPERATION 1 ACCESS 0 DISABLE MENU//"Pesquisar"
ADD OPTION aRotina TITLE STR0003	ACTION "PMS200Dlg"  OPERATION 2 ACCESS 0//"Visualizar"
ADD OPTION aRotina TITLE STR0004	ACTION "PMS200Dlg"  OPERATION 3 ACCESS 0//"Incluir"
ADD OPTION aRotina TITLE STR0023	ACTION "PMS200Alt"  OPERATION 4 ACCESS 0//143//"Alt.Cadastro"
ADD OPTION aRotina TITLE STR0006	ACTION "PMS200Dlg"  OPERATION 5 ACCESS 0//144//"Excluir"

ADD OPTION aRotina TITLE STR0024   ACTION "PMS200Dlg"  OPERATION 4 ACCESS 0//"Alt.Estrutura"
ADD OPTION aRotina TITLE STR0239   ACTION "PMS200Fase" OPERATION 4 ACCESS 0//"Alt.Fase"
ADD OPTION aRotina TITLE STR0062	ACTION "PMS200User" OPERATION 6 ACCESS 0//"Usuarios"
ADD OPTION aRotina TITLE STR0279	ACTION "PMS200Evt"  OPERATION 6 ACCESS 0//"Eventos"

ADD OPTION aRotina TITLE STR0293 ACTION "PMSAltPrj"  OPERATION 6 ACCESS 0

ADD OPTION aRotina TITLE STR0079	ACTION "PMS200Leg"  OPERATION 6 ACCESS 0//"Legenda"

	// adiciona botoes do usuario na EnchoiceBar
If ExistBlock( "PM200ROT" )
	If ValType( aUsRotina := ExecBlock( "PM200ROT", .F., .F. ) ) == "A"
		AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
	EndIf
EndIf

Return(aRotina)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥PMS200UsrVld≥ Autor ≥Marcelo Akama        ≥ Data ≥ 30.12.2008 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Funcao de chamada de ponto de entrada para validaÁ„o da       ≥±±
±±≥          ≥associacao de composicao                                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥PMSA200                                                       ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PMS200UsrVld()
Local lRet:=.t.

If ExistBlock("PMA200VLD")
   	lRet := ExecBlock("PMA200VLD",.F.,.F.,Nil)
	If ValType(lRet) == "L" .And. !lRet
		lRet:=.F.
   	Endif
Endif

Return(lRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥PMS200SbLt∫Autor  ≥Marcelo Akama       ∫ Data ≥  08.09.2009 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Funcao que substitui um recurso por outro(s) informado(s)  ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ PMSA200                                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PMS200SbLt(cRevisao)
Local aArea		:= GetArea()
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaAFA	:= AFA->(GetArea())
Local aAreaAE8	:= AE8->(GetArea())
Local aAreaAFF	:= AFF->(GetArea())
Local aAreaAFU	:= AFU->(GetArea())
Local aAreaSB1
Local aParam	:= {}
Local lIntTMK	:= SuperGetMV("MV_QTMKPMS",.F.,1) == 3 .Or. SuperGetMV("MV_QTMKPMS",.F.,1) == 4
Local aStruTRB	:= {}
Local aCampos	:= {}
Local lOk		:= .F.
Local cFiltro
Local cFiltroUs	:= ".T."
Local aRet
Local aAux
Local nX
Local aSize
Local oDlg
Local oPanel
Local oMark
Local lInverte
Local cRecOri
Local cRecDest
Local cRecurs
Local cProdut
Local nValor
Local lUpdate
Local aRetCus
Local lRejeicao	:= AF8->AF8_PAR002=="1" .Or. AF8->AF8_PAR002=="2"
Local bCampo 	:= {|n| FieldName(n) }
Local cItem
Local lResp
Local lAFAMsBlQl:= AFA->(FieldPos("AFA_MSBLQL")) > 0
Local cObfNRecur := IIF(FATPDIsObfuscate("AE8_DESCRI",,.T.),FATPDObfuscate("RESOURCE NAME","AE8_DESCRI",,.T.),"")        

Default cRevisao := AF8->AF8_REVISA
// verifica se o projeto nao esta reservado.
If AF8->AF8_PRJREV=="1" .And. AF8->AF8_STATUS<>"2" .And. GetNewPar("MV_PMSRBLQ","N")=="S"
	Aviso(STR0035,STR0036,{STR0037},2) //"Gerenciamento de Revisoes"###"Este projeto nao se encontra em revisao. Para realizar uma alteracao no projeto, deve-se primeiro Iniciar uma revisao no projeto atraves do Gerenciamento de Revisoes."###"Fechar"
	Return .F.
EndIf

// verifica o evento de alteracao de tarefa na Fase atual.
If !PmsVldFase("AF8", AF8->AF8_PROJET, "18")
	Return .F.
EndIf

// verifica o evento de inclusao de tarefa na Fase atual.
If !PmsVldFase("AF8", AF8->AF8_PROJET, "15")
	Return .F.
EndIf

// verifica o evento de alteracao de projeto na Fase atual.
If !PmsVldFase("AF8", AF8->AF8_PROJET, "11")
	Return .F.
EndIf

SaveInter()

AADD(aParam, {1, "Recurso Atual:"      ,space(TamSX3("AE8_RECURS")[1]),,'Vazio() .Or. ExistCPO("AE8",,1)',"AE8",,,.F.})
AADD(aParam, {1, "Novo Recurso:"       ,space(TamSX3("AE8_RECURS")[1]),,'ExistCPO("AE8",,1)',"AE8",,,.T.})
AADD(aParam, {1, "Equipe De:"          ,space(TamSX3("AE8_EQUIP" )[1]),,,"AED",,,.F.})
AADD(aParam, {1, "Equipe Ate:"         ,repl('Z',TamSX3("AE8_EQUIP" )[1]),,,"AED",,,.F.})
AADD(aParam, {3, "Considerar tarefas:" ,1,{"A executar","Em execucao","Abertas (executar/execucao)","Encerradas","Todas"},150,,.F.})
If lIntTMK
	AADD(aParam, {1, "Tipo Plano/Acao De:" ,space(TamSX3("QI5_TPACAO")[1]),,,"QIK",,,.F.})
	AADD(aParam, {1, "Tipo Plano/Acao Ate:",repl('Z',TamSX3("QI5_TPACAO")[1]),,,"QIK",,,.F.})
EndIf
AADD(aParam, {7, "Filtro de Tarefas:"  ,"AF9",""})

If ExistBlock( "PM200SLP" )
	aAux := ExecBlock("PM200SLP",.F.,.F.)
	If ( ValType(aAux) == "A" ) .And. !Empty(aAux)
		For nX := 1 to len(aAux)
			AADD(aParam, aAux[nX])
		Next
	EndIf
EndIf

If ParamBox(aParam, "Transferencia de recursos", @aRet)

	If ExistBlock( "PM200SLF" )
		cFiltroUs := ExecBlock("PM200SLF",.F.,.F.)
		If ( ValType(cFiltroUs) <> "C" ) .Or. Empty(cFiltroUs)
			cFiltroUs := ".T."
		EndIf
	EndIf

	dbSelectArea("AE8")
	dbSetOrder(1)
	If empty(mv_par01)
		cRecOri := "Todos"
	Else
		AE8->( MsSeek(xFilial("AE8")+mv_par01) )
		cRecOri := AE8->AE8_RECURS+' - '+ IIF(Empty(cObfNRecur),AE8->AE8_DESCRI,cObfNRecur)
	EndIf
	AE8->( MsSeek(xFilial("AE8")+mv_par02) )
	cRecDest := AE8->AE8_RECURS+' - '+ IIF(Empty(cObfNRecur),AE8->AE8_DESCRI,cObfNRecur)
	cRecurs  := AE8->AE8_RECURS
	cProdut  := AE8->AE8_PRODUT
	nValor   := AE8->AE8_VALOR 

	AADD(aStruTrb,{"TRB_MARCA"	,"C",2,0})
	AADD(aStruTrb,{"AFA_RECURS"	,"C",TamSx3("AFA_RECURS")[1],0})
	AADD(aStruTrb,{"AE8_DESCRI"	,"C",TamSx3("AE8_DESCRI")[1],0})
	AADD(aStruTrb,{"AF9_TAREFA"	,"C",TamSx3("AF9_TAREFA")[1],0})
	AADD(aStruTrb,{"AF9_DESCRI"	,"C",TamSx3("AF9_DESCRI")[1],0})
	AADD(aStruTrb,{"AF9_PRIORI"	,"N",TamSx3("AF9_PRIORI")[1],TamSx3("AF9_PRIORI")[2]})

	AADD(aStruTrb,{"TRB_DTINI"	,"D",8,0})
	AADD(aStruTrb,{"TRB_DTFIM"	,"D",8,0})

	If mv_par05==1 //[Considerar Tarefas] = "A Executar"
		AADD(aStruTrb,{"AF9_START"	,"D",8,0})
		AADD(aStruTrb,{"AF9_FINISH"	,"D",8,0})
	Else
		AADD(aStruTrb,{"AF9_DTATUI"	,"D",8,0})
		AADD(aStruTrb,{"AF9_DTATUF"	,"D",8,0})
	EndIf

	If lIntTMK
		cFiltro:=mv_par08
		AADD(aStruTrb,{"AF9_FNC"	,"C",TamSx3("AF9_FNC"   )[1],0})
		AADD(aStruTrb,{"AF9_ACAO"	,"C",TamSx3("AF9_ACAO"  )[1],0})
		AADD(aStruTrb,{"AF9_TPACAO"	,"C",TamSx3("AF9_TPACAO")[1],0})
	Else
		cFiltro:=mv_par06
	EndIf

	AADD(aStruTrb,{"AE8_RECNO"	,"N",12,0})
	AADD(aStruTrb,{"AFA_RECNO"	,"N",12,0})
	AADD(aStruTrb,{"AF9_RECNO"	,"N",12,0})
	AADD(aStruTrb,{"TRB_APONT"	,"L",1,0})

	AADD(aCampos,{"TRB_MARCA" ,"","",""})
	AADD(aCampos,{"AFA_RECURS","","Recurso",""})
	AADD(aCampos,{"AE8_DESCRI","","Nome Recurso",""})
	AADD(aCampos,{"AF9_TAREFA","","Tarefa",""})
	AADD(aCampos,{"AF9_DESCRI","","Descricao Tarefa",""})
	AADD(aCampos,{"AF9_PRIORI","","Prioridade",""})
	AADD(aCampos,{"TRB_DTINI" ,"",IIf(mv_par05==1,"Dt Inicio Prv","Dt Inicio Real"),""})
	AADD(aCampos,{"TRB_DTFIM" ,"",IIf(mv_par05==1,"Dt Termino Prv","Dt Termino Real"),""})
	If lIntTMK
		AADD(aCampos,{"AF9_FNC"   ,"","FNC",""})
		AADD(aCampos,{"AF9_ACAO"  ,"","Plano de Acao",""})
		AADD(aCampos,{"AF9_TPACAO","","Etapa",""})
	EndIf

	If _oPMSA2002 <> Nil
		_oPMSA2002:Delete()
		_oPMSA2002	:= Nil
	Endif	
	
	//Cria o Objeto do FwTemporaryTable
	_oPMSA2002 := FwTemporaryTable():New("TRB")
	
	//Cria a estrutura do alias temporario
	_oPMSA2002:SetFields(aStruTrb)
	
	//Criando a Tabela Temporaria
	_oPMSA2002:Create()

	cFiltro:=IIf( empty(cFiltro), ".T.", cFiltro )

	dbSelectArea("AFU")
	dbSetOrder(1)
	dbSelectArea("AE8")
	dbSetOrder(1)
	dbSelectArea("AFA")
	dbSetOrder(1)
	dbSelectArea("AFF")
	dbSetOrder(1)
	dbSelectArea("AF9")
	dbSetOrder(1)
	MSSeek(xFilial("AF9")+AF8->AF8_PROJET+cRevisao )
	Do While AF9->(!Eof()) .AND. (AF9->(AF9_FILIAL+AF9_PROJET+AF9->AF9_REVISA)==xFilial("AF9")+AF8->AF8_PROJET+cRevisao)
		If &cFiltro
			If !lIntTMK .Or. ( lIntTMK .And. AF9_TPACAO>=mv_par06 .And. AF9_TPACAO<=mv_par07 )
				AFF->( MsSeek(xFilial("AFF")+AF8->AF8_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA), , .T. )
				RegToMemory('AFF',.F.)
				If ( mv_par05==1 .And. AFF->(Eof()) ) .Or.;
				   ( mv_par05==2 .And. M->AFF_PERC<100 ) .Or.;
				   ( mv_par05==3 .And. ( ( AFF->(Eof()) ) .Or. ( M->AFF_PERC<100 ) ) ) .Or.;
				   ( mv_par05==4 .And. M->AFF_PERC>=100 ) .Or.;
				   ( mv_par05==5 )
					AFA->( MsSeek(xFilial("AFA")+AF8->AF8_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA))
					Do While !AFA->(Eof()) .And. AFA->(AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA)==xFilial("AFA")+AF8->AF8_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA
						If ( AFA->AFA_RECURS<>mv_par02 ) .And. ( empty(mv_par01) .Or. ( AFA->AFA_RECURS==mv_par01 ) )
							AE8->( MsSeek(xFilial("AE8")+AFA->AFA_RECURS) )
							If !AE8->(Eof()) .And. AE8->AE8_EQUIP>=mv_par03 .And. AE8->AE8_EQUIP<=mv_par04
								If &cFiltroUs
									dbSelectArea("TRB")
									RecLock("TRB", .T.)
									replace TRB->TRB_MARCA	with ""
									replace TRB->AFA_RECURS	with AFA->AFA_RECURS
									replace TRB->AE8_DESCRI	with AE8->AE8_DESCRI
									replace TRB->AF9_TAREFA	with AF9->AF9_TAREFA
									replace TRB->AF9_DESCRI	with AF9->AF9_DESCRI
									replace TRB->AF9_PRIORI	with AF9->AF9_PRIORI
									replace TRB->TRB_DTINI	with IIf(mv_par05==1,AF9->AF9_START ,AF9->AF9_DTATUI)
									replace TRB->TRB_DTFIM	with IIf(mv_par05==1,AF9->AF9_FINISH,AF9->AF9_DTATUF)
									If lIntTMK
										replace TRB->AF9_FNC	with AF9->AF9_FNC
										replace TRB->AF9_ACAO	with AF9->AF9_ACAO
										replace TRB->AF9_TPACAO	with AF9->AF9_TPACAO
									EndIf
									replace TRB->AFA_RECNO	with AFA->(RecNo())
									replace TRB->AF9_RECNO	with AF9->(RecNo())
									If SuperGetMV("MV_PMSVRAL", .F., 0) <> 0
										AFU->( MsSeek( xFilial("AFU")+"1"+AF8->AF8_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA+AFA->AFA_RECURS ) )
										replace TRB->TRB_APONT	with !AFU->(Eof())
									Else
										replace TRB->TRB_APONT	with .F.
									EndIf

									MsUnlock()
									dbSelectArea("AF9")
								EndIf
							EndIf
						EndIf
						AFA->(dbSkip())
					EndDo
				EndIf
			EndIf
		EndIf
		AF9->(dbSkip())
	EndDo

	dbSelectArea("TRB")
	dbGoTop()

	aSize := MSADVSIZE()

	DEFINE MSDIALOG oDlg TITLE "Transferencia de tarefas do projeto" From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL

	oDlg:lMaximized := .T.
	oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,25,25,.T.,.T.)
	oPanel:Align := CONTROL_ALIGN_TOP

	@ 003,003 Say "Recurso atual:"	PIXEL OF oPanel
	@ 003,080 Say cRecOri			PIXEL OF oPanel
	@ 015,003 Say "Novo Recurso:"	PIXEL OF oPanel
	@ 015,080 Say cRecDest			PIXEL OF oPanel

	lInverte:= .F.
	oMark := MsSelect():New("TRB","TRB_MARCA","TRB_APONT",aCampos,@lInverte,"XX", {35,oDlg:nLeft,oDlg:nBottom,oDlg:nRight})
	oMark:oBrowse:lHasMark := .T.
	oMark:oBrowse:lCanAllMark:=.T.
	oMark:oBrowse:bAllMark := {|| PMS200MkAl(oDlg)}
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	FATPDLogUser("PMS200SBLT")
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := .T.,oDlg:End()},{||oDlg:End()}) CENTERED

	If lOk

		TRB->(dbGoTop())
		Do While !TRB->(Eof())
			If !empty(TRB->TRB_MARCA)
				lUpdate := .F.
				AFA->( dbGoTo(TRB->AFA_RECNO) )
				AF9->( dbGoTo(TRB->AF9_RECNO) )

				If lRejeicao
					aAreaAFA := AFA->(GetArea())
					cItem:=strzero(0,AFA->(TamSX3("AFA_ITEM")[1]))
					AFA->(DbSetOrder(1))
					AFA->(DbSeek(xFilial("AFA")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)))
					Do While AFA->(!Eof()) .And. xFilial("AFA")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)==AFA->(AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA)
						cItem := AFA->AFA_ITEM
						AFA->(DbSkip())
					EndDo
					cItem := Soma1(cItem)
					RestArea(aAreaAFA)

					RegToMemory( "AFA", .F.)
					lResp := AFA->AFA_RESP == "1"
					RecLock("AFA",.F.)
					AFA->AFA_RESP := "2"
					If lAFAMsBlQl
						AFA->AFA_MSBLQL := "1"
					EndIf
					MsUnLock()

					dbSelectArea("AFA")
					RecLock("AFA",.T.)
					For nx := 1 TO FCount()
						FieldPut(nx,M->&(EVAL(bCampo,nx)))
					Next nx
					AFA->AFA_FILIAL	:= xFilial("AFA")
					AFA->AFA_RESP	:= IIf(lResp, "1", "2")
					AFA->AFA_ITEM	:= cItem
				Else
					RecLock("AFA",.F.)
					PmsAvalAFA("AFA",2)
				EndIf

				AFA->AFA_RECURS	:= cRecurs
				AFA->AFA_PRODUT := cProdut
				AFA->AFA_CUSTD  := nValor

				If Empty(AFA->AFA_PRODUT)
					AFA->AFA_MOEDA := 1
				Else
					aAreaSB1 := SB1->(GetArea())
					dbSelectArea("SB1")
					dbSetOrder(1)
					If MSSeek(xFilial("SB1")+AFA->AFA_PRODUT)
						AFA->AFA_MOEDA := Val(RetFldProd(SB1->B1_COD,"B1_MCUSTD"))
						If AFA->AFA_CUSTD == 0
							AFA->AFA_CUSTD := RetFldProd(SB1->B1_COD,"B1_CUSTD")
						EndIf
					Else
						AFA->AFA_MOEDA := 1
						AFA->AFA_CUSTD := 0
					EndIf
					RestArea(aAreaSB1)
				EndIf

				If hasTemplate("CCT") .and. ExistTemplate("CCT200_3")
					ExecTemplate("CCT200_3",.F.,.F.)
				EndIf

				MsUnlock()

				// Realiza alteracao do recurso quando houver integracao
				If SuperGetMV("MV_QTMKPMS",.F.,1) == 3 .Or. SuperGetMV("MV_QTMKPMS",.F.,1) == 4
					DbSelectArea( "QI5" )
					QI5->( DbSetOrder( 4 ) ) //QI5_FILIAL+QI5_CODIGO+QI5_REV+QI5_TPACAO
					If QI5->( DbSeek( xFilial( "QI5" ) + AF9->( AF9_ACAO + AF9_REVACA + AF9_TPACAO ) ) )
						While QI5->( !Eof() ) .And. QI5->( QI5_FILIAL + QI5_CODIGO + QI5_REV + QI5_TPACAO ) == xFilial( "QI5" ) + AF9->( AF9_ACAO + AF9_REVACA + AF9_TPACAO )
							If QI5->( QI5_PROJET + QI5_PRJEDT + QI5_TAREFA ) == AF9->( AF9_PROJET + AF9_EDTPAI + AF9_TAREFA )
								RecLock( "QI5", .F. )
								QI5->QI5_MAT := RDZRetEnt( "AE8", xFilial( "AE8" ) + AFA->AFA_RECURS, "QAA",,,, .F. )
								MsUnLock()
							EndIf
							QI5->(dbSkip())
						End
				    EndIf
				EndIf

				PmsAvalAFA("AFA",1)
				lUpdate := .T.

				If lUpdate
					//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
					//≥Grava o custo da tarefa.≥
					//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
					If hasTemplate("CCT") .and. ExistTemplate("PMAAF9CTrf")
						ExecTemplate("PMAAF9CTrf",.F.,.F.,{AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA})
					Else
						aRetCus	:= PmsAF9CusTrf(0 ,AF9->AF9_PROJET ,AF9->AF9_REVISA ,AF9->AF9_TAREFA)
						RecLock("AF9",.F.)
						Replace AF9->AF9_CUSTO  With aRetCus[1]
						Replace AF9->AF9_CUSTO2 With aRetCus[2]
						Replace AF9->AF9_CUSTO3 With aRetCus[3]
						Replace AF9->AF9_CUSTO4 With aRetCus[4]
						Replace AF9->AF9_CUSTO5 With aRetCus[5]
						AF9->AF9_VALBDI:= aRetCus[1]*IF(AF9->AF9_BDI<>0,AF9->AF9_BDI,PmsGetBDIPad('AFC',AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_EDTPAI,AF9->AF9_UTIBDI))/100
						AF9->AF9_TOTAL := aRetCus[1]+AF9->AF9_VALBDI

						MsUnlock()
				 	EndIf

				 	PmsAvalTrf("AF9",1,,.F.,.T.)

					lUpdate := .F.
				EndIf

			EndIf
			TRB->(dbSkip())
		EndDo
	EndIf

	DbSelectArea('TRB')
	DbCloseArea()

EndIf

RestInter()

RestArea(aAreaAF9)
RestArea(aAreaAFA)
RestArea(aAreaAE8)
RestArea(aAreaAFF)
RestArea(aAreaAFU)
RestArea(aArea)

Return( .T. )

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥PMS200MkAll ∫Autor  ≥ Marcelo Akama    ∫ Data ≥  14/09/09   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Marca/Desmarca todos os registros                           ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ PMS                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PMS200MkAl(oDlg)
Local nReg := TRB->(RecNo())
TRB->( dbGoTop() )
TRB->( dbEval({|| TRB->TRB_MARCA := If(Empty(TRB->TRB_MARCA), "XX", " ")}) )
TRB->( dbGoto(nReg) )
oDlg:Refresh()
Return(.T.)


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥PA200Fix ≥ Autor ≥Clovis Magenta			  ≥ Data ≥23/09/09    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Funcao de chamada do fonte pmsa201 para possibilitar o uso   ≥±±
±±≥          ≥ da funcao static PA200Fix.                                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥PMSA200                                                       ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PA200Fix(cSQL, cDB)

cSQL:=PmsA200Fix(cSQL, cDB)

Return cSQL


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥PMS200Evt ≥ Autor ≥ Totvs                      ≥ Data ≥ 13/07/2010 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Funcao para tratar os eventos de notificacao do projeto.           ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥SIGAPMS                                                       	 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function PMS200Evt( cAlias, nReg, nOpcx )

PMS206Evt( cAlias, nReg, nOpcx )

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥MEMOVALID≥ Autor ≥ Pedro Pereira Lima     ≥ Data ≥ 22/10/2010 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Programa de validacao do campo memo                          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                     ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function MEMOVALID()
Local lRetorno := .T.
Local nTamMemo := TamSX3("AFE_MEMO")[1]

If nTamMemo < Len(AllTrim(M->AFE_MEMO))
	MsgAlert(STR0280+AllTrim(Str(nTamMemo))+STR0281,STR0069) //"O coment·rio deve ser inferior a "###" caracteres.","Atencao!"
	lRetorno := .F.
EndIf

Return lRetorno

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥PMS200Tool∫Autor  ≥Pedro Pereira Lima  ∫ Data ≥  07/12/10   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Cria procedures dinamicas para uso na rotina de            ∫±±
±±∫          ≥ reprocessamento.                                           ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ PMSA200                                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function PMS200Tool(lDrop,cDataBase)
Local cCommand1 := ""
Local cCommand2 := ""
Local cRetSQL   := ""
Local xProc     := ''
Local nX        := 0
Local nCaracter := 0

If !lDrop
//**************************************
//BLOCO DE CRIA«√O DE PROCEDURE/FUNCTION
//**************************************/
	If cDataBase == "DB2"
		//PMS_DATEADD
		cCommand1 := "CREATE FUNCTION PMS_DATEADD (DATEPART VARCHAR(10)," + CRLF
		cCommand1 += "                           QTDE INTEGER," + CRLF
		cCommand1 += "                           DDATA VARCHAR(10))" + CRLF
		cCommand1 += "RETURNS VARCHAR(10)" + CRLF
		cCommand1 += "BEGIN ATOMIC" + CRLF
		cCommand1 += "    DECLARE VDATA VARCHAR(10);" + CRLF
		cCommand1 += "    IF SUBSTR(DDATA,1,1) = ' ' OR DDATA IS NULL THEN" + CRLF
		cCommand1 += "        SET VDATA = '        ' ;" + CRLF
		cCommand1 += "    ELSE" + CRLF
		cCommand1 += "        SET VDATA = CHAR( DATE ( SUBSTR( DDATA, 1, 4 )||'-'||SUBSTR( DDATA, 5, 2 )||'-'||SUBSTR( DDATA, 7, 2 ) ) + QTDE DAYS );" + CRLF
		cCommand1 += "        SET VDATA = SUBSTR(VDATA,7,4)||SUBSTR(VDATA,1,2)||SUBSTR(VDATA,4,2);" + CRLF
		cCommand1 += "    END IF;" + CRLF
		cCommand1 += "    RETURN (VDATA);" + CRLF
		cCommand1 += "END"

		//PMS_DATEDIFF
		cCommand2 := "CREATE FUNCTION PMS_DATEDIFF (DATEPART VARCHAR(10)," + CRLF
		cCommand2 += "                              DATA1 VARCHAR(10)," + CRLF
		cCommand2 += "                              DATA2 VARCHAR(10))" + CRLF
		cCommand2 += "RETURNS INTEGER" + CRLF
		cCommand2 += "BEGIN ATOMIC" + CRLF
		cCommand2 += "    DECLARE VDATA1 DATE;" + CRLF
		cCommand2 += "    DECLARE VDATA2 DATE;" + CRLF
		cCommand2 += "    DECLARE VIMESES1 INTEGER;" + CRLF
		cCommand2 += "    DECLARE VIMESES2 INTEGER;" + CRLF
		cCommand2 += "    DECLARE VIDIFF INTEGER;" + CRLF
		cCommand2 += "    IF DATA1 = ' ' OR DATA1 IS NULL OR DATA2 = ' ' OR DATA2 IS NULL THEN" + CRLF
		cCommand2 += "        SET VIDIFF = 0;" + CRLF
		cCommand2 += "    ELSE" + CRLF
		cCommand2 += "       SET VIDIFF = 0;" + CRLF
		cCommand2 += "       IF UPPER(DATEPART) = 'DAY'  THEN" + CRLF
		cCommand2 += "          SET VDATA1 = DATE( SUBSTR( DATA1, 1, 4 )||'-'||SUBSTR( DATA1, 5, 2 )||'-'||SUBSTR( DATA1, 7, 2 ) );" + CRLF
		cCommand2 += "          SET VDATA2 = DATE( SUBSTR( DATA2, 1, 4 )||'-'||SUBSTR( DATA2, 5, 2 )||'-'||SUBSTR( DATA2, 7, 2 ) );" + CRLF
		cCommand2 += "          SET VIDIFF = DAYS(VDATA2) - DAYS(VDATA1);" + CRLF
		cCommand2 += "       END IF;" + CRLF
		cCommand2 += "       IF UPPER(DATEPART) = 'MONTH'  THEN" + CRLF
		cCommand2 += "          SET VIMESES1 = INTEGER ( SUBSTR( DATA1, 1, 4 ) ) * 12 + INTEGER ( SUBSTR( DATA1, 5, 2 ) ) ;" + CRLF
		cCommand2 += "          SET VIMESES2 = INTEGER ( SUBSTR( DATA2, 1, 4 ) ) * 12 + INTEGER ( SUBSTR( DATA2, 5, 2 ) ) ;" + CRLF
		cCommand2 += "          SET VIDIFF = VIMESES2 - VIMESES1;" + CRLF
		cCommand2 += "       END IF;" + CRLF
		cCommand2 += "       IF UPPER(DATEPART) = 'YEAR'  THEN" + CRLF
		cCommand2 += "          SET VIDIFF = INTEGER ( SUBSTR( DATA2, 1, 4 ) ) - INTEGER ( SUBSTR( DATA1, 1, 4 ) );" + CRLF
		cCommand2 += "       END IF;" + CRLF
		cCommand2 += "    END IF;" + CRLF
		cCommand2 += "    RETURN(VIDIFF);" + CRLF
		cCommand2 += "END"

	ElseIf cDataBase == "INFORMIX"
		//PMS_DATEADD
		cCommand1 := "CREATE PROCEDURE PMS_DATEADD (" + CRLF
		cCommand1 += "   DATEPART VarChar( 10 ) , " + CRLF
		cCommand1 += "   QTDE INTEGER , " + CRLF
		cCommand1 += "   CDATA VarChar(8) ) " + CRLF
		cCommand1 += "   Returning  Date;" + CRLF
		cCommand1 += "   DEFINE vData DATE ;" + CRLF
		cCommand1 += "   DEFINE vANO CHAR(4);" + CRLF
		cCommand1 += "   DEFINE vMES CHAR(2);" + CRLF
		cCommand1 += "   DEFINE vDIA CHAR(2);" + CRLF
		cCommand1 += "   DEFINE vCONT INTEGER;" + CRLF
		cCommand1 += "   DEFINE vB INTEGER;" + CRLF
		cCommand1 += "   DEFINE vULTDIA INTEGER;" + CRLF
		cCommand1 += "   BEGIN" + CRLF
		cCommand1 += "      IF CDATA = '        ' Then" + CRLF
		cCommand1 += "      	 LET CDATA = '19800101';" + CRLF
		cCommand1 += " 	  END IF;" + CRLF
		cCommand1 += " 	  LET vDATA = TO_DATE(CDATA,'%Y%m%d');" + CRLF
		cCommand1 += "      LET vB = 0;" + CRLF
		cCommand1 += "      LET vANO = YEAR(vDATA);" + CRLF
		cCommand1 += "      LET vMES = MONTH(vDATA);" + CRLF
		cCommand1 += "      LET vDIA = DAY(vDATA);" + CRLF
		cCommand1 += "      IF UPPER(TRIM(DATEPART)) = 'MONTH' Then" + CRLF
		cCommand1 += "         LET vCONT = 1;" + CRLF
		cCommand1 += "         WHILE ( vCONT <= QTDE)" + CRLF
		cCommand1 += "            LET vMES = VMES + 1;" + CRLF
		cCommand1 += "            IF vMES = 13 THEN" + CRLF
		cCommand1 += "               LET vANO = vANO +1;" + CRLF
		cCommand1 += "                LET vMES = 1;" + CRLF
		cCommand1 += "            END IF;    " + CRLF
		cCommand1 += "            LET vCONT =  vCONT+1;" + CRLF
		cCommand1 += "         END WHILE" + CRLF
		cCommand1 += "      END IF;" + CRLF
		cCommand1 += "      IF UPPER(TRIM(DATEPART)) = 'YEAR' Then" + CRLF
		cCommand1 += "         LET vANO = vANO+QTDE;" + CRLF
		cCommand1 += "      END IF;    " + CRLF
		cCommand1 += "      IF  ( MOD(vANO,4) = 0 )  AND( ( MOD (vANO,100)  <> 0 ) OR ( MOD(vANO,400) = 0) ) THEN" + CRLF
		cCommand1 += "         LET  vB=1;" + CRLF
		cCommand1 += "      END IF;" + CRLF
		cCommand1 += "      IF vMES = 2 THEN" + CRLF
		cCommand1 += "         IF vB = 1 THEN " + CRLF
		cCommand1 += "            LET vULTDIA = 29;" + CRLF
		cCommand1 += "         ELSE" + CRLF
		cCommand1 += "            LET vULTDIA = 28;" + CRLF
		cCommand1 += "         END IF; " + CRLF
		cCommand1 += "      ELSE " + CRLF
		cCommand1 += "         IF vMES = 04 OR vMES = 06 OR vMES = 09 OR vMES = 11 THEN            " + CRLF
		cCommand1 += "            LET vULTDIA = 30;" + CRLF
		cCommand1 += "         ELSE" + CRLF
		cCommand1 += "            LET vULTDIA = 31;" + CRLF
		cCommand1 += "         END IF;" + CRLF
		cCommand1 += "      END IF;  " + CRLF
		cCommand1 += "      IF vDIA > vULTDIA THEN " + CRLF
		cCommand1 += "         LET vDIA = vULTDIA;" + CRLF
		cCommand1 += "      END IF;  " + CRLF
		cCommand1 += "      IF UPPER(TRIM(DATEPART)) = 'DAY' then " + CRLF
		cCommand1 += "         LET  vdata = DATE(vDATA)+QTDE; " + CRLF
		cCommand1 += "      ELSE  " + CRLF
		cCommand1 += "         LET vDATA = MDY(vMES,vDIA,vANO);" + CRLF
		cCommand1 += "      END IF;" + CRLF
		cCommand1 += "      RETURN(vData);" + CRLF
		cCommand1 += "   END" + CRLF
		cCommand1 += "END PROCEDURE;" + CRLF

		//PMS_DATEDIFF
		cCommand2 := "CREATE PROCEDURE PMS_DATEDIFF (" + CRLF
		cCommand2 += "   DATEPART VarChar( 10 ) , " + CRLF
		cCommand2 += "   CDATA1 VarChar(8) ," + CRLF
		cCommand2 += "   CDATA2 VarChar(8) )    " + CRLF
		cCommand2 += "   Returning  INTEGER ;" + CRLF
		cCommand2 += "   DEFINE nDIF   INTEGER;" + CRLF
		cCommand2 += "   DEFINE nMESES1 INTEGER;" + CRLF
		cCommand2 += "   DEFINE nMESES2 INTEGER;" + CRLF
		cCommand2 += "   DEFINE vDATA1 DATE;" + CRLF
		cCommand2 += "   DEFINE vDATA2 DATE;" + CRLF
		cCommand2 += "   BEGIN" + CRLF
		cCommand2 += "      IF CDATA1 = '        ' Then" + CRLF
		cCommand2 += "         LET CDATA1 = '19000101';" + CRLF
		cCommand2 += "      END IF;" + CRLF
		cCommand2 += "      LET vDATA1 = TO_DATE(CDATA1,'%Y%m%d');      " + CRLF
		cCommand2 += "      IF CDATA2 = '        ' Then" + CRLF
		cCommand2 += "         LET CDATA2 = '19000101';" + CRLF
		cCommand2 += "      END IF;      " + CRLF
		cCommand2 += "      LET vDATA2 = TO_DATE(CDATA2,'%Y%m%d');      " + CRLF
		cCommand2 += "      IF UPPER(TRIM(DATEPART)) = 'YEAR' Then" + CRLF
		cCommand2 += "            LET nDIF = YEAR(vDATA2)-YEAR(vDATA1);" + CRLF
		cCommand2 += "      END IF;" + CRLF
		cCommand2 += "      IF UPPER(TRIM(DATEPART)) = 'MONTH' Then     " + CRLF
		cCommand2 += "          LET nMESES1 = ( YEAR(vDATA1)*12)+MONTH(vDATA1);" + CRLF
		cCommand2 += "          LET nMESES2 = ( YEAR(vDATA2)*12)+MONTH(vDATA2);" + CRLF
		cCommand2 += "          LET nDIF = nMESES2-nMESES1;" + CRLF
		cCommand2 += "      END IF;" + CRLF
		cCommand2 += "      IF UPPER(TRIM(DATEPART)) = 'DAY' then " + CRLF
		cCommand2 += "           LET  nDIF  = vDATA2-vDATA1;" + CRLF
		cCommand2 += "      END IF;" + CRLF
		cCommand2 += "      RETURN (nDIF);      " + CRLF
		cCommand2 += "   END" + CRLF
		cCommand2 += "END PROCEDURE;"

	ElseIf cDataBase == "ORACLE"
		//PMS_DATEADD
		cCommand1 := "CREATE OR REPLACE FUNCTION PMS_DATEADD (DATEPART IN VARCHAR,QTDE IN INTEGER,dDATA IN CHAR)" + CRLF
		cCommand1 += "RETURN DATE" + CRLF
		cCommand1 += "IS" + CRLF
		cCommand1 += "vdata DATE;" + CRLF
		cCommand1 += "vano CHAR(8);" + CRLF
		cCommand1 += "vB INTEGER;" + CRLF
		cCommand1 += "vULTDIA INTEGER;" + CRLF
		cCommand1 += "nDIA INTEGER;" + CRLF
		cCommand1 += "nMES INTEGER;" + CRLF
		cCommand1 += "nANO INTEGER;" + CRLF
		cCommand1 += "dDATA1 DATE;" + CRLF + CRLF
		cCommand1 += "BEGIN" + CRLF
		cCommand1 += "   IF ( LTrim( RTrim( dDATA ) ) ) is null  or dDATA = '' then" + CRLF
		cCommand1 += "      dDATA1 := TO_DATE( '19800101','YYYYMMDD' );" + CRLF
		cCommand1 += "   ELSE" + CRLF
		cCommand1 += "      dDATA1 := TO_DATE( dDATA,'YYYYMMDD' );" + CRLF
		cCommand1 += "   END IF;" + CRLF
		cCommand1 += "   IF UPPER(DATEPART) = 'DAY' Then" + CRLF
		cCommand1 += "      vdata := dDATA1+QTDE; " + CRLF
		cCommand1 += "   END IF;" + CRLF
		cCommand1 += "   IF UPPER(DATEPART) = 'MONTH' Then" + CRLF
		cCommand1 += "      vdata := ADD_MONTHS(dDATA1,QTDE);" + CRLF
		cCommand1 += "   END IF;" + CRLF
		cCommand1 += "   IF UPPER(DATEPART) = 'YEAR' Then" + CRLF
		cCommand1 += "      vB := 0;" + CRLF
		cCommand1 += "      nDIA:=TO_NUMBER(TO_CHAR(dDATA1,'DD'));" + CRLF
		cCommand1 += "      nMES:=TO_NUMBER(TO_CHAR(dDATA1,'MM'));" + CRLF
		cCommand1 += "      nANO:=TO_NUMBER(TO_CHAR(dDATA1,'YYYY'));" + CRLF
		cCommand1 += "      IF  (MOD(nANO+QTDE,4) = 0 )  AND ((MOD(nANO+QTDE,100)  <> 0) OR (MOD(nANO+QTDE,400) = 0)) THEN" + CRLF
		cCommand1 += "         vB:=1;" + CRLF
		cCommand1 += "      END IF;" + CRLF
		cCommand1 += "      IF nMES = 2 THEN" + CRLF
		cCommand1 += "         IF vB = 1 THEN" + CRLF
		cCommand1 += "            vULTDIA := 29;" + CRLF
		cCommand1 += "         ELSE" + CRLF
		cCommand1 += "            vULTDIA := 28;" + CRLF
		cCommand1 += "         END IF;" + CRLF
		cCommand1 += "      ELSE" + CRLF
		cCommand1 += "         IF nMES = 04 OR nMES = 06 OR nMES = 09 OR nMES = 11 THEN" + CRLF
		cCommand1 += "            vULTDIA := 30;" + CRLF
		cCommand1 += "         ELSE" + CRLF
		cCommand1 += "            vULTDIA := 31;" + CRLF
		cCommand1 += "         END IF;" + CRLF
		cCommand1 += "      END IF;" + CRLF
		cCommand1 += "      IF nDIA > vULTDIA THEN" + CRLF
		cCommand1 += "         nDIA := vULTDIA;" + CRLF
		cCommand1 += "      END IF;" + CRLF + CRLF
		cCommand1 += "      vano :=  TO_CHAR(TO_NUMBER(TO_CHAR(dDATA1,'YYYY'))+QTDE)||TO_CHAR(dDATA1,'MM')||TO_CHAR(nDIA);" + CRLF
		cCommand1 += "      vdata := TO_DATE(vano,'YYYYMMDD');" + CRLF
		cCommand1 += "   END IF;" + CRLF
		cCommand1 += "   RETURN( vdata );" + CRLF
		cCommand1 += "END;" + CRLF

		//PMS_DATEDIFF
		cCommand2 := "CREATE OR REPLACE FUNCTION PMS_DATEDIFF (DATEPART IN VARCHAR,DATA1 IN CHAR,DATA2 IN CHAR)" + CRLF
		cCommand2 += "RETURN INTEGER" + CRLF
		cCommand2 += "IS" + CRLF
		cCommand2 += "nDIF   INTEGER;" + CRLF
		cCommand2 += "nMESES1 INTEGER;" + CRLF
		cCommand2 += "nMESES2 INTEGER;" + CRLF
		cCommand2 += "dDATA1  DATE;" + CRLF
		cCommand2 += "dDATA2  DATE;" + CRLF + CRLF
		cCommand2 += "BEGIN" + CRLF
		cCommand2 += "   dDATA1 := TO_DATE(DATA1,'YYYYMMDD');" + CRLF
		cCommand2 += "   dDATA2 := TO_DATE(DATA2,'YYYYMMDD');" + CRLF
		cCommand2 += "   IF UPPER(DATEPART) = 'DAY' Then" + CRLF
		cCommand2 += "      nDIF  := dDATA2-dDATA1;" + CRLF
		cCommand2 += "   END IF;" + CRLF
		cCommand2 += "   IF UPPER(DATEPART) = 'MONTH' Then" + CRLF
		cCommand2 += "      nMESES1 := ( TO_NUMBER(TO_CHAR(dDATA1,'YYYY'))*12)+TO_NUMBER(TO_CHAR(dDATA1,'MM'));" + CRLF
		cCommand2 += "      nMESES2 := ( TO_NUMBER(TO_CHAR(dDATA2,'YYYY'))*12)+TO_NUMBER(TO_CHAR(dDATA2,'MM'));" + CRLF
		cCommand2 += "      nDIF := nMESES2-nMESES1;" + CRLF
		cCommand2 += "   END IF;" + CRLF
		cCommand2 += "   IF UPPER(DATEPART) = 'YEAR' Then" + CRLF
		cCommand2 += "      nDIF := TO_NUMBER(TO_CHAR(dDATA2,'YYYY'))-TO_NUMBER(TO_CHAR(dDATA1,'YYYY'));" + CRLF
		cCommand2 += "   END IF;" + CRLF
		cCommand2 += "   RETURN(nDIF);" + CRLF
		cCommand2 += "END;" + CRLF
	EndIf

	If !Empty(cCommand1) .And. !Empty(cCommand2)

		xProc := ''
		For nX := 1 To Len(cCommand1)
		    nCaracter := asc(Substr(cCommand1,nX,1))
		    If nCaracter == 13
		       xProc += ''
		    ElseIf nCaracter == 10
		       xProc += chr(10)
		    Else
		       xProc += Subs(cCommand1,nX,1)
		    EndIf
		Next
		cCommand1 := xProc

		cRetSQL :=TCSqlExec(cCommand1)

		If cRetSQL <> 0
			If !__lBlind
	 			MsgAlert(STR0260+" "+cCommand1+": "+TCSqlError())  //'Erro criando a Stored Procedure:'
			EndIf
		EndIf

		cRetSQL := ""

		xProc := ''
		For nX := 1 To Len(cCommand2)
		    nCaracter := asc(Substr(cCommand2,nX,1))
		    If nCaracter == 13
		       xProc += ''
		    ElseIf nCaracter == 10
		       xProc += chr(10)
		    Else
		       xProc += Subs(cCommand2,nX,1)
		    EndIf
		Next
		cCommand2 := xProc

		cRetSQL :=TCSqlExec(cCommand2)

		If cRetSQL <> 0
			If !__lBlind
	 			MsgAlert(STR0260+" "+cCommand2+": "+TCSqlError())  //'Erro criando a Stored Procedure:'
			EndIf
		EndIf
	EndIf
Else
//**************************************
//BLOCO DE REMO«√O DE PROCEDURE/FUNCTION
//**************************************/
	If cDataBase == "DB2" .Or. cDataBase == "ORACLE"
		//DROP PMS_DATEADD
		cCommand1 := "DROP FUNCTION PMS_DATEADD"
		//DROP PMS_DATEDIFF
		cCommand2 := "DROP FUNCTION PMS_DATEDIFF"
	ElseIf cDataBase == "INFORMIX"
		//DROP PMS_DATEADD
      cCommand1 := "DROP PROCEDURE PMS_DATEADD"
		//DROP PMS_DATEDIFF
      cCommand2 := "DROP PROCEDURE PMS_DATEDIFF"
	EndIf

	If !Empty(cCommand1) .And. !Empty(cCommand2)
		cRetSQL :=TCSqlExec(cCommand1)

		If cRetSQL <> 0
			If !__lBlind
	 			MsgAlert(STR0263+" "+cCommand1+": "+TCSqlError())  //'Erro excluindo a Stored Procedure:'
			EndIf
		EndIf

		cRetSQL := ""

		cRetSQL :=TCSqlExec(cCommand2)

		If cRetSQL <> 0
			If !__lBlind
	 			MsgAlert(STR0263+" "+cCommand2+": "+TCSqlError())  //'Erro excluindo a Stored Procedure:'
			EndIf
		EndIf
	EndIf
EndIf

Return Nil


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥PmsAltAC9 ∫Autor  ≥Clovis Magenta      ∫ Data ≥  31/01/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Funcao que ira alterar o registro da tabela de amarracao de∫±±
±±∫          ≥ Documentos - AC9 - ao recodificar as EDTs e tarefas        ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Function PmsAltAC9( cAlias, nReg , cNovoCodigo , cEntAntiga)

Local nScan			:= 0
Local nX				:= 0
Local aEntidade 	:= {}
Local aChave		:= {}
Local aRecAC9		:= {}
Local cCodDesc		:= ""
Local cCodEnt		:= ""

Default cAlias 		:= ""
Default cNovoCodigo	:= ""
Default nReg			:= 0

dbSelectArea( cAlias )
MsGoto( nReg )

aEntidade := MsRelation()

nScan := AScan( aEntidade, { |x| x[1] == cAlias } )

aChave   := aEntidade[ nScan, 2 ]
cCodEnt  := MaBuildKey( cAlias, aChave )

cCodDesc := AllTrim( cCodEnt ) + "-" + Capital( Eval( aEntidade[ nScan, 3 ] ) )

CodEnt  := PadR( cCodEnt, TamSX3("AC9_CODENT")[1] )

dbSelectArea("AC9")
dbSetOrder(2) //AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT+AC9_CODOBJ
DbSeek(xFilial("AC9")+cAlias+xFilial(cAlias)+cEntAntiga )
While AC9->(!EOF()) .and. xFilial("AC9")+cAlias+xFilial(cAlias)+cEntAntiga == AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT

	aAdd( aRecAC9 , AC9->(Recno()) )

	AC9->(dbSkip())
EndDo

For nX := 1 to Len(aRecAC9)
	AC9->(DbGoTo(aRecAC9[nX]))
	RecLock("AC9", .F.)
		AC9_CODENT := cCodEnt
	MsUnlock()
Next nX

Return



/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥PmsGetEnt ∫Autor  ≥Clovis Magenta      ∫ Data ≥  31/01/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Funcao que resgatara a entidade da tarefa antes dela ter seu∫±±
±±∫          ≥codigo alterado                                             ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Function PmsGetEnt(cAlias, nReg)
Local nScan			:= 0
Local aEntidade 	:= {}
Local aChave		:= {}
Local cCodDesc		:= ""
Local cCodEnt		:= ""

Default cAlias 		:= ""
Default nReg			:= 0

dbSelectArea( cAlias )
MsGoto( nReg )

aEntidade := MsRelation()

nScan := AScan( aEntidade, { |x| x[1] == cAlias } )

aChave   := aEntidade[ nScan, 2 ]
cCodEnt  := MaBuildKey( cAlias, aChave )

Return PadR( cCodEnt, TamSX3("AC9_CODENT")[1] )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados do Cadastro de Projetos

@author Wilson.Godoi
@since 31/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oStruAF8 	:= FWFormStruct( 1, 'AF8', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruANE 	:= NIL
Local oModel		:= Nil
Local aRelacANE	:= {}
Local lVersao		:= PMSVersion()
Local lExistANE	:= lVersao

PRIVATE l200auto := .F.

//-----------------------------------------
//Monta o modelo do formul·rio
//-----------------------------------------
oModel:= MPFormModel():New("PMSA200",, {|oModel| Pms200Ok(oModel)}, {|oModel| Pms200Atu(oModel)},/*Cancel*/)
oModel:AddFields("AF8MASTER", /*cOwner*/, oStruAF8)
oModel:SetDescription( STR0001 )
oModel:GetModel("AF8MASTER"):SetDescription(STR0001)

//236.02
If Type("lAuto")=="L" .and. lAuto .and. lExistANE
	oStruANE 	:= FWFormStruct(1, 'ANE', /*bAvalCampo*/, /*lViewUsado*/)
	oModel:AddGrid('ANEDETAIL', 'AF8MASTER', oStruANE, /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/)

	//Relacionamento da tabela Contratos do Projeto
	aAdd(aRelacANE,{'ANE_FILIAL', 'xFilial("ANE")'})
	aAdd(aRelacANE,{'ANE_PROJET', 'AF8_PROJET'})
	aAdd(aRelacANE,{'ANE_REVISA', 'AF8_REVISA'})

	oModel:SetRelation('ANEDETAIL', aRelacANE, ANE->(IndexKey(1)))
	oModel:GetModel('ANEDETAIL'):SetOptional(.T.)
	oModel:GetModel('ANEDETAIL'):SetUniqueLine({'ANE_CONTRA'})
Endif

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Visualizador de dados do Cadastro de Projetos

@author Wilson.Godoi
@since 31/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel		:= FWLoadModel("PMSA200")	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oStruAF8	:= FWFormStruct(2, 'AF8')	// Cria a estrutura a ser usada na View
Local oStruANE	:= NIL
Local oView		:= FWFormView():New()		// Cria o objeto de View
Local lVersao		:= PMSVersion()
Local lExistANE	:= lVersao
Local nI			:= 0

Private aButtonUsr  :={}
Private aUsButtons	:= {}

oView:SetModel(oModel)											// Define qual o Modelo de dados ser· utilizado
oView:AddField('VIEW_AF8', oStruAF8, 'AF8MASTER')			//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('MASTER',100)
oView:SetOwnerView('VIEW_AF8', 'MASTER')

If Type("lAuto") == "L" .and. lAuto .and. lExistANE
	oStruANE	:= FWFormStruct(2, 'ANE')
	oStruANE:RemoveField('ANE_FILIAL')
	oStruANE:RemoveField('ANE_PROJET')
	oStruANE:RemoveField('ANE_REVISA')
	oView:AddGrid('VIEW_ANE', oStruANE, 'ANEDETAIL')
Endif

//Inclui Botıes na AÁıes Relacionadas da Alt.Cadastro
If nOperation == 4 .and. ExistBlock("PM200BU2")
		aButtonUsr := ExecBlock("PM200BU2",.F.,.F.)
		If ValType(aButtonUsr) == "A"
			For nI := 1 To Len(aButtonUsr)
				oView:AddUserButton( aButtonUsr[nI][3], aButtonUsr[nI][1], aButtonUsr[nI][2],NIL,NIL)
			Next nI
		Endif
EndIf

// Inclui Botıes na AÁıes Relacionadas da Incluir.
If nOperation == 3 .and. ExistBlock("PM200BUT")
		aUsButtons := ExecBlock("PM200BUT",.F.,.F.)
	If ValType(aUsButtons) == "A"
		For nI := 1 To Len(aUsButtons)
			oView:AddUserButton( aUsButtons[nI][1], aUsButtons[nI][3], aUsButtons[nI][2],NIL,NIL)
		Next nI
	Endif
EndIf

Return oView

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥PmsVldAFW ∫Autor  ≥Clovis Magenta      ∫ Data ≥  06/12/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Validacao para caso exista apontamento pendente de finaliza-∫±±
±±∫          ≥cao no monitor de tarefas.                                  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function PmsVldAFW()
Local lOK 		:= .T.
Local aArea 	:= GetArea()
Local cQuery	:= ""
Local cAlias	:= GetNextAlias()

cQuery += "SELECT COUNT(AFW_RECURS) NCONT FROM "+RetSqlName("AFW")
cQuery += " WHERE AFW_PROJET = '"+AF8->AF8_PROJET+"'"
cQuery += " AND D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .T.)
If (cAlias)->NCONT > 0
	lOK := .F.
	Aviso(STR0292,STR0291,{STR0136},2)
	//"Apontamento existente!"
	//"Este projeto possui apontamento pendente de finalizaÁ„o no monitor de tarefas. Finalize o memso para alterar a fase do projeto."
Endif
(cAlias)->(DbcloseArea())

RestArea(aArea)

Return lOK

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥INTEGDEF  ∫Autor  ≥Wilson de Godoi      ∫ Data ≥ 28/12/2012 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥FunÁ„o para a interaÁ„o com EAI                             ∫±±
±±∫          ≥envio e recebimento                                         ∫±±
±±∫          ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function IntegDef( cXml, nType, cTypeMsg )
Local aRet := {}

	aRet:= PMSI200( cXml, nType, cTypeMsg )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PMSAltPrj
Efetua a troca de um codigo de projeto cadastrado por um outro codigo

@author Reynaldo Tetsu Miyashita
@since 17/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function PMSAltPrj(cAlias,nReg,nOpcx,xreserv,yreserv,aGetCpos)
Local aArea     := GetArea()
Local aAliasCpy := {}
Local aAliasUpd := {}
Local lOk       := .F.
Local cGetPict  := PesqPict('AF8','AF8_PROJET')
Local oDlg
Local oOldCode
Local oNewCode
Local cPrjAtual := ""
Local cPrjNovo  := ""
Local aValidGet := {}
Local aBlkAjuste := {{|| if( AFC->AFC_EDT = cPrjAtual, AFC->AFC_EDT := cPrjNovo,)}, {||if( AFC->AFC_EDTPAI = cPrjAtual, AFC->AFC_EDTPAI := cPrjNovo,)}}

	If TamSX3("AFC_PROJET")[1] > TamSX3("AFC_EDT")[1]
		Help(" ",1,"A200TAMAFC")
	Else
		dbSelectArea("AF8")

		// chamada por rotina automatica
		If !Empty(aGetCpos)

			If (nPosCod:=Ascan(aGetCpos,{|x|Alltrim(x[1]) == 'AF8_PROJET'}))>0
				cPrjAtual := aGetCpos[nPosCod][2]
			EndIf
			If (nPosCod:=Ascan(aGetCpos,{|x|Alltrim(x[1]) == 'NEW_AF8_PROJET'}))>0
				cPrjNovo := aGetCpos[nPosCod][2]
			EndIf

			cPrjAtual := padr(cPrjAtual,Tamsx3("AF8_PROJET")[1])
			cPrjNovo := padr(cPrjNovo,Tamsx3("AF8_PROJET")[1])

			lOk := .F.

			aValidGet := {}
			Aadd(aValidGet,{'cPrjAtual' ,cPrjAtual,"ExistCpo('AF8',cPrjAtual)",.t.})
			Aadd(aValidGet,{'cPrjNovo'  ,cPrjNovo,"NoExistPrj(cPrjNovo)",.t.})
			If AF8->(MsVldGAuto(aValidGet)) // consiste os gets
				lOk := .T.
			EndIF

		Else
			cPrjAtual := padr(AF8->AF8_PROJET,Tamsx3("AF8_PROJET")[1])
			cPrjNovo := SPACE(Tamsx3("AF8_PROJET")[1])
			Define MsDialog oDlg Title STR0293 From 0, 0 To 125, 300 Of oMainWnd Pixel

				// codigo atual
				@ 010, 005 Say STR0294 Of oDlg Pixel
				@ 009, 045 MSGet oOldCode Var cPrjAtual Valid ExistCpo("AF8",cPrjAtual) Of oDlg;
							   Picture cGetPict F3 'AF8' HASBUTTON;
							   Size 100, 08 Pixel
				// novo codigo
				@ 022, 005 Say STR0295 Of oDlg Pixel
				@ 021, 045 MSGet oNewCode Var cPrjNovo Valid Empty(cPrjNovo).OR.NoExistPrj(cPrjNovo) Of oDlg;
							   Picture cGetPict Size 100, 08 Pixel

				// OK
				@ 038, 065 Button "OK" Size 35 ,11 FONT oDlg:oFont Action iIf(!Empty(cPrjAtual).and.!Empty(cPrjNovo),(lOk := .T., oDlg:End()),.F.) Of oDlg Pixel

				// Cancelar
				@ 038, 110 Button STR0018 Size 35 ,11 FONT oDlg:oFont Action (lOk := .F., oDlg:End()) Of oDlg Pixel //"Cancela"

			Activate MsDialog oDlg On Init oNewCode:SetFocus() Centered
		EndIf

		If lOk

			//
			cPrjAtual := padr(cPrjAtual,Tamsx3("AF8_PROJET")[1])
			cPrjNovo := padr(cPrjNovo,Tamsx3("AF8_PROJET")[1])

			// lista dos alias que devem ter os registros duplicados
			aAliasCpy := {}

			aAdd( aAliasCpy, {"AF8", 1, {{"AF8_FILIAL", FwxFilial("AF8")}, {"AF8_PROJET",cPrjAtual}}                                 ,{{"AF8_PROJET" ,cPrjNovo}  }})                         // Projetos                 - AF8_FILIAL+AF8_PROJET+AF8_DESCRI
			aAdd( aAliasCpy, {"AF9", 1, {{"AF9_FILIAL", FwxFilial("AF9")}, {"AF9_PROJET",cPrjAtual}, {"AF9_EDTPAI", cPrjAtual}}      ,{{"AF9_PROJET" ,cPrjNovo}, {"AF9_EDTPAI" ,cPrjNovo}}}) // Tarefas do Projeto       - AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_TAREFA+AF9_ORD
			aAdd( aAliasCpy, {"AF9", 1, {{"AF9_FILIAL", FwxFilial("AF9")}, {"AF9_PROJET",cPrjAtual}, {"AF9_EDTPAI", cPrjAtual,"<>"}} ,{{"AF9_PROJET" ,cPrjNovo}  }})
			aAdd( aAliasCpy, {"AFC", 1, {{"AFC_FILIAL", FwxFilial("AFC")}, {"AFC_PROJET",cPrjAtual}, {"AFC_EDT",    cPrjAtual}}      ,{{"AFC_PROJET" ,cPrjNovo}, {"AFC_EDT"    ,cPrjNovo}}}) // Estrutura do Projeto     - AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDT+AFC_ORDEM
			aAdd( aAliasCpy, {"AFC", 1, {{"AFC_FILIAL", FwxFilial("AFC")}, {"AFC_PROJET",cPrjAtual}, {"AFC_EDTPAI", cPrjAtual}}      ,{{"AFC_PROJET" ,cPrjNovo}, {"AFC_EDTPAI" ,cPrjNovo}}})
			aAdd( aAliasCpy, {"AFC", 1, {{"AFC_FILIAL", FwxFilial("AFC")}, {"AFC_PROJET",cPrjAtual}, {"AFC_EDT",    cPrjAtual,"<>"}  ;
			                                                                                       , {"AFC_EDTPAI", cPrjAtual,"<>"}} ,{{"AFC_PROJET" ,cPrjNovo}  }})
			aAdd( aAliasCpy, {"AFD", 1, {{"AFD_FILIAL", FwxFilial("AFD")}, {"AFD_PROJET",cPrjAtual}}                                 ,{{"AFD_PROJET", cPrjNovo}  }})                                                             // Relacionamentos          - AFD_FILIAL+AFD_PROJET+AFD_REVISA+AFD_TAREFA+AFD_ITEM
			aAdd( aAliasCpy, {"AFF", 1, {{"AFF_FILIAL", FwxFilial("AFF")}, {"AFF_PROJET",cPrjAtual}}                                 ,{{"AFF_PROJET", cPrjNovo}  }})                                                            // ConfirmaÁıes             - AFF_FILIAL+AFF_PROJET+AFF_REVISA+AFF_TAREFA+DTOS(AFF_DATA)
			aAdd( aAliasCpy, {"AFP", 1, {{"AFP_FILIAL", FwxFilial("AFP")}, {"AFP_PROJET",cPrjAtual}, {"AFP_EDT",    cPrjAtual,"<>"}} ,{{"AFP_PROJET", cPrjNovo}  }})                                                             // Eventos do Projeto       - AFP_FILIAL+AFP_PROJET+AFP_REVISA+AFP_EDT+AFP_TAREFA+DTOS(AFP_DTCALC) Atualiza eventos das EDTs
			aAdd( aAliasCpy, {"AFP", 1, {{"AFP_FILIAL", FwxFilial("AFP")}, {"AFP_PROJET",cPrjAtual}, {"AFP_EDT",    cPrjAtual,"="}}  ,{{"AFP_PROJET", cPrjNovo}, {"AFP_EDT"    ,cPrjNovo}}})                                     // Eventos do Projeto       - AFP_FILIAL+AFP_PROJET+AFP_REVISA+AFP_EDT+AFP_TAREFA+DTOS(AFP_DTCALC) Atualiza eventos da EDT Principal
			aAdd( aAliasCpy, {"AFQ", 1, {{"AFQ_FILIAL", FwxFilial("AFQ")}, {"AFQ_PROJET",cPrjAtual}, {"AFQ_EDT",    cPrjAtual}}      ,{{"AFQ_PROJET",cPrjNovo},  {"AFQ_EDT" ,cPrjNovo}}}) // ConfirmaÁıes  - AFQ_FILIAL+AFQ_PROJET+AFQ_REVISA+AFQ_EDT+DTOS(AFQ_DATA)
			aAdd( aAliasCpy, {"AFQ", 1, {{"AFQ_FILIAL", FwxFilial("AFQ")}, {"AFQ_PROJET",cPrjAtual}, {"AFQ_EDT",    cPrjAtual,"<>"}} ,{{"AFQ_PROJET",cPrjNovo}   }})
			aAdd( aAliasCpy, {"AFX", 1, {{"AFX_FILIAL", FwxFilial("AFX")}, {"AFX_PROJET",cPrjAtual}, {"AFX_EDT",    cPrjAtual}}      ,{{"AFX_PROJET",cPrjNovo},  {"AFX_EDT" ,cPrjNovo}}}) // Usu·rios      - AFX_FILIAL+AFX_PROJET+AFX_REVISA+AFX_EDT+AFX_USER+AFX_FASE
			aAdd( aAliasCpy, {"AFY", 1, {{"AFY_FILIAL", FwxFilial("AFY")}, {"AFY_PROJET",cPrjAtual}}                                 ,{{"AFY_PROJET",cPrjNovo}   }}) // ExceÁıes ao Calend·rio       - AFY_FILIAL+AFY_PROJET+AFY_RECURS+DTOS(AFY_DATA)
			aAdd( aAliasCpy, {"AJ4", 1, {{"AJ4_FILIAL", FwxFilial("AJ4")}, {"AJ4_PROJET",cPrjAtual}}                                 ,{{"AJ4_PROJET",cPrjNovo}   }}) // Relac Tarefa x EDT (Projeto) - AJ4_FILIAL+AJ4_PROJET+AJ4_REVISA+AJ4_TAREFA+AJ4_ITEM
			aAdd( aAliasCpy, {"AJ5", 1, {{"AJ5_FILIAL", FwxFilial("AJ5")}, {"AJ5_PROJET",cPrjAtual}}                                 ,{{"AJ5_PROJET",cPrjNovo}   }}) // Relac EDT x Tarefa (Projeto) - AJ5_FILIAL+AJ5_PROJET+AJ5_REVISA+AJ5_EDT+AJ5_ITEM
			aAdd( aAliasCpy, {"AJ6", 1, {{"AJ6_FILIAL", FwxFilial("AJ6")}, {"AJ6_PROJET",cPrjAtual}}                                 ,{{"AJ6_PROJET",cPrjNovo}   }}) // Relac EDT x EDT (Projeto)    - AJ6_FILIAL+AJ6_PROJET+AJ6_REVISA+AJ6_EDT+AJ6_ITEM
			aAdd( aAliasCpy, {"AFE", 1, {{"AFE_FILIAL", FwxFilial("AFE")}, {"AFE_PROJET",cPrjAtual}}                                 ,{{"AFE_PROJET",cPrjNovo}   }}) // Controle de Revisao do projeto - AFE_FILIAL+AFE_PROJET+AFE_REVISA

			//
			// deve duplicar o registro com o codigo do projeto Atual alterando para o novo codigo do projeto.
			If !IsBlind()
				MsgRun(STR0296,STR0293,{||auxCpyReg(aAliasCpy)})
			Else
				auxCpyReg(aAliasCpy)
			Endif

			// lista dos alias que devem ser alterados o conteudo do cÛdigo do projeto
			aAliasUpd := {}
			// Tabelas sem indice
			aAdd( aAliasUpd, {"AFU", 0, {{"AFU_FILIAL",FwxFilial("AFU")}, {"AFU_PROJET",cPrjAtual}},{{"AFU_PROJET",cPrjNovo}}}) // Apontamento - AFU_FILIAL+AFU_CTRRVS+AFU_PROJET+AFU_REVISA+AFU_TAREFA+AFU_RECURS+DTOS(AFU_DATA)
			aAdd( aAliasUpd, {"AJ8", 0, {{"AJ8_FILIAL",FwxFilial("AJ8")}, {"AJ8_PROJPM",cPrjAtual}},{{"AJ8_PROJPM",cPrjNovo}}}) // Consulta Gerencial Projetos - AJ8_FILIAL AJ8_PROJPM
			aAdd( aAliasUpd, {"AJC", 0, {{"AJC_FILIAL",FwxFilial("AJC")}, {"AJC_PROJET",cPrjAtual}},{{"AJC_PROJET",cPrjNovo}}}) // Apontamento Direto          - AJC_FILIAL+AJC_CTRRVS+AJC_PROJET+AJC_REVISA+AJC_TAREFA+DTOS(AJC_DATA)
			aAdd( aAliasUpd, {"AJK", 0, {{"AJK_FILIAL",FwxFilial("AJK")}, {"AJK_PROJET",cPrjAtual}},{{"AJK_PROJET",cPrjNovo}}}) // Pre Apontamento Confirmacao - AJK_FILIAL+AJK_CTRRVS+AJK_PROJET+AJK_REVISA+AJK_TAREFA+AJK_RECURS+DTOS(AJK_DATA)
			aAdd( aAliasUpd, {"ANB", 0, {{"ANB_FILIAL",FwxFilial("ANB")}, {"ANB_PROJET",cPrjAtual}},{{"ANB_PROJET",cPrjNovo}}}) // Motivos das Rejeicoes       - ANB_FILIAL+ANB_FILREJ+ANB_PROJET+ANB_REVISA+ANB_TAREFA+DTOS(ANB_DATA)+ANB_HORA+ANB_TRFORI
			aAdd( aAliasUpd, {"SC9", 0, {{"C9_FILIAL" ,FwxFilial("SC9")}, {"C9_PROJPMS",cPrjAtual}},{{"C9_PROJPMS",cPrjNovo}}}) // Pedidos Liberados           - C9_FILIAL C9_PROJPMS
			aAdd( aAliasUpd, {"QI5", 0, {{"QI5_FILIAL",FwxFilial("QI5")}, {"QI5_PROJET",cPrjAtual}},{{"QI5_PROJET",cPrjNovo}}}) // AÁ„o Corretiva x AÁıes      - QI5_FILIAL QI5_PROJET
			aAdd( aAliasUpd, {"QUP", 0, {{"QUP_FILIAL",FwxFilial("QUP")}, {"QUP_PROJET",cPrjAtual}},{{"QUP_PROJET",cPrjNovo}}}) // Grupo x etapa               - QUP_FILIAL QUP_PROJET
			aAdd( aAliasUpd, {"AFK", 2, {{"AFK_FILIAL",FwxFilial("AFK")}, {"AFK_PROJET",cPrjAtual}}, {{"AFK_PROJET",cPrjNovo}}})// Planejamentos do Projeto - AFK_FILIAL+AFK_PROJET+AFK_PLANEJ
			aAdd( aAliasUpd, {"FNB", 0, {{"FNB_FILIAL",FwxFilial("FNB")}, {"FNB_CODPMS",cPrjAtual}},{{"FNB_CODPMS",cPrjNovo}}}) // Projetos de imobilizado     - FNB_FILIAL FNB_CODPMS
			aAdd( aAliasUpd, {"FNC", 0, {{"FNC_FILIAL",FwxFilial("FNC")}, {"FNC_CODPMS",cPrjAtual}},{{"FNC_CODPMS",cPrjNovo}}}) // Etapas do projeto           - FNC_FILIAL FNC_CODPMS
			aAdd( aAliasUpd, {"FND", 0, {{"FND_FILIAL",FwxFilial("FND")}, {"FND_CODPMS",cPrjAtual}},{{"FND_CODPMS",cPrjNovo}}}) // Itens das etapas do projeto - FND_FILIAL FND_CODPMS
	       aAdd( aAliasUpd, {"AFB", 1, {{"AFB_FILIAL",FwxFilial("AFB")}, {"AFB_PROJET",cPrjAtual}},{{"AFB_PROJET",cPrjNovo}}}) // Despesas
			aAdd( aAliasUpd, {"AFA", 1, {{"AFA_FILIAL",FwxFilial("AFA")}, {"AFA_PROJET",cPrjAtual}},{{"AFA_PROJET",cPrjNovo}}}) // Recursos do Projeto
			aAdd( aAliasUpd, {"AJB", 1, {{"AJB_FILIAL",FwxFilial("AJB")}, {"AJB_PROJET",cPrjAtual}},{{"AJB_PROJET",cPrjNovo}}}) // SimulaÁıes de Projeto          - AJB_FILIAL+AJB_PROJET+AJB_REVISA
			aAdd( aAliasUpd, {"AJD", 1, {{"AJD_FILIAL",FwxFilial("AJD")}, {"AJD_PROJET",cPrjAtual}},{{"AJD_PROJET",cPrjNovo}}}) // AmarraÁ„o Doc x Projetos       - AJD_FILIAL+AJD_PROJET+AJD_REVISA+AJD_EDT+AJD_FILDOC+AJD_DOCTO
			aAdd( aAliasUpd, {"AJH", 1, {{"AJH_FILIAL",FwxFilial("AJH")}, {"AJH_PROJET",cPrjAtual}},{{"AJH_PROJET",cPrjNovo}}}) // An·lise de ExecuÁ„o            - AJH_FILIAL+AJH_PROJET+AJH_TAREFA+AJH_REVISA+DTOS(AJH_DATA)
			aAdd( aAliasUpd, {"AJO", 1, {{"AJO_FILIAL",FwxFilial("AJO")}, {"AJO_PROJET",cPrjAtual}},{{"AJO_PROJET",cPrjNovo}}}) // Tarefa X Itens Check List      - AJO_FILIAL+AJO_PROJET+AJO_REVISA+AJO_TAREFA+AJO_ITEM+AJO_ORDEM
			aAdd( aAliasUpd, {"AJT", 2, {{"AJT_FILIAL",FwxFilial("AJT")}, {"AJT_PROJET",cPrjAtual}},{{"AJT_PROJET",cPrjNovo}}}) // Composicoes Unicas             - AJT_FILIAL+AJT_PROJET+AJT_REVISA+AJT_COMPUN
			aAdd( aAliasUpd, {"AJU", 2, {{"AJU_FILIAL",FwxFilial("AJU")}, {"AJU_PROJET",cPrjAtual}},{{"AJU_PROJET",cPrjNovo}}}) // Recursos da Composicao Unica   - AJU_FILIAL+AJU_PROJET+AJU_REVISA+AJU_COMPUN+AJU_ITEM
			aAdd( aAliasUpd, {"AJV", 2, {{"AJV_FILIAL",FwxFilial("AJV")}, {"AJV_PROJET",cPrjAtual}},{{"AJV_PROJET",cPrjNovo}}}) // Despesas da Composicao Unica   - AJV_FILIAL+AJV_PROJET+AJV_REVISA+AJV_COMPUN+AJV_ITEM
			aAdd( aAliasUpd, {"AJX", 2, {{"AJX_FILIAL",FwxFilial("AJX")}, {"AJX_PROJET",cPrjAtual}},{{"AJX_PROJET",cPrjNovo}}}) // Sub-Composicoes da Comp Unica  - AJX_FILIAL+AJX_PROJET+AJX_REVISA+AJX_COMPUN+AJX_ITEM
			aAdd( aAliasUpd, {"AJY", 2, {{"AJY_FILIAL",FwxFilial("AJY")}, {"AJY_PROJET",cPrjAtual}},{{"AJY_PROJET",cPrjNovo}}}) // Insumos do Projeto             - AJY_FILIAL+AJY_PROJET+AJY_COD
			aAdd( aAliasUpd, {"AN6", 1, {{"AN6_FILIAL",FwxFilial("AN6")}, {"AN6_PROJET",cPrjAtual}},{{"AN6_PROJET",cPrjNovo}}}) // NotificaÁ„o Eventos de Projeto - AN6_FILIAL+AN6_PROJET+AN6_EVENT
			aAdd( aAliasUpd, {"AN8", 1, {{"AN8_FILIAL",FwxFilial("AN8")}, {"AN8_PROJET",cPrjAtual}},{{"AN8_PROJET",cPrjNovo}}}) // Historico de Rejeicoes         - AN8_FILIAL+AN8_PROJET+AN8_REVISA+AN8_TAREFA+DTOS(AN8_DATA)+AN8_HORA+AN8_TRFORI
			aAdd( aAliasUpd, {"AN9", 1, {{"AN9_FILIAL",FwxFilial("AN9")}, {"AN9_PROJET",cPrjAtual}},{{"AN9_PROJET",cPrjNovo}}}) // Tributos da Tarefa             - AN9_FILIAL+AN9_PROJET+AN9_REVISA+AN9_TAREFA+AN9_ITEM+AN9_PRODUT+AN9_RECURS+AN9_CODIMP
			aAdd( aAliasUpd, {"ANC", 1, {{"ANC_FILIAL",FwxFilial("ANC")}, {"ANC_PROJET",cPrjAtual}},{{"ANC_PROJET",cPrjNovo}}}) // Motivos Rejeicoes de Planos    - ANC_FILIAL+ANC_PROJET+ANC_REVISA+ANC_TAREFA+DTOS(ANC_DATA)+ANC_HORA
			aAdd( aAliasUpd, {"AEB", 1, {{"AEB_FILIAL",FwxFilial("AEB")}, {"AEB_PROJET",cPrjAtual}},{{"AEB_PROJET",cPrjNovo}}}) // Cotacao - Periodos             - AEB_FILIAL+AEB_PROJET+AEB_REVISA
			aAdd( aAliasUpd, {"AFJ", 1, {{"AFJ_FILIAL",FwxFilial("AFJ")}, {"AFJ_PROJET",cPrjAtual}},{{"AFJ_PROJET",cPrjNovo}}}) // Empenhos do Projeto            - AFJ_FILIAL+AFJ_PROJET+AFJ_TAREFA+AFJ_COD+AFJ_LOCAL
			aAdd( aAliasUpd, {"AFG", 1, {{"AFG_FILIAL",FwxFilial("AFG")}, {"AFG_PROJET",cPrjAtual}},{{"AFG_PROJET",cPrjNovo}}}) // Projeto x SolicitaÁ„o Compras  - AFG_FILIAL+AFG_PROJET+AFG_REVISA+AFG_TAREFA+AFG_NUMSC+AFG_ITEMSC
			aAdd( aAliasUpd, {"AFH", 1, {{"AFH_FILIAL",FwxFilial("AFH")}, {"AFH_PROJET",cPrjAtual}},{{"AFH_PROJET",cPrjNovo}}}) // Projeto x SolicitaÁ„o ArmazÈm  - AFH_FILIAL+AFH_PROJET+AFH_REVISA+AFH_TAREFA+AFH_NUMSA+AFH_ITEMSA
			aAdd( aAliasUpd, {"AFI", 1, {{"AFI_FILIAL",FwxFilial("AFI")}, {"AFI_PROJET",cPrjAtual}},{{"AFI_PROJET",cPrjNovo}}}) // Projeto x Movimentos Internos  - AFI_FILIAL+AFI_PROJET+AFI_REVISA+AFI_TAREFA+AFI_COD+AFI_LOCAL+DTOS(AFI_EMISSA)+AFI_NUMSEQ
			aAdd( aAliasUpd, {"AFL", 1, {{"AFL_FILIAL",FwxFilial("AFL")}, {"AFL_PROJET",cPrjAtual}},{{"AFL_PROJET",cPrjNovo}}}) // Projeto x Contrato de Parceria - AFL_FILIAL+AFL_PROJET+AFL_REVISA+AFL_TAREFA+AFL_NUMCP+AFL_ITEMCP
			aAdd( aAliasUpd, {"AFM", 1, {{"AFM_FILIAL",FwxFilial("AFM")}, {"AFM_PROJET",cPrjAtual}},{{"AFM_PROJET",cPrjNovo}}}) // Projeto x Ordens de ProduÁ„o   - AFM_FILIAL+AFM_PROJET+AFM_REVISA+AFM_TAREFA+AFM_NUMOP+AFM_ITEMOP+AFM_SEQOP
			aAdd( aAliasUpd, {"AFN", 1, {{"AFN_FILIAL",FwxFilial("AFN")}, {"AFN_PROJET",cPrjAtual}},{{"AFN_PROJET",cPrjNovo}}}) // Projeto x NF Entrada           - AFN_FILIAL+AFN_PROJET+AFN_REVISA+AFN_TAREFA+AFN_DOC+AFN_SERIE+AFN_FORNEC+AFN_LOJA+AFN_ITEM
			aAdd( aAliasUpd, {"AFO", 1, {{"AFO_FILIAL",FwxFilial("AFO")}, {"AFO_PROJET",cPrjAtual}},{{"AFO_PROJET",cPrjNovo}}}) // Projeto x LiberaÁıes CQ        - AFO_FILIAL+AFO_PROJET+AFO_REVISA+AFO_TAREFA+AFO_NUMERO+AFO_SEQ
			aAdd( aAliasUpd, {"AFR", 1, {{"AFR_FILIAL",FwxFilial("AFR")}, {"AFR_PROJET",cPrjAtual}},{{"AFR_PROJET",cPrjNovo}}}) // Projeto x Despesas Financeiras - AFR_FILIAL+AFR_PROJET+AFR_REVISA+AFR_TAREFA+AFR_PREFIX+AFR_NUM+AFR_PARCEL+AFR_TIPO+AFR_FORNEC+AFR_LOJA
			aAdd( aAliasUpd, {"AFS", 1, {{"AFS_FILIAL",FwxFilial("AFS")}, {"AFS_PROJET",cPrjAtual}},{{"AFS_PROJET",cPrjNovo}}}) // Projeto x NF SaÌda             - AFS_FILIAL+AFS_PROJET+AFS_REVISA+AFS_TAREFA+AFS_COD+AFS_LOCAL+DTOS(AFS_EMISSA)+AFS_NUMSEQ
			aAdd( aAliasUpd, {"AFT", 1, {{"AFT_FILIAL",FwxFilial("AFT")}, {"AFT_PROJET",cPrjAtual}},{{"AFT_PROJET",cPrjNovo}}}) // Projeto x Receitas Financeiras - AFT_FILIAL+AFT_PROJET+AFT_REVISA+AFT_TAREFA+AFT_PREFIX+AFT_NUM+AFT_PARCEL+AFT_TIPO+AFT_CLIENT+AFT_LOJA
			aAdd( aAliasUpd, {"AJ7", 1, {{"AJ7_FILIAL",FwxFilial("AJ7")}, {"AJ7_PROJET",cPrjAtual}},{{"AJ7_PROJET",cPrjNovo}}}) // Projeto x Pedido de Compra     - AJ7_FILIAL+AJ7_PROJET+AJ7_REVISA+AJ7_TAREFA+AJ7_NUMPC+AJ7_ITEMPC
			aAdd( aAliasUpd, {"AJ9", 1, {{"AJ9_FILIAL",FwxFilial("AJ9")}, {"AJ9_PROJET",cPrjAtual}},{{"AJ9_PROJET",cPrjNovo}}}) // ConfirmaÁıes x Aut Entrega     - AJ9_FILIAL+AJ9_PROJET+AJ9_REVISA+AJ9_TAREFA+DTOS(AJ9_DATA)+AJ9_NUMAE+AJ9_ITEMAE
			aAdd( aAliasUpd, {"AJA", 1, {{"AJA_FILIAL",FwxFilial("AJA")}, {"AJA_PROJET",cPrjAtual}},{{"AJA_PROJET",cPrjNovo}}}) // ConfirmaÁıes x Lib Ped Vendas  - AJA_FILIAL+AJA_PROJET+AJA_REVISA+AJA_EDT+AJA_TAREFA+AJA_ITEM+AJA_NUMPV+AJA_ITEMPV+AJA_SEQUEN+AJA_PRODUT
			aAdd( aAliasUpd, {"AJE", 1, {{"AJE_FILIAL",FwxFilial("AJE")}, {"AJE_PROJET",cPrjAtual}},{{"AJE_PROJET",cPrjNovo}}}) // Projetos x Mov Banc·ria        - AJE_FILIAL+AJE_PROJET+AJE_REVISA+AJE_TAREFA+DTOS(AJE_DATA)
			aAdd( aAliasUpd, {"SC6", 8, {{"C6_FILIAL" ,FwxFilial("SC6")}, {"C6_PROJPMS",cPrjAtual}},{{"C6_PROJPMS",cPrjNovo}}}) // Itens dos Pedidos de Venda     - C6_FILIAL+C6_PROJPMS+C6_TASKPMS+C6_EDTPMS
			aAdd( aAliasUpd, {"SD3", 10,{{"D3_FILIAL" ,FwxFilial("SD3")}, {"D3_PROJPMS",cPrjAtual}},{{"D3_PROJPMS",cPrjNovo}}}) // MovimentaÁıes Internas        - D3_FILIAL+D3_PROJPMS+D3_TASKPMS+D3_COD+D3_LOCAL
			aAdd( aAliasUpd, {"SE5", 9, {{"E5_FILIAL" ,FwxFilial("SE5")}, {"E5_PROJPMS",cPrjAtual}},{{"E5_PROJPMS",cPrjNovo}}}) // MovimentaÁ„o Bancaria          - E5_FILIAL+E5_PROJPMS+E5_EDTPMS+E5_TASKPMS+DTOS(E5_DATA)+E5_BANCO+E5_AGENCIA+E5_CONTA
			aAdd( aAliasUpd, {"AFW", 1, {{"AFW_FILIAL" ,FwxFilial("AFW")}, {"AFW_PROJET",cPrjAtual}},{{"AFW_PROJET",cPrjNovo}}})// Controle de Execucao
			aAdd( aAliasUpd, {"AN2", 1, {{"AN2_FILIAL" ,FwxFilial("AN2")}, {"AN2_PROJET",cPrjAtual}},{{"AN2_PROJET",cPrjNovo}}}) //Apontamentos Improdutivos
			aAdd( aAliasUpd, {"AEC", 1, {{"AEC_FILIAL" ,FwxFilial("AEC")}, {"AEC_PROJET",cPrjAtual}},{{"AEC_PROJET",cPrjNovo}}}) //Cotacao - Produtos
			aAdd( aAliasUpd, {"AEE", 1, {{"AEE_FILIAL" ,FwxFilial("AEE")}, {"AEE_PROJET",cPrjAtual}},{{"AEE_PROJET",cPrjNovo}}}) //Cotacao - Reajuste
			aAdd( aAliasUpd, {"AEF", 1, {{"AEF_FILIAL" ,FwxFilial("AEF")}, {"AEF_PROJET",cPrjAtual}},{{"AEF_PROJET",cPrjNovo}}}) //Cronog. Prev. Consumo Produto
			aAdd( aAliasUpd, {"ANE", 1, {{"ANE_FILIAL" ,FwxFilial("ANE")}, {"ANE_PROJET",cPrjAtual}},{{"ANE_PROJET",cPrjNovo}}}) //amarracao projeto x contratos
			// deve alterar os registros com o codigo do projeto Atual para o novo codigo do projeto.
			If !isBlind()
				MsgRun(STR0297,STR0293,{||auxUpdReg(aAliasUpd)})
			Else
				auxUpdReg(aAliasUpd)
			Endif
			//
			// deve atualizar os registros da tabela AC9 para o novo codigo do projeto
			If !IsBlind()
				MsgRun(STR0306,STR0293,{||auxUpdAC9(cPrjAtual, cPrjNovo)})
			Else
				auxUpdAC9(cPrjAtual, cPrjNovo)
			Endif

			//
			// deve excluir  os registros que tem o codigo do projeto Atual
			If !IsBlind()
				MsgRun(STR0298,STR0293,{||auxDelReg( aAliasCpy)})
			Else
				auxDelReg( aAliasCpy)
			Endif
		EndIf
	EndIf

	restArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} NoExistPjr()

Verifica se o conteudo n„o existe na tabela

@author Reynaldo Tetsu Miyashita
@since 17/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function NoExistPrj(cProjet)
Local lRet := .T.

DEFAULT cProjet := ""

	If !Empty(cProjet)
		dbSelectArea("AF8")
		dbSetOrder(1)
		If dbSeek(FwxFilial("AF8")+cProjet)
			Help(" ",1,STR0300,,STR0301)
			lRet := .F.
		EndIf
	Else
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AuxCpyReg
Copia os registros do projeto atual alterado para o novo codigo do projeto
atravÈs de busca por filial+codigo do projeto

aAliasCpy[n][1] -> Alias da tabela
aAliasCpy[n][2] -> Indice da tabela
aAliasCpy[n][3][n]-> Campos Chaves para busca
aAliasCpy[n][3][n][1] -> Nome do campo
aAliasCpy[n][3][n][2] -> Conteudo a ser procurado
aAliasCpy[n][3][n]-> Campos com os conteudos a serem alterados
aAliasCpy[n][4][n][1] -> Nome do campo
aAliasCpy[n][4][n][2] -> Conteudo informado
aAliasCpy[n][5][n]    -> Bloco para ajustar algum campo do Registro

@author Reynaldo Tetsu Miyashita
@since 17/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AuxCpyReg(aAliasCpy)
Local aAreaTmp  := {} // Salva temporariamente as tabelas movimentadas
Local nCntAlias := 0
Local cAlias := ""
Local cTmpAlias := ""
Local cSQL   := ""
Local nCntField := 0

Default aAliasCpy := {}

	If !Empty(aAliasCpy)

		Begin Transaction
		For nCntAlias := 1 To len(aAliasCpy)

			cAlias := aAliasCpy[nCntAlias,1]
			if Len(aAliasCpy[nCntAlias]) < 5
				Aadd(aAliasCpy[nCntAlias], NIL)
			endif
			// Verifica se a tabela existe no dicionario de dados
			dbSelectArea(cAlias)
			aAreaTMP := GetArea()
			cSQL := "SELECT R_E_C_N_O_ RECNO "
			cSQL += "FROM " + RetSqlName(aAliasCpy[nCntAlias,1]) + " "
			cSQL += "WHERE "
			For nCntField := 1 to Len(aAliasCpy[nCntAlias,3])
				cSQL +=  aAliasCpy[nCntAlias,3,nCntField,1]
				If Len(aAliasCpy[nCntAlias,3]) > 2 .AND. Len(aAliasCpy[nCntAlias,3,nCntField]) > 2 .AND. aAliasCpy[nCntAlias,3,nCntField,3] <> ''
			      cSQL += aAliasCpy[nCntAlias,3,nCntField,3] + "'"
				Else
				  cSQL +=  " = "+ "'"
				EndIf
				cSQL +=  aAliasCpy[nCntAlias,3,nCntField,2] + "' AND "
			Next nCntField
			cSQL += "D_E_L_E_T_ = ' '"
			cSQL := ChangeQuery(cSQL)

			cTmpAlias := GetNextAlias()
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cTmpAlias,.F.,.T.)
			dbSelectArea(cTmpAlias)
			While !Eof()
				// duplica o registro do projeto atual, substituindo pelo novo codigo de projeto
				PmsCopyReg(cAlias ,(cTmpAlias)->RECNO ,aAliasCpy[nCntAlias,4],,aAliasCpy[nCntAlias,5])
				dbSelectArea(cTmpAlias)
				dbSkip()
			End
			dbclosearea()

			RestArea(aAreaTmp)
		Next nCnt
		End Transaction
	EndIf

return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} AuxUpdReg
Atualiza os registros atravÈs de busca por filial+codigo do projeto

aAliasUpd[N][1] -> Alias da tabela
aAliasUpd[N][2] -> Indice da tabela
aAliasUpd[N][3][n]-> Campos Chaves para busca
aAliasUpd[N][3][n][1] -> Nome do campo
aAliasUpd[N][3][n][2] -> Conteudo a ser procurado
aAliasUpd[N][3][n]-> Campos com os conteudos a serem alterados
aAliasUpd[N][4][n][1] -> Nome do campo
aAliasUpd[N][4][n][2] -> Conteudo informado

@author Reynaldo Tetsu Miyashita
@since 17/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AuxUpdReg(aAliasUpd)
Local nCntAlias := 0
Local cAlias := ""
Local cSQL   := ""
Local nCntField := 0

Default aAliasUpd := {}

	If !Empty(aAliasUpd)

		Begin Transaction
		For nCntAlias := 1 To len(aAliasUpd)

			cAlias := aAliasUpd[nCntAlias,1]

			// Verifica se a tabela existe no dicionario de dados
			dbselectarea(cAlias)
			cSQL := "UPDATE " + RetSqlName(cAlias) + " "
			cSQL += "SET "
			For nCntField := 1 to Len(aAliasUpd[nCntAlias,4])
				cSQL += aAliasUpd[nCntAlias,4,nCntField,1] + " = '" + aAliasUpd[nCntAlias,4,nCntField,2] + "' "
			Next nCntField
			cSQL += "WHERE "
			For nCntField := 1 to Len(aAliasUpd[nCntAlias,3])
				cSQL +=  aAliasUpd[nCntAlias,3,nCntField,1] + " = '" + aAliasUpd[nCntAlias,3,nCntField,2] + "' AND "
			Next nCntField
			cSQL += "D_E_L_E_T_ = ' '"

			TcSqlExec(cSQL)

		Next nCnt
		End Transaction
	EndIf

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} AuxDelReg
Exclui os registros atravÈs da  busca por filial+codigo do projeto

aAliasCpy[n][1] -> Alias da tabela
aAliasCpy[n][2] -> Indice da tabela
aAliasCpy[n][3][n]-> Campos Chaves para busca
aAliasCpy[n][3][n][1] -> Nome do campo
aAliasCpy[n][3][n][2] -> Conteudo a ser procurado

@author Reynaldo Tetsu Miyashita
@since 17/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AuxDelReg(aAliasCpy)
Local nCntAlias := 0
Local cAlias    := ""
Local cTmpAlias := ""
Local nCntField := 0
Local cSQL      := ""

Default aAliasCpy := {}

	//
	// exclui os registros contidos no array aAliasCpy
	If !Empty(aAliasCpy)
		Begin Transaction
		For nCntAlias := 1 To len(aAliasCpy)

			cAlias := aAliasCpy[nCntAlias,1]

			// Verifica se a tabela existe no dicionario de dados
			dbSelectArea(cAlias)

			cSQL := "SELECT R_E_C_N_O_ RECNO "
			cSQL += "FROM " + RetSqlName(aAliasCpy[nCntAlias,1]) + " "
			cSQL += "WHERE "
			For nCntField := 1 to Len(aAliasCpy[nCntAlias,3])
				cSQL +=  aAliasCpy[nCntAlias,3,nCntField,1]
				//Verificacao para casos que tenham o simbolo <>
				If Len(aAliasCpy[nCntAlias,3]) > 2 .AND. Len(aAliasCpy[nCntAlias,3,nCntField]) > 2 .AND. aAliasCpy[nCntAlias,3,nCntField,3] <> ''
			      cSQL += aAliasCpy[nCntAlias,3,nCntField,3] + "'"
				Else
				  cSQL +=  " = '"
				EndIf
				cSQL += aAliasCpy[nCntAlias,3,nCntField,2] + "' AND "
			Next nCntField
			cSQL += "D_E_L_E_T_ = ' '"
			cSQL := ChangeQuery(cSQL)

			cTmpAlias := GetNextAlias()
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cTmpAlias,.F.,.T.)
			dbSelectArea(cTmpAlias)
			While !Eof()
				dbSelectArea(cAlias)
				dbGoto((cTmpAlias)->RECNO)
				Reclock(cAlias,.F.)
					dbDelete()
				MsUnlock()

				dbSelectArea(cTmpAlias)
				dbSkip()
			End
			dbclosearea()
		Next nCnt
		End Transaction
	EndIf

Return .T.

/*
FUN«√O	| PMSRETCODE
DATA     | 28.06.2013
AUTOR    | PEDRO PEREIRA LIMA
*/
Function PmsRetCode(cNewCode,cOldCode,cProject,cRev,cAlias,cNivel)
Local oDlg
Local oNewCode
Local lOk		:= .T.
Local cGetPict	:= ""

Default cNewCode	:= ""
Default cOldCode	:= ""
Default cProject	:= ""
Default cRev		:= ""
Default cAlias		:= ""

If (!Empty(cOldCode) .And. !Empty(cProject) .And. !Empty(cRev) .And. !Empty(cAlias)) .And.;
	MsgYesNo("Deseja informar o cÛdigo da EDT/Tarefa?","RecodificaÁ„o")
	While .T.
		Define MsDialog oDlg Title STR0211 From 0, 0 To 125, 300 Of oMainWnd Pixel //"Recodificar Tarefa/EDT"

		// codigo atual
		@ 010, 005 Say STR0210 Of oDlg Pixel //"Codigo atual:"
		@ 009, 045 MSGet cOldCode Of oDlg Size 100, 08 Pixel ReadOnly

		// novo codigo
		@ 022, 005 Say STR0185 Of oDlg Pixel //"Novo codigo:"

		If cAlias == "AF9"
			@ 021, 045 MSGet oNewCode Var cNewCode Valid !ExistPrjTrf(cProject, cRev, cNewCode) Of oDlg Picture cGetPict Size 100, 08 Pixel
		Else
			@ 021, 045 MSGet oNewCode Var cNewCode Valid !ExistPrjEDT(cProject, cRev, cNewCode) Of oDlg Picture cGetPict Size 100, 08 Pixel
		EndIf

		// OK
		@ 038, 065 Button "OK" Size 35 ,11 FONT oDlg:oFont Action (lOk := .T., oDlg:End()) Of oDlg Pixel //Ok

		// Cancelar
		@ 038, 110 Button STR0078 Size 35 ,11 FONT oDlg:oFont Action (lOk := .F., oDlg:End()) Of oDlg Pixel //"Cancela"
		Activate MsDialog oDlg On Init oNewCode:SetFocus() Centered

		If !lOk
			Exit
		EndIf

		If (!Empty(cNewCode) .And. PmsValMask(cNewCode,cProject,cNivel))
			Exit
		EndIf
	EndDo
Else
	lOk := .F.
EndIf

Return lOk

/*
FUN«√O	| PMSVALMASK
DATA     | 28.06.2013
AUTOR    | PEDRO PEREIRA LIMA
*/
Static Function PmsValMask(cCodigo,cProject,cNivelTrf)
Local cDelim		:= ""
Local cMascara		:= ""
Local cOldCode		:= cCodigo
Local nIni			:= 0
Local nFim			:= 0
Local nDigitos		:= 0
Local nX				:= 0
Local nLoop			:= 0
Local lRet			:= .T.
Local lEdtPai		:= .F.

If cNivelTrf == "000" .Or. cNivelTrf == "001"
	cNivelTrf := "002"
	lEdtPai := .T.
EndIf

AF8->(dbSetOrder(1))
AF8->(MsSeek(xFilial()+cProject))

cDelim    := AllTrim(AllTrim(AF8->AF8_DELIM))
cMascara  := AllTrim(AF8->AF8_MASCAR)

If Empty(cMascara)
	cMascara := "111111111111111111"
EndIf

nDigitos	:= Val(SubStr(cMascara,Val(cNivelTrf)-1,1))

If lEdtPai
	If Len(AllTrim(cOldCode)) < nDigitos
		MsgAlert("CÛdigo inv·lido! Digite um cÛdigo v·lido para a EDT/Tarefa.")
		Return .F.
	EndIf
EndIf


If Val(cNivelTrf) == 2 .And. At(cDelim,cCodigo) == 0
	nIni := 0
Else
	cMaskAux := SubStr(cMascara,1,Val(cNivelTrf)-2)
	nIni := 0
	nLoop := Len(cMaskAux)
	For nX := 1 To nLoop
		nIni += Val(SubStr(cMaskAux,1,1))
		If Len(cMaskAux) > 1
			cMaskAux := SubStr(cMaskAux,2,Len(cMaskAux))
		EndIf
	Next nX
	nIni += nLoop
EndIf

cCodigo := SubStr(cCodigo,nIni+1,Len(cCodigo))

If Len(AllTrim(cOldCode)) <= nIni+1
	MsgAlert("CÛdigo inv·lido! Digite um cÛdigo v·lido para a EDT/Tarefa.")
	Return .F.
EndIf

If  At(cDelim,cCodigo) == 0
	nFim := Len(cCodigo)
Else
	nFim := At(cDelim,cCodigo)-1
EndIf

cCodigo := SubStr(cCodigo,1,nFim)

If Len(AllTrim(cCodigo)) != nDigitos
	MsgAlert("Informar um cÛdigo compatÌvel com a m·scara do projeto!"+CRLF+;
				"M·scara: "+ cMascara + CRLF +;
				"CÛdigo digitado: " + AllTrim(cOldCode))
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AuxUpdAC9
Atualiza os registros da tabela AC9 com o novo codigo do projeto.

Por causa do conteudo do campo AC9_CODENT ser È armazenado de forma concatenada.
Foi necessario desenvolver esta rotina em especifico, n„o sendo possivel o uso
da funÁ„o AuxUpdReg.

@param cPrjAtual - Codigo do projeto Atual
@param cPrjNovo - Novo Codigo do projeto

@author Reynaldo Tetsu Miyashita
@since 03/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AuxUpdAC9(cPrjAtual, cPrjNovo)
Local cQuery    := ""
Local cTmpAlias := ""
Local cCharConcat := ""

	// Define o simbolo de concatenacao de acordo com o banco de dados
	If Upper( TcGetDb() ) $ "ORACLE*POSTGRES*DB2*INFORMIX"
		cCharConcat := "||"
	Else
		cCharConcat	:= "+"
	EndIf

	// garante o tamanho correto da variavel que deve ser o tamanho do campo AF8_PROJET
	cPrjAtual := padr(cPrjAtual, TamSx3("AF8_PROJET")[1])
	cPrjNovo  := padr(cPrjNovo, TamSx3("AF8_PROJET")[1])

	//
	// montar um query q junta a AF9 e AC9 e o retorno s„o os recnos da tabela AC9\s
	//
	cQuery := "SELECT AF9_TAREFA, AC9.R_E_C_N_O_ AC9_RECNO "
	cQuery += "FROM "+RetSqlName( "AC9" )+" AC9 "
	cQuery += "INNER JOIN "+RetSqlName( "AF9" )+" AF9 "
	cQuery +=     "ON '"+cPrjAtual+"'"+cCharConcat+"AF9_TAREFA=AC9_CODENT "
	cQuery += "WHERE AC9_FILIAL = '"+FwxFilial("AC9")+"' "
	cQuery +=     "AND AC9.AC9_FILENT = '"+FwxFilial("AF9")+"' "
	cQuery +=     "AND AC9.D_E_L_E_T_= ' ' "
	cQuery +=     "AND AF9_FILIAL = '"+FwxFilial("AF9")+"' "
	cQuery +=     "AND AF9_PROJET = '"+cPrjNovo+"' "
	cQuery +=     "AND AF9.D_E_L_E_T_= ' ' "
	cQuery := ChangeQuery(cQuery)

	cTmpAlias := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpAlias,.T.,.T.)
	dbSelectArea("AC9")
	While (cTmpAlias)->(!Eof())
		msGoto((cTmpAlias)->AC9_RECNO)
		RecLock("AC9",.F.)
			AC9->AC9_CODENT := cPrjNovo + (cTmpAlias)->AF9_TAREFA
		MsUnlock()
		(cTmpAlias)->(dbSkip())
	End
	(cTmpAlias)->(dbCloseArea())

	//
	// montar um query q junta a AFC e AC9 e o retorno s„o os recnos da tabela AC9\s
	//
	cQuery := "SELECT AFC_EDT, AC9.R_E_C_N_O_ AC9_RECNO "
	cQuery += "FROM "+RetSqlName( "AC9" )+" AC9 "
	cQuery += "INNER JOIN "+RetSqlName( "AFC" )+" AFC "
	cQuery +=     "ON '"+cPrjAtual+"'"+cCharConcat+"AFC_EDT=AC9_CODENT "
	cQuery += "WHERE AC9_FILIAL = '"+FwxFilial("AC9")+"' "
	cQuery +=     "AND AC9.AC9_FILENT = '"+FwxFilial("AFC")+"' "
	cQuery +=     "AND AC9.D_E_L_E_T_= ' ' "
	cQuery +=     "AND AFC_FILIAL = '"+FwxFilial("AFC")+"' "
	cQuery +=     "AND AFC_PROJET = '"+cPrjNovo+"' "
	cQuery +=     "AND AFC.D_E_L_E_T_= ' ' "
	cQuery := ChangeQuery(cQuery)

	cTmpAlias := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpAlias,.T.,.T.)
	dbSelectArea("AC9")
	While (cTmpAlias)->(!Eof())
		msGoto((cTmpAlias)->AC9_RECNO)
		RecLock("AC9",.F.)
			AC9->AC9_CODENT := cPrjNovo + (cTmpAlias)->AFC_EDT
		MsUnlock()
		(cTmpAlias)->(dbSkip())
	End
	(cTmpAlias)->(dbCloseArea())

Return .T.

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta funÁ„o deve utilizada somente apÛs 
    a inicializaÁ„o das variaveis atravez da funÁ„o FATPDLoad.
	Remover essa funÁ„o quando n„o houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, LÛgico, Retorna se o campo ser· ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate


//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa funÁ„o quando n„o houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   



//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informaÁıes enviadas, 
    quando a regra de auditoria de rotinas com campos sensÌveis ou pessoais estiver habilitada
	Remover essa funÁ„o quando n„o houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que ser· utilizada no log das tabelas
    @param nOpc, Numerico, OpÁ„o atribuÌda a funÁ„o em execuÁ„o - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria n„o esteja aplicada, tambÈm retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    FunÁ„o que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  

