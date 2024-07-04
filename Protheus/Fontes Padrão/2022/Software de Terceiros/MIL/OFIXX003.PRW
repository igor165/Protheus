// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 16     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "OFIXX003.ch"
#include "Protheus.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OFIXX003   | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Liberacao de Venda                                           |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina / AutoPecas                                          |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIXX003(cAlias,nReg,nOpc)
Local aObjects 	:= {}

Local aSizeAut	:= MsAdvSize(.t.)
// Variaveis da Enchoice
Local aCpos := {}
Local nModelo := 3
Local cTudoOk := ".t."
Local lF3 := .f.
Local lMemoria := .t.
Local lColumn := .f.
Local cATela := ""
Local lNoFolder := .t.
Local lProperty := .f.

Local i := 0
//
Local lVS7DIVERG  := VS7->(FieldPos("VS7_DIVERG")) > 0

Private aCpoEncS := {}
Private oOk := LoadBitmap( GetResources(), "LBTIK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
Private aMemos   := {{"VS6_OBSMEM","VS6_OBSERV"}}
Private lProcessa := .t.
//Private aNewBot := {}                                          //BOBY FNC-17983 - 17/08/10
Private cTipLib := "1"                                          // boby  (pecas)
Private aNewBot := {{"PRECO", { ||FS_OX03RGER() } ,STR0028}}   // boby

Private nPosRecP := 0 //para ser utilizado na função RetbLine (posicionando na tabela VS7)
Private nPosRecS := 0 //para ser utilizado na função RetbLine (posicionando na tabela VS7)
//
Private lVS7SemProb := AllTrim(GetNewPar("MV_MIL0131", "0")) == "1" // Cria/Mostra VS7 de todos os Itens se pelo menos 1 tiver problema de Margem ou Desconto
Private oVerme := LoadBitmap( GetResources() , "BR_VERMELHO" )
Private oVerde := LoadBitmap( GetResources() , "BR_VERDE" )
Private lCkFilVerme := .t.
Private lCkFilVerde := IIf(lVS7SemProb,.t.,.f.)

For i:=1 to Len(aNewBot)                                        // boby
	Private cFunc&(alltrim(Str(i))) := aNewBot[i,2]            // boby
Next                                                            // boby

Private lTemPedPec := .t.
Private lTemPedSrv := .t.

Private aHeaderP:= {}
Private aTitulo := {}
Private aSizes  := {}
Private aLines  := {}

Private aHeadS  := {}
Private aTituloS:= {}
Private aSizesS := {}
Private aLinesS := {}

Private oGetPecas
Private aHeadVS3 := {}
Private aColsVS3 := {}

If ! Empty(VS6->VS6_DATAUT) .or. ! Empty( VS6->VS6_DATREJ )
	FMX_HELP("OX003JALIB",STR0039) // "Solicitação de liberação de venda já foi liberada ou rejeitada."
	Return .f.
Endif

If ExistBlock("OX003PRIM") // Ponto de Entrada para criacao de Botao na Enchoicebar
	if !ExecBlock("OX003PRIM",.f.,.f.,{cAlias,nReg,nOpc})
		Return .f.
	else
		// Toda a tratativa fica, então, a cargo do programa OX003PRIM. Nenhuma liberação ou avanço de fase será
		// realizado pelo programa padrão (OX003LIB). Realizado para o projeto SHARK em 06/11/09. (Luis Delorme)
		return .t.
	Endif
Endif
//
If ExistBlock("PEOX003BTN") // Ponto de Entrada para criacao de Botao na Enchoicebar
	ExecBlock("PEOX003BTN")
Endif
//################################################################
//# Especifica o espacamento entre os objetos principais da tela #
//################################################################
// Tela Superior - Enchoice do VS1 - Tamanho vertical fixo
AAdd( aObjects, { 0,	100, .T., .F. } )
// Tela Dois - Folder (Pecas) - Tamanho vertical VARIAVEL
AAdd( aObjects, { 0,	50, .T., .T. } )
// Tela Tres - Folder (Servicos) - Tamanho vertical VARIAVEL
AAdd( aObjects, { 0,	50, .T., .T. } )
//
If lVS7DIVERG
	// Tela Quatro - Legenda - Tamanho vertical VARIAVEL
	AAdd( aObjects, { 0,	10, .T., .F. } )
Endif
//
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ],aSizeAut[ 3 ] ,aSizeAut[ 4 ], 3, 3 }// Tamanho total da tela
aPosObj := MsObjSize( aInfo, aObjects ) // Monta objetos conforme especificacoes
//###############################################
//# Cria variaveis M->????? da Enchoice do VS6  #
//###############################################
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VS6")
//
aCpoEncS  := {} 	// ARRAY DE CAMPOS DA ENCHOICE
aCpos  := {} 		// ARRAY DE CAMPOS DA ENCHOICE NAO EDITAVEIS
//
cVS6nEdit := ""
cVS6nMostra := ""
//
While !Eof().and.(x3_arquivo=="VS6")
	If X3USO(x3_usado).and.cNivel>=x3_nivel .and. !(Alltrim(x3_campo)+"," $ cVS6nMostra)
		AADD(acpoEncS,x3_campo)
		if x3_campo != "VS6_OBSERV"
			aAdd(aCpos,"VS6_OBSERV")
		endif
	EndIf
	If x3_context == "V"
		&("M->"+x3_campo):= CriaVar(x3_campo)
	Else
		&("M->"+x3_campo):= &("VS6->"+x3_campo)
	EndIf
	DbSkip()
Enddo
//###################################################################
//# Cria variaveis de memoria, aHeader e aCols da GetDados de Pecas #
//###################################################################
// Campos que aparecerao na aCols de Pecas (caso estejam sendo usados e exista nivel para tal)
cVS7nMostra := ""
//
nUsadoP:=1
//
DBSelectArea("SX3")
DBSeek("VS7")
If lVS7DIVERG
	Aadd(aHeaderP,"" )
	Aadd(aLines,"IIf(!Empty(aColsP[oLbItens:nAt,2]),IIF(aColsP[oLbItens:nAt,1],oVerme,oVerde),'')")
	Aadd(aTitulo,"")
	Aadd(aSizes,1)
Else
	aHeaderP:= {""}
	aTitulo := {""}
	aSizes  := {1}
	aLines  := {"IIF(aColsP[oLbItens:nAt,1],oOk,oNo)"}
