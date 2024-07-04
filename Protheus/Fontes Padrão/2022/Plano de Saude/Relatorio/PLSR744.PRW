#INCLUDE "PROTHEUS.CH"
Static objCENFUNLGP := CENFUNLGP():New() 
Static lAutoSt := .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSR744    ºAutor  ³Paulo Carnelossi   º Data ³  01/08/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime relacao de usuarios ativos em determinado mes sepa- º±±
±±º          ³rado por operadora e pessoa fisica ou juridica              º±±
±±º          ³Tb por tipo de usuario e sexo					  			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSR744(lAuto)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local wnrel
Local cDesc1 := "Este programa tem como objetivo imprimir a relacao sintetica de "
Local cDesc2 := "usuarios ativos no mes separado por pessoa fisica / juridica    "
Local cDesc3 := ""
Local cString := "BA1"
Local Tamanho := "G"

Default lAuto := .F.

PRIVATE cTitulo:= "Relatorio de Usuarios por Produto/Tipo/Sexo"
PRIVATE cabec1
PRIVATE cabec2
Private aReturn := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
Private cPerg   := "PLR744"
Private nomeprog:= "PLSR744" 
Private nLastKey:=0

lAutoSt := lAuto

//-- LGPD ----------
if !objCENFUNLGP:getPermPessoais()
	objCENFUNLGP:msgNoPermissions()
	Return
Endif
//------------------

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao dos cabecalhos                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cabec1:= "                      +---------------T i t u l a r----------------+ +-------------D e p e n d e n t e-------------+ +---------------A g r e g a d o---------------+ +------------T  O  T  A  L------------+"
cabec2:= "Prod./Faixa Etaria     Masc.       %    Fem.       %   Total       %   Masc.       %    Fem.       %   Total       %   Masc.       %    Fem.       %   Total       %   Masc.       %    Fem.       %   Total"
//        12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789001234567890123456789012345678900123456789012345678901234567890
//                  1         2         3         4         5         6         7         8         9        10        11        12        13        14        15          16        17         18        19        20       21
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := "PLR744"

Pergunte(cPerg,.F.)

if !lAutoSt
	wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho,,.F.)
endif

If !lAutoSt .AND. nLastKey == 27
   Return
End

if !lAutoSt
	SetDefault(aReturn,cString)
endif

If !lAutoSt .AND. nLastKey == 27
   Return ( NIL )
End

if !lAutoSt
	RptStatus({|lEnd| PLSR744Imp(@lEnd,wnRel,cString)},cTitulo)
else
	PLSR744Imp(.F.,wnRel,cString)
endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³PLSR744Imp³ Autor ³ Paulo Carnelossi      ³ Data ³ 01/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³Impressao relacao Usuarios ativos no mes p/ Plano/Tipo/Sexo ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³PLSR744Imp(lEnd,wnRel,cString)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSR744Imp(lEnd,wnRel,cString)
Local cbcont,cbtxt
Local tamanho:= "G"
Local nTipo
Local nPos, nPosFai, nCol, nExclusao, nInclusao
Local aProd, nMasculino, nFeminino, nTotal, nCtd, nX, nY, aTipUsu
LOCAL cDbTipo  	:= AllTrim(TCGetDB())

LOCAL cSQL
Local cArqTrab  := CriaTrab(nil,.F.)

Local cCodOpe  := mv_par01
Local cProd
Local lTitulo, cCodEmp, cCodPro, cDatExc
Local aFaixa := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

nTipo:=GetMv("MV_COMP")

