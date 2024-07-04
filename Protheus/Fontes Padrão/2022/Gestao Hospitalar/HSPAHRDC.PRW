#INCLUDE "HSPAHRDC.ch"
#include "protheus.ch"
#include "msgraphi.ch"
#INCLUDE "Report.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HSPAHRDC º       ³ Antonio Carlos     º Data ³ 10/08/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ PERCENTUAL DE INFECCAO POR CLINICA E TOPOGRAFIA            º±±
±±º          ³ Conversão para relatorios personalizaveis                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GESTAO HOSPITALAR.                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HSPAHRDC()

Local oReport

Private aVetorCli := {}
Private aVetorTop := {}
Private aVetorGra := {}
Private nTotGer   := 0
Private nTotQtd   := 0
Private lTmpR4:=.F.
Private oTempTRB

If FindFunction("TRepInUse") .And. TRepInUse()
	pergunte("HSPRDC",.F.)
	oReport := ReportDef()
	oReport:PrintDialog()
	
	if( select( "TMPR4" ) > 0 )
		oTempTRB:Delete()
	endIf
ELSE
	HSPAHRDCR3()
EndIF

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³REPORTDEF ³ Autor ³ Antonio Carlos        ³ Data ³ 10/08/06 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()
Local oReport
Local oSection1, oSection2
Local oCell
Local oTotaliz1, oTotaliz2, oTotaliz3

oReport := TReport():New("HSPAHRDC",STR0003,"HSPRDC",{|oReport| RDCIMP(oReport)},STR0001 + " " + STR0002)  
 //"PERCENTUAL DE INFECCAO POR CLINICA E TOPOGRAFIA"### "Este programa tem como objetivo imprimir relatorio" ### "de acordo com os parametros informados pelo usuario."

//oReport:SetLandscape()         // Imprimir relatorio em formato paisagem
oReport:SetPortrait()          // Imprimir relatorio em formato retrato

oSection1 := TRSection():New(oReport,STR0015,{"TMPR4","GCW"})
oSection1:SetHeaderBreak(.T.)    
oSection1:SetPageBreak(.F.) 
oSection1:SetHeaderPage(.T.)
oSection1:SetNoFilter({"TMPR4"})
oCell := TRCell():New(oSection1,"cDes","GCW",STR0015,,30,,{||cDes:=HS_INIPADR("GCW", 1, ("TMPR4")->cCodCli , "GCW_DESCLI",,.F.)})   ////"Clinica :"

oSection2:=TRSection():New(oSection1,STR0036,{"TMPR4"})
oSection2:SetHeaderBreak(.T.)    
oSection2:SetPageBreak(.F.)
oSection2:SetHeaderPage(.T.)
oSection2:SetNoFilter({"TMPR4"})
oCell := TRCell():New(oSection2,"Des","TMPR4",STR0036,,30)  //"Topografia"
oCell := TRCell():New(oSection2,"Qtd","TMPR4",STR0037,,6)   //"Qtde"
oCell := TRCell():New(oSection2,"Txa","TMPR4"," (%) ","999.99",8) 

oTotaliz1 := TRFunction():new(oSection2:Cell("Qtd"),,"SUM",,STR0012,,,.T.,.F.,.F.,,)         //"Total da Clinica"
oTotaliz2 := TRFunction():new(oSection2:Cell("Qtd"),,"SUM",,STR0013,,,.T.,.F.,.F.,,)         //"Total Geral de Infeccoes"
oTotaliz3 := TRFunction():new(oSection2:Cell("Txa"),,"SUM",,STR0014,"999.99",,.T.,.F.,.F.,,) //"Percentual da Infecção da clinica x Total de Infecções"

Return(oReport)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TRFunction:  Classe que instancia totalizadores de quebra, secoes ou relatorios.                                                                        ³
//³ Parametros para o construtor inicializar as variaveis de instancia :                                                                                    ³
//³ (oSec:Cell("campo"),/*cVarTemp*/,/*FUNCAO*/,/*oBreak*/,/*cTit*/,/*cPict*/,/*uForm*/,.F./*lEndSect*/,.F./*lEndRep*/,.F./*lEndPage*/,oSection,condition)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ RDCImp   ³ Autor ³ Antonio Carlos        ³ Data ³ 10/08/06 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RDCIMP(oReport)

Local oSection1  := oReport:Section(1)
Local oSection2  := oReport:Section(1):Section(1)
Local oSection3  := oReport:Section(1):Section(1):Section(1)

Local aCampos  := {}
Local nCtaFor1 := 1