Endif
cVS7nMostra = "VS7_NUMIDE,VS7_SEQUEN,VS7_TIPAUT,VS7_GRUSER,VS7_CODSER,VS7_TIPSER,VS7_ITELIB,VS7_DIVERG"
While !Eof().And.(x3_arquivo=="VS7")
	If  X3USO(x3_usado) .And. cNivel>=x3_nivel .and. !(Alltrim(x3_campo)+"," $ cVS7nMostra)
		nUsadoP:=nUsadoP+1
		if x3_context != "V"
			Aadd(aHeaderP,SX3->X3_CAMPO )
			aAdd(aLines,"Transform(aColsP[oLbItens:nAt,"+Alltrim(STR(nUsadoP))+"],'"+Alltrim(SX3->X3_PICTURE)+"')")
		else
			Aadd(aHeaderP,SX3->X3_RELACAO)
			aAdd(aLines,SX3->X3_RELACAO)
		endif
		Aadd(aTitulo,RetTitle(SX3->X3_CAMPO))
		Aadd(aSizes,(TamSX3(SX3->X3_CAMPO)[1]+TamSX3(SX3->X3_CAMPO)[2]) * 3)
	EndIf
	DbSkip()
EndDo

Aadd(aHeaderP,"VS7->(RecNo())")
nUsadoP:=nUsadoP+1
nPosRecP := Len(aHeaderP) // para ser utilizado na função RetbLine (posicionando na tabela VS7)

///////////
//#####################################################################
//# Cria variaveis de memoria, aHeader e aCols da GetDados de Servicos#
//#####################################################################
// Campos que aparecerao na aCols de Pecas (caso estejam sendo usados e exista nivel para tal)
cVS7nMostra := ""
//
nUsadoS:=1
//
If lVS7DIVERG
	Aadd(aHeadS,"" )
	Aadd(aLinesS,"IIf(!Empty(aColsS[oLbItensS:nAt,2]),IIF(aColsS[oLbItensS:nAt,1],oVerme,oVerde),'')")
	Aadd(aTituloS,"")
	Aadd(aSizesS,1)
Else
	aHeadS  := {""}
	aTituloS:= {""}
	aSizesS := {1}
	aLinesS := {"IIF(aColsS[oLbItensS:nAt,1],oOk,oNo)"}
Endif

DBSelectArea("SX3")
DBSeek("VS7")
cVS7nMostra = "VS7_NUMIDE,VS7_SEQUEN,VS7_TIPAUT,VS7_GRUITE,VS7_CODITE,VS7_ITELIB,VS7_MARLUC,VS7_MARPER,VS7_DESITE,VS7_DIVERG"
While !Eof().And.(x3_arquivo=="VS7")
	If  X3USO(x3_usado) .And. cNivel>=x3_nivel .and. !(Alltrim(x3_campo)+"," $ cVS7nMostra)
		nUsadoS:=nUsadoS+1
		if x3_context != "V"
			Aadd(aHeadS,SX3->X3_CAMPO )
			aAdd(aLinesS,"Transform(aColsS[oLbItensS:nAt,"+Alltrim(STR(nUsadoS))+"],'"+Alltrim(SX3->X3_PICTURE)+"')")
		else
			Aadd(aHeadS,SX3->X3_RELACAO )
			aAdd(aLinesS,SX3->X3_RELACAO)
		endif
		Aadd(aTituloS,RetTitle(SX3->X3_CAMPO))
		Aadd(aSizesS,(TamSX3(SX3->X3_CAMPO)[1]+TamSX3(SX3->X3_CAMPO)[2]) * 3)
	EndIf
	DbSkip()
EndDo

Aadd(aHeadS,"VS7->(RecNo())")
nUsadoS:=nUsadoS+1
nPosRecS := Len(aHeadS) // para ser utilizado na função RetbLine (posicionando na tabela VS7)
//
aColsP := {}
aColsS := {}
aTemp  := {}

// Cria Acols de Peças e Serviços
If lVS7SemProb .and. lVS7DIVERG
	OX0030012_FiltraItens("2",nOpc,.f.) //  levanta Todos os Itens
Else
	OX0030012_FiltraItens("1",nOpc,.f.) //  levanta apenas Itens com Divergencia
Endif

//####################################################
//# Montagem da tela da liberacao                    #
//####################################################
oDlg := MSDIALOG() :New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],cCadastro,,,,,,,,,.t.)
//#####################################################
//# Monta a enchoice do VS1 com os campos necessarios #
//#####################################################
aPosEnchoice := aClone(aPosObj[1])
oEnch := MSMGet():New( cAlias ,nReg,nOpc ,,,,aCpoEncS, aPosEnchoice,aCpos,nModelo,,,cTudoOk,oDlg,lF3,lMemoria,lColumn,caTela,lNoFolder, lProperty,,,,.t.)
//#############################################################################
//# ListBox  de Pecas                                                         #
//#############################################################################
@ aPosObj[2,1],aPosObj[2,2] LISTBOX oLbItens FIELDS HEADER "" ;
SIZE aPosObj[2,4] - aPosObj[2,2], aPosObj[2,3] - aPosObj[2,1] OF oDlg PIXEL
oLbItens:aHeaders := aTitulo
oLbItens:aColSizes := aSizes
oLbItens:SetArray(aColsP)

oLbItens:bLine := { || RetbLine("P") }

//#############################################################################
//# ListBox  de servicos                                                      #
//#############################################################################
@ aPosObj[3,1],aPosObj[3,2] LISTBOX oLbItensS FIELDS HEADER "" ;
SIZE aPosObj[3,4] - aPosObj[3,2], aPosObj[3,3] - aPosObj[3,1] OF oDlg PIXEL
oLbItensS:aHeaders := aTituloS
oLbItensS:aColSizes := aSizesS
oLbItensS:SetArray(aColsS)

oLbItensS:bLine := { || RetbLine("S") }

//#############################################################################
//# Legenda                                                      #
//#############################################################################
If lVS7DIVERG
	If lVS7SemProb
		@ aPosObj[4,1]+2,010 CHECKBOX oCkFilVERME VAR lCkFilVerme PROMPT "" OF oDlg ON CLICK OX0030012_FiltraItens("1",nOpc,.t.) SIZE 08,08 PIXEL
	Endif
	@ aPosObj[4,1]+2,019 BITMAP oxVerm RESOURCE "BR_VERMELHO" OF oDlg NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPosObj[4,1]+2,028 SAY STR0037 SIZE 120,8 OF oDlg PIXEL COLOR CLR_BLUE //"Itens com Divergência de Desconto e/ou Margem"
	If lVS7SemProb
		@ aPosObj[4,1]+2,210 CHECKBOX oCkFilVERDE VAR lCkFilVerde PROMPT "" OF oDlg ON CLICK OX0030012_FiltraItens("0",nOpc,.t.) SIZE 08,08 when lVS7SemProb PIXEL
		@ aPosObj[4,1]+2,219 BITMAP oxVerd RESOURCE "BR_VERDE" OF oDlg NOBORDER SIZE 10,10 when .f. PIXEL
		@ aPosObj[4,1]+2,228 SAY STR0038 SIZE 120,8 OF oDlg PIXEL COLOR CLR_BLUE //"Itens sem Divergência de Desconto e/ou Margem"
	Endif
