#INCLUDE "HSPAHR41.ch"
#Include "protheus.ch"
#include "TopConn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR41 บ Autor ณ Mario Arizono        บ Data ณ 17/08/07  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Faturamento Bruto por M้dicos                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR41()
/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ Declaracao de Variaveis                                             ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""
Local titulo         := ""
Local nLin           := 80 
Local Cabec1         := STR0003 //"Conv๊nio"
Local Cabec2         := ""
Local imprime        := .T.
Local aOrd 				      := {}   
Local aMeses         := {STR0004,STR0005,STR0006,STR0007,STR0008,STR0009,STR0010,STR0011,STR0012,STR0013,STR0014,STR0015} //"Jan"###"Fev"###"Mar"###"Abr"###"Mai"###"Jun"###"Jul"###"Ago"###"Set"###"Out"###"Nov"###"Dez"

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 80
Private tamanho      := "P"
Private nomeprog     := "HSPAHR41" /* Coloque aqui o nome do programa para impressao no cabecalho */
Private nTipo        := 18
Private aReturn      := {STR0016 , 1, STR0017, 2, 2, 1, "", 1}      //"Administracao"###"Zebrado"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHR41" /* Coloque aqui o nome do arquivo usado para impressao em disco */
Private cPerg        := PADR("HSPR41", Len(SX1->X1_GRUPO))
Private cString  := ""

Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao
Private oTempTRB

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ PARAMETROS                                                       ณ
 ณ MV_PAR01	Do Setor                                                ณ
 ณ MV_PAR02	Ate o Setor                                             ณ
 ณ MV_PAR03	Da Data                                                 ณ
 ณ MV_PAR04	Ate a Data                                              ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

If !Pergunte(cPerg,.T.)
	return
EndIf

cFilTab   := MV_PAR01
cMesARef  := MV_PAR02
nEmitPro  := MV_PAR03
cCodConv  := MV_PAR04
nConsRec  := MV_PAR05 

If Empty(substr(cMesARef,1,2)) .or. Empty(substr(cMesARef,4,2) )
	HS_MsgInf(STR0031, STR0022, STR0032) //"O parโmetro M๊s Ano Refer๊ncia nใo estแ preenchido, favor preench๊-lo."###"Aten็ใo"###"Valida็ใo Parโmetro"
	Return
EndIf
nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2

If nEmitPro == 1     

