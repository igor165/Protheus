#INCLUDE "HSPAHRD3.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHRD3 บ       ณ MARCELO JOSE       บ Data ณ 16/04/2005  บฑฑ  
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ FATURA CAPA                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHRD3( cProgCh, aGuiasP12 )
 Local aArea         := GetArea()
 Local cDesc1        := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2        := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3        := ""
 Local cPict         := ""
 Local imprime       := .T.
 Local aOrd          := {}
 Local aGuias        := IIF(!Empty(aGuiasP12), aClone(aGuiasP12), {})
 
 Private cTitulo     := STR0033 //"Capa da Fatura"
 Private nLin        := 80 
 Private cCabec1     := ""
 Private cCabec2     := ""
 Private nLinTotal   := 60

 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private Tamanho     := "M"
 Private Limite      := 132
 Private m_pag       := 01
 Private nomeprog    := "HSPAHRD3"
 Private nTipo       := 18
 Private aReturn     := {STR0003, 1, STR0004, 2, 1, 1, "", 1}  //"Zebrado"###"Administracao"
 Private nLastKey    := 0    
 Private cbtxt       := Space(10)
 Private cbcont      := 00
 Private CONTFL      := 01
 Private wnrel       := "HSPAHRD3"
 Private cString     := "GCY"
 Private aVetor      := {}
 
 Private nTpFat      := 0
 Private cRegAte_De  := ""
 Private cRegAte_Ate := ""
 Private cNrSeqG_De  := ""
 Private cNrSeqG_Ate := ""

 Private bRepli       := {|| REPLI("_",limite) }
 Private lChamado     := !Empty(cProgCh)

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao
 Private nMaxConta:=0
 
 If !lChamado
  If !Pergunte("HSPRC6",.T.)
   Return()
  EndIf          
  nTpFat      := mv_par01
  cRegAte_De  := mv_par02
  cRegAte_Ate := mv_par03
  cNrSeqG_De  := mv_par04
  cNrSeqG_Ate := mv_par05
  lImpGraf    := mv_par06 == 1
  aGuias      := HS_RC6Guias(nTpFat, cRegAte_De, cRegAte_Ate, cNrSeqG_De, cNrSeqG_Ate)
 Else
  If !Pergunte("HSPRD3", .T.)
   Return
  Else
   nOrdemGuia  := mv_par01
   lImpGraf    := mv_par02 == 1
  Endif
 Endif 

 If lImpGraf

  RptStatus({ || RunRepRel(aGuias, .T.) }, cTitulo)
  
 Else
  nMaxLin := HS_MaxLin(cCODIMP)
  nLin := nMaxLin * 2
 
  If Len(aGuias) == 0
   HS_MsgInf(STR0035, STR0042, STR0043) //"Nenhuma guia foi selecionada. Verifique!"###"Aten็ใo"###"Capa Fatura" 
   Return()
  Endif 
 
  wnrel := SetPrint(cString,NomeProg,"HSPRD3",@cTitulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho)
 
  If nLastKey == 27
   Return
  Endif
 
  SetDefault(aReturn,cString)
 
  If nLastKey == 27
   Return
  Endif
                           
  nTipo := If(aReturn[4]==1,15,18)

  RptStatus({|| RunRepRel(aGuias)}, cTitulo)

  SET PRINTER TO
  SET DEVICE TO SCREEN
 
  If aReturn[5]==1
   DbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
  Endif

  MS_FLUSH()
 
 EndIf
  
 RestArea(aArea)

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunRepRel(aGuias, lGraf)
 Local cAFat5, cAFat6, cAFat7
 Local nForGui := 0

 Private oPrn       := Nil

 Default lGraf := .F.

 If FunName() == "HSPAHP12"
	If Len(aGuias) > 0
		If !Empty(aGuias[1,3]) .And. nOrdemGuia == 1
			aSort(aGuias,,,{|x,y| x[3] < y[3]})
		Endif
	Endif
 Endif

 If lGraf
  oPrn := TMSPrinter():New()
  oPrn:Setup()
 EndIf
 
 SetRegua(nLenGuias := len(aGuias))
 For nForGui := 1 To nLenGuias

  m_pag := 01
  DbSelectArea("GCZ")
  DbSetOrder(1)
  DbSeek(xFilial("GCZ") + aGuias[nForGui,1])
  
  If HS_IniPadr("GCU", 1, GCZ->GCZ_CODTPG, "GCU_TPGUIA") == "7" //Se for retorno 
   Loop                                                          //Nใo executa
  EndIf

 nMaxConta:=FS_MAXCTA(GCZ->GCZ_REGATE)
  If lChamado
   cAFat5 := Iif(GCZ->GCZ_STATUS $ "0/1", "GD5", "GE5")
   cAFat6 := Iif(GCZ->GCZ_STATUS $ "0/1", "GD6", "GE6")
   cAFat7 := Iif(GCZ->GCZ_STATUS $ "0/1", "GD7", "GE7")   
  Else
   cAFat5 := Iif( nTpFat == 1, "GD5", "GE5" )
   cAFat6 := Iif( nTpFat == 1, "GD6", "GE6" )
   cAFat7 := Iif( nTpFat == 1, "GD7", "GE7" )
  Endif  
        
  aSort(aVetor,,,{|x,y| x[5]+x[1] < y[5]+y[1]}) // UND CONSUMO + GRP DESPESA

  If lGraf
  
   FS_ImpGraf(cAFat5, cAFat6, cAFat7)
   
  Else
   FS_Capa()
   FS_Pre(cAFat5, cAFat6, cAFat7)
   FS_Impr(nLin)
  EndIf
  
  IncRegua() 

 Next nForGui

 If lGraf
  oPrn:Preview()
  oPrn:End()
 EndIf

