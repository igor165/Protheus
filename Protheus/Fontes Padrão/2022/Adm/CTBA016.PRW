#INCLUDE "CTBA016.CH"
#INCLUDE "PROTHEUS.CH"

// 17/08/2009 -- Filial com mais de 2 caracteres

Static aCodRel := {	{"01","Matriz no exterior"},; 
					{"02","Filial, inclusive agências, dependências e filiais no exterior"},;
					{"03","Coligada, inclusive equiparada"},;
					{"04","Controladora"},;
					{"05","Controlada (exceto subsidiária integral)"},;
					{"06","Subsidiária integral"},;
					{"07","Controlada em conjunto"},;
					{"08","Entidade de Propósito Específico (conforme definição da CVM)"},;
					{"09","Participante do conglomerado, conforme norma específica do órgão regulador, exceto as que se enquadrem nos tipos precedentes"},;
					{"10","Vinculadas (Art. 23 da Lei 9.430/96), exceto as que se enquadrem nos tipos precedentes"},;
					{"11","Localizada em país com tributação favorecida (Art. da Lei 9.430/96)"}	}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CTBA016  ³ Autor ³ Marco Bianchi         ³ Data ³ 16/18/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cadastro do Participante                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBA016()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MP8                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alf. Medrano³08/07/16³TVPIJ3³Merge v118 vs v1217                       ³±±
±±³            ³        ³      ³Se modifica Func CTBA016 Se agrega func   ³±±
±±³            ³        ³      ³CTB016INC que inserta NIt/Ced en CV0, Func³±±
±±³            ³        ³      ³CTB016ALT que altera NIt/Ced en CV0 func  ³±±
±±³            ³        ³      ³CTB016TdOk que valida NIt/Ced y func      ³±±
±±³            ³        ³      ³CTB016DEL que borra Reg. De CV0. COLOMBIA ³±±
±±³            ³        ³      ³Se agrega func GetSxENum() en CTB016INC   ³±±
±±³ gsantacruz  ³        ³      ³Se modifican la etiquetas del menu       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CTBA016(nOpcAuto,aAuto)

Local cAlias 		:= "CVC"

If !Empty(aAuto)
	AxCadastro("CVC",STR0001,".T.",".T.",,,,,,,aAuto,nOpcAuto,,)	// "Cadastro do Participante"
Else
Private cCadastro	:= STR0001 //"Cadastro do Participante"

DBSelectArea(cAlias)
DBSetOrder(1)
MBrowse(6,1,22,75,cAlias)
EndIf

Return  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³a016TabRel³ Autor ³Marco Bianchi          ³ Data ³ 17/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Apresenta tela para escolha do codigo de relacionamento     ³±±
±±³          ³no cadastro de participantes.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function a016TabRel()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oListBox
Local oPanel

Local aPars     := {}

Local cVar	    := Upper( Alltrim( ReadVar() ) )
Local cConteudo := ""
Local cCodigo   := ""

Local nPosList  := 0

Local lOk		:= .T.


