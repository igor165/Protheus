#Include 'Protheus.ch'
#include "APWIZARD.CH"
#include "FINA377A.CH"

Static nTamCli 		:= TAMSX3("A1_COD")[1]
Static nTamLoj 		:= TAMSX3("A1_LOJA")[1]
Static nTamTit		:= TamSx3("E1_NUM")[1]
Static nTamParc  	:= TamSx3("E1_PARCELA")[1]
Static nTamVal		:= TamSx3("FKG_VALOR")[1]
Static nDescVal		:= TamSx3("FKG_VALOR")[2]
Static nTamBas		:= TamSx3("E1_BASEINS")[1]
Static nDescBas		:= TamSx3("E1_BASEINS")[2]
Static nTamINS		:= TamSx3("E1_INSS")[1]
Static nDescINS		:= TamSx3("E1_INSS")[2] 
Static __lDefTop	:= IfDefTopCTB()
Static cMascBase	:= PesqPict("SE1","E1_BASEINS",nTamBas,nDescBas)
Static cMascINS		:= PesqPict("SE1","E1_INSS",nTamINS,nDescINS)
Static cMascVal		:= PesqPict("FKG","FKG_VALOR",nTamVal,nDescVal)

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA377A
Wizard de processamento de títulos com abatimento de INSS com processos 
Judiciais

@author Pâmela Bernardo	
@since 01/06/2017	
@version 11.80
/*/
//-------------------------------------------------------------------

Function FINA377A()
Local oWizard 	:= Nil
Local aArea		:= GetArea()
Local oBold
Local aFils 	:= {}
Local oFil 		:= Nil		//Objeto Filiais
Local lGestao   := FWSizeFilial() > 2	// Indica se usa Gestao Corporativa
Local oOk		:= Nil		//Botão OK				
Local oNo		:= Nil		//Botão No
Local aFiliais 	:= {}
Local cSA1Emp	:= FWModeAccess("SA1",1)
Local cSA1UNe	:= FWModeAccess("SA1",2)
Local lSA1Emp 	:= cSA1Emp == "E" // Define se admgetfil vai trazer filtro por empresa
Local lSA1Une 	:= cSA1UNe == "E" // Define se admgetfil vai trazer filtro por unidade de negócio



//Perguntas do wizard 2
Private aPerWiz2 	:= {} 
Private aResWiz2	:= {}
//Perguntas do wizard 3
Private aHeader3 	:= ARRAY(5) 
Private aCols3		:= {}
Private cAliasSe1	:= ""
Private aRecnoFKG 	:= {}
//Perguntas do wizard 4
Private aHeader4 	:= ARRAY(6) 
Private aCols4		:= {}
PRIVATE lMsErroAuto := .F.
Private aSimNao		:= {STR0036, STR0037}//"Sim"##"Não"
Private aDataEmi 	:= {STR0032, STR0033,STR0034, STR0035}//"Emissão Sistema"##"Emissão Titulo"##"Vencto Real"##"Vencimento"

PRIVATE  oTit 		:= Nil		//Titulos gerados
PRIVATE  oCli 		:= Nil		//Clientes apurados

//---------------------------------------------
//Verifica ambiente
//---------------------------------------------
If !__lDefTop
	Alert(STR0001)//'Rotina disponível somemente para ambiente TOPCONNECT'
	Return
EndIf

If !AliasinDic("FKF")
	Alert(STR0002)//'Ambiente sem a atualização do REINF. Necessário rodar o update "UPDREINF"!'
	Return
EndIf

If CCF->(FieldPos("CCF_UF")) == 0
	Alert(STR0003)//'Ambiente sem a atualização do FISCAL. Necessário rodar o update "UPDSIGAFIS"!'
	Return
EndIf

//---------------------------------------------
//Carrega todas as filiais existentes
//---------------------------------------------
aHeader	:= ARRAY(4)
aHeader[1]	:= ""  		
aHeader[2]	:= IIF(!lGestao,STR0004,STR0005)//"Filial" ##"Empresa/Unidade/Filial"
aHeader[3]	:= STR0006// "Razão Social"
aHeader[4]	:= STR0007//"CNPJ"
aFiliais	:= AdmGetFil(.F.,lSA1Emp,"SE1", lSA1Une, .T.,.F.)
aEval(aFiliais, {|x| aAdd(aFils, {.F., x[1],x[2],x[3] } ) })

//---------------------------------------------
//Carrega dados iniciais de Clientes selecionados
//---------------------------------------------
aHeader3[1]	:= STR0008 //"Cliente/Loja" 	
aHeader3[2]	:= STR0009 //"Nome"
aHeader3[3]	:= STR0010 //"Valor Base"
aHeader3[4]	:= STR0012 //"Inss Abatido"
aHeader3[5]	:= STR0013 //"Inss a Abater"

AADD(aCols3, {STR0008,STR0009,0,0,0} )

//---------------------------------------------
//Carrega dados iniciais de títulos gerados
//---------------------------------------------
aHeader4[1]	:= STR0008 //"Cliente/Loja" 		
aHeader4[2]	:= STR0009 //"Nome"
aHeader4[3]	:= STR0014 //"Tipo"
aHeader4[4]	:= STR0015 //"Natureza"
aHeader4[5]	:= STR0016 //"Descrição"
aHeader4[6]	:= STR0017 //"Valor"


AADD(aCols4, {STR0008,STR0009,STR0014,STR0015,STR0016,0} )

//---------------------------------------------
//Carrega imagens dos botoes
//---------------------------------------------
oOk 		:= LoadBitmap( GetResources(), "LBOK")
oNo			:= LoadBitmap( GetResources(), "LBNO")
//---------------------------------------------
//³ Montagem da Wizard                      
//---------------------------------------------
DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
/*"Acerto de INSS Contas a Receber "*/
/*"Ajustar os valores do INSS abatido no contas a receber com processo judicial"*/
/* "Parâmetros Iniciais..." */
/*"O objetivo desta rotina será: Gerar título um receber por cliente, em que os valores de INSS tiveram cálculo diferenciado devido a amarração com causas judicias, caso haja perda de causa."*/
DEFINE WIZARD oWizard TITLE STR0018;
       HEADER STR0019 ;
       MESSAGE STR0020	 ;
       TEXT STR0021;
       NEXT {||.T.} ;
       FINISH {|| .F. } ;
       PANEL