Return()
/******************************************************************************************************************/
Static Function FS_Capa()
 Local aArea   := GetArea()
 
 DbSelectArea("GBH")
 DbSetOrder(1)
 DbSeek(xFilial("GBH") + GCZ->GCZ_REGGER)
 
 DbSelectArea("GCY")
 DbSetOrder(1)
 DbSeek(xFilial("GCY") + GCZ->GCZ_REGATE)
 
 If nLin > nMaxLin
   nLin := FS_CabEmp(nLin)
   nLin := 12
 EndIf  

 @ nLin,43 Psay STR0005 + GCZ->GCZ_NRFATU //"F A T U R A     H O S P I T A L A R   "
 nLin++
 @ nLin,00 Psay Eval(bRepli)
 nLin++
 @ nLin,00 Psay STR0006 + GCY->GCY_NOME                  //"Nome..............: "
 @ nLin,67 Psay STR0007 + DTOC(GBH->GBH_DTNASC)          //"Data de Nascimento: "
 If GBH->GBH_SEXO == "0"                                 //"Sexo .....: "
  @ nLin,99 Psay STR0008 + STR0036 //"Masculino"
 ElseIf GBH->GBH_SEXO == "1"  
  @ nLin,99 Psay STR0008 + STR0037 //"Feminino"
 EndIf  
 nLin++
 @ nLin,00 Psay STR0038 + ALLTRIM(GCY->GCY_IDADE)    //"Idade.............: "
 nLin++
 @ nLin,00 Psay STR0009 + GBH->GBH_END                   //"Endereco .........: "
 @ nLin,67 Psay STR0010 + GBH->GBH_NUM                   //"Numero ...........: "
 @ nLin,99 Psay STR0011 + GBH->GBH_BAIRRO                //"Bairro ...: "
 nLin++
 @ nLin,00 Psay STR0012 + GBH->GBH_CEP +  " " + ALLTRIM(GBH->GBH_MUN) + " - " + GBH->GBH_EST   //"Municipio ........: "
 nLin++
 @ nLin,00 Psay STR0013 + GBH->GBH_TEL                   //"Telefone .........: "
 @ nLin,67 Psay STR0014 + GBH->GBH_CPF                   //"C.P.F. ...........: "
 @ nLin,99 Psay STR0015 + GBH->GBH_RG                    //"Identidade: "
 nLin++
 @ nLin,00 Psay STR0016 + Posicione("GFD",1,xFilial("GFD")+GCY->GCY_CODRES, "GFD_NOME")  //"Responsavel ......: "
 nLin++
 @ nLin,00 Psay STR0017 + GCZ->GCZ_REGGER                //"PRONTUARIO .......: "
 nLin++
 @ nLin,00 Psay Eval(bRepli)
 nLin++

 @ nLin,00 Psay STR0018 + POSICIONE("GA9", 1, xFilial("GA9") + GCZ->GCZ_CODCON, "GA9_NOME") //"Convenio .........: "
 @ nLin,67 Psay STR0019 + POSICIONE("GCM", 2, xFilial("GCM") + GCZ->GCZ_CODPLA, "GCM_DESPLA") //"Plano ............: "
 nLin++
 @ nLin,00 Psay STR0020 + GCZ->GCZ_NRSEQG //"Guia .............: "
 @ nLin,67 Psay STR0021 + GCZ->GCZ_REGATE //"Atendimento ......: "
 @ nLin,99 Psay STR0022 + GCY->GCY_CIDALT //"CID ......: "
 nLin++
 @ nLin,00 Psay STR0023 + Posicione("GAV",1,xFilial("GAV")+GCY->GCY_REGATE,"GAV_LEITO") //"LEITO ............: "
 nLin++
 @ nLin,00 Psay STR0024 + DTOC(GCY->GCY_DATATE) //"Data da Entrada ..: "
 @ nLin,67 Psay STR0025 + GCY->GCY_HORATE //"Hora da Entrada ..: "
 nLin++
 @ nLin,00 Psay STR0026 + DTOC(GCY->GCY_DATALT) //"Data da Saida ....: "
 @ nLin,67 Psay STR0027 + GCY->GCY_HORALT //"Hora da Saida ....: "
 nLin++  
 @ nLin,00 Psay STR0039 + ALLTRIM(STR(GCZ->GCZ_CTAPAR,2)) //"Nr.Fechamento.....: "
 @ nLin,67 Psay STR0040 + DTOC(GCZ->GCZ_DCPARI) //"Data Inic. Fech...: "
 @ nLin,99 Psay STR0041 + Dtoc(IIF(((EMPTY(GCY->GCY_DATALT).or.GCY->GCY_DATALT>GCZ->GCZ_DCPARF).AND.GCZ->GCZ_CTAPAR<>nMaxConta	 ), GCZ->GCZ_DCPARF, GCY->GCY_DATALT    )) 
 nLin++
 @ nLin,00 Psay Eval(bRepli)
 nLin++

 RestArea(aArea)
