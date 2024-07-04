#INCLUDE "HSPAHRDL.ch"
#include "protheus.ch"
#include "msgraphi.ch"
#INCLUDE "Report.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HSPAHRDL º    ³Antonio Carlos/Marcelo º Data ³ 10/08/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ PERCENTUAL DE INFECCAO POR CLASSIFICACAO FATORES DE RISCO  º±±
±±º          ³ Conversão para relatorios personalizaveis                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GESTAO HOSPITALAR.                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HSPAHRDL()
Local oReport
Private aVetorFat  := {}
Private aVetorGra  := {}
Private nTotGer    := 0
Private nTotIH     := 0
Private lTmpR4 := .F.
Private oTempTRB

If FindFunction("TRepInUse") .And. TRepInUse()
	pergunte("HSPRDL",.F.)
	oReport := ReportDef()
	oReport:PrintDialog()
	
	if( select( "TMPR4" ) > 0 )
  		oTempTRB:Delete()
	endIf
ELSE
	HSPAHRDLR3()
EndIF

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³REPORTDEF ³ Autor ³ Antonio Carlos/Marcelo³ Data ³ 10/08/06 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()
Local oReport
Local oSection1
Local oCell
Local oTotaliz1

oReport := TReport():New("HSPAHRDL",STR0003,"HSPRDL",{|oReport| RDLIMP(oReport)},STR0001 + " " + STR0002)  

oReport:SetPortrait()          

oSection1 := TRSection():New(oReport,STR0029,{"TMPR4"})
oSection1:SetHeaderBreak(.T.)    
oSection1:SetPageBreak(.F.)
oSection1:SetHeaderPage(.T.) 
oSection1:SetNoFilter({"TMPR4"})
oCell := TRCell():New(oSection1,"Cod","TMPR4",STR0025,,6)  //"Código"
oCell := TRCell():New(oSection1,"Des","TMPR4",STR0026,,30) //"Descrição"
oCell := TRCell():New(oSection1,"QIH","TMPR4",STR0027,,6)  //"Qtd IH"
oCell := TRCell():New(oSection1,"QCI","TMPR4",STR0028,,6)  //"No.Cir"
oCell := TRCell():New(oSection1,"Tx1","TMPR4",STR0029,,6)   //"Taxa IH Cir %"
oCell := TRCell():New(oSection1,"Tx2","TMPR4",STR0030,,6)  //"Taxa IH Geral%"

oTotaliz1 := TRFunction():new(oSection1:Cell("QIH"),,"SUM",,STR0031,,,.F.,.T.,.F.,,)   //"Total Qtd IH"
oTotaliz2 := TRFunction():new(oSection1:Cell("QCI"),,"SUM",,STR0032,,,.F.,.T.,.F.,,)  //"Total No.Cir"

Return( oReport )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ RDLImp   ³ Autor ³ Antonio Carlos        ³ Data ³ 10/08/06 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RDLIMP(oReport)

Local oSection1  := oReport:Section(1)
Local aCampos    := {}
Local nCtaFor    := 1

FS_MontMat(.F.)

aAdd(aCampos, {"COD", "C",  6, 0} )
aAdd(aCampos, {"DES", "C", 30, 0} )
aAdd(aCampos, {"QIH", "N",  6, 0} )
aAdd(aCampos, {"QCI", "N",  6, 0} )
aAdd(aCampos, {"Tx1", "N",  6, 2} )
aAdd(aCampos, {"Tx2", "N",  6, 2} )

//--< Criação do objeto FWTemporaryTable >---
oTempTRB := FWTemporaryTable():New( "TMPR4" )
oTempTRB:SetFields( aCampos )
oTempTRB:AddIndex( "INDTRB",{ "COD" } )

if( select( "TMPR4" ) > 0 )
	TMPR4->( dbCloseArea() )
endIf

oTempTRB:Create()
DbSelectArea("TMPR4")

For nCtaFor := 1 to Len(aVetorFat)
 RecLock("TMPR4", .T.)
  TMPR4->Cod := aVetorFat[nCtaFor,1] 
  TMPR4->Des := aVetorFat[nCtaFor,2]
  TMPR4->QIH := aVetorFat[nCtaFor,3]
  TMPR4->QCI := aVetorFat[nCtaFor,4]
  TMPR4->Tx1 :=(aVetorFat[nCtaFor,3] * 100)/aVetorFat[nCtaFor,4] 
  TMPR4->Tx2 :=(aVetorFat[nCtaFor,3] * 100)/ nTotGer 
 MsUnlock()
