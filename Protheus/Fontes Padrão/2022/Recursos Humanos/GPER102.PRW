#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER102.CH"
#INCLUDE "Report.ch"
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPER102   ºAutor  ³Tania Bronzeri           º Data ³ 08/08/2007   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para tratar a emissao do relatorio mensal.                º±±
±±º          ³ Formato Vertical                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Folha de pagamento  - Mexico                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador³ Data     ³ BOPS           ³ Motivo da Alteracao                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCarlos O.  ³03/09/2013³M12RH01  184702 ³Ajustes referentes a ordem de impres º±±
±±º           ³          ³                ³sao escolhida. Checa existencia      º±±
±±º           ³          ³                ³dos campos RA_KEYLOC, RA_CODRPAT.    º±±
±±º           ³          ³                ³Retirada funcao Gp102RAjustaSx1().   º±±
±±ºSidney O.  ³19/03/2014³M_RH003  294901 ³Criacao dos totalizadores por        º±±
±±º           ³          ³                ³Unidade de Negocio e Empresa         º±±
±±ºSidney O.  ³24/06/2014³M_RH003  294901 ³Correcao de bug na criacao de filtro º±±
±±ºSidney O.  ³07/07/2014³M_RH003  294901 ³Bug duplicacao de valores. Adicionadaº±±
±±º           ³          ³                ³restricao para nao incluir valores   º±±
±±º           ³          ³                ³excluidos da SQB                     º±±
±±ºRenan B.   ³27/05/2016³TVFSSG          ³Ajuste para imprimir relatório de va-º±±
±±º           ³          ³                ³lores por verba no período vertical. º±±
±±º           ³          ³                ³Quando func não possui departamento  º±±
±±º           ³          ³                ³seus valores vem Nulos.              º±±
±±³Gustavo M. ³30/05/2016³TVFFAD  		  ³Ajuste p/ considerar o controle 		º±±
±±º           ³          ³                ³de acesso de usuario.			    º±±
±±³Esther V.  ³31/05/2016³TVFY37  		  ³Ajuste p/ considerar o controle 		º±±
±±º           ³          ³                ³de acesso de usuario - correcao.	    º±±
±±ºRenan B.   ³19/08/2016³TVNNK6          ³Ajuste para ao gerar o relatorio da  º±±
±±º           ³          ³                ³folha de pagamento vertical possuindoº±±
±±º           ³          ³                ³funcionários com a mesma matricula emº±±
±±º           ³          ³                ³filiais diferentes seja impressos os º±±
±±º           ³          ³                ³valores corretos, respeitando as suasº±±
±±º           ³          ³                ³filiais.                             º±±
±±ºGabriel A. ³16/09/2016³TVTOWN          ³Ajuste no filtro de verba na         º±±
±±º           ³          ³                ³construção da query.                 º±±
±±ºOswaldo    ³03/01/2017³MRH-4340        ³Substituimos as chamadas da função   º±±
±±ºLeite      ³          ³                ³“fGetJOINGestaoEmpresa”              º±±
±±º           ³          ³                ³por “fGetJOINGestEmp”                º±±
±±ºPaulo O.   ³24/05/2017³DRHPAG-903      ³Ajuste na montagem da query para     º±±
±±ºInzonha    ³          ³                ³tratar error log                     º±±
±±ºJaqueline  ³08/02/2018³DRHPAG-DRHPAG-  ³Correção na criação do filtro C  e   º±±
±±ºLaurenti   ³          ³ 13623          ³Filtro D                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPER102()

	Local	oReport   
	Local	aArea 				:= GetArea()
	Private cPerg				:= "GPE102R"
	Private aOrd				:={}
	Private cProcesso 			:= ""
	Private cPeriodo			:= ""
	Private cPagamento			:= ""
	Private cRot    			:= ""	  
	Private cHDV				:= ""	//Horas / Dias / Valores
	Private cPDB				:= ""	//Proventos / Descontos / Bases
	Private cAliasQry			:= ""
	Private cTitulo			    := OemToAnsi(STR0012)	//"Valores por Verba no Período"
	Private nOrdem				:= 1
	Private nSinAna   			:= 0
	Private lUsaArqui			:= Iif(GetMv("MV_ORGCFG",,"0")=="0",.F.,.T.)	// 0-Nao utiliza	1-Utiliza Postos e Deptos	2-Utiliza so Deptos.
	Private nItensRetirados 	:= 0
	Private nPosRetirada 		:= 0
	Private lCorpManage		:= fIsCorpManage( FWGrpCompany() )	// Verifica se o cliente possui Gestão Corporativa no Grupo Logado

	Private cFilRCJ := ""

	Aadd(aOrd, OemToAnsi(STR0004)+"+"+OemToAnsi(STR0040))													//1 - "Matricula + Lançamentos"	
	Aadd(aOrd, OemToAnsi(STR0006)+"+"+OemToAnsi(STR0040))													//2 - "Nome + Lançamentos"
	Aadd(aOrd, OemToAnsi(STR0005)+"+"+OemToAnsi(STR0004)+"+"+OemToAnsi(STR0040))							//3 - "C.Custo + Matrícula + Lançamentos"
	Aadd(aOrd, OemToAnsi(STR0005)+"+"+OemToAnsi(STR0006)+"+"+OemToAnsi(STR0040))							//4 - "C.Custo + Nome + Lançamentos"
	Aadd(aOrd, OemToAnsi(STR0007)+"+"+OemToAnsi(STR0004)+"+"+OemToAnsi(STR0040))							//5 - "Depto + Matricula + Lançamentos"
	Aadd(aOrd, OemToAnsi(STR0007)+"+"+OemToAnsi(STR0006)+"+"+OemToAnsi(STR0040)) 							//6 - "Depto + Nome + Lançamentos"
	Aadd(aOrd, OemToAnsi(STR0005)+"+"+OemToAnsi(STR0007)+"+"+OemToAnsi(STR0004)+"+"+OemToAnsi(STR0040))		//7 - "C.Custo + Depto + Matricula + Lançamentos"
	Aadd(aOrd, OemToAnsi(STR0005)+"+"+OemToAnsi(STR0007)+"+"+OemToAnsi(STR0006)+"+"+OemToAnsi(STR0040))		//8 - "C.Custo + Depto + Nome + Lançamentos"

	nPosRetirada := Len(aOrd) + 1
	
	dbSelectArea("SRA")
	If SRA->(FIELDPOS("RA_KEYLOC")) > 0 //Se existe o campo
	
		Aadd(aOrd, OemToAnsi(STR0041)+"+"+OemToAnsi(STR0004)+"+"+OemToAnsi(STR0040))							//9 - "Loc.Pago + Matrícula + Lançamentos"
		Aadd(aOrd, OemToAnsi(STR0041)+"+"+OemToAnsi(STR0006)+"+"+OemToAnsi(STR0040))							//10 - "Loc.Pago + Nome + Lançamentos"
		nPosRetirada += 2		
	Else
		nItensRetirados += 2						
	Endif
		
	If SRA->(FIELDPOS("RA_CODRPAT")) > 0//Se existe o campo
		
		Aadd(aOrd, OemToAnsi(STR0044)+"+"+OemToAnsi(STR0004)+"+"+OemToAnsi(STR0040))							//11 - "Reg.Patronal + Matricula + Lançamentos"
		Aadd(aOrd, OemToAnsi(STR0044)+"+"+OemToAnsi(STR0006)+"+"+OemToAnsi(STR0040)) 							//12 - "Reg.Patronal + Nome + Lançamentos"
		
		If nItensRetirados == 0
			nPosRetirada += 2
		Endif

	Else
		nItensRetirados += 2		  	
	Endif
			
	Aadd(aOrd, OemToAnsi(STR0013)+"+"+OemToAnsi(STR0040))														//13 - "Verba + Lançamentos"

	If lCorpManage
		Private lUniNeg	:= !Empty(FWSM0Layout(cEmpAnt, 2)) // Verifica se possui tratamento para unidade de Negocios
		Private lEmpFil	:= !Empty(FWSM0Layout(cEmpAnt, 1)) // Verifica se possui tratamento para Empresa
		Private cLayoutGC 	:= FWSM0Layout(cEmpAnt)
		Private nStartEmp	:= At("E",cLayoutGC)
		Private nStartUnN	:= At("U",cLayoutGC)
		Private nEmpLength	:= Len(FWSM0Layout(cEmpAnt, 1))
		Private nUnNLength	:= Len(FWSM0Layout(cEmpAnt, 2))
	EndIf
	
	Pergunte(cPerg,.F.)
	
	cProcesso := mv_par09
	cRot := mv_par10

	oReport := ReportDef()
	oReport:PrintDialog()
	
	RestArea( aArea )
	    
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportDef  ³ Autor ³ Tania Bronzeri        ³ Data ³31/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio de Valores por Verba Vertical                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER102                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()

Local oReport 
Local oSecFun 
Local oSecLan      
Local oSecNom
Local oSecCtt
Local oSecSqb 
Local oSecSrv
Local oSecRgc 
Local oSecRco
Local oSectionh  
Local cDesc1	:= OemToAnsi(STR0001) + OemToAnsi(STR0035) + OemToAnsi(STR0002) + OemToAnsi(STR0003)
					//"Relatorio por Codigo" ### "Imprime ralação das verbas por período." ### "Ser  impresso de acordo com os parametros solicitados pelo" ### "usu rio."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao dos componentes de impressao                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE REPORT oReport NAME "GPER102" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| R102Imp(oReport)} DESCRIPTION cDesc1	

	oReport:SetTotalInLine(.F.)     // para totalizar em linhas
	oReport:nFontBody	:= 8
	oReport:SetDynamic()

    //SECTION 1
    //Cabecalho - Funcionario
	DEFINE SECTION oSecFun OF oReport TITLE OemToAnsi(STR0011) TABLES "SRA", "SQB", "RCO", "RGC", "CTT" ORDERS aOrd	//"Filial / Funcionário"

		DEFINE CELL NAME "RA_FILIAL"  OF oSecFun ALIAS "SRA"
		DEFINE CELL NAME "RA_CC"      OF oSecFun ALIAS "SRA" 
		DEFINE CELL NAME "RA_MAT"     OF oSecFun ALIAS "SRA" 
		DEFINE CELL NAME "RA_NOME"    OF oSecFun ALIAS "SRA"

		DEFINE CELL NAME "RA_DEPTO"   OF oSecFun ALIAS "SRA"
		DEFINE CELL NAME "QB_DESCRIC" OF oSecFun ALIAS "SQB"
		DEFINE CELL NAME "RA_KEYLOC"  OF oSecFun ALIAS "SRA" 
		DEFINE CELL NAME "RGC_DESLOC" OF oSecFun ALIAS "RGC" 
		DEFINE CELL NAME "RA_CODRPAT" OF oSecFun ALIAS "SRA"
		DEFINE CELL NAME "RCO_NREPAT" OF oSecFun ALIAS "RCO"
		DEFINE CELL NAME "RCO_NOME"   OF oSecFun ALIAS "RCO"
		DEFINE CELL NAME "RA_HRSMES"  OF oSecFun ALIAS "SRA" 
		DEFINE CELL NAME "RA_SALARIO" OF oSecFun ALIAS "SRA"
		
		DEFINE CELL NAME "QB_DEPTO" OF oSecFun ALIAS "SQB"
		oSecFun:Cell("QB_DEPTO"):Disable()
		
		DEFINE CELL NAME "CTT_CUSTO" OF oSecFun ALIAS "CTT"
		oSecFun:Cell("CTT_CUSTO"):Disable()
		
		DEFINE CELL NAME "CTT_DESC01" OF oSecFun ALIAS "CTT" TITLE OemToAnsi(STR0020) SIZE 60
		oSecFun:Cell("CTT_DESC01"):Disable()
	
		oSecFun:SetLineStyle()  
		oSecFun:SetTotalInLine(.F.)
		oSecFun:Cell("RA_NOME"   ):SetCellBreak(.T.)
		oSecFun:Cell("QB_DESCRIC"):SetCellBreak(.T.)
		oSecFun:Cell("RGC_DESLOC"):SetCellBreak(.T.)
		oSecFun:Disable()
		oSecFun:SetDynamicKey(OemToAnsi(STR0004))	//"Matrícula"

    //SECTION 2
    //Cabecalho - Funcionario - Lancamentos
	DEFINE SECTION oSecLan OF oReport TITLE OemToAnsi(STR0027) TABLES "SRC", "SRD", "SRV", "SRA"	//Lançamentos

		DEFINE CELL NAME "RA_FILIAL" 	OF oSecLan ALIAS "SRA"
		DEFINE CELL NAME "RA_MAT" 		OF oSecLan ALIAS "SRA"
		DEFINE CELL NAME "RA_NOME"		OF oSecLan ALIAS "SRA"
		DEFINE CELL NAME "RA_DEPTO"		OF oSecLan ALIAS "SRA"

		DEFINE CELL NAME "PXD"     OF oSecLan TITLE OemToAnsi(STR0021) SIZE 03	PICTURE "@!"	; 	//"Cod."
			BLOCK {||Upper((cAliasQry)->PXD)}		
		DEFINE CELL NAME "DESC"   OF oSecLan TITLE OemToAnsi(STR0020) SIZE 20	PICTURE "@!" 	;	//"Descrição"
			BLOCK {||Upper((cAliasQry)->DESCPD)}
		DEFINE CELL NAME "HORAS"  OF oSecLan TITLE OemToAnsi(STR0022) SIZE 08 PICTURE "@E 999,999.99"	;	//"Horas"
			BLOCK {||Iif(cHDV=="H",(cAliasQry)->HORAS,0)}
		DEFINE CELL NAME "DIAS"   OF oSecLan TITLE OemToAnsi(STR0023) SIZE 08 PICTURE "@E 999,999.99"	;	//"Dias"
			BLOCK {||Iif(cHDV=="D",(cAliasQry)->HORAS,0)}
		DEFINE CELL NAME "REFER"  OF oSecLan TITLE OemToAnsi(STR0019) SIZE 08 PICTURE "@E 999,999.99"	;	//"Referência"
			BLOCK {||Iif(cHDV<>"H" .And. cHDV<>"D",(cAliasQry)->HORAS,0)}
		DEFINE CELL NAME "PROVEN" OF oSecLan TITLE OemToAnsi(STR0024) SIZE 20 PICTURE "@E 99,999,999,999.99"	;	//"Provento"
			BLOCK {||Iif(cPDB=="1" .Or. cPDB=="3",(cAliasQry)->VALOR,0)}
		DEFINE CELL NAME "DESCON" OF oSecLan TITLE OemToAnsi(STR0025) SIZE 20 PICTURE "@E 99,999,999,999.99"	;	//"Desconto"
			BLOCK {||Iif(cPDB=="2" .Or. cPDB=="4",(cAliasQry)->VALOR,0)}

		DEFINE CELL NAME "LIQUI"  OF oSecLan TITLE OemToAnsi(STR0026) SIZE 20 PICTURE "@E 99,999,999,999.99"		//"Liquido"
		DEFINE CELL NAME "SINAL"  OF oSecLan TITLE "."   BLOCK {||cPDB} PICTURE "@!"
		DEFINE CELL NAME "STATUS" OF oSecLan TITLE "HDV" BLOCK {||cHDV}
		
		oSecLan:Cell("HORAS" ):SetHeaderAlign("RIGHT")
		oSecLan:Cell("DIAS"  ):SetHeaderAlign("RIGHT")
		oSecLan:Cell("PROVEN"):SetHeaderAlign("RIGHT")
		oSecLan:Cell("DESCON"):SetHeaderAlign("RIGHT")
		oSecLan:Cell("LIQUI" ):SetHeaderAlign("RIGHT")
		oSecLan:Cell("SINAL" ):Disable()  
		oSecLan:Cell("STATUS"):Disable()
		oSecLan:Cell("RA_FILIAL"):Disable()
		oSecLan:Cell("RA_MAT"   ):Disable()
		oSecLan:Cell("RA_NOME"  ):Disable()
		oSecLan:Cell("RA_DEPTO" ):Disable()
		oSecLan:SetTotalInLine(.F.)
		oSecLan:SetLineCondition({||	cPDB:=(cAliasQry)->TIPOCOD	,;
										cHDV:=(cAliasQry)->TIPOPD	}) 
		oSecLan:Disable()
		oSecLan:SetDynamicKey(OemToAnsi(STR0040))	//"Lançamentos"
		
