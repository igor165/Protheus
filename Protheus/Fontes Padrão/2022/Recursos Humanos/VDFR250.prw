#INCLUDE "VDFR250.ch"
#Include "Totvs.Ch"
#Include "Report.Ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VDFR250  ³ Autor ³ Robson Soares de Morais³ Data ³  03.01.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Quadro do Grupo de Provimento em Cargo Efetivo por Categoria ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR250(void)                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³      ³                                          ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Function VDFR250()

Private oReport
Private cString	:= "SRA"
Private cPerg		:= "VDFR250"
Private aOrd    	:= {}
Private cTitulo	:= STR0001 //'Quadro do Grupo de Provimento em Cargo Efetivo por Categoria'
Private cAliasQRY := ""
Private oQ3_DESCSUM

Pergunte(cPerg, .F.)
M->RA_FILIAL := ""	// Variavel para controle da numeração

oReport := ReportDef()
oReport:PrintDialog()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportDef  ³ Autor ³ Robson Soares de Morais³ Data ³ 03.01.14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Montagem das definições do relatório                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR250                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR250 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReportDef()

Local cDescri  := STR0002 //"Relatórios quantitativos mensais atualizados sempre que há alteração no quadro de ocupação dos cargos comissionados, efetivos e membros"

oReport := TReport():New(cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo)}, cDescri)

oReport:OnPageBreak( { || If(oReport:oPage:nPage > 1, (oReport:Section(1):Init(), oReport:Section(1):PrintLine(), oReport:Section(1):Finish()), .F.) })
oReport:nFontBody := 7

oFilial := TRSection():New(oReport, STR0003, { "SM0" }) //'Filiais'
oFilial:SetLineStyle()
oFilial:cCharSeparator := ""
oFilial:nLinesBefore   := 0

oFilial:bOnPrintLine := { || (oReport:SkipLine(), 	oReport:PrintText(AllTrim(RetTitle("RA_FILIAL")) + ': ' +;
													(cAliasQry)->(RA_FILIAL) + " - " +;
													fDesc("SM0", cEmpAnt + (cAliasQry)->(RA_FILIAL), "M0_NOMECOM")), .F.) } 

TRCell():New(oFilial,"RA_FILIAL","SRA")
TRCell():New(oFilial, "", "", '-',,, /*lPixel*/,/*bBlock*/ { || fDesc("SM0", cEmpAnt + (cAliasQry)->(RA_FILIAL), "M0_NOMECOM") } )

oSimbolo := TRSection():New(oFilial, STR0004, ( "RBR" )) //'Simbolo'
oSimbolo:SetLineStyle()
oSimbolo:cCharSeparator := ""
oSimbolo:nLinesBefore   := 0
oSimbolo:bOnPrintLine := { || (oReport:SkipLine(), oReport:PrintText(Space(5) + STR0004 + ': ' + (cAliasQry)->(RBR_SIMBOL)),oReport:SkipLine(), .F.) } 

TRCell():New(oSimbolo,"RBR_SIMBOL","RBR",STR0004)

oCargo := TRSection():New(oSimbolo, STR0005, ( "SRA","SQ3","RCC" ),,,,,,,,,,,.F.) //'Servidores'
oCargo:nLinesBefore   := 0
oCargo:SetLeftMargin(15)
oCargo:SetCellBorder("ALL",,, .T.)
oCargo:SetCellBorder("RIGHT")
oCargo:SetCellBorder("LEFT")
oCargo:SetCellBorder("BOTTOM")

oBranco := TRCell():New(oCargo,"","", '-',,, /*lPixel*/,/*bBlock*/ { || oQ3_DESCSUM:SetTitle((caliasQry)->(RBR_DESCTA)) } )
oBranco:Disable()

oQ3_DESCSUM := TRCell():New(oCargo,"Q3_DESCSUM","SQ3",STR0006,,50) //Denominação dos Cargos //'Cargo'

TRCell():New(oCargo, "SQ3_VAGAS","",STR0007, "@E 99999",, /*lPixel*/, { || (cAliasQry)->(SQ3_VAGAS) }, /*cAlign*/) //Quantidade Cargos //'Número de Vagas'
TRCell():New(oCargo, "EFETIVO","",STR0008, "@E 99999",, /*lPixel*/,{ || (cAliasQry)->(EFETIVO) }, /*cAlign*/) //Numero de Servidores efetivos ocupando a vaga //'Efetivo'
TRCell():New(oCargo, "COMISSAO","",STR0009, "@E 99999",, /*lPixel*/,{ || (cAliasQry)->(COMISSAO) }, /*cAlign*/) //Numero de Servidores ocupando a vaga de comissionado //'Comissão'
TRCell():New(oCargo, "VAGOS","",STR0010, "@E 99999",, /*lPixel*/,{ || (cAliasQry)->(VAGOS) }, /*cAlign*/) //Cargos vagos. (Numero de Vagas - (Efetivo + Comissionado)) = Vagos //'Vagos'

