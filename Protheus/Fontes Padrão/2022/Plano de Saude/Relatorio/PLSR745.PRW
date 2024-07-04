#include "PROTHEUS.CH"

Static lAutoSt := .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSR745    ºAutor  ³Paulo Carnelossi   º Data ³  06/08/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime relacao de usuarios ativos em determinado mes sepa- º±±
±±º          ³rado por operadora e pessoa fisica ou juridica              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSR745(lauto)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local wnrel
Local cDesc1 := "Este programa tem como objetivo imprimir a relacao de Motivos "
Local cDesc2 := "de Cancelamento dos Contratos em determinado mes."
Local cDesc3 := ""
Local cString := "BA1"
Local Tamanho := "G"

Default lauto := .F.

PRIVATE cTitulo:= "Relatorio de Motivo de Cancelamento dos Contratos Mes a Mes"
PRIVATE cabec1
PRIVATE cabec2
Private aReturn := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
Private cPerg   := "PLR741"
Private nomeprog:= "PLSR745" 
Private nLastKey:=0

lAutoSt := lauto

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao dos cabecalhos                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cabec1:= ""
cabec2:= ""
//        123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//                 1         2         3         4         5         6         7         8         9        10        11        12        13        14        15
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := "PLR745"

Pergunte(cPerg,.F.)
if !lauto
	wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho,,.F.)
endif

If !lauto .AND. nLastKey == 27
   Return
End

if !lauto
	SetDefault(aReturn,cString)
endif

If !lauto .AND. nLastKey == 27
   Return ( NIL )
End

if !lauto
	RptStatus({|lEnd| PLSR745Imp(@lEnd,wnRel,cString)},cTitulo)
else
	PLSR745Imp(.F.,wnRel,cString)
endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³PLSR745Imp³ Autor ³ Paulo Carnelossi      ³ Data ³ 06/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³Impressao relacao de Cancelamento de Contratos					³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³PLSR745Imp(lEnd,wnRel,cString)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSR745Imp(lEnd,wnRel,cString)
Local cbcont,cbtxt
Local nCtd
Local tamanho:= "G"
Local nTipo
Local cCabec1, cCabec2, cAuxCabec2, nPos, nPosTot, nCol, nTotal

LOCAL cSQL, cSQL2
Local cArqTrab  := CriaTrab(nil,.F.)
Local cArqTrab2 := CriaTrab(nil,.F.)

Local cCodOpe  := mv_par01
Local cBloqueio
Local lTitulo, cCodEmp, cCodPro, cDatExc
Local aMeses   := { 'Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'}                
Local nQtdMes, nAuxQtdMes, dDatIni, dDatFim

Local aStruct  := { {"ANOMES", "C", 6, 0}, {"BA3_TIPOUS", "C", 1, 0}, {"TRB_NIVBLQ", "C", 01, 0}, {"TRB_MOTBLO", "C", 03, 0},{"TOTUSU", "N", 10, 0} }
Local oTempTRB

//--< Criação do objeto FWTemporaryTable >---
oTempTRB := FWTemporaryTable():New( "TRB" )
oTempTRB:SetFields( aStruct )
oTempTRB:AddIndex( "INDTRB",{ "BA3_TIPOUS","TRB_NIVBLQ","TRB_MOTBLO","ANOMES" } )
	
if( select( "TRB" ) > 0 )
	TRB->( dbCloseArea() )
endIf
	
oTempTRB:Create()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

cTitulo :=	"Relacao de Motivos de Cancelamento de Contrato "
cTitulo +=  "   ===> Operadora : "+cCodOpe+" - "+ Padr(Posicione("BA0",1,xFilial("BA0")+cCodOpe,"BA0_NOMINT"),45)

nTipo:=GetMv("MV_COMP")

cMesIni := mv_par04
cMesFim := mv_par05

nQtdMes := QtdMes(cMesIni, cMesFim)

If !lAutoSt .AND. nQtdMes > 6
	MsgStop("Colocar periodo menor ou igual a 06 meses!")
	dbSelectArea("TRB")
	dbclosearea()
	Return
else
	nQtdMes := 2
EndIf