/******************************/
oSecLan:Cell("HORAS"):lAutoSize := .F.
/******************************/

    //SECTION 3
    //Cabecalho - Relatorio
	DEFINE SECTION oSectionh OF oReport TITLE OemToAnsi(STR0031) TABLE "SRA" ORDERS aOrd	PAGE HEADER	//Processo / Periodo

		DEFINE CELL NAME "PROCESSO"   OF oSectionh TITLE OemToAnsi(STR0014) SIZE 5 BLOCK {||cProcesso} 		//Processo: 
		DEFINE CELL NAME "PERIODO" 	  OF oSectionh TITLE OemToAnsi(STR0015) SIZE 6 BLOCK {||cPeriodo}		//Periodo: 
		DEFINE CELL NAME "PAGAMENTO"  OF oSectionh TITLE OemToAnsi(STR0016) SIZE 2 BLOCK {||cPagamento} 	//Pagamento:
		DEFINE CELL NAME "ROTEIRO"    OF oSectionh TITLE OemToAnsi(STR0017) SIZE 3 BLOCK {||cRot}		//Roteiro:
    
		oSectionh:SetLineStyle()  
		oSectionh:Cell("ROTEIRO"):SetCellBreak(.T.)

    //SECTION 4
	DEFINE SECTION oSecNom OF oReport TITLE OemToAnsi(STR0011) TABLES "SRA", "SQB", "RCO", "CTT" ORDERS aOrd	//"Filial / Funcionário"

		DEFINE CELL NAME "RA_FILIAL"  OF oSecNom ALIAS "SRA"
		DEFINE CELL NAME "RA_CC"      OF oSecNom ALIAS "SRA" 
		DEFINE CELL NAME "RA_NOME"    OF oSecNom ALIAS "SRA"
		DEFINE CELL NAME "RA_MAT"     OF oSecNom ALIAS "SRA" 

		DEFINE CELL NAME "RA_DEPTO"   OF oSecNom ALIAS "SRA"
		DEFINE CELL NAME "QB_DESCRIC" OF oSecNom ALIAS "SQB"
		DEFINE CELL NAME "RA_KEYLOC"  OF oSecNom ALIAS "SRA" 
		DEFINE CELL NAME "RGC_DESLOC" OF oSecNom ALIAS "RGC"
		DEFINE CELL NAME "RA_CODRPAT" OF oSecNom ALIAS "SRA"
		DEFINE CELL NAME "RCO_NREPAT" OF oSecNom ALIAS "RCO"
		DEFINE CELL NAME "RCO_NOME"   OF oSecNom ALIAS "RCO"
		DEFINE CELL NAME "RA_HRSMES"  OF oSecNom ALIAS "SRA" 
		DEFINE CELL NAME "RA_SALARIO" OF oSecNom ALIAS "SRA"
		
		DEFINE CELL NAME "CTT_CUSTO" OF oSecNom ALIAS "CTT"
		oSecNom:Cell("CTT_CUSTO"):Disable()
		
		DEFINE CELL NAME "CTT_DESC01" OF oSecNom ALIAS "CTT" TITLE OemToAnsi(STR0020) SIZE 60
		oSecNom:Cell("CTT_DESC01"):Disable()

		oSecNom:SetLineStyle()  
		oSecNom:SetTotalInLine(.F.)
		oSecNom:Cell("RA_MAT"    ):SetCellBreak(.T.)
		oSecNom:Cell("QB_DESCRIC"):SetCellBreak(.T.)
		oSecNom:Cell("RGC_DESLOC"):SetCellBreak(.T.)
		oSecNom:Disable()
		oSecNom:SetDynamicKey(OemToAnsi(STR0006))	//"Nome"

    //SECTION 5
	DEFINE SECTION oSecCtt OF oReport TABLES "CTT", "SRA" ORDERS aOrd TITLE OemToAnsi(STR0038) TOTAL IN COLUMN // "Centro de Custo"
		
		DEFINE CELL NAME "CTT_FILIAL" 	OF oSecCtt ALIAS "CTT"
		DEFINE CELL NAME "RA_FILIAL" 	OF oSecCtt ALIAS "SRA"
		DEFINE CELL NAME "CTT_CUSTO"   	OF oSecCtt ALIAS "CTT"
		
		DEFINE CELL NAME "CTT_DESC01"  OF oSecCtt ALIAS "CTT" TITLE OemToAnsi(STR0020) SIZE 60

		oSecCtt:Disable()
		oSecCtt:SetDynamicKey(OemToAnsi(STR0005))	//"C.Custo"

    //SECTION 6
	DEFINE SECTION oSecSqb OF oReport TABLES "SQB", "SRA", "CTT" ORDERS aOrd TITLE OemToAnsi(STR0039) TOTAL IN COLUMN // "Departamento"
		
		DEFINE CELL NAME "RA_FILIAL"	OF oSecSqb ALIAS "SRA"
		DEFINE CELL NAME "QB_FILIAL" 	OF oSecSqb ALIAS "SQB" 
		DEFINE CELL NAME "QB_CC"    	OF oSecSqb ALIAS "SQB" 
		DEFINE CELL NAME "QB_DEPTO"   	OF oSecSqb ALIAS "SQB"
		DEFINE CELL NAME "QB_DESCRIC"	OF oSecSqb ALIAS "SQB"

		DEFINE CELL NAME "CTT_DESC01"	OF oSecSqb ALIAS "CTT"  TITLE OemToAnsi(STR0020) SIZE 60
		oSecSqb:Cell("CTT_DESC01"):Disable()
		
		DEFINE CELL NAME "CTT_CUSTO"	OF oSecSqb ALIAS "CTT"
		oSecSqb:Cell("CTT_CUSTO"):Disable()
		
		oSecSqb:Cell("QB_CC"    ):Disable()
		oSecSqb:Disable()
		oSecSqb:SetDynamicKey(OemToAnsi(STR0007))	//"Depto."

    //SECTION 7
	DEFINE SECTION oSecSrv OF oReport TABLES "SRV", "SRC", "SRD" TITLE OemToAnsi(STR0013)	// "Verba"
	oSecSrv:SetLineStyle()
			
		DEFINE CELL NAME "RV_COD" 		OF oSecSRV ALIAS "SRV" TITLE OemToAnsi(STR0013) SIZE 8 BLOCK {||Upper((cAliasQry)->PXD)}  	// "Verba"
		DEFINE CELL NAME "RV_DESC"		OF oSecSRV ALIAS "SRV" BLOCK {||Upper((cAliasQry)->DESCPD)}

		oSecSrv:Disable()
		oSecSrv:SetDynamicKey(OemToAnsi(STR0013))	//"Verba"

    //SECTION 8
	DEFINE SECTION oSecRgc OF oReport TABLES "RGC" ORDERS aOrd TITLE OemToAnsi(STR0042) TOTAL IN COLUMN // "Localidade Pagamento"
		
		DEFINE CELL NAME "RGC_FILIAL" 	OF oSecRgc ALIAS "RGC"
		DEFINE CELL NAME "RGC_KEYLOC"  	OF oSecRgc ALIAS "RGC"
		DEFINE CELL NAME "RGC_DESLOC"	OF oSecRgc ALIAS "RGC"

		oSecRgc:SetLineStyle()                                                         	
		oSecRgc:Cell("RGC_FILIAL"):Disable()
		oSecRgc:Disable()
		oSecRgc:SetDynamicKey(OemToAnsi(STR0041))	//"Loc.Pago"

    //SECTION 9
	DEFINE SECTION oSecRco OF oReport TABLES "RCO" ORDERS aOrd TITLE OemToAnsi(STR0045) TOTAL IN COLUMN // "Registro Patronal"
		
		DEFINE CELL NAME "RCO_FILIAL" 	OF oSecRco ALIAS "RCO"
		DEFINE CELL NAME "RCO_CODIGO"  	OF oSecRco ALIAS "RCO"
		DEFINE CELL NAME "RCO_NREPAT"	OF oSecRco ALIAS "RCO"
		DEFINE CELL NAME "RCO_NOME" 	OF oSecRco ALIAS "RCO"

		oSecRco:SetLineStyle()                                                         	
		oSecRco:Cell("RCO_FILIAL"):Disable()
		oSecRco:Disable()
		oSecRco:SetDynamicKey(OemToAnsi(STR0044))	//"Reg.Patronal"

Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ R102Imp    ³ Autor ³ Tania Bronzeri        ³ Data ³31/07/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio de Valores por Verba                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER102                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function R102Imp(oReport)
Local oSectionh		:= oReport:Section(3)
Local oSectLanc	
Local oSectFunc
Local oSectCCus 
Local oSectDept 
Local oSectLocp
Local oSectVerb 
Local oSectRPat
Local cFiltro 		:= ""   
Local cFiltroC 		:= ""   
Local cFiltroD 		:= ""
Local cFiltroPDB	:= ""
Local cSitQuery		:= ""
Local cCatQuery		:= ""
Local cVerQuery		:= ""
Local cOrdem		:= ""
Local cTitFil		:= ""
Local cTitUnN		:= ""
Local cTitEFil		:= ""
Local cTitFun		:= ""
Local cTitLp		:= "" 
Local cTitRpt		:= ""
Local cTitCC		:= ""
Local cTitDp		:= ""
Local cCpoQuebra	:= "" 
Local cCpoDelim		:= "" 
Local cCpoAdic		:= ""
Local cCpoAddSRC    := ""
Local cCpoAddSRD    := ""
Local cJoin			:= ""
Local cJoinC		:= ""
Local cJoinD		:= ""
Local cJoinSQB		:= ""
Local cJoinRGC		:= ""
Local cJoinSRC		:= ""
Local cJoinSRD		:= ""
Local cJoinDep		:= ""
Local cTitulo		:= ""
Local cJoinVerbas	:= ""
Local cOrgJoin		:= ""
Local cNotDel		:= ""
Local cFilPdSRC		:= ""
Local cFilPdSRD		:= ""
Local cChaveArq		:= ""
Local cVisaoDepto	:= ""
Local cModAcesso	:= ""
Local cEspaco		:= "%%"
Local cValidFil		:= ""
Local nX			:= 0
Local aValidFil		:= StrToArray(fValidFil(),"/")
Local oBreakFil
Local oBreakUnN
Local oBreakEFil
Local nReg			:= 0
Local lShar			:= .T.
Local aChaveArq		:= array(2)
Local aPosics		:= Array(3)
Local nCont
Local nIni			:= 1
Local cUserFiltro	:= ""
Local cItemClvl	    := GetMvRH( "MV_ITMCLVL", .F., "2" )  //Conteudo do parametro
Local lItemClvl	    := cItemClvl $ "1*3"  // Define se trabalha com item contábil e classe de valor
Local cAdicSRC		:= ""
Local cAdicSRD		:= ""

Private cCodVisao	:= ""
Private cCodDepto	:= ""
Private aPerAberto	:= {}
Private aPerFechado	:= {}
Private nHrsMes		:= 0
Private nSalario	:= 0
Private lImpBase    := .F.

nOrdem := oReport:GetOrder()

If (nItensRetirados > 0) .And. (nOrdem >= nPosRetirada) 

	nOrdem += nItensRetirados 
	//Isso aqui foi necessario porque inicialmente cada item de seleção do combo das ordens
	//foi deixado com numeros fixos nos ifs e nesta modificacao tem opcoes de ordens
	//que foram retiradas para o usuario com ids menores que o 13, dependendo da existencia de campos,
	//deslocando o ultimo item para cima.
Endif 
	
cSituacao   := mv_par06					
cCategoria 	:= mv_par07					
nSinAna   	:= mv_par08						// 1=Analitico ou 2=Sintetico
cProcesso	:= mv_par09 
cRot		:= mv_par10        		
cPeriodo	:= mv_par11        
cPagamento	:= mv_par12      			
cCodigos  	:= AllTrim(mv_par13)			// Codigos ( Verbas )
cCodigos  	+= AllTrim(mv_par14)		
lAllVerbas 	:= If(mv_par15=1,.T.,.F.)		// Imprimir todas as verbas
lSalario  	:= If(mv_par16=1,.T.,.F.)		// Salario Cadastro
lImpEmpr  	:= If(mv_par17=1,.T.,.F.)		// Listar total empresa
cCodDepto	:= mv_par19
lImpBase	:= If(mv_par20 = 1,.T.,.F.)		// Imprimir bases

If !lAllVerbas .And. Len(AllTrim(cCodigos)) == 0
	Aviso(OemToAnsi(STR0049), OemToAnsi(STR0052), {"OK"})	//"Atenção!" ### "Não foi selecionada nenhuma verba para impressão. Favor selecionar pelo menos uma verba."
	Return
EndIf

If lUsaArqui 	//Se usa Arquitetura Organizadional (SIGAORG)
	cCodVisao	:= mv_par18
//-	cCodDepto	:= mv_par19
Else
	cCodVisao	:= ""
//-	cCodDepto	:= ""
EndIf  

If !Empty(cCodVisao + cCodDepto)
	aChaveArq	:= fQueryVisao()
	cChaveArq	:= aChaveArq[2]
	lShar		:= Iif(Empty(aChaveArq[1]),.T.,.F.)
	cOrgJoin	:= " INNER JOIN (SELECT RD4.RD4_FILIDE, RD4.RD4_CODIDE, RD4.RD4_CHAVE "
	cOrgJoin	+= " FROM " + RetSqlName("RD4") + " RD4 "
	cOrgJoin	+= " WHERE RD4_CHAVE LIKE '" + AllTrim(cChaveArq) + "%' AND RD4.D_E_L_E_T_ = ' ' ) TVRD4 "
	cOrgJoin	+= " ON SRA.RA_DEPTO = TVRD4.RD4_CODIDE "
	If !lShar
		cOrgJoin+= " AND SRA.RA_FILIAL = TVRD4.RD4_FILIDE "
	EndIf
	
	cVisaoDepto	:= OemToAnsi(STR0048) + AllTrim(cCodVisao) + " / " + OemToAnsi(STR0007) + AllTrim(cCodDepto) //"Visão: " ## "Depto.: "
					
	DEFINE CELL NAME "ARQORG"  OF oSectionh TITLE OemToAnsi(STR0047) SIZE 125  	;	//"Arquitetura Organizacional - " 
	BLOCK {|| cVisaoDepto }	

EndIf

If AllTrim(oReport:Title()) != cTitulo
	cTitulo	:= oReport:Title()
Endif

If nSinAna == 1
	cTitulo += " - " + OemToAnsi(STR0036) 	//Analitico
Else
	cTitulo	+= " - " + OemToAnsi(STR0037)	//Sintético
Endif

If nOrdem == 3 .Or. nOrdem == 4 .Or. nOrdem == 7 .Or. nOrdem == 8		//Centro de Custo
	cTitulo 	+= " - " + OemToAnsi(STR0038)
Endif

If nOrdem == 5 .Or. nOrdem == 6
	cTitulo += " - " + OemToAnsi(STR0039)	//"Por Departamento"
EndIf

If nOrdem == 7 .Or. nOrdem == 8
	cTitulo	+= " + " + OemToAnsi(STR0007)	//"Depto."  
EndIf

If nOrdem == 9 .Or. nOrdem == 10
	cTitulo += " - " + OemToAnsi(STR0042)	//"Localidade Pagamento"
Endif

If nOrdem == 11 .Or. nOrdem == 12
	cTitulo += " - " + OemToAnsi(STR0045)	//"Registro Patronal"	
Endif

If nSinAna == 1
	If nOrdem == 1 .Or. nOrdem == 3 .Or. nOrdem == 5 .Or. nOrdem == 7 .Or. nOrdem == 9 .Or. nOrdem == 11
		cTitulo += " + " + OemToAnsi(STR0004)	//Matrícula
		
	ElseIf nOrdem == 2 .Or. nOrdem == 4 .Or. nOrdem == 6 .Or. nOrdem == 8 .Or. nOrdem == 10 .Or. nOrdem == 12
		cTitulo += " + " + OemToAnsi(STR0006)	//Nome
	EndIf
Endif

If nOrdem == 13
	cTitulo 	+= " - " + OemToAnsi(STR0008)	//Por Verba
Endif

//Secoes comuns a todas as ordens selecionadas
oSectLanc 	:= oReport:Section(2)

If lImpBase
	oSectLanc:Cell("PROVEN"):SetTitle(STR0057)

	oSectLanc:Cell("DESCON"):SetTitle(STR0058)
