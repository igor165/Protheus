
#Include "PROTHEUS.CH"
#Include "PLSA310.CH"
#include "PLSMGER.CH"
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSA310 Ё Autor Ё Tulio Cesar          Ё Data Ё 03.04.2000 Ё╠╠
╠╠цддддддддддедддддддддадддддддаддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Cadastro de Formas de Bloqueio da Usuario                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё Advanced Protheus 5.07                                     Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ Nenhum                                                     Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL           Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA310   

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis...                                                 Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL   aRotAux   := {}
LOCAL 	nNr
PRIVATE aRotina   := MenuDef()
PRIVATE cCadastro := fundesc() //"Formas de Bloqueio de UsuАrio"
PRIVATE cAlias    := "BG3"
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chama funcao de Browse...                                           Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BG3->(dbGoTop())

	If ExistBlock("PL310MEN")
		aRotAux := ExecBlock("PL310MEN",.F.,.F.,{})

		If ValType(aRotAux) == "A"
			for nNr := 1 to Len(aRotAux)
				AAdd(aRotina, aRotAux[nNr])
			Next
		EndIf	
	EndIf

BG3->(mBrowse(06,01,22,75,"BG3"))
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSA310MOVЁ Autor Ё Michele Tatagiba   Ё Data Ё 29.01.2002 Ё╠╠
╠╠цддддддддддедддддддддддадддддддаддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Monto uma enchoice especifica para a exclusao              Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ Nenhum                                                     Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL           Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/                     
Function PLSA310MOV(cAlias,nReg,nOpc)
Local I__f 		:= 0
Local nRetorno	:= 0

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis da EnchoiceBar...                                  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL bOK     := {|| nOpca := 1,If( PLSA310OK(M->BG3_CODBLO), ;
                      oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) }
LOCAL bCancel := {||oDlg:End()}
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis genericas...                                       Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE nOpcx        := nOpc
PRIVATE nOpca        := 0
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis da enchoice...                                     Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE aTELA[0][0]
PRIVATE aGETS[0]   
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis para controle de forma de pagamento...             Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE aSTela  := {}
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define Dialogo...                                                   Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE oDlg            

If nOpc == K_Incluir
	
	nRetorno := AxInclui(cAlias,nReg,K_Incluir)

ElseIf nOpc == K_Alterar
	
	nRetorno := AxAltera(cAlias,nReg,K_Alterar)

ElseIf nOpc == K_Excluir
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta ,M->??? para enchoice...                                       Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Copy cAlias TO MEMORY
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define dialogo...                                                   Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	SetEnch("") 
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM ndLinIni,ndColIni TO ndLinFin,ndColFin OF GetWndDefault()
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta Enchoice dos Dados Gerais ...                                 Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Zero();MsMGet():New(cAlias,nReg,nOpc,,,,,{012,001,195,356},,,,,,oDlg,,,.F.)
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Ativa o dialogo...                                                  Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOK,bCancel,.F.,{})
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Trata atualizacao dos dados...  
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If nOpca == K_OK
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicio da Transacao...                                              Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды 
		Begin Transaction
		PLUPTENC("BG3",nOpc)            
		End Transaction
	Endif   
EndIf 

If nRetorno == 1 .And. nOpc <> K_Excluir .And. ExistBlock("PL310GRV")
	   
	ExecBlock("PL310GRV",.F.,.F.,{nOpc})

EndIf
Return

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLS310New Ё Autor Ё Michele Tatagiba   Ё Data Ё 28.01.2002 Ё╠╠
╠╠цддддддддддедддддддддддадддддддаддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Busca novo codigo para bloqueio de beneficiario            Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ Nenhum                                                     Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL           Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/                     
Function PLS310New(cPropri)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca o proximo codigo...                                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL cNew

BG3->(DbSetOrder(1))

If cPropri == "9"
   BG3->(DbSeek(xFilial("BG3")+cPropri+"99"))
Else
   If cPropri == "1"
      BG3->(DbSeek(xFilial("BG3")+"9"))
   Endif
Endif
BG3->(DbSkip(-1))

If BG3->BG3_PROPRI == cPropri
   cNew := cPropri+StrZero(Val(Subs(BG3->BG3_CODBLO,2,2))+1,2)
Else
   cNew := cPropri+"01"
Endif