Return()

/******************************************************************************************************************/
Static Function FS_Pre(cAFat5, cAFat6, cAFat7)  
 Local cArqOl1
 Local cArqOl2
 Local cPreFa5 := cAFat5 + "->" + PrefixoCpo(cAFat5)
 Local cPreFa6 := cAFat6 + "->" + PrefixoCpo(cAFat6)
 Local cPreFa7 := cAFat7 + "->" + PrefixoCpo(cAFat7)

  cArqOl1 := Alias()
  DbSelectArea(cAFat5)
  DbSetOrder(2) 
 If DbSeek(xFilial(cAFat5) + GCZ->GCZ_NRSEQG)
  DO WHILE !Eof() .AND. &(cPreFa5+"_FILIAL") == xFilial(cAFat5) .AND. &(cPreFa5+"_NRSEQG") = GCZ->GCZ_NRSEQG 
   If  &(cPreFa5+"_GLODES")== "0"
    cCodDes := &(cPreFa5+"_CODDES")
    cArqOl2 := Alias() 
    DbSelectArea("GBI")
    DbSetOrder(1)
    If DbSeek(xFilial("GBI") + cCodDes )
     DbSelectArea("GCS")
     DbSetOrder(1)
     DbSeek(xFilial("GCS") + &(cPreFa5+"_CODLOC") )
     nPosVet := aScan(aVetor, {| aVetTmp | aVetTmp[5] == GCS->GCS_CODUNC .and. aVetTmp[1] == GBI->GBI_CODGDE } )
     If nPosVet > 0        
      aVetor[nPosVet,1] := GBI->GBI_CODGDE
      aVetor[nPosVet,2] := PADR(Posicione("GCS", 1, xFilial("GCS") + &(cPreFa5+"_CODLOC"), "GCS_NOMLOC"),30)
      aVetor[nPosVet,3] += HS_CValDes(cAFat5, &(cPreFa5+"_SEQDES") )
      aVetor[nPosVet,4] := Posicione("GAW", 1, xFilial("GAW") + GBI->GBI_CODGDE, "GAW_DESC")
      aVetor[nPosVet,5] := GCS->GCS_CODUNC
      aVetor[nPosVet,6] := Posicione("GCT", 1, xFilial("GCT") + GCS->GCS_CODUNC, "GCT_DESUNC")
      aVetor[nPosVet,7] := GCY->GCY_REGATE
      aVetor[nPosVet,8] += &(cPreFa5+"_QTDDES") * &(cPreFa5+"_DESVAL") //Desconto
     Else  
      AADD(aVetor,{"","",0,"","","","",0})
      aVetor[Len(aVetor),1] := GBI->GBI_CODGDE
      aVetor[Len(aVetor),2] := PADR(Posicione("GCS", 1, xFilial("GCS") + &(cPreFa5+"_CODLOC"), "GCS_NOMLOC"),30)
      aVetor[Len(aVetor),3] := HS_CValDes(cAFat5, &(cPreFa5+"_SEQDES") )
      aVetor[Len(aVetor),4] := Posicione("GAW", 1, xFilial("GAW") + GBI->GBI_CODGDE, "GAW_DESC")
      aVetor[Len(aVetor),5] := GCS->GCS_CODUNC
      aVetor[Len(aVetor),6] := Posicione("GCT", 1, xFilial("GCT") + GCS->GCS_CODUNC, "GCT_DESUNC")
      aVetor[Len(aVetor),7] := GCY->GCY_REGATE
      aVetor[Len(aVetor),8] := &(cPreFa5+"_QTDDES") * &(cPreFa5+"_DESVAL")//Desconto
     EndIf
    EndIf
    dbselectArea(cArqOl2)
   Endif 
   DbSkip() 
  ENDDO
 EndIf 
 
 DbSelectArea(cAFat6)
 DbSetOrder(2)
 If DbSeek(xFilial(cAFat6) + GCZ->GCZ_NRSEQG)
  DO WHILE !Eof() .AND. &(cPreFa6+"_FILIAL") == xFilial(cAFat6) .AND. &(cPreFa6+"_NRSEQG") = GCZ->GCZ_NRSEQG  
   If &(cPreFa6+"_GLODES")== "0"
    cCodDes := &(cPreFa6+"_CODDES")
    cArqOl2 := Alias()
    DbSelectArea("GAA")
    DbSetOrder(1)
    If DbSeek(xFilial("GAA") + cCodDes )
     DbSelectArea("GCS")
     DbSetOrder(1)
     DbSeek(xFilial("GCS") + &(cPreFa6+"_CODLOC") )                                         
     nPosVet := aScan(aVetor, {| aVetTmp | aVetTmp[5] == GCS->GCS_CODUNC .and. aVetTmp[1] == GAA->GAA_CODGDE } )
     If nPosVet > 0
      aVetor[nPosVet,1] := GAA->GAA_CODGDE
      aVetor[nPosVet,2] := PADR(Posicione("GCS", 1, xFilial("GCS") + &(cPreFa6+"_CODLOC"), "GCS_NOMLOC"),30)
      aVetor[nPosVet,3] += HS_CValDes(cAFat6, &(cPreFa6+"_SEQDES") )
      aVetor[nPosVet,4] := Posicione("GAW", 1, xFilial("GAW") + GAA->GAA_CODGDE, "GAW_DESC")  
      aVetor[nPosVet,5] := GCS->GCS_CODUNC
      aVetor[nPosVet,6] := Posicione("GCT", 1, xFilial("GCT") + GCS->GCS_CODUNC, "GCT_DESUNC")
      aVetor[nPosVet,7] := GCY->GCY_REGATE  
      aVetor[nPosVet,8] += &(cPreFa6+"_QTDDES") * &(cPreFa6+"_DESVAL") //Desconto
     Else  
      AADD(aVetor,{"","",0,"","","","",0})
      aVetor[Len(aVetor),1] := GAA->GAA_CODGDE
      aVetor[Len(aVetor),2] := PADR(Posicione("GCS", 1, xFilial("GCS") + &(cPreFa6+"_CODLOC"), "GCS_NOMLOC"),30)
      aVetor[Len(aVetor),3] := HS_CValDes(cAFat6, &(cPreFa6+"_SEQDES") )
      aVetor[Len(aVetor),4] := Posicione("GAW", 1, xFilial("GAW") + GAA->GAA_CODGDE, "GAW_DESC")
      aVetor[Len(aVetor),5] := GCS->GCS_CODUNC
      aVetor[Len(aVetor),6] := Posicione("GCT", 1, xFilial("GCT") + GCS->GCS_CODUNC, "GCT_DESUNC")
      aVetor[Len(aVetor),7] := GCY->GCY_REGATE     
      aVetor[Len(aVetor),8] := &(cPreFa6+"_QTDDES") * &(cPreFa6+"_DESVAL") //Desconto
     EndIf
    EndIf
    dbselectArea(cArqOl2)
   Endif 
   DbSkip()   
  ENDDO
 EndIf
 
 DbSelectArea(cAFat7)
 DbSetOrder(2)
 If DbSeek(xFilial(cAFat7) + GCZ->GCZ_NRSEQG)
  DO WHILE !Eof() .AND. &(cPreFa7+"_FILIAL") == xFilial(cAFat7) .AND. &(cPreFa7+"_NRSEQG") = GCZ->GCZ_NRSEQG 
   If &(cPreFa7+"_GLODES")== "0" .AND.  &(cPreFa7+"_PGTMED") <> "0"
    cCodDes := &(cPreFa7+"_CODDES")
    cArqOl2 := Alias()
    DbSelectArea("GA7")
    DbSetOrder(1)
    If DbSeek(xFilial("GA7") + cCodDes )  
     DbSelectArea("GCS")
     DbSetOrder(1)
     DbSeek(xFilial("GCS") + &(cPreFa7+"_CODLOC") )                                            
     nPosVet := aScan(aVetor, {| aVetTmp | aVetTmp[5] == GCS->GCS_CODUNC .and. aVetTmp[1] == GA7->GA7_CODGDE } )
     If nPosVet > 0  
      aVetor[nPosVet,1] := GA7->GA7_CODGDE
      aVetor[nPosVet,2] := PADR(Posicione("GCS", 1, xFilial("GCS") + &(cPreFa7+"_CODLOC"), "GCS_NOMLOC"),30)
      aVetor[nPosVet,3] += HS_CValDes(cAFat7, &(cPreFa7+"_SEQDES") )
      aVetor[nPosVet,4] := Posicione("GAW", 1, xFilial("GAW") + GA7->GA7_CODGDE, "GAW_DESC")
      aVetor[nPosVet,5] := GCS->GCS_CODUNC
      aVetor[nPosVet,6] := Posicione("GCT", 1, xFilial("GCT") + GCS->GCS_CODUNC, "GCT_DESUNC")
      aVetor[nPosVet,7] := GCY->GCY_REGATE
      aVetor[nPosVet,8] += &(cPreFa7+"_QTDDES") * &(cPreFa7+"_DESVAL") //Desconto
     Else   
      AADD(aVetor,{"","",0,"","","","",0})
      aVetor[Len(aVetor),1] := GA7->GA7_CODGDE
      aVetor[Len(aVetor),2] := PADR(Posicione("GCS", 1, xFilial("GCS") + &(cPreFa7+"_CODLOC"), "GCS_NOMLOC"),30)
      aVetor[Len(aVetor),3] := HS_CValDes(cAFat7, &(cPreFa7+"_SEQDES") )
      aVetor[Len(aVetor),4] := Posicione("GAW", 1, xFilial("GAW") + GA7->GA7_CODGDE, "GAW_DESC") 
      aVetor[Len(aVetor),5] := GCS->GCS_CODUNC
      aVetor[Len(aVetor),6] := Posicione("GCT", 1, xFilial("GCT") + GCS->GCS_CODUNC, "GCT_DESUNC")
      aVetor[Len(aVetor),7] := GCY->GCY_REGATE
      aVetor[Len(aVetor),8] := &(cPreFa7+"_QTDDES") * &(cPreFa7+"_DESVAL") //Desconto
     EndIf
    EndIf
    dbselectArea(cArqOl2)
   Endif 
   DbSkip()
  ENDDO 
 EndIf
 dbselectArea(cArqOl1)

