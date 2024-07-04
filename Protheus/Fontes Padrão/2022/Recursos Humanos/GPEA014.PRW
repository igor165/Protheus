#INCLUDE "PROTHEUS.CH" 
#INCLUDE 'GPEA014.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GPEA014  ³ Autor ³ Leandro Drumond                   ³ Data ³ 12/09/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro de Layout				                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEA014()			                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ FNC            ³  Motivo da Alteracao                       ³±±
±±³Henrique V. ³24/04/2015³TS6859          ³Criada validação para o campo Tipo somente  ³±±
±±³            ³          ³                ³permitir conteúdo "C" ou "N" como consta no ³±±
±±³            ³          ³                ³Help                                        ³±±
±±³Henrique V. ³27/04/2015³TS6859          ³Melhorada correção anteriror.               ³±±
±±³Paulo O I   ³13/04/2017³DRHPAG-239      ³Melhoria -  remoção de dependencias do ctree³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPEA014()
Local aButtons		:= {}
Local aPosGetD		:= {}
Local aTMPHeader	:= {}
Local aTMPCols		:= {}
Local bLoad			:= {||}
Local cFile			:= ""
Local cMsg			:= ""
Local cLinha		:= ""
Local nOpcA			:= 0
Local nX			:= 0
Local nArq			:= 0
Local oSize
Local oDlg
Local oFont
Local oFile
Local oGet

Private oTmpTable := Nil

Private cAliasTmp 	:= GetNextAlias()

fCriaTmp(cAliasTmp, @aTMPHeader)

//MONTA AS DIMENSOES DOS OBJETOS
oSize := FwDefSize():New()             
oSize:AddObject( "GETDADOS",oSize:aWindSize[4],oSize:aWindSize[3] , .F., .F. )// Não dimensionavel

oSize:lProp 	:= .F. // Proporcional             
oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
oSize:Process() 	   // Dispara os calculos

aPosGetD := { 3, 3, oSize:GetDimension("GETDADOS","YSIZE") - 16, oSize:GetDimension("GETDADOS","XSIZE") - 4 }   

//PARAMETROS PARA GENERACION DE VALORES FUTUROS
DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) From oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oDlg PIXEL //"Definição de Layout de Arquivo de Beneficios"

	oGet := MsNewGetDados():New(					aPosGetD[1] + 30		,;
										   			aPosGetD[2] + 5			,;
												    aPosGetD[3] * 0.5		,;
													aPosGetD[4] / 2			,;
													( GD_INSERT + GD_UPDATE + GD_DELETE )						,;
													"gp014LinOk"			,;
													"gp014TudOk"			,;
													NIL						,;
													NIL						,;
													0						,;
													999						,; 
													NIL						,;
													NIL						,;
													NIL						,;
													oDlg					,;
													@aTMPHeader				,;
													GdRmkaCols(aTMPHeader)	;
												  )


	bSet15 := {|| nOpcA := 1, If(oGet:TudoOk(), oDlg:End(), nOpcA := 0), if( nOpcA == 1, aTMPCols := oGet:aCols, NIL) }
	bSet24 := {|| nOpcA := 2, oDlg:End()}
	
	bLoad	:= { || ( (cFile := cGetFile( " *.INI |*.INI " ,OemToAnsi(STR0002),0,,.T.,GETF_LOCALHARD+GETF_LOCALFLOPPY,,)) , (If(!Empty(cFile),fLoadFile(cFile,oGet),.T.))) } //"Selecione o Arquivo" 

	aAdd(;
				aButtons	,;
								{;
									"IMPORTAR"	,;
		   							bLoad				,;
		       	   					STR0003	,;	//"Importar Layout"
		       	   					STR0003	 ;	//"Importar Layout"
		           				};
		     )

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , bSet15 , bSet24, Nil, aButtons )

If nOpcA == 1
	If Len(aTMPCols) > 0
		cFile := ""
		cFile := cGetFile( "" ,OemToAnsi(STR0004),0,,.F.,GETF_LOCALHARD+GETF_LOCALFLOPPY,,) //"Selecione o Diretório para geração do arquivo"
		If Empty(cFile)
			Return Nil
		EndIf
		If File( cFile )
			If MsgYesNo(STR0005 + cFile + STR0006) //"Arquivo " " já existe. Sobrepor?"
				FClose(cFile)
				fErase( cFile )
			Else
				Return Nil
			EndIf
		EndIf
		
		nArq := MSFCREATE(cFile, 0)
		If Ferror() # 0 .and. nArq = -1 
			cMsg := STR0007 + STR(Ferror(),3) //-- "Erro de Gravacao do Arquivo - Codigo DOS: "
			MsgInfo( cMsg, STR0008 )
			Return Nil
		EndIf	
	EndIf
	
	For nX := 1 to Len(aTMPCols)
		If !aTMPCols[nX,6]
			If Empty(aTMPCols[nX,2])
				cLinha := AllTrim(aTMPCols[nX,1]) + CRLF
			Else
				cLinha := aTMPCols[nX,1] + aTMPCols[nX,2] + StrZero(aTMPCols[nX,3],4) + aTMPCols[nX,4] + AllTrim(aTMPCols[nX,5]) + CRLF
			EndIf 
			Fwrite( nArq, cLinha )
		EndIf
	Next nX
	
	FClose(nArq)
	
	MsgInfo(STR0005 + cFile + STR0009) //"Arquivo "" gerado com sucesso!"
	
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fCriaTmp       ³ Autor ³ Leandro Drumond    ³ Data ³ 12/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria tabela temporaria                               			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fCriaTmp()				                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³GPEa014					                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fCriaTmp(cAlias,aHeaderTMP)
Local aColumns	 := {}
Local cArqTmp	 := ''
	
