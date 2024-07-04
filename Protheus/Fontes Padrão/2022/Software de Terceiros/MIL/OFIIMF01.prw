// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 5      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFIIMF01.CH"

/*
======================================================================================
######################################################################################
##+----------+------------+-------+------------------------------+------+----------+##
##|Função    | OFIIMF01   | Autor | Thiago                       | Data | 17/04/13 |##
##+----------+------------+-------+------------------------------+------+----------+##
##|Descrição | Importação das atualizações de Preços da Montadora Massey Ferguson. |##
##+----------+---------------------------------------------------------------------+##
##|Uso       |                                                                     |##
##+----------+---------------------------------------------------------------------+##
######################################################################################
======================================================================================
*/
Function OFIIMF01()
//
Local cDesc1  := STR0001
Local cDesc2  := STR0002
Local cDesc3  := STR0003
Local aSay := {}
Local aButton := {}
Local i := 0

Private cTitulo := STR0004
Private cPerg := "OIMF01"
Private lErro := .f.  	    // Se houve erro, não move arquivo gerado
Private cArquivo			// Nome do Arquivo a ser importado
Private oNo      := LoadBitmap( GetResources(), "LBNO" )
Private oTik     := LoadBitmap( GetResources(), "LBTIK" )
Private aItens   := {}
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
If nOpc <> 1
	Return
Endif

Pergunte(cPerg,.f.)
cGrp := MV_PAR02
//
Processa( {|lEnd| ImportArq(@lEnd)},"",STR0006,.t.)
//
RptStatus({|lEnd| ImprimeRel(@lEnd) },STR0007, STR0008, .T. )
//

return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | ImportArq  | Autor | Thiago                | Data | 11/12/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Exporta arquivo.										        |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function ImportArq()

if Empty(mv_par01)
	MsgInfo(STR0016)
	Return(.f.)
Endif

if Empty(mv_par02)
	MsgInfo(STR0012)
	Return(.f.)
Endif

dbSelectArea("SBM")
dbSetOrder(1)
if dbSeek(xFilial("SBM")+mv_par02)
	if SBM->BM_PROORI <> "1"
		MsgInfo(STR0014)
	Endif
Else
	MsgInfo(STR0013)
	Return(.f.)
Endif

if Empty(mv_par01)
	MsgInfo(STR0011)
	Return(.f.)
Endif
If File(mv_par01)
	
	if (nHandle:= FT_FUse( mv_par01 )) == -1
		Return
	EndIf
	
	FT_FGotop()
	lRet := .f.
	nLin := 1
	While ! FT_FEof()
		
		cStr := FT_FReadLN()
		if nLin == 1
			nLin += 1
			FT_FSkip()
			Loop
		Endif
		if substr(cStr,1,1) == "A" .or. substr(cStr,1,1) == "I"
			dbSelectArea("SB1")
			dbSetOrder(7)
			if !dbSeek(xFilial("SB1")+cGrp+substr(cStr,2,25))
				aAdd(aItens,{cGrp,substr(cStr,2,25),substr(cStr,27,30),val(substr(cStr,73,9)),"I"})
				aIncSB1:= {}
				cPecInt := GetSXENum("SB1","B1_COD")
				ConfirmSX8()
				aAdd(aIncSB1,{"B1_COD"     , cPecInt		     		 	 ,Nil})
				aAdd(aIncSB1,{"B1_CODITE"  , substr(cStr,2,25)    		 	 ,Nil})
				aAdd(aIncSB1,{"B1_GRUPO"   , cGrp	     					 ,Nil})
				aAdd(aIncSB1,{"B1_DESC"    , substr(cStr,27,30)				 ,Nil})
				aAdd(aIncSB1,{"B1_TIPO"    , "ME"             				 ,Nil})
				aAdd(aIncSB1,{"B1_UM"      , "PC"                  			 ,Nil})
				aAdd(aIncSB1,{"B1_IPI"     , val(substr(cStr,61,4))/100 	 ,Nil})
				aAdd(aIncSB1,{"B1_CONV"    , val(substr(cStr,57,4))           	 ,Nil})
				aAdd(aIncSB1,{"B1_POSIPI"  , substr(cStr,65,8)           	 ,Nil})
				aAdd(aIncSB1,{"B1_PRV1"    , val(substr(cStr,73,9))			 ,Nil})
				aAdd(aIncSB1,{"B1_PPIS"    , val(substr(cStr,112,5))		  	 ,Nil})
				aAdd(aIncSB1,{"B1_PCOFINS" , val(substr(cStr,117,5))		 	 ,Nil})
				aAdd(aIncSB1,{"B1_LOCPAD"  ,"01"   			  				 ,Nil})
				aAdd(aIncSB1,{"B1_ORIGEM"  ,"0"   			  				 ,Nil})
				

				//Ponto de Entrada p/ Atualizar o Cadastro de Produto
				If ExistBlock("OMF01SB1")
					aIncSB1 := ExecBlock("OMF01SB1",.f.,.f.,{aIncSB1})
				EndIf
		
				lMSHelpAuto := .t.
				lMSErroAuto := .f.
				
				MSExecAuto({|x| mata010(x)},aIncSB1)
				
				if lMSErroAuto
					MostraErro()
					DisarmTransaction()
					Break
				Endif
				
			Else
				RecLock("SB1",.f.)
				SB1->B1_PRV1   := val(substr(cStr,73,9))
				MsUnlock()
				aAdd(aItens,{cGrp,substr(cStr,2,25),substr(cStr,27,30),val(substr(cStr,73,9)),"A"})
			Endif
		Else
			RecLock("SB1",.f.)
			SB1->B1_MSBLQL := "1"
			aAdd(aItens,{cGrp,substr(cStr,2,25),substr(cStr,27,30),val(substr(cStr,73,9)),"E"})
			MsUnlock()
		Endif
		FT_FSkip()
	End
	FT_FUse()
