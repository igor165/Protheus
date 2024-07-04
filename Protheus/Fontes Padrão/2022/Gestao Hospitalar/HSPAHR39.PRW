#INCLUDE "HSPAHR39.ch"
#include "rwmake.ch"
#include "TopConn.ch"
#INCLUDE "Report.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR39 บ Autor ณFabricio E. da Costa  บ Data ณ 07/08/07  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Contas Abertas com Alta                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HSPAHR39()
Local oReport

If FindFunction("TRepInUse") .And. TRepInUse() // Se ja tem rpo para relatorios personalizaveis.
	pergunte("HSPR39",.T.)
	oReport := ReportDef() // Chama a funcao de montagem do relatorio que retornara um objeto de impressao.
	// Metodo que apresenta a tela de impressao a partir do objeto retornado(...instanciado) na funcao ReportDef().
	// para o usuario configurar o relatorio...
	oReport:PrintDialog()
ELSE  // Se ainda nao tem rpo para relatorios personalizaveis entao executa o relatorio antigo renomeado...
	HSPAHR39R3()
EndIF

Return( Nil )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณREPORTDEF ณ Autor ณ Fabricio E. da Costa  ณ Data ณ 07/08/07 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
*/

Static Function ReportDef()
 Local oReport 
 Local oSection1, oSection2
 Local oCell
 Local oTotaliz
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ TReport:  Classe que instancia o componente de impressao                                                     ณ
//ณ Parametros para o  construtor inicializar as variaveis de instancia :                                        ณ
//ณ  (/*cNome Rel*/,/*cTit Rel*/,/*cPerg*/,/*{|| code-block de impres}*/,/*cdescricao*/)                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ TRSection:  Classe que instancia secoes(lay-out) do componente de impressao                                  ณ
//ณ Parametros para o  construtor inicializar as variaveis de instancia :                                        ณ  
//ณ ( /*oReport*/, /*cDescri*/,/*aTab*/,/*aOrd Rel*,/,.F./*lCpo SX3*,/,.F./*lCpo SIX*/)                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ TRCell:  Classe que instancia celulas das secoes (campos do lay-out de impressao)                            ณ
//ณ Parametros para o construtor inicializar as variaveis de instancia :                                         ณ
//ณ ( /*oSection*/,/*cCpoSX3*/,/*cTabSX2*/, /*cX3Tit*/,/*cX3Pict*/,/*cX3Tam*/,.F./*lPixel*/,/*{|| bCb impres}*/ )ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ TRFunction:  Classe que instancia totalizadores de quebra, secoes ou relatorios.                                                    ณ
 //ณ Parametros para o construtor inicializar as variaveis de instancia :                                                                ณ
 //ณ (oSec:Cell("campo"),/*cVarTemp*/,/*FUNCAO*/,/*oBreak*/,/*cTit*/,/*cPict*/,/*uForm*/,.F./*lEndSect*/,.F./*lEndRep*/,.F./*lEndPage*/) ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

 oReport := TReport():New("HSPAHR39",STR0003,"HSPR39",{|oReport| R39IMP(oReport)},STR0024) //"Rela็ใo de contas abertas com alta"###"Relat๓rio de contas abertas de pacientes com alta"
 //"Relatorio de Matriculas Invalidas por Convenio""Este relatorio tem por objetivo a impressao de pacientes com matriculas invalidas."
	oReport:ParamReadOnly()
	oReport:SetTotalText("")
	oReport:SetPortrait()
 If MV_PAR05 == 1
 	oSection1 := TRSection():New(oReport,STR0025,{"TMP"}) //"Conv๊nio"
	 oSection1:SetTotalInLine(.T.)	
 	oCell := TRCell():New(oSection1,"GCZ_CODCON","TMP",STR0026) //"Cod."
 	oCell := TRCell():New(oSection1,"GA9_NREDUZ","TMP",STR0025) //"Conv๊nio"
 	oSection2 := TRSection():New(oSection1,STR0027,{"TMP"}) //"Atendimentos"
 	oCell := TRCell():New(oSection2,"GCZ_REGATE","TMP",STR0028) //"Reg.At"
 	oCell := TRCell():New(oSection2,"GCZ_NRSEQG","TMP",STR0034) //"No.Guia"
 	oCell := TRCell():New(oSection2,"GCY_NOME"  ,"TMP",STR0029) //"Nome do Paciente"
 	oCell := TRCell():New(oSection2,"GCY_DATATE","TMP",STR0030) //"Dt. Atend"
 	oCell := TRCell():New(oSection2,"GCY_DATALT","TMP",STR0031) //"Dt. Alta"
 	oCell := TRCell():New(oSection2,"GCU_CODTPG","TMP",STR0035) //"Cod.Tp"
 	oCell := TRCell():New(oSection2,"GCU_DESTPG","TMP",STR0036) //"Tipo de Guia"
 	oCell := TRCell():New(oSection2,STR0032      ,"TMP",,,,,{|| Dias:=(dDataBase-TMP->GCY_DATALT)}) //"Dias"
		oTotaliz := TRFunction():new(oSection2:Cell("GCZ_REGATE"),,"COUNT",,STR0018,,,.T.,.F.,.F.)   //"Total de contas Abertas do Convenio---> "
 
 Else                         
 	
 	oSection1 := TRSection():New(oReport,STR0027,{"TMP"}) //"Atendimentos"
 	oCell := TRCell():New(oSection1,"GCZ_REGATE","TMP",STR0028) //"Reg.At"
 	oCell := TRCell():New(oSection1,"GCZ_NRSEQG","TMP",STR0034) //"No.Guia"
 	oCell := TRCell():New(oSection1,"GCY_NOME"  ,"TMP",STR0029) //"Nome do Paciente"
 	oCell := TRCell():New(oSection1,"GCY_DATATE","TMP",STR0030) //"Dt. Atend"
 	oCell := TRCell():New(oSection1,"GCY_DATALT","TMP",STR0031) //"Dt. Alta"
 	oCell := TRCell():New(oSection1,"GCU_CODTPG","TMP",STR0035) //"Cod.Tp"
 	oCell := TRCell():New(oSection1,"GCU_DESTPG","TMP",STR0036) //"Tipo de Guia"
 	oCell := TRCell():New(oSection1,"GCZ_CODCON","TMP",STR0026) //"Cod."
 	oCell := TRCell():New(oSection1,"GA9_NREDUZ"  ,"TMP",STR0025) //"Conv๊nio"
 	oCell := TRCell():New(oSection1,STR0032      ,"TMP",,,,,{|| Dias:=(dDataBase-TMP->GCY_DATALT)})	 //"Dias"
 	oTotaliz := TRFunction():new(oSection1:Cell("GCZ_REGATE"),,"COUNT",,STR0033,,,.T.,.F.,.F.) //"Total de contas Abertas---> "
 Endif

