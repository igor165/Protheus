#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ-ÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³GH133032  ³ Autor ³ MICROSIGA             ³ Data ³ 20/09/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄ-ÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao Principal                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gestao Hospitalar                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GH133032()

PRIVATE cMessage
PRIVATE aArqUpd	 := {}
PRIVATE aREOPEN	 := {}
PRIVATE oMainWnd
Private aEmpFil := {}

Public cArqEmp 				:= "SigaMat.Emp"
Public __cInterNet := ""
Public nModulo 	   := 51 // modulo SIGAHSP

Set Dele On

lEmpenho				:= .F.
lAtuMnu					:= .F.

Processa({|| ProcATU()},"Processando [GH133032]","Aguarde , processando preparação dos arquivos")
                    
If Select("SM0") > 0
 DbSelectArea("SM0")
 DbCloseArea()
EndIf 

FS_IncItem()

Return()


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcATU   ³ Autor ³                       ³ Data ³  /  /    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento da gravacao dos arquivos           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Baseado na funcao criada por Eduardo Riera em 01/02/2002   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ProcATU()
Local cTexto    	:= ""
Local cFile     	:= ""
Local cMask     	:= "Arquivos Texto (*.TXT) |*.txt|"
Local nRecno    	:= 0
Local nI        	:= 0
Local nX        	:= 0
Local aRecnoSM0 	:= {}
Local lOpen     	:= .F.

ProcRegua(1)
IncProc("Verificando integridade dos dicionários....")
If (lOpen := IIF(Alias() <> "SM0", MyOpenSm0Ex(), .T. ))

	dbSelectArea("SM0")
	dbGotop()
	While !Eof()
  		If Ascan(aRecnoSM0,{ |x| x[2] == M0_CODIGO}) == 0
			Aadd(aRecnoSM0,{Recno(),M0_CODIGO})
		EndIf			
		
		aAdd(aEmpFil, {SM0->M0_CODIGO, SM0->M0_CODFIL})
		dbSkip()
	EndDo	

	If lOpen
		For nI := 1 To Len(aRecnoSM0)
			SM0->(dbGoto(aRecnoSM0[nI,1]))
			RpcSetType(2)
			RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
 		nModulo := 51 // modulo SIGAHSP
			lMsFinalAuto := .F.
			__cInterNet 	:= ""
			cTexto += Replicate("-",128)+CHR(13)+CHR(10)
			cTexto += "Empresa : "+SM0->M0_CODIGO+SM0->M0_NOME+CHR(13)+CHR(10)

			ProcRegua(8)

			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Funções descontinuadas pelo SGBD: GeraSX3() e GeraSIX()" , 0, 0, {})
	
			__SetX31Mode(.F.)
			For nX := 1 To Len(aArqUpd)
				IncProc("Atualizando estruturas. Aguarde... ["+aArqUpd[nx]+"]")
				If Select(aArqUpd[nx])>0
					dbSelecTArea(aArqUpd[nx])
					dbCloseArea()
				EndIf
				X31UpdTable(aArqUpd[nx])
				If __GetX31Error()
					Alert(__GetX31Trace())
					Aviso("Atencao!","Ocorreu um erro desconhecido durante a atualizacao da tabela : "+ aArqUpd[nx] + ". Verifique a integridade do dicionario e da tabela.",{"Continuar"},2)
					cTexto += "Ocorreu um erro desconhecido durante a atualizacao da estrutura da tabela : "+aArqUpd[nx] +CHR(13)+CHR(10)
				EndIf
				dbSelectArea(aArqUpd[nx])
			Next nX		
   
			RpcClearEnv()
			If !( lOpen := MyOpenSm0Ex() )
				Exit
		 EndIf
		Next nI
		
		If lOpen
			
			cTexto 				:= "Log da atualizacao " + CHR(13) + CHR(10) + cTexto
			__cFileLog := MemoWrite(Criatrab(,.f.) + ".LOG", cTexto)
			
			DEFINE FONT oFont NAME "Mono AS" SIZE 5,12
			DEFINE MSDIALOG oDlg TITLE "Atualizador [GH133032] - Atualizacao concluida." From 3,0 to 340,417 PIXEL
				@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL
				oMemo:bRClicked := {||AllwaysTrue()}
				oMemo:oFont:=oFont
				DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
				DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
			ACTIVATE MSDIALOG oDlg CENTER
	
		EndIf
		
	EndIf
		
EndIf 	

Return(Nil)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MyOpenSM0Ex³ Autor ³Sergio Silveira       ³ Data ³07/01/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a abertura do SM0 exclusivo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao FIS                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MyOpenSM0Ex()

