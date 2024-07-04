// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 4      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW00.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    | OFINVW00   | Autor | Luis Delorme          | Data | 27/03/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Relatório de Importação de Rotinas de Integração VW          |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINVW00()

Local nCntFor

Local cDesc1  := STR0039
Local cDesc2  := ""
Local cDesc3  := ""

Private cString  := ""
Private Tamanho  := "G"
Private aReturn  := { "Zebrado",2,"Administracao",2,2,1,"",1 }
Private wnrel    := "OFINVW00"
Private NomeProg := "OFINVW00"
Private nLastKey := 0
Private Limite   := 220
Private Titulo   := STR0040
Private nTipo    := 15
Private cbCont   := 0
Private cbTxt    := " "
Private Li       := 999
Private m_pag    := 1
Private aOrd     := {}
Private aLinErros := {}
Private Cabec1   := " "
Private Cabec2   := " "
Private cPerg := ""
//
Private aSay := {}			// PARAMBOX
Private aButton := {}		// PARAMBOX
Private nOpc := 0
//
Private aIntCab := {} // FGX_VISINT
Private aIntIte := {} // FGX_VISINT

aAdd(aIntCab, {STR0037,STR0038} )

aAdd( aSay, STR0001)
aAdd( aSay, STR0002 )
aAdd( aSay, STR0003 )

aAdd( aButton, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
aAdd( aButton, { 2, .T., {|| FechaBatch()            }} )

FormBatch( Titulo, aSay, aButton )

If nOpc <> 1
	Return
Endif

//+-------------------------------------------------------------------------------
//| Solicita ao usuario a parametrizacao do relatorio.
//+-------------------------------------------------------------------------------
wnrel := SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,.F.,.F.)
//+-------------------------------------------------------------------------------
//| Se teclar ESC, sair
//+-------------------------------------------------------------------------------
If nLastKey == 27
	Return
Endif
//+-------------------------------------------------------------------------------
//| Estabelece os padroes para impressao, conforme escolha do usuario
//+-------------------------------------------------------------------------------
SetDefault(aReturn,cString)
//+-------------------------------------------------------------------------------
//| Verificar se sera reduzido ou normal
//+-------------------------------------------------------------------------------
nTipo := Iif(aReturn[4] == 1, 15, 18)
//+-------------------------------------------------------------------------------
//| Se teclar ESC, sair
//+-------------------------------------------------------------------------------
If nLastKey == 27
	Return
Endif
//
ImportArq()
//
If aReturn[5] == 1
	Set Printer TO
	dbCommitAll()
	OurSpool(wnrel)
EndIf
//
Ms_Flush()
//
return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    | OFINVW00   | Autor | Luis Delorme          | Data | 27/03/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição |                                                              |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function ImportArq()
//
Local nCurArq, nCntFor
//
Local aVetNome := {}
Local aVetTam := {}
Local aVetData := {}
Local aVetHora := {}
//
Private oOkTik   := LoadBitmap( GetResources() , "LBTIK" )
Private oNoTik   := LoadBitmap( GetResources() , "LBNO" )
//
cArquivo := cGetFile( "*.txt" , "Textos (TXT)", 1, , .F., ,.T., .T. )
//
nTamArq = Len(cArquivo)
//
if nTamArq = 0
	lAbort = .t.
	return
