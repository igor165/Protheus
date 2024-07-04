#INCLUDE "HSPAHR52.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

//----------------------------------------------R4 - PERSONALIZADO

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HSPAHR52 º Autor ³ DANIEL PEIXOTO     º Data ³  29/06/2006 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ RELATORIO PACIENTES ATEND. OU FALTOSOS                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GESTAO HOSPITALAR.                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HSPAHR52()   

 Local oReport
 
 If FindFunction("TRepInUse") .And. TRepInUse() 
 	pergunte("HSPR52",.T.)
  oReport := ReportDef() 
  oReport:PrintDialog()  
 ELSE  
  HSPAHR52R3()  
 EndIF    
 
Return( Nil )     

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³REPORTDEF ³ Autor ³ DANIEL PEIXOTO        ³ Data ³ 29/06/06 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()
 Local oReport 
 Local oSection1, oSection2
 Local oCell
 Local oTotaliz1, oTotaliz2, oTotaliz3, oTotaliz4, oTotaliz5
 Local aOrdem  := {}
 Local cTitulo := ""
 Local bFormula

// AADD(aOrdem ,"Filial Agend + Data Agenda" )
 If MV_PAR05 == 2 //sintetico
  cTitulo := STR0007+Dtoc(mv_par03)+STR0008+Dtoc(mv_par04)  //"Pacientes Atendidos e Faltosos de: "###" a "
 Else  //analitico
  If MV_PAR06 == 1 //atendidos
   cTitulo := STR0009+Dtoc(mv_par03)+STR0008+Dtoc(mv_par04)  //"Pacientes Atendidos de: "###" a "
  Else //faltosos
   cTitulo := STR0010+Dtoc(mv_par03)+STR0008+Dtoc(mv_par04)  //"Pacientes Faltosos de: "###" a "
  EndIf
 EndIf 
 
 oReport := TReport():New("HSPAHR52",OemToAnsi(cTitulo),'HSPR52',{|oReport| R52IMP(oReport)},"Este relatorio tem por objetivo a impressao dos Pacientes Atendidos ou Faltosos.")
 oReport:SetTotalText(STR0016+" "+STR0017) // texto impresso antes da somatoria de oTotaliz
