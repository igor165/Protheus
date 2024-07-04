#INCLUDE "HSPAHRDF.ch"
#Include "protheus.ch"
#include "TopConn.ch"    

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
²²ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿²²
²²³Fun‡…o    ³ HSPAHRDF ³ Autor ³ MARIO ARIZONO         ³ Data ³ 29/06/06 ³²²
²²ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´²²
²²³Descri‡…o ³ Relatorio PACIENTES CADASTRADOS                            ³²²
²²ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´²²
²²³Obs:      ³ Convertido para relatorios personalizaveis                 ³²²
²²ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´²²
²²³ Uso      ³ SIGAHSP                                                    ³²²
²²ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ²²
²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
FUNCTION HSPAHRDF()

 Local oReport
 
 If FindFunction("TRepInUse") .And. TRepInUse() 
 	pergunte("HSPRDF",.F.)
  oReport := ReportDef() 
  oReport:PrintDialog()  
 Else   
  HSPAHRDFR3()  
 EndIF    
 
Return( Nil )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
²²ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿²²
²²³Fun‡„o    ³REPORTDEF ³ Autor ³ MARCELO JOSE          ³ Data ³ 05/06/06 ³²²
²²ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ²²
²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()
 Local oReport 
 Local oSection1, oSection2,oTotaliz1
 Local oCell
   
 oReport := TReport():New("HSPAHRDF",OemToAnsi(STR0003),"HSPRDF",{|oReport| RDFIMP(oReport)},STR0001+STR0002)

 oSection1 := TRSection():New(oReport,OemToAnsi("Dados Cadastrais"),{"GBH","GCM"},)

  oCell := TRCell():New(oSection1,"GBH_CODPAC","GBH","")
  oCell := TRCell():New(oSection1,"GBH_NOME"  ,"GBH",,,30)
  oCell := TRCell():New(oSection1,"GBH_DTNASC","GBH",,,,,{||HS_DTOC(QRYGBH->GBH_DTNASC,1)})
  oCell := TRCell():New(oSection1,"GBH_SEXO"  ,"GBH")
  oCell := TRCell():New(oSection1,"GBH_CORPEL","GBH")
  oCell := TRCell():New(oSection1,"GCM_DESPLA","GCM")
  oCell := TRCell():New(oSection1,"GBH_USRCAD","GBH")
  
 oSection2 := TRSection():New(oSection1,OemToAnsi("ENDERECO"),{"GBH"},)
  oCell := TRCell():New(oSection2,"GBH_END",   "GBH")
  oCell := TRCell():New(oSection2,"GBH_NUM"   ,"GBH")
  oCell := TRCell():New(oSection2,"GBH_BAIRRO","GBH")
  oCell := TRCell():New(oSection2,"GBH_MUN"   ,"GBH")
  oCell := TRCell():New(oSection2,"GBH_EST",   "GBH")
  oCell := TRCell():New(oSection2,"GBH_CEP"   ,"GBH",,"@R 99999-999")
  oCell := TRCell():New(oSection2,"GBH_TEL",   "GBH")
 
 oTotaliz1 :=  TRFunction():new(oSection1:Cell("GBH_CODPAC"),,"COUNT",,STR0044,"@E 9,999",,.f.)//Qtd. Pacientes Emitidos
Return( oReport )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
²²ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿²²
²²³Fun‡„o    ³ RDFImp   ³ Autor ³ MARIO ARIZONO         ³ Data ³ 29/06/06 ³²²
²²ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ²²
²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RDFIMP(oReport)
Local cSql := ""

	MakeSqlExp("HSPRDF")
	
 oReport:Section(1):BeginQuery()
  
		If MV_PAR07 == 1  //ORDENAR POR NOME 
 	 cSQL := "%GBH_NOME%" 
  Else 						 //ordenar por prontuario
   cSQL := "%GBH_CODPAC%"
  EndIf   
	
