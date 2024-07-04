#INCLUDE "Protheus.CH"
#INCLUDE "GPEA873CHI.CH"
#INCLUDE	"RWMake.ch"

Static lIncluir:= .F.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³GPEA873CHI³ Autor ³ Jonathan Gonzalez         ³Fecha ³19/02/2015  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrip.  ³ Manutencao do Arquivo da Declaracao Anual Chile.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis  ³ GPEA873CHI()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  SIGAGPE                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ACTUALIZACIONES SUFRIDAS DESDE LA CREACION INICIAL                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Fecha    ³ BOPS/FNC ³  Motivo de alteracion                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alex Hdez.  ³12/01/2016³PCREQ-7944³Se paso a la v12 a partir del fuente de   ³±±
±±³            ³          ³          ³v11 con la fecha 18/12/15                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function GPEA873CHI()
	Local aArea        := GetArea()
	LOCAL cFiltraRCV					//Variavel para filtro
	LOCAL aIndexRCV    := {}			//Variavel Para Filtro
	Private bFiltraBrw := {|| Nil}	//Variavel para Filtro
	// Define Variaveis
	Private nVez       := 1
	Private cArqCompl  :=	"GPCMPL"+cEmpAnt
	Private aColsComp  := {}
	Private aColsRec

		cCadastro := OeMtoAnsi(STR0001) //"Mantenimiento de la Declaracion Anual"

		/* Funcao verifica se existe alguma restrição de acesso para o usuário que impeça a execução da rotina. */
		If !(fValidFun({"RCV","RCW","RCC"}))
			Return( nil )
		Endif

		Private aRotina :=	{{STR0009 , "AxPesqui"    , 0 , 1 } ,; //"Pesquisar"
								{ STR0010 , "gp873CHIMan" , 0 , 2 } ,; //"Visualizar"
								{ STR0011 , "gp873CHIAux" , 0 , 4 } ,; //"Incluir"
								{ STR0012 , "gp873CHIMan" , 0 , 6 } ,; //"Alterar"
								{ STR0013 , "gp873CHIMan" , 0 , 5 } }  //"Excluir"

		// Endereca a funcao de BROWSE
		dbSelectArea( "RCV" )
		RCV->(dbSetOrder( 1 ))
		//RCV->(dbGoTop())

		/* Carregando Filtro de BROWSE */
		cFiltraRCV	:= ChkRh( "GPEA873CHI" , "RCV" , "1" )
		bFiltraBrw	:= { || FilBrowse( "RCV" , @aIndexRCV , @cFiltraRCV ) }
		Eval( bFiltraBrw )

		RCV->(dbGoTop())

		SetBrwCHGAll( .T. )
		mBrowse(06,01,22,75,"RCV",,,,,,)

		// Deleta o filtro utilizando a funcao FilBrowse
		EndFilBrw("RCV",aIndexRCV)

		RCV->(dbCloseArea())
	RestArea( aArea )
