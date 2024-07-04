#INCLUDE "QADA015.ch"
#INCLUDE "Protheus.ch" 
#INCLUDE "Folder.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QADA015    ³ Autor ³Telso Carneiro          ³ Data ³11/08/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Transfere os lancamentos Pendentes da Auditoria por Usuario   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QADA015()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QADA015                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/                      

Static Function MenuDef()

Private aRotina  := {}

Aadd(aRotina,{OemToAnsi(STR0002), "AxPesqui" , 0, ,,.F.})  //"Pesquisar"
Aadd(aRotina,{OemToAnsi(STR0003), "QAD015Vis", 0, 2})  //"Visualizar"
Aadd(aRotina,{OemToAnsi(STR0004), "QAD015Atu", 0, 4})  //"Transferir"
Aadd(aRotina,{OemToAnsi(STR0005), "QAD015Cor", 0, 6,,.F.})  //"Legenda"

Return aRotina

Function QADA015()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private cCadastro:= OemtoAnsi(STR0001)   //"Responsáveis/Usuários"
Private lIntGPE  := If(GetMv("MV_QGINT",.F.,"N") == "S",.T.,.F.)
Private cFilMat  := xFilial("QAA")
Private aCores	 := {}
Private lExtQUM	 := ChkFile("QUM")			
Private aRotina  := MenuDef()

If ! ChkFile("QUN")
	Return             
Endif            

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Classifica as cores conforme situacao do Responsavel/Usuario ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCores:=	{{ 'QAD015Led() == 1','ENABLE'    },;
			 { 'QAD015Led() == 2','DISABLE'   },;
			 { 'QAD015Led() == 3','BR_AMARELO'},;
			 { 'QAD015Led() == 4','BR_PRETO'  }}

QUD->(DbSetOrder(1))
QUH->(DbSetOrder(1))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//mBrowse(06,01,22,75,"QAA",,,,,,aCores)

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'QAA' )
oBrowse:SetDescription( cCadastro )  
oBrowse:AddLegend( "Qaxa010Vld(1) == 1", 'ENABLE'    ,"Verde - Normal,sem nenhum lacto de pendencia")		//Verde - Normal,sem nenhum lacto de pendencia
oBrowse:AddLegend( "Qaxa010Vld(2) == 2", 'DISABLE'   ,"Vermelho - Demitido, sem nenhum lacto de pendencia") // Vermelho - Demitido, sem nenhum lacto de pendencia
oBrowse:AddLegend( "Qaxa010Vld(3) == 3", 'BR_AMARELO',"Amarelo - Normal,com lacto de pendencia")  			// Amarelo - Normal,com lacto de pendencia
oBrowse:AddLegend( "Qaxa010Vld(4) == 4", 'BR_AZUL'   ,"Azul - Transferido,com lacto de pendencia")  	    // Azul - Transferido,com lacto de pendencia
oBrowse:AddLegend( "Qaxa010Vld(5) == 5", 'BR_PRETO'  ,"Preta - Demitido, com lacto de pendencia")  	        // Preta - Demitido, com lacto de pendencia
oBrowse:SetFilterDefault( "QAA->QAA_STATUS == '1'" )

//dbSelectArea('QAA') 
//Set Filter To

DbselectArea("QAA")
QAA->(DbSetOrder(1))
//DbClearFilter()
DbSeek(xFilial("QAA"))                                                                     
oBrowse:Activate()

Return(NIL)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QADA015    ³ Autor ³Telso Carneiro          ³ Data ³11/08/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Manutencao dos dados referentes aos Responsaveis          	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QAD015Atu()                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/                      

Function QAD015Atu()

Local oDlg, oQUH, oQUB ,oQUA, oQUM
Local oMarcar, oCombOrd, oUsuarios, oPesq, oChk01
Local lChk01   	:= .T.
Local oOk      	:= LoadBitmap( GetResources(), "LBTIK" )
Local oNo      	:= LoadBitmap( GetResources(), "LBNO" )
Local nOldOrdU 	:= 1
Local cCombOrd 	:= 1
Local nOpcao   	:= 2
Local cMsg     	:= ""
Local cMail    	:= ""
Local aUsrMat	:= QA_USUARIO()
Local cMatFil	:= aUsrMat[2]
Local cMatCod	:= aUsrMat[3]
Local aCombOrd  := {OemToAnsi(STR0006),	OemToAnsi(STR0007),;  //"Matricula"###"Nome"
					 OemToAnsi(STR0008),OemToAnsi(STR0009) }  //"Nome Reduzid"###"Depto"

Local aStAud  	:= {}
Local aStAge  	:= {}
Local lFolQUB 	:= .T.
Local lFolQUH 	:= .T.
Local lFolQUA 	:= .T.
Local lFolQUM 	:= .T.
Local nIc		:= 0
Local cQUB , cQUH , cQUA, cQUM
Local aQUH     	:= {}
Local aQUB     	:= {}        
Local aQUA     	:= {}        
Local aQUM     	:= {}        
Local oPanel1	:= NIL
Local oSize    
Local oSize2
					 
Private cTexto1 	:= QAA->QAA_FILIAL + " - " + QAA->QAA_MAT + " - " + QAA->QAA_NOME
Private oFolder1
Private lMarca 		:= .F.
Private aMsg 		:= {}
Private cMotTransf	:= SPACE(30)
Private aEmails 	:= {}
Private aTitPend	:= {}
Private aPagPend	:= {}
Private aButtons	:= {}
Private lTrava	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega os Lactos Pendentes e de Transferencia QAB           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Processa({|| lTrava:=QAD015Pen(@aQUB,@aQUH,@aQUA,@aQUM)},OemToAnsi(STR0041) ) //"Carregando os lactos pendentes..."

IF !lTrava
	IF MsgYesNo(OemToAnsi(STR0042),OemToAnsi(STR0010))   //"Existem pendencias de Transferência deste usuario, Confirme! Para a realização destas Transferências."###"Atenção"
		cMotTransf:=OemToAnsi(STR0013) // "Transferˆncia de Lançamentos pendentes da(s) Auditoria(s)"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava Tranferenciaa das pendencias     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QAD015Grv(@aQUB,@aQUH,@aQUA,@aQUM)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Limpa os Arrays apos a realizacao de Transferencia QAB      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aEval(aQUB,{|x| x[1]:=.F.,x[Len(x)]:=SPACE(12)}) //Auditor Lider
		aEval(aQUH,{|x| x[1]:=.F.,x[Len(x)]:=SPACE(12)}) //Auditores
		aEval(aQUA,{|x| x[1]:=.F.,x[Len(x)]:=SPACE(12)}) //Agenda Auditor Lider
		aEval(aQUM,{|x| x[1]:=.F.,x[Len(x)]:=SPACE(12)}) //Agenda Auditores
	Endif
Endif                                

IF Len(aQUB) == 0
	lFolQUB:=.F.
Else
	aadd(aTitPend,OemtoAnsi(STR0011)) //"Auditor Lider"
	AaDD(aPagPend,"Lider")
Endif
IF Len(aQUH) == 0
	lFolQUH:=.F.
Else
	AaDD(aTitPend,OemtoAnsi(STR0012)) //"Auditor"
	AaDD(aPagPend,"Audit")
Endif
IF Len(aQUA) == 0
	lFolQUA:=.F.
Else
	AaDD(aTitPend,OemtoAnsi(STR0043)) //"Agendas Auditor Lider"
	AaDD(aPagPend,"AgLider")
Endif
IF lExtQUM
	IF Len(aQUM) == 0
		lFolQUM:=.F.
	Else
		AaDD(aTitPend,OemtoAnsi(STR0044)) //"Agendas Auditor"
		AaDD(aPagPend,"AgAudit")
	Endif
Endif

IF lExtQUM
	If  !lFolQUB .AND. !lFolQUH  .AND. !lFolQUA .AND. !lFolQUM
		Help( " ", 1, "QADNPEND")
		Return Nil
	Endif
Else
	If  !lFolQUB .AND. !lFolQUH  .AND. !lFolQUA
		Help( " ", 1, "QADNPEND")
		Return Nil
	Endif
Endif    
              

AADD(aStAud,{ 'BR_VERDE'   ,OemToAnsi(STR0045)}) //"Sem Resultado"
AADD(aStAud,{ 'BR_AMARELO' ,OemToAnsi(STR0046)}) //"Resultados Parcialmente Respondido"
AADD(aStAud,{ 'BR_PRETO'   ,OemToAnsi(STR0047)}) //"Liberada para Encerramento"

