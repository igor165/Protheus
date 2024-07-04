#INCLUDE "HSPAHRDG.ch"
#include "protheus.ch"
#include "msgraphi.ch"
#INCLUDE "Report.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HSPAHRDG º   ³ Antonio Carlos/Marcelo º Data ³ 10/08/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ PERCENTUAL DE INFECCAO POR TOPOGRAFIA                      º±±
±±º          ³ Conversão para relatorios personalizaveis                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GESTAO HOSPITALAR.                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HSPAHRDG()
Local oReport
Private aVetorTop    := {}
Private aVetorGra    := {}
Private nTotGer      := 0
Private lTmpR4:=.F.
Private oTempTRB

If FindFunction("TRepInUse") .And. TRepInUse()
	pergunte("HSPRDG",.F.)
	oReport := ReportDef()
	oReport:PrintDialog()
  
	if( select( "TMPR4" ) > 0 )
		oTempTRB:Delete()
	endIf
ELSE
	HSPAHRDGR3()
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

oReport := TReport():New("HSPAHRDG",STR0003,"HSPRDG",{|oReport| RDGIMP(oReport)},STR0001 + " " + STR0002)  
 //"PERCENTUAL DE INFECCAO POR TOPOGRAFIA"### "Este programa tem como objetivo imprimir relatorio" ### "de acordo com os parametros informados pelo usuario."

//oReport:SetLandscape()         // Imprimir relatorio em formato paisagem
oReport:SetPortrait()          // Imprimir relatorio em formato retrato

oSection1 := TRSection():New(oReport,STR0011,{"TMPR4"})
oSection1:SetHeaderBreak(.T.)    
oSection1:SetPageBreak(.F.)
oSection1:SetHeaderPage(.T.)
oSection1:SetNoFilter({"TMPR4"})
oCell := TRCell():New(oSection1,"TOPO","TMPR4",STR0011,,50)  //"Topografia"
oCell := TRCell():New(oSection1,"QTE","TMPR4",STR0028,"99999",6)  //"Qtde"
oCell := TRCell():New(oSection1,"TXA","TMPR4","( % )","999.99",6) 

oTotaliz1 := TRFunction():new(oSection1:Cell("QTE"),,"SUM",,STR0029,"99999",,.F.,.T.,.F.,,)  //"TOTAL DE TOPOGRAFIA"
oTotaliz2 := TRFunction():new(oSection1:Cell("TXA"),,"SUM",,STR0030,"999.99",,.F.,.T.,.F.,,) //"TOTAL (%)         "

Return( oReport )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TRFunction:  Classe que instancia totalizadores de quebra, secoes ou relatorios.                                                                        ³
//³ Parametros para o construtor inicializar as variaveis de instancia :                                                                                    ³
//³ (oSec:Cell("campo"),/*cVarTemp*/,/*FUNCAO*/,/*oBreak*/,/*cTit*/,/*cPict*/,/*uForm*/,.F./*lEndSect*/,.F./*lEndRep*/,.F./*lEndPage*/,oSection,condition)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ RDGImp   ³ Autor ³ Antonio Carlos/Marcelo³ Data ³ 10/08/06 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RDGIMP(oReport)

Local oSection1  := oReport:Section(1)
Local aCampos    := {}
Local nCtaFor    := 1

FS_MontMat(.F.)

aAdd(aCampos, {"TOPO", "C", 30, 0} )
aAdd(aCampos, {"QTE", "N",  6, 2} )
aAdd(aCampos, {"TXA", "N",  6, 2} )

//--< Criação do objeto FWTemporaryTable >---
oTempTRB := FWTemporaryTable():New( "TMPR4" )
oTempTRB:SetFields( aCampos )
oTempTRB:AddIndex( "INDTRB",{ "TOPO","QTE","TXA" } )

if( select( "TMPR4" ) > 0 )
	TMPR4->( dbCloseArea() )
endIf

oTempTRB:Create()

