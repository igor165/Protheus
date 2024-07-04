#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSA105.CH"
#INCLUDE "PLSMGER.CH"
#include "PLSMCCR.CH"

#Define K_Proced 6  // Procedimentos
#Define UNICA    2	// ESPECIFICO PARA UMA UNICA OPERADORA 
#define K_Copiar 8

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA105 ³ Autor ³ Tulio Cesar            ³ Data ³ 31.03.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Tabela de Precos                                           ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLSA105

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := MenuDef()
Private cCadastro := Fundesc() //"Rede de Atendimento X Tabela de Precos"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectarea("BC5")
DbSetOrder(1)
MsSeek(xFilial("BC5"))
BC5->(mBrowse(06,01,22,75,"BC5"))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PL105MOV ³ Autor ³ Tulio Cesar           ³ Data ³ 31.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Movimentacao da Tabela de Precos.                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PL105MOV(cAlias,nReg,nOpc)
Local I__f := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lAtuVig 
Local nOpca	:= 0
Local oDlg
Local oEnchoice
Local aTELA[0][0]
Local aGETS[0]
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}
If nOpc == K_Incluir
	Copy "BC5" TO Memory Blank
Else
	Copy "BC5" TO MEMORY
Endif 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T. )
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] OF GetWndDefault() Pixel
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Enchoice...                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Zero()
	
	cAlias:="BC5"
	nReg:=BC5->(RecNo())
	oEnchoice := MSMGet():New(cAlias,nReg,nOpc,,,,,aPosObj[1],,,,,,oDlg,,,.F.)
    
ACTIVATE MSDIALOG oDlg ON INIT Eval({ || EnchoiceBar(oDlg,{|| nOpca := 1,Iif(Obrigatorio(oEnchoice:aGets,oEnchoice:aTela) .and. ValDtBC5(nOpc),oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) },{||oDlg:End()},.F.,{})  }) Center

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Rotina de gravacao dos dados...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  nOpca == K_OK

    lAtuVig := .F.
    If  nOpc == K_Alterar .and. !empty(M->BC5_DATFIM) .and. empty(BC5->BC5_DATFIM) 
		cMsg := STR0024 + chr(13) //"Deseja atualizar a DATA VIGENCIA FIM dos itens da"
		cMsg += STR0025 + chr(13) //"tabela de precos que possuem a data de vigencia fim"
		cMsg += STR0026 + chr(13) //"vazia (sem informacao) ?"
		cMsg += chr(13)
		cMsg += STR0027 + dtoc(M->BC5_DATFIM) + chr(13) //"     Data Vigencia Fim: "
		cMsg += chr(13)
		If  MsgYesNo(cMsg,STR0028) //"Data Vigencia Fim"
            lAtuVig := .T.
        Endif        
    Endif           
	
	// Controle de semaforo
	If  nOpc == K_Incluir
		_nH := PLSAbreSem("PLSA105.SMF")
	
	   
	Endif
	    
	PLUPTENC("BC5",nOpc)
	
	If  nOpc == K_Incluir	
		PLSFechaSem(_nH,"PLSA105.SMF")
	Endif
	
	If nOpc == K_Excluir 
		BC6->(dbSetOrder(1)) //BC6_FILIAL + BC6_CODINT + BC6_CODRDA + BC6_CODTAB + BC6_CODPAD + BC6_CODPRO + BC6_NIVEL
        While BC6->(MsSeek(xFilial("BC6")+BC5->BC5_CODINT+BC5->BC5_CODRDA+BC5->BC5_CODTAB)) 
	        PLUPTENC("BC6",nOpc)
	    EndDo    
    EndIf    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Somente quando for alteracao e datafim do bc5 for null que vai atualizar o bc6 	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If  lAtuVig     
    
        BC6->(dbSetOrder(1))//BC6_FILIAL + BC6_CODINT + BC6_CODRDA + BC6_CODTAB + BC6_CODPAD + BC6_CODPRO + BC6_NIVEL
        BC6->(MsSeek(xFilial("BC6")+BC5->BC5_CODINT+BC5->BC5_CODRDA+BC5->BC5_CODTAB)) 
        
        While ! BC6->(eof()) .and. BC6->BC6_CODINT+BC6->BC6_CODRDA+BC6->BC6_CODTAB == BC5->BC5_CODINT+BC5->BC5_CODRDA+BC5->BC5_CODTAB
        
           If  empty(BC6->BC6_VIGFIM) .and. BC5->BC5_DATFIM >= BC6->BC6_VIGINI
           
               If  BC6->(RecLock("BC6",.F.))
                   BC6->BC6_VIGFIM := BC5->BC5_DATFIM
                   BC6->(msUnLock())
               Endif
               
           Endif
           
           BC6->(dbSkip())
        End
        
    Endif
	
	If ExistBlock("PLS105OK")
	   ExecBlock("PLS105OK",.F.,.F.,{nOpc,lAtuVig})
	Endif   

Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(NIL)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ValDtBC5    ³ Autor ³ Tulio Cesar       ³ Data ³ 25.06.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida data na digitacao da tabela de preco				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValDtBC5(nOpc)

If nOpc <> K_Excluir 
	If M->BC5_DATINI > M->BC5_DATFIM .And. !Empty(M->BC5_DATFIM)
	   Help("",1,"PLSANAFAI2")   
	   Return(.F.)
	Endif                                
EndIf
	
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA105NUM ³ Autor ³ Tulio Cesar       ³ Data ³ 25.06.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna proximo numero                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA105NUM(cCodInt,cCodRDA)

Local cNum
Local nTam := Len(BC5->BC5_CODTAB)

BC5->(DbSetOrder(1))
BC5->(MsSeek(xFilial("BC5")+cCodInt+cCodRDA+Replicate("Z",nTam),.T.))

BC5->(DbSkip(-1))

If BC5->(BC5_FILIAL+BC5_CODINT+BC5_CODRDA) == xFilial("BC5")+cCodInt+cCodRDA
	cNum := Soma1(BC5->BC5_CODTAB)
Else
	cNum := StrZero(1,nTam)
Endif

Return(cNum)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PL105CLO ³ Autor ³ Eduardo Motta         ³ Data ³ 26.05.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faz a clonagem de uma tabela de precos.                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PL105CLO(cAlias,nReg,nOpc)
Local dDataAtu := BC5->BC5_DATFIM
Local oDlg
Local nOpca   := 0
Local cCodInt := BC5->BC5_CODINT
Local cCodRDA := BC5->BC5_CODRDA
Local cTabOri := BC5->BC5_CODTAB
Local cDesOri := BC5->BC5_DESCRI
Local cTabDes := PLSA105NUM(cCodInt,cCodRDA) //CriaVar("BC5_CODTAB")
Local cDesDes := BC5->BC5_DESCRI
Local dDatFim := STOD("")
Local oGetDat

Local nUsPco := 0
Local nTipoUsPco
Local lChkUsPco := .F.
Local oGetUsPco
Local oChkUsPco

Local nVrPco := 0
Local nTipoVrPco
Local lChkVrPco := .F.
Local oGetVrPco
Local oChkVrPco

