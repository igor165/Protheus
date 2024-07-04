#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM880.CH"
                
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPEM880   บAutor  ณTiago Malta         บ Data ณ  26/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo de importa็ใo das tabelas auxiliares de IRS.        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             บฑฑ
ฑฑฬอออออออออออัออออออออัออออออออัอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramadorณ Data   ณ FNC    ณ  Motivo da Alteracao             		  บฑฑ
ฑฑฬอออออออออออุออออออออุออออออออุอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบLeandro Dr.ณ27/09/12ณM12RH01 ณRequisito RHU210 - Unifica็ใo das folhas บฑฑ
ฑฑศอออออออออออฯออออออออฯออออออออฯอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function GPEM880()
                                  
Local oFont1 := TFont():New("Arial",,013,,.T.,,,,,.F.,.F.)
Local oSay1
Local oSay10
Local oSay11
Local oSay12
Local oSay13
Local oSay14
Local oSay15
Local oSay16
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6
Local oSay7
Local oSay8
Local oSay9
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}  
Local bSet15	:= {|| ImportCsv(cGetImp, cGetImp2),oDlg:End()}
Local bSet24	:= {|| oDlg:End()}
Local oScroll 
Local oPnl12
  
Static oDlg

Private oS002
Private nS002 := 0
Private oS003
Private nS003 := 0
Private oS004
Private nS004 := 0
Private oS005
Private nS005 := 0
Private oS006
Private nS006 := 0
Private oS007
Private nS007 := 0
Private oS008
Private nS008 := 0
Private oS009
Private nS009 := 0
Private oS010
Private nS010     := 0   
Private oGetImp
Private cGetImp   := space(99)
Private oGetImp2
Private cGetImp2  := space(99)
Private oFolder1
Private oComboBo1
Private nComboBo1 := 1 
Private aTitle    := {STR0001}
Private aLog      := {}

aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
		
 DEFINE MSDIALOG oDlg TITLE STR0002 FROM 0,0 TO aAdvSize[1]+400,aAdvSize[1]+420 COLORS 0, 16777215 PIXEL 

    @ aObjSize[1][1] + 003 , 001 SCROLLBOX oScroll HORIZONTAL VERTICAL SIZE aObjSize[1][1]+380, aObjSize[1][1] +400 PIXEL OF oDlg

	@ aObjSize[1][1] + 3, aObjSize[1][1] SAY oSay16 PROMPT STR0003 SIZE aObjSize[1][1] + 20, aObjSize[1][1] - 5 OF oScroll COLORS 0, 16777215 PIXEL
    @ aObjSize[1][1] + 2, aObjSize[1][1] + 23 MSCOMBOBOX oComboBo1 VAR nComboBo1 ITEMS {STR0004,STR0005,STR0006} SIZE aObjSize[1][1] + 60, aObjSize[1][1] - 2 OF oScroll COLORS 0, 16777215 PIXEL

    @ aObjSize[1][1] + 22 , aObjSize[1][2] + 6 FOLDER oFolder1 SIZE aObjSize[1][1] + 184 , aObjSize[1][1] + 135 OF oScroll ITEMS STR0007,STR0008 COLORS 0, 16777215 PIXEL
    
    @ aObjSize[1][1] + 8,  aObjSize[1][1] 	SAY oSay1 PROMPT STR0009    SIZE aObjSize[1][1] , aObjSize[1][1] OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
    @ aObjSize[1][1] + 23, aObjSize[1][1]	SAY oSay2 PROMPT STR0010    SIZE aObjSize[1][1] , aObjSize[1][1] OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
    @ aObjSize[1][1] + 38, aObjSize[1][1] 	SAY oSay3 PROMPT STR0011    SIZE aObjSize[1][1] , aObjSize[1][1] OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
    @ aObjSize[1][1] + 53, aObjSize[1][1]	SAY oSay4 PROMPT STR0012    SIZE aObjSize[1][1] , aObjSize[1][1] OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
    @ aObjSize[1][1] + 68, aObjSize[1][1]	SAY oSay5 PROMPT STR0012  	SIZE aObjSize[1][1] , aObjSize[1][1] OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
    @ aObjSize[1][1] + 83, aObjSize[1][1]	SAY oSay6 PROMPT STR0014 	SIZE aObjSize[1][1] , aObjSize[1][1] OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
    @ aObjSize[1][1] + 8 , aObjSize[1][1] + 137 MSGET oS002 VAR nS002 	SIZE aObjSize[1][1] , aObjSize[1][1] OF oFolder1:aDialogs[1] PICTURE "999" COLORS 0, 16777215 PIXEL
    @ aObjSize[1][1] + 23, aObjSize[1][1] + 137 MSGET oS003 VAR nS003 	SIZE aObjSize[1][1] , aObjSize[1][1] OF oFolder1:aDialogs[1] PICTURE "999"COLORS 0, 16777215 PIXEL
    @ aObjSize[1][1] + 38, aObjSize[1][1] + 137 MSGET oS004 VAR nS004 	SIZE aObjSize[1][1] , aObjSize[1][1] OF oFolder1:aDialogs[1] PICTURE "999" COLORS 0, 16777215 PIXEL
    @ aObjSize[1][1] + 53, aObjSize[1][1] + 137 MSGET oS005 VAR nS005 	SIZE aObjSize[1][1] , aObjSize[1][1] OF oFolder1:aDialogs[1] PICTURE "999" COLORS 0, 16777215 PIXEL
    @ aObjSize[1][1] + 68, aObjSize[1][1] + 137 MSGET oS006 VAR nS006 	SIZE aObjSize[1][1] , aObjSize[1][1] OF oFolder1:aDialogs[1] PICTURE "999" COLORS 0, 16777215 PIXEL
    @ aObjSize[1][1] + 83, aObjSize[1][1] + 137 MSGET oS007 VAR nS007 	SIZE aObjSize[1][1] , aObjSize[1][1] OF oFolder1:aDialogs[1] PICTURE "999" COLORS 0, 16777215 PIXEL
    @ aObjSize[1][1] + 103, aObjSize[1][1]	SAY oSay7 PROMPT STR0015   	SIZE aObjSize[1][1] , aObjSize[1][1] OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
    @ aObjSize[1][1] + 101, aObjSize[1][1] + 45 MSGET oGetImp VAR cGetImp  When GetFile() 	SIZE aObjSize[1][1] + 73, aObjSize[1][1] - 2 OF oFolder1:aDialogs[1] COLORS 0, 16777215 PIXEL