//Wizard 1 - Seleção de Filiais
/*"Seleção de Filiais"*/
/*"Marque as filiais que serão consideradas para seleção de título"*/ 
CREATE PANEL oWizard ;
		HEADER STR0022; 
		MESSAGE STR0023;
		BACK {|| .T. } ;
		NEXT {|| ValidaFil(aFils) } ;
		PANEL
		
		oFil := TWBrowse():New( 0.5, 0.5 , 280, 100,Nil,aHeader, Nil, oWizard:GetPanel(2), Nil, Nil, Nil,Nil,;
					      {|| oFil:Refresh() })      

		oFil:SetArray( aFils )

		oFil:bHeaderClick := {|oFil,nCol| If( nCol==1, fMarkAll(@aFils),Nil), oFil:Refresh()}

		oFil:bLine := {|| {;
					If( aFils[oFil:nAt,1] , oOk , oNo ),;
						aFils[oFil:nAt,2],;
						aFils[oFil:nAt,3],;
						aFils[oFil:nAt,4];
					}}
		oFil:bLDblClick := {|| aFils[oFil:nAt][1] := !aFils[oFil:nAt][1],oFil:DrawSelect()} 


//Wizard 2 - Seleção de títulos a Receber 
/*"Parâmetros de Seleção"*/
/*"Defina critérios para seleção dos clientes/títulos"*/
CREATE PANEL oWizard ;
		HEADER STR0024; 
		MESSAGE STR0025; 
		BACK {|| .T. } ;
		NEXT {|| F377MP3(aFils) } ;
		PANEL

		//Define os Paremtros
		F377ParSel()
			
		ParamBox(aPerWiz2,STR0026,@aResWiz2,,,,,,oWizard:GetPanel(3))//"Parâmetros..."

