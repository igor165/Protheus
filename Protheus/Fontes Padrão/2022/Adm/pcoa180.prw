#INCLUDE "pcoa180.ch"
#INCLUDE "PROTHEUS.CH"
#include "pcoicons.ch"
#Define TP_PERIODO 1
#Define INI_PERIODO 2
#Define FIM_PERIODO 3
#Define ARRAY_HEADERCFG 4
#Define ARRAY_ACOLSAKP 5
#Define ARRAY_ACONFIG 6

Static _oPCOA1801
Static _oPCOA1802

/*/
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ PCOA180  ³ AUTOR ³ Paulo Carnelossi      ³ DATA ³ 16/11/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Programa de Execucao da consulta gerencial do PCO            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ SIGAPCO                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PCOA180                                                      ³±±
±±³_DESCRI_  ³ Programa de manutecao da consulta gerencial                  ³±±
±±³_FUNC_    ³ Esta funcao podera ser utilizada com a sua chamada normal a  ³±±
±±³          ³ partir do Menu ou a partir de uma funcao pulando assim o     ³±±
±±³          ³ browse principal e executando a chamada direta da rotina     ³±±
±±³          ³ selecionada.                                                 ³±±
±±³          ³ Exemplo : PCOA180(2) - Executa a chamada da funcao de visua- ³±±
±±³          ³                        zacao da rotina.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_PARAMETR_³ ExpN1 : Chamada direta sem passar pela mBrowse               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOA180(nCallOpcx)

PRIVATE cCadastro	:= STR0001 //"Visao Gerencial Orcamentaria"
Private aRotina := MenuDef()

Private nRecAKN

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	If nCallOpcx <> Nil
		PCO180EXE("AKN",AKN->(RecNo()),nCallOpcx,,,)
	Else
		mBrowse(6,1,22,75,"AKN")
	EndIf
EndIf

Return 

Function PCO180DLG
Local lContinua := .F.
Local nDirAcesso 	:= 0

If SuperGetMV("MV_PCO_AKN",.F.,"2")!="1"  //1-Verifica acesso por entidade
	lContinua := .T.                        // 2-Nao verifica o acesso por entidade
Else
	nDirAcesso := PcoDirEnt_User("AKN", AKN->AKN_CODIGO, __cUserID, .F.)
    If nDirAcesso == 0 //0=bloqueado
		Aviso(STR0022,STR0024,{STR0025},2)//"Atenção"###"Usuario sem acesso a esta configuração de visao gerencial. "###"Fechar"
		lContinua := .F.
	Else
	    lContinua := .T.
	EndIf
EndIf

If lContinua
	PCOA170(2)
EndIf

DelPCOA180()

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCO180EXE³ Autor ³ Paulo Carnelossi       ³ Data ³ 22/11/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de execucao da consulta planilha de visao gerencial.³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCO180EXE(cAlias,nReg,nOpcx, cR1, cR2, aPeriodo, lPrintRel, bPrintRel)

Local nX
Local aParam := {}
Local aStruAK1, cArqCab
Local aStruAK2, cArqIte, cArqIt2
Local cPicture, nTamanho, nDecimal, cTipo
Local aTiposCp := {"C","N","L","D"}
Local oDlg
Local lContinua := .T.

Local cArquivo		:= GetNextAlias()
Local cFiltro 		:= ".T."

Local lOk
Local aMenu			:= {}
Local lVisual       := .T.
Local l180Visual    := .F.
Local nPosCO
Local nDirAcesso 	:= 0

Local bFechaTMPAK1 := {||dbSelectArea("TMPAK1"),;
						dbCloseArea(), ;
						FErase(AllTrim(cArqCab)+GetDBExtension()), ;
						FErase(AllTrim(cArqCab)+".FPT"), ;
						FErase(AllTrim(cArqCab)+OrdBagExt()) }

Local bFechaAK2TMP := {||dbSelectArea("TMPAK2"), ;
						dbCloseArea(), ; 
						FErase(AllTrim(cArqIte)+GetDBExtension()), ;
						FErase(AllTrim(cArqIte)+OrdBagExt()), ;	
						FErase(AllTrim(cArqIt2)+OrdBagExt())}
						
Local aChave1	:= {}
Local aChave2	:= {}

Private cTpPeriodo, dIniPer, dFimPer, aConfig := {}
Private aHeaderCfg := {}
Private aDadosAK2 := {}
Private oMenu, oMenu1
Private M->AKR_ORCAME := Padr(" ", Len(AKR->AKR_ORCAME))

DEFAULT lPrintRel := .F.
DEFAULT bPrintRel := {||.T.}

If SuperGetMV("MV_PCO_AKN",.F.,"2")!="1"  //1-Verifica acesso por entidade
	lContinua := .T.                        // 2-Nao verifica o acesso por entidade
Else
	nDirAcesso := PcoDirEnt_User("AKN", AKN->AKN_CODIGO, __cUserID, .F.)
    If nDirAcesso == 0 //0=bloqueado
		Aviso(STR0022,STR0024,{STR0025},2)//"Atenção"###"Usuario sem acesso a esta configuração de visao gerencial. "###"Fechar"
		lContinua := .F.
	Else
	    lContinua := .T.
	EndIf
EndIf

If lContinua 
		If (aPeriodo == NIL .Or. Empty(aPeriodo)) .And. ;
			ParamBox( { 	{2,STR0005,"3",{STR0006,STR0007,STR0008,STR0009,STR0010,STR0011},80,"",.F.},;   //"Tipo Periodo"###"1=Semanal"###"2=Quinzenal"###"3=Mensal"###"4=Bimestral"###"5=Semestral"###"6=Anual"
							{1,STR0012,CtoD(Space(8)),"","",,"",50,.T.},; //"Inicio Periodo"
							{1,STR0013,CtoD(Space(8)),"","",,"",50,.T.} }, "OK" ,aParam ) //"Final Periodo"
		Else
			If aPeriodo != NIL .And. !Empty(aPeriodo)
				mv_par01 := aPeriodo[1]
				mv_par02 := aPeriodo[2]
				mv_par03 := aPeriodo[3]
			Else
				lContinua := .F.
			EndIf
		EndIf
EndIf

If lContinua
	lContinua := A180VerifyCpos()
	If !lContinua
		Aviso(STR0022,STR0023,{"OK"},2)//"Atencao"###"Campos cadastrados nos parametros da visao gerencial nao encontrados. Verifique!"
	EndIf
EndIf

If lContinua
	If mv_par03 >= mv_par02
		cTpPeriodo := mv_par01
		dIniPer := mv_par02
		dFimPer := mv_par03
		aPeriodo := {mv_par01, mv_par02, mv_par03}
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ ExecBlock para inclusao por exemplo pergunte         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("PCOA1802")
			//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//P_E³ Ponto de entrada utilizado para inclusao de funcoes de usuarios na     ³
			//P_E³ tela da planilha visao Gerencial orcamentaria                          ³
			//P_E³ Parametros : Nenhum                                                    ³
			//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ExecBlock("PCOA1802",.F.,.F.)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem do aHeader do AKP                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		A180aHeaderCfg(aHeaderCfg, lVisual, aConfig)

		//montar arquivo de Trabalho para cabecalho da planilha visao gerencial
		//Estrutura identica ao AK1 - Planilha Orcamentaria
		aStruAK1 := AK1->(DBSTRUCT())
		
		If _oPCOA1801 <> Nil
			_oPCOA1801:Delete()
			_oPCOA1801 := Nil
		Endif
		
		aChave1	:= {"AK1_FILIAL","AK1_CODIGO","AK1_VERSAO"}		

		_oPCOA1801 := FWTemporaryTable():New( "TMPAK1" )  
		_oPCOA1801:SetFields(aStruAK1) 
		_oPCOA1801:AddIndex("1", aChave1)

		//------------------
		//Criação da tabela temporaria
		//------------------
		_oPCOA1801:Create()
		
		cArqCab	:= _oPCOA1801:GetRealName()
		
		dbSelectArea("TMPAK1")
        RecLock("TMPAK1", .T.)
		TMPAK1->AK1_FILIAL := ""
		TMPAK1->AK1_CODIGO := AKN->AKN_CODIGO
		TMPAK1->AK1_VERSAO := "0001"
		TMPAK1->AK1_VERREV := ""
		TMPAK1->AK1_DESCRI := AKN->AKN_DESCRI
		TMPAK1->AK1_NMAX   := 99
		TMPAK1->AK1_TPPERI := cTpPeriodo
		TMPAK1->AK1_INIPER := dIniPer
		TMPAK1->AK1_FIMPER := dFimPer
		TMPAK1->AK1_TPREV  := ""
		TMPAK1->AK1_STATUS := ""
		TMPAK1->AK1_MEMO   := ""
		TMPAK1->AK1_CTRUSR := "2"
		MsUnLock()        
		
		//montar arquivo de Trabalho para itens da visao orcamentaria gerencial
		//Estrutura identica ao AK2 - Itens da Planilha Orcamentaria
		aStruAK2 := AK2->(DBSTRUCT())
		If (nPosCO := Ascan(aStruAK2,  {|aVal| Alltrim(aVal[1]) == "AK2_CO"})) > 0
			aStruAK2[nPosCO][3] := Len(AKO->AKO_CO)
		EndIf	
        aAdd(aStruAK2, {"AK2_ORCORI", "C", Len(AK2->AK2_ORCAME), 0})
        aAdd(aStruAK2, {"AK2_CO_ORI", "C", Len(AK2->AK2_CO), 0})
        aAdd(aStruAK2, {"AK2_PERORI", "D", 8, 0})
        aAdd(aStruAK2, {"AK2_ID_ORI", "C", Len(AK2->AK2_ID), 0})
        aAdd(aStruAK2, {"AK2_VLRORI", "N", 14, 2})
        aAdd(aStruAK2, {"AK2_RECNO", "N", 10, 0})
        
 		If _oPCOA1802 <> Nil
			_oPCOA1802:Delete()
			_oPCOA1802 := Nil
		Endif
		
		aChave2	:= {"AK2_FILIAL","AK2_ORCAME","AK2_CO","AK2_PERIOD","AK2_ID"}
		aChave3	:= {"AK2_FILIAL","AK2_ORCAME","AK2_CO","AK2_ID"}

		_oPCOA1802 := FWTemporaryTable():New( "TMPAK2" )  
		_oPCOA1802:SetFields(aStruAK2) 
		_oPCOA1802:AddIndex("1", aChave2)
		_oPCOA1802:AddIndex("2", aChave3)

		//------------------
		//Criação da tabela temporaria
		//------------------
		_oPCOA1802:Create()
		
		cArqIte	:= _oPCOA1802:GetRealName()
        
       dbSelectArea("TMPAK2") 
	   dbSetOrder(1)
        
		dbSelectArea("AKO")
		dbSetOrder(3)
		MsSeek(xFilial()+AKN->AKN_CODIGO+"001")
		While !Eof() .And. 	AKO_FILIAL+AKO_CODIGO+AKO_NIVEL==;
							xFilial("AKO")+AKN->AKN_CODIGO+"001"
			aDadosAK2 := {}				
			PCOA180It(AKO_CODIGO,AKO_CO, .F., aDadosAK2, @lContinua)
			dbSelectArea("AKO")
			dbSkip()
		End
		
		If ! lPrintRel
			//visualizacao da planilha visao orcamentaria gerencial
			MENU oMenu POPUP
				MENUITEM STR0017 ACTION (Pco180to171(2,cArquivo),Eval(bRefresh)) //"Visualizar C.O.G."
			ENDMENU
			MENU oMenu1 POPUP
				MENUITEM STR0018 ACTION (dbSelectArea((cArquivo)->ALIAS),dbGoto((cArquivo)->RECNO),PCOR030(.T.)) //"Plan.Visao Ger.Mod.1"
				MENUITEM STR0019+"(A)" ACTION (dbSelectArea((cArquivo)->ALIAS),dbGoto((cArquivo)->RECNO),PCOR035(.T.)) //"Plan.Visao Ger.Mod.2"
				MENUITEM STR0020+"(A)" ACTION (dbSelectArea((cArquivo)->ALIAS),dbGoto((cArquivo)->RECNO),PCOR040(.T.)) //"Total Visao Gerencial"
				MENUITEM STR0019+"(B)" ACTION (dbSelectArea((cArquivo)->ALIAS),dbGoto((cArquivo)->RECNO),PCOR055(.T.)) //"Plan.Visao Ger.Mod.2"
				MENUITEM STR0020+"(B)" ACTION (dbSelectArea((cArquivo)->ALIAS),dbGoto((cArquivo)->RECNO),PCOR060(.T.)) //"Total Visao Gerencial"
			ENDMENU
	
			aMenu := {	{TIP_PESQUISAR,		{|| PcoAKZPesq(cArquivo) }, BMP_PESQUISAR, TOOL_PESQUISAR},;
						{TIP_ORC_IMPRESSAO,	{|| oMenu1:Activate(140,45,oDlg) }, "IMPRESSAO", TOOL_ORC_IMPRESSAO},;
						{TIP_ORC_ESTRUTURA,	{|| PCO180Menu(@oMenu,l180Visual,cArquivo),oMenu:Activate(140,45,oDlg) },BMP_ORC_ESTRUTURA,TOOL_ORC_ESTRUTURA}}
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ ExecBlock para inclusao de botoes customizados       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock("PCOA1803")
				//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//P_E³ Ponto de entrada utilizado para inclusao de funcoes de usuarios na     ³
				//P_E³ tela da planilha orcamentaria                                          ³
				//P_E³ Parametros : Nenhum                                                    ³
				//P_E³ Retorno    : Array contendo as rotinas a serem adicionados na planilha ³
				//P_E³              [1] : Titulo                                              ³
				//P_E³              [2] : Codeblock contendo a funcao do usuario              ³
				//P_E³              [3] : Resource utilizado no bitmap                        ³
				//P_E³              [4] : Tooltip do bitmap                                   ³
				//P_E³              Exemplo :                                                 ³
				//P_E³              User Function PCOXFUN1                                    ³
				//P_E³              Return {{"Titulo", {|| U_Botao() }, "BPMSDOC","Titulo" }} ³
				//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aUsrButons := ExecBlock("PCOA1803",.F.,.F.)
				For nx := 1 to Len(aList)
					aAdd(aMenu,{aUsrButons[nx,1],aUsrButons[nx,2],aUsrButons[nx,3],aUsrButons[nx,4]})
				Next
			EndIf
			
			If lContinua
				dbSelectArea("AKO")
				dbGoTop()
	
				PCOAKZPLAN(STR0001,,cArquivo,@lOk,aMenu,@oDlg,,,l180Visual,cFiltro,aPeriodo) //"Visao Gerencial Orcamentaria"
				
			EndIf
			
			If lOk
				PCO180EXE("AKN",AKN->(RecNo()),3,,,aPeriodo)
			Else
				aPeriodo := NIL	
			EndIf
		
		Else
		
			Eval(bPrintRel)
		
		EndIf	
			
	EndIf
	
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCO180Menu³ Autor ³ Paulo Carnelossi      ³ Data ³ 16/11/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de controle do menu de atualizacoes.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCO180Menu(oMenu,lVisual,cArquivo)
Local aArea		:= GetArea()
Local cAlias	
Local nRecView	

cAlias	:= (cArquivo)->ALIAS
nRecView	:= (cArquivo)->RECNO
dbSelectArea(cAlias)
dbGoto(nRecView)

If !lVisual
	Do Case 
		Case cAlias == "AKO" 
				oMenu:aItems[1]:Enable()
		Otherwise
			oMenu:aItems[1]:Enable()
	EndCase
   
EndIf

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCO180to171³ Autor ³ Paulo Carnelossi     ³ Data ³ 16/11/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de chamada do PCOA171 para atualizacao do Conta Orc Ger³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PCOA180                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCO180to171(nOpc,cArquivo)

Local aArea		:= GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ExecBlock para inclusao de botoes customizados       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PCOA1804")
	//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//P_E³ Ponto de entrada utilizado para validacao da rotina chamada no menu    ³
	//P_E³ Estrutura no programa de atualizacao da planilha orcamentaria.         ³
	//P_E³ Parametros : [1] - Numerico - Opcao selecionada                        ³
	//P_E³ Retorno    : Logico - Permite ou na a utilizacao da opcao selecionada. ³
	//P_E³              Exemplo :                                                 ³
	//P_E³              User Function PCOA1804                                    ³
	//P_E³              Local lRet := .F.                                         ³
	//P_E³              If ParamIXB[1] == 1                                       ³	
	//P_E³                 lRet := .T.                                            ³	
	//P_E³              EndIf                                                     ³	
	//P_E³              Return lRet                                               ³
	//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !ExecBlock("PCOA1804", .F., .F., {nOpc})
		RestArea(aArea)
		Return
	EndIf
EndIf

cAlias := (cArquivo)->ALIAS
nRecAlias := (cArquivo)->RECNO

dbSelectArea(cAlias)
dbGoto(nRecAlias)
Do Case
	Case nOpc == 2
		PCOA171(2,,"000")
	Case nOpc == 3
		aGetCpos := {	{"AKO_CODIGO",AKO->AKO_CODIGO,.F.},;
						{"AKO_COPAI",AKO->AKO_CO,.F.}}

		nRecAKO	:= PCOA171(3,aGetCpos,AKO->AKO_NIVEL)
	Case nOpc == 4 
		PCOA171(4,,"000")
	Case nOpc == 5
	    If PadR(AKO_CODIGO, Len(AKO_CO))!=PadR(AKO_CO, Len(AKO_CO))
			PCOA171(5,,"000")
		EndIf	
EndCase

RestArea(aArea)
Return	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCOA180It ³ Autor ³ Paulo Carnelossi      ³ Data ³22/11/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Itens da conta orcamentaria gerencial                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PCOA180It                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PCOA180It(cVisGer,cCOG,lGravaAK2, aDadosAK2, lContinua)
Local aArea		:= GetArea()
Local aAreaAKO	:= AKO->(GetArea())

Private aColsAKP
Private aFiltro

IF lGravaAK2
  	A180GravaAK2(aDadosAK2)
    aDadosAK2 := {}
EndIf

dbSelectArea("AKO")
dbSetOrder(2)
MsSeek(xFilial()+cVisGer+cCOG)
While !Eof() .And. AKO->AKO_FILIAL+AKO->AKO_CODIGO+AKO->AKO_COPAI==xFilial("AKO")+cVisGer+cCOG
    
    lGrava := .T.
    aColsAKP := {}
    //grava no array AcolsAKP - a definicao do filtro a ser utilizado no ponto
    //de entrada PCOA1805 (abaixo)
    aColsAKP := PcoA180PlanIt()
    
    //aFiltro eh visualizado no ponto de entrada
    aFiltro := {cTpPeriodo, dIniPer, dFimPer, aHeaderCfg, aColsAKP, aConfig}  

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ExecBlock para para usuario montar array com conteudo³
	//³ arquivo temporario itens da C.O.G.                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("PCOA1805")
	    If ValType( aDadosAK2 := ExecBlock( "PCOA1805", .F., .F. ) ) != "A"
	       Conout(STR0021) //"Erro ao executar o ponto de entrada PCOA1806"
	       lGrava := .F.
	    EndIf
	Else
		aDadosAK2 := {}
		nId := 1
		A180CarregaAK2(aDadosAK2, @nId, @lContinua)
	EndIf
		
	PCOA180It(AKO->AKO_CODIGO,AKO->AKO_CO, lGrava, aDadosAK2, @lContinua)
	
	dbSelectArea("AKO")
	dbSkip()
End

RestArea(aAreaAKO)
RestArea(aArea)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoA180PlanIt  ³ Autor ³ Paulo Carnelossi  ³ Data ³18/11/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de montagem dos itens planilha Visao Ger.orcamentaria  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoA180PlanIt()

Local ny
Local aAuxArea	:= {}
Local aArea		:= GetArea()
Local nHeadItem	:= aScan(aHeaderCfg,{|x| AllTrim(x[2])=="AKP_ITEM"})
Local aAreaAKO := AKO->(GetArea())

aColsFiltro	:= {}

dbSelectArea("AKP")
dbSetOrder(1)
If dbSeek(xFilial("AKP") + AKN->AKN_CODIGO + AKO->AKO_CO ) 
	While !Eof() .And. AKP->AKP_FILIAL + AKP->AKP_CODIGO + AKP->AKP_CO  == ;
						xFilial("AKP") + AKN->AKN_CODIGO + AKO->AKO_CO
						
		nPosIt	:= aScan(aColsFiltro,{|x| x[nHeadItem] == AKP->AKP_ITEM})

		If nPosIt > 0
			For ny := 1 to Len(aHeaderCfg)
				Do Case
					Case Left(AllTrim(aHeaderCfg[ny][2]),7)=="AKP_CRF"
					    If Left(AllTrim(aHeaderCfg[ny][2]),9)=="AKP_CRF"+AKP->AKP_ITECFG
							If AKP->AKP_TIPO=="1".OR.;
								Subs(AllTrim(aHeaderCfg[ny][2]),10,1)=="1"
								aColsFiltro[nPosIt][nY] := String_To_QQTipo(AKP->AKP_VALINI, aHeaderCfg[ny][8])
							EndIf
							If AKP->AKP_TIPO=="2".And.;
								Subs(AllTrim(aHeaderCfg[ny][2]),10,1)=="2"
								aColsFiltro[nPosIt][nY] := String_To_QQTipo(AKP->AKP_VALFIM, aHeaderCfg[ny][8])
							EndIf	
						EndIf
					OtherWise
						If ( aHeaderCfg[ny][10] != "V") 
							aColsFiltro[nPosIt][ny] := FieldGet(FieldPos(aHeaderCfg[ny][2]))
						EndIf   						
				EndCase
			Next
		Else
			aADD(aColsFiltro,Array(Len(aHeaderCfg)+1))
			aColsFiltro[Len(aColsFiltro)][Len(aHeaderCfg)+1] := .F.		
			For ny := 1 to Len(aHeaderCfg)
				Do Case
					Case Left(AllTrim(aHeaderCfg[ny][2]),7)=="AKP_CRF"
						If Left(AllTrim(aHeaderCfg[ny][2]),9)=="AKP_CRF"+AKP->AKP_ITECFG
							If AKP->AKP_TIPO=="1".OR.;
								Subs(AllTrim(aHeaderCfg[ny][2]),10,1)=="1"
								aColsFiltro[Len(aColsFiltro)][nY] := String_To_QQTipo(AKP->AKP_VALINI, aHeaderCfg[ny][8])
							EndIf
							If AKP->AKP_TIPO=="2".And.;
								Subs(AllTrim(aHeaderCfg[ny][2]),10,1)=="2"
								aColsFiltro[Len(aColsFiltro)][nY] := String_To_QQTipo(AKP->AKP_VALFIM, aHeaderCfg[ny][8])
							EndIf
						EndIf
					OtherWise
						If ( aHeaderCfg[ny][10] != "V") 
							aColsFiltro[Len(aColsFiltro)][ny] := FieldGet(FieldPos(aHeaderCfg[ny][2]))
						EndIf   						
				EndCase
			Next
		EndIf
		dbSkip()
	End
EndIf

RestArea(aAreaAKO)	
RestArea(aArea)

Return(aColsFiltro)

Static Function A180CarregaAK2(aDadosAK2, nId, lContinua)
Local cTpPeriodo := aFiltro[TP_PERIODO]
Local dIniPer := aFiltro[INI_PERIODO]
Local dFimPer := aFiltro[FIM_PERIODO]
Local aHeaderCfg := aFiltro[ARRAY_HEADERCFG]
Local aColsAKP := aFiltro[ARRAY_ACOLSAKP]
Local aConfig := aFiltro[ARRAY_ACONFIG]
Local nX, nY
Local nPlanilha := Ascan(aHeaderCfg,{|x| AllTrim(x[2]) == "AKP_CRF01"})
Local nOperac := Ascan(aHeaderCfg,{|x| AllTrim(x[2]) == "AKP_OPERAC"})
Local nFuncao := Ascan(aHeaderCfg,{|x| AllTrim(x[2]) == "AKP_FORMUL"})
Local aAuxAK2, bFilter, cVerPlan, cItAK2
Local lVerAcesso := GETMV("MV_PCOVACE",,.T.)

dbSelectArea("AK1")
dbSetOrder(1)

If nPlanilha > 0

	For nX := 1 TO Len(aColsAKP)
		If lContinua
			//verifico se existe a planilha e se o periodo corresponde execucao da consulta Ger.
		    If dbSeek(xFilial("AK1")+PadR(aColsAKP[nX][nPlanilha],Len(AK1->AK1_CODIGO)))
		    	//(cVerPlan := PcoVerAtu(PadR(aColsAKP[nX][nPlanilha],Len(AK1->AK1_CODIGO)))))
		    	If AK1->AK1_TPPERI != cTpPeriodo
		    		HELP("  ",1,"PCOA1801") //Tipo periodo da planilha difere com o da visao gerencial.
					lContinua := .F.
	            Else
	            	If AK1->AK1_INIPER != dIniPer .OR.;
	            		AK1->AK1_FIMPER != dFimPer
			    		HELP("  ",1,"PCOA1801") //Tipo periodo da planilha difere com o da visao gerencial.
						lContinua := .F.
	            	Else
	            	    bFilter := A180MontaFiltro(aHeaderCfg, aColsAKP, aConfig, nX)
		                //processa AK2 e grava conteudo dos registros no array aDadosAK2
		                dbSelectArea("AK2")
		                dbSetOrder(5)
		                dbSeek(xFilial("AK2")+PadR(aColsAKP[nX][nPlanilha],Len(AK2_ORCAME)))
		                While ! Eof() .And. AK2_FILIAL+AK2_ORCAME== xFilial("AK2")+;
		                						PadR(aColsAKP[nX][nPlanilha],Len(AK2_ORCAME))
		                    If Eval(bFilter)
		                    	
		                    	cItAK2 := AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CO+AK2_ID
		                    	
				                While ! Eof() .And. AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CO+AK2_ID==cItAK2
				                
					                If (If(lVerAcesso,A180TemAcesso(),.T.)) .And. Eval(bFilter)
						                aAuxAK2 := {}
						                For nY := 1 To FCount()
						                	aAdd(aAuxAK2, {FieldName(nY), FieldGet(nY)})
						                Next
						                aAdd(aAuxAk2,aColsAKP[nX][nOperac])
						                aAdd(aAuxAk2,aColsAKP[nX][nFuncao])
						                aAdd(aAuxAk2, nId)//grava recno no ultimo elemento
						                aAdd(aAuxAk2, Recno())//grava recno no ultimo elemento
		
						                aAdd(aDadosAK2, aAuxAK2)
					                EndIf
					                dbSkip()
					                
								End
								
	                            nId++  //Incrementa contador de itens
	                            
			                Else
			                
			                   dbSkip()
			                   
			                EndIf
			                
			            End	
			            
		            EndIf
		    	EndIf
		    Else
				HELP("  ",1,"PCOA1802",,Alltrim(aColsAKP[nX][nPlanilha]))
				lContinua := .F.
		    EndIf
		EndIf
	Next
	
EndIf

Return

Static Function A180GravaAK2(aDadosAK2)
Local nX := 1, nId, nY, nPos
Local cFuncao

Private nValor := 0

dbSelectArea("TMPAK2")

While nX <= Len(aDadosAK2)
	
	nId := aDadosAK2[nX][Len(aDadosAK2[nX])-1]
	
	While nX <= Len(aDadosAK2) .And. nId == aDadosAK2[nX][Len(aDadosAK2[nX])-1]
	    
	    //grava campos da tabela AK2
	    RecLock("TMPAK2", .T.)
		For nY := 1 TO Len(aDadosAK2[nX])-4
			nPos := FieldPos(aDadosAK2[nX][nY][1])
			If nPos > 0
				FieldPut(nPos, aDadosAK2[nX][nY][2])
			EndIf	
		Next
		
		//grava campos de origem da tabela AK2+COG
		FieldPut(FieldPos("AK2_ORCORI"), TMPAK2->AK2_ORCAME)
		FieldPut(FieldPos("AK2_CO_ORI"), TMPAK2->AK2_CO)
		FieldPut(FieldPos("AK2_PERORI"), TMPAK2->AK2_PERIOD)
		FieldPut(FieldPos("AK2_ID_ORI"), TMPAK2->AK2_ID)
		FieldPut(FieldPos("AK2_VLRORI"), TMPAK2->AK2_VALOR)
		FieldPut(FieldPos("AK2_RECNO"), aDadosAK2[nX][Len(aDadosAK2[nX])])

		//grava campos para ligacao com a tab TMPAK1/AKO
		FieldPut(FieldPos("AK2_ORCAME"), AKO->AKO_CODIGO)
		FieldPut(FieldPos("AK2_CO"), AKO->AKO_CO)
		FieldPut(FieldPos("AK2_ID"), StrZero(aDadosAK2[nX][Len(aDadosAK2[nX])-1],Len(TMPAK2->AK2_ID)))

		//Grava valor dependendo da operacao somar/diminuir ou aplicar uma funcao/formula
		nValor := If(aDadosAK2[nX][Len(aDadosAK2[nX])-3] == "1", TMPAK2->AK2_VALOR, TMPAK2->AK2_VALOR*-1)

		cFuncao := aDadosAK2[nX][Len(aDadosAK2[nX])-2]
		
		nValor := If(Empty(cFuncao), nValor, &cFuncao)

		FieldPut(FieldPos("AK2_VALOR"), nValor)
		
		MsUnLock()
		
		nX++
		
	End		
	
End

Return


Static Function A180MontaFiltro(aHeaderCfg, aColsAKP, aConfig, nElem)
Local bFilter := {||.T.}
Local nX, nY
Local aAuxFil := {}
Local cEntFil, cCpoFil, cCpoRef, cTipo, cFiltro, nPosCol

Local nEntFil 	:= aScan(aConfig[1],{|x| AllTrim(x[1])=="AKM_ENTFIL"})
Local nCpoFil 	:= aScan(aConfig[1],{|x| AllTrim(x[1])=="AKM_CPOFIL"})
Local nTipo  	:= aScan(aConfig[1],{|x| AllTrim(x[1])=="AKM_TIPO"})
Local nPlanilha := Ascan(aHeaderCfg,{|x| AllTrim(x[2]) == "AKP_CRF01"})

For nX := 2 TO Len(aConfig)
	
	cEntFil := aConfig[nX][nEntFil][2]
	cCpoFil := aConfig[nX][nCpoFil][2]
	cCpoRef := "AKP_CRF"+StrZero(nX,2)
    cTipo   := aConfig[nX][nTipo][2]
    
	aAdd(aAuxFil,{cEntFil, cCpoFil, cCpoRef+If(cTipo=="1","","1"), cTipo})

	If cTipo == "2"
		aAdd(aAuxFil,{cEntFil, cCpoFil, cCpoRef+"2", cTipo})
	EndIf

Next

cFiltro := "{||"

	cFiltro += "( "
	
	For nY := 1 TO Len(aAuxFil)
		cFiltro += Alltrim(aAuxFil[nY][1])+"->"+Alltrim(aAuxFil[nY][2])
		
		If aAuxFil[nY][4]=="1"
			cFiltro += " == "
		Else
			If Right(Alltrim(aAuxFil[nY][3]),1)=="1"
				cFiltro += " >= "
			Else
				cFiltro += " <= "
			EndIf
		EndIf
		
		If (nPosCol := aScan(aHeaderCfg,{|x| AllTrim(x[2])==AllTrim(aAuxFil[nY][3])})) > 0
			If Alltrim(aAuxFil[nY][2]) == "AK2_VERSAO" .And. ;
				Empty(AcolsAKP[nElem][nPosCol])
				cFiltro += "PadR(PcoVerAtu(PadR(aColsAKP[nX][nPlanilha],Len(AK1->AK1_CODIGO))), Len(AK1->AK1_VERSAO))"
			Else
				cFiltro += "PadR('"+AcolsAKP[nElem][nPosCol]+"', Len("+Alltrim(aAuxFil[nY][1])+"->"+Alltrim(aAuxFil[nY][2])+"))"
			EndIf
		
			If nY < Len(aAuxFil)
				cFiltro += " .And. "
			EndIf	
		EndIf
		
	Next
    cFiltro += " )"

cFiltro += " }"

//monta o bloco para filtro
bFilter := MontaBlock(cFiltro)

Return(bFilter)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A180TemAcessoºAutor  ³Paulo Carnelossi º Data ³  12/17/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se usuario tem acesso a visualizacao da Conta Orc. º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A180TemAcesso()
Local cAlias := Alias()
Local aArea := GetArea()
Local aAreaAK3 := AK3->(GetArea())
Local lRet := .F.

Static nQtdEntid 

dbSelectArea("AK3")
dbSetOrder(1)
       
If dbSeek(xFilial("AK3")+AK2->AK2_ORCAME+AK2->AK2_VERSAO+AK2->AK2_CO)
	If PcoChkUser(AK3->AK3_ORCAME,AK3->AK3_CO,AK3->AK3_PAI,1,"ESTRUT",AK3->AK3_VERSAO) .And. ;
		PcoChkUser(AK3->AK3_ORCAME,AK3->AK3_CO,AK3->AK3_PAI,2,"ITENS",AK3->AK3_VERSAO) .And. ;
		PcoCC_User(AK3->AK3_ORCAME,AK3->AK3_CO,AK3->AK3_PAI,2,"CCUSTO",AK3->AK3_VERSAO,AK2->AK2_CC) .And. ;
		PcoIC_User(AK3->AK3_ORCAME,AK3->AK3_CO,AK3->AK3_PAI,2,"ITMCTB",AK3->AK3_VERSAO,AK2->AK2_ITCTB) .And. ;
		PcoCV_User(AK3->AK3_ORCAME,AK3->AK3_CO,AK3->AK3_PAI,2,"CLAVLR",AK3->AK3_VERSAO,AK2->AK2_CLVLR) .And. ;
		PcoUserEnts()
	    lRet := .T.
	EndIf    
EndIf	

RestArea(aAreaAK3)
RestArea(aArea)
dbSelectArea(cAlias)

Return(lRet)


		
Function A180aHeaderCfg(aHeaderCfg, lVisual, aConfig, cCfgAKN)
Local nX, aAuxCpo
Local cPicture, nTamanho, nDecimal, cTipo

DEFAULT cCfgAKN := AKN->AKN_CONFIG

cCfgAKN := PadR(cCfgAKN, Len(AKN->AKN_CONFIG))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader do AKP                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("AKP")
//campos normais da tabela AKP
While !EOF() .And. (x3_arquivo == "AKP")
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel 
		AADD(aHeaderCfg,{ 	TRIM(x3titulo()),;
							SX3->X3_CAMPO,;
							SX3->X3_PICTURE,;
							SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,;
							SX3->X3_VALID,;
							SX3->X3_USADO,;
							SX3->X3_TIPO,;
							SX3->X3_F3,;
							SX3->X3_CONTEXT,;
							SX3->X3_CBOX,;
							SX3->X3_RELACAO,;
							SX3->X3_WHEN})

	Endif
	dbSkip()
End

//campos VIRTUAIS de acordo com configuracao da visao na grade da tabela AKP
dbSelectArea("SX3")
dbSetOrder(2)

dbSelectArea("AKM")
dbSetOrder(1)
dbSeek(xFilial("AKM")+cCfgAKN)
//campos normais da tabela AKP
While AKM->(!EOF() .And. AKM_FILIAL + AKM_CONFIG == xFilial("AKM")+cCfgAKN)
    
    aAuxCpo := {}
    For nX := 1 TO FCount()
		aAdd(aAuxCpo, {FieldName(nX), FieldGet(nX)})
    Next
    aAdd(aConfig, aClone(aAuxCpo))
    If SX3->(!dbSeek(TRIM(AKM->AKM_CPOREF)))
	    cPicture := AKM->AKM_PICTUR
	    nTamanho := AKM->AKM_TAMANH
		nDecimal := AKM->AKM_DECIMA
		cTipo	 := aTiposCp[Val(AKM->AKM_TIPOCP)]
    Else
	    cPicture := SX3->X3_PICTURE
	    nTamanho := SX3->X3_TAMANHO
		nDecimal := SX3->X3_DECIMAL
		cTipo    := SX3->X3_TIPO
    EndIf
    
    If AKM->AKM_TIPO == "1"
		AADD(aHeaderCfg,{ 	TRIM(AKM->AKM_TITULO),;
						"AKP_CRF"+AKM->AKM_ITEM/*SX3->X3_CAMPO*/,;
						cPicture/*SX3->X3_PICTURE*/,;
						nTamanho/*SX3->X3_TAMANHO*/,;
						nDecimal/*SX3->X3_DECIMAL*/,;
						""/*SX3->X3_VALID*/,;
						""/*SX3->X3_USADO*/,;
						cTipo/*SX3->X3_TIPO*/,;
						AKM->AKM_CONPAD/*SX3->X3_F3*/,;
						"V"/*SX3->X3_CONTEXT*/,;
						""/*SX3->X3_CBOX*/,;
						If(lVisual, "", AKM->AKM_VALINI)/*SX3->X3_RELACAO*/,;
						""/*SX3->X3_WHEN*/})
	Else
		For nX := 1 TO 2
		AADD(aHeaderCfg,{ 	TRIM(AKM->AKM_TITULO)+If(nX==1,STR0014, STR0015),; //" De"###" Ate"
						"AKP_CRF"+AKM->AKM_ITEM+Str(nX,1)/*SX3->X3_CAMPO*/,;
						cPicture/*SX3->X3_PICTURE*/,;
						nTamanho/*SX3->X3_TAMANHO*/,;
						nDecimal/*SX3->X3_DECIMAL*/,;
						""/*SX3->X3_VALID*/,;
						""/*SX3->X3_USADO*/,;
						cTipo/*SX3->X3_TIPO*/,;
						AKM->AKM_CONPAD/*SX3->X3_F3*/,;
						"V"/*SX3->X3_CONTEXT*/,;
						""/*SX3->X3_CBOX*/,;
						If(lVisual, "", If(nX==1, AKM->AKM_VALINI, AKM->AKM_VALFIM))/*SX3->X3_RELACAO*/,;
						""/*SX3->X3_WHEN*/})
		Next
	EndIf
	AKM->(dbSkip())