BeginSql alias "QRYGBH"
		SELECT GBH_CODPAC, GBH_NOME, GBH_DTNASC, GBH_SEXO, GBH_CORPEL, GCM_DESPLA, GBH_USRCAD, GBH_END, GBH_NUM,
		GBH_BAIRRO, GBH_MUN, GBH_EST, GBH_CEP, GBH_TEL 
		FROM %table:GBH% GBH
		JOIN %table:GD4% GD4 ON GD4.GD4_REGGER = GBH.GBH_CODPAC AND GD4.GD4_IDPADR = '1' AND GD4_FILIAL = %xfilial:GD4% AND GD4.%notDel%
  JOIN %table:GCM% GCM ON GCM.GCM_CODPLA = GD4.GD4_CODPLA AND GCM_FILIAL = %xfilial:GCM% AND GCM.%notDel%
		WHERE GBH_FILIAL = %xfilial:GBH% AND GBH.%notDel%
  AND GBH.GBH_DATCAD BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)%
  AND GBH.GBH_USRCAD BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
  AND GBH.GBH_CODLOC BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
				
		ORDER BY %Exp:cSql%
EndSql 
	
 oReport:Section(1):EndQuery()                                 
 oReport:Section(1):Section(1):SetParentQuery()
	oReport:SetMeter(RecCount())
 DbSelectArea("QRYGBH")
 oReport:Section(1):init(.f.)
 oReport:Section(1):Section(1):init(.f.)
Do While !QRYGBH->(Eof())
	If oReport:Cancel()
		Exit
	EndIf

	If oReport:PageBreak()
		oReport:Section(1):PrintHeader() 
  oReport:Section(1):Section(1):PrintHeader()
	EndIf
	oReport:Section(1):PrintLine()
 oReport:Section(1):Section(1):PrintLine()
 oReport:SkipLine()
	    
 oReport:IncMeter()
 QRYGBH->(dbskip())
Enddo

oReport:Section(1):Section(1):Finish()
oReport:Section(1):Finish()
  
Return( NIL )
/*****************************************************************************************************************/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHRDFR3º Autor ³ Daniel Peixoto     º Data ³  17/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio PACIENTES CADASTRADOS                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºAlterações³ L.Gustavo Caloi 28/03/06 -> Padronização da HS_MsgInf()    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HSPAHRDFR3()


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³ Declaracao de Variaveis                                             ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""
Local titulo         := STR0003 //"Pacientes Cadastrados"
Local nLin           := 80
/*                       					 1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16       17
               					 0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.012 */
Local Cabec1         := STR0039 //"Nome do Paciente                                       Data Nasc.   Sexo   Cor      Plano                             Usuario         "
Local Cabec2         := STR0041 //"Endereco                                   Nr     Bairro                          Cidade                UF  CEP        Telefone     "
Local imprime        := .T.
Local aOrd 				   := {}    

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 80                  
Private tamanho      := "M"
Private nomeprog     := "HSPAHRDF" /* Coloque aqui o nome do programa para impressao no cabecalho */
Private nTipo        := 18
Private aReturn      := {STR0006, 1, STR0007, 2, 2, 1, "", 1}     //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHRDF" /* Coloque aqui o nome do arquivo usado para impressao em disco */
Private cPerg        := "HSPRDF"

Private cString  := ""

Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³ PARAMETROS                                                           ³
 ³ MV_PAR01	Da Data                                                     ³
 ³ MV_PAR02	Ate Data                                                    ³
 ³ MV_PAR03	DO Usuario                                                  ³
 ³ MV_PAR04	Ate Usuario                                                 ³
 ³ MV_PAR05	Do Setor                                                    ³
 ³ MV_PAR06	Ate Setor                                                   ³
 ³ MV_PAR07	Ordenar Por                                                   ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

If !Pergunte(cPerg,.T.)
	return
EndIf

nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2

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
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ Daniel Peixoto     º Data ³  17/05/05   º±±
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