If Select(cAlias) > 0
	If oTmpTable <> Nil   
		oTmpTable:Delete()  
		oTmpTable := Nil 
	EndIf 	
EndIf 

aAdd( aColumns, { "TAB_CAMPO"	,"C",28,00 })
aAdd( aColumns, { "TAB_TIPO"	,"C",01,00 })
aAdd( aColumns, { "TAB_TAM"		,"N",04,00 })
aAdd( aColumns, { "TAB_FIXO"	,"C",01,00 })
aAdd( aColumns, { "TAB_CODIGO"	,"C",50,00 })

aAdd( aHeaderTMP, {STR0010,			"TAB_CAMPO",	"@!",	28,	0,	"",	Chr(251),	"C",	"", "V", "", "", "", "A", "", "", .F. } ) //"Registro/Campo"
aAdd( aHeaderTMP, {STR0011,			"TAB_TIPO",		"@!", 	01,	0,	"",	Chr(251),	"C",	"", "V", "", "", "", "A", "", "", .F. } ) //"Tipo"
aAdd( aHeaderTMP, {STR0012, 		"TAB_TAM",		"9999",	04,	0,	"",	Chr(251),	"N",	"", "V", "", "", "", "A", "", "", .F. } ) //"Tamanho"
aAdd( aHeaderTMP, {STR0013,			"TAB_FIXO",		"@!",	01,	0,	"",	Chr(251),	"C",	"", "V", "", "", "", "A", "", "", .F. } ) //"Fixo"
aAdd( aHeaderTMP, {STR0014, 		"TAB_CODIGO",	"@!",	50,	0,	"",	Chr(251),	"C",	"", "V", "", "", "", "A", "", "", .F. } ) //"Fórmula"


oTmpTable := FWTemporaryTable():New(cAlias)
oTmpTable:SetFields( aColumns ) 
oTmpTable:Create() 

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fLoadFile      ³ Autor ³ Leandro Drumond    ³ Data ³ 12/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Carrega modelo de layout                             			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fLoadFile()    			                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³GPEA014					                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fLoadFile(cFile,oGet)

Local aFile		 := {}
Local nHdlTmp	 := 0
Local xBuffer	 := ""

If !File(cFile)
	MsgAlert(OemToAnsi(STR0015) + cFile)  // "Arquivo nao encontrado "
	Return .T. //Retorna .T. porque a utilização da rotina independente da carga do arquivo.
Else
	oGet:aCols := {}
	DbSelectArea(cAliasTmp)
	
	FT_FUSE(cFile)
	FT_FGOTOP()
	
	While !FT_FEOF()
		xBuffer := FT_FREADLN()
		
		RecLock(cAliasTmp,.T.)
		(cAliasTmp)->TAB_CAMPO 	:= SubStr(xBuffer,1,28)  
		(cAliasTmp)->TAB_TIPO	:= SubStr(xBuffer,29,1)
		(cAliasTmp)->TAB_TAM	:= Val(SubStr(xBuffer,30,4))
		(cAliasTmp)->TAB_FIXO	:= SubStr(xBuffer,34,1)
		(cAliasTmp)->TAB_CODIGO := SubStr(xBuffer,35,50)
		MsUnLock()
		
		aAdd( oGet:aCols, {(cAliasTmp)->TAB_CAMPO , (cAliasTmp)->TAB_TIPO, (cAliasTmp)->TAB_TAM, (cAliasTmp)->TAB_FIXO, (cAliasTmp)->TAB_CODIGO, .F. } )	
		
		FT_FSKIP()
	
	EndDo
	
	FT_FUSE() //Libera o arquivo

EndIf

//Atualiza getdados com novos valores
oGet:Refresh()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp014LinOk     ³ Autor ³ Henrique Velloso   ³ Data ³ 24/04/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida linhas da Grid                               			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³gp014LinOk()			                                    	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³GPEA014					                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function gp014LinOk(nLin)

Local lRet 	 		:= .T.
Local nPosTipo  	:= GdFieldPos( "TAB_TIPO" )
Local nPosCampo  	:= GdFieldPos( "TAB_CAMPO" )
Local cTipo 		:= "C*N"

If valType(nLin) == "N"
	n:=nLin
EndIf


If !(("[" $ aCols[n][nPosCampo]) .Or. ("]" $ aCols[n][nPosCampo])) .And. !( aCols[n][nPosTipo] $ cTipo )
	Alert(STR0016)//'O campo Tipo deve ser preenchido com conteúdo "C" - Caractere ou "N" - Numérico'
	lRet := .F.
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gp014TudOk      ³ Autor ³ Henrique Velloso   ³ Data ³ 24/04/15³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida grid como um todo                            			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³gp014TudOk() 			                                    	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³GPEA014					                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function gp014TudOk()

Local lRetorna	:= .T.
Local nX 		:= 0

For nX := 1 to Len( aCols )
	lRetorna := Gp014LinOk (nX)
	If !lRetorna
		Exit
	EndIf
Next nX
	
Return lRetorna