EndIf

If nOrdem == 1 //Matrícula
	oSectFunc	:= oReport:Section(1)	
EndIf
	
If nOrdem == 2	//Nome
	oSectFunc	:= oReport:Section(4)	
Endif
	
If nOrdem == 1 .Or. nOrdem == 2
	If nSinAna == 1
		oSectFunc:Cell("RA_FILIAL" ):Enable()
		oSectFunc:Cell("RA_CC"     ):Enable() 
		oSectFunc:Cell("RA_DEPTO"  ):Enable()
		oSectFunc:Cell("QB_DESCRIC"):Enable()		
		oSectFunc:SetCharSeparator(": ")
	Endif	
Endif
	
If nOrdem == 3
	oSectFunc	:= oReport:Section(1)
Endif

If nOrdem == 4
	oSectFunc	:= oReport:Section(4)
Endif
	
If nOrdem == 3 .Or. nOrdem == 4 	//C.Custo + (Matrícula Ou Nome)
 		
	oSectFunc:Cell("RA_FILIAL"):Disable()
	oSectFunc:Cell("RA_CC"):Disable()
	oSectFunc:SetLineStyle()

	oSectCCus:= oReport:Section(5)

	If nSinAna == 1
				
		oSectCCus:Cell("RA_FILIAL"):Disable()		
		oSectCCus:SetLineStyle()
		oSectCCus:SetCharSeparator(": ")
	Else
	
		oSectFunc:Cell("RA_FILIAL"):Enable()
		oSectFunc:Cell("RA_CC"):Enable()
		oSectFunc:Cell("RA_CC"):bCellBlock := { || (cAliasQry)->CTT_CUSTO }
		oSectFunc:Cell("CTT_DESC01"):Enable()
	
	Endif
		
ElseIf nOrdem == 5 .Or. nOrdem == 6	//Depto + (Matrícula Ou Nome)

	oSectDept	:= oReport:Section(6)
	
	If nOrdem == 5 		
		oSectFunc	:= oReport:Section(1)
	Else
		oSectFunc	:= oReport:Section(4)
	Endif
	
	oSectFunc:Cell("RA_CC"):Disable()
	
	oSectDept:SetLineStyle()
	oSectFunc:SetLineStyle()
	
	If nSinAna == 2
	
		oSectFunc:Cell("RA_FILIAL" ):Enable()
		oSectFunc:Cell("RA_DEPTO"  ):Enable()
		oSectFunc:Cell("QB_DESCRIC"):Enable()
		//TRPosition():New(oSectFunc,"SQB",1,{||RhFilial("SQB",(cAliasQry)->RA_FILIAL)+(cAliasQry)->RA_DEPTO})
	
	Else
		oSectFunc:Cell("RA_FILIAL" ):Disable()	
		oSectFunc:Cell("RA_DEPTO"):Disable()
		oSectFunc:Cell("QB_DESCRIC"):Disable()
	
	Endif
		
ElseIf nOrdem == 7 .Or. nOrdem == 8 //C.Custo + Depto + (Matrícula Ou Nome)

	oSectCCus := oReport:Section(5)
	oSectCCus:SetLineStyle()
	oSectCCus:SetCharSeparator(": ")
	
	oSectDept := oReport:Section(6)
	oSectDept:SetLineStyle()
	
	If nOrdem == 7		
		oSectFunc	:= oReport:Section(1)
	Else
		oSectFunc	:= oReport:Section(4)				
	Endif
	
	If nSinAna == 1	//Analítico
		
		oSectCCus:Cell("CTT_FILIAL"):Disable()
		
		oSectDept:Cell("QB_FILIAL" ):Disable()
		oSectDept:Cell("RA_FILIAL" ):Disable()		

		oSectFunc:Cell("RA_FILIAL" ):Disable()
		oSectFunc:Cell("RA_CC"):Disable()		
		oSectFunc:Cell("RA_DEPTO"  ):Disable()
		oSectFunc:Cell("QB_DESCRIC" ):Disable()		
		oSectFunc:SetLineStyle()

	Else	
		oSectDept:Cell("QB_DEPTO"   ):Disable()			
		oSectDept:Cell("QB_DESCRIC" ):Disable()					
		oSectDept:Cell("QB_CC"      ):Enable()
		oSectDept:Cell("QB_CC"      ):bCellBlock := { || (cAliasQry)->CTT_CUSTO }

		oSectFunc:Cell("RA_FILIAL"):Disable()
		oSectFunc:Cell("RA_CC"):Disable()		
		oSectFunc:Cell("RA_DEPTO"):Enable()
		oSectFunc:Cell("RA_DEPTO"):bCellBlock := { || (cAliasQry)->QB_DEPTO }		
		oSectFunc:Cell("QB_DESCRIC"):Enable()							
	EndIf
		
ElseIf nOrdem == 9		//Loc.Pago + Matrícula	
	oSectFunc 	:= oReport:Section(1)
	
ElseIf nOrdem == 10		//Loc.Pago + Nome
	oSectFunc 	:= oReport:Section(4)
	
Endif
	
If nOrdem == 9 .Or. nOrdem == 10
	oSectLocp	:= oReport:Section(8)

	If nSinAna == 2
		oSectFunc:Cell("RA_FILIAL" ):Enable()
		oSectFunc:Cell("RA_KEYLOC" ):Enable()
		oSectFunc:Cell("RGC_DESLOC"):Enable()
		TRPosition():New(oSectFunc,"RGC",1,{||RhFilial("RGC",(cAliasQry)->RA_FILIAL)+(cAliasQry)->RA_KEYLOC})
	Endif
		
ElseIf nOrdem == 11 .Or. nOrdem == 12	//Reg.Patronal + (Matrícula Ou Nome)
	oSectRPat	:= oReport:Section(9)
	
	If nOrdem == 11	
		oSectFunc	:= oReport:Section(1)
	Else
		oSectFunc	:= oReport:Section(4)		
	Endif
	
	oSectFunc:Cell("RA_FILIAL" ):Enable()
	oSectFunc:Cell("RA_CODRPAT"):Disable()
	oSectFunc:Cell("RCO_NREPAT"):Disable()
	oSectFunc:Cell("RCO_NOME"  ):Disable()
	oSectFunc:Cell("RA_CC"):Disable()
	oSectRPat:SetLineStyle()
	oSectFunc:SetLineStyle()
	
	If nSinAna == 2
		oSectFunc:Cell("RA_FILIAL" ):Enable()
		oSectFunc:Cell("RA_CODRPAT"):Enable()
		oSectFunc:Cell("RCO_NREPAT"):Enable()
		oSectFunc:Cell("RCO_NOME"  ):Enable()
		TRPosition():New(oSectFunc,"RCO",1,{||RhFilial("RCO",(cAliasQry)->RA_FILIAL)+(cAliasQry)->RA_CODRPAT})
	Endif	
		
ElseIf nOrdem == 13	//Verba + Nome
	/*
		Verbas -> Section pai
		Lancamentos -> Section filha
	*/	
	oSectVerb := oReport:Section(7)
	oSectVerb:SetLineStyle()
	
	oSectLanc:AutoSize()
	oSectLanc:Cell("LIQUI"     ):Disable()
EndIf

If nOrdem <> 13

	If nSinAna == 1
	
		oSectFunc:Cell("RA_MAT"    ):Enable()
		oSectFunc:Cell("RA_NOME"   ):Enable()
		
		If lSalario
			oSectFunc:Cell("RA_HRSMES" ):Enable()
			oSectFunc:Cell("RA_SALARIO"):Enable()
		Else
			oSectFunc:Cell("RA_HRSMES" ):Disable()
			oSectFunc:Cell("RA_SALARIO"):Disable()
		EndIf
		
	Else
		oSectFunc:SetCharSeparator("")
		oSectFunc:Cell("RA_MAT"     ):Disable()
		
		If nOrdem != 3 .And. nOrdem != 4 .And. nOrdem != 7 .And. nOrdem != 8
			oSectFunc:Cell("RA_CC"      ):Disable()					
		Endif
		
		If nOrdem != 5 .And. nOrdem != 6 .And. nOrdem != 7 .And. nOrdem != 8
			oSectFunc:Cell("RA_DEPTO"   ):Disable()		
			oSectFunc:Cell("QB_DESCRIC" ):Disable()		
		Endif
		
		oSectFunc:Cell("RA_NOME"    ):Disable()
		oSectFunc:Cell("RA_HRSMES"  ):Disable()
		oSectFunc:Cell("RA_SALARIO" ):Disable()
	Endif
	
	If nOrdem != 9 .And. nOrdem != 10
		oSectFunc:Cell("RA_KEYLOC"  ):Disable()
		oSectFunc:Cell("RGC_DESLOC" ):Disable()
	Endif	

	If nOrdem != 11 .And. nOrdem != 12
		oSectFunc:Cell("RA_CODRPAT" ):Disable()
		oSectFunc:Cell("RCO_NREPAT" ):Disable()
		oSectFunc:Cell("RCO_NOME" ):Disable()	
	Endif
Else
	oSectLanc:Cell("RA_FILIAL" ):Enable()

	If nSinAna == 1	//Analitico
		oSectLanc:Cell("PXD"       ):Disable()
		oSectLanc:Cell("DESC"      ):Disable()
		oSectLanc:Cell("RA_MAT"    ):Enable()
		oSectLanc:Cell("RA_NOME"   ):Enable()
		oSectVerb:SetCharSeparator(": ")
	Endif		
Endif

If nSinAna == 1 .And. nOrdem <> 13 
 	DEFINE BREAK oBreakFun OF oSectFunc WHEN {|| (cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT } TITLE STR0034 //"Total do Funcionário "

	DEFINE FUNCTION NAME "UTOTHORAS"  FROM oSectLanc:Cell("HORAS" ) FUNCTION SUM     BREAK oBreakFun NO END SECTION NO END REPORT TITLE OemToAnsi(STR0022) PICTURE "@E 999,999.99"         	//"Horas:"
	DEFINE FUNCTION NAME "UTOTDIAS"   FROM oSectLanc:Cell("DIAS"  ) FUNCTION SUM     BREAK oBreakFun NO END SECTION NO END REPORT TITLE OemToAnsi(STR0023) PICTURE "@E 999,999.99"         	//"Dias:"
	
	If lImpBase
		DEFINE FUNCTION NAME "UPROVVALOR" FROM oSectLanc:Cell("PROVEN") FUNCTION SUM     BREAK oBreakFun NO END SECTION NO END REPORT TITLE OemToAnsi(STR0057) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "1" } 	//"Provento / Base Provento:"
		DEFINE FUNCTION NAME "UDESCVALOR" FROM oSectLanc:Cell("DESCON") FUNCTION SUM     BREAK oBreakFun NO END SECTION NO END REPORT TITLE OemToAnsi(STR0058) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "2" } 	//"Desconto / Base Desconto:
	Else
		DEFINE FUNCTION NAME "UPROVVALOR" FROM oSectLanc:Cell("PROVEN") FUNCTION SUM     BREAK oBreakFun NO END SECTION NO END REPORT TITLE OemToAnsi(STR0024) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "1" } 	//"Provento:"
		DEFINE FUNCTION NAME "UDESCVALOR" FROM oSectLanc:Cell("DESCON") FUNCTION SUM     BREAK oBreakFun NO END SECTION NO END REPORT TITLE OemToAnsi(STR0025) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "2" } 	//"Desconto:
	EndIf

	DEFINE FUNCTION NAME "ULIQVALOR"  FROM oSectLanc:Cell("LIQUI" ) FUNCTION ONPRINT BREAK oBreakFun NO END SECTION NO END REPORT TITLE OemToAnsi(STR0026) PICTURE "@E 99,999,999,999.99" FORMULA {|| (oSectLanc:GetFunction("UPROVVALOR"):GetLastValue() - oSectLanc:GetFunction("UDESCVALOR"):GetLastValue()) } 	//"Liquido:"

	oBreakFun:OnBreak({|x,y|cTitFun:=OemToAnsi(STR0034)+" "+oSectFunc:Cell("RA_NOME"):GetText()})	//"Total do Funcionário"
	oBreakFun:SetTotalText({||cTitFun})
	oBreakFun:SetTotalInLine(.F.)                                                                
Endif

If nOrdem == 3 .Or. nOrdem == 4 .Or. nOrdem == 7 .Or. nOrdem == 8		//Centro de Custo

	If nSinAna == 1	//Analitico
		DEFINE BREAK oBreakCc  OF oSectCCus WHEN { || (cAliasQry)->RA_FILIAL+(cAliasQry)->CTT_CUSTO } TITLE OemToAnsi(STR0029) //"Total do Centro de Custo "
	Else			//Sintetico
		If nOrdem == 3 .Or. nOrdem == 4 
			DEFINE BREAK oBreakCc  OF oSectFunc WHEN { || (cAliasQry)->RA_FILIAL+(cAliasQry)->CTT_CUSTO } TITLE OemToAnsi(STR0029) //"Total do Centro de Custo "
		Else
			DEFINE BREAK oBreakCc  OF oSectDept WHEN { || (cAliasQry)->RA_FILIAL+(cAliasQry)->CTT_CUSTO } TITLE OemToAnsi(STR0029) //"Total do Centro de Custo "			
		Endif
	EndIf

	DEFINE FUNCTION NAME "CTOTHORAS"  FROM oSectLanc:Cell("HORAS" ) FUNCTION SUM     BREAK oBreakCc NO END SECTION NO END REPORT TITLE OemToAnsi(STR0022) PICTURE "@E 999,999.99"         	//"Horas:"
	DEFINE FUNCTION NAME "CTOTDIAS"   FROM oSectLanc:Cell("DIAS"  ) FUNCTION SUM     BREAK oBreakCc NO END SECTION NO END REPORT TITLE OemToAnsi(STR0023) PICTURE "@E 999,999.99"         	//"Dias:"

	If lImpBase
		DEFINE FUNCTION NAME "CPROVVALOR" FROM oSectLanc:Cell("PROVEN") FUNCTION SUM     BREAK oBreakCc NO END SECTION NO END REPORT TITLE OemToAnsi(STR0057) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "1" } 	//"Provento / Base Provento:"
		DEFINE FUNCTION NAME "CDESCVALOR" FROM oSectLanc:Cell("DESCON") FUNCTION SUM     BREAK oBreakCc NO END SECTION NO END REPORT TITLE OemToAnsi(STR0058) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "2" } 	//"Desconto / Base Desconto:
	Else
		DEFINE FUNCTION NAME "CPROVVALOR" FROM oSectLanc:Cell("PROVEN") FUNCTION SUM     BREAK oBreakCc NO END SECTION NO END REPORT TITLE OemToAnsi(STR0024) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "1" } 	//"Provento:"
		DEFINE FUNCTION NAME "CDESCVALOR" FROM oSectLanc:Cell("DESCON") FUNCTION SUM     BREAK oBreakCc NO END SECTION NO END REPORT TITLE OemToAnsi(STR0025) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "2" } 	//"Desconto:
	EndIf

	DEFINE FUNCTION NAME "CLIQVALOR"  FROM oSectLanc:Cell("LIQUI" ) FUNCTION ONPRINT BREAK oBreakCc NO END SECTION NO END REPORT TITLE OemToAnsi(STR0026) PICTURE "@E 99,999,999,999.99" FORMULA {|| (oSectLanc:GetFunction("CPROVVALOR"):GetLastValue() - oSectLanc:GetFunction("CDESCVALOR"):GetLastValue()) } 	//"Liquido:"

	If nSinAna == 1	//Analitico
		oBreakCc:OnBreak({|x,y|cTitCC:=OemToAnsi(STR0029)+" "+oSectCCus:Cell("CTT_CUSTO"):GetText()+" - "+oSectCCus:Cell("CTT_DESC01"):GetText()})
	Else			//Sintetico
		If nOrdem == 3 .Or. nOrdem == 4 
			oBreakCc:OnBreak({|x,y|cTitCC:=OemToAnsi(STR0029)+" "+oSectFunc:Cell("CTT_CUSTO"):GetText()+" - "+oSectFunc:Cell("CTT_DESC01"):GetText()})
		Else
			oBreakCc:OnBreak({|x,y|cTitCC:=OemToAnsi(STR0029)+" "+oSectDept:Cell("CTT_CUSTO"):GetText()+" - "+oSectDept:Cell("CTT_DESC01"):GetText()})			
		Endif
	EndIf

	oBreakCc:SetTotalText({||cTitCC})
	oBreakCc:SetTotalInLine(.F.)
        	