Endif
//
If VS6->VS6_TIPAUT == "1" .or. !Empty(VS6->VS6_NUMORC)
	VS1->(DBSetOrder(1))
	VS1->(DBSeek(xFilial("VS1")+VS6->VS6_NUMORC))
	OX0030021_Levanta_aHeader_aCols_Orcamento()
	oTPanP1 := TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,0,0,.T.,.F.)
	oGetPecas := MsNewGetDados():New(0, 0, 0 ,0,3,/*cLinOKP*/,/*cTudoOkP*/,,/*aAlterP*/,0,999,/*cFieldOkP*/,,/*cDelPecOk*/,oTPanP1,aHeadVS3,aColsVS3 ) // Objeto utilizado para montar o MAPA de AVALIAÇÃO
EndIf
//
oDlg:bInit := {|| EnchoiceBar(oDlg, { || If(OX003TUDOK(nOpc),OX003LIB(nOpc),.t.) } , { || nOpca := 0,lRet:=OX003SAIR(nOpc) },,aNewBot )}
oDlg:Activate()
//
Return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OFIXX003   | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Liberacao de Venda                                           |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina / AutoPecas                                          |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX003TUDOK(nOpc)

Local nCntFor
Local lVS7DIVERG := VS7->(FieldPos("VS7_DIVERG")) > 0
Local lLibOK     := .f.
//
lProcessa := .t.
//

If nOpc == 2
	Return .t. 
EndIf

DBSelectArea("VAI")
DBSetOrder(4)
DBSeek(xFilial("VAI")+__cUserId)
//
If	lTemPedPec
	
	// Ponto de entrada para tratamento da Alçada de Liberação de Margem de Peças
	if ExistBlock("OX003TO1")
		
		if !ExecBlock("OX003TO1",.f.,.f.)
			return .f.
		Endif
		lLibOK := .t.
		
	Else
		
		For nCntFor:=1 to Len(aColsP)
			If !lVS7DIVERG .or. (lVS7DIVERG .and. aColsP[nCntFor,1]) // não tem o campo VS7_DIVERG OU tem o campo e tem divergencia
				if VAI->(FieldPos("VAI_ADEPEC")) > 0
					if aColsP[nCntFor,5] > VAI->VAI_ADEPEC .or. aColsP[nCntFor,9] < VAI->VAI_AMLPEC
						MsgInfo(STR0036,STR0033) // "Usuário não possui alçada para esta operação."
						return .f.
					endif
				endif
				lLibOk := .t.
			endif
		Next
		
	Endif
	
Endif

If	lTemPedSrv
	For nCntFor:=1 to Len(aColsS)
		If !lVS7DIVERG .or. (lVS7DIVERG .and. aColsS[nCntFor,1]) // não tem o campo VS7_DIVERG OU tem o campo e tem  divergencia
			lLibOk := .t.
		endif
	Next
Endif

If lLibOk
	if !MsgYesNo(STR0034,STR0033) // Deseja liberar a venda?
		return .f.
	Endif
Else
	// Não há porque entrar aqui se não houver o PE OX003TO1 compilado no cliente e mesmo compilado, dependendo da customização do cliente, não irá entrar aqui 
	if !Empty(VS6->VS6_NUMORC)
		if MsgYesNo(STR0035,STR0033) // "A venda não foi liberada. Deseja reabrir o orçamento?"
			OXI001REVF(VS6->VS6_NUMORC, "0")
		endif
	endif
	lProcessa := .f.
endif
//
return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OX003LIB   | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Liberacao de Venda                                           |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina / AutoPecas                                          |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX003LIB(nOpc)
Local nCntFor
if nOpc == 2 .or. !lProcessa
	oDlg:end()
	return .t.
endif

// Ponto de entrada chamado apos clicar em Reabrir Orçamento
if ExistBlock("OX003ALB")
	lRetorn := ExecBlock("OX003ALB",.f.,.f.)
	if !lRetorn
		return .f.
	Endif
Endif

BEGIN TRANSACTION

dbSelectArea("VS6")
RecLock("VS6",.f.)
VS6->VS6_LIBPRO := substr(cUsuario,7,15)
VS6->VS6_DATAUT := dDataBase
VS6->VS6_HORAUT := val(substr(time(),1,2)+substr(time(),4,2))
cVar := aMemos[1][2]
MSMM(VS6->VS6_OBSMEM,TamSx3("VS6_OBSERV")[1],,&cVar,1,,,"VS6","VS6_OBSMEM")
VS6->(MsUnlock())
VS6->(dbGoTo(VS6->(Recno()))) // Desposiciona para atualizar tabela para SELECT retornar corretamente
// Pecas
DbSelectArea("VS7")
For nCntFor:=1 to Len(aColsP)
	If DbSeek(xFilial("VS7")+VS6->VS6_NUMIDE+aColsP[nCntFor,2])
		RecLock("VS7",.f.)
		If aColsP[nCntFor,1] == .t.
			VS7->VS7_ITELIB := "S"
		Else
			VS7->VS7_ITELIB := "N"
		Endif
		MsUnlock()
	Endif
Next
// Servicos
DbSelectArea("VS7")
For nCntFor:=1 to Len(aColsS)
	If DbSeek(xFilial("VS7")+VS6->VS6_NUMIDE+aColsS[nCntFor,2])
		RecLock("VS7",.f.)
		If aColsS[nCntFor,1] == .t.
			VS7->VS7_ITELIB := "S"
		Else
			VS7->VS7_ITELIB := "N"
		Endif
		MsUnlock()
	Endif
