#include "protheus.ch"
#include "report.ch"
#include "GPER108.ch"

/*/{Protheus.doc}GPER108
Relatório de conferência de Incidências x Calculados
@author Valdeci Lira
@since 14/01/2008
@history 05/06/2008, Valdeci Lira	, Ordens que continham quebras por Centro de Custo Cadastro foram alteradas para Centro de Custo Movimento e otimizado o desempenho do relatorio
@history 16/03/2012, Leandro Dr.	, TEQU28 - Ajuste no pergunte SX1.
@history 28/06/2012, Mohanad Odeh	, TFGBHR - Declarada variável cCond como Private para ser usada como filtro na função gpRCHFiltro()
@history 11/02/2013, Ademar Jr.		, RHU210 - Implementado pra sempre tratar o campo RA_DEPTO, independente do ORG.
@history 05/05/2015, Jonathan Glz	, PCREQ-4256 - elimina la funcion Gp108RAjustaSx1, cual realiza la modificacion al diccionario dedatos(SX1) por motivo de adecuacion de nueva estructura de SXs para version 12
@history 30/06/2017, Cícero Alves	, DRHPAG-2797 Alterado o grupo de perguntas para o GP108R1 na versão 12.1.17
@history 05/04/2020, Luis Enríquez	, DMINA-8729 Se realiza modificación para que si campo RGB_DTREF no existe se haga el filtrado por RHC_DTFIM de la tabla de periosos. (MEX)
/*/
Function GPER108()

Local aArea	:= GetArea()
Local Report																		  //-> Objeto do relatorio
Private cAliasQry																	  //-> Variavel para abertura da query no Top
Private aOrd	:={	OemToAnsi(STR0004)+"+"+OemToAnsi(STR0007)						,;//1-"Matrícula 	+ Lançamentos"
					OemToAnsi(STR0011)+"+"+OemToAnsi(STR0007)						,;//2-"Nome 		+ Lançamentos"
					OemToAnsi(STR0012)+"+"+OemToAnsi(STR0004)+"+"+OemToAnsi(STR0007),;//3-"C.Custo Mov. + Matrícula + Lançamentos"
					OemToAnsi(STR0013)+"+"+OemToAnsi(STR0004)+"+"+OemToAnsi(STR0007),;//4-"Depto. 		+ Nome 		+ Lançamentos"
					OemToAnsi(STR0014)+"+"+OemToAnsi(STR0004)+"+"+OemToAnsi(STR0007)} //5-"LocPagto 	+ Matrícula + Lançamentos"
Private lUsaArqui := Iif(GetMv("MV_ORGCFG",,"0")=="0",.F.,.T.)	// 0-Nao utiliza	1-Utiliza Postos e Deptos	2-Utiliza so Deptos.

Private cRot      := ""
Private cProcesso := ""
Private cPeriodo  := ""
Private cCond	  := "1" // Variável a ser verificada no filtro da função gpRCHFiltro() -- (1=períodos abertos, 2=períodos fechados, 3=ambos)
Private cPerg	  := ""

//Verifica se exite o grupo de perguntas GP108R1
DBSelectArea("SX1")
DBSetOrder(1)
If DBSeek("GP108R1")
	cPerg := "GP108R1"
Else
	cPerg := "GP108R"
EndIf

Pergunte(cPerg,.F.)

If FindFunction("TRepInUse") .And. TRepInUse()
    oReport := ReportDef()
    oReport:PrintDialog()
EndIF

RestArea( aArea )

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportDef ºAutor  ³Valdeci Lira        º Data ³  14/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Definicao do Relatorio                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()