//Wizard 3 - Mostrar resultado da apuração
/*"Clientes Selecionados"*/
/*"Valores apurados por clientes"*/
CREATE PANEL oWizard ;
		HEADER STR0027; 
		MESSAGE STR0028; 
		BACK {|| .T. } ;
		NEXT {||  F377MP4() } ;
		PANEL
		

		oCli := TWBrowse():New( 0.5, 0.5 , 280, 100,Nil,aHeader3, Nil, oWizard:GetPanel(4), Nil, Nil, Nil,Nil,;
					      {|| oTit:Refresh() })      

		oCli:SetArray(aCols3)

		oCli:bLine := {|| {aCols3[oCli:nAt,1],;
						aCols3[oCli:nAt,2],;
						Transform( aCols3[oCli:nAt,3], cMascBase),;
						Transform( aCols3[oCli:nAt,4], cMascINS ),;
						Transform( aCols3[oCli:nAt,5], cMascVal );
					}}

					
//Wizard 4 - Títulos que serão gerados
//"Títulos Gerados"; 
//"Lista de títulos que serão gerados"; 
CREATE PANEL oWizard ;
		HEADER STR0029 ; 
		MESSAGE STR0030 ; 
		BACK {|| .T. } ;
		FINISH {|| F377MP5() } ;
		PANEL
		

		oTit := TWBrowse():New( 0.5, 0.5 , 280, 100,Nil,aHeader4, Nil, oWizard:GetPanel(5), Nil, Nil, Nil,Nil,;
					      {|| oTit:Refresh() })      

		oTit:SetArray(aCols4)

		oTit:bLine := {|| {aCols4[oTit:nAt,1],;
						aCols4[oTit:nAt,2],;
						aCols4[oTit:nAt,3],;
						aCols4[oTit:nAt,4],;
						aCols4[oTit:nAt,5],;
						Transform(aCols4[oTit:nAt,6], cMascVal );
					}}
	
ACTIVATE WIZARD oWizard CENTERED

RestArea( aArea )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidaFil 
Valida na tela do Wizard se selecionou pelo menos uma filial

@param aFils Array com as filiais para seleção
@return Retorna .T. se selecionou pelo menos uma filial 

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------

Static Function ValidaFil(aFils)
Local lRet := .F.
Local nI := 1
For nI := 1 to Len( aFils )
	IF aFils[nI][1]
		lRet := .T.
		Exit
	Endif
Next
If !lRet
	Help(" ",1,"ADMFILIAL",,STR0031,1,0)//"Por favor selecione uma filial"	
EndIf 
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F377ParSel 
Define os arrays dos perguntes e respostas do wizard