//    @ aObjSize[1][1] + 101, aObjSize[1][1] + 136 BUTTON oBtImp1 PROMPT STR0016         	SIZE aObjSize[1][1] + 18, aObjSize[1][1] OF oFolder1:aDialogs[1] ACTION ImportCsv(cGetImp) PIXEL
    @ aObjSize[1][2] , aObjSize[1][1] + 121   	SAY oSay8 PROMPT STR0017 SIZE aObjSize[1][1] , aObjSize[1][1] OF oFolder1:aDialogs[1] FONT oFont1 COLORS 0, 16777215 PIXEL
    @ aObjSize[1][2] , aObjSize[1][1]  		SAY oSay9 PROMPT STR0021 SIZE aObjSize[1][1] , aObjSize[1][1] OF oFolder1:aDialogs[1] FONT oFont1 COLORS 0, 16777215 PIXEL
    
    @ aObjSize[1][2] , aObjSize[1][1] 			SAY oSay10 PROMPT STR0021 SIZE aObjSize[1][1] , aObjSize[1][1] OF oFolder1:aDialogs[2] FONT oFont1 COLORS 0, 16777215 PIXEL
    @ aObjSize[1][2] , aObjSize[1][1] + 121 	SAY oSay11 PROMPT STR0017 SIZE aObjSize[1][1] , aObjSize[1][1] OF oFolder1:aDialogs[2] FONT oFont1 COLORS 0, 16777215 PIXEL
    @ aObjSize[1][1] + 8, aObjSize[1][1]		SAY oSay12 PROMPT STR0018 SIZE aObjSize[1][1] , aObjSize[1][1] OF oFolder1:aDialogs[2] COLORS 0, 16777215 PIXEL
    @ aObjSize[1][1] + 8, aObjSize[1][1] + 137 MSGET oS008 VAR nS008	  SIZE aObjSize[1][1] , aObjSize[1][1] OF oFolder1:aDialogs[2] PICTURE "999" COLORS 0, 16777215 PIXEL
    @ aObjSize[1][1] + 22, aObjSize[1][1]		SAY oSay13 PROMPT STR0019 SIZE aObjSize[1][1] , aObjSize[1][1] OF oFolder1:aDialogs[2] COLORS 0, 16777215 PIXEL
    @ aObjSize[1][1] + 38, aObjSize[1][1]		SAY oSay14 PROMPT STR0020 SIZE aObjSize[1][1] , aObjSize[1][1] OF oFolder1:aDialogs[2] COLORS 0, 16777215 PIXEL
    @ aObjSize[1][1] + 23, aObjSize[1][1] + 137 MSGET oS009 VAR nS009	  SIZE aObjSize[1][1] , aObjSize[1][1] OF oFolder1:aDialogs[2] PICTURE "999" COLORS 0, 16777215 PIXEL
    @ aObjSize[1][1] + 38, aObjSize[1][1] + 137 MSGET oS010 VAR nS010	  SIZE aObjSize[1][1] , aObjSize[1][1] OF oFolder1:aDialogs[2] PICTURE "999" COLORS 0, 16777215 PIXEL
    @ aObjSize[1][1] + 103, aObjSize[1][1]		SAY oSay15 PROMPT STR0015 SIZE aObjSize[1][1] , aObjSize[1][1] OF oFolder1:aDialogs[2] COLORS 0, 16777215 PIXEL
    @ aObjSize[1][1] + 101, aObjSize[1][1] + 45 MSGET oGetImp2  VAR cGetImp2  When GetFile()  	SIZE aObjSize[1][1] + 73, aObjSize[1][1] - 2 OF oFolder1:aDialogs[2] COLORS 0, 16777215 PIXEL
