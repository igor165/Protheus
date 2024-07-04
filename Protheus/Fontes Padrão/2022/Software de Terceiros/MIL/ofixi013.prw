// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 5      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFIXI013.CH"
  
/*
================================================================================
################################################################################
##+----------+------------+-------+-----------------------+------+-----------+##
##|Função    | OFIXI013   | Autor | Thiago                | Data | 02/01/13  |##
##+----------+------------+-------+-----------------------+------+-----------+##
##|Descrição | Importar as informações de FATURAMENTO DE PECAS.				 |##
##+----------+---------------------------------------------------------------+##
##|Uso       |                                                               |##
##+----------+---------------------------------------------------------------+##
################################################################################
================================================================================
*/
Function OFIXI013()
//
Local cDesc1  := STR0001
Local cDesc2  := STR0002

Local cDesc3  := ""
Local aSay := {}
Local aButton := {}

Private cTitulo := "" // TODO - Titulo do Assunto (Vai no relatório e FormBatch)
Private cPerg := "OXI013" 	// TODO -Pergunte
Private lErro := .f.  	    // Se houve erro, não move arquivo gerado
Private cArquivo			// Nome do Arquivo a ser importado
Private aLinhasRel := {}	// Linhas que serão apresentadas no relatorio

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
RptStatus( {|lEnd| ImportArq(@lEnd)},"",STR0012)

//
return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | ImportArq  | Autor | Thiago                | Data | 11/12/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Importar arquivo.									        |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function ImportArq()
//
Local i := 0     
        
if Empty(mv_par01)
   MsgInfo(STR0009)
   Return(.f.)