Local nUsRco := 0
Local nTipoUsRco
Local lChkUsRco := .F.
Local oGetUsRco

Local nVrRco := 0
Local nTipoVrRco
Local lChkVrRco := .F.
Local oGetVrRco

Local nUsPpp := 0
Local nTipoUsPpp
Local lChkUsPpp := .F.
Local oGetUsPpp

Local nVrPpp := 0
Local nTipoVrPpp
Local lChkVrPpp := .F.
Local oGetVrPpp 

Local nUsRpp := 0
Local nTipoUsRpp
Local lChkUsRpp := .F. 
Local oGetUsRpp

Local nVrRpp := 0
Local nTipoVrRpp
Local lChkVrRpp := .F.   
Local oGetVrRpp

Local nBanDap := 0
Local nTipoBanDap
Local lChkBanDap := .F.  
Local oGetBanDap

Local nBanDar := 0
Local nTipoBanDar
Local lChkBanDar := .F.
Local oGetBanDar

Local lChkAplica := .F.
Local oGroup    

Local lRet := .F.

If ExistBlock("PLS105CL")
   ExecBlock("PLS105CL",.F.,.F.)
   Return
Endif   

If !Empty(dDataAtu)
	MsgStop(STR0036)//"Copia abortada! Data Vigencia Final já informada."
	Return
EndIf

