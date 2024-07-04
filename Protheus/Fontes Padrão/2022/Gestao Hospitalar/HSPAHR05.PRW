#INCLUDE "HSPAHR05.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ HSPAHR05 ³ Autor ³ MARCELO JOSE          ³ Data ³ 06/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio TRANSFERENCIA DE MULTIPRONTUARIOS                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs:      ³ Convertido para relatorios personalizaveis                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAHSP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FUNCTION HSPAHR05(aItemGsi)

 Local oReport
 Default aItemGsi := {}
 
 If FindFunction("TRepInUse") .And. TRepInUse() 
 	pergunte("HSPR05",.F.)
  oReport := ReportDef(aItemGsi) 
  oReport:PrintDialog()  
 ELSE  
  HSPAHR05R3(aItemGsi)  
 EndIF    
 
Return( Nil )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³REPORTDEF ³ Autor ³ MARCELO JOSE          ³ Data ³ 05/06/06 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef(aItemGsi)
 Local oReport 
 Local oSection1, oSection2, oSection3
 Local oCell
 Local oTotaliz1
 
 oReport := TReport():New("HSPAHR05",STR0003,"HSPR05",{|oReport| R05IMP(oReport,aItemGsi)},STR0001+" "+STR0002)
//"TRANSFERENCIA DE MULTIPRONTUARIOS" ###"Este programa tem como objetivo imprimir relatorio"###"de acordo com os parametros informados pelo usuario."
  
 oSection1 := TRSection():New(oReport,"Endereços",{"GSI"})
 oSection1:SetHeaderBreak(.F.)    //Indica se cabecalho da secao sera impresso em cada quebra 
 oSection1:SetPageBreak(.T.)      //Indica quebra de pagina no final da secao
 oSection1:SetHeaderPage(.T.)     //Indica que cabecalho da secao sera impresso no topo da pagina
 oSection1:SetHeaderSection(.T.)  //Indica se cabecalho da secao sera impresso (padrao)   
 oCell := TRCell():New(oSection1,"GSI_CODEND","GSI")
 oCell := TRCell():New(oSection1,"GSI_DESEND","GSI","Endereço")
 
 oSection2 := TRSection():New(oSection1,"Datas",{"GSI"})                                     
 oSection2:SetHeaderBreak(.F.)    //Indica se cabecalho da secao sera impresso em cada quebra 
 oSection2:SetPageBreak(.f.)      //Indica quebra de pagina no final da secao
 oSection2:SetHeaderPage(.T.)     //Indica que cabecalho da secao sera impresso no topo da pagina
 oSection2:SetHeaderSection(.T.)  //Indica se cabecalho da secao sera impresso (padrao)   
 oCell := TRCell():New(oSection2,"GSI_DATTRA","GSI")                                    

 oSection3 := TRSection():New(oSection2,"Horarios",{"GSI"})                                  
 oSection2:SetHeaderBreak(.F.)    //Indica se cabecalho da secao sera impresso em cada quebra 
 oSection2:SetPageBreak(.f.)      //Indica quebra de pagina no final da secao
 oSection2:SetHeaderPage(.T.)     //Indica que cabecalho da secao sera impresso no topo da pagina
 oSection2:SetHeaderSection(.T.)  //Indica se cabecalho da secao sera impresso (padrao)   
 oCell := TRCell():New(oSection3,"GSI_HORTRA","GSI") 
 oCell := TRCell():New(oSection3,"GSI_REGGER","GSI")
 If GSI->(FieldPos("GSI_REGATE")) > 0
 oCell := TRCell():New(oSection3,"GSI_REGATE","GSI")
 Endif
 oCell := TRCell():New(oSection3,"NOME",,"Paciente",,TamSx3("GBH_NOME")[1],,{||HS_INIPADR('GBH', 1, GSI->GSI_REGGER, 'GBH_NOME',,.F.) })   
 oCell := TRCell():New(oSection3,"GSI_CODENO","GSI")
 oCell := TRCell():New(oSection3,"GSI_DESENO","GSI")

 oTotaliz1 :=  TRFunction():new(oSection3:Cell("GSI_HORTRA"),,"COUNT",," ===> ",,,.t.)
  
