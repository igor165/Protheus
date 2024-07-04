#INCLUDE "Protheus.ch"
#INCLUDE "UPDGHPAD.ch"

#DEFINE CRLF	CHR(13)+CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ UPDGH096 บ Autor ณ Alexandre Villar   บ Data ณ 25/10/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Update do Campo "GM8_STATUS" para considerar e tratar os   บฑฑ
ฑฑบ          ณ casos de Transferencia de Agendamento.                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaHSP.                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function UPDGH096()

Local nOpca			:= 0
Local aSays			:= {}
Local aButtons		:= {}

Private nModulo		:= 51 // modulo SIGAHSP
Private cMessage
Private aArqUpd		:= {}
Private aREOPEN		:= {} 
Private oMainWnd 
Private cCadastro	:= STR0001 // "Compatibilizador de Dicionแrios x Banco de dados"
Private cCompat		:= "UPDGHXXX"
Private cFnc		:= "TFWS06"
Private cRef		:= "Atualiza็ใo do GM8_STATUS"

Set Dele On

//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ Monta texto para a Janela de Processaento.								บ
//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
aadd( aSays , STR0002 ) //"Esta rotina irแ efetuar a compatibiliza็ใo dos dicionแrios e banco de dados,"
aadd( aSays , STR0003 ) //"e demais ajustes referentes a FNC abaixo: "
aadd( aSays , "   Chamado: " + cFnc )
aadd( aSays , STR0004 + cRef ) //"   Refer๊ncia: "
aadd( aSays , '   Update no Campo "GM8_STATUS": inclusใo de novo Status: 8 - Transferido' )
aadd( aSays , STR0005 ) //"Aten็ใo: efetuar backup dos dicionแrios e do banco de dados previamente "

//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ Monta Botoes para a Janela de Processaento.								บ
//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
aadd( aButtons , { 1 , .T. , { || nOpca := 1 , FechaBatch() } } )
aadd( aButtons , { 2 , .T. , { || nOpca := 0 , FechaBatch() } } )

//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ Exibe a Janela de Processaento.											บ
//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
FormBatch( cCadastro , aSays , aButtons ,, 230 )

//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ Se confirmado executa Rotina de Processaento.							บ
//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
If  nOpca == 1

	If  Aviso( STR0006 , STR0007 , {"Sim","Nใo"} ) == 1
          Processa( { || UpdEmp() } , "Processando" , "Aguarde, processando prepara็ใo dos arquivos" , .F. )
    Endif
    
Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ProcATU  บ Autor ณ Alexandre Villar   บ Data ณ 25/10/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processamento da Atualizacao do Dicionario de dados para o บฑฑ
ฑฑบ          ณ Update do Campo GM8_STATUS                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaHSP                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ProcATU( lEnd , aRecnoSM0 , lOpen )

Local cTexto    	:= ""
Local cFile     	:= ""
Local cMask     	:= "Arquivos Texto (*.TXT) |*.txt|"
Local nRecno    	:= 0
Local nI        	:= 0
Local nX        	:= 0 
Local cCodigo		:= ""

ProcRegua(1)
IncProc(STR0010) //"Verificando integridade dos dicionแrios...."

If lOpen  
   		
	lSel:=.F.
	
	For nI := 1 To Len(aRecnoSM0)
	
		DBSelectArea("SM0")
 		SM0->( DBGotop() )
		SM0->( DBGoto( aRecnoSM0[nI][09] ) )
		
		If !aRecnoSM0[nI][01]
			Loop
		Endif
		
		lSel := .T.
		
		RpcSetType(2)
		RpcSetEnv( SM0->M0_CODIGO , FWGETCODFILIAL )
		
 		nModulo			:= 51 // modulo SIGAHSP
		lMsFinalAuto	:= .F.
		
		cTexto += Replicate( "-" , 128 ) + CRLF
		cTexto += STR0025 + aRecnoSM0[nI][2] + CRLF //"Grupo Empresa: "
		
		ProcRegua(3)
  		
		If  SM0->M0_CODIGO <> cCodigo
		
			conout( "Fun็๕es descontinuadas pelo SGBD: GeraSX3()" )

			cCodigo := SM0->M0_CODIGO
			
		Endif
		
		__SetX31Mode(.F.)
		
		For nX := 1 To Len(aArqUpd)
		
			IncProc( STR0016 +"["+ aArqUpd[nx] +"]" )
			
			If Select(aArqUpd[nx])>0
			
				DBSelecTArea(aArqUpd[nx])
				(aArqUpd[nx])->( DBCloseArea() )
				
			EndIf
			
			X31UpdTable(aArqUpd[nx])
			
			If __GetX31Error()
			
				Alert(__GetX31Trace())
				Aviso(STR0017,STR0019 + aArqUpd[nx] + STR0018 ,{STR0030},2) //"Atencao!","Ocorreu um erro desconhecido durante a atualizacao da tabela : " //". Verifique a integridade do dicionario e da tabela."  // "Continuar"
				cTexto += STR0019 +aArqUpd[nx]  + CRLF //"Ocorreu um erro desconhecido durante a atualizacao da estrutura da tabela : "
				
			EndIf
			
			DBSelectArea(aArqUpd[nx])
			
		Next nX

		RpcClearEnv()
		
		If !( lOpen := MyOpenSm0Ex() )
			Exit
		EndIf
		
	Next nI
	
	If lOpen
		
		cTexto := STR0020 + CRLF + cTexto //"Log da atualizacao "
		
		If !lSel 
			cTexto+= STR0026//"Nใo foi selecionada nenhuma empresa para Atualiza็ใo"
		Endif
		
		__cFileLog := MemoWrite(Criatrab(,.f.) + ".LOG", cTexto)
		
		DEFINE FONT oFont NAME "Mono AS" SIZE 5,12
		
		DEFINE MSDIALOG oDlg TITLE STR0021+" ["+cFnc+"]"+ STR0022  From 3,0 to 340,417 PIXEL  //"Atualizador   Atualizacao concluida."
		
			@ 5 , 5 GET oMemo VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL
			oMemo:bRClicked	:= {||AllwaysTrue()}
			oMemo:oFont		:=oFont
			
			DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
			DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
		
		ACTIVATE MSDIALOG oDlg CENTER

	EndIf
	
