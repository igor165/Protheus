#INCLUDE "plsa370.ch"
#include "PLSMGER.CH"
#Include "PROTHEUS.CH"  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA370 ³ Autor ³ Eduardo Motta        ³ Data ³ 23.05.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de Especialidades Medicas                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tulio Cesar ³05.06.02³ xxxx ³  Tratar exclusao existe movimentacao...  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA370(xAutoCab,xAutoItens,xOpcAuto,nReg)

Local aAliasItem := {{"BBM",STR0005,,,,{{OemtoAnsi(STR0010),;
					{||PlVigDifId("BBM",'M->(BAQ_FILIAL+BAQ_CODINT+BAQ_CODESP)+M->(BBM_CODPAD+BBM_CODPSA+BBM_NIVEL+BBM_TIPO+BBM_ATIVO)',M->BBM_DIFIDA)},;
					OemtoAnsi(STR0010),OemtoAnsi(STR0010)}}},; 
                  {"BMY",STR0006,,}}//"Period. Dif. Idade"

Local aKeyItem := {"BAQ->BAQ_CODINT+BAQ->BAQ_CODESP","BAQ->BAQ_CODINT+BAQ->BAQ_CODESP","BAQ->BAQ_CODINT+BAQ->BAQ_CODESP"}

Local aCondItem := {"BBM->BBM_CODINT+BBM->BBM_CODESP",;
                     "BMY->BMY_CODINT+BMY->BMY_CODESP"}

Local aChavCab := {{{"BBM_CODINT","M->BAQ_CODINT"},{"BBM_CODESP","M->BAQ_CODESP"}},;
                    {{"BMY_CODINT","M->BAQ_CODINT"},{"BMY_CODESP","M->BAQ_CODESP"}}}

Local nNum :=0

PRIVATE aCols   := {}
PRIVATE aHeader := {}
PRIVATE n       := 1 


PlsCabItem("BAQ",OemtoAnsi(STR0001),aAliasItem,{1,1,1},aKeyItem,aCondItem,aChavCab,nil,nil,xAutoCab,; //"Cadastro de Especialidades Medicas"
           xAutoItens,xOpcAuto,nReg,{||PLSA370GRV(nOpc) }, {|| PLSA370EXC()  }, , , , , .T.  )



Return                  


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSA370Cd³ Autor ³ Eduardo Motta        ³ Data ³ 23.05.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de Especialidades Medicas                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tulio Cesar ³05.06.02³ xxxx ³  Tratar exclusao existe movimentacao...  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLSA370Cd(cCodInt)
LOCAL nRet    := 0
LOCAL nOrdBAQ := BAQ->(IndexOrd())

BAQ->(DbSetOrder(1))

BAQ->(DbSeek(xFilial("BAQ")+cCodInt+Replicate("9",Len(BAQ->BAQ_CODESP)),.T.))
BAQ->(DbSkip(-1))
                                                           
If BAQ->(BAQ_FILIAL+BAQ_CODINT) <> xFilial("BAQ")+cCodInt
   nRet := StrZero(1,3)
Else
   nRet := StrZero(Val(BAQ->BAQ_CODESP)+1,3)
Endif

BAQ->(DbSetOrder(nOrdBAQ))