cCabec1 := PadR("Motivos de Cancelamento", 30)
cAuxCabec2 := ""

FOR nCtd := 1 TO nQtdMes
 
   cCabec1 += " +"+PadC(aMeses[Val(Left(cMesIni,2))]+"/"+Right(cMesIni,2),13,"-")+"+" 
   cAuxCabec2 += PadC("Usuarios",16)
   
   dDatIni		:= CTOD("01/"+Left(cMesIni,2)+"/"+Right(cMesIni,2))
   
	If Val(Left(cMesIni,2)) + 1 > 12
		cAno    := StrZero(Val(Right(cMesIni,4))+1,4)
		nMesIni := 1
	Else
		cAno    := StrZero(Val(Right(cMesIni,4)),4)
		nMesIni := Val(Left(cMesIni,2)) + 1
	EndIf
	
	cMesIni := StrZero(nMesIni,2)+cAno
	
	dDatFim := CTOD( "01/"+StrZero(nMesIni,2)+"/"+Right(cAno,2) )
	
	cSQL := "SELECT BA3.BA3_TIPOUS, BA1.BA1_CONSID, BA1.BA1_MOTBLO, "
	cSQL += "COUNT( DISTINCT (BA1.BA1_MATVID) ) TOTUSU FROM "
	cSQL += RetSQLName("BA1")+" BA1, "+RetSQLName("BA3")+" BA3, "
	cSQL += RetSQLName("BCA")+" BCA "
	//--relacionar usuario com familia
	cSQL += "WHERE "
	cSQL += "BA1.BA1_FILIAL = BA3.BA3_FILIAL AND "
	cSQL += "BA1.BA1_CODINT  = BA3.BA3_CODINT AND "
	cSQL += "BA1.BA1_CODEMP = BA3.BA3_CODEMP AND "
	cSQL += "BA1.BA1_MATRIC = BA3.BA3_MATRIC AND "
	//--relacionar usuario com historico bloqueio de usuario
	cSQL += "BA1.BA1_FILIAL = BCA.BCA_FILIAL AND "
	cSQL += "BA1.BA1_CODINT+BA1.BA1_CODEMP+BA1_MATRIC  = BCA.BCA_MATRIC AND "
	cSQL += "BCA.BCA_TIPO = '0' AND "      //0=Bloqueado
	//--considerar somente registros validos
	cSQL += "BA1.D_E_L_E_T_ <> '*' AND BA3.D_E_L_E_T_ <> '*'  AND BCA.D_E_L_E_T_ <> '*'  AND"
	//--condicao principal 
	cSQL += "	BA1.BA1_FILIAL = '"+xFilial("BA1")+"' AND "
	cSQL += "	BA3.BA3_FILIAL = '"+xFilial("BA3")+"' AND "
	cSQL += "	BCA.BCA_FILIAL = '"+xFilial("BCA")+"' AND "
	cSQL += "	BA1.BA1_CODINT = '"+MV_PAR01+"' AND "
	//--faixa de produtos
	cSQL += "	BA3.BA3_CODPLA >='"+MV_PAR02+"' AND BA3.BA3_CODPLA <='"+MV_PAR03+"'"
	
	cSQL += "	AND "
	
	cSQL += "	BA1.BA1_DATBLO >='"+DTOS(dDatIni)+"' AND BA1.BA1_DATBLO <='"+DTOS(dDatFim)+"'"
	
	If mv_par06 == 1
	   cSQL += " AND BA3_TIPOUS = '1' "
	ElseIf mv_par06 == 2
		cSQL += " AND BA3_TIPOUS = '2' "
	EndIf
	
	cSQL += " GROUP BY BA3.BA3_TIPOUS, BA1.BA1_CONSID, BA1.BA1_MOTBLO"
	cSQL += " ORDER BY BA3.BA3_TIPOUS, BA1.BA1_CONSID, BA1.BA1_MOTBLO"
	
	PLSQuery(cSQL,cArqTrab)

	(cArqTrab)->(DbGoTop())

	dbSelectArea(cArqTrab)
	if !lAutoSt
		SetRegua(RecCount())
	endif

		While (cArqTrab)->(! Eof())
		
			if !lAutoSt
				IncRegua()
			endif
			TRB->(dbAppend())
	
			TRB->ANOMES 		:= Left(DTOS(dDatIni),6)
			TRB->BA3_TIPOUS 	:= (cArqTrab)->BA3_TIPOUS
			TRB->TRB_NIVBLQ 	:= (cArqTrab)->BA1_CONSID
		    TRB->TRB_MOTBLO		:= (cArqTrab)->BA1_MOTBLO
	    	TRB->TOTUSU 		:= (cArqTrab)->TOTUSU
			
			(cArqTrab)->(DbSkip())
	
		End		
		(cArqTrab)->(dbCloseArea())

