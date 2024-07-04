#INCLUDE "HSPAHRC9.ch"
#include "rwmake.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHRC9 บ       ณ MARCELO JOSE       บ Data ณ 30/03/2005  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ GUIAS POR SETOR                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHRC9()

 Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3         := ""
 Local cPict          := ""
 Local cTitulo        := STR0003 //"R E L A T O R I O    D E   G U I A S   P O R   S E T O R"
 Local nLin           := 80
 Local cCabec1        := STR0004 //"Dt.Atend Hora  Nome--------------------------------- Atend. Medico-------------------------  Plano-------------------------  Tipo de Guia---------------------------  Numero da Guia------  Sequencia"
 Local cCabec2        := STR0035 //"Procedimentos----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
 Local imprime        := .T.
 Local aOrd           := {}
 Local nLinTotal      := 60

 Private lEnd         := .F.
 Private lAbortPrint  := .F.
 Private Tamanho      := "G"
 Private limite       := 80
 Private m_pag        := 01
 Private nomeprog     := "HSPAHRC9"
 Private nTipo        := 18
 Private aReturn      := {STR0005, 1, STR0006, 2, 2, 1, "", 1}  //"Zebrado"###"Administracao"
 Private nLastKey     := 0
 Private wnrel        := "HSPAHRC9"
 Private cString      := "GCY"
 Private aVetorPri    := {}
 Private aVetorSec    := {}
 Private cPerg        := "HSPRC9"

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

 If !Pergunte(cPerg,.T.)
  return
 EndIf          

 nMaxLin := HS_MaxLin(cCODIMP)
 nLin := nMaxLin * 2
 
 wnrel := SetPrint(cString,NomeProg,"",@cTitulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)
 
 If nLastKey == 27
  Return
 Endif
 
 SetDefault(aReturn,cString)
 
 If nLastKey == 27
  Return
 Endif
 
 RptStatus({|| RunRepRel(cCabec1, cCabec2, cTitulo, nLin, nLinTotal)}, cTitulo)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunRepRel(cCabec1, cCabec2, cTitulo, nLin, nLinTotal)
 
 Local nCtaFor   := 0 
 Local nCtaSec   := 0
 Local nPosVet   := 0
 Local nTotAlt   := 0
 Local nTotGer   := 0
 Local aMovs     := {}
 Local nTotMov   := 0
 Local cDescCC   := ""
 Local nHora     := 0
 Local cCodSetor := ""
 Local cCodConve := ""
 Local cPlanVer  := ""
 Local nCtaPlan  := 0
 Local nCtaSetor := 0
 Local nCtaConve := 0  
 Local nSimFec   := 0
 Local nNaoFec   := 0
 Local cCodTpg   := ""
 Local cArqOld, bWhile, cArqAnt
 Local nColuna   := 0
 Local nLenProc  := 0
 Local cAuxReg   := ""

 Private cAliasGCY := "GCY"

 /*===============================================================================================================*/
	#IFDEF TOP
  If TcSrvType() != "AS/400"
  	bWhile := {||!Eof()}                             
 	 cAliasGCY := "RC9QRY"
 	 dbSelectArea("GCY")
	  dbSetOrder(1)   
	  cQuery := "SELECT "
	  cQuery += "GCY.GCY_REGATE, GCY.GCY_REGGER, GCY.GCY_NOME, GCY.GCY_DATATE, GCY.GCY_HORATE, GCY.GCY_LOCATE, GCY.GCY_CODCRM, "
	  cQuery += "GCZ.GCZ_NRGUIA, GCZ.GCZ_NRSEQG, GCZ.GCZ_CODCON, GCZ.GCZ_REGATE, GCM.GCM_DESPLA, GCU.GCU_DESTPG, GA9.GA9_NOME "
	  cQuery += "FROM "+RetSqlName("GCY")+ " GCY JOIN " +RetSqlName("GCZ")+ " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial( "GCZ" ) + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_REGATE = GCY.GCY_REGATE AND "
   cQuery += "GCZ.GCZ_CODCON BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
	  cQuery += "JOIN "+RetSqlName("GCM")+ " GCM ON GCM.GCM_FILIAL = '" + xFilial( "GCM" ) + "' AND GCM.D_E_L_E_T_ <> '*' AND GCM.GCM_CODPLA = GCZ.GCZ_CODPLA "
	  cQuery += "JOIN "+RetSqlName("GCU")+ " GCU ON GCU.GCU_FILIAL = '" + xFilial( "GCU" ) + "' AND GCU.D_E_L_E_T_ <> '*' AND GCU.GCU_CODTPG = GCZ.GCZ_CODTPG "
	  cQuery += "JOIN "+RetSqlName("GA9")+ " GA9 ON GA9.GA9_FILIAL = '" + xFilial( "GA9" ) + "' AND GA9.D_E_L_E_T_ <> '*' AND GA9.GA9_CODCON = GCZ.GCZ_CODCON "
	  cQuery += "WHERE GCY.GCY_FILIAL = '" + xFilial( "GCY" ) + "' "
	  cQuery += "AND GCY.GCY_TPALTA <> '99' AND "
	  cQuery += "GCY.GCY_DATATE BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' AND "
   cQuery += "GCY.GCY_LOCATE BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' AND "
	  cQuery += "GCY.GCY_HORATE BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' AND "
	  cQuery += "GCY.D_E_L_E_T_ <> '*' "
	  cQuery += "ORDER BY "+SqlOrder(GCY->(IndexKey()))
	  cQuery := ChangeQuery(cQuery)
	  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasGCY,.T.,.T.)
                                                                                        
   DbSelectArea(cAliasGCY)
		 While !(cAliasGCY)->(Eof())
		         
 		 If (cAliasGCY)->GCY_REGATE <> cAuxReg
 		 
 		  DbSelectArea("GE7") /* FATURAMENTO PROCEDIMENTOS */
     DbSetOrder(3)
     If DbSeek(xFilial("GE7") + (cAliasGCY)->GCY_REGATE )
      DO WHILE !EOF() .AND. GE7->GE7_FILIAL == xFilial("GE7") .AND. GE7->GE7_REGATE == (cAliasGCY)->GCY_REGATE
      	cArqAnt := Alias()  
      	DbSelectArea("GA7") /* CADASTRO DE PROCEDIMENTOS */
       DbSetOrder(1)
       If DbSeek(xFilial("GA7") + GE7->GE7_CODDES )
        AADD(aVetorSec,{"","",""})
        aVetorSec[Len(aVetorSec),1] := (cAliasGCY)->GCY_REGATE
        aVetorSec[Len(aVetorSec),2] := GA7->GA7_DESC
        aVetorSec[Len(aVetorSec),3] := GE7->GE7_NRSEQG
       EndIf
      	DbSelectArea(cArqAnt)
       DbSkip()
      EndDo     
     EndIf
 		 EndIf 
 		 
 		 cAuxReg := (cAliasGCY)->GCY_REGATE
		 
 	 	nTotGer++
    AADD(aVetorPri,{"","","","","","","","","","",""})
    aVetorPri[Len(aVetorPri), 1] := HS_DToC(StoD((cAliasGCY)->GCY_DATATE))
    aVetorPri[Len(aVetorPri), 2] := (cAliasGCY)->GCY_HORATE
    aVetorPri[Len(aVetorPri), 3] := (cAliasGCY)->GCY_NOME
    aVetorPri[Len(aVetorPri), 4] := (cAliasGCY)->GCY_REGATE
    aVetorPri[Len(aVetorPri), 5] := (cAliasGCY)->GCY_CODCRM
    aVetorPri[Len(aVetorPri), 6] := (cAliasGCY)->GCZ_CODCON + " - " + (cAliasGCY)->GA9_NOME 
	   aVetorPri[Len(aVetorPri), 7] := (cAliasGCY)->GCM_DESPLA 
    aVetorPri[Len(aVetorPri), 8] := (cAliasGCY)->GCY_LOCATE
    aVetorPri[Len(aVetorPri), 9] := (cAliasGCY)->GCU_DESTPG
    aVetorPri[Len(aVetorPri),10] := (cAliasGCY)->GCZ_NRGUIA
    aVetorPri[Len(aVetorPri),11] := (cAliasGCY)->GCZ_NRSEQG
   
   
    DbSelectArea(cAliasGCY)
    DbSkip()
 
   EndDo

   DbSelectArea(cAliasGCY)
 	 dbCloseArea()
  
  EndIf
  
 #ENDIF 