Return(cNew)

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLS310VLD Ё Autor Ё Michele Tatagiba   Ё Data Ё 28.01.2002 Ё╠╠
╠╠цддддддддддедддддддддддадддддддаддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Verifica se o campo rdmake foi utilizado                   Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ Nenhum                                                     Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL           Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/                     
Function PLS310VLD()
Return(M->BG3_PERBLO == "0" .And. M->BG3_PROPRI <> "1")

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSA310OK Ё Autor Ё Michele Tatagiba   Ё Data Ё 29.01.2002 Ё╠╠
╠╠цддддддддддедддддддддддадддддддаддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Verifica se existe alguma Usuario com esse codigo de bloqueiЁ╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ Nenhum                                                     Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL           Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/                     
Function PLSA310OK(cCodBlo)

LOCAL nRecBA3 := BA3->(Recno())
LOCAL nOrdBA3 := BA3->(IndexOrd())
LOCAL cInd    := CriaTrab(Nil,.F.)
LOCAL cFor    := ""
LOCAL lRet    := .T.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta Expressao de filtro...                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cFor := "BA3_FILIAL = '"+xFilial("BA3")+"' .And. "
cFor += "BA3_MOTBLO == '"+cCodBlo+"'"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta filtro de acordo com os grupos informados no parametro...          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BA3->(IndRegua("BA3",cInd,"BA3_MOTBLO",nil,cFor,nil,.T.))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posicione no primeiro registro no arquivo de Usuario                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !BA3->(EOF())
   Alert(OemtoAnsi(STR0007)) //"Existe alguma Usuario bloqueada com esse motivo !"
   lRet := .F.
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Restaura dados salvados...                                          Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BA3->(DbSetOrder(nOrdBA3))
BA3->(DbGoTo(nRecBA3))

Return(lRet)


/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPL310HDE  ╨Autor  ЁAlexander           ╨ Data Ё  16/05/05   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁExibe Selecao para montar historico de desbloqueio		  ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PL310HDE(cOEMatric)

    Local cSql        
    Local dDataDes
    Local cHoraDes
    Local cTitulo

    Local cHistorico := OemtoAnsi(STR0008) //'Historico de Usuario Reativado'
    
    Local aSelecao   := {}
    Local aRet		 := {}           

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁQuery para mostrar o historio por data														Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cSql := " SELECT DISTINCT BQY_DATA,BQY_HORA "
	cSql += " FROM "+RetSqlName("BQY")+" "
	cSql += " WHERE BQY_FILIAL+BQY_MATRIC = '"+cOEMatric+"'"
	cSql += "   AND BQY_ALIAS  = 'BA1' "

	PLSQuery(cSql,"QHTs")
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁVerifica se retornou alguma coisa															Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If QHTs->(Eof())                                            
	   QHTs->(DbCloseArea())                                       
	   MsgInfo(OemtoAnsi(STR0009)) //'NЦo existe historico para esta matricula'
	   Return
	EndIf                  
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁMonta matriz para selecao de desbloqueio														Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	While !QHTs->(Eof())    
	   AaDd(aSelecao,{ QHTs->(BQY_DATA),QHTs->(BQY_HORA) } )                        
	   QHTs->(DbSkip()) 
	EndDo               
	QHTs->(DbCloseArea())	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁSe existir mais de um monstra o plscrigen para selecao de qual data e hora de desbloqueio	Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If Len(aSelecao) > 1
		aRet := PlsCriGen(aSelecao,{ {OemtoAnsi(STR0010),'@C',060},{OemtoAnsi(STR0012),'@C',050} },cHistorico) //'Data Reativacao' 'Hora'
		If aRet[1]
		   dDataDes := aSelecao[aRet[2],1]
		   cHoraDes := aSelecao[aRet[2],2]
		   MsAguarde({ || PL310HDEU(dDataDes,cHoraDes,cOEMatric,cHistorico), OemtoAnsi(STR0011), "", .T. }) //"Aguarde."
	    Else 
	       Return
	    EndIf   
    Else
	    MsAguarde({ || PL310HDEU(aSelecao[1,1],aSelecao[1,2],cOEMatric,cHistorico) ,  OemtoAnsi(STR0011), "", .T. }) //"Aguarde"
    EndIf
Return


/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPL310HDEU ╨Autor  ЁAlexander           ╨ Data Ё  16/05/05   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁExibe historico de usuario reativado     					  ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
		 