Local lOpen := .F.
Local nLoop := 0

For nLoop := 1 To 20
	openSM0( cNumEmp,.F. )
	If !Empty( Select( "SM0" ) )
		lOpen := .T.
		dbSetIndex("SIGAMAT.IND")
		Exit	
	EndIf
	Sleep( 500 )
Next nLoop

If !lOpen
	Aviso( "Atencao !", "Nao foi possivel a abertura da tabela de empresas de forma exclusiva !", { "Ok" }, 2 )
EndIf

Return( lOpen )



Static Function FS_IncItem()
 Local nEmpFil := 0
  
 For nEmpFil := 1 To Len(aEmpFil) 
             
  RpcSetType(2)
	 RpcSetEnv(aEmpFil[nEmpFil][1], aEmpFil[nEmpFil][2])
  nModulo := 51 // modulo SIGAHSP
	 lMsFinalAuto := .F.
	 __cInterNet 	:= ""
	 
	 Processa({|| FS_EmpItem()}, "Proc. Emp/Fil " + aEmpFil[nEmpFil][1] + "/" + aEmpFil[nEmpFil][2], "Aguarde, gravando o campo CDITEM")
  
  RpcClearEnv()
  
 Next 

Return(Nil)  

Static Function FS_EmpItem()
  Local cCDItem := "000"
  Local cSql  := ""
  Local nCont := 0
  Local aVet  := {"GA4","GA5","GA6","GAC", "GDG"}
  Local cCodCon := "", cCodPla := "", nRecTot := 0, nPlaAtu := 0
  
  For nCont := 1 To Len(aVet)                                                 
  
   cSQL := "SELECT COUNT(DISTINCT " + aVet[nCont] + "_CODCON || " + aVet[nCont] + "_CODPLA) NRECCNT "
   cSQL += " FROM " + RetSQLName(aVet[nCont]) + " " + aVet[nCont]
   cSQL += " WHERE " + aVet[nCont] + "_FILIAL = '" + xFilial(aVet[nCont]) + "' AND " + aVet[nCont] + ".D_E_L_E_T_ <> '*'"
   
   cSQL := ChangeQuery(cSQL)
 	 TCQUERY cSQL NEW ALIAS "QRY"
 	              
 	 nRecTot += QRY->NRECCNT
 	 
 	 DbCloseArea()
   
  Next
  
  ProcRegua(nRecTot)
 
	 For nCont := 1 to Len(aVet)
	  
  	cSQL := "SELECT R_E_C_N_O_ NOREC, " + aVet[nCont] + "_CODCON CODCON, " + aVet[nCont] + "_CODPLA CODPLA"
  	cSQL += " FROM " + RetSQLName(aVet[nCont]) + " " + aVet[nCont]
  	cSQL += " WHERE " + aVet[nCont] + "_FILIAL = '" + xFilial(aVet[nCont]) + "' AND " + aVet[nCont] + ".D_E_L_E_T_ <> '*'"
  	cSQL += " ORDER BY " + aVet[nCont] + "_CODCON, " + aVet[nCont] + "_CODPLA"
	
	  cSQL := ChangeQuery(cSQL)
	  TCQUERY cSQL NEW ALIAS "QRY"
	
	  DbSelectArea("QRY")
	  DbGoTop()
	  
	  While !Eof()
	  	   
	   Begin Transaction
	    
	    cCodCon := QRY->CODCON
	    cCodPla := QRY->CODPLA
	    
	    nPlaAtu++
	    
	    IncProc("Arq. [" + aVet[nCont] + "] Convenio [" + cCodCon + "] Plano [" + cCodPla + "][" + AllTrim(Str(nPlaAtu)) + "/" + AllTrim(Str(nRecTot)) + "]")
	    ProcessMessages()
	    
	    cCDItem := "000"
	    
	    While !EOF() .And. cCodCon == QRY->CODCON .And. cCodPla == QRY->CODPLA
	     
	     cCDItem := Soma1(cCDItem, 3)
	     
  	   cQry := "UPDATE " + RetSqlName(aVet[nCont]) + " SET " + aVet[nCont] + "_CDITEM = '" + cCDItem + "'"
 	    cQry += " WHERE R_E_C_N_O_ = " + AllTrim(Str(QRY->NOREC))
	    	
	    	TcSqlExec(cQry)
 	    
 	    DbSelectArea("QRY")
 	    DbSkip()
 	   EndDo 	       
 	   
	   End Transaction
	  End
	  DbCloseArea()
  Next nCont
  
Return(Nil)