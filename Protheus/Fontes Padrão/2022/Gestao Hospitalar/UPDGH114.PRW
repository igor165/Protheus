#INCLUDE "protheus.ch"
#INCLUDE "UPDGHPAD.ch"     


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ UPDGH114()³ Autor ³ MAICON DOS SANTOS     ³ Data ³ 13/11/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualização do tamanho do campo GAT_CODPLA  		            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gestao Hospitalar                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±                 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function UPDGH114()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis                                                       |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local nOpca       := 0
Local aSays       := {}, aButtons := {}   
Local aRecnoSM0 	:= {}  
Local lOpen     	:= .F.  
Private nModulo 	:= 51 // modulo SIGAHSP
Private cMessage
Private aArqUpd	  := {}
Private aREOPEN	  := {} 
Private oMainWnd 
Private cCadastro := STR0001 // "Compatibilizador de Dicionários x Banco de dados"
Private cCompat		:= "UPDGH114"
Private cFnc		:= "TQZOCY"
Private cRef01 		:= "Atualização do tamanho do campo GAT_CODPLA. "
Set Dele On      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta texto para janela de processamento                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aSays,STR0002)  //"Esta rotina irá efetuar a compatibilização dos dicionários e banco de dados,"
aadd(aSays,STR0003)//"e demais ajustes referentes a FNC abaixo:"
AADD(aSays,"   CHAMADO: " + cFnc)
AADD(aSays, STR0004 + cRef01)//"   Referência: "
aadd(aSays, STR0005)   //"Atenção: efetuar backup dos dicionários e do banco de dados previamente "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta botoes para janela de processamento                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aButtons, { 1,.T.,{|| nOpca := 1, FechaBatch() }} )
aadd(aButtons, { 2,.T.,{|| nOpca := 0, FechaBatch() }} )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe janela de processamento                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FormBatch( cCadastro, aSays, aButtons,, 250 )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa calculo                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  nOpca == 1
	If  Aviso(STR0006, STR0007, {"Sim","Não"}) == 1
          Processa({||UpdEmp(aRecnoSM0,lOpen)},STR0008,STR0009,.F.)//"Processando", "Aguarde , processando preparação dos arquivos"
    Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim do programa                                                            |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
Static Function ProcATU(lEnd,aRecnoSM0,lOpen)
Local cTexto    	:= ""
Local cFile     	:= ""
Local cMask     	:= "Arquivos Texto (*.TXT) |*.txt|"
Local nRecno    	:= 0
Local nI        	:= 0
Local nX        	:= 0 
Local cCodigo		:= ""


ProcRegua(1)
IncProc(STR0010)//"Verificando integridade dos dicionários...."

   	If lOpen  
   		
		lSel:=.F.
		For nI := 1 To Len(aRecnoSM0)
			DbSelectArea("SM0")
   			DbGotop()
			SM0->(dbGoto(aRecnoSM0[nI,9]))
					
			If !aRecnoSM0[nI,1]    
				loop
			Endif 
			lSel:=.T.   
						
			RpcSetType(2)
			RpcSetEnv(  SM0->M0_CODIGO, FWGETCODFILIAL)
			
 			nModulo := 51 // modulo SIGAHSP
			lMsFinalAuto := .F.
			cTexto += Replicate("-",128)+CHR(13)+CHR(10)
			cTexto += STR0025 + aRecnoSM0[nI][2]+CHR(13)+CHR(10)//"Grupo Empresa: "

			ProcRegua(8)
            

			If  SM0->M0_CODIGO <> cCodigo   //Só irá executar manutenção no SX se For Grupo Empresas Diferentes
			
				Begin Transaction
				                
				IncProc("Analisando Dicionarios...")
			   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			    //³ Atualiza SX3                                                               |
			    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			    cTexto += Replicate("-",128)+CHR(13)+CHR(10)
			    cTexto += HSPAtuSX3()
     			End Transaction
	        
	
				cCodigo := SM0->M0_CODIGO
			Endif 
			
			__SetX31Mode(.F.)
			For nX := 1 To Len(aArqUpd)
				IncProc(STR0016 +"["+aArqUpd[nx]+"]")
				If Select(aArqUpd[nx])>0
					dbSelecTArea(aArqUpd[nx])
					dbCloseArea()
				EndIf
				X31UpdTable(aArqUpd[nx])
				If __GetX31Error()
					Alert(__GetX31Trace())
					Aviso(STR0017,STR0019 + aArqUpd[nx] + STR0018 ,{STR0030},2) //"Atencao!","Ocorreu um erro desconhecido durante a atualizacao da tabela : " //". Verifique a integridade do dicionario e da tabela."  // "Continuar"
					cTexto += STR0019 +aArqUpd[nx] +CHR(13)+CHR(10) //"Ocorreu um erro desconhecido durante a atualizacao da estrutura da tabela : "
				EndIf
				dbSelectArea(aArqUpd[nx])
			Next nX	

			RpcClearEnv()
			If !( lOpen := MyOpenSm0Ex() )
				Exit
		 EndIf
		Next nI
		
		If lOpen
			
			cTexto 				:= STR0020 + CHR(13) + CHR(10) + cTexto //"Log da atualizacao "
			
				If !lSel 
					cTexto+= STR0026//"Não foram selecionadas nenhuma empresa para Atualização"
				Endif
			__cFileLog := MemoWrite(Criatrab(,.f.) + ".LOG", cTexto)
			
			DEFINE FONT oFont NAME "Mono AS" SIZE 5,12
			DEFINE MSDIALOG oDlg TITLE STR0021+" ["+cFnc+"]"+ STR0022  From 3,0 to 340,417 PIXEL  //"Atualizador   Atualizacao concluida."
				@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL
				oMemo:bRClicked := {||AllwaysTrue()}
				oMemo:oFont:=oFont
				DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
				DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
			ACTIVATE MSDIALOG oDlg CENTER
	
		EndIf
		
	EndIf
		