Function PL310HDEU(dDataDes,cHoraDes,cOEMatric,cHistorico)

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁDeclaracao de variavel																			Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Local cAlias 	
	Local cTitulo
	Local cConteudo                
	Local cCampo
	Local nLin
	Local nCol
	Local nLinM
	Local nColM
	Local nI
	Local nJ
	
	Local oDlg                             
	Local oFont
	Local oLista	
	
	Local aTmp                        
	Local aMatCab
	Local aMatDad    
	
	Local nQtdLin
	Local nQtdCol
	Local cPicture
	
	Local nTrocaLin := 0
	Local bOK       := {|| ( oDlg:End(), .T.) }
	Local bCancel   := {|| ( oDlg:End(), .T.) }
	Local aBotoes   := {}
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁGuarda o filtro do sx2																		Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Local cFilX2    := SX2->(DbFilter())    
	// variaveis lgpd
	local oGetChave    := NIL      
	local objCENFUNLGP := CENFUNLGP():New()         
	local lObfs 	   := .f.                                                  
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁQuery para selecionar historico do usuario													Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cSql := " SELECT BQY_DATA,BQY_ALIAS,BQY_SEQUEN,BQY_CAMPO,BQY_CONTEU "
	cSql += " FROM "+RetSqlName("BQY")+" "
	cSql += " WHERE BQY_FILIAL+BQY_MATRIC = '"+cOEMatric+"'"
    cSql += "   AND BQY_DATA = '"+DtoS(dDataDes)+"'"
    cSql += "   AND BQY_HORA = '"+cHoraDes+"'"
	cSql += " Order By R_E_C_N_O_ "
	PLSQuery(cSql,"QHis")
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁVerifica se retornou alguma coisa															Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If QHis->(Eof())
	   MsgInfo(OemtoAnsi(STR0009)) //'NЦo existe historico para esta matricula'
	   QHis->(DbCloseArea())
	   Return
	EndIf  
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁTitulo da tela																				Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cHistorico += OemtoAnsi(STR0013)+TransForm(QHis->(BQY_DATA),'@D') //' - Data de Reativacao: '
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁLimpa o filtro do sx2																		Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DbSelectArea("SX2")               
	SX2->(DbClearFilter())
	DbSetOrder(1) 
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁMonta Matriz dinamicamente de acordo com o historico do bqy									Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	While !QHis->(Eof())
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁCheca se mudou o alias																		Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    	If cAlias <> QHis->(BQY_ALIAS) 
    	   cAlias   := QHis->(BQY_ALIAS)
		   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		   //ЁMonta a matriz de cabecalho somente se nao for BA1										   Ё
		   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    	   If cAlias <> 'BA1'
	    	   aMatCab  := 'a'+cAlias+'Cab'
	    	   &aMatCab := {}
	       EndIf	   
    	   aMatDad  := 'a'+cAlias+'Dad'
    	   &aMatDad := {}                          
		   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		   //ЁMatriz de botoes.. Descricao																   Ё
		   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    	   AaDd(aBotoes , {cAlias, Posicione('SX2' , 1 , cAlias , 'X2_NOME')} )
    	EndIf                   
	    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	    //ЁPega o campo e monta o conteudo conforme o tipo no sx3										Ё
	    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   	    cCampo := QHis->(BQY_CAMPO)	                 
   	    cTipo  := Posicione('SX3' , 2 , cCampo , 'X3_TIPO')
	    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	    //ЁCheca os tipos																				Ё
	    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   	    Do Case
   	       Case cTipo == 'C'
	   	        cConteudo := AllTrim(QHis->(BQY_CONTEU))
   	       Case cTipo == 'D'
	   	        cConteudo := StoD(AllTrim(QHis->(BQY_CONTEU)))
   	       Case cTipo == 'N'
 	   	        cConteudo := Val(AllTrim(QHis->(BQY_CONTEU)))
 	   	   oTherWise
 	   	        cConteudo := AllTrim(QHis->(BQY_CONTEU))
   	    EndCase                  
	    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	    //ЁTroca o valor do conteudo conforme x3_cbox na tabela sx3										Ё
	    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   	    cBoxC := Posicione('SX3' , 2 , cCampo , 'X3_CBOX')                         
   	    If !Empty(cBoxC)
            cConteudo := alltrim(X3COMBO(cCampo,cConteudo))
	   	EndIf
	    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	    //ЁPega o titulo de cada campo no caso de ba1 e cabecalho se nao 								Ё
	    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	    cTitulo  := Posicione('SX3' , 2 , cCampo , 'X3_TITULO')
	    If cAlias == 'BA1'   
	    	AaDd( &aMatDad, { cTitulo, cCampo, TransForm( cConteudo , PesqPict(cAlias , cCampo) )} )
	    Else   
	   	    If AsCan(&aMatCab,{|x| x[1] == cTitulo }) == 0
		   	   cPicture := Posicione('SX3' , 2 , cCampo , 'X3_PICTURE')
	   	       cPicture := Iif(Empty(cPicture),'@!',cPicture)
	       	   AaDd( &aMatCab, { cTitulo , cPicture , PL310HDETC(cCampo) } )
	        EndIf	   
	    	AaDd( &aMatDad, { QHis->(BQY_SEQUEN), cTitulo , cConteudo } )
	    EndIf	
		QHis->(DbSkip())
	EndDo               
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁFecha a area de trabalho																		Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	QHis->(DbCloseArea())                                       
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁConforme os botoes. monta o (acols) do plscrigen												Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    For nI := 1 To Len(aBotoes)
    
        If aBotoes[nI,1] <> 'BA1' 
	
			aMatDad  := 'a'+aBotoes[nI,1]+'Dad'
			aMatCab  := 'a'+aBotoes[nI,1]+'Cab'
			
	        aSort(&aMatDad,,, { |x, y| SubString(x[1],1,4) > SubString(Y[1],1,4) })
		    nQtdLin := Val( SubString(&(aMatDad+'[1,1]'),1,4) )
		    
		    nQtdCol := Len(&aMatCab)
		    
	        aTmp    := Array( nQtdLin,nQtdCol )
	        
	        aSort(&aMatDad,,, { |x, y| x[1] < Y[1] })
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁMonta uma matriz temporaria para implementacao do cabecalho									Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	        For nJ := 1 To Len(&aMatDad)
			   nLinM   := Val(SubString(&( aMatDad+'['+Str(nJ)+',1]' ),1,4))
	           cTitulo := &( aMatDad+'['+Str(nJ)+',2]' )
			   nColM   := AsCan(&aMatCab,{|x| x[1] == cTitulo }) 
	       	   aTmp[nLinM,nColM] := &( aMatDad+'['+Str(nJ)+',3]' )
	        Next                           
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁCarrega a matriz que vai ser exibida															Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	        &aMatDad  := aClone(aTmp)
	    EndIf    
    Next
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁRetorna com o filtro do sx2																	Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DbSelectArea("SX2")             
	Set Filter To &cFilX2
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁDefinicao de fonte e monta a tela															Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Define FONT oFont NAME "Courier New" Size 0,-11
	Define MsDialog oDlg Title cHistorico From 160,70 TO 600,950 PIXEL 
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁScroll para dados do ba1																		Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	@ 15,01 ScrollBox oScroll Vertical Horizontal  Size 100,435 of oDlg BORDER
	
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁConforme a matriz de abotoes exibe os botoes	e monta o nome da matriz de cab e dad			Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	    For nI := 1 To Len(aBotoes)
		    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		    //ЁMonta o nome da matriz a ser exibida															Ё
		    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aMatDad  := 'a'+aBotoes[nI,1]+'Dad'
	        If aBotoes[nI,1] == 'BA1'   
	           nLin     := 010
               nCol     := 005                       
	           nMudaCol := 154                          
			   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			   //ЁCarrega os dados para um campo em memoria													   Ё
			   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	           For nJ := 1 To Len(&aMatDad) 
	           	   cTitulo   := &(aMatDad+'['+AllTrim(Str(nJ))+',1]')
	           	   cCampo    := 'M->'+AllTrim(&(aMatDad+'['+AllTrim(Str(nJ))+',2]'))
	           	   cConteudo := AllTrim(&(aMatDad+'['+AllTrim(Str(nJ))+',3]'))

	           	   if !Empty(cTitulo)
					   ++nTrocaLin                       
					   cTitulo 	 += Replicate(' ' , (15-Len(cTitulo)) )
			           cMTitulo  := "{||'"+cTitulo+"'}"		                                                      
			           cMCampo   := cCampo
					   &cMCampo  := cConteudo
			           cBlock    := "{ |u| If( PCount() == 0, "+cMCampo+", "+cMCampo+" := u ) }"
					   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					   //ЁCheca se pode mostrar a coluna na mesma linha	(Maior campo preenchido (Mae) Tamanho 120)	   Ё
					   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	   			       If ( (Len(cTitulo+cConteudo)*3.3)+nCol ) > 462 
	            	      nTrocaLin := 0
			              nLin 		+= 010
			              nCol  	:= 005
			           EndIf
					   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					   //ЁExibe o nome referente ao ba1															   	   Ё
					   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				   	   TSay():New( nLin, nCol, &cMTitulo , oScroll,, oFont ,,,,.t.)
				   	   nCol += (Len(cTitulo)*3.3)       
					   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					   //ЁExibe o conteudo referente ao ba1															   Ё
					   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            		   oGetChave := TGet():New( nLin-3, nCol, &cBlock , oScroll, ( (Len(cConteudo)*3.3)+10 ) , 08, "@!",,nil,nil,nil,nil,nil,.T.,nil,nil,nil,.F.,nil,nil,.T.,Nil,nil,nil)
				   	   nCol += ( (Len(cConteudo)*3.3)+10 ) 

						if objCENFUNLGP:isLGPDAt()
							lObfs := objCENFUNLGP:getTGet(&(aMatDad+'['+AllTrim(Str(nJ))+',2]'))
							oGetChave:lObfuscate := lObfs
						endif
					   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					   //ЁCheca se pode exibir numa determinada coluna												   Ё
					   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			           If nCol > 154 .and. nCol <= 308
   	  			          nCol	:= 309
   	  			       ElseIf nCol < 154
   	  			          nCol	:= 155
   	  			       Else
	  			       	  nTrocaLin := 0
			              nLin 		+= 010
			              nCol  	:= 005
			           EndIf
					   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					   //ЁTroca a linha																				   Ё
					   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		               If nTrocaLin == 4  
	            	      nTrocaLin := 0
			              nLin 		+= 010
			              nCol  	:= 005
					   EndIf	   
				   EndIf	   
			   Next
			   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			   //ЁPara controle dos botoes																	   Ё
			   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
 	           nCol := 002
 	           nLin := 117
	        Else                 
			   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			   //ЁMontando o nome da matriz de cabecalho 													   Ё
			   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			   aMatCab   := 'a'+aBotoes[nI,1]+'Cab'
	           cTextoBtn := AllTrim( aBotoes[nI,2] )
			   cChamada  := '{|| PlsCriGen('+aMatDad+','+aMatCab+',"'+cTextoBtn+'") }'                
     		   If nCol > 400
			      nCol := 002
			      nLin += 015
			   EndIf    
			   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			   //ЁExibe o botoa																				   Ё
			   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			   TButton():New( nLin, nCol, cTextoBtn, oDlg,  &cChamada , 100, 15,,,,.T.)
			   nCol +=100
			EndIf	
		Next	
    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //ЁExibe a Tela																				   Ё
    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Activate MsDialog oDlg On Init EVal({||EnChoiceBar(oDlg,{||EVal(bOk)},{||EVal(bCancel)},.F.)} )
	
