#INCLUDE "protheus.ch"      
#INCLUDE "TCFA002.CH"

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ TCFA002  ³ Autor ³ Tatiane Matias             ³ Data ³06/02/2006 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³ Informacoes necessarias para o Informe de Rendimento             ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³ Generico                                                         ³
ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                   ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Programador ³ Data   ³ FNC        ³  Motivo da Alteracao                     ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Cecilia Car.³24/07/14³TQEA22      ³Incluido o fonte da 11 para a 12 e efetua-³ 
³            ³        ³            ³da a limpeza.                             ³ 
ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function TCFA002()

Local aArea				:= GetArea()
Local nHdl				:= 0.00
Local nHdlAnt			:= 0.00
Local cFile				:= "GRHINF2.FCH"    //Arquivo Novo
Local cFileAnt			:= "GRHINF.FCH"     //Arquivo Antigo
Local nTamArq			:= 0.00
Local nFor				:= 0.00
Local nX				:= 0.00
Local cBuffer			:= ""
Local aDados 			:= {}
Local aAdvSize			:= {}
Local aInfoAdvSize		:= {}
Local aObjCoords		:= {}
Local aObjSize			:= {}
Local oFont
Local oDlg     
Local cCadastro 		:= OemToAnsi(STR0001)  //"Configuracao do Informe de Rendimento"
Local aHeader			:= {}
Local bSet15			:= { || NIL }
Local bSet24			:= { || NIL }
Local nOpcA 			:= 0	
Local nGd_Insert := 1  //Insert
Local nGd_UpDate := 2  //Update
Local nGd_Delete := 4  //Delete

Private oGet		:= NIL

//Le o arquivo com as configuracoes do Informe de Rendimento e armazena em array
IF File(cFile)
	nHdl := Fopen(cfile,64)
	fSeek(nHdl,0,0)
	nTamArq := fSeek(nHdl,0,2)
	fSeek(nHdl,0,0)
	nFor := nTamArq / (80+FWGETTAMFILIAL)
	For nX := 1 To nFor
		cBuffer := Space(81+FWGETTAMFILIAL)
		fRead(nHdl,@cBuffer,81+FWGETTAMFILIAL)
		aAdd(aDados, { Substr(cBuffer,77,2)	,;     	    			// Empresa
							Substr(cBuffer,80,FWGETTAMFILIAL),;		// Filial
							Substr(cBuffer,1,4) 	,;				// Ano Base
							Substr(cBuffer,6,4)		,;				// Data Liberacao
							Substr(cBuffer,11,4)	,;				// Data do Innforme de Rendimento
						   	Substr(cBuffer,16,60)	,;				// Responsavel
							.F. 					})				// GDDELETED 

	Next nX                              	
	aDados:= aSort(aDados,,,{|x,y| x[1]+x[2]+x[3] > y[1]+y[2]+y[3]}) //Empresa + Filial + AnoBase
	fClose(nHdl)

Else //senao existir arquivo, criar arquivo novo copiando o conteundo do antigo.

	IF File(cFileAnt)
		nHandle := FCreate(cFile)
		nHdlAnt := Fopen(cfileAnt,64)
		fSeek(nHdlAnt,0,0)
		nTamArq := fSeek(nHdlAnt,0,2)
		fSeek(nHdlAnt,0,0)

		nFor 	:= nTamArq / 76
		For nX := 1 To nFor
			cBuffer := Space(77)
			fRead(nHdlAnt,@cBuffer,77)
			cBuffer := Substr(cBuffer,1,4) + " " + Substr(cBuffer,6,4) + " " + Substr(cBuffer,11,4) + " " + Substr(cBuffer,16,60) + "  " + " " + "  " + Chr(13)+Chr(10)
			Fwrite(nHandle,cBuffer,83)
		
			aAdd(aDados, {  space(2)	,;				// Empresa
							space(FWGETTAMFILIAL)	,;	// Filial
							Substr(cBuffer,1,4) 	,;	// Ano Base
							Substr(cBuffer,6,4)		,;	// Data Liberacao
							Substr(cBuffer,11,4)	,;	// Data do Innforme de Rendimento
							Substr(cBuffer,16,60)	,;	// Responsavel
							.F. 					})	// GDDELETED 

		Next nX
	
		fClose(nHandle) //Fecha arquivo novo
		fClose(nHdlAnt) //Fecha arquivo antigo.
	EndIf
EndIF

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize := MsObjSize( aInfoAdvSize , aObjCoords )

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
DEFINE MSDIALOG oDlg TITLE cCadastro From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

			// Titulo				, campo      ,  Picture							, Tamanho		, Decimal, Valid			, Usado, Tipo, F3
