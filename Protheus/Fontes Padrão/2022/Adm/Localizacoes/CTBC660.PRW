#INCLUDE "CTBC660.ch"
#INCLUDE "Protheus.ch"

#define ALIASDOC	1
#define DATADOC		2
#define NRODOC		3
#define MOEDOC 		4
#define VLRDOC 		5
#define NODIA 		6


//alteração feita no changeset:74459

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTBC660   ³ Autor ³Fernando Radu Muscalu ³ Data ³ 29/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa para auditoria da contabilidade. Ele demonstrara   ³±±
±±³          ³se o que foi gerado pelos modulos existe na contabilidade,  ³±±
±±³          ³assim como se o que ha na contabilidade tambem possui seu   ³±±
±±³          ³documento correlativo no modulo.						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBC660()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil		                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBC660()

Local cRetSegOfi	:= ""
Local nOpc 			:= 0

Local aResultSet	:= {}	//Veja a documentacao destes array no final do arquivo
Local aCfgDoc		:= {}
Local aButtons		:= {}
Local aSays			:= {}
Local aModSel		:= {}

Local bParam		:= {|| aModSel := Ctbc66Param() }
Local bBtnOk		:= {||	Iif(aModSel[4] == "1", aCtbc66Fil := AdmGetFil(), aCtbc66Fil := {cFilAnt} ),;
                            Iif(Empty(aCtbc66Fil),Help(" ",1,"CTBC660",,STR0068,1,0),;  //## "Não foi selecionada nenhuma filial."
                            (aCfgDoc 	:= CtbCQCLoad(aModSel[1]),;
							CtbC66GenInf(aModSel,aCfgDoc,aResultSet),;
							CtbC66Scr(aModSel[1],aResultSet)) ) }

Private aCtbc66Moe 	:= CtbC66GMoe()
Private aCtbc66Fil	:= {}

CriaCTL()

cRetSegOfi := GetMv("MV_SEGOFI")

If Empty(cRetSegOfi) .or. alltrim(cRetSegOfi) == "0"
	Help(" ",1,"CTBC660_NODIA",,STR0033,1,0)	 //##"O uso do controle diario (número correlativo) está desabilitado."
	Return()
Endif

aAdd(aButtons,{5,.t.,bParam})
aAdd(aButtons,{1,.t.,{|| nOpc := 1, oDlg:End() } })
aAdd(aButtons,{2,.t.,{|| oDlg:End() } })

aAdd(aSays,STR0001)	//## "Programa com o objetivo de demonstrar um comparativo entre"
aAdd(aSays,STR0002)	//## "documentos dos módulos do sistema e a contabilidade."
aAdd(aSays,"")
aAdd(aSays,STR0003) //## "Para tal, em parâmetros, selecione um ou mais módulos."
aAdd(aSays,STR0004) //## "O período definido será considerado para os lançamentos contábeis."

FormBatch(STR0005,aSays,aButtons) //## "Relatório de Auditoria"

If nOpc == 1
	If !Empty(aModSel)
		If len(aModSel[1]) > 0
			Eval(bBtnOk)
		Else
			Help(" ",1,"CTBC660",,STR0006,1,0)	//#"Não foi selecionado nenhum módulo."
		Endif
	Else
		Help(" ",1,"CTBC660",,STR0007,1,0)	//#"Não houve parametrização definida."
	Endif
Endif


Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctbc66Param³ Autor ³Fernando Radu Muscalu ³ Data ³ 29/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Tela de parametrizacao da auditoria. Definicao do periodo   ³±±
±±³          ³de movimentacoes e de quais modulos se vai auditar.		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctbc66Param()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array	- Tipo: A 	                                          ³±±
±±³          ³	Array[1] - Tipo: A => Array com os modulos selecionados	  ³±±
±±³          ³	Array[2] - Tipo: D => data de inicio do periodo     	  ³±±
±±³          ³	de contabilizacao								     	  ³±±
±±³          ³	Array[3] - Tipo: D => data do final do periodo     	  	  ³±±
±±³          ³	de contabilizacao								     	  ³±±
±±³          ³	Array[4] - Tipo: C => Seleciona Filiais?         	  	  ³±±
±±³          ³		"1" = Sim									     	  ³±±
±±³          ³		"2" = Nao									     	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

*/
Static Function Ctbc66Param()

Local oDlg
Local oScrLayer		:= fwLayer():New()
Local oPnlDlg
Local oGrpDlg
Local oGetDI
Local oGetDF
Local oListMod
Local oSelecFil
Local oSelecMvt
local oCheck

Local aSizeDlg		:= FwGetDialogsize(oMainWnd)
Local aListMod		:= CtbC660LoadMod()
Local aSelected		:= {}
Local aSelecFil		:= {"1="+STR0008,"2="+STR0009}				//Sim###Não
Local aSelecMvt		:= {"1="+STR0057,"2="+STR0056,"3="+STR0058}	//Não Conferidos###Conferidos###Todos
Local nHeight		:= aSizeDlg[3] * 0.80
Local nWidth        := aSizeDlg[4] * 0.80
Local nOpc			:= 0

Local cSelecFil		:= "2"
Local cSelecMvt		:= "3"

Local dDataI		:= FirstDay(dDataBase)
Local dDataF		:= LastDay(dDataBase)

Local lCheckNDiv		:=.F.

Local bBtnOk		:= {|| 	Iif( ChkModActive(aListMod), nOpc := 1, nil ),;
							Iif(nOpc == 1, oDlg:End(),nil) }
Local bBtnCancel	:= {|| oDlg:End()}
Local bEnchBar		:= {|| EnchoiceBar(oDlg,bBtnOk,bBtnCancel) }

DEFINE MSDIALOG oDlg FROM 0,0 TO nHeight, nWidth TITLE STR0005 PIXEL STYLE DS_MODALFRAME of oMainWnd //## "Relatório de Auditoria"

	oScrLayer:init(oDlg,.F.)

	oScrLayer:addLine("Linha",100,.t.)
	oScrLayer:addCollumn("Coluna",100,.t.,"Linha")
	oScrLayer:addWindow("Coluna","Janela",STR0010,100,.f.,.t.,{||},"Linha")	 //## "Parametrização"

    oPnlDlg := oScrLayer:getWinPanel("Coluna","Janela","Linha")
	oPnlDlg:FreeChildren()

	nWidth *= 0.488
	nHeight*= 0.12

	oGrpDlg := tGroup():New(0,0,nHeight,nWidth,STR0011,oPnlDlg,,,.T.)	//##"Período de Verficação"

	@ 15,005 Say STR0012 PIXEL OF oPnlDlg //## "Data Inicial"
	@ 15,045 MsGet oGetDI Var dDataI Size 40,008 PIXEL OF oPnlDlg

	@ 15,90 Say STR0013 PIXEL OF oPnlDlg //## "Data Final"
	@ 15,120 MsGet oGetDF Var dDataF Size 40,008 PIXEL OF oPnlDlg

	@ 15,165 Say STR0014 PIXEL OF oPnlDlg //## "Seleciona Filiais"
	@ 15,225 ComboBox oSelecFil Var cSelecFil Items aSelecFil Size 50,008 PIXEL OF oPnlDlg

	@ 15,280 Say STR0034 PIXEL OF oPnlDlg //## "Seleciona Movtos"
	@ 15,350 ComboBox oSelecMvt Var cSelecMvt Items aSelecMvt Size 60,008 PIXEL OF oPnlDlg
	oGrpDlg2 := tGroup():New(nHeight + 5,0,nHeight+147,nWidth,STR0015,oPnlDlg,,,.T.) //## "Módulos"
	                                                        //"Nro Modulo","Descricao","Desc. Extendida"

	@ 30,005 CHECKBOX oCheckNDiv VAR lCheckNDiv Size 100,009 PROMPT STR0060 When (.T.) On Change() Of oPnlDlg //adicionado filtro para não divergentes //##"Seleciona não divergentes?"

	@ nHeight + 15,002 ListBox oListMod Fields  HEADER " ",STR0016,STR0017,STR0018 Size nWidth-2,nHeight * 2.30 Pixel Of oPnlDlg ON  dblClick( aListMod[oListMod:nAt][1] := !aListMod[oListMod:nAt][1] , oListMod:Refresh())

	oListMod:lShowHint := .T.

	oListMod:SetArray(aListMod)

	oListMod:bLine := {|| {;
							Iif(aListMod[oListMod:nAT,01], LoadBitmap(GetResources(),"CHECKED") , LoadBitmap(GetResources(), "UNCHECKED") ),;
							aListMod[oListMod:nAT,02],;
							aListMod[oListMod:nAT,03],;
							aListMod[oListMod:nAT,04]}}

	oListMod:bHeaderClick := {|| Ctbc66ChkAll(aListMod,oListMod)}
oDlg:Activate(,,,.T.,,,bEnchBar)

If nOpc == 1
	aEval(aListMod,{|x| Iif(x[1], aAdd(aSelected,{strzero(x[2],2),x[4]}),nil) })
Endif

Return({aSelected,dDataI,dDataF,cSelecFil,cSelecMvt,lCheckNDiv})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctbc66ChkAll³ Autor ³Fernando Radu Muscalu ³ Data ³ 29/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Marcacao e desmarcacao dos modulos 					       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctbc66ChkAll(aListMod,oListMod)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aListMod	- Tipo: A => Lista dos modulos                     ³±±
±±³          ³oListMod	- Tipo: O => Objeto ListBox 	                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil			 	                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

*/
Static Function Ctbc66ChkAll(aListMod,oListMod)

Local nI		:= 0
Local nQtdOn	:= 0

aEval(aListMod,{|x| If(x[1],nQtdOn++,nil) })

For nI := 1 to len(aListMod)

	If aListMod[nI,1] .and. nQtdOn == len(aListMod)
		aListMod[nI,1] := .f.
	Else
		aListMod[nI,1] := .t.
	Endif

Next nI

oListMod:Refresh()

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ChkModActive³ Autor ³Fernando Radu Muscalu ³ Data ³ 29/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida se ha pelo menos UM modulo selecionado			       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ChkModActive(aListMod)		                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aListMod	- Tipo: A => Lista dos modulos                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet	- Tipo: L => .t., validado                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ChkModActive(aListMod)

Local nI	:= 0

Local lRet	:= .f.

For nI := 1 to len(aListMod)
	If aListMod[nI,1]
		lRet := .t.
		Exit
	Endif
Next nI

If !lRet
	Help(" ",1,"ChkModActive",,STR0006,1,0)	//#"Não foi selecionado nenhum módulo."
Endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbC660LoadMod³ Autor ³Fernando Radu Muscalu ³ Data ³ 29/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta a lista de modulos que integram com a contabilidade	     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbC660LoadMod()				                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³        	                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aRet	- Tipo: A => Lista dos modulos                           ³±±
±±³          ³	aRet[n,1]- Tipo: L => Se possui selecao ou nao, .t., possui  ³±±
±±³          ³	aRet[n,2]- Tipo: N => nro do modulo						     ³±±
±±³          ³	aRet[n,3]- Tipo: C => Descricao curta do modulo			     ³±±
±±³          ³	aRet[n,5]- Tipo: C => Descricao extendida do modulo	 	     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function CtbC660LoadMod()

Local cQry 		:= "SELECT DISTINCT CVA_MODULO FROM " + RetSQlName("CVA") + " WHERE D_E_L_E_T_ = ' ' ORDER BY CVA_MODULO "

Local aModulo	:= RetModName()
Local aRet		:= {}

Local nPos		:= 0

cQry := ChangeQuery(cQry)

If Select("TRBCVA") > 0
	TRBCVA->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), "TRBCVA", .T., .F.)

While TRBCVA->(!eof())

	If ( nPos :=  aScan(aModulo,{|x| x[1] == Val(TRBCVA->CVA_MODULO) }) ) > 0
		aAdd(aRet, {.f.,aModulo[nPos,1],aModulo[nPos,2],aModulo[nPos,3]} )
	Endif

	TRBCVA->(DbSkip())
EndDo

If ( nPos :=  aScan(aModulo,{|x| alltrim(x[2]) == "SIGACTB" }) ) > 0
	aAdd(aRet, {.f.,aModulo[nPos,1],aModulo[nPos,2],aModulo[nPos,3]} )
Endif

TRBCVA->(DbCloseArea())

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbC66GenInf  ³ Autor ³Fernando Radu Muscalu ³ Data ³ 29/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Carrega em memoria as informacoes necessarias para  o relatorio³±±
±±³          ³de auditoria.													 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbC66GenInf(aParams,aCfgDoc,aResult)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aParams	- tipo: A => Parametros deifinidos pelo usuario      ³±±
±±³          ³aCfgDoc	- tipo: A => Configuracao do arquivo do modulo       ³±±
±±³          ³aResult	- tipo: A => Array com os dados dos comparativos     ³±±
±±³          ³modulo X contabilidade									     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aRet	- Tipo: A => Lista dos modulos                           ³±±
±±³          ³	aRet[n,1]- Tipo: L => Se possui selecao ou nao, .t., possui  ³±±
±±³          ³	aRet[n,2]- Tipo: N => nro do modulo						     ³±±
±±³          ³	aRet[n,3]- Tipo: C => Descricao curta do modulo			     ³±±
±±³          ³	aRet[n,5]- Tipo: C => Descricao extendida do modulo	 	     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbC66GenInf(aParams,aCfgDoc,aResult)

Local nP		:= 0
Local nI		:= 0
Local nX		:= 0

Local aSelected 	:= aClone(aParams[1])

Local cDtIni		:= dtos(aParams[2])		//Data Inicial
Local cDtfim		:= dtos(aParams[3])     //Data Final
Local cSelecMvt   := aParams[5]           //Movimentos
local lCheckNDiv	:= aParams[6]			//Mostra não divergentes
Local cNameFil		:= ""

QryTabMod(aSelected)

For nI := 1 to len(aCtbc66Fil)

    cNameFil := Alltrim(SM0->(GetAdvFVal("SM0","M0_FILIAL",cEmpAnt+aCtbc66Fil[nI],1,"")))

	aAdd(aResult,{aCtbc66Fil[nI]+"|"+cNameFil,Nil})

	aResult[nI,2]  := {}

	For nX := 1 to len(aSelected)
		aAdd(aResult[nI,2],{aSelected[nX,1]+"|"+aSelected[nX,2],nil,nil})
	Next nX


	If Select("TRBCTL") > 0

		TRBCTL->(DbGoTop())

		While TRBCTL->(!Eof())

            If cPaisLoc $ "ARG/CHI" .And. TRBCTL->CVA_MODULO == "01"
               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
               //³ Problemas encontrados no modulo SIGAATF; somente SN3 esta, atualmente, sendo rastreado em CV3 ³
               //³ Outras tabelas "candidatas" a Select no ATF: SN4 e SNS; ambas inserem "ruido" no Resultado    ³
          	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
               If TRBCTL->CTL_ALIAS == "SN4"

		          nP := aScan( aCfgDoc,{|x| alltrim(x[ALIASDOC]) == "SN3" })

		          If nP > 0

		             MsgRun(STR0019 + Alltrim(aCtbc66Fil[nI]) + STR0020 + Alltrim(TRBCTL->CVA_MODULO),STR0021, {|| FillATFMod( "SN3", cDtIni, cDtfim, aCfgDoc[nP], aResult[nI,2], TRBCTL->CVA_MODULO, aCtbc66Fil[nI], cSelecMvt, lCheckNDiv ) } ) //##"Extraindo dados Filial "#" módulo "#"Aguarde..."

                  EndIf

               EndIf

            Else

			   nP := aScan(aCfgDoc,{|x| alltrim(x[ALIASDOC]) == Alltrim(TRBCTL->CTL_ALIAS) })

			   If nP > 0

				  //MsgRun(OemToAnsi(STR0001),OemToAnsi(STR0002),{|| CtbTabelas() }) // "Carregando as configurações do Módulo Contabilidade Gerencial" ## "Aguarde"
				  MsgRun(STR0019 + Alltrim(aCtbc66Fil[nI]) + STR0020 + Alltrim(TRBCTL->CVA_MODULO),STR0021, {|| FillInfMod(TRBCTL->CTL_ALIAS,cDtIni,cDtfim,aCfgDoc[nP],aResult[nI,2],TRBCTL->CVA_MODULO,aCtbc66Fil[nI],cSelecMvt,lCheckNDiv) } ) //##"Extraindo dados Filial "#" módulo "#"Aguarde..."

			   Endif

            EndIf

			TRBCTL->(Dbskip())
		EndDo

	Endif

	If aScan(aSelected,{|x| alltrim(x[1]) == "34"}) > 0
		MsgRun(STR0022 + alltrim(aCtbc66Fil[nI]),STR0021, {|| FillInfCtb(cDtIni,cDtfim,aResult[nI,2],aCtbc66Fil[nI],cSelecMvt) } )//##"Extraindo dados da contabilidade, filial "
	Endif

	Ctbc66FillBlank(aResult[nI,2])

Next nI


TRBCTL->(DbCloseArea())

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QryTabMod	    ³ Autor ³Fernando Radu Muscalu ³ Data ³ 29/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta arquivo temporario com as tabelas utilizadas nos LPs     ³±±
±±³          ³dos modulos selecionados										 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³QryTabMod(aSelected)					                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aSelected	- tipo: A => Lista dos modulos selecionados	         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil															 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QryTabMod(aSelected)

Local cQry 			:= ""
Local cRetMod   	:= GetClauseInArray(aSelected)