EndIf

If nOrdem == 5 .Or. nOrdem == 6 .Or. nOrdem == 7 .Or. nOrdem == 8		//Departamento

	oSectDept:SetCharSeparator(": ")
	
	If nSinAna == 1	//Analitico
		DEFINE BREAK oBreakDp  OF oSectDept WHEN {||(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_CC+(cAliasQry)->RA_DEPTO} TITLE OemToAnsi(STR0010) //"Total do Departamento"
	Else			//Sintetico
		If nOrdem == 7 .Or. nOrdem == 8
			DEFINE BREAK oBreakDp  OF oSectFunc WHEN {||(cAliasQry)->RA_FILIAL+(cAliasQry)->CTT_CUSTO+(cAliasQry)->QB_DEPTO} TITLE OemToAnsi(STR0010) //"Total do Departamento"
		Else
			DEFINE BREAK oBreakDp  OF oSectFunc WHEN {||(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_DEPTO} TITLE OemToAnsi(STR0010) //"Total do Departamento"
		EndIf
	EndIf
	
	DEFINE FUNCTION NAME "DTOTHORAS"  FROM oSectLanc:Cell("HORAS" ) FUNCTION SUM     BREAK oBreakDp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0022) PICTURE "@E 999,999.99"         	//"Horas:"
	DEFINE FUNCTION NAME "DTOTDIAS"   FROM oSectLanc:Cell("DIAS"  ) FUNCTION SUM     BREAK oBreakDp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0023) PICTURE "@E 999,999.99"         	//"Dias:"
	
	If lImpBase
		DEFINE FUNCTION NAME "DPROVVALOR" FROM oSectLanc:Cell("PROVEN") FUNCTION SUM     BREAK oBreakDp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0057) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "1" } 	//"Provento / Base Provento:"
		DEFINE FUNCTION NAME "DDESCVALOR" FROM oSectLanc:Cell("DESCON") FUNCTION SUM     BREAK oBreakDp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0058) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "2" } 	//"Desconto / Base Desconto:
	Else
		DEFINE FUNCTION NAME "DPROVVALOR" FROM oSectLanc:Cell("PROVEN") FUNCTION SUM     BREAK oBreakDp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0024) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "1" } 	//"Provento:"
		DEFINE FUNCTION NAME "DDESCVALOR" FROM oSectLanc:Cell("DESCON") FUNCTION SUM     BREAK oBreakDp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0025) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "2" } 	//"Desconto:
	EndIf

	DEFINE FUNCTION NAME "DLIQVALOR"  FROM oSectLanc:Cell("LIQUI" ) FUNCTION ONPRINT BREAK oBreakDp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0026) PICTURE "@E 99,999,999,999.99" FORMULA {|| (oSectLanc:GetFunction("DPROVVALOR"):GetLastValue() - oSectLanc:GetFunction("DDESCVALOR"):GetLastValue()) } 	//"Liquido:"
	
	If nSinAna == 1	//Analitico
		oBreakDp:OnBreak({|x,y|cTitDp:=OemToAnsi(STR0010)+" "+oSectDept:Cell("QB_DESCRIC"):GetText()})
	Else			//Sintetico
		oBreakDp:OnBreak({|x,y|cTitDp:=OemToAnsi(STR0010)+" "+oSectFunc:Cell("QB_DEPTO"):GetText() + "-" + oSectFunc:Cell("QB_DESCRIC"):GetText()})
	EndIf
	
	oBreakDp:SetTotalText({||cTitDp})
	oBreakDp:SetTotalInLine(.F.)                                                                

EndIf

If nOrdem == 9 .Or. nOrdem == 10
	oSectLocp:SetCharSeparator(": ")
	
	If nSinAna == 1	//Analitico
		DEFINE BREAK oBreakLp  OF oSectLocp WHEN  oSectLocp:Cell("RGC_KEYLOC") TITLE OemToAnsi(STR0043) //"Total Local. Pagamento"
	Else			//Sintetico
		DEFINE BREAK oBreakLp  OF oSectLanc WHEN  oSectFunc:Cell("RA_KEYLOC") TITLE OemToAnsi(STR0043) //"Total Local. Pagamento"
	EndIf
	
	DEFINE FUNCTION NAME "LTOTHORAS"  FROM oSectLanc:Cell("HORAS" ) FUNCTION SUM     BREAK oBreakLp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0022) PICTURE "@E 999,999.99"         	//"Horas:"
	DEFINE FUNCTION NAME "LTOTDIAS"   FROM oSectLanc:Cell("DIAS"  ) FUNCTION SUM     BREAK oBreakLp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0023) PICTURE "@E 999,999.99"         	//"Dias:"

	If lImpBase
		DEFINE FUNCTION NAME "LPROVVALOR" FROM oSectLanc:Cell("PROVEN") FUNCTION SUM     BREAK oBreakLp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0057) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "1" } 	//"Provento / Base Provento:"
		DEFINE FUNCTION NAME "LDESCVALOR" FROM oSectLanc:Cell("DESCON") FUNCTION SUM     BREAK oBreakLp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0058) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "2" } 	//"Desconto / Base Desconto:
	Else
		DEFINE FUNCTION NAME "LPROVVALOR" FROM oSectLanc:Cell("PROVEN") FUNCTION SUM     BREAK oBreakLp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0024) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "1" } 	//"Provento:"
		DEFINE FUNCTION NAME "LDESCVALOR" FROM oSectLanc:Cell("DESCON") FUNCTION SUM     BREAK oBreakLp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0025) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "2" } 	//"Desconto:
	EndIf

	DEFINE FUNCTION NAME "LLIQVALOR"  FROM oSectLanc:Cell("LIQUI" ) FUNCTION ONPRINT BREAK oBreakLp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0026) PICTURE "@E 99,999,999,999.99" FORMULA {|| (oSectLanc:GetFunction("LPROVVALOR"):GetLastValue() - oSectLanc:GetFunction("LDESCVALOR"):GetLastValue()) } 	//"Liquido:"

	oBreakLp:OnBreak({|x,y|cTitLp:=OemToAnsi(STR0043)+" "+x})	
	oBreakLp:SetTotalText({||cTitLp})	//"Total Local. Pagamento"
	oBreakLp:SetTotalInLine(.F.)                                                                
    	
	If nSinAna == 1	//Analitico
		DEFINE COLLECTION OF oSectLanc FUNCTION COUNT FORMULA {|| oSectLanc:Cell("PXD"):GetText() + " " + oSectLanc:Cell("DESC"):GetText()} CONTENT {|| oSectLanc:Cell("PXD"):GetText()} BREAK oBreakLp TITLE OemToAnsi(STR0053) PICTURE "9999"	NO END REPORT	NO END SECTION	//"Verba"
		DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PXD"):GetText()} CONTENT {|| oSectLanc:Cell("HORAS" ):GetValue(.T.)}	BREAK oBreakLp TITLE OemToAnsi(STR0022) PICTURE "@E 9,999,999.99"		NO END REPORT	NO END SECTION	//"Horas"
		DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PXD"):GetText()} CONTENT {|| oSectLanc:Cell("DIAS"  ):GetValue(.T.)}	BREAK oBreakLp TITLE OemToAnsi(STR0023) PICTURE "@E 9,999,999.99"		NO END REPORT	NO END SECTION	//"Dias"
		
		If lImpBase
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PXD"):GetText()} CONTENT {|| oSectLanc:Cell("PROVEN"):GetValue(.T.)}	BREAK oBreakLp TITLE OemToAnsi(STR0057) PICTURE "@E 9,999,999,999,999.99"	NO END REPORT	NO END SECTION	//Provento / Base provento"
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PXD"):GetText()} CONTENT {|| oSectLanc:Cell("DESCON"):GetValue(.T.)}	BREAK oBreakLp TITLE OemToAnsi(STR0058) PICTURE "@E 9,999,999,999,999.99"	NO END REPORT	NO END SECTION	//"Desconto / Base Desconto"
		Else
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PXD"):GetText()} CONTENT {|| oSectLanc:Cell("PROVEN"):GetValue(.T.)}	BREAK oBreakLp TITLE OemToAnsi(STR0024) PICTURE "@E 9,999,999,999,999.99"	NO END REPORT	NO END SECTION	//Provento"
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PXD"):GetText()} CONTENT {|| oSectLanc:Cell("DESCON"):GetValue(.T.)}	BREAK oBreakLp TITLE OemToAnsi(STR0025) PICTURE "@E 9,999,999,999,999.99"	NO END REPORT	NO END SECTION	//"Desconto"
		EndIf

	EndIf

EndIf

If nOrdem == 11 .Or. nOrdem == 12
	oSectRPat:SetCharSeparator(": ")
	If nSinAna == 1	//Analitico
		DEFINE BREAK oBreakRpt OF oSectRPat WHEN  oSectRPat:Cell("RCO_CODIGO") TITLE OemToAnsi(STR0046) //"Total Registro Patronal"
	Else			//Sintetico
		DEFINE BREAK oBreakRpt OF oSectLanc WHEN  oSectFunc:Cell("RA_KEYLOC") TITLE OemToAnsi(STR0046) //"Total Registro Patronal"
	EndIf
	DEFINE FUNCTION NAME "RTOTHORAS"  FROM oSectLanc:Cell("HORAS" ) FUNCTION SUM     BREAK oBreakRpt NO END SECTION NO END REPORT TITLE OemToAnsi(STR0022) PICTURE "@E 999,999.99"         	//"Horas:"
	DEFINE FUNCTION NAME "RTOTDIAS"   FROM oSectLanc:Cell("DIAS"  ) FUNCTION SUM     BREAK oBreakRpt NO END SECTION NO END REPORT TITLE OemToAnsi(STR0023) PICTURE "@E 999,999.99"         	//"Dias:"

	If lImpBase
		DEFINE FUNCTION NAME "RPROVVALOR" FROM oSectLanc:Cell("PROVEN") FUNCTION SUM     BREAK oBreakRpt NO END SECTION NO END REPORT TITLE OemToAnsi(STR0057) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "1" } 	//"Provento / Base Provento:"
		DEFINE FUNCTION NAME "RDESCVALOR" FROM oSectLanc:Cell("DESCON") FUNCTION SUM     BREAK oBreakRpt NO END SECTION NO END REPORT TITLE OemToAnsi(STR0058) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "2" } 	//"Desconto / Base Desconto:
	Else
		DEFINE FUNCTION NAME "RPROVVALOR" FROM oSectLanc:Cell("PROVEN") FUNCTION SUM     BREAK oBreakRpt NO END SECTION NO END REPORT TITLE OemToAnsi(STR0024) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "1" } 	//"Provento:"
		DEFINE FUNCTION NAME "RDESCVALOR" FROM oSectLanc:Cell("DESCON") FUNCTION SUM     BREAK oBreakRpt NO END SECTION NO END REPORT TITLE OemToAnsi(STR0025) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "2" } 	//"Desconto:
	EndIf

	DEFINE FUNCTION NAME "RLIQVALOR"  FROM oSectLanc:Cell("LIQUI" ) FUNCTION ONPRINT BREAK oBreakRpt NO END SECTION NO END REPORT TITLE OemToAnsi(STR0026) PICTURE "@E 99,999,999,999.99" FORMULA {|| (oSectLanc:GetFunction("RPROVVALOR"):GetLastValue() - oSectLanc:GetFunction("RDESCVALOR"):GetLastValue()) } 	//"Liquido:"

	oBreakRpt:OnBreak({|x,y|cTitRpt:=OemToAnsi(STR0046)+" "+x})	
    oBreakRpt:SetTotalText({||cTitRpt})	//"Total Registro Patronal"
    oBreakRpt:SetTotalInLine(.F.)                                                                
	    	
	If nSinAna == 1	//Analitico
		DEFINE COLLECTION OF oSectLanc FUNCTION COUNT FORMULA {|| oSectLanc:Cell("PXD"):GetText() + " - " + oSectLanc:Cell("DESC"):GetText()} CONTENT {|| oSectLanc:Cell("PXD"):GetText()} BREAK oBreakRpt TITLE OemToAnsi(STR0053) PICTURE "9999"	NO END REPORT	NO END SECTION	//"Verba"
		DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PXD"):GetText()} CONTENT {|| oSectLanc:Cell("HORAS" ):GetValue(.T.)}	BREAK oBreakRpt TITLE OemToAnsi(STR0022) PICTURE "@E 9,999,999.99"		NO END REPORT	NO END SECTION	//"Horas"
		DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PXD"):GetText()} CONTENT {|| oSectLanc:Cell("DIAS"  ):GetValue(.T.)}	BREAK oBreakRpt TITLE OemToAnsi(STR0023) PICTURE "@E 9,999,999.99"		NO END REPORT	NO END SECTION	//"Dias"

		If lImpBase
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PXD"):GetText()} CONTENT {|| oSectLanc:Cell("PROVEN"):GetValue(.T.)}	BREAK oBreakRpt TITLE OemToAnsi(STR0057) PICTURE "@E 9,999,999,999,999.99"	 NO END REPORT	NO END SECTION	//Provento / Base Provento"
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PXD"):GetText()} CONTENT {|| oSectLanc:Cell("DESCON"):GetValue(.T.)}	BREAK oBreakRpt TITLE OemToAnsi(STR0058) PICTURE "@E 9,999,999,999,999.99" NO END REPORT	NO END SECTION	//"Desconto / Base Desconto"
		Else
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PXD"):GetText()} CONTENT {|| oSectLanc:Cell("PROVEN"):GetValue(.T.)}	BREAK oBreakRpt TITLE OemToAnsi(STR0024) PICTURE "@E 9,999,999,999,999.99"	 NO END REPORT	NO END SECTION	//Provento"
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PXD"):GetText()} CONTENT {|| oSectLanc:Cell("DESCON"):GetValue(.T.)}	BREAK oBreakRpt TITLE OemToAnsi(STR0025) PICTURE "@E 9,999,999,999,999.99" NO END REPORT	NO END SECTION	//"Desconto"
		EndIf
	EndIf
	
EndIf

If nOrdem == 13	//Verba
	If nSinAna == 1	//Analitico
		DEFINE BREAK oBreakPd OF oSectVerb WHEN  {|| (cAliasQry)->RA_FILIAL+(cAliasQry)->PXD } TITLE OemToAnsi(STR0009) //"Total da Verba"		
		DEFINE FUNCTION NAME "VTOTHORAS"  FROM oSectLanc:Cell("HORAS" ) FUNCTION SUM     BREAK oBreakPd NO END SECTION NO END REPORT TITLE OemToAnsi(STR0022) PICTURE "@E 999,999.99"         	//"Horas:"
		DEFINE FUNCTION NAME "VTOTDIAS"   FROM oSectLanc:Cell("DIAS"  ) FUNCTION SUM     BREAK oBreakPd NO END SECTION NO END REPORT TITLE OemToAnsi(STR0023) PICTURE "@E 999,999.99"         	//"Dias:"
		
		If lImpBase
			DEFINE FUNCTION NAME "VPROVVALOR" FROM oSectLanc:Cell("PROVEN") FUNCTION SUM     BREAK oBreakPd NO END SECTION NO END REPORT TITLE OemToAnsi(STR0057) PICTURE "@E 99,999,999,999.99" 	//"Provento / Base Provento:"
			DEFINE FUNCTION NAME "VDESCVALOR" FROM oSectLanc:Cell("DESCON") FUNCTION SUM     BREAK oBreakPd NO END SECTION NO END REPORT TITLE OemToAnsi(STR0058) PICTURE "@E 99,999,999,999.99" 	//"Desconto / Base Desconto:
		Else
			DEFINE FUNCTION NAME "VPROVVALOR" FROM oSectLanc:Cell("PROVEN") FUNCTION SUM     BREAK oBreakPd NO END SECTION NO END REPORT TITLE OemToAnsi(STR0024) PICTURE "@E 99,999,999,999.99" 	//"Provento:"
			DEFINE FUNCTION NAME "VDESCVALOR" FROM oSectLanc:Cell("DESCON") FUNCTION SUM     BREAK oBreakPd NO END SECTION NO END REPORT TITLE OemToAnsi(STR0025) PICTURE "@E 99,999,999,999.99" 	//"Desconto:
		EndIf

    	oBreakPd:SetTotalInLine(.F.)    	                                       
	EndIf