oBrkGrupo := TRBreak():New(oCargo, { || (cAliasQry)->RBR_SIMBOL },{|| "TOTAL/CARGOS" },,,.F.)	//	" TOTAL/CARGOS "

oTSQ3_VAGAS := TRFunction():New(oCargo:Cell("SQ3_VAGAS"),,"SUM",oBrkGrupo/*oBreak*/,/*Titulo*/, "@E 99999",;
							{ || (cAliasQry)->SQ3_VAGAS },.F.,.F.,.F.,oCargo)

oTEFETIVO := TRFunction():New(oCargo:Cell("EFETIVO"),,"SUM",oBrkGrupo/*oBreak*/,/*Titulo*/, "@E 99999",;
							{ || (cAliasQry)->EFETIVO },.F.,.F.,.F.,oCargo)

oTCOMISSAO := TRFunction():New(oCargo:Cell("COMISSAO"),,"SUM",oBrkGrupo/*oBreak*/,/*Titulo*/, "@E 99999",;
							{ || (cAliasQry)->COMISSAO },.F.,.F.,.F.,oCargo)

oTVAGOS := TRFunction():New(oCargo:Cell("VAGOS"),,"SUM",oBrkGrupo/*oBreak*/,/*Titulo*/, "@E 99999",;
							{ || (cAliasQry)->VAGOS },.F.,.F.,.F.,oCargo)

Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportPrint ³ Autor ³ Wagner Mobile Costa  ³ Data ³ 01.01.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Impressão do conteúdo do relatório                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR250                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR250 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReportPrint(oReport)

Local oFilial		:= oReport:Section(1), oSimbolo := oReport:Section(1):Section(1), oCargo := oReport:Section(1):Section(1):Section(1), cWhere := "%"
Local cRBR_TABELA	:= "", nTamTabela := GetSx3Cache( "RBR_TABELA", "X3_TAMANHO" ), nCont := 0, cWhereRBR := cWhereQ3 := "%%"
Local cQ3_TIPO		:= "", nTQ3_TIPO  := GetSx3Cache( "Q3_TIPO", "X3_TAMANHO" )
Local cFilParam		:= ""
Local cJoinRCC		:= ""
Local cJoinRBR		:= ""
Local cJoinSQ3		:= ""
Local cFilRBR		:= "'  ',"
Local nX			:= 0
Local aFilParam		:= {}

cAliasQRY := GetNextAlias()

//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
MakeSqlExpr(cPerg)
If At("RA_FILIAL IN",MV_PAR01)>0
	cFilParam:= StrTran(StrTran(StrTran(MV_PAR01,"RA_FILIAL IN",''),"((",""),"))","")
Else
	cFilParam:= Alltrim(StrTran(StrTran(StrTran(StrTran(MV_PAR01,"RA_FILIAL BETWEEN",''),"(",""),")","")," AND ",","))
EndIf
aFilParam	:= iif(!Empty(cFilParam),STRTOKARR(cFilParam,","),)

cJoinSQ3	:= "%"+ FWJoinFilial("SRA","SQ3")+"%"
cJoinRCC	:="%"+ FWJoinFilial("SRA","RCC")+"%"
cJoinRBR	:= "%"+ FWJoinFilial("SQ3","RBR")+"%"
cFilRBR		:= f_QbrFil("RBR",aFilParam)
cMV_PAR		:= ""
if !empty(MV_PAR01)		//-- Filial
	cMV_PAR += " AND " + MV_PAR01
EndIf
if !empty(MV_PAR02)		//-- Matricula
	cMV_PAR += " AND " + MV_PAR02
EndIf
cMV_PAR += "%"
If "IN" $ MV_PAR01
	cFilRBR:= "% AND RBR_FILIAL IN (" +cFilRBR+") %"
ElseIf !empty(MV_PAR01)
	cFilRBR:= "% AND RBR_FILIAL BETWEEN " +REPLACE(REPLACE(cFilRBR,"' ',",""),","," AND " ) +"%"
Else
	cFilRBR:= "%	%"
EndIf
cWhere += cMV_PAR

//-- Monta a string de Tipos de Cargo
If AllTrim( mv_par03 ) <> Replicate("*", Len(AllTrim( mv_par03 )))
	cQ3_TIPO   := ""
	For nCont  := 1 to Len(Alltrim(mv_par03)) Step nTQ3_TIPO
		cQ3_TIPO += "'" + Substr(mv_par03, nCont, nTQ3_TIPO) + "',"
	Next
	cQ3_TIPO := Substr( cQ3_TIPO, 1, Len(cQ3_TIPO)-1)
	If !Empty(AllTrim(cQ3_TIPO))
		cWhereQ3 := '%AND Q3_TIPO IN (' + cQ3_TIPO + ')%'
	EndIf
EndIf

oFilial:BeginQuery()

BeginSql Alias cAliasQRY