cQry := "SELECT " + chr(13) + chr(10)
cQry += "	DISTINCT CTL_ALIAS, " + chr(13) + chr(10)
cQry += "	CVA_MODULO " + chr(13) + chr(10)
cQry += "FROM " + chr(13) + chr(10)
cQry += "	" + RetSQLName("CVA") + " CVA " + chr(13) + chr(10)
cQry += "INNER JOIN " + chr(13) + chr(10)
cQry += "	" + RetSQLName("CTL") + " CTL " + chr(13) + chr(10)
cQry += "ON " + chr(13) + chr(10)
cQry += "	CTL.D_E_L_E_T_ = ' '  " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CTL_FILIAL = CVA_FILIAL " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CTL_LP = CVA_CODIGO	 " + chr(13) + chr(10)
cQry += "WHERE " + chr(13) + chr(10)
cQry += "	CVA.D_E_L_E_T_ = ' ' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CVA_MODULO " + cRetMod + chr(13) + chr(10)
cQry += "ORDER BY " + chr(13) + chr(10)
cQry += "	CVA_MODULO, " + chr(13) + chr(10)
cQry += "	CTL_ALIAS "

cQry := ChangeQuery(cQry)

If Select("TRBCTL") > 0
	TRBCTL->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), "TRBCTL", .T., .F.)

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FillInfMod	³ Autor ³Fernando Radu Muscalu ³ Data ³ 29/08/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera massa de dados em memoria de acordo com o modulo e tabela. ³±±
±±³          ³Esta massa de dado corresponde tanto do lancamento quanto do    ³±±
±±³          ³documento gerador (lado do modulo)							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FillInfMod(cAlias,cDtIni,cDtfim,aConfig,aResult,cMod,cFilSelect)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias	- Tipo: C => Alias da tabela a ser analisada          ³±±
±±³          ³cDtIni	- Tipo: C => Data inicial do periodo			      ³±±
±±³          ³cDtFim	- Tipo: C => Data final do periodo				      ³±±
±±³          ³aConfig	- Tipo: A => Campos utilizados pela Tabela		      ³±±
±±³          ³aResult	- Tipo: A => Array com os dados comparativo Modulo X  ³±±
±±³          ³cMod		- Tipo: C => Codigo do Modulo						  ³±±
±±³          ³cFilSelect- Tipo: C => Filiais selecionadas					  ³±±
±±³          ³cSelecMvt - Tipo: C => Filtrar movimentos.					  ³±±
±±³          ³lCheckNDiv - Tipo: L => Filtrar não Divergente.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil									                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FillInfMod(cAlias,cDtIni,cDtfim,aConfig,aResult,cMod,cFilSelect,cSelecMvt,lCheckNDiv)

Local cQry			:= ""
Local cSelectEnt	:= ""
Local cMoeMod		:= ""
Local cBmpLeg		:= ""
Local cIdFil		:= GetFieldFil(cAlias)
Local cDataDoc		:= ""
Local cNroDoc		:= Alltrim(StrTran(aConfig[NRODOC],"+",","+space(1) ) ) + ", "
Local cMoeDoc		:= ""
Local cVlrDoc		:= ""
Local cNodia		:= ""

Local aDataMod	:= {}
Local aDataCtb	:= {}
Local aDataCV3	:= {}
Local aVlrMCtb	:= {}
Local aEntities := Ctbc66RetEnt()

Local nP		:= 0
Local nI		:= 0
Local nQtdEnt	:= len(aEntities[1])

local lCond1
local lCond2
local lCond3
local lCond4

cFilSelect:=xfilial(TRBCTL->CTL_ALIAS,cFilSelect)

For nI := 1 to nQtdEnt
	cSelectEnt += alltrim(aEntities[1][nI,1])+ ", " + alltrim(aEntities[2][nI,1]) + ", "
Next nI

If "NO_" $ Upper(aConfig[DATADOC])
	cDataDoc := "	' ' " + aConfig[DATADOC] + ", "+ chr(13) + chr(10)
Else
	cDataDoc := "	" + aConfig[DATADOC] + ", "+ chr(13) + chr(10)
Endif

If "NO_" $ Upper(cNroDoc)
	cNroDoc := "	' ' " + cNroDoc + chr(13) + chr(10)
Else
	cNroDoc := "	" + cNroDoc + chr(13) + chr(10)
Endif

If "NO_" $ Upper(aConfig[MOEDOC])
	cMoeDoc := "	'01' " + aConfig[MOEDOC]+ ", "+ chr(13) + chr(10)
Else
	cMoeDoc := "	" + aConfig[MOEDOC]+ ", "+ chr(13) + chr(10)
Endif

If "NO_" $ Upper(aConfig[VLRDOC])
	cVlrDoc := "	0 " + aConfig[VLRDOC]+ ", "+ chr(13) + chr(10)
Else
	cVlrDoc := "	" + aConfig[VLRDOC]+ ", "+ chr(13) + chr(10)
Endif

If "NO_" $ Upper(aConfig[NODIA])
	cNodia := "	' ' " + aConfig[NODIA]+ ", "+ chr(13) + chr(10)
Else
	cNodia := "		" + aConfig[NODIA]+ ", "+ chr(13) + chr(10)
Endif

cQry := "SELECT "+ chr(13) + chr(10)
cQry += cIdFil + ", " + chr(13) + chr(10)
cQry += cDataDoc
cQry += cNroDoc
cQry += cMoeDoc
cQry += cVlrDoc
cQry += cNodia
cQry += "	" + cAlias + ".D_E_L_E_T_ DELETADO, "+ chr(13) + chr(10)
cQry += "	CT2.R_E_C_N_O_ CT2_RECNO,  "+ chr(13) + chr(10)
cQry += "	CT2_FILIAL,  "+ chr(13) + chr(10)
cQry += "	CT2_DATA,  "+ chr(13) + chr(10)
cQry += "	CT2_TPSALD,  "+ chr(13) + chr(10)
cQry += "	CT2_LOTE,  "+ chr(13) + chr(10)
cQry += "	CT2_SBLOTE, "+ chr(13) + chr(10)
cQry += "	CT2_DOC, "+ chr(13) + chr(10)
cQry += "	CT2_SEQLAN,  "+ chr(13) + chr(10)
cQry += "	CT2_LINHA,  "+ chr(13) + chr(10)
cQry += "	CT2_MOEDLC, "+ chr(13) + chr(10)
cQry += "	CT2_LP,  "+ chr(13) + chr(10)
cQry += "	CT2_NODIA,  "+ chr(13) + chr(10)
cQry += "	CT2_DEBITO,  "+ chr(13) + chr(10)
cQry += "	CT2_CREDIT,  "+ chr(13) + chr(10)
cQry += "	CT2_CCD,  "+ chr(13) + chr(10)
cQry += "	CT2_CCC,  "+ chr(13) + chr(10)
cQry += "	CT2_ITEMD,  "+ chr(13) + chr(10)
cQry += "	CT2_ITEMC,  "+ chr(13) + chr(10)
cQry += "	CT2_CLVLDB,  "+ chr(13) + chr(10)
cQry += "	CT2_CLVLCR,  "+ chr(13) + chr(10)
cQry += cSelectEnt + chr(13) + chr(10)
cQry += "	CT2_VALOR,  "+ chr(13) + chr(10)
cQry += "	CT2_SEQUEN, "+ chr(13) + chr(10)
cQry += "	CT2_DC, "+ chr(13) + chr(10)
cQry += "	CT2_CONFST, "+ chr(13) + chr(10)
cQry += "	CT2.D_E_L_E_T_ CT2_DELET  "+ chr(13) + chr(10)
cQry += "FROM "+ chr(13) + chr(10)
cQry += "	" + RetSQlName("CT2") + " CT2 "+ chr(13) + chr(10)
cQry += "LEFT JOIN "+ chr(13) + chr(10)

//*-*
If "NO_" $ Upper(aConfig[NODIA])   // Feito para tabelas que NAO possuem campos _NODIA

	cQry += "	" + RetSqlName(cAlias) + " " + cAlias + chr(13) + chr(10)
	cQry += "ON	 "+ chr(13) + chr(10)
	cQry += "	CT2_FILIAL = " + cIdFil + chr(13) + chr(10)
	cQry += "	AND " + chr(13) + chr(10)
	cQry += "	CT2_NODIA = ' '" + chr(13) + chr(10)
    cQry += "	AND " + cAlias + ".D_E_L_E_T_=''" + chr(13) + chr(10)

Else

	cQry += "	" + RetSqlName("CV3") + " CV3" + chr(13) + chr(10)
	cQry += "ON	 "+ chr(13) + chr(10)
	cQry += "	CV3_FILIAL = '" + cFilSelect + "'" + chr(13) + chr(10)
	cQry += "	AND " + chr(13) + chr(10)

      If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"

         cQry += " (Case When CV3_RECDES = ' ' Then 0 Else NVL(CAST(CV3_RECDES as int),0) End) = CT2.R_E_C_N_O_" + chr(13) + chr(10)

      Else

		 cQry += " CONVERT(Int,CV3_RECDES) = CT2.R_E_C_N_O_" + chr(13) + chr(10)

      EndIf

	cQry += "	AND " + chr(13) + chr(10)
	cQry += "	CV3.D_E_L_E_T_ = ' ' " + chr(13) + chr(10)
	cQry += "INNER JOIN "+ chr(13) + chr(10)
	//*-*
	cQry += "	" + RetSqlName(cAlias) + " " + cAlias + chr(13) + chr(10)
	cQry += "ON	 "+ chr(13) + chr(10)

      If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"

	     cQry += " (Case When CV3_RECORI = ' ' Then 0 Else NVL(CAST(CV3_RECORI as int),0) End) = " + cAlias + ".R_E_C_N_O_ " + chr(13) + chr(10)

      Else

		 cQry += " CONVERT(Int,CV3_RECORI) = " + cAlias + ".R_E_C_N_O_ " + chr(13) + chr(10)

      EndIf

	cQry += "	AND " + chr(13) + chr(10)
	cQry += " " + cIdFil + " = '" + cFilSelect + "'" + chr(13) + chr(10)
	cQry += "	AND " + cAlias + ".D_E_L_E_T_= ' '" + chr(13) + chr(10)

EndIf

cQry += "INNER JOIN  " + chr(13) + chr(10)
cQry += "	" + RetSQLName("CTL") + " CTL " + chr(13) + chr(10)
cQry += "ON " + chr(13) + chr(10)
cQry += "	CTL_FILIAL = CT2_FILIAL " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CTL_LP = CT2_LP " + chr(13) + chr(10)
cQry += "	AND	 " + chr(13) + chr(10)
cQry += "	CTL_ALIAS = '"+cAlias+"'  " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CTL.D_E_L_E_T_ = ' ' " + chr(13) + chr(10)
cQry += "INNER JOIN " + chr(13) + chr(10)
cQry += "	" + RetSqlName("CVA") + " CVA " + chr(13) + chr(10)
cQry += "ON " + chr(13) + chr(10)
cQry += "	CVA_FILIAL = CT2_FILIAL  " + chr(13) + chr(10)
cQry += "	AND  " + chr(13) + chr(10)
cQry += "	CVA_MODULO = '"+cMod+"'  " + chr(13) + chr(10)
cQry += "	AND  " + chr(13) + chr(10)
cQry += "	CVA_CODIGO = CT2_LP  " + chr(13) + chr(10)
cQry += "	AND  " + chr(13) + chr(10)
cQry += "	CVA.D_E_L_E_T_ = ' '   " + chr(13) + chr(10)

cQry += "WHERE " + chr(13) + chr(10)
cQry += "	CT2_FILIAL = '" + cFilSelect + "' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2_NODIA <> '' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2_DC <> '4' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2_MOEDLC = '01' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2_DATA BETWEEN '"+cDtIni+"' AND '"+cDtFim+"'	 " + chr(13) + chr(10)

cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2_CONFST IN (' ','1','2') " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2.D_E_L_E_T_=''" + chr(13) + chr(10)

cQry += "UNION " + chr(13) + chr(10)
cQry += "SELECT "+ chr(13) + chr(10)
cQry += cIdFil + ", " + chr(13) + chr(10)
cQry += cDataDoc
cQry += cNroDoc
cQry += cMoeDoc
cQry += cVlrDoc
cQry += cNodia
cQry += "	" + cAlias + ".D_E_L_E_T_ DELETADO, "+ chr(13) + chr(10)
cQry += "	CT2.R_E_C_N_O_ CT2_RECNO,  "+ chr(13) + chr(10)
cQry += "	CT2_FILIAL,  "+ chr(13) + chr(10)
cQry += "	CT2_DATA,  "+ chr(13) + chr(10)
cQry += "	CT2_TPSALD,  "+ chr(13) + chr(10)
cQry += "	CT2_LOTE,  "+ chr(13) + chr(10)
cQry += "	CT2_SBLOTE, "+ chr(13) + chr(10)
cQry += "	CT2_DOC, "+ chr(13) + chr(10)
cQry += "	CT2_SEQLAN,  "+ chr(13) + chr(10)
cQry += "	CT2_LINHA,  "+ chr(13) + chr(10)
cQry += "	CT2_MOEDLC, "+ chr(13) + chr(10)
cQry += "	CT2_LP,  "+ chr(13) + chr(10)
cQry += "	CT2_NODIA,  "+ chr(13) + chr(10)
cQry += "	CT2_DEBITO,  "+ chr(13) + chr(10)
cQry += "	CT2_CREDIT,  "+ chr(13) + chr(10)
cQry += "	CT2_CCD,  "+ chr(13) + chr(10)
cQry += "	CT2_CCC,  "+ chr(13) + chr(10)
cQry += "	CT2_ITEMD,  "+ chr(13) + chr(10)
cQry += "	CT2_ITEMC,  "+ chr(13) + chr(10)
cQry += "	CT2_CLVLDB,  "+ chr(13) + chr(10)
cQry += "	CT2_CLVLCR,  "+ chr(13) + chr(10)
cQry += cSelectEnt + chr(13) + chr(10)
cQry += "	CT2_VALOR,  "+ chr(13) + chr(10)
cQry += "	CT2_SEQUEN, "+ chr(13) + chr(10)
cQry += "	CT2_DC, "+ chr(13) + chr(10)
cQry += "	CT2_CONFST, "+ chr(13) + chr(10)
cQry += "	CT2.D_E_L_E_T_ CT2_DELET  "+ chr(13) + chr(10)
cQry += "FROM "+ chr(13) + chr(10)
cQry += "	" + RetSqlName(cAlias) + " " + cAlias + chr(13) + chr(10)
cQry += "LEFT JOIN "+ chr(13) + chr(10)
cQry += "	" + RetSQlName("CT2") + " CT2 "+ chr(13) + chr(10)
cQry += "ON " + chr(13) + chr(10)
cQry += "	" + cIdFil + " = CT2_FILIAL " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)

If "NO_" $ Upper(aConfig[NODIA])
   cQry += "	' ' = CT2_NODIA  " + chr(13) + chr(10)
Else
   cQry += "	" + aConfig[NODIA] + " = CT2_NODIA  " + chr(13) + chr(10)
Endif

cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2_NODIA <> '' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2_DC <> '4' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2_MOEDLC = '01' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2_DATA BETWEEN '"+cDtIni+"' AND '"+cDtFim+"' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2_CONFST IN (' ','1','2') " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2.D_E_L_E_T_ = ''" + chr(13) + chr(10)

cQry += "WHERE " + chr(13) + chr(10)
cQry += "	" + cIdFil + " = '" + cFilSelect + "' " + chr(13) + chr(10)

//Filtrar por data no arquivo Origem, ex: F1_EMISSAO, F2_EMISSAO
If ! "NO_DATA" $ cDataDoc
	cDataDoc := StrTran(cDataDoc,",","")
	cQry += " AND "
    cQry += cDataDoc + " BETWEEN '"+cDtIni+"' AND '"+cDtFim+"' " + chr(13) + chr(10)
EndIf


cQry += "	AND " + chr(13) + chr(10)
cQry += "	" + cAlias + ".D_E_L_E_T_=''" + chr(13) + chr(10)

cQry += "ORDER BY "+ chr(13) + chr(10)
cQry += "	CT2_FILIAL,  "+ chr(13) + chr(10)
cQry += "	CT2_DATA,  "+ chr(13) + chr(10)
cQry += "	CT2_LOTE,  "+ chr(13) + chr(10)
cQry += "	CT2_SBLOTE,  "+ chr(13) + chr(10)
cQry += "	CT2_DOC,  "+ chr(13) + chr(10)
cQry += "	CT2_LINHA,  "+ chr(13) + chr(10)
cQry += "	CT2_SEQLAN  "

cQry := ChangeQuery(cQry)

If Select("TRBCTB") > 0
	TRBCTB->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), "TRBCTB", .T., .F.)
TcSetField( "TRBCTB", aConfig[VLRDOC], "N", TamSx3("CT2_VALOR")[1], TamSx3("CT2_VALOR")[2] )

TRBCTB->(DbGotop())