//"Total Geral.: " ###"Pacientes Atendidos/Faltosos"

 oReport:ParamReadOnly() //Desabilitando Botão de parâmetros do Relatório.
 
 oSection1 := TRSection():New(oReport,STR0015,{"GM8"}, /*aOrdem*/) //"Data Agendamento"
 oCell := TRCell():New(oSection1,"GM8_DATAGE","GM8")

 oSection2 := TRSection():New(oSection1,STR0024,{"GM8","GBH","GA7","SRA"}, /*aOrdem*/) //"Atendimentos"

 oCell := TRCell():New(oSection2,"cTotal" ,        ,"",,  ,,{|| ("QRYGM8")->GM8_REGGER})     
 oSection2:Cell("cTotal"):Hide()
 oCell := TRCell():New(oSection2,"GM8_REGGER","GM8") 
 oCell := TRCell():New(oSection2,"GBH_NOME"  ,"GBH")
 oCell := TRCell():New(oSection2,"GM8_CODPRO","GM8")
 oCell := TRCell():New(oSection2,"GA7_DESC"  ,"GA7")
 oCell := TRCell():New(oSection2,"GM8_CODCRM","GM8")
 oCell := TRCell():New(oSection2,"RA_NOME"   ,"SRA")
 

 oTotaliz1 := TRFunction():new(oSection2:Cell("cTotal"),,"COUNT",,"Qtd Agendados    ==>",,,.T.,.F.,.F.)
 
 oTotaliz1 := TRFunction():new(oSection2:Cell("GM8_REGGER"),,"COUNT",,"Qtd Agendados    ==>",,,.T.,.F.,.F.)
 
 oTotaliz2 := TRFunction():New(oSection2:Cell("cTotal"),"QTDATE","COUNT"  ,,"Qtd Atendidos    ==>",/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
 oTotaliz2:SetCondition({ || ("QRYGM8")->GM8_STATUS == "3" })

 oTotaliz3 := TRFunction():New(oSection2:Cell("cTotal"),""      ,"AVERAGE",,"Qtd Atendidos(%) ==>","@E 999.999%",{ || FS_PercAte(oReport, ("QRYGM8")->GM8_DATAGE) },.T./*lEndSection*/,/*lEndReport*/,/*lEndPage*/)	

 oTotaliz4 := TRFunction():New(oSection2:Cell("cTotal"),"QTDFAL","COUNT"  ,,"Qtd Faltosos     ==>",/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
 oTotaliz4:SetCondition({ || ("QRYGM8")->GM8_STATUS <> "3" })
 
 oTotaliz5 := TRFunction():New(oSection2:Cell("cTotal"),""      ,"AVERAGE",,"Qtd Faltosos(%)  ==>","@E 999.999%",{ || FS_PercFal(oReport, ("QRYGM8")->GM8_DATAGE) },.T./*lEndSection*/,/*lEndReport*/,/*lEndPage*/)

Return( oReport )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R52Imp   ³ Autor ³ DANIEL PEIXOTO        ³ Data ³ 29/06/06 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function R52IMP(oReport)
Local cCond   := "%%"
Local cCpoGM8 := "%"+HS_RetCpos("GM8",.T., ".")+"%"                                       
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³Transforma parametros Range em expressao SQL                            ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 MakeSqlExpr(oReport:uParam)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Query do relatório da secao 1                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If MV_PAR05 == 2 //Sintetico
  cCond := "%GM8.GM8_STATUS IN ('1','3','5')%" 
 Else //Analitico
  If MV_PAR06 == 1 //Atendidos
    cCond := "%GM8.GM8_STATUS = '3'%" 
  Else //Faltosos                                                        7
   cCond := "%GM8.GM8_STATUS IN ('1','5')%" 
  EndIf 
 Endif
// 	SELECT GM8.*, GM8_CODCRM, RA_NOME, GM8_REGGER, GM8_CODPRO, GBH_NOME, GA7_DESC 
	oReport:Section(1):BeginQuery()		
	BeginSql Alias "QRYGM8"
 	SELECT %exp:cCpoGM8%, RA_NOME       , GBH_NOME      , GA7_DESC 
  FROM %table:GM8% GM8
 				  JOIN %table:GBH% GBH ON GBH.GBH_CODPAC = GM8.GM8_REGGER AND GBH.GBH_FILIAL = %xFilial:GBH% AND GBH.%NotDel%
       JOIN %table:GA7% GA7 ON GA7.GA7_CODPRO = GM8.GM8_CODPRO AND GA7.GA7_FILIAL = %xFilial:GA7% AND GA7.%NotDel%
       JOIN %table:GBJ% GBJ ON GBJ.GBJ_CRM    = GM8.GM8_CODCRM AND GBJ.GBJ_FILIAL = %xFilial:GBJ% AND GBJ.%NotDel%
       JOIN %table:SRA% SRA ON SRA.RA_CODIGO  = GBJ.GBJ_CRM    AND SRA.RA_FILIAL  = %xFilial:SRA% AND SRA.%NotDel%
  WHERE GM8.GM8_FILIAL = %xFilial:GM8% AND GM8.%NotDel%
        AND GM8.GM8_FILAGE BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
        AND GM8.GM8_DATAGE BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
        AND %Exp:cCond%
  ORDER BY GM8_FILAGE, GM8_DATAGE, GM8_STATUS, GM8_HORAGE, GBH_NOME
 EndSql 	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Metodo EndQuery ( Classe TRSection )                                    ³
	//³                                                                        ³
	//³Prepara o relatório para executar o Embedded SQL.                       ³
	//³                                                                        ³
	//³ExpA1 : Array com os parametros do tipo Range                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(1):EndQuery(/*ExpA1*/)
	oReport:Section(1):Section(1):SetParentQuery()
	oReport:Section(1):Section(1):SetParentFilter({ |cParam| QRYGM8->GM8_DATAGE == cParam },{ || QRYGM8->GM8_DATAGE })
 
 If MV_PAR05 == 2 //sintetico                              
  oReport:Section(1):Section(1):Cell("GM8_REGGER"):Disable() 
  oReport:Section(1):Section(1):Cell("GBH_NOME"  ):Disable()
  oReport:Section(1):Section(1):Cell("GM8_CODPRO"):Disable()
  oReport:Section(1):Section(1):Cell("GA7_DESC"  ):Disable()
  oReport:Section(1):Section(1):Cell("GM8_CODCRM"):Disable()
  oReport:Section(1):Section(1):Cell("RA_NOME"   ):Disable()  
  oReport:Section(1):Section(1):Hide()
 Else 
  oReport:Section(1):Section(1):Cell("cTotal"):Disable()   
 EndIf 

 oReport:Section(1):Print() // processa as informacoes da tabela principal

Return( NIL )



//----------------------------------------------R3
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HSPAHR52 º Autor ³ DANIEL PEIXOTO     º Data ³  10/04/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ RELATORIO PACIENTES ATEND. OU FALTOSOS                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GESTAO HOSPITALAR.                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHR52R3()   
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Declaracao de Variaveis Locais                                      ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3         := ""
 Local Titulo         := STR0003 //"Pacientes Atend. ou Faltosos."
 Local Cabec1         := ""
 Local Cabec2         := ""
 Local aOrd           := {}
 Local aArea          := GetArea()

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Declaracao de Variaveis Privadas                                    ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
 Private lEnd         := .F.
 Private lAbortPrint  := .F.
 Private limite       := 132
 Private tamanho      := "M"
 Private nomeprog     := "HSPAHR52"
 Private nTipo        := 15
 Private aReturn      := { STR0004, 1, STR0005, 2, 2, 1, "", 1}  //"Zebrado"###"Administracao"
 Private nLastKey     := 0
 Private cbtxt        := Space(10)
 Private cbcont       := 00
 Private m_pag        := 01
 Private wnrel        := "HSPAHR52"
 Private cString      := "GM8"
 Private aRegistros   := {}
 Private nLin         := 80

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ PARAMETROS                                                         ³
 //³ MV_PAR01	Da Filial                                                 ³
 //³ MV_PAR02	Ate a Filial                                              ³
 //³ MV_PAR03	Da data                                                   ³
 //³ MV_PAR04	Ate a data                                                ³
 //³ MV_PAR05	Tipo Relatorio 1-Analitico  2-Sintetico                   ³
 //³ MV_PAR06	Tipo Agenda    1- Atendidos 2-Faltosos                    ³
 //³ MV_PAR07	Grafico 1-Sim  2-Nao                                      ³
 //| MV_PAR08 Impressora ?                                              |
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 cPerg := "HSPR52"       
 Pergunte(cPerg,.T.)             

 nMaxLin := HS_MaxLin(cCODIMP)
 nLin := nMaxLin * 2
                                                                                                  
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                        
 //³ Monta a interface padrao com o usuario...                           ³                        
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.F.,Tamanho,,.T.)
 If nLastKey == 27
  Return
 Endif          
 
 SetDefault(aReturn,cString)   
 
 If nLastKey == 27
  Return
 Endif            
 
 nTipo := If(aReturn[4]==1,15,18)
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 RptStatus({|| RunReport(Cabec1,Cabec2,Titulo) },Titulo)
 
 RestArea(aArea)
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ Daniel Peixoto     º Data ³04/10/2005   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GESTAO HOSPITALAR                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo)
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Definicao das variáveis locais.                                     ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Local cDATAGE     := ""      
 Local nTotDia     := 0 
 Local nTotDiaAte		:= 0
 Local nTotDiaFal		:= 0
 Local cSQL        := "" 
 Local aVetGraf    := {}
 Local cFilUsu     := HS_FilUsu("GM8")
 Local cAliasQr    := "QRY"
 Local cCpoGM8 := HS_RetCpos("GM8" ,.T., ".")                                       

 Private nTotGerAte  := 0
 Private nTotGerFal  := 0
 Private nTotGer     := 0 
 
 cSQL := "SELECT "+cCpoGM8+", SRA.RA_NOME, GBH.GBH_NOME, GA7.GA7_DESC"
 cSQL += " FROM " + RetSQLName("GM8") + " GM8"                                   
 cSQL += " JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_CODPAC = GM8.GM8_REGGER"
 cSQL += " JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GM8.GM8_CODPRO"
 cSQL += " JOIN " + RetSQLName("GBJ") + " GBJ ON GBJ.GBJ_CRM    = GM8.GM8_CODCRM"
 cSQL += " JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO  = GBJ.GBJ_CRM"
 cSQL += " WHERE"
 cSQL += "     GM8.GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8.D_E_L_E_T_ <> '*' "
 cSQL += " AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' "
 cSQL += " AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
 cSQL += " AND GBJ.GBJ_FILIAL = '" + xFilial("GBJ") + "' AND GBJ.D_E_L_E_T_ <> '*' " 
 cSQL += " AND SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' " 
 cSQL += " AND GM8.GM8_FILAGE BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
 cSQL += " AND GM8.GM8_DATAGE BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' "
 If MV_PAR05 == 2 //Sintetico
  cSQL += " AND GM8.GM8_STATUS IN ('1','3','5') "
 Else //Analitico
  If MV_PAR06 == 1 //Atendidos
   cSQL += " AND GM8.GM8_STATUS = '3' " 
  Else //Faltosos 
   cSQL += " AND GM8.GM8_STATUS IN ('1','5') "
  EndIf 
 Endif
 cSQL += " ORDER BY GM8_FILAGE, GM8_DATAGE, GM8_STATUS, GM8_HORAGE, GBH_NOME"
 cSQL :=  ChangeQuery(cSQL)

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
 
 If Eof()
  HS_MsgInf(STR0006, STR0022, STR0023) //"Nenhum dado foi encontrado para a selecao efetuada!"###"Atencao"###"Verifique a seleção"
 Endif
 
 If MV_PAR05 == 2 //sintetico
  Titulo := STR0007+Dtoc(mv_par03)+STR0008+Dtoc(mv_par04)  //"Pacientes Atendidos e Faltosos de: "###" a "
 Else  //analitico
  If MV_PAR06 == 1 //atendidos
   Titulo := STR0009+Dtoc(mv_par03)+STR0008+Dtoc(mv_par04)  //"Pacientes Atendidos de: "###" a "
  Else //faltosos
   Titulo := STR0010+Dtoc(mv_par03)+STR0008+Dtoc(mv_par04)  //"Pacientes Faltosos de: "###" a "
  EndIf
 EndIf 
  
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ SETREGUA -> Indica quantos registros serao processados para a regua ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 SetRegua(500)

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Carrega o vetor aRegistros com todos os dados a serem impressos.    ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 
 FS_CalcTot()

 While !EOF()

  If !&(cFilUsu)    // Filtro usando HS_FilUsu para imprimir o que foi selecionado pelo usuario. (12/04)
   DbSkip()
   Loop
  Endif
  IncRegua()     
  
  If lAbortPrint
   @nLin,00 PSAY STR0011 //"*** CANCELADO PELO OPERADOR ***"
   Exit
  Endif                                                                              
		                    //           1         2         3         4         5         6         7         8         9         0         1         2         3
                     	// 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
  If MV_PAR05 == 1 //sintetico
    Cabec1 := STR0012 //"Prontuario  Nome                            Procedimento                              Profissional                          "
  Else
    Cabec1 := STR0013 //"Data               Qtd Agendados      Qtd  Atendidos(%)      Qtd  Faltosos(%)"
  EndIf
    
	 If nLin+2 > nMaxLin
	  Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
   nLin := 8
   @nLin,00 PSAY STR0015 + DTOC(STOD(QRY->GM8_DATAGE)) //"Data do Agendamento...: "
   nLin += 2
  Endif
 
  If cDatAge <> QRY->GM8_DATAGE
    If MV_PAR05 == 1 //analitico
     If !EMPTY(cDatAge) 
      nLin ++
      @nLin,00 PSAY STR0014 + TRANSFORM(nTotDia, "@E 999,999")   //"Total do Dia...: "
      nTotDia := 0
      nLin += 2
      @nLin,00 PSAY REPLICATE("_",132)
      nLin += 2
      If nLin+2 < nMaxLin 
       @nLin,00 PSAY STR0015 + DTOC(STOD(QRY->GM8_DATAGE)) //"Data do Agendamento...: "
       nLin += 2  
      EndIf 
     EndIf 
    Else //sintetico    
     If !EMPTY(cDatAge) 
      @nLin,00 PSAY DTOC(STOD(cDatAge))
      nPorcAte := (nTotDiaAte/nTotDia)*100
      nPorcFal := (nTotDiaFal/nTotDia)*100
      @nLin,25 PSAY TRANSFORM( nTotDia, "@E 999,999")    
      @nLin,34 PSAY TRANSFORM( nTotDiaAte, "@E 999,999")    
      @nLin,48 PSAY TRANSFORM( nPorcAte, "@E 999.99")+"%"     
      @nLin,57 PSAY TRANSFORM( nTotDiaFal, "@E 999,999")    
      @nLin,70 PSAY TRANSFORM( nPorcFal, "@E 999.99")+"%"       
      AADD(aVetGraf,{ nPorcAte,nPorcFal, DTOC(STOD(cDatAge)) } )   
      nLin ++      
      @nLin,00 PSAY REPLICATE("_",132)
      nLin += 2
      nTotDiaAte := 0
      nTotDiaFal := 0                
      nTotDia    := 0
     EndIf      
    EndIf 
    cDatAge := QRY->GM8_DATAGE
  EndIf
  
  If MV_PAR05 == 1 //analitico
   If nLin+2 > nMaxLin
	   Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
    nLin := 8
    @nLin,00 PSAY STR0015 + DTOC(STOD(QRY->GM8_DATAGE)) //"Data do Agendamento...: "
    nLin += 2
   Endif

   @nLin,00 PSAY QRY->GM8_REGGER 
   @nLin,12 PSAY SUBSTR(QRY->GBH_NOME,1,30) 
   @nLin,44 PSAY PADL(ALLTRIM(QRY->GM8_CODPRO),LEN(QRY->GM8_CODPRO)) + " - " + SUBSTR(QRY->GA7_DESC,1,28) 
   @nLin,86 PSAY PADL(ALLTRIM(QRY->GM8_CODCRM),LEN(QRY->GM8_CODCRM)) + " - " + SUBSTR(QRY->RA_NOME,1,30) 
   nLin ++
  Else //sintetico
   If QRY->GM8_STATUS == '3'
    nTotDiaAte ++
   Else
    nTotDiaFal ++
   EndIf 
  EndIf 
  nTotDia ++
  nTotGer ++ 

  DbSkip()
 
 EndDo   
  
 If EOF()
  If MV_PAR05 == 1    
   nLin ++
   @nLin,00 PSAY STR0014 + TRANSFORM(nTotDia, "@E 999,999")  //"Total do Dia...: "
   nLin ++
  Else
   @nLin,00 PSAY DTOC(STOD(cDatAge))
   nPorcAte := (nTotDiaAte/nTotDia)*100
   nPorcFal := (nTotDiaFal/nTotDia)*100
   @nLin,25 PSAY TRANSFORM( nTotDia, "@E 999,999")    
   @nLin,34 PSAY TRANSFORM( nTotDiaAte, "@E 999,999")    
   @nLin,48 PSAY TRANSFORM( nPorcAte, "@E 999.99")+"%"     
   @nLin,57 PSAY TRANSFORM( nTotDiaFal, "@E 999,999")    
   @nLin,70 PSAY TRANSFORM( nPorcFal, "@E 999.99")+"%"       
   AADD(aVetGraf,{ nPorcAte,nPorcFal, DTOC(STOD(cDatAge)) } )   
   nLin += 2
   @nLin,00 PSAY REPLICATE("_",132)
   nLin ++
  EndIf 
  nLin ++
  @nLin,00 PSAY STR0016 + IIF(MV_PAR05 == 1,TRANSFORM(nTotGer, "@E 999,999"),"") //"Total Geral: "
  If MV_PAR05 == 2 
   @nLin,25 PSAY TRANSFORM( nTotGerAte+nTotGerFal, "@E 999,999")       
   @nLin,34 PSAY TRANSFORM( nTotGerAte, "@E 999,999")    
   @nLin,48 PSAY TRANSFORM((nTotGerAte/nTotGer)*100, "@E 999.99")+"%"
   @nLin,57 PSAY TRANSFORM( nTotGerFal, "@E 999,999")    
   @nLin,70 PSAY TRANSFORM((nTotGerFal/nTotGer)*100, "@E 999.99")+"%"
  EndIf
 EndIf 
  
 If MV_PAR05 == 2 .And. MV_PAR07 == 1
  oGraf := hsGRAF():NEW(STR0017,STR0018 + DTOC(MV_PAR03) +STR0008 + DTOC(MV_PAR04), STR0019, "", STR0020, "", aVetGraf,2,1,2,0,3,8,6,6,25,20) //"Pacientes Atendidos/Faltosos"###"No periodo de: "###" a "###"Percentuais"###"Tipo Atendimento"
 EndIf 
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Finaliza a execucao do relatorio...                                 ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 SET DEVICE TO SCREEN

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Se impressao em disco, chama o gerenciador de impressao...          ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 
 If aReturn[5]==1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif

 MS_FLUSH()
  
 DbCloseArea()
