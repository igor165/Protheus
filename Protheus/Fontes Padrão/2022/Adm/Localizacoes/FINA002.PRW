#INCLUDE "FINA002.CH"
#INCLUDE "PROTHEUS.CH"
                                     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ     
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA002   ºAutor  ³Jair Ribeiro        º Data ³  03/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Manutencao cadastro de analistas financeiros				  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIN                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FINA002(lAutomato)    

Local aUser		:= {}	
Local aCodUser	:= {}
Local aAllUser	:= {}
Local cCodUser	:= ""
Local cUser		:= ""
Local nUser		:= 0
Local aArea		:= GetArea()

Local oSay		:= Nil 
Local oDlg		:= Nil
Local oList		:= Nil
Local oGroup	:= Nil
Local oButton1	:= Nil
Local oButton2	:= Nil
Local oButton3	:= Nil
Local oButton4	:= Nil
Local oButton5	:= Nil
Local oButton6	:= Nil

Private cCadastro  		:= STR0001	//"Cadastro de Analistas Financeiros"
Private bListRefresh	:= { || F002LRfr( @oList, @aUser, aAllUser, @aCodUser ) }
Private aRotina    		:= MenuDef()

Default lAutomato 	:= .F. //Se inicializa en .T. cuando viene por automatización, en todos los demás casos es .F.

DbSelectArea("FRO")
DbSelectArea("FRQ")

FRO->(DbSetOrder(1))    


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Monta os Arrays estaticos contendo todos os usuarios do sistema.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Processa( { || F002AllUsr( @aAllUser ) }, , STR0004 )	//"Carregando Usuários..." 

Eval(bListRefresh)
IF !lAutomato
oDlg := MSDialog():New(0,0,217,417,cCadastro,,,,,,,,oMainWnd,.T.)	
	oSay 	 := TSay():New(01,05,{|| STR0005 },oDlg,,,,,,.T.)	//"Usuário"
	oList 	 := TListBox():New( 10,  05, { |u| If( PCount() > 0, cUser := u, cUser ) }, aUser, 150, 85, { || nUser := oList:nAT }, oDlg, , , , .T., , { || If( !Empty(cUser), F002Processa( aCodUser[nUser], 2 ), Nil ) } )
	oButton1 := TButton():New ( 10, 160, STR0006,       oDlg, { || ( UserPesqui( , @oList:nAT, @aUser, @oList, STR0005, oDlg ) ), ( Eval(bListRefresh) ) }			, 44, 11, , , , .T. )	//"Localizar"
	oButton2 := TButton():New ( 25, 160, "&" + STR0007, oDlg, { || If( F002GetUser(aAllUser,@cCodUser,aCodUser),F002Processa(cCodUser,3), Nil), (Eval(bListRefresh))}	, 44, 11, , , , .T. )	//"Incluir"
	oButton3 := TButton():New ( 40, 160, "&" + STR0008, oDlg, { || If( nUser > 0, F002Processa( aCodUser[nUser], 2), Nil), ( Eval(bListRefresh) ) }				, 44, 11, , , , .T. )	//"Visualizar"
	oButton4 := TButton():New ( 55, 160, "&" + STR0009, oDlg, { || If( nUser > 0, F002Processa( aCodUser[nUser], 4), Nil), ( Eval(bListRefresh) ) }				, 44, 11, , , , .T. )	//"Alterar"
	oButton5 := TButton():New ( 70, 160, "&" + STR0010, oDlg, { || If( nUser > 0, F002Processa( aCodUser[nUser], 5), Nil), ( Eval(bListRefresh) ) }				, 44, 11, , , , .T. )	//"Excluir"
	oButton6 := TButton():New ( 85, 160, STR0011, oDlg, { ||oDlg:End()}  																   						, 44, 11, , , , .T. )	//"Sai&r"
	//caso não seja encontrado user na tbl fro, inicializa a Lst de Obj c/ conteúdo vazio para ñ gerar error de acesso violado em browse.
	If Len(oList:aitems) == 0
		oList:SetItems({""})		
	EndIf

	oDlg:Activate(,,,.T.,,,)
