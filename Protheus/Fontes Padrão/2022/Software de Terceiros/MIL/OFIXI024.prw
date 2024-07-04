// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 2      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFIXI024.CH"

/*
================================================================================
################################################################################
##+----------+------------+-------+-----------------------+------+-----------+##
##|Função    | OFIXI024   | Autor | Renato Vinicius       | Data | 17/06/15  |##
##+----------+------------+-------+-----------------------+------+-----------+##
##|Descrição | Importação da Nova tabela de Preços Mitsubishi           	  |##
##|			 |                                                        		  |##
##+----------+---------------------------------------------------------------+##
##|Uso       |                                                               |##
##+----------+---------------------------------------------------------------+##
################################################################################
================================================================================
*/
Function OFIXI024()
//
Local cDesc1  := STR0001
Local cDesc2  := STR0002

Local cDesc3  := STR0003
Local aSay := {}
Local aButton := {}

Private cTitulo := ""
Private cPerg := "OXI024" 	// TODO - Pergunte
Private lErro := .f.  	    // Se houve erro, não move arquivo gerado
Private cArquivo			// Nome do Arquivo a ser importado
Private aLinhasRel := {}	// Linhas que serão apresentadas no relatorio

/*if TamSX3("B1_CODITE")[1] < 17
	MsgInfo(STR0012)
	return .f.
endif*/
//
CriaSX1()
//
aAdd( aSay, cDesc1 ) // Um para cada cDescN
aAdd( aSay, cDesc2 ) // Um para cada cDescN
aAdd( aSay, cDesc3 ) // Um para cada cDescN
//
nOpc := 0
aAdd( aButton, { 5, .T., {|| Pergunte(cPerg,.T. )    }} )
aAdd( aButton, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
aAdd( aButton, { 2, .T., {|| FechaBatch()            }} )
//
FormBatch( cTitulo, aSay, aButton )
//
If nOpc <> 1
	Return
Endif
//
Pergunte(cPerg,.f.)
//
RptStatus( {|lEnd| ImportArq(@lEnd)},"",STR0004)

//
return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | ImportArq  | Autor | Renato Vinicius       | Data | 17/06/15 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Importar arquivo.									        |          |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function ImportArq()

Local cFilTabSel := ""
Local cCpoGrv := ""
Local nTmCpo := 0
Local cTabSel := ""
Local lAchoCpo := .f.
Local nVal := 0

if Empty(mv_par01)
	MsgInfo(STR0005)
	Return(.f.)
Endif

cTabSel := Iif(MV_PAR02=1,'SB1',Iif(MV_PAR02=2,'SB5',Iif(MV_PAR02=3,'SBZ',''))) // Alias da tabela que será atualizada
lAchoCpo := ( ( cTabSel )->(FieldPos( MV_PAR03 )) > 0 ) // Checagem de existencia do campo informado no parametro 3

If lAchoCpo
	If File(mv_par01)		
		if (nHandle:= FT_FUse( mv_par01 )) == -1
			Return
		EndIf

		cFilTabSel := xFilial( cTabSel )
		cCpoGrv := cTabSel + "->" + AllTrim(MV_PAR03)

		FT_FGotop()
		While ! FT_FEof()			
			cStr := FT_FReadLN()
			If !Empty(cStr)
				nTmCpo := Len(Alltrim(substr(cStr,1,TamSX3("B1_COD")[1])))
				if nTmCpo > 22 // Tamanho máximo suportado pelo layout de importação (Código do Produto)
					nTmCpo := 22
				EndIf
				if ( cTabSel )->(dbSeek( cFilTabSel +substr(cStr,1,nTmCpo)))
					nVal := val(substr(cStr,23,32))/100
					If nVal > 0
						RecLock( cTabSel ,.f.)
						&(cCpoGrv) := nVal
						MsUnlock()
					EndIf
				EndIf		
			Endif
			FT_FSkip()
		End
		FT_FUse()
		MsgInfo(STR0006)
	EndIf
Else
	MsgInfo(STR0012)
Endif

return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OFIXI024  ºAutor  ³Microsiga           º Data ³  06/17/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function OXI024VLD()

Local lRet := ( ( Iif(MV_PAR02==1,'SB1',Iif(MV_PAR02==2,'SB5',Iif(MV_PAR02==3,'SBZ',''))) )->(FieldPos( MV_PAR03 )) > 0 ) // Checagem de existencia do campo informado no parametro 3

Return lRet

/*
=============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | CriaSX1    | Autor |  Luis Delorme         | Data | 30/05/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Criacao das perguntas.                                       |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function CriaSX1()
Local aSX1    := {}
Local aEstrut := {}
Local i       := 0
Local j       := 0
Local lSX1	  := .F.
Local cTexto  := ''
Local nOpcGetFil := GETF_LOCALHARD + GETF_NETWORKDRIVE


dbSelectArea("SX1")
If dbSeek(cPerg)
	cTexto += STR0007+CHR(13)+CHR(10)
	Return cTexto
Endif

aEstrut:= { "X1_GRUPO"  ,"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL"	,;
"X1_GSC"    ,"X1_VALID","X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2"	,;
"X1_DEFENG2","X1_CNT02","X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4"	,;
"X1_DEFENG4","X1_CNT04","X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3"     ,"X1_GRPSXG" ,"X1_PYME"}


aAdd(aSX1,{cPerg,"01",STR0008 ,"","","MV_CH1","C",99,0,0,"G","!Vazio().or.(Mv_Par01:=cGetFile('*.*','',,,,"+AllTrim(Str(nOpcGetFil))+"))","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"02",STR0009 ,"","","MV_CH2","N",1 ,0,1,"C","","mv_par02","SB1","","","","","SB5","","","","","SBZ","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"03",STR0010 ,"","","MV_CH3","C",10,0,0,"G","OXI024VLD()","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})

ProcRegua(Len(aSX1))

dbSelectArea("SX1")
dbSetOrder(1)
For i:= 1 To Len(aSX1)
	If !Empty(aSX1[i][1])
		If !dbSeek(Left(Alltrim(aSX1[i,1])+SPACE(100),Len(SX1->X1_GRUPO))+aSX1[i,2])
			lSX1 := .T.
			RecLock("SX1",.T.)
			
			For j:=1 To Len(aSX1[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSX1[i,j])
				EndIf
			Next j
			
			dbCommit()
			MsUnLock()
			IncProc(STR0011)
		EndIf
	EndIf
Next i

return