DEFINE MSDIALOG oDlg TITLE cCadastro FROM 008.2,010.3 TO 040.4,135.3 OF GetWndDefault()
  	oGroup1 := tGroup():New(15,4,100,485,STR0031,oDlg,,,.T.)//"Dados do Cadastro."
  	oGroup2 := tGroup():New(103,4,230,485,STR0032,oDlg,,,.T.)//"Preencha caso Necessário Reajuste."
                                                                                                                                                      
	@ 25,10 Say TitX3("BC5_CODINT") PIXEL
	@ 40,10 Say TitX3("BC5_CODRDA") PIXEL
	@ 55,10 Say STR0013		      		PIXEL //"Tab.Origem"	
	@ 70,10 Say STR0022			       	PIXEL //"Vigencia Final"
	@ 85,10 Say STR0014			       	PIXEL //"Tab.Destino"
	@ 25,55 MsGet cCodInt Picture X3Picture("BC5_CODINT") When .F. Size 20,08 PIXEL
	@ 40,55 MsGet cCodRDA Picture X3Picture("BC5_CODRDA") When .F. Size 25,08 PIXEL
	@ 55,55 MsGet cTabOri Picture X3Picture("BC5_CODTAB") When .F. Size 20,08 PIXEL
	@ 55,80 MsGet cDesOri Picture X3Picture("BC5_DESCRI") When .F. Size 90,08 PIXEL

	oGetDat := TGet():New( 070,055, {|u| If( PCount() == 0, dDatFim , dDatFim  := u ) }, oDlg, 50,08 , X3Picture("BC5_DATFIM"),,,,,.F.,;
	,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"BC5_DATFIM","BC5_DATFIM",,,.T.,,,) 
    
	@ 85,55 MsGet cTabDes Picture X3Picture("BC5_CODTAB") Valid VldTab(cCodInt,cCodRDA,cTabDes) Size 20,08 PIXEL When .f.
	TGet():New( 085,080, {|u| If( PCount() == 0, cDesDes , cDesDes  := u ) }, oDlg, 90,08 , X3Picture("BC5_DESCRI"),,,,,.F.,,.T.,,.F.,;
    ,.F.,.F.,,.F.,.F.,,"BC5_DESCRI","BC5_DESCRI",,,.T.,,,)
	@ 115,010 Say TitX3("BC6_USPCO") 	PIXEL	

    @ 115,050 CHECKBOX oChkUsPco VAR lChkUspCo PROMPT OemtoAnsi("") PIXEL SIZE 08,08 On Change ( IIf( !lChkUspCo,;
    oGetUsPco:Disable(LmpUsPco(@nUsPco)),	oGetUsPco:Enable() ), oGetUsPco:Refresh() ) 
    oGetUsPco := TGet():New( 115,060, {|u| If( PCount() == 0, nUsPco , nUsPco  := u ) }, oDlg, 50,08 , X3Picture("BC6_USPCO"),,,,,.F.,,.T.,,.F.,;
    ,.F.,.F.,,.F.,.F.,,"BC6_USPCO","BC6_USPCO",,,.T.,,,) 
     Eval(oChkUsPco:bChange)
	@ 115,111 Say "%" 	PIXEL	
    @ 130,050 RADIO oTipoUsPco VAR nTipoUsPco 3D SIZE 40,08 PROMPT STR0033, STR0034	PIXEL When lChkUsPco //US CO PAGTO  //"Acrescimo","Desconto"
	@ 115,130 Say TitX3("BC6_VRPCO") 	PIXEL	
   
	@ 115,170 CHECKBOX oChkVrPco VAR lChkVrPco PROMPT OemtoAnsi("") PIXEL SIZE 08,08 On Change ( IIf( !lChkVrPco, oGetVrPco:Disable(LmpVrPco(@nVrPco)),;
	oGetVrPco:Enable() ), oGetVrPco:Refresh() )//On Change ( IIf( lChkVrPco, oGetVrPco:Disable(), oGetVrPco:Enable() ))
	oGetVrPco := TGet():New( 115,180, {|u| If( PCount() == 0, nVrPco , nVrPco  := u ) }, oDlg, 50,08 , X3Picture("BC6_VRPCO"),,,,,.F.,,.T.,,.F.,;
    /*{|u| If( lChkVrPco == .F., .F. , .T. ) }*/,.F.,.F.,,.F.,.F.,,"BC6_VRPCO","BC6_VRPCO",,,.T.,,,) 
    Eval(oChkVrPco:bChange)
	@ 115,231 Say "%" 	PIXEL	
    @ 130,170 RADIO oTipoVrPco VAR nTipoVrPco 3D SIZE 40,08 PROMPT	STR0033, STR0034 PIXEL When lChkVrPco //VL CO PAGTO             //"Acrescimo","Desconto"
    
	@ 115,250 Say TitX3("BC6_USRCO") 	PIXEL	
    @ 115,290 CHECKBOX oChkUsRco VAR lChkUsRco PROMPT OemtoAnsi("") PIXEL SIZE 08,08 On Change ( IIf( !lChkUsRco,;
    oGetUsRco:Disable(LmpUsRco(@nUsRco)),oGetUsRco:Enable() ), oGetUsRco:Refresh() )
	oGetUsRco := TGet():New( 115,300, {|u| If( PCount() == 0, nUsRco , nUsRco  := u ) }, oDlg, 50,08 , X3Picture("BC6_USRCO"),,,,,.F.,,.T.,,.F.,;
    ,.F.,.F.,,.F.,.F.,,"BC6_USRCO","BC6_USRCO",,,.T.,,,)
    Eval(oChkUsRco:bChange)
	@ 115,351 Say "%" 	PIXEL	
    @ 130,290 RADIO oTipoUsRco VAR nTipoUsRco 3D SIZE 40,08 PROMPT	STR0033, STR0034 PIXEL When lChkUsRco //US CO RECTO //"Acrescimo","Desconto"
    
	@ 115,370 Say TitX3("BC6_VRRCO") 	PIXEL	
    @ 115,410 CHECKBOX oChkVrRco VAR lChkVrRco PROMPT OemtoAnsi("") PIXEL SIZE 08,08 On Change ( IIf( !lChkVrRco,;
    oGetVrRco: Disable(LmpVrRco(@nVrRco)),oGetVrRco:Enable() ), oGetVrRco:Refresh() )
	oGetVrRco := TGet():New( 115,420, {|u| If( PCount() == 0, nVrRco , nVrRco  := u ) }, oDlg, 50,08 , X3Picture("BC6_VRRCO"),,,,,.F.,,.T.,,.F.,;
    ,.F.,.F.,,.F.,.F.,,"BC6_VRRCO","BC6_VRRCO",,,.T.,,,)
    Eval(oChkVrRco:bChange)
	@ 115,471 Say "%" 	PIXEL	
    @ 130,410 RADIO oTipoVrRco VAR nTipoVrRco 3D SIZE 40,08 PROMPT	STR0033, STR0034 PIXEL When lChkVrRco //VL CO RECTO //"Acrescimo","Desconto"

	@ 155,010 Say TitX3("BC6_USPPP") 	PIXEL	
    @ 155,050 CHECKBOX oChkUsPpp VAR lChkUsPpp PROMPT OemtoAnsi("") PIXEL SIZE 08,08 On Change ( IIf( !lChkUsPpp,;
    oGetUsPpp: Disable(LmpUsPpp(@nUsPpp)),oGetUsPpp:Enable() ), oGetUsPpp:Refresh() )
	oGetUsPpp := TGet():New( 155,060, {|u| If( PCount() == 0, nUsPpp , nUsPpp  := u ) }, oDlg, 50,08 , X3Picture("BC6_USPPP"),,,,,.F.,,.T.,,.F.,;
    ,.F.,.F.,,.F.,.F.,,"BC6_USPPP","BC6_USPPP",,,.T.,,,)	
    Eval(oChkUsPpp:bChange)
	@ 155,111 Say "%" 	PIXEL	
    @ 170,050 RADIO oTipoUsPpp VAR nTipoUsPpp 3D SIZE 40,08 PROMPT	STR0033, STR0034 PIXEL When lChkUsPpp//US PP PAGTO //"Acrescimo","Desconto"

	@ 155,130 Say TitX3("BC6_VRPPP") 	PIXEL	
    @ 155,170 CHECKBOX oChkVrPpp VAR lChkVrPpp PROMPT OemtoAnsi("") PIXEL SIZE 08,08 On Change ( IIf( !lChkVrPpp,;
    oGetVrPpp:Disable(LmpVrPpp(@nVrPpp)),oGetVrPpp:Enable() ), oGetVrPpp:Refresh() )
	oGetVrPpp := TGet():New( 155,180, {|u| If( PCount() == 0, nVrPpp , nVrPpp  := u ) }, oDlg, 50,08 , X3Picture("BC6_VRPPP"),,,,,.F.,,.T.,,.F.,;
    ,.F.,.F.,,.F.,.F.,,"BC6_VRPPP","BC6_VRPPP",,,.T.,,,)	
    Eval(oChkVrPpp:bChange)
	@ 155,231 Say "%" 	PIXEL	
    @ 170,170 RADIO oTipoVrPpp VAR nTipoVrpPp 3D SIZE 40,08 PROMPT	STR0033, STR0034 PIXEL When lChkVrPpp   //VL PP PAGTO           //"Acrescimo","Desconto"
    
	@ 155,250 Say TitX3("BC6_USRPP") 	PIXEL	
    @ 155,290 CHECKBOX oChkUsRpp VAR lChkUsRpp PROMPT OemtoAnsi("") PIXEL SIZE 08,08 On Change ( IIf( !lChkUsRpp,;
    oGetUsRpp:Disable(LmpUsRpp(@nUsRpp)),oGetUsRpp:Enable() ), oGetUsRpp:Refresh() )
	oGetUsRpp := TGet():New( 155,300, {|u| If( PCount() == 0, nUsRpp , nUsRpp  := u ) }, oDlg, 50,08 , X3Picture("BC6_USRPP"),,,,,.F.,,.T.,,.F.,;
    ,.F.,.F.,,.F.,.F.,,"BC6_USRPP","BC6_USRPP",,,.T.,,,)	
    Eval(oChkUsRpp:bChange)
	@ 155,351 Say "%" 	PIXEL	
    @ 170,290 RADIO oTipoUsRpp VAR nTipoUsRpp 3D SIZE 40,08 PROMPT	STR0033, STR0034 PIXEL When lChkUsRpp   //US PP RECTO           //"Acrescimo","Desconto"

	@ 155,370 Say TitX3("BC6_VRRPP") 	PIXEL	
    @ 155,410 CHECKBOX oChkVrRpp VAR lChkVrRpp PROMPT OemtoAnsi("") PIXEL SIZE 08,08 On Change ( IIf( !lChkVrRpp,;
    oGetVrRpp:Disable(LmpVrRpp(@nVrRpp)),oGetVrRpp:Enable() ), oGetVrRpp:Refresh() )
	oGetVrRpp := TGet():New( 155,420, {|u| If( PCount() == 0, nVrRpp , nVrRpp  := u ) }, oDlg, 50,08 , X3Picture("BC6_VRRPP"),,,,,.F.,,.T.,,.F.,;
    ,.F.,.F.,,.F.,.F.,,"BC6_VRRPP","BC6_VRRPP",,,.T.,,,)		
    Eval(oChkVrRpp:bChange)
	@ 155,471 Say "%" 	PIXEL	
    @ 170,410 RADIO oTipoVrRpp VAR nTipoVrRpp 3D SIZE 40,08 PROMPT	STR0033, STR0034 PIXEL When lChkVrRpp  //VL PP RECTO            //"Acrescimo","Desconto"

	@ 195,010 Say TitX3("BC6_BANDAP") 	PIXEL	
    @ 195,050 CHECKBOX oChkBanDap VAR lChkBanDap PROMPT OemtoAnsi("") PIXEL SIZE 08,08 On Change ( IIf( !lChkBanDap,;
    oGetBanDap:Disable(LmpBanDap(@nBanDap)),oGetBanDap:Enable() ), oGetBanDap:Refresh() )
	oGetBanDap := TGet():New( 195,060, {|u| If( PCount() == 0, nBanDap , nBanDap  := u ) }, oDlg, 50,08 , X3Picture("BC6_BANDAP"),,,,,.F.,,.T.,,.F.,;
    ,.F.,.F.,,.F.,.F.,,"BC6_BANDAP","BC6_BANDAP",,,.T.,,,)		
    Eval(oChkBanDap:bChange)
	@ 195,111 Say "%" 	PIXEL	
    @ 210,050 RADIO oBanDap VAR nTipoBanDap 3D SIZE 40,08 PROMPT	STR0033, STR0034 PIXEL When lChkBanDap //BANDA PAGTO             //"Acrescimo","Desconto"

	@ 195,130 Say TitX3("BC6_BANDAR") 	PIXEL	
    @ 195,170 CHECKBOX oChkBanDar VAR lChkBanDar PROMPT OemtoAnsi("") PIXEL SIZE 08,08 On Change ( IIf( !lChkBanDar,;
    oGetBanDar:Disable(LmpBanDar(@nBanDar)),oGetBanDar:Enable() ), oGetBanDar:Refresh() )
	oGetBanDar := TGet():New( 195,180, {|u| If( PCount() == 0, nBanDar , nBanDar  := u ) }, oDlg, 50,08 , X3Picture("BC6_BANDAR"),,,,,.F.,,.T.,,.F.,;
    ,.F.,.F.,,.F.,.F.,,"BC6_BANDAR","BC6_BANDAR",,,.T.,,,)		
    Eval(oChkBanDar:bChange)
    
	@ 195,231 Say "%" 	PIXEL	
    @ 210,170 RADIO oTipoBanDar VAR nTipoBanDar 3D SIZE 40,08 PROMPT	STR0033, STR0034 PIXEL When lChkBanDar //BANDA RECTO //"Acrescimo","Desconto"
         
    @ 195,250 CHECKBOX oChkAplica VAR lChkAplica PROMPT OemtoAnsi(STR0035) PIXEL SIZE 100,08 //"Aplicar Reajuste no Cabeçalho?"

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If(lRet := VldDt(dDatFim,@lRet),oDlg:End(),nOpca:=0)},{||nOpca:=0,oDlg:End()}) Center