Next
//
If !Empty(VS6->VS6_NUMORC)
	VS1->(DBSetOrder(1))
	VS1->(DBSeek(xFilial("VS1")+VS6->VS6_NUMORC))
	If VS1->VS1_TIPORC == "2"
		// Se for orcamento de oficina verifica se a liberacao de peca E servico
		// foi aprovada para atualizar status da OS
		If !Empty(VS1->VS1_NUMLIB) .and. (VS1->(FieldPos("VS1_NUMLIS")) > 0 .and. !Empty(VS1->VS1_NUMLIS))
			cSQL := "SELECT COUNT(*) NCONT"
			cSQL +=  " FROM " + RetSQLName("VS6") + " VS6"
			cSQL += " WHERE VS6.VS6_FILIAL = '" + xFilial("VS6") + "'"
			cSQL +=   " AND VS6.VS6_NUMIDE IN ('" + VS1->VS1_NUMLIB + "','" + VS1->VS1_NUMLIS + "')"
			cSQL +=   " AND VS6.VS6_DATAUT = '        '"
			cSQL +=   " AND VS6.D_E_L_E_T_ = ' '"
			If FM_SQL( cSQL ) == 0
				OFIXI001(VS6->VS6_NUMORC)
			EndIf
		Else
			OFIXI001(VS6->VS6_NUMORC)
		EndIf
	Else
		aRet012 := OFIXI001(VS1->VS1_NUMORC)
		cMsgFase := aRet012[1]
		lRollback := aRet012[2]
		lRollObrig := aRet012[3]
		lAbortProc := aRet012[4]
		
		if cMsgFase != ""
			MsgInfo(cMsgFase,STR0033)
			if VS1->VS1_STATUS == "O" .or. ;
				(VS1->VS1_STATUS == "R" .and. lAbortProc)
				MsgInfo(STR0013,STR0012)
				reclock("VS1",.f.)
				cVS1StAnt := VS1->VS1_STATUS
				VS1->VS1_STATUS := "2"
				msunlock()
				If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
					OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0004 ) // Grava Data/Hora na Mudança de Status do Orçamento / Liberação de Venda
				EndIf
				If FindFunction("FM_GerLog")
					//grava log das alteracoes das fases do orcamento
					FM_GerLog("F",VS1->VS1_NUMORC,,VS1->VS1_FILIAL,cVS1StAnt)
				EndIF
				Return .f.
			endif
		endif
	EndIf
EndIf
END TRANSACTION
//
oDlg:end()
//
return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OX003SAIR  | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Liberacao de Venda                                           |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina / AutoPecas                                          |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX003SAIR(nOpc)
oDlg:end()
return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OX003SAIR  | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Liberacao de Venda                                           |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina / AutoPecas                                          |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function RetbLine(cPar)

Local aRet := {}
Local nCntFor
If cPar == "P" // Pecas
	If nPosRecP > 0 .and. aColsP[oLbItens:nAt,nPosRecP] > 0
		VS7->(DbGoTo(aColsP[oLbItens:nAt,nPosRecP]))
	Endif
	for nCntFor := 1 to len(aLines)
		aAdd(aRet, &(aLines[nCntFor]) )
	next
Else //cPar == "S" // Servicos
	If nPosRecS > 0 .and. aColsS[oLbItensS:nAt,nPosRecS] > 0
		VS7->(DbGoTo(aColsS[oLbItensS:nAt,nPosRecS]))
	Endif
	for nCntFor := 1 to len(aLinesS)
		aAdd(aRet, &(aLinesS[nCntFor]) )
	next
Endif
return aRet


///////////////////////////////////////////////////////////////////////////////
// Funcao   : FS_OX03RGER                                                    //
// Descricao: para mostrar botão para visualização da avaliacao de resultado //
//            na liveração do desconto.                                      //
// Tirada do OFIOM170 - BOBY FNC-17983 - 17/08/10                            //
///////////////////////////////////////////////////////////////////////////////
Function FS_OX03RGER()

Local nCont     := 0
Local bCampo    := { |nCPO| Field(nCPO) }

Local aSomaStru := {}
Local x			:= 0
Local _ni		:= 0
Local n_		:= 0
Local nCnt		:= 0
Local cNumOrc := ""
Private cSimVda := " "
Private cCodMap
Private cOutMoed
Private cSimOMoe
Private aStru   := {}

cTipLib := VS6->VS6_TIPAUT
cNumOrc := VS6->VS6_NUMORC