Local oReport															//-> Objeto para definicao do relatorio
Local oSectFunc  														//-> Section que printa as informacoes do Funcionario
Local oSectLanc															//-> Section que printa os Lancamentos e Dif do Lancamentos
Local oSectCCusto
Local oSectDepto
Local oSectLocPag
Local nTamRvDesc	:=	GetSx3Cache( "RV_DESC"		, "X3_TAMANHO" )    //-> Tamanho do campo descricao de verba do sx3
Local nTamRcHoras	:=	GetSx3Cache( "RC_HORAS"		, "X3_TAMANHO" )	//-> Tamanho do campo horas no sx3
Local nTamRcValor	:=	GetSx3Cache( "RC_VALOR"		, "X3_TAMANHO" )	//-> Tamanho do Campo valor no sx3
Local cHeaderLanc	:=	OemtoAnsi(STR0002)								//-> Incidencias  |  Calculados   | Diferencas
Private cTitulo	:= OemtoAnsi(STR0001)									//-> Incidencias x Calculados

	Define Report oReport;
		Name "GPER108";
		Title cTitulo ; 						//-> Incidencias x Calculados
		Parameter cPerg;                     //-> Grupo de Parametros de Impressao (Pergunte)
		Action {|oReport| RelFuncImp(oReport)}; //-> Funcao que imprime o relatorio
		Description OemtoAnsi(STR0001) 			//-> Incidencias x Calculados

		//Tamanho da Fonte do Relatorio
		oReport:nFontBody	:= 8
		oReport:SetDynamic()

		//SECTION 1
		Define Section oSectFunc OF oReport;
			Title OemtoAnsi(STR0006);            //->Funcionario
			Table "SRA";
			Orders aOrd

			Define Cell Name "RA_FILIAL"	Of oSectFunc Alias "SRA" Block {|| (cAliasQry)->Filial}
		 	Define Cell Name "RA_CC"		Of oSectFunc Alias "SRA" Block {|| (cAliasQry)->CentroCusto}
			Define Cell Name "RA_MAT"		Of oSectFunc Alias "SRA" Block {|| (cAliasQry)->Matricula}
			Define Cell Name "RA_NOME"		Of oSectFunc Alias "SRA" Block {|| (cAliasQry)->Ra_Nome}
			Define Cell Name "RA_SALARIO"	Of oSectFunc Alias "SRA" Block {|| (cAliasQry)->Ra_Salario}
			Define Cell Name "HEADERLANC"	Of oSectFunc Alias Title "" Size Len(cHeaderLanc) Block {|| cHeaderLanc}
			/*
			  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			  ³Propiedades da Section que exibe as informacoes do Funcionario³
			  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			*/
			oSectFunc:SetLineStyle()
			oSectFunc:Cell("RA_SALARIO"):SetCellBreak()
			oSectFunc:OnPrintLine({|| oReport:SkipLine(), oReport:ThinLine(), oReport:SkipLine()})
			oSectFunc:SetCharSeparator("")
			oSectFunc:Disable()
			oSectFunc:SetDynamicKey(OemToAnsi(STR0004))				//->Matricula

		//SECTION 2
		Define Section oSectNom OF oReport					;
			Title OemToAnsi(STR0011)						;	    //->Nome

			Define Cell Name "RA_FILIAL"	Of oSectNom Alias "SRA" Block {|| (cAliasQry)->Filial}
		 	Define Cell Name "RA_CC"		Of oSectNom Alias "SRA" Block {|| (cAliasQry)->CentroCusto}
			Define Cell Name "RA_MAT"		Of oSectNom Alias "SRA" Block {|| (cAliasQry)->Matricula}
			Define Cell Name "RA_NOME"		Of oSectNom Alias "SRA" Block {|| (cAliasQry)->Ra_Nome}
			Define Cell Name "RA_SALARIO"	Of oSectNom Alias "SRA" Block {|| (cAliasQry)->Ra_Salario}
			Define Cell Name "HEADERLANC"	Of oSectNom Alias Title "" Size Len(cHeaderLanc) Block {|| cHeaderLanc}
			oSectNom:SetLineStyle()
			oSectNom:Cell("RA_SALARIO"):SetCellBreak()
			oSectNom:OnPrintLine({|| oReport:SkipLine(), oReport:ThinLine(), oReport:SkipLine()})
			oSectNom:SetCharSeparator("")
			oSectNom:Disable()
			oSectNom:SetDynamicKey(OemToAnsi(STR0011))				//->Nome

		//SECTION 3
		Define Section oSectDepto OF oReport				;
			Title OemToAnsi(STR0011)						;		//->Nome

			Define Cell Name "QB_FILIAL"	Of oSectDepto Alias "SQB" Block {|| (cAliasQry)->Qb_Filial}
		 	Define Cell Name "QB_DEPTO"		Of oSectDepto Alias "SQB" Block {|| (cAliasQry)->Qb_Depto}
		 	Define Cell Name "QB_DESCRIC"	Of oSectDepto Alias "SQB" Block {|| (cAliasQry)->Qb_Descric}
			Define Cell Name "QB_CC"		Of oSectDepto Alias "SQB" Block {|| (cAliasQry)->Qb_CC}
			Define Cell Name "QB_REGIAO"	Of oSectDepto Alias "SQB" Block {|| (cAliasQry)->Qb_Regiao}
			oSectDepto:Disable()
			oSectDepto:SetDynamicKey(OemToAnsi(STR0013))			//->Depto
			oSectDepto:OnPrintLine({|| oReport:SkipLine(), oReport:ThinLine(), oReport:SkipLine()})
			oSectDepto:SetLineStyle()
			oSectDepto:SetCharSeparator("")

		//SECTION 4
		Define Section oSectLocPag OF oReport				;
			Title OemToAnsi(STR0011)						;		//->Nome

			Define Cell Name "RGC_FILIAL"	Of oSectLocPag Alias "RGC" Block {|| (cAliasQry)->Rgc_Filial}
		 	Define Cell Name "RGC_KEYLOC"	Of oSectLocPag Alias "RGC" Block {|| (cAliasQry)->Rgc_KeyLoc}
		 	Define Cell Name "RGC_DESLOC"	Of oSectLocPag Alias "RGC" Block {|| (cAliasQry)->Rgc_DesLoc}
			Define Cell Name "RGC_ENDER"	Of oSectLocPag Alias "RGC" Block {|| (cAliasQry)->Rgc_Ender}
			Define Cell Name "RGC_BAIRRO"	Of oSectLocPag Alias "RGC" Block {|| (cAliasQry)->Rgc_Bairro}
			Define Cell Name "RGC_CIDADE"	Of oSectLocPag Alias "RGC" Block {|| (cAliasQry)->Rgc_Cidade}
			Define Cell Name "RGC_ESTADO"	Of oSectLocPag Alias "RGC" Block {|| (cAliasQry)->Rgc_Estado}
			Define Cell Name "RGC_MUNIC"	Of oSectLocPag Alias "RGC" Block {|| (cAliasQry)->Rgc_Munic}
			Define Cell Name "RGC_CODPOS"	Of oSectLocPag Alias "RGC" Block {|| (cAliasQry)->Rgc_CodPos}
			Define Cell Name "RGC_CDAREA"	Of oSectLocPag Alias "RGC" Block {|| (cAliasQry)->Rgc_CdArea}
			Define Cell Name "RGC_FONE"		Of oSectLocPag Alias "RGC" Block {|| (cAliasQry)->Rgc_Fone}
			Define Cell Name "RGC_CVAZON"	Of oSectLocPag Alias "RGC" Block {|| (cAliasQry)->Rgc_CVAZon}
			Define Cell Name "RGC_IMPSNO"	Of oSectLocPag Alias "RGC" Block {|| (cAliasQry)->Rgc_ImpSNo}
			oSectLocPag:Disable()
			oSectLocPag:SetDynamicKey(OemToAnsi(STR0014))			//->Loc Pagto

		//SECTION 5
		Define Section oSectLanc OF oReport					;
			Title OemtoAnsi(STR0007)						;	//-> Lancamentos
			Table "SRC", "RGB"

			Define Cell Name "RC_TIPO2" Of oSectLanc		;
			Alias "RGC"										;
			Block {|| (cAliasQry)->Origem}

  			Define Cell Name "RC_PD" Of oSectLanc			;
			Alias "RGC"										;
  			Block {|| (cAliasQry)->Verba }

			Define Cell Name "DESCRICAO" Of oSectLanc 		;
			Title OemtoAnsi(STR0008)						;	//-> Descricao (Descricao da Verba)
			SIZE nTamRvDesc									;
			Block {||  (cAliasQry)->RV_DESC }

			Define Cell Name "RGB_HORAS" Of oSectLanc		;
			Alias "RGB"										;
			Block {|| (cAliasQry)->HorasRGB}

			Define Cell Name "RGB_VALOR" Of oSectLanc		;
			Alias "RGB"										;
			Block {|| (cAliasQry)->ValorRGB}

 			Define Cell Name "RC_HORAS"	Of oSectLanc		;
			Alias "RGC"										;
			Block {|| (cAliasQry)->HorasSRC}

			Define Cell Name "RC_VALOR"	Of oSectLanc		;
   			Alias "RGC"										;
			Block {|| (cAliasQry)->ValorSRC}

			Define Cell Name "DIFHORAS" Of oSectLanc		;
			Title OemToAnsi(STR0009)						;	//-> Dif Horas (Diferenca de Horas entre Incidencias e Calculados)
			SIZE nTamRcHoras								;
			Block {|| (cAliasQry)->HorasRGB - (cAliasQry)->HorasSRC}

			Define Cell Name "DIFVALOR"	Of oSectLanc		;
			Title OemToAnsi(STR0010)						;	//-> Dif Valor (Diferenca de Valor entre Incidencias e Valores)
			SIZE nTamRcValor								;
			Block {|| (cAliasQry)->ValorRGB - (cAliasQry)->ValorSRC}

		oSectLanc:Disable()
		oSectLanc:SetDynamicKey(OemToAnsi(STR0007))  			//->Lancamentos
		oSectLanc:SetHeaderBreak(.T.)

		//SECTION 6
		oSectCCusto:= TRSection():New( oReport , OemToAnsi(STR0012))//->C. Custo Mov.
			TRCell():New( oSectCCusto , "FILIALCUSTO" , "" , OemToAnsi(STR0003), NIL, NIL, NIL, {|| (cAliasQry)->Filial})//->Filial
			TRCell():New( oSectCCusto , "CENTROCUSTO" , "" , OemToAnsi(STR0015), NIL, NIL, NIL, {|| (cAliasQry)->CentroCusto})//->C Custo
			TRCell():New( oSectCCusto , "DESCCUSTO"   , "" , OemToAnsi(STR0016), NIL, NIL, NIL, {|| (cAliasQry)->Ctt_Desc01})//->Descricao
		oSectCCusto:Disable()
		oSectCCusto:SetDynamicKey(OemToAnsi(STR0012))//->C. Custo Mov.

		oReport:SetTotalInLine(.F.)

		//Section 7, Header
	DEFINE SECTION oSectionh OF oReport TITLE OemToAnsi(STR0021) TABLE "SRA" ORDERS aOrd	PAGE HEADER	//Processo / Periodo

		DEFINE CELL NAME "ARQORG"  OF oSectionh TITLE OemToAnsi(STR0021) SIZE 125		//"Arquitetura Organizacional - "
		oSectionh:SetLineStyle()