Else
  If FindFunction ("GetParAuto")  // Tratamiento para scripts automatizados
     aRetAuto  := GetParAuto("FINA002TESTCASE")
     IF aRetAuto[1] == 2 //Visualizar
        	F002Processa( aRetAuto[2],2,lAutomato)
     ElseIf aRetAuto[1] == 3 //Incluir
     		RollBackSX8()
	    	F002Processa(aRetAuto[2],3,lAutomato)
	 ElseIf aRetAuto[1] == 4 //Modificar o Alterar
        	F002Processa( aRetAuto[2],4,lAutomato)
     ElseIf aRetAuto[1] == 5 //Borrar
        	F002Processa( aRetAuto[2],5,lAutomato)
     EndIF
  Endif
Endif

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³F002AllUsr ³ Autor ³ Edson Maricate       ³ Data ³ 30.09.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta o array contendo tosod usuarios do sistema            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³FINf002                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F002AllUsr( aAllUser ) 

ProcRegua(3)
IncProc()
IncProc()
aAllUser := FWSFALLUSERS()
IncProc()

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³admin	  ³ Autor ³ Edson Maricate      ³ Data ³ 30.09.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa o refresh na lista de compradores.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINf002                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F002LRfr( oList, aUser, aAllUser, aCodUser )	

Local aArea		:= GetArea()
Local aAreaFRO	:= FRO->(GetArea())
Local nI       	:= 0
Local nPos     	:= 0

aUser		:= {}
aCodUser	:= {}

For	nI	:= 1 to Len(aAllUser)
	FRO->(DbSetOrder(3))	//FRO_FILIAL+FRO_USER
	If FRO->( DbSeek( xFilial("FRO") + aAllUser[nI][2] ) )
		aAdd( aUser, aAllUser[nI][4] )
		aAdd( aCodUser, aAllUser[nI][2] )
	EndIf
Next

If oList != Nil     
	nPos := oList:NAT
	oList:SetItems(aUser) 
	If Len(oList:aITems) >= nPos
		oList:NAT := nPos
	Elseif Len(oList:aITems) == 0 //Caso todos os user sejam excl, iniciliza o lst de obj de user 
		oList:SetItems({""})
	EndIf
EndIf

RestArea(aAreaFRO)
RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³F002GetUser³ Autor ³ Edson Maricate       ³ Data ³ 30.09.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria uma tela com os Usuarios disponiveis.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³FINf002                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F002GetUser( aAllUser, cUser, aCodUser )

Local cTitle	:= STR0012	//"Usuários do Sistema" 
Local cPesq		:= Space(50)
Local aList		:= {}
Local aGroup	:= {}
Local aCodigo	:= {}
Local lRet		:= .F.

Local nOpc		:= 0
Local cList		:= 0
Local nList		:= 0
Local nPos		:= 0
Local oDlg		:= Nil 
Local oBold		:= Nil
Local oList		:= Nil
Local oTGet		:= Nil
Local oBmp 		:= Nil
Local oSay1		:= Nil
Local oSay2		:= Nil
Local oButton1	:= Nil
Local oButton2	:= Nil
Local oButton3	:= Nil

                      
aEval( aAllUser, { |x| If( aScan( aCodUser, x[2]) == 0, ( aAdd( aList, x[4] ), aAdd( aCodigo, { x[4], x[2] } ) ), Nil ) } )

aSort( aList )
oBold := TFont():New( "Arial", , -12, , .T. )