endif
//
aArquivos := {}
aAdd(aArquivos,cArquivo)
//
aAssuntos := {}
Aadd(aAssuntos,{"FT5", STR0005,"OFINVW01"})
Aadd(aAssuntos,{"FVW000",  STR0006,"OFINVW02"})
Aadd(aAssuntos,{"F23", STR0007,"OFINVW03"})
Aadd(aAssuntos,{"FG9", STR0008,"OFINVW04"})
Aadd(aAssuntos,{"FG0", STR0009,"OFINVW05"})
Aadd(aAssuntos,{"FG1", STR0010,"OFINVW06"})
Aadd(aAssuntos,{"FG2", STR0011,"OFINVW07"})
Aadd(aAssuntos,{"FG3", STR0012,"OFINVW08"})
Aadd(aAssuntos,{"FG4", STR0013,"OFINVW09"})
Aadd(aAssuntos,{"FL3", STR0014,"OFINVW10"})
Aadd(aAssuntos,{"FP5", STR0015,"OFINVW11"})
Aadd(aAssuntos,{"FP6", STR0016,"OFINVW12"})
Aadd(aAssuntos,{"FP7", STR0017,"OFINVW13"})
Aadd(aAssuntos,{"FP8", STR0018,"OFINVW14"})
Aadd(aAssuntos,{"F40", STR0019,"OFINVW15"})
Aadd(aAssuntos,{"F10", STR0020,"OFINVW16"})
Aadd(aAssuntos,{"F27", STR0021,"OFINVW17"})
Aadd(aAssuntos,{"FK1", STR0022,"OFINVW18"})
Aadd(aAssuntos,{"FCR75", STR0023,"OFINVW22"})
Aadd(aAssuntos,{"FCR321", STR0024,"OFINVW23"})
Aadd(aAssuntos,{"FCR320", STR0025,"OFINVW24"})
Aadd(aAssuntos,{"FCR330", STR0026,"OFINVW25"})
Aadd(aAssuntos,{"FA1", STR0027,"OFINVW26"})
Aadd(aAssuntos,{"FA4", STR0028,"OFINVW27"})
Aadd(aAssuntos,{"FNT", STR0029,"OFINVW28"})
Aadd(aAssuntos,{"FLH555", STR0030,"OFINVW29"})
Aadd(aAssuntos,{"FLH600", STR0031,"OFINVW30"})
Aadd(aAssuntos,{"FA3", STR0032,"OFINVW31"})
Aadd(aAssuntos,{"FG5", STR0041,"OFINVW32"})
Aadd(aAssuntos,{"F50", STR0042,"OFINVW33"})
//
for nCurArq := 1 to Len(aArquivos)
	// pega o próximo arquivo
	cArquivo := Alltrim(aArquivos[nCurArq])
	nTamArq = Len(cArquivo)
	if nTamArq == 0
		loop
	endif
	// verifica existência do arquivo somente para garantia
	if !File(cArquivo)
		aAdd(aLinErros,STR0033 + cArquivo + STR0034)
		loop
	endif
	// extrai diretório e verifica se ele já foi processado e está no salva
	while nTamArq != 0 .and. Subs(cArquivo,nTamArq,1) != "\"
		nTamArq--
	enddo
	cDir := Subs(cArquivo,1,nTamArq)
	cArq := Subs(cArquivo,nTamArq+1)
	if aDir( cDir + "SALVA\" + cArq , aVetNome, aVetTam, aVetData, aVetHora) > 0
		if !MsgYesNo(STR0033+cArquivo+STR0035,STR0036)
			loop
		endif
	endif
	//
	FT_FUse( cArquivo )
	//
	FT_FGotop()
	if FT_FEof()
		aAdd(aLinErros, cArquivo)
		loop
	endif
	//
	nTotRec := FT_FLastRec()
	//
	nLinhArq := 0
	//
	// INICIO DO PROCESSAMENTO DOS ARQUIVOS
	//
	While !FT_FEof()
		//
		cStr := FT_FReadLN()
		nLinhArq++
		//
			for nCntFor := 1 to Len(aAssuntos)
			if Left(cStr,len(aAssuntos[nCntFor,1])) == aAssuntos[nCntFor,1]
				if aScan(aIntIte, { |x| x[1] == aAssuntos[nCntFor,1] }) == 0
					aAdd(aIntIte, {aAssuntos[nCntFor,1], aAssuntos[nCntFor,2],aAssuntos[nCntFor,3] } )
				endif
			endif
		next
		//
		FT_FSkip()
	EndDo
	//
	FT_FUse()
next
//
aSizeHalf  := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
//
aObjects   := {}
aAdd( aObjects, { 0 , 13 , .T. , .F. } ) // Titulo / Botoes
aAdd( aObjects, { 0 ,  0 , .T. , .T. } ) // ListBox
//
aPos := MsObjSize( aInfo, aObjects )
//
For nCntFor := 1 to len(aIntIte) // Adicionar campo de TIK no vetor (1a.coluna)
	aIntIte[nCntFor] := aSize(aIntIte[nCntFor],Len(aIntIte[nCntFor])+1) // Criar uma posicao a mais no vetor
	aIntIte[nCntFor] := aIns(aIntIte[nCntFor],1) // inserir 1a. coluna
	aIntIte[nCntFor,1] := .t.
Next

lRetDlg := .f.

DEFINE MSDIALOG oFGX_VISINT FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (cArq + " - " + Titulo) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS
oFGX_VISINT:lEscClose := .F.
oLbVISINT := TWBrowse():New(aPos[2,1]+2,aPos[2,2]+2,(aPos[2,4]-aPos[2,2]-4),(aPos[2,3]-aPos[2,1]-4),,,,oFGX_VISINT,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbVISINT:nAT := 1
oLbVISINT:SetArray(aIntIte)
oLbVISINT:addColumn( TCColumn():New( "" , { || IIf(aIntIte[oLbVISINT:nAt,1] , oOkTik , oNoTik ) } ,,,,"LEFT" ,05,.T.,.F.,,,,.F.,) ) // Tik
oLbVISINT:addColumn( TCColumn():New( STR0037 , { || aIntIte[oLbVISINT:nAt,2] } ,,,, "LEFT" , 20 ,.F.,.F.,,,,.F.,) ) // DEMAIS Colunas
oLbVISINT:addColumn( TCColumn():New( STR0038 , { || aIntIte[oLbVISINT:nAt,3] } ,,,, "LEFT" , 11 ,.F.,.F.,,,,.F.,) ) // DEMAIS Colunas
oLbVISINT:bLDblClick := { || aIntIte[oLbVISINT:nAt,1] := !aIntIte[oLbVISINT:nAt,1] }
oLbVISINT:Refresh()
//
ACTIVATE MSDIALOG oFGX_VISINT ON INIT EnchoiceBar(oFGX_VISINT,{|| lRetDlg := .t., oFGX_VISINT:End()},{|| oFGX_VISINT:End()},,)
//

if !lRetDlg
	return .f.
endif
For nCntFor := 1 to len(aIntIte) // Adicionar campo de TIK no vetor (1a.coluna)
	if aIntIte[nCntFor,1]
		Titulo   := STR0040
		Li       := 999
		Cabec1   := " "
		Cabec2   := " "
		NomeProg := "OFINVW00"
		cMacro := aIntIte[nCntFor,4]+"('"+cArquivo+"')"
		&(cMacro)
	endif
next
//
return