FS_MontMat(.F.)
aAdd(aCampos, {"CCODCLI", "C", 6, 0} )
aAdd(aCampos, {"CDESCLI", "C", 30, 0} )
aAdd(aCampos, {"Des"    , "C", 30, 0} )
aAdd(aCampos, {"Qtd"    , "N",  6, 2} )
aAdd(aCampos, {"Txa"    , "N",  6, 2} )

//--< Criação do objeto FWTemporaryTable >---
oTempTRB := FWTemporaryTable():New( "TMPR4" )
oTempTRB:SetFields( aCampos )
oTempTRB:AddIndex( "INDTRB",{ "CCODCLI","CDESCLI" } )

if( select( "TMPR4" ) > 0 )
	TMPR4->( dbCloseArea() )
endIf

oTempTRB:Create()

For nCtaFor1 := 1 to Len(aVetorTop)
 RecLock("TMPR4", .T.)
 TMPR4->CCODCLI := aVetorTop[nCtaFor1,1] 
 TMPR4->CDESCLI := aVetorTop[nCtaFor1,2] 
 TMPR4->Des     := aVetorTop[nCtaFor1,3] 
 TMPR4->Qtd     := aVetorTop[nCtaFor1,4]
 TMPR4->Txa     :=(aVetorTop[nCtaFor1,4] * 100)/nTotGer
 MsUnlock()
Next
DbGotop()                  

oSection2:SetParentFilter({|G|TMPR4->CCODCLI==G},{||TMPR4->CCODCLI })
oSection1:Print() // processa as informacoes da tabela principal
oReport:SetMeter(GCY->(LastRec()))

lTmpR4:=.T.

Return( NIL )



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHRDCR3º Autor ³ MARCELO JOSE       º Data ³  16/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ PERCENTUAL DE INFECCAO POR CLINICA E TOPOGRAFIA            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CCIH                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HSPAHRDCR3()

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := STR0003 //"PERCENTUAL DE INFECCAO POR CLINICA E TOPOGRAFIA"
Local cPict          := ""
Local titulo         := STR0004 //"PERCT. INFEC. POR CLINICA/TOPOGRAFIA"
Local nLin           := 80