SELECT SRA.RA_FILIAL, RBR.RBR_SIMBOL, RBR.RBR_DESCTA, SQ3.Q3_DESCSUM, MIN(RCC.SQ3_VAGAS) AS SQ3_VAGAS,
       COUNT(CASE WHEN RA_CATFUNC IN (%Exp:'2'%, %Exp:'5'%) THEN 1 ELSE NULL END) AS EFETIVO,
       COUNT(CASE WHEN RA_CATFUNC = %Exp:'3'% THEN 1 ELSE NULL END) AS COMISSAO,
       MIN(RCC.SQ3_VAGAS) - COUNT(CASE WHEN RA_CATFUNC IN (%Exp:'2'%, %Exp:'5'%) THEN 1 ELSE NULL END) -
                            COUNT(CASE WHEN RA_CATFUNC = %Exp:'3'% THEN 1 ELSE NULL END) AS VAGOS
  FROM %table:SRA% SRA
  JOIN %table:SQ3% SQ3 ON	SQ3.%notDel% AND 
  					 	%Exp:cJoinSQ3% AND SQ3.Q3_CARGO = SRA.RA_CARGO %Exp:cWhereQ3%
   						AND SQ3.Q3_TABELA <> %Exp:' '%
  JOIN (SELECT RBR.RBR_FILIAL,RBR.RBR_TABELA, RBR.RBR_DESCTA, RBR.RBR_SIMBOL 
          FROM %table:RBR% RBR
         WHERE 	RBR.%notDel% %Exp:cWhereRBR% AND 
         			RBR.R_E_C_N_O_ IN (
         			SELECT MAX(R_E_C_N_O_) FROM %table:RBR% 
         				 WHERE 	%notDel%  %Exp:cFilRBR% AND 
     									RBR_TABELA = RBR.RBR_TABELA AND 
         										RBR_DTREF < %Exp:Dtos(dDataBase)%
         										GROUP BY 
         										RBR_FILIAL	)) RBR 
		ON RBR.RBR_TABELA = SQ3.Q3_TABELA AND %Exp:cJoinRBR%  
  LEFT JOIN (SELECT RCC_FILIAL, RCC_FIL,
                    SUBSTRING(RCC_CONTEU, 1, 5) AS RA_CARGO,
                    SUM(CAST(SUBSTRING(RCC_CONTEU, 13, 5) AS INTEGER)) AS SQ3_VAGAS
             FROM %table:RCC% RCC
             WHERE %notDel% AND RCC_CODIGO = %Exp:'S111'% 
             GROUP BY 
             		RCC_FILIAL,RCC_FIL, 
             		SUBSTRING(RCC_CONTEU, 1, 5)) RCC 
 		ON 	 %Exp:cJoinRCC% AND (RCC.RCC_FIL = SRA.RA_FILIAL OR RCC.RCC_FIL = '' )  AND 
 			RCC.RA_CARGO = SRA.RA_CARGO
 WHERE 	SRA.%notDel% %Exp:cWhere% AND 
 		SRA.RA_CATFUNC IN (%Exp:'2'%, %Exp:'3'%) AND 
 		(SRA.RA_DEMISSA = %Exp:' '% OR SRA.RA_DEMISSA > %Exp:Dtos(dDataBase)%)
 
 GROUP BY SRA.RA_FILIAL, RBR.RBR_SIMBOL, RBR.RBR_DESCTA, SQ3.Q3_DESCSUM
 ORDER BY SRA.RA_FILIAL, RBR.RBR_SIMBOL, RBR.RBR_DESCTA, SQ3.Q3_DESCSUM

EndSql

oFilial:EndQuery()

oSimbolo:SetParentQuery()
oSimbolo:SetParentFilter({|cParam| (cAliasQRY)->RA_FILIAL == cParam}, {|| (cAliasQRY)->RA_FILIAL  })

oCargo:SetParentQuery()
oCargo:SetParentFilter({|cParam| (cAliasQRY)->(RA_FILIAL + RBR_SIMBOL) == cParam}, {|| (cAliasQRY)->(RA_FILIAL + RBR_SIMBOL) })

oFilial:Print()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ TipoRH  ³ Autor ³ Wagner Mobile Costa    ³ Data ³ 27/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna lista de opções utilizando a tabela SX5 (RH)  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ TipoRX() 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function R250TipoRH()

Local aArea := GetArea(), aLista := {}, MvParDef := "", nTam := 2

CursorWait()

DbSelectArea("SX5")
DbSetOrder(1)
DbSeek(xFilial() + "RH")

While !Eof() .And. X5_FILIAL + X5_TABELA == xFilial("SX5") + "RH"
	Aadd(aLista, AllTrim(SX5->X5_CHAVE + " - " + SX5->X5_DESCRI))
	MvParDef += AllTrim(SX5->X5_CHAVE)
	dbSkip()
Enddo

CursorArrow()

MvPar := &(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
mvRet := Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

If f_Opcoes(@MvPar, STR0011, aLista, MvParDef, 12, 49, .F., nTam) //'Tipos de Cargo'
	&MvRet := mvpar                                                                          // Devolve Resultado
EndIF

RestArea(aArea)

Return .T.