aAdd(aHeader,{ "Empresa"			, "T002EMP"	 , "!!" 							, 2	    		, 0		 , "ValEmpTc02()"	, "û"  , "C" , "EMP"	} )
aAdd(aHeader,{ "Filial"				, "T002FIL"	 , Replicate("!", FWGETTAMFILIAL)	, FWGETTAMFILIAL, 0		 , "ValFilTc02()"	, "û"  , "C" , "SM0"	} )
aAdd(aHeader,{ "Ano Base"			, "T002ANO"	 , "9999" 							, 4	    		, 0		 ,   				, "û"  , "C" , " "		} )
aAdd(aHeader,{ "Dia/Mes Liberacao"	, "T002DTLIB", "@R 99/99"						, 6	    		, 0		 ,     				, "û"  , "C" , " "		} )
aAdd(aHeader,{ "Dia/Mes Informe"	, "T002DTINF", "@R 99/99"  						, 6	    		, 0		 ,   				, "û"  , "C" , " "		} )
aAdd(aHeader,{ "Responsavel"		, "T002RESP" , "!@"	 	   						, 60	    	, 0		 ,     				, "û"  , "C" , " "		} )

oGet := MsNewGetDados():New(aObjSize[1,1] + 6,;							// nTop
	 								 aObjSize[1,2],;						// nLeft
	 								 aObjSize[1,3],;						// nBottom
           		          			 aObjSize[1,4],;						// nRright
									 nGd_Insert + nGd_UpDate + nGd_Delete,;	// controle do que podera ser realizado na GetDado - nstyle
									 "Tc002LinOk",;							// funcao para validar a edicao da linha - ulinhaOK
									 "Tc002TudOk",;							// funcao para validar todas os registros da GetDados - uTudoOK
  									 NIL,;					 				// cIniCPOS
									 NIL,;									// aAlter
									 0,;									// nfreeze
									 99999,;								// nMax
									 NIL,;									// cFieldOK
									 NIL,;									// usuperdel
									 NIL,;									// udelOK
									 @oDlg,;								// objeto de dialogo - oWnd
									 @aHeader,;								// Vetor com Colunas - AparHeader
									 @aDados;								// Vetor com Header - AparCols
									)

bSet15	:= {|| nOpca:=1, If(oGet:TudoOk(), oDlg:End(), nOpca:=0 )}
bSet24	:= {|| nOpca:=0, oDlg:End()}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 )
                        
If nOpca == 1
	Tc002Grava()
EndIf

RestArea( aArea )
	
Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tc002LinOk³ Autor ³ Equipe R.H.           ³ Data ³ 20.02.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Critica linha digitada                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tc002LinOk()

Local aDadosBkp 	:= ( oGet:aCols )
Local cMeses		:= "01_02_03_04_05_06_07_08_09_10_11_12"
Local lRet		 	:= .T.
Local cDataAux		:= ""
Local nDiaAux		:= 0
Local cMesAux		:= ""      
Local cAnoBase		:= ""
Local nX			:= 0
Local nCont         := 0     
Local cCodFil       := ""
Local cCodEmp		:= ""

If aCols[n,len(aHeader)+1]  = .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se esta cadastrando a verba em duplicidade          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aeval(aCols,{ |X| If(X[1] = aCols[N,1] .and. X[2] = aCols[N,2] .and. X[3] = aCols[N,3] .and. X[len(aHeader)+1] = .F. , nCont ++ , nCont ) } )
	If nCont > 1
		MsgInfo( "Chave do Registro ja Cadastrada" + CRLF ) 
		lret := .F.
	Endif 

EndIf

//Filial <> "" , empresa obrigatoria
cCodEmp := aDadosBkp[n,1]	
cCodFil := aDadosBkp[n,2]

If Empty( cCodEmp ) .and. ! Empty( cCodFil )
	MsgInfo( "Codigo da Empresa obrigatorio, qdo filial preenchida!" + CRLF )
	lRet := .F.
EndIf

// Validacao da Empresa
If ! Empty( cCodEmp ) .and. ! ExistCpo( "SM0", cCodEmp, , , .F. )
	MsgInfo( "Codigo da Empresa não é válido!" + CRLF )
	lRet := .F.
EndIf

// Validacao da Filial qdo Empresa estiver preenchida
If ! Empty( cCodEmp ) .and. ! Empty( cCodFil ) .and. ! ExistCpo( "SM0", cCodEmp + cCodFil , , , .F. )
	MsgInfo( "Codigo da Filial não é válido!" + CRLF )
	lRet := .F.
EndIf

//Ano Base
cAnoBase := aDadosBkp[n,3]
If Empty(cAnoBase) .or. Val(cAnoBase) = 0
	MsgInfo( "Ano Base obrigatorio" + CRLF )
	lRet := .F.
EndIf