EndIf

If !oReport:lXlstable
	DEFINE BREAK oBreakFil OF oReport WHEN {||(cAliasQry)->RA_FILIAL}  TITLE OemToAnsi(STR0030) //"Total da Filial "

	oBreakFil:OnBreak({|x,y|cTitFil:=OemToAnsi(STR0030)+" "+x})	//"Total Filial"
	oBreakFil:SetTotalText({||cTitFil})
	oBreakFil:SetTotalInLine(.F.)

	DEFINE FUNCTION NAME "FTOTHORAS"  FROM oSectLanc:Cell("HORAS" ) FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT  TITLE OemToAnsi(STR0022) PICTURE "@E 999,999.99"         	//"Horas:"
	DEFINE FUNCTION NAME "FTOTDIAS"   FROM oSectLanc:Cell("DIAS"  ) FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT  TITLE OemToAnsi(STR0023) PICTURE "@E 999,999.99"         	//"Dias:"

	If nOrdem == 13
		If lImpBase
			DEFINE FUNCTION NAME "FPROVVALOR" FROM oSectLanc:Cell("PROVEN") FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT  TITLE OemToAnsi(STR0057) PICTURE "@E 99,999,999,999.99" 	//"Provento / Base Provento:"
			DEFINE FUNCTION NAME "FDESCVALOR" FROM oSectLanc:Cell("DESCON") FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT  TITLE OemToAnsi(STR0058) PICTURE "@E 99,999,999,999.99"  //"Desconto / Base Desconto:
		Else
			DEFINE FUNCTION NAME "FPROVVALOR" FROM oSectLanc:Cell("PROVEN") FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT  TITLE OemToAnsi(STR0024) PICTURE "@E 99,999,999,999.99" 	//"Provento:"
			DEFINE FUNCTION NAME "FDESCVALOR" FROM oSectLanc:Cell("DESCON") FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT  TITLE OemToAnsi(STR0025) PICTURE "@E 99,999,999,999.99" 	//"Desconto:
		EndIf
	Else
		If lImpBase
			DEFINE FUNCTION NAME "FPROVVALOR" FROM oSectLanc:Cell("PROVEN") FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT TITLE OemToAnsi(STR0057) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "1" } 	//"Provento / Base Provento:"
			DEFINE FUNCTION NAME "FDESCVALOR" FROM oSectLanc:Cell("DESCON") FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT TITLE OemToAnsi(STR0058) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "2" } 	//"Desconto / Base Desconto:
		Else
			DEFINE FUNCTION NAME "FPROVVALOR" FROM oSectLanc:Cell("PROVEN") FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT TITLE OemToAnsi(STR0024) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "1" } 	//"Provento:"
			DEFINE FUNCTION NAME "FDESCVALOR" FROM oSectLanc:Cell("DESCON") FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT TITLE OemToAnsi(STR0025) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "2" } 	//"Desconto:
		EndIf

		DEFINE FUNCTION NAME "FLIQVALOR"  FROM oSectLanc:Cell("LIQUI" ) FUNCTION ONPRINT BREAK oBreakFil NO END SECTION NO END REPORT TITLE OemToAnsi(STR0026) PICTURE "@E 99,999,999,999.99" FORMULA {|| (oSectLanc:GetFunction("FPROVVALOR"):GetLastValue() - oSectLanc:GetFunction("FDESCVALOR"):GetLastValue()) } 	//"Liquido:"
	EndIf

	If lImpEmpr
		DEFINE COLLECTION OF oSectLanc FUNCTION COUNT	FORMULA {|| oSectLanc:Cell("PXD"):GetText() + " - " + oSectLanc:Cell("DESC"):GetText()} CONTENT {|| oSectLanc:Cell("PXD"):GetText()} BREAK oBreakFil TITLE OemToAnsi(STR0013) PICTURE "9999"	NO END SECTION NO END REPORT	//"Verba"
		DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PXD"):GetText()} CONTENT {|| oSectLanc:Cell("HORAS" ):GetValue(.T.)}	BREAK oBreakFil TITLE OemToAnsi(STR0022) PICTURE "@E 9,999,999.99"		NO END SECTION NO END REPORT	//"Horas"
		DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PXD"):GetText()} CONTENT {|| oSectLanc:Cell("DIAS"  ):GetValue(.T.)}	BREAK oBreakFil TITLE OemToAnsi(STR0023) PICTURE "@E 9,999,999.99"		NO END SECTION NO END REPORT	//"Dias"

		If lImpBase
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PXD"):GetText()} CONTENT {|| oSectLanc:Cell("PROVEN"):GetValue(.T.)}	BREAK oBreakFil TITLE OemToAnsi(STR0057) PICTURE "@E 9,999,999,999,999.99"	NO END SECTION NO END REPORT	//Provento / Base Provento"
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PXD"):GetText()} CONTENT {|| oSectLanc:Cell("DESCON"):GetValue(.T.)}	BREAK oBreakFil TITLE OemToAnsi(STR0058) PICTURE "@E 9,999,999,999,999.99"	NO END SECTION NO END REPORT	//"Desconto / Base Desconto"
		Else
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PXD"):GetText()} CONTENT {|| oSectLanc:Cell("PROVEN"):GetValue(.T.)}	BREAK oBreakFil TITLE OemToAnsi(STR0024) PICTURE "@E 9,999,999,999,999.99"	NO END SECTION NO END REPORT	//Provento"
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PXD"):GetText()} CONTENT {|| oSectLanc:Cell("DESCON"):GetValue(.T.)}	BREAK oBreakFil TITLE OemToAnsi(STR0025) PICTURE "@E 9,999,999,999,999.99"	NO END SECTION NO END REPORT	//"Desconto"
		EndIf
	EndIf

	If lCorpManage .AND. lImpEmpr
		If lUniNeg
			DEFINE BREAK oBreakUnN OF oReport   WHEN  { || Substr((cAliasQry)->RA_FILIAL, nStartUnN, nUnNLength) }

			DEFINE FUNCTION NAME "FUNTOTHORAS"  FROM oSectLanc:Cell("HORAS" ) FUNCTION SUM BREAK oBreakUnN NO END SECTION NO END REPORT TITLE OemToAnsi(STR0022) PICTURE "@E 999,999.99"         	//"Horas:"
			DEFINE FUNCTION NAME "FUNTUNOTDIAS"   FROM oSectLanc:Cell("DIAS"  ) FUNCTION SUM BREAK oBreakUnN NO END SECTION NO END REPORT TITLE OemToAnsi(STR0023) PICTURE "@E 999,999.99"         	//"Dias:"
			
			If nOrdem == 13
				If lImpBase
					DEFINE FUNCTION NAME "FUNPROVVALOR" FROM oSectLanc:Cell("PROVEN") FUNCTION SUM     BREAK oBreakUnN NO END SECTION NO END REPORT TITLE OemToAnsi(STR0057) PICTURE "@E 99,999,999,999.99" 	//"Provento / Base Provento:"
					DEFINE FUNCTION NAME "FUNDESCVALOR" FROM oSectLanc:Cell("DESCON") FUNCTION SUM     BREAK oBreakUnN NO END SECTION NO END REPORT TITLE OemToAnsi(STR0058) PICTURE "@E 99,999,999,999.99" 	//"Desconto / Base Desconto:
				Else
					DEFINE FUNCTION NAME "FUNPROVVALOR" FROM oSectLanc:Cell("PROVEN") FUNCTION SUM     BREAK oBreakUnN NO END SECTION NO END REPORT TITLE OemToAnsi(STR0024) PICTURE "@E 99,999,999,999.99" 	//"Provento:"
					DEFINE FUNCTION NAME "FUNDESCVALOR" FROM oSectLanc:Cell("DESCON") FUNCTION SUM     BREAK oBreakUnN NO END SECTION NO END REPORT TITLE OemToAnsi(STR0025) PICTURE "@E 99,999,999,999.99" 	//"Desconto:
				EndIf
			Else
				If lImpBase
					DEFINE FUNCTION NAME "FUNPROVVALOR" FROM oSectLanc:Cell("PROVEN") FUNCTION SUM     BREAK oBreakUnN NO END SECTION NO END REPORT TITLE OemToAnsi(STR0057) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "1" } 	//"Provento / Base Provento:"
					DEFINE FUNCTION NAME "FUNDESCVALOR" FROM oSectLanc:Cell("DESCON") FUNCTION SUM     BREAK oBreakUnN NO END SECTION NO END REPORT TITLE OemToAnsi(STR0058) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "2" } 	//"Desconto / Base Desconto:
				Else
					DEFINE FUNCTION NAME "FUNPROVVALOR" FROM oSectLanc:Cell("PROVEN") FUNCTION SUM     BREAK oBreakUnN NO END SECTION NO END REPORT TITLE OemToAnsi(STR0024) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "1" } 	//"Provento:"
					DEFINE FUNCTION NAME "FUNDESCVALOR" FROM oSectLanc:Cell("DESCON") FUNCTION SUM     BREAK oBreakUnN NO END SECTION NO END REPORT TITLE OemToAnsi(STR0025) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "2" } 	//"Desconto:
				EndIf
				
				DEFINE FUNCTION NAME "FUNLIQVALOR"  FROM oSectLanc:Cell("LIQUI" ) FUNCTION ONPRINT BREAK oBreakUnN NO END SECTION NO END REPORT TITLE OemToAnsi(STR0026) PICTURE "@E 99,999,999,999.99" FORMULA {|| (oSectLanc:GetFunction("FUNPROVVALOR"):GetLastValue() - oSectLanc:GetFunction("FUNDESCVALOR"):GetLastValue()) } 	//"Liquido:"
			EndIf

			oBreakUnN:OnBreak({ |x, y| cTitUnN := OemToAnsi(STR0055) + ": " + x })	//"Total Unidade de Negocios:"
			oBreakUnN:SetTotalText({ || cTitUnN })
			oBreakUnN:SetTotalInLine(.F.)

			DEFINE COLLECTION OF oSectLanc FUNCTION COUNT FORMULA {|| oSectLanc:Cell("PXD"):GetText() + " - " + oSectLanc:Cell("DESC"):GetText()} CONTENT {|| oSectLanc:Cell("PXD"):GetText()} BREAK oBreakUnN TITLE OemToAnsi(STR0013) PICTURE "9999"	NO END SECTION NO END REPORT	//"Verba"
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PXD"):GetText()} CONTENT {|| oSectLanc:Cell("HORAS" ):GetValue(.T.)}	BREAK oBreakUnN TITLE OemToAnsi(STR0022) PICTURE "@E 9,999,999.99"		NO END SECTION NO END REPORT	//"Horas"
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PXD"):GetText()} CONTENT {|| oSectLanc:Cell("DIAS"  ):GetValue(.T.)}	BREAK oBreakUnN TITLE OemToAnsi(STR0023) PICTURE "@E 9,999,999.99"		NO END SECTION NO END REPORT	//"Dias"

			If lImpBase
				DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PXD"):GetText()} CONTENT {|| oSectLanc:Cell("PROVEN"):GetValue(.T.)}	BREAK oBreakUnN TITLE OemToAnsi(STR0057) PICTURE "@E 9,999,999,999,999.99"	NO END SECTION NO END REPORT	//Provento / Base Provento"
				DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PXD"):GetText()} CONTENT {|| oSectLanc:Cell("DESCON"):GetValue(.T.)}	BREAK oBreakUnN TITLE OemToAnsi(STR0058) PICTURE "@E 9,999,999,999,999.99"	NO END SECTION NO END REPORT	//"Desconto / Base Desconto"
			Else
				DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PXD"):GetText()} CONTENT {|| oSectLanc:Cell("PROVEN"):GetValue(.T.)}	BREAK oBreakUnN TITLE OemToAnsi(STR0024) PICTURE "@E 9,999,999,999,999.99"	NO END SECTION NO END REPORT	//Provento"
				DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PXD"):GetText()} CONTENT {|| oSectLanc:Cell("DESCON"):GetValue(.T.)}	BREAK oBreakUnN TITLE OemToAnsi(STR0025) PICTURE "@E 9,999,999,999,999.99"	NO END SECTION NO END REPORT	//"Desconto"
			EndIf
		EndIf

		If lEmpFil
			DEFINE BREAK oBreakEFil OF oReport   WHEN  { || Substr((cAliasQry)->RA_FILIAL, nStartEmp, nEmpLength) }

			DEFINE FUNCTION NAME "FEFTOTHORAS"  FROM oSectLanc:Cell("HORAS" ) FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT TITLE OemToAnsi(STR0022) PICTURE "@E 999,999.99"         	//"Horas:"
			DEFINE FUNCTION NAME "FEFTOTDIAS"   FROM oSectLanc:Cell("DIAS"  ) FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT TITLE OemToAnsi(STR0023) PICTURE "@E 999,999.99"         	//"Dias:"
			
			If nOrdem == 13
				If lImpBase
					DEFINE FUNCTION NAME "FEFPROVVALOR" FROM oSectLanc:Cell("PROVEN") FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT TITLE OemToAnsi(STR0057) PICTURE "@E 99,999,999,999.99" 	//"Provento / Base Provento:"
					DEFINE FUNCTION NAME "FEFDESCVALOR" FROM oSectLanc:Cell("DESCON") FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT TITLE OemToAnsi(STR0058) PICTURE "@E 99,999,999,999.99" 	//"Desconto / Base Desconto:
				Else
					DEFINE FUNCTION NAME "FEFPROVVALOR" FROM oSectLanc:Cell("PROVEN") FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT TITLE OemToAnsi(STR0024) PICTURE "@E 99,999,999,999.99" 	//"Provento:"
					DEFINE FUNCTION NAME "FEFDESCVALOR" FROM oSectLanc:Cell("DESCON") FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT TITLE OemToAnsi(STR0025) PICTURE "@E 99,999,999,999.99" 	//"Desconto:
				EndIf
			Else
				If lImpBase
					DEFINE FUNCTION NAME "FEFPROVVALOR" FROM oSectLanc:Cell("PROVEN") FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT TITLE OemToAnsi(STR0057) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "1" } 	//"Provento / Base provento:"
					DEFINE FUNCTION NAME "FEFDESCVALOR" FROM oSectLanc:Cell("DESCON") FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT TITLE OemToAnsi(STR0058) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "2" } 	//"Desconto / Base Desconto:
				Else
					DEFINE FUNCTION NAME "FEFPROVVALOR" FROM oSectLanc:Cell("PROVEN") FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT TITLE OemToAnsi(STR0024) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "1" } 	//"Provento:"
					DEFINE FUNCTION NAME "FEFDESCVALOR" FROM oSectLanc:Cell("DESCON") FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT TITLE OemToAnsi(STR0025) PICTURE "@E 99,999,999,999.99" WHEN {|| oSectLanc:Cell("SINAL" ):GetText() == "2" } 	//"Desconto:
				EndIf

				DEFINE FUNCTION NAME "FEFLIQVALOR"  FROM oSectLanc:Cell("LIQUI" ) FUNCTION ONPRINT BREAK oBreakEFil NO END SECTION NO END REPORT TITLE OemToAnsi(STR0026) PICTURE "@E 99,999,999,999.99" FORMULA {|| (oSectLanc:GetFunction("FEFPROVVALOR"):GetLastValue() - oSectLanc:GetFunction("FEFDESCVALOR"):GetLastValue()) } 	//"Liquido:"
			EndIf

			oBreakEFil:OnBreak({ |x,y| cTitEFil := OemToAnsi(STR0056) + ": " + x })	//"Total Empresa"
			oBreakEFil:SetTotalText({ || cTitEFil })
			oBreakEFil:SetTotalInLine(.F.)

			DEFINE COLLECTION OF oSectLanc FUNCTION COUNT FORMULA {|| oSectLanc:Cell("PXD"):GetText() + " - " + oSectLanc:Cell("DESC"):GetText()} CONTENT {|| oSectLanc:Cell("PXD"):GetText()} BREAK oBreakEFil TITLE OemToAnsi(STR0013) PICTURE "9999"	NO END SECTION NO END REPORT	//"Verba"
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PXD"):GetText()} CONTENT {|| oSectLanc:Cell("HORAS" ):GetValue(.T.)}	BREAK oBreakEFil TITLE OemToAnsi(STR0022) PICTURE "@E 9,999,999.99"		NO END SECTION NO END REPORT	//"Horas"
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PXD"):GetText()} CONTENT {|| oSectLanc:Cell("DIAS"  ):GetValue(.T.)}	BREAK oBreakEFil TITLE OemToAnsi(STR0023) PICTURE "@E 9,999,999.99"		NO END SECTION NO END REPORT	//"Dias"

			If lImpBase
				DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PXD"):GetText()} CONTENT {|| oSectLanc:Cell("PROVEN"):GetValue(.T.)}	BREAK oBreakEFil TITLE OemToAnsi(STR0057) PICTURE "@E 9,999,999,999,999.99"	NO END SECTION NO END REPORT	//Provento / Base Provento"
				DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PXD"):GetText()} CONTENT {|| oSectLanc:Cell("DESCON"):GetValue(.T.)}	BREAK oBreakEFil TITLE OemToAnsi(STR0058) PICTURE "@E 9,999,999,999,999.99"	NO END SECTION NO END REPORT	//"Desconto / Base Desconto"
			Else
				DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PXD"):GetText()} CONTENT {|| oSectLanc:Cell("PROVEN"):GetValue(.T.)}	BREAK oBreakEFil TITLE OemToAnsi(STR0024) PICTURE "@E 9,999,999,999,999.99"	NO END SECTION NO END REPORT	//Provento"
				DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PXD"):GetText()} CONTENT {|| oSectLanc:Cell("DESCON"):GetValue(.T.)}	BREAK oBreakEFil TITLE OemToAnsi(STR0025) PICTURE "@E 9,999,999,999,999.99"	NO END SECTION NO END REPORT	//"Desconto"
			EndIf

		EndIf   
	EndIf