End

Return

Static Function A180VerifyCpos()
Local lContinua := .F., lExistCpos := .T.
Local aArea := GetArea()
Local aAreaAKM := AKM->(GetArea())

dbSelectArea("AKM")
dbSetOrder(1)

If dbSeek(xFilial("AKM")+AKN->AKN_CONFIG)
	While AKM->(!Eof() .And. AKM_FILIAL+AKM_CONFIG == xFilial("AKM")+AKN->AKN_CONFIG)
		lExistCpos := lExistCpos .And. ;
			(A180CampoPos(Alltrim(AKM->AKM_ENTSIS),Alltrim(AKM->AKM_CPOREF))>0) .And. ;
			(A180CampoPos(Alltrim(AKM->AKM_ENTFIL),Alltrim(AKM->AKM_CPOFIL))>0) 
		AKM->(dbSkip())
	End
	lContinua := lExistCpos
EndIf

RestArea(aAreaAKM)
RestArea(aArea)

Return(lContinua)

Static Function A180CampoPos(cAlias,cCampo)
Local aArea := GetArea()
Local nPosCpo := 0

dbSelectArea(cAlias)
nPosCpo := FieldPos(cCampo)

RestArea(aArea)

Return(nPosCpo)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³12/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
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
Local aRotina 	:= {	{ STR0002,		"AxPesqui"  , 0 , 1, ,.F.},;    //"Pesquisar"
							{ STR0003, 	"PCO180DLG" , 0 , 2},;    //"Vis.Definicao"
							{ STR0004, 		"PCO180EXE" , 0 , 6 }} //"Executar"

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona botoes do usuario no Browse                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "PCOA1801" )
		//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//P_E³ Ponto de entrada utilizado para inclusao de funcoes de usuarios no     ³
		//P_E³ browse da tela de orcamentos                                           ³
		//P_E³ Parametros : Nenhum                                                    ³
		//P_E³ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ³
		//P_E³               Ex. :  User Function PCOPE001                            ³
		//P_E³                      Return {{"Titulo", {|| U_Teste() } }}             ³
		//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType( aUsRotina := ExecBlock( "PCOA1801", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