Next
DbGotop()                  

oSection1:Print() // processa as informacoes da tabela principal
oReport:SetMeter(GCY->(LastRec()))
lTmpR4:=.T.
Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHRDLR3º Autor ³ MARCELO JOSE       º Data ³  20/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ PERCENTUAL DE INFECCAO POR CLASSIFICACAO FATORES DE RISCO  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CCIH                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HSPAHRDLR3()

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := STR0003 //"PERCENTUAL DE INFECCAO POR CLAS. FATORES DE RISCO "
Local cPict          := ""
Local titulo         := STR0004 //"INFEC.CLAS.FATORES DE RISCO"
Local nLin           := 80

Local Cabec1         := STR0005 //"Fatores de Risco                	Qtd I.H.    No.Cir.   Tx IH Cir.%   Tx IH Geral%"
//                                                          9999       9999       999.99         999.99
Local Cabec2         := ""
Local imprime        := .T.
Local aOrd           := {}       

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 80
Private tamanho      := "P"
Private nomeprog     := "HSPAHRDL" 
Private nTipo        := 18
Private aReturn      := { STR0006, 1, STR0007, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHRDL" 
Private cString      := "GCY"
Private cPerg        := "HSPRDL"
Private aVetorFat    := {}
Private aVetorGra    := {}
Private nTotGer      := 0
Private nTotIH       := 0

Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

If !Pergunte(cPerg,.T.)
	return
EndIf

nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2

FS_MontMat() /* monta a matriz dos dados a serem impressos */

wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±  Monta a base dados para impressao                                      ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/        
Static Function FS_MontMat(lMontaG)
 Local bWhile    := {||!Eof()}, cArqOld1, cArqOld2, cSeqGeh := "", nPosVet := 0, nCtaFor, lContaIH := .F.
 Private cAliasGCY := "RDCQRY"                                                                             
 
 Default lMontaG := .T.
 
	#IFDEF TOP
	 
	 If TCSrvType() <> "AS/400"
	
		 dbSelectArea("GCY")
		 dbSetOrder(1)   
		 cQuery := "SELECT "
		 cQuery += "GCY.GCY_TPALTA GCY_TPALTA, "
		 cQuery += "GCY.GCY_REGATE GCY_REGATE, "
		 cQuery += "GCY.GCY_OBTINF GCY_OBTINF, "
		 cQuery += "GCY.GCY_DATALT GCY_DATALT "
		 cQuery += "FROM "+RetSqlName("GCY") + " GCY " 
		 cQuery += "WHERE "
		 cQuery += "GCY.GCY_FILIAL = '" + xFilial( "GCY" ) + "' AND GCY.D_E_L_E_T_ <> '*' AND "
	  cQuery += "GCY.GCY_TPALTA <> '99'"
	  cQuery += " AND GCY.GCY_TPALTA <> '  '"
   If !Empty(MV_PAR01) .AND. !Empty(MV_PAR02)
    cQuery += " AND GCY.GCY_DATALT BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
		 EndIf

   cQuery += " ORDER BY "+SqlOrder(GCY->(IndexKey()))

		 cQuery := ChangeQuery(cQuery)

		 dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasGCY,.T.,.T.)
   
   DbSelectArea(cAliasGCY)

			While (cAliasGCY)->(Eval(bWhile))

    cArqOld1 := Alias()

    DbSelectArea("GEO")
    DbSetOrder(2)
    If DbSeek(xFilial("GEO") + (cAliasGCY)->GCY_REGATE )
     DO WHILE !Eof() .AND. GEO->GEO_FILIAL == xFilial("GEO") .AND. GEO->GEO_REGATE = (cAliasGCY)->GCY_REGATE
      If Empty(GEO->GEO_CODIGO)
       DbSkip()
       Loop
      EndIf
      nPosVet := aScan(aVetorFat, {| aVetTmp | aVetTmp[1] == GEO->GEO_CODIGO } )
      If nPosVet <= 0
       AADD(aVetorFat, { GEO->GEO_CODIGO,Padr(POSICIONE("GEN",1,XFILIAL("GEN")+GEO->GEO_CODIGO,"GEN_DESCRI" ),30) , 0, 0 } )
      EndIf
   		 DbSkip()   
     End
    Else
     DbSelectArea(cArqOld1)
  		 DbSkip()
  		 Loop
    EndIf


    DbSelectArea("GEH")
    DbSetOrder(2)
    If DbSeek(xFilial("GEH") + (cAliasGCY)->GCY_REGATE )

     DO WHILE !Eof() .AND. GEH->GEH_FILIAL == xFilial("GEH") .AND. GEH->GEH_REGATE = (cAliasGCY)->GCY_REGATE

      cSeqGeh := GEH->GEH_SEQGEH

      If GEH->GEH_TPINFE # "2"
       DbSkip()
       Loop
      EndIf

      cArqOld2 := Alias()
      lContaIH := .F.
      
      DbSelectArea("GEJ")     		
      DbSetOrder(2)
      If DbSeek(xFilial("GEJ") + cSeqGeh )

       DO WHILE !Eof() .AND. GEJ->GEJ_FILIAL == xFilial("GEJ") .AND. GEJ->GEJ_SEQGEH = cSeqGeh

        For nCtaFor := 1 to Len(aVetorFat)

         If lContaIH == .F.
          lContaIH := .T.
          aVetorFat[nCtaFor,3] := aVetorFat[nCtaFor,3] + 1
          nTotIH++
         EndIf
        
         aVetorFat[nCtaFor,4] := aVetorFat[nCtaFor,4] + 1
        
         nTotGer++
        Next
        
        DbSkip()

       ENDDO
      EndIf
      DbSelectArea(cArqOld2)
      DbSkip()
     ENDDO
    EndIf
    DbSelectArea(cArqOld1)
 		 DbSkip()
	  EndDo
  EndIf

  DbSelectArea(cAliasGCY)
 	dbCloseArea()

  If lMontaG
   If MV_PAR03 == 2
    For nCtaFor := 1 To Len(aVetorFat)
    /* Monta vetor para o grafico carteziano */ 
    AADD(aVetorGra,{ ((aVetorFat[nCtaFor,3] * 100)/aVetorFat[nCtaFor,4] ) , aVetorFat[nCtaFor,2]   } ) 
    Next
    /* cria o objeto para contrucao do grafico */
    oGraf := hsGRAF():NEW(STR0008,STR0009 + DtoC(MV_PAR01) +STR0033 + DtoC(MV_PAR02), STR0010, "", STR0011, "", aVetorGra,1,1,0,0,2,20,6,6,25,20) //"C.C.I.H. - PERCENTUAL DE INFECCAO POR CLASSIFICACAO FATORES DE RISCO"###"No periodo de: "###"Percentuais"###"FATORES DE RISCO" //" a "
   EndIf 
  EndIf
  
 #ENDIF  	