Return( oReport )

Static Function R39IMP(oReport)
 Local oSection1 := oReport:Section(1)
 Local oSection2 := oReport:Section(1):Section(1)
 Local cCond1 := "%%"
 Local cCond2 := "%%"
 Local cCond3 := "%%"
 
 //-- Transforma parametros Range em expressao SQL
 MakeSqlExpr(oReport:uParam)                      
 
 oSection1:BeginQuery()

	BeginSql alias "TMP"
	 SELECT GCZ_REGATE,	GCZ_NRSEQG,	GCU_CODTPG,	GCU_DESTPG,	GCY_NOME, GCY_DATATE,	GCY_DATALT,	GCZ_CODCON,	GA9_NREDUZ /*, count(*) AS QTD*/
  FROM	
	   %table:GCZ% GCZ   
	 		JOIN %table:GCY% GCY ON GCY.GCY_ATENDI = '0'
	     AND GCY.GCY_DATALT BETWEEN %Exp:Dtos(MV_PAR03)% AND %Exp:Dtos(MV_PAR04)%
	     AND GCY.GCY_DATALT <> %Exp:DTOS(CTOD("  /  /  "))%
	 			 AND GCY.GCY_REGATE = GCZ.GCZ_REGATE 
	 			 AND GCY_TPALTA <> '99'
	 			 AND GCY.GCY_FILIAL = %xFilial:GCY% 
	 			 AND GCY.D_E_L_E_T_ <> '*'
	 		JOIN %table:GCU% GCU ON GCU.GCU_CODTPG = GCZ.GCZ_CODTPG
	 			 AND GCU.GCU_FILIAL = %xFilial:GCU% AND GCU.GCU_TPGUIA <> '7'
	 			 AND GCU.D_E_L_E_T_ <> '*' 
	 		JOIN %table:GA9% GA9 ON GA9.GA9_CODCON = GCZ.GCZ_CODCON
	 			 AND GA9.GA9_FILIAL = %xFilial:GA9%
	 			 AND GA9.D_E_L_E_T_ <> '*' 
	 WHERE	GCZ.GCZ_STATUS < '4' 
	   AND GCZ.GCZ_CODCON BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
	 		AND GCZ.GCZ_FILIAL = %xFilial:GCZ%
	 		AND GCZ.D_E_L_E_T_ <> '*' 
	 ORDER BY GCZ.GCZ_CODCON, GCZ.GCZ_REGATE 
	EndSql

	oSection1:EndQuery()
	If MV_PAR05 == 1
		oSection2:SetParentQuery()
		oSection2:SetParentFilter( {|G| ("TMP")->GCZ_CODCON == G }, {|| ("TMP")->GCZ_CODCON}) // Quebra P/Convenio
	EndIf

 oSection1:Print() // processa as informacoes da tabela principal
 oReport:SetMeter(TMP->(LastRec()))
 
Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR39R3 บ Autor ณ Fabricio E. da Costa บ Data ณ 07/08/07  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Contas Abertas com Alta                                      บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HSPAHR39R3()
Local cDesc1  := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2  := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3  := ""
Local cPict   := ""
Local cTitulo := STR0003 //"Rela็ใo de contas abertas com alta"
Local nLin    := 80
Local cCabec1 := ""
Local cCabec2 := ""
Local imprime := .T.
Local aOrd    := {}
Local nLinTotal := 60


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis Privadas                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 132
Private tamanho     := "G"
Private cNomprog    := "HSPAHR39"
Private nTipo       := 15
Private aReturn     := {STR0004, 1, STR0005, 1, 1, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "HSPAHR39"
Private cString     := ""
Private aVetor      := {}
Private cConvIni    :=""
Private cConvFim    :=""
Private dDeDtAlt    :=""
Private dAteDtAlt   :=""
Private nAgrupa     :=0
Private cCodImp     := ""
Private nMaxLin     := 0

cPerg := "HSPR39"

wnrel := SetPrint(cString,cNomprog,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)
//	wnRel := SetPrint(cString,wnRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,cTamanho)
Pergunte(cPerg,.F.)
cDoConv   := MV_PAR01
cAteConv  := MV_PAR02
dDeDtAlt  := MV_PAR03
dAteDtAlt := MV_PAR04
nAgrupa   := MV_PAR05
nMaxLin   := HS_MaxLin(cCODIMP)
nLin      := nMaxLin * 2

														//                  1         2         3         4         5         6         7         8         9        10        11        12        13
														//        0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
If nAgrupa == 1 //Agrupa por Convenio
	cCabec1  := STR0006 //"Reg.At   No.Guia  Nome do Paciente                                Dt. Atend   Dt. Alta    Dias"
Else
	cCabec1  := STR0020 //"Reg.At   No.Guia  Nome do Paciente                                Dt. Atend   Dt. Alta    Convenio                            Dias"
EndIf

cCabec2  := STR0016+Dtoc(dDeDtAlt)+STR0017+Dtoc(dAteDtAlt) //"Periodo de: "###" a "

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

RptStatus({|| RunReport(cCabec1, cCabec2, cTitulo, nLin, nMaxLin)}, cTitulo)
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณFabricio E. da Costaบ Data ณ07/08/2007   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(cCabec1, cCabec2, cTitulo, nLin, nMaxLin)
Local cQuebra := ""
Local cSql    := ""
Local nTot    := 0

Set Printer to &wNRel
Set Printer On
Set Device  to Printer    
cSql+=" 	SELECT "
cSql+=" 		GCZ.GCZ_REGATE, "
cSql+=" 		GCZ.GCZ_NRSEQG, "
cSql+=" 		GCU.GCU_CODTPG, "
cSql+=" 		GCU.GCU_DESTPG, "
cSql+=" 		GCY.GCY_NOME,   "
cSql+=" 		GCY.GCY_DATATE, "
cSql+=" 		GCY.GCY_DATALT, "
cSql+=" 		GCZ.GCZ_CODCON, "
cSql+=" 		GA9.GA9_NREDUZ  "
cSql+=" FROM	" + RetSqlName("GCZ") + " GCZ   "
cSql+=" 		JOIN " + RetSqlName("GCY") + " GCY ON GCY.GCY_ATENDI = '0'"
cSQL+="     AND GCY.GCY_DATALT BETWEEN '" + Dtos(dDeDtAlt) + "' AND '" + Dtos(dAteDtAlt) + "' "
cSQL+="     AND GCY.GCY_DATALT <> '" + DTOS(CTOD("  /  /  ")) + "' "
cSql+=" 			 AND GCY.GCY_REGATE = GCZ.GCZ_REGATE "
cSql+=" 			 AND GCY_TPALTA <> '99'"
cSql+=" 			 AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' "
cSql+=" 			 AND GCY.D_E_L_E_T_ <> '*'"
cSql+=" 		JOIN " + RetSqlName("GCU") + " GCU ON GCU.GCU_CODTPG = GCZ.GCZ_CODTPG"
cSql+=" 			 AND GCU.GCU_FILIAL = '" + xFilial("GCU") + "' AND GCU.GCU_TPGUIA <> '7' "
cSql+=" 			 AND GCU.D_E_L_E_T_ <> '*' "
cSql+=" 		JOIN " + RetSqlName("GA9") + " GA9 ON GA9.GA9_CODCON = GCZ.GCZ_CODCON"
cSql+=" 			 AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' "
cSql+=" 			 AND GA9.D_E_L_E_T_ <> '*' "
cSql+=" WHERE	GCZ.GCZ_STATUS < '4' "
cSql+= "  AND GCZ.GCZ_CODCON BETWEEN '" + cDoConv + "' AND '" + cAteConv + "' "
cSql+=" 		AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' "
cSql+=" 		AND GCZ.D_E_L_E_T_ <> '*' "
cSql+=" ORDER BY GCZ.GCZ_CODCON, GCZ.GCZ_REGATE "

cSql := ChangeQuery(cSql)
TCQUERY cSql NEW ALIAS "TMPQRY"
TCSetField("TMPQRY", "GCY_DATALT" ,"D")

DbSelectArea("TMPQRY")
DbGotop()
cQuebra := ""
While !Eof()
	If nLin > nMaxLin //Se chegou a ultima linha reescreve o cabecalho
		nLin := cabec(ctitulo, cCabec1, cCabec2, cNomProg, Tamanho, nTipo) + 1
	EndIf
	If cQuebra <> TMPQRY->GCZ_CODCON .And. nAgrupa == 1//Entra qd nicio do relatorio ou mudou o convenio e esta pedindo quebra
		@nLin++,000 psay STR0019+TMPQRY->GCZ_CODCON+"-"+TMPQRY->GA9_NREDUZ   //"Convenio: "
		nTot := 0
	EndIf
	//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19
	// 0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
	//"Reg.At   No.Guia  Nome do Paciente                                Dt. Atend   Dt. Alta    Cod.Tp  Tipo de Guia                             Dias"
	// 999999   XXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   99/99/9999  99/99/9999  XXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   999
	//"Reg.At   No.Guia  Nome do Paciente                                Dt. Atend   Dt. Alta    Cod.Tp  Tipo de Guia                             Convenio                            Dias"
	// 999999   XXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   99/99/9999  99/99/9999  XXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   999
	@ nLin,000 psay Transform(TMPQRY->GCZ_REGATE, "@E 999999")
	@ nLin,009 psay TMPQRY->GCZ_NRSEQG
	@ nLin,018 psay TMPQRY->GCY_NOME
	@ nLin,066 psay TMPQRY->GCY_DATATE
	@ nLin,078 psay TMPQRY->GCY_DATALT
	@ nLin,090 psay TMPQRY->GCU_CODTPG
	@ nLin,098 psay TMPQRY->GCU_DESTPG                    
	
	If nAgrupa==2
		@ nLin,139 psay TMPQRY->GCZ_CODCON+"-"+TMPQRY->GA9_NREDUZ
	EndIf
	@ nLin,iif(nAgrupa==2,176,139) psay Strzero(dDataBase-TMPQRY->GCY_DATALT, 3) + STR0007 //" Dia(s)"
	nLin ++
	nTot ++
	cQuebra :=  TMPQRY->GCZ_CODCON
	dbskip()
	If cQuebra <> TMPQRY->GCZ_CODCON .And. nAgrupa == 1
		@nLin,000 psay STR0018 + Transform(nTot, "@E 9999")// "Total de contas Abertas do Convenio---> "
		nLin += 2
	EndIf
End
If nAgrupa == 2
	@ nLin,000 Psay STR0010 + Transform(nTot, "@E 9999") //"Total de contas Abertas ---> "
EndIf
If eof() .And. Bof()
	MsgStop(STR0008, STR0009) //"Nใo hแ pacientes com alta e conta aberta!"###"Aten็ใo"
	dbclosearea()
	Return
EndIf
dbclosearea()

Set Printer to
Set Device  to Screen
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif
MS_FLUSH()
Return(Nil)