EndIf

cSitQuery	:= ""
For nReg:=1 to Len(cSituacao)
	cSitQuery += "'"+Subs(cSituacao,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cSituacao)
		cSitQuery += "," 
	Endif
Next nReg     

cCatQuery	:= ""
For nReg:=1 to Len(cCategoria)
	cCatQuery += "'"+Subs(cCategoria,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cCategoria)
		cCatQuery += "," 
	Endif
Next nReg

MakeSqlExpr(cPerg)    


If nOrdem == 1
	cOrdem := "%RA_FILIAL,RA_MAT,PXD%"
ElseIf nOrdem == 2
	cOrdem := "%RA_FILIAL,RA_NOME,RA_MAT,PXD%"
ElseIf nOrdem == 3
	cOrdem := "%RA_FILIAL,CCUSTO,RA_MAT,PXD%"
ElseIf nOrdem == 4
	cOrdem := "%RA_FILIAL,CCUSTO,RA_NOME,RA_MAT,PXD%"
ElseIf nOrdem == 5
	cOrdem := "%RA_FILIAL,RA_DEPTO,RA_MAT,PXD%" 
ElseIf nOrdem == 6
	cOrdem := "%RA_FILIAL,RA_DEPTO,RA_NOME,RA_MAT,PXD%"
ElseIf nOrdem == 7
	cOrdem := "%RA_FILIAL,CCUSTO,RA_DEPTO,RA_MAT,PXD%"
ElseIf nOrdem == 8
	cOrdem := "%RA_FILIAL,CCUSTO,RA_DEPTO,RA_NOME,RA_MAT,PXD%"
ElseIf nOrdem == 9
	cOrdem := "%RA_FILIAL,RA_KEYLOC,RA_MAT,PXD%"
ElseIf nOrdem == 10
	cOrdem := "%RA_FILIAL,RA_KEYLOC,RA_NOME,RA_MAT,PXD%"
ElseIf nOrdem == 11
	cOrdem := "%RA_FILIAL,RA_CODRPAT,RA_MAT,PXD%"
ElseIf nOrdem == 12
	cOrdem := "%RA_FILIAL,RA_CODRPAT,RA_NOME,RA_MAT,PXD%"
ElseIf nOrdem == 13
	cOrdem := "%RA_FILIAL,PXD,RA_MAT%"				
Endif


If !lAllVerbas

	IF Substr(cCodigos,1,1) == '*'
		nIni := 2
	Endif

	For nReg:=nIni to Len(cCodigos) step 3
		If Substr(cCodigos,nReg,1) != "*"
			cVerQuery += "'"+Subs(cCodigos,nReg,3)+"'"
			If ( nReg+3 ) < Len(cCodigos)
				cVerQuery += "," 
			Endif
		Endif
	Next nReg 
EndIf
	
cSitQuery	:= "%" + cSitQuery + "%"
cCatQuery	:= "%" + cCatQuery + "%"
cAliasQry	:= GetNextAlias()

//-- Filial
If !Empty(mv_par01)
	cFiltro += mv_par01
EndIf

//Filtra filiais de acesso do usuario
cValidFil := "% RA_FILIAL IN ('' "
For nX := 1 to Len(aValidFil)
	cValidFil += ", '" + aValidFil[nX] + "' "
Next nX
cValidFil += ") %"

//-- Centro de Custo
If !Empty(mv_par02)
	cFiltro += Iif(!Empty(cFiltro)," AND ","")
	cFiltro += mv_par02
EndIf

//-- Departamento
If !Empty(mv_par03)
	cFiltro += Iif(!Empty(cFiltro)," AND ","")
	cFiltro += mv_par03
EndIf

//=== Matricula   
If !Empty(mv_par04)
	cFiltro += Iif(!Empty(cFiltro)," AND ","")
	cFiltro	+= mv_par04
EndIf

//=== Nome   
If !Empty(mv_par05)
	cFiltro += Iif(!Empty(cFiltro)," AND ","")
	cFiltro += mv_par05
EndIf


//== Verbas
If !lAllVerbas
	If Empty(cFiltro)
		cFiltroC := cFiltro + If(!Empty(cVerQuery) .And. cVerQuery != "*", " SRC.RC_PD IN ("+cVerQuery+")","")
		cFiltroD := cFiltro + If(!Empty(cVerQuery) .And. cVerQuery != "*", " SRD.RD_PD IN ("+cVerQuery+")","")
	Else
		cFiltroC := cFiltro + If(!Empty(cVerQuery) .And. cVerQuery != "*", " AND SRC.RC_PD IN ("+cVerQuery+")","")
		cFiltroD := cFiltro + If(!Empty(cVerQuery) .And. cVerQuery != "*", " AND SRD.RD_PD IN ("+cVerQuery+")","")
	EndIf
Else
	If !Empty(cFiltro)
		cFiltroC	:= cFiltro
		cFiltroD	:= cFiltro
	EndIf
EndIf

cFiltroC += Iif(!Empty(cFiltroC)," AND " ,"")
cFiltroD += Iif(!Empty(cFiltroD)," AND " ,"")

If !lImpBase
	cFiltroPDB := "% RV_TIPOCOD IN ('1', '2') %"
Else
	cFiltroPDB := "% 1 = 1 %"
EndIf

//Checagem da gestao de empresas quando estiver selecionado
//parametro (pergunta) 'Listar todas as verbas?'

For nCont := 1 to 3
	aPosics[nCont] := Len(FWSM0Layout(,nCont)) //Pega quantidade de caracteres usados para empresa, unid. negocio, filial
Next

cJoinSRC := "%SRA.RA_FILIAL = SRC.RC_FILIAL AND%"	
cJoinSRD := "%SRA.RA_FILIAL = SRD.RD_FILIAL AND%"
cFilPdSRC := "% SRC.RC_PD=SRV.RV_COD AND SRV.RV_FILIAL = '" + FWxFilial("SRV", SRC->RC_FILIAL) + "'%"
cFilPdSRD := "% SRD.RD_PD=SRV.RV_COD AND SRV.RV_FILIAL = '" + FWxFilial("SRV", SRD->RD_FILIAL) + "'%"  
 
SRA->( dbCloseArea() ) //Fecha o SRA para uso da Query

cUserFiltro := ''

If nOrdem == 1 .Or. nOrdem == 2 //"(Matricula ou Nome) + Lançamentos"	
	
	If nSinAna == 1 //Analitico	
		cCpoAdic	:= "%, SQB.QB_DESCRIC%"
	Else //Sintetico
		cCpoAdic	:= "%%"		
	Endif
	
	cJoinDep := fGetJOINGestEmp (aPosics, 'SQB', 'QB_FILIAL', 'SRA', 'RA_FILIAL')	
	cJoin   	:= "% LEFT JOIN " + RetSqlName("SQB") + " SQB ON SRA.RA_DEPTO = SQB.QB_DEPTO" + cJoinDep + " AND  SQB.D_E_L_E_T_= ' '%"  	
	cNotDel		:= "% AND (SQB.D_E_L_E_T_ IS NULL OR SQB.D_E_L_E_T_= ' ') %"
	BEGIN REPORT QUERY oSectFunc
	
ElseIf nOrdem == 3 .Or. nOrdem == 4 //"C.Custo + (Matrícula ou Nome) + Lançamentos"

	If nSinAna == 1
		cCpoAdic	:= "%, CTT.CTT_FILIAL, CTT.CTT_CUSTO, CTT.CTT_DESC01, SQB.QB_DESCRIC%"
	Else
		cCpoAdic	:= "%, CTT.CTT_FILIAL, CTT.CTT_CUSTO, CTT.CTT_DESC01%"		
	Endif

	cJoinDep := " AND SQB.QB_FILIAL = '" + FWxFilial("SQB", SRA->RA_FILIAL) + "'"
	cJoinCTT := " AND CTT.CTT_FILIAL = '" + FWxFilial("CTT", SRC->RC_FILIAL) + "'"  
	
	cJoin		:= "% INNER JOIN " + RetSqlName("CTT") + " CTT ON SRC.RC_CC = CTT.CTT_CUSTO " + cJoinCTT
	cJoin   	+= " LEFT JOIN " + RetSqlName("SQB") + " SQB ON SRA.RA_DEPTO = SQB.QB_DEPTO" + cJoinDep + "%"  		
	cNotDel		:= "% AND CTT.D_E_L_E_T_= ' ' AND (SQB.D_E_L_E_T_ IS NULL OR SQB.D_E_L_E_T_= ' ') %"
	cCpoQuebra  := "CTT_CUSTO"
	
	BEGIN REPORT QUERY oSectCCus
	
ElseIf nOrdem == 5 .Or. nOrdem == 6 //"Depto + (Matricula ou Nome) + Lançamentos"

	If nSinAna == 1
		cCpoAdic	:= "%, SQB.QB_FILIAL, SQB.QB_DEPTO, SQB.QB_DESCRIC %"		
	Else
		cCpoAdic	:= "%, RA_DEPTO, SQB.QB_FILIAL, SQB.QB_DEPTO, SQB.QB_DESCRIC %"				
	Endif
	cJoinDep := fGetJOINGestEmp (aPosics, 'SQB', 'QB_FILIAL', 'SRA', 'RA_FILIAL')
	cJoin   	:= "% LEFT JOIN " + RetSqlName("SQB") + " SQB ON SRA.RA_DEPTO = SQB.QB_DEPTO " + cJoinDep + "%"  
	cNotDel		:= "% AND (SQB.D_E_L_E_T_ IS NULL OR SQB.D_E_L_E_T_= ' ') %"
	//cCpoQuebra	:= "SRA.RA_DEPTO, SQB.QB_DEPTO, SQB.QB_DESCRIC"
	cCpoQuebra	:= "RA_DEPTO, QB_DEPTO, QB_DESCRIC"
	BEGIN REPORT QUERY oSectDept
	
ElseIf nOrdem == 7 .Or. nOrdem == 8 //"C.Custo + Depto + (Matricula ou Nome) + Lançamentos"

	cCpoAdic    := "% , CTT.CTT_FILIAL, CTT.CTT_CUSTO, CTT.CTT_DESC01, SQB.QB_FILIAL, SQB.QB_CC, SQB.QB_DEPTO, SQB.QB_DESCRIC %"
	cJoinDep := fGetJOINGestEmp (aPosics, 'SQB', 'QB_FILIAL', 'SRA', 'RA_FILIAL')
	cJoinCTT := fGetJOINGestEmp (aPosics, 'CTT', 'CTT_FILIAL', 'SRC', 'RC_FILIAL')			
	cJoin		+= "%  INNER JOIN " + RetSqlName("CTT") + " CTT ON SRC.RC_CC = CTT.CTT_CUSTO " + cJoinCTT
	cJoin   	+= " LEFT JOIN " + RetSqlName("SQB") + " SQB ON SRA.RA_DEPTO = SQB.QB_DEPTO " + cJoinDep + "%"	  			
	cNotDel		:= "% AND CTT.D_E_L_E_T_= ' ' AND (SQB.D_E_L_E_T_ IS NULL OR SQB.D_E_L_E_T_= ' ') %"	
	//cCpoQuebra	:= "CTT.CTT_CUSTO, SQB.QB_DEPTO"	
	cCpoQuebra	:= "CTT_CUSTO, QB_DEPTO"
	BEGIN REPORT QUERY oSectCCus
	
ElseIf nOrdem == 9 .Or. nOrdem == 10

	cCpoAdic	:= "% , RGC.RGC_FILIAL, RGC.RGC_KEYLOC, RGC.RGC_DESLOC %"
	cJoin		:= "%%"
	cNotDel		:= "%%"
	cCpoQuebra	:= "SRA.RA_KEYLOC"	
	BEGIN REPORT QUERY oSectLocp
	
ElseIf nOrdem == 11 .Or. nOrdem == 12

	cCpoAdic	:= "% , RCO.RCO_FILIAL, RCO.RCO_CODIGO, RCO.RCO_NREPAT, RCO.RCO_NOME %"
	cJoin		:= "% LEFT JOIN " + RetSqlName("RCO") + " RCO ON SRA.RA_CODRPAT = RCO.RCO_CODIGO %"
	cNotDel		:= "% AND RCO.D_E_L_E_T_= ' ' %"
	cCpoQuebra	:= "SRA.RA_CODRPAT"	
	BEGIN REPORT QUERY oSectRPat
	
ElseIf nOrdem == 13 //"Verba + Lançamentos"

	cCpoAdic	:= "%%"
	cJoin		:= "%%"
	cNotDel		:= "%%"		
	BEGIN REPORT QUERY oSectVerb
EndIf

IF lItemClvl
	cCpoAddSRC	:= Iif(!Empty(cCpoAdic), "" + StrTran(cCpoAdic, "%", "") + ", SRC.RC_ITEM, SRC.RC_CLVL", ", SRC.RC_ITEM, SRC.RC_CLVL")
	cCpoAddSRD	:= Iif(!Empty(cCpoAdic), "" + StrTran(cCpoAdic, "%", "") + ", SRD.RD_ITEM, SRD.RD_CLVL", ", SRD.RD_ITEM, SRD.RD_CLVL")
ENDIF

cCpoDelim	:= "%RA_FILIAL "
cCpoDelim	+= Iif(!Empty(cCpoQuebra),","+AllTrim(cCpoQuebra),"")
cCpoDelim	+= "%"

If !Empty(cCpoQuebra)
	cCpoQuebra := "%" + cCpoQuebra + ",%"
Else
	cCpoQuebra := "%%"
Endif

cJoinC		:= Iif(Empty(cJoinC),cJoin,"%"+cJoinC+"%")
cJoinC		:= Iif(Empty(cOrgJoin),cJoinC,Left(AllTrim(cJoinC),Len(AllTrim(cJoinC))-1)+cOrgJoin+"%")

cJoinD		:= Iif(Empty(cJoinD),cJoin,"%"+cJoinD+"%")
cJoinD		:= Iif(Empty(cOrgJoin),cJoinD,Left(AllTrim(cJoinD),Len(AllTrim(cJoinD))-1)+cOrgJoin+"%")
cJoinD		:= StrTran(cJoinD, "SRC", "SRD")
cJoinD		:= StrTran(cJoinD, "RC_", "RD_")

If nOrdem <> 13 
	cUserFiltro += IIF (!EMPTY(oSectFunc:GetUserExp( "SRA",.T.)), oSectFunc:GetUserExp( "SRA",.T.) + " AND ", "")
	cUserFiltro += IIF (!EMPTY(oSectFunc:GetUserExp( "SQB",.T.)), oSectFunc:GetUserExp( "SQB",.T.) + " AND ", "")
	cUserFiltro += IIF (!EMPTY(oSectFunc:GetUserExp( "RCO",.T.)), oSectFunc:GetUserExp( "RCO",.T.) + " AND ", "")
	cUserFiltro += IIF (!EMPTY(oSectFunc:GetUserExp( "RGC",.T.)), oSectFunc:GetUserExp( "RGC",.T.) + " AND ", "")
	cUserFiltro += IIF (!EMPTY(oSectFunc:GetUserExp( "CTT",.T.)), oSectFunc:GetUserExp( "CTT",.T.) + " AND ", "")