Return              

Static Function FS_CalcTot()

 While !EOF()
  If QRY->GM8_STATUS == '3'
    nTotGerAte ++
  Else
   nTotGerFal ++
  EndIf 
  DBSkip()
 EndDo

 DBGoTop() 

Return()                 

Function FS_VldData()
Local lRet := .T.

  If MV_PAR03 >= DATE() .Or. MV_PAR04 >= DATE()
    HS_MsgInf(STR0021, STR0022, STR0023)  //"A Data deve ser Menor que a Data Atual"###"Atencao"###"Verifique a seleção"
    lRet := .F.
  EndIf  
  
Return(lRet)

Static Function FS_PercAte(oReport, dQuebra)
 Static nAtualAte := 0
 Static dQbrAte   := CTOD("  /  /  ")
 Local  nTotAte   := 0, nRet := 0

	If dQbrAte <> dQuebra 
	 nAtualAte := 0      
	 dQbrAte   := dQuebra 
	EndIf
	 
	nTotAte := oReport:Section(1):Section(1):GetFunction("QTDATE"):SectionValue()
 If nTotAte <> nAtualAte
  nRet := 100
  nAtualAte := nTotAte
 EndIf
 
Return(nRet)

Static Function FS_PercFal(oReport, dQuebra)
 Static nAtualFal := 0               
 Static dQbrFal   := CTOD("  /  /  ")
 Local  nTotFal   := 0, nRet := 0

	If dQbrFal <> dQuebra
	 nAtualFal := 0      
	 dQbrFal   := dQuebra
	EndIf
	
	nTotFal := oReport:Section(1):Section(1):GetFunction("QTDFAL"):SectionValue()
 If nTotFal <> nAtualFal
  nRet := 100
  nAtualFal := nTotFal
 EndIf
 
Return(nRet)