If cVar == "M->CVC_CODREL"
	lOk       := .F.
	cConteudo := &(ReadVar())

	If !Empty(cConteudo)
		nPosList := ASCAN(aCodRel, {|aVal| aVal[1] == Upper(cConteudo)})
	EndIf
	
	
	DEFINE MSDIALOG oDlg FROM 00,00 TO 290,490 PIXEL TITLE OemToAnsi("Pesquisa"/*STR0320*/) //"Pesquisa"

	oPanel := TPanel():New(1,1,'',oDlg,oDlg:oFont, .T., .T.,,,204,140,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	
	@ 0,0 BITMAP oBmp RESNAME "PROJETOAP" Of oDlg SIZE 100,300 NOBORDER When .F. PIXEL
	oListBox := TWBrowse():New( 40,05,204,140,,{STR0018,STR0019},,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,)  //"Codigo"###"Relacionamento"
	oListBox:SetArray(aCodRel)
	oListBox:bLine := { ||{aCodRel[oListBox:nAT][1],aCodRel[oListBox:nAT][2]}}
	oListBox:bLDblClick := { ||Eval(oConf:bAction), oDlg:End()}
	oListBox:Align := CONTROL_ALIGN_ALLCLIENT
	
	@ 115,05 BUTTON oConf Prompt STR0020 SIZE 45 ,10   FONT oDlg:oFont ACTION (lOk:=.T.,cCodigo:=aCodRel[oListBox:nAT][1],oDlg:End())  OF oDlg PIXEL //'Confirma'
	@ 115,55 BUTTON oCanc Prompt STR0021 SIZE 45 ,10   FONT oDlg:oFont ACTION (lOk:=.F.,oDlg:End())  OF oDlg PIXEL //'Cancela'
	
	If nPosList > 0
		oListBox:nAT   := nPosList
		oListBox:bLine := { ||{aCodRel[oListBox:nAT][1],aCodRel[oListBox:nAT][2]}}
		oConf:SetFocus()
	EndIf
	
	ACTIVATE MSDIALOG oDlg CENTERED

	If lOk
		M->CVC_CODREL := cCodigo	
	Else
		M->CVC_CODREL := cConteudo
	EndIf
EndIf

Return lOk


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Ctb016ConsºAutor  ³Eduardo Nunes Cirqueira º Data ³  20/08/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorno para consulta padrao especifica (016) acima             º±±
±±º          ³                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb016Cons()

Return (M->CVC_CODREL)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Ctb016ValidºAutor  ³Eduardo Nunes Cirqueira º Data ³  20/08/07  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validar a digitacao do campo Cod. Relacionamento                º±±
±±º          ³                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb016Valid()
Local lOk := ( ASCAN(aCodRel, {|aVal| aVal[1] == Upper(M->CVC_CODREL)}) > 0 )
If !lOk
	MsgAlert( STR0022 )
EndIf

Return lOk


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³a016CGC   ³ Autor ³ Marco Bianchi         ³ Data ³ 17/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Validacao do campo CVC_CGC. Qd Pessoa="J" nao permitir      ³±±
±±³          ³entrada de CPF                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastro de Participantes                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   
Function a016CGC(cTipPes,cCNPJ)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea     := GetArea()
Local aAreaCVC  := CVC->(GetArea())
Local lRetorno  := .T.
Local cCNPJBase := ""
DEFAULT cCNPJ   := &(ReadVar())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida o tipo de pessoa                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipPes == "F" .And. !(Len(AllTrim(cCNPJ))==11)
	Help(" ",1,"CPFINVALID")
	lRetorno := .F.
ElseIf cTipPes == "J" .And. !(Len(AllTrim(cCNPJ))==14)  
	Help(" ",1,"CGC")     
	lRetorno := .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida a duplicidade do CGC                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno .And. Pcount() > 1 
	If cTipPes == "J"
		dbSelectArea("CVC")
		dbSetOrder(2)
		If MsSeek(xFilial("CVC")+cCNPJ)
			Aviso(STR0002,STR0003+CVC->CVC_CODPAR+"/"+CVC->CVC_NOME+".",{"Ok"})//"Atenção"###"O CNPJ informado já foi utilizado para o contabilista "
			lRetorno := .F.
		EndIf
		If lRetorno
			cCNPJBase := SubStr(cCNPJ,1,8)
			dbSelectArea("CVC")
			dbSetOrder(2)
			If MsSeek(xFilial("CVC")+cCNPJBase) .And. M->CVC_CODPAR <> CVC->CVC_CODPAR
				If Aviso(STR0002,STR0003+CVC->CVC_CODPAR+" - "+CVC->CVC_NOME+".",{STR0004,STR0005},2)==2//"Atenção"###"O CNPJ informado já foi utilizado para o contabilista "###"Aceitar"###"Cancelar"
				   lRetorno := .F.
				EndIf
			EndIf
		EndIf
	Else
		dbSelectArea("CVC")
		dbSetOrder(2)
		If MsSeek(xFilial("CVC")+cCNPJ) .And. M->CVC_CODPAR <> CVC->CVC_CODPAR
			If Aviso(STR0002,STR0006+CVC->CVC_CODPAR+" - "+CVC->CVC_NOME+".",{STR0004,STR0005},2)==2//"Atenção"###"O CPF informado já foi utilizado no Contabilista "###"Aceitar"###"Cancelar"
			   lRetorno := .F.
			EndIf
		EndIf		
	EndIf
EndIf

RestArea(aAreaCVC)
RestArea(aArea)
Return lRetorno   

Static Function MenuDef()
Local aRotina := {}

	AADD(aRotina,{STR0029,  "AxPesqui",0,1}) //Pesquisar
	AADD(aRotina,{STR0028,  "AxVisual",0,2}) //Visualizar
	AADD(aRotina,{STR0027,  "CTB016INC",0,3}) //Incluir
	AADD(aRotina,{STR0026,  "CTB016ALT",0,4})  //Alterar
	AADD(aRotina,{STR0025,  "CTB016DEL",0,5}) //Excluir


Return aRotina

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CTB016INC ³ Autor ³ Alfredo Medrano       ³ Data ³06/04/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Inserta en CV0 los NIT de nuevos Participantes Colombia     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA016 Cadastro de Participantes                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/  
Function CTB016INC(cAlias, nReg, nOpc)
Local lRet	:= .T.
Local nOpcao := 0  
Local cItm   := ""

nOpcao := AxInclui(cAlias, nReg, nOpc,/*aAcho*/,/*cFunc*/,/*aCpos*/,"CTB016TdOk()",.T.,/*cTransact*/,/*aButtons*/,;
		 /*aParam*/,/*aAuto*/,/*lVirtual*/,/*lMaximized*/,/*cTela*/,/*lPanelFin*/,/*oFather*/,/*aDim*/,/*uArea*/)

If nOpcao == 1 .and. cPaisLoc =="COL"    
	IF CVC->CVC_TIPDOC=="31" //Tipo de Documento de Indetificacion NIT	

		cItm := GetSxENum( "CV0", "CV0_ITEM" )
		Begin Transaction	
			RecLock("CV0",.T.) 	  
			CV0->CV0_FILIAL :=xFilial("CV0")
			CV0->CV0_PLANO  :="01"
			CV0->CV0_ITEM   :=cItm
			CV0->CV0_CLASSE := "2"
			CV0->CV0_NORMAL := "2"
			CV0->CV0_DTIEXI := dDatabase
			CV0->CV0_TIPO00 := "04"
			CV0->CV0_TIPO01 := CVC->CVC_TIPDOC
			CV0->CV0_DESC   := CVC->CVC_NOME
			CV0->CV0_CODIGO := CVC->CVC_CGC
			CV0->CV0_COD   := CVC->CVC_CODPAR
			MsUnlock()	   	
			ConfirmSX8()    		    	
		End Transaction
		
	Endif						
Endif
    
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CTB016ALT ³ Autor ³ Alfredo Medrano       ³ Data ³06/04/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³altera en CV0 el Cod Participante y el nombre               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA016 Cadastro de Participantes                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/  
Function CTB016ALT(cAlias, nReg, nOpc)
Local lRet 	:= .T.
Local nOpcA	:= 0  
Local cCod 	:= ""

nOpcA := AxAltera(cAlias,nReg,nOpc,/*aAcho*/,/*aCpos*/,/*nColMens*/,/*cMensagem*/,"CTB016TdOk()"	,/*cTransact*/,;
		/*cFunc*/,/*aButtons*/, /*aParam*/  ,/*aRotAuto*/,/*lVirtual*/)

If nOpcA == 1 .AND. cPaisLoc =="COL" 
	cCod:=Space(TamSx3("CV0_COD")[1])
	cCod:= PADR( CVC->CVC_CODPAR,TamSx3("CV0_COD")[1]," ")   
	IF CVC->CVC_TIPDOC=="31" //Tipo de Documento de Indetificacion NIT	   
		DbSelectArea("CV0")
		DbSetOrder(4)//CV0_FILIAL+CV0_COD+CV0_TIPO00+CV0_CODIGO
		If DbSeek(xFilial("CV0")+cCod+'04'+CVC->CVC_CGC)
			RecLock("CV0",.F.)
			CV0->CV0_DESC	:= CVC->CVC_NOME
			CV0->CV0_COD	:= CVC->CVC_CODPAR
			MsUnlock()
		ElseIf DbSeek(xFilial("CV0")+cCod+'04')
			RecLock("CV0",.F.)
			CV0->CV0_DESC	:= CVC->CVC_NOME
			CV0->CV0_COD	:= CVC->CVC_CODPAR
			CV0->CV0_CODIGO := CVC->CVC_CGC
			MsUnlock()
		EndIf
	EndIf						
Endif
   
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CTB016TdOk³ Autor ³ Alfredo Medrano       ³ Data ³06/04/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valida campo CVC_CGC dependiendo CVC_TIPDOC                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³  AxAltera                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
Function CTB016TdOk()
Local lRet := .T.

	If cPaisLoc == 'COL'
		IF M->CVC_TIPDOC=="31" //Tipo de Documento de Indetificacion NIT
			
			IF EMPTY(M->CVC_CGC)	 
				MsgAlert(OemToAnsi(STR0023)  )// "Se debe indicar el campo NIT del Participante"                                        
			    lRet:=.F.
			Endif                         
		Else
			IF !EMPTY(M->CVC_CGC)	                                          
				MsgAlert(OemToAnsi(STR0024))//"El campo NIT del Participante debe estar Vacio"
			   lRet:=.F.
			Endif    
		Endif
	Endif

return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CTB016DEL ³ Autor ³ Alfredo Medrano       ³ Data ³20/04/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Borra Registros de Tabla CV0                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA016 Cadastro de Participantes                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
Function CTB016DEL(cAlias, nReg, nOpc)
Local lRet 	:= .T.
Local nOpcA	:= 0  
Local cCod 	:= ""

nOpcA := AxDeleta(cAlias,nReg,nOpc,/*cTransact*/,/*cTransact*/,/*aCpos*/,/*aButtons*/, /*aParam*/  ,/*aRotAuto*/)

If nOpcA == 2	 .AND. cPaisLoc =="COL" 
	cCod:= Space(TamSx3("CV0_COD")[1])
	cCod:= PADR( CVC->CVC_CODPAR,TamSx3("CV0_COD")[1]," ")  
	DbSelectArea("CV0")
	DbSetOrder(4)//CV0_FILIAL+CV0_COD+CV0_TIPO00+CV0_CODIGO
	If DbSeek(xFilial("CV0")+cCod+'04'+CVC->CVC_CGC)
		RecLock("CV0",.F.)
		dbDelete()
		MsUnlock()
	EndIf       						
Endif
   
Return lRet