If cTipLib == "1" .or. !Empty(cNumOrc)   //Pecas ou orçamento
	
	Private aColsP
	Private aHeaderP
	Private nUsadoP
	Private cCodVen
	Private nTotNot,nTotDes, nTotOrc
	Private aColsc,aIteParc
	cSimVda := "P" // Pecas
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no VS1 p/ pegar o Vendedor                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	DbSelectArea("VS1")
	DbSeek(xFilial("VS1")+VS6->VS6_NUMORC)
	For x:=1 to FCount()
		&("M->"+FieldName(x)) := &(FieldName(x))
	Next
	
	DbSelectArea("SA3")
	DbSetOrder(1)
	DbSeek(xFilial("SA3")+VS1->VS1_CODVEN)
	cCodVen := SA3->A3_COD
	nTotDes := VS1->VS1_VALDES
	nTotNot := VS1->VS1_VTOTNF
	nTotOrc := VS1->VS1_VTOTNF
	
	aHeaderP := aClone(oGetPecas:aHeader)
	aColsP := aClone(oGetPecas:aCols)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o aCols da Entrada                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	nUsadoC:=0
	DbSelectArea("SX3")
	DbSeek("VS9")
	aHeaderC:={}
	While !Eof().And.(x3_arquivo=="VS9")
		If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ( Trim(SX3->X3_CAMPO) $ "VS9_TIPPAG#VS9_DESPAG#VS9_DATPAG#VS9_VALPAG#VS9_REFPAG")
			nUsadoC++
			Aadd(aHeaderC,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal,x3_valid,;
			x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
			wVar := "M->"+x3_campo
			&wVar := CriaVar(x3_campo)
		Endif
		DbSkip()
	EndDo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o aCols da Entrada                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aColsC:={Array(nUsadoC+1)}
	aColsC[1,nUsadoC+1]:=.F.
	For _ni:=1 to nUsadoC
		aColsC[1,_ni]:=CriaVar(aHeaderC[_ni,2])
	Next

	VISUALIZA := .t. // VARIAVEL UTILIZADA NO OFIXX001
	EXCLUI    := .f. // VARIAVEL UTILIZADA NO OFIXX001
	OX001AVARES(2) // AVALIAÇÃO DE RESULTADO DO ORCAMENTO POR FASES

Elseif cTipLib == "2"
	
	Private aStruP  := {}
	Private aStruS  := {}
	Private aStruO  := {}
	Private lCalcTot:= .f.
	Private cCpoDiv := "    1"
	Private cNumIde
	cSimVda := "S"
	cTipAva := "4"
	
	If !PERGUNTE("ATDOFI")
		return .t.
	EndIf
	
	cMapPecas := Mv_Par01
	cMapSrvcs := Mv_Par02
	cMapOdSrv := Mv_Par03
	
	cOutMoed := GetMv("MV_SIMB"+Alltrim(GetMv("MV_INDMFT")))
	cSimOMoe := Val(Alltrim(GetMv("MV_INDMFT")))
	cNumLib := VS6->VS6_NUMIDE
	*******************************************************************************
	nNumero := VS6->VS6_NUMIDE
	cParPro := "1"
	cContChv:= "VEC_NUMORC"
	cParTem := ""
	&&cArqPes := ""
	
	*** Avaliacao de Pecas ********************************************************
	
	aSomaStru := {}
	cCpoDiv := "    1"
	lCalcTot := .f.
	
	If FG_SEEK("VSY","VS6->VS6_NUMIDE",1,.f.)
		
		DbSelectArea("VSY")
		
		While VS6->VS6_NUMIDE == VSY->VSY_NUMIDE .and. VSY->VSY_FILIAL == xFilial("VSY") .and. !eof()
			
			DbSelectArea("VOQ")
			FG_Seek("VOQ","cMapPecas",1,.f.)
			FG_SEEK("SB1","VSY->VSY_GRUITE+VSY->VSY_CODITE",7,.f.)
			nPosVet := aScan(aStruP,{|x| x[3]+x[7] == SB1->B1_COD+VOQ->VOQ_CODIGO})
			ncont := nPosVet
			while cMapPecas == VOQ->VOQ_CODMAP .and. VOQ->VOQ_FILIAL == xFilial("VOQ") .and. !eof()
				
				If VOQ->VOQ_INDATI != "1" && Sim
					DbSkip()
					Loop
				Endif
				
				cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ->VOQ_DESAVA,VOQ->VOQ_DESAVA)
				
				If nPosVet == 0
					aadd(aStruP,{ VSY->VSY_NUMOSV,,SB1->B1_COD,;
					VOQ->VOQ_CLAAVA,cDescVOQ,VOQ->VOQ_ANASIN,VOQ->VOQ_CODIGO,VOQ->VOQ_SINFOR,0,0,SB1->B1_GRUPO+" "+SB1->B1_CODITE,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ->VOQ_FUNADI,VOQ->VOQ_CODIMF,dDataBase,0,0,VOQ->VOQ_CTATOT})
					aadd(aSomaStru,{0,0,0,0,0,0})
				Else
					
					aStruP[nCont,1]  := VSY->VSY_NUMOSV
					aStruP[nCont,2]  := Nil
					aStruP[nCont,3]  := SB1->B1_COD
					aStruP[nCont,4]  := VOQ->VOQ_CLAAVA
					aStruP[nCont,5]  := cDescVOQ
					aStruP[nCont,6]  := VOQ->VOQ_ANASIN
					aStruP[nCont,7]  := VOQ->VOQ_CODIGO
					aStruP[nCont,8]  := VOQ->VOQ_SINFOR
					aStruP[nCont,9]  := 0
					aStruP[nCont,10] := 0
					aStruP[nCont,11] := SB1->B1_GRUPO+" "+SB1->B1_CODITE
					aStruP[nCont,12] := 0
					aStruP[nCont,13] := 0
					aStruP[nCont,14] := .f.
					aStruP[nCont,15] := VOQ->VOQ_PRIFAI
					aStruP[nCont,16] := VOQ->VOQ_SEGFAI
					aStruP[nCont,17] := VOQ->VOQ_FUNADI
					aStruP[nCont,18] := VOQ->VOQ_CODIMF
					aStruP[nCont,19] := dDataBase
					aStruP[nCont,20] := 0
					aStruP[nCont,21] := 0
					
				Endif
				
				nCont++
				
				DbSkip()
				
			Enddo
			
			DbSelectArea("VSY")
			
			cNumero := VS6->VS6_NUMIDE
			aStruP := FG_CalcVlrs(aStruP,SB1->B1_COD,cCpoDiv)
			
			If nPosVet == 0
				cCpoDiv := cCpoDiv + "#" + str(len(aStruP)+1,5)
			Endif
			
			FG_Seek("VOQ","cMapPecas",1,.f.)
			FG_SEEK("SB1","VSY->VSY_GRUITE+VSY->VSY_CODITE",7,.f.)
			nPosVet := aScan(aStruP,{|x| x[3]+x[7] == SB1->B1_COD+VOQ->VOQ_CODIGO})
			If nPosVet == 0
				nPosVet := 1
			Endif
			
			For n_:=nPosVet to Len(aSomaStru)
				aSomaStru[n_,1] += aStruP[n_,9]
				aSomaStru[n_,3] += aStruP[n_,12]
				aSomaStru[n_,5] += aStruP[n_,20]
			Next
			
			For n_:=1 to Len(aSomaStru)
				aStruP[n_,9]  := aSomaStru[n_,1]
				aStruP[n_,12] := aSomaStru[n_,3]
				aStruP[n_,20] := aSomaStru[n_,5]
			Next
			
			dbSkip()
			
		EndDo
		
		lCalcTot:= .t.
		
		DbSelectArea("VOQ")
		FG_Seek("VOQ","cMapPecas",1,.f.)
		
		While cMapPecas == VOQ->VOQ_CODMAP .and. VOQ->VOQ_FILIAL == xFilial("VOQ") .and. !eof()
			
			If VOQ->VOQ_INDATI != "1" && Sim
				DbSkip()
				Loop
			Endif
			
			cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ->VOQ_DESAVA,VOQ->VOQ_DESAVA)
			aadd(aStruP,{ VSY->VSY_NUMOSV,,STR0031,; //"Total da Venda"
			VOQ->VOQ_CLAAVA,cDescVOQ,VOQ->VOQ_ANASIN,VOQ->VOQ_CODIGO,VOQ->VOQ_SINFOR,0,0,SB1->B1_GRUPO+" "+SB1->B1_CODITE,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ->VOQ_FUNADI,VOQ->VOQ_CODIMF,dDataBase,0,0,VOQ->VOQ_CTATOT})
			
			DbSkip()
			
		EndDo
		
		
		
		cNumero := VS6->VS6_NUMIDE
		aStruP := FG_CalcVlrs(aStruP,STR0031,cCpoDiv) //"Total da Venda"
		
	EndIf
	
	*** Avaliacao de Servicos ********************************************
	
	aSomaStru := {}
	cCpoDiv := "    1"
	lCalcTot := .f.
	
	If FG_SEEK("VSZ","VS6->VS6_NUMIDE",1,.f.)
		
		DbSelectArea("VSZ")
		While  VS6->VS6_NUMIDE == VSZ->VSZ_NUMIDE .and. VSZ->VSZ_FILIAL == xFilial("VSZ") .and. !eof()
			
			DbSelectArea("VOQ")
			FG_Seek("VOQ","cMapSrvcs",1,.f.)
			nPosVet := aScan(aStruS,{|x| x[3]+x[7] == VSZ->VSZ_CODSER+VOQ->VOQ_CODIGO})
			nCont := nPosVet
			
			While cMapSrvcs == VOQ->VOQ_CODMAP .and. VOQ->VOQ_FILIAL == xFilial("VOQ") .and. !eof()
				
				If VOQ->VOQ_INDATI != "1" && Sim
					DbSkip()
					Loop
				Endif
				
				cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ->VOQ_DESAVA,VOQ->VOQ_DESAVA)
				
				If nPosVet == 0
					aAdd(aStruS,{ VSZ->VSZ_NUMOSV,,VSZ->VSZ_CODSER,;
					VOQ->VOQ_CLAAVA,cDescVOQ,VOQ->VOQ_ANASIN,VOQ->VOQ_CODIGO,VOQ->VOQ_SINFOR,0,0,VSZ->VSZ_CODSER,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ->VOQ_FUNADI,VOQ->VOQ_CODIMF,dDataBase,0,0,VOQ->VOQ_CTATOT})
					aAdd(aSomaStru,{0,0,0,0,0,0})
				Else
					aStruS[nCont,1]  := VSZ->VSZ_NUMOSV
					aStruS[nCont,2]  := Nil
					aStruS[nCont,3]  := VSZ->VSZ_CODSER
					aStruS[nCont,4]  := VOQ->VOQ_CLAAVA
					aStruS[nCont,5]  := cDescVOQ
					aStruS[nCont,6]  := VOQ->VOQ_ANASIN
					aStruS[nCont,7]  := VOQ->VOQ_CODIGO
					aStruS[nCont,8]  := VOQ->VOQ_SINFOR
					aStruS[nCont,9]  := 0
					aStruS[nCont,10] := 0
					aStruS[nCont,11] := VSZ->VSZ_CODSER
					aStruS[nCont,12] := 0
					aStruS[nCont,13] := 0
					aStruS[nCont,14] := .f.
					aStruS[nCont,15] := VOQ->VOQ_PRIFAI
					aStruS[nCont,16] := VOQ->VOQ_SEGFAI
					aStruS[nCont,17] := VOQ->VOQ_FUNADI
					aStruS[nCont,18] := VOQ->VOQ_CODIMF
					aStruS[nCont,19] := dDataBase
					aStruS[nCont,20] := 0
					aStruS[nCont,21] := 0
				Endif
				
				nCont ++
				
				DbSkip()
				
			EndDo
			
			DbSelectArea("VSZ")
			nArea := GetArea()
			
			cNumero := VS6->VS6_NUMIDE + VSZ->VSZ_CODSER + VSZ->VSZ_NUMOSV
			aStruS := FG_CalcVlrs(aStruS,VSZ->VSZ_CODSER,cCpoDiv)
			
			If nPosVet == 0
				cCpoDiv := cCpoDiv + "#" + str(len(aStruS)+1,5)
			Endif
			
			FG_Seek("VOQ","cMapSrvcs",1,.f.)
			nPosVet := aScan(aStruS,{|x| x[3]+x[7] == VSZ->VSZ_CODSER+VOQ->VOQ_CODIGO})
			If nPosVet == 0
				nPosVet := 1
			Endif
			
			For n_:=nPosVet to Len(aSomaStru)
				aSomaStru[n_,1] += aStruS[n_,9]
				aSomaStru[n_,3] += aStruS[n_,12]
				aSomaStru[n_,5] += aStruS[n_,20]
			Next
			
			For n_:=1 to Len(aSomaStru)
				aStruS[n_,9]  := aSomaStru[n_,1]
				aStruS[n_,12] := aSomaStru[n_,3]
				aStruS[n_,20] := aSomaStru[n_,5]
			Next
			
			DbSelectArea("VSZ")
			RestArea(nArea)
			dbSkip()
			
		EndDo
		
		lCalcTot:= .t.
		
		DbSelectArea("VOQ")
		FG_SEEK("VOQ","cMapSrvcs",1,.f.)
		
		while cMapSrvcs == VOQ->VOQ_CODMAP .and. VOQ->VOQ_FILIAL == xFilial("VOQ") .and. !eof()
			
			If VOQ->VOQ_INDATI != "1" && Sim
				DbSkip()
				Loop
			Endif
			
			cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ->VOQ_DESAVA,VOQ->VOQ_DESAVA)
			aadd(aStruS,{ VSZ->VSZ_NUMOSV,,STR0031,; //"Total da Venda"
			VOQ->VOQ_CLAAVA,cDescVOQ,VOQ->VOQ_ANASIN,VOQ->VOQ_CODIGO,VOQ->VOQ_SINFOR,0,0,VSZ->VSZ_CODSER,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ->VOQ_FUNADI,VOQ->VOQ_CODIMF,dDataBase,0,0,VOQ->VOQ_CTATOT})
			DbSkip()
			
		EndDo
		
		cNumero := VS6->VS6_NUMIDE
		aStruS := FG_CalcVlrs(aStruS,STR0031,cCpoDiv) //"Total da Venda"
		
	EndIf
	
	*** Avaliacao da Ordem de Servico *********************************************
	
	aSomaStru := {}
	cCpoDiv := "    1"
	
	If FG_SEEK("VSY","VS6->VS6_NUMIDE",1,.f.)
		
		DbSelectArea("VSY")
		
		While VS6->VS6_NUMIDE == VSY->VSY_NUMIDE .and. VSY->VSY_FILIAL == xFilial("VSY") .and. !eof()
			
			DbSelectArea("VOQ")
			FG_Seek("VOQ","cMapOdSrv",1,.f.)
			
			while cMapPecas == VOQ->VOQ_CODMAP .and. VOQ->VOQ_FILIAL == xFilial("VOQ") .and. !eof()
				
				If VOQ->VOQ_INDATI != "1" && Sim
					DbSkip()
					Loop
				Endif
				
				FG_SEEK("SB1","VO3->VO3_GRUITE+VO3->VO3_CODITE",7,.f.)
				
				cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ->VOQ_DESAVA,VOQ->VOQ_DESAVA)
				aadd(aStruO,{ VSY->VSY_NUMOSV,,SB1->B1_COD,;
				VOQ->VOQ_CLAAVA,cDescVOQ,VOQ->VOQ_ANASIN,VOQ->VOQ_CODIGO,VOQ->VOQ_SINFOR,0,0,SB1->B1_GRUPO+" "+SB1->B1_CODITE,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ->VOQ_FUNADI,VOQ->VOQ_CODIMF,dDataBase,0,0,VOQ->VOQ_CTATOT})
				
				DbSkip()
				
			Enddo
			
			DbSelectArea("VSY")
			
			cNumero := VS6->VS6_NUMIDE
			aStruO := FG_CalcVlrs(aStruO,SB1->B1_GRUPO+" "+SB1->B1_CODITE,cCpoDiv)
			cCpoDiv := cCpoDiv + "#" + str(len(aStruO)+1,5)
			DbSkip()
			
		EndDo
		
	EndIf
	
	If FG_SEEK("VSZ","VS6->VS6_NUMIDE",1,.f.)
		
		DbSelectArea("VSZ")
		
		While VS6->VS6_NUMIDE == VSZ->VSZ_NUMIDE .and. VSZ->VSZ_FILIAL == xFilial("VSZ") .and. !eof()
			
			DbSelectArea("VOQ")
			FG_Seek("VOQ","cMapOdSrv",1,.f.)
			
			While cMapOdSrv == VOQ->VOQ_CODMAP .and. VOQ->VOQ_FILIAL == xFilial("VOQ") .and. !eof()
				
				If VOQ->VOQ_INDATI != "1" && Sim
					DbSkip()
					Loop
				Endif
				
				cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ->VOQ_DESAVA,VOQ->VOQ_DESAVA)
				aadd(aStruO,{ VSZ->VSZ_NUMOSV,,VSZ->VSZ_CODSER,;
				VOQ->VOQ_CLAAVA,cDescVOQ,VOQ->VOQ_ANASIN,VOQ->VOQ_CODIGO,VOQ->VOQ_SINFOR,0,0,VSZ->VSZ_CODSER,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ->VOQ_FUNADI,VOQ->VOQ_CODIMF,dDataBase,0,0,VOQ->VOQ_CTATOT})
				
				DbSkip()
				
			Enddo
			
			DbSelectArea("VSZ")
			
			cNumero := VS6->VS6_NUMIDE
			aStruO := FG_CalcVlrs(aStruO,VSZ->VSZ_CODSER,cCpoDiv)
			cCpoDiv := cCpoDiv + "#" + str(len(aStruO)+1,5)
			DbSkip()
			
		EndDo
		
	EndIf
	
	lCalcTot:= .t.
	
	DbSelectArea("VOQ")
	FG_SEEK("VOQ","cMapOdSrv",1,.f.)
	
	While cMapOdSrv == VOQ->VOQ_CODMAP .and. VOQ->VOQ_FILIAL == xFilial("VOQ") .and. !eof()
		
		If VOQ->VOQ_INDATI != "1" && Sim
			DbSkip()
			Loop
		Endif
		
		cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ->VOQ_DESAVA,VOQ->VOQ_DESAVA)
		aadd(aStruO,{ VSZ->VSZ_NUMOSV,,STR0031,; //"Total da Venda"
		VOQ->VOQ_CLAAVA,cDescVOQ,VOQ->VOQ_ANASIN,VOQ->VOQ_CODIGO,VOQ->VOQ_SINFOR,0,0,VSZ->VSZ_CODSER,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ->VOQ_FUNADI,VOQ->VOQ_CODIMF,dDataBase,0,0,VOQ->VOQ_CTATOT})
		
		DbSkip()
		
	EndDo
	
	cNumero := VS6->VS6_NUMIDE
	aStruO := FG_CalcVlrs(aStruO,STR0031,cCpoDiv) //"Total da Venda"
	
	FG_ResAva(cOutMoed,3,"S","","OFIOM160",{aStruP,aStruS,aStruO})
	