@author Pâmela Bernardo
@since 02/06/2017
@version P11.80
/*/
//-------------------------------------------------------------------
Static Function F377ParSel()
	
	//Cria Perguntas
	aAdd(aPerWiz2 ,{1,STR0038		,Space(nTamCli)    	,"@!"		,"","CLI"	,,60,.F.})	//"Cliente de"
	aAdd(aPerWiz2 ,{1,STR0039		,Space(nTamCli)		,"@!"		,"","CLI"	,,60,.F.})	//"Cliente até"	
	aAdd(aPerWiz2 ,{1,STR0040		,Space(nTamLoj)    	,"@!"		,"",		,,10,.F.})	//"Loja de"
	aAdd(aPerWiz2 ,{1,STR0041		,Space(nTamLoj)		,"@!"		,"",		,,10,.F.})	//"Loja até"	
	aAdd(aPerWiz2 ,{2,STR0042		,1					,aDataEmi	,70,"",.F.})	//"Considera Data"
	aAdd(aPerWiz2 ,{1,STR0043		,CTOD("  /  /    ")	,""			,"",""	,,60,.F.})	//"Data de"	
	aAdd(aPerWiz2 ,{1,STR0044		,CTOD("  /  /    ")	,""			,"",""	,,60,.F.})	//"Data até"	
	aAdd(aPerWiz2 ,{2,STR0045		,1					,aSimNao	,60,"",.F.})	//"Imprime Relatório"
	
	//Seta a resposta padrão
	aResWiz2	:= Array(Len(aPerWiz2))
	aResWiz2[1]	:= Space(nTamCli)						//Cliente de
	aResWiz2[2]	:= REPLICATE('Z',nTamCli)				//Cliente Ate
	aResWiz2[3]	:= Space(nTamLoj)						//Loja de
	aResWiz2[4]	:= REPLICATE('Z',nTamLoj)				//Loja até
	aResWiz2[5]	:= aSimNao[1]									//Considera Data
	aResWiz2[6]	:= FirstDay( FirstDay( dDataBase ))//Data de					
	aResWiz2[7]	:= LastDay( FirstDay( dDataBase ))	//Data até
	aResWiz2[8] := aDataEmi[1]								//Imprime Relatório			


Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} F377ProcTit 
Define os arrays dos perguntes e respostas do wizard
@param aFils Array com as filiais selecionadas

@author Pâmela Bernardo
@since 02/06/2017
@version P11.80
/*/
//-------------------------------------------------------------------
Static Function F377ProcTit(aFils)
	Local cQuery := ""
	Local cCampos:= ""
	Local aSelFil:= {}
	Local cTmpFil:= ""
	Local nPos	 := 0
	Local cQryIn := ""
	Local nPosRec:= 0
	Local nTamCCF:= Len(Alltrim(xFilial("CCF")))
	
	F377Selfil(aFils, aSelFil)
	
	aCols3 := {}
	aRecnoFKG := {}
	cAliasSe1	:= GetNextAlias()
	
	cCampos:= " FKG.R_E_C_N_O_ FKGRECNO, SE1.E1_FILIAL, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, "
	cCampos+= "SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_NOMCLI, SE1.E1_EMISSAO, "
	cCampos+= "SE1.E1_VENCTO, SE1.E1_VENCREA, SE1.E1_BASEINS, SE1.E1_INSS, "
	cCampos+= "FKG.FKG_VALOR, FKG.FKG_DEDACR, SE1.R_E_C_N_O_ SE1RECNO "

	cQryIn := GetRngFil(aSelFil, "SE1", .T., @cTmpFil) 
	
	cQuery := "SELECT Distinct " + cCampos +"From"
	cQuery += RetSqlName("SE1") + " SE1, "
	cQuery += RetSqlName("FK7") + " FK7, "
	cQuery += RetSqlName("FKG") + " FKG, "
	cQuery += RetSqlName("CCF") + " CCF  "
	
	cQuery += " WHERE "
	cQuery += "SE1.E1_FILIAL " + cQryIn + " AND "
	cQuery += "FK7.FK7_FILIAL = SE1.E1_FILIAL AND "		
	cQuery += "FK7.FK7_CHAVE = "
	cQuery += " E1_FILIAL || '|' || E1_PREFIXO || '|' || E1_NUM || '|' || E1_PARCELA || '|' || "
	cQuery += " E1_TIPO || '|' ||  E1_CLIENTE || '|' ||  E1_LOJA  AND "
	cQuery += "FKG.FKG_FILIAL = SE1.E1_FILIAL AND "	
	cQuery += "FK7.FK7_IDDOC = FKG.FKG_IDDOC AND "
	If nTamCCF > 0
		cQuery += "SUBSTRING(CCF.CCF_FILIAL,1,"+ cValToChar(nTamCCF)+") = SUBSTRING(E1_FILORIG,1,"+ cValToChar(nTamCCF)+") AND "
	EndIf
	cQuery += "FKG.FKG_NUMPRO = CCF.CCF_NUMERO AND "
	cQuery += "CCF.CCF_RESACA = '3' AND FKG.FKG_APURIN = '1' AND "
	cQuery += "SE1.E1_CLIENTE BETWEEN '"+ aResWiz2[1] +" ' AND '"+ aResWiz2[2]+"' AND "
	cQuery += "SE1.E1_LOJA BETWEEN '"+ aResWiz2[3]+" ' AND '"+ aResWiz2[4]+"' AND "

	Do Case
		Case aDataEmi[1] $ aResWiz2[5]
			cQuery += "SE1.E1_EMIS1 BETWEEN '"+ dTos(aResWiz2[6])+"' AND '"+ dTos(aResWiz2[7]) +"' AND "
		Case aDataEmi[2] $ aResWiz2[5]
			cQuery += "SE1.E1_EMISSAO BETWEEN '"+ dTos(aResWiz2[6])+"' AND '"+ dTos(aResWiz2[7]) +"' AND "
		Case aDataEmi[3] $ aResWiz2[5]
			cQuery += "SE1.E1_VENCREA BETWEEN '"+ dTos(aResWiz2[6])+"' AND '"+ dTos(aResWiz2[7]) +"' AND "
		Case aDataEmi[4] $ aResWiz2[5] 
			cQuery += "SE1.E1_VENCTO BETWEEN '"+ dTos(aResWiz2[6])+"' AND '"+ dTos(aResWiz2[7]) +"' AND "
	EndCase

	cQuery += "SE1.D_E_L_E_T_ = ' ' AND FK7.D_E_L_E_T_ = ' ' AND "
	cQuery += "FKG.D_E_L_E_T_ = ' ' AND "
	cQuery += "CCF.D_E_L_E_T_ = ' '  "
	
	cQuery += "ORDER BY SE1.E1_CLIENTE, SE1.E1_LOJA "
			
	cQuery := ChangeQuery(cQuery)
	
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSe1,.T.,.T.)
		
	TCSetField( cAliasSe1, "FKG_VALOR", "N", nTamVal, nDescVal )
	TCSetField( cAliasSe1, "E1_BASEINS", "N", nTamBas, nDescBas )
	TCSetField( cAliasSe1, "E1_INSS", "N", nTamINS, nDescINS )
	
	
	dbSelectArea(cAliasSe1)
	DbGoTop()
	ProcRegua((cAliasSe1)->(RecCount()))
	
	/*Estrutura do aCols3
	aCols3[1][1]	:= "Cliente" + 	"loja"	
	aCols3[1][2]	:= "Nome"
	aCols3[1][3]	:= "Valor Base"
	aCols3[1][4]	:= "Inss Abatatido"
	aCols3[1][5]	:= "Inss a Abater"*/
	
	/*Estrutura do aRecnoFKG utilizado para montagem do relatório e gravação dos campos FKG_TITINS, FKG_APURIN
	aRecnoFKG[1][1]	:= "Cliente" + 	"loja"	
	aRecnoFKG[1][2]	:= Recno da FKG
	aRecnoFKG[1][3]	:= cIDDOC do título gerado após o acerto
	aRecnoFKG[1][4]	:= Recno da SE1 */
	
	While (cAliasSe1)->(!Eof())
		IncProc(STR0052)//"Processando"
		nPos:=  Ascan(aCols3, {|x|x[1]  == (cAliasSe1)->E1_CLIENTE+(cAliasSe1)->E1_LOJA})
		If nPos == 0
			If (cAliasSe1)->FKG_DEDACR == "1"
				AADD(aCols3, {(cAliasSe1)->E1_CLIENTE+(cAliasSe1)->E1_LOJA,(cAliasSe1)->E1_NOMCLI,(cAliasSe1)->E1_BASEINS,(cAliasSe1)->E1_INSS,-(cAliasSe1)->FKG_VALOR} )
			Else
				AADD(aCols3, {(cAliasSe1)->E1_CLIENTE+(cAliasSe1)->E1_LOJA,(cAliasSe1)->E1_NOMCLI,(cAliasSe1)->E1_BASEINS,(cAliasSe1)->E1_INSS,(cAliasSe1)->FKG_VALOR} )
			Endif
		Else
			nPosRec := Ascan(aRecnoFKG, {|x|x[4]  == (cAliasSe1)->SE1RECNO})
			If nPosRec == 0
				aCols3[nPos][3]+=(cAliasSe1)->E1_BASEINS
				aCols3[nPos][4]+=(cAliasSe1)->E1_INSS
			Endif
			If (cAliasSe1)->FKG_DEDACR == "1"
				aCols3[nPos][5]-=(cAliasSe1)->FKG_VALOR
			Else
				aCols3[nPos][5]+=(cAliasSe1)->FKG_VALOR
			Endif
		
		Endif
		
		AADD(aRecnoFKG, {(cAliasSe1)->E1_CLIENTE+(cAliasSe1)->E1_LOJA, (cAliasSe1)->FKGRECNO, "",(cAliasSe1)->SE1RECNO})
		(cAliasSe1)->(DbSkip())
	
	Enddo
	
	(cAliasSE1)->(dbCloseArea())
	If !Empty(cTmpFil)
		dbSelectArea(cTmpFil)
		dbCloseArea()
		Ferase(cTmpFil+GetDBExtension())
		Ferase(cTmpFil+OrdBagExt())
		cTmpFil := ""
	Endif
	
	
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} F377Selfil 
função para ajustar a estrutura do array com as filiais selecionadas
@param aFils Array com as filiais para selecionadas pelo usuário
@param aSelFil Array com a estrutura para usar na função GetRngFil
@author Pâmela Bernardo
@since 05/06/2017
@version P11.80
/*/
//-------------------------------------------------------------------
Static Function F377Selfil(aFils,aSelFil )
	Local nCont := 1
	For nCont:=1 to Len(aFils)
	
		If aFils[nCont][1]
			aAdd(aSelFil, aFils[nCont][2])
		Endif
	
	Next
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} F377MosTit 
função exibir dados dos títulos que serão gerados


@author Pâmela Bernardo
@since 05/06/2017
@version P11.80
/*/
//-------------------------------------------------------------------
Static Function  F377MosTit ()
	Local nCont 	:= 1
	Local cTipoNCC	:= "NCC"
	Local cTipoDeb	:= GetMv("MV_TPAPUIN",.F.,'"DP"')
	Local cNatNCC 	:= GetMv("MV_NATNCC",.F.,'"NCC"')
	Local cNatDeb	:= GetMv("MV_NATIND",.F.,'"DEB"')
	Local cDesNCC	:= F377GrvNat (cNatNCC, 1)
	Local cDesDeb	:= F377GrvNat (cNatDeb, 2)
	
	aCols4 := {}
	/*Estrutura do aCols
	aCols4[1]	:= "Cliente/Loja" 		
	aCols4[2]	:= "Nome"
	aCols4[3]	:= "Tipo"
	aCols4[4]	:= "Natureza"
	aCols4[5]	:= "Descrição"
	aCols4[6]	:= "Valor"*/
	ProcRegua(Len(aCols3))	
	For nCont:=1 to Len(aCols3)
		IncProc(STR0052)//"Processando"
	
		If aCols3[nCont][5]>0
			aAdd(aCols4, {aCols3[nCont][1],aCols3[nCont][2], cTipoDeb, cNatDeb, cDesDeb, ABS(aCols3[nCont][5])} )
		Elseif aCols3[nCont][5]<>0 
			aAdd(aCols4, {aCols3[nCont][1],aCols3[nCont][2], cTipoNCC, cNatNCC, cDesNCC, ABS(aCols3[nCont][5])} )
		Endif
	
	Next
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} F377GrvNat 
função exibir dados dos títulos que serão gerados
@param cNaturez Natureza a ser inclusa
@param nOpera 1 Natureza de Credito/2 Natureza de Debito
@author Pâmela Bernardo
@since 05/06/2017
@version P11.80
/*/
//-------------------------------------------------------------------
Static Function  F377GrvNat (cNaturez, nOpera)
	Local cDescri 	:= ""
	Local aArea 	:= GetArea()
	
	DbSelectArea("SED")
	If !SED->(DbSeek(xFilial("SED")+avKey(cNaturez,"ED_CODIGO")))
		RecLock("SED",.T.)
		SED->ED_FILIAL  := xFilial("SED")
		SED->ED_CODIGO  := cNaturez
		SED->ED_CALCIRF := "N"
		SED->ED_CALCISS := "N"
		SED->ED_CALCINS := "N"
		SED->ED_CALCCSL := "N"
		SED->ED_CALCCOF := "N"
		SED->ED_CALCPIS := "N"
		If nOpera == 1
			SED->ED_DESCRIC := STR0048 //"Natureza de crédito para acerto de INSS CR"
		Else
			SED->ED_DESCRIC := STR0049 //"Natureza de débito para acerto de INSS CR"
		Endif
		SED->ED_TIPO	:= "2"
		MsUnlock()
	EndIf
	
	cDescri := SED->ED_DESCRIC
	
	RestArea(aArea)
	
return cDescri

//-------------------------------------------------------------------
/*/{Protheus.doc} F377Grava
função gravar os títulos a receber