If mv_par06 == 1
	//carrega array aFaixa com as Faixas Etarias padrao ANS
	dbSelectArea("BL9")
	dbGotop()
	nFxAnt := 0
	aTipUsu := {"T1","T2","D1","D2","A1","A2","Z1","Z2"}
	
	While  ! Eof()
	
		For nY := 1 TO Len(aTipUsu)
			If 		Left(aTipUsu[nY],1)=="T"
						nTipUsu := 1 
			ElseIf 	Left(aTipUsu[nY],1)=="D"
						nTipUsu := 2 
			ElseIf 	Left(aTipUsu[nY],1)=="A"
						nTipUsu := 3 
			ElseIf 	Left(aTipUsu[nY],1)=="Z"
						nTipUsu := 4 
            EndIf
			nCol := 20 + ( (nTipUsu-1) * 48 ) 
			aAdd(aFaixa, { StrZero(BL9->BL9_IDADEF,3)+aTipUsu[nY] , Alltrim(Str(nFxAnt,3))+"-"+Alltrim(Str(BL9->BL9_IDADEF,3)) , 0 , nCol } )
		Next

		nFxAnt := BL9->BL9_IDADEF + 1
		
		BL9->(dbSkip())
		
	End
EndIf

cMesIni := mv_par04

dDatIni := CTOD("01/"+Left(cMesIni,2)+"/"+Right(cMesIni,2))
   
If Val(Left(cMesIni,2)) + 1 > 12
	cAno    := StrZero(Val(Right(cMesIni,4))+1,4)
	nMesIni := 1
Else
	cAno    := StrZero(Val(Right(cMesIni,4)),4)
	nMesIni := Val(Left(cMesIni,2)) + 1
EndIf

cMesIni := StrZero(nMesIni,2)+cAno

dDatFim := CTOD( "01/"+StrZero(nMesIni,2)+"/"+Right(cAno,2) ) 

cTitulo :=	"Relacao de Usuarios por Produto/Tp/Sexo/Fx.Etaria em "+DtoC(dDatFim - 1)
cTitulo +=  "   ===> Operadora : "+cCodOpe+" - "+ Padr(Posicione("BA0",1,xFilial("BA0")+cCodOpe,"BA0_NOMINT"),45)
	
cSQL := "SELECT BA3.BA3_TIPOUS, BA3.BA3_CODPLA, BA1.BA1_TIPUSU, BA1.BA1_SEXO, BL9.BL9_IDADEF, "
cSQL += "COUNT(BA3.BA3_MATRIC) AS TOTUSU FROM "
cSQL += RetSQLName("BA1")+" BA1, "+RetSQLName("BA3")+" BA3, "
cSQL += RetSQLName("BL9")+" BL9 "
//--relacionar usuario com familia
cSQL += "WHERE "
cSQL += "BA1.BA1_FILIAL = BA3.BA3_FILIAL AND "
cSQL += "BA1.BA1_CODINT  = BA3.BA3_CODINT AND "
cSQL += "BA1.BA1_CODEMP = BA3.BA3_CODEMP AND "
cSQL += "BA1.BA1_MATRIC = BA3.BA3_MATRIC AND "
//--considerar somente registros validos
cSQL += "BA1.D_E_L_E_T_ <> '*' AND BA3.D_E_L_E_T_ <> '*'  AND "
cSQL += "BL9.D_E_L_E_T_ <> '*' AND "
//--condicao principal                     
cSQL += "	BA1.BA1_FILIAL = '"+xFilial("BA1")+"' AND "
cSQL += "	BA3.BA3_FILIAL = '"+xFilial("BA3")+"' AND "
cSQL += "	BL9.BL9_FILIAL = '"+xFilial("BL9")+"' AND "
cSQL += "	BA1.BA1_CODINT = '"+MV_PAR01+"' AND "
//--faixa de produtos
cSQL += "	BA3.BA3_CODPLA >='"+MV_PAR02+"' AND BA3.BA3_CODPLA <='"+MV_PAR03+"'"
cSQL += "	AND "
cSQL += "	BA1.BA1_DATINC < '"+DTOS(dDatFim)+"' AND "
cSQL += "	(BA1.BA1_DATBLO = '   ' OR BA1.BA1_DATBLO >='"+DTOS(dDatFim)+"') AND "
cSQL += "	(BA1.BA1_DATTRA = '   ' OR BA1.BA1_DATTRA >='"+DTOS(dDatFim)+"') AND "
cSQL += "   BA1.BA1_DATNAS <> 'Null' AND BA1.BA1_DATNAS <> '        '  AND "
cSQL += "   BA1.BA1_SEXO <> 'Null' AND BA1.BA1_SEXO <> ' ' AND "           
//calcular faixa etaria segundo padrao ANS
cSQL += "BL9_IDADEF IN ( SELECT MIN( BL9_IDADEF ) FROM "+RetSqlName("BL9")+" WHERE BL9_IDADEF  >= "
//cSQL += "MSDATEDIFF(YEAR,BA1_DATNAS, BA1_DATINC ) ) "