Else
	
	// Veiculos
	cTipAva := "2"
	
	PERGUNTE("LIBVEI")
	
	cCodMap  := Mv_Par01
	cOutMoed := GetMv("MV_SIMB"+Alltrim(GetMv("MV_INDMFT")))
	cSimOMoe := Val(Alltrim(GetMv("MV_INDMFT")))
	
	DbSelectArea("VV0")
	DbSetOrder(1)
	DbGotop()
	DbSeek(xFilial("VV0")+"00"+VS6->VS6_NUMORC)
	
	DbSelectArea("VVA")
	DbSetOrder(1)
	DbGotop()
	DbSeek(xFilial("VVA")+"00"+VS6->VS6_NUMORC)
	
	DbSelectArea("VV1")
	DbSetOrder(2)
	DbGotop()
	DbSeek(xFilial("VV1")+VVA->VVA_CHASSI)
	
	FG_DesVei(VV1->VV1_TRACPA,VV1->VV1_CHAINT,"D")
	FG_DesVei(VV1->VV1_TRACPA,VV1->VV1_CHAINT,"R")
	
	aStru   := {}
	cTipAva := "1"
	cCpoDiv := "    1"
	cTipFat := VV0->VV0_TIPFAT
	lCarBott:= .t.
	cSimVda := "V"
	
	DbSelectArea("VS5")
	FG_Seek("VS5","cCodMap",1,.f.)
	
	DbSelectArea("VOQ")
	FG_Seek("VOQ","cCodMap",1,.f.)
	
	while !eof() .and. VOQ->VOQ_FILIAL == xFilial("VOQ")
		
		If !(cTipFat $ VOQ->VOQ_TIPFAT)
			DbSkip()
			Loop
		Endif
		
		If VOQ->VOQ_INDATI # "1" && Sim
			DbSkip()
			Loop
		Endif
		
		If VOQ->VOQ_CODMAP # cCodMap
			Exit
		Endif
		
		cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ->VOQ_DESAVA,VOQ->VOQ_DESAVA)
		aadd(aStru,{ VV0->VV0_NUMTRA,VV1->VV1_TRACPA,VV1->VV1_CHAINT,;
		VOQ->VOQ_CLAAVA,cDescVOQ,VOQ->VOQ_ANASIN,VOQ->VOQ_CODIGO,VOQ->VOQ_SINFOR,0,0,VV1->VV1_CHASSI,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ->VOQ_FUNADI,VOQ->VOQ_CODIMF,VV0->VV0_DATMOV,0,0,VOQ->VOQ_CTATOT})
		
		DbSkip()
		
	Enddo
	
	DbSelectArea("VV0")
	For nCnt := 1 TO FCount()
		cNome := Substr(FieldName(nCnt),5)
		M->&(EVAL(bCampo,nCnt)) := &("VV0->VV0_"+cNome)
	Next
	
	DbSelectArea("VVA")
	For nCnt := 1 TO FCount()
		cNome := Substr(FieldName(nCnt),5)
		M->&(EVAL(bCampo,nCnt)) := &("VVA->VVA_"+cNome)
	Next
	
	FG_CalcVlrs(aStru,VV1->VV1_CHAINT)
	FG_RESAVA(cOutMoed,3,"V","","OFIOM170")
	