Return( oReport )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R05Imp   ³ Autor ³ MARCELO JOSE          ³ Data ³ 05/06/06 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function R05IMP(oReport,aItemGsi)
 Local cFiltro1  := ""
 Local oSection1 := oReport:Section(1) 
 Local oSection2 := oReport:Section(1):Section(1)
 Local oSection3 := oReport:Section(1):Section(1):Section(1)
 Local cSeqTraI  := ""
 Local cSeqtraF  := ""

 DbSelectArea("GSI")
 DbSetOrder(2) 

 If Len(aItemGsi) > 0
  cSeqTraI :=  aItemGsi[1,9]
  cSeqTraF :=  aItemGsi[Len(aItemGsi),9]  
  cFiltro1 := "@GSI_FILIAL = '"+XFILIAL("GSI")+"'"
  cFiltro1 += " AND GSI_SEQTRA BETWEEN '" + cSeqTraI + "' AND '" + cSeqTraF +"'" 
 Else
  cFiltro1 := "@GSI_FILIAL = '"+XFILIAL("GSI")+"'"
  cFiltro1 += " AND GSI_ENDTIP <> '1'"
  cFiltro1 += " AND GSI_DATTRA BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) +"'" 
  cFiltro1 += " AND GSI_CODENO BETWEEN '" + mv_par03 + "' AND '" + mv_par04 +"'"  
  cFiltro1 += " AND GSI_CODEND BETWEEN '" + mv_par05 + "' AND '" + mv_par06 +"'" 
 EndIf
 
 oSection1:SetIdxOrder(2)  
 oSection1:SetFilter(cFiltro1)
 oSection2:SetParentFilter( {|G| GSI_CODEND == G }, {|| GSI_CODEND } )
 oSection3:SetParentFilter( {|P| DTOC(GSI->GSI_DATTRA) + GSI->GSI_CODEND == P }, {|| DTOC(GSI->GSI_DATTRA) + GSI->GSI_CODEND} )
  
 oSection1:Print() 
Return( NIL ) 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHR05  º Autor ³ Patricia Queiroz   º Data ³  02/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio Transferencia de Multi Prontuarios               º±±                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HSPAHR05R3(aItemGsi)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cSQL :=""
Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir relatorio"
Local cDesc2 := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3 := ""
Local cPict := ""
Local titulo := STR0003 //"Relatorio Transferencia de Multi Prontuarios"
Local nLin := 80
Local Cabec1 := ""
Local Cabec2 := ""
Local imprime := .T.
Local aOrd := {}