Return( oReport )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RelFuncImpºAutor  ³Valdeci Lira        ºData  ³  14/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao de Impressao do Relatorio                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RelFuncImp (oReport)

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Parametros vindos do SX1³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  */
Local cFil		:= ""
Local cCentCust	:= ""
Local cMatric	:= ""
Local cProcess	:= ""
Local cRoteir	:= ""
Local cPeriod	:= ""
Local cVerbas	:= ""
Local cNumPag	:= ""
Local cDtRefDe	:= ""
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Variaveis de Trabalho   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  */
Local cCpoAdicionais	:= "%%" //-> Armazena os possiveis campos adicionais da Query principal
Local cCpoALJ			:= "%%" //-> Armazena os possiveis campos adicionais da Query Left Join
Local cCpoARJ			:= "%%" //-> Armazena os possiveis campos adicionais da Query Right Join
Local cWhere    		:= "%%" //-> Armazena a clausula Where da Query enviada ao TOP
Local cWhereLJ		:= "%%" //-> Where Sql tratado para o Left Join
Local cWhereRJ		:= "%%" //-> Where Sql tratado para o Right Join
Local cOrderBy		:= "%%" //-> Armazena a regra de Ordenacao da Query
Local cJoinAdicional	:= "%%" //-> Armazena o possivel join adicional
Local cRegraBreak		:= ""	//-> Regra para Execucao do Break Comum nas Sections
Local nOrdem 			:= 1	//-> Ordem de Selecao do Relatorio
Local oSectLocPagto				//-> Section com as informacoes da localidade de pagamento
Local oSectDepto				//-> Section com as informacoes do departamento
Local oSectFunc					//-> Section com as informacoes do funcionario
Local oSectLanc					//-> Section com os lancamentos do funcionario
Local oSectCcusto				//-> Section com os codigos de centro de custo
Local oBreakLocPagto   			//-> Break com os totais do funcionario
Local oBreakLanc     			//-> Break com os totais do funcionario
Local oBreakDepto				//-> Break com os totais por departamento
Local oFncHrRGB   			    //-> Function do Break de Lancamento
Local oFncValor 				//-> Function do Break de Lancamento
Local oFncDifValor          	//-> Function do Break de Lancamento
Local cOrgJoin			:= ""	//-> Possivel Join por Arquitetura
Local oSectionH	:= oReport:Section(7)
Local aChaveArq	:= {}
Local lShar
Local cVisaoDepto		:= ""
Local cFilRCH           := ""
Local nX                := 0
Private cCodVisao		:= ""
Private cCodDepto		:= ""
Private aConceptos      := {}