Endif

Return

/*/{Protheus.doc} OX0030012_FiltraItens
Calcula o peso das peças no Orçamento para Informação na NF
@author Manoel Filho
@since 15/05/2019
@version 1.0
@param cFiltro -> 0 - Somente Itens sem Divergencia , 1 - Somente Itens com Divergencia ,  2 - Ambos, com e sem Divergencia
/*/
Function OX0030012_FiltraItens(cFiltro,nOpc,lRefresh)//
Local nCntFor    := 0
Local _ni        := 0
Local lVS7DIVERG := VS7->(FieldPos("VS7_DIVERG")) > 0
Local lVazio     := .f.

If lRefresh
	// Quando todos estão marcados mostra Ambos
	If lCkFilVerde .and. lCkFilVerme
		cFiltro := "2"
	Else
		If lCkFilVerde
			cFiltro := "0"
		Else
			cFiltro := "1"
		Endif
	Endif
	// Quando nenhum está marcado mostra nada
	If !lCkFilVerde .and. !lCkFilVerme
		lVazio := .t.
	Endif
Endif

aColsP:={}
If !lVazio
	DbSelectArea("VS7")
	DbSetOrder(1)
	DbSeek(xFilial()+M->VS6_NUMIDE)
	While !eof() .and. M->VS6_NUMIDE == VS7->VS7_NUMIDE .and. xFilial("VS7") == VS7->VS7_FILIAL
		//
		If cFiltro <> "2" .or. !lVS7SemProb // Ambos, com e sem Divergencia
			If lVS7DIVERG .and.  VS7->VS7_DIVERG <> cFiltro // 1 - há Divergência / 0 - não há Divergência
				DbSkip()
				Loop
			Endif
		Endif
		//
		If VS7->VS7_TIPAUT == "1"
			If lVS7DIVERG
				aTemp := {if(VS7->VS7_DIVERG=="1",.t.,.f.)}
			Else
				aTemp := {.t.}
			Endif
			for nCntFor = 2 to Len(aHeaderP)
				aAdd(aTemp,&(aHeaderP[nCntFor]))
			next
			aAdd(aColsP,aTemp)
			If nOpc == 2
				If lVS7DIVERG
					aColsP[Len(aColsP),1] := if(VS7->VS7_DIVERG=="1",.t.,.f.)
				Else
					aColsP[Len(aColsP),1] := if(VS7->VS7_ITELIB=="S",.t.,.f.)
				Endif
			Endif
		Endif
		DbSkip()
	EndDo