If TRBCTB->(!eof())
	While TRBCTB->(!eof())
		aDataCV3 := Ctbc66CV3(TRBCTB->CT2_DATA,TRBCTB->CT2_SEQUEN,TRBCTB->CT2_SEQLAN,cFilSelect,TRBCTB->CT2_RECNO)
		nStatus := Ctbc66GRsc(,,"TRBCTB",2,aDataCV3,aConfig,@cBmpLeg)
		// monta condições apartir do Filtro
		lcond1:= (cSelecMvt == "2" 	.AND. nStatus == 3)
		lcond2:= (cSelecMvt == "1" 	.AND. (nStatus == 1 .OR. nStatus == 2))
		lcond3:= (cSelecMvt == "3"	.AND. nStatus != 0)
		lcond4:= (lCheckNDiv	.AND. nStatus == 0)

		If Empty(TRBCTB->DELETADO) .and. (!Empty(TRBCTB->&(aConfig[NRODOC])) .OR. !Empty(TRBCTB->&(aConfig[DATADOC])) .OR. !Empty(TRBCTB->&(aConfig[VLRDOC])))

			if lCond1 .OR. lCond2 .OR. lCond3 .OR. lCond4

				aAdd(aDataMod,cBmpLeg) // reservado para a legenda
				aAdd(aDataMod,TRBCTB->&(cIdFil))
				aAdd(aDataMod,cAlias)
				aAdd(aDataMod,stod(TRBCTB->&(aConfig[DATADOC])))	//data
				aAdd(aDataMod,TRBCTB->&(aConfig[NRODOC]))		//Documento

				If Valtype(TRBCTB->&(aConfig[MOEDOC])) == "N"
					cMoeMod := Alltrim(str(TRBCTB->&(aConfig[MOEDOC])))
				Else
					cMoeMod := Alltrim(TRBCTB->&(aConfig[MOEDOC]))
				Endif

				aAdd(aDataMod,cMoeMod)							//Moeda
				aAdd(aDataMod,TRBCTB->&(aConfig[VLRDOC]))		//Vrl Doc
				aAdd(aDataMod,TRBCTB->&(aConfig[NODIA]))		//Correlativo
				aAdd(aDataMod,aDataCV3[1])						//CV3_DEBITO
				aAdd(aDataMod,aDataCV3[2])						//CV3_CREDIT
				aAdd(aDataMod,aDataCV3[3])						//CV3_CCD
				aAdd(aDataMod,aDataCV3[4])						//CV3_CCC
				aAdd(aDataMod,aDataCV3[5])						//CV3_ITEMD
				aAdd(aDataMod,aDataCV3[6])						//CV3_ITEMC
				aAdd(aDataMod,aDataCV3[7])						//CV3_CLVLDB
				aAdd(aDataMod,aDataCV3[8])						//CV3_CLVLCR

				For nI := 1 to len(aDataCV3[9])
					aAdd(aDataMod,aDataCV3[9,nI])
				Next nI

				aAdd(aDataMod,nStatus)							//Adiciona codigo do status SEMPRE ao final do array, pois o relatorio lera o status dessa posicao
			else
				aDataMod := Array(16+(nQtdEnt*2))
				aFill(aDataMod,"")
				aDataMod[1] := LoadBitmap(GetResources(),"BR_VERMELHO")
				aDataMod[7] := 0
				aAdd(aDataMod,nStatus)							//Adiciona codigo do status SEMPRE ao final do array, pois o relatorio lera o status dessa posicao
			endif
		Else
			If Empty(TRBCTB->CT2_DELET)
				aDataMod := Array(16+(nQtdEnt*2))
				aFill(aDataMod,"")
				aDataMod[1] := LoadBitmap(GetResources(),"BR_VERMELHO")
				aDataMod[7] := 0
				aAdd(aDataMod,nStatus)							//Adiciona codigo do status SEMPRE ao final do array, pois o relatorio lera o status dessa posicao
			Endif
		Endif

		If Empty(TRBCTB->CT2_DELET) .AND. !Empty(TRBCTB->CT2_LOTE)
			aVlrMCtb := GetValMCT2(TRBCTB->CT2_NODIA,TRBCTB->CT2_SEQLAN,cFilSelect)

			aAdd(aDataCtb,TRBCTB->CT2_FILIAL)
			aAdd(aDataCtb,stod(TRBCTB->CT2_DATA))
			aAdd(aDataCtb,TRBCTB->CT2_TPSALD)
			aAdd(aDataCtb,TRBCTB->CT2_LOTE)
			aAdd(aDataCtb,TRBCTB->CT2_SBLOTE)
			aAdd(aDataCtb,TRBCTB->CT2_DOC)
			aAdd(aDataCtb,TRBCTB->CT2_LINHA)
			aAdd(aDataCtb,TRBCTB->CT2_LP)
			aAdd(aDataCtb,TRBCTB->CT2_SEQLAN)
			aAdd(aDataCtb,TRBCTB->CT2_NODIA)
			aAdd(aDataCtb,TRBCTB->CT2_DEBITO)
			aAdd(aDataCtb,TRBCTB->CT2_CREDIT)
			aAdd(aDataCtb,TRBCTB->CT2_CCD)
			aAdd(aDataCtb,TRBCTB->CT2_CCC)
			aAdd(aDataCtb,TRBCTB->CT2_ITEMD)
			aAdd(aDataCtb,TRBCTB->CT2_ITEMC)
			aAdd(aDataCtb,TRBCTB->CT2_CLVLDB)
			aAdd(aDataCtb,TRBCTB->CT2_CLVLCR)

			For nI := 1 to nQtdEnt
				aAdd(aDataCtb,TRBCTB->&(aEntities[1][nI,1]))
				aAdd(aDataCtb,TRBCTB->&(aEntities[2][nI,1]))
			Next nI

			aEval(aVlrMCtb,{|x| aAdd(aDataCtb,x)})

			aAdd(aDataCtb,TRBCTB->CT2_DC)

		Else
			If Empty(TRBCTB->DELETADO)
				aDataCtb := Array(19+(nQtdEnt*2)+len(aCtbc66Moe))
				aFill(aDataCtb,"")
				For nI := 19+(nQtdEnt*2) to len(aDataCtb)-1
					aDataCtb[nI] := 0
				Next nI
			Endif
		Endif

		nP := aScan(aResult,{|x| AllTrim(cMod) $ alltrim(x[1]) })

		If nP > 0
			If aResult[nP,2] == nil
				aResult[nP,2] := {}
			Endif

			If aResult[nP,3] == nil
				aResult[nP,3] := {}
			Endif
			if lCond1 .OR. lCond2 .OR. lCond3 .OR. lCond4
				aAdd(aResult[nP,2],aClone(aDataMod))
				aAdd(aResult[nP,3],aClone(aDataCtb))
			EndIf
			aDataMod := {}
			aDataCtb := {}
		Endif
		TRBCTB->(DbSkip())

	EndDo
Endif


If Select("TRBCTB") > 0
	TRBCTB->(DbCloseArea())
Endif

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FillInfCtb	³ Autor ³Fernando Radu Muscalu ³ Data ³ 29/08/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera massa de dados em memoria de acordo com os lancamentos     ³±±
±±³          ³contabeis manuais.								              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FillInfCtb(cDtIni,cDtfim,aResult,cFilSelect)					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cDtIni	- Tipo: C => Data inicial do periodo			      ³±±
±±³          ³cDtFim	- Tipo: C => Data final do periodo				      ³±±
±±³          ³aResult	- Tipo: A => Array com os dados comparativo Modulo X  ³±±
±±³          ³Contabilidade													  ³±±
±±³          ³cFilSelect- Tipo: C => Filiais selecionadas					  ³±±
±±³          ³cSelecMvt - Tipo: C => seleciona movimentos					  	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil									                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FillInfCtb(cDtIni,cDtfim,aResult,cFilSelect,cSelecMvt)

Local cQry			:= ""
Local cSelectEnt    := ""

Local aDataCtb		:= {}
Local aVlrMCtb		:= {}
Local aEntities 	:= Ctbc66RetEnt()

Local nP			:= 0
Local nI			:= 0
Local nQtdEnt		:= len(aEntities[1])

cFilSelect:=xfilial("CT2",cFilSelect)

For nI := 1 to nQtdEnt
	cSelectEnt += alltrim(aEntities[1][nI,1])+ ", " + alltrim(aEntities[2][nI,1]) + ", "
Next nI

cQry := "SELECT " + chr(13) + chr(10)
cQry += "	CT2_FILIAL,   " + chr(13) + chr(10)
cQry += "	CT2_DATA,   " + chr(13) + chr(10)
cQry += "	CT2_TPSALD,   " + chr(13) + chr(10)
cQry += "	CT2_LOTE,   " + chr(13) + chr(10)
cQry += "	CT2_SBLOTE,  " + chr(13) + chr(10)
cQry += "	CT2_DOC,  " + chr(13) + chr(10)
cQry += "	CT2_SEQLAN,   " + chr(13) + chr(10)
cQry += "	CT2_LINHA,   " + chr(13) + chr(10)
cQry += "	CT2_MOEDLC,  " + chr(13) + chr(10)
cQry += "	CT2_LP,   " + chr(13) + chr(10)
cQry += "	CT2_NODIA,   " + chr(13) + chr(10)
cQry += "	CT2_DEBITO,   " + chr(13) + chr(10)
cQry += "	CT2_CREDIT,   " + chr(13) + chr(10)
cQry += "	CT2_CCD,   " + chr(13) + chr(10)
cQry += "	CT2_CCC,   " + chr(13) + chr(10)
cQry += "	CT2_ITEMD,   " + chr(13) + chr(10)
cQry += "	CT2_ITEMC,   " + chr(13) + chr(10)
cQry += "	CT2_CLVLDB,   " + chr(13) + chr(10)
cQry += cSelectEnt + chr(13) + chr(10)
cQry += "	CT2_CLVLCR,   " + chr(13) + chr(10)
cQry += "	CT2_VALOR,   " + chr(13) + chr(10)
cQry += "	CT2_SEQUEN,  " + chr(13) + chr(10)
cQry += "	CT2_DC " + chr(13) + chr(10)
cQry += "FROM " + chr(13) + chr(10)
cQry += "	" + RetSQLName("CT2") + " CT2 " + chr(13) + chr(10)
cQry += "WHERE " + chr(13) + chr(10)
cQry += "	CT2_FILIAL = '" + cFilSelect + "' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2.D_E_L_E_T_ = ' ' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2_DATA BETWEEN '"+cDtIni+"' AND '"+cDtFim+"' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2_DC <> '4' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2_LP < '500' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2_MOEDLC = '01' " + chr(13) + chr(10)

cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2_CONFST IN (' ','1','2') " + chr(13) + chr(10)

cQry += "ORDER BY " + chr(13) + chr(10)
cQry += "	CT2_DATA,  " + chr(13) + chr(10)
cQry += "	CT2_LOTE, " + chr(13) + chr(10)
cQry += "	CT2_SBLOTE, " + chr(13) + chr(10)
cQry += "	CT2_DOC, " + chr(13) + chr(10)
cQry += "	CT2_LINHA, " + chr(13) + chr(10)
cQry += "	CT2_SEQLAN "

cQry := ChangeQuery(cQry)

If Select("TRBCTB") > 0
	TRBCTB->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), "TRBCTB", .T., .F.)

TRBCTB->(DbGotop())

If TRBCTB->(!eof())
	While TRBCTB->(!eof())

		aVlrMCtb := GetValMCT2(TRBCTB->CT2_NODIA,TRBCTB->CT2_SEQLAN,cFilSelect)

		aAdd(aDataCtb,TRBCTB->CT2_FILIAL)
		aAdd(aDataCtb,stod(TRBCTB->CT2_DATA))
	    aAdd(aDataCtb,TRBCTB->CT2_TPSALD)
	    aAdd(aDataCtb,TRBCTB->CT2_LOTE)
	    aAdd(aDataCtb,TRBCTB->CT2_SBLOTE)
	    aAdd(aDataCtb,TRBCTB->CT2_DOC)
	    aAdd(aDataCtb,TRBCTB->CT2_LINHA)
	    aAdd(aDataCtb,TRBCTB->CT2_LP)
	    aAdd(aDataCtb,TRBCTB->CT2_SEQLAN)
	    aAdd(aDataCtb,TRBCTB->CT2_NODIA)
	    aAdd(aDataCtb,TRBCTB->CT2_DEBITO)
	    aAdd(aDataCtb,TRBCTB->CT2_CREDIT)
	    aAdd(aDataCtb,TRBCTB->CT2_CCD)
	    aAdd(aDataCtb,TRBCTB->CT2_CCC)
	    aAdd(aDataCtb,TRBCTB->CT2_ITEMD)
	    aAdd(aDataCtb,TRBCTB->CT2_ITEMC)
	    aAdd(aDataCtb,TRBCTB->CT2_CLVLDB)
	    aAdd(aDataCtb,TRBCTB->CT2_CLVLCR)

	    For nI := 1 to nQtdEnt
	    	aAdd(aDataCtb,TRBCTB->&(aEntities[1][nI,1]))
	    	aAdd(aDataCtb,TRBCTB->&(aEntities[2][nI,1]))
	    Next nI

	    aEval(aVlrMCtb,{|x| aAdd(aDataCtb,x)})

	    aAdd(aDataCtb,TRBCTB->CT2_DC)

		TRBCTB->(Dbskip())

		nP := aScan(aResult,{|x| "34" $ alltrim(x[1]) })

		If nP > 0

			If aResult[nP,3] == nil
				aResult[nP,3] := {}
			Endif

	 		aAdd(aResult[nP,3],aClone(aDataCtb)	)

	 		aDataCtb := {}
		Endif
    EndDo

Endif

If Select("TRBCTB") > 0
	TRBCTB->(DbCloseArea())
Endif

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbC66Scr  	³ Autor ³Fernando Radu Muscalu ³ Data ³ 29/08/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Montagem da interface da quadratura contabil				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbC66Scr(aSelected,aResultSet)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aSelected	- Tipo: A => Modulos selecionados				      ³±±
±±³          ³aResultSet- Tipo: A => Array com os dados comparativo Modulo X  ³±±
±±³          ³Contabilidade													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil									                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbC66Scr(aSelected,aResultSet)

Local oDlg
Local oFolderFil
Local oBrwMod
Local oBrwCtb

Local aSizeDlg		:= FwGetDialogsize(oMainWnd)
Local aButtons		:= {}

Local aFolderFil	:= {}
Local aScrLayer	 	:= {}
Local aBrwMod		:= {}
Local aBrwCtb		:= {}
Local aFModulos		:= {}

Local nHeight		:= aSizeDlg[3]
Local nWidth    	:= aSizeDlg[4]
Local nI			:= 0
Local nX            := 0

Local bBtnOk		:= {|| 	oDlg:End() }
Local bBtnCanc		:= {|| 	oDlg:End() }
Local bEnchBar		:= {||	EnchoiceBar(oDlg,bBtnOk,bBtnCanc,,aButtons) }

aEval(aCtbc66Fil,{|x| aAdd(aFolderFil,x+"-"+ Alltrim(SM0->(GetAdvFVal("SM0","M0_FILIAL",cEmpAnt+x,1,"")))   )})

aAdd(aButtons,{"EDITAR"           ,{|| CT660Conf(oFolderFil,aFModulos,aBrwMod,aBrwCtb,aResultSet)},STR0045})			//"Conferir"
aAdd(aButtons,{"EDITAR"			  ,{|| CT660Reve(oFolderFil,aFModulos,aBrwMod,aBrwCtb,aResultSet)},STR0046})			//"Reverter"
aAdd(aButtons,{"VISUAL"			  ,{|| CT660Dive(oFolderFil,aFModulos,aBrwMod,aBrwCtb,aResultSet)},STR0047})			//"Divergencias"
aAdd(aButtons,{"TOTVSPRINTER_LOGO",{|| CTBR660A(aResultSet)}   ,STR0023})		//"Imprimir"
aAdd(aButtons,{"S4WB011N"         ,{|| CTBC66Leg()}           ,STR0024})		//"Legenda"

DEFINE MSDIALOG oDlg FROM 0,0 TO nHeight-15, nWidth-30 TITLE STR0005 PIXEL STYLE DS_MODALFRAME of oMainWnd //## "Relatório de Auditoria"

    oFolderFil := TFolder():New(10,0,aFolderFil,aFolderFil,oDlg,,,,.T.,,nWidth/2-15,nHeight/2-15)
	aFModulos := CtbC66FMod(oFolderFil,aSelected)
    aScrLayer := CtbC66Layer(aFModulos)

	CtbC66Load(aScrLayer,oFolderFil,aFModulos,aBrwMod,aBrwCtb,aResultSet)

oDlg:Activate(,,,.T.,,,bEnchBar)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbC66FMod  	³ Autor ³Fernando Radu Muscalu ³ Data ³ 29/08/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Montagem das abas dos modulos selecionados.					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbC66FMod(oFolderFil,aSelected)								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oFolderFil- Tipo: O => Objeto da Folder das Filiais 			  ³±±
±±³          ³aSelected	- Tipo: A => Modulos selecionados				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aRetMod	- Tipo: A => Array com os objetos tFolder dos         ³±±
±±³          ³modulos de acordo com as filiais						          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbC66FMod(oFolderFil,aSelected)

Local aRetMod	:= array(len(oFolderFil:aDialogs))
Local aFolder	:= {}
Local aSizeDlg	:= {}

Local nI		:= 0
Local nWidth	:= 0
Local nHeight	:= 0

//Montagem dos Folders de acordo com os modulo selecionados
For nI := 1 to len(aSelected)
	aAdd(aFolder,alltrim(aSelected[nI,1])+"-"+alltrim(aSelected[nI,2]))
Next nI

For nI := 1 to len(aRetMod)

	aSizeDlg := FwGetDialogsize(oFolderFil:aDialogs[nI])

	nHeight		:= aSizeDlg[3]
	nWidth    	:= aSizeDlg[4]

	aRetMod[nI] := TFolder():New(0,0,aFolder,aFolder,oFolderFil:aDialogs[nI],,,,.T.,,nWidth/2-15,nHeight/2-30 )
Next nI

Return(aRetMod)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbC66Layer  	³ Autor ³Fernando Radu Muscalu ³ Data ³ 29/08/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Montagem das layers.											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbC66Layer(aFModulos)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aFModulos	- Tipo: A => Array com os objetos tfolders dos Modulos³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aLayers	- Tipo: A => Array com os objetos das layers	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbC66Layer(aFModulos)

Local cSufix	:= ""

Local nI		:= 0
Local nX		:= 0

Local aAuxLay	:= {}
Local aLayers	:= {}