If Upper(cDbtipo) $ "ORACLE|POSTGRES"
//	cSql +=	"TO_NUMBER "
    cSql += "( TO_NUMBER(SUBSTR('"+DTOS(dDatFim-1)+"',1,4)) - TO_NUMBER(SUBSTR(TO_CHAR(BA1_DATNAS),1,4))))"
//	cSql += "+(( to_number(SUBSTR('"+DTOS(dDatFim-1)+"',5,2)) - to_number(SUBSTR(TO_CHAR(BA1_DATNAS),5,2)) )/12  )"
//	cSql += "+(  to_number(SUBSTR('"+DTOS(dDatFim-1)+"',7,2)) - to_number(SUBSTR(TO_CHAR(BA1_DATNAS),7,2)) )/360))"
ElseIf Upper(cDbtipo) == "DB2"
	cSQL += " ( INT(SUBSTR('"+DTOS(dDatFim-1)+"',1,4))-INT(SUBSTR(BA1_DATNAS,1,4)) ) )"
Else
	cSQL += " CONVERT(INT, "
	cSQL += "(CONVERT(INT, SUBSTRING('"+DTOS(dDatFim-1)+"',1,4))-CONVERT(INT, SUBSTRING(BA1_DATNAS,1,4)))"
	cSQL += "+(		(  ( CONVERT(FLOAT, SUBSTRING('"+DTOS(dDatFim-1)+"',5,2)) - CONVERT(INT, SUBSTRING(BA1_DATNAS,5,2)) ) /12 )+"
	cSQL += "(  ( CONVERT(FLOAT, SUBSTRING('"+DTOS(dDatFim-1)+"',7,2)) - CONVERT(INT, SUBSTRING(BA1_DATNAS,7,2)) ) /360 )	)	)	)"
Endif 

If mv_par05 == 1
    cSQL += " AND BA3_TIPOUS = '1' "
ElseIf mv_par05 == 2
	cSQL += " AND BA3_TIPOUS = '2' "
EndIf

cSQL += " GROUP BY BA3_TIPOUS, BA3_CODPLA, BA1_TIPUSU, BA1_SEXO, BL9_IDADEF "

cSQL += " ORDER BY BA3_TIPOUS, BA3_CODPLA, BA1_TIPUSU, BA1_SEXO, BL9_IDADEF "

//cSQL := MSParse(cSQL, alltrim(TcGetDB()))     //cBuffer:= MSParse(cBuffer,alltrim(TcGetDB()))

PLSQuery(cSQL,cArqTrab)

(cArqTrab)->(DbGoTop())

aTotGer := {}

dbSelectArea(cArqTrab)
if !lAutoSt
	SetRegua(RecCount())
endif