Endif   
// FP9 - FATURAMENTO DE PEÇAS   
cGrpIte := "VW  "  
lAchou := .f.
If File(mv_par01)

		if (nHandle:= FT_FUse( mv_par01 )) == -1
			Return
		EndIf
		
		FT_FGotop()
		While ! FT_FEof()
			
			cStr := FT_FReadLN()
			dbSelectArea("VE4")
			dbSetOrder(2)
			dbSeek(xFilial("VE4")+substr(cStr,168,14))
			If substr(cStr,1,3) == "FP9"
			   dbSelectArea("VI0")
			   dbSetOrder(1)
			   if !dbSeek(xFilial("VI0")+mv_par02+substr(cStr,26,2)+" "+substr(cStr,28,6))
	               RecLock("VI0",.T.) 
    	           VI0->VI0_FILIAL := xFilial("VI0")
        	       VI0->VI0_CODMAR := mv_par02
        	       VI0->VI0_PEDFAB := val(substr(cStr,4,7))
            	   VI0->VI0_TIPPED := val(substr(cStr,11,2))
	               VI0->VI0_PEDCON := substr(cStr,13,13)
    	           VI0->VI0_SERNFI := substr(cStr,26,2)
        	       VI0->VI0_NUMNFI := substr(cStr,28,6) 
        	       dDt := substr(cStr,34,8)
        	       cDia := substr(dDt,1,2)
        	       cMes := substr(dDt,3,2)
        	       cAno := substr(dDt,5,4) 
        	       dData := cDia+"/"+cMes+"/"+cAno
            	   VI0->VI0_DTAFAT := ctod(dData)
        	       dDt := substr(cStr,42,8)
        	       cDia := substr(dDt,1,2)
        	       cMes := substr(dDt,3,2)
        	       cAno := substr(dDt,5,4) 
        	       dData := cDia+"/"+cMes+"/"+cAno
	               VI0->VI0_DTAVCT := ctod(dData)
				   VI0->VI0_CODFOR := substr(cStr,162,6)
        	       MsUnlock()				
               Endif
               RecLock("VIA",.T.)                
   	           VIA->VIA_FILIAL := xFilial("VIA")
			   VIA->VIA_SERNFI := VI0->VI0_SERNFI
       	       VIA->VIA_CODMAR := mv_par02
			   VIA->VIA_NUMNFI := VI0->VI0_NUMNFI  
			   cCodIteP := ""
			   cCodIte  := substr(cStr,50,20)
			   For i := 1 to Len(cCodIte)
				   nPos := AT("/",cCodIte)
				   if nPos > 0
				      nPos -= 1
				   Else
					  nPos := Len(cCodIte)
				   Endif     
				   cCodIteP := cCodIteP+alltrim(Substr(cCodIte,1,nPos))
				   cCodIte := alltrim(substr(cCodIte,nPos+2,Len(cCodIte)))
			   Next   
			   VIA->VIA_CODITE := cCodIteP
			   VIA->VIA_DESITE := substr(cStr,70,13)
       	       VIA->VIA_PEDCON := substr(cStr,13,13)
       		   VIA->VIA_TIPPED := val(substr(cStr,11,2))
	   	       dDt := substr(cStr,42,8)
       	       cDia := substr(dDt,1,2)
    	       cMes := substr(dDt,3,2)
        	   cAno := substr(dDt,5,4) 
	           dData := cDia+"/"+cMes+"/"+cAno
    	       VIA->VIA_DTAVCT := ctod(dData)
	    	   VIA->VIA_PEDFAB := val(substr(cStr,4,7))
			   VIA->VIA_TXAIPI := val(substr(cStr,93,4))/100
    	   	   dDt := substr(cStr,34,8)
       		   cDia := substr(dDt,1,2)
       	       cMes := substr(dDt,3,2)
      	       cAno := substr(dDt,5,4) 
   	   	       dData := cDia+"/"+cMes+"/"+cAno
       	   	   VIA->VIA_DTAFAT := ctod(dData)
			   VIA->VIA_CLAFIS := substr(cStr,83,10)
			   VIA->VIA_VALIPI := val(substr(cStr,97,11))/100
			   VIA->VIA_VALICM := val(substr(cStr,108,11))/100
			   VIA->VIA_VALITE := (val(substr(cStr,119,11))/100)-val(substr(cStr,97,11))/100 //Esta sendo removido o valor do ipi.
			   VIA->VIA_QTDFAT := val(substr(cStr,130,7))
			   VIA->VIA_PESPEC := (val(substr(cStr,137,7))/100)/10
			   VIA->VIA_NROCXA := val(substr(cStr,144,10))
			   VIA->VIA_SISTRI := substr(cStr,154,3)
			   VIA->VIA_PERDES := val(substr(cStr,157,5))/100
			   VIA->VIA_CODFOR := substr(cStr,162,6)
			   VIA->VIA_CGCFOR := substr(cStr,168,14)
			   lAchou := .t.
           	   MsUnlock() 
			EndIf
			dbSelectArea("VIA")
			dbSetOrder(1)
			if dbSeek(xFilial("VIA")+VI0->VI0_CODMAR+VI0->VI0_SERNFI+VI0->VI0_NUMNFI)
		       nValIpI  := 0
		       nValIcm  := 0
		       nValTot  := 0
		       nValMerc := 0
			   While !Eof() .and. xFilial("VIA") == VIA->VIA_FILIAL .and. VI0->VI0_CODMAR+VI0->VI0_SERNFI+VI0->VI0_NUMNFI == VIA->VIA_CODMAR+VIA->VIA_SERNFI+VIA->VIA_NUMNFI 
			      nValIpI  += VIA->VIA_VALIPI
			      nValIcm  += VIA->VIA_VALICM
			      nValTot  += VIA->VIA_VALITE+VIA->VIA_VALIPI
			      nValMerc += VIA->VIA_VALITE
			      dbSelectArea("VIA")
			      dbSkip()
			   Enddo   
               RecLock("VI0",.f.)
               VI0->VI0_VLTIPI := nValIpI
               VI0->VI0_VLTICM := nValIcm
               VI0->VI0_VLTNFI := nValTot
               VI0->VI0_VLTMER := nValMerc
               MsUnlock()
			Endif   
			FT_FSkip()
		End
		FT_FUse()
		if lAchou
			MsgInfo(STR0008)
		Else
			MsgInfo(STR0011)
		Endif	
Else
	MsgInfo(STR0010)
Endif

return

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
Local nOpcGetFil := GETF_LOCALHARD + GETF_NETWORKDRIVE 

aEstrut:= { "X1_GRUPO"  ,"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL"	,;
"X1_GSC"    ,"X1_VALID","X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2"	,;
"X1_DEFENG2","X1_CNT02","X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4"	,;
"X1_DEFENG4","X1_CNT04","X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3"     ,"X1_GRPSXG" ,"X1_PYME"}


aAdd(aSX1,{cPerg,"01",STR0003,"","","MV_CH1","C",99,0,0,"G","!Vazio().or.(Mv_Par01:=cGetFile('Arquivos |*.*','',,,,"+AllTrim(Str(nOpcGetFil))+"))","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S"})
aAdd(aSX1,{cPerg,"02",STR0013,"","","MV_CH2","C",3,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","VE1",""	,"S"})

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
			IncProc(STR0006)
		EndIf
	EndIf
Next i

return