Return
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPL310HDETC╨Autor  ЁAlexander			 ╨ Data Ё  05/17/05   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Acha o tamanho da colunao de um Browse somente necessario  ╨╠╠
╠╠╨          Ё passar o nome do campo                                     ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PL310HDETC(cCampo)                                                  

    Local nTamTitu
    Local ntamanho
     
    nTamTitu := Len( Posicione('SX3' , 2 , cCampo , 'X3_TITULO') )
    nTamanho := Posicione('SX3' , 2 , cCampo , 'X3_TAMANHO')
    If nTamTitu > nTamanho
       nTamanho := nTamTitu
    EndIf   
    nTamanho += Iif(Posicione('SX3' , 2 , cCampo , 'X3_TIPO') <> 'C',(nTamanho*1.5),( nTamanho*3.8 ) )
    
Return nTamanho

//-------------------------------------------------------------------
/*/{Protheus.doc} PLVLDPERBL

Valida os perМodos de bloqueio e desbloqueio de usuАrios

@author  Karine Riquena Limp
@version P12
@since   05/07/2017

/*/
//-------------------------------------------------------------------
Function PLVLDPERBL(cAlias, cMatric, cTipReg, dData, cTp)

LOCAL lRet  := .T.
LOCAL cMsg  := ""
LOCAL nOpca := 0
LOCAL cSql  := ""
LOCAL oDlg
LOCAL aAreaAlias := (cAlias)->(getArea())
LOCAL cTitular  := SuperGetMv("MV_PLCDTIT")
LOCAL cMatDlg   := ""
LOCAL dNewData  := Date()
Local oData := NIL
Local dDtLastBlq 
DEFAULT cTipReg := ""

	
	if(cAlias == "BCA")
		lRet := (Empty(BA1->BA1_DATBLO) .OR. (!EMPTY(BA1->BA1_DATBLO) .AND. M->BCA_DATA >= BA1->BA1_DATBLO)) 
		cMsg := "O beneficiАrio jА encontra-se bloqueado nesta data"
	else 
		lRet := (Empty(BA3->BA3_DATBLO) .OR. (!EMPTY(BA3->BA3_DATBLO) .AND. M->BC3_DATA >= BA3->BA3_DATBLO))           
		cMsg := "A famМlia jА encontra-se bloqueada nesta data"
	endIf
	
	//Para existir um desbloqueio, sempre deve haver um bloqueio
	//Estou validando para nЦo incluir bloqueio em um periodo bloqueado
	//Exemplo:
	//bloqueio: 01/01/2017 desbloqueio: 31/12/2017
	//o sistema nЦo permitirА incluir um bloqueio no meio desse periodo, em 01/06/2017 por exemplo
	//somente a partir de 01/01/2018
	//entЦo eu chamo uma dialog para que o usuАrio possa alterar a data do ultimo desbloqueio, nesse caso 31/12/2017, para poder incluir um novo bloqueio vigente
	
	if lRet .AND. cTp == "0"
				
 		lRet := !PlChHiBlo(cAlias,dData,cMatric,cTipReg)
		
		//POSICIONO NO REGISTRO DO DESBLOQUEIO QUE и O ULTIMO
		cSql := " SELECT MAX(R_E_C_N_O_) AS RECNO FROM " + RetSqlName(cAlias)
		cSql += " WHERE "
		cSql += cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
		cSql += " AND " + cAlias + "_MATRIC = '" + cMatric + "' "
		cSql += iif(cAlias == "BCA","AND BCA_TIPREG = '" + cTipReg + "' "," ")
		cSql += " AND " + cAlias + "_TIPO = '1'"
		
		cSql := ChangeQuery(cSql)
		
		If Select("TRBLOQ") > 0
			TRBLOQ->(DbCloseArea())
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRBLOQ",.F.,.T.)
		
		//POSICIONO NO REGISTRO DO ULTIMO BLOQUEIO PARA INFORMAR PRO USUARIO QUE A NOVA DATA TEM QUE SER MAIOR
		cSql := " SELECT MAX(R_E_C_N_O_) AS RECNO, " + cAlias + "_DATA AS DATAUBLQ FROM " + RetSqlName(cAlias)
		cSql += " WHERE "
		cSql += cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
		cSql += " AND " + cAlias + "_MATRIC = '" + cMatric + "' "
		cSql += iif(cAlias == "BCA","AND BCA_TIPREG = '" + cTipReg + "' "," ")
		cSql += " AND " + cAlias + "_TIPO = '1'"
		cSql += " GROUP BY " + cAlias + "_DATA "
		
		cSql := ChangeQuery(cSql)
		
		If Select("TRUBLOQ") > 0
			TRUBLOQ->(DbCloseArea())
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRUBLOQ",.F.,.T.)

		
		if !lRet .AND. TRBLOQ->(!EOF())
			
			if MsgYesNo(cMsg + ". Deseja alterar a data do desbloqueio para uma data anterior Ю " + dtoc(dData) + " para que esse novo bloqueio seja o corrente?","AtenГЦo")
			
				aArea := (cAlias)->(getArea())
				
				(cAlias)->(dbGoto(TRBLOQ->RECNO))
				
				if empty(dDtLastDesbloq) .and. nRecLastDesbloq == 0
					dDtLastDesbloq := &(cAlias+"->"+cAlias+"_DATA")
					nRecLastDesbloq := TRBLOQ->RECNO
				endIf
							
				DEFINE MsDialog oDlg Title "Desbloqueio" FROM 0,0 TO 17,60 OF GetWndDefault()

					if cAlias == "BCA"
						BA1->(dbSetOrder(2))
						BA1->(msSeek(xFilial("BA1")+BCA->(BCA_MATRIC+BCA_TIPREG)))
						cMatDlg := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
						@ 5,10  SAY "BeneficiАrio: "          SIZE 60,10  OF oDlg PIXEL
						@ 5,72  SAY alltrim(BA1->BA1_NOMUSR)  SIZE 300,10 OF oDlg PIXEL
						@ 10,10 SAY "MatrМcula: "             SIZE 30,10  OF oDlg PIXEL
						@ 10,72 SAY cMatDlg                   SIZE 60,10  OF oDlg PIXEL
						@ 15,10 SAY "Data do desbloqueio: "   SIZE 60,10  OF oDlg PIXEL
						@ 15,72 SAY dtoc(BCA->BCA_DATA)       SIZE 30,10  OF oDlg PIXEL
						@ 20,10 SAY "Motivo do desbloqueio: " SIZE 60,10  OF oDlg PIXEL
						@ 20,72 SAY BCA->BCA_MOTBLO + " - " + PLRETMOBLQ("BCA") SIZE 60,10 OF oDlg PIXEL
					else
						BA3->(dbSetOrder(1))
						BA3->(msSeek(xFilial("BC3")+BC3->BC3_MATRIC))
						BA1->(dbSetOrder(1))
						BA1->(msSeek(xFilial("BA1")+BC3->BC3_MATRIC+cTitular))
						cMatDlg := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
						@ 5,10  SAY "Titular: "          	   SIZE 60,10 OF oDlg PIXEL
						@ 5,72  SAY alltrim(BA1->BA1_NOMUSR)  SIZE 300,10 OF oDlg PIXEL
						@ 10,10 SAY "MatrМcula: "             SIZE 30,10 OF oDlg PIXEL
						@ 10,72 SAY cMatDlg                   SIZE 60,10 OF oDlg PIXEL
						@ 15,10 SAY "Data do desbloqueio: "   SIZE 60,10 OF oDlg PIXEL
						@ 15,72 SAY dtoc(BC3->BC3_DATA)       SIZE 30,10 OF oDlg PIXEL
						@ 20,10 SAY "Motivo do desbloqueio: " SIZE 60,10 OF oDlg PIXEL
						@ 20,72 SAY BC3->BC3_MOTBLO + " - " + PLRETMOBLQ("BC3") SIZE 60,10 OF oDlg PIXEL
					endIf
					
					
					@ 35,10 SAY "Nova Data: " SIZE 30,15 OF oDlg PIXEL
					@ 35,72 MSGET oData VAR dNewData PICTURE "@D" SIZE 50,10 VALID !EMPTY(dNewData) .and. PLVLNEWDT(cAlias,dData,dNewData) OF oDlg PIXEL 
										
					DEFINE SBUTTON FROM 50,30  TYPE 1 ACTION PLGRVDBLQ(cAlias, dNewData, oDlg) ENABLE OF oDlg
							
					DEFINE SBUTTON FROM 50,60  TYPE 2 ACTION (lRet := .F., oDlg:End()) ENABLE OF oDlg
					
					if(GetNewPar("MV_PLSEXCO",.F.))
						@ 65,10  SAY "Lembre-se de alterar esse registro de desbloqueio na central de obrigaГУes " COLOR CLR_HRED SIZE 250,10  OF oDlg PIXEL
					endif
				
				ACTIVATE MSDIALOG oDlg CENTERED
								
			endIf
			
			TRBLOQ->(DbCloseArea())
			TRUBLOQ->(DbCloseArea())
		
		endIf
		
	endIf
	
	
	(cAlias)->(restArea(aAreaAlias))
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLRETMOBLQ
Retorna o motivo de bloqueio para a dialog