For nI := 1 to len(aFModulos)

	aAuxLay := array(len(aFModulos[nI]:aDialogs))

	For nX := 1 to len(aAuxLay)

		cSufix := strzero(nI,2)+strzero(nX,2)

		If "34" $ aFModulos[nI]:aDialogs[nX]:cCaption
			aAuxLay[nX] := fwLayer():New()

			aAuxLay[nX]:init(aFModulos[nI]:aDialogs[nX],.F.)

			aAuxLay[nX]:addLine("Linha"+cSufix,100,.t.)
			aAuxLay[nX]:addCollumn("ColCtb"+cSufix,100,.t.,"Linha"+cSufix)
			aAuxLay[nX]:addWindow("ColCtb"+cSufix,"WinCtb"+cSufix,aFModulos[nI]:aDialogs[nX]:cCaption,100,.f.,.t.,{||},"Linha"+cSufix)
		Else
			aAuxLay[nX] := fwLayer():New()

			aAuxLay[nX]:init(aFModulos[nI]:aDialogs[nX],.F.)

			aAuxLay[nX]:addLine("Linha"+cSufix,100,.t.)

			aAuxLay[nX]:addCollumn("ColMod"+cSufix,50,.t.,"Linha"+cSufix)
			aAuxLay[nX]:addCollumn("ColCtb"+cSufix,50,.t.,"Linha"+cSufix)

			aAuxLay[nX]:addWindow("ColMod"+cSufix,"WinMod"+cSufix,aFModulos[nI]:aDialogs[nX]:cCaption,100,.f.,.t.,{||},"Linha"+cSufix)
			aAuxLay[nX]:addWindow("ColCtb"+cSufix,"WinCtb"+cSufix,"34-"+STR0025 ,100,.f.,.t.,{||},"Linha"+cSufix)//##"Contabilidad de Gestion"
		Endif
	Next nX

	aAdd(aLayers,aClone(aAuxLay))
	aAuxLay := {}
Next nI

Return(aLayers)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbC66Load  	³ Autor ³Fernando Radu Muscalu ³ Data ³ 29/08/11   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Montagem das abas dos modulos selecionados.					   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbC66Load(aScrLayer,oFolderFil,aFModulos,aBrwMod,aBrwCtb,	   ³±±
±±³          ³aResultSet)													   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aScrLayer	- Tipo: A => Array com os objetos das layers		   ³±±
±±³          ³oFolderFil- Tipo: O => Objeto da Folder das Filiais 			   ³±±
±±³          ³aFModulos	- Tipo: A => Array com os objetos tfolders dos Modulos ³±±
±±³          ³aBrwMod	- Tipo: A => Array com os objetos twBrowses dos Modulos³±±
±±³          ³aBrwCtb	- Tipo: A => Array com os objetos twBrowses do CTB	   ³±±
±±³          ³aResultSet- Tipo: A => Array com os dados comparativo Modulo X   ³±±
±±³          ³Contabilidade													   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil													           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbC66Load(aScrLayer,oFolderFil,aFModulos,aBrwMod,aBrwCtb,aResultSet)

Local oPnlMod
Local oPnlCtb

Local nI			:= 0
Local nX			:= 0
Local nZ			:= 0

Local cSufix		:= ""
Local cLineMod		:= ""
Local cLineCtb		:= ""

Local aHeadMod		:= CTBC66GetHBrw(1)//cabecalho do browse dos dados do Modulo
Local aHeadCtb		:= CTBC66GetHBrw(2)//cabecalho do browse dos dados da contabilidade
Local aCabMod		:= {}
Local aCabCtb		:= {}//cabecalho do browse dos dados da contabilidade
Local aSizeMod		:= {}
Local aSizeCtb		:= {}
Local aTipoMod		:= {}
Local aTipoCtb		:= {}
Local aAuxBrwMod	:= {}
Local aAuxBrwCtb	:= {}

aBrwMod	:= Array(len(oFolderFil:aDialogs),len(aFModulos[1]:aDialogs))
aBrwCtb	:= Array(len(oFolderFil:aDialogs),len(aFModulos[1]:aDialogs))

aEval(aHeadMod,{|x| aAdd(aCabMod,x[1]),aAdd(aSizeMod,x[2]),aAdd(aTipoMod,x[3]) })
aEval(aHeadCtb,{|x| aAdd(aCabCtb,x[1]),aAdd(aSizeCtb,x[2]),aAdd(aTipoCtb,x[3]) })

For nI := 1 to len(oFolderFil:aDialogs)

	For nX := 1 to len(aFModulos[nI]:aDialogs)
		cSufix := strzero(nI,2)+strzero(nX,2)

		If "34" $ aFModulos[nI]:aDialogs[nX]:cCaption

			For nZ := 1 to len(aCabCtb)
				If aTipoCtb[nZ] == "N"
					cLineCtb += "Transform(aResultSet["+str(nI)+",2,"+str(nX)+",3][aBrwCtb["+str(nI)+","+str(nX)+"]:nAt,"+alltrim(str(nZ))+"],PesqPict('CT2','CT2_VALOR')),"
				Else
					cLineCtb += "aResultSet["+str(nI)+",2,"+str(nX)+",3][aBrwCtb["+str(nI)+","+str(nX)+"]:nAt,"+alltrim(str(nz))+"],"
				Endif
			Next nZ

			cLineCtb := Substr(cLineCtb,1,len(cLineCtb)-1)

			oPnlCtb	:= aScrLayer[nI,nX]:getWinPanel("ColCtb"+cSufix,"WinCtb"+cSufix,"Linha"+cSufix)

			If aBrwCtb[nI,nX] == nil
				aBrwCtb[nI,nX] := TWBrowse():New(0,0,0,0,,aCabCtb,aSizeCtb,oPnlCtb,,,,,,,,,,,,.F.,,.T.,,.F.,,, )
			Endif

			aBrwCtb[nI,nX]:Align := CONTROL_ALIGN_ALLCLIENT
			aBrwCtb[nI,nX]:SetArray(aResultSet[nI,2,nX,3])
			aBrwCtb[nI,nX]:bLine := &("{|| {" + cLineCtb + "}}")
			aBrwCtb[nI,nX]:Refresh()

		Else

			For nZ := 1 to len(aCabMod)
				If aTipoMod[nZ] == "N"
					cLineMod += "Transform(aResultSet["+str(nI)+",2,"+str(nX)+",2][aBrwMod["+str(nI)+","+str(nX)+"]:nAt,"+alltrim(str(nZ))+"],PesqPict('CT2','CT2_VALOR')),"
				Else
					cLineMod += "aResultSet["+str(nI)+",2,"+str(nX)+",2][aBrwMod["+str(nI)+","+str(nX)+"]:nAt,"+alltrim(str(nZ))+"],"
				Endif
			Next nX

			cLineMod := Substr(cLineMod,1,len(cLineMod)-1)

			For nZ := 1 to len(aCabCtb)
				If aTipoCtb[nZ] == "N"
					cLineCtb += "Transform(aResultSet["+str(nI)+",2,"+str(nX)+",3][aBrwCtb["+str(nI)+","+str(nX)+"]:nAt,"+alltrim(str(nZ))+"],PesqPict('CT2','CT2_VALOR')),"
				Else
					cLineCtb += "aResultSet["+str(nI)+",2,"+str(nX)+",3][aBrwCtb["+str(nI)+","+str(nX)+"]:nAt,"+alltrim(str(nz))+"],"
				Endif
			Next nZ

			cLineCtb := Substr(cLineCtb,1,len(cLineCtb)-1)

			oPnlMod	:= aScrLayer[nI,nX]:getWinPanel("ColMod"+cSufix,"WinMod"+cSufix,"Linha"+cSufix)
			oPnlCtb	:= aScrLayer[nI,nX]:getWinPanel("ColCtb"+cSufix,"WinCtb"+cSufix,"Linha"+cSufix)

			If aBrwMod[nI,nX] == nil
				aBrwMod[nI,nX] := TWBrowse():New(0,0,0,0,,aCabMod,aSizeMod,oPnlMod,,,,,,,,,,,,.F.,,.T.,,.F.,,, )
				aBrwMod[nI,nX]:nFreeze := 1
			endif

			If aBrwCtb[nI,nX] == nil
				aBrwCtb[nI,nX] := TWBrowse():New(0,0,0,0,,aCabCtb,aSizeCtb,oPnlCtb,,,,,,,,,,,,.F.,,.T.,,.F.,,, )
			Endif
			if !empty(aResultSet[nI,2,nX,2])
				aBrwMod[nI,nX]:Align := CONTROL_ALIGN_ALLCLIENT
				aBrwCtb[nI,nX]:Align := CONTROL_ALIGN_ALLCLIENT

				aBrwMod[nI,nX]:bChange := &("{|| aBrwCtb["+str(nI)+","+str(nX)+"]:GoPosition(aBrwMod["+str(nI)+","+str(nX)+"]:nAt)}")
				aBrwCtb[nI,nX]:bChange := &("{|| aBrwMod["+str(nI)+","+str(nX)+"]:GoPosition(aBrwCtb["+str(nI)+","+str(nX)+"]:nAt)}")

				//aBrwMod[nI,nX]:bLDblClick := {||  CTC660ConfLanc() }
				aBrwMod[nI,nX]:SetArray(aResultSet[nI,2,nX,2])
				aBrwCtb[nI,nX]:SetArray(aResultSet[nI,2,nX,3])

				aBrwMod[nI,nX]:bLine := &("{|| {" + cLineMod + "}}")
				aBrwCtb[nI,nX]:bLine := &("{|| {" + cLineCtb + "}}")

				aBrwMod[nI,nX]:nClrBackFocus := 0
				aBrwCtb[nI,nX]:nClrBackFocus := 0

				aBrwMod[nI,nX]:nClrForeFocus := 0
				aBrwCtb[nI,nX]:nClrForeFocus := 0

				aBrwMod[nI,nX]:Refresh()
				aBrwCtb[nI,nX]:Refresh()
			endif
		Endif

		cLineMod := ""
		cLineCtb := ""

	Next nX

Next nI

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GetClauseInArray³ Autor ³Fernando Radu Muscalu ³ Data ³ 29/08/11   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera String da clausula IN de um select de query a partir de um 	 ³±±
±±³          ³array bidimensional											 	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GetClauseInArray(aArray,nInd)									     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aArray- Tipo: A => dados a serem convertidos 			             ³±±
±±³          ³nInd	- Tipo: N => Coluna de aArray utilizada na geracao da string ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cRet	- Tipo: C => String com a clausula IN			             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function GetClauseInArray(aArray,nInd)

Local nI 	:= 0

Local cRet	:= ""

Default nInd	:= 1

If Len(aArray) == 1
	cRet := " = "
	cRet += "'" + Alltrim(aArray[1,nInd]) + "'"
Else
	cRet := " IN("

	For nI := 1 to len(aArray)
		cRet += "'" + Alltrim(aArray[nI,nInd]) + "',"
	Next nI

	cRet := Substr(cRet,1,len(cRet)-1) + ")"
Endif

Return(cRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CTBOrdSIXByChave³ Autor ³Fernando Radu Muscalu ³ Data ³ 29/08/11   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atraves da chave, busca-se a ordem do indice					 	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTBOrdSIXByChave(cAlias,cChave)								     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias- Tipo: C => Alias do arquivo								 ³±±
±±³          ³cCahve- Tipo: C => Chave a ser buscada no SIX						 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³nOrdem- Tipo: N => Ordem da chave no SIX				             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTBOrdSIXByChave(cAlias,cChave)

Local nOrdem	:= 0
Local aAreaSIX	:= SIX->(GetArea())

SIX->(DbSetOrder(1))

SIX->(DbSeek(cAlias))

While !SIX->(Eof()) .and. Alltrim(SIX->INDICE) == Alltrim(cAlias)
	If Alltrim(cChave) $ Alltrim(SIX->CHAVE)
		If !IsAlpha(SIX->ORDEM)
			nOrdem := Val(SIX->ORDEM)
		Else
			nOrdem := Asc(UPPER(SIX->ORDEM))-55
		Endif
		Exit
	Endif
	SIX->(DbSkip())
EndDo

RestArea(aAreaSIX)
Return(nOrdem)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbcQCLoad	  ³ Autor ³Fernando Radu Muscalu ³ Data ³ 29/08/11   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Carrega os campos necessario para gerar informacoes das tabelas do ³±±
±±³          ³modulo gerador dos lancamentos								 	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbcQCLoad(aSelected)											     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aSelected- Tipo: A => Modulos selecionados 			             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aRet	- Tipo: A => Campos que devem ser utilizados pelas tabelas   ³±±
±±³          ³do modulo gerador													 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbcQCLoad(aSelected)

Local aRet		:= {}
Local aAux		:= {}
Local aAreaSx3	:= SX3->(GetArea())
Local aNrDoc	:= {}

Local cQry		:= ""
Local cRetMod	:= GetClauseInArray(aSelected)
Local cConteudo	:= ""
Local cCampo	:= ""
Local cAuxCont	:= ""

Local lExistX3	:= .f.

Local nI		:= 0
Local nX		:= 0
Local nZ		:= 0
Local nPos		:= 0

cQry := "SELECT " + chr(13) + chr(10)
cQry += "	DISTINCT CTL_ALIAS, " + chr(13) + chr(10)
cQry += "	CTL_QCDATA, " + chr(13) + chr(10)
cQry += "	CTL_QCDOC, " + chr(13) + chr(10)
cQry += "	CTL_QCMOED, " + chr(13) + chr(10)
cQry += "	CTL_QCVLRD, " + chr(13) + chr(10)
cQry += "	CTL_QCCORR " + chr(13) + chr(10)
cQry += "FROM " + chr(13) + chr(10)
cQry += "	" + RetSQLName("CTL") + " CTL " + chr(13) + chr(10)
cQry += "INNER JOIN " + chr(13) + chr(10)
cQry += "	" + RetSQLName("CVA") + " CVA " + chr(13) + chr(10)
cQry += "ON " + chr(13) + chr(10)
cQry += "	CVA_FILIAL = CTL_FILIAL " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CVA_CODIGO = CTL_LP " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CVA_MODULO " + cRetMod
cQry += "	AND	 " + chr(13) + chr(10)
cQry += "	CVA.D_E_L_E_T_ = ' ' " + chr(13) + chr(10)
cQry += "WHERE " + chr(13) + chr(10)
cQry += "	CTL.D_E_L_E_T_ = ' ' " + chr(13) + chr(10)
cQry += "ORDER BY " + chr(13) + chr(10)
cQry += "	CTL_ALIAS  "

cQry := ChangeQuery(cQry)

If Select("TRBCTL") > 0
	TRBCTL->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), "TRBCTL", .T., .F.)

While TRBCTL->(!Eof())

  	lExistX3 := .f.

	For nI := 1 to TRBCTL->(FCount())

		cConteudo	:= TRBCTL->(FieldGet(nI))
		cCampo		:= Alltrim(TRBCTL->(FieldName(nI)))

		SX3->(DbSetOrder(2))//campo

		If Alltrim(cCampo) == "CTL_QCDOC"
			aNrDoc := Separa(cConteudo,"+")

			If Len(aNrDoc) > 0
				For nX := 1 to Len(aNrDoc)

					If ( nPos := AT("(",aNrDoc[nX]) ) > 0
						cConteudo := ""
						For nZ := nPos to len(aNrDoc[nX])
							If Substr(aNrDoc[nX],nZ,1) $ "(*)"
								Loop
							Endif

							cAuxCont += Substr(aNrDoc[nX],nZ,1)

						Next nZ

						aNrDoc[nX] 	:= cAuxCont

					Endif

					If !("FILIAL" $ aNrDoc[nX])
						lExistX3 := SX3->(DbSeek(aNrDoc[nX]))
					Endif
				Next nX

				If lExistX3 .and. !Empty(cAuxCont)
					For nX := 1 to len(aNrDoc)
						cConteudo += aNrDoc[nX]+ "+"
					Next nX
					cAuxCont	:= ""
					cConteudo 	:= Substr(cConteudo,1,Rat("+",cConteudo)-1)
				Endif

			Else
				lExistX3 := SX3->(DbSeek(cConteudo))
			Endif
		Else
			lExistX3 := SX3->(DbSeek(cConteudo))
		Endif

		If (!Empty(cConteudo) .and. lExistX3 ) .or. cCampo == "CTL_ALIAS"
			aAdd(aAux,cConteudo)
		Else
			Do Case
			Case cCampo == "CTL_QCDATA"
				aAdd(aAux,"NO_DATA")
			Case cCampo == "CTL_QCDOC"
				aAdd(aAux,"NO_DOC")
			Case cCampo == "CTL_QCMOED"
				aAdd(aAux,"NO_MOEDA")
			Case cCampo == "CTL_QCVLRD"
				aAdd(aAux,"NO_VALOR")
			Case cCampo == "CTL_QCCORR"
				aAdd(aAux,"NO_NODIA")
			EndCase
		Endif
	Next nI

	If !Empty(aAux[2])
		nX := At("_",aAux[2])
		If !(aAux[1] == IIF(nX == 3, "S"+Substr(aAux[2],1,2), Substr(aAux[2],1,3)))
			aAux[1] := IIF(nX == 3, "S"+Substr(aAux[2],1,2), Substr(aAux[2],1,3))
		EndIf
	EndIf

	aAdd(aRet,aAux)
	aAux := {}
	//aAdd(aRet,{TRBCTL->CTL_ALIAS,TRBCTL->CTL_QCDATA,TRBCTL->CTL_QCDOC,TRBCTL->CTL_QCMOED,TRBCTL->CTL_QCVLRD,TRBCTL->CTL_QCCORR})
	TRBCTL->(DbSkip())
EndDo

TRBCTL->(DbCloseArea())

RestArea(aAreaSX3)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Problemas encontrados no modulo SIGAATF; somente SN3 esta, atualmente, sendo rastreado em CV3 ³
//³ **  Nao conformidade a ser resolvida: SN3->N3_NODIA nao esta sendo gravado ! *** 02/01/2013   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc $ "ARG/CHI"

   For nI := 1 TO Len( aRet )

       If aRet[ nI ][ 1 ] == "SN4" .OR. ( aRet[ nI ][ 1 ] == "SN3" .And. aRet[ nI ][ 2 ] == "NO_DATA" )

          // aAdd( aRet,{ TRBCTL->CTL_ALIAS,TRBCTL->CTL_QCDATA,TRBCTL->CTL_QCDOC,TRBCTL->CTL_QCMOED,TRBCTL->CTL_QCVLRD,TRBCTL->CTL_QCCORR } )
          aRet[ nI ][ 1 ] := "SN3"
          aRet[ nI ][ 2 ] := "N3_AQUISIC"
          aRet[ nI ][ 3 ] := "N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ"
          aRet[ nI ][ 4 ] := "NO_MOEDA"
          aRet[ nI ][ 5 ] := "N3_VORIG1"
          aRet[ nI ][ 6 ] := "N3_NODIA"

       EndIf

   Next nI