oDlg := MSDialog():New( 114, 180, 335, 600, cTitle,,,,,,,, oMainWnd, .T. )
	oBmp     := TBitMap():New( 0, 0, 90, 255, , "PROJETOAP", .F., oDlg,,,,,,,, { || .F. } )		
	oSay1 	 := TSay():New( 4, 50, { || STR0013 }, oDlg, , oBold,,,, .T.,,, 120, 9 )	//"Selecione o Usuário: "
	oList 	 := TListBox():New( 18, 50, { |u| If( PCount() > 0, cList := u, cList ) }, aList, 150, 56, { || nList := oList:nAT }, oDlg,,,,.T.,,{ || If( !Empty(cList), ( nOpc := 1, oDlg:End() ), ) } )   	
   	oButton1 := TButton():New( 80, 140, STR0006, oDlg, { || UserPesqui( , @oList:nAT, @aList, @oList, STR0005, oDlg ) }, 60, 10,,,, .T. )
   	oButton2 := TButton():New( 95, 115, "<< " + STR0014, oDlg, { || oDlg:End() }, 40, 10, , oDlg:oFont, , .T. )	//"Ca&ncelar"
	oButton3 := TButton():New( 95, 160, STR0015 + " >>", oDlg, { || If( !Empty(cList), ( nOpc := 1, oDlg:End() ), ) }, 40, 10, , oDlg:oFont, , .T. )	//"&Confirma"
oDlg:Activate(,,,.T.,,,)

If nOpc == 1            
	cUser := aCodigo[aScan( aCodigo, { |x| x[1] == aList[nList] } )][2]
	lRet  := .T.
EndIf  

Return(lRet)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³F002Processa³ Rev.  ³ Edson Maricate      ³ Data ³13.11.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de cadastro de Compradores.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³F002Processa(cUser,aCodUser,nOpcx)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cUser  : Codigo do Usuario                                 ³±±
±±³          ³ nOpcx  : 2 - Visualizar                                    ³±±
±±³          ³          3 - Incluir                                       ³±±
±±³          ³          4 - Alterar                                       ³±±
±±³          ³          5 - Excluir                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINf002                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function F002Processa( cUser, nOpcx, lAutomato)

Local oDlg 		:= Nil
Local oMsGet	:= Nil 
Local aArea		:= GetArea()
Local lEnchBar	:= .T.

Local lGravaOk	:= .F.
Local l002Inclui:= .F.
Local l002Exclui:= .F.
Local l002Visual:= .F.
Local l002Altera:= .F.

Local lPontoEnt	:= .F. //Retorno Ponto de Entrada MF002VLD 
Local lContinua	:= .T.

Local aButtons   	:= {} 
Local aUsrButtons	:= {}
Local aDms  		:= MsAdvSize(lEnchBar)//FWGetDialogSize(oMainWnd) 
Local nSaveSX8    	:= GetSX8Len()

Private lRefresh 	:= .T.
Private Inclui 	 	:= .F.

Default lAutomato	:= .F. //Se inicializa en .T. cuando viene por automatización, en todos los demás casos es .F.

Do Case
	Case nOpcx == 2
		l002Visual := .T.
	Case nOpcx == 3
		l002Inclui := .T.
		Inclui	:= .T.
	Case nOpcx == 4
		l002Altera := .T.
	Case nOpcx == 5   
		l002Exclui := .T.
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Em caso de exclusao verifica se analista esta cadastrado em Grupo de Analistas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If l002Exclui .And. lContinua 
	DbSelectArea("FRO")                                                          
	FRO->(DbSetOrder(3))	//FRO_FILIAL + FRO_USER     
	If FRO->(DbSeek(xFilial("FRO")+PADR(cUser,TamSx3("FRO_USER")[1]))) .or. l002Inclui  
		DbSelectArea("FRQ")
		FRQ->(DbSetOrder(2))       	//FRQ_FILIAL + FRQ_USER                                                   
		If FRQ->(DbSeek( xFilial() + PADR( FRO->FRO_COD, TamSx3("FRQ_USER")[1]) ) )
			Help( " ", 1, "F002PROC" )	//"Este Analista foi utilizado em um Grupo de Analistas Financeiros e não pode ser excluído."
			lContinua := .F.
		EndIf
	EndIf
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Em caso de Inclusão verifica se analista esta cadastrado como Gestor          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If l002Inclui .And. lContinua 
	DbSelectArea("FRP")
	FRP->(DbSetOrder(2))	//FRO_FILIAL + FRO_USER --> FRP_FILIAL + FRP_USER
	If FRP->(DbSeek(xFilial("FRO")+PADR(cUser,TamSx3("FRO_USER")[1])))
		Help(" ",1,"F003ExistUsr",,STR0024,1,0)  //"Já está cadastrado como Gestor"
		lContinua := .F.
	EndIf