@author  Karine Riquena Limp
@version P12
@since   06/07/2017

/*/
//-------------------------------------------------------------------
Function PLRETMOBLQ(cAlias)

LOCAL cMotBlo := &(cAlias+"->"+cAlias+"_MOTBLO")
LOCAL cNivBlq := &(cAlias+"->"+cAlias+"_NIVBLQ")
LOCAL cAliasPesq := ""
LOCAL cRet    := ""

	If !Empty(cMotBlo)
	
		Do case
			case cNivBlq == "S"
			 	cAliasPesq := "BQU"
			case cNivBlq == "F"
			 	cAliasPesq := "BG1"
			case cNivBlq == "U"
				cAliasPesq := "BG3"
		EndCase
		
		cRet := alltrim(Posicione(cAliasPesq,1,xFilial(cAliasPesq)+cMotBlo,cAliasPesq+"_DESBLO"))
	
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLVLNEWDT
Valida se a nova data informada para o desbloqueio И menor do que a data do 
bloqueio que o usuАrio estА tentando fazer e maior do que a data do bloqueio
atual

@author  Karine Riquena Limp
@version P12
@since   06/07/2017

/*/
//-------------------------------------------------------------------
Static Function PLVLNEWDT(cAlias, dData, dNewDt)

LOCAL cAliBlo := iif(cAlias == "BCA", "BA1", "BA3")
LOCAL lRet := dNewDt <= dData .and. dNewDt >= &(cAliBlo+"->"+cAliBlo+"_DATBLO")
LOCAL dDtLastBlq 