Endif
If Len(aColsP) == 0
	aColsP:={Array(nUsadoP+1)}
	aColsP[1,1]:=.F.
	aColsP[1,nUsadoP+1]:=.F.
	For _ni:=2 to nUsadoP
		aColsP[1,_ni] := IIf(_ni<>nPosRecP,CriaVar(aHeaderP[_ni]),0)
	Next
	lTemPedPec := .f.
Endif
///////////
aColsS:={}
If !lVazio
	DbSelectArea("VS7")
	DbSetOrder(1)
	DbSeek(xFilial()+M->VS6_NUMIDE)
	While !eof() .and. M->VS6_NUMIDE == VS7->VS7_NUMIDE .and. xFilial("VS7") == VS7->VS7_FILIAL
		//
		If cFiltro <> "2"  .or. !lVS7SemProb // Ambos, com e sem Divergencia
			If lVS7DIVERG .and.  VS7->VS7_DIVERG <> cFiltro // 1 - há Divergência / 0 - não há Divergência
				DbSkip()
				Loop
			Endif
		Endif
		//
		If VS7->VS7_TIPAUT == "2"
			If lVS7DIVERG
				aTemp := {if(VS7->VS7_DIVERG=="1",.t.,.f.)}
			Else
				aTemp := {.t.}
			Endif
			for nCntFor = 2 to Len(aHeadS)
				aAdd(aTemp,&(aHeadS[nCntFor]))
			next
			aAdd(aColsS,aTemp)
			If nOpc == 2
				If lVS7DIVERG
					aColsS[Len(aColsS),1] := if(VS7->VS7_DIVERG=="1",.t.,.f.)
				Else
					aColsS[Len(aColsS),1] := if(VS7->VS7_ITELIB=="S",.t.,.f.)
				Endif
			Endif
		Endif
		DbSkip()
	EndDo
Endif
If Len(aColsS) == 0
	aColsS:={Array(nUsadoS+1)}
	aColsS[1,1]:=.F.
	aColsS[1,nUsadoS+1]:=.F.
	For _ni:=2 to nUsadoS
		aColsS[1,_ni] := IIf(_ni<>nPosRecS,CriaVar(aHeadS[_ni]),0)
	Next
	lTemPedSrv := .f.
Endif
//
If lRefresh
	oLbItens:nAt := 1
	oLbItens:SetArray(aColsP)
	oLbItens:bLine := { || RetbLine("P") }
	oLbItens:Refresh()
	oLbItensS:nAt := 1
	oLbItensS:SetArray(aColsS)
	oLbItensS:bLine := { || RetbLine("S") }
	oLbItensS:Refresh()
Endif
//
Return

/*/{Protheus.doc} OX0030021_Levanta_aHeader_aCols_Orcamento
Levanta Orcamento - aHeader e aCols (utilizado no Mapa de Resultado) - igual ao OFIXX001

@author André Luis Almeida
@since 26/04/2022
/*/
Static Function OX0030021_Levanta_aHeader_aCols_Orcamento()
Local nUsadoPX01 := 0
Local nCntFor    := 0
Local cMotCanDPM := GetNewPar("MV_MIL0032","000002") // Motivo de Cancelamento DPM
//
aHeadVS3 := {}
aColsVS3 := {}
//
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VS3")
While !Eof().And.(x3_arquivo=="VS3")
	If X3USO(x3_usado)
		nUsadoPX01++
		Aadd(aHeadVS3,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
		SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,X3CBOX(),SX3->X3_RELACAO})
	EndIf
	DbSkip()
EndDo
//
dbSelectArea("VS3")
dbSetOrder(1)
dbSeek(xFilial("VS3")+VS1->VS1_NUMORC)
While !eof() .and. VS3->VS3_FILIAL == xFilial("VS3").and. VS3->VS3_NUMORC == VS1->VS1_NUMORC
	SF4->(dbseek(xFilial("SF4")+VS3->VS3_CODTES))
	If SF4->F4_OPEMOV == "05"
		AADD(aColsVS3,Array(nUsadoPX01+1))
		For nCntFor:=1 to nUsadoPX01
			if aHeadVS3[nCntFor,2] =="VS3_QTDEST"
				SB1->(DBSetOrder(7))
				SB1->(DBSeek(xFilial("SB1")+VS3->VS3_GRUITE+VS3->VS3_CODITE))
				aColsVS3[Len(aColsVS3),nCntFor] := OX001SLDPC(xFilial("SB2")+SB1->B1_COD+VS3->VS3_LOCAL)
			elseif aHeadVS3[nCntFor,10] == "V"
				SX3->(DBSetOrder(2))
				SX3->(DBSeek(aHeadVS3[nCntFor,2]))
				aColsVS3[Len(aColsVS3),nCntFor] := &(sx3->x3_relacao)
			elseIf !IsHeadRec(aHeadVS3[nCntFor,2]) .and. !IsHeadAlias(aHeadVS3[nCntFor,2])
				aColsVS3[Len(aColsVS3),nCntFor] := FieldGet(FieldPos(aHeadVS3[nCntFor,2]))
			endif
		Next
		If !Empty(VS3->VS3_MOTPED) .and. !(VS3->VS3_MOTPED $ cMotCanDPM)
			aColsVS3[Len(aColsVS3),nUsadoPX01+1]:=.T.
		Else
			aColsVS3[Len(aColsVS3),nUsadoPX01+1]:=.F.
		Endif
	EndIf
	DbSkip()
EndDo
Return