If nOpca == 1 // faz a clonagem
	ClonaTab(cCodInt,cCodRDA,cTabOri,cTabDes,cDesDes,dDatFim,;
	lChkUsPco,nUsPco,nTipoUsPco,lChkVrPco,nVrPco,nTipoVrPco,;
	lChkUsRco,nUsRco,nTipoUsRco,lChkVrRco,nVrRco,nTipoVrRco,;
	lChkUsPpp,nUsPpp,nTipoUsPpp,lChkVrPpp,nVrPpp,nTipoVrPpp,;
	lChkUsRpp,nUsRpp,nTipoUsRpp,lChkVrRpp,nVrRpp,nTipoVrRpp,;
    lChkBanDap,nBanDap,nTipoBanDap,lChkBanDar,nBanDar,nTipoBanDar,lChkAplica)
	BC5->(MsSeek(xFilial("BC5")+cCodInt+cCodRDA+cTabDes))
//	PL105MOV(cAlias,nReg,4) // chama o programa de alteracao
Endif

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA105   ºAutor  ³Microsiga           º Data ³  06/19/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldTab(cCodInt,cCodRDA,cCodTab)
Local lRet := .T.

BC5->(DbSetOrder(1))
If BC5->(MsSeek(xFilial("BC5")+cCodInt+cCodRDA+cCodTab))
	MsgStop(STR0015)		//" Codigo ja cadastrado. "
	lRet := .F.
Endif       

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA105   ºAutor  ³Microsiga           º Data ³  06/19/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TitX3(cCampo)

Local cTit := ""
Local aArea := sGetArea()

sGetArea(aArea,"SX3")

SX3->(DbSetOrder(2))
SX3->(MsSeek(cCampo))
cTit := X3Titulo()

sRestArea(aArea)

Return(cTit)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ClonaTab  ºAutor  ³Microsiga           º Data ³  06/19/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Alexander  ³27/05/05³ 	   ³Correc. na gravacao da data fim obj origem³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ClonaTab(cCodInt,cCodRDA,cTabOri,cTabDes,cDesTab,dDatFim,;
	lChkUsPco,nUsPco,nTipoUsPco,lChkVrPco,nVrPco,nTipoVrPco,;
	lChkUsRco,nUsRco,nTipoUsRco,lChkVrRco,nVrRco,nTipoVrRco,;
	lChkUsPpp,nUsPpp,nTipoUsPpp,lChkVrPpp,nVrPpp,nTipoVrPpp,;
	lChkUsRpp,nUsRpp,nTipoUsRpp,lChkVrRpp,nVrRpp,nTipoVrRpp,;
    lChkBanDap,nBanDap,nTipoBanDap,lChkBanDar,nBanDar,nTipooBanDar,lChkAplica)

Local nColBC5   := Len(BC5->(DbStruct()))
Local aDaDbC5 	:= {}
Local nColBC6   := Len(BC6->(DbStruct()))
Local aDaDbC6 	:= {}
Local nI		:= 0 
Local nJ		:= 0 	
Local nCont 	:= 0

DbSelectArea("BC5")
SC5->(dbSetOrder(1))

If MsSeek(xFilial("BC5")+cCodInt+cCodRDA+cTabOri)

	While BC5->(!Eof()) .AND. BC5->(xFilial("BC5")+cCodInt+cCodRDA+cTabOri == BC5->(BC5_FILIAL+BC5_CODINT+BC5_CODRDA+BC5_CODTAB))
		nCont++
		aadd(aDaDbC5,Array(nColBC5))
		For nI := 1 to nColBC5
			aDaDbC5[nCont,nI] := FieldGet(nI)
		Next
		
		If !Empty(dDatFim)
			RecLock("BC5",.F.)
			If BC5->BC5_DATINI < dDatFim
				BC5->BC5_DATFIM := dDatFim
			Else
				BC5->BC5_DATFIM := BC5->BC5_DATINI
			Endif
			MsUnLock()
		EndIf
		
		DbSkip()
	End
	
	If !Empty(dDatFim)
		dDatIni := dDatFim + 1
	Else
		dDatIni := dDatFim
	EndIf
	
	For nI := 1 to Len(aDaDbC5)
		RecLock("BC5",.T.)
		For nJ := 1 To nColBC5
			BC5->(FieldPut(nJ,aDaDbC5[nI,nJ]))
		Next
		BC5->BC5_CODTAB := cTabDes
		BC5->BC5_DESCRI := cDesTab
		BC5->BC5_DATFIM := StoD('')
		BC5->BC5_DATINI := dDatIni
		
		If lChkAplica
			If (lChkUsPpp).AND.(nUsPpp>0).AND.(BC5->BC5_VPPP>0)
				If nTipoUsPpp==1
					BC5->BC5_VPPP := BC5->BC5_VPPP+(nUsPpp*BC5->BC5_VPPP/100)
				ElseIf nTipoUsPpp==2
					BC5->BC5_VPPP := BC5->BC5_VPPP-(nUsPpp*BC5->BC5_VPPP/100)
				Endif
			EndIf
			If (lChkUsRpp).AND.(nUsRpp>0).AND.(BC5->BC5_VRPP>0)
				If nTipoUsRpp==1
					BC5->BC5_VRPP := BC5->BC5_VRPP+(nUsRpp*BC5->BC5_VRPP/100)
				ElseIf nTipoUsRpp==2
					BC5->BC5_VRPP := BC5->BC5_VRPP-(nUsRpp*BC5->BC5_VRPP/100)
				Endif
			EndIf
			If (lChkUsPco).AND.(nUsPco>0).AND.(BC5->BC5_VPCO>0)
				If nTipoUsPco == 1
					BC5->BC5_VPCO := BC5->BC5_VPCO+(nUsPco*BC5->BC5_VPCO/100)
				ElseIf nTipoUsPco==2
					BC5->BC5_VPCO := BC5->BC5_VPCO-(nUsPco*BC5->BC5_VPCO/100)
				Endif
			EndIf
			If (lChkUsRco).AND.(nUsRco>0).AND.(BC5->BC5_VRCO>0)
				If nTipoUsRco==1
					BC5->BC5_VRCO := BC5->BC5_VRCO+(nUsRco*BC5->BC5_VRCO/100)
				ElseIf nTipoUsRco==2
					BC5->BC5_VRCO := BC5->BC5_VRCO-(nUsRco*BC5->BC5_VRCO/100)
				Endif
			EndIf
			If (lChkBanDap).AND.(nBanDap>0).AND.(BC5->BC5_BANDAP>0)
				If nTipoBanDap==1
					BC5->BC5_BANDAP := BC5->BC5_BANDAP+(nBanDap*BC5->BC5_BANDAP/100)
				ElseIf nTipoBanDap==2
					BC5->BC5_BANDAP := BC5->BC5_BANDAP-(nBanDap*BC5->BC5_BANDAP/100)
				Endif
			EndIf
			If (lChkBanDar).AND.(nBanDar>0).AND.(BC5->BC5_BANDAR>0)
				If nTipoBanDar==1
					BC5->BC5_BANDAR := BC5->BC5_BANDAR+(nBanDar*BC5->BC5_BANDAR/100)
				ElseIf nTipoBanDar==2
					BC5->BC5_BANDAR := BC5->BC5_BANDAR-(nBanDar*BC5->BC5_BANDAR/100)
				Endif
			EndIf
		EndIf
		
		DbUnlock()
	Next