Return(Nil)

/******************************************************************************************************************/
Static Function FS_Impr()
 Local nCtaFor
 Local cGrupoD   := ""
 Local nSubTotal := 0
 Local nTotal    := 0
 Local cDESCUNC  := ""
 nLin++ 
          /*              	    			   1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
                  		     	 0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
 
 @ nLin,00 Psay STR0034 //"Descricao                                         Setor                                Valor R$     Desconto R$        -Total R$-"
 nLin += 2
 For nCtaFor := 1 to Len(aVetor)
  If cDESCUNC <> aVetor[nCtaFor,6]
   If !EMPTY(cDESCUNC)
    @ nLin,119 Psay nSubTotal PICTURE "@E 999,999,999.99"
    nSubTotal := 0
   EndIf 
   cDESCUNC := aVetor[nCtaFor,6]
   cGrupoD  := ""
   nLin ++
   @ nLin,00 Psay aVetor[nCtaFor,6]
   nLin ++
  EndIf  
  If cGrupoD <> aVetor[nCtaFor,4]
   If !EMPTY(cGrupoD)
     @ nLin,119 Psay nSubTotal PICTURE "@E 999,999,999.99"
     nSubTotal := 0
     nLin++
   EndIf
   @ nLin,05 Psay aVetor[nCtaFor,4]
   cGrupoD := aVetor[nCtaFor,4]
  EndIf  
  @ nLin,50  Psay aVetor[nctaFor,2]
  @ nLin,85  Psay aVetor[nCtaFor,3] + aVetor[nCtaFor,8] PICTURE "@E 999,999,999.99"
  @ nLin,101 Psay aVetor[nCtaFor,8] PICTURE "@E 999,999,999.99"
  nSubTotal := nSubTotal + aVetor[nCtaFor,3]
  nTotal    := nTotal + aVetor[nCtaFor,3] 
  nLin++
 Next 
 @ nLin,119 Psay nSubTotal PICTURE "@E 999,999,999.99"
 nLin+=2
 @ nLin,119 Psay STR0028 //"----------"
 nLin++
 @ nLin,060 Psay STR0029 //"T o t a l   d a   F a t u r a ===> "
 @ nLin,119 Psay nTotal PICTURE "@E 999,999,999.99"
 nLin++
 @ nLin,005 Psay "("+Extenso(nTotal,.F.,1 )+" )" 
 
 nLin := nMaxLin * 2
 aVetor:={}  
 cDESCUNC := "" 
 cGrupoD  := ""
 
 
  
Return(Nil)

/*****************************************************************************************************************/  
Static Function FS_CabEmp(nLin)

 Cabec(cTitulo,cCabec1,cCabec2,NomeProg,Tamanho,nTipo) 
 @ 06,00 Psay SM0->M0_NOMECOM
 @ 07,00 Psay SM0->M0_ENDENT+" "+SM0->M0_BAIRENT
 @ 08,00 Psay SM0->M0_CIDENT+" - "+SM0->M0_ESTENT+STR0030+SM0->M0_CEPENT      //" CEP: "
 @ 09,00 Psay SM0->M0_CGC
 @ 10,00 Psay STR0031+SM0->M0_TEL+STR0032+SM0->M0_FAX //"Fone: "###"  Fax: "
 @ 11,00 Psay Eval(bRepli)
 
