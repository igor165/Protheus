#INCLUDE "HSPAHRDK.ch"
#include "protheus.ch"
#include "msgraphi.ch"
#INCLUDE "Report.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HSPAHRDK º       ³ Antonio Carlos     º Data ³ 10/08/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ PERCENTUAL DE INFECCAO POR CLASSIFICACAO ASA               º±±
±±º          ³ Conversão para relatorios personalizaveis                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GESTAO HOSPITALAR.                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HSPAHRDK()

Local oReport
Private aVetorAsa    := {}
Private aVetorGra    := {}
Private nTotGer      := 0
Private nTotIH       := 0
Private lTmpR4:=.F.
Private oTempTRB

If FindFunction("TRepInUse") .And. TRepInUse()
	pergunte("HSPRDK",.F.)
	oReport := ReportDef()
	oReport:PrintDialog()
	
	if( select( "TMPR4" ) > 0 )
  		oTempTRB:Delete()
	endIf
ELSE
	HSPAHRDKR3()
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

oReport := TReport():New("HSPAHRDK",STR0003,"HSPRDK",{|oReport| RDKIMP(oReport)},STR0001 + " " + STR0002)  
 //"PERCENTUAL DE INFECCAO POR CLASSIFICACAO ASA"### "Este programa tem como objetivo imprimir relatorio" ### "de acordo com os parametros informados pelo usuario."

//oReport:SetLandscape()         // Imprimir relatorio em formato paisagem
oReport:SetPortrait()          // Imprimir relatorio em formato retrato

oSection1 := TRSection():New(oReport,"Classifica ASA ",{"TMPR4"})
oSection1:SetHeaderBreak(.T.)    
oSection1:SetPageBreak(.F.)
oSection1:SetHeaderPage(.T.)                        
oSection1:SetNoFilter({"TMPR4"})
oCell := TRCell():New(oSection1,"ASA","TMPR4",STR0011,,15)         //"A S A"
oCell := TRCell():New(oSection1,"QIH","TMPR4",STR0025,,8)          //"Qtde I.H."
oCell := TRCell():New(oSection1,"NCI","TMPR4",STR0026,,8)          //"No.Cirurgias"
oCell := TRCell():New(oSection1,"TX1","TMPR4",STR0027,"999.99",8)  //"Taxa IH Cirurgia %"
oCell := TRCell():New(oSection1,"TX2","TMPR4",STR0028,"999.99",8)  //"Taxa IH Geral%"

oTotaliz1 := TRFunction():new(oSection1:Cell("QIH"),,"SUM",,STR0029,,,.F.,.T.,.F.,,)   //"Total Qtd IH"
oTotaliz2 := TRFunction():new(oSection1:Cell("NCI"),,"SUM",,STR0030,,,.F.,.T.,.F.,,)   //"Total No.Cir"

Return( oReport )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TRFunction:  Classe que instancia totalizadores de quebra, secoes ou relatorios.                                                                        ³
//³ Parametros para o construtor inicializar as variaveis de instancia :                                                                                    ³
//³ (oSec:Cell("campo"),/*cVarTemp*/,/*FUNCAO*/,/*oBreak*/,/*cTit*/,/*cPict*/,/*uForm*/,.F./*lEndSect*/,.F./*lEndRep*/,.F./*lEndPage*/,oSection,condition)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ RDKImp   ³ Autor ³ Antonio Carlos        ³ Data ³ 10/08/06 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RDKIMP(oReport)

Local oSection1  := oReport:Section(1)
Local aCampos    := {}
Local nCtaFor    := 1

FS_MontMat(.F.)

aAdd(aCampos, {"ASA", "C",  6, 0} )
aAdd(aCampos, {"QIH", "N",  6, 0} )
aAdd(aCampos, {"NCI", "N",  6, 0} )
aAdd(aCampos, {"TX1", "N",  6, 2} )
aAdd(aCampos, {"TX2", "N",  6, 2} )

//--< Criação do objeto FWTemporaryTable >---
oTempTRB := FWTemporaryTable():New( "TMPR4" )
oTempTRB:SetFields( aCampos )
oTempTRB:AddIndex( "INDTRB",{ "ASA" } )

if( select( "TMPR4" ) > 0 )
	TMPR4->( dbCloseArea() )
endIf

oTempTRB:Create()