Next
cCabec1 += " +"+PadC("Total",13,"-")+"+" 
cAuxCabec2 += PadC("Usuarios",16)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata se nao existir registros...                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTotGer := {}
dbSelectArea("TRB")

if !lAutoSt
	SetRegua(RecCount())
endif

TRB->(dbGotop())

If TRB->(Eof())
	if !lAutoSt
		Alert("Não existem usuários bloqueados no período informado")     
		MS_FLUSH()
	endif
	dbSelectArea("TRB")
	
	if( select( "TRB" ) > 0 )
		oTempTRB:delete()
	endIf

	Return
Else	
	While TRB->( ! Eof())		
	
		if !lAutoSt
			IncRegua()
		endif

		If TRB->BA3_TIPOUS == "1"
			cCabec2:= PadR("==>PESSOA FISICA<==",30)+cAuxCabec2
	
		ElseIf TRB->BA3_TIPOUS == "2"
			cCabec2:= PadR("==>PESSOA JURIDICA<==",30)+cAuxCabec2
	
		ElseIf Empty(TRB->BA3_TIPOUS)
			cCabec2:= PadR("==>* *<==",30)+cAuxCabec2
			
	   EndIf
	
	   cTipo := TRB->BA3_TIPOUS
	   aSubTot := {}
	   
	   If !lAutoSt .ANd. li > 58
			cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			lTitulo := .T.
		EndIf
		
		@ li,000 PSAY cCabec1
		li++
		@ li,000 PSAY cCabec2
		li++
		@ li,000 PSAY Repl("-",220)
		li ++
	   	
	   While TRB->(! Eof() .And. BA3_TIPOUS == cTipo)
	   
	   	cBloqueio := TRB->(TRB_NIVBLQ+TRB_MOTBLO)
	   	nTotal := 0
	   	lTitulo := .T.
	   	
		   If li > 58
				if !lAutoSt
					cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
				endif
				lTitulo := .T.
				
				@ li,000 PSAY cCabec1
				li++
				@ li,000 PSAY cCabec2
				li++
				@ li,000 PSAY Repl("-",220)
				li ++
				
			EndIf
	   	
	   	While TRB->(! Eof() .And. BA3_TIPOUS+TRB_NIVBLQ+TRB_MOTBLO == cTipo+cBloqueio)
		   
				If lTitulo
					@ li,00 PSay Padr(A660DescBloq("TRB") , 30)
					lTitulo := .F.		
				EndIf
	
	         nAuxQtdMes := QtdMes(mv_par04,  Right(TRB->ANOMES,2)+"/"+Left(TRB->ANOMES,4) )
	         nCol := 32+((nAuxQtdMes-1)*16)
	         					
				@ li,nCol 		PSay Str(TRB->TOTUSU,10)
				
			   nTotal += TRB->TOTUSU
				
				//incrementa sub-total
				nPos := ASCAN(aSubTot, {|aVal| aVal[1] == TRB->ANOMES})
				
				If nPos == 0
					aAdd(aSubTot, { TRB->ANOMES, 0})
					aSubTot[Len(aSubTot)][2] += TRB->TOTUSU
	         Else
		         aSubTot[nPos][2] += TRB->TOTUSU
			   EndIf
			   
				TRB->(DbSkip())      
		   
		   End
		   nCol := 32+(nQtdMes*16)
		   @ li,nCol Psay Str(nTotal,10)
		   li++
		   
	   End
	   
	   @ li,00 PSAY Repl("-",220)
	   li++
	   
		@ li,00 PSay " **SUB TOTAL**"
		
		cMesIni := mv_par04
	   nTotal  := 0
	   
	   For nCtd := 1 TO nQtdMes
	   
	   	If Val(Left(cMesIni,2)) + 1 > 12
				cAno    := StrZero(Val(Right(cMesIni,4))+1,4)
				nMesIni := 1
			Else
				cAno    := StrZero(Val(Right(cMesIni,4)),4)
				nMesIni := Val(Left(cMesIni,2)) + 1
			EndIf
			
			cMesIni := StrZero(nMesIni,2)+cAno
		
			dDatFim := CTOD( "01/"+StrZero(nMesIni,2)+"/"+Right(cAno,2) )
			
			nPos := ASCAN(aSubTot, {|aVal| aVal[1] == Left(DTOS(dDatFim-1),6)})
	
			If nPos > 0
	
				nAuxQtdMes := QtdMes(mv_par04, Right(aSubTot[nPos][1],2)+"/"+Left(aSubTot[nPos][1],4))
		      nCol := 32+(nAuxQtdMes-1)*16
		         					
				@ li,nCol 		PSay Str(aSubTot[nPos][2],10)
				nTotal += aSubTot[nPos][2]
	
				//incrementa array do Total Geral
				nPosTot := ASCAN(aTotGer, {|aVal| aVal[1] == aSubTot[nPos][1]})
				
				If nPosTot == 0
					aAdd(aTotGer, { aSubTot[nPos][1], 0, 0})
					aTotGer[Len(aTotGer)][2] += aSubTot[nPos][2]
	         Else
		         aTotGer[nPosTot][2] += aSubTot[nPos][2]
			   EndIf
	
			EndIf
			
	   Next
	   nCol := 32+(nQtdMes*16)
		@ li, nCol Psay Str(nTotal,10)
		li++
	   
	   @ li,00 PSAY Repl("-",220)
	   li += 2
	
	End
	
	@ li,00 PSay " **TOTAL GERAL**"
	cMesIni 	:= mv_par04
	nTotal 	:= 0
	
	For nCtd := 1 TO nQtdMes
	   
	   If Val(Left(cMesIni,2)) + 1 > 12
			cAno    := StrZero(Val(Right(cMesIni,4))+1,4)
			nMesIni := 1
		Else
			cAno    := StrZero(Val(Right(cMesIni,4)),4)
			nMesIni := Val(Left(cMesIni,2)) + 1
		EndIf
		
		cMesIni := StrZero(nMesIni,2)+cAno
	
		dDatFim := CTOD( "01/"+StrZero(nMesIni,2)+"/"+Right(cAno,2) )
		
		nPos := ASCAN(aTotGer, 	{ |aVal| aVal[1] == Left(DTOS(dDatFim-1),6) } )
	
		If nPos > 0
	
			nAuxQtdMes := QtdMes(mv_par04, Right(aTotGer[nPos][1],2)+"/"+Left( aTotGer[nPos][1],4))
	      nCol := 32+(nAuxQtdMes-1)*16
	         					
			@ li,nCol 		PSay Str(aTotGer[nPos][2],10)
	      nTotal += aTotGer[nPos][2]
	      
	   EndIf
	      
	Next
	nCol := 32+(nQtdMes*16)
	@ li, nCol Psay Str(nTotal,10)
	li++ 
	
	@ li,00 PSAY Repl("=",220)
	li ++
	@ li,00 PSay PadL("MEDIA DE EXCLUSOES EFETIVAS NO PERIODO  ------> "+Str(Int(nTotal/nQtdMes),10),220)
	li ++
	@ li,00 PSAY Repl("=",220)
	li ++
		
	IF !lAutoSt .AND. li != 80
		roda(cbcont,cbtxt,tamanho)
	End

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Integridade dos dados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if( select( "TRB" ) > 0 )
	oTempTRB:delete()
endIf

dbSelectArea("BA1")

if !lAutoSt
	Set Device To Screen
endif

If !lAutoSt .AND. aReturn[5] = 1
   Set Printer To
	dbCommitAll()
   OurSpool(wnrel)
Endif

if !lAutoSt
	MS_FLUSH() 
endif

Return