Else
	MsgStop(STR0017)
	Return(.f.)
Endif

MsgInfo(STR0021)

return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡…o    | ImprimeRel | Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡…o | Imprime o resultado da importação                           |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function ImprimeRel()

Local nCntFor

Local cDesc1  := ""
Local cDesc2  := ""
Local cDesc3  := ""

Private cString  := "SB1" // TODO
Private Tamanho  := "P"
Private aReturn  := { STR0018,2,STR0019,2,2,1,"",1 }
Private wnrel    := "OIMF01" // TODO
Private NomeProg := "OFIIMF01" // TODO
Private nLastKey := 0
Private Limite   := 80
Private Titulo   := "Atualizações de Preços da Montadora Massey Ferguson."
Private nTipo    := 0
Private cbCont   := 0
Private cbTxt    := " "
Private Li       := 80
Private m_pag    := 1
Private aOrd     := {}
Private Cabec1   := " "  // TODO
Private Cabec2   := " "  // TODO
Private cPerg := ""
//+-------------------------------------------------------------------------------
//| Solicita ao usuario a parametrizacao do relatorio.
//+-------------------------------------------------------------------------------
wnrel := SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,.F.,.F.)
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
//+-------------------------------------------------------------------------------
//| Chama funcao que processa os dados
//+-------------------------------------------------------------------------------

for nCntFor = 1 to Len(aItens)
	
	If Li > 55
		li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		li++
		@ Li++, 1   PSay STR0020
	Endif
	//
	if aItens[nCntFor,5] == "E"
		@ Li++, 1   PSay aItens[nCntFor,1]+" "+aItens[nCntFor,2]+" "+substr(aItens[nCntFor,3],1,25)+" "+transform(aItens[nCntFor,4],"@E 999,999,999.99")+" Bloqueado"
	Else
		@ Li++, 1   PSay aItens[nCntFor,1]+" "+aItens[nCntFor,2]+" "+substr(aItens[nCntFor,3],1,25)+" "+transform(aItens[nCntFor,4],"@E 999,999,999.99")
	Endif
	//+-------------------------------------------------------------------------------
	//| Se teclar ESC, sair
	//+-------------------------------------------------------------------------------
	If nLastKey == 27
		@ Li++ , 1 psay STR0011
		exit
	Endif
next
//
If Li <> 80
	Roda(cbCont,cbTxt,Tamanho)
Endif
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
##|Função    | CriaSX1	  | Autor | Thiago                | Data | 18/02/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Criacao das perguntes.								        |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function FS_VALIDSBM()
lRet := .f.

if Empty(mv_par02)
	MsgInfo(STR0012)
	Return(.f.)
Endif

dbSelectArea("SBM")
dbSetOrder(1)
if dbSeek(xFilial("SBM")+mv_par02)
	if SBM->BM_PROORI <> "1"
		MsgInfo(STR0014)
		Return(.f.)
	Endif
Else
	MsgInfo(STR0013)
	Return(.f.)
Endif

Return(.t.)
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | CriaSX1	  | Autor | Thiago                | Data | 18/02/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Criacao das perguntes.								        |##
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
Local nOpcGetFil := GETF_LOCALHARD + GETF_NETWORKDRIVE

aEstrut:= { "X1_GRUPO"  ,"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL"	,;
"X1_GSC"    ,"X1_VALID","X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2"	,;
"X1_DEFENG2","X1_CNT02","X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4"	,;
"X1_DEFENG4","X1_CNT04","X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3"     ,"X1_GRPSXG" ,"X1_PYME" ,"X1_GRPSXG" ,"X1_HELP","X1_PICTURE"}


aAdd(aSX1,{cPerg,"01",STR0005,"","","MV_CH1","C",99,0,0,"G","!Vazio().or.(Mv_Par01:=cGetFile('Arquivos |*.*','',,,,"+AllTrim(Str(nOpcGetFil))+"))","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S"})
aAdd(aSX1,{cPerg,"02",STR0015,"","","MV_CH2","C",4,0,0,"G","FS_VALIDSBM()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SBM","","S"})

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
			IncProc(STR0009)
		EndIf
	EndIf
Next i

return