Return( Nil )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³gp873CHIMan ³ Autor ³ Jonathan Gonzalez   ³ Data ³19/02/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Visualizacao,Inclusao,Altereacao do Arquivo    ³±±
±±³          ³ da Declaracao anual                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ gp873CHIMan(ExpO1,ExpO2,ExpO3)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nOpca  := Tipo operacion                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA873CHI                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1  : Area de trabajo.                                  ³±±
±±³          ³ ExpO1  : Renglon de trabajo.                               ³±±
±±³          ³ ExpO1  : Tipo de operacion.                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function gp873CHIMan(cAlias,nReg,nOpc)
	Local aArea        := GetArea()
	Local aAdvSize     := {}
	Local aInfoAdvSize := {}
	Local aObjSize     := {}
	Local aObjCoords   := {}
	Local aButton      := {}
	Local bSet15       := { || NIL }
	Local bSet24       := { || NIL }
	//Local nOpca        := 0.00
	Local oDlg
	Local oGet
	Local nDel         := 0.00
	Local cX3Campo
	Local cMCampo
	Local aColsAnt     := {}
	Local nTamRFCF:=TamSx3('RCV_RFCFON')[1]
	
	Local nx           := 0
	Private nOpca      := 0.00
	Private nUsad      := 0
	Private aCols      := {}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Matriz de Cabecalho para Enchoice³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aM873Obrig := {}
	Private aM873Nao   := {"RCV_FILIAL"}
	Private aM873Dif   := {"RCV_MAT" }
	Private aLetra     := {}
	Private aTelaAnt:={}
		If lIncluir
			nOpcx := 3
			lIncluir :=.F.
		Endif

		cAlias := "RCV"

		// Monta a entrada de dados do Arquivo
		If nOpc == 3
		   
			dbSelectArea("SX3")
			SX3->(dbSeek( "RCV"))
			While SX3->(!Eof()) .and. (SX3->X3_ARQUIVO == "RCV")
				cX3Campo := "RCV->"+(SX3->X3_CAMPO)
				cMCampo  := "M->"+(SX3->X3_CAMPO)
				If Ascan(aM873Nao,ALLTRIM(Upper(SX3->X3_CAMPO))) == 0
				    IF SX3->X3_CAMPO == "RCV_FILFON"  
					    &(cMCampo) := SM0->M0_CODFIL
				    ElseIf SX3->X3_CAMPO == "RCV_RFCFON"
						&(cMCampo) := substr(SM0->M0_CGC,1,nTamRFCF)
					Elseif SX3->X3_CAMPO == "RCV_NOMFON"
						&(cMCampo) := SM0->M0_NOMECOM
					Else
						If ValType(&(cX3Campo)) == "C"
							&(cMCampo) := SPACE(LEN(&(cX3Campo)))
						ElseIf ValType(&(cX3Campo)) == "N"
							&(cMCampo) := 0
						ElseIf ValType(&(cX3Campo)) == "D"
							&(cMCampo) := CtoD("  /  /  ")
						ElseIf ValType(&(cX3Campo)) == "L"
							&(cMCampo) := .F.
						Endif
					Endif
					AADD(aM873Obrig,SX3->X3_CAMPO)
				Endif
				SX3->( dbSkip())
			Enddo
		ElseIf nOpc == 4
			dbSelectArea("SX3")
			SX3->( dbSeek( "RCV"))
			While SX3->(!Eof()) .and. (SX3->X3_ARQUIVO == "RCV")
				If Ascan(aM873Nao,ALLTRIM(Upper(SX3->X3_CAMPO))) == 0
					cX3Campo := "RCV->"+(SX3->X3_CAMPO)
					cMCampo  := "M->"+(SX3->X3_CAMPO)
					&cMCampo := &(cX3Campo)
					If &cMCampo == Nil
						If ValType(&(cX3Campo)) == "C"
							&(cMCampo) := SPACE(LEN(RCV->&(SX3->X3_CAMPO)))
						ElseIf ValType(&(cX3Campo)) == "N"
							&(cMCampo) := 0
						ElseIf ValType(&(cX3Campo)) == "D"
							&(cMCampo) := CtoD("  /  /  ")
						ElseIf ValType(&(cX3Campo)) == "L"
							&(cMCampo) := .F.
						Endif
					Endif
					If Ascan(aM873Dif,ALLTRIM(Upper(SX3->X3_CAMPO))) = 0
						AADD(aM873Obrig,x3_campo)
					Endif
				Endif
				SX3->( dbSkip())
			Enddo
		EndIf

		Private aTELA[0][0],aGETS[0],aHeader[0],Continua:=.F.

		nUsado := 0

		Gera873(cAlias,@aHeader,@aCols,@nUsado,nOpc)

		aAlter := Array(Len(aHeader))
		For nx:= 2 to Len(aHeader)
			aAlter[nx] := aHeader[nx,2]
		Next

		aColsAnt := Aclone(aCols)
		aTelaAnt :=  Aclone(aTELA)
		/* Monta as Dimensoes dos Objetos */
		aAdvSize		:= MsAdvSize()
		aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
		aAdd( aObjCoords , { 000 , 080 , .T. , .F. } )
		aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
		aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

		DEFINE MSDIALOG oDlg TITLE cCadastro From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL
			nOpca := EnChoice( cAlias , nReg , nOpc , NIL , NIL , NIL , NIL , aObjSize[1] ,If(nOpc==2.or. nopc==6,NIL,aM873Obrig),3 )
		  	oGet	:= MsGetDados():New(aObjSize[2,1],aObjSize[2,2],aObjSize[2,3],aObjSize[2,4],nOpc,"gp873LinOk","gp873LinOk"," ",,,,,12)
			bSet15	:= {||nOpca:=1,If(If(nOpc==3,Obrigatorio(aGets,aTela),(if (nopc==3, gp873Valid(.t.),.T.))).and.oGet:TudoOk() ,oDlg:End(),nOpca:=0)}
			bSet24	:= {||oDlg:End()}

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 , NIL  )

		If nOpcA == 1 .and. nOpc # 2
			Begin Transaction
				If nOpc == 5 //Exclusao
					nDel := 0
					FDel873(@nDel)
			    Else
					gp873Grava("RCW",aColsAnt,nOpc)
					EvalTrigger()
				EndIf
			End Transaction
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restaura a integridade da janela                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aColsComp 	:= {}
		nOpca 		:= 0
		dbSelectArea(cAlias)
		RestArea( aArea )