EndIf

//DbCloseArea()

nCont := 0
DbSelectArea("BC6")               
//DbClearFilter()
SC6->(dbSetOrder(1))

If MsSeek(xFilial("BC6")+cCodInt+cCodRDA+cTabOri)
	While BC6->(!Eof()) .AND. BC6->(xFilial("BC6")+cCodInt+cCodRDA+cTabOri == BC6->(BC6_FILIAL+BC6_CODINT+BC6_CODRDA+BC6_CODTAB))
		if empty(BC6->BC6_VIGFIM)
			nCont++
			aadd(aDaDbC6,Array(nColBC6))
			For nI := 1 to nColBC6
				aDaDbC6[nCont,nI] := FieldGet(nI)
			Next
			
			If !Empty(dDatFim)
				
				RecLock("BC6",.F.)
				If BC6->BC6_VIGINI < dDatFim
					BC6->BC6_VIGFIM := dDatFim
				Else
					BC6->BC6_VIGFIM := BC6->BC6_VIGINI
				EndIf
				MsUnLock()
			EndIf
		endIf
		DbSkip()
	End
	
	For nI := 1 to Len(aDaDbC6)
		
		RecLock("BC6",.T.)
		For nJ := 1 To nColBC6
			BC6->(FieldPut(nJ,aDaDbC6[nI,nJ]))
		Next
		BC6->BC6_CODTAB := cTabDes
		BC6->BC6_VIGINI := dDatIni
		BC6->BC6_VIGFIM := StoD('')
		
		If (lChkUsPco).AND.(nUsPco>0).AND.(BC6->BC6_USPCO>0)
			If nTipoUsPco==1
				BC6->BC6_USPCO := BC6->BC6_USPCO+(nUsPco*BC6->BC6_USPCO/100)
			ElseIf nTipoUsPco==2
				BC6->BC6_USPCO := BC6->BC6_USPCO-(nUsPco*BC6->BC6_USPCO/100)
			EndIf
		EndIf
		If (lChkVrPco).AND.(nVrPco>0).AND.(BC6->BC6_VRPCO>0)
			If nTipoVrPco==1
				BC6->BC6_VRPCO := BC6->BC6_VRPCO+(nVrPco*BC6->BC6_VRPCO/100)
			ElseIf nTipoVrPco==2
				BC6->BC6_VRPCO := BC6->BC6_VRPCO-(nVrPco*BC6->BC6_VRPCO/100)
			EndIf
		EndIf
		If (lChkUsRco).AND.(nUsRco>0).AND.(BC6->BC6_USRCO>0)
			If nTipoUsRco==1
				BC6->BC6_USRCO := BC6->BC6_USRCO+(nUsRco*BC6->BC6_USRCO/100)
			ElseIf nTipoUsRco==2
				BC6->BC6_USRCO := BC6->BC6_USRCO-(nUsRco*BC6->BC6_USRCO/100)
			EndIf
		EndIf
		If (lChkVrRco).AND.(nVrRco>0).AND.(BC6->BC6_VRRCO>0)
			If nTipoVrRco==1
				BC6->BC6_VRRCO := BC6->BC6_VRRCO+(nVrRco*BC6->BC6_VRRCO/100)
			ElseIf nTipoVrRco==2
				BC6->BC6_VRRCO := BC6->BC6_VRRCO-(nVrRco*BC6->BC6_VRRCO/100)
			EndIf
		EndIf
		If (lChkUsPpp).AND.(nUsPpp>0).AND.(BC6->BC6_USPPP>0)
			If nTipoUsPpp==1
				BC6->BC6_USPPP := BC6->BC6_USPPP+(nUsPpp*BC6->BC6_USPPP/100)
			ElseIf nTipoUsPpp==2
				BC6->BC6_USPPP := BC6->BC6_USPPP-(nUsPpp*BC6->BC6_USPPP/100)
			EndIf
		EndIf
		If (lChkVrPpp).AND.(nVrPpp>0).AND.(BC6->BC6_VRPPP>0)
			If nTipoVrPpp==1
				BC6->BC6_VRPPP := BC6->BC6_VRPPP+(nVrPpp*BC6->BC6_VRPPP/100)
			ElseIf nTipoVrPpp==2
				BC6->BC6_VRPPP := BC6->BC6_VRPPP-(nVrPpp*BC6->BC6_VRPPP/100)
			EndIf
		EndIf
		If (lChkUsRpp).AND.(nUsRpp>0).AND.(BC6->BC6_USRPP>0)
			If nTipoUsRpp==1
				BC6->BC6_USRPP := BC6->BC6_USRPP+(nUsRpp*BC6->BC6_USRPP/100)
			ElseIf nTipoUsRpp==2
				BC6->BC6_USRPP := BC6->BC6_USRPP-(nUsRpp*BC6->BC6_USRPP/100)
			EndIf
		EndIf
		If (lChkVrRpp).AND.(nVrRpp>0).AND.(BC6->BC6_VRRPP>0)
			If nTipoVrRpp==1
				BC6->BC6_VRRPP := BC6->BC6_VRRPP+(nVrRpp*BC6->BC6_VRRPP/100)
			ElseIf nTipoVrRpp==2
				BC6->BC6_VRRPP := BC6->BC6_VRRPP-(nVrRpp*BC6->BC6_VRRPP/100)
			EndIf
		EndIf
		If (lChkBanDap).AND.(nBanDap>0).AND.(BC6->BC6_BANDAP>0)
			If nTipoBanDap==1
				BC6->BC6_BANDAP := BC6->BC6_BANDAP+(nBanDap*BC6->BC6_BANDAP/100)
			ElseIf nTipoBanDap==2
				BC6->BC6_BANDAP := BC6->BC6_BANDAP-(nBanDap*BC6->BC6_BANDAP/100)
			EndIf
		EndIf
		If (lChkBanDar).AND.(nBanDar>0).AND.(BC6->BC6_BANDAR>0)
			If nTipoBanDar==1
				BC6->BC6_BANDAR := BC6->BC6_BANDAR+(nBanDar*BC6->BC6_BANDAR/100)
			ElseIf nTipoBanDar==2
				BC6->BC6_BANDAR := BC6->BC6_BANDAR-(nBanDar*BC6->BC6_BANDAR/100)
			EndIf
		EndIf
		
		DbUnlock()
		
	Next