/*================================================================================================================*/
 	
 If len(aVetorPri) > 0
  If MV_PAR09 == 1
   ASort(aVetorPri,,,{|x,y| X[8] + Subs(X[6],3,0) + X[7] + X[1] <  Y[8] + Subs(Y[6],3,0) + Y[7] + Y[1] })
  Else
   ASort(aVetorPri,,,{|x,y| X[8] + Subs(X[6],3,0) + X[7] +  X[3]      <  Y[8] + Subs(Y[6],3,0) + Y[7] + Y[3] })
  EndIf 
  SetRegua(Len(aVetorPri)) 
 Endif

 For nCtaFor = 1 to Len(aVetorPri)     	

  If lAbortPrint
   @nLin,00 PSAY STR0007 //"INTERROMPIDO PELO USUARIO"
   Exit
  Endif     
	
  If nLin > nMaxLin
  
   If nCtaFor > 1
    @ nLin,01 Psay STR0008 //"continua..."
   EndIf
   Cabec(cTitulo,cCabec1,cCabec2,NomeProg,Tamanho,nTipo)
   nLin := 8
   If !Empty(cCodSetor)
    If cCodSetor == aVetorPri[nCtaFor,8]
    	@ nLin,00 Psay STR0009 + PADR(Posicione("GCS", 1, xFilial("GCS") + aVetorPri[nCtaFor, 8], "GCS_NOMLOC"),30) //"......continuacao do Setor: "
 	   nLin += 2
    Endif               
   EndIf
   If !Empty(cCodConve)
    If cCodConve == Subs(aVetorPri[nCtaFor,6],3,0)
    	@ nLin,00 Psay STR0010 + aVetorPri[nCtaFor,6]   //"...continuacao do Convenio: "
 	   nLin += 2
    Endif
   EndIf
  Endif

  If Len(aVetorPri) >= 1
   If nCtaFor == 1 .OR. cCodSetor != aVetorPri[nCtaFor,8]
    If nCtaFor > 1
     nLin++
    Endif 
    If nCtaPlan > 0
     @ nLin,00 Psay STR0011 + Str(nCtaPlan,4,0) //"Total do Plano ======> "
     nLin++
     nCtaPlan := 0
    EndIf
    If nCtaConve > 0
     @ nLin,00 Psay STR0012 + Str(nCtaConve,4,0) //"Total do Convenio ===> "
     nLin++
     nCtaConve := 0
    EndIf    
    If nCtaSetor > 0
     @ nLin,00 Psay STR0013 + Str(nCtaSetor,4,0) //"Total do Setor ======> "
     nLin +=2
     nCtaSetor := 0
    EndIf     
  	 @ nLin,00 Psay PADR(Posicione("GCS", 1, xFilial("GCS") + aVetorPri[nCtaFor, 8], "GCS_NOMLOC"),30)
  	 nLin++
  	 @ nLin,00 Psay Repl("-",Len(Alltrim(Posicione("GCS", 1, xFilial("GCS") + aVetorPri[nCtaFor, 8], "GCS_NOMLOC"))))
    nLin ++
    @ nLin,05 Psay "==> " + aVetorPri[nCtaFor,6]
    nLin += 2
    cCodSetor := aVetorPri[nCtaFor,8]
    cCodConve := Subs(aVetorPri[nCtaFor,6],3,0)
    cPlanVer  := aVetorPri[nCtaFor,7]
   Else
    If cCodConve != Subs(aVetorPri[nCtaFor,6],3,0)
     @ nLin,00 Psay STR0012 + Str(nCtaConve,4,0)  //"Total do Convenio ===> "
     nLin++
     @ nLin,05 Psay "==> " + aVetorPri[nCtaFor,6]
     nLin += 2
     cCodConve := Subs(aVetorPri[nCtaFor,6],3,0)
     nCtaConve := 0
    EndIf
    If cPlanVer != aVetorPri[nCtaFor,7]
     nLin++
     @ nLin,00 Psay STR0011 + Str(nCtaPlan,4,0)  //"Total do Plano ======> "
     nLin +=2
     nCtaPlan := 0
     cPlanVer  := aVetorPri[nCtaFor,7]
    EndIf
   ENDIF
  ENDIF

  @ nLin,00  Psay aVetorPri[nCtaFor,1]       
  @ nLin,09  Psay aVetorPri[nCtaFor,2]
  @ nLin,15  Psay Padr(aVetorPri[nCtaFor,3],37)
  @ nLin,53  Psay aVetorPri[nCtaFor,4]
  @ nLin,60  Psay Posicione("SRA",11, xFilial("SRA") + aVetorPri[nCtaFor, 5], "RA_NOME")
  @ nLin,93  Psay aVetorPri[nCtaFor,7]
  @ nLin,125 Psay aVetorPri[nCtaFor,9] 
  @ nLin,166 Psay aVetorPri[nCtaFor,10] 
  @ nLin,188 Psay aVetorPri[nCtaFor,11] 

	 nPosVet := aScan(aVetorSec, {| aVetTmp | aVetTmp[3] == aVetorPri[nCtaFor,11] } )
  nColuna := 0
  
  If nPosVet > 0
   nLin++
   For nCtaSec := 1 to Len(aVetorSec)
    If aVetorSec[nCtaSec,3] == aVetorPri[nCtaFor,11]
     nLenProc := Len( Alltrim( aVetorSec[nCtaSec,2] ) )
     @ nLin,nColuna Psay Alltrim( aVetorSec[nCtaSec,2] ) + " / " 
     nColuna += nLenProc + 3
     If nColuna > 170
      nColuna := 0
      nLin++
     EndIf 
    EndIf
   Next nCtaSec
   nLin++
  EndIf

  nLin ++
  nCtaSetor++
  nCtaPlan++
  nCtaConve++

 Next nCtaFor
/************************************************ fim do loop de impressao dos dados ******************************/
 If nCtaPlan > 0
  nLin++
  @ nLin,00 Psay STR0011 + Str(nCtaPlan,4,0)  //"Total do Plano ======> "
  nLin++
  nCtaPlan := 0
 EndIf 
 If nCtaConve > 0
  @ nLin,00 Psay STR0012 + Str(nCtaConve,4,0) //"Total do Convenio ===> "
  nLin++
  nCtaConve := 0
 EndIf       
 If nCtaSetor > 0
  @ nLin,00 Psay STR0013 + Str(nCtaSetor,4,0)   //"Total do Setor ======> "
  nLin +=2
 EndIf     
    
 @ nLin,000 Psay REPLI("_",228)
 nLin++
 @ nLin,000 Psay STR0014 + Alltrim( Str(nTotGer,5,0) ) //" Total de Atendimentos no periodo ...: "
 
 Set Printer to
 Set Device  to Screen
 
 If aReturn[5]==1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif

 MS_FLUSH()
Return(Nil)
