#INCLUDE "QADA150.CH"
#INCLUDE "PROTHEUS.CH"
 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QADA150    ³ Autor ³ Eduardo de Souza   ³ Data ³ 14/01/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Agenda de Auditorias                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QADA150()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ SIGAQAD                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³   Data   ³  BOPS  ³ Programador ³ Alteracao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function MenuDef()

Local aRotina  := {{OemToAnsi(STR0001),"AxPesqui", 0, 1,,.F.},;    // 'Pesquisar'
				 {OemToAnsi(STR0002),"QAD150Tela", 0, 2},;         // 'Visualizar'
				 {OemToAnsi(STR0003),"QAD150Tela", 0, 3},;         // 'Incluir'
				 {OemToAnsi(STR0004),"QAD150Tela", 0, 4},;         // 'Alterar'
				 {OemToAnsi(STR0005),"QAD150Tela", 0, 5},;         // 'Excluir'
				 {OemToAnsi(STR0006),"QAD150Efet", 0, 6},;         // 'Efetiva'
				 {OemToAnsi(STR0014),"QAD150Lege", 0, 6,,.F.}}     // 'Legenda'

Return aRotina

Function QADA150()

Local aCores := {}
Local aUsrMat:= QA_USUARIO()
Local i := 0


Private cCadastro:= OemToAnsi(STR0007) // 'Agenda de Auditorias'   		
Private cFilMat  := cFilAnt
Private cMatFil  := aUsrMat[2]
Private cMatCod  := aUsrMat[3]
Private cMatDep  := aUsrMat[4]
Private aRotina  := MenuDef() 

Private lPEQ150Leg := ExistBlock("Q150LEG")
Private aLegenda := {}
Private aButtons := {}

//Avisa o cliente sobre as atualizações que serão realizadas no SIGAQAD.
//QAvisoQad()                     

DbSelectArea("QUA")
DbSetOrder(3)
DbGoTop()

If lPEQ150Leg
	aLegenda := ExecBlock("Q150LEG")
EndIf

If !lPEQ150Leg
	aCores:=	{{ 'QUA->QUA_STATUS == "1"','ENABLE'    },; // "Agendada"
	   			 { 'QUA->QUA_STATUS == "3"','BR_AMARELO'},;
				 { 'QUA->QUA_STATUS == "4"','BR_AZUL'   },;
				 { 'QUA->QUA_STATUS == "5"','BR_CINZA'  },;
				 { 'QUA->QUA_STATUS == "6"','BR_LARANJA'},;
			 	 { 'QUA->QUA_STATUS == "7"','BR_MARRON' },;
				 { 'QUA->QUA_STATUS == "8"','BR_VERDE'  },;
			 	 { 'QUA->QUA_STATUS == "9"','BR_CINZA'  },; 
		 	 	 { 'QUA->QUA_STATUS == "0"','BR_PINK'   },;
				 { 'QUA->QUA_STATUS == "2"','DISABLE'   }}  // "Efetivada"
Else
For i := 1 to Len(aLegenda)
	Aadd(aCores,{aLegenda[i][3],aLegenda[i][1]})