Local cSQL 	     := ""
Local nQtdTot    := 0

 cSQL := "SELECT GBH.GBH_CODPAC, GBH.GBH_NOME, GBH.GBH_DTNASC, GBH.GBH_SEXO, GBH.GBH_CORPEL, GCM.GCM_DESPLA, "
 cSQL += " GBH.GBH_USRCAD, GBH.GBH_END, GBH.GBH_NUM, GBH.GBH_BAIRRO, GBH.GBH_MUN, GBH.GBH_EST, GBH.GBH_CEP, GBH.GBH_TEL "
 cSQL += " FROM " + RetSQLName("GBH") + " GBH" 
 cSQL += " JOIN " + RetSQLName("GD4") + " GD4 ON GD4.GD4_REGGER = GBH.GBH_CODPAC AND GD4.GD4_IDPADR = '1' "
 cSQL += " JOIN " + RetSQLName("GCM") + " GCM ON GCM.GCM_CODPLA = GD4.GD4_CODPLA "
 cSQL += " WHERE "
 cSQL += " GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' "
 cSQL += " AND GD4.GD4_FILIAL = '" + xFilial("GD4") + "' AND GD4.D_E_L_E_T_ <> '*' "
 cSQL += " AND GBH.GBH_DATCAD BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
 cSQL += " AND GBH.GBH_USRCAD BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
 cSQL += " AND GBH.GBH_CODLOC BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
 If MV_PAR07 == 1  //ORDENAR POR NOME 
 	 cSQL += " ORDER BY GBH_NOME "
 Else 						 //ordenar por prontuario
   cSQL += " ORDER BY GBH_CODPAC "
 EndIf   
 
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
                                
 If Eof()
  HS_MsgInf(STR0008, STR0042, STR0043) //"Nenhum dado foi encontrado para a selecao efetuada!"###"Atenção"###"Funcao aux. chamada pela RPTSTATUS"
 Endif

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³ SETREGUA -> Indica quantos registros serao processados para a regua ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

 SetRegua(100)

 While !EOF()

	 IncRegua()
   
   If lAbortPrint
      @nLin,00 PSAY STR0009 //"*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif
   
   If nLin > nMaxLin
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 9
   Endif
   
   @nLin,000 PSAY QRY->GBH_CODPAC + ' - '
   @nLin,009 PSAY QRY->GBH_NOME
   @nLin,055 PSAY HS_DTOC(STOD(QRY->GBH_DTNASC),1)
   If QRY->GBH_SEXO == "0"
   	 @nLin,068 PSAY "M"
   Else	 
	   @nLin,068 PSAY "F" 
	 EndIf  
   DO CASE
	   CASE QRY->GBH_CORPEL == "0"
	   	 @nLin,075 PSAY STR0010 //"Branca"
		 CASE QRY->GBH_CORPEL == "1"
	   	 @nLin,075 PSAY STR0011 //"Negra"
	   CASE QRY->GBH_CORPEL == "2"
	   	 @nLin,075 PSAY STR0012 //"Morena"
	   CASE QRY->GBH_CORPEL == "3"
	   	 @nLin,075 PSAY STR0013 //"Parda"
	 ENDCASE
   @nLin,084 PSAY QRY->GCM_DESPLA
   @nLin,118 PSAY QRY->GBH_USRCAD
   nLin++
   @nLin,000 PSAY QRY->GBH_END
   @nLin,043 PSAY QRY->GBH_NUM
   @nLin,050 PSAY SUBSTR(QRY->GBH_BAIRRO, 1, 29)
   @nLin,082 PSAY SUBSTR(QRY->GBH_MUN, 1, 20)
   @nLin,104 PSAY QRY->GBH_EST
   @nLin,108 PSAY TRANSFORM(QRY->GBH_CEP, "@R 99999-999")
   @nLin,119 PSAY QRY->GBH_TEL
	   
   nLin += 2
   nQtdTot++ 
   dbSkip() /* Avanca o ponteiro do registro no arquivo */

EndDo
If EOF()
 If nLin > nMaxLin
  Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
  nLin := 9
 Endif
  nLin++
  @nLin,000 PSAY STR0045 + ALLTRIM(TRANSFORM(nQtdTot,"@E 9,999"))//"Total de Pacientes Emitidos.: "  
 Endif 


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³ Finaliza a execucao do relatorio...                                 ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

SET DEVICE TO SCREEN

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³ Se impressao em disco, chama o gerenciador de impressao...          ³                                           	
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()
DBCloseArea()

Return   