Return nOpca

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³gp873Grava  ³ Autor ³ Jonathan Gonzalez   ³ Data ³19/02/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava no arquivo de Acumulados Anuais                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ gp873Grava(ExpO1,ExpO2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gp873CHIMan                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1  : Area de trabajo.                                  ³±±
±±³          ³ ExpO1  : Columnas.                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function gp873Grava(cAlias,aColsAnt,nopc)
	Local nX 		:= 0
	Local nY 		:= 0
	Local aAreaRCV 	:= RCV->( GetArea() )
	Local lMod:= .f.
	Local lModEnc := if(aTelaAnt<> aTela,.t.,.f.)
	Local nFolio:=0
	Local cFilRCV:=xFilial("RCV")
	
	Local cAliasRCV:=criatrab( nil, .f. )
	Local cQry:=''
	
		if nOpc==3  //si Incluir,  extrae el ultimo folio
			cQry:="SELECT MAX(RCV_FOLIO) FOLMAX FROM "+RetSqlName("RCV") +" RCV WHERE RCV_FILIAL='"+CFILRCV+"' AND RCV_RFCFON='"+M->RCV_RFCFON+"' AND RCV_ANO='"+M->RCV_ANO +"' AND   RCV.D_E_L_E_T_ = ' ' "
			cQry := ChangeQuery(cQry)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasRCV,.T.,.T.)
			IF !(cAliasRCV)->(EOF())
			   nFolio:=(cAliasRCV)->FOLMAX+1
			ELSE 
			   nFolio:=1   
			ENDIF
			(cAliasRCV)->(dbclosearea())	    
		endif
		Begin Transaction
			
			dbSelectArea("RCW")
			dbSetOrder(1) // RCW_FILIAL+RCW_MAT+RCW_RFC+RCW_ANO+RCW_MESINI+RCW_MESFIN+RCW_MES+RCW_TIPORE
			For nX := 1 TO 12
		        For nY := 2 to nUsado
		        	cTipDirf := aLetra[nY-1]
		  			If aCols[nX,nY] # aColsAnt[nX,nY]   //.And. aCols[nX,nY] >= 0.00
		  			    lMod:= .t.
						If dbSeek(RCV->RCV_FILIAL+RCV->RCV_MAT+RCV->RCV_RFC+RCV->RCV_ANO+RCV->RCV_MESINI+RCV->RCV_MESFIN+STRZERO(nX,2)+ALLTRIM(cTipDirf))
							RecLock("RCW",.F.)
						Else
							RecLock("RCW",.T.)
							RCW->RCW_FILIAL  := RCV->RCV_FILIAL
							RCW->RCW_MAT     := RCV->RCV_MAT
							RCW->RCW_RFC     := RCV->RCV_RFC
							RCW->RCW_ANO     := RCV->RCV_ANO
							RCW->RCW_MESINI  := RCV->RCV_MESINI
							RCW->RCW_MESFIN  := RCV->RCV_MESFIN
							RCW->RCW_MES     := STRZERO(nX,2)
							RCW->RCW_TIPORE  := cTipDirf
						Endif
						RCW->RCW_VALOR   := aCols[nX,nY]
						RCW->RCW_STATUS  := "U" // le asigna estatus U
						MsUnLock()
					else //no hubo cambios en el getdados
					   	if lModEnc //Pero si modifico el encabezado, entonces el encabezado se maraca como de Usuario
							   	If dbSeek(RCV->RCV_FILIAL+RCV->RCV_MAT+RCV->RCV_RFC+RCV->RCV_ANO+RCV->RCV_MESINI+RCV->RCV_MESFIN+STRZERO(nX,2)+ALLTRIM(cTipDirf))
									RecLock("RCW",.F.)
									RCW->RCW_STATUS  := "U" // le asigna estatus U
									MsUnLock()
								endif	
					   	endif
					Endif
				Next nY
			Next nX
			
			if lMod .or. nopc == 3 .or. lModEnc//Si modifico el getdado o es la opcion Incluir o si modifico el encabezado
			
				dbSelectArea("RCV")
				dbSetOrder(1) // RCV_FILIAL+RCV_MAT+RCV_RFC+RCV_ANO+RCV_MESINI+RCV_MESFIN
				If dbSeek(xFilial("RCV")+M->RCV_MAT+M->RCV_RFC+M->RCV_ANO+M->RCV_MESINI+M->RCV_MESFIN)
					RecLock("RCV",.F.)
				Else
					RecLock("RCV",.T.)
					RCV->RCV_FILIAL   := xFilial("RCV")
					RCV->RCV_MAT      := M->RCV_MAT
					RCV->RCV_RFC      := M->RCV_RFC
					RCV->RCV_ANO      := M->RCV_ANO
					RCV->RCV_MESINI   := M->RCV_MESINI
					RCV->RCV_MESFIN   := M->RCV_MESFIN
					RCV->RCV_FOLIO    := NfOLIO
				Endif
				RCV->RCV_PRINOM   := M->RCV_PRINOM
				RCV->RCV_SEGNOM   := M->RCV_SEGNOM
				RCV->RCV_PRISOB   := M->RCV_PRISOB
				RCV->RCV_SEGSOB   := M->RCV_SEGSOB
				RCV->RCV_RFCFON   := M->RCV_RFCFON
				RCV->RCV_NOMFON   := M->RCV_NOMFON
				RCV->RCV_RFCREP   := M->RCV_RFCREP
				RCV->RCV_EMAIL    := M->RCV_EMAIL
				RCV->RCV_NOMREP   := M->RCV_NOMREP
				RCV->RCV_STATUS   := "U" // le asigna estatus U
			    RCV->(MsUnlock())
			endif
		End Transaction
		RestArea( aAreaRCV )