//Data Liberacao
If lRet     
	cDataAux := aDadosBkp[n,4]
	If Empty(cDataAux)
		MsgInfo( "Dia/Mes de Liberacao obrigatorio" + CRLF )
		lRet := .F.               
	Else
		nDiaAux := Val(Subst( cDataAux , 1, 2 ))
		cMesAux := Subst( cDataAux , 3, 2 )
		If !(cMesAux  $ cMeses ) .or. ( nDiaAux <= 0 ) .or. ( nDiaAux > 31 ) .or.;
		    ( ( cMesAux $ "04*06*09*11" ) .and. ( nDiaAux > 30 ) ) .or.;
		    ( ( cMesAux == "02" ) .and. ( val(cAnoBase) % 4 > 0 ) .and. ( nDiaAux > 28 ) ) .or.;
		    ( ( cMesAux == "02" ) .and. ( val(cAnoBase) % 4 == 0 ) .and. ( nDiaAux > 29 ) )
			MsgInfo( "Dia/Mes de Liberacao invalido" + CRLF )
	  		lRet := .F.			
		EndIf
	EndIf
EndIf

//Data Informe
If lRet 
	cDataAux := aDadosBkp[n,5]
	If Empty(cDataAux)
		MsgInfo( "Dia/Mes de Informe de Rendimento obrigatorio" + CRLF )
		lRet := .F.               
	Else
		nDiaAux := Val(Subst( cDataAux , 1, 2 ))
		cMesAux := Subst( cDataAux , 3, 2  )
		If !(cMesAux  $ cMeses ) .or. ( nDiaAux <= 0 ) .or. ( nDiaAux > 31 ) .or.;
		    ( ( cMesAux $ "04*06*09*11" ) .and. ( nDiaAux > 30 ) ) .or.;
		    ( ( cMesAux == "02" ) .and. ( val(cAnoBase) % 4 > 0 ) .and. ( nDiaAux > 28 ) ) .or.;
		    ( ( cMesAux == "02" ) .and. ( val(cAnoBase) % 4 == 0 ) .and. ( nDiaAux > 29 ) )
			MsgInfo( "Dia/Mes do Informe de Rendimento invalido" + CRLF )
	  		lRet := .F.			
		EndIf
	EndIf
EndIf

//Responsavel
If lRet .and. Empty(aDadosBkp[n,6])
	MsgInfo( "Responsavel obrigatorio" + CRLF )
	lRet := .F.
EndIf                 

If lRet 
	For nX := 1 to Len(aDadosBkp)
		If nX <> n .and. aDadosBkp[nX, 1] = cAnoBase
			MsgInfo( "Ano Base ja existe" + CRLF )
			lRet := .F.   
			exit                       
		EndIf
	Next nX
EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tc002TudOk³ Autor ³ Equipe R.H.           ³ Data ³ 20.02/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tc002TudOk()
Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ValEmpTc02³ Autor ³ Equipe R.H.           ³ Data ³ 09/09/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao da Empresa.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ValEmpTc02()
Local lRet		:= .T.
Local cCodEmp	:= GetMemVar( "T002EMP" )

If ! Empty( cCodEmp ) .and. ! ExistCpo( "SM0", cCodEmp, , , .F. )
	MsgInfo( "Codigo da Empresa não é válido!" + CRLF )
	lRet := .F.
EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ValFilTc02³ Autor ³ Equipe R.H.           ³ Data ³ 09/09/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao da Filial.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ValFilTc02()
Local lRet		:= .T.
Local aDadosBkp := ( oGet:aCols )
Local cCodEmp	:=  aDadosBkp[n,1]
Local cCodFil	:= GetMemVar( "T002FIL" )

If ! Empty( cCodEmp ) .and. ! Empty( cCodFil ) .and. ! ExistCpo( "SM0", cCodEmp + cCodFil , , , .F. )
	MsgInfo( "Codigo da Filial não é válido!" + CRLF )
	lRet := .F.
EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tc002Grava³ Autor ³ Equipe R.H.           ³ Data ³ 20.02/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tc002Grava()

Local aDadosBkp := ( oGet:aCols )
Local cFile		 := "GRHINF2.FCH"
Local nHandle	 := 0
Local nX			 := 0
Local cBuffer	 := ""

	//Deletar arquivo
	If File(cFile)
		fClose(nHandle)
		fErase(cFile)
	EndIf
	
	//Recriar o arquivo com as informacoes da GetDados	
	nHandle := FCreate(cFile)
	If nHandle > 0
		For nX := 1 to Len(aDadosBkp)
			If aDadosBkp[nX, 7] == .F.
				cBuffer := aDadosBkp[nX,3] + " " + trim(aDadosBkp[nX,4]) + " " + trim(aDadosBkp[nX,5]) + " " + aDadosBkp[nX,6] + " " + aDadosBkp[nX,1] + " " + aDadosBkp[nX,2] + Chr(13)+Chr(10)
				Fwrite(nHandle,cBuffer,Len(cBuffer))
			EndIf
		Next nX
	EndIf
	fClose(nHandle)
	
Return( NIL )
