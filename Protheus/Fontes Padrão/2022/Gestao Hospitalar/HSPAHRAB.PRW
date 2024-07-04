#INCLUDE "HSPAHRAB.ch"
#INCLUDE "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHRAB  º Autor ³ Alessandro Freire  º Data ³  19/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Auditoria de setores.                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HSPAHRAB()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := STR0003 //"Auditoria de Contas"
Local cPict          := ""
Local titulo         := STR0003 //"Auditoria de Contas"
Local nLin           := 80

Local Cabec1         := ""
Local Cabec2         := ""
Local imprime        := .T.
Local aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := "HSPAHRAB" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 15
Private aReturn      := { STR0004, 1, STR0005, 1, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cPerg        := "HSPRAB"
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHRAB" // Coloque aqui o nome do arquivo usado para impressao em disco

Private cString := "GD5"

Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

dbSelectArea("GD5")
dbSetOrder(1)

If !Pergunte(cPerg)
 Return()
Endif 

nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

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
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  19/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local cQry     := ""
Local cDataFim := DTOS( mv_par04 + IIF(mv_par05 > 10, 10, mv_par05-1) )
Local aDatas   := {}
Local aVetor   := {}
Local nI

/*
1- setor de
2- setor ate
3- itens - 1-Mat/Med 2-Taxas 3-Procedimentos 4-Todos
4- Data Inicial
5- Dias
*/

For nI := 1 to 11
	AAdd( aDatas, DtoS(mv_par04 + nI-1) )
Next nI

Cabec2 := STR0006 //"Item                                                        "
For nI := 1 to Len(aDatas)
	Cabec2 += "     "+SubStr(aDatas[nI],7,2)+"/"+SubStr(aDatas[ni],3,2)
Next nI
Cabec2 += STR0007 //"   Quantidade Vlr.Unitario  Valor Total"

If mv_par03 == 1 .or. mv_par03 == 4
	cQry += "SELECT GCS_CODLOC TRB_CODLOC, GCS_NOMLOC TRB_NOMLOC, GCY_REGGER TRB_REGGER, GCY_NOME TRB_NOME, "
	cQry +=        "GCZ_CODPLA TRB_CODPLA, GCM_DESPLA TRB_DESPLA, '1' TRB_TIPO, B1_DESC TRB_DESC, "
	cQry +=        "GD5_DATDES TRB_DATDES, GD5_QTDDES TRB_QTDDES, " + HS_FValDes("GD5") + " TRB_VALDES, "
	cQry +=        "GCY_QUAINT TRB_QUAINT, GCY_LEIINT TRB_LEIINT "
	
	cQry += "FROM " + RetSqlName("GD5") + " GD5 "
	cQry += "JOIN " + RetSqlName("GCZ") + " GCZ ON GD5_NRSEQG = GCZ_NRSEQG AND GD5_REGATE = GCZ_REGATE "
	cQry += "JOIN " + RetSqlName("GCS") + " GCS ON GCS_CODLOC = GD5_CODLOC "
	cQry += "JOIN " + RetSqlName("GCY") + " GCY ON GCZ_REGATE = GCY_REGATE "
	cQry += "JOIN " + RetSqlName("GCM") + " GCM ON GCM_CODPLA = GCZ_CODPLA AND GCM_CODCON = GCZ_CODCON "
	cQry += "JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = GD5_CODDES "
	
	cQry += "WHERE "
	cQry += "GD5_FILIAL = '" + xFilial("GD5") + "' AND "
	cQry += "GCS_FILIAL = '" + xFilial("GCS") + "' AND "
	cQry += "GCY_FILIAL = '" + xFilial("GCY") + "' AND "
	cQry += "GCZ_FILIAL = '" + xFilial("GCZ") + "' AND "
	cQry += "GCM_FILIAL = '" + xFilial("GCM") + "' AND "
	cQry += "B1_FILIAL  = '" + xFilial("SB1") + "' AND "
	
	cQry += "GD5.D_E_L_E_T_ <> '*' AND "
	cQry += "GCS.D_E_L_E_T_ <> '*' AND "
	cQry += "GCY.D_E_L_E_T_ <> '*' AND "
	cQry += "GCZ.D_E_L_E_T_ <> '*' AND "
	cQry += "GCM.D_E_L_E_T_ <> '*' AND "
	cQry += "SB1.D_E_L_E_T_ <> '*' AND "
	
	cQry += "GD5_CODLOC BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' AND "
	cQry += "GD5_DATDES BETWEEN '" + DTOS(mv_par04) + "' AND '" + cDataFim + "' "
	
	If mv_par03 == 4
		cQry += "UNION ALL "
	EndIf
Endif
                             
If mv_par03 == 2 .or. mv_par03 == 4
	cQry += "SELECT GCS_CODLOC TRB_CODLOC, GCS_NOMLOC TRB_NOMLOC, GCY_REGGER TRB_REGGER, GCY_NOME TRB_NOME, "
	cQry +=        "GCZ_CODPLA TRB_CODPLA, GCM_DESPLA TRB_DESPLA, '2'          TRB_TIPO, GAA_DESC TRB_DESC, "
	cQry +=        "GD6_DATDES TRB_DATDES, GD6_QTDDES TRB_QTDDES, " + HS_FValDes("GD6") + " TRB_VALDES, "	
	cQry +=        "GCY_QUAINT TRB_QUAINT, GCY_LEIINT TRB_LEIINT "
	
	cQry += "  FROM "+RetSqlName("GD6")+" GD6 "
	cQry += "              JOIN "+RetSqlName("GCZ")+" GCZ ON GD6_NRSEQG = GCZ_NRSEQG AND "
	cQry += "                                 GD6_REGATE = GCZ_REGATE "
	cQry += "              JOIN "+RetSqlName("GCS")+" GCS ON GCS_CODLOC = GD6_CODLOC "
	cQry += "              JOIN "+RetSqlName("GCY")+" GCY ON GCZ_REGATE = GCY_REGATE "
	cQry += "              JOIN "+RetSqlName("GCM")+" GCM ON GCM_CODPLA = GCZ_CODPLA AND GCM_CODCON = GCZ_CODCON "
	cQry += "              JOIN "+RetSqlName("GAA")+" GAA ON GAA_CODTXD = GD6_CODDES "
	
	cQry += "WHERE "
	cQry += "      GD6_FILIAL = '"+xFilial("GD6")+"' AND "
	cQry += "      GCS_FILIAL = '"+xFilial("GCS")+"' AND "
	cQry += "      GCY_FILIAL = '"+xFilial("GCY")+"' AND "
	cQry += "      GCZ_FILIAL = '"+xFilial("GCZ")+"' AND "
	cQry += "      GCM_FILIAL = '"+xFilial("GCM")+"' AND "
	cQry += "      GAA_FILIAL = '"+xFilial("GAA")+"' AND "
	
	cQry += "      GD6.D_E_L_E_T_ <> '*' AND "
	cQry += "      GCS.D_E_L_E_T_ <> '*' AND "
	cQry += "      GCY.D_E_L_E_T_ <> '*' AND "
	cQry += "      GCZ.D_E_L_E_T_ <> '*' AND "
	cQry += "      GCM.D_E_L_E_T_ <> '*' AND "
	cQry += "      GAA.D_E_L_E_T_ <> '*' AND "
	
	cQry += "      GD6_CODLOC BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' AND "
	cQry += "      GD6_DATDES BETWEEN '"+DTOS(mv_par04)+"' AND '"+cDataFim+"' "
	
	If mv_par03 == 4
		cQry += "UNION ALL "
	EndIf

EndIf

If mv_par03 == 3 .or. mv_par03 == 4
	cQry += "SELECT GCS_CODLOC TRB_CODLOC, GCS_NOMLOC TRB_NOMLOC, GCY_REGGER TRB_REGGER, GCY_NOME TRB_NOME, "
	cQry +=        "GCZ_CODPLA TRB_CODPLA, GCM_DESPLA TRB_DESPLA, '3'          TRB_TIPO, GA7_DESC TRB_DESC, "
	cQry +=        "GD7_DATDES TRB_DATDES, GD7_QTDDES TRB_QTDDES, " + HS_FValDes("GD7") + " TRB_VALDES, "
	cQry +=        "GCY_QUAINT TRB_QUAINT, GCY_LEIINT TRB_LEIINT "
	
	cQry += "  FROM "+RetSqlName("GD7")+" GD7 "
	cQry += "              JOIN "+RetSqlName("GCZ")+" GCZ ON GD7_NRSEQG = GCZ_NRSEQG AND "
	cQry += "                                 GD7_REGATE = GCZ_REGATE "
	cQry += "              JOIN "+RetSqlName("GCS")+" GCS ON GCS_CODLOC = GD7_CODLOC "
	cQry += "              JOIN "+RetSqlName("GCY")+" GCY ON GCZ_REGATE = GCY_REGATE "
	cQry += "              JOIN "+RetSqlName("GCM")+" GCM ON GCM_CODPLA = GCZ_CODPLA AND GCM_CODCON = GCZ_CODCON "
	cQry += "              JOIN "+RetSqlName("GA7")+" GA7 ON GA7_CODPRO = GD7_CODDES "
	
	cQry += "WHERE "
	cQry += "      GD7_FILIAL = '"+xFilial("GD7")+"' AND "
	cQry += "      GCS_FILIAL = '"+xFilial("GCS")+"' AND "
	cQry += "      GCY_FILIAL = '"+xFilial("GCY")+"' AND "
	cQry += "      GCZ_FILIAL = '"+xFilial("GCZ")+"' AND "
	cQry += "      GCM_FILIAL = '"+xFilial("GCM")+"' AND "
	cQry += "      GA7_FILIAL = '"+xFilial("GA7")+"' AND "
	
	cQry += "      GD7.D_E_L_E_T_ <> '*' AND "
	cQry += "      GCS.D_E_L_E_T_ <> '*' AND "
	cQry += "      GCY.D_E_L_E_T_ <> '*' AND "
	cQry += "      GCZ.D_E_L_E_T_ <> '*' AND "
	cQry += "      GCM.D_E_L_E_T_ <> '*' AND "
	cQry += "      GA7.D_E_L_E_T_ <> '*' AND "
	
	cQry += "      GD7_CODLOC BETWEEN '"+mv_par01+"' AND  '"+mv_par02+"' AND "
	cQry += "      GD7_DATDES BETWEEN '"+DTOS(mv_par04)+"' AND '"+cDataFim+"' "
EndIf

cQry += "ORDER BY TRB_CODLOC,TRB_NOME, TRB_REGGER, TRB_TIPO, TRB_DESC"

cQry := ChangeQuery(cQry)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRB",.T.,.T.)

SetRegua(RecCount())

dbGoTop()

While !EOF()
	
	
	If lAbortPrint
		@nLin,00 PSAY STR0008 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	cSetor  := TRB->TRB_CODLOC
	cNomLoc := TRB->TRB_NOMLOC
	cRegGer := TRB->TRB_REGGER
	cTipo   := TRB->TRB_TIPO
	cDesc   := TRB->TRB_DESC
	cCodPla := TRB->TRB_CODPLA
	cDesPla := TRB->TRB_DESPLA
	cQuarto := TRB->TRB_QUAINT
	cLeito  := TRB->TRB_LEIINT
	cNome   := TRB->TRB_NOME
	aVetor  := {cDesc,; // descricao 1
	0,; //02 - valor na data 1
	0,; //03 - valor na data 2
	0,; //04 - valor na data 3
	0,; //05 - valor na data 4
	0,; //06 - valor na data 5
	0,; //07 - valor na data 6
	0,; //08 - valor na data 7
	0,; //09 - valor na data 8
	0,; //10 - valor na data 9
	0,; //11 - valor na data 10
	0,; //12 - valor na data 11
	0,; //13 - quantidade total
	0,; //14 - valor unitario
	0 } //15 - valor total
	
	
	While ! Eof() .and. TRB->TRB_CODLOC == cSetor  .and. ;
		TRB->TRB_REGGER == cRegGer .and. ;
		TRB->TRB_TIPO   == cTipo   .and. ;
		TRB->TRB_DESC   == cDesc
		
		nPos := aScan( aDatas, {|x| x = TRB->TRB_DATDES } )
		
		aVetor[nPos+1] += TRB->TRB_QTDDES             // QUANTIDADE NO DIA
		aVetor[13]     += TRB->TRB_QTDDES             // QUANTIDADE NO PERIODO
		aVetor[15]     += TRB->TRB_VALDES             // VALOR TOTAL
		dbSkip()
	Enddo
	aVetor[14]     := Round( aVetor[15]/aVetor[13],2 )
//	aVetor[15] := aVetor[14] * aVetor[13]
	
	If nLin > nMaxLin
		Cabec1 := STR0009 + cSetor + "-" //"Setor: "
		Cabec1 += cNomLoc
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin     := 9
		lImpCab1 := .t.
		lImpCab2 := .t.
	Endif
	
	If lImpCab1
		Cabec1 := STR0010 + cRegGer + "-" + cNome //"Paciente: "
		Cabec1 += STR0011 + cCodPla + "-" //"Plano: "
		Cabec1 += cDesPla + " / "
		Cabec1 += STR0012 + cQuarto + "-" //"Quarto: "
		Cabec1 += STR0013 + cLeito //"Leito: "
		@ nLin,00 PSAY  Cabec1 
		nLin   += 1
		lImpCab1 := .f.
	EndIf
	
	If lImpCab2
		@ nLin,00 PSAY iif(cTipo == "1",STR0014, iif(cTipo == "2", STR0015, STR0016) ) //"Mat/Med"###"Taxas"###"Procedimentos"
		nLin ++
		lImpCab2 := .f.
	EndIf

	/*
                                                          	1         2         3        4         5         6           7        8         9        10        11
	"Item                                                   99/99     99/99     99/99     99/99     99/99     99/99     99/99     99/99     99/99     99/99     99/99   Quantidade Vlr.Unitario  Valor Total"
	 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    999.99    999.99    999.99    999.99    999.99    999.99    999.99    999.99    999.99    999.99    999.99    99.999.99    99.999.99   999.999.99
	 0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678
	 1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0
	                                                                                           1         1         1         1         1         1         1         1         1         1         2
	*/

	@ nLin,000 PSAY SubStr(aVetor[01],1,50)
	@ nLin,064 PSAY aVetor[02] PICTURE "@E 999.99"  
	@ nLin,074 PSAY aVetor[03] PICTURE "@E 999.99"  
	@ nLin,084 PSAY aVetor[04] PICTURE "@E 999.99"  
	@ nLin,094 PSAY aVetor[05] PICTURE "@E 999.99"  
	@ nLin,104 PSAY aVetor[06] PICTURE "@E 999.99"  
	@ nLin,114 PSAY aVetor[07] PICTURE "@E 999.99"  
	@ nLin,124 PSAY aVetor[08] PICTURE "@E 999.99"  
	@ nLin,134 PSAY aVetor[09] PICTURE "@E 999.99"  
	@ nLin,144 PSAY aVetor[10] PICTURE "@E 999.99"  
	@ nLin,154 PSAY aVetor[11] PICTURE "@E 999.99"  
	@ nLin,164 PSAY aVetor[12] PICTURE "@E 999.99"  
	@ nLin,174 PSAY aVetor[13] PICTURE "@E 99,999.99"
	@ nLin,187 PSAY aVetor[14] PICTURE "@E 99,999.99"
	@ nLin,199 PSAY aVetor[15] PICTURE "@E 999,999.99"
	nLin := nLin + 1

	If cSetor != TRB->TRB_CODLOC
		nLin := nMaxLin * 2
		lImpCab1 := .t.
		lImpCab2 := .t.
	EndIf
	
	If cRegGer != TRB->TRB_REGGER
	 @ nLin,00 PSAY Replicate("-",limite)
	 nLin     := nLin + 1
		lImpCab1 := .t.
		lImpCab2 := .t.
	EndIf

	If cTipo != TRB->TRB_TIPO .and. cRegGer == TRB->TRB_REGGER
		nLin     := nLin + 1
		lImpCab2 := .t.
	EndIf
Enddo
SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

DBSELECTAREA("TRB")
dbCloseArea()

Return