EndIf

If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada que possibilita a adicao de botoes na EnchoiceBar³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("MF002BUT")
		If ValType( aUsrButtons := ExecBlock( "MF002BUT", .F., .F., {nOpcx} ) ) == "A" 
			aEval( aUsrButtons, { |x| aAdd( aButtons, x) } ) 
		EndIf 			
	EndIf 
	DbSelectArea("FRO")                                                          
	FRO->(DbSetOrder(3))	//FRO_FILIAL + FRO_USER     
	
	If FRO->(DbSeek(xFilial("FRO")+PADR(cUser,TamSx3("FRO_USER")[1]))) .or. l002Inclui 	           
	 
	  //	oDlg := MSDialog():New(aDms[7],aDms[2],aDms[6]/2+100,aDms[5]/2+50,cCadastro + " - " + aRotina[nOpcx][1],,,,,,,,oMainWnd,.T.)
	  	If !lAutomato 
	  		DEFINE MSDIALOG oDlg TITLE cCadastro + " - " + aRotina[nOpcx][1] FROM aDms[7],aDms[2] TO aDms[6]/2,aDms[5]/2+50 PIXEL OF oMainWnd                                                        
		EndIf
			RegToMemory("FRO",l002Inclui)
		
			If l002Inclui
				M->FRO_COD	:= GetSX8Num( "FRO", "FRO_COD" )
				M->FRO_USER	:= cUser
			EndIf
		
		If !lAutomato 
			oMsGet := Msmget():New( "FRO",, nOpcx,,,,, {18,2,210,318},,,,,, oDlg, .F., .T.,,,, )   
			oMsGet:oBox:Align := CONTROL_ALIGN_ALLCLIENT
			If l002Inclui
				oMsGet:aEntryCtrls[3]:Buffer := UsrFullName(cUser)
				oMsGet:aEntryCtrls[3]:cText:= UsrFullName(cUser)
			EndIf
		EndIf
			
	  If !lAutomato // Tratamiento para scripts Automatizados
   		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| IiF(Obrigatorio(oMsGet:aGets,oMsGet:aTela),(lGravaOk := .T.,oDlg:End()),lGravaOk := .F.)},{|| oDlg:End()},,aButtons) CENTERED    
      Else 
        lGravaOk := .T.
      Endif
	Else
		Help( " ", 1, "F002CARRE" )	//"Erro ao tentar carregar dados!"
	EndIf
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada que possibilita a validacao dos dados a serem gravados na tabela FRO			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MF002VLD")
	lPontoEnt := ExecBlock( "MF002VLD", .F., .F., { nRecFRO, nOpcx } )
	If ValType(lPontoEnt) == "L"
		lGravaOk := lPontoEnt
	EndIf
EndIf       

If !l002Visual .And. lGravaOk
	Begin Transaction
		F002Grava( cUser, l002Exclui, l002Altera )
		EvalTrigger()
        While (GetSX8Len() > nSaveSX8 )
			ConfirmSX8()
		EndDo
	End Transaction
Else
    While ( GetSX8Len() > nSaveSX8 )
       RollBackSX8()
	EndDo
EndIf

If l002Altera .Or. l002Exclui
	FRO->(MsUnlockAll())
EndIf

RestArea(aArea)  

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³F002Grava³ Autor ³ Edson Maricate         ³ Data ³ 30.09.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua a gravacao do Comprador                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³FINf002                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F002Grava( cUser, lExclui, lAltera )

Local bCampo   	:= { |nCpo| Field(nCpo) }
Local nI  		:= 0
Local lContinua	:= .T.