Endif 

cUserFiltro += IIF (!EMPTY(oSectLanc:GetUserExp( "SRC",.T.)), oSectLanc:GetUserExp( "SRC",.T.) + " AND ", "")
cUserFiltro += IIF (!EMPTY(oSectLanc:GetUserExp( "SRD",.T.)), oSectLanc:GetUserExp( "SRD",.T.) + " AND ", "")
cUserFiltro += IIF (!EMPTY(oSectLanc:GetUserExp( "SRV",.T.)), oSectLanc:GetUserExp( "SRV",.T.) + " AND ", "")
cUserFiltro += IIF (!EMPTY(oSectLanc:GetUserExp( "SRA",.T.)), oSectLanc:GetUserExp( "SRA",.T.) + " AND ", "")

cUserFiltro += IIF (!EMPTY(oSectionh:GetUserExp( "SRA",.T.)), oSectionh:GetUserExp( "SRA",.T.) + " AND ", "")

cFiltroD := Iif(Empty(cFiltroD) .and. empty(cUserFiltro),"%%","%"+cFiltroD + cUserFiltro + "%")
cFiltroC := Iif(Empty(cFiltroC) .and. empty(cUserFiltro),"%%","%"+cFiltroC + cUserFiltro + "%")

If nSinAna == 1 	//Analitico

	cAdicSRC += Iif(Empty(cCpoAddSRC), cCpoAdic, + "%" + cCpoAddSRC + "%") 
	cAdicSRD += Iif(Empty(cCpoAddSRD), cCpoAdic, + "%" + cCpoAddSRD + "%") 

	Do Case
	
		Case nOrdem == 9 .Or. nOrdem == 10 //Localidade Pagamento
		
			BeginSql alias cAliasQry
			
				SELECT SRA.RA_FILIAL,       SRA.RA_MAT,         	SRA.RA_CC,              SRA.RA_NOME,           
					SRA.RA_DEPTO,           SRA.RA_HRSMES,      	SRA.RA_SALARIO,         SRA.RA_SITFOLH,
					SRA.RA_KEYLOC,          SRC.RC_FILIAL FILIAL,   SRC.RC_MAT MAT, 		SRC.RC_FILIAL,      
					SRC.RC_CC CCUSTO,		SRC.RC_PD PXD,       	SRC.RC_TIPO1 TIPO1,     SRC.RC_QTDSEM QTDSEM, 
					SRC.RC_HORINFO HORINFO, SRC.RC_HORAS HORAS, 	SRC.RC_VALINFO VALINFO, SRC.RC_VALOR VALOR,   
					SRC.RC_VNAOAPL VNAOAPL, SRC.RC_DATA DATPGT, 	SRC.RC_DTREF DTREF,     SRC.RC_SEMANA SEMANA, 
					SRC.RC_PARCELA PARCELA, SRC.RC_TIPO2 TIPO2, 	SRC.RC_SEQ SEQ,         SRC.RC_PROCES PROCES, 
					SRC.RC_PERIODO PERIODO, SRC.RC_POSTO POSTO, 	SRC.RC_NUMID NUMID,     SRC.RC_ROTEIR ROTEIR,  
					SRV.RV_COD CODPD,       SRV.RV_DESC DESCPD, 	SRV.RV_TIPOCOD TIPOCOD, SRV.RV_TIPO TIPOPD, SQB.QB_DESCRIC		
					%exp:cAdicSRC%
				FROM %table:SRA% SRA
				    
				INNER JOIN %table:SRC% SRC 
					//ON SRA.RA_FILIAL = SRC.RC_FILIAL AND SRA.RA_MAT = SRC.RC_MAT
					ON %exp:cJoinSRC% SRA.RA_MAT = SRC.RC_MAT					
							
				%exp:cJoinC%																				

				INNER JOIN %table:SRV% SRV
					//ON SRV.RV_FILIAL = %exp:cFilPd%	AND SRV.RV_COD = SRC.RC_PD
					ON SRV.RV_COD = SRC.RC_PD					
					
				%exp:cJoinSQB%					
														
				LEFT JOIN %table:RGC% RGC 
					ON RGC.RGC_KEYLOC = SRA.RA_KEYLOC AND RGC.D_E_L_E_T_ = ' '
					
				%exp:cJoinRGC%					
					
				WHERE	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND
				   		SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND
				   		SRC.RC_PROCES  =   %exp:Upper(cProcesso)%  AND
				   		SRC.RC_PERIODO =   %exp:Upper(cPeriodo)%   AND  
				   		SRC.RC_ROTEIR  =   %exp:Upper(cRot)%   AND
				   		SRC.RC_SEMANA  =   %exp:Upper(cPagamento)% AND
				   		SQB.%notDel% AND
						SRA.%notDel% AND
						%exp:cValidFil% AND
				   		%exp:cFiltroC% 
						SRC.%notDel% AND
						%exp:cFiltroPDB% AND 
						SRV.%notDel% 
						%exp:cNotDel%
				UNION
		
				SELECT SRA.RA_FILIAL,           SRA.RA_MAT,           SRA.RA_CC,              	SRA.RA_NOME,
						SRA.RA_DEPTO,           SRA.RA_HRSMES,        SRA.RA_SALARIO,         	SRA.RA_SITFOLH,
						SRA.RA_KEYLOC,          SRD.RD_FILIAL FILIAL, SRD.RD_MAT MAT, 			SRD.RD_FILIAL,       
						SRD.RD_CC CCUSTO,	    SRD.RD_PD PXD,        SRD.RD_TIPO1 TIPO1,     	SRD.RD_QTDSEM QTDSEM, 
						SRD.RD_HORINFO HORINFO, SRD.RD_HORAS HORAS,   SRD.RD_VALINFO VALINFO, 	SRD.RD_VALOR VALOR,   
						SRD.RD_VNAOAPL VNAOAPL, SRD.RD_DATPGT DATPGT, SRD.RD_DTREF DTREF,     	SRD.RD_SEMANA SEMANA, 
						0 PARCELA,              SRD.RD_TIPO2 TIPO2,   SRD.RD_SEQ SEQ,         	SRD.RD_PROCES PROCES, 
						SRD.RD_PERIODO PERIODO, SRD.RD_POSTO POSTO,   SRD.RD_NUMID NUMID,     	SRD.RD_ROTEIR ROTEIR,  
						SRV.RV_COD CODPD,       SRV.RV_DESC DESCPD,   SRV.RV_TIPOCOD TIPOCOD, 	SRV.RV_TIPO TIPOPD, SQB.QB_DESCRIC
					    %exp:cAdicSRD%
				FROM %table:SRA% SRA    
				
				INNER JOIN %table:SRD% SRD 
					//ON SRA.RA_FILIAL = SRD.RD_FILIAL AND SRA.RA_MAT = SRD.RD_MAT
					ON %exp:cJoinSRD% SRA.RA_MAT = SRD.RD_MAT
								
				%exp:cJoinD%																															

				INNER JOIN %table:SRV% SRV
					//ON SRV.RV_FILIAL = %exp:cFilPd%	AND SRV.RV_COD = SRD.RD_PD
					ON SRV.RV_COD = SRD.RD_PD
					
				%exp:cJoinSQB%									
					
				LEFT JOIN %table:RGC% RGC
					ON RGC.RGC_KEYLOC = SRA.RA_KEYLOC AND RGC.D_E_L_E_T_ = ' '

				%exp:cJoinRGC%
												
				WHERE	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND
				   		SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND
				   		SRD.RD_PROCES  =   %exp:Upper(cProcesso)%  AND
				   		SRD.RD_PERIODO =   %exp:Upper(cPeriodo)%   AND  
				   		SRD.RD_ROTEIR  =   %exp:Upper(cRot)%   AND
				   		SRD.RD_SEMANA  =   %exp:Upper(cPagamento)% AND
				   		SQB.%notDel% AND
						SRA.%notDel% AND
						%exp:cValidFil% AND
				   		%exp:cFiltroD% 
						SRD.%notDel% AND
						%exp:cFiltroPDB% AND 
						SRV.%notDel% 
						%exp:cNotDel%

				ORDER BY %exp:cOrdem%
							 
			EndSql   
				
		Case nOrdem == 11 .Or. nOrdem == 12 //Registro Patronal
		
			BeginSql alias cAliasQry
			
				SELECT SRA.RA_FILIAL,       SRA.RA_MAT,         	SRA.RA_CC,              SRA.RA_NOME,           
					SRA.RA_DEPTO,           SRA.RA_HRSMES,      	SRA.RA_SALARIO,         SRA.RA_SITFOLH,
					SRA.RA_CODRPAT,     	SRC.RC_FILIAL FILIAL,	SRC.RC_MAT MAT, 		SRC.RC_FILIAL,      
					SRC.RC_CC CCUSTO,       SRC.RC_PD PXD,       	SRC.RC_TIPO1 TIPO1,     SRC.RC_QTDSEM QTDSEM, 
					SRC.RC_HORINFO HORINFO, SRC.RC_HORAS HORAS, 	SRC.RC_VALINFO VALINFO, SRC.RC_VALOR VALOR,   
					SRC.RC_VNAOAPL VNAOAPL, SRC.RC_DATA DATPGT, 	SRC.RC_DTREF DTREF,     SRC.RC_SEMANA SEMANA, 
					SRC.RC_PARCELA PARCELA, SRC.RC_TIPO2 TIPO2, 	SRC.RC_SEQ SEQ,         SRC.RC_PROCES PROCES, 
					SRC.RC_PERIODO PERIODO, SRC.RC_POSTO POSTO, 	SRC.RC_NUMID NUMID,     SRC.RC_ROTEIR ROTEIR,  
					SRV.RV_COD CODPD,       SRV.RV_DESC DESCPD, 	SRV.RV_TIPOCOD TIPOCOD, SRV.RV_TIPO TIPOPD, SQB.QB_DESCRIC	
					%exp:cAdicSRC%
				FROM %table:SRA% SRA    

				INNER JOIN %table:SRC% SRC				 
					//ON SRA.RA_FILIAL = SRC.RC_FILIAL AND SRA.RA_MAT = SRC.RC_MAT
					ON %exp:cJoinSRC% SRA.RA_MAT = SRC.RC_MAT
					
				%exp:cJoinC%					

				INNER JOIN %table:SRV% SRV
					//ON SRV.RV_FILIAL = %exp:cFilPd%	AND SRV.RV_COD = SRC.RC_PD
					ON SRV.RV_COD = SRC.RC_PD					
					
				%exp:cJoinSQB%					
									
				WHERE	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND
				   		SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND
				   		SRC.RC_PROCES  =   %exp:Upper(cProcesso)%  AND
				   		SRC.RC_PERIODO =   %exp:Upper(cPeriodo)%   AND  
				   		SRC.RC_ROTEIR  =   %exp:Upper(cRot)%   AND
				   		SRC.RC_SEMANA  =   %exp:Upper(cPagamento)% AND
				   		SQB.%notDel% AND
						SRA.%notDel% AND
						%exp:cValidFil% AND
				   		%exp:cFiltroC% 
						SRC.%notDel% AND
						%exp:cFiltroPDB% AND 
						SRV.%notDel% 
						%exp:cNotDel%
				UNION
		
				SELECT SRA.RA_FILIAL,           SRA.RA_MAT,           	SRA.RA_CC,              SRA.RA_NOME,
						SRA.RA_DEPTO,           SRA.RA_HRSMES,        	SRA.RA_SALARIO,         SRA.RA_SITFOLH,
						SRA.RA_CODRPAT,       	SRD.RD_FILIAL FILIAL,	SRD.RD_MAT MAT, 		SRD.RD_FILIAL,       
						SRD.RD_CC CCUSTO,       SRD.RD_PD PXD,        	SRD.RD_TIPO1 TIPO1,     SRD.RD_QTDSEM QTDSEM, 
						SRD.RD_HORINFO HORINFO, SRD.RD_HORAS HORAS,   	SRD.RD_VALINFO VALINFO, SRD.RD_VALOR VALOR,   
						SRD.RD_VNAOAPL VNAOAPL, SRD.RD_DATPGT DATPGT, 	SRD.RD_DTREF DTREF,     SRD.RD_SEMANA SEMANA, 
						0 PARCELA,              SRD.RD_TIPO2 TIPO2,   	SRD.RD_SEQ SEQ,         SRD.RD_PROCES PROCES, 
						SRD.RD_PERIODO PERIODO, SRD.RD_POSTO POSTO,   	SRD.RD_NUMID NUMID,     SRD.RD_ROTEIR ROTEIR,  
						SRV.RV_COD CODPD,       SRV.RV_DESC DESCPD,   	SRV.RV_TIPOCOD TIPOCOD, SRV.RV_TIPO TIPOPD, SQB.QB_DESCRIC
					    %exp:cAdicSRD%
				FROM %table:SRA% SRA
				    
				INNER JOIN      %table:SRD% SRD
					//ON SRA.RA_FILIAL = SRD.RD_FILIAL AND SRA.RA_MAT = SRD.RD_MAT
					ON %exp:cJoinSRD% SRA.RA_MAT = SRD.RD_MAT

				%exp:cJoinD%
							
				INNER JOIN %table:SRV% SRV
					//ON SRV.RV_FILIAL = %exp:cFilPd%	AND SRV.RV_COD = SRD.RD_PD
					ON SRV.RV_COD = SRD.RD_PD
					
				%exp:cJoinSQB%
									
				WHERE	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND
				   		SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND
				   		SRD.RD_PROCES  =   %exp:Upper(cProcesso)%  AND
				   		SRD.RD_PERIODO =   %exp:Upper(cPeriodo)%   AND  
				   		SRD.RD_ROTEIR  =   %exp:Upper(cRot)%   AND
				   		SRD.RD_SEMANA  =   %exp:Upper(cPagamento)% AND
				   		SQB.%notDel% AND
				   		SRA.%notDel% AND
				   		%exp:cValidFil% AND
				   		%exp:cFiltroD% 
						SRD.%notDel% AND
						%exp:cFiltroPDB% AND 
						SRV.%notDel% 
						%exp:cNotDel%
			
				
				ORDER BY %exp:cOrdem%
				
			EndSql
			
		Otherwise
		
			BeginSql alias cAliasQry
			
				SELECT SRA.RA_FILIAL,       SRA.RA_MAT,         SRA.RA_CC,              SRA.RA_NOME,           
					SRA.RA_DEPTO,           SRA.RA_HRSMES,      SRA.RA_SALARIO,         SRA.RA_SITFOLH,
					SRC.RC_MAT MAT, 		SRC.RC_CC CCUSTO,   SRC.RC_PD PXD,      	SRC.RC_TIPO1 TIPO1,     
					SRC.RC_HORINFO HORINFO, SRC.RC_HORAS HORAS, SRC.RC_VALINFO VALINFO, SRC.RC_VALOR VALOR,   
					SRC.RC_VNAOAPL VNAOAPL, SRC.RC_DATA DATPGT, SRC.RC_DTREF DTREF,     SRC.RC_SEMANA SEMANA, 
					SRC.RC_PARCELA PARCELA, SRC.RC_TIPO2 TIPO2, SRC.RC_SEQ SEQ,         SRC.RC_PROCES PROCES, 
					SRC.RC_PERIODO PERIODO, SRC.RC_POSTO POSTO, SRC.RC_NUMID NUMID,     SRC.RC_ROTEIR ROTEIR,  
					SRV.RV_COD CODPD,       SRV.RV_DESC DESCPD, SRV.RV_TIPOCOD TIPOCOD, SRV.RV_TIPO TIPOPD,
					SRC.RC_QTDSEM QTDSEM,	SRC.RC_CONVOC
					%exp:cAdicSRC%					
				FROM %table:SRA% SRA
				    
				INNER JOIN %table:SRC% SRC 
					ON %exp:cJoinSRC% SRA.RA_MAT = SRC.RC_MAT

				%exp:cJoinC%
				
				INNER JOIN %table:SRV% SRV
					ON %exp:cFilPdSRC%
									
				WHERE	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND
				   		SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND
				   		SRC.RC_PROCES  =   %exp:Upper(cProcesso)%  AND
				   		SRC.RC_PERIODO =   %exp:Upper(cPeriodo)%   AND  
				   		SRC.RC_ROTEIR  =   %exp:Upper(cRot)%   AND
				   		SRC.RC_SEMANA  =   %exp:Upper(cPagamento)% AND
						SRA.%notDel% AND
						%exp:cValidFil% AND 
				   		%exp:cFiltroC% 
						SRC.%notDel% AND
						%exp:cFiltroPDB% AND 
						SRV.%notDel% 
						%exp:cNotDel%
				UNION
		
				SELECT SRA.RA_FILIAL,      SRA.RA_MAT,         	SRA.RA_CC,              SRA.RA_NOME,           
					SRA.RA_DEPTO,           SRA.RA_HRSMES,      	SRA.RA_SALARIO,         SRA.RA_SITFOLH,
					SRD.RD_MAT MAT, 		SRD.RD_CC CCUSTO,   	SRD.RD_PD PXD,      	SRD.RD_TIPO1 TIPO1,     
					SRD.RD_HORINFO HORINFO, SRD.RD_HORAS HORAS, 	SRD.RD_VALINFO VALINFO, SRD.RD_VALOR VALOR,   
					SRD.RD_VNAOAPL VNAOAPL, SRD.RD_DATPGT DATPGT, 	SRD.RD_DTREF DTREF,     SRD.RD_SEMANA SEMANA, 
					0 PARCELA, 				SRD.RD_TIPO2 TIPO2, 	SRD.RD_SEQ SEQ,         SRD.RD_PROCES PROCES, 
					SRD.RD_PERIODO PERIODO, SRD.RD_POSTO POSTO, 	SRD.RD_NUMID NUMID,     SRD.RD_ROTEIR ROTEIR,  
					SRV.RV_COD CODPD,       SRV.RV_DESC DESCPD, 	SRV.RV_TIPOCOD TIPOCOD, SRV.RV_TIPO TIPOPD,
					SRD.RD_QTDSEM QTDSEM , SRD.RD_CONVOC 
					%exp:cAdicSRD%					
				FROM %table:SRA% SRA    

				INNER JOIN %table:SRD% SRD 
					ON %exp:cJoinSRD% SRA.RA_MAT = SRD.RD_MAT

				%exp:cJoinD%					

				INNER JOIN %table:SRV% SRV
					ON %exp:cFilPdSRD%
																
				WHERE	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND
				   		SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND
				   		SRD.RD_PROCES  =   %exp:Upper(cProcesso)%  AND
				   		SRD.RD_PERIODO =   %exp:Upper(cPeriodo)%   AND  
				   		SRD.RD_ROTEIR  =   %exp:Upper(cRot)%   AND
				   		SRD.RD_SEMANA  =   %exp:Upper(cPagamento)% AND
						SRA.%notDel% AND
						%exp:cValidFil% AND
				   		%exp:cFiltroD% 
						SRD.%notDel% AND
						%exp:cFiltroPDB% AND 
						SRV.%notDel% 
						%exp:cNotDel%
						
				ORDER BY %exp:cOrdem%
			 
			EndSql
	Endcase
	
	If nOrdem == 1 .Or. nOrdem == 2
		END REPORT QUERY oSectFunc
		
	ElseIf nOrdem == 3 .Or. nOrdem == 4	
		END REPORT QUERY oSectCCus		
		//-- C.Custo x Matrícula
		oSectFunc:SetParentQuery()
		oSectFunc:SetParentFilter({|cParam|(cAliasQry)->RA_FILIAL+(cAliasQry)->CCUSTO==cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->CTT_CUSTO})
	
	ElseIf nOrdem == 5 .Or. nOrdem == 6
	
		END REPORT QUERY oSectDept
		//-- Depto x Matrícula
		oSectFunc:SetParentQuery()		
		oSectFunc:SetParentFilter({|cParam|(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_DEPTO==cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->QB_DEPTO})

	ElseIf nOrdem == 7 .Or. nOrdem == 8
	
		END REPORT QUERY oSectCCus
		//-- C.Custo x Depto
		oSectDept:SetParentQuery()    
		oSectDept:SetParentFilter({|cParam|(cAliasQry)->RA_FILIAL+(cAliasQry)->CCUSTO==cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->CTT_CUSTO})
		//-- Depto x Matrícula
		oSectFunc:SetParentQuery()		
		oSectFunc:SetParentFilter({|cParam|(cAliasQry)->RA_FILIAL+(cAliasQry)->CCUSTO+(cAliasQry)->RA_DEPTO==cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->CTT_CUSTO+(cAliasQry)->QB_DEPTO})

	ElseIf nOrdem == 9 .Or. nOrdem == 10
	
		END REPORT QUERY oSectLocp
		//-- Loc.Pago x Matrícula
		oSectFunc:SetParentQuery()		
		oSectFunc:SetParentFilter({|cParam|(cAliasQry)->RA_KEYLOC==cParam},{||(cAliasQry)->RGC_KEYLOC})
	
	ElseIf nOrdem == 11 .Or. nOrdem == 12
	
		END REPORT QUERY oSectRPat
		//-- Reg.Patronal x Matrícula
		oSectFunc:SetParentQuery()		
		oSectFunc:SetParentFilter({|cParam|(cAliasQry)->RA_CODRPAT==cParam},{||(cAliasQry)->RCO_CODIGO})
	
	ElseIf nOrdem == 13
		END REPORT QUERY oSectVerb
		//-- Verba x Lançamentos
		oSectLanc:SetParentQuery()			 
		oSectLanc:SetParentFilter({|cParam|(cAliasQry)->RA_FILIAL+(cAliasQry)->PXD==cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->PXD})	
	EndIf
	
	If nOrdem != 13
		oSectLanc:SetParentQuery()		
		//-- Matrícula x Lançamentos
		oSectLanc:SetParentFilter({|cParam|(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT==cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT})
	Endif	
	
Else	//Sintetico                
	
	BeginSql alias cAliasQry

		SELECT 	SUM(SRA.RA_SALARIO) SALARIO, SRC.RC_PD PXD,        	SUM(SRC.RC_HORAS) HORAS, 
				SUM(SRC.RC_VALOR) VALOR,     SRC.RC_PROCES PROCES, 	SRC.RC_PERIODO PERIODO,  
				SRC.RC_ROTEIR ROTEIR,        SRA.RA_FILIAL,
				SRV.RV_TIPOCOD TIPOCOD,      SRV.RV_TIPO TIPOPD,   	SRV.RV_DESC DESCPD
				%exp:cCpoAdic%
													
		FROM  %table:SRA% SRA	
				
			INNER JOIN %table:SRC% SRC 
				ON %exp:cJoinSRC% SRA.RA_MAT = SRC.RC_MAT
				
				%exp:cJoinC%									
						
			INNER JOIN %table:SRV% SRV
				ON %exp:cFilPdSRC%
				AND SRV.%notDel% 
		WHERE 	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND 
				SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND 
				SRC.RC_PROCES  =   %exp:Upper(cProcesso)%  AND 
				SRC.RC_ROTEIR  =   %exp:Upper(cRot)%   AND 
				SRC.RC_PERIODO =   %exp:Upper(cPeriodo)%   AND 
				SRC.RC_SEMANA =    %exp:Upper(cPagamento)% AND
				SRA.%notDel% AND 
				%exp:cValidFil% AND
				%exp:cFiltroC%  
				SRC.%notDel% AND
				%exp:cFiltroPDB%
		GROUP BY RC_PROCES, RC_PERIODO, RC_ROTEIR, RA_FILIAL, RC_PD,
				RV_TIPOCOD, RV_TIPO, RV_DESC
				%exp:cCpoAdic%
		UNION			
		SELECT SUM(SRA.RA_SALARIO) SALARIO, SRD.RD_PD PXD,        	SUM(SRD.RD_HORAS) HORAS, 
				SUM(SRD.RD_VALOR) VALOR,     SRD.RD_PROCES PROCES, 	SRD.RD_PERIODO PERIODO,  
				SRD.RD_ROTEIR ROTEIR,        SRA.RA_FILIAL,
				SRV.RV_TIPOCOD TIPOCOD,      SRV.RV_TIPO TIPOPD,   	SRV.RV_DESC DESCPD
				%exp:cCpoAdic%									
				
		FROM  %table:SRA% SRA	
				
			INNER JOIN %table:SRD% SRD
				ON %exp:cJoinSRD% SRA.RA_MAT = SRD.RD_MAT				
				%exp:cJoinD%					
				AND SRD.%notDel%
			INNER JOIN %table:SRV% SRV
				ON %exp:cFilPdSRD%
				AND SRV.%notDel%
		WHERE 	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND 
				SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND 
				SRD.RD_PROCES  =   %exp:Upper(cProcesso)%  AND 
				SRD.RD_PERIODO =   %exp:Upper(cPeriodo)%   AND 
				SRD.RD_ROTEIR  =   %exp:Upper(cRot)%   AND 
				SRD.RD_SEMANA =    %exp:Upper(cPagamento)% AND
				SRA.%notDel% AND
				%exp:cValidFil% AND
				%exp:cFiltroD%  
				SRD.%notDel% AND
				%exp:cFiltroPDB%
		GROUP BY RD_PROCES, RD_PERIODO, RD_ROTEIR, RA_FILIAL, RD_PD, 
				RV_TIPOCOD, RV_TIPO, RV_DESC
				%exp:cCpoAdic%
				

		ORDER BY %exp:cCpoDelim%, PXD
		 	
	EndSql	
		
	oSectLanc:SetParentQuery()	

	If nOrdem == 1 .Or. nOrdem == 2			//Mat. / Nome
		END REPORT QUERY oSectFunc
		//-- Filial x Lançamentos		
		oSectLanc:SetParentFilter({ |cParam|(cAliasQry)->RA_FILIAL == cParam }, {||(cAliasQry)->RA_FILIAL })		
		
	ElseIf nOrdem == 3 .Or. nOrdem == 4		//C.Custo 
		END REPORT QUERY oSectCCus
		oSectLanc:SetParentFilter({ |cParam|(cAliasQry)->RA_FILIAL+(cAliasQry)->CTT_CUSTO == cParam }, {||(cAliasQry)->RA_FILIAL+(cAliasQry)->CTT_CUSTO })				
				
	ElseIf nOrdem == 5 .Or. nOrdem == 6    //Depto
		END REPORT QUERY oSectDept
		oSectLanc:SetParentFilter({ |cParam|(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_DEPTO == cParam }, {||(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_DEPTO })				
		
	ElseIf nOrdem == 7 .Or. nOrdem == 8		//C.Custo + Depto
		END REPORT QUERY oSectCCus
		/*
			Obs: No caso desta ordenacao, a Section oSectDept esta sendo
			usada como section de Centro de Custo (1o nivel).
			A Section oSectFunc esta sendo usada como section de Departamento (2o nivel).
			E a Section de Lancamentos das verbas oSectLanc e o 3o nivel.
		*/
		//C.Custo x Depto		
		oSectFunc:SetParentQuery()
		oSectFunc:SetParentFilter({|cParam|(cAliasQry)->RA_FILIAL+(cAliasQry)->CTT_CUSTO==cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->CTT_CUSTO})
		//Depto x Lanc.
		oSectLanc:SetParentFilter({|cParam|(cAliasQry)->RA_FILIAL+(cAliasQry)->CTT_CUSTO+(cAliasQry)->QB_DEPTO == cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->CTT_CUSTO+(cAliasQry)->QB_DEPTO})
	ElseIf nOrdem == 9 .Or. nOrdem == 10
		END REPORT QUERY oSectLocp
		
	ElseIf nOrdem == 11 .Or. nOrdem == 12
		END REPORT QUERY oSectRPat
		
	ElseIf nOrdem == 13
		END REPORT QUERY oSectVerb
		oSectLanc:SetParentFilter({ |cParam|(cAliasQry)->RA_FILIAL+(cAliasQry)->PXD == cParam }, {||(cAliasQry)->RA_FILIAL+(cAliasQry)->PXD })						
	EndIf
   
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Esta função busca todos os periodos em aberto e fechado dos funcionarios.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RetPerAbertFech(cProcesso, cRot, cPeriodo, cPagamento, , , @aPerAberto, @aPerFechado, , Space(FwGetTamFilial), Replicate("z", FwGetTamFilial))

If Empty(aPerAberto) .And. Empty(aPerFechado)
   MsgAlert(STR0032,STR0033)	//"Nao foi encontrado nenhum periodo" ### "Falta parametro"
   Return
Endif

oReport:SetMeter(LastRec())  
//oReport:OnPageBreak({|| oSectionh:Init(), oSectionh:PrintLine(), oSectionh:Finish(), oReport:ThinLine() })
oReport:OnPageBreak({||fGR102Header(oReport)})

//-- Altera o titulo do relatorio
oReport:SetTitle(cTitulo)

If nOrdem == 1 .Or. nOrdem == 2
	oSectFunc:Print()
	
ElseIf nOrdem == 3 .Or. nOrdem == 4
	 
	If nSinAna	== 1	//Analítico
		oSectCCus:OnPrintLine({||oReport:SkipLine()})
		oSectCCus:Print()
	Else				//Sintético
		oSectFunc:OnPrintLine({||oReport:SkipLine()})
		oSectFunc:Print()
	EndIf
	
ElseIf nOrdem == 5 .Or. nOrdem == 6  
	If nSinAna	== 1	//Analítico
		oSectDept:OnPrintLine({||oReport:SkipLine()})
		oSectDept:Print()
	Else				//Sintético
		oSectFunc:OnPrintLine({||oReport:SkipLine()})
		oSectFunc:Print()
	EndIf
	
ElseIf nOrdem == 7 .Or. nOrdem == 8 
	If nSinAna	== 1	//Analítico
		oSectCCus:OnPrintLine({||oReport:SkipLine()})
		oSectCCus:Print()
	Else				//Sintético
		oSectDept:OnPrintLine({||oReport:SkipLine()})
		oSectDept:Print()
	EndIf
	
ElseIf nOrdem == 9 .Or. nOrdem == 10
	If nSinAna	== 1	//Analítico
		oSectLocp:OnPrintLine({||oReport:SkipLine()})
		oSectLocp:Print()
	Else				//Sintético
		oSectFunc:OnPrintLine({||oReport:SkipLine()})
		oSectFunc:Print()
	EndIf
	
ElseIf nOrdem == 11 .Or. nOrdem == 12  
	If nSinAna	== 1	//Analítico
		oSectRPat:OnPrintLine({||oReport:SkipLine()})
		oSectRPat:Print()
	Else				//Sintético
		oSectFunc:OnPrintLine({||oReport:SkipLine()})
		oSectFunc:Print()
	EndIf
	
ElseIf nOrdem == 13
	oSectVerb:Print()	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ fQueryVisao   ³ Autor ³ Tania Bronzeri        ³ Data ³17/03/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Pesquisa Visao / Departamento para a Arquitetura Organizacional.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER102                                                         ³±±
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
	cQuery += "AND RD4.D_E_L_E_T_ = ' ' AND RDK.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQryAlias,.T.,.T.)
	
	aChave[1]	:= (cQryAlias)->RD4_FILIDE
	aChave[2]	:= (cQryAlias)->RD4_CHAVE
	
	(cQryAlias)->(DbCloseArea())
	
	RestArea( aArea )
	
Return aChave

/************************************************************************************/
Static Function fGR102Header(oReport)
	Local cDescProc := ""

	cDescProc := EVAL({||Substr(PosAlias("RCJ",cProcesso,xFilial("RCJ"),"RCJ_DESCRI"),1,20)}) 

	oReport:SkipLine()
	oReport:PrintText(OemToAnsi(STR0014) + ': ' + cProcesso + ' - ' + cDescProc + space(05) + OemToAnsi(STR0015) + ': ' + cPeriodo;
		+ space(05) + OemToAnsi(STR0016) + ': ' + cPagamento + space(05) + OemToAnsi(STR0017) + ': ' + cRot, ;
		/*nRow*/,/*nCol*/,/*nClrText*/,/*cStyle*/,/*nCells*/,.F.) //"Processo"##"Período"##"Pagamento"##"Roteiro"
	oReport:ThinLine()
	oReport:SkipLine()
Return
