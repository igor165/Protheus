#INCLUDE "hspahr72.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณHSPAHR72  บ Autor ณ Mario Arizono      บ Data ณ  01/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio que imprime o protocolo para saidas multiplas.   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SPP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

FUNCTION HSPAHR72(cProgCh, cLote)                                                
 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir relatorio"
Local cDesc2 := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3 := ""
Local cPict := ""
Local titulo := "SPP"
Local nLin := 80
Local Cabec1 := ""
Local Cabec2 := ""
Local imprime := .T.
Local aOrd := {}

Default cProgCh := ""
Default cLote   := ""  
Private lEnd := .F.
Private lAbortPrint := .F.
Private limite := 80
Private tamanho := "M"
Private nomeprog := "HSPAHR72" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo := 18
Private aReturn := {STR0003, 1, STR0004 , 2, 2, 1, "", 1}  //"Zebrado"###"Administracao"
Private nLastKey := 0
Private cbtxt := Space(10)
Private cbcont := 00
Private CONTFL := 01
Private m_pag := 01
Private wnrel := "HSPAHR72" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cCodLote := ""
Private cCodImp := ""
Private nMaxLin := 0
Private cString := "GSA"
Private lChamado := !Empty(cProgCh)

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ PARAMETROS                                                       ณ
ณ MV_PAR01	Protocolo ?                                             ณ
ณ MV_PAR02	Impressora                                              ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/

If !lChamado
 Pergunte("HSPR72",.T.)
	cCodLote   := MV_PAR01
 cCodImp    := MV_PAR02	
Else
 cCodLote := cLote
EndIf

nMaxLin := HS_MaxLin(cCodImp)

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ Monta a interface padrao com o usuario...                           ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/

wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณRUNREPORT บ Autor ณ Mario Arizono      บ Data ณ  01/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Rotina de execucao do relatorio                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
Local cSQL    := ""
Local nTotFic := 0  


 DbSelectArea(cString)
 DbSetOrder(6) // GSA_FILIAL + GSA_LOTE 

 /*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
   ณ Selecao de Dados                                                    ณ
   ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
 cSQL:= "SELECT GSA.GSA_CODLOC CODLOC, GSA.GSA_CODEND CODEND, GSA.GSA_CODCRM CODCRM, GSA.GSA_CODPRO CODPRO, GSA.GSA_REGGER REGGER, " 
 cSQL+= " GSA.GSA_NOMSOL NOMSOL, GSA.GSA_CODMOT CODMOT, GSA.GSA_OBSERV OBSERV, GCS.GCS_NOMLOC NOMLOC, GSD.GSD_DESEND DESEND, SRA.RA_NOME NOMPRO, "
 cSQL+= " GA7.GA7_DESC DESPRO, GBH.GBH_NOME NOMPAC, GSC.GSC_DESMOT DESMOT, GSG.GSG_DATA DATLOTE, GSG.GSG_HORA HORLOTE "
 cSQL+= " FROM "+RetSQLName("GSA")+ " GSA"
 cSQL+= " JOIN "+RetSQLName("GCS")+ " GCS ON GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_CODLOC = GSA.GSA_CODLOC"
 cSQL+= " JOIN "+RetSQLName("GSD")+ " GSD ON GSD.GSD_FILIAL = '" + xFilial("GSD") + "' AND GSD.D_E_L_E_T_ <> '*' AND GSD.GSD_CODEND = GSA.GSA_CODEND"
 cSQL+= " JOIN "+RetSQLName("SRA")+ " SRA ON SRA.RA_FILIAL = '"  + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO = GSA.GSA_CODCRM"
 cSQL+= " JOIN "+RetSQLName("GA7")+ " GA7 ON GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = GSA.GSA_CODPRO"
 cSQL+= " JOIN "+RetSQLName("GBH")+ " GBH ON GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' AND GBH.GBH_CODPAC = GSA.GSA_REGGER"
 cSQL+= " JOIN "+RetSQLName("GSC")+ " GSC ON GSC.GSC_FILIAL = '" + xFilial("GSC") + "' AND GSC.D_E_L_E_T_ <> '*' AND GSC.GSC_CODMOT = GSA.GSA_CODMOT"
 cSQL+= " JOIN "+RetSQLName("GSG")+ " GSG ON GSG.GSG_FILIAL = '" + xFilial("GSG") + "' AND GSG.D_E_L_E_T_ <> '*' AND GSG.GSG_LOTE = GSA.GSA_LOTE"
 cSQL+= " WHERE GSA.GSA_FILIAL = '" + xFilial("GSA") + "' AND GSA.D_E_L_E_T_ <> '*'"  
 cSQL+= " AND GSA.GSA_LOTE = '" + cCodLote + "' "
 cSQL+= " ORDER BY " + SqlOrder(GSA->(IndexKey(6)))
 
 cSQL:=ChangeQuery(cSQL)
 TCQUERY cSQL NEW ALIAS "QRY"

 If Eof()
	 HS_MsgInf(STR0005, STR0006, STR0007)   //"Nenhuma informa็ใoo foi encontrada para a sele็ใo!"###"Aten็ใo"###"Verifique a sele็ใo"
  Return()
 Endif

  
 DbSelectArea("QRY")
 dbGoTop()
 SetRegua(100)
 

 Cabec1 := STR0008 + cCodLote  //"                             PROTOCOLO DE PRONTUARIO(S) SAIDAS MULTIPLAS No. "
 //                   1         2         3         4         5         6         7         8         9        10        11        12        13
         // 0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
 Cabec2 := STR0009 //"Paciente                                   Endereco                                     Visto "

 While !EOF()
 	IncRegua()
 	If lAbortPrint
 		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
 		Exit
	 EndIf
	
	 If nLin > nMaxLin // Salto de Pagina.
	 	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	  nLin:=9
		 @nLin,000 Psay STR0010 + ALLTRIM(QRY->CODLOC) + " - " + QRY->NOMLOC   //"Setor.......: "
		 nLin++
		 @nLin,000 Psay STR0011 + ALLTRIM(QRY->CODCRM) + " - " + QRY->NOMPRO //"Medico......: "
		 nLin++                                                
		 @nLin,000 Psay STR0012 + ALLTRIM(QRY->CODPRO) + " - " + QRY->DESPRO //"Procedimento: "
		 nLin++
		 @nLin,000 Psay STR0013 + ALLTRIM(QRY->CODMOT) + " - " + QRY->DESMOT //"Motivo......: "
		 nLin++
   @nLin,000 Psay STR0014 + QRY->OBSERV  //"Observacao..: "
		 nLin++   
		 @nLin,000 Psay STR0015 + DTOC(STOD(QRY->DATLOTE)) + STR0016 + QRY->HORLOTE  //"Data e Hora.: "###" as "
		 nLin++
		 @nLin,000 Psay STR0017 + QRY->NOMSOL  //"Funcionario.: "
		 nLin+=2
	 EndIf
	  @nLin,000 Psay QRY->REGGER + " - " + SUBSTR(QRY->NOMPAC,1,30) 
   @nLin,043 Psay	ALLTRIM(QRY->CODEND)+ " - " + QRY->DESEND 
   @nLin,088 Psay "______________________________"
	  nLin++
	  nTotFic++
	 DbSkip() 
 EndDo
 If EOF()
  If nLin > nMaxLin // Salto de Pagina.
 	 Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
 	 nLin:=9
		 @nLin,000 Psay STR0010 + QRY->CODLOC + QRY->NOMLOC   //"Setor.......: "
		 nLin++
		 @nLin,000 Psay STR0011 + QRY->CODCRM + QRY->NOMPRO //"Medico......: "
		 nLin++    
		 @nLin,000 Psay STR0012 + QRY->CODPRO + QRY->DESPRO //"Procedimento: "
		 nLin++
		 @nLin,000 Psay STR0013 + QRY->CODMOT + QRY->DESMOT //"Motivo......: "
		 nLin++
   @nLin,000 Psay STR0014 + QRY->OBSERV  //"Observacao..: "
		 nLin++   
		 @nLin,000 Psay STR0015 + DTOC(STOD(QRY->DATLOTE)) + STR0016 + QRY->HORLOTE  //"Data e Hora.: "###" as "
		 nLin++
		 @nLin,000 Psay STR0017 + QRY->NOMSOL  //"Funcionario.: "
		 nLin++
 	Endif
 	nLin := nLin + 4
  @nLin,000 Psay STR0018 + TRANSFORM(nTotFic,"@E 9,999") //"Total de Fichas Solicitadas.......:"
  @nLin,065 Psay  "__________________________________"
  nLin++
  @nLin,075 Psay STR0019 //"ASSINATURA"
 EndIf
 
 DbClosearea()

SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()
Return