@author Pâmela Bernardo
@since 05/06/2017
@version P11.80
/*/
//-------------------------------------------------------------------
Static Function  F377Grava ()
	
	Local aTit 		:= {}
	Local nCont 	:= 1
	Local lRet 		:= .T.
	Local nPos 		:= 0
	Local cChave	:= ""
	Local cIdDoc 	:= ""
	Local nx 		:= 0
	Local cPrefixo	:= GetMv("MV_PRFINS",.F.,'"APR"')
	Local cNumtit	:= ""
	Local cCliente	:= ""
	Local cloja		:= ""
	Local cParc		:= SOMA1(Chr(Asc(GetMV("MV_1DUP"))-1))
	Local nTamArray	:= Len(aRecnoFKG)

	Begin Transaction 
		ProcRegua(Len(aCols4))
		For nCont:=1 to Len(aCols4)
			IncProc(STR0052)//"Processando"
			aTit := {}
			cCliente := SubStr(aCols4[nCont][1], 1,nTamCli)
			cloja:= SubStr(aCols4[nCont][1], nTamCli+1,nTamLoj)
			cNumtit	:= F377NroTit(cPrefixo,cParc ,cCliente, cloja,  aCols4[nCont][3]) 
			AADD(aTit , {"E1_FILIAL"	, xFilial("SE1")									, NIL})						
			AADD(aTit , {"E1_PREFIXO"	, cPrefixo											, NIL})
			AADD(aTit , {"E1_NUM"    	, cNumtit											, NIL})
			AADD(aTit , {"E1_PARCELA"	, cParc												, NIL})
			AADD(aTit , {"E1_TIPO"   	, aCols4[nCont][3]									, NIL})
			AADD(aTit , {"E1_NATUREZ"	, aCols4[nCont][4]									, NIL})
			AADD(aTit , {"E1_VENCTO" 	, dDatabase											, NIL})
			AADD(aTit , {"E1_VENCREA"	, DataValida(dDatabase,.T.)							, NIL})
			AADD(aTit , {"E1_VENCORI"	, DataValida(dDatabase,.T.)							, NIL})
			AADD(aTit , {"E1_EMISSAO"	, dDataBase											, NIL})
			AADD(aTit , {"E1_EMIS1"		, dDataBase											, NIL})
			AADD(aTit , {"E1_CLIENTE"	, cCliente											, NIL})
			AADD(aTit , {"E1_LOJA"   	, cloja												, NIL})
			AADD(aTit , {"E1_NOMCLI" 	, aCols4[nCont][2]									, NIL})
			AADD(aTit , {"E1_MOEDA"  	, 1													, NIL})
			AADD(aTit , {"E1_VALOR"  	, aCols4[nCont][6]									, NIL})
			AADD(aTit , {"E1_SALDO"  	, aCols4[nCont][6]									, NIL})
			AADD(aTit , {"E1_VLCRUZ" 	, aCols4[nCont][6]									, NIL})
			AADD(aTit , {"E1_STATUS" 	, "A"												, NIL})
			AADD(aTit , {"E1_ORIGEM" 	, "FINA377A"										, NIL})
			
			MSExecAuto({|a,b| FINA040(a,b)}, aTit, 3)
	
			
			If  lMsErroAuto
			    MOSTRAERRO()
			    DisarmTransaction() 
			    Exit
			Endif
			cChave := SE1->E1_FILIAL + "|" +  SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO + "|" +;
						SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
			cIdDoc := FINGRVFK7("SE1", cChave)
			nPos:=  Ascan(aRecnoFKG, {|x|x[1]  == aCols4[nCont][1]})
			For nx:=1 to Len(aRecnoFKG)
				If nPos<= nTamArray .and. aRecnoFKG[nPos][1] == aCols4[nCont][1]
					aRecnoFKG[nPos][3] :=cIdDoc 
					FKG->(dBGoto(aRecnoFKG[nPos][2]))
					RecLock("FKG",.F.)
						FKG->FKG_APURIN := "3"
						FKG->FKG_TITINS := cIdDoc
					FKG->(MsUnlock())
					nPos++
				Else
					Exit
				Endif
			Next
		Next
	End Transaction
	
	If aResWiz2[8] $ aSimNao[1] .and. !lMsErroAuto
		FINR377A()//função de impressão do relatório
	Endif

	
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F377NroTit
função retorna o numero do proximo título


@author Pâmela Bernardo
@since 05/06/2017
@version P11.80
/*/
//-------------------------------------------------------------------