EndIf

//DbCloseArea()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PL105Oper ºAutor  ³Marcelo Kotaki      º Data ³  09/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela para selecao dos operadores no cadastro do BC6        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PL105Oper(aListaOper)

Local oDlgOper												// Tela
Local oListBox												// Listbox
Local lOk 		:= .F.										// Confirma / Cancela
Local oOk		:= LoaDbitmap( GetResources(), "LBOK" )     // OK 
Local oNo		:= LoaDbitmap( GetResources(), "LBNO" )		// CANCELA	
Local oOperadora
Local cOperadora:= SPACE(200)						        // Codigo da Operadora
Local lRet 		:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a selecao do "Tipo de Lancamento" for 1- ESPECIFICO PARA UMA UNICA OPERADORA  disponibiliza o recurso do botao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If VAL(M->BC6_TPLAN) <> UNICA 		
   //"Esse recurso é disponivél somente para lançamentos específicos de uma única operadora","Atenção",	
   MsgStop(STR0016,STR0017) 
   Return(lRet)
Endif

DEFINE MSDIALOG oDlgOper TITLE STR0018 FROM 0,0 TO 320,700 PIXEL //"Seleção das Operadoras" 
	
	EnchoiceBar(oDlgOper, {|| (lOk:=.T.,oDlgOper:End())}, {|| (lOk:=.F.,oDlgOper:End())} )
		
	@ 30,03 LISTBOX oListBox FIELDS Header;
					"",;
					STR0019,;				//"Código"
					STR0020;				//"Nome da Operadora"
				SIZE 345,110 Of oDlgOper PIXEL; 
				ON DBLCLICK (aListaOper[oListBox:nAt,1]:= !aListaOper[oListBox:nAt,1], oListBox:Refresh())
		
	oListBox:SetArray(aListaOper)
	oListBox:bLine := { || { IIF(aListaOper[oListBox:nAt,1],oOk,oNo), aListaOper[oListBox:nAt,2], aListaOper[oListBox:nAt,3] } }

	@ 143,10 SAY STR0021 OF oDlgOper PIXEL 	//"Operadoras"
	@ 143,50 MSGET oOperadora VAR cOperadora Picture "@S100" SIZE 200,8 OF oDlgOper PIXEL 

	DEFINE SBUTTON FROM 143,300 TYPE 1 ACTION PLS105Marca(@aListaOper,@cOperadora,oListBox) ENABLE OF oDlgOper 
		
ACTIVATE MSDIALOG oDlgOper CENTERED 

lRet := lOk 

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLS105Marca ºAutor  ³Marcelo Kotaki    º Data ³  20/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Marca automaticamente o Listbox das operadoras             º±±
±±º          ³ 1234,1234,1234,1234,...,1234 = 200 Caracteres/50 Operadorasº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PLS105Marca(aListaOper,cOperadora,oListBox)

Local oOk		:= LoaDbitmap( GetResources(), "LBOK" )     // OK 
Local oNo		:= LoaDbitmap( GetResources(), "LBNO" )		// CANCELA	
Local nCont 	:= 0			// Contador
Local cCodigo 	:= SPACE(4)		// Codigo para busca na Lista de Operadoras
Local nPos 		:= 0 			// Posicao da Operadora no Array de Operadoras
Local nPula 	:= 0 			// Procura por , ou ;

// Se o usuario preencheu o get das operadoras
If !Empty(ALLTRIM(cOperadora))

	// Limpa os espacos vazios
	cOperadora := ALLTRIM(cOperadora)
	
	If ! (Substr(cOperadora,Len(cOperadora),1) $ ",;" )
		cOperadora := cOperadora+","
	Endif	
		
	// Comeca a percorrer as operadoras digitadas
	For nCont := 1 TO LEN(cOperadora)
        
		nPula := 0 
		nPula := AT(",",cOperadora)-1
		If nPula <= 0
			nPula := AT(";",cOperadora)-1
		Endif	

		If nPula > 0 			
			cCodigo := SUBSTR(cOperadora,1,nPula)
		
			//  Procuro por esse codigo de operadora na lista de Operadoras
			nPos := Ascan(aListaOper ,{|x| x[2] == cCodigo})
			If nPos > 0
				aListaOper[nPos][1] := .T.
			Endif
		
			cOperadora := RIGHT(cOperadora, Len(cOperadora) - Len(cCodigo) - 1)
		Endif
		
		If Len(cOperadora) <= 0 
			Exit
		Endif
			
	Next nCont 
	
	oListBox:SetArray(aListaOper)	
	oListBox:bLine:={||{IIF(aListaOper[oListBox:nAt,1],oOk,oNo),;
			 			aListaOper[oListBox:nAt,2],;
						aListaOper[oListBox:nAt,3]}}
	oListBox:Refresh()   
	
	cOperadora := SPACE(200)
Endif

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PL105AddOperºAutor  ³Marcelo Kotaki    º Data ³  06/20/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inclui as linhas necessarias no ACOLS de acordo com a      º±±
±±º          ³ selecao do usuario                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PL105AddOper(aListaOper,nOpc)

	Local nI	:= 0
	Local lRet  := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o item foi especifico para uma unica operadora e ela nao foi informada - valida pela ENCHOICE digitada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If VAL(M->BC6_TPLAN) == UNICA .AND. Empty(M->BC6_CODOPE)
		For nI := 1 To Len(aListaOper)
			If aListaOper[nI,1]  
			    M->BC6_CODOPE := aListaOper[nI,2]
				PLUPTENC("BC6",nOpc)
				lRet := .T.
			EndIf	
		Next
	Endif
	
Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PL105PRO ³ Autor ³ Alexander		        ³ Data ³ 22.05.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Seleciona procedimentos para um Rda x Tabela de Preco	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PL105PRO(cAlias,nReg,nOpc)