Private lEnd := .F.
Private lAbortPrint := .F.
Private limite := 80
Private tamanho := "M"
Private nomeprog := "HSPAHR05" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo := 18
Private aReturn := {STR0004, 1, STR0005 , 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey := 0
Private cbtxt := Space(10)
Private cbcont := 00
Private CONTFL := 01
Private m_pag := 01
Private wnrel := "HSPAHR05" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cCodEnd_De := ""
Private cCodEnd_Ate := ""
Private cCodEndO_De := ""
Private cCodEndO_Ate := ""
Private dDatTransf_De := ""
Private dDatTransf_Ate := ""
Private cCodImp := ""
Private nMaxLin := 0
Private cString := "GSI"
Private aIteTran:= aClone(aItemGsi)
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ PARAMETROS                                                       ³
³ MV_PAR01	Da Data Transferencia                                   ³
³ MV_PAR02	Ate Data Transferencia                                  ³
³ MV_PAR03	Do Endereco Origem                                      ³
³ MV_PAR04	Ate Endereco Origem                                     ³
³ MV_PAR05	Do Endereco Destino                                     ³
³ MV_PAR06	Ate Endereco Destino                                    ³
³ MV_PAR07	Impressora                                              ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

If FunName() <> "HSPAHM41"
	If !Pergunte("HSPR05",.T.)
		Return()
	EndIf
EndIf

dDat_De    := MV_PAR01
dDat_Ate   := MV_PAR02
cCdEdO_De  := MV_PAR03
cCdEdO_Ate := MV_PAR04
cCdEnd_De  := MV_PAR05
cCdEnd_Ate := MV_PAR06
cCodImp    := MV_PAR07

nMaxLin := HS_MaxLin(cCodImp)

DbSelectArea(cString)
DbSetOrder(2) //GSI_FILIAL + GSI_DATTRA + GSI_HORTRA + GSI_REGGER

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Monta a interface padrao com o usuario...                           ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³RUNREPORT º Autor ³ Patricia Queiroz   º Data ³  02/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Rotina de execucao do relatorio                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local cUltEnd  := "" //armazena o ultimo endereco de destino
Local cUltData := "" //armazena a ultimo data
Local nTotDia  := 0
Local nTotTra  := 0
Local nTot     := 0  
Local nFor     := 0
If Empty(aIteTran)
 DbSelectArea(cString)
 DbSetOrder(2) // GSI_FILIAL + GSI_CODEND + GSI_DATTRA + GSI_HORTRA + GSI_REGGER

 /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³ Selecao de Dados                                                    ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
 cSQL:= "SELECT GSI.GSI_CODEND, GSI.GSI_DESEND, GSI.GSI_HORTRA, GSI.GSI_DATTRA, GSI.GSI_CODENO,"
 cSQL+= " GSI.GSI_DESENO, GSI_REGGER, GBH_NOME"
 If GSI->(FieldPos("GSI_REGATE")) > 0
 cSQL+= " GSI.GSI_REGATE"
 Endif
 cSQL+= " FROM "+RetSQLName("GSI")+ " GSI"
 cSQL+= " JOIN "+RetSQLName("GBH")+ " GBH ON GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' AND GBH.GBH_CODPAC = GSI.GSI_REGGER"
 cSQL+= " WHERE GSI.GSI_FILIAL = '" + xFilial("GSI") + "' AND GSI.D_E_L_E_T_ <> '*'"  
 cSQL+= " AND GSI.GSI_ENDTIP <> '1'"
 If !Empty(dDat_Ate)
	 cSQL+= " AND GSI.GSI_DATTRA BETWEEN '" + DTOS(dDat_De) + "' AND '" + DTOS(dDat_Ate) +"'"
 Else
 	cSQL+= " AND GSI.GSI_DATTRA = '" + DTOS(dDatabase) +"'"
 EndIf
 
 If !Empty(cCdEdO_Ate)
 	cSQL+= " AND GSI.GSI_CODENO BETWEEN '" + (cCdEdO_De) + "' AND '" + (cCdEdO_Ate) +"'"
 EndIf
 
 If !Empty(cCdEnd_Ate)
 	cSQL+= " AND GSI.GSI_CODEND BETWEEN '" + (cCdEnd_De) + "' AND '" + (cCdEnd_Ate) +"'"
 EndIf
 
 cSQL+= " ORDER BY " + SqlOrder(GSI->(IndexKey(2)))
 
 cSQL:=ChangeQuery(cSQL)
 TCQUERY cSQL NEW ALIAS "QRY"

 If Eof()
	 HS_MsgInf(STR0006, STR0007, STR0008)  //"Nenhuma informaçãoo foi encontrada para a seleção!"###"Atenção"###"Verifique a seleção"
 Endif

 //           1         2         3         4         5         6         7         8         9        10        11        12        13
 // 0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
 
 DbSelectArea("QRY")
 dbGoTop()
 SetRegua(100)

 Cabec1 := STR0009 + ALLTRIM(QRY->GSI_CODEND) + " - " + QRY->GSI_DESEND //"Endereço: "
 Cabec2 := STR0010 //"Hora    Paciente                                                 Endereco Origem                   "

 While !EOF()
 	IncRegua()
 	If lAbortPrint
 		@nLin,00 PSAY STR0011 //"*** CANCELADO PELO OPERADOR ***"
 		Exit
	 EndIf
	
	 If nLin > nMaxLin // Salto de Pagina.
	 	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	 	cUltEnd := QRY->GSI_CODEND
		 cUltData := QRY->GSI_DATTRA
		 nLin:=9
		 @nLin,000 Psay + STR0012 + DTOC(STOD(QRY->GSI_DATTRA))  //"Data "
		 nLin++
	 EndIf
	
	 If cUltEnd <> QRY->GSI_CODEND
	 	nLin := nLin + 2
	 	@nLin,025 Psay + STR0013 + TRANSFORM(nTotTra,"@E 99,999") //"Total de Endereço:..........."
	 	Cabec1 := STR0009 + ALLTRIM(QRY->GSI_CODEND) + " - " + QRY->GSI_DESEND
	 	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	 	nLin := 9
	 	If cUltData == QRY->GSI_DATTRA
	 		@nLin,000 Psay + STR0012 + DTOC(STOD(QRY->GSI_DATTRA))
	 	EndIf
		 nLin++
		 nTotTra := 0
	 EndIf
	
	 If cUltData <> QRY->GSI_DATTRA
	 	nLin := nLin + 2
	 	@nLin,025 Psay + STR0014 + TRANSFORM(nTotDia,"@E 99,999") //"Total do Dia:..........."
	 	nTotDia := 0
	 	nLin := nLin + 2
	 	@nLin,000 Psay + STR0012 + DTOC(STOD(QRY->GSI_DATTRA))
	 	nLin++
	 EndIf
	
	 cUltEnd := QRY->GSI_CODEND
	 cUltData := QRY->GSI_DATTRA
	 nTotDia++
	 nTotTra++
	 nTot++
	
	 @nLin,000 Psay QRY->GSI_HORTRA
	 @nLin,008 Psay QRY->GSI_REGGER + " - " + Iif(GSI->(FieldPos("GSI_REGATE")) > 0, QRY->GSI_REGATE," " ) + " - " + QRY->GBH_NOME
	 @nLin,065 Psay QRY->GSI_CODENO + " - " + QRY->GSI_DESENO
	 nLin++
	 DbSkip() 
 EndDo

 If nLin > nMaxLin // Salto de Pagina.
 	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
 	nLin:=9
 EndIf


 nLin := nLin + 2
 @nLin,025 Psay + STR0013 + TRANSFORM(nTotTra,"@E 99,999")//"Total de Endereço:..........."
 nLin := nLin + 2
 @nLin,025 Psay + STR0015 + TRANSFORM(nTot,"@E 99,999")//"Total........................"  
 nLin := nLin + 2
 @nLin,025 Psay + STR0014 + TRANSFORM(nTotDia,"@E 99,999")//"Total do Dia:..........."

 DbClosearea()
Else
  
 aSort(aIteTran,,,{|x,y| x[1] + dTos(x[4])+ x[3] + x[7] < y[1] + dTos(y[4])+ y[3] + y[7]})
 SetRegua(len(aIteTran))
 
 Cabec1 := STR0009 + ALLTRIM(aIteTran[1,1]) + " - " + aIteTran[1,2] //"Endereço: "
 Cabec2 := STR0010 //"Hora    Paciente                                                 Endereco Origem                   "

 For nFor := 1 to len(aIteTran)
 	
 	IncRegua()
 	If lAbortPrint
 		@nLin,00 PSAY STR0011 //"*** CANCELADO PELO OPERADOR ***"
 		Exit
	 EndIf
	
	 If nLin > nMaxLin // Salto de Pagina.
	 	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	 	cUltEnd := aIteTran[nFor,1]
		 cUltData := aIteTran[nfor,4]
		 nLin:=9
		 @nLin,000 Psay + STR0012 + DTOC(aIteTran[nfor,4])  //"Data "
		 nLin++
	 EndIf
	
	 If cUltEnd <> aIteTran[nfor,1]
	 	nLin := nLin + 2
	 	@nLin,025 Psay + STR0013 + TRANSFORM(nTotTra,"@E 99,999") //"Total de Endereço:..........."
	 	Cabec1 := STR0009 + ALLTRIM(aIteTran[nfor,1]) + " - " + aIteTran[nfor,2]
	 	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	 	nLin := 9
	 	If cUltData == aIteTran[nfor,4]
	 		@nLin,000 Psay + STR0012 + DTOC(aIteTran[nfor,4])
	 	EndIf
		 nLin++
		 nTotTra := 0
	 EndIf
	
	 If cUltData <> aIteTran[nfor,4]
	 	nLin := nLin + 2
	 	@nLin,025 Psay + STR0014 + TRANSFORM(nTotDia,"@E 99,999") //"Total do Dia:..........."
	 	nTotDia := 0
	 	nLin := nLin + 2
	 	@nLin,000 Psay + STR0012 + DTOC(aIteTran[nfor,4])
	 	nLin++
	 EndIf
	
	 cUltEnd := aIteTran[nfor,1]
	 cUltData := aIteTran[nfor,4]
	 nTotDia++
	 nTotTra++
	 nTot++

	 @nLin,000 Psay aIteTran[nfor,3]
	 @nLin,008 Psay aIteTran[nfor,7]+ " - " + aIteTran[nfor,10] + " - " + aIteTran[nfor,8] 
	 @nLin,065 Psay aIteTran[nfor,5] + " - " + aIteTran[nfor,6]
	 nLin++
	 
 Next nfor

 If nLin > nMaxLin // Salto de Pagina.
 	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
 	nLin:=9
 EndIf

 
 nLin := nLin + 2
 @nLin,025 Psay + STR0013 + TRANSFORM(nTotTra,"@E 99,999")//"Total de Endereço:..........."
 nLin := nLin + 2
 @nLin,025 Psay + STR0015 + TRANSFORM(nTot,"@E 99,999")//"Total........................"  
 nLin := nLin + 2
 @nLin,025 Psay + STR0014 + TRANSFORM(nTotDia,"@E 99,999")//"Total do Dia:..........."
 
Endif

SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()
Return