Static Function F377NroTit(cPrefixo,cParc,cCliente, cloja, ctipo) 

Local aArea 	:= GetArea()
Local cNumTit 	:= Replicate('0',nTamTit)
Local cQuery	:= ""
Local cAliasTRB := GetNextAlias()

	cQuery := "SELECT MAX(E1_NUM) MAXNUMPRC FROM " + RetSqlName("SE1") + " "
	cQuery += "WHERE E1_FILIAL = '" + xFilial("SE1")+ "' AND "
	cQuery += "E1_PREFIXO = '" + cPrefixo + "' AND "
	cQuery += "E1_PARCELA = '" + cParc + "' AND "
	cQuery += "E1_TIPO = '" + ctipo + "' AND "
	cQuery += "D_E_L_E_T_ = ' ' "
    cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTRB, .F., .T.)

	//Obtem o maior numero de titulo
	If (cAliasTRB)->(!EOF())
		cNumTit := (cAliasTRB)->MAXNUMPRC
	EndIf
	(cAliasTRB)->(dbCloseArea())
	
	RestArea(aArea)
	cNumTit := Soma1( cNumTit, nTamTit )
	
Return cNumTit

//-------------------------------------------------------------------
/*/{Protheus.doc} fMarkAll 
Marca/Desmarca todas filiais

@param aFils Array com as filiais para seleção

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------

Static Function fMarkAll(aFils)

Local nI := 0

If Len(aFils) > 0
	For nI := 1 to Len(aFils)
		If aFils[nI][1]
			aFils[nI][1] := .F.
		Else
			aFils[nI][1] := .T.
		EndIf
	Next
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} F377MP3 
Processamento da busca de clientes.

@param aFils Array com as filiais para seleção

@author Pâmela Bernardo
@since 06/06/17
@version P11
/*/
//-------------------------------------------------------------------