Return(nLin)

Static Function FS_ImpGraf(cAFat5, cAFat6, cAFat7)

 Private m_Pag      := 1

 Private nPagHeigth := 3100  
 Private nPagLength := 2300// Rela็ใo Matricial Grแfico ("M") = 2300/132

 Private nLin       := 0
 Private nMargX     := 50
 Private nColIni    := nMargX
 Private nColFim    := nPagLength - nMargX

 oPrn:StartPage()
 
 FS_GrfCapa()
 FS_Pre(cAFat5, cAFat6, cAFat7)
 FS_GrfImpr()

 oPrn:EndPage()
 
Return Nil

Static Function FS_GrfCapa()
 Local aArea   := GetArea()
 
 Local oCapFont1 := TFont():New("Courier New", 13, 11,, .T.,,,,,.F.) //cTitulos dos Relat๓rio
 Local oCapFont2 := TFont():New("Courier New", 11, 09,, .F.,,,,,.F.) //Adendos Cabe็alho

 Local nEntreLin := 30
 
 Local nPosTit    := 0719
 Local nPosLeft   := 0000
 Local nPosCenter := 1167
 Local nPosRight  := 1725

 nLin := nPagHeigth + 1
 
 DbSelectArea("GBH")
 DbSetOrder(1)
 DbSeek(xFilial("GBH") + GCZ->GCZ_REGGER)
 
 DbSelectArea("GCY")
 DbSetOrder(1)
 DbSeek(xFilial("GCY") + GCZ->GCZ_REGATE)
 
 If nLin > nPagHeigth
   nLin := FS_GrfCab()
 EndIf  

 nLin += nEntreLin
 oPrn:Say(nLin, nMargX+nPosTit,STR0005 + GCZ->GCZ_NRFATU, oCapFont1, 100) //"F A T U R A     H O S P I T A L A R   "
 nLin += 2 * nEntreLin
 oPrn:Line(nLin, nColIni, nLin, nColFim)
 nLin += nEntreLin
 oPrn:Say(nLin, nMargX+nPosLeft,STR0006 + GCY->GCY_NOME, oCapFont2, 100)                  //"Nome..............: "
 oPrn:Say(nLin, nMargX+nPosCenter, STR0007 + DTOC(GBH->GBH_DTNASC), oCapFont2, 100)          //"Data de Nascimento: "
 If GBH->GBH_SEXO == "0"                                 //"Sexo .....: "
  oPrn:Say(nLin, nMargX+nPosRight, STR0008 + STR0036, oCapFont2, 100) //"Masculino"
 ElseIf GBH->GBH_SEXO == "1"  
  oPrn:Say(nLin, nMargX+nPosRight, STR0008 + STR0037, oCapFont2, 100) //"Feminino"
 EndIf  
 nLin += nEntreLin
 oPrn:Say(nLin, nMargX+nPosLeft, STR0038 + ALLTRIM(GCY->GCY_IDADE), oCapFont2, 100)    //"Idade.............: "
 nLin += nEntreLin
 oPrn:Say(nLin, nMargX+nPosLeft, STR0009 + GBH->GBH_END, oCapFont2, 100)                   //"Endereco .........: "
 oPrn:Say(nLin, nMargX+nPosCenter, STR0010 + GBH->GBH_NUM, oCapFont2, 100)                   //"Numero ...........: "
 oPrn:Say(nLin, nMargX+nPosRight, STR0011 + GBH->GBH_BAIRRO, oCapFont2, 100)                //"Bairro ...: "
 nLin += nEntreLin
 oPrn:Say(nLin, nMargX+nPosLeft, STR0012 + GBH->GBH_CEP +  " " + ALLTRIM(GBH->GBH_MUN) + " - " + GBH->GBH_EST, oCapFont2, 100)   //"Municipio ........: "
 nLin += nEntreLin
 oPrn:Say(nLin, nMargX+nPosLeft, STR0013 + GBH->GBH_TEL, oCapFont2, 100)                   //"Telefone .........: "
 oPrn:Say(nLin, nMargX+nPosCenter, STR0014 + GBH->GBH_CPF, oCapFont2, 100)                   //"C.P.F. ...........: "
 oPrn:Say(nLin, nMargX+nPosRight, STR0015 + GBH->GBH_RG, oCapFont2, 100)                    //"Identidade: "
 nLin += nEntreLin
 oPrn:Say(nLin, nMargX+nPosLeft, STR0016 + Posicione("GFD",1,xFilial("GFD")+GCY->GCY_CODRES, "GFD_NOME"), oCapFont2, 100)  //"Responsavel ......: "
 nLin += nEntreLin
 oPrn:Say(nLin, nMargX+nPosLeft, STR0017 + GCZ->GCZ_REGGER, oCapFont2, 100)                //"PRONTUARIO .......: "
 nLin += 2 * nEntreLin
 oPrn:Line(nLin, nColIni, nLin, nColFim)
 nLin += nEntreLin

 oPrn:Say(nLin, nMargX+nPosLeft, STR0018 + POSICIONE("GA9", 1, xFilial("GA9") + GCZ->GCZ_CODCON, "GA9_NOME"), oCapFont2, 100) //"Convenio .........: "
 oPrn:Say(nLin, nMargX+nPosCenter, STR0019 + POSICIONE("GCM", 2, xFilial("GCM") + GCZ->GCZ_CODPLA, "GCM_DESPLA"), oCapFont2, 100) //"Plano ............: "
 nLin += nEntreLin
 oPrn:Say(nLin, nMargX+nPosLeft, STR0020 + GCZ->GCZ_NRSEQG, oCapFont2, 100) //"Guia .............: "
 oPrn:Say(nLin, nMargX+nPosCenter, STR0021 + GCZ->GCZ_REGATE, oCapFont2, 100) //"Atendimento ......: "
 oPrn:Say(nLin, nMargX+nPosRight, STR0022 + GCY->GCY_CIDALT, oCapFont2, 100) //"CID ......: "
 nLin += nEntreLin
 oPrn:Say(nLin, nMargX+nPosLeft,STR0023 + Posicione("GAV",1,xFilial("GAV")+GCY->GCY_REGATE,"GAV_LEITO"), oCapFont2, 100) //"LEITO ............: "
 nLin += nEntreLin
 oPrn:Say(nLin, nMargX+nPosLeft,STR0024 + DTOC(GCY->GCY_DATATE), oCapFont2, 100) //"Data da Entrada ..: "
 oPrn:Say(nLin, nMargX+nPosCenter, STR0025 + GCY->GCY_HORATE, oCapFont2, 100) //"Hora da Entrada ..: "
 nLin += nEntreLin
 oPrn:Say(nLin, nMargX+nPosLeft,STR0026 + DTOC(GCY->GCY_DATALT), oCapFont2, 100) //"Data da Saida ....: "
 oPrn:Say(nLin, nMargX+nPosCenter, STR0027 + GCY->GCY_HORALT, oCapFont2, 100) //"Hora da Saida ....: "
 nLin += nEntreLin
 oPrn:Say(nLin, nMargX+nPosLeft, STR0039 + ALLTRIM(STR(GCZ->GCZ_CTAPAR,2)), oCapFont2, 100) //"Nr.Fechamento.....: "
 oPrn:Say(nLin, nMargX+nPosCenter, STR0040 + DTOC(GCZ->GCZ_DCPARI), oCapFont2, 100) //"Data Inic. Fech...: "
 oPrn:Say(nLin, nMargX+nPosRight, STR0041 + Dtoc(IIF(((EMPTY(GCY->GCY_DATALT).or.GCY->GCY_DATALT>GCZ->GCZ_DCPARF).AND.GCZ->GCZ_CTAPAR<>nMaxConta ), GCZ->GCZ_DCPARF, GCY->GCY_DATALT    )) , oCapFont2, 100) //"Dt.Fin.Fe.: "
 nLin += 2 * nEntreLin
 oPrn:Line(nLin, nColIni, nLin, nColFim)
 nLin += nEntreLin

 RestArea(aArea)