Return(nRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSA370EXC³ Autor ³Eduardo Motta        ³ Data ³ 23.05.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de Especialidades Medicas                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tulio Cesar ³05.06.02³ xxxx ³  Tratar exclusao existe movimentacao...  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLSA370EXC()
LOCAL lRet
Local lEspelhar := GetNewPar("MV_INTESPE",.F.)  // Parametro integração entre Tabelas GH e PLS   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa se existe relacionada a pelo menos uma rede de atendimento...      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BBF->(DbSetOrder(02))
BFN->(dbSetorder(01))
BBM->(dbSetorder(01))

If BBF->(DbSeek(xFilial("BBF")+BAQ->(BAQ_CODINT+BAQ_CODESP)))
	If	FunName() # "HSPAHA08" 	
		MsgInfo(OemtoAnsi(STR0002)) //"A Especialidade esta vinculada a pelo menos uma Rede de Atendimento"
	Else
		MsgInfo(OemtoAnsi(STR0008)) //"A Especialidade esta vinculada a pelo menos uma Rede de Atendimento Sincronismo  não Efetuado na Tabela do SIGAPLS"
	Endif
	
Elseif BFN->( dbSeek(xFilial("BFN")+BAQ->(BAQ_CODINT+BAQ_CODESP)))
	If FunName() # "HSPAHA08" 
		MsgInfo(OemtoAnsi( STR0003)) //"A Especialidade esta vinculada a pelo menos uma Sub-Especialidade"
	Else
		MsgInfo(OemtoAnsi(STR0009)) //"A Especialidade esta vinculada a pelo menos uma Sub-Especialidade Sincronismo  não Efetuado na Tabela do SIGAPLS"
	Endif
Else
	If MsgYesNo(OemtoAnsi(STR0004)) //"Confirma a Exclusao?"
		
		If BBM->( dbSeek(xFilial("BBM")+BAQ->(BAQ_CODINT+BAQ_CODESP+BAQ_CODPAD+BAQ_CODPSA)) )
			cKey := BAQ->(BAQ_CODINT+BAQ_CODESP+BAQ_CODPAD+BAQ_CODPSA)
			cSql := "UPDATE "+RetSqlName("BBM")+" SET D_E_L_E_T_ = '*' WHERE BBM_FILIAL='" + xFilial("BBM") + "' AND BBM_CODINT+BBM_CODESP+BBM_CODPAD+BBM_CODPSA = '"+cKey+"'"
			TcSqlExec(cSql)
		Endif
		
		Reclock("BAQ",.F.)
		Delete
		MsUnlock()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Rotina de Exclusão dos dados nas Tabelas de Gestão Hospitalar            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lEspelhar
			DbSelectarea ("GFR")
			GFR->(DbSetOrder(1))
			If GFR->(MsSeek(xFilial("GFR")+BAQ->BAQ_CODESP)) .and. HS_VldExc(BAQ->BAQ_CODESP)//Chama a Validação do HSP verificando se Registro pode ser Sincronizado
				DbSelectarea ("BBL")
				BBL->(DbSetOrder(2))
				If BBL->(MsSeek(xFilial("BBL")+"PLSA370   "+"BAQ"+"GFR"))
					RecLock("GFR", .F.)
					DbDelete()
					MsUnlock()
				Else
					If GetNewPar("MV_PLSMSGS","1") == "1"
						MsgAlert(OemtoAnsi(STR0007)) //"Arquivo de sincronismo entre BAQ x GFR nao esta integro. Verifique!"
					Endif
				Endif
				
			Endif
		Endif
		
		
	Endif
	
	
	
Endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA370   ºAutor  ³Microsiga           º Data ³  13/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de Atualização e Gravação nas Tabelas de Gestão     º±±
±±º          ³ Hospitalar para Sincronismo nas informações                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/



Function PLSA370GRV(nOpc)
Local lNovGFR	:=.T.
Local lAchou	:=.F.
Local lEspelhar := GetNewPar("MV_INTESPE",.F.)  // Parametro integração entre Tabelas GH e PLS   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Rotina de gravacao dos dados...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ No caso de exclusao verifico se houve movimentacao...                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nOpc == 3
	If lEspelhar
		If  ! Empty(M->BAQ_CODESP)
			DbSelectarea ("GFR")
			GFR->(DbSetOrder(1))
			lNovGFR := (GFR->(MsSeek(xFilial("GFR")+M->BAQ_CODESP)))
		Else
			lNovGFR := .T.
		Endif
	Endif
	
	If  ! LNovGFR
		DbSelectarea ("BBL")
		BBL->(DbSetOrder(2))
		If 	BBL->(MsSeek(xFilial("BBL")+"PLSA370   "+"BAQ"+"GFR"))
			RecLock("GFR", .T.)
			GFR->GFR_FILIAL := xFilial("GFR")
			PlsSinc("PLSA370   ","BAQ","GFR")
			GFR->GFR_LOGARQ := HS_LOGARQ()
			MsUnlock()
		Else
			If GetNewPar("MV_PLSMSGS","1") == "1"
				MsgAlert(OemtoAnsi(STR0007)) //"Arquivo de sincronismo entre BAQ x GFR nao esta integro. Verifique!"
			Endif
		Endif
	Endif
ElseIf nOpc == 4
	If lEspelhar
		DbSelectarea ("GFR")
		GFR->(DbSetOrder(1))
		If BAQ->(FieldPos("BAQ_REFIGH"))>0
			If !Empty(M->BAQ_REFIGH) .and. GFR->(MsSeek(xFilial("GFR")+M->BAQ_REFIGH)) 
				lAchou:= HS_VldExc(M->BAQ_REFIGH) // Chama a Validação do HSP verificando se Registro pode ser Sincronizado
			Else
				lAchou:= GFR->(MsSeek(xFilial("GFR")+M->BAQ_CODESP))
			Endif
			If lAchou
				DbSelectarea ("BBL")
				BBL->(DbSetOrder(2))
				If 	BBL->(MsSeek(xFilial("BBL")+"PLSA370   "+"BAQ"+"GFR"))
					RecLock("GFR", .F.)
					PlsSinc("PLSA370   ","BAQ","GFR")
					GFR->GFR_LOGARQ := HS_LOGARQ()
					MsUnlock()
				Else
					If GetNewPar("MV_PLSMSGS","1") == "1"
						MsgAlert(OemtoAnsi(STR0007)) //"Arquivo de sincronismo entre BAQ x GFR nao esta integro. Verifique!"
					Endif
					
				Endif
			Endif
		Endif
	Endif
	
	
EndIf

Return

Function PLSA370VLD()



lRet:=Vazio() .Or.(PlsSeek("BR8",,M->BBM_CODPAD+M->BBM_CODPSA,"BBM_DESPSA","BR8_DESCRI") .AND. PlsVldGd({"BBM_CODPAD","BBM_CODPSA","BBM_DATVAL"}) )




Return(lRet)  


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PlVigDifId³ Autor ³Everton M Fernandes    ³ Data ³23/10/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exibe tela para cadastrar periodicidade qndo difere dor idade³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PlVigDifId(cAlias,cChvBusca,cDifIda)

Local lRet := .T.
Local oDlgPerio
Local nOpc			:= 0
LOCAL nOpca	 := 0
Local aButtons	:= {}
Local aCabPerio	:= {}
Local aDadPerio	:= {}
Local aTrbPerio	:= {}

DEFAULT cDifIda := &("M->" + cAlias + "_DIFIDA")

If cDifIda == "1"
	If !Inclui .and. Altera
	   nOpc := K_Alterar
	Else
	   nOpc := K_Visualizar
	EndIf
	//cChvBusca := "xFilial('" + cAlias + "')+" + cChvBusca
	
	Store Header "B1Y" TO aCabPerio For .T.                    
	B1Y->(DbSetOrder(1))
	If ! B1Y->(DbSeek(xFilial("B1Y")+cAlias+&(cChvBusca)))
	   Store COLS Blank "B1Y" TO aDadPerio FROM aCabPerio
	Else
	   Store COLS "B1Y" TO aDadPerio FROM aCabPerio VETTRAB aTrbPerio While AllTrim(xFilial("B1Y")+cAlias+&(cChvBusca)) == ALLTRIM(B1Y->(B1Y_FILIAL+B1Y_ALIAS+B1Y_CHAVE))
	EndIf
	
	DEFINE MSDIALOG oDlgPerio TITLE OemtoAnsi(STR0011) FROM 009,000 TO 029,140 OF GetWndDefault()  //##"Periodicidade Diferente por idade"
	oDlgPerio:lEscClose := .T.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o Browse ...					                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oBrwPerio  := TPLSBrw():New(032,001,580,150,nil  ,oDlgPerio,nil, nil,nil,nil,nil,.T.,;
									nil,.T.,nil,aCabPerio ,aDadPerio ,.F. ,"B1Y" ,nOpc,;
									OemtoAnsi(STR0011) ,nil,nil,nil,aTrbPerio,;
									nil,nil,nil,nil,nil,nil,nil,&('{||M->B1Y_ALIAS := cAlias,M->B1Y_CHAVE := ' + cChvBusca + '}')/*bBeforeDialog*/)  //##"Periodicidade Diferente por idade"
	
	//oBrwPerio:bBeforeAdd := {||M->B1Y_ALIREC := cRecno}
	ACTIVATE DIALOG oDlgPerio CENTERED ON INIT ( EnchoiceBar(oDlgPerio, {|| nOpca:=1,IIf(VldRecB1Y(oBrwPerio),oDlgPerio:End(),)},{|| nOpca:= 0,oDlgPerio:End()},.f.,aButtons ))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Rotina de gravacao dos dados...                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpca == K_OK
		aCabPerio := aClone(oBrwPerio:aHeader)
	   aDadPerio := aClone(oBrwPerio:aCols)  	
	   
	   aChave := { {"B1Y_ALIAS",cAlias} ,;
	   				 {"B1Y_CHAVE",cChvBusca}}
	
	 	PLUPTCOLS("B1Y",aDadPerio,aCabPerio,aTrbPerio,nOpc,aChave)
	EndIf
Else
	MsgAlert(OemtoAnsi(STR0012) + cAlias + "_DIFIDA=1 - Sim.") //"Para informar uma periodicidade diferente por idade, deve-se configurar o campo "
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS370SEQ
Cria Sequencia

@author  PLS TEAM
@version P12
@since   19.12.2017
/*/
//-------------------------------------------------------------------
Function PLS370SEQ(oBrwPerio)

LOCAL cRet
If ValType(oBrwPerio) == "O"
   If oBrwPerio:aCols[Len(oBrwPerio:aCols),Len(oBrwPerio:aHeader)+1]
	   cRet := Soma1(oBrwPerio:FieldGet("B1Y_SEQUEN"))
   Else
	   cRet := PLSINCRE("B1Y_SEQUEN",oBrwPerio)
   EndIf
Else
   cRet := PLSINCRE("B1Y_SEQUEN")
Endif

Return(cRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} VldRecB1Y
Valida os registros antes de incluir na B1Y para não ocorrer erro de chave duplicada

@author  PLS TEAM
@version P11
@since   18/12/2017
/*/
//-------------------------------------------------------------------
Static Function VldRecB1Y(oBrwPerio)
Local lRet		:= .T.
Local i 		:= 0
Local j		:= 0
local nRept	:= 0
Local nPos1 := PLRETPOS("B1Y_ALIAS",oBrwPerio:aHeader)
Local nPos2 := PLRETPOS("B1Y_CHAVE",oBrwPerio:aHeader)
Local nPos3 := PLRETPOS("B1Y_IDADE",oBrwPerio:aHeader)
Local nPos4 := PLRETPOS("B1Y_TIDADE",oBrwPerio:aHeader)
Local nPos5 := PLRETPOS("B1Y_PERIOD",oBrwPerio:aHeader)
Local nPos6 := PLRETPOS("B1Y_UNPERI",oBrwPerio:aHeader)
local nDel  := len(oBrwPerio:aHeader) + 1

For i:=1 to Len(oBrwPerio:aCols)

	For j := 1 to Len(oBrwPerio:aCols)
		If	oBrwPerio:aCols[i,nPos1] == oBrwPerio:aCols[j,nPos1]  .and. Alltrim(oBrwPerio:aCols[i,nPos2]) == Alltrim(oBrwPerio:aCols[j,nPos2]) .and.  oBrwPerio:aCols[i,nPos3] == oBrwPerio:aCols[j,nPos3] .and.;
			oBrwPerio:aCols[i,nPos4] == oBrwPerio:aCols[j,nPos4]  .and. oBrwPerio:aCols[i,nPos5] == oBrwPerio:aCols[j,nPos5] .and.  oBrwPerio:aCols[i,nPos6] == oBrwPerio:aCols[j,nPos6] .and. !(oBrwPerio:aCols[j,nDel]) 
			nRept++
			iF nRept >1 
				MsgInfo(OemtoAnsi(STR0013)) //"Item ja incluso ! "
				lRet		:= .F.
				Exit
			Endif
		Endif
	Next j
	nRept:=0
	If !lRet
		Exit
	Endif
	

Next i
 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author Oscar Zanin
@since 08/04/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := PLSMnDefY(.T., "BAQ", , )

Return(aRotina)