AADD(aStAge,{'BR_VERDE'	   ,OemToAnsi(STR0048)}) //"Agendada"
AADD(aStAge,{'BR_VERMELHO' ,OemToAnsi(STR0049)}) //"Efetivada"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New()

oSize:AddObject( "LABEL"    ,  100, 20, .T., .F. ) // Nao dimensiona Y
oSize:AddObject( "FOLDER"   ,  100, 30, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "BOTAO"    ,  100, 20, .T., .F. ) // Nao dimensiona Y
oSize:AddObject( "LISTBOX"  ,  100, 30, .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  
   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize2 := FwDefSize():New()

oSize2:aWorkArea := oSize:GetNextCallArea( "LABEL" ) 

oSize2:AddObject( "USUARIO"     ,  60, 100, .T., .T.) // Não dimensionavel
oSize2:AddObject( "PENDENCIA"   ,  40, 100, .T., .T.) // Não dimensionavel
  
oSize2:lLateral := .T.            //Calculo em Lateral
oSize2:lProp := .T.               // Proporcional             
oSize2:aMargins := { 3, 3, 0, 0 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize2:Process() // Dispara os calculos  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE OemToAnsi( STR0013 ) ;  //"Transferˆncia de Lançamentos pendentes da(s) Auditoria(s)"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
						
@ oSize2:GetDimension("USUARIO","LININI")  , oSize2:GetDimension("USUARIO","COLINI")   TO oSize2:GetDimension("USUARIO","LINEND"), oSize2:GetDimension("USUARIO","COLEND") LABEL  OemToAnsi(STR0014) OF oDlg PIXEL   //"Usuário"
@ oSize2:GetDimension("USUARIO","LININI")+9, oSize2:GetDimension("USUARIO","LININI")+6 SAY OemToAnsi(cTexto1) SIZE 195,010 OF oDlg PIXEL

@ oSize2:GetDimension("PENDENCIA","LININI")  , oSize2:GetDimension("PENDENCIA","COLINI")     TO oSize2:GetDimension("PENDENCIA","LINEND"), oSize2:GetDimension("PENDENCIA","COLEND")+3 LABEL  OemToAnsi(STR0015) OF oDlg PIXEL   //"Opcao"
@ oSize2:GetDimension("PENDENCIA","LININI")+9, oSize2:GetDimension("PENDENCIA","COLINI")+6 CHECKBOX oChk01 VAR lChk01 SIZE 62,06 OF oDlg PIXEL  ;
			  PROMPT OemToAnsi(STR0016) ;	 //"Todas Pendencias"

@ oSize:GetDimension("FOLDER","LININI"), oSize:GetDimension("FOLDER","COLINI") TO oSize:GetDimension("FOLDER","LINEND"), oSize:GetDimension("FOLDER","COLEND")+3 LABEL  OemToAnsi(STR0017) OF oDlg PIXEL  //"Tipos de Pendencias"

oFolder1 := TFolder():New(oSize:GetDimension("FOLDER","LININI")+10, oSize:GetDimension("FOLDER","COLINI"),aTitPend,aPagPend,oDlg,,,,.T.,.F.,;
					       oSize:GetDimension("FOLDER","XSIZE"), oSize:GetDimension("FOLDER","YSIZE")-13)

IF lFolQUB
	// Folder 1 - Auditor Lider
	@ 001, 002 LISTBOX oQUB VAR cQUB FIELDS HEADER " "," ",;
			Alltrim(TitSx3("QUB_FILIAL")[1]),;
			Alltrim(TitSx3("QUB_NUMAUD")[1]) ;
			SIZE 299,71.8 OF oFolder1:aDialogs[Ascan(aPagPend,"Lider")] PIXEL ;
			ON DBLCLICK (QAD015LCT(oQUB,@aQUB,lChk01,.F.) ,oQUB:Refresh(.T.))			
	oQUB:Align := CONTROL_ALIGN_ALLCLIENT
	oQUB:SetArray(aQUB)
	oQUB:cToolTip:= OemToAnsi(STR0018) //"Duplo click para << MARCAR/DESMARCAR >> Pendˆncia"
	oQUB:bLine   := {|| {IF(aQUB[oQUB:nAt,1],oOK,oNo),LoadBitmap( GetResources(),aStAud[aQUB[oQUB:nAt,2],1]),aQUB[oQUB:nAt,3],aQUB[oQUB:nAt,4]}  }
Endif

IF lFolQUH
	// Folder 2 - Auditores
	@ 001, 002 LISTBOX oQUH VAR cQUH FIELDS HEADER " "," ",Alltrim(TitSx3("QUB_FILIAL")[1]),;
							Alltrim(TitSx3("QUD_NUMAUD" )[1]),;
							Alltrim(TitSx3("QUH_DESTIN")[1]),;
							Alltrim(TitSx3("QUD_CHKLST")[1]),;
							Alltrim(TitSx3("QUD_REVIS")[1]),;
							Alltrim(TitSx3("QUD_CHKITE" )[1]) ;
							SIZE 299,71.8 OF oFolder1:aDialogs[Ascan(aPagPend,"Audit")] PIXEL ;
							ON DBLCLICK (QAD015LCT(oQUH,@aQUH,lChk01,.F.) ,oQUH:Refresh(.T.))
	oQUH:Align := CONTROL_ALIGN_ALLCLIENT					
	oQUH:SetArray(aQUH)
	oQUH:cToolTip := OemToAnsi(STR0018	)  //"Duplo click para << MARCAR/DESMARCAR >> Pendˆncia"
	oQUH:bLine    := {|| {IF(aQUH[oQUH:nAt,1],oOK,oNo),LoadBitmap( GetResources(),aStAud[aQUH[oQUH:nAt,2],1]),aQUH[oQUH:nAt,3],aQUH[oQUH:nAt,4],aQUH[oQUH:nAt,5],aQUH[oQUH:nAt,6],aQUH[oQUH:nAt,7],aQUH[oQUH:nAt,8]}}
ENDIF

IF lFolQUA
	// Folder 3 - Agenda de Auditor Lider
	@ 001, 002 LISTBOX oQUA VAR cQUA FIELDS HEADER " "," ",;
			Alltrim(TitSx3("QUA_FILIAL")[1]),;
			Alltrim(TitSx3("QUA_NUMAUD")[1]) ;
			SIZE 299,71.8 OF oFolder1:aDialogs[Ascan(aPagPend,"AgLider")] PIXEL ;
			ON DBLCLICK (QAD015LCT(oQUA,@aQUA,lChk01,.F.) ,oQUA:Refresh(.T.))
	oQUA:Align := CONTROL_ALIGN_ALLCLIENT			
	oQUA:SetArray(aQUA)
	oQUA:cToolTip:= OemToAnsi(STR0018) //"Duplo click para << MARCAR/DESMARCAR >> Pendˆncia"
	oQUA:bLine   := {|| {IF(aQUA[oQUA:nAt,1],oOK,oNo),LoadBitmap( GetResources(),aStAge[aQUA[oQUA:nAt,2],1]),aQUA[oQUA:nAt,3],aQUA[oQUA:nAt,4]}  }
ENDIF

IF lExtQUM .AND. lFolQUM
	// Folder 4 - Agenda de Auditores
	@ 001, 002 LISTBOX oQUM VAR cQUM FIELDS HEADER " "," ",;
			Alltrim(TitSx3("QUM_FILIAL")[1]),;
			Alltrim(TitSx3("QUM_NUMAUD")[1]),;                
			Alltrim(TitSx3("QUM_DESTIN")[1]);
			SIZE 299,71.8 OF oFolder1:aDialogs[Ascan(aPagPend,"AgAudit")] PIXEL  ;
			ON DBLCLICK (QAD015LCT(oQUM,@aQUM,lChk01,.F.) ,oQUM:Refresh(.T.))
	oQUM:Align := CONTROL_ALIGN_ALLCLIENT			
	oQUM:SetArray(aQUM)
	oQUM:cToolTip:= OemToAnsi(STR0018) //"Duplo click para << MARCAR/DESMARCAR >> Pendˆncia"
	oQUM:bLine   := {|| {IF(aQUM[oQUM:nAt,1],oOK,oNo),LoadBitmap( GetResources(),aStAge[aQUM[oQUM:nAt,2],1]),aQUM[oQUM:nAt,3],aQUM[oQUM:nAt,4],aQUM[oQUM:nAt,5]}  }
Endif

@ oSize:GetDimension("BOTAO","LININI")+3, oSize:GetDimension("BOTAO","COLINI") BUTTON oPesq   PROMPT OemToAnsi(STR0019) ;	//"Pesquisar Usuário"
			  ACTION ( If(QAD015PUS()== .F.,QAA->(dbGoTop()),"") ,;
						If( oCombOrd:nAt == 1 .And. QAA->(IndexOrd()) <> 1, QAA->(dbSetOrder(1)),;
						If( oCombOrd:nAt == 2 .And. QAA->(IndexOrd()) <> 3, QAA->(dbSetOrder(3)),;
						If( oCombOrd:nAt == 3 .And. QAA->(IndexOrd()) <> 6, QAA->(dbSetOrder(6)),;
						If( oCombOrd:nAt == 4 .And. QAA->(IndexOrd()) <> 5, QAA->(dbSetOrder(5)),"")))), ;
			  			nOldOrdU := oCombOrd:nAt,oUsuarios:UpsTable(),oUsuarios:Refresh() ) ;
			  SIZE 53,12 PIXEL OF oDlg			

@ oSize:GetDimension("BOTAO","LININI")+3, oSize:GetDimension("BOTAO","COLINI")+57  BUTTON oMarcar PROMPT OemToAnsi(STR0020) SIZE 135,12 PIXEL OF oDlg ;  //"<< MARCAR/DESMARCAR USUÁRIOS >>"
			ACTION QAD015BUT(@oQUB,@aQUB,@oQUH,@aQUH,@oQUA,@aQUA,@oQUM,@aQUM,oFolder1:nOption,lChk01)

@ oSize:GetDimension("BOTAO","LININI")+3, oSize:GetDimension("BOTAO","COLINI")+197  SAY OemToAnsi(STR0021) SIZE 55,010 OF oDlg PIXEL  //"Ordena‡„o Usuários:"
@ oSize:GetDimension("BOTAO","LININI")+3, oSize:GetDimension("BOTAO","COLINI")+253  COMBOBOX oCombOrd VAR cCombOrd ITEMS aCombOrd SIZE 58,70 PIXEL OF oDlg ;
			  ON CHANGE If( nOldOrdU <> oCombOrd:nAt,;
			  				(nOldOrdU := oCombOrd:nAt,;
							If( oCombOrd:nAt == 1, QAA->(dbSetOrder(1)) ,;
							If( oCombOrd:nAt == 2, QAA->(dbSetOrder(3)) ,;
							If( oCombOrd:nAt == 3, QAA->(dbSetOrder(6)) ,;
							                       QAA->(dbSetOrder(5)) ))) ,;
						   oUsuarios:UpsTable(),oUsuarios:Refresh() ) ,"")						   
  				
@ oSize:GetDimension("LISTBOX","LININI")  , oSize:GetDimension("LISTBOX","COLINI") TO;
	 oSize:GetDimension("LISTBOX","LINEND"),oSize:GetDimension("LISTBOX","COLEND")+3 LABEL  OemToAnsi(STR0022) OF oDlg PIXEL  //"Usuários Destinos"

@ oSize:GetDimension("LISTBOX","LININI")+7,  oSize:GetDimension("LISTBOX","COLINI")+3  LISTBOX oUsuarios VAR cUsr;
			  FIELDS QAA->QAA_FILIAL,QAA->QAA_MAT,QAA->QAA_NOME,QAA->QAA_APELID,QAA->QAA_CC+"-"+QA_NDEPT(QAA->QAA_CC,.F.,QAA->QAA_FILIAL) ;
			  HEADER OemToAnsi(STR0023),OemToAnsi(STR0024),OemToAnsi(STR0007),OemToAnsi(STR0008),OemToAnsi(STR0009) ;	 //"Fil"###"C¢digo"###"Nome"###"Nome Reduzid"###"Depto"
			  ALIAS "QAA" ;
			  SIZE oSize:GetDimension("LISTBOX","XSIZE")-3,oSize:GetDimension("LISTBOX","YSIZE")-8 PIXEL ;
			  OF oDlg


oUsuarios:GoTop()
oUsuarios:UpStable()
oUsuarios:Refresh()

aAdd(aButtons,{"NOTE", {|| QAD015Leg(aStAud,aStAge,oFolder1:nOption)} , OemToAnsi( STR0005 ) } )    //"Legenda"


ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,;
										{|| IF( QAD015FIM(aClone(aQUB),aClone(aQUH),aClone(aQUA),aClone(aQUM),oDlg),(nOpcao:=1,oDlg:End()),)},; 
										{||(nOpcao:=2,oDlg:End())},,aButtons) 

If nOpcao == 1	// OK
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Tranferenciaa das pendencias     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QAD015Grv(@aQUB,@aQUH,@aQUA,@aQUM)	
Endif

If __lSX8
	If nOpcao == 1
	   	ConfirmSX8()		
	Else
		RollBackSX8()
	Endif
Endif

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QAD015FIM ºAutor  ³Telso Carneiro      º Data ³  13/09/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica e Libera a Transferência                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QADA015()                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function QAD015FIM(alQUB,alQUH,alQUA,alQUM,oDlg)
Local lRet	:=.F.
Local nI 	:= 0
Local oDlgC
Local aCof	:= {}
Local oCof
Local cCof
Local cFilDe	:= ""
Local cMatDe	:= ""
Local cFilPara	:= ""
Local cMatPara	:= ""
Local lTemQUB	:= .F.
Local lTemQUH	:= .F.
Local lTemQUA	:= .F.
Local lTemQUM	:= .F.

For nI := 1 to Len(alQUB)
	IF alQUB[nI,1]
		lTemQUB:=.T.
		Exit			
	Endif	
Next   
For nI := 1 to Len(alQUH)
	IF alQUH[nI,1]
		lTemQUH:=.T.
		Exit			
	Endif	
Next   
For nI := 1 to Len(alQUA)
	IF alQUA[nI,1]
		lTemQUA:=.T.
		Exit			
	Endif	
Next   
For nI := 1 to Len(alQUM)
	IF alQUM[nI,1]
		lTemQUM:=.T.
		Exit			
	Endif	
Next   

IF lTemQUB .OR. lTemQUH .OR. lTemQUA .OR. lTemQUM
	IF lTemQUB
		For nI :=1 TO Len(alQUB)
			If (alQUB[nI,1])
				QUB->(dbGoTo(alQUB[nI,5])) //Recno
				cFilDe:= QUB->QUB_FILMAT
				cMatDe:= QUB->QUB_AUDLID
				cFilPara:= SubStr(alQUB[nI,Len(alQUB[nI])],1,FWSizeFilial())
				cMatPara:= SubStr(alQUB[nI,Len(alQUB[nI])],FWSizeFilial()+1,len(QUB->QUB_AUDLID))
				
				AADD(aCof,{aTitPend[Ascan(aPagPend,"Lider")] ,;
				alQUB[nI,3],; //Filial
				alQUB[nI,4],; // Codigo Auditoria
				cFilDe+"-"+cMatDe+" "+QA_NUSR(cFilDe,cMatDe),; 			//DE
				cFilPara+"-"+cMatPara+" "+QA_NUSR(cFilPara,cMatPara)}) //PARA
			Endif
		Next
	Endif
	IF lTemQUH
		For nI :=1 TO Len(alQUH)
			If (alQUH[nI,1])
				QUH->(dbGoTo(alQUH[nI,9])) //Recno
				cFilDe:= QUH->QUH_FILMAT
				cMatDe:= QUH->QUH_CODAUD
				cFilPara:= SubStr(alQUH[nI,Len(alQUH[nI])],1,FWSizeFilial())
				cMatPara:= SubStr(alQUH[nI,Len(alQUH[nI])],FWSizeFilial()+1,len(QUH->QUH_CODAUD))
				
				AADD(aCof,{aTitPend[Ascan(aPagPend,"Audit")],;
				alQUH[nI,3],; //Filial
				alQUH[nI,4],; // Codigo Auditoria
				cFilDe+"-"+cMatDe+" "+QA_NUSR(cFilDe,cMatDe),; 			//DE
				cFilPara+"-"+cMatPara+" "+QA_NUSR(cFilPara,cMatPara)}) //PARA
			Endif
		Next
	Endif
	IF lTemQUA
		For nI :=1 TO Len(alQUA)
			If (alQUA[nI,1])
				
				QUA->(dbGoTo(alQUA[nI,5])) //Recno
				cFilDe:= QUA->QUA_FILMAT
				cMatDe:= QUA->QUA_MAT
				cFilPara:= SubStr(alQUA[nI,Len(alQUA[nI])],1,FWSizeFilial())
				cMatPara:= SubStr(alQUA[nI,Len(alQUA[nI])],FWSizeFilial()+1,len(QUA->QUA_MAT))
				
				AADD(aCof,{aTitPend[Ascan(aPagPend,"AgLider")],;
				alQUA[nI,3],; //Filial
				alQUA[nI,4],; // Codigo Agenda
				cFilDe+"-"+cMatDe+" "+QA_NUSR(cFilDe,cMatDe),; 			//DE
				cFilPara+"-"+cMatPara+" "+QA_NUSR(cFilPara,cMatPara)}) //PARA
			Endif
		Next
	Endif
	
	IF lTemQUM
		For nI :=1 TO Len(alQUM)
			If (alQUM[nI,1])
				QUM->(dbGoTo(alQUM[nI,6]))  //Recno
				cFilDe:= QUM->QUM_FILMAT
				cMatDe:= QUM->QUM_CODAUD
				
				cFilPara:= SubStr(alQUM[nI,Len(alQUM[nI])],1,FWSizeFilial())
				cMatPara:= SubStr(alQUM[nI,Len(alQUM[nI])],FWSizeFilial()+1,len(QUM->QUM_CODAUD))
				
				AADD(aCof,{aTitPend[Ascan(aPagPend,"AgAudit")],;
				alQUM[nI,3],; //Filial
				alQUM[nI,4],; // Codigo Agenda
				cFilDe+"-"+cMatDe+" "+QA_NUSR(cFilDe,cMatDe),; 			//DE
				cFilPara+"-"+cMatPara+" "+QA_NUSR(cFilPara,cMatPara)}) //PARA
			Endif
		Next
	Endif
	
	DEFINE MSDIALOG oDlgC TITLE OemToAnsi("Confirmação de Transferências") FROM 9,0 TO 40,100
	
	@015, 002 LISTBOX oCof VAR cCof FIELDS HEADER ;
		OemToAnsi(STR0017),; //"Tipos de Pendencias"
		OemToAnsi(STR0023),; //"Fil"
		OemToAnsi(STR0024),; //"C¢digo"
		OemToAnsi(STR0039),; //"Transferências realizadas (DE): "
		OemToAnsi(STR0040);  //"Transferências realizadas (PARA): "
		COLSIZES GetTextWidth(0,OemToAnsi(STR0017)),;
		         GetTextWidth(0,OemToAnsi(STR0023)),;
		         GetTextWidth(0,OemToAnsi(STR0024)),;
		         GetTextWidth(0,OemToAnsi(STR0039)),;
		         GetTextWidth(0,OemToAnsi(STR0040));
	    SIZE 392,218 OF oDlgC PIXEL
	
	oCof:SetArray(aCof)
	oCof:bLine := {|| aCof[oCof:nAt] }
	oCof:Align := CONTROL_ALIGN_ALLCLIENT
	
	ACTIVATE MSDIALOG oDlgC CENTERED ON INIT EnchoiceBar(oDlgC,{|| lRet:=.T.,oDlgC:End()},{|| lRet:= .F.,oDlgC:End()} )
	
	IF lRet
		lRet:= MsgYesNo(OemToAnsi(STR0025),OemToAnsi(STR0010)) .And. QAD050Jus(oDlg)  //"Confirma Transferencia de Lancamentos Pendentes ?"###"Atencao"
	Endif
Endif


Return(lRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QAD015BUT ºAutor  ³Telso Carneiro      º Data ³ 12/08/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza ponteiro de usuarios                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³QAD015BUT(oBJ1,Array1,oBJ2,Array2,oBJ3,Array3,oBJ4,Array4,  º±±
±±º          ³	NFolder,lCheck)                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QAD015BUT(oQUB,aQUB,oQUH,aQUH,oQUA,aQUA,oQUM,aQUM,nFolderItem,lChk01)

Local cPaginas:= aPagPend[nFolderItem]

If QAA->QAA_STATUS <> "2"
	DO CASE
		CASE cPaginas=="Lider"
			QAD015LCT(oQUB,@aQUB,lChk01,.T.) // Auditor Lider
			oQUB:Refresh()
		CASE cPaginas=="Audit"
			QAD015LCT(oQUH,@aQUH,lChk01,.T.) // Auditores
			oQUH:Refresh()
		CASE cPaginas=="AgLider"
			QAD015LCT(oQUA,@aQUA,lChk01,.T.) // Agenda Auditor Lider
			oQUA:Refresh()
		CASE cPaginas=="AgAudit"
			QAD015LCT(oQUM,@aQUM,lChk01,.T.) // Agenda Auditores
			oQUM:Refresh()
	EndCASE
Else
	Help( " ", 1,"USRINATIVO" )
Endif


Return Nil                       

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QAD015LCT  ³ Autor ³ Telso Carneiro      ³ Data ³12/08/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza ponteiro de usuarios                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³QAD015LCT(oArray,aArray,lChk01,lButton)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oUsuarios= Objeto contendo os Usuarios                     ³±±
±±³          ³ cChave   = Caracter contendo a chave de pesquisa de usuario³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QAD015LCT(oArray,aArray,lChk01,lButton)

Local nArray := 0

IF QAA->QAA_STATUS =="2"
	Help( " ", 1,"USRINATIVO" )
	Return Nil
Endif

If cTexto1 == QAA->QAA_FILIAL + " - " + QAA->QAA_MAT + " - " + QAA->QAA_NOME
	Help(" ",1,"QADUSRTRF") //Usuário não pode Transferir ele mesmo.
	Return Nil
Endif

IF QAA->QAA_AUDIT <> "1"
	Msgalert(OemtoAnsi(STR0026)) //"Usuário escolhido não está autorizado como Auditor"
	Return Nil
Endif

If Len(aArray) > 0  .And. !Empty(aArray[oArray:nAt,2])
	If lChk01 .And. lButton
		lMarca := !lMarca
		For nArray := 1 to Len(aArray)
			aArray[nArray,1] := lMarca
			If lMarca
				aArray[nArray,Len(aArray[nArray])] := QAA->QAA_FILIAL+QAA->QAA_MAT
			Else
				aArray[nArray,Len(aArray[nArray])] := Space(12)
			Endif
		Next
	Else
		aArray[oArray:nAt,1] := !(aArray[oArray:nAt,1])
		If aArray[oArray:nAt,1] == .T.
			aArray[oArray:nAt,Len(aArray[oArray:nAt])] := QAA->QAA_FILIAL+QAA->QAA_MAT
		Else
			aArray[oArray:nAt,Len(aArray[oArray:nAt])] := Space(12)
		Endif
	Endif
Endif

Return Nil



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QAD050Jus  ³ Autor ³Telso Carneiro        ³ Data ³13/09/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Tela de Justificativa (Motivo)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QAD050Jus(oDlg) 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QADA015()                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QAD050Jus(oDlg)

Local oMotTransf
Local lGrava	:= .F.
Local oDlgTransf

DEFINE MSDIALOG oDlgTransf TITLE OemToAnsi(STR0027) FROM 150,000 TO 230,280 OF oDlg PIXEL //"Motivo da Transferência"

@ 005,005 MSGET oMotTransf VAR cMotTransf SIZE 130,010 OF oDlgTransf PIXEL

DEFINE SBUTTON FROM 021,075 TYPE 1 ENABLE OF oDlgTransf;
ACTION  (If(NaoVazio(cMotTransf),(lGrava := .T.,oDlgTransf:End()),));

DEFINE SBUTTON FROM 021,105 TYPE 2 ENABLE OF oDlgTransf;
ACTION  (lGrava := .F.,oDlgTransf:end());

ACTIVATE MSDIALOG oDlgTransf CENTERED

Return lGrava


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QAD015Log  ³ Autor ³Telso Carneiro        ³ Data ³10/09/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Grava Log da Transferência                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QAD015Log(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5,ExpC6,ExpC7,ExpC8,  ³±±
±±³          ³            ExpC9,ExpC10)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ExpC1  - Filial da Auditoria                                ³±±
±±³          ³ExpC2  - Codigo da Auditoria                                ³±±
±±³          ³ExpC3  - Seq/Area da Auditoria                              ³±±
±±³          ³ExpC4  - Area Auditada/Destino                              ³±±
±±³          ³ExpC5  - Check-List                      					  ³±±
±±³          ³ExpC6  - Revisao do Check-List                   			  ³±±
±±³          ³ExpC7  - Tipo de Pendencia	                              ³±±
±±³          ³ExpC8  - Sequencia da Transferencia                         ³±±
±±³          ³ExpC9  - Motivo da Transferencia		                      ³±±
±±³          ³ExpC10 - Filial De										  ³±±
±±³          ³ExpC11 - Matricula De										  ³±±
±±³          ³ExpC12 - Filial Para										  ³±±
±±³          ³ExpC13 - Matricula Para									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QAXA010()                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QAD015Log(cNumAud,cSeq,cDestin,cChklst,cRevis,cTpPend,;
						  cSeqTrf,cMotTransf,cFilDe,cMatDe,cFilPara,cMatPara)

Local aArea 	:= GetArea()
Local aUsrMat	:= QA_USUARIO()
Local cMatFil	:= aUsrMat[2]
Local cMatCod	:= aUsrMat[3]
Local cSubject	:= ""

Default cSeq	:= ""
Default cDestin	:= ""
Default cChklst	:= ""
Default cRevis	:= ""

QAA->(DbSetOrder(1))

DbSelectArea("QUN")
DbSetOrder(1)

RecLock("QUN",.T.)
QUN->QUN_FILIAL:= xFilial("QUN")
QUN->QUN_NUMAUD:= cNumAud
QUN->QUN_SEQ   := cSeq
QUN->QUN_DESTIN:= cDestin
QUN->QUN_CHKLST:= cChklst
QUN->QUN_REVIS := cRevis
QUN->QUN_DTTRAN:= dDataBase
QUN->QUN_SEQTRF:= cSeqTrf
QUN->QUN_TPPEND:= cTpPend   		//1-Auditor Lider 2-Auditor 3-Agenda Auditor Lider 4-Agenda Auditor
QUN->QUN_MOTIVO:= cMotTransf
QUN->QUN_FILRES:= cMatFil
QUN->QUN_MATRES:= cMatCod
QUN->QUN_FILDE := cFilDe
QUN->QUN_MATDE := cMatDe
QUN->QUN_FILPAR:= cFilPara
QUN->QUN_MATPAR:= cMatPara
MsUnlock()
FKCommit()

If QAA->(dbSeek(cFilPara  + cMatPara )) .And. QAA->QAA_RECMAI == "1"
	cMail := AllTrim(QAA->QAA_EMAIL)
	
	If !Empty(cMail)
	    DO CASE
		CASE cTpPend == "1"
			cSubject:=OemToAnsi(STR0028) //"Transferência de Liderença da Auditoria"
		CASE cTpPend == "2"
			cSubject:=OemToAnsi(STR0029) //"Transferência de Auditores"
		CASE cTpPend == "3"
			cSubject:=OemToAnsi(STR0050) //"Transferência da Agenda de Liderença da Auditoria"
		CASE cTpPend == "4"
			cSubject:=OemToAnsi(STR0051) //"Transferência da Agenda de Auditores"
		EndCase
		
		aAdd(aEmails,{cMail,cSubject,Q015AudMail(cSubject,cTpPend,QAA->QAA_TPMAIL,cFilDe,cMatDe,cFilPara,cMatPara),""})
	Endif
Endif

RestaRea(aArea)
Return 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Q015AudMail³ Autor ³ Telso Carneiro       ³ Data ³13/08/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta email da Transf Auditoria em Html                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QADA015                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Q015AudMail(cSubject,cTipo,cTpMail,cFilDe,cMatDe,cFilPara,cMatPara)

Local aUsrMat 	:= QA_USUARIO()
Local cMatFil 	:= aUsrMat[2]
Local cMatCod 	:= aUsrMat[3]
Local cMatDep 	:= aUsrMat[4]
Local cMsg		:= ""

If cTpMail == "1"
	cTpMail:= "1" // HTML
Else
	cTpMail:= "2" // TEXTO
EndIf

If cTpMail == "1"
	cMsg:= '<HTML>'
	cMsg+= '  <TITLE>SIGAQAD</TITLE>'
	cMsg+= '<BODY>'
	
	cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
	cMsg+= '  <TR><TD borderColor=#0099cc borderColorLight=#0099cc align=left width=606 '
	cMsg+= '    bgColor=#0099cc borderColorDark=#0099cc height=1>'
	cMsg+= '    <P align=center><FONT face="Courier New" color=#ffffff size=4>'
	cMsg+= '    <B>'+OemToAnsi(STR0030)+'</B></FONT></P></TD></TR>' //"MENSAGEM"
	cMsg+= '  <TR><TD align=left width=606 height=32>'
	cMsg+= '    <P align=Center>'+cSubject+'</P></TD></TR>'
	cMsg+= '</TABLE><BR>'
	
	cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
	cMsg+= '  <TR><TD borderColor=#0099cc borderColorLight=#0099cc align=left width=606 '
	cMsg+= '    bgColor=#0099cc borderColorDark=#0099cc height=1>'
	cMsg+= '    <P align=center><font face="Courier New" color="#ffffff" size="4"><b>'+OemToAnsi(STR0031)+'</b></font></P></TD></TR>' //"AUDITORIA"
	cMsg+= '</TABLE>'
	
	cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
	cMsg+= '  <TR><TD align=left width=77 height=32><b>'
	IF cTipo == "1" .OR. cTipo == "2"
		cMsg+= RetTitle("QUB_NUMAUD")
	ElseIF cTipo == "3" .OR. cTipo == "4"	
		cMsg+= OemToAnsi(STR0052) //"Agenda "
	Endif
	cMsg+='</b><br>'+QUN->QUN_NUMAUD+'</TD>' // Auditoria
	cMsg+= '</TABLE>'
	
	cMsg+= '&nbsp;'
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Auditores         				             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
	cMsg+= '  <TR><TD borderColor=#0099cc borderColorLight=#0099cc align=left width=606 '
	cMsg+= '    bgColor=#0099cc borderColorDark=#0099cc height=1>'
	cMsg+= '    <p align="center"><font face="Courier New" color="#ffffff" size="4"><b>'+Upper(OemToAnsi(STR0032))+'</b></font></TD></TR>' //"AUDITORES"
	cMsg+= '</TABLE>'
	
	cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
	cMsg+= '  <tr><TD align=left width=100% height=32><B>'+OemToAnsi(STR0033)+'</B>  '+cFilDE+'-'+cMatDE+' '+QA_NUSR(cFilDE,cMatDE)+'</TD></tr>'        	//"De:   "
	cMsg+= '  <tr><TD align=left width=100% height=32><B>'+OemToAnsi(STR0034)+'</B>  '+cFilPara+'-'+cMatPara+' '+QA_NUSR(cFilPara,cMatPara)+'</TD></tr>'  //"Para: "
	cMsg+= '</TABLE>'
	
	cMsg+= '&nbsp;'
	
	IF cTipo == "2"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Areas Auditadas   				             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cMsg+= '&nbsp;'
		cMsg+= '<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border="1">'
		cMsg+= '  <tbody>'
		cMsg+= '    <tr>'
		cMsg+= '      <td borderColor="#0099cc" borderColorLight="#0099cc" align="left" width="606" bgColor="#0099cc" borderColorDark="#0099cc" height="1">'
		cMsg+= '        <p align="center"><font face="Courier New" color="#ffffff" size="4"><b>'+Upper(OemToAnsi(STR0035))+'</b></font></p>' //"AREAS AUDITADAS"
		cMsg+= '      </td>'
		cMsg+= '    </tr>'
		cMsg+= '  </tbody>'
		cMsg+= '</table>'
		cMsg+= '<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border="1">'
		cMsg+= '  <tbody>'
		cMsg+= '    <tr>'
		cMsg+= '      <td align="left" width="286" height="32"><b>'+QUN->QUN_DESTIN+'<b></td> '
		cMsg+= '    </tr>'
		cMsg+= '  </tbody>'
		cMsg+= '</table>'
		
		cMsg+= '&nbsp;'
	Endif
	
	
	cMsg+= '<p>'+OemToAnsi(STR0036) //"Atenciosamente,"
	cMsg+= '<BR>'+QA_NUSR(cMatFil,cMatCod)
	cMsg+= '<BR>'+QA_NDEPT(cMatDep,.T.,cMatFil)+'<BR></p>'
	cMsg+= '<p><FONT size=2><EM>'+OemToAnsi(STR0037)+'</EM></FONT></p>' //"Mensagem gerada automaticamente pelo Sistema SIGAQAD - Controle de Auditorias"
	cMsg+= '</BODY>'
	cMsg+= '</HTML>'
	
ElseIf cTpMail == "2"
	
	cMsg:= cSubject+CHR(13)+CHR(10)+CHR(13)+CHR(10)             
	IF cTipo == "1" .OR. cTipo == "2"
		cMsg+= RetTitle("QUB_NUMAUD")+CHR(13)+CHR(10)+CHR(13)+CHR(10)
	ElseIF cTipo == "3" .OR. cTipo == "4"	
		cMsg+= OemToAnsi(STR0052)+CHR(13)+CHR(10)+CHR(13)+CHR(10) //"Agenda "
	Endif	
	cMsg+= RetTitle("QUB_NUMAUD")+": "+QUN->QUN_NUMAUD+CHR(13)+CHR(10)
	cMsg+= CHR(13)+CHR(10)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Auditores         				             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMsg+= OemToAnsi(STR0012)+" "+OemToAnsi(STR0033)+QA_NUSR(cFilDe,cMatDe)+CHR(13)+CHR(10) //"Auditor"###"De:   "
	cMsg+= OemToAnsi(STR0012)+" "+OemToAnsi(STR0034)+QA_NUSR(cFilPara,cMatPara)+CHR(13)+CHR(10) //"Auditor"###"Para: "
	cMsg+= CHR(13)+CHR(10)
	
	IF cTipo == "2"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Areas Auditadas   				             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cMsg+= Upper(OemToAnsi(STR0035))+CHR(13)+CHR(10)+CHR(13)+CHR(10) //"AREAS AUDITADAS"
		cMsg+= QUN->QUN_DESTIN+CHR(13)+CHR(10)
		cMsg+= CHR(13)+CHR(10)
	Endif
	
	cMsg+= OemToAnsi( STR0036)+CHR(13)+CHR(10) //"Atenciosamente,"
	cMsg+= QA_NUSR(cMatFil,cMatCod)+CHR(13)+CHR(10)
	cMsg+= QA_NDEPT(cMatDep,.T.,cMatFil)+CHR(13)+CHR(10)+CHR(13)+CHR(10)
	cMsg+= OemToAnsi(STR0037) //"Mensagem gerada automaticamente pelo Sistema SIGAQAD - Controle de Auditorias"
EndIf

Return cMsg


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QAD015Vis ºAutor  ³Telso Carneiro      º Data ³  14/09/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡ao ³ Visualiza Log de Transferencia (Historico)                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QADA015                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function QAD015Vis()

Local nOpca
Local oDlgR
Local cCpoGrv
Local nX
Local aColsDE := {}
Local aColsPA := {}
Local aHeadDE := {}
Local aHeadPA := {}
Local lZeroDE := .F.
Local lZeroPA := .F.

Private oGetDE
Private oGetPA


//Montando o aHeader e aCols do Responsavel "DE"
dbSelectArea("QUN")
dbSetOrder(1)
If !dbSeek(xFilial("QUN")+QAA->QAA_FILIAL+QAA->QAA_MAT)
	lZeroDe := .T.
EndIf

cSeek  := QUN->QUN_FILIAL+QUN->QUN_FILDE+QUN->QUN_MATDE
cWhile := "QUN->QUN_FILIAL+QUN->QUN_FILDE+QUN->QUN_MATDE"

  FillGetDados(  2  ,"QUN",1     ,cSeek ,{|| &cWhile},         ,         ,          ,        ,      ,        ,       ,          ,        ,          ,           ,            ,)
//FillGetDados(nOpcX,Alias ,nOrdem,cSeek  ,bSeekWhile  ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry

aColsDE := aClone(aCols)
aHeadDE := aClone(aHeader)

//Zerando o aHeader e aAcols para montar o responsável "PARA"
aCols   := {}
aHeader := {}

//Montando o aHeader e aCols do Responsavel "PARA"
dbSelectArea("QUN")
dbSetOrder(2)
If !dbSeek(xFilial("QUN")+QAA->QAA_FILIAL+QAA->QAA_MAT)
	lZeroPA := .T.
EndIf

cSeek  := QUN->QUN_FILIAL+QUN->QUN_FILPAR+QUN->QUN_MATPAR
cWhile := "QUN->QUN_FILIAL+QUN->QUN_FILPAR+QUN->QUN_MATPAR"

  FillGetDados(  2  ,"QUN",2     ,cSeek ,{|| &cWhile},         ,         ,          ,        ,      ,        ,       ,          ,        ,          ,           ,            ,)
//FillGetDados(nOpcX,Alias ,nOrdem,cSeek  ,bSeekWhile  ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry

aColsPA := aClone(aCols)
aHeadPA := aClone(aHeader)

IF lZeroDE .And. lZeroPA
	Help( " ", 1, "QADNPEND")
	Return(Nil)
Endif

dbSelectArea("QUN")
dbSetOrder(3)  //FILIAL+DATA+SEQ

DEFINE MSDIALOG oDlgR TITLE OemToAnsi(STR0038) FROM 9,0 TO 40,100  //"Historico de Transferências das Pendencias de Auditorias"

RegToMemory("QUN")

@035,002 SAY OemToAnsi(STR0039)+QAA->QAA_FILIAL+"-"+QAA->QAA_MAT+" "+QA_NUSR(QAA->QAA_FILIAL,QAA->QAA_MAT) PIXEL //"Transferências realizadas (DE): "
oGetDE :=MsNewGetDados():New(050,002,120,395,Iif(Altera .Or. Inclui,GD_INSERT+GD_DELETE+GD_UPDATE,0),"AllwaysTrue()","AllwaysTrue()",,,,,,,,oDlgR,aHeadDE,aColsDE)

@130,002 SAY OemToAnsi(STR0040)+QAA->QAA_FILIAL+"-"+QAA->QAA_MAT+" "+QA_NUSR(QAA->QAA_FILIAL,QAA->QAA_MAT) PIXEL //"Transferências realizadas (PARA): "
oGetPA :=MsNewGetDados():New(150,002,230,395,Iif(Altera .Or. Inclui,GD_INSERT+GD_DELETE+GD_UPDATE,0),"AllwaysTrue()","AllwaysTrue()",,,,,,,,oDlgR,aHeadPA,aColsPA)

ACTIVATE MSDIALOG oDlgR CENTERED ON INIT EnchoiceBar(oDlgR,{|| oDlgR:End()},{|| oDlgR:End()} )

Return(NIL)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QAD015Leg  ³ Autor ³Telso Carneiro        ³ Data ³01/11/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe a legenda da Auditoria /Agenda 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³QAD015Leg()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QAD015Leg(aStAud,aStAge,nFolderItem)

Local cPaginas:= aPagPend[nFolderItem]

IF cPaginas=="Lider" .OR. cPaginas=="Audit"
	BrwLegenda(cCadastro,STR0053, aStAud)    //"Auditorias"
ELSEIF cPaginas=="AgLider" .OR. cPaginas=="AgAudit"
	BrwLegenda(cCadastro,STR0052, aStAge)    //"Agenda "
EndIF

Return(NIL)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QAD015Pen ºAutor  ³Telso Carneiro      º Data ³ 22/09/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega nos Arrays as Pendencias de Transferencias QAB      º±±
±±º          ³e pendencias Atuais de Auditorias/Agendas                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³QAD015Atu()                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

STATIC Function QAD015Pen(aQUB,aQUH,aQUA,aQUM)

Local lVerEvid	:= GetMv("MV_QADEVI",.T.,.F.) 
Local dDtEncer	:= dDataBase       
Local cTxtEvi	:= ""        
Local lPend   	:= .F.
Local nIs		:= 0
Local lRet		:= .T.
Local cIndex1   := ""
Local cFiltro   := ""
Local cKey      := ""
Local aBuscaPed := {}
Local aRecTrf   := {}
Local cFilAtu   := ""
Local cMatAtu   := ""                                                                   

ProcRegua(2)

IncProc()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega os Lactos de Transferencia e QAB                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFilAtu	 := QAA->QAA_FILIAL
cMatAtu  :=	QAA->QAA_MAT
aAdd(aBuscaPed,{cFilAtu,cMatAtu})

QAB->(DbSetOrder(2))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega os Lactos de Transferencia e Matricula atual         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If QAB->(DbSeek(cFilAtu+cMatAtu))
	While QAB->(!Eof()) .And. QAB->QAB_FILP + QAB->QAB_MATP == cFilAtu + cMatAtu
		If Ascan(aRecTrf,QAB->(Recno())) > 0
			QAB->(DbSkip())
			Loop
		Else
			Aadd(aRecTrf,QAB->(Recno()))
		Endif
		If QAB->QAB_FILP+QAB->QAB_MATP == cFilAtu+cMatAtu
			If QAB->QAB_FILP+QAB->QAB_MATP <> QAB->QAB_FILD+QAB->QAB_MATD
				If Ascan(aBuscaPed,{|X| X[1]+X[2] == QAB->QAB_FILD+QAB->QAB_MATD}) == 0
					Aadd(aBuscaPed,{QAB->QAB_FILD,QAB->QAB_MATD})
				Endif
			EndIf
			cFilAtu := QAB->QAB_FILD
			cMatAtu := QAB->QAB_MATD
			QAB->(DbSeek(cFilAtu+cMatAtu))
		Else
			QAB->(DbSkip())
		EndIf
	EndDo
EndIf

cFilAtu	 := QAA->QAA_FILIAL
cMatAtu  :=	QAA->QAA_MAT

For nIs:=1 TO Len(aBuscaPed)
	
	cIndex1  := CriaTrab(Nil,.F.) // Cria Indice Condicional nos arquivos utilizados
	cFiltro  := ""
	cKey     := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pendencias de Auditor Lider³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QUB->(DbSetOrder(2))
	QUB->(dbSetFilter({|| Empty(QUB->QUB_ENCREA) },'Empty(QUB->QUB_ENCREA)'))		
	QUB->(dbGotop())	
	While QUB->(!Eof())
		
		IF QUB->QUB_FILMAT == aBuscaPed[nIs,1] .And. QUB->QUB_AUDLID == aBuscaPed[nIs,2]			
			IF aBuscaPed[nIs,1]+aBuscaPed[nIs,2]<>cFilAtu+cMatAtu // Usuario Transf. QAB				
				AaDD(aQUB,{.T.,VAL(QUB->QUB_STATUS),QUB->QUB_FILIAL,QUB->QUB_NUMAUD,QUB->(RECNO()),cFilAtu+cMatAtu })
				lRet:=.F.
			Else
				AaDD(aQUB,{.F.,VAL(QUB->QUB_STATUS),QUB->QUB_FILIAL,QUB->QUB_NUMAUD,QUB->(RECNO()),SPACE(12)})
			Endif
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Pendencias de Auditor ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		IF QUH->(DbSeek(QUB->QUB_FILIAL+QUB->QUB_NUMAUD))
			While QUH->(!Eof()) .And. QUH->QUH_FILIAL == QUB->QUB_FILIAL .AND. QUH->QUH_NUMAUD == QUB->QUB_NUMAUD
				
				IF QUH->QUH_FILMAT == aBuscaPed[nIs,1] .AND. QUH->QUH_CODAUD == aBuscaPed[nIs,2]
					If QUD->(DbSeek(QUH->QUH_FILIAL+QUH->QUH_NUMAUD+QUH->QUH_SEQ))
						While QUD->(!Eof()) .And. QUD->QUD_FILIAL+QUD->QUD_NUMAUD+QUD->QUD_SEQ == QUH->QUH_FILIAL+QUH->QUH_NUMAUD+QUH->QUH_SEQ
							lPend:=.F.
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se questao Nao esta respondida.          ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !Empty(QUD->QUD_DTAVAL)
								If lVerEvid
									cTxtEvi := MsMM(QUD->QUD_EVICHV,TamSX3('QUD_EVIDE1')[1])
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Verifica se o texto da Evidencia esta preenchido. ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If Empty(cTxtEvi)
										lPend:= .T.
									EndIf
								EndIf
							Else
								lPend:= .T.
							Endif
										
							If lPend
								IF ASCAN(aQUH,{|X| X[3]+X[4]+X[5]+X[6]+X[7]+X[8]==QUD->QUD_FILIAL+QUD->QUD_NUMAUD+QUH->QUH_DESTIN+QUD->QUD_CHKLST+QUD->QUD_REVIS+QUD->QUD_CHKITE }) == 0
									IF aBuscaPed[nIs,1]+aBuscaPed[nIs,2]<>cFilAtu+cMatAtu // Usuario Transf. QAB
										AaDD(aQUH,{.T.,VAL(QUB->QUB_STATUS),QUD->QUD_FILIAL,QUD->QUD_NUMAUD,QUH->QUH_DESTIN,QUD->QUD_CHKLST,QUD->QUD_REVIS,QUD->QUD_CHKITE,QUH->(RECNO()),cFilAtu+cMatAtu})
										lRet:=.F.
									Else
										AaDD(aQUH,{.F.,VAL(QUB->QUB_STATUS),QUD->QUD_FILIAL,QUD->QUD_NUMAUD,QUH->QUH_DESTIN,QUD->QUD_CHKLST,QUD->QUD_REVIS,QUD->QUD_CHKITE,QUH->(RECNO()),SPACE(12)})
									Endif
								EndIf
							Endif
							QUD->(DbSkip())
						EndDo
					EndIf
				Endif
				QUH->(DbSkip())
			EndDo
		Endif
		
		QUB->(DbSkip())
	EndDo
	
	QUB->(dbClearFilter())
	QUB->(DbSetOrder(1))
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pendencias Agenda de Auditor Lider³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QUA->(dbSetFilter({||QUA->QUA_FILMAT == aBuscaPed[nIs,1] .And. QUA->QUA_MAT == aBuscaPed[nIs,2]},'QUA->QUA_FILMAT == "'+aBuscaPed[nIs,1]+'" .And. QUA->QUA_MAT    == "'+aBuscaPed[nIs,2]+'"'))	
	QUA->(dbGotop())
	While QUA->(!Eof())
		If QUA->QUA_STATUS=="1"
			IF aBuscaPed[nIs,1]+aBuscaPed[nIs,2]<>cFilAtu+cMatAtu // Usuario Transf. QAB
				AaDD(aQUA,{.T.,VAL(QUA->QUA_STATUS),QUA->QUA_FILIAL,QUA->QUA_NUMAUD,QUA->(RECNO()),cFilAtu+cMatAtu })
				lRet:=.F.
			Else
				AaDD(aQUA,{.F.,VAL(QUA->QUA_STATUS),QUA->QUA_FILIAL,QUA->QUA_NUMAUD,QUA->(RECNO()),SPACE(12)})
			Endif
		EndIf
		QUA->(DbSkip())
	EndDo
	QUA->(dbClearFilter())
	QUA->(DbSetOrder(1))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pendencias Agenda de Auditor ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF lExtQUM

		QUM->(dbSetFilter({|| QUM->QUM_FILMAT == aBuscaPed[nIs,1] .And. QUM->QUM_CODAUD == aBuscaPed[nIs,2]},'QUM->QUM_FILMAT == "'+aBuscaPed[nIs,1]+'" .And. QUM->QUM_CODAUD == "'+aBuscaPed[nIs,2]+'"'))
		QUM->(DbGotop())				
		While QUM->(!Eof())
			IF Posicione("QUA",3,QUM->QUM_FILIAL+QUM->QUM_NUMAUD,"QUA_STATUS")=="1"
				
				IF aBuscaPed[nIs,1]+aBuscaPed[nIs,2]<>cFilAtu+cMatAtu // Usuario Transf. QAB
					AaDD(aQUM,{.T.,VAL(QUA->QUA_STATUS),QUM->QUM_FILIAL,QUM->QUM_NUMAUD,QUM->QUM_DESTIN,QUM->(RECNO()),cFilAtu+cMatAtu})
					lRet:=.F.
				Else
					AaDD(aQUM,{.F.,VAL(QUA->QUA_STATUS),QUM->QUM_FILIAL,QUM->QUM_NUMAUD,QUM->QUM_DESTIN,QUM->(RECNO()),SPACE(12)})
				Endif
			Endif
			QUM->(DbSkip())
		EndDo
		
		QUM->(dbClearFilter())
		QUM->(DbSetOrder(1))
	Endif
Next
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QAD015Grv ºAutor  ³Telso Carneiro      º Data ³ 22/09/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³GRAVA os Arrays das Pendencias de Transferencias QAB        º±±
±±º          ³e pendencias Atuais de Auditorias/Agendas                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³QAD015Atu()                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QAD015Grv(aQUB,aQUH,aQUA,aQUM)

Local cSeqTrf	:= ""
Local cFilDe	:= ""
Local cMatDe	:= ""
Local cFilPara	:= ""
Local cMatPara	:= ""
Local nIC		:= 1
	Begin Transaction
	QAA->(dbSetOrder(1))
	
	cSeqTrf:= GetSxeNum("QUN","QUN_SEQTRF")
	
	For nIc := 1 to Len(aQUB)
		If (aQUB[nIc,1])
			
			QUB->(dbGoTo(aQUB[nIc,5]))
			cFilDe:= QUB->QUB_FILMAT
			cMatDe:= QUB->QUB_AUDLID
			
			RecLock("QUB",.F.)
			QUB->QUB_FILMAT := SubStr(aQUB[nIc,Len(aQUB[nIc])],1,FWSizeFilial())
			QUB->QUB_AUDLID := SubStr(aQUB[nIc,Len(aQUB[nIc])],FWSizeFilial()+1,len(QUB->QUB_AUDLID))
			MsUnLock()
			FKCommit()
			
			cFilPara:= QUB->QUB_FILMAT
			cMatPara:= QUB->QUB_AUDLID

			QAD015Log(aQUB[nIc,4],,,,,"1",cSeqTrf,cMotTransf,cFilDe,cMatDe,cFilPara,cMatPara)
						
		Endif
	Next
	
	For nIc := 1 to Len(aQUH)
		If (aQUH[nIc,1])
			
			QUH->(dbGoTo(aQUH[nIc,9]))
			cFilDe:= QUH->QUH_FILMAT
			cMatDe:= QUH->QUH_CODAUD
			
			RecLock("QUH",.F.)
			QUH->QUH_FILMAT := SubStr(aQUH[nIc,Len(aQUH[nIc])],1,FWSizeFilial())
			QUH->QUH_CODAUD := SubStr(aQUH[nIc,Len(aQUH[nIc])],FWSizeFilial()+1,len(QUH->QUH_CODAUD))
			MsUnLock()
			FkCommit()
			cFilPara:= QUH->QUH_FILMAT
			cMatPara:= QUH->QUH_CODAUD
						
			If QUD->(DbSeek(QUH->QUH_FILIAL+QUH->QUH_NUMAUD+QUH->QUH_SEQ))
				While QUD->(!Eof()) .And. QUD->QUD_FILIAL+QUD->QUD_NUMAUD+QUD->QUD_SEQ == QUH->QUH_FILIAL+QUH->QUH_NUMAUD+QUH->QUH_SEQ
					RecLock("QUD",.F.)
					QUD->QUD_FILMAT := SubStr(aQUH[nIc,Len(aQUH[nIc])],1,FWSizeFilial())
					QUD->QUD_CODAUD := SubStr(aQUH[nIc,Len(aQUH[nIc])],FWSizeFilial()+1,len(QUH->QUH_CODAUD))
					MsUnLock()
					FkCommit()
					QUD->(DbSkip())
				EndDo
			Endif
			
			//QUC->(DbSetOrder(1))
			//If QUC->(DbSeek(xFilial("QUC")+QUH->QUH_NUMAUD))
			//	While QUC->(!Eof()) .And. QUC->QUC_FILIAL+QUC->QUC_NUMAUD == xFilial("QUC")+QUH->QUH_NUMAUD
			//		RecLock("QUC",.F.)
			//		QUC->QUC_FILMAT := SubStr(aQUH[nIc,Len(aQUH[nIc])],1,2)
			//		QUC->QUC_CODAUD := SubStr(aQUH[nIc,Len(aQUH[nIc])],3,10)
			//		MsUnLock()
			//		FKCommit()
			//		QUC->(DbSkip())
			//	EndDo
			//EndIf

			QAD015Log(aQUH[nIC,4],QUH->QUH_SEQ,aQUH[nIC,5],aQUH[nIC,6],aQUH[nIC,7],"2",cSeqTrf,cMotTransf,cFilDe,cMatDe,cFilPara,cMatPara)
						
		EndIf
	Next

	For nIc := 1 to Len(aQUA)
		If (aQUA[nIc,1])
			
			QUA->(dbGoTo(aQUA[nIc,5]))
			cFilDe:= QUA->QUA_FILMAT
			cMatDe:= QUA->QUA_MAT
			
			RecLock("QUA",.F.)
			QUA->QUA_FILMAT := SubStr(aQUA[nIc,Len(aQUA[nIc])],1,FWSizeFilial())
			QUA->QUA_MAT 	:= SubStr(aQUA[nIc,Len(aQUA[nIc])],FWSizeFilial()+1,len(QUA->QUA_MAT))
			MsUnLock()
			FkCommit()
			cFilPara:= QUA->QUA_FILMAT
			cMatPara:= QUA->QUA_MAT

			QAD015Log(aQUA[nIc,4],,,,,"3",cSeqTrf,cMotTransf,cFilDe,cMatDe,cFilPara,cMatPara)
						
		Endif
	Next

	For nIc := 1 to Len(aQUM)
		If (aQUM[nIc,1])
			
			QUM->(dbGoTo(aQUM[nIc,6]))
			cFilDe:= QUM->QUM_FILMAT
			cMatDe:= QUM->QUM_CODAUD
			
			RecLock("QUM",.F.)
			QUM->QUM_FILMAT := SubStr(aQUM[nIc,Len(aQUM[nIc])],1,FWSizeFilial())
			QUM->QUM_CODAUD	:= SubStr(aQUM[nIc,Len(aQUM[nIc])],FWSizeFilial()+1,len(QUM->QUM_CODAUD))
			MsUnLock()
			FKCommit()
			cFilPara:= QUM->QUM_FILMAT
			cMatPara:= QUM->QUM_CODAUD

			QAD015Log(aQUM[nIc,4],,aQUM[nIc,5],,,"4",cSeqTrf,cMotTransf,cFilDe,cMatDe,cFilPara,cMatPara)
						
		Endif
	Next
	
	End Transaction
	                  	
	If Len(aEmails) > 0
		QAudEnvMai(aEmails,,,,.T.)
	Endif   
	 	
Return(Nil)	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QAD015PUS ºAutor  ³Telso Carneiro      º Data ³ 22/09/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tela de Pesquisa do Usuario para definir a Filial/Codigo    º±±
±±º          ³												              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³QAD015Atu()                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function QAD015PUS()

Local lRet:= .T.
Local oDlgU
Local oFilUsr
Local cFilUsr := xFilial("QAA")
Local oCodUsr
Local oDesUsr
Local cCodUsr:= Space(TamSx3("QAA_MAT" )[1])
Local cDesUsr:= Space(TamSx3("QAA_NOME")[1])
Local oPanel := NIL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New()

oSize:AddObject( "PANEL"   ,  100,100, .F., .F. ) // Fixo

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  
    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog                                                 ³    
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgU FROM 000,000 TO 160,400 TITLE OemToAnsi(STR0002) PIXEL //"Pesquisar"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Panel                                                  ³    
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
oPanel:= tPanel():New(,,,oDlgU)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Label Principal                                              ³    
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 003,003 TO 065,200 LABEL OemToAnsi(STR0014) OF oPanel PIXEL  //"Usuário"

@ 015,006 SAY OemToAnsi(STR0023) SIZE 010,008 OF oPanel PIXEL  //"Fil"
@ 025,006 MSGET oFilUsr VAR cFilUsr PICTURE REPL("@!",FWSizeFilial()) F3 "SM0" SIZE 010,008 OF oPanel PIXEL ;
VALID QA_CHKFIL(cFilUsr,@cFilMat)

@ 015,055 SAY OemToAnsi(STR0024) SIZE 044,008 OF oPanel PIXEL  //"C¢digo"
@ 025,055 MSGET oCodUsr VAR cCodUsr PICTURE '@!' F3 "QDE" SIZE 044,008 OF oPanel PIXEL ;
VALID (cDesUsr:= QA_NUSR(cFilUsr,cCodUsr,.T.),	oDesUsr:Refresh(),QA_CHKMAT(cFilUsr,cCodUsr))

@ 015,105 SAY OemToAnsi(STR0007) SIZE 85,008 OF oPanel PIXEL  //"Nome"
@ 025,105 MSGET oDesUsr VAR cDesUsr SIZE 85,008 OF oPanel PIXEL WHEN .f.

ACTIVATE MSDIALOG oDlgU CENTERED ON INIT EnchoiceBar(oDlgU,{|| lRet:=.T., oDlgU:End()},{|| lRet:=.F., oDlgU:End()} )

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ºPrograma  ³QAD015Cor ºAutor  ³Telso Carneiro         º Data ³15/10/2004º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Define as Legendas utilizadas no cadastro de Responsaveis  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QAD015Cor(aCores)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NENHUM													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEA050													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QAD015Cor() 
Local aLegenda := {}      
Aadd(aLegenda,{'BR_VERDE'   ,STR0054})  //"Usuario ativo s/ Lancamento Pendente"
Aadd(aLegenda,{'BR_VERMELHO',STR0055}) //"Usuario inativo s/Lancamento Pendente"
Aadd(aLegenda,{'BR_AMARELO' ,STR0056}) //"Usuario ativo c/Lancamento Pendente"
Aadd(aLegenda,{'BR_PRETO'   ,STR0057}) //"Usuario inativo c/Lancamento Pendente"

BrwLegenda(cCadastro,STR0005,aLegenda) //"Legenda"

Return(NIL)