While (cArqTrab)->(! Eof())

	if !lAutoSt
		IncRegua()
	endif
	
	If (cArqTrab)->BA3_TIPOUS == "1"
		cSubTitulo := "*** P E S S O A    F I S I C A ***   "

	ElseIf (cArqTrab)->BA3_TIPOUS == "2"
		cSubTitulo := "*** P E S S O A    J U R I D I C A  ***   "

	ElseIf Empty((cArqTrab)->BA3_TIPOUS)
		cSubTitulo := "***    ***                     "
		
   EndIf

   cTipo := (cArqTrab)->BA3_TIPOUS
   aSubTot := {}
   
   If !lAutoSt .AND. li > 58
		cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		lTitulo := .T.
	EndIf
	
	@ li,000 PSAY cSubTitulo
	li +=2
   	
   While (cArqTrab)->(! Eof() .And. BA3_TIPOUS == cTipo)
   
   	cProd := (cArqTrab)->BA3_CODPLA
   	aProd := {{},{},{}, {}}
   	//onde 1o. elemento = Titular
   	//     2o. elemento = dependente
   	//		 3o. elemento = agregado
   	//		 4o. elemento = total
   	lTitulo := .T.
		nMasculino := 0
		nFeminino  := 0

		For nY := 1 TO Len(aFaixa)
  			aFaixa[nY][3] := 0
     	Next	
   	
	   If !lAutoSt .AND. li > 58
			cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			lTitulo := .T.
			
			@ li,000 PSAY cSubTitulo
			li+=2
			
		EndIf
   	
   	While (cArqTrab)->(! Eof() .And. BA3_TIPOUS+(cArqTrab)->BA3_CODPLA == cTipo+cProd)
	   
			If lTitulo
				@ li,00 PSay Padr( Posicione("BI3",1,xFilial("BI3")+mv_par01+(cArqTrab)->BA3_CODPLA,"BI3_NREDUZ"), 20)
				lTitulo := .F.		
			EndIf

			If (cArqTrab)->BA1_TIPUSU == 'T'
			   nTipUsu := 1
			ElseIf (cArqTrab)->BA1_TIPUSU == 'D'
			   nTipUsu := 2
			Else
			   nTipUsu := 3 // os demais vou considerar agregado
			EndIf

            nCol := 20 + ( (nTipUsu-1) * 48 ) 

			nPos := ASCAN( aProd[nTipUsu], {|aVal| aVal[1] == (cArqTrab)->(BA1_TIPUSU+BA1_SEXO)}	)	
			
			If nPos == 0
				aAdd(aProd[nTipUsu], {(cArqTrab)->(BA1_TIPUSU+BA1_SEXO) , (cArqTrab)->TOTUSU, nCol })
            Else
				aProd[nTipUsu][nPos][2] += (cArqTrab)->TOTUSU
		    EndIf
		   
		    If mv_par06 == 1
				nPosFai := ASCAN( aFaixa, {|aVal| aVal[1] == (cArqTrab)->(StrZero(BL9_IDADEF,3)+BA1_TIPUSU+BA1_SEXO)}	)	
				
				If nPosFai == 0
					aAdd(aFaixa, {(cArqTrab)->(StrZero(BL9_IDADEF,3)+BA1_TIPUSU+BA1_SEXO) ,"????", (cArqTrab)->TOTUSU, nCol })
	        	Else
					aFaixa[nPosFai][3] += (cArqTrab)->TOTUSU
				EndIf

         	EndIf

			If (cArqTrab)->BA1_SEXO == "1"
				nMasculino += (cArqTrab)->TOTUSU
			Else
				nFeminino += (cArqTrab)->TOTUSU
			EndIf	

			(cArqTrab)->(DbSkip())      
	   
	   End

	   nCol := 20 + ( (4-1) * 48 )
	   //incrementa coluna total - 4o. elemento
	   aAdd(aProd[4], { "Z1" , nMasculino, nCol })
	   aAdd(aProd[4], { "Z2" , nFeminino, nCol })
	   nTotGer := nMasculino + nFeminino

	   For nCtd := 1 TO 4
	   
	   	nMasculino := 0
	   	nFeminino  := 0
	   	nTotal     := 0

	      If LEN(aProd[nCtd]) > 0
		      For nX := 1 TO LEN(aProd[nCtd])
	
		      	If Right(aProd[nCtd][nX][1], 1) == "1"
		      		nMasculino += aProd[nCtd][nX][2]
		         ElseIf Right(aProd[nCtd][nX][1], 1) == "2"
		      		nFeminino += aProd[nCtd][nX][2]
		         EndIf
		         nCol := aProd[nCtd][nX][3]
		         
	         Next
				nTotal := nMasculino + nFeminino

      		@ li, nCol  	Psay Str(nMasculino, 08)
      		@ li, nCol+009 	Psay Str(Round(nMasculino/nTotal*100,1), 5, 1) + " %"
         
         	@ li, nCol+016 	Psay Str(nFeminino, 08)
      		@ li, nCol+025 	Psay Str(Round(nFeminino/nTotal*100,1), 5, 1) + " %"
      		
         	@ li, nCol+032 	Psay Str(nTotal, 08)
         	If nCtd < 4  // Total nao deve sair percentual
      			@ li, nCol+041 Psay Str(Round(nTotal/nTotGer*100,1), 5, 1) + " %"
      		EndIf
      	EndIf	
      		
    Next
         
	 li++
	 
	 //impressao distribuindo por faixa etaria
	 If mv_par06 == 1
	 	li++
		@ li, 000 Psay Space(20)+Repl("-",200)
        li++

	  	For nCtd := 1 TO Len(aFaixa)
	  	
  		  	nMasculino := 0
		  	nFeminino  := 0
  			nTotal     := 0
            nTotMasc   := 0
            nTotFemi   := 0
            
         	For nY := nCtd TO (nCtd+7)
         	   if nY <= Len(aFaixa) 	
         		If nY == nCtd
         			@li, 000 Psay PadL(aFaixa[nY][2], 15)
         		EndIf	

	      		If Right(aFaixa[nY][1], 1) == "1"
	      			nMasculino += aFaixa[nY][3]

	         	ElseIf Right(aFaixa[nY][1], 1) == "2"
	      			nFeminino += aFaixa[nY][3]

	         	EndIf
	          endif 	
	      	Next
	      	nTotal := nMasculino + nFeminino

            if nY <= Len(aFaixa) 	
	      	aFaixa[(nCtd+7)-1][3] := nMasculino
	      	aFaixa[(nCtd+7)  ][3] := nFeminino
            endif

            For nY := nCtd TO (nCtd+7)
                if nY <= Len(aFaixa)
            	nCol := aFaixa[nY][4]
         	
            	If Right(aFaixa[nY][1], 1) == "1"
		            @ li, nCol  	   Psay Str(aFaixa[nY][3], 08)
      				@ li, nCol+009 	Psay Str(Round(aFaixa[nY][3]/nTotal*100,1), 5, 1) + " %"
	         	ElseIf Right(aFaixa[nY][1], 1) == "2"
	         		@ li, nCol+016 	Psay Str(aFaixa[nY][3], 08)
      				@ li, nCol+025 	Psay Str(Round(aFaixa[nY][3]/nTotal*100,1), 5, 1) + " %"
      			EndIf
                endif
            Next
            
            @ li, nCol+032 	Psay Str(nTotal, 08)
            li++
            
            nCtd += 7
      		
    	Next
    	@ li, 000 Psay Repl("-",220)
		li++
	      
	 EndIf
	   
   End
   li++

End

IF !lAutoSt .ANd. li != 80
	roda(cbcont,cbtxt,tamanho)
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Integridade dos dados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cArqTrab)
dbCloseArea()

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

/*/{Protheus.doc} PLSR744AnoMes
	Criando a função herdada do código PLSR367 / PLSR367AnoMes, 
	pois o código foi descontinuado.
	- Validação Pergunta Mês/Ano inicial -
	@type  Function
	@author Gabriel J Mucciolo
	@since 23/03/2022
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function PLSR744AnoMes(cMesAno)
	Local lRet := .T.
	//A variavel cMesAno vem no formato 99/9999
	//Definida na X1_PICTURE da tabela SX1
	
	//posicao 1 -> MM (Mês)
	//posicao 2 -> AAAA (Ano)
	cMes := SUBSTR(cMesAno, 1, 2)     // MM
	cAno := SUBSTR(cMesAno, 4, 4)     // AAAA

	cData = CTOD("01/"+cMesAno)

	if(empty(cData)) 
		msgStop("Data inválida", "Atenção!")
		lRet := .F.
	endIf
	
Return(lRet)