If ExistBlock("MF002GRV")
	ExecBlock("MF002GRV", .F., .F., { lExclui, lAltera } )
EndIf

If !lExclui
	If lAltera 
		FRO->(DbSetOrder(3))	//FRO_FILIAL + FRO_USER
		If FRO->(DbSeek( xFilial("FRO") + PADR( cUser, TamSx3("FRO_USER")[1] ) ) )
			FRO->(RecLock("FRO",.F.))
		Else
			lContinua:= .F.
		EndIf
	Else
		FRO->(DbSetOrder(1))
		While FRO->(DbSeek( xFilial("FRO") + M->FRO_COD ) ) .Or. !MayIUseCode( "FRO" + AllTrim(xFilial("FRO")) + M->FRO_COD )
			M->FRO_COD := Soma1( M->FRO_COD, Len(FRO_COD) )
		End
		FRO->(RecLock("FRO", .T.))
	EndIf
	
	If lContinua
		For nI := 1 To FCount()
			If "FILIAL" $ Field(nI)
				FieldPut( nI, xFilial("FRO") )
			Else
				FieldPut( nI, M->&(EVAL(bCampo,nI)) )
			EndIf
		Next nI
	Else
		Help( " ", 1, "F002GRAVA" )	//"Erro ao tentar efetuar gravação!"
	EndIf
Else
	FRO->(DbSetOrder(3))
	If FRO->(DbSeek( xFilial("FRO") + PADR( cUser, TamSx3("FRO_USER")[1] ) ) )
		If FRO->( RecLock( "FRO", .F., .T. ) )
			FRO->(dbDelete())
			FRO->(MsUnlock())
		Else
			Help( " ", 1, "F002EXCL" )	//"Erro ao tentar excluir!"
		EndIf
	Else 
		Help( " ", 1, "F002EXCL" )	//"Erro ao tentar excluir!"
	EndIf
EndIf 

Return Nil    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MenuDef	ºAutor  ³Jair Ribeiro        º Data ³  03/15/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Menu                                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIN                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()

Local aRotina := { { STR0006, "AxPesqui"  , 0, 1 },;	//"Localizar"
    	           { STR0008, "AxVisual"  , 0, 2 },;	//"Visualizar"
        	       { STR0007, "AxInclui"  , 0, 3 },;	//"Incluir"
            	   { STR0009, "AxAltera"  , 0, 4 },;	//"Alterar"
                   { STR0010, "f002Deleta", 0, 5, 3 } }	//"Excluir"
                   