if(!lRet)
	
	if Select("TRUBLOQ") > 0 .and. TRUBLOQ->(!EOF())
		dDtLastBlq := ctod(TRUBLOQ->DATA)
	endIf
	
	msgAlert("A data inserida para alterar o desbloqueio deve ser maior que a do bloqueio atual (" + dtoc(dDtLastBlq) + ") e menor que a data inserida para o novo bloqueio (" + dtoc(dData) + ")")
endIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLGRVDBLQ
Grava a nova data no ultimo bloqueio

@author  Karine Riquena Limp
@version P12
@since   06/07/2017

/*/
//-------------------------------------------------------------------
Static Function PLGRVDBLQ(cAlias, dNewData, oDlg)
LOCAL cAliBlo := iif(cAlias == "BCA", "BA1", "BA3")
LOCAL cSql := ""
LOCAL dDtAnt := &(cAlias+"->"+cAlias+"_DATA")
LOCAL nI := 0

	Begin Transaction
		
		(cAlias)->(recLock(cAlias, .F.))
			&(cAlias+"->"+cAlias+"_DATA") := dNewData
		(cAlias)->(msUnlock())
	
		if(cAlias == "BC3")
			
			BA1->(dbSetOrder(1))
			BA1->(msSeek(xFilial("BA1")+BC3->BC3_MATRIC))
			aBCARecbloq := {}
			
			while BA1->(!EOF()) .and. (xFilial("BA1")+BC3->BC3_MATRIC) == BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC)
					
					//POSICIONO NO REGISTRO DO DESBLOQUEIO DA BCA DO USUARIO PARA ALTERAR TAMBиM
					cSql := " SELECT MAX(R_E_C_N_O_) AS RECNO FROM " + RetSqlName("BCA")
					cSql += " WHERE "
					cSql += "BCA_FILIAL = '" + xFilial("BCA") + "' "
					cSql += " AND BCA_MATRIC = '" + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) + "' "
					cSql += " AND BCA_TIPREG = '" + BA1->BA1_TIPREG + "' "
					cSql += " AND BCA_TIPO = '1' "
					cSql += " AND BCA_DATA = '" + DTOS(dDtAnt) + "' "
			
					cSql := ChangeQuery(cSql)
			
					If Select("TRBLOQBCA") > 0
						TRBLOQBCA->(DbCloseArea())
					EndIf
					
					dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRBLOQBCA",.F.,.T.)
					
					if TRBLOQBCA->(!EOF()) 
						aAdd(aBCARecbloq, TRBLOQBCA->RECNO)
					endIf
					
				
				BA1->(dbSkip())
				
			endDo
			
			for nI := 1 to len(aBCARecbloq)
				BCA->(dbGoto(aBCARecbloq[nI]))
				BCA->(RecLock("BCA", .F.))
					BCA->BCA_DATA := dNewData
				BCA->(msUnlock())
			next nI
			
			If Select("TRBLOQBCA") > 0
				TRBLOQBCA->(DbCloseArea())
			EndIf
					
		endIf
				
	End Transaction
	
	msgInfo("Data alterada com sucesso, agora И possМvel incluir um novo bloqueio a partir de " + dtoc(dNewData))
	oDlg:End()

Return .T.

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma  ЁMenuDef   Ё Autor Ё Darcio R. Sporl       Ё Data Ё04/01/2007Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Utilizacao de menu Funcional                               Ё╠╠
╠╠Ё          Ё                                                            Ё╠╠
╠╠Ё          Ё                                                            Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁRetorno   ЁArray com opcoes da rotina.                                 Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁParametros do array a Rotina:                               Ё╠╠
╠╠Ё          Ё1. Nome a aparecer no cabecalho                             Ё╠╠
╠╠Ё          Ё2. Nome da Rotina associada                                 Ё╠╠
╠╠Ё          Ё3. Reservado                                                Ё╠╠
╠╠Ё          Ё4. Tipo de Transa┤└o a ser efetuada:                        Ё╠╠
╠╠Ё          Ё	  1 - Pesquisa e Posiciona em um Banco de Dados           Ё╠╠
╠╠Ё          Ё    2 - Simplesmente Mostra os Campos                       Ё╠╠
╠╠Ё          Ё    3 - Inclui registros no Bancos de Dados                 Ё╠╠
╠╠Ё          Ё    4 - Altera o registro corrente                          Ё╠╠
╠╠Ё          Ё    5 - Remove o registro corrente do Banco de Dados        Ё╠╠
╠╠Ё          Ё5. Nivel de acesso                                          Ё╠╠
╠╠Ё          Ё6. Habilita Menu Funcional                                  Ё╠╠
╠╠цддддддддддедддддддддддддддбдддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё   DATA   Ё Programador   ЁManutencao efetuada                         Ё╠╠
╠╠цддддддддддедддддддддддддддедддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё          Ё               Ё                                            Ё╠╠
╠╠юддддддддддадддддддддддддддадддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function MenuDef()
Private aRotina := {	{ STR0001	, 'AxPesqui' 	, 0 , K_Pesquisar  , 0, .F.},;
						{ STR0002	, 'AxVisual' 	, 0 , K_Visualizar , 0, Nil},;
						{ STR0003	, 'PLSA310MOV' 	, 0 , K_Incluir    , 0, Nil},;
						{ STR0004	, 'PLSA310MOV' 	, 0 , K_Alterar    , 0, Nil},;
						{ STR0005	, 'PLSA310MOV'	, 0 , K_Excluir    , 0, Nil}}
Return(aRotina)