/*              	    			   1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
          	      0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
	Cabec2 :=      STR0018 //"M้dico                         Procedimento                  Qtde.          Valor"
else
	Cabec2 :=      STR0019 //"M้dico                                                                      Valor"
endif

titulo := STR0027 + " " + aMeses[val(substr(cMesARef,1,2))] + "/" + substr(cMesARef,4,2)//"Fat. Bruto-M้dicos"

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
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Mario Arizono      บ Data ณ  17/08/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local cSQL 	   := "" 
Local cCodCon  := "", cCodCrm := ""      
Local nVlrMed  := 0, nVlrTot := 0
Local nRegistro:= 0
Local cFilialTmp := ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Tabela Temporแria de Trabalho ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCampos:={	{"FILIAL"   , "C" , FWGETTAMFILIAL,0},;
{"CODCRM"   , "C" , 006,0},;
{"CODCON"   , "C" , 003,0},;
{"VALOR"    , "N" , 012,2},;
{"NOMMED"   , "C" , 030,0},;
{"NOMCON"   , "C" , 020,0},;
{"CODDES"   , "C" , 009,0},;
{"QTDDES"   , "N" , 010,4},;
{"DESGA7"   , "C" , 050,2}}

//--< Cria็ใo do objeto FWTemporaryTable >---
oTempTRB := FWTemporaryTable():New( "cArqTmp" )
oTempTRB:SetFields( aCampos )
oTempTRB:AddIndex( "INDTRB",{ "FILIAL","CODCON","CODCRM","CODDES" } )

if( select( "cArqTmp" ) > 0 )
	cArqTmp->( dbCloseArea() )
endIf

oTempTRB:Create()

DbSelectArea("SM0")
If !Empty(cFilTab)
	nRegistro := Recno()
	DbGoTop()
endif
While !eof()
                         
	// Emite Procedimentos
 If nEmitPro == 1
  cSQL := "SELECT GE7.GE7_FILIAL FILIAL,GE7.GE7_CODCRM CODCRM, GE7.GE7_CODCON CODCON, GE7.GE7_CODDES CODDES, SUM(GE7.GE7_QTDDES) QTDDES, SUM(GE7.GE7_VALDES) VALOR, "
  cSQL += "SRA.RA_NOME NOMMED, "
  cSQL += "GA9.GA9_NREDUZ NOMCON,"
  cSQL += "GA7.GA7_DESC DESGA7 "
 Else 
  cSQL := "SELECT GE7.GE7_FILIAL FILIAL,GE7.GE7_CODCRM CODCRM, GE7.GE7_CODCON CODCON, SUM(GE7.GE7_VALDES) VALOR, "
  cSQL += "SRA.RA_NOME NOMMED, "
  cSQL += "GA9.GA9_NREDUZ NOMCON"
 Endif
 
 cSQL += " FROM " + RetSQLName("GAT") + " GAT"                                   
 cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRLOTE = GAT.GAT_NUMLOT AND GCZ.GCZ_CODCON = GAT.GAT_CODCON AND GCZ.D_E_L_E_T_ <> '*' " 
	If !Empty(cFilTab)
		cSQL += " AND GCZ.GCZ_FILIAL = '" + IIF(Empty(xFilial("GCZ")), xFilial("GCZ"), cFilTab)  + "' "
	Else
		cSQL += " AND GCZ.GCZ_FILIAL = '" + IIF(Empty(xFilial("GCZ")), xFilial("GCZ"), IIF(FindFunction("FWCodFil"),FWGETCODFILIAL,SM0->M0_CODFIL))  + "' "
	Endif
 cSQL += " AND GCZ.GCZ_STATUS >= '4' " 
 
	// Considera Recebimento
 If nConsRec == 1
  cSQL += " JOIN " + RetSQLName("GF7") + " GF7 ON GF7.GF7_NREXTC = GCZ.GCZ_NREXTC AND GF7.GF7_NRSEQG = GCZ.GCZ_NRSEQG AND GF7.D_E_L_E_T_ <> '*' " 

		If !Empty(cFilTab)
			cSQL += " AND GF7.GF7_FILIAL = '" + IIF(Empty(xFilial("GF7")), xFilial("GF7"), cFilTab)  + "' "
		Else
			cSQL += " AND GF7.GF7_FILIAL = '" + IIF(Empty(xFilial("GF7")), xFilial("GF7"), IIF(FindFunction("FWCodFil"),FWGETCODFILIAL,SM0->M0_CODFIL))  + "' "
		Endif
	
  cSQL += " JOIN " + RetSQLName("GE7") + " GE7 ON GE7.GE7_NRSEQG = GF7.GF7_NRSEQG AND GE7.D_E_L_E_T_ <> '*' " 
		If !Empty(cFilTab)
			cSQL += " AND GE7.GE7_FILIAL = '" + IIF(Empty(xFilial("GE7")), xFilial("GE7"), cFilTab)  + "' "
		Else
			cSQL += " AND GE7.GE7_FILIAL = '" + IIF(Empty(xFilial("GE7")), xFilial("GE7"), IIF(FindFunction("FWCodFil"),FWGETCODFILIAL,SM0->M0_CODFIL))  + "' "
		Endif

 Else
  cSQL += " JOIN " + RetSQLName("GE7") + " GE7 ON GE7.GE7_NRSEQG = GCZ.GCZ_NRSEQG AND GE7.D_E_L_E_T_ <> '*' " 

		If !Empty(cFilTab)
			cSQL += " AND GE7.GE7_FILIAL = '" + IIF(Empty(xFilial("GE7")), xFilial("GE7"), cFilTab)  + "' "
		Else
			cSQL += " AND GE7.GE7_FILIAL = '" + IIF(Empty(xFilial("GE7")), xFilial("GE7"), IIF(FindFunction("FWCodFil"),FWGETCODFILIAL,SM0->M0_CODFIL))  + "' "
		Endif

 Endif
 
 cSQL += " JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO  = GE7.GE7_CODCRM AND SRA.D_E_L_E_T_ <> '*' " 

		If !Empty(cFilTab)
			cSQL += " AND SRA.RA_FILIAL = '" + IIF(Empty(xFilial("SRA")), xFilial("SRA"), cFilTab)  + "' "
		Else
			cSQL += " AND SRA.RA_FILIAL = '" + IIF(Empty(xFilial("SRA")), xFilial("SRA"), IIF(FindFunction("FWCodFil"),FWGETCODFILIAL,SM0->M0_CODFIL))  + "' "
		Endif


 cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GE7.GE7_CODCON AND GA9.D_E_L_E_T_ <> '*' "    

		If !Empty(cFilTab)
			cSQL += " AND GA9.GA9_FILIAL = '" + IIF(Empty(xFilial("GA9")), xFilial("GA9"), cFilTab)  + "' "
		Else
			cSQL += " AND GA9.GA9_FILIAL = '" + IIF(Empty(xFilial("GA9")), xFilial("GA9"), IIF(FindFunction("FWCodFil"),FWGETCODFILIAL,SM0->M0_CODFIL))  + "' "
		Endif

 cSQL += " JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GE7.GE7_CODDES AND GA7.D_E_L_E_T_ <> '*' "    

		If !Empty(cFilTab)
			cSQL += " AND GA7.GA7_FILIAL = '" + IIF(Empty(xFilial("GA7")), xFilial("GA7"), cFilTab)  + "' "
		Else
			cSQL += " AND GA7.GA7_FILIAL = '" + IIF(Empty(xFilial("GA7")), xFilial("GA7"), IIF(FindFunction("FWCodFil"),FWGETCODFILIAL,SM0->M0_CODFIL))  + "' "
		Endif
 
 cSQL += " WHERE GAT.D_E_L_E_T_ <> '*'"
 cSQL += " AND GAT.GAT_MESREF = '" + cMesARef + "' "
 cSQL += " AND GAT.GAT_CODCON = '" + cCodConv + "' "

	If !Empty(cFilTab)
		cSQL += " AND GAT.GAT_FILIAL = '" + IIF(Empty(xFilial("GAT")), xFilial("GAT"), cFilTab)  + "' "
	Else
		cSQL += " AND GAT.GAT_FILIAL = '" + IIF(Empty(xFilial("GAT")), xFilial("GAT"), IIF(FindFunction("FWCodFil"),FWGETCODFILIAL,SM0->M0_CODFIL))  + "' "
	Endif
 
 If nEmitPro == 1 
		cSQL += " GROUP BY GE7.GE7_FILIAL,GE7.GE7_CODCRM, GE7.GE7_CODCON, GE7.GE7_CODDES, SRA.RA_NOME, GA9.GA9_NREDUZ, GA7.GA7_DESC"
 Else
  cSQL += " GROUP BY GE7.GE7_FILIAL,GE7.GE7_CODCRM, GE7.GE7_CODCON, SRA.RA_NOME, GA9.GA9_NREDUZ "
 Endif
 cSQL :=  ChangeQuery(cSQL)


 TCQUERY cSQL NEW ALIAS "QRY"
	DbSelectArea("QRY")
	DbGoTop()
	// Preenche o arquivo temporario com os dados da filial
	While !EOF()
		DbSelectArea("cArqTmp")
		RecLock("cArqTmp",.T.)
		cArqTmp->FILIAL   := IIF(!Empty(cFilTab), cFilTab, IIF(FindFunction("FWCodFil"),FWGETCODFILIAL,SM0->M0_CODFIL))
		cArqTmp->CODCRM   := 	QRY->CODCRM
		cArqTmp->CODCON   := 	QRY->CODCON
		cArqTmp->VALOR    := 	QRY->VALOR
		cArqTmp->NOMMED   := 	QRY->NOMMED
		cArqTmp->NOMCON   := 	QRY->NOMCON
	 If nEmitPro == 1
			cArqTmp->CODDES   := 	QRY->CODDES
			cArqTmp->QTDDES   := 	QRY->QTDDES
			cArqTmp->DESGA7   := 	QRY->DESGA7
		Endif
		MSUNLOCK()
		DbSelectArea("QRY")
		DbSkip()
	End
	QRY->(DbCloseArea())
	If !Empty(cFilTab)
		Exit // Sai se for selecionada a filial
	Endif
	DbSelectArea("SM0")
	dbSkip() // Pega a pr๓xima Filial
End

// Recupera posi็ใo do registro de Filial
DbSelectArea("SM0")
If !Empty(cFilTab)
	DbGoTo(nRegistro)
endif
                                

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

 SetRegua(100)
	dbSelectArea("cArqTmp")   
	dbgotop()
 If Eof()
  HS_MsgInf(STR0021, STR0022, STR0023) //"Nenhum dado foi encontrado para a selecao efetuada!"###"Aten็ใo"###"Valida็ใo relat๓rio faturamento bruto por m้dicos"
 Endif
	cFilialTmp := cArqTmp->FILIAL
	nValorFil := 0
 While !EOF()

	 IncRegua()
   
   If lAbortPrint
      @nLin,00 PSAY STR0024 //"*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif
   
   If nLin > nMaxLin
				Cabec(alltrim(titulo)+" (Fil: "+cArqTmp->FILIAL+")",Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
    nLin := 9
   Endif
 
			// Imprime o Conv๊nio
   If cCodCon <> cArqTmp->CODCON
    @nLin,000 PSAY cArqTmp->NOMCON 
    nLin++
   Endif

			// Se trocar de m้dico
   If cCodCrm <> cArqTmp->CODCRM  
    nLin++
    If nEmitPro == 1 
     If !Empty(cCodCrm)
      @nLin,000 PSAY STR0025 //"Total do M้dico"
      @nLin,067 PSAY TRANSFORM(nVlrMed, "@E 999,999,999.99")
      nVlrMed := 0
      nLin+=2
     Endif
     @nLin,000 PSAY SUBSTR(cArqTmp->NOMMED,1,30)
     @nLin,031 PSAY SUBSTR(cArqTmp->DESGA7,1,29)
     @nLin,061 PSAY TRANSFORM(cArqTmp->QTDDES, "99999")
    Else
     @nLin,000 PSAY SUBSTR(cArqTmp->NOMMED,1,30)
    Endif   
   Else
    nLin++
    If nEmitPro == 1 
	    @nLin,031 PSAY SUBSTR(cArqTmp->DESGA7,1,29)
	    @nLin,061 PSAY TRANSFORM(cArqTmp->QTDDES, "99999")
	   Endif
   EndIf
                              
   @nLin,067 PSAY TRANSFORM(cArqTmp->VALOR, "@E 999,999,999.99")
   
			nValorFil += cArqTmp->VALOR
   nVlrMed   += cArqTmp->VALOR
   nVlrTot   += cArqTmp->VALOR 
     
   cCodCon := cArqTmp->CODCON
   cCodCrm := cArqTmp->CODCRM
   
   dbSkip() /* Avanca o ponteiro do registro no arquivo */  
   
   // Quando trocar de filial
			If cFilialTmp <> cArqTmp->FILIAL
			 If nEmitPro == 1
			  nLin++  
			  @nLin,000 PSAY STR0025 //"Total do M้dico"
			  @nLin,067 PSAY TRANSFORM(nVlrMed, "@E 999,999,999.99")
			 Endif 
			 nLin++
			 @ nLin, 000 PSAY REPLICATE("-", 81)
			 nLin++   
			 @nLin,000 PSAY STR0028 + "(" + STR0029 + cFilialTmp+")" //"Total Mensal "##"Filial: "
			 @nLin,067 PSAY TRANSFORM(nValorFil, "@E 999,999,999.99")
				If EOF() .AND. Empty(cFilTab)
				 nLin++
				 @ nLin, 000 PSAY REPLICATE("-", 81)
				 nLin++   
				 @nLin,000 PSAY STR0030 //"Total Mensal Geral"
				 @nLin,067 PSAY TRANSFORM(nVlrTot, "@E 999,999,999.99")
				 nLin++
				 @ nLin, 000 PSAY REPLICATE("-", 81)
				Endif
				nValorFil := 0
				nLin += nMaxLin // For็a ejetar pแgina           
				cFilialTmp := cArqTmp->FILIAL
			Endif
 EndDo
                                                                                

/*
		ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ Finaliza a execucao do relatorio...                                 ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

SET DEVICE TO SCREEN

/*
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ Se impressao em disco, chama o gerenciador de impressao...          ณ                                           	
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

if( select( "cArqTmp" ) > 0 )
 	oTempTRB:Delete()
endIf

Return  