Return aRotina
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ F002FRR  º Autor ³ Microsiga           º Data ³ 25/09/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consulta Especifica de Grupo de Gestores  , FRR_F5         º±±
±±º          ³ Criada para contornar a ordem unica da tabela FRR, que     º±±
±±º          ³ eh CODIGO+ DESCRICAO, MOEDA   , quando o campo FRR_COD     º±±
±±º          ³ representa o Codigo do Grupo de Gestores   .               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Campo FRR_COD                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function F002FRR()

    //--- Ambiente
	Local aArea := GetArea()
    
    //--- Select
	Local cQuery	:= ""
	Local cAliasFRR	:= ""
	Local aItens	:= {}

    //--- Dialog Principal
	Local oDlgFRR
	Local oBrwFRR
    
    //--- Variavel Get para Pesquisa 
	Local cDesc		:= ""
	Local oDesc
	Local oSayDesc

    //--- Genericas
	Local aScrRes	:= {}
	Local cFilFRR	:= xFilial( "FRR" ) 
	Local cCodigo   := ""
	Local cDescFRR	:= STR0023   // "Grupo de Gestores"
	Local nItem		:= 0
	Local xRet		:= .F.

	//--- Paineis
	Local oPnlTopo
	Local oPnlEsq
	Local oPnlDir
	Local oPnlBase
	Local oPnlCons
	Local oPnlCons1
	Local oPnlBot
	Local oSep0
	Local oSep1
	Local oSep2
	Local oSep3
	Local oSep4
	Local oSep5

	//--- Botoes	
	Local oBtnSair
	Local oBtnOk
	Local oBtnPesq

	
	dbSelectArea("FRR")
	dbSetOrder(1)
	DbGotop()

	While !EOF()
	   	If cCodigo != FRR->FRR_COD
	       Aadd( aItens, { FRR->FRR_COD, FRR->FRR_DESC, FRR->FRR_MOEDA,FRR->(RECNO()) } )
    	   cCodigo:= FRR->FRR_COD
    	Endif
	   	dbSkip()
	Enddo

		
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Montagem dos Paineis ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty( aItens )

            //--- Variavel Get para Pesquisa 
			cDesc := Space(FRR->(TamSX3("FRR_COD")[1]))

			aScrRes := MsAdvSize(.F.,.F.,300)

			oDlgFRR := TDialog():New(aScrRes[7],0,aScrRes[6]-450,aScrRes[5]-650,AllTrim(cDescFRR),,,,,,,,,.T.,,,,,)

				oPnlEsq := TPanel():New(01,01,,oDlgFRR,,,,,,5,5,.F.,.F.)
					oPnlEsq:Align := CONTROL_ALIGN_LEFT
					oPnlEsq:nWidth := 10
				oPnlDir := TPanel():New(01,01,,oDlgFRR,,,,,,5,5,.F.,.F.)
					oPnlDir:Align := CONTROL_ALIGN_RIGHT
					oPnlDir:nWidth := 10
				oPnlBase := TPanel():New(01,01,,oDlgFRR,,,,,,5,30,.F.,.F.)
					oPnlBase:Align := CONTROL_ALIGN_BOTTOM
					oPnlBase:nHeight := 10
				oPnlTopo := TPanel():New(01,01,,oDlgFRR,,,,,,5,30,.F.,.F.)
					oPnlTopo:Align := CONTROL_ALIGN_TOP
					oPnlTopo:nHeight := 10

                //--- Painel da Pesquisa 
				oPnlCons := TPanel():New(01,01,,oDlgFRR,,,,,,5,30,.F.,.F.)
					oPnlCons:Align := CONTROL_ALIGN_TOP
					oPnlCons:nHeight := 40
					oPnlCons1 := TPanel():New(01,01,,oPnlCons,,,,,,5,30,.F.,.F.)
					oPnlCons1:Align := CONTROL_ALIGN_ALLCLIENT

						@00,00 MSGET oDesc VAR cDesc SIZE 5,100 PIXEL OF oPnlCons1
							oDesc:Align := CONTROL_ALIGN_BOTTOM
							oDesc:nHeight := 20
						oSayDesc := TSay():New(0,0,{|| FRR->(RetTitle("FRR_DOC"))},oPnlCons1,,,,,,.T.,,,10,10)
							oSayDesc:Align := CONTROL_ALIGN_TOP
							oSayDesc:nHeight := 20

					oSep4 := TPanel():New(01,01,,oPnlCons,,,,,,5,30,.F.,.F.)
						oSep4:Align := CONTROL_ALIGN_RIGHT
						oSep4:nWidth := 10
					oSep5 := TPanel():New(01,01,,oPnlCons,,,,,,5,30,.F.,.F.)
						oSep5:Align := CONTROL_ALIGN_LEFT
						oSep5:nWidth := 10
					oPnlBot := TPanel():New(01,01,,oPnlCons,,,,,,5,30,.F.,.F.)
						oPnlBot:Align := CONTROL_ALIGN_RIGHT
						oPnlBot:nWidth := 100

                    //--- Botao Pesquisar 
					oPnlBot1 := TPanel():New(01,01,,oPnlBot,,,,,,5,30,.F.,.F.)
						oPnlBot1:Align := CONTROL_ALIGN_BOTTOM
						oPnlBot1:nHeight := 20
						oBtnPesq := TButton():New(0,0,"Pesquisar",oPnlBot1,{|| oBrwFRR:nAt := FRRPes(cDesc,aItens,oBrwFRR:nAt) },30,10,,,,.T.,,"",,,,)		//"Pesquisar"
							oBtnPesq:Align := CONTROL_ALIGN_RIGHT
							oBtnPesq:nWidth := 80

				oSep3 := TPanel():New(01,01,,oDlgFRR,,,,,,5,30,.F.,.F.)
					oSep3:Align := CONTROL_ALIGN_TOP
					oSep3:nHeight := 10

				oPnlBotoes := TPanel():New(01,01,,oDlgFRR,,,,,,5,30,.F.,.F.)
					oPnlBotoes:Align := CONTROL_ALIGN_BOTTOM
					oPnlBotoes:nHeight := 20
					oSep0 := TPanel():New(01,01,,oPnlBotoes,,,,,,5,30,.F.,.F.)
						oSep0:Align := CONTROL_ALIGN_TOP
						oSep0:nHeight := 5
					oSep1 := TPanel():New(01,01,,oPnlBotoes,,,,,,5,30,.F.,.F.)
						oSep1:Align := CONTROL_ALIGN_RIGHT

					oBtnSair := TButton():New(0,0,"Abandona",oPnlBotoes,{|| nItem := 0,oDlgFRR:End()},40,10,,,,.T.,,"",,,,)	//"Abandona"
						oBtnSair:Align := CONTROL_ALIGN_RIGHT

					oSep2 := TPanel():New(01,01,,oPnlBotoes,,,,,,5,30,.F.,.F.)
						oSep2:Align := CONTROL_ALIGN_RIGHT

					oBtnOk := TButton():New(0,0,"Selecionar",oPnlBotoes,{|| nItem := oBrwFRR:nAt,oDlgFRR:End()},40,10,,,,.T.,,"",,,,) //"Selecionar"
						oBtnOk:Align := CONTROL_ALIGN_RIGHT

                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Montagem das Colunas ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oBrwFRR := TCBrowse():New(0,0,100,100,,,,oBrwFRR,,,,,,,,,,,,.T.,"",.T.,{|| .T.},,,,)

				oBrwFRR:AddColumn(TCColumn():New(FRR->(RetTitle("FRR_COD"))   ,{|| aItens[oBrwFRR:nAt,1]},,,,"LEFT",20,.F.,.F.,,,,,))
				oBrwFRR:AddColumn(TCColumn():New(FRR->(RetTitle("FRR_DESC")),{|| aItens[oBrwFRR:nAt,2]},,,,"LEFT",25,.F.,.F.,,,,,))
				oBrwFRR:AddColumn(TCColumn():New(FRR->(RetTitle("FRR_MOEDA")),{|| aItens[oBrwFRR:nAt,3]},,,,"LEFT",20,.F.,.F.,,,,,))

				oBrwFRR:Align     := CONTROL_ALIGN_ALLCLIENT
				oBrwFRR:bLDblClick := {|| nItem := oBrwFRR:nAt,oDlgFRR:End()} 
				oBrwFRR:lAutoEdit := .F.
				oBrwFRR:lReadOnly := .F.
				oBrwFRR:SetArray(aItens)
				oDlgFRR:lCentered := .T.

			oDlgFRR:Activate(,,,,)

		Else

			ApMsgAlert(STR0022) //"Não foram encontrados itens para a tabela FRR"

		EndIf

	RestArea( aArea )

	If nItem > 0
		FRR->(DbGoTo(aItens[nItem,4]))
		xRet := .T.
	Endif

Return( xRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FRRPes   º Autor ³ Microsiga           º Data ³ 25/09/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Acionada pelo botao Pesquisar da Consulta Especifica       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Consulta Especifica                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FRRPes( cTarget, aSearch, nPos )

Local nPes    := 0
Local nTamTar := Len( AllTrim( cTarget ) )

 If nTamTar > 0
 
   nPes := aScan( aSearch, { |x| Left( x[ 2 ], nTamTar ) == Left( cTarget, nTamTar ) } )

 EndIf
   
 If nPes == 0
    nPes := nPos
 EndIf
   
Return( nPes )