Return(Nil)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±  Inicia a impressao do relatorio                                        ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
 Local nCtaFor

 Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
 nLin := 10                                                   

 For nCtaFor := 1 To Len(aVetorFat) /* loop da topografia */

  If nLin > nMaxLin
   If nCtaFor1 > 1
    @ nLin,00 Psay STR0012 //"Continua..."
   EndIf 
   Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo,,.T.)
   nLin := 8
   If nCtaFor1 > 1
    @ nLin,00 Psay STR0013 //"Continuacao..."
    nLin++
   EndIf 
  Endif
  
  @ nLin,00 PSAY aVetorFat[nCtaFor,2]           
  @ nLin,35 PSAY aVetorFat[nCtaFor,3] picture "9999"
  @ nLin,46 PSAY aVetorFat[nCtaFor,4] picture "9999"
  @ nLin,57 Psay Str( ((aVetorFat[nCtaFor,3] * 100)/aVetorFat[nCtaFor,4] )   ,6,2)
  @ nLin,72 Psay Str( ((aVetorFat[nCtaFor,3] * 100)/ nTotGer )   ,6,2)
  nLin++
   
 Next nCtaFor
 nLin++
 @ nLin,00 Psay Replicate("-",80) 
 nLin++
 @ nLin,00 Psay STR0014  //"Total"
 @ nLin,35 Psay nTotIH Picture "9999"
 @ nLin,46 Psay nTotGer Picture "9999"
 nLin++
 @ nLin,00 Psay Replicate("=",80) 
 
 SET DEVICE TO SCREEN

 If aReturn[5]==1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif

 MS_FLUSH()

Return(NIL)