Static Function F377MP3(aFils)

Local lEnd := .F.
Local lRet := .T.

	Processa({|lEnd| F377ProcTit(aFils)},STR0046)//"Selecionando Registros"
	If Len(aCols3) == 0
		lRet := .F.	
		Help(" ",1,"NOTITACR",,STR0051, 1, 0) //"Não existem títulos para acerto de INSS"
		
	Else
		oCli:SetArray(aCols3)
		oCli:bLine := {|| {aCols3[oCli:nAt,1],;
						aCols3[oCli:nAt,2],;
						Transform( aCols3[oCli:nAt,3], cMascBase ),;
						Transform( aCols3[oCli:nAt,4], cMascINS ),;
						Transform( aCols3[oCli:nAt,5], cMascVal );
					}}	
		oCli:Refresh()
	EndIf

	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F377MP4 
Demonstração dos títulos que serão gerados

@author Pâmela Bernardo
@since 06/06/17
@version P11
/*/
//-------------------------------------------------------------------

Static Function F377MP4()

Local lEnd := .F.
	
	Processa({|lEnd| F377MosTit()},STR0047)//"Processando Clientes/Títulos"
	If Len(aCols4) == 0
		lRet := .F.	
		Help(" ",1,"NOTITACR",,STR0051, 1, 0) //"Não existem títulos para acerto de INSS"
		
	Else
		oTit:SetArray(aCols4)

		oTit:bLine := {|| {aCols4[oTit:nAt,1],;
						aCols4[oTit:nAt,2],;
						aCols4[oTit:nAt,3],;
						aCols4[oTit:nAt,4],;
						aCols4[oTit:nAt,5],;
						Transform(aCols4[oTit:nAt,6], cMascVal );
					}}
	
		oTit:Refresh()
	Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} F377MP5 
Gravação dos títulos

@author Pâmela Bernardo
@since 06/06/17
@version P11
/*/
//-------------------------------------------------------------------

Static Function F377MP5()

Local lEnd := .F.

	Processa({|lEnd| F377Grava()},STR0050)//"Gravando Títulos"

Return .T.
