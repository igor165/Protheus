#INCLUDE "PROTHEUS.CH"
Static objCENFUNLGP := CENFUNLGP():New() 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSR741    บAutor  ณPaulo Carnelossi   บ Data ณ  29/07/03   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime relacao de usuarios ativos em determinado mes sepa- บฑฑ
ฑฑบ          ณrado por operadora e pessoa fisica ou juridica              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSR741()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local wnrel
Local cDesc1 := "Este programa tem como objetivo imprimir a relacao sintetica de "
Local cDesc2 := "usuarios ativos em determinado mes."
Local cDesc3 := ""
Local cString := "BA1"
Local Tamanho := "G"

PRIVATE cTitulo:= "Relatorio de Numero de Usuarios por Produto"
PRIVATE cabec1
PRIVATE cabec2
Private aReturn := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
Private cPerg   := "PLR741"
Private nomeprog:= "PLSR741" 
Private nLastKey:=0

//-- LGPD ----------
if !objCENFUNLGP:getPermPessoais()
	objCENFUNLGP:msgNoPermissions()
	Return
Endif
//------------------

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao dos cabecalhos                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cabec1:= ""
cabec2:= ""
//        123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//                 1         2         3         4         5         6         7         8         9        10        11        12        13        14        15
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Envia controle para a funcao SETPRINT                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
wnrel := "PLR741"

Pergunte(cPerg,.F.)

wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho,,.F.)

If nLastKey == 27
   Return
End

SetDefault(aReturn,cString)

If nLastKey == 27
   Return ( NIL )
End