Return .T.

 /*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³gp873LinOk  ³ Autor ³ Jonathan Gonzalez   ³ Data ³19/02/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica linha digitada                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ gp873LinOk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gp873CHIMan                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function gp873LinOk(o)
	//Local nx
	Local lRet 	:= .T.
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³gp873TudOk  ³ Autor ³ Jonathan Gonzalez   ³ Data ³19/02/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Todo OK                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ gp873Grava()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gp873CHIMan                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function gp873TudOk(o)
	Local lRetorna  := .T.
		Continua     := .F.
Return lRetorna

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FDel873    ³ Autor ³ Jonathan Gonzalez   ³ Data ³19/02/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Elimina no arquivo de Acumulados Anuais                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FDel873(ExpO1)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gp873CHIMan                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1  : Numero de linea.                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FDel873(nDel)
	Local aArea := GetArea()
		Begin Transaction
			dbSelectArea("RCV")
			RecLock("RCV",.F.)
			dbDelete()

			dbSelectArea("RCW")
			dbSeek( RCV->RCV_FILIAL+RCV->RCV_MAT+RCV->RCV_RFC+RCV->RCV_ANO+RCV->RCV_MESINI+RCV->RCV_MESFIN )
			While ! Eof() .And. RCV->RCV_FILIAL+RCV->RCV_MAT+RCV->RCV_RFC+RCV->RCV_ANO+RCV->RCV_MESINI+RCV->RCV_MESFIN == RCW->RCW_FILIAL+RCW->RCW_MAT+RCW->RCW_RFC+RCW->RCW_ANO+RCW->RCW_MESINI+RCW->RCW_MESFIN
				RecLock("RCW",.F.)
				dbDelete()
				nDel ++
		      dbSkip()
			EndDo

			dbSelectArea("RCV")
			RecLock("RCV",.F.)
			dbDelete()
			aColsComp := {}
		End Transaction
	RestArea(aArea)
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ Gera873    ³ Autor ³ Jonathan Gonzalez   ³ Data ³19/02/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera o aHeader e aCols                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Gera873(ExpO1,ExpO2,ExpO3,ExpO4,ExpO5)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ gp873CHIMan                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1  : Area de trabajo.                                  ³±±
±±³          ³ ExpO2  : Encabezado para el grid.                          ³±±
±±³          ³ ExpO3  : Columnas.                                         ³±±
±±³          ³ ExpO4  : Usado.                                            ³±±
±±³          ³ ExpO5  : Tipo de operacion.                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Gera873(cAlias,aHeader,aCols,nUsado,nOpc)
	Local aArea := GetArea()
	Local aMes   := {STR0014,STR0015,STR0016,STR0017,STR0018,STR0019,; //"Janeiro    $"###"Fevereiro  $"###"Marco      $"###"Abril      $"###"Maio       $"###"Junho      $"
	                 STR0020,STR0021,STR0022,STR0023,STR0024,STR0025}  //"Julho      $"###"Agosto     $"###"Setembro   $"###"Outubro    $"###"Novembro   $"###"Dezembro   $"
	Local aTpRent:= {'A','B','C','D','E','F','G','H'}
	//##"Sueldo Bruto"##"Cot. Previs. a Cargo Trab."##"Imp Único X Rentas del Año"##"Imp Único X Rentas Acces."##"Mayor Retención Solic."
	//##"Renta Total Exenta"##"Renta Total No Gravada"##"Rebaja por Zona Extrema"
	Local aDscRen:= { STR0027, STR0028, STR0029, STR0035, STR0030, STR0031, STR0032 , STR0033 }
	Local nA
	Local aDirfv := {}
	Local nX
	Local nY
	Local nL     := 1
	Local aChave := {}
	Local cTipo  := ""

		//Guarda as posicoes inicio e tamanho, dentro das vaiaves com os respectivos conteudos.
		AADD(aHeader,{STR0026 ,"M710MES"  ,"@!",13, 0,"! EMPTY()","û", "C" ," "}) //"Mes "

		for nA := 1 to Len(aTpRent)

			If nL >= 67
			   cTipo := "."
			Endif

			cChave := aTpRent[nA]
			cDescr	:= aTpRent[nA] + " - " + aDscRen[nA]+cTipo
			cPict	:= "@E 999,999,999,999.99"
			nTam   := 15
			nDec   := 2
			cAlter := "M710"+ StrZero(nL,3)

			AAdd(aChave, {cChave} )
			AAdd(aHeader,{ cDescr , cAlter , cPict , nTam , nDec , "" , "û" , "N" ," " }) //               '

			nL += 1
		next

		nUsado := Len(aHeader)
		aLetra := Array(Len(aChave))
		aDirfV := Array(12,nUsado)

		For nx := 1 to Len(aChave)
			aLetra[nx] := aChave[nx,1]
		Next nx

		For nX := 1 to 12
		    For nY := 1 TO nUsado
				If nY == 1
					aDirfv[nX,nY] := aMes[nX]
				Else
					aDirfv[nX,nY] := 0.00
				Endif
			Next nY
		Next nX

		If nOpc # 3
			dbSelectArea("RCW")
			dbSeek(RCV->RCV_FILIAL+RCV->RCV_MAT+RCV->RCV_RFC+RCV->RCV_ANO+RCV->RCV_MESINI+RCV->RCV_MESFIN)
			While !Eof() .And. RCV->RCV_FILIAL+RCV->RCV_MAT+RCV->RCV_RFC+RCV->RCV_ANO+RCV->RCV_MESINI+RCV->RCV_MESFIN == RCW->RCW_FILIAL+RCW->RCW_MAT+RCW->RCW_RFC+RCW->RCW_ANO+RCW->RCW_MESINI+RCW->RCW_MESFIN
				nMes   := Val(RCW->RCW_MES)
				nElem  := Ascan(aLetra, ALLTRIM(RCW->RCW_TIPORE))
				If nElem >0
					adirfv[nMes,nElem+1] := RCW->RCW_VALOR
				EndIf
				dbSkip(1)
			Enddo
		Endif
		aCols := Aclone(aDirfv)
	RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GP873LOK    ³ Autor ³ Jonathan Gonzalez   ³ Data ³19/02/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a linha da msGetdados                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GP873LOK()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION GP873LOK()
	Local aArea := GetArea()
	Local lRet := .T.

		if  (aCols[n,5] == .F.) .and. (empty(aCols[n,1]) .or. aCols[n,3]==0)
			lRet := .F.
		EndIf
	RestArea( aArea )
RETURN(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³gp873CHIAux ³ Autor ³ Jonathan Gonzalez   ³ Data ³19/02/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizada para identificar quando é selecionado            ³±±
±±³          ³ a opçao de incluir                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ gp873CHIAux(ExpO1,ExpO2,ExpO3)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA873CHI                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1  : Area de trabajo.                                  ³±±
±±³          ³ ExpO1  : Renglon de trabajo.                               ³±±
±±³          ³ ExpO1  : Tipo de operacion.                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function gp873CHIAux(cAlias,nReg,nOpcX)
	lIncluir := .T.
Return(gp873CHIMan(cAlias,nReg,nOpcX))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³gp873Valid  ³ Autor ³ Jonathan Gonzalez   ³ Data ³19/02/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizada para identificar que el registro no sea duplicado³±±
±±³          ³ a opçao de incluir                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ gp873Valid()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA873CHI                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function gp873Valid(lValTodo)
Local aArea := getArea()
Local lRet  := .T.
Local cVarAct:=Readvar()
Local cLlave:=''
Local lNoValida:=.f.  

Default lValTodo:= .f.
   
 do Case
   		Case alltrim(cVarAct)=='M->RCV_MAT'
   		     cLlave:=&cVarAct+M->RCV_RFC+M->RCV_ANO+M->RCV_MESINI+M->RCV_MESFIN
   		     if empty(M->RCV_RFC) .or. empty(M->RCV_ANO).or. empty(M->RCV_MESINI) .or. empty(M->RCV_MESFIN)
   		         lNoValida:=.t.
   		     endif    
   		         
		Case alltrim(cVarAct)=='M->RCV_RFC'
   		     cLlave:=M->RCV_MAT+&cVarAct+M->RCV_ANO+M->RCV_MESINI+M->RCV_MESFIN   		     
   		       if empty(M->RCV_MAT) .or. empty(M->RCV_MAT) .or. empty(M->RCV_MESINI) .or. empty(M->RCV_MESFIN)
   		         lNoValida:=.t.
   		     endif    
		Case alltrim(cVarAct)=='M->RCV_ANO'
   		     cLlave:=M->RCV_MAT+M->RCV_RFC+&cVarAct+M->RCV_MESINI+M->RCV_MESFIN   		     
   		      if empty(M->RCV_MAT) .or. empty(M->RCV_RFC) .or. empty(M->RCV_MESINI) .or. empty(M->RCV_MESFIN)
   		         lNoValida:=.t.
   		     endif
   		 Case alltrim(cVarAct)=='M->RCV_MESINI'
   		     cLlave:=M->RCV_MAT+M->RCV_RFC+M->RCV_ANO+&cVarAct+M->RCV_MESFIN   		     
   		      if empty(M->RCV_MAT) .or. empty(M->RCV_RFC).or. empty(M->RCV_ANO) .or. empty(M->RCV_MESFIN)
   		         lNoValida:=.t.
   		     endif                            
   		 Case alltrim(cVarAct)=='M->RCV_MESFIN'
   		     cLlave:=M->RCV_MAT+M->RCV_RFC+M->RCV_ANO+M->RCV_MESINI+&cVarAct  		     
   		      if empty(M->RCV_MAT) .or. empty(M->RCV_RFC) .or. empty(M->RCV_ANO) .or. empty(M->RCV_MESINI)
   		         lNoValida:=.t.
   		     endif                 
         Otherwise
		         cLlave:=M->RCV_MAT+M->RCV_RFC+M->RCV_ANO +M->RCV_MESINI+M->RCV_MESFIN     
 EndCase
if !lNoValida
	dbSelectArea("RCV")
	dbSetOrder(1)
	
	If RCV->(dbSeek(xFilial("RCV")+cllave))
		Help( /*cHelp*/ , /*nLinha,*/ , "JAGRAVADO" , /*uPar4*/ , STR0034 , 1 , 0 ) //Ya existe registro con esta información
		lRet  := .F.
	Endif
endif
RestArea( aArea )
Return lRet