For nCtaFor := 1 to Len(aVetorAsa)
 RecLock("TMPR4", .T.)
  TMPR4->ASA :=  aVetorAsa[nCtaFor,2] 
  TMPR4->QIH :=  aVetorAsa[nCtaFor,3]
  TMPR4->NCI :=  aVetorAsa[nCtaFor,4]
  TMPR4->TX1 := (aVetorAsa[nCtaFor,3] * 100) / aVetorAsa[nCtaFor,4] 
  TMPR4->TX2 := (aVetorAsa[nCtaFor,3] * 100) / nTotGer 
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
±±ºPrograma  ³HSPAHRDKR3º Autor ³ MARCELO JOSE       º Data ³  18/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ PERCENTUAL DE INFECCAO POR CLASSIFICACAO ASA               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CCIH                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HSPAHRDKR3()

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := STR0003 //"PERCENTUAL DE INFECCAO POR CLASSIFICACAO ASA"
Local cPict          := ""
Local titulo         := STR0004 //"PERCT. INFEC. POR CLASSIFICACAO ASA"
Local nLin           := 80

Local Cabec1         := STR0005 //"ASA         		Qtd I.H.    No.Cirurgias   TaxaIH Cirurgia%   Taxa IH Geral%"

Local Cabec2         := ""
Local imprime        := .T.
Local aOrd           := {}       

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 80
Private tamanho      := "P"
Private nomeprog     := "HSPAHRDK" 
Private nTipo        := 18
Private aReturn      := { STR0006, 1, STR0007, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHRDK" 
Private cString      := "GCY"
Private cPerg        := "HSPRDK"
Private aVetorAsa    := {}
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
Static Function FS_MontMat()
 Local bWhile    := {||!Eof()}, cArqOld1, cArqOld2, cSeqGeh := "", nPosVet := 0, nCtaFor, lContaIH := .F.
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

   AADD(aVetorAsa, { "1","ASA 1"   , 0, 0 } )
   AADD(aVetorAsa, { "2","ASA 2"   , 0, 0 } )
   AADD(aVetorAsa, { "3","ASA 3"   , 0, 0 } )
   AADD(aVetorAsa, { "4","ASA 4"   , 0, 0 } )
   AADD(aVetorAsa, { "5","ASA 5"   , 0, 0 } )
   AADD(aVetorAsa, { "6","Ignorado", 0, 0 } )         

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
      lContaIH := .F.
      
      DbSelectArea("GEJ")     		
      DbSetOrder(2)
      If DbSeek(xFilial("GEJ") + cSeqGeh )

       DO WHILE !Eof() .AND. GEJ->GEJ_FILIAL == xFilial("GEJ") .AND. GEJ->GEJ_SEQGEH = cSeqGeh

        If Val(GEJ->GEJ_ASA) < 1 .Or. Val(GEJ->GEJ_ASA) > 6
         DbSkip()
         Loop
        EndIf
      
        nPosVet := Val(GEJ->GEJ_ASA)

        If lContaIH == .F.
         lContaIH := .T.
         aVetorAsa[nPosVet,3] := aVetorAsa[nPosVet,3] + 1
         nTotIH++
        EndIf
        
        aVetorAsa[nPosVet,4] := aVetorAsa[nPosVet,4] + 1
        
        nTotGer++
 
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

  If MV_PAR03 == 2
   For nCtaFor := 1 To Len(aVetorAsa)
    /* Monta vetor para o grafico carteziano */ 
    AADD(aVetorGra,{ ((aVetorAsa[nCtaFor,3] * 100)/aVetorAsa[nCtaFor,4] ) , aVetorAsa[nCtaFor,2]   } ) 
   Next
   oGraf := hsGRAF():NEW(STR0008,STR0009 + DtoC(MV_PAR01) +" a " + DtoC(MV_PAR02), STR0010, "", STR0011, "", aVetorGra,1,1,0,0,2,8,6,6,25,20) //"C.C.I.H. - PERCENTUAL DE INFECCAO POR CLASSIFICACAO ASA"###"No periodo de: "###"Percentuais"###"A S A"
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

 For nCtaFor := 1 To Len(aVetorAsa) /* loop da topografia */

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
  
  @ nLin,00 PSAY aVetorAsa[nCtaFor,2]           
  @ nLin,16 PSAY aVetorAsa[nCtaFor,3] picture "9999"
  @ nLin,30 PSAY aVetorAsa[nCtaFor,4] picture "9999"
  @ nLin,46 Psay Str( ((aVetorAsa[nCtaFor,3] * 100)/aVetorAsa[nCtaFor,4] )   ,6,2)
  @ nLin,64 Psay Str( ((aVetorAsa[nCtaFor,3] * 100)/ nTotGer )   ,6,2)
  nLin++
   
 Next nCtaFor
 nLin++
 @ nLin,00 Psay Replicate("-",80) 
 nLin++
 @ nLin,00 Psay STR0014  //"Total"
 @ nLin,16 Psay nTotIH Picture "9999"
 @ nLin,30 Psay nTotGer Picture "9999"
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
