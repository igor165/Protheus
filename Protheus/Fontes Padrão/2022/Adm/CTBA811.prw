#INCLUDE "PROTHEUS.CH"                      
#INCLUDE 'DBTREE.CH'
#INCLUDE "CTBA810.CH"                         

#Define BMPINCLUIR  	"BMPINCLUIR.PNG"
#Define BMPALTERAR 		"NOTE.PNG"
#Define BMPEXCLUIR 		"EXCLUIR.PNG"

#Define BMPCONFIRMAR 	"OK.PNG"
#Define BMPCANCELAR 	"CANCEL.PNG"

#Define BMPCOPIAR 		"S4WB005N.PNG"
#Define BMPCOLAR 		"S4WB007N.PNG"
 
#Define BMPPESQUISA  	"PESQUISA.PNG"
#Define BMPFILTRO	  	"FILTRO.PNG"
#Define BMPCAMPO	  	"BMPCPO.PNG"
#Define BMPSAIR	  		"FINAL.PNG"       

#Define BMPCUBO 		"PCOCUBE.PNG" 
#Define BMPSALVAR 		"SALVAR.PNG"

#Define CLRLAYER	  	CLR_WHITE//RGB(180,210,220)

#Define BOTAOCLASSICO 		1
#Define BOTAOFWAREA 		2

#Define X_ALIAS Left( oTree:GetCargo(), 3)
#Define X_RECNO Val( Right( oTree:GetCargo(), 6) )

Static lCriaTrb
Static aArqTrb   := {}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBA811   ³ Autor ³ TOTVS                 ³ Data ³ 07/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Amarracoes de entidades                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


Function CTBA811()
Local lCtbUseAmar := FindFunction( "CTBA811" ) .And. FindFunction( "CtbUseAmar" ) .And. ( CtbUseAmar() $ '2#3' )
Private aRotina 	:= MenuDef()	
Private cCadastro 	:= OemToAnsi(STR0001) //"Cadastro AmarraÃ§Ã£o de entidades"
Private cBrwFiltro	:= "" 
Private aIndexFil	:= {}
Private bFiltraBrw



If !lCtbUseAmar
	If FunName() != "CTBA250"
	    CTBA250()   //Somente chamar CTBA250 se nï¿½o foi o ctba250 que chamou o ctba811
	EndIf
	Return
EndIf

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf


SetKey(VK_F12,{|a,b|Pergunte("CTB250",.T.)})



