#INCLUDE "HSPAHRD4.ch"
#include "protheus.ch"
#include "msgraphi.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NOVO2     º Autor ³ MARCELO JOSE       º Data ³  10/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ INDICADORES DE CONTROLE DE INFECCAO HOSPITALAR             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CCIH                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HSPAHRD4()

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := STR0003 //"INDICADORES DE CONTROLE DE INFECCAO HOSPITALAR."
Local cPict          := ""
Local titulo         := STR0003 //"INDICADORES DE CONTROLE DE INFECCAO HOSPITALAR."
Local nLin           := 80

Local Cabec1         := STR0004 //"INDICADORES                                    Total Altas  Total Notific.  Pac.Inf.Hosp.  Pac.Infectados  Obitos Infec.  Pac.Inf.Comunit.  Pac.Inf.Outro Hosp     %"
Local Cabec2         := ""
Local imprime        := .T.
Local aOrd           := {}       

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 80
Private tamanho      := "G"
Private nomeprog     := "HSPAHRD4" 
Private nTipo        := 18
Private aReturn      := { STR0005, 1, STR0006, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHRD4" 
Private cString      := "GCY"
Private cPerg        := "HSPRD4"
Private aVetor       := {}

Private nTotAlta     := 0
Private nTotNotif    := 0
Private nTotPacIH    := 0
Private nTotInfec    := 0 
Private nTotObtIn    := 0
Private nTotComun    := 0
Private nTotOutHo    := 0

Private nTaxNotif    := 0 /* notificacao */
Private nTaxInfHo    := 0 /* infeccao hospitalar */ 
Private nTaxDInfH    := 0 /* doentes com infeccao hospitalar */
Private nTaxMInfH    := 0 /* mortalidade por infeccao hospitalar */
Private nTaxLInfH    := 0 /* Letalidade por infeccao hospitalar */ 
Private nTaxInfeC    := 0 /* Infeccao comunitaria */
Private nTaxOutHo    := 0 /* Outros hospitais */ 

IniciaX1()

If !Pergunte(cPerg,.T.)
	return
EndIf

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
 Local bWhile    := {||!Eof()}, cArqOld, lPacInfec := .F.
 
 Private cAliasGCY := "RD4QRY"
 
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

    cArqOld := Alias()

    If (cAliasGCY)->GCY_OBTINF == "1"
     nTotObtIn++ /* OBITO POR INFECCAO (5)*/
    EndIF
      
    DbSelectArea("GEH")
    DbSetOrder(2)
    If DbSeek(xFilial("GEH") + (cAliasGCY)->GCY_REGATE )
     
     nTotNotif++ /* NOTIFICACAO (2)*/
    
     lPacInfec := .F. /* PACIENTES COM INFCCAO HOSPITALAR (4) - so pode um para contagem */
     
     DO WHILE !Eof() .AND. GEH->GEH_FILIAL == xFilial("GEH") .AND. GEH->GEH_REGATE = (cAliasGCY)->GCY_REGATE

      If GEH->GEH_TPINFE == "1"
       nTotComun++ /* PACIENTES COM INFECCAO COMUNITARIA (6)*/
      ElseIf GEH->GEH_TPINFE == "2"
       nTotPacIH++ /* PACIENTES COM INFECCAO HOSPITALAR (3) - so conta uma vez...*/
       If !lPacInfec 
        nTotInfec++ /* PACIENTES COM INFCCAO HOSPITALAR (4)*/
        lPacInfec := .T.
       EndIf
      ElseIf GEH->GEH_TPINFE == "3"
       nTotOutHo++ /* PACIENTES COM INFECCAO DE OUTRO HOSPITAL (7)*/
      EndIf
      
      DbSkip()
     ENDDO
    EndIf
    
    DbSelectArea(cArqOld)
   
    nTotAlta++

			 DbSkip()

	  EndDo

  EndIf

  DbSelectArea(cAliasGCY)
 	dbCloseArea()
  
  nTaxNotif := ( nTotNotif * 100 ) / nTotAlta    /* notificacao */
  nTaxInfHo := ( nTotPacIH * 100 ) / nTotNotif   /* infeccao hospitalar */ 
  nTaxDInfH := ( nTotInfec * 100 ) / nTotNotif   /* doentes com infeccao hospitalar */
  nTaxMInfH := ( nTotObtIn * 100 ) / nTotNotif   /* mortalidade por infeccao hospitalar */
  nTaxLInfH := ( nTotObtIn * 100 ) / nTotInfec   /* Letalidade por infeccao hospitalar */ 
  nTaxInfeC := ( nTotComun * 100 ) / nTotNotif   /* Infeccao comunitaria */
  nTaxOutHo := ( nTotOutHo * 100 ) / nTotNotif   /* Outros hospitais */ 

 	If MV_PAR03 == 2
   /* Monta vetor para o grafico carteziano */ 
   AADD(aVetor,{nTaxNotif,STR0007+AllTrim(STR(nTaxNotif,6,2))  } ) //"Notificacao "
   AADD(aVetor,{nTaxInfHo,STR0008+AllTrim(STR(nTaxInfHo,6,2))  } )  //"Infec.Hosp. "
   AADD(aVetor,{nTaxDInfH,STR0009+AllTrim(STR(nTaxDInfH,6,2)) } ) //"Doen.Inf.Hos "
   AADD(aVetor,{nTaxMInfH,STR0010+AllTrim(STR(nTaxMInfH,6,2))  } )  //"Mortalidade "
   AADD(aVetor,{nTaxLInfH,STR0011+AllTrim(STR(nTaxLInfH,6,2))   } )  //"Letalidade "
   AADD(aVetor,{nTaxInfeC,STR0012+AllTrim(STR(nTaxInfeC,6,2))  } ) //"Inf. Comun. "
   AADD(aVetor,{nTaxOutHo,STR0013+AllTrim(STR(nTaxOutHo,6,2))} )  //"Inf.Outr.Hosp."
   /* cria o objeto para contrucao do grafico */
   oGraf := hsGRAF():NEW(STR0014,STR0015 + DtoC(MV_PAR01) +" a " + DtoC(MV_PAR02), STR0016, "", STR0017, "", aVetor,1,1,0,0,2,20,6,6,25,20)  //"C.C.I.H. - INDICADORES DE CONTROLE DE INFECCAO HOSPITALAR"###"NO PERIODO DE "###"Percentuais (%)"###"TAXAS"
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
  
 Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                                                    
 @ 10, 00 Psay STR0018 //"Taxa de Notificacao"
 @ 10, 49 PSAY nTotAlta  picture "99999"     
 @ 10, 63 Psay nTotNotif picture "99999"
 @ 10,161 Psay nTaxNotif Picture "999.99"

 @ 12, 00 Psay STR0019 //"Taxa de Infeccao Hospitalar"
 @ 12, 63 Psay nTotNotif picture "99999"
 @ 12, 78 Psay nTotPacIH picture "99999"
 @ 12,161 Psay nTaxInfHo Picture "999.99"

 @ 14, 00 Psay STR0020 //"Taxa de Doentes com Infeccao Hospitalar"
 @ 14, 63 Psay nTotNotif picture "99999"
 @ 14, 95 Psay nTotInfec picture "99999"
 @ 14,161 Psay nTaxDInfH Picture "999.99"

 @ 16, 00 Psay STR0021 //"Taxa de Mortalidade por Infeccao Hospitalar"
 @ 16, 63 Psay nTotNotif picture "99999"
 @ 16,109 Psay nTotObtIn picture "99999"
 @ 16,161 Psay nTaxMInfH Picture "999.99"

 @ 18, 00 Psay STR0022 //"Taxa de Letalidade por Infeccao Hospitalar"
 @ 18, 95 Psay nTotInfec picture "99999"
 @ 18,109 Psay nTotObtIn picture "99999"
 @ 18,161 Psay nTaxLInfH Picture "999.99"

 @ 20, 00 Psay STR0023 //"Taxa de Infeccao Comunitaria"
 @ 20, 63 Psay nTotNotif picture "99999"
 @ 20,129 Psay nTotComun picture "99999"
 @ 20,161 Psay nTaxInfeC Picture "999.99"

 @ 22, 00 Psay STR0024  //"Taxa de Infeccao de Outros Hospitais"
 @ 22, 63 Psay nTotNotif picture "99999" 
 @ 22,145 Psay nTotOutHo picture "99999"
 @ 22,161 Psay nTaxOutHo Picture "999.99"

 @ 23, 00 Psay Replicate("_",228)  
 
 SET DEVICE TO SCREEN

 If aReturn[5]==1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif

 MS_FLUSH()

Return(NIL)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±  Nil  _ADVPLdecl  IniciaX1(Nil)    ===> Inicia arquivo SX1              ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IniciaX1()

 Local aHelpPor := {}
 Local aHelpSpa := {}
 Local aHelpEng := {}
 Local aRegs    := {}

 _sAlias := Alias()
 dbSelectArea("SX1")

 If DbSeek(cPerg) 
	 DbSelectArea(_sAlias)
	 Return
 Endif

 AADD(aHelpPor,STR0025) //"Informe a data da Alta INICIAL para"
 AADD(aHelpPor,STR0026) //"a pesquisa do periodo...											"
 AADD(aHelpSpa,"                                   ")
 AADD(aHelpSpa,"              																					")
 AADD(aHelpEng,"                                   ")
 AADD(aHelpEng,"                                   ")
 AADD(aRegs,{STR0027,STR0027,STR0027,"mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","",; //"Da Data"###"Da Data"###"Da Data"
 "","","","","","","","","","","","","","","","N","","",aHelpPor,aHelpSpa,aHelpEng})

 aHelpPor := {}
 aHelpSpa := {}
 aHelpEng := {}
 AADD(aHelpPor,STR0028) //"Informe a data da Alta FINAL para  "
 AADD(aHelpPor,STR0026) //"a pesquisa do periodo...											"
 AADD(aHelpSpa,"                                   ")
 AADD(aHelpSpa,"              																					")
 AADD(aHelpEng,"                                   ")
 AADD(aHelpEng,"                                   ")
 AADD(aRegs,{STR0029,STR0029,STR0029,"mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","",; //"Ate a Data"###"Ate a Data"###"Ate a Data"
 "","","","","","","","","","","","","","","","N","","",aHelpPor,aHelpSpa,aHelpEng})

 aHelpPor := {}
 aHelpSpa := {}
 aHelpEng := {}
 AADD(aHelpPor,STR0030) //"Visualiza Grafico Carteziano antes "
 AADD(aHelpPor,STR0031) //"da Impressao do relatorio?									"
 AADD(aHelpSpa,"                                   ")
 AADD(aHelpSpa,"              																					")
 AADD(aHelpEng,"                                   ")
 AADD(aHelpEng,"                                   ")
 AADD(aRegs,{STR0032,STR0032,STR0032,"mv_ch3","N",01,0,0,"C","","mv_par03",STR0033,"","","","",STR0034,"","","","",; //"Visualiza Grafico"###"Visualiza Grafico"###"Visualiza Grafico"###"Nao"###"Sim"
 "","","","","","","","","","","","","","","","N","","",aHelpPor,aHelpSpa,aHelpEng})

 AjustaSx1(cPerg, aRegs)
 dbSelectArea(_sAlias)
Return(Nil)
//******************************************************************************************************************