Local Cabec1         := STR0005 //"Clinica"
Local Cabec2         := STR0006 //"  Topografia                                                 Qdte     (%)"
Local imprime        := .T.
Local aOrd           := {}       

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 80
Private tamanho      := "P"
Private nomeprog     := "HSPAHRDC" 
Private nTipo        := 18
Private aReturn      := { STR0007, 1, STR0008, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHRDC" 
Private cString      := "GCY"
Private cPerg        := "HSPRDC"
Private aVetorCli    := {}
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
 Local bWhile    := {||!Eof()}, cArqOld1, cArqOld2, nPosVet1 := 0, cSeqGeh := "", nCtaFor0 := 1, nPosVet2 := 0
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

      If GEH->GEH_CODCLI < MV_PAR03 .Or. GEH->GEH_CODCLI > MV_PAR04
       DbSkip()
       Loop
      EndIf
      
      If GEH->GEH_TPINFE # "2"
       DbSkip()
       Loop
      EndIf
      cSeqGeh := GEH->GEH_SEQGEH
      nPosVet1 := aScan(aVetorCli, {| aVetTmp | aVetTmp[1] == GEH->GEH_CODCLI } )
      nTotGer++
      
      If nPosVet1 <= 0
       AADD(aVetorCli,{"","",1})
       aVetorCli[Len(aVetorCli), 1] := GEH->GEH_CODCLI
       aVetorCli[Len(aVetorCli), 2] := POSICIONE("GCW", 1, xFilial("GCW") + GEH->GEH_CODCLI , "GCW_DESCLI")
      EndIf
 
      cArqOld2 := Alias()
      DbSelectArea("GEJ")
      DbSetOrder(2)
      If DbSeek(xFilial("GEJ") + cSeqGeh )
       DO WHILE !Eof() .AND. GEJ->GEJ_FILIAL == xFilial("GEJ") .AND. GEJ->GEJ_SEQGEH = cSeqGeh

        If GEJ->GEJ_CODTOP < MV_PAR05 .Or. GEJ->GEJ_CODTOP > MV_PAR06
         DbSkip()
         Loop
        EndIf
      
        nPosVet2 := 0
        For nCtaFor0 := 1 To Len(aVetorTop)
         If aVetorTop[nCtaFor0, 1] == GEH->GEH_CODCLI .And. aVetorTop[nCtaFor0, 2] == GEJ->GEJ_CODTOP .And. nPosVet2 == 0
          nPosVet2 := nCtaFor0
         EndIf
        Next
         
        If nPosVet2 > 0
         aVetorTop[nPosVet2, 4] := aVetorTop[nPosVet2, 4]+1
        Else
         AADD(aVetorTop,{"","","",1})
         aVetorTop[Len(aVetorTop), 1] := GEH->GEH_CODCLI
         aVetorTop[Len(aVetorTop), 2] := GEJ->GEJ_CODTOP
         aVetorTop[Len(aVetorTop), 3] := Posicione("SX5",1,xFilial("SX5")+"LI"+GEJ->GEJ_CODTOP,"X5_DESCRI")
        EndIf

        If nPosVet1 > 0
         aVetorCli[nPosVet1, 3] := aVetorCli[nPosVet1, 3]+ 1
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

  If MV_PAR07 == 2
   for nCtaFor0 := 1 To Len(aVetorCli)
   /* Monta vetor para o grafico carteziano */ 
   AADD(aVetorGra,{ ((aVetorCli[nCtaFor0,3]*100)/nTotGer) , aVetorCli[nCtaFor0,2]   } ) 
   Next
   /* cria o objeto para contrucao do grafico */
   oGraf := hsGRAF():NEW(STR0009,STR0010 + DtoC(MV_PAR01) +" a " + DtoC(MV_PAR02), STR0011, "", STR0005, "", aVetorGra,1,1,0,0,2,14,6,6,25,20) //"C.C.I.H. - PERCENTUAL DE INFECCAO POR CLINICA"###"No periodo de: "###"Percentuais"###"Clinica"
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
 Local cCodCli := "",cDesCli := "",nTotCli := 0, nCtaFor1 := 1, nCtaFor2 := 1

 Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
 nLin := 10                                                   

 For nCtaFor1 := 1 to len(aVetorCli)

  If cCodCli # aVetorCli[nCtaFor1,1] /*quebra por status*/
   If nCtaFor1 > 1
    nLin++
    @ nLin,00 Psay STR0012 + AllTrim(cDesCli) //"Total da Clinica "
    @ nLin,60 Psay nTotCli picture "9999"  
    nLin++
    @ nLin,00 Psay STR0013 //"Total Geral de Infeccoes"
    @ nLin,60 Psay nTotGer picture "9999"
    nLin++
    @ nLin,00 Psay STR0014 //"Percentual da Infeccao da clinica x Total de Infeccoes"
    @ nLin,69 PSay Str( ((nTotCli * 100)/nTotGer)   ,6,2)
    nLin++
    @ nLin,00 Psay Replicate("_",80)
    nLin++
   EndIf 
   nLin++
   @nLin,000 PSAY STR0015+aVetorCli[nCtaFor1,2] //"Clinica: "
   nLin+=2
   cCodCli := aVetorCli[nCtaFor1,1] 
   cDesCli := aVetorCli[nCtaFor1,2] 
   nTotCli := aVetorCli[nCtaFor1,3] 
  EndIf  
  
  For nCtaFor2 := 1 to len(aVetorTop) /* loop da topografia */

   If nLin > nMaxLin
    If nCtaFor1 > 1
     @ nLin,00 Psay STR0016 //"Continua..."
    EndIf 
    Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo,,.T.)
    nLin := 8
    If nCtaFor1 > 1
     @ nLin,00 Psay STR0017 //"Continuacao..."
     nLin++
    EndIf 
   Endif
   
   If aVetorTop[nCtaFor2,1] = cCodCli
    @nLin,02 PSAY aVetorTop[nCtaFor2,3]           
    @nLin,60 PSAY aVetorTop[nCtaFor2,4] picture "9999"
    @nLin,69 Psay Str( ((aVetorTop[nCtaFor2,4] * 100)/nTotGer) ,6,2)
    nLin++
   EndIf
   
  Next nCtaFor2

 Next nCtaFor1
 nLin++
 @ nLin,00 Psay STR0012 + AllTrim(cDesCli) //"Total da Clinica "
 @ nLin,60 Psay nTotCli picture "9999"  
 nLin++
 @ nLin,00 Psay STR0013 //"Total Geral de Infeccoes"
 @ nLin,60 Psay nTotGer picture "9999"
 nLin++
 @ nLin,00 Psay STR0014 //"Percentual da Infeccao da clinica x Total de Infeccoes"
 @ nLin,69 PSay Str( ((nTotCli * 100)/nTotGer)   ,6,2)
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