For nCtaFor := 1 to Len(aVetorTop)
 RecLock("TMPR4", .T.)
 TMPR4->TOPO := aVetorTop[nCtaFor,2]
 TMPR4->QTE := aVetorTop[nCtaFor,3]
 TMPR4->TXA :=((aVetorTop[nCtaFor,3] * 100)/nTotGer) 
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
±±ºPrograma  ³HSPAHRDGR3º Autor ³ MARCELO JOSE       º Data ³  17/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ PERCENTUAL DE INFECCAO POR TOPOGRAFIA                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CCIH                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HSPAHRDGR3()

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := STR0003 //"PERCENTUAL DE INFECCAO POR TOPOGRAFIA"
Local cPict          := ""
Local titulo         := STR0004 //"PERCT. INFEC. POR TOPOGRAFIA"
Local nLin           := 80

Local Cabec1         := STR0005 //"  Topografia                                                 Qdte     (%)"
Local Cabec2         := ""
Local imprime        := .T.
Local aOrd           := {}       

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 80
Private tamanho      := "P"
Private nomeprog     := "HSPAHRDG" 
Private nTipo        := 18
Private aReturn      := { STR0006, 1, STR0007, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHRDG" 
Private cString      := "GCY"
Private cPerg        := "HSPRDG"
Private aVetorTop    := {}
Private aVetorGra    := {}
Private nTotGer      := 0

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
Static Function FS_MontMat()
 Local bWhile    := {||!Eof()}, cArqOld1, cArqOld2, cSeqGeh := "", nPosVet := 0, nCtaFor
 Private cAliasGCY := "RDCQRY"
 
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

      DbSelectArea("GEJ")
      DbSetOrder(2)
      If DbSeek(xFilial("GEJ") + cSeqGeh )

       DO WHILE !Eof() .AND. GEJ->GEJ_FILIAL == xFilial("GEJ") .AND. GEJ->GEJ_SEQGEH = cSeqGeh

        If GEJ->GEJ_CODTOP < MV_PAR03 .Or. GEJ->GEJ_CODTOP > MV_PAR04
         DbSkip()
         Loop
        EndIf
 
        If Empty(GEJ->GEJ_CODTOP)
         DbSkip()
         Loop
        EndIf
        
        nPosVet := aScan(aVetorTop, {| aVetTmp | aVetTmp[1] == GEJ->GEJ_CODTOP } )
  
        nTotGer++
      
        If nPosVet > 0
         aVetorTop[nPosVet, 3] := aVetorTop[nPosVet, 3]+1
        Else
         AADD(aVetorTop,{"","",1})
         aVetorTop[Len(aVetorTop), 1] := GEJ->GEJ_CODTOP
         aVetorTop[Len(aVetorTop), 2] := Posicione("SX5",1,xFilial("SX5")+"LI"+GEJ->GEJ_CODTOP,"X5_DESCRI")
        EndIf

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

  If MV_PAR05 == 2
   for nCtaFor := 1 To Len(aVetorTop)
   /* Monta vetor para o grafico carteziano */ 
   AADD(aVetorGra,{ ((aVetorTop[nCtaFor,3]*100)/nTotGer) , aVetorTop[nCtaFor,2]   } ) 
   Next
   /* cria o objeto para contrucao do grafico */
   oGraf := hsGRAF():NEW(STR0008,STR0009 + DtoC(MV_PAR01) +" a " + DtoC(MV_PAR02), STR0010, "", STR0011, "", aVetorGra,1,1,0,0,2,14,6,6,25,20) //"C.C.I.H. - PERCENTUAL DE INFECCAO POR TOPOGRAFIA"###"No periodo de: "###"Percentuais"###"TOPOGRAFIA"
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

 For nCtaFor := 1 To Len(aVetorTop) /* loop da topografia */

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
  
  @nLin,02 PSAY aVetorTop[nCtaFor,2]           
  @nLin,60 PSAY aVetorTop[nCtaFor,3] picture "9999"
  @nLin,69 Psay Str( ((aVetorTop[nCtaFor,3] * 100)/nTotGer)   ,6,2)
  nLin++
   
 Next nCtaFor
 nLin++
 @ nLin,00 Psay Replicate("-",80) 
 nLIn++
 @ nLin,00 Psay "TOTAL DE TOPOGRAFIA
 @ nLin,60 Psay nTotGer Picture "9999"
 @ nLin,69 Psay "100.00%"
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