Local cOldCad := cCadastro

Private aRotina   := { { STRPL01 ,'AxPesqui'  , 0 , K_Pesquisar  },; //'Pesquisar'
                       { STRPL02 ,'PLSA105PRO', 0 , K_Visualizar },; //'Visualizar'
                       { STRPL03 ,'PLSA105PRO', 0 , K_Incluir 	},; //'Incluir'
                       { STRPL04 ,'PLSA105PRO', 0 , K_Alterar    },; //'Alterar'
                       { STRPL05 ,'PLSA105PRO', 0 , K_Excluir    }}  //'Excluir'
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao Filtro														 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cFil := "BC6_FILIAL = '" + xFilial("BC6")  + "' AND BC6_CODINT = '" + BC5->BC5_CODINT + "' AND "
        cFil += " BC6_CODRDA = '" + BC5->BC5_CODRDA + "' AND BC6_CODTAB = '" + BC5->BC5_CODTAB + "' AND D_E_L_E_T_ = ' '"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define titulo...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCadastro   := STR0029+AllTrim(BC5->(BC5_CODINT+"."+BC5_CODRDA)+" - "+BC5->BC5_DESCRI) //"Procedimentos do Rda X Tabela de Preços  -  "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa filtro e monta browse...                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("BC6")
BC6->(DbSetOrder(1))	
BC6->(MsSeek(xFilial("BC6")))
BC6->(dbSetorder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Browse																	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BC6->(mBrowse(ndLinIni,ndColIni,ndLinFin,ndColFin,"BC6",,,,,,,,,,,,,,cFil))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna o titulo da tela												 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCadastro := cOldCad

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA105PRO³ Autor ³ Alexander		        ³ Data ³ 22.05.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela de movimentcao do procedimento					 	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA105PRO(cAlias,nReg,nOpc)
Local I__f := 0

    Local aButtons   := {}
Local aListaOper := {} // Lista com as operadoras selecionadas    
Local nOpca		 := 1
Local cOldCad 	 := cCadastro

Local oDlg
Local oEnchoice
Local aTELA[0][0]
Local aGETS[0]              
Local nOpcX := nOpc
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {} 
cCadastro   := STR0030 //"Item da Tabela de Preco"

DbSelectarea("BA0")
DbSetorder(1)
MsSeek(xFilial("BA0")) 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Conteudo adicionado a matriz Selecao - Codigo Ident. Empresa + Operadora 		 ³
//³Nome da Operadora - Codigo Proc RDA												 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While (!Eof()) .AND. (xFilial("BA0") == BA0->BA0_FILIAL)
	  AAdd(aListaOper,{.F.,(BA0_CODIDE+BA0_CODINT),BA0_NOMINT,SPACE(16)})
	  BA0->(DbSkip())
EndDo                                         
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao da enchoicebar para selecao de operadora									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aButtons := {{"GROUP",{|| PL105Oper(@aListaOper)},STR0012,STR0021}}	//"Seleção de Operadoras"

If nOpc == K_Incluir
   Copy "BC6" TO Memory Blank
Else
   Copy "BC6" TO Memory
Endif  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := { aSize[1],aSize[2],aSize[3],aSize[6], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T. )
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] OF GetWndDefault() Pixel

	Zero()
	
	cAlias:="BC6"
	nReg:=BC6->(RecNo())
	oEnchoice := MSMGet():New(cAlias,nReg,nOpc,,,,,aPosObj[1],,,,,,oDlg,,,.F.)
    
ACTIVATE MSDIALOG oDlg ON INIT Eval( { || EnchoiceBar(oDlg ,{|| Iif( Obrigatorio(oEnchoice:aGets,oEnchoice:aTela) .and. P105ValReg(aListaOper,nOpc), oDlg:End(), .F.) } ,{||oDlg:End()},, Iif( K_Incluir==nOpcX ,aButtons ,{} ) ) })
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno do titulo da tela														 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCadastro := cOldCad

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³P105ValReg³ Autor ³ Alexander		        ³ Data ³ 22.05.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao da vigencia e inclusao							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function P105ValReg(aListaOper,nOpc)

Local cSql
Local lCheck := .F.

If nOpc == K_Incluir .or. nOpc == K_Alterar

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se data inicio for maior que final nao permite									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If M->BC6_VIGINI > M->BC6_VIGFIM .And. ! Empty(M->BC6_VIGFIM)
	   Help("",1,"PLSANAFAI2")   
	   Return(.F.)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao permite Cod. Acomodacao em Branco se o Tipo for Especifico.                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If M->BC6_TIPLAN == "2" .And. Empty(M->BC6_CODACO)
		Help( ,, "Atenção!" ,, "Caso a Acomodação seja Específica, informar o Código da Acomodação [BC6_CODACO]" , 1 , 0 )
		Return(.F.)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao permite Cod. Operadora em Branco se o Tipo for Especifico.                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If M->BC6_TPLAN == "2" .And. Empty(M->BC6_CODOPE)
		Help( ,, "Atenção!" ,, "Caso a Operadora seja Específica, informar o Código da Operadora [BC6_CODOPE]" , 1 , 0 )
		Return(.F.)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao permite Cod. Produto em Branco se o Tipo for Especifico.                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If M->BC6_TPLANP == "2" .And. Empty(M->BC6_CODPLA)
		Help( ,, "Atenção!" ,, "Caso o Produto seja Específico, informar o Código do Produto [BC6_CODPLA]" , 1 , 0 )
		Return(.F.)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Selecao dos procedimentos da tabela												 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSql := " SELECT BC6_VIGINI,BC6_VIGFIM,R_E_C_N_O_ REGISTRO FROM "+RetSQLName("BC6")+" " 
	cSql += " WHERE BC6_FILIAL = '"+xFilial("BC6")+"'"//Filial
	cSql += "   AND BC6_CODINT = '"+Alltrim(BC5->BC5_CODINT)+"'"//Operadora
	cSql += "   AND BC6_CODRDA = '"+Alltrim(BC5->BC5_CODRDA)+"'"//Rda
	cSql += "   AND BC6_CODTAB = '"+Alltrim(BC5->BC5_CODTAB)+"'"//Tabela
	cSql += "   AND BC6_CDPRRA = '"+Alltrim(M->BC6_CDPRRA)+"'" //Codigo Procedimento RDA
	cSql += "   AND BC6_CODACO = '"+Alltrim(M->BC6_CODACO)+"'" //Acomodacao
	cSql += "   AND BC6_CODPLA = '"+Alltrim(M->BC6_CODPLA)+"'" //Codigo Tabela Padrao
	cSql += "   AND BC6_CODPRO = '"+Alltrim(M->BC6_CODPRO)+"'" //Codigo Tabela Padrao
	cSql += "   AND BC6_CODOPE = '"+Alltrim(M->BC6_CODOPE)+"'" //Codigo Operadora
	cSql += "   AND D_E_L_E_T_ <> '*' "
	cSql += "   ORDER BY R_E_C_N_O_ "
	
	PlsQuery(cSql,'Trb105')
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Checa a vigencia														 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !Trb105->(Eof())  
	   If M->BC6_VIGINI > Trb105->BC6_VIGINI .and. M->BC6_VIGINI <= Trb105->BC6_VIGFIM 
		  lCheck := .T.
		  Exit
	   EndIf	  
	   If M->BC6_VIGINI <= Trb105->BC6_VIGINI .and. M->BC6_VIGFIM >= Trb105->BC6_VIGINI
		  lCheck := .T.                   
		  Exit
	   EndIf	                                                   
	   If Empty(Trb105->BC6_VIGFIM) .and. M->BC6_VIGFIM >= Trb105->BC6_VIGINI
		  lCheck := .T.
		  Exit
	   EndIf
	   Trb105->(DbSkip()) 
	EndDo   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se for o mesmo registro deixa passar											 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Trb105->REGISTRO == BC6->(Recno()) .and. nOpc == K_Alterar
	   lCheck := .F.
	EndIf
	Trb105->(DbCloseArea())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao deixa passar se data for invalida											 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCheck
		Help("",1,"PLSANAFAI5")
	   	Return(.F.)
	EndIf   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravacao ou Alteracao do procedimento											 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	M->BC6_FILIAL := xFilial("BC5")
	M->BC6_CODINT := BC5->BC5_CODINT
	M->BC6_CODRDA := BC5->BC5_CODRDA
	M->BC6_CODTAB := BC5->BC5_CODTAB
	
	If !PL105AddOper( aListaOper,nOpc )
		PLUPTENC("BC6",nOpc)
	EndIf
	
	/*If PLSALIASEX("B64")
		aChave := {}
	 	aadd(aChave,{"B64_CODINT"	,BC5->BC5_CODINT})
	    aadd(aChave,{"B64_CODRDA"	,BC5->BC5_CODRDA})
	    aadd(aChave,{"B64_CODTAB" 	,BC5->BC5_CODTAB})
	    aadd(aChave,{"B64_CODTAB" 	,BC5->BC5_CODTAB})
	    aadd(aChave,{"B64_CODPRO" 	,M->BC6_CODPRO})
	    oBrwB64:Grava(aChave) 
	EndIf
	*/	