Return()

Static Function FS_GrfCab()
 Local oFontCab := TFont():New("Courier New", 13, 11,, .T.,,,,,.F.)
 Local nEntreLin := 40
 nLin := HS_CabGraf(oPrn, nPagLength, nomeprog, 1000, cTitulo)
 oPrn:Say(nLin, nMargX, SM0->M0_NOMECOM, oFontCab, 100)
 nLin +=  nEntreLin
 oPrn:Say(nLin, nMargX, SM0->M0_ENDENT+" "+SM0->M0_BAIRENT, oFontCab, 100)
 nLin +=  nEntreLin
 oPrn:Say(nLin, nMargX, SM0->M0_CIDENT+" - "+SM0->M0_ESTENT+STR0030+SM0->M0_CEPENT, oFontCab, 100)      //" CEP: "
 nLin +=  nEntreLin
 oPrn:Say(nLin, nMargX, SM0->M0_CGC, oFontCab, 100) 
 nLin +=  nEntreLin
 oPrn:Say(nLin, nMargX, STR0031+SM0->M0_TEL+STR0032+SM0->M0_FAX, oFontCab, 100) //"Fone: "###"  Fax: "
 nLin +=  2* nEntreLin
 oPrn:Line(nLin, nColIni, nLin, nColFim)
 