EndIf		

Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณMyOpenSM0Exณ Autor ณSergio Silveira       ณ Data ณ07/01/2003ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Efetua a abertura do SM0 exclusivo                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Atualizacao FIS                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
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
	Aviso( STR0017, STR0023, { "Ok" }, 2 ) //Aten็ใo , "Nao foi possivel a abertura da tabela de empresas de forma exclusiva !"
EndIf

Return( lOpen )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ UpdEmp   ณ Autor ณ Luciano Aparecido     ณ Data ณ 15.05.07 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Trata Empresa. Verifica as Empresas para Atualizar         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SigaHSP		                                              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function UpdEmp()

Local aRecnoSM0	:= {}
Local aRecSM0	:= {}
Local cVar		:= Nil
Local oDlg		:= Nil
Local cTitulo	:= STR0027  //"Escolha a(s) Empresa(s) que serแ(ใo) Atualizada(s)"
Local lMark		:= .F.
Local lOpen		:= .F.
Local nI		:=0
Local oOk		:= LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
Local oNo		:= LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
Local oChk		:= Nil                                
Local bCode		:= {||oDlg:End(),Processa({|lEnd| ProcATU(@lEnd,aRecnoSM0,lOpen)},STR0008,STR0009,.F.)} //"Processando","Aguarde, processando prepara็ใo dos arquivos"

Private lChk	:= .F.
Private oLbx	:= Nil

If ( lOpen := MyOpenSm0Ex() )

	DBSelectArea("SM0")
	SM0->( DBGotop() )
	
	//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	//บ Carrega o Vetor															บ
	//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ		
	aRecSM0 := FWLoadSM0()
	
	If Empty( aRecSM0 )
	
   		Aviso( cTitulo, STR0028, {"Ok"} ) //"Nao existe bancos a consultar"
   		Return()
   		
 	Else
 	
		For nI := 1 to  len(aRecSM0)
		
			Aadd( aRecnoSM0 , {	lMark				,;
								aRecSM0[nI][1]		,;
								aRecSM0[nI][6]		,;
								aRecSM0[nI][2]		,;
								aRecSM0[nI][3]		,;
								aRecSM0[nI][4]		,;
								aRecSM0[nI][5]		,;
								aRecSM0[nI][7]		,;
								aRecSM0[nI][12]		})
			
		Next nI
 	
	Endif

	//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	//บ Monta a tela para usuario visualizar consulta							บ
	//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,730 PIXEL
	   
		@ 010 , 010 LISTBOX oLbx VAR cVar FIELDS HEADER " ","Grupo Emp","Descricao", "Codigo","Empresa","Unidade","Filial","Descricao","Recno" ;
			SIZE 350,090 OF oDlg PIXEL ON dblClick(aRecnoSM0[oLbx:nAt,1] := !aRecnoSM0[oLbx:nAt,1],oLbx:Refresh())
	
		oLbx:SetArray( aRecnoSM0)
		oLbx:bLine := {|| {Iif(	aRecnoSM0[oLbx:nAt,1],oOk,oNo)		,;
		                       	aRecnoSM0[oLbx:nAt,2]				,;
		                       	aRecnoSM0[oLbx:nAt,3]				,;
		                       	aRecnoSM0[oLbx:nAt,4]				,;
		                       	aRecnoSM0[oLbx:nAt,5]				,;
		                       	aRecnoSM0[oLbx:nAt,6]				,;
		                       	aRecnoSM0[oLbx:nAt,7]				,;
		                       	aRecnoSM0[oLbx:nAt,8]				,;
		                       	Alltrim(Str(aRecnoSM0[oLbx:nAt,9])	)}}
		                       	
		@ 110 , 010 CHECKBOX oChk VAR lChk PROMPT  STR0029 SIZE 60,007 PIXEL OF oDlg ON CLICK(aEval(aRecnoSM0,{|x| x[1]:=lChk}),oLbx:Refresh())
	 
		DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION Eval(bCode) ENABLE OF oDlg
		
	ACTIVATE MSDIALOG oDlg CENTER

EndIf

Return()