RptStatus({|lEnd| PLSR741Imp(@lEnd,wnRel,cString)},cTitulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณ Fun…o    ณPLSR741Impณ Autor ณ Paulo Carnelossi      ณ Data ณ 07/07/03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Descri…o ณImpressao relacao de Movimentos dos Beneficiarios				ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Sintaxe   ณPLSR741Imp(lEnd,wnRel,cString)                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso       ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function PLSR741Imp(lEnd,wnRel,cString)
Local cbcont,cbtxt
Local nCtd
Local tamanho:= "G"
Local nTipo
Local cCabec1, cCabec2, cAuxCabec2, nPos, nPosTot, nCol

LOCAL cSQL, cSQL2
Local cArqTrab  := CriaTrab(nil,.F.)
Local cArqTrab2 := CriaTrab(nil,.F.)

Local cCodOpe  := mv_par01
Local cProd
Local lTitulo, cCodEmp, cCodPro, cDatExc
Local aMeses   := { 'Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'}                
Local aStruct  := { {"DATBAS", "D", 8, 0}, {"BA3_TIPOUS", "C", 1, 0}, {"BA3_CODPLA", "C", 04, 0}, {"TOTPLA", "N", 10, 0}, {"TOTEMP", "N", 10, 0} }
Local nQtdMes, nAuxQtdMes
Local oTempTRB

//--< Cria็ใo do objeto FWTemporaryTable >---
oTempTRB := FWTemporaryTable():New( "TOT" )
oTempTRB:SetFields( aStruct )
oTempTRB:AddIndex( "INDTRB",{ "BA3_TIPOUS","BA3_CODPLA","DATBAS" } )
	
if( select( "TOT" ) > 0 )
	TOT->( dbCloseArea() )
endIf
	
oTempTRB:Create()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

cTitulo :=	"Relacao de Numero de Usuarios por Produto "
cTitulo +=  "   ===> Operadora : "+cCodOpe+" - "+ Padr(Posicione("BA0",1,xFilial("BA0")+cCodOpe,"BA0_NOMINT"),45)

nTipo:=GetMv("MV_COMP")

cMesIni := mv_par04
cMesFim := mv_par05

nQtdMes := QtdMes(cMesIni, cMesFim)

If nQtdMes > 6
	MsgStop("Colocar periodo menor ou igual a 06 meses!")

	if( select( "TOT" ) > 0 )
		oTempTRB:delete()
	endIf

	Return
EndIf


cCabec1 := Space(20)
cAuxCabec2 := ""

FOR nCtd := 1 TO nQtdMes
 
   cCabec1 += " +"+PadC(aMeses[Val(Left(cMesIni,2))]+"/"+Right(cMesIni,2),18,"-")+"+" 
   cAuxCabec2 += Padl("Empr.    Usuar.",21)
   
	If Val(Left(cMesIni,2)) + 1 > 12
		cAno    := StrZero(Val(Right(cMesIni,4))+1,4)
		nMesIni := 1
	Else
		cAno    := StrZero(Val(Right(cMesIni,4)),4)
		nMesIni := Val(Left(cMesIni,2)) + 1
	EndIf
	
	cMesIni := StrZero(nMesIni,2)+cAno
	
	dDatBas := CTOD( "01/"+StrZero(nMesIni,2)+"/"+Right(cAno,2) )
	
	cSQL := "SELECT BA3.BA3_TIPOUS, BA3.BA3_CODPLA, COUNT(BA3_CODPLA) AS TOTPLA, "
	cSQL += "COUNT(DISTINCT BA1.BA1_CODEMP) AS TOTEMP, "+DTOS(dDatBas)+" AS DATBAS FROM "
	cSQL += RetSQLName("BA1")+" BA1, "+RetSQLName("BA3")+" BA3 "
	//--relacionar usuario com familia
	cSQL += "WHERE "
	cSQL += "BA1.BA1_FILIAL = BA3.BA3_FILIAL AND "
	cSQL += "BA1.BA1_CODINT  = BA3.BA3_CODINT AND "
	cSQL += "BA1.BA1_CODEMP = BA3.BA3_CODEMP AND "
	cSQL += "BA1.BA1_MATRIC = BA3.BA3_MATRIC AND "
	//--considerar somente registros validos
	cSQL += "BA1.D_E_L_E_T_ <> '*' AND BA3.D_E_L_E_T_ <> '*'  AND "
	//--condicao principal 
	cSQL += "	BA1.BA1_FILIAL = '"+xFilial("BA1")+"' AND "
	cSQL += "	BA3.BA3_FILIAL = '"+xFilial("BA3")+"' AND "
	cSQL += "	BA1.BA1_CODINT = '"+MV_PAR01+"' AND "
	//--faixa de produtos
	cSQL += "	BA3.BA3_CODPLA >='"+MV_PAR02+"' AND BA3.BA3_CODPLA <='"+MV_PAR03+"'"
	
	cSQL += "	AND "
	
	cSQL += "	BA1.BA1_DATINC <'"+DTOS(dDatBas)+"' AND "
	cSQL += "	(BA1.BA1_DATBLO = '   ' OR BA1.BA1_DATBLO >='"+DTOS(dDatBas)+"') AND"
	cSQL += "	(BA1.BA1_DATTRA = '   ' OR BA1.BA1_DATTRA >='"+DTOS(dDatBas)+"')"
	
	If mv_par06 == 1
	   cSQL += " AND BA3_TIPOUS = '1' "
	ElseIf mv_par06 == 2
		cSQL += " AND BA3_TIPOUS = '2' "
	EndIf
	
	cSQL += " GROUP BY BA3.BA3_TIPOUS, BA3.BA3_CODPLA"
	cSQL += " ORDER BY BA3.BA3_TIPOUS, BA3.BA3_CODPLA"
	
	PLSQuery(cSQL,cArqTrab)

	(cArqTrab)->(DbGoTop())

	dbSelectArea(cArqTrab)
	SetRegua(RecCount())

	While (cArqTrab)->(! Eof())
	
		IncRegua()
		
		TOT->(dbAppend())

		TOT->DATBAS 		:= CTOD(SUBS(Str((cArqTrab)->DATBAS, 8),7,2)+"/"+SUBS(Str((cArqTrab)->DATBAS, 8),5,2)+"/"+SUBS(Str((cArqTrab)->DATBAS, 8),3,2))
		TOT->BA3_TIPOUS 	:= (cArqTrab)->BA3_TIPOUS
		TOT->BA3_CODPLA 	:= (cArqTrab)->BA3_CODPLA
      TOT->TOTPLA 		:= (cArqTrab)->TOTPLA
      TOT->TOTEMP 		:= (cArqTrab)->TOTEMP
		
		(cArqTrab)->(DbSkip())

	End
	
	(cArqTrab)->(dbCloseArea())

Next

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Trata se nao existir registros...                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aTotGer := {}
dbSelectArea("TOT")

SetRegua(RecCount())

TOT->(dbGotop())

While TOT->( ! Eof())		

	IncRegua()

	If TOT->BA3_TIPOUS == "1"
		cCabec2:= "PESSOA FISICA       "+cAuxCabec2

	ElseIf TOT->BA3_TIPOUS == "2"
		cCabec2:= "PESSOA JURIDICA     "+cAuxCabec2

	ElseIf Empty(TOT->BA3_TIPOUS)
		cCabec2:= "                    "+cAuxCabec2
		
   EndIf

   cTipo := TOT->BA3_TIPOUS
   aSubTot := {}
   
   If li > 58
		cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		lTitulo := .T.
	EndIf
	
	@ li,000 PSAY cCabec1
	li++
	@ li,000 PSAY cCabec2
	li++
	@ li,000 PSAY Repl("-",220)
	li += 2
   	
   While TOT->(! Eof() .And. BA3_TIPOUS == cTipo)
   
   	cProd := TOT->BA3_CODPLA
   	lTitulo := .T.
   	
	   If li > 58
			cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			lTitulo := .T.
			
			@ li,000 PSAY cCabec1
			li++
			@ li,000 PSAY cCabec2
			li++
			@ li,000 PSAY Repl("-",220)
			li += 2
			
		EndIf
   	
   	While TOT->(! Eof() .And. BA3_TIPOUS+BA3_CODPLA == cTipo+cProd)
	   
			If lTitulo
				@ li,00 PSay Padr( Posicione("BI3",1,xFilial("BI3")+mv_par01+TOT->BA3_CODPLA,"BI3_NREDUZ"), 20)
				lTitulo := .F.		
			EndIf

         nAuxQtdMes := QtdMes(mv_par04, StrZero(Month( TOT->DATBAS-1 ),2)+"/"+StrZero(Year( TOT->DATBAS-1 ),4))
         nCol := nAuxQtdMes*21 
         					
			@ li,nCol 		PSay Str(TOT->TOTEMP,10)
			@ li,nCol+10 	PSay Str(TOT->TOTPLA,10)
			
			//incrementa sub-total
			nPos := ASCAN(aSubTot, {|aVal| aVal[1] == TOT->DATBAS})
			
			If nPos == 0
				aAdd(aSubTot, { TOT->DATBAS, 0, 0})
				aSubTot[Len(aSubTot)][2] += TOT->TOTEMP
				aSubTot[Len(aSubTot)][3] += TOT->TOTPLA
         Else
	         aSubTot[nPos][2] += TOT->TOTEMP
				aSubTot[nPos][3] += TOT->TOTPLA
		   EndIf
		   
			TOT->(DbSkip())      
	   
	   End
	   
	   li++
	   
   End
   
   @ li,00 PSAY Repl("-",220)
   li++
	@ li,00 PSay " **SUB TOTAL**"
	
	cMesIni := mv_par04
   
   For nCtd := 1 TO nQtdMes
   
   	If Val(Left(cMesIni,2)) + 1 > 12
			cAno    := StrZero(Val(Right(cMesIni,4))+1,4)
			nMesIni := 1
		Else
			cAno    := StrZero(Val(Right(cMesIni,4)),4)
			nMesIni := Val(Left(cMesIni,2)) + 1
		EndIf
		
		cMesIni := StrZero(nMesIni,2)+cAno
	
		dDatBas := CTOD( "01/"+StrZero(nMesIni,2)+"/"+Right(cAno,2) )
		
		nPos := ASCAN(aSubTot, {|aVal| aVal[1] == dDatBas})

		If nPos > 0

			nAuxQtdMes := QtdMes(mv_par04, StrZero(Month( aSubTot[nPos][1]-1 ),2)+"/"+StrZero(Year( aSubTot[nPos][1]-1 ),4))
	      nCol := nAuxQtdMes*21 
	         					
			@ li,nCol 		PSay Str(aSubTot[nPos][2],10)
			@ li,nCol+10 	PSay Str(aSubTot[nPos][3],10)

			//incrementa array do Total Geral
			nPosTot := ASCAN(aTotGer, {|aVal| aVal[1] == aSubTot[nPos][1]})
			
			If nPosTot == 0
				aAdd(aTotGer, { aSubTot[nPos][1], 0, 0})
				aTotGer[Len(aTotGer)][2] += aSubTot[nPos][2]
				aTotGer[Len(aTotGer)][3] += aSubTot[nPos][3]
         Else
	         aTotGer[nPosTot][2] += aSubTot[nPos][2]
				aTotGer[nPosTot][3] += aSubTot[nPos][3]
		   EndIf

		EndIf
		
   Next
   li++
   
   @ li,00 PSAY Repl("-",220)
   li += 2

End

@ li,00 PSay " **TOTAL GERAL**"
cMesIni := mv_par04
   
For nCtd := 1 TO nQtdMes
   
   If Val(Left(cMesIni,2)) + 1 > 12
		cAno    := StrZero(Val(Right(cMesIni,4))+1,4)
		nMesIni := 1
	Else
		cAno    := StrZero(Val(Right(cMesIni,4)),4)
		nMesIni := Val(Left(cMesIni,2)) + 1
	EndIf
	
	cMesIni := StrZero(nMesIni,2)+cAno

	dDatBas := CTOD( "01/"+StrZero(nMesIni,2)+"/"+Right(cAno,2) )
	
	nPos := ASCAN(aTotGer, {|aVal| aVal[1] == dDatBas})

	If nPos > 0

		nAuxQtdMes := QtdMes(mv_par04, StrZero(Month( aTotGer[nPos][1]-1 ),2)+"/"+StrZero(Year( aTotGer[nPos][1]-1 ),4))
      nCol := nAuxQtdMes*21 
         					
		@ li,nCol 		PSay Str(aTotGer[nPos][2],10)
		@ li,nCol+10 	PSay Str(aTotGer[nPos][3],10)

   EndIf
      
Next      
li++
	   
@ li,00 PSAY Repl("=",220)
li ++
	
IF li != 80
	roda(cbcont,cbtxt,tamanho)
End

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Recupera a Integridade dos dados                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
if( select( "TOT" ) > 0 )
	oTempTRB:delete()
endIf

dbSelectArea("BA1")

Set Device To Screen

If aReturn[5] = 1
   Set Printer To
	dbCommitAll()
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQtdMes    บAutor  ณPaulo Carnelossi    บ Data ณ  29/07/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a quantidade de meses entre mes inicial e final     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function QtdMes(cMesIni, cMesFim)
Local nMesIni := Val(Left(cMesIni,2))
Local nMesFim := Val(Left(cMesFim,2))
Local nAnoIni := Val(Right(cMesIni,4))
Local nAnoFim := Val(Right(cMesFim,4))
Return( ((nAnoFim-nAnoIni)*12) + (nMesFim-nMesIni) + 1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณPLSR741YM บAutor ณJos้ Guilherme Romano บ Data ณ 14/07/2021 บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao Pergunte Mes/Ano Inicial e Final                  บฑฑ
ฑฑบ          ณPLR741                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PLSR741YM(cMesAno)
Local lRet := .F.

If cMesAno == "99/9999"
	lRet := .T.
ElseIf cMesAno == Space(7)
	lRet := .T.	
ElseIf Subs(cMesAno, 3, 1) == "/" .And. Len(Trim(cMesAno)) == 7 .And. ;
		Val(Subs(cMesAno,1,2)) >= 01 .And. Val(Subs(cMesAno,1,2)) <= 12 .And. ;
		Val(Subs(cMesAno, 4)) <= 9999 .And. Len(Trim(Subs(cMesAno, 4))) == 4
	lRet := .T.
EndIf


Return(lret)