Return(nLin)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRD3  บAutor  ณMicrosiga           บ Data ณ  09/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_GrfImpr( )
 Local nCtaFor    := 0
 Local cGrupoD    := ""
 Local nSubTotal  := 0
 Local nTotal     := 0
 Local cDESCUNC   := ""
 
 Local nPosDescri := 0000 
 Local nPosGrupo  := 0082
 Local nPosSetor  := 0871
 Local nPosTotalF := 1045
 Local nPosValor  := 1481
 Local nPosValorT := 1516
 Local nPosDescoT := 1742
 Local nPosDescon := 1760
 Local nPosTotal  := 2030
 Local nPosExtens := 0390

 Local nEntreLin  := 30
 
 Local oFontCabec := TFont():New("Courier New", 09, 08,, .T.,,,,,.F.) //cTitulos dos Campos
 Local oFontTxt   := TFont():New("Courier New", 09, 08,, .F.,,,,,.F.) //cTitulos dos Campos

 //              	                 1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
 //        		     	   0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
 //                       "Descricao                                         Setor                                Valor R$     Desconto R$        -Total R$-"
 oPrn:Say(nLin, nMargX+nPosDescri, STR0044, oFontCabec, 100)  //"Descricao"
 oPrn:Say(nLin, nMargX+nPosSetor,  STR0045, oFontCabec, 100)  //"Setor"
 oPrn:Say(nLin, nMargX+nPosValorT, STR0046, oFontCabec, 100)  //"Valor R$"
 oPrn:Say(nLin, nMargX+nPosDescoT, STR0047, oFontCabec, 100)  //"Desconto R$"
 oPrn:Say(nLin, nMargX+nPosTotal,  STR0048, oFontCabec, 100)  //"-Total R$-"
 
 nLin += 2 * nEntreLin

 For nCtaFor := 1 to Len(aVetor)
  If cDESCUNC <> aVetor[nCtaFor,6]
   If !EMPTY(cDESCUNC)
    oPrn:Say(nLin, nMargX+nPosTotal, Transform(nSubTotal, "@E 999,999,999.99"), oFontTxt, 100)
    nSubTotal := 0
   EndIf 
   cDESCUNC := aVetor[nCtaFor,6]
   cGrupoD  := ""
   nLin += nEntreLin
   oPrn:Say(nLin, nMargX+nPosDescri, aVetor[nCtaFor,6], oFontTxt, 100)
   nLin += nEntreLin
  EndIf  
  If cGrupoD <> aVetor[nCtaFor,4]
   If !Empty(cGrupoD)
     oPrn:Say(nLin, nMargX+nPosTotal, Transform(nSubTotal,"@E 999,999,999.99"), oFontTxt, 100)
     nSubTotal := 0
     nLin += nEntreLin
   EndIf
   oPrn:Say(nLin, nMargX+nPosGrupo, aVetor[nCtaFor,4], oFontTxt, 100)
   cGrupoD := aVetor[nCtaFor,4]
  EndIf  

  oPrn:Say(nLin, nMargX+nPosSetor, aVetor[nctaFor,2], oFontTxt, 100)
  oPrn:Say(nLin, nMargX+nPosValor, Transform(aVetor[nCtaFor,3] + aVetor[nCtaFor,8], "@E 999,999,999.99"), oFontTxt, 100)
  oPrn:Say(nLin, nMargX+nPosDescon, Transform(aVetor[nCtaFor,8], "@E 999,999,999.99"), oFontTxt, 100)
  nSubTotal := nSubTotal + aVetor[nCtaFor,3]
  nTotal    := nTotal + aVetor[nCtaFor,3] 
  nLin += nEntreLin
 Next 
 oPrn:Say(nLin, nMargX+nPosTotal, Transform(nSubTotal,"@E 999,999,999.99"), oFontTxt, 100)
 nLin += 2*nEntreLin
 oPrn:Say(nLin, nMargX+nPosTotal, "__________", oFontTxt, 100)
 nLin += nEntreLin
 oPrn:Say(nLin, nMargX+nPosTotalF, STR0029, oFontTxt, 100) //"T o t a l   d a   F a t u r a ===> "
 oPrn:Say(nLin, nMargX+nPosTotal, Transform(nTotal, "@E 999,999,999.99"), oFontTxt, 100)
 nLin += nEntreLin
 oPrn:Say(nLin, nMargX+nPosExtens, PadL("("+AllTrim(Extenso(nTotal,.F.,1 ))+")", 104), oFontTxt, 100)

 
 nLin := nEntreLin * 2
 aVetor:={}  
 cDESCUNC := "" 
 cGrupoD  := ""
  
Return(Nil)