Else 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclusao																	     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PLUPTENC("BC6",nOpc)
EndIf
        
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Darcio R. Sporl       ³ Data ³26/12/2006³±±
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
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados         ³±±
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
LOCAL aPE := {}
LOCAL nPE := 0

LOCAL aRotina := {	{ STR0004, 'AxPesqui' , 0 , K_Pesquisar  , 0, .F.},; //'Pesquisar'		1
											{ STR0005, 'PL105MOV' , 0 , K_Visualizar , 0, Nil},; //'Visualizar'    2
											{ STR0006, 'PL105MOV' , 0 , K_Incluir    , 0, Nil},; //'Incluir'       3
											{ STR0007, 'PL105MOV' , 0 , K_Alterar    , 0, Nil},; //'Alterar'       4
											{ STR0008, 'PL105MOV' , 0 , K_Excluir    , 0, Nil},; //'Excluir'       5
           									{ STR0023, 'PL105PRO' , 0 , K_Proced     , 0, Nil},; //'Procedimento'  5 //"Procedimentos"
											{ STR0010, 'PL105CLO' , 0 , K_Copiar     , 0, Nil} } //'Clonar'        6

	If ExistBlock("PLS105MN")
		aPE := ExecBlock("PLS105MN")
		
		If Len(aPE) > 0
			For nPE := 1 To Len(aPE)
				Aadd(aRotina, aPE[nPE])
			Next
		Endif
	Endif


Return(aRotina)       
    
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ LmpUsPco ³ Autor ³ Microsiga		        ³ Data ³ 07/16/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Limpa a variavel nUsPco   							      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Static Function LmpUsPco(nUsPco)

nUsPco := 0  

Return nUsPco       
 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ LmpVrPco ³ Autor ³ Microsiga		        ³ Data ³ 07/16/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Limpa a variavel nVrPco   							      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Static Function LmpVrPco(nVrPco)

nVrPco := 0

Return nVrPco
    
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ LmpUsRco ³ Autor ³ Microsiga		        ³ Data ³ 07/16/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Limpa a variavel nUsRco   						    	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Static Function LmpUsRco(nUsRco)

nUsRco := 0

Return nUsRco
   
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ LmpVrRco ³ Autor ³ Microsiga		        ³ Data ³ 07/16/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Limpa a variavel nVrRco   						    	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Static Function LmpVrRco(nVrRco)

nVrRco := 0

Return nVrRco
     
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ LmpUsPpp ³ Autor ³ Microsiga		        ³ Data ³ 07/16/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Limpa a variavel nUsPpp   						     	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Static Function LmpUsPpp(nUsPpp)

nUsPpp := 0

Return nUsPpp
    
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ LmpVrPpp ³ Autor ³ Microsiga		        ³ Data ³ 07/16/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Limpa a variavel nVrPpp   							      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Static Function LmpVrPpp(nVrPpp)

nVrPpp := 0

Return nVrPpp
     
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ LmpUsRpp ³ Autor ³ Microsiga		        ³ Data ³ 07/16/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Limpa a variavel nUsRpp   							      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Static Function LmpUsRpp(nUsRpp)

nUsRpp := 0

Return nUsRpp
     
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ LmpVrRpp ³ Autor ³ Microsiga		        ³ Data ³ 07/16/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Limpa a variavel nVrRpp   							      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Static Function LmpVrRpp(nVrRpp)

nVrRpp := 0

Return nVrRpp
   
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LmpBanDap ³ Autor ³ Microsiga		        ³ Data ³ 07/16/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Limpa a variavel nBanDap   							      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Static Function LmpBanDap(nBanDap)

nBanDap := 0

Return nBanDap
  
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LmpBanDar ³ Autor ³ Microsiga		        ³ Data ³ 07/16/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Limpa a variavel nBanDar   							      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Static Function LmpBanDar(nBanDar)

nBanDar := 0

Return nBanDar         

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VldDt    ³ Autor ³ Microsiga		        ³ Data ³ 07/16/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Limpa a variavel nUsPco   							      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Static Function VldDt(dDatFim,lRet) 
Default lRet := .T.

If Empty(dDatFim)
    MsgAlert(STR0037)//"Informe a Data de Vigencia Final."
    lRet := .F.
Else
	lRet := .T.    
EndIf

Return lRet       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA105NUM ³ Autor ³ Tulio Cesar       ³ Data ³ 25.06.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna proximo numero                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TabNumRDA(cCodInt)

Local cNum
Local nTam := Len(BC5->BC5_CODTAB)

BC5->(DbSetOrder(3))
BC5->(MsSeek(xFilial("BC5")+cCodInt+Replicate("Z",nTam),.T.))

BC5->(DbSkip(-1))

If BC5->(BC5_FILIAL+BC5_CODINT) == xFilial("BC5")+cCodInt
	cNum := Soma1(BC5->BC5_CODTAB)
Else
	cNum := StrZero(1,nTam)
Endif
 

Return(cNum)