//    @ aObjSize[1][1] + 110, aObjSize[1][1] + 136 BUTTON oBtImp2 PROMPT STR0016             	SIZE aObjSize[1][1] + 18, aObjSize[1][1] OF oFolder1:aDialogs[2] ACTION ImportCsv(cGetImp2) PIXEL 
         
  ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 ) CENTERED

Return() 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImportCsv บAutor  ณTiago Malta         บ Data ณ  10/26/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Fun็ใo de leitura do arquivo csv.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ImportCsv(cArq1, cArq2) 

Local aDados  := {}
Local aArquivo:= {} 
Local nHandle := 0 
Local cLine   := ""
Local cArquivo:= ""
Local nPasta  := 0
Local aPos    := {}
Local n       := 1
Local nX	  := 0  
Local nlinha  := 1

DEFAULT cArq1 := ""
DEFAULT cArq2 := ""

If !Empty(cArq1)
	aAdd(aArquivo,{cArq1,1})
EndIf

If !Empty(cArq2)
	aAdd(aArquivo,{cArq2,2})
EndIf

For nX := 1 to Len(aArquivo)

	cArquivo := aArquivo[nX,1]
	nPasta	 := aArquivo[nX,2]
	
	If File(cArquivo)
	
		If nPasta == 1
			aAdd( aPos , { nS002 , "S002" } )
			aAdd( aPos , { nS003 , "S003" } )
			aAdd( aPos , { nS004 , "S004" } )
			aAdd( aPos , { nS005 , "S005" } )
			aAdd( aPos , { nS006 , "S006" } )
			aAdd( aPos , { nS007 , "S007" } )
		Else
			aAdd( aPos , { nS008 , "S008" } )
			aAdd( aPos , { nS009 , "S009" } )
			aAdd( aPos , { nS010 , "S010" } )
		EndIf

		nHandle := FT_FUse(cArquivo)
		
		// Se houver erro de abertura abandona processamento
		If nHandle = -1
		  Return
		EndIf
		
		FT_FGoTop()
		
		While !FT_FEOF()
		
			IF n <= len(aPos) .and. nlinha == aPos[n][1] 
				
				While !FT_FEOF()
				
					cLine  := FT_FReadLn() // Retorna a linha corrente
				    
				    If Empty( Strtran( cLine , ";" ) )
				    	EXIT
				    EndIf   
				    
				    aAdd( aDados , CsvToArray(cLine,.T.,"%") )
				     
					nlinha++
					FT_FSKIP()
				EndDo
				
				// Grava็ใo das tabelas auxiliares.
				If GravaRCC( aPos[n][2] , aDados )
					aAdd( aLog , { STR0022 + SPACE(1) + aPos[n][2] + SPACE(1) + STR0023} )
				Else
					aAdd( aLog , { STR0022 + SPACE(1) + aPos[n][2] + SPACE(1) + STR0024} )
				EndIf
				
				aDados := {}
				n++
			ElseIf n <= len(aPos) .and. aPos[n][1] == 0 
				n++
			EndIf
		 
			nlinha++
			FT_FSKIP()
		EndDo
		
		// Fecha o Arquivo
		FT_FUSE() 

	EndIf
	
Next nX
	
fMakeLog(aLog,aTitle,"GPEM880")
aLog := {}
	
Return()                              


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetFile   บAutor  ณTiago Malta         บ Data ณ  10/26/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo de escolha do diretorio da importa็ใo.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GetFile()
        