cCodDepto	:= mv_par13
	If lUsaArqui 	//Se uas Arquitetura Organizadional (SIGAORG)
		cCodVisao	:= mv_par12
//-		cCodDepto	:= mv_par13
	Else
		cCodVisao	:= ""
//-		cCodDepto	:= ""
	EndIf
	If !Empty(cCodVisao + cCodDepto)
	   	aChaveArq	:= fQueryVisao()
		cChaveArq	:= aChaveArq[2]
		lShar		:= Iif(Empty(aChaveArq[1]),.T.,.F.)
		cOrgJoin	:= " INNER JOIN (SELECT RD4.RD4_FILIDE, RD4.RD4_CODIDE, RD4.RD4_CHAVE "
		cOrgJoin	+= " FROM " + RetSqlName("RD4") + " RD4 "
		cOrgJoin	+= " WHERE RD4_CHAVE LIKE '" + AllTrim(cChaveArq) + "%' AND RD4.D_E_L_E_T_ <> '*' ) TVRD4 "
		cOrgJoin	+= " ON RA_DEPTO = TVRD4.RD4_CODIDE "
		If !lShar
			cOrgJoin+= " AND RA_FILIAL = TVRD4.RD4_FILIDE "
		EndIf

		cVisaoDepto	:=	OemToAnsi(STR0022) + AllTrim(cCodVisao) + " / " + 	;	//"Visão: "
						OemToAnsi(STR0013) + AllTrim(cCodDepto)					//"Depto.: "

		oReport:OnPageBreak({||	oSectionh:Init(), oSectionH:Cell("ARQORG"):SetValue(cVisaoDepto), oSectionh:PrintLine(), oSectionh:Finish(), oReport:ThinLine()})
	EndIf

	nOrdem := oReport:GetOrder()
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Configura de Acordo com a Ordem Selecionada pelo usuario³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	Do Case
		Case nOrdem == 1
			oSectFunc		:= oReport:Section(1)
			oSectLanc		:= oReport:Section(5)
			oSectFunc		:Enable()
			oSectLanc		:Enable()
			cRegraBreak		:= "(cAliasQry)->Filial+(cAliasQry)->CentroCusto+(cAliasQry)->Matricula"
			cCpoAdicionais	:= "%,RA_FILIAL	, RA_MAT	, RA_CC%"
			cCpoALJ 		:= "%%"
			cCpoARJ 		:= "%%"
			cJoinAdicional	:= "%"+cOrgJoin+"%"
			cOrderBy 		:= "%RA_FILIAL	, RA_MAT	, RA_CC%"
		Case nOrdem == 2
			oSectFunc		:= oReport:Section(2)
			oSectLanc		:= oReport:Section(5)
			oSectFunc  		:Enable()
			oSectLanc  		:Enable()
			cRegraBreak		:= "(cAliasQry)->Filial+(cAliasQry)->CentroCusto+(cAliasQry)->Matricula"
			cCpoAdicionais	:= "%,RA_FILIAL	, RA_MAT	, RA_CC%"
			cCpoALJ 		:= "%%"
			cCpoARJ 		:= "%%"
			cJoinAdicional	:= "%"+cOrgJoin+"%"
			cOrderBy 		:= "% RA_FILIAL	, RA_NOME	, RA_MAT, RA_CC%"
		Case nOrdem == 3
			oSectCCusto		:= oReport:Section(6)
			oSectFunc 		:= oReport:Section(1)
			oSectLanc 		:= oReport:Section(5)
			oSectCCusto		:Enable()
			oSectFunc  		:Enable()
			oSectLanc  		:Enable()

			oBreakCCusto 	:= TRBreak():New ( oReport , {|| (cAliasQry)->Filial+(cAliasQry)->CentroCusto} , OemToAnsi(STR0017) , .F. )	//->Total do Centro de Custo
				TRFunction():New(oSectLanc:Cell("RGB_VALOR"),,"SUM",oBreakCCusto,"","@E 999,999,999,999.99", /*[ uFormula ]*/ , .F., .T.)
				TRFunction():New(oSectLanc:Cell("RC_VALOR"),,"SUM" ,oBreakCCusto,"","@E 999,999,999,999.99", /*[ uFormula ]*/ , .F., .T.)
				TRFunction():New(oSectLanc:Cell("DIFVALOR"),,"SUM" ,oBreakCCusto,"","@E 999,999,999,999.99", /*[ uFormula ]*/ , .F., .T.)

			oBreakTeste     := TRBreak():New ( oReport , {|| (cAliasQry)->CentroCusto}, , .F. )
			cRegraBreak		:= "(cAliasQry)->Filial+(cAliasQry)->CentroCusto+(cAliasQry)->Matricula"
			cCpoAdicionais	:= "%,CTT_FILIAL, CTT_CUSTO, CTT_DESC01, Ra_Filial, Ra_Mat%"
			cCpoALJ 		:= "%%"
			cCpoARJ 		:= "%%"
			cJoinAdicional	:= "%Inner Join "+ RetSqlName("CTT") +" CTT On CTT_Filial = Filial And CTT_CUSTO=CentroCusto "+cOrgJoin+"%"
			cOrderBy 		:= "%Filial, CentroCusto, Matricula%"
		Case nOrdem == 4
			oSectDepto		:= oReport:Section(3)
			oSectFunc 		:= oReport:Section(1)
			oSectLanc 		:= oReport:Section(5)
			oSectDepto 		:Enable()
			oSectFunc  		:Enable()
			oSectLanc  		:Enable()

			oBreakDepto 	:= TRBreak():New ( oReport , {|| (cAliasQry)->Filial+(cAliasQry)->DEPTO} , OemToAnsi(STR0018) , .F. )	//->Total do Departamento
				TRFunction():New(oSectLanc:Cell("RGB_VALOR"),,"SUM",oBreakDepto,"","@E 999,999,999,999.99", /*[ uFormula ]*/ , .F., .T.)
				TRFunction():New(oSectLanc:Cell("RC_VALOR"),,"SUM" ,oBreakDepto,"","@E 999,999,999,999.99", /*[ uFormula ]*/ , .F., .T.)
				TRFunction():New(oSectLanc:Cell("DIFVALOR"),,"SUM" ,oBreakDepto,"","@E 999,999,999,999.99", /*[ uFormula ]*/ , .F., .T.)

			cRegraBreak		:= "(cAliasQry)->Filial+(cAliasQry)->DEPTO+(cAliasQry)->Matricula+(cAliasQry)->CentroCusto"
			cCpoAdicionais	:= "%,QB_FILIAL, QB_DEPTO, QB_GRUPO, QB_DESCRIC, QB_CC, QB_REGIAO,"
			cCpoAdicionais  += "RA_FILIAL, RA_MAT, DEPTO, QB_DESCRIC%"
			cCpoALJ 		:= "%,RC_DEPTO DEPTO%"
			cCpoARJ 		:= "%,RGB_DEPTO%"
			cJoinAdicional	:= "%Inner Join "+ RetSqlName("SQB") +" Sqb On Qb_filial = Filial And Qb_Depto = Depto "+cOrgJoin+"%"
			cOrderBy 		:= "%RA_FILIAL, RA_DEPTO, RA_MAT, RA_CC%"
		Case nOrdem == 5
			oSectFunc		:= oReport:Section(1)
			oSectLocPagto	:= oReport:Section(4)
			oSectLanc		:= oReport:Section(5)
			oSectLocPagto 	:Enable()
			oSectFunc  		:Enable()
			oSectLanc		:Enable()
			cRegraBreak		:=	"(cAliasQry)->Filial+(cAliasQry)->CentroCusto+(cAliasQry)->Matricula"
			cCpoAdicionais	:= "%,RA_FILIAL , RA_MAT, RA_KEYLOC, "
			cCpoAdicionais  += "RGC_FILIAL, RGC_KEYLOC, RGC_DESLOC, RGC_ENDER, RGC_BAIRRO, RGC_CIDADE, "
			cCpoAdicionais  += "RGC_ESTADO, RGC_MUNIC, RGC_CODPOS, RGC_CDAREA, RGC_FONE, RGC_CVAZON, RGC_IMPSNO%"
			cJoinAdicional	:= "%Inner Join "+ RetSqlName("RGC") +" RGC On RGC_filial = Filial And RGC_KeyLoc = RA_KeyLoc "+cOrgJoin+"%"
			cOrderBy 		:= "%RA_FILIAL, RA_KEYLOC, RA_MAT, RA_CC%"

			oBreakLocPagto 	:= TRBreak():New ( oReport , {|| (cAliasQry)->Filial+(cAliasQry)->Ra_KeyLoc} , OemToAnsi(STR0019) , .F. )	//->Total da Localidade de Pagamento
				TRFunction():New(oSectLanc:Cell("RGB_VALOR"),,"SUM",oBreakLocPagto,"","@E 999,999,999,999.99", /*[ uFormula ]*/ , .F., .T.)
				TRFunction():New(oSectLanc:Cell("RC_VALOR"),,"SUM" ,oBreakLocPagto,"","@E 999,999,999,999.99", /*[ uFormula ]*/ , .F., .T.)
				TRFunction():New(oSectLanc:Cell("DIFVALOR"),,"SUM" ,oBreakLocPagto,"","@E 999,999,999,999.99", /*[ uFormula ]*/ , .F., .T.)

	EndCase

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Definicao do Break e Totais por Quebra³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	oBreakMat 	:= TRBreak():New ( oSectLanc , &("{||"+ cRegraBreak +"}") , OemToAnsi(STR0020) , .F. )	//->Total do Funcionario
	oFncHrRGB 	:= TRFunction():New(oSectLanc:Cell("RGB_VALOR"),,"SUM",oBreakMat,"","@E 999,999,999,999.99", /*[ uFormula ]*/ , .F., .T.)
	oFncValor 	:= TRFunction():New(oSectLanc:Cell("RC_VALOR"),,"SUM" ,oBreakMat,"","@E 999,999,999,999.99", /*[ uFormula ]*/ , .F., .T.)
	oFncDifValor:= TRFunction():New(oSectLanc:Cell("DIFVALOR"),,"SUM" ,oBreakMat,"","@E 999,999,999,999.99", /*[ uFormula ]*/ , .F., .T.)

	/*
	  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³Abertura da Query principal do programa|
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	#IFDEF TOP
		/*Transforma parametros do tipo Range em expressao
    	  SQL para ser utilizada no filtro de Query*/
		MakeSqlExpr(cPerg)

		If( !Empty(MV_PAR01) )
			cFil := " " + MV_PAR01 + " And"
		EndIf

		If( !Empty(MV_PAR02) )
			cCentCust := " " + MV_PAR02 + " And"
		EndIf

		If( !Empty(MV_PAR03) )
			cMatric := " " + MV_PAR03 + " And"
		EndIf

		If( !Empty(MV_PAR04) )
			cProcess := " (RC_PROCES = '" + AllTrim(MV_PAR04) + "' ) AND "
		EndIf

		If( !Empty(MV_PAR05) )
			cRoteir := " (RC_ROTEIR = '" + AllTrim(MV_PAR05) + "') And "
		EndIf

		If( !Empty(MV_PAR06) )
			cPeriod := " (RC_PERIODO = '" + AllTrim(MV_PAR06) + "') And "
		EndIf

		If( !Empty(MV_PAR07) )
			cNumPag := " (RC_NUMPAG = '" + AllTrim(MV_PAR07) + "') And"
		EndIf
		
		If (Alltrim(MV_PAR08)=="*") .Or. (Alltrim(MV_PAR09)=="*")
			cVerbas := ""
		Else
			If !Empty(MV_PAR08)
				fQuebraMV(MV_PAR08, "VERBAS",@aConceptos)
			EndIf
			If !Empty(MV_PAR09)
				fQuebraMV(MV_PAR09, "VERBAS",@aConceptos)
			EndIf	
			For nX:=1 To Len(aConceptos)
				cVerbas += IIf(nX==1,"",",") + aConceptos[nX]
			Next nX			
		EndIf
		
		If( !Empty(cVerbas) )
			cVerbas := " (RC_PD IN(" + cVerbas + ")) And "
		EndIf
		
		If !Empty(MV_PAR10) .Or. !Empty(MV_PAR11)
			//Filial de periodo
			cFilRCH  := " (RCH_FILIAL = '" + xFilial("RCH") + "') And"
			cDtRefDe := " CASE "
			cDtRefDe += "WHEN RC_DTREF <> '' " + IIf(!Empty(MV_PAR10)," AND RC_DTREF >= '"+ Dtos(MV_PAR10) + "'","") + IIf(!Empty(MV_PAR11)," AND RC_DTREF <= '"+ DTos(MV_PAR11) + "'","")  + " THEN 1 "
			cDtRefDe += "WHEN RC_DTREF = ''" + IIf(!Empty(MV_PAR10)," AND RCH_DTFIM >= '"+ Dtos(MV_PAR10) + "'","")  + IIf(!Empty(MV_PAR11)," AND RCH_DTFIM <= '"+ DTos(MV_PAR11) + "'","") + " THEN 1 "
			cDtRefDe += "END = 1 "	    
		EndIf
		
        //Cria a Clausula Where
        cWhere := AllTrim(cFil + cCentCust + cMatric + cVerbas + cProcess + cRoteir + cPeriod + cNumPag + cFilRCH + cDtRefDe)

        If ("AND" == Upper(SubStr(cWhere, Len(cWhere)-2, 3)))
        	cWhere := SubStr(cWhere, 1, Len(cWhere)-3)
        EndIf
		cWhere:= StrTran(cWhere  , "RGB_NUMPAG", "RGB_SEMANA")
		If !Empty(cWhere)
			cWhereLJ := "% WHERE "+cWhere+"%"
            cWhereLJ:= StrTran(cWhereLJ, "RA_", "RC_")    
			cWhereLJ:= StrTran(cWhereLJ  , "NUMPAG", "SEMANA")
			cWhereRJ:= StrTran(cWhereLJ, "RC_", "RGB_")
			cWhereRJ:= StrTran(cWhereRJ  , "PERIODO", "PERIOD")
		Else
			cWhere	:= "%%"
			cWhereLJ:= "%%"
			cWhereRJ:= "%%"
		EndIf

		cAliasQry := GetNextAlias()
		Do Case
			Case nOrdem == 3
				Begin Report Query oSectCCusto
			Case nOrdem == 4
				Begin Report Query oSectDepto
			Case nOrdem == 5
				Begin Report Query oSectLocPagto
			OtherWise
				Begin Report Query oSectFunc
		End Case

		BeginSql alias cAliasQry
			column RGB_DTREF as Date

	   		Select
				FILIAL	, CENTROCUSTO	, MATRICULA	, ORIGEM	, RA_NOME	, RA_SALARIO,
				VERBA	, RV_DESC		, HORASSRC	, VALORSRC	, HORASRGB	, VALORRGB
				%exp:cCpoAdicionais%
			From
			(
				Select
					RC_FILIAL FILIAL	, RC_CC CENTROCUSTO	, RC_MAT MATRICULA	, RC_TIPO2 ORIGEM	,
					RC_PD VERBA			, RC_HORAS HORASSRC	, RC_VALOR VALORSRC	, RGB_HORAS HORASRGB,
					RGB_VALOR VALORRGB
					%exp:cCpoALJ%
				From
					%Table:SRC% Src Left Join %Table:RGB% Rgb	On	Rc_Filial  = Rgb_Filial
																And Rc_Mat     = Rgb_Mat
																And Rc_Proces  = Rgb_Proces
																And Rc_Periodo = Rgb_Period
																And Rc_Semana  = Rgb_Semana
																And Rc_Pd      = Rgb_Pd
																And Rc_Seq     = Rgb_Seq
													   			And Rc_Roteir  = Rgb_Roteir
																And Rc_CC      = Rgb_CC
					/*																											/*
					ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³Na variavel cWhere contem a clausula Where montada³
					³a partir da pergunta                              ³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					*/
					Inner Join %Table:RCH% Rch
									On RCH_PROCES  = Rc_Proces
									And RCH_PER    = Rc_Periodo					
									And RCH_NUMPAG = Rc_Semana
									And RCH_ROTEIR = Rc_Roteir					
					%exp:cWhereLJ%

				/*************UNIAO DOS SELECTS LEFT E RIGHT JOIN*******************/
											UNION
		   		/*******************************************************************/
				Select
					RGB_FILIAL FILIAL, RGB_CC CENTROCUSTO, RGB_MAT MATRICULA, RGB_TIPO2 ORIGEM, RGB_PD VERBA,
					RC_HORAS HORASSRC, RC_VALOR	VALORSRC, RGB_HORAS HORASRGB, RGB_VALOR VALORRGB
					%exp:cCpoARJ%
				From
					%Table:SRC% Src Right Join %Table:RGB% Rgb On Rc_Filial  = Rgb_Filial
															 And Rc_Mat     = Rgb_Mat
															 And Rc_Proces  = Rgb_Proces
															 And Rc_Periodo = Rgb_Period
															 And Rc_Semana  = Rgb_Semana
															 And Rc_Pd      = Rgb_Pd
															 And Rc_Seq     = Rgb_Seq
															 And Rc_Roteir  = Rgb_Roteir
															 And Rc_CC      = Rgb_CC

					/*
					ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³Na variavel cWhere contem a clausula Where montada³
					³a partir da pergunta                              ³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					*/
					//PERIODOS
					Inner Join %Table:RCH% Rch
									On RCH_PROCES  = Rgb_Proces
									And RCH_PER    = Rgb_Period					
									And RCH_NUMPAG = Rgb_Semana
									And RCH_ROTEIR = Rgb_Roteir
					%exp:cWhereRJ%
			) As tView
			Inner Join %Table:SRA% Sra
									On  Ra_filial = Filial
									And Ra_mat    = Matricula
			Inner Join %Table:SRV% Srv
									On Rv_cod = Verba
			%exp:cJoinAdicional%
	   		Order By %exp:cOrderBy%

       EndSql

	    Do Case
	    	Case nOrdem == 3
				End Report Query oSectCCusto
				oSectFunc:SetParentQuery()
	    	Case nOrdem == 4
				End Report Query oSectDepto
				oSectFunc:SetParentQuery()
			Case nOrdem == 5
				End Report Query oSectLocPagto
				oSectFunc:SetParentQuery()
	    	OtherWise
				End Report Query oSectFunc
		End Case
	#ENDIF

	/*
	  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³Propiedades da Section que exibe as informacoes dos Lancamentos³
  	  ³dos Funcionarios considerando a relacao de Incidencias x Calcul|
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	oSectLanc:SetParentQuery()

	Do Case
		Case nOrdem == 1 .Or. nOrdem == 2
			oSectLanc:SetParentFilter	(																		;
										{|cParam| (cAliasQry)->Filial    + (cAliasQry)->Matricula == cParam} , 	;
										{|| 	  (cAliasQry)->Ra_Filial + (cAliasQry)->Ra_Mat}			   		;
										)
		Case nOrdem == 3
			//MONTA O CONJUNTO DE DEPARTAMENTOS PARA IMPRIMIR
			oSectFunc:SetParentFilter	(																		;
										{|cParam| (cAliasQry)->Filial    +(cAliasQry)->CentroCusto == cParam} , 		;
										{|| 	  (cAliasQry)->CTT_Filial+(cAliasQry)->CTT_CUSTO}		   			;
										)
			//MONTA O CONJUNTO DE LANCAMENTOS DE UM FUNCIONARIO
		   	oSectLanc :SetParentFilter	(																		;
										{|cParam| (cAliasQry)->Filial    +(cAliasQry)->CentroCusto+ (cAliasQry)->Matricula == cParam} ,	;
										{|| 	  (cAliasQry)->Ra_Filial +(cAliasQry)->CentroCusto+ (cAliasQry)->Ra_Mat}		   			;
										)
		Case nOrdem == 4
			//MONTA O CONJUNTO DE DEPARTAMENTOS PARA IMPRIMIR
			oSectFunc:SetParentFilter	(																		;
										{|cParam| (cAliasQry)->Filial    + (cAliasQry)->DEPTO == cParam} , 		;
										{|| 	  (cAliasQry)->Ra_Filial + (cAliasQry)->DEPTO}		   			;
										)

			//MONTA O CONJUNTO DE LANCAMENTOS DE UM FUNCIONARIO
		   	oSectLanc :SetParentFilter	(																		;
										{|cParam| (cAliasQry)->Filial    + (cAliasQry)->Matricula == cParam} ,	;
										{|| 	  (cAliasQry)->Ra_Filial + (cAliasQry)->Ra_Mat}		   			;
										)

		Case nOrdem == 5
			oSectFunc:SetParentFilter	(																		;
										{|cParam| (cAliasQry)->Filial    + (cAliasQry)->RA_KEYLOC == cParam} , 	;
										{|| 	  (cAliasQry)->Ra_Filial + (cAliasQry)->RA_KEYLOC}		   		;
										)
			oSectLanc:SetParentFilter	(																		;
										{|cParam| (cAliasQry)->Filial    + (cAliasQry)->Matricula == cParam} , 	;
										{|| 	  (cAliasQry)->Ra_Filial + (cAliasQry)->RA_Mat}		   		;
										)
	EndCase

	/*
	  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³Impressao do Relatorio ³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	oReport:SetMeter( (cAliasQry)->(RecCount()) )	//-> Seta a Regua de Impressao

	Do Case
		Case nOrdem == 3
			oSectCCusto:Print()
		Case nOrdem == 4
			oSectDepto:Print()	 		   					//-> Start na impressao do relatorio
		cASE nOrdem == 5
			oSectLocPagto:Print()	   				   		//-> Start na impressao do relatorio
		OtherWise
			oSectFunc:Print()	 		   					//-> Start na impressao do relatorio
	End Case

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GP108R    ºAutor  ³Valdeci Lira        º Data ³  22/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Quebra o conteudo do MV informado na caixa de parametros de º±±
±±º          ³impressao, quebra a string em pedacos de acordo com o tamanhº±±
±±º          ³do campo no SX3                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fQuebraMv(cConteudo, cTipo, aConceptos)
Local nTamStr := 0
Local nTamTot := 0
Local nI      := 0
Local cVirg   := ""
Local cRet    := ""
Local nPos    := 0

	Do Case
		Case cTipo == "NUMPAG"
			nTamStr := GetSx3Cache( "RC_SEMANA"  , "X3_TAMANHO")
		Case cTipo == "VERBAS"
			nTamStr := GetSx3Cache( "RV_COD" 	  , "X3_TAMANHO")
		Case cTipo == "ROTEIR"
			nTamStr := GetSx3Cache( "RC_ROTEIR"  , "X3_TAMANHO")
	EndCase

	If nTamStr > 0
		nI		:= 1
    	cVirg	:= ""
	    cRet	:= ""
    	nTamTot	:= Len(AllTrim(cConteudo))
		While nI < nTamTot
			cRet	:=	cRet + cVirg
			cRet 	:= cRet + "'" + SubStr(cConteudo, nI, nTamStr) + "'"
			nPos := AScan(aConceptos,Alltrim("'" + SubStr(cConteudo, nI, nTamStr) + "'"))
			If nPos == 0
				aAdd(aConceptos,"'" + SubStr(cConteudo, nI, nTamStr) + "'")
			EndIf
			cVirg	:= ","
			nI   	:= nI + nTamStr
		EndDo

		If Empty(cRet) .and. !Empty(cConteudo)
			cRet := "'" + Alltrim(cConteudo) + "'"
		EndIf
	EndIf
Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ fQueryVisao   ³ Autor ³ Tania Bronzeri        ³ Data ³19/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Pesquisa Visao / Departamento para a Arquitetura Organizacional.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER108                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fQueryVisao()

Local aArea		:= GetArea()
Local aChave	:= array(2)
Local cQuery 	:= ""
Local cQryAlias	:= GetNextAlias()

dbSelectArea("RD4")
dbCloseArea()
cQuery := "SELECT RD4.RD4_CHAVE, RD4.RD4_FILIDE FROM " + RetSqlName("RD4") + " RD4 "
cQuery += "INNER JOIN " + RetSqlName("RDK") + " RDK "
cQuery += "ON RD4_CODIGO = RDK_CODIGO AND RD4_FILIAL = RDK_FILIAL "
cQuery += "WHERE RD4_CODIDE = '" + cCodDepto + "' AND RDK_HIERAR = '1' AND RDK_CODIGO = '" + cCodVisao + "' "
cQuery += "AND RD4.D_E_L_E_T_ <> '*' AND RDK.D_E_L_E_T_ <> '*' "
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQryAlias,.T.,.T.)

aChave[1]	:= (cQryAlias)->RD4_FILIDE
aChave[2]	:= (cQryAlias)->RD4_CHAVE

(cQryAlias)->(DbCloseArea())

RestArea( aArea )

Return aChave
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ fSetProcesso   ³ Autor ³ Tatiane Matias       ³ Data ³13/05/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega a variavel private cProcesso que sera utilizada para    ³±±
±±³          ³ filtro do campo de periodo.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER108                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fSetProcesso()
Local cCont := &(ReadVar())
	cProcesso := Padr( cCont, GetSx3Cache("RCJ_CODIGO","X3_TAMANHO"))
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ fSetPeriodo    ³ Autor ³ Tatiane Matias       ³ Data ³13/05/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega a variavel private cPeriodo que sera utilizada para fil-³±±
±±³          ³ tro do campo de numero de pagamento                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER108                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fSetPeriodo()
Local cCont := &(ReadVar())
	cPeriodo := Padr( cCont, GetSx3Cache("RCH_PER","X3_TAMANHO"))
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ fSetRoteiro    ³ Autor ³ Tatiane Matias       ³ Data ³13/05/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega a variavel private cRot que sera utilizada para filtro  ³±±
±±³          ³ do campo de periodo.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER108                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fSetRoteiro()
Local cCont := &(ReadVar())
	cRot := Padr( cCont, GetSx3Cache("RY_CALCULO","X3_TAMANHO"))
Return