EndIf

Return(aRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CTBC66GetHBrw	³ Autor ³Fernando Radu Muscalu ³ Data ³ 29/08/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera as colunas dos objetos tWBrowse referentes ao modulo e a   ³±±
±±³          ³contabilidade													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTBC66GetHBrw(nCabTipo)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nCabTipo	- Tipo: N => Tipo de cabecalho a ser montado          ³±±
±±³          ³				1 = Modulo									      ³±±
±±³          ³				2 = Contabilidade				      			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aRetCab	- Tipo: A => Dados para a formacao das colunas dos    ³±±
±±³          ³objetos twBrowse											      ³±±
±±³          ³	aRetCab[n,1] - Tipo: C => Titulo da coluna				      ³±±
±±³          ³	aRetCab[n,2] - Tipo: N => Tamanho da coluna				      ³±±
±±³          ³	aRetCab[n,3] - Tipo: C => Tipo de dado da coluna		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTBC66GetHBrw(nCabTipo)

Local aRetCab		:= {}
Local aTitulo		:= {}
Local aAux			:= {}
Local aEntidades	:= Ctbc66RetEnt()

Local nI		:= 0

If nCabTipo == 1

	aAux := {	" ",;
	            "CT2_FILIAL",;
				STR0026,; 	//##"Arquivo"
				STR0027,;	//## "Data"
				STR0028,;	//##"Documento"
				"CT2_MOEDLC",;
				STR0029,;	//##"Valor Doc."
				"CT2_NODIA",;
				"CT2_DEBITO",;
				"CT2_CREDIT",;
				"CT2_CCD",;
				"CT2_CCC",;
				"CT2_ITEMD",;
				"CT2_ITEMC",;
				"CT2_CLVLDB",;
				"CT2_CLVLCR"}

	For nI := 1 to len(aEntidades[1])
		aAdd(aAux,aEntidades[1,nI,1])
		aAdd(aAux,aEntidades[2,nI,1])
	Next nI
Else
	aAux := {	"CT2_FILIAL",;
				"CT2_DATA",;
				"CT2_TPSALD",;
				"CT2_LOTE",;
				"CT2_SBLOTE",;
				"CT2_DOC",;
				"CT2_LINHA",;
				"CT2_LP",;
				"CT2_SEQLAN",;
				"CT2_NODIA",;
				"CT2_DEBITO",;
				"CT2_CREDIT",;
				"CT2_CCD",;
				"CT2_CCC",;
				"CT2_ITEMD",;
				"CT2_ITEMC",;
				"CT2_CLVLDB",;
				"CT2_CLVLCR"}

	For nI := 1 to len(aEntidades[1])
		aAdd(aAux,aEntidades[1,nI,1])
		aAdd(aAux,aEntidades[2,nI,1])
	Next nI

	aEval(aCtbc66Moe,{|x| aAdd(aAux,alltrim(x[3])) })

Endif

For nI := 1 to len(aAux)
	If nCabTipo == 1
		If nI == 7
			aTitulo := Ctbc66GCpoTit("CT2",aAux[nI],"N")
		Else
			aTitulo := Ctbc66GCpoTit("CT2",aAux[nI])
		Endif
	Else
		If nI > 18+len(aEntidades[1])*2
			aTitulo := Ctbc66GCpoTit("CT2",aAux[nI],"N")
		Else
			aTitulo := Ctbc66GCpoTit("CT2",aAux[nI])
		Endif
	EndIf
	aAdd(aRetCab,{aTitulo[1],aTitulo[2],aTitulo[3]})
Next nI


Return(aRetCab)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctbc66GCpoTit	³ Autor ³Fernando Radu Muscalu ³ Data ³ 29/08/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera as informacoes necessarias para a criacao das colunas      ³±±
±±³          ³dos objetos tWBrowse referentes ao modulo e a contabilidade	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctbc66GCpoTit(cAlias,cField,cTipoDef)							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias	- Tipo: C => Alias do arquivo 				          ³±±
±±³          ³cField	- Tipo: C => Campo									  ³±±
±±³          ³cTipoDef	- Tipo: C => tipo de dado que coluna ira assumir	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aRet	- Tipo: A => Informacoes das colunas				      ³±±
±±³          ³	aRet[1] - Tipo: C => Titulo da coluna		   			      ³±±
±±³          ³	aRet[2] - Tipo: N => Tamanho da coluna					      ³±±
±±³          ³	aRet[3] - Tipo: C => Tipo de dado da coluna		    		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctbc66GCpoTit(cAlias,cField,cTipoDef)

Local aRet			:= {}
Local aAreaSX3		:= SX3->(GetArea())

Local cTitulo		:= ""
Local cTipo			:= ""

Local nConst		:= 2.5
Local nVal			:= 0

Default cTipoDef	:= "C"

SX3->(DbSetOrder(2))//campo

If "_" $ cField .and. SX3->(DbSeek(cField))
	cTitulo := (cAlias)->(RetTitle(cField))
	nVal 	:= ( TamSx3(cField)[1]*nConst )+( len(cTitulo)*nConst )
	cTipo 	:= Alltrim(SX3->X3_TIPO)
Else
	cTitulo := cField
	nVal	:= 40 + (len(cTitulo)*nConst)
	cTipo	:= cTipoDef
Endif

aRet := {cTitulo,nVal,cTipo}

RestArea(aAreaSX3)
Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbC66GMoe	³ Autor ³Fernando Radu Muscalu ³ Data ³ 29/08/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna as moedas cadastradas que nao estao bloqueadas 	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbC66GMoe()													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³      	                              				          	 	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aRet	- Tipo: A => Moedas do cadastradas na tab. CTO		    ³±±
±±³          ³	aRet[n,1] - Tipo: C => Titulo da coluna		   			    ³±±
±±³          ³	aRet[n,2] - Tipo: N => Tamanho da coluna				      	 ³±±
±±³          ³	aRet[n,3] - Tipo: C => Tipo de dado da coluna	    		  	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbC66GMoe()

Local cFilCTO	:= xFilial("CTO")

Local aRet 		:= {}
Local aAreaCTO  := CTO->(GetArea())

CTO->(dbsetorder(1))

If Empty(cFilCTO)
	CTO->(dbGotop())
Else
	CTO->(DbSeek(cFilCTO))
Endif

While CTO->(!Eof()) .and. xFilial("CTO") == CTO->CTO_FILIAL
	If Alltrim(CTO->CTO_BLOQ) == "2"
		aAdd(aRet,{CTO->CTO_MOEDA,CTO->CTO_SIMB,CTO->CTO_DESC})
	Endif
	CTO->(DbSkip())
EndDo

Restarea(aAreaCTO)
Return(aRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GetValMCT2	³ Autor ³Fernando Radu Muscalu ³ Data ³ 29/08/11  	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna os valores dos lancamentos contabeis nas n moedas que   	 ³±±
±±³          ³foram lancadas.												  	 	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GetValMCT2(cNodia,cSeqLan,cFilPesq)							  	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cNodia	- Tipo: C => Nro diario, conhecido como correlativo   	 ³±±
±±³          ³cSeqLan	- Tipo: C => Sequencia do lancamento contabil		  	 ³±±
±±³          ³cFilPesq	- Tipo: C => Filial									  	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aRet	- Tipo: A => Valores nas Moedas dos Lancamentos Contabeis³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetValMCT2(cNodia,cSeqLan,cFilPesq)

Local aRet
Local aAreaCT2	:= CT2->(GetArea())
Local aExist	:= {}

Local nOrdSix	:= 	CTBOrdSIXByChave("CT2","CT2_FILIAL+CT2_NODIA")
Local nP		:= 0

Default cFilPesq	:= xFilial("CT2")
If nOrdSix > 0

	CT2->(DbSetOrder(nOrdSix))

	If CT2->(DbSeek(cFilPesq + cNodia))

		aRet := Array(len(aCtbc66Moe))
	    aFill(aRet,0)

		While CT2->(!eof()) .and. cNodia == CT2->CT2_NODIA
			If CT2->CT2_SEQLAN == cSeqLan
				nP := aScan(aCtbc66Moe,{|x| alltrim(x[1]) == Alltrim(CT2->CT2_MOEDLC) })
				If nP > 0
					If aScan(aExist,CT2->CT2_MOEDLC) == 0
						aRet[nP] := CT2->CT2_VALOR
						aAdd(aExist,CT2->CT2_MOEDLC)
					Endif
				Endif
			Endif

			CT2->(dbSkip())

			If Len(aExist) == len(aCtbc66Moe)
				Exit
			Endif
		EndDo
	Endif
Endif

Restarea(aAreaCT2)

Return(aRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GetFieldFil	³ Autor ³Fernando Radu Muscalu ³ Data ³ 29/08/11  	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o nome do campo filial do alias passado				  		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GetFieldFil(cAlias)											  		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias	- Tipo: C => Alias do arquivo 						  		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cRet	- Tipo: C => Nome do campo Filial do dicionario SX3		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetFieldFil(cAlias)

Local cRet		:= ""
Local aAreaSx3	:= SX3->(GetArea())

SX3->(DbSetOrder(1))//adicionado por Caio Quiqueto

If SX3->(DbSeek(cAlias))
	While SX3->(!Eof()) .AND. Alltrim(SX3->X3_ARQUIVO) == Alltrim(cAlias)
		If "FILIAL" $ SX3->X3_CAMPO
			cRet := Alltrim(SX3->X3_CAMPO)
			Exit
		Endif
		SX3->(DBSKIP())
	EndDo
Endif

RestArea(aAreaSx3)
Return(cRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctbc66CV3		³ Autor ³Fernando Radu Muscalu ³ Data ³ 29/08/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna os dados do arquivo CV3 pois estes irao compor as       	 ³±±
±±³          ³informacoes do lado do modulo, quando ha lancamento contabil    ³±±
±±³          ³para um determinado registro do modulo						  		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctbc66CV3(cData,cSequen,cLPSeq,cFilPesq)						  	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cData		- Tipo: C => data do lancamento 					  	 ³±±
±±³          ³cSequen	- Tipo: C => sequencia do lancamento				  	 ³±±
±±³          ³cLPSeq	- Tipo: C => Sequencia do LP						  		 ³±±
±±³          ³cFilPesq	- Tipo: C => Filial			 						  	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aRet	- Tipo: A => Dados de CV3								  	 ³±±
±±³          ³	aRet[1]	- Tipo: C => Conta Debito							 ³±±
±±³          ³	aRet[2]	- Tipo: C => Conta Credito							 ³±±
±±³          ³	aRet[3]	- Tipo: C => Centro de Custo Debito				 ³±±
±±³          ³	aRet[4]	- Tipo: C => Centro de Custo Credito				 ³±±
±±³          ³	aRet[5]	- Tipo: C => Item de Conta Debito					 ³±±
±±³          ³	aRet[6]	- Tipo: C => Item de Conta Credito					 ³±±
±±³          ³	aRet[7]	- Tipo: C => Classe de Valor Debito				 ³±±
±±³          ³	aRet[8]	- Tipo: C => Classe de Valor Credito				 ³±±
±±³          ³	aRet[9]	- Tipo: C => Array com as demais entidades		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctbc66CV3(cData,cSequen,cLPSeq,cFilPesq,nRecno)

Local aAreaCV3		:= CV3->(GetArea())
Local aRet			:= {}
Local aEnt			:= Ctbc66RetEnt("CV3")

Local nI			:= 0
Local nQtdEnt		:= 0

Default cFilPesq	:= xFilial("CV3")

aRet 	:= Array(9)
aFill(aRet,"")
aRet[9]	:= {}
nQtdEnt := len(aEnt[1])

If !Empty(nRecno)

	CV3->(DbSetOrder(2))

	If CV3->(DbSeek(cFilPesq + padr(AllTrim(STR(nRecno)),tamSX3("CV3_RECDES")[1])))
		aRet[1] := CV3->CV3_DEBITO
   		aRet[2] := CV3->CV3_CREDIT
   		aRet[3] := CV3->CV3_CCD
    	aRet[4] := CV3->CV3_CCC
		aRet[5] := CV3->CV3_ITEMD
		aRet[6] := CV3->CV3_ITEMC
		aRet[7] := CV3->CV3_CLVLDB
		aRet[8] := CV3->CV3_CLVLCR
		For nI := 1 to nQtdEnt
			aAdd(aRet[9],CV3->&(aEnt[1,nI,1]))
			aAdd(aRet[9],CV3->&(aEnt[2,nI,1]))
		Next nI
	Endif
Endif

If len(aRet[9]) == 0
	aRet[9]	 := Array(nQtdEnt*2)
	aFill(aRet[9],"")
Endif

Restarea(aAreaCV3)

Return(aRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctbc66FillBlank³ Autor ³Fernando Radu Muscalu ³ Data ³ 29/08/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Adiciona valores em branco no array master aResultSet caso nao   ³±±
±±³          ³haja nenhum valor preenchido.									   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctbc66FillBlank(aResult)	     								   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aResult - Tipo: A => Array com os dados comparativo Modulo X     ³±±
±±³          ³Contabilidade													   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil							    							   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctbc66FillBlank(aResult)
Local nI		:= 0
Local aAux		:= {}
Local nQtdEnt   := Len(Ctbc66RetEnt()[1])*2

For nI := 1 to len(aResult)
	If aResult[nI,2] == nil

		aResult[nI,2] := {}

		aAux := Array(16+nQtdEnt)

		aFill(aAux,"")

		aAux[1] := LoadBitmap(GetResources(),"BR_VERMELHO")

		Aadd(aAux,-1)		//Adiciona codigo do status SEMPRE ao final do array, pois o relatorio lera o status dessa posicao

		aAdd(aResult[nI,2],aAux)
		aAux := {}
	Endif
	If aResult[nI,3] == nil

		aResult[nI,3] := {}

		aAux := Array(19+nQtdEnt+len(aCtbc66Moe))
		aFill(aAux,"")

		aResult[nI,2,len(aResult[nI,2]),1] := LoadBitmap(GetResources(),"BR_VERDE")

		Aadd(aAux,-1)		//Adiciona codigo do status SEMPRE ao final do array, pois o relatorio lera o status dessa posicao

		aAdd(aResult[nI,3],aAux)
		aAux := {}
	Endif
Next nI

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctbc66RetEnt	 ³ Autor ³Fernando Radu Muscalu ³ Data ³ 29/08/11   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna os campos e suas descricoes das outras entidades		    ³±±
±±³          ³contabeis alem das quatro fixas							 	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctbc66RetEnt(cAlias)		     								    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias - Tipo: C => Alias do arquivo						        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array - Entidades contabeis alem das 4 fixas					    ³±±
±±³          ³	Array[1] - Tipo: A => Entidades de Debito					    ³±±
±±³          ³		Array[1,n,1] - Tipo: C => Campo para o Alias passado        ³±±
±±³          ³		Array[1,n,2] - Tipo: C => Nome do campo para o Alias passado³±±
±±³          ³	Array[2] - Tipo: A => Entidades de Credito					    ³±±
±±³          ³		Array[2,n,1] - Tipo: C => Campo para o Alias passado        ³±±
±±³          ³		Array[2,n,2] - Tipo: C => Nome do campo para o Alias passado³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                         	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctbc66RetEnt(cAlias)

Local aRetDb	:= {}
Local aRetCr	:= {}
Local aAreaSX3 	:= SX3->(GetArea())

Local nQtdEnt	:= 0
Local nI		:= 0

Local cCompl	:= ""

Default cAlias	:= "CT2"

nQtdEnt := CtbQtdEntd()

SX3->(DbSetOrder(1))

If SX3->( DbSeek(cAlias) )
	cCompl := Substr(SX3->X3_CAMPO,1,At("_",SX3->X3_CAMPO,1))
Endif

If !Empty(cCompl)
	For nI := 5 to nQtdEnt

		aAdd(aRetDB,{cCompl+"EC"+STRZERO(nI,2)+"DB",(cAlias)->(RetTitle(cCompl+"EC"+STRZERO(nI,2)+"DB"))} )
		aAdd(aRetCR,{cCompl+"EC"+STRZERO(nI,2)+"CR",(cAlias)->(RetTitle(cCompl+"EC"+STRZERO(nI,2)+"CR"))} )

	Next nI
Endif


RestArea(aAreaSX3)

Return({aRetDb,aRetCr})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctbc66GRsc	 ³ Autor ³Fernando Radu Muscalu ³ Data ³ 29/08/11   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³funcao responsavel pela definicao do semafaro para os registros   ³±±
±±³          ³que compoe a browse do modulo								 	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctbc66GRsc(aArrayMod,aArrayCtb,cAlias,nTipo,aDataCV3,aCfgFields)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aArrayMod - Tipo: A => Array com os dados do Modulo    	        ³±±
±±³          ³aArrayCtb - Tipo: A => Array com os dados da Contabilidade        ³±±
±±³          ³cAlias 	- Tipo: C => Alias do arquivo do modulo				    ³±±
±±³          ³nTipo 	- Tipo: N => Tipo de Validacao a ser usada			    ³±±
±±³          ³      	  1 = Validacao diretamente no browse     			    ³±±
±±³          ³      	  2 = Validacao na composicao dos dados do array master 	³±±
±±³			   ³cBmp - Tipo: O => Objeto com a cor										³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³nStatus - Tipo: N => status da conta								³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                         	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctbc66GRsc(aArrayMod,aArrayCtb,cAlias,nTipo,aDataCV3,aCfgFields,cBmp)
Local nStatus		:= 0
Local aCabecMod 	:= CTBC66GetHBrw(1)
Local aEntities 	:= Ctbc66RetEnt()
Local nI			:= 0
Local nEnt			:= 0
Local nX 			:= 0
Local nPos			:= 0
Local lDone			:= .f.

Default nTipo		:= 1
Default aDataCV3	:= {}
Default aArrayMod	:= {}
Default aArrayCtb	:= {}

cBmp		:= LoadBitmap(GetResources(),"BR_VERDE")

If nTipo == 1
    nX 		:= 11
    nEnt	:= Len(aEntities[1]) * 2
	For nI := 1 to len(aCabecMod)

		If nI == 3
			If ( Empty(aArrayMod[nI]) .and. !Empty(aArrayCtb[2]) ) .or. ( !Empty(aArrayMod[nI]) .and. Empty(aArrayCtb[2]) )
				cBmp := LoadBitmap(GetResources(),"BR_VERMELHO")
				nStatus:=1
				Exit
			Endif
		ElseIf nI == 7
			If ( !Empty(aArrayMod[nI]) .or. !Empty(aArrayCtb[19+nEnt]) ) .and. aArrayMod[nI] <> aArrayCtb[19+nEnt]
				cBmp := LoadBitmap(GetResources(),"BR_AMARELO")
				nStatus:=2
				Exit
			Endif
		ElseIf nI >= 9
			If (!Empty(aArrayMod[nI]) .or. !Empty(aArrayCtb[nX]) ) .and. aArrayMod[nI] <> aArrayCtb[nX]
				cBmp := LoadBitmap(GetResources(),"BR_AMARELO")
				nStatus:=2
			Endif
			nX++
		Endif
	Next nI
Else

	nEnt	:= Len(aEntities[1])

	If ( Empty( (cAlias)->&(aCfgFields[NRODOC]) ) .AND. !Empty((cAlias)->CT2_DATA) ) .OR. ( !Empty((cAlias)->&(aCfgFields[NRODOC])) .AND. Empty((cAlias)->CT2_DATA ) )
		cBmp := LoadBitmap(GetResources(),"BR_VERMELHO")
		nStatus:=1
		lDone := .t.
	Endif

	If !lDone

		nPos := (cAlias)->(FieldPos(aCfgFields[NODIA]))

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Problemas encontrados no modulo SIGAATF; somente SN3 esta, atualmente, sendo rastreado em CV3 ³
        //³ **  Nao conformidade a ser resolvida: SN3->N3_NODIA nao esta sendo gravado ! *** 02/01/2013   ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If cPaisLoc $ "ARG/CHI" .And. aCfgFields[ ALIASDOC ] == "SN3"
           // Do Nothing !
        Else
           //
		   If ( Empty((cAlias)->(FieldGet(nPos) )) .and. !Empty((cAlias)->CT2_NODIA) ) .OR. ( !Empty((cAlias)->(FieldGet(nPos))) .and. Empty((cAlias)->CT2_NODIA) )
			   cBmp := LoadBitmap(GetResources(),"BR_VERMELHO")
			   nStatus:=1
			   lDone := .t.
		   Endif
           //
        EndIf

		If !lDone
			If (!Empty((cAlias)->DELETADO) .or. !Empty((cAlias)->CT2_DELET) ) .and. (cAlias)->DELETADO <> (cAlias)->CT2_DELET
				cBmp := LoadBitmap(GetResources(),"BR_VERMELHO")
				nStatus:=1
				lDone := .t.
			Endif

			If !lDone
				//Verifica se o Valor do documento e diferente da contabilidade
				nPos := (cAlias)->(FieldPos(aCfgFields[VLRDOC]))
				If ( !Empty((cAlias)->(FieldGet(nPos))) .or. !Empty( (cAlias)->CT2_VALOR ) ) .and. (cAlias)->(FieldGet(nPos)) <> (cAlias)->CT2_VALOR
					If (cAlias)->CT2_CONFST == "1"
						cBmp := LoadBitmap(GetResources(),"BR_PRETO")
						nStatus:=3
					Else
						cBmp := LoadBitmap(GetResources(),"BR_AMARELO")
						nStatus:=2
					EndIf
					lDone := .t.
				Endif

				If !lDone
					//Verifica se ha divergencias entre as quantidades
					aPosEntCT2 := {	(cAlias)->(FieldPos("CT2_DEBITO")),;
									(cAlias)->(FieldPos("CT2_CREDIT")),;
									(cAlias)->(FieldPos("CT2_CCD")),;
									(cAlias)->(FieldPos("CT2_CCC")),;
									(cAlias)->(FieldPos("CT2_ITEMD")),;
									(cAlias)->(FieldPos("CT2_ITEMC")),;
									(cAlias)->(FieldPos("CT2_CLVLDB")),;
									(cAlias)->(FieldPos("CT2_CLVLCR")),;
									}


					For nI := 1 to nEnt
						aAdd(aPosEntCt2,(cAlias)->(FieldPos(aEntities[1,nI,1])))
						aAdd(aPosEntCt2,(cAlias)->(FieldPos(aEntities[2,nI,1])))
					Next nI

					For nI := 1 to len(aDataCV3)

						If Valtype(aDataCV3[nI]) <> "A"
							cEntCT2 := (cAlias)->(FieldGet(aPosEntCt2[nI]))

							If ( !Empty(aDataCV3[nI]) .or. !Empty(cEntCT2) ) .and. aDataCV3[nI] <> cEntCT2
								cBmp := LoadBitmap(GetResources(),"BR_AMARELO")
								nStatus:=2
								lDone := .t.
							Endif
						Endif

						If !lDone
							If Valtype(aDataCV3[nI]) == "A"
								For nX := 1 to len(aDataCV3[nI])
									cEntCT2 := (cAlias)->(FieldGet(aPosEntCt2[nI+nX]))
									If ( !Empty(aDataCV3[nI,nX]) .or. !Empty(cEntCT2) ) .and. aDataCV3[nI,nX] <> cEntCT2
										cBmp := LoadBitmap(GetResources(),"BR_AMARELO")
										nStatus:=2
										lDone := .t.
										Exit
									Endif
								Next nX
							Endif
						Endif

						If lDone
							Exit
						Endif
					Next nI

				Endif

			Endif

	    Endif

	Endif

Endif

Return(nStatus)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CTBC66leg		 ³ Autor ³Fernando Radu Muscalu ³ Data ³ 29/08/11   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Montagem da tela de legenda									    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTBC66leg()														³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³																	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil																³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                         	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTBC66leg()

Local aCores := {	{"BR_VERMELHO"	,STR0030	},;		//## "Documentos desbalanceados."
				 	{"BR_AMARELO"   ,STR0031	},;		//## "Doc. dados divergentes"
				 	{"BR_VERDE"		,STR0032	},;		//## "Documentos corretos."
				 	{"BR_PRETO"     ,STR0059    }	}   //## "Documentos conferidos."

BrwLegenda(STR0005,STR0024,aCores)  //##"Relatório de Auditoria"#"Legenda"

Return()

/*
Mapa de aResultSet

aResultSet
	aResultSet[n] - array, refere-se a aba das Dialogs das Filiais
		aResultSet[n,1] - Filial Codigo + Descicao
		aResultSet[n,2] - array, refere-se a aba dos Modulos selecionados
			aResultSet[n,2,x] - array dos modulos
				aResultSet[n,2,x,1] - nro do modulo
				aResultSet[n,2,x,2] - array com as informacoes do modulo
					aResultSet[n,2,x,2,z] 		- array indicando a Linha
						aResultSet[n,2,x,2,z,1] 		- Bitmap da cor
						aResultSet[n,2,x,2,z,2] 		- Filial
						aResultSet[n,2,x,2,z,3] 		- CV3_TABORI
						aResultSet[n,2,x,2,z,4] 		- Data (Pegar na CTL)
						aResultSet[n,2,x,2,z,5] 		- Documento (Pegar na CTL)
						aResultSet[n,2,x,2,z,6] 		- Moeda (Pegar na CTL)
						aResultSet[n,2,x,2,z,7] 		- Vlr Doc (Pegar na CTL)
						aResultSet[n,2,x,2,z,8] 		- Correlativo
						aResultSet[n,2,x,2,z,9] 		- CV3_DEBITO
						aResultSet[n,2,x,2,z,10] 		- CV3_CREDIT
						aResultSet[n,2,x,2,z,11] 		- CV3_CCD
						aResultSet[n,2,x,2,z,12]		- CV3_CCC
						aResultSet[n,2,x,2,z,13]	 	- CV3_ITEMD
						aResultSet[n,2,x,2,z,14]	 	- CV3_ITEMC
						aResultSet[n,2,x,2,z,15] 		- CV3_CLVLDB
						aResultSet[n,2,x,2,z,16] 		- CV3_CLVLCR
						aResultSet[n,2,x,2,z,17] 		- Status// adicionado por Caio Quiqueto
						aResultSet[n,3,x,2,z,18...n]	- Entidades Contabeis
				aResultSet[n,2,x,3] - array Contabilidade
					aResultSet[n,2,x,3,z] 		- array indicando a Linha
						aResultSet[n,2,x,3,z,1] 		- CT2_FILIAL
						aResultSet[n,2,x,3,z,2] 		- CT2_DATA
						aResultSet[n,2,x,3,z,3] 		- CT2_TPSALD
						aResultSet[n,2,x,3,z,4] 		- CT2_LOTE
						aResultSet[n,2,x,3,z,5] 		- CT2_SBLOTE
						aResultSet[n,2,x,3,z,6] 		- CT2_DOC
						aResultSet[n,2,x,3,z,7] 		- CT2_LINHA
						aResultSet[n,2,x,3,z,8] 		- CT2_SEQLAN
						aResultSet[n,2,x,3,z,9] 		- CT2_LP
						aResultSet[n,2,x,3,z,10] 		- CT2_NODIA
						aResultSet[n,2,x,3,z,11] 		- CT2_DEBITO
						aResultSet[n,2,x,3,z,12] 		- CT2_CREDIT
						aResultSet[n,2,x,3,z,13] 		- CT2_CCD
						aResultSet[n,2,x,3,z,14] 		- CT2_CCC
						aResultSet[n,2,x,3,z,15] 		- CT2_ITEMD
						aResultSet[n,2,x,3,z,16] 		- CT2_ITEMC
						aResultSet[n,2,x,3,z,17] 		- CT2_CLVLDB
						aResultSet[n,2,x,3,z,18] 		- CT2_CLVLCR
						aResultSet[n,2,x,3,z,19...n]	- Entidades Contabeis
						aResultSet[n,2,x,3,z,n+1...n+y]- valor nas Moedas
						aResultSet[n,2,x,3,z,n+y+1]	- CT2_DC

*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTC660Conf()	 ³ Autor ³ Jose Lucas           ³ Data ³ 31/10/11   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Conferir lançamentos e gravar marca de conferencia.			    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTC660Conf(ExpO1,ExpO2,ExpA1,ExpA2,ExpA3)						³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 := oFolderFil - Folder com as filiais ativas).				³±±
±±³          ³ ExpO2 := aFModulos - Folder com as configurações modulos).		³±±
±±³          ³ ExpA1 := aBrwMod - Objeto correspondente ao browse do módulo sel-³±±
±±³          ³ ecionado. Exemplo: Compras, Faturamento, Financeiro, etc...		³±±
±±³          ³ ExpA2 := aBrwCtb - Objeto correspondente ao browse do módulo CTB.³±±
±±³          ³ ExpA3 := Array aResultSet.										³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil																³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTC660 - Quadratura                                             	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ct660Conf(oFolderFil,aFModulos,aBrwMod,aBrwCtb,aResultSet)
Local nI := 0 //Elemento correspondente ao folder da filial corrente.
Local nX := 0 //Elemento correspondente ao subfolder do modulo corrente.
Local nC := 0
Local nPosLinha := 0
Local lConfere  := .F.
Local lConferir := .F.
Local lReverter := .F.
local cMod:=0 //codigo do modulo
Local oConferir
Local oObs
Local cObs      := CriaVar("CT2_OBSCNF")
Local lGravaCT2 := .F.
Local aSizeDlg	:= FWGetDialogSize(oMainWnd)
Local oDlg		:= Nil
Local nHeight	:= aSizeDlg[3] * 0.50
Local nWidth    := aSizeDlg[4] * 0.60
Local bUpdate	:= {|| If(lConferir .and. !Empty(cObs),(Ct660GrvCT2(oFolderFil,aFModulos,aBrwMod,aBrwCtb,aResultSet,nPosLinha,cObs,.T.,.F.),oDlg:End()),.F.)}
Local bEndWin	:= {|| oDlg:End()}
Local bEnchBar	:= {|| EnchoiceBar(oDlg,bUpdate,bEndWin) }

nI := oFolderFil:nOption				//Elemento correspondente ao folder da filial corrente.
If nI > 0
	nX := aFModulos[nI]:nOption			//Elemento correspondente ao subfolder do modulo corrente.
EndIf
If ( nI > 0 .and. nX > 0 )
	cMod:=aFModulos[nI]:aDialogs[nX]:cCaption
	if !("34" $ cMod)
		nPosLinha := aBrwMod[nI][nX]:nAt	//Posição da linha do lançamento posicionado.
		If nPosLinha > 0
			If "BR_AMARELO" $ aBrwMod[nI][nX]:aArray[nPosLinha][1]:cName
				lConfere := .T.
			EndIf
			If "BR_PRETO" $ aBrwMod[nI][nX]:aArray[nPosLinha][1]:cName
				lConfere := .F.
				Help(" ",1,"CTBC660_DOCCONF",,STR0034,1,0)	 //"Documento ja conferido."
			ElseIf ! "BR_AMARELO" $ aBrwMod[nI][nX]:aArray[nPosLinha][1]:cName
				lConfere := .F.
				Help(" ",1,"CTBC660_NOCONF",,STR0035,1,0)	 //"Documento não permite conferecia."
			EndIf

			If lConfere

				DEFINE MSDIALOG oDlg FROM 0,0 TO nHeight, nWidth TITLE STR0036 PIXEL STYLE DS_MODALFRAME of oMainWnd  //###Conferencia do Documento

				@ 010,010  CHECKBOX oConferir VAR lConferir PROMPT STR0037 PIXEL OF oDlg SIZE 80,9 MESSAGE STR0038;	  //###"Se estiver marcado, modificará o status e gravará o lançamento contabil como conferido."
					   	 			ON CLICK lGravaCT2 := .T.

				@ 023,011  SAY OemToAnsi(STR0039)	PIXEL OF oDlg SIZE 50,9			// "Observação"
				@ 030,010  MSGET oObs	VAR cObs Picture "@!" 	VALID Ct660Obs(cObs)  PIXEL OF oDlg SIZE 150,10

				oDlg:Activate(,,,.T.,,,bEnchBar)
	        EndIf
	    EndIf
	Else
		lConfere := .F.
		Help(" ",1,"CTBC660_NOCONF",,STR0035,1,0)	 //"Documento não permite conferecia."
	Endif
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTC660Reve()	 ³ Autor ³ Jose Lucas           ³ Data ³ 31/10/11   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Reverter a confirmação do lançamento selecionado.			    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTC660Reve(ExpO1,ExpO2,ExpA1,ExpA2,ExpA3)						³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 := oFolderFil - Folder com as filiais ativas).				³±±
±±³          ³ ExpO2 := aFModulos - Folder com as configurações modulos).		³±±
±±³          ³ ExpA1 := aBrwMod - Objeto correspondente ao browse do módulo sel-³±±
±±³          ³ ecionado. Exemplo: Compras, Faturamento, Financeiro, etc...		³±±
±±³          ³ ExpA2 := aBrwCtb - Objeto correspondente ao browse do módulo CTB.³±±
±±³          ³ ExpA3 := Array aResultSet.										³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil																³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTC660 - Quadratura                                             	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CT660Reve(oFolderFil,aFModulos,aBrwMod,aBrwCtb,aResultSet)
Local nI := 0
Local nX := 0
Local nC := 0
Local nPosLinha := 0
Local lConfere  := .F.
Local lConferir := .F.
Local lReverter := .T.
Local oConferir
Local oObs
Local cObs      := CriaVar("CT2_OBSCNF")
Local lGravaCT2 := .F.
Local aSizeDlg	:= FWGetDialogSize(oMainWnd)
Local nHeight	:= aSizeDlg[3] * 0.50
Local nWidth    := aSizeDlg[4] * 0.60
Local oDlg		:= Nil
Local bUpdate	:= {|| If(lConferir .and. lReverter,(Ct660GrvCT2(oFolderFil,aFModulos,aBrwMod,aBrwCtb,aResultSet,nPosLinha,cObs,.F.,lReverter),oDlg:End()),.F.)}
Local bEndWin	:= {|| oDlg:End()}
Local bEnchBar	:= {|| EnchoiceBar(oDlg,bUpdate,bEndWin) }

nI := oFolderFil:nOption				//Elemento correspondente ao folder da filial corrente.
If nI > 0
	nX := aFModulos[nI]:nOption			//Elemento correspondente ao subfolder do modulo corrente.
EndIf
If ( nI > 0 .and. nX > 0 )
	cMod:=aFModulos[nI]:aDialogs[nX]:cCaption
	if !("34" $ cMod)
		nPosLinha := aBrwMod[nI][nX]:nAt	//Posição da linha do lançamento posicionado.
		If nPosLinha > 0
			If "BR_PRETO" $ aBrwMod[nI][nX]:aArray[nPosLinha][1]:cName
				lConfere  := .T.
				dDataLan  := aBrwCtb[nI][nX]:aArray[nPosLinha][2]
				cLoteLan  := aBrwCtb[nI][nX]:aArray[nPosLinha][4]
				cSBLote   := aBrwCtb[nI][nX]:aArray[nPosLinha][5]
				cDocLanc  := aBrwCtb[nI][nX]:aArray[nPosLinha][6]
				cLinha    := aBrwCtb[nI][nX]:aArray[nPosLinha][7]
				cTipSaldo := aBrwCtb[nI][nX]:aArray[nPosLinha][3]
				CT2->(dbSetOrder(1))
				CT2->(dbSeek(xFilial("CT2")+DTOS(dDataLan)+cLoteLan+cSBLote+cDocLanc+cLinha+cTipSaldo))
	            cObs := CT2->CT2_OBSCNF
			Else
				lConfere := .F.
				Help(" ",1,"CTBC660_NOREV",,STR0040,1,0)	 //"Reversão só é possível nos documentos confirmados."
			EndIf

			If lConfere

				DEFINE MSDIALOG oDlg FROM 0,0 TO nHeight, nWidth TITLE STR0041 PIXEL STYLE DS_MODALFRAME of oMainWnd  	//"Reversão do Documento"

				@ 010,010  CHECKBOX oConferir VAR lConferir PROMPT STR0042 PIXEL OF oDlg SIZE 80,9 MESSAGE STR0043;		//"Reverter Documento"###"Se estiver marcado, reverterá o status estornando a conferencia do documento contabil."
					   	 			ON CLICK lGravaCT2 := .T.

				@ 023,011  SAY OemToAnsi(STR0039)	PIXEL OF oDlg SIZE 50,9			// "Observação"
				@ 030,010  MSGET oObs	VAR cObs Picture "@!" 	WHEN .F.            	PIXEL OF oDlg SIZE 150,10

				oDlg:Activate(,,,.T.,,,bEnchBar)
	        EndIf
	    EndIf
	Endif
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Ct660GrvCT2()	 ³ Autor ³ Jose Lucas       ³ Data ³ 04/11/11   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravar dados de conferencia ou reversão de lançamento na tabela  ³±±
±±³          ³ de lançamentos contabeis na tabela CT2.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ C660GrvCT2(ExpO1,ExpO2,ExpA1,ExpA2,ExpA3, ExpN1, ExpL1, ExpL2)	³±±
±±³          ³ Linha,lConferir,lReverter)										³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 := oFolderFil - Folder com as filiais ativas).				³±±
±±³          ³ ExpO2 := aFModulos - Folder com as configurações modulos).		³±±
±±³          ³ ExpA1 := aBrwMod - Objeto correspondente ao browse do módulo sel-³±±
±±³          ³ ecionado. Exemplo: Compras, Faturamento, Financeiro, etc...		³±±
±±³          ³ ExpA2 := aBrwCtb - Objeto correspondente ao browse do módulo CTB.³±±
±±³          ³ ExpA3 := Array aResultSet.										³±±
±±³          ³ ExpN1 := Numero da linha do elemento selecionado.				³±±
±±³          ³ ExpL1 := Variavel de controle lConferir.							³±±
±±³          ³ ExpL2 := Variavel de controle lReverter.							³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil																³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTC660 - Quadratura Contabil.                                   	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ct660GrvCT2(oFolderFil,aFModulos,aBrwMod,aBrwCtb,aResultSet,nPosLinha,cObs,lConferir,lReverter)
Local aArea := GetArea()
Local nI := 0
Local nX := 0
Local dDataLan  := CTOD("")
Local cLoteLan  := ""
Local cSBLote   := ""
Local cDocLanc  := ""
Local cLinha    := ""
Local cTipSaldo := ""

nI := oFolderFil:nOption			//Elemento correspondente ao folder da filial corrente.
If nI > 0
	nX := aFModulos[nI]:nOption		//Elemento correspondente ao subfolder do modulo corrente.
EndIf
If ( nI > 0 .and. nX > 0 ) .and. nPosLinha > 0
	dDataLan  := aBrwCtb[nI][nX]:aArray[nPosLinha][2]
	cLoteLan  := aBrwCtb[nI][nX]:aArray[nPosLinha][4]
	cSBLote   := aBrwCtb[nI][nX]:aArray[nPosLinha][5]
	cDocLanc  := aBrwCtb[nI][nX]:aArray[nPosLinha][6]
	cLinha    := aBrwCtb[nI][nX]:aArray[nPosLinha][7]
	cTipSaldo := aBrwCtb[nI][nX]:aArray[nPosLinha][3]
	CT2->(dbSetOrder(1))
	If CT2->(dbSeek(xFilial("CT2")+DTOS(dDataLan)+cLoteLan+cSBLote+cDocLanc+cLinha+cTipSaldo))
		If lConferir
			aBrwMod[nI][nX]:aArray[nPosLinha][1]:cName := "BR_PRETO"	//Conferido
			RecLock('CT2',.F.)
			Replace CT2_CONFST	With "1"
			Replace CT2_OBSCNF	With cObs
			Replace CT2_USRCNF	With cUserName
			Replace CT2_DTCONF	With MSDate()
			Replace CT2_HRCONF	With Time()
			MsUnLock()
		EndIf
		If lReverter
			aBrwMod[nI][nX]:aArray[nPosLinha][1]:cName := "BR_AMARELO"	//Revertido
			RecLock('CT2',.F.)
			Replace CT2_CONFST	With " "
			Replace CT2_OBSCNF	With " "
			Replace CT2_USRCNF	With " "
			Replace CT2_DTCONF	With CTOD("")
			Replace CT2_HRCONF	With " "
			MsUnLock()
		EndIf
	EndIf
Endif
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Ct660Obs()		 ³ Autor ³ Jose Lucas       ³ Data ³ 04/11/11   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validar a caixa de edição do campo Observação.          		    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL := Ct660Obs(ExpC)											³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC := cObs - Texto digitado.									³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL := Retorno logico True ou False.							³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTC660 - Quadratura Contabil.                                   	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ct660Obs(cObs)
Local lTrue  := .T.
Local lFalse := .F.
If Empty(cObs)
	Help(" ",1,"CTBC660_OBSMSG",,STR0044,1,0)	 //"Informe o texto para o campo observação."
EndIf
Return If(Empty(cObs),lFalse,lTrue)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTC660Dive()	 ³ Autor ³ Jose Lucas           ³ Data ³ 31/10/11   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibir divergencias do documento selecionado.   				    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTC660Dive(ExpO1,ExpO2,ExpA1,ExpA2,ExpA3)						³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 := oFolderFil - Folder com as filiais ativas).				³±±
±±³          ³ ExpO2 := aFModulos - Folder com as configurações modulos).		³±±
±±³          ³ ExpA1 := aBrwMod - Objeto correspondente ao browse do módulo sel-³±±
±±³          ³ ecionado. Exemplo: Compras, Faturamento, Financeiro, etc...		³±±
±±³          ³ ExpA2 := aBrwCtb - Objeto correspondente ao browse do módulo CTB.³±±
±±³          ³ ExpA3 := Array aResultSet.										³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil																³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTC660 - Quadratura                                             	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CT660Dive(oFolderFil,aFModulos,aBrwMod,aBrwCtb,aResultSet)
Local nI := 0
Local nX := 0
Local nC := 0
Local nPosLinha    := 0
Local lDivergencia := .F.
Local lGravaCT2 := .F.
Local aSizeDlg	:= FWGetDialogSize(oMainWnd)
Local nHeight	:= aSizeDlg[3] * 0.50
Local nWidth    := aSizeDlg[4] * 0.60
Local oDlg		:= Nil
Local oListBox
Local aListBox  := {}
Local aEntidades:= Ctbc66RetEnt()
Local cModulo   := ""
Local bUpdate	:= {|| If(lGravaCT2,(Ct660GrvCT2(oFolderFil,aFModulos,aBrwMod,aBrwCtb,aResultSet,nPosLinha,cObs,.F.,lReverter),oDlg:End()),.F.)}
Local bEndWin	:= {|| oDlg:End()}
Local bEnchBar	:= {|| EnchoiceBar(oDlg,bUpdate,bEndWin) }

nI := oFolderFil:nOption				//Elemento correspondente ao folder da filial corrente.
If nI > 0
	nX := aFModulos[nI]:nOption			//Elemento correspondente ao subfolder do modulo corrente.
EndIf
If ( nI > 0 .and. nX > 0)
	cModulo := aFModulos[nI]:aPrompts[nX]//alterado pois precisa pegar o modulo
	if (cModulo != "34") // inserido o !=34 pois no modulo de contabilidade não existe comparação
		nPosLinha := aBrwMod[nI][nX]:nAt	//Posição da linha do lançamento posicionado.
		If nPosLinha > 0
			If "BR_AMARELO" $ aBrwMod[nI][nX]:aArray[nPosLinha][1]:cName
				lDivergencia := .T.
				//Divergencias

				If aBrwMod[nI][nX]:aArray[nPosLinha][4] <> aBrwCtb[nI][nX]:aArray[nPosLinha][2]	//Data do Lançamento
					AADD(aListBox,{STR0048,Transform(aBrwMod[nI][nX]:aArray[nPosLinha][4],"@D"),Transform(aBrwCtb[nI][nX]:aArray[nPosLinha][2],"@D")})	//"Data do documento"
				EndIf

				If aBrwMod[nI][nX]:aArray[nPosLinha][7] <> aBrwCtb[nI][nX]:aArray[nPosLinha][19+len(aEntidades[1])*2]	//Valor do Documento
					AADD(aListBox,{STR0049,Transform(aBrwMod[nI][nX]:aArray[nPosLinha][7],"@E 999,999,999.99"),Transform(aBrwCtb[nI][nX]:aArray[nPosLinha][19+len(aEntidades[1])*2],"@E 999,999,999.99")})
				EndIf

				If aBrwMod[nI][nX]:aArray[nPosLinha][8] <> aBrwCtb[nI][nX]:aArray[nPosLinha][10]	//Numero do Diario
					AADD(aListBox,{STR0050,aBrwMod[nI][nX]:aArray[nPosLinha][8],aBrwCtb[nI][nX]:aArray[nPosLinha][10]})
				EndIf

				If aBrwMod[nI][nX]:aArray[nPosLinha][9] <> aBrwCtb[nI][nX]:aArray[nPosLinha][11]	//Conta Contabil Debito
					AADD(aListBox,{STR0051,aBrwMod[nI][nX]:aArray[nPosLinha][9],aBrwCtb[nI][nX]:aArray[nPosLinha][11]})
				EndIf

				If aBrwMod[nI][nX]:aArray[nPosLinha][10] <> aBrwCtb[nI][nX]:aArray[nPosLinha][12]	//Conta Contabil Credito
					AADD(aListBox,{STR0067,aBrwMod[nI][nX]:aArray[nPosLinha][10],aBrwCtb[nI][nX]:aArray[nPosLinha][12]})
				EndIf

				If aBrwMod[nI][nX]:aArray[nPosLinha][11] <> aBrwCtb[nI][nX]:aArray[nPosLinha][13]	//Centro custo Debito
					AADD(aListBox,{STR0061,aBrwMod[nI][nX]:aArray[nPosLinha][11],aBrwCtb[nI][nX]:aArray[nPosLinha][13]})
				EndIf

				If aBrwMod[nI][nX]:aArray[nPosLinha][12] <> aBrwCtb[nI][nX]:aArray[nPosLinha][14]	//Centro custo credito
					AADD(aListBox,{STR0062,aBrwMod[nI][nX]:aArray[nPosLinha][12],aBrwCtb[nI][nX]:aArray[nPosLinha][14]})
				EndIf

				If aBrwMod[nI][nX]:aArray[nPosLinha][13] <> aBrwCtb[nI][nX]:aArray[nPosLinha][15]	//Item debito
					AADD(aListBox,{STR0063,aBrwMod[nI][nX]:aArray[nPosLinha][13],aBrwCtb[nI][nX]:aArray[nPosLinha][15]})
				EndIf

				If aBrwMod[nI][nX]:aArray[nPosLinha][14] <> aBrwCtb[nI][nX]:aArray[nPosLinha][16]	//item credito
					AADD(aListBox,{STR0064,aBrwMod[nI][nX]:aArray[nPosLinha][14],aBrwCtb[nI][nX]:aArray[nPosLinha][16]})
				EndIf

				If aBrwMod[nI][nX]:aArray[nPosLinha][15] <> aBrwCtb[nI][nX]:aArray[nPosLinha][17]	//cl valor debito
					AADD(aListBox,{STR0065,aBrwMod[nI][nX]:aArray[nPosLinha][15],aBrwCtb[nI][nX]:aArray[nPosLinha][17]})
				EndIf

				If aBrwMod[nI][nX]:aArray[nPosLinha][16] <> aBrwCtb[nI][nX]:aArray[nPosLinha][18]	//Cl valor credito
					AADD(aListBox,{STR0066,aBrwMod[nI][nX]:aArray[nPosLinha][16],aBrwCtb[nI][nX]:aArray[nPosLinha][18]})
				EndIf


			EndIf
			If lDivergencia

				DEFINE MSDIALOG oDlg FROM 0,0 TO nHeight, nWidth TITLE "Divergencias" PIXEL STYLE DS_MODALFRAME of oMainWnd  //###Conferencia do Documento

				nHeight	:= aSizeDlg[3] * 0.40
				nWidth  := aSizeDlg[4] * 0.50

				@ 010, 010 LISTBOX oListBox Fields HEADER "Referencia",cModulo,"34-Contabilidade Gerencial"; //"Referencia"###"Modulo"###"Contabilidade"
							SIZE 355, 110 PIXEL
				oListBox:SetArray( aListBox )
				oListBox:bLine := { || { aListBox[ oListBox:nAT,1 ],aListBox[ oListBox:nAT,2 ],aListBox[ oListBox:nAT,3 ]} }
				oListBox:Align := CONTROL_ALIGN_ALLCLIENT

				oDlg:Activate(,,,.T.,,,bEnchBar)
	        EndIf
	    EndIf
    EndIf
EndIf
Return




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FillATFMod	³ Autor ³Fernando Radu Muscalu ³ Data ³ 29/08/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera massa de dados em memoria de acordo com o modulo e tabela. ³±±
±±³          ³Esta massa de dado corresponde tanto do lancamento quanto do    ³±±
±±³          ³documento gerador (lado do modulo)							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FillATFMod(cAlias,cDtIni,cDtfim,aConfig,aResult,cMod,cFilSelect)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias	- Tipo: C => Alias da tabela a ser analisada          ³±±
±±³          ³cDtIni	- Tipo: C => Data inicial do periodo			      ³±±
±±³          ³cDtFim	- Tipo: C => Data final do periodo				      ³±±
±±³          ³aConfig	- Tipo: A => Campos utilizados pela Tabela		      ³±±
±±³          ³aResult	- Tipo: A => Array com os dados comparativo Modulo X  ³±±
±±³          ³cMod		- Tipo: C => Codigo do Modulo						  ³±±
±±³          ³cFilSelect- Tipo: C => Filiais selecionadas					  ³±±
±±³          ³cSelecMvt - Tipo: C => Filtrar movimentos.					  ³±±
±±³          ³lCheckNDiv - Tipo: L => Filtrar não Divergente.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil									                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FillATFMod(cAlias,cDtIni,cDtfim,aConfig,aResult,cMod,cFilSelect,cSelecMvt,lCheckNDiv)

Local cQry			:= ""
Local cSelectEnt	:= ""
Local cMoeMod		:= ""
Local cBmpLeg		:= ""
Local cIdFil		:= GetFieldFil(cAlias)
Local cDataDoc		:= ""
Local cNroDoc		:= Alltrim(StrTran(aConfig[NRODOC],"+",","+space(1) ) ) + ", "
Local cMoeDoc		:= ""
Local cVlrDoc		:= ""
Local cNodia		:= ""

Local aDataMod	:= {}
Local aDataCtb	:= {}
Local aDataCV3	:= {}
Local aVlrMCtb	:= {}
Local aEntities := Ctbc66RetEnt()

Local nP		:= 0
Local nI		:= 0
Local nQtdEnt	:= len(aEntities[1])

local lCond1
local lCond2
local lCond3
local lCond4

cFilSelect := xfilial( cAlias, cFilSelect )

For nI := 1 to nQtdEnt
	cSelectEnt += alltrim(aEntities[1][nI,1])+ ", " + alltrim(aEntities[2][nI,1]) + ", "
Next nI

If "NO_" $ Upper(aConfig[DATADOC])
	cDataDoc := "	' ' " + aConfig[DATADOC] + ", "+ chr(13) + chr(10)
Else
	cDataDoc := "	" + aConfig[DATADOC] + ", "+ chr(13) + chr(10)
Endif

If "NO_" $ Upper(cNroDoc)
	cNroDoc := "	' ' " + cNroDoc + chr(13) + chr(10)
Else
	cNroDoc := "	" + cNroDoc + chr(13) + chr(10)
Endif

If "NO_" $ Upper(aConfig[MOEDOC])
	cMoeDoc := "	'01' " + aConfig[MOEDOC]+ ", "+ chr(13) + chr(10)
Else
	cMoeDoc := "	" + aConfig[MOEDOC]+ ", "+ chr(13) + chr(10)
Endif

If "NO_" $ Upper(aConfig[VLRDOC])
	cVlrDoc := "	0 " + aConfig[VLRDOC]+ ", "+ chr(13) + chr(10)
Else
	cVlrDoc := "	" + aConfig[VLRDOC]+ ", "+ chr(13) + chr(10)
Endif

If "NO_" $ Upper(aConfig[NODIA])
	cNodia := "	' ' " + aConfig[NODIA]+ ", "+ chr(13) + chr(10)
Else
	cNodia := "		" + aConfig[NODIA]+ ", "+ chr(13) + chr(10)
Endif

cQry := "SELECT "+ chr(13) + chr(10)
cQry += cIdFil + ", " + chr(13) + chr(10)
cQry += cDataDoc
cQry += cNroDoc
cQry += cMoeDoc
cQry += cVlrDoc
cQry += cNodia
cQry += "	" + cAlias + ".D_E_L_E_T_ DELETADO, "+ chr(13) + chr(10)
cQry += "	CT2.R_E_C_N_O_ CT2_RECNO,  "+ chr(13) + chr(10)
cQry += "	CT2_FILIAL,  "+ chr(13) + chr(10)
cQry += "	CT2_DATA,  "+ chr(13) + chr(10)
cQry += "	CT2_TPSALD,  "+ chr(13) + chr(10)
cQry += "	CT2_LOTE,  "+ chr(13) + chr(10)
cQry += "	CT2_SBLOTE, "+ chr(13) + chr(10)
cQry += "	CT2_DOC, "+ chr(13) + chr(10)
cQry += "	CT2_SEQLAN,  "+ chr(13) + chr(10)
cQry += "	CT2_LINHA,  "+ chr(13) + chr(10)
cQry += "	CT2_MOEDLC, "+ chr(13) + chr(10)
cQry += "	CT2_LP,  "+ chr(13) + chr(10)
cQry += "	CT2_NODIA,  "+ chr(13) + chr(10)
cQry += "	CT2_DEBITO,  "+ chr(13) + chr(10)
cQry += "	CT2_CREDIT,  "+ chr(13) + chr(10)
cQry += "	CT2_CCD,  "+ chr(13) + chr(10)
cQry += "	CT2_CCC,  "+ chr(13) + chr(10)
cQry += "	CT2_ITEMD,  "+ chr(13) + chr(10)
cQry += "	CT2_ITEMC,  "+ chr(13) + chr(10)
cQry += "	CT2_CLVLDB,  "+ chr(13) + chr(10)
cQry += "	CT2_CLVLCR,  "+ chr(13) + chr(10)
cQry += cSelectEnt + chr(13) + chr(10)
cQry += "	CT2_VALOR,  "+ chr(13) + chr(10)
cQry += "	CT2_SEQUEN, "+ chr(13) + chr(10)
cQry += "	CT2_DC, "+ chr(13) + chr(10)
cQry += "	CT2_CONFST, "+ chr(13) + chr(10)
cQry += "	CT2.D_E_L_E_T_ CT2_DELET  "+ chr(13) + chr(10)
cQry += "FROM "+ chr(13) + chr(10)
cQry += "	" + RetSQlName("CT2") + " CT2 "+ chr(13) + chr(10)
cQry += "LEFT JOIN "+ chr(13) + chr(10)

//*-*
If "NO_" $ Upper(aConfig[NODIA])

	cQry += "	" + RetSqlName(cAlias) + " " + cAlias + chr(13) + chr(10)
	cQry += "ON	 "+ chr(13) + chr(10)
	cQry += "	CT2_FILIAL = " + cIdFil + chr(13) + chr(10)
	cQry += "	AND " + chr(13) + chr(10)
	cQry += "	CT2_NODIA = ' '" + chr(13) + chr(10)
    cQry += "	AND " + cAlias + ".D_E_L_E_T_=''" + chr(13) + chr(10)

Else

	cQry += "	" + RetSqlName("CV3") + " CV3" + chr(13) + chr(10)
	cQry += "ON	 "+ chr(13) + chr(10)
	cQry += "	CV3_FILIAL = '" + cFilSelect + "'" + chr(13) + chr(10)
	cQry += "	AND " + chr(13) + chr(10)

      If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"

         cQry += " (Case When CV3_RECDES = ' ' Then 0 Else NVL(CAST(CV3_RECDES as int),0) End) = CT2.R_E_C_N_O_" + chr(13) + chr(10)

      Else

		 cQry += " CONVERT(Int,CV3_RECDES) = CT2.R_E_C_N_O_" + chr(13) + chr(10)

      EndIf

	cQry += "	AND " + chr(13) + chr(10)
	cQry += "	CV3_TABORI = 'SN3' " + chr(13) + chr(10)
	cQry += "	AND " + chr(13) + chr(10)
	cQry += "	CV3.D_E_L_E_T_ = ' ' " + chr(13) + chr(10)
	cQry += "INNER JOIN "+ chr(13) + chr(10)
	//*-*
	cQry += "	" + RetSqlName(cAlias) + " " + cAlias + chr(13) + chr(10)
	cQry += "ON	 "+ chr(13) + chr(10)

      If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"

	     cQry += " (Case When CV3_RECORI = ' ' Then 0 Else NVL(CAST(CV3_RECORI as int),0) End) = " + cAlias + ".R_E_C_N_O_ " + chr(13) + chr(10)

      Else

		 cQry += " CONVERT(Int,CV3_RECORI) = " + cAlias + ".R_E_C_N_O_ " + chr(13) + chr(10)

      EndIf

	cQry += "	AND " + chr(13) + chr(10)
	cQry += " " + cIdFil + " = '" + cFilSelect + "'" + chr(13) + chr(10)
	cQry += "	AND " + cAlias + ".D_E_L_E_T_= ' '" + chr(13) + chr(10)

EndIf


cQry += "WHERE " + chr(13) + chr(10)
cQry += "	CT2_FILIAL = '" + cFilSelect + "' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2_NODIA <> '' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2_DC <> '4' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2_MOEDLC = '01' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2_DATA BETWEEN '"+cDtIni+"' AND '"+cDtFim+"'	 " + chr(13) + chr(10)

cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2_CONFST IN (' ','1','2') " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2.D_E_L_E_T_=''" + chr(13) + chr(10)

cQry += "UNION " + chr(13) + chr(10)
cQry += "SELECT "+ chr(13) + chr(10)
cQry += cIdFil + ", " + chr(13) + chr(10)
cQry += cDataDoc
cQry += cNroDoc
cQry += cMoeDoc
cQry += cVlrDoc
cQry += cNodia
cQry += "	" + cAlias + ".D_E_L_E_T_ DELETADO, "+ chr(13) + chr(10)
cQry += "	CT2.R_E_C_N_O_ CT2_RECNO,  "+ chr(13) + chr(10)
cQry += "	CT2_FILIAL,  "+ chr(13) + chr(10)
cQry += "	CT2_DATA,  "+ chr(13) + chr(10)
cQry += "	CT2_TPSALD,  "+ chr(13) + chr(10)
cQry += "	CT2_LOTE,  "+ chr(13) + chr(10)
cQry += "	CT2_SBLOTE, "+ chr(13) + chr(10)
cQry += "	CT2_DOC, "+ chr(13) + chr(10)
cQry += "	CT2_SEQLAN,  "+ chr(13) + chr(10)
cQry += "	CT2_LINHA,  "+ chr(13) + chr(10)
cQry += "	CT2_MOEDLC, "+ chr(13) + chr(10)
cQry += "	CT2_LP,  "+ chr(13) + chr(10)
cQry += "	CT2_NODIA,  "+ chr(13) + chr(10)
cQry += "	CT2_DEBITO,  "+ chr(13) + chr(10)
cQry += "	CT2_CREDIT,  "+ chr(13) + chr(10)
cQry += "	CT2_CCD,  "+ chr(13) + chr(10)
cQry += "	CT2_CCC,  "+ chr(13) + chr(10)
cQry += "	CT2_ITEMD,  "+ chr(13) + chr(10)
cQry += "	CT2_ITEMC,  "+ chr(13) + chr(10)
cQry += "	CT2_CLVLDB,  "+ chr(13) + chr(10)
cQry += "	CT2_CLVLCR,  "+ chr(13) + chr(10)
cQry += cSelectEnt + chr(13) + chr(10)
cQry += "	CT2_VALOR,  "+ chr(13) + chr(10)
cQry += "	CT2_SEQUEN, "+ chr(13) + chr(10)
cQry += "	CT2_DC, "+ chr(13) + chr(10)
cQry += "	CT2_CONFST, "+ chr(13) + chr(10)
cQry += "	CT2.D_E_L_E_T_ CT2_DELET  "+ chr(13) + chr(10)

cQry += "FROM "+ chr(13) + chr(10)
cQry += "	" + RetSQlName("CT2") + " CT2 "+ chr(13) + chr(10)
cQry += "LEFT JOIN "+ chr(13) + chr(10)

//*-*
If "NO_" $ Upper(aConfig[NODIA])

	cQry += "	" + RetSqlName(cAlias) + " " + cAlias + chr(13) + chr(10)
	cQry += "ON	 "+ chr(13) + chr(10)
	cQry += "	CT2_FILIAL = " + cIdFil + chr(13) + chr(10)
	cQry += "	AND " + chr(13) + chr(10)
	cQry += "	CT2_NODIA = ' '" + chr(13) + chr(10)
    cQry += "	AND " + cAlias + ".D_E_L_E_T_=''" + chr(13) + chr(10)

Else

	cQry += "	" + RetSqlName("CV3") + " CV3" + chr(13) + chr(10)
	cQry += "ON	 "+ chr(13) + chr(10)
	cQry += "	CV3_FILIAL = '" + cFilSelect + "'" + chr(13) + chr(10)
	cQry += "	AND " + chr(13) + chr(10)

      If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"

         cQry += " (Case When CV3_RECDES = ' ' Then 0 Else NVL(CAST(CV3_RECDES as int),0) End) = CT2.R_E_C_N_O_" + chr(13) + chr(10)

      Else

		 cQry += " CONVERT(Int,CV3_RECDES) = CT2.R_E_C_N_O_" + chr(13) + chr(10)

      EndIf

	cQry += "	AND " + chr(13) + chr(10)
	cQry += "	CV3.D_E_L_E_T_ = ' ' " + chr(13) + chr(10)
	cQry += "INNER JOIN "+ chr(13) + chr(10)
	//*-*
	cQry += "	" + RetSqlName(cAlias) + " " + cAlias + chr(13) + chr(10)
	cQry += "ON	 "+ chr(13) + chr(10)

      If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"

	     cQry += " (Case When CV3_RECORI = ' ' Then 0 Else NVL(CAST(CV3_RECORI as int),0) End) = " + cAlias + ".R_E_C_N_O_ " + chr(13) + chr(10)

      Else

		 cQry += " CONVERT(Int,CV3_RECORI) = " + cAlias + ".R_E_C_N_O_ " + chr(13) + chr(10)

      EndIf

	cQry += "	AND " + chr(13) + chr(10)
	cQry += " " + cIdFil + " = '" + cFilSelect + "'" + chr(13) + chr(10)
	cQry += "	AND " + cAlias + ".D_E_L_E_T_= ' '" + chr(13) + chr(10)

EndIf

cQry += "WHERE " + chr(13) + chr(10)
cQry += "	CT2_FILIAL = '" + cFilSelect + "' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2_NODIA <> '' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2_DC <> '4' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2_MOEDLC = '01' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2_DATA BETWEEN '"+cDtIni+"' AND '"+cDtFim+"'	 " + chr(13) + chr(10)

cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2_CONFST IN (' ','1','2') " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	CT2.D_E_L_E_T_ <> ''" + chr(13) + chr(10)

cQry += "ORDER BY "+ chr(13) + chr(10)
cQry += "	CT2_FILIAL,  "+ chr(13) + chr(10)
cQry += "	CT2_DATA,  "+ chr(13) + chr(10)
cQry += "	CT2_LOTE,  "+ chr(13) + chr(10)
cQry += "	CT2_SBLOTE,  "+ chr(13) + chr(10)
cQry += "	CT2_DOC,  "+ chr(13) + chr(10)
cQry += "	CT2_LINHA,  "+ chr(13) + chr(10)
cQry += "	CT2_SEQLAN  "

cQry := ChangeQuery(cQry)

If Select("TRBCTB") > 0
	TRBCTB->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), "TRBCTB", .T., .F.)
TcSetField( "TRBCTB", aConfig[VLRDOC], "N", TamSx3("CT2_VALOR")[1], TamSx3("CT2_VALOR")[2] )

TRBCTB->(DbGotop())

If TRBCTB->(!eof())
	While TRBCTB->(!eof())
		aDataCV3 := Ctbc66CV3(TRBCTB->CT2_DATA,TRBCTB->CT2_SEQUEN,TRBCTB->CT2_SEQLAN,cFilSelect,TRBCTB->CT2_RECNO)
		nStatus := Ctbc66GRsc(,,"TRBCTB",2,aDataCV3,aConfig,@cBmpLeg)
		// monta condições apartir do Filtro
		lcond1:= (cSelecMvt == "2" 	.AND. nStatus == 3)
		lcond2:= (cSelecMvt == "1" 	.AND. (nStatus == 1 .OR. nStatus == 2))
		lcond3:= (cSelecMvt == "3"	.AND. nStatus != 0)
		lcond4:= (lCheckNDiv	.AND. nStatus == 0)

		If Empty(TRBCTB->DELETADO) .and. (!Empty(TRBCTB->&(aConfig[NRODOC])) .OR. !Empty(TRBCTB->&(aConfig[DATADOC])) .OR. !Empty(TRBCTB->&(aConfig[VLRDOC])))

			if lCond1 .OR. lCond2 .OR. lCond3 .OR. lCond4

				aAdd(aDataMod,cBmpLeg) // reservado para a legenda
				aAdd(aDataMod,TRBCTB->&(cIdFil))
				aAdd(aDataMod,cAlias)
				aAdd(aDataMod,stod(TRBCTB->&(aConfig[DATADOC])))	//data
				aAdd(aDataMod,TRBCTB->&(aConfig[NRODOC]))		//Documento

				If Valtype(TRBCTB->&(aConfig[MOEDOC])) == "N"
					cMoeMod := Alltrim(str(TRBCTB->&(aConfig[MOEDOC])))
				Else
					cMoeMod := Alltrim(TRBCTB->&(aConfig[MOEDOC]))
				Endif

				aAdd(aDataMod,cMoeMod)							//Moeda
				aAdd(aDataMod,TRBCTB->&(aConfig[VLRDOC]))		//Vrl Doc
				aAdd(aDataMod,TRBCTB->&(aConfig[NODIA]))		//Correlativo
				aAdd(aDataMod,aDataCV3[1])						//CV3_DEBITO
				aAdd(aDataMod,aDataCV3[2])						//CV3_CREDIT
				aAdd(aDataMod,aDataCV3[3])						//CV3_CCD
				aAdd(aDataMod,aDataCV3[4])						//CV3_CCC
				aAdd(aDataMod,aDataCV3[5])						//CV3_ITEMD
				aAdd(aDataMod,aDataCV3[6])						//CV3_ITEMC
				aAdd(aDataMod,aDataCV3[7])						//CV3_CLVLDB
				aAdd(aDataMod,aDataCV3[8])						//CV3_CLVLCR

				For nI := 1 to len(aDataCV3[9])
					aAdd(aDataMod,aDataCV3[9,nI])
				Next nI

				aAdd(aDataMod,nStatus)							//Adiciona codigo do status SEMPRE ao final do array, pois o relatorio lera o status dessa posicao
			else
				aDataMod := Array(16+(nQtdEnt*2))
				aFill(aDataMod,"")
				aDataMod[1] := LoadBitmap(GetResources(),"BR_VERMELHO")
				aDataMod[7] := 0
				aAdd(aDataMod,nStatus)							//Adiciona codigo do status SEMPRE ao final do array, pois o relatorio lera o status dessa posicao
			endif
		Else
			If Empty(TRBCTB->CT2_DELET)
				aDataMod := Array(16+(nQtdEnt*2))
				aFill(aDataMod,"")
				aDataMod[1] := LoadBitmap(GetResources(),"BR_VERMELHO")
				aDataMod[7] := 0
				aAdd(aDataMod,nStatus)							//Adiciona codigo do status SEMPRE ao final do array, pois o relatorio lera o status dessa posicao
			Endif
		Endif

		If Empty(TRBCTB->CT2_DELET) .AND. !Empty(TRBCTB->CT2_LOTE)
			aVlrMCtb := GetValMCT2(TRBCTB->CT2_NODIA,TRBCTB->CT2_SEQLAN,cFilSelect)

			aAdd(aDataCtb,TRBCTB->CT2_FILIAL)
			aAdd(aDataCtb,stod(TRBCTB->CT2_DATA))
			aAdd(aDataCtb,TRBCTB->CT2_TPSALD)
			aAdd(aDataCtb,TRBCTB->CT2_LOTE)
			aAdd(aDataCtb,TRBCTB->CT2_SBLOTE)
			aAdd(aDataCtb,TRBCTB->CT2_DOC)
			aAdd(aDataCtb,TRBCTB->CT2_LINHA)
			aAdd(aDataCtb,TRBCTB->CT2_LP)
			aAdd(aDataCtb,TRBCTB->CT2_SEQLAN)
			aAdd(aDataCtb,TRBCTB->CT2_NODIA)
			aAdd(aDataCtb,TRBCTB->CT2_DEBITO)
			aAdd(aDataCtb,TRBCTB->CT2_CREDIT)
			aAdd(aDataCtb,TRBCTB->CT2_CCD)
			aAdd(aDataCtb,TRBCTB->CT2_CCC)
			aAdd(aDataCtb,TRBCTB->CT2_ITEMD)
			aAdd(aDataCtb,TRBCTB->CT2_ITEMC)
			aAdd(aDataCtb,TRBCTB->CT2_CLVLDB)
			aAdd(aDataCtb,TRBCTB->CT2_CLVLCR)

			For nI := 1 to nQtdEnt
				aAdd(aDataCtb,TRBCTB->&(aEntities[1][nI,1]))
				aAdd(aDataCtb,TRBCTB->&(aEntities[2][nI,1]))
			Next nI

			aEval(aVlrMCtb,{|x| aAdd(aDataCtb,x)})

			aAdd(aDataCtb,TRBCTB->CT2_DC)

		Else
			If Empty(TRBCTB->DELETADO)
				aDataCtb := Array(19+(nQtdEnt*2)+len(aCtbc66Moe))
				aFill(aDataCtb,"")
				For nI := 19+(nQtdEnt*2) to len(aDataCtb)-1
					aDataCtb[nI] := 0
				Next nI
			Endif
		Endif

		nP := aScan(aResult,{|x| AllTrim(cMod) $ alltrim(x[1]) })

		If nP > 0
			If aResult[nP,2] == nil
				aResult[nP,2] := {}
			Endif

			If aResult[nP,3] == nil
				aResult[nP,3] := {}
			Endif
			if lCond1 .OR. lCond2 .OR. lCond3 .OR. lCond4
				aAdd(aResult[nP,2],aClone(aDataMod))
				aAdd(aResult[nP,3],aClone(aDataCtb))
			EndIf
			aDataMod := {}
			aDataCtb := {}
		Endif
		TRBCTB->(DbSkip())

	EndDo
Endif


If Select("TRBCTB") > 0
	TRBCTB->(DbCloseArea())
Endif

Return()