Return(Nil)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ UpdEmp   ³ Autor ³ Luciano Aparecido     ³ Data ³ 15.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Trata Empresa. Verifica as Empresas para Atualizar         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao PLS                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

static function  UpdEmp(aRecnoSM0,lOpen) 
		
Local cVar     := Nil
Local oDlg     := Nil
Local cTitulo  := STR0027  //"Escolha a(s) Empresa(s) que será(ão) Atualizada(s)"
Local lMark    := .F.
Local oOk      := LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
Local oNo      := LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
Local oChk     := Nil                                
Local bCode := {||oDlg:End(),Processa({|lEnd| ProcATU(@lEnd,aRecnoSM0,lOpen)},STR0008,STR0009,.F.)} //"Processando","Aguarde, processando preparação dos arquivos"
Local nI :=0
Local aRecSM0 :={}

Private lChk     := .F.
Private oLbx := Nil


If ( lOpen := MyOpenSm0Ex() )
	dbSelectArea("SM0")


 /////////////////////////////////////////
//| Carrega o vetor conforme a condicao |/
//////////////////////////////////////////
	dbGotop()
		
	aRecSM0:=FWLoadSM0()		
		

	For nI := 1 to  len(aRecSM0)
		Aadd(aRecnoSM0,{lMark,aRecSM0[nI][1],aRecSM0[nI][6],aRecSM0[nI][2],aRecSM0[nI][3],aRecSM0[nI][4],aRecSM0[nI][5],aRecSM0[nI][7],aRecSM0[nI][12]})
	Next nI 

///////////////////////////////////////////////////
//| Monta a tela para usuario visualizar consulta |
///////////////////////////////////////////////////
	If Len( aRecnoSM0 ) == 0
   		Aviso( cTitulo, STR0028, {"Ok"} ) //"Nao existe bancos a consultar"
   	Return
Endif

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,700 PIXEL
   
@ 10,10 LISTBOX oLbx VAR cVar FIELDS HEADER ;
   " ","Grupo Emp","Descricao", "Codigo","Empresa","Unidade","Filial","Descricao","Recno" ;
   SIZE 335,095 OF oDlg PIXEL ON dblClick(aRecnoSM0[oLbx:nAt,1] := !aRecnoSM0[oLbx:nAt,1],oLbx:Refresh())

oLbx:SetArray( aRecnoSM0)
oLbx:bLine := {|| {Iif(aRecnoSM0[oLbx:nAt,1],oOk,oNo),;
                       aRecnoSM0[oLbx:nAt,2],;
                       aRecnoSM0[oLbx:nAt,3],;
                       aRecnoSM0[oLbx:nAt,4],;
                       aRecnoSM0[oLbx:nAt,5],;
                       aRecnoSM0[oLbx:nAt,6],;
                       aRecnoSM0[oLbx:nAt,7],;
                       aRecnoSM0[oLbx:nAt,8],;
                       Alltrim(Str(aRecnoSM0[oLbx:nAt,9]))}} 
     