Next				
EndIf
	mBrowse( 006,001,022,075,"QUA",,,,,,aCores) 
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QAD150Tela³ Autor ³ Eduardo de Souza      ³ Data ³ 14/01/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tela Cadastro de Agenda Auditoria                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QAD150Tela(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Alias do arquivo                                   ³±±
±±³          ³ ExpN1 - Numero do registro                                 ³±±
±±³          ³ ExpN2 - Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QAD150Tela(cAlias,nReg,nOpc)

Local oDlg
Local lOk := .F.
Local nSaveSX8	:= GetSX8Len()
Local aArea := {}
Local aTelaButtons := {}
Local aUsrBut	   := {}
Local nX		   := 0
Local aAchoQUA     := {}
Local aNoFields    := {"QUM_NUMAUD"}
Local oStruQUA

Private bCampo:= {|nCPO| Field( nCPO ) }
Private aTELA[0][0]
Private aGETS[0]
Private aHeader := {}
Private nUsado	:=	0
Private cFilMat:= xFilial("QAA") // Utilizada no SXB
Private nQAConpad:= 1
Private oGet
Private nPosFilRes := 0
Private nPosAudRes := 0 

aButtons	 := IF(Type("aButtons") == "U", {}, aButtons)
aTelaButtons := ACLONE(aButtons)

If nOpc != 3
	aArea := GetArea()

	dbSelectArea("QUM")
	dbSetOrder(1)
	dbSeek(xFilial("QUM")+QUA->QUA_NUMAUD)
	
	Private cSeek  := QUM->QUM_FILIAL+QUM->QUM_NUMAUD
	Private cWhile := "QUM->QUM_FILIAL+QUM->QUM_NUMAUD"
	
	RestArea(aArea)
EndIf

If nOpc # 3 .And. GetMv("MV_AUDSLID", .T., .F.) .And. QUA->QUA_MAT <> cMatCod
	Help("",1,"QADNAUDIT") // "Usuario nao tem permissao para visualizar" ### "ou efetuar manutencao neste agendamento de Auditoria"
	Return .T.
Endif 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para criacao de botoes do usuario  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (ExistBlock( "QD150BUT" ))
	aUsrBut := ExecBlock("QD150BUT",.F.,.F.,{nOpc})
	If ValType(aUsrBut) == "A"
		For nx:=1 to Len(aUsrBut)
			AADD(aTelaButtons,aUsrBut[nx])
		Next
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica os campos que serao editados na Enchoice   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAchoQUA    := {} 
oStruQUA := FWFormStruct(3, "QUA")

For nX := 1 to Len(oStruQUA[3])
	If !AllTrim(oStruQUA[3][nX][1]) $ "QUA_STATUS"
		aAdd(aAchoQUA, oStruQUA[3][nX][1])
	EndIf
Next nX

RegToMemory("QUA",If(nOpc == 3,.T.,.F.))

If nOpc == 4 .Or. nOpc == 5
	If M->QUA_STATUS == "2"
		Help(" ",1,"QAD150EFET") // "Nao sera possivel a manutencao para" ### "Agenda Efetivada."
		Return .F.
	EndIf
EndIf

DEFINE MSDIALOG oDlg TITLE cCadastro FROM 000,000 TO 420,625 OF oMainWnd PIXEL //'Agenda de Auditorias'

Enchoice("QUA",nReg,nOpc,,,, aAchoQUA,{031,002,113,312})

RegToMemory("QUM") 

If nOpc !=3
	FillGetDados(nOpc,"QUM" ,1     ,cSeek ,{|| &cWhile},         , aNoFields,          ,        ,      ,        ,       ,          ,        ,          ,           ,            ,)
  //FillGetDados(nOpc,Alias ,nOrdem,cSeek  ,bSeekWhile  ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
Else
	FillGetDados(nOpc,"QUM" ,1     ,      ,             ,         , aNoFields,          ,        ,      ,        ,  .T.  ,          ,        ,          ,           ,            ,)
  //FillGetDados(nOpc,Alias ,nOrdem,cSeek  ,bSeekWhile   ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
EndIf

nPosFilRes 	:= Ascan(aHeader,{|x|Alltrim(x[2]) == "QUM_FILMAT"})
nPosAudRes 	:= Ascan(aHeader,{|x|Alltrim(x[2]) == "QUM_CODAUD"})

nUsado := Len(aHeader)

oGet := MsNewGetDados():New(120,002,193,312,Iif(Altera .Or. Inclui,GD_INSERT+GD_DELETE+GD_UPDATE,0),"QA150LinOk()","AllwaysTrue()","+QUM_SEQ",,,99,,,,oDlg,aHeader,aCols)
                                                                                                                          
If nOpc == 2 .Or. nOpc == 5
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| (If(nOpc == 5,QAD150Dele(),),oDlg:End())},{|| oDlg:End()},,aTelaButtons) CENTERED
ElseIf nOpc == 3 .Or. nOpc == 4
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela) .And. QA150VldAcols(),(lOk := .T.,QAD150Grav(nOpc),oDlg:End()),)},{|| oDlg:End()},,aTelaButtons) CENTERED
	While (GetSX8Len() > nSaveSx8)
		If lOk 
			ConfirmSx8()
		Else
			RollBackSx8()
		EndIf		
	Enddo
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QAD150Grav³ Autor ³ Eduardo de Souza      ³ Data ³ 14/01/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Agenda                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QAD150Grav(ExpN1                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao do Browse                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QAD150Grav(nOpc)

Local lRecLock  := .F.
Local nI        := 0
Local nZ        := 0
Local cMail     := "" 
Local cMvQadTMai:= GetMv("MV_QADTMAI",.F.,"1")
Local cTpMail   := ""
Local nPosSeq   := Ascan(aHeader,{|x|Alltrim(x[2]) == "QUM_SEQ"})
Local cSeqQUM   := "00"
Local lMvQadeag := IF( GetMv("MV_QADENAG",.F.,"1")=="1" ,.T.,.F. )
Local aAgeUsu   := {}                                            
Local aMemUser	:= {}
Local lQA150MEM := Existblock("QA150MEM")
Local lQAD150EN := ExistBlock("QAD150EN")

If cMvQadTMai == "1"
	cTpMail:= "1" // HTML
Else
	cTpMail:= "2" // TEXTO
EndIf

If nOpc == 3
	lRecLock:= .T.
EndIf

//Ponto de entrada para permitir a alteracao
//do nome da auditoria
If ExistBlock("QAD150GR")
	ExecBlock("QAD150GR",.F.,.F.,{nOpc})
EndIf

Begin Transaction
	RecLock("QUA",lRecLock)
	For nI := 1 TO FCount()
		FieldPut(nI,M->&(Eval(bCampo,nI)))
	Next nI
	QUA->QUA_FILIAL:= xFilial("QUA")
	QUA->QUA_STATUS:= "1"
	MsUnLock()      
	FKCOMMIT()       

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para adicao de campos memo do usuario       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lQA150MEM
		If ValType (aMemUser := ExecBlock( "QA150MEM", .F., .F. ) ) == "A" 
			For nI := 1 to Len(aMemUser)
				If  (nOpc == 3 .And. !Empty(&("M->"+aMemUser[nI,2]))) .Or. ;
					(nOpc == 4 .And. !Empty(aMemUser[nI,1])) .Or. ;
					(nOpc == 4 .And. !Empty(&("M->"+aMemUser[nI,2])) .And. Empty(aMemUser[nI,1]))
					MSMM(&(aMemUser[nI,1]),,,&("M->"+aMemUser[nI,2]),1,,,"QUA",aMemUser[nI,1])
				EndIf
			Next
		EndIf
	EndIf
	
	cMail := AllTrim(Posicione("QAA", 1, QUA->QUA_FILMAT+QUA->QUA_MAT,"QAA_EMAIL"))	
	IF !Empty(cMail)
		Aadd(aAgeUsu,{"L",QUA->QUA_FILMAT,QUA->QUA_MAT,cMail})
	Endif	
	
	cSeqQUM := "00"
	For nI := 1 to Len(oGet:aCols)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava as Areas auditadas											 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    dbSelectArea("QUH")
	    dbSetorder(1)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o registro esta marcado para delecao. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If oGet:aCols[nI,nUsado+1] == .F.
			cSeqQUM := StrZero(Val(cSeqQUM)+1,Len(QUM->QUM_SEQ))			

			If cSeqQUM <> oGet:aCols[nI,nPosSeq]
			    If QUM->(DbSeek(xFilial("QUM")+M->QUA_NUMAUD+oGet:aCols[nI,nPosSeq]))
					RecLock("QUM",.F.)
					DbDelete()
					MsUnlock()
					FKCOMMIT()
				EndIf
				oGet:aCols[nI,nPosSeq] := cSeqQUM
			Endif

		    If QUM->(DbSeek(xFilial("QUM")+M->QUA_NUMAUD+cSeqQUM))
				RecLock("QUM",.F.)             
			Else
				RecLock("QUM",.T.)             
				QUM->QUM_FILIAL := xFilial("QUM")  
				QUM->QUM_NUMAUD := QUA->QUA_NUMAUD
			EndIf	
			For nZ := 1 to Len(aHeader)
			    If aHeader[nZ,10] # "V"
					QUM->(FieldPut(FieldPos(AllTrim(aHeader[nZ,2])),oGet:aCols[nI,nZ]))	    
			    EndIf
			Next nZ	
			MsUnLock()                                     

			cMail := AllTrim(Posicione("QAA", 1, QUM->QUM_FILMAT+QUM->QUM_CODAUD,"QAA_EMAIL"))	
			IF !Empty(cMail)
			    IF Ascan(aAgeUsu,{|X| X[2]+X[3]==QUM->QUM_FILMAT+QUM->QUM_CODAUD})==0
					Aadd(aAgeUsu,{"A",QUM->QUM_FILMAT,QUM->QUM_CODAUD,cMail})
				Endif	
			Endif	
			IF !Empty(QUM->QUM_EMAIL)
			    IF Ascan(aAgeUsu,{|X| X[4]==QUM->QUM_EMAIL})==0
					Aadd(aAgeUsu,{"U",QUM->QUM_FILMAT,QUM->QUM_NUMAUD,QUM->QUM_EMAIL})
				Endif	
			Endif

		Else
		    If QUM->(DbSeek(xFilial("QUM")+M->QUA_NUMAUD+oGet:aCols[nI,nPosSeq]))
				RecLock("QUM",.F.)
				DbDelete()
				MsUnlock()
				FKCOMMIT()
			EndIf
		EndIf
	Next		
End Transaction

IF lMvQadeag	
	For nI := 1 to Len(aAgeUsu)
		If cTpMail == "1"
			cMsg:= '<HTML>'
			cMsg+= '  <TITLE>SIGAQAD</TITLE>'
			cMsg+= '<BODY>'
			
			cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
			cMsg+= '  <TR><TD borderColor=#0099cc borderColorLight=#0099cc align=left width=606 '
			cMsg+= '    bgColor=#0099cc borderColorDark=#0099cc height=1>'
			cMsg+= '    <P align=center><FONT face="Courier New" color=#ffffff size=4>'
			cMsg+= '    <B>'+OemToAnsi(STR0017)+'</B></FONT></P></TD></TR>' // "MENSAGEM"
			
			cMsg+= '  <TR><TD align=left width=606 height=32>'
			If !Empty(AllTrim(QA_NUSR(aAgeUsu[ni,2],aAgeUsu[ni,3])))
				cMsg+= '    <P align=Center>'+OemToAnsi(STR0008)+' '+AllTrim(QA_NUSR(aAgeUsu[ni,2],aAgeUsu[ni,3]))+' '+OemToAnsi(STR0009)+' '+Dtoc(QUA->QUA_ALOC)+'</P></TD></TR>'  //"Agendamento previo de Auditoria para"  ### "na data"
				cMsg+= '</TABLE><BR>'
			Else 
				cMsg+= '    <P align=Center>'+OemToAnsi(STR0031)+' '+AllTrim(QA_NUSR(aAgeUsu[ni,2],aAgeUsu[ni,3]))+' '+OemToAnsi(STR0009)+' '+Dtoc(QUA->QUA_ALOC)+'</P></TD></TR>'  //"Agendamento previo de Auditoria para"  ### "na data"
				cMsg+= '</TABLE><BR>'
			EndIf
			cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
			cMsg+= '  <TR><TD borderColor=#0099cc borderColorLight=#0099cc align=left width=606 '
			cMsg+= '    bgColor=#0099cc borderColorDark=#0099cc height=1>'
			cMsg+= '    <P align=center><font face="Courier New" color="#ffffff" size="4"><b>'+OemToAnsi(STR0018)+'</b></font></P></TD></TR>' // "AGENDAMENTO DE AUDITORIA"
			cMsg+= '</TABLE>'
			
			cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
			cMsg+= '  <TR><TD align=left width=50% height=32><b>'+RetTitle("QUA_NUMAUD")+'</b><br>'+QUA->QUA_NUMAUD+'</TD>' // Auditoria
			cMsg+= '    <TD align=left width=50% height=32><B>' +RetTitle("QUA_ALOC")+'</B><br>'+Dtoc(QUA->QUA_ALOC)+'</TD></TR>' // Alocacao
			cMsg+= '</TABLE>'
			
			cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
			cMsg+= '    <TD align=left width=50% height=32><b>'+RetTitle("QUA_TIPAUD")+'</b><BR>'+QADCBox("QUA_TIPAUD", QUA->QUA_TIPAUD)+'</TD>' // Tipo
			cMsg+= '    <TD align=left width=50% height=32><b>'+RetTitle("QUA_SITUAC")+'</b><BR>'+QADCBox("QUA_SITUAC",QUA->QUA_SITUAC)+'</TD></TR>' // Situacao
			cMsg+= '</TABLE>'
			
			cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
			cMsg+= '  <TR><TD align=left width=100% height=32><b>'+OemToAnsi("Auditor Lider")+'</b><br>'+AllTrim(QA_NUSR(QUA->QUA_FILMAT,QUA->QUA_MAT))+'</TD>'
			cMsg+= '  </TR>'
			cMsg+= '</TABLE>'
			
			cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
			cMsg+= '  <TR><TD align=left width=100% height=32><b>'+RetTitle("QUA_DESCRI")+'</b><br>'+AllTrim(QUA->QUA_DESCRI)+'</TD>' // Descricao
			cMsg+= '  </TR>'
			cMsg+= '</TABLE>'
			
			If !Empty(QUA->QUA_CODFOR)
				cMsg+= '<TABLE borderColor=#0099cc height=29 cellSpacing=1 width=645 borderColorLight=#0099cc border=1>'
				cMsg+= '  <TR><TD align=left width=86 height=32><b>'+RetTitle("QUA_CODFOR")+'</b><br>'+QUA->QUA_CODFOR+'</TD>' // Fornecedor
				cMsg+= '    <TD align=left width=543 height=32><b>'+OemToAnsi(STR0020)+'</b><br>'+Posicione("SA2",1,xFilial("SA2")+QUA->QUA_CODFOR,"A2_NOME")+'</TD></TR>' // "Razao Social"
				cMsg+= '</TABLE>'
			EndIf
			
			cMsg+= '<p>'+OemToAnsi(STR0010)+'<p>' //"Em breve, será enviado email de confirmação, juntamente com mais detalhes sobre a auditoria"
			cMsg+= '<p>'+OemToAnsi(STR0021) // "Atenciosamente"
			cMsg+= '<BR>'+QA_NUSR(cMatFil,cMatCod)
			cMsg+= '<BR>'+QA_NDEPT(cMatDep,.t.,cMatFil)
			cMsg+= '<BR></p>'
			
			cMsg+= '<p><FONT size=2><EM>'+OemToAnsi(STR0022)+'</EM></FONT></p>' // Mensagem gerada automaticamente pelo Sistema SIGAQAD - Controle de Auditorias
			cMsg+= '</BODY>'
			cMsg+= '</HTML>'
		Else
			cMsg:= OemToAnsi(STR0008)+' '+AllTrim(QA_NUSR(aAgeUsu[ni,2],aAgeUsu[ni,3]))+' '+OemToAnsi(STR0009)+' '+Dtoc(QUA->QUA_ALOC)+CHR(13)+CHR(10)+CHR(13)+CHR(10)  //"Agendamento previo de Auditoria para"  ### "na data"
			cMsg+= OemToAnsi(STR0018)+CHR(13)+CHR(10) // "AGENDAMENTO DE AUDITORIA"
			cMsg+= RetTitle("QUA_NUMAUD")+': '+QUA->QUA_NUMAUD+CHR(13)+CHR(10) // Auditoria
			cMsg+= RetTitle("QUA_ALOC")+': '+Dtoc(QUA->QUA_ALOC)+CHR(13)+CHR(10) // Alocacao
			cMsg+= RetTitle("QUA_TIPAUD")+': '+QADCBox("QUA_TIPAUD", QUA->QUA_TIPAUD)+CHR(13)+CHR(10) // Tipo
			cMsg+= RetTitle("QUA_SITUAC")+': '+QADCBox("QUA_SITUAC",QUA->QUA_SITUAC)+CHR(13)+CHR(10) // Situacao
			cMsg+= OemToAnsi("Auditor Lider")+': '+AllTrim(QA_NUSR(QUA->QUA_FILMAT,QUA->QUA_MAT))+CHR(13)+CHR(10) 
			cMsg+= RetTitle("QUA_DESCRI")+': '+AllTrim(QUA->QUA_DESCRI)+CHR(13)+CHR(10) // Descricao
			If !Empty(QUA->QUA_CODFOR)
				cMsg+= RetTitle("QUA_CODFOR")+': '+QUA->QUA_CODFOR+CHR(13)+CHR(10) // Fornecedor
				cMsg+= OemToAnsi(STR0020)+': '+Posicione("SA2",1,xFilial("SA2")+QUA->QUA_CODFOR,"A2_NOME")+CHR(13)+CHR(10) // "Razao Social"
			EndIf
			cMsg+= CHR(13)+CHR(10)
			cMsg+= OemToAnsi(STR0010)+CHR(13)+CHR(10)+CHR(13)+CHR(10) //"Em breve, será enviado email de confirmação, juntamente com mais detalhes sobre a auditoria"
			cMsg+= OemToAnsi(STR0021)+CHR(13)+CHR(10) // "Atenciosamente"
			cMsg+= QA_NUSR(cMatFil,cMatCod)+CHR(13)+CHR(10)
			cMsg+= QA_NDEPT(cMatDep,.t.,cMatFil)+CHR(13)+CHR(10)+CHR(13)+CHR(10)
			cMsg+= OemToAnsi(STR0022) // Mensagem gerada automaticamente pelo Sistema SIGAQAD - Controle de Auditorias
		EndIf

		//Ponto de entrada para personalizar
		//a mensagem do e-mail antes do envio		
		If lQAD150EN
			cMsg := ExecBlock( "QAD150EN", .f., .f., {cMsg,aAgeUsu[nI,3]}) 
		EndIF

		QAudEnvMail({{aAgeUsu[ni,4],OemToAnsi(STR0011)+ dtoc(QUA->QUA_ALOC), cMsg, ""}},,,,,"2") //"Auditoria Marcada para "
	Next	
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QAD150Dele ³ Autor ³ Eduardo de Souza   ³ Data ³ 14/01/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Exclusao de registros do Cadastro de Agenda               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QAD150Dele()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QADA150                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QAD150Dele()

Local nX		:= 0
Local aMemUser	:= {}
Local lQA150MEM := Existblock("QA150MEM")

Begin Transaction

	dbSelectArea("QUM")
    If DbSeek(xFilial("QUM")+QUA->QUA_NUMAUD)
		While !Eof() .And. xFilial("QUM")+QUA->QUA_NUMAUD == QUM->QUM_FILIAL+QUM->QUM_NUMAUD
			RecLock("QUM",.F.)
			DbDelete()
			MsUnlock()			
			dbSkip()
		Enddo
	EndIf

	RecLock("QUA",.F.)
	QUA->(DbDelete())
	MsUnlock()
End Transaction

If Existblock("QA150EXC")
	Execblock("QA150EXC",.F.,.F.)
Endif

If lQA150MEM
	If ValType (aMemUser := ExecBlock( "QA150MEM", .F., .F. ) ) == "A" 
		For nX := 1 To Len(aMemUser)
			MSMM(&("QUA->"+aMemUser[nX,1]),,,,2)
		Next
	EndIf
EndIf

dbSelectArea("QUA")
QUA->(DbSkip())

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QAD150Efet³ Autor ³ Eduardo de Souza      ³ Data ³ 14/01/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetiva a Agenda para Auditoria.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QAD150Efet()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QAD150Efet()
Local aDadosQUM := {}


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a Agenda nao encontra-se efetivada. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If QUA->QUA_STATUS == "2"
	Help(" ",1,"QAD150EFET") // "Nao sera possivel a manutencao para" ### "Agenda Efetivada."
	Return .F.
EndIf

If cMatCod <> QUA->QUA_MAT
	Help("",1,"QADNAUDIT") // "Usuario nao tem permissao para efetivar" ### "esta Agenda."
	Return .F.
EndIf

QUB->(DbSetOrder(1))
If !QUB->(DbSeek(xFilial("QUB")+QUA->QUA_NUMAUD))
	RecLock("QUB",.T.)
	QUB->QUB_FILIAL:= QUA->QUA_FILIAL
	QUB->QUB_NUMAUD:= QUA->QUA_NUMAUD
	QUB->QUB_MOTAUD:= QUA->QUA_MOTAUD
	QUB->QUB_TIPAUD:= QUA->QUA_TIPAUD
	QUB->QUB_REFAUD:= dDataBase
	QUB->QUB_INIAUD:= QUA->QUA_ALOC
	QUB->QUB_ENCAUD:= QUA->QUA_ALOCFI
	QUB->QUB_FILMAT:= QUA->QUA_FILMAT
	QUB->QUB_AUDLID:= QUA->QUA_MAT
	QUB->QUB_CODFOR:= QUA->QUA_CODFOR
	QUB->QUB_LOJA  := QUA->QUA_LOJA
	QUB->QUB_STATUS:= "1"
	QUB->QUB_PONPOS:= CRIAVAR("QUB->QUB_PONPOS")
	MsUnlock()
    
	RecLock("QUA",.F.)	
	QUA->QUA_STATUS:= "2"
	MsUnlock()
    FKCOMMIT()
    
	dbSelectArea("QUH")
	If !QUH->(DbSeek(xFilial("QUH")+QUA->QUA_NUMAUD))
		While !Eof() .And. xFilial("QUM")+QUA->QUA_NUMAUD == QUH->QUH_FILIAL+QUH->QUH_NUMAUD
			RecLock("QUH",.F.)
			dbDelete()
			MsUnLock()
			dbSkip()
		Enddo
	Endif

	dbSelectArea("QUM")
	QUM->(DbSetOrder(1))
	If QUM->(DbSeek(xFilial("QUM")+QUA->QUA_NUMAUD))
		While !Eof() .And. xFilial("QUM")+QUA->QUA_NUMAUD == QUM->QUM_FILIAL+QUM->QUM_NUMAUD
	
			RecLock("QUH",.T.)
			QUH->QUH_FILIAL := QUA->QUA_FILIAL
			QUH->QUH_NUMAUD := QUA->QUA_NUMAUD
			QUH->QUH_SEQ    := QUM->QUM_SEQ
			QUH->QUH_CCUSTO := QUM->QUM_CCUSTO
			QUH->QUH_DESTIN := QUM->QUM_DESTIN
			QUH->QUH_EMAIL  := QUM->QUM_EMAIL				
			QUH->QUH_FILMAT := QUM->QUM_FILMAT
			QUH->QUH_CODAUD := QUM->QUM_CODAUD			
			QUH->QUH_DTIN := QUM->QUM_DTIN
			QUH->QUH_DTFI := QUM->QUM_DTFI
			QUH->QUH_HRIN := QUM->QUM_HRIN
			QUH->QUH_HRFI := QUM->QUM_HRFI
    		
			MsUnlock()
			FKCOMMIT()
			
			aADD(aDadosQUM,{QUA->QUA_FILIAL,QUA->QUA_NUMAUD,QUM->QUM_SEQ,QUM->QUM_CCUSTO,;
							QUM->QUM_DESTIN,QUM->QUM_EMAIL,QUM->QUM_FILMAT,QUM->QUM_CODAUD,;
							QUM->QUM_DTIN,QUM->QUM_HRIN,QUM->QUM_DTFI,QUM->QUM_HRFI})
            
			dbSelectArea("QUM")
			dbSkip()
		
		Enddo
	Endif			
	
Else
	Help("",1,"AUDJAEXIST") // "Auditoria ja existe."
	Return .F.
EndIf

//Ponto de entrada que envia para o usuário
//os dados da efetivação da auditoria
If ExistBlock("QAD150E2")
	ExecBlock("QAD150E2",.F.,.F.,{aDadosQUM})
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QAD150Lege ³ Autor ³ Eduardo de Souza     ³ Data ³14/01/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe a legenda da Agenda   								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QAD150Lege()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QAD150Lege()
Local aLegen :={}
Local i := 0

if !lPEQ150Leg
	BrwLegenda(cCadastro,OemToAnsi(STR0014), {	{"ENABLE" ,OemToAnsi(STR0015) },; // "Agendada"
   							       				{"DISABLE",OemToAnsi(STR0016) }}) // "Efetivada"   						       				
Else
   For i := 1 to Len(aLegenda)
   		Aadd(aLegen,{aLegenda[i][1],aLegenda[i][2]})
   Next
   		BrwLegenda(cCadastro,STR0007, aLegenda) 
EndIf  						       				
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q150VldUsu ³ Autor ³ Paulo Emidio         ³ Data ³07/09/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao da filial/codigo do Auditor lider/alocado		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q150VldUsu()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Q150VldUsu()

Local lRetorno := .T.
Local cFilMat  := Space(FWSizeFilial())
Local cCodMat  := ""

//Auditores responsaveis pelas Areas Auditadas
If ReadVar() == 'M->QUM_FILMAT'.Or. ReadVar() == 'M->QUM_CODAUD'
	If ReadVar() == 'M->QUM_FILMAT'
		cFilMat := M->QUM_FILMAT
	Else
		cFilMat := oGet:aCols[n][nPosFilRes]
	Endif
	
	If ReadVar() == 'M->QUM_CODAUD'
		cCodMat := M->QUM_CODAUD
	Else
		cCodMat := oGet:aCols[n][nPosAudRes]
	Endif
EndIf

//Auditor Agendado em uma Auditoria
If ReadVar() == 'M->QUA_FILMAT'.Or. ALLTRIM(ReadVar()) == 'M->QUA_MAT'

	If ReadVar() == 'M->QUA_FILMAT'
		cFilMat := M->QUA_FILMAT
	Endif
	
	If AllTrim(ReadVar()) == 'M->QUA_MAT'
		IF Empty(cFilMat)
			cFilMat := M->QUA_FILMAT                  
	    Endif			
		cCodMat := M->QUA_MAT
	Endif
EndIf

If !Empty(cFilMat) .And. !Empty(cCodMat)                                       		
	lRetorno := QA_ChkMat(cFilMat,cCodMat)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificacao se o usuario e Auditor³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF lRetorno
	   lRetorno:=POSICIONE("QAA",1,cFilMat+cCodMat,"QAA_AUDIT")=="1"
	   IF !lRetorno
	   		Msgalert(OemtoAnsi(STR0029)) //"Usuario escolhido não é autorizado como Auditor"      
	   Endif		
	Endif
EndIf


Return(lRetorno)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QA150LinOk³ Autor ³ Aldo Marini Junior   ³ Data ³ 06/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para mudanca/inclusao de linhas               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QA150LinOk                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QADA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QA150LinOk
Local lRetorno := .T.
Local nItem

If !oGet:aCols[N,nUsado+1]
	lRetorno := QA150VLDCC()
	IF lRetorno
		lRetorno := QA150VLARE(N)
	Endif	
Endif


If lRetorno .And. !oGet:aCols[N,nUsado+1]
	For nItem := 2 to Len(aHeader)
		If aHeader[nItem,2]!= "QUM_EMAIL"  .AND.;
		   aHeader[nItem,2]!= "QUM_ALI_WT" .AND.;
		   aHeader[nItem,2]!= "QUM_REC_WT" .AND.;
		   Empty(oGet:aCols[N,nItem])
			Help(" ",1,"QA_CPOOBR")
			lRetorno := .F.
			Exit
		EndIf
	Next nItem
Endif
             
If lRetorno
	lRetorno := QADVDATAUD ("QUA", "QUM", "LIN", Nil, Nil, oGet:aCols, oGet:aHeader, oGet:oBrowse:nAt)
EndIf

Return(lRetorno)

Function QAD150Impr()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QA150VldAcols³ Autor ³ Aldo Marini Junior   ³ Data ³06/09/03³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Acols de Areas Auditadas                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QA150VldAcols()                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPL1 = Logico                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QA150VldAcols()
Local lRetorno := .T.
Local nItA    := 0
Local nItH    := 0
Local nConta  := 0
Local lAudDep := GetMV("MV_QADDEP",.T.,.F.)
Local nItem	
Local nPos1       := Ascan(aHeader,{|x|Alltrim(x[2]) == "QUM_CCUSTO"})      	
Local nPosFilial  := Ascan(aHeader,{|x|Alltrim(x[2]) == "QUM_FILMAT"})	
Local nPosAuditor := Ascan(aHeader,{|x|Alltrim(x[2]) == "QUM_CODAUD"})	

For nItA := 1 to Len(oGet:aCols)
	If !oGet:aCols[nItA,nUsado+1]
		nConta := nConta + 1
		For nItH := 1 to Len(aHeader)
		    IF aHeader[nIth,2]!= "QUM_EMAIL"  .AND.;
		       aHeader[nIth,2]!= "QUM_ALI_WT" .AND.;
		       aHeader[nIth,2]!= "QUM_REC_WT" .AND.;
		       Empty(oGet:aCols[nItA,nItH])
				lRetorno := .F.
				Exit
			EndIf
		Next
		If !lRetorno
			Exit
		Endif
	Endif
Next nItem

If lRetorno .And. nConta == 0
	lRetorno := .F.
Endif

If lRetorno .And. Empty(M->QUA_ALOC)
	lRetorno := .F.
Endif

If !lRetorno
	Help(" ",1,"QA_CPOOBR")
Endif

IF lRetorno
	lRetorno := QA150VLARE()	
Endif	

IF lAudDep .AND. lRetorno
	lRetorno := QA150VLAUD()
Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validacao Filial X Auditor - Auditoria ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno
	lRetorno := QA_ChkMat(M->QUA_FILMAT,M->QUA_MAT)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validacao Filial X Auditor - Departamento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno
	For nItem := 1 to Len(oGet:aCols)		
		If !Empty(oGet:Acols[nItem,nPos1])
			lRetorno := QA_ChkMat(oGet:aCols[nItem,nPosFilial],oGet:aCols[nItem,nPosAuditor])
		EndIf
	Next nItem
Endif     

If lRetorno
	lRetorno := QADVDATAUD ("QUA", "QUM", "ALL", Nil, Nil, oGet:aCols, oGet:aHeader, oGet:oBrowse:nAt)
EndIf

Return (lRetorno)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QA150VLDCC  ³ Autor ³ Aldo Marini Junior   ³ Data ³06/09/03³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Acols - Departamento ( QUM_CCUSTO )                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QA150VLDCC()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPL1 = Logico                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QA150VLDCC()

Local lRetorno := .T.
Local cItem 
Local nItem 
Local nDataHora
Local nPos1    := Ascan(aHeader,{|x|Alltrim(x[2]) == "QUM_CCUSTO"})      
Local nDtFim   := Ascan(aHeader,{|x|Alltrim(x[2]) == "QUM_DTFI"}) 
Local nHrFim   := Ascan(aHeader,{|x|Alltrim(x[2]) == "QUM_HRFI"}) 
Local nDtIni   := Ascan(aHeader,{|x|Alltrim(x[2]) == "QUM_DTIN"}) 
Local nHrIni   := Ascan(aHeader,{|x|Alltrim(x[2]) == "QUM_HRIN"}) 
Local lAudDep  := GetMV("MV_QADDEP",.T.,.F.)

cItem := &(ReadVar())
If !(AllTrim(ReadVar()) == "M->QUM_CCUSTO")
	cItem := oGet:aCols[N,nPos1]
Endif

For nItem := 1 to Len(oGet:aCols)		
	If oGet:aCols[nItem,nPos1] == cItem
		If !oGet:aCols[N,nUsado+1] .And. !oGet:aCols[nItem,nUsado+1]
			If nItem > N
				nDataHora := SubtHoras( aCols[N][nDtFim], aCols[N][nHrFim], aCols[nItem][nDtIni], aCols[nItem][nHrIni] ) 
				If nDataHora < 0 
					Help("",1,"100EXISARE") // "Exitem areas cadastradas em duplicidade" ### "para esta auditoria."
					lRetorno := .F.
			 	Exit
	        	EndIf
		    ElseIf N > nItem
		    	nDataHora := SubtHoras( aCols[nItem][nDtFim], aCols[nItem][nHrFim], aCols[N][nDtIni], aCols[N][nHrIni] ) 
				If nDataHora < 0 
					Help("",1,"100EXISARE") // "Exitem areas cadastradas em duplicidade" ### "para esta auditoria."
					lRetorno := .F.
			 	Exit
	        	EndIf
		    EndIf
		EndIf
	EndIf
Next nItem

If lAudDep .AND. lRetorno 
	lRetorno:= QA150VLAUD()
Endif
  
Return (lRetorno)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QA150VLARE  ³ Autor ³ Telso Carneiro       ³ Data ³29/12/04³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Acols - Area Audit ( QUM_DESTIN )		 		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QA150VLDCC()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPL1 = Logico                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QA150VLARE(Ni)

Local lRetorno := .T.
Local cItem 
Local nItem
Local nPos1    := Ascan(aHeader,{|x|Alltrim(x[2]) == "QUM_DESTIN"})
Local nDtFim   := Ascan(aHeader,{|x|Alltrim(x[2]) == "QUM_DTFI"}) 
Local nHrFim   := Ascan(aHeader,{|x|Alltrim(x[2]) == "QUM_HRFI"}) 
Local nDtIni   := Ascan(aHeader,{|x|Alltrim(x[2]) == "QUM_DTIN"}) 
Local nHrIni   := Ascan(aHeader,{|x|Alltrim(x[2]) == "QUM_HRIN"})       

Default Ni	:= 0

If Ni==0
	For Ni:=1 to Len(oGet:aCols)
		cItem := oGet:aCols[Ni,nPos1]
		For nItem := 1 to Len(oGet:aCols)
			If oGet:aCols[nItem,nPos1] == cItem
				If !oGet:aCols[Ni,nUsado+1] .And. !oGet:aCols[nItem,nUsado+1]
					If nItem > Ni
						nDataHora := SubtHoras( oGet:aCols[Ni][nDtFim], oGet:aCols[Ni][nHrFim], oGet:aCols[nItem][nDtIni], oGet:aCols[nItem][nHrIni] ) 
						If nDataHora < 0 
							Help("",1,"100EXISAREA",,OemToAnsi(STR0027)+Chr(13)+OemToAnsi(STR0028),1) // "Exitem areas cadastradas em duplicidade" ### "para esta auditoria."
							lRetorno := .F.
							Exit
						EndIf
					ElseIf Ni > nItem
				    	nDataHora := SubtHoras( oGet:aCols[nItem][nDtFim], oGet:aCols[nItem][nHrFim], oGet:aCols[Ni][nDtIni], oGet:aCols[Ni][nHrIni] ) 
						If nDataHora < 0
							Help("",1,"100EXISAREA",,OemToAnsi(STR0027)+Chr(13)+OemToAnsi(STR0028),1) // "Exitem areas cadastradas em duplicidade" ### "para esta auditoria."
							lRetorno := .F.
							Exit
						EndIf
					EndIf 
				EndIf
			EndIf
		Next nItem
        IF !lRetorno
			Exit
		Endif	
	Next
Else
	cItem := oGet:aCols[N,nPos1]
	
	For nItem := 1 to Len(oGet:aCols)
		If oGet:aCols[nItem,nPos1] == cItem
			If !oGet:aCols[N,nUsado+1] .And. !oGet:aCols[nItem,nUsado+1]
				If nItem > N
				nDataHora := SubtHoras( aCols[N][nDtFim], aCols[N][nHrFim], aCols[nItem][nDtIni], aCols[nItem][nHrIni] ) 
				If nDataHora < 0 
					Help("",1,"100EXISAREA",,OemToAnsi(STR0027)+Chr(13)+OemToAnsi(STR0028),1) // "Exitem areas cadastradas em duplicidade" ### "para esta auditoria."
					lRetorno := .F.
			 	Exit
	        	EndIf
		    ElseIf N > nItem
		    	nDataHora := SubtHoras( aCols[nItem][nDtFim], aCols[nItem][nHrFim], aCols[N][nDtIni], aCols[N][nHrIni] ) 
				If nDataHora < 0 
					Help("",1,"100EXISAREA",,OemToAnsi(STR0027)+Chr(13)+OemToAnsi(STR0028),1) // "Exitem areas cadastradas em duplicidade" ### "para esta auditoria."
					lRetorno := .F.
			 	Exit
	        	EndIf
		    EndIf
			EndIf
		EndIf
	Next nItem
Endif
Return (lRetorno)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QA150VLAUD   ³ Autor ³ Leandro Sabino       ³ Data ³13/04/06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se o depto auditado nao e o mesmo o qual pertence   ³±±
±±³          | o auditor selecionado.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QA150VLAUD()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPL1 = Logico                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QADA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QA150VLAUD()
Local nItem
Local nPos1       := Ascan(aHeader,{|x|Alltrim(x[2]) == "QUM_CCUSTO"})      
Local nPosFilial  := Ascan(aHeader,{|x|Alltrim(x[2]) == "QUM_FILMAT"})
Local nPosAuditor := Ascan(aHeader,{|x|Alltrim(x[2]) == "QUM_CODAUD"})
Local lRetorno    := .T.

For nItem := 1 to Len(oGet:aCols)		
	If !Empty(oGet:Acols[nItem,nPos1])
		QAA->(dbSetOrder(1))
		If QAA->(DBSeek(oGet:aCols[nItem,nPosFilial]+oGet:aCols[nItem,nPosAuditor]))
			If !oGet:Acols[nItem,Len(oGet:aHeader)+1] 
				If QAA->QAA_CC == oGet:Acols[nItem,nPos1]
					Aviso('',OemToAnsi(STR0030),{'Ok'}) //"O auditor selecionado nao pode auditar seu proprio departamento !"				
	       			lRetorno:= .F.
	   			EndIf
    		EndIf
		EndIf
	EndIf
Next nItem

Return (lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³InSeqQUM  ºAutor  ³Rafael S. Bernardi  º Data ³  11/01/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inicialiazador padrao para o campo vitual QUM_SEQ           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QADA150                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function InSeqQUM()
Local nPos
Local nX
Local nRetorno
For nX := 1 To Len(aHeader)
	If aScan(aHeader[nX],"QUM_SEQ") != 0
		nPos := nX
	EndIf
Next nX

If Len(aCols) == 1
	nRetorno := 1
Else	
	nRetorno := Val(aCols[Len(aCols) - 1][nPos])
	nRetorno++
EndIF
Return StrZero(nRetorno,2)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³InNomQUM  ºAutor  ³Rafael S. Bernardi  º Data ³  11/01/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inicialiazador padrao para o campo vitual QUM_NOMAUD        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA030                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function InNomQUM()
Local nPos
Local nX
For nX := 1 To Len(aHeader)
	If ascan(aHeader[nX],"QUM_CODAUD") != 0
		nPos := nX
	EndIf
Next nX

If Len(aHeader) > 0 .And. aCols[Len(aCols)][nPos] <> NIL
	Posicione("QAA",1,xFilial("QAA")+aCols[Len(aCols)][nPos],"QAA_NOME")
	Return QAA->QAA_NOME
EndIf

Return " "