EndIf
Return(aRotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoUserEntºAutor  ³Bruna Paola		 º Data ³  17/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se usuario tem acesso a Unidade Orcamentaria e as  º±±
±±º          ³ novas entidades.                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoUserEnts()
Local lRet := .T. 
Local nQt  
Local aAreaAK2 := GetArea()
Static nQtdEntid

/*
 PcoDirEnt_User retorna
0        - sem direito de acesso
1,2 ou 3 - com direito de acesso 
1 - Visualizar
2 - Alterar
3 - Controle Total
*/  


// Verifica a Unidade Orcamentaria se = 0 nao tem acesso
If PcoDirEnt_User("AMF", AK2->AK2_UNIORC, __cUserID, .F.) == 0 
  	lRet := .F.
EndIf

// Verifica a quantidade de entidades contabeis
If nQtdEntid == NIL
	If cPaisLoc == "RUS" 
		nQtdEntid := PCOQtdEntd()//sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor.
	Else
		nQtdEntid := CtbQtdEntd()//sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	EndIf
EndIf 

// Verificar as novas entidades 
If nQtdEntid > 4 .And. lRet == .T.   

	For nQt := 5 To nQtdEntid 

		dbSelectArea("CT0")
		dbSetOrder(1)
		
		dbSeek(xFilial("CT0")+STRZERO(nQt,2))    
		
		If PcoDirEnt_User(CT0->CT0_ALIAS, FieldGet(AK2->(FieldPos("AK2_ENT"+STRZERO(nQt,2)))), __cUserID, .F., CT0->CT0_ENTIDA) == 0
		   	lRet := .F.
		EndIf
	Next  
EndIf

RestArea(aAreaAK2)
Return (lRet)  

//-------------------------------------------------------------------
/*/{Protheus.doc} 

Função para deleção da tabela temporária chamada de outro fonte

@author Kássia Caregnatto
@since 23/01/2016
@version 1.0
/*/

//-------------------------------------------------------------------
Function DelPCOA180()

If _oPCOA1801 <> Nil
	_oPCOA1801:Delete()
	_oPCOA1801 := Nil
Endif
	
If _oPCOA1802 <> Nil
	_oPCOA1802:Delete()
	_oPCOA1802 := Nil
Endif

Return