////////////////////////////////////////////////////////////////////
//| Para marcar e desmarcar todos existem duas opçoes, acompanhe...
////////////////////////////////////////////////////////////////////


@ 110,10 CHECKBOX oChk VAR lChk PROMPT  STR0029 SIZE 60,007 PIXEL OF oDlg ; //"Marca/Desmarca"
         ON CLICK(aEval(aRecnoSM0,{|x| x[1]:=lChk}),oLbx:Refresh())
 
DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION Eval(bCode) ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTER
Endif

Return


Static Function HSPAtuSX3()
Local aSX3           := {}
Local ni              := 0
Local nj              := 0
Local lSX3	         := .F.
Local cTexto         := ""
Local cAlias         := ""   
Local aEstrut := { "X3_ARQUIVO","X3_ORDEM"  ,"X3_CAMPO"  ,"X3_TIPO"   ,"X3_TAMANHO","X3_DECIMAL",;
                   "X3_TITULO" ,"X3_TITSPA" ,"X3_TITENG" ,"X3_DESCRIC","X3_DESCSPA","X3_DESCENG",;
                   "X3_PICTURE","X3_VALID"  ,"X3_USADO"  ,"X3_RELACAO","X3_F3"     ,"X3_NIVEL"  ,;
                   "X3_RESERV" ,"X3_CHECK"  ,"X3_TRIGGER","X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,;
                   "X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER","X3_CBOX"   ,"X3_CBOXSPA","X3_CBOXENG",;
                   "X3_PICTVAR","X3_WHEN"   ,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER", "X3_PYME"}     

aAdd(aSX3,{'GAT',;											// Arquivo
		'06',;													// Ordem
		'GAT_CODPLA',;				  						// Campo
		'C',;		   											// Tipo
		50,;													// Tamanho
		0,;														// Decimal
		'Plano',;	   											// Titulo
		'Plan',; 		      									// Titulo SPA
		'Health plan',;     	    							// Titulo ENG
		'Plano',;		 										// Descricao
		'Plan del Convenio',;								// Descricao SPA
		'Health Insurance Plan',;							// Descricao ENG
		'@!',;													// Picture           			
		'HS_VLDA51(2)',;  									// Valid
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
		Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),; //Usado
		'',;                           					  	// Relacao
		'GCM',;      				  							// F3
		1,;				 				   						// Nivel
   		'ÿA',;	   	 											// Reserv
		'',;													// Check
		'',;													// Trigger
		'',;													// Propri
		'S',;													// Browse
		'A',;													// Visual
		'R',;													// Context
		'',;													// ObrDigat
		'',;													// VldUser
		'',;	                 	  					     	// CBox
		'',;													// CBox SPA
		'',;													// CBox ENG
		'',;												    // PictVar
		'',;													// When
		'',;													// IniBrw
		'',;													// SXG
		'',;				   									// Folder			
		'N',;                        	   					// PYME
		{''}})	  												// Help
	cTexto:= "Foi ajustado o campo GAT_CODPLA" + CRLF 	
	
ProcRegua(Len(aSX3))
SX3->(DbSetOrder(2))	
dBSelectArea("SX3")	
For nI:= 1 To Len(aSX3)
		
	If !Empty(aSX3[nI][1])
		If !dbSeek(aSX3[nI,3])
			RecLock("SX3",.T.)
		Else
			RecLock("SX3",.F.)
		EndIf
		lSX3	:= .T.
		If !(aSX3[nI,1]$cAlias)
			cAlias += CHR(13)+CHR(10)+aSX3[nI,1]+CHR(13)+CHR(10)                                            
			aAdd(aArqUpd,aSX3[nI,1])
		EndIf
		For nJ:=1 To Len(aSX3[nI])
			If nJ < 37
				If FieldPos(aEstrut[nJ])>0 .And. aSX3[nI,nJ] != Nil
					FieldPut(FieldPos(aEstrut[nJ]),aSX3[nI,nJ])
				EndIf              
				If aEstrut[nJ] == "L_DELETED"
					If Len(aSX3[nI]) == nJ .and. aSX3[nI,nJ] != Nil .and. aSX3[nI,nJ] == .T.
						DbDelete()
					 Endif
				Endif
			Else 
				PutHelp("P"+aSX3[nI,3],aSX3[nI,37],aSX3[nI,37],aSX3[nI,37],.T.)	
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()
		IncProc("Atualizando Dicionário de Dados...") 
	EndIf
next nI       

Return cTexto
	             