Local nFocus  := Getfocus()
Local _cPath  := "" 
Local nPasta  := oFolder1:nOption
                  
	IF nFocus == oGetImp:hwnd .OR. nFocus == oGetImp2:hwnd
	
		_cPath:=cGetFile(  STR0025 + " (*.CSV) |*.csv|" , STR0026 )
		  
		IF nPasta == 1
			cGetImp := _cPath 
			SetFocus(oS002:hwnd)
		ELSE
			cGetImp2 := _cPath
			SetFocus(oS008:hwnd)		
		ENDIF

	ENDIF 
	 
Return() 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCsvToArray บAutor  ณTiago Malta        บ Data ณ  10/20/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que converte string com ponto e virgula para array. บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function CsvToArray(cVar,lRetira,cCont)

Local aDados := {}
Local cDados := cVar 
Local cRes   := ""
Local nPos   := 0 

	While !Empty(cDados)
	
		nPos := AT(";",cDados) 
		
		IF lRetira       
			cRes := StrTran( Substr(cDados,1,nPos-1) , cCont , "" )
		Else
			cRes := Substr(cDados,1,nPos-1)			
		Endif
		
		aAdd( aDados , cRes )
		cDados := Substr( cDados , nPos + 1 , len(cDados) )
	
	Enddo

Return(aDados)   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGravaRCC   บAutor  ณTiago Malta        บ Data ณ  10/20/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava็ใo de dados do arquivo csv na tabela RCC             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GravaRCC( cTabela , aDados )

Local aEstrut := {}
Local cAnomes := AnoMes(dDatabase-30)                                
Local i       := 0
Local ii      := 0
Local ix      := 0
Local cCont   := ""
Local cSeq    := "001"
Local nCntEstr:= 0 
Local aRecnos := {}
Local lRet    := .F.
Local lExiste := .F.
         
    // Guarda a Estrutura da tabela auxiliar
	DBSELECTAREA("RCB")
	RCB->( DBSETORDER(1) )
	RCB->( DBSEEK( xFilial("RCB") + cTabela  ) )
	While RCB->( !EOF() ) .AND. RCB->RCB_CODIGO == cTabela	             
	    aAdd( aEstrut , { RCB->RCB_CAMPOS , RCB->RCB_TIPO , RCB->RCB_TAMAN , RCB->RCB_DECIMA , RCB->RCB_PICTUR } )
		RCB->( DBSKIP() )
	ENDDO
	
	//Atualiza os registro sem mes e ano para o mes anterior da importa็ใo 
	DBSELECTAREA("RCC")
	RCC->( DBSETORDER(1) )
	RCC->( DBSEEK( xFilial("RCC") + cTabela  ) )
	While RCC->( !EOF() ) .AND. RCC->RCC_CODIGO == cTabela 
	
		IF EMPTY(RCC->RCC_CHAVE) 
			aAdd( aRecnos , RCC->( RECNO() ) )
		ELSEIF RCC->RCC_CHAVE == cAnomes
			lExiste := .T.
			EXIT
		ENDIF
		
		RCC->( DBSKIP() )
	ENDDO
	
	IF !lExiste	 
	
		FOR ii:=1 To len(aRecnos)	
			RCC->( dbgoto(aRecnos[ii]) )
			RecLock("RCC",.F.)
			RCC->RCC_CHAVE := cAnomes
			RCC->(Msunlock()) 
		Next ii           
		      
		// Grava็ใo dos dados do arquivo csv.
		For i=1 to Len(aDados)
		    
			nCntEstr := 3
			cCont    := Alltrim(Str(oComboBo1:NAT)) + ;
			            Alltrim(oComboBo1:AITEMS[oComboBo1:NAT]) + ;
			            Space( aEstrut[2][3] - Len(oComboBo1:AITEMS[oComboBo1:NAT]) )
			
			For ix=2 to Len(aDados[i])
				if type(aDados[i][ix]) == "N"
					if (ix+1) <= Len( aEstrut )
						cCont += Space( aEstrut[ix+1][3] - Len(StrTran( StrTran( aDados[i][ix] , ".", "") , ",",".")) ) +;
								 StrTran( StrTran( aDados[i][ix] , ".", "") , ",",".")
						nCntEstr++
					endif
				endif
			Next ix
			
			RecLock("RCC",.T.)  
			RCC->RCC_FILIAL := xFilial("RCC")
			RCC->RCC_CODIGO := cTabela 
			RCC->RCC_SEQUEN := cSeq
			RCC->RCC_CONTEU := cCont
			RCC->( Msunlock() )
			
			cSeq  := Soma1(cSeq)
			cCont := ""
			
			lRet := .T.
		   
		Next i 
	
	ELSE
		lRet := .F.
	ENDIF
	
Return(lRet)