If CTA->(FieldPos('CTA_CONTA')) == 0 .OR. CTA->(FieldPos('CTA_CUSTO')) == 0 .OR. ;
	CTA->(FieldPos('CTA_ITEM')) == 0 .OR. CTA->(FieldPos('CTA_CLVL')) == 0 .OR. ;
	CTA->(FieldPos('CTA_ITREGR')) == 0               //se os campos nao existirem deve retornar ao menu
	Aviso(STR0029,STR0030, {`"Ok"})  //"Atencao", "Campos Conta/Centro de Custo/Item Contabil/Classe de Valor nao encontrado. Verifique Parametro MV_CTBAMAR."
	Return
EndIf

cBrwFiltro := ' CTA_ITREGR == "'+StrZero(1,TamSx3("CTA_ITREGR")[1])+'"'
bFiltraBrw := { || FilBrowse("CTA",@aIndexFil,@cBrwFiltro) }
DbSelectArea("CTA")
Eval(bFiltraBrw)

mBrowse( 6, 1,22,75,"CTA" )  

EndFilBrw("CTA",aIndexFil)
Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBA811ROT³ Autor ³ TOTVS                 ³ Data ³ 07/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processamento por opcao do aRotina                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function CTBA811ROT(cAlias,nRecno,nOpc)
Local oRegCT0
Local oFont
Local aScreen 		:= MsAdvSize(.F.)	//GetScreenRes()
Local nWStage 		:= aScreen[5]		//aScreen[1]-63
Local nHStage 		:= aScreen[6]		//aScreen[2]-255
Local nColorAnt, nX
Local oDlg, oWin01, oWin02,oWin03,oWin04, oTree
Local oFWLayer
Local lRetFiltro	
Local cCT1Conta	:= Space(TamSx3('CT1_CONTA')[1])
Local bColor1 := {|| oWin03:nClrPane := nColorAnt,oWin01:nClrPane := CLRLAYER }
Local bColor2 := {|| oWin01:nClrPane := nColorAnt,oWin03:nClrPane := CLRLAYER }
Local bDescCT0 := {|| Alltrim(CT0->CT0_ID)+ " - " + Alltrim(CT0->CT0_DESC) + ' [' + cValToChar(nCount) + ']' }

Local bDescriCT1	:= {|| Alltrim(CT1->CT1_CONTA)+"-"+Alltrim(CT1->CT1_DESC01 ) }
Local bDescriCTT	:= {|| Alltrim(CTT->CTT_CUSTO)+"-"+Alltrim(CTT->CTT_DESC01 ) }
Local bDescriCTD	:= {|| Alltrim(CTD->CTD_ITEM)+"-"+Alltrim(CTD->CTD_DESC01 ) }
Local bDescriCTH	:= {|| Alltrim(CTH->CTH_CLVL)+"-"+Alltrim(CTH->CTH_DESC01 ) }
Local bDescriE05	:= {|| }
Local bDescriE06	:= {|| }
Local bDescriE07	:= {|| }
Local bDescriE08	:= {|| }
Local bDescriE09	:= {|| }

Local bPosiciona := {|| dbSelectArea(X_ALIAS), dbGoto(X_RECNO) }

Local bReg_Memory := { |cAlias, lGet_Incl | 	lGet_Incl := If(lGet_Incl == NIL,  .F., lGet_Incl), ;
												dbSelectArea(cAlias), ;
												RegToMemory(cAlias,lGet_Incl) }

Local bAtua_Enchoice := { |oEnch, cAlias, lGet_Incl | 	Eval(bReg_Memory,cAlias,lGet_Incl), ;
														oEnch:EnchRefreshAll() }
														
Local bChgState := { || oFWLayer:WinChgState("Col02", "Win02"), ;        //Minimiza
						oFWLayer:WinChgState("Col02", "Win02"), ;        //Maximiza
						oFWLayer:WinChgState("Col02", "Win03"), ;        //Minimiza
						oFWLayer:WinChgState("Col02", "Win03"), ;        //Maximiza
						oFWLayer:WinChgState("Col02", "Win04"), ;        //Minimiza
						oFWLayer:WinChgState("Col02", "Win04") }        //Maximiza

Local bAction  := 	{|oTree| 	Eval(bPosiciona), ;
								cPlano := CT0->CT0_ENTIDA, ;
								lRetFiltro := CtbEditTree(oTree,CT0->CT0_ALIAS,CT0->CT0_ENTIDA,CT0->CT0_DESC,VAL(CT0->CT0_ID),aResult,oWin04), ;
	 					 		IIf(lRetFiltro,CtbInclAmarra(oWin04,CT0->CT0_ALIAS,CT0->CT0_ENTIDA,VAL(CT0->CT0_ID),aResult,Nil,CT0->CT0_ID + ' - ' + CT0->CT0_DESC,@oTree),.T.)} 

Local aResult := {}

Local oBarMarc

Local bInclEntid := {||}
Local bAltEntid  := {||}

Local bFiltro	:= {|| CtbFiltro(bPosiciona,oTree,aResult,@oWin03) }

Local aCampos	:= Nil
Local aParam	:= {}
Local aConfig	:= {}
Local aTitle 	:= {"*",STR0002,STR0003}   //"Conta"###"Descriï¿½ï¿½o"
Local aTitleCb 	:= Nil
Local nOpcao	:= 0	
Local cOpcao	:= ""	//Iif(nOpc==3,"Incluir","Em desenvolvimento") 
Local aTmp		:= {} 
Local aTmp2		:= {}
Local nY		:= 0  
Local aCposCT0	:= Nil 
Local lFlag		:= Nil
Local nCount	:= 0 
Local aEntMarks	:= {}
Local nC		:= 0 
Local cDescrEnt	:= "" 
Local cGetCargo	:= ""
Local cCPOCHV
Local cCPODSC
Local cF3ENTI
Local aAuxCT0	:= { {"CT1_CONTA" ,"CT1_DESC01","CT1"}, {"CTT_CUSTO" ,"CTT_DESC01","CTT"}, {"CTD_ITEM"  ,"CTD_DESC01","CTD"}, {"CTH_CLVL"  ,"CTH_DESC01","CTH"} }
Local lAntINCLUI:= .F.
                          
Private VISUAL	:= nOpc==2
Private INCLUI	:= nOpc==3
Private ALTERA	:= nOpc==4 
Private EXCLUI	:= nOpc==5

Private oOk		:= LoadBitMap(GetResources(), "LBTIK")
Private oNo		:= LoadBitMap(GetResources(), "LBNO")

Private cPlano
Private cCodigo := ""  
Private lMarkTodos := .F. 
Private oLstBox
Private aDados		:= {}   
Private aCubos		:= {}
Private aMarcados	:= Nil
Private aRegCT0		:= Nil
Private nTotEnt		:= 0 
Private bBlocobLine	:= "{ || {If(aCubos[oLstBox2:nAt,1],oOk,oNo),"//Iif(INCLUI,"{ || {If(aCubos[oLstBox2:nAt,1],oOk,oNo),","{ || {")
Private aDescrEnt	:= {} 
Private nSomaCol	:= 1 //Iif(INCLUI .OR. ALTERA,1,0) 
Private aIndexes
Private aCpoCubos	:= {}

dbSelectArea(cAlias)
dbGoTo(nRecno)

If FindFunction("CTBEntGtIn")
	aIndexes := CTBEntGtIn()
Else
	aIndexes := {{1, 5},{1, 5},{1, 5},{1, 5},{1, 3},{1, 3},{1, 3},{1, 3},{1, 3}}
EndIf
                                
AADD( aDados,{.f.,"",""} ) 

If VISUAL
	cOpcao := STR0004 //"Visualizar"
ElseIf INCLUI
	cOpcao := STR0005 //"Incluir"
ElseIf ALTERA
	cOpcao	:= STR0006 //"Alterar" 
Else
	cOpcao	:= STR0007 //"Excluir"	
EndIf 		

If !INCLUI .And. !ALTERA

	bAction  := 	{|oTree| 	Eval(bPosiciona), ;
								MostraLista(VAL(CT0->CT0_ID))}  
EndIf

//--------------------------------------------------------------------------//
oRegCT0:= Adm_List_Records():New()
oRegCT0:SetAlias("CT0")  //alias
oRegCT0:SetOrder(1)		//ordem do indice	
oRegCT0:Fill_Records() //preenche os registros 

For nX := 1 TO oRegCT0:CountRecords()
	oRegCT0:SetPosition(nX)
	oRegCT0:SetRecord()

	If nX==5
		bDescriE05 := &("{|| Alltrim("+CT0->CT0_ALIAS+"->"+CT0->CT0_CPOCHV+")+'-'+Alltrim("+CT0->CT0_ALIAS+"->"+CT0->CT0_CPODSC+" ) }")
		AADD(aAuxCT0, {CT0->CT0_CPOCHV, CT0->CT0_CPODSC, CT0->CT0_ALIAS})
	ElseIf nX==6
		bDescriE06 := &("{|| Alltrim("+CT0->CT0_ALIAS+"->"+CT0->CT0_CPOCHV+")+'-'+Alltrim("+CT0->CT0_ALIAS+"->"+CT0->CT0_CPODSC+" ) }")
		AADD(aAuxCT0, {CT0->CT0_CPOCHV, CT0->CT0_CPODSC, CT0->CT0_ALIAS})
	ElseIf nX==7
		bDescriE07 := &("{|| Alltrim("+CT0->CT0_ALIAS+"->"+CT0->CT0_CPOCHV+")+'-'+Alltrim("+CT0->CT0_ALIAS+"->"+CT0->CT0_CPODSC+" ) }")
		AADD(aAuxCT0, {CT0->CT0_CPOCHV, CT0->CT0_CPODSC, CT0->CT0_ALIAS})
	ElseIf nX==8
		bDescriE08 := &("{|| Alltrim("+CT0->CT0_ALIAS+"->"+CT0->CT0_CPOCHV+")+'-'+Alltrim("+CT0->CT0_ALIAS+"->"+CT0->CT0_CPODSC+" ) }")
		AADD(aAuxCT0, {CT0->CT0_CPOCHV, CT0->CT0_CPODSC, CT0->CT0_ALIAS})
	ElseIf nX==9
		bDescriE09 := &("{|| Alltrim("+CT0->CT0_ALIAS+"->"+CT0->CT0_CPOCHV+")+'-'+Alltrim("+CT0->CT0_ALIAS+"->"+CT0->CT0_CPODSC+" ) }")
		AADD(aAuxCT0, {CT0->CT0_CPOCHV, CT0->CT0_CPODSC, CT0->CT0_ALIAS})
	EndIf
Next

nTotEnt 	:= oRegCT0:CountRecords()

aResult 	:= ARRAY( nTotEnt )

aMarcados 	:= ARRAY( nTotEnt )

aRegCT0		:= ARRAY( nTotEnt )
AFILL(aRegCT0,{})

aTitleCb	:= ARRAY( nTotEnt + nSomaCol )  

aCpoCubos	:= { 	{0,''},;
		   			{1,'CTA_CONTA'},;
	   				{2,'CTA_CUSTO'},;  
   					{3,'CTA_ITEM'},;
  					{4,'CTA_CLVL'}	  }
					
For nX:=Len(aCpoCubos) To nTotEnt
	AADD(aCpoCubos,{nX,'CTA_ENTI'+StrZero(nX,2)})
Next nX 					

DEFINE DIALOG oDlg TITLE STR0011 SIZE nWStage,nHStage PIXEL STYLE nOr(WS_VISIBLE,WS_POPUP)  //"Entidades Contabeis"

// Cria instancia do fwlayer
oFWLayer := FWLayer():New()
// Inicializa componente passa a Dialog criada, 
// o segundo parametro Ã© para criaÃ§Ã£o de um botao de fechar utilizado para Dlg sem cabeÃ§alho
oFWLayer:init( oDlg, .T. )
// Adiciona coluna passando nome, porcentagem da largura, e se ela Ã© redimensionada ou nÃ£o
oFWLayer:addCollumn( "Col01", 30, .T. )
// seta o split da coluna passando o nome e o alinhamento
///oFWLayer:setColSplit( "Col01", CONTROL_ALIGN_RIGHT,, {|| aLERT("Split")} )
// Cria windows passando, nome da coluna onde sera criada, nome da window
// titulo da window, a porcentagem da altura da janela, se esta habilitada para click,
// se Ã© redimensionada em caso de minimizar outras janelas e a aÃ§Ã£o no click do split
oFWLayer:addWindow( "Col01", "Win01", STR0013, 95, .F., .T.,/* {|| Alert("Janela 01") }*/,,bColor1)  //"Entidade"
oWin01 := oFWLayer:getWinPanel('Col01','Win01')
nColorAnt := oWin01:nClrPane
oWin01:nClrPane := CLRLAYER
oWin01:blClicked := bColor1

oFWLayer:addCollumn( "Col02", 70, .T. )
// Cria windows passando, nome da coluna onde sera criada, nome da window
// titulo da window, a porcentagem da altura da janela, se esta habilitada para click,
// se Ã© redimensionada em caso de minimizar outras janelas e a aÃ§Ã£o no click do split
oFWLayer:addWindow( "Col02", "Win02", STR0012+" - " + cOpcao, 20, .T., .T., {|| },,bColor2)  //"Cadastro"
oWin02 := oFWLayer:getWinPanel('Col02','Win02')
oWin02:blClicked := bColor2   
oWin02:Align := CONTROL_ALIGN_ALLCLIENT

oFWLayer:addWindow( "Col02", "Win03", STR0014, 38,.T., .T.,/* {|| Alert("Janela 03") }*/,,bColor2)  //"AmarraÃ§Ã£o"
oWin03 := oFWLayer:getWinPanel('Col02','Win03')  
oWin03:blClicked := bColor2   
oWin03:Align := CONTROL_ALIGN_ALLCLIENT       

oFWLayer:addWindow( "Col02", "Win04", STR0014, 38,.T., .T.,/* {|| Alert("Janela 03") }*/,,bColor2)  //"AmarraÃ§Ã£o"
oWin04 := oFWLayer:getWinPanel('Col02','Win04')  
oWin04:blClicked := bColor2   
oWin04:Align := CONTROL_ALIGN_ALLCLIENT                         

If INCLUI .Or. ALTERA
	DEFINE BUTTONBAR oBarMarc SIZE 30,30 3D BOTTOM OF oWin03
	//BotÃ£o Filtrar           
	oButton := TButton():New( 005, 005, STR0010,oBarMarc,bFiltro,40,10,,,.F.,.T.,.F.,,.F.,,,.F. )		//"Filtrar"
EndIf

lAntINCLUI := INCLUI
// Quando chamado pela CTBA250, considera mesma incluso (mesmo Cod. Regra de Ligacao) 
If IsInCallStack('CTBA250DLG')
	INCLUI := .F.
EndIf
RegToMemory('CTA',INCLUI)
INCLUI := lAntINCLUI
                                                                                              
//------------------------------------------------------------------------------------------//
//SELECIONA AMARRACAO OPCAO VISUAL,ALTERA,EXCLUI
//------------------------------------------------------------------------------------------//
If !INCLUI
	
	lFlag := .T.//Iif( ALTERA,.T.,.F. )

	aCubos 	:= {}
					
	aCampos := aClone( aCpoCubos )					
					
	AFILL(aMarcados,{})	
	
	aTmp := aClone( aMarcados )
	
	If Select('__CTA') == 0
		CHKFILE('CTA',.F.,'__CTA')	
	EndIf				
					
	DbSelectArea('__CTA')	
	DbSetOrder(1)
	If DbSeek(xFilial('CTA')+M->CTA_REGRA )	
		While __CTA->(!Eof()) .And. __CTA->CTA_FILIAL == xFilial('CTA') .And. __CTA->CTA_REGRA == M->CTA_REGRA
		
			aAdd(aCubos, ARRAY(nTotEnt + nSomaCol) )
			
			AFILL( aCubos[len(aCubos)],"" )
		    
			AFILL( aCubos[len(aCubos)],lFlag,1,1)	
			       
			For nX:= 1 To Len(aCampos)		
				If aCampos[nX][1] > 0
					aCubos[Len(aCubos)][aCampos[nX][1]+nSomaCol] := __CTA->&(aCampos[nX][2])				
				EndIf					
			Next nX				
	
			For nX:=1 To Len(aCampos)
				If aCampos[nX][1] > 0 .And. !Empty(__CTA->&(aCampos[nX][2])) 
					If Ascan( aTmp[aCampos[nX][1]],{|z| Alltrim(z[2]) == Alltrim(__CTA->&(aCampos[nX][2])) }	) == 0				
						AADD(aTmp[aCampos[nX][1]], {aCampos[nX][1],__CTA->&(aCampos[nX][2])} )					
					EndIf
				EndIf				                               			
			Next nX			
			
			__CTA->(dbSkip())
		
		EndDo 
		
		For nX:=1 To Len(aTmp) 
			aTmp2 	:= {}
			nPosEnt	:= 0
			For nY:=1 To Len(aTmp[nX])
            	nPosEnt := aTmp[nX][nY][1]
            	aCposCT0:= GetAdvFval('CT0',{'CT0_ALIAS','CT0_CPODSC','CT0_ENTIDA'},xFilial('CT0')+StrZero(nPosEnt,TamSx3('CT0_ID')[1]),1)
            	If aCposCT0[1] == "CV0"
					AADD( aTmp2,{lFlag,aTmp[nX][nY][2],GetAdvFval(aCposCT0[1],aCposCT0[2],xFilial(aCposCT0[1])+aCposCT0[3]+aTmp[nX][nY][2],1)} )
            	Else
					AADD( aTmp2,{lFlag,aTmp[nX][nY][2],GetAdvFval(aCposCT0[1],aCposCT0[2],xFilial(aCposCT0[1])+aTmp[nX][nY][2],1)} )
				EndIf
			Next nY		
			If nPosEnt > 0
				aMarcados[nPosEnt] := aClone(aTmp2)		
			EndIf
		Next nX 
		
		aTmp2:= {}
		AADD(aTmp2,{.f.,"",""})
		
		For nX:=1 To Len(aMarcados)
			If Empty(aMarcados[nX])
				aMarcados[nX] := aClone(aTmp2)			
		    EndIf
		Next		                     
		
	EndIf		
EndIf

//------------------------------------------------------------------------------------------//
//CRIACAO DA ARVORE
//------------------------------------------------------------------------------------------//
oTree:= Xtree():New(oWin01:nLeft+2,oWin01:nTop+2,oWin01:oWnd:nHeight-420,oWin01:oWnd:nWidth*.30-150, oWin01) 
oTree:nClrPane := CLRLAYER  
oTree:Align := CONTROL_ALIGN_ALLCLIENT

	oTree:AddTree	( STR0011,; //descricao do node###"Entidades Contabeis"
						"IndicatorCheckBox", ; //bitmap fechado
						"IndicatorCheckBoxOver",; //bitmap aberto
						"ZZZZZ000000", ;  //cargo (id)
						{|| oTree:nClrPane := CLRLAYER } ; //bAction - bloco de codigo para exibir
					) 
				     
	If INCLUI //.Or. ALTERA				
		aAdd(aCubos, {} )
		aAdd(aCubos[Len(aCubos)], .f.)	 
	EndIf	

	aTitleCb[01] := "*"					

	For nX := 1 TO oRegCT0:CountRecords()
	
		oRegCT0:SetPosition(nX)
		oRegCT0:SetRecord()       
		
		If INCLUI //.Or. ALTERA
			aAdd(aCubos[Len(aCubos)], Space(20))			 
		EndIf				

		aTitleCb[nX+nSomaCol] := CT0->CT0_DESC 	//"Entidade " + CT0->CT0_ID							

		bBlocobLine += "aCubos[oLstBox2:nAT]["+cValTochar(nX+nSomaCol)+"]," 			

		If CT0->(FieldPos("CT0_CPOCHV"))>0 .And. !Empty(CT0->CT0_CPOCHV)
			cCPOCHV := CT0->CT0_CPOCHV
		Else
			cCPOCHV := aAuxCT0[nX][1]
		EndIf
		If CT0->(FieldPos("CT0_CPODSC"))>0 .And. !Empty(CT0->CT0_CPODSC)
			cCPODSC := CT0->CT0_CPODSC
		Else
			cCPODSC := aAuxCT0[nX][2]
		EndIf
		If CT0->(FieldPos("CT0_F3ENTI"))>0 .And. !Empty(CT0->CT0_F3ENTI)
			cF3ENTI := CT0->CT0_F3ENTI
		Else
			cF3ENTI := aAuxCT0[nX][3]
		EndIf

		aRegCT0[nX]:= {CT0->CT0_ALIAS , CT0->CT0_ENTIDA, CT0->CT0_ID, cCPOCHV, cCPODSC, cF3ENTI }
                                                   
        AADD(aDescrEnt,Eval(bDescCT0))
        
		cGetCargo := "CT0"+If(Empty(CT0->CT0_ENTIDA),"ZZ",CT0->CT0_ENTIDA)+StrZero(CT0->(Recno()),6)	 	        

		If !INCLUI		             
		                     
			aEntMarks := aMarcados[nX]
				                 
			nCount := 0				
			For nC:=1 To Len(aEntMarks)
				If aEntMarks[nC][1]
					nCount ++
				EndIF			      
			Next nC
			
		EndIf					
        
		oTree:AddTree	( Eval(bDescCT0),; 				//descricao do node 
							Iif(nCount==0,"IndicatorCheckBox","IndicatorCheckBoxOver"), ; 		//bitmap fechado
							"IndicatorCheckBoxOver",; 	//bitmap aberto
							cGetCargo, ;  				//cargo (id)
							bAction ; 					//bAction - bloco de codigo para exibir
						)                                         
	
		oTree:EndTree()  
			
	Next
	
//oTree:EndTree()  

// REMOVER A ULTIMA VIRGULA
bBlocobLine := Substr(bBlocobLine,1,Len(bBlocobLine)-1) + "} }"

oLstBox := TwBrowse():New(0,0,0,000,,aTitle,,oWin03,,,,,,,,,,,,.F.,,.T.,,.F.,,,) 
oLstBox:Align := CONTROL_ALIGN_ALLCLIENT
oLstBox:SetArray(aDados)
oLstBox:bLine := { || {If(aDados[oLstBox:nAt,1],oOk,oNo),aDados[oLstBox:nAT][2],aDados[oLstBox:nAT][3]}}
If INCLUI .Or. ALTERA
	oLstBox:bLDblClick := {|| MarkList('L1',@aDados,bPosiciona,oTree) ,oLstBox:Refresh() }
	oLstBox:bHeaderClick := {|X,Y|(_L := Y,IIF(_L == 1,MarkList('T1',@aDados,bPosiciona,oTree),aSort(aDados,,,{|_A1,_A2| _A1[_L] <= _A2[_L] }) ) ,oLstBox:Refresh()) }	
EndIf

oLstBox2 := TwBrowse():New(0,0,0,000,,aTitleCb,,oWin04,,,,,,,,,,,,.F.,,.T.,,.F.,,,) 
oLstBox2:Align := CONTROL_ALIGN_ALLCLIENT
oLstBox2:SetArray(aCubos)
oLstBox2:bLine := &(bBlocobLine)
If INCLUI .Or. ALTERA
	oLstBox2:bLDblClick := {|| MarkList('L2',@aCubos,bPosiciona,oTree) ,oLstBox2:Refresh() }
	oLstBox2:bHeaderClick := {|X,Y|(_L := Y,IIF(_L == 1,MarkList('T2',@aCubos,bPosiciona,oTree),aSort(aCubos,,,{|_A1,_A2| _A1[_L] <= _A2[_L] }) ) ,oLstBox2:Refresh()) }	
EndIf

CtbGetConta(@oWin02,nOpc) 

//EnchoiceBar
EnchoiceBar(oDlg, IIF(INCLUI .OR. ALTERA, {||nOpcao:= 0,Iif(A811VldGrava(),nOpcao:=1,Nil),Iif(nOpcao==1,oDlg:End(),Nil)}, IIF(EXCLUI, {|| nOpcao:=1,oDlg:End()} , {|| oDlg:End()} ) ) , {|| oDlg:End()} ,,/*aButtons*/)

//AtivaÃ§Ã£o da dialog principal
ACTIVATE DIALOG oDlg CENTERED ON INIT Eval(bChgState)

If nOpcao == 1
	BEGIN TRANSACTION
		Processa( {|| CTBA811Grava(nOpc)},STR0015)		//"Gravando..."
	END TRANSACTION		   
Else
	RollBackSx8()	
EndIf 

If Select('__CTA') > 0
	DbSelectArea('__CTA')
	dbCloseArea()
EndIf

If EXCLUI
	DbSelectArea("CTA")
	Eval(bFiltraBrw)
EndIf

a811Erase()  //Exclui as tabelas temporarias criadas no banco

Return 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CtbFiltro ³ Autor ³ TOTVS                 ³ Data ³ 07/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Acao do botao filtro                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function CtbFiltro(bPosiciona,oTree,aResult,oWin03)
Local aArea	:= GetArea()

If Left( oTree:GetCargo(), 3) != 'ZZZ'
	Eval(bPosiciona) 
	If CtbEditTree(oTree,CT0->CT0_ALIAS,CT0->CT0_ENTIDA,CT0->CT0_DESC,VAL(CT0->CT0_ID),aResult,oWin03,.t.)
		CtbInclAmarra(oWin03,CT0->CT0_ALIAS,CT0->CT0_ENTIDA,VAL(CT0->CT0_ID),aResult,.t.,CT0->CT0_ID + ' - ' + CT0->CT0_DESC,@oTree) 
	EndIf	
EndIF

RestArea(aArea)
Return
      

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CtbEditTree³ Autor ³ TOTVS                 ³ Data ³ 07/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Acao da arvore de entidades                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


Static Function CtbEditTree(oTree,cAlias,cPlano,cTitCpo,nEntid,aResult,oWin02,lBotaoFiltro)
Local cCampo := ""
Local cTitulo := oTree:GetPrompt()
Local aParametros	:= {}
Local aConfig := {}
Local cRange_De 
Local cRange_Ate
Local cFiltro := ""
Local aTamCpo 
Local cF3 := ""   
Local lRet := .T.

Default lBotaoFiltro := .F. 

If !Empty(aMarcados[nEntid]) .And. !Empty(aMarcados[nEntid][1][2]) .And. !lBotaoFiltro 
	Return(lRet)
EndIf 

cCampo 	:= Alltrim(aRegCT0[nEntid][4])	
cF3 	:= Alltrim(aRegCT0[nEntid][6])	

aTamCpo := TamSX3(cCampo)

If aResult[nEntid] == NIL   //primeira vez
	cRange_De := Space(aTamCpo[1])
	cRange_Ate := Replicate("Z",aTamCpo[1])
	cFiltro := ""
Else
	cRange_De := aResult[nEntid, 1]
	cRange_Ate := aResult[nEntid, 2]
	cFiltro := aResult[nEntid, 3]
EndIf
aAdd(aParametros,{1, Alltrim(cTitCpo)+STR0016	, cRange_De		, "" 	,"",cF3/*f3*/	,""	, aTamCpo[1]*5 , .F. } ) //" de "
aAdd(aParametros,{1, Alltrim(cTitCpo)+STR0017	, cRange_Ate	, "" 	,"",cF3/*f3*/	,""	, aTamCpo[1]*5 , .F. } ) //" Ate "
aAdd(aParametros,{7, STR0018					, cAlias		,cFiltro,""} ) //"Filtro "

If ParamBox(  aParametros ,cTitulo,aConfig,{||ValidParam(nEntid,aTamCpo)},,.F.,,,,,.F.)
	aResult[nEntid] := aClone(aConfig)
	oTree:ChangeBmp(BMPALTERAR,BMPALTERAR,oTree:GetCargo()) 
Else 
	//RETORNO ACAO DO BOTAO CANCELA DO PARAMBOX
	If INCLUI .OR. ALTERA
		//CASO ENTIDADE NAO TENHA NENHUM ITEM ESCOLHIDO ATUALIZAR A JANELA
		If ValType(aMarcados[nEntid]) == 'U' .or. ( ValType(aMarcados[nEntid]) != 'U' .And. Empty(aMarcados[nEntid][1][2]) )   
			aDados := {}
			AADD( aDados,{.f.,"",""} )
			oLstBox:SetArray(aDados)
			oLstBox:bLine := { || {If(aDados[oLstBox:nAt,1],oOk,oNo),aDados[oLstBox:nAT][2],aDados[oLstBox:nAT][3]}}
			oLstBox:Refresh()  

		EndIf	          
		lRet := .F.	 		
	EndIf
EndIf

Return(lRet)  


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ValidParam ³ Autor ³ TOTVS                 ³ Data ³ 07/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida digitacao dos parametros                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


Static Function ValidParam(nEntid,aTamCpo) 
Local aArea		:= GetArea()
Local _cAlias   := aRegCT0[nEntid][1]
Local _cPlano   := aRegCT0[nEntid][2]
Local lRetorno 	:= .T.
Local _cParam	:= Nil
Local nX		:= 0

DbSelectArea(_cAlias)
DbSetOrder(aIndexes[nEntid][1])
For nX:=1 To 2
	_cParam	:= &("MV_PAR"+AllTrim(STRZERO(nx,2,0)))
	If !Empty( _cParam )  
		If UPPER(Repl("z",aTamCpo[1])) != UPPER(_cParam)
			If _cAlias == "CV0"
				lRetorno := DbSeek( xFilial(_cAlias) + _cPlano + _cParam )
			Else
				lRetorno := DbSeek( xFilial(_cAlias) + _cParam )
			EndIf
			If !lRetorno 
				Help( " ",1,"REGNOIS")
				lRetorno := .F.
				nX := 3		             
			EndIf
		EndIf	                        
	EndIf
Next nX             

RestArea(aArea)
Return( lRetorno )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CtbInclAmarra³ Autor ³ TOTVS                 ³ Data ³ 07/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seleciona dados para o alistbox                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function CtbInclAmarra(oWin03,cAlias,cCodEnt,nEntid,aResult,lBotaoFiltro,cDescEntidade,oTree) 
Local aArea	:= GetArea() 
Local nX
Local nCtd := 0
Local cQuery := ""
Local cAliasQry	:= ""   
Local oGet 
Local cCampo	:= ""    
Local cSelCampo	:= ""  
Local lCpoClasse:= Nil   
Local lSel	:= .F. 
Local lMarcado	:= .F.
Local _cFiltro	:= ""

Default lBotaoFiltro := .F.

If Empty(aMarcados[nEntid]) .Or. lBotaoFiltro
	                      
   	lCpoClasse:= cAlias $ 'CT1*CTT*CTD*CTH*CV0'
   	
	cCampo 		:= Alltrim(aRegCT0[nEntid][4])
	cSelCampo 	:= Alltrim(aRegCT0[nEntid][4]) + " CONTA,"+Alltrim(aRegCT0[nEntid][5])+" DESCR "
			
	cAliasQry	:= GetNextAlias() 
	
	cQuery := "SELECT " + cSelCampo + " "
	cQuery += "FROM "+RetSqlName(cAlias)+" "+cAlias+" " 
	cQuery += "WHERE "+PrefixoCpo(cAlias)+"_FILIAL = '"+xFilial(cAlias)+"' AND "+cCampo+" BETWEEN '"+aResult[nEntid,1]+"' AND '"+aResult[nEntid,2]+"' "
	If lCpoClasse
		cQuery += "AND  "+PrefixoCpo(cAlias)+"_CLASSE = '2' "	
	EndIf 
	If cAlias == 'CV0
		cQuery += " AND CV0_PLANO = '"+cCodEnt+"' "
	EndIf		
				
	If !Empty(aResult[nEntid, 3])

		_cFiltro := PcoParseFil( aResult[nEntid, 3], cAlias )
		
		If !Empty(_cFiltro)		
			cQuery += " AND "+_cFiltro
		Else
			If !MsgYesNo(STR0031)//"Somente serÃ£o aceitas expressÃµes exatas. As expressÃµes 'ContÃ©m a expressÃ£o', 'NÃ£o ContÃ©m', 'Esta Contido em' e 'NÃ£o esta Contido em'  nÃ£o serÃ£o executadas.Prosseguir?"
				Return()  
			EndIf						
		EndIf
				
	EndIf

	cQuery += " AND D_E_L_E_T_ = ' ' ORDER BY 1 "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .T. )

	dbSelectArea(cAliasQry) 
   
	If aMarcados[nEntid] != Nil .And. lBotaoFiltro  	                        
		For nX:=1 To Len(aMarcados[nEntid])
			If aMarcados[nEntid][nX][1]
				lMarcado := .T.
				nX:= Len(aMarcados[nEntid])+1
			EndIf	
		Next nX   
	Else
		aDados := {}		                 
	EndIf	
	
	If lMarcado
		If lSel := MsgYesNo(cDescEntidade + CRLF+ STR0019)  //'Adicionar ao filtro da entidade?'
		Else 	
			aDados := {}
			oTree:ChangePrompt( Alltrim(cDescEntidade) +' ['+cValToChar(0)+']',oTree:GetCargo()) 
			oTree:ChangeBmp("IndicatorCheckBox","IndicatorCheckBox",oTree:GetCargo()) 
		EndIf	
	Else
		aDados := {}			
	EndIf  

	If lMarcado
		oTree:ChangeBmp("IndicatorCheckBoxOver","IndicatorCheckBoxOver",oTree:GetCargo()) 				
	Else
		oTree:ChangeBmp("IndicatorCheckBox","IndicatorCheckBox",oTree:GetCargo()) 
	EndIf

	While (cAliasQry)->(!Eof())
		If lSel 
			If Ascan( aDados, {|y| Alltrim(y[2]) == Alltrim((cAliasQry)->CONTA) }  ) == 0	
				aAdd(aDados, {.F.,(cAliasQry)->CONTA,(cAliasQry)->DESCR} )
			EndIf					
		Else
			aAdd(aDados, {.F.,(cAliasQry)->CONTA,(cAliasQry)->DESCR} )
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	dbSelectArea(cAliasQry)
	dbCloseArea()	                                       
	
	If Empty(aDados)
		AADD(aDados,{.f.,"",""}) 
		ApMsgInfo(STR0020)			
	EndIf   

	aMarcados[nEntid]:= aClone(aDados)

Else
    
	aDados := aClone(aMarcados[nEntid])

EndIf

If Empty(aDados)
	AADD(aDados,{.f.,"",""}) 
	ApMsgInfo(STR0020)			//"NÃ£o localizado registro."
EndIf 

oLstBox:SetArray(aDados)
oLstBox:bLine := { || {If(aDados[oLstBox:nAt][1],oOk,oNo),aDados[oLstBox:nAT][2],aDados[oLstBox:nAT][3]}}
oLstBox:Refresh()  

If lBotaoFiltro
	Processa( {|| A811CUBO(.F.)},STR0021)                 //"Selecionando..."
EndIf	

RestArea(aArea)
Return()  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³MostraLista  ³ Autor ³ TOTVS                 ³ Data ³ 07/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mostra dados no alistbox                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MostraLista(nEntid)
Local aArea	:= GetArea() 

If Empty(aMarcados[nEntid])
	aDados := {.f.,"",""} 
Else
	aDados := aClone(aMarcados[nEntid])	
EndIf                                    

oLstBox:SetArray(aDados)
oLstBox:bLine := { || {If(aDados[oLstBox:nAt][1],oOk,oNo),aDados[oLstBox:nAT][2],aDados[oLstBox:nAT][3]}}
oLstBox:Refresh()  
                        
RestArea(aArea)
Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ MarkList    ³ Autor ³ TOTVS                 ³ Data ³ 07/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marca/Desmarca Visao                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


Static Function MarkList(cTipo,aDados,bPosiciona,oTree)
Local aAreaAtu	:= GetArea()
Local nEntid	:= 0 
Local nCount	:= 0 
Local cDescrEnt	:= "" 
Local nX		:= 0
Local lExtEnt	:= .F.

If Left( oTree:GetCargo(), 3) == 'ZZZ'
	Help( " " , 1 , "MarkList" ,, STR0022 ,3,0)  //"Selecione uma entidade para MARCAR/DESMARCAR."
	RestArea(aAreaAtu)
	Return
EndIf

//Posiciona na tabela CT0
Eval(bPosiciona) 
nEntid	:= Val(CT0->CT0_ID)

lMarkTodos := .F.

If cTipo == 'T1'  
	aEval( aDados, {|x| Iif(x[1],lMarkTodos:=.T.,Nil) } )
	aEval( aDados, {|x| x[1] := !lMarkTodos } )  
ElseIf cTipo == 'T2'  

	aEval( aDados, {|x| Iif(x[1],lMarkTodos:=.T.,Nil) } )
	aEval( aDados, {|x| x[1] := !lMarkTodos } )	
	
ElseIf cTipo == 'L1' 	
	If !Empty(AllTrim(aDados[oLstBox:nAt,2]))
		aDados[oLstBox:nAt,1] := !aDados[oLstBox:nAt,1]
	EndIf	
ElseIf cTipo == 'L2' 	
	For nX := 2 To Len(aCubos[oLstBox2:nAt])
		If !Empty(AllTrim(aCubos[oLstBox2:nAt,nX]))
			lExtEnt := .T.
			Exit
		EndIf
	Next nX

	If lExtEnt
		aCubos[oLstBox2:nAt,1] := !aCubos[oLstBox2:nAt,1]	
	EndIf
EndIf
      
If cTipo $ 'T1.L1'    
	aMarcados[nEntid] := aClone(aDados)            
	aEval( aDados, {|x| Iif(x[1],nCount ++,Nil) } )
	Processa( {|| A811CUBO(.F.)},STR0021)  //"Selecionando..."
EndIf	

If ValType(oTree) == 'O' .And. ( cTipo != 'T2' .And. cTipo != 'L2' )
	cDescrEnt := Alltrim(aDescrEnt[Val(left(oTree:GetPrompt(),2))]) 
	cDescrEnt := Substr(cDescrEnt,1,At("[",cDescrEnt)-1 )	
	oTree:ChangePrompt( cDescrEnt +'['+cValToChar(nCount)+']',oTree:GetCargo()) 
	If nCount == 0
		oTree:ChangeBmp("IndicatorCheckBox","IndicatorCheckBox",oTree:GetCargo()) 
	Else
		oTree:ChangeBmp("IndicatorCheckBoxOver","IndicatorCheckBoxOver",oTree:GetCargo()) 				
	EndIf	
EndIf	

RestArea(aAreaAtu)
Return()   


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ CtbGetConta ³ Autor ³ TOTVS                 ³ Data ³ 07/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ GET cadastro de amarracoes                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function CtbGetConta(oWin02,nOpc) 
Local aAreaAtu	:= GetArea() 

Local cAliasE := 'CTA'
Local aCpoEnch := {'NOUSER','CTA_REGRA','CTA_DESC'}
Local aAlterEnch := {'CTA_DESC'}
Local aIncluEnch := {'CTA_REGRA','CTA_DESC'}
//Local aPos := {000,000,400,600}
Local nModelo := 3
Local lF3 := .F.
Local lMemoria := .T.
Local lColumn := .F.
Local caTela := ""
Local lNoFolder := .F.
Local lProperty := .F.

Private aTELA[0][0]
Private aGETS[0]

oGet := MsMGet():New(cAliasE, /*CTA->(RecNo())*/, nOpc, /*aCRA*/, /*cLetra*/,;
							/*cTexto*/, aCpoEnch, /*aPos*/, IIF(INCLUI, aIncluEnch, aAlterEnch), nModelo, /*nColMens*/,;
							/*cMensagem*/, /*cTudoOk*/,oWin02,lF3,lMemoria,lColumn, caTela,;
							lNoFolder, lProperty)

oGet:oBox:Align := CONTROL_ALIGN_TOP
 
RestArea(aAreaAtu)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ A811CUBO    ³ Autor ³ TOTVS                 ³ Data ³ 07/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seleciona o cruzamento das entidades                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A811Cubo(lMensagem)
Local aAreaAtu	:= GetArea()
Local nX		:= 0
Local aContas	:= ARRAY( Len(aMarcados) ) 
Local cCampos	:= "" 
Local _cAlias	:= ""
Local _cPlano	:= ""
Local _cCodID	:= ""
Local _cCpoChv	:= ""

Local cTabelas	:= "" 
Local cWhere	:= ""
Local cDelete	:= "" 
Local cQry		:= ""
Local cAliasQry	:= "" 
Local _aTitle	:= {}
Local nMarcados	:= 0
Local lMarcados	:= .F.  
Local cInsertSql
Local nY

Default lMensagem := .T.

AFILL(aContas,"")  

//ProcRegua(0)

a811CriaTrb(aMarcados, aRegCT0) //cria arquivos temporarios no banco para conter as entidades selecionadas

For nX:=1 To Len(aMarcados)
	If !Empty(aMarcados[nX]) 
	
		lMarcados	:= .F.

		cInsertSql := ""
		For nY := 1 TO Len(aMarcados[nX])
			If !lMarcados .And. aMarcados[nX][nY][1]
				lMarcados:= .T.  //para montar a query
			EndIf
			_cCpoChv := aRegCT0[nX][4]
			If aMarcados[nX][nY][1] //somente os marcados
				cInsertSql += " Insert Into "+aArqTrb[nX]+" ( "+_cCpoChv+", R_E_C_N_O_ ) Values ( '"+aMarcados[nX][nY][2]+"',"+Str(nY,0) + " ) " + CRLF
//			EndIf
//			If !Empty(cInsertSql) //.And. ( nY == Len(aMarcados[nX]) .OR. Len(cInsertSql) >= 10000 )
				TcSqlExec( cInsertSql )
				TcRefresh( aArqTrb[nX] )
				cInsertSql := ""
			EndIf
		Next
		If lMarcados
			nMarcados ++ 
		EndIf			
               
		_cAlias := aRegCT0[nX][1]
		_cPlano := aRegCT0[nX][2] 
		_cCodID	:= Alltrim(_cAlias)+aRegCT0[nX][3] 
		_cCpoChv:= aRegCT0[nX][4]
		
		_cAlias := If(_cAlias=="CV0", _cAlias+StrZero(nMarcados,2),_cAlias)
		
		If lMarcados
			cCampos += _cAlias+"."+_cCpoChv + " " + _cCodID + "," 
			
			cTabelas+= RetSqlName(_cAlias) +Space(1)+ _cAlias + "," 
			
			cWhere	+=  _cAlias+"."+PrefixoCpo(	Left(_cAlias,3))+"_FILIAL = '"+xFilial( Left(_cAlias,3) )+"' AND "	
			If Left(_cAlias,3) == 'CV0'
				cWhere += " "+_cAlias+"."+"CV0_PLANO = '"+_cPlano+"' AND "
			EndIf		
			
			cWhere 	+= _cAlias+"."+_cCpoChv + " IN ( SELECT "+_cCpoChv+" FROM "+aArqTrb[nX]+" ) AND " 			
			cDelete	+= _cAlias+".D_E_L_E_T_ = ' ' AND "
		EndIf
		
	EndIf		
Next nX  

If nMarcados < 2
	If lMensagem
		ApMsgInfo(STR0023)  //'Selecione mais de uma entidade com marcaÃ§Ã£o para amarraÃ§Ã£o.'
	EndIf		
	aCubos := {}
	aAdd(aCubos, ARRAY(nTotEnt + 1) )
	AFILL( aCubos[len(aCubos)],"" )
	AFILL( aCubos[len(aCubos)],.f.,1,1)		
Else
	// REMOVER A ULTIMA VIRGULA
	cCampos := Substr(cCampos,1,Len(cCampos)-1) 
	cTabelas:= Substr(cTabelas,1,Len(cTabelas)-1)
	// REMOVER O ULTIMO AND
	//cWhere := Substr(cWhere,1,Len(cWhere)-4) 
	cDelete:= Substr(cDelete,1,Len(cDelete)-4) 
	
	cQry += "SELECT " + cCampos + " FROM " + cTabelas + " WHERE " + cWhere + cDelete
	
	cQry := ChangeQuery(cQry)
	
	cAliasQry := GetNextAlias()
	
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cAliasQry, .T., .T. )
	
	dbSelectArea(cAliasQry)
	                       
	aCubos := {}
	While (cAliasQry)->(!Eof()) 
	
//		IncProc()
	
		aAdd(aCubos, ARRAY(nTotEnt + 1) )
		
		AFILL( aCubos[len(aCubos)],"" )
	
		AFILL( aCubos[len(aCubos)],.f.,1,1)	
	
		For nX := 1 TO (cAliasQry)->(FCOUNT())
			aCubos[Len(aCubos)][Val(Right((cAliasQry)->(FieldName(nX)),2))+1] := (cAliasQry)->(FieldGet(nX))		
		Next
	
		(cAliasQry)->(dbSkip())
	
	EndDo 
	
	dbSelectArea(cAliasQry)
	dbCloseArea()     

    a811Trunca()  //trunca as tabelas temporarias criadas no banco

EndIf

oLstBox2:SetArray(aCubos)
oLstBox2:bLine := &(bBlocobLine)
oLstBox2:Refresh()
RestArea(aAreaAtu)

Return 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ A811VldGrava³ Autor ³ TOTVS                 ³ Data ³ 07/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao para gravacao                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A811VldGrava()
Local lRetorno 	:= .F.
Local lSelecao	:= .F.
Local bSelecao	:= ''
Local nX		:= 0 
Local nY		:= 0

For nX:=1 To Len(aCubos)   
	bSelecao	:= '{|| lSelecao := aCubos[nX][1] .And. !Empty('
	For nY:=2 To Len(aCubos[nX]) 
		bSelecao += 'aCubos[nX]['+cValToChar(nY)+']'+Iif(nY<Len(aCubos[nX]),'+','') 
	Next nY
	bSelecao += ')}' 
	eVal( &bSelecao )
	If lSelecao
		nX := Len(aCubos) + 1	
	EndIf
Next nX

If !lSelecao
	ApMsgInfo(STR0024)  //'Nenhum item de amarraÃ§Ã£o selecionado.'
Else
	lRetorno := .T.	
EndIF   

If lRetorno 
	If Empty(M->CTA_REGRA)
		ApMsgInfo(STR0027)  //"CÃ³digo da regra nÃ£o preenchido."
		lRetorno := .F.
	EndIf
EndIf

If lRetorno 
	If Empty(M->CTA_DESC)
		ApMsgInfo(STR0025)  //'DescriÃ§Ã£o nÃ£o preenchida.'
		lRetorno := .F.
	EndIf            
EndIf

Return( lRetorno ) 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ CTBA811Grava³ Autor ³ TOTVS                 ³ Data ³ 07/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


Static Function CTBA811Grava(nOpc)
Local lCtb180Grv := ExistBlock("CTB180Grv")
Local nX		:= 0  
Local ny		:= 0                  
Local cItemRegra:= Replicate('0',TamSx3('CTA_ITREGR')[1])
Local cCodRegra	:= M->CTA_REGRA	//GetSXENum("CTA","CTA_REGRA")
Local lFirst	:= .T.
Local lInclui := .T.

If Select('__CTA') == 0
	CHKFILE('CTA',.F.,'__CTA')	
EndIf

DbSelectArea('__CTA') 
DbSetOrder(1)  

If nOpc == 5 .Or. nOpc == 4		// Exclusao ou Alteracao

	DbSelectArea('__CTA')	
	DbSetOrder(1)
	If DbSeek(xFilial('CTA')+M->CTA_REGRA )	
		While __CTA->(!Eof()) .And. __CTA->CTA_FILIAL == xFilial('CTA') .And. __CTA->CTA_REGRA == M->CTA_REGRA
			RecLock('__CTA',.F.)		
				DbDelete()		                     
			MsUnlock()		     
			__CTA->(DbSkip())
		EndDo
	EndIf
	
EndIF

If nOpc == 3 .Or. nOpc == 4 	// Inclusao ou Alteracao
	lFirst := (nOpc == 3 .And. Val(cItemRegra) == 0)
	For nX:=1 To Len(aCubos)
		If aCubos[nX][01]
			If lFirst
				cItemRegra := StrZero(1, Len(CTA->CTA_ITREGR))
				lInclui    := .F.
				lFirst     := .F.
				__CTA->( dbGoto( CTA->(Recno()) ) )
			Else
				lInclui    := .T.
				cItemRegra := Soma1(cItemRegra)
			EndIf
			RecLock('__CTA',lInclui)
				__CTA->CTA_FILIAL	:= xFilial('CTA')
				__CTA->CTA_REGRA	:= cCodRegra 
				__CTA->CTA_ITREGR	:= cItemRegra
	           	__CTA->CTA_NIVEL	:= "1"             
	           	__CTA->CTA_DESC	:= M->CTA_DESC
	           	For ny:= 1 To Len( aCubos[nX] )
	           		If ny <= Len(aCpoCubos)
	           			If aCpoCubos[ny][01] > 0
							__CTA->&(aCpoCubos[ny][02]):= aCubos[nX][ny]
						EndIf                                          						
					EndIf
				Next ny	           	
			MsUnlock()
		EndIf               
	Next nX  
	
	If nOpc == 3
		ConfirmSx8()
	EndIf
EndIF    
 	If lCtb180Grv
 		ExecBlock("CTB180Grv", .F., .F.,{nOpc})
 	EndIf		                                            

Return() 

CtbRegCt0()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ MenuDef     ³ Autor ³ TOTVS                 ³ Data ³ 07/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/



Static Function MenuDef()

Local aRotina := { 	{OemToAnsi(STR0026)	, "AxPesqui"	, 0 , 1,,.F.},;  	//"Pesquisar"
						{OemToAnsi(STR0004)	, "CTBA811ROT"	, 0 , 2},; 	 		//"Visualizar"
						{OemToAnsi(STR0005)	, "CTBA811ROT"	, 0 , 3},;	  		//"Incluir"
						{OemToAnsi(STR0006)	, "CTBA811ROT"	, 0 , 4},;	  		//"Alterar"
						{OemToAnsi(STR0007)	, "CTBA811ROT"	, 0 , 5} }	  		//"Excluir"
Return(aRotina)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ a811CriaTrb ³ Autor ³ TOTVS                 ³ Data ³ 07/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria arquivos temporarios no banco para conter as entidades   ³±±
±±³          ³ selecionadas                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function a811CriaTrb(aMarcados,aRegCT0)
Local _cAlias
Local _cCpoChv
Local aStruTrb := {}
Local nX

If lCriaTrb == NIL
	For nX:=1 To Len(aMarcados)
		_cAlias  := aRegCT0[nX][1]
		_cCpoChv := aRegCT0[nX][4]
	    aAdd( aArqTrb, CriaTrab(,.F.) )
	    aStruTrb := {}
		aAdd(aStruTrb, { _cCpoChv, "C", Len(&(_cAlias+"->"+_cCpoChv)), 0 } ) 
		MsCreate(aArqTrb[Len(aArqTrb)],aStruTrb, "TOPCONN")
		Sleep(200)
	Next
	lCriaTrb := .T.
EndIf

Return NIL


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ a810Trunca  ³ Autor ³ TOTVS                 ³ Data ³ 07/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Trunca arquivos temporarios no banco para conter entidades    ³±±
±±³          ³ selecionadas                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


Static Function a811Trunca()
Local nX

//trunca as tabelas temporarias criadas no banco
For nX:=1 To Len(aArqTrb)
	TcSqlExec( " TRUNCATE TABLE "+aArqTrb[nX] )
	TcRefresh( aArqTrb[nX] )// commit
Next

Return NIL


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ a811Erase   ³ Autor ³ TOTVS                 ³ Data ³ 07/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclui arquivos temporarios no banco para conter entidades    ³±±
±±³          ³ selecionadas                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function a811Erase()
Local nX

//Exclui as tabelas temporarias criadas no banco
For nX:=1 To Len(aArqTrb)
	MsErase(aArqTrb[nX])
Next

aArqTrb		:= ASIZE(aArqTrb,0)
lCriaTrb 	:= NIL

Return NIL
